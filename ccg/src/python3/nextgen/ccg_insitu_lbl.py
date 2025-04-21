
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data from wgc lbl system

# returns results in a pandas DataFrame
"""

import sys
import datetime
import numpy
from scipy import interpolate

import pandas as pd

import ccg_utils
import ccg_insitu_utils
import ccg_insitu_config

SQRT2 = 1.4142136

#pd.set_option("display.max_rows", None)



##################################################################
class lbl:
    """ Class for calculations involving insitu systems using an automatic
        response curve calibration (mole fraction vs difference from reference).
        All data comes from the raw files, passed in by the 'raw' class object.

        Args:
            required
                stacode : three letter station code, e.g. 'MLO'
                gas : gas to use, e.g. 'CO2'
                raw : pandas DataFrame of raw.data
                system : system name, e.g. 'ndir' or 'lcr'
                refgas : ccg_refgasdb class object
            optional
                smptype : Type of sample to use.  Either 'SMP', or 'TGT'
                debug : show extra debugging information if True

        Returns:
            results - pandas DataFrame
    """

    def __init__(self, stacode, gas, raw, system, refgas, smptype="SMP", debug=False):
        """ Class for calculations involving insitu systems using auto response curve cals.  """

        # REQUIRED
        # create a namedtuple object for storing results
        self.Result = ccg_insitu_utils.resultTuple()

        self.stacode = stacode
        self.raw = raw
        self.refgas = refgas
        self.sample_type = smptype
        self.debug = debug
        self.use_subtract = True
        self.std_labels = []
        self.fit = 2
        self.input_data = []  # hold input x, y values for response curve cal
        self.results = []
        self.coeffs = {}
        self.cal_time_diff = 0
        self.gas = gas

        startdate = self.raw.date.iloc[0]
        enddate = self.raw.date.iloc[-1]

        # get config here
        self.config = ccg_insitu_config.InsituConfig(self.stacode, gas, system)

        self.reference = self.config.get('reference', startdate)

        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, system, self.reference, self.refgas, startdate, enddate, self.config)

#        print("tank history ---------------")
#        for row in self.refgas.tank_history: print(row)
        if self.debug:
            print("caldates -------------")
            print(self.caldates)
            print("-------------")
#        sys.exit()


    #--------------------------------------------------------------------------
    def compute(self):
        """ Calculate mole fractions for samples using automatic response curve.

        Returns:
            results - pandas DataFrame
        """

        # We might need to break raw into different sections if the reference gas or instrument changes.
        # For each section, create a subset of raw for just that date interval,
        # then interpolate the reference gas at each sample date
        nsections = len(self.caldates) - 1
        for j in range(nsections):
            sdate = self.caldates[j]
            edate = self.caldates[j+1]
            df = self.raw[(self.raw.date >= sdate) & (self.raw.date < edate)].copy()
#            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", sdate, self.reference)
#            continue

            # set configuration values for this block
#            self.use_subtract = self.config.getboolean('use_subtract', sdate)
            self.std_labels = self.config.get('stds', sdate).split()
#            self.reference = self.config.get('reference', sdate)
            self.fit = self.config.getint('fit', sdate)
            self.cal_time_diff = self.config.getint('cal_time_diff', sdate, default=2)
            self.cal_time_diff = datetime.timedelta(days=self.cal_time_diff)

            # interpolate reference values at every sample point, and add them to the dataframe
            ref_vals, ref_unc, ref_flags = self._interp(df)
#            df['reference'] = ref_vals
            df['ref_unc'] = ref_unc
#            df['ref_flag'] = ref_flags
            df['ref_flag'] = 0
            df['reference'] = 1
#            df['ref_unc'] = 0.05

            # get baseline uncertainty in analyzer units
#            bu = ccg_insitu_utils.baseline_unc(df, self.reference)
#            df['baseline_unc'] = bu
            df['baseline_unc'] = 0

#            print(df)
#            sys.exit()

            # find cals here using interpolated values and dataframe for this block
            # return a dict with odr fit and rsd with date as key
            coeffs = self._find_cals(df)
            self.coeffs.update(coeffs)  # save for later
            if self.debug:
                print("cal coefficients")
                for c in self.coeffs:
                    print(self.coeffs[c][0].beta)

#            continue
            df2 = df[(df.smptype == self.sample_type)]
#            print(df2)
#            sys.exit()

            for row in df2.itertuples():

                resp = self._get_response(row.date, sdate, edate)
#                print(row)
#                print(row.date)
#                print(resp)

                mf, std, meas_unc, random_unc, flag = ccg_insitu_utils.calc_mf(row, resp, self.use_subtract, self.fit, self.debug)

                if self.debug:
                    print(row)
                    print("reference is", row.reference, "diff from ref is", row.value - row.reference)
                    print("mf, stdv, meas_unc", mf, std, meas_unc)

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

#        sys.exit()

        self.results = pd.DataFrame(self.results)
        self.results.fillna(-999.99, inplace=True)

        return self.results


    #--------------------------------------------------------------------------
    def _get_response(self, date, startdate, enddate):
        """ return the response coefficients and covariance for the given date.

        The coefficients will be averaged from
        the odr fits to the previous and next cals on the given date.

        The coefficients are held in the self.coeffs dict, keyed by date.

        Use only cals that fall between startdate, enddate

        AVERAGED COEFFICIENTS
        """

        prev_cal_date = self._get_prev_cal(date, startdate)
        next_cal_date = self._get_next_cal(date, enddate)

#        print(date, prev_cal_date, next_cal_date)

        # self.coeffs is list of tuples, (odr fit, rsd)
        if prev_cal_date is not None and next_cal_date is not None:
            fit_prev = self.coeffs[prev_cal_date][0]
            fit_next = self.coeffs[next_cal_date][0]

#            tdiff = (next_cal_date - prev_cal_date).total_seconds()
#            smp_tdiff = (date - prev_cal_date).total_seconds()

            # we're going to drift correct the fit coefficients for this date
#            drift = (fit_next.beta - fit_prev.beta) / tdiff
#            coeffs = fit_prev.beta + drift * smp_tdiff
            coeffs = (fit_prev.beta + fit_next.beta) / 2.0

#            drift = (fit_next.cov_beta - fit_prev.cov_beta) / tdiff
#            covar = fit_prev.cov_beta + drift * smp_tdiff
            covar = (fit_prev.cov_beta + fit_next.cov_beta) / 2.0

#            drift = (self.coeffs[next_cal_date][1] - self.coeffs[prev_cal_date][1]) / tdiff
#            rsd = self.coeffs[prev_cal_date][1] + drift * smp_tdiff
            rsd = (self.coeffs[prev_cal_date][1] + self.coeffs[next_cal_date][1]) / 2.0
            flag = "..."

        elif prev_cal_date is not None:
            fit = self.coeffs[prev_cal_date][0]
            coeffs = fit.beta
            covar = fit.cov_beta # * fit.res_var
            rsd = self.coeffs[prev_cal_date][1]
            flag = "..<"

        elif next_cal_date is not None:
            fit = self.coeffs[next_cal_date][0]
            coeffs = fit.beta
            covar = fit.cov_beta # * fit.res_var
            rsd = self.coeffs[next_cal_date][1]
            flag = "..>"

        else:
            coeffs = [0.0, 0.0, 0.0]
            covar = numpy.zeros((self.fit+1, self.fit+1))
            rsd = 0
            flag = "C.."

        if self.debug:
            print("\ndate, prev_cal_date, next_cal_date:", date, prev_cal_date, next_cal_date)
            print("coeffs", coeffs)
            print("covar", covar)
            print("flag", flag)
            print("rsd", rsd)

        if self.use_subtract:
            ref_op = "subtract"
        else:
            ref_op = "divide"

        ref_op = None

        # mimic structure from responseDb class
        resp = {'coeffs': coeffs, 'flag': flag, 'covar': covar, 'rsd': rsd, 'ref_op': ref_op}

        return resp


    #--------------------------------------------------------------------------
    def _get_prev_cal(self, date, sdate):
        """ to find previous cal, go backwards until the cal date is
         less than the given date

        Check time difference from last cal. It must be less than some limit to use it.
        """

        for cal_date in sorted(self.coeffs, reverse=True):
            if sdate <= cal_date <= date:
                if (date - cal_date) < self.cal_time_diff:
                    return cal_date

        return None

    #--------------------------------------------------------------------------
    def _get_next_cal(self, date, edate):
        """ to find next cal, go forwards until the cal date is
         greater than the given date

        Check time difference from next cal. It must be less than some limit to use it.
        """

        for cal_date in sorted(self.coeffs):
            if date <= cal_date <= edate:
                if (cal_date - date) < self.cal_time_diff:
                    return cal_date

        return None

    #--------------------------------------------------------------------------
    def _find_cals(self, df):
        """ Find the response curve cals.

        Args:
            df :  Dataframe with raw data for a block of time, and includes a
                column with drift corrected reference values.

        Find each R0-S1-S2-S3-S4-R0 cal then calculate the Std-Ref difference
        and compute polynomial response, mole fraction vs std-ref difference
        using odr with x axis weighting with std-ref uncertainty, and
        y axis weighting with uncertainty of the assigned mole fraction value of std.

        If a cal curve has multiple cycles, use only the last one.

        Keep only valid calibrations.
        """

        date1 = datetime.datetime(2023, 3, 27)


        data = {}

        # find all rows that have the first standard
        df2 = df[df.label == self.std_labels[0]]
        if self.debug:
            print("first standard data")
            print(df2)

        for row in df2.itertuples():
#            if self.reference in self.std_labels:  # for towers, where ref == a std
#                nextidx = row.Index + len(self.std_labels)  # index of next std_label[0] for next cycle
#            else:
#                nextidx = row.Index + len(self.std_labels) + 1  # index of next std_label[0] for next cycle

            # skip initial cycles, we want only last one,
            # which is when the index of the next cycle doesn't exist
            # so if it does exist, skip it
#            if nextidx in df2.index: continue

            valid = self._check_cal(row.Index, df, self.std_labels)
            if not valid: continue

            if self.gas.lower() == "co2":
                if row.date < date1:
                    caltanks = {"S1": 405.24, "S2": 531.18}
                else:
                    caltanks = {"S1": 385.08, "S2": 531.18}
            elif self.gas.lower() == "ch4":
                if row.date < date1:
                    caltanks = {"S1": 1926.8, "S2": 4388.0}
                else:
                    caltanks = {"S1": 1851.0, "S2": 4388.0}

            # get drift corrected assigned values for tank at this date
            y = []
            ysd = []
            for label in self.std_labels:
                value = caltanks[label]
#                tank = self.refgas.getRefgasByLabel(label, row.date)
#                y.append(tank.value)
                y.append(value)
                ysd.append(0.03)   # ysd.append(tank.unc)

            # get ratios/differences for cal
#            x, xsd = self._get_cal_diffs(row.Index, df, self.std_labels)
            x = df.loc[row.Index:row.Index+1].value.tolist()
            xsd = df.loc[row.Index:row.Index+1].stdv.tolist()


            # skip if all x's are 0
            if numpy.all(numpy.array(x) == 0):
                continue

            # check if any xsd==0, replace it with avg std
            # can't have weights = 0, odr won't work
            if 0 in xsd:
                a = [z for z in xsd if z != 0]  # make list without 0
                if len(a) > 0:
                    avgstd = numpy.mean(a)      # get average xsd
                    zidx = xsd.index(0)
                    xsd[zidx] = avgstd          # replace 0 with avg xsd
                else:
                    xsd = [0.001 * v for v in x] # make xsd 0.1% of value


            self.input_data.append((x, y, xsd, ysd))

#            print(x)
#            print(y)
#            print(xsd)
#            print(ysd)
            fit, rsd = ccg_utils.odr_fit(self.fit, x, y, xsd, ysd, self.debug)

            # don't use poorly constrained fit
            has_nan = numpy.isnan(fit.beta).any()
            if has_nan: 
                if self.debug:
                    print("*** Bad cal curve for", row.date, " Discarding.")
                continue

            data[row.date] = (fit, rsd)
            if self.debug:
                print("calibration curve for date:", row.date)
                print("   response curve x:", x)
                print("   response curve x sd:", xsd)
                print("   response curve y:", y)
                print("   response curve y sd:", ysd)
                print("   coefficients:", fit.beta)
                print("   rsd:", rsd)


        return data

    #-----------------------------------------------------------------------
    def _check_cal(self, start_cal, df, std_labels):
        """ Check that response cal is valid.  Sequence of gases must match
        the std_labels sequence, and be unflagged.

        Args:
            start_cal : row index of first standard in cal
            df : dataframe of raw data
            std_labels : list of labels for standards (e.g. C1, C2 ...)
        """

        # make sure we have all s1,s2 measurements with good flags

        labels = std_labels

        nstds = len(labels)
        if (start_cal >= 0 and start_cal + nstds - 1 <= df.index[-1]):

            for i in range(nstds):
                if df.loc[start_cal+i].flag != '.': return False
                if df.loc[start_cal+i].label != labels[i]: return False

            return True

        return False

    #-----------------------------------------------------------------------
    def _get_cal_diffs(self, start_cal, df, std_labels):
        """ For the response cal starting at index start_cal in the raw list,
        calculate the std-ref difference and return this value for each standard.
        Note: make sure you call _check_cal() and see if data is valid before
        calling this routine.  Doesn't do any checks for validity.
        """

        nstds = len(std_labels)

        std_values = df.loc[start_cal:start_cal+nstds-1].value
        ref_values = df.loc[start_cal:start_cal+nstds-1].reference
        sig_values = df.loc[start_cal:start_cal+nstds-1].stdv
        ref_sig_values = df.loc[start_cal:start_cal+nstds-1].ref_unc

        # calculate difference from drift corrected R0 for each std.
        r = (std_values - ref_values).tolist()
        sigma = numpy.sqrt(sig_values**2 + ref_sig_values**2).tolist()

        if self.debug:
            print("Startcal", start_cal)
            print("Std values\n", std_values)
            print("ref values\n", ref_values)
            print("Stdv values\n", sig_values)
            print("ref_Stdv values\n", ref_sig_values)
            print("Diffs", r)
            print("Sigmas", sigma)

        return r, sigma


    #--------------------------------------------------------------------------
    def _interp(self, raw):
        """ get interpolated values for the reference tank

        Input
            raw - pandas dataframe with a subset of the raw data

        Returns:
            refvals - interpolated values of the reference at all sample times
            refsigs - interpolated uncertainties for the reference at all sample times

        Computes a drift corrected value, and std. dev for the reference tank
        at the time of every sample.
        """

        # get times for all samples
        times2 = numpy.array([t.timestamp() for t in raw.date])

        # find all unflagged reference (R0) values
        df = raw[(raw.label == self.reference) & (raw.flag == ".")]
        if self.debug:
            print("in interp, references (", self.reference, ") df:")
            print(df)

        # if no valid references, return default values
        if len(df) == 0:
#            print(len(raw))
            refvals = [-999.99] * len(raw)
            refsigs = [-99.99] * len(raw)
            refflags = [1] * len(raw)
            return refvals, refsigs, refflags

        max_diff_resp = 2 * 24 * 60 * 60   # two days in seconds
#        max_diff_resp = 4 * 60 * 60   # two days in seconds
        refflags = numpy.zeros(len(times2))
        refdates = numpy.array([t.timestamp() for t in df['date']])

        if len(df) == 1:
            print("Warning: Only one reference available for time span. Drift correction not possible.")
            refvals = [df.value.values[0] for t in times2]
            refsigs = [df.stdv.values[0] for t in times2]

        else:
            # convert dates to epoch time in seconds
            times = numpy.array([t.timestamp() for t in df.date])

            # set up interpolation for reference
            f = interpolate.interp1d(times, df.value.values, bounds_error=False, fill_value='extrapolate')

            # get interpolated values of the reference at all sample times
            refvals = f(times2)
            for i, tt in enumerate(times2):
                idx  = ccg_insitu_utils.find_nearest(refdates, tt)
                if abs(tt - refdates[idx]) > max_diff_resp:
                    refflags[i] = 1

            # compute uncertainty of the reference values
            # this will just be the interpolated standard deviations of each reference measurement
            fsig = interpolate.interp1d(times, df.stdv.values, bounds_error=False, fill_value='extrapolate')
            refsigs = fsig(times2) * SQRT2

        return refvals, refsigs, refflags

    #--------------------------------------------------------------------------
    def printTable(self):
        """ print results in nice format """

        print("   Date      Time            R0              Response Coeff         Mixing Ratio   Flag")
        print("---------------------------------------------------------------------------------------")

        for row in self.results.itertuples():
            print(" %s " % (row.date.strftime("%Y-%m-%d %H:%M")), end='')
            for tank in self.std_labels:
                ser, conc, unc = self.refgas.getRefgasByLabel(tank, row.date)
                print(" %10s %6.2f" % (ser, conc), end='')
            print(" %10.2f %6.2f %5s" % (row.mf, row.stdv, row.flag))

