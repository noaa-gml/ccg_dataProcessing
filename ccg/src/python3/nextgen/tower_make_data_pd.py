#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab

"""
read the towers .dat file and create separate text files
for the analyzer output data
"""
from __future__ import print_function

import os
import sys
import argparse
import fnmatch

from dateutil.parser import parse

import tower_read_rawdata_pd
import ccg_insitu_qc_rules
import ccg_insitu_qc
import ccg_insitu_config


##################################################################################
def tower_assign_syscode(df, cfg):
    """ Convert the sysmode number to a syscode string.

    The conversion is done using settings in the configuration file for
    'sysmodes' and 'syscodes'
    'sysmodes' is a space separated string with wildcards that will match the sysmode number
    'syscodes' is a corresponding character string for the sysmode
    For example:
        sysmodes = 11?? 12?? 13?? 14?? 15?? 21?? 22?? 23??
        syscodes = C1   C2   C3   C4   T1   L2   L4   L6

    So a sysmode number of 2323 will match 23?? for a syscode of L6
    """

    codes = []

    for row in df.itertuples():
        sysmodes = cfg.get("sysmodes", row.Index).split()
        syscodes = cfg.get("syscodes", row.Index).split()

        syscode = "??"  # default
        # check if sysmode matches any of the given sysmode patterns
        for code, mode in zip(syscodes, sysmodes):
            if fnmatch.fnmatch(str(int(row.sysmode)), mode):
                syscode = code
                break

        codes.append(syscode)

    return codes


##################################################################################
desctxt = "Read tower .dat files and create separate analyzer output data text files. "

parser = argparse.ArgumentParser(description=desctxt)
parser.add_argument('-c', '--config', help="Select non-default configuration file")
parser.add_argument('-q', '--qcconfig', help="Select non-default qc configuration file")
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the file with data.")
parser.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")

parser.add_argument('stacode', type=str.lower, help="3 letter station code")
parser.add_argument('gas', type=str.lower, help="gas e.g. 'co2'")
parser.add_argument('inst', type=str.lower, help="instrument abbreviation e.g. 'lcr'")
parser.add_argument('date', help="date to process")
options = parser.parse_args()

# required options
stacode = options.stacode
gas = options.gas
date = parse(options.date)

# get configuration settings
config = ccg_insitu_config.InsituConfig(stacode, gas, system=options.inst, configfile=options.config)
qcconfig = ccg_insitu_qc_rules.qcrules(stacode, gas=gas, inst=options.inst, section='DATA', cfgfile=options.qcconfig)

# read tower .dat file and return a pandas dataframe
data = tower_read_rawdata_pd.tower_read_rawdata(stacode, options.inst, date, qcconfig, verbose=options.verbose)
if data is None or 'data' not in data.columns:
    if options.verbose:
        print("No", gas, "data found for", options.date)
    sys.exit()

# convert the sysmodes number to syscode string
data['inlet'] = tower_assign_syscode(data, config)
data['mode'] = 1

_format = "%s %12.5e %12.5e %d %s"

if options.update:
    outfile = ccg_insitu_qc.data_filename(stacode, options.inst, date, gas)
    if options.verbose: print("Writing to", outfile)

    ccg_insitu_qc.write_insitu_data(outfile, data)

else:
    if options.verbose:
        for row in data.itertuples():
            print(row)
    else:
        print(data)
