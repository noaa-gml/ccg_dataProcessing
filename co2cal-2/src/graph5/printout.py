# vim: tabstop=4 shiftwidth=4 expandtab
import wx

#-------------------------------------------------------------------------------
# Used to layout the printer page

class PlotPrintout(wx.Printout):
    """Controls how the plot is made in printing and previewing"""
    # Do not change method names in this class,
    # we have to override wx.Printout methods here!
    def __init__(self, graph):
        """graph is instance of plotCanvas to be printed or previewed"""
        wx.Printout.__init__(self)
        self.graph = graph

    def OnBeginDocument(self, start, end):
        return super().OnBeginDocument(start, end)

    def OnEndDocument(self):
        super().OnEndDocument()

    def OnBeginPrinting(self):
        super().OnBeginPrinting()

    def OnEndPrinting(self):
        super().OnEndPrinting()

    def OnPreparePrinting(self):
        super().OnPreparePrinting()

    def GetPageInfo(self):
        return (1, 1, 1, 1)

    def HasPage(self, page):
        if page <= 2:
            return True
        else:
            return False

    def OnPrintPage(self, page):

        self.FitThisSizeToPageMargins(wx.Size(self.graph.width, self.graph.height), self.graph.pageSetupData)
        dc = self.GetDC()  # allows using floats for certain functions
        self.graph._draw(dc)
        return True
