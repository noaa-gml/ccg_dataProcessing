
import os
import wx

import config

from graph.graph import Graph
from graph.dataset import Dataset
from panel_utils import run_command


#pages = { 0: 'N2O/SF6', 1: 'CO/H2', 2: 'CH4' }
pages = { 0: 'CH4' }

###############################################################
class mkGCPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
        self.timer = wx.Timer(self)
	self.lastmod = 0
	self.lastfile = ""

        box = wx.StaticBox(self, -1, "Chromatograms", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        for pagenum, pagelabel in pages.items():
                plot = Graph(self.nb, -1)
                plot.showGrid = 1
                plot.showSubgrid = 1
		plot.legend.showLegend = 0

                self.nb.AddPage(plot, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)
        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)


        self.SetSizer(sizer)

        self.Bind(wx.EVT_TIMER, self.refreshPage)

    #----------------------------------------------
    def updatePage(self):

        if self.IsShownOnScreen():

                page_num = self.nb.GetSelection()
                plot = self.nb.GetCurrentPage()
		gas = pages[page_num]
		if "/" in gas:
			(gas, xx) = gas.split("/")

		# check if file has changed since last time
		file = "%s/gc.%s.txt" % (config.sysdir, gas.lower())
		fstats = os.stat(file)
		modtime = fstats.st_mtime

		# if it has, replot chromatogram
		if modtime != self.lastmod or file != self.lastfile:
			self.lastmod = modtime
			self.lastfile = file
			self.doGCPlot(file, plot)

		if not self.timer.IsRunning():
			self.timer.Start(config.page_refresh)
	else:
		self.timer.Stop()

    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()


    #----------------------------------------------
    def doGCPlot(self, file, graph):
	""" Plot the most recent chromatogram """

        x = []
        y = []
        if os.path.exists(file):
                f = open(file, "r")
		line = f.readline()
		list = line.split()
		yr = int(list[0])
		mn = int(list[1])
		dy = int(list[2])
		hr = int(list[3])
		mi = int(list[4])
		title = "%d/%d/%d %d:%d" % (yr, mn, dy, hr, mi)
		line = f.readline()  
		line = f.readline()  # sample rate
		rate = float(line)
		line = f.readline()
		n = 0
                for line in f:
                        v = float(line)
			xp = n / rate
			x.append(xp)
			y.append(v)
			n = n + 1
                f.close()


        graph.clear()
        dataset = Dataset(x,y, name=self.gas)
        dataset.style.setLineColor("red")
        graph.addDataset(dataset)
	graph.title.text = title

	self.setPeakData(graph, file)

        graph.update()


    #----------------------------------------------
    def setPeakData(self, graph, file):


        # Run helper program to get peak info.
        command = "%s/bin/gcshow -d %s -r %s" % (config.sysdir, config.sysdir+"/ch4", file)
	(err, output) = run_command(command)

        if err:
                print("Error in running command %s: %s", command, output)
                return


        # Each line has peak name, height, area, retention time, peak width,
        # baseline code, start time, stop time, start level, stop level.
        peaks = []
        for line in output.split("\n"):
                list = line.split()
                if len(list) == 10: 
                        p = Peak()
                        p.name = list[0]
                        p.height = float(list[1])
                        p.area = float(list[2])
                        p.retention_time = float(list[3])
                        p.peak_width = float(list[4])
                        p.baseline_code = list[5]
                        p.start_time = float(list[6])
                        p.end_time = float(list[7])
                        p.start_level = int(list[8])
                        p.end_level = int(list[9])

                        s  = "     Peak Name: %s\n" % p.name
                        s += "   Peak Height: %g\n" % p.height
                        s += "     Peak Area: %g\n" % p.area
                        s += "Retention Time: %g\n" % p.retention_time
                        s += "    Peak Width: %g\n" % p.peak_width
                        s += " Baseline Code: %s\n" % p.baseline_code
                        s += "    Start Time: %g\n" % p.start_time
                        s += "      End Time: %g\n" % p.end_time
                        s += "   Start Level: %d\n" % p.start_level
                        s += "     End Level: %d"   % p.end_level

                        peaks.append(p)
                        t = graph.Text(p.retention_time, p.start_level, p.name, s)
                        t.setPopup(1)

                        # Create dataset for peak baseline
                        # Just use linear line for now. Actual baseline could be
                        # curved, but that requires more work.
                        xp = [p.start_time, p.end_time]
                        yp = [p.start_level, p.end_level]
                        graph.createDataset (xp, yp, p.name + "baseline", symbol="circle", linecolor='blue', color='blue')


#####################################################################3333
class Peak:

    def __init__(self):

        self.name = ""
        self.height = 0.0
        self.area = 0.0
        self.retention_time = 0.0
        self.peak_width = 0.0
        self.baseline_code = ""
        self.start_time = 0.0
        self.end_time = 0.0
        self.start_level = 0
        self.end_level = 0

