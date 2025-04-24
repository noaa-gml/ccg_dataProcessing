#! /usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Program for comparing tank calibration data in cal_scale_tests with live DB
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
sys.path.insert(1, "/ccg/src/python3/nextgen")
sys.path.insert(1, "/ccg/python/ccglib")

import ccg_db_conn as db_conn
import ccg_dbutils
#import ccg_caldb
#import ccg_cal_db as ccg_caldb
#import ccg_db
import ccg_calfit
import ccg_dates  # for v02, use more of these functions to simplify code dealing with dates.
import ccg_refgasdb



#######################################################################
#######################################################################
def calc_value(dt, result):
    """ calculate the fit value at time dt """

    x = dt - result.tzero
    val = result.coef0 + result.coef1*x + result.coef2*x*x
    unc = result.unc_c0 + result.unc_c1*x + result.unc_c2*x*x

    return val, unc









##################################################################################
def mean_stdv(a):

    average = numpy.mean(a)
    if len(a) > 1:
        std = numpy.std(a, ddof=1)
    else:
        std = 0.0
    nv = len(a)

    return average, std, nv




##################################################################################
# get list of cylinders run on system 
def get_tank_cal_data(system, species, parameter_num, inst, sdate, edate, cnt, min_mf, max_mf, system_n_limit, cal_n_limit, diff_limit, fit_inst, org_database, new_database):
    """  get list of tank cal episodes on system within date range and mole fraction range.
    """
    
    org_db = db_conn.RO(org_database)
    new_db = db_conn.RO(new_database)

    tmp_data = {}
    system_cals = []

    # pull data from new_database
    table = "calibrations_fill_view"
    query = "SELECT idx, serial_number, fill_code, date, time, species, parameter_num, mixratio, stddev, meas_unc, num, method, inst, system, pressure, flag, location, regulator, notes, mod_date from %s " % table
    #query += " WHERE system like '%s' and species like '%s' and date >= '%s' and date < '%s' and mixratio >= %s and mixratio <= %s and flag like '.';" % (
    #        system, species, sdate, edate, min_mf, max_mf)
    query += " WHERE system like '%s' and parameter_num=%s and date >= '%s' and date < '%s' and mixratio >= %s and mixratio <= %s " % (
            system, parameter_num, sdate, edate, min_mf, max_mf)
    #print("query: %s" % query)
    #rtn = ccg_db.dbQueryAndFetch(query, database=new_database, readonly=True, asDict=True, conn=None)
    rtn = new_db.doquery(query, form='dict')

    #z = 0
    if len(rtn) > 0:
        for v in rtn:
            #for key in v.keys():
            #    print(key, v[key])

            ## test cal_n_limit
            #query = "SELECT count(*) from %s " % table
            #query += " WHERE serial_number like '%s' and species like '%s' and flag like '.';" % (v["serial_number"], species)
            #rtn_b = ccg_db.dbQueryAndFetch(query, database=new_database, readonly=True, asDict=True, conn=None)
            #for vv in rtn_b:
            #    #print(vv)
            #    n_total = float(vv["count(*)"])
            #if n_total < cal_n_limit: continue



            tmp_data["date_range"] = cnt
            tmp_data["idx"] = v["idx"]
            tmp_data["serial_number"] = v["serial_number"]
            tmp_data["fill_code"] = v["fill_code"]
            tmp_data["date"] = v["date"]
            #(yr, mo, dy) = v["date"].split('-')
            tmp_data["time"] = v["time"]
            tmp_data["dd"] = ccg_dates.decimalDate(tmp_data["date"].year,tmp_data["date"].month,tmp_data["date"].day)
            tmp_data["species"] = v["species"]
            tmp_data["value"] = v["mixratio"]
            tmp_data["stddev"] = v["stddev"]
            if v["meas_unc"] > 0.0:
                tmp_data["meas_unc"] = v["meas_unc"]
            else:
                tmp_data["meas_unc"] = v["stddev"]
            tmp_data["num"] = v["num"]
            tmp_data["method"] = v["method"]
            if inst:
                if v["inst"] not in inst:
                    #print("drop  %s" % v["inst"])
                    continue
            tmp_data["inst"] = v["inst"]
            tmp_data["system"] = v["system"]
            tmp_data["pressure"] = v["pressure"]
            tmp_data["flag"] = v["flag"]
            tmp_data["location"] = v["location"]
            tmp_data["regulator"] = v["regulator"]
            tmp_data["notes"] = v["notes"]
            #tmp_data["mod_date"] = v["mod_date"]
            #tmp_data["mean_residual"] = -999.99
            #tmp_data["linear_residual"] = -999.99
            #tmp_data["quadratic_residual"] = -999.99
            #tmp_data["auto_residual"] = -999.99


            # determine if meets system_n_limit
            if system_n_limit:
                tbl = "calibrations_fill_view"
                query = "SELECT COUNT(mixratio) from %s " % (tbl)
                query += " where serial_number like '%s' and parameter_num = %s and fill_code like '%s' and system like '%s'" % (
                    tmp_data["serial_number"],tmp_data["parameter_num"], tmp_data["fill_code"], tmp_data["system"] )
                #print(query)
                tmp_data["system_count"] = new_db.doquery(query, numRows=0)
            else:
                tmp_data["system_count"] = 9999


            # if co2, get 13C value of the tank # hardcode database='reftank' for isotope informationa values 
            if species.lower() == "co2":
                tbl = "calibrations_fill_view"
                query = "SELECT AVG(mixratio) from %s " % (tbl)
                query += " where serial_number like '%s' and parameter_num = 7 and fill_code='%s' and flag like '.'" % (
                    tmp_data["serial_number"],tmp_data["fill_code"] )
                tmp_data["c13"] = org_db.doquery(query, numRows=0)
                if not tmp_data["c13"]: tmp_data["c13"] = -999.99
            else:
                tmp_data["c13"] = -999.99


            # get original value from org_database (default = reftank.calibrations)
            query = "SELECT mixratio, stddev, meas_unc from calibrations where idx=%s" % tmp_data["idx"]
            rtn4 = org_db.doquery(query, form='dict')
            if rtn4:
                tmp_data["org_value"] = rtn4[0]["mixratio"]
                if float(rtn4[0]["meas_unc"]) <= 0.0:
                    tmp_data["org_unc"] = float(rtn4[0]["stddev"])
                else:
                    tmp_data["org_unc"] = float(rtn4[0]["meas_unc"])

                tmp_data["diff"] = tmp_data["value"] - tmp_data["org_value"]


            temp_data= copy.deepcopy(tmp_data)
            #for key in temp_data.keys():
            #    print(key, temp_data[key])
            #sys.exit()

            if temp_data["system_count"] > system_n_limit and abs(temp_data["diff"]) < diff_limit:
                system_cals.append(temp_data)

    return system_cals






#######################################################################
def edit_cals(gas, cals, tempfile):
    """ allow user to edit calibration data """
    if gas.lower() == 'co2':
        header = "date_n idx serial_number fc  date       time      dd         species   value     stddev meas_unc num method     inst  system  flag  org_value org_unc  diff  co2c13 #notes"
    else:
        header = "date_n idx serial_number fc  date       time      dd         species   value     stddev meas_unc num method     inst  system  flag  org_value org_unc  diff #notes"
    output = '#%s' % (header)

    #for dline in cals:
    #for dline in sorted(cals, key=lambda k: k["diff"]):
    for dline in sorted(cals, key=lambda k: (k["date_range"], k["diff"])):
        #print(dline)
        t = "%s" % dline["time"]
        (hr, mn, sc) = t.split(':')

        output += "\n%-8s" % (dline["date_range"])
        output += " %12d" % (dline["idx"])
        output += " %-12s" % (dline["serial_number"])
        output += " %-3s" % (dline["fill_code"])
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
        output += " %12.3f" % dline["org_value"]
        output += " %8.3f" % dline["org_unc"]
        output += " %8.3f" % dline["diff"]
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
            print(line, file=sys.stderr)
            tmp_data = {}
            line = line.lstrip()
            if line.startswith("#"): continue
            line = line.rstrip('\r\n')
            (tdata, notes) = line.split('#')
            print("len(tdata): %s" % len(tdata.split()))
            
            if len(tdata.split()) == 20:
                (d_range, idx, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, org_val, org_unc, diff, c13) = tdata.split()
            elif len(tdata.split()) == 19:
                (d_range, idx, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, org_val, org_unc, diff) = tdata.split()
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
            tmp_data["org_value"] = float(org_val)
            tmp_data["org_unc"] = float(org_unc)
            tmp_data["diff"] = float(diff)
            #tmp_data["diff_unc"] = float(diff_unc)
            #tmp_data[""] = 

            edited_data.append(tmp_data)

        return edited_data

    # else after "do you want to edit" question - if answer "no" just use data as is
    return None






#######################################################################
def odr_fitScales(ocals, degree=None, fit_differences=False, debug=False):
    """ Do odr fit to values 
    """

    if degree.lower() == 'mean':
        fit_degree = 0
    elif degree.lower() == 'linear':
        fit_degree = 1
    elif degree.lower() == 'quadratic':
        fit_degree = 2
    else:
        sys.exit("odr fit must be linear or quadratic, exiting ...")

    names = ['tzero', 'coef0', 'coef1', 'coef2', 'unc_c0', 'unc_c1', 'unc_c2', 'sd_resid', 'n', 'chisq']
    Fit = namedtuple('calfit', names)

    x = [d['value'] for d in ocals]
    xsd = [d['meas_unc'] for d in ocals]
    np = len(x)
    #print("len(x): %s" % len(x))

    if fit_differences:
        y = [d['diff'] for d in ocals]
        #ysd = [d['diff_unc'] for d in ocals]  # for now use meas_unc for unc on differences
        ysd = [d['meas_unc'] for d in ocals]
    else:
        y = [d['org_value'] for d in ocals]
        ysd = [d['org_unc'] for d in ocals]


    # set up and run odr fit, give it plenty of iterations and an initial estimate of the coefficients
    func = models.polynomial(fit_degree)
    beta0 = numpy.polyfit(x, y, fit_degree)   # initial guess at coefficients
    beta0 = beta0[::-1] # reverse the order of coefficients for input into odr
    mydata = odr.RealData(x, y, xsd, ysd)
    myodr = odr.ODR(mydata, func, beta0=beta0, maxit=1000)
    myodr.set_job(0)
    if debug:
        myodr.set_iprint(init=2, iter=2, final=2)
    fit = myodr.run()
    if debug: print(fit)

    resid = numpy.polyval(fit.beta[::-1], x) - numpy.array(y)
    rmean = numpy.mean(resid)
    if debug: print("residuals are:\n", resid)
    rsd = numpy.std(resid, ddof=fit_degree)
    if debug: print("rsd is", rsd)

    # Results and errors
    coeff = list(fit.beta)
    covar = fit.cov_beta
    dof = len(coeff)

    if debug:
        print("odr output:")
        print("   beta:", coeff)
        print("   type(beta):", type(coeff))
        print("   beta std error:", fit.sd_beta)
        print("   residual mean:", rmean)
        print("   residual standard deviation:", rsd)
        print("cov:")
        print(fit.cov_beta)
        print(" ")

    # reduced chi squared
    #chisq = 0 if dof == 0 else round(numpy.sum(numpy.square(residuals/ysd)) / dof, 6)
    chisq = 0.0

    ## build the result tuple.  Need an entry for all three coefficients
    coefs = [0.0, 0.0, 0.0]
    uncs = [0.0, 0.0, 0.0]

    for i in range(len(coeff)):
        coefs[i] = round(coeff[i], 8)
        uncs[i] = round(fit.sd_beta[i], 8)

    tzero = 0.0
    t = ((round(tzero, 6)),) + tuple(coefs) + tuple(uncs) + ((rsd),) + ((np),) + ((chisq),)

    result = Fit._make(t)
    if debug:
        print(result)

    return result, fit.cov_beta








#######################################################################
# checks/configuration
col_arr = ['r','b','g','c','m','y','b','r','m','g','r','b','m','y','r','b','g','c','m','y','b','r','m','g','r','b','m','y']
sym_arr = ['o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x']

tempfile = "%s/tempfile_compare_cal_scale_tests.txt" % os.getenv("HOME") # temp file for editing data

parser = argparse.ArgumentParser(description="Compare systems with official calibration system history")

#        epilog="Only one of the output options should be given.  No options means print out a single result line to stdout.")

group = parser.add_argument_group("Data Selection Options")

#Add ability to select system and inst used in fits - may need ability to pass in non-standard unc file
# add ability to select inst used for system passed in.
#
#
#group.add_argument('--fillcode', type=str.upper, help="Specify fillcode. Default is None which causes code to return list and ask")
group.add_argument('--inst', help="Specify inst codes to pull from database, default is all. For example --inst=L9,PC1 ")
group.add_argument('--system', help="Specify systems to pull from database, default is all. For example --system=magicc-3 ")
#group.add_argument('--check_assignments_table', action="store_true", default=True, help="Check for assigned value in lookup table for primary stds. ")
#group.add_argument('--uncfile', help="Pass in path to non-default scale transfer uncrtainty table used for weights in fit.")
group.add_argument('--date_ranges', help="Pass in a list of date ranges to process. Use ':' to separate start:end dates and ',' to separate ranges. For example --date_ranges=1990:1999,2004:2005,2021-01-01:2021-03-31,2022-01:2022-06")
group.add_argument('--range', help="Pass in mole fraction range to limit. For example --range=350,450. If one value, assume minimum.")
group.add_argument('--c13_limit', help="Pass in 13C limit to remove depleted tanks (or CO2). For example --13C_limit=-15")
group.add_argument('--cal_n_limit', help="Pass in limit for number of calibrations on the calibration system. For example --cal_n_limit=5")
group.add_argument('--system_n_limit', help="Pass in limit for number of calibrations on the calibration system. For example --system_n_limit=5")
group.add_argument('--diff_limit', help="Pass in limit for abs diff to reject outliers. For example --diff_limit=5")
group.add_argument('--org_database', default="reftank", help="Select database to compare (org results). Default is 'reftank'.")
group.add_argument('--new_database', default="cal_scale_tests", help="Select database to compare (new results). Default is 'cal_scale_tests'.")
group.add_argument('--moddate', help="Use values for standards before this modification date. For example --moddate=2014-05-01")
#group.add_argument('--use_grav', action="store_true", default=False, help=" Add in the original gravimetric value from DB tables. Default is False.")

group = parser.add_argument_group("Fitting Options for differences")
group.add_argument('--edit', action="store_true", default=False, help="Allow user to select/edit data offline prior to fit.")
group.add_argument('--fit_inst', help="Specify instrument to use to value assign tank. This is a subset of inst displayed. For example --inst=L9,PC1 ")
#group.add_argument('--fit_official', action="store_true", default=False, help="Use only official calibration instruments in the fit.  This is an alternative to --fit_inst ")
group.add_argument('--fit_differences', action="store_true", default=False, help="Fit differences rather than odr fit to values")
group.add_argument('--auto_fit', action="store_true", default=False, help="Show results of auto significance testing of fits.")
group.add_argument('--mean', action="store_true", default=False, help="Show weighted mean (default is False).")
group.add_argument('--linear', action="store_true", default=False, help="Show linear fit (default is False).")
group.add_argument('--quadratic', action="store_true", default=False, help="Show quadratic fit (default is False).")
#group.add_argument('--include_flag', default=".", help="Specify flags to include in fit (default is '.'). For example --include_flag=.,S,r")
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
group.add_argument('--plot', action="store_true", default=False, help="Create a plot of system results vs assigned value from calibration system . Default is False.")
group.add_argument('--plot_differences', action="store_true", default=False, help="Create a plot of differences (system results - assigned value from calibration system) vs mole fraction . Default is False.")
group.add_argument('--plot_residuals', action="store_true", default=False, help="Plot residuals from fit. Default is False")
group.add_argument('--plot_unc', action="store_true", default=False, help="Plot uncertainty of scale conversion. Default is False")
group.add_argument('--hide_residual_unc', action="store_true", default=False, help="Supress error bars in residuals plot. Default is False")
group.add_argument('--hide_diff_unc', action="store_true", default=False, help="Supress error bars in difference plot. Default is False")
group.add_argument('--vs_time', action="store_true", default=False, help="Plot differences vs time rather than the default mole fraction")
group.add_argument('--plot_flag', help="Flag to include in plots but not in the fit (default is None). For example --plot_flag=S")
group.add_argument('--no_legend', action="store_true", default=False, help="Set to remove legend from plot")
#group.add_argument('--save_result', action="store_true", default=False, help="Pause and ask user for fit type to save to tempfile (default is False)")
group.add_argument('--fit_debug', action="store_true", default=False, help="Used to print debugging information on statistical testing used in auto fit routine (default is False)")
#group.add_argument('--info', action="store_true", default=False, help="Print out input data and residuals.")
#group.add_argument('--vertical_mark', default=None, help="Dates to place vertical mark on plots")
#group.add_argument('-u', '--update', action="store_true", default=False, help="Save fit parameters in scale assignment database table. Only one fit type can be used.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Print out extra information.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")

# required arguments
parser.add_argument('species', help="Specify species to value assign tank.")

options = parser.parse_args()


mainstart = datetime.datetime.now()

# Setup
db = ccg_dbutils.dbUtils()
SPECIES = options.species
#import ccg_dbutils
PARAMETER_NUM = db.getGasNum(SPECIES)
if options.debug: print("SPECIES: %s   PARAMETER_NUM: %s" % (SPECIES, PARAMETER_NUM), file=sys.stderr)

SYSTEM = options.system
if options.debug: print("SYSTEM: %s" % SYSTEM, file=sys.stderr)

# databases
org_database = options.org_database
new_database = options.new_database
if options.debug: print("Database 1 (org values):  %s " % org_database)
if options.debug: print("Database 2 (new values):  %s " % new_database)

# inst
if options.inst:
    inst = list(options.inst.upper().split(','))
else:
    inst = None

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

# flags to include in plot, these are flags in addition to '.'
plot_flag = ['.']
if options.plot_flag:
    plot_flag = plot_flag + options.plot_flag.split(',')



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
# Pass in a list of date ranges to process. Use ':' to separate start:end dates and '/' to separate ranges. 
# For example --date_ranges=1990:1999/2004:2005/2021-01-01:2021-03-31/2022-01:2022-06
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
    results = get_tank_cal_data(SYSTEM, SPECIES, PARAMETER_NUM, inst, startdate[i], enddate[i], cnt_date_range, min_molefraction, max_molefraction,
                    system_n_limit, cal_n_limit, diff_limit, options.fit_inst, org_database, new_database)
    #print(type(results)) 
    #print(len(results))
    for dline in results:
        tmp = copy.deepcopy(dline)
        #print(tmp)
        if dline["value"] < -100: continue
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







# start fitting of offsets 
df = pd.DataFrame(final_data)

fit_results = []
# loop through date ranges - fit scale relationships
for n, sd in enumerate(startdate):
    #print("n: %s" % n)
    label = "%s - %s" % (startdate[n], enddate[n])
    print("\n********************************************************")
    print("working on fit for %s" % label)
    # get data for date_range
    df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["org_value"] > -800) & (df["date_range"] == n) ]
    #tmp_dict = df2.to_dict('records')
    #print("type tmp_dict: %s" % type(tmp_dict))
    #print("len tmp_dict: %s" % len(tmp_dict))
    #for key in tmp_dict[0].keys(): print ("tmp_dict key: %s" % key)



    for fit_type in fit_types:
        tmp_fit_results = {}

        #print("fit of selected data" % fit_type)
        if options.fit_differences:
            #fit = fitScales(df2.to_dict('records'), degree=fit_type, debug=options.fit_debug)
            fit, covar = odr_fitScales(df2.to_dict('records'), degree=fit_type, fit_differences=True, debug=options.fit_debug)
        else:
            #fit = ............ odr fit of values
            fit, covar = odr_fitScales(df2.to_dict('records'), degree=fit_type, fit_differences=False, debug=options.fit_debug)


        if options.verbose:
            #print("Serial Number: %s" % tank_serial_number)
            #print("Fill Code:     %s" % fillcode)
            print("-----\n %s - %s: " % (label, fit_type))
            print("Gas:           %s" % SPECIES)
            #print("Time zero:     %s" % fit.tzero)
            print("Coeff. 0:      %s" % fit.coef0)
            print("Coeff. 1:      %s" % fit.coef1)
            print("Coeff. 2:      %s" % fit.coef2)
            print("Unc Coeff. 0:  %s" % fit.unc_c0)
            print("Unc Coeff. 1:  %s" % fit.unc_c1)
            print("Unc Coeff. 2:  %s" % fit.unc_c2)
            print("Residual Stdv. %s" % fit.sd_resid)
            print("Reduce Chisq   %s" % fit.chisq)

        tmp_fit_results["date_range"] = n
        tmp_fit_results["fit_type"] = fit_type
        tmp_fit_results["time_zero"] = fit.tzero
        tmp_fit_results["coef0"] = fit.coef0
        tmp_fit_results["coef1"] = fit.coef1
        tmp_fit_results["coef2"] = fit.coef2
        tmp_fit_results["unc_c0"] = fit.unc_c0
        tmp_fit_results["unc_c1"] = fit.unc_c1
        tmp_fit_results["unc_c2"] = fit.unc_c2
        tmp_fit_results["sd_resid"] = fit.sd_resid
        tmp_fit_results["chisq"] = fit.chisq
        tmp_fit_results["n"] = fit.n
        tmp_fit_results["covar"] = covar
        fit_results.append(copy.deepcopy(tmp_fit_results))

        # get residuals from fit
        for nnn, dline in enumerate(final_data):
            if dline["date_range"] != n: continue
            #for key in dline.keys():
            #    print("key: %s   val: %s" % (key, dline[key]), file=sys.stderr)
            (cval, unc) = calc_value(dline['value'], fit)
            if options.fit_differences:
                resid = dline["diff"] - cval
            else:
                resid = dline["value"] - cval

            key = fit_type + "_residual"
            if options.debug: print("value: %s   org_value: %s   diff: %s    cval: %s   resid: %s" % (dline["value"],dline["org_value"],dline["diff"], cval, resid))
            final_data[nnn][key] = resid



# print fit results
print("\n********************************************************")
print("Fit results for %s vs calibration system" % (SYSTEM))
for ft in fit_results:
    msg = "%s - %s" % (startdate[ft["date_range"]], enddate[ft["date_range"]])
    msg += " (%s):" % ft["fit_type"]
    msg += "Y = %12.6f (%12.6f)" % (ft["coef0"], ft["unc_c0"])
    if ft["coef1"] != 0.0: msg += " + %12.6f (%12.6f) * [meas_value] " % (ft["coef1"], ft["unc_c1"])
    if ft["coef2"] != 0.0: msg += " + %12.6f (%12.6f) * [meas_value]^2" % (ft["coef2"], ft["unc_c2"])
    #msg += " (wt_mean: %12.6f  sdresid: %12.6f   reduced chisquare: %12.6f n: %d)" % (ft["time_zero"], ft["sd_resid"], ft["chisq"], ft["n"])
    msg += " (sdresid: %12.6f   reduced chisquare: %12.6f n: %d)" % (ft["sd_resid"], ft["chisq"], ft["n"])
    print("    %s" % msg)


# new df now includes residuals
df = pd.DataFrame(final_data)

# get range from all good data
df_all = df[(df['flag'].isin(plot_flag)) & (df['value'] > -800) & (df["org_value"] > -800) ]

# get date range for plotting curves
step = 200
if options.vs_time:
    min_value = min(df_all['date']) # for fitting lines, may need to change to using df_all['dd']
    max_value = max(df_all['date'])
else:
    min_value = min(df_all['value']) * 0.95
    max_value = max(df_all['value']) * 1.05
interval = (max_value - min_value) / step
line_x = [n * interval + (min_value) for n in range(step)]


### plots
#  scale vs scale - 1:1 line and fit line
#  differences vs noaa scale and residuals to fit
num_plots = 0
if options.plot: num_plots += 1
if options.plot_differences: num_plots += 1
if options.plot_residuals: num_plots += 1

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
    if options.plot:
        scale_plot = axs[current_plot] if options.plot_residuals or options.plot_differences else axs
        current_plot += 1
    else:
        scale_plot = None

    if options.plot_differences:
        difference_plot = axs[current_plot] if options.plot_residuals or options.plot else axs
        current_plot += 1
    else:
        difference_plot = None

    if options.plot_residuals or options.plot_unc:
        residual_plot = axs[current_plot] if options.plot or options.plot_differences else axs
    else:
        residual_plot = None

    #label axis
    #xlabel = "%s %s\n(%s)" % (gas_formula, gas_units, ext_scale)
    if options.vs_time:
        xlabel = "analysis date"
    else:
        xlabel = "%s %s\n(%s)" % (gas_formula, gas_units, SYSTEM)
    #title = '%s: %s cal_scale_tests vs live DB' % (gas_formula, SYSTEM)
    title = '%s (%s): %s vs %s' % (gas_formula, SYSTEM, new_database, org_database)
    if scale_plot:
        scale_plot.set_title(title)
        ylabel = "%s %s\n(%s)" % (gas_formula, gas_units,new_database)
        scale_plot.set_ylabel('%s' % (ylabel))
        if difference_plot is None and residual_plot is None: scale_plot.set_xlabel("%s" % (xlabel))

    if difference_plot:
        if scale_plot is None: difference_plot.set_title(title)
        ylabel = "$\Delta$ %s %s\n(%s - %s)" % (gas_formula, gas_units, new_database, org_database)
        difference_plot.set_ylabel(ylabel)
        difference_plot.set_xlabel("%s" % (xlabel))

    if residual_plot:
        if scale_plot is None and difference_plot is None: residual_plot.set_title(title)
        ylabel = "%s Residuals\n%s" % (gas_formula, gas_units)
        residual_plot.set_ylabel(ylabel)
        if difference_plot is None: residual_plot.set_xlabel("%s" % (xlabel))

   # plot 1:1 line in scale plot
    line_y = []
    for x in line_x:
        line_y.append(x)
    if scale_plot: scale_plot.plot(line_x, line_y, linestyle='dotted', color='black')

    # plot 0:0 line in difference and residual plots
    line_y = []
    for x in line_x:
        line_y.append(0.0)
    if difference_plot: difference_plot.plot(line_x, line_y, linestyle='dotted', color='black')
    if residual_plot: residual_plot.plot(line_x, line_y, linestyle='dotted', color='black')


    # loop through date ranges
    for n, sd in enumerate(startdate):
        #print("n: %s" % n)
        label = "%s - %s" % (startdate[n], enddate[n])
        #print("working on %s" % label)
        # get data for date_range
        df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["org_value"] > -800) & (df["date_range"] == n) ]
        df3 = df[(df['flag'] != '.') & (df['flag'].isin(plot_flag)) & (df['value'] > -800) & (df["org_value"] > -800) & (df["date_range"] == n) ]

        # plot each inst in diffent color/symbol, close sym if in fit, open if not in fit
        if not df2.empty:
            if options.vs_time:
                xval = df2['date']
            else:
                xval = df2['org_value']

            if scale_plot:
                scale_plot.errorbar(xval, df2['value'], yerr=df2['org_unc'], xerr=df2['meas_unc'], color=col_arr[n],
                      marker=sym_arr[n], linestyle='none', fillstyle='full', label=label )
            if difference_plot:
                if options.hide_diff_unc:
                    difference_plot.errorbar(xval, df2['diff'], color=col_arr[n],
                          marker=sym_arr[n], linestyle='none', fillstyle='full', label=label )
                else:
                    difference_plot.errorbar(xval, df2['diff'], yerr=df2['meas_unc'], color=col_arr[n],
                          marker=sym_arr[n], linestyle='none', fillstyle='full', label=label )

        if not df3.empty:
            if options.vs_time:
                xval = df3['date']
            else:
                xval = df3['org_value']

            if scale_plot:
                scale_plot.errorbar(xval, df3['_value'], yerr=df3['org_unc'], xerr=df3['meas_unc'], color=col_arr[n],
                      marker=sym_arr[n], linestyle='none', fillstyle='none', label=label )
            if difference_plot:
                difference_plot.errorbar(xval, df3['diff'], yerr=df3['meas_unc'], color=col_arr[n],
                      marker=sym_arr[n], linestyle='none', fillstyle='none', label=label )


        # plot line for fits (either in scale plot or difference plot) 
        for ft in fit_results:
            if ft["date_range"] != n: continue
            #print("coef0: %15.8f   coef1: %15.8f   coef2: %15.8f" % (ft["coef0"], ft["coef1"], ft["coef2"]))
            line_y = []
            for x in line_x:
                dx = x-ft["time_zero"]
                y = ft["coef0"] + ft["coef1"]*dx + ft["coef2"]*dx*dx
                line_y.append(y)
            if options.fit_differences and difference_plot:
                difference_plot.plot(line_x, line_y, linestyle='dotted', color=col_arr[n], label='%s %s' % (label,ft["fit_type"]))
            elif scale_plot:
                scale_plot.plot(line_x, line_y, linestyle='dotted', color=col_arr[n], label='%s %s' % (label,ft["fit_type"]))
            else:
                pass

        # plot residuals 
        if residual_plot and options.plot_residuals:
            for nnn, fit_type in enumerate(fit_types):
                key = fit_type + "_residual"
                if options.hide_residual_unc:
                    if not df2.empty:
                        if options.vs_time:
                            xval = df2['date'] # for fitting lines, may need to change to using df_all['dd']
                        else:
                            xval = df2['org_value']

                        residual_plot.plot(xval, df2[key], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='full', label="%s %s" % (label, fit_type) )
                    if not df3.empty:
                        if options.vs_time:
                            xval = df3['date'] # for fitting lines, may need to change to using df_all['dd']
                        else:
                            xval = df3['org_value']

                        residual_plot.plot(xval, df3[key], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='none', label="%s %s not included" % (label, fit_type) )
                else:
                    if not df2.empty:
                        if options.vs_time:
                            xval = df2['date']
                        else:
                            xval = df2['org_value']

                        residual_plot.errorbar(xval, df2[key], yerr=df2["meas_unc"], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='full', label="%s %s" % (label, fit_type) )
                    if not df3.empty:
                        if options.vs_time:
                            xval = df3['date']
                        else:
                            xval = df3['org_value']

                        residual_plot.errorbar(xval, df3[key], yerr=df3["meas_unc"], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='none', label="%s %s not included" % (label, fit_type) )



        ##########    
        # plot uncertainty on the residual plot
        if options.plot_unc:

            for ft in fit_results:
                if ft["date_range"] != n: continue

                line_y = []
                line_y_neg = []
                for x in line_x:
                    cunc = calc_fit_unc(x, ft)
                    #print(x, cunc)
                    line_y.append(cunc)
                    line_y_neg.append(-1.0*cunc)
                residual_plot.plot(line_x, line_y, linestyle='dashed', color=col_arr[n], label='%s %s unc (1-sigma)' % (label, ft["fit_type"]))
                residual_plot.plot(line_x, line_y_neg, linestyle='dashed', color=col_arr[n], label='%s %s unc (1-sigma)' % (label, ft["fit_type"]))




    if not options.no_legend:
        if scale_plot:
            scale_plot.legend()
        elif difference_plot:
            difference_plot.legend()
        elif residual_plot:
            residual_plot.legend()


# calculate and print mean offsets
print("\n********************************************************")
print("Calculating mean offsets for each time period (%s minus %s)" % (new_database, org_database))
for n, sd in enumerate(startdate):
    label = "%s - %s" % (startdate[n], enddate[n])
    # get data for date_range
    df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["org_value"] > -800) & (df["date_range"] == n) ]

    # calculate mean offset
    mean_diff, sd_diff, n_diff = mean_stdv(df2["diff"])
    print("    %s mean offset: %12.3f  sd: %8.3f  n: %d" % (label, mean_diff, sd_diff, n_diff))
print("\n\n")

# calculate and print weighted mean offsets
print("\n********************************************************")
print("Calculating weighted mean offsets for each time period (%s minus %s)" % (org_database, new_database))
for n, sd in enumerate(startdate):
    label = "%s - %s" % (startdate[n], enddate[n])
    # get data for date_range
    df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["org_value"] > -800) & (df["date_range"] == n) ]

    #fit, covar = odr_fitScales(df2.to_dict('records'), degree=fit_type, fit_differences=True, debug=options.fit_debug)

    # calculate mean offset
    x = []
    w = []
    for d in df2.to_dict('records'):
        if d["meas_unc"] <= 0.0: continue
        x.append(d["diff"])
        w.append(1.0/d["meas_unc"])
    n = len(w)
    try:
        mean_diff = numpy.average(x, weights=w)
        sd_diff = math.sqrt(numpy.average((x-mean_diff)**2, weights=w)) # this is probably biased with small sample sizes, need to look into more.
        print("    %s weighted mean offset: %12.3f  sd: %8.3f  n: %d" % (label, mean_diff, sd_diff, n))
    except:
        print("weighted mean_diff could not be calculated")


print("\n\n")




mainend = datetime.datetime.now()
dt = mainend - mainstart
#print("main cycle time: %s" % dt)

plt.show()





