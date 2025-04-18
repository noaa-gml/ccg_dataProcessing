# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Create a dialog with a list of everything in the 'datalist' array.
# One line per list item, each tuple item in a separate column.
"""

import wx

from common.edit_dialog import FlagEditDialog


###################################################################
def get_sequences(x):
    """ Get sections with consecutive values.
    x is a list containing indices of selected data in the
    flag list.  Find start and stop points where the
    indices in x are consecutive, i.e. 1 apart.

    This is used to condense the entries in the flagging log.
    """

    s = []

    end = x[0]
    start = x[0]
    for n in x[1:]:

        # if this index is more than 1 from the previous index,
        # save the previous start and end
        if n - end != 1:
            s.append((start, end))
            start = n

        end = n

    s.append((start, end))

    return s


###################################################################
class FlagList(wx.ListCtrl):
    """ A list control that will contain the dates, values and flags
    which the user can select and apply a new flag
    """

    def __init__(self, parent):

        # make a copy of the datalist
        # any changes will be made to this copy, so that the original list is unchanged until
        # we process this copied list.
        self.datalist = parent.datalist.copy()

        # the wx.LC_VIRTUAL makes the ListCtrl show items only when visible, and requires OnGetItemText method
        wx.ListCtrl.__init__(self,
                             parent,
                             -1,
                             size=(1000, 500),
                             style=wx.LC_REPORT | wx.LC_VIRTUAL | wx.LC_HRULES | wx.LC_VRULES)

        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.SetFont(font)

        # create columns for the list. A column for every DataFrame column

        self.cols = self.datalist.columns

        for n, name in enumerate(self.cols):
            val = f"{self.datalist.iloc[0][name]}"
            if len(name) > len(val):
                s = name
            else:
                s = val
            size = self.GetTextExtent(s)
            w = size.GetWidth() + 30
            if s == "comment":
                w = w + 200

            self.InsertColumn(n, name, width=w)

        self.SetItemCount(len(self.datalist))

    # ----------------------------------------------
    def OnGetItemText(self, item, col):
        """ this gets called everytime a new cell in the listbox needs to be shown """

        row = self.datalist.iloc[item]
        colname = self.cols[col]

        return f"{row[colname]}"


##########################################################################
class FlagDialog(wx.Dialog):
    """ A dialog showing list of dates, values, flags that the user can
    select and apply a different flag.
    """

    def __init__(self, parent, datalist, title="Flag", size=(980, 650)):
        wx.Dialog.__init__(self, parent, -1, title,
                           size=size,
                           style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER)

        self.datalist = datalist  # a DataFrame
        self.flaginfo = []  # this will contain changed flag information
        self.changes = {}

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkList()
        box0.Add(sizer, 0, wx.GROW | wx.ALL, 5)

        btn = wx.Button(self, -1, "Edit Flag")
        self.Bind(wx.EVT_BUTTON, self.edit, btn)
        box0.Add(btn, 0, wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btn = wx.Button(self, wx.ID_OK)
        btnsizer.AddButton(btn)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

    # ----------------------------------
    def mkList(self):
        """ Create a static box containing a list control """

        # First static box sizer
        box = wx.StaticBox(self, -1, "Mole Fractions")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        t = wx.StaticText(self, -1, "Highlight lines, then click 'Edit Flag'")
        font = wx.Font(wx.FontInfo().Italic())
        t.SetFont(font)
        sizer.Add(t)

        self.listbox = FlagList(self)

        sizer.Add(self.listbox, 1, wx.ALL | wx.EXPAND, 5)

        return sizer

    # ----------------------------------
    def edit(self, event):
        """ Get selected lines, show a dialog for setting the flag, then
        save the new flag info and update the flag list
        """

        # make list with index of selected rows
        index = self.listbox.GetFirstSelected()

        if index == -1:
            dlg = wx.MessageDialog(self, "Select one or more lines", 'Warning', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        # determine column number where qcflag is in DataFrame
        a = list(self.datalist.columns)

        # get existing flag from first selected item
        FLAG_COLUMN = a.index("qcflag")
        item = self.listbox.GetItem(index, FLAG_COLUMN)
        edit_flag = item.GetText()

        COMMENT_COLUMN = a.index("comment")
        item = self.listbox.GetItem(index, COMMENT_COLUMN)
        edit_comment = item.GetText()

        sel_list = []
        while index != -1:
            sel_list.append(index)
            index = self.listbox.GetNextSelected(index)

        s = get_sequences(sel_list)

        # Create a dialog for editing the flag for the selected lines.
        dlg = FlagEditDialog(self, edit_flag, edit_comment)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            flag = dlg.flag
            comment = dlg.comment

            for (start, stop) in s:
                t1 = self.datalist.iloc[start]['date']
                t2 = self.datalist.iloc[stop]['date']
                print(t1, "-", t2, flag, comment)
                self.flaginfo.append((t1, t2, flag, comment))

            # for each selected item, replace the flag in the data list in the listbox
            self.listbox.datalist.iloc[sel_list, FLAG_COLUMN] = flag
            self.listbox.datalist.iloc[sel_list, COMMENT_COLUMN] = comment

            for idx in sel_list:
                self.changes[idx] = (flag, comment)

            self.listbox.Refresh()

    # ----------------------------------
    def ok(self, event):
        """ Processing of the changed flags is done in insitu.py """

        self.EndModal(wx.ID_OK)
