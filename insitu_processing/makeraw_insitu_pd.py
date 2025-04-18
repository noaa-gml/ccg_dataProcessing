#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
#
# Program ndir_insitu_makeraw.py
#
# Create co2 raw in-situ files
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
def make_avg(values, gas_, dt, modenum):
    """ compute the average of the 10 sec voltages """

    average = numpy.mean(values)
    if len(values) > 1:
        std = numpy.std(volts, ddof=1)
    else:
        std = 0.0
    nv = len(volts)
    flg = "."
    smptype = sample_type(gas_)

    return (smptype, gas_, dt, average, std, nv, flg, modenum)


##################################################################################
def ndir_sample(stacode, dt, mode_num):
    """ Determine gas being measured for co2 ndir systems at the given
    minute and mode number.
    """

    gases = ["TGT", "W3", "W2", "W1"]

    minute = dt.minute

    # old style ndir, line 1 0-25 minutes, line 2 25-45
    if mode_num == 1:
        nwork = nwork_check(stacode, dt)
        if nwork == 3:
            if minute < 25:
                sample = "Line1"
            elif minute < 45:
                if dt.year <= 2013:    # didn't separate lines before 2014
                    sample = "Line1"
                else:
                    sample = "Line2"
            elif minute < 50:
                sample = "W3"
            elif minute < 55:
                sample = "W2"
            else:
                sample = "W1"
        else:
            if minute < 50:
                sample = "Line1"
            elif minute < 55:
                sample = "W2"
            else:
                sample = "W1"

    # need to handle mode 2 (weekly cal) for old data files
    elif mode_num == 2:
        sample = None

    # target cal
    elif mode_num == 3:
        n = (minute // 5) % 4
        sample = gases[n]

    return sample

##################################################################################
def check_gas_change(stacode, dt):
    """ Check if we want to switch on 5 minute intervals.
    This is for sites with new style response curve method of measurements,
    i.e. lgr, picarro, ndir (starting in 2018 at spo)
    """

    if stacode == "SPO" and dt >= datetime.datetime(2018, 1, 21, 0, 0, 0): return True
    if stacode == "MLO" and dt >= datetime.datetime(2019, 4, 10, 22, 35, 0): return True
    if stacode == "BRW" and dt >= datetime.datetime(2013, 4, 11, 0, 25, 0): return True
    if stacode == "SMO" and dt >= datetime.datetime(2022, 1, 14, 0, 0, 0): return True

    if stacode == "LEF": return True
    if stacode == "CAO": return True
    if stacode == "MKO": return True

    return False

##################################################################################
def nwork_check(stacode, dt):
    """
    Determine which working gases were used.
    """

    ntnks = 2
    dd = dt.year*1000000 + dt.month*10000 + dt.day*100 + dt.hour
    if stacode == "SMO" and dd >= 2002050700: ntnks = 3
    if stacode == "SPO" and dd >= 2002020700: ntnks = 3
    if stacode == "BRW" and dd >= 2003071600: ntnks = 3
    if stacode == "MLO" and dd >= 2003110500: ntnks = 3

    return ntnks

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

    rows = []

    try:
        f = open(datafile)
    except (OSError, IOError) as err:
        print("Can't open file", datafile, err, file=sys.stderr)
        return None

    # read first line and check for a ':'
    line = f.readline()
    if ':' in line:
        f.close()
        ds = pd.read_csv(datafile, delim_whitespace=True, parse_dates=[[0,1]], names=['date', 'time', 'value', 'stdv', 'modenum', 'sample'])
        return ds

    f.seek(0)
    for line in f:
        a = line.split()
        year = int(a[0])
        month = int(a[1])
        day = int(a[2])
        hour = int(a[3])
        minute = int(a[4])
        second = int(a[5])
        date_ = datetime.datetime(year, month, day, hour, minute, second)
        value = float(a[6])
        if value < -1e10: continue

#        if check_gas_change(stacode, date_):
        if len(a) > 9:
            stdv = float(a[7])
            mode_num = int(a[8])
            sample = a[9]
        else:
            # older style files don't have std. dev. column, and may not have sample column
# skip for now
#            continue
            mode_num = int(a[7])
            if len(a) >= 9:
                sample = a[8]
            else:
                sample = ndir_sample(stacode, date_, mode_num)
            stdv = 0

        if sample == "T": sample = "TGT"

        if sample is not None:
            rows.append((date_, value, stdv, mode_num, sample))

    f.close()

    ds = pd.DataFrame(rows, columns=['date_time', 'value', 'stdv', 'modenum', 'sample'])

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
#parser.add_argument('file', help="data file to process")
parser.add_argument('files', nargs='+', help="data files to process")

options = parser.parse_args()

# check station code
station = options.stacode.upper()
if station not in ("BRW", "MLO", "SMO", "SPO", "AMT", "CRV", "LEF", "SCT", "CAO", "MKO"):
    print("Bad station code", station, file=sys.stderr)
    sys.exit()

config = ccg_insitu_config.InsituConfig(station, options.gas, options.instrument)

FIVE_MINUTES = datetime.timedelta(minutes=5)

for filename in options.files:

    rawdata = []
    prev_date = None
    volts = []
    prev_5min_gas = None

#    filename = options.file
    ds = read_data(station, filename)
#    print(ds)

    #if not ds: sys.exit()


    # row will contain row.date_time, row.value, row.stdv, row.mode, row.sample
    for row in ds.itertuples():
        if row.value < -1e10: continue

        time_switch = check_gas_change(station, row.date_time)

        flushtime = get_flush_time(config, row.sample, row.date_time)

        if prev_date is None:
            prev_date = row.date_time
            prev_sample = row.sample
            prev_mode = row.modenum
            prev_stdv = row.stdv
            prev_block = (row.date_time.hour*60 +row.date_time.minute) // 5
    #        prev_5min_gas = gas

        # if gas has changed, calculate average for the previous gas
    #    if (gas != prev_gas or (time_switch and date.minute % 5 == 0)) and len(volts) > 0:
    #    if (gas != prev_gas or (time_switch and date.minute % 5 == 0)):
#        print(row.date_time, prev_date, row.date_time-prev_date)
#        t = row.date_time.hour*60 +row.date_time.minute
        block5 = (row.date_time.hour*60 +row.date_time.minute) // 5
#        print(row.date_time, t, block5)
        if (row.sample != prev_sample
            or (time_switch and block5 != prev_block)
#            or (time_switch and row.date_time-prev_date >= datetime.timedelta(minutes=5))
#            or (time_switch and row.date_time.minute % 5 == 0 and row.date_time.second == 0)
#            or (row.modenum == 2 and row.date_time-prev_date >= datetime.timedelta(minutes=5))):
            ):
    #        print("#####", gas, prev_gas)
            if len(volts) > 0:
                mydt = prev_date.replace(second=0)
                data = make_avg(volts, prev_sample, mydt, prev_mode)
                if len(volts) == 1:
                    t = list(data)
                    t[4] = prev_stdv
                    data = tuple(t)
                rawdata.append(Row._make(data))

            volts = []
            prev_date = row.date_time  # start of new gas or 5 minute period
            prev_5min_gas = prev_sample
            prev_block = block5

        # skip first 3 minutes of gas for flushing of previous gas
    #    if date.minute - prev_date.minute >= 3:


        td = row.date_time - prev_date
        total_seconds = (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6
    #    print(date, prev_date, total_seconds, gas, prev_gas, prev_5min_gas)
    #    if (date - prev_date).total_seconds() >= FLUSHTIME:
    #    if total_seconds >= flushtime or row.sample == prev_5min_gas:
        if total_seconds >= flushtime:
    #        print("!!!!!!!!!!!!!")
            volts.append(row.value)

        # remember the values for next time through loop
        prev_sample = row.sample
        prev_mode = row.modenum
        prev_stdv = row.stdv

    # handle remaining data
    if len(volts) > 0:
        mydt = prev_date.replace(second=0)
        data = make_avg(volts, prev_sample, mydt, prev_mode)
        if len(volts) == 1:
            t = list(data)
            t[4] = prev_stdv
            data = tuple(t)
        rawdata.append(Row._make(data))


    if options.update:
        if len(rawdata) > 0:
            date = rawdata[0].date
            dirname = "/ccg/%s/in-situ/%s/%s/raw/%d" % (options.gas.lower(), options.stacode.lower(), options.instrument.lower(), date.year)

            filename = "%s/%d-%02d-%02d.%s" % (dirname, date.year, date.month, date.day, options.gas.lower())
            if options.verbose: print(filename)

            if not os.path.exists(dirname):
                os.makedirs(dirname)

            f = open(filename, "w")
    else:
        f = sys.stdout

    # print out raw lines
    format1 = "%-3s %6s %s %12.5e %9.3e %3d %1s %1d"
    for row in rawdata:
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

    if options.update:
        if len(rawdata) > 0:
            f.close()
