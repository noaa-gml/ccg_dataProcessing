
import os
import sys 
import wx
from datetime import datetime

import panel_config as config
from panel_utils import *

#--------------------------------------------------------------
class mkRefgasPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.gas = gas
        #self.tankfile = config.sysdir + "/sys.tanks"
        self.tankfile = config.sysdir + "/sys.ref_tanks"
        self.tank_info = {}
        #self.worktankfile = config.datadir + "/" + self.gas.lower() + "/worktanks"

        box = wx.StaticBox(self, -1, "Reference Gases", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)


        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)
        self.refgases = self.getRefgases()

        #for pagenum, pagelabel in enumerate(sorted(self.refgases.keys())):
        for pagenum, pagelabel in enumerate(reversed(sorted(self.refgases.keys()))):
            #print("key = %s" % (pagelabel), file=sys.stderr)
            page = self.mkPage(pagelabel)
            self.nb.AddPage(page, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

        self.SetSizer(sizer)


        SetSaveButton(self, sizer, self.ok)

    #--------------------------------------------------------------
    def mkPage(self, label):

        page = wx.Panel(self.nb, -1)

        #sizer = wx.FlexGridSizer(0, 7, 5, 8)
        sizer = wx.FlexGridSizer(0, 7, 5, 7)

        # first row is header labels
        #tx = wx.StaticText(page, -1, "Sp")
        #sizer.Add(tx, 0, wx.ALIGN_LEFT|wx.LEFT|wx.TOP, 5)
        tx = wx.StaticText(page, -1, "Set")
        sizer.Add(tx, 0, wx.ALIGN_LEFT|wx.LEFT|wx.TOP, 10)
        tx = wx.StaticText(page, -1, "ID")
        sizer.Add(tx, 0, wx.ALIGN_LEFT|wx.LEFT|wx.TOP, 5)
        tx = wx.StaticText(page, -1, "Serial Number")
        #sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 10)
        sizer.Add(tx, 0, wx.LEFT|wx.TOP, 10)
        tx = wx.StaticText(page, -1, "Manifold")
        #sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 5)
        sizer.Add(tx, 0, wx.LEFT|wx.TOP, 10)
        tx = wx.StaticText(page, -1, "Port")
        #sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 5)
        sizer.Add(tx, 0, wx.LEFT|wx.TOP, 5)
        tx = wx.StaticText(page, -1, "Pressure")
        #sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 10)
        sizer.Add(tx, 0, wx.LEFT|wx.TOP, 10)
        tx = wx.StaticText(page, -1, "Regulator")
        #sizer.Add(tx, 0, wx.ALIGN_CENTER|wx.LEFT|wx.TOP, 10)
        sizer.Add(tx, 0, wx.LEFT|wx.TOP, 10)

        self.tank_info[label] = []

        # remaining rows are data
        #for (sp, stdset, name, sernum, manifold, port, press, reg) in self.refgases[label]:
        for (stdset, name, sernum, manifold, port, press, reg) in self.refgases[label]:
            #tx1 = wx.StaticText(page, -1, sp, size=(50, -1))
            ##sizer.Add(tx1, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_LEFT)
            #sizer.Add(tx1, 0, wx.ALIGN_LEFT)

            tx2 = wx.StaticText(page, -1, stdset, size=(125, -1))
            #sizer.Add(tx2, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_LEFT)
            sizer.Add(tx2, 0, wx.ALIGN_LEFT)

            tx3 = wx.StaticText(page, -1, name, size=(50, -1))
            #sizer.Add(tx3, 0, wx.ALIGN_CENTER_VERTICAL|wx.ALIGN_LEFT)
            sizer.Add(tx3, 0, wx.ALIGN_LEFT)
        
            tx4 = wx.TextCtrl(page, -1, sernum, size=(150, -1))
            sizer.Add(tx4, 0, wx.ALIGN_RIGHT)
        
            tx5 = wx.TextCtrl(page, -1, manifold, size=(150, -1))
            sizer.Add(tx5, 0, wx.ALIGN_RIGHT)
        
            tx6 = wx.TextCtrl(page, -1, port, size=(150, -1))
            sizer.Add(tx6, 0, wx.ALIGN_RIGHT)
        
            tx7 = wx.TextCtrl(page, -1, press, size=(100, -1))
            sizer.Add(tx7, 0, wx.ALIGN_RIGHT)
        
            tx8 = wx.TextCtrl(page, -1, reg, size=(100, -1))
            sizer.Add(tx8, 0, wx.ALIGN_RIGHT)

            #self.tank_info[label].append( (tx1, tx2, tx3, tx4, tx5, tx6, tx7, tx8) )
            self.tank_info[label].append( (tx2, tx3, tx4, tx5, tx6, tx7, tx8) )

        page.SetSizer(sizer)
        return page


    #--------------------------------------------------------------
    def getRefgases(self):

        refgases = {}

        if os.path.exists(self.tankfile):
            f = open(self.tankfile)
            for line in f:
                #(sp, stdset, stdid, sn, manifold, port, pressure, regulator) = line.split()
                (stdset, stdid, sn, manifold, port, pressure, regulator) = line.split()
                #tmpkey = "%s %s" % ( sp, stdset)
                tmpkey = "%s" % ( stdset)
                #tmpkey = "%s_%s" % (type.upper(), stdset)
                #print tmpkey
                #if type not in refgases:
                if tmpkey not in refgases:
                    #refgases[type] = []
                    refgases[tmpkey] = []

                #t = (sp, stdset, stdid, sn, manifold, port, pressure, regulator)
                t = (stdset, stdid, sn, manifold, port, pressure, regulator)
                #refgases[type].append(t)
                refgases[tmpkey].append(t)
        else:
            refgases["CH4"] = [("","R0", "", "", "", "")]

        return refgases


    #--------------------------------------------------------------
    def ok(self, event):

        tanklist = []
        for pagenum in range(self.nb.GetPageCount()):
            print("pagenum: %s" % pagenum, file=sys.stderr)
            label = self.nb.GetPageText(pagenum)
            print("label: %s" % label, file=sys.stderr)
            #tmplabel = self.nb.GetPageText(pagenum)
            #(sp, stdset) = label.split("_",1)
    
            #for (t1, t2, t3, t4, t5, t6, t7, t8) in self.tank_info[label]:
            for (t2, t3, t4, t5, t6, t7, t8) in self.tank_info[label]:
                press = ""
                reg = ""
                #sp = t1.GetLabel()
                stdset = t2.GetLabel()
                stdid = t3.GetLabel()
                sn = t4.GetValue()
                manifold = t5.GetValue()
                port = t6.GetValue()
                press = t7.GetValue()
                reg = t8.GetValue()

                if len(stdset)==0 or len(stdid)==0 or len(sn)==0:
                    msg = "Error for %s, tank %s: missing data." % (label, val1)
                    dlg = wx.MessageDialog(self, msg, 'Error', style=wx.OK | wx.ICON_ERROR)
                    dlg.ShowModal()
                    dlg.Destroy()
                    return

                #s = "%5s %12s %5s %16s %12s %5s %10s %20s" % (sp, stdset, stdid, sn, manifold, port, press, reg)
                s = "%12s %5s %16s %12s %5s %10s %20s" % (stdset, stdid, sn, manifold, port, press, reg)
                print("s:  %s" % s, file=sys.stderr)
                tanklist.append(s)
        
        os.rename(self.tankfile, self.tankfile+".bak")

        f = open(self.tankfile, "w")
        for line in tanklist:
            f.write(line + "\n")
        f.close

        config.main_frame.SetStatusText ("Updated reference tanks")

        return
