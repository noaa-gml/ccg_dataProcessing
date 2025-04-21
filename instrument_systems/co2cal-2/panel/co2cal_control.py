

import sys

import wx

import panel_config
from panel_utils import *


sys.path.append("%s/src/python" % (panel_config.sysdir))
from runaction import *

sampleselectvalve = [
	"Sample Port 1",
	"Sample Port 2",
	"Sample Port 3",
	"Sample Port 4",
	"Sample Port 5",
	"Sample Port 6",
	"Sample Port 7",
	"Sample Port 8",
	"Sample Port 9",
	"Sample Port 10",
	"Sample Port 11",
	"Sample Port 12",
	"Sample Port 13",
	"Sample Port 14",
	"Sample Port 15",
	"Sample Port 16",
]

referenceselectvalve = [
	"Reference On (1)",
	"Reference Off (2)",
	"Standards On (3)",
	"Standards Off (4)",
	"Samples On (5)",
	"Samples Off (6)",
	"Zero On (7)",
	"Zero Off (8)",
]

systemselectvalve = [
	"Vent On (1)",
	"Vent Off (2)",
	"LGR On (3)",
	"LGR Off (4)",
	"Picarro On (5)",
	"Picarro Off (6)",
	"NDIR On (7)",
	"NDIR Off (8)",
]

HOMEDIR    = panel_config.sysdir                         # Our home
CONFFILE   = HOMEDIR + "/co2cal.conf"                      # hm configuration file
ACTIONDIR  = HOMEDIR + "/actions"                       # Action directory


#--------------------------------------------------------------
class mkControlPage(wx.Panel):

    def __init__(self, parent, gas):
	wx.Panel.__init__(self, parent, -1)

        self.action = RunAction(actiondir=ACTIONDIR, configfile=CONFFILE, testMode=False)



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

        title = wx.StaticText(self, -1, "Reference Select Valve Position")
        title.SetFont(font)
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.LEFT, 10)

	self.refvalve = wx.Choice(self, -1, choices=referenceselectvalve)
        sizer.Add(self.refvalve, 0, wx.ALIGN_CENTRE|wx.BOTTOM, 25)
	self.Bind(wx.EVT_CHOICE, self.setRefSelect, self.refvalve)

        title = wx.StaticText(self, -1, "System Select Valve Position")
        title.SetFont(font)
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.LEFT, 10)

	self.sysvalve = wx.Choice(self, -1, choices=systemselectvalve)
        sizer.Add(self.sysvalve, 0, wx.ALIGN_CENTRE|wx.BOTTOM, 25)
	self.Bind(wx.EVT_CHOICE, self.setSystemSelect, self.sysvalve)


    #----------------------------------------------
    def updatePage(self):

        if self.IsShownOnScreen():
		self.action.run("startup.act")


    #-------------------------------------------------------------------
    def setSampleSelect(self, evt):

	s = evt.GetString()
	position = sampleselectvalve.index(s) + 1
	print(position)
	self.action.run("sample_select.act", position)

    #-------------------------------------------------------------------
    def setSystemSelect(self, evt):

	s = evt.GetString()
	position = systemselectvalve.index(s) + 1
	print(position)
	self.action.run("system_select.act", position)

    #-------------------------------------------------------------------
    def setRefSelect(self, evt):

	s = evt.GetString()
	position = referenceselectvalve.index(s) + 1
	print(position)
	self.action.run("reference_select.act", position)


    #-------------------------------------------------------------------
    def doAction(self, on, options):

	if on:
		actionfile = "closerelay.act"
	else:
		actionfile = "openrelay.act"

	self.action.run(actionfile, options)


