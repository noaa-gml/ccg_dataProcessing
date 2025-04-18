
# vim: tabstop=4 shiftwidth=4 expandtab
""" app for viewing flask raw files.
Consists of a window with two plots, and
a choice menu for each plot for selecting the
parameter to plot.
"""

import os
import wx
from dateutil.parser import parse

from ccg_flask_data import FlaskData

import ccg_rawfile

from common.edit_dialog import showEditDialog
from common.find_raw_file import findRawFile
from common.FileView import FileView
from common.ImageView import ImageView


##################################################################################
class FlaskListCtrl(wx.ListCtrl):
    """ A listctrl for the actual flask data.
    Used by selectedFlaskListbox and SiteStrings
    """

    def __init__(self, parent, height=70):
        wx.ListCtrl.__init__(self, parent, -1,
                             style=wx.LC_REPORT | wx.LC_SINGLE_SEL | wx.LC_VRULES | wx.LC_HRULES,
                             size=(-1, height))

        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.SetFont(font)

        self.headers = {
            "Event": 80,
            "Gas": 70,
            "Code": 70,
            "Date": 170,
            "ID": 80,
            "Method": 80,
            "Data Num": 100,
            "Value": 100,
            "Flag": 70,
            "Inst": 70,
            "System": 90,
            "ADate": 170,
            "Use Tags": 100,
            "Comment": 200
            }
        for n, (label, size) in enumerate(self.headers.items()):
            self.InsertColumn(n, label)
            self.SetColumnWidth(n, size)

#        for n, name in enumerate(self.headers):
#            val = f"{self.datalist.iloc[0][name]}"
#            if len(name) > len(val):
#                s = name
#            else:
#                s = val
#            size = self.GetTextExtent(s)
#            w = size.GetWidth() + 30
#            self.InsertColumn(n, name, width=w)

    # ---------------------------------------------------------------------------------
    def setFlaskListCtrlItems(self, row):
        """ set the values of the flask listctrl

        row is a dict that comes from FlaskData class
        """

        item = self.makeItem(row)
        self.Append(item)

        n = self.GetItemCount()
        if n % 2 == 0:
            self.SetItemBackgroundColour(n-1, wx.Colour(245, 245, 245))

    # ---------------------------------------------------------------------------------
    def makeItem(self, row):
        """ Make a tuple for the listctrl item
        Input
            row : row of data from FlaskData result
         """

        item = (
            str(row['event_number']),
            str(row['gas']),
            str(row['code']),
            str(row['date']),
            str(row['flaskid']),
            str(row['method']),
            str(row['data_number']),
            str(row['value']),
            str(row['qcflag']),
            str(row['inst']),
            str(row['system']),
            str(row['adate']),
            str(row['use_tags']),
            str(row['comment']),
        )

        return item

    # ---------------------------------------------------------------------------------
    def updateItem(self, index, row):
        """ update the list entry at row 'index' with the values in the tuple 'row' """

        item = self.makeItem(row)
        for column, label in enumerate(item):
            self.SetItem(index, column, label)

    # ---------------------------------------------------------------------------------
    def setList(self, flist):
        """ remove existing rows and insert new rows from flist.

        flist is a list of dicts from FlaskData class
        """

        self.DeleteAllItems()
        for row in flist:
            self.setFlaskListCtrlItems(row)


##################################################################################
class selectedFlaskListbox(wx.Panel):
    """ combined widget for displaying a listctrl with flask data

    Includes a text header and a button for editing an entry in the list
    """

    def __init__(self, parent, height=80, callback=None):
        wx.Panel.__init__(self, parent, -1)

        self.event_number = None
        self.analysis_date = None
        self.edit_index = 0

        self.parent = parent
        self.parent_callback = callback
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # --------------------
        # single line list to show flask sample info for selected data point
        self.text = wx.StaticText(self, -1, "Selected Data:")
        self.sizer.Add(self.text, 0, wx.ALL, 5)

        self.listbox2 = FlaskListCtrl(self, height)
        self.Bind(wx.EVT_LIST_ITEM_RIGHT_CLICK, self.ItemRightClick, self.listbox2)

        self.sizer.Add(self.listbox2, 1, wx.EXPAND, 0)
#        self.sizer.Add(self.listbox2)

        self.editbtn = wx.Button(self, -1, "Edit")  # wx.ID_EDIT)
        self.editbtn.Enable(False)
        self.Bind(wx.EVT_BUTTON, self.show_edit_dialog, self.editbtn)
        self.sizer.Add(self.editbtn, 0, wx.ALL, 3)

        self.SetSizer(self.sizer)

    # ----------------------------------------------
    def DeleteAllItems(self):
        """ Remove all rows from the list ctrl """

        self.listbox2.DeleteAllItems()

    # ----------------------------------------------
    def setItems(self, parameter, flask_evt, analysis_date=None):
        """ Update list box with selected flask data
        Args
            parameter - single or list of parameters to use
            flask_evt - flask event number
            analysis_date - analysis date for flask event and parameter
        """

        self.listbox2.DeleteAllItems()
        if flask_evt is None:
            return

        self.event_number = flask_evt
        self.analysis_date = analysis_date

        if isinstance(parameter, list):
            params = parameter
        else:
            params = [parameter]

        for param in params:

            results = self._get_flask_data(param, flask_evt, analysis_date)
            if results:
                for row in results:
                    self.listbox2.setFlaskListCtrlItems(row)

        self.editbtn.Enable(True)

    # ---------------------------------------------------------------------------
    def _get_flask_data(self, param, flask_evt, analysis_date):
        """ call FlaskData to get data for this flask event """

        fdb = FlaskData(param)
        fdb.setEvents(flask_evt)
        if analysis_date:
            fdb.setAnalysisDate(analysis_date.date(), analysis_date.time())
        fdb.includeFlaggedData()
        fdb.includeHardFlags()
        fdb.includeDefault()
        fdb.run()

        return fdb.results

    # ---------------------------------------------------------------------------
    def show_edit_dialog(self, event):
        """ Create a dialog for editing the flag/tags and comment field for the
            selected flask.  If the 'Apply' button is selected, update the
            database with the changes.
        """

        nrows = self.listbox2.GetItemCount()
        index = self.listbox2.GetFirstSelected()

        # if the list has more than 1 row, make sure a row is selected
        if index == -1:
            if nrows > 1:
                dlg = wx.MessageDialog(self, "Select one line", 'Warning', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

            index = 0

        mdata = {
            "gas":         str(self.listbox2.GetItem(index, 1).GetText()),
            "data_number": int(self.listbox2.GetItem(index, 6).GetText()),
            "qcflag":      str(self.listbox2.GetItem(index, 8).GetText()),
            "use_tags":    int(self.listbox2.GetItem(index, 12).GetText()),
            "comment":     str(self.listbox2.GetItem(index, 13).GetText()),
        }

#        print(mdata)

        flag_updated = showEditDialog(self, mdata)

        # flag_updated is always true for tags
        if not flag_updated:
            return

#        fmt = "Saved flag/tags for event %s, data number %s, gas %s "
#        s = fmt % (self.event_number, mdata['data_number'], mdata['gas'])
#        self.parent.SetStatusText(s)

        # update the listbox item with new flag,comment
        # do this by getting data from db and updating each column label
        results = self._get_flask_data(mdata['gas'], self.event_number, self.analysis_date)
        if results:
            # there could be multiple analysis results of same event number on same analysis date,
            # so find the result with the same data number
            for item in results:
                if item['data_number'] == mdata['data_number']:
                    self.listbox2.updateItem(index, item)

        # call the parent callback if set (e.g. to update plot with new flask flag)
        if self.parent_callback:
            self.parent_callback(mdata['gas'])

    # ---------------------------------------------------------------------------
    def viewRawFile(self, event):
        """ Get the raw file for the selected data point and show it in
            a popup dialog.
        """

        event = int(self._get_sel_item(self.edit_index, 'Event'))
        date = self._get_sel_item(self.edit_index, 'ADate')
        gas = self._get_sel_item(self.edit_index, 'Gas')
        system = self._get_sel_item(self.edit_index, 'System')
        adate = parse(date)

        rawfile = findRawFile(gas, system, adate.date(), event)
        if rawfile is None:
            wx.MessageBox("File not found.", "Error")
        else:
            dlg = FileView(self, rawfile)
            dlg.Show()

    # ---------------------------------------------------------------------------
    def viewSiteStrings(self, event):
        """ Create and/or show the dialog that show site strings from the raw file
            for the selected flask.
        """

        event = int(self._get_sel_item(self.edit_index, 'Event'))
        date = self._get_sel_item(self.edit_index, 'ADate')
        gas = self._get_sel_item(self.edit_index, 'Gas')
        system = self._get_sel_item(self.edit_index, 'System')
        adate = parse(date)

        rawfile = findRawFile(gas, system, adate.date(), event)
        if rawfile is None:
            wx.MessageBox("File not found.", "Error")
        else:
            sitedlg = SiteStrings(self, [rawfile], gas, str(event))
            sitedlg.Show()

    # ---------------------------------------------------------------------------
    def viewTraj(self, event):
        """ Find the image file with the back trajectory for the selected data point.
            Display it in a popup dialog.
        """

        date = self._get_sel_item(self.edit_index, 'Date')
        code = self._get_sel_item(self.edit_index, 'Code')
        dt = parse(date)

        tdir = "/ccg/traj/images/%s/" % code.lower()
        tfile = "%s_%4d-%02d-%02d.%02d.png" % (code.lower(), dt.year, dt.month, dt.day, dt.hour)
        trajfile = tdir + tfile

        if os.path.exists(trajfile):
            dlg = ImageView(self, trajfile)
            dlg.Show()
            dlg.Raise()
        else:
            msg = "No trajectory is available."
            dlg = wx.MessageDialog(self, msg, 'Error: No Data', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()

    # ---------------------------------------------------------------------------
    def plotRawFile(self, event):
        """ Create and/or show the dialog that plots the rawfile data
            for the selected flask.
        """
        from fledit.flask import flRaw

        event = int(self._get_sel_item(self.edit_index, 'Event'))
        date = self._get_sel_item(self.edit_index, 'ADate')
        gas = self._get_sel_item(self.edit_index, 'Gas')
        system = self._get_sel_item(self.edit_index, 'System')
        adate = parse(date)

        rawfile = findRawFile(gas, system, adate.date(), event)
    #    print "rawfile is ", rawfile
        if rawfile is None:
            wx.MessageBox("File not found.", "Error")
        else:
            frame = flRaw(self, rawfile=rawfile, gas=gas)
            frame.Show()

    # ---------------------------------------------------------------------------
    def ItemRightClick(self, event):
        """ right click on list row.  Popup a menu with more options """

        self.edit_index = event.GetIndex()
        print(self.edit_index)
        if self.edit_index < 0:
            return

        # make a menu
        menu = wx.Menu()
        # add some other items
        menu.Append(1002, "Plot Raw File...")
        menu.Append(1003, "View Raw File...")
        menu.Append(1005, "View Raw File Site Strings...")
        menu.Append(1004, "View Trajectory...")

        self.Bind(wx.EVT_MENU, self.plotRawFile, id=1002)
        self.Bind(wx.EVT_MENU, self.viewRawFile, id=1003)
        self.Bind(wx.EVT_MENU, self.viewTraj, id=1004)
        self.Bind(wx.EVT_MENU, self.viewSiteStrings, id=1005)

        # Popup the menu.  If an item is selected then its handler
        # will be called before PopupMenu returns.
        self.PopupMenu(menu)
        menu.Destroy()

    # ---------------------------------------------------------------------------
    def _get_sel_item(self, index, name):
        """ return the value of the selected item at row 'index' in the column 'name' """

        colnum = list(self.listbox2.headers.keys()).index(name)
        item = self.listbox2.GetItem(index, colnum)
        val = item.GetText()

        return val


######################################################################
class SiteStrings(wx.Dialog):
    """
    Create a dialog listing the flask results from one or more raw files,
    with the option of editing the tag/flag and comment fields.

    Input:
        rawfiles - list of raw file names to use
        paramnum - parameter number for the raw files
        flask_event - (optional) flask event number, if set, highlight the row
            with the flask event number
    """

    def __init__(self, parent, rawfiles, parameter, flask_event=None, size=(900, 700)):

        wx.Dialog.__init__(self, parent, -1,
                           title="Flask Results for Raw Files",
                           size=size,
                           style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER)

        self.flask_event = flask_event
        self.rawfiles = rawfiles
        self.parameter = parameter
        self.mdata = None

        box0 = wx.BoxSizer(wx.VERTICAL)

        self.text = wx.TextCtrl(self, -1, "")
        self.text.SetEditable(False)
        box0.Add(self.text, 0, wx.EXPAND | wx.ALL, 3)

        self.listbox2 = FlaskListCtrl(self)
        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.ItemSelect, self.listbox2)
        box0.Add(self.listbox2, 1, wx.EXPAND, 0)

        b = wx.Button(self, wx.ID_EDIT)
        box0.Add(b, 0, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.show_edit_dialog, b)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CLOSE)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

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
        """ Put items into the listctrl

        For each raw file, read the file and get results
        from the database for each sample. Display these results
        ctrl

        in the list box.
        """

        if len(self.rawfiles) > 1:
            self.text.SetValue("%s to %s" % (self.rawfiles[0], self.rawfiles[-1]))
        else:
            self.text.SetValue(self.rawfiles[0])

        self.listbox2.DeleteAllItems()

        selected_row = None
        n = 0
        for rawfile in self.rawfiles:

            # read the raw file
            raw = ccg_rawfile.Rawfile(rawfile)
            events = raw.getSampleEvents()

            fldb = FlaskData(self.parameter)
            fldb.setEvents(events)
            fldb.includeFlaggedData()
            fldb.includeHardFlags()
            fldb.run()
#            fldb.showQuery()
#            for row in fldb.results: print(row)

            for i in raw.sampleIndices():
                row = raw.dataRow(i)
                event = int(row.event)

                fdata = fldb.find(event, row.date)
                self.listbox2.setFlaskListCtrlItems(fdata)

                if event == self.flask_event:
                    selected_row = n
                n += 1

        # If selidx was specified, highlight that row and make it visible.
        if selected_row is not None:
            self.listbox2.SetItemState(selected_row, wx.LIST_STATE_SELECTED, wx.LIST_STATE_SELECTED)
            self.listbox2.EnsureVisible(selected_row)

    # ----------------------------------------------
    def ItemSelect(self, event):
        """ A click has happend on an entry in the list box.

        Save the needed data for the selected row to be used in edit dialog.
        """

        # need to remember the index of the selected row for later usage
        index = event.Index
        print("edit index is", index)

        datanum = int(self._get_sel_item(index, 'Data Num'))
        event = int(self._get_sel_item(index, 'Event'))
        flag = self._get_sel_item(index, 'Flag')
        comment = self._get_sel_item(index, 'Comment')
        use_tags = int(self._get_sel_item(index, 'Use Tags'))
        gas = self._get_sel_item(index, 'Gas')

        # save these values in a dict similar to what comes out of flaskdb.measurementData
# Maybe return the entire selected row as mdata?  Then don't need to set individual entries
        self.mdata = {
            "data_number": datanum,
            "qcflag": flag,
            "comment": comment,
            "use_tags": use_tags,
            "gas": gas,
        }
        print(self.mdata)

        self.flask_event = event

    # ---------------------------------------------------------------------------
    def _get_sel_item(self, index, name):
        """ return the value of the selected item at row 'index' in the column 'name' """

        colnum = list(self.listbox2.headers.keys()).index(name)
        item = self.listbox2.GetItem(index, colnum)
        val = item.GetText()

        return val

    # ---------------------------------------------------------------------------
    def show_edit_dialog(self, event):
        """ Create a dialog for editing the flag and comment field for the
            selected flask.  If the 'OK' button is selected, update the
            database with the changes, and update the graph using new flag.

            This method is called when the 'Edit' button is clicked.
        """

        print(self.mdata)
        if self.mdata is None: return

        flag_updated = showEditDialog(self, self.mdata)

        if flag_updated:
            self.process_data()

    # ---------------------------------------------------------
    def ok(self, event):
        """ Close the dialog """

        self.Destroy()
