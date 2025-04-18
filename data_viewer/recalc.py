# vim: tabstop=4 shiftwidth=4 expandtab
""" A dialog for recalculating a response curve by changing the parameters
for the fit.
"""
import wx

from graph5.graph import Graph

import ccg_nl

from common.TextView import TextView
from .params import ParametersDialog
from .viewdata import view_nl_data


###################################################################
class RecalcDialog(wx.Frame):
    """ A dialog for recalculating a response curve by changing the parameters
    for the fit.
    """

    def __init__(self, parent, rawfile, data):
        wx.Frame.__init__(self, parent, -1, "Recalc Response Curve",
                          wx.DefaultPosition, size=wx.Size(750, 500))

        self.paramsdlg = None
        self.rawfile = rawfile
        self.data = data
        self.nldata = None
        self.orig_nldata = ccg_nl.Response(rawfile)

        # Main sizer
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()
        self.SetStatusText("")

#        self.plot = self.mkGraph()
        self.plot = Graph(self)
        self.plot.showGrid = 1
        self.sizer.Add(self.plot, 1, wx.EXPAND | wx.ALL, 5)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)

        self.Bind(wx.EVT_SHOW, self.setOrigData)

    # ----------------------------------------------
    def mkGraph(self):
        """ Create a graph """

#        plot = Graph(self, -1, xaxis_title="Std/Ref Ratio")
        plot = Graph(self)
        plot.showGrid = 1

        return plot

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        m101 = self.file_menu.Append(101, "Close", "Close the window")
        self.Bind(wx.EVT_MENU, self.OnExit, m101)

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.menuBar.Append(self.edit_menu, "Edit")

        m200 = self.edit_menu.Append(200, "Parameters")
        self.Bind(wx.EVT_MENU, self.get_parameters, m200)

        # ---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")
        m301 = self.view_menu.Append(301, "View Response Curve Results")
        self.Bind(wx.EVT_MENU, self.viewResponseData, m301)

        # ---------------------------------------

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def get_parameters(self, e):
        """ open parameters dialog and get settings """

        if self.paramsdlg is None:
            self.paramsdlg = ParametersDialog(self)
            self.paramsdlg.CenterOnScreen()

        val = self.paramsdlg.ShowModal()

        # this does not return until the dialog is closed.
        if val == wx.ID_OK:

            use_odr = self.paramsdlg.use_odr
            use_sigma = self.paramsdlg.use_sigma
            no_x = self.paramsdlg.no_x
            no_y = self.paramsdlg.no_y
            no_x = not no_x
            no_y = not no_y
            order = self.paramsdlg.order
            exclude = self.paramsdlg.exclude
            functype = self.paramsdlg.functype

            print(use_odr, use_sigma, no_x, no_y, order, exclude, functype)

            self.nldata = ccg_nl.Response(self.rawfile, order=order, odrfit=use_odr,
                                          use_x_weights=no_x, use_y_weights=no_y, use_sigma=use_sigma,
                                          nulltanks=exclude, functype=functype)

            self._showcurve(self.nldata)

    # ----------------------------------------------
    def setOrigData(self, event):
        """ plot the original nl data """

        self._showcurve(self.orig_nldata)

    # ----------------------------------------------
    def _showcurve(self, nldata):
        """ Plot the residuals from response curve """

        x, y = nldata.getResiduals()

        self.plot.createDataset(x, y, "Residuals", symbol='circle', markersize=5, connector="None")
        xax = self.plot.getXAxis(0)
        xax.title.text = "Std/Ref Ratio"

        self.plot.update()

    # ----------------------------------------------
    def OnExit(self, e):
        """ Close the dialog """

        self.Close(True)

    # --------------------------------------------------------------
    def viewResponseData(self, evt):
        """ Show information about the response curve """

        if self.nldata is None:
            s = view_nl_data(self.orig_nldata)
        else:
            s = view_nl_data(self.nldata)
        dlg = TextView(self, s)
        dlg.Show()
