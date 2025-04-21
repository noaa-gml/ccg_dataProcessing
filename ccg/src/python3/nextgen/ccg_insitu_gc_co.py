# vim: tabstop=4 shiftwidth=4 expandtab


"""
# Routines needed for calculating mole fractions for in-situ data
# using gc for co measurements

# returns results in a pandas DataFrame
"""

import sys
import datetime
import pandas as pd
import numpy

import ccg_dates
import ccg_insitu_utils
import ccg_insitu_config
import acmie

SQRT2 = 1.4142136
MINUTES_20 = datetime.timedelta(minutes=20)

##################################################################
class gc:
    """ Class for calculations involving insitu systems using gc
    analyzers for carbon monoxide measurements

    The computation uses either 2 or 3 standards to determine a
    response curve, and calculation of the sample mole fraction
    from that response curve.

    Usage:
       isdata = ccg_insitu_gc_co.gc(raw, refgas, smptype='SMP', debug=False)

    Arguments:
       required
         raw - raw class object containg the raw data
         refgas - refgasdb object with reference gas information
       optional
         smptype - Sample type to process.  Either 'SMP' of 'TGT'
         debug - Print out debugging information

    Methods:
       compute():
         Calculate the mole fractions.
    """

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

        self.config = ccg_insitu_config.InsituConfig(self.stacode, gas, 'gc')
        self.std_labels = self.config.get('stds', startdate).split()

        self.caldates = ccg_insitu_utils.change_dates(self.stacode, gas, 'gc', self.std_labels, refgas, startdate, enddate)


    #------------------------------------------------------------------------
    def compute(self, use_amie=True):
        """ Routines for CO GC calculations """

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

            df2 = df[(df.smptype == self.sample_type)]
            if self.debug:
                print(df2)
            for row in df2.itertuples():

                mrh = -999.99
                mra = -999.99
                flag = "*.."

                nwork = len(self.std_labels)
                bcodes = self.config.get('baseline_codes', row.date).split()

                if row.bc in bcodes:
                    if nwork == 2:
                        (mrh, mra, flag) = self.calc_co_2work(row.Index, bcodes, row.ph, row.pa)
                    else:
                        (mrh, mra, flag) = self.calc_co_3work(row, bcodes)

                    mrh = round(mrh, 2)
                    mra = round(mra, 2)

                    if mrh < 0: mrh = -999.99
                    if mra < 0: mra = -999.99


                peaktype = self.config.get('peaktype', row.date)
                val = mrh if peaktype == "height" else mra
                t = (self.stacode.upper(), row.date, val, -999.99, -999.99, -999.99, 1, flag, row.label, row.comment)
#                print(t)
                t = self.Result._make(t)
                self.results.append(t)


        if use_amie:
#            t0 = datetime.datetime.now()
            acmie.acmie(self.stacode, self.config, self.raw, self.results, self.debug)
#            t1 = datetime.datetime.now()
#            print("time for acmie is", t1-t0)

        self.results = pd.DataFrame(self.results)

        return self.results

    #-----------------------------------------------------------------------
    def printTable(self):
        """ print results in nice format """

        format1 = " %s  %10s %6.2f %10s %6.2f %10s %6.2f %12.2f %10s %6s"

        print("   Date      Time           L                 M                 H        M.R.          Port    Flag")
        print("-"*116)

        for row in self.results.itertuples():

            nwork = 3
            dd = ccg_dates.intDate(row.date.year, row.date.month, row.date.day, 0)
            if self.stacode.upper() == "BRW" and dd < 1993012000: nwork = 2
            serw1, concw1, uncw1 = self.refgas.getRefgasByLabel("L", row.date)
            serw2, concw2, uncw2 = self.refgas.getRefgasByLabel("M", row.date)
            if nwork == 3:
                serw3, concw3, uncw3 = self.refgas.getRefgasByLabel("H", row.date)
            else:
                serw3 = "None"
                concw3 = -999.99
                uncw3 = -999.99

            print(format1 % (
                row.date.strftime("%Y-%m-%d %H:%M"),
                serw1, concw1, serw2, concw2, serw3, concw3, row.mf, row.sample, row.flag))

    #-----------------------------------------------------------------------
    def calc_co_3work(self, row, bcodes):
        """ Calculate co mole fraction using 3 reference tanks """

        if self.debug:
            print("------- Using 3 working tanks", self.std_labels)
            print(row)

        mrh = -999.99
        mra = -999.99
        flag = "*.."

#        i = row.Index

        # Get bracketing reference gas samples
        (vlh, vla, nl) = self._get_co_ref(row.Index, "L", bcodes, row.date)
        (vmh, vma, nm) = self._get_co_ref(row.Index, "M", bcodes, row.date)
        (vhh, vha, nh) = self._get_co_ref(row.Index, "H", bcodes, row.date)

        # If any of L, M, or H don't have values, use the
        # default mole fraction for the ambient sample and move on.

        if nl != 0 and nm != 0 and nh != 0:

            # Now we can finally calculate the mole fraction.
            # First find the correct working tank assigned values
            # from the working tank table.

            y = []
            for label in self.std_labels:
                tank = self.refgas.getRefgasByLabel(label, row.date)
                y.append(tank.value)

            # Fit a quadratic to the points.  Y axis is mole fraction,
            # X axis is peak size. Calculate both height and area values.


            # mole fraction using peak height
            x = numpy.array([vlh, vmh, vhh])
            coeffsh = numpy.polyfit(x, y, deg=2)
            mrh = numpy.polyval(coeffsh, row.ph)

            # mole fraction using peak area
            x = numpy.array([vla, vma, vha])
            coeffsa = numpy.polyfit(x, y, deg=2)
            mra = numpy.polyval(coeffsa, row.pa)

            if self.debug:
                print("x height:", vlh, vmh, vhh)
                print("x area:", vla, vma, vha)
                print("y:", y)
                print("coeffs height:", coeffsh)
                print("coeffs area:", coeffsa)
                print("mfh, mfa:", mrh, mra)

            flag = "..."

        if nl == 1 or nm == 1 or nh == 1:
            flag = "..R"
        if nl == 0 or nm == 0 or nh == 0:
            flag = "&.R"


        return (mrh, mra, flag)

    #---------------------------------------------------------------------------
    def _get_co_ref(self, i, name, bcodes, date):
        """
        Find co gc reference aliquots with the label given by 'name'.
        # There may be missing samples so check each line until you find the L sample.
        # It must be one of the next 3 lines for it to be valid.
        """

        n = 0
        vh = 0
        va = 0

        # Get the desired reference gas following the sample
        # It must be within 20 minutes of the sample
        idx = self.findNextRef(i, "REF", name)
        if idx > 0:
            row = self.raw.iloc[idx]
            if row.bc in bcodes and row.date - date <= MINUTES_20:
                vh = row.ph
                va = row.pa
                n = 1

        # Get the desired reference gas preceeding the sample
        # It must be within 20 minutes of the sample
        idx = self.findPrevRef(i, "REF", name)
        if idx > 0:
            row = self.raw.iloc[idx]
            if row.bc in bcodes and date - row.date <= MINUTES_20:
                vh += row.ph
                va += row.pa
                n += 1

        if n > 1:
            vh = vh / n
            va = va / n

        return vh, va, n

    #------------------------------------------------------------------------------
    def calc_co_2work(self, i, bcodes, ph, pa):
        """
        Compute the mole fractions for two reference tanks.
        4 possibilities
        1. preceeding aliquot is a good reference and following aliquot is a good reference
        2. preceeding aliquot is not a good reference and following aliquot is not a good reference
        3. preceeding aliquot is a good reference and following aliquot is not a good reference
        4. preceeding aliquot is not a good reference and following aliquot is a good reference

        Only check for cases 1,3,4.  Any others get default values.

        Flag for 1 is "...";
        Flag for 2 is "*..";
        Flag for 3 is "..<";
        Flag for 4 is "..>";
        """

        if self.debug:
            print("Using 2 working tanks", self.std_labels)

        mrh = -999.99
        mra = -999.99
        flag = "*.."

        r1valid = True
        r2valid = True

        if i-1 >= 0:
            row1 = self.raw.loc[i-1]
            tank1 = self.refgas.getRefgasByLabel(row1.label, row1.date)
            if row1.bc not in bcodes: r1valid = False
            if row1.label not in self.std_labels: r1valid = False
        else:
            r1valid = False

        if i+1 < len(self.raw):
            row2 = self.raw.loc[i+1]
            tank2 = self.refgas.getRefgasByLabel(row2.label, row2.date)
            if row2.bc not in bcodes: r2valid = False
            if row2.label not in self.std_labels: r2valid = False
        else:
            r2valid = False

#        print(r1valid, r2valid)

        # Check for case 1
        if r1valid and r2valid:
            slope = (tank2.value - tank1.value)/(row2.ph - row1.ph)
            mrh = ((ph - row1.ph) * slope) + tank1.value
            slope = (tank2.value - tank1.value)/(row2.pa - row1.pa)
            mra = ((pa - row1.pa) * slope) + tank1.value
            flag = "..."

        # Check for case 3
        elif r1valid:
            slope = (tank1.value)/(row1.ph)
            mrh = ((ph - row1.ph) * slope) + tank1.value
            slope = (tank1.value)/(row1.pa)
            mra = ((pa - row1.pa) * slope) + tank1.value
            flag = "..<"

        # Check for case 4
        elif r2valid:
            slope = (tank2.value)/(row2.ph)
            mrh = ((ph - row2.ph) * slope) + tank2.value
            slope = (tank2.value)/(row2.pa)
            mra = ((pa - row2.pa) * slope) + tank2.value
            flag = "..>"

        return (mrh, mra, flag)

    #--------------------------------------------------------------------------
    def findPrevRef(self, linenum, stype, label, occurence=1):
        """ Find the previous reference sample type and label
        starting at linenum
        """

        nocc = 0
        for i in range(linenum, -1, -1):
            smptype = self.raw.smptype[i]
            smplabel = self.raw.label[i]
            if smptype == stype and smplabel == label:
                nocc += 1
                if nocc == occurence:
                    return i

        return -1

    #--------------------------------------------------------------------------
    def findNextRef(self, linenum, stype, label, occurence=1):
        """ Find the next reference sample type ('REF')
        starting at linenum
        """

        nocc = 0
        for i in range(linenum, len(self.raw)):
            smptype = self.raw.smptype[i]
            smplabel = self.raw.label[i]
            if smptype == stype and smplabel == label:
                nocc += 1
                if nocc == occurence:
                    return i

        return -1
