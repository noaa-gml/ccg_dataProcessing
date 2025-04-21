#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Driver for the fledit program.

This allows fledit to be run standalone, instead
of being called from dv.py
"""

import os
import sys
import wx

sys.path.insert(1, "/ccg/src/python3/lib")

from dei.dei import Dei


##################################################################################
class MyApp(wx.App):
    def OnInit(self):
        frame = Dei(None, -1, "Data Extension Viewer")
#        frame.CenterOnScreen()
#        frame.Show(True)
        self.SetTopWindow(frame)
        return True

##################################################################################
if __name__ == '__main__':

    app = MyApp(0)
    app.MainLoop()
