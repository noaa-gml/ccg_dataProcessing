# vim: tabstop=4 shiftwidth=4 expandtab
"""
A wx dialog for editing the axis parameters
"""

import wx

from .linetypes import *

TIC_NONE = 0
TIC_IN = 1
TIC_OUT = 2
TIC_IN_OUT = 3

#####################################################################3333
class AxisDialog(wx.Dialog):
    def __init__(
        self, parent, axis, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER
        ):

        wx.Dialog.__init__(self, parent, -1, title)

        self.graph = parent
        self.axis = axis

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)
        box0.Add(nb, 0, wx.GROW|wx.ALL, 5)

        page = self.makeAxisPage(nb)
        nb.AddPage(page, "Axis")

        page = self.makeScalePage(nb)
        nb.AddPage(page, "Scale")

        page = self.makeLabelsPage(nb)
        nb.AddPage(page, "Labels")

        page = self.makeTitlePage(nb)
        nb.AddPage(page, "Title")

        page = self.makeOriginPage(nb)
        nb.AddPage(page, "Origin")

        #------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        #------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_APPLY)
        self.Bind(wx.EVT_BUTTON, self.apply, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    #------------------------------------------------
    def makeAxisPage(self, nb):

        page = wx.Panel(nb, -1)

        box0 = wx.BoxSizer(wx.VERTICAL)

        #-----
        box = wx.StaticBox(page, -1, "Axis")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT)

        box1 = wx.GridSizer(4, 2, 1, 1)
        sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

        label = wx.StaticText(page, -1, "Color:")
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
        self.axis_color = wx.ColourPickerCtrl(page, -1, self.axis.color)
        box1.Add(self.axis_color, 0, wx.ALIGN_LEFT|wx.ALL, 0)

        label = wx.StaticText(page, -1, "Tic Type:")
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
        choicelist = ["None", "In", "Out", "In-Out"]
        self.ticType = wx.Choice(page, -1, choices=choicelist)
        self.ticType.SetStringSelection("In")
        box1.Add(self.ticType, 0, wx.ALIGN_LEFT|wx.ALL, 0)

        label = wx.StaticText(page, -1, "Line Width:")
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
        self.axis_linewidth = wx.SpinCtrl(page, -1, str(self.axis.lineWidth), size=(50, -1))
        box1.Add(self.axis_linewidth, 0, wx.ALIGN_LEFT|wx.ALL, 2)

        label = wx.StaticText(page, -1, "Tic Length:")
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
        self.axis_ticlength = wx.SpinCtrl(page, -1, str(self.axis.ticLength), size=(50, -1))
        box1.Add(self.axis_ticlength, 0, wx.ALIGN_LEFT|wx.ALL, 2)

        page.SetSizer(box0)
        return page

    #------------------------------------------------
    def makeScalePage(self, nb):

        page = wx.Panel(nb, -1)

        box0 = wx.BoxSizer(wx.VERTICAL)

        #-----
        box = wx.StaticBox(page, -1, "Scale")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT)

        self.autoscale = wx.CheckBox(page, -1, "Auto Scale")
        self.autoscale.SetValue(self.axis.autoscale)
        sizer2.Add(self.autoscale, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

        box = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
        label = wx.StaticText(page, -1, "From ")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.scale_from = wx.TextCtrl(page, -1, str(self.axis.min), size=(80, -1))
        box.Add(self.scale_from, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

        label = wx.StaticText(page, -1, " To ")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.scale_to = wx.TextCtrl(page, -1, str(self.axis.max), size=(80, -1))
        box.Add(self.scale_to, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

        label = wx.StaticText(page, -1, " Step ")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.scale_step = wx.TextCtrl(page, -1, str(self.axis.ticInterval), size=(80, -1))
        box.Add(self.scale_step, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

        box = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
        label = wx.StaticText(page, -1, "Minor Tics per Major Tic:")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.ntics = wx.SpinCtrl(page, -1, str(self.axis.subticDensity), size=(50, -1))
        box.Add(self.ntics, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

#        box = wx.BoxSizer(wx.HORIZONTAL)
#        sizer2.Add(box, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
#        label = wx.StaticText(page, -1, "Scale Type:")
#        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
#        list = ["Linear", "Logarithmic", "Time"]
 #               self.scaleType = wx.Choice(page, -1, choices=list)
        #!!! Needs fixing.
#        self.scaleType.SetStringSelection ("Linear")
#        box.Add(self.scaleType, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

        page.SetSizer(box0)
        return page

    #------------------------------------------------
    def makeLabelsPage(self, nb):

        page = wx.Panel(nb, -1)

        box0 = wx.BoxSizer(wx.VERTICAL)

        #-----
        box = wx.StaticBox(page, -1, "Labels")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT)

        self.show_labels = wx.CheckBox(page, -1, "Show Tic Labels")
        self.show_labels.SetValue(self.axis.show_labels)
        sizer2.Add(self.show_labels, wx.GROW|wx.ALIGN_LEFT|wx.ALL)

        box = wx.BoxSizer(wx.HORIZONTAL)
        label = wx.StaticText(page, -1, "Format:")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        choicelist = ["Auto", "Scientific", "Exponential"]
        self.labelFormat = wx.Choice(page, -1, choices=choicelist)
        #!!! Needs fixing.
        self.labelFormat.SetStringSelection("Auto")
        box.Add(self.labelFormat, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

        label = wx.StaticText(page, -1, "Precision:")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.prec = wx.SpinCtrl(page, -1, "0", size=(50, -1), max=10)
        box.Add(self.prec, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

        sizer2.Add(box, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

        label = wx.StaticText(page, -1, "Font:")
        box1.Add(label, 0, wx.ALL, 5)
        self.label_font = wx.FontPickerCtrl(page, style=wx.FNTP_USEFONT_FOR_LABEL)
        self.label_font.SetSelectedFont(self.axis.font.wxFont())
        box1.Add(self.label_font, wx.GROW|wx.ALL)

        label = wx.StaticText(page, -1, "Font Color:")
        box1.Add(label, 0, wx.ALL, 5)
        self.label_color = wx.ColourPickerCtrl(page, -1, self.axis.labelColor)
        box1.Add(self.label_color, 0, wx.ALL, 2)

        page.SetSizer(box0)
        return page

    #------------------------------------------------
    def makeTitlePage(self, nb):

        page = wx.Panel(nb, -1)

        box0 = wx.BoxSizer(wx.VERTICAL)

        #-----
        box = wx.StaticBox(page, -1, "Title")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT)

        box = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
        label = wx.StaticText(page, -1, "Title Text:")
        box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.title = wx.TextCtrl(page, -1, self.axis.title.text, size=(380, -1))
        box.Add(self.title, 1, wx.ALIGN_CENTRE|wx.ALL, 5)


        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

        label = wx.StaticText(page, -1, "Font:")
        box1.Add(label, 0, wx.ALL, 5)
        self.title_font = wx.FontPickerCtrl(page, style=wx.FNTP_USEFONT_FOR_LABEL)
        self.title_font.SetSelectedFont(self.axis.title.font.wxFont())
        box1.Add(self.title_font, wx.GROW|wx.ALL)

        label = wx.StaticText(page, -1, "Font Color:")
        box1.Add(label, 0, wx.ALL, 5)
        self.title_color = wx.ColourPickerCtrl(page, -1, self.axis.labelColor)
        box1.Add(self.title_color, 0, wx.ALL, 2)

        page.SetSizer(box0)
        return page

    #------------------------------------------------
    def makeOriginPage(self, nb):

        page = wx.Panel(nb, -1)

        box0 = wx.BoxSizer(wx.VERTICAL)

        #-----
        box = wx.StaticBox(page, -1, "Origin")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
        box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT)

        self.show_origin = wx.CheckBox(page, -1, "Show Origin Lines")
        self.show_origin.SetValue(self.axis.show_origin)
        sizer2.Add(self.show_origin, wx.GROW|wx.ALIGN_LEFT|wx.ALL, 2)

        box1 = wx.GridSizer(2, 2, 1, 1)
        sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

        label = wx.StaticText(page, -1, "Line Width:")
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
        self.origin_linewidth = wx.SpinCtrl(page, -1, str(self.axis.origin_width), size=(50, -1))
        box1.Add(self.origin_linewidth, 0, wx.ALIGN_LEFT|wx.ALL, 2)

        label = wx.StaticText(page, -1, "Line Color:")
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 5)
        self.origin_color = wx.ColourPickerCtrl(page, -1, self.axis.origin_color)
        box1.Add(self.origin_color, 0, wx.ALIGN_LEFT|wx.ALL, 2)

        page.SetSizer(box0)
        return page

    #---------------------------------------------------------------
    def ok(self, event):
        self.apply(event)
        self.EndModal(wx.ID_OK)

    #---------------------------------------------------------------
    def apply(self, event):

        # Axis values
        color = self.axis_color.GetColour()
        self.axis.color = color

        val = self.axis_linewidth.GetValue()
        self.axis.setAxisLineWidth(val)

        val = self.axis_ticlength.GetValue()
        self.axis.ticLength = val
        self.axis.subticLength = val/2

        val = self.ticType.GetStringSelection()
        if val == "In":
            tictype = TIC_IN
        elif val == "Out":
            tictype = TIC_OUT
        elif val == "In-Out":
            tictype = TIC_IN_OUT
        else:
            tictype = TIC_NONE
        self.axis.ticType = tictype

        # Scale values
        val = self.autoscale.GetValue()
        self.axis.autoscale = val

        val_from = self.scale_from.GetValue()
        val_to = self.scale_to.GetValue()
        val_step = self.scale_step.GetValue()
        if not self.axis.autoscale:
            self.axis.umin = float(val_from)
            self.axis.umax = float(val_to)
            self.axis.ticInterval = float(val_step)
            self.axis.exact = True

    #            print val_from, val_to, val_step
        else:
            self.axis.exact = False


        val = self.ntics.GetValue()
        if not self.axis.autoscale:
            self.axis.subticDensity = val

    #        val = self.scaleType.GetStringSelection()
    #        if val == "Linear":
    #            self.axis.scale_type = "linear"
    #        if val == "Time":
    #            self.axis.scale_type = "time"

        # Label values

        val = self.show_labels.GetValue()
        self.axis.show_labels = val

        val = self.labelFormat.GetStringSelection()
        f = "g"
        label_type = "auto"
        if val == "Scientific":
            f = "f"
        elif val == "Exponential":
            f = "e"

        val = self.prec.GetValue()
        if f == "g":
            fmt = "%g"
        else:
            fmt = "%%.%d%s" % (val, f)

        self.axis.labelFormat = fmt
        self.axis.labelType = label_type

        font = self.label_font.GetSelectedFont()
        self.axis.font.SetFont(font.GetPointSize(), font.GetFamily(), font.GetStyle(), font.GetWeight())
        print(self.axis.font.__dict__)
    #                self.axis.font = font

        color = self.label_color.GetColour()
        self.axis.labelColor = color

        # Axis title values
        val = self.title.GetValue()
        self.axis.title.text = val

        font = self.title_font.GetSelectedFont()
        self.axis.title.font.SetFont(font.GetPointSize(), font.GetFamily(), font.GetStyle(), font.GetWeight())

        color = self.title_color.GetColour()
        self.axis.title.color = color

        # Origin values
        val = self.show_origin.GetValue()
        self.axis.show_origin = val

        color = self.origin_color.GetColour()
        self.axis.origin_color = color

        val = self.origin_linewidth.GetValue()
        self.axis.origin_width = val

        self.graph.update()
