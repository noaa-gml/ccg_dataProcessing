
# vim: tabstop=4 shiftwidth=4 expandtab
"""
class for doing the ccgFilter curve fitting
in the ccgvu wx window
"""

import numpy

from graph5.dataset import Dataset
import ccg_filter

import ccg_dates


# ----------------------------------------------
def createDataset(graph, x, y, name, color, symbol, linewidth=1):
    """ Create or update the data in a graph dataset """

    if len(x) == 0 or len(y) == 0:
        return False

    dataset = graph.getDataset(name)
    if dataset is None:
        dataset = Dataset(x, y, name)
        dataset.style.setLineColor(color)
        dataset.style.setMarker(symbol)
        dataset.style.setFillMarkers(0)
        dataset.style.setLineWidth(linewidth)
        graph.addDataset(dataset)
    else:
        dataset.SetData(x, y)

    return True


# ----------------------------------------------
class filterData:
    """
    Apply ccgvu filter to data

    Process the data in the x, y variables.  Do curve fits to the
    data, create graph datasets and plot the datasets.

    Args:
        grapher : ccgvu wxFrame window
        x : x axis (time) data array
        y : y axis (mole fraction) data
        name : name for dataset
    """

    # ----------------------------------------------
    def __init__(self, grapher, x, y, name, parameters):

        grapher.SetStatusText("Processing Data...")

        #    print "name is ", name

        # needed for export dialog
        self.start_date = ccg_dates.datetimeFromDecimalDate(x[0])

        gap = 0
        if parameters.fill_gap:
            gap = parameters.gap_size
        self.filt = ccg_filter.ccgFilter(x,
                                         y,
                                         parameters.short_cutoff,
                                         parameters.long_cutoff,
                                         parameters.interval,
                                         parameters.npoly,
                                         parameters.nharm,
                                         parameters.zero,
                                         gap,
                                         use_gain_factor=parameters.gain,
                                         debug=False)

        # Seasonal cycle amplitudes ----------------------------
        amps = self.filt.getAmplitudes()
        a = numpy.array(amps)

        # columns are year, total amplitude, date of max amplitude, max amplitude,
        # date of min amplitude, min amplitude
        page = grapher.nb.GetPage(4)
        if a.size > 0:
            createDataset(page, a.T[0] + 0.5, a.T[1], 'Amplitude', 'blue', 'circle', linewidth=2)
            createDataset(page, a.T[2], a.T[3], 'Amplitude Max', 'red', 'circle', 2)
            createDataset(page, a.T[4], a.T[5], 'Amplitude Min', 'green', 'circle', 2)
            page.title.text = name
            page.update()

        # Data plot -------------------------
        x0 = self.filt.xinterp
        y1 = self.filt.getFunctionValue(x0)
        y2 = self.filt.getPolyValue(x0)
        y3 = self.filt.getSmoothValue(x0)
        y4 = self.filt.getTrendValue(x0)

        page = grapher.nb.GetPage(0)
        createDataset(page, x, y, 'Data', 'black', 'square')
        createDataset(page, x0, y1, 'Function', 'magenta', 'None', linewidth=2)
        createDataset(page, x0, y2, 'Poly', 'cyan', 'None', linewidth=2)
        createDataset(page, x0, y3, 'Smoothed', 'red', 'None', linewidth=2)
        createDataset(page, x0, y4, 'Trend', 'blue', 'None', linewidth=2)
        page.title.text = name
        page.update()

        # Seasonal Cycle plot ------------------------
        trend = self.filt.getTrendValue(x)
        ys2 = y - trend
        y6 = self.filt.getHarmonicValue(x0)
        y5 = y6 + self.filt.smooth - self.filt.trend

        page = grapher.nb.GetPage(1)
        createDataset(page, x, ys2, 'Detrended data', 'black', 'square')
        createDataset(page, x0, y5, 'Smoothed Cycle', 'red', 'None', linewidth=2)
        createDataset(page, x0, y6, 'Harmonics', 'blue', 'None', linewidth=2)
        page.title.text = name
        page.update()

        # Residuals plot -----------------------
        ys3 = self.filt.resid
        yy = self.filt.getSmoothValue(x)
        ys4 = self.filt.yp - yy
        y7 = self.filt.smooth
        y8 = self.filt.trend

        x1 = self.filt.xinterp
        y9 = self.filt.yinterp

        page = grapher.nb.GetPage(2)
        createDataset(page, x, ys3, 'Residuals', 'black', 'square')
        createDataset(page, x, ys4, 'Residuals from Smooth', 'black', 'plus')
        createDataset(page, x1, y9, 'Interpolated/Equal spaced data', '#00bb00', 'circle')
        createDataset(page, x0, y7, 'Smoothed Residuals', 'red', 'None', linewidth=2)
        createDataset(page, x0, y8, 'Trend Residuals', 'blue', 'None', linewidth=2)
        page.title.text = name
        page.update()

        # Growth Rate plot ----------------------------
        y9 = self.filt.deriv

        page = grapher.nb.GetPage(3)
        createDataset(page, x0, y9, 'Growth Rate', 'red', 'None', linewidth=2)
        page.title.text = name
        page.update()

        # Filter response plot ------------------------
        page = grapher.nb.GetPage(5)

        freq, r = self.filt.getFilterResponse(parameters.short_cutoff)
        createDataset(page, freq, r, 'Short Term Filter Response', 'red', 'None', linewidth=2)

        freq, r = self.filt.getFilterResponse(parameters.long_cutoff)
        createDataset(page, freq, r, 'Long Term Filter Response', 'blue', 'None', linewidth=2)
        page.update()

        grapher.update_menus(1)
        grapher.SetStatusText("")

    #    yhat, upcb, lwcb = filt.get_cb()
    #    print yhat
    #    print upcb
    #    print lwcb

    # ----------------------------------------------
    def getAmplitudeStats(self):
        """ Generate text showing annual amplitude results """

        amps = self.filt.getAmplitudes()

        months = [
            "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
            "Oct", "Nov", "Dec"
        ]

        s = """
    *****  Season Cycle Statistics.  *****

     Year      Amplitude     Maximum   Date     Minimum   Date
    -----------------------------------------------------------
    """

        for (year, amp, maxdate, maxval, mindate, minval) in amps:

            (yr, mnmax, dmax, hr, mn, sec) = ccg_dates.calendarDate(maxdate)
            (yr, mnmin, dmin, hr, mn, sec) = ccg_dates.calendarDate(mindate)

            s += "    %5.0f %12.2f %12.2f   %3s %2d %9.2f   %3s %2d\n" % (
                year, amp, maxval, months[mnmax], dmax, minval, months[mnmin],
                dmin)

        return s

    # ----------------------------------------------
    def getMonthlyStats(self):
        """ Generate text showing monthly means """

        mm = self.filt.getMonthlyMeans()
        s = ""
        for (year, month, val, std, n) in mm:

            s += "%4d %02d %7.2f %5.2f %2d\n" % (year, month, val, std, n)

        return s

    # ----------------------------------------------
    def getFilterStats(self):
        """ Get text of filter statistics """

        return self.filt.stats()

    # ----------------------------------------------
    def getAnnualStats(self):
        """ Generate text showing annual means """

        ann = self.filt.getAnnualMeans()
        s = ""
        for (year, val, std, n) in ann:

            s += "%4d %7.2f %5.2f %2d\n" % (year, val, std, n)

        return s

    # ----------------------------------------------
    def getTrendCrossing(self):
        """ Generate text showing crossing dates of the smooth curve
        over the trend curve.
        """

        tcup, tcdown = self.filt.getTrendCrossingDates()
        months = [
            "", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep",
            "Oct", "Nov", "Dec"
        ]

        s = "Trend Crossing Dates\n    - to +           + to -\n" + "-" * 40 + "\n"

        for up, down in zip(tcup, tcdown):

            (uyr, umon, uday, hr, mn, sec) = ccg_dates.calendarDate(up)
            (dyr, dmon, dday, hr, mn, sec) = ccg_dates.calendarDate(down)

            s += "    %02d %s %4d    %02d %s %4d\n" % (uday, months[umon], uyr,
                                                       dday, months[dmon], dyr)

        return s
