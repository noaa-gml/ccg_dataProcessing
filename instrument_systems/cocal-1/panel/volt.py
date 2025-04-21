
from datetime import datetime, timedelta
import time


import os
import wx
import wx.lib.calendar
import glob

import config

from graph2.graph import Graph
from graph2.dataset import Dataset
from panel_utils import *

pages = { 0: '10 Sec. Average Volts', 1: 'Averaged Volts', 2: 'Voltages for a Day' }

#--------------------------------------------------------------
class mkVoltPage(wx.Panel):
    def __init__(self, parent, sys ):
	wx.Panel.__init__(self, parent, -1)

	self.t2 = wx.Timer(self)
	self.plot = []

	self.gas = config.gases[0]

        box = wx.StaticBox(self, -1, "Voltages", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.rb = wx.RadioBox(self, -1, choices=config.gases)
        sizer.Add(self.rb)
        self.rb.Bind(wx.EVT_RADIOBOX, self.setGas)

	self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

	for pagenum, pagelabel in pages.items():
		if pagenum != 2:
			plot = Graph(self.nb, -1)
			xaxis = plot.getXAxis(0)
			xaxis.scale_type = "time"
			plot.showGrid = 1
			plot.showSubgrid = 1
			self.nb.AddPage(plot, pagelabel)
		else:
			(page, plot) = self.MakePage2(self.nb)
			self.nb.AddPage(page, pagelabel)

		self.plot.append(plot)

	sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

	self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)
	self.Bind(wx.EVT_TIMER, self.refreshPage)

        self.SetSizer(sizer)

    #----------------------------------------------
    def MakePage2(self, parent):

        p1 = wx.Panel(parent)

        box = wx.BoxSizer(wx.VERTICAL)

	button = wx.Button(p1, -1, "Select a date")
	box.Add(button, 0, wx.ALIGN_CENTER|wx.ALL, 5 )
	button.Bind(wx.EVT_BUTTON, self.getDate)


	plot = Graph(p1, -1)
	xaxis = plot.getXAxis(0)
	xaxis.scale_type = "time"
	plot.showGrid = 1
	plot.showSubgrid = 1
	plot.legend.showLegend = 0

        box.Add(plot, 1, wx.EXPAND, 0)
        p1.SetSizer(box)

        return p1, plot

    #----------------------------------------------
    def getDate(self, evt):
	dlg = wx.lib.calendar.CalenDlg(self)
	if dlg.ShowModal() == wx.ID_OK:
		result = dlg.result
		year = result[3]
		month = result[2]
		day = result[1]
		print(year, month, day)
		s = "%s %s %s" % (year, month, day)
		t = time.strptime(s, "%Y %B %d")
		print(t)
		dt = datetime(*t[:6])
		print(dt)

		self.doDayVolt(self.plot[2], dt.year, dt.month, dt.day)

    #----------------------------------------------
    def setGas(self, evt):

	self.gas = self.rb.GetStringSelection()
	self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def updatePage(self):
	if self.nb.IsShownOnScreen():
		page_num = self.nb.GetSelection()
#		page = self.nb.GetCurrentPage()
		page = self.plot[page_num]
		if page_num == 0:
			self.do10SecVolt(page)
			self.t2.Start(config.page_refresh)
		elif page_num == 1:
			self.doHrVolt(page)
			self.t2.Stop()
		elif page_num == 2:
			self.doDayVolt(page)
			self.t2.Stop()

	else:
		self.t2.Stop()

    #----------------------------------------------
    def refreshPage(self, evt):

	self.updatePage()
        evt.Skip()

    #----------------------------------------------
    # Show last x hours of voltages (10 second averages)
    # from the available data 
    # (may not be the same as last x hours from current date and time)
    # This way data will be shown even if system has been off for a while.
    def do10SecVolt(self, graph):

	# Get a list of all available files
	s = '%s/%s/data/*/*' % (config.datadir, self.gas.lower())
	list = glob.glob(s)
	if len(list) == 0: return
	list.sort()

	# Take just the last 2, and read in the data from those files
	filelist = list[-2:]
	data = []
	for file in filelist:
		f = open(file)
		for line in f:
			data.append(line)
		f.close()


	# find date and time of last data point
	line = data[-1:]
	s = line[0]
	list = s.split()
	yr = int(list[0])
	mn = int(list[1])
	dy = int(list[2])
	hr = int(list[3])
	mi = int(list[4])
	sc = int(list[5])
	v = float(list[6])
	endtime = datetime(yr, mn, dy, hr, mi,sc)

	# Find start date and time, x hours before last data point
	nhours = config.sec10_hours
	nsec = nhours * 3600
	d = timedelta(seconds=nsec)
	start = endtime - d

	# Keep only the data within the right time frame
	x = []
	y = []
	for line in data:
		list = line.split()
		yr = int(list[0])
		mn = int(list[1])
		dy = int(list[2])
		hr = int(list[3])
		mi = int(list[4])
		sc = int(list[5])
		v = float(list[6])
		t = datetime(yr, mn, dy, hr, mi,sc)
		if t >= start:
			xp = decimalDate(yr, mn, dy, hr, mi, sc)
			x.append(xp)
			y.append(v)
		
	graph.clear()
	graph.createDataset(x, y, self.gas, linecolor="blue", symbol="None")
	graph.update()


    #----------------------------------------------
    def doHrVolt(self, graph):

#	s = '%s/%s/raw/*/*.%s' % (config.datadir, self.gas.lower(), self.gas.lower())
	s = '%s/%s/data/*/*.%s' % (config.datadir, self.gas.lower(), self.gas.lower())
	list = glob.glob(s)
	list.sort()
	filelist = list[-config.hravg_days:]
	s = " ".join(filelist)
        com = "python %s/bin/makeraw.py %s > /tmp/hrdata.txt " % (config.sysdir, s)
        os.system(com)


#	for file in filelist:
	x = {}
	y = {}
	file = "/tmp/hrdata.txt"
	f = open(file, "r")
	for line in f:

#SMP 2012 12 07 11  5 1.56083e-04 1.302e-05  12 . Line2
		list = line.split()
		id = list[0]
		year = int(list[1])
		month = int(list[2])
		day = int(list[3])
		hour = int(list[4])
		minute = int(list[5])
		value = float(list[6])

		xp = decimalDate(year, month, day, hour, minute)
		if id not in x:
			x[id] = []
			y[id] = []

		x[id].append(xp)
		y[id].append(value)

	f.close()

	graph.clear()
	for name in x:
		graph.createDataset(x[name], y[name], name)

	graph.update()

    #----------------------------------------------
    def doDayVolt(self, graph, year=0, month=0, day=0):

	if year ==0 or month == 0 or day== 0:
		s = '%s/%s/data/*/*' % (config.datadir, self.gas.lower())
		list = glob.glob(s)
		if len(list) == 0: return
		list.sort()
		filelist = list[-1:]
		file = filelist[0]
		s = os.path.basename(file)
		year = s[0:4]
		month = s[4:6]
		day = s[6:8]
	else:
		file = "%s/%s/data/%d/%d%02d%02d.%s" % (config.datadir, self.gas.lower(), year, year, month, day, self.gas.lower())

	x = []
	y = []
	if os.path.exists(file):
		f = open(file, "r")
		for line in f:
			list = line.split()
			yr = int(list[0])
			mn = int(list[1])
			dy = int(list[2])
			hr = int(list[3])
			mi = int(list[4])
			sc = int(list[5])
			v = float(list[6])

			xp = decimalDate(yr, mn, dy, hr, mi, sc)
			x.append(xp)
			y.append(v)

		f.close()

	else:
		s = "No data for that date."
                dlg = wx.MessageDialog(self, s, 'Warning', style=wx.OK | wx.ICON_WARNING)
                dlg.ShowModal()
                dlg.Destroy()
#                return

	graph.clear()
	graph.createDataset (x, y, self.gas, symbol='none', linecolor='blue')
	graph.title.text = "%s/%s/%s" % (year, month, day)
	graph.update()
