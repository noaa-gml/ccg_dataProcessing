# experimenting with wxPython's DrawRectangle()
# the rectangle is filled with the brush color
# tested with Python24 and wxPython26     vegaseat    19oct2005

import wx
import time

import sys
sys.path.append("graph")
sys.path.append(".")

from graph import *
from element import *

from scipy.special import jn



def createDataset(graph, n, name, marker, color):

	# Create the initial X-series of data
	numpoints = 100
	low = -5
	high = 15.0
	x = arange(low, high+0.001, (high-low)/numpoints)
	y = jn(n, x)

	element = Element(x,y, name=name)
	#element.setLineType("solid")
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
class MainApp(wx.App):
        def OnInit(self):
                frame = wx.Frame(None, -1, "tst2", size=(700,500))
                graph = Graph(frame)

                createDataset(graph, 0, "Data1", "circle_plus", wx.Colour(220,128,140))
                createDataset(graph, 1, "Data2", "circle", wx.Colour(255,228,128))
                createDataset(graph, 2, "Data3", "diamond", wx.Colour(140,228,180))
                createDataset(graph, 3, "Data4", "asterisk", wx.Colour(210,28,190))

                frame.Show()
		return True

#plot = graph.getDataset("Data2")
#xaxis = graph.addXAxis("x1 title")
#yaxis = graph.addYAxis("y1 title")
#plot.setAxis(xaxis)
#plot.setAxis(yaxis)

#plot = graph.getDataset("Data3")
#xaxis = graph.addXAxis("x2 title")
#yaxis = graph.addYAxis("y2 title")
#plot.setAxis(xaxis)
#plot.setAxis(yaxis)

#plot = graph.getDataset("Data4")
#xaxis = graph.addXAxis("x3 title")
#yaxis = graph.addYAxis("y3 title")
#plot.setAxis(xaxis)
#plot.setAxis(yaxis)
#plot.label = "legend label"
#print "--------------"
#print "y data is ", plot.ydata
#print "name of element is ", plot.name
#print "y minimum is ",plot.ymin
#print "y maximum is ",plot.ymax

#a = graph.getDatasetNames()
#print a

#b = ["Data2"]
#print b

#graph.showDatasets(b)


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

