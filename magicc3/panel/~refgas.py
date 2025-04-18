
import os
import sys 
import wx
from datetime import datetime

import config
from utils import *

#--------------------------------------------------------------
class mkRefgasPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas
	self.tankfile = config.sysdir + "/sys.tanks"
	self.tank_info = {}
#	self.worktankfile = config.datadir + "/" + self.gas.lower() + "/worktanks"

        box = wx.StaticBox(self, -1, "Reference Gases", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)


        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)
	self.refgases = self.getRefgases()

	for pagenum, pagelabel in enumerate(sorted(self.refgases.keys())):
		#print "key = %s" % (pagelabel)
		page = self.mkPage(pagelabel)
                self.nb.AddPage(page, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

        self.SetSizer(sizer)
#        title = wx.StaticText(self, -1, "Enter correct serial number and mixing ratio.  Press 'Save' when done.")
#        title.SetFont(wx.Font(11, wx.SWISS, wx.NORMAL, wx.ITALIC))
#        sizer.Add(title, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


	SetSaveButton(self, sizer, self.ok)

    #--------------------------------------------------------------
    def mkPage(self, label):

	page = wx.Panel(self.nb, -1)

	#sizer = wx.FlexGridSizer(0, 5, 5, 8)
	sizer = wx.FlexGridSizer(0, 6, 5, 8)

	# first row is header labels
	tx = wx.StaticText(page, -1, "Sp")
	sizer.Add(tx, 0, wx.ALIGN_LEFT|wx.LEFT|wx.TOP, 10)
	tx = wx.StaticText(page, -1, "Set")
	sizer.Add(tx, 0, wx.ALIGN_LEFT|wx.LEFT|wx.TOP, 10)
	tx = wx.StaticText(page, -1, "ID")
	sizer.Add(tx, 0, wx.ALIGN_RIGHT|wx.LEFT|wx.TOP, 5)
	tx = wx.StaticText(page, -1, "Serial Number")
	sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 10)
	tx = wx.StaticText(page, -1, "Pressure")
	sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 10)
	tx = wx.StaticText(page, -1, "Regulator")
	sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 10)

	self.tank_info[label] = []

	# remaining rows are data
	for (sp, stdset, name, sernum, press, reg) in self.refgases[label]:
                tx1 = wx.StaticText(page, -1, sp, size=(125, -1))
                sizer.Add(tx1, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_LEFT)

                tx2 = wx.StaticText(page, -1, stdset, size=(125, -1))
                sizer.Add(tx2, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_LEFT)

                tx3 = wx.StaticText(page, -1, name, size=(50, -1))
                sizer.Add(tx3, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_LEFT)
		
                tx4 = wx.TextCtrl(page, -1, sernum, size=(150, -1))
                sizer.Add(tx4, 0, wx.ALIGN_RIGHT)
		
                tx5 = wx.TextCtrl(page, -1, press, size=(100, -1))
                sizer.Add(tx5, 0, wx.ALIGN_RIGHT)
		
                tx6 = wx.TextCtrl(page, -1, reg, size=(100, -1))
                sizer.Add(tx6, 0, wx.ALIGN_RIGHT)

		self.tank_info[label].append( (tx1, tx2, tx3, tx4, tx5, tx6) )

	page.SetSizer(sizer)
	return page

    #--------------------------------------------------------------
    def create(self):

	#refgases = self.getRefgases2()

#	sizer = wx.FlexGridSizer(0, 2+len(config.gases), 2, 2)
	sizer = wx.FlexGridSizer(0, 2, 2, 2)

	label = wx.StaticText(self, -1, "Tank")
	sizer.Add(label, 0, wx.ALIGN_RIGHT|wx.LEFT|wx.RIGHT, 10)
	label = wx.StaticText(self, -1, "Serial Number")
	sizer.Add(label, 0, wx.ALIGN_RIGHT|wx.LEFT|wx.RIGHT, 10)
#	for gas in ["CH4"]:
#		label = wx.StaticText(self, -1, "%s" % gas)
#		sizer.Add(label, 0, wx.ALIGN_CENTER|wx.ALL, 0)

	lines = self.getRefgases()
#	print lines
	self.tank_id = []
	self.tank_sernum = []
	self.tank_mr = []
	sernum = ""

	for name in config.refgas_labels:
#		print name

		values = []
		for (gas1, stdset, label, sn, press, regulator) in lines:
			if label == name:
				sernum = sn

		# make sure we get gases in the right order
#		for gas in config.gases:
#			for (gas1, label, sn) in lines:
#				if gas1 == gas and sn == sernum:
#					values.append(mr)
			
                label = wx.StaticText(self, -1, name)
                self.tank_id.append(label)
                sizer.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT|wx.RIGHT, 5)

                tx = wx.TextCtrl(self, -1, sernum, size=(100, -1))
                self.tank_sernum.append(tx)
                sizer.Add(tx, 0, wx.ALIGN_RIGHT|wx.LEFT|wx.RIGHT, 5)

#		for mr in values:
#			tx = wx.TextCtrl(self, -1, mr,  validator = Validator(V_FLOAT))
#			self.tank_mr.append(tx)
#			sizer.Add(tx, 0, wx.ALIGN_RIGHT|wx.LEFT|wx.RIGHT, 5)

	return sizer


    #--------------------------------------------------------------
    def getRefgases(self):

	refgases = {}

	if os.path.exists(self.tankfile):
		f = open(self.tankfile)
		for line in f:
			#(type, stdset, label, sn, pressure, regulator) = line.split()
			(sp, stdset, stdid, sn, pressure, regulator) = line.split()
			tmpkey = "%s" % ( stdset)
			#tmpkey = "%s_%s" % (type.upper(), stdset)
			#print tmpkey
			#if type not in refgases:
			if tmpkey not in refgases:
				#refgases[type] = []
				refgases[tmpkey] = []

			t = (sp, stdset, stdid, sn, pressure, regulator)
			#refgases[type].append(t)
			refgases[tmpkey].append(t)
	else:
		refgases["CH4"] = [("","R0", "", "", "")]

	return refgases


    #--------------------------------------------------------------
    def ok(self, event):

	tanklist = []
	for pagenum in range(self.nb.GetPageCount()):
		print("pagenum: %s" % pagenum, file=sys.stderr)
		label = self.nb.GetPageText(pagenum)
		print("label: %s" % label, file=sys.stderr)
		#tmplabel = self.nb.GetPageText(pagenum)
		#(sp, stdset) = label.split("_",1)
	
		for (t1, t2, t3, t4, t5, t6) in self.tank_info[label]:
			press = ""
			reg = ""
			sp = t1.GetLabel()
			stdset = t2.GetLabel()
			stdid = t3.GetLabel()
			sn = t4.GetValue()
			press = t5.GetValue()
			reg = t6.GetValue()

			if len(stdset)==0 or len(stdid)==0 or len(sn)==0:
				msg = "Error for %s, tank %s: missing data." % (label, val1)
				dlg = wx.MessageDialog(self, msg, 'Error', style=wx.OK | wx.ICON_ERROR)
				dlg.ShowModal()
				dlg.Destroy()
				return

			#s = "%5s %12s %5s %16s %10s %20s" % (sp, val1, val2, val3, val4, val5)
			s = "%5s %12s %5s %16s %10s %20s" % (sp, stdset, stdid, sn, press, reg)
			print("s:  %s" % s, file=sys.stderr)
			tanklist.append(s)
		
	os.rename(self.tankfile, self.tankfile+".bak")

	f = open(self.tankfile, "w")
	for line in tanklist:
		f.write(line + "\n")
	f.close

	config.main_frame.SetStatusText ("Updated reference tanks")

	return
