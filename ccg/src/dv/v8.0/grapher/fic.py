# vim: tabstop=4 shiftwidth=4 expandtab

"""
Dialog class for choosing data set to graph.
Dialog contains several sections:
        station list
        parameter
        time span
        options

Used by grapher module
Create with

        from common import get

        dlg = get.GetInsituDataDialog(self)

        where self is the parent of the dialog.

Then get data arrays with

        x,y,name = dlg.ProcessData()
"""

import datetime
import wx

import ccg_dbutils

import ccg_fic
import ccg_tankhistory

from common import combolist


#####################################################################
class FICData:
    """ class for holding settings and getting flask-insitu comparision data """

    def __init__(self):
        self.sitenum = 75
        self.stacode = "MLO"
        self.parameter = 1
        self.paramname = "co2"
        self.byear = 0
        self.eyear = 0
        self.diff_symbols = 0
        self.use_flagged_flask = 0
        self.use_flagged_insitu = 0
        self.use_hour_data = 0
        self.inst = ""
        self.db = ccg_dbutils.dbUtils()

    # ----------------------------------------------
    def SetBegYear(self, yr):

        self.byear = int(yr)

    # ----------------------------------------------
    def SetEndYear(self, yr):

        self.eyear = int(yr)

    # ----------------------------------------------
    def SetParameter(self, formula):

        paramnum = self.db.getGasNum(formula)
        self.parameter = paramnum
        self.paramname = formula

    # ----------------------------------------------
    def SetStation(self, code):

        self.stacode = code
        self.sitenum = self.db.getSiteNum(self.stacode)

    # ----------------------------------
    def IncludeWorkLines(self, graph):
        """ Include a vertical line wherever a working tank changes. """

        if self.includework:
            hist = ccg_tankhistory.tankhistory(self.paramname, location=self.stacode)  # , system=self.system)

            for t in hist.data:
                dt = t.start_date
                if dt.year >= self.byear and dt.year <= self.eyear and "TGT" not in t.label:
                    graph.AddVerticalLine(dt)

    # ----------------------------------
    def processData(self):
        """ get flask-insitu data from database

        return a dict of x, y values with the dataset name
        as the key
        """

        d = {}
        fic = ccg_fic.fic(self.stacode, self.byear, self.eyear, [self.paramname], use_hourly_data=self.use_hour_data)
        if self.diff_symbols:
            for method in fic.methods:
                x, y = fic.get_differences(self.paramname, method=method,
                                           use_flagged_flask=self.use_flagged_flask,
                                           use_flagged_insitu=self.use_flagged_insitu)
                name = "%s %s %s" % (self.stacode, self.paramname, method)
                d[name] = (x, y)
        else:
            x, y = fic.get_differences(self.paramname,
                                       use_flagged_flask=self.use_flagged_flask,
                                       use_flagged_insitu=self.use_flagged_insitu)
            name = "%s %s" % (self.stacode, self.paramname)
            d[name] = (x, y)

        return d


##########################################################################
class FICDialog(wx.Dialog):
    def __init__(self, parent=None, title="Flask In-Situ Comparison"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

        self.data = FICData()
        self.db = ccg_dbutils.dbUtils()

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkStation()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkParams()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkTimeSpan()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkOptions()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)
        self.options_sizer = sizer

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        self.stationSelected(None)

    # ----------------------------------
    def mkStation(self):

        box = wx.StaticBox(self, -1, "Sampling Site")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#        self.listbox = extchoice.ExtendedChoice(self, -1, size=(355,-1))
        self.listbox = combolist.ComboList(self, -1, size=(355, -1))
#        self.listbox = wx.ComboBox(self, -1, size=(355, -1), style=wx.CB_READONLY)

        sql = "SELECT DISTINCT site_num, parameter_num from insitu_data order by site_num, parameter_num"
        result = self.db.doquery(sql)

        self.params = {}
        value = ""
        stations = []
        for row in result:
            code = self.db.getSiteCode(row['site_num'])
            gas = self.db.getGasFormula(row['parameter_num'])
            name = self.db.getSiteName(code)

            # skip site without flasks (SNP)
            sql = "select count(*) as count from flask_event where site_num=%d" % row['site_num']
            r = self.db.doquery(sql)
            if r[0]['count'] == 0: continue

            txt = "%s - %s" % (code.upper(), name)
            if txt not in stations:
                stations.append(txt)
            if code.upper() == self.data.stacode:
                value = txt

            if code.lower() not in self.params:
                self.params[code.lower()] = []
            self.params[code.lower()].append(gas)

        if value == "": value = stations[0]
        self.listbox.InsertItems(stations)

        self.listbox.SetValue(value)

        szr.Add(self.listbox, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)

        print(self.params)

        return szr

    # ----------------------------------
    def mkParams(self):
        """ Make list of available parameter names """

        box = wx.StaticBox(self, -1, "Parameters")
        box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

        text = "Select a measurement parameter."
        self.label = wx.StaticText(self, -1, text)
        box1.Add(self.label, 0, wx.ALIGN_LEFT | wx.ALL, 5)

        self.parambox = wx.ListBox(self, -1, style=wx.LB_SINGLE, size=(350, 150))
        box1.Add(self.parambox, 1, wx.ALIGN_RIGHT | wx.ALL, 5)
        self.parambox.Bind(wx.EVT_LISTBOX, self.paramSelected)

        self.param_config()

        return box1

    # ----------------------------------
    def mkTimeSpan(self):

        now = datetime.datetime.now()
        this_year = int(now.strftime("%Y"))

        box = wx.StaticBox(self, -1, "Time Span")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        szr.Add(box1)

        label = wx.StaticText(self, -1, "Begin Year")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.byear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
        box1.Add(self.byear, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        label = wx.StaticText(self, -1, "End Year")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.eyear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
        box1.Add(self.eyear, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        self.setDates()

        return szr

    # ------------------------------------------------------------------------
    def mkOptions(self):

        box = wx.StaticBox(self, -1, "Data Options")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        panel = self.options()
        szr.Add(panel)

        return szr

    # ------------------------------------------------------------------------
    def options(self):

        panel = wx.Panel(self, -1)
        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        self.usehour = wx.CheckBox(panel, -1, "Compare flasks with in-situ hourly averages")
        self.usehour.SetValue(self.data.use_hour_data)
        vs.Add(self.usehour, 0, wx.GROW | wx.ALL, 2)

        self.a1 = wx.CheckBox(panel, -1, "Use Different Symbols for each Flask Method")
        self.a1.SetValue(self.data.diff_symbols)
        vs.Add(self.a1, 0, wx.GROW | wx.ALL, 2)

        self.f1 = wx.CheckBox(panel, -1, "Include Variable InSitu Data")
        self.f1.SetValue(self.data.use_flagged_insitu)
        vs.Add(self.f1, 0, wx.GROW | wx.ALL, 2)

        self.f2 = wx.CheckBox(panel, -1, "Include Flagged Flask Data")
        self.f2.SetValue(self.data.use_flagged_flask)
        vs.Add(self.f2, 0, wx.GROW | wx.ALL, 2)

        self.includework = wx.CheckBox(panel, -1, "Include vertical lines at reference tank changes")
        self.includework.SetValue(0)
        vs.Add(self.includework, 0, wx.GROW | wx.ALL, 2)

        # instrument
        rbList = []
        if self.data.stacode == "BRW":
            if self.data.paramname == "co2":
                rbList = ["NDIR", "LGR"]

        if len(rbList) > 0:
            txt = wx.StaticText(panel, -1, "Instrument")
            vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

            self.inst = wx.RadioBox(
                panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
                rbList, 1, wx.RA_SPECIFY_COLS  # | wx.NO_BORDER
                )
            vs.Add(self.inst, 0, wx.LEFT, 20)

        return panel

    # ----------------------------------
    # callbacks
    # ----------------------------------

    # ----------------------------------
    def stationSelected(self, event):
        """ station selection has changed.
            update parameters, time span and options
            with values relavent to selected station.
        """

        # get the newly selected station code
        self.data.SetStation(self.getStationCode())

        # update the parameters, time and options sections
        self.param_config()
        self.date_config()
        self.option_config()

    # ----------------------------------
    def paramSelected(self, event):
        """ parameter selection has changed.
            update parameters, time span and options
            with values relavent to selected station and parameter
        """

        s = self.parambox.GetStringSelection()
        if s:
            self.data.SetParameter(self.getParameter())

            self.date_config()
            self.option_config()

    # ----------------------------------
    # helper functions
    # ----------------------------------


    # ----------------------------------
    def param_config(self):

        code = self.data.stacode
        params = self.params[code.lower()]

        self.parambox.Clear()
        for formula in params:
            name = self.db.getGasName(formula)
            s = "%s - %s" % (formula, name)
            self.parambox.Append(s)

        self.parambox.SetSelection(0)
        self.data.SetParameter(params[0])

        return

    # ----------------------------------
    def date_config(self):

        (mindate, maxdate) = self.getDates(self.data.stacode, self.data.paramname)
#        print mindate, maxdate

        self.setDates()

        self.byear.SetRange(mindate.year, maxdate.year)
        self.eyear.SetRange(mindate.year, maxdate.year)
        self.byear.SetValue(mindate.year)
        self.eyear.SetValue(maxdate.year)

    # ----------------------------------
    def option_config(self):

        # remove existing options
        self.options_sizer.Clear(True)

        # create new options
        panel = self.options()

        self.options_sizer.Add(panel)
        self.options_sizer.Layout()

        # resize the dialog
        win = self
        while win is not None:
            win.InvalidateBestSize()
            win = win.GetParent()
        wx.CallAfter(wx.GetTopLevelParent(self).Fit)

    # ----------------------------------
    def getStationCode(self):
        s = self.listbox.GetValue()
        code, name = s.split('-', 1)
        code = code.strip()

        return code

    # ----------------------------------
    def getParameter(self):
        """ Get the formula for the selected parameter """

        s = self.parambox.GetStringSelection()
        (formula, name) = s.split('-', 1)
        formula = formula.strip()

        return formula

    # ----------------------------------
    def getDates(self, code, param):
        """ get the min and max dates of available data """

        sitenum = self.db.getSiteNum(code)

#        table = "%s_%s_insitu" % (code.lower(), param.lower())
        query = "select min(date) as mindate, max(date) as maxdate from insitu_data "
        query += "where site_num=%d and parameter_num=1" % sitenum
        print(query)

        dlist = self.db.doquery(query)
        row = dlist[0]

        return row['mindate'], row['maxdate']

    # ----------------------------------
    def setDates(self):
        """ set the data begin year, end year, beg month, end month """

        self.data.SetBegYear(self.byear.GetValue())
        self.data.SetEndYear(self.eyear.GetValue())

    # ----------------------------------
    def ok(self, event):
        """
        Get all the values from the dialog and store them in self.data
            stacode
            parameter
            begyear
            endyear
            options:
                skip_first
                analyzer
        """

        self.setDates()
        self.data.SetStation(self.getStationCode())
        self.data.SetParameter(self.getParameter())
        self.data.diff_symbols = self.a1.GetValue()
        self.data.use_flagged_insitu = self.f1.GetValue()
        self.data.use_flagged_flask = self.f2.GetValue()
        self.data.use_hour_data = self.usehour.GetValue()
        self.data.includework = self.includework.GetValue()

        try:
            self.data.inst = self.inst.GetStringSelection()
        except:
            self.data.inst = None

        self.EndModal(wx.ID_OK)
