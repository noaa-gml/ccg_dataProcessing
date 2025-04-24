#! /usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Program for plotting the sd of tank cal results for system/inst over time periods
"""

import sys
import os
import argparse
import subprocess
import datetime
import math
import numpy
from scipy.optimize import curve_fit
from scipy.odr import odrpack as odr
from scipy.odr import models
import scipy.stats
import copy
from dateutil.parser import parse
import pandas as pd
from collections import namedtuple

import matplotlib.pyplot as plt

#sys.path.append("/ccg/src/python3/nextgen")
#sys.path.insert(1, "/ccg/src/python3/nextgen")
sys.path.insert(1, "/ccg/python/ccglib")
#import ccg_caldb
#import ccg_cal_db as ccg_caldb
#import ccg_db
#import ccg_calfit
import ccg_db_conn
import ccg_dbutils
import ccg_dates  # for v02, use more of these functions to simplify code dealing with dates.
import ccg_refgasdb



#######################################################################
##################################################################################
def mean_stdv(a):

    average = numpy.mean(a)
    if len(a) > 1:
        std = numpy.std(a, ddof=1)
    else:
        std = 0.0
    nv = len(a)

    return average, std, nv






###########################################################
#######################################################################
def edit_cals(gas, cals, tempfile):
    """ allow user to edit calibration data """
    if gas.lower() == 'co2':
        header = "date_n serial_number fc  date       time      dd         species   value     stddev meas_unc num  method     inst  system  flag  co2c13 #notes"
    else:
        header = "date_n serial_number fc  date       time      dd         species   value     stddev meas_unc num  method     inst  system  flag  #notes"
    output = '#%s' % (header)

    #for dline in cals:
    for dline in sorted(cals, key=lambda k: k["stddev"]):
        #print(dline)
        t = "%s" % dline["time"]
        (hr, mn, sc) = t.split(':')

        output += "\n%-8s" % (dline["date_range"])
        output += " %-12s" % (dline["serial_number"])
        output += " %-3s" % (dline["fillcode"])
        output += " %4d-%02d-%02d" % (dline["date"].year, dline["date"].month, dline["date"].day)
        output += " %8s" % (dline["time"])
        output += " %9.4f" % (dline["dd"])
        output += " %6s" % dline["species"]
        output += " %12.3f" % dline["value"]
        output += " %8.3f" % dline["stddev"]
        output += " %8.3f" % dline["meas_unc"]
        output += " %2d" % dline["num"]
        output += " %10s" % dline["method"]
        output += " %5s" % dline["inst"]
        output += " %8s" % dline["system"]
        #output += " %5s" % dline["pressure"]
        output += " %2s" % dline["flag"]
        #output += " %3s" % dline["location"]
        #if not dline["regulator"]: dline["regulator"] = 'na'
        #output += " %12.3f" % dline["noaa_value"]
        #output += " %8.3f" % dline["noaa_unc"]
        #output += " %8.3f" % dline["diff"]
        #output += " %8.3f" % dline["diff_unc"]
        if gas.lower() == 'co2': output += " %5.1f" % dline["c13"]
        output += " #%s" % dline["notes"]
        #output += " %s" % dline[""]


    print("\n\n%s\n" % output)

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
            if len(tdata.split()) == 16:
                #(d_range, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, noaa_val, noaa_unc, diff, diff_unc, c13) = tdata.split()
                (d_range, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, c13) = tdata.split()
            elif len(tdata.split()) == 15:
                #(d_range, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, noaa_val, noaa_unc, diff, diff_unc) = tdata.split()
                (d_range, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg) = tdata.split()
                c13 = -999.9
            else:
                print("unknown number of fields")
                print("len(tdata.split()): %s on line: %s" % (len(tdata.split()), line))
                sys.exit()

            tmp_data["date_range"] = int(d_range)
            tmp_data["serial_number"] = sn
            (yr, mo, dy) = d.split('-')
            dt = datetime.date(int(yr), int(mo), int(dy))
            tmp_data["date"] = dt
            (hr, mn, sc) = t.split(':')
            dt = datetime.timedelta(hours=int(hr), minutes=int(mn), seconds=int(sc))
            tmp_data["time"] = dt
            tmp_data["dd"] = float(dd)
            tmp_data["species"] = sp
            tmp_data["value"] = float(val)
            tmp_data["stddev"] = float(sd)
            tmp_data["meas_unc"] = float(meas_unc)
            tmp_data["num"] = int(n)
            tmp_data["method"] = method
            tmp_data["inst"] = tinst
            tmp_data["system"] = tsystem
            tmp_data["flag"] = flg
            if gas.lower() == 'co2': tmp_data["c13"] = float(c13)
            #tmp_data["noaa_value"] = float(noaa_val)
            #tmp_data["noaa_unc"] = float(noaa_unc) 
            #tmp_data["diff"] = float(diff)
            #tmp_data["diff_unc"] = float(diff_unc)
            #tmp_data[""] = 

            edited_data.append(tmp_data)

        return edited_data

    # else after "do you want to edit" question - if answer "no" just use data as is
    return None





#######################################################################
#######################################################################
#######################################################################


#######################################################################
# get list of cylinders run on system
def get_tank_cal_data(system, species, parameter_num, inst_list, sdate, edate, cnt, min_mf, max_mf, system_n_limit, cal_n_limit, diff_limit, database):
    """  get list of tank cal episodes on system within date range and mole fraction range.
    """
    tmp_data = {}
    system_cals = []
    
    # make DB connection
    db = ccg_db_conn.RO(database)

    # pull external data from reftank.external_calibrations
    table = "calibrations_fill_view"
    query = "SELECT serial_number, fill_code, date, time, species, mixratio, stddev, meas_unc, num, method, inst, system, pressure, flag, location, regulator, notes, mod_date from %s " % table
    #query += " WHERE system like '%s' and species like '%s' and date >= '%s' and date < '%s' and mixratio >= %s and mixratio <= %s and flag like '.';" % (
    #        system, species, sdate, edate, min_mf, max_mf)
    query += " WHERE system like '%s' and parameter_num = %s and date >= '%s' and date < '%s' and mixratio >= %s and mixratio <= %s and flag like '.'" % (
            system, parameter_num, sdate, edate, min_mf, max_mf)
    print("query: %s" % query, file=sys.stderr)
    rtn = db.doquery(query, form='dict')

    #z = 0
    if rtn:
        for v in rtn:
            #for key in v.keys():
            #    print(key, v[key])
            #sys.exit()
            # test cal_n_limit
            query = "SELECT count(*) from %s " % table
            query += " WHERE serial_number like '%s' and parameter_num =  %s and flag like '.';" % (v["serial_number"], parameter_num)
            n_total = db.doquery(query,numRows=0)
            if int(n_total) < cal_n_limit: continue
            


            tmp_data["date_range"] = cnt
            tmp_data["serial_number"] = v["serial_number"]
            tmp_data["fill_code"] = v["fill_code"]
            tmp_data["date"] = v["date"]
            #(yr, mo, dy) = v["date"].split('-')
            tmp_data["time"] = v["time"]
            tmp_data["dd"] = ccg_dates.decimalDate(tmp_data["date"].year,tmp_data["date"].month,tmp_data["date"].day)
            tmp_data["species"] = v["species"]
            tmp_data["value"] = v["mixratio"]
            tmp_data["stddev"] = v["stddev"]
            tmp_data["meas_unc"] = v["meas_unc"] 
            tmp_data["num"] = v["num"]
            tmp_data["method"] = v["method"]
            if inst_list:
                if v["inst"].upper() not in inst_list: 
                    #print("****   %s not in inst"% (v["inst"])) 
                    continue
            tmp_data["inst"] = v["inst"]
            tmp_data["system"] = v["system"]
            tmp_data["pressure"] = v["pressure"]
            tmp_data["flag"] = v["flag"]
            tmp_data["location"] = v["location"]
            tmp_data["regulator"] = v["regulator"]
            tmp_data["notes"] = v["notes"]
    
            # determine if meets system_n_limit
            if system_n_limit:
                query = "SELECT COUNT(mixratio) from %s " % (tbl)
                query += " where serial_number like '%s' and parameter_num = %s and fill_code like '%s' and system like '%s'" % (
                    tmp_data["serial_number"], parameter_num, tmp_data["fill_code"], tmp_data["system"] )
                #print(query)
                rtn4 = db.doquery(query, numRows=0)
                if rtn4:
                    tmp_data["system_count"] = int(rtn4)
                else:
                    tmp_data["system_count"] = 0
            else:
                tmp_data["system_count"] = 9999


            # if co2, get 13C value of the tank # hardcode database='reftank' for isotope informationa values 
            if species.lower() == "co2":
                tbl = "calibrations_fill_view"
                query = "SELECT AVG(mixratio) from %s " % (tbl)
                query += " where serial_number like '%s' and parameter_num = 7 and fill_code like '%s'" % (
                    tmp_data["serial_number"],tmp_data["fill_code"] )
                rtn3 = db.doquery(query, numRows=0)
                if rtn3:
                    tmp_data["c13"] = float(rtn3)
                else:
                    tmp_data["c13"] = -999.99
                #print("sn: %s fillcode: %s   tmp_data[c13]: %s" % (tmp_data["serial_number"],tmp_data["fillcode"], tmp_data["c13"]))
            else:
                tmp_data["c13"] = -999.99
            

            temp_data= copy.deepcopy(tmp_data)
            #for key in temp_data.keys():
            #    print(key, temp_data[key])
            #sys.exit()

            #if temp_data["system_count"] > system_n_limit and abs(temp_data["diff"]) < diff_limit:
            if temp_data["system_count"] > system_n_limit:
                system_cals.append(temp_data)

    return system_cals
 




#######################################################################
# checks/configuration
col_arr = ['r','b','g','c','m','y','b','r','m','g','r','b','m','y','r','b','g','c','m','y','b','r','m','g','r','b','m','y']
sym_arr = ['o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x']

tempfile = "%s/tempfile_compare_systems.txt" % os.getenv("HOME") # temp file for editing data

parser = argparse.ArgumentParser(description="Compare systems with official calibration system history")

#        epilog="Only one of the output options should be given.  No options means print out a single result line to stdout.")

group = parser.add_argument_group("Data Selection Options")

#Add ability to select system and inst used in fits - may need ability to pass in non-standard unc file
# add ability to select inst used for system passed in.
#
#
#group.add_argument('--fillcode', type=str.upper, help="Specify fillcode. Default is None which causes code to return list and ask")
group.add_argument('--inst', help="Specify inst codes to pull from database, default is all. For example --inst=L9,PC1 ")
#group.add_argument('--check_assignments_table', action="store_true", default=True, help="Check for assigned value in lookup table for primary stds. ")
#group.add_argument('--uncfile', help="Pass in path to non-default scale transfer uncrtainty table used for weights in fit.")
group.add_argument('--date_ranges', help="Pass in a list of date ranges to process. Use ':' to separate start:end dates and ',' to separate ranges. For example --date_ranges=1990:1999,2004:2005,2021-01-01:2021-03-31,2022-01:2022-06")
group.add_argument('--range', help="Pass in mole fraction range to limit. For example --range=350,450. If one value, assume minimum.")
group.add_argument('--c13_limit', help="Pass in 13C limit to remove depleted tanks (or CO2). For example --13C_limit=-15")
group.add_argument('--cal_n_limit', help="Pass in limit for number of calibrations on the calibration system. For example --cal_n_limit=5")
group.add_argument('--system_n_limit', help="Pass in limit for number of calibrations on the calibration system. For example --system_n_limit=5")
group.add_argument('--diff_limit', help="Pass in limit for abs diff to reject outliers. For example --diff_limit=5")
group.add_argument('--database', default="reftank", help="Select database to compare/update results. Default is 'reftank'.")
group.add_argument('--moddate', help="Use values for standards before this modification date. For example --moddate=2014-05-01")
#group.add_argument('--use_grav', action="store_true", default=False, help=" Add in the original gravimetric value from DB tables. Default is False.")

group = parser.add_argument_group("Fitting Options for scale relationship")
group.add_argument('--edit', action="store_true", default=False, help="Allow user to select/edit data offline prior to fit.")
#group.add_argument('--fit_inst', help="Specify instrument to use to value assign tank. This is a subset of inst displayed. For example --inst=L9,PC1 ")
#group.add_argument('--fit_official', action="store_true", default=False, help="Use only official calibration instruments in the fit.  This is an alternative to --fit_inst ")
group.add_argument('--fit_differences', action="store_true", default=False, help="Fit differences rather than odr fit to values")
group.add_argument('--auto_fit', action="store_true", default=False, help="Show results of auto significance testing of fits.")
group.add_argument('--mean', action="store_true", default=False, help="Show weighted mean (default is False).")
group.add_argument('--linear', action="store_true", default=False, help="Show linear fit (default is False).")
group.add_argument('--quadratic', action="store_true", default=False, help="Show quadratic fit (default is False).")
group.add_argument('--include_flag', default=".", help="Specify flags to include in fit (default is '.'). For example --include_flag=.,S,r")
#group.add_argument('--use_sd', action="store_true", default=False, help="Use std dev of episode for weighting in fit. Ignores the scale transfer uncertainty term (Default is false). Helpful when including inst without a defined scale transfer unc.")
#group.add_argument('--use_external', action="store_true", default=False, help="Use external calibration data")

#group = parser.add_argument_group("Offline re-processing Options")
#group.add_argument('--reprocess', action="store_true", default=False, help="Reprocess calibrations (default is False). For example --reprocess=True")
#group.add_argument('--scale', help="Scale to use for reprocessing (default is current). For example --scale=CO_X2004")
#group.add_argument('-w', '--refgasfile', help="Choose a text reference gas file instead of database for assigned values.")
#group.add_argument('-r', '--respfile', help="Select a non-standard response file for reprocessing.")
#group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
#group.add_argument('--program', help="Path to non-standard version of calpro for reprocessing. For example --program=/home/ccg/.../.../test_version_calpro.py")
#group.add_argument('--extra_option', help="List of options to pass to calpro.py for reprocessing, separated by commas. For example --c13=*,--018=*,etc")

group = parser.add_argument_group("Output Options")
group.add_argument('--plot_stddev', action="store_true", default=False, help="Create a plot of standard deviations vs time. Default is False.")
group.add_argument('--plot_meas_unc', action="store_true", default=False, help="Create a plot of measurement unc vs time. Default is False.")
group.add_argument('--vs_time', action="store_true", default=False, help="Set to plot stddev vs time rather than mole fraction")
group.add_argument('--plot_differences', action="store_true", default=False, help="Create a plot of differences (system results - assigned value from calibration system) vs mole fraction . Default is False.")
#group.add_argument('--plot_residuals', action="store_true", default=False, help="Plot residuals from fit. Default is False")
#group.add_argument('--plot_unc', action="store_true", default=False, help="Plot uncertainty of scale conversion. Default is False")
#group.add_argument('--hide_residual_unc', action="store_true", default=False, help="Supress error bars in residuals plot. Default is False")
group.add_argument('--plot_flag', help="Flag to include in plots but not in the fit (default is None). For example --plot_flag=S")
group.add_argument('--no_legend', action="store_true", default=False, help="Set to remove legend from plot")
#group.add_argument('--save_result', action="store_true", default=False, help="Pause and ask user for fit type to save to tempfile (default is False)")
#group.add_argument('--fit_debug', action="store_true", default=False, help="Used to print debugging information on statistical testing used in auto fit routine (default is False)")
#group.add_argument('--info', action="store_true", default=False, help="Print out input data and residuals.")
#group.add_argument('--vertical_mark', default=None, help="Dates to place vertical mark on plots")
group.add_argument('-u', '--update', action="store_true", default=False, help="Save fit parameters in scale assignment database table. Only one fit type can be used.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Print out extra information.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")

# required arguments
parser.add_argument('species', help="Specify species to value assign tank.")
parser.add_argument('system', help="Specify species to value assign tank.")

options = parser.parse_args()


mainstart = datetime.datetime.now()


# Setup
SPECIES = options.species
if options.debug: print("SPECIES: %s" % SPECIES, file=sys.stderr)
db = ccg_dbutils.dbUtils()
PARAMETER_NUM = db.getGasNum(SPECIES)

SYSTEM = options.system
if options.debug: print("SYSTEM: %s" % SYSTEM, file=sys.stderr)

# set moddate
if options.moddate:
    moddate = options.moddate
else:
    now = datetime.datetime.now()
    moddate = "%4d-%02d-%02d" % (int(now.year), int(now.month), int(now.day))

# flags to include in plot, these are flags in addition to '.'
plot_flag = ['.']
if options.plot_flag:
    plot_flag = plot_flag + options.plot_flag.split(',')

# make list of passed inst codes
if options.inst:
    inst_list = []
    for inst_id in options.inst.split(','):
        inst_list.append(inst_id.upper())
else:
    inst_list = None

# set range, default = -100 - 9999
min_molefraction = -100.0
max_molefraction = 9999.9
if options.range:
    if len(options.range.split(',')) == 2:
        min_molefraction = float(options.range.split(',')[0])
        max_molefraction = float(options.range.split(',')[1])
    else:
        min_molefraction = float(options.range)
if options.debug: print("min_molefraction: %12.3f    max_molefraction: %12.3f" % (min_molefraction, max_molefraction ))

# set c13 limit (for co2)
if options.c13_limit:
    c13_limit = float(options.c13_limit)
else:
    c13_limit = -999.99
if options.debug: print("c13_limit: %12.3f" % (c13_limit ))

# set cal_n_limit (number of episodes on the cal system)
if options.cal_n_limit:
    cal_n_limit = float(options.cal_n_limit)
else:
    cal_n_limit = 1

# set system_n_limit (number of episodes on the cal system)
if options.system_n_limit:
    system_n_limit = float(options.system_n_limit)
else:
    system_n_limit = 0

# set diff_limit (abs value of diff)
if options.diff_limit:
    diff_limit = float(options.diff_limit)
else:
    diff_limit = 9999.99

 
 
 

# save fit types requested
# only add entry for fit types that will be used
fit_types = {}
if options.auto_fit: fit_types['auto'] = True
if options.mean:           fit_types['mean'] = True
if options.linear:         fit_types['linear'] = True
if options.quadratic:      fit_types['quadratic'] = True

# format date ranges
# Pass in a list of date ranges to process. Use ':' to separate start:end dates and ',' to separate ranges. 
# For example --date_ranges=1990:1999,2004:2005,2021-01-01:2021-03-31,2022-01:2022-06
startdate = []
enddate = []
if options.date_ranges:
    for r in options.date_ranges.split(','):
        #print(r)
        rr = r.split(':')
        #print("len(rr): %s" % len(rr))
        #print("\n")
        if len(rr) == 1:
            sd = rr[0]
            ed = rr[0]
        elif len(rr) == 2:
            sd = rr[0]
            ed = rr[1]
        else:
            msg="date range %s is not formated correctly" % r
            sys.exit(msg)

        #format sd
        rr = sd.split('-')
        if len(rr) == 1:
            d = "%s-01-01" % rr[0]
        elif len(rr) == 2:
            d = "%s-%s-01" % (rr[0],int(rr[1]))
        elif len(rr) == 3:
            d = "%s-%02d-%02d" % (rr[0],int(rr[1]),int(rr[2]))
        else:
            msg= "date %s not formated correctly" % rr
            sys.exit(msg)

        startdate.append(d)

        #format ed
        rr = ed.split('-')
        if len(rr) == 1:
            d = "%s-12-31" % rr[0]
        elif len(rr) == 2:
            dy_arr = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
            month = int(rr[1])
            year = int(rr[0])
            days = dy_arr[month-1]
            if (month==2 and ((year%400==0) or ((year%100!=0) and (year%4==0)))):  days += 1
            d = "%s-%02d-%02d" % (year, month, days)
                
        elif len(rr) == 3:
            d = "%s-%02d-%02d" % (rr[0],int(rr[1]),int(rr[2]))
        else:
            msg= "date %s not formated correctly" % rr
            sys.exit(msg)

        enddate.append(d)
else:
    startdate.append("1900-01-01")
    enddate.append("2100-12-31")


data = []
final_data = []
cnt_date_range =-1
for i, j in enumerate(startdate):
    print("date range:  %s - %s" % (startdate[i], enddate[i]))
    cnt_date_range += 1

    # find all tanks measured on system during date range with associated time dependent value assignment
    print("database: %s" % options.database, file=sys.stderr)
    results = get_tank_cal_data(SYSTEM, SPECIES, PARAMETER_NUM, inst_list, startdate[i], enddate[i], cnt_date_range, min_molefraction, max_molefraction,system_n_limit, cal_n_limit, diff_limit, options.database)
    
    for dline in results:
        tmp = copy.deepcopy(dline)
        #if dline["noaa_value"] < -100: continue
        if SPECIES.upper() == "CO2" and dline["c13"] < c13_limit: continue
            
        data.append(tmp)

if options.edit:
    newcals = edit_cals(SPECIES, data, tempfile)
    if newcals:
        final_data = newcals
    else:
        final_data = data

else:
    final_data = data




# new df now includes residuals
df = pd.DataFrame(final_data)

## get range from all good data
#df_all = df[(df['flag'].isin(plot_flag)) & (df['value'] > -800) & (df["noaa_value"] > -800) ]

# get date range for plotting curves
step = 200
if options.vs_time:
    #tmp_data["dd"] = ccg_dates.decimalDate(tmp_data["date"].year,tmp_data["date"].month,tmp_data["date"].day)
    min_dd = min(df['dd']) 
    max_dd = max(df['dd']) 
    min_value = ccg_dates.dateFromDecimalDate(min_dd)
    max_value = ccg_dates.dateFromDecimalDate(max_dd)
else:
    min_value = min(df['value']) * 0.99
    max_value = max(df['value']) * 1.01

interval = (max_value - min_value) / step
line_x = [n * interval + (min_value) for n in range(step)]




### plots
num_plots = 1
#if options.plot_stddev: num_plots += 1
#if options.plot_meas_unc: num_plots += 1
#if options.plot_differences: num_plots += 1

if num_plots > 0:
    if SPECIES.upper() == 'CO2':
        gas_formula = "CO$_2$"
        gas_units = "$\mu$mol mol$^{-1}$"
    elif SPECIES.upper() == 'CH4':
        gas_formula = "CH$_4$"
        gas_units = "nmol mol$^{-1}$"
    elif SPECIES.upper() == 'N2O':
        gas_formula = "N$_2$O"
        gas_units = "nmol mol$^{-1}$"
    elif SPECIES.upper() == 'CO':
        gas_formula = "CO"
        gas_units = "nmol mol$^{-1}$"
    elif SPECIES.upper() == 'SF6':
        gas_formula = "SF$_6$"
        gas_units = "pmol mol$^{-1}$"
    elif SPECIES.upper() == 'H2':
        gas_formula = "H$_2$"
        gas_units = "nmol mol$^{-1}$"
    else:
        gas_formula = SPECIES
        gas_units = "%s units" % (SPECIES)

    fit_colors = {'auto': 'r', 'mean': 'b', 'linear': 'g', 'quadratic': 'm', 'current': 'black'}

    ncols = 1
    nrows = num_plots

    # create the figure - might need to adjust size by num_plots
    if num_plots == 3:
        fig_height = 8.5
        fig_width = 7.5
    elif num_plots == 2:
        fig_height = 8.5
        fig_width = 7.5
    else:
        fig_height = 6.0
        fig_width = 6.5

    fig, axs = plt.subplots(nrows, ncols, figsize=(fig_width, fig_height))

    # create the plots
    current_plot = 0
    data_plot = axs

#    if options.plot_stddev:
#        stddev_plot = axs[current_plot] if options.plot_meas_unc or options.plot_differences else axs
#        current_plot += 1
#    else:
#        stddev_plot = None
#
#    if options.plot_meas_unc:
#        meas_unc_plot = axs[current_plot] if options.plot_stddev or options.plot_differences else axs
#        current_plot += 1
#    else:
#        meas_unc_plot = None
#
#    if options.plot_differences:
#        difference_plot = axs[current_plot] if options.plot_stddev or options.plot_meas_unc else axs
#        current_plot += 1
#    else:
#        difference_plot = None

    #if options.plot_residuals or options.plot_unc:
    #    residual_plot = axs[current_plot] if options.plot or options.plot_differences else axs
    #else:
    #    residual_plot = None

    #label axis
    if options.vs_time:
        title = '%s %s: unc vs time' % (gas_formula, SYSTEM)
        xlabel = "date"
    else:
        title = '%s %s: unc vs mole fraction' % (gas_formula, SYSTEM)
        xlabel = "%s %s" % (gas_formula, gas_units)


    if data_plot:
        data_plot.set_title(title)
        ylabel = "%s unc (%s) " % (gas_formula, gas_units)
        data_plot.set_ylabel('%s' % (ylabel))
        data_plot.set_xlabel("%s" % (xlabel))

    #if meas_unc_plot:
    #    if stddev_plot is None: meas_unc_plot.set_title(title)
    #    ylabel = "%s meas_unc (%s) " % (gas_formula, gas_units)
    #    meas_unc_plot.set_ylabel('%s' % (ylabel))
    #    if difference_plot is None and stddev_plot is None: meas_unc_plot.set_xlabel("%s" % (xlabel))

    #if difference_plot:
    #    if stddev_plot is None and meas_unc_plot is None: difference_plot.set_title(title)
    #    ylabel = "%s %s\n(Meas_unc - Stddev)" % (gas_formula, gas_units)
    #    difference_plot.set_ylabel(ylabel)
    #    difference_plot.set_xlabel("%s" % (xlabel))

    #if residual_plot:
    #    if scale_plot is None and difference_plot is None: residual_plot.set_title(title)
    #    ylabel = "%s Residuals\n%s" % (gas_formula, gas_units)
    #    residual_plot.set_ylabel(ylabel)
    #    if difference_plot is None: residual_plot.set_xlabel("%s" % (xlabel))

    ## plot 1:1 line in scale plot
    #line_y = []
    #for x in line_x:
    #    line_y.append(x)
    #if scale_plot: scale_plot.plot(line_x, line_y, linestyle='dotted', color='black')

    ## plot 0:0 line in difference plots
    #line_y = []
    #for x in line_x:
    #    line_y.append(0.0)
    #if difference_plot: difference_plot.plot(line_x, line_y, linestyle='dotted', color='black')





    for n, tinst in enumerate(df['inst'].unique()):
        cnt = -1 

        # loop through date ranges
        for nn, sd in enumerate(startdate):
            cnt += 1
            print("cnt: %s   n: %s  tinst: %s" % (cnt, n, tinst))
            label = "%s: %s - %s" % (tinst, startdate[nn], enddate[nn])
            print(label)
            # get data for date_range
            df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["date_range"] == nn) & (df["inst"] == tinst) ]

            # plot each inst in diffent color/symbol, close sym if in fit, open if not in fit
            if not df2.empty:
                if options.plot_stddev:
                    if options.vs_time:
                        data_plot.errorbar(df2['dd'], df2['stddev'], color=col_arr[cnt],
                              marker=sym_arr[n], linestyle='none', fillstyle='none', label="%s stddev" % label )
                    else:
                        data_plot.errorbar(df2['value'], df2['stddev'], color=col_arr[cnt],
                              marker=sym_arr[n], linestyle='none', fillstyle='none', label="%s stddev" % label )

                if options.plot_meas_unc:
                    if options.vs_time:
                        data_plot.errorbar(df2['dd'], df2['meas_unc'], color=col_arr[cnt],
                              marker=sym_arr[n], linestyle='none', fillstyle='full', label="%s meas_unc" % label )
                    else:
                        data_plot.errorbar(df2['value'], df2['meas_unc'], color=col_arr[cnt],
                              marker=sym_arr[n], linestyle='none', fillstyle='full', label="%s meas_unc" % label )
            else:
                print("empty")



        if not options.no_legend:
            if data_plot:
                data_plot.legend()
            #elif residual_plot:
            #    residual_plot.legend()





mainend = datetime.datetime.now()
dt = mainend - mainstart
#print("main cycle time: %s" % dt)

plt.show()



