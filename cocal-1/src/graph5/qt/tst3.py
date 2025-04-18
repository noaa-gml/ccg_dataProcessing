
import wx

#---------------------------------------------------------------------------

class TestPopup(wx.PopupWindow):
    """Adds a bit of text and mouse movement to the wx.PopupWindow"""
    def __init__(self, parent, style):
        wx.PopupWindow.__init__(self, parent, style)
        self.SetBackgroundColour("CADET BLUE")

        st = wx.StaticText(self, -1,
                          "This is a special kind of top level\n"
                          "window that can be used for\n"
                          "popup menus, combobox popups\n"
                          "and such.\n\n"
                          "Try positioning the demo near\n"
                          "the bottom of the screen and \n"
                          "hit the button again.\n\n"
                          "In this demo this window can\n"
                          "be dragged with the left button\n"
                          "and closed with the right."
                          ,
                          pos=(10,10))

        sz = st.GetBestSize()
        self.SetSize( (sz.width+20, sz.height+20) )

#        self.Bind(wx.EVT_LEFT_DOWN, self.OnMouseLeftDown)
#        self.Bind(wx.EVT_MOTION, self.OnMouseMotion)
#        self.Bind(wx.EVT_LEFT_UP, self.OnMouseLeftUp)
#        self.Bind(wx.EVT_RIGHT_UP, self.OnRightUp)

#        st.Bind(wx.EVT_LEFT_DOWN, self.OnMouseLeftDown)
#        st.Bind(wx.EVT_MOTION, self.OnMouseMotion)
#        st.Bind(wx.EVT_LEFT_UP, self.OnMouseLeftUp)
#        st.Bind(wx.EVT_RIGHT_UP, self.OnRightUp)

        wx.CallAfter(self.Refresh)

    def OnMouseLeftDown(self, evt):
        self.Refresh()
        self.ldPos = evt.GetEventObject().ClientToScreen(evt.GetPosition())
        self.wPos = self.ClientToScreen((0,0))
        self.CaptureMouse()

    def OnMouseMotion(self, evt):
        if evt.Dragging() and evt.LeftIsDown():
            dPos = evt.GetEventObject().ClientToScreen(evt.GetPosition())
            nPos = (self.wPos.x + (dPos.x - self.ldPos.x),
                    self.wPos.y + (dPos.y - self.ldPos.y))
            self.Move(nPos)

    def OnMouseLeftUp(self, evt):
        self.ReleaseMouse()

    def OnRightUp(self, evt):
        self.Show(False)
        self.Destroy()

#---------------------------------------------------------------------------
class TestPanel(wx.Panel):
    def __init__(self, parent):
        wx.Panel.__init__(self, parent, -1)

        self.Bind(wx.EVT_LEFT_DOWN, self.OnShowPopup)

    def OnShowPopup(self, evt):
	x,y = evt.GetPosition()
        win = TestPopup(self, wx.SIMPLE_BORDER)
        #win = TestPopupWithListbox(self, wx.SIMPLE_BORDER, self.log)

#        btn = evt.GetEventObject()
#        pos = btn.ClientToScreen( (0,0) )
#        sz =  btn.GetSize()
#        win.Position(pos, (0, sz[1]))
	wPos = self.ClientToScreen((x,y))
        win.Move(wPos)
        win.Show(True)


################################################################
class MainApp(wx.App):
        def OnInit(self):
                frame = wx.Frame(None, -1, "tst2", size=(700,500))
                self.panel = wx.Panel(frame, -1)
		self.popup = TestPopup(self.panel, wx.SIMPLE_BORDER)

		self.Bind(wx.EVT_LEFT_DOWN, self.OnShowPopup)
		self.Bind(wx.EVT_MOTION, self.OnMouseMotion)
		self.Bind(wx.EVT_LEFT_UP, self.OnLeftUp)

                frame.Show()
		return True

	def OnShowPopup(self, evt):
		x,y = evt.GetPosition()
#		win = TestPopup(self.panel, wx.SIMPLE_BORDER)
		wPos = self.panel.ClientToScreen((x,y))
#		win.Move(wPos)
#		win.Show(True)
		self.popup.Move(wPos)
		self.popup.Show(True)

	def OnMouseMotion(self, evt):
		x,y = evt.GetPosition()
		if evt.Dragging() and evt.LeftIsDown():
			wPos = self.panel.ClientToScreen((x,y))
			self.popup.Move(wPos)

	def OnLeftUp(self, evt):
		self.popup.Show(False)
#		self.popup.Destroy()

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()




havePopupWindow = 1
if wx.Platform == '__WXMAC__':
    havePopupWindow = 0
    wx.PopupWindow = wx.PopupTransientWindow = wx.Window

