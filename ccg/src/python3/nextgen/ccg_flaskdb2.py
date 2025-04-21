
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for handling flask data from the ccgg database.

This class is mainly for use with flask raw files and 'flpro.py',
but possibly could be used for other things.

Given a single or list of event numbers, get the sampling information and measurement
data for the events.

Flask data is in the 'ccgg' database.  The table 'sample_event'
has sampling info, and the table 'sample_data' has the measurement info.

Usage
    flask = ccg_flaskdb.Flasks(event, gas=None, database='ccgg', debug=False)
    sample_data = flask.getSampleData(event)

Input parameters
    event - flask event number, or list of event numbers
    gas - gas formula, e.g. 'CO2'
    database - database to use.  Default is 'ccgg'.
    debug - If true, print debugging information

"""
from __future__ import print_function

import datetime

import ccg_db_conn
import ccg_utils


########################################################################
class Flasks():
    """
    Class for processing flask results in the database.

    When need to separate the sample data from the measurement data because
    when processing a flask raw file right after analysis, there is no
    measurement data in the database yet.  But we still need the sampling
    information for the events.

    Attributes
        sample_data{} - dict with sampling event information.  event number is the key.
            Members of the dict are
                'num': event number
                'code': site code
                'site_num': site number
                'project_num': project number
                'date': sample date (datetime object)
                'time': sample time (timedelta)
                'id': flask id string
                'me': flask method
                'lat': latitude
                'lon': longitude
                'alt': altitude
                'strategy_num': strategy number

        measurement_data[] - list of dicts with measurement data.
            Each dict in the list contains
                'num': database index number
                'event_num': event number
                'value': measurement value
                'flag': flag
                'parameter_num': parameter number
                'date': analysis date
                'time': analysis time
                'inst': instrument id
                'system': analysis system name
    """

    def __init__(self, event, gas, database=None, debug=False):
        """
        Input parameters
            event - flask event number, or list of event numbers
            gas - gas formula, e.g. 'CO2'
            database - database to use.  Default is 'ccgg'.
            debug - If true, print debugging information
        """

        if database is None:
            database = "ccgg"
        self.db = ccg_db_conn.ProdDB(db=database)

        # we need the gas number later in updateDb()
        sql = "select num from gmd.parameter where formula=%s"
        result = self.db.doquery(sql, (gas,))
        self.gasnum = result[0]['num']

        self.sample_data = {}
        self.measurement_data = []
        self.debug = debug

        if not isinstance(event, list):
            event = [event]

        if len(event) > 0:
            self._get_sample_data(event)
            self._get_measurement_data(event, gas)

    # --------------------------------------------------------------------------
    def _get_sample_data(self, events):
        """ Get the database results for given event numbers.

        Put sample data into dict, with the event number as the key.
        """

        self.sql = self.db.sql

        # always get flask_event data from the ccgg database.
        self.sql.initQuery()
        self.sql.table("ccgg.flask_event e")
        self.sql.innerJoin("gmd.site s on e.site_num=s.num")
        self.sql.col("e.num as event_number")
        self.sql.col("e.site_num as site_num")
        self.sql.col("s.code as code")
        self.sql.col("e.dd as time_decimal")
        self.sql.col("e.date as date")
        self.sql.col("e.time as time")
        self.sql.col("e.id as flaskid")
        self.sql.col("e.me as method")
        self.sql.col("e.strategy_num as strategy_num")
        self.sql.col("e.alt as altitude")
        self.sql.col("e.lat as latitude")
        self.sql.col("e.lon as longitude")
        self.sql.col("e.comment as event_comment")
        self.sql.orderby("e.dd")
        self.sql.wherein("e.num in", events)
        results = self.db.doquery()

        # make a dict with event number as key
        t0 = datetime.time()  # time = 0
        if results:
            for row in results:
                # convert separate date and time fields to single datetime
                t1 = datetime.datetime.combine(row['date'], t0) + row['time']
                row['date'] = t1
                del row['time']
                self.sample_data[row['event_number']] = row

    # --------------------------------------------------------------------------
    def _get_measurement_data(self, events, gas):
        """ Get the database measurement results for given event numbers.

        Put measurement data into list of dicts
        """

        self.sql = self.db.sql

        self.sql.initQuery()
        self.sql.table("flask_data d")
        self.sql.innerJoin("gmd.parameter p on d.parameter_num=p.num")
        self.sql.col("d.num as data_number")
        self.sql.col("d.event_num as event_number")
        self.sql.col("p.formula as gas")
        self.sql.col("d.value as value")
        self.sql.col("d.unc as unc")
        self.sql.col("d.meas_unc as meas_unc")
        self.sql.col("d.flag as qcflag")
        self.sql.col("d.system as system")
        self.sql.col("d.inst as inst")
        self.sql.col("d.date as adate")
        self.sql.col("d.time as atime")
        self.sql.col("d.update_flag_from_tags as use_tags ")
        self.sql.col("d.comment as comment ")
        self.sql.where("p.formula=%s", gas)
        self.sql.wherein("d.event_num in", events)

        results = self.db.doquery()

        t0 = datetime.time()  # time = 0
        if results:
            for row in results:
                # convert separate date and time fields to single datetime
                t1 = datetime.datetime.combine(row['adate'], t0) + row['atime']
                row['adate'] = t1
                del row['atime']
                self.measurement_data.append(row)

    # --------------------------------------------------------------------------
    def sampleData(self, event):
        """ Return the sampling data for a given event number.

        Args:
            event: event number

        Returns:
            The self.sample_data record for the given event, or None if record not found.
        """

        evt = int(event)

        if evt in self.sample_data:
            return self.sample_data[evt]

        return None

    # --------------------------------------------------------------------------
    def measurementData(self, event, species, adate, inst=None):
        """ Find matching measurement record.

        A match is if event number, parameter number, analysis date and analysis time agree.
        If instrument id is given, then use that too.
        There can be multiple entries for the same event number and parameter.

        Args:
            event: Event number
            species: Gas formula, e.g. 'CO2'.
            adate: Analysis date (datetime)
            inst: Instrument id string

        Returns:
            Record from self.measurement_data that matches input arguments, or None if not found.
        """

        evt = int(event)

        for data in self.measurement_data:
            if inst:
                if (evt == data['event_number']
                    and species.lower() == data['gas'].lower()
                    and adate == data['adate']
                    and inst == data['inst']):

                    return data

            else:
                if (evt == data['event_number']
                    and species.lower() == data['gas'].lower()
                    and adate == data['adate']):

                    return data

        return None

    # --------------------------------------------------------------------------
    def checkDb(self, result, verbose=False):
        """ Check the result tuple with the corresponding values in the database.
        Print messages if differences are found.

        Args:
            result: namedtuple with results to check. Members are
                (event, gas, mf, flag, inst, adate, comment)
        """

        format1 = "%10s %5s %8.2f %3s %3s %s"
        line = format1 % (result.event, result.gas, result.mf, result.tag,
                          result.inst, result.adate.strftime("%Y %m %d %H %M"))

        record = self.measurementData(result.event, result.gas, result.adate, result.inst)

        if record is None:
            print("%s  not found." % line)

        else:
            dbvalue = float(record['value'])

            # Check if mole fractions agree.
            diff = result.mf - dbvalue
            if abs(diff) > 0.011:
                print("%s mole fraction mismatch (%8.2f, %6.2f)" % (line, dbvalue, diff))
            else:
                if verbose:
                    print("Mole fraction for event %7s analyzed on %s OK" % (result.event, result.adate))

    # ----------------------------------------------------------------------------------------------
    def updateDb(self, result, system, verbose=False):
        """ Update the database with results.

        Args:
            result: namedtuple with results to update. Members are
                (event, gas, mf, unc, meas_unc, tagnum, inst, adate, comment)
            system: System id string
            verbose: If set to True, print extra messages while processing.
        """

        record = self.measurementData(result.event, result.gas, result.adate, result.inst)

        table = "flask_data"

        date = result.adate.strftime("%Y-%m-%d")
        time = result.adate.strftime("%H:%M:%S")

#        record = None
        # insert a flag if the data does not exist yet, but don't update any existing flags
        # If a record was found, update the database, else insert.
        if record is None:

            query = "INSERT INTO %s SET " % table
            query += "date='%s', time='%s', dd=f_date2dec('%s', '%s'), " % (date, time, date, time)
            query += "event_num=%s, " % result.event
            query += "parameter_num=%s, " % self.gasnum
            query += "value=%.4f, " % result.mf
            query += "inst='%s', " % result.inst
            query += "system='%s', " % system
            query += "unc=%.4f, " % result.unc
            query += "meas_unc=%.4f, " % result.meas_unc
#            query += "flag=%s, " % result.flag
            query += "comment='%s' " % result.comment

        else:
            query = "UPDATE %s SET " % table
            query += "value=%.4f, " % result.mf
            query += "inst='%s', " % result.inst
            query += "system='%s', " % system
            query += "unc=%.4f, " % result.unc
            query += "meas_unc=%.4f " % result.meas_unc
            # only update comments if the comment field is empty
            # that is, don't change existing comments in the database
            if len(record['comment']) == 0:
                query += ", comment='%s' " % result.comment
            query += "WHERE num=%s" % record['data_number']

        if verbose:
            print(query)

        self.db.doquery(query)

        # add any auto tags to the flask data. Have to do this after data is inserted
        if record is None and result.tag != 0:
            if verbose:
                print("Add tag number", result.tag, "to event", result.event)
            ccg_utils.addTagNumber(result.event, result.gas, result.tag, result.inst, date, time,
                                   verbose=verbose, data_source=True)

    # ----------------------------------------------------------------------------------------------
    def deleteDb(self, result, verbose=False):
        """ Delete results from the database.

        Args:
            result: nameduple with results. Members are
                (event, gas, mf, flag, inst, adate, ddate, comment)
            verbose: If set to True, print extra messages while processing.
        """

        table = "flask_data"

        record = self.measurementData(result.event, result.gas, result.adate, result.inst)

        if record:
            sql = "DELETE FROM %s WHERE num=%d" % (table, record['num'])

            if verbose:
                print(sql)

            self.db.doquery(sql)


if __name__ == "__main__":

    f = Flasks(483911, "co2")
    print(f.sample_data)
    print(f.measurement_data)
