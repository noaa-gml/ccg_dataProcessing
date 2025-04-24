#! /usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Program for comparing magicc-3 (or other systems) to the official calibration histories  
Uses Kirk's calfit procedure to automatically asses calibration system histories for
the appropriate value assignment. 
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

sys.path.insert(1, "/ccg/python/ccglib")
import ccg_db_conn as db_conn
import ccg_dbutils
import ccg_cal_db 
import ccg_calfit
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





#######################################################################
def calc_fit_unc(xp, fit_result):
    """ calculate the fit value at x, with uncertainty """

    #for key in fit_result.keys():
    #    print(key, fit_result[key])
    #print("")
   
    if fit_result["fit_type"].lower() == "mean":
        fit_order = 0
    elif fit_result["fit_type"].lower() == "linear":
        fit_order = 1
        #val = fit_result["coef0"] + fit_result["coef1"]*xp 
    elif fit_result["fit_type"].lower() == "quadratic":
        fit_order = 2
        #val = fit_result["coef0"] + fit_result["coef1"]*xp + fit_result["coef2"]*xp*xp
    else:
        sys.exit("in calc_fit_unc: fit type needs to be linear or quadratic, exiting ...")

    rsd = fit_result["sd_resid"]
    covar = fit_result["covar"]
    #print("rsd: ",rsd)
    #print("covar",covar)
    # partial derivatives of polynomial with respect to the coefficients at point x
    a = numpy.array([xp**i for i in range(fit_order+1)])

    # variance of estimated y value (confidence interval)
    z1 = numpy.dot(a.T, covar)
    var = numpy.dot(z1, a)
    #print("variance is ", var)

    var = var + rsd*rsd  # prediction interval variance
    unc = math.sqrt(var)

    #print("uncertainty at", xp, "is", math.sqrt(var))
    #sys.exit()

    return unc






###########################################################
#######################################################################
def edit_cals(gas, cals, tempfile):
    """ allow user to edit calibration data """
    if gas.lower() == 'co2':
        header = "date_n serial_number fc  date       time      dd         species   value     stddev meas_unc num method     inst  system  flag  noaa_value  noaa_unc  diff  diff_unc co2c13 #notes"
    else:
        header = "date_n serial_number fc  date       time      dd         species   value     stddev meas_unc num method     inst  system  flag  noaa_value  noaa_unc  diff  diff_unc #notes"
    output = '#%s' % (header)

    #for dline in cals:
    #for dline in sorted(cals, key=lambda k: k["diff"]):
    for dline in sorted(cals, key=lambda k: (k["date_range"], k["diff"])):
        #print(dline)
        t = "%s" % dline["time"]
        (hr, mn, sc) = t.split(':')

        output += "\n%-8s" % (dline["date_range"])
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
        output += " %12.3f" % dline["noaa_value"]
        output += " %8.3f" % dline["noaa_unc"]
        output += " %8.3f" % dline["diff"]
        output += " %8.3f" % dline["diff_unc"]
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
            line = "%s " % line
            (tdata, notes) = line.split('#')
            if len(tdata.split()) == 20:
                (d_range, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, noaa_val, noaa_unc, diff, diff_unc, c13) = tdata.split()
            elif len(tdata.split()) == 19:
                (d_range, sn, fc, d, t, dd, sp, val, sd, meas_unc, n, method, tinst, tsystem, flg, noaa_val, noaa_unc, diff, diff_unc) = tdata.split()
                c13 = -999.9
            else:
                print("unknown number of fields")
                print("len(tdata.split()): %s on line: %s" % (len(tdata.split()), line))
                sys.exit()

            tmp_data["date_range"] = int(d_range)
            tmp_data["serial_number"] = sn
            tmp_data["fill_code"] = fc
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
            tmp_data["noaa_value"] = float(noaa_val)
            tmp_data["noaa_unc"] = float(noaa_unc) 
            tmp_data["diff"] = float(diff)
            tmp_data["diff_unc"] = float(diff_unc)
            #tmp_data[""] = 

            edited_data.append(tmp_data)

        return edited_data

    # else after "do you want to edit" question - if answer "no" just use data as is
    return None





#######################################################################
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
        ysd = [d['diff_unc'] for d in ocals]
    else:
        y = [d['noaa_value'] for d in ocals]
        ysd = [d['noaa_unc'] for d in ocals]


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











###########################################################
def fitScales(ocals, degree=None, debug=False):
    """ Determine fit to calibrations

    This function determines the fit to calibrations on each scale
    external_scale - NOAA scale is y axis, external scale is x

    Use the highest degree polynomial where the
    coefficients of the fit are significant.
    Fits are made for a polynomial function; quadratic and linear.
    If the coefficient of the fit is significant, then accept that fit,
    otherwise do another fit dropping one degree in the fit, i.e.
    quadratic first, linear second, mean third.

    Input:
        ocals - list of dicts with calibration results.  These normally come

        debug - Print debugging information if True

    Returns:
        result - namedtuple containing (tzero, coef0, coef1, coef2, unc_c0, unc_c1, unc_c2, sd_resid, n, chisq)
    """

    names = ['tzero', 'coef0', 'coef1', 'coef2', 'unc_c0', 'unc_c1', 'unc_c2', 'sd_resid', 'n', 'chisq']
    Fit = namedtuple('calfit', names)

    #x = [d['dd'] for d in ocals]
    x = [d['value'] for d in ocals]
    np = len(x)
    print("len(x): %s" % len(x))

    # if no cals, return default value
    if np == 0:
        t = (0.0, -999.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0)

    else:


        #y = [d['mixratio'] for d in ocals]
        y = [d['diff'] for d in ocals]
        #ysd = [math.sqrt(d['noaa_unc']**2 + d['noaa_stddev']**2) for d in ocals]
        ysd = [d['diff_unc'] for d in ocals]
        ysd2 = 1.0 / numpy.array(ysd)**2
        tzero = numpy.average(x, weights=ysd2)  # weighted average of central date
        ##############################
        #tzero = 0.0 #### hard code central value =0 for scale to scale fit. Need to think if this is appropriate for scale to scale plot
        ##############################
        x = [xp - tzero for xp in x]           # calculate deviation from central date

        # if only one cal, return it's value
        if np == 1:
            t = (0.0, y[0], 0.0, 0.0, ysd[0], 0.0, 0.0, 0.0, 1, 0.0)

        # two or more cals
        else:

            # count up number of unique x values
            # Don't want to fit a quadratic to only 2 x values
            # If number of unique y values is 1, just take the mean
            nx = len(set(x))
            ny = len(set(y))


            if degree is None or degree == "auto":
                # no quadratic fits for 3 cals
                maxfit = 2
                if nx <= 3: maxfit = 1
                if nx <= 1: maxfit = 0
                if ny == 1: maxfit = 0
                minfit = -1
            elif degree == "mean":
                maxfit = 0
                minfit = -1
            elif degree == "linear":
                maxfit = 1
                minfit = 0
            elif degree == "quadratic":
                maxfit = 2
                minfit = 1

            # loop through the degrees of polynomial fit until
            # the highest degree coefficient is significant
            for pfit in range(maxfit, minfit, -1):

                # estimate coefficients with a polynomial ols fit
                beta0 = numpy.polyfit(x, y, pfit)
                beta0 = beta0[::-1] # reverse the order of coefficients for input into curve_fit

                if debug:
                    print("---------------")
                    print("degree of fit:", pfit)
                    print("fit parameters")
                    print("   number of points:", np)
                    print("   number of unique x values:", nx)
                    print("   number of unique y values:", ny)
                    print("   x:", x)
                    print("   y:", y)
                    print("   beta0:", beta0)
                    print("   sigma:", ysd)

                popt, pcov = curve_fit(ccg_calfit.poly2, x, y, p0=beta0, sigma=ysd, absolute_sigma=True)
                beta_sd = numpy.sqrt(numpy.diag(pcov))

                dof = np - len(popt)
                tvalue = ccg_calfit.get_significance(dof)
                tstar = abs(popt[pfit]/beta_sd[pfit])  # test significance of highest degree coefficient

                if debug:
                    print("fit results")
                    print("   coefficients:", popt)
                    print("   coefficients stdv:", beta_sd)
                    print("   coefficient for degree", pfit, "is", popt[pfit])
                    print("   coefficient stdv for degree", pfit, "is", beta_sd[pfit])
                    print("   degrees of freedom", dof)
                    print("   calculated t value is", tstar)
                    print("   t probability is", tvalue)

                success = ccg_calfit.check_tstar(dof, tstar, tvalue, debug)
                if success: break


            # calculate residuals and residual standard deviation
            yvals = numpy.polyval(popt[::-1], x)
            resid = yvals - numpy.array(y)
            rsd = round(numpy.std(resid, ddof=1), 6)

            # reduced chi squared
            chisq = 0 if dof == 0 else round(numpy.sum(numpy.square(resid/ysd)) / dof, 6)

            # build the result tuple.  Need an entry for all three coefficients
            coefs = [0.0, 0.0, 0.0]
            uncs = [0.0, 0.0, 0.0]

            for i in range(len(popt)):
                coefs[i] = round(popt[i], 8)
                uncs[i] = round(beta_sd[i], 8)

            t = ((round(tzero, 6)),) + tuple(coefs) + tuple(uncs) + ((rsd),) + ((np),) + ((chisq),)

    result = Fit._make(t)
    if debug:
        print(result)

    return result


#######################################################################


#######################################################################
# get list of cylinders run on system
def get_tank_cal_data(system, species, parameter_num, inst, sdate, edate, cnt, min_mf, max_mf, system_n_limit, cal_n_limit, diff_limit, fit_inst, remove_nonlinear):
    """  get list of tank cal episodes on system within date range and mole fraction range.
    """
    tmp_data = {}
    system_cals = []

    # pull cal data for the system from calibrations_fill_view
    table = "calibrations_fill_view"
    query = "SELECT serial_number, fill_code, date, time, species, mixratio, stddev, meas_unc, num, method, inst, system, pressure, flag, location, regulator, notes, mod_date from %s " % table
    query += " WHERE system like '%s' and parameter_num = %s and date >= '%s' and date < '%s' and mixratio >= %s and mixratio <= %s " % (
            system, parameter_num, sdate, edate, min_mf, max_mf)
    #print("query: %s" % (query))
    rtn = db.doquery(query, form='dict')
    #print("***** rtn: \n", file=sys.stderr)
    #print(rtn, file=sys.stderr)
    #sys.exit("clean exit")
    
    if len(rtn) > 0:
        for v in rtn:
            #for key in v.keys():
            #    print(key, v[key])
            #sys.exit()

            # test if analytical inst is in requested list of instruments
            if inst:
                if v["inst"] not in inst: 
                    continue

            # determine if meets system_n_limit
            if system_n_limit:
                tbl = "calibrations_fill_view"
                query = "SELECT COUNT(mixratio) from %s " % (tbl)
                query += " where serial_number like '%s' and fill_code like '%s' and system like '%s' and parameter_num = %s " % (
                    v["serial_number"], v["fill_code"], system, parameter_num)
                #print(query)
                sys_count = db.doquery(query, numRows=0)

                if sys_count < system_n_limit: continue

            #remove runs where tank has no fill code. Causes problems when determining value assignment from cal systems.
            if v["fill_code"] is None: continue


            tmp_data["date_range"] = cnt
            tmp_data["serial_number"] = v["serial_number"]
            tmp_data["fill_code"] = v["fill_code"]
            tmp_data["date"] = v["date"]
            tmp_data["time"] = v["time"]
            tmp_data["dd"] = ccg_dates.decimalDate(tmp_data["date"].year,tmp_data["date"].month,tmp_data["date"].day)
            tmp_data["species"] = v["species"]
            tmp_data["value"] = v["mixratio"]
            tmp_data["stddev"] = v["stddev"]

            # use meas_unc if it exists, otherwise use stddev
            if v["meas_unc"] > 0.0: 
                tmp_data["meas_unc"] = v["meas_unc"] 
            else:
                tmp_data["meas_unc"] = v["stddev"]
            tmp_data["num"] = v["num"]
            tmp_data["method"] = v["method"]
            tmp_data["inst"] = v["inst"]
            tmp_data["system"] = v["system"]
            tmp_data["pressure"] = v["pressure"]
            tmp_data["flag"] = v["flag"]
            tmp_data["location"] = v["location"]
            tmp_data["regulator"] = v["regulator"]
            tmp_data["notes"] = v["notes"]

            # if co2, get 13C value of the tank # hardcode database='reftank' for isotope informational values 
            if parameter_num == 1:
                tbl = "reftank.calibrations_fill_view"
                query = "SELECT AVG(mixratio) from %s " % (tbl)
                query += " where serial_number like '%s' and species like 'co2c13' and fill_code like '%s'" % (
                    tmp_data["serial_number"],tmp_data["fill_code"] )
                rtn3 = db.doquery(query, numRows=0 )
                if rtn3:
                    tmp_data["c13"] = rtn3
                else:
                    tmp_data["c13"] = -999.99
            else:
                tmp_data["c13"] = -999.99
            

            # get time dependent assigned value   ----- Have changed this to record the fits from caldrift for each tank, this prevents needing 
            # to access DB over and over for same value assignement info for tgt tanks that are run routinely.
            cval, cunc = get_value_assignment(species, tmp_data["serial_number"], tmp_data["fill_code"], tmp_data["dd"], cal_n_limit, fit_inst, remove_nonlinear) 

            tmp_data["noaa_value"] = cval 
            tmp_data["noaa_unc"] = cunc 
            tmp_data["diff"] = tmp_data["value"] - tmp_data["noaa_value"]
            tmp_data["diff_unc"] = math.sqrt(tmp_data["meas_unc"]**2 + tmp_data["noaa_unc"]**2) # place holder until get unc for ]magicc

            # test diff vs passed limits
            if abs(tmp_data["diff"]) > diff_limit: continue
            
            
            temp_data= copy.deepcopy(tmp_data)
            #for key in temp_data.keys():
            #    print(key, temp_data[key])
            #sys.exit()

            system_cals.append(temp_data)

    return system_cals
 


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
# get assigned value
def get_value_assignment(sp, sn, fc, dd, n_lim, f_i, remove_nonlinear):
    """ get time dependent assigned value from fit to cal system data
    """

    global scale_assignments
  
    if f_i:
        official = False
    else:
        official = True
        f_i = ''

    # look in scale_assignments for entry for sn/fill
    current_key = "%s:%s" % (sn.upper(), fc.upper())

    scale_assignment_entry= next((item for item in scale_assignments if item["key"] == current_key), None)

    if scale_assignment_entry is None:
        #print("no match found, determining value assignment for %s" % current_key, file=sys.stderr)
        #print("in get_value_assignment: sn=%s  fc=%s" % (sn, fc)) 
        c = ccg_cal_db.Calibrations(tank=sn,
                  gas=sp,
                  fillingcode=fc,
                  date=None,
                  method=None,
                  official=official,
                  syslist=f_i,  
                  #uncfile='/home/ccg/crotwell/src/python3/calculate_drift/unc_master.conf',  # hard code exceptions to using official cal results 
                  #uncfile='/home/ccg/crotwell/src/python3/calculate_drift/test_meas_unc/unc_master.conf',  # hard code exceptions to using official cal results 
                  notes=True,
                  database=DATABASE)
        cals = c.cals

        cals = [cal for cal in cals if cal['flag'] == '.']
        # run each tank through caldrift.py to get auto assigned value
        fit = ccg_calfit.fitCalibrations(cals)
        scale_assignments.append({"key": current_key, "calfit": fit})
    else:
        #print("match found, using entry from scale_assignments for %s" % current_key, file=sys.stderr)
        fit = scale_assignment_entry["calfit"]

    # get official cal value
    (cval, cunc) = calc_value(dd, fit)

    # test to make sure number of official cals is greater than passed limit
    if fit.n < n_lim:
        cval = -999.99
        cunc = -999.99
    
    # remove nonlinear drifting tanks if called for
    if remove_nonlinear:
        if fit.coef2 != 0.0:
            cval = -999.99
            cunc = -999.99
            print("%s has nonlinear drift determined, removing from analysis" % current_key, file=sys.stderr)

    #could return fit.coef1, fit.coef2 to help weed out fast/non-linear drifting tanks
    return(cval, cunc)






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
group.add_argument('--remove_nonlinear_drifting', action="store_true", default=False, help="Remove cyliders from comparison where non-linear drift is detected by calibration system, default is False")
group.add_argument('--database', default="reftank", help="Select database to compare/update results. Default is 'reftank'.")
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
group.add_argument('--hide_difference_unc', action="store_true", default=False, help="Supress error bars in difference plot. Default is False")
group.add_argument('--plot_flag', help="Flag to include in plots but not in the fit (default is None). For example --plot_flag=S")
group.add_argument('--no_legend', action="store_true", default=False, help="Set to remove legend from plot")
#group.add_argument('--save_result', action="store_true", default=False, help="Pause and ask user for fit type to save to tempfile (default is False)")
group.add_argument('--fit_debug', action="store_true", default=False, help="Used to print debugging information on statistical testing used in auto fit routine (default is False)")
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

# global list of value assignment for each sn/fill
global scale_assignments
tmp_scale_assignment = {"key": "ABCDEF:Z", "calfit": "qqq"}
scale_assignments = []
scale_assignments.append(tmp_scale_assignment)


#database
global DATABASE
if options.database:
    DATABASE = options.database
else:
    DATABASE = "reftank"

SPECIES = options.species
db_utils = ccg_dbutils.dbUtils()
PARAMETER_NUM = db_utils.getGasNum(SPECIES)
if options.debug: print("SPECIES: %s     PARAMETER_NUM: %s" % (SPECIES, PARAMETER_NUM), file=sys.stderr)

SYSTEM = options.system
if options.debug: print("SYSTEM: %s" % SYSTEM, file=sys.stderr)

# inst
if options.inst:
    inst = list(options.inst.upper().split(','))
else:
    inst = None

# allow or remove tanks with non-linear drift 
#group.add_argument('--remove_nonlinear_drifting', action="store_true", default=False, help="Remove cyliders from comparison where non-linear drift is detected by calibration system, default is False")

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
cnt_date_range = -1

# set up DB connection
global db
db = db_conn.RO(DATABASE)


for i, j in enumerate(startdate):
    print("date range:  %s - %s" % (startdate[i], enddate[i]))
    cnt_date_range += 1

    # find all tanks measured on system during date range with associated time dependent value assignment
    #results = get_tank_cal_data(SYSTEM, SPECIES, PARAMETER_NUM, inst, startdate[i], enddate[i], cnt_date_range, min_molefraction, max_molefraction,
    #                system_n_limit, cal_n_limit, diff_limit, options.fit_inst, database)
    results = get_tank_cal_data(SYSTEM, SPECIES, PARAMETER_NUM, inst, startdate[i], enddate[i], cnt_date_range, min_molefraction, max_molefraction,
                    system_n_limit, cal_n_limit, diff_limit, options.fit_inst, options.remove_nonlinear_drifting)
    #print(type(results)) 
    #print(len(results))
    for dline in results:
        tmp = copy.deepcopy(dline)
        #print(tmp)
        if dline["noaa_value"] < -100: continue
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



    

df = pd.DataFrame(final_data)
#tmp_dict = df.to_dict('records')
#print("type tmp_dict: %s" % type(tmp_dict))
#print("len tmp_dict: %s" % len(tmp_dict))
#for key in tmp_dict[0].keys(): print ("tmp_dict key: %s" % key)

fit_results = []
# loop through date ranges - fit scale relationships
for n, sd in enumerate(startdate):
    #print("n: %s" % n)
    label = "%s - %s" % (startdate[n], enddate[n])
    print("\n********************************************************")
    print("working on fit for %s" % label)
    # get data for date_range
    df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
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
            (cval, unc) = calc_value(dline['value'], fit)
            if options.fit_differences:
                resid = dline["diff"] - cval
            else:
                resid = dline["value"] - cval

            key = fit_type + "_residual"
            if options.debug: print("value: %s   noaa_value: %s   diff: %s    cval: %s   resid: %s" % (dline["value"],dline["noaa_value"],dline["diff"], cval, resid))
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
df_all = df[(df['flag'].isin(plot_flag)) & (df['value'] > -800) & (df["noaa_value"] > -800) ]

# get date range for plotting curves
step = 200
min_value = min(df_all['noaa_value']) * 0.95
max_value = max(df_all['noaa_value']) * 1.05
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
    xlabel = "%s %s\n(%s)" % (gas_formula, gas_units, SYSTEM)
    title = '%s: %s vs calibration system' % (gas_formula, SYSTEM)
    if scale_plot:
        scale_plot.set_title(title)
        ylabel = "%s %s\n(Calibration system)" % (gas_formula, gas_units)
        scale_plot.set_ylabel('%s' % (ylabel))
        if difference_plot is None and residual_plot is None: scale_plot.set_xlabel("%s" % (xlabel))

    if difference_plot:
        if scale_plot is None: difference_plot.set_title(title)
        ylabel = "$\Delta$ %s %s\n(%s - Calibration system)" % (gas_formula, gas_units, SYSTEM)
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
        df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
        df3 = df[(df['flag'] != '.') & (df['flag'].isin(plot_flag)) & (df['value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]

        # plot each inst in diffent color/symbol, close sym if in fit, open if not in fit
        if not df2.empty:
            if scale_plot:
                scale_plot.errorbar(df2['value'], df2['noaa_value'], yerr=df2['noaa_unc'], xerr=df2['meas_unc'], color=col_arr[n],
                      marker=sym_arr[n], linestyle='none', fillstyle='full', label=label )
            if difference_plot:
                if options.hide_difference_unc:
                    difference_plot.plot(df2['value'], df2['diff'], color=col_arr[n],
                          marker=sym_arr[n], linestyle='none', fillstyle='full', label=label )
                else:
                    difference_plot.errorbar(df2['value'], df2['diff'], yerr=df2['diff_unc'], color=col_arr[n],
                          marker=sym_arr[n], linestyle='none', fillstyle='full', label=label )

        if not df3.empty:
            if scale_plot:
                scale_plot.errorbar(df3['value'], df3['noaa_value'], yerr=df3['noaa_unc'], xerr=df3['meas_unc'], color=col_arr[n],
                      marker=sym_arr[n], linestyle='none', fillstyle='none', label=label )
            if difference_plot:
                if options.hide_difference_unc:
                    difference_plot.plot(df3['value'], df3['diff'], color=col_arr[n],
                          marker=sym_arr[n], linestyle='none', fillstyle='none', label=label )
                else:
                    difference_plot.errorbar(df3['value'], df3['diff'], yerr=df3['diff_unc'], color=col_arr[n],
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
                        residual_plot.plot(df2['value'], df2[key], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='full', label="%s %s" % (label, fit_type) )
                    if not df3.empty:
                        residual_plot.plot(df3['value'], df3[key], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='none', label="%s %s not included" % (label, fit_type) )
                else:
                    if not df2.empty:
                        residual_plot.errorbar(df2['value'], df2[key], yerr=df2["diff_unc"], color=col_arr[n],
                                      marker=sym_arr[nnn], linestyle='none', fillstyle='full', label="%s %s" % (label, fit_type) )
                    if not df3.empty:
                        residual_plot.errorbar(df3['value'], df3[key], yerr=df3["diff_unc"], color=col_arr[n],
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
print("Calculating mean offsets for each time period (%s minus calibration system)" % (SYSTEM))
for n, sd in enumerate(startdate):
    label = "%s - %s" % (startdate[n], enddate[n])
    # get data for date_range
    df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]

    # calculate mean offset
    mean_diff, sd_diff, n_diff = mean_stdv(df2["diff"])
    print("    %s mean offset: %12.3f  sd: %8.3f  n: %d" % (label, mean_diff, sd_diff, n_diff))
print("\n\n")

# calculate and print weighted mean offsets
print("\n********************************************************")
print("Calculating weighted mean offsets for each time period (%s minus calibration system)" % (SYSTEM))
for n, sd in enumerate(startdate):
    label = "%s - %s" % (startdate[n], enddate[n])
    # get data for date_range
    df2 = df[(df['flag'] == '.') & (df['value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]

    #fit, covar = odr_fitScales(df2.to_dict('records'), degree=fit_type, fit_differences=True, debug=options.fit_debug)
    
    # calculate mean offset
    x = []
    w = [] 
    for d in df2.to_dict('records'):
        if d["diff_unc"] <= 0.0: continue
        x.append(d["diff"])
        w.append(1.0/d["diff_unc"])
    n = len(w)
    mean_diff = numpy.average(x, weights=w)  

    sd_diff = math.sqrt(numpy.average((x-mean_diff)**2, weights=w)) # this is probably biased with small sample sizes, need to look into more.
    print("    %s weighted mean offset: %12.3f  sd: %8.3f  n: %d" % (label, mean_diff, sd_diff, n))

print("\n\n")




mainend = datetime.datetime.now()
dt = mainend - mainstart
#print("main cycle time: %s" % dt)

plt.show()



