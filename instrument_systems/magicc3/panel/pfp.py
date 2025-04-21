
import sys
import errno
import os
import wx
import subprocess

import config
from utils import *

#--------------------------------------------------------------
class mkPFPInfo(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
	self.pfpfile = config.sysdir + "/pfp_table"

        box = wx.StaticBox(self, -1, "PFP Sample Information", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.HORIZONTAL)
        self.SetSizer(sizer)

	self.listbox = self.mkListBox()
	sizer.Add(self.listbox, 1, wx.ALL, 5)


	panel = wx.Panel(self, -1)
	sizer.Add(panel, 0, wx.ALL, 3)

	sizer2 = wx.BoxSizer(wx.VERTICAL)


	self.editbutton = wx.Button(panel, -1, "Download...")
	self.editbutton.Enable(False)
	sizer2.Add(self.editbutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.editEntry, self.editbutton)

	self.deletebutton = wx.Button(panel, -1, "Clear")
	self.deletebutton.Enable(False)
	sizer2.Add(self.deletebutton, -1, wx.ALL, 3)
        self.Bind(wx.EVT_BUTTON, self.deleteEntry, self.deletebutton)

	panel.SetSizer(sizer2)

	self.updateListBox()

    #--------------------------------------------------------------
    def mkListBox(self):

	listbox = wx.ListCtrl(self, -1, style=wx.LC_REPORT|wx.LC_SINGLE_SEL|wx.LC_VRULES|wx.LC_HRULES, size=(-1, 120))

	n = 0
	for name in ["Port Number", "Serial #", "Package ID", "Site", "Sample Date", "# Valid Samples"]:
                listbox.InsertColumn(n, name)
                n += 1

	listbox.SetColumnWidth(0, 100)
	listbox.SetColumnWidth(1,  80)
	listbox.SetColumnWidth(2, 100)
	listbox.SetColumnWidth(3,  80)
	listbox.SetColumnWidth(4, 100)
	listbox.SetColumnWidth(5, 120)

	self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, listbox)

	return listbox

    #--------------------------------------------------------------
    def updateListBox(self):
	"""
	Update the list box by searching for the pfp1, pfp3, pfp5, pfp7 files,
	reading their content and inserting into list
	"""

	self.listbox.DeleteAllItems()

	nr = 0
	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	for port in range(1,9,2):
		# port number on serial gear usb/serial box 1->5, 3->6, 5->7, 7->8
		usb = (int(port) + 1)/2 + 4

		pfpfile = config.sysdir + "/pfp" + str(port)
		if os.path.exists(pfpfile):
			f = open(pfpfile)
			n = 0
			for s in f:
				list = s.split()
				pfp_id = list[2]
				code = list[3]
				date = list[4]
				n += 1
			f.close()
		else:
			pfp_id = ""
			code = ""
			date = ""
			n = ""

		index = self.listbox.InsertStringItem(nr, str(port))
		self.listbox.SetItemFont(index, font)
		self.listbox.SetStringItem(index, 1, str(usb))
		self.listbox.SetStringItem(index, 2, pfp_id)
		self.listbox.SetStringItem(index, 3, code)
		self.listbox.SetStringItem(index, 4, date)
		self.listbox.SetStringItem(index, 5, str(n))
		nr += 1


    #--------------------------------------------------------------
    def OnItemSelected(self, evt):
        """ If a line in a listbox is selected, remember the row number.
        """
        self.currentItem = evt.m_itemIndex
	self.editbutton.Enable(True)
	self.deletebutton.Enable(True)

    #--------------------------------------------------------------
    def getDevFile(self, port):
	""" Get serial-usb device file name given carousel port number.
		carousel port 1 -> serial gear connector #5 -> device file /dev/ttyUSB4
		carousel port 3 -> serial gear connector #6 -> device file /dev/ttyUSB5
		carousel port 5 -> serial gear connector #7 -> device file /dev/ttyUSB6
		carousel port 7 -> serial gear connector #8 -> device file /dev/ttyUSB7
	"""

	usb = (int(port) + 1)/2 + 3
	dev = "/dev/ttyUSB" + str(usb)

	return dev

    #--------------------------------------------------------------
    def editEntry(self, evt):

	row = self.currentItem
	item = self.listbox.GetItem(row, 0)
	portnum = item.GetText()
	devfile = self.getDevFile(portnum)

	self.dlgpp = wx.ProgressDialog("PFP Download", "Downloading history data from pfp package at port %s (%s)" % (portnum, devfile))
	self.dlgpp.Pulse()

        command = "%s/bin/setup_pfp %s %s" % (config.sysdir, portnum, devfile)
	print(command)
	self.process = wx.Process(self)
	self.process.Redirect()
	pid = wx.Execute(command, wx.EXEC_ASYNC, self.process)

	# send event when process finishes, goto routine afterwards
	self.Bind(wx.EVT_END_PROCESS, self.OnProcessEnded)

	# set up timer to move progress gauge
	self.Bind(wx.EVT_TIMER, self.TimerHandler)
        self.timer = wx.Timer(self)
        self.timer.Start(100)

    #--------------------------------------------------------------
    def TimerHandler(self, evt):
	self.dlgpp.Pulse()

    #--------------------------------------------------------------
    def OnProcessEnded(self, evt):
	"""
	Process for downloading history info from pfp has ended.
	Check for errors, if none, update list
	"""

	self.timer.Stop()
	self.running = False
	self.dlgpp.Destroy()
	self.dlgpp = None

	stream = self.process.GetErrorStream()
	if stream.CanRead():
		text = stream.read()
		if text:
			s = "Error running command.\n" + text
			dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
			dlg.ShowModal()
			dlg.Destroy()
			return

	stream = self.process.GetInputStream()
        if stream.CanRead():
		text = stream.read()
		print(text)

        self.process.Destroy()
        self.process = None

	self.updateListBox()
	self.update_table()

	return


    #--------------------------------------------------------------
    def deleteEntry(self, evt):

	row = self.currentItem
	self.listbox.SetStringItem(row, 2, "")
	self.listbox.SetStringItem(row, 3, "")
	self.listbox.SetStringItem(row, 4, "")
	self.listbox.SetStringItem(row, 5, "")

	self.update_table()

	item = self.listbox.GetItem(row, 0)
	port = item.GetText()
	pfpfile = config.sysdir + "/pfp" + port
	print(pfpfile)
	os.remove(pfpfile)
	
    #--------------------------------------------------------------
    def clearList(self, evt):

	self.listbox.ClearAll()
	os.remove(self.pfpfile)

    #--------------------------------------------------------------
    def update_table(self):

	f = open(self.pfpfile, "w")

	for row in range(0, 4):

		port = self.listbox.GetItem(row, 0).GetText()
#		port = item.GetText()
		s = self.listbox.GetItem(row, 2).GetText()
#		s = item.GetText()
		if s: 
			f.write("%s %s\n" % (port, s))
		
	f.close()
