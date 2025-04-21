#!/usr/bin/env python
""" Startup script for the insitu editing program """

import sys
import wx

sys.path.insert(1, "/ccg/src/python3/nextgen")
sys.path.insert(1, "/ccg/python/ccglib")


from isedit.insitu import InsituEdit


##################################################################################
class MyApp(wx.App):
    """ Create wx app """

    def OnInit(self):
        """ Create the main window and start it up """

        frame = InsituEdit(None, -1, "In-Situ Edit")
        frame.CenterOnScreen()
        frame.Show(True)
        self.SetTopWindow(frame)
        return True

##################################################################################
if __name__ == '__main__':

    app = MyApp(0)
    app.MainLoop()
