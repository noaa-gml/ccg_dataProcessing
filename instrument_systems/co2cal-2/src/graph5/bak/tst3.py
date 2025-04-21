
# experimenting with wxPython's DrawRectangle()
# the rectangle is filled with the brush color
# tested with Python24 and wxPython26     vegaseat    19oct2005

import wx
import time

import sys
sys.path.append("graph")
sys.path.append(".")


from scipy.special import jn


#####################################################################3333
class Graph(wx.Window):

    def __init__(self, *args, **kwargs):
        """Constructs a panel, which can be a child of a frame or
        any other non-control window"""

        wx.Window.__init__(self, *args, **kwargs)

	c = self.GetBackgroundColour()

	self.margin = 10
	self.plotareaColor = wx.Colour(255,255,255)
	self.backgroundColor = c

	self.xleft = 50
	self.ytop = 50
	self.plot_width = 200
	self.plot_height = 200

	self.foo = 0

        # set curser as cross-hairs
        self.SetCursor(wx.CROSS_CURSOR)

        # Create some mouse events for zooming
        self.Bind(wx.EVT_LEFT_DOWN, self.OnMouseLeftDown)
#        self.Bind(wx.EVT_LEFT_UP, self.OnMouseLeftUp)
#        self.Bind(wx.EVT_MOTION, self.OnMotion)
#        self.Bind(wx.EVT_LEFT_DCLICK, self.OnMouseDoubleClick)
#        self.Bind(wx.EVT_RIGHT_DOWN, self.OnMouseRightDown)
#        self.Bind(wx.EVT_RIGHT_UP, self.OnMouseRightUp)

        # OnSize called to make sure the buffer is initialized.
        # This might result in OnSize getting called twice on some
        # platforms at initialization, but little harm done.
#        self.OnSize(None) # sets the initial size based on client size
        Size  = self.GetClientSize()
        Size.width = max(1, Size.width)
        Size.height = max(1, Size.height)
	self.width=Size.width
	self.height = Size.height
        self._Buffer = wx.EmptyBitmap(Size.width, Size.height)

	self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_SIZE, self.OnSize)

    ############################################################################
    # Redraw the graph
    #---------------------------------------------------------------------------
    def update(self):
#	self.OnSize(None)
	self._draw()
	print "update"
	self.OnPaint(wx.PaintEvent())
#        dc = wx.BufferedPaintDC(self, self._Buffer)
#	wx.BufferedDC(self.dc, self._Buffer)

    #---------------------------------------------------------------------------
    def OnSize(self,event):
        # The Buffer init is done here, to make sure the buffer is always
        # the same size as the Window
        Size  = self.GetClientSize()
        Size.width = max(1, Size.width)
        Size.height = max(1, Size.height)
	self._setSize(Size.width, Size.height)

	print "size event"

        # Make new offscreen bitmap: this bitmap will always have the
        # current drawing in it, so it can be used to save the image to
        # a file, or whatever.
        self._Buffer = wx.EmptyBitmap(Size.width, Size.height)
	self._draw()

    #---------------------------------------------------------------------------
    def OnPaint(self, event):
        # All that is needed here is to draw the buffer to screen
	print "got paint event"
        dc = wx.BufferedPaintDC(self, self._Buffer)

    ############################################################################
    # Routines dealing with drawing the graph
    #---------------------------------------------------------------------------
    def _draw(self, dc=None):

        if dc == None:
		dc = wx.BufferedDC(wx.ClientDC(self), self._Buffer)
		dc.Clear()
	else:
		dc = dc

#        self.dc.BeginDrawing()

	# Fill the window with background color
        dc.SetPen(wx.Pen(wx.BLACK))
        dc.SetBrush(wx.Brush(self.backgroundColor, wx.SOLID))
	dc.DrawRectangle(0, 0, self.width, self.height)
	
        dc.SetBrush(wx.Brush(self.plotareaColor, wx.SOLID))
	dc.DrawRectangle(self.xleft, self.ytop, self.plot_width+1, self.plot_height+1)
	if self.foo:
		dc.SetBrush(wx.Brush(wx.Colour(255,0,0), wx.SOLID))
		dc.DrawRectangle(300,300,50,50)

#       self.dc.EndDrawing()

    #---------------------------------------------------------------------------
    def OnMouseLeftDown(self, event):
	x,y = event.GetPosition()
	print "got mouse left down"
	self.foo = not self.foo
	self.update()

    #---------------------------------------------------------------------------
    def OnMouseLeftUp(self, event):
	x,y = event.GetPosition()
	print "got mouse left up"

    def _setSize(self, width, height):
	self.width = width
	self.height = height
        
################################################################
class MainApp(wx.App):
        def OnInit(self):
                frame = wx.Frame(None, -1, "tst2", size=(700,500))
                graph = Graph(frame)

                frame.Show()
		return True


if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

