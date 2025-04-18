#!/usr/bin/env python


import wx
from gcplot.main import GCPlot


##################################################################################
class MyApp(wx.App):
	def OnInit(self):
		frame = GCPlot(None, -1, "GCPlot")
		frame.Show(True)
		self.SetTopWindow(frame)
		return True

##################################################################################

app = MyApp(0)
app.MainLoop()
