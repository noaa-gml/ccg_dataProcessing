#! /usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Program for comparing scales (NOAA vs and external independent scale)
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

sys.path.append("/ccg/python/ccglib")
#sys.path.insert(1, "/ccg/src/python3/lib")
#sys.path.insert(1, "/ccg/src/python3/nextgen")
import ccg_cal_db 
import ccg_db_conn
import ccg_dbutils

#import ccg_db # SWITCH TO START USING CCG_DBUTILS.PY INSTEAD
import ccg_calfit
import ccg_dates  # for v02, use more of these functions to simplify code dealing with dates.
import ccg_refgasdb
#import ccg_flaskunc
import ccg_utils



#######################################################################
def edit_cals(gas, data, tempfile):
    """ allow user to edit calibration data """

    header = "idx date_rng sn    fc   date     time  dd       sp ext_val ext_sd  ext_unc ext_n noaa_val noaa_unc diff diff_unc ext_method ext_lab ext_system pressure flag location reg mod_date # comments"
    output = '#%s' % (header)
    for dline in data:
        #print(dline)
        t = "%s" % dline["time"]
        (hr, mn, sc) = t.split(':')

        output += "\n%1s" % ("0")
        output += " %2d" % (dline["date_range"])
        output += " %3d" % (dline["meas_lab_num"])
        output += " %-10s" % (dline["serial_number"])
        output += " %-2s" % (dline["fill_code"])
        output += " %4d-%02d-%02d" % (dline["date"].year, dline["date"].month, dline["date"].day)
        output += " %8s" % (dline["time"])
        output += " %9.4f" % (dline["dd"])
        output += " %6s" % dline["species"]
        output += " %9.3f" % (dline["ext_value"])
        output += " %9.3f" % (dline["ext_stddev"])
        output += " %9.3f" % (dline["ext_unc"])
        output += " %3s" % (dline["num"])
        output += " %9.3f" % (dline["noaa_value"])
        output += " %9.3f" % (dline["noaa_unc"])
        output += " %8.3f" % (dline["diff"])
        output += " %8.3f" % (dline["diff_unc"])
        output += " %10s" % (dline["method"])
        output += " %10s" % (dline["inst"])
        output += " %10s" % (dline["system"])
        output += " %5s" % (dline["pressure"])
        output += " %1s" % (dline["flag"])
        output += " %3s" % (dline["location"])
        output += " %10s" % (dline["regulator"])
        output += " %10s" % (dline["mod_date"])
        #output += " %s" % (dline["mean_residual"])
        #output += " %s" % (dline["linear_residual"])
        #output += " %s" % (dline["quadratic_residual"])
        #output += " %s" % (dline["auto_residual"])
        output += " #%s" % (dline["notes"])
        #output += " %s" % (dline[""])


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
            
            if len(tdata.split()) == 25:
                (idx, dt_rng,lab_num, sn, fc, d, t, dd, sp, ext_val, ext_sd, ext_unc, ext_n, 
                noaa_val, noaa_unc, diff, diff_unc, 
                ext_method, ext_inst, ext_system, press, flg, loc, reg, md, 
                ) = tdata.split()
            else:
                print("unknown number of fields")
                print("len(tdata.split()): %s on line: %s" % (len(tdata.split()), line))
                sys.exit()


            tmp_data["idx"] = int(idx)
            tmp_data["date_range"] = int(dt_rng)
            tmp_data["meas_lab_num"] = int(lab_num)
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
            tmp_data["ext_value"] = float(ext_val)
            tmp_data["ext_stddev"] = float(ext_sd) 
            tmp_data["ext_unc"] = float(ext_unc) 
            tmp_data["num"] = int(ext_n) 
            tmp_data["method"] = ext_method 
            tmp_data["inst"] = ext_inst 
            tmp_data["system"] = ext_system 
            tmp_data["pressure"] = int(press)
            tmp_data["flag"] = flg 
            tmp_data["location"] = loc 
            tmp_data["regulator"] = reg
            tmp_data["mod_date"] = md 
            tmp_data["noaa_value"] = float(noaa_val) 
            tmp_data["noaa_unc"] = float(noaa_unc) 
            tmp_data["diff"] = float(diff) 
            tmp_data["diff_unc"] = float(diff_unc) 
            tmp_data["mean_residual"] = -999.9 
            tmp_data["linear_residual"] = -999.9 
            tmp_data["quadratic_residual"] = -999.9 
            tmp_data["auto_residual"] = -999.9 
            tmp_data["notes"] = notes
            #tmp_data[""] = 

            edited_data.append(tmp_data)

        return edited_data

    # else after "do you want to edit" question - if answer "no" just use data as is
    return None




#######################################################################
def calc_fit_unc(xp, fit_result):
    """ calculate the fit value at x, with uncertainty """

    #for key in fit_result.keys():
    #    print(key, fit_result[key])
    #print("")
    
    if fit_result["fit_type"].lower() == "linear":
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

#######################################################################
def calc_value(dt, result):
    """ calculate the fit value at time dt """

    x = dt - result.tzero
    val = result.coef0 + result.coef1*x + result.coef2*x*x
    ci = result.unc_c0 + result.unc_c1*x + result.unc_c2*x*x
    #print(result)
    # add sd_resid to CI to get unc
    unc = numpy.sqrt(ci**2 + result.sd_resid**2)

    return val, ci, unc


#######################################################################
#######################################################################
def odr_fitScales(ocals, degree=None, debug=False):
    """ Do odr fit to values 
    """

    if degree.lower() == 'linear':
        fit_degree = 1
    elif degree.lower() == 'quadratic':
        fit_degree = 2
    else:
        sys.exit("odr fit must be linear or quadratic, exiting ...")

    names = ['tzero', 'coef0', 'coef1', 'coef2', 'unc_c0', 'unc_c1', 'unc_c2', 'sd_resid', 'n', 'chisq']
    Fit = namedtuple('calfit', names)

    x = [d['ext_value'] for d in ocals]
    xsd = [d['ext_unc'] for d in ocals]
    np = len(x)
    #print("len(x): %s" % len(x))

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
    print("residuals are", resid)
    rsd = numpy.std(resid, ddof=fit_degree)
    print("rsd is", rsd)

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
    x = [d['ext_value'] for d in ocals]
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
        tzero = 0.0 #### hard code central value =0 for scale to scale fit. Need to think if this is appropriate for scale to scale plot
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
#######################################################################



    #ext_data = get_external_cals(SPECIES, ext_scale_num, options.meas_lab_num, startdate[i], enddate[i], cnt_date_range, min_mf, max_mf)
#######################################################################
def get_external_cals(species, parameter_num, scale_num, meas_lab_num, sdate, edate, cnt, min_mf, max_mf):
    """ get external calibrations 
        ext_data = get_external_cals(SPECIES, PARAMETER_NUM, ext_scale_num, startdate[i], enddate[i]):
    """
    
    tmp_data = {}
    external_cals = []

    # pull external data from reftank.external_calibrations
    
    external_table = "external_calibrations"
    query = "SELECT serial_number, dt, value, stddev, n, method, inst, system, pressure, flag, meas_lab_num, regulator, notes, mod_date, scale_transfer_unc from %s " % external_table
    query += " WHERE scale_num = %s and parameter_num = %s and dt >= '%s' and dt < '%s'" % (scale_num, parameter_num, sdate, edate)
    if meas_lab_num: 
        cn = " and ("
        for lab_num in meas_lab_num:
            query += "%s meas_lab_num = %s" % (cn, lab_num)
            cn = " or "
        query += ")"

    query += ";"
    #print(query, file=sys.stderr)
    
    rtn = db.doquery(query, form='dict')

    z = 0
    if len(rtn) > 0:
        for v in rtn:
            #for key in v.keys():
            #    print(key, v[key])
            #sys.exit()
            z += 1
            tmp_data["date_range"] = cnt
            tmp_data["idx"] = z
            tmp_data["serial_number"] = v["serial_number"]
            dt = datetime.date(v["dt"].year, v["dt"].month, v["dt"].day)
            tmp_data["date"] = dt
            date_str = "%s-%02d-%02d" % (v["dt"].year, v["dt"].month, v["dt"].day)
            dt = datetime.timedelta(v["dt"].hour, v["dt"].minute, v["dt"].second)
            tmp_data["time"] = dt
            tmp_data["dd"] = ccg_dates.decimalDate(v["dt"].year, v["dt"].month, v["dt"].day)
            tmp_data["species"] = species
            tmp_data["ext_value"] = float(v["value"])
            tmp_data["ext_stddev"] = float(v["stddev"])
            tmp_data["ext_unc"] = math.sqrt((float(v["scale_transfer_unc"]))**2 + (float(v["stddev"]))**2 ) 
            #tmp_data["ext_unc"] = float(v["stddev"]) # scale transfer not set yet, use sd for testing
            tmp_data["num"] = int(v["n"])
            tmp_data["method"] = v["method"]

            tmp_data["meas_lab_num"] = v["meas_lab_num"]

            # get measurment lab abbr
            obspack_tbl = "obspack.lab"
            query ="SELECT abbr from %s where num = %s" % (obspack_tbl, v["meas_lab_num"])
            lab_abbr = db.doquery(query, numRows=0)
            if not lab_abbr:
                lab_abbr = "na"

            #tmp_data["inst"] = v["inst"]
            tmp_data["inst"] = lab_abbr
            tmp_data["system"] = lab_abbr
            tmp_data["pressure"] = v["pressure"]
            tmp_data["flag"] = v["flag"]
            if v["flag"] == ".":
                if tmp_data["ext_value"] < min_mf or tmp_data["ext_value"] > max_mf: tmp_data["flag"] = "Q"
            tmp_data["location"] = "external"
            tmp_data["regulator"] = v["regulator"]
            tmp_data["notes"] = v["notes"]
            tmp_data["mod_date"] = "%4d-%02d-%02d" % (v["mod_date"].year, v["mod_date"].month, v["mod_date"].day)
            tmp_data["noaa_value"] = -999.99 # place holder for the time corrected Noaa value
            tmp_data["noaa_unc"] = -999.99 #need to get from fit*****************************
            tmp_data["diff"] = -999.99
            tmp_data["diff_unc"] = -999.99
            tmp_data["mean_residual"] = -999.99
            tmp_data["linear_residual"] = -999.99
            tmp_data["quadratic_residual"] = -999.99
            tmp_data["auto_residual"] = -999.99

            ##get fill code
            fill_view = "fill_end_dates_view"
            query = "SELECT fill_code from %s " % fill_view
            query += " WHERE serial_number like '%s' and fill_start_date <= '%s' and fill_end_date > '%s';" % (v["serial_number"], date_str, date_str )
            #print(query)
            fc  = db.doquery(query, numRows=0)
    
            if fc:
                tmp_data["fill_code"] = fc
            else:
                tmp_data["fill_code"] = "none"

            temp_data= copy.deepcopy(tmp_data)
            external_cals.append(temp_data)

    return external_cals










#######################################################################
# checks/configuration
#col_arr = ['r','b','g','c','m','y','b','r','m','g','r','b','m','y','r','b','g','c','m','y','b','r','m','g','r','b','m','y']
col_arr = ['r','b','g','c','m','y','b','r','m','g','r','b','m','y','r','b','g','c','m','y','b','r','m','g','r','b','m','y']
#col_arr = ['k','k','r','c','m','y','b','r','m','g','r','b','m','y','r','b','g','c','m','y','b','r','m','g','r','b','m','y']
#sym_arr = ['o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x']
sym_arr = ['o','s','*','v','D','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x','o','D','s','v','*','P','x']
linestyle_arr = ['dotted','dashdot','dashed','dotted','dashdot','dashed','dotted','dashdot','dashed']

tempfile = "%s/tempfile_external_scale_comparison.txt" % os.getenv("HOME") # temp file for editing data

parser = argparse.ArgumentParser(description="Compare scales - NOAA vs external scale")

#        epilog="Only one of the output options should be given.  No options means print out a single result line to stdout.")

group = parser.add_argument_group("Data Selection Options")

#group.add_argument('--fillcode', type=str.upper, help="Specify fillcode. Default is None which causes code to return list and ask")
#group.add_argument('--inst', help="Specify inst codes to pull from database, default is all. For example --inst=L9,PC1 ")
group.add_argument('--check_assignments_table', action="store_true", default=True, help="Check for assigned value in lookup table for primary stds. ")
group.add_argument('--min_noaa_unc', default=0.0, help="Pass in minimum scale transfer uncrtainty for NOAA results used for weights in fit. Default is 0.015. Pass 0.0 to skip. Not applied to primary stds")
group.add_argument('--date_ranges', help="Pass in a list of date ranges to process. Use ':' to separate start:end dates and '/' to separate ranges. For example --date_ranges=1990:1999/2004:2005/2021-01-01:2021-03-31/2022-01:2022-06")
group.add_argument('--database', default="reftank", help="Select database to compare/update results. Default is 'reftank'.")
group.add_argument('--moddate', help="Use values for standards before this modification date. For example --moddate=2014-05-01")
#group.add_argument('--use_grav', action="store_true", default=False, help=" Add in the original gravimetric value from DB tables. Default is False.")
group.add_argument('--noaa_fit_inst', default=None, help="Base NOAA value on fitting one analyzer. --noaa_fit_inst=pc1,l9")
group.add_argument('--noaa_fit_system', default=None, help="Base NOAA value on fitting one analyzer. --noaa_fit_system=co2cal-2,co2cal-1")

group = parser.add_argument_group("Fitting Options for scale relationship")
group.add_argument('--edit', action="store_true", default=False, help="Allow user to select/edit data offline prior to fit.")
group.add_argument('--fit_differences', action="store_true", default=False, help="Fit differences rather than odr fit to values")
#group.add_argument('--fit_official', action="store_true", default=False, help="Use only official calibration instruments in the fit.  This is an alternative to --fit_inst ")
group.add_argument('--auto_fit', action="store_true", default=False, help="Show results of auto significance testing of fits.")
group.add_argument('--mean', action="store_true", default=False, help="Show weighted mean (default is False).")
group.add_argument('--linear', action="store_true", default=False, help="Show linear fit (default is False).")
group.add_argument('--quadratic', action="store_true", default=False, help="Show quadratic fit (default is False).")
group.add_argument('--include_flag', default=".", help="Specify flags to include in fit (default is '.'). For example --include_flag=.,S,r")
group.add_argument('--fit_range', default="-800,9999", help="Specify mole fraction range to include in fit (default is -9999 to +9999). For example --fit_range=350,450")
#group.add_argument('--use_sd', action="store_true", default=False, help="Use std dev of episode for weighting in fit. Ignores the scale transfer uncertainty term (Default is false). Helpful when including inst without a defined scale transfer unc.")
#group.add_argument('--use_external', action="store_true", default=False, help="Use external calibration data")

group = parser.add_argument_group("Selection Options")
group.add_argument('--meas_lab_num', default=None, help="Select by measurement lab number in addition to scale/species, multiples set at 4,426 will be plotted separately")
#group.add_argument('--fit_inst', default=None, help="Base NOAA value on fitting one analyzer. --fit_inst=pc1")
#group.add_argument('--scale', help="Scale to use for reprocessing (default is current). For example --scale=CO_X2004")
#group.add_argument('-w', '--refgasfile', help="Choose a text reference gas file instead of database for assigned values.")
#group.add_argument('-r', '--respfile', help="Select a non-standard response file for reprocessing.")
#group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
#group.add_argument('--program', help="Path to non-standard version of calpro for reprocessing. For example --program=/home/ccg/.../.../test_version_calpro.py")
#group.add_argument('--extra_option', help="List of options to pass to calpro.py for reprocessing, separated by commas. For example --c13=*,--018=*,etc")

group = parser.add_argument_group("Output Options")
group.add_argument('--plot', action="store_true", default=False, help="Create a plot of external scale vs noaa scale. Default is False.")
group.add_argument('--plot_differences', action="store_true", default=False, help="Plot external_scale minus NOAA differences as functio of external scale. Default is False")
group.add_argument('--plot_residuals', action="store_true", default=False, help="Plot residuals from fit. Default is False")
group.add_argument('--plot_unc', action="store_true", default=False, help="Plot uncertainty of scale conversion. Default is False")
group.add_argument('--plot_curve_differences', action="store_true", default=False, help="Plot date range curve differences, requires two date ranges and only one fit type. Default is False")
group.add_argument('--hide_residual_unc', action="store_true", default=False, help="Supress error bars in residuals plot. Default is False")
group.add_argument('--plot_flag', default="Q", help="Flag to include in plots but not in the fit (default is Q for stds outside fit_range). For example --plot_flag=Q,S")
group.add_argument('--save_result', action="store_true", default=False, help="Pause and ask user for fit type to save to tempfile (default is False)")
group.add_argument('--fit_debug', action="store_true", default=False, help="Used to print debugging information on statistical testing used in auto fit routine (default is False)")
group.add_argument('--no_legend', action="store_true", default=False, help="Set to remove legend from plot")
#group.add_argument('--date_extension', default=0.2, help="Decimal years to extend plot past last calibration result (default is 0.2). For example --date_extension=1.5")
#group.add_argument('--min_date', default=None, help="Minimum date for plotting (default is cylinder fill date). For example --min_date=2020-01-01")
group.add_argument('--info', action="store_true", default=False, help="Print out input data and residuals.")
group.add_argument('--vertical_mark', default=None, help="Place vertical mark on plots - NOT YET")
group.add_argument('-u', '--update', action="store_true", default=False, help="Save fit parameters in scale assignment database table. Only one fit type can be used.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Print out extra information.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")

# required arguments
parser.add_argument('species', help="Specify species to value assign tank.")
parser.add_argument('external_scale', help="External scale to compare to NOAA")

options = parser.parse_args()


mainstart = datetime.datetime.now()


######### Setup

# DB connections
global db_utils
global db
global cal_db

database = options.database

db_utils = ccg_dbutils.dbUtils()
db = ccg_db_conn.RO(database)
#cal_db = ccg_cal_db.Calibrations()


SPECIES = options.species
if options.debug: print("sp: %s" % SPECIES, file=sys.stderr)
PARAMETER_NUM = db_utils.getGasNum(SPECIES)

# list of noaa primary stds that have assigned values rather than fit cal results
noaa_primary = ['AL47-110','AL47-102','AL47-111','AL47-130','AL47-121','AL47-139','AL47-105','AL47-136','AL47-146','AL47-101','AL47-106','AL47-123','AL47-107','AL47-132']
noaa_green_tanks = ['3080','3082','3074','3091','3071','3092','3087','3089']

# set moddate
if options.moddate:
    moddate = options.moddate
else:
    now = datetime.datetime.now()
    moddate = "%4d-%02d-%02d" % (int(now.year), int(now.month), int(now.day))

# get NOAA scale info 
rtn = db_utils.getCurrentScale(SPECIES)
noaa_scale = rtn["name"]
noaa_scale_num = rtn["idx"]
j, noaa_scale_version = noaa_scale.split('_')
if options.debug: print("NOAA_scale: %s      noaa_scale_num: %s    version: %s" % (noaa_scale, noaa_scale_num, noaa_scale_version), file=sys.stderr)

# set min NOAA uncertainty - used to prevent unreasonably low unc from Kirk's fitting code - *** MAY NOT NEED ANY MORE
# pass in 0.0 to prevent min value and use Kirk's values
min_noaa_unc = float(options.min_noaa_unc)

# set external scale
ext_scale = options.external_scale
ext_scale_num = db_utils.getScaleNum(ext_scale)
if not ext_scale_num: 
    sys.exit("External scale %s not found, exiting ...")
if options.debug: print("external scale: %s       external_scale_num: %s" % (ext_scale, ext_scale_num), file=sys.stderr)


# set range to include in fit - for now just remove values outside this range NEED TO CHANGE TO PLOT BUT NOT INCLUDE IN FIT
if options.fit_range:
    t1_mf, t2_mf = options.fit_range.split(',')
    min_mf = float(t1_mf)
    max_mf = float(t2_mf)
else:
    min_mf = -800.00
    max_mf =  9999.99

# flags to include in plot, these are flags in addition to '.'
plot_flag = ['.']
if options.plot_flag:
    plot_flag = plot_flag + options.plot_flag.split(',')

# set meas_lab_nums
if options.meas_lab_num:
    meas_lab_num = []
    tmp_lab_num = options.meas_lab_num.split(',')
    meas_lab_num = [int(str_num) for str_num in tmp_lab_num]
else:
    meas_lab_num = None

# save fit types requested
# only add entry for fit types that will be used
fit_types = {}
if options.auto_fit: fit_types['auto'] = True
if options.mean:           fit_types['mean'] = True
if options.linear:         fit_types['linear'] = True
if options.quadratic:      fit_types['quadratic'] = True
if not fit_types: print("****** ----------- NO FIT SPECIFIED")


### format noaa_fit_inst and noaa_fit_system
if options.noaa_fit_system:
    noaa_fit_systems = []
    for r in options.noaa_fit_system.split(','):
        noaa_fit_systems.append(r.lower())
else:
    noaa_fit_systems = None

if options.noaa_fit_inst:
    noaa_fit_inst = []
    for r in options.noaa_fit_inst.split(','):
        noaa_fit_inst.append(r.lower())
else:
    noaa_fit_inst = None

# format date ranges
# Pass in a list of date ranges to process. Use ':' to separate start:end dates and '/' to separate ranges. 
# For example --date_ranges=1990:1999/2004:2005/2021-01-01:2021-03-31/2022-01:2022-06
startdate = []
enddate = []
if options.date_ranges:
    for r in options.date_ranges.split('/'):
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
            d = "%s-%s-31" % (rr[0],int(rr[1]))        # need to change to use datetime plus time delta to find ends of month
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
cnt_date_range =-1 
for i, j in enumerate(startdate):
    print("date range:  %s - %s" % (startdate[i], enddate[i]))
    cnt_date_range += 1
    
    # pull data from external cal DB table
    ext_data = get_external_cals(SPECIES, PARAMETER_NUM, ext_scale_num, meas_lab_num, startdate[i], enddate[i], cnt_date_range, min_mf, max_mf)
   
    for dline in ext_data: 
        # Don't use noaa green_tanks for comparison
        if dline["serial_number"] in noaa_green_tanks: continue
        tmp = copy.deepcopy(dline)
        data.append(tmp)

#limit plot_curve_differences to only when date ranges >1 and when only one fit is specified
if options.plot_curve_differences: 
    if cnt_date_range < 1: options.plot_curve_differences = False
    if len(fit_types) < 1 or len(fit_types) > 2: options.plot_curve_differences = False   

# loop through data
for n, dline in enumerate(data):
    print("tank: %s    fill_code: %s   flag: %s   date_range: %s" % (dline["serial_number"], dline["fill_code"], dline["flag"], dline["date_range"]))

    # now get NOAA data for tank/fill/instruments 
    # for noaa primary stds use assigned value, for others use autofit results from cal history
    if dline["serial_number"] in noaa_primary:

        cmd = '/ccg/bin/get_standard_value.py --scale=%s ' % (noaa_scale)
        cmd = "%s  -d %s  --sp=%s %s" % (cmd, dline["date"], SPECIES, dline["serial_number"])
        #print("Getting noaa value:  %s" % cmd)
        result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)

        rr = result.stdout.decode('utf-8')
        rr = rr.rstrip("\t\n")
        if len(rr) == 0:  
            val = -999.99

        (val, unc) = rr.split()
        #print(dline["serial_number"], dline["dd"],  val, unc)
        data[n]["noaa_value"] = float(val)
        data[n]["noaa_unc"] = float(unc)
        data[n]["diff"] = data[n]["ext_value"] - data[n]["noaa_value"]
        data[n]["diff_unc"] = math.sqrt(data[n]["ext_unc"]**2 + data[n]["noaa_unc"]**2)
        

        #for key in dline.keys():
        #    print("key: %s   val: %s" % (key, dline[key]))
        #sys.exit("clean exit") 
    else:
        cals = ccg_cal_db.Calibrations(tank = dline["serial_number"],
                                      gas = SPECIES,
                                      #syslist = options.inst,
                                      fillingcode = dline["fill_code"],
                                      date = None,
                                      method = None,
                                      #official = options.official,
                                      official = True,
                                      #uncfile = options.uncfile,
                                      notes = True,
                                      database = database)

        # run each tank through caldrift.py to get auto assigned value  *********** need to remove flagged data
        fitdata = []
        for ddline in cals.cals:
            #print("returned data:  ", ddline)
            include_check = True
            if ddline["flag"] not in options.include_flag: include_check = False
            if noaa_fit_systems:
                if ddline["system"].lower() not in noaa_fit_systems: include_check = False
            if noaa_fit_inst:
                if ddline["inst"].lower() not in noaa_fit_inst: include_check = False

            if include_check: fitdata.append(ddline)

        #print("\n\n*************** included noaa data")
        #for ddline in fitdata:
        #    print(ddline)
        #sys.exit("clean exit")

        fit = ccg_calfit.fitCalibrations(fitdata)
        (cval, cci, cunc) = calc_value(dline['dd'], fit)
        #print(cval, cunc)
        data[n]["noaa_value"] = cval
        data[n]["noaa_unc"] = max(cunc, min_noaa_unc)
        print("*** %s   ci: %8.4f  cunc: %8.4f  min_unc: %8.4f  -- use %8.4f" % (dline["serial_number"], cci, cunc, min_noaa_unc, data[n]["noaa_unc"]))
        data[n]["diff"] = data[n]["ext_value"] - data[n]["noaa_value"]
        data[n]["diff_unc"] = math.sqrt(data[n]["ext_unc"]**2 + data[n]["noaa_unc"]**2)

# allow user to select sn to use (by deleting from text file)  #######NOT YET
for dline in data:
    print("date_range: %d  %15s   NOAA: %12.3f (%12.3f)   External: %12.3f (%12.3f)   diff: %12.3f  ( %12.3f)" % (dline["date_range"], 
            dline["serial_number"], dline["noaa_value"], dline["noaa_unc"], dline["ext_value"], dline["ext_unc"], dline["diff"], dline["diff_unc"]))


# allow user to offline edit the data before fitting
#------------------------------------------------------------
if options.edit:

    newdata = edit_cals(SPECIES, data, tempfile)
    if newdata:
        final_data = newdata
        #final_data = copy.deepcopy(newdata)
    else:
        #final_data = data
        final_data = data

else:
    final_data = data

# remove 9'd out data
final_data = [cal for cal in final_data if (cal['ext_value'] > -800 and cal['noaa_value'] > -800)]



#final_data = copy.deepcopy(data)



#for key in final_data[0].keys(): print("key: %s   %s    type: %s" % (key, final_data[0]["%s" % key], type(final_data[0]["%s" % key])))

# create a dataframe from the final_data
#------------------------------------------------------------
if options.debug:
    print("length of final data", len(final_data))
if len(final_data) == 0:
    print("No data available.")
    sys.exit("no data")
    #continue

df = pd.DataFrame(final_data)
fit_results = []

# loop through date ranges - fit scale relationships for each meas_lab_num separately
#begin meas_lab loop
if not meas_lab_num: meas_lab_num=[0]  # if not set, assign 0 to indicate all

for nn, lab_num in enumerate(meas_lab_num):
    #begin startdate loop
    for n, sd in enumerate(startdate):
        #print("n: %s" % n)
        label = "%s: %s - %s" % (lab_num, startdate[n], enddate[n])
        print("working on fit for %s" % label)
        # get data for date_range
        if lab_num != 0:
            df2 = df[(df['meas_lab_num'] == lab_num) & (df['flag'] == '.') & (df['ext_value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
        else: 
            df2 = df[(df['flag'] == '.') & (df['ext_value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
        tmp_dict = df2.to_dict('records')

        # test for no data
        if len(tmp_dict) == 0: continue
        #print("type tmp_dict: %s" % type(tmp_dict))
        #print("len tmp_dict: %s" % len(tmp_dict))
        #for key in tmp_dict[0].keys(): print ("tmp_dict key: %s" % key)
        #sys.exit()

        for fit_type in fit_types:
            tmp_fit_results = {}

            print("************************************\n%s fit of selected data" % fit_type)
            print("Minimum NOAA unc set to %8.4f" % min_noaa_unc)
            print("************************************\n")
            
            if options.fit_differences:
                fit = fitScales(df2.to_dict('records'), degree=fit_type, debug=options.fit_debug)
            else:
                #fit = ............ odr fit of values
                fit, covar = odr_fitScales(df2.to_dict('records'), degree=fit_type, debug=options.fit_debug)
             
            if options.verbose:
                #print("Serial Number: %s" % tank_serial_number)
                #print("Fill Code:     %s" % fill_code)
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
                if not options.fit_differences:
                    print("Covar:  %s" % covar)
             
            else:
                print("-----\n %s - %s: " % (label, fit_type))
                print(fit)
                print("-----\n")

            tmp_fit_results["meas_lab_num"] = lab_num
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
            if options.fit_differences:
                #hardcode cov=0 for now
                tmp_fit_results["covar"] = [0.0]
            else:
                tmp_fit_results["covar"] = covar
            #tmp_fit[""] = 
            fit_results.append(copy.deepcopy(tmp_fit_results))
            
            # get residuals from fit
            for nnn, dline in enumerate(final_data):
                if dline["date_range"] != n: continue
                #print(fit)
                (cval, ci, unc) = calc_value(dline['ext_value'], fit)
                if options.fit_differences:
                    resid = dline["diff"] - cval
                else:
                    resid = dline["noaa_value"] - cval
                key = fit_type + "_residual"
                final_data[nnn][key] = resid
#end startdate loop

#end meas_lab_num loop


# print fit results
print("---------")
print("---------")
print("%s vs %s" % (ext_scale, noaa_scale))
#print(type(fit_results))
for ft in fit_results:
    print("---------")
    if options.fit_differences:
        msg = "Fit_differences: lab_num %s  date_range %s - %s" % (ft["meas_lab_num"], startdate[ft["date_range"]], enddate[ft["date_range"]])
        msg += " (%s):" % ft["fit_type"]
        msg += "[%s-WMO_%s] = %12.6f (%12.6f)" % (ext_scale, noaa_scale_version, ft["coef0"], ft["unc_c0"]) 
        if ft["coef1"] != 0.0: msg += " + %12.6f (%12.6f) * [%s - %15.6f]" % (ft["coef1"], ft["unc_c1"], ext_scale, ft["time_zero"]) 
        if ft["coef2"] != 0.0: msg += " + %12.6f (%12.6f) * [%s - %15.6f]^2" % (ft["coef2"], ft["unc_c2"], ext_scale, ft["time_zero"]) 
        msg += " (wt_mean: %15.6f)    (sdresid: %12.6f   reduced chisquare: %12.6f n: %d)" % (ft["time_zero"],ft["sd_resid"], ft["chisq"], ft["n"])  
    else:
        msg = "ODR: lab_num %s  date_range %s - %s" % (ft["meas_lab_num"], startdate[ft["date_range"]], enddate[ft["date_range"]])
        msg += " (%s):" % ft["fit_type"]
        msg += "[WMO_%s] = %12.6f (%12.6f)" % (noaa_scale_version, ft["coef0"], ft["unc_c0"]) 
        if ft["coef1"] != 0.0: msg += " + %12.6f (%12.6f) * [%s]" % (ft["coef1"], ft["unc_c1"], ext_scale) 
        if ft["coef2"] != 0.0: msg += " + %12.6f (%12.6f) * [%s]^2" % (ft["coef2"], ft["unc_c2"], ext_scale) 
        msg += " (sd_resid = %-8.3f)" % ft["sd_resid"]
    print("%s" % msg)
    #if not options.fit_differences:
    #    print('covar: \n', ft["covar"])
    #print("---------")
    
        


# new df now includes residuals
df = pd.DataFrame(final_data)

# get range from all good data
df_all = df[(df['flag'].isin(plot_flag)) & (df['ext_value'] > -800) & (df["noaa_value"] > -800) ]

# get date range for plotting curves
step = 200
min_value = min(df_all['ext_value']) * 0.95
max_value = max(df_all['ext_value']) * 1.05
interval = (max_value - min_value) / step
line_x = [n * interval + (min_value) for n in range(step)]



### plots
#  scale vs scale - 1:1 line and fit line
#  differences vs noaa scale and residuals to fit
   # #find number of plots
   # num_plots = 0
   # if options.plot: num_plots+=1 
   # if options.plot_residuals: num_plots+=1 
   # if options.plot_differences: num_plots+=1 
   # if options.plot_curve_differences: num_plots+=1 
    

num_plots = 0
if options.plot: num_plots += 1
if options.plot_differences: num_plots += 1
if options.plot_residuals: num_plots +=1
if options.plot_curve_differences: num_plots +=1
if options.plot_unc: 
    if not options.plot_residuals and not options.plot_curve_differences:
        num_plots +=1
#if options.plot_unc: num_plots +=1

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
    if num_plots == 4:
        fig_height = 8.5
        fig_width = 7.5
    elif num_plots == 3:
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
        #scale_plot = axs[current_plot] if options.plot_residuals or options.plot_differences or options.plot_curve_differences else axs
        scale_plot = axs[current_plot] if num_plots > 1 else axs
        current_plot += 1
    else:
        scale_plot = None

    if options.plot_residuals or (options.plot_unc and not options.plot_curve_differences):
        #residual_plot = axs[current_plot] if options.plot or options.plot_differences or options.plot_curve_differences else axs
        residual_plot = axs[current_plot] if num_plots > 1 else axs
        current_plot += 1
    else:
        residual_plot = None

    if options.plot_differences:
        #difference_plot = axs[current_plot] if options.plot_residuals or options.plot or options.plot_curve_differences else axs
        difference_plot = axs[current_plot] if num_plots > 1 else axs
        current_plot += 1
    else:
        difference_plot = None

    if options.plot_curve_differences:
        #curve_difference_plot = axs[current_plot] if options.plot_residuals or options.plot or options.plot_differences else axs
        curve_difference_plot = axs[current_plot] if num_plots > 1 else axs
    else:
        curve_difference_plot = None

    #label axis
    xlabel = "%s %s\n(%s)" % (gas_formula, gas_units, ext_scale)
    title = '%s: %s vs WMO-%s' % (gas_formula, ext_scale, noaa_scale_version)
    if scale_plot:
        scale_plot.set_title(title)
        ylabel = "%s %s\n(WMO-%s)" % (gas_formula, gas_units, noaa_scale_version) 
        scale_plot.set_ylabel('%s' % (ylabel))
        if difference_plot is None and residual_plot is None: scale_plot.set_xlabel("%s" % (xlabel))

    if residual_plot:
        if scale_plot is None: residual_plot.set_title(title)
        ylabel = "%s Residuals\n%s" % (gas_formula, gas_units)
        residual_plot.set_ylabel(ylabel)
        if difference_plot is None: residual_plot.set_xlabel("%s" % (xlabel))

    if difference_plot:
        if scale_plot is None and residual_plot is None: difference_plot.set_title(title)
        ylabel = "$\Delta$ %s %s\n(%s - WMO-%s)" % (gas_formula, gas_units, ext_scale, noaa_scale_version)
        difference_plot.set_ylabel(ylabel)
        difference_plot.set_xlabel("%s" % (xlabel))

    if curve_difference_plot:
        if scale_plot is None and residual_plot is None: curve_difference_plot.set_title(title)
        ylabel = "$\Delta$ %s %s\n(%s - WMO-%s)" % (gas_formula, gas_units, ext_scale, noaa_scale_version)
        curve_difference_plot.set_ylabel(ylabel)
        curve_difference_plot.set_xlabel("%s" % (xlabel))

    # plot 1:1 line in scale plot
    line_y = []
    for x in line_x:
        line_y.append(x)
    if scale_plot: scale_plot.plot(line_x, line_y, linestyle='solid', color='black')

    # plot 0:0 line in difference and residual plots
    line_y = []
    for x in line_x:
        line_y.append(0.0)
    if difference_plot: difference_plot.plot(line_x, line_y, linestyle='solid', color='black')
    if residual_plot: residual_plot.plot(line_x, line_y, linestyle='solid', color='black')
    if curve_difference_plot: curve_difference_plot.plot(line_x, line_y, linestyle='solid', color='black')

    #Begin loop through meas_lab_num
    for nn, lab_num in enumerate(meas_lab_num):
        # Begin loop through date ranges
        for n, sd in enumerate(startdate):
            #print("n: %s" % n)
            #print("working on %s" % label)

            # get data for date_range
            if lab_num != 0: 
                label = "lab %s, %s - %s" % (lab_num, startdate[n], enddate[n])
                df2 = df[(df['meas_lab_num'] == lab_num) &  (df['flag'] == '.') & (df['ext_value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
                df3 = df[(df['meas_lab_num'] == lab_num) &  (df['flag'] != '.') & (df['flag'].isin(plot_flag)) & (df['ext_value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
            else:
                label = "%s - %s" % (startdate[n], enddate[n])
                df2 = df[(df['flag'] == '.') & (df['ext_value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
                df3 = df[(df['flag'] != '.') & (df['flag'].isin(plot_flag)) & (df['ext_value'] > -800) & (df["noaa_value"] > -800) & (df["date_range"] == n) ]
            
            #tmp_dict2 = df2.to_dict('records')
            #print("len(tmp_dict): %s" % (len(tmp_dict)))
            #if len(tmp_dict) == 0: continue
           

            # plot each inst in diffent color/symbol, close sym if in fit, open if not in fit
            if not df2.empty:
                if scale_plot:
                    scale_plot.errorbar(df2['ext_value'], df2['noaa_value'], yerr=df2['noaa_unc'], xerr=df2['ext_unc'], color=col_arr[n],
                          marker=sym_arr[nn], linestyle='none', fillstyle='full', label=label )
                if difference_plot:
                    difference_plot.errorbar(df2['ext_value'], df2['diff'], yerr=df2['diff_unc'], color=col_arr[n],
                          marker=sym_arr[nn], linestyle='none', fillstyle='full', label=label )

            if not df3.empty:
                if scale_plot:
                    scale_plot.errorbar(df3['ext_value'], df3['noaa_value'], yerr=df3['noaa_unc'], xerr=df3['ext_unc'], color=col_arr[n],
                          marker=sym_arr[nn], linestyle='none', fillstyle='none', label=label )
                if difference_plot:
                    difference_plot.errorbar(df3['ext_value'], df3['diff'], yerr=df3['diff_unc'], color=col_arr[n],
                          marker=sym_arr[nn], linestyle='none', fillstyle='none', label=label )

           
            # plot line for fits (either in scale plot or difference plot) 
            for ft in fit_results:
                print("lab_num: %s" % lab_num)
                print(ft)
                if ft["date_range"] != n or ft["meas_lab_num"] != lab_num: continue
                print("passed")
                #print("coef0: %15.8f   coef1: %15.8f   coef2: %15.8f" % (ft["coef0"], ft["coef1"], ft["coef2"]))
                line_y = []
                for x in line_x:
                    dx = x-ft["time_zero"]
                    y = ft["coef0"] + ft["coef1"]*dx + ft["coef2"]*dx*dx
                    line_y.append(y)
                if options.fit_differences and difference_plot:
                    difference_plot.plot(line_x, line_y, linestyle=linestyle_arr[nn], color=col_arr[n], label='%s %s' % (label,ft["fit_type"]))
                elif scale_plot:
                    scale_plot.plot(line_x, line_y, linestyle=linestyle_arr[nn], color=col_arr[n], label='%s %s' % (label,ft["fit_type"]))
                else:
                    pass     

            # plot line for curve fit difference ###################
            for tmp_ft in fit_results:
                if tmp_ft["date_range"] == 0: 
                    first_fit = tmp_ft
            
            for ft in fit_results:
                if ft["date_range"] != n: continue
                #print("coef0: %15.8f   coef1: %15.8f   coef2: %15.8f" % (ft["coef0"], ft["coef1"], ft["coef2"]))
                line_y = []
                for x in line_x:
                    dx0 = x-first_fit["time_zero"]
                    y0 = first_fit["coef0"] + first_fit["coef1"]*dx0 + first_fit["coef2"]*dx0*dx0
                    dx = x-ft["time_zero"]
                    y = ft["coef0"] + ft["coef1"]*dx + ft["coef2"]*dx*dx
                    line_y.append(y-y0)
                if curve_difference_plot:
                    curve_difference_plot.plot(line_x, line_y, linewidth=2.0, linestyle=linestyle_arr[nn], color=col_arr[n], label='%s %s' % (label,ft["fit_type"]))
                else:
                    pass     

            # plot residuals 
            if residual_plot and options.plot_residuals:
                for nnn, fit_type in enumerate(fit_types):
                    key = fit_type + "_residual"
                    if options.hide_residual_unc:
                        if not df2.empty:
                            residual_plot.plot(df2['ext_value'], df2[key], color=col_arr[n],
                                          marker=sym_arr[nnn], linestyle='none', fillstyle='full', label="%s %s" % (label, fit_type) )
                        if not df3.empty:
                            residual_plot.plot(df3['ext_value'], df3[key], color=col_arr[n],
                                          marker=sym_arr[nnn], linestyle='none', fillstyle='none', label="%s %s not included" % (label, fit_type) )
                    else:
                        if not df2.empty:
                            residual_plot.errorbar(df2['ext_value'], df2[key], yerr=df2["diff_unc"], color=col_arr[n],
                                          marker=sym_arr[nnn], linestyle='none', fillstyle='full', label="%s %s" % (label, fit_type) )
                        if not df3.empty:
                            residual_plot.errorbar(df3['ext_value'], df3[key], yerr=df3["diff_unc"], color=col_arr[n],
                                          marker=sym_arr[nnn], linestyle='none', fillstyle='none', label="%s %s not included" % (label, fit_type) )

            ##########    
            # plot uncertainty on the residual plot
            if options.plot_unc and residual_plot: 
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

            ##########    
            # plot uncertainty on the curve_diffference plot
            if options.plot_unc and curve_difference_plot:
                for ft in fit_results:
                    if ft["date_range"] != n: continue

                    line_y = []
                    line_y_neg = []
                    for x in line_x:
                        cunc = calc_fit_unc(x, ft)
                        #print(x, cunc)
                        line_y.append(cunc) 
                        line_y_neg.append(-1.0*cunc) 
                    curve_difference_plot.plot(line_x, line_y, linestyle='dotted', color=col_arr[n], label='%s %s unc (1-sigma)' % (label, ft["fit_type"]))
                    curve_difference_plot.plot(line_x, line_y_neg, linestyle='dotted', color=col_arr[n], label='%s %s unc (1-sigma)' % (label, ft["fit_type"]))

        #end loop through date_ranges
    #end loop through meas_lab_num

    if not options.no_legend:    
        if scale_plot:
            scale_plot.legend()
        elif difference_plot:
            difference_plot.legend()
        elif residual_plot:
            residual_plot.legend()


mainend = datetime.datetime.now()
dt = mainend - mainstart
print("main cycle time: %s" % dt)

plt.show()



# Plot external scale vs NOAA scale
# fit line and compare to 1:1 and residuals





