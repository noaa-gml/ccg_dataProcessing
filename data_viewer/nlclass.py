# vim: tabstop=4 shiftwidth=4 expandtab
""" app for viewing response curve results.
Consists of a window with two plots, and
a choice menu for each plot for selecting the
parameter to plot.
"""

import os
import datetime
import glob
import wx
import pandas as pd

import ccg_nl
from ccg_rawdf import Rawfile

from common.getraw import GetRawDialog
from common.getrange import GetRawRangeDialog, NL
from common.FileView import FileView
from common.TextView import TextView
from common.utils import get_path

from .viewdata import view_nl_data
from .dataWindow import dataWindow
from .recalc import RecalcDialog
from .openfile import OpenFile


##################################################################################
class nlEdit(wx.Frame):
    """ app for viewing response curve results """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(700, 600))

        self.opendlg = None
        self.finddlg = None
        self.rangedlg = None
        self.nldata = None
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

        p1 = dataWindow(sw, self.sb)
        p2 = dataWindow(sw, self.sb)

        self.dw = []
        self.dw.append(p1)
        self.dw.append(p2)

        sw.SplitHorizontally(p1, p2, 0)

        # --------------------

        self.SetSizer(self.sizer)

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

#        m103 = self.file_menu.Append(103, "Open...")
        m102 = self.file_menu.Append(102, "Open Single Raw File...")
        m104 = self.file_menu.Append(104, "Open Date Range...")

        self.file_menu.AppendSeparator()
        m101 = self.file_menu.Append(101, "Exit", "Exit the program")

        self.Bind(wx.EVT_MENU, self._get_date_range_data, m104)
#        self.Bind(wx.EVT_MENU, self._open_data, m103)
        self.Bind(wx.EVT_MENU, self._find_data, m102)
        self.Bind(wx.EVT_MENU, self.OnExit, m101)

        # ---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")
        m300 = self.view_menu.Append(300, "View Raw File")
        m304 = self.view_menu.Append(304, "View Data")
        m301 = self.view_menu.Append(301, "View Response Curve Results")
        m302 = self.view_menu.Append(302, "Recalculate Response Curve...")
        self.view_menu.AppendSeparator()
        self.sep_data = self.view_menu.Append(303, "Separate Data by Sample Type", kind=wx.ITEM_CHECK)
        self.sep_data.Check()
        self.Bind(wx.EVT_MENU, self.viewRawFile, m300)
        self.Bind(wx.EVT_MENU, self.viewResponseData, m301)
        self.Bind(wx.EVT_MENU, self.recalcCurve, m302)
        self.Bind(wx.EVT_MENU, self.viewData, m304)
        self.Bind(wx.EVT_MENU, self.category, self.sep_data)
        self.view_menu.Enable(300, False)
        self.view_menu.Enable(301, False)
        self.view_menu.Enable(302, False)
        self.view_menu.Enable(304, False)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def _find_data(self, e):
        """ Open a dialog the allows user to pick a system,
        gas, and raw file. """

        if self.finddlg is None:
            self.finddlg = GetRawDialog(self, "nl")

        self.finddlg.CenterOnScreen()
        val = self.finddlg.ShowModal()

        # this does not return until the dialog is closed.
        if val == wx.ID_OK:
            self.data = self.finddlg.data
            self._read_file()
            self.enable_buttons(True)

    # ----------------------------------
    def _open_data(self, event):
        """ show dialog for setting response curve raw file. """

        if self.opendlg is None:
            self.opendlg = OpenFile(self)

        val = self.opendlg.ShowModal()

        if val == wx.ID_OK:
            self.data = NlGetData()    # class for holding data
            self.data.files = self.opendlg.filename
            if self.opendlg.refgasfilename:
                self.data.refgasfile = self.opendlg.refgasfilename
            self._read_file()

            self.enable_buttons(True)

        self.opendlg.Hide()

    # ----------------------------------
    def _get_date_range_data(self, e):
        """ Pick raw files over a date range """

        if self.rangedlg is None:
            self.rangedlg = GetRawRangeDialog(self, NL)

        self.rangedlg.CenterOnScreen()
        val = self.rangedlg.ShowModal()

        # this does not return until the dialog is closed.
        if val == wx.ID_OK:

            self.data = self.rangedlg.data
            startyear = self.data.start_date.year
            endyear = self.data.end_date.year

            print(self.data.start_date, self.data.end_date)
            # get directories for requested years
            filelist = []
            for year in range(startyear, endyear+1):
                dirname = "/ccg/%s/%s/%s/raw/%s" % (self.data.parameter.lower(),
                                                    self.data.project,
                                                    self.data.sys,
                                                    year)

                print(dirname)
                # find raw files between requested dates
                path = "%s/%d-*.%s.%s" % (dirname, year, self.data.inst.lower(), self.data.parameter.lower())
                path = get_path(path)
                print(path)
                files = sorted(glob.glob(path))
                for filename in files:
                    name = os.path.basename(filename)
                    (datestr, therest) = name.split(".", 1)
                    (year, month, day) = map(int, datestr.split("-"))
                    dt = datetime.date(year, month, day)
                    print(filename, dt)
                    if self.data.start_date <= dt <= self.data.end_date:
                        filelist.append(filename)

            self.data = self.data._replace(files=filelist)

            self._read_file()
            self.enable_buttons(False)

    # ----------------------------------
    def _read_file(self):
        """ Read and process response curve raw file """

        self.SetCursor(wx.Cursor(wx.CURSOR_WAIT))

        self.df = None
        # read in the raw files, make one pandas dataframe
        for rawfile in self.data.files:
            raw = Rawfile(rawfile, "nl")
            if self.df is None:
                self.df = raw.data
            else:
                self.df = pd.concat([self.df, raw.data], ignore_index=True)

        self.data = self.data._replace(inst=raw.instid)

        checked = self.sep_data.IsChecked()

        for n, datawindow in enumerate(self.dw):
            datawindow.setOptions(self.df, self.data, default=n)
            datawindow.Categorize(checked)
            datawindow.updateParams()

        if len(self.data.files) == 1:
            self.text.SetValue(self.data.files[0])
        else:
            self.text.SetValue("%s to %s" % (self.data.start_date, self.data.end_date))

        self.SetCursor(wx.NullCursor)

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
            self.view_menu.Enable(301, True)
            self.view_menu.Enable(302, True)
            self.view_menu.Enable(304, True)
        else:
            self.next.Enable(False)
            self.prev.Enable(False)
            self.view_menu.Enable(300, False)
            self.view_menu.Enable(301, False)
            self.view_menu.Enable(302, False)
            self.view_menu.Enable(304, False)
        self.SetStatusText("")

    # --------------------------------------------------------------
    def _get_raw_file(self, event):
        """ Find either the next or previous raw file """

        d1 = os.path.dirname(self.data.files[0])
        path = "%s/*.%s" % (d1, self.data.parameter.lower())
        files = sorted(glob.glob(path))

        # get index of current file
        idx = files.index(self.data.files[0])

        if event.GetId() == wx.ID_BACKWARD:
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
        """ Open a dialog that shows the response curve raw file """

        dlg = FileView(self, self.data.files[0])
        dlg.Show()

    # --------------------------------------------------------------
    def viewData(self, evt):
        """ view the data from raw file """

        dlg = TextView(self, self.df.to_string())
        dlg.Show()

    # --------------------------------------------------------------
    def viewResponseData(self, evt):
        """ Show information about the response curve """

        rawfile = self.data.files[0]
        nldata = ccg_nl.Response(rawfile)

        s = view_nl_data(nldata)
        dlg = TextView(self, s)
        dlg.Show()

    # ----------------------------------------------
    def recalcCurve(self, e):
        """ Show a dialog with response curve residuals, allow user to change
        odr parameters to fit and compute new residuals.
        """

        print("recalc")
        rawfile = self.data.files[0]
        frame = RecalcDialog(self, rawfile, self.data)
        frame.Show()

    # ----------------------------------------------
    def category(self, evt):
        """ separate datasets by sample type """

        checked = self.sep_data.IsChecked()

        for datawindow in self.dw:
            datawindow.Categorize(checked)
            datawindow.updateParams()

    # ----------------------------------------------
    def OnExit(self, e):
        """ Exit the dialog """

        self.Close(True)
