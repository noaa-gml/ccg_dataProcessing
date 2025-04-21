
import glob
import wx
import subprocess

import config

from graph.graph import Graph
from graph.dataset import Dataset

###############################################################
class mkMixingRatioPage(wx.Panel):
    def __init__(self, parent, sys ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = config.gases[0]

        box = wx.StaticBox(self, -1, "Mixing Ratio", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.rb = wx.RadioBox(self, -1, choices=config.gases)
        sizer.Add(self.rb)
        self.rb.Bind(wx.EVT_RADIOBOX, self.setGas)

	self.plot = Graph(self, -1)
	self.plot.showGrid = 1
	self.plot.showSubgrid = 1
	xaxis = self.plot.getXAxis(0)
	xaxis.scale_type = "time"

	sizer.Add(self.plot, 100, wx.EXPAND|wx.ALL, 5)
        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):

	self.doMRPlot(self.plot)

    #----------------------------------------------
    def setGas(self, evt):

        self.gas = self.rb.GetStringSelection()
        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def doMRPlot(self, graph):

	config.main_frame.SetStatusText ("Working...")

	# get list of data files (one per day), use the last mr_days
	# Then call the insitu processing program on the data files to get the mixing ratios.
        s = '%s/%s/data/*/*.%s' % (config.datadir, self.gas.lower(), self.gas.lower())
        list = glob.glob(s)
	list.sort()
	s = " ".join(list[-config.mr_days:])
	command = "%s/bin/ccgis.py -m -x %s %s" % (config.sysdir, self.gas.lower(), s)

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


	graph = self.plot
	graph.clear()
	graph.createDataset(x, y, name=self.gas)
	graph.legend.showLegend = 0
	graph.update()

	config.main_frame.SetStatusText ("")
