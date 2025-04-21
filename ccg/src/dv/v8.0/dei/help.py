# vim: tabstop=4 shiftwidth=4 expandtab

import  os
import  sys

import  wx
import  wx.html as  html
import  wx.lib.wxpTag

from common.utils import get_install_dir


#########################################################################
class HelpDialog(wx.Frame):

    def __init__(self, parent):
        wx.Frame.__init__(self, parent, -1, 'Help', size=(600, 400))
#        self.CenterOnScreen()

#        self.cwd = os.path.split(sys.argv[0])[0]

#        if not self.cwd:
#            self.cwd = os.getcwd()


#        self.CreateStatusBar()
#        self.SetStatusText("This is the statusbar")

        # Add another panel to hold text 
        box = wx.BoxSizer(wx.VERTICAL)
        self.html = html.HtmlWindow(self, -1)
        if "gtk2" in wx.PlatformInfo:
                self.html.SetStandardFonts()
        box.Add(self.html, 1, wx.EXPAND, 0)
        self.SetSizer(box)

        self.SetAutoLayout(True)

        # Prepare the menu bar
        menuBar = wx.MenuBar()

        # 1st menu from left
        menu1 = wx.Menu()
        menu1.Append(101, "Save", "Save text to file")
        menu1.Append(102, "Print", "")
        menu1.AppendSeparator()
        menu1.Append(104, "Close", "Close this frame")
        # Add menu to the menu bar
        menuBar.Append(menu1, "File")

        self.SetMenuBar(menuBar)

        # Menu events

        self.Bind(wx.EVT_MENU, self.Menu101, id=101)
        self.Bind(wx.EVT_MENU, self.Menu102, id=102)
        self.Bind(wx.EVT_MENU, self.CloseWindow, id=104)

#        install_dir = get_install_dir()
#        print("install dir is", install_dir)
#        name = '%s/ccgvu/help/ccgvu.html' % install_dir
#        print("name = ", name)
#        self.html.LoadFile(name)

    #-----------------------------------------------------
    def showTopic(self, topic):

        if topic == "ext":
            name = "ext.html"
        if topic == "fit":
            name = "fit.html"

        install_dir = get_install_dir()
        name = install_dir + "/dei/" + name
        self.html.LoadFile(name)

    #-----------------------------------------------------
    def Menu101(self, event):
        dlg = wx.FileDialog( self, message="Save file as ...", defaultDir=os.getcwd(), 
            defaultFile="", style=wx.SAVE
            )

        if dlg.ShowModal() == wx.ID_OK:
                path = dlg.GetPath()
                f = open(path, "w")
                f.write(self.tc.GetValue())
                f.close()

    #-----------------------------------------------------
    def Menu102(self, event):
        pass

    #-----------------------------------------------------
    def CloseWindow(self, event):
        self.Hide()
