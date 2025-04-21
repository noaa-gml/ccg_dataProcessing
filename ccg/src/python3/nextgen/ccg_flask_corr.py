
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Determine corrections to apply to flask data
"""
from __future__ import print_function

import sys
import fnmatch
import datetime

import ccg_dates
import ccg_utils



class flaskCorrections:
    """ Class for determining correction value to apply to flask data.
    Currently only used for CO2, but could be used for other gases if needed.
    """

    def __init__(self, corrections_file, sample_data, analyzer_id, adate, debug=False):

        self.corrections_file = corrections_file
        self.sample_data = sample_data
        self.analyzer_id = analyzer_id
        self.idate = ccg_dates.intDate(adate.year, adate.month, adate.day, adate.hour)
        self.debug = debug

        # Each entry in list has the format
        # (startdec, stopdec, site, by, flaskids, method, sysid, basis, function, tzero, np, params)
        self.corrections = self._read_corrections()

    #--------------------------------------------------------------------------
    def getCorrection(self, mr, event, adate):
        """
        Find the correction to apply.
        Returns a float value, 0 if no correction.
        """

        if len(self.corrections) == 0:
            return 0

        line = self._find_sample_data(event)
        if not line:
            return 0

        samplesite = line['code']
# Start applying corrections to tst flasks 26 Apr 2023
#        if samplesite == "TST":
#            return 0

        sampleid = line['flaskid']
        samplemethod = line['method']
        sampledate = line['date']
        sdate = ccg_dates.intDate(sampledate.year, sampledate.month, sampledate.day, 0)

        c = 0.0
        for (startdec, stopdec, site, by, flaskid, method, inst, basis, function, tzero, np, params) in self.corrections:
            if by == "sdate":
                dec = sdate
            if by == "adate":
                dec = self.idate

            if basis == "sdate":
                value = ccg_dates.decimalDate(sampledate.year, sampledate.month, sampledate.day)
            if basis == "adate":
                value = ccg_dates.decimalDate(adate.year, adate.month, adate.day, adate.hour, 0)
            if basis == "value":
                value = mr
            if basis == "stime":
                value = self.storage_time(adate, sampledate)

            if (startdec <= dec <= stopdec
               and fnmatch.fnmatch(samplesite, site)
               and fnmatch.fnmatch(sampleid, flaskid)
               and fnmatch.fnmatch(samplemethod, method)
               and fnmatch.fnmatch(self.analyzer_id, inst)
               and mr >= 0):

                if function == "polynomial":
                    c += ccg_utils.poly(value - tzero, params)

        if self.debug:
            print("   Correction for event", event, "analyzed on", adate, "mole fraction %.3f" % mr, "is %.3f" % c)

        return c

    #--------------------------------------------------------------------------
    def _find_sample_data(self, event):
        """ Find the flask sample data for the given event """

        evt = int(event)
        if evt in self.sample_data:
            return self.sample_data[evt]

#        evt = int(event)
#        for row in self.sample_data:
#            if row['event_number'] == evt:
#                return row

        print("flaskCorrections: Bad event number %s." % event, file=sys.stderr)
        return None


    #--------------------------------------------------------------------------
    @staticmethod
    def storage_time(adate, sdate):
        """ Calculate the number of days between analysis date and sample date.
        adate is a datetime object,
        sdate is a date object.
        convert sdate to datetime and calculate timedelta
        """

        diff = adate - datetime.datetime(sdate.year, sdate.month, sdate.day)

        return diff.days

    #--------------------------------------------------------------------------
    def _read_corrections(self):
        """
        Read correction data from the corrections file.
        Keep only the lines necessary for this system and the time period being processed.
        Store data as a list of tuples.
        """

        #*   1977 11 04 1978 08 31 adate  *  *  L2  adate  polynomial  1977.8411 3  1.12776 -2.46375 1.3325

        corr = []
        lines = ccg_utils.cleanFile(self.corrections_file, False)
        for line in lines:
            [site, syr, smon, sday, eyr, emon, eday, by, flaskids, method, sysid, basis, function, tzero, np, therest] = line.split(None, 15)
            sdate = datetime.datetime(int(syr), int(smon), int(sday))
            edate = datetime.datetime(int(eyr), int(emon), int(eday))
            tzero = float(tzero)
            np = int(np)

            if np < 0 or np > 10:
                print("** Error in corrections file.  Bad # of parameters (%d; max is %d)." % (np, 10), file=sys.stderr)
                continue

            if by not in ("sdate", "adate"):
                print("** Error in corrections file.  Bad data type %s" % (by), file=sys.stderr)
                continue

            if basis not in ("sdate", "adate", "value", "stime"):
                print("** Error in corrections file.  Bad basis type %s" % (basis), file=sys.stderr)
                continue

            if function not in ("polynomial", "exponential"):
                print("** Error in corrections file.  Bad function type %s" % (function), file=sys.stderr)
                continue

            startdec = ccg_dates.intDate(sdate.year, sdate.month, sdate.day, 0)
            stopdec = ccg_dates.intDate(edate.year, edate.month, edate.day, 23)
            if startdec > stopdec:
                fmt = "** Error in corrections file.  Start date (%s) after end date (%s)"
                print(fmt % (sdate.strftime("%Y-%m-%d"), edate.strftime("%Y-%m-%d")), file=sys.stderr)
                continue

            if by == "adate":
                if self.idate < startdec or self.idate > stopdec:
                    continue

            if by == "sdate":
                # check if any sample event dates fall within date range
                useit = False
                for t in self.sample_data.values():
                    sampledate = t['date']
                    sd = ccg_dates.intDate(sampledate.year, sampledate.month, sampledate.day, 0)
#                    if sd >= startdec and sd <= stopdec:
                    if startdec <= sd <= stopdec:
                        useit = True
                        break

                if not useit:
                    continue

            if fnmatch.fnmatch(self.analyzer_id, sysid):
                params = [float(c) for c in therest.split()]
                corr.append((startdec, stopdec, site, by, flaskids, method, sysid, basis, function, tzero, np, params))

        return corr
