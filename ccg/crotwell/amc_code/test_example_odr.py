
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

#x = [-1.1378380000000001, -0.5824659999999999, 0.7242760000000001, 1.6047880000000005]
#xsd =  [0.003176171752282927, 0.0031031086026757104, 0.0033932643575176986, 0.0035582560335085498]
#y = [392.659, 398.359, 411.666, 420.644]
#ysd = [0.03, 0.03, 0.03, 0.03]


# data from external scale comparison
x = [340.54, 365.65, 379.35, 406.29, 414.4, 428.05, 440.07, 449.63, 479.0]
y =  [340.626541, 365.790021, 379.516907, 406.502798, 414.647751, 428.272669, 440.3423977912973, 449.9064349632414, 479.316201962241]
xsd =  [0.022360679774997897, 0.03162277660168379, 0.03162277660168379, 0.022360679774997897, 0.022360679774997897, 0.01414213562373095, 0.022360679774997897, 0.01414213562373095, 0.022360679774997897]
ysd =  [0.010616688231270616, 0.009639978526947039, 0.010589923984618586, 0.012623476858615458, 0.012891300012023613, 0.011268765904037584, 0.011099033826225832, 0.01917338866724, 0.01123825276176548]



#fit_order = 2 # quadratic
fit_order = 1 # linear
fit = odr_fit(fit_order, x, y, xsd, ysd)
print(fit)

resid = numpy.polyval(fit.beta[::-1], x) - numpy.array(y)
print("residuals are", resid)
rsd = numpy.std(resid, ddof=2)
print("rsd is", rsd)

covar = fit.cov_beta

# partial derivatives of polynomial with respect to the coefficients at point xp
#xp = 1.5
xp = 400.0
a = numpy.array([xp**i for i in range(fit_order+1)])

# variance of estimated y value (confidence interval)
z1 = numpy.dot(a.T, covar)
var = numpy.dot(z1, a)
print("variance is ", var)

var = var + rsd*rsd  # prediction interval variance

print("uncertainty at", xp, "is", math.sqrt(var))

