
import os
import math
import numpy


def surface_subset(infile, species, latmin, latmax, reftype):

	# One axis of surface is in sine latitude.
	# These are the values:
	# -1 to 1 in 0.05 steps
	nsinebands = 41
	sinelat = numpy.linspace(-1, 1, nsinebands)
#	print sinelat

	if not os.path.exists(infile):
		sys.exit("File %s does not exist" % infile)

	data = numpy.loadtxt(infile)
#	print data
#	print data.shape

	# first column of data is decimal date
	# extract that column here
	dd = data[:,0]
	ntimesteps = dd.size
#	print dd
#	print "ntimesteps", ntimesteps

	# create separate array of values only without date
	values = data[:,1:]
#	print values

	# input latmin and latmax are in degrees, 
	# create corresponding values of sine latitude
	sinelatmin = math.sin(math.radians(latmin))
	sinelatmax = math.sin(math.radians(latmax))
#	print latmin, latmax, sinelatmin, sinelatmax


	surface2 = numpy.array( values)

	# find first latitude that is < given latmin,
	# and last latitude that is > given latmax
	a = numpy.where( (sinelat > sinelatmin) & (sinelat < sinelatmax) )
#	print a

	pl2 = a[0][0]	# index where lat > latmin
	pl1 = pl2 - 1	# index where lat <= latmin
	lat_start = pl1
	lat_end = a[0][-1] + 1
#	print "lat_start, lat_end", lat_start, lat_end

	# work on min lat
	pl1 = lat_start
	pl2 = lat_start + 1
	l1 = sinelat[pl1]
	l2 = sinelat[pl2]
#	print pl1, pl2, l1,l2

	v1 = values[:, pl1]
	v2 = values[:, pl2]

	m = (v2-v1)/(l2-l1)
	surface2[:,pl1] = v1 + (sinelatmin-l1)*m

	# work on max lat
	pl1 = lat_end-1
	pl2 = lat_end
	l1 = sinelat[pl1]
	l2 = sinelat[pl2]
#	print pl1, pl2, l1, l2

	v1 = values[:, pl1]
	v2 = values[:, pl2]

	m = (v2-v1)/(l2-l1)
	surface2[:,pl2] = v1 + (sinelatmax-l1)*m

	# set min and max sine latitudes to given values, not grid values
	sinelat[lat_start] = sinelatmin
	sinelat[lat_end] = sinelatmax

#	print surface2
#	print sinelat

	# extract the values over the given latitude range
	subset_values = surface2[:,lat_start:lat_end+1]
#	print "subset values shape", subset_values.shape
	
	# extract the latitude values over the given latitude range
	subset_lat = sinelat[lat_start:lat_end+1]
	nlats = subset_lat.size
#	print subset_lat
#	print subset_lat.size

	lat_range = sinelatmax - sinelatmin
#	print lat_range


	if lat_range == 0:
		result = subset_values[0]

	else:
		result = numpy.zeros( (ntimesteps) )
		for i in range(ntimesteps):
			integrated_value = 0.0
			for j in range(nlats-1):
				ybar = 0.5 * (subset_values[i,j] + subset_values[i,j+1])
				dl = abs(subset_lat[j+1] - subset_lat[j])
				integrated_value += (ybar*dl)/lat_range

			result[i] = integrated_value

#	print result
#	print result.shape

	return dd, result

if __name__ == '__main__':

	x, y = surface_subset("/webdata/ccgg/GHGreference/co2/surface.mbl.co2.txt", "co2", -10, 10, "zonal")

	print x, y
	print x.tolist(), y.tolist()

