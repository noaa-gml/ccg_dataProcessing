# vim: tabstop=4 shiftwidth=4 expandtab

"""
Dialog class for choosing data set to graph.

For getting data from insitu database tables.

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

        x,y,name = dlg.data.ProcessData()
"""

import datetime
from collections import defaultdict
import wx

import ccg_dbutils
import ccg_insitu_data2
import ccg_tower_data


#####################################################################
class GetInsituData:
    """ class for holding settings and getting data from database
    from the 'insitu' tables.
    """

    def __init__(self):
        self.stacode = "MLO"
        self.paramname = "co2"
        self.byear = 0
        self.eyear = 0
        self.use_soft_flags = False
        self.use_hard_flags = False
        self.month1 = 0
        self.month2 = 0
        self.intake_ht = 0
        self.monthlist = [
                "January",
                "February",
                "March",
                "April",
                "May",
                "June",
                "July",
                "August",
                "September",
                "October",
                "November",
                "December"
        ]

    # ----------------------------------------------
    def ProcessData(self):
        """
        Process the data from the GetDataDialog,
        return the x, and y lists and name for new dataset.
        """

        date1 = self.GetBegDate()
        date2 = self.GetEndDate()

        if self.stacode.lower() in ['brw', 'mlo', 'smo', 'spo', 'mko', 'cao']:
            fdb = ccg_insitu_data2.InsituData(self.paramname, self.stacode, 0)
        else:
            fdb = ccg_tower_data.TowerData(self.paramname, self.stacode, 0)

        print(date1, date2, self.intake_ht)
        fdb.setRange(date1, date2)
        fdb.includeFlaggedData()
        fdb.setIntakeHeight(self.intake_ht)
        fdb.run(as_arrays=True)
        fdb.showQuery()

        x = fdb.results['date']
        y = fdb.results['value']

        name = self.stacode + " " + self.paramname + " " + str(self.intake_ht)

        return x, y, name

    # ----------------------------------------------
    def GetBegDate(self):
        """ Create datetime of beginning date """

        datestr1 = datetime.datetime(self.byear, self.month1, 1)

        return datestr1

    # ----------------------------------------------
    def GetEndDate(self):
        """ Create datetime of ending date """

        # set end 1 month after saved setting
        endmonth = self.month2+1
        endyear = self.eyear
        if endmonth > 12:
            endyear += 1
            endmonth = 1
        datestr2 = datetime.datetime(endyear, endmonth, 1)

        return datestr2

    # ----------------------------------------------
    def SetBegYear(self, yr):
        """ save beginning year """

        self.byear = int(yr)

    # ----------------------------------------------
    def SetEndYear(self, yr):
        """ save ending year """

        self.eyear = int(yr)

    # ----------------------------------------------
    def SetBegMonth(self, month_string):
        """ save beginning month """

        self.month1 = self.getMonthNum(month_string)

    # ----------------------------------------------
    def SetEndMonth(self, month_string):
        """ save ending month """

        self.month2 = self.getMonthNum(month_string)

    # ----------------------------------------------
    def getMonthNum(self, s):
        """ convert month name to number """

        if s in self.monthlist:
            num = self.monthlist.index(s) + 1
        else:
            num = 0

        return num

    # ----------------------------------------------
    def SetParameter(self, formula):
        """ save parameter formula """

        self.paramname = formula

    # ----------------------------------------------
    def SetIntakeHt(self, n):
        """ save intake height """

        self.intake_ht = float(n)

    # ----------------------------------------------
    def SetStation(self, code):
        """ save station code """

        self.stacode = code


##########################################################################
class GetInsituDataDialog(wx.Dialog):
    """ a dialog for selecting insitu data """

    def __init__(self, parent=None, title="Choose Dataset"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

        self.db = ccg_dbutils.dbUtils()
        self.data = GetInsituData()
        self.params = defaultdict(list)
        self.paramnames = defaultdict(list)
        self.intake = None

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

    # ----------------------------------
    # widget creation routines
    # ----------------------------------

    # ----------------------------------
    def mkStation(self):
        """ Make extended choice box with list of avaiable station names.
            Also create a dict with list of parameter formulas available at each station.
        """

        box = wx.StaticBox(self, -1, "Sampling Site")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#        self.listbox = extchoice.ExtendedChoice(self, -1, size=(555,-1))
#        self.listbox = combolist.ComboList(self, -1, size=(555, -1))
        self.listbox = wx.ComboBox(self, -1, size=(555, -1), style=wx.CB_READONLY)

        value = ""
        stations = []
        query = "select distinct site_num, parameter_num from insitu_data "
        result = self.db.doquery(query)
        for row in result:
            paramnum = row['parameter_num']
            param = self.db.getGasFormula(paramnum)
            code = self.db.getSiteCode(row['site_num']).lower()
            if param not in self.params[code]:
                self.params[code].append(param)
                self.paramnames[param] = self.db.getGasName(param)

            name = self.db.getSiteName(code)
            txt = "%s - %s" % (code.upper(), name)
            if txt not in stations:
                stations.append(txt)
            if code.upper() == self.data.stacode:
                value = txt

        if value == "": value = stations[0]

#        self.listbox.ReplaceAll(stations)
#        self.listbox.InsertItems(stations)
        self.listbox.Set(stations)
        self.listbox.SetValue(value)

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

        self.parambox = wx.ListBox(self, -1, style=wx.LB_SINGLE, size=(500, 150))
        box1.Add(self.parambox, 1, wx.ALIGN_RIGHT | wx.ALL, 5)
        self.parambox.Bind(wx.EVT_LISTBOX, self.paramSelected)

        self.param_config()

        return box1

    # ----------------------------------
    def mkTimeSpan(self):
        """ Make two rows with month selector, year spin box in each row """

        now = datetime.datetime.now()
        this_month = now.strftime("%B")

        box = wx.StaticBox(self, -1, "Time Span")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 3, 2, 2)
        szr.Add(box1)

        label = wx.StaticText(self, -1, "Start")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.month1 = wx.Choice(self, -1, choices=self.data.monthlist)
        self.month1.SetSelection(self.data.monthlist.index(this_month))
        box1.Add(self.month1, 0, wx.ALIGN_CENTRE | wx.ALL, 0)

        # the callback for the byear and eyear calls the database to get valid intake heights
        # for the requested date range.
        # But there's a wierd bug in spinctrl in that if the callback doesn't return within ~0.1 seconds,
        # a second event is created.  This makes the spinctrl go up or down by 2 values instead of 1.
        # because of this, we'll use a choice instead
        (mindate, maxdate) = self.getDates(self.data.stacode, self.data.paramname)
        zz = [str(x) for x in range(mindate.year, maxdate.year+1)]
#        self.byear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
        self.byear = wx.Choice(self, -1, choices=zz)
        box1.Add(self.byear, 0, wx.ALIGN_LEFT | wx.ALL, 0)
        self.byear.SetSelection(zz.index(str(maxdate.year)))

        label = wx.StaticText(self, -1, "End")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.month2 = wx.Choice(self, -1, choices=self.data.monthlist)
        box1.Add(self.month2, 0, wx.ALIGN_CENTRE | wx.ALL, 0)
        self.month2.SetSelection(self.data.monthlist.index(this_month))

#        self.eyear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
        self.eyear = wx.Choice(self, -1, choices=zz)
        box1.Add(self.eyear, 0, wx.ALIGN_LEFT | wx.ALL, 0)
        self.eyear.SetSelection(zz.index(str(maxdate.year)))

        # add bindings to month/year changes
        self.month1.Bind(wx.EVT_CHOICE, self.dateSelected)
        self.month2.Bind(wx.EVT_CHOICE, self.dateSelected)
        self.byear.Bind(wx.EVT_CHOICE, self.dateSelected)
        self.eyear.Bind(wx.EVT_CHOICE, self.dateSelected)
#        self.byear.Bind(wx.EVT_TEXT, self.dateSelected)
#        self.byear.Bind(wx.EVT_SPINCTRL, self.dateSelected)
#        self.eyear.Bind(wx.EVT_TEXT, self.dateSelected)
#        self.eyear.Bind(wx.EVT_SPINCTRL, self.dateSelected)

        self.setDates()

        return szr

    # ------------------------------------------------------------------------
    def mkOptions(self):
        """ create the options panel """

        box = wx.StaticBox(self, -1, "Data Options")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

        panel = self.options()
        szr.Add(panel)

        return szr

    # ------------------------------------------------------------------------
    def options(self):
        """ create the options panel.
            options will depend on the station, parameter and dates
            already chosen.
        """

        panel = wx.Panel(self, -1)
        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        # intake heights
        txt = wx.StaticText(panel, -1, "Intake Heights")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

        rbList = self.getIntakeHts()
        if rbList:
            self.intake = wx.RadioBox(
                    panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
                    rbList, 1, wx.RA_SPECIFY_COLS  # | wx.NO_BORDER
                    )
            vs.Add(self.intake, 0, wx.LEFT, 20)

        return panel

    # ----------------------------------
    # callbacks
    # ----------------------------------

    # ----------------------------------
    def stationSelected(self, event):
        """ station selection has changed.
            update station, parameters, time span and options
            with values relavent to selected station.
        """

        # get and set in data the newly selected station code
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

        # get and set in data the newly selected parameter
        s = self.parambox.GetStringSelection()
        if s:
            self.data.SetParameter(self.getParameter())

            # update the time and options sections
            self.date_config()
            self.option_config()

    # ----------------------------------
    def dateSelected(self, event):
        """ date selection has changes.
            update time span and options
            with values relavent to selected station, parameter and date
        """

        self.setDates()

        self.option_config()

    # ----------------------------------
    # helper functions
    # ----------------------------------

    # ----------------------------------
    def param_config(self):
        """ update the parameter selection list with
            parameters available for the selected station.
        """

        code = self.data.stacode
        params = self.params[code.lower()]  # get parameters for this station

        self.parambox.Clear()
        for formula in params:
            name = self.paramnames[formula]
            s = "%s - %s" % (formula, name)
            self.parambox.Append(s)

        self.parambox.SetSelection(0)
        self.data.SetParameter(params[0])

    # ----------------------------------
    def date_config(self):
        """ update the year boxes with available years for selected
            station and parameter.
        """

        (mindate, maxdate) = self.getDates(self.data.stacode, self.data.paramname)
    #                print mindate, maxdate

        # remember current date settings
        self.setDates()
        print(self.data.byear, self.data.eyear)

        self.byear.Clear()
        self.eyear.Clear()
        zz = [str(x) for x in range(mindate.year, maxdate.year+1)]
        print(zz)
        self.byear.SetItems(zz)
        self.eyear.SetItems(zz)

        if str(self.data.byear) in zz:
            self.byear.SetSelection(zz.index(str(self.data.byear)))
        else:
            self.byear.SetSelection(zz.index(str(mindate.year)))
            self.data.SetBegYear(mindate.year)

        if str(self.data.eyear) in zz:
            self.eyear.SetSelection(zz.index(str(self.data.eyear)))
        else:
            self.eyear.SetSelection(zz.index(str(maxdate.year)))
            self.data.SetEndYear(maxdate.year)

    #                self.byear.SetRange(mindate.year, maxdate.year)
    #                self.eyear.SetRange(mindate.year, maxdate.year)

    # ----------------------------------
    def option_config(self):
        """ update the options section of the dialog """

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
        """ Get the site code for the selected station """

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
        """ Get min and max dates for selected station and parameter """

        sitenum = self.db.getSiteNum(code)
        gasnum = self.db.getGasNum(param)
        query = "select min(date) as mindate, max(date) as maxdate from insitu_data where site_num=%s and parameter_num=%s" % (sitenum, gasnum)
#        print(query)

        dlist = self.db.doquery(query)

        row = dlist[0]

        return row['mindate'], row['maxdate']

    # ----------------------------------
    def setDates(self):
        """ set the data begin year, end year, beg month, end month """

#        self.data.SetBegYear(self.byear.GetValue())
#        self.data.SetEndYear(self.eyear.GetValue())
        self.data.SetBegYear(self.byear.GetStringSelection())
        self.data.SetEndYear(self.eyear.GetStringSelection())
        self.data.SetBegMonth(self.month1.GetStringSelection())
        self.data.SetEndMonth(self.month2.GetStringSelection())

    # ----------------------------------
    def getIntakeHts(self):
        """ get the available intake heights for the given date range.
        update the radio button options with new heights
        """

        datestr1 = self.data.GetBegDate()
        datestr2 = self.data.GetEndDate()

        sitenum = self.db.getSiteNum(self.data.stacode)
        paramnum = self.db.getGasNum(self.data.paramname)
        query = "select distinct height from intake_heights "
        query += "where start_date<='%s' and end_date>='%s' " % (datestr2, datestr1)
        query += "and site_num=%d and parameter_num=%d" % (sitenum, paramnum)
        dlist = self.db.doquery(query)

        rbList = None
        if dlist:
            rbList = []
            for row in dlist:
                ht = row['height']
                rbList.append(str(ht))

        return rbList

    # ----------------------------------
    def ok(self, event):
        """
        Get all the values from the dialog and store them in self.data
                stacode
                parameter
                begyear
                endyear
                begmonth
                endmonth
                options:
                        intake_ht
                        analyzer
        """

        self.data.SetStation(self.getStationCode())
        self.setDates()
        self.data.SetParameter(self.getParameter())
        self.data.SetIntakeHt(self.intake.GetStringSelection())

        self.EndModal(wx.ID_OK)
