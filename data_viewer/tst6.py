

# experimenting with wxPython's DrawRectangle()
# the rectangle is filled with the brush color
# tested with Python24 and wxPython26     vegaseat    19oct2005

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
class MainApp(wx.App):
        def OnInit(self):
                frame = wx.Frame(None, -1, "tst2", size=(700,500))

#		label = wx.StaticText(frame, -1, "this is a test ")
                graph = Graph(frame)

                xp = []
                yp = []
                file = sys.argv[1]
                f = open(file)
                for line in f:
                    (x, y) = line.split()
                    x = float(x)
                    y = float(y)
                    xp.append(x)
                    yp.append(y)

                graph.createDataset(xp, yp)
                graph.update()

                frame.Show()
		return True


# show the frame
#frame.Show(True)
# start the event loop

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

