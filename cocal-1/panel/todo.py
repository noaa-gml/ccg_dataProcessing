import sys
import os
import wx
import wx.lib.mixins.listctrl as listmix
sys.path.append("/ccg/python/ccglib")
import ccg_dbutils
import ccg_db_conn
from dialogs import TankEntryDialog

######################################################################
class SortableListCtrl(wx.ListCtrl, listmix.ColumnSorterMixin):
    """ A sortable ListCtrl which contains the information on tanks from the
    mysql 'rgm_buildTodoList' procedure call
    """

    def __init__(self, parent):
        wx.ListCtrl.__init__(self, parent, -1, style=wx.LC_REPORT|wx.LC_VRULES|wx.LC_HRULES|wx.LC_SORT_ASCENDING)

        names, sample_data, column_data = self.getData()

        self.itemDataMap = column_data # data to shown in listctrl
        self.sampleData = sample_data # data kept separately, needed by TodoDialog

        for n, label in enumerate(names):
            self.InsertColumn(n, label)
            if len(label) < 5:
                self.SetColumnWidth(n, 150)
            else:
                self.SetColumnWidth(n, -2)

        # allow list to be sorted on a column by clicking on column headers
        listmix.ColumnSorterMixin.__init__(self, self.GetColumnCount())

        for rownum,row in enumerate(column_data):
            index = self.InsertItem(rownum, str(row[0]))
            for fieldnum, value in enumerate(row):
                self.SetItem(index, fieldnum, str(value))

            self.SetItemData(index, rownum)


    #----------------------------------------------
    def GetListCtrl(self):
        return self


    #----------------------------------------------
    def getData(self, searchstr=None):
        """ Update the listctrl with todo items 
        Call the stored procedure to get available items.
        """

#        db, c = dbutils.dbConnect("refgas_orders")
        db = ccg_dbutils.dbUtils()
#        c.callproc("rgm_buildTodoList", [1, 103])
        results=db.doquery("call refgas_orders.rgm_buildTodoList(%s,%s)",(3,103))

        #result = c.fetchall()
        #desc = c.description

        # The first 4 columns of this procedure call will always be serial number, tank pressure, regulator, request number
        # Save these 4 columns separately from the columns that are shown in the listctrl.
        # We'll convert from listctrl row number to data row number using self.SetItemData and self.GetItemData,
        # which will return the correct data for a given listctrl row number, even if listctrl is sorted by different columns

        #names = []
        #for t in desc:
        #    colname = t[0]
        #    names.append(colname)
        names = list(results[0].keys())

        sample_data = []
        column_data = []
        for row in results:
#            print(row)
            key = names[0]
            sample_data.append([row[key] for key in names[0:4]])
            column_data.append([row[key] for key in names[4:]])

        #sample_data = []
        #column_data = []
        #for row in result:
        #    sample_data.append(tuple([str(field) for field in row[0:4]]))
        #    column_data.append(tuple([str(field) for field in row[4:]]))

        return names[4:], sample_data, column_data


######################################################################
class TodoDialog(wx.Frame):
    """ Class for working with calibration to do lists """

    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, -1, title, wx.DefaultPosition, wx.Size(850, 650))

        self.id = 0
        self.parent = parent
        self.currentItem = None

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()

        # A list control with sortable columns mixin for showing database entries
        self.listbox = SortableListCtrl(self)
        self.sizer.Add(self.listbox, 1, wx.EXPAND|wx.ALL, 2)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.ItemClick, self.listbox)
        self.Bind(wx.EVT_LIST_ITEM_RIGHT_CLICK, self.ItemRightClick, self.listbox)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.Show(True)

    #----------------------------------------------
    def ItemClick(self, evt):

        self.currentItem = evt.Index


    #----------------------------------------------
    def ItemRightClick(self, evt):

        self.currentItem = evt.Index
        #print self.currentItem

        # make a menu
        menu = wx.Menu()
        # add some other items
        m1 = menu.Append(1001, "Use This Record...")

#        wx.EVT_MENU(self, 1001, self.showEditDialog)
        self.Bind(wx.EVT_MENU, self.showEditDialog, id=1001)

        # Popup the menu.  If an item is selected then its handler
        # will be called before PopupMenu returns.
        self.PopupMenu(menu)
        menu.Destroy()

   #---------------------------------------------------------------------------
    def showEditDialog(self, event):
        """ Show a dialog for changing the properties of a database record """

        # don't do anything if a row is not selected
        if self.currentItem is None: return
        
        # starting point for manifold/port
        port = 1
        if self.parent.manifold:
            manifold = self.parent.manifold
        else:
            manifold = "A"

        if self.parent.port:
            port = self.parent.port
            if port > 16: port = 1
        else:
            port = 1
            
        #print("self.manifold: %s   self.port: %s" % (self.parent.manifold, self.parent.port))
        #print("     manifold: %s             port: %s" % (manifold, port))

        # convert table row number to data row number, that is, 
        # map the selected item row number to actual row in data list
        n = self.listbox.GetItemData(self.currentItem)

        # get the data for the selected item from listbox saved columns
        (sernum, pressure, regulator, reqnum) = self.listbox.sampleData[n]

        data = []
        data.append(manifold)  
        data.append(port)  # port number
        data.append(sernum)
        data.append(pressure)
        data.append(regulator)
        data.append("8")  # num aliquots
        data.append(reqnum)

        # create a dialog for editing the tank information
        dlg = TankEntryDialog(self, -1, "Edit Record", data = data)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            self.parent.add_entry_to_list(dlg.data)


        dlg.Destroy()


    #----------------------------------------------
    def MakeMenuBar(self):
        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(101, "Close", "Close the window")

        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
#        wx.EvtHandler.Bind(self, 101, self.OnExit)

        #---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append (self.view_menu, "Edit")

        self.view_menu.Append(301, "Add Selected Record to List")

        self.Bind(wx.EVT_MENU, self.showEditDialog, id=301)
#        wx.EvtHandler.Bind(self, 301, self.showEditDialog)


        self.SetMenuBar(self.menuBar)


    #----------------------------------------------
    def OnExit(self, e):
        self.Close(True)  # Close the frame.

