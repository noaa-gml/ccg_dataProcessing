# vim: tabstop=4 shiftwidth=4 expandtab
"""
Perform an outlier rejection of data using ccg_filter curve fit to data
"""

import sys
import datetime
import numpy

sys.path.append("/ccg/python/ccglib")
import ccg_filter
from ccg_filter_params import filterParameters

import ccg_dates


######################################################################
class quickFilter:
    """ Perform filtering of data based on outliers from a smooth curve.

    Args:
        x : Date values.  Can be a list/array of decimal date values or datetime objects
        y : Mole Fraction values.  Can be either a list or numpy array
        flags : An integer value associated with the data point flag.
                0 = unflagged, include in fit, 1 = auto flagged.
                Any other value is not used and is not changed.

    Attributes:
        summaryText (str): Text summarizing changes to flags that were made
        flags (list): Array of new flags values for each data point
        xFiltered (list): Array of new x points excluding flagged data
        yFiltered (list): Array of new y points excluding flagged data
        filt (ccgFilter): ccgFilter object
        params (filterParameters): filterParameters object

    Methods:
        setEnvelope(sigmaminus, sigmaplus): Set envelope in terms of multiples of the residual standard deviation
        setFilterParameters(params...): Set filter and function parameters

    Results:
        Creates three members with filtered results:

        * xFiltered: array of x values for unflagged data
        * yFiltered: array of y values for unflagged data
        * flags: array of integer flag values. A value of 1 indicates automatically flagged data point


    The parameters for the filter can be set either through the convenience 
    functions setEnvelope() and setFilterParameters(), or set directy with::

        params = filterParameters()
        qf.params = params

    Example::

        qf = quickFilter(x, y)
        qf.setEnvelope(2.5, 2.5)
        qf.setFilterParameters(short_cutoff=120)
        qf.run()
        newx = qf.xFiltered
        newy = qf.yFiltered
        flags = qf.flags
    """


    def __init__(self, x, y, flags):

        self.xFiltered = None
        self.yFiltered = None
        self.summaryText = None
        self.filt = None
        self.flag_years = None

        # set default parameters.  These can be changed with setFilterParameters()
        # or individually with qf.params.short_cutoff = 60
        self.params = filterParameters()

        if isinstance(x[0], datetime.datetime):
            x = [ccg_dates.decimalDateFromDatetime(xp) for xp in x]

        self.mf = numpy.array(y)
        self.dd = numpy.array(x)
        self.flags = numpy.array(flags)


    #----------------------------------------------------------------------
    def run(self):
        """ Perform an outlier rejection of data using ccg_filter curve fit to data """

        text = []
        _format = "  Changed data point on %s %8.2f %d -> %d (diff from curve %.3f)"


        # loop until number of rejected points = 0
        nr = 1
        loopnum = 0
        while nr > 0 and loopnum < 50:

            loopnum += 1

            text.append("\nPass # %d through data" % (loopnum))
            text.append("-----------------------------------------")

            # get only unflagged data
            w = numpy.where(self.flags == 0)
            x = self.dd[w]
            y = self.mf[w]
            years = self.dd.astype(int)

            # do curve fit
            filt = ccg_filter.ccgFilter(
                x, y,
                self.params.short_cutoff,
                self.params.long_cutoff,
                self.params.interval,
                self.params.npoly,
                self.params.nharm,
                self.params.zero,
                use_gain_factor=self.params.gain
            )

            # Find the residual std. dev about the smooth curve
            text.append("Residual std. dev. is %f " % filt.rsd2)
            sigma3plus = self.params.sigma_plus(filt.rsd2)
            sigma3minus = self.params.sigma_minus(filt.rsd2)

            # get smoothed curve value for all data points and residuals
            y1 = filt.getSmoothValue(self.dd)
            diff = self.mf - y1

            if self.flag_years is None:
                # find auto flagged data that is inside +/- 3 sigma, remove auto flag
                w1 = numpy.where(
                    (self.flags==1) &
                    (((diff > 0) & (diff < sigma3plus)) |
                     ((diff < 0) & (diff > sigma3minus)))
                )

                # find unflagged data outside +/- 3 sigma, auto flag
                w = numpy.where(
                    (self.flags==0) &
                    ((diff > sigma3plus) | (diff < sigma3minus))
                )


            else:
                # find auto flagged data that is inside +/- 3 sigma, remove auto flag
                w1 = numpy.where(
                    (self.flags==1) & (numpy.in1d(years, self.flag_years)) &
                    (((diff > 0) & (diff < sigma3plus)) |
                     ((diff < 0) & (diff > sigma3minus)))
                )

                # find unflagged data outside +/- 3 sigma, auto flag
                w = numpy.where(
                    (self.flags==0) & (numpy.in1d(years, self.flag_years)) &
                    ((diff > sigma3plus) | (diff < sigma3minus))
                )

            nr = 0

            # set auto flagged data
            for i in w[0]:
                self.flags[i] = 1
                dt = ccg_dates.datetimeFromDecimalDate(self.dd[i])
                text.append(_format % (dt, self.mf[i], 0, 1, diff[i]))
                nr = nr + 1

            # remove auto flagged data
            for i in w1[0]:
                self.flags[i] = 0
                dt = ccg_dates.datetimeFromDecimalDate(self.dd[i])
                text.append(_format % (dt, self.mf[i], 1, 0, diff[i]))
                nr = nr + 1

        text.append("\nSummary")
        text.append("=====================================")
        w = numpy.where(self.flags == 1)
        for i in w[0]:
            dt = ccg_dates.datetimeFromDecimalDate(self.dd[i])
            text.append(_format % (dt, self.mf[i], 0, 1, diff[i]))

        text.append("\n%d points flagged" % len(w[0]))


        # create array with only unflagged data
        w = numpy.where(self.flags == 0)
        self.xFiltered = self.dd[w]
        self.yFiltered = self.mf[w]

        self.summaryText = "\n".join(text)
        self.filt = filt


    #----------------------------------------------------------------------
    def setEnvelope(self, sigmaminus, sigmaplus):
        """ Set width of envelope for flagging

        Args:
            sigmaminus (float): Number of residual standard deviations below the curve
            sigmaplus (float): Number of residual standard deviations above the curve
        """

        self.params.sigmaplus = sigmaplus
        self.params.sigmaminus = sigmaminus

    #----------------------------------------------------------------------
    def setFlagYears(self, years):
        """ Set the years that can be flagged.

        Args:
            years (list): list of years to be flagged, e.g. [2020,2021,2022]
        """

        if not isinstance(years, list) and not isinstance(years, range):
            raise TypeError("flag years must be a list")

        self.flag_years = years

    #----------------------------------------------------------------------
    def setFilterParameters(self,
            short_cutoff=None,
            long_cutoff=None,
            interval=None,
            numpoly=None,
            numharm=None,
            tzero=None,
            gain=None):
        """ Set parameter for the filter and curve fit.

        Args:
            short_cutoff : Short term cutoff.
            long_cutoff : Long term cutoff
            interval : Sampling interval
            numpoly : Number of polynomial terms to use in function fit
            numharm : Number of harmonic terms to use in function fit
            tzero : Value where x=0 in function coefficients
            gain : Use amplitude gain factor if True

        All arguments are optional.
        """

        if short_cutoff: self.params.short_cutoff = short_cutoff
        if long_cutoff: self.params.long_cutoff = long_cutoff
        if interval: self.params.interval = interval
        if numpoly: self.params.npoly = numpoly
        if numharm: self.params.nharm = numharm
        if tzero: self.params.zero = tzero
        if gain: self.params.gain = gain


################################################################################################

if __name__ == "__main__":

    import ccg_flask_data
    
    f = ccg_flask_data.FlaskData("co2", "ALT")
    f.setProject(1)
    f.setStrategy(True, False)
    f.includeFlaggedData()
    results = f.run(as_arrays=True)

#    print(f.results)
    flags = []
    for flag in results['qcflag']:
        if flag[0] != '.':
            flags.append(-1)
        elif flag[1] != '.':
            flags.append(2)
        else:
            flags.append(0)

    qf = quickFilter(f.results['date'], f.results['value'], flags)
    qf.setFlagYears([2022,2023])
    qf.run()
    print(qf.summaryText)
    print(qf.flags)

    for x, y, flag in zip(f.results['date'], f.results['value'], qf.flags):
        if flag == 1:
            print(x, y, flag)

