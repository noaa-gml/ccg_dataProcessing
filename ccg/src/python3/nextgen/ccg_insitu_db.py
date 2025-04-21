# vim: tabstop=4 shiftwidth=4 expandtab
"""
class for handling database access to insitu tables

For use with ccgis.py program

Modified June 2021 to use proposed new database table structure
"""

import sys
import datetime

import ccg_dbutils
import ccg_instrument
import ccg_insitu_intake


####################################################################################
class InsituDB:
    """ Insitu database class
    Usage
        isdb = ccg_insitu_db.InsituDB(stacode, species, system, smptype,
                     force_flag, readonly, database, verbose, debug)
        isdb.checkDb(result)

    Input parameters
        stacode - Station code
        species - gas formula, e.g. 'CO2'
        system - measurement system, e.g. 'GC', 'NDIR', 'LGR', 'PIC'
        smptype - Type of sample to use, either 'SMP', or 'TGT'
        force_flag - Force an update of the flag field in the database
        readonly - Open database with readonly access
        database - database to use. Default is 'ccgg'.
        verbose - Print extra messages
        debug - If true, print debugging information
    """


    def __init__(self, stacode, species, system,
             smptype="SMP",
             force_flag=False,
             readonly=True,
             database="ccgg",
             newdb = False,
             verbose=False,
             debug=False):

        self.stacode = stacode
        self.lcspecies = species.lower()
        self.system = system
        self.verbose = verbose
        self.debug = debug
        self.sample_type=smptype
        self.force_flag = force_flag
        self.newdb = newdb
        host = ""

        self.db = ccg_dbutils.dbUtils(database, readonly, host=host)

        self.inst = ccg_instrument.instrument(self.stacode, species, self.system)
#        print(self.inst.inst_list)
#        if len(self.inst.inst_list) == 0:
        if self.inst is None:
            print("No instruments found for ", self.stacode, species, file=sys.stderr)
            print("Update inst_usage_history database table.", file=sys.stderr)
            sys.exit()


        # Read in the uncertainty data.  added 28 Feb 2018
        # uncertainties from table are put in the hour average table - may 2022

        # get sample intake height information.  Needed for updateDb()
        self.intake = ccg_insitu_intake.intake(self.stacode, species)

        # get site number for stacode
        self.site_num = self.db.getSiteNum(self.stacode)

        # get parameter number for species
        self.parameter_num = self.db.getGasNum(self.lcspecies)

    #--------------------------------------------------------------
    def _get_dbtable(self, dt):
        """ Get the database table name """

        table = "%s_%s_insitu" % (self.stacode.lower(), self.lcspecies)
        if self.sample_type == "TGT":
            table = table.replace("insitu", "target")

        if self.system == "LGR" and self.lcspecies == "co2" and dt < datetime.datetime(2017, 1, 1):
            table += "_b"

        if self.system == "PIC" and self.lcspecies == "co2" and dt < datetime.datetime(2019, 6, 1):
            table += "_b"


        return table


    #--------------------------------------------------------------
    def _find_record(self, date, instnum):
        """ Find an existing record in the database.  """

        if not self.newdb:
            dbtable = self._get_dbtable(date)
            datestr = "%d-%d-%d" % (date.year, date.month, date.day)
            sql = "SELECT flag, value FROM %s " % dbtable
            if self.stacode.lower() == "mko":
                sql += "WHERE date='%s' AND hr=%d AND min=%d " % (datestr, date.hour, date.minute)
            else:
                sql += "WHERE date='%s' AND hr=%d AND min=%d AND sec=%d " % (datestr, date.hour, date.minute, date.second)
            sql += "AND inst='%s' " % instnum
#            print(sql)
            result = self.db.doquery(sql)
#            print(result)

        else:
            datestr = date.strftime("%Y-%m-%d %H:%M:%S")
            sql = "SELECT num, flag, value, comment FROM insitu_data "
            sql += "WHERE date = %s "
            sql += "AND site_num = %s "
            sql += "AND parameter_num = %s "
            sql += "AND system = %s "
            sql += "AND inst_num = %s "
            if self.sample_type == "TGT":
                sql += "AND target = 1 "
            else:
                sql += "AND target = 0 "
            result = self.db.doquery(sql, (datestr, self.site_num, self.parameter_num, self.system.lower(), instnum))
#        print(sql, (datestr, self.site_num, self.parameter_num, self.system.lower(), instnum))
#            print(sql % (datestr, self.site_num, self.parameter_num, self.system.lower(), instnum))

        return result

    #--------------------------------------------------------------
    def checkDb(self, row):
        """ Check the result string with the corresponding value in the database.
        Input:
            row - namedtuple with results.
        """

        if not self.newdb:
            inst = self.inst.getInstrumentId(row.date)
            if inst is None:
                print("Instrument number not found for date", row.date, file=sys.stderr)
            record = self._find_record(row.date, inst)
        else:
            inst_num = self.inst.getInstrumentNumber(row.date)
            if inst_num is None:
                print("Instrument number not found for date", row.date, file=sys.stderr)
            record = self._find_record(row.date, inst_num)

        if record is None:
            line = self._format_line(row)
            print("%s not found." % line)
        else:
            # Check if mole fractions agree.
            db_flag = record[0]['flag']
            db_value = record[0]['value']
            flag = self._qc_flag(db_flag, row.flag)
            diff = row.mf - db_value
            if abs(diff) > 0.011:
                line = self._format_line(row, flag=flag)
                print("%s : mole fraction mismatch (%8.2f, %6.2f)" % (line, db_value, diff))
            else:
                if self.verbose:
                    format1 = "Mole fraction on %s OK"
                    print(format1 % (row.date.strftime("%Y-%m-%d %H:%M:%S")))

#            diff = row.unc - record[0]['unc']
#            if abs(diff) > 0.01:
#                line = self._format_line(row, flag=flag)
#                print("%s : meas_unc mismatch (%8.2f, %6.2f)" % (line, record[0]['unc'], diff))

            # check if flags agree
            if flag != db_flag:
                line = self._format_line(row, flag=flag)
                print("%s : flag mismatch (%s)" % (line, db_flag))

    #--------------------------------------------------------------
    @staticmethod
    def _format_line(row, flag=None):
        """ Format the result row into a nice string """

        format1 = "%3s %s %8.2f %8.2f %3d %3s %s"
        if flag is None:
            line = format1 % (row.stacode,
                      row.date.strftime("%Y-%m-%d %H:%M:%S"),
                      row.mf,
                      row.stdv,
                      row.n,
                      row.flag,
                      row.sample)

        else:
            line = format1 % (row.stacode,
                      row.date.strftime("%Y-%m-%d %H:%M:%S"),
                      row.mf,
                      row.stdv,
                      row.n,
                      flag,
                      row.sample)

        return line

    #--------------------------------------------------------------
    def updateDb(self, row):
        """ Update the database with new values from results.
        Input:
            row - namedtuple with results.
        """

        # Find the record.
        if not self.newdb:
            inst_num = self.inst.getInstrumentId(row.date)
            dbtable = self._get_dbtable(row.date)
        else:
            inst_num = self.inst.getInstrumentNumber(row.date)

        if inst_num is None:
            print("Instrument number not found for date", row.date, file=sys.stderr)

        record = self._find_record(row.date, inst_num)

        if self.debug:
            print("Record for", row, "is", record)

        # If a record was found, update the database, else insert
        # keep the flag from the database if updating.
        if record is None:
            if not self.newdb:
                self._update_db_legacy(dbtable, row, inst_num, insert=True)
            else:
                self._update_db(0, row, inst_num, insert=True)

        else:
            # check on retaining existing flag from database
            db_flag = record[0]['flag']

            # Don't update data with a new '>' or '<' flag
            # This can happen at the ends of the results if previous or next reference gas is missing,
            # but was processed correctly sometime before.
            # If first character of new flag is not '.', then go ahead and update flag
            if db_flag[2] == "." and row.flag[0] == "." and (row.flag[2] == ">" or row.flag[2] == "<") and self.force_flag is False: return

            # if a comment already exists in database, keep it and don't use a comment from raw data
            update_comment = True
            if len(record[0]['comment']) != 0:
                update_comment = False

            flag = self._qc_flag(db_flag, row.flag)

            if not self.newdb:
                self._update_db_legacy(dbtable, row, inst_num, flag=flag, insert=False)
            else:
                self._update_db(record[0]['num'], row, inst_num, flag=flag, update_comment=update_comment, insert=False)

    #--------------------------------------------------------------
    def _update_db(self, id_num, result, instnum, flag=None, update_comment=False, insert=False):
        """ Update or insert a record in the database
        Input:
            id_num - the id number of the row in the database.  Set to 0 and not used if insert=True
            result - namedtuple with results.
            instnum - instrument number
            flag - flag to use instead of the flag field in result
            insert - True to insert new data, false to update existing data
        """

        if self.sample_type == "TGT":
            intake_ht = 0
            target = 1
        else:
            intake_ht = self.intake.get_intake(result.sample, result.date)
            target = 0
            # fix for separate co2 and ch4 lines at mlo in 1987/1988
            if self.site_num==75 and self.parameter_num==2 and result.date.year in [1987, 1988]:
                intake_ht = 40.0

#        target = 1 if "TGT" in result.sample else 0

        if insert:
            query = "INSERT INTO insitu_data SET "
            query += "site_num=%s, " % self.site_num
            query += "parameter_num=%s, " % self.parameter_num
            query += "date='%s', " % result.date.strftime("%Y-%m-%d %H:%M:%S")
            query += "value=%.4f, " % result.mf
            query += "n=%d, " % result.n
            query += "std_dev=%.2f, " % result.stdv
            query += "meas_unc = %.2f, " % result.unc
            query += "random_unc = %.2f, " % result.ref_unc
            query += "flag='%s', " % result.flag
            query += "inlet='%s', " % result.sample
            query += "target=%d, " % target
            query += "intake_ht=%.2f, " % intake_ht
            query += "system='%s', " % self.system.lower()
            query += "inst_num=%s, " % instnum
            query += "comment='%s' " % result.comment

        else:
            query = "UPDATE insitu_data SET "
            query += "value=%.4f, " % result.mf
            query += "n=%d, " % result.n
            query += "std_dev=%.2f, " % result.stdv
            query += "meas_unc=%.2f, " % result.unc
            query += "random_unc=%.2f, " % result.ref_unc
            query += "flag='%s', " % flag
            query += "inlet='%s', " % result.sample
            query += "target=%d, " % target
            query += "intake_ht=%.2f " % intake_ht
            if update_comment:
                query += ", comment='%s' " % (result.comment)
            query += "WHERE num=%s " % id_num
#            query += "WHERE date='%s' " % result.date.strftime("%Y-%m-%d %H:%M:%S")
#            query += "AND site_num=%s " % self.site_num
#            query += "AND parameter_num=%s " % self.parameter_num
#            query += "AND inst_num=%s " % (instnum)
#            query += "AND system='%s' " % (self.system.lower())

        if self.verbose:
            print(query)
        r = self.db.doquery(query, insert=True)
#        print(r)

    #--------------------------------------------------------------
    def _update_db_legacy(self, dbtable, result, inst, flag=None, insert=False):
        """ Update or insert a record in the database
        Input:
            dbtable - database table to work with
            result - namedtuple with results.
            inst - instrument id
            flag - flag to use instead of the flag field in result
            insert - True to insert new data, false to update existing data
        """

        # target tables have column called 'type' instead of 'intake-ht'
        if self.sample_type == "TGT":
            optfield = "type"
            optvalue = result.sample
        else:
            optfield = "intake_ht"
            optvalue = self.intake.get_intake(result.sample, result.date)
            intakeline = int(result.sample.strip("Line"))
            if intakeline not in (0, 1):    # we now want to use line number 1 or 2 instead of port number for inlet value
                intakeline = 2      # added 28 Feb 2018
            # fix for separate co2 and ch4 lines at mlo in 1987/1988
            if self.site_num==75 and self.parameter_num==2 and result.date.year in [1987, 1988]:
                optvalue = 40.0

        # get uncertainty value for this observation - added 28 Feb 2018
        if result.unc > 0:
            uncval = result.unc
        else:
            uncval = -999.99

        if insert:
            query = "INSERT INTO %s SET " % dbtable
            query += "date='%s', " % result.date.strftime("%Y-%m-%d")
#            query += "hr=%d, min=%d, sec=%d, " % (result.date.hour, result.date.minute, result.date.second)
            query += "hr=%d, min=%d, " % (result.date.hour, result.date.minute)
            query += "dd=f_date2dec('%s', '%s'), " % (result.date.strftime("%Y-%m-%d"), result.date.strftime("%H:%M:0"))
            query += "value=%.4f, " % result.mf
            query += "n=%d, " % result.n
            query += "std_dev=%.2f, " % result.stdv
            query += "unc = %.2f, " % uncval
            query += "flag='%s', " % result.flag
            if self.sample_type != "TGT":
                query += "inlet=%s, " % intakeline
            query += "%s='%s', " % (optfield, optvalue)
            query += "inst='%s' " % inst

        else:
            query = "UPDATE %s SET " % dbtable
            query += "value=%.4f, " % result.mf
            query += "n=%d, " % result.n
            query += "std_dev=%.2f, " % result.stdv
            query += "unc=%.2f, " % uncval
            query += "flag='%s', " % flag
            if self.sample_type != "TGT":
                query += "inlet=%s, " % intakeline
            query += "%s='%s' " % (optfield, optvalue)
            query += "WHERE date='%s' " % result.date.strftime("%Y-%m-%d")
#            query += "AND hr=%d AND min=%d AND sec=%d " % (result.date.hour, result.date.minute, result.date.second)
            query += "AND hr=%d AND min=%d " % (result.date.hour, result.date.minute)
            query += "AND inst='%s' " % (inst)

        if self.verbose:
            print(query)
        self.db.doquery(query)


    #--------------------------------------------------------------
    def _qc_flag(self, old, new):
        """ Logic for retaining and overwriting existing QC flags.
        Overwrite an existing 1st column flag IFF existing 1st column flag IS '*', '&' OR '.'
        OR the new flag has an '*" in the 1st column.
        Never overwrite an existing 2nd column flag unless it is '.'
        Never overwrite an existing 3rd column flag unless it is '.' or '>' or '<'
        """

        # for tower sites, the flag is always what's coming from processing, regardless of database flag
        if self.stacode not in ['brw', 'mlo', 'mko', 'smo', 'spo', 'cao']:
            return new

        f1 = old[0]
        f2 = old[1]
        f3 = old[2]
        n1 = new[0]
        n2 = new[1]
        n3 = new[2]

        if f1 in ('*', '.', '&', 'F') or n1 == '*': f1 = n1
        if f1 == "I" and n1 == "F": f1 = n1  # let new acdie flagging override old flags
#        if f1 != "." and n1 != ".": f1 = n1  # a non '.' can be replaced with a different non '.'
        if f2 == '.': f2 = n2
        if f3 in ('.', '>', '<', '+'): f3 = n3

        return f1+f2+f3
