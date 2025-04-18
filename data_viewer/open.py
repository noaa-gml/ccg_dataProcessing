# vim: tabstop=4 shiftwidth=4
"""
# Determine which station, gas and month to use
"""

import sys
import datetime
import wx

sys.path.append("/ccg/src/python/lib")

import dbutils


monthlist = [
	"January",
	"February",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"October",
	"November",
	"December"
]


##########################################################################
class OpenDialog(wx.Dialog):
	def __init__(self, parent=None, title="Open"):
		wx.Dialog.__init__(self, parent, -1, title)

		self.stations = {}
		self.data = self.getAvailableData()

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		sizer = self.mkSource(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

		sizer = self.mkTimespan(box0)
		box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

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
	def getAvailableData(self):


		db, c = dbutils.dbConnect("met", readonly=True)
#		sql = "show tables like '%hour'"
#		c.execute(sql)

#		list = c.fetchall()

		list = ["brw", "mlo", "smo", "spo", "thd", "sum"]

		data = []
#		for table in list:
#			(stacode, a) = table[0].split("_")
		for stacode in list:

			sql = "select name from gmd.site where code='%s'" % stacode
			c.execute(sql)
			name = c.fetchone()[0]

			data.append((stacode, name))

			if name not in self.stations:
				s = "%s %s" % (stacode.upper(), name)
				self.stations[s] = stacode


		c.close()
		db.close()

		return data


	#----------------------------------
	def mkSource(self, box0):

		# First static box sizer
		box = wx.StaticBox(self, -1, "Data Source")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

		# station choice box
		box1 = wx.BoxSizer(wx.HORIZONTAL)
		sizer.Add(box1, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.ALL)

		label = wx.StaticText(self, -1, "Station: ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		self.choice = wx.Choice(self, -1, choices=sorted(self.stations.keys()))
		self.choice.SetSelection(0)
		box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)


		return sizer

	#----------------------------------
	def mkTimespan(self, box0):
		now=datetime.datetime.today()
		this_year = int(now.strftime("%Y"))
		this_month = now.strftime("%B")

		# Second static box sizer
		box = wx.StaticBox(self, -1, "Time Span")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

		box1 = wx.FlexGridSizer(0, 2, 2, 2)
		sizer.Add(box1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Month: ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.month1 = wx.Choice(self, -1, choices=monthlist)
		self.month1.SetSelection(monthlist.index(this_month))
		box1.Add(self.month1, 0, wx.ALIGN_CENTRE|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Year: ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.byear = wx.SpinCtrl(self, -1, str(this_year), min=1973, max=this_year)
		box1.Add(self.byear, 0, wx.ALIGN_CENTRE|wx.ALL, 0)


		return sizer


	#----------------------------------
	def ok(self, event):

		station = self.choice.GetStringSelection()
		self.code = self.stations[station]

		self.year = int(self.byear.GetValue())

		month1 = self.month1.GetStringSelection()
		self.month = monthlist.index(month1) + 1

		self.EndModal(wx.ID_OK)

		return
