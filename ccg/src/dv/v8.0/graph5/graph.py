# vim: tabstop=4 shiftwidth=4 expandtab
"""
A 2d plotting widget for wxPython
"""

import datetime
import numpy
import pickle
import wx
from pubsub import pub

from numpy import around, clip

from .axis import Axis
from . import crosshair
from .legend import Legend, LEGEND_RIGHT, LEGEND_LEFT, LEGEND_TOP, LEGEND_BOTTOM
from .title import Title
from .printout import PlotPrintout
from .graph_menu import GraphContextMenu
from .text import Text
from .style import Style
from .dataset import Dataset
from .datenum import date2num
from . import prefs
from .pen import Pen


#####################################################################3333
class Graph(wx.Window):
    """ A scientific graphing class """


    def __init__(self, parent, id=-1, yaxis_title="", xaxis_title=""):
        """Constructs a panel, which can be a child of a frame or
        any other non-control window"""

        self.version = "4.0"

        wx.Window.__init__(self, parent, id)

        c = self.GetBackgroundColour()

        self.overlay = wx.Overlay()

#        print wx.PlatformInfo
#        print wx.Platform

        # Size and location
        self.auto_size = 1
        self.plot_height = 0
        self.plot_width = 0
        self.margin = 10
        self.plotareaColor = wx.Colour(255, 255, 255)
        self.backgroundColor = c
        self.xleft = 0
        self.xright = 0
        self.ytop = 0
        self.ybottom = 0
        self.draw_frame = 1
        self.SetThemeEnabled(True)

        # User specified corners of the plotting area
        # Value of 0 means auto fit into width
        # value < 0 means that far from the edge
        # value > 0 means that far from origin
        self.xl = 0
        self.xr = 0
        self.yt = 0
        self.yb = 0

        # Crosshair stuff
        self.crosshair = crosshair.Crosshair(self)
        self.crosshair_on = False
        self.popup = crosshair.CrosshairPopup(self, wx.BORDER_NONE)
        self.show_popup = 1
        self.pointLabelPopup = crosshair.PointLabelPopup(self, wx.BORDER_NONE)
        self.show_point_label_popup = 0
        self.point_label_min_distance = 15

        # datasets
        self.datasets = []
        self.datasetShowList = []
        self.saveDataset = ""
        self.show_offscale_points = False

        # Zoom stuff
        self.zoomEnabled = False
        self.dragEnabled = False
        if wx.Platform == '__WXMAC__':
#            self.zoom_brush = wx.TRANSPARENT_BRUSH
#            self.zoom_pen = Pen( wx.Colour(255, 255, 255) )
            self.zoom_brush = wx.Brush(wx.Colour(205, 238, 255, 100), wx.SOLID)
            self.zoom_pen = Pen(wx.Colour(77, 110, 255))
        else:
            self.zoom_brush = wx.Brush(wx.Colour(50, 17, 0, 200), wx.SOLID)
            self.zoom_pen = Pen(wx.Colour(128, 128, 0))
        self.startx = 0
        self.starty = 0
        self.lastx = 0
        self.lasty = 0

        # Selection area stuff
        self.sel_startx = None
        self.sel_starty = None
        self.sel_lastx = None
        self.sel_lasty = None
        self.selectionEnabled = False
        self.selection_on = False

        self.syncid = 0

        # Text annotations
        self.textList = []

        # marker annotations
        self.markerList = []

        # line annotations
        self.vlineList = []
        self.hlineList = []

        # Axis stuff
        self.axes = []
        self.xaxisId = -1
        self.yaxisId = -1
        # Add default x axis and y axis
        self.addXAxis(xaxis_title)
        self.addYAxis(yaxis_title)

        # Things for printing
        self.print_data = wx.PrintData()
        self.print_data.SetPaperId(wx.PAPER_LETTER)
        self.print_data.SetPrintMode(wx.PRINT_MODE_PRINTER)
        self.print_data.SetOrientation(wx.LANDSCAPE)
        self.pageSetupData = wx.PageSetupDialogData()
        self.pageSetupData.SetMarginBottomRight((25, 25))
        self.pageSetupData.SetMarginTopLeft((25, 25))
        self.pageSetupData.SetPrintData(self.print_data)


        # Create some mouse events for zooming
        self.Bind(wx.EVT_LEFT_DOWN, self.OnMouseLeftDown)
        self.Bind(wx.EVT_LEFT_UP, self.OnMouseLeftUp)
        self.Bind(wx.EVT_MOTION, self.OnMotion)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnMouseRightDown)
        self.Bind(wx.EVT_RIGHT_UP, self.OnMouseRightUp)
#        self.Bind(wx.EVT_MIDDLE_DOWN, self.OnMouseMiddleDown)
        self.Bind(wx.EVT_MOUSEWHEEL, self.OnMouseWheel)


        # Add a title and legend
        self.title = Title()
        self.title.margin = 2
        self.legend = Legend()
        self.legend.title.text = ""

        # colors for createdataset
        self.colors = [
            (255, 0, 0),      # red
            (0, 0, 255),      # blue
            (0, 205, 0),      # green3
            (255, 0, 255),    # magenta
            (0, 209, 209),    # dark turquoise
            (238, 238, 0),    # yellow2
            (30, 144, 255),   # dodger blue
            (139, 89, 43),    # tan4
            (255, 140, 0),    # dark orange
            (155, 48, 255),   # purple 1
            (32, 178, 168),   # light sea green
        ]
        self.num_colors = len(self.colors)

        self._isWindowCreated = False

        if '__WXGTK__' in wx.PlatformInfo:
            self.Bind(wx.EVT_WINDOW_CREATE, self.doSetWindowCreated)
        else:
            self.doSetWindowCreated(None)

        # OnSize called to make sure the buffer is initialized.
        # This might result in OnSize getting called twice on some
        # platforms at initialization, but little harm done.
#        Size = self.GetClientSize()
#        self.width = max(1, Size.width)
#        self.height = max(1, Size.height)
        self.width = 20
        self.height = 20
        self._Buffer = wx.Bitmap(self.width, self.height)

        self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_SIZE, self.OnSize)

        self._set_cursor()

    ############################################################################

    def doSetWindowCreated(self, evt):
        """
        # OnSize called to make sure the buffer is initialized.
        # This might result in OnSize getting called twice on some
        # platforms at initialization, but little harm done.
        """

        self._isWindowCreated = True
        self.OnSize(None)

    #---------------------------------------------------------------------------
    def update(self):
        """ Redraw the graph """

        self._draw()
        self.Refresh()

    #---------------------------------------------------------------------------
    def OnSize(self, event):
        """ The Buffer init is done here, to make sure the buffer is always
            the same size as the Window
        """


        # bug with gtk in wxpython phoenix, we must wait until window
        # is created before drawing
#        if not self._isWindowCreated:
#            return

        Size = self.GetClientSize()
#        print("size is", Size.width, Size.height)
        self.width = max(1, Size.width)
        self.height = max(1, Size.height)

        # Make new offscreen bitmap: this bitmap will always have the
        # current drawing in it, so it can be used to save the image to
        # a file, or whatever.
        self._Buffer = wx.Bitmap(self.width, self.height)

        self._draw()

    #---------------------------------------------------------------------------
    def OnPaint(self, event):
        """ All that is needed here is to draw the buffer to screen """

        wx.BufferedPaintDC(self, self._Buffer)

    #---------------------------------------------------------------------------
    def _draw(self, dc=None):
        """ Draw the graph. """

#        self.SetCursor(wx.HOURGLASS_CURSOR)

        if dc is None:
            dc = wx.BufferedDC(wx.ClientDC(self), self._Buffer)
            dc.Clear()

#        t0 = datetime.datetime.now()
        for dataset in self.datasets:
            dataset.findViewableRange(self)
#        t1 = datetime.datetime.now()
#        print("time to find range", t1-t0)

        # If all datasets on an xaxis are dates, add 'date' to label
        # for axis in self.axes:
        #     datasets_on_axis = self.datasetsMappedToThisAxis(axis)
        #     if len(datasets_on_axis) > 0:
        #         if axis.type == "x" and all([ds.xdatatype == 1 for ds in datasets_on_axis]): # if they all are date = 1
        #             axis.SetTitle((axis.title.text.strip().removesuffix("Date") + " Date").strip()) # preserve existing label

        #         if axis.type == "y":
        #             yunits = set([str(ds.yunits) for ds in datasets_on_axis])
        #             yunits_str = f"[{'; '.join(yunits)}]"
        #             axis.SetTitle((axis.title.text.strip().removesuffix(yunits_str) + " " + yunits_str).strip())

        # Find and set the maximum and minimum values for each axis
        # Set the height and width of axis labeling
#        t0 = datetime.datetime.now()
        for axis in self.axes:
            axis.setLimits(self)
            axis.setSize(dc)


        self.legend.setSize(self, dc)

        self.set_graph_height(dc)
        self.set_graph_width()

        # Fill the window with background color
        dc.SetPen(wx.Pen(wx.BLACK, 1, wx.TRANSPARENT))
        dc.SetBrush(wx.Brush(self.backgroundColor, wx.SOLID))
        dc.DrawRectangle(0, 0, self.width, self.height)

        # Fill plotting area with plot area color
        dc.SetBrush(wx.Brush(self.plotareaColor, wx.SOLID))
        dc.DrawRectangle(self.xleft, self.ytop, self.plot_width+1, self.plot_height+1)

        # Draw frame around plotting area
        if self.draw_frame:
            dc.SetPen(wx.Pen(wx.BLACK, 1, wx.SOLID))
            dc.SetBrush(wx.Brush(self.plotareaColor, wx.TRANSPARENT))
            dc.DrawRectangle(self.xleft, self.ytop, self.plot_width+1, self.plot_height+1)


        # draw all the axes
        for axis in self.axes:
            axis.draw(self, dc)

        # graph title
        # determine title location
        (w, h0) = self.title.getSize(dc)
        title_x = (self.xright - self.xleft)/2 + self.xleft - w/2
        # Find height of all odd numbered x axes for correct placement of graph title
        for axis in self.axes:
            if axis.isXAxis() and axis.id % 2 == 1:
                h = axis.height
                h0 += h
        title_y = self.ytop - h0
        self.title.setLocation(title_x, title_y)
        self.title.draw(dc)

        # graph legend
        self.legend.draw(self, dc)

        dc.SetClippingRegion(self.xleft, self.ytop, self.plot_width, self.plot_height)
#        t1 = datetime.datetime.now()
#        print("time to draw graph", t1-t0)

        # Draw only datasets that are not hidden.
        # If datasetShowList is empty, draw all datasets,
        # else draw only those in the list
#        t0 = datetime.datetime.now()
        if len(self.datasetShowList) > 0:
            for name in self.datasetShowList:
                dataset = self.getDataset(name)
                dataset.draw(self, dc)
        else:
            for dataset in self.datasets:
                dataset.draw(self, dc)
#        t1 = datetime.datetime.now()
#        print("time to draw datasets", t1-t0)

        # Draw text annotations
        for t in self.textList:
            t.set_size(self, dc)
            t.draw(self, dc)

        # Draw marker annotations
        for (x, y, style) in self.markerList:
            xp = self.UserToPixel(x, self.axes[0])
            yp = self.UserToPixel(y, self.axes[1])
            style.DrawMarker(self, dc, xp, yp)

        # Draw line annotations
        for (x, style) in self.vlineList:
            xp = self.UserToPixel(x, self.axes[0])
            yptop = self.ytop+1
            ypbottom = self.ytop + self.plot_height
            style.DrawLine(self, dc, [xp, xp], [yptop, ypbottom])

        if self.selectionEnabled:
            self._drawSelectionBox(dc)

#        if self.zoomEnabled:
            # set curser as magnifier
#            self.SetCursor(wx.StockCursor(wx.CURSOR_MAGNIFIER))
#        else:
            # set curser as cross-hairs
#            self.SetCursor(wx.CROSS_CURSOR)

    #---------------------------------------------------------------------------
    def set_graph_width(self):
        """ Determine plotting area location and width leaving enough room
        for all the y axes and the legend """

        w1 = 0
        w2 = 0
        for axis in self.axes:
            if axis.isYAxis():
                if axis.id % 2 == 0:
                    w1 += axis.width
                else:
                    w2 += axis.width

        if self.xl == 0:
            if self.legend.location == LEGEND_RIGHT:
                self.xleft = w1 + self.margin
            elif self.legend.location == LEGEND_LEFT:
                self.xleft = w1 + self.margin + self.legend.width
            else:
                self.xleft = w1 + self.margin
            self.xleft = (int(self.xleft/10)+1) * 10

        elif self.xl > 0:
            self.xleft = self.xl
        else:
            self.xleft = abs(self.xl)

        if self.xr == 0:
            if self.legend.location == LEGEND_RIGHT:
                self.xright = self.width - self.legend.width - self.margin
                self.xright = self.xright - w2 - self.legend.margin
            elif self.legend.location == LEGEND_LEFT:
                self.xright = self.width - self.margin - w2
            else:
                self.xright = self.width - self.margin - w2
        elif self.xr > 0:
            self.xright = self.xr
        else:
            self.xright = self.width - abs(self.xr)

        self.plot_width = self.xright - self.xleft


    #---------------------------------------------------------------------------
    def set_graph_height(self, dc):
        """ Calculate the height of the plotting area of the graph.

            Height is the window height, minus
              the height of all the x axes,
              the height of the graph title.
        """

        # Get x axis height.
        h1 = 0
        h2 = 0
        for axis in self.axes:
            if axis.isXAxis():
                if axis.id % 2 == 0:
                    h1 += axis.height
                else:
                    h2 += axis.height

        # Get title height
        (w, titleh) = self.title.getSize(dc)

        # Set top and bottom of plotting area.
        if self.yb == 0:
            self.ybottom = self.height - h1 - self.margin
        elif self.yb > 0:
            self.ybottom = self.yb
        else:
            self.ybottom = self.height - abs(self.yb)

        if self.yt == 0:
            self.ytop = titleh + self.margin + h2
        elif self.yt > 0:
            self.ytop = self.yt
        else:
            self.ytop = abs(self.yt)

        # Adjust top and bottom if the legend is on top or bottom
        if self.legend.location == LEGEND_BOTTOM:
            self.ybottom = self.ybottom - self.legend.height - self.legend.margin

        if self.legend.location == LEGEND_TOP:
            self.ytop = self.ytop + self.legend.height + self.legend.margin

        self.plot_height = self.ybottom - self.ytop


    ############################################################################
    # Routines dealing with axes of the graph
    #---------------------------------------------------------------------------
    def addXAxis(self, title):
        """ Add an X axis to the graph. """

        axis_id = self.xaxisId + 1
        axis = Axis("x", axis_id)
        axis.title.text = title
        self.axes.append(axis)
        self.xaxisId += 1
        return axis

    #---------------------------------------------------------------------------
    def addYAxis(self, title):
        """ Add a Y axis to the graph. """

        axis_id = self.yaxisId + 1
        axis = Axis("y", axis_id)
        axis.title.text = title
        self.axes.append(axis)
        self.yaxisId += 1
        return axis

    #---------------------------------------------------------------------------
    def getXAxis(self, axis_id):
        """ Return an X axis given its id number. """

        axis_id = int(axis_id)
        for axis in self.axes:
            if axis.isXAxis() and axis.id == axis_id:
                return axis

        raise ValueError(str(axis_id) + ': illegal X axis specification')

    #---------------------------------------------------------------------------
    def getYAxis(self, axis_id):
        """ Return a Y axis given its id number. """

        axis_id = int(axis_id)
        for axis in self.axes:
            if axis.isYAxis() and axis.id == axis_id:
                return axis

        raise ValueError(str(axis_id) + ': illegal Y axis specification')

    #---------------------------------------------------------------------------
    def removeXAxis(self, axis_id):
        """ Remove an axis from the graph given its id number
            Don't remove the default axis (id = 0)
        """

        if axis_id == 0:
            return

        # If a dataset is mapped to this axis, remap it to ?????
        for axis in self.axes:
            if axis.isXAxis() and axis.id == axis_id:
                for dataset in self.datasets:
                    if dataset.xaxis == axis_id:
                        dataset.xaxis = 0        #Map it to default axis

                self.axes.remove(axis)

    #---------------------------------------------------------------------------
    def removeYAxis(self, axis_id):
        """ Remove an axis from the graph given its id number
            Don't remove the default axis (id = 0)
        """

        if axis_id == 0:
            return

        # If an dataset is mapped to this axis, remap it to ?????
        for axis in self.axes:
            if axis.isYAxis() and axis.id == axis_id:
                for dataset in self.datasets:
                    if dataset.yaxis == axis_id:
                        dataset.yaxis = 0        #Map it to default axis

                self.axes.remove(axis)

    #---------------------------------------------------------------------------
    def showGrid(self, show, xaxis_id=0, yaxis_id=0):
        """ Turn on/off drawing of grid lines at major tic interval """

        axis = self.getXAxis(xaxis_id)
        axis.show_grid = show
        axis = self.getYAxis(yaxis_id)
        axis.show_grid = show

    #---------------------------------------------------------------------------
    def showSubgrid(self, show, xaxis_id=0, yaxis_id=0):
        """ Turn on/off drawing of grid lines at minor tic interval """

        axis = self.getXAxis(xaxis_id)
        axis.show_subgrid = show
        axis = self.getYAxis(yaxis_id)
        axis.show_subgrid = show


    ############################################################################
    # Routines dealing with datasets of the graph
    def createDataset(self, x, y, name="", symbol="square", color="auto",
                      outlinecolor="black", outlinewidth=1, fillsymbol=True, markersize=2,
                      linecolor="auto", linetype="solid", connector="lines", linewidth=1):
        """ Convenience function for creating a dataset """

        # do nothing if input data lists are empty
#        if not x or not y:
        if len(x) == 0 or len(y) == 0:
            return False


        if color == "auto":
            nd = len(self.datasets)
            color = self.colors[nd%self.num_colors]

        dataset = Dataset(x, y, name)
        dataset.style.setFillColor(color)
        dataset.style.setMarker(symbol)
        dataset.style.setMarkerSize(markersize)
        dataset.style.setFillMarkers(fillsymbol)
        dataset.style.setOutlineColor(outlinecolor)
        dataset.style.setOutlineWidth(outlinewidth)
        dataset.style.setLineType(linetype)
        dataset.style.setConnectorType(connector)
        dataset.style.setLineWidth(linewidth)
        if linecolor == "auto":
            dataset.style.setLineColor(color)
        else:
            dataset.style.setLineColor(linecolor)

        self.addDataset(dataset)

        return dataset

    #---------------------------------------------------------------------------
    def addDataset(self, dataset):
        """ Add a dataset to the graph.

            Make sure the name is unique by appending a _n to the end
            of the name if needed.
        """

        names = self.getDatasetNames()
        name = dataset.name
        n = 1
        while name in names:
            name = dataset.name + "_%d" % n
            n += 1

        dataset.name = name
        if n > 1:
            dataset.label = dataset.label + "_%d" % (n-1)
        self.datasets.append(dataset)

    #---------------------------------------------------------------------------
    def getDataset(self, name):
        """ Return a dataset given its name. """

        for dataset in self.datasets:
            if dataset.name == name:
                return dataset

        return None

    #---------------------------------------------------------------------------
    def getDatasetNames(self):
        """ Get a list of dataset names that have been added to this graph. """

        tmplist = [dataset.name for dataset in self.datasets]

        return tmplist

    #---------------------------------------------------------------------------
    def clear(self):
        """ Remove all data datasets and additional axes from graph. """

        for dataset in self.datasets:
            self.removeDataset(dataset)

        self.datasets = []
        self.datasetShowList = []

        # Remove all additional axes from graph.  The removeAxis routines
        # will not remove axes with id=0
        # duplicate the list, otherwise removing an element screws up pointers to the list
        lx = self.axes[:]
        for axis in lx:
            if axis.id != 0:
                self.axes.remove(axis)
            else:
                axis.scale_type = "linear"
#            axis.autoscale = 1

        self.title = Title()
        self.yaxisId = 0
        self.xaxisId = 0

        del self.textList[:]
        del self.markerList[:]
        del self.vlineList[:]
        del self.hlineList[:]

        self.sel_startx = None
        self.sel_starty = None
        self.sel_lastx = None
        self.sel_lasty = None

    #---------------------------------------------------------------------------
    def showDatasets(self, list_of_datasets):
        """ Set list of dataset names to display.

            User can choose not to display every dataset, or can change the order
            in which they are drawn.  Can also be empty to reset to all datasets.
        """

        self.datasetShowList = list_of_datasets
        self.update()

    #---------------------------------------------------------------------------
    def removeDataset(self, dataset):
        """ Remove a single dataset from the graph. """

        if self.datasetShowList:
            if self.datasetShowList.count(dataset):
                self.datasetShowList.remove(dataset.name)

        if self.datasets.count(dataset):
            self.datasets.remove(dataset)

    #---------------------------------------------------------------------------
    def showThisDataset(self, dataset):
        """ Return true/false if this dataset is visible """

        if dataset.hidden:
            return False

        if self.datasetShowList:
            return dataset.name in self.datasetShowList

        return True

    ############################################################################
    # event handlers
    #---------------------------------------------------------------------------
    def OnMotion(self, event):
        """ capture mouse motion
            If mouse move with button down, then show crosshair or zoombox
            depending on mode.
            If no button is down, then show point labels if near a data point,
            and show any text popup if we are hovering over a text item
        """

        x, y = event.GetPosition()
        if event.LeftIsDown():
            if self.zoomEnabled or self.selectionEnabled:
                if self.inplotregion(x, y):
                    if "WXMAC" not in wx.Platform:
                        self._drawRubberBand(event)
                    self.lastx = x
                    self.lasty = y
                    self._drawRubberBand(event)
            elif self.dragEnabled:
                if event.ControlDown():
                    self._zoom(event)
                else:
                    self._pan(event)
                self.lastx = x
                self.lasty = y
                self._send_axis_limits()
            else:
#                if self.inplotregion(self.lastx, self.lasty) and "wxMac" not in wx.PlatformInfo:
#                    self.crosshair.draw(self, self.lastx, self.lasty)

                self.lastx = x
                self.lasty = y

                if self.inplotregion(x, y):
                    self.crosshair.draw(self, x, y)
                    if self.show_popup:
                        self.popup.draw(self, x, y)


        else:
            # If position is over a text annotation that is in popup mode,
            # show the popup
            for t in self.textList:
                if t.inRegion(x, y):
                    t.show(self)
                else:
                    t.hide(self)

            if self.show_point_label_popup:
                if self.inplotregion(x, y):
                    name, index, dist = self.findClosestPoint(x, y)
                    if index >= 0  and dist < self.point_label_min_distance:
                        dataset = self.getDataset(name)
                        self.pointLabelPopup.Show(True)
                        xp = dataset.xdata[index]
                        yp = dataset.ydata[index]
                        xaxis = self.getXAxis(dataset.xaxis)
                        yaxis = self.getYAxis(dataset.yaxis)
                        self.pointLabelPopup.draw(self, xaxis, yaxis, xp, yp)
                    else:
                        self.pointLabelPopup.Show(False)
                else:
                    self.pointLabelPopup.Show(False)

    #---------------------------------------------------------------------------
    def OnMouseLeftDown(self, event):
        """ Capture left mouse button press """

        x, y = event.GetPosition()

        # do this to clear out previous selection
        if self.selectionEnabled:
            self.selection_on = True
            if 'wxMac' in wx.PlatformInfo:
                self.clear_overlay()
            else:
                self._drawSelectionBox()

        if self.zoomEnabled or self.selectionEnabled or self.dragEnabled:
            self.startx = x
            self.starty = y
            self.lastx = x
            self.lasty = y
        else:
            self.lastx = x
            self.lasty = y
            if self.inplotregion(x, y):

                if self.show_popup:
                    self.popup.draw(self, x, y)
                    self.popup.Show(True)

                self.crosshair.draw(self, x, y)
                self.crosshair_on = True

        # check if mouse was over dataset label in legend
        # if so, toggle visibility of dataset
        if self.legend.inLegendRegion(x, y):
            dataset = self.legend.getDataset(self, x, y)
            if dataset:
                dataset.hidden = not dataset.hidden
                self.update()

    #---------------------------------------------------------------------------
    def OnMouseLeftUp(self, event):
        """ Capture left mouse button release """

        x, y = event.GetPosition()
        if self.show_popup:
            self.popup.Show(False)


        if self.selectionEnabled and self.selection_on:
            self.selection_on = False
            self.sel_startx = self.PixelToUser(self.startx, self.axes[0])
            self.sel_starty = self.PixelToUser(self.starty, self.axes[1])
            self.sel_lastx = self.PixelToUser(self.lastx, self.axes[0])
            self.sel_lasty = self.PixelToUser(self.lasty, self.axes[1])
            if self.startx == self.lastx or self.starty == self.lasty:
                return

        elif self.zoomEnabled:
            if self.startx == self.lastx or self.starty == self.lasty:
                return

            self.clear_overlay()

            # set new scale for each axis
            for axis in self.axes:
                if axis.isXAxis():
                    p1 = self.PixelToUser(self.lastx, axis)
                    p0 = self.PixelToUser(self.startx, axis)
                if axis.isYAxis():
                    p1 = self.PixelToUser(self.lasty, axis)
                    p0 = self.PixelToUser(self.starty, axis)


                if p0 > p1:
                    p0, p1 = p1, p0

                axis.umin = p0
                axis.umax = p1
                axis.autoscale = False
                axis.zoomstack.append([p0, p1])
                axis.set_tics = True

            self.update()
            self._send_axis_limits()


        elif self.dragEnabled:
            self._send_axis_limits()

        else:
            if self.inplotregion(x, y) and self.crosshair_on:
#                self.crosshair.hide(self, x, y)
                self.clear_overlay()
                self.crosshair_on = False

    #---------------------------------------------------------------------------
    def OnMouseRightDown(self, event):
        """ Capture right mouse button press
        If mouse is in plotting region, and control key is not pressed,
        show the context menu.
        """

        x, y = event.GetPosition()

        if self.inplotregion(x, y):
            if not event.ControlDown():
                m = GraphContextMenu(self)
                self.PopupMenu(m)

        if self.legend.inLegendRegion(x, y):
            dataset = self.legend.getDataset(self, x, y)
            if dataset:
                self.makeDatasetMenu(dataset)

    #---------------------------------------------------------------------------
    def OnMouseRightUp(self, event):
        """ Capture right mouse button release.
        Only used if control key is also pressed.
        If so, and in zoom mode, then unzoom one level
        """

        if event.ControlDown():
            x, y = event.GetPosition()
            if self.zoomEnabled and self.inplotregion(x, y):
                for axis in self.axes:
                    n = len(axis.zoomstack)
                    if n > 1:
                        b = axis.zoomstack[n-2]
                        axis.zoomstack = axis.zoomstack[:-1]
                        axis.umin = b[0]
                        axis.umax = b[1]
                    else:
                        axis.autoscale = True
                        axis.zoomstack = []

                self.update()

    #---------------------------------------------------------------------------
    def OnMouseWheel(self, event):
        """ zoom in/out on mouse wheel movement """

        a = event.GetWheelRotation()
        if a == 0: return
        x = 1 / self.axes[0].ratio * 20
        y = 1 / self.axes[1].ratio * 20
        if a < 0:
            # add this amount to axis range
            self.axes[0].adjustAxisRange(-x, x)
            self.axes[1].adjustAxisRange(-y, y)
        else:
            self.axes[0].adjustAxisRange(x, -x)
            self.axes[1].adjustAxisRange(y, -y)

        self.update()
        self._send_axis_limits()


    ############################################################################
    # Utilities
    #---------------------------------------------------------------------------
    def clearSelection(self):
        """ clear the selection box
        Note: doesn't work yet except internally
        """

        if self.selectionEnabled:
            self.selection_on = False
            if 'wxMac' in wx.PlatformInfo:
                self.clear_overlay()
            else:
                self._drawSelectionBox()

    #---------------------------------------------------------------------------
    def clear_overlay(self):
        """ Clear the wxPython overlay """

        dc = wx.ClientDC(self)
        odc = wx.DCOverlay(self.overlay, dc)
        odc.Clear()
        del odc
        self.overlay.Reset()

    #---------------------------------------------------------------------------
    def _drawRubberBand(self, event):
        """ Draw box when dragging mouse """

        w = self.lastx-self.startx
        h = self.lasty-self.starty

        dc = wx.ClientDC(self)
        if 'wxMac' in wx.PlatformInfo:
            odc = wx.DCOverlay(self.overlay, dc)
            odc.Clear()
        else:
            dc.SetLogicalFunction(wx.XOR)
        dc.SetPen(self.zoom_pen.wxPen())
        dc.SetBrush(self.zoom_brush)
        dc.DrawRectangle(self.startx, self.starty, w, h)

        if 'wxMac' in wx.PlatformInfo:
            del odc

    #---------------------------------------------------------------------------
    def _drawSelectionBox(self, dc=None):
        """ Draw selection area box """

        if not self.sel_startx: return

        x1 = self.UserToPixel(self.sel_startx, self.axes[0])
        y1 = self.UserToPixel(self.sel_starty, self.axes[1])
        x2 = self.UserToPixel(self.sel_lastx, self.axes[0])
        y2 = self.UserToPixel(self.sel_lasty, self.axes[1])

        w = x2-x1
        h = y2-y1

        if not dc:
            dc = wx.ClientDC(self)
        dc.SetLogicalFunction(wx.XOR)
        dc.SetPen(self.zoom_pen.wxPen())
        dc.SetBrush(self.zoom_brush)
        dc.DrawRectangle(x1, y1, w, h)


    #---------------------------------------------------------------------------
    def PixelToUser(self, x, axis):
        """ Convert pixel X coordinate on graph to user data value """

        if axis.isXAxis():
            p = (x-self.xleft) / axis.ratio + axis.min
        else:
            p = (self.ybottom - x) / axis.ratio + axis.min
        return p

    #---------------------------------------------------------------------------
    def PixelToUserY(self, y, axis):
        """ Convert pixel Y coordinate on graph to user data value """

        yp = (self.ybottom - y) / axis.ratio + axis.min
        return yp

    #---------------------------------------------------------------------------
    # clip min and max values to avoid int overflow later when passing pts into dc.draw methods
    def UserToPixel(self, p, axis):
        """ Convert user coordinate to pixel location on graph """

        if axis.isXAxis():
            a = around((p - axis.min) * axis.ratio + self.xleft)
            a = clip(a, -1000, self.width+1000)
        else:
            z = self.ybottom - ((p - axis.min) * axis.ratio)
            a = around(self.ybottom - ((p - axis.min) * axis.ratio))
            a = clip(a, -1000, self.height+1000)
        return a.astype(int)

    #---------------------------------------------------------------------------
    def inplotregion(self, x, y):
        """ Check if data point is inside plotting area """

        if self.ytop < y < self.ybottom and self.xleft < x < self.xright:
            return 1
        return 0

    #---------------------------------------------------------------------------
    def setZoomEnabled(self, state):
        """ Allow zooming of graph by dragging the mouse """

        self.zoomEnabled = state
        self._set_cursor()

    #---------------------------------------------------------------------------
    def setSelectionEnabled(self, state):
        """ Allow selection of graph area by dragging the mouse """

        self.selectionEnabled = state
        if not self.selectionEnabled:
            self._drawSelectionBox()
            self.sel_startx = None
            self.sel_starty = None
            self.sel_lastx = None
            self.sel_lasty = None

        self._set_cursor()

    #---------------------------------------------------------------------------
    def setDragEnabled(self, state):
        """ Allow pan and zoom of graph by dragging the mouse """

        self.dragEnabled = state
        self._set_cursor()

    #---------------------------------------------------------------------------
    def _set_cursor(self):
        """ Set the correct cursor for the viewing mode. """

        if self.dragEnabled:
            self.SetCursor(wx.Cursor(wx.CURSOR_SIZING))
        elif self.selectionEnabled:
            self.SetCursor(wx.Cursor(wx.CURSOR_MAGNIFIER))
        elif self.zoomEnabled:
            self.SetCursor(wx.Cursor(wx.CURSOR_MAGNIFIER))
        else:
            # set curser as cross-hairs
            self.SetCursor(wx.Cursor(wx.CURSOR_CROSS))


    #---------------------------------------------------------------------------
    def findClosestPoint(self, x, y):
        """ Find the closest data point in the datasets to the clicked point """

        a = []
        for dataset in self.datasets:
            result = dataset.getClosestPoint(self, x, y)
            if result:
                a.append(result)  # name, distance, index

        dists = [c[1] for c in a]
        if dists != []:
            mdist = min(dists)  #Min dist
            i = dists.index(mdist)  #index for min dist
            name = a[i][0]
            return name, a[i][2], mdist

        return "", -1, -1

    #---------------------------------------------------------------------------
    def isDatasetMappedToThisAxis(self, axis_type, axis):
        """ Check if there is an dataset using this axis """

        for dataset in self.datasets:
            if axis_type == "x":
                if dataset.xaxis == axis.id and axis_type == axis.type:
                    return True
            else:
                if dataset.yaxis == axis.id and axis_type == axis.type:
                    return True

        return False
    
    #---------------------------------------------------------------------------
    # def datasetsMappedToThisAxis(self, axis):
    #     """ Return all datasets using this axis """

    #     datasets = []
    #     axis_type = axis.type
    #     for dataset in self.datasets:
    #         if axis_type == "x":
    #             if dataset.xaxis == axis.id and axis_type == axis.type:
    #                 datasets.append(dataset)
    #         else:
    #             if dataset.yaxis == axis.id and axis_type == axis.type:
    #                 datasets.append(dataset)

    #     return datasets

    ############################################################################
    # Handle the legend context menu
    #---------------------------------------------------------------------------
    def makeDatasetMenu(self, dataset):
        """ Create a dialog for editing a dataset's properties """

        self.popupDataset = dataset

        m4 = wx.Menu()
        m5 = wx.Menu()
        for axis in self.axes:
            if axis.isXAxis():
                s = "X%d" % axis.id
                axis_id = 1000+axis.id
                m4.Append(axis_id, s)
                self.Bind(wx.EVT_MENU, self.map_axis, id=axis_id)
                if dataset.xaxis == axis.id:
                    m4.Enable(axis_id, False)
            if axis.isYAxis():
                s = "Y%d" % axis.id
                axis_id = 2000+axis.id
                m5.Append(axis_id, s)
                self.Bind(wx.EVT_MENU, self.map_axis, id=axis_id)
                if dataset.yaxis == axis.id:
                    m5.Enable(axis_id, False)

        id1 = wx.NewId()
        id2 = wx.NewId()
        id3 = wx.NewId()
        id4 = wx.NewId()
        id5 = wx.NewId()
        id6 = wx.NewId()
        id7 = wx.NewId()
        id8 = wx.NewId()
        id9 = wx.NewId()
        id10 = wx.NewId()

        Menu = wx.Menu()
        Menu.Append(id1, "Edit Attributes...", "hint 1")
        Menu.Append(id2, "Map X Axis", m4)
        Menu.Append(id3, "Map Y Axis", m5)
        Menu.AppendSeparator()

        Menu.Append(id4, "To Front", "hint 4")
        Menu.Append(id5, "To Back", "hint 4")
        Menu.Append(id6, "Forward By One", "hint 4")
        Menu.Append(id7, "Backward By One", "hint 4")
        Menu.AppendSeparator()
        Menu.Append(id8, "Cut", "hint 4")
        Menu.Append(id9, "Copy", "hint 4")
        Menu.Append(id10, "Delete", "hint 4")

        self.Bind(wx.EVT_MENU, self.editDataset, id=id1)
        self.Bind(wx.EVT_MENU, self.toFront, id=id4)
        self.Bind(wx.EVT_MENU, self.toBack, id=id5)
        self.Bind(wx.EVT_MENU, self.forward, id=id6)
        self.Bind(wx.EVT_MENU, self.backward, id=id7)
        self.Bind(wx.EVT_MENU, self.cutDataset, id=id8)
        self.Bind(wx.EVT_MENU, self.copyDataset, id=id9)
        self.Bind(wx.EVT_MENU, self.remove, id=id10)

        self.PopupMenu(Menu)


    #---------------------------------------------------------------------------
    def editDataset(self, event):
        """ Bring up edit dialog for editing a dataset's properties """

        dataset = self.popupDataset
        dataset.ShowDatasetStyleDialog(self)


    #---------------------------------------------------------------------------
    def toFront(self, event):
        """ Move dataset to last spot in drawing list """

        dataset = self.popupDataset
        if len(self.datasetShowList) > 0:
            dlist = self.datasetShowList
        else:
            dlist = self.getDatasetNames()
        dlist.remove(dataset.name)
        dlist.append(dataset.name)
        self.showDatasets(dlist)

    #---------------------------------------------------------------------------
    def toBack(self, event):
        """ Move dataset to first spot in drawing list """

        dataset = self.popupDataset
        if len(self.datasetShowList) > 0:
            dlist = self.datasetShowList
        else:
            dlist = self.getDatasetNames()
        dlist.remove(dataset.name)
        dlist.insert(0, dataset.name)
        self.showDatasets(dlist)

    #---------------------------------------------------------------------------
    def forward(self, event):
        """ Move dataset foreward (toward end) in drawing list """

        dataset = self.popupDataset
        if len(self.datasetShowList) > 0:
            dlist = self.datasetShowList
        else:
            dlist = self.getDatasetNames()
        idx = dlist.index(dataset.name)
        dlist.remove(dataset.name)
        dlist.insert(idx+1, dataset.name)
        self.showDatasets(dlist)


    #---------------------------------------------------------------------------
    def backward(self, event):
        """ Move dataset backward (toward 0) in drawing list """

        dataset = self.popupDataset
        if len(self.datasetShowList) > 0:
            dlist = self.datasetShowList
        else:
            dlist = self.getDatasetNames()
        idx = dlist.index(dataset.name)
        dlist.remove(dataset.name)
        idx -= 1
        if idx < 0:
            idx = 0
        dlist.insert(idx, dataset.name)
        self.showDatasets(dlist)

    #---------------------------------------------------------------------------
    def remove(self, event):
        """ Remove a dataset from graph """

        dataset = self.popupDataset
        self.removeDataset(dataset)
        self.update()

    #---------------------------------------------------------------------------
    def map_axis(self, event):
        """ Attach a dataset to an axis """

        dataset = self.popupDataset
        evid = event.GetId()
        if evid >= 2000:
            axisid = evid - 2000
            dataset.yaxis = axisid

        else:
            axisid = evid - 1000
            dataset.xaxis = axisid

        self.update()

    #---------------------------------------------------------------------------
    def cutDataset(self, event):
        """ Copy a dataset to buffer and remove it """

        self.copyDataset(event)
        self.remove(event)

    #---------------------------------------------------------------------------
    def copyDataset(self, event):
        """ Copy a dataset to buffer """

        dataset = self.popupDataset
#        print dataset.name
#        self.saveDataset = copy.copy(dataset)

        if wx.TheClipboard.Open():
            data = pickle.dumps(dataset)
            ldata = wx.CustomDataObject("Dataset")
            ldata.SetData(data)
            wx.TheClipboard.SetData(ldata)
            wx.TheClipboard.Close()
        else:
            print("Could not open clipboard for copying.")

    #----------------------------------------------
    def paste(self, event):
        """ Paste a dataset from the clipboard into graph """

        if wx.TheClipboard.Open():
            mydata = wx.CustomDataObject("Dataset")
            r = wx.TheClipboard.GetData(mydata)
            if r:
                dataset = pickle.loads(mydata.GetData())
                self.addDataset(dataset)
                self.update()
            else:
                print("No dataset to paste.")
            wx.TheClipboard.Close()
        else:
            print("Could not open clipboard for pasting.")


    ############################################################################
    # Routines for zooming and panning the graph
    #---------------------------------------------------------------------------
    def autoScale(self, event=None):
        """ Reset graph to auto scaling """

        for axis in self.axes:
            axis.autoscale = 1
            axis.exact = False
            axis.zoomstack = []
        self.update()
        self._send_axis_limits(autoscale=True)

    #----------------------------------------------
    def userScale(self, event=None):
        """ Reset graph to user scaling """

        for axis in self.axes:
            if axis.autoscale and axis.umin is not None and axis.umax is not None:
                axis.autoscale = 0
                axis.exact = True
            axis.zoomstack = []
        self.update()

    #----------------------------------------------
    def zoomIn(self, event=None):
        """ Zoom in half tic interval for all axes """

        for axis in self.axes:
            axis.adjustAxisRange(+axis.ticInterval/2, -axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def zoomOut(self, event=None):
        """ Zoom out half tic interval for all axes """

        for axis in self.axes:
            axis.adjustAxisRange(-axis.ticInterval/2, +axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def zoomInVert(self, event=None):
        """ Zoom in half tic interval for all y axes """

        for axis in self.axes:
            if axis.isYAxis():
                axis.adjustAxisRange(+axis.ticInterval/2, -axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def zoomOutVert(self, event=None):
        """ Zoom out half tic interval for all y axes """

        for axis in self.axes:
            if axis.isYAxis():
                axis.adjustAxisRange(-axis.ticInterval/2, +axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def zoomInHoriz(self, event=None):
        """ Zoom in half tic interval for all x axes """

        for axis in self.axes:
            if axis.isXAxis():
                axis.adjustAxisRange(+axis.ticInterval/2, -axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def zoomOutHoriz(self, event=None):
        """ Zoom out half tic interval for all x axes """

        for axis in self.axes:
            if axis.isXAxis():
                axis.adjustAxisRange(-axis.ticInterval/2, axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def panLeft(self, event=None):
        """ Shift x axes half tic interval to left """

        for axis in self.axes:
            if axis.isXAxis():
                axis.adjustAxisRange(-axis.ticInterval/2, -axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def panRight(self, event=None):
        """ Shift x axes half tic interval to right """

        for axis in self.axes:
            if axis.isXAxis():
                axis.adjustAxisRange(+axis.ticInterval/2, +axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def panDown(self, event=None):
        """ Shift y axes half tic interval down """

        for axis in self.axes:
            if axis.isYAxis():
                axis.adjustAxisRange(-axis.ticInterval/2, -axis.ticInterval/2)
        self.update()

    #----------------------------------------------
    def panUp(self, event=None):
        """ Shift y axes half tic interval up """

        for axis in self.axes:
            if axis.isYAxis():
                axis.adjustAxisRange(+axis.ticInterval/2, +axis.ticInterval/2)
        self.update()

    #---------------------------------------------------------------------------
    def _pan(self, event):
        """ Pan axis when dragging mouse """

        x, y = event.GetPosition()
        # get change in mouse position in user units
        diffx = self.PixelToUser(self.lastx, self.axes[0]) - self.PixelToUser(x, self.axes[0])
        diffy = self.PixelToUser(self.lasty, self.axes[1]) - self.PixelToUser(y, self.axes[1])

        # add this amount to axis range
        self.axes[0].adjustAxisRange(diffx, diffx)
        self.axes[1].adjustAxisRange(diffy, diffy)
        self.update()

    #---------------------------------------------------------------------------
    def _zoom(self, event):
        """ Zoom axis when dragging mouse """

        x, y = event.GetPosition()
        diffx = self.PixelToUser(self.lastx, self.axes[0]) - self.PixelToUser(x, self.axes[0])
        diffy = self.PixelToUser(self.lasty, self.axes[1]) - self.PixelToUser(y, self.axes[1])

        # add this amount to axis range
        self.axes[0].adjustAxisRange(-diffx, diffx)
        self.axes[1].adjustAxisRange(-diffy, diffy)
        self.update()


    ############################################################################
    # Miscellaneous routines
    #---------------------------------------------------------------------------
    def showPrefsDialog(self, event):
        """ Show a dialog for changing the properties of the graph """

        dlg = prefs.PreferencesDialog(self, -1, "Graph Preferences", size=(350, 800),
                                      style=wx.DEFAULT_DIALOG_STYLE)
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        dlg.ShowModal()
        dlg.Destroy()

    #---------------------------------------------------------------------------
    def Text(self, x, y, title, s):
        """ Store text annotation on the graph.
            x,y is location in user units, s is the text.
        """

        t = Text(self, x, y, title, s)
        self.textList.append(t)

        return t

    #---------------------------------------------------------------------------
    def AddMarker(self, x, y, style):
        """ Add a marker to the graph.  x,y are in user units. """

        if isinstance(x, datetime.datetime):
            xp = date2num(x)
        else:
            xp = x

        self.markerList.append((xp, y, style))

    #---------------------------------------------------------------------------
    def AddVerticalLine(self, x, style=None):
        """ Add a vertical line to the graph at x axis point 'x'.  x is in user units. """

        if isinstance(x, datetime.datetime):
            xp = date2num(x)
        else:
            xp = x

        if not style:
            style = Style()
            style.setLineColor("#aaa")

        self.vlineList.append((xp, style))

    #---------------------------------------------------------------------------
    def ClearMarkers(self, event=None):
        """ Remove all markers from the graph. """

        del self.markerList[:]

    #---------------------------------------------------------------------------
    def SetLocation(self, xleft, xright, ytop, ybottom):
        """ Specify the locations of the plotting area of the graph.
            Values are in pixels, and a value = 0 will let the graph
            automatically find the correct location for that point.
            Values < 0 are relative to the opposite side, so e.g. if xright = -100,
            then the right side of plotting area is 100 pixels to left of right side
            of graph.
        """

        self.xl = xleft
        self.xr = xright
        self.yt = ytop
        self.yb = ybottom

    #---------------------------------------------------------------------------
    def getSelection(self):
        """ Get corners of area highlighted by the user in user units"""

        for axis in self.axes:
            if axis.isXAxis():
                p1 = self.PixelToUser(self.lastx, axis)
                p0 = self.PixelToUser(self.startx, axis)
                if p0 > p1:
                    p0, p1 = p1, p0
                xleft = p0
                xright = p1

            if axis.isYAxis():
                p1 = self.PixelToUser(self.lasty, axis)
                p0 = self.PixelToUser(self.starty, axis)
                if p0 > p1:
                    p0, p1 = p1, p0
                ybottom = p0
                ytop = p1

        return (xleft, xright, ybottom, ytop)


    ############################################################################
    # Routines for printing the graph, saving an image of the graph,
    # or saving/loading graph to/from a file
    #---------------------------------------------------------------------------
    def getImage(self):
        """ Convert the buffer to an image and return it. """

        image = self._Buffer.ConvertToImage()

        return image

    #----------------------------------------------
    def saveImage(self, event):
        """ Save the graph to a png image file """

        wildcard = "PNG Images (*.png)|*.png| All files (*.*)|*.*"

        dlg = wx.FileDialog(self, message="Save image as ...", defaultDir=".", wildcard=wildcard,
                            style=wx.FD_SAVE | wx.FD_CHANGE_DIR | wx.FD_OVERWRITE_PROMPT)

        if dlg.ShowModal() == wx.ID_OK:
            image = self.getImage()
            path = dlg.GetPath()
            image.SaveFile(path, wx.BITMAP_TYPE_PNG)

    #---------------------------------------------------------------------------
    def printPreview(self, event=None):
        """Print-preview current plot."""

        data = wx.PrintDialogData(self.print_data)
        printout = PlotPrintout(self)
        printout2 = PlotPrintout(self)
        self.preview = wx.PrintPreview(printout, printout2, data)

        if not self.preview.IsOk():
            wx.MessageDialog(self, "Print Preview failed.\n" \
                               "Check that default printer is configured\n", \
                               "Print error", wx.OK|wx.CENTRE).ShowModal()
            return

        # search up tree to find frame instance
        frame = self
        while not isinstance(frame, wx.Frame):
            frame = frame.GetParent()
        pfrm = wx.PreviewFrame(self.preview, frame, "Preview")

        pfrm.Initialize()
        pfrm.SetPosition(frame.GetPosition())
        pfrm.SetSize(frame.GetSize())
        pfrm.Show(True)

    #---------------------------------------------------------------------------
    def print_(self, event=None):
        """ Print the graph """

        pdd = wx.PrintDialogData(self.print_data)
        pdd.SetToPage(2)
        printer = wx.Printer(pdd)
        printout = PlotPrintout(self)

        # search up tree to find frame instance
        frame = self
        while not isinstance(frame, wx.Frame):
            frame = frame.GetParent()

        if printer.Print(frame, printout, True):
            self.print_data = wx.PrintData(printer.GetPrintDialogData().GetPrintData())

        printout.Destroy()

    #----------------------------------------------
    def saveGraph(self, event=None):
        """ Create a dialog for selecting a graph file, then
        call the save method to save graph settings.
        """

        wildcard = "Graph Files (*.dv)|*.dv| All files (*.*)|*.*"

        dlg = wx.FileDialog(self, message="Save graph as ...", defaultDir=".", wildcard=wildcard,
                            style=wx.FD_SAVE | wx.FD_CHANGE_DIR | wx.FD_OVERWRITE_PROMPT)

        if dlg.ShowModal() == wx.ID_OK:
            path = dlg.GetPath()
            if not path.endswith(".dv"):
                path += ".dv"
            self.save(path)

    #----------------------------------------------
    def loadGraph(self, event=None):
        """ Create a dialog for selecting a graph file,
        then call the load method
        """

        wildcard = "Graph Files (*.dv)|*.dv| All files (*.*)|*.*"

        dlg = wx.FileDialog(self, message="Open graph ...", defaultDir=".", wildcard=wildcard,
                            style=wx.FD_OPEN | wx.FD_CHANGE_DIR)

        if dlg.ShowModal() == wx.ID_OK:
            path = dlg.GetPath()
            self.load(path)



    #---------------------------------------------------------------------------
    def save(self, filename):
        """ Save the graph setttings to a pickled file """

        graph_file = open(filename, 'wb')
        pickle.dump(self.version, graph_file)
        pickle.dump(self.datasets, graph_file)
        pickle.dump(self.datasetShowList, graph_file)
        pickle.dump(self.legend, graph_file)
        pickle.dump(self.title, graph_file)
        pickle.dump(self.axes, graph_file)
        pickle.dump(self.crosshair, graph_file)
        # Text annotations
        pickle.dump(self.textList, graph_file)

        # marker annotations
        pickle.dump(self.markerList, graph_file)

        # line annotations
        pickle.dump(self.vlineList, graph_file)
        pickle.dump(self.hlineList, graph_file)

        # misc graph settings
        pickle.dump(self.margin, graph_file)
        pickle.dump(self.plotareaColor, graph_file)
        pickle.dump(self.backgroundColor, graph_file)
        pickle.dump(self.show_offscale_points, graph_file)

        graph_file.close()

    #---------------------------------------------------------------------------
    def load(self, filename):
        """ Load a pickled file with graph settings """

        import sys

        try:
            f = open(filename, 'rb')
        except IOError:
            print("Can't open graph file ", filename, file=sys.stderr)
            return

        self.clear()

        try:
            self.version = pickle.load(f)
        except pickle.UnpicklingError:
            wx.MessageDialog(self, "File Error.   " \
                               "Invalid graph file format.", \
                               "File error", wx.OK|wx.CENTRE).ShowModal()

            f.close()
            return

#        print self.version

        dlist = pickle.load(f)
#        print dlist[0]
#        print len(dlist)
        for dataset in dlist:
            self.addDataset(dataset)

        self.datasetShowList = pickle.load(f)

        self.legend = pickle.load(f)
        self.title = pickle.load(f)

        alist = pickle.load(f)
        for i, axis in enumerate(alist):
            self.axes[i] = axis

        self.crosshair = pickle.load(f)

        self.textList = pickle.load(f)
        self.markerList = pickle.load(f)
        self.vlineList = pickle.load(f)
        self.hlineList = pickle.load(f)

        self.margin = pickle.load(f)
        self.plotareaColor = pickle.load(f)
        self.backgroundColor = pickle.load(f)
        self.show_offscale_points = pickle.load(f)

        f.close()

        self.update()

    #---------------------------------------------------------------------------
    def _send_axis_limits(self, autoscale=False):
        """ send message about x axis limits change """

        xmin = self.axes[0].umin
        xmax = self.axes[0].umax
        xexact = self.axes[0].exact
        limits = [self, xmin, xmax, xexact, autoscale]
        pub.sendMessage("graph_change", message="scale change", arg2=limits)

    #---------------------------------------------------------------------------
    def syncAxis(self, syncid=0):
        """ subscribe this graph to listen for graph change messages

        This will allow multiple graphs to keep their x axis limits
        synced together.  So if one graph is zoomed or panned, other graphs will
        also zoom and pan, X axis only, to stay in sync.
        """

        self.syncid = syncid

        pub.subscribe(self.my_listener, "graph_change")

    #---------------------------------------------------------------------------
    def my_listener(self, message, arg2=None):
        """ message received.  Process it.
        Update the x axis limits with values received in message
        """

        calling_graph, xmin, xmax, xexact, autoscale = arg2

        if calling_graph.syncid != self.syncid: return

        xaxis = self.axes[0]
        if autoscale:
            xaxis.autoscale = 1
            xaxis.exact = False
            xaxis.zoomstack = []

        else:
            if xmin > xmax:
                xmin, xmax = xmax, xmin
            xaxis.setAxisRange(xmin, xmax, exact=xexact)

        self.update()
