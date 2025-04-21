# vim: tabstop=4 shiftwidth=4 expandtab
"""
Main dialog for viewing/editing in-situ data
User can select one month of data, and dialog
shows two plots where the user can select various
parameters, such as mole fractions, average analyzer output, qc data ...

A dialog for flagging data is available, where user inputs a flag
for selected data and the database is updated with that flag.
"""

import calendar
import glob
import datetime
import wx

import ccg_db_conn
import ccg_insitu_raw
import ccg_flask_data
import ccg_insitu_data2
from graph5.toolbars import ZoomToolBar

from common.TextView import TextView
from common.FileView import FileView
from common.utils import get_path

from .open import OpenDialog
from .flag import FlagDialog
from .tanks import TankDialog
from .dataWindow import dataWindow


##################################################################################
class InsituEdit(wx.Frame):
    """ Main dialog for isedit - in-situ data viewing """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(950, 850))

        self.overlay = 1
        self.opendlg = None
        self.code = None
        self.year = None
        self.month = None
        self.gas = None
        self.system = None
        self.datalist = None
        self.flaskdata = None
        self.target = None
        self.voltlist = None

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.sb = self.CreateStatusBar()

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        self.datebar = self.mkDatesBar()
        self.sizer.Add(self.datebar, 0, wx.EXPAND, 0)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        self.sizer.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 0)

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)
        self.zoomtb.Enable(False)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        self.sizer.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 0)

#        sw = wx.SplitterWindow(self, -1, style=wx.SP_LIVE_UPDATE)
#        sw = wx.SplitterWindow(self)
#        sw.SetSashGravity(0.5)
#        self.sizer.Add(sw, 1, wx.EXPAND, 0)

        # -------------------------------

#        p1 = dataWindow(self, sw, self.sb)
#        p2 = dataWindow(self, sw, self.sb)
        p1 = dataWindow(self, self, self.sb)
        p2 = dataWindow(self, self, self.sb)
        self.sizer.Add(p1, 1, wx.EXPAND, 0)
        self.sizer.Add(p2, 1, wx.EXPAND, 0)

        self.dw = []
        self.dw.append(p1)
        self.dw.append(p2)

        self.zoomtb.SetGraph(p1.plot)
        self.zoomtb.SetGraph(p2.plot)

#        sw.SplitHorizontally(p1, p2, 0)
#        sw.UpdateSize()

        # -------------------------------
        today = datetime.datetime.today()
        self.year = today.year
        self.month = today.month
        (a, self.daysinmonth) = calendar.monthrange(self.year, self.month)

        # these will be the days to plot, either full month or partial month
        self.startday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
        self.endday = datetime.datetime(self.year, self.month, self.daysinmonth, 0, 0, 0)

        # first day of month, first day of next month
        self.firstday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
        self.lastday = self.endday + datetime.timedelta(days=1)

        self.SetSizer(self.sizer)
#       self.sizer.Layout()
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    # ----------------------------------------------
    def mkDatesBar(self):
        """ Create a box with sliders for choosing the day of the month.
        There are 3 sliders, one for starting day, one for ending day,
        and one for choosing a single day of the month.
        Also include a button for setting the entire month.
        """

        p = wx.Panel(self)
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        p.SetSizer(box1)

        box2 = wx.FlexGridSizer(0, 3, 2, 2)

        label = wx.StaticText(p, -1, "Start Day: ")
        box2.Add(label, 0, wx.ALIGN_RIGHT | wx.TOP | wx.LEFT, 20)

        self.startdayofmonth = wx.Slider(p, -1, 1, 1, 31, size=(250, -1), style=wx.SL_HORIZONTAL | wx.SL_AUTOTICKS | wx.SL_VALUE_LABEL)
        self.startdayofmonth.SetPageSize(1)
        box2.Add(self.startdayofmonth, 0, wx.ALIGN_LEFT | wx.ALL, 0)
        self.Bind(wx.EVT_SLIDER, self.get_startday, self.startdayofmonth)
        self.startdayspin = wx.SpinButton(p, -1)
        self.startdayspin.SetRange(1, 31)
        self.startdayspin.SetValue(1)
        box2.Add(self.startdayspin, 0, wx.TOP, 15)
        self.Bind(wx.EVT_SPIN_UP, self.add_start_day, self.startdayspin)
        self.Bind(wx.EVT_SPIN_DOWN, self.subtract_start_day, self.startdayspin)

        label = wx.StaticText(p, -1, "End Day: ")
        box2.Add(label, 0, wx.ALIGN_RIGHT | wx.TOP, 20)
        self.enddayofmonth = wx.Slider(p, -1, 1, 1, 31, size=(250, -1), style=wx.SL_HORIZONTAL | wx.SL_AUTOTICKS | wx.SL_VALUE_LABEL)
        self.enddayofmonth.SetPageSize(1)
        box2.Add(self.enddayofmonth, 0, wx.ALIGN_LEFT | wx.ALL, 0)
        self.Bind(wx.EVT_SLIDER, self.get_endday, self.enddayofmonth)
        self.enddayspin = wx.SpinButton(p, -1)
        self.enddayspin.SetRange(1, 31)
        self.enddayspin.SetValue(31)
        box2.Add(self.enddayspin, 0, wx.TOP, 15)
        self.Bind(wx.EVT_SPIN_UP, self.add_end_day, self.enddayspin)
        self.Bind(wx.EVT_SPIN_DOWN, self.subtract_end_day, self.enddayspin)

        box1.Add(box2)

        label = wx.StaticText(p, -1, " OR ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.LEFT, 5)

        box2 = wx.FlexGridSizer(0, 3, 2, 2)
        label = wx.StaticText(p, -1, "Single Day: ")
        box2.Add(label, 0, wx.RIGHT | wx.TOP, 20)

        self.day = wx.Slider(p, -1, 1, 1, 31, size=(250, -1), style=wx.SL_HORIZONTAL | wx.SL_AUTOTICKS | wx.SL_VALUE_LABEL)
        self.day.SetPageSize(1)
        self.day.SetLineSize(1)
        box2.Add(self.day, 0, wx.ALIGN_LEFT | wx.ALL, 0)
        self.Bind(wx.EVT_SLIDER, self.get_day, self.day)
        self.dayspin = wx.SpinButton(p, -1)
        self.dayspin.SetRange(1, 31)
        box2.Add(self.dayspin, 0, wx.TOP, 15)
        self.Bind(wx.EVT_SPIN_UP, self.add_day, self.dayspin)
        self.Bind(wx.EVT_SPIN_DOWN, self.subtract_day, self.dayspin)

        box1.Add(box2)

        label = wx.StaticText(p, -1, " OR ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.LEFT, 5)

        btn = wx.Button(p, -1, "Entire Month")
        box1.Add(btn, 0, wx.ALIGN_CENTRE | wx.LEFT, 5)
        self.Bind(wx.EVT_BUTTON, self.getmonth, btn)

        p.Enable(False)

        return p

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the menu bar for the application """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(102, "Open...")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(103, "Previous Month")
        self.file_menu.Append(104, "Next Month")
        self.file_menu.Append(105, "Reload Current Month")
#        self.file_menu.AppendSeparator ()
#        self.file_menu.Append (110, "Print Preview...")
#        self.file_menu.Append (-1, "Print")

        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Exit", "Exit the program")

        self.Bind(wx.EVT_MENU, self.opendata, id=102)
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        self.Bind(wx.EVT_MENU, self.previousMonth, id=103)
        self.Bind(wx.EVT_MENU, self.nextMonth, id=104)
        self.Bind(wx.EVT_MENU, self.reload, id=105)

        self.file_menu.Enable(103, False)
        self.file_menu.Enable(104, False)
        self.file_menu.Enable(105, False)

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.menuBar.Append(self.edit_menu, "Edit")

        self.edit_menu.Append(200, "Flag Data...")
        self.edit_menu.Append(202, "Flag Target Data...")

        self.Bind(wx.EVT_MENU, self.flag, id=200)
        self.Bind(wx.EVT_MENU, self.flagtarget, id=202)

        self.edit_menu.Enable(200, False)
        self.edit_menu.Enable(202, False)

        # ---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")

        self.view_menu.Append(301, "Overlay Flask Data", "", wx.ITEM_CHECK)
        self.view_menu.Append(300, "Operator Log")
        self.view_menu.Append(302, "Working Tanks")
        self.view_menu.Append(303, "Raw Data")

        self.Bind(wx.EVT_MENU, self.getLog, id=300)
        self.Bind(wx.EVT_MENU, self.setOverlay, id=301)
        self.Bind(wx.EVT_MENU, self.getWorkTanks, id=302)
        self.Bind(wx.EVT_MENU, self.viewRawdata, id=303)

        self.view_menu.Enable(300, False)
        self.view_menu.Enable(302, False)
        self.view_menu.Enable(303, False)
        self.view_menu.Check(301, self.overlay)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def get_startday(self, event):
        """ value of start day slider has changed """

        startday = self.startdayofmonth.GetValue()
        self.set_start_day(startday)
        self.startdayspin.SetValue(startday)
        event.Skip()

    # ----------------------------------------------
    def set_start_day(self, startday):
        """ set the start day for range of days """

        self.startday = datetime.datetime(self.year, self.month, startday, 0, 0, 0)
        if self.startday > self.endday:
            self.endday = self.startday
            self.enddayofmonth.SetValue(startday)

        self.setPlotDates()

    # ----------------------------------------------
    def add_start_day(self, event):
        """ add one day at the start """

        startday = self.startdayofmonth.GetValue() + 1
        if startday > self.daysinmonth:
            return
        self.set_start_day(startday)
        self.startdayofmonth.SetValue(startday)  # set start slider to correct day

    # ----------------------------------------------
    def subtract_start_day(self, event):
        """ subtract one day from the start """

        startday = self.startdayofmonth.GetValue() - 1
        if startday == 0:
            return
        self.set_start_day(startday)
        self.startdayofmonth.SetValue(startday)  # set start slider to correct day

    # ----------------------------------------------
    def add_end_day(self, event):
        """ add one day to the end """

        endday = self.enddayofmonth.GetValue() + 1
        if endday > self.daysinmonth:
            return
        self.set_end_day(endday)
        self.enddayofmonth.SetValue(endday)  # set end slider to correct day

    # ----------------------------------------------
    def subtract_end_day(self, event):
        """ subtract one day from end of day range """

        endday = self.enddayofmonth.GetValue() - 1
        if endday == 0:
            return
        self.set_end_day(endday)
        self.enddayofmonth.SetValue(endday)  # set end slider to correct day

    # ----------------------------------------------
    def add_day(self, event):
        """ go to next day for single day """

        day = self.day.GetValue() + 1
        if day > self.daysinmonth:
            return
        self.set_day(day)
        self.day.SetValue(day)  # set single day slider to correct day

    # ----------------------------------------------
    def subtract_day(self, event):
        """ go to previous day for single day """

        day = self.day.GetValue() - 1
        if day == 0:
            return
        self.set_day(day)
        self.day.SetValue(day)  # set single day slider to correct day

    # ----------------------------------------------
    def get_endday(self, event):
        """ value of end day slider has changed """

        endday = self.enddayofmonth.GetValue()
        self.set_end_day(endday)
        self.enddayspin.SetValue(endday)
        event.Skip()

    # ----------------------------------------------
    def set_end_day(self, endday):
        """ set the end day """

        self.endday = datetime.datetime(self.year, self.month, endday, 0, 0, 0)
        if self.endday < self.startday:
            self.startday = self.endday
            self.startdayofmonth.SetValue(endday)
        self.setPlotDates()

    # ----------------------------------------------
    def get_day(self, event):
        """ value of day of month slider has changed
        Pick a single day of the month
        """

        day = self.day.GetValue()
        self.set_day(day)
        event.Skip()

    # ----------------------------------------------
    def set_day(self, day):
        """ set a single day """

        self.startday = datetime.datetime(self.year, self.month, day, 0, 0, 0)
        self.endday = datetime.datetime(self.year, self.month, day, 0, 0, 0)

        self.startdayofmonth.SetValue(day)
        self.enddayofmonth.SetValue(day)
        self.startdayspin.SetValue(day)
        self.enddayspin.SetValue(day)
        self.dayspin.SetValue(day)

        self.setPlotDates()

    # ----------------------------------------------
    # Get data for the entire month
    def getmonth(self, event):
        """ entire month button was clicked """

        self.startday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
        self.endday = datetime.datetime(self.year, self.month, self.daysinmonth, 0, 0, 0)

        self.startdayofmonth.SetValue(self.startday.day)
        self.enddayofmonth.SetValue(self.endday.day)

        self.setPlotDates()
        event.Skip()

    # ----------------------------------------------
    def previousMonth(self, event):
        """ previous month menu button was clicked """

        self.month -= 1
        if self.month == 0:
            self.month = 12
            self.year -= 1

        self.GetMonth()

    # ----------------------------------------------
    def nextMonth(self, event):
        """ next month menu button was clicked """

        self.month += 1
        if self.month == 13:
            self.month = 1
            self.year += 1

        self.GetMonth()

    # ----------------------------------------------
    def reload(self, event):
        """ reload month menu button was clicked """

        self.GetMonth()

    # ----------------------------------------------
    def opendata(self, e):
        """ Pick a new station and month of data.

        When opening a new month of data,
        reset the plots to the full month
        """

        if self.opendlg is None:
            self.opendlg = OpenDialog(self)

        self.opendlg.Show()
        self.opendlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.opendlg.ShowModal()
        if val == wx.ID_OK:
            self.code = self.opendlg.code
            self.year = self.opendlg.year
            self.month = self.opendlg.month
            self.gas = self.opendlg.species
            self.system = self.opendlg.system.lower()
            print("@@@@ system is", self.system)
            self.sitenum = self.opendlg.sitenum
            self.paramnum = self.opendlg.paramnum

            self.GetMonth()

    # ----------------------------------------------
    def GetMonth(self):
        """ Get a month of data from database and files,
        update widgets and plots
         """

        self.SetStatusText("Getting data from database...")
#        self.SetCursor(wx.Cursor(wx.CURSOR_WAIT))

        # reset the start and end days to be the entire month
        (a, self.daysinmonth) = calendar.monthrange(self.year, self.month)
        self.startday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
        self.endday = datetime.datetime(self.year, self.month, self.daysinmonth, 0, 0, 0)

        # first day of month, first day of next month
        self.firstday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
        self.lastday = self.endday + datetime.timedelta(days=1)

        # get the data
        self.datalist = self._get_insitu_data()  # a pandas dataframe
        self.flaskdata = self._get_flask_data()  # a pandas dataframe
        self.target = self._get_target_data()    # a pandas dataframe
        self.voltlist = self._get_raw_data()     # an InsituRaw object

        # update the plots
        for n, datawindow in enumerate(self.dw):
            datawindow.setOptions(self.code, self.gas, self.year, self.month, self.system, self.startday, self.endday, self.overlay, default=n)
            datawindow.setData(self.datalist, self.flaskdata, self.target, self.voltlist)
            datawindow.updateParams()

        # update the widgets
        self.startdayofmonth.SetRange(1, self.daysinmonth)
        self.startdayofmonth.SetValue(self.startday.day)
        self.startdayofmonth.SetPageSize(1)
        self.enddayofmonth.SetRange(1, self.daysinmonth)
        self.enddayofmonth.SetValue(self.endday.day)
        self.enddayofmonth.SetPageSize(1)
        self.day.SetRange(1, self.daysinmonth)
        self.day.SetPageSize(1)
        self.day.SetValue(self.startday.day)

        self.datebar.Enable(True)
        self.zoomtb.Enable(True)
        self.file_menu.Enable(103, True)    # previous month
        self.file_menu.Enable(104, True)    # next month
        self.file_menu.Enable(105, True)    # reload month
        self.edit_menu.Enable(200, True)    # flag data
#        self.edit_menu.Enable(203, True)    # recalc
        self.view_menu.Enable(300, True)    # observer log
        self.view_menu.Enable(302, True)    # view worktanks
        self.view_menu.Enable(303, True)    # view rawdata

        if self.system in ("lgr", "picarro", "pic", "ndir", "aeris"):
            self.edit_menu.Enable(202, True)    # flag target gas
        else:
            self.edit_menu.Enable(202, False)    # flag target gas

#        if self.gas == "co2" and self.system != "LGR":
#            self.edit_menu.Enable(201, True)
#        else:
#            self.edit_menu.Enable(201, False)    # flag voltage

        self.SetStatusText("")

    # ----------------------------------------------
    def setPlotDates(self):
        """ start and end days have changed. update the plots, but don't read in new data """

        for datawindow in self.dw:
            datawindow.setDates(self.startday, self.endday)

    # ----------------------------------------------
    def _get_insitu_data(self):
        """ Pull the insitu mole fraction data out of the insitu_data mysql table """

        f = ccg_insitu_data2.InsituData(self.gas, self.code, 0)
        f.setRange(self.firstday, self.lastday)
        f.setSystem(self.system)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.run(as_dataframe=True)
#        print(f.results)

        return f.results

    # -------------------------------------------------------
    def _get_flask_data(self):
        """ get flask data for this month from db """

        f = ccg_flask_data.FlaskData(self.gas, self.code)
        f.setRange(start=self.firstday, end=self.lastday)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.run(as_dataframe=True)

        return f.results

    # -------------------------------------------------------
    def _get_target_data(self):
        """ get target cals from db """

        if self.code == "mko":
            return None

        f = ccg_insitu_data2.InsituData(self.gas, self.code, 0, use_target=True)
        f.setRange(self.firstday, self.lastday)
        f.setSystem(self.system)
        f.includeFlaggedData()
        f.includeHardFlags()
        f.run(as_dataframe=True)

        return f.results

    # -------------------------------------------------------
    def _get_raw_data(self):
        """ read raw files to get voltage data """

        rawdir = "/ccg/%s/in-situ/%s/%s/raw/%s/%d-%02d-*.%s" % (self.gas,
                                                                self.code.lower(),
                                                                self.system,
                                                                self.year,
                                                                self.year,
                                                                self.month,
                                                                self.gas)
        rawdir = get_path(rawdir)
        files = sorted(glob.glob(rawdir))

        if len(files) > 0:

            # read in the raw files and return a list of raw data
            ir = ccg_insitu_raw.InsituRaw(self.code, self.gas, files, system=self.system)
            return ir

        return None

    # ----------------------------------------------
    def flag(self, e):
        """ Show the flag dialog.  One line for each data entry. """

        flagdlg = FlagDialog(self, self.datalist)
        flagdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = flagdlg.ShowModal()
        if val == wx.ID_OK:

            self.make_flag_changes(flagdlg.changes)

            for n, datawindow in enumerate(self.dw):
                datawindow.updateMR()

#            self.updateFlagLog(flagdlg.flaginfo)

        # destroy the dialog each time so we make sure it always shows correct flags.
        flagdlg.Destroy()

    # ----------------------------------------------
    def make_flag_changes(self, changes):
        """ update the database with flag changes

        Also update the datalist with new flags
        """

        FLAG_COLUMN = list(self.datalist.columns).index("qcflag")
        COMMENT_COLUMN = list(self.datalist.columns).index("comment")

        db = ccg_db_conn.ProdDB()
#        table = self._get_db_table("insitu")

        print(changes)
        for index, (newflag, newcomment) in changes.items():
            oldflag = self.datalist['qcflag'].iloc[index]    # old flag
            oldcomment = self.datalist['comment'].iloc[index]    # old comment
            print("index", index, "oldflag", oldflag, "newflag", newflag, "flag_column", FLAG_COLUMN, "oldcomment", oldcomment, "newcomment", newcomment)
            if newflag != oldflag or newcomment != oldcomment:
                self.datalist.iloc[index, FLAG_COLUMN] = newflag
                self.datalist.iloc[index, COMMENT_COLUMN] = newcomment

                date = self.datalist.iloc[index]['date']
# stop updating old tables 22 jul 2024 - kwt
#                sql = "UPDATE %s " % table
#                sql += "SET flag='%s' " % newflag
#                sql += "WHERE date='%s-%s-%s' " % (date.year, date.month, date.day)
#                sql += "AND hr=%s AND min=%s AND sec=%s " % (date.hour, date.minute, date.second)
#                print(sql)
#                db.doquery(sql)

                sql = "UPDATE ccgg.insitu_data "
                sql += "SET flag='%s', comment='%s' " % (newflag, newcomment)
                sql += "WHERE date='%s' " % date.strftime("%Y-%m-%d %H:%M:%S")
                sql += "AND site_num=%d " % self.sitenum
                sql += "AND parameter_num=%d " % self.paramnum
#                print(sql)
                db.doquery(sql)

    # ----------------------------------------------
    def updateFlagLog(self, flaginfo):
        """ Update the file with comments about flags that were applied. """

        logfile = "/ccg/%s/in-situ/%s/%s/flags.log" % (self.gas, self.code.lower(), self.system)
        logfile = get_path(logfile)

#        f = open(logfile, "a")
        for t in flaginfo:    # t is start date, end date flag comment
            s = "%s|%s|%s|%s" % t
            s += "|%s" % datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
#            f.write(s + "\n")
            print(s)

#        f.close()

    # ----------------------------------------------
    def flagtarget(self, e):
        """ Show the flag target dialog.  One line for each data entry.

        For each selected target measurement, update the flag in the database.
        """

        flagdlg = FlagDialog(self, self.target)
        flagdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = flagdlg.ShowModal()
        if val == wx.ID_OK:
            FLAG_COLUMN = list(self.target.columns).index("qcflag")
            COMMENT_COLUMN = list(self.datalist.columns).index("comment")

            db = ccg_db_conn.ProdDB()
#            table = self._get_db_table("target")

            print(flagdlg.changes)
            for index, (newflag, newcomment) in flagdlg.changes.items():
                oldflag = self.target['qcflag'].iloc[index]    # old flag
                oldcomment = self.datalist['comment'].iloc[index]    # old comment
                print("index", index, "oldflag", oldflag, "newflag", newflag, "flag_column", FLAG_COLUMN)
                if newflag != oldflag or newcomment != oldcomment:
                    self.target.iloc[index, FLAG_COLUMN] = newflag
                    self.target.iloc[index, COMMENT_COLUMN] = newcomment

                    date = self.target.iloc[index]['date']
#                    sql = "UPDATE %s SET flag='%s' " % (table, newflag)
#                    sql += "WHERE date='%s-%s-%s' " % (date.year, date.month, date.day)
#                    sql += "AND hr=%s AND min=%s AND sec=%s " % (date.hour, date.minute, date.second)
#                    print(sql)
#                    db.doquery(sql)

                    sql = "UPDATE ccgg.insitu_data "
                    sql += "SET flag='%s', comment='%s' " % (newflag, newcomment)
                    sql += "WHERE date='%s' " % date.strftime("%Y-%m-%d %H:%M:%S")
                    sql += "AND site_num=%d " % self.sitenum
                    sql += "AND parameter_num=%d " % self.paramnum
                    sql += "AND target=1 "
    #                print(sql)
                    db.doquery(sql)

            for n, datawindow in enumerate(self.dw):
                datawindow.updateMR()

        # destroy the dialog each time so we make sure it always shows correct flags.
        flagdlg.Destroy()

    # --------------------------------------------------------------
    def getLog(self, event):
        """ Get all the operator log entries and display in a window """

        print(self.system)
        logfile = "/ccg/insitu/%s/oper_log.txt" % (self.code.lower())
        logfile = get_path(logfile)

        dlg = FileView(self, logfile)
        dlg.Show()

    # --------------------------------------------------------------
    def setOverlay(self, event):
        """ Set whether to show flask data overlayed on insitu """

        self.overlay = event.IsChecked()
        for datawindow in self.dw:
            datawindow.overlay = self.overlay
            datawindow.updateMR()

    # --------------------------------------------------------------
    def getWorkTanks(self, event):
        """ Get the working tanks being used for this month and show in a list dialog. """

        dlg = TankDialog(self, self.gas, self.code, self.system, self.year, self.month)
        dlg.Show()

    # --------------------------------------------------------------
    def viewRawdata(self, event):
        """ Print out the raw data and show in dialog """

        text = []
        for row in self.voltlist.data.itertuples():
            text.append(self.voltlist.format_row(row))

        dlg = TextView(self, "\n".join(text))
        dlg.Show()

    # --------------------------------------------------------------
    def _get_db_table(self, which):
        """ Determine mysql table to use. 'which' is either 'insitu' or 'target' """

        table = "%s_%s_%s" % (self.code.lower(), self.gas, which)
        if self.system == "lgr" and self.gas.lower() == "co2" and self.year < 2017:
            table = "%s_%s_%s_b" % (self.code.lower(), self.gas.lower(), which)

        if self.system == "pic" and self.gas.lower() == "co2":
            if self.year == 2019 and self.month < 6:
                table = "%s_%s_%s_b" % (self.code.lower(), self.gas.lower(), which)
            else:
                table = "%s_%s_%s" % (self.code.lower(), self.gas.lower(), which)

        return table

    # ----------------------------------------------
    def OnExit(self, e):
        """ End the application """

        self.Close(True)  # Close the frame.
