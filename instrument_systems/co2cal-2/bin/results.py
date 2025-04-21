#!/usr/bin/python

import sys
import os

sys.path.append("%s/src/python" % os.environ["HOME"])
sys.path.append(os.environ["HOME"])
sys.path.append("/ccg/src/python/lib")

import datetime
import subprocess
import signal
import atexit
import logging
import collections
import dbutils

from lock_file import LockFile, LockError
from runaction import *

from utils import *

home = os.environ["HOME"]

HOMEDIR = home                       # Our home


######################################################################
def get_mode():

        try:
                f = open("sys.setup")
                s = f.readline()
                f.close()
                (junk, mode) = s.split()
                mode = int(mode)
                return mode
        except:
                return 1

######################################################################
# Determine which systems are to be used
# gaslist will hold system names, 
# processlist will hold gases that will be processed when finishing
######################################################################
def get_systems():

        syslist = []
        sysgases = {}

        try:
                f = open("sys.setup")
        except:
                return ["picarro"], {"picarro":"CO2"}

        for line in f:
                if "Cal_System" in line:
                        (a, systems) = line.split(":")
                        (sysname, gasstr) = systems.split("-")
                        sysname = sysname.strip()
                        sysname = sysname.lower()
                        gases = gasstr.strip().split()
                        sysgases[sysname] = gases

        f.close()

        # make sure syslist is in proper order of system names
        # i.e., can't use sysgases.keys() because they might not be in correct order.
        for name in ["picarro", "lgr", "aerodyne"]:
                if name.lower() in sysgases: syslist.append(name.lower())

        if len(syslist) == 0:
                return ["picarro"], {"picarro":"CO2"}
        else:
                return syslist, sysgases


######################################################################
def default_results():

	tempfile = "display_results_tempraw"
	for inst in syslist:

			print "Data from instrument %s" % (inst)
			print "---------------------------------------"
			fn = "data.%s" % (inst.lower())
			try:
				fp = open(fn)
			except:
				results = "No data available"
				print results
				return

#REF R0 2016 03 28 08 35 38     390.6734       0.0128 34       0.0000       0.0000 0       0.0011       0.0004 11  140.0012   0.0099 45  44.9
#998   0.0001 45  42.6232   0.0083 45  45.0103   0.0001 45  44.9996   0.0001 45    150.12    758.39     23.18     20.7

			if inst.lower() == "picarro":
				print "type id yr  mo dy hr mn sc co2     co2_sd co2_n ch4 ch4_sd ch4_n cellP  cellT   flow  sampleP roomT chillerT"
				for line in fp:
					(type, id, yr, mo, dy, hr, mn, sc, 
						co2, co2_sd, co2_n, 
						ch4, ch4_sd, ch4_n,
						j, j, j, 
						cellP, cellP_sd, cellP_n, 
						cellT, cellT_sd, cellT_n, 
						j,j,j,
						j,j,j,
						j,j,j,
						flow, sampleP, roomT, chillerT) = line.split()

					print "%3s %4s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (type, id, yr, mo, dy, hr, mn, sc, 
						co2, co2_sd, co2_n,ch4,ch4_sd,ch4_n,cellP,cellT,flow,sampleP,roomT,chillerT)

			if inst.lower() == "lgr":
				print "type id yr   mo dy hr mn sc 636 636_sd 636_n 628 628_sd 628_n cellP   cellT   flow sampleP roomT chillerT"
				for line in fp:
					(type, id, yr, mo, dy, hr, mn, sc,
						j,j,j, 
						j,j,j, 
						j,j,j, 
						j,j,j, 
						cellP, cellP_sd, cellP_n,
						cellT, cellT_sd, cellT_n,
						j,j,j,
						flow, sampleP, roomT, chillerT,
						j,j,j,
						co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n,
						co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n) = line.split()
					print "%3s  %4s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (
						type, id, yr, mo, dy, hr, mn, sc, 
						co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n,
						co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n,
						cellP, cellT, flow, sampleP, roomT, chillerT)

			if inst.lower() == "aerodyne":
#REF R0 2016 01 22 15 25 47    389.21363690      0.02312058 31     4.41683633      0.00019642 31     1.61991055      0.00006754 31     0.31163449      0.00006760 31    294.1828       0.0022 31     19.9980       0.0026 31    155.57    790.82     24.79

				print "type id yr   mo dy hr mn sc 636 636_sd 636_n 628 628_sd 628_n cellP   cellT   flow sampleP roomT chillerT"
				for line in fp:
					(type, id, yr, mo, dy, hr, mn, sc,
						co2_626_ppm, co2_626_ppm_sd, co2_626_ppm_n,
						co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n,
						co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n,
						co2_627_ppm, co2_627_ppm_sd, co2_627_ppm_n,
						cellT, cellT_sd, cellT_n, 
						cellP, cellP_sd, cellP_n, 
						flow, sampleP, roomT, chillerT) = line.split()

					print "%3s  %4s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (
						type, id, yr, mo, dy, hr, mn, sc, 
						co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n,
						co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n,
						cellP, cellT, flow, sampleP, roomT, chillerT)

			fp.close()

			print "   "	


######################################################################
def tankcal_results():
	
	tempfile = "display_results_tempraw"
	#filenames = ["%s.co2" % tempfile, "%s.co2c13" % tempfile, "%s.co2o18" % tempfile]
	#for fn in filenames:
	#	if os.path.isfile(fn):		
	#		os.system("rm "+fn)

	for inst in syslist:
		tempfile = "display_results_tempraw_%s" % inst.lower()
		cmd = "bin/makeraw --type=cals --inst=%s --basefilename=%s" % (inst, tempfile)
		os.system(cmd)

	#for inst in syslist:
		for sp in sysgases[inst]:
			fn = "%s.%s" % (tempfile, sp.lower())
			if os.path.isfile(fn):		
				#os.system("/ccg/bin/calpro.py -t  "+fn+" 2>/dev/null")
				os.system("/ccg/src/python3/calpro.py -t  "+fn+" 2>/dev/null")



######################################################################
# Start of things

os.chdir(HOMEDIR)

# Get starting mode from sys.setup
mode = get_mode()

syslist, sysgases = get_systems()

if   mode == 1: default_results()
elif mode == 2: tankcal_results()
elif mode == 3: default_results()
elif mode == 4: default_results()
elif mode == 5: default_results()
elif mode == 6: default_results()
elif mode == 7: default_results()
elif mode == 8: default_results()
elif mode == 9: default_results()
elif mode == 10: default_results()
elif mode == 11: default_results()

else:
        sys.exit("Unknown mode number %d" % mode)



