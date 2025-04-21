# experimenting with wxPython's DrawRectangle()
# the rectangle is filled with the brush color
# tested with Python24 and wxPython26     vegaseat    19oct2005

import PyQt4
import time

import sys
sys.path.append("graph")
sys.path.append(".")

from graph import *
from element import *

#from scipy.special import jn

import MySQLdb


def createDataset(graph, n, name, marker, color):

	# Create the initial X-series of data
	numpoints = 100
	low = -5
	high = 15.0
	x = arange(low, high+0.001, (high-low)/numpoints)
	y = jn(n, x)

	element = Element(x,y, name=name)
#	element.setLineType("none")
	element.setLineColor(color)
	#element.setMarker("circle")
	element.setFillColor(color)
	#element.setOutlineColor(wx.Colour(255,0,0))
	element.setLineWidth(2)
	element.setOutlineWidth(1)
	element.setMarker(marker)
	element.setMarkerSize(5)

	graph.addDataset(element)

        
        
#height1 = 350
#width1 = 400

#app = wx.App()
################################################################
class MainApp(QtGui.QMainWindow):

    def __init__(self, parent=None, name=None):
#        QtGui.QMainWindow.__init__(self, parent, name)
	super(MainApp, self).__init__()

#        self.setMinimumSize(800, 600)
#        self.setMaximumSize(800, 600)

#	self.plotgrid = QtGui.QGrid (2,self)
	self.plotgrid = QtGui.QVBoxLayout()
	graph = Graph(self.plotgrid)

	self.resize(750,600)
#	self.setCentralWidget(self.plotgrid)

	db=MySQLdb.connect(host="db",user="guest", passwd="",db="ccgg")

	c = db.cursor()
	c.execute("""select dd,value  from mlo_co2_month""")
	list = c.fetchall()
#	print list
	x= []
	y = []
	for row in list:
#			print row
		x.append(row[0])
		y.append(row[1])

#		print x
#		print y
	element = Element(x,y, name="BRW Wind Speed")
	element.setLineColor(QtGui.QColor(220,50,60))
	element.setFillColor(QtGui.QColor(220,50,60))
	element.setLineWidth(2)
	element.setOutlineWidth(1)
	element.setMarker("CIRCLE")
	element.setMarkerSize(4)

	graph.addDataset(element)

	graph.resize(750,600)


#        graph.show()
#	return True


if __name__ == "__main__":
	app = QtGui.QApplication(sys.argv)
        w = MainApp()
	app.setMainWidget(w)
	w.show()
        app.exec_loop()

