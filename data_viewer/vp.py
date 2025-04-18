# vim: tabstop=4 shiftwidth=4 expandtab

"""
App for plotting results from pfp samples, which are usually from
a vertical profile sampling onboard aircraft.

vertical profile data is plotted as altitude vs mole fraction.
surface data is plotted mole fraction vs time.
"""

import datetime
from math import sqrt
from dateutil.parser import parse
import wx

from common.TextView import TextView

from ccg_flask_data import FlaskData
from graph5.graph import Graph
import ccg_dbutils

from .get import GetVpDialog


######################################################################
class VP(wx.Frame):
    """ A dialog for plotting pfp data, either as vertical profiles or as time series """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(700, 550))

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.parent = parent
        self.plot = None
        self.opendlg = None
        self.db = ccg_dbutils.dbUtils()
        self.result = None

        # Make the menu bar
        self._make_menu_bar()

        # and status bar
        self.CreateStatusBar()
        self.SetStatusText("")

        # Notebook for holding graphs for the various curves
        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)
        self.sizer.Add(self.nb, 1, wx.GROW | wx.ALIGN_LEFT | wx.ALL, 5)

        # First tab has a panel for multiple plots
        self.panel = wx.Panel(self.nb, -1)
        self._make_tab1(self.panel)
        self.nb.AddPage(self.panel, "Panel")

        # next tab, holds one single graph with multiple datasets
        panel = wx.Panel(self.nb, -1)
        self._make_tab2(panel)
        self.nb.AddPage(panel, "Overlay")

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    # ----------------------------------------------
    def _make_tab1(self, panel):
        """ make contents of first notebook tab
        This is a text title and a grid sizer that can
        hold multiple graphs
        """

        # Add a vertical sizer to hold a title, flexgrid sizer
        box = wx.BoxSizer(wx.VERTICAL)

        self.title = wx.StaticText(panel, -1, "No package selected")
        box.Add(self.title, 0, wx.EXPAND | wx.ALL, 10)

        # ---- grid sizer to hold graphs
        self.sizer2 = wx.GridSizer(0, 0, 1, 1)
        box.Add(self.sizer2, 1, wx.EXPAND | wx.ALL, 0)

        plot = Graph(self.panel, -1)
        self.sizer2.Add(plot, 1, wx.EXPAND | wx.ALL, 0)

        panel.SetSizer(box)

    # ----------------------------------------------
    def _make_tab2(self, panel):
        """ make contents of first notebook tab
        This is a text title and a single graph
        """

        box = wx.BoxSizer(wx.VERTICAL)

        self.title2 = wx.StaticText(panel, -1, "No package selected")
        box.Add(self.title2, 0, wx.EXPAND | wx.ALL, 10)

        self.overlay_plot = Graph(panel, -1)
        box.Add(self.overlay_plot, 1, wx.EXPAND, 0)

        panel.SetSizer(box)

    # ----------------------------------------------
    def _make_menu_bar(self):
        """ make the menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(102, "Open...")
        self.file_menu.Append(107, "Export...")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(111, "Print")

        self.file_menu.Enable(107, False)

        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Close", "Close the window")

        self.Bind(wx.EVT_MENU, self.open, id=102)
        self.Bind(wx.EVT_MENU, self.exportdata, id=107)
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)

        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")
        btn301 = self.view_menu.Append(301, "View Data", "View Data")

        self.Bind(wx.EVT_MENU, self.viewData, btn301)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def open(self, evt):
        """ Open the dialog for selecting data to use """

        if self.opendlg is None:
            self.opendlg = GetVpDialog(self)
            self.opendlg.CenterOnScreen()

        val = self.opendlg.ShowModal()

        if val == wx.ID_OK:
            print(self.opendlg.data)
            self.plot_data(self.opendlg.data)
            self.file_menu.Enable(107, True)
    #        self.tb.Enable()

    # ----------------------------------------------
    def OnExit(self, e):
        """ Close the app """

        self.Close(True)  # Close the frame.

    # --------------------------------------------------------------
    def viewData(self, evt):
        """ view the data from raw file """

        text = ""
        if self.opendlg:
            for param in self.opendlg.data.parameter_list:

                name = self.db.getGasFormula(param)
                text += "\n%s\n-------------------------\n" % name

                for date, package in sorted(zip(self.opendlg.data.datestr, self.opendlg.data.package)):

                    if self.opendlg.data.flaggedsymbol:
                        result = self._get_data(self.opendlg.data, param, date, package, flagged=False)
                    else:
                        result = self._get_data(self.opendlg.data, param, date, package, flagged=None)

                text += result.to_string()
                text += "\n"

        dlg = TextView(self, text)
        dlg.Show()

    # ----------------------------------------------
    def exportdata(self, evt):
        """ Create and show a dialog for writing out the various
            data sets to files.
        """

        lst = []
        for num in self.param_list:
            info = self.db.getGasInfoFromNum(num)
            lst.append("%s %s %s" % (info[0], info[1], info[2]))

        dlg = wx.MultiChoiceDialog(self,
                                   "Pick parameters to export to Grapher",
                                   "wx.MultiChoiceDialog", lst)

        if dlg.ShowModal() == wx.ID_OK:
            if not self.plot:
                grapher = self.parent.grapher(None)
                self.plot = grapher.current_plot

            selections = dlg.GetSelections()
            for x in selections:
                formula = lst[x].split()[1]
                ds = self.overlay_plot.getDataset(formula)
                ds.yaxis = 0
                self.plot.addDataset(ds)

            self.plot.update()

    # ----------------------------------------------
    def plot_data(self, config):
        """ Now get the data from the database and plot the data.
        Need to modify the graphs to handle the type of plots to
        make, either profile or time series.
        """

        self.overlay_plot.clear()
        self.sizer2.Clear(True)
        self.setLayout(len(config.parameter_list))

        for param in config.parameter_list:

            x = []
            y = []
            name = self.db.getGasFormula(param)

            for date, package in sorted(zip(config.datestr, config.package)):
#                print("date, package", date, package)

                if config.flaggedsymbol:
                    result = self._get_data(config, param, date, package, flagged=False)
                else:
                    result = self._get_data(config, param, date, package, flagged=None)

#                print(result)
                xp, yp = self._get_plot_data(result, config.project)
                x.extend(xp)
                y.extend(yp)

            self.overlay_plot.createDataset(x, y, name)

            # For the overlay plot,
            # The first parameter uses the default xaxis.
            # Other parameters need their own xaxis created and assigned
            if param != config.parameter_list[0]:
                dataset = self.overlay_plot.getDataset(name)
                if dataset:
                    if int(config.project) == 1:
                        yaxis = self.overlay_plot.addYAxis(name)
                        dataset.SetAxis(yaxis)
                    else:
                        xaxis = self.overlay_plot.addXAxis(name)
                        dataset.SetAxis(xaxis)
            else:
                if int(config.project) == 1:
                    yaxis = self.overlay_plot.getYAxis(0)
                    xaxis = self.overlay_plot.getXAxis(0)
                    yaxis.title.text = name
                    xaxis.title.text = ""
                else:
                    xaxis = self.overlay_plot.getXAxis(0)
                    xaxis.title.text = name

            # For the panel plot,
            # Create a new plot for each param
            plot = self.makePlot(name, config.project)
            self.sizer2.Add(plot, 0, wx.EXPAND, 0)
            plot.createDataset(x, y, name)
            plot.update()

            # if plotting flagged data separately, get it here
            if config.flaggedsymbol:
                x = []
                y = []
                for date, package in sorted(zip(config.datestr, config.package)):
                    result = self._get_data(config, param, date, package, flagged=True)
                    xp, yp = self._get_plot_data(result, config.project)
#                    print xp, yp
                    x.extend(xp)
                    y.extend(yp)

                flagname = name + ' Flagged'
                plot.createDataset(x, y, flagname, symbol="plus", markersize=4, outlinewidth=2)

                # add flagged data to overlay plot
# TODO
#                dataset = self.overlay_plot.getDataset(name)  # check if unflagged data exists
#                if dataset:  #if so, get the x and y axis for it
#                    yaxis = self.overlay_plot.getYAxis  ??? 
#                    xaxis = self.overlay_plot.getXAxis  ??? 
#                    dataset = self.overlay_plot.createDataset(x, y, flagname, symbol="plus", markersize=4, outlinewidth=2)
#                    dataset.setYaxis(yaxis)
#                    dataset.setXaxis(xaxis)

    #    print self.param_list
        self.sizer2.Layout()

        self.overlay_plot.update()

        title = "%s %s Package Id %s" % (config.stacode, config.datestr, config.package)
#        print "title is ", title
        self.title.SetLabel(title)
        self.title2.SetLabel(title)

    # --------------------------------------------
    def _get_plot_data(self, result, project):
        """ Extract the x and y data from the result from the database """

        if result is None:
            return [], []

        if project == 1:
            xp = result['date']
            yp = result['value']
        else:
            xp = result['value']
            yp = result['altitude'] / 1000.0

        return xp, yp

    # --------------------------------------------
    def _get_data(self, config, param, date, package, flagged=None):
        """ Get the data for the given date, parameter and flask package """

        (date1, s, date2) = date.split()
        # need to add one day to date2 for use in FlaskData
        dateend = parse(date2) + datetime.timedelta(days=1)

        f = FlaskData(param, config.sitenum)
        f.setRange(start=date1, end=dateend.date())
        f.setProject(config.project)
        f.setPrograms(config.programs)
        f.setFlaskPackage(package)
        f.setStrategy(use_flask=False)
        if flagged is True:
            f.includeFlaggedData(only_flagged=True)
        elif flagged is False:
            f.includeFlaggedData()

        f.run(as_dataframe=True)
#        f.showQuery()
#        print(f.results)

        return f.results

    # ----------------------------------------------
    def makePlot(self, title, project):
        """ Create a graph widget, setting one of the axis titles to 'title' """

        if project == 1:
            ytitle = title
            xtitle = "Date"
        else:
            ytitle = "Altitude (km)"
            xtitle = title
        plot = Graph(self.panel, -1, yaxis_title=ytitle, xaxis_title=xtitle)
        plot.legend.showLegend = False

        return plot

    # ----------------------------------------------
    def setLayout(self, nplots):
        """ Arrange the layout of the graphs in a grid,
        depending on how many there are.
        """

        n = nplots - 1
        nrows = int(sqrt(n)) + 1
        ncols = int(n/nrows) + 1

        self.sizer2.SetRows(nrows)
        self.sizer2.SetCols(ncols)
        self.sizer2.Layout()
