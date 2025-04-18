# vim: tabstop=4 shiftwidth=4 expandtab
"""
**** grav_refgasdb.py

A class for holding and manipulating reference gas information for
gravimetric standards.

Usage:
    refgas = grav_refgas.refgas(sp, scale=None, moddate=md, database=None, verbose=False
        fulloutput=False, convert_units=False)

    sp      -  species (required)
    scale   -  Set to "Grav"
    convert_units - Set to convert from mole fraction to ppm, ppb, ppt according to sp
    verbose -  Use to add moddate and comments to info,history, and table outputs
    fulloutput - Use to add preparation information to info, history, and table outputs
    moddate -  Modification date.  Use assigned values prior to this date.
        Pass in as python datetime or as "yyyy-mm-dd" string.
    database - Specify database that has gravimetric tables. Use for off-line
        testing.

Methods:
    getRefgasBySerialNumber( sernum, date, [standard_unc]): Return the value and unc
        of the standard on date.
        If pass standard_unc=True, will return standard_unc, default is transfer_unc

    getInfo(sernum, date):  Return the information on the standard

    getHistory(sernum):   Return the history of the standard.

    printTable():   Returns a table of all entries.  Only the most recent
        entry prior to the modification date passed when class
        constructed is included.

    getRefgasByLabel( id, date, [standard_unc]):  Return the s/n, value, and unc
        of the standard on date.  Searches by label listed in the level
        column of a text file.  Used for observatory systems where text
        file lookup tables are used, not to be used when getting values
        from the DB.

"""
from __future__ import print_function

import sys
import datetime
from operator import itemgetter
import copy

from ccg_dates import decimalDate
import ccg_dbutils
import ccg_utils

DEFAULT = -999.99

##################################################################
class refgas:
    """ Class for holding reference gas information.
    """

    def __init__(self, sp=None, scale=None, database=None, startdate=None, enddate=None, moddate=None,
         verbose=False, fulloutput=False, convert_units=False, debug=False):
        """
        Initialize a reference gas object.
        parameter:
            sp: the gas species, REQUIRED

            scale: Set to "grav"

            moddate: optional, if specified, modifications of assignments after this date
                 are not included. This must be a python datetime object or "yyyy-mm-dd"
                 format string.

            database: optional, if set then use this database instead of default database.
        """

        self.valid = True
        self.debug = debug
        self.verbose = verbose
        self.fulloutput = fulloutput
        self.use_hour = False
        self.sp_num = None
        self.startdate = startdate
        self.enddate = enddate
        self.convert_units = convert_units
        if database is None:
            database = "reftank"
        self.db = ccg_dbutils.dbUtils(database=database)

        if not moddate:
            self.moddate = datetime.datetime(9999, 12, 31)
        else:
            if isinstance(moddate, datetime.datetime):
                self.moddate = moddate
            else:
                (yr, mo, dy) = moddate.split('-')
                self.moddate = datetime.datetime(int(yr), int(mo), int(dy))

        #allow sp to be passed in as formula, name, or number
        #convert name or number to formula for use
        if sp:
            try:
                #if sp passed in as gasnum, assign to sp_num
                self.sp_num = int(sp)
            except:
                # try to get sp_num from formula or name
                self.sp_num = self.db.getGasNum(sp)

            if self.sp_num != -1:
            #get sp formula from gas_num
                self.sp = self.db.getGasFormula(self.sp_num)
            else:
                self.sp = sp
        else:
            self.sp = sp

        self.scale = scale
        self.info_DBtable = "grav_stds"
        self.value_DBtable = "grav_values"
        if self.debug: print("scale = %s" % self.scale, file=sys.stderr)


        if self.debug: print("Getting reference gas values from database.", file=sys.stderr)
        #read DB table for scale
        self.refgas = self._readDBrefgas()


        if len(self.refgas) == 0:
            print("No reference gas information found.", file=sys.stderr)
            self.valid = False
            return


    #--------------------------------------------------------------------------
    def _readDBrefgas(self):

        #sql = "select s.serial_number,s.date,v.species,v.species_num,v.value,v.unc,v.partial_unc,v.flag,v.mod_date,v.id "
        sql = "select * "
        sql += " from %s s join %s v on s.id = v.std_idx " % (self.info_DBtable,self.value_DBtable)
        if self.sp:
            sql += " where v.species_num=%s " % (self.sp_num)
        sql += " order by s.serial_number, s.date, v.species_num, v.mod_date;" 
        
        info_list = self.db.doquery(sql)

        # split lines of returned info values
        data = []
        for line in info_list:
            #print(line, file=sys.stderr)
            #sys.exit("clean exit")

            std_idx = line['id']
            fill_num = line['fill_num']
            sn = line['serial_number']
            idate = line['date']
            project = line['project']
            notebook = line['notebook']
            pages = line['pages']
            prepared_by = line['prepared_by']
            parent = line['parent']
            o2_content = line['o2_content']
            calc_mw = line['calc_mw']
            notes = line['notes']
            species = line['species'].lower()
            species_num = line['species_num']
            val = line['value']
            unc = line['unc']
            partial_unc = line['partial_unc']
            flag = line['flag']
            comment = line['comments']
            moddate = line['mod_date']
            

            date = datetime.datetime(idate.year, idate.month, idate.day, 0, 0)


            if self.convert_units:

                result = self.db.getGasInfoFromNum(species_num)
                unit = result['unit']
                unit_name = result['unit_name']

                if unit == "pmol mol-1":
                    cvt_factor = 1.0e-12
                elif unit == "nmol mol-1":
                    cvt_factor = 1.0e-9
                elif unit == "umol mol-1":
                    cvt_factor = 1.0e-6

                val = val / cvt_factor
                unc = unc / cvt_factor
                partial_unc = partial_unc / cvt_factor

            t = (std_idx, sn, fill_num, date, moddate, project, notebook, pages, prepared_by, parent, o2_content,
                 calc_mw, notes, species, species_num, val, unc, partial_unc, flag, comment)

            data.append(t)

        return data



    #--------------------------------------------------------------------------
    def getRefgasBySerialNumber(self, sernum, adate, std_unc=False):
        """ Get mixing ratio of tank with serial number on adate.
            Pass adate as python datetime or "yyyy-mm-dd" string.

            convert_units=True  convets grav value form mole fraction to normal units (ppb,ppt, etc)
        """
    #        t = (idx,sn, fill_num, date, moddate, project, notebook, pages, prepared_by, parent, o2_content,
    #             calc_mw, notes, v_sp, v_sp_num, v_val, v_unc, v_partial_unc, v_flag, v_comment)


        mr = DEFAULT
        uncertainty = DEFAULT/10.0

        if not isinstance(adate, datetime.datetime):
            (yr, mo, dy) = adate.split('-')
            #set minute = 1 to prevent roundoff errors
            adate = datetime.datetime(int(yr), int(mo), int(dy), 0, 1)

        dd = decimalDate(adate.year, adate.month, adate.day, adate.hour, adate.minute, adate.second)

        # sort by sn, date, sp_num, moddate in output of DB call.

        for (idx, sn, fill_num, date, mdate, project, notebook, pages, prepared_by, parent, o2_content,
             calc_mw, notes, sp, sp_num, val, unc, partial_unc, flag, comment) in self.refgas:

            if sn.upper() == sernum.upper() and sp.upper() == self.sp.upper() and date <= adate and mdate <= self.moddate:
                if std_unc:
                    uncertainty = partial_unc
                else:
                    uncertainty = unc
                mr = val

        if mr == DEFAULT:
            print("Assigned value for ", sernum, "on", adate.date(), "not found.", file=sys.stderr)

        return (mr, uncertainty)


    #--------------------------------------------------------------------------
    def getInfo(self, sernum, adate):
        """ return the information on the standard rather than the assigned value.
        RETURNS CURRENT VALUE FOR ALL SPECIES

        Pass adate as python datetime or "yyyy-mm-dd" string.

        Output line = sn yr mo dy t0 coef0 coef1 coef2 transfer_unc standard_unc level #mod_date comment
        """
    #        t = (idx,sn, fill_num, date, moddate, project, notebook, pages, prepared_by, parent, o2_content,
    #             calc_mw, notes, v_sp, v_sp_num, v_val, v_unc, v_partial_unc, v_flag, v_comment)
    #

        oldkey = ""
        olddate = datetime.datetime(1900, 1, 1)
        info = []
        header = ""

        if self.fulloutput:
            header = "#sn date project notebook page prepared_by parent O2 MW SP value unc unc2 flag"
            if self.verbose:
                header += " #moddate comment"
            info.append(header)

        if not isinstance(adate, datetime.datetime):
            (yr, mo, dy) = adate.split('-')
            #set minute = 1 to prevent roundoff errors
            adate = datetime.datetime(int(yr), int(mo), int(dy), 0, 1)

        # sort by sn, date, sp_num, moddate in DB call

        for t in self.refgas:

            if t[1].upper() == sernum.upper() and t[3] <= adate and t[4] <= self.moddate:
                mod_dt = self._format_mod_dt(t)

                #If the fill date is a new fill date, clear the old fill information from info
                if t[3] > olddate:
                    info = []
                    if self.fulloutput:
                        info.append(header)
                    olddate = t[3]

                #Test to see if current line is a new modification of the previous line.
                #If it is then remove the previous line.
                # key = sn filldate sp
                newkey = "%s %d-%02d-%02d %s" % (t[1], int(t[3].year), int(t[3].month), int(t[3].day), t[13])

                if newkey == oldkey:
                    old = info.pop()
                oldkey = newkey

                infoline = self._format_info(t, mod_dt)
                info.append(infoline)

        return info


    #--------------------------------------------------------------------------
    def _format_info(self, t, mod_dt=""):
        """ Format the information line.
        fulloutput:
        sn, year, month, day, [hour]
        project, notebook, pages, prepared_by, parent, o2_content, calc_mw,'notes'
        sp, value, unc, partial_unc, flag

        Normal:
        sn, year, month, day, [hour]
        sp, value, unc, partial_unc, flag

        verbose adds moddate and comments

        """
#        t = (idx (0),sn (1), fill_num (2), date (3), moddate (4), project (5), notebook (6),
#                    pages (7), prepared_by (8), parent (9), o2_content (10),
#             calc_mw (11), notes (12), v_sp (13), v_sp_num (14), v_val (15),
#                    v_unc (16), v_partial_unc (17), v_flag (18), v_comment (19) )
#

        if self.use_hour:
            if self.fulloutput:
                frmt = "%-12s %4d %02d %02d %02d %15s %3s %3s %15s %15s %5.2f %7.3f \"%s\" %s %12G %12G %12G %s"
                info = frmt % (t[1], t[3].year, t[3].month, t[3].day, t[3].hour,
                         t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[15], t[16], t[17], t[18])
            else:
                frmt = "%-12s %4d %02d %02d %02d %15s %12G %12G %12G %s"
                info = frmt % (t[1], t[3].year, t[3].month, t[3].day, t[3].hour,
                         t[13], t[15], t[16], t[17], t[18])
        else:
            if self.fulloutput:
                frmt = "%-12s %4d %02d %02d %15s %3s %3s %15s %15s %5.2f %7.3f \"%s\" %s %12G %12G %12G %s"
                info = frmt % (t[1], t[3].year, t[3].month, t[3].day,
                         t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[15], t[16], t[17], t[18])
            else:
                #format = "%-12s %4d %02d %02d %15s %20.15f %20.15f %20.15f %s"
                frmt = "%-12s %4d %02d %02d %15s %12G %12G %12G %s"
        #        format = "%-12s %4d %02d %02d %15s %12E %12E %12E %s"
                info = frmt % (t[1], t[3].year, t[3].month, t[3].day, t[13], t[15], t[16], t[17], t[18])

        if self.verbose:
            info += " #%s \"%s\"" % (mod_dt, t[19])

        return info

    #--------------------------------------------------------------------------
    def _format_mod_dt(self, t):
        """ Format the modification date """

        #mod_dt = "%4d-%02d-%02d %02d:%02d:%02d" % ( t[4].year, t[4].month, t[4].day, t[4].hour, t[4].minute, t[4].second)
        mod_dt = "%4d-%02d-%02d" % (t[4].year, t[4].month, t[4].day)

        return mod_dt

    #--------------------------------------------------------------------------
    def getHistory(self, sernum):
        """ Return the history of the standard.  All fills, all modifications.
        """
    #        t = (idx (0),sn (1), fill_num (2), date (3), moddate (4), project (5), notebook (6),
    #                    pages (7), prepared_by (8), parent (9), o2_content (10),
    #             calc_mw (11), notes (12), v_sp (13), v_sp_num (14), v_val (15),
    #                    v_unc (16), v_partial_unc (17), v_flag (18), v_comment (19) )

        info = []

        # write header to history
        header = "#sn  year  month  day"
        if self.use_hour:
            header += "  hour"
        if self.fulloutput:
            header += "  project  notebook  pages  prepared_by  parent  o2_content  calc_mw  notes  sp  value  unc  partial_unc  flag"
        else:
            header += "  sp  value  unc  partial_unc  flag"

        if self.verbose:
            header += "  #moddate  comment"

        info.append(header)

        for t in self.refgas:
            if t[1].upper() == sernum.upper():
                mod_dt = self._format_mod_dt(t)

                infoline = self._format_info(t, mod_dt)

                info.append(infoline)

        return info

    #--------------------------------------------------------------------------
    def printTable(self):
        """ prints a table of all standards (and all species) selected by the
        modification date if passed.  Does not print comments.

        Output line = sn, year, month, day, project, notebook, pages, prepared_by, parent, o2_content, calc_mw,notes
        sp, value, unc, partial_unc, flag, moddate, comment #
        """
    #        t = (idx (0),sn (1), fill_num (2), date (3), moddate (4), project (5), notebook (6),
    #                    pages (7), prepared_by (8), parent (9), o2_content (10),
    #             calc_mw (11), notes (12), v_sp (13), v_sp_num (14), v_val (15),
    #                    v_unc (16), v_partial_unc (17), v_flag (18), v_comment (19) )
        info = []
        table = []
        oldkey = ""
        # write header to table
        header = "#sn  year  month  day"
        if self.use_hour:
            header += "  hour"
        if self.fulloutput:
            header += "  project  notebook  pages  prepared_by  parent  o2_content  calc_mw notes sp  value  unc  partial_unc  flag"
        else:
            header += "  sp  value  unc  partial_unc  flag"

        if self.verbose:
            header += "  #moddate  comment"



        table.append(header)

        # sort by sn, date, sp_num, moddate
        self.refgas.sort(key=itemgetter(4))
        self.refgas.sort(key=itemgetter(13))
        self.refgas.sort(key=itemgetter(3))
        self.refgas.sort(key=itemgetter(1))

        for t in self.refgas:

            #Test moddate, if > passed moddate then don't put into table
            if t[4] > self.moddate: continue

            #Test to see if current line is a new modification of the previous line.
            #If it is then remove the previous line.
            # key = sn filldate sp
            newkey = "%s %d-%02d-%02d %s" % (t[1], int(t[3].year), int(t[3].month), int(t[3].day), t[13])
            #print >> sys.stderr, "newkey: %s" % newkey

            if newkey == oldkey:
                old = info.pop()
            oldkey = newkey
            info.append(t)

        for t in info:

            mod_dt = self._format_mod_dt(t)
            infoline = self._format_info(t, mod_dt)

            table.append(infoline)
            #print infoline

        return table
