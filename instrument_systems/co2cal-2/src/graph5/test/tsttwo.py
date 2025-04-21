

import sys
import numpy
import wx

sys.path.append("/ccg/src/python3")
from graph5.graph import Graph
from graph5.dataset import Dataset
from graph5.style import Style


################################################################
def createDataset(graph, n, name, marker, color, yoffset=0):

	# Create the initial X-series of data
	numpoints = 100
	low = -5
	high = 15.0
	x = numpy.arange(low, high+0.001, (high-low)/numpoints)
	y = x*x + yoffset

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

	def __init__(self, parent, ID, title):
		wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(910, 800))

		box0 = wx.BoxSizer(wx.VERTICAL)

		self.graph1 = Graph(self)
		self.graph2 = Graph(self)

		createDataset(self.graph1, 0, "Data1", "circle_plus", wx.Colour(220,128,140))
		createDataset(self.graph2, 0, "Data2", "square_plus", wx.Colour(140,220,128), yoffset=50)

		self.graph1.syncAxis()
		self.graph2.syncAxis()

		box0.Add(self.graph1, 1, wx.EXPAND, 0)
		box0.Add(self.graph2, 1, wx.EXPAND, 0)

		self.SetSizer(box0)
		box0.Layout()


##################################################################################
class MyApp(wx.App):
	def OnInit(self):
		frame = MainFrame(None, -1, "two graphs")
		frame.CenterOnScreen()
		frame.Show(True)
		self.SetTopWindow(frame)
		return True

##################################################################################
if __name__ == '__main__':

	app = MyApp(0)
	app.MainLoop()
