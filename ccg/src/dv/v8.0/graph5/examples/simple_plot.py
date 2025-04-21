

import wx
import numpy
import sys
sys.path.append("/ccg/src/python3")

#from graph import *

from graph5.graph import Graph


################################################################
class MainApp(wx.App):
    def OnInit(self):
        frame = wx.Frame(None, -1, "Simple Plot", size=(700,500))
        graph = Graph(frame)
        x = numpy.arange(1000)
        y = numpy.random.normal(size=1000)
        dataset = graph.createDataset(x, y, "Random Numbers")

        frame.Show()

        return True

if __name__ == "__main__":
    app = MainApp()
    app.MainLoop()

