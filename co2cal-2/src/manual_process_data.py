
import sys
import datetime
import logging
import time
#from multiprocessing import Process, Queue
import multiprocessing

import config
sys.path.append("%s/src" % config.HOMEDIR)
sys.path.append("%s/src/hm" % config.HOMEDIR)

from common import *
from runaction import *
import utils


########################################################
# CHANGE THIS SECTION TO REFLECT ACTUAL DATA TO BE RECOVERED
#
syslist = ["gc1","gc2","aerodyne","picarro"] # change when needed
sysgases = {"picarro":["CO2","CH4"], "aerodyne":["N2O","CO"], "gc1":["SF6"], "gc2":["H2"]} #change when needed

stdset = 'normal_range'

runtype = "pfp" # change for type sample processing
#runtype = "flask" # change for type sample processing
#runtype = "nl" # change for type sample processing
#runtype = "cals" # change for type sample processing

# for cals, make changes here
current_sampledata = {
        "manifold" : "B",
        "port_num"  : "11",
        "serial_num" : "CA01234",
        "sample_type" : "cal",    
        "sample_num"  : 1,
        "sample_id"   : "W",
        "event_num"   : "NA",
        "analysis_id" : None,
        "pressure"    : "NA",
        "regulator"   : "NA",
        "sample_id_num" : -9
        }
########################################################
########################################################
########################################################


if runtype.lower() == "flask" or runtype.lower() == "pfp":
	#process flask/pfp data
	for inst in syslist:
		ShowStatus("Updating files for %s" % (inst))
		update_files(inst, sysgases, "flask")
	
	# update files for system qc (after flask)
	inst = "QC"
	ShowStatus("Updating files for %s" % (inst))
	update_files(inst, sysgases, "flask")

	# run flask flagging program
	for inst in syslist:
		ShowStatus("Run auto-flagging routine for files from %s" % (inst))
		run_auto_flag(inst, sysgases, "flask")


elif runtype.lower() == "cal":
	#process tankcal data
	for inst in syslist:
		ShowStatus("Updating files for %s" % (inst))
		update_files(inst, sysgases, "cals", serialnum=current_sampledata["serial_num"],
			manifold=current_sampledata["manifold"], portnum=current_sampledata["port_num"],
			pressure=current_sampledata["pressure"], regulator=current_sampledata["regulator"])
	
	# update files for system qc
	inst = "QC"
	ShowStatus("Updating files for %s" % (inst))
	update_files(inst, sysgases, "cals", serialnum=current_sampledata["serial_num"],
			pressure=current_sampledata["pressure"], regulator=current_sampledata["regulator"],
			manifold=current_sampledata["manifold"], portnum=current_sampledata["port_num"])


elif runtype.lower() == "nl":
	# Create non-linearity raw and data files
	for inst in syslist:
		ShowStatus("Updating files for %s" % (inst))
		update_files(inst, sysgases, "nl", stdset )

	# update files for system qc
	inst = "QC"
	ShowStatus("Updating files for %s" % (inst))
	update_files(inst, sysgases, "nl", stdset )


