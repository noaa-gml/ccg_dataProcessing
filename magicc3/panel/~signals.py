

import sys
import os
import wx
import glob
import datetime

import config

from graph2.graph import Graph
from graph2.dataset import Dataset
from utils import *

#pages = { 0: 'N2O', 1: 'SF6', 2: 'CO', 3: 'H2', 4: 'CH4', 5: 'CO2' }
#pages = { 0: 'CH4' }
pages = { 0: 'Picarro', 1: 'LGR', 2: 'NDIR'} 

PEAK_HEIGHT = 1
PEAK_AREA = 2
RET_TIME = 3

#--------------------------------------------------------------
class mkSignalPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
	self.t2 = wx.Timer(self)

        box = wx.StaticBox(self, -1, "Signals", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

	self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

	self.rb = {}
	self.plot = {}
	for pagenum, pagelabel in pages.items():
		panel = wx.Panel(self.nb, -1)
		sz = wx.BoxSizer(wx.VERTICAL)
#		if pagenum == 5:
#			self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["Analyzer Voltages"])
#		else:
#			self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["Peak Height", "Peak Area", "Retention Time"])
		if pagenum == 0:
			self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["CO2","CH4","H2O","Cell_Press",
									   "Cell_Temp","Flow",
									   "Smpl_Press","Room_temp"])
		elif pagenum == 1:
			self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["CO2","C13_CO2","O18_CO2",
									   "O17_CO2","Cell_Press",
									   "Cell_Temp","Flow",
									   "Smpl_Press","Room_temp"])
		elif pagenum == 2:
			self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["Analyzer Voltages","Cell_Press",
									   "Cell_Temp","Flow","Smpl_Press",
									   "Room_temp"])
		else:
			self.rb[pagenem] = wxRadioBox(panel, -1, choices=["Analyzer Voltages"])
			
		sz.Add(self.rb[pagenum])
		self.rb[pagenum].Bind(wx.EVT_RADIOBOX, self.refreshPage)

		plot = Graph(panel, -1)
#		xaxis = plot.getXAxis(0)
#		xaxis.scale_type = "time"
		plot.showGrid = 1
		plot.showSubgrid = 1
		plot.margin = 25
		sz.Add(plot, 1, wx.EXPAND|wx.ALL, 5)
		self.plot[pagenum] = plot

		panel.SetSizer(sz)

		self.nb.AddPage(panel, pagelabel)

	sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

	self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)
	self.Bind(wx.EVT_TIMER, self.refreshPage)

        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):
	if self.nb.IsShownOnScreen():
		page_num = self.nb.GetSelection()
		gas = pages[page_num]
		plot = self.plot[page_num]
		rb = self.rb[page_num]
		type = rb.GetStringSelection()

		self.doPlotSignal(gas, plot, type)
		self.t2.Start(config.page_refresh)

	else:
		self.t2.Stop()

    #----------------------------------------------
    def refreshPage(self, evt):

	self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def doPlotSignal(self, gas, graph, type):

	file = "%s/data.%s" % (config.sysdir, gas.lower())

	x = []
	y = []
	x1 = []
	y1 = []
	x2 = []
	y2 = []

	if os.path.exists(file):
		f = open(file, "r")
		for line in f:
			list = line.split()
			gas_type = list[0]
			gas_name = list[1]
			yr = int(list[2])
			mn = int(list[3])
			dy = int(list[4])
			hr = int(list[5])
			mi = int(list[6])
			sc = int(list[7])

			if gas.lower() == "picarro":
			    if   type == "CO2":        v = float(list[8])
			    elif type == "CH4":        v = float(list[11])
			    elif type == "H2O":        v = float(list[14])
			    elif type == "Cell_Press": v = float(list[17])
			    elif type == "Cell_Temp":  v = float(list[20])
			    elif type == "Flow":       v = float(list[32])
			    elif type == "Smpl_Press": v = float(list[33])
			    elif type == "Room_temp":  v = float(list[34])
			    else:
				    pass

			if gas.lower() == "lgr":
			    if   type == "CO2":        v = float(list[8])
			    elif type == "C13_CO2":    v = float(list[11])
			    elif type == "O18_CO2":    v = float(list[14])
			    elif type == "O17_CO2":    v = float(list[17])
			    elif type == "Cell_Press": v = float(list[20])
			    elif type == "Cell_Temp":  v = float(list[23])
			    elif type == "Flow":       v = float(list[29])
			    elif type == "Smpl_Press": v = float(list[30])
			    elif type == "Room_temp":  v = float(list[31])
			    else:
				    pass

			if gas.lower() == "ndir":
			    if   type == "CO2":        v = float(list[8])
			    elif type == "Cell_Press": v = float(list[11])
			    elif type == "Cell_Temp":  v = float(list[14])
#			    elif type == "Flow":       v = float(list[29])
#			    elif type == "Smpl_Press": v = float(list[30])
#			    elif type == "Room_temp":  v = float(list[30])
			    else:
				    pass

			t = datetime.datetime(yr, mn, dy, hr, mi, sc)
#			xp = decimalDate(yr, mn, dy, hr, mi)
			if gas_type == "SMP":
				x.append(t)
				y.append(v)
			elif gas_type == "STD":
				x1.append(t)
				y1.append(v)
			else:
				x2.append(t)
				y2.append(v)
		f.close()


	graph.clear()
	if len(x):
		dataset = Dataset(x,y, "Sample")
		dataset.style.setLineColor("black")
		dataset.style.setMarker("circle")
		dataset.style.setFillColor("blue")
		graph.addDataset(dataset)

	if len(x1):
		dataset = Dataset(x1,y1, "Standard")
		dataset.style.setLineColor("black")
		dataset.style.setMarker("circle")
		dataset.style.setFillColor("orange")
		graph.addDataset(dataset)

	if len(x2):
		dataset = Dataset(x2,y2, "Reference")
		dataset.style.setLineColor("black")
		dataset.style.setMarker("circle")
		dataset.style.setFillColor("red")
		graph.addDataset(dataset)

	graph.update()

