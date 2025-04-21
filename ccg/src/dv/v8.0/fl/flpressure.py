# vim: tabstop=4 shiftwidth=4 expandtab
"""
Create a window showing flask pressures or flow rates for the
data selected in the flask flagging main dialog.
"""

import datetime
from collections import defaultdict
import wx

from graph5.graph import Graph
from graph5.style import Style
from graph5.toolbars import ZoomToolBar
import ccg_dbutils
from ccg_flask_data import FlaskData

import ccg_rawfile

from common.find_raw_file import findRawFile
from common.flask_listbox import selectedFlaskListbox


######################################################################
class FLPressure(wx.Frame):
    """
    Create a window showing flask pressures or flow rates for the
    data selected in the flask flagging main dialog.
    """

    def __init__(self, parent, ID=-1, title="Flask Pressures", data_type="pressure"):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(800, 550))

        db = ccg_dbutils.dbUtils()
        self.sitenum = parent.data.sitenum
        self.gasname = db.getGasFormula(parent.data.parameter_list[0])
        self.byear = parent.data.byear
        self.eyear = parent.data.eyear
        self.data_type = data_type    # can be either pressure or flow

        self.useFlask = parent.data.use_flask
        self.usePFP = parent.data.use_pfp

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        choices = [db.getGasFormula(p) for p in parent.data.parameter_list]
#        print("choices is", choices)
        c = wx.Choice(self, -1, choices=choices)
        self.sizer.Add(c, 0, wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selGas, c)
        c.SetSelection(0)

        # make the initial graph.
        plot = Graph(self, -1)
        plot.Bind(wx.EVT_MIDDLE_DOWN, self.selectPoint)
        self.current_plot = plot

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()
#        self.SetStatusText("This is the statusbar")

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self, plot)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)

        self.listbox2 = selectedFlaskListbox(self, height=105)

        self.sizer.Add(plot, 1, wx.EXPAND, 0)
        self.sizer.Add(self.listbox2, 0, wx.EXPAND, 0)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)

        self._get_data()

        self.Show(True)

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Menu bar entries """

        menuBar = wx.MenuBar()

        menu = wx.Menu()
        menu.Append(101, "Close", "Close this window")
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        menuBar.Append(menu, "&File")

        self.SetMenuBar(menuBar)

    # ----------------------------------------------
    def OnExit(self, e):
        """ exit program """

        self.Close(True)  # Close the frame.

    # ----------------------------------------------
    def selGas(self, e):
        """ gas choice has changed, update graph """

        self.gasname = e.GetString()

        self.SetStatusText("Working...")
        self._get_data()
        self.SetStatusText("")

    # ----------------------------------------------
    def _get_data(self):
        """ Query the database for the flask data for the given site, gas, and years.
        For each flask result, find its rawfile, and get the pressure or flow rate from
        the raw file.
        """

        t1 = datetime.datetime(self.byear, 1, 1)
        t2 = datetime.datetime(self.eyear+1, 1, 1)

        f = FlaskData(self.gasname, self.sitenum)
        f.setRange(start=t1, end=t2)
#        f.setProject(self.data.project)
        f.setStrategy(self.useFlask, self.usePFP)
        f.setSystem("%magicc%")
        f.includeFlaggedData()
        f.includeHardFlags()
#        f.setPrograms(self.proglist)
        f.run()

        xp = defaultdict(list)
        yp = defaultdict(list)
        events = defaultdict(list)
        for row in f.results:
            eventnum = row['event_number']
            method = row['method']
            sdate = row['date']
            date = row['adate']
            system = row['system']

            rawfile = findRawFile(self.gasname, system, date, eventnum, "qc")
#            print(rawfile)
            if rawfile is None:
#                print("WARNING: Can't find qc file for event number", eventnum, "gas", self.gasname, "system", system, "date", date)
                continue

            # read the raw file, find where event is, then get pressure
            raw = ccg_rawfile.Rawfile(rawfile)
            rawevents = raw.getColumnData("event")
            rownum = rawevents.tolist().index(str(eventnum))
            rawcol = None
            if self.data_type == "pressure":
                # find the column with the pressure value.  It can have a couple different names
                for colnum, name in enumerate(raw.column_names):
                    if "pressure" in name.lower() or "flask_p" in name.lower():
                        rawcol = colnum

            else:
                for colnum, name in enumerate(raw.column_names):
                    if "flow" in name.lower():
                        rawcol = colnum

            if rawcol is None: continue  # column name was not found in raw file

            val = raw.data[rownum][rawcol]

            xp[method].append(sdate)
            yp[method].append(val)
            events[method].append(eventnum)

        self.current_plot.clear()
        if self.data_type == "pressure":
            dataname = "Flask Pressure " + self.gasname
        else:
            dataname = "Flask Flow Rate " + self.gasname
        for method in xp:
            dataset = self.current_plot.createDataset(xp[method], yp[method], dataname + " " + method, linetype="None")
            dataset.userData = events[method]

        self.current_plot.update()

    # -----------------------------------------------------
    def selectPoint(self, event):
        """ Get point nearest middle mouse button click.
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

#        z = self.listbox.FindItem(-1, str(event_num))
#        self.listbox.EnsureVisible(z)
#        self.listbox.SetItemState(z, wx.LIST_STATE_SELECTED, wx.LIST_STATE_SELECTED)

#        self.highlight_points(event_num)

        style = Style()
        style.setFillColor(wx.Colour(255, 255, 0, 100))
        style.setMarker("square")
        style.setMarkerSize(6)

        xp = dataset.xdata[index]
        yp = dataset.ydata[index]
#        print xp, yp, event_num
        self.current_plot.ClearMarkers()
        self.current_plot.AddMarker(xp, yp, style)
        self.current_plot.update()

        self._set_listbox(event_num, self.gasname)

        event.Skip()

    # -----------------------------------------------------
    def _set_listbox(self, event_num, param):
        """ Update the list box with the data for the selected flask """

        self.listbox2.setItems(param, event_num)
