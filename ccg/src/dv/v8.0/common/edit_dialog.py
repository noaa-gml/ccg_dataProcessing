# vim: tabstop=4 shiftwidth=4 expandtab
""" routine for getting and updating flag/tags for a flask data number

ShowEditDialog()
    Driver routine for calling either FlagEditDialog() or
    TagEditDialog() and updating the database with changes.

FlagEditDialog()
    A dialog showing flag and comment for a selected flask.
    User can change the flag and/or comment
    For flasks that don't use the tagging scheme

TagEditDialog()
    A dialog showing applied tags on flask data.
    User can select add more tags, or remove existing tags.
    For flasks that do use the tagging scheme

TagDialog()
    A dialog showing available flask tags.
    User can select one of the tags, and the selected tag and an optional
    comment can be added to the flask.
    For flasks that do use the tagging scheme
"""
import os
import pwd
import wx
import wx.lib.agw.hyperlink as hl
import wx.html

import ccg_dbutils
from ccg_flask_data import FlaskData
import ccg_utils

from common.validators import checkVal, V_STRING


#########################################################################
def showEditDialog(parent, mdata):
    """ Create a dialog for editing the flag/tags and comment field for the selected flask.
    Input:
        parent - wx widget for parent of this dialog
        mdata - dict containing the following data:
            'data_number': flask_data datanum value
            'qcflag': flask_data flag value
            'comment': flask_data comment
            'use_tags': flask_data update_data_from_tags value, 0 or 1


    Returns:
        updated (boolean) - True if flags/tags were changed in database, False if no changes
    """

    db = ccg_dbutils.dbUtils(readonly=False)

    updated = False

    if mdata['use_tags']:
        dlg = TagEditDialog(parent, mdata['data_number'], mdata['gas'])
        val = dlg.ShowModal()
        # all changes of tags are handled inside TagEditDialog

        updated = True

    else:

        dlg = FlagEditDialog(parent, mdata['qcflag'], mdata['comment'])
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            flag = dlg.flag
            comment = dlg.comment

            ccg_utils.addTagToDatanum(flag, mdata['data_number'], mode=2, verbose=True, update=True)
            query = "UPDATE flask_data SET comment=%s WHERE num=%s "
            db.doquery(query, (comment, mdata['data_number']))
#            print(query)

            updated = True

    dlg.Destroy()

    return updated


#########################################################################
class FlagEditDialog(wx.Dialog):
    """ # a dialog for user to input the 3 character flag string and/or comment.

    If the flag is set to 'None' in the call, then don't show a box for
    entering the flag, just a box for the comment.
    """

    def __init__(self, parent, flag="...", comment=""):

        wx.Dialog.__init__(self, parent, -1)

        self.flag = flag
        self.comment = comment

        # Main sizer for dialog
        sizer = wx.BoxSizer(wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        sizer.Add(box1, 0, wx.GROW | wx.ALL, 0)

        if self.flag is not None:
            label = wx.StaticText(self, -1, "Flag:")
            box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALL, 5)
            self.p1 = wx.TextCtrl(self, -1, self.flag, size=(150, -1))
            box1.Add(self.p1, 0, wx.ALIGN_LEFT | wx.ALL, 5)

        label = wx.StaticText(self, -1, "Comment:")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALL, 5)
        self.p2 = wx.TextCtrl(self, -1, self.comment, size=(550, -1))
        box1.Add(self.p2, 1, wx.EXPAND | wx.ALIGN_LEFT | wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        sizer.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_APPLY)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        sizer.Add(btnsizer, 1, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.SetSizer(sizer)
        sizer.SetSizeHints(self)

        self.p2.SelectNone()

    # -------------------------------------------
    def ok(self, event):
        """ Get the new flag and comment, save as attributes of this class.
        Then end dialog
        """

        if self.flag is not None:
            val = self.p1.GetValue()
            valid = checkVal(self.p1, val, V_STRING, 3)
            if not valid:
                return
            self.flag = val

        self.comment = self.p2.GetValue()

        self.EndModal(wx.ID_OK)


######################################################################
class TagEditDialog(wx.Dialog):
    """
    Create a dialog listing the available tags for a flask data number,
    with the option of selecting multiple tags and applyting them to the flask measurement

    Input:
        datanum - data number for row in flask_data table
    """

    def __init__(self, parent, datanum, gas, size=(980, 850)):

        wx.Dialog.__init__(self, parent, -1,
                           title="Flask Tags",
                           size=size,
                           style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER)

        self.db = ccg_dbutils.dbUtils(database="ccgg", readonly=False)
#        self.db = ccg_dbutils.dbUtils(database="mund_dev", readonly=False)
        self.user = pwd.getpwuid(os.getuid()).pw_name
        self.edit_index = 0
        self.gas = gas
        self.datanum = datanum

#        print(gas, datanum)
        self.results = self._get_results(self.gas, self.datanum)
#        print(self.results)

        event_text = self._get_event_text(self.results)
        data_text = self._get_data_text(self.results)

        # build ui
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))

        box0 = wx.BoxSizer(wx.VERTICAL)

        # data number and link to web page
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        text = wx.StaticText(self, -1, "Analysis Number: " + str(self.datanum))
        url = "https://omi.cmdl.noaa.gov/dt/?data_num=%s" % str(self.datanum)
        hyperl = hl.HyperLinkCtrl(self, -1, "DataTagger", URL=url)
        box1.Add(text, 0, wx.ALL, 10)
        box1.AddStretchSpacer()
        box1.Add(hyperl, 0, wx.ALL, 10)
        box0.Add(box1, 0, wx.EXPAND, 0)

        # separator line
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # two text boxes, left with flask event info, right with flask data info
        box2 = wx.BoxSizer(wx.HORIZONTAL)

        b = wx.StaticBoxSizer(wx.VERTICAL, self, "Flask Event Details")
        t = wx.StaticText(b.GetStaticBox(), -1, event_text, size=(480, -1), style=wx.ST_NO_AUTORESIZE)
        t.SetFont(font)
        b.Add(t, 1, wx.EXPAND | wx.ALL, 10)
        box2.Add(b, 1, wx.EXPAND | wx.ALL, 10)

        b = wx.StaticBoxSizer(wx.VERTICAL, self, "Flask Data Details")
        self.datatext = wx.StaticText(b.GetStaticBox(), -1, data_text, size=(480, -1),
                                      style=wx.ST_ELLIPSIZE_END | wx.ST_NO_AUTORESIZE)
        self.datatext.SetFont(font)
        b.Add(self.datatext, 1, wx.EXPAND | wx.ALL, 10)

        btn = wx.Button(b.GetStaticBox(), -1, "Edit Data Comment")
        b.Add(btn, 0, wx.ALIGN_RIGHT | wx.ALL, 5)
        self.Bind(wx.EVT_BUTTON, self._data_comment, btn)

        box2.Add(b, 1, wx.EXPAND | wx.ALL, 10)

        box0.Add(box2, 0, wx.EXPAND, 0)

        # list with applied tags
        b = wx.StaticBoxSizer(wx.VERTICAL, self, "Applied Tags")

        # a static text widget to display if no tags.  Hidden if there are tags
        self.msg = wx.StaticText(b.GetStaticBox(), -1, "No tags have been applied")
        b.Add(self.msg, 0, wx.ALL, 10)

        # a listbook to show applied tags and information about the tags
        self.listbox = wx.Listbook(b.GetStaticBox())
        lv = self.listbox.GetListView()
        lv.SetFont(font)

        self.listbox.Bind(wx.EVT_LISTBOOK_PAGE_CHANGED, self.OnPageChanged)

        b.Add(self.listbox, 1, wx.EXPAND | wx.ALL, 10)
        box0.Add(b, 1, wx.EXPAND | wx.ALL, 10)

        # buttons
        if self.results['use_tags']:
            box3 = wx.BoxSizer(wx.HORIZONTAL)

            # a button to open new dialog to add more tags
            b = wx.Button(self, -1, "Add Tag")
            self.Bind(wx.EVT_BUTTON, self._add_tag, b)
            box3.Add(b, 0, wx.LEFT, 10)

            self.deletebtn = wx.Button(self, -1, "Delete Tag")
            self.Bind(wx.EVT_BUTTON, self._delete_tag, self.deletebtn)
            box3.Add(self.deletebtn, 0, wx.LEFT, 20)

            self.addtagbtn = wx.Button(self, -1, "Add Tag Comment")
            self.Bind(wx.EVT_BUTTON, self._edit_tag, self.addtagbtn)
            box3.Add(self.addtagbtn, 0, wx.LEFT, 20)

            box0.Add(box3, 0, wx.EXPAND, 0)

        # populate the list book
        self._show_tags()

        # separator line
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # close button
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CLOSE)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.cancel, btn)
        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        self.SetSize(size)
        self.CenterOnScreen()

    # ---------------------------------------------------------
    def OnPageChanged(self, event):
        """ Save the index of the page we just changed to.
        Needed for the delete tag and edit tag comment operations.
        """

        self.edit_index = event.GetSelection()
        taginfo = self.appliedtaglist[self.edit_index]
        # if its an event tag, don't allow delete
        if taginfo['is_tag_range'] == 1:
            self.deletebtn.Disable()
            self.addtagbtn.Disable()
        else:
            self.deletebtn.Enable()
            self.addtagbtn.Enable()

        event.Skip()

    # ---------------------------------------------------------
    def _get_results(self, gas, datanum):
        """ get flask data results for given data number """

        f = FlaskData(gas, database="ccgg")
        f.setDataNumber(datanum)
        f.includeFlaggedData()
        f.includeHardFlags()
        results = f.run()

        # use only first dict from list (there should be only one anyway)
        return results[0]

    # ---------------------------------------------------------
    def _get_event_text(self, data):
        """ make text for the flask event text box """

        fmt = "%-15s %s\n"
        s = fmt % ('Event Number:', data['event_number'])
        s += fmt % ('Date:', data['date'])
        s += fmt % ('Site:', data['code'])
        s += fmt % ('Flask ID:', data['flaskid'])
        s += fmt % ('Method:', data['method'])
        s += fmt % ('Latitude:', data['latitude'])
        s += fmt % ('Longitude:', data['longitude'])
        s += fmt % ('Altitude:', data['altitude'])
        s += fmt % ('Comment:', data['event_comment'])
        s = s.rstrip()  # remove trailing \n

        return s

    # ---------------------------------------------------------
    def _get_data_text(self, data):
        """ make text for the flask data text box """

        fmt = "%-17s %s\n"
        s = fmt % ('Analysis Number:', data['data_number'])
        s += fmt % ('Parameter:', data['gas'])
        s += fmt % ('Value:', data['value'])
        s += fmt % ('Flag:', data['qcflag'])
        s += fmt % ('Analysis Date:', data['adate'])
        s += fmt % ('System:', data['system'])
        s += fmt % ('Instrument:', data['inst'])
        s += fmt % ('Comment:', data['comment'])
        s = s.rstrip()  # remove trailing \n

        return s

    # ---------------------------------------------------------
    def _make_html_text(self, taginfo):
        """ Create html formatted text with tag information """

        category = self._get_tag_category(taginfo['tag_num'])

        evtag = taginfo['affected_rows']
        comment = taginfo['tag_comment'].replace("\n", "<br>")

        s = "<u><b>%s</b></u><br><br>" % category
        s += "Tag: %s<br>" % taginfo['abbr']
        s += "Tag Number: %s<br>" % taginfo['tag_num']
        s += "Range Number: %s<br>" % taginfo['range_num']
        s += "Affected Range: %s<br>" % evtag
        s += "<br>"
        s += "<b>Description</b><br>"
        s += "<i>" + taginfo['description'] + "</i>"
        s += "<br><br>"
        s += "<b>Selection Criteria</b><br>"
        s += taginfo['selection_criteria']
        s += "<br><br>"
        s += "<b>Tag Comment</b><br>"
        s += "<i>" + comment + "</i>"

        return s

    # ---------------------------------------------------------
    def _get_tag_category(self, tag_num):
        """ Get the category name for a tag """

        sql = "select Tag_Type from ccgg.tag_list where Tag_number=%s"
        result = self.db.doquery(sql, (tag_num,))
        category = "Unknown"
        if result:
            category = result[0]['Tag_Type']

        return category

    # ---------------------------------------------------------
    def _show_tags(self, tagnum=None):
        """ populate the listbook with applied tags

        If tagnum is not None, then select the page with that tagnum
        """

        # we need to get the tag list each time because it may have changed
        self.appliedtaglist = self.db.getFlaskDataTags(self.datanum)
#        for t in self.appliedtaglist: print(t)

        if len(self.appliedtaglist) == 0:
            self.msg.Show()
            self.listbox.Hide()
            self.deletebtn.Disable()
            self.addtagbtn.Disable()
        else:
            self.msg.Hide()
            self.deletebtn.Enable()
            self.addtagbtn.Enable()

            self.listbox.DeleteAllPages()
            for tag_info in self.appliedtaglist:

                if tag_info['is_tag_range'] == 1:
                    self.deletebtn.Disable()
                    self.addtagbtn.Disable()

                category = self._get_tag_category(tag_info['tag_num'])
                category = category.replace(" issues", "")

                text = self._make_html_text(tag_info)

                st = wx.html.HtmlWindow(self.listbox, style=wx.BORDER_THEME)
                st.SetPage(text)

                label = " " + tag_info['abbr'] + " " + category + " "*(20 - len(category))
                select = tagnum is not None and tagnum == tag_info['tag_num']

                self.listbox.AddPage(st, label, select)

            self.listbox.Show()
            self.Layout()

    # ---------------------------------------------------------
    def cancel(self, event):
        """ Close the dialog """

        self.EndModal(wx.ID_CANCEL)

    # ---------------------------------------------------------
    def _delete_tag(self, evt):
        """ Delete the selected tag """

        range_num = self.appliedtaglist[self.edit_index]['range_num']
        tag = self.appliedtaglist[self.edit_index]['abbr']

        msg = "Delete tag (" + str(tag) + ")?"
        dlg = wx.MessageDialog(self, msg, 'Warning', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING)
        answer = dlg.ShowModal()
        if answer == wx.ID_YES:
            r = self.db.delFlaskDataTag(self.datanum, range_num, self.user)
            if r[0][0] != 0:
                msgdlg = wx.MessageDialog(self, r[0][1], 'Error', wx.OK | wx.ICON_ERROR)
                msgdlg.ShowModal()
                msgdlg.Destroy()

            # refresh the tag list, reset the selected item to 0
            self.edit_index = 0
            self._show_tags()

            # also update data text in case data flag or comment changed with tag delete
            self.results = self._get_results(self.gas, self.datanum)
            data_text = self._get_data_text(self.results)
            self.datatext.SetLabel(data_text)

        dlg.Destroy()

    # ---------------------------------------------------------
    def _data_comment(self, evt):
        """ Edit the data comment for the flask data number """

        dlg = FlagEditDialog(self, None, self.results['comment'])
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            comment = dlg.comment
            query = "UPDATE flask_data SET comment=%s WHERE num=%s "
            self.db.doquery(query, (comment, self.datanum))

            self.results['comment'] = comment

            data_text = self._get_data_text(self.results)
            self.datatext.SetLabel(data_text)

    # ---------------------------------------------------------
    def _edit_tag(self, evt):
        """ Add a comment to the selected tag"""

        tagnum = self.appliedtaglist[self.edit_index]['tag_num']

        dlg = FlagEditDialog(self, None, '')
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            comment = dlg.comment
            if len(comment) == 0:
                msgdlg = wx.MessageDialog(self, "Comment is empty.  Not added.", 'Error', wx.OK | wx.ICON_ERROR)
                msgdlg.ShowModal()
                msgdlg.Destroy()
                return

            r = self.db.addFlaskDataTag(self.datanum, tagnum, comment, self.user)
            if r[0][0] > 0:
                msgdlg = wx.MessageDialog(self, r[0][1], 'Error', wx.OK | wx.ICON_ERROR)
                msgdlg.ShowModal()
                msgdlg.Destroy()

            # refresh the tag list
            self._show_tags(tagnum)

    # ---------------------------------------------------------
    def _add_tag(self, evt):
        """ The 'Add Tag' button has been clicked.
        Bring up another dialog for the user to pick a tag
        to add to the current flask data number
        """

        dlg = TagDialog(self, self.datanum)
        val = dlg.ShowModal()
        if val == wx.ID_APPLY:

            tagnum = dlg.tagnum
            comment = dlg.comment

            # apply the tag with
            r = self.db.addFlaskDataTag(self.datanum, tagnum, comment, self.user)
            if r[0][0] > 0:
                msgdlg = wx.MessageDialog(self, r[0][1], 'Error', wx.OK | wx.ICON_ERROR)
                msgdlg.ShowModal()
                msgdlg.Destroy()

            # refresh the tag list
            self._show_tags(tagnum)

            # also update data text in case data flag changed
            self.results = self._get_results(self.gas, self.datanum)
            data_text = self._get_data_text(self.results)
            self.datatext.SetLabel(data_text)


#########################################################################################
class TagDialog(wx.Dialog):
    """ A dialog for choosing a tag and optionally adding aa comment for the tag.

        The user is shown a list of tags, from which only one can be selected.
        The user can add in comment text for the tag.
        If the 'Apply' button is clicked, the self.tagnum and self.comment attributes
        are set and the dialog ends.
     """

    def __init__(self, parent, datanum, size=(1020, 700)):

        wx.Dialog.__init__(self, parent, -1,
                           title="Available Tags",
                           size=size,
                           style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER)

        self.datanum = datanum
        self.disabled_rows = []  # list  of row numbers that we don't allow to change
        self.db = ccg_dbutils.dbUtils(database="ccgg", readonly=False)
#        self.db = ccg_dbutils.dbUtils(database="mund_dev", readonly=False)
        self.appliedtaglist = self.db.getFlaskDataTags(datanum)
        self.tagnum = None
        self.comment = None
        self.selected_index = None

        box0 = wx.BoxSizer(wx.VERTICAL)

        self.listbox = wx.ListCtrl(self, -1, style=wx.LC_REPORT | wx.LC_SINGLE_SEL | wx.LC_VRULES | wx.LC_HRULES)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.listbox.SetFont(font)
        self.listbox.InsertColumn(0, "Tag Num")
        self.listbox.InsertColumn(1, "Abbr")
        self.listbox.InsertColumn(2, "Description")
        self.listbox.InsertColumn(3, "Group Name")

        sizes = [90, 80, 575, 240]
        for n, sz in enumerate(sizes):
            self.listbox.SetColumnWidth(n, sz)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.ItemSelected, self.listbox)
        box0.Add(self.listbox, 1, wx.EXPAND, 0)

        label = wx.StaticText(self, -1, "Comment:")
        box0.Add(label, 0, wx.ALL, 10)
        self.p2 = wx.TextCtrl(self, -1, '')
        box0.Add(self.p2, 0, wx.EXPAND | wx.LEFT | wx.RIGHT, 10)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.ALL, 10)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_APPLY)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)

        btn = wx.Button(self, wx.ID_CANCEL)
        self.Bind(wx.EVT_BUTTON, self.cancel, btn)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        # put data into list box
        self.process_data()

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        self.SetSize(size)
        self.CenterOnScreen()

    # ---------------------------------------------------------
    def process_data(self):
        """ Fill the listbox with available tags for our flask data number.
        """

        taglist = self.db.getFlaskDataTagList(self.datanum)

        self.listbox.DeleteAllItems()

        for n, (tagnum, tagabbr, tagdesc, taggroup) in enumerate(taglist):

            index = self.listbox.InsertItem(n, str(tagnum))
            self.listbox.SetItem(index, 1, str(tagabbr))
            self.listbox.SetItem(index, 2, str(tagdesc))
            self.listbox.SetItem(index, 3, str(taggroup))

            if n % 2 == 0:
                self.listbox.SetItemBackgroundColour(index, wx.Colour(240, 240, 240))

            for taginfo in self.appliedtaglist:
                if tagnum == taginfo['tag_num']:
                    if taginfo['is_tag_range'] == 1:
                        self.listbox.SetItemTextColour(index, wx.Colour(200, 200, 200))
                        self.disabled_rows.append(index)

        # These are row numbers that can't be changed.
        self.disabled_rows = list(set(self.disabled_rows))  # get unique row numbers

#        print("disabled rows are", self.disabled_rows)

    # ---------------------------------------------------------
    def ItemSelected(self, evt):
        """ A row in the listbox has been selected.

        We can't actually disable rows in the listctrl, so mimic the behavior
        by not allowing selections on disabled rows.
        """

        index = evt.GetIndex()

        # turn off selection for 'disabled' rows
        if index in self.disabled_rows:
            self.listbox.Select(index, on=0)   # turn off selection
            self.selected_index = None
            return

        self.selected_index = index

    # ---------------------------------------------------------
    def cancel(self, event):
        """ Close the dialog """

        self.EndModal(wx.ID_CANCEL)

    # ---------------------------------------------------------
    def ok(self, event):
        """ Process any selected tags, then close the dialog """

        if self.selected_index is None:
            msgdlg = wx.MessageDialog(self, "Select a row first", 'Error', wx.OK | wx.ICON_ERROR)
            msgdlg.ShowModal()
            msgdlg.Destroy()
            return

        # get item at row, column
        item = self.listbox.GetItem(self.selected_index, 0)
        self.tagnum = int(item.GetText())
        self.comment = self.p2.GetValue()

        self.EndModal(wx.ID_APPLY)
