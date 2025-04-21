
import os
import wx
import glob
from datetime import datetime

import panel_config as config
from panel_utils import *


#--------------------------------------------------------------
class mkWorksheetPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.gas = gas


        self.num_prev_entries = 3

        box = wx.StaticBox(self, -1, "Daily Worksheet", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)
        self.SetSizer(sizer)

        self.grid = wx.FlexGridSizer(0, 5, 0, 0)
        sizer.Add(self.grid, 0, wx.ALL, 5)
    
        self.makeGUI()


        SetSaveButton(self, sizer, self.ok)

    #--------------------------------------------------------------
    def makeGUI(self):

        self.getPrevFiles()

        self.grid.Clear(True)

        left_spacing = 20

        # Add a Date: row, but this won't be saved
        label = "Date: "
        tx = wx.StaticText(self, -1, label)
        #self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 0)
        self.grid.Add(tx, 0, wx.ALL, 0)
        tx = wx.StaticText(self, -1,'')
        self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
        for i in range(0,self.num_prev_entries):
            txt = self.getPrevEntry(i, label)
            tx = wx.StaticText(self, -1, txt)
            #self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT, left_spacing)
            self.grid.Add(tx, 0, wx.LEFT, left_spacing)

        self.tc = []
        list = config.worksheet_labels[self.gas.upper()]
        for label in list:
            tx = wx.StaticText(self, -1, label)
            #self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 0)
            self.grid.Add(tx, 0, wx.ALL, 0)

            if label != " ":
                tc = wx.TextCtrl(self, -1, "")
                self.grid.Add(tc, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
                self.tc.append(tc)

                for i in range(0,self.num_prev_entries):
                    txt = self.getPrevEntry(i, label)
                    tx = wx.StaticText(self, -1, txt)
                    #self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT, left_spacing)
                    self.grid.Add(tx, 0, wx.LEFT, left_spacing)

            else:
                tx = wx.StaticText(self, -1, label)
                #self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 0)
                self.grid.Add(tx, 0, wx.ALL, 0)

                for i in range(0,self.num_prev_entries):
                    tx = wx.StaticText(self, -1, '')
                    #self.grid.Add(tx, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT, left_spacing)
                    self.grid.Add(tx, 0, wx.LEFT, left_spacing)

            self.grid.Layout()

    #--------------------------------------------------------------
    def getPrevFiles(self):

        # Get a list of all available files
        s = '%s/worksheets/*' % (config.sysdir)
        list = glob.glob(s)
        list.sort(reverse=True)

        # Take just the last 2, and read in the data from those files
        filelist = list[-3:]
        self.data = []
        for file in filelist:
            a = []
            f = open(file)
            for line in f:
                a.append(line)
            f.close()

            self.data.append(a)



    #--------------------------------------------------------------
    def getPrevEntry(self, n, label):

        if n >= len(self.data):
            return ""

        a = self.data[n]
        if label == "Date: ":
            return a[0][0:15]
        else:
            for line in a:
                if label in line:
                    (lbl, txt) = line.split(":")
                    txt = txt.strip()
                    return txt.strip("\n")

        return ""

    #--------------------------------------------------------------
    def ok(self, event):

        dir = config.datadir + "/" + self.gas.lower() + "/worksheets/"
        now=datetime.today()
        s = now.strftime("%Y-%m-%d")
        file = dir + "wks." + s
        print(file)

        f = open (file, "w")
        f.write(now.strftime("%c\n"))


        # create a copy of the label list, since we will be removing the blank entries.
        # Don't want to remove them from the original list.
        list = config.worksheet_labels[self.gas.upper()][:]
        while " " in list:
            list.remove(" ")

        nrows = len(self.tc)
        for i in range(0,nrows):
            txt = self.tc[i].GetValue()
            f.write("%-40s %10s\n" % (list[i], txt))

        f.close()

        config.main_frame.SetStatusText ("Saved worksheet for %s" % self.gas)

        self.makeGUI()
