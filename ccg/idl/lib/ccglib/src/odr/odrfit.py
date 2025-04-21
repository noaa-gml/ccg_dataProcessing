#!/usr/bin/env python
"""
Driver program for odr fit to data using IDL and the ccg routine ccg_odr.pro

Input data is specified in the file given by the -s option.
The format of the file has one line for each estimated polynomial coefficient,
the multiple lines with the data in 4 columns, x, x weight, y, y weight.

The output report from the odr run is written into the file
given by the -d option.  The IDL ccg routine ccg_odr.pro reads this file
for results.

The -o option tells the number of polynomial coefficients to use in the fit,
i.e. 2 = linear, 3 = quadratic.

The method of using options, files and odr output is to be consistent with the way the
c/fortran odrfit program worked, and with how ccg_odr.pro uses the files.
"""
 
import os
import sys
import argparse

from scipy.odr import odrpack as odr
from scipy.odr import models

parser = argparse.ArgumentParser(description="Perform odr fit to data. ")
parser.add_argument('-s', '--source', default=None, help="Source data file.")
parser.add_argument('-d', '--report', default=None, help="Output data file.")
parser.add_argument('-o', '--order', default=None, type=int, help="Order of fit.")

options = parser.parse_args()

if options.source is None or options.report is None or options.order is None:
    sys.exit("Wrong number of arguments.")


# beta0 is estimated coefficients of polynomial.  These are set in the input file.
beta0 = [0.0 for i in range(options.order)]
x = []
y = []
xwt = []
ywt = []

with open(options.source) as fp:
    for i in range(options.order):
        s = fp.readline()
        s = s.strip()
        beta0[i] = float(s)

    for line in fp:
        line = line.strip()
        a = [float(d) for d in line.split()]
        x.append(a[0])
        xwt.append(a[1])
        y.append(a[2])
        xwt.append(a[3])

if os.path.exists(options.report):
    os.remove(options.report)

FIT = options.order - 1

func = models.polynomial(FIT)
mydata = odr.RealData(x, y, xwt, ywt)

# set up odr fit, give it plenty of iterations and an initial estimate of the coefficients
myodr = odr.ODR(mydata, func, beta0=beta0, maxit=1000, rptfile=options.report)
myodr.set_job(0)

# set odr output report.  Final short report.
myodr.set_iprint(init=0, iter=0, final=1)

fit = myodr.run()
