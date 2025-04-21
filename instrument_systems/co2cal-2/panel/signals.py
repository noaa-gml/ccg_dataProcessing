

import sys
import os
import wx
import glob
import datetime

import panel_config as config

from graph5.graph import Graph
from graph5.dataset import Dataset
from panel_utils import *

#pages = { 0: 'N2O', 1: 'SF6', 2: 'CO', 3: 'H2', 4: 'CH4', 5: 'CO2' }
#pages = { 0: 'CH4' }
pages = { 0: 'Picarro', 1: 'LGR', 2: 'Aerodyne'} 

PEAK_HEIGHT = 1
PEAK_AREA = 2
RET_TIME = 3

#--------------------------------------------------------------
class mkSignalPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.gas = gas
        self.t2 = wx.Timer(self)

        box = wx.StaticBox(self, -1, "Signals", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        self.rb = {}
        self.plot = {}
        for pagenum, pagelabel in pages.items():
            panel = wx.Panel(self.nb, -1)
            sz = wx.BoxSizer(wx.VERTICAL)

            #Picarro
            if pagenum == 0:
                self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["CO2","CH4","H2O","Cell_Press",
                                       "Cell_Temp","Flow",
                                       "Smpl_Press","Room_temp","CO2_ratio",
                                       "ChillerT"])
            #LGR
            elif pagenum == 1:
                self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["626_ppm", "636_ppm", "628_ppm", 
                                       "Cell_Press",
                                       "Cell_Temp","Flow",
                                       "Smpl_Press","Room_temp"])
            #Aerodyne
            elif pagenum == 2:
                self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["626_ppm", "636_ppm", "628_ppm", 
                                       "627_ppm", "Cell_Press",
                                       "Cell_Temp","Flow",
                                       "Smpl_Press","Room_temp","CO2_ratio"])
            else:
                self.rb[pagenem] = wxRadioBox(panel, -1, choices=["Analyzer Voltages"])
            
            sz.Add(self.rb[pagenum])
            self.rb[pagenum].Bind(wx.EVT_RADIOBOX, self.refreshPage)

            plot = Graph(panel, -1)
    #        xaxis = plot.getXAxis(0)
    #        xaxis.scale_type = "time"
            plot.showGrid = 1
            plot.showSubgrid = 1
            plot.margin = 25
            sz.Add(plot, 1, wx.EXPAND|wx.ALL, 5)
            self.plot[pagenum] = plot

            panel.SetSizer(sz)

            self.nb.AddPage(panel, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)
        self.Bind(wx.EVT_TIMER, self.refreshPage)

        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):
        if self.nb.IsShownOnScreen():
            page_num = self.nb.GetSelection()
            gas = pages[page_num]
            plot = self.plot[page_num]
            rb = self.rb[page_num]
            type = rb.GetStringSelection()

            self.doPlotSignal(gas, plot, type)
            self.t2.Start(config.page_refresh)

        else:
            self.t2.Stop()

    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def doPlotSignal(self, gas, graph, type):

        file = "%s/data.%s" % (config.sysdir, gas.lower())

        x = []
        y = []
        x1 = []
        y1 = []
        x2 = []
        y2 = []
        x3 = []
        y3 = []
        prev_ref = "" 
        next_ref = ""
    

        if os.path.exists(file):
            f = open(file, "r")
            raw = f.readlines()
            f.close()

        for linenum, line in enumerate(raw):
            list = line.split()
            gas_type = list[0]
            #print(line, file=sys.stderr)
            gas_name = list[1]
            yr = int(list[2])
            mn = int(list[3])
            dy = int(list[4])
            hr = int(list[5])
            mi = int(list[6])
            sc = int(list[7])

            if gas.lower() == "picarro":
                if   type == "CO2":        v = float(list[8])
                elif type == "CH4":        v = float(list[11])
                elif type == "H2O":        v = float(list[14])
                elif type == "Cell_Press": v = float(list[17])
                elif type == "Cell_Temp":  v = float(list[20])
                elif type == "Flow":       v = float(list[32])
                elif type == "Smpl_Press": v = float(list[33])
                elif type == "Room_temp":  v = float(list[34])
                elif type == "CO2_ratio": 
                    if gas_type != "REF":
                        signal = float(list[8])
                        #signal = float(list[11])
                        #print >> sys.stderr, "sig = %f" % signal
                        prev_ref = self._find_prev_ref(raw, linenum)
                        next_ref = self._find_next_ref(raw, linenum)
                        if prev_ref != "" and next_ref != "":
                            #print >> sys.stderr, "case 1"
                            ref = ((prev_ref + next_ref)/2.0)
                        elif prev_ref != "" and next_ref == "":
                            #print >> sys.stderr, "case 2"
                            ref = prev_ref
                        elif prev_ref == "" and next_ref != "":
                            #print >> sys.stderr, "case 3"
                            ref = next_ref
                        else:
                            ref = 1.0
                        #print >> sys.stderr, ref
                        v = signal / ref
                        #print >> sys.stderr, "v = %f" % v
                    else:
                        pass
                        #print >> sys.stderr, "gas_type %s equals REF" % gas_type
                elif type == "ChillerT":  v = float(list[35])
                else:
                    pass

            #self.rb[pagenum] = wx.RadioBox(panel, -1, choices=["626_ppm", "636_ppm", "628_ppm", 
            #                           "Cell_Press",
            #                           "Cell_Temp","Flow",
            #                           "Smpl_Press","Room_temp"])
            if gas.lower() == "lgr":
                if   type == "626_ppm":    v = float(list[33])
                elif type == "636_ppm":    v = float(list[36])
                elif type == "628_ppm":    v = float(list[39])
                elif type == "Cell_Press": v = float(list[20])
                elif type == "Cell_Temp":   v = float(list[23])
                elif type == "Flow":       v = float(list[29])
                elif type == "Smpl_Press": v = float(list[30])
                elif type == "Room_temp":  v = float(list[31])
                else:
                    pass

            if gas.lower() == "aerodyne":
                if   type == "626_ppm":        v = float(list[8])
                elif type == "636_ppm":       v = float(list[11])
                elif type == "628_ppm":       v = float(list[14])
                elif type == "627_ppm":       v = float(list[17])
                elif type == "Cell_Press": v = float(list[23])
                elif type == "Cell_Temp":  v = float(list[20])
                elif type == "Flow":       v = float(list[26])
                elif type == "Smpl_Press": v = float(list[27])
                elif type == "Room_temp":  v = float(list[28])
                elif type == "CO2_ratio": 
                    if gas_type != "REF":
                        signal = float(list[8])
                        prev_ref = self._find_prev_ref(raw, linenum)
                        next_ref = self._find_next_ref(raw, linenum)
                        if prev_ref != "" and next_ref != "":
                            ref = ((prev_ref + next_ref)/2.0)
                        elif prev_ref != "" and next_ref == "":
                            ref = prev_ref
                        elif prev_ref == "" and next_ref != "":
                            ref = next_ref
                        else:
                            ref = 1.0
                        
                        #v = signal / ref
                        v = signal - ref
                        #print >> sys.stderr, "v = %f" % v
                    else:
                        pass
                        #print >> sys.stderr, "gas_type %s equals REF" % gas_type

                else:
                    pass

            t = datetime.datetime(yr, mn, dy, hr, mi, sc)
#            xp = decimalDate(yr, mn, dy, hr, mi)
            if gas_type == "SMP":
                x.append(t)
                y.append(v)
            elif gas_type == "STD":
                x1.append(t)
                y1.append(v)
            else:
                #print("gas_type: %s   gas_name: %s " % (gas_type, gas_name), file=sys.stderr)
                if type != "CO2_ratio":
                    if gas_name.lower() == "r0":
                        x2.append(t)
                        y2.append(v)
                    else:
                        x3.append(t)
                        y3.append(v)


        graph.clear()
        if len(x):
            dataset = Dataset(x,y, "Sample")
            dataset.style.setLineColor("black")
            dataset.style.setMarker("circle")
            dataset.style.setFillColor("blue")
            graph.addDataset(dataset)

        if len(x1):
            dataset = Dataset(x1,y1, "Standard")
            dataset.style.setLineColor("black")
            dataset.style.setMarker("circle")
            dataset.style.setFillColor("orange")
            graph.addDataset(dataset)

        if len(x2):
            dataset = Dataset(x2,y2, "Reference")
            dataset.style.setLineColor("black")
            dataset.style.setMarker("circle")
            dataset.style.setFillColor("red")
            graph.addDataset(dataset)

        if len(x3):
            dataset = Dataset(x3,y3, "Junk air")
            dataset.style.setLineColor("black")
            dataset.style.setMarker("circle")
            dataset.style.setFillColor("green")
            graph.addDataset(dataset)

        graph.update()


    #--------------------------------------------------------------------------
    def _find_prev_ref(self, raw, linenum):
#REF R0 2015 02 09 15 17 42  392.6617       0.0118 10    1844.1720       0.1800 10       0.0016       0.0006 10  139.9987   0.0136 30  45.0000   0.00
#00 30  42.8125   0.0000 30  45.0094   0.0001 30  45.0001   0.0001 30      0.03    731.37     25.26
    #therest=[]
        for line in raw[linenum::-1]:
                (type, tnk, j,j,j,j,j,j,co2,j,j,ch4,therest) = line.split(None,12)
                if type == "REF":
                        return float(co2)
                        #return float(ch4)

        return ""

    #--------------------------------------------------------------------------
    def _find_next_ref(self, raw, linenum):

        for line in raw[linenum:]:
                (type, tnk, j,j,j,j,j,j,co2,j,j,ch4,therest) = line.split(None,12)
                if type == "REF":
                        return float(co2) 
                        #return float(ch4) 

        return ""


