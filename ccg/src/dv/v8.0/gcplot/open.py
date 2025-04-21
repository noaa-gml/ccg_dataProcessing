# vim: tabstop=4 shiftwidth=4 expandtab
""" Dialog for selecting chromatogram file to process.
Handles either a single file or a zip/archive file containing multiple files.
"""

import os
import zipfile

import wx

from common.utils import run_command

from .data import getData

##########################################################################
class OpenDialog(wx.Dialog):
    """ Dialog for selecting chromatogram files """

    def __init__(self, parent=None, title="Open File"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER)

        self.parent = parent

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        sizer = self.mkOptions()
        box0.Add(sizer, 1, wx.GROW|wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

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

    #----------------------------------
    def mkSource(self):
        """ Make the boxes for source file name and a button to browse for files """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box1, 0, wx.GROW|wx.ALL, 2)

        # horizontal box
        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box2, 0, wx.GROW|wx.ALL, 2)

        label = wx.StaticText(self, -1, "File:")
        box2.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.file = wx.TextCtrl(self, -1, "", size=(400, -1), style=wx.TE_PROCESS_ENTER)
        box2.Add(self.file, 1, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.Bind(wx.EVT_TEXT_ENTER, self.extract_filenames, self.file)

        # horizontal box
        box3 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box3, 0, wx.GROW|wx.ALL, 2)

        btn = wx.Button(self, 1, "Browse...", style=wx.BU_EXACTFIT)
        self.Bind(wx.EVT_BUTTON, self.browse, btn)
        box3.Add(btn, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


        return sizer

    #----------------------------------
    def mkOptions(self):
        """ a box listing the files insize a zip/archive file """

        # -------------- second static box sizer
        box = wx.StaticBox(self, -1, "Files")
        sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)

        # a horizontal box
        self.listbox = wx.ListCtrl(self, -1,
            style=wx.LC_LIST|wx.LC_SINGLE_SEL|wx.SIMPLE_BORDER,
            size=(550, 300)
        )
        self.Bind(wx.EVT_LIST_ITEM_ACTIVATED, self.OnItemActivated, self.listbox)
        sizer2.Add(self.listbox, 1, wx.GROW|wx.ALL, 2)

#        self.listbox.Hide()

        return sizer2


    #----------------------------------
    def browse(self, event):
        """ Browse for a file """

        dlg = wx.FileDialog(
            self, message="Choose a file", defaultDir="/ccg", #os.getcwd(),
            defaultFile="", style=wx.FD_OPEN | wx.FD_CHANGE_DIR
            )
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
            for path in paths:
#                print path
                self.file.SetValue(path)
                self.extract_filenames(None)
                self.listbox.Show()

        dlg.Destroy()

    #----------------------------------
    def extract_filenames(self, event):
        """ Get file names from inside a zip file """

        path = self.file.GetValue()

        files = []
        if zipfile.is_zipfile(path):
#            z = zipfile.ZipFile(path)
            with zipfile.ZipFile(path) as z:
                files = z.namelist()
        elif path.endswith(".a"):
            r, filelist = run_command(["ar", "-t", path])
            print("r is", r)
            if r == 0:
                files = filelist.split("\n")


        self.listbox.ClearAll()
        for file in files:
            n = self.listbox.GetItemCount()
            self.listbox.InsertItem(n, file)

    #----------------------------------
    def OnItemActivated(self, event):
        """ called when return is hit on a zip file """

        self.ok(None)

    #----------------------------------
    def ok(self, event):
        """ check the entered file names, and process chromatogram """

        # Get and test archive access
        archive = self.file.GetValue()
        if not archive:
            dlg = wx.MessageDialog(self, "Please enter a file name.", 'Error', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return
        if not os.access(archive, os.F_OK):
            dlg = wx.MessageDialog(self, "Could not open file 'f{archive}'.", 'Error', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return


        if zipfile.is_zipfile(archive) or archive.endswith(".a"):
            index = self.listbox.GetFirstSelected()
            # Get and test file access
            if index < 0:
                dlg = wx.MessageDialog(self, "Please select a file from the archive.", 'Error', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return
            filename = self.listbox.GetItemText(index)
            self.parent.archive = archive
        else:
            filename = archive
            self.parent.archive = None

#        print "call getdata with", self.parent.archive, filename
        getData(self.parent, self.parent.archive, filename)
        self.parent.input_file = filename
        self.parent.update_menus(1)
