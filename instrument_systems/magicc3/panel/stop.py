

import os
import wx

import panel_config as config
from panel_utils import *

#--------------------------------------------------------------
class mkStopPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.gas = gas
        self.t2 = wx.Timer(self)

        box = wx.StaticBox(self, -1, "Stop System", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.SetSizer(sizer)
        self.title = wx.StaticText(self, -1, "Stop System.")
        self.title.SetFont(wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_BOLD))
        self.title.SetForegroundColour(wx.BLUE)
        sizer.Add(self.title, 0, wx.ALL, 5)

        self.stopButton = wx.Button(self, wx.ID_STOP)
        self.stopButton.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.stop, self.stopButton)

        sizer.Add(self.stopButton, 0, wx.ALIGN_CENTRE|wx.ALL, 50)
        self.Bind(wx.EVT_TIMER, self.refreshPage)

    #--------------------------------------------------------------
    def stop(self, evt):

        #cmd = "/".join([config.sysdir, self.gas.lower(), "bin/stop"])
        cmd = "/".join([config.sysdir, "bin/stop"])
        print(cmd)
        os.system(cmd)

        self.updatePage()

    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()


    #--------------------------------------------------------------
    def updatePage(self):

        if self.IsShownOnScreen():
#        if not (getSysRunning() or getSysScheduled(self.gas)):
            if not (getSysRunning()):
                s = "The %s System has been stopped." % self.gas
                self.title.SetLabel(s)
                self.stopButton.Disable()
            else:
                s = "Confirm that you want to stop the %s System." % self.gas
                self.title.SetLabel(s)
                self.stopButton.Enable()

                self.t2.Start(1000)

        else:
            self.t2.Stop()

