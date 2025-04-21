
import sys
import os
import wx
import subprocess
import multiprocessing
import datetime

import panel_config as config

from panel_utils import *
from todo import TodoDialog
from dialogs import TankEntryDialog

sys.path.append("/ccg/python/ccglib")
sys.path.append(config.sysdir + "/src")
from magiccdb import *

#import MySQLdb
import ccg_dbutils


sys.path.append("%s/src" % os.environ["HOME"])
from utils import get_resource

#sys.path.append(config.sysdir + "/src/hm")
#from resources import get_resources
#magicc_conf = "%s/%s" % (os.environ["HOME"], config.conffile)
#devices, virtual_devices, resources = get_resources(magicc_conf)

#--------------------------------------------------------------
class mkSysInfo(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.manifold = "A"
        #self.port = -1
        self.port = 1
        self.listfont = wx.Font(9, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)

        dbfile = config.sysdir + "/" + config.database
        self.db = magiccDB(dbfile)

        self.valid_routes = self._get_routes()

        box = wx.StaticBox(self, -1, "Sample Information", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        page = self.set_summary_page()
        self.nb.AddPage(page, "Summary")

        self.details_page = self.set_details_page()
        self.nb.AddPage(self.details_page, "Details")

        self.info_page = self.set_info_page()
        self.nb.AddPage(self.info_page, "Sample Info")

        sizer.Add(self.nb, 100, wx.EXPAND|wx.ALL, 5)


        b1 = wx.Button(self, -1, "Refresh")
        self.Bind(wx.EVT_BUTTON, self.updatePage, b1)
        sizer.Add(b1)



        self.finishlabel = wx.StaticText(self, -1, "Estimated finish time: ")
        sizer.Add(self.finishlabel, 0, wx.TOP, 5)


        self.SetSizer(sizer)


    #--------------------------------------------------------------
    def set_summary_page(self):

        p1 = wx.Panel(self.nb)
        sizer = wx.BoxSizer(wx.HORIZONTAL)

        self.listbox = wx.ListCtrl(p1, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)
        colnames = self.db.get_column_names("sample_info")
        for n, name in enumerate(colnames):
            self.listbox.InsertColumn(n, name)
            self.listbox.SetColumnWidth(n, -2)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, self.listbox)

        sizer.Add(self.listbox, 1, wx.EXPAND|wx.ALL, 5)

        panel = wx.Panel(p1, -1)
        sizer.Add(panel, 0, wx.ALL, 3)

        sizer2 = wx.BoxSizer(wx.VERTICAL)


        b1 = wx.Button(panel, -1, "Clear List")
        self.editbutton = wx.Button(panel, -1, "Edit...")
        self.deletebutton = wx.Button(panel, -1, "Delete")
        #self.junkair_button = wx.Button(panel, -1, "Add JunkAir (warm-up)")
        self.ref_button = wx.Button(panel, -1, "Add Ref (warm-up)")
        self.todo_button = wx.Button(panel, -1, "Pick from TODO list")
        #self.flaskbutton = wx.Button(panel, -1, "Add Flask...")
        #b5 = wx.Button(panel, -1, "Add PFP...")
        b6 = wx.Button(panel, -1, "Add Cal...")
        self.co2_secondary = wx.Button(panel, -1, "CO2 2\N{DEGREE SIGN} Resp Curve")
        self.ch4_secondary = wx.Button(panel, -1, "CH4 2\N{DEGREE SIGN} Resp Curve")
        self.co2_primary_a = wx.Button(panel, -1, "CO2 1\N{DEGREE SIGN} Set A Resp Curve")
        self.co2_primary_b = wx.Button(panel, -1, "CO2 1\N{DEGREE SIGN} Set B Resp Curve")
        self.ch4_primary_a = wx.Button(panel, -1, "CH4 1\N{DEGREE SIGN} Set A Resp Curve")
        self.ch4_primary_b = wx.Button(panel, -1, "CH4 1\N{DEGREE SIGN} Set B Resp Curve")
        self.co2_nextgen_primary_a = wx.Button(panel, -1, "CO2 NextGen 1\N{DEGREE SIGN} Set A \nResp Curve")
        self.co2_nextgen_primary_b = wx.Button(panel, -1, "CO2 NextGen 1\N{DEGREE SIGN} Set B \nResp Curve")
        #self.normal_nl = wx.Button(panel, -1, "Add Normal Resp Curve...")
        #self.manual_nl = wx.Button(panel, -1, "Add Manual Resp Curve...")
        #self.dilution_nl = wx.Button(panel, -1, "Add CO dilution std Resp Curve...")

        sizer2.Add(b1, 0, wx.ALL, 3)
        sizer2.Add(self.editbutton, 0, wx.ALL, 3)
        sizer2.Add(self.deletebutton, 0, wx.ALL, 3)
        #sizer2.Add(self.junkair_button, 0, wx.ALL, 3)
        sizer2.Add(self.ref_button, 0, wx.ALL, 3)
        sizer2.Add(self.todo_button, 0, wx.ALL, 3)
    
        #sizer2.Add(self.flaskbutton, 0, wx.ALL, 3)
        #sizer2.Add(b5, 0, wx.ALL, 3)
        sizer2.Add(b6, 0, wx.ALL, 3)
        sizer2.Add(self.co2_secondary, 0, wx.ALL, 3)
        sizer2.Add(self.ch4_secondary, 0, wx.ALL, 3)
        sizer2.Add(self.co2_primary_a, 0, wx.ALL, 3)
        sizer2.Add(self.co2_primary_b, 0, wx.ALL, 3)
        sizer2.Add(self.ch4_primary_a, 0, wx.ALL, 3)
        sizer2.Add(self.ch4_primary_b, 0, wx.ALL, 3)
        sizer2.Add(self.co2_nextgen_primary_a, 0, wx.ALL, 3)
        sizer2.Add(self.co2_nextgen_primary_b, 0, wx.ALL, 3)
        #sizer2.Add(self.normal_nl, 0, wx.ALL, 3)
        #sizer2.Add(self.manual_nl, 0, wx.ALL, 3)
        #sizer2.Add(self.dilution_nl, 0, wx.ALL, 3)

        self.Bind(wx.EVT_BUTTON, self.clearList, b1)
        self.Bind(wx.EVT_BUTTON, self.editEntry, self.editbutton)
        self.Bind(wx.EVT_BUTTON, self.deleteEntry, self.deletebutton)
    
        #self.Bind(wx.EVT_BUTTON, self.addJunkEntry, self.junkair_button)
        self.Bind(wx.EVT_BUTTON, self.addRefEntry, self.ref_button)
        self.Bind(wx.EVT_BUTTON, self.pickFromTODO, self.todo_button)
    
        #self.Bind(wx.EVT_BUTTON, self.addFlaskEntry, self.flaskbutton)
        #self.Bind(wx.EVT_BUTTON, self.addPfpEntry, b5)
        self.Bind(wx.EVT_BUTTON, self.addCalEntry, b6)
        self.Bind(wx.EVT_BUTTON, self.addCO2SecondaryNL, self.co2_secondary)
        self.Bind(wx.EVT_BUTTON, self.addCH4SecondaryNL, self.ch4_secondary)
        self.Bind(wx.EVT_BUTTON, self.addCO2PrimaryANL, self.co2_primary_a)
        self.Bind(wx.EVT_BUTTON, self.addCO2PrimaryBNL, self.co2_primary_b)
        self.Bind(wx.EVT_BUTTON, self.addCH4PrimaryANL, self.ch4_primary_a)
        self.Bind(wx.EVT_BUTTON, self.addCH4PrimaryBNL, self.ch4_primary_b)
        self.Bind(wx.EVT_BUTTON, self.addCO2NextGenPrimaryANL, self.co2_nextgen_primary_a)
        self.Bind(wx.EVT_BUTTON, self.addCO2NextGenPrimaryBNL, self.co2_nextgen_primary_b)
        #self.Bind(wx.EVT_BUTTON, self.addNormalNL, self.normal_nl)
        #self.Bind(wx.EVT_BUTTON, self.addManualNL, self.manual_nl)
        #self.Bind(wx.EVT_BUTTON, self.addDilutionNL, self.dilution_nl)


        self.editbutton.Enable(False)
        self.deletebutton.Enable(False)

        self.test_nl()
        self.test_flask_addition()


        panel.SetSizer(sizer2)

        p1.SetSizer(sizer)

        return p1

    #--------------------------------------------------------------
    def set_details_page(self):

        page = wx.ListCtrl(self.nb, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)
        #colnames = ["ID", "Manifold", "Port", "Sample ID", "Sample Type", "Sample Num", "Event #", "Status", "Adate"]
        colnames = ["a_id", "ID", "Manifold", "Port", "Sample ID", "Sample Type", "Sample Num", "Event #", "Status", "Adate"]
        for n, name in enumerate(colnames):
            page.InsertColumn(n, name)
            page.SetColumnWidth(n, -2)

        #self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.show_sampling, page)

        return page


    #--------------------------------------------------------------
    def set_info_page(self):

        page = wx.ListCtrl(self.nb, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES)
        colnames = ["Manifold", "Port", "Sample ID", "Sample Type", "Sample Num", "Event #", "Station", "Sample Date", "Sample Time", "Method"]
        for n, name in enumerate(colnames):
            page.InsertColumn(n, name)
            page.SetColumnWidth(n, -2)

        #self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.show_sampling, page)

        return page


    #--------------------------------------------------------------
    def updatePage(self, event=None):
        """ called when flask page becomes visible """

        self.updateListBox()

    #--------------------------------------------------------------
    def updateFinishTime(self):

        MINUTES_PER_SAMPLE = 6.3
        regulator_flush_time = 4.0
        sys_evac_time = 0.0
        process_data_time = 0.2

        data = self.db.get_analysis_info()
        ntodo = 0
        extra_time = 0.0
        previous_sample_type = ""
        previous_info_id = "-1"

        for n, line in enumerate(data):
            #print("ntodo:  %s    extra_time:   %s" % (ntodo, extra_time))
            if line[12].lower() == "complete" or line[12].lower() == "error":  continue

            ntodo += 1  # 1 on co2cal-2 where R0&SMP run at same time, 2 elsewhere
            #if switch sample type, add an extra reference shot
            if line[5] != previous_sample_type:
                ntodo += 0 # 0 on co2cal-2 where R0&SMP run at same time, 1 elsewhere
                extra_time += process_data_time
                
            #if sample type equal cal, add extra ref shot for each sample tank switch
            # and add in 3 minute regulator flush. If previous sample_type = cal then add another ref shot
            if line[5].upper() == "CAL" and line[1] != previous_info_id:
                extra_time += regulator_flush_time # regulator flush
                extra_time += sys_evac_time  # extra system evacuation when switching
                if previous_sample_type == "CAL":
                    ntodo += 0  # 0 on co2cal-2 where R0&SMP run at same time, 1 elsewhere
                    extra_time += process_data_time

            # add regulator flush time for each standard in response curve
            if line[5].upper() == "NL" and line[1] != previous_info_id:
                extra_time += regulator_flush_time # regulator flush

            previous_sample_type = line[5]
            previous_info_id = line[1]
            
            #add final ref shot
            if n == len(data):
                ntodo += 0 # 0 on co2cal-2 where R0&SMP run at same time, 1 elsewhere


        if ntodo == 0:
            if getSysRunning():
                self.finishlabel.SetLabel("Estimated finish time: Running last reference shot")
            else:
                self.finishlabel.SetLabel("Estimated finish time: COMPLETED")

        else:
            #print("ntodo: %s" % ntodo, file=sys.stderr)
            #print("time for ntodo: %s" % (ntodo*MINUTES_PER_SAMPLE), file=sys.stderr)
            #print("extra time: %s" % extra_time, file=sys.stderr)
            now = datetime.datetime.now()
            td = datetime.timedelta(minutes=(MINUTES_PER_SAMPLE*ntodo)+extra_time)  
            s = now + td
            self.finishlabel.SetLabel("Estimated finish time: %s" % s.strftime("%c"))


    #--------------------------------------------------------------
    def updateListBox(self):
        """ Update the list of flask entries with data from
        the flask sample table file.
        """

        # update the summary page
        rows = self.db.get_all()
        
        self.listbox.DeleteAllItems()
        for n, line in enumerate(rows):
            #index = self.listbox.InsertStringItem(n, str(line[0]))
            index = self.listbox.InsertItem(n, str(line[0]))
            #print "index is ", index, line
            self.listbox.SetItemFont(index, self.listfont)

            for i, val in enumerate(line):
                #self.listbox.SetStringItem(index, i, str(val))
                self.listbox.SetItem(index, i, str(val))

            self.manifold = line[1]
            self.port = line[2]

        self.listbox.EnsureVisible(len(rows)-1)

        self.editbutton.Enable(False)
        self.deletebutton.Enable(False)

        # set group and port to next open port
        self._set_next_port()

        # update the details page
        data = self.db.get_analysis_info()
        #output = analysis_id, rowid, manifold, port, serial_num, sample_type, 
        #num_samples, pressure, regulator, sample_num, flask_id, event_num, status, adate 

        self.details_page.DeleteAllItems()
        for n, line in enumerate(data):

            #index = self.details_page.InsertStringItem(n, str(line[1]))
            index = self.details_page.InsertItem(n, str(line[1]))
            self.details_page.SetItemFont(index, self.listfont)
            #t = (line[0], line[1], line[2], line[3], line[4], line[8], line[10], line[11], line[12])
            t = (line[0], line[1], line[2], line[3], line[4], line[5], line[9], line[11], line[12], line[13])
            #print("sysinfo updateListBox  t:", t, file=sys.stderr) 
            for i, val in enumerate(t):
                #self.details_page.SetStringItem(index, i, str(val))
                self.details_page.SetItem(index, i, str(val))

        self.details_page.SetColumnWidth(7, 80)
        self.details_page.SetColumnWidth(8, 160)

        self.details_page.EnsureVisible(len(data)-1)

        # update the sample info page
        db = ccg_dbutils.dbUtils()
        

        self.info_page.DeleteAllItems()
        for n, line in enumerate(data):
            #manifold = line[1]
            #port = line[2]
            #sample_id = line[3]
            #sample_type = line[4]
            #sample_num = line[9]
            #event_num = line[10]
            manifold = line[2]
            port = line[3]
            sample_id = line[4]
            sample_type = line[5]
            sample_num = line[10]
            event_num = line[11]

            if sample_type == "flask" or sample_type == "pfp":

                query = "SELECT id,code,date,time,me,comment FROM flask_event "
                query += "LEFT JOIN gmd.site ON flask_event.site_num=site.num "
                query += "WHERE flask_event.num=%s" % event_num
                #print query

                #c.execute(query)
                #result = c.fetchone()
                result = db.doquery(query)

                (rid, station, sample_date, sample_time, sample_method, comment) = result

                #index = self.info_page.InsertStringItem(n, str(line[1]))
                index = self.info_page.InsertItem(n, str(line[1]))
                self.details_page.SetItemFont(index, self.listfont)
                t = (manifold, port, sample_id, sample_type, sample_num, event_num, station, sample_date, sample_time, sample_method)
                for i, val in enumerate(t):
                    #self.info_page.SetStringItem(index, i, str(val))
                    self.info_page.SetItem(index, i, str(val))

            elif sample_type == "cal":

                #serial_num = line[3]
                serial_num = line[4]
                query = "SELECT code,date,location,method FROM reftank.fill "
                query += "WHERE serial_number='%s' order by code desc limit 1" % serial_num
                #print query

                #c.execute(query)
                result = db.doquery(query)
                if result: result = result[0]
                #if c.rowcount == 0:
                if not result:
                    fillcode = 'A'
                    station = 'UNK'
                    sample_date = datetime.datetime(2000, 1, 1)
                    sample_method = ""
                else:
                    #result = c.fetchone()
                    #print >> sys.stderr, result
                    fillcode = result['code']
                    sample_date = result['date']
                    station = result['location']
                    sample_method = result['method']
#                    (fillcode, sample_date, station, sample_method) = result

                #index = self.info_page.InsertStringItem(n, str(line[1]))
                index = self.info_page.InsertItem(n, str(line[1]))
                self.details_page.SetItemFont(index, self.listfont)
                t = (manifold, port, sample_id, sample_type, sample_num, fillcode, station, sample_date, "", sample_method)
                for i, val in enumerate(t):
                    #self.info_page.SetStringItem(index, i, str(val))
                    self.info_page.SetItem(index, i, str(val))

            elif sample_type == "nl" or sample_type == "warmup":
                #colnames = [" ", " ", "Sample ID", "Sample Type", "Sample Num", "Event #", "Station", "Sample Date", "Sample Time", "Method"]
                #index = self.info_page.InsertStringItem(n, str(line[1]))
                index = self.info_page.InsertItem(n, str(line[1]))
                self.details_page.SetItemFont(index, self.listfont)
                t = (manifold, port, sample_id, sample_type, sample_num, 0, '', '', '', '')
                for i, val in enumerate(t):
                    #self.info_page.SetStringItem(index, i, str(val))
                    self.info_page.SetItem(index, i, str(val))

        self.info_page.EnsureVisible(len(data)-1)

#        db.close()
        #c.close()

        self.test_flask_addition()
        self.test_nl()

        self.updateFinishTime()

    #--------------------------------------------------------------
    def show_sampling(self, evt):

        currentItem = evt.m_itemIndex
        item = self.info_page.GetItem(currentItem, 2)
        flaskid = item.GetText()
        item = self.info_page.GetItem(currentItem, 3)
        sample_type = item.GetText()
        item = self.info_page.GetItem(currentItem, 5)
        event_num = item.GetText()

        #print flaskid, sample_type, event_num

        if sample_type == "flask" or sample_type == "pfp":
            db = ccg_dbutils.dbUtils()
            
            query = "SELECT id,code,date,time,me,comment FROM flask_event "
            query += "LEFT JOIN gmd.site ON flask_event.site_num=site.num "
            query += "WHERE flask_event.num=%s" % event_num

            #c.execute(query)
            #result = c.fetchone()
            result = db.doquery(query)
            (flaskid, sta, date, time, method, comment) = result
            #print result

            #c.close()
#            db.close()

            win = TransientPopup(self, wx.SIMPLE_BORDER, result)

            # Show the popup right below or above the button
            # depending on available screen space...
            btn = evt.GetEventObject()
            pos = btn.ClientToScreen( (0,0) )
            sz =  btn.GetSize()
            pos = wx.GetMousePosition()
            #print pos
            win.Position(pos, (0,0))
            #win.Position(pos, (0, sz[1]))
            win.Popup()

    
    #--------------------------------------------------------------
    def set_listbox_item(self, index, row):
        """ set the columns in a single listbox row given by 'index' """

        #get flask information from event number
        #query = "SELECT id,code,date,time,me,flask_event.num,comment FROM flask_event "
        #query += "LEFT JOIN gmd.site ON flask_event.site_num=site.num "
        #query += "WHERE flask_event.num=%s" % event

        #c.execute(query)
        #result = c.fetchone()
        #(id, sta, date, time, method, eventnum, comment) = result

        for n, val in enumerate(row):
            if val is None:
                #self.listbox.SetStringItem(index, n, '')
                self.listbox.SetItem(index, n, '')
            else:
                #self.listbox.SetStringItem(index, n, str(val))
                self.listbox.SetItem(index, n, str(val))


    #--------------------------------------------------------------
    def OnItemSelected(self, evt):
        """ If a line in a listbox is selected, remember the row number.
        """
        self.currentItem = evt.Index
        #self.editbutton.Enable(True)
        self.editbutton.Enable(False)  # hardcode "edit" button disabled to prevent flasks being rerun. If need in future put in checks.
        self.deletebutton.Enable(True)

    #--------------------------------------------------------------
    def editEntry(self, evt):

        # get row id
        item = self.listbox.GetItem(self.currentItem, 0)
        rowid = int(item.GetText())

        # get sample type
        item = self.listbox.GetItem(self.currentItem, 4)
        sample_type = item.GetText()

        if sample_type == "flask":
            self.editFlaskEntry(rowid)
        elif sample_type == "cal":
            self.editCalEntry(rowid)
        elif sample_type == "pfp":
            self.editPfpEntry(rowid)


    #--------------------------------------------------------------
    def addFlaskEntry(self, evt):
        """ Add a new entry for a single flask """

        data = [self.manifold, self.port, ""]
        dlg = FlaskEntryDialog(self, -1, "Add Flask Entry", data = data, routes=self.valid_routes)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            #print "dlg.data is", dlg.data
            # if data added in dialog, enter it into database
            for (manifold, port, flaskid, eventnum) in dlg.data:
    #           eventnum = self._check_flask_item(flaskid)
                sample_number = 1  # always 1 for flasks
                num_aliquots = 1   # always 1 for flasks
    #           if eventnum is not None:
                sample_info = (manifold, port, flaskid, "flask", num_aliquots, "", "")
                analysis_info = (sample_number, flaskid, eventnum)
                rowid = self.db.insert_entry(sample_info, analysis_info)

            self.updateListBox()
    
            # add check to make sure ok to prep manifold
            msgdlg = wx.MessageDialog(self,'Do you want to prep the flask manifold now?', 'Prep Manifold?', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
            if msgdlg.ShowModal() == wx.ID_YES:

                if dlg.data:
                    cmd = "/home/magicc/bin/prep_flask_manifold.py"
                    subprocess.Popen(cmd, shell=True, stdin=None, stdout=None, stderr=None)

    #--------------------------------------------------------------
    def editFlaskEntry(self, rowid):
        """ Edit an existing single flask entry """

        # get sample data: manifold, port, id
        data = []
        for i in [1, 2, 3]:  # these are the columns numbers with the data we need
            item = self.listbox.GetItem(self.currentItem, i)
            s = item.GetText()
            data.append(s)

        dlg = FlaskEntryDialog(self, -1, "Edit Flask Entry", data = data, routes=self.valid_routes)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            for (manifold, port, flaskid, eventnum) in dlg.data:
                sample_number = 1  # always 1 for flasks
                num_aliquots = 1   # always 1 for flasks
                sample_info = (manifold, port, flaskid, "flask", num_aliquots, "", "")
                analysis_info = (sample_number, flaskid, eventnum)
                self.db.update_entry(rowid, sample_info, analysis_info)
                self.updateListBox()

        self.test_flask_addition()

    #--------------------------------------------------------------
    def test_flask_addition(self):
        """ tests for open manifolds, if none then disable add flask button
        Also test for flasks marked "not_ready", these are currently 
        being preped so should not add more until they are done. Prevents
        multiple instances of prep_manifold from starting and prevents 
        confusion in user on which flasks to open.
        """
        manifolds = ["A","B"]
        add_flasks = True

        #get open manifolds     
        rows = self.db.get_analysis_info()

        for line in rows:
            if line[2].upper() == "A" and line[12].upper() == "READY":
                if "A" in manifolds: manifolds.remove("A")
            if line[2].upper() == "B" and line[12].upper() == "READY":
                if "B" in manifolds: manifolds.remove("B")
            if line[12].upper() == "NOT_READY":
                add_flasks = False

        if manifolds and add_flasks:
            #self.flaskbutton.Enable(True)
            pass
        else:
            #self.flaskbutton.Enable(False)
            pass

        return 

    #--------------------------------------------------------------
    def test_nl(self):
        """ look to see if any NL samples listed.
            Deactivates nl buttons if one nl run is already listed
        """
    
        nl_test = False
        #this will allow nl runs after the first one is done but be careful since it
        #will allow next nl to be entered before the last R0 is finished.
        rows = self.db.get_analysis_info()
        for line in rows:
            if line[5].upper() == "NL" and line[12].upper() == "READY":
                nl_test = True
                break
    
        #self.Bind(wx.EVT_BUTTON, self.addCO2SecondaryNL, self.co2_secondary)
        #self.Bind(wx.EVT_BUTTON, self.addCH4SecondaryNL, self.ch4_secondary)
        #self.Bind(wx.EVT_BUTTON, self.addCO2PrimaryANL, self.co2_primary_a)
        #self.Bind(wx.EVT_BUTTON, self.addCO2PrimaryBNL, self.co2_primary_b)
        #self.Bind(wx.EVT_BUTTON, self.addCH4PrimaryANL, self.ch4_primary_a)
        #self.Bind(wx.EVT_BUTTON, self.addCH4PrimaryBNL, self.ch4_primary_b)
        #self.Bind(wx.EVT_BUTTON, self.addCO2NextGenPrimaryANL, self.co2_nextgen_primary_a)
        #self.Bind(wx.EVT_BUTTON, self.addCO2NextGenPrimaryBNL, self.co2_nextgen_primary_b)
        if nl_test:
            self.co2_secondary.Enable(False)
            self.ch4_secondary.Enable(False)
            self.co2_primary_a.Enable(False)
            self.co2_primary_b.Enable(False)
            self.ch4_primary_a.Enable(False)
            self.ch4_primary_b.Enable(False)
            self.co2_nextgen_primary_a.Enable(False)
            self.co2_nextgen_primary_b.Enable(False)
            #self.normal_nl.Enable(False)
            #self.manual_nl.Enable(False)
            #self.dilution_nl.Enable(False)
        else:
            self.co2_secondary.Enable(True)
            self.ch4_secondary.Enable(True)
            self.co2_primary_a.Enable(True)
            self.co2_primary_b.Enable(True)
            self.ch4_primary_a.Enable(True)
            self.ch4_primary_b.Enable(True)
            self.co2_nextgen_primary_a.Enable(True)
            self.co2_nextgen_primary_b.Enable(True)
            #self.normal_nl.Enable(True)
            #self.manual_nl.Enable(True)
            #self.dilution_nl.Enable(True)

        return 


    #--------------------------------------------------------------
    def addCO2SecondaryNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "co2_secondary"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCH4SecondaryNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "ch4_secondary"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCO2PrimaryANL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "co2_primary_a"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCO2PrimaryBNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "co2_primary_b"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCH4PrimaryANL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "ch4_primary_a"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCH4PrimaryBNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "ch4_primary_b"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCO2NextGenPrimaryANL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "co2_nextgen_primary_a"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addCO2NextGenPrimaryBNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "co2_nextgen_primary_b"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()

    #--------------------------------------------------------------
    def addNormalNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "normal_range"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()


    #--------------------------------------------------------------
    def addManualNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "manual"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()


    #--------------------------------------------------------------
    def addDilutionNL(self, evt):
        """ Add entries for normal std set response curve"""
        stdset = "co_dilution"
        self.addNLEntry(stdset)

        #save stdset in sys.setset for use in make_raw
        stdset_file = config.sysdir + "/sys.stdset" 
        f = open (stdset_file, "w")
        f.write("StdSet: %s\n" % stdset)
        f.close()


    #--------------------------------------------------------------
    def addNLEntry(self, stdset):
        """ Add entries for normal std set response curve"""


       # update database with analysis information for the response curve cal
        num_cycles = config.num_response_curve_cycles
        data = getRefTanks(stdset)
        #magiccdb.clear()
        #magiccdb.insert_nl_entries(data, num_cycles)
        self.db.insert_nl_entries(data, num_cycles)
    
        self.updateListBox()

    #--------------------------------------------------------------
    def addRefEntry(self, evt):
        """ add a shot of ref to run. Use to put pre-analysis into run script

        """

        manifold, portnum = get_resource(config.ref_name.lower()).split()
        serial_num = config.ref_name.lower()
        num_aliquots = 1
        pressure = 0
        regulator = "na"
        sample_number = 1 # dummy value, not used for cal entries
        eventnum = 0
        sample_info = (manifold, portnum, serial_num.upper(), "warmup", num_aliquots, pressure, regulator)
        analysis_info = (sample_number, config.ref_name.upper(), eventnum)
        rowid = self.db.insert_entry(sample_info, analysis_info)
        self.updateListBox()

    #--------------------------------------------------------------
    def addJunkEntry(self, evt):
        """ add a shot of ref to run. Use to put pre-analysis into run script

        """

        manifold, portnum = get_resource(config.junk_name.lower()).split()
        serial_num = config.junk_name.lower()
        num_aliquots = 1
        pressure = 0
        regulator = "na"
        sample_number = 1 # dummy value, not used for cal entries
        eventnum = 0
        sample_info = (manifold, portnum, serial_num.upper(), "warmup", num_aliquots, pressure, regulator)
        analysis_info = (sample_number, config.junk_name.upper(), eventnum)
        rowid = self.db.insert_entry(sample_info, analysis_info)
        self.updateListBox()

    #--------------------------------------------------------------
    def addCalEntry(self, evt):
        """ Add a new entry for a tank calibration """


        #if self.manifold != "C":
        #   self.manifold = "C"
        #   self.port = 1
        if not self.manifold:
            #print("sysinfo/addCalEntry  - not self.manifold", file = sys.stderr)
            self.manifold = "A"
            self.port = 1

        # data is manifold, port, serial number, pressure, regulator, num aliquots, request_num
        data = [self.manifold, self.port, "", "", "", 8, ""]
        #dlg = TankEntryDialog(self, -1, "Add Tank Cal Entry", data = data)
        dlg = TankEntryDialog(self, 0, "Add Tank Cal Entry", data = data)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            #print "dlg.data is", dlg.data
            (manifold, port, serial_num, pressure, regulator, num_aliquots, request_num) = dlg.data
            port = int(port)
            pressure = int(pressure)
            num_aliquots = int(num_aliquots)
            eventnum = 0
            sample_number = 1 # dummy value, not used for cal entries
            sample_info = (manifold, port, serial_num, "cal", num_aliquots, pressure, regulator)
            analysis_info = (sample_number, 'W', request_num)
            rowid = self.db.insert_entry(sample_info, analysis_info)

            self.updateListBox()

    #--------------------------------------------------------------
    def pickFromTODO(self, evt):
        """ pick cylinders for calibration from refgas manager ToDo lists """
        tododlg = TodoDialog(self, "Pick From ToDo list")

        tododlg.Show()
        tododlg.Raise()

    #--------------------------------------------------------------
    def add_entry_to_list(self, data):
        """ add cal entry with data from the pickFromTODO dialog screen"""

        (manifold, port, serial_num, pressure, regulator, num_aliquots, request_num) = data

        print("manifold: %s   port: %s    serial_num: %s  pressure: %s    regulator: %s    num_aliquots: %s  request_num: %s" % (manifold, port, serial_num, pressure, regulator, num_aliquots, request_num), file=sys.stderr)
        port = int(port)
        pressure = int(pressure)
        num_aliquots = int(num_aliquots)
        eventnum = 0
        sample_number = 1 # dummy value, not used for cal entries
        sample_info = (manifold, port, serial_num, "cal", num_aliquots, pressure, regulator)
        #print("sample_info: ", sample_info, file=sys.stderr)
        analysis_info = (sample_number, 'W', request_num)
        #print("analysis_info: ", analysis_info, file=sys.stderr)
        rowid = self.db.insert_entry(sample_info, analysis_info)

        self.updateListBox()

    #--------------------------------------------------------------
    def editCalEntry(self, rowid):
        """ Edit an existing tank cal entry """
        ## test 
        #for i in [1, 2, 3, 6, 7, 5]:  # these are the columns numbers with the data we need
        #    item = self.listbox.GetItem(self.currentItem, i)
        #    s = item.GetText()
        #    print("i: %s    val: %s" % (i,s), file=sys.stderr)
    
        # get sample data: manifold, port, serial num, pressure, regulator, num aliquots
        data = []
        for i in [1, 2, 3, 6, 7, 5]:  # these are the columns numbers with the data we need
            item = self.listbox.GetItem(self.currentItem, i)
            s = item.GetText()
            data.append(s)
    
        dlg = TankEntryDialog(self, -1, "Add Tank Cal Entry", data = data)
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            #print "dlg.data is", dlg.data
            (manifold, port, serial_num, pressure, regulator, num_aliquots) = dlg.data
            port = int(port)
            pressure = int(pressure)
            num_aliquots = int(num_aliquots)
            eventnum = 0
            sample_number = 1 # dummy value, not used for cal entries
            sample_info = (manifold, port, serial_num, "cal", num_aliquots, pressure, regulator)
            analysis_info = (sample_number, 'W', eventnum)
            self.db.update_entry(rowid, sample_info, analysis_info)

            self.updateListBox()

    #--------------------------------------------------------------
    def addPfpEntry(self, evt):

        data = [self.manifold, self.port, ""]
        
        dlg = FlaskEntryDialog(self, -1, "Add PFP Package Entry", data = data, routes=self.valid_routes)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            #print "dlg.data is", dlg.data
            for (manifold, port, packageid, pfp_flasks) in dlg.data:
                print(pfp_flasks)
                num_flasks = len(pfp_flasks)
                sample_info = (manifold, port, packageid, "pfp", num_flasks, "", "")
                flask_numbers = [a[0] for a in pfp_flasks]
                flask_ids = [a[1] for a in pfp_flasks]
                event_nums = [a[2] for a in pfp_flasks]
                analysis_info = (flask_numbers, flask_ids, event_nums)
                rowid = self.db.insert_entry(sample_info, analysis_info)

                self.updateListBox()

    #--------------------------------------------------------------
    def editPfpEntry(self, rowid):

        # get sample data: manifold, port, id
        data = []
        for i in [0, 1, 2, 3]:  # these are the columns numbers with the data we need
            item = self.listbox.GetItem(self.currentItem, i)
            s = item.GetText()
            data.append(s)

        dlg = FlaskEntryDialog(self, -1, "Edit PFP Package Entry", data = data, routes=self.valid_routes)

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            for (manifold, port, packageid, pfp_flasks) in dlg.data:
                num_flasks = len(pfp_flasks)
                sample_info = (manifold, port, packageid, "pfp", num_flasks, "", "")
                flask_numbers = [a[0] for a in pfp_flasks]
                flask_ids = [a[1] for a in pfp_flasks]
                event_nums = [a[2] for a in pfp_flasks]
                analysis_info = (flask_numbers, flask_ids, event_nums)
                self.db.update_entry(rowid, sample_info, analysis_info)
                self.updateListBox()


    #--------------------------------------------------------------
    def get_db_rowid_from_index(self, index):
        """ index is the row number in the list box.  
        The database row id number is in the first column of the list box.
        """

        item = self.listbox.GetItem(self.currentItem, 0)
        rowid = int(item.GetText())

        #print "rowid is", rowid
        return rowid


    #--------------------------------------------------------------
    def _set_next_port(self):

        self.port = self.port + 1
        if self.port > 16:
            self.port = 1
            if self.manifold == "A":
                self.manifold = "B"
            if self.manifold == "B":
                self.manifold = "A"
        


    #--------------------------------------------------------------
    def deleteEntry(self, evt):

        rowid = self.get_db_rowid_from_index(self.currentItem)
        msg = "Are you sure you want to delete this entry?"
        dlg = wx.MessageDialog(self, msg, 'Delete Entry?', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
        if dlg.ShowModal() == wx.ID_YES:
            self.db.delete_entry(rowid)
            self.updateListBox()
    
    #--------------------------------------------------------------
    def clearList(self, evt):

        msg = "Are you sure you want to delete all entries?"
        dlg = wx.MessageDialog(self, msg, 'Delete Entry?', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
        if dlg.ShowModal() == wx.ID_YES:
            self.listbox.DeleteAllItems()
            self.db.clear()
        
            self.manifold = 'A'
            self.port = 1

            self.editbutton.Enable(False)
            self.deletebutton.Enable(False)

        self.test_nl()
        self.test_flask_addition()

    #------------------------------------------------
    def _get_routes(self):
        """ get valid route numbers for the magicc system """
       
 
        query = "select num from system where route like '%s'" % config.system_name
        #print(query)

        # connect to mysql database
        db = ccg_dbutils.dbUtils()

        routes = []
        #c.execute(sql)
        #result = c.fetchall()
        result = db.doquery(query)
        #print("type(result): %s" % type(result))
        #print("result:", result)
        if result:
            for line in result:
                num = line["num"]
                routes.append(num)

        #print("type(routes): %s" % type(routes))
        #print("routes: ", routes)
#        db.close()

        return routes

#####################################################################3333
class TransientPopup(wx.PopupTransientWindow):
    """Adds a bit of text and mouse movement to the wx.PopupWindow"""
    def __init__(self, parent, style, data):
        wx.PopupTransientWindow.__init__(self, parent, style)
        self.SetBackgroundColour("#FFfff0")
        txt = str(data)
        st = wx.StaticText(self, -1, txt, pos=(10,10))
        sz = st.GetBestSize()
        self.SetSize( (sz.width+20, sz.height+20) )

