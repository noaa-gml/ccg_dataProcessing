import wx
from numpy import *
#import Numeric as _Numeric

#####################################################################3333
class Title:

    def __init__(self):
	self.show_text = 1
	self.text = ""
	self.margin = 0
	self.font = wx.Font(12, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	self.color = wx.Colour(0,0,0)

    #---------------------------------------------------------------------------
    def draw(self,graph):
	graph.dc.SetFont (self.font)
	xp = (graph.xright - graph.xleft)/2 + graph.xleft
	(w,h0) = graph.dc.GetTextExtent(self.text)

	# Find height of all odd numbered x axes
	for axis in graph.axes:
		if axis.isXAxis():
			if axis.id %2 == 1:
				h = axis.height
				h0 += h
				

	yp = graph.ytop - h0 - self.margin
	graph.dc.SetTextForeground(self.color)
	graph.dc.DrawText (self.text, xp - w/2, yp)

    #---------------------------------------------------------------------------
    def getHeight(self, dc):
	h = 0
	if (self.show_text):
		dc.SetFont (self.font)
		h = dc.GetCharHeight()
		h += self.margin

	return h

#####################################################################3333
class Axis:

    def __init__(self, type, id):

	""" General axis parameters """
	self.autoscale = 1
	self.type = type
	self.id = id
	self.round_endpoints = 1
	self.min = 0
	self.max = 1.0
	self.umin = 0
	self.umax = 1.0
	self.dmin = 0
	self.dmax = 1.0
	self.width = 1
	self.ratio = 1.0
	self.has_data = 0
	self.label_width = 0
	self.location = ""
	self.x1 = 0
	self.x2 = 0
	self.y1 = 0
	self.y2 = 0
	self.height = 0
	self.width = 0
	self.axis_spacing = 20
	self.zoomstack = []

	""" Axis Origin Parameters (draw a grid line where axis value=0) """
	self.drawOrigin = 1
	self.originPen = wx.Pen(wx.Colour(168,168,168), 1, wx.SOLID)

	""" Axis Tic Parameters """
	self.ticInterval = 0.2
	self.uticInterval = 0.2
	self.subticDensity = 4
	self.usubticDensity = 4
	self.ticType = 1
	self.autoTics = 1
	self.ticColor = wx.BLACK
	self.ticLength = 8
	self.subticLength = 5
	self.pen = wx.Pen(wx.Colour(0,0,0), 1, wx.SOLID)
	self.default_numtics = 4

	""" Tic Label Parameters """
	self.centerLabels = 0
	self.showLabels = 1
	self.draw_numbers = 1
	self.label_margin = 2
	self.labelFormat = "%g"
	self.supressEndlabels = 0
	self.font = wx.Font(10, wx.FONTFAMILY_DEFAULT, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
	self.color = wx.BLACK

	""" Axis Title parameters """
	self.title = Title()

	if not (self.isXAxis or self.isYAxis):
		raise ValueError, str(type) + ': illegal axis specification'

		
    #-----------------------------------------------------------------------------
    # Draw the axis
    def draw(self,graph):
	self.draw_axis(graph)
	self.draw_tics(graph)
	self.draw_origin(graph)
	self.draw_labels(graph)
	self.title_axis(graph)

    #-----------------------------------------------------------------------------
    # Draw the axis line.  No tics or labels
    def draw_axis(self,graph):
	graph.dc.SetPen(self.pen)
	graph.dc.DrawLine(self.x1, self.y1, self.x2, self.y2)

    #-----------------------------------------------------------------------------
    # Set the end point locations of the axis
    # For multiple axes, the location depends on the axes before it.
    def setLocation(self,graph):

	if self.isXAxis():
		# Add up the heights of all the x axes with an id lower than this one,
		# and where the id has the same even or odd value
		h = 0
		even_odd = self.id % 2
		for axis in graph.axes:
			if axis.isXAxis() and axis.id % 2 == even_odd and axis.id < self.id:
				h += axis.height

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

	if self.isYAxis():
		# Add up the widths of all the y axes with an id lower than this one,
		# and where the id has the same even or odd value
		w = 0
		even_odd = self.id % 2
		for axis in graph.axes:
			if axis.isYAxis() and axis.id % 2 == even_odd and axis.id < self.id:
				w += axis.width

		if even_odd == 0:
			self.x1 = graph.xleft - w
			self.x2 = graph.xleft - w
			self.y1 = graph.ybottom
			self.y2 = graph.ytop
		else:
			self.x1 = graph.xright + w
			self.x2 = graph.xright + w
			self.y1 = graph.ybottom
			self.y2 = graph.ytop

    #-----------------------------------------------------------------------------
    # Set the pixels per user unit ratio value for the axis
    def setRatio(self):
	if self.isXAxis():
		self.ratio = (self.x2 - self.x1) / (self.max - self.min)
	else:
		self.ratio = (self.y1 - self.y2) / (self.max - self.min)

    #-----------------------------------------------------------------------------
    # Draw a grid line where axis value = 0
    def draw_origin(self,graph):

	if self.max > 0 and self.min < 0:
		graph.dc.SetPen(self.originPen)

		if self.isXAxis() and self.drawOrigin:
			xp = graph.UserToPixelX(0.0, self)
			xp2 = xp
			yp  = graph.ytop + 1
			yp2 = graph.ybottom

		if self.isYAxis() and self.drawOrigin:
			yp = graph.UserToPixelY(0.0, self)
			yp2 = yp
			xp  = graph.xleft + 1
			xp2 = graph.xright

		graph.dc.DrawLine(xp,yp, xp2, yp2)


    #-----------------------------------------------------------------------------
    # Draw the major and minor tic marks
    def draw_tics(self,graph):

	# Do subtics first
	graph.dc.SetPen(self.pen)

	vals = arange(self.min, self.max + self.ticInterval/self.subticDensity, self.ticInterval/self.subticDensity)
	list = []
	for val in vals:
		if val > self.max:
			continue
		if self.isXAxis():
			xp = graph.UserToPixelX(val, self)
			xp2 = xp
			yp = self.y1
			if self.id % 2 == 0:
				yp2 = yp - self.subticLength
			else:
				yp2 = yp + self.subticLength

		if self.isYAxis():
			yp = graph.UserToPixelY(val, self)
			yp2 = yp
			xp = self.x1
			if self.id % 2 == 0:
				xp2 = xp + self.subticLength
			else:
				xp2 = xp - self.subticLength

		list.append([xp,yp,xp2,yp2])

	graph.dc.DrawLineList(list)


	# Do major tics
	graph.dc.SetPen(self.pen)

	list = []
	vals = arange(self.min, self.max + self.ticInterval, self.ticInterval)
	for val in vals:
		if val>self.max:
			continue
		if self.isXAxis():
			xp = graph.UserToPixelX(val, self)
			xp2 = xp
			yp = self.y1
			if self.id %2 == 0:
				yp2 = yp - self.ticLength
			else:
				yp2 = yp + self.ticLength

		if self.isYAxis():
			yp = graph.UserToPixelY(val, self)
			yp2 = yp
			xp = self.x1
			if self.id %2 == 0:
				xp2 = xp + self.ticLength
			else:
				xp2 = xp - self.ticLength

		list.append([xp,yp,xp2,yp2])

	graph.dc.DrawLineList(list)

	
    #-----------------------------------------------------------------------------
    # Draw the grid lines
    def draw_subgrid(self,graph):

	# Do subgrid
	graph.dc.SetPen(graph.subgridPen)
	list = []
	vals = arange(self.min, self.max + self.ticInterval/self.subticDensity, self.ticInterval/self.subticDensity)
	for val in vals:
		if val >= self.max or val == self.min:
			continue
		if self.isXAxis():
			xp = graph.UserToPixelX(val, self)
			xp2 = xp
			yp = graph.ytop
			yp2 = graph.ybottom
		else:
			yp = graph.UserToPixelY(val, self)
			yp2 = yp
			xp = graph.xleft
			xp2 = graph.xright

		list.append([xp,yp,xp2,yp2])

	graph.dc.DrawLineList(list)


    #-----------------------------------------------------------------------------
    def draw_grid(self, graph):
	graph.dc.SetPen(graph.gridPen)
	list = []
	vals = arange(self.min, self.max + self.ticInterval, self.ticInterval)
	for val in vals:
		if val >= self.max or val == self.min:
			continue
		if self.isXAxis():
			xp = graph.UserToPixelX(val, self)
			xp2 = xp
			yp = graph.ytop
			yp2 = graph.ybottom
		else:
			yp = graph.UserToPixelY(val, self)
			yp2 = yp
			xp = graph.xleft
			xp2 = graph.xright

		list.append([xp,yp,xp2,yp2])

	graph.dc.DrawLineList(list)

    #-----------------------------------------------------------------------------
    # Draw the major tic labels
    def draw_labels(self, graph):

	graph.dc.SetFont (self.font)
	graph.dc.SetTextForeground(self.color)

	vals = arange(self.min, self.max + self.ticInterval, self.ticInterval)
	for val in vals:
		if val>self.max:
			continue
		if abs(val) < 1e-15:
			val = 0
		s = self.labelFormat % val 
		(w,h) = graph.dc.GetTextExtent(s)
		w *= graph.printerScale
		h *= graph.printerScale
		if self.isXAxis():
			if self.id % 2 == 0:
				xp = graph.UserToPixelX(val, self)
				xp -= w/2
				yp = self.y1 + self.label_margin
			else:
				xp = graph.UserToPixelX(val, self)
				xp -= w/2
				yp = self.y1 - self.label_margin - h
		else:
			if self.id % 2 == 0:
				yp = graph.UserToPixelY(val, self)
				yp -= h/2
				xp = self.x1 - w - self.label_margin
			else:
				yp = graph.UserToPixelY(val, self)
				yp -= h/2
				xp = self.x1 + self.label_margin

		graph.dc.DrawText(s, xp, yp)
			
    #-----------------------------------------------------------------------------
    # Draw the axis title
    def title_axis(self,graph):

	if self.isXAxis():

		graph.dc.SetFont (self.font)
		(w,h1) = graph.dc.GetTextExtent("test")

		graph.dc.SetFont (self.title.font)
		label = self.title.text
		(w,h) = graph.dc.GetTextExtent(label)
		graph.dc.SetTextForeground(self.title.color)

		xp = (self.x2 - self.x1)/2 + self.x1

		if self.id % 2 == 0:
			yp = self.y1 + h + self.label_margin
		else:
			yp = self.y1 - h - h1 - self.label_margin

		graph.dc.DrawText (label, xp - w/2, yp)
	else:
		w0 = self.width - self.axis_spacing
		yp = (graph.ybottom - graph.ytop)/2 + graph.ytop

		graph.dc.SetFont (self.title.font)
		label = self.title.text
		(w,h) = graph.dc.GetTextExtent(label)
		graph.dc.SetTextForeground(self.title.color)

		if self.id % 2 == 0:
			xp = self.x1 - w0
			graph.dc.DrawRotatedText (label, xp, yp+w/2, 90.0)
		else:
			xp = self.x1 + w0
			graph.dc.DrawRotatedText (label, xp, yp-w/2, -90.0)

    #-----------------------------------------------------------------------------
    def setSize(self, graph):
	self.get_width(graph)
	self.get_height(graph)

    #-----------------------------------------------------------------------------
    # Get the width of a y axis.  
    # This includes:
    #    label margin between axis line and tic labels
    #    the width of the longest tic label, 
    #    title margin between tic labels and title
    #    the height of the title,
    #    spacing between title and next axis
    def get_width(self,graph):
	w = self.label_margin
	if self.isYAxis():
		if self.draw_numbers:
			graph.dc.SetFont(self.font)
			vals = arange(self.min, self.max + self.ticInterval, self.ticInterval)
			width = 0
			for val in vals:
				if abs(val) < 1e-15:
					val = 0
				s = self.labelFormat % val 
				(a,b) = graph.dc.GetTextExtent(s)
				if (a > width):
					width = a
			w += width

		if self.title.show_text:
			graph.dc.SetFont(self.title.font)
			(a,b) = graph.dc.GetTextExtent(self.title.text)
			w += b
			w += self.title.margin

	w += self.axis_spacing
	w *= graph.printerScale
	self.width = w

	return w

    #-----------------------------------------------------------------------------
    # Get the height of a x axis.  
    #This includes:
    #    label margin between axis line and tic labels
    #    the height of the tic labels, 
    #    title margin between tic labels and title
    #    the height of the title,
    #    spacing between title and next axis
    def get_height(self,graph):
	h = self.label_margin
	if self.isXAxis():
		if self.draw_numbers:
			graph.dc.SetFont(self.font)
			h += graph.dc.GetCharHeight()
		if self.title.show_text:
			graph.dc.SetFont(self.title.font)
			h += graph.dc.GetCharHeight()
			h += self.title.margin

	h += self.axis_spacing
	h *= graph.printerScale
	self.height = h

	return h

    #---------------------------------------------------------------------------
    def NiceNum(self, val, round):
	expt = floor(log10(val))
	frac = val / 10.**expt;
	if round:
		if frac < 1.5:
			nice = 1.0
		elif frac < 3.0:
			nice = 2.0
		elif frac < 7.0:
			nice = 5.0
		else:
			nice = 10.0;
 
	else:
		if frac <= 1.0:
			nice = 1.0
		elif frac <= 2.0:
			nice = 2.0
		elif frac <= 5.0:
			nice = 5.0
		else:
			nice = 10.0


	x = nice * 10.**expt
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
    # Set the minimum and maximum values for the axis
    def setLimits(self, graph):

	if self.autoscale:
		if len(graph.elements) == 0:
			self.dmax = 1.0
			self.dmin = 0.0
		else:
			self.dmax = -999.99E15
			self.dmin = 999.99e15
			# Find elements that use this axis
			found = 0
			for element in graph.elements:
				if not element.hidden:
					if self.isXAxis():
						if element.xaxis == self.id:
							found = 1
							if element.xmax > self.dmax:
								self.dmax = element.xmax
							if element.xmin < self.dmin:
								self.dmin = element.xmin
					if self.isYAxis():
						if element.yaxis == self.id:
							found = 1
							if element.ymax > self.dmax:
								self.dmax = element.ymax
							if element.ymin < self.dmin:
								self.dmin = element.ymin
			if not found:
				self.dmax = 1.0
				self.dmin = 0.0


		range = self.dmax - self.dmin
#		print "range = ", range
		range = self.NiceNum(range, 0)
		step = self.NiceNum(range/self.default_numtics, 1)

		# Find the outer tick values. Add 0.0 to prevent getting -0.0. */
		self.min = tickMin = floor(self.dmin / step) * step + 0.0
		self.max = tickMax = ceil(self.dmax / step) * step + 0.0

		nTicks = round(((tickMax - tickMin) / step) + 1)
		self.ticInterval = step

	else:
		range = self.umax - self.umin
		range = self.NiceNum(range, 0)
		step = self.NiceNum(range/self.default_numtics, 1)
		self.min = tickMin = floor(self.umin / step) * step + 0.0
		self.max = tickMax = ceil(self.umax / step) * step + 0.0
		nTicks = round(((tickMax - tickMin) / step) + 1)
		self.ticInterval = step

