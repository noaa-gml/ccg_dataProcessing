
from PyQt4 import QtGui, QtCore
import datetime
import math
from numpy import arange, where

from dateutil.rrule import rrule, YEARLY, MONTHLY, WEEKLY, DAILY, HOURLY, MINUTELY, SECONDLY
from dateutil.relativedelta import relativedelta

#from dataset import num2date, date2num, DATE
from dataset import DATE
from title import Title
from font import Font
from pen import Pen

import text


TIC_NONE = 0
TIC_IN = 1
TIC_OUT = 2
TIC_IN_OUT = 3


#####################################################################3333
class Axis:
    """ Class for handling a graph axis.  """

    def __init__(self, type, id, scale="linear"):

        # General axis parameters
        self.autoscale = 1
        self.type = type	# Should be 'x' or 'y'
        self.scale_type = scale	# Should be 'linear' or 'date'
        self.id = id
        self.round_endpoints = 1
        self.min = 0		# value at left end of axis
        self.max = 1.0		# value at right end of axis
        self.umin = None        #user specified value for axis min
        self.umax = None	# user specified value for axis max
        self.ratio = 1.0
        self.has_data = 0
        self.label_width = 0	# ???
        self.location = ""	# ???
        self.x1 = 0		# location of left end of axis
        self.x2 = 0		# location of right end of axis
        self.y1 = 0		# location of bottom of axis
        self.y2 = 0		# location of top of axis
        self.height = 0
        self.width = 0
        self.axis_spacing = 15
        self.zoomstack = []
        self.lineWidth = 1
	self.label_spacing = 8  # spacing between leftmost character of y tic label and title

	# Whether to round off limits of axis to nice tic marks (exact=False)
	# or use exactly what user wants (exact = true)
	self.exact = False
	self.set_tics = False		# if true, calc nice tic values to fit inside axis min, max

        # Axis Origin Parameters (draw a grid line where axis value=0)
        self.show_origin = 1
        self.origin_width = 1
        self.origin_color = QtGui.QColor(168, 168, 168)

        # Axis Tic Parameters
        self.ticInterval = 0.2
        self.uticInterval = 0.2
        self.subticDensity = 4
        self.usubticDensity = 4
        self.ticType = TIC_IN
        self.autoTics = 1	# ??? not used
#        self.ticColor = wx.BLACK
        self.ticLength = 8
        self.subticLength = 4
        self.color = QtCore.Qt.black
        self.default_numtics = 5

        # Tic Label Parameters
        self.centerLabels = 0	# labels are centered between tics (not implemented)
        self.show_labels = 1
        self.label_margin = 2
        self.labelFormat = "%g"
        self.supressEndLabels = 0
#        self.font = wx.Font(10, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	self.font = Font()  # set axis label font to default
        self.labelColor = QtCore.Qt.black
	self.labelType = "auto"	# ??? not used
	self.labelDateUseYear = 1

	# Grid parameters
	self.show_grid = 0
	self.show_subgrid = 0
        self.grid_pen = Pen(QtGui.QColor(200, 200, 200))
        self.subgrid_pen = Pen(QtGui.QColor(200, 200, 200))

        # Axis Title parameters
        self.title = Title()

	# pen for drawing axis and tics
        self.pen = Pen(self.color, self.lineWidth)
#        self.pen.SetCap(wx.CAP_BUTT)
 #       self.pen.SetJoin(wx.JOIN_MITER)

        if not (self.isXAxis() or self.isYAxis()):
            raise ValueError, str(type) + ': illegal axis specification'

    #-----------------------------------------------------------------------------
    def SetTitle(self, title):
	""" Set the text for the axis title """

        self.title.text = title
                
    #-----------------------------------------------------------------------------
    def setLabelFormat(self, format):

	self.labelFormat = format

    #-----------------------------------------------------------------------------
    def setAxisLineWidth(self, linewidth):

	self.lineWidth = linewidth
#        self.pen = wx.Pen(self.color, self.lineWidth, wx.SOLID)
        self.pen = Pen(self.color, self.lineWidth)

    #-----------------------------------------------------------------------------
    def setSize(self, graph, qp):
	""" Calculate and save the width and height of the axis.
	    The size of an axis depends on the labels and title.
	 """

        w = self._get_width(graph, qp)
        self.width = w

        h = self._get_height(graph, qp)
        self.height = h

    #-----------------------------------------------------------------------------
    def setScaleType(self, type):
	good_types = ["linear", "date"]

	if type.lower() in good_types:
		self.scale_type = type.lower()
	else:
            raise ValueError, str(type) + ': illegal scale type specification'

	print "scale type is ", self.scale_type
	
    #-----------------------------------------------------------------------------
    def _get_width(self, graph, qp):
        """ Get the width of a y axis.  

        This includes:
          - width of tic marks if they point out from graph
	  - label margin between axis line and tic labels
          - the width of the longest tic label, 
          - the height of title (since title is rotated 90 degrees)
          - spacing between title and next axis

	  - also if a secondary axis, include tic in length
        """

	w = 0
        if self.isYAxis():
            if self.ticType == TIC_OUT or self.ticType == TIC_IN_OUT:
                w += self.ticLength

	    if self.id > 0 and (self.ticType==TIC_IN or self.ticType == TIC_IN_OUT):
		w += self.ticLength

            w += self.label_margin

            if self.show_labels:
                qp.setFont(self.font.qtFont())
		vals = self._getMajorTicVals()
                width = 0
                for val in vals:
                    s = self.labelFormat % val 
                    (a, b) = text.getTextExtent(qp, s)
                    if (a > width):
                        width = a

#		width = (int(width/10)+1)*10
                w += width

	    # add height of axis title
	    (a,b) = self.title.getSize()
	    w += b

            w += self.axis_spacing

        return w

    #-----------------------------------------------------------------------------
    def _get_height(self, graph, qp):
        """ Get the height of an x axis.  

        This includes:
	  - length of tic marks if they point out from graph
          - label margin between axis line and tic labels
          - the height of the tic labels, 
          - the height of the title
	  - spacing between title and next axis 
	"""
	h = 0
        if self.isXAxis():
            if self.ticType == TIC_OUT or self.ticType == TIC_IN_OUT:
                h += self.ticLength

	    if self.id > 0 and (self.ticType==TIC_IN or self.ticType == TIC_IN_OUT):
		h += self.ticLength

            h += self.label_margin

            if self.show_labels:
                qp.setFont(self.font.qtFont())
                h += text.getCharHeight(qp)


#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		vals = self._getMajorTicVals()
                if self.scale_type == "linear":
                    s = self.labelFormat % vals[0] 

                elif self.scale_type == "date":
		    s = self._get_date_format(vals[0])
#		print "s is ", s
		if "\n" in s: 
		    h += text.getCharHeight()
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	    (w, h1) = self.title.getSize()
	    h += h1

#            h += self.axis_spacing

        return h

    #-----------------------------------------------------------------------------
    def _set_location(self, graph):
        """ Set the end point locations of the axis
        For multiple axes, the location depends on the axes before it.
	"""

        if self.isXAxis():
            # Add up the heights of all the x axes with an id lower than this one,
            # and where the id has the same even or odd value
            h = 0
            even_odd = self.id % 2
            for axis in graph.axes:
                if axis.isXAxis() and axis.id % 2 == even_odd and axis.id < self.id:
                    h += axis.height
		    if self.id > 0 and (self.ticType == TIC_IN or self.ticType == TIC_IN_OUT):
			h += self.ticLength

            if even_odd == 0:
                self.x1 = graph.xleft
                self.x2 = graph.xright
                self.y1 = graph.ybottom + h
                self.y2 = graph.ybottom + h
            else:
                self.x1 = graph.xleft
                self.x2 = graph.xright
                self.y1 = graph.ytop - h
                self.y2 = graph.ytop - h

	    self.title.rotated = False
#	    self.default_numtics = int((self.x2-self.x1)/50)
#	    print self.x2, self.x1
#	    print "default numtics is ", self.default_numtics

        if self.isYAxis():
            # Add up the widths of all the y axes with an id lower than this one,
            # and where the id has the same even or odd value
            w = 0
            even_odd = self.id % 2
            for axis in graph.axes:
                if axis.isYAxis() and axis.id % 2 == even_odd and axis.id < self.id:
                    w += axis.width
#		    if self.id > 0: w += self.axis_spacing
		    if self.id > 0 and (self.ticType == TIC_IN or self.ticType == TIC_IN_OUT):
			w += self.ticLength

#	    print "-----", axis.id, axis.id/2, (axis.id/2)*self.axis_spacing

            if even_odd == 0:
                self.x1 = graph.xleft - w
                self.x2 = graph.xleft - w
                self.y1 = graph.ybottom
                self.y2 = graph.ytop
		self.title.rot_angle = 90
            else:
                self.x1 = graph.xright + w
                self.x2 = graph.xright + w
                self.y1 = graph.ybottom
                self.y2 = graph.ytop
		self.title.rot_angle = -90

	    self.title.rotated = True

    #-----------------------------------------------------------------------------
    def _set_ratio(self):
        """ Set the pixels per user unit ratio value for the axis 
	Used by the graph UserToPixel() and PixelToUser() routines
	"""
        if self.isXAxis():
	    self.ratio = (self.x2 - self.x1) / (self.max - self.min)
        else:
            self.ratio = (self.y1 - self.y2) / (self.max - self.min)

    #-----------------------------------------------------------------------------
    # Draw the axis
    def draw(self, graph, qp):
	""" Draw the axis 
	The setLimits() and setSize() methods have already been called from graph.py
	"""

	# now that we know the width of the axis, recalc the tic marks to make sure
	# the major tic labels don't overwrite each other.  i.e. make the major
	# tics far enough apart so the labels will fit
#	if self.isXAxis():
#		self._set_xaxis_tics()

	self._set_location(graph)
	self._set_ratio()

        self._draw_axis(graph, qp)
	self._draw_subgrid(graph, qp)
	self._draw_grid(graph, qp)
	self._draw_origin(graph, qp)
	self._draw_tics(graph, qp)
	self._draw_labels(graph, qp)
	self._title_axis(graph, qp)

    #-----------------------------------------------------------------------------
    def _draw_axis(self, graph, qp):
        """ Draw the axis line.  No tics or labels """

        qp.setPen(self.pen.qtPen())
        qp.drawLine(self.x1, self.y1, self.x2, self.y2)

    #-----------------------------------------------------------------------------
    def _draw_origin(self, graph, qp):
        """ Draw a grid line where axis value = 0 """
        if not self.show_origin:
            return

        if self.max > 0 and self.min < 0:
            self.originPen = Pen(self.origin_color, self.origin_width)
            qp.setPen(self.originPen.qtPen())

            if self.isXAxis():
                xp = graph.UserToPixelX(0.0, self)
                xp2 = xp
                yp  = graph.ytop + 1
                yp2 = graph.ybottom

            if self.isYAxis():
                yp = graph.UserToPixelY(0.0, self)
                yp2 = yp
                xp  = graph.xleft + 1
                xp2 = graph.xright

            qp.drawLine(xp, yp, xp2, yp2)


    #-----------------------------------------------------------------------------
    def _getMajorTicVals(self):
	""" Get array of values where major tics will be drawn. """

	if self.scale_type == "date":
            a = list(self.rrule)
            vals = date2num(a)
	else:
            if self.supressEndLabels:
                a = arange(self.ticmin+self.ticInterval, self.ticmax, self.ticInterval)
            else:
                a = arange(self.ticmin, self.ticmax + self.ticInterval, self.ticInterval)
            vals = a[ where((a>=self.min) & (a<=self.max)) ]

            # check on values not quite 0, make them 0 so label is correct
            b = where(abs(vals)<1e-15)
            vals[b] = 0

	return vals

    #-----------------------------------------------------------------------------
    def _getMinorTicVals(self):
	""" Get array of values where minor tics will be drawn """

	if self.scale_type == "date":
            a = list(self.minor_rrule)
            vals = date2num(a)
	else:
            a = arange(self.ticmin, self.ticmax, self.ticInterval/self.subticDensity)
            vals = a[ where((a>self.min) & (a<self.max)) ]

	return vals

    #-----------------------------------------------------------------------------
    def _draw_tics(self, graph, qp):
        """ Draw the major and minor tic marks """

        if self.ticType == TIC_NONE:
            return

        qp.setPen(self.pen.qtPen())

        # Do subtics first
	vals = self._getMinorTicVals()
	list = self._calc_tics(graph, vals, self.subticLength)
        qp.drawLines(list)

        # Do major tics
	vals = self._getMajorTicVals()
	list = self._calc_tics(graph, vals, self.ticLength)
        qp.drawLines(list)


    #-----------------------------------------------------------------------------
    def _calc_tics(self, graph, vals, ticLength):
	""" Calculate locations of tic marks """

	list = []
        for val in vals:
            if self.isXAxis():
                xp = graph.UserToPixelX(val, self)
                xp2 = xp
                yp = self.y1
                if self.id % 2 == 0:
                    if self.ticType == TIC_IN:
                        yp2 = yp - ticLength
                    elif self.ticType == TIC_IN_OUT:
                        yp = self.y1 + ticLength
                        yp2 = self.y1 - ticLength
                    else:
                        yp2 = yp + ticLength
                else:
                    if self.ticType == TIC_IN:
                        yp2 = yp + ticLength
                    elif self.ticType == TIC_IN_OUT:
                        yp = self.y1 + ticLength
                        yp2 = self.y1 - ticLength
                    else:
                        yp2 = yp - ticLength

            if self.isYAxis():
                yp = graph.UserToPixelY(val, self)
                yp2 = yp
                xp = self.x1
                if self.id % 2 == 0:
                    if self.ticType == TIC_IN:
                        xp2 = xp + ticLength
                    elif self.ticType == TIC_IN_OUT:
                        xp = self.x1 + ticLength
                        xp2 = self.x1 - ticLength
                    else:
                        xp2 = xp - ticLength
                else:
                    if self.ticType == TIC_IN:
                        xp2 = xp - ticLength
                    elif self.ticType == TIC_IN_OUT:
                        xp = self.x1 + ticLength
                        xp2 = self.x1 - ticLength
                    else:
                        xp2 = xp + ticLength

            list.append(QtCore.QLine(xp, yp, xp2, yp2))

	return list

        
    #-----------------------------------------------------------------------------
    def _draw_subgrid(self, graph, qp):
        """ Draw the sub grid lines (grid lines at minor tic intervals) """

	if not self.show_subgrid: return

        # Do subgrid
        qp.setPen(self.subgrid_pen.qtPen())
	vals = self._getMinorTicVals()
	linelist = self._getGridLines(graph, vals)

        qp.drawLines(linelist)


    #-----------------------------------------------------------------------------
    def _draw_grid(self, graph, qp):
        """ Draw the grid lines (grid lines at major tic intervals) """

	if not self.show_grid: return

        qp.setPen(self.grid_pen.qtPen())
	vals = self._getMajorTicVals()
	linelist = self._getGridLines(graph, vals)

        qt.drawLines(linelist)

    #-----------------------------------------------------------------------------
    def _getGridLines(self, graph, vals):

        linelist = []
        for val in vals:
 	    if val <= self.min or val >= self.max: continue
            if self.isXAxis():
                xp = graph.UserToPixelX(val, self)
                xp2 = xp
                yp = graph.ytop + self.lineWidth
                yp2 = graph.ybottom - self.lineWidth
            else:
                yp = graph.UserToPixelY(val, self)
                yp2 = yp
                xp = graph.xleft + self.lineWidth
                xp2 = graph.xright - self.lineWidth

            linelist.append(QtCore.QLine(xp, yp, xp2, yp2))

	return linelist

    #-----------------------------------------------------------------------------
    def _draw_labels(self, graph, qp):
        """ Draw the major tic labels """

        if not self.show_labels:
            return

        qp.setFont (self.font.qtFont())
        qp.setPen(QtGui.QColor(self.labelColor))

	vals = self._getMajorTicVals()

        xright = 0
        for val in vals:

            if self.scale_type == "linear":
                s = self.labelFormat % val 

            elif self.scale_type == "date":
		s = self._get_date_format(val)


            (w, h) = text.getTextExtent(qp, s)
	    h = text.getTextAscent(qp)
            if self.isXAxis():
                xp = graph.UserToPixelX(val, self)
                xp -= w/2

                # if label position overlaps with previous label, skip it
                if xp <= xright: continue

                # save right edge of last label drawn
                xright = xp + w + 2*self.label_margin

		# bottom xaxis
                if self.id % 2 == 0:
                    yp = self.y1 + self.label_margin + h
                    if self.ticType == TIC_OUT or self.ticType == TIC_IN_OUT:
                        yp += self.ticLength

		# top xaxis
                else:
                    yp = self.y1 - self.label_margin - h
                    if self.ticType == TIC_OUT or self.ticType == TIC_IN_OUT:
                        yp -= self.ticLength

            else:
                yp = graph.UserToPixelY(val, self)
		yp += h/2

		# left yaxis
                if self.id % 2 == 0:
                    xp = self.x1 - w - self.label_margin
                    if self.ticType == TIC_OUT or self.ticType == TIC_IN_OUT:
                        xp -= self.ticLength

		# right yaxis
                else:
                    xp = self.x1 + self.label_margin
                    if self.ticType == TIC_OUT or self.ticType == TIC_IN_OUT:
                        xp += self.ticLength

            qp.drawText(xp, yp, s)
                        
    #-----------------------------------------------------------------------------
    def _get_date_format(self, val):
	""" Get the correct format string for a date label.  """

	fval = num2date(val)

	# if labelformat is '%g', use a date format based on the label frequency instead
	if self.labelFormat == "%g" or self.set_tics:
            freq = self.rrule._freq
            if ( freq == YEARLY ):
                s = "%d" % fval.year
            elif ( freq == MONTHLY ):
		if self.labelDateUseYear:
			s = fval.strftime("%b %Y")
		else:
			s = fval.strftime("%b")
            elif ( freq == WEEKLY ):
		if self.labelDateUseYear:
			s = fval.strftime("%b %d %Y")
		else:
			s = fval.strftime("%b %d")
            elif ( freq == DAILY ):
		if self.labelDateUseYear:
			s = fval.strftime("%b %d %Y")
		else:
			s = fval.strftime("%b %d")
            elif ( freq == HOURLY ):
		if self.labelDateUseYear:
			s = fval.strftime("%b %d %Y\n%H:%M:%S")
		else:
			s = fval.strftime("%b %d\n%H:%M:%S")
            elif ( freq == MINUTELY ):
		if self.labelDateUseYear:
			s = fval.strftime("%b %d %Y\n%H:%M:%S")
		else:
			s = fval.strftime("%b %d\n%H:%M:%S")
            elif ( freq == SECONDLY ):
		s = fval.strftime("%H:%M:%S")
            else:
                # error
                s = fval.strftime("%b %d %Y\n %H:%M:%S")

	else:
            s = fval.strftime(self.labelFormat)

	return s


    #-----------------------------------------------------------------------------
    def _title_axis(self, graph, qp):
        """ Draw the axis title. 
	y position of x axis title is relative to top of text 
	"""


        if self.isXAxis():

	    (w, h) = self.title.getSize()
            xp = (self.x2 - self.x1)/2 + self.x1 - w/2

            if self.id % 2 == 0:
		yp = self.y1 + self.height  - self.label_margin # + h
		# if additional axis, account for tic length in towards graph
	        if self.id > 0 and (self.ticType==TIC_IN or self.ticType == TIC_IN_OUT):
		    yp -= self.ticLength
            else:
		yp = self.y1 - self.height
		# if additional axis, account for tic length in towards graph
	        if self.id > 0 and (self.ticType==TIC_IN or self.ticType == TIC_IN_OUT):
		    yp += self.ticLength

        else:

	    (w, h) = self.title.getSize()
            yp = (graph.ybottom - graph.ytop)/2 + graph.ytop

            if self.id % 2 == 0:
                xp = self.x1 - self.width + self.axis_spacing + self.title.getAscent() - self.label_spacing
		# if additional axis, account for tic length in towards graph
	        if self.id > 0 and (self.ticType==TIC_IN or self.ticType == TIC_IN_OUT):
		    xp += self.ticLength
		yp += w/2
            else:
                xp = self.x1 + self.width - self.axis_spacing
		# if additional axis, account for tic length in towards graph
	        if self.id > 0 and (self.ticType==TIC_IN or self.ticType == TIC_IN_OUT):
		    xp -= self.ticLength
		yp -= w/2

	self.title.setLocation(xp, yp)
	self.title.draw(qp)


    #---------------------------------------------------------------------------
    # Apparently comes from the book 'Graphics Gems' by Andrew S. Glassner Academic Press, 1990
    def _NiceNum(self, val, round):

	if val == 0:
		expt = 0
		nice = 1.0
	else:
		expt = math.floor(math.log10(val))
		frac = val / (10.0 ** expt)
		if round:
		    if frac < 1.5: nice = 1.0
		    elif frac < 3.0: nice = 2.0
		    elif frac < 7.0: nice = 5.0
		    else: nice = 10.0
	 
		else:
		    if frac <= 1.0: nice = 1.0
		    elif frac <= 2.0: nice = 2.0
		    elif frac <= 5.0: nice = 5.0
		    else: nice = 10.0

        x = nice * (10.0 ** expt)
        return x

    #---------------------------------------------------------------------------
    def isXAxis(self):

        if self.type == "x":
            return 1
        else:
            return 0

    #---------------------------------------------------------------------------
    def isYAxis(self):

        if self.type == "y":
            return 1
        else:
            return 0

    #---------------------------------------------------------------------------
    def setLimits(self, graph):
        """ Set the minimum and maximum values for the axis """

        if self.autoscale:
            if len(graph.datasets) == 0:
#                if self.scale_type == "linear":
#			dmax = 1.0
#			dmin = 0.0
 #               if self.scale_type == "date":
#			a = datetime.datetime.today()
#			dmin = datetime.datetime(a.year, a.month, a.day, 0, 0, 0)
#			dmax = dmin + datetime.timedelta(days=1)
		dmax = 1.0
		dmin = 0.0
		self.scale_type = "linear"

            else:
                dmax = -999.99E15
                dmin = 999.99e15
                # Find datasets that use this axis
		# and find the miminum and maximum values of the points
                found = 0
                for dataset in graph.datasets:
                    if graph.showThisDataset(dataset):
#                    if not dataset.hidden and dataset.name not in graph.datasetShowList:
                        if self.isXAxis():
                            if dataset.xaxis == self.id:
				if dataset.xdatatype == DATE: self.scale_type = "date"
#                                if dataset.xmax > dmax: dmax = dataset.xmax
 #                               if dataset.xmin < dmin: dmin = dataset.xmin
                                if dataset.xvmax is not None:
					found = 1
					if dataset.xvmax > dmax: dmax = dataset.xvmax
                                if dataset.xvmin is not None:
					found = 1
					if dataset.xvmin < dmin: dmin = dataset.xvmin
                        if self.isYAxis():
                            if dataset.yaxis == self.id:
				if dataset.ydatatype == DATE: self.scale_type = "date"
#                                if dataset.ymax > dmax: dmax = dataset.ymax
 #                               if dataset.ymin < dmin: dmin = dataset.ymin
                                if dataset.yvmax is not None:
					found = 1
					if dataset.yvmax > dmax: dmax = dataset.yvmax
                                if dataset.yvmin is not None:
					found = 1
					if dataset.yvmin < dmin: dmin = dataset.yvmin


                if not found:
		    self.scale_type = "linear"
                    dmax = 1.0
                    dmin = 0.0


        else:
            dmin = self.umin
            dmax = self.umax
	    self.scale_type == "linear"
            for dataset in graph.datasets:
                if not dataset.hidden:
                    if self.isXAxis() and dataset.xaxis == self.id:
			    if dataset.xdatatype == DATE: self.scale_type = "date"
                    if self.isYAxis() and dataset.yaxis == self.id:
			    if dataset.ydatatype == DATE: self.scale_type = "date"

#	print "axis dmin, dmax", dmin, dmax


        if self.scale_type == "date":
            self.set_date_limits(dmin, dmax)
        else:
            self._set_linear_limits(dmin, dmax)


    #---------------------------------------------------------------------------
    def _set_linear_limits(self, dmin, dmax):
	"""
	set axis limits for linear scaling.
	Set:
		self.min
		self.max
		self.ticmin
		self.ticmax
		self.ticInterval
		self.subticDensity
	"""

        if self.exact:
            self.min = dmin
            self.max = dmax
            if self.set_tics:
                range = dmax - dmin
                range = self._NiceNum(range, 0)
                step = self._NiceNum(range/self.default_numtics, 1)
                self.ticmin = math.floor(dmin / step) * step
                self.ticmax = math.ceil(dmax / step) * step
                self.ticInterval = step
                self.subticDensity = self.CalcTicInterval2(self.ticmin, self.ticmax)
            else:
                self.ticmin = self.min
                self.ticmax = self.max

	else:
            range = dmax - dmin
            range = self._NiceNum(range, 0)
            step = self._NiceNum(range/self.default_numtics, 1)  #! should take into account graph width and label widths

            # Find the outer tick values. Add 0.0 to prevent getting -0.0. */
            self.min = math.floor(dmin / step) * step + 0.0
            self.max = math.ceil(dmax / step) * step + 0.0
            if self.max == self.min:
		self.max = self.min + step

            self.ticmin = self.min
            self.ticmax = self.max
            self.ticInterval = step
            self.subticDensity = self.CalcTicInterval2(self.min, self.max)

    #---------------------------------------------------------------------------
    def set_date_limits(self, dmin, dmax):
	"""
        This axis is in date units, so we need to find appropriate 
        minimum, maximum and tic locations that make sense for dates.

        The range is the difference between the maximum and minumum values
        expressed in decimal days
	"""

	self.min = dmin
	self.max = dmax

	# add one minute to max if min=max
	if self.min == self.max:
		self.max = self.min + 1.0/1440.0
	if not self.autoscale and not self.set_tics: return

        delta = relativedelta(num2date(self.max), num2date(self.min))
#        delta = relativedelta(self.max, self.min)

        numYears = (delta.years * 1.0)
        numMonths = (numYears * 12.0) + delta.months
        numDays = (numMonths * 31.0) + delta.days
        numHours = (numDays * 24.0) + delta.hours
        numMinutes = (numHours * 60.0) + delta.minutes
        numSeconds = (numMinutes * 60.0) + delta.seconds

        numticks = 5

        # freq = YEARLY
	minor_interval = 1
        interval = 1
        bymonth = 1
        bymonthday = 1
        byhour = 0
        byminute = 0
        bysecond = 0
        if ( numYears >= numticks ):
            freq = YEARLY
            minor_freq = YEARLY

	    # gives interval like 1, 5, 10, 20, 50, 100, 200, 500, 1000 ...
            interval = int(self._NiceNum(numYears/self.default_numtics, 1))
	    if interval < 10: minor_interval = 1
	    else: minor_interval = interval/5

        elif ( numMonths >= numticks ):     # 5 months to 5 years
            freq = MONTHLY
            minor_freq = MONTHLY
            bymonth = range(1, 13)
            if ( (0 <= numMonths) and (numMonths <= 14) ):
                interval = 1      # show every month
                minor_interval = 1      # show every month
		minor_freq = DAILY	# not working yet, probably need bymonthday... for minor
		minor_interval = 7
            elif ( (15 <= numMonths) and (numMonths <= 29) ):
                interval = 3      # show every 3 months
                minor_interval = 1      # show every month
            elif ( (30 <= numMonths) and (numMonths <= 44) ):
                interval = 4      # show every 4 months
                minor_interval = 1      # show every month
            else:   # 45 <= numMonths <= 59
                interval = 6      # show every 6 months
                minor_interval = 1      # show every month

        elif ( numDays >= numticks ):       # 5 days to 5 months
            freq = DAILY
            minor_freq = DAILY
            bymonth = None
            bymonthday = range(1, 32)
            if ( (0 <= numDays) and (numDays <= 9) ):
                interval = 1      # show every day
                minor_interval = 1
            elif ( (10 <= numDays) and (numDays <= 19) ):
                interval = 2      # show every 2 days
                minor_interval = 1
            elif ( (20 <= numDays) and (numDays <= 49) ):
                interval = 3      # show every 3 days
                minor_interval = 1
            elif ( (50 <= numDays) and (numDays <= 99) ):
                interval = 7      # show every 1 week
                minor_interval = 1
            else:   # 100 <= numDays <= ~150
                interval = 14     # show every 2 weeks
                minor_interval = 2

        elif ( numHours >= numticks ):  # 5 hours to 5 days
            freq = HOURLY
            minor_freq = HOURLY
            bymonth = None
            bymonthday = None
            byhour = range(0, 24)      # show every hour
            if ( (0 <= numHours) and (numHours <= 7) ):
                interval = 1      # show every hour
                minor_interval = 1
            elif ( (8 <= numHours) and (numHours <= 14) ):
                interval = 2      # show every 2 hours
                minor_interval = 1
            elif ( (15 <= numHours) and (numHours <= 30) ):
                interval = 4      # show every 4 hours
                minor_interval = 2
            elif ( (30 <= numHours) and (numHours <= 45) ):
                interval = 6      # show every 3 hours
                minor_interval = 1
            elif ( (45 <= numHours) and (numHours <= 68) ):
                interval = 8      # show every 4 hours
                minor_interval = 2
            elif ( (68 <= numHours) and (numHours <= 90) ):
                interval = 12      # show every 6 hours
                minor_interval = 2
            else:   # 90 <= numHours <= 120
                interval = 12     # show every 12 hours
                minor_interval = 3

        elif ( numMinutes >= numticks ): # 5 minutes to 5 hours
            freq = MINUTELY
            minor_freq = MINUTELY
            bymonth = None
            bymonthday = None
            byhour = None
            byminute = range(0, 60)
	    if 0<=numMinutes and numMinutes <= 10:
		interval = 1
		minor_interval = 1
	    elif 11 <= numMinutes and numMinutes <= 20:
		interval = 2
		minor_interval = 1
	    elif 21 <= numMinutes and numMinutes <= 60:
		interval = 5
		minor_interval = 1
	    elif 61 <= numMinutes and numMinutes <= 90:
		interval = 10
		minor_interval = 2
	    elif 91 <= numMinutes and numMinutes <= 120:
		interval = 15
		minor_interval = 5
	    elif 121 <= numMinutes and numMinutes <= 300:
		interval = 30
		minor_interval = 5

            # end if

        elif ( numSeconds >= numticks ):   # 5 seconds to 5 minutes
            freq = SECONDLY
            minor_freq = SECONDLY
            bymonth = None
            bymonthday = None
            byhour = None
            byminute = None
            bysecond = range(0, 60)
	    if 0<=numSeconds and numSeconds <= 10:
		interval = 1
		minor_interval = 1
	    elif 11<=numSeconds and numSeconds <= 20:
		interval = 2
		minor_interval = 1
	    elif 21<=numSeconds and numSeconds <= 60:
		interval = 5
		minor_interval = 1
	    elif 61<=numSeconds and numSeconds <= 90:
		interval = 10
		minor_interval = 2
	    elif 91<=numSeconds and numSeconds <= 120:
		interval = 15
		minor_interval = 5
	    elif 120<=numSeconds and numSeconds <= 300:
		interval = 30
		minor_interval = 5
            # end if
        else:
            # do what?
            #   microseconds as floats, but floats from what reference point?
            freq = SECONDLY
            minor_freq = SECONDLY
            bymonth = None
            bymonthday = None
            byhour = None
            byminute = None
            bysecond = range(0, 60)
	    interval = 1
	    minor_interval = 1

#	print freq, interval, bymonth, bymonthday, byhour, byminute, bysecond

	# round off axis min, max to next major tic
# skip for now, not working properly 
#	print "self.min, self.max = ",self.min, self.max, interval, minor_interval

#	if interval != minor_interval:
#		self.min = self.tstround_date(self.min, freq, minor_interval, 0)
#		self.max = self.tstround_date(self.max, freq, minor_interval, 1)
#	self.min = self.round_date(self.min, freq, 0)
#	self.max = self.round_date(self.max, freq, 1)
#	print "self.min, self.max after rounding = ",self.min, self.max


	self.rrule = rrule( freq, interval=interval,          \
                              dtstart=num2date(self.min), until=num2date(self.max),               \
                              bymonth=bymonth, bymonthday=bymonthday, \
                              byhour=byhour, byminute = byminute,     \
                              bysecond=bysecond )

	self.minor_rrule = rrule( minor_freq, interval=minor_interval,          \
                              dtstart=num2date(self.min), until=num2date(self.max),               \
                              bymonth=bymonth, bymonthday=bymonthday, \
                              byhour=byhour, byminute = byminute,     \
                              bysecond=bysecond )

	vals = self._getMajorTicVals()
#	print vals
	self.ticInterval = vals[1]-vals[0]
	
    #---------------------------------------------------------------------------
    def tstround_date(self, val, freq, minor_interval, dir):

#	print "freq, minor, dir", freq, minor_interval, dir

	if freq == YEARLY:
		return val
	elif freq == MONTHLY:
		return val
	elif freq == DAILY:
		factor = 1.0
	elif freq == HOURLY:
		factor = 24.0
	elif freq == MINUTELY:
		factor = 1440.0
	else:
		return val

	a = minor_interval/factor
	if dir == 0:
		newval = int(val/a) * a
	else:
		newval = int(val/a) * a + a

	return newval

    #---------------------------------------------------------------------------
    def round_date(self, val, freq, dir):

	dt = num2date(val)	

	if freq == YEARLY:
		newdt = datetime.datetime(dt.year, 1, 1, 0, 0, 0)
	elif freq == MONTHLY:
		newdt = datetime.datetime(dt.year, dt.month, 1, 0, 0, 0)
	elif freq == DAILY:
		newdt = datetime.datetime(dt.year, dt.month, dt.day, 0, 0, 0)
	elif freq == HOURLY:
		newdt = datetime.datetime(dt.year, dt.month, dt.day, dt.hour, 0, 0)
	elif freq == MINUTELY:
		newdt = datetime.datetime(dt.year, dt.month, dt.day, dt.hour, dt.minute, 0)
	else:
		newdt = dt


	if dir == 1:
		if freq == YEARLY:
			newdt = datetime.datetime(dt.year+1, 1, 1, 0, 0, 0)
		elif freq == MONTHLY:
			if dt.month == 12: 
				m = 1 
				y = dt.year + 1
			else:
				m = dt.month + 1
				y = dt.year
			newdt = datetime.datetime(y, m, 1, 0, 0, 0)
		elif freq == DAILY:
			td = datetime.timedelta(days=1)
			newdt = newdt + td
		elif freq == HOURLY:
			td = datetime.timedelta(seconds = 3600)
			newdt = newdt + td
		elif freq == MINUTELY:
			td = datetime.timedelta(seconds = 60)
			newdt = newdt + td
		else:
			td = datetime.timedelta(seconds = 1)
			newdt = newdt + td

#	print newdt
	newdt = date2num(newdt)

	return newdt

    #---------------------------------------------------------------------------
    # Calculate the number of subtics to use.
    def CalcTicInterval2(self, min, max):

        nt = self.default_numtics
        if nt >= 8: nt = 10
        if nt > 5 and nt <= 7: nt = 5
        if nt == 3 or nt == 4: nt = 2
        if nt < 1: nt = 1
        nst = 5

        mag = math.log10(math.fabs(max - min))
        flr = math.floor(mag)
        sizeticratio = (10**(mag-flr)) / nt

        d = 1.0

        while(1):
            if (sizeticratio > 2.857*d):
                mult = 5
                break
            if (sizeticratio > 1.333*d):
                mult = 2
                break
            if (sizeticratio > 0.6666*d):
                mult = 1
                break
            d /= 10.0

        if mult == 1:
            if nst >= 10: nst = 10
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

    #---------------------------------------------------------------------------
    def setAxisDateRange(self, min, max, interval=None, majorfreq=None, minor=None, minorfreq=None):

        if not isinstance(min, datetime.datetime) and not isinstance(max, datetime.datetime):
            print "In setDateAxisRange, min and max values must both be datetime objects."
            print "Switching to linear scale"
            self.setAxisRange(min, max, interval, minor, True)
	else:

            self.umin = date2num(min)
            self.umax = date2num(max)
            self.exact = True
            self.scale_type = "date"
            self.autoscale = 0
            if interval:
                self.set_tics = False

                self.rrule = rrule(majorfreq, interval=interval, dtstart=min, until=max)
                self.minor_rrule = rrule( minorfreq, interval=minor, dtstart=min, until=max)
            else:
                self.set_tics = True


    #---------------------------------------------------------------------------
    def setAxisRange(self, min, max, step, minor, exact = False):

	self.umin = float(min)
	self.umax = float(max)
	self.autoscale = 0
	self.ticInterval = float(step)
	self.subticDensity = float(minor)
	self.exact = exact
	self.set_tics = False

    #---------------------------------------------------------------------------
    def adjustAxisRange(self, val1, val2):

	self.umin = self.min + float(val1)
	self.umax = self.max + float(val2)
        self.autoscale = 0
        self.exact = True
	self.set_tics = True

    #---------------------------------------------------------------------------
    def setAutoscale(self):
        """ reset axis to autoscaling """

        self.autoscale = 1
        self.exact = False
        self.set_tics = False

