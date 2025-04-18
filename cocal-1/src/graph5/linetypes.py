# vim: tabstop=4 shiftwidth=4 expandtab
""" Functions dealing with line styles """

import wx

LINE_TYPES = {
    'none': wx.TRANSPARENT,
    'solid': wx.SOLID,
    'long dash': wx.LONG_DASH,
    'short dash': wx.SHORT_DASH,
    'dot': wx.DOT,
    'dot dash': wx.DOT_DASH
}

def NameToStyle(name):
    """ Convert a string name to wx line type. """
    if name.lower() in LINE_TYPES:
        return LINE_TYPES[name.lower()]

    return wx.SOLID

def StyleToName(style):
    """ Convert a wx line type to string name. """
    for k, v in LINE_TYPES.items():
        if style == v:
            return k
    return "None"
