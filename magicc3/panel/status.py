

import subprocess
import wx
import sys

import panel_config as config

pages = { 0: 'Status', 1: 'Results' }

#--------------------------------------------------------------
class mkStatusPage(wx.Panel):
    def __init__(self, parent, sys ):
        wx.Panel.__init__(self, parent, -1)

        self.t2 = wx.Timer(self)
        self.commands = { 
        0: config.sysdir + "/bin/status.py", 
        1: config.sysdir + "/bin/results.py", 
        #1: config.sysdir + "/bin/results", 
        }

        box = wx.StaticBox(self, -1, "Status and Results", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        for pagenum, pagelabel in pages.items():
            page = wx.TextCtrl(self.nb, -1, "", style=wx.TE_MULTILINE|wx.TE_WORDWRAP)
            font = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
            page.SetFont(font)
            self.nb.AddPage(page, pagelabel)

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)

        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.refreshPage)
        self.Bind(wx.EVT_TIMER, self.refreshPage)

        self.SetSizer(sizer)

    #----------------------------------------------
    def updatePage(self):

        if self.nb.IsShownOnScreen():
    #       gas = self.rb.GetStringSelection()
            page_num = self.nb.GetSelection()
            page = self.nb.GetCurrentPage()
            txt = self.getText(self.commands[page_num])
            page.ChangeValue(txt)
            self.t2.Start(config.page_refresh)
        else:
            self.t2.Stop()


    #----------------------------------------------
    def refreshPage(self, evt):

    #   self.t2.Stop()

        self.updatePage()
        evt.Skip()

    #----------------------------------------------
    def getText(self, com):

        print(com, file=sys.stderr)
        com = 'bash ' + config.python + ' ' + com
        print(com, file=sys.stderr)
        alltxt = ""
        

        file = subprocess.Popen(com, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        (txt, err) = file.communicate()
        encoding = 'utf-8'
        txt = str(txt, encoding)
        err = str(err, encoding)
        print("txt: %s" % txt, file=sys.stderr)
        print("err: %s" % err, file=sys.stderr)
        errcode = file.returncode
        if err != "":
            txt = "Error running " + com + "\n" + err

        alltxt += txt
        #return txt
        return alltxt
