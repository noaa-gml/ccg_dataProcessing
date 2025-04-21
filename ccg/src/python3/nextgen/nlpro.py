#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Program nlpro.py
#
# Process raw non-linearity files,
#
"""
from __future__ import print_function

import sys
import argparse
from dateutil.parser import parse

sys.path.insert(1, "/ccg/src/python3/nextgen")
import ccg_nl
import ccg_rawfile


########################################################################
odrfit = None
co2_626_only = None

# epilog not allowed with python 2.4
epilog = "Only one of the output options should be given.  No options means print out results to stdout."

parser = argparse.ArgumentParser(epilog=epilog, description="Process response curve raw files. ")


group = parser.add_argument_group("Processing Options")
group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
group.add_argument('--database', help="Select a non-standard database for response curve table.")
group.add_argument('--moddate', help="use values for standards before this modification date ex --moddate=2014-05-01.")
group.add_argument('--scale', help="scale to use (default is current) ex --scale=CO_X2004.")
group.add_argument('--ref_op', choices=['divide', 'subtract', 'none'], default=None, help="Reference Operation (divide, subtract, or none for don't use)  Default is divide.")

group = parser.add_argument_group("Curve Fitting Options")
group.add_argument('-f', '--functype', choices=['poly', 'power'], help="Set type of function to use for odr fit, one of 'poly' or 'power'. Default is 'poly'.")
group.add_argument('-l', '--leastsq', action="store_true", default=False, help="Use normal least squares fit instead of odr fit.")
group.add_argument('-n', '--addnormal', choices=['true', 'false'], help="Set whether to use a point at reference tank, i.e. at [1, mixing ratio of std]. Specify either 'true' or 'false'.")
group.add_argument('-o', '--order', type=int, default=0, help="Order of polynomial to use in odr fit (1 = linear, 2 = quadratic... max is 8).")
group.add_argument('-z', '--addzero', action="store_true", default=False, help="Add a zero point to fit, i.e. add point at [0,0].")
group.add_argument('--nulltanks', help="comma separated list of tank serial numbers to NOT use in the curve fit.")
group.add_argument('--use_x_weights', choices=['true', 'false'], help="Use/Don't use weighting on x values. Specify either 'true' or 'false'.")
group.add_argument('--use_y_weights', choices=['true', 'false'], help="Use/Don't use weighting on y values. Specify either 'true' or 'false'.")

group = parser.add_argument_group("CO2 Isotope Options")
group.add_argument('--co2_626_only', choices=['true', 'false'], help="Set whether to assign total co2 value to 626 only before fit. Specify either 'true' or 'false'.")
#group.add_argument('--no_co2_626_only', action="store_true", default=False, help="Override the dedault conversion from total CO2 to 626 CO2 for the CRDS system.")
group.add_argument('--c13scale', help="Select scale to use for co2c13 values.")
group.add_argument('--o18scale', help="Select scale to use for co2o18 values.")

group = parser.add_argument_group("Output Options")
group.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with existing results.")
group.add_argument('-u', '--update', action="store_true", default=False, help="Update results with calculated values from file.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Include extra information on some output (--input and --resid options).")
group.add_argument('-t', '--table', action="store_true", default=False, help="Print a table of values")
group.add_argument('-i', '--input', action="store_true", default=False, help="Print input values that go into polynomial fit, sample/std ratio, std mixing ratio")
group.add_argument('-x', '--xrange', help="Specify range of ratios to use with --ratios option (e.g. 1,3). Default is 0 to 2")
#group.add_argument('--delete', action="store_true", default=False, help="Delete existing results!!!!")
group.add_argument('--ratios', action="store_true", default=False, help="Print out the mixing ratio value for a range of sample/std ratios")
group.add_argument('--resid', action="store_true", default=False, help="Print residuals of input data from curve")
group.add_argument('--show_config', action="store_true", default=False, help="Print out configuration values used in calculations")
group.add_argument('--show_extra', action="store_true", default=False, help="print out extra information on fit, i.e. coefficient standard errors and covariance matrix")
group.add_argument('--print_correlation', action="store_true", default=False, help="print out of correlation matrix computed from covariance matrix")
group.add_argument('--print_unc', action="store_true", default=False, help="print out coefficient standard errors")
group.add_argument('--printraw', action="store_true", default=False, help="print out data read from the raw file and exit")

parser.add_argument('args', nargs='*')

options = parser.parse_args()

if options.xrange is not None:
    try:
        (xmin, xmax) = options.xrange.split(",")
        xmin = float(xmin)
        xmax = float(xmax)
    except:
        print("Bad xmin, xmax for --xrange option.")
        parser.print_usage()
        sys.exit()
else:
    xmin = 0
    xmax = 2

if options.moddate is not None:
    try:
        moddate = parse(options.moddate)
    except:
        print("Could not parse date %s" % options.moddate, file=sys.stderr)
        sys.exit()
else:
    moddate = None

if options.leastsq:
    odrfit = False

# These variables can have 3 states:
#   None - Use default from configuration
#   True - Turn it on
#   False - Turn it off
# Option from command line will be either 'true', 'false', or None
# convert 'true' to True, 'false' to False
if options.co2_626_only is not None:
    if options.co2_626_only == "true":
        options.co2_626_only = True
    else:
        options.co2_626_only = False

if options.addnormal is not None:
    if options.addnormal == "true":
        options.addnormal = True
    else:
        options.addnormal = False

if options.use_x_weights is not None:
    if options.use_x_weights == "true":
        options.use_x_weights = True
    else:
        options.use_x_weights = False

if options.use_y_weights is not None:
    if options.use_y_weights == "true":
        options.use_y_weights = True
    else:
        options.use_y_weights = False


# Process the files specified on the command line
for filename in options.args:

    if options.debug:
        print("Processing", filename)


    if options.printraw:
        # Read the raw file
        raw = ccg_rawfile.Rawfile(filename, "nl")
        if raw.valid:

            for key in list(raw.info.keys()):
                print(key, ":", raw.info[key])
            for i in range(raw.numrows):
                print(raw.data[i])

        continue

    # Create nl class with additional data
    nldata = ccg_nl.Response(filename,
            database=options.database,
            peaktype=options.peaktype,
            moddate=moddate,
            scale=options.scale,
            order=options.order,
            odrfit=odrfit,
            usenormal=options.addnormal,
            usezero=options.addzero,
            debug=options.debug,
            nulltanks=options.nulltanks,
            use_x_weights=options.use_x_weights,
            use_y_weights=options.use_y_weights,
            functype=options.functype,
            co2_626_only=options.co2_626_only,
            c13scale=options.c13scale,
            o18scale=options.o18scale,
            ref_op=options.ref_op)


    if nldata.valid is False: continue

    if options.debug:
        print("Odrfit is ",   nldata.config.odrfit)
        print("usenormal = ", nldata.config.usenormal)
        print("usezero = ",   nldata.config.usezero)
        print("order = ",     nldata.config.order)
        print("ref_op = ",    nldata.config.ref_op)

    if options.show_config:
        nldata.printConfig()

    # Process depending on option
    if options.check:               nldata.checkDb()
    elif options.update:            nldata.updateDb()
#    elif options.delete:            nldata.deleteDb()
    elif options.table:             nldata.printTable()
    elif options.input:             nldata.printInput(options.verbose)
    elif options.ratios:            nldata.printRatios(xmin, xmax)
    elif options.resid:             nldata.printResiduals(options.verbose)
    elif options.print_correlation: nldata.printCorrelation()
    elif options.print_unc:         nldata.printUnc()
    else:                           nldata.printResults(options.show_extra, verbose=options.verbose)
