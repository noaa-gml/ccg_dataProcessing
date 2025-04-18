# vim: tabstop=4 shiftwidth=4 expandtab
""" A general purpose graphing window """

import os
import glob
from math import sqrt
from collections import defaultdict
import wx

from graph5.graph import Graph
from graph5.toolbars import ZoomToolBar

import ccg_dates
import ccg_dbutils

from common.stats import StatsDialog
from common.hist import HistDialog
from common.regres import RegressionDialog
from common import get
from common.importdata import ImportDialog
from common.getimportdata import getImportData

# from common import getinsitu
from .getinsitu import GetInsituDataDialog

from .target import TargetDialog
from .fic import FICDialog
from .save import SaveDialog
from .mbl import MblDialog
from .met import MetDialog

LAYOUT_VERTICAL = 1
LAYOUT_HORIZONTAL = 2
LAYOUT_GRID = 3


######################################################################
class Grapher(wx.Frame):
    """ A general purpose graphing window """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(850, 750))

        self.getdlg = None
        self.targetdlg = None
        self.ficdlg = None
        self.pairdlg = None
        self.metdlg = None
        self.mbldlg = None
        self.insitudlg = None
        self.importdlg = None

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # make the initial graph.
        self.plot_list = []
        plot = Graph(self, -1)
        self.current_plot = plot
        self.plot_list.append(plot)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()
#        self.SetStatusText("This is the statusbar")

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self, self.current_plot)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)

        # We will put the graphs in a grid sizer
        self.sizer2 = wx.GridSizer(0, 1, 1, 1)
#        self.sizer2 = wx.GridSizer(1,5,5)
        self.layout = LAYOUT_VERTICAL

        self.addGraphToSizer(plot)

        # Add the graphs sizer to the main sizer
        self.sizer.Add(self.sizer2, 1, wx.EXPAND | wx.ALL, 0)

        self.update_menus()

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ create the menu bar """

        menuBar = wx.MenuBar()

        menu = wx.Menu()
#        menu.AppendSeparator()
        menu.Append(100, "New", "Remove datasets and start fresh")

        addmenu = wx.Menu()
#        mkMenuItem(addmenu, 1001, "Flask - InSitu Comparison", self.fic)

        addmenu.Append(1001, "Flask - InSitu Comparison")
        addmenu.Append(1002, "Flask Pair Difference")
        addmenu.Append(1003, "In-Situ Raw Mixing Ratios")
        addmenu.Append(1006, "InSitu Target Cals")
        addmenu.Append(1009, "Observatory Meteorology")
        addmenu.Append(1008, "MBL Zone Reference")
        menu.Append(-1, "Add Data", addmenu)

        self.Bind(wx.EVT_MENU, self.fic, id=1001)
        self.Bind(wx.EVT_MENU, self.pairdiff, id=1002)
        self.Bind(wx.EVT_MENU, self.insitu_raw, id=1003)
        self.Bind(wx.EVT_MENU, self.target, id=1006)
        self.Bind(wx.EVT_MENU, self.mbl, id=1008)
        self.Bind(wx.EVT_MENU, self.met, id=1009)

        menu.Append(102, "Get Data...")
        menu.Append(106, "Import...")
        menu.Append(112, "Load Graph...")
        menu.AppendSeparator()
        menu.Append(107, "Save Dataset...")
        menu.Append(109, "Save Graph...")
        menu.Append(108, "Save Graph as Image...")
        menu.AppendSeparator()
        menu.Append(110, "Print Preview...")
        menu.Append(111, "Print")

        self.Bind(wx.EVT_MENU, self.new, id=100)
        self.Bind(wx.EVT_MENU, self.getdata, id=102)
        self.Bind(wx.EVT_MENU, self.importdata, id=106)
        self.Bind(wx.EVT_MENU, self.savedata, id=107)
        self.Bind(wx.EVT_MENU, self.saveimage, id=108)
        self.Bind(wx.EVT_MENU, self.savegraph, id=109)
        self.Bind(wx.EVT_MENU, self.print_preview, id=110)
        self.Bind(wx.EVT_MENU, self.print_, id=111)
        self.Bind(wx.EVT_MENU, self.loadgraph, id=112)

        menu.AppendSeparator()
        menu.Append(101, "Close", "Close this window")
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        menuBar.Append(menu, "&File")

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.edit_menu.Append(200, "Paste")
        self.edit_menu.AppendSeparator()
#        self.edit_menu.Append(201, "Data Editor...")
        self.edit_menu.Append(202, "Graph Preferences...")
        self.edit_menu.AppendSeparator()
        self.edit_menu.Append(203, "Delete Graph")
#        self.edit_menu.Enable(203, False)
        menuBar.Append(self.edit_menu, "Edit")

        self.Bind(wx.EVT_MENU, self.paste, id=200)
        self.Bind(wx.EVT_MENU, self.graph_prefs, id=202)
        self.Bind(wx.EVT_MENU, self.delete_graph, id=203)

#        self.edit_menu.Enable(201, False)

        # ---------------------------------------
        menu = wx.Menu()
        menuBar.Append(menu, "View")

        toolbarmenu = wx.Menu()
#        toolbarmenu.Append(-1, "Application Toolbar", "", wx.ITEM_CHECK)
        m = toolbarmenu.Append(1111, "Zoom Toolbar", "", wx.ITEM_CHECK)
        m.Check()
        menu.Append(-1, "Toolbars", toolbarmenu)
        self.Bind(wx.EVT_MENU, self.toggleZoomToolBar, id=1111)

        # Graph layout menu
        graphmenu = wx.Menu()
        graphmenu.Append(2220, "Vertical", "", wx.ITEM_RADIO)
        graphmenu.Append(2221, "Horizontal", "", wx.ITEM_RADIO)
        graphmenu.Append(2222, "Grid", "", wx.ITEM_RADIO)
        menu.Append(-1, "Graph Layout", graphmenu)

        self.Bind(wx.EVT_MENU, self.setGraphLayout, id=2220)
        self.Bind(wx.EVT_MENU, self.setGraphLayout, id=2221)
        self.Bind(wx.EVT_MENU, self.setGraphLayout, id=2222)

        # --- Zoom menu
        zoommenu = wx.Menu()
        m = zoommenu.Append(-1, "Set Scale", "", wx.ITEM_CHECK)
        if self.current_plot.zoomEnabled:
            m.Check()
        zoommenu.Append(-1, "Autoscale")
        zoommenu.Append(-1, "Zoom In",)
        zoommenu.Append(-1, "Zoom Out")
        zoommenu.Append(-1, "Zoom In Vertical",)
        zoommenu.Append(-1, "Zoom Out Vertical")
        zoommenu.Append(-1, "Zoom In Horizontal",)
        zoommenu.Append(-1, "Zoom Out Horizontal")
        zoommenu.Append(-1, "Pan Left")
        zoommenu.Append(-1, "Pan Right")
        zoommenu.Append(-1, "Pan Up")
        zoommenu.Append(-1, "Pan Down")
        menu.Append(-1, "Zoom", zoommenu)

        # ---------------------------------------
        menu = wx.Menu()
        menuBar.Append(menu, "Insert")

#        toolbarmenu = wx.Menu()
#        toolbarmenu.Append(-1, "Random Numbers...")
#        toolbarmenu.Append(-1, "Sine Wave...")
#        toolbarmenu.Append(-1, "Sequence of Numbers...")
#        toolbarmenu.Append(-1, "Function...")
#        menu.Append(401, "Data Set", toolbarmenu)
#        menu.AppendSeparator ()
        menu.Append(404, "New X Axis")
        menu.Append(405, "New Y Axis")
        menu.Append(406, "New Graph")

        self.Bind(wx.EVT_MENU, self.addXAxis, id=404)
        self.Bind(wx.EVT_MENU, self.addYAxis, id=405)
        self.Bind(wx.EVT_MENU, self.addGraph, id=406)

#        menu.Enable(401, False)

        # ---------------------------------------
        menu = wx.Menu()
        menuBar.Append(menu, "Analysis")
        menu.Append(501, "Interpolation...")
        menu.Append(502, "Regression...")
        menu.Append(503, "Smoothing...")
        menu.Append(504, "Statistics...")
        menu.Append(505, "Histogam...")

        self.Bind(wx.EVT_MENU, self.regression, id=502)
        self.Bind(wx.EVT_MENU, self.stats, id=504)
        self.Bind(wx.EVT_MENU, self.hist, id=505)

        menu.Enable(501, False)
        menu.Enable(503, False)

        # ---------------------------------------
        menu = wx.Menu()
        menu.Append(501, "&About...", "More information about this program")
        menuBar.Append(menu, "&Help")

        self.SetMenuBar(menuBar)

    # ----------------------------------------------
    def loadgraph(self, evt):
        """ load the contents of a saved graph """

        self.current_plot.loadGraph()

    # ----------------------------------------------
    def savegraph(self, evt):
        """ save the contents of the current graph to file """

        self.current_plot.saveGraph()

    # ----------------------------------------------
    def saveimage(self, evt):
        """ save an image of the current graph to file """

        image = self.current_plot.getImage()

        dlg = wx.FileDialog(self, message="Choose a file", defaultDir=os.getcwd(),
                            defaultFile="", style=wx.FD_SAVE | wx.FD_CHANGE_DIR | wx.FD_OVERWRITE_PROMPT
                            )
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
            for path in paths:
                outputfile = path
                image.SaveFile(outputfile, wx.BITMAP_TYPE_PNG)

    # ----------------------------------------------
    def new(self, evt):
        """ Clear the current graph of all datasets """

        msg = "This will remove all data! Are you sure you want to continue?"
        dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING)
        answer = dlg.ShowModal()
        if answer == wx.ID_YES:
            self.current_plot.clear()
            self.current_plot.update()
        dlg.Destroy()

    # ----------------------------------------------
    def update_menus(self):
        """ Update the setting of the menu items

        Usually called when current_plot changes or plot_list changes
        Disable delete graph if only 1 graph
        """

        if len(self.plot_list) == 1:
            self.edit_menu.Enable(203, False)
        else:
            self.edit_menu.Enable(203, True)

    # ----------------------------------------------
    def delete_graph(self, evt):
        """ delete a graph from the window """

        self.sizer2.Detach(self.current_plot)
        self.setLayout()

        self.plot_list.remove(self.current_plot)
        self.current_plot.Destroy()
        self.setCurrentPlot(self.plot_list[0])
        self.update_menus()

    # ----------------------------------------------
    def setLayout(self):
        """ redo the layout of the graph in the window """

        if self.layout == LAYOUT_VERTICAL:
            nrows = len(self.plot_list)
            ncols = 1
        if self.layout == LAYOUT_HORIZONTAL:
            nrows = 1
            ncols = len(self.plot_list)
        if self.layout == LAYOUT_GRID:
            n = len(self.plot_list) - 1
            nrows = int(sqrt(n)) + 1
            ncols = n/nrows + 1

        self.sizer2.SetRows(nrows)
        self.sizer2.SetCols(ncols)
        self.sizer2.Layout()

    # ----------------------------------------------
    def setGraphLayout(self, evt):
        """ set how graphs are layed out in window """

        evtid = evt.GetId()
        if evtid == 2220:
            self.layout = LAYOUT_VERTICAL
        if evtid == 2221:
            self.layout = LAYOUT_HORIZONTAL
        if evtid == 2222:
            self.layout = LAYOUT_GRID
        self.setLayout()

    # ----------------------------------------------
    def toggleZoomToolBar(self, evt):
        """ toggle visual state of zoom toolbar """

        if evt.IsChecked():
            self.sizer.Show(self.zoomtb)
        else:
            self.sizer.Hide(self.zoomtb)
        self.sizer.Layout()

    # ----------------------------------------------
    def graph_prefs(self, evt):
        """ show the graph preferences dialog """

        self.current_plot.showPrefsDialog(evt)

    # ----------------------------------------------
    def paste(self, evt):
        """ paste a dataset into the current graph """

#                if self.current_plot.saveDataset:
#            self.current_plot.addDataset(self.current_plot.saveDataset)
#            self.current_plot.update()
        import pickle

        if wx.TheClipboard.Open():
            mydata = wx.CustomDataObject("Dataset")
            r = wx.TheClipboard.GetData(mydata)
            if r:
                dataset = pickle.loads(mydata.GetData())
                self.current_plot.addDataset(dataset)
                self.current_plot.update()
            else:
                print("No dataset to paste.")
                wx.TheClipboard.Close()
        else:
            print("Could not open clipboard for pasting.")

    # ----------------------------------------------
    def setCurrentPlot(self, plot):
        """ Set the active plot to another graph.

        Various things like zoom toolbar depend on knowing the current plot.
        """

        self.current_plot = plot
        self.zoomtb.SetGraph(plot)

    # ----------------------------------------------
    def selectGraph(self, event):
        """ User has clicked on one of the graphs.

        Make it the current plot so that things like zoom toolbar will work on it.
        """

        plot = event.GetEventObject()
        self.setCurrentPlot(plot)
        event.Skip()

    # ----------------------------------------------
    def addGraphToSizer(self, plot):
        """ add a graph widget to it's sizer """

        self.setLayout()
        self.sizer2.Add(plot, 1, wx.EXPAND, 0)
        self.sizer2.Layout()
        plot.Bind(wx.EVT_LEFT_DOWN, self.selectGraph)

    # ----------------------------------------------
    def addGraph(self, evt):
        """ add a new graph to the window """

        plot = Graph(self, -1)
        self.plot_list.append(plot)
        self.addGraphToSizer(plot)
        self.setCurrentPlot(plot)
        self.update_menus()

    # ----------------------------------------------
    def addXAxis(self, evt):
        """ add an X axis to the current plot """

        self.current_plot.addXAxis("")
        self.current_plot.update()

    # ----------------------------------------------
    def addYAxis(self, evt):
        """ add an Y axis to the current plot """

        self.current_plot.addYAxis("")
        self.current_plot.update()

    # ----------------------------------------------
    def savedata(self, e):
        """ Save data to file from current plot """

        savedlg = SaveDialog(self, graph=self.current_plot)
        savedlg.CenterOnScreen()
        savedlg.Show()

        # this does not return until the dialog is closed.
        savedlg.ShowModal()

        savedlg.Destroy()

    # ----------------------------------------------
    def importdata(self, e):
        """ import data from a file """

        if self.importdlg is None:
            self.importdlg = ImportDialog(self)
            self.importdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.importdlg.ShowModal()

        if val == wx.ID_OK:
            datasets = getImportData(self.importdlg.data)
            for name in datasets:
                df = datasets[name]
                x = df.iloc[:, 0].tolist()
                y = df.iloc[:, 1].tolist()
                self.current_plot.createDataset(x, y, name)
            self.current_plot.update()

        self.importdlg.Hide()

    # ----------------------------------------------
    def OnExit(self, e):
        """ exit the app """

        self.Close(True)  # Close the frame.

    # ----------------------------------------------
    def print_(self, event):
        """ print the current graph """

        self.current_plot.print_()

    # ----------------------------------------------
    def print_preview(self, event):
        """ show a print preview of the current plot """

        self.current_plot.printPreview()

    # ----------------------------------------------
    def stats(self,  evt):
        """ show statistics for datasets in current plot """

        statsdlg = StatsDialog(self, -1, graph=self.current_plot)
        statsdlg.CenterOnScreen()
        statsdlg.Show()

    # ----------------------------------------------
    def hist(self,  evt):
        """ show histogram for datasets in current plot """

        histdlg = HistDialog(self, -1, graph=self.current_plot)
        histdlg.CenterOnScreen()
        histdlg.Show()

    # ----------------------------------------------
    def regression(self, evt):
        """ do regressions for datasets in current plot """

        regresdlg = RegressionDialog(self, -1, graph=self.current_plot)
        regresdlg.CenterOnScreen()
        regresdlg.Show()

    # ----------------------------------------------
    def getdata(self, evt):
        """ get data from database """

        if self.getdlg is None:
            self.getdlg = get.GetDataDialog(self)
            self.getdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.getdlg.ShowModal()

        if val == wx.ID_OK:
            self.SetStatusText("Getting data...")
            self.getdlg.data.process_data(useDatetime=True)
            for data in self.getdlg.data.datasets:
                x = data.x
                y = data.y
                name = data.name

                dataset = self.current_plot.createDataset(x, y, name, linetype='None')
                if not dataset:
                    msg = "No data found for specified parameters (f{name})."
                    dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                    dlg.ShowModal()
                    dlg.Destroy()
                    break

            self.current_plot.update()

            self.SetStatusText("")

    # ----------------------------------------------
    def insitu_raw(self, evt):
        """ get insitu 'raw' data from database """

        if self.insitudlg is None:
            self.insitudlg = GetInsituDataDialog(self)
            self.insitudlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.insitudlg.ShowModal()

        if val == wx.ID_OK:
            self.SetStatusText("Getting data...")
            x, y, name = self.insitudlg.data.ProcessData()

            n = self.current_plot.createDataset(x, y, name)
            if not n:
                msg = "No data found for specified parameters."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
            else:
                self.current_plot.update()

            self.SetStatusText("")

    # ----------------------------------------------
    def fic(self, evt):
        """ show a dialog for selecting flask-insitu data """

        if self.ficdlg is None:
            self.ficdlg = FICDialog(self)
            self.ficdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.ficdlg.ShowModal()

        if val == wx.ID_OK:
            self.SetStatusText("Getting data...")

            plotdata = self.ficdlg.data.processData()
            for name in plotdata:
                x, y = plotdata[name]
                self.current_plot.createDataset(x, y, name, linetype='none')

            if self.ficdlg.data.includework:
                self.ficdlg.data.IncludeWorkLines(self.current_plot)
            self.current_plot.update()

            self.SetStatusText("")

    # ----------------------------------------------
    def pairdiff(self, evt):

        if self.pairdlg is None:
            self.pairdlg = get.GetDataDialog(self, flaskOnly=True, multiParameters=False)
            self.pairdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.pairdlg.ShowModal()

        if val == wx.ID_OK:
            self.data = self.pairdlg.data

            t1 = '%s-1-1' % self.data.byear
            t2 = '%s-1-1' % (self.data.eyear + 1)

            db = ccg_dbutils.dbUtils()
            result = db.flaskPairDiff(self.data.stacode,
                                      self.data.paramname,
                                      t1, t2,
                                      self.data.project,
                                      programs=self.data.programs)

            if result is None:
                msg = "No flask pairs found for specified parameters."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()

            else:

                x = defaultdict(list)
                y = defaultdict(list)
                for (date, method, flaskid1, flaskid2, val1, val2, diff, flagged) in result:
                    name = method
                    if flagged:
                        name = method + "_flagged"
                    x[name].append(date)
                    y[name].append(diff)

                methods = list(set([a[0] for a in list(x.keys())]))

                # plot flagged and unflagged data in same color for same method
                for name in x:
                    method = name[0]
                    ncolor = methods.index(method)
                    color = self.current_plot.colors[ncolor % 11]
                    xp = x[name]
                    yp = y[name]
                    title = "%s %s %s" % (self.data.stacode, self.data.paramname, name)
                    if "flagged" in name:
                        self.current_plot.createDataset(xp, yp, title,
                                                        symbol='plus',
                                                        outlinecolor=color,
                                                        outlinewidth=2,
                                                        markersize=3,
                                                        connector='none')
                    else:
                        self.current_plot.createDataset(xp, yp, title,
                                                        symbol='square',
                                                        color=color,
                                                        connector='none')

                self.current_plot.update()

        self.pairdlg.Hide()

    #----------------------------------------------
    def mbl(self, evt):
        """ get zonal data from the latest mbl run """

        if self.mbldlg is None:
            self.mbldlg = MblDialog(self)
            self.mbldlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.mbldlg.ShowModal()

        if val == wx.ID_OK:
            zone = self.mbldlg.zone
            param = self.mbldlg.param

            dir_pattern = "/ccg/dei/ext/%s/web/results.web.2???-??/" % param
            dirs = glob.glob(dir_pattern)
            last_dir = sorted(dirs)[-1]

            if    "Global" in zone:                       filename = "zone_gl.mbl.%s" % param
            elif "Arctic" in zone:                        filename = "zone_arctic.mbl.%s" % param
            elif "Low Northern Hemisphere" in zone:       filename = "zone_lnh.mbl.%s" % param
            elif "Temperate Northern Hemisphere" in zone: filename = "zone_tnh.mbl.%s" % param
            elif "High Northern Hemisphere" in zone:      filename = "zone_hnh.mbl.%s" % param
            elif "Polar Northern Hemisphere" in zone:     filename = "zone_pnh.mbl.%s" % param
            elif "Northern Hemisphere" in zone:           filename = "zone_nh.mbl.%s" % param
            elif "Low Southern Hemisphere" in zone:       filename = "zone_lsh.mbl.%s" % param
            elif "Temperate Southern Hemisphere" in zone: filename = "zone_tsh.mbl.%s" % param
            elif "High Southern Hemisphere" in zone:      filename = "zone_hsh.mbl.%s" % param
            elif "Polar Southern Hemisphere" in zone:     filename = "zone_psh.mbl.%s" % param
            elif "Southern Hemisphere" in zone:           filename = "zone_sh.mbl.%s" % param
            elif "Tropics" in zone:                       filename = "zone_tropics.mbl.%s" % param
            elif "Equatorial" in zone:                    filename = "zone_equ.mbl.%s" % param
            elif "Custom" in zone:                        filename = "surface.mbl.%s" % param

            if zone == "Custom":
                min_lat = self.mbldlg.min_latitude
                max_lat = self.mbldlg.max_latitude
                x, y = surface_subset(last_dir+filename, min_lat, max_lat, dates=True)
                name = "Custom Zone (%s to %s) %s" % (min_lat, max_lat, param)

            else:
                x = []
                y = []
                with open(last_dir+filename, 'r') as f:
                    for line in f:
                        a = line.split()
                        dd = float(a[0])
                        xp = ccg_dates.datetimeFromDecimalDate(dd)
                        yp=float(a[1])

                        x.append(xp)
                        y.append(yp)

                a = zone.split("(")
                name = a[0] + param

            self.current_plot.createDataset(x, y, name)
            self.current_plot.update()

    # ----------------------------------------------
    def target(self, evt):
        """ get observatory target tank measurements """

        if self.targetdlg is None:
            self.targetdlg = TargetDialog(self)
            self.targetdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.targetdlg.ShowModal()

        if val == wx.ID_OK:
            self.SetStatusText("Getting data...")
            x, y, title = self.targetdlg.data.ProcessData()

            for tgtname in x:
                n = self.current_plot.createDataset(x[tgtname], y[tgtname], title[tgtname])

            n = True
#            n = self.current_plot.createDataset(x, y, name)
            if not n:
                msg = "No data found for specified parameters."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
            else:
                if self.targetdlg.data.includework:
                    self.targetdlg.data.IncludeWorkLines(self.current_plot)
                if self.targetdlg.data.includeresp:
                    self.targetdlg.data.IncludeRespLines(self.current_plot)
                if self.targetdlg.data.includevalue:
                    self.targetdlg.data.IncludeTankValue(self.current_plot)
                self.current_plot.update()

            self.SetStatusText("")

    # ----------------------------------------------
    def met(self, evt):
        """ get observatory meteorological data """

        if self.metdlg is None:
            self.metdlg = MetDialog(self)
            self.metdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.metdlg.ShowModal()

        if val == wx.ID_OK:
            self.SetStatusText("Getting data...")
            x, y, name = self.metdlg.ProcessData()

            self.current_plot.createDataset(x, y, name, symbol="none")
            self.current_plot.update()

            self.SetStatusText("")
