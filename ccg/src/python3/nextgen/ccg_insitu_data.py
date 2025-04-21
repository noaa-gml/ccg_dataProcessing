# vim: tabstop=4 shiftwidth=4 expandtab
"""
InsituData - A class for getting observatory insitu data from the database
"""

import datetime
from collections import defaultdict
import numpy
import pandas as pd

import ccg_db_conn
import ccg_dbutils

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
    def __init__(self, parameter, site, which=RAW, use_target=False):

        self.results = None
        self.result_type = 0
        self.use_soft_flags = False
        self.use_hard_flags = False
        self.use_default = False

        self.db = ccg_db_conn.RO()

        db = ccg_dbutils.dbUtils()
        if isinstance(parameter, int):
            paramnum = parameter
            paramname = db.getGasFormula(paramnum)
            paramname = paramname.lower()
        else:
            paramnum = db.getGasNum(parameter)
            paramname = parameter.lower()

        if isinstance(site, int):
            self.stacode = db.getSiteCode(site)
            self.stacode = self.stacode.lower()
        else:
            self.stacode = site.lower()

        if use_target:
            which = RAW

        allowed_types = [RAW, HOURLY, DAILY, MONTHLY]
        if which not in allowed_types:
            raise ValueError("Incorrect averaging value %s. Should be one of %s" % (which, ",".join(allowed_types)))
        self.averaging = which

        self.sql = self.db.sql

        self.sql.initQuery()
        self.sql.col("date")
        self.sql.col("dd as time_decimal")
        self.sql.col("value")
        self.sql.col("n")
        self.sql.col("std_dev")
        self.sql.col("flag as qcflag")
        self.sql.orderby("dd")

        if self.averaging == RAW:
            if use_target:
                self.sql.col("type as inlet")
                table = self.stacode.lower() + "_" + paramname + "_target"
            else:
                self.sql.col("intake_ht")
                self.sql.col("inlet")
                table = self.stacode.lower() + "_" + paramname + "_insitu"
            self.sql.col("hr")
            self.sql.col("min")
            self.sql.col("sec")
            self.sql.col("unc")
            self.sql.col("inst")
        elif self.averaging == DAILY:
            table = self.stacode.lower() + "_" + paramname + "_day"
        elif self.averaging == MONTHLY:
            table = self.stacode.lower() + "_" + paramname + "_month"
        elif self.averaging == HOURLY:
            table = self.stacode.lower() + "_" + paramname + "_hour"
            self.sql.col("hour")
            self.sql.col("intake_ht")
            self.sql.col("unc")
            self.sql.col("inst")

        self.sql.table(table)

    #--------------------------------------------------------------
    def run(self, as_arrays=False, as_dataframe=False):
        """ Run the query and return results

        By default the result is a list of dicts, each dict
        representing a row of data. This can be changed by
        setting the as_arrays or as_dataframe arguments.

        Args:
            as_arrays : If True, convert the result to a single dict of
                numpy arrays.  The key is the name, and the value
                is a numpy array of all results.

            as_dataframe : If True, return results as a pandas DataFrame

        Results:

            Results are stored in the class attribute 'results', that is
            ``f.results``
        """

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

        # convert separate date and time fields to single datetime
        for row in result:
            if self.averaging == RAW:
                dt = row['date']
                hour = row['hr']
                minute = row['min']
                second = row['sec']
                row['date'] = datetime.datetime(dt.year, dt.month, dt.day, hour, minute, second)
                del row['hr']
                del row['min']
                del row['sec']

            elif self.averaging in [DAILY, MONTHLY]:
                dt = row['date']
                row['date'] = datetime.datetime(dt.year, dt.month, dt.day)

            elif self.averaging == HOURLY:
                dt = row['date']
                hour = row['hour']
                row['date'] = datetime.datetime(dt.year, dt.month, dt.day, hour)
                del row['hour']

        if as_dataframe:
            self.results = pd.DataFrame(result)
            self.result_type = 2
        elif as_arrays:
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
        else:
            self.results = result
            self.result_type = 0

        return self.results

    #--------------------------------------------------------------
    def setRange(self, start=None, end=None):
        """ Set the date range for the results.

        Args:
            start (datetime) : Start date of data
            end (datetime) : End date of data

        Data is up to but not including end date.
        Times for the start and end are ignored, only
        complete days are used.
        """

        if start:
            self.sql.where("date >= %s", start.date())

        if end:
            self.sql.where("date < %s", end.date())

    #--------------------------------------------------------------
    def setInstrument(self, instid):
        """ Restrict results to certain analyer instruments.

        'instid' can be an explicit name or can contain mysql wildcard characters like '%'
        """

        self.sql.where("inst like %s", instid)

    #--------------------------------------------------------------
    def setIntakeHeight(self, height):
        """ Restrict results to a single intake height """

        self.sql.where("intake_ht = %s", height)

    #--------------------------------------------------------------
    def setInlet(self, inlet_num):
        """ Restrict results to a single inlet """

        self.sql.where("inlet=%s", inlet_num)

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

        print(self.sql._parameters)
        print(self.sql.cmd() % self.sql.bind())
#        print(self.sql.cmd())

if __name__ == "__main__":

    f = InsituData("CO2", "MLO", 2)
    t1 = datetime.datetime(1974,  5, 1)
    t2 = datetime.datetime.now()
    f.setRange(start=t1, end=t2)
    #    f.includeFlaggedData()
#    f.setIntakeHeight(18.3)
#    f.includeHardFlags()
#    f.includeDefault()
#    f.setInlet(2)
    results = f.run(as_dataframe=True)
#    results = f.run(as_arrays=True)
#    f.showQuery()

    #    for row in f.results: print(row)
    print(results)
    sys.exit()

#    d = InsituData("CO2", "MKO", 2)
#    results2 = d.run(as_dataframe=True)
#    results2 = d.run(as_arrays=True)
#    print(results2)

#    print(pd.concat([results, results2]))
#    print(numpy.concatenate((results['date'], results2['date'])))
