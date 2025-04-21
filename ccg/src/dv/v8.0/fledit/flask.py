# vim: tabstop=4 shiftwidth=4 expandtab
""" app for viewing flask raw files.
Consists of a window with two plots, and
a choice menu for each plot for selecting the
parameter to plot.
"""

import os
from collections import namedtuple
import glob
import wx
import pandas as pd

from ccg_rawdf import Rawfile

from common.getraw import GetRawDialog
from common.getrange import GetRawRangeDialog
from common.FileView import FileView
from common.flask_listbox import selectedFlaskListbox, SiteStrings
from common.TextView import TextView
from common.utils import get_path

from fledit.dataWindow import dataWindow


##################################################################################
class flRaw(wx.Frame):
    """ app for viewing flask raw files """

    def __init__(self, parent, ID=-1, title="View Flask Raw Files", rawfile=None, gas=None):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(930, 700))

        self.edit_event = None
        self.opendlg = None
        self.rangedlg = None
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

        # a text control to hold raw file name
        self.text = wx.TextCtrl(self, -1, "")
        self.text.SetEditable(False)

        box0.Add(self.text, 1, wx.EXPAND, 0)

        # back and forward buttons for going to previous and next raw file
        b = wx.Button(self, wx.ID_BACKWARD)
        box0.Add(b, 0, wx.EXPAND | wx.ALL, 2)
        b.Enable(False)
        self.prev = b
        self.Bind(wx.EVT_BUTTON, self._get_raw_file, b)

        b = wx.Button(self, wx.ID_FORWARD)
        box0.Add(b, 0, wx.EXPAND | wx.ALL, 2)
        b.Enable(False)
        self.next = b
        self.Bind(wx.EVT_BUTTON, self._get_raw_file, b)

        # -------------------------------
        # divider line
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        self.sizer.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 0)

        # -------------------------------
        # splitter window to hold two graphs
        sw = wx.SplitterWindow(self, -1, style=wx.SP_LIVE_UPDATE)
        self.sizer.Add(sw, 1, wx.EXPAND, 0)
        sw.SetSashGravity(0.5)

        p1 = dataWindow(sw, self.sb, self)
        p2 = dataWindow(sw, self.sb, self)

        self.dw = []
        self.dw.append(p1)
        self.dw.append(p2)

        sw.SplitHorizontally(p1, p2, 0)

        self.CenterOnScreen()

        # --------------------
        # single line list to show flask sample info for selected data point
        self.listbox2 = selectedFlaskListbox(self)
        self.sizer.Add(self.listbox2, 0, wx.EXPAND, 0)

        self.SetSizer(self.sizer)

        # if this class is called from another app
        if rawfile:
            FlData = namedtuple('fldata', ['project', 'parameter', 'sys', 'year', 'files', 'refgasfile'])
            self.data = FlData(project='flask', parameter=gas, sys='', year=0, files='', refgasfile='')
            self.data = self.data._replace(files=[rawfile])
            self._read_file()

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the top menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        btn102 = self.file_menu.Append(102, "Open Single Raw File...", "Select one raw file to view")
        btn103 = self.file_menu.Append(103, "Open Date Range...", "Select multiple raw files to view")

        self.file_menu.AppendSeparator()
        btn101 = self.file_menu.Append(101, "Exit", "Exit the program")

        self.Bind(wx.EVT_MENU, self._get_data, btn102)
        self.Bind(wx.EVT_MENU, self._get_date_range_data, btn103)
        self.Bind(wx.EVT_MENU, self.OnExit, btn101)

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.menuBar.Append(self.edit_menu, "Edit")

        btn200 = self.edit_menu.Append(200, "Flag Data")

        self.Bind(wx.EVT_MENU, self._flagdata, btn200)

        self.edit_menu.Enable(200, False)

        # ---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")
        btn300 = self.view_menu.Append(300, "View Raw File", "View contents of raw file")
        btn301 = self.view_menu.Append(301, "View Data", "View Data")
        self.view_menu.AppendSeparator()
        self.sep_data = self.view_menu.Append(303, "Separate Data by Sample Type", kind=wx.ITEM_CHECK)
        self.sep_strategy = self.view_menu.Append(304, "Separate Data by Sample Strategy", kind=wx.ITEM_CHECK)
        self.sep_data.Check()

        self.Bind(wx.EVT_MENU, self.viewRawFile, btn300)
        self.Bind(wx.EVT_MENU, self.viewData, btn301)
        self.Bind(wx.EVT_MENU, self.category, self.sep_data)
        self.Bind(wx.EVT_MENU, self.strategy, self.sep_strategy)

        self.view_menu.Enable(300, False)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def _get_data(self, evt):
        """ Pick a new raw file """

        if self.opendlg is None:
            self.opendlg = GetRawDialog(self, "flask")

        self.opendlg.CenterOnScreen()
        val = self.opendlg.ShowModal()
        if val == wx.ID_OK:
            self.data = self.opendlg.data
            self._read_file()
            self.enable_buttons()

    # ----------------------------------------------
    def _get_date_range_data(self, evt):
        """ Pick raw files over a date range """

        if self.rangedlg is None:
            self.rangedlg = GetRawRangeDialog(self)

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

            self.data = self.data._replace(files=[])
            for year in range(startyear, endyear+1):
                dirname = "/ccg/%s/%s/%s/raw/%s" % (self.data.parameter.lower(),
                                                    self.data.project,
                                                    self.data.sys, year)

                # find raw files between requested dates
                path = "%s/%d-*.%s" % (dirname, year, self.data.parameter.lower())
                path = get_path(path)
                files = sorted(glob.glob(path))
                for filename in files:
                    name = os.path.basename(filename)
                    if startfile <= name <= endfile:
                        self.data.files.append(filename)

            self._read_file()
            self.enable_buttons(False)

    # ----------------------------------------------
    def _flagdata(self, evt):
        """ Show the flag dialog.  One line for each data entry. """

        flagdlg = SiteStrings(self, self.data.files, self.data.parameter, self.edit_event)
        flagdlg.CenterOnScreen()
        flagdlg.Show()

    # -----------------------------------------------------------------
    def _read_file(self):
        """ Read the raw file, update the graphs """

        self.SetCursor(wx.Cursor(wx.CURSOR_WAIT))

        self.df = None
        # read in the raw files, make one pandas dataframe
        for rawfile in self.data.files:
            raw = Rawfile(rawfile, "flask")
            print(raw.data.columns)
            if self.df is None:
                self.df = raw.data
            else:
                self.df = pd.concat([self.df, raw.data], ignore_index=True)

#        print(self.df)

        for n, datawindow in enumerate(self.dw):
            datawindow.setOptions(self.df, default=n)
            datawindow.updateParams()

        if len(self.data.files) == 1:
            self.text.SetValue(self.data.files[0])
        else:
            self.text.SetValue("%s to %s" % (self.data.start_date, self.data.end_date))

        self.listbox2.DeleteAllItems()
        self.listbox2.editbtn.Enable(False)

        self.SetCursor(wx.Cursor(wx.NullCursor))

    # --------------------------------------------------------------
    def enable_buttons(self, enable_back_forward=True):
        """ enable the next and previous buttons, and the View menu items """

        self.spst.SetLabel(self.data.parameter.upper())
        self.sysst.SetLabel(self.data.sys)
        self.sizer.Layout()
        self.edit_menu.Enable(200, True)

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
        """ view the raw file """

        dlg = FileView(self, self.data.files[0])
        dlg.Show()

    # --------------------------------------------------------------
    def viewData(self, evt):
        """ view the data from raw file """

        dlg = TextView(self, self.df.to_string())
        dlg.Show()

    # ----------------------------------------------
    def OnExit(self, evt):
        """ exit the app """

        self.Close(True)  # Close the frame.

    # ----------------------------------------------
    def clearMarkers(self):
        """ clear symbol markers from all data windows """

        for datawindow in self.dw:
            datawindow.plot.ClearMarkers()
            datawindow.plot.update()

    # ----------------------------------------------
    def setFlaskList(self, flask_evt, analysis_date):
        """ Update list box with selected flask data
        Called from dataWindow widget
        """

        self.listbox2.setItems(self.data.parameter, flask_evt, analysis_date)
        self.edit_event = flask_evt

    # ----------------------------------------------
    def category(self, evt):
        """ handle check menu item for separating data """

        checked = self.sep_data.IsChecked()

        for datawindow in self.dw:
            datawindow.Categorize(checked)
            datawindow.updateParams()

    # ----------------------------------------------
    def strategy(self, evt):
        """ handle check menu item for separating data by strategy"""

        checked = self.sep_strategy.IsChecked()
        print(checked)

#        for datawindow in self.dw:
#            datawindow.Categorize(checked)
#            datawindow.updateParams()
