
import wx
import sys

import panel_config as config
sys.path.append("/ccg/python/ccglib")
sys.path.append(config.sysdir + "/src")

import ccg_dbutils
from panel_utils import Validator
from magiccdb import *

#####################################################################3333
class FlaskEntryDialog(wx.Dialog):
    def __init__(
        self, parent, ID, title, data=None, routes=[1,5,6,7], size=wx.DefaultSize, pos=wx.DefaultPosition,
        style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

        # connect to mysql database
        self.db = ccg_dbutils.dbUtils()

        self.is_pfp = "pfp" in title.lower()
        self.is_edit = "edit" in title.lower()

        dbfile = config.sysdir + "/" + config.database
        self.magiccdb = magiccDB(dbfile)

        if self.is_pfp or self.is_edit:
            available_manifolds = ["A", "B"]
        else:
            available_manifolds= self.get_open_manifolds()
        
        #test available_manifolds
        if len(available_manifolds) == 0:
            #need to cleanly exit add flask
            pass 

        #print data
        if data:
            manifold = data[0]
            port = data[1]
            flaskid = data[2]
        else:
            manifold = available_manifolds[0]
            port = "1"
            flaskid = ""

        if manifold == "C":
            manifold = available_manifolds[0] 
            port = "1"

        if manifold not in available_manifolds:
            manifold = available_manifolds[0] 
            port = "1"
     

        self.data = []
        self.valid_routes = routes

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        if self.is_pfp:
            txt = wx.StaticText(self, -1, "Enter the correct information for the pfp package to be analyzed.")
        else:
            txt = wx.StaticText(self, -1, "Enter the correct information for the flask to be analyzed.")

        box0.Add(txt, 0, wx.BOTTOM, 20)

        box01 = wx.BoxSizer(wx.HORIZONTAL)
        #box0.Add(box01, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)
        box0.Add(box01, 0, wx.GROW|wx.ALL, 2)

        #ch = ["A", "B"]
        txt = wx.StaticText(self, -1, "Manifold")
        box01.Add(txt, 0, wx.ALL, 2)
        self.tc1 = wx.Choice(self, -1, choices=available_manifolds )
        #box01.Add(self.tc1, 1, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT, 20)
        box01.Add(self.tc1, 1, wx.GROW|wx.RIGHT, 20)
        self.tc1.SetSelection(available_manifolds.index(manifold))

    #   ch = ["1", "3", "5", "7", "9", "11", "13", "15"]
        ch = [str(n) for n in range(1, 16, 2)]
        txt = wx.StaticText(self, -1, "Port Number")
        box01.Add(txt, 0, wx.ALL, 2)
    #   tc = wx.SpinCtrl(self, -1, str(port), min=1, max=8 )
        self.tc2 = wx.Choice(self, -1, choices=ch)
        #box01.Add(self.tc2, 1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 0)
        box01.Add(self.tc2, 1, wx.GROW|wx.ALL, 0)
        self.tc2.SetSelection(ch.index(str(port)))

    #---
        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        #box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        box1 = wx.FlexGridSizer(1,2,2,2)
        #box0.Add(box1, 0, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)
        box0.Add(box1, 0, wx.GROW|wx.ALL, 2)

        if self.is_pfp:
            txt = "PFP Flask Package ID: "
        else:
            txt = "Flask ID: "
        label = wx.StaticText(self, -1, txt)
        #box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 10)
        box1.Add(label, 0, wx.RIGHT, 10)
        self.tc3 = wx.TextCtrl(self, -1, flaskid, size=(200,-1), style=wx.TE_PROCESS_ENTER )
        #box1.Add(self.tc3, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
        box1.Add(self.tc3, 0, wx.ALL, 0)


        if not self.is_edit:
            self.Bind(wx.EVT_TEXT_ENTER, self.save_entry, self.tc3)
            self.listbox = wx.ListCtrl(self, -1, size=(-1,250), style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)
            self.listbox.InsertColumn(0, "Manifold")
            self.listbox.InsertColumn(1, "Port")
            self.listbox.InsertColumn(2, txt)
            if self.is_pfp:
                self.listbox.InsertColumn(3, "# of Flasks")
            else:
    #           self.listbox.InsertColumn(3, "Event Number")
                self.listbox.InsertColumn(3, "Site Sample Date")
            self.listbox.SetColumnWidth(0, -2)
            self.listbox.SetColumnWidth(1, -2)
            self.listbox.SetColumnWidth(2, -2)
            self.listbox.SetColumnWidth(3, -2)
            box0.Add(self.listbox, 0, wx.GROW|wx.TOP, 10)

        #------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        #box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        #------------------------------------------------
        box02 = wx.FlexGridSizer(1,3,2,2)
        box02.AddGrowableCol(0, 1)
        if not self.is_edit:
            btn = wx.Button(self, wx.ID_CLEAR)
            box02.Add(btn, 0, wx.ALIGN_LEFT)
            self.Bind(wx.EVT_BUTTON, self.clear, btn)
        else:
            txt = wx.StaticText(self, -1, " ")
            box02.Add(txt, 0, wx.ALIGN_LEFT)

        btn = wx.Button(self, wx.ID_CANCEL)
        box02.Add(btn, 0, wx.ALIGN_RIGHT)

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        box02.Add(btn, 0, wx.ALIGN_RIGHT)
        box0.Add(box02, 1, wx.GROW)
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    #------------------------------------------------
    def clear(self, evt):
        """ Clear entered information from list
        and remove any previous entries from data """

        self.data = []
        self.listbox.DeleteAllItems()
        self.tc2.SetSelection(0)

    #------------------------------------------------
    def save_entry(self, evt):

        n = self.tc1.GetSelection()
        manifold = self.tc1.GetString(n)

        n = self.tc2.GetSelection()
        portnum = self.tc2.GetString(n)

        flaskid = self.tc3.GetValue()

        if not flaskid:
            eventnum = None
        else:
            if self.is_pfp:
                eventnum = self._check_pfp_item(flaskid)
            else:
                eventnum = self._check_flask_item(flaskid)

        if eventnum is not None:

            if not self.is_pfp:
                # get site code and sample date for this event
                query = "select site, date from flask_event_view where num=%s " % eventnum
                result= self.db.doquery(query)
                sitecode = result[0]['site']
                sampledate = result[0]['date']

            self.data.append((manifold, portnum, flaskid, eventnum))

            if not self.is_edit:

                self.tc3.ChangeValue("")
                #next_n = n + 1
                next_n = n + 1
                if next_n > 15:
                    next_n = 0
                self.tc2.SetSelection(next_n)

                n = self.listbox.GetItemCount()
                #index = self.listbox.InsertStringItem(n, manifold)
                index = self.listbox.InsertItem(n, manifold)
                #self.listbox.SetStringItem(index, 0, manifold)
                self.listbox.SetItem(index, 0, manifold)
                #self.listbox.SetStringItem(index, 1, portnum)
                self.listbox.SetItem(index, 1, portnum)
                #self.listbox.SetStringItem(index, 2, flaskid)
                self.listbox.SetItem(index, 2, flaskid)
                if self.is_pfp:
                    #self.listbox.SetStringItem(index, 3, str(len(eventnum)))
                    self.listbox.SetItem(index, 3, str(len(eventnum)))
                else:
                    #self.listbox.SetStringItem(index, 3, sitecode + " %s" % sampledate)
                    self.listbox.SetItem(index, 3, sitecode + " %s" % sampledate)


            return 1
        else:
            return None


    #------------------------------------------------
    def ok(self, evt):

        if self.is_edit:
            evtnum = self.save_entry(None)
            if evtnum is None: 
                return
        #added next line since looks like needs to call this even if not an edit
        evtnum = self.save_entry(None)

        self.EndModal(wx.ID_OK)

    #--------------------------------------------------------------
    def _check_flask_item(self, flaskid):
        """ Check if flask is supposed to be analyzed.
        Return the event number if
        status num is 3
        path number includes this system
        otherwise return None
        """

        print("in check_flask_item:  flaskid = %s" % flaskid, file=sys.stderr)

        query = "SELECT id,sample_status_num,event_num,path FROM flask_inv "
        query += "WHERE id='%s'" % flaskid

        result = self.db.doquery(query)

        if result:

            # path must include valid route number,
            # and status number must be 3 for us to analyze this flask
            ok_to_analyze = False
            id = result[0]['id']
            statusnum = result[0]['sample_status_num']
            eventnum = result[0]['event_num']
            path = result[0]['path']

            #if no path, assign default
            if not path:
                path = "-9"
            pathnums = path.split(",")
            for val in pathnums:
                if int(val) in self.valid_routes:
                    ok_to_analyze = True

            if statusnum != 3:
                ok_to_analyze = False

            if not ok_to_analyze:
                s = "Flask ID (%s) not found in inventory. Do not analyze." % flaskid
                dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return None
            else:
                return eventnum

        else:
            s = "Flask ID (%s) not found in inventory. Do not analyze." % flaskid
            dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return None

    #--------------------------------------------------------------
    def _check_pfp_item(self, pfpid):
        """ Check if pfp is supposed to be analyzed.
        Return  a list of tuples if
        status num is 3
        path number includes this system
        otherwise return None
        Each tuple in the returned list contains 
            (flasknum, flaskid, eventnum)
        where
            flasknum - number of the flask in the pfp package (1, 2, ...)
            flaskid - id of the single flask in the pfp
            eventnum - event number for the single flask
        The length of the list is the number of flasks to analyzer from the pfp.
        """

        # Replace the 'FP' part of serial number with '%'
        idstr = pfpid.replace("FP", "%")

        query = "SELECT id,sample_status_num,event_num,path FROM pfp_inv "
        query += "WHERE id LIKE '%s' AND id !='%s'" % (idstr, pfpid)
        #print >> sys.stderr, "sysinfo, check_pfp_time, query = %s" % query

        result = self.db.doquery(query)
        if result:
            data = []
            for row in result:
                #for row in reversed(result):
                # path must include valid route number,
                # and status number must be 3 for us to analyze this flask
                ok_to_analyze = False
                flaskid = row["id"]
                statusnum = row["sample_status_num"]
                eventnum = row["event_num"]
                path = row["path"]
                #print("flaskid: %s  statusnum: %s  eventnum: %s   path: %s" % (flaskid, statusnum, eventnum, path), file=sys.stderr)
                # if no path, assign default
                if not path:
                    path = "-9"
                pathnums = path.split(",")
                for val in pathnums:
                    if int(val) in self.valid_routes:
                        ok_to_analyze = True

                if statusnum != 3:
                    ok_to_analyze = False

                if ok_to_analyze:
                    (a, flasknum) = flaskid.split("-")
                    flasknum = int(flasknum)
                    print("flasknum: %s" % flasknum, file=sys.stderr)
                    data.append((flasknum, flaskid, eventnum))

            if len(data):
                return data
            else:
                s = "No valid flasks found in inventory. Do not analyze."
                dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return None


        else:
            s = "Flask ID not found in inventory. Do not analyze."
            dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return None
        
    #--------------------------------------------------------------
    def get_open_manifolds(self):
        """ 
        Returns list of flask manifolds with no "ready" samples.
        Used to prevent flask from being added to a manifold with samples
        already on.

        """

        manifolds = ["A","B"]

        #get open manifolds     
        rows = self.magiccdb.get_analysis_info()
#output = analysis_id, rowid, manifold, port, serial_num, sample_type, 
#       num_samples, pressure, regulator, sample_num, flask_id, event_num, status, adate 
        for line in rows:
            #if line[1].upper() == "A" and line[11].upper() == "READY":
            if line[2].upper() == "A" and line[12].upper() == "READY":
                if "A" in manifolds: manifolds.remove("A")
            #if line[1].upper() == "B" and line[11].upper() == "READY":
            if line[2].upper() == "B" and line[12].upper() == "READY":
                if "B" in manifolds: manifolds.remove("B")

        #print >> sys.stderr, "in get_open_manifolds,  open_manifolds = %s" % manifolds
        return manifolds

#####################################################################3333
class TankEntryDialog(wx.Dialog):
    def __init__(
            self, parent, ID, title, data=None, size=wx.DefaultSize, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
    ):
        wx.Dialog.__init__(self, parent, -1, title)

        print("data: \n", data, file=sys.stderr)

        if data:
            manifold = data[0]
            port = data[1]
            serialnum = data[2]
            #pressure = str(data[3])
            if data[3]: 
                pressure = str(data[3])
            else:
                pressure = ""
                
            if data[4]:
                regulator = data[4]
            else:
                regulator = ""
            numaliquots = str(data[5])
            if data[6]:
                request_num = str(data[6])
            else:
                request_num = ""
        else:
            manifold = ""
            port = ""
            serialnum = ""
            pressure = ""
            regulator = ""
            numaliquots = config.num_tank_cal_cycles
            request_num = ""
       
        #print("manifold: %s   port: %s    serialnum: %s  pressure: %s    regulator: %s    numaliquots: %s" % (manifold, port, serialnum, pressure, regulator, numaliquots), file=sys.stderr) 

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        txt = wx.StaticText(self, -1, "Enter the correct information for the tank to be analyzed.", size=(-1,-1))
        box0.Add(txt, 0, wx.ALL, 10)

        box1 = wx.FlexGridSizer(7,2,2,2)
        box1.SetFlexibleDirection(wx.HORIZONTAL)
        box1.AddGrowableCol(1)
        #box0.Add(box1, 1, wx.GROW|wx.ALIGN_CENTER|wx.ALL, 2)
        box0.Add(box1, 1, wx.GROW|wx.ALL, 2)

        ch = ["A", "B", "C", "D"]
        txt = wx.StaticText(self, -1, "Manifold: ")
        #box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc0 = wx.Choice(self, -1, choices=ch )
        box1.Add(self.tc0, 0, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)
        self.tc0.SetSelection(ch.index(manifold))

        ch = [str(n) for n in range(1, 17, 1)]
        #ch = ["-9"]
        #for n in range(1, 17, 1):
        #    ch.append(str(n))
        #print("in TankEntryDialog - ch:", ch)
        label = wx.StaticText(self, -1, "Port Number: ")
        #box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc1 = wx.Choice(self, -1, choices=ch )
        box1.Add(self.tc1, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)
        self.tc1.SetSelection(ch.index(str(port)))

        txt = wx.StaticText(self, -1, "Serial Number:")
        #box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc2 = wx.TextCtrl(self, -1, serialnum )
        box1.Add(self.tc2, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

        txt = wx.StaticText(self, -1, "Pressure:")
        #box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc3 = wx.TextCtrl(self, -1, pressure )
        box1.Add(self.tc3, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

        label = wx.StaticText(self, -1, "Regulator: ")
        #box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc4 = wx.TextCtrl(self, -1, regulator )
        box1.Add(self.tc4, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

        label = wx.StaticText(self, -1, "Number of Aliquots: ")
        #box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(label, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc5 = wx.TextCtrl(self, -1, numaliquots, validator=Validator("V_INT") )
        box1.Add(self.tc5, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)

        txt = wx.StaticText(self, -1, "Request Number:")
        #box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 5)
        box1.Add(txt, 0, wx.ALIGN_RIGHT|wx.RIGHT, 5)
        self.tc6 = wx.TextCtrl(self, -1, request_num )
        box1.Add(self.tc6, 1, wx.ALIGN_RIGHT|wx.ALL|wx.GROW, 0)


        #------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        #box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        #------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        box0.Fit(self)

    #------------------------------------------------
    def ok(self, evt):

        self.data = []
        n = self.tc0.GetSelection()
        val = self.tc0.GetString(n)
        self.data.append(val)

        n = self.tc1.GetSelection()
        val = self.tc1.GetString(n)
        self.data.append(val)

        val = self.tc2.GetValue()
        self.data.append(val.upper())

        val = self.tc3.GetValue()
        self.data.append(val)

        val = self.tc4.GetValue()
        self.data.append(val)

        val = self.tc5.GetValue()
        self.data.append(val)

        val = self.tc6.GetValue()
        self.data.append(val)

        self.EndModal(wx.ID_OK)
