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



#######################################################################
# Get filling information for a specific tank serial number
#######################################################################
def getFillList(tank):

        sql = "SELECT date,code FROM fill WHERE serial_number='%s' ORDER BY date" % (tank)
        c.execute(sql)
        filllist = c.fetchall()
        fill = []
        for line in filllist:
                fill.append(line)
        dt = datetime.date(9999, 12, 31)
        fill.append((dt, "Z"))
        nfill = len(fill)

        return fill, nfill

#######################################################################
# Find the correct fill code for a given date.  The 'fill' array
# comes from the getFillList routine.
#######################################################################
def getFillCode(date, fill):

        for n in range(0, len(fill)-1):
                (filldate, fillcode) = fill[n]
                (nextfilldate, nextfillcode) = fill[n+1]
                if filldate == None or nextfilldate == None:
                        return "None"
                if date >= filldate and date < nextfilldate:
                        return fillcode

        return "None"

#######################################################################
def getCalResults(gas, tank, fillingcode=None):

	syslist = getSyslist(gas)

        sql  = "SELECT * FROM calibrations "
        sql += "WHERE serial_number='%s' " % tank
        sql += "AND species='%s' " % gas
        sql += "AND (inst in (%s) OR method='TOWERCAL') " % syslist
        sql += "ORDER BY date,time"

        c.execute(sql)
        result = c.fetchall()

	rows = []
        if c.rowcount > 0:
                fill, nfill = getFillList(tank)

                for line in result:
                        (index, sn, date, time, species, mr, sd, nq, method, inst, pressure, flag, loc, reg, notes, mod_date) = line
                        fillcode = getFillCode(date, fill)
                        if fillingcode and fillcode != fillingcode: continue
                        t = (sn, loc, fillcode, date, time, species, mr, sd, nq, method, inst, pressure, flag)
			rows.append(t)

	return rows


#######################################################################
def getSyslist(gas):
	""" Get a comma separated string containing all of the analyzer codes
	required for the given gas.
	"""

	acodes = {
		"co2": "U1,U2,U3,U4,U6,S2,S4,S5,L1,L2,L9,PC1,MANO",
		"ch4": "H5,C2,C3,C4,H7,PC1",
		"co":  "V1,V2,LGR2,R2,R7,V3",
		"n2o": "HP,VC",
		"sf6": "HP,VC",
		"h2":  "R7,P2,H9",
	}
		

        if gas == "All":
		# combine all analyzer codes and create a unique list of codes
		x = [acodes[key] for key in acodes.keys() ]
		s = ",".join(x)
		a = list(set(s.split(",")))
	else:
		a = acodes[gas.lower()].split(",")

	# add single quotes around each code and create a comma separated string
        tmplist = [ "'" + s + "'" for s in a ]
        syslist = ",".join(tmplist)

	return syslist

#######################################################################
def getAvg(caldata, cutoffdate, after):

	a = []
	for t in caldata:
		date = t[3]
		mr = float(t[6])
		flag = t[12]
		if flag != '.': continue
#		if after:
#			if date > cutoffdate:
#				a.append(mr)
#		else:
#			if date < cutoffdate:
#				a.append(mr)
		a.append(mr)

	count = len(a)
	if count > 0:
		avg = numpy.mean(a)
		std = numpy.std(a, ddof=1)
	else:
		avg = -999.9
		std = -99.99

	return avg, std, count


#######################################################################
def getCoef(caldata, cutoffdate, after):


	x = []
	y = []
	have_before = False
	have_after = False
	for t in caldata:
		date = t[3]
		mr = float(t[6])
		flag = t[12]
		if flag != ".": continue

		if date > cutoffdate:
			have_after = True
		if date < cutoffdate:
			have_before = True

		x.append(ccgdates.decimalDate(date.year, date.month, date.day))
		y.append(mr)

#	print caldata
#	print x
#	print y
#	print have_before, have_after
#	sys.exit()

#	print y

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

	return coeffs

#######################################################################
def check_extra(caldata):

	for t in caldata:
		if t[1] != "BLD":
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


skiplines = []

# Go through cylinders.dat file,
# and replace coef fields with new values.
for line in f:
	line = line.strip()

#	print "@@@@@@@@@", line

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

	# check the 'desc' field to get gas
	desc = data["desc"]
	b = desc.split("_")
	species = b[0]

	if species.lower() not in ["co2", "co", "ch4", "n2o", "sf6", "h2"]:
		print line
		continue


	s = data["installed"]
	install_date = parse(s)		# convert string to datetime
	install_date = install_date.date()
	
	sn = data["serial"]
	fill, nfill = getFillList(sn)
	fillcode = getFillCode(install_date, fill)
	caldata = getCalResults(species, sn, fillingcode=fillcode)

	# if any cals are available that were done at tower site, 
	# create coefficients for linear drift between each calibration.
	if check_extra(caldata):

		# create a unique string for entries with extra tower cals
		skipstr = data["serial"] + data["site"] + data["desc"] + fillcode

		# if we haven't done this cylinder yet, create new lines for each calibration interval
		if skipstr not in skiplines:

			for n, cd in enumerate(caldata[1:]):
				start_date = caldata[n][3]  # n points to previous caldata
				start_time = caldata[n][4]  # n points to previous caldata
				current_date = cd[3]
				current_time = cd[4]
				yprev = caldata[n][6]
				ycurr = cd[6]

				dt1 = datetime.datetime(start_date.year, start_date.month, start_date.day) + start_time
				dt2 = datetime.datetime(current_date.year, current_date.month, current_date.day) + current_time

				dd1 = ccgdates.decimalDateFromDatetime(dt1)
				dd2 = ccgdates.decimalDateFromDatetime(dt2)

				x = [dd1-2000, dd2-2000]
				y = [float(yprev), float(ycurr)]
				coeffs = numpy.polyfit(x, y, deg=1)

#				print dt1, dd1, dt2, dd2, yprev, ycurr, coeffs
				year2000 = datetime.datetime(2000, 1, 1)

				data["installed"] = dt1.strftime("%Y-%m-%dT%H:%M:%S")
				data["coef0"] = "%.4f" % coeffs[1]
				data["coef1"] = "%.4f" % coeffs[0]
				data["time0"] = year2000.strftime("%Y-%m-%dT%H:%M:%S")

				s = build_string(data, names)
				print s

			skiplines.append(skipstr)


#		print caldata
#		print "do extra cals", sn, species
#		print skiplines
#		sys.exit()

	else:

		# find linear drift for tank
		(coefs) = getCoef(caldata, install_date, 0)
		if coefs[0] > -999:
			data["coef0"] = "%.6f" % coefs[0]
		if coefs[1] > -999:
			data["coef1"] = "%.6f" % coefs[1]

		s = build_string(data, names)
		print s

	if sn == "CC311722" and species.lower() == "co2": sys.exit()
