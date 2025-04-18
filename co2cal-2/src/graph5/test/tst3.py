
# test date axis of graph by setting limits of axis to one month


import wx
import time

import sys
sys.path.append("graph")
sys.path.append(".")

from graph import *
from dataset import *
from style import *

import numpy

from dateutil.rrule import MONTHLY, WEEKLY, DAILY, HOURLY, MINUTELY, SECONDLY

################################################################
def createDataset(graph, n, name, marker, color):

	# Create the initial X-series of data
#	numpoints = 100
#	low = -5
#	high = 15.0
#	x = arange(low, high+0.001, (high-low)/numpoints)
#	y = x*x

        numdays = {1:31, 2:28, 3:31, 4:30, 5:31, 6:30, 7:31, 8:31, 9:30, 10:31, 11:30, 12:31}

	year = 2014
        x = []
        y = []
	month = 5
	ndays = numdays[month]
	for day in range (1, 20):
		xp = datetime.datetime(year, month, day, 0, 0, 0)
		x.append(xp)
		y.append(day)



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
                frame = wx.Frame(None, -1, "tst3", size=(1000,600))

#		label = wx.StaticText(frame, -1, "this is a test ")
                graph = Graph(frame)

                createDataset(graph, 0, "Data1", "circle_plus", wx.Colour(220,128,240))

		xaxis = graph.getXAxis(0)
#		xaxis.setLabelFormat("%d")
		xmin = datetime.datetime(2014, 5, 1, 0, 0, 0)
		xmax = datetime.datetime(2014, 6, 1, 0, 0, 0)
#                xaxis.setAxisDateRange(xmin, xmax, 1, DAILY, 12, HOURLY)
                xaxis.setAxisDateRange(xmin, xmax)
#		xaxis.title.text = "Day of Month"

		yaxis = graph.getYAxis(0)
		yaxis.title.SetText("Y Axis Title")

		graph.title.text = "this is the graph title"


                frame.Show()
		return True


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

