
# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for handling configuration file for insitu data processing
"""

import sys
import datetime
import fnmatch
from collections import namedtuple
from dateutil.parser import parse

import ccg_utils


##################################################################
class InsituConfig:
    """
    Class for handling configuration file for in-situ data processing.

    Args:
        stacode : three letter station code
        gas : gas formula, e.g. 'co2'
        system : system name, e.g. 'pic', 'lgr'... (optional)
        configfile : Use non-standard configuration file (optional)

    Methods:
        get(key, date) : Get configuration value for 'key' on date
        getint(key, date) : Get integer configuration value for 'key' on date
        getfloat(key, date) : Get float configuration value for 'key' on date
        getboolean(key, date) : Get boolean configuration value for 'key' on date
        get_rules(key) : Get all configuration rules for 'key'.

    """

    BOOLEAN_STATES = {'1': True, 'yes': True, 'true': True, 'on': True,
                      '0': False, 'no': False, 'false': False, 'off': False}

    def __init__(self, stacode, gas, system=None, configfile=None):

        self.gas = gas
        self.stacode = stacode
        self.system = system

        if configfile is None:
            if sys.platform == "darwin":
                cfile = "/Volumes/ccg/insitu/insitu.conf"
            else:
                cfile = "/ccg/insitu/insitu.conf"
        else:
            cfile = configfile

        self.rules = self._read_config(cfile)


    #------------------------------------------------------------------
    def get(self, key, date, default=None):
        """ return string value for key on date """

        for rule in self.rules:
            if rule.key == key and rule.sdate <= date < rule.edate:
                return rule.value

#        if default is not None:
        return default

#        raise ValueError("key '%s' doesn't exist in configuration" % key)

    #------------------------------------------------------------------
    def getboolean(self, key, date):
        """ return boolean value for key on date """

        value = self.get(key, date)
        if value.lower() not in self.BOOLEAN_STATES:
            raise ValueError('Not a boolean: %s' % value)
        return self.BOOLEAN_STATES[value.lower()]

    #------------------------------------------------------------------
    def getint(self, key, date, default=None):
        """ return integer value for key on date """

        value = self.get(key, date, default)
        if value is not None:
            try:
                return int(value)
            except ValueError as e:
                raise ValueError('Not an integer: %s' % value) from e

        return value

    #------------------------------------------------------------------
    def getfloat(self, key, date):
        """ return float value for key on date """

        value = self.get(key, date)
        try:
            return float(value)
        except ValueError as e:
            raise ValueError('Not a float: %s' % value) from e

    #------------------------------------------------------------------
    def get_rules(self, key):
        """ get list of rules that match key """

        tmp = [rule for rule in self.rules if rule.key == key]

        return tmp

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
    def _read_config(self, configfile):
        """
        Read flagging data from the flagging file.
        Store data as a list of namedtuples.

        Filter the rules based on station code and gas species.
        More filtering is done in the find_rules() method.
        """

        Rules = namedtuple('rule', ['gas', 'site', 'inst', 'sdate', 'edate', 'key', 'value'])

        rules = []
        lines = ccg_utils.cleanFile(configfile, True)
        for line in lines:
            a = line.split(None, 6)
            [gas, site, instid, sdate, edate, key, value] = a

            # skip rules that aren't for this site or gas
            if not self._check_rule(self.gas.upper(), gas.upper()): continue
            if not self._check_rule(self.stacode.upper(), site.upper()): continue
            if not self._check_rule(self.system.upper(), instid.upper()): continue

            if sdate == "*":
                sdate = datetime.datetime(1900, 1, 1)
            else:
                sdate = parse(sdate)

            if edate == "*":
                edate = datetime.datetime(2100, 1, 1)
            else:
                edate = parse(edate)

            t = (gas, site, instid, sdate, edate, key, value)
            rules.append(Rules._make(t))

        return rules



if __name__ == "__main__":

    cf = InsituConfig("cao", "CO2", "picarro")
    for r in cf.rules:
        print(r)

    print('==============')
    r = cf.get_rules('stds')
    for row in r:
        print(row)

    dt = datetime.datetime(2005, 6, 1)
    print("for date", dt)
    s = cf.get("method", dt)
    print('method', s)
    s = cf.get("stds", dt).split()
    print('stds', s)
    s = cf.get("reference", dt) #.split()
    print('reference', s)
    r = cf.get_rules('break')
    for row in r:
        print(row)

#    dt = datetime.datetime(1983, 12, 1)
#    s = cf.getboolean("cams", dt)
#    print(s)

#    dt = datetime.datetime(1983, 12, 1)
#    s = cf.get("stds", dt)
#    print(s)
