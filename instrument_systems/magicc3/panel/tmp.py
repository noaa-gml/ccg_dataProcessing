#	try:
#		f = open (self.logfile, "w")
#		f.write(text)
#		f.close()
#		config.main_frame.SetStatusText ("Updated log file.")
#	except:
#		s = "%s" % sys.exc_info()[1]
#		config.main_frame.SetStatusText ("ERROR: %s" % (s))
#
#		dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
#		dlg.ShowModal()
#		dlg.Destroy()
