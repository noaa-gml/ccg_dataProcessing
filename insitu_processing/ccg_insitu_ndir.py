

# vim: tabstop=4 shiftwidth=4 expandtab
"""
Routines needed for calculating mole fractions for in-situ data
using NDIR systems.

This version uses same methods for calculations as previous programs.

Passed in 'raw' is a pandas dataframe, not a raw class object
"""

import sys
import datetime
import numpy
import pandas as pd

import ccg_utils
import ccg_insitu_utils
import ccg_insitu_corr
import ccg_insitu_config

DEFAULTVAL = -999.99

ONE_HOUR = datetime.timedelta(seconds=3600)

##################################################################
class ndir:
    """ Class for calculations involving insitu systems using NDIR,
        with either 2 or 3 working tanks.
        All data comes from the raw files, passed in by the 'raw' class object.

        Arguments
            required
                stacode - three letter station code, BRW, MLO, SMO, SPO
                gas - gas of interest, e.g. 'co2', 'ch4' ...
                raw - pandas DataFrame of raw data
                refgas - ccg_refgasdb class object
            optional
                smptype - Sample type to compute, either 'SMP' or 'TGT'
                debug - show extra debugging information if True

        Returns:
            results - pandas DataFrame
    """

    def __init__(self, stacode, gas, raw, system, refgas, smptype="SMP", debug=False):
        """ Class for calculations involving observatory insitu systems using NDIR.
        """

        # REQUIRED
        # create a namedtuple object for storing results
        self.Result = ccg_insitu_utils.resultTuple()

        self.stacode = stacode
        self.gas = gas.upper()
        self.raw = raw
        self.refgas = refgas
        self.debug = debug
        self.sample_type = smptype
        self.input_data = []
        self.coeffs = {}
        self.fit = 2
        self.results = []

        self.config = ccg_insitu_config.InsituConfig(stacode, gas, system)

        # Read in the correction data
        correctionsfile = "/ccg/%s/in-situ/corrections.%s" % (self.gas.lower(), self.gas.lower())
        self.corr = ccg_insitu_corr.insituCorrections(self.stacode, correctionsfile)


        startdate = self.raw.date.iloc[0]
        enddate = self.raw.date.iloc[-1]

        self.std_labels = self.config.get('stds', startdate).split()

        # determine when reference tanks or instruments change
        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, system, self.std_labels, self.refgas, startdate, enddate)

        # also check if number of working tanks changes
        prev_ntanks = None
        for date in self.raw.date:
            labels = self.config.get('stds', date).split()
            ntanks = len(labels)
            if ntanks != prev_ntanks and prev_ntanks is not None:
                self.caldates.append(date)
            prev_ntanks = ntanks

        self.caldates.sort()

#        print("caldates -------------")
#        print(self.caldates)
#        print("-------------")
#        sys.exit()



    #--------------------------------------------------------------------------
    def compute(self):
        """ Calculate mole fractions for old ndir measurements using working tanks """

        # We might need to break raw into different sections if the reference gas or instrument changes.
        # For each section, create a subset of raw for just that date interval,
        # then interpolate the reference gas at each sample date
        nsections = len(self.caldates) - 1
        for j in range(nsections):
            sdate = self.caldates[j]
            edate = self.caldates[j+1]
            df = self.raw[(self.raw.date >= sdate) & (self.raw.date < edate)].copy()

            # set configuration values for this block
            self.std_labels = self.config.get('stds', sdate).split()
            self.fit = self.config.getint('fit', sdate)
#            print(sdate, edate, self.std_labels, self.fit)

            # find cals here using interpolated values and dataframe for this block
            coeffs = self._find_cals(df)
            self.coeffs.update(coeffs)  # save for later
            if self.debug:
                print("cal data")
                for c in self.coeffs:
                    print(c, self.coeffs[c])

            df2 = df[(df.smptype == self.sample_type)]

            for row in df2.itertuples():

                resp = self._get_response(row, sdate, edate)
                mf, std, meas_unc, random_unc, flag = ccg_insitu_utils.calc_mf_ndir(row, resp, self.fit, self.debug)

                # apply corrections to the data
                if mf >= 0:
                    corr = self.corr.getCorrection(mf, row.date)
                    mf += corr
                    if self.debug: print("  correction:", corr)
                    if mf < 0:
                        mf = DEFAULTVAL
                        std = DEFAULTVAL

                if self.debug:
                    print(row)
                    print("mf, stdv, meas_unc, random_unc", mf, std, meas_unc, random_unc)

                t = (
                    self.stacode.upper(),
                    row.date,
                    round(mf, 2),
                    round(std, 2),
                    round(meas_unc, 2),
                    round(random_unc, 2),
                    row.n,
                    flag,
                    row.label,
                    row.comment
                )

                t = self.Result._make(t)
                self.results.append(t)

        self.results = pd.DataFrame(self.results)

        return self.results

    #--------------------------------------------------------------------------
    def printTable(self):
        """ print results in nice format """

        header = True
        for row in self.results.itertuples():

            std_labels = self.config.get('stds', self.raw.date[0]).split()
            if header:
                print("   Date     Time ", end="")
                for label in std_labels:
                    print("%18s" % label, end="")
                print("    Mole Fraction   Flag")
                header = False

            print("%s " % row.date.strftime("%Y-%m-%d %H:%M"), end="")
            for label in std_labels:
                tank = self.refgas.getRefgasByLabel(label, row.date)
                print(" %10s %6.2f" % (tank.serial_num, tank.value), end="")

            print("%10.2f %6.2f %5s" % (row.mf, row.stdv, row.flag))


    #--------------------------------------------------------------------------
    def _get_response(self, row, startdate, enddate):
        """ return calibration response curve information for the given date

        For cams era and beyond, we use both cal from previous hour and cal from
        current hour for getting the values.

        Need to make checks that both previous and current cal are valid, e.g.
        the previous cal must be in the previous hour from the sample,
        and the next cal must be in the same hour as the sample.

        Drift correct the working tank voltages to the mid point of the sample,
        then calculate the analyzer response.  This keeps same method
        as in earlier processing programs.

        If no uncertainty data on analyzer values, don't use odr fit, use poly instead.
        """

        date = row.date
        if self.debug:
            print("---- Get response for", date)

        # for cams era and after, work tanks are at end of hour, so
        # drift correct from previous hours work tanks
        # Before cams, working tanks were actually in the middle of the hour, so no drift correction is done.
        # In the raw files, the cals are at the end of the hour for both cases.
        cams = self.config.getboolean('cams', date)

        prev_cal_date = self._get_prev_cal(date, startdate) if cams else None
        next_cal_date = self._get_next_cal(date, enddate)

        flag = "C.."

        # self.coeffs is dict of tuples, (x, y, xsd, ysd, dates)
        if prev_cal_date is not None and next_cal_date is not None:

            (px, py, pxsd, pysd, pdate, pflag) = self.coeffs[prev_cal_date]
            (nx, y, nxsd, ysd, ndate, nflag) = self.coeffs[next_cal_date]
            next_date = self.raw.date[row.Index+1]
            mid_time = date + (next_date - date)/2

            # drift correct x values to mid_time
            x = []
            xsd = []
            for i in range(len(px)):

                if pflag[i] == nflag[i]:

                    tdiff = (ndate[i] - pdate[i]).total_seconds()
                    smp_tdiff = (mid_time - pdate[i]).total_seconds()

                    drift = (nx[i] - px[i]) / tdiff
                    xp = px[i] + drift * smp_tdiff

                    drift = (nxsd[i] - pxsd[i]) / tdiff
                    xpsd = pxsd[i] + drift * smp_tdiff
                    flag = "..."

                else:
                    xp = nx[i]
                    xpsd = nxsd[i]
                    flag = "..>"

                x.append(xp)
                xsd.append(xpsd)

        elif next_cal_date is not None:

            (x, y, xsd, ysd, ndate, f) = self.coeffs[next_cal_date]
            flag = "..." if not cams else "..>"

        else:
            x = [0 for i in self.std_labels]
            xsd = [0]


        #----------------------------
        # default values
        coeffs = [0.0, 0.0, 0.0]
        covar = numpy.zeros((self.fit+1, self.fit+1))
        rsd = 0
        ref_stdv = 0

        # check if values are the same.  Mainly for older smo ndir data
        if not numpy.all(numpy.array(x) == numpy.array(x)[0]):

            # can't use odr if we don't have x weights
            if numpy.all(numpy.array(xsd) == 0):
                c = numpy.polyfit(x, y, deg=self.fit)
                coeffs = c[::-1]
            else:
                if self.debug:
                    print("x input to odr:", x, xsd, self.fit)
                    print("y input to odr:", y, ysd, self.fit)
                fit, rsd = ccg_utils.odr_fit(self.fit, x, y, xsd, ysd, False)  # self.debug)
                coeffs = fit.beta
                covar = fit.cov_beta
        ref_stdv = xsd[0]

        if self.debug:
            print("\ndate, prev_cal_date, next_cal_date:", date, prev_cal_date, next_cal_date)
            print("coeffs", coeffs)
            print("covar", covar)
            print("flag", flag)
            print("rsd", rsd)


        # mimic structure from responseDb class
        resp = {'coeffs': coeffs, 'flag': flag, 'covar': covar, 'rsd': rsd, 'ref_stdv': ref_stdv}

        return resp


    #--------------------------------------------------------------------------
    def _get_prev_cal(self, date, sdate):
        """ to find previous cal, go backwards until the cal date is
         less than the given date
        """

        # find last cal before the given date
        for cal_date in sorted(self.coeffs, reverse=True):
            if sdate <= cal_date <= date:
                if (date - cal_date) <= ONE_HOUR:
                    return cal_date

        return None

    #--------------------------------------------------------------------------
    def _get_next_cal(self, date, edate):
        """ to find next cal, go forwards until the cal date is
         greater than the given date
        """

        # find first cal after the given date
        for cal_date in self.coeffs:
            if date <= cal_date <= edate:
                if (cal_date - date) <= ONE_HOUR:
                    return cal_date

        return None


    #--------------------------------------------------------------------------
    def _find_cals(self, df):
        """ Find the cals for ndir.

        Find the rows in the raw data that match the first working tank (e.g. W2)
        Then extract the analyzer value and standard deviation and
        assigned working tank mole fraction for all of the working tanks for
        that calibration. Save these for later use in calculating response curve.
        """

        data = {}

        # find all rows that have the first standard
        df2 = df[df.label == self.std_labels[0]]

        ntanks = len(self.std_labels)


        for row in df2.itertuples():

            valid = self._check_cal(row.Index, df, self.std_labels)
            if not valid: continue

            # get drift corrected assigned values
            y = []
            ysd = []
            for label in self.std_labels:
                tank = self.refgas.getRefgasByLabel(label, row.date)
                y.append(tank.value)
                ysd.append(0.03)   # ysd.append(tank.unc)

            x = df.loc[row.Index:row.Index+ntanks-1].value.tolist()
            xsd = df.loc[row.Index:row.Index+ntanks-1].stdv.tolist()
            xsd = [max(xsd) if xx == 0 else xx for xx in xsd]  # can't have weight=0 for odr

            times = df.loc[row.Index:row.Index+ntanks-1].date.tolist()
            f = df.loc[row.Index:row.Index+ntanks-1].flag.tolist()

            self.input_data.append((x, y, xsd, ysd))

            # save sd of first working tank to use later for random unc
            data[row.date] = (x, y, xsd, ysd, times, f)
            if self.debug:
                print("calibration curve for date:", row.date)
                print("   response curve x:", x)
                print("   response curve x sd:", xsd)
                print("   response curve y:", y)
                print("   response curve y sd:", ysd)

        return data


    #-----------------------------------------------------------------------
    def _check_cal(self, start_cal, df, labels):
        """ Check that response cal is valid.  It must use same reference gas,
        be the same instrument as at the time of the sample.
        """

        nstds = len(labels)
        if (start_cal >= 0 and start_cal + nstds - 1 <= df.index[-1]):

            for i in range(nstds):
#                print(labels[i], df.loc[start_cal+i].label, df.loc[start_cal+i].flag)
                if df.loc[start_cal+i].flag not in ['.', '*']: return False
                if df.loc[start_cal+i].label != labels[i]: return False

            return True

        return False
