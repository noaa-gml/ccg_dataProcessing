# vim: tabstop=4 shiftwidth=4 expandtab
"""
Dialog class for choosing pfp data to graph in vp modules.
Dialog contains several sections:
    project (surface flask, aircraft flask)
    station list
    package list
    parameters
    options

    dlg = get.GetVpDialog(self)

    where self is the parent of the dialog.

"""
from dataclasses import dataclass, field
from typing import List

import wx

#from common import extchoice
from common import combolist

import ccg_dbutils
import ccg_db_conn


#####################################################################
def getVpList(sitenum, project):
    """ Create a list of pfp's that were used at a site, each
    entry contains the start date and end date of the samples in the pfp.
    """

    dates = []

    db = ccg_db_conn.RO()

    sql = "SELECT date,id "
    sql += "FROM flask_event "
    sql += "WHERE site_num=%d AND project_num=%d AND strategy_num=2 " % (sitenum, project)
    sql += "ORDER BY date, time, id;"
    print(sql)
    samples = db.doquery(sql)


    firstdate = None
    lastdate = None
    tmpid = "9999-99"
    tmppkg = None
    for row in samples:

        pkg, fnum = row['id'].split("-")

        # if the id is less than the previous one (e.g. 3941-12 -> 3941-01),
        # then assume a new set of samples from pfp.  Remember the first date
        # and last date of the previous pfp, and reset the first date
        if pkg != tmppkg or row['id'] <= tmpid:
            if firstdate is not None:
                dates.append((firstdate, lastdate, tmppkg))

            firstdate = row['date']

        lastdate = row['date']
        tmpid = row['id']
        tmppkg = pkg

    dates.append((firstdate, lastdate, tmppkg))

    return sorted(dates)


#####################################################################
def getParameters(sitenum, project, dates, packages):
    """ Get the parameters and programs for the given site,
    project and pfp packages
    """

    db = ccg_db_conn.RO()

    # Find the event number for the site, date, package
    paramlist = []
    programlist = []
    for date, package in zip(dates, packages):
        query = "SELECT num FROM flask_event "
        query += "WHERE site_num=%d AND project_num=%d " % (sitenum, project)
        query += "AND strategy_num=2 "
        if sitenum != 274:
            (date1, s, date2) = date.split()
            query += "AND date between '%s' and '%s' " % (date1, date2)
        else:
            query += "AND date='%s'" % date
        query += "AND substring_index(id,'-',1)='%s';" % (package)
#        print(query)

        plist = db.doquery(query)

        eventnums = [str(t['num']) for t in plist]

        # Find all parameters measured for this event
        query = "SELECT DISTINCT formula,name "
        query += "FROM ccgg.flask_data,gmd.parameter "
        query += "WHERE event_num in (%s)  and parameter_num=gmd.parameter.num;" % (",".join(eventnums))
#        print(query)
        plist = db.doquery(query)

        if plist is None: continue

        for s in plist:
            if s not in paramlist:
                paramlist.append(s)


        # get programs that have analyzed flasks for the programs option box
        query = "SELECT DISTINCT program_num, abbr "
        query += "FROM ccgg.flask_data, gmd.program "
        query += "WHERE event_num in (%s) and program_num=gmd.program.num;" % (",".join(eventnums))
        plist = db.doquery(query)
        for s in plist:
            if s not in programlist:
                programlist.append(s)


    return paramlist, programlist

#####################################################################

@dataclass
class GetVpData:
    """ A class for holding the data requested for pfps """

    project: int = 1
    sitenum: int = 62
    stacode: str = "LEF"
    parameter: int = 1
    paramname: str = "co2"
    package: List = field(default_factory=lambda: [])
    parameter_list: List = field(default_factory=lambda: [])
    datestr: List  = field(default_factory=lambda: [])
    flaggedsymbol: int = 1
    programs: List = field(default_factory=lambda: [])


##########################################################################
class GetVpDialog(wx.Dialog):
    """ A dialog for choosing one or more pfps to plot in the vp program """

    def __init__(self, parent=None, title="Choose Dataset"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)

        self.data = GetVpData()
        self.projects = {"Surface Flasks": 1, "Airborne Flasks":2}
        self.db = ccg_dbutils.dbUtils()

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkProject()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        sizer = self.mkStation()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        sizer = self.mkPackages()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        sizer = self.mkParams()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        sizer = self.mkOptions()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        self.param_config()

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
#        self.Bind(wx.EVT_BUTTON, self.ok, btn)
        btn.Bind(wx.EVT_BUTTON, self.ok)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        self.choice.SetSelection(0)


    #----------------------------------
    def mkProject(self):
        """ Build the project choice section of the dialog """

        # project choice box
        box1 = wx.BoxSizer(wx.HORIZONTAL)

        label = wx.StaticText(self, -1, "Project: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

        # get list of keys sorted by value
        plist = sorted(self.projects, key=self.projects.get)

        self.choice = wx.Choice(self, -1, choices=plist)
        box1.Add(self.choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.projChoice, self.choice)

        return box1

    #----------------------------------
    def projChoice(self, event):
        """ The project choice has changed.  Update the other widgets """

        proj = event.GetString()
        if proj in self.projects:
            self.data.project = self.projects[proj]

#        print "data.project is ", self.data.project

        # remove event callback on the station listbox.
        # Not doing this ends up calling package config twice.
        self.listbox.Unbind(wx.EVT_TEXT)
        self.station_config()
#        print "calling package_config..."
        self.package_config()
#        self.param_config()
        self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)

        event.Skip()


    #----------------------------------
    def mkStation(self):
        """ Build the station list section of the dialog """

        box = wx.StaticBox(self, -1, "Sampling Site")
        szr = wx.StaticBoxSizer(box, wx.VERTICAL)

#        self.listbox = extchoice.ExtendedChoice(self, -1, size=(555, -1))
        self.listbox = combolist.ComboList(self, -1, size=(555, -1))
#        self.listbox = wx.ComboBox(self, -1, size=(555, -1), style=wx.CB_READONLY)
        self.station_config()

        szr.Add(self.listbox, 0, wx.ALIGN_LEFT|wx.ALL, 5)
        self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)
#        self.listbox.Bind(wx.EVT_COMBOBOX_CLOSEUP, self.stationSelected)

        return szr


    #----------------------------------
    def station_config(self):
        """ update site list.
            called on creation and whenever project changes.
        """

        project = self.data.project
        stalist = self.db.getSiteList(project, [2])

#        print("station list is ", stalist)

        # Add the site names to a list.  But don't include
        # the 'binned' sites.  This is a temporary fix until
        # we modify the database tables to distinguish between
        # real and binned sites.
        value = ""
        stations = []
        for row in stalist:
            code = row['code']
            if len(code) > 3:
                if code[3] in ('S', 'N', '0'):
                    continue
            txt = "%s - %s" % (code, row['name'])
            stations.append(txt)
            if code == self.data.stacode:
                value = txt

        if value == "": value = stations[0]

#        self.listbox.ReplaceAll(stations)
        self.listbox.InsertItems(stations)
#        self.listbox.Set(stations)
        self.listbox.SetValue(value)

        code, name = value.split('-', 1)
        code = code.strip()
        self.data.stacode = code
        self.data.sitenum = self.db.getSiteNum(code)


    #----------------------------------
    def stationSelected(self, event):
        """ station selection has changed.
            update package list and parameters
            with values relavent to selected station.
        """

        print("in stationSelected")

        s = self.listbox.GetValue()
        code, name = s.split('-', 1)
        code = code.strip()
        self.data.stacode = code
        self.data.sitenum = self.db.getSiteNum(code)

        self.package_config()
#        self.param_config()

    #----------------------------------
    def mkPackages(self):
        """ create a list with pfp package numbers and dates of sampling """

        box = wx.StaticBox(self, -1, "Packages")
        box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

        text = "Select a package."
        self.label = wx.StaticText(self, -1, text)
        box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

        self.packagebox = wx.ListBox(self, -1, style=wx.LB_MULTIPLE, size=(500, 150))
        box1.Add(self.packagebox, 1, wx.ALIGN_RIGHT|wx.ALL, 5)
        self.Bind(wx.EVT_LISTBOX, self.packageSelected, self.packagebox)

        self.package_config()

        return box1

    #---------------------------------------------------------
    def package_config(self):
        """ Fill the list box with package ids and dates for selected site """

#        print "--- in package_config"

        stacode = self.data.stacode
        sitenum = self.db.getSiteNum(stacode)
        print ("sitenum is", sitenum, stacode)

        project = self.data.project
        date_list = []
        package_list = []
        # surface pfp's are a bit more tricky to find the sample dates.


        # site 274 is TST
        if sitenum == 274:
            db = ccg_db_conn.RO()

            query = "SELECT date,substring_index(id,'-',1) as package FROM flask_event "
            query += "WHERE site_num=%s "
            query += "AND project_num=%s "
            query += "AND strategy_num=2 "
            query += "GROUP BY date "
            query += "ORDER BY date; "
            print(query)

            plist = db.doquery(query, (sitenum, project))
            for row in plist:
                date_list.append("%s to %s" % (row['date'], row['date']))
                package_list.append(row['package'])

        else:

            pfplist = getVpList(sitenum, project)
            for (firstdate, lastdate, pfp) in pfplist:
                date_list.append("%s to %s" % (firstdate, lastdate))
                package_list.append(pfp)

        date_list.reverse()
        package_list.reverse()


        self.Unbind(wx.EVT_LISTBOX, self.packagebox)
        # Add results to list box
        self.packagebox.Clear()
        for date, package in zip(date_list, package_list):
            s = "Package %s: %s" % (package, date)
            self.packagebox.Append(s)

        self.data.package = [package_list[0]]
        self.data.datestr = [date_list[0]]
        self.Bind(wx.EVT_LISTBOX, self.packageSelected, self.packagebox)
        self.packagebox.SetSelection(0)

    #----------------------------------
    def packageSelected(self, event):
        """ package selection has changed.
            update parameters with values relevent to selected package.
        """

#        print "--- in packageSelected"

#        s = self.packagebox.GetStringSelection()
        items = self.packagebox.GetSelections()
        print("selected pacakge items are ", items)
        self.data.package = []
        self.data.datestr = []
        for idx in items:
            s = self.packagebox.GetString(idx)
            if len(s) > 0:
                a, b = s.split(':', 1)
                s, package = a.split()
                self.data.package.append(package.strip())
                self.data.datestr.append(b)

        self.param_config()

#        event.Skip()


    #----------------------------------
    def mkParams(self):
        """ Build the parameters section of the dialog """

        box = wx.StaticBox(self, -1, "Parameters")
        box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

        text = "Select measurement parameters."
        self.label = wx.StaticText(self, -1, text)
        box1.Add(self.label, 0, wx.ALIGN_LEFT|wx.ALL, 5)

        self.parambox = wx.CheckListBox(self, -1, style=wx.LB_SINGLE, size=(500, 150))
        box1.Add(self.parambox, 1, wx.ALIGN_RIGHT|wx.ALL, 5)


        return box1

    #----------------------------------
    def param_config(self):
        """ find parameters that were measured for a given pfp package """

#        print "--- in param_config"

        paramlist, programlist = getParameters(self.data.sitenum, self.data.project, self.data.datestr, self.data.package)
#        print paramlist

        if len(paramlist) == 0:
            self.parambox.Clear()
            return

        self.parambox.Show()

        checkedItems = [i for i in range(self.parambox.GetCount()) if self.parambox.IsChecked(i)]
        checkedparams = []
        for n in checkedItems:
            line = self.parambox.GetString(n)
            s = line.split(' ')
            param = s[0].lower()
            checkedparams.append(param)

        self.parambox.Clear()
#        for (formula, name) in paramlist:
        for row in paramlist:
            s = "%s - %s" % (row['formula'], row['name'])
            self.parambox.Append(s)

        # if param was checked before, check it here again
        for n in range(self.parambox.GetCount()):
            line = self.parambox.GetString(n)
            s = line.split(' ')
            param = s[0].lower()
            if param in checkedparams:
                self.parambox.Check(n)


        # update program checkbox here
        self.p2.Clear()
        for s in programlist:
            self.p2.Append(s['abbr'])

        for i in range(len(programlist)):
            self.p2.Check(i, True)



    #----------------------------------
    def mkOptions(self):
        """ Build the options section of the dialog """

        box = wx.StaticBox(self, -1, "Options")
        box1 = wx.StaticBoxSizer(box, wx.VERTICAL)

        self.f3a = wx.CheckBox(self, -1, "Plot flagged data with different symbol")
        self.f3a.SetValue(1)
        box1.Add(self.f3a, 0, wx.ALIGN_LEFT|wx.ALL, 5)

        txt = wx.StaticText(self, -1, "Program")
        box1.Add(txt, 0, wx.LEFT|wx.TOP, 5)

        self.p2 = wx.CheckListBox(self, -1)
        box1.Add(self.p2, 0, wx.LEFT, 20)

        return box1

    #----------------------------------
    def ok(self, event):
        """
        Get all the values from the dialog and store them in self.data
            project
            stacode
            package
            parameter
        """

        # everything but parameters are already set in the self.data class. Get the parameters
        checkedItems = [i for i in range(self.parambox.GetCount()) if self.parambox.IsChecked(i)]
        if len(checkedItems) == 0:
            dlg = wx.MessageDialog(self,
                "No Parameters selected.  Please choose a parameter.",
                'Error', wx.OK | wx.ICON_ERROR)
            dlg.ShowModal()
            dlg.Destroy()
            return


        self.data.parameter_list = []
        for n in checkedItems:
            line = self.parambox.GetString(n)
            s = line.split(' ')
            param = s[0].lower()
            paramnum = self.db.getGasNum(param)
            self.data.parameter_list.append(paramnum)

        self.data.flaggedsymbol = self.f3a.GetValue()

        # get program numbers for the checked programs
        # must be a list, so if only one program need to convert
        progs = self.p2.GetCheckedStrings()
        nums = self.db.getProgramNum(progs)
        if isinstance(nums, int):
            nums = [nums]
        self.data.programs = nums

        self.EndModal(wx.ID_OK)
