# vim: tabstop=4 shiftwidth=4 expandtab
""" A higher level class for containing wx Pen data """

import wx


#####################################################################
class Pen:
    """ Class for pens """

    def __init__(self, pencolor=wx.BLACK, width=1, style=wx.SOLID):
        self.width = width
        self.color = pencolor
        self.style = style

    def SetPen(self, pencolor=wx.BLACK, width=1, style=wx.SOLID):
        """ Set the pen color, width and style """
        self.width = width
        self.color = pencolor
        self.style = style


    #---------------------------------------------------------------------------
    def wxPen(self):
        """ get a wx pen from settings """
        return wx.Pen(self.color, self.width, self.style)

    def GetColour(self):
        """ Return the color of the pen """
        return self.color

    def GetColor(self):
        """ Retrun the color of the pen """
        return self.color

    def GetStyle(self):
        """ Return the pen style """
        return self.style

    def GetWidth(self):
        """ Return the pen width """
        return self.width
