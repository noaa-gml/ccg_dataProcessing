#!/usr/bin/python

import os
import sys
import datetime
import time
#import MySQLdb
#import pymysql as mysql
import pymysql as MySQLdb
import multiprocessing
import subprocess

import config
sys.path.append("%s/src" % config.HOMEDIR)
sys.path.append("%s/src/hm" % config.HOMEDIR)

from common import *
from runaction import *
import utils


from collections import deque
from statistics import median, mean


## open connection to database file that has the sample information
#from magiccdb import *
#db_filename = 'magicc.db'
## db_filename = config.databasefile # could put this in config.py instead
#magiccdb = magiccDB(db_filename)



# Create a RunAction class instance to use in all the modes
action = RunAction(actiondir=config.ACTIONDIR, configfile=config.CONFFILE, testMode=config.testmode)


print("start of test code", file = sys.stderr)


#dlist = deque([float(config.transducer_offset)], maxlen=10)
#print(dlist)
#print(dlist[0])
#
#for nn in range(0,10):
#    dlist.append(nn)
#    print(dlist)

#print("*** final")
#print(dlist)
#print("mean(dlist): %s" % mean(dlist)) 
#print("median(dlist): %s" % median(dlist)) 

#config.transducer_offset = deque([float(config.transducer_offset)], maxlen=10)
#print(config.transducer_offset)
#print(config.transducer_offset[0])

#for nn in range(0,20):
#    config.transducer_offset.append(nn)
#    print(config.transducer_offset)


#print("*** final")
#print(config.transducer_offset)
#print("mean(config.transducer_offset): %s" % mean(config.transducer_offset)) 
#print("median(config.transducer_offset): %s" % median(config.transducer_offset)) 

#config.transducer_offset=0.0
#if isinstance(config.transducer_offset, deque):
#    print("true")
#else:
#    print("false")



#print("config.PFPLOGFILE: %s" % config.PFPLOGFILE)
##if any pfp errors, display information 
#if os.path.exists(config.PFPLOGFILE):
#    print("here")
#    f = open(config.PFPLOGFILE,'r')
#    lines = f.readlines()
#    f.close()
#    if len(lines) > 1:
#        utils.ShowMessage(file = config.PFPLOGFILE, nostop=True, nowait=True)



sampledata = {
    "manifold" : "A",
    "port_num"  : 15,
    "serial_num" : "3101-FP",
    "sample_type" : "pfp",    # reset this field for each internal mode
    "sample_num"  : 2,
    "sample_id"   : "3163-02",
    "event_num"   : 12345,
    "analysis_id" : 1,
    "pressure"    : "NA",
    "regulator"   : "NA",
    "sample_id_num" : -9
    }

#d = utils.get_resource("Manifold%s_host" % (sampledata["manifold"]))
#print(d)

##activate port - ONLY ACTIVATE ONCE AT THE START 
#de_activate_ports(action, "A")
#de_activate_ports(action, "B")
#activate_port(action, sampledata["manifold"], sampledata["port_num"])
#print("\nwaiting 10 secs after activating manifold-%s, port number: %s" % (sampledata["manifold"], sampledata["port_num"]))
#time.sleep(10) 
#
#
## check pfp serial number on first flask analysis only
#ShowStatus("Checking pfp serial number ...")
#(pfp_check, listed_sn, actual_sn) = getPFPID(action, sampledata["manifold"],
#    sampledata["port_num"], sampledata["serial_num"])
#ShowStatus("Check pfp serial number: Listed: %s    Actual: %s" % (listed_sn, actual_sn))
#
#ShowStatus("\nwaiting for 10 secs")
#time.sleep(10)
#
#
##open pfp flask
#ShowStatus("opening pfp valve")
#open_check = open_as_sample(action, sampledata["manifold"], sampledata["port_num"],
#        sampledata["serial_num"], sampledata["sample_num"])
#ShowStatus("open_check: %s" % open_check)




#ShowStatus("waiting for 20 secs")
#time.sleep(20)

## close pfp flask valve (returns True for successful, False for close error)
#ShowStatus("close pfp valve")
#close_check = close_as_sample(action, sampledata["manifold"], sampledata["port_num"],
#        sampledata["serial_num"], sampledata["sample_num"])
#ShowStatus("close_check: %s" % open_check)
#
#ShowStatus("waiting for 20 secs")
#time.sleep(20)


#print("de-activating all ports")
#de_activate_ports(action, "A")
#de_activate_ports(action, "B")




#rawfile = utils.get_rawfile_name("sf6", "H6")
#print("rawfile = %s" % rawfile)

#syslist = ["gc1","picarro","aerodyne"]
#sysgases={"gc1":["SF6"], "picarro":["CO2","CH4"], "aerodyne":["N2O","CO"]}
##process flask data
#for inst in syslist:
#    ShowStatus("Updating files for %s" % (inst))
#    update_files(inst, sysgases, "flask")

#inst='gc1'
#ShowStatus("Updating files for %s" % (inst))
#update_files(inst, sysgases, "flask")



#status_tag="test"
#ShowStatus("Aerodyne Measure (in background):  %s" % (status_tag))
#proc3 = action.runbg("aerodyne_measure.act", utils.get_resource("aerodyne_datafile"))
#proc3_on = True
#
#ShowStatus("Waiting for background processes to finish:  %s" % (status_tag))
#if proc3_on:  proc3.wait()
#
inst="picarro"
data = utils.cvt_data( inst, utils.get_resource("%s_datafile" % inst.lower()), utils.get_resource("%s_qc_datafile" % inst.lower()))

print("data:")
print(data)

# Example calling syntax:
#  answer = ShowMessage("this is a test")
#  answer = ShowMessage("this is a test", prompt="enter data here", text="a value")
#  answer = ShowMessage(file="input.txt")
#  answer = ShowMessage("Press 'ok' when ready", nostop=True)
#

#answer = utils.ShowMessage("this is a test")
#answer = utils.ShowMessage("this is a test", prompt="enter data here", text="a value")

#inst="gc1"
#relax_gc=True
#sp="sf6"
#
#datafile = "data.%s" % sp.lower()
#gcfile = "gc.%s.txt" % sp.lower()
##process chromatograms and write data to data.sf6 and data.h2 files
#data = utils.process_gc(sp, gcfile, relax_gc)
#
#print("data: %s" % data)





#action.run("valco_current_position.act", "Manifold%s" % sampledata["manifold"].upper())
##print >> sys.stderr, "output: %s" % action.output
#cp = int(action.output)
#ShowStatus("In evac_system: current position is %s" % (cp))





##query splitter
#print("query splitter on manifold %s" % manifold)
#query_pfp_splitter(action,manifold)
#
#
#print("activate port %s on manifold %s" % (port, manifold))
#activate_port(action,manifold,port)
#
#print("waiting 30 secs")
#time.sleep(30)
#
#
#print("de-activate ports on manifold %s" % ( manifold))
#de_activate_ports(action,manifold)

print("end of test code", file = sys.stderr)
