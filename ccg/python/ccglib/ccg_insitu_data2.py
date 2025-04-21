
# vim: tabstop=4 shiftwidth=4 expandtab
"""
InsituData - A class for getting observatory insitu data from the database

.. note::
    This version is for the new structure of a single insitu database table for each averaging period.
    The tall tower site CAO is included in this module.  For other tower sites, use ``ccg_insitu_tower``

There are 4 insitu tables
    * insitu_data - holds high frequency insitu data (e.g. 5 minute avgs)
    * insitu_hour - holds hourly averaged data
    * insitu_day - holds daily averaged data
    * insitu_month - holds monthly averaged data
"""

import datetime
from collections import defaultdict
import numpy
import pandas as pd

import ccg_db_conn
import ccg_dbutils
import ccg_dates

# averaging types
RAW = 0
HOURLY = 1
DAILY = 2
MONTHLY = 3


class InsituData:
    """
    Args:
        parameter (int) or (str): parameter number or parameter formula
        site (int) or (str): Site code or site number
        which (int): Type of averaged data to get.  Valid values are:

            * 0 - get high frequency data from insitu table
            * 1 - get hourly averaged data
            * 2 - get daily averaged data
            * 3 - get monthly averaged data

        use_target (bool) : True to use target results instead of ambient air.
            The 'which' argument is ignored if ``use_target`` is True.

    Usage:

        Usage of this class is a 3 step process

        1. Create the class
        2. Configure settings for filtering data
        3. Run the query

    Example::

        f = InsituData(parameter, site, 1)
        f.setRange(t1, t2)
        result = f.run()

    Additional methods are available to filter results.

    Data with a first or second character flag != '.' is not included
    unless the useFlaggedData() and/or useHardFlags() methods are called prior to run().

    Results:

        Results are generated with the ``run()`` method. Results are also available
        in the self.results attribute.  If no data is found, None is returned as the result.

        Default result is a list of dicts, each dict representing a row of data.
        Results can be changed to either a dict of numpy arrays or a pandas DataFrame
        with arguments to the ``run()`` method.
        Data fields included in the results are:

        * date - datetime object for sample date and time
        * time_decimal - decimal value for the sample date
        * value - analzyed mole fraction value
        * n - number of samples averaged into value
        * std_dev - standard deviation of value
        * qcflag - qc flag (renamed from 'flag')
        * intake_ht - intake height of sample
        * unc - calculated uncertainty of value
        * inst - instrument id
        * inlet - inlet name

        If ``use_target`` is True, then `intake_ht` is not included.
    """

    #--------------------------------------------------------------
    def __init__(self, parameter, site, which=RAW, use_target=False, database="ccgg"):

        self.results = None
        self.result_type = 0
        self.use_soft_flags = False
        self.use_hard_flags = False
        self.use_default = False
        self.use_target = use_target

        self.db = ccg_db_conn.ReadOnlyDB(db=database)

        db = ccg_dbutils.dbUtils()
        if isinstance(parameter, int):
            self.paramnum = parameter
        else:
            self.paramnum = db.getGasNum(parameter)

        if isinstance(site, int):
            self.sitenum = site
        else:
            self.sitenum = db.getSiteNum(site)

        if use_target:
            which = RAW

        self.averaging = which

        self.sql = self.db.sql

        self.sql.initQuery()
        self.sql.col("num")
        self.sql.col("date")
        self.sql.col("value")
        self.sql.col("n")
        self.sql.col("std_dev")
        self.sql.col("flag as qcflag")
        self.sql.col("intake_ht")

        if self.averaging == RAW:
            table = "insitu_data"
            self.sql.col("inlet")
            self.sql.col("meas_unc")
            self.sql.col("random_unc")
            self.sql.col("system")
            self.sql.col("inst_num")
            self.sql.col("comment")

        elif self.averaging == HOURLY:
            table = "insitu_hour"
            self.sql.col("unc")
            self.sql.col("system")
            self.sql.col("inst_num")

        elif self.averaging == DAILY:
            table = "insitu_day"

        elif self.averaging == MONTHLY:
            table = "insitu_month"

        else:
            allowed_types = ['RAW', 'HOURLY', 'DAILY', 'MONTHLY', '0', '1', '2', '3']
            raise ValueError("Incorrect averaging value %s. Should be one of %s" % (which, ",".join(allowed_types)))

        self.sql.orderby("date")

        self.sql.table(table)

    #--------------------------------------------------------------
    def run(self, as_arrays=False, as_dataframe=False, bydate=False):
        """ Run the query and return results

        Results:
            By default the result is a list of dicts, each dict
            representing a row of data. This can be changed by
            setting the as_arrays or as_dataframe arguments.

            Results are also stored in the class attribute 'results', that is
            ``f.results``

        Args:
            as_arrays : If True, convert the result to a single dict of
                numpy arrays.  The key is the name, and the value
                is a numpy array of all results.

            as_dataframe : If True, return results as a pandas DataFrame

            bydate : If True and as_dataframe is True, set the index of the
                dataframe to the date.  If both as_arrays is False and as_dataframe is false,
                return results as a dict with the date as the key, and the row of data as the value

        """

        self.sql.where("site_num=%d" % self.sitenum)
        self.sql.where("parameter_num=%d" % self.paramnum)

        if self.averaging == RAW:
            if self.use_target:
                self.sql.where("target=1")
            else:
                self.sql.where("target=0")

        if self.averaging in [RAW, HOURLY]:
            if self.use_hard_flags and self.use_soft_flags:
                # don't restrict flags
                pass
            elif self.use_hard_flags and not self.use_soft_flags:
                self.sql.where("flag like '_._'")
            elif not self.use_hard_flags and self.use_soft_flags:
                self.sql.where("flag like '.__'")
            else:
                self.sql.where("flag like '.._'")

        if not self.use_default:
            self.sql.where("value>-999")

        result = self.db.doquery()

        if result is None:
            self.results = None
            return None

        # add in a time_decimal field.  Do it this way because the mysql f_dt2dec 
        # function may not be available for a database
        for row in result:
            row['time_decimal'] = ccg_dates.decimalDateFromDatetime(row['date'])

        # convert date field to datetime
        if self.averaging in [DAILY, MONTHLY]:
            for row in result:
                dt = row['date']
                row['date'] = datetime.datetime(dt.year, dt.month, dt.day)

        if as_dataframe:
            self.results = pd.DataFrame(result)
            if bydate:
                self.results.set_index('date', inplace=True)
            self.result_type = 2
        elif as_arrays:
            self.results = {}
            d = defaultdict(list)
            for row in result:
                for key in row:
                    d[key].append(row[key])

#            {d[key].append(row[key]) for row in result for key in row}
            d2 = {}
            for key in d:
                d2[key] = numpy.array(d[key])
            self.results = d2
            self.result_type = 1

#            df = pd.DataFrame(result)
#            for colname in df.columns:
#                self.results[colname] = df[colname].to_numpy()
#            self.result_type = 1
        else:
            self.result_type = 0
            if bydate:
                self.results = {}
                for row in result:
                    dt = row['date']
                    del row['date']
                    self.results[dt] = row
            else:
                self.results = result

        return self.results

    #--------------------------------------------------------------
    def setRange(self, start=None, end=None):
        """ Set the date range for the results.

        Args:
            start (datetime) : Start date of data
            end (datetime) : End date of data

        Data is up to but not including end date.
        """

        if start:
            self.sql.where("date >= %s", start)

        if end:
            self.sql.where("date < %s", end)

    #--------------------------------------------------------------
    def setInstrument(self, instnum):
        """ Restrict results to certain analyer instrument.

        'instnum' is a single instrument number from inst_description table
        """

        self.sql.where("inst_num = %s", instnum)

    #--------------------------------------------------------------
    def setSystem(self, sysname):
        """ Restrict results to certain system names.

        'sysname' is a system name, such as 'pic', 'lgr', 'ndir'...
        """

        self.sql.where("system = %s", sysname)

    #--------------------------------------------------------------
    def setInlet(self, inlet_name):
        """ Restrict results to a single inlet. 
            Only for high frequency raw data.
        """

        self.sql.where("inlet=%s", inlet_name)

    #--------------------------------------------------------------
    def setIntakeHeight(self, height):
        """ Restrict results to a single intake height """

        self.sql.where("intake_ht = %s", height)

    #--------------------------------------------------------------
    def includeFlaggedData(self):
        """ include data where the second character of the flag is not '.' """

        if self.averaging in [RAW, HOURLY]:
            self.use_soft_flags = True

    #--------------------------------------------------------------
    def includeHardFlags(self):
        """ include data where the first character of the flag is not '.' """

        if self.averaging in [RAW, HOURLY]:
            self.use_hard_flags = True

    #--------------------------------------------------------------
    def includeDefault(self):
        """ Include data that has default value (-999.99)

        Since default data is usually flagged, you also need to include the
        includeHardFlags() filter to get the default values.   
        """

        self.use_default = True

    #--------------------------------------------------------------
    def showQuery(self):
        """ Print out the query string """

        print(self.sql.cmd() % self.sql.bind())

if __name__ == "__main__":

    f = InsituData("CO2", "CAO", 0, use_target=False)
    t1 = datetime.datetime(2024, 5, 1, 12 )
    t2 = datetime.datetime(2024, 5, 12, 18)
    t3 = datetime.datetime(2020, 3, 11, 14, 28, 18)
    f.setRange(start=t1, end=t2)
#    f.setInlet("Line1")
    #    f.includeFlaggedData()
#    f.includeHardFlags()
#    f.includeDefault()
#    results = f.run(as_arrays=True)
#    results = f.run(bydate=True)
    results = f.run(as_dataframe=True, bydate=True)
    f.showQuery()

    #    for row in f.results: print(row)
    print(results)
    print(results.columns)
    print(results.info())
    sys.exit()

#    data2 = results.set_index('date')
#    data2 = data2['value']
#    df2 = data2.resample('H')
#    print(df2.mean())


#    df2 = data2.groupby(pd.Grouper(freq='H'))
#    print("-----")
#    print(df2)
#    print("-----")
#    print(df2.mean())
#    print(df2.count())
#    print(df2.std())
