# vim: tabstop=4 shiftwidth=4 expandtab
"""
Utility functions
"""

from __future__ import print_function

import sys
import datetime
import subprocess
from math import sqrt, pow, exp
import numpy
from numpy.polynomial import Polynomial as Poly
from numpy.polynomial.polynomial import polyval
from scipy.odr import odrpack as odr
from scipy.odr import models



#############################################################
def clean_line(line):
    """
    Remove unwanted characters from line,
    such as leading and trailing white space, new line,
    and comments
    """

    line = line.strip('\n')                 # get rid of new line
    line = line.split('#')[0]               # discard '#' and everything after it
    line = line.strip()                     # strip white space from both ends
    line = line.replace("\t", " ")          # replace tabs with spaces

    return line

#############################################################
def cleanFile(filename, showError=True):
    """
    Return the contents of a file as a list, one line = one list item.
    Remove comment lines, and comments within a line.
    Remove blank lines and white space at front and end of a line.
    """

    data = []


    try:
        f = open(filename)
    except (OSError, IOError) as err:
        if showError:
            print("ERROR: cleanFile: Can't open file", filename, err, file=sys.stderr)
        return data

    for line in f:
        line = clean_line(line)
        if line:
            data.append(line)

    f.close()

    return data

#############################################################
def removePrefix(string, prefix):
    """ Remove a prefix or from a string, if present.
    Copied from PEP 616, for use in Python < 3.9"""
    if string.startswith(prefix):
        return string[len(prefix):]
    else:
        return string[:]
    
#############################################################
def removeSuffix(string, suffix):
    """ Remove a suffix or from a string, if present.
    Copied from PEP 616, for use in Python < 3.9"""
    # suffix='' should not call self[:-0].
    if suffix and string.endswith(suffix):
        return string[:-len(suffix)]
    else:
        return string[:]


########################################################################
def getPeakType(system, adate, species="", defaults=None, defaults_file=""):
    """ Get the correct peak type to use for a GC on the given date.
    Parameters:
        system: analysis system id or station code
        adate: datetime object with desired date
        species: gas species formula, e.g. 'CH4'
        defaults: list of default values already obtained by getDefaults()
        defaults_file: file to read if defaults is empty.  If not set, uses default file name

        species is not needed if defaults is set, but is required
        if defaults is not set and defaults_file is not set
    """

    # if no defaults list given, get them from file
    if not defaults:
        defaults = getDefaults(system, species, defaults_file)
        if not defaults:
            return "area"


    # convert adate datetime to string
    dd = "%4d-%02d-%02d.%02d%02d" % (adate.year, adate.month, adate.day, adate.hour, 0)
    for (gas, sysname, method, peaktype, start, end) in defaults:
        if start <= dd <= end:
            return peaktype

    # no matching default found
    return "area"

########################################################################
def getDefaults(system, species="", defaults_file=""):
    """ Get entries from a defaults file.  The file has the peak type to use for date periods.
    Format of the file is
    ch4    H6    r1-s-r1            area    1983-00-00.0000    9999-99-99.9999
    which is gas, system id, calculation method (not used anymore), peak type, start date, end date
    Parameters:
        system: analysis system id or station code
        species: gas species formula, e.g. 'CH4'
        defaults_file: file to read.  If not set, uses default file name

    Returns a list of tuples containing the (species, system, method, start, end)
    """


    if defaults_file == "":
        file = "/ccg/%s/defaults" % species.lower()
    else:
        file = defaults_file

    try:
        f = open(file)
    except:
        return []

    a = []
    for line in f:
        line = clean_line(line)

        # save only those line that match the system id
        if system.upper() in line:
            (gas, sta, method, peaktype, start, end) = line.split()
            a.append((gas.upper(), sta.upper(), method, peaktype, start, end))


    return a



#########################################################################
def meanstdv(x):
    """ Calculate mean and standard deviation of data x[]:
    mean = { sum_i x_i  over n}
    std = sqrt( sum_i (x_i - mean)^2  over n-1)
    """

    n, mean, std = len(x), 0, 0

    if n == 1:
        mean = x[0]

    elif n > 1:

        for a in x:
            mean = mean + a
        mean = mean / n

        for a in x:
            std = std + (a - mean)**2

        std = sqrt(std / (n-1))

    return mean, std

#########################################################################
def combined_stdv(means, sds, ncounts):
    ''' compute combined standard deviation

    where means is a list of averages, with associated stdvs in sds
    '''

    ng = len(means)

    if ng != len(sds):
        raise Exception('inconsistent list lengths')
    if ng != len(ncounts):
        raise Exception('wrong ncounts list length')

    N = sum(ncounts)
    if N == 1:
        return sds[0]

    # calculate weighted average
    average = numpy.average(means, weights=ncounts)

#    print("%%%%%", sds, ncounts, N, average)

    # calculate weighted standard variance
    # or the 'combined variance'
    # see e.g. https://www.emathzone.com/tutorials/basic-statistics/combined-variance.html
    ss = 0
    for n, avg, s in zip(ncounts, means, sds):
        if n == 0: continue
        d = avg - average
        ss += n*(s*s + d*d)

    sp = ss/N

    return sqrt(sp)


#########################################################################
def polyderiv(x, params):
    """ Calculate the derivative of polynomial at x """

    p = Poly(params)
    s = polyval(x, p.deriv().coef)

    return s

#########################################################################
def poly(x, params):
    """ Calculate a value at x from np number of polynomial coefficients
    parameters are in order
        param[0] + param[1]*x + param[2]*x^2 ...

    This is the opposite order of coefficients then is used by numpy.polyval
    """

    sumx = polyval(x, params)

    return sumx

#########################################################################
def power(x, params):
    """
    Calculate a value at x for a power function.
    y = a + bx^c
    parameters are in order
        param[0] + param[1]*x^param[2]

    """

    if len(params) < 3:
        raise ValueError("Need 3 parameters for power function.")

    return params[0] + params[1]*pow(x, params[2])

#########################################################################
def expfunc(x, params):
    """
    Calculate a value at x for an exponential function
    y = a + be^cx
    parameters are in order
        param[0] + param[1]* exp(param[2]*x)

    """

    if len(params) < 3:
        raise ValueError("Need 3 parameters for exponential function.")

    return params[0] + params[1] * exp(params[2]*x)


###########################################################################
def getBC(stacode, gas, date):
    """ Get the acceptable baseline codes for a gas on a given date """

    if gas.lower() == "ch4":
        bcodes = ["BP", "PB", "BB"]
        dd = date.year*10000 + date.month*100 + date.day
#        if stacode == "BRW" and dd <= 19880630:
#            bcodes = ["BB"]

    if gas.lower() == "co":
        bcodes = ["BP", "PB", "BB", "BT", "FF", "BF", "FB"]

    return bcodes


###########################################################################
def addTagToDatanum(flag, datanum, mode=0, verbose=False, test=False, force_flag=False, data_source=False, update=True):
    """ call the addtag script to update the flag for the given event and gas """

    com = []
    com.append("/ccg/src/db/ccg_addtag.pl")
    com.append("-flag='%s'" % flag)
    com.append("-data_num='%s'" % datanum)
    if update:
        com.append("-u")
    com.append("-mergeMode=%s" % mode)
    if force_flag:
        com.append("-forceUpdate=1")
    if data_source:
        com.append("-data_source=14")
    if verbose:
        com.append("-v")

    command = " ".join(com)
    if verbose:
        print(command)

    if test:
        print(command)
        return 0, ""

    try:
        p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = p.communicate()
        retcode = p.returncode
        if verbose:
            print(output)
        if retcode != 0 and len(errors) > 0:
            print(errors)

        return retcode, errors

    except OSError as e:
        print("Error running script.", " ".join(com), file=sys.stderr)
        print("Error was", e, file=sys.stderr)

        return 1, e

###########################################################################
def addTagNumberToDatanum(tagnum, datanum, mode=0, verbose=False, test=False, force_flag=False, data_source=False, update=True):
    """ call the addtag script to update the flag for the given event and gas """

    com = []
    com.append("/ccg/src/db/ccg_addtag.pl")
    com.append("-tag_num=%s" % tagnum)
    com.append("-data_num='%s'" % datanum)
    if update:
        com.append("-u")
    com.append("-mergeMode=%s" % mode)
    if force_flag:
        com.append("-forceUpdate=1")
    if data_source:
        com.append("-data_source=14")
    if verbose:
        com.append("-v")

    command = " ".join(com)
    if verbose:
        print(command)

    if test:
        print(command)
        return 0, ""

    try:
        p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = p.communicate()
        retcode = p.returncode
        if verbose:
            print(output)
        if retcode != 0 and len(errors) > 0:
            print(errors)

        return retcode, errors

    except OSError as e:
        print("Error running script.", " ".join(com), file=sys.stderr)
        print("Error was", e, file=sys.stderr)

        return 1, e

###########################################################################
def addTag(event, species, flag, system, date, time, mode=0, verbose=False, test=False, force_flag=False, data_source=False):
    """ call the addtag script to update the flag for the given event and gas """

    com = []
    com.append("/ccg/src/db/ccg_addtag.pl")
    com.append("-flag='%s'" % flag)
    com.append("-e=%s" % event)
    com.append("-g=%s" % species)
    com.append("-adate='%s'" % date)
    com.append("-atime='%s'" % time)
    com.append("-inst=%s" % system)
    com.append("-u")
    com.append("-mergeMode=%s" % mode)
    if force_flag:
        com.append("-forceUpdate=1")
    if data_source:
        com.append("-data_source=14")
    if verbose:
        com.append("-v")

    command = " ".join(com)
    if verbose:
        print(command)

    if test:
        print(command)
        return 0, ""

    try:
        p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = p.communicate()
        retcode = p.returncode
        if verbose:
            print(output)
        if retcode != 0 and len(errors) > 0:
            print(errors)

        return retcode, errors

    except OSError as e:
        print("Error running script.", " ".join(com), file=sys.stderr)
        print("Error was", e, file=sys.stderr)

        return 1, e

###########################################################################
def addTagNumber(event, species, tagnum, system, date, time, mode=0, verbose=False, test=False, devdb=False, data_source=False):
    """ call the addtag script to update the flag for the given event and gas """

    com = []
    com.append("/ccg/src/db/ccg_addtag.pl")
    com.append("-tag=%s" % tagnum)
    com.append("-e=%s" % event)
    com.append("-g=%s" % species)
    com.append("-adate='%s'" % date)
    com.append("-atime='%s'" % time)
    com.append("-inst=%s" % system)
    com.append("-u")
    com.append("-mergeMode=%s" % mode)
    if devdb:
        com.append("-productionDB=0")
    if data_source:
        com.append("-data_source=14")
    if verbose:
        com.append("-v")

    command = " ".join(com)
    if verbose:
        print(command)

    if test:
        print(command)
        return 0, ""

    try:
        p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = p.communicate()
        retcode = p.returncode
        if verbose:
            print(output)
        if retcode != 0 and len(errors) > 0:
            print(errors)

        return retcode, errors

    except OSError as e:
        print("Error running script.", " ".join(com), file=sys.stderr)
        print("Error was", e, file=sys.stderr)

        return 1, e


###########################################################################
def getTag(event, species, system, date, time, verbose=False, test=False):
    """ call the ccg_getTags.pl perl script  and return the output """

    com = []
    com.append("/ccg/src/db/ccg_getTags.pl")
    com.append("-event_num=%s" % event)
    com.append("-parameter=%s" % species)
    com.append("-adate='%s'" % date)
    com.append("-atime='%s'" % time)
    com.append("-inst=%s" % system)
    command = " ".join(com)
    try:
        p = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = p.communicate()

    except OSError as e:
        print("Error running script.", " ".join(com), file=sys.stderr)
        print("Error was", e, file=sys.stderr)
        s = "Error running script.", " ".join(com)
        s += "Error was %s" % e
        return s

    retcode = p.returncode
#    if retcode != 0 and len(errors) > 0:
#        print errors

    return errors + output

#/ccg/src/db/ccg_getTags.pl -event_num=425272 -parameter='co2' -adate='2017-05-11' -atime='18:25:00' -inst='L8'


########################################################################
def get_system(stacode, gas, date):
    """ get system name at an observatory site for the
    given gas and date

    These names must match with the system names in the
    'System' column in the inst_history table
    """

    if stacode.upper() == "BRW":
        if gas.upper() in ("CH4", "CO", "N2O"):
            if date < datetime.datetime(2013, 4, 11):
                return "GC"
            else:
                return "LGR"

        else:
            if date < datetime.datetime(2013, 4, 11):
                return "NDIR"
            elif date >= datetime.datetime(2017, 1, 1):
                return "LGR"
            else:
                # ambiguous, could be either ndir or lgr
                return None

    elif stacode.upper() == "MLO":
        if gas.upper() in ("CH4", "CO"):
            if date < datetime.datetime(2019, 4, 10, 22, 35, 0):
                return "GC"
            else:
                return "PIC"

        else:
            if date < datetime.datetime(2019, 4, 10, 22, 35, 0):
                return "NDIR"
            elif date >= datetime.datetime(2019, 6, 1):
                return "PIC"
            else:
                # ambiguous, could be either ndir or pic
                return None

    elif stacode.upper() == "CHS":
        return "LGR"

    else:
        return "NDIR"

########################################################################
def odr_fit(fit_degree, x, y, xsd, ysd, debug=False):
    """ Run an odr fit to the data x, y with weights xsd, ysd """

    if len(x) <= fit_degree:
        sys.exit("Not enough data points (%d) for degree of fit (%d)" % (len(x), fit_degree))

    # set up odr fit, give it plenty of iterations and an initial estimate of the coefficients
    func = models.polynomial(fit_degree)
    p = Poly.fit(x, y, fit_degree)  # initial guess at coefficients
    beta0 = p.convert().coef
    if debug:
        print("estimated coefficients are", beta0)
        print("calling odr with")
        print("   x = ", x)
        print("   y = ", y)
        print(" xsd = ", xsd)
        print(" ysd = ", ysd)

    mydata = odr.RealData(x, y, xsd, ysd)
    myodr = odr.ODR(mydata, func, beta0=beta0, maxit=1000)
    myodr.set_job(0)
#    if debug:
#        myodr.set_iprint(init=2, iter=2, final=2)

    fit = myodr.run()

    resid = polyval(x, fit.beta) - numpy.array(y)
    if len(x) == fit_degree+ 1:
        rsd = 0
    else:
        rsd = numpy.std(resid, ddof=2)

    return fit, rsd

########################################################################
def odr_fit_val(fit_degree, x, fit, rsd):
    """ Compute the value and uncertainty of the response curve at point x

    Args:
        fit_degree : degree of polynomial (2 = quadratic, 1 = linear)
        x : x axis value at which to compute value and uncertainty
        fit : odr fit results
        rsd : residual standard deviation from odr fit
    """

    value = polyval(x, fit.beta)
    meas_unc = odr_fit_unc(fit_degree, x, fit.cov_beta, rsd)

    return value, meas_unc

########################################################################
def odr_fit_unc(fit_degree, x, covar, rsd):
    """ Compute the uncertainty of the response curve at point x

    Args:
        fit_degree : degree of polynomial (2 = quadratic, 1 = linear)
        x : x axis value at which to compute uncertainty
        covar : covariance matrix from odr fit
        rsd : residual standard deviation from odr fit
    """

    # partial derivatives of polynomial with respect to the coefficients
    a = numpy.array([x**i for i in range(fit_degree+1)])

    # variance of estimated y value s2(yh)
    # Equation 7.50, 'Applied Linear Regression Models', Neter, Wasserman and Kutner, 1983
    # Then use equation 7.55a, rsd^2  + s2(yh)

    # variance of estimated y value
    z1 = numpy.dot(a.T, covar)
    var = numpy.dot(z1, a) # confidence interval variance
    var = var + rsd*rsd    # predicted value variance
    if var >= 0:
        unc = sqrt(var)
    else:
        unc = -99.99

    return unc
