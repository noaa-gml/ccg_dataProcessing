#!/usr/bin/env python


import wx
from ccgvu import *

##################################################################################
class MyApp(wx.App):
        def OnInit(self):
                frame = Ccgvu(None, -1, "CCGVU")
                frame.Show(True)
                self.SetTopWindow(frame)
                return True

##################################################################################

app = MyApp(0)
app.MainLoop()

