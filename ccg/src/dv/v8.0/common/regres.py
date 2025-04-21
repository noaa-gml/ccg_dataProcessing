
import os
import wx
import numpy
import scipy.stats

from .validators import Validator, V_FLOAT
from .stats import getStats

from graph5.graph import Graph
from graph5.dataset import Dataset


#########################################################################
class RegressionDialog(wx.Frame):

    def __init__(self, parent, id, graph=None):
        wx.Frame.__init__(self, parent, id, 'Regression', size=(650, 500))
        self.CenterOnScreen()

        self.graph = graph
        self.timezero = 0.0
        self.nparm = 2
        self.dataset = None

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

        # Add another panel to hold text
        p2 = wx.Panel(sw)
        box = wx.BoxSizer(wx.VERTICAL)

        box1 = wx.FlexGridSizer(0, 2, 2, 2)
        box.Add(box1, 0, wx.ALL | wx.ALIGN_CENTER, 0)

        label = wx.StaticText(p2, -1, "Number of Parameters: ")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.prec = wx.SpinCtrl(p2, -1, str(self.nparm), size=(50, -1), min=1, max=10)
        self.Bind(wx.EVT_SPINCTRL, self.changeparam, self.prec)

        box1.Add(self.prec, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        label = wx.StaticText(p2, -1, "X Intercept: ")
        box1.Add(label, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.tz = wx.TextCtrl(p2, -1, str(self.timezero), size=(100, -1),
                              style=wx.TE_PROCESS_ENTER, validator=Validator(V_FLOAT))
        box1.Add(self.tz, 0, wx.ALIGN_RIGHT | wx.ALIGN_CENTER_VERTICAL | wx.ALL, 2)
        self.Bind(wx.EVT_TEXT_ENTER, self.settz, self.tz)

        # Notebook for holding graphs for the various curves
        self.nb = wx.Notebook(p2, -1, style=wx.BK_DEFAULT)
        box.Add(self.nb, 1, wx.EXPAND | wx.ALL, 5)

        page = self.makeGraphPage(self.nb)
        self.nb.AddPage(page, "Graph")

        page = self.makeResultsPage(self.nb)
        self.nb.AddPage(page, "Results")

        p2.SetSizer(box)

        sw.SetMinimumPaneSize(20)
        sw.SplitVertically(p1, p2, 140)

        # Prepare the menu bar
        menuBar = wx.MenuBar()

        # 1st menu from left
        menu1 = wx.Menu()
    #        menu1.Append(101, "Export", "Export dataset to grapher")
        menu1.Append(102, "Print", "")
        menu1.AppendSeparator()
        menu1.Append(104, "Close", "Close this frame")
        # Add menu to the menu bar
        menuBar.Append(menu1, "File")

        self.SetMenuBar(menuBar)

        # Menu events
        self.Bind(wx.EVT_MENU, self.Menu101, id=101)
        self.Bind(wx.EVT_MENU, self.Menu102, id=102)
        self.Bind(wx.EVT_MENU, self.CloseWindow, id=104)

        self.SetMenuBar(menuBar)

    # ----------------------------------------------
    def makeGraphPage(self, nb):

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        self.regresgraph = Graph(page, -1)
        box0.Add(self.regresgraph, 1, wx.GROW | wx.ALL, 5)

        page.SetSizer(box0)
        return page

    # ----------------------------------------------
    def makeResultsPage(self, nb):

        page = wx.Panel(nb, -1)
        box0 = wx.BoxSizer(wx.VERTICAL)

        self.tc = wx.TextCtrl(page, -1, "", style=wx.TE_READONLY | wx.TE_MULTILINE)
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.tc.SetFont(font)
        box0.Add(self.tc, 1, wx.EXPAND, 0)

        page.SetSizer(box0)
        return page

    # -----------------------------------------------------
    def OnSelChanged(self, event):
        """ A new dataset has been selected for regression.
            Save the chosen dataset, remove all datasets from
            regression graph, then add the chosen dataset to
            the regression graph, calculate the regression,
            add the regression line to the graph
        """
        import copy
        self.item = event.GetItem()
        if self.item:
            name = self.tree.GetItemText(self.item)
            dataset = copy.copy(self.graph.getDataset(name))
            if dataset == "":
                return

            self.dataset = dataset
            # Remove all datasets
            self.regresgraph.clear()
            # Change source dataset to remove connection lines
            self.dataset.style.setConnectorType("None")
            # Add revised source dataset to graph
            self.regresgraph.addDataset(self.dataset)
            self.update_graph()

        event.Skip()

    # -----------------------------------------------------
    def update_graph(self):

        if self.dataset is None:
            return
        # Check that nparm is <= number of data points.
        # This can happen if a new dataset is chosen that has
        # fewer points than the value in the nparm spin ctrl.
        if self.nparm > len(self.dataset.xdata):
            self.nparm = len(self.dataset.xdata)
            self.prec.SetValue(self.nparm)

        # Calculate regression line
        x, y, text = self.getRegression(self.dataset)

        dataset = self.regresgraph.getDataset("Regression")
        if dataset is None:
            # Create a graph dataset for the regression line
            # and and it to the graph.
            dataset = Dataset(x, y, "Regression")
            style = dataset.style
            style.setLineColor(wx.Colour("red"))
            style.setLineType("solid")
            style.setLineWidth(2)
            self.regresgraph.addDataset(dataset)
        else:
            # dataset already exists, change the data values
            dataset.SetData(x, y)

        self.regresgraph.update()
        self.tc.ChangeValue(text)

    # -----------------------------------------------------
    def changeparam(self, event):
        nparm = self.prec.GetValue()
        if self.dataset is not None:
            if nparm > len(self.dataset.xdata):
                nparm = len(self.dataset.xdata)
                self.prec.SetValue(nparm)

        self.nparm = nparm
        self.update_graph()

    # -----------------------------------------------------
    def settz(self, event):
        self.timezero = float(self.tz.GetValue())
        self.update_graph()

    # -----------------------------------------------------
    def getRegression(self, dataset):
        import copy

        x = copy.copy(dataset.xdata)
        if self.timezero != 0:
            for i in range(0, len(x)):
                x[i] = x[i] - self.timezero

        y = dataset.ydata
        n = len(y)
        xdata = []
        ydata = []

        nparm = self.nparm
        # handle special case of nparm=1, the mean
        if nparm == 1:
            s = getStats(y)
            mean = numpy.mean(y)
            xdata.append(x.min())
            xdata.append(x.max())
            ydata.append(mean)
            ydata.append(mean)
            return xdata, ydata, s

        # Handle actual regressions.  For linear regression,
        # we'll do some extra statistics to check if the
        # slope coefficient is significant.
        if nparm > 2 or n == 2:
            coeffs = numpy.polyfit(x, y, deg=nparm-1)
        else:
            slope, intercept, r_value, p_value, std_err = scipy.stats.linregress(x, y)
            coeffs = [slope, intercept]

        # calculate residual standard deviation
        d = y - numpy.polyval(coeffs, x)
        mean = numpy.mean(d)
        std = numpy.std(d, ddof=nparm)
        chisq = numpy.sum(d*d)
        expected = numpy.polyval(coeffs, x)
        chisqr = numpy.sum((d * d) / expected)
        chisquare, pval = scipy.stats.chisquare(y, expected)
    #    print "chisq, p ", chisq, p_value
    #    print "chisqr", chisqr
    #    print "chisquare, pval", chisquare, pval

        # calculate the regression line values for plotting
        # From max to min with steps at 1/100 of the range
        xmin = x.min()
        xmax = x.max()
        step = (xmax-xmin)/100.0
        xdata = numpy.arange(xmin, xmax, step)
        ydata = numpy.polyval(coeffs, xdata)
        if self.timezero != 0:
            for i in range(0, len(xdata)):
                xdata[i] = xdata[i] + self.timezero


        s  = "X Intercept at t = %f\n\n" % self.timezero
        s += "Polynomial Regression\n"
        s += "   Number of Parameters:   %d\n" % nparm
        s += "   Number of Data Points:  %d\n" % n
        s += "   Coefficients:\n"
        i = 0
        for cp in coeffs[-1::-1]:
            s += "    %d:  %18.6f\n" % (i, cp)
            i += 1

        s += "\n\n"
    #        printf("   Covariance Matrix:\n     ");
    #        for (i=0; i<nparm; i++) {
    #                for (j=0; j<nparm; j++) {
    #                        printf (" %+.5e ", COV(i,j));
    #                }
    #                printf ("\n     ");
    #        }
        s += "\n   Chisq = %g\n" % chisq
        s += "   Residual Standard Deviation:   %g\n" % std
        if nparm == 2 and n > 2:
    #        s += "   t value: %g\n" % t
            s += "   p value: %g\n" % p_value
            s += "     (if p < 0.05, then linear coefficient is significant)"

        return xdata, ydata, s

    # -----------------------------------------------------
    def Menu101(self, event):
        dlg = wx.FileDialog(self, message="Save file as ...", defaultDir=os.getcwd(),
                            defaultFile="", style=wx.SAVE
                            )

        if dlg.ShowModal() == wx.ID_OK:
            path = dlg.GetPath()
            f = open(path, "w")
            f.write(self.tc.GetValue())
            f.close()

    # -----------------------------------------------------
    def Menu102(self, event):
        self.regresgraph.printPreview()

    # -----------------------------------------------------
    def CloseWindow(self, event):
        self.Close()
