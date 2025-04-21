# vim: tabstop=4 shiftwidth=4 expandtab
"""
A dialog to determine which station, gas and month to use
"""

import datetime
import wx
import calendar

import ccg_dbutils
import ccg_insitu_systems

monthlist = [
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

# list of sites that we can work with
SITES_TO_USE = ["brw", "mlo", "smo", "spo", "mko", "cao", "bnd", "lef", "wkt", "amt", "wbi", "sbt", "wgc"]


##########################################################################
class OpenDialog(wx.Dialog):
    """ A dialog for selecting station and date to use """

    def __init__(self, parent=None, title="Open"):
        wx.Dialog.__init__(self, parent, -1, title)

        self.stations = {}
        self.data = self.getAvailableData()
        self.code = "BRW"  # default site for selection choices

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkTimespan()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

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

        self.setParam(None)

    # ----------------------------------
    def getAvailableData(self):
        """ Get a list of available stations, gases from the database """

        data = []

        db = ccg_dbutils.dbUtils()

        sql = "select distinct site_num, parameter_num from ccgg.insitu_data"
        result = db.doquery(sql)

        for row in result:
            sitenum = row['site_num']
            parameter_num = row['parameter_num']
            stacode = db.getSiteCode(sitenum)
            name = db.getSiteName(stacode)
            gas = db.getGasFormula(parameter_num)
            if stacode.lower() in SITES_TO_USE:

                data.append((stacode, gas, name))

                if name not in self.stations:
                    s = "%s %s" % (stacode.upper(), name)
                    self.stations[s] = stacode

        return data

    # ----------------------------------
    def mkSource(self):
        """ Create boxes for station and gas selection """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        # station choice box
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Station: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

#        self.choice = wx.Choice(self, -1, choices=sorted(self.stations.keys()))
        choices = sorted(list(self.stations.keys()))
        for idx, t in enumerate(choices):
            if self.code in t:
                break

        self.choice = wx.Choice(self, -1, choices=choices)
        self.choice.SetSelection(idx)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selStation, self.choice)

        # species choice box
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Species: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.choice2 = wx.Choice(self, -1)
        self.choice2.SetSelection(0)
        box1.Add(self.choice2, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.setParam, self.choice2)

        # system choice box (co2 only for now)
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "System: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.systemchoice = wx.Choice(self, -1, size=(100, -1))
        self.systemchoice.SetSelection(0)
        box1.Add(self.systemchoice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        return sizer

    # ----------------------------------
    def mkTimespan(self):
        """ Create boxes for setting the year and month """

        now = datetime.datetime.today()
        self.year = int(now.strftime("%Y"))
        this_month = now.strftime("%B")
        self.month = monthlist.index(this_month) + 1

        # Second static box sizer
        box = wx.StaticBox(self, -1, "Time Span")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        sizer.Add(box1, 0, wx.GROW | wx.ALL, 0)

        label = wx.StaticText(self, -1, "Month: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.month1 = wx.Choice(self, -1, choices=monthlist)
        self.month1.SetSelection(monthlist.index(this_month))
        box1.Add(self.month1, 0, wx.ALIGN_CENTRE | wx.ALL, 0)
        self.Bind(wx.EVT_CHOICE, self.setDate, self.month1)

        label = wx.StaticText(self, -1, "Year: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.byear = wx.SpinCtrl(self, -1, str(self.year), min=1973, max=self.year)
        box1.Add(self.byear, 0, wx.ALIGN_CENTRE | wx.ALL, 0)
        self.Bind(wx.EVT_SPINCTRL, self.setDate, self.byear)

        return sizer

    # ----------------------------------
    def selStation(self, event):
        """ A new station has been selected, update the
        dialog with appropriate values for the station
        """

        staname = event.GetString()
        self.code = self.stations[staname]

        self.setParam(None)

    # ----------------------------------
    def setParam(self, event):
        """ Set the species select box for selected site """

        params = []
        for (code, gas, a) in self.data:
            if code == self.code:
                params.append(gas.upper())

        # get currently selected gas
        curr_gas = self.choice2.GetStringSelection()
        self.choice2.Clear()

        # create new list of gases available for this site.
        for s in params:
            self.choice2.Append(s)

        # keep the same gas as before if possible
        if curr_gas in params:
            self.choice2.SetSelection(params.index(curr_gas))
        else:
            self.choice2.SetSelection(0)

        self.setSystem(None)

    # ----------------------------------
    def setSystem(self, event):
        """ New species has been set, update the available
        systems for the site, species, date """

        s = self.choice2.GetStringSelection()
        self.species = s.lower()

        systems = ccg_insitu_systems.system(self.code, self.species)
        dt = datetime.datetime(self.year, self.month, 1)
        sysnames1 = systems.get(dt)
#        syslist = [s.upper() for s in sysnames]

        (a, daysinmonth) = calendar.monthrange(self.year, self.month)
        systems = ccg_insitu_systems.system(self.code, self.species)
        dt = datetime.datetime(self.year, self.month, daysinmonth)
        sysnames2 = systems.get(dt)

        # merge sysnames
        sysnames = set(sysnames1 + sysnames2)

        syslist = [s.upper() for s in list(sysnames)]

        curr_sys = self.systemchoice.GetStringSelection()
        self.systemchoice.Clear()
        for s in syslist:
            self.systemchoice.Append(s)

        if curr_sys in syslist:
            self.systemchoice.SetSelection(syslist.index(curr_sys))
        else:
            self.systemchoice.SetSelection(0)

    # ----------------------------------
    def setDate(self, event):
        """ New date has been set, update the available
        systems for the site, species, date """

        month1 = self.month1.GetStringSelection()
        self.month = monthlist.index(month1) + 1

        self.year = int(self.byear.GetValue())

        self.setSystem(None)

    # ----------------------------------
    def ok(self, event):
        """ Save settings and end dialog """

        db = ccg_dbutils.dbUtils()

        station = self.choice.GetStringSelection()
        self.code = self.stations[station]
        self.sitenum = db.getSiteNum(self.code)

        s = self.choice2.GetStringSelection()
        self.species = s.lower()
        self.paramnum = db.getGasNum(self.species)

        self.year = int(self.byear.GetValue())

        month1 = self.month1.GetStringSelection()
        self.month = monthlist.index(month1) + 1

        self.system = self.systemchoice.GetStringSelection()

        self.EndModal(wx.ID_OK)
