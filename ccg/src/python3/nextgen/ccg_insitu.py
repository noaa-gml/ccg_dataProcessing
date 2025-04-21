
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data
# using either LGR based system, GC, or NDIR systems.
#
# This version uses several setup methods that can be called before
# computing the mole fractions.
"""

import sys
import datetime
import pandas as pd

import ccg_insitu_raw
import ccg_refgasdb
import ccg_dates
import ccg_insitu_db

import ccg_insitu_ndir
import ccg_insitu_response
import ccg_insitu_response_odr
import ccg_insitu_tower_odr
import ccg_insitu_gc
import ccg_insitu_gc_co
import ccg_insitu_labcal
import ccg_insitu_lbl
import ccg_insitu_wgc
from ccg_utils import poly


##################################################################
class insitu:
    """ Class for calculations involving insitu systems using NDIR, GC, LGR's.
    All data comes from the raw files, passed in by the 'rawfiles' filename list.

    Usage:
       isdata = ccg_insitu.insitu(stacode, gas, rawfiles, system=None, debug=False)

       Arguments
       required
         stacode - three letter station code, BRW, MLO, SMO, SPO
         gas - gas of interest, e.g. 'co2', 'ch4' ...
         rawfiles - list of raw file names to read

       optional
         system - type of measurement system, one of 'NDIR', 'GC', 'LGR'
         debug - print debuggin information if True

    Methods:

       Several methods are available to further refine the configuration.

        useTarget(use_target)
            - Determine results for target gas calibrations instead of air samples
        setRefgasFile(refgasfile)
            - name of file holding reference gas information.  Default is scale_assignments database table
        setRefgasScale(scale)
            - Set scale to use for reference gases.  Default is current scale for the gas.
        setResponseFile(responsefile)  NOT IMPLEMENTED
            - name of file with repsonse curve information.  Default is to get response curve values from database
        setAmie(amie)
            - Apply automated flags to GC results if True.

       Main method for doing the calculations is

        compute_mf()

    """

    def __init__(self, stacode, gas, rawfiles, system=None, debug=False):

        self.stacode = stacode.lower()
        self.gas = gas.upper()
        self.useResponseCurves = False
        self.valid = True
        self.debug = debug
        self.system = None
        self.results = None
        self.responsefile = None
        self.use_amie = True
        self.debug = debug
        self.sample_type = "SMP"
        self.obj = None  # this is the class object that does the computation
        self.results = None

#        t0 = datetime.datetime.now()
        # this will also set the calculation methods to be used, and their time spans.
        self.raw = ccg_insitu_raw.InsituRaw(stacode, gas, rawfiles, system=system)
#        t1 = datetime.datetime.now()
#        print("time to read rawfiles:", t1-t0)
        if self.raw.method is None:
            sys.exit("Unknown system type.  Use --system option.")

        if self.debug:
            print("Raw valid is", self.raw.valid)
        if self.raw.numrows == 0:
            sys.exit("Error: No raw data found.")

#        for meth in self.raw.methods: print(meth)
#        print(self.raw.data)


        if system is None:
            self.system = self.raw.method
            if self.system is None:
                sys.exit("Ambiguous system type. Use --system option.")
        else:
            self.system = system
        if self.debug:
            print("System:", self.system)


        # Find the dates of the first and last lines of data
        self.startdate = self.raw.startdate
        self.enddate = self.raw.enddate

        # Open the corresponding reference gas table and read entries.
        # get reference gas info from database
        self.refgas = ccg_refgasdb.refgas(
            self.gas,
            location=self.stacode,
            use_history_table=True,
            startdate=self.startdate,
            enddate=self.enddate,
            debug=debug)

#        print(self.startdate, self.enddate)
#        for row in self.refgas.refgas: print(row)
#        sys.exit()


        if not self.refgas.valid:
            print("No reference gas information found for date %s" % (self.startdate.strftime("%Y-%m-%d")), file=sys.stderr)
            self.valid = False


    #########################################################################
    # Setup methods
    #########################################################################

    #--------------------------------------------------------------------------
    def useTarget(self, use_target):
        """ make calculations on Target gas instead of sample air if True """

        self.sample_type = "TGT" if use_target else "SMP"

    #--------------------------------------------------------------------------
    def setRefgasFile(self, refgasfile):
        """ Set the reference gas information to a text file.

        Default is to use the database, but this method can be used
        to read the info from a file instead.
        """

        self.refgas = ccg_refgasdb.refgas(
            self.gas,
            refgasfile=refgasfile,
            startdate=self.startdate,
            enddate=self.enddate,
            debug=self.debug)

    #--------------------------------------------------------------------------
    def setRefgasScale(self, scale):
        """ Set the scale to use in the reference gas database assignments """

        self.refgas = ccg_refgasdb.refgas(
            self.gas,
            scale=scale,
            location=self.stacode,
            use_history_table=True,
            startdate=self.startdate,
            enddate=self.enddate,
            debug=self.debug)


    #--------------------------------------------------------------------------
    def setResponseFile(self, filename):
        """ Set a non-default response curve file

        For laser instruments at brw, mlo

        NOT IMPLEMENTED
        requires more work to use.
        """

        self.responsefile = filename

    #--------------------------------------------------------------------------
    def setAmie(self, use_amie=True):
        """ Set whether to use amie (or acmie) processing or not for gc's """

        self.use_amie = use_amie

    #########################################################################
    # Compute methods
    #########################################################################

    #--------------------------------------------------------------------------
    def compute_mf(self):
        """ Calculate mole fraction values
        The method to use for computing the mole fractions is
        set in the insitu.conf configuration file, and is saved
        in the raw class object.
        The method can change with time.

        Return the results as a pandas DataFrame.
        If multiple methods are needed, append the dataframes together
        """

        if self.debug:
            print("Methods:", self.raw.methods)

        if len(self.raw.methods) == 0:
            sys.exit("No calculation methods set.")

        # this requires raw passed to the methods is a DataFrame, not a class object
        for method in self.raw.methods:

            df = self.raw.data[(self.raw.data.date >= method.sdate) & (self.raw.data.date < method.edate)]

            # for instruments with manual response curves (brw, mlo)
            if method.value == 'response':
                self.obj = ccg_insitu_response.response(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
#                t0 = datetime.datetime.now()
                results = self.obj.compute()
#                t1 = datetime.datetime.now()
#                print("time to compute results", t1-t0)

            # for older observatory co2 ndir systems
            elif method.value == "ndir":
                self.obj = ccg_insitu_ndir.ndir(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute()

            # for nextgen, tower and recent co2 ndir (smo, spo)
            elif method.value == "auto_response":
                self.obj = ccg_insitu_response_odr.ndir2(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute()

            # older non-co gc's (brw, mlo)
            elif method.value == "gc":
                self.obj = ccg_insitu_gc.gc(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, debug=self.debug)
                results = self.obj.compute(self.use_amie)

            # older co gc's (brw, mlo)
            elif method.value == "gc_co":
                self.obj = ccg_insitu_gc_co.gc(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute(self.use_amie)

            # - for testing, computation methods similar to idl program
            elif method.value == "tower":
                self.obj = ccg_insitu_tower_odr.tower(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute()

            elif method.value == "labcal":
                self.obj = ccg_insitu_labcal.response(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute()

            # for wgc before 2024 (testing)
            elif method.value == "lbl":
                self.obj = ccg_insitu_lbl.lbl(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute()

            # for wgc after dec 2024
            elif method.value == "wgc":
                self.obj = ccg_insitu_wgc.ndir2(self.stacode, self.gas, df, self.system, self.refgas, self.sample_type, self.debug)
                results = self.obj.compute()

            else:
                sys.exit("Unknown computation method: %s", method.value)


            if self.results is None:
                self.results = results
            else:
#                self.results = self.results.append(results)
                self.results = pd.concat([self.results, results])  # needed for pandas 2.0

#            print(self.results)

#        sys.exit()


    #########################################################################
    # Output methods
    #########################################################################

    #--------------------------------------------------------------------------
    def printResultString(self, dateformat=False):
        """ Print results in nice format """

        format1 = "%3s %s %8.2f %8.2f %8.2f %8.2f %3d %3s %s %s"
        for row in self.results.itertuples():
            if dateformat:
                datestr = row.date.strftime("%Y-%m-%d %H:%M:%S")
            else:
                datestr = row.date.strftime("%Y %m %d %H %M %S")

            print(format1 % (row.stacode, datestr, row.mf, row.stdv, row.unc, row.ref_unc, row.n, row.flag, row.sample, row.comment))

    #--------------------------------------------------------------------------
    def printXYData(self):
        """ Print two columns of results, dates as a decimal date and molefraction """

        for row in self.results.itertuples():
            x = ccg_dates.decimalDateFromDatetime(row.date)
            y = row.mf
            print("%13.8f %.2f" % (x, y))

    #--------------------------------------------------------------------------
    def printTable(self):
        """ Print out a table of results and reference gas info """

        if hasattr(self.obj, 'printTable'):
            self.obj.printTable()

    #--------------------------------------------------------------
    def printCoeffs(self):
        """ Print out the calibration response coefficients """

        for date, t in self.obj.coeffs.items():
            fit = t[0]
            rsd = t[1]
            if isinstance(fit, tuple):
                # laser coeffs are different
                coeffs = fit
            else:
                coeffs = fit.beta
            print(date, end='')
            for coef in coeffs:
                print("%14.8f" % coef, end='')

            print("%8.3f" % rsd)

    #--------------------------------------------------------------
    def printInput(self):
        """ Print out the input data for calibration response """

        for date, (x, y, xsd, ysd) in zip(self.obj.coeffs, self.obj.input_data):
            for xp, yp, xpsd, ypsd in zip(x, y, xsd, ysd):
                print("%s %11.6f %11.6f %11.6f %11.6f" % (date.strftime("%Y %m %d %H %M"), xp, xpsd, yp, ypsd))
            print()

    #--------------------------------------------------------------
    def printResid(self):
        """ print out residuals from calibration response curve """

        # input_data has (x, y, xsd, ysd)
        for date, (x, y, xsd, ysd) in zip(self.obj.coeffs, self.obj.input_data):
            for xp, yp in zip(x, y):
                fit = self.obj.coeffs[date][0]
                resid = yp - poly(xp, fit.beta)
#                print(xp, yp, fit.beta, resid)
                print("%s %8.4f %8.4f" % (date.strftime("%Y %m %d %H %M"), xp, resid))
            print()



    #--------------------------------------------------------------
    def checkDb(self, verbose=False, db="ccgg", newdb=False):
        """ Check the result string with the corresponding value in the database. """

        isdb = ccg_insitu_db.InsituDB(
            self.stacode,
            self.gas,
            self.system,
            self.sample_type,
            database=db,
            newdb=newdb,
            verbose=verbose,
            debug=self.debug)

        for row in self.results.itertuples():
            isdb.checkDb(row)

    #--------------------------------------------------------------
    def updateDb(self, verbose=False, force_flag=False, db="ccgg", newdb=False):
        """ Update the database with new values from results. """

        isdb = ccg_insitu_db.InsituDB(
            self.stacode,
            self.gas,
            self.system,
            self.sample_type,
            force_flag=force_flag,
            readonly=False,
            database=db,
            newdb=newdb,
            verbose=verbose,
            debug=self.debug)

        if self.results is not None:
            for row in self.results.itertuples():
                isdb.updateDb(row)
