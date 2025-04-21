# vim: tabstop=4 shiftwidth=4 expandtab
"""
A dialog for getting data from the database
"""

import datetime
import numpy
import wx

import ccg_dbutils

from .getdata import GetData


##########################################################################
class GetDataDialog(wx.Dialog):
    """ A dialog for getting data from the database """

    def __init__(self, parent=None, title="Choose Dataset", flaskOnly=False, multiParameters=False, ccgvu=False):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER)

        self.data = GetData()
        self.flaskOnly = flaskOnly
        self.multiParameters = multiParameters
        self.ccgvu = ccgvu
        if self.flaskOnly:
            self.projects = {"Surface Flasks": 1, "Airborne Flasks": 2}
        else:
            self.projects = {"Surface Flasks": 1,
                             "Airborne Flasks": 2,
                             "Tall Tower": 3,
                             "Observatory": 4,
                             "Surface In-Situ": 5}

        self.db = ccg_dbutils.dbUtils()

        self.progbtns = []

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkProject()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

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

#        btnsizer = wx.StdDialogButtonSizer()
        btnsizer = wx.BoxSizer(wx.HORIZONTAL)

#        btn = wx.Button(self, wx.ID_CANCEL)
        btn = wx.Button(self, -1, "Cancel")
        self.Bind(wx.EVT_BUTTON, self._cancel, btn)
#        btnsizer.AddButton(btn)
        btnsizer.Add(btn)
#        btn = wx.Button(self, wx.ID_OK)
        btn = wx.Button(self, -1, "Ok")
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

#        btnsizer.AddButton(btn)
        btnsizer.Add(btn, 0, wx.LEFT | wx.RIGHT, 20)
#        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT | wx.ALL, 5)

#        self.Bind(wx.EVT_SHOW, self._show, self)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        self.choice.SetSelection(0)

    # ------------------------------------------------------------------------
#    def _show(self, evt):

#        print("show dialog")
#        self.db = ccg_dbutils.dbUtils()

    # ------------------------------------------------------------------------
    # ------------------------------------------------------------------------
    # create widget
    # ------------------------------------------------------------------------
    # ----------------------------------
    def mkProject(self):
        """ make project choice box """

        box1 = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, -1, "Project: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        # get list of keys sorted by value
        keylist = sorted(self.projects, key=self.projects.get)

        self.choice = wx.Choice(self, -1, choices=keylist)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.projChoice, self.choice)

        return box1

    # ----------------------------------
    def mkStation(self):
        """ make station combo box """

        box = wx.StaticBox(self, -1, "Sampling Site")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#        self.listbox = ExtendedChoice(self, -1, size=(555, -1))
        self.listbox = wx.ComboBox(self, -1, size=(555, -1), style=wx.CB_READONLY)
        self.station_config()

        szr.Add(self.listbox, 0, wx.ALIGN_LEFT | wx.ALL, 5)
#        self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)
        self.listbox.Bind(wx.EVT_COMBOBOX_CLOSEUP, self.stationSelected)

        return szr

    # ----------------------------------
    def mkParams(self):
        """ make parameters list box """

        box = wx.StaticBox(self, -1, "Parameters")
        box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

        if self.multiParameters:
            text = "Select one or more measurement parameters."
            self.label = wx.StaticText(self, -1, text)
            box1.Add(self.label, 0, wx.ALIGN_LEFT | wx.ALL, 5)

            text = "Use [shift] or [control] keys with mouse button to select more than 1 item.\n (6 maximum)"
            self.label = wx.StaticText(self, -1, text)
            box1.Add(self.label, 0, wx.ALIGN_LEFT | wx.ALL, 5)

            self.parambox = wx.ListBox(self, -1, style=wx.LB_EXTENDED, size=(500, 150))
            box1.Add(self.parambox, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        else:
            text = "Select a measurement parameter."
            self.label = wx.StaticText(self, -1, text)
            box1.Add(self.label, 0, wx.ALIGN_LEFT | wx.ALL, 5)

            self.parambox = wx.ListBox(self, -1, style=wx.LB_SINGLE, size=(500, 150))
            box1.Add(self.parambox, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

#        self.Bind(wx.EVT_LISTBOX, self.paramSelected, self.parambox)
#                self.parambox.Bind(wx.EVT_LISTBOX, self.paramSelected)
        self.param_config()

        return box1

    # ----------------------------------
    def mkTimeSpan(self):
        """ make time span spinners """

        box = wx.StaticBox(self, -1, "Time Span")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#        box1 = wx.FlexGridSizer(0,4,2,20)
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        szr.Add(box1)

        now = datetime.datetime.now()
        this_year = now.year

        label = wx.StaticText(self, -1, "Beginning Year:")
        box1.Add(label, 0, wx.LEFT | wx.RIGHT, 5)
        self.byear = wx.SpinCtrl(self, -1, "1967", min=1967, max=this_year, size=(100, -1))
        box1.Add(self.byear, 0, wx.ALIGN_LEFT | wx.RIGHT, 20)

        label = wx.StaticText(self, -1, "Ending Year:")
        box1.Add(label, 0, wx.LEFT | wx.RIGHT, 5)
        self.eyear = wx.SpinCtrl(self, -1, str(this_year), min=1967, max=this_year, size=(100, -1))
        box1.Add(self.eyear, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        return szr

    # ------------------------------------------------------------------------
    def mkOptions(self):
        """ make an options panel """

        box = wx.StaticBox(self, -1, "Data Options")
        self.boxx = box
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#        self.flask_sizer = wx.BoxSizer(wx.VERTICAL)
#        szr.Add(self.flask_sizer)
        panel = self.flask_options()
        szr.Add(panel)

#        self.tower_sizer = wx.BoxSizer(wx.VERTICAL)
#        szr.Add(self.tower_sizer)
#        panel = self.tower_options()
#        szr.Add(panel)

#        szr.Hide(panel)

        return szr

    # ------------------------------------------------------------------------
    # ------------------------------------------------------------------------
    # configuration
    # ------------------------------------------------------------------------
    # ----------------------------------
    def projChoice(self, event):
        """ project choice has changed """

        proj = event.GetString()
#        print("new project is", proj)
        if proj in self.projects:
            self.data.project = self.projects[proj]

        self.station_config()
# station_config will set new station, which will call param_config and option_config
        self.param_config()
        self.option_config()

    # ----------------------------------
    def station_config(self):
        """ update site list.
            called on creation and whenever project changes.
        """

#        print("setting station")
        project = self.data.project

        # surface in-situ uses project number 1, strategy 3 in data_summary
        if project == 5:
            sitelist = self.db.getSiteList(1, [3])
        else:
            sitelist = self.db.getSiteList(project, [1, 2])

        # Add the site names to a list.  But don't include
        # the 'binned' sites.
        value = None
        stations = []
        for row in sitelist:
            if len(row['code']) > 3:
                if row['code'][3] in ("S", "N", "0"):
                    continue

            txt = "%s - %s" % (row['code'], row['name'])
            stations.append(txt)
            if row['code'] == self.data.stacode:
                value = txt

        # if station not set, try setting to MLO
        if value is None:
            for s in stations:
                if "MLO" in s:
                    value = s
                    break

        # if mlo not available, set to first station in list
        if value is None:
            value = stations[0]

#        self.listbox.ReplaceAll(stations)
#        print(stations)
#        self.listbox.InsertItems(stations)
        self.listbox.Set(stations)
        self.listbox.SetValue(value)

        self.data.stacode = self.getStationCode()

    # ----------------------------------
    def stationSelected(self, event):
        """ station selection has changed.
            update parameters, time span and options
            with values relavent to selected station.
        """

#        print("in stationselected")
        self.data.stacode = self.getStationCode()
        self.param_config()
        self.option_config()

    # ----------------------------------
    def param_config(self):
        """ configure parameters """

        code = self.data.stacode
#        print("in param_config, code is", self.data.stacode)
        project = self.data.project
        if project == 5:
            plist = self.db.getParameterList(code, 1, [3])
        else:
            plist = self.db.getParameterList(code, project, [1, 2])

        if plist is None:
            self.parambox.Hide()
            return

#        print("plist is", plist)

        plist.append({'formula': 'tod', 'name': 'Time of Day', 'parameter_num': 0})

        self.parambox.Show()

        prev_param = []
        if self.multiParameters:
            zz = self.parambox.GetSelections()
            for idx in zz:
                prev_param.append(self.parambox.GetString(idx))
        else:
            zz = self.parambox.GetSelection()
            if zz >= 0:
                prev_param.append(self.parambox.GetString(zz))

        self.Unbind(wx.EVT_LISTBOX, self.parambox)
        self.parambox.Clear()
        param_strings = []
        for row in plist:
            s = "%s - %s" % (row['formula'], row['name'])
            param_strings.append(s)
            self.parambox.Append(s)

        # if previous selected parameter is in the new list, select it now
        idx = -1
        for s in prev_param:
            if s in param_strings:
                idx = param_strings.index(s)
                self.parambox.SetSelection(idx)
                self.data.paramname = plist[idx]['name']

        if idx < 0:
            self.parambox.SetSelection(0)
            self.data.paramname = plist[0]['name']

        self.Bind(wx.EVT_LISTBOX, self.paramSelected, self.parambox)

        return

    # ----------------------------------
    def paramSelected(self, event):
        """ A parameter has been selected/deselected """

        if self.multiParameters:
            self.data.parameter_list = []
            for i in self.parambox.GetSelections():
                s = self.parambox.GetString(i)
                (formula, name) = s.split('-', 1)
                formula = formula.strip()
                paramnum = self.db.getGasNum(formula)
                self.data.parameter_list.append(paramnum)
            if len(self.data.parameter_list) > 0:
                self.data.parameter = self.data.parameter_list[0]

        else:
            idx = self.parambox.GetSelection()
            s = self.parambox.GetString(idx)

            if "-" in s:
                (formula, name) = s.split('-', 1)
                formula = formula.strip()
                paramnum = self.db.getGasNum(formula)
                self.data.parameter_list = [paramnum]
                self.data.parameter = paramnum
                self.data.paramname = formula

        self.option_config()

    # ----------------------------------
    def getStationCode(self):
        """ get station code from selected value in station list box """

        s = self.listbox.GetValue()
#        print("in getStationCode, s is", s)
        code = None
        if '-' in s:
            code, name = s.split('-', 1)
            code = code.strip()

        return code

    # ------------------------------------------------------------------------
    def flask_options(self):
        """ set the flask options panel """

        panel = wx.Panel(self, -1)
        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        if not self.flaskOnly:
            txt = wx.StaticText(panel, -1, "Methods")
            vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

            self.methods_box = wx.FlexGridSizer(1, 13, 2, 2)
            vs.Add(self.methods_box, 0, wx.GROW | wx.LEFT, 20)

#            methods = ["A", "B", "C", "D", "F", "G", "H", "I", "N", "P", "R", "S", "T"]
            methods = self.db.getFlaskMethodList(self.data.stacode, self.data.project, self.data.parameter_list)
            for method in methods:
                mcb = wx.CheckBox(panel, -1, method)
                mcb.SetValue(1)
                self.methods_box.Add(mcb)

            if not self.ccgvu:
                self.f1a = wx.CheckBox(panel, -1, "Plot methods with different symbols")
                self.f1a.SetValue(self.data.flags_symbol)
                vs.Add(self.f1a, 0, wx.GROW | wx.LEFT, 20)
#            self.Bind(wx.EVT_CHECKBOX, self.get_soft_flags_symbol, self.f1a)

        # don't show flagging options if flaskOnly
        if not self.flaskOnly:
            txt = wx.StaticText(panel, -1, "Flagged Data")
            vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

            flags_box = wx.FlexGridSizer(2, 2, 2, 2)
            vs.Add(flags_box, 0, wx.GROW | wx.LEFT, 20)

            self.f2 = wx.CheckBox(panel, -1, "Include Data with Soft Flags")
            self.f2.SetValue(self.data.use_soft_flags)
            flags_box.Add(self.f2, 0, wx.GROW | wx.LEFT, 0)
            self.Bind(wx.EVT_CHECKBOX, self.get_soft_flag, self.f2)

            self.f3 = wx.CheckBox(panel, -1, "Include Data with Hard Flags")
            self.f3.SetValue(self.data.use_soft_flags)
            flags_box.Add(self.f3, 0, wx.GROW | wx.LEFT, 0)
            self.Bind(wx.EVT_CHECKBOX, self.get_hard_flag, self.f3)

            if not self.ccgvu:
                self.f2a = wx.CheckBox(panel, -1, "Plot flagged data with different symbol")
                self.f2a.SetValue(self.data.flags_symbol)
                flags_box.Add(self.f2a, 0, wx.GROW | wx.LEFT, 20)
                self.Bind(wx.EVT_CHECKBOX, self.get_soft_flags_symbol, self.f2a)

#                self.f3a = wx.CheckBox(panel, -1, "Plot flagged data with different symbol")
#                self.f3a.SetValue(self.data.soft_flags_symbol)
#                flags_box.Add(self.f3a, 0, wx.GROW|wx.LEFT, 20)
#                self.Bind(wx.EVT_CHECKBOX, self.get_hard_flags_symbol, self.f3a)

        # --------------------------

        result = self.db.getSitePrograms(self.data.stacode, self.data.parameter_list)
        if result is None:
            result = ({'program_num': 1, 'abbr': "CCGG", 'name': 'Carbon Cycle'},)

        txt = wx.StaticText(panel, -1, "Program")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

        progchoices = []
        for row in result:
            progchoices.append(row['abbr'])

        self.p2 = wx.CheckListBox(panel, -1, size=(-1, 55), choices=progchoices)
#        self.p2.SetValue(self.data.use_soft_flags)
        vs.Add(self.p2, 0, wx.GROW | wx.LEFT, 20)
#        self.Bind(wx.EVT_CHECKBOX, self.get_soft_flag, self.p2)

        for i in range(len(progchoices)):
            self.p2.Check(i, True)

        # --------------------------

        txt = wx.StaticText(panel, -1, "Strategies")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

        self.o1 = wx.CheckBox(panel, -1, "Individual Flasks")
        vs.Add(self.o1, 0, wx.GROW | wx.LEFT, 20)

        self.o2 = wx.CheckBox(panel, -1, "Programmable Flask Package")
        vs.Add(self.o2, 0, wx.GROW | wx.LEFT, 20)

        # Check if more than 1 strategy for this site
        result = self.db.getStrategies(self.data.stacode, [self.data.project])

        if 1 in result:
            self.o1.Enable(True)
            self.o1.SetValue(True)
        else:
            self.o1.Enable(False)
            self.o1.SetValue(False)

        if 2 in result:
            self.o2.Enable(True)
            self.o2.SetValue(True)
        else:
            self.o2.Enable(False)
            self.o2.SetValue(False)

        # check on bin options
        (c, binmethod) = self._get_bin_choices()
        if c is None:
            return panel

        if binmethod == "alt":
            units = "meters"
            bintype = "altitude"
        else:
            units = "degrees"
            bintype = "latitude"

        txt = wx.StaticText(panel, -1, "Binning")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

        # -----
        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        vs.Add(box1, 0, wx.GROW | wx.ALL, 5)

        t = wx.StaticText(panel, -1, "Select a default %s range:" % bintype)
        box1.Add(t, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.LEFT, 20)

        self.bin = wx.Choice(panel, -1, choices=c)
        self.bin.SetSelection(0)
        box1.Add(self.bin, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

        t = wx.StaticText(panel, -1, "OR specify %s range:" % bintype)
        box1.Add(t, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.LEFT, 20)

        # another horizontal box
        box2 = wx.BoxSizer(wx.HORIZONTAL)
        box1.Add(box2, 0, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

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

        t = wx.StaticText(panel, -1, "OR ")
        box1.Add(t, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.LEFT, 20)
#        self.o3 = wx.CheckBox(panel, -1, "OR Use All Data")
        self.o3 = wx.CheckBox(panel, -1, "Use All Data")
        self.o3.SetValue(False)
        box1.Add(self.o3, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

        return panel

    # ----------------------------------
    def _get_bin_choices(self):
        """ getting any binning options for the site """

        result = self.db.getBinInfo(self.data.stacode, self.data.project)
        if result is None and self.data.project != 2:
            return None, None

        c = []
        if result:
            for row in result:
                s = self._get_bin_choice_label(row['method'], row['min'], row['max'], row['width'])
                method = row['method']
                c.extend(s)
        else:
            method = "alt"
            binmin = 1000
            binmax = 8000
            width = 2000
            s = self._get_bin_choice_label(method, binmin, binmax, width)
            c.extend(s)

        return c, method

    # ----------------------------------
    def _get_bin_choice_label(self, method, binmin, binmax, width):
        """ create the label for a bin option """

        labels = []
        if method == "alt":
            units = "meters"
        else:
            units = "degrees"

        self.data.bin_method = method

        if width == 0:
            s = "From %s %s to %s %s" % (binmin, units, binmax, units)
            labels.append(s)
        else:
            for center in numpy.arange(binmin, binmax+width, width):
                low = center-width/2
                high = center+width/2
                s = "From %s %s to %s %s" % (low, units, high, units)
                labels.append(s)

        return labels

    # ----------------------------------
    def tower_options(self):
        """ set the tower options panel """

        panel = wx.Panel(self, -1)

        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        txt = wx.StaticText(panel, -1, "Intake Heights")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

        tlist = self.db.getIntakeHeights(self.data.stacode, self.data.paramname)
        rbList = [str(ht) for ht in tlist]

        self.intake = wx.RadioBox(
            panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
            rbList, 1, wx.RA_SPECIFY_COLS  # | wx.NO_BORDER
            )
#        self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
        vs.Add(self.intake, 0, wx.LEFT, 20)

        if self.data.stacode.lower() == "cao":
            txt = wx.StaticText(panel, -1, "Data Averages")
            vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

            rbList = ["Monthly Averages", "Daily Averages", "Hourly Averages"]
            self.obs = wx.RadioBox(
                panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
                rbList, 1, wx.RA_SPECIFY_COLS  # | wx.NO_BORDER
                )
    #        self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
            vs.Add(self.obs, 0, wx.LEFT, 20)

        return panel

    # ----------------------------------
    def obs_options(self):
        """ set the observatory options panel """

        panel = wx.Panel(self, -1)

        vs = wx.BoxSizer(wx.VERTICAL)
        panel.SetSizer(vs)

        txt = wx.StaticText(panel, -1, "Data Averages")
        vs.Add(txt, 0, wx.LEFT | wx.TOP, 10)

        rbList = ["Monthly Averages", "Daily Averages", "Hourly Averages"]
        self.obs = wx.RadioBox(
            panel, -1, "", wx.DefaultPosition, wx.DefaultSize,
            rbList, 1, wx.RA_SPECIFY_COLS  # | wx.NO_BORDER
            )
#        self.Bind(wx.EVT_RADIOBOX, self.get_rb, self.rb)
        vs.Add(self.obs, 0, wx.LEFT, 20)

        self.obsf2 = wx.CheckBox(panel, -1, "Include Data with Soft Flags")
        self.obsf2.SetValue(False)
        vs.Add(self.obsf2, 0, wx.GROW | wx.LEFT, 20)

        self.obsf2a = wx.CheckBox(panel, -1, "Plot flagged data with different symbols")
        self.obsf2a.SetValue(self.data.flags_symbol)
        vs.Add(self.obsf2a, 0, wx.GROW | wx.LEFT, 40)
#        self.Bind(wx.EVT_CHECKBOX, self.get_soft_flags_symbol, self.obsf2a)

        return panel

    # ----------------------------------
    def option_config(self):
        """ update the options panel, depending on project """

        self.data.bin_method = None
        self.data.bin_data = False

        self.options_sizer.Clear(True)
        if self.data.project in [1, 2]:

            panel = self.flask_options()

        elif self.data.project == 3:

            panel = self.tower_options()

        elif self.data.project == 4:

            panel = self.obs_options()

        elif self.data.project == 5:
            panel = self.tower_options()

        else:
            print("how did i get here?")

        self.options_sizer.Add(panel)
        self.options_sizer.Layout()

        # resize the dialog
        win = self
        while win is not None:
            win.InvalidateBestSize()
            win = win.GetParent()
        wx.CallAfter(wx.GetTopLevelParent(self).Fit)

    # ----------------------------------
    def get_soft_flag(self, event):
        """ get value of soft flags checkbox """

        self.data.use_soft_flags = self.f2.GetValue()

    # ----------------------------------
    def get_soft_flags_symbol(self, event):
        """ get value of soft flags symbol checkbox """

        self.data.flags_symbol = self.f2a.GetValue()

    # ----------------------------------
    def get_hard_flag(self, event):
        """ get value of hard flags checkbox """

        self.data.use_hard_flags = self.f3.GetValue()

    # ----------------------------------
    def get_hard_flags_symbol(self, event):
        """ get value of hard flags symbol checkbox """

        self.data.hard_flags_symbol = self.f3a.GetValue()

    # ----------------------------------
    def ok(self, event):
        """
        Get all the values from the dialog and store them in self.data
            project
            stacode
            parameter
            begyear
            endyear
            options:
                flask:
                    plot soft flags
                    plot soft flags with different symbol
                    regular flasks
                    pfp flasks
                    binning:
                tower:
                    intake_ht
                insitu:
                    monthly averages
                    daily averages
                    hourly averages
        """

        self.data.stacode = self.getStationCode()
        self.data.sitenum = self.db.getSiteNum(self.data.stacode)

        self.data.byear = self.byear.GetValue()
        self.data.eyear = self.eyear.GetValue()

        if self.multiParameters:
            self.data.parameter_list = []
            for i in self.parambox.GetSelections():
                s = self.parambox.GetString(i)
                (formula, name) = s.split('-', 1)
                formula = formula.strip()
                paramnum = self.db.getGasNum(formula)
                self.data.parameter_list.append(paramnum)
            self.data.parameter = self.data.parameter_list[0]
        else:
            s = self.parambox.GetStringSelection()
            (formula, name) = s.split('-', 1)
            formula = formula.strip()
            paramnum = self.db.getGasNum(formula)
            self.data.parameter = paramnum
            self.data.paramname = formula

        if self.data.project in [1, 2]:
            self.data.use_flask = self.o1.GetValue()
            self.data.use_pfp = self.o2.GetValue()

            if not self.data.use_flask and not self.data.use_pfp:
                msg = "Must select at least one flask type."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

            # methods
            self.data.methods = []
            if not self.flaskOnly:
                clist = self.methods_box.GetChildren()
                for cb in clist:
                    w = cb.GetWindow()
                    if w.GetValue():
#                        method = "'" + w.GetLabel() + "'"
                        method = w.GetLabel()
                        self.data.methods.append(method)

                if not self.ccgvu:
                    self.data.methods_symbol = self.f1a.GetValue()

            # programs
            progs = self.p2.GetCheckedStrings()
#            print("programs are", progs)
            self.data.programs = [self.db.getProgramNum(prog) for prog in progs]
#            print(self.data.programs)

#            self.data.use_hard_flags = self.f1.GetValue()
            if not self.flaskOnly:
                self.data.use_soft_flags = self.f2.GetValue()
                self.data.use_hard_flags = self.f3.GetValue()
                if not self.ccgvu:
                    self.data.flags_symbol = self.f2a.GetValue()
#                if not self.ccgvu:
#                    self.data.hard_flags_symbol = self.f3a.GetValue()

            # binning
            if self.data.bin_method:
                val = self.o3.GetValue()  # use all data
                if val:
                    self.data.min_bin = 0
                    self.data.max_bin = 0
                    self.data.bin_data = False
                else:
                    self.data.bin_data = True
                    _min = self.le2.GetValue()
                    _max = self.le3.GetValue()
                    if _min == "" and _max == "":
                        s = self.bin.GetStringSelection()
                        result = s.split()
                        self.data.min_bin = float(result[1])
                        self.data.max_bin = float(result[4])
                    else:
                        self.data.min_bin = float(_min)
                        self.data.max_bin = float(_max)

        # tower
        elif self.data.project == 3 or self.data.project == 5:
            n = self.intake.GetStringSelection()
            self.data.intake_ht = float(n)
            if self.data.stacode.lower() == "cao":
                s = self.obs.GetStringSelection()
                if "Hourly" in s:
                    self.data.obs_avg = "Hourly"
                elif "Daily" in s:
                    self.data.obs_avg = "Daily"
                elif "Monthly" in s:
                    self.data.obs_avg = "Monthly"
            else:
                self.data.obs_avg = "Hourly"

        # observatory
        elif self.data.project == 4:
            s = self.obs.GetStringSelection()
            if "Hourly" in s:
                self.data.obs_avg = "Hourly"
            elif "Daily" in s:
                self.data.obs_avg = "Daily"
            elif "Monthly" in s:
                self.data.obs_avg = "Monthly"
#            self.data.obs_avg = s
            self.data.use_soft_flags = self.obsf2.GetValue()
            self.data.flags_symbol = self.obsf2a.GetValue()


#        self.db.close()
        self.EndModal(wx.ID_OK)

    def _cancel(self, evt):

        self.EndModal(wx.ID_CANCEL)
