# vim: tabstop=4 shiftwidth=4 expandtab
"""
Dialog that shows flask data in a list box
"""

import wx

import ccg_dbutils

from common.flask_listbox import FlaskListCtrl


##########################################################################
class FlaskDataView(wx.Dialog):
    """
    Dialog that shows flask data in a list box
    """

    def __init__(self, parent, title="Flask Data", size=(900, 700)):

        wx.Dialog.__init__(self, parent, -1,
                           title=title,
                           size=size,
                           style=wx.DEFAULT_DIALOG_STYLE | wx.RESIZE_BORDER)

        self.parent = parent
        self.data = parent.data

        # Main sizer for dialog
        box0 = wx.BoxSizer(wx.VERTICAL)

        db = ccg_dbutils.dbUtils()
        choicelist = []
        for pnum in self.data.parameter_list:
            formula = db.getGasFormula(pnum)
            name = db.getGasNameFromNum(pnum)

            s = "%s - %s" % (formula, name)
            choicelist.append(s)

        self.params = wx.Choice(self, -1, choices=choicelist)
        self.params.SetSelection(0)
        box0.Add(self.params, 0, wx.ALIGN_LEFT | wx.ALL, 2)
        self.Bind(wx.EVT_CHOICE, self.setparam, self.params)

        self.listbox = FlaskListCtrl(self)
        box0.Add(self.listbox, 1, wx.EXPAND | wx.ALL, 5)

        line = wx.StaticLine(self, -1, size=(20, -1), style=wx.LI_HORIZONTAL)
        box0.Add(line, 0, wx.GROW | wx.RIGHT | wx.TOP, 5)

        btnsizer = wx.StdDialogButtonSizer()

        btn = wx.Button(self, wx.ID_CANCEL)
        btnsizer.AddButton(btn)
        btn.SetDefault()

        btnsizer.Realize()

        box0.Add(btnsizer, 0, wx.ALIGN_RIGHT | wx.ALL, 5)

        self.SetSizer(box0)
        box0.SetSizeHints(self)
        self.SetSize(size)
        self.CenterOnScreen()

        self.load_data(choicelist[0])

    # ----------------------------------------------------------------------
    def setparam(self, evt):
        """ parameter choice box has changed.  Load in data for the selected gas """

        s = self.params.GetStringSelection()

        self.load_data(s)

    # ----------------------------------------------------------------------
    def load_data(self, s):
        """ Get data from database and load list box with results """

        print(s)
        formula = s.split()[0]

        d = self.parent._get_flask_data(formula)
        self.listbox.setList(d)

#        t1 = datetime.datetime(self.data.byear, 1, 1)
#        t2 = datetime.datetime(self.data.eyear+1, 1, 1)

#        f = FlaskData(formula, self.data.sitenum)
#        f.setRange(start=t1, end=t2)
#        f.setProject(self.data.project)
#        f.setStrategy(self.data.use_flask, self.data.use_pfp)
#        f.includeFlaggedData()
#        f.includeHardFlags()
#        f.includeDefault()
#        f.setPrograms(self.proglist)
#        f.run()

#        self.listbox.setList(f.results)

#        self.listbox.DeleteAllItems()

#        for row in f.results:
#            self.listbox.setFlaskListCtrlItems(row)
