# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for applying corrections to in-situ data

Usage:
    corr = insituCorrections(stacode, corrections_file)
    cval = corr.getCorrection(mf, date)

        Get correction value for mole fraction value 'mf' on date
"""

import ccg_utils
import ccg_dates

class insituCorrections:
    """ Class for applying corrections to in-situ data """

    def __init__(self, stacode, corrections_file):

        self._read_corrections(stacode, corrections_file)

    #--------------------------------------------------------------
    def _read_corrections(self, stacode, corrfile):
        """
        # Read correction rules from the corrections file.
        # keep only the lines for this station and the time period being processed.
        # Store data as a list of tuples.
        """

        self.rules = []

        a = ccg_utils.cleanFile(corrfile, showError=False)

        for line in a:

            [site, syr, smon, sday, shr, eyr, emon, eday, ehr, basis, alg, tzero, np, therest] = line.split(None, 13)
            if site.lower() != stacode.lower():
                continue

            tzero = float(tzero)
            np = int(np)
            if np < 0 or np > 10:
                print("** Error in corrections file.  Bad # of parameters (%d; max is %d)." % (np, 10))
                continue

            if basis not in ("date", "value"):
                print("** Error in corrections file.  Bad basis type %s" % (basis))
                continue

            startdec = ccg_dates.intDate(int(syr), int(smon), int(sday), int(shr))
            stopdec = ccg_dates.intDate(int(eyr), int(emon), int(eday), int(ehr))

            params = []
            for c in therest.split():
                params.append(float(c))

            self.rules.append((startdec, stopdec, basis, alg, tzero, np, params))


    #--------------------------------------------------------------
    # Calculate the correction value
    #--------------------------------------------------------------
    def getCorrection(self, mr, adate):
        """ Get correction value for mole fraction value 'mr' on date """

        corr = 0

        if len(self.rules) == 0: return 0

        date = ccg_dates.intDate(adate.year, adate.month, adate.day, adate.hour)
        for (start, end, basis, alg, tz, np, params) in self.rules:

            if start <= date <= end:
                if basis.lower() == "value":
                    value = float(mr)

                if basis.lower() == "date":
                    value = ccg_dates.decimalDate(adate.year, adate.month, adate.day, adate.hour, 0, 0)
                    value = value - tz

                c = ccg_utils.poly(value, params)
                corr = corr + c
#                if self.debug:
#                    print("  correction value:", value, "correction parameters:", params, "correction value:", c)

    #       print corr
        return corr
