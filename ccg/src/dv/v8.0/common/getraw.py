# vim: tabstop=4 shiftwidth=4 expandtab
"""
Dialog for selecting a single raw file for any of the projects: nl, cals, flask
"""

import os
from collections import namedtuple
import glob

import wx

from common.utils import get_path


##########################################################################
class GetRawDialog(wx.Dialog):
    """ Dialog for selecting calibration raw files """

    def __init__(self, parent, project, title="Get Raw File"):
        wx.Dialog.__init__(self, parent, -1, title)

        RawData = namedtuple('rawdata', ['project', 'parameter', 'sys', 'inst', 'method', 'year', 'files'])
        self.data = RawData(project=project, parameter='co2', sys='', inst='', method='', year=0, files='')

        if project == "cals":
            plist = ["Calibrations"]
        elif project == "flask":
            plist = ["Flasks"]
        elif project == "nl":
            plist = ["Nl", "In-Situ"]

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        # make the main part of dialog
        self.mkSource(box0, plist)

        # add the ok and cancel buttons
        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        # now set the defaults
        self.setParam()

    # ----------------------------------
    def mkSource(self, box0, plist):
        """ make main part of dialog.  This includes
        a choice boxes for project, species, system, year and files
        """

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        box0.Add(box1, 0, wx.GROW | wx.ALL, 0)

        # project choice box
        label = wx.StaticText(self, -1, "Project: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.proj = wx.Choice(self, -1, choices=plist)
        self.proj.SetSelection(0)
        box1.Add(self.proj, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selProj, self.proj)

        # ----------------------------------
        # species choice box
        label = wx.StaticText(self, -1, "Species: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.param = wx.Choice(self, -1, choices=[])
        self.param.SetSelection(0)
        box1.Add(self.param, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selParam, self.param)

        # ----------------------------------
        # system choice box
        label = wx.StaticText(self, -1, "System: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.system = wx.Choice(self, -1, choices=[])
        box1.Add(self.system, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selSystem, self.system)

        # ----------------------------------
        # year choice box
        label = wx.StaticText(self, -1, "Year: ")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.year = wx.Choice(self, -1, choices=[])
        box1.Add(self.year, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.Bind(wx.EVT_CHOICE, self.selYear, self.year)

        # ----------------------------------
        # raw file list box
        box1 = wx.BoxSizer(wx.VERTICAL)
        box0.Add(box1, 0, wx.ALL, 0)

        label = wx.StaticText(self, -1, "Select a Raw File:")
        box1.Add(label, 0, wx.ALIGN_LEFT | wx.BOTTOM, 10)

        self.listbox = wx.ListBox(self, -1, style=wx.LB_SINGLE, size=(250, 250))
        self.Bind(wx.EVT_LISTBOX, self.selFile, self.listbox)

        box1.Add(self.listbox, 1, wx.EXPAND, 0)

    # ----------------------------------
    def selProj(self, event):
        """ project choice has changed """

        proj = event.GetString()
        if proj == "Calibrations":
            self.data = self.data._replace(project="cals")
        elif proj == "Flasks":
            self.data = self.data._replace(project="flask")
        elif proj == "Nl":
            self.data = self.data._replace(project="nl")
        elif proj == "In-Situ":
            self.data = self.data._replace(project="in-situ")

        self.setParam()

    # ----------------------------------
    def selParam(self, event):
        """ Species choice has changed. reset system list """

        self.data = self.data._replace(parameter=event.GetString())
        self.setSystem()

    # ----------------------------------
    def selSystem(self, event):
        """ system choice has changed """

        self.data = self.data._replace(sys=event.GetString())
        self.setYears()

    # ----------------------------------
    def selYear(self, event):
        """ year choice has changed """

        self.data = self.data._replace(year=event.GetString())
        self.setFiles()

    # ----------------------------------
    def selFile(self, event):
        """ file choice has changed """

        rawdir = self._get_raw_dir(self.data.parameter, self.data.project, self.data.sys)
        s = event.GetString()
        self.data = self.data._replace(files=["%s/%s/%s" % (rawdir, self.data.year, s)])

    # ----------------------------------
    def setParam(self):
        """ set choice of available parameters for given project """

        if self.data.project == "cals":
            clist = ["CO2", "CH4", "CO", "H2", "N2O", "SF6", "CO2C13", "CO2O18"]
        elif self.data.project == "flask":
            clist = ["CO2", "CH4", "CO", "H2", "N2O", "SF6"]
        elif self.data.project == "nl":
            clist = ["CO2", "CH4", "CO", "H2", "N2O", "SF6"]
        elif self.data.project == "in-situ":
            clist = ["CO2", "CH4", "CO", "N2O"]

        self.param.Clear()

        for s in clist:
            self.param.Append(s)
        self.data = self.data._replace(parameter=clist[0])

        self.param.SetSelection(0)

        self.setSystem()

    # ----------------------------------
    def setSystem(self):
        """ Set system choice box for given project and species. """

        systems = {}
        systems["cals"] = {
            "CO2": ["co2cal-2", "co2cal-1", "magicc-3", "magicc-1", "magicc-2"],
            "CH4": ["co2cal-2", "ch4cal-1", "magicc-3", "magicc-1", "magicc-2", "carle-cal", "carle"],
            "CO": ["cocal-1", "rgd2", "magicc-3", "magicc-1", "magicc-2", "carle"],
            "H2": ["cocal-1", "rgd2", "magicc-3", "magicc-1", "magicc-2"],
            "N2O": ["cocal-1", "magicc-3", "magicc-1", "magicc-2"],
            "SF6": ["magicc-3", "magicc-1", "magicc-2"],
            "CO2C13": ["co2cal-2"],
            "CO2O18": ["co2cal-2"],
        }
        systems["flask"] = {
            "CO2": ["magicc-3", "magicc-1", "magicc-2", "siemens", "afas", "safa", "lira"],
            "CH4": ["magicc-3", "magicc-1", "magicc-2", "carle", "afas"],
            "CO": ["magicc-3", "magicc-1", "magicc-2", "carle", "afas", "rgd2"],
            "H2": ["magicc-3", "magicc-1", "magicc-2", "carle", "rgd2"],
            "N2O": ["magicc-3", "magicc-1", "magicc-2"],
            "SF6": ["magicc-3", "magicc-1", "magicc-2"],
        }
        systems["nl"] = {
            "CO2": ["magicc-3", "co2cal-2"],
            "CH4": ["magicc-3", "co2cal-2", "ch4cal-1"],
            "CO": ["magicc-3", "magicc-1", "magicc-2", "cocal-1", "carle", "rgd2"],
            "H2": ["magicc-3", "cocal-1"],
            "N2O": ["magicc-3", "magicc-1", "magicc-2", "cocal-1"],
            "SF6": ["magicc-3", "magicc-1", "magicc-2"],
        }
        systems["in-situ"] = {
            "CO2": ["BRW", "MLO", "SMO", "SPO"],
            "CH4": ["BRW", "MLO"],
            "CO": ["BRW", "MLO"],
            "N2O": ["BRW"],
        }

        self.system.Clear()

        for s in systems[self.data.project][self.data.parameter.upper()]:
            self.system.Append(s)
        self.data = self.data._replace(sys=systems[self.data.project][self.data.parameter.upper()][0])

        self.system.SetSelection(0)

        self.setYears()

    # ----------------------------------
    def setYears(self):
        """ set choice of available years for given project, species and system """

        rawdir = self._get_raw_dir(self.data.parameter, self.data.project, self.data.sys)

        path = "%s/[1|2][0-9][0-9][0-9]" % rawdir
        filelist = sorted(glob.glob(path))

        self.year.Clear()
        for s in filelist:
            yr = os.path.basename(s)
            self.year.Append(yr)

        self.year.SetSelection(len(filelist)-1)

        self.data = self.data._replace(year=os.path.basename(filelist[-1]))

        self.setFiles()

    # ----------------------------------
    def setFiles(self):
        """ set available files for given project, species, system and year """

        rawdir = self._get_raw_dir(self.data.parameter, self.data.project, self.data.sys)
        path = "%s/%s/*.%s" % (rawdir, self.data.year, self.data.parameter.lower())
        filelist = sorted(glob.glob(path))

        files = [os.path.basename(s) for s in filelist]

        self.listbox.Set(files)
        self.listbox.SetSelection(0)

        self.data = self.data._replace(files=[filelist[0]])

    # ----------------------------------
    def ok(self, event):
        """ end dialog. requested data is in self.data """

        self.EndModal(wx.ID_OK)

    # ----------------------------------
    def _get_raw_dir(self, parameter, project, system):
        """ get the complete directory path to the raw directory """

        if project.lower() == "in-situ":
            fmt = "/ccg/%s/%s/%s/%s/nl"
            if system.lower() == "brw":
                sysname = "lgr"
            else:
                sysname = "pic"

            rawdir = fmt % (parameter.lower(),
                            project,
                            system.lower(),
                            sysname)
        else:
            fmt = "/ccg/%s/%s/%s/raw/"
            rawdir = fmt % (parameter.lower(),
                            project,
                            system.lower())

        rawdir = get_path(rawdir)

        return rawdir
