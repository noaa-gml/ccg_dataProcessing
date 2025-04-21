# vim: tabstop=4 shiftwidth=4 expandtab
"""
A dialog for saving the data in a graph dataset to file
"""

import os
import wx

import ccg_dates

from graph5.datenum import _from_ordinalf


##########################################################################
class SaveDialog(wx.Dialog):
    """ A dialog for saving the data in a graph dataset to file """

    def __init__(self, parent=None, title="Save Data to File", graph=None):
        wx.Dialog.__init__(self, parent, -1, title)

        self.graph = graph
        self.name = None

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 1, wx.GROW | wx.ALL, 5)

        self.d1 = wx.CheckBox(self, -1, "Use calendar format for dates")
        self.d1.SetValue(0)
        box0.Add(self.d1, 0, wx.GROW | wx.ALL, 2)

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

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        self.SetSize((-1, 400))

    # -----------------------------------------------------
    def ok(self, event):
        """ ok button clicked, open a file dialog and save data """

        if self.name:
            usecal = self.d1.GetValue()
            dataset = self.graph.getDataset(self.name)

            if dataset is not None:
                dlg = wx.FileDialog(
                    self, message="Choose a file", defaultDir=os.getcwd(),
                    defaultFile="", style=wx.FD_SAVE | wx.FD_CHANGE_DIR | wx.FD_OVERWRITE_PROMPT
                    )

                if dlg.ShowModal() == wx.ID_OK:
                    paths = dlg.GetPaths()
                    for path in paths:
                        outputfile = path

                    self._save_data(outputfile, dataset, usecal=usecal)
                    dlg.Destroy()

                else:
                    dlg.Destroy()
                    return

            self.EndModal(wx.ID_OK)

        else:
            msg = "Select a dataset to save."
            dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_WARNING)
            dlg.ShowModal()
            dlg.Destroy()

    # -----------------------------------------------------
    def _save_data(self, outputfile, dataset, usecal=False):
        """ save data to file """

        cal_fmt = "%4d %02d %02d %02d %02d %02d %16.9e\n"
        dd_fmt = "%16.9f %16.9e\n"
        n_fmt = "%16.9e %16.9e\n"

        x = dataset.xdata
        y = dataset.ydata
        f = open(outputfile, "w")

        if dataset.xdatatype == 1:  # x data is in dates
            for xp, yp in zip(x, y):
                dt = _from_ordinalf(xp)
                if usecal:
                    f.write(cal_fmt % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, yp))
                else:
                    xd = ccg_dates.decimalDateFromDatetime(dt)
                    f.write(dd_fmt % (xd, yp))
        else:
            for xp, yp in zip(x, y):
                f.write(n_fmt % (xp, yp))

        f.close()

    # -----------------------------------------------------
    def mkSource(self):
        """ make a tree ctrl for showing and picking available datasets """

        # Store images for the tree control
        isz = (16, 16)
        il = wx.ImageList(isz[0], isz[1])
        fldridx     = il.Add(wx.ArtProvider.GetBitmap(wx.ART_FOLDER,      wx.ART_OTHER, isz))
        fldropenidx = il.Add(wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN,   wx.ART_OTHER, isz))
        fileidx     = il.Add(wx.ArtProvider.GetBitmap(wx.ART_NORMAL_FILE, wx.ART_OTHER, isz))

        # Create panel to hold tree
        p1 = wx.Panel(self)
        box = wx.BoxSizer(wx.VERTICAL)
        self.tree = wx.TreeCtrl(p1, -1, style=wx.TR_DEFAULT_STYLE)
        self.tree.AssignImageList(il)
        self.root = self.tree.AddRoot("Data Sets", fldridx, fldropenidx)

        # Add nodes for each dataset
        for dataset in self.graph.datasets:
            self.tree.AppendItem(self.root, dataset.name, fileidx)

        # Open up root node
        self.tree.Expand(self.root)

        # Catch selection changes on tree
        self.Bind(wx.EVT_TREE_SEL_CHANGED, self.OnSelChanged, self.tree)

        # Add tree to sizer
        box.Add(self.tree, 1, wx.EXPAND, 0)
        p1.SetSizer(box)

        return p1

    # -----------------------------------------------------
    def OnSelChanged(self, event):
        """ save the selected item from the tree ctrl """

        item = event.GetItem()
        if item:
            name = self.tree.GetItemText(item)
            self.name = name

        event.Skip()
