# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for reading raw files; flask, cals, nl.
NOT for insitu raw files, use ccg_insitu_raw.py instead

This version will read either data raw files or qc raw files.

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

import sys
import math
import datetime
from collections import namedtuple
import numpy

import ccg_dates


class Rawfile():
    """ Class for reading raw files

        The raw file can be either a data raw file or a qc raw file.

        Usage
        raw = Rawfile(filename)

        Parameters
        ----------
        filename - name of raw file to read

        Attributes
        ----------
        rawlines - list of list of values for the data part of the raw file
        data - numpy 2d array with processed data.  There is one row for each line of data.
            For data raw files, each row contains
            [stype, event, dt, val1, val2, val3, flag, bc]
            types for each column are
            (str, str, datetime, float, float, float, str, str)
            For qc raw files, each row contains
            [stype, event, dt, val1, val2, val3, ...]
            depending on how many fields are in the qc file.
        numrows - integer count of number of rows in data
        info - dict of header information
        stds - list of tank labels used in the calibration
        column_names - list of short names for each column in data array
        column_titles - list of long names for each column in data array
        refid - label of first 'REF' sample, excluding 'Z'

        Methods
        Use pydoc to view public methods

    """

    def __init__(self, filename, debug=False):

        self.debug = debug
        self.filename = filename
        self.rawlines = []
        self.info = {}
        self.column_names = []
        self.method = None
        self.data = None
        self.refid = None
        self.valid = False
        self.instid = None
        self.method = None
        self.numrows = 0

        self.info, self.rawlines = self._read_file(filename)
        if self.info:
            self.valid = True

        if not self.valid:
            return

        self.species = self.info["Species"].lower()
        self.adate = ccg_dates.getDatetime(self.info["Date"])
        self.idate = ccg_dates.intDate(self.adate.year, self.adate.month, self.adate.day, self.adate.hour)
        self.system = self.info["System"].split()[0]
        if "File type" in self.info:
            filetype = self.info["File type"].lower()
        else:
            filetype = None

        if self.species == "qc" or filetype == "qc":
            raw = self._get_qc_data()
        else:
            self.instid = self.info["Instrument"].split()[0]
            self.method = self.info["Method"]
            raw = self._get_raw_data()

        # create a numpy array from the raw data
        self.data = numpy.array(raw)
        self.numrows = self.data.shape[0]
        if self.numrows == 0:
            print("No data found in raw file.", file=sys.stderr)
            self.valid = False
            return

        if self.debug:
            print("number of lines in raw file:", self.numrows)

        if self.data.shape[1] != len(self.column_names):
            print("ERROR: Number of column names (%d)" % len(self.column_names),
                  "does not match with number of data columns (%d)" % self.data.shape[1],
                  file=sys.stderr)
            self.valid = False
            return

        # determine the id of first 'REF' sample type
        for i in range(self.numrows):
            smptype = self.data[i][0]
            smpid = self.data[i][1]
            if smptype == "REF" and smpid.upper() != "Z":
                self.refid = smpid
                break

        # get list of all refs used
        w = numpy.where((self.data.T[0] == 'REF') & (self.data.T[1] != 'Z'))
        self.refs = numpy.unique(self.data.T[1][w])
        self.refs = [s for s in self.refs if 'W' not in s]

        # get list of all stds used
        w = numpy.where((self.data.T[0] == 'STD') & (self.data.T[1] != 'Z'))
        self.stds = numpy.unique(self.data.T[1][w])
        self.stds = [s for s in self.stds if 'W' not in s]
        if self.debug:
            print("Reference is", self.refid)
            print("in ccg_rawfile stds =", self.stds)
            print("in ccg_rawfile refs =", self.refs)
            print("in ccg_rawfile column names =", self.column_names)

        # create a namedtuple for later use in dataRow()
        self.Row = namedtuple("row", self.column_names)

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
    def _get_raw_data(self):
        """ Parse the raw data into a list of tuples.
        """

        if self.method == "GC":
            self.column_titles = ["Sample Type", "Event", "Date", "Peak Height", "Peak Area", "Retention Time", "Flag", "Baseline Code"]
            self.column_names = ["smptype", "event", "date", "ph", "pa", "rt", "flag", "bc"]
        else:
            self.column_titles = ["Sample Type", "Event", "Date", "Analyzer Units", "Analyzer Units Std. Dev.", "N", "Flag", ""]
            self.column_names = ["smptype", "event", "date", "value", "std", "n", "flag", "bc"]


        raw = []
        for line in self.rawlines:

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

        return raw

    #--------------------------------------------------------------------------
    def _get_qc_data(self):
        """
        Put qc raw data into a list of tuples.
        qc data don't have fixed number of columns, so figure out column data
        from the 'Format' header line.

        The first 8 columns in the qc file are sample type, event, and date fields.
        qc data comes after them.
        """

        if "Format" in self.info:
            labels = self.info["Format"].split()
            self.column_titles = ["Sample Type", "Event", "Date"] + labels[8:]
            # must remove characters '()/' from column_names because namedtuple doesn't allow
            # those characters as an attribute name
            self.column_names = ['smptype', 'event', 'date']
            for name in labels[8:]:
                name = name.replace(')', '_')
                name = name.replace('(', '_')
                name = name.replace('/', '_')
                self.column_names.append(name)
        else:
            print("Warning: No Format line in qc file.", file=sys.stderr)

        raw = []
        for line in self.rawlines:

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

            t = [stype, event, dt] + b
            raw.append(tuple(t))

        return raw

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
    def _find_prev_zero(self, linenum):
        """ Return the prev raw line signal value for the Z tank
        There must be a reference before the Z, unless the Z is the first line of data
        """

        for i in range(linenum, -1, -1):
            tnk = self.data[i][1]
            flag = self.data[i][6]
            signal = self.data[i][3]
            sd = self.data[i][4]
            n = self.data[i][5]
            if n < 0: n = 10  # default value if number of measurements not recorded
            if tnk == 'Z' and flag == '.':  #  and i > 0:
                if i > 0:
                    tnk2 = self.data[i-1][1]
                    if tnk2 == self.refid:  # this isn't always correct.  Need to send in correct reference id
                        return signal, sd/math.sqrt(n)
                else:
                    return signal, sd/math.sqrt(n)

        return None, None


    #--------------------------------------------------------------------------
    def _find_next_zero(self, linenum):
        """ Return the next raw line signal value for the Z tank
         that follows immediately after a reference """

        for i in range(linenum, self.numrows):
            tnk = self.data[i][1]
            flag = self.data[i][6]
            signal = self.data[i][3]
            sd = self.data[i][4]
            n = self.data[i][5]
            if n < 0: n = 10  # default value if number of measurements not recorded
            if tnk == 'Z' and flag == '.' and i > 0:
                tnk2 = self.data[i-1][1]
                if tnk2 == self.refid:
                    return signal, sd/math.sqrt(n)

        return None, None


    #--------------------------------------------------------------------------
    def zeroCorrectSignal(self, linenum):
        """
        zero correct the value for raw[linenum]
        Will return a zero corrected value, or if no valid zeros then returns
        default as corrected value and a z flag
        """


        signal = self.data[linenum][3]
        signal_sd = self.data[linenum][4]
        signal_n = self.data[linenum][5]
        if signal_n < 0: signal_n = 10  # default value if number of measurements not recorded
        flag = self.data[linenum][6]
        if flag != '.':
            return (-999.99, -99.99, flag)

        prev_zero, prevz_sd = self._find_prev_zero(linenum)
        next_zero, nextz_sd = self._find_next_zero(linenum)

        signal_sd = signal_sd/math.sqrt(signal_n)

        if self.debug:
            print(self.data[linenum])
            print("prev zero", prev_zero, "+/-", prevz_sd)
            print("next zero", next_zero, "+/-", nextz_sd)

        if prev_zero and next_zero:
            corr_signal = signal - ((prev_zero + next_zero)/2.0)
            corr_sd = math.sqrt(signal_sd*signal_sd + prevz_sd*prevz_sd + nextz_sd*nextz_sd)
            f3 = "."
        elif prev_zero and not next_zero:
            corr_signal = signal - prev_zero
            corr_sd = math.sqrt(signal_sd*signal_sd + prevz_sd*prevz_sd)
            f3 = "z"
        elif not prev_zero and next_zero:
            corr_signal = signal - next_zero
            corr_sd = math.sqrt(signal_sd*signal_sd + nextz_sd*nextz_sd)
            f3 = "z"
        else:
            corr_signal = -999.99
            corr_sd = 0
            f3 = "z"


        return (corr_signal, corr_sd, f3)

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
