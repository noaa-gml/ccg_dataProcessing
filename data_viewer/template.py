

import os
import wx

import glob

#import datetime

#from common.utils import *


##########################################################################
class MblDialog(wx.Dialog):
	def __init__(self, parent=None, title="Import MBL Data", graph=None):
		wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

		self.graph = graph

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		sizer = self.mkSource(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkZones(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkLatitudeRange(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkBootstrap(box0)
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


	#----------------------------------
	def mkSource(self, box0):

		box = wx.StaticBox(self, -1, "Data Source")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

                label = wx.StaticText(self, -1, "Latest Web Run:")
                sizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 1)

		web_options = []
		for gas in ["co2", "ch4", "co", "n2o", "sf6", "co2c13"]:
			dir_pattern = "/ccg/dei/ext/%s/web/results.web.2???-??/" % gas
                        dirs = glob.glob(dir_pattern)
                        last_dir = sorted(dirs)[-1]
			s = gas.upper() + " - " + last_dir
			web_options.append(s)
		self.web_choice = wx.Choice(self, -1, choices=web_options)
		sizer.Add(self.web_choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

                label = wx.StaticText(self, -1, "OR")
                sizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 10)


                label = wx.StaticText(self, -1, "DEI Directory:")
                sizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 1)

                self.dp2 = wx.DirPickerCtrl(self, size=(800, -1), style=wx.DIRP_USE_TEXTCTRL)
                self.dp2.SetTextCtrlProportion(1)
                sizer.Add(self.dp2, 1, wx.ALIGN_LEFT|wx.GROW|wx.ALL, 1)


		return sizer

	#----------------------------------
	def mkZones(self, box0):

		# First static box sizer
		box = wx.StaticBox(self, -1, "Zones")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

		box1 = wx.BoxSizer(wx.HORIZONTAL)
		sizer.Add(box1, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL)

		label = wx.StaticText(self, -1, "Reference Type")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


		zonal_options = [ 
			u"Global (90\u00b0S to 90\u00b0N)",
			u"Northern Hemisphere (0\u00b0 to 90\u00b0N)",
			u"Southern Hemisphere (90\u00b0S to 0\u00b0)",
			u"Arctic (58.2\u00b0N to 90\u00b0N)",
			u"Polar Northern Hemisphere (53.1\u00b0N to 90\u00b0N)",
			u"High Northern Hemisphere (30\u00b0N to 90\u00b0N)",
			u"Temperate Northern Hemisphere (17.5\u00b0N to 53.1\u00b0N)",
			u"Low Northern Hemisphere (0\u00b0 to 30\u00b0N)",
			u"Tropics (17.5\u00b0S to 17.5\u00b0N)",
			u"Equatorial (14.5\u00b0S to 14.5\u00b0N)",
			u"Low Southern Hemisphere (30\u00b0S to 0\u00b0)",
			u"Temperate Southern Hemisphere (53.1\u00b0S to 17.5\u00b0S)",
			u"High Southern Hemisphere (90\u00b0S to 30\u00b0S)",
			u"Polar Southern Hemisphere (90\u00b0S to 53.1\u00b0S)",
			u"Custom",
		]


		self.choice = wx.Choice(self, -1, choices=zonal_options)
		box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		self.choice.Bind(wx.EVT_CHOICE, self.zone)


		return sizer


	#----------------------------------
	def mkBootstrap(self, box0):

		# First static box sizer
		box = wx.StaticBox(self, -1, "Bootstrap Runs")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

		self.cb = wx.CheckBox(self, -1, "Use Bootstrap Results")
		sizer.Add(self.cb, 0, wx.ALL, 5)

		rbList = ["Atmospheric", "Network", "Measurement Bias"]

		self.bs = wx.RadioBox(
                        self, -1, "", wx.DefaultPosition, wx.DefaultSize,
                        rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
                        )
                sizer.Add(self.bs, 0, wx.LEFT, 20)

		label = wx.StaticText(self, -1, "Optional bootstrap results directory (leave blank to use default)")
		sizer.Add(label, 0, wx.TOP, 10)

		self.bsdir = wx.TextCtrl(self, -1)
		sizer.Add(self.bsdir, 1, wx.GROW|wx.LEFT, 20)


		return sizer

	#----------------------------------
	def mkLatitudeRange(self, box0):

		self.latbox = wx.StaticBox(self, -1, "Custom Latitude Range")
		szr = wx.StaticBoxSizer(self.latbox, wx.VERTICAL)

		box1 = wx.FlexGridSizer(0,2,2,2)
		szr.Add(box1)

		self.label1 = wx.StaticText(self, -1, "Minimum")
		box1.Add(self.label1, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		self.minlat = wx.TextCtrl(self, -1, "-90")
		box1.Add(self.minlat, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		self.label2 = wx.StaticText(self, -1, "Maximum")
		box1.Add(self.label2, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		self.maxlat = wx.TextCtrl(self, -1, "90")
		box1.Add(self.maxlat, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		self.minlat.Enable(False)
		self.maxlat.Enable(False)
		self.latbox.Enable(False)
		self.label1.Enable(False)
		self.label2.Enable(False)

		return szr


	#----------------------------------
	def zone(self, event):
		""" If 'custom' zone is chosen, enable the
		latitude range boxes, otherwise disable them.
		"""

		reftype = self.choice.GetStringSelection()
		if reftype == "Custom":
			self.minlat.Enable(True)
			self.maxlat.Enable(True)
			self.latbox.Enable(True)
			self.label1.Enable(True)
			self.label2.Enable(True)
		else:
			self.minlat.Enable(False)
			self.maxlat.Enable(False)
			self.latbox.Enable(False)
			self.label1.Enable(False)
			self.label2.Enable(False)



	#----------------------------------
	def ok(self, event):

		s = self.web_choice.GetStringSelection()
		(gas, deidir) = s.split("-", 1)
		self.deidir = deidir.strip()
		self.param = gas.strip().lower()

		s = self.dp2.GetPath()
		print "dp2 is", s
		if len(s):

			if not os.path.exists(s):
				dlg = wx.MessageDialog(self, "DEI Directory does not exist.", 'A Message Box', wx.OK | wx.ICON_ERROR)
				dlg.ShowModal()
				dlg.Destroy()
				return




			self.deidir = s
			files = glob.glob(s + "/surface.mbl.*")
			if len(files):
				f = files[0]
				print "surface mfl file is ", f
				f = os.path.basename(f)
				(a, b, gas) = f.split(".")

				self.param = gas.strip().lower()


		self.bootstrap_dir = self.bsdir.GetValue()


		self.zone = self.choice.GetStringSelection()
#		print zone

#		param = self.param_choice.GetStringSelection()
#		(formula, name) = param.split("-", 1)
#		self.param = formula.strip().lower()
#		print param

		self.min_latitude = float(self.minlat.GetValue())
		self.max_latitude = float(self.maxlat.GetValue())

		self.use_bootstrap = self.cb.GetValue()
		print self.use_bootstrap

		s = self.bs.GetStringSelection()
		if "bias" in s.lower():
			s = "bias"
		self.bootstrap = s
		print self.bootstrap

		self.EndModal(wx.ID_OK)


