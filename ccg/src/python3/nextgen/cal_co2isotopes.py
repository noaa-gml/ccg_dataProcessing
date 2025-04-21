
"""
# This file contains routines needed for calculating co2 calibration results
# using the co2cal-2 system which is based on various isotope measurements of co2
"""
from __future__ import print_function

import sys
import os

from math import sqrt

import ccg_cal

#Reference values for (13C/12C)VPDB, (18O/16O)VPDB-CO, and (17O/16O)VPDB-CO
#r13_PDB = 0.0112372  # this value was used in previous version
r13_PDB_X2007 = 0.0112372  # this value was used in previous version
r13_PDB_X2019 = 0.011180
r18_PDB = 0.002088349
r17_PDB = 0.00039511

# Limits of co2 scale (in ppm) where isotope corrections are made
CO2_SCALE_MINIMUM = 240.0
CO2_SCALE_MAXIMUM = 810.0

########################################################################
def getCO2RawFiles(filename, caldata):
	""" Find corresponding raw files for co2/isotopes when using
	co2cal-2 system """

	bname = os.path.basename(filename)
	idx = bname.rfind(".")
	datestr = bname[0:idx]

	year = caldata.adate.year
	co2dir = "/ccg/co2/cals/%s/raw/%d/" % (caldata.system, year)
	co2file = co2dir + datestr + ".co2"
	if not os.path.exists(co2file):
		# if reprocessing co2c13 or co2o18, the AR1 and LGR6 co2 file may not exist
		# at beginning, so use the picarro co2 instead.
		if caldata.analyzer_id in ["LGR6", "AR1"]:
			co2dir = "/ccg/co2/cals/%s/raw/%d/" % (caldata.system, year)
			co2file = co2dir + datestr.replace(caldata.analyzer_id.lower(), "pc1")
#			co2file = co2dir + datestr + ".co2"
			if not os.path.exists(co2file):
				co2file = None
		else:
			co2file = None

	# search isotope directories for corresponding raw files
	idx = bname.rfind(".")
	bname = bname[0:idx]
	idx = bname.rfind(".")
	bname = bname[0:idx]
	datestr = bname[0:idx]
	for instid in ["LGR6", "AR1"]:
		co2c13dir = "/ccg/co2c13/cals/%s/raw/%d/" % (caldata.system, year)
		co2o18dir = "/ccg/co2o18/cals/%s/raw/%d/" % (caldata.system, year)

		co2c13file = co2c13dir + datestr + "." + instid.lower() + ".co2c13"
		co2o18file = co2o18dir + datestr + "." + instid.lower() + ".co2o18"

		if not os.path.exists(co2c13file): co2c13file = None
		if not os.path.exists(co2o18file): co2o18file = None

		if co2c13file or co2o18file:
			return {"CO2":co2file, "CO2C13":co2c13file, "CO2O18":co2o18file}

	return {"CO2":co2file, "CO2C13":co2c13file, "CO2O18":co2o18file}


########################################################################
def getR13PDB(scale):
	""" Get the correct pdb value for the given scale.
	If no scale given use the X2019 value for the default
	"""

	if scale is None:
		return r13_PDB_X2019

	else:
		(sp, version) = scale.split("_")

		if version == "X2007" or version == "INSTAAR":
			return r13_PDB_X2007
		else:
			return r13_PDB_X2019

########################################################################
def calcProbability(d13c, d18o, r13_PDB=r13_PDB_X2007):
	"""
	Calculate probabilities for each isotopologue to use in calculation of total CO2

	This is a function because it's needed in ccg_nl.py and in calcCO2Isotopes function.

	For all equations assume:  d17o = 0.5 * d18o
	For all equations delta values are assigned delta values divided by 1000

	P626 = (1.0 / (1.0 + (r13_PDB *(1.0 + d13c)))) *
			( 1.0 / ( 1.0 + r17_PDB*(1.0 + d17o) + r18_PDB*(1.0 + d18o))^2 )

	P636 = ((r13_PDB * (1.0 + d13c)) ) / (1.0 + r13_PDB*(1.0 + d13c)) ) *
			( 1.0 / ( 1.0 + r17_PDB*(1.0 + d17o) + r18_PDB*(1.0 + d18o))^2 )

	P628 = 	(1.0 / (1.0 + (r13_PDB *(1.0 + d13c)))) *
			((2 * r18_PDB*(1.0 + d18o)) / (( 1.0 + r17_PDB*(1.0 + d17o) + r18_PDB*(1.0 + d18o))^2))

	P627 = 	(1.0 / (1.0 + (r13_PDB *(1.0 + d13c)))) *
			((2 * r17_PDB*(1.0 + d17o)) / (( 1.0 + r17_PDB*(1.0 + d17o) + r18_PDB*(1.0 + d18o))^2))

	For readability:
		c_denominator =  ( 1.0 + r13_PDB *(1.0 + d13c) )
		o_denominator =  ( 1.0 + r17_PDB*(1.0 + d17o) + r18_PDB*(1.0 + d18o) )

		simplified equations:
		P626 = [1.0 / c_denominator] * [1.0 / (o_denominator)^2]
		P636 = [(r13_PDB * (1.0 + d13c)) / c_denominator] * [1.0 / (o_denominator)^2 ]
		P628 = [1.0 / c_denominator] * [(2 * r18_PDB*(1.0 + d18o)) / (o_denominator)^2]
		P627 = [1.0 / c_denominator] * [(2 * r17_PDB*(1.0 + d17o)) / (o_denominator)^2]
	"""
	d17o = 0.528 * d18o # need d17o below

	c_denominator = 1.0 + (r13_PDB * (1.0 + d13c))
	o_denominator = 1.0 + (r17_PDB * (1.0 + d17o)) + (r18_PDB * (1.0 + d18o))
	o_denominator_2 = o_denominator**2

#	print("d13c = ", d13c)
#	print("d17o = ", d17o)
#	print("d18o = ", d18o)
#	print("c_denominator =", c_denominator)
#	print("o_denominator =", o_denominator)
#	print("o_denominator2=", o_denominator_2)


	P626 = (1.0 / c_denominator) * (1.0 / (o_denominator_2))
	P636 = ((r13_PDB * (1.0 + d13c)) / c_denominator) * (1.0 / (o_denominator_2))
	P628 = (1.0 / c_denominator) * ((2.0 * r18_PDB * (1.0 + d18o)) / (o_denominator_2))
	P627 = (1.0 / c_denominator) * ((2.0 * r17_PDB * (1.0 + d17o)) / (o_denominator_2))

	return P626, P636, P628, P627

########################################################################
#def calcCO2Isotopes(rawfile, caldata, co2respfile, c13respfile, o18respfile, debug):
def calcCO2Isotopes(rawfile, caldata, database=None, debug=False):
	""" for co2cal-2 system, which uses isotope measurements to get
	co2 value, we need to get corresponding raw files for
	co2c13, co2o18, and make necessary corrections to results.

	Input:
		rawfile - file name of raw file that is being processed.
		caldata - 'cal' class calibration data results from raw file 'rawfile'
		debug - If true, print extra information during calculations

	Output:
		cdata - A dict with 'cal' class results for 3 isotopes.  Keys are:
			'co2' - for co2 626
			'co2c13' - for co2 636
			'co2o18' - for co2 628

	"""

#	if caldata.scale == "CO2_X2019":
#		r13_PDB = r13_PDB_X2019
#	else:
#		r13_PDB = r13_PDB_X2007

	r13_PDB = getR13PDB(caldata.scale)

	# get raw files for other species for this calibration
	rawfilelist = getCO2RawFiles(rawfile, caldata)

	# define a dict to hold results for each species
	cdata = {"CO2": None, "CO2C13": None, "CO2O18": None}

	# point to results already calculated
	# Note, changing this will also change caldata, i.e. this just makes a pointer to caldata
	# this allows the processing of output options to still work correctly
	cdata[caldata.species] = caldata

	# create new cal class results for other species needed
	for species in list(cdata.keys()):
		if cdata[species] is None:
			rawfilename = rawfilelist[species]
			if debug: print("using raw file %s for %s" % (rawfilename, species))
			if rawfilename:
#				if species == "CO2C13":
#					rfile = c13respfile
#				elif species == "CO2O18":
#					rfile = o18respfile
#				elif species == "CO2":
#					rfile = co2respfile
#				cdata[species] = ccg_cal.Cal(rawfilename, responsefile=rfile, debug=debug)
				cdata[species] = ccg_cal.Cal(rawfilename, database=database, debug=debug)
			else:
				sys.exit("ERROR: No raw file found for %s" % species)
				pass  # what to do?

	if debug:
		print("results before isotope correction")
		for species in list(cdata.keys()):
			print(species, cdata[species].results)

	# loop over each sample tank, make corrections and convert isotopes to delta values
	# replace results with corrected values
	for name in cdata["CO2"].results:
		(x626, sd626, n626, flag626, unc626) = cdata["CO2"].results[name]
		(x636, sd636, n636, flag636, unc636) = cdata["CO2C13"].results[name]
		(x628, sd628, n628, flag628, unc628) = cdata["CO2O18"].results[name]

		# make isotope correction only within scale limits
		if x626 > CO2_SCALE_MINIMUM and x626 < CO2_SCALE_MAXIMUM and x636 > 0.0 and x628 > 0.0:
			# convert X636 mole fraction results into delta values, d13c not multiplied by 1000 so easier in equations below
			d13c = (x636 / (r13_PDB * x626)) - 1.0
			delta_13c = d13c * 1000.0

			# convert X628 mole fraction results into delta values, d18o not multiplied by 1000 so easier in equations below
			d18o = (x628 / (2.0 * r18_PDB * x626)) - 1.0
			delta_18o = d18o * 1000.0

			# calculate probabilities for each isotopologue to use in calculation of total CO2
			# Based on the actual measured d13C and d18o
			P626, P636, P628, P627 = calcProbability(d13c, d18o, r13_PDB)

			# use ratio of P627/P628 to determine the mole fraction of 627 for calculating total co2
			# X627 = X628 * (P627/P628)
			if P628 == 0:
				x627 = 0
			else:
				x627 = x628 * (P627 / P628)

			if debug:
				print("*** pdb vaues ", file=sys.stderr)
				print("R13_PDB: %15.12f" % r13_PDB, file=sys.stderr)
				print("R18_PDB: %15.12f" % r18_PDB, file=sys.stderr)
				print("*** Isotopologue probablilites calculated from delta values", file=sys.stderr)
				print("P626:  %15.12f" % P626, file=sys.stderr)
				print("P636:  %15.12f" % P636, file=sys.stderr)
				print("P628:  %15.12f" % P628, file=sys.stderr)
				print("P627:  %15.12f" % P627, file=sys.stderr)
				print("*** Isotopologue mole fractions measured (X627 is calculated, not measured)", file=sys.stderr)
				print("X626:  %15.5f  +- %15.5f" % (x626, sd626), file=sys.stderr)
				print("X636:  %15.5f  +- %15.5f" % (x636, sd636), file=sys.stderr)
				print("X628:  %15.5f  +- %15.5f" % (x628, sd628), file=sys.stderr)
				print("X627:  %15.5f" % x627, file=sys.stderr)


			# Total mole fraction CO2 = sum of measured isotopologues divided by sum of probablilities
			# to correct for unmeasured minor isotopologues
			# Xtotal = (X626 + X636 + X628 + X627) / (P626 + P636 + P628 + P627)
			xtotal = (x626 + x636 + x628 + x627) / (P626 + P636 + P628 + P627)
#			xtotal = round(xtotal, 3)

			# Calculate unc_delta by scaling unc in mole fraction measurements
			# add unc of minor and major isotopologues in quad then normalize to minor mole fraction.
			# Gives very low values, ***Check for better estimates for this unc value ***
			unc_delta_13c = sqrt((sd636/x636)**2 + (sd626/x626)**2) * delta_13c
			if x628 == 0:
				unc_delta_18o = 0
			else:
				unc_delta_18o = sqrt((sd628/x628)**2 + (sd626/x626)**2) * delta_18o

		else: ##here
			if debug:
				print("--- isotope correction not possible ---", file=sys.stderr)
				print("x626 =", x626, "x628 = ", x628, "x636 =", x636)
				print("-------")
			# calculate probabilities for each isotopologue to use in calculation of total CO2
			# Based on assumed atmospheric d13C and d18o ratios rather than measured values
			default_d13c = -8.5/1000.0
			default_d18o = -1.5/1000.0
			P626, P636, P628, P627 = calcProbability(default_d13c, default_d18o, r13_PDB)
			xtotal = x626 / P626
			delta_13c = -999.99
			unc_delta_13c = -99.99
			delta_18o = -999.99
			unc_delta_18o = -99.99

		# Put calculated values into results
		if debug:
			print("***", file=sys.stderr)
			print("delta_13c:  %12.4f      +-  %12.4f" % (delta_13c, unc_delta_13c), file=sys.stderr)
			print("delta_18o:  %12.4f      +-  %12.4f" % (delta_18o, unc_delta_18o), file=sys.stderr)

		cdata["CO2"].results[name] = (xtotal, sd626, n626, flag626, unc626)
		cdata["CO2C13"].results[name] = (delta_13c, unc_delta_13c, n636, flag636, unc636)
		cdata["CO2O18"].results[name] = (delta_18o, unc_delta_18o, n628, flag628, unc628)


	if debug:
		print("results after isotope correction")
		for species in list(cdata.keys()):
			print(species, cdata[species].results)

	return cdata
