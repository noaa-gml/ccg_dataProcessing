
# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for dealing with the tank_history database table,
which contains usage information for tanks used on various systems,
especially for observatories.

"""

import datetime
from operator import attrgetter
from collections import namedtuple, defaultdict

import ccg_dbutils
import ccg_db_conn

##################################################################
# make this a function so that tankhistory class can be readonly
def insert_tank_history(stacode, system, serial_number, label, start_date, gases, comment=""):
    """ Insert a new entry into the tank_history database table

    Args:
        stacode (str) : station code
        system (str) : system name
        serial_number (str) : tank serial number
        label (str) : tank usage label
        start_date (str or datetime) : start date of tank usage
        gases (list) : list of gases that tank is used for
        comment (str) : comment
    """

    sql = "insert into tank_history set "
    sql += "site='%s', " % stacode
    sql += "system='%s', " % system
    sql += "serial_number='%s', " % serial_number
    sql += "label='%s', " % label
    sql += "start_date='%s', " % start_date
    sql += "gas='%s', " % ",".join(gases)
    sql += "comment='%s'" % comment

    db = ccg_db_conn.ProdDB(db='reftank')
    db.doquery(sql)


##################################################################
class tankhistory:
    """ Class for holding tank history information.

    Args:
        gas     : gas species
        location : sitecode, e.g. brw, mlo ...
        label : find entries with this tank label, e.g. R0, S1, ...
        system : system name, e.g. ndir, lgr, picarro ...
        date : Only include information where the tank is active on this date.
               Can be datetime object or valid date string.

    Attributes:
        data : A list of namedtuples with information on the reference gases.
            Field names are ('site', 'system', 'gas', 'serial_number', 'label', 'start_date', 'fill_code')

    """

    def __init__(self, gas=None, location=None, system=None, label=None, date=None, debug=False):
        """
        Initialize a tank history object.

        parameter:
            gas: the gas species
            location: set to specify location from tank history table.
            system: system name to use
            label: get only entries that have this label
            date: get entries that are active on this date (startdate <= date <= enddate)

        """

        self.valid = True
        self.debug = debug
        self.gas = gas
        self.location = location
        self.system = system
        self.label = label
        self.activedate = date

        self.db = ccg_dbutils.dbUtils(database='reftank')

        results = self._get_results()
        # a namedtuple object to hold results.
        field_names = ['site', 'system', 'gas', 'serial_number', 'label', 'start_date', 'end_date', 'fill_code']
        self.Row = namedtuple('row', field_names)

        self.data = []
        if results:
            for row in results:
                fillcode = self._get_fill_code(row)
                row['fill_code'] = fillcode

                end_date = self._get_end_date(results, row)
                row['end_date'] = end_date

    #            t = row + (fillcode,)
    #            self.data.append(self.Row._make(t))
                self.data.append(self.Row(**row))


    #--------------------------------------------------------------------------
    def filterByDate(self, startdate, enddate=None):
        """ Find entries that have start_date >= given startdate.

        Need to save, for each tank label, the last entry before start date, and any after start date
        """

        tmpdata = defaultdict(list)
        # save the data by the tank label
        for t in self.data:
            tmpdata[t.label].append(t)

        data = []
        for key in list(tmpdata.keys()):
            tmpdata[key].sort(key=attrgetter('start_date')) # sort by date
            tmplist = []

            for t in tmpdata[key]:
                if t.start_date < startdate:
                    if enddate:
                        if t.start_date < enddate:
                            tmplist = [t]       # last one before start date and before end date
                    else:
                        tmplist = [t]       # last one before start date
                else:
                    if enddate:
                        if t.start_date < enddate:
                            tmplist.append(t)   # any after start date and before enddate
                    else:
                        tmplist.append(t)   # any after start date

            data.extend(tmplist)    # save entries for this tank label

        return data

    #--------------------------------------------------------------------------
    def filterByLabel(self, label):
        """ Find entries that have label

        """

        data = []
        for t in self.data:
            if t.label == label:
                data.append(t)

        return data

    #--------------------------------------------------------------
    def search(self, site, serial_number, start_date, label):
        """ search entries that match given arguments """

        for row in self.data:
            if (row.site == site
                and row.serial_number == serial_number
                and row.start_date == start_date
                and row.label == label):
                return row

        return None

    #--------------------------------------------------------------
    def _get_results(self):
        """ Get the results from the tank_history database """

        sql = "select site, system, gas, serial_number, label, start_date from tank_history "

        whereclause = []
        if self.location:
            whereclause.append("site='%s'" % self.location)
        if self.gas:
            whereclause.append("find_in_set('%s', gas)" % self.gas)

        if self.system:
            whereclause.append("system='%s'" % self.system)
        if self.label:
            s = ["'%s'" % l for l in self.label.split(",")]
            whereclause.append("label in (%s)" % ",".join(s))

        if self.activedate:
            whereclause.append("start_date<='%s'" % self.activedate)

        if len(whereclause) > 0:
            sql += "WHERE "
            sql += " AND ".join(whereclause)

        sql += " order by site,label,start_date"

        # modifications needed to sql if date set
        # we want to order by date descending for each label, so most recent
        # start date before active date is first
        # Then the group by label will select the first row for each group
        # the 'gas' part of the group by is needed to separate the same label
        # used by multiple gases.
        # The limit 99999 is needed to keep the descending sort
        if self.activedate:
            sql = "select * from (" + sql + " desc limit 999999) as zzz group by gas, label"

        if self.debug:
            print(sql)

#        results = self.db.dbQueryAndFetch(sql)
        results = self.db.doquery(sql)

        return results

    #--------------------------------------------------------------
    def _get_fill_code(self, data):
        """ Get fill code for a tank entry """

        code = self.db.getFillCode(data['serial_number'], data['start_date'])

        return code

    #--------------------------------------------------------------
    @staticmethod
    def _get_end_date(data, row):
        """ as a convenience, find the end date for a tank history entry """

        rows = [t for t in data if t['system']==row['system'] and t['label']==row['label']]

        for i, t in enumerate(rows):
            if t['start_date'] == row['start_date']:
                if i == len(rows)-1:
                    dt = datetime.datetime.now()
                    end_date = datetime.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute)
                else:
                    end_date = rows[i+1]['start_date']

        return end_date

#if __name__ == "__main__":
#    dt = datetime.datetime(2022,6,6)
#    hist = tankhistory("CO2", "BRW", system="lgr", date=dt)
#    for t in hist.data:
#        print(t.system, t.serial_number, t.label, t.start_date, t.end_date)
