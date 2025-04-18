
import wx
from datetime import datetime

from common import extchoice
from common.utils import *

import sys
sys.path.append("/ccg/src/python/lib")
import dbutils

#####################################################################
class FlGetData:

        project = 1
        sitenum = 75
        stacode = "MLO"
        parameter_list = []
        byear = 0
        eyear = 0


##########################################################################
class GetFlDialog(wx.Dialog):
	def __init__(self, parent=None, title="Flask Flagging", graph=None):
		wx.Dialog.__init__(self, parent, -1, title)

		self.data = FlGetData()

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		sizer = self.mkSource(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkStation(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkParams(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkTimeSpan(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.flaskOptions(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

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
	def mkSource(self, box0):

		# project choice box
		box1 = wx.BoxSizer(wx.HORIZONTAL)

		label = wx.StaticText(self, -1, "Flask Project: ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		list = [
			"Surface Flasks" ,
			"Airborne Flasks"
		]
		self.choice = wx.Choice(self, -1, choices=list)
		box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.Bind(wx.EVT_CHOICE, self.projChoice, self.choice)

		return box1

	#----------------------------------
	def projChoice(self, event):

		proj = event.GetString()
		if proj == "Surface Flasks":
			self.data.project = 1
		else:
			self.data.project = 2
		self.station_config()


	#----------------------------------
	def mkStation(self, box0):

                box = wx.StaticBox(self, -1, "Sampling Site")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

                self.listbox = extchoice.ExtendedChoice(self, -1, size=(555,-1))
		self.station_config()

		szr.Add(self.listbox, 0, wx.ALIGN_LEFT|wx.ALL, 5)
                self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)

		return szr

	#----------------------------------
	def stationSelected(self, event):

		code = self.getStationCode()
		self.param_config()
		self.date_config(code)
		self.flask_config(code)


	#----------------------------------
	def station_config(self):

		project = self.data.project
		list = getSiteList(project, [1,2])

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
			if code == "MLO":
				value = txt

		if value == "": value = stations[0]

                self.listbox.ReplaceAll(stations)
		self.listbox.SetValue(value)

		return

	#----------------------------------
	def mkParams(self, box0):

                box = wx.StaticBox(self, -1, "Parameters")
                box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

		text = "Select one or more measurement parameters."
		self.label = wx.StaticText(self, -1, text)
		box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

		text = "Use [shift] or [control] keys with mouse button to select more than 1 item.\n (6 maximum)"
		self.label = wx.StaticText(self, -1, text)
		box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

		self.message = wx.StaticText(self, -1, "")
		box1.Add(self.message, 0, wx.ALIGN_LEFT|wx.ALL, 5)
		self.parambox = wx.ListBox(self, -1, style=wx.LB_EXTENDED, size=(500,150))
		box1.Add(self.parambox, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

		self.param_config()

		return box1

	#----------------------------------
	def param_config(self):

		code = self.getStationCode()
		project = self.data.project
		list = getParameterList(code, project, [1,2])


		if len(list) == 0:
			self.parambox.Hide()
			self.message.SetLabel("No parameters found for this location.")
			self.message.Show()
			return
		else:
			self.parambox.Show()
			self.message.SetLabel("")
			self.message.Hide()

		self.parambox.Clear()
                for (formula,name) in list:
                        s = "%s - %s" % (formula, name)
			self.parambox.Append(s)

		self.parambox.SetSelection(0)
		
		return

	#----------------------------------
	def getStationCode(self):
		s = self.listbox.GetValue()
		code, name = s.split('-', 1)
		code = code.strip()

		return code

	#----------------------------------
	def mkTimeSpan(self, box0):

                box = wx.StaticBox(self, -1, "Time Span")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

		box1 = wx.FlexGridSizer(0,2,2,2)
		szr.Add(box1)

		now=datetime.datetime.now()
		this_year = now.year

		label = wx.StaticText(self, -1, "Beginning Year:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.byear = wx.SpinCtrl(self, -1, "1967", min=1967, max=this_year, size=(100,-1))
		box1.Add(self.byear, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Ending Year:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.eyear = wx.SpinCtrl(self, -1, str(this_year), min=1967, max=this_year, size=(100,-1))
		box1.Add(self.eyear, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		return szr

	#----------------------------------
	def date_config(self, sitecode):

		(mindate, maxdate) = getMinMaxDates(sitecode, [self.data.project], [1,2], "co2")

		self.byear.SetValue(mindate.year)
		self.eyear.SetValue(maxdate.year)

        #------------------------------------------------------------------------
        def flaskOptions(self, box0):

                #-----
                box = wx.StaticBox(self, -1, "Flask Types")
                szr = wx.StaticBoxSizer(box, wx.VERTICAL)

                self.o1 = wx.CheckBox(self, -1, "Individual Flasks")
                self.o1.SetValue(True)
                szr.Add(self.o1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

                self.o2 = wx.CheckBox(self, -1, "Programmable Flask Package")
                self.o2.SetValue(True)
                szr.Add(self.o2, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

		return szr

        #----------------------------------
        def flask_config(self, sitecode):

		result = getStrategies(sitecode, [self.data.project])

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


	#----------------------------------
	def ok(self, event):

		self.data.stacode = self.getStationCode()
		self.data.sitenum = dbutils.getSiteNum(self.data.stacode)

		self.data.byear = self.byear.GetValue()
		self.data.eyear = self.eyear.GetValue()

		self.data.useFlask = self.o1.GetValue()
		self.data.usePFP = self.o2.GetValue()

		if not self.data.useFlask and not self.data.usePFP:
			msg = "Must select at least one flask type."
			dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
			dlg.ShowModal()
			dlg.Destroy()
			return

		self.data.parameter_list = []

		for i in self.parambox.GetSelections():
			s = self.parambox.GetString(i)
			(formula,name) = s.split('-', 1)
			formula = formula.strip()
			paramnum = dbutils.getGasNum(formula)
			self.data.parameter_list.append(paramnum)

		self.EndModal(wx.ID_OK)
