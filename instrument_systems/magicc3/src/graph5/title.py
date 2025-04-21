# vim: tabstop=4 shiftwidth=4 expandtab
""" a class for handling the 'title' of various things in the graph. """

import wx

from .font import Font


#####################################################################
class Title:
    """ Class for various titles, such as axis, graph and legend title """

    def __init__(self):
        self.show_text = 1
        self.text = ""
        self.margin = 0
        self.font = Font()
        self.color = wx.Colour(0, 0, 0)
        self.x = 0
        self.y = 0
        self.rotated = False
        self.rot_angle = 0


    #---------------------------------------------------------------------------
    def draw(self, dc):
        """ Draw the text """

        if self.show_text and self.text != "":
            dc.SetFont(self.font.wxFont())
            dc.SetTextForeground(self.color)

            if self.rotated:
                dc.DrawRotatedText(self.text, int(self.x), int(self.y), self.rot_angle)
            else:
                dc.DrawText(self.text, int(self.x), int(self.y))

    #---------------------------------------------------------------------------
    def getSize(self, dc):
        """ Get the width and height of the text """

        w = 0
        h = 0
        if self.show_text:
            dc.SetFont(self.font.wxFont())
            (w, h) = dc.GetTextExtent(self.text)
            h += 2 * self.margin
            w += 2 * self.margin

        return (w, h)

    #---------------------------------------------------------------------------
    def setLocation(self, x, y):
        """ Set the location of the text.
        This is the left, top position of the text as used by wx DrawText
        No justification (center, left, etc) is supported at this time.
        """

        self.x = x
        self.y = y


    #---------------------------------------------------------------------------
    def SetText(self, t):
        """ Set the text string to use as the title. """

        self.text = t
