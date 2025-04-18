
import os
import wx
import subprocess

import panel_config as config
from panel_utils import *

#--------------------------------------------------------------
class mkStartPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.parent = parent
        self.gas = gas
        self.t2 = wx.Timer(self)

        box = wx.StaticBox(self, -1, "Start System", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.SetSizer(sizer)
        self.title = wx.StaticText(self, -1, "Start System.")
        self.title.SetFont(wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_BOLD))
        self.title.SetForegroundColour(wx.BLUE)
        sizer.Add(self.title, 0, wx.ALL, 5)

        self.startButton = wx.Button(self, wx.ID_OK)
        self.startButton.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.start, self.startButton)

        sizer.Add(self.startButton, 0, wx.ALIGN_CENTRE|wx.ALL, 50)
        self.Bind(wx.EVT_TIMER, self.refreshPage)

    #--------------------------------------------------------------
    def start(self, evt):

        global child

        cmd = "/".join([config.sysdir, "bin/start"])
        print(cmd)
    #    os.system(cmd)
        config.child = subprocess.Popen(cmd, shell=True)

        self.updatePage()

    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()


    #--------------------------------------------------------------
    def updatePage(self):

        if self.IsShownOnScreen():
            if getSysRunning():
                s = "The %s System has been started." % self.gas
                self.title.SetLabel(s)
                self.startButton.Disable()
            else:
                s = "Confirm that you want to start the %s System." % self.gas
                self.title.SetLabel(s)
                self.startButton.Enable()

            self.t2.Start(1000)

        else:
            self.t2.Stop()

