# vim: tabstop=4 shiftwidth=4 expandtab

"""
Get dates and values of reference tanks that were used.
Display them in a dialog.
"""

import datetime
import calendar
from operator import attrgetter
import wx

import ccg_tankhistory
import ccg_refgasdb


##########################################################################
class TankDialog(wx.Dialog):
    """ A dialog showing what reference tanks were used for a given month """

    def __init__(self, parent, gas, code, system, year, month, title="Working Tanks"):
        wx.Dialog.__init__(self, parent, -1, title)

        (a, daysinmonth) = calendar.monthrange(year, month)

        self.gas = gas
        self.system = system
        self.startdate = datetime.datetime(year, month, 1, 0)
        self.enddate = datetime.datetime(year, month, daysinmonth, 23, 59)

        # get the last tank that started before the first of this month
        # and any tanks that started after the first of the month
        print("system is", self.system)
        hist = ccg_tankhistory.tankhistory(gas, location=code, system=self.system)
        tanklist1 = hist.filterByDate(self.startdate)

        # keep only the tanks that started before the end of the month
        self.tanklist = []
        for t in tanklist1:
            if t.start_date <= self.enddate:
                self.tanklist.append(t)

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkList()
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
    def mkList(self):
        """ Create a list control that contains the dates and values of the working tanks """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Working Tanks")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.listbox = wx.ListCtrl(self, -1, style=wx.LB_SINGLE, size=(500, 300))
        self.listbox.InsertColumn(0, "Type", width=60)
        self.listbox.InsertColumn(1, "Start Date", width=100)
        self.listbox.InsertColumn(2, "Start Time", width=90)
        self.listbox.InsertColumn(3, "Serial Number", width=100)
        self.listbox.InsertColumn(4, "Value", width=80)

        self.tanklist.sort(key=attrgetter('label', 'start_date'))
        tlist = [t.serial_number for t in self.tanklist]
        refgas = ccg_refgasdb.refgas(self.gas, tlist)

        for n, tank in enumerate(self.tanklist):
            if tank.start_date > self.enddate:
                continue

            row = refgas.getAssignment(tank.serial_number, tank.start_date)
            print(row)
            print(tank.start_date)
            if tank.start_date > self.startdate:
                val, unc = refgas.getRefgasBySerialNumber(tank.serial_number, tank.start_date)
            else:
                val, unc = refgas.getRefgasBySerialNumber(tank.serial_number, self.startdate)

            mfstr = "%.2f" % val
            if row is not None:
                if row.coef1 != 0:
                    mfstr += "*"

            index = self.listbox.InsertItem(n, tank.label)
            self.listbox.SetItem(index, 1, str(tank.start_date.date()))
            self.listbox.SetItem(index, 2, str(tank.start_date.time()))
            self.listbox.SetItem(index, 3, tank.serial_number)
            self.listbox.SetItem(index, 4, mfstr)

        sizer.Add(self.listbox, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        msg = "* in value indicates drifting tank assignment.  Value is for start of the month"
        t = wx.StaticText(self, -1, msg)
        font = wx.Font(wx.FontInfo().Italic())
        t.SetFont(font)
        sizer.Add(t)

        return sizer

    # ----------------------------------
    def ok(self, event):
        """ End the dialog """

        self.EndModal(wx.ID_OK)
