

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
#pages = { 0: 'Picarro', 1: 'LGR', 2: 'Aerodyne'} 
pages = { 0: 'Aerodyne', 1: 'Aerolaser', 2: 'Aeris', 3: 'H2'}

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



            # Aerodyne
            if pagenum == 0:
                choices = ["N2O", "N2O_sd", "CO", "CO_sd", "Cell_Press", "Cell_Press_sd", "Cell_Temp","Flow"]
                self.rb[pagenum] = wx.Choice(panel, -1, choices=choices)

            # Aerolaser
            elif pagenum == 1:
                choices = ["CO", "CO_sd", "Cell_Press", "Cell_Press_SD", "Cell_Temp", "Flow"]
                self.rb[pagenum] = wx.Choice(panel, -1, choices=choices)

            # Aeris
            elif pagenum == 2:
                choices = ["N2O", "N2O_sd", "CO", "CO_sd", "Cell_Press", "Cell_Press_SD", "Cell_Temp","Flow"]
                self.rb[pagenum] = wx.Choice(panel, -1, choices=choices)

            # H2 
            elif pagenum == 3:
                choices = ["Peak Height", "Peak Area", "Retention time"]
                self.rb[pagenum] = wx.Choice(panel, -1, choices=choices)

            else:
                self.rb[pagenum] = wxChoice(panel, -1, choices=["Analyzer Voltages"])

            self.rb[pagenum].SetSelection(0)
            sz.Add(self.rb[pagenum])
            self.rb[pagenum].Bind(wx.EVT_CHOICE, self.refreshPage)

            plot = Graph(panel, -1)
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
        x4 = []
        y4 = []
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

            ######################################################



            ######################################################
            if gas.lower() == "picarro":
                if   type == "CO2":        v = float(list[8])
                elif type == "CH4":        v = float(list[11])
                elif type == "H2O":        v = float(list[14])
                elif type == "Cell_Press": v = float(list[17])
                elif type == "Cell_Press_SD": v = float(list[18])
                elif type == "Cell_Temp":  v = float(list[20])
                elif type == "Smpl_Press": v = float(list[32])
                elif type == "Flow":       v = float(list[33])
                elif type == "Analysis_time_delta": v = int(list[35])
                elif type == "CO2_ratio": 
                    if gas_type != "REF":
                        val_col = 8
                        signal = float(list[val_col])
                        #prev_ref = self._find_prev_ref(raw, linenum,8)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
                        if next_ref == "":
                            prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        else:
                            pref_ref = ""  # use to test only using next ref

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
                elif type == "CH4_ratio": 
                    if gas_type != "REF":
                        val_col =11 
                        signal = float(list[val_col])
                        #print >> sys.stderr, "sig = %f" % signal
                        #prev_ref = self._find_prev_ref(raw, linenum,8)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
                        if next_ref == "":
                            prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        else:
                            pref_ref = ""  # use to test only using next ref

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
                else:
                    pass

            ######################################################
            if gas.lower() == "aerodyne":
                if   type == "N2O":        v = float(list[8])
                elif type == "N2O_sd":       v = float(list[9])
                elif type == "CO":       v = float(list[11])
                elif type == "CO_sd":       v = float(list[12])
                elif type == "Cell_Press": v = float(list[17])
                elif type == "Cell_Press_sd": v = float(list[18])
                elif type == "Cell_Temp":  v = float(list[14])
                elif type == "Flow":       v = float(list[20])
                elif type == "N2O_ratio": 
                    if gas_type.upper() != "REF":
                        val_col = 8
                        signal = float(list[val_col])
                        #print >> sys.stderr, "val_col: %s    signal: %s" % (val_col, signal)
                        prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
                        if prev_ref != "" and next_ref != "":
                            ref = ((prev_ref + next_ref)/2.0)
                        elif prev_ref != "" and next_ref == "":
                            ref = prev_ref
                        elif prev_ref == "" and next_ref != "":
                            ref = next_ref
                        else:
                            ref = 1.0
                        
                        v = signal / ref
                        #v = signal - ref
                        #print >> sys.stderr, "v = %f" % v
                    else:
                        pass
                        #print >> sys.stderr, "gas_type %s equals REF" % gas_type
                elif type == "CO_ratio": 
                    if gas_type.upper() != "REF":
                        val_col = 11
                        signal = float(list[val_col])
                        #print >> sys.stderr, "val_col: %s    signal: %s" % (val_col, signal)
                        prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
                        if prev_ref != "" and next_ref != "":
                            ref = ((prev_ref + next_ref)/2.0)
                        elif prev_ref != "" and next_ref == "":
                            ref = prev_ref
                        elif prev_ref == "" and next_ref != "":
                            ref = next_ref
                        else:
                            ref = 1.0
                        
                        v = signal / ref
                        #v = signal - ref
                        #print >> sys.stderr, "v = %f" % v
                    else:
                        pass
                        #print >> sys.stderr, "gas_type %s equals REF" % gas_type
                elif type == "N2O_diff": 
                    if gas_type.upper() != "REF":
                        val_col = 8
                        signal = float(list[val_col])
                        #print >> sys.stderr, "val_col: %s    signal: %s" % (val_col, signal)
                        prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
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
                elif type == "CO_diff": 
                    if gas_type.upper() != "REF":
                        val_col = 11
                        signal = float(list[val_col])
                        #print >> sys.stderr, "val_col: %s    signal: %s" % (val_col, signal)
                        prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
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

            ######################################################
            if gas.lower() == "aerolaser":
                #choices = ["CO", "CO_sd", "Cell_Press", "Cell_Press_SD", "Cell_Temp", "Flow"]
                if type == "CO":       v = float(list[8])
                elif type == "CO_sd":       v = float(list[9])
                elif type == "Cell_Press": v = float(list[13])
                elif type == "Cell_Press_SD": v = float(list[14])
                elif type == "Cell_Temp":  v = float(list[12])
                elif type == "Flow":       v = float(list[11])

            ######################################################
            if gas.lower() == "aeris":
                if   type == "N2O":        v = float(list[8])
                elif type == "N2O_sd":       v = float(list[9])
                elif type == "CO":       v = float(list[11])
                elif type == "CO_sd":       v = float(list[12])
                elif type == "Cell_Press": v = float(list[20])
                elif type == "Cell_Press_SD": v = float(list[21])
                elif type == "Cell_Temp":  v = float(list[17])
                elif type == "Flow":       v = float(list[23])


            ######################################################
            if gas.lower() == "sf6":
                if   type == "Peak Height":     v = float(list[8])
                elif type == "Peak Area":       v = float(list[9])
                elif type == "Retention time":  v = float(list[10])
                elif type == "Sample Loop Pressure":  v = float(list[14]) 
                elif type == "Sample_loop_relax": v = float(list[15])
                elif type == "Analysis_time_delta": v = int(list[16])
                elif type == "press_correct_area":
                    sig = float(list[9])
                    p = float(list[14])
                    v = sig / (p / 624.0)  # peak area corrected to pressure = 624 Torr

            ######################################################
            if gas.lower() == "h2":
                if   type == "Peak Height":     v = float(list[8])
                elif type == "Peak Area":       v = float(list[9])
                elif type == "Retention time":  v = float(list[10])
                elif type == "Sample Loop Pressure":  v = float(list[14]) 
                elif type == "Sample_loop_relax": v = float(list[15])
                elif type == "Analysis_time_delta": v = int(list[16])
                elif type == "press_correct_area":
                    sig = float(list[9])
                    p = float(list[14])
                    v = sig / (p / 624.0)  # peak area corrected to pressure = 624 Torr
                elif type == "press_correction":
                    sig = float(list[9])
                    p = float(list[14])
                    v = (sig / (p / 624.0)) - sig  # Correction applied
                elif type == "press_correction_percent":
                    sig = float(list[9])
                    p = float(list[14])
                    v = (sig - (sig / (p / 624.0))) / sig * 100.0  # Correction applied as a percent of signal
                    #v = p / 624.0
                elif type == "area_ratio":
                    if gas_type.upper() != "REF":
                        val_col = 9
                        signal = float(list[val_col])
                        #print >> sys.stderr, "val_col: %s    signal: %s" % (val_col, signal)
                        prev_ref = self._find_prev_ref(raw, linenum, val_col)
                        next_ref = self._find_next_ref(raw, linenum, val_col)
                        if prev_ref != "" and next_ref != "":
                            ref = ((prev_ref + next_ref)/2.0)
                        elif prev_ref != "" and next_ref == "":
                            ref = prev_ref
                        elif prev_ref == "" and next_ref != "":
                            ref = next_ref
                        else:
                            ref = 1.0
                        
                        v = signal / ref
                elif type == "corr_area_ratio":
                    press_corr = 14   # to press corr signal, pass in press column 
                    if gas_type.upper() != "REF":
                        val_col = 9
                        signal = float(list[val_col]) / (float(list[press_corr]) / 624.0)
                        #print >> sys.stderr, "val_col: %s    signal: %s" % (val_col, signal)
                        prev_ref = self._find_prev_ref(raw, linenum, val_col, press_corr)
                        next_ref = self._find_next_ref(raw, linenum, val_col, press_corr)
                        if prev_ref != "" and next_ref != "":
                            ref = ((prev_ref + next_ref)/2.0)
                        elif prev_ref != "" and next_ref == "":
                            ref = prev_ref
                        elif prev_ref == "" and next_ref != "":
                            ref = next_ref
                        else:
                            ref = 1.0
                        
                        v = signal / ref
                    
            ######################################################
            if gas.lower() == "qc":  
                if   type == "cycle_time":      v = float(list[10])
                elif type == "init_press":      v = float(list[11])
                elif type == "final_press":     v = float(list[12])
                elif type == "init_evac_time":  v = float(list[13])
                elif type == "init_evac_P":     v = float(list[14])
                elif type == "evac_time":       v = float(list[15])
                elif type == "evac_P":          v = float(list[16])
                elif type == "room_T":          v = float(list[17])
                elif type == "room_P":          v = float(list[18])
                elif type == "idle_P":          v = float(list[19])
                elif type == "chiller_T":       v = float(list[20])
                elif type == "scroll_pump_P":       v = float(list[21])
                #elif type == "smpl_loop_P":     v = float(list[21])
                elif type == "gas_usage":
                    if gas_type.upper() == "SMP":
                        # get sample type from sys.current_sample file
                        try:
                               f = open("sys.internal_mode", "r")
                               sample_type = f.readline()
                               sample_type = sample_type.rstrip()
                               f.close()
                        except:
                            ShowStatus("Could not open file %s for reading, continue ..."  % "sys.current_sample")
                            sample_type = "none"


                        if sample_type.lower() == "flask":
                            volume = 2100.0
                            v = ((float(list[11]) * volume) / 14.7) - ((float(list[12]) * volume) / 14.7)
                            #print >> sys.stderr, "v = %s" % v
                        elif sample_type.lower() == "pfp":
                            volume = 750.0
                            v = ((float(list[11]) * volume) / 14.7) - ((float(list[12]) * volume) / 14.7)
                        else:
                            v = 0
                    else:
                        v = 0   
                elif type == "port_evac_1Torr":     v = int(list[22])
                elif type == "port_evac_100mTorr":  v = int(list[23])
                elif type == "port_evac_P":     v = float(list[24])
                elif type == "port_evac_time":      v = float(list[25])
            
            ######################################################
            if gas.lower() == "trap_dry_qc":
                if   type == "flow":        v = float(list[8])
                elif type == "room_T":          v = float(list[9])
                elif type == "chiller_T":       v = float(list[10])
                #elif type == "humidity":     v = ((float(list[11]) - 0.826) / 0.0315)
                elif type == "humidity":     v = float(list[11]) 









            ######################################################


            t = datetime.datetime(yr, mn, dy, hr, mi, sc)
#            xp = decimalDate(yr, mn, dy, hr, mi)
            if gas_type == "REF":
                if gas_name == "Z":
                    x3.append(t)
                    y3.append(v)
                elif gas_name == "J0":
                    x4.append(t)
                    y4.append(v)
                else:
                    x2.append(t)
                    y2.append(v)

            elif gas_type == "SMP":
                x.append(t)
                y.append(v)
            elif gas_type == "STD":
                x1.append(t)
                y1.append(v)


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
            dataset = Dataset(x3,y3, "Zero")
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


