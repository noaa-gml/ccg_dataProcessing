import sys
import wx
import datetime
import calendar

sys.path.append("/ccg/src/python/lib")

import dbutils

from graph3.graph import *
from graph3.style import *

ONEDAY = datetime.timedelta(days=1)

######################################################################
class dataWindow(wx.Panel):
    def __init__(self, parent, statusbar, defaultchoice=0):
        wx.Panel.__init__(self, parent, -1)

	self.parent = parent
	self.statusbar = statusbar

	sizer1 = wx.BoxSizer(wx.VERTICAL)
	self.SetSizer(sizer1)

	box2 = wx.BoxSizer(wx.HORIZONTAL)
	sizer1.Add(box2, 0, wx.EXPAND|wx.ALL, 3)

	label = wx.StaticText(self, -1, "Parameter: ")
	box2.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 5)

	choices = ["P (hour)", "WI (hour)", "U (hour)", "T (hour)", "T1 (hour)", "T2 (hour)", "WS (hour)", "WD (hour)", "WDg (hour)", 
		"P (minute)", "WI (minute)", "U (minute)", "T (minute)", "T1 (minute)", "T2 (minute)", "WS (minute)", "WD (minute)", "WDg (minute)"]
	self.choice = wx.Choice(self, -1, choices=choices, size=(250,-1))
	box2.Add(self.choice, 0, wx.ALIGN_LEFT, 0)
	self.Bind(wx.EVT_CHOICE, self.updateParams, self.choice)
	self.choice.SetSelection(defaultchoice)

	self.plot = Graph(self)
	self.plot.legend.showLegend = 1
	self.plot.showGrid(True)
	self.plot.axes[0].labelDateUseYear = 0
	self.plot.SetLocation(80,-180, 40, -50)
	sizer1.Add(self.plot, 1, wx.EXPAND, 5)

    #----------------------------------------------
    def setOptions(self, code, year, month, daysinmonth, startday, endday, default=0):

	self.code = code
	self.year = year
	self.month = month
	self.startday = startday
	self.endday = endday
	self.daysinmonth = daysinmonth

	self.month_name = calendar.month_name[self.month]
#	self.getChoices(default)

    #----------------------------------------------
    # Update the plot
    def updateParams(self, event=None):
	""" choice has changed """

	param = self.choice.GetStringSelection()
	self.getSignals(param)
	self._set_plot_range()

    #----------------------------------------------
    # Update the plot
    def update(self):
	""" update plot.  Presumably start and end day options has changes """

	self._set_plot_range()
#	self.updateParams()


    #----------------------------------------------
    # Update a plot based on new parameters.
    def getSignals(self, param):

	self.statusbar.SetStatusText("Getting %s ..." % param)

	db,c = dbutils.dbConnect("met")

	plot = self.plot
	self.plot.clear()

	plot.Unbind(wx.EVT_MIDDLE_DOWN)

	(field, a) = param.split()
	# get default value for field
	if "hour" in param:
		table = "%s_hour" % self.code.lower()
	else:
		table = "%s_minute" % self.code.lower()
	sql = "describe %s %s" % (table, field)
	c.execute(sql)
	result = c.fetchone()
	default = int(float(result[4]))

	if "hour" in param:
		startdate = "%s" % (self.startday.date())
		enddate = "%s" % (self.endday.date())
		startdate = "%s-%s-1" % (self.year, self.month)
		enddate = "%s-%s-%s" % (self.year, self.month, self.daysinmonth)

		sql = "select date,hour,%s from %s where date>='%s' and date<='%s' and %s>%s order by date, hour" % (field, table, startdate, enddate, field, default)
		print sql

		x = []
		y = []
		c.execute(sql)
		result = c.fetchall()
		for date, hour, val in result:
			x.append(datetime.datetime(date.year, date.month, date.day, hour))
			y.append(float(val))

		plot.createDataset(x, y, param)


	if "minute" in param:
		startdate = "%s" % (self.startday.date())
		enddate = "%s" % (self.endday.date())
		startdate = "%s-%s-1" % (self.year, self.month)
		enddate = "%s-%s-%s" % (self.year, self.month, self.daysinmonth)

		sql = "select date,time,%s from %s where date>='%s' and date<='%s' and %s>%s order by date, time" % (field, table, startdate, enddate, field, default)
		print sql

		x = []
		y = []
		c.execute(sql)
		result = c.fetchall()
		for date, time, val in result:
			dt = datetime.datetime(date.year, date.month, date.day)
			x.append(dt + time)
			y.append(float(val))

		plot.createDataset(x, y, param, symbol='None')

	self.statusbar.SetStatusText("")

	return

    #----------------------------------------------------------------------------------------------
    def _set_plot_range(self):

	axis = self.plot.getXAxis(0)

	if self.startday == self.endday:
#			# labels every 6 hours, tic marks every 1 hours
#			axis.setAxisDateRange(self.startday, self.endday+ONEDAY, 6, HOURLY, 1, HOURLY)
		axis.setAxisDateRange(self.startday, self.endday+ONEDAY)
#			axis.setLabelFormat("%d %H:00")
	else:
		# labels, every day, tic marks every 6 hours
		axis.setAxisDateRange(self.startday, self.endday+ONEDAY, 1, DAILY, 6, HOURLY)
#			axis.setLabelFormat("%d")

	axis = self.plot.getYAxis(0)
	axis.setAutoscale()

	s = "%s %s %s" % (self.code.upper(), self.month_name, self.year)
	self.plot.title.text = s

	self.plot.update()

	return

