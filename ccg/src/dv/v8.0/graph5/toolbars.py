# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for drawing a toolbar that has buttons for zooming and panning
the graph
"""

import sys
import os
import wx


ZOOM = 1
AUTOSCALE = 2
ZOOM_IN_BOTH = 3
ZOOM_OUT_BOTH = 4
ZOOM_IN_VERT = 5
ZOOM_OUT_VERT = 6
ZOOM_IN_HORIZ = 7
ZOOM_OUT_HORIZ = 8
PAN_LEFT = 9
PAN_RIGHT = 10
PAN_UP = 11
PAN_DOWN = 12

##################################################################################
def get_install_dir():
    """ get the installation directory of pydv """

#    return "/ccg/src/python3/graph5"

    p = sys.argv[0]
    # This doesn't work if startup command is ./pydv
    rdir = os.path.realpath(p)
    idir = os.path.split(rdir)[0]
    return idir

##########################################################################
class ZoomToolBar(wx.ToolBar):
    def __init__(self, parent=None, plot=None):
        wx.ToolBar.__init__(self, parent, -1)

        self.graphs = []

#        self._make_button(ZOOM,           "zoomin.xpm",       "Turn on drag zoom", check = True)
        self._make_button(AUTOSCALE,      "autoscale.xpm",    "Autoscale" )
        self._make_button(ZOOM_IN_BOTH,   "zoominboth.xpm",   "Zoom In Both Axes")
        self._make_button(ZOOM_OUT_BOTH,  "zoomoutboth.xpm",  "Zoom Out Both Axes")
        self._make_button(ZOOM_IN_VERT,   "zoomvertin.xpm",   "Zoom In Y Axis")
        self._make_button(ZOOM_OUT_VERT,  "zoomvertout.xpm",  "Zoom Out Y Axis")
        self._make_button(ZOOM_IN_HORIZ,  "zoomhorizin.xpm",  "Zoom In X Axis")
        self._make_button(ZOOM_OUT_HORIZ, "zoomhorizout.xpm", "Zoom Out X Axis")
        self._make_button(PAN_LEFT,       "left.xpm",         "Pan Left")
        self._make_button(PAN_RIGHT,      "right.xpm",        "Pan Right")
        self._make_button(PAN_UP,         "up.xpm",           "Pan Up")
        self._make_button(PAN_DOWN,       "down.xpm",         "Pan Down")

        if plot:
            self.graphs.append(plot)
            self.ToggleTool(ZOOM, plot.zoomEnabled)

        self.Realize()

    def SetGraph(self, graph):
        if graph not in self.graphs:
            self.graphs.append(graph)
        self.ToggleTool(ZOOM, graph.zoomEnabled)

    def ClearGraphs(self):
        self.graphs = []


    def _make_button(self, id, bitmapfile, tooltip, appfunction = "", check = False):
        # Make the bitmap button
        install_dir = get_install_dir()
        imgfile = ('%s/bitmaps/%s' % (install_dir, bitmapfile))
        bmp = wx.Bitmap(imgfile)
        if check:
            self.AddCheckTool(id, "test", bmp, shortHelp=tooltip)
        else:
            self.AddTool(id, "test", bmp, shortHelp=tooltip)


        self.Bind(wx.EVT_TOOL, self.OnToolClick, id=id)


    def OnToolClick(self, evt):
        id = evt.GetId()
        if id == ZOOM:
            state = self.GetToolState(ZOOM)
            for graph in self.graphs: graph.setZoomEnabled(state)

        elif id == AUTOSCALE:
            for graph in self.graphs: graph.autoScale()
        elif id == ZOOM_IN_BOTH:
            for graph in self.graphs: graph.zoomIn()
        elif id == ZOOM_OUT_BOTH:
            for graph in self.graphs: graph.zoomOut()
        elif id == ZOOM_IN_VERT:
            for graph in self.graphs: graph.zoomInVert()
        elif id == ZOOM_OUT_VERT:
            for graph in self.graphs: graph.zoomOutVert()
        elif id == ZOOM_IN_HORIZ:
            for graph in self.graphs: graph.zoomInHoriz()
        elif id == ZOOM_OUT_HORIZ:
            for graph in self.graphs: graph.zoomOutHoriz()
        elif id == PAN_LEFT:
            for graph in self.graphs: graph.panLeft()
        elif id == PAN_RIGHT:
            for graph in self.graphs: graph.panRight()
        elif id == PAN_UP:
            for graph in self.graphs: graph.panUp()
        elif id == PAN_DOWN:
            for graph in self.graphs: graph.panDown()
