
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for processing tank calibration results.

Calibration data is in the 'reftank' database.  The table 'calibrations'
has the results, and the table 'fill' has filling information.
"""

import datetime
import json
from numpy import mean, std

import sys
sys.path.append("/ccg/python/ccglib")
import ccg_db_conn
import ccg_uncdata_all
import ccg_calfit

json.encoder.FLOAT_REPR = lambda o: format(o, '.3f')

# Update these to specify 'official' instrument id's
INST_CODES = {
    "co2": "U1,U2,U3,U4,U6,S2,S4,S5,L1,L2,L9,PC1",
    "ch4": "H5,C2,C3,C4,H7,PC1",
    "co":  "V1,V2,V3,LGR2,R2,R7",
    "n2o": "HP,VC,AR3",
    "sf6": "HP,VC",
    "h2":  "R7,P2,H9",
}

###########################################################
def get_syslist(gas=None):
    """ Get list of instrument id's for 'official' instruments """

    if gas is None:
        # combine all analyzer codes and create a unique list of codes
        x = [INST_CODES[key] for key in list(INST_CODES.keys())]
        s = ",".join(x)
        a = list(set(s.split(",")))
    else:
        a = INST_CODES[gas.lower()].split(",")

    # add single quotes around each code and create a comma separated string
    tmplist = ["'" + s + "'" for s in a]
    syslist = ",".join(tmplist)

    return syslist

###########################################################
def _decimalDate(year, month, day, hour=0, minute=0, second=0):
    """ Convert a date and time to a fractional year. """

    doy = datetime.datetime(year, month, day, hour, minute, second).timetuple().tm_yday
    soy = (doy-1)*86400 + hour*3600 + minute*60 + second

    if year % 4 == 0 and year % 100 != 0 or year % 400 == 0:
        dd = year + soy/3.16224e7
    else:
        dd = year + soy/3.1536e7

    return dd


########################################################################
def _getTerminalWidth(fd=1):
    """
    Returns height and width of current terminal. First tries to get
    size via termios.TIOCGWINSZ, then from environment. Defaults to 25
    lines x 80 columns if both methods fail.

    :param fd: file descriptor (default: 1=stdout)

    from http://blog.taz.net.au/2012/04/09/getting-the-terminal-size-in-python/
    """
    try:
        import fcntl, termios, struct, os
        hw = struct.unpack('hh', fcntl.ioctl(fd, termios.TIOCGWINSZ, '1234'))
    except:
        try:
            hw = (os.environ['LINES'], os.environ['COLUMNS'])
        except:
            hw = (25, 80)

    return hw[1]


########################################################################
class Calibrations:
    """
    Args:
        tank : tank serial number
        gas : gas formula, e.g. 'CO2'
        syslist : comma separated list of instrument id's to use, e.g. 'L8,L10,L4'
        fillingcode : A fill code letter A-Z. Use calibrations for this filling code only.
        date : Get calibrations for this date only.  A datetime object.
        method : Include calibrations for this method too. Method is set in cal raw file, e.g. 'NDIR', 'CDRS', 'GC'...
        official : Use calibrations for 'official' calibration systems only.  See INST_CODES dict below.
        notes : Include data from the 'notes' field in output.
        quiet : If true, suppress warning messages.
        uncfile : If set, use a calibration uncertainty table different from default
        database : Specify the database to use.
        dbconn : Use an already created database connection instead of making a new connection.
        readonly : Open database in readonly mode by default.  Set to 'True' to do updates.

    Members:

        * cals : list of dicts containing data about the calibration
        * flasks : list of dicts with isotope data measured in flasks filled from the tank

    """

    def __init__(self,
                 tank=None,
                 gas=None,
                 syslist=None,
                 fillingcode=None,
                 date=None,
                 method=None,
                 official=False,
                 notes=False,
                 quiet=False,
                 uncfile=None,
                 database='reftank',
                 dbconn=None,
                 readonly=True):

        if gas is not None:
            self.gas = gas.upper()
        else:
            self.gas = None
        self.tank = tank
        self.fillingcode = fillingcode
        self.date = date
        self.include_notes = notes
        self.quiet = quiet
        self.official = official
        self.method = method
        self.cals = []
        self.flasks = []
        if database is None:
            database = "reftank"
        self.database = database # need this for json output

        if syslist:
            self.syslist = ",".join(["'" + s + "'" for s in syslist.split(",")])
        else:
            self.syslist = syslist

        if readonly:
            if dbconn is None:
                self.db = ccg_db_conn.RO(db=database)
            else:
                self.db = dbconn
        else:
            if dbconn is None:
                self.db = ccg_db_conn.ProdDB(db=database)
            else:
                self.db = dbconn

        # read table with uncertainty values
#        self.cal_unc = ccg_calunc.CalUnc(uncfile)
        self.cal_unc = ccg_uncdata_all.dataUnc('cals', self.gas, uncfile=uncfile)

        if self.tank is None and self.date is None:
            self._get_tanks()

        else:
            self._get_fill_list(self.tank)
            self._get_results()

        self.numcals = len(self.cals)

        # create a dict of scale names for each gas.  Needed for json output
        self.scales = {}
        for g in self._get_species():
            scale = self._get_scale(g)
            self.scales[g] = scale


    #------------------------------------------------------------------------
    def _get_tanks(self):
        """ Get serial numbers of all tanks in database """

        sql = "SELECT DISTINCT serial_number FROM calibrations "

        whereclause = []
        if self.gas: whereclause.append("species='%s' " % (self.gas))
        if self.syslist: whereclause.append("inst in (%s) " % self.syslist)
        if whereclause:
            sql += "WHERE "
            sql += " AND ".join(whereclause)
        sql += "ORDER BY serial_number"

        self.tanks = self.db.doquery(sql)
        if self.tanks is None:
            self.tanks = []


    #------------------------------------------------------------------------
    def _get_results(self):
        """ Get the calibration results from the database. """

        whereclause = []
        if self.date: whereclause.append("date='%s' " % self.date)
        if self.tank: whereclause.append("serial_number='%s' " % self.tank)
        if self.gas: whereclause.append("species='%s' " % (self.gas))
        if self.syslist:
            if self.method:
                whereclause.append("(inst in (%s) OR method='%s')" % (self.syslist, self.method))
            else:
                whereclause.append("inst in (%s) " % self.syslist)
        elif self.official:
            if self.method:
                whereclause.append("(inst in (%s) OR method='%s')" % (get_syslist(self.gas), self.method))
            else:
                whereclause.append("inst in (%s) " % get_syslist(self.gas))


        sql = "SELECT * FROM calibrations "
        if whereclause:
            sql += "WHERE "
            sql += " AND ".join(whereclause)
        sql += " ORDER BY date,time"

        result = self.db.doquery(sql)

        if result:
            for row in result:
                # if date is set but tank serial num is not
                if self.tank is None:
                    self._get_fill_list(row['serial_number'])

                # get fill code for this date
                date = row['date']
                code = self.getFillCode(date)
                row['fillcode'] = code
                if self.fillingcode and code != self.fillingcode: continue

                # get decimal date
                (hr, minute, sec) = str(row['time']).split(":")
                dd = _decimalDate(date.year, date.month, date.day, int(hr), int(minute), int(sec))
                row['dd'] = dd

                # check if system name is blank
                if row['system'] == '': row['system'] = "None"

                if row['notes'] is None:
                    row['notes'] = ""
                row['notes'] = str(row['notes']).replace("\n", "")

                # check if location is null
                if row['location'] is None: row['location'] = "None"

                # get type B uncertainty from table
#                unc = self.cal_unc.getUnc(row['species'], row['system'], row['inst'], date, row['mixratio'])
                unc = self.cal_unc.getUncertainty(row['location'], date, row['mixratio'], inst=row['inst'], system=row['system'])
#                print("unc is", unc)
                # getUncertainty() returns -999.99 if no matching rules are found.  Handle this here.
                if unc < 0:
                    unc = 0
#                row['unc'] = unc
                row['typeB_unc'] = unc

                self.cals.append(row)

        # if gas isn't specified but official is true, then filter out any cals that are not official for each gas
        # (e.g. LGR2 is official for co but not n2o, but the above query will get n2o LGR2 cals even if official is True)
        if self.gas is None and self.official:
            mycals = []
            gaslist = self._get_species()
            for mygas in gaslist:
                syslist = get_syslist(mygas)

                # get only the cals for this gas
                cals = [d for d in self.cals if d['species'].lower() == mygas.lower()]
                cals = [d for d in cals if d['inst'] in syslist]

                mycals = mycals + cals

            self.cals = mycals
            

        # get isotope flask data for certain cases
        if (self.gas == "CO2C13" or self.gas == "CO2O18" or self.gas is None) and self.tank is not None:
            self._get_flasks()



    #------------------------------------------------------------------------
    def _get_fill_list(self, tanksn):
        """ Get filling information for a specific tank serial number """

        if tanksn is None: return

        sql = "SELECT serial_number,date,code,location,method,type,h2o,notes FROM reftank.fill "
        sql += "WHERE serial_number='%s' ORDER BY date" % (tanksn)

        self.fill = self.db.doquery(sql)
        # if no results, return empty list
        if self.fill is None:
            self.nfill = 0
            self.fill = []
            return

        # add a fake row at the end to use as end fill
        dt = datetime.date(9999, 12, 31)
        self.fill.append({
            'serial_number':self.tank,
            'date':dt,
            'code':"Z",
            'location':'BLD',
            'method':None,
            'type':None,
            'h2o':0,
            'notes':'Fake entry'
        })
        self.nfill = len(self.fill)


    #------------------------------------------------------------------------
    def showDbList(self):
        """ Show serial number of tanks that have been calibrated. """

        text = ""

        # output formatted as multi column
        maxl = 0
        for line in self.tanks:
            l = len(line['serial_number'])
            if l > maxl: maxl = l

        colwidth = maxl + 2
        fmt = "%%-%ds" % (colwidth-1)
        columns = _getTerminalWidth()
    #       columns -= 10  # leave some space for scrollbar
        ncolumns = columns//colwidth
        nentries = len(self.tanks)
        nrows = nentries//ncolumns + 1

        if nentries > 0:
            for row in range(0, nrows):
                for n in range(0, ncolumns):
                    ix = row + (nrows * n)
                    if ix < nentries:
                        text += fmt % (self.tanks[ix]['serial_number']) + " "
                text += "\n"

        return text.rstrip()

    #------------------------------------------------------------------------
    def showFillList(self, fmt="text", header=True):
        """ Print out list of filling information for a tank """

        text = []
        if fmt == "csv":
            format1 = "%s,%s,%s,%s,%s,%s,%s,%s"
        else:
            format1 = "%11s %12s %5s %14s %12s %10s %7s   %s"

        if header:
            if fmt == "csv":
                text.append("Serial_Number,Fill_Date,Code,Location,Method,Type,H2o,Notes")
            else:
                text.append("Serial Number  Fill Date   Code      Location      Method        Type     H2o    Notes")
                text.append("--------------------------------------------------------------------------------------")

        for row in self.fill:
            line = format1 % (
                row['serial_number'],
                row['date'],
                row['code'],
                row['location'],
                row['method'],
                row['type'],
                row['h2o'],
                row['notes']
            )

            if row['code'] == 'Z': continue

            if self.date is not None:
                fc = self.getFillCode(self.date)
                if fc == row['code']:
                    text.append(line)

            else:
                text.append(line)

        return "\n".join(text)

    #------------------------------------------------------------------------
    def showResults(self, fmt="text", showheader=True, showflasks=True, legacy=False):
        """
        Print calibration results, either as table of dates and mole fractions,
        or as table of calibrations with average and standard deviation for
        each fill code.

        Formatting of output depends on the how the 'fmt' variable is set.
        Also co2c13 and co2o18 have different headers and format from other gases.
        """

        if fmt == "json":
            text = self._print_json(self.cals)
            return text

        gaslist = self._get_species()

        text = ""

        if gaslist and fmt == "csv":
            text += "serial_number,fillcode,date,time,species,system,instrument,method,pressure,value,std.dev.,flag,scale,uncertainty\n"

        for mygas in gaslist:

            # get only the cals for this gas
            cals = [d for d in self.cals if d['species'].lower() == mygas.lower()]

            if len(cals) == 0:
                if (not self.quiet or fmt == "html") and (mygas not in ("CO2C13", "CO2O18")):
                    text += "No %s data for %s " % (mygas, self.tank)
                continue

            if showheader and fmt == "text":
                text += "\n%s CALIBRATION SUMMARY FOR TANK # %s\n\n" % (mygas.upper(), self.tank)
                if legacy:
                    text += "        Date     Loc     Gas   Inst Press   Value     S.D.     Num    Avg    Sdev\n"
                    text += "---------------------------------------------------------------------------------\n"
                else:
                    text += "        Date     Loc     Gas   System     Inst Press   Value     S.D.     Num    Avg    Sdev\n"
                    text += "--------------------------------------------------------------------------------------------\n"


            fcodes = self._get_fill_codes_for_cals(cals)
            for fillcode in fcodes:
                fcals = [d for d in cals if d['fillcode'] == fillcode]

                if fmt == "text":
                    text += self._print_text(fcals, legacy)
                elif fmt == "html":
                    text += self._print_html(fcals, fillcode, mygas)
                elif fmt == "csv":
                    text += self._print_csv(fcals)


            if fmt == "text":
                text += self._check_cals(cals)

        if self.gas is None:
            if showflasks:
                text += self._print_flasks("CO2C13", fmt)
                text += self._print_flasks("CO2O18", fmt)
        elif (self.gas == "CO2C13" or self.gas == "CO2O18") and len(self.cals) == 0:
            if showflasks:
                text += self._print_flasks(self.gas, fmt)

        return text.rstrip()

    #------------------------------------------------------------------------
    def showAverages(self, fmt="text"):
        """ Print only average values for each fillcode, not individual calibrations """

        text = []

        format1 = "%s %s %3d %9.3f %7.3f %s\n"
        if fmt == "csv":
            format1 = "%s,%s,%d,%.3f,%.3f,%s\n"

        gaslist = self._get_species()

        if gaslist and fmt == "csv":
            text.append("fillcode,serial_number,num_cals,average,std.dev.,gas")

        for mygas in gaslist:

            # get cals for this gas
            cals = [d for d in self.cals if d['species'].lower() == mygas.lower()]

            fcodes = self._get_fill_codes_for_cals(cals)
            for fillcode in fcodes:
                fcals = [d for d in cals if d['fillcode'] == fillcode]

                # get average values for each fillcode
                avg, stdv, num = self.getAvgs(fcals)
                text.append(format1 % (fillcode, self.tank, num, avg, stdv, mygas))

        return "\n".join(text)

    #------------------------------------------------------------------------
    def showTankSummary(self, fmt="text", showheader=True):
        """ Print out summary calibration results """

        if fmt == "json":
            text = self._print_json(self.cals)
            return text

        text = []

        if showheader:
            if fmt == "csv":
                if self.include_notes:
                    text.append("Serial_num,Fillcode,Date,Time,Gas,M.R.,S.D.,N,Type,Inst,System,Pressure,Flag,Notes")
                else:
                    text.append("Serial_num,Fillcode,Date,Time,Gas,M.R.,S.D.,N,Type,Inst,System,Pressure,Flag")
            else:
                if self.include_notes:
                    text.append(" Serial #  Fillcode       Date       Time        Gas      M.R.      S.D.     N           Type      Sytem    Inst  Pressure Flag  Notes")
                    text.append("--------------------------------------------------------------------------------------------------------------------------------------")
                else:
                    text.append(" Serial #  Fillcode       Date       Time        Gas      M.R.      S.D.     N           Type      System   Inst  Pressure Flag")
                    text.append("-------------------------------------------------------------------------------------------------------------------------------")

        if fmt == "csv":
            _format = "%s,%s,%s,%s,%s,%.3f,%.3f,%d,%s,%s,%s,%s,%s"
            if self.include_notes:
                _format += ",%s"
        else:
            _format = "%-12s %5s %15s %9s %8s %10.3f %8.3f %4d %18s %8s %5s %8s %5s"
            if self.include_notes:
                _format += "  # %s"

        for d in self.cals:
            t = (
                d['serial_number'],
                d['fillcode'],
                d['date'],
                d['time'],
                d['species'],
                d['mixratio'],
                d['stddev'],
                d['num'],
                d['method'],
                d['system'],
                d['inst'],
                d['pressure'],
                d['flag']
            )
            if self.include_notes: t = t + (d['notes'],)

            text.append(_format % t)

        return "\n".join(text)

    #------------------------------------------------------------------------
    def showTable(self, fmt="text"):
        """ Print results in a table format.
        This means print decimal date instead of date string
        """

        text = []

        format1 = "%12.6f %8.3f %1s %4s"
        if fmt == "csv":
            format1 = "%.6f,%.3f,%s,%s"

        gaslist = self._get_species()

        if gaslist and fmt == "csv":
            text.append("fillcode,serial_number,num_cals,average,std.dev.,gas")

        for mygas in gaslist:

            # get cals for this gas
            cals = [d for d in self.cals if d['species'].lower() == mygas.lower()]
            for d in cals:
                text.append(format1 % (d['dd'], d['mixratio'], d['flag'], d['fillcode']))

        return "\n".join(text)


    #------------------------------------------------------------------------
    def showCalsByFill(self, fmt="text"):
        """ Print cals by fill.  This will print a header for every fillcode,
        even if there are no cals for that fillcode.
        """

        text = []

        gaslist = self._get_species()

        if gaslist and fmt == "csv":
            text.append("fillcode,serial_number,num_cals,average,std.dev.,gas")

        for mygas in gaslist:

            for dct in self.fill:
                fillcode = dct['code']
                if fillcode == 'Z': continue

                cals = [d for d in self.cals if d['fillcode'] == fillcode and d['species'].lower() == mygas.lower()]

                if fmt != "csv":
                    text.append("\n%s Calibrations for fill code %s" % (mygas, fillcode))

                format1 = "%2s %10s  %3s %5s %4s %5s  %8.3f %6.3f %1s"
                format2 = "%s,%s,%s,%s,%s,%s,%.3f,%.3f,%s"
                if self.include_notes:
                    format1 += " # %s"
                    format2 += ",%s"

                _format = format1
                if fmt == "csv": _format = format2

                for d in cals:
                    t = (
                        d['fillcode'],
                        d['date'],
                        d['location'],
                        d['species'],
                        d['inst'],
                        d['pressure'],
                        d['mixratio'],
                        d['stddev'],
                        d['flag'],
                    )
                    if self.include_notes: t = t + (d['notes'],)

                    text.append(_format % t)

        return "\n".join(text)


    #------------------------------------------------------------------------
    def _print_text(self, cals, legacy=False):
        """ Print results in text format .
        cals is list of calibration results for a single gas.
        """

        s = []

        _format = "%4s %10s  %3s %7s %10s %6s %5s  %8.3f %7.3f %1s"
        _format2 = "%75d%9.3f %7.3f"
        if legacy:
            _format = "%4s %10s  %3s %7s %6s %5s  %8.3f %7.3f %1s"
            _format2 = "%65d%9.3f %7.3f"
        if self.include_notes: _format += " # %s"

        for d in cals:
            pressure = d['pressure']
            if pressure is None: pressure = 0

            if legacy:
                t = (
                    d['fillcode'],
                    d['date'],
                    d['location'],
                    d['species'],
                    d['inst'],
                    pressure,
                    d['mixratio'],
                    d['stddev'],
                    d['flag'],
                )
            else:
                t = (
                    d['fillcode'],
                    d['date'],
                    d['location'],
                    d['species'],
                    d['system'],
                    d['inst'],
                    pressure,
                    d['mixratio'],
                    d['stddev'],
                    d['flag'],
                )

            if self.include_notes: t = t + (d['notes'],)
            s.append(_format % t)


        avg, stdv, num = self.getAvgs(cals)
        s.append(_format2 % (num, avg, stdv))

        return "\n".join(s) + "\n"

    #------------------------------------------------------------------------
    def _print_html(self, cals, fcode, gas):
        """ Print results in format for a web page.
        Since these results go to the public, for co2c13 and co2o18 results,
        show only one significant digit and don't calculate and show the
        average for them.
        """

        text = ""
        scale = self.scales[gas]

        if gas.lower() == 'co2c13' or gas.lower() == 'co2o18':
            text += "\n%s INFORMATION FOR TANK # %s\n" % (gas.upper(), self.tank)
            text += "<pre>\n"
            text += " Fill   Date     Loc     Gas  Inst Press   Value \n"
            text += "-------------------------------------------------\n"
        else:
            text += "Filling Code <span class='fillcode bold blue'>%s.</span>&nbsp;&nbsp; Scale %s\n" % (fcode, scale)
            text += "<pre>\n"
            text += "        Date     Loc  Inst Pressure   Value    S.D.   Unc*      Num    Avg    Sdev\n"
            text += "------------------------------------------------------------------------------\n"

        for d in cals:
            fillcode = d['fillcode']
            caldate = d['date']
            mr = d['mixratio']
            sd = d['stddev']
            location = d['location']
            pressure = d['pressure']
            inst = d['inst']
            flag = d['flag']
            species = d['species']
            unc = d['typeB_unc']

            # text += result of this cal
            if pressure is None: pressure = " "
            if species.lower() in ["co2c13", "co2o18"]:
                if mr < -999:
                    text += "%4s %10s  %3s %7s %4s %5s    -999.9\n" % (fillcode, caldate, location, species, inst, pressure)
                else:
                    text += "%4s %10s  %3s %7s %4s %5s  %8.1f\n" % (fillcode, caldate, location, species, inst, pressure, mr)
            else:
                text += "%4s %10s  %3s %5s %8s %8.2f %6.2f %6.2f %1s\n" % (" ", caldate, location, inst, pressure, mr, sd, unc, flag)


        if cals and (gas.lower() != "co2c13" and gas.lower() != "co2o18"):
            avg, stdv, num = self.getAvgs(cals)
            text += "%66d%9.2f %7.2f\n" % (num, avg, stdv)

        text += "</pre><br>\n"

        return text

    #------------------------------------------------------------------------
    def _print_json(self, cals):
        """ Print calibration information in json format. """

        records = []

        for d in cals:
            pressure = d['pressure']
            if pressure is None: pressure = 0

            scale = self.scales[d['species']]

            a = {
                "fill_code"       : d['fillcode'],
                "serial_number"   : d['serial_number'],
                "date"            : "%s" % (d['date']),
                "time"            : "%s" % d['time'],
                "parameter"       : d['species'],
                "value"           : float(d['mixratio']),
                "std._dev."       : float(d['stddev']),
                "num_samples"     : d['num'],
                "type"            : d['method'],
                "system"          : d['system'],
                "instrument_code" : d['inst'],
                "tank_pressure"   : pressure,
                "flag"            : d['flag'],
                "scale"           : scale,
                "uncertainty"     : d['typeB_unc'],
            }
            if self.include_notes: a['notes'] = d['notes']
            records.append(a)

        return json.dumps(records, indent=4)


    #------------------------------------------------------------------------
    def _print_csv(self, cals):
        """ Print calibration information in csv format. """

        text = []

        for d in cals:

            pressure = d['pressure']
            if pressure is None: pressure = 0

            scale = self.scales[d['species']]

            t = (
                d['serial_number'],
                d['fillcode'],
                d['date'],
                d['time'],
                d['species'],
                d['system'],
                d['inst'],
                d['method'],
                pressure,
                d['mixratio'],
                d['stddev'],
                d['flag'],
                scale,
                d['typeB_unc'],
            )
            if self.include_notes: t = t + (d['notes'],)
            s = ",".join([str(a) for a in t])

            text.append(s)

        return "\n".join(text) + "\n"


    #------------------------------------------------------------------------
    def _get_scale(self, species):
        """ Get the scale that is being used for the species """

        # scale name is that for the current=1 scale in scales table
        sql = "select name from reftank.scales where species='%s' and current=1" % species
        result = self.db.doquery(sql)
#        print(result)

        # except for co2, which has archived data in different scale in separate database
        if self.database != "reftank" and species.lower() == "co2":
            return "CO2_X2007"

        if result:
            return result[0]["name"]

        return "None"

    #------------------------------------------------------------------------
    def _get_species(self):
        """ Get a list of species analyzed from the calibrations """

        gaslist = []
        if self.gas is None:
            for d in self.cals:
                gas = d['species']
                if gas not in gaslist:
                    gaslist.append(gas)
        else:
            gaslist.append(self.gas)

        return sorted(gaslist)

    #------------------------------------------------------------------------
    @staticmethod
    def _get_fill_codes_for_cals(cals):
        """ take a list of cal results and extract a list of unique fill codes """

        a = []
        for d in cals:
            fcode = d['fillcode']
            if fcode not in a:
                a.append(fcode)

        return a

    #------------------------------------------------------------------------
    def getFillCode(self, date):
        """ Find the correct fill code for a given date. """

        if isinstance(date, datetime.datetime):
            adate = date.date()
        else:
            adate = date

        for n in range(0, len(self.fill)-1):
            filldate = self.fill[n]['date']
            fillcode = self.fill[n]['code']
            nextfilldate = self.fill[n+1]['date']

            if filldate is None or nextfilldate is None:
                return None
#            if date >= filldate and date < nextfilldate:
            if filldate <= adate < nextfilldate:
                return fillcode

        return None

    #------------------------------------------------------------------------
    def getFillDate(self, date):
        """ Find the fill date for a given calendar date. """

        if isinstance(date, datetime.datetime):
            adate = date.date()
        else:
            adate = date

        for n in range(0, len(self.fill)-1):
            filldate = self.fill[n]['date']
            nextfilldate = self.fill[n+1]['date']

            if filldate is None or nextfilldate is None:
                return None
            if filldate <= adate < nextfilldate:
                return filldate

        return None

    #------------------------------------------------------------------------
    def getFlag(self, date):
        """ Get the flag for a calibration on given date """

        for d in self.cals:
            caldate = d['date']

            if caldate == date:
                return d['flag']

        return '.'

    #------------------------------------------------------------------------
    @staticmethod
    def getAvgs(cals):
        """
        Get the average, stddev, and n for given calibrations.
        The cals are for a single fillcode.
        """

        # get unflagged values
        values = [float(d['mixratio']) for d in cals if d['flag'] == "."]
        num = len(values)
        if num > 0:
            avg = mean(values)
            if num == 1:
                stdv = 0.0
            else:
                stdv = std(values, ddof=1)
        else:
            avg = -999.99
            stdv = -99.99

        return avg, stdv, num


    #----------------------------------------------------------------------
    def getAverage(self, sn, mygas, fillcode):
        """ Get the average value for the given tank serial number and fill code """

        cals = [d for d in self.cals if d['species'].lower() == mygas.lower()]
        fcals = [d for d in cals if d['fillcode'] == fillcode]
        avg, stdv, num = self.getAvgs(fcals)

        return avg

    #----------------------------------------------------------------------
    def getValue(self, mygas, fillcode):
        """ Get the value for the given tank and fill code that can be used
        to put an entry into the scale_assignments table.

        Returns:
            result : namedtuple with (tzero, coef0, unc0, coef1, unc1, coef2, unc2)
        """

        instruments = INST_CODES[mygas.lower()].split(",")

        cals = [d for d in self.cals if d['species'].lower() == mygas.lower()]  # get cals for this gas
        fcals = [d for d in cals if d['fillcode'] == fillcode]   # get cals for fillcode
        fcals = [d for d in fcals if d['flag'] == "."]  # get unflagged cals
        ocals = [d for d in fcals if d['inst'] in instruments]   # get official cals only

        result = ccg_calfit.fitCalibrations(ocals)

        return result

    #----------------------------------------------------------------------
    def _check_cals(self, cals):
        """ Check for problems in database, such as cal before first fill,
        fills after last cal, no fillings for a tank.
        """

        text = ""

        if len(cals) == 0 or self.quiet:
            return text

        if self.nfill == 0:
            text += "Warning: No filling information found."
        else:
            firstfilldate = self.fill[0]['date']
            firstcaldate = cals[0]['date']
            if firstcaldate < firstfilldate:
                text += "===> WARNING: There are calibrations before the first filling date. <===\n"

            lastcaldate = cals[-1]['date']
            lastfilldate = self.fill[self.nfill-2]['date']
            if lastfilldate > lastcaldate:
                text += "===> WARNING: There are fillings after last calibration. <===\n"

        return text

    #----------------------------------------------------------------------
    def _get_flasks(self):
        """ Get any flasks that have been filled from a tank and
        analyzed for isotopes c13 and o18.
        """

        sql = "SELECT num from ccgg.flask_event where comment like '%" + self.tank + "%'"
        result = self.db.doquery(sql)
        if result:
            elist = []
            for row in result:
                elist.append(str(row['num']))

            events = ",".join(elist)

            for param in [7, 8]:

                sql = "select value, unc, flag, inst, system, date, parameter_num "
                sql += "from ccgg.flask_data "
                sql += "where event_num in (%s) and parameter_num=%d" % (events, param)
                result2 = self.db.doquery(sql)
                if result2:
                    for row in result2:
                        date = row['date']
                        code = self.getFillCode(date)
                        row['fillcode'] = code
                        if self.fillingcode and code != self.fillingcode: continue
                        self.flasks.append(row)

    #----------------------------------------------------------------------
    def _print_flasks(self, gas, fmt):
        """ print out information for flasks filled from tank and analyzed for isotopes. """

        text = ""

        if len(self.flasks) == 0: return text

        if gas == "CO2C13":
            param = 7
        else:
            param = 8

        flsks = [f for f in self.flasks if f['parameter_num'] == param]
        if len(flsks) == 0: return text

        format1 = "%4s %10s  %3s %7s %10s %4s %5s  %8.1f %6.1f %1s\n"
        if fmt == "csv":
            format1 = "%s,%s,%s,%s,%s,%s,%s,%s,%.1f,%.1f,%s\n"

        if fmt != "csv":
            text += "\n%s FLASK SAMPLES FOR TANK # %s\n" % (gas, self.tank)
            if fmt == "html":
                text += "<pre>"
            text += " Fill   Date     Loc     Gas   System   Inst Press   Value    S.D.\n"
            text += "----------------------------------------------------------------------------\n"

        for line in flsks:
            fillcode = line['fillcode']
            caldate = line['date']
            system = line['system']
            inst = line['inst']
            value = line['value']
            sd = line['unc']
            flag = line['flag']

            if fmt == "csv":
                text += format1 % (self.tank, fillcode, caldate, "BLD", gas, system, inst, "----", value, sd, flag)
            else:
                text += format1 % (fillcode, caldate, "BLD", gas, system, inst, "----", value, sd, flag)

        if fmt == "html":
            text += "</pre><br>"

        return text

    #----------------------------------------------------------------------
    def checkDb(self, cal_data, verbose=False):
        """ check results with data in database

        Args:
            cal_data : namedtuple containing
                (adate, mf, sd, ncycles, method, pressure, site, regulator, inst, system, flag)
            verbose : boolean.  If true print out extra messages while updating.
        """

        # this shouldn't ever happen but check anyway
        if self.gas is None:
            sys.exit("Gas species must be specified for checks.")

        date = "%4d-%02d-%02d" % (cal_data.adate.year, cal_data.adate.month, cal_data.adate.day)
        time = "%02d:%02d:00" % (cal_data.adate.hour, cal_data.adate.minute)

        table = "calibrations"

        # info line for messages
        frmt = "%12s %4d %02d %02d %02d %9.3f %7.3f %3d %4s %3s %s"
        line = frmt % (
            self.tank,
            cal_data.adate.year,
            cal_data.adate.month,
            cal_data.adate.day,
            cal_data.adate.hour,
            cal_data.mf,
            cal_data.sd,
            cal_data.ncycles,
            cal_data.pressure,
            cal_data.inst,
            cal_data.regulator
        )

#        print(cal_data)
        record = self._find_record(cal_data.adate, cal_data.inst)
#        print("record is", record)
        if record is None:

            # If nothing found, check if it's a serial number mismatch

            # First by checking if the date, time and mole fraction agree
            sql = "SELECT serial_number FROM %s WHERE " % (table)
            sql += "date='%s' " % date
            sql += "AND time='%s' " % time
            sql += "AND mixratio=%f " % cal_data.mf
            sql += "AND species='%s' " % self.gas
            sql += "AND inst='%s'" % cal_data.inst
            result = self.db.doquery(sql)

            if result:
                dbsn = result[0]['serial_number']
                print("%s Serial number mismatch (%s)." % (line, dbsn))

            # check if serial numbers are similar
            else:
                sql = "SELECT serial_number FROM %s WHERE " % (table)
                sql += "date='%s' " % date
                sql += "AND time='%s' " % time
                sql += "AND species='%s' " % self.gas
                sql += "AND serial_number like '%%%s%%' " %self.tank
                sql += "AND inst='%s'" % cal_data.inst
                result = self.db.doquery(sql)
                if result:
                    dbsn = result[0]['serial_number']
                    print("%s Possible serial number mismatch (%s)." % (line, dbsn))

                else:
                    # check if date, location, instrument match but not time
                    sql = "SELECT time FROM %s WHERE " % (table)
                    sql += "date='%s' " % date
                    sql += "AND serial_number='%s' " % self.tank
                    sql += "AND species='%s' " % self.gas
                    sql += "AND inst='%s'" % cal_data.inst
                    sql += "AND location='%s'" % cal_data.site
                    result = self.db.doquery(sql)
                    if result:
                        dbsn = result[0]['time']
                        print("%s Time mismatch (%s)." % (line, dbsn))
                    else:
                        print("%s  not found." % line)

        else:
            # Check if mole fraction agree.
            mr2 = float(record['mixratio'])
            stdv = float(record['stddev'])
            diff = round(abs(cal_data.mf - mr2), 3)
            if diff > 0.001:
                print("%s mole fraction mismatch (%8.3f, %6.3f, diff = %6.3f)." % (line, mr2, stdv, diff))

            else:
                if verbose:
                    print("Tank %10s on %s %s OK" % (self.tank, date, time))


    #----------------------------------------------------------------------
    def updateDb(self, cal_data, verbose=False):
        """ Update the database with results of calibration.

        Args:
            cal_data : namedtuple containing
                (adate, mf, sd, ncycles, method, pressure, site, regulator, inst, system, flag)
            verbose : boolean.  If true print out extra messages while updating.

        .. note::
            Class must be initialized with ``readonly=False`` argument for updates

        """

        # this shouldn't ever happen but check anyway
        if self.gas is None:
            sys.exit("Gas species must be specified for updates.")

        table = "calibrations"


        date = "%4d-%02d-%02d" % (cal_data.adate.year, cal_data.adate.month, cal_data.adate.day)
        time = "%02d:%02d:00" % (cal_data.adate.hour, cal_data.adate.minute)

        # Find the record.
        # If no record, insert new one, else update existing data
        record = self._find_record(cal_data.adate, cal_data.inst)
        if record is None:
            query = "INSERT INTO %s SET " % table
        else:
            query = "UPDATE %s SET " % table

        query += "mixratio=%.4f, " % cal_data.mf
        query += "stddev=%.3f, " % cal_data.sd
        query += "num=%d, " % cal_data.ncycles
        query += "method='%s', " % cal_data.method
        query += "system='%s', " % cal_data.system
        query += "pressure=%s, " % cal_data.pressure
        query += "location='%s', " % cal_data.site
        query += "regulator='%s', " % cal_data.regulator
        query += "meas_unc=%.3f, " % cal_data.meas_unc
        query += "mod_date=now() "

        if record is None:
            query += ", date='%s', time='%s', " % (date, time)
            query += "serial_number='%s', " % self.tank
            query += "inst='%s', " % cal_data.inst
            query += "species='%s', flag='.', " % self.gas
            query += "parameter_num=%s " % cal_data.paramnum
        else:
            query += "WHERE idx=%d " % (record['idx'])

        if verbose:
            print(query)
        self.db.doquery(query, commit=True)
#        self.db.commit()

        # update our results
        self._get_results()

    #----------------------------------------------------------------------
    def deleteDb(self, cal_data, verbose=False):
        """ Delete a record from the database

        Args:
            cal_data : tuple containing
                (adate, co2, sd, ncycles, method, pressure, sitecode, regulator, inst, flag)
            verbose : boolean.  If true print out extra messages while updating.

        .. note::
            Class must be initialized with ``readonly=False`` argument for deletes
        """

        table = "calibrations"

        date = "%4d-%02d-%02d" % (cal_data.adate.year, cal_data.adate.month, cal_data.adate.day)
        time = "%02d:%02d:00" % (cal_data.adate.hour, cal_data.adate.minute)

        # Delete the record.
        sql = "DELETE FROM %s WHERE " % (table)
        sql += "serial_number='%s' " % self.tank
        sql += "AND date='%s' " % date
        sql += "AND time='%s' " % time
        sql += "AND species='%s' " % self.gas
        sql += "AND inst='%s'" % cal_data.inst
        if verbose:
            print(sql)
        self.db.doquery(sql, commit=True)
#        self.db.commit()

# OR

#        record = self._find_record(cal_data.adate, cal_data.inst)
#        if record is not None:
#            query = "DELETE FROM %s WHERE idx=%d" % (table, record['idx'])
#            if verbose:
#                print(sql)
#            self.db.doquery(sql, commit=True)
    

    #----------------------------------------------------------------------
    def _find_record(self, date, inst):
        """ Find if this calibration record is already in the database.
        The Calibrations class MUST have been created with the species and tank serial number
        given as arguments.
        Loop through the cals and see if any match.

        Input:
            date - datetime object of analysis date

        Return the self.cals dict entry if a match is found, otherwise return None
        """

        # self.cals is already filtered by tank serial number and gas on creation
#        print("search for ", date)
        for d in self.cals:
#            print(d)
            caldate = d['date']
            time = d['time']

#            print(d)
            adate = datetime.datetime(caldate.year, caldate.month, caldate.day) + time
#            print(caldate, time, adate, date)
            if (adate == date 
                and inst == d['inst']):
#                and paramnum == d['parameter_num']):
                return d

        return None


if __name__ == "__main__":

    dbc = ccg_db_conn.RO(db='reftank')

    sn = "CC71623"
    gas = "co2"
    cals = Calibrations(sn, gas, dbconn=dbc)
    txt = cals.showResults()
    print(txt)
#    json = cals.showResults(fmt='json')
#    print(json)
#    html = cals.showResults(fmt='html')
#    print(html)
    fillcode = "C"
    t = cals.getValue("co2", fillcode)
    print(t)

