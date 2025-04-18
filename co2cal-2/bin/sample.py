#!/usr/bin/python
# Script for controlling sample measurement for gc.
# This is called after sample loop has been flushed.
#
# calling syntax:
#   sample.py sys port type storegc
#
# where sys is the system name, 'co2', 'ch4', 'co', 'n2o'
#       port is the port number to sample from
#       type is sample type, either 'SMP' or 'REF'
#  	storegc is 0 or 1, whether to save chromatogram file 
#	   in zip archive or not. 0 - don't save, 1 - save.

import sys
import os

sys.path.append("%s/src/python" % os.environ["HOME"])
sys.path.append("%s" % os.environ["HOME"])

import logging

from utils import *
from runaction import *

home = os.environ["HOME"]

HOMEDIR    = home                       # Our home
LOGFILE    = HOMEDIR + "/ch4cal.log"    # log file
CONFFILE   = HOMEDIR + "/ch4cal.conf"   # hm configuration file
ACTIONDIR  = HOMEDIR + "/actions"       # Action directory
LOCKFILE   = HOMEDIR + "/.pid"          # lock file for this process
LOGLEVEL   = logging.DEBUG              # change to logging.INFO for normal operation
LOGFORMAT  = "%(levelname)-8s: %(asctime)s %(message)s"

logging.basicConfig(filename=LOGFILE, level=LOGLEVEL, format=LOGFORMAT)

# Create a RunAction class instance
action = RunAction(actiondir=ACTIONDIR, configfile=CONFFILE)

try:
	system = sys.argv[1].lower()
	port = sys.argv[2]
	type = sys.argv[3]
	storegc = int(sys.argv[4])	 # 0 or 1
except:
	print >> sys.stderr, "Usage: sample.py sys port type storegc"
	sys.exit()

gcfile = "gc.%s.txt" % system


if system == "ch4":
	action.run("sample_ch4.act", gcfile, port)
	process_gc("ch4", gcfile, type)
	if storegc:
		archive_gcfile(system, gcfile)

else:
	print >>sys.stderr, "Unknown system in sample script: %s" % system
	logging.error("Unknown system in sample script: %s" % system)

