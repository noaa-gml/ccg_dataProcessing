# vim: tabstop=4 shiftwidth=4 expandtab
"""
Dialog for selecting a file to get data from.
Provides options for filtering the data based on its value
"""

import os
import wx

from .getimportdata import IMPORT_FORMATS, ImportData


##########################################################################
class ImportDialog(wx.Dialog):
    def __init__(self, parent=None, title="Import Data"):
        wx.Dialog.__init__(self, parent, -1, title)

        self.data = ImportData()

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        sizer = self.mkOptions()
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
        """ create widgets for selecting file format and file name """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Data Format")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.choice = wx.Choice(self, -1, choices=IMPORT_FORMATS)
        self.choice.SetSelection(0)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        # horizontal box
        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box2, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Filename:")
        box2.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.filename = wx.TextCtrl(self, -1, "", size=(250, -1))
        box2.Add(self.filename, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        btn = wx.Button(self, 1, "Browse...")
        self.Bind(wx.EVT_BUTTON, self.browse, btn)
        box2.Add(btn, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        return sizer

    # ----------------------------------
    def mkOptions(self):
        """ widget for filtering data """

        # -------------- second static box sizer
        box = wx.StaticBox(self, -1, "Options")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)

        # a horizontal box
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box1, 0, wx.GROW | wx.ALL, 2)

        label = wx.StaticText(self, -1, "Lines to Skip")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.sc = wx.SpinCtrl(self, -1, "")
        self.sc.SetRange(0, 10000)
        self.sc.SetValue(0)
        box1.Add(self.sc, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        # another horizontal box
        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer2.Add(box2, 0, wx.GROW | wx.ALL, 2)

        self.checkbox = wx.CheckBox(self, -1, "")
        box2.Add(self.checkbox, wx.ALIGN_LEFT)
        label = wx.StaticText(self, -1, "Use Data ")
        box2.Add(label, 0, wx.ALIGN_LEFT)
        optlist = ["less than", "equal to", "greater than", "less than or equal to",
                   "greater than or equal to", "not equal to", "between", "not between"]
        self.numtype = wx.Choice(self, -1, choices=optlist)
        self.numtype.SetSelection(0)
        box2.Add(self.numtype, 0, wx.ALIGN_LEFT)

        self.le2 = wx.TextCtrl(self, -1, "")
        box2.Add(self.le2, 0, wx.ALIGN_LEFT)

        label = wx.StaticText(self, -1, " and ")
        box2.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL)

        self.le3 = wx.TextCtrl(self, -1, "")
        box2.Add(self.le3, 0, wx.ALIGN_LEFT)

        return sizer2

    # ----------------------------------
    def browse(self, event):
        """ create filedialog for browsing file system """

        dlg = wx.FileDialog(
            self, message="Choose a file", defaultDir=os.getcwd(),
            defaultFile="", style=wx.FD_OPEN | wx.FD_CHANGE_DIR)
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
#            for path in paths:
#                print path
#                self.file.SetValue(path)
            self.filename.SetValue("|".join(paths))

        dlg.Destroy()

    # ----------------------------------
    def ok(self, event):

        filename = self.filename.GetValue()
        if not filename:
            dlg = wx.MessageDialog(self, "Please enter a file name.", 'A Message Box', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        if not os.access(filename, os.F_OK):
            msg = "Could not open file '%s'." % filename
            dlg = wx.MessageDialog(self, msg, 'Error', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        self.data.file_format = self.choice.GetStringSelection()

        self.data.skiplines = self.sc.GetValue()
        self.data.selectdata = self.checkbox.GetValue()
        self.data.numtype = self.numtype.GetStringSelection()
        val1 = 0
        val2 = 0
        value1 = self.le2.GetValue()
        if value1:
            val1 = float(value1)
        value2 = self.le3.GetValue()
        if value2:
            val2 = float(value2)

        self.data.value1 = val1
        self.data.value2 = val2

        self.data.filename = filename

        self.EndModal(wx.ID_OK)
