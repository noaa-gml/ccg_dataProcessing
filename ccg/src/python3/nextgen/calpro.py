#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
#
# Program calpro.py
#
# Process raw calibration files,
#
#
# Apr 2019 modified to use calrawfile class instead of calraw.read_file() function
"""
from __future__ import print_function

import sys
import argparse

sys.path.insert(1, "/ccg/src/python3/nextgen")
import ccg_cal
import cal_co2isotopes
import ccg_utils


########################################################################
def print_header(caldata, verbose=False):
    """
    Print one line for each file, showing date and tank serial numbers,
    and optionally assigned mixing ratios if -v flag was given.
    The co2cal-1 system needs to be handled specifically, because the
    number of reference tanks that were used can change for each cal.
    """

    global needheader

    frmt = "%10s"

    # Only one header for all the files
    if needheader:
        print("      Date    ", end=' ')
        if caldata.system.lower() == "co2cal-1":
            for name in ["L", "M", "H", "Q"]:
                if verbose:
                    print("%18s" % name, end=' ')
                else:
                    print("%10s" % name, end=' ')

        else:
            for name in list(caldata.refgas.keys()):
                if verbose:
                    print("%18s" % name, end=' ')
                else:
                    print("%10s" % name, end=' ')

        for name in sorted(caldata.workgas.keys()):
            print("%10s" % name, end=' ')

        print("\n-----------------------------------------------------------------------------------")
        needheader = 0

    print("%s" % caldata.adate.strftime("%Y-%m-%d %H:%M"), end=' ')
    if caldata.system.lower() == "co2cal-1":
        for key in ["L", "M", "H", "Q"]:
            if key in list(caldata.refgas.keys()):
                (sn, val, stdv) = caldata.refgas[key]
                if verbose:
                    print("%10s %7.2f" % (sn, val), end=' ')
                else:
                    print(frmt % (sn), end=' ')
            else:
                if verbose:
                    print("%18s" % " ", end=' ')
                else:
                    print(frmt % " ", end=' ')

    else:
        for name, (sn, val, stdv) in list(caldata.refgas.items()):
            if verbose:
                print("%10s %7.2f" % (sn, val), end=' ')
            else:
                print(frmt % (sn), end=' ')


    for name, (sn, pressure, regulator) in sorted(caldata.workgas.items()):
        print(frmt % (sn), end=' ')

    print()

########################################################################
def print_input(caldata, verbose=False):
    """ print the std/ref ratios that were used in the calibration """

#    print(caldata.ratio)
    for key in list(caldata.ratio.keys()):
        allrr = []
        for i, (rr, flag) in enumerate(caldata.ratio[key]):
            if flag == '.':
                allrr.append(rr)
            if verbose:
                print("%2d %9.6f %8.3f %3s" % (i+1, rr, caldata.mr[key][i][0], flag))

        if not verbose:
            avgrr, sdrr = ccg_utils.meanstdv(allrr)
            print("%15.6f %15.6f  %4d" % (avgrr, sdrr, len(allrr)))


########################################################################

needheader = True
default_output = True

parser = argparse.ArgumentParser(description="Process tank calibration raw files. ")

#        epilog="Only one of the output options should be given.  No options means print out a single result line to stdout.")

group = parser.add_argument_group("Processing Options")
group.add_argument('-f', '--file', help="Get raw file names to process from FILE, instead of arguments on command line.")
group.add_argument('-n', '--noresp', action='store_true', default=False, help="Do not use response curves for calculations, even if available.")
group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
group.add_argument('--scale', help="Scale to use (default is current). For example --scale=CO_X2004")
group.add_argument('--moddate', help="Use values for standards before this modification date. For example --moddate=2014-05-01")
group.add_argument('--nocorr', action="store_true", default=False, help="Do not apply co2 isotope corrections for co2cal-2 system.")
group.add_argument('--skip_first', choices=['true','false'], type=str.lower, default=None, help="Skip first aliquot. Specify either true or false")
group.add_argument('--database', default="reftank", help="Select database to compare/update results. Default is 'reftank'.")

group = parser.add_argument_group("Output Options")
group.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with those in database.")
group.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with calculated values from file.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")
group.add_argument('-g', '--stats', action="store_true", default=False, help="Print out a table of statistics for the raw file")
group.add_argument('-i', '--input', action="store_true", default=False, help="Print input values that go into polynomial fit, sample/std ratio, std mixing ratio")
group.add_argument('-t', '--table', action="store_true", default=False, help="Print a table of values")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")
group.add_argument('-s', '--showheader', action="store_true", default=False, help="Show serial numbers of tanks being used in each raw file")
group.add_argument('--dbflag', action="store_true", default=False, help="Use flag from database when printing default results")
group.add_argument('--fillcode', action="store_true", default=False, help="Include fill code when printing default results")
group.add_argument('--delete', action="store_true", default=False, help="Delete results from database!!!!")

parser.add_argument('args', nargs='*')

options = parser.parse_args()

#if options.scale in ["CO2_X2019", "CO2C13_X2019", "CO2O18_X2019"]:
#    options.database = "cal_scale_tests"


if options.file:
    inputfiles = []
    f = open(options.file)
    for line in f:
        inputfiles.append(line.strip())
    f.close()
else:
    inputfiles = options.args

if len(inputfiles) == 0:
    parser.print_usage()
    sys.exit("No input files given.")

if options.table or options.showheader or options.delete or options.input:
    default_output = False

# Set variables
if options.skip_first is not None:
    options.skip_first = True if options.skip_first == "true" else False

if options.debug:
        print("\n Start Debug ===================================================================================")

# Process the files
for filename in inputfiles:

    # Create cal class with additional data
    caldata = ccg_cal.Cal(filename,
        database=options.database,
        peaktype=options.peaktype,
        noresponse_curve=options.noresp,
        scale=options.scale,
        moddate=options.moddate,
        skip_first=options.skip_first,
        debug=options.debug)

#    print(caldata.results)
    if not caldata.valid: continue
    if not caldata.results: continue

    # if calibration is co2 cal using isotopes, do extra calculations
    # NOTE: caldata object is modified inside calcCO2Isotopes
    if (caldata.system.lower() == "co2cal-2"
        and caldata.species.lower() != "ch4"
        and (options.check or options.update or default_output)
        and not options.nocorr):

        cal_co2isotopes.calcCO2Isotopes(filename, caldata, options.database, options.debug)

    # for updating database, if system is co2cal-2, update total co2, co2c13 and co2o18 results
    # Changed Oct 18, 2016 - update only 1 species
#    if options.update:
#        if caldata.system.lower() == "co2cal-2" and options.nocorr == False:
#            for species in cdata.keys():
#                cdata[species].updateDb(options.verbose)
#        else:
#            caldata.updateDb(options.verbose)


    # Process depending on option
    if   options.update:     caldata.updateDb(options.database, options.verbose)
    elif options.check:      caldata.checkDb(options.database, options.verbose)
    elif options.table:      caldata.printTable()
    elif options.showheader: print_header(caldata, options.verbose)
    elif options.delete:      caldata.deleteDb(options.database, options.verbose)
    elif options.input:      print_input(caldata, options.verbose)
    elif options.stats:      caldata.stats(options.verbose)
    else: caldata.printResults(use_db_flag=options.dbflag, use_fill_code=options.fillcode)
