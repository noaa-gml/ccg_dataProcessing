
# vim: tabstop=4 shiftwidth=4 expandtab
"""
A class for automated tagging of flask data

This version uses a rule file with tag numbers

Given a raw file name,
it reads a file with rules for flagging, then applies
those flags to the entries in the flask database


!!!!!! Doesn't work with older 3 and 5 liter flasks that had
!!!!!! multiple sequential aliquots. Need to fix!
"""
from __future__ import print_function

import os
import datetime
import fnmatch
from collections import namedtuple, defaultdict
from dateutil.parser import parse

import ccg_rawfile
import ccg_flaskdb
import ccg_utils
import ccg_dbutils


#########################################################################################
class Flag:
    """ Class for automated flagging of flask data.

    Public Methods:
        printResults() : print condensed version of flask result and flag
        printTable()   : print table of flask results
        checkDb()      : check if flag agrees with entry in database
        updateDb()     : update database with flag

    Usage:
        flflag = ccg_flag.Flag(rawfile, rulefile=None, database="ccgg", debug=False)
            rawfile      : name of data raw file or qc file to process
            rulefile     : name of file with flagging rules.  None means use default file.
            database     : name of database to use for flask results.
            debug        : print debugging information if true

        rawfile is required.
        rulefile, database and debug are optional.
        Default rulefile is "/ccg/flask/tag_flagrules.dat"
    """

    def __init__(self, rawfile, rulefile=None, devdb=False, debug=False):

        self.debug = debug

        self.raw = ccg_rawfile.Rawfile(rawfile, debug=self.debug)
        self.valid = self.raw.valid
        if not self.valid: return
        self.rawfilename = os.path.basename(rawfile)

        self.taginfo = defaultdict(list)

        self.adate = self.raw.adate
        self.species = self.raw.info["Species"].upper()
        self.valid = True

        # system name
        self.system = self.raw.system.lower()
        events = self.raw.getSampleEvents()

        database = "ccgg"
        if devdb: database="mund_dev"
        self.flaskdb = ccg_flaskdb.Flasks(events, self.species, database=database, debug=debug)

        # get flask measurement results already in database
        self.results = self._make_tuple(self.species)

        if rulefile:
            self.flagging_file = rulefile
        else:
#            self.flagging_file = "/ccg/src/python3/nextgen/tag_flagrules.dat"
#            self.flagging_file = "/ccg/flask/tag_flagrules.dat"
            self.flagging_file = "/ccg/flask/tagrules.dat"

        self._read_flagging()
        if self.debug:
            print("Rule file is", self.flagging_file)
            for rule in self.flag_rules:
                print(rule)

        self._apply_flags()


    #----------------------------------------------------------------------------------------------
    def _make_tuple(self, gas):
        """ Make the result tuple from the flask data

        The names and fields of the tuple need to match the result tuples from flpro so they
        can be passed into the checkDb and updateDb methods of ccg_flaskdb
        """

        Row = namedtuple('row', ['event', 'gas', 'mf', 'flag', 'inst', 'adate', 'comment', 'modified'])

        a = []
        for i in self.raw.sampleIndices():

            row = self.raw.dataRow(i)

            record = self.flaskdb.measurementData(int(row.event), gas, row.date)
            if record is None:
                mf = -999.99
                inst = "XX"
            else:
                mf = record['value']
                inst = record['inst']
                flag = record['qcflag']
                comment = record['comment']

            row = Row._make((int(row.event), gas, float(mf), flag, inst, row.date, comment, False))

            a.append(row)

        return a

    #----------------------------------------------------------------------------------------------
    def _find_sample_data(self, event):
        """ Given an event number and analysis date, return the flask information for that event. """

        if event in self.flaskdb.sample_data:
            return self.flaskdb.sample_data[event]

        return None

    #----------------------------------------------------------------------------------------------
    def _save_tag(self, event, tagnum, comment):
        """ Save the applied tagnum and comment for the event. """

        self.taginfo[event].append((tagnum, comment))

    #----------------------------------------------------------------------------------------------
    def _find_pair_event(self, eventnum):
        """ Find the matching flask for eventnum.
        A match is where the sample site, date, time and method agree.
        Returns
            matching event number, or None if no match
        """

        # get sample data for given event number
        sampledata = self._find_sample_data(eventnum)
        tsitenum = sampledata['site_num']
        tsite = sampledata['code']
        tdate = sampledata['date']
        tme = sampledata['method']

        # skip certain site codes
        if tsite in ('TST', 'INX', 'MRC'):
            return None

        # now go through all events in raw file and try to find match
        for row in self.flaskdb.sample_data.values():

            # skip itself
            if row['event_number'] == eventnum: continue

            # check for matching pair
            if (tsitenum == row['site_num']
                and tdate == row['date']
                and tme == row['method']):

                return row['event_number']

        return None


    #--------------------------------------------------------------------------
    def printTable(self):
        """ Print table of results """

#        format1 = "%10s %4s %s  %10s %4s %10.2f %8s      %s  %s"
        format1 = "%10s %4s %s  %10s %4s %10.2f %8s      %s  "

        print("%50s\n" % (self.species + " Flask Flagging"))
        print("System:              %s" % self.system)
        print("Analysis Date:       %s" % (self.adate.strftime("%Y-%m-%d %H:%M")))
        print()
        print("   Event    Site  Sample Date           ID     Meth  Mole Fract   Inst      Analysis Date    Tags")
        print("-------------------------------------------------------------------------------------------------")

        for row in self.results:

            line = self._find_sample_data(row.event)
            if line is None:
                print(format1 % (0, 'XXX', "0000-00-00", "00:00:00", "None", "X",
                        row.mf, row.flag, row.inst, row.adate.strftime("%Y-%m-%d %H:%M"), row.comment))

            else:
                print(format1 % (row.event, line['code'], line['date'].strftime("%Y-%m-%d %H:%M"),
                         line['flaskid'], line['method'], row.mf, row.inst,
                         row.adate.strftime("%Y-%m-%d %H:%M")), end='') # row.comment), end='')
                if row.event in self.taginfo:
                    s = [str(tag[0])+" "+tag[1] for tag in self.taginfo[row.event]]
                    print(" ".join(s), end='')
                print()


        print("--------------------------------------------------------------------------------------------------")


    #--------------------------------------------------------------------------
    def printResults(self):
        """ Print out one line of results """

        format1 = "%10s %5s %3s %s %8s %1s %8.3f %3s %s %s"
        format1 = "%10s %5s %3s %s %8s %1s %8.3f %3s %s"

        for row in self.results:

            line = self._find_sample_data(row.event)
            if line is None:
                print(format1  % ('XXX', row.gas, '0000 00 00 00 00', 'None', 'X', row.mf,
                        row.flag, row.inst, row.adate.strftime("%Y %m %d %H %M"), ""))
            else:
                print(format1  % (row.event, row.gas, line['code'], line['date'].strftime("%Y %m %d %H %M"),
                        line['flaskid'], line['method'], row.mf, row.inst,
                        row.adate.strftime("%Y %m %d %H %M")), end='')  # row.comment), end='')
                if row.event in self.taginfo:
                    for tags in self.taginfo[row.event]:
                        print("%4d %s" % (tags[0], tags[1]), end='')
                print()


    #--------------------------------------------------------------------------
    def checkDb(self, devdb=False, verbose=False):
        """ Check the result string with the corresponding value in the database. """

        format1 = "%10s %5s %8.2f %3s %3s %s"

        database = "ccgg"
        if devdb: database = "mund_dev"
        db = ccg_dbutils.dbUtils(database=database, readonly=False)

        for result in self.results:

            record = self.flaskdb.measurementData(result.event, self.species, result.adate, result.inst)
            datanum = record['data_number']
            dbtags = db.getFlaskDataTags(datanum)

            line = format1 % (result.event, result.gas, result.mf, result.flag,
                    result.inst, result.adate.strftime("%Y %m %d %H %M"))


            if result.event in self.taginfo:
                tags = self.taginfo[result.event]
                if len(dbtags) > 0:
                    print(line, 'Tags', tags, ': Tags from database', dbtags)
                else:
                    print(line, 'Tags', tags, ': Tags from database - None')
            else:
                if len(dbtags) > 0:
                    print(line, 'Tags - None : Tags from database', dbtags)
                else:
                    if verbose:
                        print(line)


    #----------------------------------------------------------------------------------------------
    def updateDb(self, devdb=False, verbose=False):
        """ Update the database with results. """

        for result in self.results:
            if result.event in self.taginfo:
                date = result.adate.strftime("%Y-%m-%d")
                time = result.adate.strftime("%H:%M:%S")

                tags = self.taginfo[result.event]

                comments = []
                for tagnum, tagcomment in tags:
                    if verbose:
                        print("add tag number", tagnum, "to event", result.event, tagcomment)
                    ccg_utils.addTagNumber(result.event, result.gas, tagnum, result.inst, date, time, verbose=verbose, devdb=devdb, data_source=True)

                    # We need to save the tag comment in the flask_data comment field.
                    # But because multiple tags can be used, save all unique comments and
                    # join them together to put in comment field
                    comments.append(tagcomment)

                data = self.flaskdb.measurementData(result.event, result.gas, result.adate)
                datanum = data['data_number']

                c = list(set(comments))  # remove duplicate comments
                if len(data['comment']) == 0:
                    comment = " ".join(c)
                else:
                    comment = data['comment'] + " " + " ".join(c)

                query = "UPDATE flask_data SET "
                query += "comment='%s' " % comment
                query += "WHERE num=%s" % datanum
                if verbose:
                    print(query)
                self.flaskdb.db.doquery(query)


    #------------------------------------------------------------------
    def _check_for_qc(self):
        """ check if we need to use qc files """

        qc1 = None
        qc2 = None

        use_qc = False
        for rule in self.flag_rules:
            if rule.basis not in ['value', 'method', 'pair_diff', 'sample_date']:
                use_qc = True

        if use_qc:
            # gas specific qc file
            qcfile1 = "/ccg/%s/flask/%s/qc/%d/%s.qc" % (self.species.lower(), self.system, self.adate.year, self.rawfilename)
            if os.path.exists(qcfile1):
                qc1 = ccg_rawfile.Rawfile(qcfile1)

            # system wide qc file
            s = self.raw.instid.lower() + "." + self.species.lower()
            qcfile2 = "/ccg/%s_qc/flask/%d/%s.qc" % (self.system, self.adate.year, self.rawfilename.replace(s, self.system))
            if os.path.exists(qcfile2):
                qc2 = ccg_rawfile.Rawfile(qcfile2)

        return qc1, qc2

    #------------------------------------------------------------------
    def _apply_flags(self):
        """ Process the flagging rules on the results and apply flags if needed. """

        qc1, qc2 = self._check_for_qc()

        # apply rules to each flask
        for row in self.results:

            # don't apply flags to default data
            if row.mf < -900: continue

            # find the rules that could be applied to this flask
            rules = self._find_rules(row)

            for rule in rules:

                if rule.basis == "value":
                    if row.mf < rule.minval or row.mf > rule.maxval:
                        if self.debug:
                            print("Event", row.event, "Apply value tag", rule.tagnumber, "value of", row.mf, "outside range", rule.minval, rule.maxval)
                        self._save_tag(row.event, rule.tagnumber, rule.comment)

                elif rule.basis == "method":
                    if self.debug:
                        print("Event", row.event, "Apply method flag", rule.method)
                    self._save_tag(row.event, rule.tagnumber, rule.comment)

                elif rule.basis == "pair_diff":
                    pair_event = self._find_pair_event(row.event)
                    if pair_event:

                        # get mole fraction value for matching pair from results
                        for a in self.results:
                            if a.event == pair_event and a.gas == row.gas:
                                mr2 = a.mf
                                break

                        diff = abs(mr2 - row.mf)

                        # apply bad pair flag if difference is > max
                        if diff > rule.maxval:
                            if self.debug:
                                print("Event", row.event, "Apply pair diff flag %.2f" % diff, ">", rule.maxval)
                            self._save_tag(row.event, rule.tagnumber, rule.comment)

                elif rule.basis == "sample_date":
                    if self.debug:
                        print("Event", row.event, "Apply sample date flag", rule.sdate, rule.edate)
                    self._save_tag(row.event, rule.tagnumber, rule.comment)

                # basis should be a qc column name
                else:

                    # check in the gas specific qc file
                    if qc1:
                        self._check_qc_rule(rule, row, qc1)

                    # check in the system qc file
                    if qc2:
                        self._check_qc_rule(rule, row, qc2)


    #------------------------------------------------------------------
    def _check_qc_rule(self, rule, row, qc):
        """ Check if this rule is applied from this qc data """

        if rule.basis in qc.column_names:
            rownum = qc.findRow(row.adate)
            colidx = qc.column_names.index(rule.basis)
            bval = qc.data.T[colidx][rownum]
            if self.debug:
                print("Rule basis", rule.basis, "value is", bval, "min is", rule.minval, "max is", rule.maxval)
            if bval < rule.minval or bval > rule.maxval:
                if self.debug:
                    print("Event", row.event, "Apply %s flag" % rule.basis, bval, "outside range", rule.minval, rule.maxval)
                self._save_tag(row.event, rule.tagnumber, rule.comment)


    #------------------------------------------------------------------
    def _find_rules(self, row):
        """ Find the rules that apply to this row of data.
        All checks of the rules must be True for the rule to be applied.
        """

        sampledata = self._find_sample_data(row.event)

        rules = []
        for rule in self.flag_rules:

            if not self._check_rule(row.gas.upper(), rule.gas.upper()): continue
            if not self._check_rule(sampledata['code'], rule.site): continue
            if not self._check_rule(row.inst, rule.inst): continue
            if not self._check_rule(sampledata['flaskid'], rule.flaskid): continue
            if not self._check_rule(sampledata['method'], rule.method): continue
            if not self._check_rule(sampledata['strategy_num'], rule.strategy): continue
            if rule.basis == "sample_date":
                sdt = sampledata['date']
                if sdt < rule.sdate: continue
                if sdt > rule.edate: continue
            else:
                if row.adate < rule.sdate: continue
                if row.adate > rule.edate: continue

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
        """

        names = ['gas', 'site', 'sdate', 'edate', 'flaskid', 'method', 'strategy', 'inst', 'basis', 'minval', 'maxval', 'tagnumber', 'comment']
        FlagRules = namedtuple('rule', names)

        self.flag_rules = []
        lines = ccg_utils.cleanFile(self.flagging_file, True)
        for line in lines:
            a = line.split(";")        # separate parameters from comment
            params = a[0].strip()
            if len(a) == 2:
                comment = a[1].strip()
            else:
                comment = ""
            [gas, site, sdate, edate, flaskids, method, strategy, instid, basis, minval, maxval, tagnum] = params.split()

            # skip rules not for our gas
            if not self._check_rule(self.species.upper(), gas.upper()): continue

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

            tagnum = int(tagnum)

            t = (gas, site, sdate, edate, flaskids, method, strategy, instid, basis, minval, maxval, tagnum, comment)
            self.flag_rules.append(FlagRules._make(t))



if __name__ == "__main__":

    rawfile = "/ccg/co2/flask/magicc-3/raw/2022/2022-06-16.1720.pc2.co2"
    f = Flag(rawfile, debug=True)

#    print(f.taginfo)
    for evt in f.taginfo:
        print(evt, f.taginfo[evt])

#    f.printTable()
    f.updateDb()
