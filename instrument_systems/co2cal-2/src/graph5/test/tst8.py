

import numpy

a = numpy.array( [1,2,3,4,5,-1e-18, 6, 7, 8])
print a

b = numpy.where(abs(a)<1e-15)
print b

a[b] = 0
print a
