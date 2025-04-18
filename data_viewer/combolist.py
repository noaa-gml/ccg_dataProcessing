# vim: tabstop=4 shiftwidth=4 expandtab
"""
A ComboCtrl using a ListBox as popup
"""

import wx

#----------------------------------------------------------------------
# This class is used to provide an interface between a ComboCtrl and the
# ListCtrl that is used as the popoup for the combo widget.

class ListCtrlComboPopup(wx.ComboPopup):

    def __init__(self):
        wx.ComboPopup.__init__(self)
        self.lc = None

    def AddItem(self, txt):
        self.lc.InsertItem(self.lc.GetItemCount(), txt)

    def InsertItems(self, items):
        self.lc.Clear()
        self.lc.InsertItems(items, 0)

    def OnMotion(self, evt):
        item, flags = self.lc.HitTest(evt.GetPosition())
        if item >= 0:
            self.lc.Select(item)
            self.curitem = item

    def OnLeftDown(self, evt):
        self.value = self.curitem
        self.Dismiss()

    def Selected(self, evt):
        idx = self.lc.GetSelection()
        print("idx is", idx)
        data = self.lc.GetString(idx)
        print("selection is", data)
        self.value = idx
        self.Dismiss()

    # The following methods are those that are overridable from the
    # ComboPopup base class.  Most of them are not required, but all
    # are shown here for demonstration purposes.

    def Init(self):
        """
        # This is called immediately after construction finishes.  You can
        # use self.GetCombo if needed to get to the ComboCtrl instance.
        """
        self.value = -1
        self.curitem = -1

    def Create(self, parent):
        """ Create the popup child control.  Return true for success. """
        self.lc = wx.ListBox(parent, style=wx.LB_SINGLE)
#        self.lc.Bind(wx.EVT_MOTION, self.OnMotion)
        self.lc.Bind(wx.EVT_LISTBOX, self.Selected)
        return True

    def GetControl(self):
        """ Return the widget that is to be used for the popup """
        return self.lc

    def SetStringValue(self, val):
        """ Called just prior to displaying the popup, you can use it to
        'select' the current item.
        """
#        print("in setstringvalue, val is", val)
        idx = self.lc.FindString(val)
        if idx != wx.NOT_FOUND:
            self.lc.SetSelection(idx)

    def GetStringValue(self):
        """ Return a string representation of the current item. """
        if self.value >= 0:
            return self.lc.GetString(self.value)
        return ""

    def OnPopup(self):
        """ Called immediately after the popup is shown """
        wx.ComboPopup.OnPopup(self)

    def OnDismiss(self):
        """ Called when popup is dismissed """
        wx.ComboPopup.OnDismiss(self)

    def PaintComboControl(self, dc, rect):
        """ This is called to custom paint in the combo control itself
        (ie. not the popup).  Default implementation draws value as string.
        """
        wx.ComboPopup.PaintComboControl(self, dc, rect)

    def OnComboKeyEvent(self, event):
        """ Receives key events from the parent ComboCtrl.  Events not
        handled should be skipped, as usual.
        """
        wx.ComboPopup.OnComboKeyEvent(self, event)

    def OnComboDoubleClick(self):
        """ Implement if you need to support special action when user
        double-clicks on the parent wxComboCtrl.
        """
        wx.ComboPopup.OnComboDoubleClick(self)

    def GetAdjustedSize(self, minWidth, prefHeight, maxHeight):
        """ Return final size of popup. Called on every popup, just prior to OnPopup.
        minWidth = preferred minimum width for window
        prefHeight = preferred height. Only applies if > 0,
        maxHeight = max height for window, as limited by screen size
        and should only be rounded down, if necessary.
        """
        return wx.ComboPopup.GetAdjustedSize(self, minWidth, prefHeight, maxHeight)

    def LazyCreate(self):
        """ Return true if you want delay the call to Create until the popup
        is shown for the first time. It is more efficient, but note that
        it is often more convenient to have the control created
        immediately.
        Default returns false.
        """
        return wx.ComboPopup.LazyCreate(self)

class ComboList(wx.ComboCtrl):

    def __init__(self, parent, id=wx.ID_ANY, choices=None,
                 pos=wx.DefaultPosition,
                 size=wx.DefaultSize, # style=wx.CB_READONLY,
                 ):


        wx.ComboCtrl.__init__(self, parent, id, pos=pos, size=size) # , style=style)

        self.popupCtrl = ListCtrlComboPopup()

        # It is important to call SetPopupControl() as soon as possible
        self.SetPopupControl(self.popupCtrl)


        if choices:
            self.popupCtrl.InsertItems(choices)
#            for item in choices:
#                self.popupCtrl.AddItem(item)

    def InsertItems(self, choices):
        self.popupCtrl.InsertItems(choices)


    def SetItems(self, choices):
        self.popupCtrl.InsertItems(choices)
