

from datetime import datetime, timedelta

import os
import glob
import wx

import config

from graph.graph import Graph
from graph.dataset import Dataset
from panel_utils import *

###############################################################
class mkMixingRatioPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
        self.Bind(wx.EVT_END_PROCESS, self.processEnded)

        box = wx.StaticBox(self, -1, "Mixing Ratio")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

	self.plot = Graph(self, -1)
	self.plot.showGrid = 1
	self.plot.showSubgrid = 1
	xaxis = self.plot.getXAxis(0)
	xaxis.scale_type = "time"


	sizer.Add(self.plot, 100, wx.EXPAND|wx.ALL, 5)

        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):

	self.doMRPlot(self.plot)

    #----------------------------------------------
    def doMRPlot(self, graph):

	config.main_frame.SetStatusText ("Working...")

        now=datetime.today()

        start = now - timedelta(days=config.mr_days)
        s = '/ccg/%s/in-situ/mlo_data/raw/%s/%s-%02d-*.%s' % (self.gas.lower(), start.year, start.year, start.month, self.gas.lower())
        list = glob.glob(s)

        if (now.month != start.month):
                s = '/ccg/%s/in-situ/mlo_data/raw/%s/%s-%02d-*.%s' % (self.gas.lower(), now.year, now.year, now.month, self.gas.lower())
                list.extend(glob.glob(s))

        filelist = list[-config.mr_days:]
	s = " ".join(filelist)
	command = "/ccg/src/insitu/%sis.pl -n %s %s 2> /dev/null" % (self.gas.lower(), config.stacode, s)
	print("command is ", command)

        self.process = wx.Process(self)
        self.process.Redirect();
        pid = wx.Execute(command, wx.EXEC_ASYNC, self.process)




#        try:
#                file = os.popen(command)
#                txt = file.read()
 #               file.close()
 #       except:
 #               s = "Error running command."
#		dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
#		dlg.ShowModal()
#		dlg.Destroy()
#		return


    def processEnded(self, evt):
	print("got process end event")

	stream = self.process.GetInputStream()

        if stream.CanRead():
		txt = stream.read()
        self.process.Destroy()
        self.process = None


	x = []
	y = []
	for line in txt.split('\n'):
		list = line.split()
		if self.gas.lower() == "co2":
			if len(list) == 8:
				yr = int(list[1])
				mn = int(list[2])
				dy = int(list[3])
				hr = int(list[4])
				v = float(list[5])
				if v > 0:
					xp = decimalDate(yr, mn, dy, hr)
					x.append(xp)
					y.append(v)
		elif self.gas.lower() == "ch4" or self.gas.lower() == "co":
			if len(list) == 10:
				yr = int(list[0])
				mn = int(list[1])
				dy = int(list[2])
				hr = int(list[3])
				mi = int(list[4])
				v = float(list[6])
				if v > 0:
					xp = decimalDate(yr, mn, dy, hr)
					x.append(xp)
					y.append(v)

	graph = self.plot
	graph.clear()
        dataset = Dataset(x,y, name=self.gas)
	dataset.style.setLineColor("black")
	dataset.style.setMarker("circle")
	dataset.style.setFillColor("blue")
        graph.addDataset(dataset)
	graph.legend.showLegend = 0
	graph.update()

	config.main_frame.SetStatusText ("")
