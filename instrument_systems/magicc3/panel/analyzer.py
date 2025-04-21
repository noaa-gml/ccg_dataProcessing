
import sys
import errno
import os
import wx

import panel_config
from panel_utils import *

#--------------------------------------------------------------
class mkAnalyzerPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.gas = gas
        self.analyzerfile = config.sysdir + "/sys.analyzer"

        box = wx.StaticBox(self, -1, "Analyzers", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)
        self.SetSizer(sizer)

        title = wx.StaticText(self, -1, "Enter correct analyzer serial numbers.  Press 'Save' when done.")
        title.SetFont(wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_BOLD))
        sizer.Add(title, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

        box = self.create()
        sizer.Add(box, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

        SetSaveButton(self, sizer, self.ok)

    #--------------------------------------------------------------
    def create(self):

        sizer = wx.FlexGridSizer(0, 2, 2, 2)

        label = wx.StaticText(self, -1, "Gases")
        sizer.Add(label, 0, wx.ALIGN_CENTER|wx.ALL, 0)
        label = wx.StaticText(self, -1, "Serial Number")
        sizer.Add(label, 0, wx.ALIGN_CENTER|wx.ALL, 0)

        lines = self.getAnalyzers()
        self.analyzer_id = []
        self.analyzer_sernum = []

        for line in lines:
                (name, sernum) = line

                label = wx.StaticText(self, -1, name)
                self.analyzer_id.append(label)
                sizer.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.LEFT|wx.RIGHT, 5)

                tx = wx.TextCtrl(self, -1, sernum, size=(500,-1))
                self.analyzer_sernum.append(tx)
                sizer.Add(tx, 0, wx.ALIGN_RIGHT|wx.LEFT|wx.RIGHT, 5)

        return sizer

    #--------------------------------------------------------------
    def getAnalyzers(self):

        alist = []
        if os.path.exists(self.analyzerfile):
                f = open(self.analyzerfile, "r")
                lines = f.readlines()

                for line in lines:
                    list = line.strip('\n').split(':')
                    alist.append(tuple(list))

        else:
                # if we don't have any info yet, create some lines with default values
                for name in config.analyzer_labels:
                        t = [name, ""]
                        alist.append(t)

        return alist


    #--------------------------------------------------------------
    def ok(self, event):

        analyzerlist = []
        for i in range(len(self.analyzer_id)):
                id = self.analyzer_id[i].GetLabel()
                sn = self.analyzer_sernum[i].GetValue()
                if len(sn) == 0:
                        config.main_frame.SetStatusText ("ERROR: Need serial number for %s" % id)
                        return

                s = "%s: %s\n" % (id, sn)
                analyzerlist.append(s)

        f = open(self.analyzerfile, "w")
        f.writelines(analyzerlist)
        f.close

#        config.main_frame.SetStatusText ("Updated file %s" % (self.analyzerfile))
        config.main_frame.updateStatus ("Updated file %s" % (self.analyzerfile))

        return

