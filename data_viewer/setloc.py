# vim: tabstop=4 shiftwidth=4 expandtab
"""
dialog for setting the location of the dei run
"""

import os
import glob
import wx

##########################################################################
class DEIDialog(wx.Dialog):
    """ dialog for setting the location of the dei run """

    def __init__(self, parent=None, title="Import MBL Data"):
        wx.Dialog.__init__(self, parent, -1, title, style=wx.RESIZE_BORDER)


        self.deidir = None
        self.param = None

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        sizer = self.mkSource()
        box0.Add(sizer, 0, wx.GROW|wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20,-1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW|wx.RIGHT|wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn = wx.Button(self, wx.ID_OK)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 1, wx.ALIGN_RIGHT|wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)


    #----------------------------------
    def mkSource(self):
        """ Create the widgets for the source of the dei run """

        box = wx.StaticBox(self, -1, "Data Source")
        sizer = wx.StaticBoxSizer(box, wx.VERTICAL)

        label = wx.StaticText(self, -1, "Latest Web Run:")
        sizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 1)

        web_options = ["None"]
        for gas in ["co2", "ch4", "co", "n2o", "sf6", "co2c13"]:
            dir_pattern = "/ccg/dei/ext/%s/web/results.web.2???-??/" % gas
            dirs = glob.glob(dir_pattern)
            last_dir = sorted(dirs)[-1]
            s = gas.upper() + " - " + last_dir
            web_options.append(s)
        self.web_choice = wx.Choice(self, -1, choices=web_options)
        self.web_choice.SetSelection(0)
        sizer.Add(self.web_choice, 0, wx.ALIGN_CENTRE|wx.ALL, 5)

        label = wx.StaticText(self, -1, "OR")
        sizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 10)


        label = wx.StaticText(self, -1, "DEI Directory:")
        sizer.Add(label, 0, wx.ALIGN_LEFT|wx.ALL, 1)

        self.dp2 = wx.DirPickerCtrl(self, size=(800, -1), style=wx.DIRP_USE_TEXTCTRL)
        self.dp2.SetTextCtrlProportion(1)
        sizer.Add(self.dp2, 1, wx.ALIGN_LEFT|wx.GROW|wx.ALL, 1)


        return sizer


    #----------------------------------
    def ok(self, event):
        """ OK button clicked, save selections and end modal """

        s = self.web_choice.GetStringSelection()
        if s != "None":
            (gas, deidir) = s.split("-", 1)
            self.deidir = deidir.strip()
            self.param = gas.strip().lower()

        s = self.dp2.GetPath()
        print("dp2 is", s)
        if len(s) > 0:

            if not os.path.exists(s):
                msg = "DEI Directory does not exist."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return

            self.deidir = s
            files = glob.glob(s + "/surface.mbl.*")
            if len(files) > 0:
                f = files[0]
                print("surface mbl file is ", f)
                f = os.path.basename(f)
                a = f.split(".")
                if len(a) == 3:
                    (aa, bb, gas) = a
                elif len(a) == 4:
                    (aa, bb, cc, gas) = a
                else:
                    msg = "Bad surface mbl file name."
                    dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                    dlg.ShowModal()
                    dlg.Destroy()
                    return

                self.param = gas.strip().lower()
            else:
                msg = "Invalid Directory. surface mbl file does not exist."
                dlg = wx.MessageDialog(self, msg, 'A Message Box', wx.OK | wx.ICON_ERROR)
                dlg.ShowModal()
                dlg.Destroy()
                return


        self.EndModal(wx.ID_OK)
