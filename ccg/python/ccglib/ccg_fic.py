# vim: tabstop=4 shiftwidth=4 expandtab
"""
class for calculating flask-insitu differences
"""
from __future__ import print_function

import sys
import datetime
from collections import namedtuple

import ccg_db_conn


class fic:
    """ A class for obtaining flask-insitu differences.
        Usage:
            fic(site, startyear, endyear, gases, use_hourly_data)

            site - Three letter station code
            startyear - First year for differences
            endyear - Last year for differences
            gases - List of gases to get differences for
            use_hourly_data - Compare with hourly averaged insitu data. (Optional, default is False)

        Methods:
            print_results(gas=None) - print the results in a neat table format
                If gas is specified, print out data for that gas only, otherwise print
                data for all gases

            x, y = get_differences(gas, use_flagged_flask=False, use_flagged_insitu=False, method=None)
                Return two lists; dates, differences for the given gas
                Default is to not include flagged data.  To include flagged data,
                set use_flagged_flask or use_flagged_insitu to True.  If method is None, use all methods,
                else use only the flask sampling method given.

        Members:
            fdata - List of Namedtuple containing the flask-insitu difference data
                Format of tuple is
                namedtuple('flask', ['event', 'date', 'id', 'method', 'flask_values', 'insitu_values'])
                where
                    event - flask event number
                    date  - flask sample date
                    id    - flask sample id
                    method - flask sample method
                    flask_values - dict of tuples with gas as the key, (flask_value, flag) for the data
                    insitu_values - dict of tuples with gas as the key, (insitu_value, value_stdv, flag) for the data

             NOTE: If multiple flask measurements were made for a single flask, the namedtuple will
             contain only the last measurement made.

            methods - unique list of flask sample methods in fdata
    """

    def __init__(self, site, startyear, endyear, gases, use_hourly_data=False):

        self.site = site.lower()
        self.startyear = int(startyear)
        self.endyear = int(endyear)
        self.use_hourly_data = use_hourly_data

        self.db = ccg_db_conn.RO()

        sql = "select num from gmd.site where code='%s'" % self.site
        result = self.db.doquery(sql)
        sitenum = result[0]['num']


        # check that given gases are available for given site
        self.gases = []
        self.paramnums = []
        self.gasnums = {}
        for gas in gases:
            sql = "select num from gmd.parameter where formula='%s'" % gas
            result = self.db.doquery(sql)
            gasnum = result[0]['num']

            # check if gas is measured at site
            table = "insitu_data"
            if self.use_hourly_data:
                table = "insitu_hour"

            sql = "select * from %s where site_num=%d and parameter_num=%d limit 1" % (table, sitenum, gasnum)
            result = self.db.doquery(sql)
            if result is not None:
                self.gases.append(gas.lower())
                self.paramnums.append(gasnum)
                self.gasnums[gas.lower()] = gasnum
            else:
                print("%s not available at %s.  Skipping..." % (gas, site))

        self.fdata = []

        if len(self.gases) > 0:
            self.fdata = self._get_flask_data(sitenum)
            self.fdata = self._get_insitu_data(sitenum)

            self.methods = self._get_methods()


   #------------------------------------------------------------------------------------
    def _get_flask_data(self, sitenum):
        """ get the flask data.

        Result is a list of namedtuples
        The 'flask_values' member is a dict of tuples, with parameter number as key,
        and (value, flag) as value.
        """

        Row = namedtuple('flask', ['event', 'date', 'id', 'method', 'flask_values', 'insitu_values'])

        # first get list of flask data for time period desired

        self.sql = self.db.sql

        self.sql.initQuery()
        self.sql.table("flask_event e")
        self.sql.innerJoin("flask_data d on e.num=d.event_num")
        self.sql.innerJoin("gmd.site s on e.site_num=s.num")
        self.sql.innerJoin("gmd.parameter p on d.parameter_num=p.num")
        self.sql.col("e.num as event_number")
        self.sql.col("e.date as date")
        self.sql.col("e.time as time")
        self.sql.col("e.id as flaskid")
        self.sql.col("e.me as method")
        self.sql.col("d.parameter_num as parameter_num")
        self.sql.col("d.value as value")
        self.sql.col("d.flag as qcflag")
        self.sql.orderby("e.date")
        self.sql.orderby("e.time")
        self.sql.orderby("e.num")
        self.sql.orderby("d.parameter_num")

        self.sql.where("e.site_num=%s", sitenum)
#        self.sql.where("year(e.date) between %s and %s", (self.startyear, self.endyear))  # doesn't work
        self.sql.where("year(e.date) between %s and %s" % (self.startyear, self.endyear))
        self.sql.where("e.project_num=1")

        self.sql.wherein("d.parameter_num in", self.paramnums)

        result = self.db.doquery()


        prev_evnum = None
        data = []
        t = None
        for row in result:

            # new event number
            if row['event_number'] != prev_evnum:

                # save data for previous event
                if t is not None:
                    data.append(Row._make(t))

                # convert date, time to datetime and store data for this parameter
                date = row['date']
                time = row['time']
                dt = datetime.datetime(date.year, date.month, date.day) + time

                t = (
                    row['event_number'],
                    dt,
                    row['flaskid'],
                    row['method'],
                    {row['parameter_num']: (row['value'], row['qcflag'])},
                    None
                )

            # same event number, new parameter
            else:
                t[4][row['parameter_num']] = (row['value'], row['qcflag'])
            prev_evnum = row['event_number']

        if t is not None:
            data.append(Row._make(t))

        return data

   #------------------------------------------------------------------------------------
    def _get_insitu_data(self, sitenum):
        """ Get the insitu data for the times of the flask samples

        Use the closest entry for the same hour before the flask sample.
        If no values are available, then use the closest entry
        in the same hour after the flask sample.
        """

        data = []

        # loop through the flask data and find the matching insitu value
        for row in self.fdata:

            isdata = {}
            for paramnum in row.flask_values:

                # get the entry closest but before the flask time
                isdate, isval, isstdv, flag = self._query_insitu(sitenum, paramnum, row.date)
                if isval is not None:
                    isdata[paramnum] = (isdate, isval, isstdv, flag)

                else:
                    # try again in case minute < first available minute of hour
                    if not self.use_hourly_data:
                        isdate, isval, isstdv, flag = self._query_insitu2(sitenum, paramnum, row.date)
                        if isval is None:
                            isval = -999.99
                            isstdv = -999.99
                        isdata[paramnum] = (isdate, isval, isstdv, flag)

            # replace the default insitu_values of the tuple with data
            row = row._replace(insitu_values=isdata)
            data.append(row)

        return data

    #------------------------------------------------------------------------------------
    def _query_insitu(self, sitenum, paramnum, date):
        """ Query the database for the insitu value.

        If use_minute is True, find value for the closest minute before the flask sample.
        If use_minute is False, find the first available insitu value in the hour
        """

        if self.use_hourly_data:
            table = "insitu_hour"

            # get the hour that the flask was taken
            sdate = date.replace(minute=0, second=0)
        else:
            table = "insitu_data"

            # get the 5 minute block that the flask was taken
            minute = (date.minute // 5) * 5
            sdate= date.replace(minute=minute)
            sdate= sdate.replace(second=0)

        # get next 5 minute block after flask was taken
#        edate = sdate + datetime.timedelta(minutes=5)
        # query for the insitu value at the 5 minute block
        query = "SELECT date, value, std_dev, flag FROM %s " % table
#        query += "WHERE date between '%s' and '%s' " % (sdate, edate)
        query += "WHERE date='%s' " % (sdate)
        query += "AND site_num=%d " % sitenum
        query += "AND parameter_num=%d " % paramnum
        if not self.use_hourly_data:
            query += "AND target=0 "
        query += "ORDER BY date LIMIT 1 "
#        print(query)

        a = self.db.doquery(query)
        if a:
            isdate = a[0]['date']
            isval = float(a[0]['value'])
            issd = float(a[0]['std_dev'])
            flag = a[0]['flag']
        else:
            isdate = None
            isval = None
            issd = None
            flag = "..."

        return isdate, isval, issd, flag
        
    #------------------------------------------------------------------------------------
    def _query_insitu2(self, sitenum, paramnum, date):
        """ query the database for the insitu value closest to the given date 
        but within 1 hour of the flask date """

        table = "insitu_data"

        sdate = date + datetime.timedelta(hours=-1)
        edate = date - datetime.timedelta(hours=1)

        query = "SELECT date, value, std_dev, flag FROM %s " % table
        query += "WHERE date between '%s' and '%s' " % (sdate, edate)
        query += "AND site_num=%d " % sitenum
        query += "AND parameter_num=%d " % paramnum
        query += "AND target=0 "
        query += "ORDER BY ABS(TIMEDIFF('%s', date)) " % date
        query += "LIMIT 1"

#        print(query)

        a = self.db.doquery(query)
        if a:
            isdate = a[0]['date']
            isval = float(a[0]['value'])
            issd = float(a[0]['std_dev'])
            flag = a[0]['flag']
        else:
            isdate = None
            isval = None
            issd = None
            flag = "..."

        return isdate, isval, issd, flag

    #------------------------------------------------------------------------------------
    def _get_methods(self):
        """ Get a unique list of flask methods that are available """

        methods = []
        for row in self.fdata:
            if row.method not in methods:
                methods.append(row.method)

        return methods

    #------------------------------------------------------------------------------------
    def print_results(self, gas=None):
        """ Print the results.

        Output is a table of values looking like

          477423    1511-99 2020-06-30 20:23:00  P  415.36 ... 1871.46 ...  415.30 ... 1871.15 ...
          477424    2981-99 2020-06-30 20:23:00  P  415.41 ... 1871.54 ...  415.30 ... 1871.15 ...
          477497    1016-99 2020-07-07 20:11:00  S  415.54 ... 1881.13 ...  415.52 ... 1880.97 ...
          477498     975-99 2020-07-07 20:11:00  S  415.75 ... 1881.39 ...  415.52 ... 1880.97 ...

        Columns are
            flask event number,
            flask id,
            date,
            time,
            method,
            flask value gas 1,
            flask flag gas 1,
            flask value gas 2,
            flask flag gas 2,
            insitu value gas 1,
            insitu value stdv gas 1,
            insitu flag gas 1,
            insitu value gas 2,
            insitu value stdv gas 2,
            insitu flag gas 2
            ...

        TODO - Do some filtering based on flags
        """

        if len(self.fdata) == 0: return

        # if gas is specified, do only that gas, otherwise do all gases
        if gas is None:
            params = self.paramnums
        elif gas.lower() in self.gasnums:
            params = [self.gasnums[gas.lower()]]
        else:
            print("No data for gas", gas)
            return

        for row in self.fdata:
            print("%12d %10s %s %2s" % (row.event, row.id, row.date, row.method), end=' ')

            # print flask values
            for paramnum in sorted(params):
                if paramnum in row.flask_values:
                    print("%7.2f %3s" % row.flask_values[paramnum], end=' ')
                else:
                    print("-999.99 *..", end=' ')

            # print insitu values
            for paramnum in params:
                if paramnum in row.insitu_values:
                    isdate, isval, isstdv, isflag = row.insitu_values[paramnum]
                    if isdate is None:
                        print("%19s %8.3f %8.2f %3s" % ('None', isval, isstdv, isflag), end=' ')
                    else:
                        print("%s %8.3f %8.2f %3s" % (isdate.strftime('%Y-%m-%d %H:%M:%S'), isval, isstdv, isflag), end=' ')
                else:
                    print("                    -999.999 *..", end=' ')

            print()

    #------------------------------------------------------------------------------------
    def get_differences(self, gas, use_flagged_flask=False, use_flagged_insitu=False, method=None):
        """ get the flask-insitu differences for gas

        Args:
            gas - gas formula, e.g. 'co2', 'ch4'...
            flagged - If False, don't include difference if either
                the flask or insitu value is flagged.
            method - If None, use all methods, else use given method only.

        Returns:
           Two lists, first one is the dates as datetime objects,
           the second is the flask-insitu difference values
        """

        if len(self.fdata) == 0: return [], []

        x = []
        y = []

        # get parameter number for given gas
        if gas.lower() in self.gasnums:
            paramnum = self.gasnums[gas.lower()]
        else:
            print("Data for gas %s not available." % gas, file=sys.stderr)
            return [], []

        # check that requested gas is actually available.
        # It has to be in the first data row
        if paramnum not in self.fdata[0].flask_values:
            print("Data for gas %s not available." % gas, file=sys.stderr)
            return [], []

        for row in self.fdata:
            if method is not None and row.method != method: continue

            date = row.date

            flask_value, fflag = row.flask_values[paramnum]
            if flask_value < -900: continue

            is_date, insitu_value, insitu_stdv, iflag = row.insitu_values[paramnum]
            if insitu_value < -900: continue

            diff = flask_value - insitu_value

            # never include data where first character flag is not '.'
            if fflag[0] != '.' or iflag[0] != '.': continue

            # if use_flagged is False, then skip flagged data
            if not use_flagged_flask and fflag[1] != ".": continue
            if not use_flagged_insitu and iflag[1] != ".": continue

            x.append(date)
            y.append(diff)

        return x, y


if __name__ == "__main__":

    f = fic("MLO", 2025, 2025, gases=['CO2'], use_hourly_data=True)
    f.print_results('CO2')
#    f.print_results(gas="CO2")
#    xp, yp = f.get_differences("CO2", use_flagged_insitu=0)
#    for xz, yz in zip(xp, yp):
#        print(xz, yz)

#    print(f.methods)
