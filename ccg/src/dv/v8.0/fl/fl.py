# vim: tabstop=4 shiftwidth=4 expandtab
"""
Module for manually flagging flask data by plotting the data for a station,
and allowing the user to select a data point and modify the flag for
that data point.
"""

import sys
import datetime
import copy
import wx
import wx.adv

from operator import itemgetter

from graph5.graph import Graph
from graph5.dataset import Dataset
from graph5.style import Style

import ccg_dbutils
from ccg_flask_data import FlaskData

from common.validators import *
from common import get
from common.flask_listbox import selectedFlaskListbox

from .flview import FlaskDataView
from .flpressure import FLPressure


######################################################################
class Fl(wx.Frame):
    """
    Module for manually flagging flask data by plotting the data for a station,
    and allowing the user to select a data point and modify the flag for
    that data point.
    """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(930, 700))

        self.viewdlg = None
        self.getdlg = None
        self.data = None
        self.olddata = None

        self.CreateStatusBar()
        self.SetStatusText("")

        self.db = ccg_dbutils.dbUtils()

        panel = wx.Panel(self)
        box = wx.BoxSizer(wx.HORIZONTAL)
        panel.SetSizer(box)

        self._make_menubar()

        # splitter for left and right sides
        sw = wx.SplitterWindow(panel, -1, style=wx.SP_LIVE_UPDATE)
        box.Add(sw, 1, wx.EXPAND, 0)

        # add listctrl on left side
        self.listbox = wx.ListCtrl(sw, -1, style=wx.LC_SINGLE_SEL | wx.LC_REPORT | wx.LC_VRULES | wx.LC_HRULES)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.listbox.SetFont(font)
        headers = ["Event", "Date", "ID", "Method"]
        for n, t in enumerate(headers):
            self.listbox.InsertColumn(n, t)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, self.listbox)
        self.Bind(wx.EVT_LIST_ITEM_DESELECTED, self.OnItemDeselected, self.listbox)

        # another splitter on right side for graph and listctrl
        sw2 = wx.SplitterWindow(sw, -1, style=wx.SP_LIVE_UPDATE)
        sw.SetMinimumPaneSize(20)
        sw.SplitVertically(self.listbox, sw2, 330)

        # panel for top
        p2 = wx.Panel(sw2)

        # add graph to panel
        self.graph_sizer = wx.BoxSizer(wx.VERTICAL)
        p2.SetSizer(self.graph_sizer)

        self.graph_title = wx.StaticText(p2, -1, "")
        self.graph_sizer.Add(self.graph_title, 0, wx.ALL | wx.ALIGN_CENTRE_HORIZONTAL, 0)

        self.graph = []
        for n in range(0, 6):
            g = Graph(p2, -1)
            g.margin = 10
            g.syncAxis(111)
            self.graph.append(g)
            self.graph_sizer.Add(self.graph[n], 1, wx.EXPAND, 0)
            g.Bind(wx.EVT_MIDDLE_DOWN, self.selectPoint)
            if n > 0:
                g.Hide()

        # list box for bottom
        self.listbox2 = selectedFlaskListbox(sw2, 90, self.update_plots)

        sw2.SetMinimumPaneSize(100)
        sw2.SplitHorizontally(p2, self.listbox2, -165)
        sw2.SetSashGravity(0.5)

        self.CenterOnScreen()

    # -----------------------------------------------------
    def _make_menubar(self):

        # Prepare the menu bar
        menuBar = wx.MenuBar()

        # 1st menu from left
        menu1 = wx.Menu()
        menu1.Append(102, "Get Data", "Get new set of data")
        menu1.AppendSeparator()
        menu1.Append(104, "Close", "Close this frame")
        # Add menu to the menu bar
        menuBar.Append(menu1, "File")

        self.Bind(wx.EVT_MENU, self.getdata2, id=102)
        self.Bind(wx.EVT_MENU, self.CloseWindow, id=104)

        self.menu2 = wx.Menu()
#        self.menu2.Append(203, "View Trajectory...")
        self.menu2.Append(204, "View All Flask Data...")
        self.menu2.Append(205, "View Flask Pressures...")
        self.menu2.Append(206, "View Flask Flow Rates...")
        menuBar.Append(self.menu2, "View")

#        self.menu2.Enable(203, False)
        self.menu2.Enable(204, False)
        self.menu2.Enable(205, False)
        self.menu2.Enable(206, False)

#        self.Bind(wx.EVT_MENU, self.viewTraj, id=203)
        self.Bind(wx.EVT_MENU, self.viewData, id=204)
        self.Bind(wx.EVT_MENU, self.viewPressures, id=205)
        self.Bind(wx.EVT_MENU, self.viewFlow, id=206)

        self.SetMenuBar(menuBar)

    # -----------------------------------------------------
    def selectPoint(self, event):
        """ Get point nearest middle mouse button click on graph.
        Select the corresponding event info in the list box,
        and highlight the data points in the graphs.
        Update the 2nd listbox with analysis data for the event.
        """

        x = event.x
        y = event.y
        obj = event.GetEventObject()
        name, index, dist = obj.findClosestPoint(x, y)

        dataset = obj.getDataset(name)
        event_num = dataset.userData[index]

        z = self.listbox.FindItem(-1, str(event_num))
        self.listbox.EnsureVisible(z)

        # this will also call self.OnItemSelected()
        self.listbox.SetItemState(z, wx.LIST_STATE_SELECTED, wx.LIST_STATE_SELECTED)

        # the SetItemState call will also trigger a select event for the listbox (OnItemSelected())

        event.Skip()

    # -----------------------------------------------------
    def highlight_points(self, event_num):
        """ Draw a highlight marker over the data points
        for the selected event.
        """

        style = Style()
        style.setFillColor(wx.Colour(255, 255, 0, 100))
        style.setMarker("square")
        style.setMarkerSize(6)

        # get flask data for selected point
        for n, param in enumerate(self.data.parameter_list):
            self.graph[n].ClearMarkers()
            f = FlaskData(param, self.data.stacode)
            f.setEvents(event_num)
            f.setProject(self.data.project)
            f.includeFlaggedData()
            f.includeHardFlags()
#            f.setPrograms(self.data.programs)

            f.run()

            if f.results is not None:
                for row in f.results:
                    x = row['date']
                    y = row['value']
                    if y > -999:
                        self.graph[n].AddMarker(x, y, style)

            self.graph[n].update()

    # -----------------------------------------------------
    def CloseWindow(self, event):
        self.Close()

    # ----------------------------------------------
    def OnItemSelected(self, event):
        """ An item in the event listbox has been selected.
            Update the flask info listbox with the analysis
            information for each parameter that is graphed.
        """
        self.currentItem = event.Index

        line = self.listbox.GetItemText(self.currentItem)
        s = line.split(' ')
        event = int(s[0])

        self.listbox2.setItems(self.data.parameter_list, event)
        self.highlight_points(event)

#        self.menu2.Enable(203, True)
        self.menu2.Enable(205, True)
        self.menu2.Enable(206, True)

    # ----------------------------------------------
    def OnItemDeselected(self, event):
        item = event.Index

    # ----------------------------------------------
    def update_plots(self, gasname):
        """ This is called from a callback in selectedFlaskListbox()
        when a flag is changed on a flask event.
        Update the plot for the given gasname to show new flag
        """

        # Get the data for each gas graph
        for n, param in enumerate(self.data.parameter_list):
            gas = self._get_gas_formula(param)
            if gas != gasname: continue

            data = self._get_flask_data(param)
            x, y, events = self.getGraphData(data, flagged=0)
            xs, ys, eventss = self.getGraphData(data, flagged=1)
            xf, yf, eventsf = self.getGraphData(data, flagged=2)

            if len(x) > 0:
                name = "%s unflagged" % (gas)
                dataset = self.graph[n].getDataset(name)
                dataset.SetData(x, y)
#                dataset.SetWeights(wt)
                dataset.userData = events

            if len(xs) > 0:
                name = "%s soft flags" % (gas)
                dataset = self.graph[n].getDataset(name)
                dataset.SetData(xs, ys)
#                dataset.SetWeights(wt)
                dataset.userData = eventss

            if len(xf) > 0:
                name = "%s hard flags" % (gas)
                dataset = self.graph[n].getDataset(name)
                dataset.SetData(xf, yf)
                dataset.userData = eventsf

            self.graph[n].update()

    # ----------------------------------------------
    def getdata2(self, evt):
        """ Create and show a dialog for the user to choose which data to use.
            Load the data and configure the widgets.
        """

        if self.getdlg is None:
            self.getdlg = get.GetDataDialog(self, flaskOnly=True, multiParameters=True)
            self.getdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.getdlg.ShowModal()

        if val == wx.ID_OK:
            self.data = self.getdlg.data

#            progs = []
#            for progname in self.data.programs:
#                prognum = self._get_program_num(progname)
#                progs.append(str(prognum))
#            self.proglist = ",".join(progs)
#            self.proglist = ",".join(self.data.programs)

            success = self.loaddata()
            if not success:
                self.data = copy.deepcopy(self.olddata)
            else:
                self.olddata = copy.deepcopy(self.data)

        self.getdlg.Hide()

    # ----------------------------------------------
    def loaddata(self):
        """ Load the data from the database, populating the left event list
            and the graph.
        """

        # drawing style for unflagged data
        style0 = Style()
        style0.setFillColor(wx.Colour(0, 0, 255))
        # style0.setOutlineColor(wx.Colour(255,0,0))
        style0.setLineWidth(1)
        style0.setMarker("square")
        style0.setMarkerSize(2)
        style0.setConnectorType("None")

        # drawing style for hard flagged data
        style1 = Style()
        style1.setFillColor(wx.Colour(255, 0, 0))
        style1.setLineWidth(1)
        style1.setMarker("circle")
        style1.setMarkerSize(2)
        style1.setConnectorType("None")

        # drawing style for soft flagged data
        style2 = Style()
        style2.setFillColor(wx.Colour(0, 200, 0))
        style2.setLineWidth(1)
        style2.setMarker("circle")
        style2.setMarkerSize(2)
        style2.setConnectorType("None")

        # drawing style for third column flagged data
        style3 = Style()
        style3.setFillColor(wx.Colour(0, 250, 250))
        style3.setLineWidth(1)
        style3.setMarker("square")
        style3.setMarkerSize(2)
        style3.setConnectorType("None")

        nparm = len(self.data.parameter_list)

        # Get the data for each gas graph
        # get events from all gases, in case some are missing from some gases
        # then update list box with final list of events
        self.listbox_events = []
        self.listbox_data = []
        for n in range(0, nparm):
            param = self.data.parameter_list[n]
            gas = self._get_gas_formula(param)

            data = self._get_flask_data(param)

            if not data:
                msg = "No data found for specified parameters."
                dlg = wx.MessageDialog(self, msg, 'Error', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return False

            if n == 0:
                self.graph_title.SetLabel(self.data.stacode)
#                self._set_listbox(data)

            self._set_listbox_data(data)

            x, y, events = self.getGraphData(data, flagged=0)
            xs, ys, eventss = self.getGraphData(data, flagged=1)
            xf, yf, eventsf = self.getGraphData(data, flagged=2)
            xt, yt, eventst = self.getGraphData(data, flagged=3)

            self.graph[n].clear()

            # Create new dataset and set weights
            if len(x) > 0:
                dataset = Dataset(x, y, "%s unflagged" % (gas))
                dataset.SetStyle(style0)
                dataset.userData = events
                self.graph[n].addDataset(dataset)

            if len(xt) > 0:
                dataset = Dataset(xt, yt, "%s info flag" % (gas))
                dataset.SetStyle(style3)
                dataset.userData = eventst
                self.graph[n].addDataset(dataset)

            if len(xs) > 0:
                dataset = Dataset(xs, ys, "%s soft flags" % (gas))
                dataset.SetStyle(style2)
                dataset.userData = eventss
                self.graph[n].addDataset(dataset)

            if len(xf) > 0:
                dataset = Dataset(xf, yf, "%s hard flags" % (gas))
                dataset.SetStyle(style1)
                dataset.userData = eventsf
                dataset.include_in_yaxis_range = len(x) == 0       # if no unflagged data, scale axis with flagged data
                self.graph[n].addDataset(dataset)

            axis = self.graph[n].getYAxis(0)
            axis.SetTitle(gas)
#            self.graph[n].legend.showLegend = False

            self.graph[n].SetLocation(65, 0, 0, 0)
            self.graph[n].show_offscale_points = True
            self.graph[n].update()
            self.graph[n].Show()

        # set listbox with unique events from all gases
        self._set_listbox(self.listbox_data)

        # Hide other unused graphs
        for n in range(nparm, 6):
            self.graph[n].clear()
            self.graph[n].Hide()

        # Update the sizer holding the graphs
        self.graph_sizer.Layout()

        self.menu2.Enable(204, True)
        self.menu2.Enable(205, True)
        self.menu2.Enable(206, True)

        return True

    # ----------------------------------------------------
    def _get_flask_data(self, param):

        t1 = datetime.datetime(self.data.byear, 1, 1)
        t2 = datetime.datetime(self.data.eyear+1, 1, 1)

        f = FlaskData(param, self.data.sitenum)
        f.setRange(start=t1, end=t2)
        f.setProject(self.data.project)
        f.setStrategy(self.data.use_flask, self.data.use_pfp)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.includeDefault()
#        print("set programs to", self.data.programs)
        f.setPrograms(self.data.programs)
        if self.data.bin_method and self.data.bin_data:
            f.setBin(self.data.bin_method, self.data.min_bin, self.data.max_bin)

        f.run()
#        f.showQuery()

        return f.results

    # ----------------------------------------------------
    def _set_listbox_data(self, data):
        """ update a list of event info.  Keep all unique events """

        for row in data:
            if row['event_number'] in self.listbox_events: continue  # skip duplicate events in list
            self.listbox_data.append((row['event_number'], row['date'], row['flaskid'], row['method']))
            self.listbox_events.append(row['event_number'])

    # ----------------------------------------------------
    def _set_listbox(self, data):
        """ update the main listbox with new flask data """

        data.sort(key=itemgetter(1))  # sort by date

        self.listbox.DeleteAllItems()
        self.listbox2.DeleteAllItems()
        for n, row in enumerate(data):
            index = self.listbox.InsertItem(n, str(row[0]))
            self.listbox.SetItem(index, 1, str(row[1]))
            self.listbox.SetItem(index, 2, str(row[2]))
            self.listbox.SetItem(index, 3, str(row[3]))
            if n % 2 == 0:
                self.listbox.SetItemBackgroundColour(index, wx.Colour(240, 240, 240))

        for n in range(0, 4):
            self.listbox.SetColumnWidth(n, -1)

    # ----------------------------------------------------
    def getGraphData(self, data, flagged=False):
        """ Get the specific data depending on value of 'flagged'
        Return the date and value arrays, with associated
        event numbers that are needed later.

        If flagged=0, return only unflagged data
        If flagged=1, return only soft flagged data
        If flagged=2, return only hard flagged data
        If flagged=3, return only third column info flagged data
        """

        x = []
        y = []
        events = []
        for row in data:
            if row['value'] <-900: continue  # don't plot default values
            date = row['date']
            flag = row['qcflag']

            # no flags
            if flagged == 0:
                if flag == '...':
                    x.append(date)
                    y.append(row['value'])
                    events.append(row['event_number'])

            # soft flags
            elif flagged == 1:
                if flag[0] == '.' and flag[1] != '.':
                    x.append(date)
                    y.append(row['value'])
                    events.append(row['event_number'])

            # hard flags
            elif flagged == 2:
                if flag[0] != '.':
                    x.append(date)
                    y.append(row['value'])
                    events.append(row['event_number'])

            elif flagged == 3:
                if flag[0] == '.' and flag[1] == '.' and flag[2] != '.':
                    x.append(date)
                    y.append(row['value'])
                    events.append(row['event_number'])

        return x, y, events

    # ---------------------------------------------------------------------------
    def viewData(self, event):
        """ Show a dialog with a list of all flask data for one species.  """

        self.viewdlg = FlaskDataView(self)
        self.viewdlg.Show()

    # ---------------------------------------------------------------------------
    def viewPressures(self, event):
        """ Show a graph of flask pressures vs time.
        Flask pressures are only available for magicc systems, starting in July 2008."""

        splash = MySplashScreen()
        wx.Yield()
#        splash.Show()

        self.pdlg = FLPressure(self)
        self.pdlg.Show()

        splash.Destroy()

    # ---------------------------------------------------------------------------
    def viewFlow(self, event):
        """ Show a graph of flow rate vs time.
        Flow rates are only available for magicc systems, starting in July 2008."""

        splash = MySplashScreen()
        wx.Yield()
#        splash.Show()

        self.fdlg = FLPressure(self, data_type="flow")
        self.fdlg.Show()

        splash.Destroy()

    # ---------------------------------------------------------------------------
    def _get_gas_formula(self, param):
        """ get gas formula from gas number """

        gas = self.db.getGasFormula(param)

        return gas

    # ---------------------------------------------------------------------------
#    def _get_program_num(self, abbr):
#        """ Get program number from program abbreviation """
#
#
#        print("abbr is", abbr)
#        num = self.db.getProgramNum(abbr)
#
#        return num


##########################################################################################
class MySplashScreen(wx.adv.SplashScreen):
    """ Create a splash screen window """

    def __init__(self):
        if sys.platform == "darwin":
            bmp = wx.Image("/Volumes/ccg/src/dv/current/fl/loading.png").ConvertToBitmap()
        else:
            bmp = wx.Image("/ccg/src/dv/current/fl/loading.png").ConvertToBitmap()
        wx.adv.SplashScreen.__init__(self, bmp,
                                     wx.adv.SPLASH_CENTRE_ON_SCREEN | wx.adv.SPLASH_NO_TIMEOUT,
                                     5000, None, -1)
