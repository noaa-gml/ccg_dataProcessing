
# vim: tabstop=4 shiftwidth=4 expandtab
"""
ACInsituData - A class for getting aircraft insitu data from the database

There are 2 insitu tables
    * mobile_insitu_event - holds event information for a measurement (date, position, vehicle...)
    * mobile_insitu_data - holds high frequency insitu data (e.g. 1 second avgs)
"""

import sys
import datetime
import pandas as pd

import ccg_db_conn
import ccg_dbutils
import ccg_dates


class ACInsituData:
    """
    Args:
        parameter (int) or (str): parameter number or parameter formula
        site (int) or (str): Site code or site number

    Usage:

        Usage of this class is a 3 step process

        1. Create the class
        2. Configure settings for filtering data
        3. Run the query

    Example::

        f = ACInsituData(parameter, site)
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
        Data fields included in the default results are:

        * event_number - event number for the measurement
        * date - datetime object for sample date and time
        * altitude - 
        * latitude -
        * longitude -
        * profile_num -
        * data_number -
        * value - analzyed mole fraction value
        * n - number of samples averaged into value
        * std_dev - standard deviation of value
        * qcflag - qc flag (renamed from 'flag')
        * inst_num - instrument id
        * time_decimal - Decimal value for the sample date

        Additional columns are available depending on settings and options.

    """

    #--------------------------------------------------------------
    def __init__(self, parameter, site, database="kwt"):

        self.results = None
        self.result_type = 0
        self.use_soft_flags = False
        self.use_hard_flags = False
        self.use_default = False
        self.resample = None

        self.db = ccg_db_conn.ReadOnlyDB(db=database)

        db = ccg_dbutils.dbUtils()
        if isinstance(parameter, int):
            self.paramnum = parameter
        else:
            if parameter.lower() == "all":
                self.paramnum = "all"
            else:
                self.paramnum = db.getGasNum(parameter)

        if isinstance(site, int):
            self.sitenum = site
        else:
            self.sitenum = db.getSiteNum(site)

        self.sql = self.db.sql

        self.sql.initQuery()
        self.sql.table("mobile_insitu_event e")
        self.sql.innerJoin("mobile_insitu_data d on e.num=d.event_num")
        self.sql.col("e.num as event_number")
        self.sql.col("e.datetime as date")
        self.sql.col("e.alt as altitude")
        self.sql.col("e.lat as latitude")
        self.sql.col("e.lon as longitude")
        self.sql.col("e.profile_num as profile_num")
        self.sql.col("d.num as data_number")
        self.sql.col("d.value as value")
        self.sql.col("d.n as n")
        self.sql.col("d.stddev as std_dev")
        self.sql.col("d.unc as unc")
        self.sql.col("d.flag as qcflag")
        self.sql.col("d.inst_num as inst_num")

        self.sql.orderby("e.datetime")

#        self.sql.table(table)

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

            bydate : If True, return default results as a dict with the date as the key,
                and the row of data as the value.  dataframe results will set the
                index of the dataframe to the date

        """

        self.sql.where("site_num=%d" % self.sitenum)

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

        if self.paramnum == "all":
            if self.resample is None:
                sys.exit("ERROR: resample must be set if using 'all' for parameter.")

            gases = {'CO2': 1, 'CH4': 2, 'CO': 3}  # should get a list of parameter_num from database instead
            gases = {'CO2': 1, 'CH4': 2, 'CO': 3, 'T': 60, 'P': 61, 'RH': 62}  # should get a list of parameter_num from database instead
            for gas in gases:
                pnum = gases[gas]
#                print("%%%%%%%%%%%%%%%%", pnum)
                self.sql.where("parameter_num=%s", pnum, replace=True)
                result = self.db.doquery()
                results = pd.DataFrame(result)
                results.set_index('date', inplace=True)
#                print(results)
                df3 = results.resample(self.resample)

                # first time through will use position info (alt, lat, lon)
                if self.results is None:
                    xx = df3.mean()  # get the mean of every column
                    xx.drop(['event_number', 'data_number'], axis=1, inplace=True)
                    xx['std_dev'] = df3['value'].std()     # replace std_dev with stddev of resample period
                    xx['n'] = df3['value'].count()         # replace n with count of resample period
                    xx['unc'] = df3['unc'].mean()          # replace unc with mean uncertainty of resample period

                    xx.rename(columns={'value':gas, 'std_dev':gas+'_std_dev', 'n':gas+'_n', 'unc':gas+'_unc'}, inplace=True)

                    self.results = xx
                else:
                    # make a dataframe with just the gas info
                    a1 = df3['value'].mean()
                    a2 = df3['value'].std()
                    a3 = df3['value'].count()
                    a4 = df3['unc'].mean()
                    xx = pd.concat([a1, a2, a3, a4], axis=1)
                    xx.columns = [gas, gas+'_std_dev', gas+'_n', gas+'_unc']
                    # add in the value, n, std_dev, unc columns to results
                    self.results = pd.merge(self.results, xx, on='date', how='outer')

#                print(self.results)
        else:
            self.sql.where("parameter_num=%d" % self.paramnum)

            result = self.db.doquery()

            if result is None:
                self.results = None
                return None

            # add in a time_decimal field.  Do it this way because the mysql f_dt2dec
            # function may not be available for a database
            for row in result:
                row['time_decimal'] = ccg_dates.decimalDateFromDatetime(row['date'])

            if self.resample:
                as_dataframe = True

            if as_dataframe:
                self.results = pd.DataFrame(result)
                if bydate:
                    self.results.set_index('date', inplace=True)
                self.result_type = 2
            elif as_arrays:
                self.results = {}
                df = pd.DataFrame(result)
                for colname in list(df.columns):
                    self.results[colname] = df[colname].to_numpy()
                self.result_type = 1
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

            if self.resample:
                if not bydate:
                    self.results.set_index('date', inplace=True)
                self.results = self.results.resample(self.resample).mean()
                self.results.drop(['event_number', 'data_number'], axis=1, inplace=True)

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
            self.sql.where("datetime >= %s", start)

        if end:
            self.sql.where("datetime < %s", end)

    #--------------------------------------------------------------
    def setInstrument(self, instnum):
        """ Restrict results to certain analyer instrument.

        'instnum' is a single instrument number from inst_description table
        """

        self.sql.where("inst_num = %s", instnum)

    #--------------------------------------------------------------
    def includeFlaggedData(self):
        """ include data where the second character of the flag is not '.' """

        self.use_soft_flags = True

    #--------------------------------------------------------------
    def includeHardFlags(self):
        """ include data where the first character of the flag is not '.' """

        self.use_hard_flags = True

    #--------------------------------------------------------------
    def includeDefault(self):
        """ Include data that has default value (-999.99)

        Since default data is usually flagged, you also need to include the
        includeHardFlags() filter to get the default values.
        """

        self.use_default = True

    #--------------------------------------------------------------
    def setSampling(self, rule):
        """ resample the data according to the frequency set by 'rule'.

        examples: '10s', '30s', '5min' for 10 second, 30 second, 5 minute averages

        Setting this option will also force
        'as_dataframe=True' and 'bydate=True' for the run() method.
        The 'event_number' and 'data_number' columns will be dropped from the dataframe.
        """

        self.resample = rule

    #--------------------------------------------------------------
    def showQuery(self):
        """ Print out the query string """

        print(self.sql.cmd() % self.sql.bind())

if __name__ == "__main__":

    f = ACInsituData("CO2", "UGD")
    t1 = datetime.datetime(2021, 6, 1, 12)
    t2 = datetime.datetime(2021, 6, 12, 18)
    f.setRange(start=t1, end=t2)
#    f.includeFlaggedData()
#    f.includeHardFlags()
#    f.includeDefault()
#    f.setSampling('10s')
    results = f.run(as_dataframe=True, bydate=False)
#    results = f.run(as_arrays=True)
#    f.showQuery()


    #    for row in f.results: print(row)
    print(results)
#    print(results.columns)
#    print(results.info())
