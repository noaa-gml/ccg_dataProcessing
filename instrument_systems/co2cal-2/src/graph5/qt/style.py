

from PyQt4 import QtGui, QtCore

import numpy

from linetypes import *

MARKER_TYPES =  [
	"none",
	"square",
	"circle",
	"diamond",
	"triangle",
	"triangle_down",
	"square_plus" ,
	"circle_plus",
	"plus",
	"cross",
	"asterisk",
	"+",
	"*",
	"x",
]


#CONNECTOR_TYPES = [ "None", "lines", "posts", "spline", "steps", "bars" ]
CONNECTOR_TYPES = [ "None", "lines", "posts", "steps", "bars"]

#########################################################################
class Style:
    """ Class for containing information about the drawing style for a dataset.
    Also does the actual drawing of the dataset to the graph.
    A style is made up of a line and a marker.  
    Lines are made up of
	line width
	line color
	line type
	connector type
    Markers are made up of
	marker type
	marker size
	boolean to fill markers or not
	marker outline width
	marker outline color
	marker fill color

    Example:
	style = Style()
	style.SetMarker("circle")
	style.SetOutlineWidth(1)
	style.SetMarkerColor("black")
	style.SetMarkerSize(8)
	style.SetFillMarkers(True)
	style.SetFillColor("blue")
	style.SetLinetype("solid")
	style.SetLineWidth(2)
	style.SetLineColor("green")
	style.SetConnectorType("lines")

    The style is attached to a dataset using the dataset.SetStyle() method.
    """

    def __init__(self):

	# Drawing parameters
	self.outlineColor = QtGui.QColor(0,0,0)
	self.fillColor = QtGui.QColor(255,255,255)
	self.lineType = 1  #  wx.SOLID
	self.lineColor = QtGui.QColor(0,0,0)
	self.lineWidth = 1
	self.outlineWidth = 1
	self.marker = "none"
	self.markerSize = 2
	self.fillSymbols = True
	self.connectorType = "lines"


    #---------------------------------------------------------------------------
    def draw(self, graph, qp, pts):
        """ Draw the data points using this style """

	qtpts = []
	for p in pts:
		pt = QtCore.QPoint(p[0], p[1])
		qtpts.append(pt)



	self.draw_lines(graph, qp, qtpts, self.lineWidth)
	self.draw_markers(qp, pts, self.markerSize)

    #---------------------------------------------------------------------------
    def draw_lines(self, graph, qp, pts, width):
	""" Draw the lines for a dataset. """

	if self.lineType == "none" or self.lineType == None or len(pts) <=1 :
		return

	qp.setPen(QtGui.QColor(self.lineColor))  # , self.lineWidth, self.lineType))

	if self.connectorType == "lines":
		print pts
		print pts[0]
		qp.drawLines(pts)

	elif self.connectorType == "spline":
		qp.drawSpline(pts)

	# draw lines from bottom of graph to data point
	elif self.connectorType == "posts":
		y1 = graph.ybottom

		for pt in pts:
			x1 = pt[0]
			x2 = x1
			y2 = pt[1]
			qp.DrawLine(x1,y1,x2,y2)

	# draw bars from bottom of graph to data point
	# bar width is 4 pixels less than the distance to next point,
	# centered on data point
	elif self.connectorType == "bars":
		qp.SetBrush(wx.Brush(self.fillColor, wx.SOLID))
		w0 = pts[0]
		w1 = pts[1]
		w = w1[0] - w0[0] - 4
                if w < 2: w = 2
		y1 = graph.ybottom

		for pt in pts:
			x1 = pt[0] - w/2
			x2 = x1 + w
			y2 = pt[1]
			qp.DrawRectangle(x1,y1,w, y2-y1)

	# connector is horizontal line half way to next data point,
	# then vertical line to next data point y value, then
	# horizontal line to next data point etc.
	#          |----*---|
	#   ---*---|        |---*---
	elif self.connectorType == "steps":

		p = pts[0]
		x0 = p[0]
		y0 = p[1]

		xa = x0
		ya = y0

		for pt in pts[1:]:
			x = pt[0]
			y = pt[1]

			xb = (x-x0)/2.0 + x0
			yb = y0

			xc = xb
			yc = y

			qp.DrawLine(xa,ya,xb,yb)
			qp.DrawLine(xb,yb,xc,yc)

			xa = xc
			ya = yc

			x0 = x
			y0 = y

		qp.DrawLine(xa,ya,x0,y0)


    #---------------------------------------------------------------------------
    def draw_markers(self, qp, pts, size):
	""" Draw the markers for the dataset """

	if self.marker == "none" or self.marker == None or len(pts) <=0:
		return

	if self.outlineWidth == 0:
		qp.setPen(wx.Pen(self.outlineColor, self.outlineWidth, wx.TRANSPARENT))
	else:
		qp.setPen(QtGui.QColor(self.outlineColor)) # , self.outlineWidth, wx.SOLID))
	if self.fillSymbols:
		print "fill color", self.fillColor
		qp.setBrush(QtGui.QColor(self.fillColor[0], self.fillColor[1], self.fillColor[2]))  # , wx.SOLID))
	else:
		qp.setBrush(QtGui.QColor(self.fillColor)) # , wx.TRANSPARENT))

	if self.marker == "square":
		self._square(qp, pts, size)
	if self.marker == "circle":
		self._circle(qp, pts, size)
	if self.marker == "triangle":
		self._triangle(qp, pts, size)
	if self.marker == "triangle_down":
		self._triangle_down(qp, pts, size)
	if self.marker == "diamond":
		self._diamond(qp, pts, size)
	if self.marker == "plus" or self.marker == "+":
		self._plus(qp, pts, size)
	if self.marker == "cross" or self.marker == "x":
		self._cross(qp, pts, size)
	if self.marker == "asterisk" or self.marker == "*":
		self._asterisk(qp, pts, size)
	if self.marker == "square_plus":
		self._square_plus(qp, pts, size)
	if self.marker == "circle_plus":
		self._circle_plus(qp, pts, size)

    #---------------------------------------------------------------------------
    def _circle_plus(self, qp, pts, size):
	self._circle(qp, pts,size)
	self._plus(qp, pts,size)

    #---------------------------------------------------------------------------
    def _square_plus(self, qp, pts, size):
	self._square(qp, pts,size)
	self._plus(qp, pts,size)

    #---------------------------------------------------------------------------
    def _square(self, qp, pts, size):
        fact= 1.0*size
        wh= 2.0*size
        rect= numpy.zeros((len(pts),4),float)+[0.0,0.0,wh+1,wh+1]
        rect[:,0:2]= pts-[fact,fact]
	a = []
	for r in rect:
		print r
		a.append(QtCore.QRect(r[0], r[1], r[2], r[3]))
        qp.drawRects(a)
	
    #---------------------------------------------------------------------------
    def _circle(self, qp, pts, size):
        fact= 1.0*size
        wh= 2.0*size
        rect= numpy.zeros((len(pts),4),float)+[0.0,0.0,wh,wh]
        rect[:,0:2]= pts-[fact,fact]
        qp.DrawEllipseList(rect.astype(numpy.int32))

    #---------------------------------------------------------------------------
    def _triangle(self, qp, pts, size):
        shape= [(-1.0*size,1.0*size), (1.0*size,1.0*size), (0.0,-1.0*size)]
        poly= numpy.array(pts.repeat(3, axis=0))
        poly.shape= (len(pts),3,2)
        poly += shape
        qp.DrawPolygonList(poly.astype(numpy.int32))

    #---------------------------------------------------------------------------
    def _triangle_down(self, qp, pts, size):
        shape= [(-1.0*size,-1.0*size), (1.0*size,-1.0*size), (0.0,1.0*size)]
        poly= numpy.array(pts.repeat(3, axis=0))
        poly.shape= (len(pts),3,2)
        poly += shape
        qp.DrawPolygonList(poly.astype(numpy.int32))

    #---------------------------------------------------------------------------
    def _diamond(self, qp, pts,size):
	shape = [(-1.0*size,0), (0,1.0*size), (1.0*size,0.0), (0.0,-1.0*size)]
        poly= numpy.array(pts.repeat(4, axis=0))
        poly.shape= (len(pts),4,2)
        poly += shape
        qp.DrawPolygonList(poly.astype(numpy.int32))

    #---------------------------------------------------------------------------
    def _plus(self, qp, pts, size):
	fact= 1.0*size
        for f in [[-fact,0,fact,0],[0,-fact,0,fact]]:
            lines= numpy.concatenate((pts,pts),axis=1)+f
            qp.DrawLineList(lines.astype(numpy.int32))

    #---------------------------------------------------------------------------
    def _cross(self, qp, pts, size):
	fact= 1.0*size
        for f in [[-fact,-fact,fact,fact],[-fact,fact,fact,-fact]]:
            lines= numpy.concatenate((pts,pts),axis=1)+f
            qp.DrawLineList(lines.astype(numpy.int32))

    #---------------------------------------------------------------------------
    def _asterisk(self, qp, pts, size):
	fact= 1.0*size
        for f in [[-fact,-fact,fact,fact],[-fact,fact,fact,-fact],[-fact,0,fact,0],[0,-fact,0,fact]]:
            lines= numpy.concatenate((pts,pts),axis=1)+f
            qp.DrawLineList(lines.astype(numpy.int32))
	
    #---------------------------------------------------------------------------
    def setOutlineColor(self, color):
	self.outlineColor = color

    #---------------------------------------------------------------------------
    def setLineWidth(self,width):
	self.lineWidth = width

    #---------------------------------------------------------------------------
    def setOutlineWidth(self,width):
	self.outlineWidth = width

    #---------------------------------------------------------------------------
    def setMarker(self,marker):

	if marker.lower() in MARKER_TYPES:
		self.marker = marker.lower()
	else:
		print "Warning: ", str(marker) + ': illegal Marker type'

    #---------------------------------------------------------------------------
    def setFillColor(self,color):
	self.fillColor = color

    #---------------------------------------------------------------------------
    def setMarkerSize(self,size):
	self.markerSize = size

    #---------------------------------------------------------------------------
    def setLineColor(self,color):
	self.lineColor = color

    #---------------------------------------------------------------------------
    def setLineType(self,type):
	wxval = NameToStyle(type)
	self.lineType = wxval

    #---------------------------------------------------------------------------
    def setFillMarkers(self,type):
	self.fillSymbols = type

    #---------------------------------------------------------------------------
    def setConnectorType(self,type):
	self.connectorType = type.lower()

    #---------------------------------------------------------------------------
    def DrawMarker(self, graph, qp, x, y):
        """ Draw a single marker at the location x,y 
	Used for marker annotation.  Called only from graph.py module
	"""

#	pqp = wx.ClientDC(graph)
	gcqp = wx.GCDC(qp)
#	qp.Clear()

        pts = numpy.transpose([[x],[y]])
	self.draw(graph, gcqp, pts)

    #---------------------------------------------------------------------------
    def DrawLine(self, graph, qp, x, y):

#	gcqp = wx.GCDC(qp)

        pts = numpy.transpose([x,y])
	self.draw(graph, qp, pts)
    

#####################################################################3333
class StyleDialog(wx.Dialog):
	def __init__(
		    self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition, 
		    style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
		    dataset = None,
            ):
                wx.Dialog.__init__(self, parent, -1, title)

		self.dataset = dataset
		self.graph = parent

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		label = wx.StaticText(self, -1, "Attributes for " + self.dataset.name)
		box0.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		# Legend label box
		box = wx.BoxSizer(wx.HORIZONTAL)
		label = wx.StaticText(self, -1, "Legend Label:")
		box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.label = wx.TextCtrl(self, -1, self.dataset.label, size=(80,-1))
		box.Add(self.label, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

		box0.Add(box, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		#------------------------------------------------
		# Symbol attributes inside a staticbox
		box = wx.StaticBox(self, -1, "Symbol Attributes")
		sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

		box1 = wx.GridSizer(6,2,1,1)
		sizer.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(self, -1, "Symbol Type:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		value = self.dataset.style.marker
		self.marker_type = wx.Choice(self, -1, choices=MARKER_TYPES)
		self.marker_type.SetStringSelection(value)
		box1.Add(self.marker_type, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Size:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.size = wx.SpinCtrl(self, -1, str(self.dataset.style.markerSize))
		box1.Add(self.size, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Outline Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.outline_color = wx.ColourPickerCtrl(self, -1, self.dataset.style.outlineColor)
		box1.Add(self.outline_color, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Outline Width:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.outline_width = wx.SpinCtrl(self, -1, str(self.dataset.style.outlineWidth))
		box1.Add(self.outline_width, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Fill Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.fillColor = wx.ColourPickerCtrl(self, -1, self.dataset.style.fillColor)
		box1.Add(self.fillColor, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		self.use_filled = wx.CheckBox(self, -1, "Use Filled Symbols")
		self.use_filled.SetValue(self.dataset.style.fillSymbols)
		box1.Add(self.use_filled, 0, wx.ALIGN_RIGHT|wx.ALL, 0)

		# add static box sizer to main sizer
		box0.Add(sizer, wx.ALIGN_LEFT)


		#------------------------------------------------
		# second static box sizer
		box = wx.StaticBox(self, -1, "Connector Attributes")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)

		box2 = wx.GridSizer(4,2,1,1)
		sizer2.Add(box2, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(self, -1, "Connector Type:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		val = self.dataset.style.connectorType
		self.connectorType = wx.Choice(self, -1, choices=CONNECTOR_TYPES)
		self.connectorType.SetStringSelection(val)
		box2.Add(self.connectorType, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		# Line attributes inside a staticbox
		label = wx.StaticText(self, -1, "Line Type:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		value = StyleToName(self.dataset.style.lineType)
		self.lineType = wx.Choice(self, -1, choices=LINE_TYPES.keys())
		self.lineType.SetStringSelection(value)
		box2.Add(self.lineType, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Line Color:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.lineColor = wx.ColourPickerCtrl(self, -1, self.dataset.style.lineColor)
		box2.Add(self.lineColor, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Line Width:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.lineWidth = wx.SpinCtrl(self, -1, str(self.dataset.style.lineWidth))
		box2.Add(self.lineWidth, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		# add 2nd sizer to main sizer
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT)

		line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
		box0.Add(line, 0, wx.GROW|wx.ALIGN_RIGHT|wx.RIGHT|wx.TOP, 5)


		#------------------------------------------------
		# Dialog buttons
		btnsizer = wx.StdDialogButtonSizer()

		btn = wx.Button(self, wx.ID_OK)
		btn.SetDefault()
		self.Bind(wx.EVT_BUTTON, self.ok, btn)
		btnsizer.AddButton(btn)
		btn = wx.Button(self, wx.ID_APPLY)
		self.Bind(wx.EVT_BUTTON, self.apply, btn)
		btnsizer.AddButton(btn)
		btn = wx.Button(self, wx.ID_CANCEL)
		btnsizer.AddButton(btn)

		btnsizer.Realize()

		box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

		self.SetSizer(box0)
		box0.SetSizeHints(self)
		box0.Fit(self)

	def apply(self, event):

		val = self.label.GetValue()
		self.dataset.label = val

		val = str(self.marker_type.GetStringSelection())
		self.dataset.style.setMarker(val.lower())

		val = self.size.GetValue()
		self.dataset.style.setMarkerSize(val)

		val = self.outline_width.GetValue()
		self.dataset.style.setOutlineWidth(val)

		color = self.outline_color.GetColour()
		self.dataset.style.setOutlineColor(color)
		
		color = self.fillColor.GetColour()
		self.dataset.style.setFillColor(color)

		val = self.use_filled.GetValue()
		self.dataset.style.setFillMarkers(val)

		color = self.lineColor.GetColour()
		self.dataset.style.setLineColor(color)

		val = self.connectorType.GetStringSelection()
		self.dataset.style.setConnectorType(val)

		val = self.lineType.GetStringSelection()
		self.dataset.style.setLineType(val)
#		wxval = NameToStyle(val)
#		self.dataset.style.setLineType(wxval)

		val = self.lineWidth.GetValue()
		self.dataset.style.setLineWidth(val)

		self.graph.update()

	def ok(self,event):
		self.apply(event)
		self.EndModal(wx.ID_OK)

