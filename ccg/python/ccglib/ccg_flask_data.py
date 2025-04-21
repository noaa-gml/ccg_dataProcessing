# vim: tabstop=4 shiftwidth=4 expandtab
"""
FlaskData - A class for getting flask data from the database
"""

import datetime
from collections import defaultdict
import numpy
import pandas as pd

import ccg_db_conn
import ccg_dbutils


class FlaskData:
    """
    Args:
        parameter : parameter number or parameter formula
        site : Site code or site number

    Usage:

        Usage of this class is a 3 step process

        1. Create the class
        2. Configure settings for filtering data
        3. Run the query

    Example::

        parameter = "CO2"
        site = "MLO"
        t1 = datetime.datetime(2010, 1, 1)
        t2 = datetime.datetime(2020, 1, 1)
        f = FlaskData(parameter, site)
        f.setRange(t1, t2)
        result = f.run()

    Additional methods are available to filter results.

    Results:

        Results are generated with the ``run()`` method. Default result
        is a list of dicts, each dict representing a row of data for the flask.
        Results can be changed to either a dict of numpy arrays or a pandas DataFrame
        with arguments to the ``run()`` method.
        Data fields included in the results are:

        * event_number - flask event number
        * site_num - site number
        * code - three letter site code
        * time_decimal - decimal value for the sample date
        * date - datetime object for sample date and time
        * flaskid - flask id
        * method - flask sampling method
        * strategy_num - flask sampling strategy number
        * altitude - flask sampling altitude
        * latitude - flask sampling latitude
        * longitude - flask sampling longitude
        * event_comment - flask event comment
        * data_number - data analysis number
        * gas - gas formula for given parameter
        * value - analzyed mole fraction value
        * qcflag - qc flag (renamed from 'flag')
        * system - analysis system name
        * inst - analysis analyzer id
        * adate - datetime object for analysis date and time
        * use_tags - use tags for flagging if 1
        * comment - analysis comment

    .. warning::
        Not setting the 'site' argument or not including any filter methods can
        give a very large amount of results.

    """

    #--------------------------------------------------------------
    def __init__(self, parameter, site=None, database="ccgg"):

        self.results = None
        self.result_type = 0
        self.use_soft_flags = False
        self.use_hard_flags = False
        self.use_default = False
        self.only_flagged = False

        self.db = ccg_db_conn.RO(db=database)

        db = ccg_dbutils.dbUtils()
        if isinstance(parameter, int):
            paramnum = parameter
        else:
            paramnum = db.getGasNum(parameter)

        if site:
            if isinstance(site, int):
                sitenum = site
            else:
                sitenum = db.getSiteNum(site)


        self.sql = self.db.sql

        self.sql.initQuery()
        self.sql.table("flask_event e")
        self.sql.innerJoin("flask_data d on e.num=d.event_num")
        self.sql.innerJoin("gmd.site s on e.site_num=s.num")
        self.sql.innerJoin("gmd.parameter p on d.parameter_num=p.num")
        self.sql.col("e.num as event_number")
        self.sql.col("e.site_num as site_num")
        self.sql.col("s.code as code")
        self.sql.col("e.dd as time_decimal")
        self.sql.col("e.date as date")
        self.sql.col("e.time as time")
        self.sql.col("e.id as flaskid")
        self.sql.col("e.me as method")
        self.sql.col("e.strategy_num as strategy_num")
        self.sql.col("e.alt as altitude")
        self.sql.col("e.lat as latitude")
        self.sql.col("e.lon as longitude")
        self.sql.col("e.comment as event_comment")
        self.sql.col("d.num as data_number")
        self.sql.col("p.formula as gas")
        self.sql.col("d.value as value")
        self.sql.col("d.unc as unc")
        self.sql.col("d.meas_unc as meas_unc")
        self.sql.col("d.flag as qcflag")
        self.sql.col("d.system as system")
        self.sql.col("d.inst as inst")
        self.sql.col("d.date as adate")
        self.sql.col("d.time as atime")
        self.sql.col("d.update_flag_from_tags as use_tags ")
        self.sql.col("d.comment as comment ")
        self.sql.orderby("e.dd")

#        self.sql.where("d.value > -999")
        self.sql.where("d.parameter_num=%s", paramnum)

        if site:
            self.sql.where("e.site_num=%s", sitenum)


    #--------------------------------------------------------------
    def run(self, as_arrays=False, as_dataframe=False, index=None):
        """ Run the query and return results

        Args:
            as_arrays : If True, convert the result to a single dict of
                numpy arrays.  The key is the field name, and the value
                is a numpy array of results for that field.

            as_dataframe : If True, return results as a pandas DataFrame

        Returns:
            By default the result is a list of dicts, each dict
            representing a row of data for the flask. This can be changed by
            setting the *as_arrays* or *as_dataframe* arguments.  Only one of the
            arguments should be set.

            Results are also stored in the class attribute 'results', that is
            ``f.results``
        """

        if self.use_soft_flags and not self.use_hard_flags:
            if self.only_flagged:
                self.sql.where("SUBSTRING(d.flag,1,1) != '.'")
            else:
                self.sql.where("d.flag like '.__'")

        elif self.use_hard_flags and not self.use_soft_flags:
            if self.only_flagged:
                self.sql.where("SUBSTRING(d.flag,0,1) != '.'")
            else:
                self.sql.where("d.flag like '_._'")

        elif self.use_hard_flags and self.use_soft_flags:
            if self.only_flagged:
                self.sql.where("SUBSTRING(d.flag,0,1) != '.' OR SUBSTRING(d.flag,1,1) != '.'")
            # else use everything

        else:
            self.sql.where("d.flag like '.._'")

        if self.use_hard_flags and not self.use_default:
            self.sql.where("d.value > -999")


#        print(self.db.sql.cmd())
        result = self.db.doquery()
#        print(result)

        if result is None:
            self.results = None
            return None


        # convert separate date and time fields to single datetime
        t0 = datetime.time()  # time = 0
        for row in result:
            t1 = datetime.datetime.combine(row['date'], t0) + row['time']
            t2 = datetime.datetime.combine(row['adate'], t0) + row['atime']
            row['date'] = t1
            row['adate'] = t2
            del row['time']
            del row['atime']

        if as_dataframe:
            self.results = pd.DataFrame(result)
            if index is not None:
                self.results.set_index(self.results[index], inplace=True)
                self.results.drop(index, axis=1, inplace=True)
            self.result_type = 2
        elif as_arrays:
            d = defaultdict(list)
            # convert list of dicts to dict of lists
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
    def find(self, event, adate):
        """ Find the result for the given event number and analysis date

        This method can only be used after the ``run()`` method is run.

        Args:
            event (int) : event number
            adate (datetime) : analysis date and time
        """

        if self.result_type == 0:
            for row in self.results:
                if row['adate'] == adate and row['event_number'] == event:
                    return row

        elif self.result_type == 1:
            w = numpy.where(
                (self.results['event_number'] == event)
                & (self.results['adate'] == adate)
            )
            if len(w[0]) == 0: return None
            d = {}
            for key in self.results:
                d[key] = self.results[key][w]

            return d

        elif self.result_type == 2:
            df = self.results[(self.results['event_number'] == event) & (self.results['adate'] == adate)]
            return df

        return None

    #--------------------------------------------------------------
    def setEvents(self, events):
        """ Limit results to a single or list of event numbers """

        if isinstance(events, list):
            self.sql.wherein("e.num in", events)
        else:
            self.sql.where("e.num=%s", events)

    #--------------------------------------------------------------
    def setDataNumber(self, datanum):
        """ Limit results to a single or list of data measurement numbers """

        if isinstance(datanum, list):
            self.sql.wherein("d.num in", datanum)
        else:
            self.sql.where("d.num=%s", datanum)

    #--------------------------------------------------------------
    def setRange(self, start=None, end=None):
        """ Set the date range for the results.

        Args:
            start (datetime or str) : Start date of data
            end (datetime or str) : End date of data

        Data is up to but not including end date.
        """

        if start:
            self.sql.where("e.date >= %s" , start)

        if end:
            self.sql.where("e.date < %s" , end)

    #--------------------------------------------------------------
    def setProject(self, project_num):
        """ Set the project number for results.

        Default is to use all project numbers.

        Args:
            project_num : Project number
        """

        self.sql.where("e.project_num=%s", project_num)

    #--------------------------------------------------------------
    def setPrograms(self, prog_nums):
        """ Set program numbers to use.

        Args:
            prog_nums : List of program numbers to include
        """

        if isinstance(prog_nums, int):
            self.sql.where("d.program_num=%s", prog_nums)

        else:
            if len(prog_nums) > 0:
                self.sql.wherein("d.program_num in", prog_nums)

    #--------------------------------------------------------------
    def setMethods(self, method_list):
        """ Set the flask sample methods to include.

        Args:
            method_list : List of flask method codes to include
        """

        if len(method_list) > 0:
            self.sql.wherein("e.me in", method_list)

    #--------------------------------------------------------------
    def setStrategy(self, use_flask=True, use_pfp=True):
        """ Set the strategy number to include in the database query.
        Default is to include all strategies.

        Args:
            use_flask : If true, include strategy number 1
            use_pfp : If true, include strategy number 2
        """

        if use_flask and use_pfp:
            self.sql.where("(e.strategy_num=1 OR e.strategy_num=2)")
        elif use_flask:
            self.sql.where("e.strategy_num=1")
        elif use_pfp:
            self.sql.where("e.strategy_num=2")


    #--------------------------------------------------------------
    def setSystem(self, sysname):
        """ Restrict results to certain analysis systems

        Args:
            sysname : An explicit name or string containing
                mysql wildcard characters like '%'
        """

        self.sql.where("d.system like %s", sysname)

    #--------------------------------------------------------------
    def setBin(self, method, binmin, binmax):
        """ Set binning to include in results.

        Data will be limited to where data from field 'method' is between
        'binmin' and 'binmax'. For example, ``f.setBin("lat", 5, 15)``

        Args:
            method : Binning method, such as 'lat', 'lon'.  This must
                be a valid field name in the flask_event table
            binmin : Minimum value to include
            binmax : maximum value to include
        """

        s = "e.%s" % method  # do it this way for python 2 compatibility
        s += " >= %s"
#        s = f"e.{method} >= %s"
        self.sql.where(s, binmin)
        s = "e.%s" % method
        s += " <= %s"
#        s = f"e.{method} <= %s"
        self.sql.where(s, binmax)

    #--------------------------------------------------------------
    def setAnalysisDate(self, adate, atime=None):
        """ Limit data to a specific analysis date """

        self.sql.where("d.date=%s", adate)
        if atime:
            self.sql.where("d.time=%s", atime)

    #--------------------------------------------------------------
    def setFlaskPackage(self, package_id):
        """ Limit data to specific flask package id

        Args:
            package_id (str): Package Id.  This is the part of the flask id before the '-' .
                For example, a flask id of 3056-01 has a package_id of '3056'
        """

        self.sql.where("substring_index(e.id,'-',1)=%s", package_id)

    #--------------------------------------------------------------
    def includeFlaggedData(self, only_flagged=False):
        """ include data where the second character of the flag is not '.'

        Args:
            only_flagged (bool) : If ``False``, flagged data is included with unflagged data,
                If ``True``: ONLY flagged data is returned.
        """

        self.use_soft_flags = True
        self.only_flagged = only_flagged

    #--------------------------------------------------------------
    def includeHardFlags(self):
        """ include data where the first character of the flag is not '.'

        Data with 9'd out values (-999.99) are not included.
        """

        self.use_hard_flags = True

    #--------------------------------------------------------------
    def includeDefault(self):
        """ Include data that has default value (-999.99) """

        self.use_default = True

    #--------------------------------------------------------------
    def showQuery(self):
        """ Print out the query string """

        print(self.sql.cmd())
        print(self.sql.bind())

        print(self.sql.cmd() % self.sql.bind())

if __name__ == "__main__":

    f = FlaskData("CO2", "MLO")
#    f = FlaskData(4, "HPB")
#    f = FlaskData("CO2", database='ccgg')
    t1 = datetime.datetime(2013,1,1)
    t2 = datetime.datetime(2014,2,1)
#    t3 = datetime.datetime(2020,3,11,14,28,18)
#    f.setRange(start=t1, end=t2)
#    f.includeFlaggedData()
#    f.includeHardFlags()
#    f.includeDefault()
#    f.setDataNumber(10304125)
#    f.setAnalysisDate(t3.date(), t3.time())
#    f.setEvents([471400, 471401])
#    f.setEvents(509863)
#    f.setMethods(['P', 'S'])
#    f.setStrategy(use_flask=True)
#    f.setBin('lat', 20, 40)
#    f.setBin('lon', -120, -110)
    f.showQuery()
    results = f.run(as_dataframe=True, index='date')
#    results = f.run(as_arrays=True)

#    for row in results: print(row)
    print(results)
    sys.exit()
#    dt = datetime.datetime(2020, 3, 11, 14, 42, 39)
#    row = f.find(471402, dt)
#    print(row)

    import matplotlib.pyplot as plt
#    results.plot('date', 'value')
    plt.plot(results['date'], results['value'])
    plt.show()
