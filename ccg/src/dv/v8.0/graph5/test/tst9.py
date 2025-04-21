

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

        numdays = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

	year = 2014
        x = []
        y = []
        for month in range(1,2):
                ndays = numdays[month]
                for day in range (1, 2):
                        xp = datetime.datetime(year, month, day, 3, 14, 20)
                        x.append(xp)
			y.append(day)


	print x, y

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

                createDataset(graph, 0, "Data1", "circle_plus", wx.Colour(220,128,140))

                frame.Show()
		return True


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

