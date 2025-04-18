# vim: tabstop=4 shiftwidth=4 expandtab

from __future__ import print_function

"""
Class for using the inst_usage_history database table.
Used to get the instrument code for a site and gas on
a specific date.
"""

import datetime

import ccg_dbutils

###########################################################################
class instrument:
    """
    Args:
        stacode : Station letter code
        gas : gas (co2, ch4, ...)
        system : system name, e.g. 'ndir', 'lgr', ...

    Example::

        inst = instrument("BRW", "CO2", "LGR")
        instcode = inst.getInstrumentId(date)

    If the system name is not included, then it's possible
    to not get the instrument code you really want during times
    where there were overlapping systems (brw, mlo).

    If the system is not included, you'll get the 'official' instrument code,
    the one that is used for mole fraction data that is released to the public.

    """

    def __init__(self, stacode, gas, system=None):

        self.stacode = stacode.upper()
        self.gas = gas.upper()
        self.system = system

        db = ccg_dbutils.dbUtils()
        gasnum = db.getGasNum(gas)
        sitenum = db.getSiteNum(stacode)


        sql = "SELECT start_date, end_date, inst_num, id "
        sql += "FROM inst_usage_history,inst_description "
        sql += "WHERE site_num=%s and parameter_num=%d and inst_usage_history.inst_num=inst_description.num " % (sitenum, gasnum)

        # system should be one of 'gc', 'ndir', 'lgr', 'pic'
        if system is not None:
            sql += "AND system='%s' " % system.lower()

        sql += "ORDER BY start_date "
#        print(sql)

        self.inst_list = db.doquery(sql)

        # mysql returns a string for date if it's default, i.e. '0000-00-00 00:00:00'
        # Need to convert this to datetime
        if self.inst_list:
            for row in self.inst_list:
                if isinstance(row['end_date'], str) or row['end_date'] is None:
                    row['end_date'] = datetime.datetime.max

        # temporary entry until towers instruments are in the instrument history table
#        if stacode.lower() == "lef":
#            if system.lower() == "lcr":
#                self.inst_list.append(Inst._make((datetime.datetime(1900,1,1), datetime.datetime(2100, 12, 31), 99, "lcr-1")))
#            if system.lower() == "lgr":
#                self.inst_list.append(Inst._make((datetime.datetime(1900,1,1), datetime.datetime(2100, 12, 31), 100, "lgr-1")))


    #-----------------------------------------
    def getInstrumentId(self, dt):
        """ Return the instrument id for a given date.

        Will match the first available instrument for the date,
        so for overlap system periods, the 'system' argument should
        be specified on creation of instrument class
        """

        if self.inst_list is not None:
            for row in self.inst_list:
                if row['start_date'] <= dt < row['end_date']:
                    return row['id']

        return None

    #-----------------------------------------
    def getInstrumentNumber(self, dt):
        """ Return the instrument id for a given date.

        Will match the first available instrument for the date,
        so for overlap system periods, the 'system' argument should
        be specified on creation of instrument class
        """

        if self.inst_list is not None:
            for row in self.inst_list:
                if row['start_date'] <= dt < row['end_date']:
                    return row['inst_num']

        return None

    #-----------------------------------------
    def getInstrumentDates(self, num):
        """ Get the start and end dates for a given instrument number """

        for row in self.inst_list:
            if row['inst_num'] == num:
                return (row['start_date'], row['end_date'])

        return (None, None)

    #-----------------------------------------
    def getInstrumentCode(self, num):
        """ Get the instrument code for given instrument number """

        for row in self.inst_list:
            if row['inst_num'] == num:
                return row['id']

        return None
        


if __name__ == "__main__":


    date = datetime.datetime(2024, 2, 12)
    inst = instrument("lef", "co2")
    print(inst.stacode, inst.gas, inst.system)
    for i in inst.inst_list:
        print(i)
    inst_id = inst.getInstrumentId(date)
    print(inst_id)
    sys.exit()

    date = datetime.datetime(1993, 8, 21)
    inst = instrument("brw", "co")
    print(inst.stacode, inst.gas, inst.system)
    for i in inst.inst_list:
        print(i)

#    sys.exit()


    date = datetime.datetime(2016, 5, 31, 23, 59)

    inst = instrument("brw", "co2")
    print(inst.stacode, inst.gas, inst.system)
    inst_id = inst.getInstrumentId(date)
    print("id on", date, "is", inst_id)
    for i in inst.inst_list:
        print(i)

    date = datetime.datetime(2017, 1, 1)

    inst = instrument("lef", "co2", "lgr")
    print(inst.stacode, inst.gas, inst.system)
    inst_id = inst.getInstrumentId(date)
    print(inst_id)
    for i in inst.inst_list:
        print(i)

    date = datetime.datetime(2021, 5, 31, 23, 59)
    inst = instrument("bld", "co2", "magicc-3")
    inst_id = inst.getInstrumentId(date)
    print("instrument for bld magicc-3 co2 is", inst_id)
