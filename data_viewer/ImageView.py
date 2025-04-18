import wx


######################################################################
class ImageView(wx.Frame):
    def __init__(self, parent, file):
        wx.Frame.__init__(self, parent, -1, "Image View", wx.DefaultPosition, wx.Size(550, 600))

        self.CreateStatusBar()
        self.SetStatusText(file)

        box0 = wx.BoxSizer(wx.VERTICAL)

        gif = wx.Image(file, wx.BITMAP_TYPE_ANY).ConvertToBitmap()
        self.image = wx.StaticBitmap(self, -1, gif, (0, 0), (gif.GetWidth(), gif.GetHeight()))
        box0.Add(self.image, 1, wx.EXPAND, 0)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CLOSE)
        btn.SetDefault()
        self.Bind(wx.EVT_BUTTON, self.ok, btn)

        btnsizer.AddButton(btn)
        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_CENTRE | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)

        #        self.CenterOnScreen()
        #    self.Raise()

    def ok(self, event):
        self.Destroy()
