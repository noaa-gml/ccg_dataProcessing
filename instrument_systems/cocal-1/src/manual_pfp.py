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

# Create a RunAction class instance to use in all the modes
action = RunAction(actiondir=config.ACTIONDIR, configfile=config.CONFFILE, testMode=config.testmode)



import subprocess


sampledata = {
        "manifold" : "A",
        "port_num"  : 1,
        "serial_num" : "3078-FP",
        "sample_type" : "NA",    # reset this field for each internal mode
        "sample_num"  : 1,
        "sample_id"   : "NA",
        "event_num"   : None,
        "analysis_id" : None,
        "pressure"    : "NA",
        "regulator"   : "NA",
        "sample_id_num" : -9
        }

ACTIVATE=False
DE_ACTIVATE=False
GET_ID=False
OPEN=False
CLOSE=False

if ACTIVATE:
	 # activate port - ONLY ACTIVATE ONCE AT THE START 
	de_activate_ports(action, sampledata["manifold"])
	#de_activate_ports(action, "B")
	activate_port(action, sampledata["manifold"], sampledata["port_num"])


if GET_ID:
	# check pfp serial number on first flask analysis only
	print("Checking pfp serial number ...")
	(pfp_check, listed_sn, actual_sn) = getPFPID(action, sampledata["manifold"],
		sampledata["port_num"], sampledata["serial_num"])
	print("Check pfp serial number: Listed: %s    Actual: %s" % (listed_sn, actual_sn))


if OPEN:
	#open pfp flask
	print("opening pfp valve")
	open_check = open_as_sample(action, sampledata["manifold"], sampledata["port_num"],
		sampledata["serial_num"], sampledata["sample_num"])

if CLOSE:
	# close pfp flask valve (returns True for successful, False for close error)
	print("close pfp valve")
	close_check = close_as_sample(action, sampledata["manifold"], sampledata["port_num"],
		sampledata["serial_num"], sampledata["sample_num"])



if DE_ACTIVATE:
	de_activate_ports(action, sampledata["manifold"])




