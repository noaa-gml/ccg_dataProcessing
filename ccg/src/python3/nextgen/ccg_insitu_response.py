
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data
# using laser based system such as lgr or pic and manual response
# curves stored in response database table

# returns results in a pandas DataFrame
"""

import sys
import datetime
import numpy
from scipy import interpolate

import pandas as pd

import ccg_response
import ccg_insitu_utils
import ccg_insitu_config
#import ccg_instrument

SQRT2 = 1.4142136

##################################################################
class response:
    """ Class for calculations involving insitu systems using manually run
    response curves, e.g. mlo picarro and brw lgr

    The computation uses pre-determined response curves for the analyzer over
    a period of time, that are set in the reftank.response database table.

    Usage:
       isdata = ccg_insitu_response.response(stacode, gas, raw, system, refgas,
            smptype='SMP', debug=False)

    Arguments:
       required
         stacode : station letter code, e.g. 'mlo'
         gas : gas formula, e.g. 'co2'
         raw : raw class object containg the raw data
         system : system name, e.g. 'pic' or 'lgr'
         refgas : refgasdb object with reference gas information
       optional
         smptype : Sample type to process.  Either 'SMP' or 'TGT'
         debug : Print out debugging information
    """

    def __init__(self, stacode, gas, raw, system, refgas, smptype="SMP", debug=False):


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
        self.results = []
        self.coeffs = {}

        startdate = self.raw.date.iloc[0]
        enddate = self.raw.date.iloc[-1]

        # get config here
        self.config = ccg_insitu_config.InsituConfig(self.stacode, gas, system)

        self.reference = self.config.get('reference', startdate)

        # get response curves for all instruments
        self.resp = ccg_response.ResponseDb(gas, site=stacode, debug=debug)
        if not self.resp.data:
            sys.exit("No response curve data available.")

        # determine when reference tank or instrument changes
        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, system, self.reference, self.refgas, startdate, enddate)
#        print(self.caldates)


    #-------------------------------------------------------------------------
    def compute(self):
        """ Compute the mole fraction values for sample using manual response curves stored in db.

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

            # get a dataframe for just this section
            df = self.raw[(self.raw.date >= sdate) & (self.raw.date < edate)].copy()

            # find dates of reference tank measurements
            dates = df[df.label == self.reference].date
            firstrefdate = dates.iloc[0]
            lastrefdate = dates.iloc[-1]

            # set configuration values for this block
            self.use_subtract = self.config.getboolean('use_subtract', sdate)
            self.std_labels = self.config.get('stds', sdate).split()
            self.reference = self.config.get('reference', sdate)
            self.fit = self.config.getint('fit', sdate)

            # interpolate reference values at every sample point, and add them to the dataframe
            ref_vals, ref_unc, ref_flag = self._interp(df)
            df['reference'] = ref_vals
            df['ref_unc'] = ref_unc
            df['ref_flag'] = ref_flag

            t0 = datetime.datetime.now()

            # get baseline uncertainty in analyzer units
            bu = ccg_insitu_utils.baseline_unc(df, self.reference)
#            print(bu.max())
            df['baseline_unc'] = bu

#            t1 = datetime.datetime.now()
#            print("baselineunc", t1-t0)

            # filter dataframe for samples only and compute mole fractions
            df2 = df[(df.smptype == self.sample_type)]
#            print(df2)

#            t0 = datetime.datetime.now()
            for row in df2.itertuples():

                if self.debug:
                    print("\nSample data:", row.smptype, row.label, row.date, row.value, row.stdv, row.n, row.flag, row.mode)

                # find the response curve for this date, save for later use in ccg_insitu.py
                resp = self.resp.findResponse(row.date)
                self.coeffs[resp['analysis_date']] = (resp['coeffs'], resp['rsd'])
                if resp is None:
                    print("No response curve for", row.date)
                    continue
                if self.debug:
                    print("Response coefs are:", resp['coeffs'])

#                mr, rr, unc = self.resp.getResponseValue(row.value, row.reference, resp)
                mf, std, meas_unc, random_unc, flag = ccg_insitu_utils.calc_mf(row, resp, self.use_subtract, self.fit, self.debug)

                # flag any samples that are before the first reference
                # or after the last reference with '<' and '>' flags
                # to show that bracketing references weren't available
                if row.date < firstrefdate: flag = flag[0:2] + ">"
                if row.date > lastrefdate: flag = flag[0:2] + "<"

                if self.debug:
                    print(row)
                    print("reference is", row.reference, "diff from ref is", row.value - row.reference)
                    print("mf, stdv, meas_unc, random_unc", mf, std, meas_unc, random_unc)

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

                self.results.append(t)

#            t1 = datetime.datetime.now()
#            print("time to compute", t1-t0)

#        sys.exit()

        self.results = pd.DataFrame(self.results)

        return self.results


    #--------------------------------------------------------------------------
    def printTable(self):
        """ print results in nice format """

        format3 = " %s  %10s %6.2f %8.4f %8.4f %8.4f %10.2f %6.2f %5s"
        print("   Date      Time            R0              Response Coeff         Mixing Ratio   Flag")
        print("---------------------------------------------------------------------------------------")

        for row in self.results.itertuples():
            (sernum, conc, unc) = self.refgas.getRefgasByLabel("R0", row.date, showWarn=False)
            coef = self.resp.getResponseCoef(row.date)
            print(format3 % (
                row.date.strftime("%Y-%m-%d %H:%M"),
                sernum,
                conc,
                coef[0],
                coef[1],
                coef[2],
                row.mf,
                row.stdv,
                row.flag
            ))


    #--------------------------------------------------------------------------
    def _interp(self, raw):
        """ get interpolated values for the reference tank

        Interpolated values are an average of the previous value and the next value,
        NOT a linear interpolation.

        Input
            raw - pandas dataframe with a subset of the raw data

        Returns:
            refvals - interpolated values of the reference at all sample times
            refsigs - interpolated uncertainties for the reference at all sample times
        """

        # get times for all samples
        times2 = numpy.array([t.timestamp() for t in raw.date])

        # find all reference (R0) values
        df = raw[(raw.label == self.reference) & (raw.flag == ".")]
        if self.debug:
            print("in interp, references df:")
            print(df)

#        max_diff_resp = 4 * 60 * 60   # four hours in seconds
        max_diff_resp = self.config.getint("max_diff_resp", raw.iloc[0].date, None)
        refflags = numpy.zeros(len(times2))
        refdates = numpy.array([t.timestamp() for t in df['date']])

        values = df.value.values
        sigmarefs = df.stdv.values

        if len(df) == 0:
            print("Warning: No valid references available for time span.")
            refvals = [0 for t in times2]
            refsigs = [0 for t in times2]
            
        elif len(df) == 1:
            print("Warning: Only one reference available for time span. Drift correction not possible.")
            refvals = [values[0] for t in times2]
            refsigs = [sigmarefs[0] for t in times2]
#            f = lambda x: [refvals[0] for t in x] # make dummy function

        else:
            # convert dates of references to epoch time in seconds
            times = numpy.array([t.timestamp() for t in df.date])

            # set up interpolation for previous reference
            f = interpolate.interp1d(times, values, kind='previous', bounds_error=False, fill_value='extrapolate')

            # get interpolated values of the previous reference at all sample times
            refvals_p = f(times2)

            # set up interpolation for next reference
            f = interpolate.interp1d(times, values, kind='next', bounds_error=False, fill_value='extrapolate')

            # get interpolated values of the next reference at all sample times
            refvals_n = f(times2)



            # average the interpolated values so we're using the
            # average of the previous and next references
            refvals = (refvals_p + refvals_n)/2.0

# skip response time diff - kwt 
            if max_diff_resp is not None:
                max_diff_resp = max_diff_resp * 3600
                for i, tt in enumerate(times2):
                    idx  = ccg_insitu_utils.find_nearest(refdates, tt)
                    if abs(tt - refdates[idx]) > max_diff_resp:
                        refflags[i] = 1

            # compute uncertainty of the reference values
            # this will just be the interpolated standard deviations of each reference measurement
            fsig = interpolate.interp1d(times, sigmarefs, kind='previous', bounds_error=False, fill_value=(sigmarefs[0], sigmarefs[-1]))
            refsigs = fsig(times2) * SQRT2

        return refvals, refsigs, refflags
