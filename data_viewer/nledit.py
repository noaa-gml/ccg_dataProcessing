#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Driver for running nledit as standalone app
"""

import wx

from nledit.nlclass import nlEdit

##################################################################################
class MyApp(wx.App):
	""" wx app for viewing response curve raw files """

	def OnInit(self):
		""" inititialize """

		frame = nlEdit(None, -1, "Nl Response Curve Raw File Edit")
		frame.CenterOnScreen()
		frame.Show(True)
		self.SetTopWindow(frame)
		return True

##################################################################################
if __name__ == '__main__':

	app = MyApp(0)
	app.MainLoop()
