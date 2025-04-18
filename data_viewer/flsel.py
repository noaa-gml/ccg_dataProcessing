
# vim: tabstop=4 shiftwidth=4 expandtab
""" Automatic selection of flask data """

import os
import datetime

import wx
import numpy

from graph5.graph import Graph
from graph5.toolbars import ZoomToolBar

from ccg_quickfilter import quickFilter
from ccg_filter_params import filterParameters
import ccg_ncdf
from ccg_flask_data import FlaskData

import ccg_utils

from common.get import GetDataDialog
from .getncdf import ImportDialog
from common.params import ParametersDialog


######################################################################
class Flsel(wx.Frame):
    """ A window for automatic flagging of flask data based on
    outliers from a smooth curve.
    """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(850, 750))

        self.importdlg = None
        self.paramsdlg = None
        self.getdlg = None
        self.parameters = filterParameters()
        self.name = ""   # name of netcdf file
        self.min_ht = None
        self.max_ht = None
        self.min_hr = None
        self.max_hr = None
        self.inputType = 'database'
        self.data = None
        self.elev = None
        self.utc2lst = None
        self.config = None  # params for getting data from database

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()
        self.SetStatusText("")

        # Notebook for holding graphs for the various curves
        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        self.plot = Graph(self.nb, -1)
        self.nb.AddPage(self.plot, "Graph")
        self.current_plot = self.plot

        self.tc = wx.TextCtrl(self.nb, -1, "", style=wx.TE_READONLY | wx.TE_MULTILINE)
        font = wx.Font(12, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        self.tc.SetFont(font)
        self.nb.AddPage(self.tc, "Results")

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self, self.current_plot)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)
        self.sizer.Add(self.nb, 1, wx.EXPAND | wx.ALL, 5)

        self.zoomtb.SetGraph(self.plot)

        self.update_menus(enable=False)

        self.CenterOnScreen()
        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.Show(True)

    # ----------------------------------------------
    def MakeMenuBar(self):
        """ Make the main menu bar for the window """

        self.menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        self.menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(102, "Get Data...")
        self.file_menu.Append(106, "Import NetCDF File...")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(107, "Export...")
        self.file_menu.Append(108, "Save Changes...")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(110, "Print Preview...")
        self.file_menu.Append(-1, "Print")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Close", "Close the window")

        self.Bind(wx.EVT_MENU, self.getdata, id=102)
        self.Bind(wx.EVT_MENU, self.importdata, id=106)
        self.Bind(wx.EVT_MENU, self.exportdata, id=107)
        self.Bind(wx.EVT_MENU, self.saveChanges, id=108)
        self.Bind(wx.EVT_MENU, self.print_preview, id=110)
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)

        # ---------------------------------------
        self.edit_menu = wx.Menu()
        self.menuBar.Append(self.edit_menu, "Edit")

        self.edit_menu.Append(200, "Parameters")

        self.Bind(wx.EVT_MENU, self.get_parameters, id=200)

        # ---------------------------------------
        menu = wx.Menu()
        self.menuBar.Append(menu, "View")

        toolbarmenu = wx.Menu()
        m = toolbarmenu.Append(1111, "Zoom Toolbar", "", wx.ITEM_CHECK)
        m.Check()
        menu.Append(300, "Toolbars", toolbarmenu)
        self.Bind(wx.EVT_MENU, self.toggleZoomToolBar, id=300)

        self.SetMenuBar(self.menuBar)

    # ----------------------------------------------
    def update_menus(self, enable=False):
        """ Update the setting of the menu items

        Called after flask selection is done.
        Enable export, save and parameter menu items
        """

        if enable is False:
            self.file_menu.Enable(107, False)
            self.file_menu.Enable(108, False)
            self.edit_menu.Enable(200, False)
        else:
            self.file_menu.Enable(107, True)
            self.file_menu.Enable(108, True)
            self.edit_menu.Enable(200, True)

    # ----------------------------------------------
    def toggleZoomToolBar(self, evt):
        """ Show/Hide the zoom toolbar """

        if evt.IsChecked():
            self.sizer.Show(self.zoomtb)
        else:
            self.sizer.Hide(self.zoomtb)
        self.sizer.Layout()

    # ----------------------------------------------
    def importdata(self, e):
        """ Find and read netcdf file """

        if self.importdlg is None:
            self.importdlg = ImportDialog(self)
            self.importdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.importdlg.ShowModal()

        if val == wx.ID_OK:
            self.name = self.importdlg.filename
            self.min_ht = self.importdlg.min_ht
            self.max_ht = self.importdlg.max_ht
            self.min_hr = self.importdlg.min_hr
            self.max_hr = self.importdlg.max_hr
            self.inputType = "import"

            self.data = ccg_ncdf.read_ncdf(self.name, datename='date')
            print(self.data.keys())
            self.data['flagged'] = numpy.zeros(len(self.data['qcflag']), dtype=int)

            self.elev = self.data['site_elevation']
            self.utc2lst = self.data['site_utc2lst']

            self.resetNCData()
#            self.processNCData()
            self._process_data()

        self.importdlg.Hide()

    # ----------------------------------------------
    def resetNCData(self):
        """ Remove any auto generated flags from the data,
        and flag data that doesn't fit into intake height range
        and hour of day range.

        """

        print(self.data['qcflag'])

        for i, flag in enumerate(self.data['qcflag']):
            if flag[0] != '.':
                self.data['flagged'][i] = -1  # bad flag
                continue

            if flag[1] in ["S", "U"]:
                flag = flag[0] + '.' + flag[2]
                self.data['qcflag'][i] = flag

            if flag[1] == '.':

                self.data['flagged'][i] = 0  # no flag

                # Flag all data outside of intake height range with second character 'U'
                # Also set nf number to 2 to identify it
                if self.min_ht is not None and self.max_ht is not None:
                    if (self.data['intake_height'][i] < self.min_ht
                    or self.data['intake_height'] > self.max_ht):
                        flag = flag[0] + 'U' + flag[2]
                        self.data['qcflag'][i] = flag
                        self.data['flagged'][i] = 2  # ouside range

                if self.min_hr is not None and self.max_hr is not None:
                    if self.data['date'].hour < self.min_hr or self.data['date'].hour > self.max_hr:
                        flag = flag[0] + 'U' + flag[2]
                        self.data['qcflag'][i] = flag
                        self.data['flagged'][i] = 2  # outside range

            else:
                self.data['flagged'][i] = 3  # already flagged

    # ----------------------------------------------
    def resetData(self):
        """ Set 'flagged' array to correct value for flag.

        This is for data from database
        """

#        print(self.data['qcflag'].tolist())

        for i, flag in enumerate(self.data['qcflag']):
            if flag[0] != '.':
                self.data['flagged'][i] = -1  # bad flag

            elif flag[1] == '.':

                self.data['flagged'][i] = 0  # no flag

            else:
                self.data['flagged'][i] = 3  # already flagged

    # ----------------------------------------------
    def getdata(self, evt):
        """ get and process flask data from database

        A dialog for choosing the flask data from database
        is shown, then based on the settings from the dialog,
        the data is obtained from the database.
        """

        if self.getdlg is None:
            self.getdlg = GetDataDialog(self, flaskOnly=True)
            self.getdlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = self.getdlg.ShowModal()

        if val == wx.ID_OK:
            self.config = self.getdlg.data
            self.inputType = "database"
            self.data = self.getDbData()
            self.resetData()

            self._process_data()

        self.getdlg.Hide()

    # ----------------------------------------------------
    def _process_data(self):
        """ do the curve filtering """

        qf = quickFilter(self.data['time_decimal'],  self.data['value'], self.data['flagged'])
        qf.params = self.parameters
        qf.run()

        self.tc.ChangeValue(qf.summaryText)
        self.data['flagged'] = qf.flags
        self._plot_data(self.data, qf.filt)
        self.update_menus(enable=True)

    # ----------------------------------------------------
    def getDbData(self):
        """ Get the data from the database for the parameter specified by the
            index in the param_list array.  Ignore hard flagged data,
        keep other data with corresponding flag and event number.
        """

        t1 = datetime.datetime(self.config.byear, 1, 1)
        t2 = datetime.datetime(self.config.eyear+1, 1, 1)

        f = FlaskData(self.config.parameter, self.config.sitenum)
        f.setRange(start=t1, end=t2)
        f.setProject(self.config.project)
        f.setStrategy(self.config.use_flask, self.config.use_pfp)
        f.setPrograms(self.config.programs)
        f.includeFlaggedData()
#        f.includeHardFlags()
        if self.config.bin_data:
            f.setBin(self.config.bin_method, self.config.min_bin, self.config.max_bin)

#        f.showQuery()
        f.run(as_arrays=True)
        f.results['flagged'] = numpy.zeros(len(f.results['qcflag']), dtype=int)

        return f.results

    # ----------------------------------------------
    def get_parameters(self, evt):
        """ Show dialog for editing the filter parameters

        The processData routine is called from the dialog
            so we don't need to do that here.
        """

        if self.paramsdlg is None:
            self.paramsdlg = ParametersDialog(self, self.parameters)
            self.paramsdlg.CenterOnScreen()

        print(self.parameters)
        val = self.paramsdlg.ShowModal()
        if val == wx.ID_OK:
            self.parameters = self.paramsdlg.parameters
            print(self.parameters)
            # Recalulate the curves
            if self.inputType == "database":
                self.resetData()
            else:
                self.resetNCData()

            self._process_data()

    # ----------------------------------------------
    def _plot_data(self, data, filt):
        """ plot the data, using different symbols for each flag type """

        self.plot.clear()

        sigma = filt.rsd2

        sigma3plus = self.parameters.sigmaplus * sigma
        sigma3minus = self.parameters.sigmaminus * sigma * -1

        # calculate +/- 3 sigma curves
        xdata = filt.xinterp
        ydata = filt.getSmoothValue(xdata)
        y1plus3 = ydata + sigma3plus
        y1minus3 = ydata + sigma3minus

        # rejected data
        w = numpy.where(self.data['flagged'] == -1)
        xb = self.data['time_decimal'][w]
        yb = self.data['value'][w]

        # non flagged data
        w = numpy.where(self.data['flagged'] == 0)
        x = self.data['time_decimal'][w]
        y = self.data['value'][w]

        # auto flagged data
        w = numpy.where(self.data['flagged'] == 1)
        xnf = self.data['time_decimal'][w]
        ynf = self.data['value'][w]

        # out of range data
        w = numpy.where(self.data['flagged'] == 2)
        xnf2 = self.data['time_decimal'][w]
        ynf2 = self.data['value'][w]

        # already flagged data
        w = numpy.where(self.data['flagged'] == 3)
        xf = self.data['time_decimal'][w]
        yf = self.data['value'][w]

        self.plot.createDataset(xdata, ydata, name='Smooth Curve', linecolor=(0, 200, 0), symbol='none')
        self.plot.createDataset(xdata, y1plus3, name='+ %.1f sigma' % self.parameters.sigmaplus, linecolor=(0, 200, 200), symbol='none')
        self.plot.createDataset(xdata, y1minus3, name='- %.1f sigma' % self.parameters.sigmaminus, linecolor=(0, 200, 200), symbol='none')
        self.plot.createDataset(x, y, name='Data', symbol='circle', color=(0, 102, 255), connector='none')
        self.plot.createDataset(xf, yf, name='Flagged Data', symbol='circle', color='red', connector='none')
        self.plot.createDataset(xnf, ynf, name='New Flagged Data', symbol='square', color='yellow', connector='none')
        self.plot.createDataset(xnf2, ynf2, name='Unselected Data', symbol='square', color='magenta', connector='none')
        self.plot.createDataset(xb, yb, name='Rejected Data', symbol='square', color='green', connector='none')

        self.plot.title.text = self._get_title()

        self.plot.update()

    # ----------------------------------------------
    def _get_title(self):
        """ Get title for the plot """

        if self.inputType == "database":
            gas = self.config.paramname
            title = self.config.stacode + " " + gas.upper()
            if self.config.bin_data:
                title += " %g - %g %s" % (self.config.min_bin, self.config.max_bin, self.config.bin_method)
        else:
            title = os.path.basename(self.name) + "\nElev: %s Utc2lst: %s" % (self.elev, self.utc2lst)

        return title

    # ----------------------------------------------
    def exportdata(self, e):
        """ write the date, value and flag to a text file """

        dlg = wx.FileDialog(
            self, message="Choose a file", defaultDir=os.getcwd(),
            defaultFile="", style=wx.FD_SAVE | wx.FD_CHANGE_DIR | wx.FD_OVERWRITE_PROMPT
        )
        if dlg.ShowModal() == wx.ID_OK:
            paths = dlg.GetPaths()
            for path in paths:
                outputfile = path

            f = open(outputfile, "w")
            for i in range(len(self.data['value'])):
                f.write("%16.9e %16.9e %3s\n" % (self.data['time_decimal'][i], self.data['value'], self.data['qcflag']))
            f.close()

        dlg.Destroy()

    # ----------------------------------------------
    def saveChanges(self, e):
        """ save the flag changes.

        Update either the database or a netcdf file, depending on the source
        """

        if self.inputType == "database":

            msg = "This will update tags in the database! Are you sure you want to continue?"
            dlg = wx.MessageDialog(self, msg, 'Update Flags', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING)
            answer = dlg.ShowModal()
            if answer == wx.ID_YES:
                w = numpy.where(self.data['flagged'] == 1)
                for i in w[0]:
                    ccg_utils.addTagNumberToDatanum(2, self.data['data_number'][i], mode=2, verbose=False, update=True)

#                    flag = self.data['qcflag'][i]
#                    newflag = flag[0] + 'X' + flag[2]
#                    self.data['qcflag'][i] = newflag
#                    print(i, self.data['flagged'][i], self.data['data_number'][i], self.data['qcflag'][i])

        else:
            msg = "This will update flags in the netCDF file! Are you sure you want to continue?"
            dlg = wx.MessageDialog(self, msg, 'Update Flags', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING)
            answer = dlg.ShowModal()
            if answer == wx.ID_YES:
                for i in w[0]:
                    flag = self.data['qcflag'][i]
                    newflag = flag[0] + 'S' + flag[2]
                    self.data['qcflag'][i] = newflag
                ccg_ncdf.update_ncdf_var(self.name, "qcflag", self.data['qcflag'])

        dlg.Destroy()

    # ----------------------------------------------
    def OnExit(self, e):
        """ exit the app and close the window """

        self.Close(True)

    # ----------------------------------------------
    def print_preview(self, event):
        """ show the print preview dialog window """

        self.plot.printPreview()
