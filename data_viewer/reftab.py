#!/usr/bin/env python

import sys
#import pwd

import wx
from reftab.scale import Scale

##################################################################################
class MyApp(wx.App):
        def OnInit(self):
                frame = Scale(None, -1, "Reference Gas Tables")
                frame.Show(True)
                self.SetTopWindow(frame)
                return True

##################################################################################

#username = pwd.getpwuid(os.getuid()).pw_name
#print username

app = MyApp(0)
app.MainLoop()

