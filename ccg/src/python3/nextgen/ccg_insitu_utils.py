
# vim: tabstop=4 shiftwidth=4 expandtab
"""
# Routines needed for calculating mole fractions for in-situ data
#
"""
from __future__ import print_function

import os
import sys
import datetime
import math
import configparser
from collections import namedtuple
import numpy
from scipy.odr import odrpack as odr
from scipy.odr import models
from scipy import interpolate

import ccg_utils
import ccg_instrument

DEFAULTVAL = -999.99

#########################################################################
def find_nearest(array, value, axis=None):
    """ Find index in array whose value is closest to the given value."""

    if axis is None:
        idx = (numpy.abs(array-value)).argmin()
    else:
        idx = (numpy.abs(array-value)).argmin(axis=axis)

    return idx #  , array[idx]



#--------------------------------------------------------------------------
def resultTuple():
    """ Create a namedtuple to hold mole fraction results.

    This tuple is used for all calculation methods, so it's set here to be
    defined in one place only.
    """

    return namedtuple('result', ['stacode', 'date', 'mf', 'stdv', 'unc', 'ref_unc', 'n', 'flag', 'sample', 'comment'])



#--------------------------------------------------------------------------
def get_config(sta, gas, inst, section=None, cfgfile=None):
    """ Read in the configuration file, and return the 'QC' section """

    if cfgfile is None:
        configfile = "/ccg/%s/in-situ/%s/%s/config.ini" % (gas.lower(), sta.lower(), inst.lower())
#        if gas == "co2":
#            configfile = "%s_co2_config.ini" % sta
#        elif gas == "ch4":
#            configfile = "%s_ch4_config.ini" % sta
    else:
        configfile = cfgfile

    print("configfile is", configfile)

    if not os.path.exists(configfile):
        sys.exit("Configuration file not found: %s" % configfile)

    cfg = configparser.ConfigParser()
    cfg.read(configfile)

    if section:
        return cfg[section]

    return cfg


#--------------------------------------------------------------------------
def calc_unc(row, avgref, sigma_ref, coef, rsd, use_subtract=False):
    """ Calculate uncertainty for response curve  measurement
    Use propogation of error to calculate uncertainty.

    if f(x) = a + bx + cx^2, then sigmaf(x) = f'(x) * sigmax
    which is (b + 2cx) * sigmax

    where x is either sample-reference or sample/reference

    """

#    print(row, avgref, sigma_ref, coef)

    if avgref == DEFAULTVAL:
        return -99.99, DEFAULTVAL

    err = -99.99
    err2 = DEFAULTVAL
    if row.value:
        if use_subtract:
            diff = row.value - avgref
            sigma_diff = math.sqrt(row.stdv*row.stdv + sigma_ref*sigma_ref)
            # to get instrument noise, use sigma_ref in place of value std,
            # to remove atmospheric variability
            sr = sigma_ref/math.sqrt(2)   # sigma_ref is always 0 for towers because only 1 30 second data point is used, so sigma of voltage is 0
            sigma_inst = math.sqrt(sr*sr + sr*sr)
        else:
            diff = row.value / avgref
            sigma_diff = math.sqrt(row.stdv**2/row.value**2 + sigma_ref**2/avgref**2)
            sigma_diff = diff * sigma_diff
            sr = sigma_ref/math.sqrt(2)
            sigma_inst = math.sqrt(sr**2/row.value**2 + sr**2/avgref**2)
            sigma_inst = diff * sigma_inst

        # need to change this to handle n coeffs
        s = 0
        for i in range(1, len(coef)):
            s += i * coef[i] * diff**(i-1)

        err = s * sigma_diff
        err2 = s * sigma_inst

#        err = (coef[1] + 2*coef[2]*diff) * sigma_diff
#        err2 = (coef[1] + 2*coef[2]*diff) * sigma_inst

        if err < 0: err = -99.99
        if err2 < 0: err2 = DEFAULTVAL
        if err > 999.99: err = -99.99
        if err2 > 999.99: err2 = DEFAULTVAL

        if err2 > 0:
            err2 = math.sqrt(err2**2 + rsd**2)

    return err, err2



#--------------------------------------------------------------------------
def get_resp_mixing_ratio(val, avgstd, coef, smpflag, refflag, ref_op, debug=False):
    """
    mole fraction is calculated from response curve coefficients
    mf = c0 + c1*x + c2*x*x

    where x is sample-std difference (or sample/std ratio if use_subtract is False).

    Also set the first character of the flag if the mole fraction value is nonsense.

    Input:
        val : analyzer sample value
        avgstd : analyzer reference value
        coef : response coefficients (molefraction vs difference from reference)
        smpflag : sample flag
        refflag : reference flag
        use_subtract : If True, use difference from reference, else use ratio
        debug : print debug info if True

    Returns:
        value : computed mole fraction value
        flag : associated flag for mole fraction value
    """

    # refflag comes from analyzer response, and is something
    # like '.' or '..>', '..<'.  Make sure it's 3 characters
    if len(refflag) == 1:
        refflag = refflag + '..'

    flag = smpflag + refflag[1:]

    if avgstd not in [0, DEFAULTVAL]:
#        if use_subtract:
        if ref_op == 'subtract':
            rr = val-avgstd
#        else:
        elif ref_op == 'divide':
            rr = val/avgstd
        else:
            rr = val
        value = ccg_utils.poly(rr, coef)
    else:
        rr = -1
        value = DEFAULTVAL

    if debug:
        print("Sample value = ", val)
        print("reference value = ", avgstd)
#        if use_subtract:
        if ref_op == 'subtract':
            print("Difference = ", rr)
        else:
            print("Ratio = ", rr)

        print("Coef = ", coef)
        print("MF = %f" % (value))


    # Sanity check on mole fraction
    if value <= 0 or value > 9999.99:
        value = DEFAULTVAL
        flag = "*" + refflag[1:]
        if debug:
            print("value out of range, setting to default.")

    return value, flag

#--------------------------------------------------------------------------
def odr_fitxxx(fit_degree, x, y, xsd, ysd, debug=False):
    """ Run an odr fit to the data x, y with weights xsd, ysd """

    # set up odr fit, give it plenty of iterations and an initial estimate of the coefficients
    func = models.polynomial(fit_degree)
    beta0 = numpy.polyfit(x, y, fit_degree)   # initial guess at coefficients
    beta0 = beta0[::-1] # reverse the order of coefficients for input into odr
    mydata = odr.RealData(x, y, xsd, ysd)
    myodr = odr.ODR(mydata, func, beta0=beta0, maxit=1000)
    myodr.set_job(0)
    if debug:
        myodr.set_iprint(init=2, iter=2, final=2)
    fit = myodr.run()

    resid = numpy.polyval(fit.beta[::-1], x) - numpy.array(y)
    rsd = numpy.std(resid, ddof=2)

    return fit, rsd

#--------------------------------------------------------------------------
def baseline_unc(raw, reference_label):
    """ calculate baseline drift uncertainty. """

    # get times for all samples
    t2 = numpy.array([t.timestamp() for t in raw.date])
    nt = len(t2)

    # find all reference (C2) values
    df = raw[(raw.label == reference_label) & (raw.flag == ".") & (raw.value > -1e10)]
    y = df.value.values
    x = numpy.array([t.timestamp() for t in df.date])

    n = len(x)

    mref = numpy.empty((n, nt))
    base_unc = numpy.zeros((nt))
#    return base_unc

    # if no valid data, return 0's for unc
    if n == 0:
        return base_unc

    # create n interpolations by removing one reference in sequence
    # don't extrapolate, set to nan
    b = numpy.arange(0, n, 1)
    for i in range(n):
        w = numpy.where(b != i)
        if w[0].size >= 2:
            f = interpolate.interp1d(x[w], y[w], bounds_error=False) # , fill_value='extrapolate')
            mref[i] = f(t2)

#        print(mref[i])
#        print(t2)

    # for each data point, get unique interpolation values,
    # then calculate the standard deviation of them.
    # scale the uncertainty according to the relative distance to other ref measurements
    for i in range(nt):
        # get non-nan values
        w = numpy.isfinite(mref.T[i])
        b = numpy.unique(mref.T[i][w])
        if b.size > 1:
            stddev = numpy.std(b, ddof=1)
        else:
            stddev = 0


        # time difference of this data point from all references,
        # in order of largest positive value to largest negative value
        dtime = t2[i] - x

        # closest ref measurement in time
        closest = numpy.min(numpy.abs(dtime))

        # get smallest positive time difference
        w = numpy.where(dtime > 0)
        if w[0].size == 0:
            distance = dtime[0]
        else:
            # index of smallest positive value
            iprev = numpy.argmax(w)
            inext = iprev + 1   # index of smallest negative value
            if inext < n:
                distance = dtime[iprev] - dtime[inext]
            else:
                distance = dtime[iprev]


        # use a time limit, references must be within a time distance to be used
        if distance < 10080 and distance != 0 and not numpy.isnan(stddev):
            unc_ref_freq = stddev * 2.0 * abs(closest) / abs(distance)
        else:
            unc_ref_freq = 0


        # uncertainty lower limit is the measurement standard deviation
#            ref_std = raw.ref_unc.iloc[i]
#            if unc_ref_freq < ref_std:
#                base_unc[i] = ref_std
#            else:
#                base_unc[i] = unc_ref_freq

        base_unc[i] = unc_ref_freq


    return base_unc

#--------------------------------------------------------------------------
def calc_mf(row, resp, use_subtract, fit_degree, debug=False):
    """ Calculate mole fraction and uncertainties.

    This is for calibration methods that use a response curve relative to a reference tank.

    Args:
        row : One row (as a tuple) from an insitu raw dataframe
        resp : dict with entries for coeffs, flag, covar, rsd
        use_subtract : How to determine relation to reference, either subtract (True) or ratio (False)
        fit_degree : Degree of polynomial fit

    Returns:
        mf : calculated mole fraction
        std : Standard deviation of mf
        meas_unc : measurement uncertainty
        random_unc : random uncertainty, basically noise of reference in mole fraction units
        flag : three character flag associated with mf
    """

#    print("************** ref_flag", row.ref_flag)

    # calculate mole fraction
    if row.ref_flag == 0:
        mf, flag = get_resp_mixing_ratio(
            row.value,
            row.reference,
            resp['coeffs'],
            row.flag,
            resp['flag'],
            resp['ref_op'],
    #        use_subtract,
            debug
        )
    else:
        mf = DEFAULTVAL
        flag = "*.."

    if mf == DEFAULTVAL:
        std = DEFAULTVAL
        meas_unc = DEFAULTVAL
        random_unc = DEFAULTVAL

    else:

        # value that goes into polynomial
    #    if use_subtract:
        if resp['ref_op'] == 'subtract':
            x = row.value - row.reference
        elif resp['ref_op'] == 'divide':
            x = row.value / row.reference
        else:
            x = row.value

        # propagation of error, sigma of difference or ratio
    #    if use_subtract:
        if resp['ref_op'] == 'subtract':
            sigma_x = math.sqrt(row.stdv*row.stdv + row.ref_unc*row.ref_unc)
        elif resp['ref_op'] == 'divide':
            if row.value != 0:
                sigma_x = x * math.sqrt(row.stdv**2/row.value**2 + row.ref_unc**2/row.reference**2)
            else:
                sigma_x = DEFAULTVAL
        else:
            sigma_x = row.stdv

        # propagation of error, partial derivative of poly with respect to x
        s = ccg_utils.polyderiv(x, resp['coeffs'])

#        print('x is', x, 'std is', row.stdv, "s is", s, 'sigma_x is', sigma_x)

        # convert sigmas in analyzer units to mole fractions
        std = s * sigma_x
    #    if use_subtract:
        if resp['ref_op'] == 'subtract':
            base_unc = s * row.baseline_unc
            random_unc = s * row.ref_unc
        elif resp['ref_op'] == 'divide':
            base_unc = s * row.baseline_unc / row.reference
            random_unc = s * row.ref_unc / row.reference
        else:
            base_unc = s * row.baseline_unc
            random_unc = s * row.ref_unc
#        print('x is', x, 'std is', std, "base_unc is", base_unc, 'random_unc is', random_unc)

        # -------- calculate measurement uncertainty from fit covariance
#        print(x, resp)
        unc = ccg_utils.odr_fit_unc(fit_degree, x, resp['covar'], resp['rsd'])
#        print("unc from odr fit is", unc)
        meas_unc = math.sqrt(unc*unc + base_unc*base_unc)

        # we need to check on the values because it's possible to get out of range errors
        # in sql when updating
        if meas_unc > 999.99 or meas_unc < 0:
            meas_unc = DEFAULTVAL
        if random_unc > 999.99 or random_unc < 0:
            random_unc = DEFAULTVAL
        if std > 999.99 or std < 0:
            std = DEFAULTVAL

    return mf, std, meas_unc, random_unc, flag

#--------------------------------------------------------------------------
def calc_mf_ndir(row, resp, fit_degree, debug=False):
    """ Calculate mole fraction and uncertainties.

    This is for calibration methods that don't use a reference tank.

    Args:
        row : One row (as a tuple) from an insitu raw dataframe
        resp : dict with entries for coeffs, flag, covar, rsd
        fit_degree : Degree of polynomial fit

    Returns:
        mf : calculated mole fraction
        std : Standard deviation of mf
        meas_unc : measurement uncertainty
        random_unc : random uncertainty, basically noise of reference in mole fraction units
        flag : three character flag associated with mf
    """

    x = row.value

    # calculate mole fraction
    mf = ccg_utils.poly(x, resp['coeffs'])

    # Sanity check on mole fraction
    if mf <= 0 or mf > 9999.99:
        mf = DEFAULTVAL
        std = -9.99
        meas_unc = -9.99
        random_unc = -9.99
        flag = "I" + resp['flag'][1:]
        if debug:
            print(row.date, "value out of range, setting to default.")

        return mf, std, meas_unc, random_unc, flag


    if row.flag == '*':
        flag = '..*'
    else:
        flag = row.flag + resp['flag'][1:]


    # propagation of error, partial derivative of poly with respect to x
    s = ccg_utils.polyderiv(x, resp['coeffs'])

    # convert sigmas in analyzer units to mole fractions

    random_unc = s * resp['ref_stdv']
    if random_unc < 0:
        random_unc = -9.99

    std = s * row.stdv
    if std < 0:
        std = -9.99

    # -------- calculate measurement uncertainty from fit covariance
    meas_unc = ccg_utils.odr_fit_unc(fit_degree, x, resp['covar'], resp['rsd'])
    if meas_unc <= 0:
        meas_unc = -9.99

#    print('x is', x, 'unc is', unc, 'std is', std, 'random_unc is', random_unc)

    return mf, std, meas_unc, random_unc, flag


#--------------------------------------------------------------------------
def change_dates(stacode, gas, system, tank_labels, refgas, startdate, enddate, config=None):
    """ Determine when dates change due to reference tank changes, instrument changes.  
        Processing of raw data needs to be broken up into blocks based on these dates.

    Args:
        stacode : three letter station code
        gas : gas formula
        system : system name
        tank_labels : single string or list of tank labels, e.g. [W1, W2, W3] or 'R0'
        refgas : refgasDb class object
        startdate : starting date, datetime object
        enddate : ending date, datetime object

    Returns:
        dates : sorted list of dates when something changes, between startdate and enddate
    """

    dates = [startdate]

    if isinstance(tank_labels, str):
        tank_labels = [tank_labels]

    # determine when working tank changes
    if tank_labels is not None:
        for label in tank_labels:
            rows = refgas.getEntries(label)
            if len(rows) > 0:
                for r in rows:
                    if r.start_date > startdate and r.start_date < enddate:
                        dates.append(r.start_date)

    # check if forced breaks are set
    if config is not None:
        breaks = config.get_rules('break')
        if len(breaks) > 0:
            for row in breaks:
                dates.append(row.sdate)

    # any instrument changes between startdate and enddate?
    instruments = ccg_instrument.instrument(stacode, gas, system)
    for inst in instruments.inst_list:
        if startdate < inst['start_date'] < enddate:
            dates.append(inst['start_date'])

    # add a day to end date so we can use < in compute()
    edate = enddate + datetime.timedelta(days=1)
    dates.append(edate)

    # return unique dates
    return sorted(list(set(dates)))

