# vim: tabstop=4 shiftwidth=4 expandtab
""" 

A class for automated flagging of insitu raw data.

Given a raw file name,
it reads a file with rules for flagging, then applies
those flags to the entries in the raw file
"""
from __future__ import print_function

import os
import sys
import datetime
import fnmatch
import re
from collections import namedtuple
from dateutil.parser import parse

import ccg_utils
import ccg_insitu_qc
import ccg_insitu_config

CYCLETIME = 5

AUTOMATED_QC_FLAG = "&"

##################################################################################
def check_gas_change(stacode, dt):
    """ Check if we want to switch on 5 minute intervals.
    This is for sites with new style response curve method of measurements,
    i.e. lgr, picarro, ndir (starting in 2018 at spo)
    """

    if stacode == "SPO" and dt >= datetime.datetime(2018, 1, 21, 0, 0, 0): return True
    if stacode == "MLO" and dt >= datetime.datetime(2019, 4, 10, 22, 35, 0): return True
    if stacode == "BRW" and dt >= datetime.datetime(2013, 4, 11, 0, 25, 0): return True
    if stacode == "SMO" and dt >= datetime.datetime(2022, 1, 1, 0, 0, 0): return True
    if stacode in ["LEF", "SCT", "CAO", "MKO", "WKT", "AMT", "WBI", "SBT", "WGC"]: return True

    return False


###################################################################
def check_extra_flush(date, last_trap_date, last_tgt_date, last_gas):
    """ Check the time difference between the start time and the
    last time the trap was impacted and requires additional flushing.
    Flag any data points that start within the extra flushing window.
    Use CYCLETIME for after TGT (unless following and R0, then use 2*Cycl)
    Use 2 * CYCLETIME for trap changes etc.
    """
    td = datetime.timedelta(minutes=CYCLETIME)
    td2 = datetime.timedelta(minutes=2 * CYCLETIME)

#    print("st, p_gas, lst_trap, lst_gas, lst_tgt", st, p_gas, lst_trap, lst_gas, lst_tgt)

    flg = '.'
    comment = ""

#    print(date, last_trap_date, td2)
    if date - last_trap_date <= td2:
        flg = AUTOMATED_QC_FLAG
        comment = "Extra flush for trap"

    elif last_gas == "R0":
        if date - last_tgt_date <= td2:
            flg = AUTOMATED_QC_FLAG
            comment = "Extra flush for trap"

    else:
        if date - last_tgt_date <= td:
            flg = AUTOMATED_QC_FLAG
            comment = "Extra flush for trap"


    return flg, comment


#########################################################################################
class Flag:
    """ Class for automated flagging of insitu raw data (not mole fractions).

    Public Methods:
        apply_flags()  - Apply flags based on rules in rulefile
        get_parameter()- Get the min value and max value from the rules file for
                        the given parameter name 'key' on the given date.

    Usage:
        af = ccg_insitu_flag.Flag(stacode, species, system, rulefile, debug)
            stacode      - three letter station code
            species         - species to work on
            system         - name of system.  Only needed during overlap periods for lgr, pic
            rulefile     - name of file with flagging rules
            debug        - print debugging information if true

        af.apply_flags(raw)
            raw             - InsituRaw object from ccg_insitu_raw.py

        Default rulefile is "/ccg/insitu/insitu_flag.conf"
    """

    def __init__(self, stacode, species, system, rulefile=None, debug=False):


        self.species = species
        self.debug = debug
        self.stacode = stacode
        self.system = system.upper()
        self.modified = False

        self.config = ccg_insitu_config.InsituConfig(self.stacode, self.species, self.system)

        # 'basis' names that we will use that require reading a qc file.
        # these names will be set in the flag rules file, and this
        # list will be updated when reading the file
        self.param_names = []

        if rulefile:
            self.flagging_file = rulefile
        else:
            self.flagging_file = "/ccg/insitu/insitu_flag.conf"

        if self.debug:
            print("Rule file is", self.flagging_file)

        self.flag_rules = self._read_flagging()
#        for r in self.flag_rules: print(r)
        self.numrules = len(self.flag_rules)
        if self.debug:
            print(self.numrules, "rules")
            for rule in self.flag_rules: print(rule)

        self.qcdata = {}

    #----------------------------------------------------------------------------------------------
    def get_parameter(self, date, key):
        """ Get the min value and max value from the rules file for
        the given parameter name 'key' on the given date.
        """

        rules = self._find_rules(date)

        for rule in rules:
            if rule.basis == key:
                return rule.minval, rule.maxval

        sys.exit("No init parameter found for %s on %s, exiting ..." % (key, date.isoformat()))


    #----------------------------------------------------------------------------------------------
    def _read_qc(self, stacode, species, date):
        """ Read in the qc files that are used in flagging """

        # read the qc data for the names specified in the flag rules file

        for param in self.param_names:
            qcfile = ccg_insitu_qc.qc_filename(stacode, self.system, date, param)
#            print("param is", param, "qcfile is", qcfile, self.system)
            if self.debug: print("qcfile is", qcfile)
            if qcfile and os.path.exists(qcfile):
                self.qcdata[param] = ccg_insitu_qc.read_insitu_qc(qcfile)
            else:
                self.qcdata[param] = None


    #----------------------------------------------------------------------------------------------
    def _replace_flag(self, rawdata, idx, flag, comment, overwrite=False):
        """ Replace the flag and comment in the raw data at index 'idx' """

        if rawdata.iloc[idx].flag == "." or overwrite:
            rawdata.at[idx, 'flag'] = flag
            rawdata.at[idx, 'comment'] = comment
            self.modified = True
            if self.debug:
                print("flag changed to ", flag, "comment", comment)


    #------------------------------------------------------------------
    def apply_flags(self, raw, replaceflags=False):
        """ Process the flagging rules on the results and apply flags if needed.
        Input
            raw - A ccg_insituraw.InsituRaw object
        """

        if self.numrules == 0:
            return

        # read in qc files here
        row = raw.dataRow(0)
        self._read_qc(self.stacode.lower(), self.species, row.date)

        if self.debug:
            print("### Begin Apply flags ##############################")

        for idx in range(raw.numrows):
            row = raw.dataRow(idx)
            if idx+1 < raw.numrows:
                nextrow = raw.dataRow(idx+1)
            else:
                nextrow = None
            if self.debug:
                print("\n------------------------------")
                print(row)
                print(nextrow)

            rules = self._find_rules(row.date)
            if self.debug: print('rules', rules)

            # Reset any existing automatically applied flags back to '.'
            if row.flag in [rule.flag for rule in rules]:
                self._replace_flag(raw.data, idx, ".", "", overwrite=True)
                if self.debug: print("@@@@@ replace flag", row)

            if replaceflags:
                if row.flag != '.':
                    self._replace_flag(raw.data, idx, ".", "", overwrite=True)

            for rule in rules:

                if self.debug: print("rule is", rule)

                # generic sample line flag
                if rule.basis.lower() in ('line1', 'line2') and rule.basis.lower() == row.label.lower():
                    self._replace_flag(raw.data, idx, rule.flag, rule.comment)
                    break

                elif rule.basis.lower() in ('r0') and rule.basis.lower() == row.label.lower():
                    self._replace_flag(raw.data, idx, rule.flag, rule.comment)
                    break


                elif rule.basis == "npoints":
                    npoints = row.n
                    if npoints < rule.minval:
                        self._replace_flag(raw.data, idx, rule.flag, rule.comment)
                        break

                elif rule.basis == "any":
#                    print(idx, row, rule)
                    self._replace_flag(raw.data, idx, rule.flag, rule.comment)
                    break

                else:

                    # check that qc data falls within limits of the rule
                    # some rules may apply to only one sample line
                    label = None
                    if re.search(r'_\d$', rule.basis):  # look for string ending in _n, ie _1, _2 ...
                        inlet_num = rule.basis[-1]
                        label = "Line" + inlet_num

                    # if rule is not for same sample line, go to next rule
                    if label is not None and row.label != label: continue

                    # get the qc data that matches this rule
                    data = self.qcdata[rule.basis]
    #                print(data)
    #                print(rule.basis)
    #                print(self.qcdata)
                    if data is None:
                        if self.debug: print("No QC data for", rule.basis)
                        continue

                    use_stddev = rule.basis_type == 'V'
                    if self._check_range(data, row, nextrow, rule, use_stddev):
                        self._replace_flag(raw.data, idx, rule.flag, rule.comment)
                        break


        # special case for brw lgr and trap flushing
        if self.stacode.upper() == "BRW" and self.system == "LGR":

            row = raw.dataRow(0)
            prev_gas = row.label
            last_trap = datetime.datetime(1900, 1, 1)  # should be from previous day
            last_tgt = datetime.datetime(1900, 1, 1)   # should be from previous day

            for idx in range(raw.numrows):
                row = raw.dataRow(idx)
                if row.smptype == "SMP":
                    flg, comment = check_extra_flush(row.date, last_trap, last_tgt, prev_gas)
                    if flg != ".":
                        self._replace_flag(raw.data, idx, flg, comment)

                prev_gas = row.label

                if row['mode'] in (4, 3, 2, 0):
                    last_trap = row.date
                if "TGT" in row.smptype:
                    last_tgt = row.date


    #------------------------------------------------------------------
    def _find_rules(self, date):
        """ Find the rules that apply to the date of the row of data.
        All checks of the rules must be True for the rule to be applied.
        """

        rules = []
        for rule in self.flag_rules:

            if not self._check_rule(self.system, rule.system): continue
            if date < rule.sdate: continue
            if date > rule.edate: continue

            rules.append(rule)

        return rules

    #------------------------------------------------------------------
    @staticmethod
    def _check_rule(string, pattern):
        """ Check if given string matches the given pattern """

        if pattern.startswith("!"):
            if "|" in pattern:
                # if string doesn't match any elements in pattern, return True
                return True not in [fnmatch.fnmatch(str(string), s) for s in pattern[1:].split("|")]

            return not fnmatch.fnmatch(str(string), pattern[1:])

        if "|" in pattern:
            # if string matches any elements in pattern, return True
            return True in [fnmatch.fnmatch(str(string), s) for s in pattern.split("|")]

        return fnmatch.fnmatch(str(string), pattern)


    #------------------------------------------------------------------
    def _read_flagging(self):
        """
        Read flagging data from the flagging file.
        Store data as a list of namedtuples.

        Filter the rules based on station code and gas species.
        More filtering is done in the find_rules() method.
        """

        names = ['gas', 'site', 'system', 'sdate', 'edate', 'basis', 'basis_type', 'minval', 'maxval', 'flag', 'comment']
        FlagRules = namedtuple('rule', names)

        flag_rules = []
        lines = ccg_utils.cleanFile(self.flagging_file, True)
        for line in lines:
            a = line.split(";")        # separate parameters from comment
            params = a[0].strip()
            if len(a) == 2:
                comment = a[1].strip()
            else:
                comment = ""
            [gas, site, system, sdate, edate, basis, basis_type, minval, maxval, flag] = params.split()

            system = system.upper()
            # skip rules that aren't for this site or gas
            if not self._check_rule(self.species.upper(), gas): continue
            if not self._check_rule(self.stacode.upper(), site): continue
            if not self._check_rule(self.system.upper(), system): continue

            if sdate == "*":
                sdate = datetime.datetime.min
            else:
                sdate = parse(sdate)

            if edate == "*":
                edate = datetime.datetime.max
            else:
                edate = parse(edate)

            if minval == "*":
                minval = -1e+34
            else:
                minval = float(minval)

            if maxval == "*":
                maxval = 1e+34
            else:
                maxval = float(maxval)

#            if basis not in self.param_names and basis not in self.param_names2:
#                print("Warning: basis name not recognized: %s. Skipping..." % basis, file=sys.stderr)
#                continue

            if basis_type not in ('R', 'V'): continue

            t = (gas, site, system, sdate, edate, basis, basis_type, minval, maxval, flag, comment)
            flag_rules.append(FlagRules._make(t))

            # keep a list of qc parameters we will need to read
            if basis not in self.param_names:
                self.param_names.append(basis)


        return flag_rules

    #------------------------------------------------------------------
    def _check_range(self, data, row, nextrow, rule, use_stdv=False):
        """ check if qc data is within limits (between min and max values).

        return True (apply flag) if outside limits,
        return False (don't apply flag) if within limits.
        If use_stdv is True, then check that the standard deviation
        of the qc value is within the limits
        """

        # if no qc data available, assume ok
        if data is None:
            return False

        if row.smptype == "SMP":
            flushtime = self.config.get('smp_flush_time', row.date)
        else:
            flushtime = self.config.get('cal_flush_time', row.date)
        startdate = row.date + datetime.timedelta(seconds=int(flushtime))
# should start date be row.date +flushtime?
        nextdate = self._next_start_time(row)
        if nextrow is not None:
            if nextrow.date < nextdate:
                nextdate = nextrow.date
        minval, maxval, average, stdv, n = ccg_insitu_qc.get_qc_avg(data, startdate, nextdate)
        if minval is None: return False # no qc data
        if self.debug:
            print(rule.basis, row.date, nextdate)
            print("Check range: minval, maxval, avg, std, min, max, use_std;", minval, maxval, average, stdv, rule.minval, rule.maxval, use_stdv)

        if use_stdv:
            if stdv < rule.minval or stdv > rule.maxval:
                return True
        else:
            if minval < rule.minval or maxval > rule.maxval:
                return True

        return False


    #------------------------------------------------------------------
    def _next_start_time(self, row):
        """
        Returns the next start time based on the cycle length.  For example
        with a 5 minute cycle will return the next 5th minute of the hour.
        """

        # gc systems will use sample time
        if self.system == "GC": return row.date

        # for systems on 5 minute cycle, or for ref, std, tgt gases,
        # next start is at next 5 minute of hour
        if check_gas_change(self.stacode, row.date) or row.smptype != "SMP":
            # need to handle that mko isn't on 5 minute cycle all the time
            if self.stacode.upper() == "MKO" and row.smptype == "REF":
                nextdate = row.date + datetime.timedelta(minutes=4)
            else:
                mm = (row.date.minute % CYCLETIME) * 60
                ss = row.date.second + row.date.microsecond/1000000.0
                amount = CYCLETIME * 60 - (mm + ss)
                td = datetime.timedelta(seconds=amount)
                nextdate = row.date + td

        # old co2 ndir have 2 samples per hour, at 0 and 25 minutes of hour
        else:
            if row.label == "Line1":
                nextdate = row.date + datetime.timedelta(seconds=25*60)
            elif row.label == "Line2":
                nextdate = row.date + datetime.timedelta(seconds=20*60)

        return nextdate
