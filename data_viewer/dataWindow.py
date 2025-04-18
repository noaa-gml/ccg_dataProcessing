# vim: tabstop=4 shiftwidth=4 expandtab
"""
widget that contains a choice menu and a graph

When a choice is made, call the appropriate method for plotting
the data for that choice.
"""

import wx

from graph5.graph import Graph
from graph5.style import Style
from graph5.datenum import num2date

import common.sysdata as sysdata


######################################################################
class dataWindow(wx.Panel):
    """ widget that contains a choice menu and a graph """

    def __init__(self, parent, statusbar, main_widget):
        wx.Panel.__init__(self, parent, -1)

        self.main = main_widget    # we need this for middle mouse click events
        self.parent = parent
        self.statusbar = statusbar
        self.df = None
        self.params = None
        self.category = True
        self.strategy = False

        sizer1 = wx.BoxSizer(wx.VERTICAL)
        self.SetSizer(sizer1)

        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer1.Add(box2, 0, wx.EXPAND | wx.ALL, 3)

        label = wx.StaticText(self, -1, "Parameter: ")
        box2.Add(label, 0, wx.ALIGN_CENTRE | wx.LEFT, 5)

        self.choice = wx.Choice(self, -1, size=(250, -1))
        box2.Add(self.choice, 0, wx.ALIGN_LEFT, 0)
        self.Bind(wx.EVT_CHOICE, self.updateParams, self.choice)

        self.plot = Graph(self)
        self.plot.legend.showLegend = 1
        self.plot.showGrid(True)
        self.plot.axes[0].labelDateUseYear = 0
        self.plot.SetLocation(100, -150, 20, -40)
        self.plot.syncAxis(50)
        sizer1.Add(self.plot, 1, wx.EXPAND, 5)

        self.plot.Bind(wx.EVT_MIDDLE_DOWN, self.selectPoint)

    # ----------------------------------------------
    def setOptions(self, df, default=0):
        """ set the data needed by this class.

        Data is passed in as DataFrame.  This data
        is created after this class is created, so can't do this
        in the init routine.
         """

        self.df = df

        # remove string data columns from choices list
        choices = []
        self.params = {}
        for name, dtype in zip(self.df.columns, self.df.dtypes):
            title = name.title()
#            print(name, title, dtype)
            if "date" in name: continue
            if "object" not in (str(dtype)):
                self.params[title] = name
                choices.append(title)

        # get current selected parameter
        param = self.choice.GetStringSelection()

        # if parameter is available, use that, otherwise use default
        ch1 = default
        if param in choices:
            ch1 = choices.index(param)

        # update the choice list
        self.choice.SetItems(choices)
        self.choice.SetSelection(ch1)

    # ----------------------------------------------
    def Categorize(self, separate_data=True):
        """ if separate_data is True, then plots will be separated
        by the sample type, that is, a separate dataset for each
        sample or std gas
        """

        self.category = separate_data

    # ----------------------------------------------
    def Strategy(self, separate_data=True):
        """ if separate_data is True, then plots will be separated
        by the flask strategy, that is, a separate dataset for each
        strategy number.  This implies the self.category is set to True
        (stds don't have strategy and should be separate)
        """

        self.strategty = separate_data

    # ----------------------------------------------
    def updateParams(self, event=None):
        """ choice has changed. Update the plot """

        title = self.choice.GetStringSelection()  # title
        param = self.params[title]  # convert to name

        self.statusbar.SetStatusText("Getting %s ..." % param)
        self.plot.clear()

        if title == "Mole_Fraction":
            sysdata.plot_mole_fractions(self.df, self.plot)

        elif title == "Response Curve":
            sysdata.response_curve(self.data.files, self.plot)

        elif title == "Residuals":
            sysdata.residuals(self.data.files, self.plot)

        else:
            sysdata.plot_raw_signal(self.df, param, title, self.plot, separate=self.category)

        self.plot.update()
        self.statusbar.SetStatusText("")

    # -----------------------------------------------------
    def selectPoint(self, event):
        """
        # Get point nearest middle mouse button click.
        # Get the coordinates, find closest data point,
        # then call the main window to decide if we want
        # to highlight the point or not, and handle
        # other updates too.
        """

        x = event.x
        y = event.y
        name, ix, dist = self.plot.findClosestPoint(x, y)
        if dist < 20:

            dataset = self.plot.getDataset(name)
            xp = dataset.xdata[ix]
            yp = dataset.ydata[ix]
            adate = num2date(xp)

            flask_event = self.findEvent(adate)
            if flask_event:

                self.main.clearMarkers()
                self.highlightPoint(xp, yp)

                self.main.setFlaskList(flask_event, adate)

        event.Skip()

    # -----------------------------------------------------
    def highlightPoint(self, xp, yp):
        """ Draw a highlight marker at the specified point.
        Called by parent, which decides if a middle mouse button click
        should be highlighted.
        """

        style = Style()
        style.setFillColor(wx.Colour(255, 255, 0, 100))
        style.setMarker("square")
        style.setMarkerSize(6)
        self.plot.AddMarker(xp, yp, style)
        self.plot.update()

    # ----------------------------------------------
    def findEvent(self, analysis_date):
        """ Given an analysis date (datetime object), find
        the flask event number and return it """

        event = self.df[self.df['date'] == analysis_date].event.iloc[0]
        try:
            evtnum = int(event)
        except ValueError:
            return None

        return evtnum
