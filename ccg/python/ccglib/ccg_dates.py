# vim: tabstop=4 shiftwidth=4 expandtab
""" Some utility functions for converting dates to different formats """

import datetime
import calendar
import numpy
from dateutil.parser import parse

###########################################################
def datesOk(year, month, day, hour=0, minute=0, second=0):
    """ Check if values are appropriate for a real date

    Returns:
        True if date is Ok, False if not.
    """

    if month < 1 or month > 12:
        raise ValueError("Month is out of range: %s" % month)

    if day < 1 or day > 31:
        raise ValueError("Day is out of range: %s" % day)

    if hour < 0 or hour > 23:
        raise ValueError("Hour is out of range: %s" % hour)

    if minute < 0 or minute > 59:
        raise ValueError("Minute is out of range: %s" % minute)

    if second < 0 or second > 59:
        raise ValueError("Second is out of range: %s" % second)

    return True

###########################################################
def decimalDate(year, month, day, hour=0, minute=0, second=0):
    """ Convert a date and time to a fractional year.

    Returns:
        dd (float) - The decimal date
    """

    if not datesOk(year, month, day, hour, minute, second):
        return 0

    soy = secondOfYear(year, month, day, hour, minute, second)

#    if year % 4 == 0 and year % 100 != 0 or year % 400 == 0:
    if calendar.isleap(year):
        dd = year + soy/3.16224e7
    else:
        dd = year + soy/3.1536e7

    return dd

###################################################
def secondOfYear(year, month, day, hour, minute, second):
    """ Determine second of the year from calendar components

    Returns:
        soy (int) - second of the year
    """

    if not datesOk(year, month, day, hour, minute, second):
        return 0

    doy = dayOfYear(year, month, day)
    soy = (doy-1)*86400 + hour*3600 + minute*60 + second

    return soy

###################################################
def dayOfYear(year, month, day):
    """ Convert year, month day to day of year

    Returns:
        doy (int) - day of year
    """

    if not datesOk(year, month, day):
        return 0

    mona = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

    x = mona[month-1] + day
#    if ((year % 4 == 0 and year % 100 != 0) or year % 400 == 0) and month > 2:
    if calendar.isleap(year) and month > 2:
        x = x + 1

    return x

###################################################
def intDate(year, month, day, hour=0):
    """ Make an integer value that contains the date and hour

    Returns:
        intd (int) - integer representation of the date yyyymmddhh
    """

    if not datesOk(year, month, day, hour):
        return 0

    intd = year*1000000 + month*10000 + day*100 + hour

    return intd

###################################################
def getDate(intdate):
    """ Opposite of intDate, get date and hour from integer value

    Returns:
        year, month, day, hour
    """

    s = str(intdate)

    if len(s) != 10:
        raise ValueError("Invalid date")

    year = int(s[0:4])
    month = int(s[4:6])
    day = int(s[6:8])
    hour = int(s[8:])

    return year, month, day, hour

###################################################
# Don't use these routines for resolution less than 1 second.
def calendarDate(decyear):
    """ Convert a decimal date to calendar components,
    year, month, day, hour, minute seconds

    Returns:
        year, month, day, hour, minute, second
    """

    dyr = int(decyear)
    fyr = decyear - dyr

    if calendar.isleap(dyr):
        nsec = fyr * (366*86400)
    else:
        nsec = fyr * (365*86400)

    nsec = round(nsec, 0)

    ndays = int(nsec / 86400)
    doy = ndays + 1

    if doy > 366:
        dyr = dyr + 1
        doy = 1
    month, day = to_mmdd(dyr, doy)


    nsecs = round(nsec - (ndays*86400), 0)
    hour = int(nsecs / 3600)
    minute = int((nsecs - (hour *3600)) / 60)
    seconds = int(round(nsecs - (hour * 3600.0) - (minute * 60.0), 0))

    return dyr, month, day, hour, minute, seconds


###################################################
def to_mmdd(year, doy):
    """ convert year, day of year to month, day

    Returns:
        month, day
    """

    if doy < 1 or doy > 366:
        raise ValueError("Day of year is out of range")

#    if year % 4 == 0:
    if calendar.isleap(year):
        mona = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
    else:
        mona = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

    idoy = doy
    imon = 0
    while idoy - mona[imon] > 0:
        idoy = idoy - mona[imon]
        imon += 1

    month = imon + 1
    return int(month), int(idoy)

###################################################
def toMonthDay(year, doy):
    """ Convert day of year to month and day

    Returns:
        month, day
    """

    if doy < 1 or doy > 366:
        raise ValueError("Day of year is out of range")

    month, day = to_mmdd(year, doy)

    return month, day

###################################################
def getDatetime(datestr, sep=""):
    """ create a datetime from a date string
    The string can be of the form 'yyy mm dd hh mm ss',
    or a string that is parseable by dateutil.parser.parse

    Returns:
        date - A datetime.datetime object
    """

    # if its already a datetime, return it
    if isinstance(datestr, datetime.datetime):
        return datestr

    # convert datetime.date to datetime.datetime
    if isinstance(datestr, datetime.date):
        return datetime.datetime(datestr.year, datestr.month, datestr.day)

    if isinstance(datestr, float):
        return datetimeFromDecimalDate(datestr)

    # we have a string
    # dateutil parse can't handle strings with fields separated by white space
    if " " in datestr:
        a = datestr.split()

        # assume string is 'yyyy mm dd hh mm ss'
        if len(a) >= 3:
            year = int(a[0])
            month = int(a[1])
            day = int(a[2])
            if len(a) > 3:
                hour = int(a[3])
                minute = int(a[4])
                if len(a) == 6:
                    second = int(a[5])
                else:
                    second = 0
            else:
                hour = 0
                minute = 0
                second = 0

        try:
            ok = datesOk(year, month, day, hour, minute)
        except ValueError as msg:
            raise ValueError("Cannot create datetime from string: %s %s" % (datestr, msg))

        date = datetime.datetime(year, month, day, hour, minute, second)

    else:

        # if parse can't convert it to datetime, let it raise an error.
        date = parse(datestr)

    return date


###################################################
def getTime(timestr, sep=""):
    """ Parse a string into hours, minutes, seconds.
    e.g. 12:45:38 -> hours = 12, minutes = 45, seconds = 38

    Returns:
        time - datetime.time object
        
    """

    separators = ["", ":"]
    if sep:
        separators = separators + sep


    for separator in separators:
        if separator == "":
            a = timestr.split()
        else:
            a = timestr.split(separator)

        if len(a) >= 3:

            hour = int(a[0])
            minute = int(a[1])
            second = int(float(a[2]))

            time = datetime.time(hour, minute, second)
            return time

    raise ValueError("Cannot create time from string: %s" % timestr)


###################################################
def decimalDateFromDatetime(dt):
    """ Convert a datetime to float decimal date

    Returns:
        dd (float) - decimal date
    """

    # Can't use isinstance(dt, datetime.date) because it is true for both datetime.date and datetime.datetime
    if type(dt) is datetime.date:
        dd = decimalDate(dt.year, dt.month, dt.day, 0, 0, 0)
    else:
        dd = decimalDate(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)

    return dd

###################################################
def datetimeFromDateAndTime(d, t):
    """ Combine separate date and times to a single datetime

    Returns:
        dt - A datetime.datetime object
    """

    s = "%s" % t
    (hr, mn, sc) = s.split(":")

    dt = datetime.datetime(d.year, d.month, d.day, int(hr), int(mn), int(sc))

    return dt

###################################################
def datetimeFromDecimalDate(dd):
    """ Convert a float decimal date to datetime

    Returns:
        dt - A datetime.datetime object
    """

    yr, mon, dy, hr, mn, sc = calendarDate(dd)
    dt = datetime.datetime(yr, mon, dy, hr, mn, sc)

    return dt


###################################################
def dateFromDecimalDate(dd):
    """ Convert a float decimal date to date

    Returns:
        dt - A datetime.date object
    """

    yr, mon, dy, hr, mn, sc = calendarDate(dd)
    dt = datetime.date(yr, mon, dy)

    

    return dt

###################################################
def dec2date(dd):
    """ convert an array of decimal dates to
    an array of calendar components
    """

    a = numpy.empty((dd.size, 6))
    # dd is a numpy array of decimal dates
    for i in range(dd.size):
        yr, mon, dy, hr, mn, sc = calendarDate(dd[i])
        a[i] = (yr, mon, dy, hr, mn, sc)

    return a
