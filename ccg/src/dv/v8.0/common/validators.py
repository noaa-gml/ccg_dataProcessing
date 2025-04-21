# vim: tabstop=4 shiftwidth=4 expandtab

import wx

V_STRING = 0
V_FLOAT = 1
V_INT = 2
V_DATE = 3
V_TIME = 4


##########################################################################
class FloatValidator(wx.Validator):
    def __init__(self, pyVar=None):
        wx.Validator.__init__(self)
        self.valid_chars = "0123456789.-+"
        self.Bind(wx.EVT_CHAR, self.OnChar)

    def Clone(self):
        return FloatValidator()

    def Validate(self, win):
        tc = self.GetWindow()
        val = tc.GetValue()
        print("val = ", val)

        for x in val:
            if x not in self.valid_chars:
                return False

        return True

    def OnChar(self, event):
        key = event.GetKeyCode()

        if key < wx.WXK_SPACE or key == wx.WXK_DELETE or key > 255:
            event.Skip()
            return

        if chr(key) in self.valid_chars:
            event.Skip()
            return

        if not wx.Validator_IsSilent():
            wx.Bell()

        # Returning without calling event.Skip eats the event before it
        # gets to the text control
        return

    def TransferToWindow(self):
        """ Transfer data from validator to window.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.

    def TransferFromWindow(self):
        """ Transfer data from window to validator.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """

        return True  # Prevent wxDialog from complaining.


##########################################################################
class IntValidator(wx.Validator):
    def __init__(self, pyVar=None):
        wx.Validator.__init__(self)
        self.valid_chars = "0123456789+-"
        self.Bind(wx.EVT_CHAR, self.OnChar)

    def Clone(self):
        return IntValidator()

    def Validate(self, win):
        tc = self.GetWindow()
        val = tc.GetValue()
        print("val = ", val)
        if len(val) == 0:
            print("no int data")
            return False

        for x in val:
            if x not in self.valid_chars:
                return False

        return True

    def OnChar(self, event):
        key = event.GetKeyCode()

        if key < wx.WXK_SPACE or key == wx.WXK_DELETE or key > 255:
            event.Skip()
            return

        if chr(key) in self.valid_chars:
            event.Skip()
            return

        if not wx.Validator_IsSilent():
            wx.Bell()

        # Returning without calling even.Skip eats the event before it
        # gets to the text control
        return

    def TransferToWindow(self):
        """ Transfer data from validator to window.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.

    def TransferFromWindow(self):
        """ Transfer data from window to validator.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.


##########################################################################
class DateValidator(wx.Validator):
    def __init__(self, pyVar=None):
        wx.Validator.__init__(self)
        self.valid_chars = "0123456789-"
        self.Bind(wx.EVT_CHAR, self.OnChar)

    def Clone(self):
        return DateValidator()

    def Validate(self, win):
        tc = self.GetWindow()
        val = tc.GetValue()
        print("val = ", val)
        if len(val) == 0:
            print("no int data")
            return False

        for x in val:
            if x not in self.valid_chars:
                return False

        return True

    def OnChar(self, event):
        key = event.GetKeyCode()

        if key < wx.WXK_SPACE or key == wx.WXK_DELETE or key > 255:
            event.Skip()
            return

        if chr(key) in self.valid_chars:
            event.Skip()
            return

        if not wx.Validator_IsSilent():
            wx.Bell()

        # Returning without calling even.Skip eats the event before it
        # gets to the text control
        return

    def TransferToWindow(self):
        """ Transfer data from validator to window.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.

    def TransferFromWindow(self):
        """ Transfer data from window to validator.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.


##########################################################################
class TimeValidator(wx.Validator):
    def __init__(self, pyVar=None):
        wx.Validator.__init__(self)
        self.valid_chars = "0123456789:"
        self.Bind(wx.EVT_CHAR, self.OnChar)

    def Clone(self):
        return TimeValidator()

    def Validate(self, win):
        tc = self.GetWindow()
        val = tc.GetValue()
        print("val = ", val)
        if len(val) == 0:
            print("no int data")
            return False

        for x in val:
            if x not in self.valid_chars:
                return False

        return True

    def OnChar(self, event):
        key = event.GetKeyCode()

        if key < wx.WXK_SPACE or key == wx.WXK_DELETE or key > 255:
            event.Skip()
            return

        if chr(key) in self.valid_chars:
            event.Skip()
            return

        if not wx.Validator_IsSilent():
            wx.Bell()

        # Returning without calling even.Skip eats the event before it
        # gets to the text control
        return

    def TransferToWindow(self):
        """ Transfer data from validator to window.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.

    def TransferFromWindow(self):
        """ Transfer data from window to validator.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.


##########################################################################
class Validator(wx.Validator):
    def __init__(self, flag=None, pyVar=None):
        wx.Validator.__init__(self)

        self.flag = flag
        if flag == V_FLOAT:
            self.valid_chars = "0123456789.+-E"
        elif flag == V_INT:
            self.valid_chars = "0123456789+-"
        elif flag == V_DATE:
            self.valid_chars = "0123456789-"
        elif flag == V_TIME:
            self.valid_chars = "0123456789:"
        else:
            self.valid_chars = "0123456789.+-"

        self.Bind(wx.EVT_CHAR, self.OnChar)

    def Clone(self):
        return Validator(self.flag)

    def Validate(self, win):
        tc = self.GetWindow()
        val = tc.GetValue()
        print("val = ", val)
        if len(val) == 0:
            print("no int data")
            return False

        for x in val:
            if x not in self.valid_chars:
                return False

        return True

    def OnChar(self, event):
        key = event.GetKeyCode()

        if key < wx.WXK_SPACE or key == wx.WXK_DELETE or key > 255:
            event.Skip()
            return

        if chr(key) in self.valid_chars:
            event.Skip()
            return

        if not wx.Validator_IsSilent():
            wx.Bell()

        # Returning without calling even.Skip eats the event before it
        # gets to the text control
        return

    def TransferToWindow(self):
        """ Transfer data from validator to window.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.

    def TransferFromWindow(self):
        """ Transfer data from window to validator.

             The default implementation returns False, indicating that an error
             occurred.  We simply return True, as we don't do any data transfer.
        """
        return True  # Prevent wxDialog from complaining.


###################################################################
def checkVal(textCtrl, val, flag=V_STRING, length=None):
    """ This is a generic routine for checking if the user
    has entered a valid value in a text control box.
    Input:
        The text ctrl widget
        The string from the text ctrl widget
        A flag defining what type of result to check for.
           The flag should be one of 'V_FLOAT', 'V_INT', 'V_STRING',
           'V_DATE', 'V_TIME'

    If the value from the text control is not correct, a message box
    is popped up, the background of the text control is turned pink,
    and False is returned.
    """

    # Check for empty string first
    if len(val) == 0:
        wx.MessageBox("Please enter a value!", "Error")
        textCtrl.SetBackgroundColour("pink")
        textCtrl.SetFocus()
        textCtrl.Refresh()
        return False

    if length is not None:
        if len(val) != length:
            wx.MessageBox("Entry must be %d characters!" % length, "Error")
            textCtrl.SetBackgroundColour("pink")
            textCtrl.SetFocus()
            textCtrl.Refresh()
            return False

    # Check for valid type
    if flag == V_FLOAT:
        try:
            num = float(val)
        except ValueError:
            wx.MessageBox("Not a valid float number!", "Error")
            textCtrl.SetBackgroundColour("pink")
            textCtrl.SetFocus()
            textCtrl.Refresh()
            return False

    elif flag == V_INT:
        try:
            num = int(val)
        except ValueError:
            wx.MessageBox("Not a valid integer number!", "Error")
            textCtrl.SetBackgroundColour("pink")
            textCtrl.SetFocus()
            textCtrl.Refresh()
            return False

    textCtrl.SetBackgroundColour(wx.SystemSettings.GetColour(wx.SYS_COLOUR_WINDOW))
    textCtrl.Refresh()

    return True
