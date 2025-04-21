
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data
# for tower sites.
#
# this version is for interpolating the cal values at each sample
# time, and computing response at each sample time
#
"""

import sys
import datetime
import math
import numpy
from scipy import interpolate
from scipy.odr import odrpack as odr
from scipy.odr import models
import pandas as pd
from numpy.polynomial import Polynomial as Poly

import ccg_instrument
import ccg_utils
import ccg_insitu_utils
import ccg_insitu_config

DEFAULTVAL = -999.99
SQRT2 = 1.4142136

#pd.set_option("display.max_rows", None)

##################################################################
class tower:
    """ Class for calculations involving tower insitu systems using NDIR/Laser.
    All data comes from the raw files, passed in by the 'raw' class object.

    Arguments
        required
            stacode : three letter station code, BRW, MLO, SMO, SPO
            gas : gas of interest, e.g. 'co2', 'ch4' ...
            raw : pandas DataFrame of raw data
            refgas : ccg_refgasdb class object
        optional
            smptype : Sample type to use, either 'SMP' or 'TGT"
            debug : show extra debugging information if True

    Returns:
        results - pandas DataFrame of computed results
    """


    def __init__(self, stacode, gas, raw, system, refgas, smptype="SMP", debug=False):

        self.stacode = stacode.upper()
        self.gas = gas.upper()
        self.raw = raw
        self.refgas = refgas
        self.debug = debug
        self.sample_type = smptype
        self.system = system
        self.results = None
        self.coeffs = {}
        self.input_data = []

        # REQUIRED
        # create a namedtuple object for storing results
        self.Result = ccg_insitu_utils.resultTuple()
#        self.Result = namedtuple('result', ['stacode', 'date', 'mf', 'stdv', 'unc', 'random_unc', 'n', 'flag', 'sample', 'comment'])

        self.inst = ccg_instrument.instrument(self.stacode, self.gas, self.system)

        startdate = self.raw.date.iloc[0].to_pydatetime()
        enddate = self.raw.date.iloc[-1].to_pydatetime()


        # get things from config file
        self.config = ccg_insitu_config.InsituConfig(self.stacode, self.gas, self.system)
        self.use_subtract = self.config.getboolean('use_subtract', startdate)
        self.std_labels = self.config.get('stds', startdate).split()
        self.reference = self.config.get('reference', startdate)
        self.fit = self.config.getint('fit', startdate)

#        for r in self.refgas.refgas: print(r)

#        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, system, self.reference, self.refgas, startdate, enddate, self.config)
#        print("caldates are", self.caldates)
#        sys.exit()


        # determine when cal tanks change
        self.caldates = [startdate]
        for label in self.std_labels:
            rows = self.refgas.getEntries(label)
#            print(label, rows)
            if len(rows) > 0:
                for r in rows:
                    if startdate < r.start_date < enddate:
                        self.caldates.append(r.start_date)

        # add a day to end date so we can use < in compute()
        edate = enddate + datetime.timedelta(days=1)
        self.caldates.append(edate)
        self.caldates = list(set(self.caldates))  # get unique set in case more than 1 tank changed at same time
        self.caldates.sort()
#        print("caldates are", self.caldates)
#        sys.exit()

    #--------------------------------------------------------------------------
    def compute(self):
        """ calculate the mole fraction values """

        t0 = datetime.datetime.now()
        results = []

        # We might need to break raw into different sections if the cals gases or instrument change.
        # For each section, create a subset of raw for just that date interval,
        # then interpolate the cal gases at each sample date
        nsections = len(self.caldates) - 1
        for j in range(nsections):
            sdate = self.caldates[j]
            edate = self.caldates[j+1]
            df = self.raw[(self.raw.date >= sdate) & (self.raw.date < edate)].copy()

            # interpolate the reference tank measurements, and include them in the dataframe
            ref_vals, ref_unc, interp_vals, interp_stdvs = self._interp(df)
            if ref_vals is None: continue
            df['reference'] = ref_vals
            df['ref_unc'] = ref_unc
            df['ref_flag'] = numpy.zeros(len(ref_vals))
            for key in interp_vals:
                df[key] = interp_vals[key]
                unckey = key + "_unc"
                df[unckey] = interp_stdvs[key]

            # get baseline uncertainty in analyzer units
            bu = self.baseline_unc(df)
            df['baseline_unc'] = bu
            

#            print(df)
#            continue
#            sys.exit()

            # iterate over the samples and calculate mole fractions
            df2 = df[df.smptype == self.sample_type]
            for row in df2.itertuples():

                if self.debug:
                    print("\nSample data:", row.smptype, row.label, row.date, row.value, row.stdv, row.n, row.flag, row.mode)

                if row.flag != ".":
                    mf = DEFAULTVAL
                    std = DEFAULTVAL
                    meas_unc = DEFAULTVAL
                    random_unc = DEFAULTVAL
                    flag = row.flag + ".."
                else:
                    resp = self._get_response(row)
#                    print(resp)
                    mf, std, meas_unc, random_unc, flag = ccg_insitu_utils.calc_mf(row, resp, self.use_subtract, self.fit, self.debug)

#                    meas_unc = math.sqrt(meas_unc*meas_unc + base_unc*base_unc)

                if self.debug:
                    print("mf, standard deviation, meas_unc, random_unc", mf, std, meas_unc, random_unc)


                # save results
                t = (
                    self.stacode,
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
                results.append(t)

#        sys.exit()

        # find dates of reference tank
        # flag any samples that are before the first reference
        # or after the last reference with '<' and '>' flags
        # to show that bracketing references weren't available
        df = self.raw[self.raw.label == self.reference]
        dates = df.date
        firstrefdate = dates.iloc[0]
        lastrefdate = dates.iloc[-1]

        df = pd.DataFrame(results)
        df.loc[(df.date < firstrefdate) & (df.flag == '...'), 'flag'] = "..>"
        df.loc[(df.date > lastrefdate) & (df.flag == '...'), 'flag'] = "..<"

        t1 = datetime.datetime.now()
#        print(t1-t0)

        self.results = df
#        print(self.results)
#        sys.exit()

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
                print ("    Mole Fraction   Flag")
                header = False

            print("%s " % row.date.strftime("%Y-%m-%d %H:%M"), end="")
            for label in std_labels:
                tank = self.refgas.getRefgasByLabel(label, row.date)
                print(" %10s %6.2f" % (tank.serial_num, tank.value), end="")

            print("%10.2f %6.2f %5s" % (row.mf, row.stdv, row.flag))


    #--------------------------------------------------------------------------
    def _interp(self, raw):
        """ get interpolated values for the standards

        Input
            raw - pandas dataframe with a subset of the raw data

        Returns:
            refvals - interpolated values of the reference at all sample times
            refsigs - interpolated uncertainties for the reference at all sample times
            vals - dict with standard label as key.
                   Values are the interpolated differences from reference at all sample times

        Note that for towers there is no separate reference tank.  One of the standards is
        used as the reference (usually C2), so the C2 difference from the reference will be 0
        """

        # get times for all samples
        times2 = numpy.array([t.timestamp() for t in raw.date])

        # find all reference (C2) values
        df = raw[(raw.label == self.reference) & (raw.flag == ".") & (raw.value > -1e10)]
#        print(df)
        if self.debug:
            print("in interp, references df:")
            print(df)

        if len(df) == 0:
            print("Warning: No reference available for time span.")
            return None, None, None, None


        dates = df.date
        values = df.value.values
        sigmarefs = df.stdv.values
#        print(df)
        if len(df) == 1:
            print("Warning: Only one reference available for time span. Drift correction not possible.")
            refvals = [values[0] for t in times2]
            refsigs = [sigmarefs[0] for t in times2]
            f = lambda x: [refvals[0] for t in x] # make dummy function

        else:
            # convert dates to epoch time in seconds
            times = numpy.array([t.timestamp() for t in dates])
#            print(dates, times, values)
#            sys.exit()

            # set up interpolation for reference
            f = interpolate.interp1d(times, values, bounds_error=False, fill_value='extrapolate')

            # get interpolated values of the reference at all sample times
            refvals = f(times2)

            # compute uncertainty of the reference values
            # this will just be the interpolated standard deviations of each reference measurement
            fsig = interpolate.interp1d(times, sigmarefs, bounds_error=False, fill_value='extrapolate')
            refsigs = fsig(times2) #  * SQRT2


        # for each standard, find the standard output values, then
        # calculate the difference from the interpolated reference
        # Interpolate the differences to all sample times
        vals = {}
        sigs = {}
        for label in self.std_labels:
            df = raw[(raw.label == label) & (raw.flag == ".") & (raw.value > -1e10)]
            if self.debug:
                print("in interp, reference %s df:" % label)
                print(df)
            times = numpy.array([int(t.timestamp()) for t in df.date])
            diffs = df.value.values - f(times) # difference from c2 values at std times
            stdvs = df.stdv.values # stdv of standard values
#            print(label, times, df.value.values, f(times))

            if len(times) == 1:
                f2 = lambda x: [diffs[0] for t in x]
            else:
                f2 = interpolate.interp1d(times, diffs, bounds_error=False, fill_value='extrapolate')
                f3 = interpolate.interp1d(times, stdvs, kind='next', bounds_error=False, fill_value=(stdvs[0], stdvs[-1]))

            # save the interpolated differences for each std
            vals[label] = f2(times2)

            # uncertainty of std-ref value should include both std and ref sigmas
            sigs[label] = numpy.sqrt(f3(times2)**2 + refsigs**2)   * SQRT2 #to account for interpolation between two values?

#        sys.exit()

        return refvals, refsigs, vals, sigs

    #--------------------------------------------------------------------------
    def _get_response(self, row):
        """ Compute the response curve at the given date

        row is a namedtuple row from a pandas dataframe
        """

        x = []
        y = []
        xsd = []
        ysd = []
        for label in self.std_labels:
            tank = self.refgas.getRefgasByLabel(label, row.date)
            y.append(tank.value)
            x.append(getattr(row, label))   # if using namedtuples
            ysd.append(0.03)                # tank.unc once uncertainties are in scale_assignments
            xd = getattr(row, label+"_unc")
            if xd == 0:                     # odr can't handle weights of value 0
                xd = 0.03
            xsd.append(xd)

        if len(set(x)) != len(self.std_labels):
#            print(x, y, row)
 #           print("Warning: Not enough uniq values for response curve", file=sys.stderr)
#            sys.exit()
            return None

#        p = Poly.fit(x, y, self.fit)  # initial guess at coefficients
#        beta0 = p.convert().coef


        self.input_data.append((x, y, xsd, ysd))
        fit, rsd = ccg_utils.odr_fit(self.fit, x, y, xsd, ysd, self.debug)
        self.coeffs[row.date] = (fit, rsd)
#        fit.beta = beta0
#        print(row)
#        if row.date.day == 6 and row.date.hour==20:
#            print(row.date, x, y, fit.beta)
#        print(row.date, fit.beta, beta0)

        if self.debug:
#        if True:
            print("calibration curve for date:", row.date)
            print("   response curve x:", x)
            print("   response curve x sd:", xsd)
            print("   response curve y:", y)
            print("   response curve y sd:", ysd)
            print("   coefficients:", fit.beta)
            print("   rsd:", rsd)

        if self.use_subtract:
            ref_op = "subtract"
        else:
            ref_op = "divide"


        resp = {'coeffs': fit.beta, 'flag': '...', 'covar': fit.cov_beta, 'rsd': rsd, 'ref_op': ref_op}

        return resp
#        return fit, rsd

    #--------------------------------------------------------------------------
    def baseline_unc(self, raw):

        # get times for all samples
        t2 = numpy.array([t.timestamp() for t in raw.date])
        nt = len(t2) 
#        print("nt is", nt)

        # find all reference (C2) values
        df = raw[(raw.label == self.reference) & (raw.flag == ".") & (raw.value > -1e10)]
        y = df.value.values
        x = numpy.array([t.timestamp() for t in df.date])

        n = len(x)

        mref = numpy.empty((n, nt))
        base_unc = numpy.empty((nt))

        # create n interpolations by removing one reference in sequence
        # don't extrapolate, set to nan
        b = numpy.arange(0, n, 1)
        for i in range(n):
            w = numpy.where(b != i)
            f = interpolate.interp1d(x[w], y[w], bounds_error=False) # , fill_value='extrapolate')
            mref[i] = f(t2)

#        print(mref)
#        print(t2)

        # for each data point, get unique interpolation values,
        # then calculate the standard deviation of them.
        # scale the uncertainty according to the relative distance to other ref measurements
        for i in range(nt):
            # get non-nan values
            w = numpy.isfinite(mref.T[i])
            a = numpy.unique(mref.T[i][w])
            if len(a) > 1: 
                stddev = numpy.std(a, ddof=1)
            else:
                stddev = 0


            # time difference of this data point from all references,
            # in order of largest positive value to largest negative value
            dtime = t2[i] - x   

            # closest ref measurement in time
            closest = numpy.min(numpy.abs(dtime))

            # get smallest positive time difference
            w = numpy.where(dtime > 0)
            if w[0].size == 0:
                idx = 0
                distance = dtime[0]
            else:
                # index of smallest positive value
                iprev = numpy.argmax(w)
                inext = iprev + 1   # index of smallest negative value
                if inext < n:
                    distance = dtime[iprev] - dtime[inext]
                else:
                    distance = dtime[iprev]

#            print(i, stddev, closest, distance)

            # use a time limit, references must be within a time distance to be used
            if distance < 10080 and distance != 0 and not numpy.isnan(stddev):
                unc_ref_freq = stddev * 2.0 * abs(closest) / abs(distance)
            else:
                unc_ref_freq = 0

            # uncertainty lower limit is the measurement standard deviation
            ref_std = raw.ref_unc.iloc[i]
            if unc_ref_freq < ref_std:
                base_unc[i] = ref_std
            else:
                base_unc[i] = unc_ref_freq

        return base_unc
