#!/usr/bin/env python
"""
#
# Program ccgis.py
#
# Process raw in-situ files, calculating mixing ratios,
# and standard deviation of mixing ratios.
#
#
# Test Version to handle tower data
"""

import sys
import argparse

#sys.path.append("/ccg/src/python3/lib")
import ccg_insitu
import ccg_insitu_stats


parser = argparse.ArgumentParser(description="Process in-situ raw files. ")

group = parser.add_argument_group("Processing Options")
group.add_argument('-g', '--target', action="store_true", default=False, help="Calculate values for the target gas.")
group.add_argument('-n', '--noamie', action="store_true", default=False, help="Skip amie (or acmie) processing of data.")
group.add_argument('-q', '--checkraw', action="store_true", default=False, help="Check raw files for errors.")
group.add_argument('-r', '--respfile', default='', help="Select a non-standard response file.")
group.add_argument('-s', '--singlepoint', action="store_true", default=False, help="Use single point calibration instead of response curves.")
group.add_argument('--scale', help="scale to use (default is current) ex --scale=CO_X2004.")
group.add_argument('-w', '--refgasfile', help="Choose a text reference gas file instead of database for assigned values.")
group.add_argument('--force', action="store_true", default=False, help="Force update of flags when reprocessing existing data.  Normally flags are not updated in the database when reprocessing data.  Only valid when used with -u option")
#group.add_argument('--system', choices=['PIC', 'LGR', 'NDIR', 'LCR'], default=None, type=str.upper, help="Specify system to use during overlap periods of co2 analysis.")
group.add_argument('--system', type=str.upper, help="Specify system to use during overlap periods of co2 analysis.")
group.add_argument('--newdb', action="store_true", default=False, help="Use new database table (single table for all insitu measurements).")
group.add_argument('--olddb', action="store_true", default=False, help="Use old database table (multiple tables for all insitu measurements).")

group = parser.add_argument_group("Output Options")
group.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with those in database.")
group.add_argument('--coeff', action="store_true", default=False, help="Print out response curve coefficients")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")
group.add_argument('-i', '--inputdata', action="store_true", default=False, help="Print out input data to response curve cals.")
group.add_argument('--residuals', action="store_true", default=False, help="Print out residuals from response curve cals.")
group.add_argument('-p', '--printraw', action="store_true", default=False, help="Print raw data to stdout, then exit")
group.add_argument('-t', '--table', action="store_true", default=False, help="Print a table of values")
group.add_argument('--stats', action="store_true", default=False, help="Print statistics for calculated reference shots")
group.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with calculated values from file.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")
group.add_argument('-x', '--xy', action="store_true", default=False, help="Print a list of decimal date, values.")
group.add_argument('--db', default="ccgg", help="Select database to use for updates and checks. Default is 'ccgg'.")
group.add_argument('--datetime', action="store_true", default=False, help="Print dates of results using yyyy-mm-dd hh:mm:ss format.")

parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="Gas formula, e.g. CO2")
parser.add_argument('files', nargs='+', help="raw files to process")

options = parser.parse_args()

stacode = options.stacode.upper()
gas = options.gas

if gas.upper() not in ("CO2", "CH4", "CO", "N2O", "CO2DRY"):
	print("Unknown gas %s." % gas)
	parser.print_usage()
	sys.exit()

#if gas == "co2":
#	if stacode not in ("BRW", "MLO", "SMO", "SPO", "LEF", "SCT", "CAO", "MKO", "AMT", "BND", "WGC"):
#		print("Unknown station code %s." % stacode)
#		parser.print_usage()
#		sys.exit()
#else:
#	if stacode not in ("BRW", "MLO", "LEF", "CAO", "MKO", "BND", "WGC", "SMO"):
#		print("Unknown station code %s." % stacode)
#		parser.print_usage()
#		sys.exit()

# force newdb option to be default, unless specifically asked for old db  - kwt oct 2024
if options.olddb is False:
    options.newdb = True
else:
    options.newdb = False

# Process the files specified on the command line
# Put all lines from raw files into raw[] array, then
# process the array.
#isdata = ccg_insitu.insitu(stacode, gas,
#			   options.files,
#			   options.target,
#			   options.refgasfile,
#			   options.respfile,
#			   options.system,
#			   scale=options.scale,
#			   singlepoint=options.singlepoint,
#			   use_amie=not options.noamie,
#			   debug=options.debug)

# OR
isdata = ccg_insitu.insitu(stacode, gas, options.files, options.system, debug=options.debug)
isdata.setAmie(not options.noamie)
if options.target: isdata.useTarget(True)
if options.refgasfile: isdata.setRefgasFile(options.refgasfile)
if options.respfile: isdata.setResponseFile(options.respfile)
if options.scale: isdata.setRefgasScale(options.scale)

isdata.compute_mf()


# Show results depending on option
if options.update: isdata.updateDb(options.verbose, options.force, db=options.db, newdb=options.newdb)
elif options.check: isdata.checkDb( options.verbose, db=options.db, newdb=options.newdb)
elif options.coeff: isdata.printCoeffs()
elif options.inputdata: isdata.printInput()
elif options.residuals: isdata.printResid()
elif options.table: isdata.printTable()
elif options.xy: isdata.printXYData()
elif options.stats: ccg_insitu_stats.gcstats(isdata, options.verbose)
elif options.checkraw: isdata.raw.checkRaw()
elif options.printraw: isdata.raw.printRaw()
else: isdata.printResultString(options.datetime)
