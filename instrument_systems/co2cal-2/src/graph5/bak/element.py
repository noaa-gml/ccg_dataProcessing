
import wx

from numpy import *

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
	self.outlineColor = wx.Colour(0,0,0)
	self.fillColor = wx.Colour(255,255,255)
	self.lineType = wx.SOLID
	self.lineColor = wx.Colour(0,0,0)
	self.lineWidth = 1
	self.outlineWidth = 1
	self.marker = "none"
	self.markerSize = 2

	self.findRange()

    #---------------------------------------------------------------------------
    def draw(self,graph):
	if self.hidden:
		return

	xaxis = graph.getXAxis(self.xaxis)
	yaxis = graph.getYAxis(self.yaxis)
	xscaled = graph.UserToPixelX(self.xdata, xaxis)
	yscaled = graph.UserToPixelY(self.ydata, yaxis)
	pts = transpose([xscaled,yscaled])

	self.draw_lines(graph,pts,self.lineWidth)
	self.draw_markers(graph, pts, self.markerSize)

    #---------------------------------------------------------------------------
    def draw_lines(self,graph,pts,width):
	if self.lineType == "none":
		return

	graph.dc.SetPen(wx.Pen(self.lineColor, width, self.lineType))
	graph.dc.DrawLines(pts)

    #---------------------------------------------------------------------------
    def draw_markers(self, graph, pts, size):
	graph.dc.SetPen(wx.Pen(self.outlineColor, self.outlineWidth, wx.SOLID))
	graph.dc.SetBrush(wx.Brush(self.fillColor, wx.SOLID))

	if self.marker == "square":
		self._square(graph, pts, size)
	if self.marker == "circle":
		self._circle(graph, pts, size)
	if self.marker == "triangle":
		self._triangle(graph, pts, size)
	if self.marker == "triangle_down":
		self._triangle_down(graph, pts, size)
	if self.marker == "diamond":
		self._diamond(graph, pts, size)
	if self.marker == "plus":
		self._plus(graph, pts, size)
	if self.marker == "cross":
		self._cross(graph, pts, size)
	if self.marker == "asterisk":
		self._asterisk(graph, pts, size)
	if self.marker == "square_plus":
		self._square_plus(graph, pts, size)
	if self.marker == "circle_plus":
		self._circle_plus(graph, pts, size)

    #---------------------------------------------------------------------------
    def _circle_plus(self, graph, pts, size):
	self._circle(graph,pts,size)
	self._plus(graph,pts,size)

    #---------------------------------------------------------------------------
    def _square_plus(self, graph, pts, size):
	self._square(graph,pts,size)
	self._plus(graph,pts,size)

    #---------------------------------------------------------------------------
    def _square(self, graph, pts, size):
        fact= 1.0*size
        wh= 2.0*size
        rect= zeros((len(pts),4),float)+[0.0,0.0,wh+1,wh+1]
        rect[:,0:2]= pts-[fact,fact]
        graph.dc.DrawRectangleList(rect.astype(int32))
	
    #---------------------------------------------------------------------------
    def _circle(self, graph, pts, size):
        fact= 1.0*size
        wh= 2.0*size
        rect= zeros((len(pts),4),float)+[0.0,0.0,wh,wh]
        rect[:,0:2]= pts-[fact,fact]
        graph.dc.DrawEllipseList(rect.astype(int32))

    #---------------------------------------------------------------------------
    def _triangle(self, graph, pts, size):
        shape= [(-1.0*size,1.0*size), (1.0*size,1.0*size), (0.0,-1.0*size)]
        poly= array(pts.repeat(3, axis=0))
        poly.shape= (len(pts),3,2)
        poly += shape
        graph.dc.DrawPolygonList(poly.astype(int32))

    #---------------------------------------------------------------------------
    def _triangle_down(self, graph, pts, size):
        shape= [(-1.0*size,-1.0*size), (1.0*size,-1.0*size), (0.0,1.0*size)]
        poly= array(pts.repeat(3, axis=0))
        poly.shape= (len(pts),3,2)
        poly += shape
        graph.dc.DrawPolygonList(poly.astype(int32))

    #---------------------------------------------------------------------------
    def _diamond(self,graph,pts,size):
	shape = [(-1.0*size,0), (0,1.0*size), (1.0*size,0.0), (0.0,-1.0*size)]
        poly= array(pts.repeat(4, axis=0))
        poly.shape= (len(pts),4,2)
        poly += shape
        graph.dc.DrawPolygonList(poly.astype(int32))

    #---------------------------------------------------------------------------
    def _plus(self,graph,pts,size):
	fact= 1.0*size
        for f in [[-fact,0,fact,0],[0,-fact,0,fact]]:
            lines= concatenate((pts,pts),axis=1)+f
            graph.dc.DrawLineList(lines.astype(int32))

    #---------------------------------------------------------------------------
    def _cross(self,graph,pts,size):
	fact= 1.0*size
        for f in [[-fact,-fact,fact,fact],[-fact,fact,fact,-fact]]:
            lines= concatenate((pts,pts),axis=1)+f
            graph.dc.DrawLineList(lines.astype(int32))

    #---------------------------------------------------------------------------
    def _asterisk(self,graph,pts,size):
	fact= 1.0*size
        for f in [[-fact,-fact,fact,fact],[-fact,fact,fact,-fact],[-fact,0,fact,0],[0,-fact,0,fact]]:
            lines= concatenate((pts,pts),axis=1)+f
            graph.dc.DrawLineList(lines.astype(int32))
	

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
	self.marker = marker

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
    def setAxis(self,axis):
	if axis.isXAxis():
		self.xaxis = axis.id
	if axis.isYAxis():
		self.yaxis = axis.id
