# vim: tabstop=4 shiftwidth=4 expandtab
"""
Module for viewing back trajectory figures previously created.
"""

import os
import glob

import wx

# from common import combolist
from common.utils import get_path


######################################################################
class Traj(wx.Frame):
    """ A frame for showing back trajectory images, with controls to
    choose the station and date of the trajectory.
    """

    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(650, 800))

        self.stacode = "MLO"
        path = "/ccg/traj/images/mlo/*.png"
        path = get_path(path)
        self.imgfiles = sorted(glob.glob(path))
        self.current_traj = self.imgfiles[-1]

        self.CreateStatusBar()

        # Main sizer to hold toolbars and graphs
        self.sizer = wx.BoxSizer(wx.VERTICAL)

        self.datebar = self.mkSelectionBar()
        self.sizer.Add(self.datebar, 0, wx.EXPAND | wx.TOP | wx.BOTTOM, 5)

        self.p1 = wx.Panel(self)
        self.imgsizer = wx.BoxSizer(wx.HORIZONTAL)
        self.p1.SetSizer(self.imgsizer)

        self.sizer.Add(self.p1, 0, wx.EXPAND, 0)

        # Make the menu bar
        menuBar = wx.MenuBar()

        menu1 = wx.Menu()
        menu1.Append(104, "Close", "Close this frame")
        menuBar.Append(menu1, "File")
        self.Bind(wx.EVT_MENU, self.CloseWindow, id=104)

        self.SetMenuBar(menuBar)
        self.SetSizer(self.sizer)

        self.updateImage()
        self.CenterOnScreen()

    # ---------------------------------------------------------------------------
    def CloseWindow(self, event):
        """ Close the app """

        self.Destroy()

    # ---------------------------------------------------------------------------
    def mkSelectionBar(self):
        """ Make a bar with a choice for station, date, and back and forward buttons """

        p = wx.Panel(self)
        box1 = wx.BoxSizer(wx.HORIZONTAL)
        p.SetSizer(box1)

        # choice box with station codes
        stalist = self._set_stations()
#        self.listbox = combolist.ComboList(p, -1, size=(100, -1))
        self.listbox = wx.ComboBox(p, -1, size=(100, -1), style=wx.CB_READONLY)
        self.listbox.Set(stalist)
        self.listbox.SetValue("MLO")
        self.stacode = "MLO"
        self.listbox.Bind(wx.EVT_TEXT, self.stationSelected)

        box1.Add(self.listbox, 0, wx.LEFT | wx.ALIGN_CENTER, 10)

        # choice box with dates
#        self.dpc = combolist.ComboList(p, -1, size=(200, -1))
        self.dpc = wx.ComboBox(p, -1, size=(200, -1), style=wx.CB_READONLY)
        box1.Add(self.dpc, 0, wx.LEFT | wx.ALIGN_CENTER, 20)
        self._set_dates()

        # back and forward buttons for going to previous and next raw file
        b = wx.Button(p, wx.ID_BACKWARD)
        box1.Add(b, 0, wx.LEFT, 20)
        self.Bind(wx.EVT_BUTTON, self.getTraj, b)

        b = wx.Button(p, wx.ID_FORWARD)
        box1.Add(b, 0, wx.LEFT, 5)
        self.Bind(wx.EVT_BUTTON, self.getTraj, b)

        return p

    # ---------------------------------------------------------------------------
    def getTraj(self, event):
        """ Back or forward button has been clicked.  Get the correct
        trajectory and set the extchoice widget with correct date """

        eid = event.GetId()

        index = self.imgfiles.index(self.current_traj)
        if eid == wx.ID_BACKWARD:
            index -= 1
            if index < 0:
                index = len(self.imgfiles) - 1
        else:
            index += 1
            if index >= len(self.imgfiles):
                index = 0

        self.current_traj = self.imgfiles[index]
        datestr = self.getDateStamp(self.current_traj)

        # this call will trigger an EVT_TEXT event for dateSelected()
        # so no need to call updateImage() (needed for MACOS)
        self.dpc.SetValue(datestr)
        self.updateImage()

    # ---------------------------------------------------------------------------
    def _set_stations(self):
        """ Update the listbox extchoice widget with new station codes """

        # get list of station codes with trajectories
        stacodes = []
        path = "/ccg/traj/images/???"
        path = get_path(path)
        codes = glob.glob(path)
        for dirname in codes:
            c = dirname.split("/")[-1]
            stacodes.append(c.upper())
        stacodes = sorted(stacodes)

        return stacodes

    # ---------------------------------------------------------------------------
    def _set_dates(self):
        """ Update the dpc extchoice widget with new dates """

        dates = self.getImageDates()
        self.dpc.Unbind(wx.EVT_TEXT)
        self.dpc.SetItems(dates)
        self.dpc.SetValue(dates[-1])
        self.dpc.Bind(wx.EVT_TEXT, self.dateSelected)

    # ---------------------------------------------------------------------------
    def stationSelected(self, event):
        """ new station code selected.
        get new list of image files available, and a separate list with their dates.
        Set the image to the most recent one (last in the list)
        """

        s = self.listbox.GetValue()
        if s != self.stacode:
            path = "/ccg/traj/images/%s/*.png" % s.lower()
            path = get_path(path)
            self.imgfiles = sorted(glob.glob(path))
            if self.imgfiles:
                self.current_traj = self.imgfiles[-1]
                self._set_dates()

                self.stacode = s
                self.updateImage()

    # ---------------------------------------------------------------------------
    def dateSelected(self, event):
        """ New date has been selected.  Find the trajectory for the date and show it """

        s = self.dpc.GetValue()
        path = "/ccg/traj/images/%s/%s_%s.png" % (self.stacode.lower(), self.stacode.lower(), s)
        path = get_path(path)
        self.current_traj = path
        self.updateImage()

    # ---------------------------------------------------------------------------
    def updateImage(self):
        """ Update the image with the correct trajecory image """

        png = wx.Image(self.current_traj, wx.BITMAP_TYPE_ANY).ConvertToBitmap()
        self.imgsizer.Clear(True)
        image = wx.StaticBitmap(self.p1, -1, png, size=(png.GetWidth(), png.GetHeight()))
        self.imgsizer.Add(image, 0, wx.EXPAND, 0)

        self.SetStatusText(self.current_traj)

    # ---------------------------------------------------------------------------
    def getDateStamp(self, filename):
        """ Get the time stamp from the trajectory file name """

        name = os.path.basename(filename)
        name = name.strip(".png")
        (code, datestr) = name.split("_")

        return datestr

    # ---------------------------------------------------------------------------
    def getImageDates(self):
        """ Get the dates of all the available trajetory images for the current station """

        dates = []
        for filename in self.imgfiles:
            datestr = self.getDateStamp(filename)
            dates.append(datestr)

        return dates
