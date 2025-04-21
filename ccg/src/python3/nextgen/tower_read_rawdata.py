

# vim: tabstop=4 shiftwidth=4 expandtab

"""
Read tower raw data files, and store
results into a data dict.

The columns to use are set in a configuration file,
passed in as the 'config' variable.
"""

import os
import sys
import glob
from collections import defaultdict
import numpy as np
import pandas as pd


def find_rawdata_files(stacode, inst, date):
    """ Get a list of rawdata files for the given station code and date """

    rawdir = "/ccg/towers/%s/rawdata/%d/%02d" % (stacode, date.year, date.month)

    if inst == "picx":
        pattern = "%s/%s_pic_%d_%02d_%02d_*.dat" % (rawdir, stacode, date.year, date.month, date.day)
    else:
        pattern = "%s/%s_raw_%d_%02d_%02d_*.dat" % (rawdir, stacode, date.year, date.month, date.day)

    print(pattern)

    # get a list of all the raw files for given date
    files = sorted(glob.glob(pattern))

    return files

def tower_read_rawdata(stacode, inst, date, config, verbose=False):
    """ Read in the tower rawdata files for the given date and station,
    and store data as a dict of lists, each data field a separate dict
    with the list made up of (date, value) tuples.
    """

    files = find_rawdata_files(stacode, inst, date)
    if len(files) == 0:
        if verbose:
            print("No data files found for", stacode, inst, date)
        return None

#    data = defaultdict(list)
    data = {}

    # loop through each file and add the data to the data dict
    for name in files:

        # if there is a .mod file available in addition to the .dat file, use it instead
        modfile = name + ".mod"
        filename = modfile if os.path.exists(modfile) else name

        if verbose: print(filename)

        # sometimes the raw data files is missing the header, which will bomb read_csv
        try:
            ds = pd.read_csv(filename, parse_dates=['TMSTAMP'], skiprows=1, na_values=["INF", "NAN"])
        except:
            if verbose:
                print("Skipping %s because of error." % filename, file=sys.stderr)
            continue
        columns = ds.columns.tolist()
        dates = ds['TMSTAMP'].tolist()
        rawdate = dates[0]
        if type(rawdate) == str:
            print("Skipping %s because of error. Possible mismatch of number of columns" % filename, file=sys.stderr)
            continue
        for fieldname in columns:
            
            # only work on fields that have been specified in the configuration file
            rule = config.find_rule(rawdate, fieldname)   # !!!!! Can't get new rule within a day! ???
            if rule is not None:
                if rule.qcdir not in data:
                    data[rule.qcdir] = ([], [])

                coefs = rule.cf[::-1]
                if rule.use_func:
                    pass    # rule.cf(float(value))
                else:
                    # make a dataframe with date and field
                    df = ds[['TMSTAMP', fieldname]]
                    # drop any NaN from dataframe
                    d = df.dropna()
                    # get remaining dates and values
                    dates = df['TMSTAMP'].tolist()
                    vals = df[fieldname].tolist()
                    # apply scaling coefficients
                    a = np.polyval(coefs, vals)
                    # save dates and values for this qc directory
                    data[rule.qcdir][0].extend(dates)
                    data[rule.qcdir][1].extend(a)
            

#            print(fieldname, rule)

#    for key in data:
#        print(key, len(data[key][0]))
#        print(data[key])

#    sys.exit()

    return data
