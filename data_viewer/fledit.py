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

from fledit.flask import flRaw


##################################################################################
class MyApp(wx.App):
    def OnInit(self):
        frame = flRaw(None, -1, "Flask Raw File Edit")
        frame.CenterOnScreen()
        frame.Show(True)
        self.SetTopWindow(frame)
        return True

##################################################################################
if __name__ == '__main__':

    app = MyApp(0)
    app.MainLoop()
