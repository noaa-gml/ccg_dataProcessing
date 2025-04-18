

import datetime

import numpy

import matplotlib.pyplot as plt


x=[]

td = datetime.datetime(2010, 1, 1, 0, 0, 0)
x.append(td)
td = datetime.datetime.now()
x.append(td)
a = numpy.array(x)

y = [1,4]

print a

plt.plot_date(x, y)

plt.plot([34, 38, 40], [1,5,3])
plt.show()
