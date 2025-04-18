

import wx
import time

import sys
sys.path.append("graph")
sys.path.append(".")

from graph import *
from dataset import *
from style import *

from datenum import date2num

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
        for month in range(1,13):
                ndays = numdays[month]
                for day in range (1, ndays+1):
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
                frame = wx.Frame(None, -1, "tst2", size=(700,500))

		self.t2 = wx.Timer(self)

#		label = wx.StaticText(frame, -1, "this is a test ")
                self.graph = Graph(frame)
		self.x = []
		self.y = []
		self.dataset = Dataset(self.x, self.y, name="test")
		self.graph.addDataset(self.dataset)

                frame.Show()

		self.t2.Start(1000)
		self.Bind(wx.EVT_TIMER, self.refreshPage)

		self.refreshPage(None)

		return True

	def refreshPage(self, event):

		x = datetime.datetime.now()
		y = numpy.random.rand()
		y = x.second + x.microsecond/1e6

		print len(self.x), x, y

		self.x.append(x)
		self.y.append(y)

		if len(self.x) >= 180:
			self.x.pop(0)
			self.y.pop(0)

		self.dataset.SetData(self.x, self.y)
		self.graph.update()


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

