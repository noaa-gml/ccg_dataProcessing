
"""
#
# Automated Carbon Monoxide Instrument Evaluation (ACMIE)
#
# Developed:  April 2005 - Swapna Krishnan and kam (initially developed in IDL)
# Modified:   May 2005 - kam (converted from original IDL code)
#
# Modified:   May 24, 2006 - kam
# Change in logic.  Disregard any flags that may
# have been assigned in the processing code.
# If the sample meets all ACMIE requirements for
# system stability AND has an assigned default
# value (-999.99) then assign an asterisk (*)
# rejection flag.
#
#
# Modified:   December 2014 -kwt
#             Converted to python class
#
# Modified:   January 2020 -kwt
          python 3 compatible
          in getRefs changed '' to None, and changed checks
          for this value to check for None instead
#
# Modified:   July 2021 - kwt
          Treat raw as pandas dataframe instead of numpy array
              Changed return value of self.find_result to boolean
#
# Ken Masarie
# NOAA CMDL Carbon Cycle Greenhouse Gases
# kenneth.masarie@noaa.gov
#
# ACMIE parameters are initialized from an init file.
#
"""
from __future__ import print_function


import sys
import zipfile

from ccg_dates import intDate
import ccg_utils

# where elements are in raw data tuple
#(type, port, date, ph, pa, rt, bc, flow)
TYPE = 0
PORT = 1
DATE = 2
PEAK_HEIGHT = 3
PEAK_AREA = 4
RETENTION_TIME = 5
BCODE = 6
FLOW = 7


##########################################################################
class acmie:
    """ Automatic flagging of co gc data

    Input:
                raw - Data part of raw object, a pandas DataFrame
                results - mole fraction results, a list of namedtuples

        Output:
                The 'flag' part of results is changed
    """


    def __init__(self, stacode, config, raw, results, debug=False):

        if len(results) == 0 or len(raw) == 0: return

        self.stacode = stacode.lower()
        self.config = config
        self.index = 0
        self.gcfilelist = {}
        self.prevzipfile = ""
        self.gotzipfile = 0
        self.z = ""
        self.debug = debug

        dt = raw.date.iloc[0]
        firstdate = intDate(dt.year, dt.month, dt.day, dt.hour)
        dt = raw.date.iloc[-1]
        lastdate = intDate(dt.year, dt.month, dt.day, dt.hour)

        initfile = "/ccg/src/insitu/acmie.init"
        self.init = self.read_acmieinit(initfile, self.stacode, firstdate, lastdate)

        self.do_acmie(raw, results)


    #------------------------------------------------------------------------
    def do_acmie(self, raw, results):

        # skip reference gases
        df = raw[raw.smptype=="SMP"]
        for row in df.itertuples():

            # Brw before Jan 20, 1993 used only 2 working tanks, so we need to
            # do things differently then.

#            stds = self.config.get('stds', row.date)
#            nwork = len(stds)
            nwork = 3
            dd = intDate(row.date.year, row.date.month, row.date.day, 0)
            if self.stacode.upper() == "BRW" and dd < 1993012000: nwork = 2

            # find corresponding mixing ratio result for this sample
            found = self.find_result(results, row.date)
            if not found: continue


            # get acmie parameters for this date
            (time_gap, flow_min, ph_percent, pa_percent, pw_percent, rt_percent) = self.get_init(row.date)


            ################################################
            # TIER 1 Baseline Code
            # flag - 'b'
            ################################################
            bcodes = self.config.get('baseline_codes', row.date)
            if row.bc not in bcodes:
                self.changeFlag(results, self.index, "b")
                continue

            ################################################
            # TIER 2 Sample Port Number
            # flag - '+'
            ################################################
            #
            portlist = ["Line1", "Line2"]
            if row.label not in portlist:
                self.changeFlag(results, self.index, "+")
                continue

            # The rest of the checks don't work for early BRW
            # when using only 2 stds, so skip them.
            if nwork == 2: continue

            ################################################
            # Get the previous 3 reference gases, current sample and next 3 reference gases from raw list.
            refset = self.getRefs(raw, row.Index, bcodes)

            #
            ################################################
            # TIER 4 Check time gap between L-M-H-S-L-M-H
            # flag - 't'
            ################################################
            #
            acmieflag = self.TimeGap(time_gap, refset)
            if acmieflag != ".":
                self.changeFlag(results, self.index, acmieflag)
                if self.debug: print("acmie: time gap", acmieflag)
                continue

            #
            ################################################
            # TIER 5 Check flow rate of L-M-H-S-L-M-H
            # flag - 'f'
            ################################################
            #
# FIX
#            acmieflag = self.FlowRate(flow_min, refset)
#            if acmieflag != ".":
#                self.changeFlag(results, self.index, acmieflag)
#                continue

            #
            ################################################
            # TIER 6 Compare Pk Ht response of bracketing
            # L, M, and H standards.  Resp(3) < Resp(5) < Resp(7)
            # flag - '#'
            ################################################
            #
            acmieflag = self.PkHtResponse(refset)
            if acmieflag != ".":
                self.changeFlag(results, self.index, acmieflag)
                if self.debug: print("acmie: peak height response", acmieflag)
                continue

            #
            ################################################
            # TIER 7 Evaluate chromatograms for L-M-H-S-L-M-H
            # if they exist.  Here we are trying to determine
            # if each chromatogram's zero stays on-scale
            # flag - 'c'
            ################################################
            #
            # Chromatograms available beginning 1998-01-01
            #
            if row.date.year >= 1998:
                acmieflag = self.Chromatograms(refset, self.stacode)
                if acmieflag != ".":
                    self.changeFlag(results, self.index, acmieflag)
                    if self.debug: print("acmie: chromatogram", acmieflag)
                    continue

            #
            ################################################
            # TIER 8 Compare peak height percent variability
            # of bracketing standard gases  L-M-H-[S]-L-M-H
            # flag - 'h'
            ################################################
            #
            acmieflag = self.PeakVar(ph_percent, refset, PEAK_HEIGHT, 'h')
            if acmieflag != ".":
                self.changeFlag(results, self.index, acmieflag)
                if self.debug: print("acmie: peak height variability", acmieflag)
                continue


            #
            ################################################
            # TIER 9 Compare peak area percent variability
            # of bracketing standard gases  L-M-H-[S]-L-M-H
            # flag - 'a'
            ################################################
            #
            acmieflag = self.PeakVar(pa_percent, refset, PEAK_AREA, 'a')
            if acmieflag != ".":
                self.changeFlag(results, self.index, acmieflag)
                if self.debug: print("acmie: peak area variability", acmieflag)
                continue

            #
            ################################################
            # TIER 10 Compare peak width percent variability
            # of bracketing standard gases  L-M-H-[S]-L-M-H
            # flag - 'w'
            ################################################
            #
            acmieflag = self.PeakWidthVar(pw_percent, refset)
            if acmieflag != ".":
                self.changeFlag(results, self.index, acmieflag)
                if self.debug: print("acmie: peak width variability", acmieflag)
                continue

            #
            ################################################
            # TIER 11 Compare retention time percent
            # variability of L-M-H-S-L-M-H
            # flag - 'r'
            ################################################
            #
            acmieflag = self.RetTimeVar(rt_percent, refset)
            if acmieflag != ".":
                self.changeFlag(results, self.index, acmieflag)
                if self.debug: print("acmie: retention time percent", acmieflag)
                continue


    #    print gcfilelist

    #------------------------------------------------------------------------
    def read_acmieinit(self, initfile, stacode, firstdate, lastdate):
        """
        read ACMIE initialization file
        Keep only the lines that match the station code,
        and have start and stop dates that bracket the data.

        ACMIE information fields

        site .......... site
        start ......... start date
        stop .......... stop date
        by ............ date (sdate = sample date; adate = analysis date)
        time_gap ...... variability in consecutive analysis time gap (minutes)
        flow_rate ..... minimum sample cell flow rate (cc/min)
        pk_ht ......... abs. percent difference between L-M-H bracketing ref. gases (height)
        pk_ar ......... abs. percent difference between L-M-H bracketing ref. gases (area)
        pk_wd ......... abs. percent difference between L-M-H bracketing ref. gases (width)
        ret_time ...... abs. percent difference in consecutive analysis retention times

        site   start      stop      by   time_gap  flow_rate pk_ht  pk_ar  pk_wd  ret_time
        --- ---------- ---------- -----  --------  --------- -----  -----  -----  --------
        BRW  1900 01 01 1993 07 31 adate        9        0      3      4       3      2
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
                flow = float(a[9])
                ph = float(a[10])
                pa = float(a[11])
                pw = float(a[12])
                ret = float(a[13])

                startdec = intDate(syr, smon, sday, 0)
                stopdec = intDate(eyr, emon, eday, 0)
                if startdec > stopdec:
                    print("** Error in amie init file.  Start date (%s-%s-%s) after end date (%s-%s-%s)" % (syr, smon, sday, eyr, emon, eday))
                    continue

                if (startdec < firstdate and stopdec >= firstdate) or (startdec >= firstdate and startdec <= lastdate):
                    init.append((site, startdec, stopdec, stype, timegap, flow, ph, pa, pw, ret))


        return init

    #-------------------------------------------------------------------------
    def find_result(self, results, date):
        """
        Find the mixing ratio result for given date and time
        self.index is an index in the results array for the last found entry.
        Remember this so we don't have to start over from 0 each time,
        and it is used in changeFlag().
        """

#        print(results[self.index])
#result(stacode='MLO', date=datetime.datetime(2019, 2, 1, 0, 1), mf=85.939999999999998, std=0.0, unc=0, n=1, flag='..R', sample='Line1')
        for row in results[self.index:]:
#        for (sta, dt, mrh, mra, n, flag, smp) in results[self.index:]:

            if row.date == date:
#                return (mrh, mra, flag)
#                return (row.mf, row.std, row.flag)
                return True

            self.index = self.index + 1


        print("Acmie error: Can't find date in results:", date, file=sys.stderr)
        self.index = 0
        return False
#        return (None, None, None)

    #-------------------------------------------------------------------------
    def get_init(self, date):
        """ Get amie init values for a given date. """

        intdate = intDate(date.year, date.month, date.day, 0)

        for (site, start, end, stype, timegap, flow, ph, pa, pw, ret) in self.init:

            if intdate >= start and intdate <= end:
                return (timegap, flow, ph, pa, pw, ret)

        print("Acmie error: Inconsistency between raw file and initfile for date", date, file=sys.stderr)
        print("  Acmie init data found was:", file=sys.stderr)
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
        results[index] = results[index]._replace(flag=flg)


    #-------------------------------------------------------------------------
    def FlowRate(self, flow, refset):
        """
        Return a flow rate flag if any single refset member has a low flow rate.

        Flag Assignment: f
        """

        for line in refset:
            if line is None: continue
            if line[FLOW] < flow:
                return 'f'

        return '.'


    #-------------------------------------------------------------------------
    def TimeGap(self, gap, refset):
        """
        #
        # Time step between consecutive samples
        # should not exceed "gap"
        #
        # For each sample in "refset", evaluate elapsed time
        # to next consecutive sample.  Take into consideration
        # missing samples in a refset.
        #
        # Flag Assignment: t
        #
        """


        for ix in range(0, 7):
            if refset[ix] is None: continue
            for iy in range(ix+1, 7):
                if refset[iy] is None: continue

                t1 = refset[ix]
                t2 = refset[iy]

                # convert to minute of the day
                dt1 = t1[DATE].hour*60 + t1[DATE].minute
                dt2 = t2[DATE].hour*60 + t2[DATE].minute

    #            print dt1, dt2, gap*(iy-ix)
                if dt2-dt1 > gap * (iy - ix): return 't'

        return '.'

    #-------------------------------------------------------------------------
    def RetTimeVar(self, rt, refset):
        """
        Retention Time percent variability between
        consecutive samples should not exceed "ret"

        Evaluate retention time percent difference for each
        pair of consecutive samples in "refset".

        Flag Assignment: r
        """

        for ix in range(0, 7):
            if refset[ix] is None: continue
            for iy in range(ix+1, 7):
                if refset[iy] is None: continue

                rt1 = refset[ix][RETENTION_TIME]/60.0
                rt2 = refset[iy][RETENTION_TIME]/60.0

                if abs((rt2 - rt1)*100.0 / rt1) > rt: return 'r'
                break

        return '.'

    #-------------------------------------------------------------------------
    def PkHtResponse(self, refset):
        """
        Peak Height Response of standard gases should
        follow L < M < H or 3 < 5 < 7

        Flag Assignment: #
        """

        a = [(0, 1), (1, 2), (0, 2), (4, 5), (5, 6), (4, 6)]

        for (ix1, ix2) in a:
            if refset[ix1] is not None and refset[ix2] is not None:
                ph1 = refset[ix1][PEAK_HEIGHT]
                ph2 = refset[ix2][PEAK_HEIGHT]
                if ph1 >= ph2: return '#'

        return '.'


    #-------------------------------------------------------------------------
    def Chromatograms(self, refset, stacode):
        """
        gcfilelist is a dict with an entry for each gcfile, and the value
        is 0 if baseline is bad, 1 if good.
        prevzipfile is the previous zip file opened.
        gotzipfile tells whether we already have an opened zip file.
        All this logic is needed so we don't have to reopen and reread the
        zip files for the refset each time this function is called.
        Much much faster this way.

        If a chromatogram file exists, determine if zero drifts off-scale.

        Flag Assignment: c
        """

        for t in refset:

            if t is None: continue

            yr = t[DATE].year
            mo = t[DATE].month
            dy = t[DATE].day
            hr = t[DATE].hour
            mn = t[DATE].minute

            # Zip file archive directory and file name
            dirname = "/ccg/co/in-situ/%s_data/data/%d" % (stacode.lower(), yr)
            filename = "%s/%4d%02d%02d.zip" % (dirname, yr, mo, dy)
            # gcfile inside of zip file
            gcfile = "%4d%02d%02d%02d%02d.txt" % (yr, mo, dy, hr, mn)
            if gcfile in self.gcfilelist:
                val = self.gcfilelist[gcfile]
                if not val:
                    return 'c'

            else:

                if filename != self.prevzipfile:
                    try:
                        self.z.close()
                    except:
                        pass

    #                print file
                    if zipfile.is_zipfile(filename):
                        self.z = zipfile.ZipFile(filename)
                        self.gotzipfile = 1
                    else:
                        self.gotzipfile = 0

                self.prevzipfile = filename

                if self.gotzipfile:
                    try:
                        data = self.z.read(gcfile)
                    except KeyError:
                        continue

                    lines = data.split(b"\n")

                    # check every second (10 data points) and see if the signal is at 0
                    for i in range(4, len(lines)-10, 10):
                        s = 0
                        for x in range(0, 10):
                            s += int(lines[i+x])

                        if s == 0:
                            self.gcfilelist[gcfile] = 0
                            return 'c'

                    self.gcfilelist[gcfile] = 1

        return '.'

    #-------------------------------------------------------------------------
    def PeakVar(self, cond, refset, field, flag):
        """
        Peak Area or Height percent variability between bracketing
        L's and M's and H's should not exceed "cond".

        Flag Assignment: h
        """

        a = [(0, 4), (1, 5), (2, 6)]

        for (ix1, ix2) in a:
            if refset[ix1] is not None and refset[ix2] is not None:
                p1 = refset[ix1][field]
                p2 = refset[ix2][field]
                diff = abs((p2 - p1)*100.0 / p1)
                if diff > cond: return flag

        return '.'


    #-------------------------------------------------------------------------
    def PeakWidthVar(self, pkwd, refset):
        """
        Peak Width percent variability between bracketing
        L's and M's and H's should not exceed "pkwd".

        Flag Assignment: w
        """

        a = [(0, 4), (1, 5), (2, 6)]

        for (ix1, ix2) in a:
            if refset[ix1] is not None and refset[ix2] is not None:
                pa1 = refset[ix1][PEAK_AREA]
                pa2 = refset[ix2][PEAK_AREA]
                ph1 = refset[ix1][PEAK_HEIGHT]
                ph2 = refset[ix2][PEAK_HEIGHT]

                pw1 = pa1/(ph1*60.0)
                pw2 = pa2/(ph2*60.0)

                diff = abs((pw2 - pw1)*100.0 / pw1)
                if diff > pkwd: return 'w'

        return '.'

    #-------------------------------------------------------------------------
    def getRefs(self, raw, i, bcodes):
        """ Get the 3 preceeding references and 3 following references
        from the current sample.  Because sometimes the l,m,h may not
        be in that order (e.g. m,l,h), the list should be sorted by time.
        """

        s = []

        t1 = self.getPreceedingRef(raw, i, "L", bcodes)
        t2 = self.getPreceedingRef(raw, i, "M", bcodes)
        t3 = self.getPreceedingRef(raw, i, "H", bcodes)

        s.append(t1)
        s.append(t2)
        s.append(t3)

        s.append(raw.iloc[i])

        t1 = self.getFollowingRef(raw, i, "L", bcodes)
        t2 = self.getFollowingRef(raw, i, "M", bcodes)
        t3 = self.getFollowingRef(raw, i, "H", bcodes)

        s.append(t1)
        s.append(t2)
        s.append(t3)

    #    s2 = sorted(s, key=lambda tup: tup[1])

        return s

    #-------------------------------------------------------------------------
    def getPreceedingRef(self, raw, i, name, bcodes):
        """ Get the desired reference gas preceeding the sample """

        for j in range(1, 4):
            if i-j < 0: break
            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = raw.iloc[i-j]
            if port == name and bc in bcodes:
                return raw.iloc[i-j]

        return None

    #-------------------------------------------------------------------------
    def getFollowingRef(self, raw, i, name, bcodes):
        """ Get the desired reference gas following the sample """

        for j in range(1, 4):
            if i+j >= len(raw): break
            (stype, port, date, ph, pa, rt, flag, mode, bc, comment) = raw.iloc[i+j]
            if port == name and bc in bcodes:
                return raw.iloc[i+j]

        return None
