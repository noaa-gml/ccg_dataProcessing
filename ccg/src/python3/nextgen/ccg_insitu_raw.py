# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class to deal with raw data files for in-situ data
"""

import os
import sys
import datetime
from collections import namedtuple
from dateutil.parser import parse
import pandas as pd

import ccg_insitu_config
import ccg_insitu_systems

##################################################################
def update_rawfile(filename, df, backup=False):
    """ update a raw file with data from the dataframe df """

    format1 = "%-3s %6s %s %12.5e %9.3e %3.0f %1s %1d %s" # non gc with comment
    format2 = "%-3s %6s %s %12.5e %9.3e %3.0f %1s %1d"  # non gc without comment

    if backup and os.path.exists(filename):
        oldfile = filename + ".bak"
        try:
            os.rename(filename, oldfile)
        except OSError as err:
            print("Couldn't backup file %s. %s" % (filename, err))

    with open(filename, "w") as f:
        for row in df.itertuples():

            if row.comment != "":
                line = format1 % (row.smptype, row.label, row.date.strftime("%Y-%m-%d %H:%M:%S"),
                       row.value, row.stdv, row.n, row.flag, row.mode, row.comment)
            else:
                line = format2 % (row.smptype, row.label, row.date.strftime("%Y-%m-%d %H:%M:%S"),
                       row.value, row.stdv, row.n, row.flag, row.mode)

            print(line, file=f)

##################################################################
class InsituRaw:
    """
    Class for reading in-situ raw files.
    Input:
        stacode - three letter station code
        gas - gas formula, e.g. 'co2'
        filenames - single filename or list of filenames to read
        changeflag - If true, change any '*' flags to '.'.  '*' signifies a
            manually entered value.

    Raw data is put into self.data, which is a pandas DataFrame

    Attributes:
        data (DataFrame) : raw data as a pandas DataFrame
        methods (list) : list of namedtuples with computation methods information
        startdate (datetime) : start date of raw data
        enddate (datetime) : end date of raw data
        gases (list) : list of gas labels sampled, e.g. SMP, S1, S2, R0 ...
        numrows (int) : number of rows of data
    """

    def __init__(self, stacode, gas, filenames, changeflag=False, system=None):

        if isinstance(filenames, str):
            filenames = [filenames]

        self.data = []
        self.filelist = filenames
        self.gas = gas.upper()
        self.stacode = stacode.lower()
        self.data = []
        self.valid = True
        self.numrows = 0

        # try to figure out what type of system this is from the data in the raw file
        if system is None:
            self.method = self._findSys(stacode, gas, filenames)
        else:
            self.method = system

        if self.method is None:
            print("ERROR: InsituRaw; No system set.", file=sys.stderr)
            self.valid = False
            return

        if "GC" in self.method.upper():
            self.column_titles = ["Sample Type", "Sample Name", "Date", "Peak Height", "Peak Area", "Retention Time", "Flag", "Mode", "Baseline Code", "Comment"]
            self.column_names = ["smptype", "label", "date", "ph", "pa", "rt", "flag", "mode", "bc", "comment"]
        else:
            self.column_titles = ["Sample Type", "Sample Name", "Date", "Analyzer Units", "Analyzer Units Std. Dev.", "N", "Flag", "Mode", "Comment"]
            self.column_names = ["smptype", "label", "date", "value", "stdv", "n", "flag", "mode", "comment"]

        self.Row = namedtuple("InsituRaw", self.column_names)

        # Read the raw data files
#        print("@@@@", filenames)
        raw = self._get_raw_data(filenames, changeflag)
        self.data = pd.DataFrame(raw, columns=self.column_names)
        self.numrows = self.data.shape[0]
        if self.numrows == 0:
            self.valid = False
            return

        self.gases = self.data.label.unique()

        self.startdate = self.data.date.iloc[0]
        self.enddate = self.data.date.iloc[-1]

#        print(self.method)
        # determine the computation methods to use for the date range
        cfg = ccg_insitu_config.InsituConfig(stacode, gas, self.method)
        tmpmethods = cfg.get_rules("method")
#        print(tmpmethods)
        self.methods = []
        startdates = []
        enddates = []
        for method in tmpmethods:

            # only use rules that fall within our date range
            if method.sdate <= self.enddate and method.edate >= self.startdate:

                # check on start and end dates to avoid duplicates due to wildcard gas match
                if method.sdate in startdates and method.edate in enddates: continue
                if method.sdate not in startdates:
                    startdates.append(method.sdate)
                if method.edate not in enddates:
                    enddates.append(method.edate)
                self.methods.append(method)

                # if the methods cover the range of the raw data, don't
                # check any more rules.  use what we already have
                # this avoids later wild card matches
                if min(startdates) <= self.startdate and max(enddates) >= self.enddate: break

#        print("raw methods for ", self.startdate, "to", self.enddate)
#        print(self.methods)
#        for r in self.methods: print(r)


    # -------------------------------------------------------
    @staticmethod
    def _findSys(stacode, gas, filenames):
        """ Try to figure out what type of system created the raw file.
        Base this on the given station code, gas, and the date of the
        first line in the raw file.
        """


        for fname in filenames:

            try:
                f = open(fname)
            except (OSError, IOError) as err:
                print(err, file=sys.stderr)
                continue  # return None

            line = f.readline()
            f.close()
            if not line:
                print("Warning: No data in file %s" % fname, file=sys.stderr)
                continue
#                return None    # no data in file

            line = line.strip("\n")
            a = line.split()

            if ':' in line:
                date = parse(a[2] + " " + a[3])
            else:
                (year, month, day, hour, minute, second) = map(int, a[2:8])
                date = datetime.datetime(year, month, day, hour, minute, second)

            s = ccg_insitu_systems.system(stacode, gas)
            sysnames = s.get(date)
            if len(sysnames) > 1:
                print("Can't determine system type from raw file %s." % fname, file=sys.stderr)
                return None
            elif len(sysnames) == 1:
                return sysnames[0]
            else:
                print("No system information for", stacode, gas, ". Update the systems.conf file.", file=sys.stderr)
                return None

        return None


    # -------------------------------------------------------
    def _get_raw_data(self, filenames, changeflag=False):
        """ Read the raw file and parse data into self.data
        Format of the raw files look like
            SMP  Line1 2020 01 13 00 00 00 3.00173e+00 1.130e-03  12 . 1
            REF     R0 2020 01 13 00 05 00 2.92690e+00 2.014e-03  12 . 1
            SMP  Line2 2020 01 13 00 10 00 3.00510e+00 1.262e-03  12 . 1

        GC files have an extra column for baseline code at the end
            REF     R0 2019 03 01 00 01 00 2.085614e+06 1.140382e+07  64.0 . 1   BB
            SMP  Line2 2019 03 01 00 08 00 2.088011e+06 1.141234e+07  63.9 . 1   BB
            REF     R0 2019 03 01 00 16 00 2.084755e+06 1.139546e+07  64.0 . 1   BB
        """

        raw = []
        for filename in filenames:

            try:
                f = open(filename)
            except (OSError, IOError) as err:
                print(err, file=sys.stderr)
                continue

            for line in f:
                a = line.split()

                if "GC" in self.method.upper():
                    (smptype, smp, year, month, day, hour, minute, second, val1, val2, val3, flag, mode, bcode) = a[0:14]
                    date = datetime.datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))
                    val1 = float(val1)
                    val2 = float(val2)
                    val3 = float(val3)
                    mode = int(mode)
                    comment = " ".join(a[14:]) if len(a) > 14 else ""
                    if changeflag:
                        if flag == "*": flag = "."
                    t = (smptype, smp, date, val1, val2, val3, flag, mode, bcode, comment)

                else:
                    if ':' in line:  # new format
#                        print("@@@@@@@@@@@@", a)
                        (smptype, smp, datestr, timestr, val1, val2, val3, flag, mode) = a[0:9]
#                        date = parse(datestr + " " + timestr)
                        # this is much faster then using parse()
                        (year, month, day) = datestr.split("-")
                        (hour, minute, second) = timestr.split(":")
                        date = datetime.datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

                        comment = " ".join(a[9:]) if len(a) > 9 else ""
                    else:
                        (smptype, smp, year, month, day, hour, minute, second, val1, val2, val3, flag, mode) = a[0:13]
                        date = datetime.datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))
                        comment = " ".join(a[13:]) if len(a) > 13 else ""
                    val1 = float(val1)
                    val2 = float(val2)
                    val3 = float(val3)
                    mode = int(mode)
                    if changeflag:
                        if flag == "*": flag = "."
                    t = (smptype, smp, date, val1, val2, val3, flag, mode, comment)

                raw.append(t)

            f.close()

        return raw

    #--------------------------------------------------------------------------
    def update(self, filename, backup=False):
        """ Write the raw data back to file """

        if backup and os.path.exists(filename):
            oldfile = filename + ".bak"
            try:
                os.rename(filename, oldfile)
            except OSError as err:
                print("Couldn't backup file %s. %s" % (filename, err))

# !todo - need to handle multiple files
        with open(filename, "w") as f:
            for row in self.data.itertuples():
                line = self.format_row(row)
                print(line, file=f)

    #--------------------------------------------------------------------------
    def dataRow(self, rownum):
        """ Get the data at row number rownum, and return it as
        a namedtuple.
        """

        return self.data.iloc[rownum]

    #--------------------------------------------------------------------------
    def sampleIndices(self, stype="SMP", mode=None, startdate=None, enddate=None, include_end_date=True):
        """ Get list of indices in the raw data where the sample type
        matches the given stype, default is 'SMP'.

        Returns
            List of integer row indices that match the desired sample type.

        If enddate is set, find indices up to that date but not beyond
        """

        sdate = startdate if startdate else datetime.datetime(1900, 1, 1)
        edate = enddate if enddate else datetime.datetime(2100, 12, 31)

        if mode:
            if include_end_date:
                w = self.data[(self.data.smptype == stype)
                    & (self.data.modenum == mode)
                    & (self.data.date >= sdate)
                    & (self.data.date <= edate)].index

            else:
                w = self.data[(self.data.smptype == stype)
                    & (self.data.modenum == mode)
                    & (self.data.date >= sdate)
                    & (self.data.date < edate)].index
        else:
            if include_end_date:
                w = self.data[(self.data.smptype == stype)
                    & (self.data.date >= sdate)
                    & (self.data.date <= edate)].index
            else:
                w = self.data[(self.data.smptype == stype)
                    & (self.data.date >= sdate)
                    & (self.data.date < edate)].index

        return w

    #--------------------------------------------------------------------------
    def data_by_label(self, label, startdate=None, enddate=None, flagged=None):
        """ Find indices in the raw data where the gas label matches. """

        sdate = startdate if startdate else datetime.datetime(1900, 1, 1)
        edate = enddate if enddate else datetime.datetime(2100, 12, 31)

        # flagged, i.e. flag != '.'
        if flagged is True:
            
            w = self.data[(self.data.label == label)
                    & (self.data.date >= sdate)
                    & (self.data.date <= edate)
                    & (self.data.flag != ".")].index

        # not flagged, i.e. flag = '.'
        elif flagged is False:
            w = self.data[(self.data.label == label)
                    & (self.data.date >= sdate)
                    & (self.data.date <= edate)
                    & (self.data.flag == ".")].index

        # all data, ignore flags
        else:
            w = self.data[(self.data.label == label)
                    & (self.data.date >= sdate)
                    & (self.data.date <= edate)].index

        return w



    #--------------------------------------------------------------------------
    def findPrevRef(self, linenum, stype, label, occurence=1):
        """ Find the previous reference sample type and label
        starting at linenum
        """

        nocc = 0
        for i in range(linenum, -1, -1):
            smptype = self.data.smptype.iloc[i]
            smplabel = self.data.label.iloc[i]
            if smptype == stype and smplabel == label:
                nocc += 1
                if nocc == occurence:
                    return i

        return -1

    #--------------------------------------------------------------------------
    def findNextRef(self, linenum, stype, label, occurence=1):
        """ Find the next reference sample type ('REF')
        starting at linenum
        """

        nocc = 0
        for i in range(linenum, self.numrows):
            smptype = self.data.smptype.iloc[i]
            smplabel = self.data.label.iloc[i]
            if smptype == stype and smplabel == label:
                nocc += 1
                if nocc == occurence:
                    return i

        return -1


    #-----------------------------------------------------------------------
    def format_row(self, row):
        """ Format a row of data into a single text line
        GC methods have an extra column for baseline code.
        If there is no flag comment, then don't print out a blank field for it.
        For non-GC methods, don't print baseline code field.
        """

        format1 = "%-3s %6s %s %12.5e %9.3e %3.0f %1s %1d %s" # non gc with comment
        format2 = "%-3s %6s %s %12.5e %9.3e %3.0f %1s %1d"  # non gc without comment
        format3 = "%-3s %6s %s %12.6e %12.6e %5.1f %1s %1d %4s %s" # gc with comment
        format4 = "%-3s %6s %s %12.6e %12.6e %5.1f %1s %1d %4s" # gc without comment

        if "GC" in self.method.upper():
            if row[9] != "":
                line = format3 % (row.smptype, row.label, row.date.strftime("%Y-%m-%d %H:%M:%S"),
                       row.ph, row.pa, row.rt, row.flag, row.mode, row.bc, row.comment)
            else:
                line = format4 % (row.smptype, row.label, row.date.strftime("%Y-%m-%d %H:%M:%S"),
                       row.ph, row.pa, row.rt, row.flag, row.mode, row.bc)
        else:
            if row.comment != "":
                line = format1 % (row.smptype, row.label, row.date.strftime("%Y-%m-%d %H:%M:%S"),
                       row.value, row.stdv, row.n, row.flag, row.mode, row.comment)
            else:
                line = format2 % (row.smptype, row.label, row.date.strftime("%Y-%m-%d %H:%M:%S"),
                       row.value, row.stdv, row.n, row.flag, row.mode)

        return line

    #-----------------------------------------------------------------------
    def printRaw(self):
        """ Print raw lines in nice format """

        for row in self.data.itertuples():
            print(self.format_row(row))


    #-----------------------------------------------------------------------
    def checkRaw(self):
        """
        Check that the formatting of the raw file is good.
        Look for bad dates, and that date and times are in order.
        """

        for filename in self.filelist:

            tddate = datetime.datetime(1900, 1, 1)
            for i in range(self.numrows):
                row = self.dataRow(i)

                if row.date < tddate:
                    print(os.path.basename(filename), "- Data is out of sequence: ", row.smptype, "%s" % row.date, file=sys.stderr)
                tddate = row.date

                # check for voltage nan
                if str(row.value) == "nan":
                    print(os.path.basename(filename), "- Bad voltage value (nan): ", row.smptype, row.date, file=sys.stderr)

                # check for correct port number of ref and samples.
                if self.gas == "CH4":
                    if row.smptype == "REF":
                        if int(row.label) not in [3, 7, 0]:
                            print("Bad port number for REF gas. Port: ", row.label, row.date, file=sys.stderr)
                    else:
                        if int(row.label) not in [1, 5, 0]:
                            print("Bad port number for SMP gas. Port: ", row.label, row.date, file=sys.stderr)



if __name__ == "__main__":

#    import glob


    files = [u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-20.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-21.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-22.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-23.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-24.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-25.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-26.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-27.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-28.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-29.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-30.n2o', u'/ccg/n2o/in-situ/brw_data/lgr/raw/2013/2013-08-31.n2o']


    files = [u'/ccg/co2/in-situ/cao/picarro/raw/2024/2024-06-06.co2']
#    print("brw n2o lgr")
#    r = InsituRaw("BRW", "N2O", files)
    print("cao co2 pic")
    r = InsituRaw("CAO", "CO2", files)


#    print("co2 ndir")
#    r = InsituRaw("SPO", "CO2", "/ccg/co2/in-situ/spo_data/raw/2019/2019-06-06.co2")
    print(r.data)
    print(r.method)
    print(r.dataRow(5))
    print(r.numrows)
#    r.printRaw()
#    r.update("test.raw", backup=True)

#    r = israw("CO2", "/ccg/co2/in-situ/mlo_data/raw/2019/2019-02-06.co2")
#    print(r.data)

#    print("mlo ch4 gc")
#    r = InsituRaw("MLO", "CH4", "/ccg/ch4/in-situ/mlo_data/raw/2018.new/2018-11-20.ch4")
#    print(r.data)
#    print(r.method)
#    for row_num in range(r.numrows):
#        print(r.dataRow(row_num))
#    r.printRaw()

#    print("brw ch4 gc")
#    r = InsituRaw("BRW", "CH4", "/ccg/ch4/in-situ/brw_data/raw/2011.new/2011-11-20.ch4")
#    print(r.data)
#    print(r.method)
#    for row_num in range(r.numrows):
#        print(r.dataRow(row_num))

#    print("multiple files co2")
#    files = sorted(glob.glob("/ccg/co2/in-situ/mlo_data/pic/raw/2019/2019-06*"))
#    r = israw("CO2", files)
#    print(files)
#    print(r.data)
#    print(r.numrows)
#if do_amie and system == "NDIR":
#    am = acdie.acdie(stacode, raw)

#if not options.noamie and system == "GC":
#    if gas == "ch4":
#        am = amie.amie(stacode, raw, isdata.results)
#    elif gas == "co":
#        am = acmie.acmie(stacode, raw, isdata.results)

#if do_amie and system == "NDIR":
#    am = acdie.acdie(stacode, raw, isdata.results)
