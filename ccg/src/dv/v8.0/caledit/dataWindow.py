# vim: tabstop=4 shiftwidth=4 expandtab
"""
widget that contains a choice menu and a graph

When a choice is made, call the appropriate method for plotting
the data for that choice.
"""

import wx

from graph5.graph import Graph

import common.sysdata as sysdata


######################################################################
class dataWindow(wx.Panel):
    """ widget that contains a choice menu and a graph """

    def __init__(self, parent, statusbar):
        wx.Panel.__init__(self, parent, -1)

        self.parent = parent
        self.statusbar = statusbar
        self.df = None
        self.data = None
        self.params = None
        self.category = True

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
        self.plot.syncAxis(200)
        sizer1.Add(self.plot, 1, wx.EXPAND, 5)

    # ----------------------------------------------
    def setOptions(self, df, default=0):
        """ set the data needed by this class.  This data
        is created after this class is created, so can't do this
        in the init routine.
         """

        self.df = df

        # remove string data columns from choices list
        choices = []
        self.params = {}
        for name in self.df.columns:
            title = name.title()
            self.params[title] = name
            if "date" in name: continue
            val = self.df[name].iloc[0]
            if not isinstance(val, str):
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
        """ separate datasets by sample """

        self.category = separate_data

    # ----------------------------------------------
    def updateParams(self, event=None):
        """ choice has changed. Update the plot """

        title = self.choice.GetStringSelection()  # title
        param = self.params[title]  # convert to name

        self.statusbar.SetStatusText("Getting %s ..." % param)
        self.plot.clear()

        sysdata.plot_raw_signal(self.df, param, title, self.plot, separate=self.category)

        self.plot.update()
        self.statusbar.SetStatusText("")
