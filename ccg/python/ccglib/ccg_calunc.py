
# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for detrmining the reproducibility (scale transfer uncertainty)
in tank calibrations

Given a gas, the calibration system, instrument and calibrations date,
it reads a file with uncertainty values and returns the 
reproducibility value for that calibration.
"""
from __future__ import print_function

import datetime
import fnmatch
from collections import namedtuple
from dateutil.parser import parse

import ccg_utils


#########################################################################################
class CalUnc:
    """
    Args:
        rulefile (str) : Name of file with flagging rules.  None means use default file.
        debug (bool) : If True, print extra debugging messages.

    Example::

        calunc = ccg_calunc.CalUnc(rulefile=None, debug=False)
        unc = calunc.getUnc(gas, system, instrument, adate, mf)

    Default rulefile is "/ccg/cals/cal_unc.dat"
    """

    def __init__(self, rulefile=None, debug=False):

        self.debug = debug

        if rulefile:
            self.rulefile = rulefile
        else:
            self.rulefile = "/ccg/cals/cal_unc.dat"

        if self.debug:
            print("Rule file is", self.rulefile)

        self._read_rules()

    #------------------------------------------------------------------
    def _read_rules(self):
        """
        Read uncertainty data rules from the rule file.
        Store data as a list of namedtuples.
        """

        names = ['gas', 'system', 'inst', 'sdate', 'edate', 'basis', 'minval', 'maxval', 'unc']
        CalRules = namedtuple('rule', names)

        self.cal_rules = []
        lines = ccg_utils.cleanFile(self.rulefile, True)
        for line in lines:
            [gas, system, instid, sdate, edate, basis, minval, maxval, unc] = line.split()

            if sdate == "*":
                sdate = datetime.datetime.min
            else:
                sdate = parse(sdate)

            if edate == "*":
                edate = datetime.datetime.max
            else:
                edate = parse(edate)

            if minval == "*":
                minval = -1e+34
            else:
                minval = float(minval)

            if maxval == "*":
                maxval = 1e+34
            else:
                maxval = float(maxval)

            gas = gas.lower()
            system = system.lower()
            instid = instid.lower()
            unc = float(unc)

            t = (gas, system, instid, sdate, edate, basis, minval, maxval, unc)
            if self.debug: print(t)
            self.cal_rules.append(CalRules._make(t))


    #------------------------------------------------------------------
    def _find_rules(self, gas, system, inst, adate, mf):
        """ Find the rules that apply to this data.
        All checks of the rules must be True for the rule to be applied.
        """

        rules = []
        for rule in self.cal_rules:

            if not self._check_rule(gas, rule.gas): continue
            if not self._check_rule(system, rule.system): continue
            if not self._check_rule(inst, rule.inst): continue
            if adate < rule.sdate: continue
            if adate > rule.edate: continue
            if not rule.minval <= mf < rule.maxval: continue

            rules.append(rule)

        return rules

    #------------------------------------------------------------------
    @staticmethod
    def _check_rule(string, pattern):
        """ Check if given string matches the given pattern """

        if pattern.startswith("!"):
            if "|" in pattern:
                # if string doesn't match any elements in pattern, return True
                return True not in [fnmatch.fnmatch(str(string), s) for s in pattern[1:].split("|")]

            return not fnmatch.fnmatch(str(string), pattern[1:])

        if "|" in pattern:
            # if string matches any elements in pattern, return True
            return True in [fnmatch.fnmatch(str(string), s) for s in pattern.split("|")]

        return fnmatch.fnmatch(str(string), pattern)

    #------------------------------------------------------------------
    def getUnc(self, gas, system, inst_id, date, mf):
        """ Find the uncertainty for the given parameters.

        Args:
            gas (str) : gas species
            system (str) : system name
            inst_id (str) : instrument id
            date (date or datetime) : date of uncertainty
            mf (float) : mole fraction value. Uncertainties can be mole fraction dependent.
        """

        # date must be a datetime object
        if isinstance(date, datetime.date):
            dt = datetime.datetime(date.year, date.month, date.day)
        else:
            dt = date

#        print(gas, system, inst_id, dt, mf)
        # find the rules that apply
        rules = self._find_rules(gas.lower(), system.lower(), inst_id.lower(), dt, mf)

        # if no matches, return default value
        if len(rules) == 0:
            return -99.9

        # return value from first rule (should usually be only 1)
        return rules[0].unc


###########################################################################3
if __name__ == "__main__":

    calunc = CalUnc()

#    for t in calunc.cal_rules:
#        print(t)

    dt = datetime.datetime(2020, 6, 6)
    unc = calunc.getUnc("co2", "co2cal-1", "S4", dt, 420)

    print(unc)
