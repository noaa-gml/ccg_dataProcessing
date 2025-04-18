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
from collections import defaultdict
import numpy
import wx

from common.utils import get_path

import ccg_dbutils

import ccg_dates
import ccg_response_file
import ccg_tankhistory
import ccg_refgasdb
import ccg_insitu_data2


#####################################################################
class TargetData:
    """ class for holding settings and getting insitu target cal data from database """

    def __init__(self):
        self.sitenum = 75   # not used
        self.stacode = "MLO"
        self.parameter = 1   # not used
        self.paramname = "co2"
        self.byear = 0
        self.eyear = 0
        self.includework = 0
        self.includeresp = 0
        self.includevalue = 0
        self.skipfirst = 0
        self.inst = ""
        self.dtype = 0  # 0 for values, 1 for difference from assigned value
#        self.db = ccg_dbutils.dbUtils()

    # ----------------------------------------------
    def SetBegYear(self, yr):
        """ Set beginning year of data """

        self.byear = int(yr)

    # ----------------------------------------------
    def SetEndYear(self, yr):
        """ Set ending year of data """

        self.eyear = int(yr)

    # ----------------------------------------------
    def SetParameter(self, formula):
        """ Set the gas to use """

        self.paramname = formula

    # ----------------------------------------------
    def SetStation(self, code):
        """ Set the station to use """

        self.stacode = code

    # ----------------------------------
    def ProcessData(self):
        """ get the target data from database """

        pyear = 0
        pmonth = 0
        pday = 0
        phour = 0
        x = defaultdict(list)
        y = defaultdict(list)
        title = defaultdict(list)

        # get difference from assigned value
        if self.dtype == 1:
            hist = ccg_tankhistory.tankhistory(self.paramname, location=self.stacode)  # , system=self.system)
            tgts = [row for row in hist.data if "TGT" in row.label]
            # remove brw lgr tgt tanks for co2 before 2017 (use ndir tgts only)
            if self.paramname.lower() == "co2":
                tgts = [row for row in tgts if
                        (row.end_date.year < 2017 and row.site == "BRW" and row.system == 'lgr') is not True]
            snlist = [t.serial_number for t in tgts]
            ref = ccg_refgasdb.refgas(self.paramname, snlist)

        f = ccg_insitu_data2.InsituData(self.paramname, self.stacode, use_target=True)
        t1 = datetime.datetime(self.byear, 1, 1)
        t2 = datetime.datetime(self.eyear+1, 1, 1)
        f.setRange(t1, t2)
        result = f.run()

        for row in result:

            yp = row['value']
            tgtname = row['inlet']
            xp = row['date']

            if self.dtype == 1:
                diff = self._get_diff(tgts, xp, row, ref)
                if diff is None:
                    continue
                yp = diff

            if self.skipfirst:
                if pyear == xp.year and pmonth == xp.month and pday == xp.day and phour == xp.hour:
                    x[tgtname].append(xp)
                    y[tgtname].append(yp)
            else:
                x[tgtname].append(xp)
                y[tgtname].append(yp)

            pyear = xp.year
            pmonth = xp.month
            pday = xp.day
            phour = xp.hour

        for name in x:
#        if self.paramname.upper() == "CO2" and self.stacode == "BRW":
#            title = "%s %s %s Target" % (self.stacode, self.inst, self.paramname)
#        else:
            title[name] = "%s %s %s" % (self.stacode, self.paramname, name)

        return x, y, title

    # ----------------------------------
    def _get_diff(self, tgts, date, row, ref):
        """ find the assigned value for the target tank on date,
        and compute the difference mf-assigned
        """

        sn = None
        # find last target tank with start date before given date
        for t in tgts:
            if (t.system == 'lgr'
                    and t.site == 'BRW'
                    and self.paramname == "co2"
                    and date.year < 2017):
                continue
            if date >= t.start_date and row['inlet'] == t.label:
                sn = t.serial_number

        tank = ref.getAssignment(sn, date)
        if tank:
            xd = ccg_dates.decimalDateFromDatetime(date)
            xd = xd - tank.tzero
            y = tank.coef0 + tank.coef1 * xd + tank.coef2 * xd * xd
            diff = row['value'] - y
            return diff

        return None

    # ----------------------------------
    def IncludeTankValue(self, graph):
        """ Include a line with the target tank assigned value. """

        if self.includevalue:
            hist = ccg_tankhistory.tankhistory(self.paramname, location=self.stacode)

            # need to handle overlapping systems.  Don't use lgr before 2017 for co2
            tgts = []
            for t in hist.data:
                if (self.stacode == "BRW"
                        and self.paramname.lower() == "co2"
                        and t.end_date.year < 2017
                        and t.system == "lgr"):
                    continue
                if "TGT" in t.label:
                    tgts.append(t)

            for i, t in enumerate(tgts):
                dt = t.start_date
                dt2 = t.end_date

                if ((dt.year < self.byear and dt2.year >= self.byear)
                        or (dt.year >= self.byear and dt.year <= self.eyear)):
                    ref = ccg_refgasdb.refgas(self.paramname, [t.serial_number])
                    row = ref.getAssignment(t.serial_number, t.start_date)
                    if row:
                        xp, yp = self._get_target_dates(t.start_date, t.end_date, row)
                        graph.createDataset(xp, yp, t.serial_number, symbol='None', linewidth=3)

    # ----------------------------------
    def _get_target_dates(self, start, end, tank):
        """ create a list of dates and values for the target tank
        assigned value from start to end dates.
        """

        if self.byear > start.year:
            xd0 = self.byear
        else:
            xd0 = ccg_dates.decimalDateFromDatetime(start)

        if self.eyear < end.year:
            xd1 = self.eyear
        else:
            xd1 = ccg_dates.decimalDateFromDatetime(end)

        dates = []
        vals = []
        for d in numpy.linspace(xd0, xd1, 100):
            xd = d - tank.tzero
            y = tank.coef0 + tank.coef1 * xd + tank.coef2 * xd * xd
            dates.append(ccg_dates.datetimeFromDecimalDate(d))
            vals.append(y)

        return dates, vals

    # ----------------------------------
    def IncludeWorkLines(self, graph):
        """ Include a vertical line wherever a working tank changes. """

        if self.includework:
            hist = ccg_tankhistory.tankhistory(self.paramname, location=self.stacode)  # , system=self.system)
#        tanklist1 = hist.filterByDate(self.startdate)
#            for row in hist.data:
#                print(row)

            for t in hist.data:
                dt = t.start_date
                if (self.stacode == "BRW"
                        and self.paramname.lower() == "co2"
                        and dt.year < 2017
                        and t.system == "lgr"):
                    continue
                if dt.year >= self.byear and dt.year <= self.eyear and "TGT" not in t.label:
                    graph.AddVerticalLine(dt)

    # ----------------------------------
    def IncludeRespLines(self, graph):
        """ Include a vertical line wherever a response curve changes. """

        print("-------------------")

#        print(self.includeresp, self.inst, self.stacode)
        if self.includeresp:

#            if self.inst == "LGR" and self.stacode == "BRW":
            if self.stacode == "BRW":
                responsefile = "/ccg/%s/in-situ/%s_data/lgr/ResponseCurves.%s" % (self.paramname.lower(), self.stacode.lower(), self.paramname.lower())
            elif self.stacode == "MLO":
                responsefile = "/ccg/%s/in-situ/%s_data/pic/ResponseCurves.%s" % (self.paramname.lower(), self.stacode.lower(), self.paramname.lower())
            else:
                return
            responsefile = get_path(responsefile)
            print(responsefile)

            resp = ccg_response_file.ResponseFile(responsefile)
            for t in resp.data:
                dt = t.date
                if self.stacode == "BRW" and dt.year < 2017 and "LGR" in t.analyzer_id:
                    continue
                if dt.year >= self.byear and dt.year <= self.eyear:
                    graph.AddVerticalLine(dt)


##########################################################################
class TargetDialog(wx.Dialog):
    """ A dialog for choosing insitu target data """

    def __init__(self, parent=None, title="Choose Dataset"):
        wx.Dialog.__init__(self, parent, -1, title)

        self.data = TargetData()
        db = ccg_dbutils.dbUtils()

        # get some data for the targets
        self.params = {}
        self.paramnames = {}
        self.dates = {}
        value = ""
        stations = []

        # use getParameterList() for this?
        self.params = {'BRW': ['CO2', 'CH4', 'CO', 'N2O'],
                       'MLO': ['CO2', 'CH4', 'CO'],
                       'SMO': ['CO2'],
                       'SPO': ['CO2'],
                       'CAO': ['CO2', 'CH4', 'CO', 'N2O'],
                       'WGC': ['CO2', 'CH4', 'CO']}

        maxdate = datetime.datetime.now().year

        for code, params in self.params.items():
            self.paramnames[code] = []
            for param in params:
                name = db.getGasName(param)
                self.paramnames[code].append(name)

                mindate = self.getDates(db, code, param)
                self.dates[(code, param)] = (mindate, maxdate)

                name = db.getSiteName(code)

                txt = "%s - %s" % (code.upper(), name)
                if txt not in stations:
                    stations.append(txt)
                    if code.upper() == self.data.stacode:
                        value = txt

        # ------------------------------------------
        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkStation(stations, value)
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkParams()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkTimeSpan()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkDataType()
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
    def mkStation(self, stations, selected_sta):
        """ create the station choice box """

        box = wx.StaticBox(self, -1, "Sampling Site")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.listbox = wx.ComboBox(self, -1, size=(555, -1), style=wx.CB_READONLY)

        if selected_sta == "":
            selected_sta = stations[0]

#        self.listbox.ReplaceAll(stations)
#        self.listbox.InsertItems(stations)
        self.listbox.Set(stations)
        self.listbox.SetValue(selected_sta)

        szr.Add(self.listbox, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)
#        self.listbox.Bind(wx.EVT_COMBOBOX_CLOSEUP, self.stationSelected)

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
        """ make widget for setting years of data to use """

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
    def mkDataType(self):
        """ additional optons """

        box = wx.StaticBox(self, -1, "Data Type")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        rlist = ['Plot measured target values', 'Plot difference from assigned value']
        self.dtype = wx.RadioBox(
            self, -1, "", wx.DefaultPosition, wx.DefaultSize,
            rlist, 1, wx.RA_SPECIFY_COLS  # | wx.NO_BORDER
            )
        szr.Add(self.dtype, 0, wx.ALL, 10)

        return szr

    # ------------------------------------------------------------------------
    def mkOptions(self):
        """ additional optons """

        box = wx.StaticBox(self, -1, "Data Options")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        panel = self.options()
        szr.Add(panel)

        return szr

    # ------------------------------------------------------------------------
    def options(self):
        """ make the panel with the options """

        panel = wx.Panel(self, -1)
        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        self.skip = wx.CheckBox(panel, -1, "Don't Use First Cycle")
        self.skip.SetValue(0)
        vs.Add(self.skip, 0, wx.GROW | wx.ALL, 2)

        self.includework = wx.CheckBox(panel, -1, "Include vertical lines at reference tank changes")
        self.includework.SetValue(0)
        vs.Add(self.includework, 0, wx.GROW | wx.ALL, 2)

        self.includeresp = wx.CheckBox(panel, -1, "Include vertical lines at response curve changes")
        self.includeresp.SetValue(0)
        vs.Add(self.includeresp, 0, wx.GROW | wx.ALL, 2)

        self.includevalue = wx.CheckBox(panel, -1, "Include line for assigned value of Target tank")
        self.includevalue.SetValue(0)
        vs.Add(self.includevalue, 0, wx.GROW | wx.ALL, 2)

        # instrument
#        rbList = []
#        if self.data.stacode == "BRW":
#            if self.data.paramname == "co2":
#                rbList = ["NDIR", "LGR"]

#        if len(rbList) > 0:
#            txt = wx.StaticText(panel, -1, "Instrument")
#            vs.Add(txt, 0, wx.LEFT|wx.TOP, 10)

#            self.inst = wx.RadioBox(
#                panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
#                rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
#                )
#            vs.Add(self.inst, 0, wx.LEFT, 20)

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
        """ configure parameters for chosen site """

        code = self.data.stacode
        params = self.params[code]
        names = self.paramnames[code]

        self.parambox.Clear()
        for formula, name in zip(params, names):
            s = "%s - %s" % (formula, name)
            self.parambox.Append(s)

        self.parambox.SetSelection(0)
        self.data.SetParameter(params[0])

    # ----------------------------------
    def date_config(self):
        """ configure min and max dates for chosen site and parameter """

        (mindate, maxdate) = self.dates[(self.data.stacode, self.data.paramname)]
#        print mindate, maxdate

        self.setDates()

        self.byear.SetRange(mindate, maxdate)
        self.eyear.SetRange(mindate, maxdate)
        self.byear.SetValue(mindate)

    # ----------------------------------
    def option_config(self):
        """ configure options """

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
        """ Get the site code from the listbox for the selected station """

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
    def getDates(self, db, code, param):
        """ get min and max dates of available target data """

        sitenum = db.getSiteNum(code)
        paramnum = db.getGasNum(param)
        query = "select year(min(date)) as mindate "
        query += "from insitu_data where site_num=%d and parameter_num=%s and target=1" % (sitenum, paramnum)
        print(query)

        result = db.doquery(query)
        mindate = result[0]['mindate']

        return mindate

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
        self.data.skipfirst = self.skip.GetValue()
        self.data.includework = self.includework.GetValue()
        self.data.includeresp = self.includeresp.GetValue()
        self.data.includevalue = self.includevalue.GetValue()

        t = self.dtype.GetSelection()
        self.data.dtype = t

#        try:
#            self.data.inst = self.inst.GetStringSelection()
#        except:
#            self.data.inst = None

        self.EndModal(wx.ID_OK)
