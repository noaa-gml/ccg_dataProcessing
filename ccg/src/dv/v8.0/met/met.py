#!/usr/bin/env python

import wx

from metdata import MetEdit

##################################################################################
class MyApp(wx.App):
	def OnInit(self):
		frame = MetEdit(None, -1, "Met Data")
		frame.CenterOnScreen()
		frame.Show(True)
		self.SetTopWindow(frame)
		return True

##################################################################################
if __name__ == '__main__':

	app = MyApp(0)
	app.MainLoop()
