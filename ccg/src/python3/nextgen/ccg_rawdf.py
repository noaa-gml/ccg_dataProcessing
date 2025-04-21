
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for reading raw files; flask, cals, nl.

This version takes a raw file name, then finds any qc
raw files associated with it, and creates a pandas dataframe
for all the data.

A data raw file has lines that look like
REF  R0          2018 10 25 16 11 11 3.317760e+02 1.000e-01    26 .
for non GC systems, and
STD  S2          2014 04 25 11 18 00 1.001271e+07 1.056290e+08  85.4 .   BF
for GC systems.

The columns are
    sample type, sample id/event, year, month, day, hour, minute, second, value, value_std, n, flag
for non GC, and
    sample type, sample id/event, year, month, day, hour, minute, second, peak_height, peak_area, retention time, flag, baseline code
for GC systems.


"""
from __future__ import print_function

import os
import sys
import datetime
from collections import namedtuple
import numpy
import pandas as pd

import ccg_dates
import ccg_flaskdb


class Rawfile():
    """ Class for reading raw files

        The raw file can be either a data raw file or a qc raw file.

        Usage
        raw = Rawfile(filename)

        Args:
        filename : name of raw file to read

        Attributes:
        rawlines : list of list of values for the data part of the raw file
        data : numpy 2d array with processed data.  There is one row for each line of data.
            For data raw files, each row contains
            [stype, event, dt, val1, val2, val3, flag, bc]
            types for each column are
            (str, str, datetime, float, float, float, str, str)
            For qc raw files, each row contains
            [stype, event, dt, val1, val2, val3, ...]
            depending on how many fields are in the qc file.
        numrows : integer count of number of rows in data
        info : dict of header information
        stds : list of tank labels used in the calibration
        column_names : list of short names for each column in data array
        column_titles : list of long names for each column in data array
        refid : label of first 'REF' sample, excluding 'Z'

        Methods
        Use pydoc to view public methods

    """

    def __init__(self, filename, project, debug=False):

        self.debug = debug
        self.filename = filename
        self.info = {}
        self.column_names = []
        self.method = None
        self.data = None
        self.refid = None
        self.valid = False
        self.instid = None
        self.method = None
        self.numrows = 0

        self.info, rawlines = self._read_file(filename)
        if self.info:
            self.valid = True

        if not self.valid:
            return

        self.species = self.info["Species"].lower()
        self.system = self.info["System"].split()[0]
        self.instid = self.info["Instrument"].split()[0]
        self.method = self.info["Method"]
        self.adate = ccg_dates.getDatetime(self.info["Date"])
        self.idate = ccg_dates.intDate(self.adate.year, self.adate.month, self.adate.day, self.adate.hour)

#        if self.info["Sample type"] in ["flask", "pfp"]:
#            self.rawtype = "flask"
#        else:
#            self.rawtype = self.info["Sample type"]
        self.rawtype = project

        # parse raw data lines
        df, titles = self._get_raw_data(rawlines)

        # find gas specific qc file, read and parse data
        qcdir = "/ccg/%s/%s/%s/qc/%d" % (self.species, self.rawtype, self.system.lower(), self.adate.year)
        if sys.platform == "darwin":
            qcdir = "/Volumes" + qcdir
        qcfile = "/".join([qcdir, os.path.basename(filename) + ".qc"])
        qcinfo, qcrawlines = self._read_file(qcfile)
#        print(qcfile)
#        print(qcinfo)
#        print(qcrawlines)
        if len(qcrawlines) > 0:
            dfqc, qctitles = self._get_qc_data(qcinfo, qcrawlines)
            if dfqc is not None:
                df = pd.concat([df, dfqc], axis=1)
                titles = titles + qctitles


        # find system qc file.  Only magicc-3 uses this
        if self.system == "magicc-3":
            qcdir = "/ccg/magicc-3_qc/%s/%d" % (self.rawtype, self.adate.year)
            if sys.platform == "darwin":
                qcdir = "/Volumes" + qcdir
            qcfile = os.path.basename(filename)
            qcfile = qcfile.replace(self.instid.lower(), "magicc-3")
            qcfile = qcfile.replace(self.species, "qc")
            qcfile = "/".join([qcdir, qcfile])
            qcinfo, qcrawlines = self._read_file(qcfile)
            dfqc2, qctitles2 = self._get_qc_data(qcinfo, qcrawlines)
            if dfqc2 is not None:
                df = pd.concat([df, dfqc2], axis=1)
                titles = titles + qctitles2


        # for flask data we'll also include mole fraction and sample data
        if self.rawtype == "flask":
            events = [int(line.event) for line in df.itertuples() if line.smptype == "SMP"]
            fdb = ccg_flaskdb.Flasks(events, self.species)
            a = []
            for row in df.itertuples():
                if row.smptype == "SMP":
                    mdata = fdb.measurementData(row.event, self.species, row.date)
                    s = fdb.sampleData(row.event)
                    if mdata is None:
                        print("Mole fraction value for %s, event %s not found." % (self.species, row.event))
                        continue
                    t5 = (mdata['value'], mdata['qcflag'], s['code'], s['date'], s['flaskid'], s['method'], s['strategy_num'], s['latitude'], s['longitude'], s['altitude'])
# for when ccg_flaskdb2.py is the official version
#                    t5 = (mdata['value'], mdata['qcflag'], mdata['unc'], mdata['meas_unc'], s['code'], s['date'], s['flaskid'], s['method'], s['strategy_num'], s['latitude'], s['longitude'], s['altitude'])
                else:
#                    t5 = (-999.99, "...", 'XXX', row.date, row.event, 'None', 'None', 'None', 'None')
#                    t5 = (-999.99, "...", 'XXX', row.date, row.event, 'None', -999, -999, -999)
                    # pandas will convert None to NaN
                    t5 = (-999.99, "...", 'XXX', row.date, row.event, 'None', 'None', None, None, None)
#                    t5 = (-999.99, "...", -999.99, -999.99, 'XXX', row.date, row.event, 'None', 'None', None, None, None)

                a.append(t5)

            columns = ['mole_fraction', 'flag', 'site_code', 'sample_date', 'flask_id', 'flask_method', 'flask_strategy', 'latitude', 'longitude', 'altitude']
#            columns = ['mole_fraction', 'flag', 'unc', 'meas_unc', 'site_code', 'sample_date', 'flask_id', 'flask_method', 'flask_strategy', 'latitude', 'longitude', 'altitude']
            titles += ['Mole Fraction', 'Flag', 'site_code', 'sample_date', 'flask_id', 'flask_method', 'flask_strategy', 'latitude', 'longitude', 'altitude']
#            titles += ['Mole Fraction', 'Flag', 'Uncertainty', 'Measurement Unc.', 'site_code', 'sample_date', 'flask_id', 'flask_method', 'flask_strategy', 'latitude', 'longitude', 'altitude']
            dfs = pd.DataFrame(a, columns=columns)
            df = pd.concat([df, dfs], axis=1)

        self.titles = titles
#        print(df)
#        print(self.titles)

        self.data = df

        self.numrows = self.data.shape[0]
        if self.numrows == 0:
            print("No data found in raw file.", file=sys.stderr)
            self.valid = False
            return

        if self.debug:
            print("number of lines in raw file:", self.numrows)

        self.column_names = self.data.columns

        # determine the id of first 'REF' sample type
        df = self.data[(self.data.smptype == "REF") & (self.data.event != "Z")]
        self.refid = df.iloc[0].event

        # get list of all refs used
        self.refs = df.event.unique()
        self.refs = [s for s in self.refs if 'W' not in s]

        df = self.data[(self.data.smptype == "STD") & (self.data.event != "Z")]
        self.stds = df.event.unique()
        self.stds = [s for s in self.stds if 'W' not in s]

        # get list of all stds used
        if self.debug:
            print("Reference is", self.refid)
            print("in ccg_rawfile stds =", self.stds)
            print("in ccg_rawfile refs =", self.refs)
            print("in ccg_rawfile column names =", self.column_names)

        # create a namedtuple for later use in dataRow()
#        self.Row = namedtuple("row", self.data.columns)
#        print(self.Row)

    #------------------------------------------------------------------------------
    @staticmethod
    def _read_file(filename):
        """ Read in the raw file.
            Store header information in self.info,
            and store the data in the self.rawlines list
        """

        info = {}
        rawlines = []

        try:
            f = open(filename)
        except (OSError, IOError) as err:
            print(err, file=sys.stderr) #  "Can't open file", file
            return info, rawlines

        header = True
        for line in f:
            line.strip("\n")
            if line.startswith(";+"):
                header = False
                continue

            if header:
                (name, value) = line.split(":", 1)
                name = name.strip()
                value = value.strip()

                # Start Date and C can be there multiple times, so store
                # these as a list

                if name in ("Start Date", "C"):
                    if name not in info:
                        info[name] = []
                    info[name].append(value)
                else:
                    info[name] = value
            else:
                rawlines.append(tuple(line.split()))

        f.close()

        return info, rawlines


    #------------------------------------------------------------------------------
    def _get_raw_data(self, rawlines):
        """ Parse the raw data into a list of tuples.
        """

        if self.method == "GC":
            column_titles = ["Sample Type", "Event", "Date", "Peak Height", "Peak Area", "Retention Time", "Raw Flag", "Baseline Code"]
            column_names = ["smptype", "event", "date", "ph", "pa", "rt", "rawflag", "bc"]
        else:
            column_titles = ["Sample Type", "Event", "Date", "Analyzer Units", "Analyzer Units Std. Dev.", "N", "Raw Flag", "Unused"]
            column_names = ["smptype", "event", "date", "value", "std", "n", "rawflag", "bc"]


        raw = []
        for line in rawlines:

            if len(line) == 12:
                (stype, event, yr, mon, day, hour, minute, second, val1, val2, val3, flag) = line
                bc = ""
            elif len(line) == 13:
                if self.method == "GC":
                    (stype, event, yr, mon, day, hour, minute, second, val1, val2, val3, flag, bc) = line
                else:
                    (stype, event, yr, mon, day, hour, minute, second, val1, val2, val3, flow, flag) = line
                    bc = ""
#            elif len(line) == 14:  # temporary line for old raw file format
#                (stype, event, yr, mon, day, hour, minute, second, val1, val2, val3, flow, flag, bc) = line
            elif len(line) == 15:  # temporary line for old raw file format
                (stype, event, yr, mon, day, hour, minute, second, val1, val2, val3, flow, flag, bc, pressure) = line
            elif len(line) == 10:
                (stype, event, yr, mon, day, hour, minute, second, val1, flag) = line
                val2 = -9.9
                val3 = -9
                bc = ""
            elif len(line) == 8:
                (stype, event, yr, mon, day, hour, minute, val1) = line
                second = 0
                val2 = -9.9
                val3 = -9
                flag = "."
                bc = ""
            else:
                print("Wrong number of columns in raw file to read. Fix file.", file=sys.stderr)
                continue

            dt = datetime.datetime(int(yr), int(mon), int(day), int(hour), int(minute), int(second))

            val1 = float(val1)
            val2 = float(val2)
            val3 = float(val3)

            t = (stype, event, dt, val1, val2, val3, flag, bc)
            raw.append(t)

        df = pd.DataFrame(raw, columns=column_names)

        return df, column_titles

        return column_titles, column_names, raw

    #--------------------------------------------------------------------------
    def _get_qc_data(self, qcinfo, rawlines):
        """
        Put qc raw data into a list of tuples.
        qc data don't have fixed number of columns, so figure out column data
        from the 'Format' header line.

        The first 8 columns in the qc file are sample type, event, and date fields.
        qc data comes after them.
        """

        if "Format" in qcinfo:
            labels = qcinfo["Format"].split()
            column_titles = labels[8:]
            # must remove characters '()/' from column_names because namedtuple doesn't allow
            # those characters as an attribute name
            column_names = []
            for name in column_titles:
                name = name.replace(')', '_')
                name = name.replace('(', '_')
                name = name.replace('/', '_')
                column_names.append(name.lower())
        else:
            print("Warning: No Format line in qc file.", file=sys.stderr)
            return None, None

        raw = []
        for line in rawlines:

            stype = line[0]
            event = line[1]
            (year, month, day, hour, minute, second) = [int(s) for s in line[2:8]]
            dt = datetime.datetime(year, month, day, hour, minute, second)

            b = []
            for a in line[8:]:
                # try converting all values to float. if error, leave as string
                try:
                    v = float(a)
                except ValueError as e:
                    v = a
                b.append(v)

#            t = [stype, event, dt] + b
            t = b
            raw.append(tuple(t))

#        print(column_names)
        df = pd.DataFrame(raw, columns=column_names)
        return df, column_titles

        return column_titles, column_names, raw

    #--------------------------------------------------------------------------
    def dataRow(self, rownum):
            """ Get the data at row number rownum, and return it as
            a namedtuple.
            """

            return self.Row._make(self.data[rownum])


    #--------------------------------------------------------------------------
    def findPrevStd(self, linenum, std, oneback=False):
        """ find the previous std in the raw lines
        'std' is the tank label wanted, e.g. 'R0'
        """

        # if oneback is true, check only the previous raw line
        if oneback:
            if linenum >= 1:
                if self.data[linenum-1][1] == std:
                    return linenum-1

            return -1

        # finds prev standard shot
        for j in range(linenum, -1, -1):
            if self.data[j][1] == std:
                return j

        return -1

    #--------------------------------------------------------------------------
    def findNextStd(self, linenum, std, oneforward=False):
        """ find the next std in the raw lines
        'std' is the tank label wanted, e.g. 'R0'
        """

        # if oneforward is true, check only the next raw line
        if oneforward:
            if linenum+1 < self.numrows:
                if self.data[linenum+1][1] == std:
                    return linenum+1

            return -1

        # finds next standard shot
        for j in range(linenum, self.numrows):
            if self.data[j][1] == std:
                return j

        return -1

    #--------------------------------------------------------------------------
    def findPrevRef(self, linenum):
        """ Find the previous reference sample type ('REF')
        starting at linenum
        """

        for i in range(linenum, -1, -1):
            smptype = self.data[i][0]
            if smptype == "REF":
                return i

        return -1

    #--------------------------------------------------------------------------
    def findNextRef(self, linenum):
        """ Find the next reference sample type ('REF')
        starting at linenum
        """

        for i in range(linenum, self.numrows):
            smptype = self.data[i][0]
            if smptype == "REF":
                return i

        return -1

    #--------------------------------------------------------------------------
    def findPrevZero(self, linenum):
        """ Return the prev raw line signal value for the Z tank that follows immediately after R0 """

        for i in range(linenum, -1, -1):
            tnk = self.data[i][1]
            flag = self.data[i][6]
            signal = self.data[i][3]
            if tnk == 'Z' and flag == '.' and i > 0:
                tnk2 = self.data[i-1][1]
                if tnk2 == self.refid:  # this isn't always correct.  Need to send in correct reference id
                    return signal

        return None


    #--------------------------------------------------------------------------
    def findNextZero(self, linenum):
        """ Return the next raw line signal value for the Z tank that follows immediately after R0 """

        for i in range(linenum, self.numrows):
            tnk = self.data[i][1]
            flag = self.data[i][6]
            signal = self.data[i][3]
            if tnk == 'Z' and flag == '.' and i > 0:
                tnk2 = self.data[i-1][1]
                if tnk2 == self.refid:
                    return signal

        return None


    #--------------------------------------------------------------------------
    def zeroCorrectSignal(self, linenum):
        """
        zero correct the value for raw[linenum]
        Will return a zero corrected value, or if no valid zeros then returns
        default as corrected value and a z flag
        """


        signal = self.data[linenum][3]
        flag = self.data[linenum][6]
        if flag != '.':
            return (-999.99, flag)

        prev_zero = self.findPrevZero(linenum)
        next_zero = self.findNextZero(linenum)


        if prev_zero and next_zero:
            corr_signal = signal - ((prev_zero + next_zero)/2.0)
            f3 = "."
        elif prev_zero and not next_zero:
            corr_signal = signal - prev_zero
            f3 = "z"
        elif not prev_zero and next_zero:
            corr_signal = signal - next_zero
            f3 = "z"
        else:
            corr_signal = -999.99
            f3 = "z"

        return (corr_signal, f3)

    #--------------------------------------------------------------------------
    def getSampleEvents(self):
        """ Get list of event numbers for samples (sample type 'SMP')."""

        a = [int(line[1]) for line in self.data if line[0] == "SMP"]

        return a

    #--------------------------------------------------------------------------
    def sampleIndices(self, stype="SMP", inverse=False):
        """ Get list of indices in the raw data where the sample type
        matches the given stype, default is 'SMP'.

        Returns
            List of integer row indices that match the desired sample type.
        """

        if inverse:
            w = numpy.where(self.data.T[0] != stype)
        else:
            w = numpy.where(self.data.T[0] == stype)

        return w[0].tolist()


    #--------------------------------------------------------------------------
    def getColumnData(self, colname, smptype=None, label=None, flagged=None):
        """ Get a single column of data that has the name 'colname'.
        Optionally filter the results with a sample type and/or label (event).

        The argument 'flagged' can be one of None, True or False.
            if None, use all data
            if True, use only flagged data
            if False, use only unflagged data

        Example. Get the final flask pressures for sample flasks only and
            their corresponding analysis dates:

            a = getColumnData("final_flask_P(psia)", smptype="SMP")
            b = getColumnData("date", smptype="SMP")

        Returns
            numpy array
        """

        if colname in self.column_names:
            colidx = self.column_names.index(colname)
        else:
            raise ValueError("Unknown column name %s" % colname)

        if smptype and label:
            if flagged is None:
                w = numpy.where((self.data.T[0] == smptype) & (self.data.T[1] == label))
                a = self.data.T[colidx][w]
            elif flagged is True:
                w = numpy.where((self.data.T[0] == smptype) & (self.data.T[1] == label) & (self.data.T[6] != "."))
                a = self.data.T[colidx][w]
            elif flagged is False:
                w = numpy.where((self.data.T[0] == smptype) & (self.data.T[1] == label) & (self.data.T[6] == "."))
                a = self.data.T[colidx][w]

        elif smptype:
            if flagged is None:
                w = numpy.where(self.data.T[0] == smptype)
                a = self.data.T[colidx][w]
            elif flagged is True:
                w = numpy.where((self.data.T[0] == smptype) & (self.data.T[6] != '.'))
                a = self.data.T[colidx][w]
            elif flagged is False:
                w = numpy.where((self.data.T[0] == smptype) & (self.data.T[6] == '.'))
                a = self.data.T[colidx][w]

        elif label:
            if flagged is None:
                w = numpy.where(self.data.T[1] == label)
                a = self.data.T[colidx][w]
            elif flagged is True:
                w = numpy.where((self.data.T[1] == label) & (self.data.T[6] != '.'))
                a = self.data.T[colidx][w]
            elif flagged is False:
                w = numpy.where((self.data.T[1] == label) & (self.data.T[6] == '.'))
                a = self.data.T[colidx][w]

        else:
            if flagged is None:
                a = self.data.T[colidx]
            elif flagged is True:
                w = numpy.where((self.data.T[6] != '.'))
                a = self.data.T[colidx][w]
            elif flagged is False:
                w = numpy.where((self.data.T[6] == '.'))
                a = self.data.T[colidx][w]

        return a

    #--------------------------------------------------------------------------
    def findRow(self, adate):
        """ Find a row in the data that has a matching adate """

        w = numpy.where(self.data.T[2] == adate)

        return w[0][0]


if __name__ == "__main__":
#    raw = Rawfile("/ccg/co2/flask/magicc-3/raw/2021/2021-11-24.1521.pc2.co2", "flask", debug=True)
    raw = Rawfile("/ccg/co2/flask/magicc-3/raw/2021/2021-01-04.1007.pc2.co2", "flask", debug=True)
#    raw = Rawfile("/ccg/co2/flask/magicc-1/raw/2019/2019-08-07.1426.l8.co2", "flask", debug=True)
#    raw = Rawfile("/ccg/co2/cals/co2cal-2/raw/2021/2021-01-12.0858.pc1.co2", "cals", debug=True)
#    raw = Rawfile("/ccg/co2/cals/co2cal-1/raw/2017/2017-01-12.1439.l9.co2", "cals", debug=True)
    print(raw.data)

    x = raw.data.date
#    print(x)
    y = raw.data.value
#    print(y)

    print(raw.titles)
