#!/usr/bin/python

from __future__ import print_function

import sys
#import datetime
import re
import numpy

import ccg_db_conn
import ccg_refgasdb
import ccg_cal_db



##################################################################
class dilution:
    """ Class to hold information for each dilution cylinder.

    Members:
    dilution.serialnumber
    dilution.adate   (datetime object)
    dilution.filldate
    dilution.nextfilldate (end date for current filling)
    dilution.fillcode
    dilution.fillflag
    dilution.parent_sn
    dilution.parent_ch4
    dilution.parent_ch4_unc
    dilution.parent_co
    dilution.parent_co_unc
    dilution.diluent_sn
    dilution.diluent_ch4
    dilution.diluent_ch4_unc
    dilution.diluent_co
    dilution.diluent_co_unc
    dilution.ch4   (ch4 assigned values for parent and diluent tanks)
    dilution.co    (CO assigned values for parent and diluent tanks)
    dilution.measured_ch4
    dilution.measured_ch4_sd
    dilution.assigned_co
    dilution.assigned_co_sd

    Methods:
    returnCalculatedCO()   gets CO value from measured CH4.  Also returns (sd of
            CH4 measurements * CO:CH4 ratio) and the fill flag.

    Creation:
    tank = dilution.dilution(tank_sn, date, ch4_refgas, co_refgas)
    tank_sn = serial number of dilution cylinder
    date = date of analysis.  Used to get info from correct filling.
        Should be passed in as string "2013-12-31".
    ch4_scale = CH4 scale (default is current scale)
    co_scale = CO scale (default is current scale)
    moddate = modification date for standards DB table

    """

    def __init__(self, serialnum, date, ch4_inst="",
         co_scale=None, ch4_scale=None, moddate=None, database=None, debug=False):

        if debug:
            self.debug = True
        else:
            self.debug = False

        if ch4_inst == "":
            ch4_inst = "H5,PC1"
        ch4_inst = re.sub(r'\s', '', ch4_inst) #remove any whitespace

        if self.debug: print("ch4 inst = %s" % ch4_inst, file=sys.stderr)

        self.serialnumber = serialnum

        # analysis date (yyyy-mm-dd)
        self.adate = date
#        (self.ayear, self.amonth, self.aday) = date.split('-')
        if self.debug: print("adate = %s" % self.adate, file=sys.stderr)

        # Get the correct fill date and fill code for the analysis date from the "fill" table.
        cals = ccg_cal_db.Calibrations(self.serialnumber, database=database)
        self.fillcode = cals.getFillCode(self.adate)
        self.filldate = cals.getFillDate(self.adate)
        if self.debug: print("fillcode: %s     filldate: %s" % (self.fillcode, self.filldate), file=sys.stderr)

        # if no fill code returned then exit with error
        if self.fillcode is None:
            print("No fill code found for %s on %s" % (self.serialnumber, self.adate), file=sys.stderr)
            sys.exit()


        # Get the info from the dilution table
        # (parent_sn, diluent_sn, fill_date, flag, notes, comments) = getDilutionInfo()
        (self.parent_sn, self.diluent_sn, dilution_filldate, self.project, self.fillflag, self.notes, self.comments) = self.getDilutionInfo()


        if self.debug:
            print("parent: %s  diluent: %s   filldate: %s  project: %s   flag: %s" % (self.parent_sn, self.diluent_sn, dilution_filldate, self.project, self.fillflag), file=sys.stderr)
            print("notes: %s " % self.notes, file=sys.stderr)
            print("comments: %s" % self.comments, file=sys.stderr)

        # test filldates from "fill" and "dilution" tables to make sure they match
        try:
            dilution_filldate == self.filldate
        except:
            print("Fill dates from fill and dilution tables for %s do not match, exiting." % (self.serialnumber), file=sys.stderr)
            sys.exit()

        serialnums = [self.parent_sn, self.diluent_sn]
        # Read CH4 standards table
        ch4_refgas = ccg_refgasdb.refgas("CH4", sn=serialnums, scale=ch4_scale, moddate=moddate)

        # Read CO standards table
        co_refgas = ccg_refgasdb.refgas("CO", sn=serialnums, scale=co_scale, moddate=moddate)

        # get parent and diluent CH4 and CO assigned mole fractions
        (self.parent_ch4, self.parent_ch4_unc) = ch4_refgas.getRefgasBySerialNumber(self.parent_sn, self.filldate)
        (self.parent_co, self.parent_co_unc) = co_refgas.getRefgasBySerialNumber(self.parent_sn, self.filldate)
        (self.diluent_ch4, self.diluent_ch4_unc) = ch4_refgas.getRefgasBySerialNumber(self.diluent_sn, self.filldate)
        (self.diluent_co, self.diluent_co_unc) = co_refgas.getRefgasBySerialNumber(self.diluent_sn, self.filldate)



        if self.debug:
            print("Parent (%s): CH4 =%12.2f   CO =%12.2f " % (self.parent_sn, self.parent_ch4, self.parent_co), file=sys.stderr)
            print("Diluent (%s): CH4 =%12.2f   CO =%12.2f " % (self.diluent_sn, self.diluent_ch4, self.diluent_co), file=sys.stderr)
            print(" ", file=sys.stderr)


        # Get average CH4 results from tank cal system for the dilution tank
        (self.measured_ch4, self.measured_ch4_sd) = self.getMeasuredCH4(ch4_inst)
        if self.debug:
            print("measured CH4 (inst = %s): %s  +- %s" % (ch4_inst, self.measured_ch4, self.measured_ch4_sd), file=sys.stderr)

        # Get assinged CO value for cylinder
        (self.assigned_co, self.assigned_co_sd) = self.calculateCO()
        if self.debug: print("assigned CO: %s  +- %s" % (self.assigned_co, self.assigned_co_sd), file=sys.stderr)



    ################################################################
    # (parent_sn, diluent_sn, fill_date, project, flag, notes, comments) = getDilutionInfo()
    def getDilutionInfo(self):

#        db, c = ccg_db.dbConnect("reftank")
        db = ccg_db_conn.RO(db="reftank")

        table = "dilution"
        sql = "SELECT * FROM %s WHERE " % (table)
        sql += "serial_number='%s' AND fill_code='%s'" % (self.serialnumber, self.fillcode)

#        c.execute(sql)
#        row = c.fetchone()
        result = db.doquery(sql)
        row = result[0]

#        c.close()
#        db.close()

#        idx = row[0]
#        sn = row[1]
#        fcode = row[2]
#        fnum = row[3]
#        parent_sn = row[4]
#        diluent_sn = row[5]
#        fdate = row[6]
#        project = row[7]
#        flag = row[8]

        idx = row['idx']
        sn = row['serial_number']
        fcode = row['fill_code']
        fnum = row['fill_num']
        parent_sn = row['parent_sn']
        diluent_sn = row['diluent_sn']
        fdate = row['date']
        project = row['project']
        flag = row['flag']

        #notes
        notes = ""
#        tmp = str(row[9])
        tmp = str(row['notes'])
        for line in tmp.splitlines():
            notes = "%s;%s" % (notes, line)
        notes = notes.lstrip()
        notes = notes.lstrip(';')
        if self.debug: print("final notes: %s" % notes, file=sys.stderr)

        #comments
        comments = ""
#        tmp = str(row[10])
        tmp = str(row['comments'])
        tmp2 = tmp.splitlines()
        for line in tmp2:
            comments = "%s;%s" % (comments, line)
        comments = comments.lstrip()
        comments = comments.lstrip(';')

        return (parent_sn, diluent_sn, fdate, project, flag, notes, comments)


    ###################################################################
    # getMeasuredCH4()
    #(self.measured_ch4, self.measured_ch4_sd) = getMeasuredCH4(ch4_inst)
    def getMeasuredCH4(self, inst):
        """ get ch4 value for this tank and fillcode """

        cals = ccg_cal_db.Calibrations(self.serialnumber, 'CH4', inst, self.fillcode)
        ave, sd, n = cals.getAvgs(cals.cals)

        if n == 0:
            print("No CH4 calibrations for %s" % (self.serialnumber), file=sys.stderr)

        return (ave, sd)

    ###################################################################
    #  Calculates the assinged CO from the measured CH4
    def calculateCO(self):
        """
        #  Calculate the uncertainty for the assigned CO

        # Brad's total uncertainty for CH4 tertiary standards
        #mol_frac       U_ppb   U_percent
        #300            1.5     0.5
        #500            1.4     0.3
        #750            1.3     0.2
        #1000           1.3     0.1
        #1500           1.5     0.1
        #1800           1.7     0.1
        #2000           1.9     0.1
        #2500           2.3     0.1
        #3000           2.8     0.1
        #4000           3.7     0.1
        #5000           4.7     0.1
        """

        parent_ratio = self.parent_co / self.parent_ch4

        val = (self.measured_ch4 - self.diluent_ch4) * parent_ratio + self.diluent_co
        #sd = self.measured_ch4_sd * parent_ratio
        #sd = 1.5 + val * 0.003
        #sd = 1.5



        #assign unc of measured CH4.  Use the total uncertainty for tertiary standards
        if self.measured_ch4 <= 400.0:
            U_ch4_measured = self.measured_ch4 * 0.005
        elif self.measured_ch4 <= 625.0 and self.measured_ch4 > 400.0:
            U_ch4_measured = self.measured_ch4 * 0.003
        elif self.measured_ch4 <= 875.0 and self.measured_ch4 > 625.0:
            U_ch4_measured = self.measured_ch4 * 0.002
        else:
            U_ch4_measured = self.measured_ch4 * 0.001

        if self.debug: print("U_ch4_measured: %f" % U_ch4_measured, file=sys.stderr)

        # assign uncertainty estimate for CH4 in zero air, +-1.0 ppb
        U_ch4_zero = 1.0
        if self.debug: print("U_ch4_zero: %f" % U_ch4_zero, file=sys.stderr)

        # assign uncertainty estimate for CO in zero air, +- 0.15 ppb
        U_co_zero = 0.15
        if self.debug: print("U_co_zero: %f" % U_co_zero, file=sys.stderr)

        # get uncertainty of parent CO:CH4 ratio
        U_p = numpy.sqrt(numpy.square(self.parent_co_unc / self.parent_co) +
                 numpy.square(self.parent_ch4_unc / self.parent_ch4)) * parent_ratio
        if self.debug: print("U_p: %20.10f" % U_p, file=sys.stderr)

        # Unc_corrected_ch4 = sqrt( Unc_ch4_measured^2 + Unc_ch4_zero^2)
        U_corr_ch4 = numpy.sqrt(numpy.square(U_ch4_measured) + numpy.square(U_ch4_zero))
        if self.debug: print("U_corr_ch4: %f" % U_corr_ch4, file=sys.stderr)

        # Unc_co = sqrt( (unc_corrected_ch4 / corrected_ch4)^2 + (unc_parent_ratio / parent_ratio)^2 ) * calculated_co
        U_co = numpy.sqrt(numpy.square(U_corr_ch4/(self.measured_ch4 - self.diluent_ch4))  +
                  numpy.square(U_p/parent_ratio)) * val
        if self.debug: print("U_co: %f" % U_co, file=sys.stderr)

        #U_corrected_co (corrected for co in diluent gas) = sqrt( U_co^2 + U_co_zero^2 )
        U_co_corr = numpy.sqrt(numpy.square(U_co) + numpy.square(U_co_zero))
        if self.debug: print("U_co_corr: %f" % U_co_corr, file=sys.stderr)

        return (val, U_co_corr)


    ###################################################################
    def getCalculatedCO(self):
        """
        #  returns the assigned CO value, plus stddev and fill flag
        #  (co, co_sd, flag) = self.getCalculatedCO()
        """

        s = "%-12.3f  %-12.3f  %s" % (self.assigned_co, self.assigned_co_sd, self.fillflag)

        return s


    ####################################################################
    def returnFullOutput(self):
        """
        # returns full output stream
        # id:  |filldate:  |fillcode:  |flag:  |project:  |notes:{}
        # |comments:{} |assigned_co:  |measured_ch4:
        # |parent_sn:  |parent_ch4:  |parent_co:
        # |diluent_sn:  |diluent_ch4:  |diluent_co:
        """

        s = "id:%s" % (self.serialnumber)
        s += "|filldate:%s" % (self.filldate)
        s += "|fillcode:%s" % (self.fillcode)
        s += "|flag:%s" % (self.fillflag)
        s += "|project:{%s}" % (self.project)
        s += "|notes:{%s}" % (self.notes)
        s += "|comments:{%s}" % (self.comments)
        s += "|assigned_co:%-12.3f" % (self.assigned_co)
        s += "|assigned_co_sd:%-12.3f" % (self.assigned_co_sd)
        s += "|measured_ch4:%-12.3f" % (self.measured_ch4)
        s += "|measured_ch4_sd:%-12.3f" % (self.measured_ch4_sd)
        s += "|parent_sn:%s" % (self.parent_sn)
        s += "|parent_ch4:%-15.1f" % (self.parent_ch4)
        s += "|parent_co:%-15.1f" % (self.parent_co)
        s += "|diluent_sn:%s" % (self.diluent_sn)
        s += "|diluent_ch4:%-12.3f" % (self.diluent_ch4)
        s += "|diluent_co:%-12.3f" % (self.diluent_co)

        return s

##### End dilution class ####################
##########################################################################
