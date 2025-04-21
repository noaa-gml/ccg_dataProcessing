#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
#
# Program makeraw_insitu_pd_tower.py
#
# Create raw in-situ files
# for tower sites, keeping 30 second value instead of averaging to 5 minute values
# Make raw files from data files.
#
# Prints formatted raw data to stdout.
#
"""
from __future__ import print_function

import os
import sys
import argparse
import datetime
from collections import namedtuple
import numpy
import pandas as pd

import ccg_insitu_config


##################################################################################
def sample_type(gas_):

    refgases = ["W1", "W2", "W3"]
    standards = ["S1", "S2", "S3", "S4", "S5", "S6", "C1", "C2", "C3", "C4", "L", "M", "H", "Q"]

    if gas_ == "R0":
        smptype = "REF"
    elif "T" in gas_:
        smptype = "TGT"
    elif gas_ in standards:
        smptype = "STD"
    elif gas_ not in refgases:
        smptype = "SMP"
    else:
        smptype = "REF"

    return smptype


##################################################################################
def get_flush_time(cfg, gas, dt):

    smptype = sample_type(gas)

    if smptype == "SMP":
        flushtime = cfg.get('smp_flush_time', dt)
    else:
        flushtime = cfg.get('cal_flush_time', dt)

    return int(flushtime)
    
##################################################################################
def read_data(stacode, datafile):
    """ Read in the insitu 'data' files, which are 10 second average output
    from the analyzer.
    """

    ds = pd.read_csv(datafile, delim_whitespace=True, parse_dates=[[0,1]], names=['date', 'time', 'value', 'stdv', 'modenum', 'sample'])
    return ds


##################################################################################


names = ["smptype", "label", "date", "value", "std", "n", "flag", "mode"]
Row = namedtuple('raw', names)

desctxt = "Read an insitu data file and print out averaged raw data. "

parser = argparse.ArgumentParser(description=desctxt)
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the file with data.")
parser.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")

parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="Gas to work with, e.g. co2, ch4...")
parser.add_argument('instrument', help="Instrument abbreviation, e.g. pic, lgr, lcr")
parser.add_argument('files', nargs='+', help="data files to process")

options = parser.parse_args()

# check station code
station = options.stacode.upper()
if station not in ("AMT", "CRV", "LEF", "SCT"):
    print("Bad station code", station, file=sys.stderr)
    sys.exit()

config = ccg_insitu_config.InsituConfig(station, options.gas, options.instrument)


for filename in options.files:

    rawdata = []
    prev_date = None
    volts = []

    ds = pd.read_csv(filename, delim_whitespace=True, parse_dates=[[0,1]], names=['date', 'time', 'value', 'stdv', 'modenum', 'sample'])
#    print(ds)

    #if not ds: sys.exit()


    # row will contain row.date_time, row.value, row.stdv, row.mode, row.sample
    for row in ds.itertuples():
        if row.value < -1e10: continue

        flushtime = get_flush_time(config, row.sample, row.date_time)

        if prev_date is None:
            prev_date = row.date_time    # beginning time of sample
            prev_sample = row.sample

        if (row.sample != prev_sample):
            for v in volts:
#                print(v)
                rawdata.append(Row._make(v))

            volts = []
            prev_date = row.date_time  # start of new gas or 5 minute period

        td = row.date_time - prev_date
        total_seconds = (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6
        if total_seconds >= flushtime:
            smptype = sample_type(row.sample)
            t = (smptype, row.sample, row.date_time, row.value, row.stdv, 1, ".", row.modenum)
            volts.append(t)

        # remember the values for next time through loop
        prev_sample = row.sample

    # handle remaining data
    for v in volts:
#        print(v)
        rawdata.append(Row._make(v))


    format1 = "%-3s %6s %s %12.5e %9.3e %3d %1s %1d"
    if options.update:

        prev_date = None
        f = None
        for row in rawdata:
            date = row.date.date()
            if date != prev_date:
                dirname = "/ccg/%s/in-situ/%s/%s/raw/%d" % (options.gas.lower(), options.stacode.lower(), options.instrument.lower(), date.year)
                filename = "%s/%d-%02d-%02d.%s" % (dirname, date.year, date.month, date.day, options.gas.lower())
                if options.verbose: print(filename)
                if not os.path.exists(dirname):
                    os.makedirs(dirname)
                if f: close(f)
                f = open(filename, "w")
                
            print(format1 % (row.smptype,
                     row.label,
                     row.date.strftime("%Y-%m-%d %H:%M:%S"),
                     row.value,
                     row.std,
                     row.n,
                     row.flag,
                     row.mode,
                    ), file=f
            )
            prev_date = date


    else:
        # print out raw lines
        for row in rawdata:
            print(format1 % (row.smptype,
                     row.label,
                     row.date.strftime("%Y-%m-%d %H:%M:%S"),
                     row.value,
                     row.std,
                     row.n,
                     row.flag,
                     row.mode,
                    )
            )

    if options.update:
        if f:
            f.close()
