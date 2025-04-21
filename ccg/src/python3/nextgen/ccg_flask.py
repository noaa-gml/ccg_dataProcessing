
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# A class to hold data needed for flask processing.
# Includes reference tank info, corrections, response curves, system ids etc.

- Update July 31, 2018, added uncertainties using method in uncdata module.
- Update Dec 2019, major revision:
    subclass of processData
    make compatible with python 3,
    remove flagging code
    use ccg_flaskdb class for database operations
- Update Oct 2022, major revision:
    use response database table instead of files
    use single master uncertainty file instead of individual files
    scale assignments of reference gases must now match on fill code
    tagging functionality (still to do)
    use revised ccg_flaskdb that uses new ccg_flask_data class
    include comments when printing results

Usage:
    fl = Flask(...)

"""
from __future__ import print_function

import sys
import math
from collections import namedtuple
import numpy

import ccg_utils
import ccg_process
import ccg_flaskdb
import ccg_flask_corr  # for flaskCorrections class
import ccg_uncdata_all

DEFAULTVAL = -999.99

# These are the tags and comments to be applied for various measurement conditions

TAGS = {
    'ok':         (0, ''),
    'voltage':    (213, 'Bad voltage (automatic).'),
    'sample':     (198, 'Bad sample flag (automatic).'),
    'aliquots':   (197, 'Bad multi aliquots (automatic).'),
    'baseline':   (34, 'Bad baseline code (automatic).'),
    'firstref':   (200, 'Only first reference is good (automatic).'),
    'secondref':  (200, 'Only second reference is good (automatic).'),
    'noref':      (198, 'No good references (automatic).'),
    'negative':   (213, 'Value less then 0 (automatic).'),
    'norefvalue': (197, 'No assigned value for reference (automatic).'),
}

##################################################################
def groupby(a):
    """ group consecutive duplicate entries in a, saving the indices where duplicates occur.
    Returns a list of dicts, each dict has the list value as key and the indices as value
    For example,
            a = [1,2,3,3,3,4,5,7,7,7,2,3,3,3]
    Result is
    [{1: [0]}, {2: [1]}, {3: [2, 3, 4]}, {4: [5]}, {5: [6]}, {7: [7, 8, 9]}, {2: [10]}, {3: [11, 12, 13]}]
    which is
            1 is at index 0
            2 is at index 1
            3 is at index 2, 3, 4
            4 is at index 5
            5 is at index 6
            7 is at index 7, 8, 9
            2 is at index 10
            3 is at index 11, 12, 13

    Similar entries which are separated by different values are given separate results

    This is needed when determining multiple aliquots in a raw file
    where the same flask could be analyzed more than once (yeah you, 5 liters)
    """

    g = []
    z = None
    prev = None

    for idx, v in enumerate(a):
        if v != prev:
            if z: g.append(z)
            z = {v: [idx]}
        else:
            z[v].append(idx)

        prev = v

    if z: g.append(z)

    return g


##################################################################
class Flask(ccg_process.processData):
    """ Class for ancillary flask data needed for processing of raw files.
    All data comes from the flask raw files, passed in by the 'info' and 'raw' lists.

    Attributes:
    flask.species  - Upper case designation of gas, e.g. 'CO2', 'CH4' etc.
    flask.lcspecies - Lower case designation of gas, e.g. 'co2', 'ch4' etc.
    flask.system - System id from raw file
    flask.analyser - Analyser serial number
    flask.adate - Date of analysis
    flask.idate - Integer representation of analysis date with year, month, day, hour e.g. 2012010515
    flask.resp - Tuple with date and coefficients of response curve for the analysis date.
             Empty if not available.  The response file used can be overridden by passing in refgasfile=
             in creation
    flask.useResponseCurves - Boolean if response curves are to be used for computation of mixing ratios
    flask.sample_data - Sampling information for each sample, such as sample date, time, site, etc.
    flask.corrections - Class for computeing correction to be applied to computed mixing ratio.
    flask.refgas - List of reference gas information
        Has the tank id as the keys,  tuple of serial number and mixing ratio as value for the given adate
        e.g. refgas["L"] = (CC71111, 385.66)
        You can get a list of tank id's with flask.refgas.keys()
    flask.nstds - Number of reference gas standards used.  Equal to length of flask.refgas
    flask.peaktype - Type of peak to use for computation of mixing ratios. Should be either 'area' or 'height'.
        None if not used.  Can be overridden by passing in peaktype= parameter in creation.


    Public Methods:
        printResults()
        printSummary()
        printTable()
        checkDb()
        updateDb()
        deleteDb()

    Creation:
    fldata = ccg_flask.Flask(rawfile, peaktype, scale, moddate, database, nocorr, debug)
        rawfile      - name of raw file to process
        peaktype     - Type of peak to use of gc systems.  If not set, uses default value from defaults file.
        scale        - use scale other than the default current scale
        moddate      - use modification date when pulling values for standards
        database     - name of database to use for response curves and flask results.
        nocorr       - If True, do not apply corrections to the flask data.
        debug        - print debugging information if true

        rawfile is required.
        All others are optional.
    """

    #----------------------------------------------------------------------------------------------
    def __init__(self, rawfile, peaktype=None, scale=None, moddate=None, database=None, nocorr=False, debug=False):

        super(Flask, self).__init__("flask", rawfile, database, peaktype, False, scale, moddate, debug)

        if not self.valid: return

        self.nocorr = nocorr

        # Get sample event data
        # Needed for corrections and certain listing options
        events = self.raw.getSampleEvents()
        if len(events) == 0:
            print("Warning: No sample data in file ", rawfile, file=sys.stderr)
        self.flaskdb = ccg_flaskdb.Flasks(events, self.species, database=database, debug=debug)


        # Get corrections from the correction file by creating a flaskCorrection class
        # Need analyzer id and analysis date so we can filter out unneeded correction entries.
        correction_file = "/ccg/%s/flask/corrections.%s" % (self.lcspecies, self.lcspecies)
        self.corrections = ccg_flask_corr.flaskCorrections(correction_file, self.flaskdb.sample_data, self.analyzer_id, self.adate, debug=debug)

        # create a namedtuple object for storing results
        self.Result = namedtuple('row', ['event', 'gas', 'mf', 'meas_unc', 'tag', 'inst', 'adate', 'comment'])

        # flagging is now done in separate program
        # !! Be careful, events coming from raw file are strings, but events from ccg_flaskdb.Flasks are ints
        self.results = self._compute_mr()
    #    print self.results


    #----------------------------------------------------------------------------------------------
    def _find_sample_data(self, event):
        """ Given an event number and analysis date, return the flask sample information for that event. """

        return self.flaskdb.sampleData(event)


    #----------------------------------------------------------------------------------------------
    def _get_corr(self, mr, event, adate):
        """ Get correction value for an event on a date """

        if self.nocorr:
            corr = 0
        else:
            corr = self.corrections.getCorrection(mr, event, adate)

        return corr


    #----------------------------------------------------------------------------------------------
    def _compute_mr(self):
        """ Determine which routine to use for calculating mole fractions """

        if self.method == "NDIR":
            co2_method = self._getCo2Method()

            if co2_method == 1:
                results = self._compute_mr_co2_1()
            else:
                results = self._compute_mr_co2_2()

        elif self.method == "VURF":
            results = self._compute_mr_vurf()

        elif self.method == "GC":
            results = self._compute_mr_gc()

        else:
            results = self._compute_mr_laser()


        return results


    #----------------------------------------------------------------------------------------------
    def _getCo2Method(self):
        """
        * CO2 analysis on magicc system can be done either of
        * two ways;
        * 1: Normally along with the other gas species,
        * where one flask sample is bracketed by 2 stds., or
        * 2: CO2 flask analysis only, where 8 flasks are measured
        * with three standards analyzed before and after.
        *
        * Each method requires a different algorithm to calculate
        * mixing ratios, but since the system is the same, there
        * is no way to specify which one to use without looking
        * at the file.
        *
        * Therefore, scan through file first to see if there are
        * consecutive flask samples.
        * If so, use the second method of calculating mixing ratios,
        * else, use the first method.
        """

        if self.analyzer_id == "L0": return 2

        method = 1
        prevtype = ""
        for line in self.raw.data:
            sampletype = line[0]
            if sampletype == "SMP" and prevtype == "SMP":
                method = 2
                break
            prevtype = sampletype

        return method


    #----------------------------------------------------------------------------------------------
    def _compute_mr_co2_1(self):
        """
        Calculate mixing ratios for single flask bracketed by standards,
        e.g.  L - SMP - M - SMP - H - SMP - L ...
        Calculate using the following reference and the two previous references
        for each sample.
        """

        results = []

        if self.debug:
            print("Using method 1, single flask bracketed by standards")

        # assigned values of reference tanks
        y = [t[1] for key, t in sorted(self.refgas.items())]

        v = {}

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if row.flag != ".":
                if self.debug: print("bad flag %s" % (row.flag))
                mf = DEFAULTVAL
                tag, comment = TAGS['sample']
            else:

                # find 2 previous refs and next ref
                linenum1 = self.raw.findPrevRef(i)
                linenum2 = self.raw.findPrevRef(linenum1-1)
                linenum3 = self.raw.findNextRef(i)

                # get voltage value for each ref
                (stype, event, dt, val1, val2, val3, flag, bc) = self.raw.data[linenum1]
                v[event] = val1
                (stype, event, dt, val1, val2, val3, flag, bc) = self.raw.data[linenum2]
                v[event] = val1
                if linenum3 >= 0:   # kludgy fix for a raw file that doesn't end in a reference
                    (stype, event, dt, val1, val2, val3, flag, bc) = self.raw.data[linenum3]
                    v[event] = val1

                x = [v[key] for key in sorted(v)]
                coeffs = numpy.polyfit(x, y, deg=2)
                value = numpy.polyval(coeffs, row.value)
                c = self._get_corr(value, row.event, row.date)
                mf = value + c
                tag, comment = TAGS['ok']

#            t = (row.event, self.species, round(mf, 2), flag, self.analyzer_id, row.date, comment)
            t = (row.event, self.species, round(mf, 2), 0, tag, self.analyzer_id, row.date, comment)
            results.append(self.Result._make(t))

        return results


    #----------------------------------------------------------------------------------------------
    def _compute_mr_co2_2(self):
        """
        Calculate mixing ratios for multiple flasks bracketed by standards,
        e.g.  L - M - SMP - SMP - SMP - SMP - L - M ...
        e.g.  L - M - H - SMP - SMP - SMP - SMP - L - M - H ...
        """

        tmp = []

        gaslist = sorted(self.refgas.keys())
        y = [self.getRefgasMR(refid) for refid in gaslist]

        for i in range(self.raw.numrows):
            row = self.raw.dataRow(i)
            if row.smptype != "SMP":
                # make a dummy entry in tmp list for the reference
                # we need these to correctly average multiple aliquots of a single flask
                t = (row.event, self.species, DEFAULTVAL, 0, "...", self.analyzer_id, row.date, "")
                tmp.append(self.Result._make(t))

            else:

                if self.debug: print("Working on event ", row.smptype, row.event)

                if row.flag != ".":
                    mr = DEFAULTVAL
                    tag, comment = TAGS['sample']

                elif row.value < -9:
                    mr = DEFAULTVAL
                    tag, comment = TAGS['voltage']

                else:

                    # look for preceeding and following refs
                    x = []
                    for refid in gaslist:
                        #std1, valid1, idx1 = self._check_std(i, refid, prev=True)
                        #std2, valid2, idx2 = self._check_std(i, refid, prev=False)
                        std1, std1_unc, valid1, idx1 = self._check_std(i, refid, prev=True)
                        std2, std2_unc, valid2, idx2 = self._check_std(i, refid, prev=False)

                        if self.debug: print("   prev, next ref values:", valid1, valid2, std1, std2)

                        if self.nstds == 2:
                            # need to drift correct instead of average the bracketing refs
                            avgstd = self.getDriftCorrValue(i, idx1, idx2, std1, std2, valid1, valid2)

                        else:
                            (avgstd, tag, comment) = self._get_avg_value(std1, std2, valid1, valid2)

                        x.append(avgstd)

                    if self.debug:
                        print("   values for polyfit:", x, y)

                    if DEFAULTVAL in y:
                        mr = DEFAULTVAL
                        tag, comment = TAGS['norefvalue']
                    else:
                        coeffs = numpy.polyfit(x, y, deg=self.nstds-1)
                        mr = numpy.polyval(coeffs, row.value)
                        tag, comment = TAGS['ok']

                    c = self._get_corr(mr, row.event, row.date)
                    mr += c

#                t = (row.event, self.species, round(mr, 2), flag, self.analyzer_id, row.date, comment)
                t = (row.event, self.species, round(mr, 2), 0, tag, self.analyzer_id, row.date, comment)
                tmp.append(self.Result._make(t))

        results = self._handle_multi_aliq(tmp)

        return results


    #----------------------------------------------------------------------------------------------
    def _handle_multi_aliq(self, tmp):
        """ Look for consecutive aliquots (same event numbers) in the 'tmp'
        results list, and average them, returning a new results list with
        consecutive aliquots for same event number removed.
        Don't average aliquots that have a reference between them, so we
        need to have entries in the tmp list for reference tanks too,
        and skip over them here.
        """

        results = []
        a = numpy.array(tmp)  # convert list of results to array
        events = a.T[0]
        groups = groupby(events) # groups is a list of dicts, each dict has only one entry
        for group in groups:
            for event_num, w in group.items(): # each dict has event num, indices
                # skip reference aliquots, which don't have an integer event number
                if event_num.isnumeric():
                    vals = a.T[2][w]
                    t = tmp[w[0]]                        # use first aliquot for results
                    smpdata = self._find_sample_data(event_num)
                    if len(vals) > 1 and smpdata['code'] != 'TST':
                        (avgmr, tag, comment) = self._average_aliquots(vals)
                        t = t._replace(mf=avgmr, tag=tag, comment=comment)
                    results.append(t)            # save new tuple

        return results


    #----------------------------------------------------------------------------------------------
    def _average_aliquots(self, a):
        """
        For older samples where multiple aliquots were taken (such as 3 and 5 liter
        flasks), we need a special way to average the aliquots.  They should all
        be within 0.5 ppm of each other.  If not, remove the highest value.
        """

        if self.debug:
            print("Average %d aliquots" % len(a))

        cc = [val for val in a if val >= 0]

        if len(cc) == 0:
            tag, comment = TAGS['aliquots']
            avg = DEFAULTVAL

        elif len(cc) == 1:
            tag, comment = TAGS['ok']
            avg = cc[0]

        else:
            minimum = min(cc)
            maximum = max(cc)

            if maximum - minimum > 0.5:
                cc.remove(maximum)

            avg = numpy.average(cc)
            if avg < 0:
                tag, comment = TAGS['aliquots']
                avg = DEFAULTVAL
            else:
                tag, comment = TAGS['ok']

        return avg, tag, comment


    #----------------------------------------------------------------------------------------------
    def _compute_mr_gc(self):
        """
        Calculate mixing ratios for single flask bracketed by standard,
        e.g.  S - SMP - S - SMP - S - SMP - S ...
        For gas chromatographs, so take into account baseline codes
        """

        results = []

        bcodes = self.raw.info["Baseline Codes"].split()

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if self.debug: print("Working on event ", row.smptype, row.event)

            if row.flag != ".":
                if self.debug: print("bad flag %s" % (row.flag))
                mr = DEFAULTVAL
                tag, comment = TAGS['sample']

            elif row.bc not in bcodes:
                if self.debug: print("baseline code %s not in %s" % (row.bc, bcodes))
                mr = -999.99
                tag, comment = TAGS['baseline']

            else:
                ## look for preceeding and following refs
                #std1, valid1, idx1 = self._check_std(i, self.raw.refid, prev=True, bcodes=bcodes)
                #std2, valid2, idx2 = self._check_std(i, self.raw.refid, prev=False, bcodes=bcodes)
                std1, std1_unc, valid1, idx1 = self._check_std(i, self.raw.refid, prev=True, bcodes=bcodes)
                std2, std2_unc, valid2, idx2 = self._check_std(i, self.raw.refid, prev=False, bcodes=bcodes)

                if self.debug: print("   prev, next ref values:", valid1, valid2, std1, std2)

                (avgstd, tag, comment) = self._get_avg_value(std1, std2, valid1, valid2)

                val = row.ph if self.peaktype == "height" else row.pa
                mr, unc, tag, comment = self._get_mole_fraction(val, avgstd, tag, comment)

                c = self._get_corr(mr, row.event, row.date)
                mr = mr + c

#            t = (row.event, self.species, round(mr, 2), flag, self.analyzer_id, row.date, comment)
            t = (row.event, self.species, round(mr, 2), 0, tag, self.analyzer_id, row.date, comment)
            results.append(self.Result._make(t))


        return results


    #----------------------------------------------------------------------------------------------
    def _compute_mr_laser(self):
        """
        Calculate mixing ratios for single flask bracketed by standard,
        Use for laser spectroscopic system
        e.g.  S - SMP - S - SMP - S - SMP - S ...
        Almost identical to compute_mr_gc except don't look at baseline codes.
        For LGR and Picarro instruments
        """

        results = []

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if self.debug: print("\n--- Working on event ", row.smptype, row.event, "---")

            if row.flag != ".":
                mr = DEFAULTVAL
                tag, comment = TAGS['sample']

            else:
                ## look for preceeding and following refs
                #std1, valid1, idx1 = self._check_std(i, self.raw.refid, prev=True, oneback=True)
                #std2, valid2, idx2 = self._check_std(i, self.raw.refid, prev=False, oneback=True)
                std1, std1_unc, valid1, idx1 = self._check_std(i, self.raw.refid, prev=True, oneback=True)
                std2, std2_unc, valid2, idx2 = self._check_std(i, self.raw.refid, prev=False, oneback=True)

                if self.debug: print("   prev, next ref values:", valid1, valid2, std1, std2)

                (avgstd, tag, comment) = self._get_avg_value(std1, std2, valid1, valid2)
#                mr, unc, flag, comment = self._get_mole_fraction(row.value, avgstd, flag, comment)
                mr, unc, tag, comment = self._get_mole_fraction(row.value, avgstd, tag, comment)
                c = self._get_corr(mr, row.event, row.date)
                mr = mr + c

# way to add in flask measurement noise? don't think this is valid.
#                if self.debug:
#                    std = row.std / math.sqrt(row.n)
#                    print("   modified unc", unc, row.std, math.sqrt(unc*unc + std*std))

#            t = (row.event, self.species, round(mr, 2), flag, self.analyzer_id, row.date, comment)
            t = (row.event, self.species, round(mr, 2), unc, tag, self.analyzer_id, row.date, comment)
            results.append(self.Result._make(t))

        return results


    #----------------------------------------------------------------------------------------------
    def _compute_mr_vurf(self):
        """
        Compute co mixing ratios using the vurf analyzer
        Almost identical to compute_mr_laser except zero correct signal
        """

        results = []

        for i in self.raw.sampleIndices():
            row = self.raw.dataRow(i)
            if self.debug: print("Working on event ", row.smptype, row.event)

            if row.flag != ".":
                mr = DEFAULTVAL
                tag, comment = TAGS['sample']

            else:
                (smpl, flag) = self.raw.zeroCorrectSignal(i) # returns zero corrected signal
                if self.debug: print("   zero corrected signal is:", smpl)

                #std1, valid1, idx1 = self._check_std(i, self.raw.refid, prev=True)
                #std2, valid2, idx2 = self._check_std(i, self.raw.refid, prev=False)
                std1, std1_unc, valid1, idx1 = self._check_std(i, self.raw.refid, prev=True)
                std2, std2_unc, valid2, idx2 = self._check_std(i, self.raw.refid, prev=False)


                if self.debug: print("   prev, next ref values:", valid1, valid2, std1, std2)

#                (avgstd, flag, comment) = self._get_avg_value(std1, std2, valid1, valid2)
#                mr, unc, flag, comment = self._get_mole_fraction(smpl, avgstd, flag, comment)
                (avgstd, tag, comment) = self._get_avg_value(std1, std2, valid1, valid2)
                mr, unc, tag, comment = self._get_mole_fraction(smpl, avgstd, tag, comment)

                c = self._get_corr(mr, row.event, row.date)
                mr = mr + c


#            t = (row.event, self.species, round(mr, 2), flag, self.analyzer_id, row.date, comment)
            t = (row.event, self.species, round(mr, 2), unc, tag, self.analyzer_id, row.date, comment)
            results.append(self.Result._make(t))

        return results

    #----------------------------------------------------------------------------------------------
    @staticmethod
    def _get_avg_value(std1, std2, r1, r2):
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
            tag, comment = TAGS['ok']

        # case 2
        elif r1:
            avgstd = std1
            tag, comment = TAGS['firstref']

        # case 3
        elif r2:
            avgstd = std2
            tag, comment = TAGS['secondref']

        # case 4
        else:
            avgstd = -999.99
            tag, comment = TAGS['noref']

        return avgstd, tag, comment

    #----------------------------------------------------------------------------------------------
    def _get_mole_fraction(self, sample_val, avgstd, tag, comment):
        """ Calculate the mole fraction for sample_val, using a response curve equation """

        if avgstd in (0, DEFAULTVAL):
            rr = -1
            value = DEFAULTVAL
            unc = DEFAULTVAL

        else:
            if self.useResponseCurves:
                value, rr, unc = self.resp.getResponseValue(sample_val, avgstd)
            else:
                # If a response curve is not used, mimic the coefficients with
                # linear response point through 0,0 and conc, 1, where conc is
                # the assigned value of the reference gas
                key = list(self.refgas.keys())[0]
                conc = self.getRefgasMR(key)
                if conc == DEFAULTVAL:
                    if self.debug: print("No value for reference %s." % key)
                    tag, comment = TAGS['norefvalue']
                    return DEFAULTVAL, 0, tag, comment

                coef = [0, conc, 0]
                rr = sample_val/avgstd
                value = ccg_utils.poly(rr, coef)
                unc = 0

        if self.debug:
            print("\nget_mixing_ratio ====")
            print("    Value = ", value)
            print("    Ratio = ", rr)
            print("    MR = %f" % (value))
            print("    Unc = %f" % (unc))

        # Sanity check on mixing ratio
        if value < 0:
            value = DEFAULTVAL
            tag, comment = TAGS['negative']

        return value, unc, tag, comment

    #--------------------------------------------------------------------------
    def printTable(self):
        """ Print table of results """

        format1 = "%10s %4s %s %13s %4s %10.2f %8.2f %8s %5s       %s %s"

        print("%50s\n" % (self.species + " Flask Analysis"))
        print("System:              %s" % self.system)
        print("Analysis Date:       %s" % (self.adate.strftime("%Y-%m-%d %H:%M")))
        print("Analyzer:            %s\n" % (self.raw.info["Instrument"]))

        gaslist = list(self.refgas.keys())
        for tank in gaslist:
            sernum = self.getRefgasSN(tank)
            conc = self.getRefgasMR(tank)
            print("Reference Tank %s:   %s %.2f" % (tank, sernum, conc))

        if self.useResponseCurves is True:
            coef = self.resp.getCoeffs()
            rdate = self.resp.getAdate()
            if self.resp.getFunction() == "poly":
                fmt = "Response Curve:      %.8f + %.8f * R +  %.8f * R^2 on %d-%02d-%02d:%02d"
                print(fmt % (coef[0], coef[1], coef[2], rdate.year, rdate.month, rdate.day, rdate.hour))
            else:
                fmt = "Response Curve:      %.8f + %.8f * R ^ %.8f on %d-%02d-%02d:%02d"
                print(fmt % (coef[0], coef[1], coef[2], rdate.year, rdate.month, rdate.day, rdate.hour))


        print()
        print("   Event   Site    Sample Date         ID       Meth  Mole Fract   Munc     Tag  Inst        Analysis Date")
        print("----------------------------------------------------------------------------------------------------")

        for row in self.results:

            line = self._find_sample_data(row.event)
            if line is None:
                print(format1 % (0, 'XXX', "0000-00-00 00:00:00", "None", "X",
                        row.mf, 0, row.tag, row.inst, row.adate.strftime("%Y-%m-%d %H:%M"), row.comment))

            else:
                print(format1 % (row.event, line['code'], line['date'].strftime("%Y-%m-%d %H:%M"),
                         line['flaskid'], line['method'], row.mf, row.meas_unc, row.tag, row.inst,
                         row.adate.strftime("%Y-%m-%d %H:%M"), row.comment))


        print("----------------------------------------------------------------------------------------------------")


    #--------------------------------------------------------------------------
    def printResults(self, addalt=False, dbflags=False):
        """ Print out results in site string format """

        format1 = "%10s %3s %s %13s %1s %8.2f %8.2f %3s %3s %s"
        format2 = "%9.4f %9.4f %8.2f %s"

        for row in self.results:
            if dbflags:
                record = self.flaskdb.measurementData(row.event, row.gas, row.adate, row.inst)
                flag = record['qcflag']
            else:
                flag = row.tag

            line = self._find_sample_data(row.event)
            if line is None:
                print(format1  % (row.event, 'XXX', '0000 00 00 00 00', 'None', 'X', row.mf, 0,
                        flag, row.inst, row.adate.strftime("%Y %m %d %H %M")), end=' ')
            else:
                print(format1  % (row.event, line['code'], line['date'].strftime("%Y %m %d %H %M"),
                        line['flaskid'], line['method'], row.mf, row.meas_unc, flag, row.inst,
                        row.adate.strftime("%Y %m %d %H %M")), end=' ')

            if addalt:
                print(format2 % (line['latitude'], line['longitude'], line['altitude'], row.comment))
            else:
                print(row.comment)


    #--------------------------------------------------------------------------
    def checkDb(self, verbose=False):
        """ Check the result string with the corresponding value in the database. """

        for t in self.results:
            self.flaskdb.checkDb(t, verbose=verbose)


    #----------------------------------------------------------------------------------------------
    def updateDb(self, verbose=False):
        """ Update the database with results. """

        # Read in the uncertainty data.  added 31 Jul 2018
#        uncfile = "/ccg/src/python3/nextgen/unc_master.txt"
        uncert = ccg_uncdata_all.dataUnc('flask', self.species, self.site, self.system, debug=self.debug)

        for t in self.results:
            sampleinfo = self._find_sample_data(t.event)
            if sampleinfo is None:
                unc = 0
            else:
                sitecode = sampleinfo['code']
                method = sampleinfo['method']

                unc = uncert.getUncertainty(sitecode, t.adate, t.mf, method, t.inst)
#                uncvals = uncert.getUncertainties(sitecode, t.adate, t.mf, method, t.inst)
#                unc = uncert.getTotalUncertainty(uncvals)

#            print("unc is", unc)
            self.flaskdb.updateDb(t, unc, self.system, verbose=verbose)


    #----------------------------------------------------------------------------------------------
    def deleteDb(self, verbose=False):
        """ Delete results from the database. """

        for t in self.results:
            self.flaskdb.deleteDb(t, verbose=verbose)

    #----------------------------------------------------------------------------------------------
    def stats(self, verbose=False):
        """ get some reference gas statistics for the system """

        if self.raw.method == "GC":
            self.gcstats(verbose)

        elif self.raw.method == "QC-TILDAS" or self.raw.method == "CRDS":
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

                    tk_val.pop(0)


        mean = numpy.average(mr_val)
        sd = numpy.std(mr_val, ddof=1)
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
            print("Precision (%% of assigned m.r.)         :   %7.3f" % (pr))
            print()

        else:
            fmt = "%-22s %s  %8.3f %8.3f %8.3f %5d"
            print(fmt % (self.raw.filename, self.adate.strftime("%Y %m %d %H %M %S"), mean, sd, pr, nref))
