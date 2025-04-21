
import numpy

ybottom = 194
amin = 0
aratio = 2.5666666666666666e-05

x = numpy.loadtxt("/tmp/zzzz")
print(x)
a = numpy.around(x)

#a = numpy.around(ybottom - ((x - amin) * aratio))
print(a)
