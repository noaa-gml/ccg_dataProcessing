# vim: tabstop=4 shiftwidth=4 expandtab
""" Crosshair class

    A Crosshair is a pair of lines drawn on the graph that intersect at the
    mouse position.  The lines are draw only inside the plotting area.
    The user can modify the color, style and width of the crosshair lines.

    Associated with the crosshair is a popup window that shows the
    coordinates of the crosshair in user units of the graph.

    There is also an additional popup window (PointLabelPopup) that gives the
    x and y values of the data point closest to the mouse.
"""

import wx

from .datenum import num2date
from .pen import Pen


#####################################################################
class Crosshair:
    """ Crosshair class for graph. """

    def __init__(self, graph):
        self.show = 1
        self.width = 1
        self.style = wx.SOLID
        self.color = wx.Colour(128, 128, 128)
        self._set_pen()

    def _set_pen(self):
        """ Since we draw the crosshair using XOR, we need to invert the colors
            to get them to display the requested color.
        """

        self.pen = Pen(self.color, self.width, self.style)

    def draw(self, graph, x, y):
        """ Draw the crosshair.  Keep the lines inside the plotting area. """

        dc = wx.ClientDC(graph)
        odc = wx.DCOverlay(graph.overlay, dc)
        odc.Clear()

        dc.SetPen(self.pen.wxPen())

        a = [[graph.xleft, y, graph.xright, y],
             [x, graph.ytop, x, graph.ybottom]]
        dc.DrawLineList(a)

        del odc

    def setCrosshairStyle(self, color, width, style):
        """ Set the crosshair color and style. """
        self.color = color
        self.width = width
        self.style = style
        self._set_pen()


#####################################################################
class CrosshairPopup(wx.PopupWindow):
    """Show coordinates of crosshair in user units in a popup window"""

    def __init__(self, parent, style):
        wx.PopupWindow.__init__(self, parent, style)

        self.st = wx.StaticText(self, -1, "", pos=(0, 0))

        self.format = "normal"
        self.fg_color = wx.Colour(0, 0, 0)
        self.st.SetForegroundColour(self.fg_color)
        self.bg_color = wx.Colour(209, 243, 247)
        self.SetBackgroundColour(self.bg_color)

#        f = wx.Font(18, wx.ROMAN, wx.ITALIC, wx.BOLD, True)
#       f = wx.NORMAL_FONT
#        self.st.SetFont(f)
        self.xaxis = 0
        self.yaxis = 0

    def draw(self, graph, x, y):
        """ Draw the popup window.
            Input:
            graph - the graph
            x, y - pixel coordinats of mouse
        """
        wPos = graph.ClientToScreen((x+15, y+10))
        xax = graph.getXAxis(self.xaxis)
        yax = graph.getYAxis(self.yaxis)
        xp = graph.PixelToUser(x, xax)
        yp = graph.PixelToUser(y, yax)

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

        self.st.SetLabel(s)
        sz = self.st.GetBestSize()
        # Set the location and size of the popup window
#        self.SetDimensions(wPos.x, wPos.y, sz.width+1, sz.height+1, wx.SIZE_AUTO)
        self.SetSize(wPos.x, wPos.y, sz.width+1, sz.height+1, wx.SIZE_AUTO)

    def setBackgroundColor(self, color):
        """ Set the background color of the popup window. """
        self.bg_color = color
        self.SetBackgroundColour(color)

    def setForegroundColor(self, color):
        """ Set the foreground color of the popup window. """
        self.fg_color = color
        self.st.SetForegroundColour(color)


#####################################################################
class PointLabelPopup(wx.PopupWindow):
    """Show values of datapoint nearest the crosshair"""

    def __init__(self, parent, style):
        wx.PopupWindow.__init__(self, parent, style)

        self.st = wx.StaticText(self, -1, "", pos=(0, 0))

        self.format = "normal"
        self.fg_color = wx.Colour(0, 0, 0)
        self.st.SetForegroundColour(self.fg_color)
        self.bg_color = wx.Colour(255, 255, 240)
        self.SetBackgroundColour(self.bg_color)

#    f = wx.Font(18, wx.ROMAN, wx.ITALIC, wx.BOLD, True)
#       f = wx.NORMAL_FONT
#    self.st.SetFont (f)
        self.xaxis = 0
        self.yaxis = 0

    def draw(self, graph, xax, yax, xp, yp):
        """ Draw the text showing value of datapoint.
            Parameters are
            graph - the graph being used
            xax - the xaxis used for scaling.
                Needed to convert to date and time label if axis
                is a date axis
            yax - the yaxis used for scaling
                Needed to convert to date and time label if axis
                is a date axis
            xp - the x value in user units
            yp - the y value in user units
        """

        x = graph.UserToPixel(xp, xax)
        y = graph.UserToPixel(yp, yax)
        wPos = graph.ClientToScreen((x+5, y-20))

        xs = "%.3f" % xp
        ys = "%.3f" % yp

        if xax.scale_type == "date":
            # convert val to calendar date
            d = num2date(xp)
            xs = d.strftime("%Y-%m-%d %H:%M:%S")

        if yax.scale_type == "date":
            # convert val to calendar date
            d = num2date(xp)
            ys = d.strftime("%Y-%m-%d %H:%M:%S")

        s = "%s, %s" % (xs, ys)

        self.st.SetLabel(s)
        sz = self.st.GetBestSize()
        # Set the location and size of the popup window
        self.SetSize(wPos.x, wPos.y, sz.width+1, sz.height+1, wx.SIZE_AUTO)

    def setBackgroundColor(self, color):
        """ Set the background color of the popup window. """
        self.bg_color = color
        self.SetBackgroundColour(color)

    def setForegroundColor(self, color):
        """ Set the foreground color of the popup window. """
        self.fg_color = color
        self.st.SetForegroundColour(color)
