# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for holding font information and getting a wx font
"""

import wx


#####################################################################
class Font:
    """ Class for fonts """

    def __init__(self, size=12, family=wx.FONTFAMILY_DEFAULT, style=wx.FONTSTYLE_NORMAL, weight=wx.FONTWEIGHT_NORMAL):

        self.size = size
        self.family = family
        self.style = style
        self.weight = weight

    #---------------------------------------------------------------------------
    def SetFont(self, size=12, family=wx.FONTFAMILY_DEFAULT, style=wx.FONTSTYLE_NORMAL, weight=wx.FONTWEIGHT_NORMAL):
        """ Save font info """

        self.size = size
        self.family = family
        self.style = style
        self.weight = weight

    #---------------------------------------------------------------------------
    def wxFont(self):
        """ get a wx font from settings """

        return wx.Font(self.size, self.family, self.style, self.weight)

    def setFixedFont(self):
        """ set the font to fixed font type """

        self.family = wx.FONTFAMILY_TELETYPE
