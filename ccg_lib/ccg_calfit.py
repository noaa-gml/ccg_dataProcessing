# vim: tabstop=4 shiftwidth=4 expandtab
"""
Procedures to calculate a drift corrected mole fraction value for cylinders.

fitCalibrations() takes a list of cal results from ccg_cal_db.py
and iteratively fits a weighted quadratic, linear, mean curve to the
data, stopping when the highest degree coefficient is significant.

Significance is made by comparing calculated t value of the coefficient
with the t value from a two-tailed t distribution for 95% confidence and
with the appropriate degrees of freedom.

For a coefficient b,

H0: b = 0
Ha: b != 0

t* = b/s(b)

if |t*| <= t(1-a/2; df), conclude H0
if |t*| > t(1-a/2; df), conclude Ha

See for example, equation 3.17,
'Applied Linear Regression Models',
Needer, Wasserman and Kutner 1983

Usual way to use this function is through ccg_cal_db.getValue():

    import ccg_cal_db
    dt = datetime.datetime(2005, 1, 1)
    c = ccg_cal_db.Calibrations("CC71623", "CO2")
    fillcode = c.getFillCode(dt)
    t = c.getValue("co2", fillcode)


It returns a namedtuple that can be used to populate the scale_assignments
database table.  To do this, use the method

    ccg_refgasdb.insertFromFit(serialnum, date, t, level=level, comment=comment)

where t is the namedtuple result from fitCalibrations() or from ccg_cal_db.getValue()

"""

from collections import namedtuple
import math
import numpy
from scipy.optimize import curve_fit
import scipy.stats

###########################################################
def poly2(x, a, b=0, c=0):
    """ quadratic polynomial """
    return a + b*x + c*x*x

###########################################################
def get_significance(dof):
    """ Get probability of two tailed t distribution for
        given degrees of freedom
    """

    CONF_INTERVAL = 95  # e.g. 95% confidence interval
    SIGLEVEL = 1 - CONF_INTERVAL/100.0
    q = 1 - SIGLEVEL/2
#    print("q is", q, "df is", dof)
    tvalue = scipy.stats.t.ppf(q=q, df=dof)
#    print("tvalue is", tvalue)

    return tvalue


###########################################################
def check_tstar(dof, tstar, tvalue, debug):
    """ Check how calculated tvalue compares with t probability
    if tstar <= tvalue, conclude that coefficient = 0, return False
    if tstar > tvalue, conclude that coefficient != 0, return True
    """


    success = False
    if dof == 0:
        # if degrees of freedom is 0, i.e. exact fit (two points, linear fit)
        # then check if the drift coefficient is much greater than uncertainty of coefficient.
        # If so, use drift
        if tstar >= 2:
            if debug:
                print("coef is > 2*coef_unc, coefficient != 0")
            success = True
    else:
        if tstar > tvalue:
            if debug:
                print("   calculated t is > probability t, coefficient != 0")
            success = True
        else:
            if debug:
                print("   calculated t is < probability t, assume coefficient = 0")

    return success

###########################################################
def fitCalibrations(ocals, degree=None, debug=False):
    """ Determine fit to calibrations

    This function determines the time dependent fit to calibrations
    for a reference tank.  Use the highest degree polynomial where the
    coefficients of the fit are significant.
    Fits are made for a polynomial function; quadratic and linear.
    If the coefficient of the fit is significant, then accept that fit,
    otherwise do another fit dropping one degree in the fit, i.e.
    quadratic first, linear second, mean third.

    Input:
        ocals - list of dicts with calibration results.  These normally come
            from the ccg_cal_db module.

        debug - Print debugging information if True

    Returns:
        result - namedtuple containing (tzero, coef0, coef1, coef2, unc_c0, unc_c1, unc_c2, sd_resid, n, chisq)
    """

    names = ['tzero', 'coef0', 'coef1', 'coef2', 'unc_c0', 'unc_c1', 'unc_c2', 'sd_resid', 'n', 'chisq', 'calibrations']
#    names = ['tzero', 'coef0', 'coef1', 'coef2', 'unc_c0', 'unc_c1', 'unc_c2', 'sd_resid', 'n', 'chisq']
    Fit = namedtuple('calfit', names)

    x = [d['dd'] for d in ocals]
    np = len(x)

    # if no cals, return default value
    if np == 0:
        t = (0.0, -999.99, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, 0.0, (0,))

    else:

        y = [d['mixratio'] for d in ocals]
        ysd = []
        cal_idxs = []
        for d in ocals:
            # use measurement uncertainty if available, otherwise use standard deviation
            meas_unc = d['meas_unc']
            if meas_unc <= 0:
                meas_unc = d['stddev']
            unc = math.sqrt(d['typeB_unc']**2 + meas_unc**2)
            ysd.append(unc)
            cal_idxs.append(d['idx'])

        ysd2 = 1.0 / numpy.array(ysd)**2
        tzero = numpy.average(x, weights=ysd2)  # weighted average of central date
        x = [xp - tzero for xp in x]           # calculate deviation from central date

        # if only one cal, return it's value
        if np == 1:
            t = (0.0, y[0], 0.0, 0.0, ysd[0], 0.0, 0.0, 0.0, 1, 0.0, tuple(cal_idxs))

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

                popt, pcov = curve_fit(poly2, x, y, p0=beta0, sigma=ysd, absolute_sigma=True)
                beta_sd = numpy.sqrt(numpy.diag(pcov))

                dof = np - len(popt)
                tvalue = get_significance(dof)
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

                success = check_tstar(dof, tstar, tvalue, debug)
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
                coefs[i] = round(popt[i], 6)
                uncs[i] = round(beta_sd[i], 6)

            t = ((round(tzero, 6)),) + tuple(coefs) + tuple(uncs) + ((rsd),) + ((np),) + ((chisq),) + (tuple(cal_idxs),)

    result = Fit._make(t)
    if debug:
        print(result)

    return result
