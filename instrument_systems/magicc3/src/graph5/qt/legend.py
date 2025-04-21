
from PyQt4 import QtGui, QtCore

from title import Title
from font import Font
from numpy import transpose

import text

LEGEND_RIGHT = 0
LEGEND_LEFT = 1
LEGEND_TOP = 2
LEGEND_BOTTOM = 3
LEGEND_PLOTAREA = 4

#####################################################################3333
class Legend:

    def __init__(self):

	self.showLegend = True
	self.showLegendBorder = True
	self.location = LEGEND_RIGHT
	self.x = 0.0
	self.y = 0.0
	self.background = QtCore.Qt.white
	self.foreground = QtCore.Qt.black
	self.autoPosition = True
	self.title = Title()
	self.font = Font(size=8)
	self.borderWidth = 1
	self.raised = True
	self.margin = 5
	self.width = 0
	self.height = 0
	self.symbol_width = 30
	self.hidden_bg = QtGui.QColor(255,255,200)
	self.color = QtCore.Qt.black	# font color
	self.spacing = 3	# spacing between lines

    #---------------------------------------------------------------------------
    def draw(self, graph, qp):
	""" Draw the legend. """

	if not self.showLegend:
		return

	self._set_location(graph)

	showlist = self.getShowList(graph)
	if len(showlist) == 0:
		return

	# Legend border
	if self.showLegendBorder:
		qp.setPen( QtGui.QColor(self.foreground))  #  , self.borderWidth)
		qp.setBrush( QtGui.QColor(self.background))
		qp.drawRect(self.x, self.y, self.width, self.height)

	# Legend title
	qp.setFont(self.font.qtFont())
	qp.setPen(self.title.color)

	(w,h) = text.getTextExtent(qp, self.title.text)
	xp = self.x + self.width/2 - w/2
	yp = self.y + self.margin + self.borderWidth
	qp.drawText (xp, yp, self.title.text)
	yp += h + self.spacing

	# Dataset names
	for name in showlist:
		dataset = graph.getDataset(name)
		(w,h) = text.getTextExtent(qp, dataset.label)

		if dataset.hidden:
			x0 = self.x + self.margin + self.borderWidth
			y0 = yp
			w0 = self.width - 2*self.borderWidth - 2*self.margin
			h0 = h
#			print "rect is ",x0,x0+w0,y0,y0+h0
			qp.setPen(QtGui.QColor(200,100,100))
			qp.setBrush(QtGui.QColor(self.hidden_bg))
			qp.drawRect(x0-2,y0-1,w0+3,h0+2)

		if dataset.style.connectorType != "none":
			x0 = self.x + self.borderWidth + self.margin
			x1 = x0 + self.symbol_width
			y0 = yp + h/2
			y1 = yp + h/2
# fix
#			qp.setPen(wx.Pen(dataset.style.lineColor, dataset.style.lineWidth, dataset.style.lineType))
			qp.drawLine(x0,y0,x1,y1)

		x0 = self.x + self.margin + self.borderWidth + self.symbol_width/2
		y0 = yp + h/2
		pts = transpose([[x0],[y0]])

		markersize = min([5, h/2])
		dataset.style.draw_markers(qp, pts, markersize)

		xp = x0 + self.margin + self.symbol_width/2
		qp.setPen(self.color)
		qp.drawText(xp, yp, dataset.label)
		yp += h + self.spacing


    #---------------------------------------------------------------------------
    def setSize(self, graph, qp):
	""" Calculate the width and height of legend """

	# If no datasets are shown, size is 0
	showlist = self.getShowList(graph)
	if not self.showLegend or not len(showlist):
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
#		dc.SetFont(self.title.font)
		qp.setFont(self.title.font.qtFont())
		(width,height) = text.getTextExtent(qp, self.title.text)

		# Now for each data dataset, get maximum
		# width of label
		qp.setFont(self.font.qtFont())
		labelw = 0
		for name in showlist:
			dataset = graph.getDataset(name)
			if dataset != None:
				(w,h) = text.getTextExtent(qp, dataset.label)
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
    def _set_location(self,graph):
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
    def inLegendRegion(self,x,y):
	""" Check if position x,y is inside the legend """

	if x >=self.x and x<=self.x+self.width and y>=self.y and y<=self.y+self.height:
		return 1
	else:
		return 0

    #---------------------------------------------------------------------------
    def getDataset(self, graph, x, y):
	""" Given window x,y location, determine if that location is on a
	    legend dataset label. If so return the dataset, else return None
	    Used in graph.py to determine if user clicked on a dataset label.
	"""

	qp = QtGui.QPainter()

	qp.setFont(self.font.qtFont())
	(w,h) = text.getTextExtent(qp, self.title.text)
	yp = self.y + self.margin + self.borderWidth 
	yp += h + self.spacing

	# get left location and width of legend label area
	x0 = self.x + self.margin + self.borderWidth
	w0 = self.width - 2*self.borderWidth - 2*self.margin

	# Dataset names
	showlist = self.getShowList(graph)
	for name in showlist:
		dataset = graph.getDataset(name)
		(w,h0) = text.getTextExtent(qp, dataset.label)

		if x>=x0 and x<=x0+w0 and y>=yp and y<=yp+h0:
			return dataset

		yp += h0 + self.spacing

	return None

    #---------------------------------------------------------------------------
    # Get list of dataset names to display in legend
    def getShowList(self, graph):

	if len(graph.datasetShowList):
		dlist = graph.datasetShowList
	else:
		dlist = graph.getDatasetNames()

	return dlist

