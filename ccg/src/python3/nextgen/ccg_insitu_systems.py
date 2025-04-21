
# vim: tabstop=4 shiftwidth=4 expandtab

"""
Class for using the 'systems.conf' file which contains information
about the insitu measurement systems,
such as site code, gas, time span, system abbreviation.

Example:

systems = system("BRW", "CO2")
dt = datetime.datetime(2000, 1, 1)
sysname = systems.get(dt)

"""

from __future__ import print_function
import sys
import datetime
from collections import namedtuple
from dateutil.parser import parse

import ccg_utils

###########################################################################
class system:
    """
    # Get a list of systems used at a station for a gas,
    # provide a method to get the instrument id for a given date

    mysql returns a string for date if it's default, i.e. '0000-00-00 00:00:00'
    Need to convert this to datetime
    """

    def __init__(self, stacode, gas):

        self.stacode = stacode.upper()
        self.gas = gas.upper()

        if sys.platform == 'darwin':
            configfile = "/Volumes/ccg/insitu/systems.conf"
        else:
            configfile = "/ccg/insitu/systems.conf"
        self.results = self._read_conf(configfile)

    #-----------------------------------------
    def _read_conf(self, cfgfile):
        """
        Read flagging data from the flagging file.
        Store data as a list of namedtuples.

        Filter the rules based on station code and gas species.
        More filtering is done in the find_rules() method.
        """

        names = ['gas', 'site', 'system', 'sdate', 'edate']
        Systems = namedtuple('systems', names)

        rules = []
        lines = ccg_utils.cleanFile(cfgfile, True)
        for line in lines:
            [site, gas,  sdate, edate, sysname] = line.split()

            # skip rules that aren't for this site or gas
            # wildcards not allowed.  gas and site must be set in conf file
            if self.gas.upper() != gas.upper(): continue
            if self.stacode.upper() != site.upper(): continue

            if sdate == "*":
                sdate = datetime.datetime.min
            else:
                sdate = parse(sdate)

            if edate == "*":
                edate = datetime.datetime.max
            else:
                edate = parse(edate)

            t = (gas, site, sysname, sdate, edate)
            rules.append(Systems._make(t))


        return rules


    #-----------------------------------------
    def get(self, dt):
        """ return all system names for a given date
        """

        names = []
        for row in self.results:
            if row.sdate <= dt < row.edate:
                names.append(row.system)

        return names

if __name__ == "__main__":

    date = datetime.datetime(2016, 5, 31, 23, 59)

    s = system("brw", "co2")
    print(s.stacode, s.gas)
    sysname = s.get(date)
    print(sysname)

    date = datetime.datetime(2017, 1, 1)

    s = system("brw", "co2")
    print(s.stacode, s.gas)
    sysname = s.get(date)
    print(sysname)
