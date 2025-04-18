# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for adding text to the graph.
You can also attach a popup window to the text that
has additional text to display when the mouse is hovered over
the text.

Create with
t = Text(graph, x, y, "title", "this is more text")

If you want to have a popup when mouse is over text, then also do
t.setPopup(True)

This will then display 'title' on the graph, and 'this is more text' in the popup.

If you don't set a popup, i.e. t.setPopup(False),
then 'this is more text' is shown on the graph, and there is no popup window.
"""

import wx

from .font import Font

#####################################################################3333
class Text:
    """ A class for displaying text on the graph """

    def __init__(self, graph, x, y, title, string):
        """
        Input:
            x,y - location of text
            title - short text string to display if we have a popup
            string - long text string to display if no popup

        """

        self.x = x
        self.y = y
        self.text = string
        self.title = title
        self.graph = graph
        self.font = Font()
        self.color = wx.Colour(0, 0, 0)
        self.justify = wx.ALIGN_CENTRE
        self.pady = 2
        self.padx = 0
        self.popup = None
        self.show_popup = 0
        self.is_shown = 0
        self.xp = 0
        self.yp = 0
        self.width = 0
        self.height = 0

    def set_size(self, graph, dc):
        """ Calculate location and size of box surrounding text """

        dc.SetFont(self.font.wxFont())
        string = self.title
        (w, h) = dc.GetTextExtent(string)
        xp = graph.UserToPixel(self.x, graph.axes[0])
        if self.justify == wx.ALIGN_RIGHT:
            xp -= w
        if self.justify == wx.ALIGN_CENTRE:
            xp -= w/2

        yp = graph.UserToPixel(self.y, graph.axes[1])
        yp += self.pady
        self.xp = xp
        self.yp = yp
        self.width = w
        self.height = h


    def setColor(self, color):
        """ Set color of text """

        self.color = color

    def setFont(self, font):
        """ Set font for displaying text """

        self.font = font

    def setText(self, text):
        """ Set the actual text """

        self.text = text

    def setPopup(self, which):
        """Set whether to show or not show text popup """

        if which:
            self.show_popup = 1
        else:
            self.show_popup = 0

    def show(self, graph):
        """ show the popup that goes with this text """
        if self.show_popup and not self.is_shown:
            if self.popup is None:
                self.popup = TextPopup(graph, t=self)
            self.popup.Show()
            self.is_shown = 1

    def hide(self, graph):
        """ hide the popup that goes with this text """
        if self.show_popup and self.popup is not None and self.is_shown:
            self.popup.Destroy()
            self.popup = None
            self.is_shown = 0

    def inRegion(self, x, y):
        """ check if mouse location is within this text.
        Used to see if popup needs to be shown. """
        if self.show_popup == 0:
            return 0

        if self.xp <= x <= self.xp+self.width and self.yp <= y <= self.yp+self.height:
            return 1
        return 0

    def draw(self, graph, dc):
        """ Draw the text popup """

        dc.SetFont(self.font.wxFont())
        dc.SetTextForeground(self.color)
        if self.show_popup:
            string = self.title
        else:
            if self.is_shown:
                self.popup.Hide()
            string = self.text

        (w, h) = dc.GetTextExtent(string)
        xp = graph.UserToPixel(self.x, graph.axes[0])
        if self.justify == wx.ALIGN_RIGHT:
            xp -= w
        if self.justify == wx.ALIGN_CENTRE:
            xp -= w/2

        yp = graph.UserToPixel(self.y, graph.axes[1])
        yp += self.pady
        dc.DrawText(string, int(xp), int(yp))

#####################################################################3333
class TextPopup(wx.PopupWindow):
    """Show text annotation as a popup window"""

    def __init__(self, parent=None, style=wx.BORDER_SIMPLE, t=None):
        wx.PopupWindow.__init__(self, parent, style)

        self.st = wx.StaticText(self, -1, "", pos=(0, 0))
        self.st.SetFont(t.font.wxFont())
        self.st.SetLabel(t.text)

        self.fg_color = wx.Colour(0, 0, 0)
        self.st.SetForegroundColour(self.fg_color)
        self.bg_color = wx.Colour(255, 255, 224)
        self.SetBackgroundColour(self.bg_color)

        self.xaxis = 0
        self.yaxis = 0

        # Set the location and size of the popup window
        wPos = parent.ClientToScreen((t.xp+10, t.yp+10))
        sz = self.st.GetBestSize()
        self.SetSize(wPos.x, wPos.y, sz.width+1, sz.height+1, wx.SIZE_AUTO)
