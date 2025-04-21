
"""
Description
===========

The Dataset class is used to contain the data points and drawing style
of a 'set' of data.  It also keeps track of which axis on the graph that
the data is to be mapped to.

A data point consists of an x value, a y value, and a weight value.
The weight value is used to distinguish between different drawing styles.
For example, a data set of

	[1, 2, 0
	 2, 3, 0
	 3, 4, 1]

will have the first two points drawn in the first style, the third point 
drawn in the second style.

The x and y values are stored as numpy arrays for faster processing.

Values passed in when creating a dataset can be either datetime objects or floats.
If datatime objects, they are converted to a float value using date2num(),
and the datatype value is set to DATE.

The Dataset class also has a popup dialog that can be used to dynamically 
change the style attributes of the dataset.
"""

#import wx
import datetime

import numpy


HOURS_PER_DAY = 24.
MINUTES_PER_DAY  = 60.*HOURS_PER_DAY
SECONDS_PER_DAY =  60.*MINUTES_PER_DAY
MUSECONDS_PER_DAY = 1e6*SECONDS_PER_DAY

DATE = 1
FLOAT = 0

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

	base =  float(dt.toordinal())
	if hasattr(dt, 'hour'):
		base += (dt.hour/HOURS_PER_DAY + dt.minute/MINUTES_PER_DAY +
                 dt.second/SECONDS_PER_DAY + dt.microsecond/MUSECONDS_PER_DAY
                 )
	return base

#####################################################################
def _from_ordinalf(x, tz=None):
	"""
	Convert Gregorian float of the date, preserving hours, minutes,
	seconds and microseconds.  Return value is a :class:`datetime`.
	"""

#    if tz is None: tz = _get_rc_timezone()
	ix = int(x)
	dt = datetime.datetime.fromordinal(ix)
	remainder = float(x) - ix
	hour, remainder = divmod(24*remainder, 1)
	minute, remainder = divmod(60*remainder, 1)
	second, remainder = divmod(60*remainder, 1)
	microsecond = int(1e6*remainder)
	if microsecond<10: microsecond=0 # compensate for rounding errors
	dt = datetime.datetime(dt.year, dt.month, dt.day, int(hour), int(minute), int(second), microsecond)

	if microsecond>999990:  # compensate for rounding errors
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

	try:
		return [_from_ordinalf(val) for val in x]
	except TypeError:
		return _from_ordinalf(x)

