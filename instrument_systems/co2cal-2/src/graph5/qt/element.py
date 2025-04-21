
import PyQt4
import datetime

from numpy import *

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
]


CONNECTOR_TYPES = [ "None", "lines", "posts", "spline", "steps" ]

#####################################################################3333
class Element:

    def __init__(self, x = None, y= None, name = ""):
	self.name = name
	self.hidden = False
	self.label = self.name
	self.xaxis = 0	# The id of the xaxis to map the data on
	self.yaxis = 0  # The id of the yaxis to map the data on

	# data parameters
	self.xdata = array(x)
	self.ydata = array(y)
	self.weights = []
	self.ymin = 0
	self.ymax = 0
	self.xmin = 0
	self.xmax = 0
	self.missingValue = 0.0
	self.subsetStart = -1
	self.subsetEnd = -1

	# Drawing parameters
	self.outlineColor = qt.QColor(0,0,0)
	self.fillColor = qt.QColor(255,255,255)
	self.lineType = qt.Qt.SolidLine
	self.lineColor = qt.QColor(0,0,0)
	self.lineWidth = 1
	self.outlineWidth = 1
	self.marker = "none"
	self.markerSize = 2
	self.fillSymbols = True
	self.connector_type = "lines"

	# Find the minimum and maximum values of the data
	self.findRange()

    #---------------------------------------------------------------------------
    def getClosestPoint(self, graph, x, y):
	if self.hidden:
		return []

	xaxis = graph.getXAxis(self.xaxis)
	yaxis = graph.getYAxis(self.yaxis)
	xscaled = graph.UserToPixelX(self.xdata, xaxis)
	yscaled = graph.UserToPixelY(self.ydata, yaxis)
	pts = transpose([xscaled,yscaled])

	pxy = array([x,y])
	d= sqrt(add.reduce((pts-pxy)**2,1)) #sqrt(dx^2+dy^2)
        pntIndex = argmin(d)
        dist = d[pntIndex]
#	print "dist = ", dist, " at index ", pntIndex, ": value is ", pts[pntIndex]
#	x0 = pts[pntIndex][0]
#	y0 = pts[pntIndex][1]
#        dc = wx.ClientDC( graph )
#        dc.SetBrush(wx.Brush( wx.Colour(250,17,0,0), wx.SOLID ) )
#        dc.SetPen(wx.Pen( wx.BLACK ) )
#        dc.DrawRectangle (x0-4,y0-4, 8, 8)

	return self.name, dist, pntIndex


	
    #---------------------------------------------------------------------------
    def draw(self, graph, dc):
	if self.hidden:
		return

	t1 = datetime.datetime.now()
	xaxis = graph.getXAxis(self.xaxis)
	yaxis = graph.getYAxis(self.yaxis)
	xscaled = graph.UserToPixelX(self.xdata, xaxis)
	yscaled = graph.UserToPixelY(self.ydata, yaxis)
	pts = transpose([xscaled,yscaled])
	t2 = datetime.datetime.now()
	print "prep time was ", t2-t1

	t1 = datetime.datetime.now()
	self.draw_lines(graph, dc, pts, self.lineWidth)
	t2 = datetime.datetime.now()
	print "drawing lines time was ", t2-t1
	self.draw_markers(graph, dc, pts, self.markerSize)
	t3 = datetime.datetime.now()
	print "drawing markers time was ", t3-t2

    #---------------------------------------------------------------------------
    def draw_lines(self, graph, dc, pts, width):
	if self.lineType == "none":
		return

	dc.setPen(qt.QPen(self.lineColor, width, self.lineType))
	if self.connector_type == "lines":
		pt = pts[0]
		x2 = pt[0]
		y2 = pt[1]
		for pt in pts:
			x1 = x2
			y1 = y2
			x2 = pt[0]
			y2 = pt[1]
			dc.drawLine(x1,y1,x2,y2)

	if self.connector_type == "posts":
		axis = graph.getYAxis(self.yaxis)
		if axis.min < 0:
			y1 = graph.UserToPixelY(0,axis)
		else:
			y1 = graph.ybottom

		for pt in pts:
			x1 = pt[0]
			x2 = x1
			y2 = pt[1]
			dc.drawLine(x1,y1,x2,y2)

	if self.connector_type == "bars":
		dc.SetBrush(wx.Brush(self.fillColor, wx.SOLID))
		axis = graph.getYAxis(self.yaxis)
		w0 = pts[0]
		w1 = pts[1]
		w = w1[0] - w0[0] -4
		print w0, w1, w	
		if axis.min < 0:
			y1 = graph.UserToPixelY(0,axis)
		else:
			y1 = graph.ybottom

		for pt in pts:
			x1 = pt[0] - w/2
			x2 = x1 + w
			y2 = pt[1]
			dc.drawRect(x1,y1,w, y2-y1)

	if self.connector_type == "steps":

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

			dc.drawLine(xa,ya,xb,yb)
			dc.drawLine(xb,yb,xc,yc)

			xa = xc
			ya = yc

			x0 = x
			y0 = y

		dc.drawLine(xa,ya,x0,y0)


    #---------------------------------------------------------------------------
    def draw_markers(self, graph, dc, pts, size):
#	dc.setPen(qt.QPen(self.outlineColor, self.outlineWidth))
	dc.setPen(self.outlineColor)
	if self.fillSymbols:
		dc.setBrush(self.fillColor)
	else:
		dc.setBrush(self.fillColor)

	if self.marker == "square":
		self._square(graph, dc, pts, size)
	if self.marker == "circle":
		self._circle(graph, dc, pts, size)
	if self.marker == "triangle":
		self._triangle(graph, dc, pts, size)
	if self.marker == "triangle_down":
		self._triangle_down(graph, dc, pts, size)
	if self.marker == "diamond":
		self._diamond(graph, dc, pts, size)
	if self.marker == "plus":
		self._plus(graph, dc, pts, size)
	if self.marker == "cross":
		self._cross(graph, dc, pts, size)
	if self.marker == "asterisk":
		self._asterisk(graph, dc, pts, size)
	if self.marker == "square_plus":
		self._square_plus(graph, dc, pts, size)
	if self.marker == "circle_plus":
		self._circle_plus(graph, dc, pts, size)

    #---------------------------------------------------------------------------
    def _circle_plus(self, graph, dc, pts, size):
	self._circle(graph, dc, pts,size)
	self._plus(graph, dc, pts,size)

    #---------------------------------------------------------------------------
    def _square_plus(self, graph, dc, pts, size):
	self._square(graph, dc, pts,size)
	self._plus(graph, dc, pts,size)

    #---------------------------------------------------------------------------
    def _square(self, graph, dc, pts, size):
        fact= 1.0*size
        wh= 2.0*size
        rect= zeros((len(pts),4),float)+[0.0,0.0,wh+1,wh+1]
        rect[:,0:2]= pts-[fact,fact]
	for r in rect:
		dc.drawRect(r[0], r[1], r[2], r[3])
#        dc.DrawRectangleList(rect.astype(int32))
	
    #---------------------------------------------------------------------------
    def _circle(self, graph, dc, pts, size):
        fact= 1.0*size
        wh= 2.0*size
        rect= zeros((len(pts),4),float)+[0.0,0.0,wh,wh]
        rect[:,0:2]= pts-[fact,fact]
	for r in rect:
		dc.drawEllipse(r[0], r[1], r[2], r[3])
#        dc.DrawEllipseList(rect.astype(int32))

    #---------------------------------------------------------------------------
    def _triangle(self, graph, dc, pts, size):
        shape= [(-1.0*size,1.0*size), (1.0*size,1.0*size), (0.0,-1.0*size)]
        poly= array(pts.repeat(3, axis=0))
        poly.shape= (len(pts),3,2)
        poly += shape
        dc.DrawPolygonList(poly.astype(int32))

    #---------------------------------------------------------------------------
    def _triangle_down(self, graph, dc, pts, size):
        shape= [(-1.0*size,-1.0*size), (1.0*size,-1.0*size), (0.0,1.0*size)]
        poly= array(pts.repeat(3, axis=0))
        poly.shape= (len(pts),3,2)
        poly += shape
        dc.DrawPolygonList(poly.astype(int32))

    #---------------------------------------------------------------------------
    def _diamond(self, graph, dc, pts,size):
	shape = [(-1.0*size,0), (0,1.0*size), (1.0*size,0.0), (0.0,-1.0*size)]
        poly= array(pts.repeat(4, axis=0))
        poly.shape= (len(pts),4,2)
        poly += shape
        dc.DrawPolygonList(poly.astype(int32))

    #---------------------------------------------------------------------------
    def _plus(self, graph, dc, pts, size):
	fact= 1.0*size
        for f in [[-fact,0,fact,0],[0,-fact,0,fact]]:
            lines= concatenate((pts,pts),axis=1)+f
            dc.DrawLineList(lines.astype(int32))

    #---------------------------------------------------------------------------
    def _cross(self, graph, dc, pts, size):
	fact= 1.0*size
        for f in [[-fact,-fact,fact,fact],[-fact,fact,fact,-fact]]:
            lines= concatenate((pts,pts),axis=1)+f
            dc.DrawLineList(lines.astype(int32))

    #---------------------------------------------------------------------------
    def _asterisk(self, graph, dc, pts, size):
	fact= 1.0*size
        for f in [[-fact,-fact,fact,fact],[-fact,fact,fact,-fact],[-fact,0,fact,0],[0,-fact,0,fact]]:
            lines= concatenate((pts,pts),axis=1)+f
            dc.DrawLineList(lines.astype(int32))
	

    #---------------------------------------------------------------------------
    # Find the minimum and maximum data values for the data 
    def findRange(self):
	self.xmin = self.xdata.min()
	self.xmax = self.xdata.max()
	self.ymin = self.ydata.min()
	self.ymax = self.ydata.max()

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
	self.lineType = type

    #---------------------------------------------------------------------------
    def setFillMarkers(self,type):
	self.fillSymbols = type

    #---------------------------------------------------------------------------
    def setConnectorType(self,type):
	self.connector_type = type.lower()

    #---------------------------------------------------------------------------
    def setAxis(self,axis):
	""" Set the axis that this element is mapped to """
	if axis.isXAxis():
		self.xaxis = axis.id
	if axis.isYAxis():
		self.yaxis = axis.id

    #---------------------------------------------------------------------------
    def showEditDialog(self, graph):

	dlg = ElementDialog(graph, -1, "Edit Attributes", size=(350, 800),
                         #style=wx.CAPTION | wx.SYSTEM_MENU | wx.THICK_FRAME,
                         style=wx.DEFAULT_DIALOG_STYLE, # & ~wx.CLOSE_BOX,
			 element = self,
                         )
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        val = dlg.ShowModal()
    
        dlg.Destroy()
        

#####################################################################3333
class ElementDialog(wx.Dialog):
	def __init__(
		    self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition, 
		    style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
		    element = None,
            ):
                wx.Dialog.__init__(self, parent, -1, title)

		self.element = element
		self.graph = parent

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		label = wx.StaticText(self, -1, "Attributes for " + element.name)
		box0.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

		# Legend label box
		box = wx.BoxSizer(wx.HORIZONTAL)
		label = wx.StaticText(self, -1, "Legend Label:")
		box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.label = wx.TextCtrl(self, -1, element.label, size=(80,-1))
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
		value = element.marker
		self.marker_type = wx.Choice(self, -1, choices=MARKER_TYPES)
		self.marker_type.SetStringSelection(value)
		box1.Add(self.marker_type, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Size:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.size = wx.SpinCtrl(self, -1, str(element.markerSize))
		box1.Add(self.size, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Outline Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.outline_color = wx.ColourPickerCtrl(self, -1, element.outlineColor)
		box1.Add(self.outline_color, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Outline Width:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.outline_width = wx.SpinCtrl(self, -1, str(element.outlineWidth))
		box1.Add(self.outline_width, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Symbol Fill Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.fillColor = wx.ColourPickerCtrl(self, -1, element.fillColor)
		box1.Add(self.fillColor, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		self.use_filled = wx.CheckBox(self, -1, "Use Filled Symbols")
		self.use_filled.SetValue(element.fillSymbols)
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
		types = ["none", "lines", "posts", "steps", "spline"]
		val = element.connector_type
#		self.connectorType = wx.ComboBox(self, -1, val, style=wx.CB_READONLY, choices=types)
		self.connectorType = wx.Choice(self, -1, choices=CONNECTOR_TYPES)
		self.connectorType.SetStringSelection(val)
		box2.Add(self.connectorType, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		# Line attributes inside a staticbox
		label = wx.StaticText(self, -1, "Line Type:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		value = StyleToName(element.lineType)
#		self.lineType = wx.ComboBox(self, -1, value, style=wx.CB_READONLY, choices=LINE_TYPES.keys())
		self.lineType = wx.Choice(self, -1, choices=LINE_TYPES.keys())
		self.lineType.SetStringSelection(value)
		box2.Add(self.lineType, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Line Color:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.lineColor = wx.ColourPickerCtrl(self, -1, element.lineColor)
		box2.Add(self.lineColor, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(self, -1, "Line Width:")
		box2.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.lineWidth = wx.SpinCtrl(self, -1, str(element.lineWidth))
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
		self.element.label = val

		val = str(self.marker_type.GetStringSelection())
		self.element.setMarker(val.lower())

		val = self.size.GetValue()
		self.element.setMarkerSize(val)

		val = self.outline_width.GetValue()
		self.element.setOutlineWidth(val)

		color = self.outline_color.GetColour()
		self.element.setOutlineColor(color)
		
		color = self.fillColor.GetColour()
		self.element.setFillColor(color)

		val = self.use_filled.GetValue()
		self.element.setFillMarkers(val)

		color = self.lineColor.GetColour()
		self.element.setLineColor(color)

		val = self.connectorType.GetStringSelection()
		self.element.setConnectorType(val)

		val = self.lineType.GetStringSelection()
		wxval = NameToStyle(val)
		self.element.setLineType(wxval)

		val = self.lineWidth.GetValue()
		self.element.setLineWidth(val)

		self.graph.update()

	def ok(self,event):
		self.apply(event)
		self.EndModal(wx.ID_OK)

