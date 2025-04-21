# vim: tabstop=4 shiftwidth=4 expandtab
"""
A dialog for selecting the date of a latitude gradient from the mbl surface
"""

import wx

##########################################################################
class LatGradDialog(wx.Dialog):
    """ A dialog for selecting the date of a latitude gradient from the mbl surface """

    def __init__(self, parent=None, title="Latitdue Gradients"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

        self.timestep = None

        self.parent = parent

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkZones()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

#        sizer = self.mkBootstrap()
#        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)


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
        """ create a list of available timesteps for the latitude gradient """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Latitude Gradients")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL)

        label = wx.StaticText(self, -1, "Time Step")
        box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


        choices = []
        syncfile = self.parent.resultsdir + "/syncsteps"
        f = open(syncfile)
        for line in f:
            line = line.strip()
            choices.append(line)

        self.choice = wx.ListBox(self, -1, (-1, -1), (-1, -1), choices)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


        return sizer


    #----------------------------------
    def mkBootstrap(self):
        """ not used """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Bootstrap Runs")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)


        rbList = ["Atmospheric", "Network", "Measurement Bias"]

        bs = wx.RadioBox(
            self, -1, "", wx.DefaultPosition, wx.DefaultSize,
            rbList, 1, wx.RA_SPECIFY_COLS # | wx.NO_BORDER
            )
        sizer.Add(bs, 0, wx.LEFT, 20)

        label = wx.StaticText(self, -1, "Curve Type: ")
        sizer.Add(label, 0, wx.TOP, 10)

        choices = ["MBL", "Growth Rate", "Trend"]
        ct = wx.Choice(self, -1, choices=choices)
        sizer.Add(ct, 0, wx.LEFT, 20)


        label = wx.StaticText(self, -1, "Optional bootstrap results directory (leave blank to use default)")
        sizer.Add(label, 0, wx.TOP, 10)

        bsdir = wx.TextCtrl(self, -1)
        sizer.Add(bsdir, 1, wx.GROW|wx.LEFT, 20)


        return sizer

    #----------------------------------
    def ok(self, event):
        """ OK button clicked, save selections and end modal """

        self.timestep = self.choice.GetStringSelection()

        self.EndModal(wx.ID_OK)
