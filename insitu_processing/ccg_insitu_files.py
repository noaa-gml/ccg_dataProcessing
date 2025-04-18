# vim: tabstop=4 shiftwidth=4 expandtab

""" functions for reading insitu data files (10 sec avg data files )
Mainly for use with pydv
"""

import os
import sys
import datetime
import glob
import numpy
import pandas as pd


#######################################################
def get_path(path):
    """ return the correcgt directory path depending on platform """

    if sys.platform == "darwin":
        path = "/Volumes" + path

    return path


###########################################################################
def read_insitu(filename):
    """ Read an insitu qc or data file.
    Input:
        filename - filename to read
    Returns:
        numpy array consisting of two columns of data,
            first column is date, as datetime object,
            second column is value as float
    """


    if not os.path.exists(filename):
        return None

    data = []
    with open(filename) as f:
        for line in f:
            a = line.split()
            if ":" in line:  # new format
                (year, month, day) = a[0].split("-")
                (hour, minute, second) = a[1].split(":")
                value = float(a[2])
            else:  # old format
                (year, month, day, hour, minute, second) = a[0:6]
                value = float(a[6])

            date = datetime.datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))
            data.append((date, value))

    if len(data) == 0:
        return None
    else:
        return numpy.array(data)

###########################################################################
def insitu_data_files(stacode, gas, system, year, month):
    """ For specified month, return a list of data files that exist """

    datadir = "/ccg/%s/in-situ/%s/%s/data/%d" % (gas.lower(), stacode.lower(), system.lower(), year)
#    if "LGR" in system:
#        datadir = "/ccg/%s/in-situ/%s_data/lgr/data/%d" % (gas.lower(), stacode.lower(), year)
#    elif "PIC" in system:
#        datadir = "/ccg/%s/in-situ/%s_data/pic/data/%d" % (gas.lower(), stacode.lower(), year)
#    else:
#        datadir = "/ccg/%s/in-situ/%s_data/data/%d" % (gas.lower(), stacode.lower(), year)

    path = datadir + "/%d%02d*.%s" % (year, month, gas.lower())
    path = get_path(path)
    files = glob.glob(path)
    files.sort()

    return files

###########################################################################
def insitu_raw_files(stacode, gas, system, year, month):
    """ For specified month, return a list of data files that exist """

    rawdir = "/ccg/%s/in-situ/%s/%s/raw/%d" % (gas.lower(), stacode.lower(), system.lower(), year)
    path = rawdir + "/%d-%02d-*.%s" % (year, month, gas.lower())
    path = get_path(path)
    files = glob.glob(path)
    files.sort()

    return files

###########################################################################
def qc_filename(stacode, system, date, param):
    """ Determine the qc filename for given station, gas and date.
    The param is a string defining which qc data to use.
    """

    qcfile = "%d-%02d-%02d" % (date.year, date.month, date.day)
    qcdir = "/ccg/insitu/%s/%s/qc/%s/%d" % (stacode, system.lower(), param, date.year)
    qcdir = get_path(qcdir)

    return qcdir + "/" + qcfile


###########################################################################
def insitu_data_files_ng(stacode, gas, system, year, month):
    """ For specified month, return a list of data files that exist """

    datadir = "/ccg/%s/in-situ/%s/%s.nextgen/data/%d" % (gas.lower(), stacode.lower(), system.lower(), year)

    path = datadir + "/%d%02d*.%s" % (year, month, gas.lower())
    path = get_path(path)
    files = glob.glob(path)
    files.sort()

    return files

###########################################################################
def read_insitu_data_files(stacode, files):
    """ read multiple insitu data files (10 second average)
        Return a pandas dataframe
    """

    newstyle = False

    if isinstance(files, str):
        files = [files]

    # assume all files have same format
    df = None
    for filename in files:
        with open(filename) as f:
            data = []
            line = f.readline()
            if len(line) == 0: continue
            f.seek(0)
            if ":" in line:
#                ds = pd.read_csv(filename, sep=r'\s+', parse_dates=[[0, 1]], names=['date', 'time', 'value', 'stdv', 'modenum', 'sample'])
                ds = pd.read_csv(filename, sep=r'\s+', names=['date', 'time', 'value', 'stdv', 'modenum', 'sample'])
                ds['date_time'] = pd.to_datetime(ds.pop('date') + 'T' + ds.pop('time'))
                if df is None:
                    df = ds
                else:
                    df = pd.concat([df, ds], ignore_index=True)

            else:
                for line in f:
                    a = line.split()
                    (year, month, day, hour, minute, second) = a[0:6]
                    date = datetime.datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))
                    value = float(a[6])

                    if len(a) > 9:
                        stdv = float(a[7])
                        mode = int(a[8])
                        inlet = a[9]
                    else:
                        # older style files don't have std. dev. column, and may not have sample column
                        mode = int(a[7])
                        if len(a) >= 9:
                            inlet = a[8]
                        else:
                            inlet = ndir_sample(stacode, date, mode)
                        stdv = 0

                    if inlet == "T": inlet = "TGT"

                    if inlet is not None:
                        t = (date, value, stdv, mode, inlet)
                        data.append(t)

                ds = pd.DataFrame(data, columns=['date_time', 'value', 'stdv', 'modenum', 'sample'])
                df = pd.concat([df, ds], ignore_index=True)

    return df


##################################################################################
def ndir_sample(stacode, dt, mode_num):
    """ Determine gas being measured for co2 ndir systems at the given
    minute and mode number.
    """

    gases = ["TGT", "W3", "W2", "W1"]

    minute = dt.minute

    # old style ndir, line 1 0-25 minutes, line 2 25-45
    if mode_num == 1:
        nwork = nwork_check(stacode.upper(), dt)
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

###########################################################################
def read_insitu_qc(files):
    """ Read an insitu qc file.
    Input:
        filename - filename to read
    Returns:
        pandas dataframe consisting of two columns of data,
            first column is date, as timestamp object,
            second column is value as float
        If filename does not exist, return None
    """

    if isinstance(files, str):
        files = [files]

    df = None
    for filename in files:
        if os.path.exists(filename):
            ds = pd.read_csv(filename, sep=r'\s+', parse_dates=[[0, 1]], names=['date', 'time', 'value'])
            if df is None:
                df = ds
            else:
                df = pd.concat([df, ds], ignore_index=True)

    return df




if __name__ == "__main__":

    x = None
    y = None
    files = insitu_data_files("brw", "n2o", "lgr", 2025, 4)
    t1 = datetime.datetime.now()

    df = read_insitu_data_files("brw", files)
    print(df)
    sys.exit()



    for filename in files:
        data = read_insitu(filename)
        if data is None: continue
        if x is None:
            x = data.T[0]
            y = data.T[1]
        else:
            x = numpy.concatenate((x, data.T[0]))
            y = numpy.concatenate((y, data.T[1]))
#        x.extend(data.T[0].tolist())
#        y.extend(data.T[1].tolist())
    t2 = datetime.datetime.now()
    print("time for reading into arrays", t2-t1)
    print(y)

    files = insitu_data_files("smo", "co2", "ndir", 2024, 9)
    t1 = datetime.datetime.now()
    df = read_insitu_data_files("smo", files)
    t2 = datetime.datetime.now()
    print("time for reading old format files", t2-t1)
    print(df)

    files = insitu_data_files_ng("smo", "co2", "ndir", 2017, 6)
    t1 = datetime.datetime.now()
    df = read_insitu_data_files("smo", files)
    t2 = datetime.datetime.now()
    print("time for reading new format files with pandas", t2-t1)
    print(df)
