#!/usr/bin/env python
"""
#
# Selection flags are applied using select_ch4, select_co2 routines
#
# Calculates hourly averages for obervatory sites only. For tower sites, use
# /ccg/towers/src/bin/tower_hravg.py
#
# Monthly averages for ch4 are computed from a smooth curve fit to the daily averages
#
# Includes calculating uncertainty value for hourly averages (added Mar 2018)
# version to use new routines in /ccg/src/python3/lib
#
# !! This version is for the consolidated insitu tables: insitu, hour, day, month
"""
from __future__ import print_function

import sys
import argparse

sys.path.insert(1, "/ccg/src/python3/nextgen")

import ccg_average_obs
import ccg_average_tower

CHECK = 2
UPDATE = 1

########################################################################

obs = ["BRW", "MLO", "SMO", "SPO", "CHS", "MKO", "CAO", "LEF", "BND", "WGC"]

parser = argparse.ArgumentParser(description="Create hourly, daily and monthly averages from in-situ data. ")
parser.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with those in database.")
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with calculated values.")
parser.add_argument('-a', '--all', action="store_true", default=False, help="Calculate all averages; hourly, daily and monthly.")
parser.add_argument('-r', '--raw', action="store_true", default=False, help="Do not calculate averages, just print out in-situ data only (Default).")
parser.add_argument('--hour', action="store_true", default=False, help="Calculate hourly averages.")
parser.add_argument('--day', action="store_true", default=False, help="Calculate daily averages.")
parser.add_argument('--month', action="store_true", default=False, help="Calculate monthly averages.")
parser.add_argument('-n', '--noselection', action="store_true", default=False, help="Do not perform the data selection step for hourly averages.")
parser.add_argument('--database', default="ccgg", help="Select database to compare/update results. Default is 'ccgg'.")
parser.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")

parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="Gas formula, e.g. CO2")
parser.add_argument('year', type=int, help="Year to process")


options = parser.parse_args()

if options.check and options.update:
	print("Only one of --check and --update can be used.", file=sys.stderr)
	parser.print_usage()
	sys.exit()

db_option = None
if options.check: db_option = CHECK
if options.update: db_option = UPDATE


stacode = options.stacode.upper()
if stacode not in obs:
	print("Unknown station code %s." % stacode)
	parser.print_usage()
	sys.exit()

gas = options.gas.lower()
if gas not in ["co2", "ch4", "co", "n2o"]:
	print("Bad gas value. Should be one of 'co2', 'ch4' or 'co'.", file=sys.stderr)
	sys.exit()


if gas == "n2o" and stacode not in ["BRW", "CAO"]:
	print("%s data is not available at %s." % (gas, stacode), file=sys.stderr)
	sys.exit()

#if gas != "co2" and stacode in ["SMO", "SPO"]:
#	print("%s data is not available at %s." % (gas, stacode), file=sys.stderr)
#	sys.exit()


year = options.year

if options.all:
	options.day = True
	options.hour = True
	options.month = True

do_selection = not options.noselection

if stacode in ["CAO", "LEF", "BND"]: 
    do_selection = False
    averages = ccg_average_tower.mfavg(stacode, gas, year, db=options.database, verbose=options.verbose)
else:
    averages = ccg_average_obs.mfavg(stacode, gas, year, db=options.database, verbose=options.verbose)

if options.raw or (not options.hour and not options.day and not options.month):
	averages.doRawData()

else:
	if options.hour:
		averages.doHourlyAverage(db_option, do_selection)

	if options.day:
		averages.doDailyAverage(db_option)

	if options.month:
		averages.doMonthlyAverage(db_option)
