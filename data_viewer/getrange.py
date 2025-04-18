# vim: tabstop=4 shiftwidth=4 expandtab

"""
A dialog to get a date range of raw files.

Can handle flask, calibration and nl raw files.
Input is a value (1, 2, or 3) that selects which project.
Then choices are available for gas, system, instrument, start date and end date.

Data is set in the dialog as member 'data', which is a namedtuple.
"""

import os
import sys
import datetime
import glob
from collections import namedtuple

import wx
import wx.adv

FLASK = 1
NL = 2
CAL = 3
# INSITU = 4 not implemented

project_title = {FLASK: "Flask", NL: "Response Curves", CAL: "Calibrations"}


##########################################################################
class GetRawRangeDialog(wx.Dialog):
    """ Dialog for getting date range of raw files """

    def __init__(self, parent=None, rawtype=FLASK):
        wx.Dialog.__init__(self, parent, -1, title="Get Raw File Date Range")

        RangeData = namedtuple('rangedata',
                               ['project', 'parameter', 'param_num', 'sys', 'inst',
                                'method', 'start_date', 'end_date', 'files']
                               )
        self.data = RangeData(
            project='cals',
            parameter='co2',
            param_num=1,
            sys='magicc-3',
            inst='pc2',
            method='',
            start_date=datetime.date.today(),
            end_date=datetime.date.today(),
            files=[]
        )

        self.gasnums = {"CO2": 1, "CH4": 2, "CO": 3, "H2": 4, "N2O": 5, "SF6": 6, "CO2C13": 7, "CO2O18": 8}

#        self.data = RawGetRangeData
        if rawtype == FLASK:
            self.data = self.data._replace(project="flask")
        elif rawtype == CAL:
            self.data = self.data._replace(project="cals")
        elif rawtype == NL:
            self.data = self.data._replace(project="nl")
        self.rawtype = rawtype

        if self.data.project == "cals":
            self.gaslist = ["CO2", "CH4", "CO", "H2", "N2O", "SF6", "CO2C13", "CO2O18"]
        elif self.data.project == "flask":
            self.gaslist = ["CO2", "CH4", "CO", "H2", "N2O", "SF6"]
        elif self.data.project == "nl":
            self.gaslist = ["CO2", "CH4", "CO", "H2", "N2O", "SF6"]
        elif self.data.project == "in-situ":
            self.gaslist = ["CO2", "CH4", "CO", "N2O"]

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        self.mkSource(box0)

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

#        self.setSystem()
        self.selProj()

    # ----------------------------------
    def mkSource(self, box0):
        """ Build all the widgets """

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        box0.Add(box1, 0, wx.GROW | wx.ALL, 0)

        # project choice box
        label = wx.StaticText(self, -1, "Project: ")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.TOP, 10)

        a = [project_title[self.rawtype]]
        self.proj = wx.Choice(self, -1, choices=a, size=(200, -1))
        self.proj.SetSelection(0)
        box1.Add(self.proj, 0, wx.ALIGN_LEFT | wx.ALL, 5)
#        self.Bind(wx.EVT_CHOICE, self.selProj, self.proj)

        # species choice box

        label = wx.StaticText(self, -1, "Species: ")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.TOP, 10)

        self.param = wx.Choice(self, -1, choices=self.gaslist, size=(200, -1))
        self.param.SetSelection(0)
        box1.Add(self.param, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selParam, self.param)

        # ----------------------------------
        # system choice box
        label = wx.StaticText(self, -1, "System: ")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.TOP, 10)

        syslist = []
        self.system = wx.Choice(self, -1, choices=syslist, size=(200, -1))
        box1.Add(self.system, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selSystem, self.system)

        # ----------------------------------
        # instrument

        label = wx.StaticText(self, -1, "Instrument:")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.TOP, 10)

        self.inst = wx.Choice(self, -1, choices=[], size=(200, -1))
        box1.Add(self.inst, 0, wx.ALIGN_LEFT | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selInst, self.inst)

        # ----------------------------------
        # start date

        label = wx.StaticText(self, -1, "Beginning Date:")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALL, 0)
        self.cal = wx.adv.CalendarCtrl(self, -1, wx.DateTime.Now())
        box1.Add(self.cal, 1, wx.GROW | wx.ALIGN_LEFT | wx.ALL, 0)
        self.Bind(wx.adv.EVT_CALENDAR_SEL_CHANGED, self.selDate, self.cal)

        label = wx.StaticText(self, -1, "Ending Date:")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALL, 0)
        self.cal2 = wx.adv.CalendarCtrl(self, -1, wx.DateTime.Now())
        box1.Add(self.cal2, 0, wx.ALIGN_LEFT | wx.ALL, 0)
        self.Bind(wx.adv.EVT_CALENDAR_SEL_CHANGED, self.selDate, self.cal2)

    # ----------------------------------
    def selProj(self, event=None):
        """ new project has been selected, update systems """

        n = self.proj.GetSelection()
        proj = self.proj.GetString(n)

#        proj = event.GetString()
        if proj == "Calibrations":
            self.data = self.data._replace(project="cals")
        elif proj == "Response Curves":
            self.data = self.data._replace(project="nl")
        elif proj == "Flask":
            self.data = self.data._replace(project="flask")

        self.setSystem()

    # ----------------------------------
    def selParam(self, event):
        """ new parameter has been selected, update systems """

        n = self.param.GetSelection()
        param = self.param.GetString(n)
        param_num = self.gasnums[param]

        self.data = self.data._replace(parameter=param, param_num=param_num)
        self.setSystem()

    # ----------------------------------
    def selDate(self, event):
        """ new date has been selected, update instruments """

        self.setInstruments()

    # ----------------------------------
    def selSystem(self, event):
        """ New system has been selected, save the system """

        n = self.system.GetSelection()
        sysname = self.system.GetString(n)

        self.data = self.data._replace(sys=sysname)
        self.setInstruments()

    # ----------------------------------
    def selInst(self, event):
        """ New instrument has been selected, save the instrument id """

        n = self.inst.GetSelection()
        instid = self.inst.GetString(n)

        self.data = self.data._replace(inst=instid)

    # ----------------------------------
    def setSystem(self):
        """ Set the available systems for given parameter, project """

        valid_systems = ["magicc-3", "magicc-1", "magicc-2", "co2cal-2",
                         "cocal-1", "ch4cal-1", "carle", "rgd2"]

        dirname = "/ccg/%s/%s/" % (self.data.parameter.lower(), self.data.project)
        if sys.platform == "darwin":
            dirname = "/Volumes" + dirname

        list1 = []
        for system in valid_systems:
            path = "%s/%s" % (dirname, system)
            if os.path.exists(path):
                list1.append(system)

        self.data = self.data._replace(sys=os.path.basename(list1[0]))
        self.system.SetItems(list1)
        self.system.SetSelection(0)

        # also need to set the instruments
        self.setInstruments()

    # ----------------------------------
    def setInstruments(self):
        """ Set the available instruments for a given system """

        dirname = "/ccg/%s/%s/%s" % (self.data.parameter.lower(), self.data.project, self.data.sys)
        if sys.platform == "darwin":
            dirname = "/Volumes" + dirname

        param = self.data.parameter.lower()

        # need dates to look in raw files
        t1 = self.cal.GetDate()
        t2 = self.cal2.GetDate()
        yr1 = t1.GetYear()
        yr2 = t2.GetYear() + 1
        dt1str = "%4d-%02d-%02d" % (t1.GetYear(), t1.GetMonth()+1, t1.GetDay())
        dt2str = "%4d-%02d-%02d" % (t2.GetYear(), t2.GetMonth()+1, t2.GetDay())
#        print(dt1str, dt2str)

        idlist = []
        for year in range(yr1, yr2):
            # get only files with raw file name format
            pattern = "%s/raw/%s/%s-*.%s" % (dirname, year, year, param)
#            print(pattern)
            files = glob.glob(pattern)
#            print(files)
            for filename in files:
                bname = os.path.basename(filename)
                a = bname.split(".")
                if dt1str <= a[0] <= dt2str:
                    inst_id = str(a[2]).upper()
                    if inst_id not in idlist:
                        idlist.append(inst_id)

#        print(idlist)

        if len(idlist) > 0:
            # try to keep already selected instrument if it's still available
            n = self.inst.GetSelection()
            if n >= 0:
                instid = self.inst.GetString(n)
            else:
                instid = None

            self.inst.SetItems(idlist)
            if instid in idlist:
                self.data = self.data._replace(inst=instid)
                self.inst.SetSelection(idlist.index(instid))
            else:
                self.data = self.data._replace(inst=idlist[0])
                self.inst.SetSelection(0)
        else:
            self.data = self.data._replace(inst="")
            self.inst.SetItems(idlist)
            self.inst.SetSelection(0)

    # ----------------------------------
    def ok(self, event):
        """ ok button clicked, save data and exit """

        t1 = self.cal.GetDate()
        t2 = self.cal2.GetDate()
        ymd = map(int, t1.FormatISODate().split('-'))
        self.data = self.data._replace(start_date=datetime.date(*ymd))

        ymd = map(int, t2.FormatISODate().split('-'))
        self.data = self.data._replace(end_date=datetime.date(*ymd))

#        print self.data
        if self.data.end_date < self.data.start_date:
            dlg = wx.MessageDialog(self, "End date must be >= start date", 'Warning', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        if self.data.inst == "":
            msg = "No files for selected date range and instrument."
            dlg = wx.MessageDialog(self, msg, 'Warning', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        self.EndModal(wx.ID_OK)
