# vim: tabstop=4 shiftwidth=4 expandtab

"""
Dialog for doing curve fitting to data
"""

import wx
import wx.adv
from wx.lib.wordwrap import wordwrap

from graph5.graph import Graph
from graph5.toolbars import ZoomToolBar
from ccg_filter_params import filterParameters

import ccg_dates

from common.stats import StatsDialog
from common.TextView import TextView
from common import get
from common.params import ParametersDialog
from common.importdata import ImportDialog
from common.getimportdata import getImportData

# from .help import HelpDialog
from .export import ExportDialog
from .filter_data import filterData


######################################################################
class Ccgvu(wx.Frame):
    """ main ccgvu widget """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(700, 550))

        self.parent = parent
        self.parameters = filterParameters()
        self.getdlg = None
        self.paramsdlg = None
        self.importdlg = None
        self.helpdlg = None
        self.exportdlg = None
        self.filt = None
        self.x = []
        self.y = []
        self.name = ""

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()

        # Notebook for holding graphs for the various curves
        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        plot = Graph(self.nb, -1)
        self.nb.AddPage(plot, "Data")
        self.current_plot = plot

        plot = Graph(self.nb, -1)
        self.nb.AddPage(plot, "Seasonal Cycle")

        plot = Graph(self.nb, -1)
        self.nb.AddPage(plot, "Residuals")

        plot = Graph(self.nb, -1)
        self.nb.AddPage(plot, "Growth Rate")

        plot = Graph(self.nb, -1)
        self.nb.AddPage(plot, "Amplitude")

        plot = Graph(self.nb, -1, xaxis_title="Cycles per year")
        self.nb.AddPage(plot, "Filter Response")

        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.OnPageChanged)

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self, self.current_plot)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)
        self.sizer.Add(self.nb, 1, wx.EXPAND | wx.ALL, 5)

        self.update_menus(0)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    # ----------------------------------------------
    def OnPageChanged(self, event):
        """ handle notebook page change """

        page_num = event.GetSelection()
        page = self.nb.GetPage(page_num)
        self.current_plot = page
        # Attach plot to zoom toolbar
        self.zoomtb.SetGraph(page)
        event.Skip()

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ create the menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(102, "Get Data...")
        self.file_menu.Append(106, "Import...")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(107, "Export...")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(110, "Print Preview...")
        self.file_menu.Append(111, "Print")

        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Close", "Close the window")

        self.Bind(wx.EVT_MENU, self.getdata, id=102)
        self.Bind(wx.EVT_MENU, self.importdata, id=106)
        self.Bind(wx.EVT_MENU, self.exportdata, id=107)
        self.Bind(wx.EVT_MENU, self.print_preview, id=110)
        self.Bind(wx.EVT_MENU, self.print_, id=111)
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.menuBar.Append(self.edit_menu, "Edit")

        self.edit_menu.Append(200, "Parameters")
        self.edit_menu.AppendSeparator()
        self.edit_menu.Append(202, "Graph Preferences...")

        self.Bind(wx.EVT_MENU, self.get_parameters, id=200)
        self.Bind(wx.EVT_MENU, self.graph_prefs, id=202)

        # ---------------------------------------
        menu = wx.Menu()
        self.menuBar.Append(menu, "View")

        toolbarmenu = wx.Menu()
        m = toolbarmenu.Append(1111, "Zoom Toolbar", "", wx.ITEM_CHECK)
        m.Check()
        menu.Append(-1, "Toolbars", toolbarmenu)
        self.Bind(wx.EVT_MENU, self.toggleZoomToolBar, id=1111)

        # ---------------------------------------
        self.report_menu = wx.Menu()
        self.menuBar.Append(self.report_menu, "Reports")

        self.report_menu.Append(501, "Filter Statistics...")
        self.report_menu.Append(502, "Data Statistics...")
        self.report_menu.Append(503, "Monthly Means...")
        self.report_menu.Append(506, "Annual Means...")
        self.report_menu.Append(505, "Trend Crossing Dates...")
        self.report_menu.Append(504, "Seasonal Cycle...")

        self.Bind(wx.EVT_MENU, self.reports, id=501)
        self.Bind(wx.EVT_MENU, self.stats, id=502)
        self.Bind(wx.EVT_MENU, self.reports, id=503)
        self.Bind(wx.EVT_MENU, self.reports, id=504)
        self.Bind(wx.EVT_MENU, self.reports, id=505)
        self.Bind(wx.EVT_MENU, self.reports, id=506)

        # ---------------------------------------
#        menu = wx.Menu()
#        menu.Append(601, "&About...", "More information about this program")
#        menu.Append(602, "&Reference...", "More information about this program")
#        self.menuBar.Append(menu, "&Help")
#        self.Bind(wx.EVT_MENU, self.about, id=601)
#        self.Bind(wx.EVT_MENU, self.help, id=602)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def update_menus(self, which):
        """ Update the setting of the menu items

        Usually called when current_plot changes or plot_list changes
        """

        if which == 0:
            self.file_menu.Enable(107, False)
            self.report_menu.Enable(501, False)
            self.report_menu.Enable(502, False)
            self.report_menu.Enable(503, False)
            self.report_menu.Enable(504, False)
            self.report_menu.Enable(505, False)
        else:
            self.file_menu.Enable(107, True)
            self.report_menu.Enable(501, True)
            self.report_menu.Enable(502, True)
            self.report_menu.Enable(503, True)
            self.report_menu.Enable(504, True)
            self.report_menu.Enable(505, True)

    # ----------------------------------------------
    def toggleZoomToolBar(self, evt):
        "show/hide zoom toolbar """

        if evt.IsChecked():
            self.sizer.Show(self.zoomtb)
        else:
            self.sizer.Hide(self.zoomtb)
        self.sizer.Layout()

    # ----------------------------------------------
    def graph_prefs(self, evt):
        """ show graph preferences dialog """

        self.current_plot.showPrefsDialog(evt)

    # ----------------------------------------------
    def importdata(self, e):
        """ import data from files """

        if self.importdlg is None:
            self.importdlg = ImportDialog(self)
            self.importdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.importdlg.ShowModal()

        if val == wx.ID_OK:
            plot = self.nb.GetPage(0)  # clear flagged data just in case it exists from a previous getdata
            plot.clear()

            datasets = getImportData(self.importdlg.data)
            names = list(datasets.keys())
            name = names[0]   # only use first dataset
            df = datasets[name]

            # if x axis data is a time, convert to decimal date
            x = df.iloc[:, 0]
            if 'time' in str(x.dtype).lower():
                x = [ccg_dates.decimalDateFromDatetime(p) for p in x]
            else:
                x = x.tolist()

            self.x = x
            self.y = df.iloc[:, 1]
            self.name = name

#            self.x = self.importdlg.xdata
#            self.y = self.importdlg.ydata
#            self.name = self.importdlg.dataname
            self.filt = filterData(self, self.x, self.y, self.name, self.parameters)

        self.importdlg.Hide()

    # ----------------------------------------------
    def getdata(self, evt):
        """ get data from database """

        if self.getdlg is None:
            self.getdlg = get.GetDataDialog(self, ccgvu=True)
            self.getdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.getdlg.ShowModal()

        if val == wx.ID_OK:
            self.SetStatusText("Getting Data...")

            self.getdlg.data.process_data(useDatetime=False)
            data = self.getdlg.data.datasets[0]
            x = data.x
            y = data.y
            name = data.name

            if len(x) == 0 or len(y) == 0:
                msg = "No data found for specified parameters."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                self.SetStatusText("")
                return

            plot = self.nb.GetPage(0)
            plot.clear()
            self.x = x
            self.y = y
            self.name = name
            self.filt = filterData(self, self.x, self.y, self.name, self.parameters)

            if len(self.getdlg.data.datasets) > 1:
                page = self.nb.GetPage(0)
                for ds in self.getdlg.data.datasets[1:]:
                    page.createDataset(ds.x, ds.y, ds.name, symbol="circle", linetype="None")
                page.update()

            self.SetStatusText("")

    # ----------------------------------------------
    def OnExit(self, e):
        """ exit the app """

        self.Close(True)  # Close the frame.

    # ----------------------------------------------
    def print_(self, event):
        """ print the graph """

        self.current_plot.print_()

    # ----------------------------------------------
    def print_preview(self, event):
        """ show print preview """

        self.current_plot.printPreview()

    # ----------------------------------------------
    def reports(self, event):
        """ show text reports in window """

        btnid = event.GetId()
        if btnid == 504:
            text = self.filt.getAmplitudeStats()
        if btnid == 503:
            text = self.filt.getMonthlyStats()
        if btnid == 501:
            text = self.filt.getFilterStats()
        if btnid == 505:
            text = self.filt.getTrendCrossing()
        if btnid == 506:
            text = self.filt.getAnnualStats()

        dlg = TextView(self, text)
        dlg.Show()

    # ----------------------------------------------
    def stats(self, evt):
        """ show statistics window """

        statsdlg = StatsDialog(self, -1, graph=self.current_plot)
        statsdlg.CenterOnScreen()
        statsdlg.Show()

    # ----------------------------------------------
    def exportdata(self, evt):
        """ Create a dialog for writing out the various data sets to files.  """

        if self.exportdlg is None:
            self.exportdlg = ExportDialog(self, self.filt)
            self.exportdlg.CenterOnScreen()
        else:
            self.exportdlg.filt = self.filt.filt  # make sure export dialog is using current filter results

        # update start date in case dataset has changed since export dialog was created
        self.exportdlg.set_start_date(self.filt.start_date)
        self.exportdlg.ShowModal()

    # ----------------------------------------------
    def get_parameters(self, evt):
        """ Show dialog for editing the filter parameters """

        if self.paramsdlg is None:
            self.paramsdlg = ParametersDialog(self, self.parameters)
            self.paramsdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.paramsdlg.ShowModal()
        if val == wx.ID_OK:
            self.parameters = self.paramsdlg.parameters
            self.filt = filterData(self, self.x, self.y, self.name, self.parameters)

    # ----------------------------------------------
    def about(self, evt):
        """ show about window """

        # First we create and fill the info object
        info = wx.adv.AboutDialogInfo()
        info.Name = "CCGVU"
        info.Version = "1.0.0"
        info.Copyright = "(C) 2006 Programmers and Coders Everywhere"
        info.Description = wordwrap(
            """CCGvu is a program for plotting and curve fitting of the GML trace gas
            measurements. Measurement species supported are CO2, CH4, CO, H2, and the C13
            and O18 isotope measurements of CO2. Curve fits are based on a combination of
            a fit to the data using a function with polynomial plus annual harmonic terms,
            and filtering of the residuals in the frequency domain. """,
            350, wx.ClientDC(self))
    #        info.WebSite = ("http://en.wikipedia.org/wiki/Hello_world", "Hello World home page")
        info.Developers = ["Kirk Thoning"]
    #        info.License = wordwrap(licenseText, 500, wx.ClientDC(self))

        # Then we call wx.AboutBox giving it that info object
        wx.adv.AboutBox(info)

    # ----------------------------------------------
#    def help(self, evt):
#        """ show help in an html window """
#
#        self.helpdlg = HelpDialog(self, -1)
#        self.helpdlg.CenterOnScreen()
#        self.helpdlg.Show()
