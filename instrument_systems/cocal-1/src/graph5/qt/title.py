

from PyQt4 import QtGui, QtCore

from font import Font


#####################################################################
class Title:
    """ Class for various titles, such as axis, graph and legend title """

    def __init__(self):
        self.show_text = 1
        self.text = ""
        self.margin = 0
#        self.font = wx.Font(10, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	self.font = Font()  # QtGui.QFont()
        self.color = QtCore.Qt.black
	self.x = 0
	self.y = 0
	self.rotated = False
	self.rot_angle = 0
	self.metrics = self.font.metrics   #  QtGui.QFontMetrics(self.font)


    #---------------------------------------------------------------------------
    def draw(self, qp):

	if self.show_text and self.text != "":
		qp.setFont(self.font.qtFont())
		qp.setPen(self.color)

		if self.rotated:
			qp.rotate(-90)
			qp.drawText(QtCore.QPoint(-self.y, self.x), self.text)
			qp.rotate(90)
		else:
			qp.drawText(QtCore.QPoint(self.x, self.y), self.text)

    #---------------------------------------------------------------------------
    def getAscent(self):

	h = 0
	if self.show_text:
		return self.metrics.ascent()
		
    #---------------------------------------------------------------------------
    def getSize(self):

	w = 0
	h = 0
	if self.show_text:
#		qp.SetFont(self.font.wxFont())
#		(w, h) = qp.GetTextExtent(self.text)
		s = self.metrics.boundingRect(self.text)
		w = s.width()
		h = s.height()
		h += 2*self.margin
		w += 2*self.margin

	return (w, h)

    #---------------------------------------------------------------------------
    def setLocation(self, x, y):
	self.x = x
	self.y = y


    #---------------------------------------------------------------------------
    def SetText(self, t):
	self.text = t

