# vim: tabstop=4 shiftwidth=4 expandtab
"""
Widget for displaying a choice menu and a graph.
When the choice changes, routines are called for
plotting the correct data in the graph.
"""

import datetime
import calendar
import wx

from dateutil.rrule import DAILY, HOURLY

from graph5.graph import Graph
from graph5.style import Style
from graph5.datenum import num2date

from common.edit_dialog import FlagEditDialog

from .sysdata import sysdata
# chs data removed from this version. Use v5.36 if needed


ONEDAY = datetime.timedelta(days=1)


######################################################################
class dataWindow(wx.Panel):
    """ Widget for displaying a choice menu and a graph """

    def __init__(self, top, parent, statusbar):
        wx.Panel.__init__(self, parent, -1)

        self.topwindow = top
        self.statusbar = statusbar

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
        self.plot.SetLocation(80, -180, 40, -50)
        self.plot.syncAxis(100)
        sizer1.Add(self.plot, 1, wx.EXPAND, 5)

    # ----------------------------------------------
    def setOptions(self, code, gas, year, month, system, startday, endday, overlay, default=0):
        """ Set all the options for this class
        Input:
            code - station code
            gas - gas being used
            year - year of the data
            month - month of the data
            system - system name
            startday - startday for the plot
            endday - endday for the plot
            overlay - overlay flask data if True
            default - index in choices to use as default
        """

        self.code = code
        self.gas = gas
        self.year = year
        self.month = month
        self.system = system
        self.startday = startday
        self.endday = endday
        self.overlay = overlay

        self.month_name = calendar.month_name[self.month]

        self.sysdata = sysdata(self.code, self.gas, self.year, self.month, self.system)

        self._set_choices(default)

    # ----------------------------------------------
    def setDates(self, startday, endday):
        """ Set the start and end dates of the plot """

        self.startday = startday
        self.endday = endday

#        self.updateParams()
        param = self.choice.GetStringSelection()
#        self._get_signals(param)
        self._set_plot_range(param)

    # ----------------------------------------------
    def setData(self, datalist, flaskdata, target, voltlist):
        """ set the data to use """

        self.datalist = datalist    # mixing ratios from database
        self.flaskdata = flaskdata    # flask data from database
        self.target = target        # target mixing ratios from database
        self.voltlist = voltlist    # volts/peaks from raw files

    # ----------------------------------------------
    # Update the plot
    def updateParams(self, event=None):
        """ choice has changed """

        param = self.choice.GetStringSelection()
        self._get_signals(param)
        self._set_plot_range(param)

    # ----------------------------------------------
    # Update the plot
    def update(self):
        """ update plot.  Presumably start and end day options have changes """

        self._set_plot_range()

    # ----------------------------------------------
    # update the plots if they show mixing ratio or std. dev.
    # This is called after applying flags to the data
    def updateMR(self):
        """ update the mixing ratio data and update the plot if mixing ratio is shown """

        param = self.choice.GetStringSelection()
        if param == "Mole Fractions":
            self.plot.clear()
            self.sysdata.getMixingRatios(self.plot, self.datalist)
            if self.overlay:
                self.sysdata.getFlaskData(self.plot, self.flaskdata)

        elif param == "Std. Dev.":
            self.plot.clear()
            self.sysdata.getStdDev(self.plot, self.datalist)

        elif param == "Target":
            self.plot.clear()
            self.sysdata.getTarget(self.plot, self.target)

        self.update()

    # ----------------------------------------------
    def _set_choices(self, default):
        """ Get list of parameters for the plot
         and update the Choice widget with this list
        """

        # get current selected parameter
        param = self.choice.GetStringSelection()

        # update the choice list
        self.choice.SetItems(self.sysdata.choices)

        # if parameter is available, use that, otherwise use default
        ch1 = default
        if param in self.sysdata.choices:
            ch1 = self.sysdata.choices.index(param)

        self.choice.SetSelection(ch1)

    # ----------------------------------------------
    def _get_signals(self, param):
        """ Update a plot based on new parameters. """

        self.statusbar.SetStatusText("Getting %s ..." % param)

        plot = self.plot
        self.plot.clear()

        plot.Unbind(wx.EVT_MIDDLE_DOWN)

        if param == "Mole Fractions":
            self.sysdata.getMixingRatios(plot, self.datalist)
            plot.Bind(wx.EVT_MIDDLE_DOWN, self.selectPoint)

            if self.overlay:
                self.sysdata.getFlaskData(plot, self.flaskdata)

        else:
            self.sysdata.getParam(plot, param, self.datalist, self.voltlist, self.target)

        self.statusbar.SetStatusText("")

    # ----------------------------------------------------------------------------------------------
    def _set_plot_range(self, param=None):
        """ set the correct x axis range of the plot depending on what the parameter is """

        axis = self.plot.getXAxis(0)
        if param in ("Response Curve", "Response Curve Residuals") and self.code.upper() in ["MLOx", "BRWx"]:
            axis.setAutoscale()
        else:
            if self.startday == self.endday:
                axis.setAxisDateRange(self.startday, self.endday+ONEDAY)
            else:
                axis.setAxisDateRange(self.startday, self.endday+ONEDAY, 1, DAILY, HOURLY)

        axis = self.plot.getYAxis(0)
        axis.setAutoscale()

        s = "%s %s %s %s" % (self.code.upper(), self.gas.upper(), self.month_name, self.year)
        self.plot.title.text = s

        self.plot.update()

    # -----------------------------------------------------
    def selectPoint(self, event):
        """
        # Get point nearest middle mouse button click.
        # Find the corresponding data from the datalist,
        # and highlight the data point in the graph.
        # Pop up a dialog to edit the flag for the point,
        # and update the data list and graph if a new flag is entered.
        """

        x = event.x
        y = event.y
        name, ix, dist = self.plot.findClosestPoint(x, y)
        print(name, ix, dist)

        dataset = self.plot.getDataset(name)
        xp = dataset.xdata[ix]
        yp = dataset.ydata[ix]
        dt = num2date(xp)
        print(xp, dt)

        row = self.findInList(dt, yp)
        if row:

            edit_flag = row.qcflag

            style = Style()
            style.setFillColor(wx.Colour(255, 255, 0, 100))
            style.setMarker("square")
            style.setMarkerSize(6)
            self.plot.AddMarker(xp, yp, style)
            self.plot.update()

            dlg = FlagEditDialog(self, edit_flag)

            # this does not return until the dialog is closed.
            val = dlg.ShowModal()
            if val == wx.ID_OK:
                newflag = dlg.flag
                comment = dlg.comment
                print("newflag is ", newflag)

                index = row.Index
                changes = {index: (newflag, comment)}
                self.topwindow.make_flag_changes(changes)

                self.updateParams()

#                self.plot.clear()
#                self.sysdata.getMixingRatios(self.plot, self.datalist)
#                self.plot.update()
            else:
                self.plot.ClearMarkers()
                self.plot.update()

        event.Skip()

    # ----------------------------------------------
    def findInList(self, dt, yp):
        """ Find in the datalist the given date, time and value """

        for row in self.datalist.itertuples():
            date = row.date
            value = row.value

            if date.day == dt.day and date.hour == dt.hour and date.minute == dt.minute and yp == value:
                return row

        return None
