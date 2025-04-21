#!/usr/bin/python

# experimenting with wxPython's DrawRectangle()
# the rectangle is filled with the brush color
# tested with Python24 and wxPython26     vegaseat    19oct2005

import wx

import sys
import os


################################################################
class MainFrame(wx.Frame):
	def __init__(self, parent, ID, title):
		wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(-1, -1))

		sizer = wx.BoxSizer(wx.VERTICAL)

		txt = wx.StaticText(self, -1, msg, style=wx.ALIGN_CENTER)
		font = wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
		txt.SetFont(font)
		sizer.Add(txt, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_CENTER_HORIZONTAL|wx.TOP, 10)

		if doPrompt:
			sizer2 = wx.BoxSizer(wx.HORIZONTAL)
			txt = wx.StaticText(self, -1, prompt_string, style=wx.ALIGN_RIGHT)
			self.tc = wx.TextCtrl(self, -1, text_string)
			sizer2.Add(txt, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALL, 10)
			sizer2.Add(self.tc, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALL, 10)
			sizer.Add(sizer2)

		line = wx.StaticLine(self, -1, size=(-1,-1), style=wx.LI_HORIZONTAL)
		sizer.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)

		btnsizer = wx.BoxSizer(wx.HORIZONTAL)

		btn = wx.Button(self, wx.ID_OK)
		btnsizer.Add(btn, 0, wx.LEFT|wx.RIGHT, 10)
		self.Bind(wx.EVT_BUTTON, self.ok, btn)

		if stopbutton:
			btn = wx.Button(self, wx.ID_STOP)
			btnsizer.Add(btn, 0, wx.LEFT|wx.RIGHT, 10)
			self.Bind(wx.EVT_BUTTON, self.stop, btn)

		sizer.Add(btnsizer, 0, wx.ALIGN_BOTTOM|wx.ALIGN_CENTER_HORIZONTAL|wx.ALL, 5)

		self.SetSizerAndFit(sizer)



	def ok(self, evt):
		f = open(".cont", "w")
		f.close()

		s = ""
		if doPrompt:
			s = self.tc.GetValue()

		print "continue", s
		sys.exit()

	def stop(self, evt):
		f = open(".stop", "w")
		f.close()

		print "stop"
		sys.exit()


##################################################################################
class MyApp(wx.App):
    def OnInit(self):
        frame = MainFrame(None, -1, "ISCP")
        frame.CenterOnScreen()
        frame.Show(True)
        self.SetTopWindow(frame)
        return True

##################################################################################
if __name__ == '__main__':

	stopbutton = True
	doPrompt = False
	text_string = ""

	try:
		os.remove(".cont")
	except:
		pass
	try:
		os.remove(".stop")
	except:
		pass

#	msg = sys.stdin.read().strip("\n")
	msg = sys.stdin.read()
#	print msg

	for n, argv in enumerate(sys.argv):
		if argv == "-nostop":
			stopbutton = False

		if argv == "-prompt":
			doPrompt = True
			prompt_string = sys.argv[n+1]

		if argv == "-text":
			text_string = sys.argv[n+1]

	app = MyApp(0)
	app.MainLoop()
