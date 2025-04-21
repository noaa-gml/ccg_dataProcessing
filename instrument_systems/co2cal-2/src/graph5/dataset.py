# vim: tabstop=4 shiftwidth=4 expandtab
"""
Description
===========

The Dataset class is used to contain the data points and drawing style
of a 'set' of data.  It also keeps track of which axis on the graph that
the data is to be mapped to.

A data point consists of an x value, a y value, and a weight value.
The weight value is used to distinguish between different drawing styles.
For example, a data set of

    [1, 2, 0
     2, 3, 0
     3, 4, 1]

will have the first two points drawn in the first style, the third point
drawn in the second style.

The x and y values are stored as numpy arrays for faster processing.

Values passed in when creating a dataset can be either datetime objects or floats.
If datatime objects, they are converted to a float value using date2num(),
and the datatype value is set to DATE.

The Dataset class also has a popup dialog that can be used to dynamically
change the style attributes of the dataset.
"""

import datetime
import numpy
import wx

from .style import Style, StyleDialog
from .datenum import date2num


DATE = 1
FLOAT = 0


#####################################################################
class Dataset:
    """ Class for containing data in a 'dataset'.
    A dataset has an array of data for the x axis and
    a corresponding array of data for the y axis.
    The arrays can be either floats or datetime objects.

    This class also has info such as
        hidden - whether to display this dataset or not
        xaxis - the graph x axis that the dataset uses
        yaxis - the graph y axis that the dataset uses
        name - a name for this dataset
        label - the label to display in the legend
        style - a style object for drawing the dataset
        """

    def __init__(self, x=None, y=None, name=""):
        self.name = name
        self.hidden = False
        self.label = self.name
        self.xaxis = 0  # The id of the xaxis to map the data on
        self.yaxis = 0  # The id of the yaxis to map the data on
        self.include_in_yaxis_range= True
        self.include_in_xaxis_range= True

        # data parameters
        if x is None:
            self.xdata = numpy.array([])
            self.xdatatype = FLOAT
        else:
            if len(x) > 0:
                if isinstance(x[0], datetime.datetime):
                    self.xdata = numpy.array(date2num(x))
                    self.xdatatype = DATE
                elif isinstance(x[0], numpy.datetime64):
                    tmp = x.astype('M8[ms]').astype('O') # convert to datetime
                    self.xdata = numpy.array(date2num(tmp))
                    self.xdatatype = DATE
                else:
                    self.xdata = numpy.array(x).astype(float)
                    self.xdatatype = FLOAT
            else:
                self.xdata = numpy.array([])
                self.xdatatype = FLOAT


        if y is None:
            self.ydata = numpy.array([])
            self.ydatatype = FLOAT
        else:
            if len(y) > 0:
                if isinstance(y[0], datetime.datetime):
                    self.ydata = numpy.array(date2num(y))
                    self.ydatatype = DATE
                else:
                    self.ydata = numpy.array(y).astype(float)
                    self.ydatatype = FLOAT
            else:
                self.ydata = numpy.array([])
                self.ydatatype = FLOAT

        t = numpy.isnan(self.ydata)
        self.ydata = self.ydata[~t]
        self.xdata = self.xdata[~t]

#        print("@@@", self.xdata)
#        print("@@@", self.ydata)

        self.weights = numpy.zeros(self.xdata.size, int)
        self.ymin = 0
        self.ymax = 1
        self.xmin = 0
        self.xmax = 1
        self.yvmin = 0
        self.yvmax = 1
        self.xvmin = 0
        self.xvmax = 1
        self.missingValue = 0.0
        self.subsetStart = -1
        self.subsetEnd = -1

        self.userData = ""

        # Styles
        self.style = Style()
        self.styles = []
        self.styles.append((0, self.style))     # tuple is (weight value, style)

        # Find the minimum and maximum values of the data
        self._findRange()

    #---------------------------------------------------------------------------
    def getClosestPoint(self, graph, x, y):
        """
        Find the data point that is closest to the given x and y coordinates
        of the graph.  x and y are in pixel units.
        """

        # If this dataset isn't shown, just return
        if self.hidden:
            return None

        # Get the axes that this dataset is using.
        xaxis = graph.getXAxis(self.xaxis)
        yaxis = graph.getYAxis(self.yaxis)

        # Convert data points in this dataset to pixel coordinates
        xscaled = graph.UserToPixel(self.xdata, xaxis)
        yscaled = graph.UserToPixel(self.ydata, yaxis)
        pts = numpy.transpose([xscaled, yscaled])

        # Now find the data point closest to the given coordinates
        pxy = numpy.array([x, y])
        d = numpy.sqrt(numpy.add.reduce((pts-pxy)**2, 1)) #sqrt(dx^2+dy^2)
        pntIndex = numpy.argmin(d)
        dist = d[pntIndex]

        # return dataset name, the actual distance, and the index in the
        # dataset point array for the closest point
        return self.name, dist, pntIndex


    #---------------------------------------------------------------------------
    def draw(self, graph, dc):
        """ Draw the dataset to the buffer """

        if self.hidden:
            return

        if self.xdata.size == 0 or self.ydata.size == 0:
            return

        # Get the axes used by the dataset
        xaxis = graph.getXAxis(self.xaxis)
        yaxis = graph.getYAxis(self.yaxis)

        # Plot only points within the axis limits
        # The array c will contain 1's at the indices where
        # data points are within the axis limits.
        for i in range(0, len(self.styles)):
            (weight, style) = self.styles[i]

            # Find all the data points that match
            # this style and are inside the axis limits.
            c = (self.weights == weight) & \
                (self.xdata >= xaxis.min) & \
                (self.xdata <= xaxis.max)

            # Create a separate array of the matching points
            xp = self.xdata[c]
            yp = self.ydata[c]

            if graph.show_offscale_points:
                c = (yp > yaxis.max)
                yp[c] = yaxis.max
                c = (yp < yaxis.min)
                yp[c] = yaxis.min

            # Convert the points to pixel coordinates
            xscaled = graph.UserToPixel(xp, xaxis)
            yscaled = graph.UserToPixel(yp, yaxis)
            pts = numpy.transpose([xscaled, yscaled])

            # revise pts for posts and bars to draw from yaxis=0 instead?
            # axis = graph.getYAxis(self.yaxis)
            #               if axis.min < 0:
            #                       y1 = graph.UserToPixel(0,axis)
            #               else:
            #                       y1 = graph.ybottom


            # Draw the points with the style
            style.draw(graph, dc, pts)

        return

    #---------------------------------------------------------------------------
    def findViewableRange(self, graph):
        """ Find the minimum and maximum data values for the data
        within the range of its axes.
        For example, if x axis is manually scaled, and y axis is autoscaled,
        then we want the y axis range to be determined only by the points within
        the manually scaled range of the x axis.
        """
#        return

        # for x axis values, check if y axis is not autoscale.
        # If not, then find the min and max within that axis range
        if self.xdata.size > 0:
            axis = graph.getYAxis(self.yaxis)
            if axis.autoscale:
                self.xvmin = self.xdata.min()
                self.xvmax = self.xdata.max()
            else:
                amin = axis.umin
                amax = axis.umax
#                print "try to find range for yaxis between ", amin, "and", amax
                a = numpy.where((self.ydata >= amin) & (self.ydata <= amax))
                if a[0].size > 0:
                    self.xvmin = self.xdata[a[0]].min()
                    self.xvmax = self.xdata[a[0]].max()
                else:
                    self.xvmin = None
                    self.xvmax = None


        if self.ydata.size > 0:
            axis = graph.getXAxis(self.xaxis)
            if axis.autoscale:
                self.yvmin = self.ydata.min()
                self.yvmax = self.ydata.max()
            else:
                amin = axis.umin
                amax = axis.umax
#                print("try to find range for xaxis between ", amin, "and", amax)
#                print("xdata[0] is ", self.xdata[0], type(self.xdata[0]))
                a = numpy.where((self.xdata >= amin) & (self.xdata <= amax))
                if a[0].size > 0:
                    self.yvmin = self.ydata[a].min()
                    self.yvmax = self.ydata[a].max()
                else:
                    self.yvmin = None
                    self.yvmax = None

#        print self.xvmin, self.xvmax, self.yvmin, self.yvmax

    #---------------------------------------------------------------------------
    def _findRange(self):
        """ Find the minimum and maximum data values for the data """

        if self.xdata.size > 0:
            self.xmin = self.xdata.min()
            self.xmax = self.xdata.max()
        if self.ydata.size > 0:
            # Careful if there is a nan in the array!  Gives wrong result
#            self.ymin = self.ydata.min()
#            self.ymax = self.ydata.max()
#            print "=== ", self.ymin, self.ymax
            self.ymin = min(self.ydata)
            self.ymax = max(self.ydata)
#            print "--- ", self.ymin, self.ymax


    #---------------------------------------------------------------------------
    def SetData(self, x, y, w=None):
        """
        Convert the given list of x and y data values
        to a numpy array, and save
        """

        if x is None or y is None: return

        if isinstance(x[0], datetime.datetime):
            self.xdata = numpy.array(date2num(x))
            self.xdatatype = DATE
        else:
            self.xdata = numpy.array(x)
            self.xdatatype = FLOAT

        if isinstance(y[0], datetime.datetime):
            self.ydata = numpy.array(date2num(y))
            self.ydatatype = DATE
        else:
            self.ydata = numpy.array(y)
            self.ydatatype = FLOAT

        if w is None:
            self.weights = numpy.zeros((len(x)), int)
        else:
            self.weights = numpy.array(w)

        self._findRange()

    #---------------------------------------------------------------------------
    def SetAxis(self, axis):
        """ Set the axis that this dataset is mapped to """

        if axis.isXAxis():
            self.xaxis = axis.id
        if axis.isYAxis():
            self.yaxis = axis.id

    #---------------------------------------------------------------------------
    def SetWeights(self, wt):
        """ List of weight values for each data point.
            The length of wt should match that of xdata and ydata.
        """

        self.weights = numpy.array(wt)

    #---------------------------------------------------------------------------
    def SetStyle(self, style):
        """ Set the default style class for the entire dataset """

        self.style = style
        self.styles[0] = (0, style)

    #---------------------------------------------------------------------------
    def SetWeightStyle(self, wt, style):
        """ Set the style class for points matching a weight value """

        self.styles.append((wt, style))

    #---------------------------------------------------------------------------
    def ShowDatasetStyleDialog(self, graph):
        """ Show the popup dialog for editing style attributes """

        dlg = StyleDialog(graph, -1, "Edit Attributes", size=(350, 800),
                         #style=wx.CAPTION | wx.SYSTEM_MENU | wx.THICK_FRAME,
                         style=wx.DEFAULT_DIALOG_STYLE, # & ~wx.CLOSE_BOX,
                         dataset=self,
                         )
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        dlg.ShowModal()

        dlg.Destroy()
