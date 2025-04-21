
import os
import wx
import glob
from datetime import datetime

import panel_config as config


#--------------------------------------------------------------
class mkLogPage(wx.Panel):
    def __init__(self, parent, gas ):
        wx.Panel.__init__(self, parent, -1)

        self.gas = gas
        self.logdir = "%s/logs" % (config.sysdir)
        if not os.path.exists(self.logdir):
            os.makedirs(self.logdir)

        self.currentItem = -1

        box = wx.StaticBox(self, -1, "Operator Log", size=(10,10))
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.listbox = self.makeListBox(self)
        sizer.Add(self.listbox, 0, wx.EXPAND, 0)

        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        sizer.Add(line, 0, wx.EXPAND, 0)

        self.tc2 = wx.TextCtrl(self, -1, "", style=wx.TE_READONLY|wx.TE_MULTILINE|wx.TE_WORDWRAP)
        sizer.Add(self.tc2, 10, wx.EXPAND|wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        #sizer.Add(line, 0, wx.GROW|wx.ALIGN_CENTER_VERTICAL|wx.RIGHT|wx.TOP, 5)
        sizer.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        box3 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box3, 0, wx.EXPAND, 0)

        self.addbtn = wx.Button(self, wx.ID_ADD)
        self.Bind(wx.EVT_BUTTON, self.add, self.addbtn)
        #box3.Add(self.addbtn, 0, wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 10)
        box3.Add(self.addbtn, 0, wx.RIGHT, 10)

        self.editbtn = wx.Button(self, wx.ID_EDIT)
        self.Bind(wx.EVT_BUTTON, self.add, self.editbtn)
        self.editbtn.SetDefault()
        #box3.Add(self.editbtn, 0, wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 10)
        box3.Add(self.editbtn, 0, wx.RIGHT, 10)
        self.editbtn.Enable(False)

        self.delbtn = wx.Button(self, wx.ID_DELETE)
        self.Bind(wx.EVT_BUTTON, self.delete, self.delbtn)
        #box3.Add(self.delbtn, 0, wx.ALIGN_CENTER_VERTICAL|wx.RIGHT, 10)
        box3.Add(self.delbtn, 0, wx.RIGHT, 10)
        self.delbtn.Enable(False)

        self.load_logs()

        self.SetSizer(sizer)

    #----------------------------------------------
    def makeListBox(self, page):

        listbox = wx.ListCtrl(page, -1, style=wx.LB_SINGLE|wx.LC_VRULES|wx.LC_HRULES, size=(-1, 250))

        listbox.InsertColumn(0, "Date", width=250)
        listbox.InsertColumn(1, "Subject", width=150)
        listbox.InsertColumn(2, "Text", width=330)

        self.Bind(wx.EVT_LIST_ITEM_SELECTED, self.OnItemSelected, listbox)
    #    self.Bind(wx.EVT_LIST_ITEM_RIGHT_CLICK, self.ItemRightClick, listbox)

        return listbox

    #----------------------------------------------
    def OnItemSelected(self, event):
        """ Get the selected item """

        self.currentItem = event.m_itemIndex

        (date, subject, text) = self.getEntry(self.currentItem)
        self.tc2.SetValue(text)

        self.editbtn.Enable(True)
        self.delbtn.Enable(True)

    #----------------------------------------------
    def getEntry(self, index):
        """ Get the text strings from each column for the
            selected item.
        """

        s = self.listbox.GetItem(index, 0)
        date = s.GetText()
        s = self.listbox.GetItem(index, 1)
        subject = s.GetText()
        s = self.listbox.GetItem(index, 2)
        text = s.GetText()

        return (date, subject, text)


    #----------------------------------------------
    def load_logs(self):
        """ Read log entries from files and insert them into list """

        loglist = "%s/*.log" % (self.logdir)

        self.filelist = glob.glob(loglist)
        self.filelist.sort()

        nr = 0
        for file in self.filelist:
            header = 1
            text = []
            f = open(file)
            for line in f:
                if "Date" in line:
                    date = line[line.find("Date:")+6:]
                    date = date.strip()
                    date = date.strip("\n")
                if "Subject" in line:
                    subject = line[line.find("Subject:")+8:]
                    subject = subject.strip()
                    subject = subject.strip("\n")
                if line[0:3] == "===":
                    header = 0
                    continue

                if not header:
                    text.append(line)


            index = self.listbox.InsertStringItem(nr, date)
            self.listbox.SetStringItem(index, 1, subject)
            self.listbox.SetStringItem(index, 2, ''.join(text))

            if nr % 2 == 0:
                self.listbox.SetItemBackgroundColour(index, wx.Colour(230, 230, 230))

            nr += 1


    #----------------------------------------------
    def add(self, event):
        """ Add a new entry or edit an existing one
            by popping up a dialog to enter the subject and text
        """


        mode = event.GetId()
        if mode == wx.ID_ADD:
            data = ("", "")
        if mode == wx.ID_EDIT:
            if self.currentItem < 0:
                return
            (date, subject, text) = self.getEntry(self.currentItem)
            data = (subject, text)

        dlg = LogEntryDialog(self, -1, "Add/Edit Log Entry", data=data, mode=mode, style=wx.DEFAULT_DIALOG_STYLE)
        val = dlg.ShowModal()
        if val == wx.ID_OK:
            (subject, text) = dlg.data

            if mode == wx.ID_ADD:
                now = datetime.now()

                n = 1
                file = "%s/%d-%02d-%02d.%d.log" % (self.logdir, now.year, now.month, now.day, n)
                while os.path.exists(file):

                    n += 1
                    file = "%s/%d-%02d-%02d.%d.log" % (self.logdir, now.year, now.month, now.day, n)

                date = now.strftime("%c")

                if self.saveEntry(file, date, subject, text):
                    self.filelist.append(file)

                    nitems = self.listbox.GetItemCount()
                    index = self.listbox.InsertStringItem(nitems, date)
                    self.listbox.SetStringItem(index, 1, subject)
                    self.listbox.SetStringItem(index, 2, text)
                    if index % 2 == 0:
                        self.listbox.SetItemBackgroundColour(index, wx.Colour(230, 230, 230))
                    s = self.listbox.GetItem(index, 0)
                    self.listbox.EnsureVisible(index)


            if mode == wx.ID_EDIT:

                file = self.filelist[self.currentItem]

                if self.saveEntry(file, date, subject, text):
                    self.listbox.SetStringItem(self.currentItem, 1, subject)
                    self.listbox.SetStringItem(self.currentItem, 2, text)


    #----------------------------------------------
    def saveEntry(self, file, date, subject, text):
        """ save a log entry to file """



        try:
            f = open(file, "w")
        except:
            s = "Error opening file %s" % file
            dlg = wx.MessageDialog(self, s, 'Error Message', style=wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return False

        print("Date: ", date, file=f)
        print("Subject: ", subject, file=f)
        print("===============================================", file=f)
        print(text, file=f)

        f.close()

        config.main_frame.updateStatus("Saved Log Entry to %s" % file)
        return True

    #----------------------------------------------
    def delete(self, event):

        msg = "Are you sure you want to delete this entry?"
        dlg = wx.MessageDialog(self, msg, 'Delete Entry?', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_QUESTION)
        if dlg.ShowModal() == wx.ID_YES:
            file = self.filelist[self.currentItem]
            os.remove(file)

            self.listbox.DeleteItem(self.currentItem)



#####################################################################3333
class LogEntryDialog(wx.Dialog):
    def __init__(
            self, parent, ID, title, data=("", ""), mode=wx.ID_EDIT, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER
            ):

        wx.Dialog.__init__(self, parent, -1, title)

        self.logdir = parent.logdir
        print("mode is ", mode)

        # Main sizer for dialog
        sizer = wx.BoxSizer(wx.VERTICAL)

        box2 = wx.BoxSizer(wx.HORIZONTAL)
        sizer.Add(box2, 0, wx.EXPAND, 0)
        title = wx.StaticText(self, -1, "Subject: ")
        box2.Add(title, 0, wx.ALIGN_LEFT|wx.TOP, 10)


        self.tc = wx.TextCtrl(self, -1, "")
        box2.Add(self.tc, 1, wx.EXPAND|wx.ALL, 5)
        if mode == wx.ID_EDIT:
            self.tc.SetValue(data[0])

        self.tc2 = wx.TextCtrl(self, -1, "", style=wx.TE_MULTILINE|wx.TE_WORDWRAP, size=(500,200))
        sizer.Add(self.tc2, 10, wx.EXPAND|wx.ALL, 5)
        if mode == wx.ID_EDIT:
            self.tc2.SetValue(data[1])


        #------------------------------------------------
        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        sizer.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)

        #------------------------------------------------
        # Dialog buttons
        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btnsizer.AddButton(btn)
#           btn = wx.Button(self, wx.ID_APPLY)
#           self.Bind(wx.EVT_BUTTON, self.apply, btn)
#           btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)

        btnsizer.Realize()

        sizer.Add(btnsizer, 0, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(sizer)
        sizer.SetSizeHints(self)
        sizer.Fit(self)


    #---------------------------------------------------------------
    def ok(self, event):

        subject = self.tc.GetValue()
        text = self.tc2.GetValue()
        self.data = (subject, text)

        self.EndModal(wx.ID_OK)
