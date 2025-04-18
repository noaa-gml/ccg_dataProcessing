
import os
import subprocess
import wx

import panel_config as config
import datetime

V_STRING = 0
V_FLOAT = 1
V_INT = 2
V_DATE = 3
V_TIME = 4



############################################################
def getRefTanks(rangeName=None):
        """
        Get list of tanks to use in the response curve.

        """

        stdlist =[]

        # read list
        try:
                f = open("%s/sys.ref_tanks" % config.sysdir)
        except:
                print >> sys.stderr, "Cannot open file 'sys.ref_tanks'."
                sys.exit()
        a = f.readlines()
        f.close()

        # Normal_range    S1          CA07413  ManifoldC        1       9999                  rrr
        for line in a:
                (range_name, id, serial_num, manifold, port, press, reg) = line.split()
                if rangeName is not None:
                        if range_name.lower() == rangeName.lower():
                                #manifold = manifold.strip("Manifold")
                                #port = int(sport)
                                t = (id, serial_num, manifold, port, press, reg)
                                stdlist.append(t)

                else:
                        #manifold = smanifold.strip("Manifold")
                        #port = int(sport)
                        t = (id, serial_num, manifold, port, press, reg)
                        stdlist.append(t)

        return stdlist







###########################################################
def sendSysSignal(sys, signal):

    pid = getSysPid(sys)
    if pid > 0:
        os.kill(pid, signal)
    
###########################################################
def getSysPid():

    pid = -1
    pidfile = config.sysdir + "/.pid"
    if os.path.exists(pidfile):
        f = open(pidfile)
        pid = f.readline()
        f.close()
        pid = int(pid.strip("\n"))

    return pid

###########################################################
def getSysRunning():
    """ If config.child is set, then the system has been 
    started using start.py module.  Check the status of
    the process using poll(). If result is None, process is
    running, otherwise it has stopped.  If stopped, remove
    child object by resetting config.child to None.
    This is done this way because the subprocess.Popen call
    that is used to start the system will result in a defunct
    process when the system stops, until the status of the 
    system process is checked.  Thus we must do a poll on the process
    after it has stopped so we don't get a defunct process still
    showing up in the process list.
    """

    if config.child != None:
        if config.child.poll() != None:
            config.child = None
            return False
        else:
            return True

    pid = getSysPid()
    if pid > 0:
        try:
            os.kill(pid, 0)
            return pid
        except OSError as err:
            return False
    else:
        return False


###########################################################
def getSysScheduled():

    cronfile = config.sysdir + "/.cron"
    if os.path.exists(cronfile):
        return True

    return False

###########################################################
def SetSaveButton(parent, sizer, callback):

        sizer.AddStretchSpacer(1)

        line = wx.StaticLine(parent, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        #sizer.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)
        sizer.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()
#       btn = wx.Button(parent, wx.ID_CANCEL)
#       btnsizer.AddButton(btn)
        btn = wx.Button(parent, wx.ID_SAVE)
        btn.SetDefault()
        parent.Bind(wx.EVT_BUTTON, callback, btn)
        btnsizer.AddButton(btn)
        btnsizer.Realize()
        #sizer.Add(btnsizer, 0, wx.ALIGN_BOTTOM|wx.ALIGN_CENTER_HORIZONTAL|wx.ALL, 5)
        sizer.Add(btnsizer, 0, wx.ALL, 5)

###########################################################
def SetButton(parent, sizer, callback, buttonID=wx.ID_CLOSE):

        sizer.AddStretchSpacer(1)

        line = wx.StaticLine(parent, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        #sizer.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)
        sizer.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

#        btnsizer = wx.StdDialogButtonSizer()
#       btn = wx.Button(parent, wx.ID_CANCEL)
#       btnsizer.AddButton(btn)
        btn = wx.Button(parent, buttonID)
        btn.SetDefault()
        parent.Bind(wx.EVT_BUTTON, callback, btn)
#        btnsizer.AddButton(btn)
#        btnsizer.Realize()
        #sizer.Add(btn, 0, wx.ALIGN_BOTTOM|wx.ALIGN_CENTER_HORIZONTAL|wx.ALL, 5)
        sizer.Add(btn, 0, wx.ALL, 5)

        return btn

###########################################################
def decimalDate (year, month, day, hour=12, minute=0, second=0):

        x = todoy(year, month, day)
        y = hour*3600 + minute*60

        soy = (x-1)*86400 + y + second
        if year % 4 == 0:
                dd = year + soy/3.16224e7
        else:
                dd = year + soy/3.1536e7

        return dd

###########################################################
def todoy (year, month, day):

        mona =  [31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]

        if month == 1:
                return day

        doy = mona[month-2]
        doy = doy + day
        if year % 4 == 0 and month > 2:
                doy = doy + 1
        return doy


##########################################################################
class Validator(wx.PyValidator):
    def __init__(self, type=None, pyVar=None):
        wx.PyValidator.__init__(self)
        if type == V_FLOAT:
                self.valid_chars = "0123456789.+-E"
        elif type == V_INT:
                self.valid_chars = "0123456789+-"
        elif type == V_DATE:
                self.valid_chars = "0123456789-"
        elif type == V_TIME:
                self.valid_chars = "0123456789:"
        else:
                self.valid_chars = "0123456789.+-"

        self.Bind(wx.EVT_CHAR, self.OnChar)

    def Clone(self):
        return Validator()

    def Validate(self, win):
        tc = self.GetWindow()
        val = tc.GetValue()
        print("val = ", val)
        if len(val)==0:
            print("no int data")
            return false

        for x in val:
            if x not in self.valid_chars:
                return False

        return True


    def OnChar(self, event):
        key = event.GetKeyCode()

        if key < wx.WXK_SPACE or key == wx.WXK_DELETE or key > 255:
            event.Skip()
            return

        if chr(key) in self.valid_chars:
            event.Skip()
            return

        if not wx.Validator_IsSilent():
            wx.Bell()

        # Returning without calling even.Skip eats the event before it
        # gets to the text control
        return

    def TransferToWindow(self):
        """ Transfer data from validator to window.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True # Prevent wxDialog from complaining.


    def TransferFromWindow(self):
        """ Transfer data from window to validator.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True # Prevent wxDialog from complaining.


###################################################
def run_command(args):

        try:
            p = subprocess.Popen(args, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            output,errors = p.communicate()
#        print "output is ", output
            return 0, output
        except OSError as e:
#            print args
            msg = "Error running process.\nError was: %s\n" % e
#           dlg = wx.MessageDialog(parent, msg, 'Error', wx.OK | wx.ICON_ERROR)
#           dlg.ShowModal()
#           dlg.Destroy()
            return 1, msg

