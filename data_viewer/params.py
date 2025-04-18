# vim: tabstop=4 shiftwidth=4 expandtab
""" A dialog for entering the parameters used in a response curve calibration """

import wx


#####################################################################
class ParametersDialog(wx.Dialog):
    """ A dialog for entering the parameters used in a response curve calibration """

    def __init__(
        self, parent, ID=-1, title="Parameters", size=wx.DefaultSize, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER):

        wx.Dialog.__init__(self, parent, ID, title, size=size, pos=pos, style=style)

        self.use_odr = 1
        self.use_sigma = 0
        self.no_x = 0
        self.no_y = 0
        self.order = 2
        self.functype = "poly"
        self.exclude = ""

        self.nldata = parent.orig_nldata

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        # ------------------------------------------------

        self.d1 = wx.CheckBox(self, -1, "Use ODR Fit")
        self.d1.SetValue(1)
        box0.Add(self.d1, 0, wx.GROW | wx.ALL, 2)

        self.s1 = wx.CheckBox(self, -1, "Use 1/variance weighting")
        self.s1.SetValue(0)
        box0.Add(self.s1, 0, wx.GROW | wx.LEFT, 20)

        self.s2 = wx.CheckBox(self, -1, "Do not use X weighting")
        self.s2.SetValue(0)
        box0.Add(self.s2, 0, wx.GROW | wx.LEFT, 20)

        self.s3 = wx.CheckBox(self, -1, "Do not use Y weighting")
        self.s3.SetValue(0)
        box0.Add(self.s3, 0, wx.GROW | wx.LEFT, 20)

        # -----

        box = wx.StaticBox(self, -1, "Exclude STD Tanks")
        szr = wx.StaticBoxSizer(box, wx.HORIZONTAL)
        box0.Add(szr, 0, wx.GROW | wx.ALL, 2)

        box1 = wx.FlexGridSizer(0, 4, 2, 2)
        self.stdbtns = []
        for key in sorted(self.nldata.refgas.keys()):
            if key != "R0":
                btn = wx.CheckBox(self, -1, key)
                self.stdbtns.append(btn)
                box1.Add(btn, 0, wx.LEFT, 2)
        szr.Add(box1)

        box = wx.StaticBox(self, -1, "Function Type")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(szr, 0, wx.GROW | wx.ALL, 2)

        self.sampleList = ['Polynomial', 'Power']
        self.rb = wx.RadioBox(
            self, -1, "", wx.DefaultPosition, wx.DefaultSize,
            self.sampleList, 1, wx.RA_SPECIFY_COLS | wx.NO_BORDER
            )
        szr.Add(self.rb, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        box2 = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, -1, "Polynomial Order:")
        box2.Add(label, 0, wx.ALIGN_LEFT | wx.LEFT, 5)
        self.npoly = wx.SpinCtrl(self, -1, "2", size=(50, -1))
        box2.Add(self.npoly, 0, wx.ALIGN_LEFT | wx.LEFT, 5)

        szr.Add(box2)

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # ------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    # ---------------------------------------------------------------
    def ok(self, event):
        """ save the parameters and end dialog """

        self.use_odr = self.d1.GetValue()
        self.use_sigma = self.s1.GetValue()
        self.no_x = self.s2.GetValue()
        self.no_y = self.s3.GetValue()
        self.order = self.npoly.GetValue()
        n = self.rb.GetSelection()
        ftype = self.rb.GetString(n)
        if ftype == "Polynomial":
            ftype = "poly"
        elif ftype == "Power":
            ftype = "power"
        self.functype = ftype

        nulltanks = []
        for btn in self.stdbtns:
            if btn.IsChecked():
                key = btn.GetLabel()
                sn, mr, unc = self.nldata.refgas[key]
                nulltanks.append(sn)

        self.exclude = ",".join(nulltanks)

        self.EndModal(wx.ID_OK)
