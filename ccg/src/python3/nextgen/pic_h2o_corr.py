# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for dealing with picarro water correction database table,
which has instrument coefficients from water calibration

Structure of table is

+---------------+---------------------+------+-----+---------+----------------+
| Field         | Type                | Null | Key | Default | Extra          |
+---------------+---------------------+------+-----+---------+----------------+
| id            | int(11)             | NO   | PRI | NULL    | auto_increment |
| parameter_num | tinyint(3) unsigned | YES  |     | NULL    |                |
| scale_num     | int(11)             | YES  |     | NULL    |                |
| inst_id       | varchar(8)          | YES  |     | NULL    |                |
| analysis_date | date                | YES  |     | NULL    |                |
| coef0         | double              | NO   |     | 0       |                |
| coef1         | double              | NO   |     | 0       |                |
| coef2         | double              | NO   |     | 0       |                |
| coef3         | double              | NO   |     | NULL    |                |
| flag          | char(1)             | NO   |     | .       |                |
| filename      | varchar(100)        | YES  |     | NULL    |                |
| comment       | text                | YES  |     | NULL    |                |
+---------------+---------------------+------+-----+---------+----------------+

"""
from __future__ import print_function

import sys
import datetime

#sys.path.append("/ccg/src/python3/nextgen")
import ccg_dbutils

##################################################################
def getCorrResultString(result):
    """
    Generate a nicely formatted string from the response data in the tuple 'result'.
    'result' is a dict created from ccg_nl.py module
    """

    # new style format that has function name in result
    frmt = "%6s %10s %s %15.8f %15.8f %15.8f %15.8f %s %s"
    s = frmt % (result['gas'].upper(), result['inst_id'],
            result['analysis_date'].strftime("%Y %m %d"),
            result['coef0'], result['coef1'], result['coef2'], result['coef3'],
            result['flag'], result['filename'])

    return s


##################################################################
class WaterCorrectionDb():
    """
    Usage:
        corr = ccg_pic_h2o_corr.WaterCorrectionDb(gas, inst_id, database)

    Args:
        gas : gas to use, e.g. CO2, CH4 ...
        inst_id : instrument id, e.g. 'PIC-039' Retrieve only data that matches id
        database (optional): Specify name of database that has the 'pic_h2o_corr' table.  Default is '???'.

    Members:
        data : List of dicts with correction data for all the rows that matched. Each dict has
            key the same as database column name.  If no data found, then data = None

    """

    #---------------------------------------------------
    def __init__(self, gas, inst_id, database=None, debug=False):


        self.gas = gas.upper()
        self.inst_id = inst_id
        self.debug = debug

        if database is None:
            database = "kwt"
        self.db = ccg_dbutils.dbUtils(database=database, readonly=False)

        self.data = self._read_db()
        if self.debug:
            print("%d records found in pic_h2o_corr for %s %s" % (len(self.data), gas, inst_id))


    #---------------------------------------------------
    def _read_db(self):
        """ Get entries from water correction database table.

        Keep entries that are <= enddate if given
        or all entries if neither startdate or enddate is given.
        Optionally filter also by instrument id, system, gas.

        Save entries in a list of dicts, and add 'covar' and 'coeffs' fields.
        """

        sql = 'SELECT * FROM pic_h2o_corr '

        whereclause = []
        t = []

        paramnum = self.db.getGasNum(self.gas)
        whereclause.append('parameter_num=%s')
        t.append(paramnum)

        whereclause.append('inst_id=%s')
        t.append(self.inst_id)


        if whereclause:
            sql += "WHERE "
            sql += " AND ".join(whereclause)
        sql += " ORDER BY inst_id, analysis_date"

        t = tuple(t)
        if self.debug:
            print(sql % t)
        results = self.db.doquery(sql, t)
#        print(results)

        # combine coefficients into one list
        if results:
            for row in results:
                row['coeffs'] = (row['coef0'], row['coef1'], row['coef2'], row['coef3'])

        return results

    #---------------------------------------------------
    def getCoef(self, date):
        """ Return coefficients before or equal to the given date """

        if type(date) == datetime.datetime:
            dt = date.date()
        else:
            dt = date

        # loop backwards through the response data
        for r in self.data[::-1]:
            if r['analysis_date'] <= dt:
                return r['coeffs']

        # return the first response data by default
        return self.data[0]['coeffs']

    #---------------------------------------------------
    def findResult(self, date):
        """ Find first response line before or equal to the given date """

        # loop backwards through the response data
        for r in self.data[::-1]:
            if r['analysis_date'] <= date.date():
                return r

        # return the first response data by default
        return None # self.data[0]

    #--------------------------------------------------------------------------
    def applyCorrection(self, h2o, value, date):
        """ Apply the correction to the given value

        h2o is a value from the picarro, in % units
        h2o and value can be either a single number, or a numpy array of numbers

        coefficients for ch4, co are for ppb
        Value for ch4 and co must be in ppm, which is what the picarro puts out.
        Return value for ch4 and co is in ppm
        """

        c = self.getCoef(date)
        if self.debug:
            print("Coefficients for %s" % date, "are", c)
        if self.gas == "CO2":
            r = c[0] + c[1]*h2o + c[2]*h2o*h2o
            corr_value = value / r
        elif self.gas ==  "CH4":
            r = c[0] + c[1]*h2o + c[2]*h2o*h2o
            # convert to ppb, apply correction, convert back to ppm
            corr_value = value*1000 / r / 1000
        elif self.gas == "CO":
            r = c[0] + c[1]*h2o + c[2]*h2o*h2o + c[3]*h2o*h2o*h2o
            # convert to ppb, apply correction, convert back to ppm
            corr_value = (value*1000 - r) / 1000
        else:
            sys.exit("Unknown parameter %s. Correction method unknown" % self.gas)

        return corr_value

    #--------------------------------------------------------------------------
    def checkDb(self, results):
        """ Check if result string is in database table, and show existing and new strings. """

        for result in results:

            match_entry = self._find_match(result)

            if match_entry is not None:
                print("Existing data: ", getCorrResultString(match_entry))
                print("New data:      ", getCorrResultString(result))
            else:
                print(getCorrResultString(result), " not found.")

        entries = self._find_all_matches(results[0])
#        print(entries)
        if entries is not None:
            nentries = len(entries)
            if len(results) < nentries:
                for i in range(len(results), nentries):
                    print("!!!Extra data: ", getCorrResultString(entries[i]))
        

    #--------------------------------------------------------------------------
    def updateDb(self, results):
        """ Update the response curve file with calculated results """

        # if updating, check that the number of new results is >= to the number
        # of exisiting results in the database.  If it is less, then that means
        # a start date was removed from the raw file, and we need to remove
        # all entries and re-insert the new ones.
        result = results[0]
        entries = self._find_all_matches(result)
        if entries is not None:
            nentries = len(entries)
            if len(results) < nentries:
                self._delete_entries(entries)

        # 
        for result in results:

            # find entries that have same instrument, raw file name, parameter
            match_entry = self._find_match(result)
            if match_entry is None:
                # insert
                sql = "insert into kwt.pic_h2o_corr set "
                sql += "parameter_num=%s, "
                sql += "scale_num=%s, "
                sql += "inst_id=%s, "
                sql += "analysis_date=%s, "
                sql += "coef0=%s, "
                sql += "coef1=%s, "
                sql += "coef2=%s, "
                sql += "coef3=%s, "
                sql += "flag=%s, "
                sql += "filename=%s "

                t = (
                    result['parameter_num'],
                    result['scale_num'],
                    result['inst_id'],
                    result['analysis_date'].strftime("%Y-%m-%d"),
                    result['coef0'],
                    result['coef1'],
                    result['coef2'],
                    result['coef3'],
                    result['flag'],
                    result['filename'],
                )


            else:
                # update
                # we match on site, parameter, system, inst_id, filename, start_date_id so those columns
                # don't need to be udpated.
                sql = "UPDATE kwt.pic_h2o_corr SET "
                sql += "scale_num=%s, "
                sql += "analysis_date=%s, "
                sql += "coef0=%s, "
                sql += "coef1=%s, "
                sql += "coef2=%s, "
                sql += "coef3=%s "
                sql += "WHERE id=%s "

                t = (
                    result['scale_num'],
                    result['analysis_date'].strftime("%Y-%m-%d"),
                    result['coef0'],
                    result['coef1'],
                    result['coef2'],
                    result['coef3'],
                    match_entry['id'],
                )


#            print(sql)
#            print(t)
            self.db.doquery(sql, t)

    #--------------------------------------------------------------------------
    def deleteDb(self, result):
        """ Delete the result from the response curve file """

        # delete any existing entries where instrument id and raw file name match result
        del_entry = self._find_match(result)

        if del_entry:
            sql = "DELETE from response WHERE id=%s "
            t = (del_entry['id'], )
            self.db.doquery(sql, t)

    #--------------------------------------------------------------------------
    def _delete_entries(self, entries):
        """ Delete all entries for a raw file """

        for entry in entries:
            sql = "DELETE from response WHERE id=%s "
            t = (entry['id'], )
            self.db.doquery(sql, t)
        
    #--------------------------------------------------------------------------
    def _find_match(self, result):
        """ Find a match for 'result' in the response file

        A match is where parameter, system, instrument id, raw file name and start_date_id agree

        Args:
            'result' : is a result dict created in ccg_nl.py
        """

        sql = "select * from pic_h2o_corr "
        whereclause = []
        whereclause.append("parameter_num=%s")
        whereclause.append("filename=%s")
        whereclause.append("inst_id=%s")
        whereclause.append("scale_num=%s")
        whereclause.append("analysis_date=%s")
        t = (
            result['parameter_num'],
            result['filename'],
            result['inst_id'],
            result['scale_num'],
            result['analysis_date'],
        )

        sql += "WHERE "
        sql += " AND ".join(whereclause)
#        print(sql % t)

        r = self.db.doquery(sql, t)

        if r:
            gas = self.db.getGasFormula(r[0]['parameter_num'])
            r[0]['gas'] = gas
            return r[0]

        return None

    #--------------------------------------------------------------------------
    def _find_all_matches(self, result):
        """ Find all matches for certain fields of 'result' in the response file

        A match is where parameter, system, instrument id, raw file name agree

        Args:
            'result' : is a result dict created in ccg_nl.py
        """

        sql = "select * from pic_h2o_corr "
        whereclause = []
        whereclause.append("parameter_num=%s")
        whereclause.append("filename=%s")
        whereclause.append("inst_id=%s")
        whereclause.append("scale_num=%s")
        t = (
            result['parameter_num'],
            result['filename'],
            result['inst_id'],
            result['scale_num'],
        )

        sql += "WHERE "
        sql += " AND ".join(whereclause)

        r = self.db.doquery(sql, t)

        return r


if __name__ == '__main__':

    import sys
    import numpy

    gas = 'CH4'
    inst = 'PIC-042'
    r = WaterCorrectionDb(gas, inst, debug=True)
    for row in r.data:
        print(row)

    sys.exit()

    date = datetime.datetime(2022, 1, 1)
    coeffs = r.getCoef(date)
    print(coeffs)

    row = r.findResult(date)
    print(date, row)

    h2o = numpy.array((0.1, 0.2, 0.3))
    co2 = numpy.array((420, 421, 422))
    nv = r.applyCorrection(h2o, co2, date)
    print(nv)
    sys.exit()

    c = r.getCoeffs()  # get coeffs from last reponse
    print(c)
    c = r.getCoeffs(row)
    print(c)

    c = r.getFunction()
    print(c)
    c = r.getFunction(row)
    print(c)

    c = r.getOperator()
    print(c)
    c = r.getOperator(row)
    print(c)

    c = r.getAdate()
    print(c)
    c = r.getAdate(row)
    print(c)


    sample_value = 604
    ref_value = 404
    v, rr, unc = r.getResponseValue(sample_value, ref_value)
    print(v, rr, unc)

    v = getResponseValue(0.0, row)
    print(v)

    r.checkDb(row)
#    r.updateDb(row)
