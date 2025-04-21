
import sys


import wx

import config
from panel_utils import *

from graph.graph import Graph
from graph.dataset import Dataset

sys.path.append("%s/src/python" % (config.sysdir))
from runaction import *

sampleselectvalve = [
	"N2O Ref. On (1)",
	"N2O Ref. Off (2)",
	"CO Ref. On (3)",
	"CO Ref. Off (4)",
	"CH4 Ref. On (5)",
	"CH4 Ref. Off (6)",
	"CO2 H Ref. On (7)",
	"CO2 H Ref. On (8)",
	"CO2 L Ref. On (9)",
	"CO2 L Ref. On (10)",
	"CO2 M Ref. On (11)",
	"CO2 M Ref. On (12)",
	"Aircraft Package On (13)",
	"Aircraft Package Off (14)",
	"Flask Carousel On (15)",
	"Flask Carousel Off (16)",
]

systemselectvalve = [
	"N2O On (1)",
	"N2O Off (2)",
	"CO On (3)",
	"CO Off (4)",
	"CH4 On (5)",
	"CH4 Off (6)",
	"CO2 On (7)",
	"CO2 Off (8)",
]

HOMEDIR    = config.sysdir                         # Our home
CONFFILE   = HOMEDIR + "/magicc.conf"                      # hm configuration file
ACTIONDIR  = HOMEDIR + "/actions"                       # Action directory


#--------------------------------------------------------------
class mkControlPage(wx.Panel):

    def __init__(self, parent, gas):
	wx.Panel.__init__(self, parent, -1)

        self.action = RunAction(actiondir=ACTIONDIR, configfile=CONFFILE, testMode=True)


	self.gas = gas
        font = wx.Font(12, wx.SWISS, wx.NORMAL, wx.ITALIC)

	box = wx.StaticBox(self, -1, "Manual Control")
	sizer = wx.StaticBoxSizer(box, wx.VERTICAL)
        self.SetSizer(sizer)


        title = wx.StaticText(self, -1, "Sample Select Valve Position")
        title.SetFont(font)
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.LEFT|wx.TOP, 10)

	self.samplevalve = wx.Choice(self, -1, choices=sampleselectvalve)
        sizer.Add(self.samplevalve, 0, wx.ALIGN_CENTRE|wx.BOTTOM, 25)
	self.Bind(wx.EVT_CHOICE, self.setSampleSelect, self.samplevalve)

        title = wx.StaticText(self, -1, "System Select Valve Position")
        title.SetFont(font)
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.LEFT, 10)

	self.sysvalve = wx.Choice(self, -1, choices=systemselectvalve)
        sizer.Add(self.sysvalve, 0, wx.ALIGN_CENTRE|wx.BOTTOM, 25)
	self.Bind(wx.EVT_CHOICE, self.setSystemSelect, self.sysvalve)

        title = wx.StaticText(self, -1, "Flask Carousel Port")
        title.SetFont(font)
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.LEFT, 10)

	choices = [str(x) for x in range(1, 17)]
	self.carousel = wx.Choice(self, -1, choices=choices)
        sizer.Add(self.carousel, 0, wx.ALIGN_CENTRE|wx.BOTTOM, 25)
	self.Bind(wx.EVT_CHOICE, self.setCarousel, self.carousel)

        title = wx.StaticText(self, -1, "Standards Valve Position")
        title.SetFont(font)
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.LEFT, 10)

	choices = [str(x) for x in range(1, 17)]
	self.stds = wx.Choice(self, -1, choices=choices)
        sizer.Add(self.stds, 0, wx.ALIGN_CENTRE|wx.BOTTOM, 65)
	self.Bind(wx.EVT_CHOICE, self.setStds, self.stds)


	b1 = wx.CheckBox(self, -1, "Transfer Pump On/Off")
	sizer.Add(b1)
	self.Bind(wx.EVT_CHECKBOX, self.setPump, b1)

	b1 = wx.CheckBox(self, -1, "Carousel Evacuation On/Off")
	sizer.Add(b1)
	self.Bind(wx.EVT_CHECKBOX, self.setEvac, b1)

	b1 = wx.CheckBox(self, -1, "Aircraft Package Evacuation On/Off")
	sizer.Add(b1)
	self.Bind(wx.EVT_CHECKBOX, self.setAirEvac, b1)

	b1 = wx.CheckBox(self, -1, "Aircraft Package Outlet Valve On/Off")
	sizer.Add(b1)
	self.Bind(wx.EVT_CHECKBOX, self.setAirOutlet, b1)

    #----------------------------------------------
    def updatePage(self):

        if self.IsShownOnScreen():
		self.action.run("startup.act")


    #-------------------------------------------------------------------
    def setSampleSelect(self, evt):

	s = evt.GetString()
	position = sampleselectvalve.index(s) + 1
	print(position)
	self.action.run("sampleport.act", position)

    #-------------------------------------------------------------------
    def setSystemSelect(self, evt):

	s = evt.GetString()
	position = systemselectvalve.index(s) + 1
	print(position)
	self.action.run("systemport.act", position)

    #-------------------------------------------------------------------
    def setCarousel(self, evt):

	s = evt.GetString()
	position = int(s)
	print(position)
	self.action.run("flaskport.act", position)

    #-------------------------------------------------------------------
    def setStds(self, evt):

	s = evt.GetString()
	position = int(s)
	print(position)
	self.action.run("stdport.act", position)

    #-------------------------------------------------------------------
    def doAction(self, on, options):

	if on:
		actionfile = "closerelay.act"
	else:
		actionfile = "openrelay.act"

	self.action.run(actionfile, options)


    #-------------------------------------------------------------------
    def setPump(self, evt):

	on = evt.IsChecked()
	options = "@TransferPump"
	self.doAction(on, options)

    #-------------------------------------------------------------------
    def setEvac(self, evt):
	on = evt.IsChecked()
	options = "@EvacValve"
	self.doAction(on, options)

    #-------------------------------------------------------------------
    def setAirEvac(self, evt):
	on = evt.IsChecked()
	options = "@AircraftEvacValve"
	self.doAction(on, options)

    #-------------------------------------------------------------------
    def setAirOutlet(self, evt):
	on = evt.IsChecked()
	options = "@AircraftOutlet"
	self.doAction(on, options)
