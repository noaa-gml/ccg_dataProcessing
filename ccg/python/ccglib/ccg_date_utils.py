#!/usr/bin/env python

"""
Class: date_conversions()
    Generalized python class for conversions between common date formats.
    Converts input to timezone aware datetime objects using pytz module, then converts datetime objects to UTC.
    Inputs: Scalars or iterables (e.g. lists, tuples, numpy arrays) of dates
    Output: List of dates

Keywords
    dtobj: date_conversion instance can be initialized with an existing array of datetime objects, "dtobj". If timezone naive, the timezone(s) must also be passed as "tz".
    tz: string or array of strings representing timezones of each element of dtobj.

Attributes
    dtobj: array of timezone aware datetime objects in UTC

Methods
    Input
        set_string_date(dates, tz="UTC", fmt="%Y-%m-%dT%H:%M:%S")
        set_calendar_date(dates, tz="UTC"):
        set_epoch_days(dates, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):
        set_epoch_seconds(dates, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):
        set_decimal_year(dates):
        set_julian_days(dates):

    Output
        get_string_date(tz="UTC", fmt="%Y-%m-%dT%H:%M:%S.%f %z (%Z)"):
        get_calendar_date(tz="UTC"):
        get_epoch_days(ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):
        get_epoch_seconds(ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):
        get_decimal_year():
        get_julian_days():
        get_seconds_past_midnight():
        get_days_per_year():
        get_days_per_month():
        get_day_of_the_week():
        get_seconds_per_year():

    Other Methods (dtboj array is modified)
        add_time(days=0, seconds=0, microseconds=0):
        round_time(days=0, hours=0, minutes=0, seconds=0, microseconds=0, direction='')

History
    Created Aug 2021, M. Trudeau (development version)
    Modified 28 Sep 2021, M. Trudeau: Removed default microsecond formatting on input methods.

Examples(s)
    # import existing datetime object and add timezone information (default is UTC), and convert to decimal year
    from datetime import datetime
    d = date_conversions(dtobj=(datetime(2000,1,1,0,0,0),), tz=("UTC",))
    print(d.dtobj)
    >> [datetime.datetime(2000, 1, 1, 0, 0, tzinfo=<UTC>)]
    print(d.get_decimal_year())
    >> [2000.0]

    # import string dates with time zone information using UTC−Offset (method 1)
    d.set_string_date(("2000-01-23T01:23:45.678","2000-01-23T01:23:45.678-07:00"), fmt=("%Y-%m-%dT%H:%M:%S.%f","%Y-%m-%dT%H:%M:%S.%f%z"))
    print(d.dtobj)
    >> [datetime.datetime(2000, 1, 23, 1, 23, 45, 678000, tzinfo=<UTC>), datetime.datetime(2000, 1, 23, 8, 23, 45, 678000, tzinfo=<UTC>)]

    # import string dates with time zone information (method 2)
    d.set_string_date(("2000-01-23T01:23:45.678","2000-01-23T01:23:45.678"), fmt=("%Y-%m-%dT%H:%M:%S.%f","%Y-%m-%dT%H:%M:%S.%f"), tz=("UTC","US/Mountain"))
    print(d.dtobj)
    >> [datetime.datetime(2000, 1, 23, 1, 23, 45, 678000, tzinfo=<UTC>), datetime.datetime(2000, 1, 23, 8, 23, 45, 678000, tzinfo=<UTC>)]

    # convert string dates to epoch days since a reference date (default is 1970-01-01T00:00:00)
    d.set_string_date(("1970-01-02T00:00:00","2000-02-01T00:00:00"))
    print(d.get_epoch_days(ref=("1970-01-01T00:00:00","2000-01-01T00:00:00")))
    >> [1.0, 31.0]

Notes
    datetime objects are time zone 'naive'. Time zone information and conversions are done external to the datetime module.
        http://pytz.sourceforge.net/
        http://www.enricozini.org/blog/2009/debian/using-python-datetime/
        https://aboutsimon.com/blog/2013/06/06/Datetime-hell-Time-zone-aware-to-UNIX-timestamp.html

Known Issues:
    1. Import of existing datetime objects: 1) input datetime objects(s) must be iterable, 2) tz must be passed and must be iterable otherwise dtobj attribute = [] (no warning).
    2. set_calendar_date: requires a tuple of tuples, e.g. ((2000,1,1),)
"""

from datetime import datetime, timedelta
import pytz
import numpy
import calendar
import sys

###################################################################
# functions to convert date formats to/from datetime objects in UTC
###################################################################

def string_to_datetime_object(string_date, tz="UTC", fmt="%Y-%m-%dT%H:%M:%S"):

    if "%Z" in fmt: exit("Error in fmt={}. Timezone cannot be passed in string as '%Z'.".format(fmt))

    # if "%z" in fmt: print("Message (fmt={}): Timezone passed as '%z'. Character string cannot contain a colon. 'tz' keyword will be ignored.".format(fmt))
    dtobj = datetime.strptime(string_date, fmt)

    return convert_local_to_utc(dtobj, tz)

def datetime_object_to_string_date(dtobj, tz="UTC", fmt="%Y-%m-%dT%H:%M:%S.%f %z (%Z)"):

    dtobj_local = pytz.timezone(tz).normalize(dtobj.astimezone(pytz.timezone(tz)))
    return dtobj_local.strftime(fmt) 

def calendar_date_to_datetime_object(calendar_date, tz="UTC"):

    dtobj = datetime(*calendar_date) 
    return pytz.utc.normalize(pytz.timezone(tz).localize(dtobj).astimezone(pytz.utc))

def datetime_object_to_calendar_date(dtobj, tz="UTC"):

    """ Returns a tuple of integers: (year, month, day, hour, minute, second, microsecond) """

    dtobj_local = pytz.timezone(tz).normalize(dtobj.astimezone(pytz.timezone(tz)))
    return dtobj_local.year, dtobj_local.month, dtobj_local.day, dtobj_local.hour, dtobj_local.minute, dtobj_local.second, dtobj_local.microsecond

def epoch_days_to_datetime_object(epoch_days, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

    dtobj = datetime.strptime(ref, fmt) + timedelta(days=epoch_days)
    return pytz.utc.localize(dtobj) # epoch dates are UTC by definition

def datetime_object_to_epoch_days(dtobj, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

    dtime = dtobj - pytz.utc.localize(datetime.strptime(ref, fmt))
    return dtime.days + (float(dtime.seconds) + float(dtime.microseconds) / 1.0e6) / float(86400)

def epoch_seconds_to_datetime_object(epoch_seconds, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

    return epoch_days_to_datetime_object(epoch_seconds/float(86400), ref=ref, fmt=fmt)

def datetime_object_to_epoch_seconds(dtobj, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

    return datetime_object_to_epoch_days(dtobj, ref=ref, fmt=fmt) * float(86400)

def julian_days_to_datetime_object(julian_days):

    return epoch_days_to_datetime_object(julian_days, ref="0001-01-01T00:00:00")
    
def datetime_object_to_julian_days(dtobj):

    return datetime_object_to_epoch_days(dtobj, ref="0001-01-01T00:00:00")

def decimal_year_to_datetime_object(decimal_year):

    year = int(decimal_year)
    days = (decimal_year - year) * timedelta_functions(year).days_per_year()

    dtobj =  datetime(year, 1, 1) + timedelta(days=days) # Note: timedelta works on fractional days

    return pytz.utc.localize(dtobj) # epoch dates are UTC by definition

def datetime_object_to_decimal_year(dtobj):

    yr, mo, dy, hr, mn, sc = dtobj.timetuple()[:6]
    return dtobj.year + (float(timedelta_functions(*(yr, mo, dy, hr, mn, sc, 0)).seconds_since(*(dtobj.year, 1, 1, 0, 0, 0, 0)))) / float(timedelta_functions(dtobj.year).seconds_per_year())

#################################################
# date/time functions for datetime objects in UTC
#################################################

def timezone_aware(dtobj):

    return dtobj.tzinfo is not None and dtobj.tzinfo.utcoffset(dtobj) is not None

def convert_local_to_utc(dtobj, tz):

    if not timezone_aware(dtobj): # create timezone aware datetime object
        return pytz.utc.normalize(pytz.timezone(tz).localize(dtobj).astimezone(pytz.utc))
    else:
        return pytz.utc.normalize(dtobj.astimezone(pytz.utc))

def convert_utc_to_local(dtobj, tz):

    # all dtobj passed to this function should already by tz aware
    return pytz.timezone(tz).normalize(dtobj.astimezone(pytz.timezone(tz)))

def get_timezone(dtobj, tz_abbreviation):

    """ Stand-alone function to return all timezone possibilities for a given timezone abbreviation (e.g. "CDT") """

    return [tz for tz in pytz.all_timezones if (pytz.timezone(tz).tzname(dtobj) == tz_abbreviation)]

class timedelta_functions(object):

    def __init__(self, year=1, month=1, day=1, hour=0, minute=0, second=0, microsecond=0):

        self.dtobj = datetime(*(year, month, day, hour, minute, second, microsecond))

    def seconds_since(self, year=1, month=1, day=1, hour=0, minute=0, second=0, microsecond=0):

        return (self.dtobj - datetime(*(year, month, day, hour, minute, second, microsecond))).total_seconds()

    def days_per_year(self):

        return (datetime(self.dtobj.year + 1, 1, 1, 0, 0, 0, 0) - self.dtobj).days

    def seconds_per_year(self):

        return (datetime(self.dtobj.year + 1, 1, 1, 0, 0, 0, 0) - self.dtobj).total_seconds()

def datetime_object_to_seconds_past_midnight(dtobj):

    return dtobj.hour * 3600.0 + float(dtobj.minute) * 60.0 + float(dtobj.second) + float(dtobj.microsecond) / 1.0e6

def round_time(dtobj, days=0, hours=0, minutes=0, seconds=0, microseconds=0, direction=''):

    nseconds = days * 86400 + hours * 3600 + minutes * 60 + seconds + microseconds / 1e6 

    """
    Round a datetime object to any time laps in seconds
    nseconds : Closest number of seconds to round to, default 1 minute.
    direction: 'up'/'down'
    """

    # convert to naive datetime object to work around "TypeError: can't subtract offset-naive and offset-aware datetimes"
    #     dtseconds = (dtobj - dtobj.min).seconds
    naive = dtobj.replace(tzinfo=None) 
    dtseconds = (naive - naive.min).seconds

    if direction == 'up':
        rounding = (dtseconds + nseconds) // nseconds * nseconds
    elif direction == 'down':
        rounding = dtseconds // nseconds * nseconds
    else:
        rounding = (dtseconds + nseconds / 2) // nseconds * nseconds

    return dtobj + timedelta(0, rounding-dtseconds, -dtobj.microsecond)

def date_increment(start_dtobj, end_dtobj, days=0, seconds=0, microseconds=0):

    dtobj = start_dtobj

    dtobjs = [start_dtobj,]
    while not (dtobj >= end_dtobj):
        dtobj = dtobj + timedelta(days=days, seconds=seconds, microseconds=microseconds)
        dtobjs.append(dtobj)

    return dtobjs

def to_array(inp, length=None):

    if isinstance(inp, str):
        arr = [inp,]
        if length is not None: arr = arr * length
    else:
        try:
            arr = list(inp) # fails if object is not iterable
        except:
            arr = [inp,]
            if length is not None: arr = arr * length

    return tuple(arr)

##############################################
# object(s) to work with arrays of dates/times 
##############################################

class date_conversions():

    def __init__(self, dtobj=(), tz=()):

        #super(date_conversions, self).__init__()

        # optional import of existing datetime objects
        self.dtobj = [convert_local_to_utc(d, t) for d, t in zip(dtobj, tz)] # create a timezone aware object and convert to UTC

    def set_string_date(self, dates, tz="UTC", fmt="%Y-%m-%dT%H:%M:%S"):

        d_arr = to_array(dates)
        t_arr = to_array(tz, length=len(d_arr))
        f_arr = to_array(fmt, length=len(d_arr))

        self.dtobj = [string_to_datetime_object(d, t, fmt=f) for d, t, f in zip(d_arr, t_arr, f_arr)]

    def get_string_date(self, tz="UTC", fmt="%Y-%m-%dT%H:%M:%S.%f %z (%Z)"):

        t_arr = to_array(tz, length=len(self.dtobj))
        f_arr = to_array(fmt, length=len(self.dtobj))

        return [datetime_object_to_string_date(d, tz=t, fmt=f) for d, t, f in zip(self.dtobj, t_arr, f_arr)]

    def set_calendar_date(self, dates, tz="UTC"):

        # dates must be a tuple of tuples here. if not, it must be created.

        d_arr = to_array(dates)
        t_arr = to_array(tz, length=len(d_arr))

        self.dtobj = [calendar_date_to_datetime_object(d, t) for d, t in zip(dates, t_arr)]

    def get_calendar_date(self, tz="UTC"):

        t_arr = to_array(tz, length=len(self.dtobj))

        return [datetime_object_to_calendar_date(d, t) for d, t in zip(self.dtobj, t_arr)]

    def set_epoch_days(self, dates, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

        d_arr = to_array(dates)
        r_arr = to_array(ref, length=len(d_arr))
        f_arr = to_array(fmt, length=len(d_arr))

        self.dtobj = [epoch_days_to_datetime_object(d, ref=r, fmt=f) for d, r, f in zip(d_arr, r_arr, f_arr)]

    def get_epoch_days(self, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

        r_arr = to_array(ref, length=len(self.dtobj))
        f_arr = to_array(fmt, length=len(self.dtobj))

        return [datetime_object_to_epoch_days(d, ref=r, fmt=f) for d, r, f in zip(self.dtobj, r_arr, f_arr)]

    def set_epoch_seconds(self, dates, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

        d_arr = to_array(dates)
        r_arr = to_array(ref, length=len(d_arr))
        f_arr = to_array(fmt, length=len(d_arr))

        self.dtobj = [epoch_seconds_to_datetime_object(d, ref=r, fmt=f) for d, r, f in zip(d_arr, r_arr, f_arr)]

    def get_epoch_seconds(self, ref="1970-01-01T00:00:00", fmt="%Y-%m-%dT%H:%M:%S"):

        r_arr = to_array(ref, length=len(self.dtobj))
        f_arr = to_array(fmt, length=len(self.dtobj))

        return [datetime_object_to_epoch_seconds(d, ref=r, fmt=f) for d, r, f in zip(self.dtobj, r_arr, f_arr)]

    def set_decimal_year(self, dates):

        d_arr = to_array(dates)

        self.dtobj = [decimal_year_to_datetime_object(d) for d in d_arr]

    def get_decimal_year(self):

        return [datetime_object_to_decimal_year(d) for d in self.dtobj]

    def set_julian_days(self, dates):

        d_arr = to_array(dates)

        self.dtobj = [julian_days_to_datetime_object(d) for d in d_arr]

    def get_julian_days(self):

        return [datetime_object_to_julian_days(d) for d in self.dtobj]

    def add_time(self, days=0, seconds=0, microseconds=0):

        self.dtobj = [d + timedelta(days=dy, seconds=sc, microseconds=ms) for d, dy, sc, ms in zip(self.dtobj, to_array(days, length=len(self.dtobj)), to_array(seconds, length=len(self.dtobj)), to_array(microseconds, length=len(self.dtobj)))]

    def get_seconds_past_midnight(self):

        return [datetime_object_to_seconds_past_midnight(d) for d in self.dtobj]

    def get_days_per_year(self):

        return [timedelta_functions(d.year).days_per_year() for d in self.dtobj]

    def get_days_per_month(self):

        return [calendar.monthrange(d.year, d.month)[1] for d in self.dtobj]

    def get_day_of_the_week(self):

        return [(d.weekday(), calendar.day_name[d.weekday()]) for d in self.dtobj]

    def get_seconds_per_year(self):

        return [timedelta_functions(d.year).seconds_per_year() for d in self.dtobj]

    def round_time(self, **kwargs):

        self.dtobj = [round_time(d, **kwargs) for d in self.dtobj]

if __name__ == "__main__":
   
    # command line call: ./ccg_date_utils.py --debug 
    if ("--debug" in sys.argv):

        dates = ("Fri Oct 30 08:03:12 2020", "2020-09-01", "1970-01-02 00:00:00", "2006-04-01", "2020-10-30T08:03:12.000000 -0500") # "2020-10-30T08:03:12.000000 -0500 (CDT)"
        tz = ("US/Central","US/Mountain", "UTC", "UTC", "Europe/Madrid")
        fmt = ("%a %b %d %H:%M:%S %Y", "%Y-%m-%d", "%Y-%m-%d %H:%M:%S", "%Y-%m-%d", "%Y-%m-%dT%H:%M:%S.%f %z") # "%Y-%m-%dT%H:%M:%S.%f %z (%Z)"

        print("Dates/timezones:", dates, tz)

        dc = date_conversions() # create instance
        dc.set_string_date(dates, tz, fmt)
        print("Decimal year:", dc.get_decimal_year())

        ref="1970-01-01T00:00:00"
        fmt="%Y-%m-%dT%H:%M:%S"
        print("Epoch days since {}:".format(ref), dc.get_epoch_days(ref=ref, fmt=fmt))
       
        #import matplotlib.dates
        #matplotlib.dates.set_epoch(ref)
        #print("Epoch days since {} (matplotlib.dates.date2num):".format(ref), [matplotlib.dates.date2num(d) for d in dc.dtobj]) # matplotlib.dates does not include milliseconds

        import matplotlib.dates
        ref="0001-01-01T00:00:00"
        matplotlib.dates.set_epoch(ref)
        print("Julian days:", dc.get_julian_days())
        print("Julian days since {} (matplotlib.dates.date2num):".format(ref), [matplotlib.dates.date2num(d) for d in dc.dtobj]) # 2006-04-01 = 732401 (https://matplotlib.org/stable/api/dates_api.html#matplotlib.dates.set_epoch) 
        print("Calendar date (matplotlib.dates.num2date):", [matplotlib.dates.num2date(d) for d in dc.get_julian_days()])

        print("string date:", dc.get_string_date(tz=tz))
        ndays = 90
        dc.add_time(days=ndays)
        print("Add {} days:".format(ndays), dc.get_calendar_date(tz=tz))
        print("Add {} days:".format(ndays), dc.get_string_date(tz=tz))

    else:

        with open(sys.argv[1]) as f:
            dat = f.readlines()

        dates = [e.strip().split(",")[0] for e in dat if e[0] != '#']
        fmt = [e.strip().split(",")[1] for e in dat if e[0] != '#']

        """
        for d, f in zip(dates, fmt):
            print(d, f)
        """

        dc = date_conversions() # create instance
        dc.set_string_date(dates, fmt=fmt)

        for d, f in zip(dates, dc.get_decimal_year()):
            print("{:.30f}".format(f))

