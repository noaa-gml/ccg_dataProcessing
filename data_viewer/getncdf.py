
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Module for importing a netcdf file into flsel
"""

import os
import wx

import ccg_ncdf


##########################################################################
class ImportDialog(wx.Dialog):
    """ A dialog for selecting a netcdf file """

    def __init__(self, parent=None, title="Import Data"):
        wx.Dialog.__init__(self, parent, -1, title)

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
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
    def mkSource(self):
        """ Create widgets for selecting file """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        # horizontal box
        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box2, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Filename:")
        box2.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.file = wx.TextCtrl(self, -1, "", size=(250, -1))
        box2.Add(self.file, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        btn = wx.Button(self, 1, "Browse...")
        self.Bind(wx.EVT_BUTTON, self.browse, btn)
        box2.Add(btn, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        return sizer

    # ----------------------------------
    def mkOptions(self):
        """ Show options available for handling data """

        # -------------- second static box sizer
        box = wx.StaticBox(self, -1, "Options")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)

        panel = self._options()
        sizer2.Add(panel)

        return sizer2

    # ----------------------------------
    def _options(self):
        """ set up options part of dialog

        This consists of text controls to allow different
        intake heights and times of day to be specified
        for filtering the data from the netcdf file
        """

        panel = wx.Panel(self, -1)

        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        txt = wx.StaticText(panel, -1, "Intake Heights")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 5)

        # another horizontal box
        box2 = wx.BoxSizer(wx.HORIZONTAL)
        vs.Add(box2, 0, wx.GROW | wx.LEFT | wx.TOP, 15)

        units = "meters"
        label = wx.StaticText(panel, -1, "From ")
        box2.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)
        self.le2 = wx.TextCtrl(panel, -1, "")
        box2.Add(self.le2, 0, wx.ALIGN_LEFT)
        label = wx.StaticText(panel, -1, " to ")
        box2.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)
        self.le3 = wx.TextCtrl(panel, -1, "")
        box2.Add(self.le3, 0, wx.ALIGN_LEFT)
        label = wx.StaticText(panel, -1, " %s." % units)
        box2.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)

        self.o3 = wx.CheckBox(panel, -1, "Use All Intake Heights")
        self.o3.SetValue(True)
        vs.Add(self.o3, 0, wx.ALIGN_LEFT | wx.LEFT, 15)

        self.avail_hts = wx.StaticText(panel, -1, "Available Heights:")
        vs.Add(self.avail_hts, 1, wx.GROW | wx.LEFT | wx.TOP | wx.BOTTOM, 15)

        txt = wx.StaticText(panel, -1, "Hours of the Day")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 5)

        # another horizontal box
        box3 = wx.BoxSizer(wx.HORIZONTAL)
        vs.Add(box3, 0, wx.GROW | wx.LEFT | wx.TOP, 15)

        units = "hour of day"
        label = wx.StaticText(panel, -1, "From ")
        box3.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)
        self.le4 = wx.TextCtrl(panel, -1, "")
        box3.Add(self.le4, 0, wx.ALIGN_LEFT)
        label = wx.StaticText(panel, -1, " to ")
        box3.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)
        self.le5 = wx.TextCtrl(panel, -1, "")
        box3.Add(self.le5, 0, wx.ALIGN_LEFT)
        label = wx.StaticText(panel, -1, " %s." % units)
        box3.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)

        self.o4 = wx.CheckBox(panel, -1, "Use All Hours of Day")
        self.o4.SetValue(True)
        vs.Add(self.o4, 0, wx.ALIGN_LEFT | wx.LEFT, 15)

        self.lst2utc = wx.StaticText(panel, -1, "LST2UTC:")
        vs.Add(self.lst2utc, 1, wx.GROW | wx.LEFT | wx.TOP | wx.BOTTOM, 15)


#        rbList = []
#        for n, ht in enumerate(intakes):
#                rbList.append("%g" % ht)

#        self.intake = wx.RadioBox(
#                panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
#                rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
#                )
#               self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
#        vs.Add(self.intake, 0, wx.LEFT, 20)

        return panel

    # ----------------------------------
    def _options_config(self, intakes, lst2utc):
        """ update the options part of the dialog
        with new intake heights and time offset
        """

        httext = "Available heights: " + ", ".join([str(itk) for itk in intakes])
        self.avail_hts.SetLabel(httext)
        lst2utctext = "LST2UTC: " + str(lst2utc)
        self.lst2utc.SetLabel(lst2utctext)

        self.options_sizer.Layout()
        # resize the dialog
        win = self
        while win is not None:
            win.InvalidateBestSize()
            win = win.GetParent()
        wx.CallAfter(wx.GetTopLevelParent(self).Fit)

    # ----------------------------------
    def browse(self, event):
        """ Dialog to browse and select a file """

        dlg = wx.FileDialog(
            self, message="Choose a file", defaultDir=os.getcwd(),
            defaultFile="", style=wx.FD_OPEN | wx.FD_CHANGE_DIR
            )
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
            self.file.SetValue(paths[0])
#            intakes = getIntakeHeights(paths[0])
            intakes = ccg_ncdf.get_nc_variable(paths[0], 'intake_height', unique=True)
#            lst2utc = getLST2UTC(paths[0])
            lst2utc = ccg_ncdf.get_nc_attr(paths[0], 'site_utc2lst')
            self._options_config(intakes, lst2utc)

        dlg.Destroy()

    # ----------------------------------
    def ok(self, event):
        """ Ok button clicked, save chosen file name and end dialog """

        self.filename = self.file.GetValue()
        min_ht = self.le2.GetValue()
        max_ht = self.le3.GetValue()
        use_all = self.o3.GetValue()
        try:
            min_ht = float(min_ht)
        except ValueError:
            min_ht = None
        try:
            max_ht = float(max_ht)
        except ValueError:
            max_ht = None

        if use_all:
            self.min_ht = None
            self.max_ht = None
        else:
            self.min_ht = min_ht
            self.max_ht = max_ht

        min_hr = self.le4.GetValue()
        max_hr = self.le5.GetValue()
        use_all_hours = self.o4.GetValue()
        try:
            min_hr = float(min_hr)
        except ValueError:
            min_hr = None
        try:
            max_hr = float(max_hr)
        except ValueError:
            max_hr = None
        if use_all_hours:
            self.min_hr = None
            self.max_hr = None
        else:
            self.min_hr = min_hr
            self.max_hr = max_hr

        self.EndModal(wx.ID_OK)
