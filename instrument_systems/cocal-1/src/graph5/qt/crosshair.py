""" Crosshair class

    A Crosshair is a pair of lines drawn on the graph that intersect at the
    mouse position.  The lines are draw only inside the plotting area.
    The user can modify the color, style and width of the crosshair lines.

    Associated with the crosshair is a popup window that shows the 
    coordinates of the crosshair in user units of the graph.  

    There is also an additional popup window (PointLabelPopup) that gives the 
    x and y values of the data point closest to the mouse.
"""

from PyQt4 import QtGui, QtCore

#from dataset import num2date
from pen import Pen
from font import Font
from datenum import num2date

#####################################################################
class Crosshair():
    """ Crosshair widget for graph. """

    def __init__(self, parent):

	self.graph = parent
        self.show = 1
        self.width = 1
#        self.style = wx.SOLID
 #       if "WXMAC" in wx.Platform:
#		self.color = wx.Colour(255, 255, 255)
#	else:
#		self.color = wx.Colour(128, 128, 128)
	self.color = QtGui.QColor(128,128,128)
        self._set_pen()
	self.x = 0
	self.y = 0
	self.show_label = True
	self.xoffset = 10
	self.yoffset = 10

	self.font = Font()


    def _set_pen(self):
        """ Since we draw the crosshair using XOR, we need to invert the colors
            to get them to display the requested color.
        """
#	color = self.color
 #       width = self.width
  #      style = self.style
   #     self.pen = wx.Pen(color, width, style)
        p = Pen(self.color, self.width) # , self.style)
	self.pen = p.qtPen()

    def setPosition(self, x, y):
	self.x = x
	self.y = y

    def draw(self, x, y):
        """ Draw the crosshair.  Keep the lines inside the plotting area. """

#	print "-----"
#	print self.graph.xleft, self.graph.xright, self.graph.ytop, self.graph.ybottom
#	print x, y

	qp = QtGui.QPainter(self.graph.image)
#	qp.begin(self.graph.image)

        qp.setPen(self.pen)
#        qp.SetLogicalFunction(wx.XOR)
	qp.setCompositionMode(QtGui.QPainter.RasterOp_SourceXorDestination)
	qp.drawLine(self.graph.xleft, y, self.graph.xright, y) 
	qp.drawLine(x, self.graph.ytop, x, self.graph.ybottom)

#	if self.show_label:
		
#		qp.setFont(Font(18).qtFont())
#		qp.drawText(x, y, "this is a test")
#		self.graph.label.setText("%s, %s" % (x, y))
#		self.graph.label.setGeometry(x+self.xoffset, y + self.yoffset, 100,30)

#	qp.end()

    def setCrosshairStyle(self, color, width, style):
        """ Set the crosshair color and style. """
        self.color = color
        self.width = width
        self.style = style
	self._set_pen()
#        self.pen = wx.Pen(self.color, self.width, self.style)


#####################################################################3333
class CrosshairPopup(QtGui.QLabel):
    """Show coordinates of crosshair in user units in a popup window"""

    def __init__(self, parent):
	super(CrosshairPopup, self).__init__(parent)

#        self.st = wx.StaticText(self, -1, "" , pos=(0, 0))
	self.graph = parent

        self.format = "normal"
        self.fg_color = QtGui.QColor(0, 0, 0)
#        self.st.SetForegroundColour(self.fg_color)
        self.bg_color = QtGui.QColor(209, 243, 247)
#        self.SetBackgroundColour(self.bg_color)
	pal = QtGui.QPalette();
 
	pal.setColor(QtGui.QPalette.Background, self.bg_color);
	self.setAutoFillBackground(True)
	self.setPalette(pal)

#       f = wx.Font(18, wx.ROMAN, wx.ITALIC, wx.BOLD, True)
#       f = wx.NORMAL_FONT

	self.font = Font()
	self.setFont(self.font.qtFont())
#       self.st.SetFont(f)
        self.xaxis = 0
        self.yaxis = 0

	self.xoffset = 15
	self.yoffset = 10

    def draw(self, x, y):
        """ Draw the popup window. 
            Input:
                graph - the graph 
                x, y - pixel coordinats of mouse
        """
#        wPos = self.graph.ClientToScreen((x+15, y+10))
        xax = self.graph.getXAxis(self.xaxis)
        yax = self.graph.getYAxis(self.yaxis)
        xp = self.graph.PixelToUserX (x, xax)
        yp = self.graph.PixelToUserY (y, yax)

        xs = "%.3f" % xp
        ys = "%.3f" % yp

        if xax.scale_type == "date":
            # convert val to calendar date
            d = num2date(xp)
            xs = d.strftime("%Y-%m-%d %H:%M:%S")

        if yax.scale_type == "date":
            # convert val to calendar date
            d = num2date(yp)
            ys = d.strftime("%Y-%m-%d %H:%M:%S")

        s = "%s, %s" % (xs, ys)

        self.setText(s)
	(w,h) = self.font.getSize(s)
#        sz = self.st.GetBestSize()
        # Set the location and size of the popup window
        self.setGeometry(x + self.xoffset, y+self.yoffset, w+4, h+2)  # sz.width+1, sz.height+1)

