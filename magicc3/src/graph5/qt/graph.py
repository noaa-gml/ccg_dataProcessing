#
# Graph widget - Qt version

from PyQt4 import QtGui, QtCore
#import datetime
#import cPickle

from numpy import around, int32, clip

from axis import *
from crosshair import *
from legend import *
#from printout import *
#from graph_menu import *
#from text import *
#from style import *
from dataset import Dataset   # , date2num
#import prefs
#from pen import Pen

from title import Title

#####################################################################3333
class Graph(QtGui.QWidget):
    """ A scientific graphing class """

    def __init__(self, parent):
        super(Graph, self).__init__(parent)

	self.version = "2.1"
	self.initUI()

    #---------------------------------------------------------------------------
    def initUI(self):

	palette = QtGui.QPalette()

	# Size and location 
	self.auto_size = 1
	self.plot_height = 0
	self.plot_width = 0
	self.margin = 10
	self.plotAreaColor = QtGui.QColor(255,255,255)
#	self.backgroundColor = palette.color(QtGui.QPalette.Window)
	self.xleft = 0
	self.xright = 0
	self.ytop = 0
	self.ybottom = 0
	self.draw_frame = True
	self.show_offscale_points = False

	# User specified corners of the plotting area
	# Value of 0 means auto fit into width
	# value < 0 means that far from the edge
	# value > 0 means that far from origin
	self.xl = 0
	self.xr = 0
	self.yt = 0
	self.yb = 0

	# datasets
	self.datasets = []
	self.datasetShowList = []

	# crosshair
	self.crosshair = Crosshair(self)
	self.crosshair_on = False
#	self.rubberband = QtGui.QRubberBand(QtGui.QRubberBand.Rectangle, self)
	self.rubberbandv = QtGui.QRubberBand(QtGui.QRubberBand.Line, self)
	self.rubberbandh = QtGui.QRubberBand(QtGui.QRubberBand.Line, self)
	self.show_popup = True

        # Zoom stuff
        self.zoomEnabled = False
        self.dragEnabled = False
        self.selectionEnabled = False
        self.startx = 0
        self.starty = 0
        self.lastx = 0
        self.lasty = 0




	# Axes
	self.axes = []
	self.xaxisId = -1
	self.yaxisId = -1
	# Add default x axis and y axis
	self.addXAxis("this is the x axis title")
	self.addYAxis("this is the y axis title")

        # Add a title and legend
        self.title = Title()
        self.title.margin = 2
	self.legend = Legend()
	self.legend.title.text = ""

        # colors for createdataset
        self.colors = [
                (255,0,0),      # red
                (0,0,255),      # blue
                (0,205,0),      # green3
                (255,0,255),    # magenta
                (0,209,209),    # dark turquoise
                (238,238,0),    # yellow2
                (30,144,255),   # dodger blue
                (139,89,43),    # tan4
                (255,140,0),    # dark orange
                (155,48,255),   # purple 1
                (32,178,168),   # light sea green
        ]
        self.num_colors = len(self.colors)


	self.setMinimumSize(500, 500)

	self.label = CrosshairPopup(self)
	self.label.setText("this is a test")
	self.label.hide()

    #---------------------------------------------------------------------------
    def paintEvent(self, e):

	# Get current size of widget
	size = self.size()
	self.width = size.width()
	self.height = size.height()
#	print self.width, self.height

	# redraw the graph
	self._draw()

	# draw the grap image to the widget
        qp = QtGui.QPainter(self)
	qp.drawImage(QtCore.QRect(QtCore.QPoint(0,0), size), self.image)

    #---------------------------------------------------------------------------
    def _drawtest(self, qp):

	color = QtGui.QColor(0, 0, 0)
        color.setNamedColor('#d4d4d4')
        qp.setPen(color)

        qp.setBrush(QtGui.QColor(200, 0, 0))
        qp.drawRect(10, 15, 90, 60)

        qp.setBrush(QtGui.QColor(255, 80, 0, 160))
        qp.drawRect(130, 15, 90, 60)

        qp.setBrush(QtGui.QColor(25, 0, 90, 200))
        qp.drawRect(250, 15, 90, 60)

    ############################################################################
    # Routines dealing with drawing the graph
    #---------------------------------------------------------------------------
    def _draw(self):
        """ Draw the graph. """

	print "draw graph"

	# create an image to draw into
	self.image = QtGui.QImage(self.width, self.height, QtGui.QImage.Format_ARGB32_Premultiplied)

	qp = QtGui.QPainter()
	qp.begin(self.image)

	for dataset in self.datasets:
		dataset.findViewableRange(self)

        # Find and set the maximum and minimum values for each axis 
        # Set the height and width of axis labeling
	for axis in self.axes:
		axis.setLimits(self)
		axis.setSize(self, qp)

	self.legend.setSize(self, qp)

	self.set_graph_height()
	self.set_graph_width()

	# Fill plotting area with plot area color
	if self.draw_frame:
		qp.setPen(QtGui.QColor(0,0,0))
	else:
		qp.setPen(QtGui.QColor(0,0,0,0))
	qp.setBrush(QtGui.QColor(self.plotAreaColor))
	qp.drawRect(self.xleft, self.ytop, self.plot_width, self.plot_height)

	for axis in self.axes:
		axis.draw(self, qp)


	# graph legend
	self.legend.draw(self, qp)

	# Draw only datasets that are not hidden.
	# If datasetShowList is empty, draw all datasets,
	# else draw only those in the list
	if len(self.datasetShowList):
		for name in self.datasetShowList:
			dataset = self.getDataset(name)
			dataset.draw(self, qp)
	else:
		for dataset in self.datasets:
			dataset.draw(self, qp)


	qp.end()


   ############################################################################
    # Routines dealing with axes of the graph
    #---------------------------------------------------------------------------
    def addXAxis(self, title):
	""" Add an X axis to the graph. """
	id = self.xaxisId + 1
	axis = Axis("x", id)
	axis.title.text = title
	self.axes.append(axis)
	self.xaxisId += 1
	return axis

    #---------------------------------------------------------------------------
    def addYAxis(self, title):
	""" Add a Y axis to the graph. """
	id = self.yaxisId + 1
	axis = Axis("y", id)
	axis.title.text = title
	self.axes.append(axis)
	self.yaxisId += 1
	return axis

    ############################################################################
    # Utilities
    #---------------------------------------------------------------------------
    def PixelToUserX(self, x, axis):
	""" Convert pixel X coordinate on graph to user data value """
	xp = (x-self.xleft) / axis.ratio + axis.min
	return xp

    #---------------------------------------------------------------------------
    def PixelToUserY(self, y, axis):
	""" Convert pixel Y coordinate on graph to user data value """
	yp = (self.ybottom - y) / axis.ratio + axis.min
	return yp

    #---------------------------------------------------------------------------
    # clip min and max values to avoid int overflow later when passing pts into dc.draw methods
    def UserToPixelX(self, x, axis):
	""" Convert user X coordinate to pixel location on graph """
	a = around((x - axis.min) * axis.ratio + self.xleft)
	a = clip(a, -1000, self.width+1000)
	return a.astype(int32)

    #---------------------------------------------------------------------------
    # clip min and max values to avoid int overflow later when passing pts into dc.draw methods
    def UserToPixelY(self, y, axis):
	""" Convert user Y coordinate to pixel location on graph """
	a = around(self.ybottom - ((y - axis.min) * axis.ratio))
	a = clip(a, -1000, self.height+1000)
	return a.astype(int32)

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
    def set_graph_height(self):
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
        (w, titleh) = self.title.getSize()
    
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


    #---------------------------------------------------------------------------
    def inplotregion(self, x, y):
	""" Check if data point is inside plotting area """

	if y < self.ybottom and y > self.ytop and x > self.xleft and x < self.xright:
		return 1
	else:
		return 0



    ############################################################################
    # Event handlers
    #---------------------------------------------------------------------------
    def mouseReleaseEvent(self, event):
	x = event.x()
	y = event.y()

	if event.button() == QtCore.Qt.LeftButton:
		self.rubberbandv.hide()
		self.rubberbandh.hide()
		self.label.hide()

    #---------------------------------------------------------------------------
    def mousePressEvent(self, event):
	x = event.x()
	y = event.y()

	if event.button() == QtCore.Qt.LeftButton:
                if self.inplotregion(x, y):
			self.origin = event.pos()
			self.rubberbandv.setGeometry( x, self.ytop, 1, self.ybottom-self.ytop)
			self.rubberbandh.setGeometry( self.xleft, y, self.xright-self.xleft, 1)
			self.rubberbandv.show()
			self.rubberbandh.show()
			self.lastx = x
			self.lasty = y

			self.label.draw(x,y)
			self.label.show()

    #---------------------------------------------------------------------------
    def mouseMoveEvent(self, event):

	btn = event.buttons()
	x = event.x()
	y = event.y()
	if btn == QtCore.Qt.LeftButton:
            if self.zoomEnabled or self.selectionEnabled:
                if self.inplotregion(x, y):
		    self.rubberband.setGeometry(QtCore.QRect(self.origin, event.pos()).normalized())
#                    self._drawRubberBand (event)
                    self.lastx = x
                    self.lasty = y
 #                   self._drawRubberBand (event)
            elif self.dragEnabled:
                if event.ControlDown():
                    self._zoom(event)
                else:
                    self._pan(event)
                self.lastx = x
                self.lasty = y
            else:
		# draw new position of crosshair
                self.lastx = x
                self.lasty = y
                if self.inplotregion(x, y):
			self.rubberbandv.move( x, self.ytop)
			self.rubberbandh.move( self.xleft, y)
			if self.show_popup:
				self.label.draw(x,y)



    ############################################################################
    # Routines dealing with axes of the graph
    #---------------------------------------------------------------------------
    def addXAxis(self, title):
	""" Add an X axis to the graph. """
	id = self.xaxisId + 1
	axis = Axis("x", id)
	axis.title.text = title
	self.axes.append(axis)
	self.xaxisId += 1
	return axis

    #---------------------------------------------------------------------------
    def addYAxis(self, title):
	""" Add a Y axis to the graph. """
	id = self.yaxisId + 1
	axis = Axis("y", id)
	axis.title.text = title
	self.axes.append(axis)
	self.yaxisId += 1
	return axis

    #---------------------------------------------------------------------------
    def getXAxis(self, id):
	""" Return an X axis given its id number. """
	id = int(id)
	for axis in self.axes:
		if axis.isXAxis() and axis.id == id:
			return axis

	raise ValueError, str(id) + ': illegal X axis specification'

    #---------------------------------------------------------------------------
    def getYAxis(self, id):
	""" Return a Y axis given its id number. """
	id = int(id)
	for axis in self.axes:
		if axis.isYAxis() and axis.id == id:
			return axis

	raise ValueError, str(id) + ': illegal Y axis specification'

    ############################################################################
    # Routines dealing with datasets of the graph
    #---------------------------------------------------------------------------
    def createDataset(self, x=[], y=[], name="", symbol="square", color="auto", outlinecolor="black", outlinewidth=1, fillsymbol=True, markersize=2, linecolor="auto", linetype="solid", connector="lines", linewidth=1):
	"""
	Create a new dataset and addit to graph.
	"""

	if len(x)==0 or len(y)==0:
		return False


	if color == "auto":
		nd = len(self.datasets)
		color = self.colors[nd%self.num_colors]

	print color

	dataset = Dataset(x, y, name)
	dataset.style.setFillColor(color)
	dataset.style.setMarker(symbol)
	dataset.style.setMarkerSize(markersize)
	dataset.style.setFillMarkers(fillsymbol)
	dataset.style.setOutlineColor(outlinecolor)
	dataset.style.setOutlineWidth(outlinewidth)
	dataset.style.setLineType(linetype)
	dataset.style.setConnectorType(connector)
	if linecolor == "auto":
		dataset.style.setLineColor(color)
	else:
		dataset.style.setLineColor(linecolor)
	dataset.style.setLineWidth(linewidth)

	self.addDataset(dataset)

	return dataset

    #---------------------------------------------------------------------------
    def addDataset(self, dataset):
	""" 
	Add a dataset to the graph. 
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
    def showThisDataset(self, dataset):

	if dataset.hidden:
		return False

	if len(self.datasetShowList):
		if dataset.name in self.datasetShowList:
			return True
		else:
			return False

	return True

