
import os
import wx
import signal

import panel_config as config
from panel_utils import *


#--------------------------------------------------------------
class mkSetupPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.sys = gas

        box = wx.StaticBox(self, -1, "Setup", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)


        self.showModes(sizer)
        self.showSystems(box, sizer)

        title = wx.StaticText(self, -1, "Options")
        title.SetFont(wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_BOLD))
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.ALL, 10)

        self.runshots = wx.CheckBox(self, -1, "Run Continous reference gas shots after completion")
        sizer.Add(self.runshots, 0, wx.LEFT|wx.ALL, 2)

        self.getsetup()

        SetSaveButton(self, sizer, self.oknew)

        self.SetSizer(sizer)

    #--------------------------------------------------------------
    def showModes(self, sizer):
        """ Create a radio box for each mode available """

        title = wx.StaticText(self, -1, "Select mode of operation.  Press 'Save' when done.")
        title.SetFont(wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_BOLD))
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.ALL, 5)

        self.modelist = {}
        modefile = config.sysdir + "/sys.modes"
        f = open(modefile)
        for line in f:
            (key, value) = line.strip("\n").split(":")
            key = int(key.strip())
            value = value.strip()
            self.modelist[key] = value
        f.close()

        keys = list(self.modelist.keys())
        keys.sort()
        labels =  [ str(key) + ": " + self.modelist[key] for key in keys]
    
        self.rb = wx.RadioBox(
                self, -1, "", wx.DefaultPosition, wx.DefaultSize,
                labels, 1, wx.RA_SPECIFY_COLS  | wx.NO_BORDER
                )
        sizer.Add(self.rb, 0, wx.ALL, 5)


    #--------------------------------------------------------------
    def showSystems(self, box, sizer):
        """ Show check box for each system available, 
        and a list of gases available for each system """

        title = wx.StaticText(self, -1, "Select analysis systems.")
        title.SetFont(wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_ITALIC, wx.FONTWEIGHT_BOLD))
        sizer.Add(title, 0, wx.ALIGN_LEFT|wx.ALL, 5)

        self.cb = []
        self.gascb = []

        # show a checkbox for each system
        for system in list(config.systems.keys()):
            b1 = wx.CheckBox(self, -1, system)
            sizer.Add(b1, 0, wx.LEFT|wx.ALL, 5)
            self.cb.append(b1)
            b1.Bind(wx.EVT_CHECKBOX, self.setbutton)

            # show a checkbox for each gas for the system
            hsizer = wx.BoxSizer(wx.HORIZONTAL)
            sizer.Add(hsizer, 0, wx.ALIGN_LEFT|wx.LEFT, 30)
            for gas in config.systems[system]:
                b2 = wx.CheckBox(self, -1, gas)
                hsizer.Add(b2, 0, wx.ALL, 5)
                self.gascb.append((b2, system, gas))
                b2.Enable(False)


    #--------------------------------------------------------------
    def setbutton(self, event):
        """ Enable/disable gas check boxes for systems """

        cb = event.GetEventObject()
        system = cb.GetLabelText()

        if event.IsChecked():
            for b2, sys, gas in self.gascb:
                if sys == system:
                    b2.Enable(True)
        else:
            for b2, sys, gas in self.gascb:
                if sys == system:
                    b2.Enable(False)

    #--------------------------------------------------------------
    def oknew(self, event):

        # get mode string
        label = self.rb.GetStringSelection()

        # get mode number 
        (mode, s) = label.split(':')

        # get which systems have been selected
        systems = {}
        for b1 in self.cb:
            if b1.IsChecked():
                label = b1.GetLabelText()
                if label not in systems:
                    systems[label] = []

        # check that a system has been selected
        if len(systems) == 0:
            s = "Error: must select a system"
            dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return

        # get which gases have been selected for each system
        for b2,sys,gas in self.gascb:
            if sys in systems:    # only check gases for selected systems
                if b2.IsChecked():
                    systems[sys].append(gas)

        # check that at least one gas is checked for each system
        for sys in systems:
            if len(systems[sys]) == 0:
                s = "Error: must select at least one gas for %s" % sys
                dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return


        # save setup to file
        file = config.sysdir + "/sys.setup"

        f = open (file, "w")
        f.write("Mode: %s\n" % mode)
        # for each checked system, write one line with system name and gases selected
        for sys in systems:
            gases = " ".join(systems[sys])
            f.write("Flask_System: %s - %s\n" % (sys,gases))

        if self.runshots.IsChecked():
            f.write("RunShots: 1\n")
        else:
            f.write("RunShots: 0\n")

        f.close()

        sysstring = " ".join(list(systems.keys()))
        config.main_frame.updateStatus ("Updated setup: Mode %s, Cal System %s" % (mode, sysstring))

        # need something like - if sys running, send USR1 signal to run manager
    #    if getSysRunning():
    #        sendSysSignal(self.sys, signal.SIGUSR1)


    #--------------------------------------------------------------
    def getsetup(self):

        file = config.sysdir + "/sys.setup"
        if os.path.exists(file):
            f = open(file, "r")
            for line in f:
                line = line.strip("\n")
                if "Mode:" in line:
                    list = line.split()
                    modenum = int(list[1])
                for key, value in self.modelist.items():
                    if modenum == key:
                        self.rb.SetSelection(modenum-1)

                if "Flask_System:" in line:
                    list = line.split(":")
                    system, gasstr = list[1].split("-")
                    system = system.strip()
                    gases = gasstr.split()
                    # for each system in setup file, set system checkbox to 1 
                    for b1 in self.cb:
                        if system == b1.GetLabelText():
                            b1.SetValue(1)
                            # for each gas of the system in setup file, set gas checkbox to 1
                            for (b2,sys,gas) in self.gascb:
                                if sys==system:
                                    b2.Enable(True)
                                    if gas in gases: 
                                        b2.SetValue(1)
            f.close()

