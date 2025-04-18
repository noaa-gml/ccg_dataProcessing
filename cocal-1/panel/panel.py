#!/usr/bin/env python

import os
import sys
import wx

from setup import *
from analyzer import *
from refgas import *
from log import *
from syslog import *
from status import *
#from volt import *
#from mr import *
#from target import *
from gcx import *
from nl import *
from signals import *
from start import *
from stop import *
from worksheet import *
#from qc import *
#from ch4_control import *
#from co2cal_control import *
#from flask import *
#from tank import *
from sysinfo import *
#from pfp import *

from panel_utils import *
import panel_config as config

sys.path.append("/ccg/python/ccglib/")

# Define the tree label and the function to create the corresponding page
SETUP =     { 'label': 'Setup',              'callback': mkSetupPage}
ANALYZER =  { 'label': 'Analyzers',          'callback': mkAnalyzerPage}
REFGASES =  { 'label': 'Reference Gases',    'callback': mkRefgasPage}
WORKSHEET = { 'label': 'Daily Worksheet',    'callback': mkWorksheetPage}
LOG =       { 'label': 'Operator Log',       'callback': mkLogPage}
SYSTEMLOG = { 'label': 'System Logs',        'callback': mkSysLogPage}
STATUS =    { 'label': 'Status and Results', 'callback': mkStatusPage}
#FLASK =     { 'label': 'Flask Information',  'callback': mkFlaskInfo}
#TANK =      { 'label': 'Tank Information',   'callback': mkTankInfo}
#PFP =       { 'label': 'PFP Information',    'callback': mkPFPInfo}
SYSINFO = {'label': 'Sample Analysis Information', 'callback': mkSysInfo}
#VOLT =      { 'label': 'Voltage Plots',      'callback': mkVoltPage}
#MR =        { 'label': 'Mixing Ratio Plot',  'callback': mkMixingRatioPage}
GC =        { 'label': 'View Chromatograms', 'callback': mkGCPage}
NL =        { 'label': 'View Response Curves', 'callback': mkNLPage}
SIGNALS =   { 'label': 'View Signals',       'callback': mkSignalPage}
#TARGET =    { 'label': 'Target Cal Results', 'callback': mkTargetPage}
START =     { 'label': 'Start System',       'callback': mkStartPage}
STOP =      { 'label': 'Stop System',        'callback': mkStopPage}
#CO2_CNTRL = { 'label': 'Manual Control',     'callback': mkCO2ControlPage}
#MAN_CNTRL = { 'label': 'Manual Control',     'callback': mkControlPage}
#QC_PLOTS  = { 'label': 'QC Plots',           'callback': mkQCPlotPage}

# need one for each entry in config.systems
#treeList = [
#    ('Setup',                [SETUP, ANALYZER, REFGASES, WORKSHEET, LOG, SYSTEMLOG]),
#    ('Analysis Information', [FLASK, TANK, PFP]),
#    ('Status/Results',       [STATUS, SIGNALS, GC, NL, TARGET]),
#    ('System Control',       [START, STOP, MAN_CNTRL]),
#]

treeList = [
    ('Setup',                [SETUP, ANALYZER, REFGASES, LOG]),
    ('Analysis Information', [SYSINFO]),
    ('Status/Results',       [STATUS, SIGNALS, NL, GC, SYSTEMLOG]),
    ('System Control',       [START, STOP]),
]


##################################################################################
class MainFrame(wx.Frame):
    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(1250, 850))
        #wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(1050, 750))

        self.timer = wx.Timer(self)
        config.main_frame = self
#    self.currentsys = config.systems[0]

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Main menu bar
        menuBar = wx.MenuBar()
        menu = wx.Menu()
        menu.Append(101, "E&xit", "Terminate the program")
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        menuBar.Append(menu, "&File")
        self.SetMenuBar(menuBar)

        # status bar, holding text and color indicator
        self.sb = self.CreateStatusBar()
        self.sb.SetFieldsCount(2)
        self.sb.SetStatusWidths([-1, 50])
        self.SetStatusText("")
        self.sb.Bind(wx.EVT_SIZE, self.Reposition)


        # A small color indicator showing if system is 
        # running (green), scheduled to run (yellow) or
        # stopped (red)
        self.win = wx.Panel(self.sb, -1)
        self.win.SetBackgroundColour(wx.RED)
        self.Reposition()


        # Notebook for holding pages for the different systems
    #    self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        # Add a notebook page for each system specified in config file.
        page = self.MkPage(self, treeList)
    #    self.nb.AddPage(page, sys.upper())

        # handle page changes
    #    self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.showStatus)

        self.sizer.Add(page, 1, wx.EXPAND|wx.ALL, 5)
        self.SetSizer(self.sizer)

        self.showStatus()

        # show status on timer event
        self.Bind(wx.EVT_TIMER, self.showStatus)

    #--------------------------------------------------------------
    def MkPage(self, parent, treeList):

        p1 = wx.Panel(parent)

        box = wx.BoxSizer(wx.VERTICAL)
        self.book = wx.Treebook (p1, -1, style=wx.BK_DEFAULT)

        for category, items in treeList:
            tx = wx.StaticText(self.book, -1, category)
            self.book.AddPage(tx, category, False)
            for item in items:
                if item['callback'] != None:
                    page = item['callback'](self.book, config.system_name)
                    self.book.AddSubPage(page, item['label'], True)

        box.Add(self.book, 1, wx.EXPAND, 0)
        p1.SetSizer(box)
        self.book.Bind(wx.EVT_TREEBOOK_PAGE_CHANGED, self.OnPageChanged)
        self.book.SetSelection(1)

        return p1


    #--------------------------------------------------------------
    def OnPageChanged(self, e):
        """ This routine is to update those pages when they become
            visible, rather than at startup time.
        """

        window = e.GetEventObject()
        page_num = window.GetSelection()
        #print page_num
        label = window.GetPageText(page_num)
        #print label

        # if page has an updatePage routine, call it,
        # otherwise do nothing.
        try:
            page = window.GetPage(page_num)
            page.updatePage()
        except:
            pass


    #--------------------------------------------------------------
    def showStatus(self, evt=""):
        """ Show system status text in the bottom statusbar,
            and update color indicator 
        """

        # status text
        #page_num = self.nb.GetSelection()
        #self.currentsys = self.nb.GetPageText(page_num)
        #if page_num:
        #file = config.sysdir + "/" + self.currentsys.lower() + "/sys.status"
        #else:
        file = config.sysdir + "/" + "/sys.status"
        if os.path.exists(file):
            f = open(file, "r")
            line = f.readline()
            f.close()
            line = line.strip("\n")
        else:
            line = "No status file"
        config.main_frame.SetStatusText (line)

        # color indicator
        #test = getSysRunning()
        #print("test getSysRunning = %s" % test)
        if getSysRunning():
            self.win.SetBackgroundColour(wx.GREEN)
        else:
            if getSysScheduled():
                self.win.SetBackgroundColour("#ffff00")
            else:
                self.win.SetBackgroundColour(wx.RED)
        
        # this timer will send the timer signal to the program 
        self.timer.Start(config.status_refresh)

    #--------------------------------------------------------------
    # show custom text in the status bar 
    def updateStatus(self, txt):
    
        self.timer.Stop()
        self.SetStatusText (txt)
        t2 = wx.CallLater(5000, self.showStatus)


    #--------------------------------------------------------------
    # reposition the color indicator if main window is resized
    def Reposition(self, evt=""):
        rect = self.sb.GetFieldRect(1)
        self.win.SetPosition((rect.x+1, rect.y+1))
        self.win.SetSize((rect.width-1, rect.height-1))


    #--------------------------------------------------------------
    def OnExit(self, e):
    #    self.Close(True)  # Close the frame.
        sys.exit()


##################################################################################
class MyApp(wx.App):
    def OnInit(self):
        frame = MainFrame(None, -1, "%s  " % config.system_name.upper())
        frame.CenterOnScreen()
        frame.Show(True)
        self.SetTopWindow(frame)
        return True

##################################################################################
if __name__ == '__main__':

    app = MyApp(0)
    app.MainLoop()
