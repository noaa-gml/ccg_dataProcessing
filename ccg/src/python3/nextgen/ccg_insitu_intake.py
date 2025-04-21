
# vim: tabstop=4 shiftwidth=4 expandtab
"""
class for handling database access to insitu intake heights
"""
import datetime
import ccg_dbutils

####################################################################################
class intake:
    """ class for handling insitu intake height information

    Usage::

        dt = datetime.datetime.now()
        intk = ccg_insitu_intake.intake(stacode, gas, debug)
        intk.get_height("Line1", dt)

    Arguments:
        stacode (str or int) : Station code, or station number
        gas (str) : gas formula
        debug (boolean) : If true, print debugging information

    """


    def __init__(self, stacode, gas, debug=False):

        db = ccg_dbutils.dbUtils()

        if isinstance(stacode, str):
            site_num = db.getSiteNum(stacode)
        else:
            site_num = stacode

        param_num = db.getGasNum(gas)

        self.debug = debug

        sql = "select * from intake_heights where site_num=%s and parameter_num=%s order by start_date"
        self.results = db.doquery(sql, (site_num, param_num))
        if self.results is None:
            sql = "select * from intake_heights where site_num=%s and parameter_num=0 order by start_date"
            self.results = db.doquery(sql, (site_num,))

        if self.debug:
            print("Intake heights for", site_num, gas)
            for row in self.results:
                print(row)


    #--------------------------------------------------------------
    def get_intake(self, inlet, date):
        """ Return the intake height for the given inlet on the given date

        Arguments:
            inlet (str) :  a character string for the intake line, e.g. 'L2' or 'Line1'
            date (datetime) : Get the inlet height for this date
        """

        if self.debug:
            print("Get intake for '%s' on %s" % (inlet, date))

        if isinstance(date, datetime.date):
            dt = datetime.datetime(date.year, date.month, date.day)
        else:
            dt = date

        if self.results:
            for row in self.results:
                if row['inlet'].lower() == inlet.lower() and row['start_date'] <= dt < row['end_date']:
                    return row['height']

        return 0

    #--------------------------------------------------------------
    def get_inlet(self, intake_ht, date):
        """ Return the inlet for the given intake height on the given date

        Arguments:
            intake_ht (float) :  a float value for the intake height
            date (datetime) : Get the inlet for this date
        """

        if self.debug:
            print("Get inlet for '%s' on %s" % (intake_ht, date))

        if isinstance(date, datetime.date):
            dt = datetime.datetime(date.year, date.month, date.day)
        else:
            dt = date

        if self.results:
            for row in self.results:
                if row['height'] == intake_ht and row['start_date'] <= dt < row['end_date']:
                    return row['inlet']

        return None

if __name__ == "__main__":
    import datetime

    dt = datetime.datetime.now()

    debug = True

    intk = intake("bnd", "co2", debug=debug)
    ht = intk.get_intake("Line1", dt)
#    inlet = intk.get_inlet(122, dt)
    print(ht)
#    print(inlet)
    sys.exit()

    intk = intake(75, "co2", debug=debug)
    ht = intk.get_intake("Line2", dt)
    print(ht)

    dt = datetime.datetime(1987, 8, 1)
    intk = intake("mlo", "co2", debug=debug)
    ht = intk.get_intake("Line1", dt)
    print(dt, ht)

    dt = datetime.datetime(2018, 8, 1)
    intk = intake("smo", "co2", debug=debug)
    ht = intk.get_intake("Line2", dt)
    print(ht)

    dt = datetime.datetime(2024, 3, 1)
    intk = intake("cao", "co2", debug=debug)
    ht = intk.get_intake("Line2", dt)
    print(ht)
