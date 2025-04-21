# vim: tabstop=4 shiftwidth=4 expandtab


import sys
import os
import pwd
import wx

import wx.lib.mixins.listctrl as listmix

from common.validators import *
from common.TextView import TextView

import ccg_db_conn

DEFAULT_SCALE = "Select a scale"

ADD_ENTRY = 0
EDIT_COMMENT = 1
EDIT_LEVEL = 2
EDIT_START = 3
EDIT_ASSIGN = 4


######################################################################
class SortableListCtrl(wx.Panel, listmix.ColumnSorterMixin):
    """ A custom list ctrl for showing records in the scales database """

    def __init__(self, parent):
        wx.Panel.__init__(self, parent, -1, style=wx.WANTS_CHARS)

        self.parent = parent
        self.id = -1
        self.showall = parent.showall
        self.db = ccg_db_conn.RO(db="reftank")

        sizer = wx.BoxSizer(wx.VERTICAL)

        self.listctrl = wx.ListCtrl(self, -1, style=wx.LC_REPORT|wx.LC_VRULES|wx.LC_HRULES|wx.LC_SORT_ASCENDING|wx.LC_EDIT_LABELS)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.listctrl.SetFont(font)
        self.makeList(self.listctrl)
        sizer.Add(self.listctrl, 1, wx.EXPAND, 0)

        self.SetSizer(sizer)
        self.SetAutoLayout(True)

        listmix.ColumnSorterMixin.__init__(self, self.listctrl.GetColumnCount())

    #----------------------------------------------
    def makeList(self, listctrl):
        """ Make a list control that has a column for each field in the
            database table.
        """

        # get column names from scale assignments table.
        query = "SHOW COLUMNS FROM reftank.scale_assignments"
        result = self.db.doquery(query)

        self.column_names = []
        for n, row in enumerate(result):
            name = row['Field']
            listctrl.InsertColumn(n, name, width=100)

            # set the widths of the columns
            listctrl.SetColumnWidth(n, -2)

            self.column_names.append(name)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, listctrl)

        return listctrl

    #----------------------------------------------
    def GetListCtrl(self):
        """ Return the list ctrl widget.  Required by the ColumnSorterMixin """

        return self.listctrl

    #----------------------------------------------
    def _get_query(self, scalenum, searchstr=None):
        """ Get the query for selecting records from the database table.
        If a search string is set, then select only those records that
        match the search string.
        """

        query = "SELECT * from reftank.scale_assignments "
        query += "WHERE scale_num=%s " % (scalenum)

        if searchstr:
            sstr = []
            query += "AND ("
            for name in self.column_names:
                if "date" in name.lower():
                    s = "cast(%s as char) like '%%%s%%'" % (name, searchstr)
                else:
                    s = "%s like '%%%s%%'" % (name, searchstr)
                sstr.append(s)

            query += " or ".join(sstr)
            query += ")"

        query += " ORDER BY serial_number, start_date, assign_date "

        return query

    #----------------------------------------------
    def setPage(self, scalenum, showall, searchstr=None):
        """ Update the listctrl with scale entries """

        query = self._get_query(scalenum, searchstr)
        result = self.db.doquery(query)


        # if not showing all data, then only keep the latest mod date
        # for records where serial number and start date are the same
        if showall:
            data = result
        else:
            data = []
            tmpsn = None
            tmpstart_date = None
            for row in result:
                sn = row['serial_number']
                start_date = row['start_date']
                # if same tank and start date, replace last entry with this one
                if sn == tmpsn and start_date == tmpstart_date:
                    data.pop()

                data.append(row)
                tmpsn = sn
                tmpstart_date = start_date

        # populate the list control with the data
        listctrl = self.GetListCtrl()
        listctrl.DeleteAllItems()

        for nr, row in enumerate(data):
            index = listctrl.InsertItem(nr, str(row['num']))
            for fieldnum, key in enumerate(row):
                value = row[key]
                if key == "comment" and "\n" in value:
                    value = value.replace("\r", "")
                    value = value.split("\n")[0] + " ..."
                listctrl.SetItem(index, fieldnum, str(value))

            listctrl.SetItemData(index, nr)

            if nr % 2 == 0:
                listctrl.SetItemBackgroundColour(index, wx.Colour(240, 240, 240))


        # set the itemDataMap.  Required for sorting the columns,
        # and it needs to be a dict with key equal to item data,
        d = {}
        for n, row in enumerate(data):
            d[n] = [row[key] for key in row]
        self.itemDataMap = d

    #----------------------------------------------
    def OnItemSelected(self, event):
        """ If a line in a listbox is selected, remember
            the table index, which is the first column in
            the listbox.  The GetText function only returns
            the value from the first column, not the entire line.
        """

        self.id = int(event.GetText())
        self.parent.update_menus(2)
        self.parent.id = self.id


######################################################################
class Scale(wx.Frame):
    """ Class for working with tank calibration scale data base.  """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(900, 650))

        self.id = 0
        self.scalenum = 0
        self.search = None
        self.showall = False
        self.user = pwd.getpwuid(os.getuid()).pw_name
        self.priv_users = ["kirk", "crotwell"]
        if self.user in self.priv_users:
            self.db = ccg_db_conn.ProdDB(db="reftank")
        else:
            self.db = ccg_db_conn.RO(db="reftank")

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()

        # show text and choice list for picking scale
        box = wx.BoxSizer(wx.HORIZONTAL)
        self.sizer.Add(box, 0, wx.EXPAND|wx.ALL, 10)

        label = wx.StaticText(self, -1, "Scale: ", style=wx.ALIGN_RIGHT)
        box.Add(label, 0, wx.ALIGN_LEFT|wx.TOP, 8)

        # choice for select scale to display
        scaleslist = self._getScales()
        self.scale_choice = wx.Choice(self, -1, choices=scaleslist)
        box.Add(self.scale_choice, 0, wx.ALIGN_LEFT|wx.ALL, 1)
        self.scale_choice.SetSelection(0)
        self.Bind(wx.EVT_CHOICE, self.setScale, self.scale_choice)

        box.AddStretchSpacer()

        # a search box for filtering results
        self.searchbox = wx.SearchCtrl(self, size=(200, -1), style=wx.TE_PROCESS_ENTER)
        self.Bind(wx.EVT_TEXT_ENTER, self.getSearch, self.searchbox)
        self.Bind(wx.EVT_SEARCHCTRL_SEARCH_BTN, self.getSearch, self.searchbox)
        self.Bind(wx.EVT_SEARCHCTRL_CANCEL_BTN, self.getSearch, self.searchbox)
        box.Add(self.searchbox, 0, wx.ALL, 10)


        # A list control with sortable columns mixin for showing database entries
        self.listbox = SortableListCtrl(self)
        self.sizer.Add(self.listbox, 1, wx.EXPAND|wx.ALL, 2)

        self.update_menus(0)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)

    #----------------------------------------------
    def _getScales(self):
        """ Get list of scales from database. Each scale has its own
        table in the 'reftank' database. """

        query = "select name,current from scales order by name"
        result = self.db.doquery(query)

        scalelist = [DEFAULT_SCALE]
        for row in result:
            if row['current']:
                scalelist.append(row['name'] + " (Current)")
            else:
                scalelist.append(row['name'])

        return scalelist

    #----------------------------------------------
    def setScale(self, evt):
        """ User has chosen new scale.
        Get the scale from the scale choice list """

        s = self.scale_choice.GetStringSelection()
        scale = s.replace(" (Current)", "")
        query = "SELECT idx FROM reftank.scales "
        query += "WHERE name=%s "
        row = self.db.doquery(query, (scale,))
        self.scalenum = row[0]['idx']

        if scale == DEFAULT_SCALE:
            self.listbox.listctrl.DeleteAllItems()
            self.id = 0
            self.update_menus(0)
        else:
            self.listbox.setPage(self.scalenum, self.showall, self.search)
            self.update_menus(1)


    #----------------------------------------------
    def getSearch(self, evt):
        """ Get the text from the search box and update the list with records
        that match the search text.
        """

        self.search = self.searchbox.GetValue()
        self.listbox.setPage(self.scalenum, self.showall, self.search)

    #----------------------------------------------
    def MakeMenuBar(self):
        """ Create the menu bar """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        b1 = self.file_menu.Append(100, "Export", "Export as text")
        b2 = self.file_menu.Append(101, "Close", "Close the window")

        self.Bind(wx.EVT_MENU, self.OnExit, b2)
        self.Bind(wx.EVT_MENU, self.export, b1)
#        wx.EVT_MENU(self, 101, self.OnExit)
#        wx.EVT_MENU(self, 100, self.export)

        #---------------------------------------
        if self.user in self.priv_users:
            self.edit_menu = wx.Menu()
            self.menuBar.Append(self.edit_menu, "Edit")

            m201 = self.edit_menu.Append(201, "Add New Entry...")
            m202 = self.edit_menu.Append(202, "Update Existing Assignment...")
            self.edit_menu.AppendSeparator()
            m203 = self.edit_menu.Append(203, "Fix Incorrect Start Date...")
            m204 = self.edit_menu.Append(204, "Edit Comment...")
            m205 = self.edit_menu.Append(205, "Change Level...")
            self.edit_menu.AppendSeparator()
            m206 = self.edit_menu.Append(206, "Delete Entry...")

            self.Bind(wx.EVT_MENU, self.showEditDialog, m201)
            self.Bind(wx.EVT_MENU, self.showEditDialog, m202)
            self.Bind(wx.EVT_MENU, self.showEditDialog, m203)
            self.Bind(wx.EVT_MENU, self.showEditDialog, m204)
            self.Bind(wx.EVT_MENU, self.showEditDialog, m205)
            self.Bind(wx.EVT_MENU, self.deleteRecord, m206)

        #---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append(self.view_menu, "View")

        m301 = self.view_menu.Append(301, "Show Only Most Recent Assignment_date", "", wx.ITEM_RADIO)
        m302 = self.view_menu.Append(302, "Show All Entries", "", wx.ITEM_RADIO)

        self.Bind(wx.EVT_MENU, self.setview, m301)
        self.Bind(wx.EVT_MENU, self.setview, m302)

        self.SetMenuBar(self.menuBar)

    #----------------------------------------------
    def update_menus(self, which):
        """ Update the setting of the menu items """

        # wx seems to call a page changed event when the dialog is closed,
        # so this can get called when the menus don't exist anymore.  Put
        # it in a try/execpt to avoid error messages.
        try:
            if which == 0:  # no scale chosen, listbox is blank
                if self.user in self.priv_users:
                    self.edit_menu.Enable(201, False)
                    self.edit_menu.Enable(202, False)
                    self.edit_menu.Enable(203, False)
                    self.edit_menu.Enable(204, False)
                    self.edit_menu.Enable(205, False)
                    self.edit_menu.Enable(206, False)
            elif which == 1:     # scale is chosen, listbox has entries, but an item has not been selected
                if self.user in self.priv_users:
                    self.edit_menu.Enable(201, True)
                    self.edit_menu.Enable(202, False)
                    self.edit_menu.Enable(203, False)
                    self.edit_menu.Enable(204, False)
                    self.edit_menu.Enable(205, False)
                    self.edit_menu.Enable(206, False)
            else:        # scale is chosen, listbox has entries, item selected
                if self.user in self.priv_users:
                    self.edit_menu.Enable(201, True)
                    self.edit_menu.Enable(202, True)
                    self.edit_menu.Enable(203, True)
                    self.edit_menu.Enable(204, True)
                    self.edit_menu.Enable(205, True)
                    self.edit_menu.Enable(206, True)

        except:
            pass


    #---------------------------------------------------------------------------
    def deleteRecord(self, event):
        """ Delete a record from the database table """

        if self.id == 0:
            return

        msg = "DELETE FROM %s WHERE num=%d" % (self.scalenum, self.id)
        dlg = wx.MessageDialog(self, msg, 'Delete Record?', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
        if dlg.ShowModal() == wx.ID_YES:
            query = "DELETE FROM %s WHERE num=%d LIMIT 1" % (self.scalenum, self.id)
            print(query)
            self.db.doquery(query, commit=True)

            self.listbox.setPage(self.scalenum, self.showall, self.search)
            self.update_menus(1)
            self.SetStatusText("Deleted record, index # %d" % self.id)

        dlg.Destroy()


    #---------------------------------------------------------------------------
    def showEditDialog(self, event):
        """ Show a dialog for changing the properties of a database record """

        menuId = event.GetId()
        if menuId == 201: self.editAction = ADD_ENTRY
        if menuId == 202: self.editAction = EDIT_ASSIGN
        if menuId == 203: self.editAction = EDIT_START
        if menuId == 204: self.editAction = EDIT_COMMENT
        if menuId == 205: self.editAction = EDIT_LEVEL

        dlg = scaleEditRecordDialog(self, -1, "Edit Record", size=(350, 800),
            style=wx.DEFAULT_DIALOG_STYLE)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            if self.editAction == ADD_ENTRY or self.editAction == EDIT_ASSIGN:
                self.SetStatusText("Added new record.")
            else:
                self.SetStatusText("Edited record, index # %d." % self.id)
            self.listbox.setPage(self.scalenum, self.showall, self.search)
            self.update_menus(1)

        dlg.Destroy()


    #----------------------------------------------
    def setview(self, evt):
        """ Select whether to show all entries or just lastest entry """

        id = evt.GetId()
        if id == 302:
            self.showall = True
        if id == 301:
            self.showall = False

        self.listbox.setPage(self.scalenum, self.showall, self.search)

    #----------------------------------------------
    def export(self, e):
        """ Create a text version of what is shown in list """

        nitems = self.listbox.listctrl.GetItemCount()
        numcols = self.listbox.listctrl.GetColumnCount()

        fmt = "%-15s %s %12.4f %10.4f %10.6f %8.4f %8.4f %8.6f %10.6f %8.3f %8.3f %15s %-10s\n"

        txt = ""
        for row in range(nitems):

            data = []
            for i in range(1, numcols):
                item = self.listbox.listctrl.GetItem(row, i)
                s = item.GetText()
                data.append(s)

            (idx, sernum, sdate, tz, c0, c1, c2, uncc0, uncc1, uncc2, rsd, sunc, level, mdate, comment) = tuple(data)
            txt += fmt % (sernum, sdate, float(tz), float(c0), float(c1), float(c2), float(uncc0), float(uncc1), float(uncc2), float(rsd), float(sunc), level, mdate)

        dlg = TextView(self, txt)
        dlg.Show()


    #----------------------------------------------
    def OnExit(self, e):
        """ Exit the app """

        self.Close(True)  # Close the frame.


#####################################################################3333
class scaleEditRecordDialog(wx.Dialog):
    """ Dialog for editing a record in the scale database table """

    def __init__(
        self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

        self.db = ccg_db_conn.ProdDB(db="reftank")

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)


        self.scalenum = parent.scalenum
        self.editAction = parent.editAction
        self.start_fix_data = []


        if self.editAction == ADD_ENTRY:
            label = wx.StaticText(self, -1, "Adding new record.")
        else:
            label = wx.StaticText(self, -1, "Edit record.")

        box0.Add(label, 0, wx.ALIGN_CENTER|wx.ALL, 5)

        # get values from selected record to use to populate the form
        if self.editAction != ADD_ENTRY:
            self.index = int(parent.listbox.id)
            query = "SELECT * FROM scale_assignments WHERE num=%s" # % (self.index)
            result2 = self.db.doquery(query, (self.index,))
            data = result2[0]
#            print("data is", data)

        query = "show columns from reftank.scale_assignments"
        columns = self.db.doquery(query)
        column_names = [cn['Field'] for cn in columns]
#        for cn in columns: print cn


        # find all rows that have the same serial number and start date if we are editing the start date
        if self.editAction == EDIT_START:
            query = "select num from scale_assignments where serial_number=%s and start_date=%s and num!=%s"  # % (data[idx1], data[idx2], self.index)
            result2 = self.db.doquery(query, (data["serial_number"], data["start_date"], self.index))
            if len(result2) > 0:
                for row in result2:
                    self.start_fix_data.append(row)


        box1 = wx.FlexGridSizer(len(columns), 2, 2, 2)
        box0.Add(box1, 1, wx.GROW|wx.ALL, 2)
        self.tclist = []
        self.fields = []
        for n, row in enumerate(columns):
            name = str(row['Field'])

            if name not in ["num", "assign_date"]:
                self.fields.append(name)

                datatype = row['Type']
                label = wx.StaticText(self, -1, name)
                box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)

                if self.editAction == ADD_ENTRY:
                    val = ""
                else:
                    val = str(data[name])

                # make a text control for each field, except if type is 'enum', use choice control
                if datatype == "text":
                    tc = wx.TextCtrl(self, -1, val, style=wx.TE_MULTILINE|wx.HSCROLL, size=(300, 100))
                elif datatype.count("decimal"):
                    tc = wx.TextCtrl(self, -1, val, size=(300, -1), validator=Validator(V_FLOAT))
                elif datatype.count("float"):
                    tc = wx.TextCtrl(self, -1, val, size=(300, -1), validator=Validator(V_FLOAT))
                elif datatype.count("int"):
                    tc = wx.TextCtrl(self, -1, val, size=(300, -1), validator=Validator(V_INT))
                elif datatype.count("date"):
                    tc = wx.TextCtrl(self, -1, val, size=(300, -1), validator=Validator(V_DATE))
                elif datatype.count("time"):
                    tc = wx.TextCtrl(self, -1, val, size=(300, -1), validator=Validator(V_TIME))
                elif datatype.count("enum"):
                    idx = datatype.index("(")
                    ridx = datatype.rindex(")")
                    options = datatype[idx+1:ridx]
                    options = options.replace("'", "")
                    opt = options.split(",")
    #                print opt
                    tc = wx.Choice(self, -1, choices=opt)
                    if val:
                        tc.SetStringSelection(val)
                else:
                    length = getSize(datatype)
                    tc = wx.TextCtrl(self, -1, val, size=(300, -1))
                    tc.SetMaxLength(length)

                tc.Enable(False)
                if name.lower() == "comment": tc.Enable(True)

                if self.editAction == ADD_ENTRY: tc.Enable(True)
                if self.editAction == EDIT_LEVEL and name.lower() == "level": tc.Enable(True)
                if self.editAction == EDIT_START and name.lower() == "start_date": tc.Enable(True)
                if self.editAction == EDIT_ASSIGN and (
                    name.lower() == "tzero" or 
                    "coef" in name.lower() or 
                    "resid" in name.lower() or 
                    "unc" in name.lower()): 
                    tc.Enable(True)

                box1.Add(tc, 0, wx.ALIGN_LEFT|wx.ALL, 0)
                self.tclist.append(tc)

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

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)


    #---------------------------------------------------------------
    def ok(self, event):
        """ Apply the changes on the record to the database.
            If we are adding a new record, use the 'INSERT'
            sql command, otherwise use 'UPDATE' and the index number.
        """

#        db, c = ccg_db.dbConnect("reftank")
#        query = ""

        # only inserts are allowed starting feb 2021.
        query = "INSERT INTO scale_assignments "
        for field, tc in zip(self.fields, self.tclist):

            if field == "level":
                val = tc.GetStringSelection()
            else:
                val = tc.GetValue()
            if query.count("SET"):
                query += ", "
            else:
                query += "SET "
#            query += "%s='%s'" % (field, self.db.escape_string(val))
            query += "%s='%s'" % (field, val)


        # editing scale entries no longer allowed.  Can only insert new entries with desired changes.
        """
        if self.editAction == ADD_ENTRY or self.editAction == EDIT_ASSIGN:
            # assign_date field is set to current_time as default, so don't need to include it here.
            query = "INSERT INTO scale_assignments "
            for field, tc in zip(self.fields, self.tclist):

                if field == "level":
                    val = tc.GetStringSelection()
                else:
                    val = tc.GetValue()
                if query.count("SET"):
                    query += ", "
                else:
                    query += "SET "
                query += "%s='%s'" % (field, db.escape_string(val))

        if self.editAction == EDIT_COMMENT:
            field = "comment"
            n = self.fields.index(field)
            tc = self.tclist[n]
            val = tc.GetValue()
            query = "UPDATE scale_assignments SET %s='%s' WHERE num=%s" % (field, db.escape_string(val), self.index)

        if self.editAction == EDIT_START:
            field = "start_date"
            n = self.fields.index(field)
            tc = self.tclist[n]
            val = tc.GetValue()
            query = "UPDATE scale_assignments SET %s='%s' WHERE num=%s" % (field, val, self.index)
            # also update start_date for other rows that had same serial number and start date.
            if len(self.start_fix_data):
                for row in self.start_fix_data:
                    idx = int(row[0])
                    sql = "UPDATE scale_assignments SET start_date='%s' where num=%s " % (val, idx)
#                    print sql
                    c.execute(sql)
                    db.commit()

        if self.editAction == EDIT_LEVEL:
            field = "level"
            n = self.fields.index(field)
            tc = self.tclist[n]
            val = tc.GetStringSelection()
            query = "UPDATE scale_assignments SET %s='%s' WHERE num=%s" % (field, val, self.index)
        """


#        print query
        self.db.doquery(query, commit=True)
#        c.execute(query)
#        db.commit()
#        c.close()
#        db.close()

        self.EndModal(wx.ID_OK)


#####################################################################3333
def getSize(s):
    """ get size of a database table field with given type 's'"""

    p1 = s.find("(")
    if p1 < 0:
        return 0

    p2 = s.find(")")

    val = s[p1+1:p2]

    return int(val)
