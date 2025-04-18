"""
Dialog class for choosing data set to graph.
Dialog contains several sections:
	project (in-situ, surface flask, aircraft flask...)
	station list
	parameter
	time span
	options

Used by grapher module
Create with

	from common import get

	dlg = get.GetDataDialog(self)

	where self is the parent of the dialog.

Then get data arrays with

	x,y,name = dlg.ProcessData()
"""

import wx
import datetime
import numpy

from common import extchoice
from common.utils import *

import sys
sys.path.append("/ccg/src/python/lib")
import dbutils
import dates


#####################################################################
class GetData:

        def __init__(self):
		self.project = 1
		self.sitenum = 75
		self.stacode = "MLO"
		self.parameter = 1
		self.paramname = "co2"
		self.parameter_list = [1]
		self.byear = 0
		self.eyear = 0
		self.use_flask = True
		self.use_pfp = True
		self.bin_method = None
		self.use_soft_flags = False
		self.use_hard_flags = False
		self.use_strategy = False
		self.min_bin = 0
		self.max_bin = 0
		self.bin_data = False
		self.obs_use_soft_flags = False
		self.soft_flags_symbol = False
		self.datasets = []
		self.useDatetime = False
		self.programs = ('CCGG')

	#----------------------------------------------
	def process_data(self, useDatetime=False):

		self.useDatetime = useDatetime

		if self.project in [1,2]:
			self.flask_process_data()
		elif self.project == 3 or self.project == 5:
			self.tower_process_data()
		elif self.project == 4:
			self.obs_process_data()

	#----------------------------------------------
	def obs_process_data(self):

		# Observatory insitu

		self.datasets = []

		average = self.obs_avg

		if "Daily" in average:
			table = self.stacode.lower() + "_" + self.paramname + "_day"
		elif "Monthly" in average:
			table = self.stacode.lower() + "_" + self.paramname + "_month"
		elif "Hourly" in average:
			table = self.stacode.lower() + "_" + self.paramname + "_hour"
		else:
			print "Unknown averaging type for observatory data.", average
			return 

		query = "SELECT dd,value FROM %s " % (table)
		query += "WHERE year(date) between %d AND %d " % (self.byear, self.eyear)
		query += "AND value > -999 "
		if "Hourly" in average:
			if self.use_soft_flags and not self.soft_flags_symbol:
				query += "AND flag like '.%' "
			else:
				query += "AND flag like '..%' "
		query += "ORDER BY dd "
		name = self.stacode + " Obs " + self.paramname

		list = dbutils.dbQueryAndFetch(query)

		ds = GetDataset()
		
		for row in list:
			dd = float(row[0])
			if self.useDatetime:
				(yr,mn,dy,hr,mi,sc) = dates.calendarDate(dd)
				xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
			else:
				xp = dd
			ds.x.append(xp)
			ds.y.append(float(row[1]))

		ds.name = name
		self.datasets.append(ds)

		# make additional datasets for flagged data if requested
		if self.use_soft_flags and self.soft_flags_symbol and "Hourly" in average:
			query = "SELECT dd,value,flag FROM %s " % (table)
			query += "WHERE year(date) between %d AND %d " % (self.byear, self.eyear)
			query += "AND value > -999 "
#			query += "AND flag like '.%' "
			query += "AND SUBSTRING(flag, 2,1)!='.' "
			query += "ORDER BY dd "
			print query

			list = dbutils.dbQueryAndFetch(query)

			x = {}	
			y = {}
			for row in list:
				dd = float(row[0])
				val = float(row[1])
				flag = row[2][1]
				if self.useDatetime:
					(yr,mn,dy,hr,mi,sc) = dates.calendarDate(dd)
					xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
				else:
					xp = dd

				if flag not in x:
					x[flag] = []
					y[flag] = []
				
				x[flag].append(xp)
				y[flag].append(val)

			for flag in sorted(x.keys()):
				ds = GetDataset()
				ds.x = x[flag]
				ds.y = y[flag]
				ds.name = name + "  " + flag
				self.datasets.append(ds)

	#----------------------------------------------
	def tower_process_data(self):

		# tower insitu

		self.datasets = []

		intake_ht = self.intake_ht

		table = self.stacode.lower() + "_" + self.paramname + "_hour"

		query = "SELECT dd,value FROM %s " % (table)
		query += "WHERE year(date) between %d AND %d " % (self.byear, self.eyear)
		query += "AND intake_ht = %f " % intake_ht
		query += "AND value > -999 "
		if self.use_soft_flags and not self.soft_flags_symbol:
			query += "AND flag like '.%' "
		else:
			query += "AND flag like '..%' "
		query += "ORDER BY dd "
		name = self.stacode + " Tower " + self.paramname + " " + str(intake_ht)

		list = dbutils.dbQueryAndFetch(query)

		ds = GetDataset()
		
		for row in list:
			dd = float(row[0])
			if self.useDatetime:
				(yr,mn,dy,hr,mi,sc) = dates.calendarDate(dd)
				xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
			else:
				xp = dd
			ds.x.append(xp)
			ds.y.append(float(row[1]))

		ds.name = name
		self.datasets.append(ds)

		# make additional datasets for flagged data if requested
		# not implemented for towers yet.  need to change dialog to include flag check boxes
		if self.use_soft_flags and self.soft_flags_symbol:
			query = "SELECT dd,value,flag FROM %s " % (table)
			query += "WHERE year(date) between %d AND %d " % (self.byear, self.eyear)
			query += "AND value > -999 "
#			query += "AND flag like '.%' "
			query += "AND SUBSTRING(flag, 2,1)!='.' "
			query += "ORDER BY dd "
			print query

			list = dbutils.dbQueryAndFetch(query)

			x = {}	
			y = {}
			for row in list:
				dd = float(row[0])
				val = float(row[1])
				flag = row[2][1]
				if self.useDatetime:
					(yr,mn,dy,hr,mi,sc) = dates.calendarDate(dd)
					xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
				else:
					xp = dd

				if flag not in x:
					x[flag] = []
					y[flag] = []
				
				x[flag].append(xp)
				y[flag].append(val)

			for flag in sorted(x.keys()):
				ds = GetDataset()
				ds.x = x[flag]
				ds.y = y[flag]
				ds.name = name + "  " + flag
				self.datasets.append(ds)

	#----------------------------------------------
	def flask_process_data(self):

		progs = []
		for progname in self.programs:
			prognum = dbutils.getProgramNum(progname)
			progs.append(str(prognum))

		self.datasets = []
			
		name = self.stacode + " " + self.paramname

		query =  "SELECT flask_event.dd, flask_data.value, flask_data.flag FROM flask_event,flask_data "
		query += "WHERE flask_event.num=flask_data.event_num "
		query += "AND flask_event.site_num=%d AND flask_data.value > -999 " % self.sitenum
		query += "AND year(flask_event.date) between %d AND %d " % (self.byear, self.eyear)
		query += "AND flask_data.parameter_num=%d AND flask_event.project_num=%d " % (self.parameter, self.project)
		query += "AND program_num in (%s) " % ",".join(progs)

		if self.use_soft_flags and not self.soft_flags_symbol:
			query += "AND flask_data.flag like '.%' "
		else:
			query += "AND flask_data.flag like '..%' "

		if self.use_flask and self.use_pfp:
			query += "AND (strategy_num=1 OR strategy_num=2) "
		elif self.use_flask:
			query += "AND strategy_num=1 "
		elif self.use_pfp:
			query += "AND strategy_num=2 "


		if self.bin_data and self.bin_method:
			query += "AND flask_event.%s BETWEEN %f AND %f " % (self.bin_method, self.min_bin, self.max_bin)
			name += " %g - %g m" % (self.min_bin, self.max_bin)

		query += "ORDER BY flask_event.dd "
#		print query

		list = dbutils.dbQueryAndFetch(query)

		ds = GetDataset()
			
		for row in list:
			dd = float(row[0])
			if self.useDatetime:
				(yr,mn,dy,hr,mi,sc) = dates.calendarDate(dd)
				xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
			else:
				xp = dd
			ds.x.append(xp)
			ds.y.append(float(row[1]))

		ds.name = name
		self.datasets.append(ds)

		# add flagged data datasets if requested
		if self.use_soft_flags and self.soft_flags_symbol:

			query =  "SELECT flask_event.dd, flask_data.value, flask_data.flag FROM flask_event,flask_data "
			query += "WHERE flask_event.num=flask_data.event_num "
			query += "AND flask_event.site_num=%d AND flask_data.value > -999 " % self.sitenum
			query += "AND year(flask_event.date) between %d AND %d " % (self.byear, self.eyear)
			query += "AND flask_data.parameter_num=%d AND flask_event.project_num=%d " % (self.parameter, self.project)
			query += "AND SUBSTRING(flask_data.flag, 2,1)!='.' "
			if self.use_flask and self.use_pfp:
				query += "AND (strategy_num=1 OR strategy_num=2) "
			elif self.use_flask:
				query += "AND strategy_num=1 "
			elif self.use_pfp:
				query += "AND strategy_num=2 "

			if self.bin_method:
				query += "AND flask_event.%s BETWEEN %f AND %f " % (self.bin_method, self.min_bin, self.max_bin)
				name += " %g - %g m" % (self.min_bin, self.max_bin)

			query += "ORDER BY flask_event.dd "
#			print query
			list = dbutils.dbQueryAndFetch(query)
				
			x = {}	
			y = {}
			for row in list:
				dd = float(row[0])
				val = float(row[1])
				flag = row[2][1]
				if self.useDatetime:
					(yr,mn,dy,hr,mi,sc) = dates.calendarDate(dd)
					xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
				else:
					xp = dd

				if flag not in x:
					x[flag] = []
					y[flag] = []
				
				x[flag].append(xp)
				y[flag].append(val)

			for flag in sorted(x.keys()):
				ds = GetDataset()
				ds.x = x[flag]
				ds.y = y[flag]
				ds.name = name + "  " + flag
				self.datasets.append(ds)

	#----------------------------------------------
	def get_flask_events(self):


		self.param_list = self.parameter_list[:6]
		nparm = len(self.param_list)
		tmp = []
		for p in self.param_list:
			tmp.append(str(p))
		plist = ",".join(tmp)

		progs = []
		for progname in self.programs:
			prognum = dbutils.getProgramNum(progname)
			progs.append(str(prognum))
		proglist = ",".join(progs)


		# Get the data for all requested parameters to put in the event listbox
		query = "select distinct flask_event.num, flask_event.date, flask_event.time, id, me from flask_event,flask_data "
		query += "where site_num=%d and project_num=%d " % (self.sitenum, self.project)
		query += "AND year(flask_event.date) between %d AND %d " % (self.byear, self.eyear)
		query += "AND flask_event.num=flask_data.event_num "
		query += "AND flask_data.parameter_num in (%s) " % plist
		query += "AND program_num in (%s) " % proglist

		if self.use_flask and self.use_pfp:
			query += "AND (strategy_num=1 OR strategy_num=2) "
		elif self.use_flask:
			query += "AND strategy_num=1 "
		elif self.use_pfp:
			query += "AND strategy_num=2 "

		if self.bin_method and self.bin_data:
			query += "AND flask_event.%s BETWEEN %f AND %f " % (self.bin_method, self.min_bin, self.max_bin)

		query += "ORDER BY date, time "


		result = dbutils.dbQueryAndFetch(query)

		return result


##########################################################################
class GetDataset:

        def __init__(self):
		self.x = []
		self.y = []
		self.name = ""

##########################################################################
class GetDataDialog(wx.Dialog):
	def __init__(self, parent=None, title="Choose Dataset", graph=None, flaskOnly=False, multiParameters=False):
		wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

		self.data = GetData()
		self.flaskOnly = flaskOnly
		self.multiParameters = multiParameters
		if self.flaskOnly:
			self.projects = { "Surface Flasks": 1 , "Airborne Flasks":2 }
		else:
			self.projects = { "Surface Flasks": 1 , "Airborne Flasks":2, "Tall Tower":3, "Observatory":4, "Surface In-Situ":5 }
#		self.projects = { "Surface Flasks": 1 , "Airborne Flasks":2, "Observatory":4 }

		self.progbtns = []

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		sizer = self.mkProject()
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

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

		self.choice.SetSelection(0)


	#----------------------------------
	def mkProject(self):

		# project choice box
		box1 = wx.BoxSizer(wx.HORIZONTAL)

		label = wx.StaticText(self, -1, "Project: ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		# get list of keys sorted by value
		list = sorted(self.projects, key=self.projects.get)

		self.choice = wx.Choice(self, -1, choices=list)
		box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.Bind(wx.EVT_CHOICE, self.projChoice, self.choice)

		return box1

	#----------------------------------
	def projChoice(self, event):
		""" project choice has changed """

		proj = event.GetString()
		if proj in self.projects:
			self.data.project = self.projects[proj]

		print "data.project is ", self.data.project
		self.station_config()
		self.param_config()
		self.date_config()
		self.option_config()


	#----------------------------------
	def mkStation(self):

                box = wx.StaticBox(self, -1, "Sampling Site")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

                self.listbox = extchoice.ExtendedChoice(self, -1, size=(555,-1))
		self.station_config()

		szr.Add(self.listbox, 0, wx.ALIGN_LEFT|wx.ALL, 5)
                self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)

		return szr


	#----------------------------------
	def station_config(self):
		""" update site list.
		    called on creation and whenever project changes.
		"""

		project = self.data.project
		if project == 5:
			list = getSiteList(1, [3])
		else:
			list = getSiteList(project, [1,2])

#		print "station list is ", list

		# Add the site names to a list.  But don't include
		# the 'binned' sites.  This is a temporary fix until
		# we modify the database tables to distinguish between
		# real and binned sites.
		value = ""
                stations = []
                for (code, name, country) in list:
			if len(code) > 3:
				if code[3] == "S" or code[3] == "N" or code[3] == "0":
					continue
                        txt = "%s - %s" % (code, name)
                        stations.append(txt)
			if code == self.data.stacode:
				value = txt

		if value == "": value = stations[0]

                self.listbox.ReplaceAll(stations)
		self.listbox.SetValue(value)

		self.data.stacode = self.getStationCode();


		return

	#----------------------------------
	def stationSelected(self, event):
		""" station selection has changed.
		    update parameters, time span and options
		    with values relavent to selected station.
		"""

		self.data.stacode = self.getStationCode()
		self.param_config()
#		self.date_config()
		self.option_config()

	#----------------------------------
	def mkParams(self):

                box = wx.StaticBox(self, -1, "Parameters")
                box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

		if self.multiParameters:
			text = "Select one or more measurement parameters."
			self.label = wx.StaticText(self, -1, text)
			box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

			text = "Use [shift] or [control] keys with mouse button to select more than 1 item.\n (6 maximum)"
			self.label = wx.StaticText(self, -1, text)
			box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

			self.parambox = wx.ListBox(self, -1, style=wx.LB_EXTENDED, size=(500,150))
			box1.Add(self.parambox, 1, wx.ALIGN_RIGHT|wx.ALL, 5)


		else:
			text = "Select a measurement parameter."
			self.label = wx.StaticText(self, -1, text)
			box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

			self.parambox = wx.ListBox(self, -1, style=wx.LB_SINGLE, size=(500,150))
			box1.Add(self.parambox, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

#		self.Bind(wx.EVT_LISTBOX, self.paramSelected, self.parambox)
#                self.parambox.Bind(wx.EVT_LISTBOX, self.paramSelected)
		self.param_config()

		return box1

	#----------------------------------
	def param_config(self):


		code = self.data.stacode
		project = self.data.project
		if project == 5:
			plist = getParameterList(code, [1], [3])
		else:
			plist = getParameterList(code, [project], [1,2])

#		print plist

		if len(plist) == 0:
			self.parambox.Hide()
#			self.message.SetLabel("No parameters found for this location.")
#			self.message.Show()
			return
		else:
			self.parambox.Show()
#			self.message.SetLabel("")
#			self.message.Hide()

		prev_param = []
		if self.multiParameters:
			zz = self.parambox.GetSelections()
			for idx in zz:
				prev_param.append(self.parambox.GetString(idx))
		else:
			zz = self.parambox.GetSelection()
			if zz >= 0:
				prev_param.append(self.parambox.GetString(zz))


#		self.parambox.Unbind(wx.EVT_LISTBOX)
		self.Unbind(wx.EVT_LISTBOX, self.parambox)
		self.parambox.Clear()
		param_strings = []
                for (formula,name) in plist:
                        s = "%s - %s" % (formula, name)
			param_strings.append(s)
			self.parambox.Append(s)


		# if previous selected parameter is in the new list, select it now
		idx = -1
		for s in prev_param:
			if s in param_strings:
				idx = param_strings.index(s)
				self.parambox.SetSelection(idx)
				self.data.paramname = plist[idx][0]

		if idx < 0:
			self.parambox.SetSelection(0)
			self.data.paramname = plist[0][0]
			

#                self.parambox.Bind(wx.EVT_LISTBOX, self.paramSelected)
                self.Bind(wx.EVT_LISTBOX, self.paramSelected, self.parambox)

		return

	#----------------------------------
	def paramSelected(self, event):

		if self.multiParameters:
			self.data.parameter_list = []
			for i in self.parambox.GetSelections():
				s = self.parambox.GetString(i)
				(formula,name) = s.split('-', 1)
				formula = formula.strip()
				paramnum = dbutils.getGasNum(formula)
				self.data.parameter_list.append(paramnum)
			if len(self.data.parameter_list):
				self.data.parameter = self.data.parameter_list[0]
				
		else:
			idx = self.parambox.GetSelection()
#		print "selected parameter is ", s
#		zz = self.parambox.GetSelection()
			s = self.parambox.GetString(idx)
			print "selected parameter is ", s

			if "-" in s:
				(formula,name) = s.split('-', 1)
				formula = formula.strip()
				paramnum = dbutils.getGasNum(formula)
				self.data.parameter = paramnum
				self.data.paramname = formula

		self.option_config()

	#----------------------------------
	def getStationCode(self):
		s = self.listbox.GetValue()
		code, name = s.split('-', 1)
		code = code.strip()

		return code

	#----------------------------------
	def mkTimeSpan(self):

                box = wx.StaticBox(self, -1, "Time Span")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#		box1 = wx.FlexGridSizer(0,4,2,20)
		box1 = wx.BoxSizer(wx.HORIZONTAL)
		szr.Add(box1)

		now=datetime.datetime.now()
		this_year = now.year

		label = wx.StaticText(self, -1, "Beginning Year:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT|wx.RIGHT, 5)
		self.byear = wx.SpinCtrl(self, -1, "1967", min=1967, max=this_year, size=(100,-1))
		box1.Add(self.byear, 0, wx.ALIGN_LEFT|wx.RIGHT, 20)

		label = wx.StaticText(self, -1, "Ending Year:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT|wx.RIGHT, 5)
		self.eyear = wx.SpinCtrl(self, -1, str(this_year), min=1967, max=this_year, size=(100,-1))
		box1.Add(self.eyear, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		return szr

	#----------------------------------
	def date_config(self):

		(mindate, maxdate) = getMinMaxDates(self.data.stacode, [self.data.project], [1,2], "co2")
#		print "mindate is", mindate, "maxdate is", maxdate

		self.byear.SetValue(mindate.year)
		self.eyear.SetValue(maxdate.year)

        #------------------------------------------------------------------------
        def mkOptions(self):

		box = wx.StaticBox(self, -1, "Data Options")
		self.boxx = box
		szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#		self.flask_sizer = wx.BoxSizer(wx.VERTICAL)
#		szr.Add(self.flask_sizer)
		panel = self.flask_options()
		szr.Add(panel)

#		self.tower_sizer = wx.BoxSizer(wx.VERTICAL)
#		szr.Add(self.tower_sizer)
#		panel = self.tower_options()
#		szr.Add(panel)

#		szr.Hide(panel)

		return szr

        #------------------------------------------------------------------------
	def flask_options(self):

		panel = wx.Panel(self, -1)
		vs = wx.BoxSizer(wx.VERTICAL)
		panel.SetSizer(vs)

		# don't show flagging options if flaskOnly
		if not self.flaskOnly:
			txt = wx.StaticText(panel, -1, "Flagged Data")
			vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

			self.f2 = wx.CheckBox(panel, -1, "Plot Data with Soft Flags")
			self.f2.SetValue(self.data.use_soft_flags)
			vs.Add(self.f2, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 20)
			self.Bind(wx.EVT_CHECKBOX, self.get_soft_flag, self.f2)

			self.f2a = wx.CheckBox(panel, -1, "Plot flagged data with different symbol")
			self.f2a.SetValue(self.data.soft_flags_symbol)
			vs.Add(self.f2a, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 40)
			self.Bind(wx.EVT_CHECKBOX, self.get_soft_flags_symbol, self.f2a)
		
		#--------------------------

		if self.multiParameters:
			sql = "select distinct program_num,program from flask_data_view where site='%s' and parameter_num in (%s) " % (self.data.stacode, ",".join([str(x) for x in self.data.parameter_list]))
		else:
			sql = "select distinct program_num,program from flask_data_view where site='%s' and parameter='%s'" % (self.data.stacode, self.data.paramname)
#		print sql
		result = dbutils.dbQueryAndFetch(sql)

		
		txt = wx.StaticText(panel, -1, "Program")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		progchoices = []
		for (prognum, prog) in result:
			progchoices.append(prog)

		self.p2 = wx.CheckListBox(panel, -1, size=(-1, 55), choices=progchoices)
#		self.p2.SetValue(self.data.use_soft_flags)
		vs.Add(self.p2, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 20)
#		self.Bind(wx.EVT_CHECKBOX, self.get_soft_flag, self.p2)

		for i in range(len(progchoices)):
			self.p2.Check(i, True)



		#--------------------------

		txt = wx.StaticText(panel, -1, "Strategies")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		self.o1 = wx.CheckBox(panel, -1, "Individual Flasks")
		vs.Add(self.o1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 20)

		self.o2 = wx.CheckBox(panel, -1, "Programmable Flask Package")
		vs.Add(self.o2, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 20)

		# Check if more than 1 strategy for this site
		result = getStrategies(self.data.stacode, [self.data.project])

		if 1 in result:
			self.o1.Enable(True)
			self.o1.SetValue(True)
		else:
			self.o1.Enable(False)
			self.o1.SetValue(False)

		if 2 in result:
			self.o2.Enable(True)
			self.o2.SetValue(True)
		else:
			self.o2.Enable(False)
			self.o2.SetValue(False)


		# check on bin options
		sitenum = dbutils.getSiteNum(self.data.stacode)
		query = "select method, min, max, width "
		query += "from data_binning where site_num=%s and project_num=%s" % (sitenum, self.data.project)
		myDb, c = dbutils.dbConnect()
		c.execute(query)
		result = c.fetchall()
		c.close()
		myDb.close()
		if len(result) == 0 and self.data.project != 2:
			return panel

		txt = wx.StaticText(panel, -1, "Binning")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		c = []
		if len(result) == 0:
			method = "alt"
			min = 1000
			max = 8000
			width = 2000
		else:
			method, min, max, width = result[0]

		if method == "alt":
			units = "meters"
			bintype = "altitude"
		else:
			units = "degrees"
			bintype = "latitude"

		self.data.bin_method = method

		if width == 0:
			s = "From %s %s to %s %s" % (min, units, max, units)
			c.append(s)
		else:
			for center in numpy.arange(min, max+width, width):
				low = center-width/2
				high = center+width/2
				s = "From %s %s to %s %s" % (low, units, high, units)
				c.append(s)

		#-----
		box1 = wx.FlexGridSizer(0,2,2,2)
		vs.Add(box1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		t = wx.StaticText(panel, -1, "Select a default %s range:" % bintype)
		box1.Add(t, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT, 20)

		self.bin = wx.Choice(panel, -1, choices=c)
		self.bin.SetSelection(0)
		box1.Add(self.bin, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)

		t = wx.StaticText(panel, -1, "OR specify %s range:" % bintype)
		box1.Add(t, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT, 20)

		# another horizontal box
		box2 = wx.BoxSizer(wx.HORIZONTAL)
		box1.Add(box2, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)

		label = wx.StaticText (panel, -1, "From ")
		box2.Add(label, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL)
		self.le2 = wx.TextCtrl(panel, -1, "")
		box2.Add(self.le2, 0, wx.ALIGN_LEFT)
		label = wx.StaticText (panel, -1, " to ")
		box2.Add(label, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL)
		self.le3 = wx.TextCtrl(panel, -1, "")
		box2.Add(self.le3, 0, wx.ALIGN_LEFT)
		label = wx.StaticText (panel, -1, " %s." % units)
		box2.Add(label, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL)

		t = wx.StaticText(panel, -1, "OR ")
		box1.Add(t, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT, 20)
#		self.o3 = wx.CheckBox(panel, -1, "OR Use All Data")
		self.o3 = wx.CheckBox(panel, -1, "Use All Data")
		self.o3.SetValue(False)
		box1.Add(self.o3, 0, wx.ALIGN_LEFT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)

		return panel


        #----------------------------------
	def tower_options(self):

		panel = wx.Panel(self, -1)

		vs = wx.BoxSizer(wx.VERTICAL)
		panel.SetSizer(vs)

		txt = wx.StaticText(panel, -1, "Intake Heights")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		table = self.data.stacode.lower() + "_" + self.data.paramname + "_insitu"
		query = "select distinct intake_ht from %s where intake_ht > 0" % table
		list = dbutils.dbQueryAndFetch(query)
		rbList = []
		for n, ht in enumerate(list):
			rbList.append(str(ht[0]))

		self.intake = wx.RadioBox(
			panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
			rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
			)
#		self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
		vs.Add(self.intake, 0, wx.LEFT, 20)

		return panel

        #----------------------------------
	def obs_options(self):

		panel = wx.Panel(self, -1)

		vs = wx.BoxSizer(wx.VERTICAL)
		panel.SetSizer(vs)

		txt = wx.StaticText(panel, -1, "Data Averages")
		vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

		rbList = ["Monthly Averages", "Daily Averages", "Hourly Averages"]
		self.obs = wx.RadioBox(
			panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
			rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
			)
#		self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
		vs.Add(self.obs, 0, wx.LEFT, 20)

		self.obsf2 = wx.CheckBox(panel, -1, "Plot Data with Soft Flags")
		self.obsf2.SetValue(False)
		vs.Add(self.obsf2, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 20)

		self.obsf2a = wx.CheckBox(panel, -1, "Plot flagged data with different symbols")
		self.obsf2a.SetValue(self.data.soft_flags_symbol)
		vs.Add(self.obsf2a, 0, wx.GROW|wx.ALIGN_RIGHT|wx.LEFT, 40)
#		self.Bind(wx.EVT_CHECKBOX, self.get_soft_flags_symbol, self.obsf2a)
		

		return panel



        #----------------------------------
        def option_config(self):

		self.data.bin_method = None
		self.data.bin_data = False

		self.options_sizer.Clear(True)
		if self.data.project in [1,2]:

			panel = self.flask_options()

		elif self.data.project == 3:

			panel = self.tower_options()

		elif self.data.project == 4:

			panel = self.obs_options()

		elif self.data.project == 5:
			panel = self.tower_options()

		else:
			print "how did i get here?"

		self.options_sizer.Add(panel)
		self.options_sizer.Layout()

		# resize the dialog
		win = self
		while win is not None:
			win.InvalidateBestSize()
			win = win.GetParent()
		wx.CallAfter(wx.GetTopLevelParent(self).Fit) 


	#----------------------------------
	def get_soft_flag(self, event):

		self.data.use_soft_flags = self.f2.GetValue()

	#----------------------------------
	def get_soft_flags_symbol(self, event):

		self.data.soft_flags_symbol = self.f2a.GetValue()

	#----------------------------------
	def ok(self, event):
		""" 
		Get all the values from the dialog and store them in self.data
			project
			stacode
			parameter
			begyear
			endyear
			options:
				plot soft flags
				plot soft flags with different symbol
				regular flasks
				pfp flasks
				binning:

				tower:
					intake_ht
				insitu:
					monthly averages
					daily averages
					hourly averages
					

			
		"""

		self.data.stacode = self.getStationCode()
		self.data.sitenum = dbutils.getSiteNum(self.data.stacode)

		self.data.byear = self.byear.GetValue()
		self.data.eyear = self.eyear.GetValue()


		if self.multiParameters:
			self.data.parameter_list = []
			for i in self.parambox.GetSelections():
				s = self.parambox.GetString(i)
				(formula,name) = s.split('-', 1)
				formula = formula.strip()
				paramnum = dbutils.getGasNum(formula)
				self.data.parameter_list.append(paramnum)
			self.data.parameter = self.data.parameter_list[0]
		else:
			s = self.parambox.GetStringSelection()
			(formula,name) = s.split('-', 1)
			formula = formula.strip()
			paramnum = dbutils.getGasNum(formula)
			self.data.parameter = paramnum
			self.data.paramname = formula

		if self.data.project in [1,2]:
			self.data.use_flask = self.o1.GetValue()
			self.data.use_pfp = self.o2.GetValue()

			if not self.data.use_flask and not self.data.use_pfp:
				msg = "Must select at least one flask type."
				dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
				dlg.ShowModal()
				dlg.Destroy()
				return

			# programs
			progs = self.p2.GetCheckedStrings()
#			print "progs are", progs
			self.data.programs = progs

#			self.data.use_hard_flags = self.f1.GetValue()
			if not self.flaskOnly:
				self.data.use_soft_flags = self.f2.GetValue()
				self.data.soft_flags_symbol = self.f2a.GetValue()


			# binning
			if self.data.bin_method:
				val = self.o3.GetValue() # use all data
				if val:
					self.data.min_bin = 0
					self.data.max_bin = 0
					self.data.bin_data = False
				else:
					self.data.bin_data = True
					_min = self.le2.GetValue()
					_max = self.le3.GetValue()
					if _min == "" and _max == "":
						s = self.bin.GetStringSelection()
						result = s.split()
						self.data.min_bin = float(result[1])
						self.data.max_bin = float(result[4])
					else:
						self.data.min_bin = float(_min)
						self.data.max_bin = float(_max)


		# tower
		elif self.data.project == 3 or self.data.project == 5:
			n = self.intake.GetStringSelection()
			self.data.intake_ht = float(n)

		# observatory
		elif self.data.project == 4:
			s = self.obs.GetStringSelection()
			self.data.obs_avg = s
			self.data.use_soft_flags = self.obsf2.GetValue()
			self.data.soft_flags_symbol = self.obsf2a.GetValue()


		self.EndModal(wx.ID_OK)


