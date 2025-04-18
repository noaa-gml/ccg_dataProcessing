
import os

import wx

import panel_config as config
from panel_utils import *

pages = { 0: 'Magicc Log', 1: 'Hardware Log', 2: 'PFP Log' }

#--------------------------------------------------------------
class mkSysLogPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.setpages = { 0: 1, 1: 1}
        self.gas = gas
        self.files = { 
            0: config.sysdir + "/"  + config.logfile,
            1: config.sysdir + "/sys.log",
            2: config.sysdir + "/pfp_error.log"
            }
        self.t2 = wx.Timer(self)

        box = wx.StaticBox(self, -1, "System Logs", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        title = wx.StaticText(self, -1, "Note: Only the last %d bytes are shown." % config.log_size)
        title.SetFont(wx.Font(8, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_NORMAL))
        sizer.Add(title, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        for pagenum, pagelabel in pages.items():
            page = wx.TextCtrl(self.nb, -1, "", style=wx.TE_MULTILINE|wx.TE_WORDWRAP)
            font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
            page.SetFont(font)
            self.nb.AddPage(page, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

        b1 = wx.Button(self, -1, "Refresh")
        sizer.Add(b1, 0, wx.ALL, 5)
        self.Bind(wx.EVT_BUTTON, self.refreshPage, b1)


        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)
        self.Bind(wx.EVT_TIMER, self.refreshPage)

        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):

        if self.nb.IsShownOnScreen():
            #if getSysRunning() or self.setpages:
            page_num = self.nb.GetSelection()
            page = self.nb.GetCurrentPage()
            txt = self.getText(self.files[page_num])
            page.ChangeValue(txt)
            #self.setpages[page_num] = 0
            #self.t2.Start(config.log_refresh)
            
            # make last line visible
            nl = len(txt)
            page.ShowPosition(nl)
        #else:
        #    self.t2.Stop()


    #----------------------------------------------
    def refreshPage(self, evt):

        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def getText(self, file):

        if os.path.exists(file):
            f = open(file)
            txt = f.read()
            f.close()
        
            return txt[-config.log_size:]
        else:
            return ""

