# vim: tabstop=4 shiftwidth=4 expandtab
""" Class for creating a context popup menu for the graph.

    The context menu has options for bringing up dialogs for
    editing the graph or axis preferences, and adding or removing
    additional axes on the graph.
"""

import wx
from . import prefs
from . import editaxis

############################################################################
class GraphContextMenu(wx.Menu):
    """ Create a context menu for the graph """

    def __init__(self, graph, title="", style=0):
        wx.Menu.__init__(self, title, style)

        self.graph = graph

        self.Append(301, "Graph Preferences...")

        m0 = wx.Menu()
        for axis in self.graph.axes:
            if axis.isXAxis():
                s = "X%d" % axis.id
                axisid = 1000+axis.id
                m0.Append(axisid, s)
                self.graph.Bind(wx.EVT_MENU, self.edit_axis, id=axisid)
            if axis.isYAxis():
                s = "Y%d" % axis.id
                axisid = 2000+axis.id
                m0.Append(axisid, s)
                self.graph.Bind(wx.EVT_MENU, self.edit_axis, id=axisid)
        self.Append(300, "Edit Axis", m0)

        self.AppendSeparator()
        self.Append(302, "Add X Axis")
        self.Append(303, "Add Y Axis")

        self.graph.Bind(wx.EVT_MENU, self.showPrefsDialog, id=301)
        self.graph.Bind(wx.EVT_MENU, self.OnPopupOne, id=302)
        self.graph.Bind(wx.EVT_MENU, self.OnPopupTwo, id=303)

        # Delete axis menus
        # Should only enable those axes that don't have datasets mapped to it.
        m1 = wx.Menu()
        m2 = wx.Menu()
        nx = 0
        ny = 0
        for axis in self.graph.axes:
            if axis.isXAxis():
                s = "X%d" % axis.id
                axisid = 100+axis.id
                m1.Append(axisid, s)
                val = self.graph.isDatasetMappedToThisAxis("x", axis)
                if val:
                    m1.Enable(axisid, False)
                else:
                    self.graph.Bind(wx.EVT_MENU, self.remove_axis, id=axisid)
                nx += 1
            if axis.isYAxis():
                s = "Y%d" % axis.id
                axisid = 200+axis.id
                m2.Append(axisid, s)
                val = self.graph.isDatasetMappedToThisAxis("y", axis)
                if val:
                    m2.Enable(axisid, False)
                else:
                    self.graph.Bind(wx.EVT_MENU, self.remove_axis, id=axisid)
                ny += 1

        # Should disable if only 1 axis left
        self.Append(304, "Delete X Axis", m1)
        if nx <= 1:
            self.Enable(304, False)

        # Should disable if only 1 axis left
        self.Append(305, "Delete Y Axis", m2)
        if ny <= 1:
            self.Enable(305, False)

        if hasattr(self.graph, "saveDataset"):
            if self.graph.saveDataset:
                self.Append(402, "Paste Dataset")
                self.graph.Bind(wx.EVT_MENU, self.paste, id=402)

        self.AppendSeparator()
        item1 = self.AppendRadioItem(-1, "Show Crosshairs")
        item2 = self.AppendRadioItem(-1, "Zoom Mode")
        item3 = self.AppendRadioItem(-1, "Selection Mode")
        item4 = self.AppendRadioItem(-1, "Drag pan and zoom Mode")
        self.graph.Bind(wx.EVT_MENU, self.setCrosshair, item1)
        self.graph.Bind(wx.EVT_MENU, self.setZoom, item2)
        self.graph.Bind(wx.EVT_MENU, self.setSelection, item3)
        self.graph.Bind(wx.EVT_MENU, self.setDrag, item4)
        if self.graph.zoomEnabled:
            item2.Check()
        elif self.graph.selectionEnabled:
            item3.Check()
        elif self.graph.dragEnabled:
            item4.Check()
        else:
            item1.Check()

        self.AppendSeparator()
        self.Append(501, "Auto Scale")
#        self.Append(502, "User Scale")
#        self.AppendRadioItem(501, "Auto Scale")
#        self.AppendRadioItem(502, "User Scale")
        self.graph.Bind(wx.EVT_MENU, self.graph.autoScale, id=501)
#        self.graph.Bind(wx.EVT_MENU, self.graph.userScale, id=502)

#        all_auto = 1
#        has_user = 0
#        for axis in graph.axes:
#            if not axis.autoscale: all_auto = 0
#            if axis.umin != None and axis.umax != None: has_user = 1

#        if not has_user:
#            self.Enable(502, False)
#        if all_auto:
#            item1a.Check()
#        else:
#            item2a.Check()


        self.AppendSeparator()
        item1 = self.AppendCheckItem(-1, "Show Point Labels")
        self.graph.Bind(wx.EVT_MENU, self.setPointLabel, item1)
        if self.graph.show_point_label_popup:
            item1.Check()

        item4 = self.AppendCheckItem(-1, "Draw Off-Scale Points on Axis")
        self.graph.Bind(wx.EVT_MENU, self.setOffscalePoints, item4)
        if self.graph.show_offscale_points:
            item4.Check()

        self.Append(600, "Clear Markers")
        self.graph.Bind(wx.EVT_MENU, self._clear_markers, id=600)

        self.AppendSeparator()

        self.Append(601, "Save as Image")
        self.graph.Bind(wx.EVT_MENU, self.graph.saveImage, id=601)

        self.Append(603, "Save Graph")
        self.graph.Bind(wx.EVT_MENU, self.graph.saveGraph, id=603)

        self.Append(604, "Load Graph")
        self.graph.Bind(wx.EVT_MENU, self.graph.loadGraph, id=604)

        self.AppendSeparator()

        item3 = self.Append(602, "Paste")
        self.graph.Bind(wx.EVT_MENU, self.graph.paste, id=602)
        if wx.TheClipboard.Open():
            mydata = wx.CustomDataObject("Dataset")
            r = wx.TheClipboard.GetData(mydata)
            if not r:
                self.Enable(602, False)
            wx.TheClipboard.Close()
        else:
            self.Enable(602, False)


    #---------------------------------------------------------------------------
    def _clear_markers(self, event):
        """ remove all markers from graph """

        self.graph.ClearMarkers()
        self.graph.update()

    #---------------------------------------------------------------------------
    def setZoom(self, event):
        """ set graph to show zoom rectangle on mouse click and drag """

        self.graph.setZoomEnabled(True)
        self.graph.setSelectionEnabled(False)
        self.graph.setDragEnabled(False)

    #---------------------------------------------------------------------------
    def setDrag(self, event):
        """ set graph to pan and zoom on mouse click and drag """

        self.graph.setZoomEnabled(False)
        self.graph.setSelectionEnabled(False)
        self.graph.setDragEnabled(True)

    #---------------------------------------------------------------------------
    def setSelection(self, event):
        """ set graph to show selection rectangle on mouse click and drag """

        self.graph.setZoomEnabled(False)
        self.graph.setSelectionEnabled(True)
        self.graph.setDragEnabled(False)

    #---------------------------------------------------------------------------
    def setPointLabel(self, event):
        """ set graph to show point label (x,y coordinate values)
        when mouse hovers close to data point.
        """

        if event.IsChecked():
            self.graph.show_point_label_popup = 1
        else:
            self.graph.show_point_label_popup = 0

    #---------------------------------------------------------------------------
    def setOffscalePoints(self, event):
        """ set graph to draw off scale point on the axis
        instead of not being shown.
        """

        if event.IsChecked():
            self.graph.show_offscale_points = True
        else:
            self.graph.show_offscale_points = False

        self.graph.update()

    #---------------------------------------------------------------------------
    def setCrosshair(self, event):
        """ Switch graph to show crosshairs on left
        mouse button press and drag.
        """

        self.graph.setZoomEnabled(False)
        self.graph.setSelectionEnabled(False)
        self.graph.setDragEnabled(False)

#        self.graph.PopupMenu(self)

    #---------------------------------------------------------------------------
    def paste(self, event):
        """ Add the saved dataset (using cut or copy) to the graph """

        import copy
        newDataset = copy.copy(self.graph.saveDataset)
        self.graph.addDataset(newDataset)

    #---------------------------------------------------------------------------
    def OnPopupOne(self, event):
        """ Add a X axis to the graph """

        self.graph.addXAxis("X Axis Title")
        self.graph.update()

    #---------------------------------------------------------------------------
    def OnPopupTwo(self, event):
        """ Add a Y axis to the graph """

        self.graph.addYAxis("Y Axis Title")
        self.graph.update()

    #---------------------------------------------------------------------------
    # Remove an axis
    def remove_axis(self, event):
        """ Remove an axis from the graph """

        # Should have self.graph.removeXAxis(id)
        axisid = event.GetId()
        if axisid >= 200:
            type = "y"
            self.graph.removeYAxis(axisid-200)
        else:
            type = "x"
            self.graph.removeXAxis(axisid-100)


        # If an dataset is mapped to this axis, remap it to ?????
#        for axis in self.graph.axes:
#            if axis.id == axisid and axis.type == type:
#                for dataset in self.graph.datasets:
#                    if type == "x":
#                        if dataset.xaxis == axisid:
#                            dataset.xaxis = 0
#                    else:
#                        if dataset.yaxis == axisid:
#                            dataset.yaxis = 0

#                self.graph.axes.remove(axis)

        self.graph.update()

    #---------------------------------------------------------------------------
    # Edit an axis
    def edit_axis(self, event):
        """ Bring up a dialog for editing the properties of an axis """

        eid = event.GetId()
        if eid >= 2000:
            axistype = "y"
            axisid = eid - 2000
        else:
            axistype = "x"
            axisid = eid - 1000

        print("edit axis id ", axisid, axistype)
        # If an dataset is mapped to this axis, remap it to ?????
        for axis in self.graph.axes:
            if axis.id == axisid and axis.type == axistype:
                s = "%s%d Axis Preferences" % (axistype, axisid)
                dlg = editaxis.AxisDialog(self.graph, axis, -1, s, size=(350, 800),
                         style=wx.DEFAULT_DIALOG_STYLE, # & ~wx.CLOSE_BOX,
                         )

                # this does not return until the dialog is closed.
                dlg.ShowModal()
                dlg.Destroy()
                break

    #---------------------------------------------------------------------------
    def showPrefsDialog(self, event):
        """ Show a dialog for changing the properties of the graph """

        dlg = prefs.PreferencesDialog(self.graph, -1, "Graph Preferences", size=(350, 800),
                         #style=wx.CAPTION | wx.SYSTEM_MENU | wx.THICK_FRAME,
                         style=wx.DEFAULT_DIALOG_STYLE, # & ~wx.CLOSE_BOX,
                         )
#        dlg.CenterOnScreen()

        # this does not return until the dialog is closed.
        dlg.ShowModal()
        dlg.Destroy()
