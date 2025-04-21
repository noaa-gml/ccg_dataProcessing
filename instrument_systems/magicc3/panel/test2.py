
import os
import wx

#--------------------------------------------------------------
class mkStartPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas

        box = wx.StaticBox(self, -1, "Start System")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.SetSizer(sizer)
        self.title = wx.StaticText(self, -1, "Start System.")
        self.title.SetFont(wx.Font(12, wx.SWISS, wx.NORMAL, wx.ITALIC))
	self.title.SetForegroundColour(wx.BLUE)
        sizer.Add(self.title, 0, wx.ALL, 5)

        self.startButton = wx.Button(self, wx.ID_OK)
        self.startButton.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.start, self.startButton)

        sizer.Add(self.startButton, 0, wx.ALIGN_CENTRE|wx.ALL, 50)

    #--------------------------------------------------------------
    def start(self, evt):

	s = "The %s System has been started." % self.gas
	self.title.SetLabel(s)
	self.startButton.Disable()
	

    #--------------------------------------------------------------
    def updatePage(self):

	if getSysRunning(self.gas):
                s = "The %s System has been started." % self.gas
		self.title.SetLabel(s)
		self.startButton.Disable()
	else:

		s = "Confirm that you want to start the %s System." % self.gas
		self.title.SetLabel(s)
		self.startButton.Enable()
