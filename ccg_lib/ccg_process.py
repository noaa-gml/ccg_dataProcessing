
# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class to hold data needed for calibration, flask, nl processing.
Includes working tank info, response curves, system ids etc.
"""
from __future__ import print_function

import sys
import datetime
import math

import ccg_refgasdb
import ccg_utils
import ccg_response
import ccg_rawfile
import ccg_dbutils
import ccg_peaktype

DEFAULTVAL = -999.99

# These are the flags and comments to be applied for various measurement conditions
FLAGS = {
    'ok':         ('...', ''),
    'voltage':    ('I..', 'bad voltage, Auto flagged'),
    'sample':     ('I..', 'bad sample flag. Auto flagged'),
    'aliquots':   ('*..', 'bad multi aliquots. Auto flagged'),
    'baseline':   ('*..', 'bad baseline code. Auto flagged'),
    'firstref':   ('..<', 'Only first reference is good.'),
    'secondref':  ('..>', 'Only second reference is good.'),
    'noref':      ('*..', 'No good references.'),
    'negative':   ('*..', 'Value less then 0'),
    'norefvalue': ('*..', "No assigned value for reference."),
}


#########################################################################################
# for python 3 only, class processData:
class processData(object):  # need this syntax for python2
    """ Base class for processing raw files.
    Shouldn't be called directly, but call a subclass of this class, e.g. Cal, Flask, Nl
    """

    def __init__(self,
                process_type,
                rawfile,
                database=None,
                peaktype=None,
                noresponse_curve=False,
                scale=None,
                moddate=None,
                debug=False):

        self.debug = debug
        self.datatype = process_type

        self.raw = ccg_rawfile.Rawfile(rawfile, debug=self.debug)
        self.valid = self.raw.valid
        if not self.valid: return

        self.species = self.raw.info["Species"].upper()
        self.lcspecies = self.species.lower()
        self.site = self.raw.info["Site"]
        self.method = self.raw.info["Method"]

        # get gasnum and sitenum from default database
        self.db = ccg_dbutils.dbUtils()
        self.gasnum = self.db.getGasNum(self.species)
        self.sitenum = self.db.getSiteNum(self.site)

        self._check_rawfile_type(self.datatype, self.raw.info)


        self.valid = True
        if moddate:
            self.moddate = moddate
        else:
            self.moddate = "9999-12-31"

        #----------------------------------------
        # scale info
        # default scale
        self.scalenum, self.scale = self.get_scale_info(self.species, scale)

#        if scale is not None:
#            self.scalenum = self.db.getScaleNum(scale)
#            self.scale = scale
#        else:
#            current_scale = self.db.getCurrentScale(self.species)
#            self.scalenum = current_scale['idx']
#            self.scale = current_scale['name']

        # check for overrides
        # if we are processing a co2 isotope file, we actually want the
        # scale for co2
        if self.species in ['CO2C13', 'CO2O18'] and process_type == "nl":
            current_scale = self.db.getCurrentScale("CO2")
            self.scalenum = current_scale['idx']
            self.scale = current_scale['name']

        if self.debug:
            print("process type", process_type)
            print("Species is ", self.species, file=sys.stderr)
            print("Scale is ", self.scale, file=sys.stderr)
            print("scale num is", self.scalenum, file=sys.stderr)

        #----------------------------------------
        #check to see if type is in header.  Use to call zero air calibration
        if "Type" in self.raw.info:
            self.type = self.raw.info["Type"]
        else:
            self.type = ""
        #if type is zero air tank calibration then set noresponse_curve to True
        self.zero_air_calibration = False
        if "ZERO AIR" in self.type.upper():
            noresponse_curve = True
            self.zero_air_calibration = True


        # check if ch4 scale is X2004. If it is, we don't want to use response curves.
        # Use curves only if scale is X2004A
        if self.species == "CH4" and self.scale == "CH4_X2004":
            noresponse_curve = True

        # system id and analyzer serial number
        self.system = self.raw.system.lower()
        self.analyzer_id = self.raw.instid
        if self.debug:
            print("system, analyzer:", self.system, self.analyzer_id, file=sys.stderr)


        # analysis date
        self.adate = self.raw.adate
        self.idate = self.raw.idate


        ########## --- Hardcode not to use H2 response curves for several periods on cocal-1 (inst H9) when there isn't
        #########      a valid response curve to use. First H2 response curve started on 2019-04-29
        #2019-06-20 -  2019-09-12 - no primary response curve available, use single point calibration vs CC49559
        if (self.species == "H2"
            and self.analyzer_id == "H9"
            and self.system == "cocal-1"
            and self.adate >= datetime.datetime(2019, 6, 20, 0, 0, 0)
            and self.adate < datetime.datetime(2019, 9, 12, 0, 0, 0)):
            noresponse_curve = True

        # 2019-12-17 - 2020-02-03 - no primary response curve available, use single point calibration vs CC49559
        if (self.species == "H2"
            and self.analyzer_id == "H9"
            and self.system == "cocal-1"
            and self.adate >= datetime.datetime(2019, 12, 17, 0, 0, 0)
            and self.adate < datetime.datetime(2020, 2, 3, 0, 0, 0)):
            noresponse_curve = True

        # 2020-07-21 - 2020-09-21 - no primary response curve available, use single point calibration vs CC49559
        if (self.species == "H2"
            and self.analyzer_id == "H9"
            and self.system == "cocal-1"
            and self.adate >= datetime.datetime(2020, 7, 21, 0, 0, 0)
            and self.adate < datetime.datetime(2020, 9, 21, 0, 0, 0)):
            noresponse_curve = True

        # 2021-05-03 - 2021-10-11 - no primary response curve available, use single point calibration vs CC49559
        if (self.species == "H2"
            and self.analyzer_id == "H9"
            and self.system == "cocal-1"
            and self.adate >= datetime.datetime(2021, 5, 3, 0, 0, 0)
            and self.adate < datetime.datetime(2021, 10, 11, 0, 0, 0)):
            noresponse_curve = True


        # Use a response curve if a responsecurve file exists.  If not, fall back to non-response calculations.
        if noresponse_curve:
            self.useResponseCurves = False
        else:
            self.resp = ccg_response.ResponseDb(self.species,
                                                 self.site,
                                                 self.scalenum,
                                                 self.system,
                                                 self.analyzer_id,
                                                 enddate=self.adate,
                                                 database=database,
                                                 debug=self.debug)

            self.useResponseCurves = self.resp.hasResponseCurves
            if self.debug:
                print("response curve data for %s is %s." % (self.analyzer_id, self.useResponseCurves), file=sys.stderr)

        # Get reference gas values for this analysis date
        # Returns a dict with refgas id as keys,
        # tuple of (serial number, mixing ratio, uncertainty) as value for the given adate
        # e.g. refgas["L"] = (CC71111, 385.66, 0.02)
        if process_type != "nl":
            self.refgas = self._get_refgas(self.adate, database)
            if len(self.refgas) == 0:
                print("Can't process file, no reference tank information available.", file=sys.stderr)

            if len(self.refgas) == 0 and self.useResponseCurves is False:
                print("No reference gas or response curve information found for analysis date %s-%s-%s" %
                    (self.adate.year, self.adate.month, self.adate.day),
                    file=sys.stderr)
                self.valid = False
                return

            if self.debug:
                print("Refgas Information")
                for key in list(self.refgas.keys()):
                    print("     ", key, self.refgas[key], file=sys.stderr)

        self.peaktype = peaktype
        if self.method == "GC" and peaktype is None:
            self.peaktype = ccg_peaktype.getPeaktype(self.analyzer_id, self.lcspecies)

    #---------------------------------------------------------------------------
    @staticmethod
    def _check_rawfile_type(datatype, info):
        """ check that the raw file we read is correct for the processing type

        This depends on the 'Sample type' header line in the raw file, which is
        not available for older raw files.
        Flask raw files can have either 'flask' or 'pfp' for the sample type.
        """

        # exit if types don't match, otherwise do nothing
        if "Sample type" in info:
            sample_type = info["Sample type"]
            if sample_type.lower() != datatype.lower():
                if datatype.lower() == "flask" and sample_type.lower() == "pfp":
                    pass
                elif datatype.lower() == "cals" and sample_type.lower() == "zero_air_cals":
                    pass
                else:
                    sys.exit("ERROR: Wrong type of rawfile for %s.  Got %s." % (datatype, sample_type))

    #---------------------------------------------------------------------------
    def _get_refgas(self, adate, database):
        """ Read in reference gas values of sample type 'REF' from database or file.
        Return a dict with tank name as keys, tuple of (serial numbers, mixing ratios) as values
        """

        # first get refgas id's from raw and info lists
        refgas = {}
        for ref in self.raw.refs:
            sn = self.raw.info[ref]
            refgas[ref] = (sn, -999.99, -99.99)


        # response curves don't use assigned values of reference gases, so no need to fetch data
        # get refgas info only for our list of serial numbers
        if not self.useResponseCurves:
            serialnums = [t[0] for t in refgas.values()]
            ref = ccg_refgasdb.refgas(self.species,
                                      sn=serialnums,
                                      database=database,
                                      enddate=self.adate,
                                      scale=self.scale,
                                      moddate=self.moddate,
                                      debug=self.debug)
            for smpid in list(refgas.keys()):
                sn = refgas[smpid][0]
                show = not self.useResponseCurves
#                print('%%%', self.useResponseCurves, show)
                mr, unc = ref.getRefgasBySerialNumber(sn, adate, showWarn=show)
                refgas[smpid] = (sn, mr, unc)


        self.nstds = len(refgas)

        return refgas

    #--------------------------------------------------------------------------
    def _check_std(self, row_idx, std, prev=True, oneback=False, bcodes=None):
        """ Get and check values of either previous or next std, starting at
        row index 'row_idx'.
        Input:
            row_idx - Index in raw data to start search.
            std - Tank label of desired entry, e.g. 'R0', 'S1'
            prev - True: Go backward and find previous entry in raw data
                   False: Go forward and find next entry in raw data
            oneback - True: Look only 1 row back/forward for std
                      False: Look forward/back as many rows as required to find std
            bcodes - List of baseline codes to check with.  Entry must have one of
                     these baseline codes.

        Returns measured value from found row and true/false flag if good value or not
        """

        val = DEFAULTVAL
        val_unc = DEFAULTVAL
        r = True

        # find std.  If not found, returns -1, else returns row index
        if prev:
            linenum = self.raw.findPrevStd(row_idx, std, oneback=oneback)
        else:
            linenum = self.raw.findNextStd(row_idx, std, oneforward=oneback)

        if linenum >= 0:
            row = self.raw.dataRow(linenum)
            flag = row.flag

            if self.method == "GC":
                val = row.ph if self.peaktype == "height" else row.pa
                if bcodes is not None: r = row.bc in bcodes
            elif self.method == "VURF":
                (val, val_unc, flag) = self.raw.zeroCorrectSignal(linenum)
            else:
                if row.n > 0:
                    val = row.value
                    val_unc = row.std/math.sqrt(row.n)
                elif row.n == -9:
                    val = row.value
                    val_unc = row.std
                else:
                    r = False

            if flag != ".": r = False
        else:
            r = False

        return val, val_unc, r, linenum

    #----------------------------------------------------------------------
    def _get_mixing_ratio(self, val, avgstd, flg, comm):
        """ Compute mixing ratio for sample value 'val' and reference value 'avgstd'.
        """

        flag = flg
        comment = comm

        if avgstd not in (0, DEFAULTVAL):
            if self.useResponseCurves:
                value, rr, unc = self.resp.getResponseValue(val, avgstd)
            else:
                # If a response curve is not used, mimic the coefficients with
                # linear response point through 0,0 and conc, 1, where conc is
                # the assigned value of the reference gas
                coef = self._get_fake_coef()
                if coef is None:
                    flag, comment = FLAGS['norefvalue']
                    return DEFAULTVAL, flag, comment, 0, 0

                rr = val/avgstd
                value = ccg_utils.poly(rr, coef)
                unc = 0

        else:
            rr = -1
            value = DEFAULTVAL
            unc = DEFAULTVAL

        if self.debug:
            print("\nget_mixing_ratio ====")
            print("    Value = ", val)
            print("    Ratio = ", rr)
            print("    MR = %f" % (value))
            print("    Unc = %f" % (unc))

        value = self.getCorrection(value)

        # Sanity check on mixing ratio
    #    if value < 0 or value > 99999.99:
        if value < 0 and not self.zero_air_calibration:
            value = DEFAULTVAL
            flag, comment = FLAGS['negative']

        return value, flag, comment, unc, rr

    #----------------------------------------------------------------------------------------------
    def _get_fake_coef(self):
        """ If a response curve is not used, mimic the coefficients with
        linear response point through 0,0 and conc, 1, where conc is
        the assigned value of the reference gas
        """

        key = list(self.refgas.keys())[0]
        conc = self.getRefgasMR(key)
        if conc == DEFAULTVAL:
            if self.debug: print("No value for reference %s." % key)
            return None

        coef = [0, conc, 0]

        return coef

    #----------------------------------------------------------------------------------------------
    def getRefgasMR(self, refid):
        """ Get the assigned mixing ratio value for a tank id (e.g. R0, W1 ...) """

        return self.refgas[refid][1]

    #----------------------------------------------------------------------------------------------
    def getRefgasSN(self, refid):
        """ Get the serial number of the reference tank 'refid' (e.g. R0, W1 ...) """

        return self.refgas[refid][0]

    #----------------------------------------------------------------------------------------------
    def getCorrection(self, value):
        """ Apply correction to calculated value
        FOR CALS ONLY.  Flask corrections are done differently.  Should fix.
        """

        c = value
        if self.datatype == "cal" and self.analyzer_id == "P2" and self.species == "H2":
            c = 95.27 + 0.822157 * value

        return c

    #----------------------------------------------------------------------------------------------
    @staticmethod
    def getAvgValue(std1, std2, r1, r2):
        """
        Check if previous/next standards are valid, determine std value to use
        and appropriate flag.
        4 possibilities
        1. preceeding aliquot is a good reference and following aliquot is a good reference
        2. preceeding aliquot is a good reference and following aliquot is not a good reference
        3. preceeding aliquot is not a good reference and following aliquot is a good reference
        4. preceeding aliquot is not a good reference and following aliquot is not a good reference

        Flag for 1 is "...";
        Flag for 2 is "..<";
        Flag for 3 is "..>";
        Flag for 4 is "*..";
        """

        # case 1
        if r1 and r2:
            avgstd = (std1 + std2)/2.0
            flag, comment = FLAGS['ok']
#            if self.debug: print("   Two good references")

        # case 2
        elif r1:
            avgstd = std1
            flag, comment = FLAGS['firstref']
#            if self.debug: print("   Only first reference is good.")

        # case 3
        elif r2:
            avgstd = std2
            flag, comment = FLAGS['secondref']
#            if self.debug: print("   Only second reference is good.")

        # case 4
        else:
            avgstd = -999.99
            flag, comment = FLAGS['noref']
#            if self.debug: print("   No good references")

        return (avgstd, flag, comment)


    #--------------------------------------------------------------------------
    @staticmethod
    def getDriftCorrValue(i, idx1, idx2, std1, std2, valid1, valid2):
        """ Get drift corrected value between two stds """

        # for older lira measurements, don't always have 2 reference
        # gases bracketing the samples, so check if only one good reference
        if valid1 and valid2:
            drift = (std2 - std1) / (idx2 - idx1)  # drift in volts/aliquot
            stdv = std1
            idx = idx1
        elif valid1:
            stdv = std1
            idx = idx1
            drift = 0
        elif valid2:
            stdv = std2
            idx = idx2
            drift = 0
        else:
            return DEFAULTVAL

        avgstd = stdv + (i - idx)*drift  # drift corrected std value

        return avgstd

    #--------------------------------------------------------------------------
    def get_scale_info(self, gas, scalename):

        if scalename is not None:
            scalenum = self.db.getScaleNum(scalename)
        else:
            current_scale = self.db.getCurrentScale(gas)
            scalenum = current_scale['idx']
            scalename = current_scale['name']


        return scalenum, scalename
    #----------------------------------------------------------------------------------------------
    def _get_meas_unc(self, sample_val, sample_std, avgstd, avgunc):
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

