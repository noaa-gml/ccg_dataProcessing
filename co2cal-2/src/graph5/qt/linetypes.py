
import wx

LINE_TYPES = {
	'None': wx.TRANSPARENT, 
	'Solid': wx.SOLID, 
	'Long Dash': wx.LONG_DASH, 
	'Short Dash': wx.SHORT_DASH, 
	'Dot': wx.DOT, 
	'Dot Dash': wx.DOT_DASH
}

def NameToStyle(name):
	if LINE_TYPES.has_key(name):
		return LINE_TYPES[name]
	else:
		return wx.SOLID

def StyleToName(style):
	for k,v in LINE_TYPES.iteritems():
		if style == v:
			return k
	return "None"
