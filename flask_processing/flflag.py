#!/usr/bin/env python
"""
#
# Program flflag.py
#
# Read raw flask/qc files and flag data if necessary
#
#
"""

import sys
import argparse

sys.path.insert(1, "/ccg/src/python3/nextgen/")
import ccg_flag


########################################################################

parser = argparse.ArgumentParser(description="Process flask analysis raw files and apply flags to data. ")

group = parser.add_argument_group("Processing Options")
group.add_argument('--rules', help="Specify non-default file name with flagging rules to use. Default is '/ccg/flask/flagrules.dat'")
group.add_argument('--devdb', action="store_true", default=False, help="Use mund_dev database for checks and updates.  This is for development purposes.")

group = parser.add_argument_group("Output Options")
group.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with those in database.")
group.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with calculated values from file.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")
group.add_argument('-t', '--table', action="store_true", default=False, help="Print a table of values")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")

parser.add_argument('rawfile', nargs='*')

options = parser.parse_args()

# Process the files specified on the command line
for filename in options.rawfile:

	# Create flag class
	flflag = ccg_flag.Flag(filename, rulefile=options.rules, devdb=options.devdb, debug=options.debug)
	if flflag.valid is False:
		continue

	# Process depending on option
	if   options.update:   flflag.updateDb(devdb=options.devdb, verbose=options.verbose)
	elif options.check:    flflag.checkDb(devdb=options.devdb, verbose=options.verbose)
	elif options.table:    flflag.printTable()
	else: flflag.printResults()
