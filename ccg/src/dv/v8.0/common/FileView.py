# vim: tabstop=4 shiftwidth=4 expandtab

"""
Widget for showing and editing the contents of a file in a textctrl widget
"""

import wx


######################################################################
class FileView(wx.Frame):
    """ Dialog for showing and optionally editing the contents of a file in a textctrl widget """

    def __init__(self, parent, filename, readonly=True):
        wx.Frame.__init__(self, parent, -1, "File View", wx.DefaultPosition, wx.Size(650, 600))

        self.filename = filename

        self.CreateStatusBar()
        self.SetStatusText(filename)

        box0 = wx.BoxSizer(wx.VERTICAL)
        if readonly:
            self.text = wx.TextCtrl(self, -1, "", style=wx.TE_READONLY | wx.TE_MULTILINE, size=(700, 600))
        else:
            self.text = wx.TextCtrl(self, -1, "", style=wx.TE_MULTILINE, size=(700, 600))
        font = wx.Font(wx.FontInfo().Family(wx.FONTFAMILY_TELETYPE))
        self.text.SetFont(font)
        self.text.LoadFile(filename)
        self.text.ShowPosition(0)
        box0.Add(self.text, 1, wx.EXPAND, 0)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CLOSE)
        self.Bind(wx.EVT_BUTTON, self.cancel, btn)
        btnsizer.AddButton(btn)

        if not readonly:
            btn = wx.Button(self, wx.ID_SAVE)
            btn.SetDefault()
            self.Bind(wx.EVT_BUTTON, self.ok, btn)
            btnsizer.AddButton(btn)

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        self.CenterOnScreen()

    def cancel(self, event):
        """ Destroy the window """
        self.Destroy()

    def ok(self, event):
        """ Save the text back to the file """

        txt = self.text.GetValue()

        f = open(self.filename, "w")
        f.write(txt)
        f.close()
