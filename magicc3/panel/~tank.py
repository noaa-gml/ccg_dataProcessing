
import sys
import errno
import os
import wx

import config
from utils import *

import  wx.lib.mixins.listctrl  as  listmix

sys.path.append("/ccg/src/python/lib")
import dbutils

#--------------------------------------------------------------
class mkTankInfo(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
	self.tankfile = config.sysdir + "/sys.tank_list"
	self.tankfile_done = config.sysdir + "/sys.tank_list_done"
	self.conffile = config.sysdir + "/" + config.conffile
	self.resources = self.get_resources(self.conffile)
        self.t2 = wx.Timer(self)


        box = wx.StaticBox(self, -1, "Tank Sample Information.  Valid ports 101-116 and 201 - 216", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.HORIZONTAL)
        self.SetSizer(sizer)

	self.listbox = self.mkListBox()
	sizer.Add(self.listbox, 1, wx.EXPAND|wx.ALL, 5)


	panel = wx.Panel(self, -1)
	sizer.Add(panel, 0, wx.ALL, 3)

	sizer2 = wx.BoxSizer(wx.VERTICAL)

	b1 = wx.Button(panel, -1, "Clear List")
	sizer2.Add(b1, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.clearList, b1)

	b4 = wx.Button(panel, -1, "New...")
	sizer2.Add(b4, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.addEntry, b4)

	b5 = wx.Button(panel, -1, "Pick from TODO List")
	sizer2.Add(b5, -1, wx.ALL, 3)
	self.Bind(wx.EVT_BUTTON, self.pickFromTODO, b5)

	self.editbutton = wx.Button(panel, -1, "Edit/Rerun...")
	self.editbutton.Enable(False)
	sizer2.Add(self.editbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.editEntry, self.editbutton)

	self.deletebutton = wx.Button(panel, -1, "Delete")
	self.deletebutton.Enable(False)
	sizer2.Add(self.deletebutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.deleteEntry, self.deletebutton)

	self.movetopbutton = wx.Button(panel, -1, "Move to top")
	self.movetopbutton.Enable(False)
	sizer2.Add(self.movetopbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.moveEntrytop, self.movetopbutton)

	self.moveupbutton = wx.Button(panel, -1, "Move up")
	self.moveupbutton.Enable(False)
	sizer2.Add(self.moveupbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.moveEntryup, self.moveupbutton)

	self.movedownbutton = wx.Button(panel, -1, "Move down")
	self.movedownbutton.Enable(False)
	sizer2.Add(self.movedownbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.moveEntrydown, self.movedownbutton)

	panel.SetSizer(sizer2)

        self.Bind(wx.EVT_TIMER, self.refreshPage)


    #--------------------------------------------------------------
    def mkListBox(self):

	listbox = wx.ListCtrl(self, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)

	n = 0
	for name in ["Port #", "Serial_Number", "Pressure", "Regulator", "# Aliquots", "Completed"]:
                listbox.InsertColumn(n, name)
                n += 1


	try:
		f = open(self.tankfile)
	except:
		return listbox

	lines = f.readlines()
	f.close()

	nr = 0
#	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        for line in lines:
		(portnum, sn, press, reg, naliq) = line.split()

		index = listbox.InsertStringItem(nr, sn)
#		listbox.SetItemFont(index, font)
		listbox.SetStringItem(index, 0, portnum)
		listbox.SetStringItem(index, 1, sn)
		listbox.SetStringItem(index, 2, press)
		listbox.SetStringItem(index, 3, reg)
		listbox.SetStringItem(index, 4, naliq)

		nr += 1

	listbox.SetColumnWidth(0, -2)
	listbox.SetColumnWidth(1, -2)
	listbox.SetColumnWidth(2, -2)
	listbox.SetColumnWidth(3, -2)
	listbox.SetColumnWidth(4, -2)
	listbox.SetColumnWidth(5, -2)

	self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, listbox)

	# read completed file list and add 'completed' in column if cal is done
	self.check_done(listbox)

	return listbox


    #--------------------------------------------------------------
    def check_done(self, listbox):

	try:
		f = open(self.tankfile_done)
	except:
		return

	lines = f.readlines()
	f.close()

	nitems = listbox.GetItemCount()
	for row in range(0, nitems):

		item = listbox.GetItem(row, 1)
		sernum = item.GetText()
		listbox.SetStringItem(row, 5, "")
		for line in lines:
			(portnum, sn, press, reg, naliq ) = line.split()
			if sernum == sn:
				listbox.SetStringItem(row, 5, "Completed")
				break

    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def updatePage(self):
        if self.listbox.IsShownOnScreen():
                self.check_done(self.listbox)
#                self.t2.Start(config.page_refresh)
                self.t2.Start(10000)

        else:
                self.t2.Stop()


    #--------------------------------------------------------------
    def OnItemSelected(self, evt):
        """ If a line in a listbox is selected, remember the row number.
        """
        self.currentItem = evt.m_itemIndex
	self.editbutton.Enable(True)
	self.movetopbutton.Enable(True)
	self.moveupbutton.Enable(True)
	self.movedownbutton.Enable(True)
	self.deletebutton.Enable(True)

    #--------------------------------------------------------------
    #OffItemSelected()
    def OffItemSelected(self):
        """ Turn off buttons
        """
        self.currentItem = -1
	self.editbutton.Enable(False)
	self.movetopbutton.Enable(False)
	self.moveupbutton.Enable(False)
	self.movedownbutton.Enable(False)
	self.deletebutton.Enable(False)

	self.listbox.Select(self.currentItem, 0)

    #--------------------------------------------------------------
    def editEntry(self, evt):

	numcols = self.listbox.GetColumnCount()

	data = []
	for i in range(0, numcols):
		item = self.listbox.GetItem(self.currentItem, i)
        	s = item.GetText()
		data.append(s)
		#print "line to edit is ", s
	

        dlg = TankEntryDialog(self, -1, "Edit Record", data = data)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
		index = self.currentItem

		self.add_entry_to_list(dlg.data, index)

		self.OffItemSelected()

    #--------------------------------------------------------------
    def RemoveFromDoneList(self, serialnum):
	"""
	Remove an entry from "done" list (file sys.tank_list_done)
	"""
	#read in list of "done" tanks
	try:
		f = open(self.tankfile_done)
	except:
		return

	donelines = f.readlines()
	f.close()

	#rewrite file of "done" tanks without the current entry
	try:
		f = open(self.tankfile_done, "w")
	except:
		return
	
	for line in donelines:
		(portnum, sn, press, reg, naliq) = line.split()
		if sn.upper() == serialnum.upper():
		    pass
		else:
		    f.write(line)
	f.close()
	return
    
    #--------------------------------------------------------------
    def moveEntrytop(self, evt):
	#move entry up
	position = 0
	idx = self.currentItem
	#if idx != 0:
	#	position = idx - 1

	self._move_current_item(position)


    #--------------------------------------------------------------
    def moveEntryup(self, evt):
	#move entry up

	position = 0
	idx = self.currentItem
	if idx != 0:
		position = idx - 1

	self._move_current_item(position)


    #--------------------------------------------------------------
    def moveEntrydown(self, evt):
	#move entry down
	position = self.listbox.GetItemCount() - 1
	idx = self.currentItem
	if idx != position:
		position = idx + 1

	self._move_current_item(position)


    #--------------------------------------------------------------
    def _move_current_item(self, position):

#	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)

	numcols = self.listbox.GetColumnCount()
	data = []
	for i in range(0, numcols):
		item = self.listbox.GetItem(self.currentItem, i)
        	s = item.GetText()
		data.append(s)

	self.listbox.DeleteItem(self.currentItem)
	self.listbox.InsertStringItem(position, data[0])
#	self.listbox.SetItemFont(position, font)

	for i in range(1, len(data)):
		self.listbox.SetStringItem(position, i, data[i])


	self.update_table()
	self.updatePage()
	self.OffItemSelected()


    #--------------------------------------------------------------
    def addEntry(self, evt):

        dlg = TankEntryDialog(self, -1, "Add Record")
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
		self.add_entry_to_list(dlg.data)


    #--------------------------------------------------------------
    def add_entry_to_list(self, data, index=None):

	print("index is", index)
#	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	(portnum, sn, press, reg, naliq) = data
	n = self.listbox.GetItemCount()

	if index is None:
		index = self.listbox.InsertStringItem(n, sn)

#	self.listbox.SetItemFont(index, font)

	#check port to make sure valid
	valid_port = self.check_sample_port(portnum)
	if valid_port:
	    self.listbox.SetStringItem(index, 0, portnum)
	else:
	    self.listbox.SetStringItem(index, 0, portnum)
	    s = "Port# %s is not defined in %s, Re-enter sample information with valid sample port number" % (portnum, self.conffile)
	    dlg = wx.MessageDialog(self, s, 'Warning', style=wx.OK | wx.ICON_WARNING)
	    dlg.ShowModal()
	    dlg.Destroy()
		    
	self.listbox.SetStringItem(index, 1, sn)
	self.listbox.SetStringItem(index, 2, press)
	self.listbox.SetStringItem(index, 3, reg)
	self.listbox.SetStringItem(index, 4, naliq)
	self.RemoveFromDoneList(sn)
		    
	self.update_table()

    #--------------------------------------------------------------
    def pickFromTODO(self, evt):

	try:
		self.tododlg.Show()
	except:
		self.tododlg = TodoDialog(self, "Pick From Todo List")
		self.tododlg.Show()

	self.tododlg.Raise()


    #--------------------------------------------------------------
    def deleteEntry(self, evt):

	serialnum = self.listbox.GetItem(self.currentItem, 0)
	self.RemoveFromDoneList(serialnum.GetText())
	
	self.listbox.DeleteItem(self.currentItem)

	self.update_table()
	self.OffItemSelected()
	
    #--------------------------------------------------------------
    def clearList(self, evt):

	self.listbox.DeleteAllItems()
	os.remove(self.tankfile)
	#os.remove(self.tankfile_done)
	f = open(self.tankfile_done, "w")
	f.close()

    #--------------------------------------------------------------
    def update_table(self):

	nitems = self.listbox.GetItemCount()
	numcols = self.listbox.GetColumnCount() - 1  # skip completed column
	#print "nitems, numcols", nitems, numcols

	f = open(self.tankfile, "w")

	for row in range(0, nitems):

		data = []
		for i in range(0, numcols):
			item = self.listbox.GetItem(row, i)
			s = item.GetText()
			if s == "": s = "---"
			data.append(s)

		line = "%s %s %s %s %s" % tuple(data)
		f.write("%s\n" % line)
		
	f.close()

    ############################################################
    # code to read conf file used by hm.  Use to get actual valve name
    # and port number for sample ports.  Code copied from hm.py.  Eventually
    # should put hm.py version into a hm utils so it can be imported
    # resources = get_resources(CONFFILE)
    # conffile defined in panel/config.py
    def get_resources(self, configfile):
	    """
	    Read in the configuration file, and store the name:value
	    resources from the file in the 'resources' dict.  
	    Also for lines that start with 'device', save info for that
	    device in separate dict.
	    DON'T USE DEVICE SECTION HERE
	    """
    
	    try:
		    fp = open(configfile)
	    except IOError as err:
		    logging.error("Cannot open configuration file. %s" % (err))
		    sys.exit(err)
    
	    resources = {}
	    #devices = {}
	    for line in fp:
		    line = self.clean_line(line)
		    if line: 
			    (name, value) = line.split(None, 1)
			    name = name.lower()
			    if name == "device":
				    pass
				    #(devname, bus, devfile, addr, baud) = value.split()
				    #devname = devname.lower()
				    #devices[devname] = device.Device(devname, bus, devfile, addr, baud)
			    else:
				    resources[name] = value
    
	    #return devices, resources
	    return resources
    
    
    #############################################################
    # from hm.py code.  Eventually move to a hm utils so it can
    # be imported.
    def clean_line(self, line):
	    """ 
	    Remove unwanted characters from line,
	    such as leading and trailing white space, new line,
	    and comments
	    """
    
	    line = line.strip('\n')			# get rid on new line
	    line = line.split('#')[0]		# discard '#' and everything after it
	    line = line.strip()			# strip white space from both ends
	    line = line.replace("\t", " ")		# replace tabs with spaces
    
	    return line


    #############################################################
    #bad_port = check_sample_port(portnum)
    def check_sample_port(self, port):
	"""
	check to make sure entered port is listed in the hm config file
	returns valid = 1 if good port number
	        valid = 0 if bad port number
	"""
	#get actual valve name and port# from listed portnum in conf file
	#portname="SMP%s" % portnum
	#valvename, portnum = resources[portname.lower()].split()
	#portnum = int(portnum)
	valid = 0
	portname = "SMP%s" % port
	
	if portname.lower() in self.resources:
	    valid = 1
	    
	return valid


#####################################################################3333
class TankEntryDialog(wx.Dialog):
    def __init__(
            self, parent, ID, title, data=None, size=wx.DefaultSize, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

	if data:
		portnum = data[0]
		serialnum = data[1]
		pressure = data[2]
		regulator = data[3]
		numaliquots = data[4]
		#portnum = data[4]
	else:
		portnum = ""
		serialnum = ""
		pressure = ""
		regulator = ""
		numaliquots = ""
		#portnum = ""

	self.tclist = []

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

	txt = wx.StaticText(self, -1, "Enter the correct information for the tank to be analyzed.", size=(-1,-1))
	box0.Add(txt, 0, wx.ALL, 10)

        box1 = wx.FlexGridSizer(5,2,2,2)
	box1.SetFlexibleDirection(wx.HORIZONTAL)
	box1.AddGrowableCol(1)
	box0.Add(box1, 1, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)

	label = wx.StaticText(self, -1, "Port Number: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
#	tc = wx.SpinCtrl(self, -1, portnum, min=1, max=16, size=(80, -1))
	tc = wx.TextCtrl(self, -1, portnum )
	self.tclist.append(tc)
	box1.Add(tc, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

	txt = wx.StaticText(self, -1, "Serial Number:")
	box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
	tc = wx.TextCtrl(self, -1, serialnum )
	self.tclist.append(tc)
	box1.Add(tc, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

	txt = wx.StaticText(self, -1, "Pressure:")
	box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
	tc = wx.TextCtrl(self, -1, pressure )
	self.tclist.append(tc)
	box1.Add(tc, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

	#---

#        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
#        box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)

#        box1 = wx.FlexGridSizer(8,2,2,2)
#        box0.Add(box1, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)

	label = wx.StaticText(self, -1, "Regulator: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
	tc = wx.TextCtrl(self, -1, regulator )
	self.tclist.append(tc)
	box1.Add(tc, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

	label = wx.StaticText(self, -1, "Number of Aliquots: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
	tc = wx.TextCtrl(self, -1, numaliquots, validator=Validator(V_INT) )
	self.tclist.append(tc)
	box1.Add(tc, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

#	label = wx.StaticText(self, -1, "Number of Isotope Aliquots: ")
#	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
#	tc = wx.TextCtrl(self, -1, num_iso, validator=Validator(V_INT) )
#	self.tclist.append(tc)
#	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

#	label = wx.StaticText(self, -1, "Port Number: ")
#	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
##	tc = wx.SpinCtrl(self, -1, portnum, min=1, max=16, size=(80, -1))
#	tc = wx.TextCtrl(self, -1, portnum )
#	self.tclist.append(tc)
#	box1.Add(tc, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)


        #------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)

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

    #------------------------------------------------
    def ok(self, evt):

	data = []
	for tc in self.tclist:
		val = str(tc.GetValue())
		data.append(val)

	self.data = data
	print(self.data)

	self.EndModal(wx.ID_OK)


######################################################################
class SortableListCtrl(wx.ListCtrl, listmix.ColumnSorterMixin):
    """ A sortable ListCtrl which contains the information on tanks from the
    mysql 'rgm_buildTodoList' procedure call
    """

    def __init__(self, parent):
        wx.ListCtrl.__init__(self, parent, -1, style=wx.LC_REPORT|wx.LC_VRULES|wx.LC_HRULES|wx.LC_SORT_ASCENDING)

	names, sample_data, column_data = self.getData()

	self.itemDataMap = column_data	# data to shown in listctrl
	self.sampleData = sample_data	# data kept separately, needed by TodoDialog

	for n, label in enumerate(names):
		self.InsertColumn(n, label)
		if len(label) < 5:
			self.SetColumnWidth(n, 150)
		else:
			self.SetColumnWidth(n, -2)

	# allow list to be sorted on a column by clicking on column headers
        listmix.ColumnSorterMixin.__init__(self, self.GetColumnCount())

	for rownum,row in enumerate(column_data):
		index = self.InsertStringItem(rownum, str(row[0]))
		for fieldnum, value in enumerate(row):
			self.SetStringItem(index, fieldnum, str(value))

		self.SetItemData(index, rownum)


    #----------------------------------------------
    def GetListCtrl(self):
        return self


    #----------------------------------------------
    def getData(self, searchstr=None):
	""" Update the listctrl with todo items 
	Call the stored procedure to get available items.
	"""

	db, c = dbutils.dbConnect("refgas_orders")
	c.callproc("rgm_buildTodoList", [1, 3])
	result = c.fetchall()
	desc = c.description

	# The first 3 columns of this procedure call will always be serial number, tank pressure, regulator.
	# Save these 3 columns separately from the columns that are shown in the listctrl.
	# We'll convert from listctrl row number to data row number using self.SetItemData and self.GetItemData,
	# which will return the correct data for a given listctrl row number, even if listctrl is sorted by different columns

	names = []
	for t in desc:
		colname = t[0]
		names.append(colname)

	sample_data = []
	column_data = []
	for row in result:
		sample_data.append(tuple([str(field) for field in row[0:3]]))
		column_data.append(tuple([str(field) for field in row[3:]]))

	return names[3:], sample_data, column_data


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

	self.currentItem = evt.m_itemIndex


    #----------------------------------------------
    def ItemRightClick(self, evt):

	self.currentItem = evt.m_itemIndex
#	print self.currentItem

	# make a menu
	menu = wx.Menu()
	# add some other items
	m1 = menu.Append(1001, "Use This Record...")

	wx.EVT_MENU(self, 1001, self.showEditDialog)

	# Popup the menu.  If an item is selected then its handler
	# will be called before PopupMenu returns.
	self.PopupMenu(menu)
	menu.Destroy()

   #---------------------------------------------------------------------------
    def showEditDialog(self, event):
        """ Show a dialog for changing the properties of a database record """

	# don't do anything if a row is not selected
	if self.currentItem is None: return

	# convert table row number to data row number, that is, 
	# map the selected item row number to actual row in data list
	n = self.listbox.GetItemData(self.currentItem)

	# get the data for the selected item
	(sernum, pressure, regulator) = self.listbox.sampleData[n]

        data = []
	data.append("-999")  # port number
	data.append(sernum)
	data.append(pressure)
	data.append(regulator)
	data.append("8")  # num aliquots

	# create a dialog for editing the tank information
        dlg = TankEntryDialog(self, -1, "Edit Record", data = data)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
                (sn, press, reg, naliq, portnum) = dlg.data
#		print sn, press, reg, naliq, portnum

		self.parent.add_entry_to_list(dlg.data)


        dlg.Destroy()


    #----------------------------------------------
    def MakeMenuBar(self):
        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(101, "Close", "Close the window")

        wx.EVT_MENU(self, 101, self.OnExit)

        #---------------------------------------
        self.view_menu = wx.Menu()
        self.menuBar.Append (self.view_menu, "Edit")

        self.view_menu.Append(301, "Add Selected Record to List")

	wx.EVT_MENU(self, 301, self.showEditDialog)


        self.SetMenuBar(self.menuBar)


    #----------------------------------------------
    def OnExit(self, e):
        self.Close(True)  # Close the frame.

