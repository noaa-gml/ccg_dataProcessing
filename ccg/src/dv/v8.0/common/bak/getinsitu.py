
"""
Dialog class for choosing data set to graph.
Dialog contains several sections:
	station list
	parameter
	time span
	options

Used by grapher module
Create with

	from common import get

	dlg = get.GetInsituDataDialog(self)

	where self is the parent of the dialog.

Then get data arrays with

	x,y,name = dlg.ProcessData()
"""

import wx
import datetime
import numpy

from common import extchoice
from common.utils import *



#####################################################################
class GetInsituData:

        def __init__(self):
		self.sitenum = 75
		self.stacode = "MLO"
		self.parameter = 1
		self.paramname = "co2"
		self.byear = 0
		self.eyear = 0
		self.use_soft_flags = False
		self.use_hard_flags = False


##########################################################################
class GetInsituDataDialog(wx.Dialog):
	def __init__(self, parent=None, title="Choose Dataset", graph=None):
		wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

		self.data = GetInsituData()

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		sizer = self.mkStation()
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkParams()
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkTimeSpan()
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkOptions()
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)
		self.options_sizer = sizer

		line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
		box0.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)

		btnsizer = wx.StdDialogButtonSizer()

		btn = wx.Button(self, wx.ID_CANCEL)
		btnsizer.AddButton(btn)
		btn = wx.Button(self, wx.ID_OK)
		btn.SetDefault()
		self.Bind(wx.EVT_BUTTON, self.ok, btn)

		btnsizer.AddButton(btn)
		btnsizer.Realize()

		box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

		self.SetSizer(box0)
		box0.SetSizeHints(self)


	#----------------------------------
	def mkStation(self):

                box = wx.StaticBox(self, -1, "Sampling Site")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

                self.listbox = extchoice.ExtendedChoice(self, -1, size=(555,-1))

		sql = "show tables like '%insitu'"
		myDb = dbConnect()
		dbQuery(myDb, sql)
		list = dbFetch(myDb)

		self.params = {}
		value = ""
                stations = []
		for row in list:
			(code, param, s) = row[0].split("_")

			if code not in self.params:
				self.params[code] = []

			if param not in self.params[code]:
				self.params[code].append(param)

			name = getStationName(code)

                        txt = "%s - %s" % (code.upper(), name)
			if txt not in stations:
				stations.append(txt)
			if code.upper() == self.data.stacode:
				value = txt

		if value == "": value = stations[0]

                self.listbox.ReplaceAll(stations)
		self.listbox.SetValue(value)

		szr.Add(self.listbox, 0, wx.ALIGN_LEFT|wx.ALL, 5)
                self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)

		return szr

	#----------------------------------
	def stationSelected(self, event):
		""" station selection has changed.
		    update parameters, time span and options
		    with values relavent to selected station.
		"""

		# get the newly selected station code
		self.data.stacode = self.getStationCode()
		# update the parameters, time and options sections
		self.param_config()
		self.date_config()
		self.option_config()

	#----------------------------------
	def mkParams(self):

                box = wx.StaticBox(self, -1, "Parameters")
                box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

		text = "Select a measurement parameter."
		self.label = wx.StaticText(self, -1, text)
		box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

		self.parambox = wx.ListBox(self, -1, style=wx.LB_SINGLE, size=(500,150))
		box1.Add(self.parambox, 1, wx.ALIGN_RIGHT|wx.ALL, 5)
                self.parambox.Bind(wx.EVT_LISTBOX, self.paramSelected)

		self.param_config()

		return box1

	#----------------------------------
	def param_config(self):

		code = self.data.stacode
#		list = getParameterList(code, [3,4], [1,2])
		params = self.params[code.lower()]

		self.parambox.Clear()
		for formula in params:
			name = getGasNameFromFormula(formula)
                        s = "%s - %s" % (formula, name)
			self.parambox.Append(s)

		self.parambox.SetSelection(0)
		self.data.paramname = params[0]
		self.data.parameter = getGasNum(self.data.paramname)
		
		return

	#----------------------------------
	def paramSelected(self, event):
		s = self.parambox.GetStringSelection()
		if s:
			(formula,name) = s.split('-', 1)
			formula = formula.strip()
			paramnum = getGasNum(formula)
			self.data.parameter = paramnum
			self.data.paramname = formula

			self.date_config()
			self.option_config()

	#----------------------------------
	def getStationCode(self):
		s = self.listbox.GetValue()
		code, name = s.split('-', 1)
		code = code.strip()

		return code

	#----------------------------------
	def mkTimeSpan(self):

		monthlist = [
			"January" ,
			"February",
			"March",
			"April",
			"May",
			"June",
			"July",
			"August",
			"September",
			"October",
			"November",
			"December"
		]

	        now=datetime.datetime.now()
		this_year = int(now.strftime("%Y"))
		this_month = now.strftime("%B")
		self.data.month1 = now.month
		self.data.month2 = now.month
		self.data.byear = this_year
		self.data.eyear = this_year
		print this_month

                box = wx.StaticBox(self, -1, "Time Span")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

		box1 = wx.FlexGridSizer(0,3,2,2)
		szr.Add(box1)

		label = wx.StaticText(self, -1, "Start")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.month1 = wx.Choice(self, -1, choices=monthlist)
		self.month1.SetSelection(monthlist.index(this_month))
		box1.Add(self.month1, 0, wx.ALIGN_CENTRE|wx.ALL, 0)

                self.byear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
                box1.Add(self.byear, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "End")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.month2 = wx.Choice(self, -1, choices=monthlist)
		box1.Add(self.month2, 0, wx.ALIGN_CENTRE|wx.ALL, 0)
		self.month2.SetSelection(monthlist.index(this_month))

                self.eyear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
                box1.Add(self.eyear, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		return szr

	#----------------------------------
	def getDates(self, code, param):

		table = "%s_%s_insitu" % (code.lower(), param.lower())
		query = "select min(date), max(date) from %s" % (table)
		print query
		myDb = dbConnect()
		dbQuery(myDb, query)
		list = dbFetch(myDb)
		print list
		row = list[0]
		mindate = row[0]
		maxdate = row[1]

		return mindate, maxdate
		

	#----------------------------------
	def date_config(self):

		(mindate, maxdate) = self.getDates(self.data.stacode, self.data.paramname)
		print mindate, maxdate

		self.byear.SetRange(mindate.year, maxdate.year)
		self.eyear.SetRange(mindate.year, maxdate.year)

        #------------------------------------------------------------------------
        def mkOptions(self):

		box = wx.StaticBox(self, -1, "Data Options")
		szr = wx.StaticBoxSizer(box, wx.VERTICAL)

		panel = self.options()
		szr.Add(panel)

		return szr

        #------------------------------------------------------------------------
	def options(self):

		panel = wx.Panel(self, -1)
		vs = wx.BoxSizer(wx.VERTICAL)
		panel.SetSizer(vs)

		# intake heights
		txt = wx.StaticText(panel, -1, "Intake Heights")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		table = self.data.stacode.lower() + "_" + self.data.paramname + "_insitu"
		query = "select distinct intake_ht from %s where intake_ht > 0" % table
		myDb = dbConnect()
		dbQuery(myDb, query)
		list = dbFetch(myDb)
		rbList = []
		for ht in list:
			rbList.append(str(ht[0]))

		self.intake = wx.RadioBox(
			panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
			rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
			)
		vs.Add(self.intake, 0, wx.LEFT, 20)

		# instrument
		txt = wx.StaticText(panel, -1, "Instrument")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		start_date = "%s-%s-%s" % (self.data.byear, self.data.month1, 1)
		end_date = "%s-%s-%s" % (self.data.eyear, self.data.month2, 31)
		table = self.data.stacode.lower() + "_" + self.data.paramname + "_insitu"
		query = "select distinct inst from %s where date >= '%s' and date <= '%s'" % (table, start_date, end_date)
		print query
		myDb = dbConnect()
		dbQuery(myDb, query)
		list = dbFetch(myDb)
		rbList = []
		for inst in list:
			rbList.append(inst[0])

		self.inst = wx.RadioBox(
			panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
			rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
			)
#		self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
		vs.Add(self.inst, 0, wx.LEFT, 20)

		return panel


        #----------------------------------
        def option_config(self):

		self.data.byear = self.byear.GetValue()
		self.data.eyear = self.eyear.GetValue()
                month1 = self.month1.GetStringSelection()
                month2 = self.month2.GetStringSelection()
                self.data.month1 = self.getMonthNum(month1)
                self.data.month2 = self.getMonthNum(month2)

		self.options_sizer.Clear(True)

		panel = self.options()

		self.options_sizer.Add(panel)
		self.options_sizer.Layout()

		# resize the dialog
		win = self
		while win is not None:
			win.InvalidateBestSize()
			win = win.GetParent()
		wx.CallAfter(wx.GetTopLevelParent(self).Fit) 


	#----------------------------------
	def ok(self, event):
		""" 
		Get all the values from the dialog and store them in self.data
			stacode
			parameter
			begyear
			endyear
			begmonth
			endmonth
			options:
				plot soft flags
				intake_ht
				analyzer
		"""

		self.data.stacode = self.getStationCode()
		self.data.sitenum = getSiteNum(self.data.stacode)

		self.data.byear = self.byear.GetValue()
		self.data.eyear = self.eyear.GetValue()
                month1 = self.month1.GetStringSelection()
                month2 = self.month2.GetStringSelection()
                self.data.month1 = self.getMonthNum(month1)
                self.data.month2 = self.getMonthNum(month2)

		s = self.parambox.GetStringSelection()
		(formula,name) = s.split('-', 1)
		formula = formula.strip()
		paramnum = getGasNum(formula)
		self.data.parameter = paramnum
		self.data.paramname = formula

		n = self.intake.GetStringSelection()
		self.data.intake_ht = float(n)

		self.data.inst = self.inst.GetStringSelection()

		self.EndModal(wx.ID_OK)


	#----------------------------------------------
	def getMonthNum(self, s):

                list = [
                        "January" ,
                        "February",
                        "March",
                        "April",
                        "May",
                        "June",
                        "July",
                        "August",
                        "September",
                        "October",
                        "November",
                        "December"
                ]

		if s in list:
			num = list.index(s) + 1
		else:
			num = 0

		return num

	
	#----------------------------------------------
	def ProcessData(self):
		"""
		Process the data from the GetDataDialog,
		return the x, and y lists and name for new dataset.
		"""

		query = ""
		name = ""

                table = "%s_%s_insitu" % (self.data.stacode.lower(), self.data.paramname)

                x = []
                y = []
                for year in range(self.data.byear,self.data.eyear+1):
                        smon = 1
                        if year == self.data.byear:
                                smon = self.data.month1
                        emon = 12
                        if year == self.data.eyear:
                                emon = self.data.month2

                        for month in range(smon, emon+1):
                                # get the data for this month

				nextmonth = month+1
				nextyear = year
				if nextmonth > 12:
					nextyear += 1
				datestr1 = "%s-%s-1" % (year, month)
				datestr2 = "%s-%s-1" % (nextyear, nextmonth)

                                query  = "select dd, value from %s " % (table)
                                query += "where date>='%s' and date<'%s' " % (datestr1, datestr2)
                                query += "and intake_ht=%s and inst='%s' " % (self.data.intake_ht, self.data.inst)
				query += "and flag like '.%%' "
				query += "and value > 0 "
                                query += "order by dd"
                                print query
                                myDb = dbConnect()
                                dbQuery(myDb, query)
                                list = dbFetch(myDb)

				for line in list:
					xp = line[0]
					yp = float(line[1])
					x.append(xp)
					y.append(yp)

                name = self.data.stacode + " " + self.data.paramname + " " + str(self.data.intake_ht)

		return x, y, name
