"""
class for holding options for export data from ccg_filter()
and outputting the exported data to the proper location.
"""
from __future__ import print_function

import sys
import datetime

#from dateutil.rrule import *
from dateutil.rrule import rrule, DAILY

from ccg_dates import calendarDate, decimalDateFromDatetime

#########################################################################
class ccgFilterExportData:
	""" A class to hold all the options for exporting results. """

	def __init__(self):

		# Set any of these to what you desire, then call run()
		self.all = False	# not implemented yet
		self.unique = False	# not implemented yet
		self.cal_format = False
		self.use_hour = False
		self.user = False
		self.userfile = None
		self.outfile1 = None
		self.outfile2 = None
		self.orig = False
		self.func = False
		self.poly = False
		self.smooth = False
		self.trend = False
		self.detrend = False
		self.smcycle = False
		self.harm = False
		self.res = False
		self.smres = False
		self.trres = False
		self.ressm = False
		self.gr = False
		self.stats = False
		self.format = ""
		self.startdate = None
		self.equal = False
		self.sample = False
		self.amp = False
		self.coef = False
		self.mm = False
		self.begcoef = 0
		self.endcoef = 0
		self.include_hour = False
		self.include_header = False
		self.firstdate = None
		self.lastdate = None

	#-----------------------------------------------------------------------------------------
	def run(self, ccgfilt):
		""" all the settings are finished, now do the actual export of data """

		# if self user dates or equal spaced dates aren't specified, use sample dates as default
		if not self.user and not self.equal: self.sample = True

		# If self starting date is not specified, set it to the date of the first data point
		(syear, smonth, sday, hour, minute, second) = calendarDate(ccgfilt.xp[0])
		self.firstdate = datetime.datetime(syear, smonth, sday)
		(syear, smonth, sday, hour, minute, second) = calendarDate(ccgfilt.xp[-1])
		self.lastdate = datetime.datetime(syear, smonth, sday)
		if not self.startdate:
			self.startdate = self.firstdate

		curves = self.check_export()

		if curves:
			self.export_data(ccgfilt)

		if self.amp:
			months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
			amps = ccgfilt.getAmplitudes()

			print(" *****  Seasonal Cycle Statistics.  *****")
			print(" Year      Amplitude     Maximum   Date     Minimum   Date")
			print("-----------------------------------------------------------")

			for (year, amp, maxdate, maxval, mindate, minval) in amps:

				(yr, mnmax, dmax, hr, mn, sec) = calendarDate(maxdate)
				(yr, mnmin, dmin, hr, mn, sec) = calendarDate(mindate)

				print("%5.0f %12.2f %12.2f   %3s %2d %9.2f   %3s %2d" % (year, amp, maxval, months[mnmax], dmax, minval, months[mnmin], dmin))

		if self.stats:
			print(ccgfilt.stats())

		if self.mm:
			mm = ccgfilt.getMonthlyMeans()
			for (year, month, val, std, n) in mm:
				print("%4d %02d %7.2f %5.2f %2d" % (year, month, val, std, n))

		if self.coef:
			if self.endcoef > ccgfilt.numpm:
				e = ccgfilt.numpm
			else:
				e = self.endcoef

			for i in range(self.begcoef, e):
				print("%.6f" % ccgfilt.params[i], end=' ')
			print()


	#------------------------------------------------------------------------
	def check_export(self):
		""" Check that at least one of the output options is set """

		if self.all \
			or self.unique \
			or self.orig \
			or self.func \
			or self.poly \
			or self.smooth \
			or self.trend \
			or self.detrend \
			or self.smcycle \
			or self.harm \
			or self.res \
			or self.smres \
			or self.trres \
			or self.ressm \
			or self.gr:
			return 1

		return 0


	#------------------------------------------------------------------------
	def export_data(self, filt):
		""" export the data from the filter 'filt' """

		if self.sample:
			if self.outfile1:
				try:
					fp = open(self.outfile1, "w")
				except:
					sys.exit("Can't open file %s for writing." % self.outfile1)

			else:
				fp = sys.stdout

			self.export_dates(fp, filt, filt.xp)

		if self.equal or self.user:
			if self.outfile2:
				try:
					fp = open(self.outfile2, "w")
				except:
					sys.exit("Can't open file %s for writing." % self.outfile2)

			else:
				fp = sys.stdout

			if self.equal:
				# if startdate is not equal to first date of xinterp, need to
				# create a new list of dates to give to export_dates()
				if self.startdate != self.firstdate:
					# get list of dates at sample interval
					xdates = []
					dates = rrule(DAILY, interval=filt.sampleinterval, dtstart=self.startdate, until=self.lastdate)
					for dt in dates:
						xd = decimalDateFromDatetime(dt)
						xdates.append(xd)
					self.export_dates(fp, filt, xdates)
				else:
					self.export_dates(fp, filt, filt.xinterp)
			else:
				user_x = []
				f = open(self.userfile)
				for line in f:
					a = line.split()
					xp = float(a[0])
					user_x.append(xp)
				f.close()

				self.export_dates(fp, filt, user_x)


	#----------------------------------------------------------------------
	def export_dates(self, fp, filt, x):
		""" Export (print) data to file pointer fp at dates given by x.
		The values to print are given as boolean flags in the export class.
		Some values can only be printed at sample dates, i.e. original data and residuals
		"""

		if self.include_header:
			self.export_header(fp)

		_format = "%13.6e"

		h = filt.getHarmonicValue(x)	# harmonics
		p = filt.getPolyValue(x)	# poly
		s = filt.getSmoothValue(x)	# function + short term smoothing
		t = filt.getTrendValue(x)	# poly + long term smoothing
		g = filt.getGrowthRateValue(x)	# growth rate, derivative of trend
		f = filt.getFunctionValue(x)    # function
	#	f = h + p			# function, poly + harmonics

		for i in range(len(x)):
			if self.cal_format:
				(yr, mon, dy, hr, mn, sec) = calendarDate(x[i])
				if self.include_hour:
					print("%4d %02d %02d %2d" % (yr, mon, dy, hr), end=' ', file=fp)
				else:
					print("%4d %02d %02d" % (yr, mon, dy), end=' ', file=fp)
			else:
				print("%13.8f" % x[i], end=' ', file=fp)

			if self.sample and self.orig:    print(_format % filt.yp[i], end=' ', file=fp)
			if self.func:                    print(_format % f[i], end=' ', file=fp)
			if self.poly:                    print(_format % p[i], end=' ', file=fp)
			if self.smooth:                  print(_format % s[i], end=' ', file=fp)
			if self.trend:                   print(_format % (t[i]), end=' ', file=fp)
			if self.sample and self.detrend: print(_format % (filt.yp[i] - t[i]), end=' ', file=fp)
	#		if self.smcycle:                 print >> fp, _format % (h[i] + s[i] - t[i]),
			if self.smcycle:                 print(_format % (s[i] - t[i]), end=' ', file=fp)
			if self.harm:                    print(_format % (h[i]), end=' ', file=fp)
			if self.sample and self.res:     print(_format % (filt.yp[i] - f[i]), end=' ', file=fp)
			if self.smres:                   print(_format % (s[i] - f[i]), end=' ', file=fp)
			if self.trres:                   print(_format % (t[i] - f[i]), end=' ', file=fp)
			if self.sample and self.ressm:   print(_format % (filt.yp[i] - s[i]), end=' ', file=fp)
			if self.gr:                      print(_format % (g[i]), end=' ', file=fp)


			print(file=fp)

	#----------------------------------------------------------------------
	def export_header(self, fp):
		""" Export a line with column header names to file pointer fp.
		"""

		_format = "%-13s"

		print(_format % "date", end=' ', file=fp)
		if self.sample and self.orig:    print(_format % "value", end=' ', file=fp)
		if self.func:                    print(_format % "function", end=' ', file=fp)
		if self.poly:                    print(_format % "polynomial", end=' ', file=fp)
		if self.smooth:                  print(_format % "smooth", end=' ', file=fp)
		if self.trend:                   print(_format % "trend", end=' ', file=fp)
		if self.sample and self.detrend: print(_format % "detrended", end=' ', file=fp)
		if self.smcycle:                 print(_format % "smooth_cycle", end=' ', file=fp)
		if self.harm:                    print(_format % "harmonics", end=' ', file=fp)
		if self.sample and self.res:     print(_format % "residuals", end=' ', file=fp)
		if self.smres:                   print(_format % "smooth_resid", end=' ', file=fp)
		if self.trres:                   print(_format % "trend_resid", end=' ', file=fp)
		if self.sample and self.ressm:   print(_format % "resid_smooth", end=' ', file=fp)
		if self.gr:                      print(_format % "growth_rate", end=' ', file=fp)

		print(file=fp)
