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
import ccg_insitu_files


##################################################################################
def sample_type(gas_):
    """ Get the sample type for the given label of the gas """

    refgases = ["W1", "W2", "W3"]
    standards = ["S1", "S2", "S3", "S4", "S5", "S6", "C1", "C2", "C3", "C4", "L", "M", "H", "Q", "Y1", "Y2", "Y3"]

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
def get_flush_time(cfg, smptype_, dt):
    """ Get the flushing time from the configuration file """

    if smptype_ == "SMP":
        flushtime = cfg.get('smp_flush_time', dt)
    else:
        flushtime = cfg.get('cal_flush_time', dt)

    return int(flushtime)


##################################################################################
def average_data(raw):
    """ average the data only when sample changes, not on 5 minute blocks """

    data = []

    # make a dataframe from saved data
    df = pd.DataFrame(raw)

    # get row numbers where label changes
    i = 0
    prev_label = None
    rownums = []
    for row in df.itertuples():
        if row.label != prev_label:
            rownums.append(i)
            prev_label = row.label
        i = i + 1
    rownums.append(df['label'].count())
    for i, n in enumerate(rownums[0:-1]):
        j = rownums[i+1]
        r = df.iloc[n:j]
        date = r['date'].iloc[0].to_pydatetime()
        start_minute = (date.minute // 5) * 5
        date = date.replace(minute = start_minute, second=0)
        t = average_df(date, r)
        data.append(Row._make(t))
        
    return data

##################################################################################
def average_df(dt, df):
    """ for a given dataframe, calculate the average, standard deviation and n
    of the 'value' column.
    The dataframe should have the same values for the sample type, 
    sample label and mode number.
    Return a tuple with needed information
    """


    # filter out any readings that happen to cross over to next 5 minute block (bug fix).
    # this can happen if picarro output value falls exactly on 5 minute time.  It would have
    # the label from the previous 5 minute block
    label = df['label'].iloc[-1]
    df = df[df['label'] == label]

    # save averaged data for each 5 minute block
    smptype = df['smptype'].iloc[0]
    sample = df['label'].iloc[0]
    modenum = df['mode'].iloc[0]
    flag = df['flag'].iloc[0]

    avg = df['value'].mean()
    std_dev = df['value'].std()
    if numpy.isnan(std_dev):
        std_dev = df['std'][0]
#        std_dev = 0
    n = df['value'].count()

    return (smptype, sample, dt, avg, std_dev, n, flag, modenum)


##################################################################################


names = ["smptype", "label", "date", "value", "std", "n", "flag", "mode"]
Row = namedtuple('raw', names)

desctxt = "Read an insitu data file and print out averaged raw data. "

parser = argparse.ArgumentParser(description=desctxt)
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the file with data.")
parser.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output for some options")
parser.add_argument('-n', '--noavg', action="store_true", default=False, help="Do not average into 5 minute values.")
parser.add_argument('--nosplit', action="store_true", default=False, help="Do not split data into 5 minute values. Use one average for sample, no matter how long.")

parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="Gas to work with, e.g. co2, ch4...")
parser.add_argument('instrument', help="Instrument abbreviation, e.g. pic, lgr, lcr")
parser.add_argument('files', nargs='+', help="data files to process")

options = parser.parse_args()

# check station code
station = options.stacode.upper()
#if station not in ("AMT", "CRV", "LEF", "SCT", "CAO", "BRW", "MLO", "SMO", "SPO", "MKO", "WKT", "WBI"):
#    print("Bad station code", station, file=sys.stderr)
#    sys.exit()

towersite = False
if station not in ("BRW", "MLO", "MKO", "SMO", "SPO", "CAO"):
    towersite = True

config = ccg_insitu_config.InsituConfig(station, options.gas, options.instrument)


for filename in options.files:

    rawdata = []
    volts = []

#    ds = read_data(station, filename)
    ds = ccg_insitu_files.read_insitu_data_files(station, filename)
#    if ds is None: continue
    if ds.size == 0: continue

    #------------------------
    # First step is to skip data that is inside the flushing time after a sample change

    prev_date = ds['date_time'].iloc[0]
    prev_sample = ds['sample'].iloc[0]
    prev_block = (prev_date.hour*60 + prev_date.minute) // 5

    # row will contain row.date_time, row.value, row.stdv, row.mode, row.sample
    for row in ds.itertuples():
        if row.value < -1e10: continue

        block5 = (row.date_time.hour*60 +row.date_time.minute) // 5

        if (row.sample != prev_sample):
#            or (station == "SMO" and block5 != prev_block)):    # make this compatible with older scripts

            rawdata.extend([Row._make(v) for v in volts])

            volts = []
            prev_date = row.date_time  # start of new gas or 5 minute period
            prev_block = block5

        # only keep data after the flush time since sample started
        smptype = sample_type(row.sample)
        flushtime = get_flush_time(config, smptype, row.date_time)
        td = row.date_time - prev_date
        total_seconds = td.total_seconds()
        if total_seconds >= flushtime:
            t = (smptype, row.sample, row.date_time, row.value, row.stdv, 1, ".", row.modenum)
            volts.append(t)

        # remember the values for next time through loop
        prev_sample = row.sample

    # handle remaining data
    for v in volts:
        rawdata.append(Row._make(v))


    if len(rawdata) == 0:
        continue

#    print(rawdata)
    # if not splitting into 5 minute blocks then average the data differently, by sample
    if options.nosplit:
        rawdata = average_data(rawdata)

    else:
        #------------------------
        # Second step is to create 5 minute averages

        # don't average data if noavg option set.  This is to make raw files for towers 30 second averages (testing)
        if not options.noavg:

            # make a dataframe from saved data
            df = pd.DataFrame(rawdata)

            # resample data to 5 minute blocks
            rawdata = []
            df2 = df.set_index('date')
            r = df2.resample("5min")

            # for each 5 minute block, get the average, std, n of the available readings
            for date, df in r:
                if df.empty:
                    continue

#                print(df)
                t = average_df(date, df)
                # sometimes a single TGT reading will get set into the start of a 5 minute block,
                # which messes up the database updates.  Skip those here.
                if t[5] > 1 or towersite:
                    rawdata.append(Row._make(t))

    #------------------------
    # Third step is to save results

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
                if f: f.close()
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
