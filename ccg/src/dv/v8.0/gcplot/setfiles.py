# vim: tabstop=4 shiftwidth=4 expandtab

"""
dialog for setting the timefile and peak id files for chromatogram, or
setting the data directory for finding timefile and pead id file.
"""


import os
import wx

from common.validators import V_STRING, checkVal

##########################################################################
class SetFilesDialog(wx.Dialog):
    """ A dialog for selecting the time file and pead id file for a chromatogram,
    or for setting the directory to search for the time file and id file.
    """

    def __init__(self, parent=None, title="Set Integration Files", pos=wx.DefaultPosition, size=(650, -1)):
        wx.Dialog.__init__(self, parent, -1, title, pos, size, style=wx.RESIZE_BORDER)

        self.parent = parent
        self.use_files = 1
        self.timefile = ""
        self.peakidfile = ""
        self.datadir = ""

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 1, wx.EXPAND|wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.EXPAND|wx.RIGHT|wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        self.SetSize((500, -1))

    #----------------------------------
    def mkSource(self):
        """ Create the file selection boxes """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Integration Files")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        #--------------------------------
        radio1 = wx.RadioButton(self, -1, "Specify File Names")
        sizer.Add(radio1, 0, wx.ALL, 2)
        self.Bind(wx.EVT_RADIOBUTTON, self.Radio1Select, radio1)

        box1a = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1a, 1, wx.EXPAND|wx.LEFT, 15)

        self.label1a = wx.StaticText(self, -1, "Time File:")
        box1a.Add(self.label1a, 0, wx.ALL, 1)

        self.fp1 = wx.FilePickerCtrl(self, style=wx.FLP_USE_TEXTCTRL)
        self.fp1.SetTextCtrlProportion(1)
        box1a.Add(self.fp1, 1, wx.ALIGN_CENTRE|wx.ALL, 1)

        box1b = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1b, 1, wx.EXPAND|wx.LEFT, 15)

        self.label1b = wx.StaticText(self, -1, "Peak ID File:")
        box1b.Add(self.label1b, 0, wx.ALL, 1)

        self.fp2 = wx.FilePickerCtrl(self, style=wx.FLP_USE_TEXTCTRL)
        self.fp2.SetTextCtrlProportion(2)
        box1b.Add(self.fp2, 1, wx.ALIGN_CENTRE|wx.ALL, 1)

        #--------------------------------
        radio2 = wx.RadioButton(self, -1, "Auto Search for Files")
        sizer.Add(radio2, 0, wx.EXPAND|wx.ALL, 2)
        self.Bind(wx.EVT_RADIOBUTTON, self.Radio2Select, radio2)

        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box2, 1, wx.EXPAND|wx.LEFT, 15)

        self.label2 = wx.StaticText(self, -1, "Directory:")
        box2.Add(self.label2, 0, wx.ALIGN_CENTRE|wx.ALL, 1)

        self.dp2 = wx.DirPickerCtrl(self, style=wx.DIRP_USE_TEXTCTRL)
        self.dp2.SetTextCtrlProportion(1)
        box2.Add(self.dp2, 1, wx.ALIGN_CENTRE|wx.ALL, 1)

        self.label2.Enable(False)
        self.dp2.Enable(False)

        return sizer


    #----------------------------------
    def Radio1Select(self, event):
        """ Enable the boxes for selecting individual files """

        self.label1a.Enable(True)
        self.fp1.Enable(True)
        self.label1b.Enable(True)
        self.fp2.Enable(True)

        self.label2.Enable(False)
        self.dp2.Enable(False)

        self.use_files = 1

    #----------------------------------
    def Radio2Select(self, event):
        """ Enable the boxes for selecting directory """

        self.label1a.Enable(False)
        self.fp1.Enable(False)
        self.label1b.Enable(False)
        self.fp2.Enable(False)

        self.label2.Enable(True)
        self.dp2.Enable(True)

        self.use_files = 0

    #----------------------------------
    def ok(self, event):
        """ OK button clicked, check entries and set file names """

        if self.use_files:
            # Get and test timefile access
            self.timefile = self.fp1.GetPath()
            valid = checkVal(self.fp1, self.timefile, V_STRING)
            if not valid:
                return
            if not os.access(self.timefile, os.F_OK):
                msg = "Could not open file 'f{self.timefile}'."
                dlg = wx.MessageDialog(self, msg, 'Error', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

            # Get and test peadidfile access
            self.peakidfile = self.fp2.GetPath()
            valid = checkVal(self.fp2, self.peakidfile, V_STRING)
            if not valid:
                return
            if not os.access(self.peakidfile, os.F_OK):
                msg = "Could not open file 'f{self.peakidfile}'."
                dlg = wx.MessageDialog(self, msg, 'Error', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return
        else:
            # Get and test directory access
            self.datadir = self.dp2.GetPath()
            valid = checkVal(self.dp2, self.datadir, V_STRING)
            if not valid:
                return
            if not os.access(self.datadir, os.F_OK):
                msg = "Could not open file 'f{self.datadir}'."
                dlg = wx.MessageDialog(self, msg, 'Error', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

        self.EndModal(wx.ID_OK)
