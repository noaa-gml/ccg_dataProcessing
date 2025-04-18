
import wx
from axis import Title
from numpy import *

#####################################################################3333
class Legend:

    def __init__(self):

	self.showLegend = True
	self.showLegendBorder = True
	self.x = 0.0
	self.y = 0.0
	self.background = wx.Colour(255,255,255)
	self.foreground = wx.Colour(0,0,0)
	self.autoPosition = True
	self.title = Title()
	self.font = wx.Font(8, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	self.borderWidth = 1
	self.raised = True
	self.margin = 5
	self.width = 0
	self.height = 0
	self.symbol_width = 30
	self.hidden_bg = wx.Colour(255,255,200)

    #---------------------------------------------------------------------------
    def draw(self,graph):
	if not self.showLegend:
		return

	showlist = self.getShowList(graph)
	if len(showlist) == 0:
		return

	# Legend border
	if self.showLegendBorder:
		graph.dc.SetPen(wx.Pen(self.foreground))
		graph.dc.SetBrush(wx.Brush(self.background, wx.SOLID))
		graph.dc.DrawRectangle (self.x, self.y, self.width, self.height)

	# Legend title
	graph.dc.SetFont(self.title.font)
	graph.dc.SetTextForeground(self.title.color)
	(w,h) = graph.dc.GetTextExtent(self.title.text)
	xp = self.x + self.width/2 - w/2
	yp = self.y + self.margin + self.borderWidth
	graph.dc.DrawText (self.title.text, xp, yp)
	yp += h*1.2

	graph.dc.SetFont(self.font)

	# Element names
	showlist = self.getShowList(graph)
	for name in showlist:
		element = graph.getDataset(name)
		(w,h) = graph.dc.GetTextExtent(element.label)

		if element.hidden:
			x0 = self.x + self.margin + self.borderWidth
			y0 = yp
			w0 = self.width - 2*self.borderWidth - 2*self.margin
			h0 = h
#			print "rect is ",x0,x0+w0,y0,y0+h0
			graph.dc.SetPen(wx.Pen(wx.Colour(200,100,100), 1, wx.DOT))
#			graph.dc.SetBrush(wx.Brush(self.background, wx.DOT))
			graph.dc.SetBrush(wx.Brush(self.hidden_bg, wx.DOT))
			graph.dc.DrawRectangle(x0-1,y0-1,w0+2,h0+2)

		x0 = self.x + self.borderWidth + self.margin
		x1 = x0 + self.symbol_width
		y0 = yp + h/2
		y1 = yp + h/2
		pts = transpose([[x0,x1],[y0,y1]])
		element.draw_lines(graph,pts,2)

		x0 = self.x + self.margin + self.borderWidth + self.symbol_width/2
		y0 = yp + h/2
		pts = transpose([[x0],[y0]])
		element.draw_markers(graph,pts, 5)

		xp = x0 + self.margin + self.symbol_width/2
		graph.dc.DrawText (element.label, xp, yp)
		yp += h*1.2


    #---------------------------------------------------------------------------
    def setSize(self,graph):

	showlist = self.getShowList(graph)
	if not self.showLegend or not len(showlist):
		self.width = 0
		self.height = 0
		return

	# Get legend title width
	graph.dc.SetFont(self.title.font)
	(width,height) = graph.dc.GetTextExtent(self.title.text)

	# Now for each data element, get maximum
	# width of label
	graph.dc.SetFont(self.font)
	labelw = 0

	for name in showlist:
		element = graph.getDataset(name)
		(w,h) = graph.dc.GetTextExtent(element.label)
		if w > labelw:
			labelw = w

		height += h * 1.2

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

#	self.width *= graph.printerScale
#	self.height *= graph.printerScale

#	print "printer scale is ", graph.printerScale

    #---------------------------------------------------------------------------
    def setLocation(self,graph):
	if not self.showLegend:
		self.x = 0
		self.y = 0
		return

#        Size  = graph.GetClientSize()
	
	self.x = graph.width - self.margin - self.width
	self.y = graph.ytop + 20


    #---------------------------------------------------------------------------
    def inLegendRegion(self,x,y):
	if x >=self.x and x<=self.x+self.width and y>=self.y and y<=self.y+self.height:
		return 1
	else:
		return 0

    #---------------------------------------------------------------------------
    # Given window x,y location, determine if that location is on a
    # legend element label
    def getElement(self,graph,x,y):

	graph.dc.SetFont(self.title.font)
	(w,h) = graph.dc.GetTextExtent(self.title.text)
	yp = self.y + self.margin + self.borderWidth 
	yp += h*1.2

	# Element names
	graph.dc.SetFont(self.font)
	x0 = self.x + self.margin + self.borderWidth
	w0 = self.width - 2*self.borderWidth - 2*self.margin

	showlist = self.getShowList(graph)
	for name in showlist:
		element = graph.getDataset(name)
		(w,h0) = graph.dc.GetTextExtent(element.label)

		if x>=x0 and x<=x0+w0 and y>=yp and y<=yp+h0:
			return element

		yp += h0*1.2

	return ""

    #---------------------------------------------------------------------------
    # Get list of element names to display in legend
    def getShowList(self,graph):

	if len(graph.elementShowList):
		list = graph.elementShowList
	else:
		list = graph.getDatasetNames()

	return list

