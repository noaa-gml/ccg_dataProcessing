# vim: tabstop=4 shiftwidth=4 expandtab
"""
a dialog for selecting mbl zone
"""

import wx


##########################################################################
class MblDialog(wx.Dialog):
    """ a dialog for selecting mbl zone """

    def __init__(self, parent=None, title="Import MBL Data"):
        wx.Dialog.__init__(self, parent, -1, title)

        # data to select and save
        self.min_latitude = -90
        self.max_latitude = 90
        self.param = "CO2"
        self.zone = "Global"

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkLatitudeRange()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkParams()
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
    def mkSource(self):
        """ create a choice for picking the mbl zone """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Reference Type")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        zonal_options = [
            "Global (90\u00b0S to 90\u00b0N)",
            "Northern Hemisphere (0\u00b0 to 90\u00b0N)",
            "Southern Hemisphere (90\u00b0S to 0\u00b0)",
            "Arctic (58.2\u00b0N to 90\u00b0N)",
            "Polar Northern Hemisphere (53.1\u00b0N to 90\u00b0N)",
            "High Northern Hemisphere (30\u00b0N to 90\u00b0N)",
            "Temperate Northern Hemisphere (17.5\u00b0N to 53.1\u00b0N)",
            "Low Northern Hemisphere (0\u00b0 to 30\u00b0N)",
            "Tropics (17.5\u00b0S to 17.5\u00b0N)",
            "Equatorial (14.5\u00b0S to 14.5\u00b0N)",
            "Low Southern Hemisphere (30\u00b0S to 0\u00b0)",
            "Temperate Southern Hemisphere (53.1\u00b0S to 17.5\u00b0S)",
            "High Southern Hemisphere (90\u00b0S to 30\u00b0S)",
            "Polar Southern Hemisphere (90\u00b0S to 53.1\u00b0S)",
            "Custom",
        ]

        self.choice = wx.Choice(self, -1, choices=zonal_options)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.choice.SetSelection(0)

        self.choice.Bind(wx.EVT_CHOICE, self._set_zone)

        return sizer

    # ----------------------------------
    def mkParams(self):
        """ create a choice for the mbl parameter """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Parameters")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Parameter")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        param_options = [
            "co2 - Carbon Dioxide",
            "ch4 - Methane",
            "co - Carbon Monoxide",
            "n2o - Nitrous Oxide",
            "sf6 - Sulfur Hexaflouride",
            "co2c13 - Carbon-13/Carbon-12 in Carbon Dioxide",
            #            "ch4c13 - Carbon-13/Carbon-12 in Methane",
        ]

        self.param_choice = wx.Choice(self, -1, choices=param_options)
        box1.Add(self.param_choice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.param_choice.SetSelection(0)

        return sizer

    # ----------------------------------
    def mkLatitudeRange(self):
        """ create input boxes for setting custom zone latitudes """

        self.latbox = wx.StaticBox(self, -1, "Custom Latitude Range")
        szr = wx.StaticBoxSizer(self.latbox, wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        szr.Add(box1)

        self.label1 = wx.StaticText(self, -1, "Minimum")
        box1.Add(self.label1, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.minlat = wx.TextCtrl(self, -1, "-90")
        box1.Add(self.minlat, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        self.label2 = wx.StaticText(self, -1, "Maximum")
        box1.Add(self.label2, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.maxlat = wx.TextCtrl(self, -1, "90")
        box1.Add(self.maxlat, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        self.minlat.Enable(False)
        self.maxlat.Enable(False)
        self.latbox.Enable(False)
        self.label1.Enable(False)
        self.label2.Enable(False)

        return szr

    # ----------------------------------
    def _set_zone(self, event):
        """ If 'custom' zone is chosen, enable the
        latitude range boxes, otherwise disable them.
        """

        reftype = self.choice.GetStringSelection()
        if reftype == "Custom":
            self.minlat.Enable(True)
            self.maxlat.Enable(True)
            self.latbox.Enable(True)
            self.label1.Enable(True)
            self.label2.Enable(True)
        else:
            self.minlat.Enable(False)
            self.maxlat.Enable(False)
            self.latbox.Enable(False)
            self.label1.Enable(False)
            self.label2.Enable(False)

    # ----------------------------------
    def ok(self, event):
        """ ok button clicked.  get settings and exit """

        zone = self.choice.GetStringSelection()
        self.zone = zone

        param = self.param_choice.GetStringSelection()
        (formula, name) = param.split("-", 1)
        self.param = formula.strip().lower()

        self.min_latitude = float(self.minlat.GetValue())
        self.max_latitude = float(self.maxlat.GetValue())

        self.EndModal(wx.ID_OK)
