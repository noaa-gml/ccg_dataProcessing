

import wx
import time

import sys
sys.path.append("/ccg/src/python3")

from graph5.graph import Graph
from graph5.dataset import Dataset
from graph5.style import Style

import numpy

################################################################
def createDataset(graph, n, name, marker, color):

	# Create the initial X-series of data
	numpoints = 100
	low = -5
	high = 15.0
	x = numpy.arange(low, high+0.001, (high-low)/numpoints)
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
class MainFrame(wx.Frame):

	def __init__(self, *args, **kw):
        # ensure the parent's __init__ is called
		super(MainFrame, self).__init__(*args, **kw)

		# create a panel in the frame
		pnl = wx.Panel(self)
		box0 = wx.BoxSizer(wx.VERTICAL)

#		label = wx.StaticText(frame, -1, "this is a test ")
		graph1 = Graph(pnl)
#		graph2 = Graph(pnl)

#		createDataset(graph1, 0, "Data1", "circle_plus", wx.Colour(220,128,140))
#		createDataset(graph2, 0, "Data2", "square_plus", wx.Colour(220,140,128))

		box0.Add(graph1)
#		box0.Add(graph2)

		pnl.SetSizer(box0)


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
	app = wx.App()
	frm = MainFrame(None, title="two graph test")
	frm.Show()
	app.MainLoop()

