# vim: tabstop=4 shiftwidth=4 expandtab
""" A dialog for entering/browsing response curve file names and
refgas.tab file names.
"""

import os
import wx


##########################################################################
class OpenFile(wx.Dialog):
    """ A dialog for entering/browsing response curve file names and
    refgas.tab file names.
    """

    def __init__(self, parent=None, title="Open File"):
        wx.Dialog.__init__(self, parent, -1, title)

        self.filename = None
        self.refgasfilename = None

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
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
        """ Make some text controls for entering file names, and
        include buttons for browsing for files.
        """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Nl Raw File")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 3, 2, 2)
        sizer.Add(box1, wx.GROW | wx.ALIGN_CENTER_VERTICAL | wx.ALL)

        label = wx.StaticText(self, -1, "Filename:")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.file = wx.TextCtrl(self, -1, "", size=(250, -1))
        box1.Add(self.file, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        btn = wx.Button(self, 1000, "Browse...")
        btn.Bind(wx.EVT_BUTTON, self.browse)
        box1.Add(btn, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        label = wx.StaticText(self, -1, "Refgas.tab File:")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.refgasfile = wx.TextCtrl(self, -1, "", size=(250, -1))
        box1.Add(self.refgasfile, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        btn2 = wx.Button(self, 1001, "Browse...")
        btn2.Bind(wx.EVT_BUTTON, self.browse)
        box1.Add(btn2, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        return sizer

    # ----------------------------------
    def browse(self, event):
        """ Open a file dialog for user to browse for a file
        For response curve file.
        """

        eid = event.GetId()

        dlg = wx.FileDialog(
            self, message="Choose a file", defaultDir=os.getcwd(),
            defaultFile="", style=wx.FD_OPEN | wx.FD_CHANGE_DIR
            )
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
            for path in paths:
                if eid == 1000:
                    self.file.SetValue(path)
                else:
                    self.refgasfile.SetValue(path)

        dlg.Destroy()

    # ----------------------------------
    def ok(self, event):
        """ Ok button clicked.  Save file names entered by user
        and end dialog.
        """

        filename = self.file.GetValue()
        if not filename:
            msg = "Please enter a file name."
            dlg = wx.MessageDialog(self, msg, 'Input Needed', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return
        if not os.access(filename, os.F_OK):
            msg = "Could not open file '%s'." % filename
            dlg = wx.MessageDialog(self, msg, 'Error', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        self.filename = filename
        self.refgasfilename = self.refgasfile.GetValue()

        self.EndModal(wx.ID_OK)
