
import sys
import errno
import os
import wx

import config
from panel_utils import *

#--------------------------------------------------------------
class mkFlaskInfo(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
	self.samplefile = config.sysdir + "/sample_table"

        box = wx.StaticBox(self, -1, "Flask Sample Information", size=(10,10))
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

	panel.SetSizer(sizer2)


#        box = self.create()
#        sizer.Add(box, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

#	SetSaveButton(self, sizer, self.ok)

    #--------------------------------------------------------------
    def mkListBox(self):

	listbox = wx.ListCtrl(self, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)

	n = 0
	for name in ["Group", "Port", "ID", "Code", "Date", "Time", "Method"]:
                listbox.InsertColumn(n, name)
                n += 1


	try:
		f = open(self.samplefile)
	except:
		return listbox
		
	lines = f.readlines()
	f.close()

	# 1  1  0089-11 IPN 2012-12-19 12:00 N   0.00   0.00     0.0 ..  1    0.0  -99.0    0.0
	nr = 0
	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        for line in lines:
		list = line.split()
		if len(list) > 7:
			(group, port, id, sta, date, time, method, therest) = line.split(None, 7)
		else:
			(group, port, id, sta, date, time, method) = line.split()

		index = listbox.InsertStringItem(nr, group)
#		print "index is ", index
		listbox.SetItemFont(index, font)
		listbox.SetStringItem(index, 1, port)
		listbox.SetStringItem(index, 2, id)
		listbox.SetStringItem(index, 3, sta)
		listbox.SetStringItem(index, 4, date)
		listbox.SetStringItem(index, 5, time)
		listbox.SetStringItem(index, 6, method)
		nr += 1

	self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, listbox)

	return listbox

    #--------------------------------------------------------------
    def OnItemSelected(self, evt):
        """ If a line in a listbox is selected, remember the row number.
        """
        self.currentItem = evt.m_itemIndex
	self.editbutton.Enable(True)
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
	

        dlg = FlaskEntryDialog(self, -1, "Edit Record", data = data, size=(350, 800), style=wx.DEFAULT_DIALOG_STYLE)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
		(group, port, id, sta, date, time, method) = dlg.data
		index = self.currentItem
		self.listbox.SetStringItem(index, 0, group)
		self.listbox.SetStringItem(index, 1, port)
		self.listbox.SetStringItem(index, 2, id)
		self.listbox.SetStringItem(index, 3, sta)
		self.listbox.SetStringItem(index, 4, date)
		self.listbox.SetStringItem(index, 5, time)
		self.listbox.SetStringItem(index, 6, method)

		self.update_table()

    #--------------------------------------------------------------
    def addEntry(self, evt):

        dlg = FlaskEntryDialog(self, -1, "Add Record", size=(350, 800), style=wx.DEFAULT_DIALOG_STYLE)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
	if val == wx.ID_OK:
		font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
		(group, port, id, sta, date, time, method) = dlg.data
		n = self.listbox.GetItemCount()
		print(n)
		index = self.listbox.InsertStringItem(n, group)
		print("index is ", index)
		self.listbox.SetItemFont(index, font)
		self.listbox.SetStringItem(index, 1, port)
		self.listbox.SetStringItem(index, 2, id)
		self.listbox.SetStringItem(index, 3, sta)
		self.listbox.SetStringItem(index, 4, date)
		self.listbox.SetStringItem(index, 5, time)
		self.listbox.SetStringItem(index, 6, method)

		self.update_table()

    #--------------------------------------------------------------
    def deleteEntry(self, evt):

	self.listbox.DeleteItem(self.currentItem)

	self.update_table()
	
    #--------------------------------------------------------------
    def clearList(self, evt):

	self.listbox.ClearAll()
	os.remove(self.samplefile)

    #--------------------------------------------------------------
    def update_table(self):

	nitems = self.listbox.GetItemCount()
	numcols = self.listbox.GetColumnCount()

	f = open(self.samplefile, "w")

	for row in range(0, nitems):

		data = []
		for i in range(0, numcols):
			item = self.listbox.GetItem(row, i)
			s = item.GetText()
			data.append(s)

		line = "%2s %2s %8s %3s %s %s %1s" % tuple(data)
		f.write("%s\n" % line)
		
	f.close()

#####################################################################3333
class FlaskEntryDialog(wx.Dialog):
    def __init__(
            self, parent, ID, title, data=None, size=wx.DefaultSize, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

	print(data)
	if data:
		group = data[0]
		port = data[1]
		id = data[2]
		sta = data[3]
		date = data[4]
		time = data[5]
		(year, month, day) = date.split("-")
		(hour, minute) = time.split(":")
		meth = data[6]
	else:
		group = ""
		port = ""
		id = ""
		sta = ""
		year = ""
		month = ""
		day = ""
		hour = ""
		minute = ""
		meth = ""

	self.tclist = []

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

	txt = wx.StaticText(self, -1, "Enter the correct information for the flask to be analyzed.")
	box0.Add(txt, 0, wx.ALL, 2)

	box01 = wx.BoxSizer(wx.HORIZONTAL)
	box0.Add(box01, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)

	txt = wx.StaticText(self, -1, "Group")
	box01.Add(txt, 0, wx.ALL, 2)
	tc = wx.TextCtrl(self, -1, group )
	self.tclist.append(tc)
	box01.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	txt = wx.StaticText(self, -1, "Port Number")
	box01.Add(txt, 0, wx.ALL, 2)
	tc = wx.TextCtrl(self, -1, port )
	self.tclist.append(tc)
	box01.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	#---
        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)

        box1 = wx.FlexGridSizer(8,2,2,2)
        box0.Add(box1, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)

	label = wx.StaticText(self, -1, "Flask ID: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, id )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Station: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, sta )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Year: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, year )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Month: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, month )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Day: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, day )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Hour: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, hour )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Minute: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, minute )
	self.tclist.append(tc)
	box1.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

	label = wx.StaticText(self, -1, "Sample Method: ")
	box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
	tc = wx.TextCtrl(self, -1, meth )
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
		val = tc.GetValue()
		data.append(val)

	(group, port, id, sta, yr, mon, day, hr, min, meth) = data
	date = "%s-%02d-%02d" % (yr, int(mon), int(day))
	time = "%02d:%02d" % (int(hr), int(min))

	self.data = (group, port, id, sta, date, time, meth)


	self.EndModal(wx.ID_OK)
