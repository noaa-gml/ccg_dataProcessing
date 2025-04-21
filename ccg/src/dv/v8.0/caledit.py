#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Driver for the caledit program.

This allows caledit to be run standalone, instead
of being called from dv.py
"""

import os
import sys
import wx

sys.path.append("/ccg/src/python3/lib")

from caledit.calib import calRaw

##################################################################################
class MyApp(wx.App):
    def OnInit(self):
        frame = calRaw(None, -1, "Tank Cal Raw File Edit")
        frame.CenterOnScreen()
        frame.Show(True)
        self.SetTopWindow(frame)
        return True

##################################################################################
if __name__ == '__main__':

    app = MyApp(0)
    app.MainLoop()
