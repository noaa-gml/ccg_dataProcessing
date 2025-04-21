

from PyQt4 import QtGui, QtCore

#####################################################################3333
class Graph(QtGui.QWidget):
    """ A scientific graphing class """

    def __init__(self, parent):
        super(Graph, self).__init__(parent)

	self.initUI()

    def initUI(self):

#	palette = QtGui.QPalette()

	self.setMinimumSize(500, 500)

    def paintEvent(self, e):

	size = self.size()
        self.width = size.width()
        self.height = size.height()

	print self.width, self.height

        qp = QtGui.QPainter()
        qp.begin(self)
        self._draw(qp)
        qp.end()

    def _draw(self, qp):

#	color = QtGui.QColor(0, 0, 0)
 #       color.setNamedColor('#d4d4d4')
 #       qp.setPen(color)

 #       qp.setBrush(QtGui.QColor(200, 0, 0))
 #       qp.drawRect(10, 15, 90, 60)

 #       qp.setBrush(QtGui.QColor(255, 80, 0, 160))
 #       qp.drawRect(130, 15, 90, 60)

 #       qp.setBrush(QtGui.QColor(25, 0, 90, 200))
 #       qp.drawRect(250, 15, 90, 60)

	lines = []
	for i in range(20):
		x = i*10
		y = 20
		x1 = i*10
		y1 = 480
		lines.append(QtCore.QLine(x, y, x1, y1))

	qp.drawLines(lines)
