# vim: tabstop=4 shiftwidth=4 expandtab


import datetime
import wx
import wx.adv

import ccg_db_conn


##########################################################################
class MetDialog(wx.Dialog):
    def __init__(self, parent=None, title="Open"):
        wx.Dialog.__init__(self, parent, -1, title)

        self.params = ["P Pressure",
                       "WI Precipitation Intensity",
                       "U Relative Humdity",
                       "T Temperature (2m)",
                       "T1 Temperature (10m)",
                       "T2 Temperature (top)",
                       "WS Wind Speed",
                       "WD Wind Direction",
                       "WDg Wind Steadiness Factor"]

        self.stations = ["BRW Barrow, Alaska",
                         "MLO Mauna Loa, Hawaii",
                         "SMO American Samoa",
                         "SPO South Pole",
                         "THD Trinidad Head, California",
                         "SUM Summit, Greenland"]

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource(box0)
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkTimespan(box0)
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

    # ----------------------------------
    def mkSource(self, box0):

        # First static box sizer
        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        # station choice box
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Station: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.choice = wx.Choice(self, -1, choices=self.stations)
        self.choice.SetSelection(0)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
#        self.Bind(wx.EVT_CHOICE, self.selStation, self.choice)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Parameter: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.systemchoice = wx.Choice(self, -1, size=(200, -1), choices=self.params)
        self.systemchoice.SetSelection(0)
        box1.Add(self.systemchoice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Data Type: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.datachoice = wx.Choice(self, -1, size=(200, -1), choices=["Hourly Averages", "Minute Averages"])
        self.datachoice.SetSelection(0)
        box1.Add(self.datachoice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        return sizer

    # ----------------------------------
    def mkTimespan(self, box0):

        # Second static box sizer
        box = wx.StaticBox(self, -1, "Time Span")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.rangetext = wx.StaticText(self, -1, "")
        sizer.Add(self.rangetext, 0, wx.ALL, 10)

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        sizer.Add(box1, 0, wx.GROW | wx.ALL, 0)

        t = wx.DateTime.Now()
        print(t)
        t = t.SetDay(1)    # set to first day of current month
        label = wx.StaticText(self, -1, "Beginning Date:")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALL, 0)
        self.cal = wx.adv.CalendarCtrl(self, -1, t)
        box1.Add(self.cal, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        label = wx.StaticText(self, -1, "Ending Date:")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALL, 0)
        self.cal2 = wx.adv.CalendarCtrl(self, -1, wx.DateTime.Now())
        box1.Add(self.cal2, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        return sizer

    # ----------------------------------
    def ok(self, event):

        station = self.choice.GetStringSelection()
        a = station.split(None, 1)
        self.code = a[0]

        self.startdate = self.cal.GetDate()
        self.enddate = self.cal2.GetDate()

        self.parameter = self.systemchoice.GetStringSelection()
        (self.paramcode, self.paramname) = self.parameter.split(None, 1)
        self.datatype = self.datachoice.GetStringSelection()

        self.EndModal(wx.ID_OK)

    # ----------------------------------
    def ProcessData(self):

        db = ccg_db_conn.RO()

        syear = self.startdate.GetYear()
        smonth = self.startdate.GetMonth() + 1
        sday = self.startdate.GetDay()
        eyear = self.enddate.GetYear()
        emonth = self.enddate.GetMonth() + 1
        eday = self.enddate.GetDay()

        s1 = "%d-%d-%d" % (syear, smonth, sday)
        s2 = "%d-%d-%d" % (eyear, emonth, eday)

        if "minute" in self.datatype.lower():
            table = "met.%s_minute" % (self.code.lower())
            field = "time"

        else:
            table = "met.%s_hour" % (self.code.lower())
            field = "hour"

        # get the mysql default value for the parameter
        sql = "select default(%s) from %s limit 1" % (self.paramcode, table)
        result = db.doquery(sql)
        name = "default(%s)" % self.paramcode
        defaultval = result[0][name]

        sql = "select date,%s,%s from %s " % (field, self.paramcode, table)
        sql += "where date>='%s' and date<='%s' " % (s1, s2)
        sql += "and %s>%s order by date, %s" % (self.paramcode, defaultval, field)
        result = db.doquery(sql)

        x = []
        y = []

        if result:
            for row in result:
                date = row['date']
                time = row[field]
                value = row[self.paramcode]

                if "minute" in self.datatype.lower():
                    s = "%s" % time
                    (hour, minute, second) = s.split(':')
                    hour = int(hour)
                    minute = int(minute)
                    second = int(second)
                else:
                    hour = int(time)
                    minute = 0
                    second = 0

                xp = datetime.datetime(date.year, date.month, date.day, hour, minute, second)
                yp = value

                x.append(xp)
                y.append(yp)

        name = "%s %s" % (self.code, self.paramname)

        return x, y, name
