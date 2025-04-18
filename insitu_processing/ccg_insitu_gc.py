
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data
# using GC system.
#
"""
import sys
import pandas as pd

import ccg_insitu_utils
import ccg_insitu_config
import amie

DEFAULTVAL = -999.99

class gc:
    """ Calculate mole fractions for CH4 GC single point calibrations. """

    def __init__(self, stacode, gas, raw, system, refgas, smptype="SMP", debug=False):

        # REQUIRED
        # create a namedtuple object for storing results
        self.Result = ccg_insitu_utils.resultTuple()

        self.stacode = stacode
        self.gas = gas.upper()
        self.raw = raw
        self.refgas = refgas
        self.sample_type = smptype
        self.debug = debug
        self.system = system

        self.results = []

        startdate = self.raw.date.iloc[0]
        enddate = self.raw.date.iloc[-1]

        # get config here
        self.config = ccg_insitu_config.InsituConfig(self.stacode, gas, self.system)
        self.reference = self.config.get('reference', startdate)

        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, self.system, self.reference, refgas, startdate, enddate)

#        print("caldates -------------")
#        print(self.caldates)
#        print("-------------")
#        sys.exit()


    #-------------------------------------------------------------------------
    def compute(self, use_amie=True):
        """ compute mole fractions"""

        # We might need to break raw into different sections if the reference gas or instrument changes.
        # For each section, create a subset of raw for just that date interval,
        # then interpolate the reference gas at each sample date
        nsections = len(self.caldates) - 1
        for j in range(nsections):
            sdate = self.caldates[j]
            edate = self.caldates[j+1]
            df = self.raw[(self.raw.date >= sdate) & (self.raw.date < edate)].copy()

            df2 = df[(df.smptype == self.sample_type)]
#            print(df2)
            for row in df2.itertuples():

                # We have a sample.
                mrh = DEFAULTVAL
                mra = DEFAULTVAL
                flag = "*.."
                r1valid = False
                r2valid = False

                bcodes = self.config.get('baseline_codes', row.date)
                if row.bc in bcodes:

                    # get previous reference
                    if row.Index - 1 >= 0:
                        r1valid = True
                        row1 = self.raw.loc[row.Index - 1]
 #                       print(row1)
                        if row1.bc not in bcodes or row1.flag != '.': r1valid = False
#                        if row1.smptype != "REF" or row1.label != self.reference: r1valid = False
                        if row1.smptype != "REF": r1valid = False

                    # get next reference
                    if row.Index+1 < len(self.raw):
                        r2valid = True
                        row2 = self.raw.loc[row.Index + 1]
#                        print(row2)
                        if row2.bc not in bcodes or row2.flag != '.': r2valid = False
#                        if row2.smptype != "REF" or row2.label != self.reference: r2valid = False
                        if row2.smptype != "REF": r2valid = False

                    tank = self.refgas.getRefgasByLabel(self.reference, row.date, showWarn=True)

                    if self.debug:
                        print("r1valid, r2valid", r1valid, r2valid)

                    # Check for case 1
                    if r1valid and r2valid:
                        mrh = (row.ph / ((row1.ph+row2.ph)/2.0)) * tank.value
                        mra = (row.pa / ((row1.pa+row2.pa)/2.0)) * tank.value
                        flag = "..."

                    # Check for case 3
                    elif r1valid:
                        mrh = (row.ph / (row1.ph)) * tank.value
                        mra = (row.pa / (row1.pa)) * tank.value
                        # Don't flag the last sample of the dataset if
                        # there isn't a following ref.
                        if row.Index+1 < len(self.raw):
                            flag = "..<"
                        else:
                            flag = "..."

                    # Check for case 4
                    elif r2valid:
                        mrh = (row.ph / (row2.ph)) * tank.value
                        mra = (row.pa / (row2.pa)) * tank.value
                        flag = "..>"

                    mrh = round(mrh, 2)
                    mra = round(mra, 2)

                    if mrh < 0: mrh = DEFAULTVAL
                    if mra < 0: mra = DEFAULTVAL

                peaktype = self.config.get('peaktype', row.date)
                val = mrh if peaktype == "height" else mra
                t = (
                    self.stacode.upper(),
                    row.date,
                    val,
                    -99.99,
                    -99.99,
                    -99.99,
                    1,
                    flag,
                    row.label,
                    row.comment
                )
                t = self.Result._make(t)
                self.results.append(t)

        # apply automated flags for GC systems
        if use_amie:
            amie.amie(self.stacode, self.config, self.raw, self.results)

        self.results = pd.DataFrame(self.results)
#        pd.set_option('display.max_rows', None)
#        print(self.results)
#        sys.exit()

        return self.results

    #-------------------------------------------------------------------------
    def printTable(self):
        """ print results in nice format """

        format1 = " %s  %10s %6.2f %10.2f %8s %4s"
        print("   Date      Time         Reference         M.F     Port  Flag")
        print("-------------------------------------------------------------")

        for row in self.results.itertuples():
            tank = self.refgas.getRefgasByLabel("S1", row.date)
            print(format1 % (row.date.strftime("%Y-%m-%d %H:%M"), tank.serial_num, tank.value, row.mf, row.sample, row.flag))
