
# vim: tabstop=4 shiftwidth=4 expandtab

import math
import numpy
from scipy.odr import odrpack as odr
from scipy.odr import models

#--------------------------------------------------------------------------
def odr_fit(fit_degree, x, y, xsd, ysd, debug=False):
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

    return fit

x = [-1.1378380000000001, -0.5824659999999999, 0.7242760000000001, 1.6047880000000005]
xsd =  [0.003176171752282927, 0.0031031086026757104, 0.0033932643575176986, 0.0035582560335085498]
y = [392.659, 398.359, 411.666, 420.644]
ysd = [0.03, 0.03, 0.03, 0.03]


fit_order = 2 # quadratic
fit = odr_fit(fit_order, x, y, xsd, ysd)

resid = numpy.polyval(fit.beta[::-1], x) - numpy.array(y)
print("residuals are", resid)
rsd = numpy.std(resid, ddof=2)
print("rsd is", rsd)

covar = fit.cov_beta

# partial derivatives of polynomial with respect to the coefficients at point xp
xp = 1.5
a = numpy.array([xp**i for i in range(fit_order+1)])

# variance of estimated y value (confidence interval)
z1 = numpy.dot(a.T, covar)
var = numpy.dot(z1, a)
print("variance is ", var)

var = var + rsd*rsd  # prediction interval variance

print("uncertainty at", xp, "is", math.sqrt(var))

