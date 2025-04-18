# vim: tabstop=4 shiftwidth=4 expandtab
"""
Create a wx dialog window with options for
exporting results from the ccgFilter curve fits.
"""

import os
import datetime

import wx

import ccg_filter_export

import ccg_dates


#####################################################################
def dd2dt(x):
    """ convert decimal date to datetime for list x """

    return [ccg_dates.datetimeFromDecimalDate(xp) for xp in x]
#    return map(ccg_dates.datetimeFromDecimalDate(x))


#####################################################################
class ExportDialog(wx.Dialog):
    """ A dialog for export curve fit results """

    def __init__(
        self,
        parent,
        filtdata,
        ID=-1,
        title="Export Data Options",
        size=wx.DefaultSize,
        pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, ID, title, size=size, pos=pos, style=style)

        self.ccgvu = parent
        self.plot = None
        self.filt = filtdata.filt  # the ccgFilter object
        print(self.filt)
        print(self.filt.numpoly)

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        # -----
        box = wx.StaticBox(self, -1, "Choose Datasets to Export")
        sizer1 = wx.StaticBoxSizer(box, wx.HORIZONTAL)
        box0.Add(sizer1, 0, wx.EXPAND | wx.ALIGN_LEFT | wx.ALL, 5)

        # -----
        box = wx.StaticBox(self, -1, "Data")
        sizer3 = wx.StaticBoxSizer(box, wx.VERTICAL)
        sizer1.Add(sizer3, 0, wx.EXPAND | wx.ALIGN_LEFT | wx.ALL, 5)

        self.d1 = wx.CheckBox(self, -1, "Original Points")
        self.d1.SetValue(0)
        sizer3.Add(self.d1, 0, wx.GROW | wx.ALL, 2)

        self.d2 = wx.CheckBox(self, -1, "Function")
        self.d2.SetValue(0)
        sizer3.Add(self.d2, 0, wx.GROW | wx.ALL, 2)

        self.d3 = wx.CheckBox(self, -1, "Polynomial")
        self.d3.SetValue(0)
        sizer3.Add(self.d3, 0, wx.GROW | wx.ALL, 2)

        self.d4 = wx.CheckBox(self, -1, "Smoothed Curve")
        self.d4.SetValue(0)
        sizer3.Add(self.d4, 0, wx.GROW | wx.ALL, 2)

        self.d5 = wx.CheckBox(self, -1, "Trend Curve")
        self.d5.SetValue(0)
        sizer3.Add(self.d5, 0, wx.GROW | wx.ALL, 2)

        # -----
        box = wx.StaticBox(self, -1, "Annual Cycle")
        sizer4 = wx.StaticBoxSizer(box, wx.VERTICAL)
        sizer1.Add(sizer4, 0, wx.EXPAND | wx.ALL, 5)

        self.d6 = wx.CheckBox(self, -1, "Detrended Data")
        self.d6.SetValue(0)
        sizer4.Add(self.d6, 0, wx.GROW | wx.ALL, 2)

        self.d7 = wx.CheckBox(self, -1, "Smoothed Seasonal Cycle")
        self.d7.SetValue(0)
        sizer4.Add(self.d7, 0, wx.GROW | wx.ALL, 2)

        self.d8 = wx.CheckBox(self, -1, "Seasonal Cycle Harmonics")
        self.d8.SetValue(0)
        sizer4.Add(self.d8, 0, wx.GROW | wx.ALL, 2)

        # -----
        box = wx.StaticBox(self, -1, "Residuals and Growth Rate")
        sizer5 = wx.StaticBoxSizer(box, wx.VERTICAL)
        sizer1.Add(sizer5, 0, wx.EXPAND | wx.ALL, 5)

        self.d9 = wx.CheckBox(self, -1, "Residuals from Function")
        self.d9.SetValue(0)
        sizer5.Add(self.d9, 0, wx.GROW | wx.ALL, 2)

        self.d10 = wx.CheckBox(self, -1, "Smoothed Residuals")
        self.d10.SetValue(0)
        sizer5.Add(self.d10, 0, wx.GROW | wx.ALL, 2)

        self.d11 = wx.CheckBox(self, -1, "Trend of Residuals")
        self.d11.SetValue(0)
        sizer5.Add(self.d11, 0, wx.GROW | wx.ALL, 2)

        self.d12 = wx.CheckBox(self, -1, "Residuals from Smoothed Curve")
        self.d12.SetValue(0)
        sizer5.Add(self.d12, 0, wx.GROW | wx.ALL, 2)

        self.d13 = wx.CheckBox(self, -1, "Growth Rate")
        self.d13.SetValue(0)
        sizer5.Add(self.d13, 0, wx.GROW | wx.ALL, 2)

        # -----
        box = wx.StaticBox(self, -1, "Choose Output Options")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(sizer2, 0, wx.EXPAND | wx.ALL, 5)

        # -----
        # horizontal box
        sampleList = ['Export Data to Grapher', 'Export Data to File']
        self.filerb = wx.RadioBox(self, -1, "", wx.DefaultPosition, wx.DefaultSize, sampleList, 1,
                                  wx.RA_SPECIFY_COLS | wx.NO_BORDER)
        sizer2.Add(self.filerb, 0, wx.EXPAND | wx.ALL, 2)
        self.Bind(wx.EVT_RADIOBOX, self._destination, self.filerb)

        # options if exporting to file
        self.filebox = wx.StaticBox(self, -1, "File Options")
        sizer1 = wx.StaticBoxSizer(self.filebox, wx.VERTICAL)
        sizer2.Add(sizer1, 0, wx.EXPAND | wx.LEFT, 30)
        self.filebox.Enable(False)

        self.colname = wx.CheckBox(self, -1, "Include Column Name Header in file")
        self.colname.SetValue(0)
        self.colname.Enable(False)
        sizer1.Add(self.colname, 0, wx.GROW | wx.LEFT, 5)

        self.datetype = "orig"
        sampleList = ['Dates Corresponding to Original Data', 'Dates at Equally Spaced Intervals']
        self.datesrb = wx.RadioBox(self, -1, "", wx.DefaultPosition, wx.DefaultSize, sampleList, 1,
                                   wx.RA_SPECIFY_COLS | wx.NO_BORDER)
        sizer1.Add(self.datesrb, 0, wx.ALIGN_LEFT | wx.EXPAND | wx.ALL, 2)
        self.Bind(wx.EVT_RADIOBOX, self._dates, self.datesrb)
        self.datesrb.Enable(False)

        self.startbox = wx.StaticBox(self, -1, "Starting Date")
        sizer2a = wx.StaticBoxSizer(self.startbox, wx.HORIZONTAL)
        sizer1.Add(sizer2a, 0, wx.ALIGN_LEFT | wx.LEFT, 35)
        self.startbox.Enable(False)

        self.yearlabel = wx.StaticText(self, -1, "Year:")
        sizer2a.Add(self.yearlabel, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.year = wx.TextCtrl(self, -1, "", size=(50, -1))
        sizer2a.Add(self.year, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.yearlabel.Enable(False)
        #        self.year.SetValue(str(self.ccgvu.startyear))
        self.year.Enable(False)

        self.monthlabel = wx.StaticText(self, -1, "Month:")
        sizer2a.Add(self.monthlabel, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.month = wx.TextCtrl(self, -1, "", size=(50, -1))
        sizer2a.Add(self.month, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.monthlabel.Enable(False)
        #        self.month.SetValue(str(self.ccgvu.startmon))
        self.month.Enable(False)

        self.daylabel = wx.StaticText(self, -1, "Day:")
        sizer2a.Add(self.daylabel, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.day = wx.TextCtrl(self, -1, "", size=(50, -1))
        sizer2a.Add(self.day, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        #        self.day.SetValue(str(self.ccgvu.startday))
        self.daylabel.Enable(False)
        self.day.Enable(False)

#        self.set_start_date(self.ccgvu.startyear, self.ccgvu.startmon, self.ccgvu.startday)
        self.set_start_date(filtdata.start_date)

        self.dateformat = "decimal"
        sampleList = ['Dates in Decimal Year Format', 'Dates in Calendar Format']
        self.dateformatrb = wx.RadioBox(self, -1, "", wx.DefaultPosition, wx.DefaultSize, sampleList, 1,
                                        wx.RA_SPECIFY_COLS | wx.BORDER_NONE)
        sizer1.Add(self.dateformatrb, 0, wx.EXPAND | wx.ALIGN_LEFT | wx.ALL, 5)
        self.Bind(wx.EVT_RADIOBOX, self._getdateformat, self.dateformatrb)
        self.dateformatrb.Enable(False)

        self.dh = wx.CheckBox(self, -1, "Include Hour in Exported Date")
        self.dh.SetValue(0)
        self.dh.Enable(False)
        sizer1.Add(self.dh, 0, wx.GROW | wx.ALIGN_LEFT | wx.LEFT, 35)

        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer1.Add(box2, wx.ALIGN_CENTER_VERTICAL | wx.ALL, 0)

        self.filelabel = wx.StaticText(self, -1, "Filename:")
        box2.Add(self.filelabel, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 5)
        self.file = wx.TextCtrl(self, -1, "", size=(400, -1))
        box2.Add(self.file, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.filebtn = wx.Button(self, 1, "Browse...")
        self.Bind(wx.EVT_BUTTON, self._browse, self.filebtn)
        box2.Add(self.filebtn, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.filelabel.Enable(False)
        self.file.Enable(False)
        self.filebtn.Enable(False)

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # ------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self._ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_APPLY)
        self.Bind(wx.EVT_BUTTON, self._apply, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    # ---------------------------------------------------------------
    def set_start_date(self, date):
        """ update the start date """

        self.year.SetValue(str(date.year))
        self.month.SetValue(str(date.month))
        self.day.SetValue(str(date.day))

    # ---------------------------------------------------------------
    def _apply(self, event):
        """ apply or ok button clicked.  Do the export """

        d = [0 for i in range(0, 14)]
        d[1] = self.d1.GetValue()
        d[2] = self.d2.GetValue()
        d[3] = self.d3.GetValue()
        d[4] = self.d4.GetValue()
        d[5] = self.d5.GetValue()
        d[6] = self.d6.GetValue()
        d[7] = self.d7.GetValue()
        d[8] = self.d8.GetValue()
        d[9] = self.d9.GetValue()
        d[10] = self.d10.GetValue()
        d[11] = self.d11.GetValue()
        d[12] = self.d12.GetValue()
        d[13] = self.d13.GetValue()
        c = d.count(True)
        if not c:
            dlg = wx.MessageDialog(self, "No Data Sets selected.  Please choose a Data Set to export.", 'Error',
                                   wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        # Check if output goes to grapher or file.
        val = self.filerb.GetSelection()
        if val == 1:
            outputfile = self.file.GetValue()
            if not outputfile:
                dlg = wx.MessageDialog(self, "Please enter a file name.", 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

            self._export_to_file(outputfile, d)

        else:
            self._export_to_grapher(d)

    # ---------------------------------------------------------------
    def _export_to_grapher(self, d):
        """ export filter results to a wx grapher window """

        if not self.plot:
            grapher = self.ccgvu.parent.grapher(None)  # create a new grapher window
            self.plot = grapher.current_plot  # get the graph in the window

        if d[1]:
            x = self.ccgvu.x
            y = self.ccgvu.y
            name = "Data"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="square", color="black", fillsymbol=False)
        if d[2]:
            x = self.filt.xinterp
            y = self.filt.getFunctionValue(x)
            name = "Function"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="magenta", linewidth=2)
        if d[3]:
            x = self.filt.xinterp
            y = self.filt.getPolyValue(x)
            name = "Polynomial"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="cyan", linewidth=2)
        if d[4]:
            x = self.filt.xinterp
            y = self.filt.getSmoothValue(x)
            name = "Smoothed"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="red", linewidth=2)
        if d[5]:
            x = self.filt.xinterp
            y = self.filt.getTrendValue(x)
            name = "Trend"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="blue", linewidth=2)
        if d[6]:
            x = self.ccgvu.x
            y = self.ccgvu.y - self.filt.getTrendValue(x)
            name = "Detrended Data"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="square", color="black", fillsymbol=False)
        if d[7]:
            x = self.filt.xinterp
            y = self.filt.getHarmonicValue(x) + self.filt.smooth - self.filt.trend
            name = "Smoothed Cycle"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="red", linewidth=2)
        if d[8]:
            x = self.filt.xinterp
            y = self.filt.getHarmonicValue(x)
            name = "Harmonics"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="blue", linewidth=2)
        if d[9]:
            x = self.ccgvu.x
            y = self.filt.resid
            name = "Residuals"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="square", color="black", fillsymbol=False)
        if d[10]:
            x = self.filt.xinterp
            y = self.filt.smooth
            name = "Smoothed Residuals"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="red", linewidth=2)
        if d[11]:
            x = self.filt.xinterp
            y = self.filt.trend
            name = "Trend of Residuals"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="blue", linewidth=2)
        if d[12]:
            x = self.ccgvu.x
            y = self.filt.yp - self.filt.getSmoothValue(x)
            name = "Residuals from Smoothed"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="plus", color="black", fillsymbol=False)
        if d[13]:
            x = self.filt.xinterp
            y = self.filt.deriv
            name = "Growth Rate"
            x = dd2dt(x)
            self.plot.createDataset(x, y, name, symbol="None", linecolor="red", linewidth=2)

        self.plot.update()

    # ---------------------------------------------------------------
    def _export_to_file(self, outputfile, d):
        """ export results to a file

        Use the ccg_filter_export module for doing the actual exporting
        """

        export = ccg_filter_export.ccgFilterExportData()

        if d[1]: export.orig = True
        if d[2]: export.func = True
        if d[3]: export.poly = True
        if d[4]: export.smooth = True
        if d[5]: export.trend = True
        if d[6]: export.detrend = True
        if d[7]: export.smcycle = True
        if d[8]: export.harm = True
        if d[9]: export.res = True
        if d[10]: export.smres = True
        if d[11]: export.trres = True
        if d[12]: export.ressm = True
        if d[13]: export.gr = True

        if self.datetype == "orig":
            export.sample = True
            export.outfile1 = outputfile
        elif self.datetype == "equal":
            yr = int(self.year.GetValue())
            mo = int(self.month.GetValue())
            dy = int(self.day.GetValue())
            export.startdate = datetime.datetime(yr, mo, dy)
            export.equal = True
            export.outfile2 = outputfile
        if self.dateformat == "cal":
            export.cal_format = True
        if self.dh.GetValue():
            export.include_hour = True

        if self.colname.GetValue():
            export.include_header = True

        export.run(self.filt)

    # ---------------------------------------------------------------
    def _ok(self, event):
        """ ok button clicked, do the export and close dialog """

        self._apply(event)
        #        self.EndModal(wx.ID_OK)
        self.Close()

    # ---------------------------------------------------------------
    def _browse(self, event):
        """ create file dialog for browsing file system """

        dlg = wx.FileDialog(self,
                            message="Choose a file",
                            defaultDir=os.getcwd(),
                            defaultFile="",
                            style=wx.FD_OPEN | wx.FD_CHANGE_DIR)
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
            for path in paths:
                self.file.SetValue(path)

        dlg.Destroy()

    # ---------------------------------------------------------------
    def _getdateformat(self, event):
        """ Get the format of the dates for exported data """

        val = event.GetInt()
        self._updateFormat(val)

    # ---------------------------------------------------------------
    def _updateFormat(self, val):
        """ set state of widgets based on date format """

        if val == 1:
            self.dh.Enable(True)
            self.dateformat = "cal"
        else:
            self.dh.Enable(False)
            self.dateformat = "decimal"

    # ---------------------------------------------------------------
    def _dates(self, event):
        """ get type of dates to use, sample dates or equally spaced intervals """

        val = event.GetInt()
        self._updateDates(val)

    # ---------------------------------------------------------------
    def _updateDates(self, val):
        """ update state of widgets based on output dates """

        if val == 1:  # equally spaced intervals
            self.year.Enable(True)
            self.month.Enable(True)
            self.day.Enable(True)
            self.yearlabel.Enable(True)
            self.monthlabel.Enable(True)
            self.daylabel.Enable(True)
            self.startbox.Enable(True)
            self.datetype = "equal"
            self.d1.Enable(False)
            self.d6.Enable(False)
            self.d9.Enable(False)
            self.d12.Enable(False)
        else:  # sample spaced intervals
            self.year.Enable(False)
            self.month.Enable(False)
            self.day.Enable(False)
            self.yearlabel.Enable(False)
            self.monthlabel.Enable(False)
            self.daylabel.Enable(False)
            self.startbox.Enable(False)
            self.datetype = "orig"
            self.d1.Enable(True)
            self.d6.Enable(True)
            self.d9.Enable(True)
            self.d12.Enable(True)

    # ---------------------------------------------------------------
    def _destination(self, event):
        """ update state of widgets based on output destination """

        val = event.GetInt()
        if val == 1:
            self.filebox.Enable(True)
            self.file.Enable(True)
            self.filelabel.Enable(True)
            self.filebtn.Enable(True)
            self.dateformatrb.Enable(True)
            self.datesrb.Enable(True)
            self.colname.Enable(True)
            n = self.datesrb.GetSelection()
            self._updateDates(n)
            n = self.dateformatrb.GetSelection()
            self._updateFormat(n)
        else:
            self.filebox.Enable(False)
            self.file.Enable(False)
            self.filelabel.Enable(False)
            self.filebtn.Enable(False)
            self.dateformatrb.Enable(False)
            self.datesrb.Enable(False)
            self.colname.Enable(False)
            n = 2
            self._updateDates(n)
            self._updateFormat(0)
