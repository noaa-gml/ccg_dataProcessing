# vim: tabstop=4 shiftwidth=4
"""
# Create a dialog to allow editing the 'raw' voltage values, and
changing the flag.
"""
from __future__ import print_function

import os
import sys
from numpy import isnan
import wx

sys.path.append("/ccg/src/python3/lib")
import ccg_utils

from graph4.graph import Graph

from flagedit import FlagEditDialog

formats = ["%s", "%11.5e", "%9.3e", "%3d", "%s", "%s"]


###################################################################
class FlagVoltList(wx.ListCtrl):
	""" A list control showing dates and voltages of the raw lines """

	def __init__(self, parent):

		# make a copy of the datalist
		self.datalist = parent.voltlist[:]
		self.code = parent.code

		wx.ListCtrl.__init__(self, parent, -1, size=(580, 400), style=wx.LC_REPORT|wx.LC_VIRTUAL|wx.LC_HRULES|wx.LC_VRULES)

		self.InsertColumn(0, "Date", width=200)
		self.InsertColumn(1, "Value", width=100)
		self.InsertColumn(2, "Unc", width=90)
		self.InsertColumn(3, "N", width=40)
		self.InsertColumn(4, "Type", width=90)
		self.InsertColumn(5, "Flag", width=55)
#		self.Bind(wx.EVT_LIST_ITEM_RIGHT_CLICK, self.ItemRightClick, self)

#		index = listbox.InsertStringItem(0, "Row 0")  # This shuts up windows complaint

		font = wx.Font(10, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
		self.SetFont(font)
		self.SetItemCount(len(self.datalist))

		self.attr1 = wx.ListItemAttr()
		self.attr1.SetBackgroundColour(wx.Colour(240, 240, 240))

	#----------------------------------------------
	def OnGetItemText(self, item, col):
		""" this gets called everytime a new cell in the listbox needs to be shown """

		return formats[col] % self.datalist[item][col]

	#----------------------------------------------
	def OnGetItemAttr(self, index):
		""" this gets called everytime a new cell in the listbox needs to be shown """

		date = self.datalist[index][0]
		hour = date.hour
		if hour % 2 == 0:
			return self.attr1
		else:
			return None


##########################################################################
class FlagVoltDialog(wx.Dialog):
	""" A dialog that allows the user to select raw lines, and change
		the voltage value or flag.
	"""

	def __init__(self, parent=None, title="Flag"):
		wx.Dialog.__init__(self, parent, -1, title)

		self.voltlist = parent.voltlist
		self.code = parent.code

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		sizer = self.mkList()
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		box1 = wx.BoxSizer(wx.HORIZONTAL)
		box0.Add(box1)

		btn = wx.Button(self, -1, "Edit Flag")
		self.Bind(wx.EVT_BUTTON, self.edit, btn)
		box1.Add(btn, 0, wx.ALL, 5)

		btn = wx.Button(self, -1, "Edit Voltage")
		self.Bind(wx.EVT_BUTTON, self.voltedit, btn)
		box1.Add(btn, 0, wx.ALL, 5)

		line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
		box0.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)

		btnsizer = wx.StdDialogButtonSizer()

		btn = wx.Button(self, wx.ID_CANCEL)
		btnsizer.AddButton(btn)
		btn = wx.Button(self, wx.ID_OK)
		btn.SetDefault()
		self.Bind(wx.EVT_BUTTON, self.ok, btn)

		btnsizer.AddButton(btn)
		btnsizer.Realize()

		box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

		self.SetSizer(box0)
		box0.SetSizeHints(self)

	#----------------------------------
	def mkList(self):
		""" Create a custom list box to show voltage data to flag or edit """

		# First static box sizer
		box = wx.StaticBox(self, -1, "Data Source")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

		t = wx.StaticText(self, -1, "Highlight lines, then click 'Edit Flag' or 'Edit Voltage'")
		font = wx.Font(10, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_NORMAL)
		t.SetFont(font)
		sizer.Add(t)


		self.listbox = FlagVoltList(self)
		sizer.Add(self.listbox, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		return sizer

	#----------------------------------
	def edit(self, event):
		""" edit the flag for a voltage """

		index = self.listbox.GetFirstSelected()

		if index == -1:
			dlg = wx.MessageDialog(self, "Select one or more lines", 'Warning', wx.OK | wx.ICON_ERROR)
			dlg.ShowModal()
			dlg.Destroy()
			return

		item = self.listbox.GetItem(index, 5)
		self.edit_flag = item.GetText()

		self.sel_list = []
		while index != -1:
			self.sel_list.append(index)
			index = self.listbox.GetNextSelected(index)

		# Create a dialog for editing the flag for the selected line.
		dlg = FlagEditDialog(self, self.edit_flag)

		# this does not return until the dialog is closed.
		val = dlg.ShowModal()
		if val == wx.ID_OK:
			flag = dlg.flag

			# for each selected item, replace the flag in the data list
			for index in self.sel_list:
				a = self.listbox.datalist[index]
				t = list(a)
				t[5] = flag
				self.listbox.datalist[index] = tuple(t)

			self.listbox.Refresh()

	#----------------------------------
	def voltedit(self, event):
		""" Edit the voltage value for a raw line """

		index = self.listbox.GetFirstSelected()

		if index == -1:
			dlg = wx.MessageDialog(self, "Select one or more lines", 'Warning', wx.OK | wx.ICON_ERROR)
			dlg.ShowModal()
			dlg.Destroy()
			return

		vdlg = EditVoltDialog(self, self.listbox.datalist[index], self.code)

		# this does not return until the dialog is closed.
		val = vdlg.ShowModal()
		if val == wx.ID_OK:
			volt = vdlg.newvolt
			sdev = vdlg.newsd
			nv = vdlg.newnv
			flag = vdlg.flag
			print(volt, sdev, nv)

			# replace the voltage, sdev, n and flag in datalist
			a = self.listbox.datalist[index]
			t = list(a)
			t[1] = volt
			t[2] = sdev
			t[3] = nv
			t[5] = flag
			self.listbox.datalist[index] = tuple(t)

			self.listbox.Refresh()

	#----------------------------------
	def ok(self, event):
		""" Processing of the changed flags is done in grapher.py """

		self.EndModal(wx.ID_OK)

		return

###################################################################
class EditVoltDialog(wx.Dialog):
	""" Create a dialog to edit the voltage value for a raw line.
		This can be done either graphically by drawing out the
		section of voltages to use for an average, or manually by
		entering the desired voltage.
	"""

	def __init__(self, parent, data, code, title="Edit Voltages"):
		wx.Dialog.__init__(self, parent, -1, title, wx.DefaultPosition, size=wx.Size(750, 500), style=wx.RESIZE_BORDER|wx.CAPTION|wx.CLOSE_BOX)

		self.code = code

		(date, volt, sdev, num, smptype, flag) = data
		yr = date.year
		mo = date.month
		dy = date.day
		hr = date.hour
		print(yr, mo, dy, hr, data)
		self.orig_volt = volt
		self.orig_sdev = sdev
		self.orig_num = num
		self.orig_flag = flag

		self.x, self.y = self.getHourVolts(yr, mo, dy, hr)
#		self.x = x
#		self.y = y

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)


		box1 = wx.BoxSizer(wx.HORIZONTAL)
		box0.Add(box1, 0, wx.ALL, 2)

		label = wx.StaticText(self, -1, "Type:")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 5)
		label = wx.StaticText(self, -1, smptype)
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 3)


		label = wx.StaticText(self, -1, "Voltage:")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 15)

		self.volt = wx.TextCtrl(self, -1, str(volt), size=(100, -1))
		box1.Add(self.volt, 0, wx.ALIGN_CENTRE|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Std. Dev.:")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 15)

		self.sdev = wx.TextCtrl(self, -1, str(sdev), size=(100, -1))
		box1.Add(self.sdev, 0, wx.ALIGN_CENTRE|wx.ALL, 0)

		label = wx.StaticText(self, -1, "# points:")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 15)

		self.nv = wx.TextCtrl(self, -1, str(num), size=(100, -1))
		box1.Add(self.nv, 0, wx.ALIGN_CENTRE|wx.ALL, 0)

		btn = wx.Button(self, -1, "Reset")
		self.Bind(wx.EVT_BUTTON, self.reset, btn)
		box1.Add(btn, 0, wx.ALIGN_CENTRE|wx.LEFT, 15)

		self.plot = self.mkGraph()
		self.plot.createDataset(self.x, self.y, 'Voltages', color='red', symbol='none', linecolor='red')
		s = "%s %s Hour %s" % (self.code.upper(), date, hr)
		self.plot.title.text = s
		box0.Add(self.plot, 1, wx.GROW|wx.ALL, 5)

		line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
		box0.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)

		btnsizer = wx.StdDialogButtonSizer()

		btn = wx.Button(self, wx.ID_CANCEL)
		btnsizer.AddButton(btn)
		btn = wx.Button(self, wx.ID_OK)
		btn.SetDefault()
		self.Bind(wx.EVT_BUTTON, self.ok, btn)

		btnsizer.AddButton(btn)
		btnsizer.Realize()

		box0.Add(btnsizer, 0, wx.ALIGN_RIGHT|wx.ALL, 5)

		self.SetSizer(box0)
#		box0.SetSizeHints(self)

	#----------------------------------
	def getHourVolts(self, year, month, day, hour):
		""" Get the 10 sec voltages from file for the given date and hour """

		gas = "co2"
		code = self.code

		x = []
		y = []
		filename = "/ccg/%s/in-situ/%s_data/data/%s/%d%02d%02d.%s" % (gas, code, year, year, month, day, gas)
		print(filename)
		if os.path.exists(filename):
			f = open(filename)
			for line in f:
				a = line.split()
				hr = int(a[3])

				if hr == hour:
					yp = float(a[6])
					if isnan(yp):
						continue
					minute = int(a[4])
					sec = int(a[5])
					xp = minute + sec/60.0
					x.append(xp)
					y.append(yp)

			f.close()

		return x, y


	#----------------------------------------------
	def mkGraph(self):
		""" Create a graph for plotting an hours worth of 10 second voltages """

		plot = Graph(self, -1, xaxis_title="Minute of the hour")
		axis = plot.getXAxis(0)
		axis.setAxisRange(0, 60, 5, 5, exact=True)
		plot.legend.showLegend = 0
		plot.showGrid = 1
#           plot.SetLocation(60,-150, 20, -40)
 #          plot.popup.format = "decimalmonth"
 #          plot.pointLabelPopup.format = "decimalmonth"

		plot.setSelectionEnabled(True)
		plot.Bind(wx.EVT_LEFT_UP, self.endSelection)

		return plot

	#----------------------------------
	def endSelection(self, event):
		""" User has selected an area from the graph.  Find all the voltage values
			inside the area and calculate an average.
		"""

		(x1, x2, y1, y2) = self.plot.getSelection()
		print(x1, x2, y1, y2)

		# find data points inside the selected region
		xa = []
		ya = []
		for x, y in zip(self.x, self.y):
			if x >= x1 and x <= x2 and y >= y1 and y <= y2:
				xa.append(x)
				ya.append(y)

		avg, sd = ccg_utils.meanstdv(ya)
		n = len(ya)

		self.volt.SetValue("%.5e" % avg)
		self.sdev.SetValue("%.3e" % sd)
		self.nv.SetValue("%d" % n)


	#----------------------------------
	def reset(self, event):
		""" Reset the voltage value back to its original value """

		self.volt.SetValue(str(self.orig_volt))
		self.sdev.SetValue(str(self.orig_sdev))
		self.nv.SetValue(str(self.orig_num))

	#----------------------------------
	def ok(self, event):
		""" Processing of the changed flags is done in inistu.py """

		self.newvolt = float(self.volt.GetValue())
		self.newsd = float(self.sdev.GetValue())
		self.newnv = int(self.nv.GetValue())
		self.flag = "*"

		self.EndModal(wx.ID_OK)

		return
