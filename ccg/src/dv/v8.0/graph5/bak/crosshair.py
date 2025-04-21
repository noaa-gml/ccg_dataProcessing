
import wx

class CrosshairPopup(wx.PopupWindow):
    """Adds a bit of text and mouse movement to the wx.PopupWindow"""
    def __init__(self, parent, style):
        wx.PopupWindow.__init__(self, parent, style)
        self.SetBackgroundColour(wx.Colour(176,226,255))

        self.st = wx.StaticText(self, -1, "" ,
                          pos=(0,0), style=wx.BORDER_SIMPLE)

#        sz = self.st.GetBestSize()
#        self.SetSize( (sz.width, sz.height+10) )
#	self.SetWindowStyle(wx.BORDER_SIMPLE)
#	self.st.SetWindowStyle(wx.BORDER_SIMPLE)


#####################################################################3333
class Crosshair:

    def __init__(self, graph):
	self.show = 1
	self.pen = wx.Pen(wx.Colour(0,0,0),1,wx.SOLID)
	self.SetColor(128,128,128)
	self.width = 1
	self.popup = CrosshairPopup(graph, wx.BORDER_DOUBLE)

    def SetColor(self, red, green, blue):
	newblue = 255-blue
	newred = 255-red
	newgreen = 255-green
	color = wx.Colour(newred, newgreen, newblue)
	width = self.pen.GetWidth()
	style = self.pen.GetStyle()
	self.pen=wx.Pen(color, width, style)


    def draw(self,graph,event):
	x,y = event.GetPosition()
	dc = wx.ClientDC( graph )

        dc.SetPen(self.pen)
        dc.SetLogicalFunction(wx.XOR)
	dc.DrawLine (graph.xleft, graph.lasty, graph.xright, graph.lasty)
	dc.DrawLine (graph.lastx, graph.ytop, graph.lastx, graph.ybottom)

	axis = graph.getXAxis(graph.grid_xaxis)
	xp = graph.PixelToUserX (x,axis)
	axis = graph.getYAxis(graph.grid_yaxis)
	yp = graph.PixelToUserY (y,axis)
	s = "%.3f, %.3f" % (xp,yp)
	self.popup.st.SetLabel(s)
	sz = self.popup.st.GetBestSize()
	self.popup.SetSize( (sz.width+1, sz.height+1) )
	wPos = graph.ClientToScreen((x+4,y+4))
        self.popup.Move(wPos)
	self.popup.Show(True)

    def hide (self):
	self.popup.Show(False)
