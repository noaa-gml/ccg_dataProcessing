

from PyQt4 import QtGui, QtCore


#####################################################################
class Pen:
    """ Class for pens """

    def __init__(self, pencolor=QtCore.Qt.black, width=1, style=QtCore.Qt.SolidLine ):
	self.width = width
	self.color = pencolor
	self.style = style

    def SetPen(self, pencolor=QtCore.Qt.black, width=1, style=QtCore.Qt.SolidLine ):
	self.width = width
	self.color = pencolor
	self.style = style
	

    #---------------------------------------------------------------------------
    def qtPen(self):
	""" get a wx pen from settings """
	return QtGui.QPen(self.color, self.width, self.style)

    def GetColour(self):
	return self.color

    def GetColor(self):
	return self.color

    def GetStyle(self):
	return self.style

    def GetWidth(self):
	return self.width

