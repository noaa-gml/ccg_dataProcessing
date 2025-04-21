#! /usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Program for getting/plotting of time dependent fit
to tank calibration data.

2024-11-22
   - Added level and comment options to command line.
   - Changed output format for printed results.
   - Included calibration indexes to fit result tuple to be
     used for updates, using new scale_assignment_calibrations table.
"""

import sys
import os
import argparse
import subprocess
import datetime
import math
import json
from dateutil.parser import parse
import pandas as pd
import numpy as np

import matplotlib.pyplot as plt

sys.path.insert(1, "/ccg/python/ccglib")
import ccg_cal_db
import ccg_dbutils
import ccg_calfit
import ccg_dates  # for v02, use more of these functions to simplify code dealing with dates.
import ccg_refgasdb
#import ccg_flaskunc
import ccg_uncdata_all


#######################################################################
def calc_value(dt, result):
    """ calculate the fit value at time dt """

    x = dt - result.tzero
    val = result.coef0 + result.coef1*x + result.coef2*x*x

    #unc
    ci = math.sqrt(result.unc_c0**2 + (result.unc_c1*x)**2 + (result.unc_c2*x*x)**2)
    unc = math.sqrt(ci**2 + result.sd_resid**2)

    return val, unc


#######################################################################
def get_fill_code(sernum, opts, cals):
    """ if fillcode not passed in (or if more than one sn passed in)
    ask user which fill code to use for sn
    """

    if opts.fillcode and len(opts.serial_number) == 1:
        fillcode = opts.fillcode

    else:
        fillcodes = [c['code'] for c in cals.fill]

        print("Available fill codes for %s" % (sernum))
        fill_list = cals.showFillList()
        print(fill_list)

        # ask user which fill code to use
        msg = "Enter fill code to process: "
        ans = input("%s\n>>> " % msg)
        #confirm passed fc is valid, exit if not
        if ans.upper() not in fillcodes:
            msg = "Passed fillcode (%s) is not valid, exiting ..." % (ans)
            sys.exit(msg)

        fillcode = ans.upper()

    return fillcode

#######################################################################
def get_grav_cal(sernum, gas, cals):
    """ get gravimetric calibration for tank sernum """

    tmp_data = {}
    cmd = '/ccg/bin/get_standard_value.py --convert_units --info --scale=gravimetric '
    cmd = "%s  -d %s  --sp=%s %s" % (cmd, cals.cals[0]["date"], gas, sernum)
    print("Getting original gravimetric value:  %s" % cmd, file=sys.stderr)
    result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)

    rr = result.stdout.decode('utf-8')
    rr = rr.rstrip("\t\n")
    if len(rr) == 0: return None

    (gsn, gyr, gmo, gdy, gsp, gval, gunc, j, gflg) = rr.split()

    tmp_data["idx"] = 0
    tmp_data["serial_number"] = gsn
    dt = datetime.date(int(gyr), int(gmo), int(gdy))
    tmp_data["date"] = dt
    dt = datetime.timedelta(hours=0, minutes=0, seconds=0)
    tmp_data["time"] = dt
    tmp_data["dd"] = ccg_dates.decimalDate(int(gyr), int(gmo), int(gdy))
    tmp_data["species"] = gas
    tmp_data["mixratio"] = float(gval)
    tmp_data["stddev"] = 0.0
    tmp_data["meas_unc"] = float(gunc)
    tmp_data["num"] = 1
    tmp_data["method"] = "gravimetric"
    tmp_data["inst"] = "grav"
    tmp_data["system"] = "grav"
    tmp_data["pressure"] = 0
    tmp_data["flag"] = gflg
    tmp_data["location"] = "na"
    tmp_data["regulator"] = "na"
    tmp_data["notes"] = "gravimetric value"
    tmp_data["mod_date"] = "%4d-%02d-%02d" % (int(gyr), int(gmo), int(gdy))
    tmp_data["fillcode"] = fillcode
    tmp_data["typeB_unc"] = 0.0
    tmp_data["mean_residual"] = -999.99
    tmp_data["linear_residual"] = -999.99
    tmp_data["quadratic_residual"] = -999.99
    tmp_data["auto_residual"] = -999.99

    return tmp_data

#######################################################################
def edit_cals(gas, cals, tempfile):
    """ allow user to edit calibration data """

    header = "idx sn    fc   date     time  dd     sp     system   inst   press   value   sd meas_unc n  flag   typeB_unc location regulator method mod_date  # comment"
    output = '#%s' % (header)
    for dline in cals.cals:
        #print(dline)
        t = "%s" % dline["time"]
        (hr, mn, sc) = t.split(':')

        output += "\n%-8s" % (dline["idx"])
        output += " %-12s" % (dline["serial_number"])
        output += " %-3s" % (dline["fillcode"])
        output += " %4d-%02d-%02d" % (dline["date"].year, dline["date"].month, dline["date"].day)
        output += " %8s" % (dline["time"])
        output += " %12.5f" % (dline["dd"])
        output += " %6s" % dline["species"]
        output += " %8s" % dline["system"]
        output += " %5s" % dline["inst"]
        output += " %5s" % dline["pressure"]
        output += " %12.3f" % dline["mixratio"]
        output += " %8.3f" % dline["stddev"]
        output += " %8.3f" % dline["meas_unc"]
        output += " %2d" % dline["num"]
        output += " %s" % dline["flag"]
        output += " %6.2f" % dline["typeB_unc"]
        output += " %3s" % dline["location"]
        if not dline["regulator"]: dline["regulator"] = 'na'
        output += " %10s" % dline["regulator"]
        output += " %10s" % dline["method"]
        output += " %s" % dline["mod_date"]
        output += " # %s" % dline["notes"]
    print(output)

    msg = "\n\nDo you want to make offline edit/selection changes? (yes/no)"
    edit_ans = input("%s\n>>> " % msg)

    if edit_ans.lower() == 'yes' or edit_ans.lower() == 'y':

        edited_data = []

        # set up temp data dictionary
        # open temp file
        fp = open(tempfile, 'w')
        fp.write(output)
        fp.close()
        EDITOR = os.environ.get('EDITOR', 'vim')
        subprocess.call([EDITOR, tempfile])

        print("continuing with fit")
        # read data back in
        fp = open(tempfile, 'r')
        input_data = fp.readlines()
        fp.close()
        # loop through and substitue values in cals.cals
        for line in input_data:
            tmp_data = {}
            line = line.lstrip()
            if line.startswith("#"): continue
            line = line.rstrip('\r\n')
            (tdata, notes) = line.split('#')
            if len(tdata.split()) == 21:
                (idx, sn, fc, d, t, dd, sp, tsystem, tinst, press, val, sd, m_unc, n, flg, b_unc, loc, reg, method, md, mt) = tdata.split()
            elif len(tdata.split()) == 20:
                (idx, sn, fc, d, t, dd, sp, tsystem, tinst, press, val, sd, m_unc, n, flg, b_unc, loc, reg, method, md) = tdata.split()
            elif len(tdata.split()) == 19:
                (idx, sn, fc, d, t, dd, sp, tsystem, tinst, press, val, sd, m_unc, n, flg, b_unc, loc, method, md) = tdata.split()
                reg = 'none'
            else:
                print("unknown number of fields")
                print("len(tdata.split()): %s on line: %s" % (len(tdata.split()), line))
                sys.exit()

            tmp_data["idx"] = idx
            tmp_data["serial_number"] = sn
            (yr, mo, dy) = d.split('-')
            dt = datetime.date(int(yr), int(mo), int(dy))
            tmp_data["date"] = dt
            (hr, mn, sc) = t.split(':')
            dt = datetime.timedelta(hours=int(hr), minutes=int(mn), seconds=int(sc))
            tmp_data["time"] = dt
            tmp_data["dd"] = float(dd)
            tmp_data["species"] = gas
            tmp_data["mixratio"] = float(val)
            tmp_data["stddev"] = float(sd)
            tmp_data["meas_unc"] = float(m_unc)
            tmp_data["num"] = int(n)
            tmp_data["method"] = method
            tmp_data["inst"] = tinst
            tmp_data["system"] = tsystem
            tmp_data["pressure"] = press
            tmp_data["flag"] = flg
            tmp_data["location"] = loc
            tmp_data["regulator"] = reg
            tmp_data["notes"] = notes
            tmp_data["mod_date"] = md
            tmp_data["fillcode"] = fc
            tmp_data["typeB_unc"] = float(b_unc)

            edited_data.append(tmp_data)

        return edited_data

    # else after "do you want to edit" question - if answer "no" just use data as is
    return None

#######################################################################
def save_result(fit_types):
    """ write the calibration fit data to a temporary file """

    HOME = os.getenv("HOME")
    tempsavefile = "%s/tempfile_calculate_drift_result.txt" % HOME # temp file for fit results


    if len(fit_types) == 1:
        ans = list(fit_types.keys())[0]
        print("saving %s" % ans)
    else:
        # ask which fit to record
        msg = "Enter fit type to write to temp file %s\nOptions are: " % tempsavefile
        for ft in fit_types:
            msg = msg + "\n\t%s" % ft
        ans = input("%s\n>>> " % msg)

    if ans.lower() in ['auto', 'mean', 'linear', 'lin', 'quadratic', 'quad']:
        if ans.lower() == "lin": ans = "linear"
        if ans.lower() == "quad": ans = "quadratic"

        fit = fit_types[ans]
        if ans.lower() == "auto":
            if fit.coef1 != 0.0 and fit.coef2 != 0.0:
                ans = "auto fit (quadratic)"
            elif fit.coef1 != 0.0 and fit.coef2 == 0.0:
                ans = "auto fit (linear)"
            else:
                ans = "auto fit (mean)"

        fit_fmt = "%s  %s  %s  %s  %s  %s  %s  %s  0.0  %s"
        fit_str = fit_fmt % (fit.tzero, fit.coef0, fit.unc_c0, fit.coef1, fit.unc_c1, fit.coef2,
                             fit.unc_c2, fit.sd_resid, fit.n)
    else:
        print("Skipping save results.")
        return


    print("writing %s fit to temp file (%s)" % (ans.lower(), tempsavefile))
    print("%s fit results:  %s" % (ans.lower(), fit_str))
    fp = open(tempsavefile, 'w')
    fp.write(fit_str)
    fp.close()

#######################################################################
def update_assignment_db(serial_num, fitdata, scalename, fill_date, level, user_comment=None):
    """ insert a new row into the scale_assignments database table """

    existing = get_existing_assignments(serial_num, scalename, fillcode)

#    if len(existing) > 0:
    if existing is not None:
        start_date = existing[0]['start_date']
        if len(existing) > 1:
            print("Multiple assignments already exist.  Need to update manually")
            return
    else:
        start_date = fill_date

    #comment = "Automatic entry from caldrift.py"
    auto_comment = "Automatic entry from caldrift.py"
    if user_comment is not None:
        comment = "%s. %s" % (auto_comment, user_comment)
    else:
        comment = "%s" % (auto_comment)

    ref = ccg_refgasdb.refgas(SPECIES, serial_num, scalename, moddate=MODDATE, readonly=False)
    ref.insertFromFit(serial_num, start_date, fitdata, level=level, comment=comment)

#    sql = "insert into scale_assignments set "
#    sql += "serial_number='%s', " % serial_num
#   sql += "scale_num=%s, " % scalenum
#    sql += "start_date='%s', " % start_date
#    sql += "tzero=%f, " % fitdata.tzero
#    sql += "coef0=%f, " % fitdata.coef0
#    sql += "coef1=%f, " % fitdata.coef1
#    sql += "coef2=%f, " % fitdata.coef2
#    sql += "unc_c0=%f, " % fitdata.unc_c0
#    sql += "unc_c1=%f, " % fitdata.unc_c1
#    sql += "unc_c2=%f, " % fitdata.unc_c2
#    sql += "sd_resid=%f, " % fitdata.sd_resid
#    sql += "assign_date='%s', " % datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
#    sql += "level='%s', " % level
#    sql += "comment='%s'" % comment
#    print(sql)

#    if existing is not None:
#        if len(existing) > 1:
#            print("Multiple assignments already exist.  Need to update manually")
#            print("Possible sql statement:")
#            print(sql)
#            return

#    r = db.doquery(sql)

#######################################################################
def get_existing_assignments(serial_num, scale, fillcode):
    """ get exisiting tank assignments from database """

    sql = "select * from scale_assignments_view where "
    sql += "serial_number='%s' " % serial_num
    sql += "and scale='%s' " % scale
    sql += "and fill_code='%s' " % fillcode
    sql += "and current_assignment=1 "
    sql += "order by assign_date"

    result = db.doquery(sql)

    return result

#######################################################################
def check_assignment_db(serial_num, gas, fitdata, scale, fillcode, fill_date, verbose=False):
    """ check result with existing data in the scale_assignments database table """

    result = get_existing_assignments(serial_num, scale, fillcode)
    if result is None:
        print("No entries found for", serial_num)
        return

    if verbose:
        print("\nExisting entry in scale_assignments:")
        for row in result:
#            print(row)
            start_date = row['start_date']
            print("Gas:           %s" % gas.upper())
            print("Serial Number: %s" % serial_num)
            print("Fill Code:     %s" % fillcode)
            print("Fill Date:     %s" % fill_date)
            print("Start Date:    %s" % row['start_date'])
            print("Assign Date:   %s" % row['assign_date'])
            print("Time zero:     %s" % row['tzero'])
            print("Coeff. 0:      %s" % row['coef0'])
            print("Coeff. 1:      %s" % row['coef1'])
            print("Coeff. 2:      %s" % row['coef2'])
            print("Unc Coeff. 0:  %s" % row['unc_c0'])
            print("Unc Coeff. 1:  %s" % row['unc_c1'])
            print("Unc Coeff. 2:  %s" % row['unc_c2'])
            print("Residual Stdv. %s" % row['sd_resid'])
            print("N:             %s" % row['n'])
            print("Comment:       %s" % row['comment'])

        print("\nProcessed data:")
        print("Gas:           %s" % gas.upper())
        print("Serial Number: %s" % serial_num)
        print("Fill Code:     %s" % fillcode)
        print("Fill Date:     %s" % fill_date)
        print("Start Date:    %s" % start_date)
        print("Assign Date:   %s" % datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        print("Time zero:     %s" % fitdata.tzero)
        print("Coeff. 0:      %s" % fitdata.coef0)
        print("Coeff. 1:      %s" % fitdata.coef1)
        print("Coeff. 2:      %s" % fitdata.coef2)
        print("Unc Coeff. 0:  %s" % fitdata.unc_c0)
        print("Unc Coeff. 1:  %s" % fitdata.unc_c1)
        print("Unc Coeff. 2:  %s" % fitdata.unc_c2)
        print("Residual Stdv. %s" % fitdata.sd_resid)
        print("N:             %s" % fitdata.n)

    else:

        print("Existing entry in scale_assignments_view:")
        _format = "%-15s %6s %-13s     %10s %1s    %-15s %9.4f %10.6f %10.6f %10.6f %3d %s"
#        _format = "%-15s %6s %-13s     %10s %1s    %-15s %9.4f %10.6f %10.6f %10.6f %s"
        _format1 = "%22s %-16s %-16s %-15s %-9s %-10s %-10s %-10s %3s %s"
        print(_format1 % ("Gas", "Serial Number", "Fill Date, Code", "Start Date", "Tzero", "coef0", "coef1", "coef2", "n", "Assign Date"))
        print("-"*130)
        start_date = fill_date
        for row in result:
            print(_format % (
                "Existing data:",
                row['species'],
                row['serial_number'],
                fill_date,
                row['fill_code'],
                row['start_date'],
                row['tzero'],
                row['coef0'],
                row['coef1'],
                row['coef2'],
                row['n'],
                row['assign_date']))

            start_date = row['start_date']

        print(_format % ("New data:",
            gas.upper(),
            serial_num,
            fill_date,
            fillcode,
            start_date,
            fitdata.tzero,
            fitdata.coef0,
            fitdata.coef1,
            fitdata.coef2,
            fitdata.n,
            datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")))

#######################################################################
# checks/configuration
col_arr = ['r','b','g','c','m','y','b','r','m','g','r','b','m','y','r','b','g','c','m','y','b','r','m','g','r','b','m','y']
sym_arr = ['o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x']

tempfile = "%s/tempfile_calculate_drift.txt" % os.getenv("HOME") # temp file for editing data

parser = argparse.ArgumentParser(description="Calculate value assignment for cylinders based on fitting calibration histories. ")

#        epilog="Only one of the output options should be given.  No options means print out a single result line to stdout.")

group = parser.add_argument_group("Data Selection Options")
group.add_argument('--fillcode', type=str.upper, help="Specify fillcode. Default is None which causes code to return list and ask")
group.add_argument('--inst', help="Specify inst codes to pull from database, default is all. For example --inst=L9,PC1 ")
group.add_argument('--official', action="store_true", help="Use only official calibration systems. ")
group.add_argument('--uncfile', help="Pass in path to non-default scale transfer uncrtainty table used for weights in fit.")
group.add_argument('--database', default="reftank", help="Select database to compare/update results. Default is 'reftank'.")
group.add_argument('--use_grav', action="store_true", default=False, help=" Add in the original gravimetric value from DB tables. Default is False.")
#need to add use grav value from DB

group = parser.add_argument_group("Fitting Options")
group.add_argument('--edit', action="store_true", default=False, help="Allow user to select/edit data offline prior to fit.")
group.add_argument('--fit_inst', help="Specify instrument to use to value assign tank. This is a subset of inst displayed. For example --inst=L9,PC1 ")
group.add_argument('--fit_official', action="store_true", default=False, help="Use only official calibration instruments in the fit.  This is an alternative to --fit_inst ")
group.add_argument('--noauto_fit', action="store_true", default=False, help="Don't show results of auto significance testing of fits.")
group.add_argument('--mean', action="store_true", default=False, help="Show weighted mean (default is False).")
group.add_argument('--linear', action="store_true", default=False, help="Show linear fit (default is False).")
group.add_argument('--quadratic', action="store_true", default=False, help="Show quadratic fit (default is False).")
group.add_argument('--include_flag', default=".", help="Specify flags to include in fit (default is '.'). For example --include_flag=.,S,r")
group.add_argument('--fit_daterange', default=None, help="Specify date range of results to use in fit. For example --fit_daterange=2014:2020 or --fit_daterange=2014-01-01:2020-12-31")

group = parser.add_argument_group("Offline re-processing Options")
group.add_argument('--reprocess', action="store_true", default=False, help="Reprocess calibrations (default is False). For example --reprocess=True")
group.add_argument('--scale', help="Scale to use for reprocessing (default is current). For example --scale=CO_X2004")
group.add_argument('-w', '--refgasfile', help="Choose a text reference gas file instead of database for assigned values.")
group.add_argument('-r', '--respfile', help="Select a non-standard response file for reprocessing.")
group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
group.add_argument('--moddate', help="Use values for standards before this modification date. For example --moddate=2014-05-01")
group.add_argument('--program', help="Path to non-standard version of calpro for reprocessing. For example --program=/home/ccg/.../.../test_version_calpro.py")
group.add_argument('--extra_option', help="List of options to pass to calpro.py for reprocessing, option and value separated by colon, additional option/value separated by comma. Leave out '--'.  For example c13respfile:temp_ResponseCurves.CO2C13,018respfile:temp_ResponseCruves.CO2O18,etc")

group = parser.add_argument_group("Output Options")
group.add_argument('--plot_assigned', action="store_true", default=False, help="Plot line for current assigned value. Default is False")
group.add_argument('--plot_residuals', action="store_true", default=False, help="** NOT YET. HARDCODE TRUE FOR NOW Plot residuals from fit. Default is False")
group.add_argument('--plot_uncertainty', action="store_true", default=False, help="Create a plot of uncertainty of assignment.  The 1-sigma predictive interval of the value assignment as a function of time plotted on data plot")
group.add_argument('--plot_flag', help="Flag to include in plots but not in the fit (default is None). For example --plot_flag=S")
group.add_argument('--plot', action="store_true", default=False, help="Create a plot of data.  Not needed if any of the other plot_ options are set.")
group.add_argument('--value_date', help="date to return a value, unc for the fits. Use for testing")
group.add_argument('--save_result', action="store_true", default=False, help="Pause and ask user for fit type to save to tempfile (default is False)")
group.add_argument('--json', action="store_true", default=False, help="Print results in json format.")
group.add_argument('--fit_debug', action="store_true", default=False, help="Used to print debugging information on statistical testing used in auto fit routine (default is False)")
group.add_argument('--date_extension', default=0.2, help="Decimal years to extend plot past last calibration result (default is 0.2). For example --date_extension=1.5")
group.add_argument('--min_date', default=None, help="Minimum date for plotting (default is cylinder fill date). For example --min_date=2020-01-01")
group.add_argument('--info', action="store_true", default=False, help="Print out input data and residuals.")
group.add_argument('--vertical_mark', default=None, help="Dates to place vertical mark on plots")
group.add_argument('--level', default='Tertiary', help="Level in the hierarchy (primary, secondary, tertiary, other). Default is tertiary. For example --level=tertiary")
group.add_argument('--comment', default=None, help="Comment to add to DB during upload. USE QUOTES AROUND THIS ARGUMENT. For example --comment='use data through 2024'")
group.add_argument('-c', '--check', action="store_true", default=False, help="Check existing scale assignment with computed results.")
group.add_argument('-u', '--update', action="store_true", default=False, help="Save fit parameters in scale assignment database table. Only one fit type can be used.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Print out extra information.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")

# required arguments
parser.add_argument('species', help="Specify species to value assign tank.")
parser.add_argument('serial_number', nargs='+', help="Tank serial numbers to process")

options = parser.parse_args()

mainstart = datetime.datetime.now()

# save fit types requested
# only add entry for fit types that will be used
fit_types = {}
if not options.noauto_fit: fit_types['auto'] = True
if options.mean:           fit_types['mean'] = True
if options.linear:         fit_types['linear'] = True
if options.quadratic:      fit_types['quadratic'] = True

if options.official and options.inst:
    msg = 'CONFLICT: both options.inst and options.official passed in, exiting ...'
    sys.exit(msg)

SPECIES = options.species

# open database connection
if options.update:
    db = ccg_dbutils.dbUtils(database=options.database, readonly=False)
else:
    db = ccg_dbutils.dbUtils(database=options.database, readonly=True)

# if scale not passed, use current scale
if options.scale:
    SCALE = options.scale
    scale_num = db.getScaleNum(SCALE)
    if scale_num is None:
        sys.exit("Unknown scale %s" % SCALE)
else:
    d = db.getCurrentScale(SPECIES)
    SCALE = d['name']
    scale_num = d['idx']

# conf moddate
if options.moddate:
    MODDATE = options.moddate
else:
    now = datetime.datetime.now()
    MODDATE = now.strftime("%Y-%m-%dT%H:%M:%S")

# fit instruments
if options.fit_inst:
    if options.fit_official:
        msg = 'CONFLICT: both options.fit_inst and options.fit_official passed in, exiting ...'
        sys.exit(msg)

    fit_inst_list = list(options.fit_inst.upper().split(','))
else:
    fit_inst_list = None

# flags to include in fit. Must specify all flags to be used.
include_flag = options.include_flag.split(',')

# set the date range to include in the fit - outside of this will be plotted but not included in the fits
if options.fit_daterange:
    rr = options.fit_daterange.split(':')

    if len(rr) == 1:
        sd = rr[0]
        ed = rr[0]
    elif len(rr) == 2:
        sd = rr[0]
        ed = rr[1]
    else:
        msg = "fit date range %s is not formated correctly" % rr
        sys.exit(msg)

    #format sd
    rr = sd.split('-')
    if len(rr) == 1:
        d = "%s-01-01" % rr[0]
    elif len(rr) == 2:
        d = "%s-%s-01" % (rr[0], int(rr[1]))
    elif len(rr) == 3:
        d = "%s-%02d-%02d" % (rr[0], int(rr[1]), int(rr[2]))
    else:
        msg = "date %s not formated correctly" % rr
        sys.exit(msg)

#    fit_startdate = datetime.datetime.strptime(d, '%Y-%m-%d')
    fit_startdate = parse(d)

    #format ed
    rr = ed.split('-')
    if len(rr) == 1:
        d = "%s-12-31" % rr[0]
    elif len(rr) == 2:
        dy_arr = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
        month = int(rr[1])
        year = int(rr[0])
        days = dy_arr[month-1]
        if (month == 2 and ((year%400 == 0) or ((year%100 != 0) and (year%4 == 0)))): days += 1
        d = "%s-%02d-%02d" % (year, month, days)

    elif len(rr) == 3:
        d = "%s-%02d-%02d" % (rr[0], int(rr[1]), int(rr[2]))
    else:
        msg = "date %s not formated correctly" % rr
        sys.exit(msg)

#    fit_enddate = datetime.datetime.strptime(d, '%Y-%m-%d')
    fit_enddate = parse(d)

else:
    fit_startdate = datetime.datetime(1900, 1, 1)
    fit_enddate = datetime.datetime.now()

# keep passed level for uploading to DB
if options.level.lower() == 'primary':
    level = "Primary"
elif options.level.lower() == 'secondary':
    level = "Secondary"
elif options.level.lower() == 'tertiary':
    level = "Tertiary"
elif options.level.lower() == 'other':
    level = "Other"
else:
    msg = "Level '%s' not recognized, needs to be 'primary', 'seconday', 'tertiary', or 'other'. Exiting ..." % (options.level)
    sys.exit(msg)
    

# set list of dd's for vertical marks on plot
if options.vertical_mark:
    tmp = options.vertical_mark.split(',')
    vertical_mark_list = [ccg_dates.decimalDateFromDatetime(parse(d)) for d in tmp]
else:
    vertical_mark_list = None


# flags to include in plot, these are flags in addition to '.'
plot_flag = ['.']
if options.plot_flag:
    plot_flag = plot_flag + options.plot_flag.split(',')


if not options.mean and not options.linear and not options.quadratic and options.noauto_fit:
    msg = 'CONFICT: no fit specified, require at least one of --mean, --linear, --quadratic if --noauto_fit is set'
    sys.exit(msg)

# conf call for reprocessing
if options.program:
    calpro_cmd = options.program
else:
    calpro_cmd = '/ccg/bin/calpro.py '

if options.scale:      calpro_cmd += " --scale=%s" % SCALE
if options.respfile:   calpro_cmd += " --respfile=%s" % options.respfile
if options.refgasfile: calpro_cmd += " --refgasfile=%s" % options.refgasfile
if options.peaktype:   calpro_cmd += " --peaktype=%s" % options.peaktype

if options.extra_option:
    #ex "List of options to pass to calpro.py for reprocessing, option and value separated by colon, additional option/value separated by comma. Leave out '--'.
    #  For example c13respfile:temp_ResponseCurves.CO2C13;018respfile:temp_ResponseCruves.CO2O18;etc")
    for ext_opt in options.extra_option.split(','):
        if ':' in ext_opt:
            opt, opt_value = ext_opt.split(':')
            calpro_cmd += " --%s=%s" % (opt, opt_value)
        else:
            opt = ext_opt
            opt_value = ' '
            calpro_cmd += " --%s" % opt
    if options.debug: print("-- %s" % calpro_cmd)

# print some stuff
if options.verbose:
    print("\n----")
    print("temp data file: %s" % tempfile)
    print("Species: %s" % SPECIES)
    print("Scale: %s" % SCALE)
    print("reprocess option:  %s" % options.reprocess)
    if options.reprocess: print("reprocess cmd: %s" % calpro_cmd)
    print("inst: %s" % options.inst)
    print("official: %s" % options.official)
    print("edit:  %s" % options.edit)
    print("include flag: ", include_flag)
    print("plot flag: ", plot_flag)
    print("use_grav: ", options.use_grav)
    print("auto fit: %s" % (not options.noauto_fit))
    print("fit_daterange: %s -> %s" % (fit_startdate.date(), fit_enddate.date()))
    print("----\n")

# flask uncertainty. These are used if no calibration uncertainty
#uncfile = "/ccg/%s/flask/uncertainty.%s" % (SPECIES.lower(), SPECIES.lower())
#flaskunc = ccg_flaskunc.dataUnc(uncfile)
flaskunc = ccg_uncdata_all.dataUnc('flask', SPECIES.lower(), uncfile=options.uncfile)


#------------------------------------------------------------
# loop through each serial number passed in
for tank_serial_number in options.serial_number:

    # get all data from DB for sn to let us find the available fill codes
    cals = ccg_cal_db.Calibrations(tank=tank_serial_number,
                                gas=SPECIES,
                                uncfile=options.uncfile,
                                database=options.database)

    fillcode = get_fill_code(tank_serial_number, options, cals)

    for line in cals.fill:
        if line['code'] == fillcode:
            filldate = line['date']

    if options.verbose:
        print("processing:  %s   fillcode: %s    filldate: %s" % (tank_serial_number, fillcode, filldate))

    if options.plot_assigned:
        ref = ccg_refgasdb.refgas(SPECIES, [tank_serial_number], SCALE, moddate=MODDATE)
#        for line in ref.refgas: print(line)

    # now get data for tank/fill/instruments (the second call allows inst/sp/ filters)
    cals = ccg_cal_db.Calibrations(tank=tank_serial_number,
                                  gas=SPECIES,
                                  syslist=options.inst,
                                  fillingcode=fillcode,
                                  date=None,
                                  method=None,
                                  official=options.official,
                                  uncfile=options.uncfile,
                                  notes=True,
                                  database=options.database)

    # add in gravimetric values if asked for
    if options.use_grav:
        grav_cal = get_grav_cal(tank_serial_number, SPECIES, cals)
        if grav_cal:
            cals.cals.insert(0, grav_cal)



    # if requested, reprocess the rawfiles - substitute values back into cals.cals
    #------------------------------------------------------------
    if options.reprocess:
        for dline in cals.cals:
            (hr, mn, sc) = str(dline["time"]).split(':')
            rawfile = "/ccg/%s/cals/%s/raw/%s/%4d-%02d-%02d.%02d%02d.%s.%s" % (SPECIES.lower(), dline["system"].lower(), dline["date"].year,
                dline["date"].year, dline["date"].month, dline["date"].day, int(hr), int(mn), dline["inst"].lower(), SPECIES.lower())
            cmd = "%s %s" % (calpro_cmd, rawfile)

            # reprocess rawfile with calpro_cmd if asked
            if os.path.exists(rawfile):
                if options.verbose: print("reprocessing rawfile:  %s" % cmd)
                result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)
                rr = result.stdout.decode('utf-8')
                rr = rr.rstrip("\t\n")
                for r in rr.split('\n'):
                    r = r.strip()
                    #print(r)
                    #sys.exit()
#                    (new_id, new_yr, new_mo, new_dy, new_hr, new_val, new_sd, new_n, new_flag, the_rest) = r.split(None, 9)
                    a = r.split()
                    new_id = a[0]
                    new_val = a[5]
                    new_sd = a[6]
                    new_meas_unc = a[7]
                    new_n = a[8]

                    if new_id.upper() == tank_serial_number.upper():
                        dline["mixratio"] = float(new_val)
                        dline["stddev"] = float(new_sd)
                        dline["meas_unc"] = float(new_meas_unc)
                        dline["num"] = int(new_n)
                        #try:
                        #    dline["num"] = int(a[7])  # old calpro output format
                        #except ValueError as e:
                        #    dline["num"] = int(a[8])  # new calpro output format
            else:
                if dline["inst"].lower() != "grav":
                    print("rawfile %s does not exist" % rawfile)
                    dline["mixratio"] = -999.99
                    dline["flag"] = '!'

    # replace unkown uncertainties with uncertainty from flask systems
    #------------------------------------------------------------
    for dline in cals.cals:
        if dline['typeB_unc'] < -99:
            # try to get uncertainty from flask analysis uncertainty table
            total_unc = flaskunc.getUncertainty('XXX', dline['date'], dline['mixratio'], method='P', inst=dline['inst'])
            if total_unc < 0: total_unc = 0
#            uncs = flaskunc.getUncertainties('XXX', dline['date'], dline['mixratio'], 'P', analyzer_id=dline['inst'])
#            total_unc = flaskunc.getTotalUncertainty(uncs)
            dline["typeB_unc"] = total_unc


    # allow user to offline edit the data before fitting
    #------------------------------------------------------------
    if options.edit:

        newcals = edit_cals(SPECIES, cals, tempfile)
        if newcals:
            final_data = newcals
        else:
            final_data = cals.cals

    else:
        final_data = cals.cals

    # remove 9'd out data
    final_data = [cal for cal in final_data if cal['mixratio'] > -800]


    # add some variables to final_data, set fit_unc
    # get data that should be included in fit
    # limit data for:
    #   1) remove flagged data unless flag = include_flag
    #   2) select by fit_inst's if used
    #   3) select by fit_official option if used
    #------------------------------------------------------------
    if options.plot_assigned:
        if options.debug:
            print("getting residuals from current assignment")
    fit_data = []
    for dline in final_data:
        # set default values for additional data to go into cals
        dline["mean_residual"] = -999.99
        dline["linear_residual"] = -999.99
        dline["quadratic_residual"] = -999.99
        dline["auto_residual"] = -999.99
        dline["current_residual"] = -999.99

        # get residual from current assignment
        if options.plot_assigned:
            y = ref.getAssignedValue(tank_serial_number, dline['dd'], showWarn=options.verbose)
            if y:
                dline["current_residual"] = dline["mixratio"] - y

        # note, fit_unc term is just for plotting. This value is calculated within the fit procedure from sd and unc
        if dline["meas_unc"] > 0.0:
            dline["fit_unc"] = math.sqrt(dline['typeB_unc']**2 + dline['meas_unc']**2)
        else:
            dline["fit_unc"] = math.sqrt(dline['typeB_unc']**2 + dline['stddev']**2)

        #default is all included - select by fit_inst, include_flag, and fit_daterange
        check = True
        if fit_inst_list:
            if dline["inst"].upper() not in fit_inst_list: check = False
        elif options.fit_official:
            if dline["inst"].upper() not in ccg_cal_db.INST_CODES[SPECIES]: check = False

        if dline["date"] < fit_startdate.date() or dline["date"] > fit_enddate.date(): check = False

        if dline["flag"] not in include_flag: check = False

        dline["in_fit"] = check
        if check: fit_data.append(dline)

    if options.debug:
        print("---------- fit data")
        for line in fit_data:
            print(line)
        print("fit types are", fit_types)

    # calibration fits
    #------------------------------------------------------------
    fmt2 = "%10s %12s %10s %5s %8.3f %1s %8.3f %8.3f %8.3f %s"

    if options.update and len(fit_types) > 1:
        sys.exit("Cannot specify more than one fit type for update option.")

    for fit_type in fit_types:

        if options.debug or options.verbose:
            print("************************************\n%s fit of selected data" % fit_type)
        fit = ccg_calfit.fitCalibrations(fit_data, degree=fit_type, debug=options.fit_debug)

        # calculate value of tank on specific date if requested
        if options.value_date:
            dt = parse(options.value_date)
            dd = ccg_dates.decimalDate(dt.year, dt.month, dt.day)
            v, u = calc_value(dd, fit)

        # determine type of output
        if options.check:
            check_assignment_db(tank_serial_number, SPECIES, fit, SCALE, fillcode, filldate, verbose=options.verbose)
        else:
            # json output
            if options.json:
                js = {
                    "serial_number": tank_serial_number, 
                    "parameter": SPECIES, 
                    "fill_code": fillcode, 
                    "scale": SCALE, 
                    "level": level, 
                    "comment": options.comment, 
                    "results": fit._asdict(), 
                    "calibrations": fit_data
                }
                # add calculated value on date to json if requested
                if options.value_date:
                    js["value"] = {"date": dt.strftime("%Y-%m-%d"), "mf": round(v, 3), "unc": round(u, 3)}

                print(json.dumps(js, indent=4, default=str))

            # text output
            else:
                if options.verbose:
                    print("Serial Number: %s" % tank_serial_number)
                    print("Fill Code:     %s" % fillcode)
                    print("Gas:           %s" % SPECIES)
                    print("Scale:         %s" % SCALE)
                    print("Time zero:     %s" % fit.tzero)
                    print("Coeff. 0:      %s" % fit.coef0)
                    print("Coeff. 1:      %s" % fit.coef1)
                    print("Coeff. 2:      %s" % fit.coef2)
                    print("Unc Coeff. 0:  %s" % fit.unc_c0)
                    print("Unc Coeff. 1:  %s" % fit.unc_c1)
                    print("Unc Coeff. 2:  %s" % fit.unc_c2)
                    print("Residual Stdv. %s" % fit.sd_resid)
                    print("N              %s" % fit.n)
                    print("Reduce Chisq   %s" % fit.chisq)
                    print("Level          %s" % level)
                    print("Comment        %s" % options.comment)
                    print("Calibrations  ", fit.calibrations)

                else:
#                    print(fit, "  %s  # %s" % (level, options.comment))
                    print("Serial_Number  Gas  Fill_Code  Time_Zero   Coef0      Coef1    Coef2  Unc_Coef0 Unc_Coef1 Unc_Coef2    Rsd   N   Chisq     Level", end="")
                    if options.comment:
                        print(" #Comment", end="")
                    print()
                    print("%10s" % tank_serial_number.upper(), end="")
                    print("%8s" % SPECIES, end="")
                    print("%7s" % fillcode, end="")
                    print("%16.5f" % fit.tzero, end="")
                    print("%9.3f" % fit.coef0, end="")
                    print("%9.5f" % fit.coef1, end="")
                    print("%9.5f" % fit.coef2, end="")
                    print("%11.3f" % fit.unc_c0, end="")
                    print("%10.5f" % fit.unc_c1, end="")
                    print("%10.5f" % fit.unc_c2, end="")
                    print("%7.2f" % fit.sd_resid, end="")
                    print("%4d" % fit.n, end="")
                    print("%8.2f" % fit.chisq, end="")
                    print("%10s" % level, end="")
                    if options.comment:
                        print(" #%s" % options.comment, end="")
                    print()

        if options.update:
            update_assignment_db(tank_serial_number, fit, SCALE, filldate, level, options.comment)

#        print()
        fit_types[fit_type] = fit

        # get residuals from fit
        for dline in final_data:
            cval, cunc = calc_value(dline['dd'], fit)
            resid = dline["mixratio"] - cval
            key = fit_type + "_residual"
            dline[key] = resid
            if options.info:
                print(fmt2 % (fit_type, dline['date'], dline['system'], dline['inst'], dline['mixratio'], dline['flag'], dline['fit_unc'], cval, resid, dline['in_fit']))

        # value date
        if options.value_date and not options.json:
            print("-----  Using %s  %s value on %s (%10.5f) = %12.4f (+- %6.4f)" % (fit_type, tank_serial_number, options.value_date, dd, v, u))


    # create a dataframe from the final_data
    #------------------------------------------------------------
    if options.debug:
        print("length of final data", len(final_data))
    if len(final_data) == 0:
        if not options.json:
            print("No data available.")
        continue

    df = pd.DataFrame(final_data)


    # get min and max dates
    #------------------------------------------------------------
    max_date = df['dd'].max()
    if options.min_date:
        dt = parse(options.min_date)
        min_date = ccg_dates.decimalDateFromDatetime(dt)
    else:
        min_date = ccg_dates.decimalDate(filldate.year, filldate.month, filldate.day)

    if options.debug:
        print("---------- final data")
        print(df)
        print("instrument list is", df['inst'].unique())
        print("min date", min_date, "max_date", max_date)

    #------------------------------------------------------------
    # plots - need to add ability to do multiple tanks on the plot
    if options.plot or options.plot_residuals or options.plot_assigned or options.plot_flag or options.plot_uncertainty:

        fit_colors = {'auto': 'r', 'mean': 'b', 'linear': 'g', 'quadratic': 'm', 'current': 'black'}

        ncols = 1
        nrows = 2 if options.plot_residuals else 1

        # create the plot
        fig, axs = plt.subplots(nrows, ncols, figsize=(6.5, 6.5))
        axis = axs[0] if options.plot_residuals else axs

        axis.set_title('%s (%s), %s' % (tank_serial_number, fillcode, SPECIES))

        # get date range for plotting curves (min and max dates found above)
        step = 200
        interval = ((max_date + float(options.date_extension)) - (min_date)) / step
        line_x = [n * interval + (min_date) for n in range(step)]

        # if asked for, get current assigned value from lookup tables for plotting
        if options.plot_assigned:
            print("Getting current assigned values for %s scale" % (SCALE))
            x_assigned = []
            y_assigned = []
            for dd in line_x:
                y = ref.getAssignedValue(tank_serial_number, dd, showWarn=options.verbose)
                if y:
                    y_assigned.append(y)
                    x_assigned.append(dd)
            if len(y_assigned) > 1:
                axis.plot(x_assigned, y_assigned, linestyle='solid', color='black', label='current assigned')

        # start loop by inst here
        for n, tinst in enumerate(df['inst'].unique()):

            # plot fit data
            df2 = df[(df['in_fit']) & (df['inst'] == tinst)]
            df3 = df[(df['in_fit'] == False) & (df['inst'] == tinst) & (df['flag'].isin(plot_flag))]

            if options.debug:
                print("---------- cal data for", tinst)
                print("None" if df2.empty else df2)
                print("---------- cals not in fit data for ", tinst)
                print("None" if df3.empty else df3)

            # plot each inst in diffent color/symbol, close sym if in fit, open if not in fit
            if not df2.empty:
                axis.errorbar(df2['dd'], df2['mixratio'], yerr=df2['fit_unc'], color=col_arr[n],
                              marker=sym_arr[n], linestyle='none', fillstyle='full', label="%s" % tinst.upper())
            if not df3.empty:
                axis.errorbar(df3['dd'], df3['mixratio'], yerr=df3['fit_unc'], color=col_arr[n],
                              marker=sym_arr[n], linestyle='none', fillstyle='none', label="%s not in fit" % tinst.upper())

            # plot residuals if asked for
            if options.plot_residuals:

                # residuals from fit
                for fit_type in fit_types:
                    label1 = "%s %s fit" % (tinst, fit_type)
                    label2 = "%s %s fit, not included" % (tinst, fit_type)
                    color = fit_colors[fit_type]
                    key = fit_type + "_residual"
                    if not df2.empty:
                        print(tinst, key, "mean: %.3f" % df2[key].mean(), "stdv: %.3f" % df2[key].std(), " n: %d" % len(df2[key]))
                        axs[1].plot(df2['dd'], df2[key], marker=sym_arr[n], linestyle='none', fillstyle='full', color=color, label=label1)
                    if not df3.empty:
                        print(tinst, key, " (not included in fit) mean: %.3f" % df3[key].mean(), "stdv: %.3f" % df3[key].std(), " n: %d" % len(df3[key]))
                        axs[1].plot(df3['dd'], df3[key], marker=sym_arr[n], linestyle='none', fillstyle='none', color=color, label=label2)

                # residuals from assigned value
                if options.plot_assigned:
                    df4 = df2[df2['current_residual'] > -800]
                    df5 = df3[df3['current_residual'] > -800]
                    if not df4.empty:
                        axs[1].plot(df4['dd'], df4['current_residual'],
                                    marker=sym_arr[n], linestyle='none', fillstyle='full', color='black',
                                    label="%s current assignment" % tinst)
                    if not df5.empty:
                        axs[1].plot(df5['dd'], df5['current_residual'],
                                    marker=sym_arr[n], linestyle='none', fillstyle='none', color='black',
                                    label="%s current assignment, not included" % tinst)


        # plot fit lines
        fit_linetype = {'auto': 'solid', 'mean': 'dashed', 'linear': 'dashdot', 'quadratic': 'dotted'}
        for fit_type in fit_types:
            line_y = []
            line_y_unc = []
            #line_y = [calc_value(d, fit_types[fit_type]) for d in line_x]
            for d in line_x:
                v, u = calc_value(d, fit_types[fit_type])
                line_y.append(v)
                line_y_unc.append(u)

            label = fit_type
            if fit_type != "mean": label += "_fit"
            axis.plot(line_x, line_y, linestyle=fit_linetype[fit_type], color=fit_colors[fit_type], label=label)

            # if asked for, plot uncertainty envelop
            if options.plot_uncertainty:
                y_unc = np.array(line_y_unc)
                y = np.array(line_y)
                axis.plot(line_x, np.add(y, y_unc), linestyle=(0, (1, 10)), color=fit_colors[fit_type], label="%s unc" % label)
                #axis.plot(line_x, np.subtract(y, y_unc), linestyle=(0, (1, 10)), color=fit_colors[fit_type], label="%s unc" % label)
                axis.plot(line_x, np.subtract(y, y_unc), linestyle=(0, (1, 10)), color=fit_colors[fit_type])

                if options.plot_residuals:
                    axs[1].plot(line_x, y_unc, linestyle=(0, (1, 10)), color=fit_colors[fit_type], label="%s unc" % label)
                    #axs[1].plot(line_x, np.negative(y_unc), linestyle=(0, (1, 10)), color=fit_colors[fit_type], label="%s unc" % label)
                    axs[1].plot(line_x, np.negative(y_unc), linestyle=(0, (1, 10)), color=fit_colors[fit_type])



        # plot vertical marks
        if vertical_mark_list:
            lims0 = axis.get_ylim()
            for dd in vertical_mark_list:
                axis.plot([dd, dd], lims0, linestyle='dotted', color='grey')
                if options.plot_residuals:
                    lims1 = axs[1].get_ylim()
                    axs[1].plot([dd, dd], lims1, linestyle='dotted', color='grey')

        if options.plot_residuals:
            # force residual plot to have same axis limits as data plot
            lims = axs[0].get_xlim()
            axs[1].set_xlim(lims)

            # plot 0 line in residuals plot
            axs[1].plot(lims, [0.0, 0.0], linestyle='solid', linewidth=1, color='#ccc')
            axs[1].legend()


        axis.legend()

        mainend = datetime.datetime.now()
        dt = mainend - mainstart
        print("main cycle time: %s" % dt)
        plt.show()




    # pause and ask user the fit type to write to temp file
    #------------------------------------------------------------
    if options.save_result:
        save_result(fit_types)
