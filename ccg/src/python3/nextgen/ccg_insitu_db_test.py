# vim: tabstop=4 shiftwidth=4 expandtab
"""
class for handling database access to insitu tables

For use with ccgis.py program

Modified June 2021 to use proposed new database table structure
"""

import sys

import ccg_dbutils
import ccg_instrument
import ccg_uncdata
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
             database="kwt",
             verbose=False,
             debug=False):

        self.stacode = stacode
        self.lcspecies = species.lower()
        self.system = system
        self.verbose = verbose
        self.debug = debug
        self.sample_type=smptype
        self.force_flag = force_flag

        self.db = ccg_dbutils.dbUtils(database, readonly)

        self.inst = ccg_instrument.instrument(self.stacode, species, self.system)
        if len(self.inst.inst_list) == 0:
            print("No instruments found for ", self.stacode, species, file=sys.stderr)
            print("Update inst_usage_history database table.", file=sys.stderr)
            sys.exit()


        # Read in the uncertainty data.  added 28 Feb 2018
# uncertainties from table are put in the hour average table - may 2022
#        uncfile = "/ccg/%s/in-situ/uncertainty.%s" % (self.lcspecies, self.lcspecies)
#        uncfile = "/ccg/src/python3/nextgen/uncertainty.%s" % (self.lcspecies)
#        self.unc = ccg_uncdata.dataUnc(uncfile, debug=self.debug)
#        if self.debug:
#            print("Uncertainties")
#            print(self.unc.uncertainties)

        # get sample intake hieght information.  Needed for updateDb()
        self.intake = ccg_insitu_intake.intake(self.stacode)


    #--------------------------------------------------------------
    def _get_dbtable(self):
        """ Get the database table name """

        table = "%s_%s_insitu" % (self.stacode.lower(), self.lcspecies)
        if self.sample_type == "TGT":
            table = table.replace("insitu", "target")

        return table

    #--------------------------------------------------------------
    def _find_record(self, dbtable, date, instnum):
        """ Find an existing record in the database.  """

        datestr = "%d-%02d-%02d %02d:%02d:%02d" % (date.year, date.month, date.day, date.hour, date.minute, date.second)
        sql = "SELECT flag, value FROM %s " % dbtable
        sql += "WHERE date = %s "
        sql += "AND system = %s "
        sql += "AND inst_num = %s "
        result = self.db.doquery(sql, (datestr, self.system.lower(), instnum))

        return result

    #--------------------------------------------------------------
    def checkDb(self, row):
        """ Check the result string with the corresponding value in the database.
        Input:
            row - namedtuple with results.
        """

        dbtable = self._get_dbtable()
        inst_num = self.inst.getInstrumentNumber(row.date)
        record = self._find_record(dbtable, row.date, inst_num)

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

        dbtable = self._get_dbtable()
        inst_num = self.inst.getInstrumentNumber(row.date)

        # Find the record.
        record = self._find_record(dbtable, row.date, inst_num)
        if self.debug:
            print("Record for", row, "is", record)

        # If a record was found, update the database, else insert
        # keep the flag from the database if updating.
        if record is None:
            self._update_db(dbtable, row, inst_num, insert=True)

        else:
            # check on retaining existing flag from database
            db_flag = record[0]['flag']

            # Don't update data with a new '>' or '<' flag
            # This can happen at the ends of the results if previous or next reference gas is missing,
            # but was processed correctly sometime before.
            if db_flag[2] == "." and (row.flag[2] == ">" or row.flag[2] == "<") and self.force_flag is False: return

            flag = self._qc_flag(db_flag, row.flag)

            self._update_db(dbtable, row, inst_num, flag=flag, insert=False)

    #--------------------------------------------------------------
    def _update_db(self, dbtable, result, instnum, flag=None, insert=False):
        """ Update or insert a record in the database
        Input:
            dbtable - database table to work with
            result - namedtuple with results.
            instnum - instrument number
            flag - flag to use instead of the flag field in result
            insert - True to insert new data, false to update existing data
        """

        # target tables have column called 'type' instead of 'intake-ht'
        if self.sample_type == "TGT":
            intake_ht = 0
        else:
            intake_ht = self.intake.get_intake(result.sample, result.date)

        # get uncertainty value for this observation - added 28 Feb 2018
#        if result.unc > 0:
#            uncs = self.unc.getUncertainties(self.stacode, result.date, result.mf, "*", instnum)
            # assumes that repeatability unc is not in both uncertainty table and calculated
#            uncs = uncs + [result.unc]
    #        print(uncs)
#            uncval = self.unc.getTotalUncertainty(uncs)
#        else:
#            uncval = -999.99

        if insert:
            query = "INSERT INTO %s SET " % dbtable
            query += "date='%s', " % result.date.strftime("%Y-%m-%d %H:%M:%S")
            query += "dd=date2dec('%s', '%s'), " % (result.date.strftime("%Y-%m-%d"), result.date.strftime("%H:%M:%S"))
            query += "value=%.4f, " % result.mf
            query += "n=%d, " % result.n
            query += "std_dev=%.2f, " % result.stdv
            query += "meas_unc = %.2f, " % result.unc
            query += "random_unc = %.2f, " % result.ref_unc
            query += "flag='%s', " % result.flag
            query += "inlet='%s', " % result.sample
            query += "intake_ht=%.2f, " % intake_ht
            query += "system='%s', " % self.system.lower()
            query += "inst_num=%s, " % instnum
            query += "comment='%s' " % result.comment

        else:
            query = "UPDATE %s SET " % dbtable
            query += "value=%.4f, " % result.mf
            query += "n=%d, " % result.n
            query += "std_dev=%.2f, " % result.stdv
            query += "meas_unc=%.2f, " % result.unc
            query += "random_unc=%.2f, " % result.ref_unc
            query += "flag='%s', " % flag
            query += "inlet='%s', " % result.sample
            query += "intake_ht=%.2f, " % intake_ht
            query += "comment='%s' " % (result.comment)
            query += "WHERE date='%s' " % result.date.strftime("%Y-%m-%d %H:%M:%S")
            query += "AND inst_num=%s " % (instnum)
            query += "AND system='%s' " % (self.system.lower())

        if self.verbose:
            print(query)
        self.db.doquery(query)


    #--------------------------------------------------------------
    @staticmethod
    def _qc_flag(old, new):
        """ Logic for retaining and overwriting existing QC flags.
        Overwrite an existing 1st column flag IFF existing 1st column flag IS '*', '&' OR '.'
        OR the new flag has an '*" in the 1st column.
        Never overwrite an existing 2nd column flag unless it is '.'
        Never overwrite an existing 3rd column flag unless it is '.' or '>' or '<'
        """

        f1 = old[0]
        f2 = old[1]
        f3 = old[2]
        n1 = new[0]
        n2 = new[1]
        n3 = new[2]

        if f1 in ('*', '.', '&') or n1 == '*': f1 = n1
        if f1 == "I" and n1 == "F": f1 = n1  # let new acdie flagging override old flags
        if f2 == '.': f2 = n2
        if f3 in ('.', '>', '<', '+'): f3 = n3

        return f1+f2+f3
