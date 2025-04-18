#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab

# Need to include way to handle picarro data, which is in a separate file

"""
read the towers .dat files and create separate text files
for the qc data
"""
from __future__ import print_function

import os
import sys
import argparse
import pandas as pd

from dateutil.parser import parse

import tower_read_rawdata
import ccg_insitu_qc
import ccg_insitu_qc_rules

import datetime

##################################################################################
desctxt = "Read tower .dat files and create separate qc text files. "

parser = argparse.ArgumentParser(description=desctxt)
parser.add_argument('-c', '--config', help="Select non-default configuration file")
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the file with data.")
parser.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")
parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('inst', type=str.lower, help="instrument abbreviation e.g. 'lcr'")
parser.add_argument('date', help="date to process")
options = parser.parse_args()

stacode = options.stacode.lower()
date = parse(options.date)
inst = options.inst

config = ccg_insitu_qc_rules.qcrules(stacode, section='QC', cfgfile=options.config)

t0 = datetime.datetime.now()
data = tower_read_rawdata.tower_read_rawdata(stacode, inst, date, config, verbose=options.verbose)
t1 = datetime.datetime.now()
print(t1-t0)


for key in data:
#    if options.verbose:
#        print(key)

    df = pd.DataFrame(data[key][1], index = data[key][0], columns=[key])

    if options.update:
        qcfile = ccg_insitu_qc.qc_filename(stacode, inst, date, key)
        if options.verbose: print("Writing to", qcfile)


        ccg_insitu_qc.write_insitu_qc(qcfile, df)

    else:
        print(df)

