##!/usr/bin/python

# manually process data NEEDS TO BE UPDATED ******************************

import sys
import os

sys.path.append("%s/src/python" % os.environ["HOME"])
sys.path.append("%s/src/python/hm.v1.2" % os.environ["HOME"])
sys.path.append("/ccg/src/python/lib")

import dbutils
import datetime
import subprocess
import signal
import atexit
import logging
import time

from lock_file import LockFile, LockError
from runaction import *

#utils.py contains many functions used here
from utils import *
import config

# get routine for reading hm resources
from resources import get_resources



######################################################################
# Get a value from the sys.setup file.
# The file has lines of "key: value" pairs. Return the value given the
# 'key' string.
######################################################################
def get_setup_value(key):

	try:
		f = open("sys.setup")
	except:
		return None

	value = []
	for s in f:
		(label, val) = s.split(':')
		label = label.strip()
		val = val.strip()
		if label == key:
			value.append(val)
	f.close()

	return value



######################################################################
# Determine which systems are to be used
# gaslist will hold system names, 
# processlist will hold gases that will be processed when finishing
######################################################################
def get_systems():

	syslist = []
	sysgases = {}

#Cal_System: Picarro - CO2
#Cal_System: Aerodyne - CO2C13 CO2O18 CO2

        s = get_setup_value("Cal_System")

	if s:
		for line in s:
			(sysname, gasstr) = line.split("-")
			sysname = sysname.strip()
			sysname = sysname.lower()
			gases = gasstr.strip().split()
			sysgases[sysname] = gases
	else:
		return ["picarro"], {"picarro":["CO2"]}


	# make sure syslist is in proper order of system names
	# Need isotope files in place before processing total co2
	# i.e., can't use sysgases.keys() because they might not be in correct order.
	for name in ["lgr", "aerodyne","picarro"]:
		if name.lower() in sysgases: syslist.append(name.lower())

	if len(syslist) == 0:
		return ["picarro"], {"picarro":["CO2"]}
	else:
		return syslist, sysgases


		sampletanks = getSampleList(samplestring)


##############################################################
def update_files(inst, caltype, stdset, serialnum="", pressure="", regulator="", manifold="", 
		portnum="", primary_key="" ):
	""" Save data to files for tank cals and response curves """

	# get instrument code
	inst_id, sernum = get_instrument_id(inst)

	system = "co2cal-2"

	# make each gas species raw file
	for sp in sysgases[inst]:
		rawfile = get_rawfile_name(sp, inst_id)

		make_raw(system, inst, caltype, qc=False, gas=sp, rawfile=rawfile, stdset=stdset,
		    serialnum=serialnum, pressure=pressure, regulator=regulator, valvename=manifold, portnum=portnum)
	

		#def save_files(type, system, inst_id, gas, rawfile, data=False, qc=False ):	
		save_files(caltype,system, inst, sp, rawfile)

	for sp in sysgases[inst]:
		rawfile = get_rawfile_name(sp, inst_id)
		year = int(rawfile[0:4])

		# if tank cal and sp=co2 and instrument is isotope analyzer, don't process total co2
		if sp.upper() == "CO2" and inst.upper() != "PICARRO" and caltype.upper() == "CALS":  continue

		#process_filename = "/ccg/%s/%s/%s/raw/%d/%s" % (sp.lower(), caltype, inst_id.upper(), year, rawfile)
		process_filename = "/ccg/%s/%s/%s/raw/%d/%s" % (sp.lower(), caltype, system.lower(), year, rawfile)
		process_data(caltype, process_filename, stdset)
		#second process step to test new scale
		#scale_test_process_data(caltype, sp, process_filename, stdset)
		

	if caltype == "nl":
		# write most recent nl timestamp to file
		timestamp = get_rawfile_name()
		write_last_nl_timestamp(timestamp)


	# qc raw file
	for sp in sysgases[inst]:
		qcrawfile = get_rawfile_name(sp, inst_id) + ".qc"
		make_raw(system, inst, caltype, qc=True, gas=sp, rawfile=qcrawfile, stdset=stdset,
		    serialnum=serialnum, pressure=pressure, regulator=regulator, valvename=manifold, portnum=portnum)
		save_files(caltype, system, inst, sp, qcrawfile, qc=True)

	# data file
	current_fn = "data.%s" % inst.lower()
	for sp in sysgases[inst]:
		datafile = get_rawfile_name(sp, inst_id) + ".dat"
		os.system("cp "+current_fn+" "+datafile)
		save_files(caltype, system, inst, sp, datafile, data=True)


##############################################################
# Mode 2, Tankcals
# Compare reference gases with the standards
# Pass in the standard set to use.
##############################################################
def tankcal():
        """
	process tank cal
        """
 	# hard code tank info here	
	stdset='secondary'
	sn = 'CA02827'
	press = 1925
	reg='26'
	manifold='ManifoldA'
	port='9'

	for inst in syslist:
		ShowStatus("Updating files for %s" % (inst))
		update_files(inst, "cals", stdset, serialnum=sn, pressure=press, regulator=reg, manifold=manifold, portnum=port)
		#def update_files(inst, caltype, stdset, serialnum="", pressure="", regulator="", manifold="", 
		#portnum="", primary_key="" ):


##############################################################
# Mode 3, Response Curves
# Compare reference gases with the standards
# Pass in the standard set to use.
##############################################################
def resp_curve(stdset, gas="CO2"):
        """
        Response Curves using secondary standards or one of the two sets of
        Primary standards or manual set of standards

        """


        # Create non-linearity raw and data files
	for inst in syslist:
		ShowStatus("Updating files for %s" % (inst))
		update_files(inst, "nl", stdset )




######################################################################
# Start of things

os.chdir(config.HOMEDIR)

# read conf file
devices, resources = get_resources(config.CONFFILE)


# Determine which systems are to be used
syslist, sysgases = get_systems()


# execute the correct mode function
# These mode numbers must agree with what is in sys.modes file
#hardcode mode
mode = 2



if   mode == 1: pre_analysis_check()
elif mode == 2: tankcal()
elif mode == 3: resp_curve("secondary", gas=sysgases['picarro'][0])
elif mode == 4: primary_response_curve(gas=sysgases['picarro'][0])
elif mode == 5: single_shot("ref")
elif mode == 6: single_shot("smp")
elif mode == 7: continuous_shot()
elif mode == 8: test_mode()
elif mode == 9: resp_curve("manual")
elif mode == 10: resp_curve("non-wmo_low")
elif mode == 11: resp_curve("non-wmo_high")

else:
	sys.exit("Unknown mode number %d" % mode)


