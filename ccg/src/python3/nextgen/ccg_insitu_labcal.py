
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data
# using laser based system such as lgr or pic and response
# curves determined in lab and stored in response database table

# returns results in a pandas DataFrame
"""

import sys
import datetime
import numpy

import pandas as pd

import ccg_response
import ccg_insitu_utils
import ccg_insitu_config
import ccg_utils
import ccg_instrument

SQRT2 = 1.4142136

##################################################################
class response:
    """ Class for calculations involving insitu systems using lab cal
    response curves, e.g. mko picarro

    The computation uses pre-determined response curves for the analyzer over
    a period of time, that are set in the reftank.response database table.
    The response curve coefficients determine the mole fraction directly
    from the analyzer output value, i.e. a reference tank is not used.

    For undried measurements, a water correction is used to get the dry
    value of the analyzer output.  The water correction occurs in the step
    where data is unpacked after being copied from the site to Boulder, and
    data files and raw files are created.
    See /ccg/incoming/mko/read_picarro.py

    Usage:
       isdata = ccg_insitu_response.response(stacode, gas, raw, system, refgas,
            smptype='SMP', debug=False)

    Arguments:
       required
         stacode : station letter code, e.g. 'mlo'
         gas : gas formula, e.g. 'co2'
         raw : raw class object containg the raw data
         system : system name, e.g. 'pic' or 'lgr'
         refgas : refgasdb object with reference gas information  !! not used
       optional
         smptype : Sample type to process.  Either 'SMP' or 'TGT'
         debug : Print out debugging information
    """

    def __init__(self, stacode, gas, raw, system, refgas, smptype="SMP", debug=False):


        # REQUIRED
        # create a namedtuple object for storing results
        self.Result = ccg_insitu_utils.resultTuple()

        self.stacode = stacode
        self.gas = gas
        self.raw = raw
        self.refgas = refgas
        self.sample_type = smptype
        self.debug = debug
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
            # for labcals, if no response curve for site, try one for 'BLD'
            self.resp = ccg_response.ResponseDb(gas, site='BLD', debug=debug)
            if not self.resp.data:
                sys.exit("No response curve data available.")

        # determine when reference tank or instrument changes
        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, system, self.reference, self.refgas, startdate, enddate)

        self.inst = ccg_instrument.instrument(self.stacode, self.gas, system)

    #-------------------------------------------------------------------------
    def compute(self):
        """ Compute the mole fraction values for sample using manual response curves stored in db.

        Returns:
            results - pandas DataFrame
        """

        # We might need to break raw into different sections if the reference gas or instrument changes.
        # For each section, create a subset of raw for just that date interval.
        nsections = len(self.caldates) - 1
        for j in range(nsections):
            sdate = self.caldates[j]
            edate = self.caldates[j+1]

            # get a dataframe for just this section
            df = self.raw[(self.raw.date >= sdate) & (self.raw.date < edate)].copy()

            # set configuration values for this block

            t0 = datetime.datetime.now()

            # get baseline uncertainty in analyzer units
            bu = 0
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
                # need to get instrument id because response curves may be set for BLD
                inst_id = self.inst.getInstrumentId(row.date)
                resp = self.resp.findResponse(row.date, inst_id)
                self.coeffs[resp['analysis_date']] = (resp['coeffs'], resp['rsd'])
                if self.debug:
                    print("Response curve coefs:", resp['coeffs'])
                if resp is None:
                    print("No response curve for", row.date)
                    continue

                # for ch4 and co,
                # response curve coefficients are in ppb. Make sure analyzer output is also in ppb
                if self.gas.lower() in ["ch4", "co"] and row.value < 5:
                    value = row.value * 1000
                    stdv = row.stdv * 1000
                else:
                    value = row.value
                    stdv = row.stdv

                mf, rr, meas_unc = self.resp.getResponseValue(value, None, resp)

                # convert sigmas in analyzer units to mole fractions
                s = ccg_utils.polyderiv(value, resp['coeffs'])
                std = s * stdv

#                meas_unc = 0
#                std = 0
                random_unc = 0
                flag = "..."
#                mf, std, meas_unc, random_unc, flag = ccg_insitu_utils.calc_mf(row, resp, self.use_subtract, self.fit, self.debug)

                if self.debug:
                    print(row)
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

        format3 = " %s %25.4f %8.4f %8.4f %10.2f %6.2f %5s"
        print("   Date      Time                            Response Coeff         Mixing Ratio   Flag")
        print("---------------------------------------------------------------------------------------")

        for row in self.results.itertuples():
            (sernum, conc, unc) = self.refgas.getRefgasByLabel("R0", row.date, showWarn=False)
            coef = self.resp.getResponseCoef(row.date)
            print(format3 % (
                row.date.strftime("%Y-%m-%d %H:%M"),
#                sernum,
#                conc,
                coef[0],
                coef[1],
                coef[2],
                row.mf,
                row.stdv,
                row.flag
            ))
