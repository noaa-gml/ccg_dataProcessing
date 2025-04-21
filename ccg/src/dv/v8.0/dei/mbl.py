# vim: tabstop=4 shiftwidth=4 expandtab
"""
Dialog for selecting pre-defined zones from the mbl surface
"""

import wx

##########################################################################
class MblDialog(wx.Dialog):
    """ Dialog for selecting pre-defined zones from the mbl surface """

    def __init__(self, parent=None, title="Import MBL Data"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

        self.zone = None
        self.data_type = None

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkZones()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)


    #----------------------------------
    def mkZones(self):
        """ create a choice of the pre-defined zone names """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Zones")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL)

        label = wx.StaticText(self, -1, "Zone: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


        zonal_options = [
            u"Global (90\u00b0S to 90\u00b0N)",
            u"Northern Hemisphere (0\u00b0 to 90\u00b0N)",
            u"Southern Hemisphere (90\u00b0S to 0\u00b0)",
            u"Arctic (58.2\u00b0N to 90\u00b0N)",
            u"Polar Northern Hemisphere (53.1\u00b0N to 90\u00b0N)",
            u"High Northern Hemisphere (30\u00b0N to 90\u00b0N)",
            u"Temperate Northern Hemisphere (17.5\u00b0N to 53.1\u00b0N)",
            u"Low Northern Hemisphere (0\u00b0 to 30\u00b0N)",
            u"Tropics (17.5\u00b0S to 17.5\u00b0N)",
            u"Equatorial (14.5\u00b0S to 14.5\u00b0N)",
            u"Low Southern Hemisphere (30\u00b0S to 0\u00b0)",
            u"Temperate Southern Hemisphere (53.1\u00b0S to 17.5\u00b0S)",
            u"High Southern Hemisphere (90\u00b0S to 30\u00b0S)",
            u"Polar Southern Hemisphere (90\u00b0S to 53.1\u00b0S)",
        ]


        self.choice = wx.Choice(self, -1, choices=zonal_options)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.choice.SetSelection(0)


        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box2, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL)

        label = wx.StaticText(self, -1, "Data Type: ")
        box2.Add(label, 0, wx.TOP, 10)

        choices = ["MBL", "Annual Averages", "Annual Increase of Trend"]
        self.ct = wx.Choice(self, -1, choices=choices)
        box2.Add(self.ct, 0, wx.LEFT, 20)
        self.ct.SetSelection(0)


        return sizer


    #----------------------------------
    def ok(self, event):
        """ OK button clicked, save selections and end modal """

        self.zone = self.choice.GetStringSelection()
        self.data_type = self.ct.GetStringSelection()

        self.EndModal(wx.ID_OK)
