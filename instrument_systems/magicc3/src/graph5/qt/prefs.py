

import wx

from linetypes import *

#####################################################################3333
class PreferencesDialog(wx.Dialog):
	def __init__(
		    self, parent, ID, title, size=wx.DefaultSize, pos=wx.DefaultPosition, 
		    style=wx.DEFAULT_DIALOG_STYLE|wx.RESIZE_BORDER,
            ):
                wx.Dialog.__init__(self, parent, -1, title)

		self.graph = parent

		# Main sizer for dialog
		box0 = wx.BoxSizer(wx.VERTICAL)

		nb = wx.Notebook(self, -1, style=wx.BK_DEFAULT)
		box0.Add(nb, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		page = self.makeGeneralPage(nb)
		nb.AddPage(page, "General")

		page = self.makeGridPage(nb)
		nb.AddPage(page, "Grid")

		page = self.makeCrosshairPage(nb)
		nb.AddPage(page, "Crosshairs")

		page = self.makeTitlePage(nb)
		nb.AddPage(page, "Title")

		page = self.makeLegendPage(nb)
		nb.AddPage(page, "Legend")

		#------------------------------------------------
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

	#---------------------------------------------------------------
	def makeGeneralPage(self, nb):

		page = wx.Panel(nb, -1)

		box0 = wx.BoxSizer(wx.VERTICAL)

		#-----
		box = wx.StaticBox(page, -1, "Margins")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		box1 = wx.FlexGridSizer(0,2,2,2)
		sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(page, -1, "Graph Margin:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.margin = wx.SpinCtrl(page, -1, str(self.graph.margin), size=(50,-1))
		box1.Add(self.margin, 0, wx.ALIGN_LEFT|wx.ALL, 0)


		#----- 
		box = wx.StaticBox(page, -1, "Plotting Area")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		box1 = wx.FlexGridSizer(0,2,2,2)
		sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(page, -1, "Background Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.bg_color = wx.ColourPickerCtrl(page, -1, self.graph.backgroundColor)
		box1.Add(self.bg_color, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(page, -1, "Plot Area Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALL, 0)
		self.pa_color = wx.ColourPickerCtrl(page, -1, self.graph.plotareaColor)
		box1.Add(self.pa_color, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		page.SetSizer(box0)
		return page


	#---------------------------------------------------------------
	def makeGridPage(self, nb):

		page = wx.Panel(nb, -1)

		box0 = wx.BoxSizer(wx.VERTICAL)

		#----- 
		box1 = wx.FlexGridSizer(0,2,2,2)
		box0.Add(box1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		label = wx.StaticText(page, -1, "X Axis for Grid:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		list = []
                for axis in self.graph.axes:
                        if axis.isXAxis():
                                s = "X%d" % axis.id
				list.append(s)
                self.gridXaxis = wx.Choice(page, -1, choices=list)
                self.gridXaxis.SetSelection(0)
                box1.Add(self.gridXaxis, 1, wx.ALIGN_CENTRE|wx.ALL, 2)
		label = wx.StaticText(page, -1, "Y Axis for Grid:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		list = []
                for axis in self.graph.axes:
                        if axis.isYAxis():
                                s = "Y%d" % axis.id
				list.append(s)
                self.gridYaxis = wx.Choice(page, -1, choices=list)
                self.gridYaxis.SetSelection(0)
                box1.Add(self.gridYaxis, 1, wx.ALIGN_CENTRE|wx.ALL, 2)

		#-----
		box = wx.StaticBox(page, -1, "Main Grid")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		self.show_grid = wx.CheckBox(page, -1, "Show Grid")
                self.show_grid.SetValue(self.graph.showGrid)
                sizer2.Add(self.show_grid, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

		box1 = wx.FlexGridSizer(0,2,2,2)
                sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
		label = wx.StaticText(page, -1, "Grid Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.gridPen.GetColour()
		self.grid_color = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.grid_color, 0, wx.ALIGN_LEFT|wx.ALL, 0)

		label = wx.StaticText(page, -1, "Line Width:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		self.grid_linewidth = wx.SpinCtrl(page, -1, "1", size=(50,-1))
		box1.Add(self.grid_linewidth, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Line Type:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		self.grid_type = wx.Choice(page, -1, choices=LINE_TYPES.keys())
		value = StyleToName(self.graph.gridPen.GetStyle())
                self.grid_type.SetStringSelection(value)
		box1.Add(self.grid_type, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		#-----
		box = wx.StaticBox(page, -1, "Sub Grid")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		self.show_subgrid = wx.CheckBox(page, -1, "Show SubGrid")
                self.show_subgrid.SetValue(self.graph.showSubgrid)
                sizer2.Add(self.show_subgrid, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

		box1 = wx.FlexGridSizer(0,2,2,2)
                sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
		label = wx.StaticText(page, -1, "SubGrid Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.subgridPen.GetColour()
		self.subgrid_color = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.subgrid_color, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Line Width:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		self.subgrid_linewidth = wx.SpinCtrl(page, -1, "1", size=(50,-1))
		box1.Add(self.subgrid_linewidth, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Line Type:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		self.subgrid_type = wx.Choice(page, -1, choices=LINE_TYPES.keys())
		value = StyleToName(self.graph.subgridPen.GetStyle())
                self.subgrid_type.SetStringSelection(value)
		box1.Add(self.subgrid_type, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		page.SetSizer(box0)
		return page

	#---------------------------------------------------------------
	def makeCrosshairPage(self, nb):

		page = wx.Panel(nb, -1)

		box0 = wx.BoxSizer(wx.VERTICAL)

		#----- 
		box1 = wx.FlexGridSizer(0,2,2,2)
		box0.Add(box1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		label = wx.StaticText(page, -1, "X Axis for Crosshairs:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		list = []
                for axis in self.graph.axes:
                        if axis.isXAxis():
                                s = "X%d" % axis.id
				list.append(s)
                self.chXaxis = wx.Choice(page, -1, choices=list)
		xaxis_id = self.graph.crosshair.xaxis
		s = "X%d" % xaxis_id
                self.chXaxis.SetStringSelection(s)
                box1.Add(self.chXaxis, 1, wx.ALIGN_CENTRE|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Y Axis for Crosshairs:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		list = []
                for axis in self.graph.axes:
                        if axis.isYAxis():
                                s = "Y%d" % axis.id
				list.append(s)
                self.chYaxis = wx.Choice(page, -1, choices=list)
		yaxis_id = self.graph.crosshair.yaxis
		s = "Y%d" % yaxis_id
                self.chYaxis.SetStringSelection(s)
                box1.Add(self.chYaxis, 1, wx.ALIGN_CENTRE|wx.ALL, 2)

#		box1 = wx.FlexGridSizer(0,2,2,2)
#                box0.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(page, -1, "Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.crosshair.color
		self.crosshair_color = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.crosshair_color, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Line Width:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		width = self.graph.crosshair.pen.GetWidth()
		self.crosshair_linewidth = wx.SpinCtrl(page, -1, str(width), size=(50,-1))
		box1.Add(self.crosshair_linewidth, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		#-----
		box = wx.StaticBox(page, -1, "Location Label")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		self.show_chlabel = wx.CheckBox(page, -1, "Show Location Label")
                self.show_chlabel.SetValue(self.graph.show_popup)
                sizer2.Add(self.show_chlabel, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

		box1 = wx.FlexGridSizer(0,2,2,2)
                sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)
		label = wx.StaticText(page, -1, "Label Foreground Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.popup.fg_color
		self.chlabel_color = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.chlabel_color, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Label Background Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.popup.bg_color
		self.chlabel_bgcolor = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.chlabel_bgcolor, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Font:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
                self.chfont = wx.FontPickerCtrl(page, style=wx.FNTP_USEFONT_FOR_LABEL)
		self.chfont.SetSelectedFont(self.graph.popup.st.GetFont())
                box1.Add(self.chfont, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)


		page.SetSizer(box0)
		return page

	#---------------------------------------------------------------
	def makeTitlePage(self, nb):

		page = wx.Panel(nb, -1)

		box0 = wx.BoxSizer(wx.VERTICAL)

		box = wx.BoxSizer(wx.HORIZONTAL)
		box0.Add(box, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		label = wx.StaticText(page, -1, "Graph Title:")
		box.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.title = wx.TextCtrl(page, -1, self.graph.title.text, size=(280,50), style=wx.TE_MULTILINE|wx.TE_PROCESS_ENTER)
		box.Add(self.title, 1, wx.ALIGN_CENTRE|wx.ALL, 5)

		box1 = wx.FlexGridSizer(0,2,2,2)
		box0.Add(box1, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 5)

		label = wx.StaticText(page, -1, "Font:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
                self.title_font = wx.FontPickerCtrl(page, style=wx.FNTP_USEFONT_FOR_LABEL)
		self.title_font.SetSelectedFont(self.graph.title.font)
                box1.Add(self.title_font, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(page, -1, "Font Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.title.color
		self.title_color = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.title_color, 0, wx.ALIGN_LEFT|wx.ALL, 2)


		page.SetSizer(box0)
		return page

		#----- 
	#---------------------------------------------------------------
	def makeLegendPage(self, nb):

		page = wx.Panel(nb, -1)

		box0 = wx.BoxSizer(wx.VERTICAL)

		#-----
		box = wx.StaticBox(page, -1, "Legend")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		self.show_legend = wx.CheckBox(page, -1, "Show Legend")
                self.show_legend.SetValue(self.graph.legend.showLegend)
                sizer2.Add(self.show_legend, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

		box1 = wx.FlexGridSizer(0,2,2,2)
                sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(page, -1, "Title:")
		box1.Add(label, 0, wx.ALIGN_CENTRE|wx.ALL, 5)
		self.legend_title = wx.TextCtrl(page, -1, self.graph.legend.title.text, size=(280,-1))
		box1.Add(self.legend_title, 0, wx.ALIGN_LEFT|wx.ALL, 2)


		label = wx.StaticText(page, -1, "Font:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
                self.legend_font = wx.FontPickerCtrl(page, style=wx.FNTP_USEFONT_FOR_LABEL)
		self.legend_font.SetSelectedFont(self.graph.legend.font)
                box1.Add(self.legend_font, wx.GROW|wx.ALIGN_LEFT|wx.ALL)

		label = wx.StaticText(page, -1, "Font Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.legend.color
		self.legend_color = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.legend_color, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Location:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		list = ["Right", "Left", "Top", "Bottom"]
                self.legend_location = wx.Choice(page, -1, choices=list)
                self.legend_location.SetSelection(0)
		box1.Add(self.legend_location, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		#-----
		box = wx.StaticBox(page, -1, "Legend Border")
		sizer2 = wx.StaticBoxSizer(box, wx.VERTICAL)
		box0.Add(sizer2, 0, wx.EXPAND|wx.ALIGN_LEFT|wx.ALL, 5)

		self.show_legend_border = wx.CheckBox(page, -1, "Show Legend Border")
                self.show_legend_border.SetValue(self.graph.legend.showLegendBorder)
                sizer2.Add(self.show_legend_border, 0, wx.GROW|wx.ALIGN_RIGHT|wx.ALL, 2)

		box1 = wx.FlexGridSizer(0,2,2,2)
                sizer2.Add(box1, wx.GROW|wx.ALIGN_RIGHT|wx.ALL)

		label = wx.StaticText(page, -1, "Background Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.legend.background
		self.legend_bgcolor = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.legend_bgcolor, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Width:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		width = self.graph.legend.borderWidth
		self.legend_borderwidth = wx.SpinCtrl(page, -1, str(width), size=(50,-1))
		box1.Add(self.legend_borderwidth, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		label = wx.StaticText(page, -1, "Color:")
		box1.Add(label, 0, wx.ALIGN_RIGHT|wx.ALIGN_CENTER_VERTICAL|wx.ALL, 2)
		color = self.graph.legend.foreground
		self.legend_bordercolor = wx.ColourPickerCtrl(page, -1, color)
		box1.Add(self.legend_bordercolor, 0, wx.ALIGN_LEFT|wx.ALL, 2)

		page.SetSizer(box0)
		return page

	#---------------------------------------------------------------
	def apply(self, event):

		# Get background color
		val = self.bg_color.GetColour()
		self.graph.backgroundColor = val

		# Get plot area color
		val = self.pa_color.GetColour()
		self.graph.plotareaColor = val

		# Get graph margin
		val = self.margin.GetValue()
		self.graph.margin = val

		# Get grid axes
                val = self.gridXaxis.GetStringSelection()
		self.graph.grid_xaxis = int(val[1])
                val = self.gridYaxis.GetStringSelection()
		self.graph.grid_yaxis = int(val[1])

		# Get grid values
		val = self.show_grid.GetValue()
		self.graph.showGrid = val

		color = self.grid_color.GetColour()
		width = self.grid_linewidth.GetValue()
                val = self.grid_type.GetStringSelection()
                type = NameToStyle(val)
		self.graph.gridPen = wx.Pen(color, width, type)

		# Get subgrid values
		val = self.show_subgrid.GetValue()
		self.graph.showSubgrid = val

		color = self.subgrid_color.GetColour()
		width = self.subgrid_linewidth.GetValue()
                val = self.subgrid_type.GetStringSelection()
                type = NameToStyle(val)
		self.graph.subgridPen = wx.Pen(color, width, type)

		# Get crosshair values
		color = self.crosshair_color.GetColour()
		width = self.crosshair_linewidth.GetValue()
		style = self.graph.crosshair.style
		self.graph.crosshair.setCrosshairStyle(color, width, style)
		show = self.show_chlabel.GetValue()
		self.graph.show_popup = show

		color = self.chlabel_color.GetColour()
		self.graph.popup.setForegroundColor(color)
		color = self.chlabel_bgcolor.GetColour()
		self.graph.popup.setBackgroundColor(color)

		font = self.chfont.GetSelectedFont()
		self.graph.popup.st.SetFont(font)

                val = self.chXaxis.GetStringSelection()
		self.graph.crosshair.xaxis = int(val[1])
                val = self.chYaxis.GetStringSelection()
		self.graph.crosshair.yaxis = int(val[1])

		# Get the title values
		val = self.title.GetValue()
		self.graph.title.text = val

		font = self.title_font.GetSelectedFont()
		self.graph.title.font = font
		color = self.title_color.GetColour()
		self.graph.title.color = color

		# Get legend values

		#--- legend
	
		val = self.legend_title.GetValue()
		self.graph.legend.title.text = val

		val = self.show_legend.GetValue()
		self.graph.legend.showLegend = val

		color = self.legend_color.GetColour()
		self.graph.legend.color = color
		color = self.legend_bgcolor.GetColour()
		self.graph.legend.background = color

		font = self.legend_font.GetSelectedFont()
		self.graph.legend.font = font

		#--- legend border
		val = self.show_legend_border.GetValue()
		self.graph.legend.showLegendBorder = val

		width = self.legend_borderwidth.GetValue()
		self.graph.legend.borderWidth = width
		color = self.legend_bordercolor.GetColour()
		self.graph.legend.foreground = color

		# Redraw the graph
		self.graph.update()

	def ok(self,event):
		self.apply(event)
		self.EndModal(wx.ID_OK)

	def nameToVal(self,val):
		if LINE_TYPES.has_key(val):
			return LINE_TYPES[val]
		else:
			return wx.SOLID

	def StyleToName(self, style):
		for k,v in LINE_TYPES.iteritems():
			if style == v:
				return k

		return "None"
		
