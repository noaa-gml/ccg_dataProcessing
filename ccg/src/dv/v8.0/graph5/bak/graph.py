import wx

from axis import *
from crosshair import *
from legend import *
from printout import *


#####################################################################3333
class Graph(wx.Window):

    def __init__(self, *args, **kwargs):
        """Constructs a panel, which can be a child of a frame or
        any other non-control window"""

        wx.Window.__init__(self, *args, **kwargs)

	c = self.GetBackgroundColour()

	self.margin = 10
	self.plotareaColor = wx.Colour(255,255,255)
	self.backgroundColor = c

	# Grid stuff
	self.gridPen = wx.Pen(wx.Colour(128,128,128), 1, wx.SOLID)
	self.subgridPen = wx.Pen(wx.Colour(128,128,128), 1, wx.DOT)
        self.grid_xaxis = 0
	self.grid_yaxis = 0
	self.showSubgrid = 0
	self.showGrid = 0

	self.elements = []
	self.elementShowList = []
	self.crosshair = Crosshair(self)
	self._zoomEnabled = 1
	self.axes = []
	self.xaxisId = -1
	self.yaxisId = -1

       # Things for printing
        self.print_data = wx.PrintData()
        self.print_data.SetPaperId(wx.PAPER_LETTER)
        self.print_data.SetOrientation(wx.LANDSCAPE)
        self.pageSetupData= wx.PageSetupDialogData()
        self.pageSetupData.SetMarginBottomRight((25,25))
        self.pageSetupData.SetMarginTopLeft((25,25))
        self.pageSetupData.SetPrintData(self.print_data)
        self.printerScale = 1

        # set curser as cross-hairs
        self.SetCursor(wx.CROSS_CURSOR)

        # Create some mouse events for zooming
        self.Bind(wx.EVT_LEFT_DOWN, self.OnMouseLeftDown)
        self.Bind(wx.EVT_LEFT_UP, self.OnMouseLeftUp)
        self.Bind(wx.EVT_MOTION, self.OnMotion)
#        self.Bind(wx.EVT_LEFT_DCLICK, self.OnMouseDoubleClick)
        self.Bind(wx.EVT_RIGHT_DOWN, self.OnMouseRightDown)
        self.Bind(wx.EVT_RIGHT_UP, self.OnMouseRightUp)

	# Add default x axis and y axis
	self.addXAxis("")
	self.addYAxis("")

	# Add a title and legend
	self.title = Title()
	self.title.text = "This is the graph title"
	self.legend = Legend()
	self.legend.title.text = ""


        # OnSize called to make sure the buffer is initialized.
        # This might result in OnSize getting called twice on some
        # platforms at initialization, but little harm done.
#        self.OnSize(None) # sets the initial size based on client size
        Size  = self.GetClientSize()
        Size.width = max(1, Size.width)
        Size.height = max(1, Size.height)
	self._setSize(Size.width, Size.height)
        self._Buffer = wx.EmptyBitmap(Size.width, Size.height)

	self.Bind(wx.EVT_PAINT, self.OnPaint)
        self.Bind(wx.EVT_SIZE, self.OnSize)

    ############################################################################
    # Redraw the graph
    #---------------------------------------------------------------------------
    def update(self):
#	self.OnSize(None)
	self._draw()
	print "update"
	self.OnPaint(wx.PaintEvent())
#        dc = wx.BufferedPaintDC(self, self._Buffer)
#	wx.BufferedDC(self.dc, self._Buffer)

    #---------------------------------------------------------------------------
    def OnSize(self,event):
        # The Buffer init is done here, to make sure the buffer is always
        # the same size as the Window
        Size  = self.GetClientSize()
        Size.width = max(1, Size.width)
        Size.height = max(1, Size.height)
	self._setSize(Size.width, Size.height)

	print "size event"

        # Make new offscreen bitmap: this bitmap will always have the
        # current drawing in it, so it can be used to save the image to
        # a file, or whatever.
        self._Buffer = wx.EmptyBitmap(Size.width, Size.height)
	self._draw()

    #---------------------------------------------------------------------------
    def OnPaint(self, event):
        # All that is needed here is to draw the buffer to screen
	print "got paint event"
        dc = wx.BufferedPaintDC(self, self._Buffer)

    def _setSize(self, width, height):
	self.width = width
	self.height = height

    ############################################################################
    # Routines dealing with axes of the graph
    #---------------------------------------------------------------------------
    def addXAxis(self, title):
	id = self.xaxisId + 1
	axis = Axis("x", id)
	axis.title.text = title
	self.axes.append(axis)
	self.xaxisId += 1
	return axis

    #---------------------------------------------------------------------------
    def addYAxis(self, title):
	id = self.yaxisId + 1
	axis = Axis("y", id)
	axis.title.text = title
	self.axes.append(axis)
	self.yaxisId += 1
	return axis

    #---------------------------------------------------------------------------
    def getXAxis(self,id):
	for axis in self.axes:
		if axis.isXAxis() and axis.id == id:
			return axis

	raise ValueError, str(type) + ': illegal X axis specification'

    #---------------------------------------------------------------------------
    def getYAxis(self,id):
	
	for axis in self.axes:
		if axis.isYAxis() and axis.id == id:
			return axis

	raise ValueError, str(id) + ': illegal Y axis specification'

    ############################################################################
    # Routines dealing with data elements of the graph
    #---------------------------------------------------------------------------
    # Add a data element to the graph
    def addDataset(self,element):
	self.elements.append(element)
	self.update()

    #---------------------------------------------------------------------------
    # Return a dataset given its name
    def getDataset(self,name):
	for element in self.elements:
		if element.name == name:
			return element

	raise ValueError, str(name) + ': illegal dataset name'
	
    #---------------------------------------------------------------------------
    # Get a list of dataset names that have been added to this graph
    def getDatasetNames(self):
	tmplist = []
	for element in self.elements:
		tmplist.append(element.name)

	return tmplist

    #---------------------------------------------------------------------------
    # Set list of dataset names to display
    # User can not display every dataset, or can change the order in which
    # they are drawn.  Can also be empty to reset to all datasets
    def showDatasets(self,list):
	self.elementShowList = list
	self.update()

    def removeDataset(self,element):
	self.elements.remove(element)
	self.update()


    ############################################################################
    # Routines dealing with drawing the graph
    #---------------------------------------------------------------------------
    def _draw(self, dc=None):

        if dc == None:
		self.dc = wx.BufferedDC(wx.ClientDC(self), self._Buffer)
		self.dc.Clear()
	else:
		self.dc = dc

#        self.dc.BeginDrawing()

	self.set_sizes()

	# Fill the window with background color
        self.dc.SetPen(wx.Pen(wx.BLACK))
        self.dc.SetBrush(wx.Brush(self.backgroundColor, wx.SOLID))
	self.dc.DrawRectangle(0, 0, self.width, self.height)
	
	# Fill plotting area with plot area color
        self.dc.SetBrush(wx.Brush(self.plotareaColor, wx.SOLID))
	self.dc.DrawRectangle(self.xleft, self.ytop, self.plot_width+1, self.plot_height+1)

	self.draw_axes()
	self.draw_title()
	self.draw_legend()

	self.dc.SetClippingRegion (self.xleft, self.ytop, self.plot_width, self.plot_height)
	self.draw_data()

#       self.dc.EndDrawing()

    #---------------------------------------------------------------------------
    def draw_data(self):
#	list = self.getShowList()
#	for name in list
#		element = self.getDataset(name)
#		element.draw(self)

	if len(self.elementShowList):
		for name in self.elementShowList:
			element = self.getDataset(name)
			element.draw(self)
	else:
		for element in self.elements:
			element.draw(self)

    #---------------------------------------------------------------------------
    def draw_title(self):
	self.title.draw(self)

    #---------------------------------------------------------------------------
    def draw_legend(self):
	self.legend.draw(self)

    #---------------------------------------------------------------------------
    # Draw axis tic labels and title
    def draw_axes(self):

	for axis in self.axes:
		axis.draw(self)

	if self.showSubgrid:
		axis = self.getXAxis(self.grid_xaxis)
		axis.draw_subgrid(self)

		axis = self.getYAxis(self.grid_yaxis)
		axis.draw_subgrid(self)
		
	if self.showGrid:
		axis = self.getXAxis(self.grid_xaxis)
		axis.draw_grid(self)

		axis = self.getYAxis(self.grid_yaxis)
		axis.draw_grid(self)


    #---------------------------------------------------------------------------
    def set_sizes(self):

	# Get plot area height, legend size, plot width
	for axis in self.axes:
		axis.setSize(self)
	
	self.set_graph_height()
	self.set_axis_limits()
	self.set_legend_size()
	self.set_graph_width()

	for axis in self.axes:
		axis.setLocation(self)
		axis.setRatio()

	self.legend.setLocation(self)

    #---------------------------------------------------------------------------
    # Find and set the maximum and minimum values for each axis
    def set_axis_limits(self):
	for axis in self.axes:
		axis.setLimits(self)


    #---------------------------------------------------------------------------
    def set_legend_size(self):
	self.legend.setSize(self)

    #---------------------------------------------------------------------------
    def set_graph_width(self):

	w1 = 0
	w2 = 0
	for axis in self.axes:
		if axis.isYAxis():
			if axis.id % 2 == 0:
				w1 += axis.width
			else:
				w2 += axis.width

	self.xleft = w1 + self.margin
	self.xright = self.width - self.legend.width - self.margin - w2
	self.plot_width = self.xright - self.xleft
	

    #---------------------------------------------------------------------------
    def set_graph_height(self):
	# Get x axis height
	h1 = 0
	h2 = 0
	for axis in self.axes:
		if axis.isXAxis():
			if axis.id % 2 == 0:
				h1 += axis.height
			else:
				h2 += axis.height

	# Get title height
	titleh = self.title.getHeight(self.dc)

	self.ybottom = self.height - h1 - self.margin
	self.ytop = titleh + self.margin + h2
	self.plot_height = self.ybottom - self.ytop


    ###########################################################################
    # event handlers
    #---------------------------------------------------------------------------
    def OnMotion(self, event):
	x,y = event.GetPosition()
	if event.LeftIsDown():
		if self._zoomEnabled:
			if self.inplotregion(x,y):
				self._drawRubberBand (event)
				self.lastx = x
				self.lasty = y
				self._drawRubberBand (event)
		else:
			if self.inplotregion(self.lastx,self.lasty):
				self.crosshair.draw(self,event)
			self.lastx = x
			self.lasty = y
			if self.inplotregion(x,y):
				self.crosshair.draw(self,event)

    #---------------------------------------------------------------------------
    def OnMouseLeftDown(self, event):
	x,y = event.GetPosition()

	if self._zoomEnabled:
		self.startx = x
		self.starty = y
		self.lastx = x
		self.lasty = y
		if self.inplotregion(x,y):
			self._drawRubberBand (event)
	else:
		self.lastx = x
		self.lasty = y
		if self.inplotregion(x,y):
			self.crosshair.draw(self,event)

	if self.legend.inLegendRegion(x,y):
		element = self.legend.getElement(self,x,y)
		if element != "":
			element.hidden = not element.hidden
			self.update()

    #---------------------------------------------------------------------------
    def OnMouseLeftUp(self, event):
	x,y = event.GetPosition()
	if self._zoomEnabled:
		if self.startx == self.lastx or self.starty == self.lasty:
			return
#		self._drawRubberBand (event)
#		xp,yp = self.PixelToUser(x,y)

		for axis in self.axes:
			if axis.isXAxis():
				p1 = self.PixelToUserX(self.lastx, axis)
				p0 = self.PixelToUserX(self.startx, axis)
			if axis.isYAxis():
				p1 = self.PixelToUserY(self.lasty, axis)
				p0 = self.PixelToUserY(self.starty, axis)

			if p0 > p1:
				t = p1
				p1 = p0
				p0 = t

			axis.umin = p0
			axis.umax = p1
			axis.autoscale = False
			axis.zoomstack.append([p0,p1])


		self.update()
		
	else:
		if self.inplotregion(x,y):
			self.crosshair.draw(self,event)
		self.crosshair.hide()

    #---------------------------------------------------------------------------
    def OnMouseRightDown(self, event):
	x,y = event.GetPosition()

	if self.inplotregion(x,y):
		if not self._zoomEnabled or len(self.axes[0].zoomstack) == 0:
			self.makeContextMenu()

	if self.legend.inLegendRegion(x,y):
		element = self.legend.getElement(self,x,y)
		if element != "":
			self.makeElementMenu(element)

    #---------------------------------------------------------------------------
    def OnMouseRightUp(self, event):
	x,y = event.GetPosition()
	if self._zoomEnabled and self.inplotregion(x,y):
		for axis in self.axes:
			n = len(axis.zoomstack)
			if n > 1:
				b = axis.zoomstack[n-2]
				axis.zoomstack = axis.zoomstack[:-1]
				axis.umin = b[0]
				axis.umax = b[1]
			else:
				axis.autoscale = True
				axis.zoomstack = []

		self.update()

    #---------------------------------------------------------------------------
    def OnMouseDoubleClick(self, event):
	x,y = event.GetPosition()

	if self.inplotregion(x,y):
		print "in plot region"

	if self.legend.inLegendRegion(x,y):
		print "in legend region"

    #---------------------------------------------------------------------------
    def _drawRubberBand(self,event):
#	x,y = event.GetPosition()
	w = self.lastx-self.startx
	h = self.lasty-self.starty
	dc = wx.ClientDC( self )
        dc.SetBrush(wx.Brush( wx.Colour(50,17,0,0), wx.SOLID ) )
        dc.SetPen(wx.Pen( wx.WHITE ) )
        dc.SetLogicalFunction(wx.XOR)
	dc.DrawRectangle (self.startx, self.starty, w, h)
	

    ############################################################################
    # Utilities
    #---------------------------------------------------------------------------
    def PixelToUserX(self, x, axis):
	xp = (x-self.xleft)/ axis.ratio + axis.min
	return xp

    def PixelToUserY(self, y, axis):
	yp = (self.ybottom - y)/ axis.ratio + axis.min
	return yp

    def UserToPixelX(self,x, axis):
	a = around((x - axis.min) * axis.ratio + self.xleft)
	return a

    def UserToPixelY(self,y, axis):
	a = around(self.ybottom - ((y - axis.min) * axis.ratio))
	return a

    def inplotregion(self, x, y):
	
	if y < self.ybottom and y > self.ytop and  x > self.xleft and x < self.xright:
		return 1
	else:
		return 0
	

    ############################################################################
    # Plot area context menu
    #---------------------------------------------------------------------------
    def makeContextMenu(self):

	plotMenu = wx.Menu()
	plotMenu.Append(301, "Graph Preferences...")
	plotMenu.AppendSeparator()
	plotMenu.Append(302, "Add X Axis")
	plotMenu.Append(303, "Add Y Axis")

	self.Bind(wx.EVT_MENU, self.OnPopupOne, id=302)
	self.Bind(wx.EVT_MENU, self.OnPopupTwo, id=303)

	# Delete axis menus
	m1 = wx.Menu()
	m2 = wx.Menu()
	nx = 0
	ny = 0
	for axis in self.axes:
		if axis.isXAxis():
			s = "X%d" % axis.id
			id = 100+axis.id
			m1.Append(id, s)
			self.Bind(wx.EVT_MENU, self.remove_axis, id=id)
			nx += 1
		if axis.isYAxis():
			s = "Y%d" % axis.id
			id = 200+axis.id
			m2.Append(id, s)
			self.Bind(wx.EVT_MENU, self.remove_axis, id=id)
			ny += 1

	# Should disable if only 1 axis left
	plotMenu.AppendMenu(304, "Delete X Axis", m1)
	if nx <= 1:
		plotMenu.Enable(304,False)
	
	# Should disable if only 1 axis left
	plotMenu.AppendMenu(305, "Delete Y Axis", m2)
	if ny <= 1:
		plotMenu.Enable(305,False)

	if hasattr(self,"saveElement"):
		if self.saveElement:
			plotMenu.Append(402, "Paste Dataset")
			self.Bind(wx.EVT_MENU, self.paste, id=402)

	plotMenu.AppendSeparator()
	plotMenu.Append(555, "Print Preview")
	self.Bind(wx.EVT_MENU, self.printPreview, id=555)
		
	self.PopupMenu(plotMenu)

    #---------------------------------------------------------------------------
    def paste(self,event):
	self.addDataset(self.saveElement)

    #---------------------------------------------------------------------------
    def OnPopupOne(self, event):
	self.addXAxis("X Axis Title")
	self.update()

    #---------------------------------------------------------------------------
    def OnPopupTwo(self, event):
	self.addYAxis("Y Axis Title")
	self.update()

    #---------------------------------------------------------------------------
    # Remove an axis
    def remove_axis(self,event):
	id = event.GetId()
	if id >= 200:
		type = "y"
		axisid = id - 200
	else:
		type = "x"
		axisid = id - 100

	for axis in self.axes:
		if axis.id == axisid and axis.type == type:
			print "delete ", axis.type, " axis ", axisid
			for element in self.elements:
				if type == "x":
					if element.xaxis == axisid:
						element.xaxis = 0
				else:
					if element.yaxis == axisid:
						element.yaxis = 0
						
			self.axes.remove(axis)
			self.update()



    ############################################################################
    # Handle the legend context menu
    #---------------------------------------------------------------------------
    def makeElementMenu(self,element):

	self.popupElement = element

	m4 = wx.Menu()
	m5 = wx.Menu()
	for axis in self.axes:
		if axis.isXAxis():
			s = "X%d" % axis.id
			id = 1000+axis.id
			m4.Append(id, s)
			self.Bind(wx.EVT_MENU, self.map_axis, id=id)
			if element.xaxis == axis.id:
				m4.Enable(id,False)
		if axis.isYAxis():
			s = "Y%d" % axis.id
			id = 2000+axis.id
			m5.Append(id, s)
			self.Bind(wx.EVT_MENU, self.map_axis, id=id)
			if element.yaxis == axis.id:
				m5.Enable(id,False)
			
	id1 = wx.NewId()
	id2 = wx.NewId()
	id3 = wx.NewId()
	id4 = wx.NewId()
	id5 = wx.NewId()
	id6 = wx.NewId()
	id7 = wx.NewId()
	id8 = wx.NewId()
	id9 = wx.NewId()
	id10 = wx.NewId()


	Menu = wx.Menu()
	Menu.Append(id1, "Edit Attributes...", "hint 1")
	Menu.AppendMenu(id2, "Map X Axis", m4)
	Menu.AppendMenu(id3, "Map Y Axis", m5)
	Menu.AppendSeparator()

	Menu.Append(id4, "To Front", "hint 4")
	Menu.Append(id5, "To Back", "hint 4")
	Menu.Append(id6, "Forward By One", "hint 4")
	Menu.Append(id7, "Backward By One", "hint 4")
	Menu.AppendSeparator()
	Menu.Append(id8, "Cut", "hint 4")
	Menu.Append(id9, "Copy", "hint 4")
	Menu.Append(id10, "Delete", "hint 4")

	self.Bind(wx.EVT_MENU, self.toFront, id=id4)
	self.Bind(wx.EVT_MENU, self.toBack, id=id5)
	self.Bind(wx.EVT_MENU, self.forward, id=id6)
	self.Bind(wx.EVT_MENU, self.backward, id=id7)
	self.Bind(wx.EVT_MENU, self.cutElement, id=id8)
	self.Bind(wx.EVT_MENU, self.copyElement, id=id9)
	self.Bind(wx.EVT_MENU, self.remove, id=id10)

	self.PopupMenu(Menu)


    #---------------------------------------------------------------------------
    def toFront(self,event):
	element = self.popupElement
	if len(self.elementShowList): 
		list = self.elementShowList
	else:
		list = self.getDatasetNames()
	list.remove(element.name)
	list.append(element.name)
	self.showDatasets(list)

    #---------------------------------------------------------------------------
    def toBack(self,event):
	element = self.popupElement
	if len(self.elementShowList): 
		list = self.elementShowList
	else:
		list = self.getDatasetNames()
	list.remove(element.name)
	list.insert(0,element.name)
	self.showDatasets(list)

    #---------------------------------------------------------------------------
    def forward(self,event):
	element = self.popupElement
	if len(self.elementShowList): 
		list = self.elementShowList
	else:
		list = self.getDatasetNames()
	idx = list.index(element.name)
	list.remove(element.name)
	list.insert(idx+1,element.name)
	self.showDatasets(list)
	

    #---------------------------------------------------------------------------
    def backward(self,event):
	element = self.popupElement
	if len(self.elementShowList): 
		list = self.elementShowList
	else:
		list = self.getDatasetNames()
	idx = list.index(element.name)
	list.remove(element.name)
	idx -= 1
	if idx < 0:
		idx = 0
	list.insert(idx,element.name)
	self.showDatasets(list)

    #---------------------------------------------------------------------------
    def remove(self,event):
	element = self.popupElement
	self.removeDataset(element)

    #---------------------------------------------------------------------------
    def cutElement(self,event):
	element = self.popupElement
	self.saveElement = element
	self.removeDataset(element)

    #---------------------------------------------------------------------------
    def copyElement(self,event):
	element = self.popupElement
	self.saveElement = element

    #---------------------------------------------------------------------------
    # Map an axis
    def map_axis(self,event):
	element = self.popupElement
	id = event.GetId()
	if id >= 2000:
		type = "y"
		axisid = id - 2000
		element.yaxis = axisid
		
	else:
		type = "x"
		axisid = id - 1000
		print "axisid = ", axisid
		element.xaxis = axisid

	self.update()



    ############################################################################
    #---------------------------------------------------------------------------
    def printPreview(self, event=None):
        """Print-preview current plot."""
        printout = PlotPrintout(self)
        printout2 = PlotPrintout(self)
        self.preview = wx.PrintPreview(printout, printout2, self.print_data)
        if not self.preview.Ok():
            wx.MessageDialog(self, "Print Preview failed.\n" \
                               "Check that default printer is configured\n", \
                               "Print error", wx.OK|wx.CENTRE).ShowModal()
        self.preview.SetZoom(50)
        # search up tree to find frame instance
        frameInst= self
        while not isinstance(frameInst, wx.Frame):
            frameInst= frameInst.GetParent()
        frame = wx.PreviewFrame(self.preview, frameInst, "Preview")
        frame.Initialize()
        frame.SetPosition(self.GetPosition())
        frame.SetSize((525,425))
        frame.Centre(wx.BOTH)
        frame.Show(True)
