# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for dealing with response database table,
which has instrument response data for nl calibration curves

Structure of table is

+---------------+----------------------------------+------+-----+---------+----------------+
| Field         | Type                             | Null | Key | Default | Extra          |
+---------------+----------------------------------+------+-----+---------+----------------+
| id            | int(11)                          | NO   | PRI | NULL    | auto_increment |
| site          | varchar(6)                       | YES  |     | NULL    |                |
| parameter_num | tinyint(3) unsigned              | YES  |     | NULL    |                |
| scale_num     | int(11)                          | YES  |     | NULL    |                |
| system        | varchar(20)                      | NO   |     | NULL    |                |
| inst_id       | varchar(8)                       | YES  |     | NULL    |                |
| start_date    | datetime                         | YES  |     | NULL    |                |
| start_date_id | tinyint(4)                       | NO   |     | 1       |                |
| analysis_date | datetime                         | YES  |     | NULL    |                |
| coef0         | double                           | NO   |     | 0       |                |
| coef1         | double                           | NO   |     | 0       |                |
| coef2         | double                           | NO   |     | 0       |                |
| coef3         | double ****** cals_scale_tests2 only
| rsd           | float                            | NO   |     | 0       |                |
| n             | tinyint(3) unsigned              | NO   |     | 0       |                |
| flag          | char(1)                          | NO   |     | .       |                |
| function      | enum('poly','power')             | YES  |     | NULL    |                |
| ref_op        | enum('subtract','divide','none') | YES  |     | NULL    |                |
| ref_sernum    | varchar(20)                      | YES  |     | NULL    |                |
| standard_set  | varchar(30)                      | YES  |     |         |                |
| filename      | varchar(100)                     | YES  |     | NULL    |                |
| covar         | text                             | YES  |     | NULL    |                |
| comment       | text                             | NO   |     | NULL    |                |
+---------------+----------------------------------+------+-----+---------+----------------+

"""
from __future__ import print_function

import datetime
import math
import numpy

#sys.path.append("/ccg/src/python3/nextgen")
import ccg_dbutils
import ccg_utils

##################################################################
def getResponseValue(x, result):
    """ Calculate response curve value at given point 'x' """

    coeffs = result['coeffs']
    functype = result['function']

    if functype == "power":
        mr = ccg_utils.power(x, coeffs)
    else:
#        print("@@", coeffs, x)
        mr = ccg_utils.poly(x, coeffs)

    return mr

##################################################################
def getResponseResultString(result):
    """
    Generate a nicely formatted string from the response data in the tuple 'result'.
    'result' is a dict created from ccg_nl.py module
    """

    # new style format that has function name in result
    frmt = "%4s %s %20.8f %20.8f %20.8f %20.8f %9.5f %5d %s %s %s %s"
    s = frmt % (result['inst_id'],
            result['start_date'].strftime("%Y %m %d %H %M"),
            result['coef0'], result['coef1'], result['coef2'], result['coef3'], result['rsd'],
            result['n'], result['flag'], result['function'], result['ref_op'], result['filename'])

    return s


##################################################################
class ResponseDb():
    """
    Usage:
        resp = ccg_response.ResponseDb(gas, scalenum, system, inst_id, startdate, enddate, database)

    Args:
        gas : gas to use, e.g. CO2, CH4 ...
        scalenum : gas scale number to use, e.g. 13 = CO2_X2019.  Default is current scale for the gas.
        system : system name, e.g. 'co2cal-2', 'magicc-3' ...
        inst_id : instrument id, e.g. 'PC2' Retrieve only data that matches id
        startdate : Retrieve data that come after this date
        enddate : Retrieve data that come before this date
        database : Specify name of database that has the 'response' table.  Default is 'reftank'.

    Members:
        data : List of dicts with repsonse data for all the rows that matched. Each dict has
            key the same as database column name.  If no data found, then data = None
        last_response : Single dict of data for the last response, matching inst_id
            and enddate if requested.  This is usually what is needed.
        hasResponseCurves : Boolean if response curve data is available

    """

    #---------------------------------------------------
    def __init__(self, gas, site=None, scalenum=None, system=None, inst_id=None, startdate=None, enddate=None, database=None, debug=False):

        self.hasResponseCurves = False

        self.gas = gas
        self.site = site
        self.system = system
        self.inst_id = inst_id
        self.enddate = enddate
        self.startdate = startdate
        self.scalenum = scalenum
        self.debug = debug
        self.include_flagged = False

        if database is None:
            database = "reftank"
        self.db = ccg_dbutils.dbUtils(database=database, readonly=False)

        if self.scalenum is None:
            r = self.db.getCurrentScale(gas)
            self.scalenum = r['idx']

        self.data = self._read_response()
        if self.debug:
            if self.data is None:
                print("No records found in responsedb for", gas, inst_id)
            else:
                print(len(self.data), "records found in responsedb for", gas, inst_id)

        self.last_response = None
        if self.data:
            self.last_response = self.data[-1]
            self.hasResponseCurves = True

    #---------------------------------------------------
    def _read_response(self):
        """ Get entries from response database table.

        Keep entries that are <= enddate if given
        or all entries if neither startdate or enddate is given.
        Optionally filter also by instrument id, system, gas.

        Save entries in a list of dicts, and add 'covar' and 'coeffs' fields.
        """

        sql = 'SELECT * FROM response '

        whereclause = []
        t = []
        if self.gas:
            paramnum = self.db.getGasNum(self.gas)
            whereclause.append('parameter_num=%s')
            t.append(paramnum)
        if self.site:
            whereclause.append('site=%s')
            t.append(self.site)
        if self.scalenum:
            whereclause.append('scale_num=%s')
            t.append(self.scalenum)
        if self.system:
            whereclause.append('system=%s')
            t.append(self.system)
        if self.inst_id:
            whereclause.append('inst_id=%s')
            t.append(self.inst_id)
        if self.startdate:
            whereclause.append('start_date>=%s')
            t.append(self.startdate.strftime("%Y-%m-%d %H:%M:%S"))
        if self.enddate:
            whereclause.append('start_date<=%s')
            t.append(self.enddate.strftime("%Y-%m-%d %H:%M:%S"))
        if not self.include_flagged:
            whereclause.append('flag=%s')
            t.append('.')
            

        if whereclause:
            sql += "WHERE "
            sql += " AND ".join(whereclause)
        sql += " ORDER BY inst_id, start_date"

        t = tuple(t)
        if self.debug:
            print(sql % t)
        #print(sql % t)
        results = self.db.doquery(sql, t)
        #print(results)

        # convert covar string to numpy array and
        # combine coefficients into one list
        if results:
            for row in results:
                s = row['covar']
                a = [float(x) for x in s.split()]
                d = int(math.sqrt(len(a)))
                row['covar'] = numpy.array(a).reshape((d, d))
                row['coeffs'] = (row['coef0'], row['coef1'], row['coef2'], row['coef3'])
                row['degree'] = d - 1

        return results

    #---------------------------------------------------
    def getResponseCoef(self, date, inst_id=None):
        """ Find first response line before or equal to the given date """

        # loop backwards through the response data
        for r in self.data[::-1]:
            if inst_id:
                if inst_id == r['inst_id'] and r['start_date'] <= date:
                    return r['coeffs']

            else:
                if r['start_date'] <= date:
                    return r['coeffs']

        # return the first response data by default
        return self.data[0]['coeffs']

    #---------------------------------------------------
    def findResponse(self, date, inst_id=None):
        """ Find first response line before or equal to the given date """

        # loop backwards through the response data
        for r in self.data[::-1]:
            if inst_id:
                if inst_id == r['inst_id'] and r['start_date'] <= date:
                    return r

            else:
                if r['start_date'] <= date:
                    return r

        # return the first response data by default
        return None # self.data[0]


    #---------------------------------------------------
    def getCoeffs(self, resp=None):
        """ Get the coefficients of the response curve.
        If resp is not set, use the last_response data.
        """

        if resp:
            coeffs = resp['coeffs']
        else:
            coeffs = self.last_response['coeffs']

        return coeffs

    #---------------------------------------------------
    def getFunction(self, resp=None):
        """ Get the function used for the response curve.
        If resp is not set, use the last_response data.
        """

        if resp:
            func = resp['function']
        else:
            func = self.last_response['function']

        return func

    #---------------------------------------------------
    def getOperator(self, resp=None):
        """ Get the operator used for the response curve.
        If resp is not set, use the last_response data.
        """

        if resp:
            oper = resp['ref_op']
        else:
            oper = self.last_response['ref_op']

        return oper

    #---------------------------------------------------
    def getCovar(self, resp=None):
        """ Get the covariance matrix of the response """

        if resp:
            covar = resp['covar']
        else:
            covar = self.last_response['covar']

        return covar

    #---------------------------------------------------
    def getAdate(self, resp=None):
        """ Get the analysis date used for the response curve.
        If resp is not set, use the last_response data.
        """

        if resp:
            adate = resp['start_date']
        else:
            adate = self.last_response['start_date']

        return adate

    #--------------------------------------------------------------------------
    def getResponseValue(self, sample_value, ref_value, resp=None):
        """ Calculate response curve value at given point """

        if self.debug:
            print("\ngetResponseValue ====")

        if resp is None:
            resp = self.last_response

        ref_op = resp['ref_op']

        rr = -999.99
        if ref_op == "divide":
            rr = sample_value / ref_value
        elif ref_op == "subtract":
            rr = sample_value - ref_value
        elif ref_op == "none" or ref_op is None:
            rr = sample_value
        else:
            raise ValueError("Unknown ref_op:  %s" % ref_op)

        value = self._get_result(rr, resp)
        meas_unc = self.getResponseUnc(rr, resp)

        return value, rr, meas_unc

    #--------------------------------------------------------------------------
    def _get_result(self, rr, resp):
        """ Calculate the mole fraction result from the response curve """

        coeffs = resp['coeffs']
        functype = resp['function']

        if functype == "poly":
            value = ccg_utils.poly(rr, coeffs)
        elif functype == "power":
#            print(coeffs, rr)
            value = ccg_utils.power(rr, coeffs)
        else:
            raise ValueError("Unknown function type: %s" % functype)

        return value

    #--------------------------------------------------------------------------
    def getResponseUnc(self, rr, resp):
        """ ------ calculate repsonse uncertainty """

        fit_degree = resp['degree']
        covar = resp['covar']

        # partial derivatives of polynomial with respect to the coefficients
        # Equation 7.50, 'Applied Linear Regression Models', Neter, Wasserman and Kutner, 1983
        # Then use equation 7.55a, rsd^2  + s2(yh)
        a = numpy.array([rr**i for i in range(fit_degree+1)])

        # variance of estimated y value
        z1 = numpy.dot(a.T, covar)
        var = numpy.dot(z1, a)
        # if passed in rr was not a single number, then we need to 
        # take the diagonal of var to get an unc for each value in the rr array
        if isinstance(var, numpy.ndarray):
            var = var.diagonal()

        # add residual variance
        var = var + resp['rsd']*resp['rsd']

        meas_unc = numpy.sqrt(var)
        if self.debug:
            print("    partial der array", a)
            print("    rr is", rr)
            print("    coeffs", resp['coeffs'])
            print("    covar", covar)
            print("    response unc", meas_unc)

        return meas_unc

    #--------------------------------------------------------------------------
    def checkDb(self, results):
        """ Check if result string is in response database table, and show existing and new strings. """

        for result in results:

            match_entry = self._find_match(result)

            if match_entry is not None:
                print("Existing data: ", getResponseResultString(match_entry))
                print("New data:      ", getResponseResultString(result))
            else:
                print(getResponseResultString(result), " not found.")

        entries = self._find_all_matches(results[0])
#        print(entries)
        if entries is not None:
            nentries = len(entries)
            if len(results) < nentries:
                for i in range(len(results), nentries):
                    print("!!!Extra data: ", getResponseResultString(entries[i]))
        

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

            # convert covariance matrix to string
            a = result['covar'].flatten()
            b = [str(x) for x in a.tolist()]
            s = " ".join(b)

            # find entries that have same instrument, raw file name, parameter, system
            match_entry = self._find_match(result)
            if match_entry is None:
                # insert
                sql = "insert into response set "
                sql += "site=%s, "
                sql += "parameter_num=%s, "
                sql += "scale_num=%s, "
                sql += "system=%s, "
                sql += "inst_id=%s, "
                sql += "start_date=%s, "
                sql += "start_date_id=%s, "
                sql += "analysis_date=%s, "
                sql += "coef0=%s, "
                sql += "coef1=%s, "
                sql += "coef2=%s, "
                sql += "coef3=%s, "
                sql += "rsd=%s, "
                sql += "n=%s, "
                sql += "function=%s, "
                sql += "ref_op=%s, "
                sql += "ref_sernum=%s, "
                sql += "standard_set=%s, "
                sql += "filename=%s, "
                sql += "covar=%s "

                t = (
                    result['site'],
                    result['parameter_num'],
                    result['scale_num'],
                    result['system'],
                    result['inst_id'],
                    result['start_date'].strftime("%Y-%m-%d %H:%M:%S"),
                    result['start_date_id'],
                    result['analysis_date'].strftime("%Y-%m-%d %H:%M:%S"),
                    float(result['coeffs'][0]),
                    float(result['coeffs'][1]),
                    float(result['coeffs'][2]),
                    float(result['coeffs'][3]),
                    float(result['rsd']),
                    result['n'],
                    result['function'],
                    result['ref_op'],
                    result['ref_sernum'],
                    result['standard_set'],
                    result['filename'],
                    s,
                )


            else:
                # update
                # we match on site, parameter, system, inst_id, filename, start_date_id so those columns
                # don't need to be udpated.
                sql = "UPDATE response SET "
                sql += "scale_num=%s, "
                sql += "start_date=%s, "
                sql += "analysis_date=%s, "
                sql += "coef0=%s, "
                sql += "coef1=%s, "
                sql += "coef2=%s, "
                sql += "coef3=%s, "
                sql += "rsd=%s, "
                sql += "n=%s, "
                sql += "function=%s, "
                sql += "ref_op=%s, "
                sql += "ref_sernum=%s, "
                sql += "standard_set=%s, "
                sql += "covar=%s "
                sql += "WHERE id=%s "

                t = (
                    result['scale_num'],
                    result['start_date'].strftime("%Y-%m-%d %H:%M:%S"),
                    result['analysis_date'].strftime("%Y-%m-%d %H:%M:%S"),
                    float(result['coef0']),
                    float(result['coef1']),
                    float(result['coef2']),
                    float(result['coef3']),
                    float(result['rsd']),
                    result['n'],
                    result['function'],
                    result['ref_op'],
                    result['ref_sernum'],
                    result['standard_set'],
                    s,
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

        sql = "select * from response "
        whereclause = []
        whereclause.append("site=%s")
        whereclause.append("parameter_num=%s")
        whereclause.append("filename=%s")
        whereclause.append("inst_id=%s")
        whereclause.append("system=%s")
        whereclause.append("scale_num=%s")
        whereclause.append("start_date_id=%s")
        t = (
            result['site'],
            result['parameter_num'],
            result['filename'],
            result['inst_id'],
            result['system'],
            result['scale_num'],
            result['start_date_id'],
        )

        sql += "WHERE "
        sql += " AND ".join(whereclause)
        #print(sql % t)

        r = self.db.doquery(sql, t)

        if r:
            return r[0]

        return None

    #--------------------------------------------------------------------------
    def _find_all_matches(self, result):
        """ Find all matches for certain fields of 'result' in the response file

        A match is where parameter, system, instrument id, raw file name agree

        Args:
            'result' : is a result dict created in ccg_nl.py
        """

        sql = "select * from response "
        whereclause = []
        whereclause.append("site=%s")
        whereclause.append("parameter_num=%s")
        whereclause.append("filename=%s")
        whereclause.append("inst_id=%s")
        whereclause.append("system=%s")
        whereclause.append("scale_num=%s")
        t = (
            result['site'],
            result['parameter_num'],
            result['filename'],
            result['inst_id'],
            result['system'],
            result['scale_num'],
        )

        sql += "WHERE "
        sql += " AND ".join(whereclause)

        r = self.db.doquery(sql, t)

        return r


if __name__ == '__main__':

    import sys

    gas = 'CO2'
    system = 'LGR'
    system = 'co2cal-2'
#    system = 'co2cal-2'
    inst = 'PC1'
#    r = ResponseDb(gas, system=system, inst_id=inst, debug=True)
    r = ResponseDb(gas, site='BLD', system='co2cal-2', database='cal_scale_tests', debug=True)
    for row in r.data:
        print(row['covar'])

    date = datetime.datetime(2022, 1, 1)
    coeffs = r.getResponseCoef(date)
    print(coeffs)

    row = r.findResponse(date)
    print(date, row)
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
