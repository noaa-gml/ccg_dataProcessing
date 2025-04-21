
import os
import wx
import glob
import subprocess
import sys

import config

from graph2.graph import Graph
from graph2.dataset import Dataset
from utils import *


#pages = { 0: 'N2O', 1: 'CO' }
#pages = { 0: 'CO2' }
pages = { 0: 'PC1 CO2', 1: 'AR1 CO2C13', 2: 'AR1 CO2O18', 3: 'AR1 CO2' }

###############################################################
class mkNLPage(wx.Panel):
    def __init__(self, parent, gas ):
	wx.Panel.__init__(self, parent, -1)

	self.gas = gas

        box = wx.StaticBox(self, -1, "Non-Linearity", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.rb = wx.RadioBox(self, -1, choices=["Response Curve", "Residuals"])
        sizer.Add(self.rb)
        self.rb.Bind(wx.EVT_RADIOBOX, self.refreshPage)

        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        for pagenum, pagelabel in pages.items():
                plot = Graph(self.nb, -1)
                plot.showGrid = 1
                plot.showSubgrid = 1

                self.nb.AddPage(plot, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)
        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)

	b1 = wx.Button(self, -1, "Refresh")
	sizer.Add(b1, 0, wx.ALL, 5)

        self.SetSizer(sizer)

        self.Bind(wx.EVT_TIMER, self.refreshPage)

    #----------------------------------------------
    def updatePage(self):

	page_num = self.nb.GetSelection()
	plot = self.nb.GetCurrentPage()
	tmp_gas = pages[page_num]
	(inst, gas) = tmp_gas.split()

        plottype = self.rb.GetStringSelection()
	self.doNLPlot(gas,inst, plot, plottype)


    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def poly(self, x, np, params):
        """ Calculate a value from polynomial coefficients """

        sum = params[np-1]
        for j in range(np-2, -1, -1):
                sum = sum*x + params[j]

        return sum


    #----------------------------------------------
    def doNLPlot(self, gas, current_inst, graph, plottype):
	""" Plot the non-linearity response curves """


	#respfile = "/projects/%s/inst_resp.%s" % (gas.lower(), gas.lower())
	respfile = "/ccg/%s/ResponseCurves.%s" % (gas.lower(), gas.lower())
	resp = []
	f = open(respfile)
	for line in f:
		line = line.lstrip()
		(inst_id, the_rest) = line.split(' ',1)
		if inst_id.upper() == current_inst.upper():
			#print >> sys.stderr, line
			resp.append(line.strip("\n"))
	f.close()
	resp.sort()
	resp = resp[-5:]


	if current_inst.lower() == "pc1":
		if gas == "CO2":
			xmin = 0
			xmax = 2.0
		else:
			xmin = 0
			xmax = 5.0

	elif current_inst.lower() == "ar1":
		if gas == "CO2":
			xmin = -200
			xmax = 200
		elif gas == "CO2C13":
			xmin = -2
			xmax = 2
		elif gas == "CO2O18":
			xmin = -1
			xmax = 1
		else:
			xmin = -200
			xmax = 200

	elif current_inst.lower() == "lgr6":
			xmin = 0
			xmax = 5

	else:
			xmin = 0
			xmax = 5
	
	xstep = 0.01
        colors = [ (255,0,0), (0,0,255), (46,189,87), (255,0,255), (0,225,225), (238,238,0), (0,0,128), (205,92,92), (95,158,160), (107,142,35), (255,140,0) ]

	#  H5 2013 07 17 09 07     3.682  1845.848     3.766   3.083    22 poly  2013-07-17.PRIM.ch4
	j = 0
	nc = len(colors)
        graph.clear()

	for line in resp:
		tmp=[]
		tmp = line.split()
		#print >> sys.stderr, "line: %s" % line
		#print >> sys.stderr, "len(tmp) = %s" % len(tmp)

		if len(tmp) == 13:	
			(inst, yr, mo, dy, hr, mn, c0, c1, c2, rsd, n, ftyp, file) = line.split()
		elif len(tmp) == 14:
			(inst, yr, mo, dy, hr, mn, c0, c1, c2, rsd, n, ftyp, ref_op, file) = line.split()

		coeffs = [float(c0), float(c1), float(c2)]
		xp = xmin
		x = []
		y = []
		while xp <= xmax:
			yp = self.poly(xp, 3, coeffs)
			x.append(xp)
			y.append(yp)
			xp += xstep

                if plottype == "Response Curve":
			dataset = Dataset(x,y, name=file)
			color = colors[j%nc]
			dataset.style.setLineColor(color)
			dataset.style.setLineWidth(3)
			graph.addDataset(dataset)

			#rawfile = "/projects/%s/nl/%s/raw/%s/%s" % (gas.lower(), inst, yr, file)
			rawfile = "/ccg/%s/nl/%s/raw/%s/%s" % (gas.lower(), inst, yr, file)
			######################
			com = "/ccg/bin/nlpro.py -i  %s" % (rawfile)
			p = subprocess.Popen(com, stdout=subprocess.PIPE, shell=True)
			resp = p.communicate()[0]
			resp = resp.strip("\n")
			if resp:
				x = []
				y = []
				for line in resp.split("\n"):
					#1.044827 0.000028 373.155000 0.024000
					(xp, xp_unc, yp, yp_unc) = line.split()
					x.append(float(xp))
					y.append(float(yp))

				dataset = Dataset(x,y, name=file)
				dataset.style.setMarker("circle")
				dataset.style.setMarkerSize(4)
				dataset.style.setFillColor(colors[j%nc])
				dataset.style.setConnectorType("None")
				graph.addDataset(dataset)

		else:
			#rawfile = "/projects/%s/nl/%s/raw/%s/%s" % (gas.lower(), inst, yr, file)
			rawfile = "/ccg/%s/nl/%s/raw/%s/%s" % (gas.lower(), inst, yr, file)

			com = "/ccg/bin/nlpro.py --resid -v %s" % (rawfile)
			p = subprocess.Popen(com, stdout=subprocess.PIPE, shell=True)
			resp = p.communicate()[0]
			resp = resp.strip("\n")
			if resp:
				x = []
				y = []
				for line in resp.split("\n"):
					#(xp, resid) = line.split()
					(rr, resid, std, std_sn, assigned_val) = line.split()
					#x.append(float(xp))
					x.append(float(assigned_val))
					y.append(float(resid))

				dataset = Dataset(x,y, name=file)
				dataset.style.setMarker("circle")
				dataset.style.setMarkerSize(4)
				dataset.style.setFillColor(colors[j%nc])
				dataset.style.setConnectorType("None")
				graph.addDataset(dataset)


		j += 1


        graph.update()
