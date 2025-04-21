# vim: tabstop=4 shiftwidth=4 expandtab

"""
# class to read and handle the qc configuration rules
# for converting the tower 'raw' data to separate
# qc text files
"""

from __future__ import print_function

import datetime
import fnmatch
from collections import namedtuple
from dateutil.parser import parse

import ccg_utils

class qcrules:
    """Class to handle qc configuration rules for creating qc text files.

    The class reads a text file with rules about how to name and
    convert the values in the towers raw .dat files, which are csv
    files containing all the data measured at a towers site.

    Args:
        stacode (str): Station three letter code.
        section (str): Section label to use in configuration file.
        cfgfile (str): Optional. Name of configuration file to use.

    Attributes:
        rules (list): List of namedtuples containing the qc rules.

    Methods:
        find_rule(): Given a date and field name, return the rule
            that matches.
    """

    def __init__(self, stacode, gas=None, inst=None, section=None, cfgfile=None):

        self.stacode = stacode.lower()
        self.gas = None if gas is None else gas.lower()
        self.inst = None if inst is None else inst.lower()
        self.section = None if section is None else section.lower()

        if cfgfile is None:
            rule_file = "/ccg/insitu/qc.conf"
        else:
            rule_file = cfgfile

        self.rules = self._read_rules(rule_file)


    #------------------------------------------------------------------
    def find_rule(self, date, fieldname):
        """ Find the rules that apply to this row of data.

        All checks of the rules must be True for the rule to be applied.

        Args:
            date (datetime): The desired date
            fieldname (str): The name of a column in the tower raw csv file.

        Returns:
            rule: The namedtuple rule that matches the data and fieldname.
                Returns None if no match found.
        """

        for rule in self.rules:
#            print(rule)

#            if not self._check_rule(inst, rule.inst): continue
#            if not self._check_rule(gas, rule.gas): continue
#            if fieldname.lower() not in rule.rawfield: continue
            if fieldname.lower() != rule.rawfield: continue
            if date < rule.sdate: continue
            if date > rule.edate: continue

            return rule

        return None

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


    #------------------------------------------------------------------
    def _read_rules(self, rule_file):
        """
        Read flagging data from the flagging file.
        Store data as a list of namedtuples.

        Filter the rules based on station code and gas species.
        More filtering is done in the find_rules() method.
        """

        section = ""

        names = ['site', 'gas', 'inst', 'sdate', 'edate', 'rawfield', 'qcdir', 'cf', 'use_func']
        QCRules = namedtuple('rule', names)

        rules = []
        lines = ccg_utils.cleanFile(rule_file, True)
        for line in lines:
            params = line.strip()

            if line.startswith('[') and line.endswith(']'):
                section = line.lstrip('[').rstrip(']')
                section = section.lower()
                continue

#            print("section is", section, "self.section is", self.section)
            if section != self.section and self.section is not None: continue

            [site, gas, inst, sdate, edate, fieldname, qcdir, coefs] = params.split(None, 7)
            a = coefs.split()
            if len(a) > 1:
                cf = [float(x) for x in a]
                use_func = False
            else:
                cf = a[0]
                use_func = True

#            print(gas, inst, self.gas, self.inst)

            # skip rules that aren't for this site
            if not self._check_rule(self.stacode, site.lower()): continue
            if not self._check_rule(self.gas, gas.lower()): continue
            if not self._check_rule(self.inst, inst.lower()): continue


            if sdate == "*":
                sdate = datetime.datetime.min
            else:
                sdate = parse(sdate)

            if edate == "*":
                edate = datetime.datetime.max
            else:
                edate = parse(edate)

            t = (site, gas, inst, sdate, edate, fieldname.lower(), qcdir, cf, use_func)
            rules.append(QCRules._make(t))

        return rules

if __name__ == '__main__':

    qc = qcrules("lef", section='QC')
    for rule in qc.rules:
        print(rule)

    print("-------------")
    dt = datetime.datetime(2020, 6, 6, 12, 15, 30)
    rule = qc.find_rule(dt, "BPR1_Avg")
    print(rule)
