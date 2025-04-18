##!/usr/bin/python




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
import shutil

from lock_file import LockFile, LockError
from runaction import *

#utils.py contains many functions used here
#import utils_v15 as utils
import utils
import config

# get routine for reading hm resources
from resources import get_resources







######################################################################
# Start of things

os.chdir(config.HOMEDIR)


# Hardcode save=False for testing, save=True to write files.
save=False

# Hardcode systems and gases to process
syslist = ["picarro","aerodyne"]
sysgases = {"picarro":["CO2"], "aerodyne":["CO2","CO2C13","CO2O18"]}

# Hardcode timestamps of file A and B. Set starttime to equal timestamp_b to match what would have happened during a run.
last_timestamp = "2022-12-12.0754"
current_timestamp = "2022-12-13.0936"

# special post processing to combine the two primary rawfile into a single one and archive the individual ones.
(current_d, current_t) = current_timestamp.split('.')
(current_yr, current_mo, current_dy) = current_d.split('-')
current_hr = current_t[0:2]
current_mn = current_t[2:4]
current_dt = datetime.datetime(int(current_yr), int(current_mo), int(current_dy), int(current_hr), int(current_mn))

combined_time = current_dt + datetime.timedelta(minutes=60)
combined_timestamp = "%4d-%02d-%02d.%02d%02d" % (combined_time.year, combined_time.month, combined_time.day, combined_time.hour, combined_time.minute)





for instrument in syslist:
	print >> sys.stderr, "instrument: %s" % instrument
	(inst_id, sernum) = utils.get_instrument_id(instrument)
	print >> sys.stderr, "inst_id: %s" % inst_id
	for sp in sysgases[instrument]:
		#print >> sys.stderr, "sp: %s" % sp 
		#print >> sys.stderr, "combining raw files for inst: %s   sp: %s" % (inst_id, sp.upper())
		#ShowStatus("combining raw files for inst: %s   sp: %s" % (inst_id, sp.upper()))

		if sp.lower() == "h2" or sp.lower() == "sf6":
			data_file_extension = "zip"
		else:
			data_file_extension = "dat"


		#set name and directory paths to each individual rawfiles
		raw_dir = "/ccg/%s/nl/%s/raw/%4d" % (sp.lower(), config.SYSTEM.lower(), current_yr)
		qc_dir = "/ccg/%s/nl/%s/qc/%4d" % (sp.lower(), config.SYSTEM.lower(), current_yr)
		data_dir = "/ccg/%s/nl/%s/data/%4d" % (sp.lower(), config.SYSTEM.lower(), current_yr)

		current_raw_filename = "%s.%s.%s" % (current_timestamp, inst_id.lower(), sp.lower())
		current_qc_filename = "%s.qc" % (current_raw_filename)
		current_data_filename = "%s.%s" % (current_raw_filename, data_file_extension.lower())

		last_raw_filename    = "%s.%s.%s" % (last_timestamp, inst_id.lower(), sp.lower())
		last_qc_filename = "%s.qc" % (last_raw_filename)
		last_data_filename = "%s.%s" % (last_raw_filename, data_file_extension.lower())

		#set up filename for combined files ( Initially this is local so doesn't overwrite existing files)
		combined_raw_filename = "%s.%s.%s" % (combined_timestamp, inst_id.lower(), sp.lower())
		combined_qc_filename = "%s.qc" % (combined_raw_filename)
		combined_data_filename = "%s.%s" % (combined_raw_filename, data_file_extension.lower())

		if not save:
			# for testing, prints to terminal
			combined_raw_filename = None
			combined_qc_filename = None
			combined_data_filename = None

		# make sure backup directory exists
		backupdir = "%s/backup/nl/" % (os.environ["HOME"])
		if not save:
			if not os.path.isdir(backupdir):
				os.makedirs(backupdir)


		########################### 
		#Returns the path of the saved combined file is successful -- def combine_nl_rawfiles(file1, file2, savefile = None, qc = False):
		savefile = utils.combine_nl_rawfiles("%s/%s" % (raw_dir,last_raw_filename), "%s/%s" % (raw_dir,current_raw_filename), savefile = combined_raw_filename, qc=False)
		
		if save:
			# remove individual entries in table - CHANGE TO FLAG ONCE NEW CODE AND DB TABLE GOES INTO SERVICE
			os.system("/ccg/bin/nlpro.py --delete %s/%s" % (raw_dir, current_raw_filename))
			os.system("/ccg/bin/nlpro.py --delete %s/%s" % (raw_dir, last_raw_filename))

			# copy combined file to /ccg and to local backup (local backup has "combined" suffix so will not overwrite existing file
			shutil.copy(combined_raw_filename, raw_dir)
			os.rename(combined_raw_filename, "%s/%s" % (backupdir, combined_raw_filename))

			#process combined file   # os.system("/ccg/bin/nlpro.py -u %s" % (rawfile))
			os.system("/ccg/bin/nlpro.py -u %s/%s" % (raw_dir, combined_raw_filename))



		##########################
		### QCfiles
		#combine qcfiles 
		savefile = utils.combine_nl_rawfiles("%s/%s" % (qc_dir,last_qc_filename), "%s/%s" % (qc_dir,current_qc_filename), savefile = combined_qc_filename, qc=True)

		if save:
			# copy combined file to /ccg and to local backup
			shutil.copy(combined_qc_filename, qc_dir)
			os.rename(combined_qc_filename, "%s/%s" % (backupdir, combined_qc_filename))


		##########################
		#### DATA files - handle .zip files for GC species
		#combined_data_filename = "%s.%s" % (combined_raw_filename, data_file_extension.lower())
		if save:
			# make temp data directory
			temp_data_dir = "%s/temporary_data" % (os.environ["HOME"])
			if not os.path.isdir(temp_data_dir):
				os.makedirs(temp_data_dir)
			# make sure temp directory is empty
			for fn in os.listdir(temp_data_dir):
				os.remove(os.path.join(temp_data_dir, fn))

			#copy data files to local temp directory
			shutil.copy("%s/%s" % (data_dir, last_data_filename), "%s/%s" % (temp_data_dir, last_data_filename))
			shutil.copy("%s/%s" % (data_dir, current_data_filename), "%s/%s" % (temp_data_dir, current_data_filename))

			if data_file_extension == "zip":
				#open local last_data_file for appending, current_data_file for reading
				z_combined = zipfile.ZipFile("%s/%s" % (temp_data_dir, combined_data_filename), 'a')
				z1 = zipfile.ZipFile("%s/%s" % (temp_data_dir, last_data_filename), 'r')
				z2 = zipfile.ZipFile("%s/%s" % (temp_data_dir, current_data_filename), 'r')

				#add members of current_data_filename to last_data_filename
				for n in z1.namelist():
					z1.extract(n, temp_data_dir)
					z_combined.write(n, n, zipfile.ZIP_DEFLATED)

				for n in z2.namelist():
					z2.extract(n, temp_data_dir)
					z_combined.write(n, n, zipfile.ZIP_DEFLATED)

				z_combined.close()
				z1.close()
				z2.close()
			else:
				# open combined_data_filename for appending, current_data_filename for reading
				f_combined = open("%s/%s" % (temp_data_dir, combined_data_filename),"a")
				f1 = open("%s/%s" % (temp_data_dir, last_data_filename),"r")
				f2 = open("%s/%s" % (temp_data_dir, current_data_filename), "r")

				for line in f1:
					f_combined.write(line)

				for line in f2:
					f_combined.write(line)

				f_combined.close()
				f1.close()
				f2.close()

			# copy combined file to /ccg and to local backup
			shutil.copy("%s/%s" % (temp_data_dir, combined_data_filename), data_dir)
			os.rename("%s/%s" % (temp_data_dir, combined_data_filename), "%s/%s" % (backupdir, combined_data_filename))



