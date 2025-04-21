	#----------------------------------------------
	def flagvolt(self, e):
		"""
		Display a dialog for selecting times to apply a flag to the raw data lines.
		Then update the raw files with the flags.
		NOTE: This requires the user to be 'ccg' since raw files are owned by that user.
		"""

		self.flagvoltdlg = FlagVoltDialog(self)
		self.flagvoltdlg.CenterOnScreen()

		# this does not return until the dialog is closed.
		val = self.flagvoltdlg.ShowModal()
		if val == wx.ID_OK:

			self.SetStatusText("Updating raw files...")

			n = len(self.voltlist)
			changes = []
			for index in range(0, n):

				# get the items that might have changed
				xflag = self.flagvoltdlg.listbox.GetItem(index, 5).GetText()
#				xflag = item.GetText()
				item = self.flagvoltdlg.listbox.GetItem(index, 1)
				xvolt = float(item.GetText())
				item = self.flagvoltdlg.listbox.GetItem(index, 2)
				xsdev = float(item.GetText())
				item = self.flagvoltdlg.listbox.GetItem(index, 3)
				xnv = int(item.GetText())

				# get the original items
				(date, volt, sdev, nv, smptype, flag) = self.voltlist[index]

				# check if anything has changed
				if flag != xflag or volt != xvolt or xsdev != sdev or xnv != nv:

					# if so, copy new values into tuple, replace data in list
					t = (date, xvolt, xsdev, xnv, smptype, xflag)
					self.voltlist[index] = t

					# keep track of which ones changed
					changes.append(t)

			# if changes were made, update the raw files and reprocess the data
			if len(changes) > 0:

				print changes
				status = raw.updateRawFiles(self, self.gas, self.code, self.year, self.month, self.system, changes)
				if status == 0:
					self.reprocData()
					self.GetMonth()

			self.SetStatusText("")

		self.flagvoltdlg.Destroy()

	#--------------------------------------------------------------
	def reprocData(self):
		"""
		Need to rerun the in-situ raw processing program since changing flags
		or modifying voltages on raw files can affect the mixing ratios calculated.
		Something like
		python /ccg/src/python/ccgis.py -u /ccg/ch4/in-situ/xxx_data/raw/2010/2010-xx-*.ch4
		"""

		# mixing ratios
		files = "/ccg/%s/in-situ/%s_data/raw/%4d/%4d-%02d-*.%s" % (self.gas, self.code.lower(), self.year, self.year, self.month, self.gas)

		prog = "/ccg/src/python/ccgis.py"
		com = "python %s -u %s %s %s" % (prog, self.code, self.gas, files)

		self.SetStatusText("Processing raw files with %s..." % com)

		print com
		status = 0

#		status, output = commands.getstatusoutput(com)
		if status != 0:
			dlg = wx.MessageDialog(self, output, 'Warning', wx.OK | wx.ICON_ERROR)
			dlg.ShowModal()
			dlg.Destroy()
			return

		# target cals
		com = "python %s -g -u %s %s %s" % (prog, self.code, self.gas, files)

		self.SetStatusText("Processing raw files with %s..." % com)
		print com
		status = 0

#		status, output = commands.getstatusoutput(com)
		if status != 0:
			dlg = wx.MessageDialog(self, output, 'Warning', wx.OK | wx.ICON_ERROR)
			dlg.ShowModal()
			dlg.Destroy()
			return


	#--------------------------------------------------------------
	def recalcData(self, event):
		""" Recalculate data by running the processing programs """

		self.reprocData()
		self.GetMonth()
		self.SetStatusText("")
