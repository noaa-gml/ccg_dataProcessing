
# vim: tabstop=4 shiftwidth=4 expandtab
"""
class for determining uncertainty values to apply to in-situ or flask data

Uses the 'master' uncertainty file, which has values for all gases for
flask and observatory.

"""
from __future__ import print_function

import sys
import fnmatch
import datetime
from collections import namedtuple
from math import sqrt
from dateutil.parser import parse

from ccg_utils import cleanFile


class dataUnc:
    """
    class for determining uncertainty values to apply to in-situ or flask data

    Usage:

        myunc = dataUnc(project, gas, site, system, uncfile=None, debug=False)
        unc = myunc.getUncertainty(site, adate, value)

    Args:

        project : measurement project, either 'flask', 'cals', or 'insitu'
        gas : gas formula
        site : site code
        system : system id string
        uncfile : file name with uncertainty rules
        debug : print debugging information if True

    Methods:

        self.getUncertainty(site, adate, value, method=None, inst=None, system=None)

        Arguments are criteria for finding matching rules:

        site (str) : site code
        adate (datetime) : analysis date
        value : float
        method (str, optional) : sampling method
        inst (str, optional) : instrument id
        system (str, optional) : system name

    The uncertainty rule file contains rules for flask, cals, and insitu projects,
    and for all analysis sites and systems and gases. All rules are contained in this one file.
    The class creation arguments will pre-filter the uncertainty rules.  The final rules to be used
    are determined in getUncertainty() for an individual measurement.

    """

    def __init__(self, project, gas, site=None, system=None, uncfile=None, debug=False):

        self.project = project
        self.debug = debug
        self.gas = gas
        self.system = system
        self.site = site

        if uncfile is None:
            self.unc_file = "/ccg/flask/unc_master.conf"
        else:
            self.unc_file = uncfile

        # Each entry in list has the format
        # (startdate, stopdate, site.lower(), by, method, sysid, inst, min_mf, max_mf, value)
        self.rules = self._read_unc()


    #------------------------------------------------------------------
    def getUncertainty(self, site, adate, mf=None, method=None, inst=None, system=None):
        """ return uncertainty value for given criteria """

        uncs = self.getUncertainties(site, adate, mf, method, inst, system)
        uncval = self.getTotalUncertainty(uncs)

        return uncval

    #------------------------------------------------------------------
    # Routine for getting uncertainty value.
    #------------------------------------------------------------------
    def getUncertainties(self, site, adate, mf=None, method=None, inst=None, system=None):
        """ Find uncertainty values that match input criteria.

        Args:
            site (str) : site code
            adate (datetime) : analysis date
            mf (float) : mole fraction, used if uncertainy method is 'value'
            method (str) : sample method
            inst (str) : analyzer id string
            system (str) : system name e.g. 'pic', 'ndir', 'magicc-1'

        Returns:
            params : list of uncertainty values to be combined for total uncertainty

        The input parameters must match a line from the uncertainty file to be used.
        """

        if isinstance(adate, datetime.date):
            adate = datetime.datetime(adate.year, adate.month, adate.day)

        params = []

        if not self.rules:
            return []

        for rule in self.rules:

            if self.debug:
                print()
                print("Date:          Look for", adate, "between", rule.startdate, rule.stopdate, ":", (rule.startdate <= adate <= rule.stopdate))
                if mf is not None:
                    print("Mole Fraction: Look for", mf, "between", rule.minval, rule.maxval, ":", (rule.minval <= mf <= rule.maxval))
                print("site:          Look for", site.lower(), "matches", rule.site, ":", self._check_rule(site.lower(), rule.site))
                print("System:        Look for", system, "matches", rule.system, ":", self._check_rule(system, rule.system))
                print("Analyzer:      Look for", inst, "matches", rule.inst, ":", self._check_rule(inst, rule.inst))
                print("Method:        Look for", method, "matches", rule.method, ":", self._check_rule(method, rule.method))

            if mf is not None:
                if not rule.minval <= mf <= rule.maxval: continue
            if not rule.startdate <= adate <= rule.stopdate: continue
            if not self._check_rule(site.lower(), rule.site): continue
            if not self._check_rule(system, rule.system): continue
            if not self._check_rule(inst, rule.inst): continue
            if not self._check_rule(method, rule.method): continue

            if self.debug: print("--- match --- value is", rule.unc)

            if rule.unc_type == "value":
                params.append(rule.unc)
            elif rule.unc_type == "ratio":
                params.append(rule.unc * mf)

        return params


    #------------------------------------------------------------------
    @staticmethod
    def getTotalUncertainty(uncs):
        """ Get total uncertainty, which is sqrt of sum of squares
        of each individual uncertainty.
        """

        val = 0
        for unc in uncs:
            val += unc * unc

        if val == 0:
            val = -999.99
        else:
            val = sqrt(val)

        return val


    #------------------------------------------------------------------
    @staticmethod
    def _check_rule(string, pattern):
        """ Check if given string matches the given pattern """

        if string is None: return True

        if pattern.startswith("!"):
            if "|" in pattern:
                # if string doesn't match any elements in pattern, return True
                return True not in [fnmatch.fnmatch(str(string), s) for s in pattern[1:].split("|")]

            return not fnmatch.fnmatch(str(string), pattern[1:])

        if "|" in pattern:
            # if string matches any elements in pattern, return True
            return True in [fnmatch.fnmatch(str(string), s) for s in pattern.split("|")]

        return fnmatch.fnmatch(str(string), pattern)


    #-----------------------------------------------------------------
    def _read_unc(self):
        """
        Read uncertainty data from the uncertainty file.
        Store data as a list of tuples.
        """

        # CO2    * magicc-3   2019-03-01           *   adate  PC2    *  300 8000  0.02 # repeatability
        # columns are:
        #    project
        #    gas
        #    site
        #    system
        #    start date ......... start date for uncertainty
        #    end date ........... stop date for uncertainty
        #    instrument code .... instrument id
        #    sample method ...... Sampling method (flasks only)
        #    minimum value ...... Minimum mole fraction value to apply uncertainty to
        #    maximum value ...... Maximum mole fraction value to apply uncertainty to
        #    uncertainty ........ The uncertainty value
        #    uncertainty type ... The uncertainty type, either 'value' or 'ratio'
        #    #
        #    comment ............ Description of uncertainty

        names = ['startdate', 'stopdate', 'site', 'method', 'system', 'inst', 'minval', 'maxval', 'unc', 'unc_type']
        Rules = namedtuple('rule', names)

        unc = []
        lines = cleanFile(self.unc_file, True)  # remove comments and blank lines
        for line in lines:
            try:
                [project, gas, site, sysid, sdate, edate, inst, method, min_mf, max_mf, value, value_type] = line.split()
            except ValueError as e:
                print("** Error reading uncertainty rule line:\n'%s'\n" % line, e, file=sys.stderr)
                continue

            # skip rules that aren't used

            # required arguments, but self.gas can still be None
            if self.project.lower() != project.lower(): continue
            if self.gas is not None:
                if not self._check_rule(self.gas.upper(), gas.upper()): continue

            # optional arguments
            if self.site is not None:
                if not self._check_rule(self.site.upper(), site.upper()): continue

            if self.system is not None:
                if not self._check_rule(self.system.upper(), sysid.upper()): continue

            if min_mf == "*":
                min_mf = -1e34
            else:
                min_mf = float(min_mf)
            if max_mf == "*":
                max_mf = 1e34
            else:
                max_mf = float(max_mf)
            value = float(value)

            if sdate == "*":
                startdate = datetime.datetime(1900, 1, 1)
            else:
                startdate = parse(sdate)

            if edate == "*":
                stopdate = datetime.datetime(2100, 1, 1)
            else:
                stopdate = parse(edate)

            if startdate > stopdate:
                print("** Error in uncertainty file.  Start date (%s) after end date (%s)" % (startdate, stopdate))
                continue

            if value_type not in ['value', 'ratio']:
                print("** Error in uncertainty file.  Invalid uncertainty type (%s)" % (value_type))
                continue

            t = (startdate, stopdate, site.lower(), method, sysid, inst, min_mf, max_mf, value, value_type)
            unc.append(Rules._make(t))

        if self.debug:
            if len(unc) > 0:
                for t in unc:
                    print(t)
            else:
                print("No uncertainty rules found.")

        return unc

#####################################################
if __name__ == '__main__':


#    uncfile = "unc_master.txt"
#    uncfile = "uncertainty.n2o"
#    uncfile = "uncertainty.co"
    myunc = dataUnc("flask", "co2", system="magicc-3", uncfile="/ccg/flask/unc_master_test.conf", debug=True)
#    myunc = dataUnc("co2", system="magicc-1", debug=True)
    print(len(myunc.rules))
    print("-----------")

    date = datetime.datetime(2019, 8, 1)
    mr = 400
#    uncvals = myunc.getUncertainties("BRW", date, mr, "P", "L8")
    uncvals = myunc.getUncertainties("BRW", date, mr, inst='L8', system='magicc-1')
#    uncvals = myunc.getUncertainties("MLO", date, mr, system='pic')
#    uncs = myunc.getUncertainties(sitecode, adate, value, method, inst)

    print(uncvals)
    uncval = myunc.getTotalUncertainty(uncvals)
    print((date, uncval))

    uncval = myunc.getUncertainty("BRW", date, mr, inst='L8', system='magicc-1')
    print(uncval)

#    n = 9
#    val = unc.getHourUncertainty(uncs, n)
#    print((date, val))

#    date = datetime.datetime(1997,8,1,12,30,0)
#    mr = 320.5
#    mr = 1985.5
#    val = unc.getUncertainty("BRW", date, mr, "P", "H4")
#    print date, val
