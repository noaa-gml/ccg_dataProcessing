#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
#
# Program flpro.py
#
# Process raw flask files
#
#
"""
from __future__ import print_function

import sys
import argparse
import datetime


sys.path.insert(1, "/ccg/src/python3/nextgen/")
import ccg_flask2


########################################################################


parser = argparse.ArgumentParser(description="Process flask analysis raw files. ")

group = parser.add_argument_group("Processing Options")
group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
group.add_argument('--scale', help="Scale to use (default is current). For example --scale=CO_X2004")
group.add_argument('--moddate', help="Use values for standards before this modification date. For example --moddate=2014-05-01")
group.add_argument('--database', help="Select database to compare/update results. Default is 'ccgg'.")
group.add_argument('--nocorr', action="store_true", default=False, help="Do not apply corrections to the data. Default is False.")

group = parser.add_argument_group("Output Options")
group.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with those in database.")
group.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with calculated values from file.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")
group.add_argument('-t', '--table', action="store_true", default=False, help="Print a table of values")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")
group.add_argument('-a', '--addalt', action="store_true", default=False, help="Add lat, lon, altitude to printed results")
group.add_argument('-g', '--stats', action="store_true", default=False, help="Print out a table of statistics for the raw file")
#group.add_argument('-f', '--flags', action="store_true", default=False, help="Show flagged flask data when using the -c, --check option")
group.add_argument('--dbflag', action="store_true", default=False, help="Use flag from database when printing results")
group.add_argument('--delete', action="store_true", default=False, help="Delete results from database!!!!")

parser.add_argument('rawfiles', nargs='*')

options = parser.parse_args()

# this is temporary
#if options.scale == "CO2_X2019":
#    options.database = "cal_scale_tests"

moddate = None
if options.moddate:
    dt = options.moddate.split('-')
    moddate = datetime.datetime(int(dt[0]), int(dt[1]), int(dt[2]))


if options.delete:
    if sys.version_info[0] < 3:
        answer = raw_input("Are you sure you want to delete from the database (y/n)? ")
    else:
        answer = input("Are you sure you want to delete from the database (y/n)? ")
    answer = answer.strip("\n")
    a = answer.lower()
    if a not in ("y", "yes"):
        sys.exit()


# Process the files specified on the command line
for filename in options.rawfiles:

    # Create flask class
    fldata = ccg_flask2.Flask(filename,
                 options.peaktype,
                 options.scale,
                 moddate,
                 database=options.database,
                 nocorr=options.nocorr,
                 debug=options.debug)

    if fldata.valid is False:
        continue

    # Process depending on option
    if   options.update:   fldata.updateDb(options.verbose)
    elif options.check:    fldata.checkDb(options.verbose)  # , options.flags)
    elif options.table:    fldata.printTable()
    elif options.delete:   fldata.deleteDb(options.verbose)
    elif options.stats:    fldata.stats(options.verbose)
    else:                  fldata.printResults(options.addalt, options.dbflag)
