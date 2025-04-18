# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for working with tank calibration data base.
"""

import wx

from graph5.graph import Graph

from common.stats import StatsDialog
from common.regres import RegressionDialog
from common.validators import Validator, V_FLOAT, V_INT, V_DATE, V_TIME
from common.utils import get_path


import ccg_db_conn
import ccg_cal_db


######################################################################
class Cal(wx.Frame):
    """ Class for working with tank calibration data base.  """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(800, 600))

        self.id = 0
        self.table = ""
        self.syslist = None
        self.db = ccg_db_conn.RO(db="reftank")
        # labels for the calibration list box header.
        # set these here because we're revising the order in which they appear
        # from the ccg_caldb results
        self.cal_fields = [{'Field': 'idx'},
                           {'Field': 'serial_number'},
                           {'Field': 'fillcode'},
                           {'Field': 'date'},
                           {'Field': 'time'},
                           {'Field': 'species'},
                           {'Field': 'mixratio'},
                           {'Field': 'stddev'},
                           {'Field': 'num'},
                           {'Field': 'method'},
                           {'Field': 'inst'},
                           {'Field': 'system'},
                           {'Field': 'pressure'},
                           {'Field': 'flag'},
                           {'Field': 'location'},
                           {'Field': 'regulator'},
                           {'Field': 'notes'},
                           {'Field': 'mod_date'},
                           {'Field': 'meas_unc'},
                           {'Field': 'scale_num'},
                           {'Field': 'parameter_num'},
                           {'Field': 'run_number'},
                           {'Field': 'dd'},
                           {'Field': 'typeB_unc'},
                           ]

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()

        # box for holding 2 more boxes
        mainbox = wx.BoxSizer(wx.HORIZONTAL)
        self.sizer.Add(mainbox, 0, wx.EXPAND, 0)

        # box for entering serial number, with a search button next to it.
        box = wx.BoxSizer(wx.HORIZONTAL)
        mainbox.Add(box, 1, wx.EXPAND | wx.ALIGN_LEFT, 0)

        label = wx.StaticText(self, -1, "Serial Number: ")
        box.Add(label, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

        self.sernum = wx.SearchCtrl(self, size=(200, -1), style=wx.TE_PROCESS_ENTER)
        self.Bind(wx.EVT_TEXT_ENTER, self.getSn, self.sernum)
        self.Bind(wx.EVT_SEARCHCTRL_SEARCH_BTN, self.getSn, self.sernum)
        box.Add(self.sernum, 0, wx.ALIGN_LEFT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)

        # another horizontal box sizer for species select box and label
        box = wx.BoxSizer(wx.HORIZONTAL)
#        mainbox.Add(box, 1, wx.EXPAND|wx.ALIGN_RIGHT, 0)
        mainbox.Add(box, 0, wx.EXPAND, 0)

        label = wx.StaticText(self, -1, "Species to Plot: ", style=wx.ALIGN_RIGHT)
#        box.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
        box.Add(label, 0, wx.ALL, 2)
        species = ["CO2", "CH4", "CO", "H2", "N2O", "SF6", "CO2C13", "CO2O18"]
        self.species = wx.Choice(self, -1, choices=species)
        box.Add(self.species, 0, wx.ALL, 2)
        self.species.SetSelection(0)
        self.graph_species = "CO2"
        self.Bind(wx.EVT_CHOICE, self.setGas, self.species)

        # Notebook for holding graphs for the various curves
        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)
        self.sizer.Add(self.nb, 1, wx.EXPAND | wx.ALL, 5)

        page = self.makeGraphPage(self.nb)
        self.nb.AddPage(page, "Graph")

        page = self.makeResultsPage(self.nb)
        self.nb.AddPage(page, "Results")

        page = self.makeCalsPage(self.nb)
        self.nb.AddPage(page, "Calibrations")

        page = self.makeFillPage(self.nb)
        self.nb.AddPage(page, "Fill")

        page = self.makeOwnerPage(self.nb)
        self.nb.AddPage(page, "Owner")

        page = self.makeInfoPage(self.nb)
        self.nb.AddPage(page, "Tank Info")

        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.OnPageChanged)

        self.update_menus(self.id)
        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.Show(True)

    # ----------------------------------------------
    def OnPageChanged(self, event):
        """ When notebook page changes, remember which page
            we are at, and store the page name, database table,
            and listbox that are used on that page.
        """

        self.id = 0
        page_num = event.GetSelection()
        page = self.nb.GetPageText(page_num)
        self.listbox = self.getListBoxFromName(page)
        self.table = self.getTableFromName(page)
        self.update_menus(self.id)
        event.Skip()

    # ----------------------------------------------
    def getListBoxFromName(self, name):
        """ Convert page name to wx listbox on that page """

        if name == "Calibrations":
            listbox = self.calibrations
        elif name == "Fill":
            listbox = self.fill
        elif name == "Owner":
            listbox = self.owner
        elif name == "Tank Info":
            listbox = self.info
        else:
            listbox = None

        return listbox

    # ----------------------------------------------
    def getTableFromName(self, name):
        """ Convert page name to database table used on that page """

        if name == "Calibrations":
            table = "calibrations"
        elif name == "Fill":
            table = "fill"
        elif name == "Owner":
            table = "owner"
        elif name == "Tank Info":
            table = "tankinfo"
        else:
            table = ""

        return table

    # ----------------------------------------------
    def getSn(self, evt):
        """ Get the serial number from the search control """

        self.sn = self.sernum.GetValue()
        self.edit_menu.Enable(204, True)
        self.setPages()

    # ----------------------------------------------
    def setPages(self):
        """ Update all of the notebook pages with results for the
            serial number of the tank entered by the user.
        """

        # Update the graph, results and calibration pages
        self.results(self.sn, self.graph_species, self.syslist)

        # Update the list pages.
#        pagelist = ["Calibrations", "Fill", "Owner", "Tank Info"]
        pagelist = ["Fill", "Owner", "Tank Info"]
        for page in pagelist:
            listbox = self.getListBoxFromName(page)
            table = self.getTableFromName(page)
            query = "SELECT * from reftank.%s WHERE serial_number='%s' " % (table, self.sn)
            if page != "Tank Info":
                query += "ORDER BY date "

            result = self.db.doquery(query)
            listbox.DeleteAllItems()
            if result is not None:
                for nr, row in enumerate(result):
                    index = listbox.InsertItem(nr, str(row['idx']))
                    for nf, field in enumerate(row):
                        listbox.SetItem(index, nf, str(row[field]))

                    if nr % 2 == 0:
                        listbox.SetItemBackgroundColour(index, wx.Colour(245, 245, 245))

        # Reset the selected row to 0, so we need to select a row to do anything again.
        self.id = 0
        self.update_menus(self.id)

    # ----------------------------------------------
    def setGas(self, evt):
        """ Get the gas species to plot on the graph page,
            and update the graph page and calibration results page.
        """

        self.graph_species = self.species.GetStringSelection()
        self.results(self.sn, self.graph_species)
        self.setPages()

    # ----------------------------------------------
    def makeGraphPage(self, nb):
        """ Make page with a graph for plotting calibration results """

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        self.graph = Graph(page, -1)
        box0.Add(self.graph, 1, wx.GROW | wx.ALL, 5)

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeResultsPage(self, nb):
        """ Make page with text for showing calibration results """

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        self.tc = wx.TextCtrl(page, -1, "", style=wx.TE_READONLY | wx.TE_MULTILINE)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.tc.SetFont(font)
        box0.Add(self.tc, 1, wx.EXPAND, 0)

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeCalsPage(self, nb):
        """ Make page with list of each calibration result """

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        listbox = self.makeListBox(page, 'calibrations')
        box0.Add(listbox, 1, wx.EXPAND, 0)
        self.calibrations = listbox

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeFillPage(self, nb):
        """ Make page with tank filling information """

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        listbox = self.makeListBox(page, 'fill')
        box0.Add(listbox, 1, wx.EXPAND, 0)
        self.fill = listbox

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeOwnerPage(self, nb):
        """ Make page with list of tank ownership results """

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        listbox = self.makeListBox(page, 'owner')
        box0.Add(listbox, 1, wx.EXPAND, 0)
        self.owner = listbox

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeInfoPage(self, nb):
        """ Make page with list of tank information """

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        listbox = self.makeListBox(page, 'tankinfo')
        box0.Add(listbox, 1, wx.EXPAND, 0)
        self.info = listbox

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeListBox(self, page, table):
        """ Make a list control that has a column for each field in the
            given database table.
        """

        listbox = wx.ListCtrl(page, -1, style=wx.LB_SINGLE | wx.LC_VRULES | wx.LC_HRULES)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        listbox.SetFont(font)

        if table == "calibrations":
            result = self.cal_fields
        else:
            query = "show columns from reftank.%s" % table
            result = self.db.doquery(query)  # , "reftank")
        for n, row in enumerate(result):
            name = row['Field']

            listbox.InsertColumn(n, name)
            listbox.SetColumnWidth(n, wx.LIST_AUTOSIZE_USEHEADER)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, listbox)
        self.Bind(wx.EVT_LIST_ITEM_RIGHT_CLICK, self.ItemRightClick, listbox)

#        listbox.InsertItem(0, "Row 0")  # This shuts up windows complaint

        return listbox

    # ----------------------------------------------
    def update_menus(self, which):
        """ Update the setting of the menu items """

        # wx seems to call a page changed event when the dialog is closed,
        # so this can get called when the menus don't exist anymore.  Put
        # it in a try/execpt to avoid error messages.
        try:
            if self.table == "calibrations":
                if which == 0:
                    self.edit_menu.Enable(200, False)   # edit
                else:
                    self.edit_menu.Enable(200, True)    # edit
#               self.edit_menu.Enable(201, True)    # add
            else:
                self.edit_menu.Enable(200, False)   # edit
#               self.edit_menu.Enable(201, False)   # add

        except:
            pass

    # ----------------------------------------------
    def OnItemSelected(self, event):
        """ If a line in a listbox is selected, remember
            the table index, which is the first column in
            the listbox.  The GetText function only returns
            the value from the first column, not the entire line.
        """

        self.id = int(event.GetText())
        self.currentItem = event.Index
        self.update_menus(self.id)

    # ----------------------------------------------
    def ItemRightClick(self, event):
        """ Right mouse click on a listCtrl.  Pop up a menu to
        allow editing the record that was clicked.
        """

        # make a menu
        menu = wx.Menu()
        # add some other items
#        m1 = menu.Append(1001, "Edit Record...")
#        m3 = menu.Append(1003, "Delete Record")
        if self.table == "calibrations":
            m1 = menu.Append(1001, "Edit Record...")
            menu.AppendSeparator()
#            m4 = menu.Append(1004, "View Raw File...")

        self.Bind(wx.EVT_MENU, self.showEditDialog, id=1001)
        self.Bind(wx.EVT_MENU, self.deleteRecord, id=1003)
        if self.table == "calibrations":
            self.Bind(wx.EVT_MENU, self.viewRawFile, id=1004)

        if self.id == 0:
            m1.Enable(False)
#            m3.Enable(False)

        # Popup the menu.  If an item is selected then its handler
        # will be called before PopupMenu returns.
        self.PopupMenu(menu)
        menu.Destroy()

    # ---------------------------------------------------------------------------
# !!! Should change this to call the cal_edit module instead !!!
    def viewRawFile(self, event):
        """ Get the raw file for a tank calibration and show it in
        a fileView dialog.
        """

        s = self.listbox.GetItem(self.currentItem, 2)
        date = s.GetText()
        s = self.listbox.GetItem(self.currentItem, 3)
        time = s.GetText()
        s = self.listbox.GetItem(self.currentItem, 4)
        gas = s.GetText()
        s = self.listbox.GetItem(self.currentItem, 9)
        inst = s.GetText()
        s = self.listbox.GetItem(self.currentItem, 10)
        system = s.GetText()

        a = date.split('-')
        year = int(a[0])
        month = int(a[1])
        day = int(a[2])
        a = time.split(':')
        hour = int(a[0])
        minute = int(a[1])

        filename = "%4d-%02d-%02d.%02d%02d.%s.%s" % (year,
                                                     month,
                                                     day,
                                                     hour,
                                                     minute,
                                                     inst.lower(),
                                                     gas.lower())
        dirname = "/ccg/%s/cals/%s/raw/%d" % (gas.lower(), system, year)

        rawfile = dirname + "/" + filename
        rawfile = get_path(rawfile)

        from caledit import calib
        frame = calib.calRaw(self, rawfile=rawfile, gas=gas.upper())
        frame.Show()
        frame.readFile(rawfile, gas, system, inst)

    # ---------------------------------------------------------------------------
    def deleteRecord(self, event):
        """ Delete a record from the database """

        if self.id == 0:
            return

        msg = "DELETE FROM %s WHERE idx=%d" % (self.table, self.id)
        dlg = wx.MessageDialog(self, msg, 'Delete Record?', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
        if dlg.ShowModal() == wx.ID_YES:
#            query = "DELETE FROM %s WHERE idx=%d LIMIT 1" % (self.table, self.id)
            query = "DELETE FROM %s WHERE idx=%d LIMIT 1"
            self.db.doquery(query, (self.table, self.id), commit=True)
#            myDb, c = ccg_db.dbConnect("reftank")
#            c.execute(query)
#            myDb.commit()
#            c.close()
#            myDb.close()
            self.setPages()
            self.SetStatusText("Deleted record, index # %d" % self.id)

        dlg.Destroy()

    # ---------------------------------------------------------------------------
    def showEditDialog(self, event):
        """ Show a dialog for changing the properties of a database record """

#        menuId = event.GetId()

        dlg = EditRecordDialog(self, -1, "Edit Record", size=(350, 800),
                               style=wx.DEFAULT_DIALOG_STYLE)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            self.SetStatusText("Edited record, index # %d." % self.id)
            self.setPages()

        dlg.Destroy()

    # ----------------------------------------------
    def search(self, event):
        """ Make a dialog for user to search tank serial numbers """

        try:
            self.searchdlg.Show()
        except:
            self.searchdlg = SearchDialog(self, -1, "Search Serial Numbers", size=(350, 800),
                                          style=wx.DEFAULT_DIALOG_STYLE)
            self.searchdlg.Show()

        val = self.searchdlg.ShowModal()
        if val == wx.ID_OK:
            if self.searchdlg.sn != "":
                self.sn = self.searchdlg.sn
                self.setPages()
                self.sernum.ChangeValue(self.sn)

        self.searchdlg.Hide()

    # ----------------------------------------------
    def systemid(self, event):
        """ Make a dialog for user to set system id's to use in results """

        self.sysiddlg = SystemIdDialog(self, -1, "Set System ID's", size=(350, 800),
                                       style=wx.DEFAULT_DIALOG_STYLE)
        self.sysiddlg.Show()

        val = self.sysiddlg.ShowModal()
        if val == wx.ID_OK:
            self.syslist = self.sysiddlg.idlist
            self.setPages()

        self.sysiddlg.Destroy()

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the menu bar for the main window """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

#        self.file_menu.Append (107, "Export...")
#        self.file_menu.AppendSeparator ()
        self.file_menu.Append(110, "Print Preview...")
        self.file_menu.Append(-1, "Print")

        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Close", "Close the window")

        self.Bind(wx.EVT_MENU, self.print_preview, id=110)
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.menuBar.Append(self.edit_menu, "Edit")

        self.edit_menu.Append(200, "Edit Record")
#        self.edit_menu.Append(201, "Add Record")
#        self.edit_menu.Append(202, "Delete Record")
        self.edit_menu.AppendSeparator()
        self.edit_menu.Append(203, "Search...")
        self.edit_menu.Append(204, "Set System ID's...")

        self.edit_menu.Enable(204, False)

        self.Bind(wx.EVT_MENU, self.showEditDialog, id=200)
        self.Bind(wx.EVT_MENU, self.deleteRecord, id=202)
        self.Bind(wx.EVT_MENU, self.search, id=203)
        self.Bind(wx.EVT_MENU, self.systemid, id=204)

        # ---------------------------------------
        menu = wx.Menu()
        self.menuBar.Append(menu, "View")

        menu.Append(300, "Statistics...")
        menu.Append(301, "Regression...")

        self.Bind(wx.EVT_MENU, self.stats, id=300)
        self.Bind(wx.EVT_MENU, self.regression, id=301)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def OnExit(self, e):
        """ Exit the main window """

        self.Close(True)  # Close the frame.

    # ----------------------------------------------
    def print_preview(self, event):
        """ show a print preview of the calibration results plot """

        self.graph.printPreview()

    # ----------------------------------------------
    def stats(self, evt):
        """ Show the statistics dialog for the plotted tank """

        statsdlg = StatsDialog(self, -1, graph=self.graph)
        statsdlg.CenterOnScreen()
        statsdlg.Show()

    # ----------------------------------------------
    def regression(self, evt):
        """ Show the regression dialog for the plotted tank """

        regresdlg = RegressionDialog(self, -1, graph=self.graph)
        regresdlg.CenterOnScreen()
        regresdlg.Show()

    # ----------------------------------------------
    def results(self, sernum, gas, syslist=None):
        """ List the results of calibrations for the given tank serial number.
            and plot the results.
        """

        self.graph.clear()

        if syslist is None:
            cals = ccg_cal_db.Calibrations(sernum, gas)
        else:
            s = ",".join(syslist)
            cals = ccg_cal_db.Calibrations(sernum, gas, syslist=s, official=True)

        output = cals.showResults()
        self.tc.ChangeValue(output)

        if len(cals.cals) > 0:
            prevcode = cals.cals[0]['fillcode']

            xp = []
            yp = []
            for line in cals.cals:
                x = line['dd']
                mr = line['mixratio']
                flag = line['flag']
                code = "%s" % line['fillcode']   # None fillcodes will get changes to 'None'
                if code != prevcode:
                    # Create the graph dataset
                    self.graph.createDataset(xp, yp, prevcode)
                    xp = []
                    yp = []
                    prevcode = code

                if flag == ".":
                    xp.append(x)
                    yp.append(mr)

            self.graph.createDataset(xp, yp, prevcode)

        self.graph.title.text = sernum + " (" + self.graph_species + ")"
        self.graph.update()

        # do calibrations listbox
        maxw = [0 for name in self.cal_fields]
        listbox = self.getListBoxFromName("Calibrations")
        listbox.DeleteAllItems()
        for nr, row in enumerate(cals.cals):
            index = listbox.InsertItem(nr, str(row['idx']))
            for nf, d in enumerate(self.cal_fields):
                fieldname = d['Field']
                listbox.SetItem(index, nf, str(row[fieldname]))
                size = self.GetTextExtent(str(row[fieldname]))
                w = size.GetWidth() + 30
                maxw[nf] = max(maxw[nf], w)

#                listbox.SetColumnWidth(nf, wx.LIST_AUTOSIZE)

            if nr % 2 == 0:
                listbox.SetItemBackgroundColour(index, wx.Colour(245, 245, 245))

        for nf, d in enumerate(self.cal_fields):
            cw = listbox.GetColumnWidth(nf)
            listbox.SetColumnWidth(nf, max(cw, maxw[nf]))


#####################################################################
class EditRecordDialog(wx.Dialog):
    """ A dialog for editing a single record in the database """

    def __init__(
        self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        self.index = int(parent.id)
        self.table = parent.table
        self.db = ccg_db_conn.ProdDB(db="reftank")

        # get list of dicts for each column of table
        query = "show columns from reftank.%s" % self.table
        result = self.db.doquery(query)

        query = "select * from %s where idx=%d" % (self.table, self.index)
        result2 = self.db.doquery(query)
        data = result2[0]  # get first item in list

        label = wx.StaticText(self, -1, "Editing record index %s" % self.index)
        box0.Add(label, 0, wx.ALIGN_CENTER | wx.ALL, 5)
        if self.table == "calibrations":
            label2 = wx.StaticText(self, -1, "Values for static fields come from the raw file.  Make changes there.")
            font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
            label2.SetFont(font)
            box0.Add(label2, 0, wx.ALIGN_CENTER | wx.ALL, 5)

        box1 = wx.FlexGridSizer(len(result), 2, 2, 2)
        box0.Add(box1, 1, wx.GROW | wx.ALL, 2)
        self.tclist = []    # this holds the text controls that are created
        self.fields = []    # this is the name of the field for each text control
        for row in result:
            name = str(row['Field'])

            if name != "idx":
                datatype = row['Type']
                label = wx.StaticText(self, -1, name)
                box1.Add(label, 0, wx.ALIGN_RIGHT | wx.RIGHT, 10)

                val = str(data[name])

                # allow editing only for the flag and notes fields.
#                if self.table != "calibrations" or  name == "flag" or name == "notes":
                if self.table == "calibrations" and name in ("flag", "notes"):
                    if datatype == "text":
                        tc = wx.TextCtrl(self, -1, val, style=wx.TE_MULTILINE, size=(250, 100))
                    elif 'decimal' in datatype:
                        tc = wx.TextCtrl(self, -1, val, size=(250, -1), validator=Validator(V_FLOAT))
                    elif 'int' in datatype:
                        tc = wx.TextCtrl(self, -1, val, size=(250, -1), validator=Validator(V_INT))
                    elif 'date' in datatype:
                        tc = wx.TextCtrl(self, -1, val, size=(250, -1), validator=Validator(V_DATE))
                    elif 'time' in datatype:
                        tc = wx.TextCtrl(self, -1, val, size=(250, -1), validator=Validator(V_TIME))
                    else:
                        length = getSize(datatype)
                        tc = wx.TextCtrl(self, -1, val, size=(250, -1))
                        tc.SetMaxLength(length)
                else:
                    tc = wx.StaticText(self, -1, val, size=(250, -1))
                    font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
                    tc.SetFont(font)

                box1.Add(tc, 0, wx.ALIGN_RIGHT | wx.ALL, 0)
                self.tclist.append(tc)
                self.fields.append(name)

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # ------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    # ---------------------------------------------------------------
    def ok(self, event):
        """ Apply the changes on the record to the database.
        """

        query = "UPDATE %s " % self.table

        for n, tc in enumerate(self.tclist):
            field = self.fields[n]
    #        if field != "idx":
            if self.table != "calibrations" or field == "flag" or field == "notes":
                val = tc.GetValue()
                if query.count("SET"):
                    query += ", "
                else:
                    query += "SET "
                query += "%s='%s'" % (field, val)

        query += " WHERE idx=%d" % self.index

        self.db.doquery(query, commit=True)

        self.EndModal(wx.ID_OK)


#####################################################################
class SearchDialog(wx.Dialog):
    """ A dialog to enter text for searching the database """

    def __init__(
        self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

        self.sn = ""
        self.db = ccg_db_conn.RO()

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        box1 = wx.BoxSizer(wx.HORIZONTAL)
        box0.Add(box1, 0, wx.ALL, 5)

        label = wx.StaticText(self, -1, "Search String: ")
        box1.Add(label, 0, wx.ALL, 0)

        self.tc = wx.SearchCtrl(self, size=(200, -1), style=wx.TE_PROCESS_ENTER)
        box1.Add(self.tc, 0, wx.ALL, 0)
        self.Bind(wx.EVT_TEXT_ENTER, self.setSn, self.tc)
        self.Bind(wx.EVT_SEARCHCTRL_SEARCH_BTN, self.setSn, self.tc)
        self.Bind(wx.EVT_SEARCHCTRL_CANCEL_BTN, self.setSn, self.tc)

        label = wx.StaticText(self, -1, " or ")
        box1.Add(label, 0, wx.ALL, 0)

        btn = wx.Button(self, -1, "Show All", style=wx.BU_EXACTFIT)
        box1.Add(btn, 0, wx.ALL, 0)
        self.Bind(wx.EVT_BUTTON, self.showall, btn)

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        label = wx.StaticText(self, -1, "Results: ")
        box0.Add(label, 0, wx.ALL, 5)

        self.listbox = wx.ListBox(self, -1, size=(-1, 400))
        box0.Add(self.listbox, 1, wx.EXPAND | wx.ALL, 5)
        self.Bind(wx.EVT_LISTBOX, self.selectItem, self.listbox)

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # ------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    # ---------------------------------------------------------------
    def setSn(self, event):
        """ Find all serial numbers that match the text in search text box """

        string = self.tc.GetValue()
        query = "select distinct serial_number from reftank.calibrations "
        query += "where serial_number like '%%%s%%' order by serial_number" % string
        result = self.db.doquery(query)
        snlist = []
        for row in result:
            snlist.append(row['serial_number'])

        self.sn = ""
        self.listbox.Set(snlist)

    # ---------------------------------------------------------------
    def showall(self, event):
        """ Get all serial numbers of tanks from database and show in listbox """

        query = "select distinct serial_number from reftank.calibrations order by serial_number"
        result = self.db.doquery(query)
        snlist = []
        for row in result:
            snlist.append(row['serial_number'])

        self.sn = ""
        self.listbox.Set(snlist)

    # ---------------------------------------------------------------
    def selectItem(self, event):
        """ Save the selected serial number """

        self.sn = self.listbox.GetStringSelection()

    # ---------------------------------------------------------------
    def ok(self, event):
        """ Exit the dialog """

        self.EndModal(wx.ID_OK)


#####################################################################
class SystemIdDialog(wx.Dialog):
    """ A dialog for  entering the system id's to get results for """

    def __init__(
        self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

        self.sn = parent.sn
        self.gas = parent.graph_species
        self.db = ccg_db_conn.RO(db="reftank")

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        label = wx.StaticText(self, -1, "Instrument ID's: ")
        box0.Add(label, 0, wx.ALIGN_LEFT | wx.ALL, 0)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 1)

        query = "select distinct inst from reftank.calibrations "
        query += "where serial_number=%s  and species=%s order by inst"  # % (self.sn, self.gas)
#        result = ccg_db.dbQueryAndFetch(query, database="reftank")
        result = self.db.doquery(query, (self.sn, self.gas))
        self.checkbuttons = []
        for row in result:
            sysid = row['inst']
            b1 = wx.CheckBox(self, -1, sysid)
            b1.SetValue(1)
            box0.Add(b1, 0, wx.TOP, 5)
            self.checkbuttons.append((sysid, b1))

        # ------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        # ------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    # ---------------------------------------------------------------
    def ok(self, event):
        """ Save selected id's and exit dialog """

        self.idlist = []
        for inst, b in self.checkbuttons:
            val = b.GetValue()
            if val:
                self.idlist.append(inst)

        self.EndModal(wx.ID_OK)


#####################################################################
def getSize(s):
    """ Get the size of a database field by looking at the number
    between the () in the string s, which is the data type string
    from a 'show columns' query.
    """

    p1 = s.find("(")
    if p1 < 0:
        return 0

    p2 = s.find(")")

    val = s[p1+1:p2]

    return int(val)
