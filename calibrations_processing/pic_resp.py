
"""
process a picarro response curve calibration
done by the aircraft group

raw file is in a calibration raw file format, 
but with some differences

"""

import sys

from collections import defaultdict
import numpy

import ccg_rawfile
import ccg_refgasdb
import ccg_utils


filename = "mko/2022-08-19.1624.co2"

raw = ccg_rawfile.Rawfile(filename)

#print(raw.data)

# we'll go through the raw lines and save the
# analyzer output value for each std, then
# calculate the mean of those.
# This will be used in the polyfit

data = defaultdict(list)

for i in range(raw.numrows):
    row = raw.dataRow(i)
    print(row)

    if row.flag == ".":
        data[row.event].append(row.value)

adate = raw.adate
print(data)
print(raw.stds)
x = []
xwt = []
ywt = []
y = []
for std in raw.stds:
#    print(raw.info[std])
    sn = raw.info[std]
    rg = ccg_refgasdb.refgas("CO2", [sn])
    val = rg.getRefgasBySerialNumber(sn, adate, std_unc=False)
    avgval = numpy.mean(data[std])
    avgstd = numpy.std(data[std], ddof=1)
    print(std, sn, avgval, val)

    x.append(avgval)
    xwt.append(avgstd)
    y.append(val[0])
    ywt.append(val[1])

print(x)
print(y)
print(xwt)
print(ywt)
    
fit_degree = 2
fit1, rsd1 = ccg_utils.odr_fit(1, x, y, xwt, ywt)
fit2, rsd2 = ccg_utils.odr_fit(2, x, y, xwt, ywt)
print(fit1.beta)
print(fit2.beta)

for xp in numpy.arange(x[0], x[-1], 1):
    yv1, unc = ccg_utils.odr_fit_val(1, xp, fit1, rsd1)
    yv2, unc = ccg_utils.odr_fit_val(2, xp, fit2, rsd2)
    print(xp, yv1, yv2, yv2-yv1)


