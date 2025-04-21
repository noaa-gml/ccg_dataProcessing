

from datetime import datetime, timedelta
import time

import os
import glob
import wx

import config

from graph5.graph import Graph
from graph5.dataset import Dataset
from panel_utils import *

pages = { 0: 'Recent Data', 1: 'QC for a Day' }
colors = [ 'red', 'green3', 'blue', 'magenta', 'dodgerblue1', 'yellow2', 'chocolate2', 'purple', 'navy', ]

###############################################################
class mkQCPlotPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
        self.t2 = wx.Timer(self)
        self.plot = []

        box = wx.StaticBox(self, -1, "QC Plot", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

	self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        for pagenum, pagelabel in pages.items():
                if pagenum != 1:
                        plot = Graph(self.nb, -1)
                        xaxis = plot.getXAxis(0)
                        xaxis.scale_type = "time"
                        plot.showGrid = 1
                        plot.showSubgrid = 1
#			plot.legend.showLegend = 1
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

                self.doDayQC(self.plot[1], dt.year, dt.month, dt.day)


    #----------------------------------------------
    def updatePage(self):
        if self.nb.IsShownOnScreen():
                page_num = self.nb.GetSelection()
#               page = self.nb.GetCurrentPage()
                page = self.plot[page_num]
                if page_num == 0:
			self.doQCPlot(self.plot[page_num])
			self.t2.Start(config.qcplot_refresh)
                elif page_num == 1:
			print("do day qc")
                        self.doDayQC(page)
                        self.t2.Stop()

        else:
                self.t2.Stop()


    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def lastAvailableDate(self):

	channellist = []
	f = open("%s/qc/qcchannels" % config.sysdir)
	for line in f:
		if line[0] == '#': continue
		(channel, name, units, dirname, active) = line.split(":")
		dirname = dirname.strip()
		active = int(active)
		if active:
			channellist.append(dirname)


        # Get a list of all available files
        s = '%s/qc/*/%s/*' % (config.datadir, channellist[0])
        list = glob.glob(s)
        list.sort()

	lastfile = list[-1:]
	file = os.path.basename(lastfile[0])
	(year, month, day) = file.split("-")
	year = int(year)
	month = int(month)
	day = int(day)

	print(year, month, day)
	endtime = datetime(year, month, day)
	return endtime

    #----------------------------------------------
    def doQCPlot(self, graph):


	graph.clear()

	endtime = self.lastAvailableDate()

        # Find start date and time, x days before last data point
        ndays = config.qc_days
        d = timedelta(days=ndays)
        start = endtime - d

	channellist = []
	channelnames = []
	f = open("%s/qc/qcchannels" % config.sysdir)
	for line in f:
		if line[0] == '#': continue
		(channel, name, units, dirname, active) = line.split(":")
		dirname = dirname.strip()
		active = int(active)
		if active:
			channellist.append(dirname)
			channelnames.append(name)

	n = 0
	for channel,name in zip(channellist, channelnames):
		s = '%s/qc/%s/%s/%s-%02d*' % (config.datadir, start.year, channel, start.year, start.month)
		list = glob.glob(s)

		if (endtime.month != start.month):
			s = '/%s/qc/%s/%s/%s%02d*' % (config.datadir, endtime.year, channel, endtime.year, endtime.month)
			list.extend(glob.glob(s))

		list.sort()
		filelist = list[-config.qc_days:]

		x = []
		y = []
		for file in filelist:
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
				t = datetime(yr, mn, dy, hr, mi,sc)
				if t >= start:
					xp = decimalDate(yr, mn, dy, hr, mi, sc)
					x.append(xp)
					y.append(v)

			f.close()

		dataset = Dataset(x,y, name=name)
		dataset.style.setLineColor(colors[n % len(colors)])
		graph.addDataset(dataset)
		n = n + 1


	graph.update()
	
    #----------------------------------------------
    def doDayQC(self, graph, year=0, month=0, day=0):

	graph.clear()

	if year ==0 or month ==0 or day==0:
		endtime = self.lastAvailableDate()
		year = endtime.year
		month = endtime.month
		day = endtime.day

	channellist = []
	channelnames = []
	f = open("%s/qc/qcchannels" % config.sysdir)
	for line in f:
		if line[0] == '#': continue
		(channel, name, units, dirname, active) = line.split(":")
		dirname = dirname.strip()
		active = int(active)
		if active:
			channellist.append(dirname)
			channelnames.append(name)

	n = 0
	for channel, name in zip(channellist,channelnames):
		file = '/%s/qc/%s/%s/%s-%02d-%02d' % (config.datadir, year, channel, year, month, day)
		if os.path.exists(file):
			x = []
			y = []
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

			dataset = Dataset(x,y, name=name)
			dataset.style.setLineColor(colors[n % len(colors)])
			graph.addDataset(dataset)
			n = n + 1

		else:
			s = "No data for that date."
			dlg = wx.MessageDialog(self, s, 'Warning', style=wx.OK | wx.ICON_WARNING)
			dlg.ShowModal()
			dlg.Destroy()
			return

	graph.title.text = "%s/%s/%s" % (year, month, day)
	graph.update()
