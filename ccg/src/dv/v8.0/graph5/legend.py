# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for a legend in the graph
"""

from numpy import transpose
import wx
from .title import Title
from .font import Font

LEGEND_RIGHT = 0
LEGEND_LEFT = 1
LEGEND_TOP = 2
LEGEND_BOTTOM = 3
LEGEND_PLOTAREA = 4

#####################################################################3333
class Legend:
    """ A legend show a list of the dataset names and styles
    that are drawn in the graph.  This class also allows the
    toggling show/hide of a dataset by clicking on the legend
    label for the dataset.
    The location of the legend is outside the plotting area,
    unless the location is set to LEGEND_PLOTAREA.
    """

    def __init__(self):

        self.showLegend = True
        self.showLegendBorder = True
        self.location = LEGEND_RIGHT
        self.x = 0.0
        self.y = 0.0
        self.background = wx.Colour(255, 255, 255)
        self.foreground = wx.Colour(0, 0, 0)    # Border color
        self.autoPosition = True
        self.title = Title()
        self.font = Font(size=8)
        self.borderWidth = 1
        self.raised = True
        self.margin = 5
        self.width = 0
        self.height = 0
        self.symbol_width = 30
        self.hidden_bg = wx.Colour(255, 255, 200)
        self.color = wx.BLACK        # font color
        self.spacing = 3    # spacing between lines

    #---------------------------------------------------------------------------
    def draw(self, graph, dc):
        """ Draw the legend. """

        if not self.showLegend:
            return

        self._set_location(graph)

        showlist = self.getShowList(graph)
        if not showlist:
            return

        # legend border
        if self.showLegendBorder:
            dc.SetPen(wx.Pen(self.foreground, self.borderWidth, wx.SOLID))
            dc.SetBrush(wx.Brush(self.background, wx.SOLID))
            dc.DrawRectangle(self.x, self.y, self.width, self.height)

        # legend title
        dc.SetFont(self.font.wxFont())
        dc.SetTextForeground(self.title.color)
        (w, h) = dc.GetTextExtent(self.title.text)
        xp = self.x + self.width/2 - w/2
        yp = self.y + self.margin + self.borderWidth
        dc.DrawText(self.title.text, int(xp), int(yp))
        yp += h + self.spacing


        # Dataset names
        for name in showlist:
            dataset = graph.getDataset(name)
            (w, h) = dc.GetTextExtent(dataset.label)

            if dataset.hidden:
                x0 = self.x + self.margin + self.borderWidth
                y0 = yp
                w0 = self.width - 2*self.borderWidth - 2*self.margin
                h0 = h
#                print "rect is ",x0,x0+w0,y0,y0+h0
                dc.SetPen(wx.Pen(wx.Colour(200, 100, 100), 1, wx.SOLID))
                dc.SetBrush(wx.Brush(self.hidden_bg, wx.SOLID))
                dc.DrawRectangle(x0-2, y0-1, w0+3, h0+2)

            if dataset.style.connectorType != "none":
                x0 = self.x + self.borderWidth + self.margin
                x1 = x0 + self.symbol_width
                y0 = yp + h/2
                y1 = yp + h/2
                dc.SetPen(wx.Pen(dataset.style.lineColor, dataset.style.lineWidth, dataset.style.lineType))
                dc.DrawLine(int(x0), int(y0), int(x1), int(y1))

            x0 = self.x + self.margin + self.borderWidth + self.symbol_width/2
            y0 = yp + h/2
            pts = transpose([[x0], [y0]])

            markersize = min([5, h/2])
            dataset.style.draw_markers(dc, pts, markersize)

            xp = x0 + self.margin + self.symbol_width/2
            dc.SetTextForeground(self.color)
            dc.DrawText(dataset.label, int(xp), int(yp))
            yp += h + self.spacing


    #---------------------------------------------------------------------------
    def setSize(self, graph, dc):
        """ Calculate the width and height of legend """

        # If no datasets are shown, size is 0
        showlist = self.getShowList(graph)
        if not self.showLegend or not showlist:
            self.width = 0
            self.height = 0
            return

# top and bottom here for now.  Need to change because they'll have a different layout
        if self.location == LEGEND_RIGHT or \
           self.location == LEGEND_LEFT or \
           self.location == LEGEND_TOP or \
           self.location == LEGEND_BOTTOM or \
           self.location == LEGEND_PLOTAREA:

            # Get legend title width
#            dc.SetFont(self.title.font)
            dc.SetFont(self.title.font.wxFont())
            (width, height) = dc.GetTextExtent(self.title.text)

            # Now for each data dataset, get maximum
            # width of label
            dc.SetFont(self.font.wxFont())
            labelw = 0
            for name in showlist:
                dataset = graph.getDataset(name)
                if dataset is not None:
                    (w, h) = dc.GetTextExtent(dataset.label)
                    if w > labelw:
                        labelw = w
                    height += h + self.spacing

            # Total label width is text width, marker width plus some space inbetween
            labelw += self.margin + self.symbol_width

            # Take the wider of the title or label
            if labelw > width:
                width = labelw

            self.width = width + 2*self.margin
            self.height = height + 2*self.margin
            if self.showLegendBorder:
                self.width += self.borderWidth*2
                self.height += self.borderWidth*2


    #---------------------------------------------------------------------------
    def _set_location(self, graph):
        """ Determine location of legend """

        if not self.showLegend:
            self.x = 0
            self.y = 0
            return

        if self.location == LEGEND_RIGHT:
            self.x = graph.width - graph.margin - self.width
            self.y = graph.ytop + 20

        if self.location == LEGEND_LEFT:
            self.x = graph.margin
            self.y = graph.ytop + 20

        if self.location == LEGEND_BOTTOM:
            self.x = graph.margin
            self.y = graph.height - graph.margin - self.height

        if self.location == LEGEND_TOP:
            self.x = graph.margin
            self.y = graph.margin

#or self.location == LEGEND_PLOTAREA:



    #---------------------------------------------------------------------------
    def inLegendRegion(self, x, y):
        """ Check if position x,y is inside the legend """

#        return x >= self.x and x <= self.x + self.width and y >= self.y and y <= self.y + self.height
        return self.x <= x <= self.x + self.width and self.y <= y <= self.y + self.height

    #---------------------------------------------------------------------------
    def getDataset(self, graph, x, y):
        """ Given window x,y location, determine if that location is on a
            legend dataset label. If so return the dataset, else return None
            Used in graph.py to determine if user clicked on a dataset label.
        """

        dc = wx.ClientDC(graph)
        dc.SetFont(self.font.wxFont())
        (w, h) = dc.GetTextExtent(self.title.text)
        yp = self.y + self.margin + self.borderWidth
        yp += h + self.spacing

        # get left location and width of legend label area
        x0 = self.x + self.margin + self.borderWidth
        w0 = self.width - 2*self.borderWidth - 2*self.margin

        # Dataset names
        showlist = self.getShowList(graph)
        for name in showlist:
            dataset = graph.getDataset(name)
            (w, h0) = dc.GetTextExtent(dataset.label)

            if x0 <= x <= x0 + w0 and yp <= y <= yp + h0:
                return dataset

            yp += h0 + self.spacing

        return None

    #---------------------------------------------------------------------------
    def getShowList(self, graph):
        """ Get list of dataset names to display in legend """

        if graph.datasetShowList:
            dlist = graph.datasetShowList
        else:
            dlist = graph.getDatasetNames()

        return dlist
