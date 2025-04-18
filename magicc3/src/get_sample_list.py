#!/usr/bin/python

import sys
import os

home = os.environ["HOME"]
sys.path.append("%s/src" % home)
sys.path.append("%s/src/hm" % home)

import datetime
import getopt

from common import *

# open connection to database file that has the sample information
import magiccdb 
db_filename = 'magicc.db'
# db_filename = config.databasefile # could put this in config.py instead
magiccdb = magiccDB(db_filename)

READY = False
ERROR = False
















########################################################################
def usage():
    print("""
    Usage:
      get_sample_list.py

      prints sample list to screen 

     where
            -r - only print samples marked 'ready'
            -e - only print samples marked 'error'
            -v - verbose output
            -h - print a help message

     
    """)

# Get the command-line options
try:
        opts, args = getopt.getopt(sys.argv[1:], "hrev" )
except getopt.GetoptError as err:
        # print help information and exit:
        print(( str(err))) # will print something like "option -a not recognized"
        usage()
        sys.exit()

for o, a in opts:
    if o == "-v": debug = True
    elif o == "-r": READY = True
    elif o == "-e": ERROR = True
    elif o in ("-h", "--help"):
        usage()
        sys.exit()
    else:
        assert False, "unhandled option"



######################################################################
# Start of things

os.chdir(config.HOMEDIR)


# get list of sample data
rows = magiccdb.get_analysis_info()

for line in rows:
    if READY:
        if line[12].lower() != "ready" and line[12].lower() != "not_ready": continue
    if ERROR:
        if line[12].lower() != "error": continue

    print(("a_id: %5s  manifold: %1s port: %2s  sample_type: %10s sample_id: %10s   status: %s" % (line[0], line[2], line[3], line[5], line[4], line[12])))




if not ERROR:
    MINUTES_PER_SAMPLE = 7.2
    regulator_flush_time = 3.2
    sys_evac_time = 1.9
    process_data_time = 0.5

    data = magiccdb.get_analysis_info()
    ntodo = 0
    extra_time = 0.0
    previous_sample_type = ""
    previous_info_id = "-1"

    for n, line in enumerate(data):
        if line[12].lower() != "complete" and line[12].lower() != "error":
            ntodo += 2
            #if switch sample type, add an extra reference shot
            if line[5] != previous_sample_type:
                ntodo += 1
                extra_time += process_data_time

            #if sample type equal cal, add extra ref shot for each sample tank switch
            # and add in 3 minute regulator flush. If previous sample_type = cal then add another ref shot
            if line[5].upper() == "CAL" and line[1] != previous_info_id:
                extra_time += regulator_flush_time # regulator flush
                extra_time += sys_evac_time  # extra system evacuation when switching
                if previous_sample_type == "CAL":
                    ntodo += 1
                    extra_time += process_data_time

            # add regulator flush time for each standard in response curve
            if line[5].upper() == "NL" and line[1] != previous_info_id:
                extra_time += 3.2 # regulator flush

            previous_sample_type = line[5]
            previous_info_id = line[1]

            #add final ref shot
            if n == len(data):
                ntodo += 1


    if ntodo == 0:
        print("\nEstimated finish time: COMPLETED")

    else:
        #print >> sys.stderr, "ntodo: %s" % ntodo
        #print >> sys.stderr, "extra time: %s" % extra_time
        now = datetime.datetime.now()
        td = datetime.timedelta(minutes=MINUTES_PER_SAMPLE*ntodo+extra_time)
        s = now + td
        print(("\nEstimated finish time: %s" % s.strftime("%c")))


