
import wx
import numpy
import datetime
import sys
sys.path.append("..")

from graph import *


################################################################
class MainApp(wx.App):
        def OnInit(self):
		self.t2 = wx.Timer(self)

                frame = wx.Frame(None, -1, "Simple Plot", size=(700,500))
                self.graph = Graph(frame)

		t = datetime.datetime.now()
#		self.x = [t]
		self.x = [0]
		a = numpy.random.normal()
		self.y = [a]
		self.dataset = self.graph.createDataset(self.x,self.y, "Random Numbers")

                frame.Show()

		self.Bind(wx.EVT_TIMER, self.update)
		self.t2.Start(100)
		self.n = 0

		return True

	def update(self, evt):

		self.n += 1

#		print "+++++++++++++++++++++"
		t = datetime.datetime.now()
#		self.x.append(t)
		self.x.append(self.n)
		y = numpy.random.normal()
		self.y.append(y)

		if len(self.x) > 20:
			del self.x[0]
			del self.y[0]
		self.dataset.SetData(self.x, self.y)
#		print self.x, self.y

		self.graph.update()

#		if len(self.x) == 4:
#		self.t2.Stop()
#		print "====================="
		
		

if __name__ == "__main__":
        app = MainApp()
        app.MainLoop()

