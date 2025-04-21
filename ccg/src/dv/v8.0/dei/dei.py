# vim: tabstop=4 shiftwidth=4 expandtab
import os
import sys
import datetime
import glob
import numpy
import wx

from graph5.graph import Graph
from graph5.dataset import Dataset
from graph5.toolbars import ZoomToolBar
from graph5.style import Style

from common.FileView import FileView

sys.path.append("/ccg/src/python3/lib")
import ccg_dates

from .mbl import MblDialog
from .bs_mbl import BsMblDialog
from .setloc import DEIDialog
from .latgrad import LatGradDialog
from .help import HelpDialog


######################################################################
class Dei(wx.Frame):
    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(700, 550))

        self.deidlg = None
        self.mbldlg = None
        self.helpdlg = None
        self.bsmbldlg = None
        self.latgraddlg = None
        self.plot_has_latgrad = False
        self.plot_has_time_series = False
        self.has_bootstrap = False
        self.resultsdir = None
        self.param = None

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()
#        self.SetStatusText("This is the statusbar")

        # make static text to hold location of dei run
        hsizer = wx.BoxSizer(wx.HORIZONTAL)
        label = wx.Button(self, -1, "DEI Location:")
        self.Bind(wx.EVT_BUTTON, self.set_location, label)
        hsizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

        self.location = wx.StaticText(self, -1, "Not set.")
        hsizer.Add(self.location, 1, wx.EXPAND|wx.ALL, 5)
        self.sizer.Add(hsizer)

        # make the initial graph.
        plot = Graph(self, -1)
        self.current_plot = plot

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self, plot)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)
        self.sizer.Add(plot, 1, wx.EXPAND, 0)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    #----------------------------------------------
    def MakeMenuBar(self):
        menuBar = wx.MenuBar()

        menu = wx.Menu()
        menu.Append(100, "New", "Remove datasets and start fresh")
#        menu.Append (102, "Set DEI Results Location...")
        menu.AppendSeparator ()
        menu.Append (110, "Print Preview...")
        menu.Append (111, "Print")

        self.Bind(wx.EVT_MENU, self.new, id=100)
#        self.Bind(wx.EVT_MENU, self.set_location, id=102)
        self.Bind(wx.EVT_MENU, self.print_preview, id=110)
        self.Bind(wx.EVT_MENU, self.print_, id=111)

        menu.AppendSeparator ()
        menu.Append(101, "Close", "Close this window")
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        menuBar.Append(menu, "&File")

        #---------------------------------------
        self.view_menu = wx.Menu()
        menuBar.Append (self.view_menu, "View")
        self.view_menu.Append(200, "Browse...")
        self.view_menu.Append(201, "Sync Steps")
        self.view_menu.Append(202, "MBL Zones")
        self.view_menu.Append(203, "Custom MBL Zone")
        self.view_menu.Append(204, "Bootstrap MBL Zones")
        self.view_menu.Append(205, "Latitude Gradients")

        self.view_menu.Enable(200, False)
        self.view_menu.Enable(201, False)
        self.view_menu.Enable(202, False)
        self.view_menu.Enable(203, False)
        self.view_menu.Enable(204, False)
        self.view_menu.Enable(205, False)

        self.Bind(wx.EVT_MENU, self.browse, id=200)
        self.Bind(wx.EVT_MENU, self.view_sync, id=201)
        self.Bind(wx.EVT_MENU, self.view_mbl, id=202)
        self.Bind(wx.EVT_MENU, self.view_bs_mbl, id=204)
        self.Bind(wx.EVT_MENU, self.view_lat_grad, id=205)

        #---------------------------------------
        self.help_menu = wx.Menu()
        menuBar.Append (self.help_menu, "Help")
        self.help_menu.Append(300, "Ext file description...")
        self.help_menu.Append(301, "Fits file description...")

        self.Bind(wx.EVT_MENU, self.help, id=300)
        self.Bind(wx.EVT_MENU, self.help, id=301)

        self.SetMenuBar(menuBar)


    #----------------------------------------------
    def new(self, evt):
        msg = "This will remove all data! Are you sure you want to continue?"
        dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING)
        answer = dlg.ShowModal()
        if answer == wx.ID_YES:
            self.current_plot.clear()
            self.current_plot.update()
        dlg.Destroy()

    #----------------------------------------------
    def update_menus(self):

        self.view_menu.Enable(200, True)
        self.view_menu.Enable(201, True)
        self.view_menu.Enable(202, True)
        self.view_menu.Enable(205, True)

        if self.has_bootstrap:
            self.view_menu.Enable(204, True)
        else:
            self.view_menu.Enable(204, False)


    #----------------------------------------------
    def OnExit(self,e):
        self.Close(True)  # Close the frame.

    #----------------------------------------------
    def print_(self, event):
        self.current_plot.print_()

    #----------------------------------------------
    def print_preview(self, event):
        self.current_plot.printPreview()

    #----------------------------------------------
    def view_sync(self, evt):

        filename = self.resultsdir + "/syncsteps"
        dlg = FileView(self, filename)
        dlg.Show()

    #----------------------------------------------
    def help(self, evt):

        evtid = evt.GetId()
        if evtid == 300:
            topic='ext'
        if evtid == 301:
            topic='fit'

        if self.helpdlg is None:
            self.helpdlg = HelpDialog(self)

        self.helpdlg.showTopic(topic)
        val = self.helpdlg.Show()


    #----------------------------------------------
    def set_location(self, evt):
        """ Set the directory where dei results reside """

        if self.deidlg is None:
            self.deidlg = DEIDialog(self)
            self.deidlg.CenterOnScreen()

        val = self.deidlg.ShowModal()

        if val == wx.ID_OK:

            print("dei dir is ", self.deidlg.deidir)
            self.resultsdir = self.deidlg.deidir
            self.param = self.deidlg.param
            self.location.SetLabel(self.resultsdir)

            s = self.resultsdir + "/bs_*"
            files = glob.glob(s)
            if len(files) > 0:
                self.has_bootstrap = True
            else:
                self.has_bootstrap = False


            self.update_menus()

            self.latgraddlg = None


    #----------------------------------------------
    def browse(self, evt):
        """ Open a file selection dialog for choosing files """

        dlg = wx.FileDialog(
            self, message="Choose a file", defaultDir=self.resultsdir,
            defaultFile="", style=wx.FD_OPEN | wx.FD_CHANGE_DIR | wx.FD_MULTIPLE
            )
        if dlg.ShowModal() == wx.ID_OK:
            if self.plot_has_latgrad:
                self.current_plot.clear()
                self.plot_has_latgrad = False

            paths = dlg.GetPaths()
            for path in paths:
                print(path)
                try:
                    a = numpy.loadtxt(path)
                    print(a)
                    print(a.shape)
                    ncols = a.shape[1]
                    for i in range(1, ncols):
                        x = a.T[0]
                        y = a.T[i]
                        w = numpy.where(a.T[i] > -900)
                        yp = y[w]
                        xp = [ccg_dates.datetimeFromDecimalDate(dd) for dd in x[w].tolist()]

                        name = os.path.basename(path) + " column %d" % i
                        self.current_plot.createDataset(xp, yp, name)

                except TypeError as err:
                    print(err)

            self.plot_has_time_series = True

        dlg.Destroy()

        self.current_plot.update()


    #----------------------------------------------
    def _get_zone_filename(self, zone):
        """ Get the filename for a given zone """

        filename = None

        if "Global" in zone:                          filename = "zone_gl.mbl"
        elif "Arctic" in zone:                        filename = "zone_arctic.mbl"
        elif "Low Northern Hemisphere" in zone:       filename = "zone_lnh.mbl"
        elif "Temperate Northern Hemisphere" in zone: filename = "zone_tnh.mbl"
        elif "High Northern Hemisphere" in zone:      filename = "zone_hnh.mbl"
        elif "Polar Northern Hemisphere" in zone:     filename = "zone_pnh.mbl"
        elif "Northern Hemisphere" in zone:           filename = "zone_nh.mbl"
        elif "Low Southern Hemisphere" in zone:       filename = "zone_lsh.mbl"
        elif "Temperate Southern Hemisphere" in zone: filename = "zone_tsh.mbl"
        elif "High Southern Hemisphere" in zone:      filename = "zone_hsh.mbl"
        elif "Polar Southern Hemisphere" in zone:     filename = "zone_psh.mbl"
        elif "Southern Hemisphere" in zone:           filename = "zone_sh.mbl"
        elif "Tropics" in zone:                       filename = "zone_tropics.mbl"
        elif "Equatorial" in zone:                    filename = "zone_equ.mbl"
        elif "Custom" in zone:                        filename = "surface.mbl"

        return filename

    #----------------------------------------------
    def view_mbl(self, evt):
        """ plot a pre-defined zone """

        if self.mbldlg is None:
            self.mbldlg = MblDialog(self)
            self.mbldlg.CenterOnScreen()

        val = self.mbldlg.ShowModal()

        if val == wx.ID_OK:

            if self.plot_has_latgrad:
                self.current_plot.clear()
                self.plot_has_latgrad = False

            zone = self.mbldlg.zone
            data_type = self.mbldlg.data_type

            filename = self._get_zone_filename(zone)
            if "averages" in data_type.lower():
                filename += ".ann.ave.sc"
            elif "increase" in data_type.lower():
                filename += ".ann.inc.tr"

            filename += ".%s" % self.param
            filename = self.resultsdir + "/" + filename

            print(filename)

            x = []
            y = []
            f=open(filename, 'r')
            for line in f:
                items = line.split()
                xp = ccg_dates.datetimeFromDecimalDate(float(items[0]))
                yp = float(items[1])

                x.append(xp)
                y.append(yp)

            f.close()
            a = zone.split("(")
            name = a[0] + self.param

            if "averages" in data_type.lower():
                self.current_plot.createDataset(x, y, name, linetype="None")
            elif "increase" in data_type.lower():
                self.current_plot.createDataset(x, y, name, linetype="None")
            else:
                self.current_plot.createDataset(x, y, name, symbol="None", linewidth=2)

            self.current_plot.update()
            self.plot_has_time_series = True


    #----------------------------------------------
    def view_bs_mbl(self, evt):
        """ plot a pre-defined zone from a bootstrap run """

        if self.bsmbldlg is None:
            self.bsmbldlg = BsMblDialog(self)
            self.bsmbldlg.CenterOnScreen()

        val = self.bsmbldlg.ShowModal()

        if val == wx.ID_OK:
            zone = self.bsmbldlg.zone
            bootstrap_type = self.bsmbldlg.bootstrap
            bootstrap_dir = self.bsmbldlg.bootstrap_dir
            curve_type = self.bsmbldlg.curve_type

            filename = self._get_zone_filename(zone)

            if curve_type.lower() == "growth rate":
                filename += ".gr"
            elif curve_type.lower() == "trend":
                filename += ".tr"

            filename += ".unc.%s" % self.param

            filename = self.resultsdir + "/" + "bs_%s" % bootstrap_type.lower() + "/" + bootstrap_dir + "/" + filename

            print(filename)

            x = []
            y = []
            yunch = []
            yuncl = []
            f=open(filename, 'r')
            for line in f:
                items = line.split()
                xp=float(items[0])
                (yr,mn,dy,hr,mi,sc) = ccg_dates.calendarDate(xp)
#                print yr, mn, dy, hr, mi, sc
                xp = datetime.datetime(yr, mn, dy, hr, mi, sc)
                yp=float(items[1])
                if len(items) > 2:
                    yp2 = float(items[2])
                    yunch.append(yp + yp2)
                    yuncl.append(yp - yp2)


                x.append(xp)
                y.append(yp)

            f.close()
            a = zone.split("(")
            name = a[0] + bootstrap_type + self.param

            dataset = self.current_plot.createDataset(x, y, name, symbol="None", linewidth=1)
            color = dataset.style.lineColor
            self.current_plot.createDataset(x, yunch, name+"unc+", symbol="None", linewidth=1, linetype="short dash", color=color)
            self.current_plot.createDataset(x, yuncl, name+"unc-", symbol="None", linewidth=1, linetype="short dash", color=color)

            self.current_plot.update()

    #----------------------------------------------
    def view_lat_grad(self, evt):
        """ plot a latitude gradient """

        if self.latgraddlg is None:
            self.latgraddlg = LatGradDialog(self)
            self.latgraddlg.CenterOnScreen()

        val = self.latgraddlg.ShowModal()

        if val == wx.ID_OK:
            print(self.latgraddlg.timestep)

            if self.plot_has_time_series:
                self.current_plot.clear()
                self.plot_has_time_series = False

            x = []
            y = []
            wts = []

            filename = "/".join([self.resultsdir, "merid.data.srfc.mbl.log"])

            nsites = 0
            f = open(filename)
            for line in f:
                if self.latgraddlg.timestep in line:
                    (ts, nsites) = line.strip().split()
                    nsites = int(nsites)
                    continue

                if nsites:
                    (lat, val, wt, scode) = line.split()
                    x.append(float(lat))
                    y.append(float(val))
                    wts.append(round(float(wt), 0))

                    if len(x) == nsites:
                        break
            f.close()

#            pattern = self.resultsdir + "/surface.mbl.*"
#            files = glob.glob(pattern)
#            mblfile = files[0]
            mblfile = self.resultsdir + "/surface.mbl.%s" % self.param
            a = numpy.loadtxt(mblfile)
            idx = (numpy.abs(a.T[0]-float(self.latgraddlg.timestep))).argmin()

            y2 = a[idx,1:]
            x2 = [n * 0.05 - 1 for n in range(41)]

            name = self.latgraddlg.timestep
            ds = self.current_plot.createDataset(x2, y2, name, symbol="None", linewidth=2)
            color = ds.style.fillColor

            # create a data set for the value going into the latitude gradient
            # and create a style for each weight (1-10)
            dataset = Dataset(x, y, name)
            dataset.SetWeights(wts)
            styles = []
            for i in range(11):
                style = Style()
                style.setFillColor(color)
                style.setOutlineWidth(1)
                style.setMarker("CIRCLE")
                style.setMarkerSize(i)
                style.setLineType("None")
                dataset.SetStyle(style)
                dataset.SetWeightStyle(i, style)

            #    styles.append(style)

            self.current_plot.addDataset(dataset)

            self.current_plot.update()
            self.plot_has_latgrad = True
