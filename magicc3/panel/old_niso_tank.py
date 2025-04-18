
import sys
import errno
import os
import wx

import config
from utils import *

#--------------------------------------------------------------
class mkTankInfo(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
	self.tankfile = config.sysdir + "/sys.tank_list"
	self.tankfile_done = config.sysdir + "/sys.tank_list_done"
        self.t2 = wx.Timer(self)


        box = wx.StaticBox(self, -1, "Tank Sample Information", size=(10,10))
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

	self.editbutton = wx.Button(panel, -1, "Edit...")
	self.editbutton.Enable(False)
	sizer2.Add(self.editbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.editEntry, self.editbutton)

	self.deletebutton = wx.Button(panel, -1, "Delete")
	self.deletebutton.Enable(False)
	sizer2.Add(self.deletebutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.deleteEntry, self.deletebutton)

	b4 = wx.Button(panel, -1, "New...")
	sizer2.Add(b4, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.addEntry, b4)

	self.rerunbutton = wx.Button(panel, -1, "Re-Run")
	self.rerunbutton.Enable(False)
	sizer2.Add(self.rerunbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.rerunEntry, self.rerunbutton)

	panel.SetSizer(sizer2)

        self.Bind(wx.EVT_TIMER, self.refreshPage)

#        box = self.create()
#        sizer.Add(box, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

#	SetSaveButton(self, sizer, self.ok)

    #--------------------------------------------------------------
    def mkListBox(self):

	listbox = wx.ListCtrl(self, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)

	n = 0
	for name in ["Serial Number", "Pressure", "Regulator", "# CO2 Aliquots", "# Isotope Aliquots", "Port #", "Completed"]:
                listbox.InsertColumn(n, name)
                n += 1


	try:
		f = open(self.tankfile)
	except:
		return listbox

	lines = f.readlines()
	f.close()

	nr = 0
	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        for line in lines:
		(sn, press, reg, naliq, niso, portnum) = line.split()

		index = listbox.InsertStringItem(nr, sn)
		listbox.SetItemFont(index, font)
		listbox.SetStringItem(index, 1, press)
		listbox.SetStringItem(index, 2, reg)
		listbox.SetStringItem(index, 3, naliq)
		listbox.SetStringItem(index, 4, niso)
		listbox.SetStringItem(index, 5, portnum)

		nr += 1

	listbox.SetColumnWidth(0, -2)
	listbox.SetColumnWidth(1, -2)
	listbox.SetColumnWidth(2, -2)
	listbox.SetColumnWidth(3, -2)
	listbox.SetColumnWidth(4, -2)
	listbox.SetColumnWidth(5, -2)
	listbox.SetColumnWidth(6, -2)

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

		item = listbox.GetItem(row, 0)
		sernum = item.GetText()
		listbox.SetStringItem(row, 6, "")
		for line in lines:
			(sn, press, reg, naliq, niso, portnum) = line.split()
			if sernum == sn:
				listbox.SetStringItem(row, 6, "Completed")
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
	self.rerunbutton.Enable(True)
	self.deletebutton.Enable(True)

    #--------------------------------------------------------------
    def editEntry(self, evt):

	numcols = self.listbox.GetColumnCount()

	data = []
	for i in range(0, numcols):
		item = self.listbox.GetItem(self.currentItem, i)
        	s = item.GetText()
		data.append(s)
		print("line to edit is ", s)
	

        dlg = TankEntryDialog(self, -1, "Edit Record", data = data, size=(350, 800), style=wx.DEFAULT_DIALOG_STYLE)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
		(sn, press, reg, naliq, niso, portnum) = dlg.data
		index = self.currentItem
		self.listbox.SetStringItem(index, 0, sn)
		self.listbox.SetStringItem(index, 1, press)
		self.listbox.SetStringItem(index, 2, reg)
		self.listbox.SetStringItem(index, 3, naliq)
		self.listbox.SetStringItem(index, 4, niso)
		self.listbox.SetStringItem(index, 5, portnum)

		self.update_table()

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
		(sn, press, reg, naliq, niso, portnum) = line.split()
		if sn == serialnum:
		    pass
		else:
		    f.write(line)
	f.close()
	return
    
    #--------------------------------------------------------------
    def rerunEntry(self, evt):

	numcols = self.listbox.GetColumnCount()

	data = []
	for i in range(0, numcols):
		item = self.listbox.GetItem(self.currentItem, i)
        	s = item.GetText()
		data.append(s)

	serialnum = self.listbox.GetItem(self.currentItem, 0)

	#Allow info to be changed, ex change n aliquots for re-run
        dlg = TankEntryDialog(self, -1, "Edit Record", data = data, size=(350, 800), style=wx.DEFAULT_DIALOG_STYLE)
        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
#		#if ok, remove entry from "done" list
#		self.RemoveFromDoneList(serialnum)
		self.RemoveFromDoneList(serialnum.GetText())

		(sn, press, reg, naliq, niso, portnum) = dlg.data
		index = self.currentItem
		self.listbox.SetStringItem(index, 0, sn)
		self.listbox.SetStringItem(index, 1, press)
		self.listbox.SetStringItem(index, 2, reg)
		self.listbox.SetStringItem(index, 3, naliq)
		self.listbox.SetStringItem(index, 4, niso)
		self.listbox.SetStringItem(index, 5, portnum)

		self.update_table()
	else:
	    return
	
	self.updatePage()
		

    #--------------------------------------------------------------
    def addEntry(self, evt):

        dlg = TankEntryDialog(self, -1, "Add Record", size=(350, 800), style=wx.DEFAULT_DIALOG_STYLE)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
		font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
		(sn, press, reg, naliq, niso, portnum) = dlg.data
		n = self.listbox.GetItemCount()
		index = self.listbox.InsertStringItem(n, sn)
		self.listbox.SetItemFont(index, font)
		self.listbox.SetStringItem(index, 1, press)
		self.listbox.SetStringItem(index, 2, reg)
		self.listbox.SetStringItem(index, 3, naliq)
		self.listbox.SetStringItem(index, 4, niso)
		self.listbox.SetStringItem(index, 5, portnum)

		self.update_table()

    #--------------------------------------------------------------
    def deleteEntry(self, evt):

	serialnum = self.listbox.GetItem(self.currentItem, 0)
	self.RemoveFromDoneList(serialnum.GetText())
	
	self.listbox.DeleteItem(self.currentItem)

	self.update_table()
	
    #--------------------------------------------------------------
    def clearList(self, evt):

	self.listbox.DeleteAllItems()
	os.remove(self.tankfile)
	os.remove(self.tankfile_done)

    #--------------------------------------------------------------
    def update_table(self):

	nitems = self.listbox.GetItemCount()
	numcols = self.listbox.GetColumnCount() - 1  # skip completed column
	print("nitems, numcols", nitems, numcols)

	f = open(self.tankfile, "w")

	for row in range(0, nitems):

		data = []
		for i in range(0, numcols):
			item = self.listbox.GetItem(row, i)
			s = item.GetText()
			if s == "": s = "---"
			data.append(s)

		line = "%s %s %s %s %s %s" % tuple(data)
		f.write("%s\n" % line)
		
	f.close()

#####################################################################3333
class TankEntryDialog(wx.Dialog):
    def __init__(
            self, parent, ID, title, data=None, size=wx.DefaultSize, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

	print(data)
	print("here")
	if data:
		serialnum = data[0]
		pressure = data[1]
		regulator = data[2]
		numaliquots = data[3]
		num_iso = data[4]
		portnum = data[5]
	else:
		serialnum = ""
		pressure = ""
		regulator = ""
		numaliquots = ""
		num_iso = "2"
		portnum = ""

	self.tclist = []

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

	txt = wx.StaticText(self, -1, "Enter the correct information for the tank to be analyzed.")
	box0.Add(txt, 0, wx.ALL, 2)

        box1 = wx.FlexGridSizer(5,2,2,2)
	box0.Add(box1, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)

	txt = wx.StaticText(self, -1, "Serial Number:")
	box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, serialnum )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	txt = wx.StaticText(self, -1, "Pressure:")
	box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, pressure )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	#---

#        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
#        box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)

#        box1 = wx.FlexGridSizer(8,2,2,2)
#        box0.Add(box1, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)

	label = wx.StaticText(self, -1, "Regulator: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, regulator )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Number of Aliquots: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, numaliquots, validator=Validator(V_INT) )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Number of Isotope Aliquots: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, num_iso, validator=Validator(V_INT) )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Port Number: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.SpinCtrl(self, -1, portnum, min=1, max=16, size=(80, -1))
#	tc = wx.TextCtrl(self, -1, portnum )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)


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
