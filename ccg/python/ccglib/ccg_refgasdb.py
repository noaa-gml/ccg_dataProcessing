# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for holding and manipulating reference gas information
from one of the scales tables.
Generally used for getting an assigned value for a tank on a certain date.

MODIFIED TO USE NEW STYLE db TABLES THAT INCLUDE TIME DEPENDENT UNCERTAINTIES - AMC

"""

from __future__ import print_function

import sys
import datetime
import math
from operator import attrgetter
from collections import namedtuple, defaultdict

import ccg_dates
import ccg_dbutils
import ccg_tankhistory

DEFAULT = -999.99

##################################################################
def calcAssignedValue(result, date):
    """ Calculate the mole fraction value from coefficients on the given date """

    dd = ccg_dates.decimalDateFromDatetime(date)
    x = dd - result.tzero
    mr = result.coef0 + result.coef1*x + result.coef2*x*x
    u = math.sqrt(result.unc_c0**2 + (result.unc_c1*x)**2 + (result.unc_c2*x*x)**2)

    # include this to be similar to prediction interval - modified Nov 29, 2023
    # result.sd_resid default value is 0, so no need to check if valid value exists
    unc = math.sqrt(u*u + result.sd_resid*result.sd_resid)

    return mr, unc

##################################################################
class refgas:
    """ Class for getting assigned value information.

    Usage:
        refgas = ccg_refgasdb.refgas(sp, sn=['CC71636'], scale = "CO_X2014", database=db, startdate=sdt, enddate=edt, moddate=md, verbose="", debug=True|False)

    Args:
        sp : The gas species of interest (e.g. 'CO2')
        sn : List of tank serial numbers
        scale : Name of the scale to use (default is current scale as defined in the reftank.scale DB table)
        database : Use a different database for refgas assignments
        startdate : Only include information after this date. Can be datetime object or valid date string.
        enddate : Don't include information after this date. Can be datetime object or valid date string.
        moddate : Modification date.  Use assigned values prior to this date.  Pass in as python datetime or as "yyyy-mm-dd" string.

    Members:

        refgas - A list of namedtuples with information on the reference gases
            Fields are
            ['serial_number', 'start_date', 'tzero', 'coef0', 'coef1', 'coef2', 'unc_c0', 'unc_c1', 'unc_c2', 'sd_resid', 'standard_unc', 'level', 'mod_date', 'comment']

    """

    def __init__(self,
            sp=None,
            sn=None,
            scale=None,
            database=None,
            location=None,
            use_history_table=False,
            startdate=None,
            enddate=None,
            moddate=None,
            readonly=True,
            verbose=False,
            debug=False
        ):
        """
        Initialize a reference gas object.
        There are 3 ways of getting reference gas data:
        1 - Directly from the scale tables
        2 - From a text file
        3 - From the scale tables but also using the tank history table. (observatory)

        Args:
            sp: the gas species, REQUIRED unless a scale is passed.

            sn: list of tank serial numbers to get information for.  If none, get all tanks

            scale: the scale to use.  Default is current scale for the gas.

            database: optional, if set then use refgas assignments from this database instead of default db.

            location: set to specify location from tank history table.  Only used if use_history_table=True

            use_history_table: optional, if set then get tank history for the given species and location
                to filter out tank serial numbers, then combine with values from scale table.  Mainly
                needed for observatory working tanks

            startdate: use reference gas information after this date, i.e. ignore info before this date
                   This is a datetime object

            enddate: ignore info after this date.
                 This is a datetime object

            moddate: optional, if specified, modifications of assignments after this date
                 are not included. This must be a python datetime object or "yyyy-mm-dd"
                 format string.

        """

        self.valid = True
        self.debug = debug
        self.verbose = verbose
        self.sp_num = None
        self.use_hour = False
        self.use_minute = False
        self.startdate = None
        self.enddate = None
        self.tank_history = None

        if startdate:
            self.startdate = ccg_dates.getDatetime(startdate)
        if enddate:
            self.enddate = ccg_dates.getDatetime(enddate)

        if moddate is None:
            self.moddate = datetime.datetime(9999, 12, 31)
        else:
            self.moddate = ccg_dates.getDatetime(moddate)

        if sp is None and scale is None:
            print("In class refgas, must specify either species or scale.", file=sys.stderr)
            self.valid = False
            return

        if database is None:
            database = "reftank"

        self.db = ccg_dbutils.dbUtils(database=database, readonly=readonly)

        # create a namedtuple object to hold results. will give it same names as in database tables
        self.field_names = self.db.getTableColumnNames("scale_assignments") + ['fill_code']
        self.Row = namedtuple('row', self.field_names)

        # allow sp to be passed in as formula, name, or number
        # convert name or number to formula for use
        if sp:
            try:
                # assume sp is a number
                self.sp_num = int(sp)
                self.sp = self.db.getGasFormula(self.sp_num)
            except ValueError:
                # sp is a string
                self.sp_num = self.db.getGasNum(str(sp))
                self.sp = sp

        if scale is None:
            row = self.db.getCurrentScale(sp)
            self.scale = row['name']
            self.scale_num = row['idx']
        else:
            self.scale = scale
            self.scale_num = self.db.getScaleNum(self.scale)
            if self.scale_num is None:
                sys.exit("ERROR: Can't find scale number for scale '%s'" % self.scale)

        if self.debug:
            print("scale for %s = %s" % (sp, self.scale), file=sys.stderr)


        if use_history_table:
            if self.debug: print("Getting reference gas values from history table and database.", file=sys.stderr)
            self.use_history = True
            self.tank_history = self._read_history(location)
            if sn:
                if isinstance(sn, str):
                    snlist = [sn]
                else:
                    snlist = sn
            else:
                # only use serial numbers from tank history
                snlist = [row.serial_number for row in self.tank_history]
                snlist = list(set(snlist))
            self.refgas = self._read_db_refgas(snlist, enddate=self.enddate)
            if self.startdate:
                self.refgas = self.filterByDate(self.startdate)

        else:
            if self.debug: print("Getting reference gas values from database %s." % database, file=sys.stderr)
            #read DB table for scale
            if isinstance(sn, str):
                sn = [sn]
            self.refgas = self._read_db_refgas(sn, self.startdate, self.enddate)
            self.use_history = False

        if not self.refgas:
            if self.verbose or self.debug:
                print("No reference gas information found for %s, %s." % (self.sp, sn), file=sys.stderr)
            self.valid = False
            return


    #--------------------------------------------------------------------------
    def _read_db_refgas(self, serialnums=None, startdate=None, enddate=None):
        """ Read assigned values for reference gases from database.

        Return a list of namedtuples with the information.
        (sn, start_dt, mdate, t0, coef0, coef1, coef2, unc_co, unc_c1, unc_c2, sd_resid, standard_unc, level, comment)
        """

        # get data from database, sorted by sn, start date, modification date
        whereclause = []
        sql = "SELECT * FROM scale_assignments "

        whereclause.append("scale_num=%s" % self.scale_num)
        if startdate:
            whereclause.append("start_date>='%s'" % startdate.date())
        if enddate:
            whereclause.append("start_date<='%s'" % enddate.date())

        if serialnums:
            s = ["'%s'" % n for n in serialnums]  # surround the serial number with single quote
            whereclause.append("serial_number in (%s)" % ','.join(s))

        if whereclause:
            sql += "WHERE "
            sql += " AND ".join(whereclause)
        sql += " ORDER BY serial_number, start_date, assign_date"

        # There can be multiple assignments with the same start_date for a tank.
        # We want the one with the latest assign_date.
        # This statement will get the latest assign_date for each unique start_date for each tank.
        # The limit 999999 is needed to keep the descending sort.
        sql = "select * from (" + sql + " desc limit 999999) as zzz group by serial_number, start_date"

        if self.debug: print(sql)
        result = self.db.doquery(sql)

        data = []
        if result:
            for line in result:

                # convert start date from date to datetime
                date = line['start_date']
                start_dt = datetime.datetime(date.year, date.month, date.day, 0, 0)
                if line['comment']:
                    line['comment'] = line['comment'].strip()
                line['start_date'] = start_dt
                line['fill_code'] = self._get_fillcode(line['serial_number'], line['start_date'])

                t = self.Row(**line)

                data.append(t)

#        print("@@@")
#        for row in data: print(row)

        return data


    #--------------------------------------------------------------------------
    def _read_history(self, location):
        """ Get entries from tank_history table for the specified location """

        hist = ccg_tankhistory.tankhistory(gas=self.sp, location=location, debug=self.debug)

        # filter out results that come before start date
        if self.startdate:
            data = hist.filterByDate(self.startdate, self.enddate)
        else:
            data = hist.data

        return data

    #--------------------------------------------------------------------------
    def filterByDate(self, startdate):
        """ Find entries that have start_date >= given startdate,
        and the last entry before the startdate.

        Need to save, for each tank label, the last entry before start date, and any after start date
        """

        tmpdata = defaultdict(list)
        # save the data by the tank serial number
        for t in self.refgas:
            tmpdata[t.serial_number].append(t)

        data = []
        for key in list(tmpdata.keys()):
            tmpdata[key].sort(key=attrgetter('start_date')) # sort by date
            tmplist = []

            for t in tmpdata[key]:
                if t.start_date < startdate:
                    tmplist = [t]       # last one before start date
                else:
                    tmplist.append(t)   # any after start date

            data.extend(tmplist)    # save entries for this tank label

        return data


    #--------------------------------------------------------------------------
    def getRefgasBySerialNumber(self, sernum, adate, fillcode=None, showWarn=True):
        """ Get mixing ratio of tank with serial number on adate.
            Pass adate as python datetime.
        """

        mr = DEFAULT
        unc = DEFAULT/10.0
        dd = ccg_dates.decimalDateFromDatetime(adate)

        row = self.getAssignment(sernum, adate, fillcode=fillcode)
        if row is None:
            if showWarn:
                if mr == DEFAULT:
                    print("Assigned value for ", sernum, "on", adate.date(), "not found.", file=sys.stderr)

        else:
            mr, unc = self._calc_mr(row, dd)

        return (mr, unc)


    #--------------------------------------------------------------------------
    def getAssignment(self, sernum, adate, fillcode=None):
        """ Return the refgas row that is the correct one for the given date.

        Because there can be multiple rows for a tank, use the one that has
        the latest assign_date.
        """

        result = None

        # make sure adate is a datetime.datetime instance
        adate = ccg_dates.getDatetime(adate)
        dd = ccg_dates.decimalDateFromDatetime(adate)

        # get the fill code for the requested date
        if fillcode is None:
            fillcode = self._get_fillcode(sernum, adate)

        # make sure results are sorted by start date, mod date so that most recent mod date is last
        self.refgas.sort(key=attrgetter('start_date', 'assign_date'))
#        print("$$$")
#        for row in self.refgas: print(row)

        # find the refgas assignment row that matches the serial number and fill code
        # and comes before or on the requested date
        # There can be multiple start dates for the same tank filling.
        # Find the last start date before the desired date here
        if self.debug: print("\nget assignment for", sernum, "on", adate, "for fillcode", fillcode)
        for row in self.refgas:
#            if self.debug: print(row)
            if row.serial_number.upper() != sernum.upper(): continue
            if self.debug:
                print("found", row)
                print(row.start_date, adate)
                print(row.assign_date, self.moddate)
                print(row.fill_code, fillcode)
#            fcode = self._get_fillcode(sernum, row.start_date)
            fcode = row.fill_code
            if (row.start_date <= adate
                and row.assign_date <= self.moddate
                and fcode == fillcode):
                result = row

        return result

    #--------------------------------------------------------------------------
    def getAssignedValue(self, sernum, adate, showWarn=True):
        """ Convenience method for getting assigned value for a tank

        Input:
            sernum - serial number of tank
            adate - date on which to calculate the assigned value

        Returns:
            val - assigned value, as a single float, not as a tuple like
                  in getRefgasBySerialNumber
        """

        adate = ccg_dates.getDatetime(adate)
        val, unc = self.getRefgasBySerialNumber(sernum, adate, showWarn=showWarn)

        if val < -999:
            return None

        return val

    #--------------------------------------------------------------------------
    def getRefgasByLabel(self, label, adate, showWarn=True):
        """ Get serial number and mixing ratio of tank on adate based on label.

        Args:
            label - label of the tank (R0, S1, S2 ...)
            adate - Date to get assignment for.  Either a python datetime or "yyyy-mm-dd" string.

        Returns:
            result - namedtuple with (serial num, val, unc) 
        """

        mr = DEFAULT
        unc = DEFAULT/10.0
        sernum = "None"

        if self.use_history is False:
            print("GetRefgasByLabel only valid when using tank_history database tables", file=sys.stderr)
            return (sernum, mr, unc)

        # make sure adate is a datetime.datetime instance
        adate = ccg_dates.getDatetime(adate)
        dd = ccg_dates.decimalDateFromDatetime(adate)

        if self.use_history:
            # Find serial number of tank for given date and label
            # already sorted by label, date, so that last match is the one to use
            for row in self.tank_history:
                if row.label != label: continue
                if row.start_date <= adate:
                    sernum = row.serial_number
                    fillcode = row.fill_code

            if sernum == 'None':
                if showWarn:
                    print("WARNING in ccg_refgasdb.py: Cannot find tank with label %s on %s" % (label, adate), file=sys.stderr)
            else:
                # find correct refgas entry for serial number and date
                mr, unc = self.getRefgasBySerialNumber(sernum, adate, fillcode=fillcode, showWarn=showWarn)

        else:
            # NEED TO RE-SORT BY LABEL/DATE RATHER THAN SERIAL NUMBER
            self.refgas.sort(key=attrgetter('level', 'start_date'))

            for row in self.refgas:
                if row.level.upper() == label.upper() and row.start_date <= adate and row.assign_date <= self.moddate:
                    mr, unc = self._calc_mr(row, dd)
                    sernum = row.serial_number

            if showWarn:
                if mr == DEFAULT:
                    print("WARNING: Assigned value for ", label, "on", adate.date(), "not found.", file=sys.stderr)

#        return (sernum, mr, unc)
        t = namedtuple("refgas", ["serial_num", "value", "unc"])
        return t._make((sernum, mr, unc))

    #--------------------------------------------------------------------------
    def _get_fillcode(self, serial_number, date):
        """ Get the fill code for given tank serial number
        on the given date.
        """

        code = self.db.getFillCode(serial_number, date.date())

        return code


    #--------------------------------------------------------------------------
    def getEntries(self, label):
        """ Get all refgas entries where label=label """

        data = []
        if self.use_history:
            for r in self.tank_history:
                if r.label == label:
                    data.append(r)
        else:
            for r in self.refgas:
                print(r)
                if r.level == label:
                    data.append(r)

        return data

    #--------------------------------------------------------------------------
    @staticmethod
    def _calc_mr(result, dd):
        """ Calculate the mole fraction value from coefficients """

        x = dd - result.tzero
        mr = result.coef0 + result.coef1*x + result.coef2*x*x
        u = math.sqrt(result.unc_c0**2 + (result.unc_c1*x)**2 + (result.unc_c2*x*x)**2)

        # include this to be similar to prediction interval - modified Nov 29, 2023
        # result.sd_resid default value is 0, so no need to check if valid value exists
        unc = math.sqrt(u*u + result.sd_resid*result.sd_resid)

        return mr, unc

    #--------------------------------------------------------------------------
    def getInfo(self, sernum, adate):
        """ return the information on the standard rather than the assigned value.
        Pass adate as python datetime or "yyyy-mm-dd" string.

        Output line = sn yr mo dy t0 coef0 coef1 coef2 transfer_unc standard_unc level mod_date #comment
        """

        info = []

        # make sure adate is a datetime.datetime instance
        adate = ccg_dates.getDatetime(adate)

        infoline = None
        for t in self.refgas:

            if t.serial_number.upper() == sernum.upper() and t.start_date <= adate and t.assign_date <= self.moddate:
                infoline = self._format_info(t)

        info.append(infoline)

        return info


    #--------------------------------------------------------------------------
    def _format_info(self, t):
        """ Format the information line.
        normal output:
            sn year month day [hour] t0 coef0 unc_c0 coef1 unc_c1 coef2 unc_c2 sd_resid unc2 level

        if verbose add:
            # moddate comments
        """

        date_str = t.start_date.strftime("%Y %m %d %H %M")

        frmt = "%-15s %s %9.4f %14.6f %14.6f %14.6f %14.6f %14.6f %14.6f %14.6f %14.6f %s"
        info = frmt % (t.serial_number, date_str, t.tzero, t.coef0, t.unc_c0, t.coef1, t.unc_c1, t.coef2, t.unc_c2, t.sd_resid, t.standard_unc, t.level)

        if self.verbose:
            info += " #%s %s" % (t.assign_date.strftime("%Y-%m-%d"), t.comment)

        return info


    #--------------------------------------------------------------------------
    def getHistory(self, sernum):
        """ Return the history of the standard.  All fills, all modifications.
        Output line = sn yr mo dy t0 coef0 coef1 coef2 transfer_unc standard_unc level mod_date #comment
        """

        info = []

        for t in self.refgas:
            if t.serial_number == sernum.upper():
                info.append(self._format_info(t))

        return info

    #--------------------------------------------------------------------------
    def printTable(self):
        """ prints a table of all standards (each start date) selected by the
        modification date if passed.  Does not print comments.
        Output line = sn yr mo dy t0 coef0 unc_c0 coef1 unc_c1 coef2 unc_c2 sd_resid standard_unc level #
        """
        info = []
        table = []
        oldkey = ""
        # write header to table
        header = "#SerialNumber Year Month Day Hour Minute"
        header += " Tzero  coef0  unc_c0   coef1  unc_c1   coef2  unc_c2   sd_resid  standard_unc  level"

        if self.verbose:
            header += "  #moddate comment"
        table.append(header)

        # sort by label, date
        self.refgas.sort(key=attrgetter('level', 'start_date'))

        for t in self.refgas:

            #Test moddate, if > passed moddate then don't put into table
            if t.assign_date > self.moddate: continue

            #Test to see if current line is a new modification of the previous line.
            #If it is then remove the previous line.
            newkey = "%s %s" % (t.serial_number, t.start_date.strftime("%Y-%m-%d %H:%M:%S"))
            if newkey == oldkey:
                info.pop()
            oldkey = newkey
            info.append(t)

        for t in info:
            table.append(self._format_info(t))

        return table

    #--------------------------------------------------------------------------
    def insert(self, serial_number, start_date, tzero=0, coef0=0, coef1=0, coef2=0, level='', comment=''):
        """ Insert a new entry into the scale assignments database table.

        For now, only parts of the fields are updated. Uncertainty terms are ignored here.
        """

        sql = "insert into scale_assignments "
        sql += "set serial_number='%s', " % serial_number
        sql += "scale_num=%s, " % self.scale_num
        if isinstance(start_date, datetime.datetime):
            sql += "start_date='%s', " % start_date.date()
        else:
            sql += "start_date='%s', " % start_date
        sql += "tzero=%f, " % tzero
        sql += "coef0=%f, " % coef0
        sql += "coef1=%f, " % coef1
        sql += "coef2=%f, " % coef2
        sql += "level='%s', " % level
        sql += "comment='%s'" % comment
#        print(sql)

        self.db.doquery(sql)

    #--------------------------------------------------------------------------
    def insertFromFit(self, serial_number, start_date, calfit, level='', comment=''):
        """ Insert a new entry into the scale assignments database table.

        Input
            serial_number - serial number of the tank
            start_date - date when to start using the assigned values
            calfit - a namedtuple from ccg_calfit.fitCalibrations()
            level - level of the tank, e.g. 'primary', 'secondary' ...
            comment - a text comment
        """

        now = datetime.datetime.now()

        sql = "insert into scale_assignments "
        sql += "set serial_number='%s', " % serial_number.upper()
        sql += "scale_num=%s, " % self.scale_num
        if isinstance(start_date, datetime.datetime):
            sql += "start_date='%s', " % start_date.date()
        else:
            sql += "start_date='%s', " % start_date
        sql += "tzero=%f, " % calfit.tzero
        sql += "coef0=%f, " % calfit.coef0
        sql += "coef1=%f, " % calfit.coef1
        sql += "coef2=%f, " % calfit.coef2
        sql += "unc_c0=%f, " % calfit.unc_c0
        sql += "unc_c1=%f, " % calfit.unc_c1
        sql += "unc_c2=%f, " % calfit.unc_c2
        sql += "sd_resid=%f, " % calfit.sd_resid
        sql += "n=%d, " % calfit.n
        sql += "level='%s', " % level
        sql += "assign_date='%s', " % (now.strftime("%Y-%m-%d %H:%M:%S"))
        sql += "comment='%s'" % comment
#        print(sql)

        idx = self.db.doquery(sql, insert=True)

        for cal_idx in calfit.calibrations:
            sql = "insert into scale_assignment_calibrations set "
            sql += "scale_assignment_num=%s, "
            sql += "calibrations_idx=%s"
            self.db.doquery(sql, (idx, cal_idx), insert=True)


        return idx



if __name__ == '__main__':

    sdt = datetime.datetime(2022, 8, 22)
    edt = datetime.datetime(2022, 8, 23)
    ref = refgas("CO2", ["CA06138"], location="SPO", use_history_table=True, startdate=sdt, enddate=edt, debug=True)
#    ref = refgas("CO2", ["CA06138"], location="SPO", use_history_table=True, debug=True)
    print("-----")
#    for row in ref.refgas:
#        print(row)
    row = ref.getAssignment("CA06138", sdt)
    print(row)
    sys.exit()
