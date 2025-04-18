
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Functions for handling in-situ qc data.
"""

import os
import datetime
import pandas as pd

###########################################################################
def read_insitu_qc(filename):
    """ Read an insitu qc file.
    Input:
        filename - filename to read
    Returns:
        pandas dataframe consisting of two columns of data,
            first column is date, as timestamp object,
            second column is value as float
        If filename does not exist, return None
    """

#    print("filename is", filename)
    if not os.path.exists(filename):
        return None

    df = pd.read_csv(filename, delim_whitespace=True, parse_dates=[[0, 1]], names=['date', 'time', 'value'])
    df = df.dropna()

    if len(df) == 0:
        return None
#    print("df is", df)


    return df

###########################################################################
def write_insitu_qc(filename, df):
    """ Write qc data to file from the given pandas dataframe

    The dataframe df must have the dates as the index.
    """

    _format = "%s %12.5e"

    outdir = os.path.dirname(filename)
    if not os.path.exists(outdir):
        os.makedirs(outdir)

    fp = open(filename, "w")

    for row in df.itertuples():
        print(_format % (row.Index, row[1]), file=fp)

    fp.close()


###########################################################################
def get_qc_avg(data, startdate, enddate):
    """ Get statistics on qc data between given start and end dates """

    df = data[(data['date_time'] >= startdate) & (data['date_time'] < enddate)]
    minval = df.value.min()
    maxval = df.value.max()
    average = df.value.mean()
    stdv = df.value.std()
    n = df.shape[0]

    return (minval, maxval, average, stdv, n)

###########################################################################
def qc_filename(stacode, system, date, param):
    """ Determine the qc filename for given station, gas and date.
    The param is a string defining which qc data to use.
    """

    qcfile = "%d-%02d-%02d" % (date.year, date.month, date.day)
    qcdir = "/ccg/insitu/%s/%s/qc/%s/%d" % (stacode, system.lower(), param, date.year)
    return qcdir + "/" + qcfile

###########################################################################
def read_insitu_data(filename):
    """ Read an insitu data file.
    Input:
        filename - filename to read
    Returns:
        pandas dataframe consisting of two columns of data,
            first column is date, as timestamp object,
            second column is value as float
            third column is value standard deviation as float
            fourth column is mode number as integer
            fifth column is sample label as string
        If filename does not exist, return None
    """

#    print("filename is", filename)
    if not os.path.exists(filename):
        return None

    df = pd.read_csv(filename, delim_whitespace=True, parse_dates=[[0,1]], names=['date', 'time', 'value', 'stdv', 'modenum', 'sample'])

    if len(df) == 0:
        return None
#    print("df is", df)
    df = df.set_index('date_time')

    return df

###########################################################################
def write_insitu_data(filename, df):
    """ Write analyzer output data to file from the given pandas dataframe

    The dataframe df must have the dates as the index.
    """

    _format = "%s %12.5e %12.5e %1d %s"

    outdir = os.path.dirname(filename)
    if not os.path.exists(outdir):
        os.makedirs(outdir)

    fp = open(filename, "w")

    for row in df.itertuples():
#        print(_format % (row.Index, row[1], row[2], row[3], row[4]), file=fp)
        print(_format % (row.Index, row.value, row.stdv, row.modenum, row.sample), file=fp)

    fp.close()


###########################################################################
def data_filename(stacode, system, date, param):
    """ Determine the data filename for given station, gas and date.
    The param is a string defining which qc data to use.
    """

    datafile = "%d%02d%02d.%s" % (date.year, date.month, date.day, param.lower())
    datadir = "/ccg/%s/in-situ/%s/%s/data/%d" % (param.lower(), stacode.lower(), system, date.year)
    return datadir + "/" + datafile
