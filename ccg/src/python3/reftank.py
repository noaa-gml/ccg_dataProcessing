#!/usr/bin/env python
"""
Program to print results for cylinder calibrations.
"""
from __future__ import print_function

import sys
import argparse

from dateutil.parser import parse

sys.path.insert(1, "/ccg/python/ccglib")

import ccg_cal_db


#######################################################################

syslist = None

parser = argparse.ArgumentParser(description="Process reference tank calibration results. ")

group = parser.add_argument_group("Output Types when serial number is set")
group.add_argument('-a', '--average', action="store_true", default=False, help="Show only average value for a filling, not individual calibrations.")
group.add_argument('-f', '--fill', action="store_true", default=False, help="Show filling information for each tank serial number.")
group.add_argument('-s', '--summary', action="store_true", default=False, help="Show summary information for each calibration.")
group.add_argument('-t', '--table', action="store_true", default=False, help="Print a table of calibration date, mixing ratio, flag, fillcode.")
group.add_argument('-x', '--groupfill', action="store_true", default=False, help="Group calibrations by fill code. Slightly different from standard result, in that fillings without calibrations will show up.")

group = parser.add_argument_group("Output Modifiers")
group.add_argument('-c', '--code', type=str.upper, help="Show information for a specific fill code.")
group.add_argument('-g', '--gas', help="Select gas species to use (co2, ch4, co ...). Do not set to get all gases.")
group.add_argument('-i', '--id', help="Include calibrations using only instruments with these id's (e.g. S2,L9,S5)")
group.add_argument('-m', '--method', help="Include calibrations, in addition to those set by -i or -o, with this type of analysis method.")
group.add_argument('-n', '--notes', action="store_true", default=False, help="Include notes for a calibration in the output.")
group.add_argument('-o', '--official', action="store_true", default=False, help="Use only 'official' system id's for results.")
group.add_argument('-p', '--isotope', action="store_true", default=False, help="Include any isotope measurements of CO2 for the tank.")
group.add_argument('--noheader', action="store_true", default=False, help="Don't print out header lines before result listing.")
group.add_argument('--legacy', action="store_true", default=False, help="Print out results in same format as previous versions.  (system name is excluded).")
group.add_argument('-d', '--date', help="Restrict data to a given date.")
group.add_argument('-q', '--quiet', action="store_true", default=False, help="Suppress warning messages about fillings and calibrations.")
group.add_argument('--noflask', action='store_false', default=True, help='Do not display isotope results of flasks filled from tank')

group = parser.add_argument_group("Processing Options")
group.add_argument('--database', default="reftank", help="Use a different database for calibration results.")

group = parser.add_argument_group("Output Format")
group.add_argument('-w', '--format', default='text', choices=['text', 'html', 'json', 'csv'], help="Set format of output, either 'text, 'html', or 'json'. Default is 'text'.")

parser.add_argument('args', nargs='*')

options = parser.parse_args()

# do this inside ccg_caldb
#if options.id:
#	syslist = ",".join(["'" + s + "'" for s in options.id.split(",")])

selected_date = None
if options.date:
	try:
		dt = parse(options.date)
	except ValueError as err:
		print("Could not parse date %s: %s" % (options.date, err), file=sys.stderr)
		sys.exit()

	selected_date = dt.date()


if options.gas:
	options.gas = options.gas.upper()

if not options.args:
	if selected_date is not None:
		cals = ccg_cal_db.Calibrations(tank=None,
					      gas=options.gas,
					      syslist=options.id,
					      date=selected_date,
					      quiet=options.quiet,
					      database=options.database)
		print(cals.showTankSummary(options.format))

	else:
		cals = ccg_cal_db.Calibrations(tank=None,
					      gas=options.gas,
					      syslist=syslist,
					      date=selected_date,
					      quiet=options.quiet,
					      database=options.database)
		print(cals.showDbList())
else:
	for tank in options.args:
		cals = ccg_cal_db.Calibrations(tank,
					      options.gas,
					      options.id,
					      options.code,
					      selected_date,
					      method=options.method,
					      official=options.official,
					      notes=options.notes,
					      quiet=options.quiet,
					      database=options.database)

		if options.fill:
			print(cals.showFillList(options.format, not options.noheader))
		elif options.average:
			print(cals.showAverages(options.format))
		elif options.summary:
			print(cals.showTankSummary(options.format, not options.noheader))
		elif options.groupfill:
			print(cals.showCalsByFill())
		elif options.table:
			print(cals.showTable())
		else:
			print(cals.showResults(options.format, not options.noheader, options.noflask, options.legacy))
			if options.isotope and options.gas == "CO2": #  or options.gas is None:
				cals = ccg_cal_db.Calibrations(tank, "CO2C13", syslist, options.code, selected_date, quiet=options.quiet, database=options.database)
				print(cals.showResults(options.format, not options.noheader))
				cals = ccg_cal_db.Calibrations(tank, "CO2O18", syslist, options.code, selected_date, quiet=options.quiet, database=options.database)
				print(cals.showResults(options.format, not options.noheader))
