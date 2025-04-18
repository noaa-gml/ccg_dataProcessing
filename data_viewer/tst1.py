
import sys
import datetime
import time
import numpy
import MySQLdb

import wx

#sys.path.append("graph")
#sys.path.append(".")

sys.path.append("/ccg/src/python3")
from graph5.graph import Graph

#from scipy.special import jn


#global graph

################################################################
def get_db_dataset(graph):

	db=MySQLdb.connect(host="db",user="guest", passwd="", db="gmd")
	c = db.cursor()

	for sta in ["BRW", "MLO", "SMO", "SPO"]:
		sql = "select date, value from ccgg.%s_co2_month where date>'2010-1-1' and value>0 order by date" % sta.lower()
		c.execute(sql)
		list = c.fetchall()
		x= []
		y = []
		for row in list:
			(d, value) = row
			dt = datetime.datetime(d.year,d.month,d.day,0,0,0)
			x.append(dt)
			y.append(float(value))

		dataset = graph.createDataset(x, y, name="%s" % sta)

#        style = Style()
#       style.setLineType("none")
#        style.setLineColor("#aaa")
#        style.setLineWidth(10)
#        style.setMarker("None")

#	xp = datetime.datetime(2012, 6, 6)
#	graph.AddVerticalLine(xp)

#	graph.legend.title.text = "this is the legend title"

#	graph.update()


#app = wx.App()
################################################################
class MainApp(wx.App):
	def OnInit(self):
#		global graph
		frame = wx.Frame(None, -1, "tst2", size=(700,500))
		graph = Graph(frame)
		axis = graph.getYAxis(0)
		axis.title.text = "CO2 (ppm)"

		get_db_dataset(graph)

#		graph.save("testgraph.dv")
#		graph.load("testgraph.dv")

		frame.Show()
		return True

if __name__ == "__main__":
	app = MainApp()
	app.MainLoop()

