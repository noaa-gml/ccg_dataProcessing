# vim: tabstop=4 shiftwidth=4 expandtab
""" app for viewing calibration raw files.
Consists of a window with two plots, and
a choice menu for each plot for selecting the
parameter to plot.
"""

import os
import glob
from collections import namedtuple
import wx
import pandas as pd

from ccg_rawdf import Rawfile

from common.getraw import GetRawDialog
from common.getrange import GetRawRangeDialog
from common.FileView import FileView
from common.utils import get_path

from .dataWindow import dataWindow


##################################################################################
class calRaw(wx.Frame):
    """ app for viewing calibration raw files """

    def __init__(self, parent, ID=-1, title="View Calibration Raw Files"):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(850, 750))

        self.rangedlg = None
        self.finddlg = None
        self.caldata = None
        self.data = None
        self.df = None

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.sb = self.CreateStatusBar()

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # -------------------------------
        box0 = wx.BoxSizer(wx.HORIZONTAL)
        self.sizer.Add(box0, 0, wx.EXPAND, 0)

        self.spst = wx.StaticText(self, -1, " ")
        box0.Add(self.spst, 0, wx.RIGHT | wx.TOP, 8)
        self.sysst = wx.StaticText(self, -1, " ")
        box0.Add(self.sysst, 0, wx.RIGHT | wx.TOP, 8)
        self.instst = wx.StaticText(self, -1, " ")
        box0.Add(self.instst, 0, wx.RIGHT | wx.TOP, 8)

        # a text control to hold raw file name
        self.text = wx.TextCtrl(self, -1, "")
        self.text.SetEditable(False)

        box0.Add(self.text, 1, wx.EXPAND, 0)

        # back and forward buttons for going to previous and next raw file
        b = wx.Button(self, wx.ID_BACKWARD)
        box0.Add(b, 0, wx.EXPAND, 0)
        b.Enable(False)
        self.prev = b
        self.Bind(wx.EVT_BUTTON, self._get_raw_file, b)

        b = wx.Button(self, wx.ID_FORWARD)
        box0.Add(b, 0, wx.EXPAND, 0)
        b.Enable(False)
        self.next = b
        self.Bind(wx.EVT_BUTTON, self._get_raw_file, b)

        # -------------------------------
        # divider line
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        self.sizer.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 0)

        sw = wx.SplitterWindow(self, -1, style=wx.SP_LIVE_UPDATE)
        self.sizer.Add(sw, 1, wx.EXPAND, 0)
        sw.SetSashGravity(0.5)

        # -------------------------------
        # create two data windows for plotting
        p1 = dataWindow(sw, self.sb)
        p2 = dataWindow(sw, self.sb)

        self.dw = []
        self.dw.append(p1)
        self.dw.append(p2)

        sw.SplitHorizontally(p1, p2, 0)

        # --------------------

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(102, "Open Single Raw File...")
        self.file_menu.Append(103, "Open Date Range...")

        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Exit", "Exit the program")

        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        self.Bind(wx.EVT_MENU, self._find_data, id=102)
        self.Bind(wx.EVT_MENU, self._get_date_range_data, id=103)

        # ---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")
        self.view_menu.Append(300, "View Raw File")
        self.view_menu.AppendSeparator()
        self.sep_data = self.view_menu.Append(303, "Separate Data by Sample Type", kind=wx.ITEM_CHECK)
        self.sep_data.Check()
        self.Bind(wx.EVT_MENU, self.category, self.sep_data)
        self.Bind(wx.EVT_MENU, self.viewRawFile, id=300)
        self.view_menu.Enable(300, False)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def _find_data(self, e):
        """ Open a dialog the allows user to pick a system,
        gas, and raw file. """

        if self.finddlg is None:
            self.finddlg = GetRawDialog(self, "cals")

        self.finddlg.CenterOnScreen()
        val = self.finddlg.ShowModal()

        # this does not return until the dialog is closed.
        if val == wx.ID_OK:
            self.data = self.finddlg.data
            self._read_file()
            self.enable_buttons()

    # ----------------------------------
    def _get_date_range_data(self, e):
        """ Pick raw files over a date range """

        if self.rangedlg is None:
            self.rangedlg = GetRawRangeDialog(self, 3)

        self.rangedlg.CenterOnScreen()
        val = self.rangedlg.ShowModal()

        # this does not return until the dialog is closed.
        if val == wx.ID_OK:

            self.data = self.rangedlg.data
            startyear = self.data.start_date.year
            endyear = self.data.end_date.year
            startfile = "%4d-%02d-%02d.0000.%s" % (
                self.data.start_date.year,
                self.data.start_date.month,
                self.data.start_date.day,
                self.data.parameter.lower()
            )
            endfile = "%4d-%02d-%02d.2359.%s" % (
                self.data.end_date.year,
                self.data.end_date.month,
                self.data.end_date.day,
                self.data.parameter.lower()
            )

            # get directories for requested years
            self.data = self.data._replace(files=[])
            for year in range(startyear, endyear+1):
                dirname = "/ccg/%s/%s/%s/raw/%s" % (self.data.parameter.lower(),
                                                    self.data.project,
                                                    self.data.sys,
                                                    year)

                # find raw files between requested dates
                path = "%s/%d-*.%s.%s" % (dirname, year, self.data.inst.lower(), self.data.parameter.lower())
                path = get_path(path)
                files = sorted(glob.glob(path))
                for filename in files:
                    name = os.path.basename(filename)
                    if startfile <= name <= endfile:
                        self.data.files.append(filename)

            self._read_file()
            self.enable_buttons(False)

    # ----------------------------------
    def _read_file(self):
        """ Read and process calibration raw files """

        self.df = None
        # read in the raw files, make one pandas dataframe
        for rawfile in self.data.files:
            raw = Rawfile(rawfile, "cals")
            if self.df is None:
                self.df = raw.data
            else:
                self.df = pd.concat([self.df, raw.data], ignore_index=True)

        # update each datawindow with the raw data
        for n, datawindow in enumerate(self.dw):
            datawindow.setOptions(self.df, default=n)
            datawindow.updateParams()

        if len(self.data.files) == 1:
            self.text.SetValue(self.data.files[0])
        else:
            self.text.SetValue("%s to %s" % (self.data.start_date, self.data.end_date))

    # --------------------------------------------------------------
    def readFile(self, rawfile, gas, system, inst):
        """ public method to allow setting of raw file to use.

        This is called from another module after the
        calRaw is created, e.g.

            frame = calib.CalRaw()
            frame.Show()
            frame.readFile(rawfilename, gas, system, inst)
        """

        RawData = namedtuple('caldata', ['project', 'parameter', 'sys', 'inst', 'year', 'files'])
        self.data = RawData(project='cals', parameter=gas, sys=system, inst=inst, year=0, files=[rawfile])
        self._read_file()
        self.enable_buttons()

    # --------------------------------------------------------------
    def enable_buttons(self, enable_back_forward=True):
        """ enable the next and previous buttons, and the View menu items """

        self.spst.SetLabel(self.data.parameter.upper())
        self.sysst.SetLabel(self.data.sys)
        self.instst.SetLabel(self.data.inst)
        self.sizer.Layout()
        if enable_back_forward:
            self.next.Enable(True)
            self.prev.Enable(True)
            self.view_menu.Enable(300, True)
        else:
            self.next.Enable(False)
            self.prev.Enable(False)
            self.view_menu.Enable(300, False)

        self.SetStatusText("")

    # --------------------------------------------------------------
    def _get_raw_file(self, button):
        """ Find either the next or previous raw file """

        d1 = os.path.dirname(self.data.files[0])
        path = "%s/*.%s" % (d1, self.data.parameter.lower())
        files = sorted(glob.glob(path))

        # get index of current file
        idx = files.index(self.data.files[0])

        if button.GetId() == wx.ID_BACKWARD:
            if idx-1 >= 0:
                prevfile = files[idx-1]
            else:
                prevfile = files[-1]
        else:
            if idx+1 < len(files):
                prevfile = files[idx+1]
            else:
                prevfile = files[0]

        self.data.files[0] = prevfile

        self._read_file()

    # --------------------------------------------------------------
    def viewRawFile(self, evt):
        """ Open a dialog that shows the calibration raw file """

        dlg = FileView(self, self.data.files[0])
        dlg.Show()

    # ----------------------------------------------
    def category(self, evt):
        """ separate datasets by sample type """

        checked = self.sep_data.IsChecked()

        for n, datawindow in enumerate(self.dw):
            datawindow.Categorize(checked)
            datawindow.updateParams()

    # ----------------------------------------------
    def OnExit(self, e):
        """ Exit the dialog """

        self.Close(True)
