# vim: tabstop=4 shiftwidth=4 expandtab
"""
A dialog for setting the parameters used
in the ccgFilter curve fitting.
"""


import wx
import wx.lib.agw.floatspin as FS


#####################################################################
class ParametersDialog(wx.Dialog):
    """ A dialog for setting the parameters used in the ccgFilter curve fitting.  """

    def __init__(
            self, parent, parameters, title="Parameters", size=wx.Size(400, -1), pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
            ):
        wx.Dialog.__init__(self, parent, -1, title=title, pos=pos, style=style, size=size)

        self.parameters = parameters

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        # ------------------------------------------------
        nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT, size=size)
        box0.Add(nb, 0, wx.GROW | wx.ALL, 5)

        page = self.makeFunctionPage(nb)
        nb.AddPage(page, "Function")

        page = self.makeFilterPage(nb)
        nb.AddPage(page, "Filter")

        page = self.makeZeroDatePage(nb)
        nb.AddPage(page, "Zero Date")

        page = self.makeGapPage(nb)
        nb.AddPage(page, "Interpolation")

        page = self.makeSigmaPage(nb)
        nb.AddPage(page, "Outlier Sigma")

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # ------------------------------------------------
        # Dialog buttons
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

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    # ---------------------------------------------------------------
    def makeFunctionPage(self, nb):
        """ make notebook page for function settings """

        page = wx.Panel(nb, -1)

        box0 = wx.FlexGridSizer(0, 2, 2, 2)

        # -----
        label = wx.StaticText(page, -1, "Number of Polynomial Terms:")
        box0.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.npoly = wx.SpinCtrl(page, -1, str(self.parameters.npoly), size=(50, -1))
        box0.Add(self.npoly, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        label = wx.StaticText(page, -1, "Number of Yearly Harmonics:")
        box0.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.nharm = wx.SpinCtrl(page, -1, str(self.parameters.nharm), size=(50, -1))
        box0.Add(self.nharm, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        label = wx.StaticText(page, -1, "Include Amplitude Gain Factor in function")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

        self.gain_checkbox = wx.CheckBox(page, -1, "")
        box0.Add(self.gain_checkbox, 0, wx.ALIGN_LEFT)
        self.gain_checkbox.SetValue(self.parameters.gain)

        page.SetSizer(box0)

        return page

    # ---------------------------------------------------------------
    def makeFilterPage(self, nb):
        """ make notebook page for filter settings """

        page = wx.Panel(nb, -1)

        box0 = wx.FlexGridSizer(0, 2, 2, 2)

        # -----
        label = wx.StaticText(page, -1, "Sampling Interval (Days):")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.interval = wx.TextCtrl(page, -1, str(self.parameters.interval), size=(80, -1))
        box0.Add(self.interval, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        label = wx.StaticText(page, -1, "Short Term Cutoff Value (Days):")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.short = wx.TextCtrl(page, -1, str(self.parameters.short_cutoff), size=(80, -1))
        box0.Add(self.short, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        label = wx.StaticText(page, -1, "Long Term Cutoff Value (Days):")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.long = wx.TextCtrl(page, -1, str(self.parameters.long_cutoff), size=(80, -1))
        box0.Add(self.long, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        page.SetSizer(box0)
        return page

    # ---------------------------------------------------------------
    def makeZeroDatePage(self, nb):
        """ make notebook page for zero date settings """

        page = wx.Panel(nb, -1)

        box0 = wx.FlexGridSizer(0, 2, 2, 2)

        # -----
        label = wx.StaticText(page, -1, "Zero Date (Year):")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.zero = wx.TextCtrl(page, -1, str(self.parameters.zero), size=(80, -1))
        box0.Add(self.zero, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        page.SetSizer(box0)
        return page

    # ---------------------------------------------------------------
    def makeGapPage(self, nb):
        """ make notebook page for gap settings """

        page = wx.Panel(nb, -1)

        box0 = wx.FlexGridSizer(0, 2, 2, 2)

        # -----
        self.checkbox = wx.CheckBox(page, -1, "")
        box0.Add(self.checkbox, 0, wx.ALIGN_RIGHT)
        self.checkbox.SetValue(self.parameters.fill_gap)

        label = wx.StaticText(page, -1, "Fill large gaps with function values")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

        label = wx.StaticText(page, -1, "Gap Size (Days):")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.gap = wx.TextCtrl(page, -1, str(self.parameters.gap_size), size=(80, -1))
        box0.Add(self.gap, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        page.SetSizer(box0)

        return page

    # ---------------------------------------------------------------
    def makeSigmaPage(self, nb):
        """ make notebook page for +/- sigma values (used in flsel) """

        page = wx.Panel(nb, -1)

        box0 = wx.FlexGridSizer(0, 2, 2, 2)

        # -----
        label = wx.StaticText(page, -1, "Flag Data + Sigma:")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.sigmapos = FS.FloatSpin(page, -1,
                                     min_val=0.5, max_val=10, increment=0.1,
                                     value=self.parameters.sigmaplus,
                                     agwStyle=FS.FS_LEFT)
        self.sigmapos.SetDigits(1)
        box0.Add(self.sigmapos, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        label = wx.StaticText(page, -1, "Flag Data - Sigma:")
        box0.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.sigmaneg = FS.FloatSpin(page, -1,
                                     min_val=0.5, max_val=10, increment=0.1,
                                     value=self.parameters.sigmaminus,
                                     agwStyle=FS.FS_LEFT)
        self.sigmaneg.SetDigits(1)
        box0.Add(self.sigmaneg, 0, wx.ALIGN_LEFT | wx.ALL, 2)

        page.SetSizer(box0)
        return page

    # ---------------------------------------------------------------
    def apply(self, event):
        """ get the parameters and save """

        npoly = self.npoly.GetValue()
        nharm = self.nharm.GetValue()
        interval = self.interval.GetValue()
        shortco = self.short.GetValue()
        longco = self.long.GetValue()
        gain = self.gain_checkbox.GetValue()
        sigmapos = self.sigmapos.GetValue()
        sigmaneg = self.sigmaneg.GetValue()
        use_gap = self.checkbox.GetValue()
        gap_size = self.gap.GetValue()

        self.parameters.npoly = int(npoly)
        self.parameters.nharm = int(nharm)
        self.parameters.interval = int(interval)
        self.parameters.short_cutoff = float(shortco)
        self.parameters.long_cutoff = float(longco)
        self.parameters.gain = gain
        self.parameters.sigmaplus = float(sigmapos)
        self.parameters.sigmaminus = float(sigmaneg)
        self.parameters.use_gap = use_gap
        if not use_gap:
            self.parameters.gap_size = 0
        else:
            self.parameters.gap_size = float(gap_size)

    # ---------------------------------------------------------------
    def ok(self, event):
        """ ok button pressed.  save parameters and exit """
        self.apply(event)
        self.EndModal(wx.ID_OK)

    # ---------------------------------------------------------------
    def _cancel(self, evt):
        """cancel button pressed, exit """

        self.EndModal(wx.ID_CANCEL)
