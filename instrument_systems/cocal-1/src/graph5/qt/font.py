

from PyQt4 import QtGui, QtCore

FONTFAMILY_DEFAULT = 'Helvetica'
FONTSTYLE_ITALIC = False
FONTWEIGHT_NORMAL = -1

#####################################################################
class Font:
    """ Class for fonts """

    def __init__(self, size=10, family=FONTFAMILY_DEFAULT, style=FONTSTYLE_ITALIC, weight=FONTWEIGHT_NORMAL):

	self.size = size
	self.family = family
	self.style = style
	self.weight = weight
	self.font = self.qtFont()
	self.metrics = QtGui.QFontMetrics(self.font)

    #---------------------------------------------------------------------------
    def SetFont(self, size=10, family=FONTFAMILY_DEFAULT, style=FONTSTYLE_ITALIC, weight=FONTWEIGHT_NORMAL):

	self.size = size
	self.family = family
	self.style = style
	self.weight = weight
	self.font = self.qtFont()
	self.metrics = QtGui.QFontMetrics(self.font)

    #---------------------------------------------------------------------------
    def qtFont(self):
	""" get a font from settings """
	return QtGui.QFont(self.family, self.size, self.weight, self.style)

#	return QtGui.QFont()

    def metrics(self):
	font = self.qtFont()
	metrics = QtGui.QFontMetrics(font)

	return metrics

    def getSize(self, text):
	s = self.metrics.boundingRect(text)
	w = s.width()
	h = s.height()

	return (w, h)

