# vim: tabstop=4 shiftwidth=4 expandtab
"""
module for generating simple statistics for an array of data,
and for creating a dialog window where
a dataset can be chosen and the statistics displayed.
"""

import os
import numpy
import scipy.stats
import wx


#########################################################################
def getStats(y):
    """ Generate a string containing basic statistics
    Input:
        y - numpy array of data
    Returns:
        s - string with statistics
    """

    n = y.size
    mean = numpy.mean(y)
    std = numpy.std(y, ddof=1)
    minval = y.min()
    maxval = y.max()
    skew = scipy.stats.skew(y)

    drange = maxval - minval
    median = numpy.median(y)
    min_index = numpy.argmin(y)
    max_index = numpy.argmax(y)

    # lag 1 autocorrelation
#    result = numpy.correlate(y, y, mode='same')
#    mx = numpy.amax(result)
#    lag1 = result[result.size/2 + 1]/mx    # normalize to 0 - 1

    ys = sorted(y)
    upperq = numpy.percentile(ys, 0.75)
    lowerq = numpy.percentile(ys, 0.25)

    s  = "Number of Observations:         %20d\n"   % n
    s += "Mean:                           %20.8f\n" % mean
    s += "Standard Deviation:             %20.8f\n" % std
    s += "Skewness:                       %20.8f\n" % skew
#        s +=  "Kurtosis:                       %20.8f\n" % kur
#        s +=  "Lag 1 Autocorrelation:          %20.8f\n" % lag1

    s += "\n"
    s += "Range:                          %20.8f\n" % drange
    s += "Minimum Value:                  %20.8f\n" % minval
    s += "Minimum Value at observation #: %20d\n"   % min_index
    s += "Maximum Value:                  %20.8f\n" % maxval
    s += "Maximum Value at observation #: %20d\n"   % max_index

    s += "\n"
    s += "Median:                         %20.8f\n" % median
    s += "Upper Quartile:                 %20.8f\n" % upperq
    s += "Lower Quartile:                 %20.8f\n" % lowerq

    return s


#########################################################################
class StatsDialog(wx.Frame):
    """ Generate a dialog where the user can choose a dataset from
    a graph, and statistics for that dataset are displayed.
    """

    def __init__(self, parent, nid, graph=None):
        wx.Frame.__init__(self, parent, nid, 'Statistics', size=(700, 500))
        self.CenterOnScreen()

        self.graph = graph
        self.item = None

        self.CreateStatusBar()
        self.SetStatusText("This is the statusbar")

        sw = wx.SplitterWindow(self, -1, style=wx.SP_LIVE_UPDATE)

        # Store images for the tree control
        isz = (16, 16)
        il = wx.ImageList(isz[0], isz[1])
        fldridx     = il.Add(wx.ArtProvider.GetBitmap(wx.ART_FOLDER,      wx.ART_OTHER, isz))
        fldropenidx = il.Add(wx.ArtProvider.GetBitmap(wx.ART_FILE_OPEN,   wx.ART_OTHER, isz))
        fileidx     = il.Add(wx.ArtProvider.GetBitmap(wx.ART_NORMAL_FILE, wx.ART_OTHER, isz))

        # Create panel to hold tree
        p1 = wx.Panel(sw)
        box = wx.BoxSizer(wx.VERTICAL)
        self.tree = wx.TreeCtrl(p1, -1, style=wx.TR_DEFAULT_STYLE)
        self.tree.AssignImageList(il)
        self.root = self.tree.AddRoot("Data Sets", fldridx, fldropenidx)

        # Add nodes for each dataset
        for dataset in graph.datasets:
            self.tree.AppendItem(self.root, dataset.name, fileidx)

        # Open up root node
        self.tree.Expand(self.root)

        # Catch selection changes on tree
        self.Bind(wx.EVT_TREE_SEL_CHANGED, self.OnSelChanged, self.tree)

        # Add tree to sizer
        box.Add(self.tree, 1, wx.EXPAND, 0)
        p1.SetSizer(box)

        # Add another panel to hold text
        p2 = wx.Panel(sw)
        box = wx.BoxSizer(wx.VERTICAL)
        self.tc = wx.TextCtrl(p2, -1, "", style=wx.TE_READONLY | wx.TE_MULTILINE)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.tc.SetFont(font)
        box.Add(self.tc, 1, wx.EXPAND, 0)
        p2.SetSizer(box)

        sw.SetMinimumPaneSize(20)
        sw.SplitVertically(p1, p2, 140)

        # Prepare the menu bar
        menuBar = wx.MenuBar()

        # 1st menu from left
        menu1 = wx.Menu()
        menu1.Append(101, "Save", "Save text to file")
#        menu1.Append(102, "Print", "")
        menu1.AppendSeparator()
        menu1.Append(104, "Close", "Close this frame")
        # Add menu to the menu bar
        menuBar.Append(menu1, "File")

        self.SetMenuBar(menuBar)

        # Menu events

        self.Bind(wx.EVT_MENU, self.Menu101, id=101)
#        self.Bind(wx.EVT_MENU, self.Menu102, id=102)
        self.Bind(wx.EVT_MENU, self.CloseWindow, id=104)

    # -----------------------------------------------------
    def Menu101(self, event):
        """ Handle save menu event """

        dlg = wx.FileDialog(self, message="Save file as ...", defaultDir=os.getcwd(),
                            defaultFile="", style=wx.SAVE
                            )

        if dlg.ShowModal() == wx.ID_OK:
            path = dlg.GetPath()
            f = open(path, "w")
            f.write(self.tc.GetValue())
            f.close()

    # -----------------------------------------------------
#    def Menu102(self, event):
#        print("print")

    # -----------------------------------------------------
    def CloseWindow(self, event):
        """ Handle close window menu event """

        self.Close()

    # -----------------------------------------------------
    def OnSelChanged(self, event):
        """ Handle new dataset selection """

        self.item = event.GetItem()
        if self.item:
            name = self.tree.GetItemText(self.item)
            dataset = self.graph.getDataset(name)
            if dataset is None:
                self.tc.ChangeValue("")
                return

            y = dataset.ydata
            results = getStats(y)
            self.tc.ChangeValue(results)

        event.Skip()
