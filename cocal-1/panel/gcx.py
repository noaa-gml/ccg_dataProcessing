
import os
import wx
import subprocess

import panel_config as config

from graph5.graph import Graph
from graph5.dataset import Dataset
#from utils import *
#import panel_utils as utils


#pages = { 0: 'N2O/SF6', 1: 'CO/H2', 2: 'CH4' }
pages = { 0: 'SF6', 1: 'H2'}

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
            if page_num == 0:
                self.gas = "SF6"
            elif page_num == 1:
                self.gas = "H2"
            else:
                self.gas = "CH4"

            # check if file has changed since last time
            file = "%s/gc.%s.txt" % (config.sysdir, self.gas.lower())
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
            title = "%d/%02d/%02d %02d:%02d" % (yr, mn, dy, hr, mi)
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


            # call gcdata to get peak info
            r, output = self.getPeakData(file, peakInfo=True)
            encoding = 'utf-8'
            output = str(output, encoding)

            if r == 0:
                # Each line has peak name, height, area, retention time, peak width,
                # baseline code, start time, stop time, start level, stop level.
                peaks = []
                for line in output.split("\n"):
                    a = line.split()
                    if len(a) == 10:
                        name = a[0]
                        height = float(a[1])
                        area = float(a[2])
                        retention_time = float(a[3])
                        peak_width = float(a[4])
                        baseline_code = a[5]
                        start_time = float(a[6])
                        end_time = float(a[7])
                        start_level = int(a[8])
                        end_level = int(a[9])

                        s  = "     Peak Name: %s\n" % name
                        s += "   Peak Height: %g\n" % height
                        s += "     Peak Area: %g\n" % area
                        s += "Retention Time: %g\n" % retention_time
                        s += "    Peak Width: %g\n" % peak_width
                        s += " Baseline Code: %s\n" % baseline_code
                        s += "    Start Time: %g\n" % start_time
                        s += "      End Time: %g\n" % end_time
                        s += "   Start Level: %d\n" % start_level
                        s += "     End Level: %d"   % end_level

                        t = graph.Text(retention_time, start_level, name, s)
                        t.setPopup(True)

                        # Create dataset for peak baseline
                        # Just use linear line for now. Actual baseline could be curved
                        xp = [start_time, end_time]
                        yp = [start_level, end_level]
                        graph.createDataset(xp, yp, name + "baseline", symbol="circle")

            graph.update()

    #----------------------------------------------
    def getPeakData(self, sourcefile, peakInfo=False):
        """ Run the gcdata command to get chromatogram data
        Return the output from the command
        """

        # Run helper program on source file, get output
        command = []
        command.append("gcdata")
        command.append("-d")
        command.append("%s/%s" % (config.sysdir, self.gas.lower()))

        if peakInfo:
                command.append("-r")
        command.append("%s" % sourcefile)

#        print command
        try:
            p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output,errors = p.communicate()
            return 0, output
        except OSError as e:
            print(command)
            msg = "Error running process.\nError was: %s\n" % e
            return 1, msg
