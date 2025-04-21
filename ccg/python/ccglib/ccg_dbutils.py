# vim: tabstop=4 shiftwidth=4 expandtab
"""
Convenience routines for common database requests
"""

import sys
import datetime

import ccg_db_conn

########################################################
def csv(items):
    """ Convert list to ',' separated string """

    if isinstance(items, list) or isinstance(items, tuple):
        if isinstance(items[0], str):
            print("%%%%", items)
            a = ",".join(("'" + str(item) + "'" for item in items))
        else:
            a = ",".join((str(item) for item in items))
    else:
        a = items

    return a


########################################################
class dbUtils:
    """ Class for convenience functions for common database requests

    Args:
        readonly (bool): If False, open database connection in read/write mode.

    .. warning::
        **readonly=False** should only be set when using the FlaskDataTag routines

    Example::

        db = ccg_dbutils.dbUtils()
        print(db.getSiteNum('MLO'))
        print(db.getSiteCode(75))
        print(db.getSiteName('MLO'))
        print(db.getSiteNameFromNum(75))

    """

    def __init__(self, database="ccgg", readonly=True, host=""):

        if database is None:
            database = ""

        # only one host available now that db is gone - 17 May 2023
        host = ""
        if readonly:
            passwd = ''
            self.db = ccg_db_conn.DatabaseConn(user='', password=passwd, db=database, host=host)
        else:
            passwd = ''
            self.db = ccg_db_conn.DatabaseConn(user='', password=passwd, db=database, host=host)

        self.db._conn.autocommit(True)
        self.database = database

    #---------------------------------------------------------
    def close(self):

        self.db._conn.close()

    #---------------------------------------------------------
    def getSiteNum(self, code):
        """ Get the site number for a site code. Returns -1 if code is not found. """

        query = "SELECT num FROM gmd.site WHERE code=%s"
        row = self.db.doquery(query, (code,))
        if row:
            num = row[0]['num']
        else:
            num = -1

        return int(num)

    #---------------------------------------------------------
    def getSiteCode(self, num):
        """ Get a site code from a site number """

        query = "SELECT code FROM gmd.site WHERE num=%s"
        row = self.db.doquery(query, (num,))

        if row:
            code = row[0]['code']
        else:
            code = ""

        return code

    #---------------------------------------------------------
    def getSiteName(self, code):
        """ Get a site name from a site code """

        query = "SELECT name FROM gmd.site WHERE code=%s"
        row = self.db.doquery(query, (code,))

        name = ""
        if row:
            name = row[0]['name']

        return name

    #---------------------------------------------------------
    def getSiteNameFromNum(self, num):
        """Get a site name from a site number """

        query = "SELECT name FROM gmd.site WHERE num=%s"
        row = self.db.doquery(query, (num,))

        name = ""
        if row:
            name = row[0]['name']

        return name

    #---------------------------------------------------------
    def getSiteInfo(self, code):
        """ Get site information from a site code.  """

        query = "SELECT num, code, name, country, lat, lon, elev, lst2utc FROM gmd.site WHERE code=%s"
        row = self.db.doquery(query, (code,))

        return row[0]


    #---------------------------------------------------------
    def getSiteInfoFromNum(self, num):
        """ Get site information from a site number """

        query = "SELECT num, code, name, country, lat, lon, elev, lst2utc FROM gmd.site WHERE num=%s"
        row = self.db.doquery(query, (num,))

        return row[0]


    #---------------------------------------------------------
    def getGasNum(self, gas):
        """ Get parameter number from formula or name """

        query = "SELECT num from gmd.parameter where formula=%s or name=%s"
        row = self.db.doquery(query, (gas, gas))

        num = -1
        if row:
            num = row[0]['num']

        return int(num)

    #---------------------------------------------------------
    def getGasFormula(self, gasnum):
        """ Get parameter formula from number """

        query = "SELECT formula from gmd.parameter where num=%s"
        row = self.db.doquery(query, (gasnum,))

        if row:
            return row[0]['formula']

        return ""

    #---------------------------------------------------------
    def getGasNameFromNum(self, gasnum):
        """ Get parameter name from number """

        query = "SELECT name from gmd.parameter where num=%s"
        row = self.db.doquery(query, (gasnum,))

        if row:
            return row[0]['name']

        return ""

    #---------------------------------------------------------
    def getGasName(self, formula):
        """ Get parameter name from formula """

        query = "SELECT name from gmd.parameter where formula=%s"
        row = self.db.doquery(query, (formula,))

        if row:
            return row[0]['name']

        return ""

    #---------------------------------------------------------
    def getGasInfo(self, formula):
        """ Get parameter info from formula """

        query = "SELECT num, formula, name, unit, unit_name, formula_html, unit_html, formula_idl, unit_idl, formula_matplotlib, unit_matplotlib "
        query += "FROM gmd.parameter WHERE formula=%s"
        row = self.db.doquery(query, (formula,))

        return row[0]

    #---------------------------------------------------------
    def getGasInfoFromNum(self, num):
        """ Get parameter info from number """

        query = "SELECT num, formula, name, unit, unit_name, formula_html, unit_html, formula_idl, unit_idl, formula_matplotlib, unit_matplotlib "
        query += "FROM gmd.parameter WHERE num=%s"
        row = self.db.doquery(query, (num,))

        return row[0]

    #---------------------------------------------------------
    def getProgramNum(self, abbr):
        """ Get program number from a single or list of program abbreviations """

        if isinstance(abbr, str):
            abbr = (abbr,)

        sql = self.db.sql
        sql.initQuery()
        sql.table("gmd.program")
        sql.col("num")
        sql.wherein("abbr in", abbr)

        result = self.db.doquery()

        plist = [int(row['num']) for row in result]

        if len(plist) == 1:
            return plist[0]

        return plist


    #---------------------------------------------------------
    def getProjectName(self, projectnum):
        """ Get project name from project number """

        query = "SELECT name FROM gmd.project WHERE num=%s"
        row = self.db.doquery(query, (projectnum,))

        projectname = ""
        if self.db._c.rowcount > 0:
            projectname = row[0]['name']

        return projectname

    #---------------------------------------------------------
    def getProgramAbbrFromProject(self, proj):
        """ Get program abbreviation from a project number """

        query = "select program.abbr from gmd.program, gmd.project where project.num=%s and program_num=program.num;"
        row = self.db.doquery(query, (proj,))

        name = ""
        if self.db._c.rowcount > 0:
            name = row[0]['abbr']

        return name

    #---------------------------------------------------------
    def getIntakeHeights(self, stacode, param):
        """ Get all intake heights from an insitu table """

        sitenum = self.getSiteNum(stacode)
        paramnum = self.getGasNum(param)

        query = "select distinct height from ccgg.intake_heights "
        query += "where site_num=%d " % sitenum
#        query += "and parameter_num=%d " % parmnum


#        table = stacode.lower() + "_" + param.lower() + "_insitu"
#        query = "select distinct intake_ht from ccgg.%s " % table
#        query += "where intake_ht > 0 "

        result = self.db.doquery(query)

        a = []
        for row in result:
            a.append(float(row['height']))

        return a

    #---------------------------------------------------------
    def getBinInfo(self, stacode, project_num):
        """ Get any binning information for a site code and project number """

        sitenum = self.getSiteNum(stacode)

        query = "select method, min, max, width "
        query += "from ccgg.data_binning where site_num=%s and project_num=%s"

        result = self.db.doquery(query, (sitenum, project_num))

#        if result is not None:
#            return result[0]

        return result

    #---------------------------------------------------------
    def getPrelimDate(self, site, gas):
        """ Return date for preliminary data for a site code and gas """

        sitecode = site[0:3].lower()
        sitenum = self.getSiteNum(sitecode)
        paramnum = self.getGasNum(gas)

        query = "SELECT begin FROM ccgg.data_release "
        query += "WHERE site_num=%s "
        query += "AND parameter_num=%s "
        query += "AND project_num=%s "

        row = self.db.doquery(query, (sitenum, paramnum, 1))
        if self.db._c.rowcount > 0:
            prelimdate = row[0]['begin']
        else:
            prelimdate = datetime.date(9999, 12, 31)

        return prelimdate

    #---------------------------------------------------------
    def getDefaultScale(self, gas):
        """ Return the default scale table name for the given gas abbr """

        query = "select name from reftank.scales where species=%s and current=1"
        row = self.db.doquery(query, (gas.upper(),))

        name = ""
        if row:
            name = row[0]['name']

        return name

    #---------------------------------------------------------
    def getScaleNum(self, scale_name):
        """ return the scale number for a given scale name """

        query = "SELECT idx FROM reftank.scales "
        query += "WHERE name=%s "
        row = self.db.doquery(query, (scale_name,))

        if row:
            return row[0]['idx']

        return None

    #---------------------------------------------------------
    def getScaleName(self, scale_num):
        """ return the scale name for a given scale number """

        query = "SELECT name FROM reftank.scales "
        query += "WHERE idx=%s "
        row = self.db.doquery(query, (scale_num,))

        if row:
            return row[0]['name']

        return None

    #---------------------------------------------------------
    def getCurrentScale(self, gas):
        """ Determine the current scale number and name for the gas

        Returns:
            dict with
            d['idx'] - scale number
            d['name'] - scale name
        """

        query = "SELECT idx, name FROM reftank.scales WHERE species=%s and current=1"
        row = self.db.doquery(query, (gas.upper(),))

        if row is None:
            raise ValueError("Unknown scale for: %s" % gas)

        return row[0]

    #---------------------------------------------------------
    def getFillCode(self, serial_num, date):
        """ Get the filling code for tank with 'serial_num' on given date

        Args:
            serial_num : serial number of the reference tank
            date : Either a datetime or date instance for the date

        Returns:
            fill code of the tank on given date. If no fill code available returns '-'
        """

        sql = "select code from reftank.fill where serial_number=%s and date <=%s order by date desc limit 1"
        results = self.db.doquery(sql, (serial_num, date.strftime('%Y-%m-%d')))

        if results:
            fillcode = results[0]['code']
            if fillcode == '': fillcode = '-'
        else:
            fillcode = "-"

        return fillcode

    #---------------------------------------------------------
    def getStrategies(self, stacode, project):
        """ Get sampling strategies that are used for a project at a site.

        Args:
            stacode (str): Three letter station code
            project (int or list): Single number or list of project numbers

        Returns:
            slist (list): List of strategy numbers
        """

        p1 = csv(project)

        if isinstance(p1, int):
            # assume project 6 will be by itself
            if p1 == 6:
                query = "select distinct strategy_num from hats_qc.data_summary where site_num=%s and project_num in (%s)"
            else:
                query = "select distinct strategy_num from ccgg.data_summary where site_num=%s and project_num in (%s)"

        else:
            # assume project 6 will be by itself
            if "6" in p1:
                query = "select distinct strategy_num from hats_qc.data_summary where site_num=%s and project_num in (%s)"
            else:
                query = "select distinct strategy_num from ccgg.data_summary where site_num=%s and project_num in (%s)"

        sitenum = self.getSiteNum(stacode)
        result = self.db.doquery(query, (sitenum, p1))

        slist = []
        if result:
            slist = [int(row['strategy_num']) for row in result]

        return slist

    #---------------------------------------------------------
    def getParameterList(self, stacode, project, strategy=None):
        """ Get a list of parameters that have been measured at a site for a given project.

        Args:
            stacode (str): Three letter station code
            project (int): Project number
            strategy (int or list): Strategy number or list of strategy numbers

        Returns:
            Return a list of dicts that contain the parameter numbers, formulas and names
            of the parameters. keys are 'parameter_num', 'formula', 'name'.
        """

        if strategy is None:
            s1 = [1,2,3,4]
        elif isinstance(strategy, int):
            s1 = (strategy,)
        else:
            s1 = strategy

        sitenum = self.getSiteNum(stacode)

        self.db.sql.initQuery()
        self.db.sql.distinct()
        if project == 6:
            self.db.sql.table("hats_qc.data_summary d")
        else:
            self.db.sql.table("ccgg.data_summary d")
        self.db.sql.innerJoin("gmd.parameter p on d.parameter_num=p.num")
        self.db.sql.col("d.parameter_num")
        self.db.sql.col("p.formula")
        self.db.sql.col("p.name")
        if project == 6:
            self.db.sql.orderby("p.formula")
        else:
            self.db.sql.orderby("d.parameter_num")

        self.db.sql.where("d.project_num=%s", project)
        self.db.sql.where("d.site_num=%s", sitenum)
        if project in [1,2]:
            self.db.sql.wherein("d.strategy_num in", s1)
        else:
            self.db.sql.where("(d.parameter_num < 58 OR d.parameter_num > 62) ")

        result = self.db.doquery()

        return result

    #---------------------------------------------------------
    def getFlaskMethodList(self, stacode, project, parameternum):
        """ Get a list of flask sample method codes for a parameter at a site

        Args:
            stacode (str): Three letter station code
            project (int): Project number
            parameternum (int or list): Parameter number

        Returns:
            Return a list of flask methods that have been used for the site/project/parameter
        """

        if project == 6:
            return ['x']


        sitenum = self.getSiteNum(stacode)

        self.db.sql.initQuery()
        self.db.sql.distinct()
        self.db.sql.table("ccgg.flask_data_view d")
        self.db.sql.innerJoin("gmd.parameter p on d.parameter_num=p.num")
        self.db.sql.col("d.me")
        self.db.sql.orderby("d.me")

        self.db.sql.where("d.project_num=%s", project)
        self.db.sql.where("d.site_num=%s", sitenum)

        if isinstance(parameternum, int):
            self.db.sql.where("d.parameter_num=%s", parameternum)
        elif isinstance(parameternum, list):
            self.db.sql.wherein("d.parameter_num in", parameternum)

        result = self.db.doquery()

        methods = [d['me'] for d in result]

        return methods

    #---------------------------------------------------------
    def getSiteList(self, project, strategy=None):
        """ Get list of sites for a given project and strategy

        Args:
            project (int): Project number
            strategy (int or list): Single number or list of strategy numbers

        Returns:
            Returns a list of dicts containing the site code, name and country.
        """

        if strategy is None:
            s1 = [1,2,3,4]
        elif isinstance(strategy, int):
            s1 = (strategy,)
        else:
            s1 = strategy

        self.db.sql.initQuery()
        self.db.sql.distinct()

        if project == 6:
            self.db.sql.table("hats_qc.data_summary d")
        elif project == 1:
            # use flask_event, data_summary not always up to date for new sites
            self.db.sql.table("ccgg.flask_event d")  # this doesn't work for observatory
        else:
            self.db.sql.table("ccgg.data_summary d")
        self.db.sql.innerJoin("gmd.site s on d.site_num=s.num")
        self.db.sql.col("s.code")
        self.db.sql.col("s.name")
        self.db.sql.col("s.country")
        self.db.sql.orderby("s.code")

        self.db.sql.where("d.project_num=%s", project)
        if project in [1,2]:
            self.db.sql.wherein("d.strategy_num in", s1)

        result = self.db.doquery()

        return result

    #---------------------------------------------------------
    def getSitePrograms(self, sitecode, gasnum, project=1):
        """ Get list of program abbr and numbers that have analyzed flasks for a gas at a site

        Args:
            sitecode: Three letter site code
            projnum: Single or list of project numbers
            gasnum: Single or list of gas numbers

        Returns:
            Returns a list of dicts with progam abbreviation and program number.
            Keys are 'program_num', 'name', 'abbr'
        """

        sitenum = self.getSiteNum(sitecode)

        self.db.sql.initQuery()
        self.db.sql.distinct()
        if project == 6:
            self.db.sql.table("hats_qc.flask_event e")
            self.db.sql.innerJoin("hats_qc.flask_data d on e.num=d.event_num")
        else:
            self.db.sql.table("ccgg.flask_event e")
            self.db.sql.innerJoin("ccgg.flask_data d on e.num=d.event_num")
        self.db.sql.innerJoin("gmd.program p on d.program_num=p.num")
        self.db.sql.col("d.program_num")
        self.db.sql.col("p.name")
        self.db.sql.col("p.abbr")

        self.db.sql.where("e.site_num=%s", sitenum)
        if isinstance(gasnum, list) or isinstance(gasnum, tuple):
            self.db.sql.wherein("d.parameter_num in", gasnum)
        else:
            self.db.sql.where("d.parameter_num=%s", gasnum)

        result = self.db.doquery()
#        print(self.db.sql.cmd() % self.db.sql.bind())

        return result


    #---------------------------------------------------------
    def flaskPairDiff(self, sitecode, gas, start=None, end=None, project=1, programs=None):
        """ Compute flask pair difference for a given site,gas and project number
            for dates from 'start' up to but not including 'end'

        Includes flagged flask data.

        Args:
            sitecode (str): Three letter site code
            gas (str): Gas formula, e.g. 'CO2'
            start (str): Start date, e.g. '2021-04-06'
            end (str): End date, e.g. '2021-04-06'
            project (int): Project number

        Returns:
            A list of tuples, each tuple contains
                (date, method, flaskid1, flaskid2, value1, value2, abs(value2-value1))
        """

        sitenum = self.getSiteNum(sitecode)
        paramnum = self.getGasNum(gas)

        self.db.sql.initQuery()
        if project == 6:
            self.db.sql.table("hats_qc.flask_event e")
            self.db.sql.innerJoin("hats_qc.flask_data d on e.num=d.event_num")
        else:
            self.db.sql.table("ccgg.flask_event e")
            self.db.sql.innerJoin("ccgg.flask_data d on e.num=d.event_num")
        self.db.sql.col("e.date")
        self.db.sql.col("e.time")
        self.db.sql.col("e.id")
        self.db.sql.col("e.me")
        self.db.sql.col("d.value")
        self.db.sql.col("d.flag")
        self.db.sql.where("e.site_num=%s", sitenum)
        self.db.sql.where("d.value > -999")
        self.db.sql.where("e.project_num=%s", project)
        if programs is None:
            self.db.sql.where("d.program_num=1")
        else:
            self.db.sql.wherein("d.program_num in", programs)

        self.db.sql.where("d.parameter_num=%s", paramnum)
#        self.db.sql.where("d.flag like '.._'")
        if start:
            self.db.sql.where("e.date >= %s" , start)
        if end:
            self.db.sql.where("e.date < %s" , end)
        self.db.sql.orderby("e.date")
        self.db.sql.orderby("e.time")
        self.db.sql.orderby("e.me")
        self.db.sql.orderby("e.id")

#        print(self.db.sql.cmd() % self.db.sql.bind())
        result = self.db.doquery()

        if len(result) == 0:
            return None

        t0 = datetime.time() # time 0
        data = []

        prev_method = None
        prev_date = None
        prev_qcflag = "..."

        # loop through results finding lines that match previous line in date and method
        for i, r in enumerate(result):
#            print(r)
            date = r['date']
            time = r['time']
            method = r['me']
            qcflag = r['flag']
            flaskid = r['id']

            # convert date and time to datetime
            dt = datetime.datetime.combine(date, t0) + time

            # check for matching pair (but not multiple aliquots from same flask)
            if dt == prev_date and method == prev_method and flaskid != prev_flaskid:
                value = r['value']
                flaskid = r['id']
                prev_value = result[i-1]['value']
                diff = round(abs(value - prev_value), 2)
                if qcflag[0:2] == ".." and prev_qcflag[0:2] == "..":
                    flagged = 0
                else:
                    flagged = 1
                data.append((dt, method, prev_flaskid, flaskid, prev_value, value, diff, flagged))

            prev_date = dt
            prev_method = method
            prev_flaskid = flaskid
            prev_qcflag = qcflag

        if len(data) == 0:
            return None

        return data


    #---------------------------------------------------------
    def getFlaskDataTagList(self, datanum):
        """ get tag numbers available for flask data number """

        args = [datanum]
        _c = self.db._conn.cursor()
        _c.callproc('tagwr_getFlaskDataTagList', args)
        result = _c.fetchall()
        _c.nextset()
        _c.close()

        return result

    #---------------------------------------------------------
    def getFlaskDataTags(self, datanum):
        """ get tag numbers already assigned to flask data number """

        args = [datanum]
        _c = self.db._conn.cursor()
        _c.callproc('tagwr_getFlaskDataTags', args)
        result = _c.fetchall()
        header = [li[0] for li in _c.description] #list of column names
        b = [dict(zip(header, row)) for row in result]
        _c.nextset()
        _c.close()

        return b

    #---------------------------------------------------------
    def addFlaskDataTag(self, datanum, tagnum, comment, user):
        """ add tag number from flask data number """

        args = [datanum, tagnum, comment, user]
        _c = self.db._conn.cursor()
        _c.callproc('tagwr_addFlaskDataTag', args)
        result = _c.fetchall()
        _c.nextset()
        _c.close()

        return result

    #---------------------------------------------------------
    def delFlaskDataTag(self, datanum, tagnum, user):
        """ remove tag number from flask data number """

        args = [datanum, tagnum, user]
        _c = self.db._conn.cursor()
        _c.callproc('tagwr_delFlaskDataTag', args)
        result = _c.fetchall()
        _c.nextset()
        _c.close()

        return result

    #---------------------------------------------------------
    def dbTableExists(self, table):
        """ Check if a table exists in a database """

        sql = " SHOW TABLES LIKE '%s'" % table
        result = self.db.doquery(sql)
        if result is None:
            return False

        return True


    #---------------------------------------------------------
    def getTables(self, searchstr):
        """ Get database tables that match a search string

        Args:
            searchstr (str): String to match a table name.  Do not include wildcard characters

        Returns:
            d (list): Returns a list of dicts with one key; 'table_name'
        """

        d = []
        sql = "show tables like '%" + searchstr + "%'"
        result = self.db.doquery(sql)

        # make a simpler key name for the results
        for row in result:
            for key, val in row.items():
                d.append({'table_name': val})


        return d

    #---------------------------------------------------------
    def getTableColumnNames(self, table):
        """ get column names of table in database. """

        query = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS "
        query += "WHERE table_schema=%s and table_name=%s;"
        result = self.db.doquery(query, (self.database, table))

        if result:
            field_names = [row["COLUMN_NAME"] for row in result]
        else:
            raise ValueError("Table name doesn't exist: %s" % table)

        return field_names


    #---------------------------------------------------------
    def getInstrumentNum(self, inst_id):
        """ Get instrument number from id character string """

        sql = "select num from ccgg.inst_description where id=%s"
        result = self.db.doquery(sql, (inst_id,))

        return result[0]['num']

    #---------------------------------------------------------
    def doquery(self, query, parameters=None, insert=False):
        """ Do a simple general query of the database.

        This method calls the doquery() method in :ref:`ccg_db_conn <db_conn>` but uses
        only two arguments, 'query' and 'parameters'.
        """

        result = self.db.doquery(query, parameters, insert=insert)

        return result

if __name__ == "__main__":

    db = dbUtils()
#    print(db.sql.cmd())
    print(db.getSiteNum('MLO'))
    print(db.getSiteCode(75))
    print(db.getSiteName('MLO'))
    print(db.getSiteNameFromNum(75))
    print(db.getSiteInfo('MLO'))
    print(db.getSiteInfoFromNum(75))
    print(db.getGasNum('CO2'))
    print(db.getGasFormula(1))
    print(db.getGasName('CO2'))
    print(db.getGasNameFromNum(1))
    print(db.getGasInfo('CO2'))
    print(db.getGasInfoFromNum(1))
    print(db.getProgramNum(('CCGG', 'HATS')))
    print(db.getProgramNum('CCGG'))
    print(db.getProgramAbbrFromProject(1))
    print(db.getProjectName(1))
    print(db.getIntakeHeights('MLO', 'CO2'))
    print(db.getBinInfo('POC', 1))
    print(db.getBinInfo('MLO', 1))
    print(db.getPrelimDate('MLO', 'CO2'))
    print(db.getDefaultScale('CO2'))
    print(db.getScaleNum('CO2_X2019'))
    print(db.getScaleName(13))
    print("-----------")
    print(db.getCurrentScale('CO2'))
    print(db.getStrategies('MLO', 1))
    print("********", db.getParameterList('MLO', 1, strategy=1))
    print("@@@@@", db.getSiteList(4))
    print(db.getSiteList(1, 1))
    print()
    print("@@@@@@@@@@@")
    print(db.getSiteList(2))
    print("@@@@@@@@@@@")
    print()
    print(db.getSiteList(3))
    print()
    print(db.getSiteList(4))
    print()
    print(db.getSiteList(5))
    print()
    print(db.getSitePrograms('MLO', 1))
    print(db.getTables("target"))
    print(db.doquery("select min(date), max(date) from mlo_co2_target"))
    print(db.getTableColumnNames('mlo_co2_insitu'))

#    db = dbUtils(readonly=False)

#    print(db.getFlaskDataTagList(498415))
#    print(db.getFlaskDataTags(498415))
    print(db.getGasNum('CFC11'))
#    print(db.doquery("SELECT * FROM reftank.grav_stds ORDER BY serial_number, date  "))

    print(db.getFlaskMethodList('MLO', 1, [1,2]))

    print("@@@@@@@@@@@")
    pd = db.flaskPairDiff('MLO', 'CO2', '2020-6-1', '2020-7-1')
    for p in pd:
        print(p)
#    print(pd[-1])
