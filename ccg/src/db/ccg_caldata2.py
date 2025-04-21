#!/usr/bin/python

"""
Updates the tower cylinder.dat file with new coefficients for
tank drift based on pre and post calibrations.

Usage:
   python ccg_caldat.py /path/to/cylinder.dat

This program reads the cylinder.dat file, determines new 
coefficients for each cylinder, and prints new line to stdout.

To create an updated cylinders.dat file, redirect output to a
file and mv/cp that file to original file.

e.g.
   python ccg_caldat.py /path/to/cylinders.dat > newcylinders.dat
   mv newcylinders.dat /path/to/cylinders.dat

"""

import sys
import MySQLdb
import getopt
import datetime
import numpy

from dateutil.parser import *

sys.path.append("/ccg/src/python/lib")
import ccgdates
import ccg_cals


#######################################################################
def getCoef(caldata, cutoffdate, after):
	""" Get coefficients for cylinder, either linear drift or average """

	x = []
	y = []
	have_before = False
	have_after = False
	for t in caldata:
		date = t['date']
		mr = float(t['mixratio'])
		flag = t['flag']
		if flag != ".": continue

		if date > cutoffdate:
			have_after = True
		if date < cutoffdate:
			have_before = True

		x.append(ccgdates.decimalDate(date.year, date.month, date.day) - 2000.0)
		y.append(mr)

#	print caldata
#	print x
#	print y
#	print have_before, have_after
#	sys.exit()

	# do linear fit if both pre and post cals, or average if only pre cals
	count = len(x)
	if len(x) > 1:
		if have_before and have_after:
			coeffs = numpy.polyfit(x, y, deg=1)
			coeffs = coeffs[::-1]  # reverse order of coefficients
		else:
			avg = numpy.mean(y)
			coeffs = [avg, -999.9]

	elif len(x) == 1:
		coeffs = [y[0], -999.9]
		
	else:
		coeffs = [-999.9, -999.9]

	return coeffs, have_before, have_after

#######################################################################
def check_extra(caldata):
	""" Check if any non Boulder cals were done for this cylinder """

	for t in caldata:
		if t['location'] != "BLD":
			return True

	return False

#######################################################################
def build_string(data, names):

	results = []
	for name in names:
		val = data[name]
		s = name + ":" + val
		results.append(s)

	s = "||".join(results)

	return s

#######################################################################


db=MySQLdb.connect(host="db",user="guest", passwd="", db="reftank")
c = db.cursor()


if len(sys.argv) >= 2:
	tankfile = sys.argv[1]

else:
	tankfile= "/ccg/towers/out/cylinders/name-value/tower_cylinders.dat"


try:
	f = open(tankfile)
except:
	sys.exit("Could not open file %s." % tankfile)

year2000 = datetime.datetime(2000, 1, 1)

skiplines = []

# Go through cylinders.dat file,
# and replace coef fields with new values.
for line in f:
	line = line.strip()

	# comments get passed through
	if line.startswith("#"): 
		print line
		continue

	# split the fields into a list
	a = line.split("||")

	# get the name for each field
	data = {}
	names = []
	for nv in a:
		(name, value) = nv.split(":", 1)
		data[name] = value
		names.append(name)

	if "db_cals" not in names:
		names.insert(-1, "db_cals")
		data["db_cals"] = ""


	# check the 'desc' field to get gas
	desc = data["desc"]
	b = desc.split("_")
	species = b[0]

#	if species.lower() != "co2": continue
#	if data["site"] != "sct": continue
#	if data["serial"] != "CA05503": continue

	if species.lower() not in ["co2", "co", "ch4", "n2o", "sf6", "h2"]:
		s = build_string(data, names)
		print s
		continue

#	print "@@@@", line

	s = data["installed"]
	install_date = parse(s)		# convert string to datetime
	install_date = install_date.date()
	
	sn = data["serial"]
#	fill, nfill = getFillList(sn)
#	fillcode = getFillCode(install_date, fill)
#	caldata = getCalResults(species, sn, fillingcode=fillcode)
	cals = ccg_cals.Calibrations(species, sn, official=True, method='TOWERCAL')
	fillcode = cals.getFillCode(install_date)
	caldata = [s for s in cals.cals if s['fillcode'] == fillcode]
	if len(caldata) == 0:
		data["db_cals"] = "none"
		s = build_string(data, names)
		print s
#		print line
		continue

	# if any cals are available that were done at tower site, 
	# create coefficients for linear drift between each calibration.
	if check_extra(caldata):


		# create a unique string for entries with extra tower cals
		skipstr = data["serial"] + data["site"] + data["desc"] + fillcode

		# if we haven't done this cylinder yet, create new lines for each calibration interval
		if skipstr not in skiplines:

			if len(caldata) > 1:

				for n, cd in enumerate(caldata[1:]):
					start_date = caldata[n]['date']  # n points to previous caldata
					start_time = caldata[n]['time']  # n points to previous caldata
					current_date = cd['date']
					current_time = cd['time']
					yprev = caldata[n]['mixratio']
					ycurr = cd['mixratio']

					dt1 = datetime.datetime(start_date.year, start_date.month, start_date.day) + start_time
					dt2 = datetime.datetime(current_date.year, current_date.month, current_date.day) + current_time

					dd1 = ccgdates.decimalDateFromDatetime(dt1)
					dd2 = ccgdates.decimalDateFromDatetime(dt2)

					x = [dd1-2000, dd2-2000]
					y = [float(yprev), float(ycurr)]
					coeffs = numpy.polyfit(x, y, deg=1)

	#				print dt1, dd1, dt2, dd2, yprev, ycurr, coeffs

					data["installed"] = dt1.strftime("%Y-%m-%dT%H:%M:%S")
					data["coef0"] = "%.3f" % coeffs[1]
					data["coef1"] = "%.4f" % coeffs[0]
					data["time0"] = year2000.strftime("%Y-%m-%dT%H:%M:%S")

					s = build_string(data, names)
					print s

			else:
				data["coef0"] = "%.4f" % float(caldata[0]['mixratio'])
				s = build_string(data, names)
				print s

			skiplines.append(skipstr)

#		print caldata
#		print "do extra cals", sn, species
#		print skiplines
#		sys.exit()

	else:

		# find linear drift for tank
		(coefs, pre_cals, post_cals) = getCoef(caldata, install_date, 0)
		if coefs[0] > -999:
			data["coef0"] = "%.3f" % coefs[0]
		if coefs[1] > -999:
			data["coef1"] = "%.4f" % coefs[1]
			data["time0"] = year2000.strftime("%Y-%m-%dT%H:%M:%S")

		if pre_cals and post_cals:
			data["db_cals"] = "pre-post"
		elif pre_cals:
			data["db_cals"] = "pre"
		elif post_cals:
			data["db_cals"] = "post"
		else:
			data["db_cals"] = "none"

		s = build_string(data, names)
		print s

#	if sn == "CA05503" and species.lower() == "co2": sys.exit()
