
# vim: tabstop=4 shiftwidth=4 expandtab

"""
ccg_nl.py
A class to process non-linearity response curve calibrations
"""
from __future__ import print_function

import os
import sys
import datetime
from collections import defaultdict
from scipy.odr import odrpack as odr
from scipy.odr import models
import numpy

#sys.path.append("/ccg/src/python3/lib")

import ccg_process
import ccg_refgasdb
import ccg_grav_refgasdb
import ccg_dilution
import ccg_dates
import ccg_utils
import ccg_response
from cal_co2isotopes import calcProbability, getR13PDB


########################################################################
def powfunc(B, x):
    """ Calculate value of power function with coefficients B at value x """

    return B[0] + B[1] * numpy.power(x, B[2])

def expfunc(B, x):
    """ Calculate value of exponential function with coefficients B at value x """

    return B[0] + B[1] * numpy.exp(B[2]*x)

########################################################################
class nlConfig:
    """ A class for holding various configuration values for non-linearity processing. """

    def __init__(self,
                species, method, analyzer_id, idate, system, primary_standards, adate, use_dilution,
                order, odrfit, usenormal, usezero, functype, nulltanks,
                use_x_weights, use_y_weights, co2_626_only, ref_op):

        # default values
        self.order = 2
        self.odrfit = True
        self.usenormal = False
        self.skip_first = False
        self.calc_method = "default"
        self.usezero = False
        self.skip_R1 = False
        self.functype = "poly"
        self.nulltanks = []
        self.use_x_weights = True
        self.use_y_weights = True
        self.co2_626_only = False
        self.ref_op = "divide"

        # modifications to default values
        self.usezero = usezero
        self._set_order(species, method, analyzer_id, adate, order)
        self._set_nulltanks(species, system, primary_standards, nulltanks)
        self._set_co2_626(species, method, system, co2_626_only)
        self._set_odrfit(species, method, odrfit)
        self._set_usenormal(species, analyzer_id, adate, use_dilution, primary_standards, usenormal)
        self._set_skipR1(species, analyzer_id)
        self._set_ref_op(species, analyzer_id, ref_op, idate)
        self._set_skip_first(species, analyzer_id)
        self._set_calc_method(analyzer_id, idate)
        self._set_functype(species, analyzer_id, functype)
        self._set_weight(species, system, use_x_weights, use_y_weights)

    #--------------------------------------------------------------------------
    def printConfig(self):
        """ Print out configuration values used in calculations """

        frmt = "%25s %s"

        print(frmt % ("Use ODR Fit:", self.odrfit))
        print(frmt % ("ODR Function type:", self.functype))
        print(frmt % ("ODR Polynomial order:", self.order))
        print(frmt % ("Use Normalization point:", self.usenormal))
        print(frmt % ("Use Zero point:", self.usezero))
        print(frmt % ("Skip first cycle:", self.skip_first))
        print(frmt % ("Skip R1:", self.skip_R1))
        print(frmt % ("STD tanks to skip:", self.nulltanks))
        print(frmt % ("Use X weights:", self.use_x_weights))
        print(frmt % ("Use Y weights:", self.use_y_weights))
        print(frmt % ("Reference operation: ", self.ref_op))
        print(frmt % ("Calc method: ", self.calc_method))

    #--------------------------------------------------------------------------
    def _set_order(self, species, method, analyzer_id, adate, order):
        """ Set the order of the odr/poly fit """

        # if poly order not specified, change default for certain cases
        # if specified, use that
        if order == 0:
            if species == "N2O" and "ICOS" in method:
                self.order = 1
            elif species == "CH4" and analyzer_id in ("PC1", "PC2"):
                self.order = 1
            elif species == "CO2" and analyzer_id in ("PC1", "PC2"):
                self.order = 1
            elif species == "H2" and analyzer_id in ("H8", "H9", "H11"):
                self.order = 1
            elif species == "CO" and analyzer_id in ("AR2"):
                self.order = 1
            elif species == "CO" and analyzer_id == "V2" and adate >= datetime.datetime(2023, 1, 31, 0, 0, 0):
                self.order = 1
            elif species == "N2O" and analyzer_id in ("AR2", "AR3"):
                self.order = 1
            elif species == "CO" and analyzer_id in ("AR3") and (adate > datetime.datetime(2024,4,1,0,0,0) and adate <= datetime.datetime(2025,1,28,0,0,0)) :
                self.order = 3

        else:
            if order > 8 or order < 0:
                raise ValueError("Bad order value, must be 1 to 8.")

            self.order = order

    #--------------------------------------------------------------------------
    def _set_nulltanks(self, species, system, primary_standards, nulltanks):
        """ set list of tank serial numbers to skip in calculations """

        # n2o lgr needs to skip some tanks
        if nulltanks is None:
            #if species == "N2O" and "ICOS" in method and idate > 2011063000:
            if system.lower() == "cocal-1" and species.lower() == "n2o":
                self.nulltanks = ['ND39907', 'ND39902', 'ND39134', 'ND46739']

            elif system.lower() == "co2cal-2":
                if primary_standards:
                    #primary standards outside range 250 - 600 ppm
                    #cfg.nulltanks = ['CB11054','CC71605','CA03386']
                    pass
                else:
                    # secondary stds outside range
                    #cfg.nulltanks = ['CC71578','CB10726','CB10726']
                    pass
            elif system.lower() == "magicc-3" and species == "H2":
                #self.nulltanks = ['CA07502','CA06388','CA05773','CA07987','CA08251']
                self.nulltanks = ['CA07502','CA07987','CA08251']

        else:
#            self.nulltanks = nulltanks
            self.nulltanks = [sn.upper() for sn in nulltanks.split(',')]


    #--------------------------------------------------------------------------
    def _set_co2_626(self, species, method, system, co2_626_only):
        """ set if using co2_626 only or total co2 """

        # if system is co2cal-2 use co2_626 values not total co2 for curve fit.
        # Will convert back to total for sample tanks in calpro.py
        if co2_626_only is None:
            if species == "CO2" and system.upper() == "CO2CAL-2" and method.upper() in ("CRDS", "QC-TILDAS", "OFFAXIS-ICOS"):
                self.co2_626_only = True
            else:
                self.co2_626_only = False
        else:
            self.co2_626_only = co2_626_only

    #--------------------------------------------------------------------------
    def _set_odrfit(self, species, method, odrfit):
        """ set if using odr fit or polynomial fit """

        # if odrfit not specified, change default for certain cases
        # if specified, use that
        if odrfit is None:
            if species == "CO" and method == "GC":
                self.odrfit = False
        else:
            self.odrfit = odrfit

    #--------------------------------------------------------------------------
    def _set_usenormal(self, species, analyzer_id, adate, use_dilution, primary_standards, usenormal):
        """ set if adding a normal point (a value equal to the reference) """

        # if usenormal not specified, change default for certain cases
        # if specified, use that
        if usenormal is None:
            if species == "CO" and "LGR" not in analyzer_id:
                if adate >= datetime.datetime(2017, 12, 28, 0, 0, 0):
                    self.usenormal = False
                else:
                    self.usenormal = True
            if use_dilution or primary_standards: #don't use ref tank if running dilution standards
                self.usenormal = False
        else:
            self.usenormal = usenormal

    #--------------------------------------------------------------------------
    def _set_skipR1(self, species, analyzer_id):
        """ set if skipping R1 tank """

        # if species = CO and instrument code R5 or R6 don't use standard R1
        if species == "CO" and analyzer_id in ("R5", "R6"):
            self.skip_R1 = True

    #--------------------------------------------------------------------------
    def _set_ref_op(self, species, analyzer_id, ref_op, idate):
        """ set reference operator (subtract or divide) """

        # how to use reference tank, default is divide
        if ref_op is not None:
            if ref_op.lower() in ['divide', 'subtract', 'none']:
                self.ref_op = ref_op.lower()
            else:
                print("nl.py, Bad reference operation %s. Must be one of 'divide', 'subtract', or 'none'" % ref_op, file=sys.stderr)
                sys.exit()
        else:
            if analyzer_id == "AR1":
                if idate < 2022103000:
                    self.ref_op = "subtract"
                else:
                    self.ref_op = "divide"
            elif analyzer_id == "AR2" and species == "CO":
                self.ref_op = "subtract"
                #self.ref_op = "divide"
            elif analyzer_id in ["PIC-030", "PC-3"]:
                self.ref_op = "subtract"
            elif analyzer_id == "PIC-012":
                self.ref_op = "none"
            else:
                self.ref_op = "divide"

    #--------------------------------------------------------------------------
    def _set_skip_first(self, species, analyzer_id):
        """ set if skipping the first aliquot of the sample and reference """

        # For CO nl cals on magicc 1 and 2, remove first sample and the following reference
        # for each sample tank, due to stream selection valve contamination problems.
        # Also remove first shots for N2O on H4 and H6 due to ECD
        # response changing after long flushing times between standards.
        if ((species == "CO" and analyzer_id in ("R5", "R6"))
           or (species == "N2O" and analyzer_id in ("H4", "H6"))
           or (analyzer_id in ("AR1", "PC-3"))
           or (species == "H2" and analyzer_id in ("H9"))):
            self.skip_first = True

    #--------------------------------------------------------------------------
    def _set_calc_method(self, analyzer_id, idate):
        """ set calculation method.  Older co systems responses are calculated differently """

        # Check if we need to use a different calculation method from the default
        if analyzer_id == "R2" and 1993010100 <= idate <= 1997100200:
            self.calc_method = "old_co"

        elif analyzer_id == "R7" and 1997101000 <= idate <= 2001082500:
            self.calc_method = "old_co"

#        elif analyzer_id == "PIC-012":
#            self.calc_method = "inst_cal"

    #--------------------------------------------------------------------------
    def _set_functype(self, species, analyzer_id, functype):
        """ set function type to use in fit (poly, power) """

        # CH4 H5 cals use power function for default
        if functype is None:
            if analyzer_id == "H5":
                self.functype = "power"
            elif analyzer_id == "LGR2" and species == "CO":
                self.functype = "power"
        else:
            self.functype = functype

    #--------------------------------------------------------------------------
    def _set_weight(self, species, system, use_x_weights, use_y_weights):
        """ set how to use weighting of data points """

        # for CO response curves on old Carle System (inst = "CS") don't weight ODR fit
        if use_x_weights is None:
            if species == "CO" and system.lower() == "carle":
                self.use_x_weights = False
            else:
                self.use_x_weights = True
        else:
            self.use_x_weights = use_x_weights

        if use_y_weights is None:
            if species == "CO" and system.lower() == "carle":
                self.use_y_weights = False
            else:
                self.use_y_weights = True
        else:
            self.use_y_weights = use_y_weights


##################################################################
class Response(ccg_process.processData):
    """ Class for processing of non-linearity response curve (nl) calibration files.

        Input parameters:
        rawfile : raw file name
        database : optional name of database for getting/updating response curve data
        peaktype : optional peak type for GC method, either "area" or "height"
        moddate : modification date, used in determining which reference gas values to use within a scale
        scale : optional scale to use for reference gas values instead of default scale
        order : order of odr fit, either 1 for linear, 2 for quadratic
        odrfit : use odr fit instead of polynomial fit if true.  If None, use default for that system
        usenormal : add data point at [1, ref gas mr] if true. Will have only 1 of the values None, True or False.
                If None, use default for that system
        usezero : add data point at [0,0] if true. If "", use default for that system
        debug : print out processing messages if true
        nulltanks : List of tank serial numbers to exclude from odr fit
        use_x_weights : Choose how to use weighting for the x axis values in the fit.
            Default is None, which means use default values.  Set to True/False to force using/not using weights.
        use_y_weights : Choose how to use weighting for the y axis values in the fit.
            Default is None, which means use default values.  Set to True/False to force using/not using weights.
        functype : Type of function to use in odr fit, e.g. 'poly', 'power'
        co2_626_only : convert total co2 to 626 only before fitting. Will have only 1 of the values None, True or False
                   If None, use default
        c13scale : Name of co2c13 database table to use for co2c13 values. Default is current
        o18scale : Name of o18c13 database table to use for o18c13 values. Default is current
        ref_op : reference operation (divide, subtract, or none for not used)


        Usage of this class:
            nldata = nl.response(info, raw, rawfilename)

        Attributes:
            results : list of tuples containing results of response curve calibration

    """

    def __init__(self, rawfile, database=None, peaktype=None, moddate=None, scale=None,
             order=0, odrfit=None, usenormal=None, usezero=False, debug=False,
             nulltanks=None, use_x_weights=None, use_y_weights=None,
             functype=None, co2_626_only=None, c13scale=None, o18scale=None, ref_op=None):


        # python 3 only syntax is super().__init__...
        super(Response, self).__init__("nl", rawfile,
                         database=database,
                         peaktype=peaktype,
                         scale=scale,
                         moddate=moddate,
                         debug=debug)

        if not self.valid: return

#        print("@@@@@@@@@@@@@@@@@@@@@@@@@ scale is", scale, self.scale)
        self.database = database

        # gas species
        if "Baseline Codes" in self.raw.info:
            self.bcodes = self.raw.info["Baseline Codes"].split()
        else:
            self.bcodes = []
        self.valid = True

        self.c13scalenum, self.c13scale = self.get_scale_info('CO2C13', c13scale)
        self.o18scalenum, self.o18scale = self.get_scale_info('CO2O18', o18scale)
#        print("@@@@@@@@@@@@@@@@@@@@@@@@@ c13scale is", c13scale, self.c13scalenum)
#        self.o18scale = o18scale
        if self.species in ['CO2C13', 'CO2O18']:
            self.co2scale = self.scale
        else:
            self.co2scale = None

        self.rawfile = os.path.basename(rawfile)

        # relative uncertainty to apply to ref gas mixing ratio assigned values if not in database
    #    self.relunc = {"CO2": 0.0002, "CH4": 0.0015, "N2O": 0.001, "SF6": 0.01, "CO": 0.01, "H2": 0.01}
        self.relunc = {"CO2": 0.07, "CH4": 1.0, "N2O": 0.2, "SF6": 0.05, "CO": 1.2, "H2": 0.5, "CO2C13": 0.07, "CO2O18": 0.07}


        # Check if dilution standards are being used
        self.use_dilution = False
        self.primary_standards = False
        if "C" in self.raw.info:
            for comment in self.raw.info["C"]:
                if "Dilution" in comment:
                    self.use_dilution = True
                if "PRIMARY STANDARDS" in comment:
                    self.primary_standards = True



        # If start date is specified in raw file, use that,
        # otherwise, date to start using the response curve is one day after the analysis date.
        # This is the value that goes into the response file
        # There can be multiple start dates in the raw file, so store them in a list.
        self.startdate = []
        if "Start Date" in self.raw.info:
            for date in self.raw.info["Start Date"]:
                self.startdate.append(ccg_dates.getDatetime(date))
        else:
            oneday = datetime.timedelta(days=1)
            sdate = datetime.datetime(self.adate.year, self.adate.month, self.adate.day) + oneday
            self.startdate.append(sdate)


        # create a class holding configuration data
        self.config = nlConfig(self.species, self.method, self.analyzer_id, self.idate,
                        self.system, self.primary_standards, self.adate, self.use_dilution,
                        order, odrfit, usenormal, usezero, functype, nulltanks,
                        use_x_weights, use_y_weights, co2_626_only, ref_op)

        # modify certain settings for picarro instruments with lab cal
        if "Type" in self.raw.info:
            if self.raw.info['Type'] == 'INSTRUMENT_CAL':
                self.config.calc_method = 'inst_cal'
                self.config.order = 1
                self.config.ref_op = "none"

        if "Method" in self.raw.info:
            if self.raw.info['Method'] == 'INSTRUMENT_CAL':
                self.config.calc_method = 'inst_cal'
                self.config.order = 1
                self.config.ref_op = "none"

        # find the id of the reference tank.
        if self.config.calc_method == "inst_cal":
            self.refid = "None"

        else:
            self.refid = self.raw.refid
            if self.refid is None:
                sys.exit("ERROR: No reference data found in raw file.")

        # Get reference gas values for this analysis date
        # Creates a dict with refgas id as keys,
        # tuple of (serial number, mixing ratio, uncertainty) as value for the given adate
        # e.g. self.refgas["L"] = ('CC71111', 385.66, 0.02)
        self.refgas = self._get_refgas_nl(self.adate)

        self.respdata = self._get_response_ratios()    # calculate std/ref ratios from raw data

        if self.debug:
            print("Response ratios:", file=sys.stderr)
            for key in list(self.respdata.keys()):
                print(key, self.respdata[key])

        self.avg = self._get_averages()            # calculate average std/ref ratio for each std
        if self.debug:
            print("Averages:", file=sys.stderr)
            for key, value in self.avg.items():
                print(key, value)

        #For old CO system, if n <= 3 then use linear fit, otherwise quadratic
        if self.config.calc_method == "old_co":
            if len(self.avg) <= 3:
                self.config.order = 1

        self.results, self.unc = self._compute_nl()        # calculate fit of mr vs std/ref
#        print(self.results)


    #--------------------------------------------------------------------------
    def _get_refgas_nl(self, adate=None):
        """ Read in reference gas values from database or file.
        Return a dict with tank name as keys, tuple of (serial numbers, mixing ratios) as values
        """

        refgas = {}

        # get a list of serial numbers to filter refgasdb results
        serialnums = [self.raw.info[ref] for ref in self.raw.stds]

#        print("get refgas for", self.species, "scale", self.scale, self.co2scale)
        # first figure out where we want to get assigned values from
        if self.species == "CO2C13" or self.species == "CO2O18":
            ref = ccg_refgasdb.refgas("CO2",
                                      sn=serialnums,
                                      scale=self.co2scale,
                                      database=self.database,
                                      moddate=self.moddate,
                                      debug=self.debug)
        else:
            if self.scale:
                if self.scale.lower in ("grav", "gravimetric"):
                    ref = ccg_grav_refgasdb.refgas(self.species,
                                                   scale=self.scale,
                                                   database=self.database,
                                                   moddate=self.moddate,
                                                   convert_units=True,
                                                   debug=self.debug)
                else:
                    ref = ccg_refgasdb.refgas(self.species,
                                              sn=serialnums,
                                              enddate=self.adate,
                                              scale=self.scale,
                                              database=self.database,
                                              moddate=self.moddate,
                                              debug=self.debug)
            else:
                ref = ccg_refgasdb.refgas(self.species,
                                          sn=serialnums,
                                          scale=self.scale,
                                          database=self.database,
                                          moddate=self.moddate,
                                          debug=self.debug)


        # if using only 626 CO2:
        #       read 13C delta values from DB table
        #       read 18O delta values from DB table
        if self.config.co2_626_only or self.species == "CO2C13" or self.species == "CO2O18":
            ref_co2c13 = ccg_refgasdb.refgas("CO2C13", sn=serialnums, scale=self.c13scale, database=self.database, moddate=self.moddate)
            ref_co2o18 = ccg_refgasdb.refgas("CO2O18", sn=serialnums, scale=self.o18scale, database=self.database, moddate=self.moddate)

        # now get the assigned values for all the stds and ref used

        # for R0, we need it added to refgas, but usually there isn't an assigned value
        # unless we're adding it as a 'normal' tank (i.e. ratio = 1.0)
        if self.config.usenormal:
            serialnum = self.raw.info[self.refid]
            mr, unc = ref.getRefgasBySerialNumber(serialnum, self.adate)
            refgas[self.refid] = (serialnum, mr, unc)
        else:
            if self.config.calc_method != "inst_cal":
                refgas[self.refid] = (self.raw.info[self.refid], -999.99, -99.99)

        # now get assigned values for all the standards
        for smpid in self.raw.stds:
#            print("!!!!!!!!!!!!!!!!!!!! get assigned value for ", smpid, self.config.co2_626_only)

            serialnum = self.raw.info[smpid]
            if self.use_dilution and smpid != self.refid:
                tank = ccg_dilution.dilution(serialnum, self.adate, database=self.database)
                mr = tank.assigned_co
                unc = tank.assigned_co_sd

            elif self.config.co2_626_only or self.species == "CO2C13" or self.species == "CO2O18":
                mr, unc = self._correct_co2(serialnum, ref, ref_co2c13, ref_co2o18)

            else:
 #               print("@@@@@", serialnum, adate)
                mr, unc = ref.getRefgasBySerialNumber(serialnum, adate)

            refgas[smpid] = (serialnum, mr, unc)


        return refgas


    #--------------------------------------------------------------------------
    def _correct_co2(self, serialnum, ref, ref_co2c13, ref_co2o18):
        """ Make isotopic corrections to co2 of tank 'serialnum' """

        #       get total co2 value for serial num
        #       get delta 13C value for serial num
        #       get delta 18O value for serial num
        co2, co2_unc = ref.getRefgasBySerialNumber(serialnum, self.adate)
        d13c, d13c_unc = ref_co2c13.getRefgasBySerialNumber(serialnum, self.adate)
        d18o, d18o_unc = ref_co2o18.getRefgasBySerialNumber(serialnum, self.adate)

        # divide each delta value by 1000 to simplify equations below
        d13c = d13c / 1000.0
        d18o = d18o / 1000.0
#        d17o = d17o / 1000.0

#!!!!IMPORTANT Need to get r13_PDB for correct co2 scale to pass into calcProbability. Default is value for X2007 scale
        r13_PDB = getR13PDB(self.scale)
        P626, P636, P628, P627 = calcProbability(d13c, d18o, r13_PDB)

        co2_626_mr = P626 * co2
        co2_636_mr = P636 * co2
        co2_628_mr = P628 * co2
#        co2_627_mr = P627 * co2

        # *** Have not included isotope uncertainty in unc being returned.
        #     Use constant uncertainty equal to ~0.5 permil 13C and 1 permil 18O
        if self.debug:
            print("Isotope Correction for %12s: co2=%12.4f  d13C=%7.5f  d18O=%7.5f  626=%12.4f  636=%12.4f 628=%12.4f " % (
            serialnum, co2, d13c, d18o, co2_626_mr, co2_636_mr, co2_628_mr), file=sys.stderr)

        if self.species == "CO2":
            mr = co2_626_mr
            unc = co2_unc
        elif self.species == "CO2C13":
            mr = co2_636_mr
            unc = 0.002 # 0.002 ppm is ~ 0.5 permill (at 400 ppm total)
        elif self.species == "CO2O18":
            mr = co2_628_mr
            unc = 0.002 # 0.002 ppm is ~ 1 permill (at 400 ppm total)

        return mr, unc

    #--------------------------------------------------------------------------
    def _get_response_ratios(self):
        """ calculate the std/ref ratios for each cycle.
        Return a dict with the std tank id as key, list of (ratio, flag) tuples as the value,
        e.g.
         {'S3': [(0.93135061683032339, "..."), (0.93041929991095518, "..."), ...], ...}
        """

        # First step, process raw data, compute sample std/refgas ratios for each cycle
        if self.config.calc_method == "default":
            resp = self._compute_response_from_raw()
        elif self.config.calc_method == "inst_cal":
            resp = self._compute_response_inst_cal()
        else:
            resp = self.compute_response_from_raw_old_co_files()


        # Remove R1 standard if needed
        if self.config.skip_R1:
            if self.debug: print("Skipping standard R1")
            if "R1" in resp:
                del resp["R1"]

        # Ignore first cycle if needed
        if self.config.skip_first:
            if self.debug: print("Skipping first cycle")
            for key in sorted(resp.keys()):
                if resp[key]:
                    resp[key].pop(0)

        return resp


    #--------------------------------------------------------------------------
    def _get_averages(self):
        """
        For each of the std tanks, compute the average std/ref ratio.
        Add a point at 1, y if a 'normalized' value is wanted,
        and a point at 0,0 if a zero point is wanted.
        Store results in a dict with tank id as key,
        tuple of (mean, stddev, mixing ratio, m.r. stddev, n) as value
        where
            mean - mean of sample/std ratios
            stddev - standard devation of mean
            mixing ratio - assigned mixing ratio of std tank
            m.r. stddev - assigned value of uncertainty for std tank
            n - number of ratios used to compute the mean
        e.g.
           {'S9': (1.539889596328438, 0.00013212835353437519, 2864.0700000000002, 1.1899999999999999, 10),
        """

        avg = {}

        # Calculate the average std/ref ratio for each standard.
        # Save the average and the corresponding mixing ratio of the standard
        for key in sorted(self.respdata.keys()):

            # check serial number vs nulltanks, if in nulltanks then don't use
            sn, mr, unc = self.refgas[key]
            if sn.upper() in self.config.nulltanks:
                if self.debug: print("%3s %s is not used" % (key, sn), file=sys.stderr)
                continue

            # check each of the ratios, remove -999.99 values
            a = [val for val, flag in self.respdata[key] if flag[0:2] == ".."]

            if len(a) == 0:
                del self.respdata[key]
                continue

            (mean, stdv) = ccg_utils.meanstdv(a)
            (sn, mr, unc) = self.refgas[key]

            mrsd = self.relunc[self.species] if unc == 0 else unc

            if stdv == 0: stdv = mean * 0.0001
            if mrsd == 0: mrsd = 0.5
            avg[key] = (mean, stdv, mr, mrsd, len(self.respdata[key]))

        # If no valid ratios, return empty data
        if len(avg) == 0:
            return avg

        # add a point at the reference gas if requested
        # use std dev of the last standard for this one
        if self.config.usenormal:
            x = 1.0
            key = sorted(avg.keys())[-1]
            xsd = avg[key][1]  #  0.000465
            (sn, mr, unc) = self.refgas[self.refid]
            if (mr - 1) > -999:  # don't use a point at the reference if not listed in DB table
                mrsd = self.relunc[self.species] # *mr
                avg[self.refid] = (x, xsd, mr, mrsd, 1)
            else:
                # don't use a point at the reference if not listed in DB table
                if self.debug: print("Value for reference tank %s not found.  Not included in fit." % (self.refid))


        # add a zero point if requested
        if self.config.usezero:
            if self.species == "CO" and self.method == "VURF":
                avg["Z"] = (0, 0.001, 0, 0.03, 1)
            else:
                avg["Z"] = (0, 0.005, 0, 0.5, 1)

        # need at least 3 std/sample ratios to compute a curve
        if len(avg) < 3:
            if self.debug: print("Not enough samples.  Need at least 3, got %d." % len(avg))

        return avg

    #--------------------------------------------------------------------------
    def _compute_nl(self):
        """
        Compute fit to (std mixing ratios) vs (std/ref ratios)
        Return a list of namedtuples
            ('analyzer_id', 'date', 'coeffs', 'rsd', 'n', 'functype', 'ref_op', 'rawfile')
        where
            analyzer_id - instrument id
            date - date of calibration
            coeffs - list of coefficients from fit
            rsd - residual standard deviation
            n - number of data points used in the fit
            functype - type of function used in fit
            ref_op - reference operator, i.e. subtract or divide
            rawfile - name of raw file for this calibration

        """

        x, y, xsd, ysd = self._make_fit_data()

        if len(x) == 0 or len(y) == 0:
            print("No data for", self.rawfile, file=sys.stderr)
            self.valid = False
            return [], []

        # get odr data, function, prelim coefficients
        mydata, func, beta0 = self._setup_odr(x, y, xsd, ysd)

        # set up odr fit, give it plenty of iterations and an initial estimate of the coefficients
        myodr = odr.ODR(mydata, func, beta0=beta0, maxit=1000)

        # Set type of fit to least-squares (2) or odrfit (0):
        if self.config.odrfit:
            if self.debug: print("Using odrfit to data", file=sys.stderr)
            myodr.set_job(0)
        else:
            if self.debug: print("Using least squares fit to data", file=sys.stderr)
            myodr.set_job(2)

        if self.debug:
            myodr.set_iprint(init=2, iter=2, final=2)  # causes an error with centos 7
            print("x is ", x, file=sys.stderr)
            print("y is ", y, file=sys.stderr)
            print("xsd is ", xsd, file=sys.stderr)
            print("ysd is ", ysd, file=sys.stderr)

        fit = myodr.run()

        # Results and errors
        coeff = list(fit.beta)
        dof = len(coeff)
        if len(coeff) < 3: coeff.append(0)    # need at least 3 coefficients
        if len(coeff) < 4: coeff.append(0)    # need at least 4 coefficients
        xr, residuals = self._get_residuals(coeff)

        rmean = numpy.mean(residuals)
        rsd = numpy.std(residuals, ddof=1)

        if self.debug:
            print("odr output:")
            print("   beta:", coeff)
            print("   beta std error:", fit.sd_beta)
            print("   residual mean:", rmean)
            print("   residual standard deviation:", rsd)
            print("   covar:", fit.cov_beta)


        # Last step, store results in tuple. Save entry for each start date set in the raw file
        results = []
        unc = []
        stdset = ''
        if 'Standard set' in self.raw.info:
            stdset = self.raw.info['Standard set']

        if self.config.calc_method == "inst_cal":
            sn = ""
        else:
            (sn, mr, sd) = self.refgas[self.refid]

        # for co2c13, we used co2 scale for computations, but we
        # want to save the co2c13 scale for results
        if self.species == 'CO2C13':
            scalenum = self.c13scalenum
            scalename = self.c13scale
        elif self.species == 'CO2O18':
            scalenum = self.o18scalenum
            scalename = self.o18scale
        else:
            scalenum = self.scalenum
            scalename = self.scale

        sdtid = 1
        for date in self.startdate:
            t = {
                'site': self.site,
                'parameter_num': self.gasnum,
                'scale_num': scalenum,
                'scale_name': scalename,
                'system': self.system,
                'inst_id': self.analyzer_id,
                'start_date': date,
                'start_date_id': sdtid,
                'analysis_date': self.adate,
                'degree': self.config.order,
                'coef0': coeff[0],
                'coef1': coeff[1],
                'coef2': coeff[2],
                'coef3': coeff[3],
                'coeffs': coeff,
                'rsd': rsd,
                'n': len(self.avg),
                'flag': '.',
                'function': self.config.functype,
                'ref_op': self.config.ref_op,
                'ref_sernum': sn,
                'standard_set': stdset,
                'filename': self.rawfile,
                'covar': fit.cov_beta
            }
            #print(t)
            results.append(t)
            sdtid += 1

            corr_matrix = self.calculate_beta_corr(fit.cov_beta)
            if self.debug:
                print("   corr_matrix:", corr_matrix)
            unc.append((fit.sd_beta, fit.cov_beta, corr_matrix))

        return results, unc

    #--------------------------------------------------------------------------
    def _make_fit_data(self):
        """ create the x, y and uncertainty data xsd, ysd for
        to be used in the odr fit.
        """

        # Compute odr fit of ratios, m.r.
        # We need to create 4 separate lists for input to odr.realdata
        x = []
        y = []
        xsd = []
        ysd = []

        if self.debug:
            if self.config.use_x_weights is False:
                print("no x weighting", file=sys.stderr)
            if self.config.use_y_weights is False:
                if self.debug: print("no y weighting", file=sys.stderr)

        for key, (xp, xpsd, yp, ypsd, n) in self.avg.items():
            if self.debug:
                print("xp, xpsd, yp, ypsd, n:", xp, xpsd, yp, ypsd, n, file=sys.stderr)
            x.append(xp)
            y.append(yp)
            xsd.append(xpsd)
            ysd.append(ypsd)

        if self.config.use_x_weights is False: xsd = None
        if self.config.use_y_weights is False: ysd = None

        return x, y, xsd, ysd

    #--------------------------------------------------------------------------
    def _setup_odr(self, x, y, xsd, ysd):
        """ Given the input data x, y, xsd, ysd, figure out the odr
        function, model to use, get preliminary coefficients with a polynomial fit,
        the set up the odr data for calling the odr fit.
        """

        if self.debug:
            print("Use function ", self.config.functype, "for odr.", file=sys.stderr)

        # set desired function model
        # estimate polynomial coefficients by doing a numpy polyfit first, then pass these to odr
        if self.config.functype == "poly":
            func = models.polynomial(self.config.order)
            beta0 = numpy.polyfit(x, y, self.config.order)
            beta0 = beta0[::-1]    # reverse the order of coefficients for input into odr
        elif self.config.functype == "power":
            func = odr.Model(powfunc)
            b = numpy.polyfit(x, y, 1)  # use linear fit to estimate first two coefficients
            beta0 = [b[1], b[0], 1.]
        elif self.config.functype == "exp":
            func = odr.Model(expfunc)
            beta0 = [1., 1., 1.]
        else:
            raise ValueError("Unknown function type %s.  Must be one of 'poly', 'power', 'exp'" % self.config.functype)

        if self.debug:
            print("Estimated", self.config.functype, "coefficients:", beta0, file=sys.stderr)

        # in odr.RealData, actual weighting internally is 1/sd^2
        mydata = odr.RealData(x, y, xsd, ysd)

        return mydata, func, beta0

    #--------------------------------------------------------------------------
    def _calc_func(self, x, coeff):
        """ Calculate the value of the function at point x
        using coefficients 'coeff'.
        """

        if self.config.functype == "poly":
            y = ccg_utils.poly(x, coeff)
        elif self.config.functype == "power":
            y = powfunc(coeff, x)
    #        y = coeff[0] + coeff[1]*numpy.power(x, coeff[2])
        elif self.config.functype == "exp":
            y = expfunc(coeff, x)

        return y

    #--------------------------------------------------------------------------
    def _calc_unc(self, x, resp):

        fit_degree = resp['degree']
        covar = resp['covar']

        # partial derivatives of polynomial with respect to the coefficients
        # Equation 7.50, 'Applied Linear Regression Models', Neter, Wasserman and Kutner, 1983
        # Then use equation 7.55a, rsd^2  + s2(yh)
        a = numpy.array([x**i for i in range(fit_degree+1)])
#        print(a.shape, a.T.shape)

        # variance of estimated y value
        z1 = numpy.dot(a.T, covar)
        var = numpy.dot(z1, a)

        # add residual variance
        var = var + resp['rsd']*resp['rsd']

#        meas_unc = math.sqrt(var)
        meas_unc = numpy.sqrt(var)

        return meas_unc

    #--------------------------------------------------------------------------
    def _compute_response_from_raw(self):
        """
        Calculate the sample/std ratio for each of the sample tanks versus reference tank.
        Return a dict with the tank id as key, list of ratios as the value,
        e.g.
         {'S3': [0.93135061683032339, 0.93041929991095518, ...], 'S2': [0.85348281405829773, ...] ...}
        """

        if self.method == "VURF":
            # The first standard tank is on the second line
            oneback = False
        else:
            # The first standard tank is on the first line
            oneback = True

        resp = defaultdict(list)
        for i in range(self.raw.numrows):
            row = self.raw.dataRow(i)

            # remove instrument zero tanks (on the VURF) and any "NUL" tanks
            if row.event == "Z" or row.smptype == "NUL": continue

            # if we are on the std, then compute ratios with bracketing refs.
            if row.smptype == "STD":
                std = row.event

                # skip flagged values
                if row.flag != ".":
                    resp[std].append((-999.99, "*.."))
                    continue

                if self.method == "GC":
                    val = row.ph if self.peaktype == "height" else row.pa
                    # skip values with bad baseline code
                    if row.bc not in self.bcodes:
                        resp[std].append((-999.99, "*.."))
                        continue
                else:
                    val = row.value

                if self.method == "VURF":
                    (val, val_unc, fg) = self.raw.zeroCorrectSignal(i) # returns zero corrected signal

                # check that we have valid baseline codes and flags for prev and next refs
                val1, unc1, r1, idx1 = self._check_std(i, self.refid, prev=True, oneback=oneback)
                val2, unc2, r2, idx2 = self._check_std(i, self.refid, prev=False, oneback=oneback)

                if self.debug:
                    print("Prev ref, Next ref, Prev valid, Next valid = ", val1, val2, r1, r2)

                (avgref, flg, comment) = self.getAvgValue(val1, val2, r1, r2)

                if self.debug:
                    print("std val, avgref", val, avgref)

                if avgref:
                    if self.config.ref_op == "none":
                        resp[std].append((val, flg))
                    elif self.config.ref_op == "subtract":
                        resp[std].append((val - avgref, flg))
                    elif self.config.ref_op == "divide":
                        resp[std].append((val/avgref, flg))
                    else:  # raise error instead?
                        print("WARNING: reference operation %s not recognized" % self.config.ref_op, file=sys.stderr)

#        print(resp)

        return resp


    #--------------------------------------------------------------------------
    def compute_response_from_raw_old_co_files(self):
        """ compute response curve from given raw file non-linearity calibration data.
        For older CO raw files on R2 and R7
        """

        resp = defaultdict(list)
        for std in self.raw.stds:

            (sn, mr, sd) = self.refgas[std]
            if mr <= 0: continue    # don't use zero points for rga

            for i in range(self.raw.numrows):
                row = self.raw.dataRow(i)
                if self.method == "GC":
                    val = row.ph
                    if self.peaktype == "area": val = row.pa
                else:
                    val = row.value

                if row.event == std:

                    if row.flag != ".":
                        resp[std].append((-999.99, "*.."))
                        continue

                    val1, unc1, r1, idx1 = self._check_std(i, self.refid, prev=True)
                    val2, unc2, r2, idx2 = self._check_std(i, self.refid, prev=False)

                    (avgval, flg, comment) = self.getAvgValue(val1, val2, r1, r2)

                    if avgval:
                        resp[std].append((val/avgval, flg))

        return resp

    #--------------------------------------------------------------------------
    def _compute_response_inst_cal(self):
        """ compute response curve from an 'instrument_cal', which is done
        for the aircraft picarros
        An instrument cal does not use a reference, but a sequence of standards only
        """

        resp = defaultdict(list)

        for std in self.raw.stds:

            (sn, mr, sd) = self.refgas[std]
            for i in range(self.raw.numrows):
                row = self.raw.dataRow(i)
                if row.event == std and row.flag == ".":
                    resp[std].append((row.value, "..."))

        return resp

    #--------------------------------------------------------------------------
    def checkDb(self):
        """ Check if result string is in response file, and show existing and new strings. """

        # Don't do anything if we don't have results.
        if not self.results:
            return

        self.resp.checkDb(self.results)

#        for result in self.results:
#            self.resp.checkDb(result)

    #--------------------------------------------------------------------------
    def updateDb(self):
        """ Update the response curve file with calculated results """

        # Don't do anything if we don't have results.
        if not self.results:
            return

        self.resp.updateDb(self.results)

#        for result in self.results:
#            print(result)
#            self.resp.updateDb(result)

    #--------------------------------------------------------------------------
    def deleteDb(self):
        """ Update the response curve file with calculated results """

        # Don't do anything if we don't have results.
        if not self.results:
            return

        for result in self.results:
            self.resp.deleteDb(result)

    #--------------------------------------------------------------------------
    @staticmethod
    def print_beta_sd(a):
        """ print beta unc values """

        np = a.size
        for i in range(np):
            print("%.5f " % a[i], end=' ')

        print()

    #--------------------------------------------------------------------------
    @staticmethod
    def calculate_beta_corr(a):
        """ calculate correlation values from odr fit """

        dia = numpy.diag(a)
        var = numpy.sqrt(dia)

        sp = a.shape
        corr = numpy.empty(sp)

        for i in range(int(sp[0])):
            for j in range(int(sp[1])):
                corr[i, j] = (a[i, j] / (var[i]*var[j]))

        return corr

    #--------------------------------------------------------------------------
    @staticmethod
    def print_beta_corr(a):
        """ print correlation values from odr fit """

        ndigits = int(numpy.max(numpy.log10(abs(a)))) + 2  # number of digits and a minus sign for largest number
        nd = ndigits + 5    # total number of characters including . and 4 digits
        frmt = "%%%d.4f" % (nd)

        sp = a.shape
    #    print "correlation matrix:"
        for i in range(sp[0]):
            for j in range(sp[1]):
                print(frmt % a[i, j], end=' ')

            print()

    #--------------------------------------------------------------------------
    @staticmethod
    def print_beta_cov(a):
        """ print covariance values from odr fit """

        ndigits = int(numpy.max(numpy.log10(abs(a)))) + 2  # number of digits and a minus sign for largest number
        nd = ndigits + 5    # total number of characters including . and 4 digits
        frmt = "%%%d.4f" % (nd)

        sp = a.shape
        for i in range(sp[0]):
            for j in range(sp[1]):
                print(frmt % a[i, j], end=' ')

            print()

    #--------------------------------------------------------------------------
    def printUnc(self):
        """ Print the uncertainty values of the curve """

        for n in range(len(self.results)):
            self.print_beta_sd(self.unc[n][0])

    #--------------------------------------------------------------------------
    def printCorrelation(self):
        """ Print the correlation values of the curve """

        for n in range(len(self.results)):
            self.print_beta_corr(self.unc[n][2])

    #--------------------------------------------------------------------------
    def printResults(self, show_extra=False, verbose=False):
        """ Print the single line results """

        if verbose:
            for t in self.results:
                for key in t:
                    if key == 'covar':
                        # convert covariance matrix to string
                        a = t['covar'].flatten()
                        b = [str(x) for x in a.tolist()]
                        s = " ".join(b)
                        print("%20s: " % key, s)

                    else:
                        print("%20s: " % key, t[key])
                print()

        else:
            n = 0
            for t in self.results:
                print(ccg_response.getResponseResultString(t))
                if show_extra:
                    self.print_beta_sd(self.unc[n][0])
                    self.print_beta_cov(self.unc[n][1])
                n = n + 1

    #--------------------------------------------------------------------------
    def printTable(self):
        """ Print a table of results for the response curve calibration """

        print("%50s\n" % ("Non-linearity Response Curve"))
        print("Analysis Date:       %s" % (self.adate.strftime("%Y %m %d %H")))
        print("Analyzer:            %s %s" % (self.analyzer_id, self.system))
        if self.config.calc_method == "inst_cal":
            sn = "None"
            mr = ""
        else:
            (sn, mr, sd) = self.refgas[self.refid]
        print("Reference:           %s %s %s" % (self.refid, sn, mr))
        print()
    #       print "Using peak", self.peaktype
        print()
        if "subtract" in self.config.ref_op.lower():
            print(" Ref. Gases    Cycle    Difference  Flag")
        else:
            print(" Ref. Gases    Cycle        Ratio   Flag")
        print("----------------------------------------")


#        for key in natsorted(self.respdata.keys()):
#            a = self.respdata[key]
        for key, a in self.respdata.items():
            if a:
                nv = 0
                (sn, mr, sd) = self.refgas[key]
                print("%4s: %s = %.3f" % (key, sn, mr))
                for n, (val, flg) in enumerate(a):
                    print("%4s -> %s %7d %15.6f %5s" % (key, self.refid, n+1, val, flg))
                    if val > -999: nv += 1
                print("N         %24d" % nv)
                if key in self.avg:
                    print("Mean      %24.6f" % self.avg[key][0])
                    print("Std.Dev.  %24.6f" % self.avg[key][1])
                else:
                    print("Mean      %24.6f" % -999.99)
                    print("Std.Dev.  %24.6f" % -99.99)
                print()

    #--------------------------------------------------------------------------
    def printInput(self, verbose=False):
        """ Print the input values that went into the odr fit """

        tlist = []
        for key in list(self.avg.keys()):
            (xp, xpsd, yp, ypsd, n) = self.avg[key]
            t = (xp, xpsd, yp, ypsd, n, key)
            tlist.append(t)

        # sort by ratio
        for (xp, xpsd, yp, ypsd, n, label) in sorted(tlist):
            if verbose:
                sn, mr, unc = self.refgas[label]
                print("%f %f %10.3f %f %4s %10s %.2f" % (xp, xpsd, yp, ypsd, label, sn, mr))
            else:
                print("%f %f %10.3f %f" % (xp, xpsd, yp, ypsd))


    #--------------------------------------------------------------------------
    def printRatios(self, xmin, xmax):
        """ Print out the value of the response curve at specified x values. """

#        x, y, z = self.get_values(xmin, xmax)

#        for xp, mr, unc in zip(x, y, z):
#            print("%6.3f %6.3f %.3f" % (xp, mr, unc))

        x, y = self.get_values(xmin, xmax)

#        for xp, mr in zip(x, y, z):
        for xp, mr in zip(x, y):
            print("%6.3f %6.3f" % (xp, mr))

    #--------------------------------------------------------------------------
    def get_values(self, xmin, xmax):
        """ Get the mole fraction values for ratios between xmin, xmax """

        # only need the first result.  Any additional results change only with start date

        # split the range into 100 steps
        step = (xmax - xmin) / 100.0

        x = []
        y = []
#        z = []
        xp = xmin
        while xp < xmax+step:
            mr = self._calc_func(xp, self.results[0]['coeffs'])
#            unc = self._calc_unc(xp, self.results[0])
            x.append(xp)
            y.append(mr)
#            z.append(unc)
            xp += step

        return x, y

    #--------------------------------------------------------------------------
    def printResiduals(self, verbose=False):
        """ Print out residuals of the sample/std averages from the response curve. """

        tlist = [(xp, yp, key) for key, (xp, xpsd, yp, ypsd, n) in self.avg.items()]

        # sort by ratio
        for (xp, yp, label) in sorted(tlist):
            resid = yp - self._calc_func(xp, self.results[0]['coeffs'])

            if verbose:
                sn, mr, unc = self.refgas[label]
                print("%.8f %12.8f %4s %10s %.2f" % (xp, resid, label, sn, mr))
            else:
                print("%.8f %12.8f" % (xp, resid))


    #--------------------------------------------------------------------------
    def getResiduals(self):
        """ Return two lists of residual data,
            x - values of std/ref ratios,
            y - residual from response curve.
        """

        x, y = self._get_residuals(self.results[0]['coeffs'])

        return x, y

    #--------------------------------------------------------------------------
    def _get_residuals(self, coeffs):
        """ return list of residual values from the curve """

        x = []
        y = []
        for key, (xp, xpsd, yp, ypsd, n) in self.avg.items():
            ycurve = self._calc_func(xp, coeffs)
            resid = yp - ycurve
            x.append(xp)
            y.append(resid)
            if self.debug:
                print("residual at", xp, "input =", yp, "value = ", ycurve, "residual = ", resid)

        return x, y


    #--------------------------------------------------------------------------
    def printConfig(self):
        """ Print out configuration values used in calculations """

        self.config.printConfig()
