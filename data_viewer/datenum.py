# vim: tabstop=4 shiftwidth=4 expandtab
"""
`datetime` objects are
converted to floating point numbers which represent the number of days
since 0001-01-01 UTC.  The helper functions `date2num`,
and `num2date` are used to facilitate easy
conversion to and from `datetime` and numeric ranges.

Borrowed code from Matplotlib dates.py file.
"""

import datetime

HOURS_PER_DAY = 24.
MINUTES_PER_DAY = 60. * HOURS_PER_DAY
SECONDS_PER_DAY = 60. * MINUTES_PER_DAY
MUSECONDS_PER_DAY = 1e6 * SECONDS_PER_DAY


# _to_ordinalf, _from_ordinalf, date2num, num2date taken from  matplotlib
#####################################################################
def _to_ordinalf(dt):
    """
    Convert :mod:`datetime` to the Gregorian date as UTC float days,
    preserving hours, minutes, seconds and microseconds.  Return value
    is a :func:`float`.
    """

    if hasattr(dt, 'tzinfo') and dt.tzinfo is not None:
        delta = dt.tzinfo.utcoffset(dt)
        if delta is not None:
            dt -= delta

    base = float(dt.toordinal())
    if hasattr(dt, 'hour'):
        base += (dt.hour/HOURS_PER_DAY + dt.minute/MINUTES_PER_DAY +
                 dt.second/SECONDS_PER_DAY + dt.microsecond/MUSECONDS_PER_DAY)
    return base


#####################################################################
def _from_ordinalf(x):
    """
    Convert Gregorian float of the date, preserving hours, minutes,
    seconds and microseconds.  Return value is a :class:`datetime`.
    """

    ix = int(x)
    dt = datetime.datetime.fromordinal(ix)
    remainder = float(x) - ix
    hour, remainder = divmod(24*remainder, 1)
    minute, remainder = divmod(60*remainder, 1)
    second, remainder = divmod(60*remainder, 1)
    microsecond = int(1e6*remainder)
    if microsecond < 10:
        microsecond = 0  # compensate for rounding errors
    dt = datetime.datetime(dt.year, dt.month, dt.day, int(hour), int(minute), int(second), microsecond)

    if microsecond > 999990:  # compensate for rounding errors
        dt += datetime.timedelta(microseconds=1e6-microsecond)

    return dt


#####################################################################
def date2num(d):
    """ Convert list or single value d to float, the number of
    days since 01-01-0000
    """

    try:
        return [_to_ordinalf(x) for x in d]
    except TypeError:
        return _to_ordinalf(d)


#####################################################################
def num2date(x):
    """ convert a list or single float value of the number of days since
    01-01-0000 to a datetime object """

    try:
        return [_from_ordinalf(val) for val in x]
    except TypeError:
        return _from_ordinalf(x)
