

import wx
import time

import sys
sys.path.append("graph")
sys.path.append(".")

from graph import *
from dataset import *
from style import *

import numpy

################################################################
def createDataset(graph, n, name, marker, color):

	# Create the initial X-series of data
	numpoints = 100
	low = -5
	high = 15.0
	x = arange(low, high+0.001, (high-low)/numpoints)
	y = x*x

	dataset = Dataset(x,y, name=name)
        style = Style()
#	style.setLineType("none")
	style.setLineColor(color)
	#style.setMarker("circle")
	style.setFillColor(color)
	#style.setOutlineColor(wx.Colour(255,0,0))
	style.setLineWidth(2)
	style.setOutlineWidth(1)
	style.setMarker(marker)
	style.setMarkerSize(5)
        dataset.SetStyle(style)

	graph.addDataset(dataset)

################################################################
class MainApp(wx.App):
        def OnInit(self):
                frame = wx.Frame(None, -1, "tst2", size=(700,500))

#		label = wx.StaticText(frame, -1, "this is a test ")
                graph = Graph(frame)
                axis = graph.getXAxis(0)
                axis.setAxisRange(0, 4, 1, 5, True)

                createDataset(graph, 0, "Data1", "circle_plus", wx.Colour(220,128,140))

                frame.Show()
		return True


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

