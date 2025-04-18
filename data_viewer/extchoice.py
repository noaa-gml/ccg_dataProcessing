# vim: tabstop=4 shiftwidth=4 expandtab
# --------------------------------------------------------------------------- #
# EXTENDEDCHOICE wxPython IMPLEMENTATION
# Python Code By:
#
# Andrea Gavana, @ 16 May 2005
# Latest Revision: 18 Dec 2005, 22.48 CET
#
#
# TODO List/Caveats
#
# 1. Multiple Choices With *The Same* Label Are Not Handled Very Well In
#    The wx.EVT_MOUSEWHEEL Event Binder For The Top StaticText Control.
#    Try Putting 2 Or More Choices With The Same Name And See It For Yourself.
#
# ---------------------------------------------------------------------------
# This Should Be Written In Big Red Blinking Colour:
# 2. On Windows 2000, Icons Have A *BAD* Black Background, Instead Of The
#    Transparent One.
# ---------------------------------------------------------------------------
#
# 3. Layout With Sizers May Be Handled Better. I Am Unable To Set Correctly
#    The Vertical Size Of The Top StaticText When An Item Spans More Than
#    1 Row (See The Demo, 3rd Control Called "Same Icon").
#    Moreover, I Am Unable To Set The Size Of The Top StaticText Control
#    *Without* A wx.EVT_SIZE Handler. Can This Be Avoided?
#
# 4. After The Failures Of wx.PopupTransientWindow And wx.PopupWindow, I Am
#    Using A wx.Dialog To Popup The Choices. By Looking At The wxPython Demo,
#    Under wx.lib.popupctl, It Seems That This Approach May Not Work On MAC.
#
# 5. Other Issues?
#
#
# For All Kind Of Problems, Requests Of Enhancements And Bug Reports, Please
# Write To Me At:
#
# andrea.gavana@agip.it
# andrea_gavan@tin.it
#
# Or, Obviously, To The wxPython Mailing List!!!
#
#
# End Of Comments
# --------------------------------------------------------------------------- #


"""Description:

The idea of an ExtendedChoice implementation that is (hopefully) portable to all
platforms supported by wxPython is interesting. Windows already have this kind
of feature.
ExtendedChoice is built using 4 different controls:

- A wx.StaticBitmap to handle the icons;
- A wx.lib.stattext.StaticText to simulate the behavior of a wx.TextCtrl (which
  does not line up correctly in a sizer if you use the wx.NO_BORDER style for it);
- A wx.lib.buttons.GenBitmapButton to simulate the wx.Choice/wx.ComboBox button;
- A wx.Dialog (to replace a wx.PopupTransientWindow) with a wx.VListBox inside
  to simulate the behavior of wx.Choice/wx.ComboBox expanded choice list.

What It Can Do:

- Behaves like wx.Choice or wx.ComboBox in handling Char/Key events;
- Set the whole control colour or change it in runtime;
- Set most Background/Foreground colour for choices, Background/Foreground
- Motifs/Styles, text colour and text selection colour;
- Set or change in runtime font associated to each or all the choices;
- Depending On The Class Construction (EC_RULES Style), You Can Have Borders
  And Customize Them;
- Sort ascending/descending the choices;
- Add or remove choices from the choice-list;
- Add icons/images in runtime to the wx.ImageList associated to the control;
- Change the order in which icons and choices are associated (change icon for
  an already present choice);
- Replace choices with other user-defined strings/labels.

Event Handlers:

- wx.EVT_CHAR events: ExtendedChoice handles char events by recognizing the char
  keycode, and these actions are taken accordingly:

  a) Special keys like TAB, SHIFT-TAB, ENTER: these are passed to the next control
     using wx.NavigationKeyEvent();
  b) wx.Choice navigation keys like UP/DOWN/LEFT/RIGHT ARROWS are used to move
     selection up/down/up/down; PAGEUP, PAGEDOWN, HOME and END keys select
     respectively the first/last/first/last choice in the choice-list;
  c) Other keys are used to navigate between choices in the choice-list just like
     wx.Choice/wx.ComboBox.

- wx.EVT_MOUSEWHEEL event: When the control has the focus, mouse wheeling up/down
  scrolls the choice-list up and down.

- wx.EVT_LEFT_DOWN event: the left mouse button down is used when the choice-list
  is displayed in the wx.PopupTransientWindow. It is used to select an item from
  the list. This events triggers the custom wxEVT_EXTENDEDCHOICE event. I have
  chosen this event instead of the wx.EVT_LISTBOX because the latest one does not
  get called when you are handling other mouse events.

- wx.EVT_ENTER_WINDOW/wx.EVT_LEAVE_WINDOW events: these events affect:

  a) The button in ExtendedChoice. When the mouse enters the button area, the
     button changes slightly the colour to simulate some kind of "3D rendering".
  b) The wx.VListBox in the choice-list when it is displayed inside the
     wx.Dialog. When the mouse enters a choice "region", the choice is
     highlighted, while when it leaves the region returns in its normal state.

- wx.EVT_BUTTON event: this event is used to trigger the button-down of the
  control. It displays the choice-list in the wx.Dialog.

- wx.EVT_KILL_FOCUS/wx.EVT_SET_FOCUS events: these events are used to somewhat
  reproduce "correctly" the text selection in the ExtendeChoice when it loses or
  aquires the focus.


ExtendedChoice is freeware and distributed under the wxPython license.

Special Thanks To Franz Steinhausler And Robin Dunn For Their Nice Suggestions.

Latest Revision: Andrea Gavana @ 18 Dec 2005, 22.48 CET

"""


import wx

# for down arrow bitmap
#import images

from wx.lib.embeddedimage import PyEmbeddedImage

#----------------------------------------------------------------------
SmallUpArrow = PyEmbeddedImage(
    "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAADxJ"
    "REFUOI1jZGRiZqAEMFGke2gY8P/f3/9kGwDTjM8QnAaga8JlCG3CAJdt2MQxDCAUaOjyjKMp"
    "cRAYAABS2CPsss3BWQAAAABJRU5ErkJggg==")

#----------------------------------------------------------------------
SmallDnArrow = PyEmbeddedImage(
    "iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABHNCSVQICAgIfAhkiAAAAEhJ"
    "REFUOI1jZGRiZqAEMFGke9QABgYGBgYWdIH///7+J6SJkYmZEacLkCUJacZqAD5DsInTLhDR"
    "bcPlKrwugGnCFy6Mo3mBAQChDgRlP4RC7wAAAABJRU5ErkJggg==")


# -----------------------------------------------------------------------
# -----------------------------------------------------------------------

class TransientChoice(wx.PopupTransientWindow):
    """ This Class Implements The Scolling Window That Contains The Choice-List
    Used Internally.
    """

    def __init__(self, parent, style):
        """ Default Class Constructor.

        Used Internally. Do Not Use It Directly In This Control!"""

        self.first = True
        wx.PopupTransientWindow.__init__(self, parent, style)

        self._parent = parent

        self._vlistbox = wx.ListBox(self, -1, style=wx.SIMPLE_BORDER, choices=self._parent._choices)
        font = wx.Font(12, wx.FONTFAMILY_TELETYPE, wx.FONTSTYLE_NORMAL, wx.FONTWEIGHT_NORMAL)
        self._vlistbox.SetFont(font)
        self._vlistbox.Bind(wx.EVT_LISTBOX, self.selected)
        self.SetFocus()

        self.sizer = wx.BoxSizer(wx.VERTICAL)
        self.sizer.Add(self._vlistbox, 0, wx.GROW|wx.ALL, 0)

        self._set_height()
        self.SetSizerAndFit(self.sizer)
        self.Layout()
        self._update_value()

    def _update_value(self):
        """ Get the label from the parent text box, and set the
        entry in the ListBox that matches
        """

        currentvalue = self._parent.GetValue()
        if currentvalue in self._parent._choices:
            indx = self._parent._choices.index(currentvalue)
            self._vlistbox.SetSelection(indx)

    def selected(self, event):
        """ A ListBox entry has been selected.  Remember the
        position in the list, and set the text control
        """

        # python 3 calls selected when popup first appears,
        # which causes problems.  avoid this here
        if self.first:
            self.first = False
            return

        selection = self._vlistbox.GetSelection()
        if selection < 0:
            return

        textlabel = self._parent._choices[selection]
        self._parent._statictext.SetValue(textlabel)
        event.Skip()

        self.Dismiss()

    def MeasureAllItems(self):
        """Returns The Cumulative Height Of All The Items In The wx.VListBox."""

        height = 0
        for choice in self._parent._choices:
            for line in choice.split('\n'):
                (w, h, d, a) = self.GetFullTextExtent(line)
                height += h + d

        return height + 20

    def _set_height(self):
        """ Set the size of the ListBox """

        h = self.MeasureAllItems()
        h = min(h, 400)

        sz = self._parent.GetSize()
        self._vlistbox.SetMinSize((sz[0], h))
        self.SetMinSize((sz[0], h))
        self.SetSize((sz[0], h))
        self.sizer.Fit(self._vlistbox)


    def ReplaceAll(self):
        """ Replace all entries in the ListBox """

        listbox = self._vlistbox
        listbox.Clear()
        for txt in self._parent._choices:
            listbox.Append(txt)

        self._set_height()
        self._update_value()

# ---------------------------------------------------------------
class ExtendedChoice(wx.Panel):
    """ This Is The Main ExtendedChoice Implementation. """

    def __init__(self, parent, id=wx.ID_ANY, choices=None,
                 pos=wx.DefaultPosition,
                 size=wx.DefaultSize, style=0,
                 itemsperpage=None):

        """ Default Class Constructor.

        ExtendedChoice.__init__(self, parent, id=wx.ID_ANY, choices=None,
                    pos = wx.DefaultPosition, size=wx.DefaultSize,
                    style=0)

        Non-Default Parameters Are:
            - choices: A list of strings
            - itemsperpage: Number Of Items "Per Page" Of The wx.VListBox. This Is
              Useful In Order To Limit The wx.VListBox Vertical Size.

        """

        wx.Panel.__init__(self, parent, id, pos=pos, size=size, style=wx.TAB_TRAVERSAL)

        self._itemsperpage = itemsperpage

        if choices is not None:
            self._choices = choices[:]
            self._statictext = wx.TextCtrl(self, -1, choices[0], size=size, style=wx.TE_READONLY)
        else:
            self._choices = []
            self._statictext = wx.TextCtrl(self, -1, "", size=size, style=wx.TE_READONLY)

        self._statictext.Bind(wx.EVT_LEFT_DOWN, self.OnChoiceButton)

        self._choicebutton = wx.BitmapButton(self, -1, SmallDnArrow.GetBitmap())
        self._choicebutton.Bind(wx.EVT_BUTTON, self.OnChoiceButton)

        self.Bind(wx.EVT_SIZE, self.OnSize)

        self._choicewindow = TransientChoice(self, wx.SIMPLE_BORDER)


    #-----------------------------------------------------
    def OnSize(self, event):
        """Handles The Event Size, To Avoid Bad Resizing Of The Control."""

        # bitmap is 26 pixels wide and high
        w, h = self.GetClientSize()
        if w == 0 or h == 0: return
        self._statictext.SetSize(0, 0, w - 28, h)
#        self._statictext.SetDimensions(0, 0, w - 28, h)

        self._choicebutton.SetSize(w - 28, 0, 28, 28)
#        self._choicebutton.SetDimensions(w - 28, 0, 28, 28)


    #-----------------------------------------------------
    def OnChoiceButton(self, event):
        """Handles The wx.EVT_LEFT_DOWN Event Of The Main Button Of The Control.

        This Action Causes The wx.Dialog That Contains Choices And Icons To
        Pop-Up. The Pop-Up Does Not Happen If The Choice-List Is Empty.
        """

        # Show the popup right below or above the button
        # depending on available screen space...

        if len(self.GetChoices()) == 0:
            return

        pos = self._statictext.ClientToScreen((0, 0))
        sz = self._statictext.GetSize()
        self._choicewindow.Position(pos, (0, sz[1]))
        self._choicewindow.Popup()


    #-----------------------------------------------------
    def SetValue(self, label):
        """Sets The Top StaticText Value."""

        if label not in self._choices:
            raise ValueError("ERROR: Input Label Is Not Present In Initial Choices")

        xind = self._choices.index(label)

        self._statictext.SetValue(label)
        self._statictext.Refresh()
        self._statictext.SetFocus()

        self._choicewindow._vlistbox.SetStringSelection(label)


    #-----------------------------------------------------
    def GetValue(self):
        """Returns The Current Value In The Top StaticText Control."""

        return self._statictext.GetValue()


    #-----------------------------------------------------
    def GetChoices(self):
        """Returns The Whole List Of Choices."""

        return self._choices

    #-----------------------------------------------------
    def SetItems(self, choices):
        """ Set the itmes in the child ListBox """

        self.ReplaceAll(choices)
    #-----------------------------------------------------
    def Set(self, choices):
        """ Set the itmes in the child ListBox """

        self.ReplaceAll(choices)

    #-----------------------------------------------------
    def ReplaceAll(self, choices):
        """ Set the itmes in the child ListBox """

        oldvalue = self.GetValue()
        self._choices = choices[:]
        self._choicewindow.ReplaceAll()

        if oldvalue in self._choices:
            self._statictext.SetValue(oldvalue)
        else:
            self._statictext.SetValue(self._choices[0])
