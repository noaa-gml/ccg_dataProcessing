#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
#
# Program flag_insitu.py
#
# Automatic flagging of insitu raw files
# 
"""
from __future__ import print_function

import sys
import argparse

sys.path.append("/ccg/src/python3/nextgen")
import ccg_insitu_raw
import ccg_insitu_flag


epilogtxt = """System overlap occurs for CO2 only at BRW April 11, 2013
- December 31, 2016 and MLO April 10, 2019 - May 31, 2019"""
desctxt = "Flag raw data based on qc data. "

parser = argparse.ArgumentParser(description=desctxt, epilog=epilogtxt)

parser.add_argument('-u', '--update', action="store_true", help="Update the raw files with new flags.")
parser.add_argument('--rules', metavar='rulesfile', help="Specify non-default file name with flagging rules to use.")
parser.add_argument('--system', type=str.lower, help="Specify system to use during overlap periods.")
parser.add_argument('--replaceflag', action="store_true", help="Remove manually applied flags and replace with automatic flags.")
parser.add_argument('--debug', action="store_true", help="Print debugging information while processing.")
parser.add_argument('-v', '--verbose', action="store_true", help="Print extra information while processing.")
parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="Gas formula, e.g. CO2")
parser.add_argument('files', nargs='*', help="raw files to process")

options = parser.parse_args()

# check station code
station = options.stacode.upper()
#if station not in ("BRW", "MLO", "SMO", "SPO", "LEF", "SCT", "CAO", "MKO", "BND", "WKT", "AMT", "WBI"):
#    print("Bad station code", station, file=sys.stderr)
#    sys.exit()


filenames = options.files

for filename in options.files:
    if options.verbose:
        print("Working on", filename)

    raw = ccg_insitu_raw.InsituRaw(station, options.gas, filename, system=options.system)
    if not raw.valid: continue

    if options.system is not None:
        system = options.system
    else:
        system = raw.method
        if system is None:
            sys.exit("Unknown system type.  Use --system option.")

    # call auto flagging here
    qc = ccg_insitu_flag.Flag(station, options.gas, system=system, rulefile=options.rules, debug=options.debug)
    qc.apply_flags(raw, options.replaceflag)
#    print(raw.data)

    if options.update:
        # don't need to update if no flagging was done
#        if qc.modified:
        raw.update(filename)

    else:
        raw.printRaw()
