#!/usr/bin/python

# code to prep manifolds for flasks analysis

import sys
import os
import datetime
import logging
import time

import config
sys.path.append("%s/src" % config.HOMEDIR)
sys.path.append("%s/src/hm" % config.HOMEDIR)

from lock_file import LockFile, LockError
from runaction import *
from utils import ShowMessage, getSysRunning
from common import ShowStatus

home = os.environ["HOME"]


logging.basicConfig(filename=config.LOGFILE, level=config.LOGLEVEL, format=config.LOGFORMAT)

# Create a RunAction class instance to use in all the modes
action = RunAction(actiondir=config.ACTIONDIR, configfile=config.CONFFILE, testMode=config.testmode)

# open connection to database file that has the sample information
from magiccdb import *
db_filename = 'magicc.db'   
# db_filename = config.databasefile # could put this in config.py instead
magiccdb = magiccDB(db_filename)


############################################################################
# Start

ShowStatus("Start manifold prep")

manifolds = []
to_prep = []
index_to_skip = []  

# get list of manifolds and flasks to prep
rows = magiccdb.get_analysis_info()
#output = analysis_id, rowid, manifold, port, serial_num, sample_type, 
#       num_samples, pressure, regulator, sample_num, flask_id, event_num, status, adate 

for line in rows:
    #for nn, ll in enumerate(line):
    #   print >> sys.stderr, "line[%s]: %s" % (nn, ll)
    #print line

    if line[5].upper() == "FLASK" and line[12].upper() == "NOT_READY":
        to_prep.append(line)
        if line[2].upper() not in manifolds:
            manifolds.append(line[2].upper())
#testing loop
#print >> sys.stderr, "here"
#for line in to_prep:
#   print >> sys.stderr, line
#   for nn, ll in enumerate(line):
#       print >> sys.stderr, "line[%s]: %s" % (nn, ll)
#sys.exit()
#end testing loop

# loop through each manifold and prep flask ports
for manifold in manifolds:
    ShowStatus("Start manifold prep:  Manifold%s" % manifold)
    # turn manifold to first position
    action.run("turn_multiposition.act", "Manifold%s" % manifold, "@Manifold%s_off" % manifold) 
    time.sleep(3)   
    
    # turn manifold_evac to evac
    action.run("turn_multiposition.act", "Manifold%s_Evac" % manifold, "@evac_on") 
    time.sleep(3)   

    for line in to_prep:
        if line[2].upper() == manifold.upper():
            ShowStatus("Evacuating flask:  manifold%s, port %s, id %s, event_num %s" % (manifold, line[3], line[4], line[11]))
            #print("!!!Evacuating flask:  manifold%s, port %s, id %s, event_num %s" % (manifold, line[3], line[4], line[11]), file=sys.stderr)
            success = False
            above_1torr = True
            above_100mtorr = True

            #turn manifold to port
            #action.run("turn_multiposition.act", "Manifold%s" % manifold, line[2]) 
        
            action.run("turn_multiposition.act", "Manifold%s" % manifold, line[3]) 
            evac_time_start = datetime.datetime.now()
            ShowStatus("evac_time_start: %s" %evac_time_start)
            #time.sleep(2)
            #ShowStatus("%s" % datetime.datetime.now())
            #action.run("measure_manifold_vacuum.act", "Manifold%s" % manifold )
            #print(datetime.datetime.now())
            #(j, p, j, j) = action.output.split()
            #if float(p) >= 10.0:
            #    ShowStatus("Bad value (%s) from transducer" % (p))
            #    press = -99.99
            #else:
            #    press = 10**(float(p)-4.0)
            #    #ShowStatus("initial pressure reading: %s at %s" % (press,datetime.datetime.now()))
            #    ShowStatus("initial pressure reading: %s at %s (delta = %s)" % (press,datetime.datetime.now(), datetime.datetime.now()-evac_time_start))

            # monitor pressure, stop when hit limit or timeout
            while True:
                action.run("measure_manifold_vacuum.act", "Manifold%s" % manifold )
                (j, p, j, j) = action.output.split()
                if float(p) >= 10.0:
                    ShowStatus("Bad value (%s) from transducer, retry" % (p))
                    time.sleep(1)
                    continue
                press = 10**(float(p)-4.0)
                ShowStatus("initial pressure reading: %s at %s (delta = %s)" % (press,datetime.datetime.now(), datetime.datetime.now()-evac_time_start))
            
                evac_time = datetime.datetime.now() - evac_time_start

                if above_1torr and float(press) <= 1.0 :   #4V = 1 Torr
                    evac_1torr_time = evac_time
                    above_1torr = False
                    ShowStatus("Time for flask stem to evac to 1 Torr = %s seconds" % evac_1torr_time.seconds)

                if above_100mtorr and float(press) <= 0.1 :
                    evac_100mtorr_time = evac_time
                    above_100mtorr = False
                    ShowStatus("Time for flask stem to evac to 100 mTorr = %s seconds" % evac_100mtorr_time.seconds)


                if float(press) < float(config.flask_evac_cutoff): 
                    success = True  
                    msg = "FLASK_EVAC:  manifold%s, port %s, evac_time= %s" % (manifold, 
                            line[3], evac_time.total_seconds())
                    ShowStatus(msg)
                    break

                if evac_time.total_seconds() > float(config.flask_evac_time_limit):
                    # record error and break OR deal with leak here
                    success = False
                    evac_1torr_time = evac_time
                    evac_100mtorr_time = evac_time
                    break   

                #time.sleep(1.0)
                time.sleep(0.1) #use short delay while hm has long spin up time

            #turn manifold to next off port  
            action.run("turn_multiposition.act", "Manifold%s" % manifold, int(line[3]) +1) 
            time.sleep(1.0)

            # write evac times/pressure to temp data files so can put into system QC file after they are run
            # temp data files are by event_number
            port_evac_datafile = "port_evac_%s.dat" % (line[11]) 
            try:
               f = open(port_evac_datafile, "w")
               f.write("%s  %s  %7.3f %s\n" % (evac_1torr_time.seconds, evac_100mtorr_time.seconds, press, evac_time.seconds))
               f.close()
            except:
               ShowStatus("Could not open file %s for writing, ... continue with flask prep anyway" % (port_evac_datafile))

            ShowStatus("evac_1torr_time: %s   evac_100mtorr_time: %s    final_press: %7.3f" % (
                evac_1torr_time.seconds, evac_100mtorr_time.seconds, press))

    
            # deal with leaking flask here
            if not success:
                msg = "Flask %s, Manifold %s, Port %s is leaking, fix and click ok or click stop to skip" % (line[4], line[2], line[3])
                answer = ShowMessage(msg=msg, nostop=False)
                if "stop" in answer:
                    index_to_skip.append(line[0])
                    msg = "Flask %s, Manifold %s, Port %s was skipped, REMOVE FROM MANIFOLD" % (line[4], line[2], line[3])
                    answer = ShowMessage(msg=msg, nostop=True)
                    
    # turn manifold_evac to system 
    action.run("turn_multiposition.act", "Manifold%s_Evac" % manifold, "@system_on") 
    time.sleep(1.0)
    # turn manifold to manifold off (set direction to go up)
    action.run("turn_multiposition.act", "Manifold%s" % manifold, "@Manifold%s_off UP" % manifold) 
    time.sleep(5)   



# promt user to open flask valves, do this after both manifolds have finished to be safer
return_code = 0
msg = "Open flask stopcocks, hit ok when done. Stop to skip all flasks"
answer = ShowMessage(msg = msg, nostop=False)
if "stop" in answer:
    #for n, line in enumerate(to_prep):
    for line in to_prep:
        if line[0] not in index_to_skip:
            index_to_skip.append(line[0])
    msg = "ALL FLASKS SKIPPED, REMOVE FROM MANIFOLD"
    answer = ShowMessage(msg = msg, nostop=True)
    return_code = 1

# mark flask as ready or remove if skipped
for line in to_prep:
    if line[0] in index_to_skip:
        #print >> sys.stderr, "skipping line[0]=%s" % line[0]
        magiccdb.mark_error(line[0])
        #pass
    else:   
        #print >> sys.stderr, "running line[0]=%s" % line[0]
        magiccdb.mark_ready(line[0])
        #pass # FOR TESTING

    
# Check to see if system is running, if not then alert user
if getSysRunning():
    pass
else:
    msg = "*** SYSTEM NOT CURRENTLY RUNNING ***"
    answer = ShowMessage(msg=msg, nostop=True, nowait=True)


