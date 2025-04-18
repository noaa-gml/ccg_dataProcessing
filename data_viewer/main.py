# vim: tabstop=4 shiftwidth=4 expandtab
""" Class for user interface for plotting and integrating chromatograms """

import sys
import os
import wx

from graph5.graph import Graph
from graph5.toolbars import ZoomToolBar

#from extract import ExtractDialog
from common.FileView import FileView
from common.TextView import TextView

from .open import OpenDialog
from .data import getData, getPeakData
from .setfiles import SetFilesDialog

######################################################################
class GCPlot(wx.Frame):
    """ Class for user interface for plotting and integrating chromatograms """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(700, 550))

        self.extractdlg = None
        self.filesdlg = None
        self.integration_file = None
        self.peakid_file = None
        self.data_directory = None
        self.show_brief_peakinfo = 1
        self.input_file = None
        self.archive = None

        rdir = os.path.realpath(sys.argv[0])
#        print "rdir is", rdir
        self.install_dir = os.path.split(rdir)[0]
#        print "install_dir is", self.install_dir


        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        # Make the menu bar
        self.MakeMenuBar()

        # and status bar
        self.CreateStatusBar()
        self.SetStatusText("")


        # Notebook for holding graphs
        self.nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)

        self.plot = Graph(self.nb, -1)
        self.nb.AddPage(self.plot, "Chromatogram")
        self.current_plot = self.plot

        self.plot2 = Graph(self.nb, -1)
        self.nb.AddPage(self.plot2, "Slope")

        self.nb.Bind(wx.EVT_NOTEBOOK_PAGE_CHANGED, self.OnPageChanged)

        # Make the zoom toolbar, add to main sizer
        self.zoomtb = ZoomToolBar(self)
        self.zoomtb.SetGraph(self.plot)
        self.sizer.Add(self.zoomtb, 0, wx.EXPAND)
        self.sizer.Add(self.nb, 1, wx.EXPAND|wx.ALL, 5)


        self.update_menus(0)

        self.SetSizer(self.sizer)
        self.SetAutoLayout(True)
        self.CenterOnScreen()
        self.Show(True)

    #----------------------------------------------
    def OnPageChanged(self, event):
        """ Tab has been selected, set correct graph for toolbar """

        page = self.nb.GetCurrentPage()
        self.current_plot = page
        # Attach plot to zoom toolbar
        self.zoomtb.SetGraph(page)
        event.Skip()


    #----------------------------------------------
    def MakeMenuBar(self):
        """ Build the menu bar """

        menuBar = wx.MenuBar()

        self.file_menu = wx.Menu()
        menuBar.Append(self.file_menu, "&File")

        self.file_menu.Append(100, "New", "Remove datasets and start fresh")
        self.file_menu.AppendSeparator()

        self.file_menu.Append(102, "Open...", "Open an archive and choose a file")
        self.file_menu.AppendSeparator()
        self.file_menu.Append(110, "Print Preview...")
        self.file_menu.Append(111, "Print")

        self.file_menu.AppendSeparator()
        self.file_menu.Append(101, "Exit", "Exit the program")

        self.Bind(wx.EVT_MENU, self.new, id=100)
        self.Bind(wx.EVT_MENU, self.extractdata, id=102)
        self.Bind(wx.EVT_MENU, self.print_preview, id=110)
        self.Bind(wx.EVT_MENU, self.print_, id=111)
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)

        #---------------------------------------
        self.edit_menu = wx.Menu()
        menuBar.Append(self.edit_menu, "Edit")

        self.edit_menu.Append(201, "Edit Time File...")
        self.edit_menu.Append(202, "Edit Peak ID File...")
        self.edit_menu.Append(203, "Set Integration Files...")
        self.edit_menu.AppendSeparator()
        self.edit_menu.Append(204, "Integrate")
        self.edit_menu.AppendSeparator()
        self.edit_menu.Append(205, "Graph Preferences...")

        self.Bind(wx.EVT_MENU, self.edit_files, id=201)
        self.Bind(wx.EVT_MENU, self.edit_files, id=202)
        self.Bind(wx.EVT_MENU, self.set_files, id=203)
        self.Bind(wx.EVT_MENU, self.integrate, id=204)
        self.Bind(wx.EVT_MENU, self.graph_prefs, id=205)

        #---------------------------------------
        menu = wx.Menu()
        menuBar.Append(menu, "View")

        menu.Append(301, "Results")
        menu.AppendSeparator ()
        self.Bind(wx.EVT_MENU, self.view_results, id=301)


        toolbarmenu = wx.Menu()
#        toolbarmenu.Append(-1, "Application Toolbar", "", wx.ITEM_CHECK)
        m = toolbarmenu.Append(1111, "Zoom Toolbar", "", wx.ITEM_CHECK)
        m.Check()
        menu.Append(-1, "Toolbars", toolbarmenu)
        self.Bind(wx.EVT_MENU, self.toggleZoomToolBar, id=1111)


        #---------------------------------------
#        menu = wx.Menu()
#        menu.Append(601, "&About...", "More information about this program")
#        self.menuBar.Append(menu, "&Help");
#        wx.EVT_MENU(self, 601, self.about)
#        wx.EVT_MENU(self, 602, self.help)

        self.SetMenuBar(menuBar)

    #----------------------------------------------
    # Update the setting of the menu items
    def update_menus(self, which):
        """ update the state of some menu items """

        if which == 0:
            self.edit_menu.Enable(204, False)
            self.edit_menu.Enable(201, False)
            self.edit_menu.Enable(202, False)
        else:
            self.edit_menu.Enable(204, True)
#            self.edit_menu.Enable(201, True)
#            self.edit_menu.Enable(202, True)

    #----------------------------------------------
    def toggleZoomToolBar(self, evt):
        """ hide or show the zoom toolbar """

        if evt.IsChecked():
            self.sizer.Show(self.zoomtb)
        else:
            self.sizer.Hide(self.zoomtb)
        self.sizer.Layout()

    #----------------------------------------------
    def graph_prefs(self, evt):
        """ Open the graph preferences dialog """

        self.current_plot.showPrefsDialog(evt)

    #----------------------------------------------
    def integrate(self, evt):
        """ Integrate the chromatogram """

#        print "integrate ", self.input_file, "in archive ", self.archive
        if self.input_file is not None:
            getData(self, self.archive, self.input_file)

    #----------------------------------------------
    def set_files(self, evt):
        """ Set the time file and peak id file for integration """

        if self.filesdlg is None:
            self.filesdlg = SetFilesDialog(self)
            self.filesdlg.CenterOnScreen()

        val = self.filesdlg.ShowModal()

        if val == wx.ID_OK:
            self.integration_file = self.filesdlg.timefile
            self.peakid_file = self.filesdlg.peakidfile
            self.data_directory = self.filesdlg.datadir
            self.filesdlg.Hide()
            self.edit_menu.Enable(201, True)
            self.edit_menu.Enable(202, True)


    #----------------------------------------------
    def extractdata(self, evt):
        """ Extract a file from a zip or .a archive,
        or a single file not in an archive """

        if self.extractdlg is None:
            self.extractdlg = OpenDialog(self)
            self.extractdlg.CenterOnScreen()

        self.extractdlg.Show()

    #----------------------------------------------
    def OnExit(self, evt):
        """ Exit the application """

        self.Close(True)  # Close the frame.

    #----------------------------------------------
    def print_preview(self, evt):
        """ show a print preview dialog """

        self.current_plot.printPreview()

    #----------------------------------------------
    def print_(self, evt):
        """ Print the graph """

        self.current_plot.print_()

    #----------------------------------------------
    def new(self, evt):
        """ remove the data and start over """

        msg = "This will remove all data! Are you sure you want to continue?"
        dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.YES_NO | wx.NO_DEFAULT | wx.ICON_WARNING)
        answer = dlg.ShowModal()
        if answer == wx.ID_YES:
            self.current_plot.clear()
            self.current_plot.update()
            self.integration_file = None
            self.peakid_file = None
            self.data_directory = None
            self.input_file = None
            self.archive = None
            self.update_menus(0)
        dlg.Destroy()

       #----------------------------------------------
    def edit_files(self, evt):
        """ Bring up simple text editor to edit either the time file
        or peak id file """

        eid = evt.GetId()

        if eid == 201:
            dlg = FileView(self, self.integration_file, readonly=False)
        else:
            dlg = FileView(self, self.peakid_file, readonly=False)

        dlg.Show()

    #----------------------------------------------
    def view_results(self, event):
        """ show window with text results of integration """

        if self.input_file is not None:
            text = getPeakData(self, self.archive, self.input_file, peakInfo=True)
            dlg = TextView(self, text)
            dlg.Show()
