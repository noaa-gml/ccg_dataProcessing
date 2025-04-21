#!/usr/bin/python

import sys
import os

home = os.environ["HOME"]
sys.path.append("%s/src" % home)
sys.path.append("%s/src/hm" % home)

import datetime
import signal
import atexit
import logging
import time
import collections

from lock_file import LockFile, LockError
from runaction import *

from common import *
import config
#import modes
import utils

# get routine for reading hm resources
#from resources import get_resources

# open connection to database file that has the sample information
import magiccdb 
db_filename = 'magicc.db'
# db_filename = config.databasefile # could put this in config.py instead
magiccdb = magiccDB(db_filename)






######################################################################
# Start of things

os.chdir(config.HOMEDIR)

#single manual change
a_id = 1
#magiccdb.mark_ready(a_id)
magiccdb.mark_error(a_id)

# list of manual changes
#a_id_list = (99,100,101,102,103,104,105,106)
#for a_id in a_id_list:
#	print >> sys.stderr, "a_id: %s" % a_id
#	# mark DB entry as "ready"
#	magiccdb.mark_ready(a_id)
#	#magiccdb.mark_not_ready(a_id)
#	#magiccdb.mark_error(a_id)


# mark DB entry as "error"
#magiccdb.mark_error(a_id)

# get analysis info
#data = magiccdb.get_analysis_info()
#for n, line in enumerate(data):
#	#if line[12].lower() != "complete" and line[12].lower() != "error":
#	if line[12].lower() == "error":
#		print "n=%s  line[0]: %s" % (n, line[0])
		
		#for i in range(len(line)):
		#	print "n=%s  line[%s]: %s" % (n, i, line[i])

## manually add entry
##sample_info = (manifold, port, flaskid, sample_type, num_aliquots, pressure, regulator)
##analysis_info = (sample_number, flaskid, eventnum)
## sampledata =[manifold, port, id, eventnum]
#
#sample_type = "flask"
#num_aliquots = 1
#pressure = ""
#regulator = ""
#sample_number = 1
#
#sampledata = ["B","1","3030-99","462438"]
#sample_info = (sampledata[0], sampledata[1], sampledata[2], sample_type, num_aliquots, pressure, regulator)
#analysis_info = (sample_number, sampledata[2], sampledata[3])
#rowid = magiccdb.insert_entry(sample_info, analysis_info)
#
#sampledata = ["B","3","2076-99","462434"]
#sample_info = (sampledata[0], sampledata[1], sampledata[2], sample_type, num_aliquots, pressure, regulator)
#analysis_info = (sample_number, sampledata[2], sampledata[3])
#rowid = magiccdb.insert_entry(sample_info, analysis_info)
#
#sampledata = ["B","5","2504-99","462435"]
#sample_info = (sampledata[0], sampledata[1], sampledata[2], sample_type, num_aliquots, pressure, regulator)
#analysis_info = (sample_number, sampledata[2], sampledata[3])
#rowid = magiccdb.insert_entry(sample_info, analysis_info)
#
#sampledata = ["B","7","2521-99","462436"]
#sample_info = (sampledata[0], sampledata[1], sampledata[2], sample_type, num_aliquots, pressure, regulator)
#analysis_info = (sample_number, sampledata[2], sampledata[3])
#rowid = magiccdb.insert_entry(sample_info, analysis_info)


