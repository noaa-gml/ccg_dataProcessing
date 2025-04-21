#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
""" Top level driver for dv
Shows buttons for starting up each of the different modules.
"""

import sys
import wx
import wx.adv

from common.utils import get_install_dir, get_path

sys.path.insert(1, get_path("/ccg/src/python3/nextgen"))
sys.path.insert(1, get_path("/ccg/python/ccglib"))


##################################################################################
class MyFrame(wx.Frame):
    def __init__(self, parent, ID, title):
        wx.Frame.__init__(self, parent, ID, title, wx.DefaultPosition, wx.Size(300, 400))

        menuBar = wx.MenuBar()

        menu = wx.Menu()
        menu.Append(101, "E&xit", "Terminate the program")
        self.Bind(wx.EVT_MENU, self.OnExit, id=101)
        menuBar.Append(menu, "&File")

        menu = wx.Menu()
        menu.Append(102, "&About...", "More information about this program")
        self.Bind(wx.EVT_MENU, self.about, id=102)
        menuBar.Append(menu, "&Help")

        self.SetMenuBar(menuBar)

        self.sizer = wx.FlexGridSizer(0, 3, 1, 20)
        self.sizer.AddGrowableCol(0)
        self.sizer.AddGrowableCol(1)

        self.MkButton('Grapher', 'grapher.gif', 'General Purpose Graphing', self.grapher)
        #        self.MkButton('Flask-InSitu', 'fic.gif', 'Flask - InSitu Comparison', self.fic)
        self.MkButton('CCGVU', 'ccgvu.gif', 'Curve Fitting', self.ccgvu)
        self.MkButton('DEI', 'dei.gif', 'Data Extension Viewer', self.dei)
        self.MkButton('GCPlot', 'gc.gif', 'Plot Chromatograms', self.gcplot)
        self.MkButton('PFP Plots', 'vpicon.gif', 'Multi species plots from PFPs', self.vp)
        self.MkButton('Flask Flagging', 'flflag.gif', 'Flask Flagging and Selection', self.fl)
        self.MkButton('Flask Selection', 'flsel.gif', 'Automatic selection of flask data', self.flsel)
        self.MkButton('Tank Calibrations', 'cals.gif', 'Reference gas calibration data', self.cal)
        self.MkButton('Refgas Scales', 'cals.gif', 'Reference gas Scale assigned values', self.scale)
        self.MkButton('Trajectories', 'traj.gif', 'Plot trajectories for a flask sample', self.traj)
        self.MkButton('Flask Raw Files', 'flraw.gif', 'View flask/aircraft raw files', self.flraw)
        self.MkButton('Nl Raw Files', 'flraw.gif', 'View non-linearity calibration raw files', self.nledit)
        self.MkButton('Tank Cal Raw Files', 'flraw.gif', 'View tank calibration raw files', self.caledit)
        self.MkButton('Insitu Data Edit', 'flraw.gif', 'View in-situ raw files', self.isedit)

        self.SetSizerAndFit(self.sizer)

    # ----------------------------------------------
    def grapher(self, event):
        """ Grapher module """
        from grapher.grapher import Grapher
        frame = Grapher(self, -1, "Grapher")
        frame.Show()

        return frame

    # ----------------------------------------------
    def ccgvu(self, event):
        """ ccgvu module """
        from ccgvu import ccgvu
        frame = ccgvu.Ccgvu(self, -1, "CCGVU")
        frame.Show()

    # ----------------------------------------------
    def dei(self, event):
        """ data extension module (not used) """
        from dei import dei
        frame = dei.Dei(self, -1, "DEI Viewer")
        frame.Show()

    # ----------------------------------------------
    def cal(self, event):
        """ tank calibrations module """
        from cal import cal
        frame = cal.Cal(self, -1, "Tank Calibrations")
        frame.Show()

    # ----------------------------------------------
    def gcplot(self, event):
        """ chromatogram plotting module """
        from gcplot import main
        frame = main.GCPlot(self, -1, "Chromatogram Plots")
        frame.Show()

    # ----------------------------------------------
    def fl(self, event):
        """ flask flasgging module """
        from fl import fl
        frame = fl.Fl(self, -1, "Flask Flagging")
        frame.Show()

    # ----------------------------------------------
    def flraw(self, event):
        """ flask raw file viewing """
        from fledit import flask
        frame = flask.flRaw(self, -1, "View Flask Raw Files")
        frame.Show()

    # ----------------------------------------------
    def flsel(self, event):
        """ automatic flask selection/flagging """
        from flsel import flsel
        frame = flsel.Flsel(self, -1, "Automatic selection of flask data")
        frame.Show()

    # ----------------------------------------------
    def traj(self, event):
        """ trajectories of flask samples """
        from traj import traj
        frame = traj.Traj(self, -1, "Flask Trajectories")
        frame.Show()

    # ----------------------------------------------
    def vp(self, event):
        """ vertical profiles module """
        from vp import vp
        frame = vp.VP(self, -1, "PFP Multi species Plots")
        frame.Show()

    # ----------------------------------------------
    def scale(self, event):
        """ calibration scales module """
        from reftab import scale
        frame = scale.Scale(self, -1, "Reference gas calibration scales")
        frame.Show()

    # ----------------------------------------------
    def nledit(self, event):
        """ response curve raw file viewing module """
        from nledit import nlclass
        frame = nlclass.nlEdit(self, -1, "View nl Calibration Raw Files")
        frame.Show()

    # ----------------------------------------------
    def isedit(self, event):
        """ in-situ raw file viewing module """
        from isedit import insitu
        frame = insitu.InsituEdit(self, -1, "View in-situ Raw Files")
        frame.Show()

    # ----------------------------------------------
    def caledit(self, event):
        """ calibration raw file viewing module """
        from caledit import calib
        frame = calib.calRaw(self)
        frame.Show()

    # ----------------------------------------------
    def MkButton(self, title, bitmapfile, tooltip, appfunction):
        """ Create a button inside a sizer, with some space at top and
            a text label below the button
        """
        sizer = wx.BoxSizer(wx.VERTICAL)

        # Add some space at the top
        sizer.Add((0, 10), 1)

        # Make the bitmap button
        install_dir = get_install_dir()
        imgfile = ('%s/bitmaps/%s' % (install_dir, bitmapfile))
        bmp = wx.Bitmap(imgfile)
        b = wx.BitmapButton(self, -1, bmp, (20, 20), (bmp.GetWidth()+10, bmp.GetHeight()+10))
        sizer.Add(b, flag=wx.ALIGN_CENTER)

        # bind actions to button
        b.SetToolTip(tooltip)
        if appfunction:
            self.Bind(wx.EVT_BUTTON, appfunction, b)

        # Add text title below button
        sizer.Add(wx.StaticText(self, -1, title), flag=wx.ALIGN_CENTRE | wx.ALL, border=5)

        # Add this sizer to main sizer
        self.sizer.Add(sizer, flag=wx.ALIGN_CENTER)
        return b

    # ----------------------------------------------
    def OnExit(self, e):
        """ Exit the program """
        sys.exit()

    # ----------------------------------------------
    def about(self, evt):
        """ Display an 'About' window """
        # First we create and fill the info object
        info = wx.adv.AboutDialogInfo()
        info.Name = "Dataview"
        info.Version = "8.0"
        info.Developers = ["Kirk Thoning NOAA/GML",]

        # Then we call wx.AboutBox giving it that info object
        wx.adv.AboutBox(info)


##################################################################################
class MyApp(wx.App):
    """ Main app startup """

    def OnInit(self):
        frame = MyFrame(None, -1, "Dataview")
        frame.CenterOnScreen()
        frame.Show(True)
        self.SetTopWindow(frame)
        return True


##################################################################################
if __name__ == '__main__':

#    print os.name
#    print sys.platform
#    print platform.uname()
#    print wx.Platform

#    os.environ['GTK2_RC_FILES'] = '/path/to/a/themes/gtkrc_file' 
#    print(os.environ['GTK2_RC_FILES'])

    app = MyApp(0)
    app.MainLoop()
