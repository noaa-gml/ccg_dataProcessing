#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Update the tank_history database table with
new working tank information that comes in from the stations.
Only inserts NEW tank data into table.
"""
from __future__ import print_function

import sys
import datetime
import argparse
from dateutil.parser import parse

sys.path.append("/ccg/src/python3/nextgen")

import ccg_refgasdb     # for assigned values
import ccg_tankhistory  # for tank usage at site
import ccg_cal_db        # for calibration results
import ccg_utils


# Get the command-line options
epilog = """
Example:
  update_refgas.py -u brw co2 reftanks.20200610.csv

 No options means print out merged strings to stdout.
"""
parser = argparse.ArgumentParser(
        description="Merge new working tank data into existing tank history database table.",
        epilog=epilog)

parser.add_argument('-u', '--update', action="store_true", default=False, help="Update database table with new entries")
parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="gas species to update")
parser.add_argument('worktankfile', help="File with worktank info downloaded from observatory.")

options = parser.parse_args()

changes = False

stacode = options.stacode.upper()
if stacode == 'BRW':
    sysname = 'lgr'
    gases = ['CO2', 'CH4', 'N2O', 'CO']
elif stacode == 'MLO':
    sysname = 'picarro'
    gases = ['CO2', 'CH4', 'CO']
elif stacode == 'CAO':
    sysname = 'picarro'
    gases = ['CO2', 'CH4', 'CO','N2O']
elif stacode == 'SMO':
    sysname = 'picarro'
    gases = ['CO2', 'CH4', 'CO']
else:
    sysname = 'ndir'
    gases = ['CO2']


worktankfile = options.worktankfile

# get all current entries in the tank history for this site and system
hist = ccg_tankhistory.tankhistory(location=stacode, system=sysname)

# Get last start date and serial number for each tank type
lastdate = {}
lastsn = {}
for row in hist.data:
    lastdate[row.label] = row.start_date
    lastsn[row.label] = row.serial_number

#print(lastdate)
#print(lastsn)
#sys.exit()


mdate = datetime.datetime(1900, 1, 1)

# read in worktanks file, remove comments
# Lines look like
#CA04496,co2,REF,R0,408.36,2022-05-18T14:00:00,2022-05-18T14:12:05
data = ccg_utils.cleanFile(worktankfile)


for line in data:
#    print("\n\n", line)

    (sernum, gas, stype, label, value, startdate, entrydate) = line.split(',')

#    if label not in lastsn: continue

    start_date = parse(startdate)
#    print(start_date)


    comment = "%s working tank %s" % (stacode, label)
    level = "Tertiary"
    comment = "%s standard tank %s" % (stacode, label)

    if label not in lastdate:
        lastdate[label] = datetime.datetime(1970, 1, 1)
    if label not in lastsn:
        lastsn[label] = "000000"

    # if start date from file is > last date from database
    # and the tank has a different serial number
    # for this label, then add new entry to database table
    if start_date > lastdate[label] and sernum != lastsn[label]:

#        print(line)
        changes = True

        print("insert into history", stacode, sysname, sernum, label, start_date, gases)
        if options.update:
            ccg_tankhistory.insert_tank_history(stacode, sysname, sernum, label, start_date, gases)

    # check if there is an entry in the scales table for this serial number
    # skip Target tanks because the observatory refgas tables are too messed up
    if label != "R0":
        gas = options.gas

        # get any assignments for this tank and gas
        refgas = ccg_refgasdb.refgas(sp=gas, sn=[sernum], readonly=False)  # , startdate=start_date, debug=False)

        # Check if there is already a scale assignment for this tank and gas
        # If there are assignments, check that fill code for the assignment is the same
        # as the fill code for the date. If not, add new entry
        # Use average of calibrations for assigned value, not what operator has entered.
        addnew = False
        r = refgas.getAssignment(sernum, start_date)
        cals = ccg_cal_db.Calibrations(sernum, gas)
        if cals.numcals == 0:
            print("WARNING: No calibration data for", sernum, gas)

        fillcode = cals.getFillCode(start_date)
#        value = cals.getAverage(sernum, gas, fillcode)
        calfit = cals.getValue(gas, fillcode)
        if r is None:
            addnew = True
        else:
            afillcode = cals.getFillCode(r.start_date)
            if afillcode != fillcode:
                addnew = True

#        print(sn, gas, fillcode, addnew, value)

        if addnew:
            changes = True
            print("enter into", gas, "scale assignments", sernum, start_date, calfit, level, comment)
            if options.update:
#                refgas.insert(sernum, start_date, coef0=value, level=level, comment=comment)
                refgas.insertFromFit(sernum, start_date, calfit, level=level, comment=comment)

# if changes are needed, return 1
# This is so that automatic updates from scripts can tell if an email needs to be sent
if changes:
    sys.exit(1)
else:
    sys.exit(0)
