# vim: tabstop=4 shiftwidth=4 expandtab
""" wx dialog to show text """

import os
import wx


######################################################################
class TextView(wx.Frame):
    """ Dialog to show text """

    def __init__(self, parent, text):
        wx.Frame.__init__(self, parent, -1, "Text View", wx.DefaultPosition, wx.Size(850, 600))

        self.CreateStatusBar()
#        self.SetStatusText(file)

        box0 = wx.BoxSizer(wx.VERTICAL)
        self.text = wx.TextCtrl(self, -1, "",
                                style=wx.TE_READONLY | wx.TE_MULTILINE | wx.HSCROLL, size=(850, 600))
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.text.SetFont(font)
        self.text.SetValue(text)
        self.text.ShowPosition(0)
        box0.Add(self.text, 1, wx.EXPAND, 0)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()
#        btnsizer = wx.BoxSizer(wx.HORIZONTAL)

        btn = wx.Button(self, wx.ID_SAVE)
#        btn = wx.Button(self, -1, "Save Text")
        self.Bind(wx.EVT_BUTTON, self._save, btn)
        btnsizer.AddButton(btn)
#        btnsizer.Add(btn, 0, wx.ALIGN_LEFT)
        btn = wx.Button(self, wx.ID_CLOSE)
#        btn = wx.Button(self, -1, "Close")
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
#        btnsizer.Add(btn, 0, wx.LEFT|wx.RIGHT, 20)
        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        self.CenterOnScreen()

    def ok(self, event):
        """ close the dialog """
        self.Destroy()

    def _save(self, event):

        dlg = wx.FileDialog(self, message="Save file as ...", defaultDir=os.getcwd(),
                            defaultFile="", style=wx.FD_SAVE
                            )

        if dlg.ShowModal() == wx.ID_OK:
            path = dlg.GetPath()
            f = open(path, "w")
            f.write(self.text.GetValue())
            f.close()
