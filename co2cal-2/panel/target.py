

import os
import wx
import glob
import subprocess

import config

from graph.graph import Graph
from graph.dataset import Dataset

pages = { 0: 'Plot', 1: 'Table' }

#--------------------------------------------------------------
class mkTargetPage(wx.Panel):
    def __init__(self, parent, sys ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = config.gases[0]
	self.t2 = wx.Timer(self)

        box = wx.StaticBox(self, -1, "Target Cal Results", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.rb = wx.RadioBox(self, -1, choices=config.gases)
        sizer.Add(self.rb)
        self.rb.Bind(wx.EVT_RADIOBOX, self.setGas)


	self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

	plot = Graph(self.nb, -1)
	xaxis = plot.getXAxis(0)
	xaxis.scale_type = "time"
	plot.showGrid = 1
	plot.showSubgrid = 1
	self.nb.AddPage(plot, pages[0])

	self.tc = wx.TextCtrl(self.nb, -1, "", style=wx.TE_MULTILINE|wx.TE_WORDWRAP)
	font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	self.tc.SetFont(font)
	self.nb.AddPage(self.tc, pages[1])


	sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

	self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)
	self.Bind(wx.EVT_TIMER, self.refreshPage)

#	SetButtons(self, sizer, self.ok)

        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):
	if self.nb.IsShownOnScreen():
		page_num = self.nb.GetSelection()
		page = self.nb.GetCurrentPage()
		if page_num == 0:
			self.doTargetPlot(page)
		elif page_num == 1:
			txt = self.doTargetTable(page)
			page.ChangeValue(txt)


	else:
		self.t2.Stop()

    #----------------------------------------------
    def setGas(self, evt):

        self.gas = self.rb.GetStringSelection()
        self.updatePage()
        evt.Skip()


    #----------------------------------------------
    def refreshPage(self, evt):

	self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def doTargetPlot(self, graph):

        config.main_frame.SetStatusText ("Working...")

        # get list of raw files (one per day), use the last mr_days
        # Then call the insitu processing program on the raw files to get the mixing ratios.
        s = '%s/%s/data/*/*.%s' % (config.datadir, self.gas.lower(), self.gas.lower())
        list = glob.glob(s)
        list.sort()
        filelist = list[-config.tgt_days:]
        s = " ".join(filelist)

        command = "%s/bin/ccgis.py -g -m -x %s %s" % (config.sysdir, self.gas.lower(), s)

        file = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (txt, err) = file.communicate()
        if err:
                s = "Error running command.\n" + err
                dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return


        x = []
        y = []
        for line in txt.strip().split('\n'):
                xp,yp = list(map(float, line.split()))
                if yp > 0:
                        x.append(xp)
                        y.append(yp)

        graph.clear()
        graph.createDataset(x, y, name=self.gas)
        graph.legend.showLegend = 0
        graph.update()

        config.main_frame.SetStatusText ("")


    #----------------------------------------------
    def doTargetTable(self, tc):

        config.main_frame.SetStatusText ("Working...")

        # get list of raw files (one per day), use the last mr_days
        # Then call the insitu processing program on the raw files to get the mixing ratios.
        s = '%s/%s/data/*/*.%s' % (config.datadir, self.gas.lower(), self.gas.lower())
        list = glob.glob(s)
        list.sort()
        filelist = list[-config.tgt_days:]
        s = " ".join(filelist)

        command = "%s/bin/ccgis.py -g -m %s %s" % (config.sysdir, self.gas.lower(), s)

        file = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (txt, err) = file.communicate()
        if err:
                s = "Error running command.\n" + err
                dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

	result  = "   Date    Time    Value    s.d.\n"
	result += "----------------------------------\n"

        for line in txt.strip().split('\n'):
		result += line + "\n"

        config.main_frame.SetStatusText ("")

	return result
