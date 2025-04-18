# vim: tabstop=4 shiftwidth=4 expandtab
"""
routines for importing data from various differently formatted files.

Settings for reading files are contained in the dataclass ImportData,
and passed in as 'options' to getImportData.

The result is a dict where the key is the name of the dataset, and the
value is a pandas DataFrame.  The DataFrame has only two columns,
the first one has the x axis data, the second has the y axis data.
"""

import os
import sys
from dataclasses import dataclass
import pandas as pd

import ccg_dates

IMPORT_FORMATS = [
            "X Y1 Y2 Y3 ...",
            "CSV with header",
            "CSV without header",
            "Decimal Date (1994.1234) Value ...",
            "Year Month Day Hour Minute Second Value",
            "Year Month Day Hour Minute Value",
            "Year Month Day Hour Value",
            "Year Month Day Value",
            "Year Month Value",
            "Date Time Y1 Y2 Y3 ...",
            "Sta Year Month Day Hour Minute Value",
            "Sta Year Month Day Hour Value",
            "Sta Year Month Day Value",
            "Sta Year Month Value",
            "Sta Year Month Day Hour Minute Line Value",
            "Flask Site File",
            "ObsPack or FTP NetCDF File",
            "FTP Text file for Hourly data",
            "FTP Text file for Daily data",
            "FTP Text file for Monthly data",
            "FTP Text file for Flask Event data",
            "FTP Text file for Flask Monthly data",
            "Y1 Y2 Y3 ...",
            "Type Id Year Month Day Hour Minute Second Val1 Val1_sd Val1_n ..."

#            "Chromatogram File",
#            "Raw File",
#            "Raw File By Sample Type",
#            "Magicc data.gas File"
]

# get an strftime format for date elements that are separated
# by white space.  n is the number of elements in the date
DATE_FORMATS = {
    2: "%Y %m",
    3: "%Y %m %d",
    4: "%Y %m %d %H",
    5: "%Y %m %d %H %M",
    6: "%Y %m %d %H %M %S",
}


@dataclass
class ImportData:
    """ A dataclass for holding options for the data import """

    file_format: str = ""
    filename: str = ""
    skiplines: int = 0
    selectdata: int = 0
    numtype: (str) = ""
    value1: float = 0
    value2: float = 0


########################################################################
def getImportData(options):
    """ get the data from a file

    Args:
        options : An ImportData class

    """

    usecols = None
    header = None
    cvt_date = False
    dc = None

    # dc should be a dict with the key 'date', and a list of column
    # numbers that will be used to create a datetime

    if options.file_format == "X Y1 Y2 Y3 ...":
        pass

    elif options.file_format == "CSV with header":
        header = 0
        r = getImportY(options, csv=True, header=header)
        return r

    elif options.file_format == "CSV without header":
        header = None
        r = getImportY(options, csv=True, header=header)
        return r

    elif options.file_format == "Decimal Date (1994.1234) Value ...":
        cvt_date = True

    elif options.file_format == "Sta Year Month Day Hour Y1 Y2 Y3 ...":
        dc = {"date": [1, 2, 3, 4]}

    elif options.file_format == "Date Time Y1 Y2 Y3 ...":
        dc = {"date": [0, 1]}

    elif options.file_format == "Year Month Day Hour Minute Second Value":
        dc = {"date": [0, 1, 2, 3, 4, 5]}

    elif options.file_format == "Year Month Day Hour Minute Value":
        dc = {"date": [0, 1, 2, 3, 4]}

    elif options.file_format == "Year Month Day Hour Value":
        dc = {"date": [0, 1, 2, 3]}

    elif options.file_format == "Year Month Day Value":
        dc = {"date": [0, 1, 2]}

    elif options.file_format == "Year Month Value":
        dc = {"date": [0, 1]}

    elif options.file_format == "Sta Year Month Day Hour Minute Value":
        dc = {"date": [1, 2, 3, 4, 5]}

    elif options.file_format == "Sta Year Month Day Hour Value":
        dc = {"date": [1, 2, 3, 4]}

    elif options.file_format == "Sta Year Month Day Value":
        dc = {"date": [1, 2, 3]}

    elif options.file_format == "Sta Year Month Value":
        dc = {"date": [1, 2]}

    elif options.file_format == "Sta Year Month Day Hour Minute Line Value":
        dc = {"date": [1, 2, 3, 4, 5]}

    elif options.file_format == "Flask Site File":
        dc = {"date": [1, 2, 3, 4, 5]}
        usecols = [1, 2, 3, 4, 5, 8]

    elif options.file_format == "ObsPack or FTP NetCDF File":
        r = getNetCDF(options)
        return r

    elif options.file_format == "FTP Text file for Hourly data":
        dc = {"date": ['year', 'month', 'day', 'hour']}
        usecols = ['year', 'month', 'day', 'hour', 'value']
        header = 0

    elif options.file_format == "FTP Text file for Daily data":
        dc = {"date": ['year', 'month', 'day']}
        usecols = ['year', 'month', 'day', 'value']
        header = 0

    elif options.file_format == "FTP Text file for Monthly data":
        dc = {"date": ['year', 'month', 'day']}
        usecols = ['year', 'month', 'day', 'value']
        header = 0

    elif options.file_format == "FTP Text file for Flask Event data":
        dc = {"date": ['year', 'month', 'day', 'hour', 'minute', 'second']}
        usecols = ['year', 'month', 'day', 'hour', 'minute', 'second', 'value']
        header = 0

    elif options.file_format == "FTP Text file for Flask Monthly data":
        dc = {"date": [1, 2]}
        usecols = [1, 2, 3]
#        header = 0

    elif options.file_format == "Y1 Y2 Y3 ...":
        r = getImportY(options)
        return r

    elif options.file_format == "Type Id Year Month Day Hour Minute Second Val1 Val1_sd Val1_n ...":
        dc = {"date": [2, 3, 4, 5, 6, 7]}

    r = getImportXY(options, header=header, datecols=dc, usecols=usecols, convert_date=cvt_date)

    return r

    """
    elif format == "X1 Y1 X2 Y2 ...":
        #            getImportXY2 (f filename skiplines selectdata type value)
        r = 0
    elif format == "Chromatogram File":
        r = getImportGC (filename, self.graph)
    elif format == "Magicc data.gas File":
        r = getImportMagicc(filename)
    elif format == "Raw File":
        r = getImportNL(filename, self.graph)
    elif format == "Raw File By Sample Type":
        r = getImportRawByType(filename, self.graph)
    """


##############################################################################
def getImportXY(options, header=None, datecols=None, usecols=None, convert_date=False):
    """get data where first column is time,
    and there are 1 or more following columns of data
    """

    dataset = {}

    # if the date and time columns are separated by space,
    # pandas can't convert to datetime, but rather combines them into
    # one string.  We'll parse the string into a datetime below

    data = pd.read_csv(options.filename,
                       sep=r'\s+',
                       header=header,
                       skiprows=options.skiplines,
                       usecols=usecols,
                       parse_dates=datecols,
                       comment='#')

    # if usecols and datecols are both used, then pandas converts a float column to object.
    # need to fix that here
    if usecols:
        l3 = [x for x in usecols if x not in datecols['date']]
        for col in l3:
            data[col] = pd.to_numeric(data[col])

    # if datecols is set, use the column labeled 'date'
    # check if the date column is a string, and if so, convert to datetime
    # if datecols is not set, then the first numeric column
    # will be used for the x axis
    if datecols is not None:
        xcol = "date"
        if str(data["date"].dtypes) == "object":
            n = len(datecols['date'])
            newdates = pd.to_datetime(data[xcol], format=DATE_FORMATS[n])
            data['date'] = newdates

    else:

        xcol = ""
        for colname, dtype in zip(data.columns, data.dtypes):
            if "object" not in str(dtype):
                xcol = colname
                break

    if xcol == "":
        print("ERROR: No non-string columns in data file.", file=sys.stderr)
        return dataset

    # convert a decimal date to datetime
    if convert_date:
        newdates = [ccg_dates.datetimeFromDecimalDate(x) for x in data[xcol]]
        data[xcol] = pd.Series(newdates)

    # make new dataframe for each numeric column
    for colname in data.columns:
        if colname == xcol:
            continue
        if "object" in str(data.dtypes[colname]):
            continue

        df = check_val(data, xcol, colname, options)

        name = os.path.basename(options.filename) + "_%s" % colname
        dataset[name] = df

    return dataset


##############################################################################
def check_val(data, xname, yname, options):
    """ Create a dataframe from the columns xname, yname, and check that
    the values fall within any limits set by the options.

    Return the new filtered dataframe
    """

    # make a new dataframe with just the two columns
    if xname == "index":
        df = pd.DataFrame({'index': data.index, yname: data[yname]})
    else:
        df = data[[xname, yname]].copy()

    if options.selectdata:

        if options.numtype == "less than":
            df = df[df[yname] < options.value1]

        elif options.numtype == "greater than":
            df = df[df[yname] > options.value1]

        elif options.numtype == "equal to":
            df = df[df[yname] == options.value1]

        elif options.numtype == "not equal to":
            df = df[df[yname] != options.value1]

        elif options.numtype == "less than or equal to":
            df = df[df[yname] <= options.value1]

        elif options.numtype == "greater than or equal to":
            df = df[df[yname] >= options.value1]

        elif options.numtype == "between":
            df = df[(df[yname] >= options.value1) & (df[yname] <= options.value2)]

        elif options.numtype == "not between":
            df = df[(df[yname] < options.value1) | (df[yname] > options.value2)]

    return df


##############################################################################
def getImportY(options, csv=False, header=None):
    """ Get data from a file without an x axis column.

    If csv is True, then columns are separated by ',' instead of white space.
    """

    dataset = {}

    sep = r"\s+"
    if csv:
        sep = ","

    data = pd.read_csv(options.filename,
                       sep=sep,
                       header=header,
                       skiprows=options.skiplines,
                       comment='#')

    for colname in data.columns:
        if "object" in str(data.dtypes[colname]):
            continue

        df = check_val(data, "index", colname, options)

        name = os.path.basename(options.filename) + "_%s" % colname
        dataset[name] = df

    return dataset


##############################################################################
def getNetCDF(options):
    """ read in a netcdf file

    Assumes that variables we want are named

        'time_date' for array of datetimes
        'value' for array of mole fraction values
        'qc flag' for array of text flags
    """

    import ccg_ncdf

    d = ccg_ncdf.read_ncdf(options.filename)
    df = ccg_ncdf.DataFrame(d)

    unflagged = df[df['qcflag'].str[0] == '.']
    flagged = df[df['qcflag'].str[0] != '.']

    dfu = check_val(unflagged, 'time_date', 'value', options)
    dff = check_val(flagged, 'time_date', 'value', options)

    datasets = {}
    if len(dfu) > 0:
        name = os.path.basename(options.filename)
        datasets[name] = dfu

    if len(dff) > 0:
        name = name + ' flagged'
        datasets[name] = dff

    return datasets


if __name__ == "__main__":

    opt = ImportData()
    opt.skiplines = 1
    opt.selectdata = 0
    opt.numtype = "not between"
    opt.value1 = 0
    opt.value2 = 0

    opt.filename = "mloflask.dat"
    opt.file_format = "Date Time Y1 Y2 Y3 ..."

#    opt.filename = "/home/ccg/kirk/brw_ch4_hravg.txt"
#    opt.file_format = "Sta Year Month Day Hour Y1 Y2 Y3 ..."

    opt.filename = "global.dat"
    opt.file_format = "X Y1 Y2 Y3 ..."
    opt.file_format = "Decimal Date (1994.1234) Value ..."
    opt.selectdata = 1
    opt.numtype = "between"
    opt.value1 = 390
    opt.value2 = 400

#    opt.filename = "global.txt"
#    opt.file_format = "Year Month Day Hour Minute Value"

#    opt.filename = "mlo.co2"
#    opt.file_format = "Flask Site File"

#    opt.filename = "../flsel/ARH_ch4_surface_event_NIWA.nc"
#    opt.file_format = "ObsPack or FTP NetCDF File"

#    opt.filename = "/iftp/aftp/data/trace_gases/co2/in-situ/surface/brw/co2_brw_surface-insitu_1_ccgg_DailyData.txt"
    opt.filename = "../grapher/co2_brw_surface-insitu_1_ccgg_DailyData.txt"
    opt.file_format = "FTP Text file for Daily data"
    opt.selectdata = 1
    opt.value1 = 0

#    opt.filename = "tst1.txt"
#    opt.file_format = "Y1 Y2 Y3 ..."

#    opt.filename = "lef_raw_2022_01_16_0200.dat"
#    opt.file_format = "CSV with header"
#    opt.skiplines = 1
#    opt.selectdata = 1
#    opt.value1 = -9e+17
#    opt.numtype = "greater than"

    print(opt)
    d = getImportData(opt)
    print("%%% result %%%")
    for dataset in d:
        print(dataset)
        print(d[dataset])
