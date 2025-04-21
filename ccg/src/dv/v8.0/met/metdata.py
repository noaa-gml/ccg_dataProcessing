# vim: tabstop=4 shiftwidth=4

import os
import sys
import calendar
import glob
import datetime
import wx


from open import *
#from data import *
from dataWindow import *

sys.path.append("/ccg/src/python")
from graph4.toolbars import *

sys.path.append("/ccg/src/python/lib")
import dbutils

ONEDAY = datetime.timedelta(days=1)

##################################################################################
class MetEdit(wx.Frame):
	def __init__(self, parent, ID, title):
		wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(910, 800))

		self.overlay = 1

		# Make the menu bar
		self.MakeMenuBar()

		# and status bar
		self.sb = self.CreateStatusBar()

		# Main sizer to hold toolbars and graphs
		self.sizer = wx.BoxSizer(wx.VERTICAL)

		self.datebar = self.mkDatesBar()
		self.sizer.Add(self.datebar, 0, wx.EXPAND, 0)

		line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
		self.sizer.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 0)

		# Make the zoom toolbar, add to main sizer
		self.zoomtb = ZoomToolBar(self)
		self.sizer.Add(self.zoomtb, 0, wx.EXPAND)
		self.zoomtb.Enable(False)


		line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
		self.sizer.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 0)

		sw = wx.SplitterWindow(self, -1, style = wx.SP_LIVE_UPDATE)
		self.sizer.Add(sw, 1, wx.EXPAND, 0)
		sw.SetSashGravity(0.5)

		#-------------------------------
		p1 = dataWindow(sw, self.sb, 0)
		p2 = dataWindow(sw, self.sb, 1)

		self.dw = []
		self.dw.append(p1)
		self.dw.append(p2)

		self.zoomtb.SetGraph(p1.plot)
		self.zoomtb.SetGraph(p2.plot)

		#-------------------------------
		today = datetime.datetime.today()
		self.year = today.year
		self.month = today.month
		(a, self.daysinmonth) = calendar.monthrange(self.year, self.month)
		self.startday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
		self.endday = datetime.datetime(self.year, self.month, self.daysinmonth, 0, 0, 0)

		sw.SplitHorizontally(p1, p2, 0)

		self.SetSizer(self.sizer)


	#----------------------------------------------
	def mkDatesBar(self):

		p = wx.Panel(self)
		box1 = wx.BoxSizer(wx.HORIZONTAL)
		p.SetSizer(box1)

		box2 = wx.FlexGridSizer(0,2,2,2)

		label = wx.StaticText(p, -1, "Start Day: ")
		box2.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.startdayofmonth = wx.Slider(p, -1, 1, 1,31, size=(250, -1), style=wx.SL_HORIZONTAL | wx.SL_AUTOTICKS | wx.SL_LABELS)
		self.startdayofmonth.SetPageSize(1)
		box2.Add(self.startdayofmonth, 0, wx.ALIGN_LEFT|wx.ALL, 0)
		self.Bind(wx.EVT_SLIDER, self.get_startday, self.startdayofmonth)

		label = wx.StaticText(p, -1, "End Day: ")
		box2.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 20)
		self.enddayofmonth = wx.Slider(p, -1, 1, 1,31, size=(250, -1), style=wx.SL_HORIZONTAL | wx.SL_AUTOTICKS | wx.SL_LABELS)
		self.enddayofmonth.SetPageSize(1)
		box2.Add(self.enddayofmonth, 0, wx.ALIGN_LEFT|wx.ALL, 0)
		self.Bind(wx.EVT_SLIDER, self.get_endday, self.enddayofmonth)
		box1.Add(box2)


		label = wx.StaticText(p, -1, " OR Single Day: ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 5)

		self.day = wx.Slider(p, -1, 1, 1,31, size=(250, -1), style=wx.SL_HORIZONTAL | wx.SL_AUTOTICKS | wx.SL_LABELS)
		self.day.SetPageSize(1)
		box1.Add(self.day, 0, wx.ALIGN_LEFT|wx.ALL, 0)
		self.Bind(wx.EVT_SLIDER, self.get_day, self.day)


		label = wx.StaticText(p, -1, " OR ")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.LEFT, 5)

		btn = wx.Button(p, -1, "Entire Month")
		box1.Add(btn, 0, wx.ALIGN_CENTRE|wx.LEFT, 5)
		self.Bind(wx.EVT_BUTTON, self.getmonth, btn)

                # back and forward buttons for going to previous and next raw file
#                b = wx.Button(p, wx.ID_BACKWARD)
#                box1.Add(b, 0, wx.ALL, 5)
 #               box1.Add(b, 0, wx.ALIGN_CENTRE|wx.LEFT, 20)
  #              self.prev = b
   #             self.Bind(wx.EVT_BUTTON, self.previousMonth, b)

    #            b = wx.Button(p, wx.ID_FORWARD)
     #           box1.Add(b, 0, wx.ALIGN_CENTRE|wx.LEFT, 5)
      #          self.next = b
       #         self.Bind(wx.EVT_BUTTON, self.nextMonth, b)


		p.Enable(False)


		return p

	#----------------------------------------------
	def MakeMenuBar(self):
		self.menuBar = wx.MenuBar()

		self.file_menu = wx.Menu()
		self.menuBar.Append(self.file_menu, "&File");

		self.file_menu.Append (102, "Open...")
		self.file_menu.AppendSeparator ()
		self.file_menu.Append(103, "Previous Month")
		self.file_menu.Append(104, "Next Month")
#		self.file_menu.AppendSeparator ()
#		self.file_menu.Append (110, "Print Preview...")
#		self.file_menu.Append (-1, "Print")

		self.file_menu.AppendSeparator ()
		self.file_menu.Append(101, "Exit", "Exit the program")

		wx.EVT_MENU(self, 102, self.opendata)
#		wx.EVT_MENU(self, 110, self.print_preview)
		wx.EVT_MENU(self, 101, self.OnExit)
		wx.EVT_MENU(self, 103, self.previousMonth)
		wx.EVT_MENU(self, 104, self.nextMonth)

		self.file_menu.Enable(103, False)
		self.file_menu.Enable(104, False)


		self.SetMenuBar(self.menuBar)


	#----------------------------------------------
	def get_startday(self, event):
		""" value of start day slider has changed """

		startday = self.startdayofmonth.GetValue()
		self.startday = datetime.datetime(self.year, self.month, startday, 0, 0, 0)
		if self.startday > self.endday:
			self.endday = self.startday
			self.enddayofmonth.SetValue(startday)
		self.enddayofmonth.SetPageSize(1)
		self.updatePlots()
		event.Skip()

	#----------------------------------------------
	def get_endday(self, event):
		""" value of end day slider has changed """

		endday = self.enddayofmonth.GetValue()
		self.endday = datetime.datetime(self.year, self.month, endday, 0, 0, 0)
		if self.endday < self.startday:
			self.startday = self.endday
			self.startdayofmonth.SetValue(endday)
		self.updatePlots()
		event.Skip()


	#----------------------------------------------
	# Pick a single day of the month
	def get_day(self, event):
		""" value of day of month slider has changed """

		day = self.day.GetValue()
		self.startday = datetime.datetime(self.year, self.month, day, 0, 0, 0)
		self.endday = datetime.datetime(self.year, self.month, day, 0, 0, 0)

		self.startdayofmonth.SetValue(day)
		self.enddayofmonth.SetValue(day)

		self.updatePlots()


		event.Skip()

	#----------------------------------------------
	# Get data for the entire month
	def getmonth(self, event):
		""" entire month button was clicked """

		self.startday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
		self.endday = datetime.datetime(self.year, self.month, self.daysinmonth, 0, 0, 0)

		self.startdayofmonth.SetValue(self.startday.day)
		self.enddayofmonth.SetValue(self.endday.day)

		self.updatePlots()
		event.Skip()

	#----------------------------------------------
	def previousMonth(self, event):
		""" previous month menu button was clicked """

		self.month -= 1
		if self.month == 0:
			self.month = 12
			self.year -= 1

		self.GetMonth()

	#----------------------------------------------
	def nextMonth(self, event):
		""" next month menu button was clicked """

		self.month += 1
		if self.month == 13:
			self.month = 1
			self.year += 1

		self.GetMonth()

	#----------------------------------------------
	# Pick a new station and month of data.
	# When opening a new month of data,
	# reset the plots to the full month
	def opendata(self, e):
		try:
			self.opendlg.Show()
		except:
			self.opendlg = OpenDialog(self)
			self.opendlg.CenterOnScreen()

		# this does not return until the dialog is closed.
		val = self.opendlg.ShowModal()
		if val == wx.ID_OK:
			self.code = self.opendlg.code
			self.year = self.opendlg.year
			self.month = self.opendlg.month

			self.GetMonth()

	#----------------------------------------------
	def GetMonth(self):
		""" Get a month of data from database and files, 
		update widgets and plots
		 """

		self.SetStatusText("Getting data from database...")
		self.SetCursor(wx.StockCursor(wx.CURSOR_WAIT))

		# reset the start and end days to be the entire month
		(a, self.daysinmonth) = calendar.monthrange(self.year, self.month)
		self.startday = datetime.datetime(self.year, self.month, 1, 0, 0, 0)
		self.endday = datetime.datetime(self.year, self.month, self.daysinmonth, 0, 0, 0)

		# update the plots
		for n, datawindow in enumerate(self.dw):
			datawindow.setOptions(self.code, self.year, self.month, self.daysinmonth, self.startday, self.endday, default=n)
			datawindow.updateParams()


		# update the widgets
		self.startdayofmonth.SetRange(1, self.daysinmonth)
		self.startdayofmonth.SetValue(self.startday.day)
		self.startdayofmonth.SetPageSize(1)
		self.enddayofmonth.SetRange(1, self.daysinmonth)
		self.enddayofmonth.SetValue(self.endday.day)
		self.enddayofmonth.SetPageSize(1)
		self.day.SetRange(1, self.daysinmonth)
		self.day.SetPageSize(1)
		self.day.SetValue(self.startday.day)

		self.datebar.Enable(True)
		self.zoomtb.Enable(True)
		self.file_menu.Enable(103, True)		# previous month
		self.file_menu.Enable(104, True)		# next month

		self.SetStatusText("")

	#----------------------------------------------
	# start and end days have changed. update the plots, but don't read in new data
	def updatePlots(self):

		for datawindow in self.dw:
			datawindow.setOptions(self.code, self.year, self.month, self.daysinmonth, self.startday, self.endday)
			datawindow.update()


	#----------------------------------------------
	def OnExit(self,e):
		self.Close(True)  # Close the frame.
