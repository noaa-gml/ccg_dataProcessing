# vim: tabstop=4 shiftwidth=4 expandtab
import wx

##########################################################################
class BsMblDialog(wx.Dialog):
    def __init__(self, parent=None, title="Import MBL Data", graph=None):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

        self.graph = graph

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkZones(box0)
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        sizer = self.mkBootstrap(box0)
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)


        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)

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
    def mkZones(self, box0):

        # First static box sizer
        box = wx.StaticBox(self, -1, "Zones")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL)

        label = wx.StaticText(self, -1, "Reference Type")
        box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


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
        ]


        self.choice = wx.Choice(self, -1, choices=zonal_options)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


        return sizer


    #----------------------------------
    def mkBootstrap(self, box0):

        # First static box sizer
        box = wx.StaticBox(self, -1, "Bootstrap Runs")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)


        rbList = ["Atmospheric", "Network", "Measurement Bias"]

        self.bs = wx.RadioBox(
            self, -1, "", wx.DefaultPosition, wx.DefaultSize,
            rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
            )
        sizer.Add(self.bs, 0, wx.LEFT, 20)

        label = wx.StaticText(self, -1, "Curve Type: ")
        sizer.Add(label, 0, wx.TOP, 10)

        choices = ["MBL", "Growth Rate", "Trend"]
        self.ct = wx.Choice(self, -1, choices=choices)
        sizer.Add(self.ct, 0, wx.LEFT, 20)


        label = wx.StaticText(self, -1, "Optional bootstrap results directory (leave blank to use default)")
        sizer.Add(label, 0, wx.TOP, 10)

        self.bsdir = wx.TextCtrl(self, -1)
        sizer.Add(self.bsdir, 1, wx.GROW|wx.LEFT, 20)


        return sizer

    #----------------------------------
    def ok(self, event):


        self.zone = self.choice.GetStringSelection()
#        print zone

        self.bootstrap_dir = self.bsdir.GetValue()

        s = self.bs.GetStringSelection()
        if "bias" in s.lower():
            s = "bias"
        self.bootstrap = s
        print(self.bootstrap)

        self.curve_type = self.ct.GetStringSelection()


        self.EndModal(wx.ID_OK)
