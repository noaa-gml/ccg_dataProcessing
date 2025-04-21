
# vim: tabstop=4 shiftwidth=4 expandtab
"""
#
# Automated Methane Instrument Evaluation (AMIE)
#
# Developed:  December 1991 - kam
#
# Modified:   March 2003 - kam
#             See Tier 4 (Peak Height Percent Variability)
#
# Modified:   March 2006 - kam
#             Added Tier 6 (Flow Rate)
#
# Modified:   May 24, 2006 - kam
# Change in logic.  Disregard any flags that may
# have been assigned in the processing code.
# If the sample meets all AMIE requirements for
# system stability AND has an assigned default
# value (-999.99) then assign an asterisk (*)
# rejection flag.
#
# Modified:   August 20, 2010 - kwt
#             Results string format changed to handle
#             up to 6 characters for instrument id.
#             Needed to change flag position in string.
#
# Modified:   October 2010 -kwt
#             Converted to python
#
# Modified:   December 2014 -kwt
#             Converted to python class
# Modified:   January 2020 - kwt
              python 3 compatible
              take advantage of result namedtuple in changeFlag()
              get flow rate from seperate qc file; no longer in raw file

# Ken Masarie
# NOAA GMD Carbon Cycle
# kenneth.masarie@noaa.gov
#
#
# AMIE parameters are initialized from an init file.
#
"""
from __future__ import print_function

import sys

from ccg_dates import intDate
import ccg_utils

DEFAULT = -9
HOURS23 = 23 * 60 * 60


# where elements are in raw data tuple
TYPE = 0
PORT = 1
DATE = 2
PEAK_HEIGHT = 3
PEAK_AREA = 4
RETENTION_TIME = 5
BCODE = 6
FLOW = 7

##############################################################################
class amie:
    """ amie processing.
    Note that amie only changes the flag element in the passed in 'results' list
    """

    def __init__(self, stacode, config, raw, results):

        if len(results) == 0 or len(raw) == 0: return

        self.stacode = stacode.lower()
        self.index = 0
        self.config = config

        dt = raw.date.iloc[0]
        firstdate = intDate(dt.year, dt.month, dt.day, dt.hour)
        dt = raw.date.iloc[-1]
        lastdate = intDate(dt.year, dt.month, dt.day, dt.hour)

        initfile = "/ccg/src/insitu/amie.init"
        self.init = self.read_amieinit(initfile, self.stacode, firstdate, lastdate)

        self.do_amie(raw, results)

    #-------------------------------------------------------------------------
    def do_amie(self, raw, results):

#        for i, (stype, port, date, ph, pa, rt, flag, mode, bc, comment) in enumerate(raw):
        df = raw[raw.smptype=='SMP']
        for row in df.itertuples():

            i = row.Index
#            if stype == "REF":
#                continue


            (mr_ht, mr_ar, flag) = self.find_result(results, row.date)

            # Get the correct init values for this date
            (time_gap, pk_width_diff, pkht_percent_diff, ret_time_diff, flow_min) = self.get_init(row.date)



            ################################################
            # TIER 1 Baseline Code
            ################################################
            bcodes = self.config.get('baseline_codes', row.date)
            if row.bc not in bcodes:
                self.changeFlag(results, self.index, "b")
                continue

            ################################################
            # TIER 2 Analysis Time Gap
            ################################################
            r1 = DEFAULT
            s0 = DEFAULT
            r2 = DEFAULT

            if i-1 >= 0: r1 = self.convert2spm(raw.date[i-1])
            s0 = self.convert2spm(row.date)
            if i+1 < len(raw): r2 = self.convert2spm(raw.date[i+1])

            amieflag = self.analysis_time_edit(time_gap, r1, s0, r2, flag)
            if amieflag != ".":
                self.changeFlag(results, self.index, amieflag)
                continue

            ################################################
            # TIER 3 Peak Width Variability
            ################################################
            r1 = DEFAULT
            s0 = DEFAULT
            r2 = DEFAULT

            if i-1 >= 0: r1 = self.compute_pkwd(raw.ph[i-1], raw.pa[i-1])
            s0 = self.compute_pkwd(row.ph, row.pa)
            last_sample = 1
            if i+1 < len(raw):
                r2 = self.compute_pkwd(raw.ph[i+1], raw.pa[i+1])
                last_sample = 0

            amieflag = self.peak_width_edit(pk_width_diff, r1, s0, r2, flag, last_sample)
            if amieflag != ".":
                self.changeFlag(results, self.index, amieflag)
                continue

            ################################################
            # TIER 4 Reference Peak Height Variability
            ################################################
            #
            # Cannot assume R-S-R-S ...
            #
            ra = []
            rb = []
            #
            # Consider 3 REFerences preceding sample (if available).
            #
            k = 0
            j = i
            while k < 3:
                if raw.smptype[j] == "REF":
                    rb.append(raw.iloc[j])
                    k = k + 1
                j = j - 1
                if j < 0: break


            #
            # Consider 3 REFerences following sample (if available).
            #
            k = 0
            j = i
            while k < 3:
                if raw.smptype[j] == "REF":
                    ra.append(raw.iloc[j])
                    k = k + 1
                j = j + 1
                if j >= len(raw): break

            last_sample = 0
            if len(ra) == 0: last_sample = 1

            amieflag = self.reference_pkht_edit(pkht_percent_diff, rb, ra, flag, last_sample)
            if amieflag != ".":
                self.changeFlag(results, self.index, amieflag)
                continue

            ################################################
            # TIER 5 Retention Time Variability
            ################################################
            r1 = DEFAULT
            s0 = DEFAULT
            r2 = DEFAULT

            if i-1 >= 0: r1 = self.getRT(raw.rt[i-1])
            s0 = self.getRT(row.rt)
            last_sample = 1
            if i+1 < len(raw):
                r2 = self.getRT(raw.rt[i+1])
                last_sample = 0

            amieflag = self.retention_time_edit(ret_time_diff, r1, s0, r2, flag, last_sample)
            if amieflag != ".":
                self.changeFlag(results, self.index, amieflag)
                continue

            ################################################
            # TIER 6 Check flow rate of R-S-R
            ################################################
            r1 = DEFAULT
            s0 = DEFAULT
            r2 = DEFAULT

# flow rate is no longer in raw files.  Need to fix by looking in qc files
#            if i-1 >= 0: r1 = self.getFR(raw[i-1])
#            s0 = self.getFR(raw[i])
#            if i+1 < len(raw): r2 = self.getFR(raw[i+1])

# FIX
#            amieflag = self.FlowRate(flow_min, r1, s0, r2)
#            if amieflag != ".":
#                self.changeFlag(results, self.index, amieflag)
#                continue

            ################################################
            # TIER 7 ?
            ################################################
            #
            # If AMIE determines the system is stable but
            # the processing code has assigned a default
            # mixing ratio then assign an asterisk (*)
            # rejection flag.
            ################################################
            if mr_ht < -999 or mr_ar < -999:
                self.changeFlag(results, self.index, "*")


    #-------------------------------------------------------------------------
    def read_amieinit(self, initfile, stacode, firstdate, lastdate):
        """
        read AMIE initialization file
        Keep only the lines that match the station code,
        and have start and stop dates that bracket the data.
        site     start       stop    by  time_gap pk_wth_diff pkht_per_diff  ret_time_diff  flow_rate
        MLO  2001 03 25 2003 11 05 adate        15      0.015            5.0         0.0201      60
        """

        data = ccg_utils.cleanFile(initfile)

        init = []
        for line in data:

            a = line.split()
            site = a[0]
            if site.lower() == stacode:
                syr = int(a[1])
                smon = int(a[2])
                sday = int(a[3])
                eyr = int(a[4])
                emon = int(a[5])
                eday = int(a[6])
                stype = a[7]
                timegap = float(a[8])
                pwdiff = float(a[9])
                pkdiff = float(a[10])
                ret = float(a[11])
                flow = float(a[12])

                startdec = intDate(syr, smon, sday, 0)
                stopdec = intDate(eyr, emon, eday, 0)
                if startdec > stopdec:
                    print("** Error in amie init file.  Start date (%s-%s-%s) after end date (%s-%s-%s)" % (syr, smon, sday, eyr, emon, eday))
                    continue

                if (startdec < firstdate and stopdec >= firstdate) or (startdec >= firstdate and startdec <= lastdate):
                    init.append((site, startdec, stopdec, stype, timegap, pwdiff, pkdiff, ret, flow))

        return init


    #-------------------------------------------------------------------------
    def find_result(self, results, date):
        """
        Find the mixing ratio result for given date and time
        self.index is an index in the results array for the last found entry.
        Remember this so we don't have to start over from 0 each time,
        and it is used in changeFlag().
        results is a list of namedtuple('result', ['stacode', 'date', 'mf', 'std', 'unc', 'n', 'flag', 'sample', 'comment'])
        """

        while self.index < len(results):
            row = results[self.index]

            if row.date == date:
                return (row.mf, row.stdv, row.flag)

            self.index = self.index + 1

        print("Amie error: Can't find date in results:", date, file=sys.stderr)
        sys.exit()

    #-------------------------------------------------------------------------
    def get_init(self, date):
        """ Get amie init values for a given date. """

        intdate = intDate(date.year, date.month, date.day, 0)

        for (site, start, end, stype, timegap, pwdiff, pkdiff, ret, flow) in self.init:
            if intdate >= start and intdate <= end:
                return (timegap, pwdiff, pkdiff, ret, flow)

        print("Amie error: Inconsistency between raw file and initfile for date", date, file=sys.stderr)
        print("  Amie init data found was:", file=sys.stderr)
        for line in self.init:
            print(line, file=sys.stderr)
        sys.exit()

    #-------------------------------------------------------------------------
    def changeFlag(self, results, index, newflag):
        """ Replace the first character in the results flag with new character. """

#        (sta, date, mrh, mra, n, flag, smp) = results[index]
        flag = results[index].flag
        flg = newflag + flag[1] + flag[2]
#        results[index] = (sta, date, mrh, mra, n, flg, smp)
        # we need to keep results as namedtuple
        results[index] = results[index]._replace(flag=flg)

    #-------------------------------------------------------------------------
    def convert2spm(self, date):
        """ convert hour and minute (analysis time) to seconds past midnight """

        spm = date.hour*3600 + date.minute*60

        return spm

    #-------------------------------------------------------------------------
    def compute_pkwd(self, ph, pa):
        """ compute peak width of chromatogram """

        z = 0.0
        if ph > 0:
            z = pa / (ph*60)

        return z

    #-------------------------------------------------------------------------
    def getFR(self, line):
        """ Return Flow Rate (cc/min) """

        flow = line[FLOW]

        return flow

    #-------------------------------------------------------------------------
    def getRT(self, rt):
        """ Return Retention Time (sec) """

        return rt / 60.0

    #-------------------------------------------------------------------------
    def analysis_time_edit(self, cond, r1, s0, r2, flag):
        """
        function:        analysis_time_edit()                            *
          return:        AMIE flag                                       *
          purpose:       flags ambient samples that do not meet          *
                         the analysis time gap requirement assigned.     *
                                                                         *
                         TIER 2                                          *
                                                                         *
                         EDIT FOR TIME-OF-DAY DISCREPANCIES              *
                                                                         *
         Key to second order edit flags                                  *
                                                                         *
         t       This flag is assigned in the following 3 cases.         *
                                                                         *
                 (i)  IF the sample has come to this point with a        *
                      'blank' flag                                       *
                                                                         *
                      AND  if either the time difference between the     *
                           1st ref time and the sample time is           *
                           > TIME_GAP minutes                            *
                      OR   if the time difference between the 2nd ref    *
                           and the sample time is > TIME_GAP minutes.    *
                                                                         *
                (ii)  IF the sample has come to this point with a        *
                      '<' flag                                           *
                                                                         *
                      AND  the time difference between the 1st ref time  *
                           and the sample time is > TIME_GAP minutes.    *
                                                                         *
               (iii)  IF the sample has come to this point with a        *
                      '>' flag                                           *
                                                                         *
                      AND  the time difference between the 2nd ref time  *
                           and the sample time is > TIME_GAP minutes.    *
        """

        if flag == '..<':
            if s0 > r1:
                if (s0 - r1) > 60 * cond:
                    return 't'
            else:
                if (s0 - r1) > (-1 * ((HOURS23) + (60 - cond) * 60)):
                    return 't'

        if flag == '...':
            if s0 > r1:
                if (s0 - r1) > 60 * cond:
                    return 't'
            else:
                if (s0 - r1) > (-1 * (HOURS23 + (60 - cond) * 60)):
                    return 't'

            if r2 > s0:
                if (r2 - s0) > 60*cond:
                    return 't'
            else:
                if (r2 - s0) > (-1 * (HOURS23 + (60 - cond) * 60)):
                    return 't'

        if flag == '..>':
            if r2 > s0:
                if (r2 - s0) > 60*cond:
                    return 't'
            else:
                if (r2 - s0) > (-1 * (HOURS23 + (60 - cond) * 60)):
                    return 't'

        return '.'

    #-------------------------------------------------------------------------
    def peak_width_edit(self, cond, r1, s0, r2, flag, last_sample):
        """
        function:       peak_width_edit()                               *
          return:       AMIE flag                                       *
         purpose:       flags ambient samples that do not meet          *
                        the assigned peak width requirement.            *
                                                                        *
                        TIER 3                                          *
                                                                        *
                        PEAK WIDTH VARIABILITY                          *
                                                                        *
        Key to third order edit flags                                   *
                                                                        *
        +       This flag is assigned in the following 3 cases.         *
                                                                        *
                (i)  IF the sample has come to this point with a        *
                     'blank' flag                                       *
                                                                        *
                     AND  if either the absolute difference between     *
                          the 1st ref peak width and the sample peak    *
                          width is >= PK_WTH_DIFF                       *
                     OR   if the absolute difference between the 2nd    *
                          ref peak width and the sample peak width      *
                          is >= PK_WTH_DIFF.                            *
                                                                        *
               (ii)  IF the sample has come to this point with a        *
                     '<' flag                                           *
                                                                        *
                     AND  the absolute difference between the 1st       *
                     ref peak width and the sample peak width is        *
                           >= PK_WTH_DIFF.                              *
                                                                        *
              (iii)  IF the sample has come to this point with a        *
                     '>' flag                                           *
                                                                        *
                     AND  the absolute difference between the 2nd       *
                     ref peak width and the sample peak width is        *
                     >= PK_WTH_DIFF.                                    *
        """

        if flag == '..<':
            if abs(s0 - r1) >= cond: return '+'

        if flag == '...':
            if abs(s0 - r1) >= cond: return '+'
            if not last_sample:
                if abs(r2 - s0) >= cond: return '+'

        if flag == '..>':
            if abs(r2 - s0) >= cond: return '+'

        return '.'

    #-------------------------------------------------------------------------
    def reference_pkht_edit(self, cond, rb, ra, flag, last_sample):
        """
         function:       reference_pkht_edit()                           *
           return:       AMIE flag                                       *
          purpose:       flags ambient samples that do not meet the      *
                         assigned reference peak height requirement.     *
                                                                         *
        #   modification:  This tier was changed in March 2003.          *
                         It was discovered that it has been possible     *
                         (for quite some time now) for raw files to      *
                         have missing REF or ambient samples.  Thus,     *
                         the ..< and ..> flags now have a slightly       *
                         different meaning.  They may be assigned        *
                         if a bracketing reference sample has a bad      *
                         baseline code (as before) OR if there is no     *
                         bracketing reference, i.e, there exist two      *
                         consecutive ambient samples (see, for example,  *
                         ../mlo_data/raw/2002/2002-01-16.ch4.  This      *
                         possibility required the introduction of two    *
                         additional flags ('(' and ')').                 *
                                                                         *
                         The '(', '[', and '{' flags will always be      *
                         accompanied by a '>' flag in the 3rd column.    *
                                                                         *
                         The ')', ']', and '}' flags will always be      *
                         accompanied by a '<' flag in the 3rd column.    *
                                                                         *
                                                                         *
                         TIER 4                                          *
                                                                         *
                 REFERENCE PEAK HEIGHT PERCENT DIFFERENCES               *
                                                                         *
         Key to fourth order edit flags                                  *
                                                                         *
         %       Bracketing ref peak height difference is > PKHT_PER_DIFF*
                                                                         *
         (       Bracketing ref peak height difference is > PKHT_PER_DIFF*
                 BUT there is a missing REF sample, e.g, S-R-S-S-R-S.    *
                                                               ^         *
                                                                         *
         [       2nd bracketing ref peak height and ref peak height      *
                 before 1st bracketing ref peak have > PKHT_PER_DIFF.    *
                                                                         *
         {       2nd bracketing ref peak height and two ref peak heights *
                 before 1st bracketing ref peak have > PKHT_PER_DIFF.    *
                 Needed to look at this ref peak height because ref      *
                 peak preceding 1st bracket ref peak had a bad baseline  *
                 code.                                                   *
                                                                         *
         )       Bracketing ref peak height difference is > PKHT_PER_DIFF*
                 BUT there is a missing REF sample, e.g, S-R-S-S-R-S.    *
                                                             ^           *
                                                                         *
         ]       1st bracketing ref peak height and ref peak height      *
                 following 2nd bracketing ref peak have > PKHT_PER_DIFF. *
                                                                         *
         }       1st bracketing ref peak height and two ref peak heights *
                 following 2nd bracketing ref peak have > PKHT_PER_DIFF. *
                 Needed to look at this ref peak height because ref      *
                 peak following 2nd bracket ref peak had a bad baseline  *
                 code.                                                   *
                                                                         *
         #       Insufficient number of ref gases to properly evaluate   *
                 the validity of the mixing ratio.                       *
        """

        if flag == '..<':

            if len(ra) == 0 and not last_sample: return '#'

            phb1 = rb[0][PEAK_HEIGHT]

            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = ra[0]
            bcs = self.config.get('baseline_codes', date)
            if bc in bcs:
                if (abs(phb1 - ph) / phb1) * 100 > cond:
#                    print('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@')
                    return ')'
                else:
                    return '.'

            if len(ra) <= 1: return '#'

            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = ra[1]
            bcs = self.config.get('baseline_codes', date)
            if bc in bcs:
                if (abs(phb1 - ph) / phb1) * 100 > cond:
                    return ']'
                else:
                    return '.'

            if len(ra) <= 2: return '#'

            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = ra[2]
            bcs = self.config.get('baseline_codes', date)
            if bc in bcs:
                if (abs(phb1 - ph) / phb1) * 100 > cond:
                    return '}'
                else:
                    return '.'

        if flag == '...':
            # Make sure we have following references.  Won't have any
            # if this is the last sample of the input data.
            if not last_sample:
                pkht_b = rb[0][PEAK_HEIGHT]
                pkht_a = ra[0][PEAK_HEIGHT]

                if (abs(pkht_b - pkht_a) / pkht_b) * 100 > cond:
                    return '%'

        if flag == '..>':

            if len(rb) == 0: return '#'

            pha1 = ra[0][PEAK_HEIGHT]

            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = rb[0]
            bcs = self.config.get('baseline_codes', date)
            if bc in bcs:
                if (abs(ph - pha1) / ph) * 100 > cond:
                    return '('
                else:
                    return '.'

            if len(rb) <= 1: return '#'

            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = rb[1]
            bcs = self.config.get('baseline_codes', date)
            if bc in bcs:
                if (abs(ph - pha1) / ph) * 100 > cond:
                    return '['
                else:
                    return '.'

            if len(rb) <= 2: return '#'

            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = rb[2]
            bcs = self.config.get('baseline_codes', date)
            if bc in bcs:
                if (abs(ph - pha1) / ph) * 100 > cond:
                    return '{'
                else:
                    return '.'

        return '.'

    #-------------------------------------------------------------------------
    def retention_time_edit(self, cond, r1, s0, r2, flag, last_sample):
        """
         function:       retention_time_edit()                           *
           return:       AMIE flag                                       *
          purpose:       flags ambient samples that do not meet the      *
                         assigned reference peak height requirement.     *
                                                                         *
                         TIER 5                                          *
                                                                         *
                         RETENTION TIME VARIABILITY                      *
                                                                         *
         Key to fifth order edit flags                                   *
                                                                         *
         ~       This flag is assigned in the following 3 cases.         *
                                                                         *
                 (i)  IF the sample has come to this point with a        *
                      'blank' flag                                       *
                                                                         *
                      AND  if either the absolute difference between     *
                           the 1st ref retention time and the sample     *
                           retention time is > RET_TIME_DIFF minutes     *
                      OR   if the absolute difference between the 2nd    *
                           ref retention time and the sample retention   *
                           time is > RET_TIME_DIFF minutes.              *
                                                                         *
                (ii)  IF the sample has come to this point with a        *
                      '<' flag                                           *
                                                                         *
                      AND  the absolute difference between the 1st       *
                      ref retention time and the sample retention        *
                            time is > RET_TIME_DIFF minutes.             *
                                                                         *
               (iii)  IF the sample has come to this point with a        *
                      '>' flag                                           *
                                                                         *
                      AND  the absolute difference between the 2nd       *
                      ref retention time and the sample retention        *
                      time is > RET_TIME_DIFF minutes.                   *
        """

        if flag == '..<':
            if abs(s0 - r1) > cond: return '~'

        if flag == '...':
            if abs(s0 - r1) > cond: return '~'
            if not last_sample:
                if abs(r2 - s0) > cond: return '~'

        if flag == '..>':
            if abs(r2 - s0) > cond: return '~'

        return '.'

    #-------------------------------------------------------------------------
    def FlowRate(self, cond, r1, s0, r2):
        """
         function:       FlowRate()                                      *
           return:       AMIE flag                                       *
          purpose:       flags ambient samples that do not meet the      *
                         minimum flow rate requirement.                  *
                                                                         *
                         TIER 6                                          *
                                                                         *
                         FLOW RATE MINIMUM                               *
                                                                         *
         Key to sixth order edit flags                                   *
                                                                         *
         F       Flow rate of either bracketing ref gas < FLOW_MIN       *
                                                                         *
         f       Flow rate of sample gas is < FLOW_MIN.                  *

        """

        if r1 > DEFAULT and r1 < cond: return 'F'
        if r2 > DEFAULT and r2 < cond: return 'F'
        if s0 > DEFAULT and s0 < cond: return 'f'

        return '.'
