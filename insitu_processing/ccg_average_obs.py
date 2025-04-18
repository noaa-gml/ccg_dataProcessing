
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for calculating hourly, daily and monthly average
for in-situ observatory data.
Also applies data selection flags to hourly data

!!!! This version is for using revised insitu tables in ccgg database
for observatory sites only.

NOTE:
Observatory sites don't care about intake heights.  A hourly, daily or monthly
average will be the average of all measurements, regradless of intake height.
A change in intake height for an observatory means the intakes were moved, not that
additional heights are being measured.

A tall tower site does take into account intake heights, and averages should
be made for each height. Use ccg_average_tower.py for tower sites.

"""
from __future__ import print_function

import sys
import datetime
import math
import calendar
import numpy

from dateutil.rrule import rrule, HOURLY, DAILY

sys.path.append("/ccg/src/python3")  # for getting composite_sd
#from composite_sd import composite_stdv
# routines for data flagging
from co2select import select_co2
from ch4select import select_ch4


import ccg_insitu_data2
import ccg_filter
import ccg_dates
import ccg_instrument
import ccg_utils
import ccg_uncdata_all
import ccg_insitu_intake
import ccg_insitu_systems
import ccg_db_conn
import ccg_dbutils

DEFAULTVAL = -999.99

CHECK = 2
UPDATE = 1


numpy.set_printoptions(linewidth=120)

##################################################################
class mfavg:
    """ Class for computing mole fraction averages at hourly, daily and monthly resolution
    from the high frequency insitu database tables.

    Usage:
       mf = ccg_average.mfavg(stacode, gas, year, db="ccgg")

    Then call one or more of

        mf.doHourlyAverage(option)
        mf.doDailyAverage(option)
        mf.doMonthlyAverage(option)

    where option is either None, CHECK or UPDATE

    """


    def __init__(self, stacode, gas, year, db="ccgg", verbose=False):
        """
        Arguments
            required
                stacode - three letter station code, BRW, MLO, SMO, SPO
                gas - gas of interest, e.g. 'co2', 'ch4' ...
                year - year of data.  Only one year at a time is processed.
            optional
                db - Database to use.  Default is 'ccgg'.
                verbose - Print extra messages while processing.
        """

        self.stacode = stacode.lower()
        self.ucstacode = stacode.upper()
        self.species = gas.upper()
        self.year = year
        self.lcspecies = gas.lower()
        self.verbose = verbose
        self.source_table = "insitu_data"
        self.uncfile = "/ccg/insitu/unc_master.txt"
        self.database = db

        dbu = ccg_dbutils.dbUtils()
        self.paramnum = dbu.getGasNum(self.species)
        self.sitenum = dbu.getSiteNum(self.stacode)

        self.intakes = ccg_insitu_intake.intake(self.stacode, self.species)

        self.RESULT_FORMAT = "%3s %4d %02d %02d %02d %8.3f %8.3f %8.3f %3d %3s %s %5.1f"
        self.RESULT_FORMAT_DAY = "%3s %4d %02d %02d %8.2f %6.2f %3d %3s %5.1f"
        self.RESULT_FORMAT_MONTH = "%3s %4d %02d %8.2f %6.2f %3d %3s %5.1f"

        self.db = ccg_db_conn.ProdDB(db=db)

        self.systems = ccg_insitu_systems.system(stacode, gas)

        # Get uncertainty information
        self.uncert = ccg_uncdata_all.dataUnc("insitu", self.species, self.stacode)

    #--------------------------------------------------------------------------
    # for hourly averages
    #--------------------------------------------------------------------------
    def doHourlyAverage(self, option=None, selection=True):
        """ calculate hourly average from high frequency insitu table values
        Observatory has one line of data for every hour of the year.
        Missing data is filled in with default values.
        """

        # get hourly averaged results from database
        data = self._get_hravg_data()

        if data is None: return

        # Here is where we should put any selection procedures.
        if selection is True:
            data = self._selectData(data)

        if option == CHECK:
            self._check_hour_db(data)

        elif option == UPDATE:
            self._update_hour_db(data)

        # Just print out the hourly averages
        else:
            for dt in sorted(data.keys()):
                (mr, mrsd, uncval, nv, flag, inst, intake_ht) = data[dt]
                print(self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, uncval, nv, flag, inst, intake_ht))


    #--------------------------------------------------------------------------
    def _get_hour(self, t1, t2, data):
        """ generator for getting data for each hour between t1 and t2

        Take advantage that data is ordered by date.

        t1 is datetime start
        t2 is datetime end
        data are results from database query (output from ccg_insitu_data)

        The rrule will generate a date for every hour of the year.

        This way is much faster than using a dataframe and groupby('H')
        """

        onehour = datetime.timedelta(hours=1)
        r = rrule(freq=HOURLY, dtstart=t1, until=t2)  # get hours between t1, t2

        nlines = len(data)

        i = 0
        for dt in r:

            a = []
            while i < nlines:
                date = data[i]['date']

                if date >= dt + onehour:
                    # past the desired hour, exit loop
                    break

                # if data falls within this hour, save it
                if date.date() == dt.date() and date.hour == dt.hour:
                    a.append(data[i])

                # go to next data line
                i += 1

            yield dt, a


    #--------------------------------------------------------------------------
    def _get_hravg_data(self): # , default_data):
        """ compute hourly averages from the insitu data for a year.
        Return a dict with date as key, tuple as value
        """

        default_data = {}
        inst = ccg_instrument.instrument(self.stacode, self.species)
        intakes = ccg_insitu_intake.intake(self.stacode, self.species)

        # we get all data, so that we can determine if data is
        # either missing or flagged, so that a "*.." or "I.." flag
        # can be applied where there is no unflagged data for an hour.
        f = ccg_insitu_data2.InsituData(self.species, self.ucstacode, 0, use_target=False, database=self.database)
        t1 = datetime.datetime(self.year, 1, 1)
        t2 = datetime.datetime(self.year+1, 1, 1)
        t3 = datetime.datetime(self.year, 12, 31, 23)
        f.setRange(start=t1, end=t2)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.includeDefault()
        data = f.run()  # all data
#        f.showQuery()

        if data is None: return None

#        print(data)
#        sys.exit()

        # need to filter out data from system we don't want to use
        sysdata = []
        for row in data:
            sysname = self.systems.get(row['date'])
            if row['system'] == sysname[0]:   # this means using the first system listed in systems.conf
                sysdata.append(row)

        for date, rows in self._get_hour(t1, t3, sysdata):
            count = len(rows)
#            print(rows)
#            print(date, count)
#                sys.exit()
#                continue

    #            unflagged = [row for row in rows if row['qcflag'][0:2] == '..']
            unflagged = [row for row in rows if row['qcflag'][0] == '.']
            unflagged_count = len(unflagged)

            if unflagged_count > 0:
                sysname = self.systems.get(date)
                d = numpy.array([row['value'] for row in unflagged])
                uncs = numpy.array([row['meas_unc'] for row in unflagged])
                w = numpy.array([row['n'] for row in unflagged])
                s = numpy.array([row['std_dev'] for row in unflagged])
                mean = numpy.average(d, weights=w)
#                if date == datetime.datetime(2023, 3, 7, 0):
#                    print(date)
#                    print(d)
#                    print(w)
#                    print(mean)
#                    sys.exit()
                unc = numpy.average(uncs, weights=w)
                intake_ht = rows[0]['intake_ht']
                inst_num = rows[0]['inst_num']
                if "GC" in sysname[0].upper():
                    if unflagged_count == 1:
                        cstdv = 0
                    else:
                        cstdv = d.std(ddof=1)
                else:
                    d = d - mean
                    ss = (w * (s*s + d*d)).sum()
                    cstdv = numpy.sqrt(ss/w.sum())

                # external uncertainties are used in the hourly averages. Get them here.
                # returns -999.99 if no uncertainties specified
                flag = "..."
                uncval = self.uncert.getUncertainty(self.stacode, date, mean, inst=inst_num, system=sysname[0])
#                print(date, unc, uncval)

                if uncval > 0:
                    if unc > 0:   # have both measured unc and table uncertainty
                        tunc = math.sqrt(uncval*uncval + unc*unc)
                    else:         # have only table uncertainty
                        tunc = uncval
                else:
                    if unc > 0:   # have only measured unc
                        tunc = unc
                    else:         # have no uncertainties
                        tunc = -999.99

        
#                if unc > 0 and uncval > 0:
                    # add in total uncertainty with measurement uncertainty
#                    unc = math.sqrt(unc*unc + uncval*uncval)

                t = (mean, cstdv, tunc, unflagged_count, flag, inst_num, intake_ht)

            else:
                inst_num = inst.getInstrumentNumber(date)
                if inst_num is None: inst_num = 0
                intake_height = intakes.get_intake("Line1", date)
                if self.species == "CH4" and self.ucstacode == "MLO" and date.year in [1987, 1988]: intake_height = 40.0
                if count == 0:
                    flag = "*.."
                else:
                    flag = "I.."
                t = (-999.99, -99.99, -999.99, 0, flag, inst_num, intake_height)

            default_data[date] = t


#        for key in default_data:
#            for t in default_data[key]:
#                print(key, t) # , default_data[key])
#        sys.exit()

        return default_data


    #--------------------------------------------------------------------------
    def _selectData(self, data):
        """ call the selection/flagging routines on the hourly average data """

        if self.lcspecies == "co2":
            a = select_co2(self.stacode, data)

        elif self.lcspecies == "ch4":
            a = select_ch4(self.stacode, data)

        # only brw co gets selection flags, the same criteria as ch4
        elif self.lcspecies == "co" and self.stacode == "brw":
            a = select_ch4(self.stacode, data)

        # all other gases (n2o), no selection
        else:
            a = data

        return a

    #--------------------------------------------------------------------------
    def _check_hour_db(self, data):
        """ Check for agreement with hourly averaged tables in database
        Check in order: date present, mixing ratios agree, flags agree
        """

        # get existing hourly data from database
        f = ccg_insitu_data2.InsituData(self.species, self.ucstacode, 1, use_target=False, database=self.database)
        t1 = datetime.datetime(self.year, 1, 1)
        t2 = datetime.datetime(self.year+1, 1, 1)
        f.setRange(start=t1, end=t2)
#        f.setIntakeHeight(intake_height)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.includeDefault()
        df = f.run(bydate=True)  # all data

        if df:

            for dt in sorted(data.keys()):
                (mr, mrsd, unc, nv, flag, inst, intake_ht) = data[dt]
    #            print(dt, data[dt])
                if dt in df:
                    row = df[dt]

                    # Check if mixing ratios agree.
                    mr2 = float(row['value'])
                    diff = mr - mr2
                    if abs(diff) > 0.011:
                        line = self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, unc, nv, flag, inst, intake_ht)
                        print("%s mixing ratio mismatch (%8.2f, %6.2f)." % (line, mr2, diff))
                    else:
                        if self.verbose:
                            print("Mixing ratio on %s hour %s OK" % (dt.date(), dt.hour))

                    # check uncertainty
                    unc2 = float(row['unc'])
                    diff = unc - unc2
                    if abs(diff) > 0.011:
                        line = self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, unc, nv, flag, inst, intake_ht)
                        print("%s uncertainty mismatch (%8.2f, %6.2f)." % (line, unc2, diff))

                    # check standard deviation
                    std2 = float(row['std_dev'])
                    diff = mrsd - std2
                    if abs(diff) > 0.011:
                        line = self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, unc, nv, flag, inst, intake_ht)
                        print("%s std dev mismatch (%8.2f, %6.2f)." % (line, std2, diff))

                    # check flag
                    oldflag = row['qcflag']
                    if flag != oldflag:
                        line = self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, unc, nv, flag, inst, intake_ht)
                        print("%s flag mismatch (%s)." % (line, oldflag))
                    else:
                        if self.verbose:
                            print("Flag on %s hour %s OK" % (dt.date(), dt.hour))

                else:
                    line = self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, unc, nv, flag, inst, intake_ht)
                    print("%s  not found." % line)

        else:
            for dt in sorted(data.keys()):
                (mr, mrsd, unc, nv, flag, inst, intake_ht) = data[dt]
                line = self.RESULT_FORMAT % (self.ucstacode, dt.year, dt.month, dt.day, dt.hour, mr, mrsd, unc, nv, flag, inst, intake_ht)
                print("%s  not found." % line)


    #--------------------------------------------------------------------------
    def _update_hour_db(self, data):
        """ This is where we actually update the database """

        for dt in sorted(data.keys()):

            (mr, mrsd, unc, nv, flag, inst, intake_ht) = data[dt]

            s = self.systems.get(dt)
            if len(s) > 0:
                system = s[0]
            else:
                system = 'None'

            # Find the record.
            record = self._find_hour_record(dt, inst, intake_ht, system)
#            print(dt, record)
#            continue

            if record is None:
                query = "INSERT INTO insitu_hour SET "
                query += "site_num=%d, " % self.sitenum
                query += "parameter_num=%d, " % self.paramnum
                query += "date='%s', " % (dt)
                query += "value=%.2f, " % mr
                query += "n=%d, " % nv
                query += "std_dev=%.2f, " % mrsd
                query += "unc=%.2f, " % unc
                query += "intake_ht=%s, " % intake_ht
                query += "inst_num=%s, " % inst
                query += "system='%s', " % system
                query += "flag='%s' " % flag

            else:
                num = record[0]['num']
                query = "UPDATE insitu_hour SET "
                query += "value = %.2f, " % mr
                query += "n = %d, " % nv
                # Use new flag only if we have done the selection process
                query += "flag = '%s', " % flag
                query += "std_dev = %.2f, " % mrsd
                query += "unc = %.2f, " % unc
                query += "intake_ht=%s " % intake_ht
                query += "WHERE num=%d " % num

            if self.verbose:
                print(query)

            self.db.doquery(query, commit=True)


    #--------------------------------------------------------------------------
    def _find_hour_record(self, date, instnum, intake_ht, system):

        datestr = date.strftime("%Y-%m-%d %H:%M:%S")
        sql = "SELECT num FROM insitu_hour "
        sql += "WHERE date = %s "
        sql += "AND site_num = %s "
        sql += "AND parameter_num = %s "
        sql += "AND system = %s "
        sql += "AND inst_num = %s "
#        print(sql % (datestr, self.sitenum, self.paramnum, system, instnum, intake_ht))
        result = self.db.doquery(sql, (datestr, self.sitenum, self.paramnum, system, instnum))

        return result

    #--------------------------------------------------------------------------
    def doDailyAverage_new(self, option):
        """ Create daily averages from hourly averages. """

        # get daily averaged results from database
        data = self._get_dayavg_data()

        if option == CHECK:
            self._check_day_db(data)

        elif option == UPDATE:
            self._update_day_db(data)

        # Just print out the hourly averages
        else:
            for dt in sorted(data.keys()):
                (mr, mrsd, nv, flag, intake_ht) = data[dt]
                print(self.RESULT_FORMAT_DAY % (self.ucstacode, dt.year, dt.month, dt.day, mr, mrsd, nv, flag, intake_ht))



    #--------------------------------------------------------------------------
    # for daily averages
    #--------------------------------------------------------------------------
    def doDailyAverage(self, option):
        """ Create daily averages from hourly averages. """

        source_table = "insitu_hour"

        # create the sql query for getting daily averages from the hourly table
        sql = "SELECT date, avg(value),stddev_samp(value),count(value),intake_ht "
        sql += "FROM %s " % (source_table)
        sql += "WHERE flag LIKE '.._' AND value > 0  and year(date) = %s  " % (self.year)
        sql += "AND site_num=%d AND parameter_num=%d " % (self.sitenum, self.paramnum)
        sql += "GROUP BY date(date); "

        result = self.db.doquery(sql)
#        for row in result: print(row)

        # get unique list of intake heights
        # create a dict with default values for every day of the year
        data = self._get_day_default_data()

        if result:
            # go through results and put in correct place in data array
            for row in result:
                date = row['date'].date()
                n = row['count(value)']
                sdev = row['stddev_samp(value)']
                val = row['avg(value)']
                intake_height = row['intake_ht']

                # mysql returns NULL for sdev if n is 1
                if n == 1: sdev = 0

                flag = "..."
                val = round(val, 2)
                sdev = round(sdev, 2)

                t = (val, sdev, n, flag, intake_height)
                data[date] = t


        if option == CHECK:
            self._check_day_db(data)

        elif option == UPDATE:
            self._update_day_db(data)

        else:
            for dt in data:
                (mr, mrsd, nv, flag, intake_ht) = data[dt]
                print(self.RESULT_FORMAT_DAY % (self.ucstacode, dt.year, dt.month, dt.day, mr, mrsd, nv, flag, intake_ht))

    #--------------------------------------------------------------------------
    def _get_day_default_data(self):
        """ create a dict with default values for every day of the year.
        Return dict of tuples containing
            (val, sdev, n, flag) for daily averages
        """

        data = {}

        dt1 = datetime.datetime(self.year, 1, 1)
        dt2 = datetime.datetime(self.year, 12, 31, 23)
        r = rrule(freq=DAILY, dtstart=dt1, until=dt2)

        for dt in r:
            t = (-999.99, -99.99, 0, "*..", -9.9)  # mf, sd, n, flag, intake_ht
            data[dt.date()] = t

        return data

    #--------------------------------------------------------------------------
    def _check_day_db(self, data):
        """ compare computed daily averages with values from the database """

        daytable = "insitu_day"

        for date in data:
            (mr, mrsd, nv, flag, intake_ht) = data[date]

            sql = "Select value from %s where date='%s' and site_num=%d and parameter_num=%d" % (daytable, date, self.sitenum, self.paramnum)
            result = self.db.doquery(sql)

            if result:
                if len(result) > 1:
                    print("Found", len(result), "values for", date)
                # Check if mixing ratios agree.
                mr2 = result[0]['value']
                diff = mr - mr2
                if abs(diff) > 0.011:
                    line = self.RESULT_FORMAT_DAY % (self.ucstacode, date.year, date.month, date.day, mr, mrsd, nv, flag, intake_ht)
                    print("%s mixing ratio mismatch (%8.2f, %6.2f)." % (line, mr2, diff))
                else:
                    if self.verbose:
                        print("Mole fraction on %s OK" % (date))

            else:
                line = self.RESULT_FORMAT_DAY % (self.ucstacode, date.year, date.month, date.day, mr, mrsd, nv, flag, intake_ht)
                print("%s  not found." % line)

    #--------------------------------------------------------------------------
    def _update_day_db(self, data):
        """ Update the daily averages in the database """

        daytable = "insitu_day"

        for date in data:
            (mr, mrsd, nv, flag, intake_ht) = data[date]

            if mr < 0: flag = "*.."

            time = "%d:%d:%d" % (12, 0, 0)

            sql = "SELECT num from %s WHERE date='%s' and site_num=%d and parameter_num=%d" % (daytable, date, self.sitenum, self.paramnum)
            result = self.db.doquery(sql)

            if result is None:
                query = "INSERT INTO %s SET " % daytable
                query += "date='%s', " % (date)
                query += "site_num=%d, " % self.sitenum
                query += "parameter_num=%d, " % self.paramnum
                query += "value = %.2f, " % mr
                query += "n = %d, " % nv
                query += "std_dev = %.2f, " % mrsd
                query += "flag = '%s', " % flag
                query += "intake_ht = %g " % intake_ht

            else:
                num = result[0]['num']
                query = "UPDATE %s SET " % daytable
                query += "value = %.2f, " % mr
                query += "n = %d, " % nv
                query += "std_dev = %.2f, " % mrsd
                query += "flag = '%s', " % flag
                query += "intake_ht = %g " % intake_ht
                query += " WHERE num=%d " % num

            if self.verbose:
                print(query)

            self.db.doquery(query, commit=True)

    #--------------------------------------------------------------------------
    # for monthly averages
    #--------------------------------------------------------------------------
    def doMonthlyAverage(self, option):
        """ Create monthly averages from daily averages. """

        if self.species == "CH4" and self.ucstacode != 'CAO':
            f = ccg_insitu_data2.InsituData(self.species, self.ucstacode, 2, database=self.database)
            df = f.run(as_arrays=True)
            if len(df['date']) >365:
                data = self._doCH4MonthlyAverage(df)
            else:
                data = self._make_monthly_avgs()

        else:
            data = self._make_monthly_avgs()

        if option == CHECK:
            self._check_month_db(data)

        elif option == UPDATE:
            self._update_month_db(data)

        else:
            for t in data:
                (val, sdev, n, flag, intake_ht) = data[t]
                yr = t[0]
                mon = t[1]
                print(self.RESULT_FORMAT_MONTH % (self.ucstacode, yr, mon, val, sdev, n, flag, intake_ht))

    #--------------------------------------------------------------------------
    def _make_monthly_avgs(self):

        data = []
        source_table = "insitu_day"

        # create the sql query for getting daily averages from the daily table
        sql = "SELECT date, avg(value),stddev_samp(value),count(value), intake_ht "
        sql += "FROM %s " % (source_table)
        sql += "WHERE flag LIKE '.._' AND value > 0  and year(date) = %s  " % (self.year)
        sql += "AND site_num=%d AND parameter_num=%d " % (self.sitenum, self.paramnum)
        sql += "GROUP BY month(date); "

        result = self.db.doquery(sql)

        # create a dict with default values for every month of the year
        data = self._get_month_default_data()

        # go through results and put in correct place in data array
        if result:
            for row in result:
                date = row['date']
                year = date.year
                month = date.month
                n = row['count(value)']
                sdev = row['stddev_samp(value)']
                val = row['avg(value)']
                intake_height = row['intake_ht']

                # mysql returns NULL for sdev if n is 1
                if n == 1: sdev = 0

                flag = "..."
                val = round(val, 2)
                sdev = round(sdev, 2)

                t = (val, sdev, n, flag, intake_height)
                data[(year, month)] = t

        return data

    #--------------------------------------------------------------------------
    def _get_month_default_data(self):
        """ create a dict with default values for every month of the year.
        Return dict of tuples containing
            (val, sdev, n, flag) for monthly averages
        """

        data = {}

        for month in range(1, 13):
            t = (-999.99, -99.99, 0, "*..", -9.9)
            data[(self.year, month)] = t

        return data

    #--------------------------------------------------------------------------
    def _check_month_db(self, data):
        """ compare calculated monthly averages with values from the database """

        monthtable = "insitu_month"

        for t in data:
            (mr, mrsd, nv, flag, intake_ht) = data[t]
            year = t[0]
            month = t[1]
            date = "%d-%d-%d" % (year, month, 15)

#            sql = "Select value,flag,n from %s where date='%s' and site_num=%d and parameter_num=%d and intake_ht=%s" % (monthtable, date, self.sitenum, self.paramnum, intake_ht)
            sql = "Select value,flag,n from %s where date='%s' and site_num=%d and parameter_num=%d" % (monthtable, date, self.sitenum, self.paramnum)
            result = self.db.doquery(sql)
            if result:
                if len(result) > 1:
                    print("Found", len(result), "values for", year, month, end='')
                    for r in result:
                        print("    ", r['value'], end='')
                    print()
                # Check if mixing ratios agree.
                mr2 = result[0]['value']
                diff = mr - mr2
                if abs(diff) > 0.011:
                    line = self.RESULT_FORMAT_MONTH % (self.stacode, year, month, mr, mrsd, nv, flag, intake_ht)
                    print("%s mixing ratio mismatch (%8.2f, %6.2f)." % (line, mr2, diff))
                else:
                    if self.verbose:
                        print("Mixing ratio on %s OK" % (date))

                # check n
                n = result[0]['n']
                if nv != n:
                    line = self.RESULT_FORMAT_MONTH % (self.stacode, year, month, mr, mrsd, nv, flag, intake_ht)
                    print("%s number of values mismatch (%d)." % (line, n))

            else:
                line = self.RESULT_FORMAT_MONTH % (self.stacode, year, month, mr, mrsd, nv, flag, intake_ht)
                print("%s  not found." % line)


    #--------------------------------------------------------------------------
    def _update_month_db(self, data):
        """ update the monthly averages in the database """

        monthtable = "insitu_month"

        for t in data:
            (mr, mrsd, nv, flag, intake_ht) = data[t]
            year = t[0]
            month = t[1]

            date = "%d-%d-%d" % (year, month, 15)

#                flag = "..."
            if mr < 0: flag = "*.."

#            sql = "SELECT num from %s WHERE date='%s' and site_num=%d and parameter_num=%d and intake_ht=%s" % (monthtable, date, self.sitenum, self.paramnum, intake_ht)
            sql = "SELECT num from %s WHERE date='%s' and site_num=%d and parameter_num=%d" % (monthtable, date, self.sitenum, self.paramnum)
            result = self.db.doquery(sql)

            if result is None:
                query = "INSERT INTO %s SET " % monthtable
                query += "date='%s', " % (date)
                query += "site_num=%d, " % self.sitenum
                query += "parameter_num=%d, " % self.paramnum
                query += "value = %.2f, " % mr
                query += "n = %d, " % nv
                query += "std_dev = %.2f, " % mrsd
                query += "flag = '%s', " % flag
                query += "intake_ht = %g " % intake_ht
            else:
                num = result[0]['num']
                query = "UPDATE %s SET " % monthtable
                query += "value = %.2f, " % mr
                query += "n = %d, " % nv
                query += "std_dev = %.2f, " % mrsd
                query += "flag = '%s', " % flag
                query += "intake_ht = %g " % intake_ht
                query += " WHERE num=%d " % num

            if self.verbose:
                print(query)

            self.db.doquery(query, commit=True)


    #--------------------------------------------------------------------------
    def _doCH4MonthlyAverage(self, df):
        """ Create monthly averages for ch4
        Rather than an average of daily values, fit a smooth curve to the data
        and calculate a monthly average at daily intervals from the smooth curve.
        """

        data = {}

        x = [ccg_dates.decimalDateFromDatetime(t) for t in df['date']]
        y = df['value']

        xp = []
        yp = []
        for xx, yy in zip(x, y):
            if int(xx) == self.year:
                xp.append(xx)
                yp.append(yy)

        # do the curve fitting/filtering for the entire record
        filt = ccg_filter.ccgFilter(x, y, shortterm=80, sampleinterval=1)

        # get monthly means from smoothed data
        # keep values for only our year
        m = filt.getMonthlyMeans()
        monthly_means = []
        for t in m:
            if t[0] == self.year:
                monthly_means.append(t)

        # get residuals of data from smooth curve for our year
        d = filt.getSmoothValue(xp)
        resid = yp - d   # this works!?  yp is cast into a numpy array since d is an array

        # calculate avgerage and residual standard deviation for each month
        for month in range(1, 13):

            # monthly average. t is tuple of (year, month, value, sdev, n)
            vals = []
            avg = -999.99
            for t in monthly_means:
                if t[0] == self.year and t[1] == month:
                    avg = t[2]
                    break

            # residual standard deviation
            vals = []
            for dd, value in zip(xp, resid):
                (yr, mon, dy, hr, minute, sec) = ccg_dates.calendarDate(dd)
                if yr == self.year and mon == month:
                    vals.append(value)
            avgresid, sdev = ccg_utils.meanstdv(vals)

            n = len(vals)
            flag = "..."
            if n == 0: flag = "*.."

            # intake height will be determined at the end of the month
            (a, daysinmonth) = calendar.monthrange(self.year, month)
            date = datetime.datetime(self.year, month, daysinmonth)
            intake_height = self.intakes.get_intake("Line1", date)

            if avg >-900:
                t = (avg, sdev, n, flag, intake_height)
                data[(self.year, month)] = t

        return data


    #--------------------------------------------------------------------------
    def doRawData(self):
        """ Get data from insitu tables and print out """

        f = ccg_insitu_data2.InsituData(self.species, self.ucstacode, 0, use_target=False, database=self.database)
        t1 = datetime.datetime(self.year, 1, 1)
        t2 = datetime.datetime(self.year+1, 1, 1)
        f.setRange(start=t1, end=t2)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.includeDefault()
        result = f.run()  # all data

        _format = "%3s %s %8.3f %8.3f %8.3f %8.3f %3d %3s %s %5.1f %s %3d %s"

        if result:
            for row in result:
                print(_format % (
                    self.ucstacode,
                    row['date'].strftime("%Y %m %d %H %M"),
                    row['value'],
                    row['std_dev'],
                    row['meas_unc'],
                    row['random_unc'],
                    row['n'],
                    row['qcflag'],
                    row['inlet'],
                    row['intake_ht'],
                    row['system'],
                    row['inst_num'],
                    row['comment'])
                )


if __name__ == "__main__":


    stacode = "BRW"
    gas = "co2"
    year = 2024
    mf = mfavg(stacode, gas, year, verbose=False)

    mf.doHourlyAverage(0)
    mf.doHourlyAverage(CHECK)
    mf.doHourlyAverage(UPDATE)

    mf.doDailyAverage(0)
    mf.doDailyAverage(CHECK)
    mf.doDailyAverage(UPDATE)

    mf.doMonthlyAverage(None)
    mf.doMonthlyAverage(CHECK)
    mf.doMonthlyAverage(UPDATE)
