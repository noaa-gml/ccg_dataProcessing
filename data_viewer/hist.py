
"""
funtions and widgets for dealing with histograms
"""

import numpy

import wx

from common.validators import Validator, checkVal, V_FLOAT, V_INT

from graph5.graph import Graph
from graph5.dataset import Dataset
from graph5.style import Style


#########################################################################
def CalcTicInterval2(minval, maxval, nt):
    """ Calculate the number of subtics to use. """

    if nt >= 8: nt = 10
    if nt > 5 and nt <= 7: nt = 5
    if nt == 3 or nt == 4: nt = 2
    if nt < 1: nt = 1
    nst = 5

    mag = numpy.log10(numpy.fabs(maxval - minval))
    flr = numpy.floor(mag)
    sizeticratio = (10**(mag-flr)) / nt

    d = 1.0

    while True:
        if sizeticratio > 2.857*d:
            mult = 5
            break
        if sizeticratio > 1.333*d:
            mult = 2
            break
        if sizeticratio > 0.6666*d:
            mult = 1
            break
        d /= 10.0

    if mult == 1:
        if nst >= 10:
            nst = 10
        elif nst >= 5: nst = 5
        elif nst >= 2: nst = 2
        else: nst = 0
    elif mult == 2:
        if nst >= 8: nst = 8
        elif nst >= 4: nst = 4
        elif nst >= 2: nst = 2
        else: nst = 0
    elif mult == 5:
        if nst >= 10: nst = 10
        elif nst >= 5: nst = 5
        elif nst >= 2: nst = 2
        else: nst = 0

    return nst


#########################################################################
def NiceNum(val, roundit):
    expt = numpy.floor(numpy.log10(val))
    frac = val / 10.**expt
    if roundit:
        if frac < 1.5:
            nice = 1.0
        elif frac < 3.0:
            nice = 2.0
        elif frac < 7.0:
            nice = 5.0
        else:
            nice = 10.0

    else:
        if frac <= 1.0:
            nice = 1.0
        elif frac <= 2.0:
            nice = 2.0
        elif frac <= 5.0:
            nice = 5.0
        else:
            nice = 10.0

    x = nice * 10.**expt
    return x


#########################################################################
class HistDialog(wx.Frame):
    """ A dialog for drawing a histogram.
    Dialog is divided into two panels, the left panel has a tree
    of available datasets to choose from, the right panel has a
    graph of the histogram.
    """

    def __init__(self, parent, id, graph=None):
        wx.Frame.__init__(self, parent, id, 'Histogram', size=(600, 400))
        self.CenterOnScreen()

        self.graph = graph
        self.yaxis_units = "Count"
        self.min = 0
        self.max = 0
        self.nbins = 0

        menubar = self._make_menu_bar()
        self.SetMenuBar(menubar)

        self.CreateStatusBar()
        self.SetStatusText("")

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

        # Add another panel to hold graph
        p2 = wx.Panel(sw)
        box = wx.BoxSizer(wx.VERTICAL)
        self.histgraph = Graph(p2, -1)
        box.Add(self.histgraph, 1, wx.EXPAND, 0)
        p2.SetSizer(box)

        sw.SetMinimumPaneSize(20)
        sw.SplitVertically(p1, p2, 140)

    # -------------------------------------------------------------
    def _make_menu_bar(self):

        # Prepare the menu bar
        menuBar = wx.MenuBar()

        # 1st menu from left
        menu1 = wx.Menu()
        menu1.Append(104, "Close", "Close this frame")
        # Add menu to the menu bar
        menuBar.Append(menu1, "File")

        # Menu events

        self.Bind(wx.EVT_MENU, self.CloseWindow, id=104)

        # 2nd menu from left
        menu2 = wx.Menu()
        menu2.Append(201, "Bin Size...", "Set Bin widths of histogram")
        menu2.Enable(201, False)
        self.m = menu2

        menu = wx.Menu()
        menu.Append(202, "Count", "", wx.ITEM_RADIO)
        menu.Append(203, "Percent", "", wx.ITEM_RADIO)
        menu2.Append(-1, "Y Axis Units", menu)

        self.Bind(wx.EVT_MENU, self.axisUnits, id=202)
        self.Bind(wx.EVT_MENU, self.axisUnits, id=203)
        self.Bind(wx.EVT_MENU, self.set_param_data, id=201)

        # Add menu to the menu bar
        menuBar.Append(menu2, "Edit")

        return menuBar

    # -----------------------------------------------------
    def axisUnits(self, event):
        id = event.GetId()

        if id == 202:    # numbers
            self.yaxis_units = "Count"
        else:
            self.yaxis_units = "Percent"

        dataset = self.histgraph.getDataset("Histogram")
        if dataset is None:
            return

        self.update_histogram()

    # -----------------------------------------------------
    def update_histogram(self):

        self.histgraph.clear()
        x, y = self.getHist(self.ydata)
        dataset = Dataset(x, y, "Histogram")
        style = Style()
        style.setFillColor(wx.Colour(200, 0, 0))
        style.setConnectorType("bars")
        dataset.SetStyle(style)
        self.histgraph.addDataset(dataset)

        yaxis = self.histgraph.getYAxis(dataset.yaxis)
        yaxis.title.text = self.yaxis_units
        self.histgraph.update()
        self.m.Enable(201, True)

    # -----------------------------------------------------
    def getHist(self, y):

        n = len(y)
        total = float(n)

        if self.nbins == 0:        # Calculate bin sizes
            dmax = y.max()
            dmin = y.min()
            drange = dmax - dmin
            drange = NiceNum(drange, 0)
            step = NiceNum(drange/4, 1)
            self.min = numpy.floor(dmin / step) * step + 0.0
            self.max = numpy.ceil(dmax / step) * step + 0.0
            nbins = numpy.floor((self.max - self.min) / step)
            nx = CalcTicInterval2(self.min, self.max, 5)
            self.nbins = int(nbins * nx)

        (vals, bins) = numpy.histogram(y, self.nbins, [self.min, self.max])

        xdata = []
        ydata = []
        width = bins[1] - bins[0]
        for val, binlow in zip(vals, bins):

            if self.yaxis_units == "Percent":
                val = val/total * 100.0

            xdata.append(binlow + width/2)
            ydata.append(val)

        return xdata, ydata

    # -----------------------------------------------------
    def CloseWindow(self, event):
        self.Close()

    # -----------------------------------------------------
    def OnSelChanged(self, event):
        self.item = event.GetItem()
        if self.item:
            name = self.tree.GetItemText(self.item)
            dataset = self.graph.getDataset(name)
            if dataset is None:
                return

            self.ydata = dataset.ydata
            self.update_histogram()

        event.Skip()

    # ----------------------------------------------
    def set_param_data(self, e):
        try:
            self.paramdlg.Show()
        except:
            self.paramdlg = HistParamDialog(self)
            self.paramdlg.CenterOnScreen()
            self.paramdlg.Show()

        # this does not return until the dialog is closed.
        val = self.paramdlg.ShowModal()

        if val == wx.ID_OK:
            self.min = self.paramdlg.minbox
            self.max = self.paramdlg.maxbox
            self.nbins = self.paramdlg.nbins
            self.update_histogram()

        self.paramdlg.Hide()


#########################################################################
class HistParamDialog(wx.Dialog):
    """ A dialog for changing the parameters for a historgram """

    def __init__(
            self, parent, size=wx.DefaultSize, pos=wx.DefaultPosition,
            style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER
            ):

        wx.Dialog.__init__(self, parent, -1)

        # Main sizer for dialog
        sizer = wx.BoxSizer(wx.VERTICAL)

        self.hist = parent

        self.minbox = 0
        self.maxbox = 0
        self.nbins = 0

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        sizer.Add(box1, 0, wx.GROW | wx.ALL, 0)

        label = wx.StaticText(self, -1, "Minimum Value:")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.p1 = wx.TextCtrl(self, -1, str(self.hist.min), size=(150, -1), validator=Validator(V_FLOAT))
        box1.Add(self.p1, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        label = wx.StaticText(self, -1, "Maximum Value:")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.p2 = wx.TextCtrl(self, -1, str(self.hist.max), size=(150, -1), validator=Validator(V_FLOAT))
        box1.Add(self.p2, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        label = wx.StaticText(self, -1, "Number of Bins:")
        box1.Add(label, 0, wx.ALIGN_CENTRE | wx.ALL, 5)
        self.p3 = wx.TextCtrl(self, -1, str(self.hist.nbins), size=(150, -1), validator=Validator(V_INT))
        box1.Add(self.p3, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        sizer.Add(line, 0, wx.GROW | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        btnsizer.AddButton(btn)
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.Realize()

        sizer.Add(btnsizer, 1, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(sizer)
        sizer.SetSizeHints(self)

    # -------------------------------------------
    def ok(self, event):
        val = self.p1.GetValue()
        valid = checkVal(self.p1, val, V_FLOAT)
        if not valid:
            return
        self.minbox = float(val)

        val = self.p2.GetValue()
        valid = checkVal(self.p2, val, V_FLOAT)
        if not valid:
            return
        self.maxbox = float(val)

        val = self.p3.GetValue()
        valid = checkVal(self.p3, val, V_INT)
        if not valid:
            return
        self.nbins = int(val)

        self.EndModal(wx.ID_OK)
