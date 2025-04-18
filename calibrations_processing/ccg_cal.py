
# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class to hold data needed for calibration processing.
Includes working tank info, response curves, system ids etc.
"""
from __future__ import print_function

import sys
import math
from collections import namedtuple, defaultdict
#from numpy import polyfit, polyval, average
import numpy
from scipy.optimize import curve_fit

import ccg_process
import ccg_cal_db
import ccg_utils

DEFAULTVAL = -999.99

FLAGS = ccg_process.FLAGS



###########################################################
def poly2(x, a, b=0, c=0):
    """ quadratic polynomial """
    return a + b*x + c*x*x


##################################################################
class Cal(ccg_process.processData):
    """ Class for ancillary calibration data needed for processing of raw files.
    All data comes from the calibration raw files, passed in by the 'info' and 'raw' lists.

    Members:
    cal.species  - Upper case designation of gas, e.g. 'CO2', 'CH4' etc.
    cal.lcspecies - Lower case designation of gas, e.g. 'co2', 'ch4' etc.
    cal.site - Three letter code where calibration was done (usually BLD)
    cal.method - Method of analysis, e.g. NDIR, VURF, GC, ...
    cal.system - System name from raw file (only for co2 cals and ch4 cals so far)...
    cal.analyzer_id - Analyser id code
    cal.analyzer_sn - Analyser serial number
    cal.adate - datetime object with date and time of analysis
    cal.resp - Tuple with date and coefficients of response curve for the analysis date.
             Empty if not available.  The response data used can be overridden by
             passing in database=dbname in creation
    cal.useResponseCurves - Boolean if response curves are to be used for computation of mixing ratios
    cal.workgas - Dict of working gas information
        Has the tank id as the keys,  tuple of (serial number, pressure, regulator) for the values
    cal.nwork - Number of working tanks used.  Equal to length of cal.workgas
    cal.refgas - Dict of reference gas information
        Has the tank id as the keys,  tuple of (serial number, mixing ratio) as value for the given adate
        e.g. refgas["L"] = (CC71111, 385.66)
        You can get a list of tank id's with cal.refgas.keys()
    cal.nstds - Number of reference gas standards used.  Equal to length of cal.refgas
    cal.peaktype - Type of peak to use for computation of mixing ratios. Should be either 'area' or 'height'.
        '' if not used.  Can be overridden by passing in peaktype=parameter in creation.
    cal.scale - Name of calibration scale being used
    cal.moddate -


    Methods:
    printResults() - Print a one line result string for the cal for each sample tank.
    printTable()   - Print more information about the cal, such as tanks used, individual aliquot results, mean, std. dev
    checkDb()      - Check calculated results with data in database
    updateDb()     - Update the database with results of calibration
    deleteDb()     - Delete results from database

    Creation:
    caldata = cal.cal(raw, database, peaktype, noresponse_curve, scale, moddate, skip_first, debug)
        rawfile          - raw file name to process
        database         - use different database for tank assignments, response curves, etc.
        peaktype         - if you want to use a different peak type from the default
        noresponse_curve - True if you want to force mixing ratio calculations to ignore response curve
        scale            - use scale other than default current scale
        moddate          - use modification date when pulling values for standards
        skip_first       - skip first aliquot
        debug            - print debugging information if True


        rawfile is required, all others are optional.
    """


    def __init__(self, rawfile,
                 database=None,
                 peaktype=None,
                 noresponse_curve=False,
                 scale=None,
                 moddate=None,
                 skip_first=None,
                 debug=False):

        super(Cal, self).__init__("cals", rawfile,
            database=database,
            peaktype=peaktype,
            noresponse_curve=noresponse_curve,
            scale=scale,
            moddate=moddate,
            debug=debug)

        if not self.valid: return

        # set skip_first
        # drop first H2 shot for tankcals on H9, H8, and H11
        if skip_first is None:
            if self.species == "H2" and self.analyzer_id in ("H9",):
                self.skip_first = True
            else:
                self.skip_first = False
        else:
            self.skip_first = skip_first

        ########### --- Note: in ccg_process.py we hardcode to not use hydrogen response curves for several periods on cocal-1, inst H9
        ##########      when there isn't a valid response curve to use. First H9 response curve started on 2019-04-29.
        ## 2019-06-20 -  2019-09-12 - no primary response curve available, use single point calibration vs CC49559
        ## 2019-12-17 - 2020-02-03 - no primary response curve available, use single point calibration vs CC49559
        ## 2020-07-21 - 2020-09-21 - no primary response curve available, use single point calibration vs CC49559
        ## 2021-05-03 - 2021-10-11 - no primary response curve available, use single point calibration vs CC49559
        ####################################

        # Get working (sample) gas information
        # Returns a dict with sample gas id as key, tuple of (serial number, pressure, regulator) as value
        self.workgas = self._getWorkgas()
#        print(self.workgas)

        # initialize mr dict.  This will contain mixing ratios and flags for each sample tank for each aliquot
        self.mr = defaultdict(list)
        self.ratio = defaultdict(list)

        # create a namedtuple for use with updateDB(), checkDb(), deleteDB()
#        self.Row = namedtuple('CalResult',
#            ['adate', 'mf', 'sd', 'ncycles', 'method', 'pressure', 'site', 'regulator', 'inst', 'system', 'flag', 'meas_unc'])
        self.Row = namedtuple('CalResult',
            ['paramnum', 'adate', 'mf', 'sd', 'ncycles', 'method', 'pressure', 'site', 'regulator', 'inst', 'system', 'flag', 'meas_unc', 'scale_num'])

        self.results = self._compute_mr()
#        print(self.results)

    #----------------------------------------------------------------------
    def _getWorkgas(self):
        """
        Determine number of sample tanks that were calibrated,
        Create a dict that has the serial number, regulator and pressure info
        for each working tank, store by tank names.
        """

        # Get work tank id's from raw and info lists,
        # save serial number, pressure regulator one time for each sample tank
        workgas = {}

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            name = row.event
            if name not in workgas:

                # get pressure of tank from info
                pressure = 0
                p = "%s Pressure" % name
                if p in self.raw.info:
                    # convert pressure to integer
                    try:
                        pressure = int(self.raw.info[p])
                    except ValueError:
                        pressure = 0

                # get regulator from info
                regulator = ""
                r = "%s Regulator" % name
                if r in self.raw.info:
                    regulator = self.raw.info[r]

                # get serial number from info
                sernum = self.raw.info[name]

                # save it
                workgas[name] = (sernum, pressure, regulator)

        self.nwork = len(workgas)

        return workgas

    #----------------------------------------------------------------------
    def _compute_mr(self):
        """
        Decide how to compute the mixing ratios of the samples based on
        instrument method and ID
        """

        if self.method == "NDIR":
            if self.system == "co2cal-1" or self.site in ["BRW", "MLO", "SMO", "SPO"]:
                results = self._compute_mr_co2_2()
            else:
                results = self._compute_mr_co2_1()

        elif self.method == "VURF":
            results = self._compute_mr_vurf()

        elif self.method in ["offaxis-ICOS", "CRDS", "QC-TILDAS", "Laser_Spectroscopy"]:
            results = self._compute_mr_icos()

        elif self.method == "GC":
            if (self.analyzer_id == "R2" and self.species == "CO") or \
               (self.analyzer_id == "R7" and self.species == "CO" and self.idate < 2001090700):
                results = self._compute_mr_gc(refid="R0")
            else:
                results = self._compute_mr_gc()

        elif self.method == "TOWERCAL":
            results = self._compute_tower_cal()

        else:
            print("Unknown method for computing mixing ratio:", self.method, file=sys.stderr)
            sys.exit()

        return results

    #----------------------------------------------------------------------
    def _get_results(self, mr):
        """
        # Each of the compute_mr routines should create a list of value, flag tuples
        # for each sample taken for each working tank.
        # This routine calculates the average and standard deviation from this list.
        # Example mr format:
        # {'W': [(120.08033024883741, '.'), (120.04444826514644, '.'), (120.05941146027376, '.')]}
        """

        results = {}
        for key in list(mr.keys()):

            if self.skip_first:
                (val, flag, unc) = mr[key][0]
                if flag[0] == ".":
                    t = (val, "-..", unc)
                    mr[key][0] = t

            # Get all unflagged values
            means = [val for val, flag, unc in mr[key] if flag[0] == "."]
            stds = [unc for val, flag, unc in mr[key] if flag[0] == "."]
            ns = [1 for val, flag, unc in mr[key] if flag[0] == "."]
            if self.debug:
                print('means', means)
                print('std', stds)
                print('ns', ns)

            # get mean and standard deviation
            if means:
                avg, sd = ccg_utils.meanstdv(means)
                unc = ccg_utils.combined_stdv(means, stds, ns)
                if self.debug:
                    print('avg, sd, unc', avg, sd, unc)
                flag = "."
            else:
                avg = DEFAULTVAL
                sd = -99.99
                unc = -9.999
                flag = "*"

            n = len(means)
#            print("###--- unc is ", unc)

#            avg = round(avg, 3)

            results[key] = (avg, sd, n, flag, unc)

        return results

    #----------------------------------------------------------------------
    def _compute_mr_co2_1(self):
        """
        # Calculate mixing ratios for single sample bracketed by standards,
        # e.g.  L - SMP - M - SMP - H - SMP - L ...
        # Calculate using the following reference and the two previous references
        # for each sample.
        """

        # assigned values of reference tanks
        y = []
        ysd = []
        labels = sorted(self.refgas)  # sort the tank labels (keys of refgas)
        for label in labels:
            t = self.refgas[label]
            y.append(t[1])    # assigned value
            ysd.append(t[2])  # uncertainty of assigned value

        v = {}
        vsd = {}

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)

            if row.flag != ".":
                if self.debug: print("bad flag %s" % (row.flag))
                value = DEFAULTVAL
                unc = -9.999
            else:

                # find 2 previous refs and next ref
                linenum1 = self.raw.findPrevRef(i)
                linenum2 = self.raw.findPrevRef(linenum1-1)
                linenum3 = self.raw.findNextRef(i)

                row1 = self.raw.dataRow(linenum1)
                row2 = self.raw.dataRow(linenum2)
                row3 = self.raw.dataRow(linenum3)

                # get voltage value for each ref
                v[row1.event] = row1.value
                v[row2.event] = row2.value
                v[row3.event] = row3.value

                vsd[row1.event] = row1.std
                vsd[row2.event] = row2.std
                vsd[row3.event] = row3.std

                x = [v[key] for key in labels]
                xsd = [vsd[key] for key in labels]

                fit, rsd = ccg_utils.odr_fit(2, x, y, xsd, ysd, self.debug)
                value, unc = ccg_utils.odr_fit_val(2, row.value, fit, rsd)

            self.mr[row.event].append((value, row.flag, unc))

        results = self._get_results(self.mr)

        return results

    #----------------------------------------------------------------------
    def _compute_mr_co2_2(self):
        """
        Calculate mixing ratios for co2 calibration system.
        Measurement cycle is something like
        L - W1 - M - W2 - H - Q - W3 - W4 - W4 - W3 - Q - H - W2 - M - W1 - L

        Note: The standard deviations of each measured voltage were not recorded,
        so we don't have any x axis errors for use with an odr fit.
        """

        results = {}

        worklist = sorted(self.workgas.keys())

        # if we are missing a reference gas assigned value, then return default value
#        for (sn, co2, unc) in self.refgas.values():
#            if co2 < 0:
#                for name in worklist:
#                    results[name] = (-999.99, -99.99, 0, "*")
#
#                return results

        # Now compute the mixing ratio for each working tank for each cycle
        nv = (self.nstds + self.nwork)*2      # Number of voltages for each gas in a cycle

        # initialize values
        n = 0
        v = defaultdict(int)

        # Store assigned mixing ratios of reference tanks in list
        y = [t[1] for key, t in self.refgas.items()]
        ysd = [t[2] for key, t in self.refgas.items()]

        # Loop through the raw lines, calculate mixing ratios for each
        # working tank after each cycle
        for i in range(self.raw.numrows):
            row = self.raw.dataRow(i)

            v[row.event] += row.value
            n += 1

            # if n = nv, then we've come to the last voltage for the cycle,
            # calculate mixing ratios
            if n == nv:

                if self.debug: print("end of cycle")

                # get average voltage for each standard
                x = [v[g]/2.0 for g in list(self.refgas.keys())]

                # compute response curve, mixing ratio as function of voltage
                coeffs = numpy.polyfit(x, y, deg=2)
                beta0 = coeffs[::-1] # reverse the order of coefficients for input into curve_fit
                popt, pcov = curve_fit(poly2, x, y, p0=beta0, sigma=ysd, absolute_sigma=True)

                resid = numpy.polyval(popt[::-1], x) - numpy.array(y)
                rsd = numpy.std(resid, ddof=2)

                if self.debug:
                    print("x,y values: ", x, y)
                    print("coeffs", coeffs)

                # get average voltage for each working tank, calculate mixing ratio
                for name in worklist:
                    volt = v[name]/2.0
                    value = numpy.polyval(popt[::-1], volt)

                    # partial derivatives of polynomial with respect to the coefficients
                    a = numpy.array([volt**i for i in range(2+1)])

                    # variance of estimated y value
                    z1 = numpy.dot(a.T, pcov)
                    var = numpy.dot(z1, a)
                    var = var + rsd*rsd
                    meas_unc = math.sqrt(var)

                    self.mr[name].append((value, ".", meas_unc))
                    if self.debug: print(name, volt, value, meas_unc)

                # re-initialize
                v = defaultdict(int)
                n = 0


        # calculate the average mixing ratio and standard deviation for each working gas
        # Flag the first cycle, keep only 5 cycles if more than that were done.
        for name in self.mr:

            self.mr[name][0] = (self.mr[name][0][0], "*", -9.999)   # flag first cycle
            values = [val for val, flg, unc in self.mr[name] if flg == "."]
            while len(values) > 5:
                co2 = numpy.average(values)
                r = 0
                maxdiff = 0

                for n, (value, flag) in enumerate(self.mr[name]):
                    if flag == ".":
                        diff = abs(value - co2)
                        if diff > maxdiff:
                            maxdiff = diff
                            r = n

                self.mr[name][r] = (self.mr[name][r][0], "*")  # flag cycle farthest away from mean
                values = [val for val, flg in self.mr[name] if flg == "."]

        results = self._get_results(self.mr)

        return results

    #----------------------------------------------------------------------
    def _compute_mr_gc(self, refid=None):
        """
        # Calculate mixing ratios for single sample bracketed by standard,
        # e.g.  S - SMP - S - SMP - S - SMP - S ...
        """

        if refid is None:
            refid = self.raw.refid

        bcodes = self.raw.info["Baseline Codes"].split()

        #For zero air calibrations get average of all std runs to use for
        # val1 and val2 below
        if self.zero_air_calibration:
            std, std_unc, std_r = self._get_zero_air_avg(bcodes)

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if self.debug: print("Working on ", row.smptype, row.event)

            if row.flag != "." or row.bc not in bcodes:
                if self.debug: print("bad flag %s or baseline code %s not in %s" % (row.flag, row.bc, bcodes))
                rr = DEFAULTVAL
                value = DEFAULTVAL
                unc_m = DEFAULTVAL
                flag = "*"
            else:
                #if zero air calibration use avg of all stds rather than bracketing
                if self.zero_air_calibration:
                    val1, r1 = std, std_r
                    val2, r2 = std, std_r
                else:
                    val1, unc1, r1, idx1 = self._check_std(i, refid, prev=True, bcodes=bcodes)
                    val2, unc2, r2, idx2 = self._check_std(i, refid, prev=False, bcodes=bcodes)

                if self.debug: print("   prev, next ref values:", r1, r2, val1, val2)

#                (avgstd, flag, comment) = self.getAvgValue(val1, val2, r1, r2)
                (avgref, uncref, flag, comment) = self._get_avg_value(val1, val2, unc1, unc2, r1, r2)

                val = row.ph if self.peaktype == "height" else row.pa
                value, flag, comment, unc, rr = self._get_mixing_ratio(val, avgref, flag, comment)
#                print("@@@ unc", unc)

                unc2 = self._get_meas_unc(val, 0, avgref, uncref)
                # get total measurement uncertainty
                unc_m = math.sqrt(unc*unc + unc2*unc2)

            # save mixing ratio for this aliquot
            self.mr[row.event].append((value, flag, unc_m))
            self.ratio[row.event].append((rr, flag))

        # find average mixing ratio for all aliquots
        results = self._get_results(self.mr)

        return results

    #--------------------------------------------------------------------------
    def _compute_mr_icos(self):
        """
        # Calculate mixing ratios for single sample bracketed by standard,
        # e.g.  REF - SMP - REF - SMP - REF - SMP - REF ...
        # Almost identical to compute_mr_gc except don't look at baseline codes.
        # For LGR and Picarro instruments
        """

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if self.debug: print("\nWorking on", row)
            if row.flag != "." or row.n <= 0:
                if self.debug: print("bad flag %s" % (row.flag))
                rr = DEFAULTVAL
                value = DEFAULTVAL
                flag = row.flag
                unc = DEFAULTVAL
                unc_m = DEFAULTVAL

            else:

                # check that we have valid values and flags for prev and next stds
                val1, unc1, r1, idx1 = self._check_std(i, self.raw.refid, prev=True, oneback=True)
                val2, unc2, r2, idx2 = self._check_std(i, self.raw.refid, prev=False, oneback=True)
                if self.debug: print("    prev, next ref values:", r1, r2, val1, val2)

                # determine standard deviation of the mean for the sample
                rowstd = row.std / math.sqrt(row.n)

                (avgref, uncref, flag, comment) = self._get_avg_value(val1, val2, unc1, unc2, r1, r2)
                if self.debug:
                    print("")
                    print("    ref mean", avgref)
                    print("    std.dev. of ref mean", uncref)
                    print("    sample mean", row.value)
                    print("    std dev of sample mean", rowstd)

                # value, unc is calculated value and uncertainty from response curve
                (value, flag, comment, unc, rr) = self._get_mixing_ratio(row.value, avgref, flag, comment)
                if self.debug:
                    print("")
                    print("    MF", value, flag, rr, unc)

                # unc2 is uncertainty due to measurement noise
                unc2 = self._get_meas_unc(row.value, rowstd, avgref, uncref)

                # get total measurement uncertainty
                unc_m = math.sqrt(unc*unc + unc2*unc2)

            self.mr[row.event].append((value, flag, unc_m))
            self.ratio[row.event].append((rr, flag))

        if self.debug:
            print("\nIndividual mr results ====")
            for key in self.mr:
                for row in self.mr[key]:
                    print("   ", key, row)
            print()

        results = self._get_results(self.mr)

        return results

    #----------------------------------------------------------------------
    def _compute_mr_vurf(self):
        """ Compute values for cals using vurf (co)
        The vurf uses a zero gas, which is used for correcting the signal.
        """

        std = list(self.refgas.keys())[0]
        if self.debug:
            print("refgas id is", std)

        #For zero air calibrations get average of all std runs to use for
        # std1 and std2 below.  Zero correct each
        if self.zero_air_calibration:
            std, std_unc, std_r = self._get_zero_air_avg()

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if row.flag != ".":
                if self.debug: print("bad flag %s" % (row.flag))
                rr = DEFAULTVAL
                value = DEFAULTVAL
                unc_m = DEFAULTVAL
                flag = "*"
            else:

                (smpl, smpl_unc, fg) = self.raw.zeroCorrectSignal(i) # returns zero corrected signal

                if self.zero_air_calibration:
                    std1, r1 = std, std_r
                    std2, r2 = std, std_r
                    std1_unc = std_unc
                    std2_unc = std_unc
                else:
                    # std1 is value, std1_unc is uncertainty of zero corrected value
                    std1, std1_unc, r1, idx1 = self._check_std(i, self.raw.refid, prev=True)
                    std2, std2_unc, r2, idx2 = self._check_std(i, self.raw.refid, prev=False)

                # get average and uncertainty of the prev and next references, only use valid (not DEFAULTVAL)
                (avgref, uncref, flag, comment) = self._get_avg_value(std1, std2, std1_unc, std2_unc, r1, r2)
                if self.debug:
                    print("")
                    print("    ref mean", avgref)
                    print("    std.dev. of ref mean", uncref)
                    print("    sample mean", smpl)
                    print("    std dev of sample mean", smpl_unc)

                # value, unc is calculated value and uncertainty from response curve
                (value, flag, comment, unc, rr) = self._get_mixing_ratio(smpl, avgref, flag, comment)

                # unc2 is uncertainty due to measurement noise
                unc2 = self._get_meas_unc(smpl, smpl_unc, avgref, uncref)
                if self.debug:
                    print("")
                    print("    MF", value, flag, rr, unc, unc2)

                # get total measurement uncertainty
                unc_m = math.sqrt(unc*unc + unc2*unc2)

            self.mr[row.event].append((value, flag, unc_m))
            self.ratio[row.event].append((rr, flag))

        results = self._get_results(self.mr)

        return results

    #----------------------------------------------------------------------
    def _get_zero_air_avg(self, bcodes=None):
        """ For zero air calibrations get average of all std runs to use """

        std_p = []
        for i in range(self.raw.numrows):
            row = self.raw.dataRow(i)
            if self.method == "GC":
                if row.smptype == "REF" and row.flag == "." and row.bc in bcodes:
                    val = row.ph if self.peaktype == "height" else row.pa
                    std_p.append(val)

            elif self.method == "VURF":
                if row.smptype == "REF" and row.flag == "." and row.event != "Z":
                    (corr_val, corr_unc, f) = self.raw.zeroCorrectSignal(i)
                    if corr_val > DEFAULTVAL:
                        std_p.append(corr_val)

        if std_p:
            std = numpy.average(std_p)
            std_unc = numpy.std(std_p, ddof=1)
            std_r = True
        else:
            std = DEFAULTVAL
            std_r = False

        if self.debug:
            print("zero air average is", std)

        return std, std_unc, std_r

    #----------------------------------------------------------------------
    def _compute_tower_cal(self):
        """ compute cals from towers.  These are special cases,
        with the raw files created by dedicated scripts.  Towers don't have
        routine tank calibrations.
        """

        y = [self.refgas[key][1] for key in sorted(self.refgas.keys())]

        print(self.raw.data)

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if self.debug: print("Working on ", row.smptype, row.event)
            if row.flag == ".":
                v = {}
                for std in list(self.refgas.keys()):
                    val = []
                    prev_std = self.raw.findPrevStd(i, std)
                    if prev_std >= 0:
                        val.append(self.raw.data[prev_std][3])

                    next_std = self.raw.findNextStd(i, std)
                    if next_std >= 0:
                        val.append(self.raw.data[next_std][3])

                    if val:
                        v[std] = numpy.average(val)


                x = [v[std] for std in sorted(self.refgas.keys())]

                if self.debug:
                    print("x", x)
                    print("y", y)

                if len(list(self.refgas.keys())) > 2:
                    coefs = numpy.polyfit(x, y, deg=2)
                else:
                    coefs = numpy.polyfit(x, y, deg=1)


                mr = numpy.polyval(coefs, row.value)
                unc = 0
                self.mr[row.event].append((mr, row.flag, unc))

                if self.debug:
                    print("coefs", coefs)
                    print("mf", mr)

        results = self._get_results(self.mr)


        return results

    #----------------------------------------------------------------------------------------------
    @staticmethod
    def _get_avg_value(std1, std2, unc1, unc2, r1, r2):
        """
        Check if previous/next standards are valid, determine std value to use
        and appropriate flag.
        4 possibilities
        1. preceeding aliquot is a good reference and following aliquot is a good reference
        2. preceeding aliquot is a good reference and following aliquot is not a good reference
        3. preceeding aliquot is not a good reference and following aliquot is a good reference
        4. preceeding aliquot is not a good reference and following aliquot is not a good reference

        Then calculate mole fraction for sample_val, using response curve
        """

        # case 1
        if r1 and r2:
            avgstd = (std1 + std2)/2.0
            tag, comment = FLAGS['ok']
            unc = math.sqrt(unc1*unc1 + unc2*unc2)

        # case 2
        elif r1:
            avgstd = std1
            tag, comment = FLAGS['firstref']
            unc = unc1

        # case 3
        elif r2:
            avgstd = std2
            tag, comment = FLAGS['secondref']
            unc = unc2

        # case 4
        else:
            avgstd = -999.99
            tag, comment = FLAGS['noref']
            unc = 0

        return avgstd, unc, tag, comment

    #----------------------------------------------------------------------------------------------
    def _get_meas_unc_xx(self, sample_val, sample_std, avgstd, avgunc):
        """ calculate measurement uncertainty """

        #========================================

        if self.useResponseCurves:
            resp = self.resp.last_response
        else:
            resp = {}
            resp['ref_op'] = 'divide'
            resp['coeffs'] = self._get_fake_coef()
#            print(resp, sample_val, sample_std, avgstd, avgunc)


        if resp['ref_op'] == 'subtract':
            x = sample_val - avgstd
        elif resp['ref_op'] == 'divide':
            x = sample_val / avgstd
        else:
            x = sample_val

        # propagation of error, sigma of difference or ratio
#        print("sample_std, avgunc, sample_val, avgstd", sample_std, avgunc, sample_val, avgstd)
        if resp['ref_op'] == 'subtract':
            sigma_x = math.sqrt(sample_std*sample_std + avgunc*avgunc)
        elif resp['ref_op'] == 'divide':
            if sample_val != 0:
                sigma_x = x * math.sqrt(sample_std**2/sample_val**2 + avgunc**2/avgstd**2)
            else:
                sigma_x = DEFAULTVAL
        else:
            sigma_x = sample_std

        if self.debug:
            print("\nget_meas_unc ====")
            print("    response operator", resp['ref_op'])
            print("    sigma_x", sigma_x)

        # convert sigma in analyzer units to mole fraction
        if resp['coeffs'] is not None:
            coeffs = list(resp['coeffs'])
            coeffs[0] = 0   # ignore intercept term
    #        print('coeffs', coeffs)
            zz = ccg_utils.poly(sigma_x, coeffs)
        else:
            zz = sigma_x # ???? not sure what the correct thing to do is

        if self.debug:
            print("    Unc of sample = ", zz)

#        print("sigma_x, zz", sigma_x, zz)

        return zz


    #----------------------------------------------------------------------
    def checkDb(self, database="reftank", verbose=False):
        """ For each working gas, check calculated results with data in database """

        for name, (sn, pressure, regulator) in sorted(self.workgas.items()):
            (mf, sd, ncycles, flag, unc) = self.results[name]
#            t = self.Row._make((self.adate, mf, sd, ncycles, self.method, pressure, self.site, regulator, self.analyzer_id, self.system, flag, unc))
            t = self.Row._make((self.gasnum, self.adate, mf, sd, ncycles, self.method, pressure, self.site, regulator, self.analyzer_id, self.system, flag, unc, self.scalenum))

            cals = ccg_cal_db.Calibrations(sn, self.species, date=self.adate.date(), database=database)
            cals.checkDb(t, verbose=verbose)

    #----------------------------------------------------------------------
    def updateDb(self, database="reftank", verbose=False):
        """ Update the database with results of calibration. """

        for name, (sn, pressure, regulator) in sorted(self.workgas.items()):
            (mf, sd, ncycles, flag, unc) = self.results[name]
#            t = self.Row._make((self.adate, mf, sd, ncycles, self.method, pressure, self.site, regulator, self.analyzer_id, self.system, flag, unc))
            t = self.Row._make((self.gasnum, self.adate, mf, sd, ncycles, self.method, pressure, self.site, regulator, self.analyzer_id, self.system, flag, unc, self.scalenum))

            cals = ccg_cal_db.Calibrations(tank=sn, gas=self.species, date=self.adate.date(), database=database, readonly=False)
            cals.updateDb(t, verbose=verbose)

    #----------------------------------------------------------------------
    def deleteDb(self, database="reftank", verbose=False):
        """ Delete the results from the database. """

        for name, (sn, pressure, regulator) in sorted(self.workgas.items()):
            (mf, sd, ncycles, flag, unc) = self.results[name]
#            t = self.Row._make((self.adate, mf, sd, ncycles, self.method, pressure, self.site, regulator, self.analyzer_id, self.system, flag, unc))
            t = self.Row._make((self.gasnum, self.adate, mf, sd, ncycles, self.method, pressure, self.site, regulator, self.analyzer_id, self.system, flag, unc, self.scalenum))

            cals = ccg_cal_db.Calibrations(sn, self.species, date=self.adate.date(), database=database)
            cals.deleteDb(t, verbose=verbose)

    #----------------------------------------------------------------------
    def printResults(self, use_db_flag=False, use_fill_code=False):
        """ Print a one line result string for the cal for each sample tank. """


        format1 = "%12s %s %9.3f %7.3f %7.3f %3d %s %4s %s %2s %s %s"
        for name, (sn, pressure, regulator) in list(self.workgas.items()):
            (mr, sd, ncycles, flag, unc) = self.results[name]

            if use_fill_code or use_db_flag:
                cf = ccg_cal_db.Calibrations(sn, self.species, date=self.adate.date())

            if use_db_flag:
                flag = cf.getFlag(self.adate.date())

            fillcode = cf.getFillCode(self.adate.date()) if use_fill_code else ""

            print(format1 % (sn, self.adate.strftime("%Y %m %d %H"),
                  mr, sd, unc, ncycles, flag, pressure, self.analyzer_id, self.system, regulator, fillcode))

    #----------------------------------------------------------------------
    def printTable(self):
        """
        Print more information about the cal, such as tanks used,
        individual aliquot results, mean, std. dev
        """

        worklist = sorted(self.workgas.keys())

        print("%50s\n" % (self.species + " Tank Calibration"))
        print("Analysis Date:       %s" % (self.adate.strftime("%Y-%m-%d %H:%M")))
        print("System:              %s" % (self.system))
        print("Analyzer:            %s\n" % (self.raw.info['Instrument']))

        for tank, (sernum, conc, unc) in list(self.refgas.items()):
            print("Reference Tank %s:   %s %.2f" % (tank, sernum, conc))

        if self.useResponseCurves:
            coef = self.resp.getCoeffs()
            adate = self.resp.getAdate()
            frmt = "Response Curve:      %s + %s * R +  %s * R^2 on %s"
            print(frmt % (coef[0], coef[1], coef[2], adate.strftime("%Y-%m-%d:%H")))

        print("\nSample Tanks")
        print("Tank  Serial Number    Pressure    Regulator")
        for name in worklist:
            (sn, pressure, regulator) = self.workgas[name]
            print("%3s %10s %13s %15s" % (name, sn, pressure, regulator))

        print()
        print("  Cycle    ", end=' ')
        for key in sorted(self.mr.keys()):
            print("%-10s %-10s" % (key, 'Unc'), end=' ')
        print()
        print("  --------" + "-"*21*len(list(self.mr.keys())))

        key = list(self.mr.keys())[0]
        ncycles = len(self.mr[key])
        for cycle in range(ncycles):
            print("%5d " % (cycle+1), end=' ')
            for key in sorted(self.mr.keys()):
                (mr, flag, unc) = self.mr[key][cycle]
                print("%10.3f %s %8.3f" % (mr, flag, unc), end=' ')
            print()

        print("  --------" + "-"*21*len(list(self.mr.keys())))
        print()
        print("  Gas      Mean    Std. Dev.   Unc      N")
        for name in worklist:
            (mr, sd, ncycles, flag, unc) = self.results[name]
            print("  %3s %10.3f %10.3f %8.3f %4d" % (name, mr, sd, unc, ncycles))

        print("  ---------------------------------------")
        print()

    #----------------------------------------------------------------------------------------------
    def stats(self, verbose=False):
        """ get some reference gas statistics for the system """

        if self.raw.method == "GC":
            self.gcstats(verbose)

#        elif self.raw.method == "QC-TILDAS" or self.raw.method == "CRDS":
        elif self.raw.method in ("QC-TILDAS", "CRDS", "Laser_Spectroscopy", "offaxis-ICOS"):
#            print("stats for", self.raw.method, "go here")
            self.laserstats(verbose)

        else:
            print("Statistics are not available for %s instruments." % self.raw.method)

    #----------------------------------------------------------------------------------------------
    def gcstats(self, verbose=False):
        """ Print out a table of statistics for gc measurements """

        key = self.raw.refid
        sernum = self.getRefgasSN(key)
        conc = self.getRefgasMR(key)

        num = 0
        nref = 0
        minratio = 9999.9
        maxratio = 0
        tk_area = []
        tk_hite = []
        mr_area = []
        mr_hite = []

        for i in range(self.raw.numrows):
            row = self.raw.dataRow(i)
            if row.ph == 0 or row.pa == 0:
                continue

            if i == 0:
                start = row.date

            if row.smptype == "REF":
                tk_area.append(row.pa)
                tk_hite.append(row.ph)
                ratio = row.pa/row.ph

                if ratio < minratio: minratio = ratio
                if ratio > maxratio: maxratio = ratio

                if len(tk_area) == 3:
                    avg_area = (tk_area[0] + tk_area[2]) / 2.0
                    avg_hite = (tk_hite[0] + tk_hite[2]) / 2.0
                    if conc > 0:
                        mr_area.append(tk_area[1]/avg_area * conc)
                        mr_hite.append(tk_hite[1]/avg_hite * conc)
                    else:
                        mra, rr, unc = self.resp.getResponseValue(tk_area[1], avg_area)
                        mrh, rr, unc = self.resp.getResponseValue(tk_hite[1], avg_hite)
                        if self.peaktype == "area":
                            mr_area.append(mra)
                            mr_hite.append(-999.99)
                        else:
                            mr_hite.append(mrh)
                            mr_area.append(-999.99)

                    tk_area.pop(0)
                    tk_hite.pop(0)

                nref += 1
            num += 1

        area_mean = numpy.average(mr_area)
        area_sd = numpy.std(mr_area, ddof=1)
        area_pr = area_sd/area_mean * 100
        hite_mean = numpy.average(mr_hite)
        hite_sd = numpy.std(mr_hite, ddof=1)
        hite_pr = hite_sd/hite_mean * 100


        if verbose:

            print("Statistics for rawfile ", self.raw.filename)
            print("Reference Tank %s                       :  %s %.2f" % (key, sernum, conc))
            print("Analyzer:                              : ", self.raw.info["Instrument"])
            print("Analytical sequence started            : ", start)
            print("Analytical sequence ended              : ", row.date)
            print()
            print("Total Number of Chromatograms          : ", num)
            print("Total Number of Reference Chromatograms: ", nref)
            print()
            print("Range of Area/Height Ratios            :     Minimum       Maximum")
            print("                                          %10.3f    %10.3f" % (minratio, maxratio))
            print()
    #       print "Range of Retention Times     :     Minimum     Maximum\n";
    #       printf "                               %10.1f  %10.1f\n", $minrt, $maxrt;
    #       print "\n\n";
    #       print "Baseline code percentages    :     Code        Percent\n";
    #       foreach $code (sort keys %bc) {
    #       $percent = $bc{$code} / $num * 100;
    #       printf "                             :      %2s          %6.2f\n", $code, $percent;
    #       }
    #       print "\n\n";
            print("Reference gas statistics               :     Height        Area")
            print("Mixing Ratio Mean                      :   %9.3f     %9.3f" % (hite_mean, area_mean))
            print("Standard Deviation                     :   %9.3f     %9.3f" % (hite_sd, area_sd))
            print("Precision (%% of assigned m.r.)         :   %9.3f     %9.3f" % (hite_pr, area_pr))

        else:
            if self.peaktype == "area":
                mean = area_mean
                sd = area_sd
                pr = area_pr
            else:
                mean = hite_mean
                sd = hite_sd
                pr = hite_pr

            fmt = "%-22s %s  %6.3f %6.3f %8.2f %8.3f %8.3f %8.3f"
            print(fmt % (self.raw.filename, self.adate.strftime("%Y %m %d %H %M %S"), minratio, maxratio, conc, mean, sd, pr))

    #----------------------------------------------------------------------------------------------
    def laserstats(self, verbose=False):
        """ Print out a table of statistics for laser instruments """

        key = self.raw.refid
        sernum = self.getRefgasSN(key)

        tk_val = []
        mr_val = []
        unc_val = []
        n_val = []

        for i in range(self.raw.numrows):
            row = self.raw.dataRow(i)

            if i == 0:
                start = row.date

            if row.smptype == "REF":
                tk_val.append(row.value)

                if len(tk_val) == 3:
                    avg_val = (tk_val[0] + tk_val[2]) / 2.0

                    mr, rr, unc = self.resp.getResponseValue(tk_val[1], avg_val)
                    mr_val.append(mr)
                    unc_val.append(unc)
                    n_val.append(1)

                    tk_val.pop(0)


        mean = numpy.average(mr_val)
        sd = numpy.std(mr_val, ddof=1)
        unc = ccg_utils.combined_stdv(mr_val, unc_val, n_val)
        pr = sd/mean * 100
        nref = len(mr_val)

        if verbose:

            print("Statistics for rawfile ", self.raw.filename)
            print("Reference Tank %s                      :  %s" % (key, sernum))
            print("Analyzer:                              : ", self.raw.info["Instrument"])
            print("Analytical sequence started            : ", start)
            print("Analytical sequence ended              : ", row.date)
            print("Number of Reference Measurements       : ", nref)
            print("Mole Fraction Mean                     :   %7.3f" % (mean))
            print("Standard Deviation                     :   %7.3f" % (sd))
            print("Uncertainty                            :   %7.3f" % (unc))
            print("Precision (%% of assigned m.r.)         :   %7.3f" % (pr))
            print()

        else:
            fmt = "%-22s %s  %8.3f %8.3f %8.3f %5d"
            print(fmt % (self.raw.filename, self.adate.strftime("%Y %m %d %H %M %S"), mean, sd, pr, nref))
