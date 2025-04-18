
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


# open connection to database file that has the sample information
from magiccdb import *

db_filename = 'magicc.db'   
# db_filename = config.databasefile # could put this in config.py instead
magiccdb = magiccDB(db_filename)


# create global dictionary for reference gas, use similar template as the 
# dictionary returned for samples from the magiccdb using get_next()
try:
    manifold, portnum = utils.get_resource(config.ref_name.lower()).split()
except:
    msg = "%s is NOT a valid value in config file, exiting" % (config.ref_name)
    logging.info(msg)
    sys.exit()

referencedata = {
    "manifold" : manifold,
    "port_num"  : portnum,
    "serial_num" : "NA",
    "sample_type" : "NA",    # reset this field for each internal mode
    "sample_num"  : 1,
    "sample_id"   : config.ref_name,
    "event_num"   : 0,
    "analysis_id" : config.ref_name,
    "pressure"    : "NA",
    "regulator"   : "NA",
    "sample_id_num" : -9
    }

# create global dictionary for junk air, use similar template as the 
# dictionary returned for samples from the magiccdb using get_next()
try:
    manifold, portnum = utils.get_resource(config.junk_name.lower()).split()
except:
    msg = "%s is NOT a valid value in config file, exiting" % (config.junk_name)
    logging.info(msg)
    sys.exit()

junkdata = {
    "manifold" : manifold,
    "port_num"  : portnum,
    "serial_num" : "NA",
    "sample_type" : "NA",    # reset this field for each internal mode
    "sample_num"  : 1,
    "sample_id"   : config.junk_name,
    "event_num"   : None,
    "analysis_id" : None,
    "pressure"    : "NA",
    "regulator"   : "NA",
    "sample_id_num" : -9
    }



sampledata = junkdata

utils.set_start_time()
proc2_on = False

cnt = 0
background = True
while True:
    cnt += 1
    if background:
        ShowStatus("Run H2 chromatography in BACKGROUND --- cnt: %s" % cnt)
        utils.set_start_time(cycle=True)
        proc2 = action.runbg("sample_h2_quick_cycle_for_testing.act", "gc.h2.txt", sampledata["port_num"])
        proc2_on = True
        ShowStatus("waiting for h2 chromatography")
        if proc2_on:  proc2.wait()
    else:
        ShowStatus("Run H2 chromatography --- cnt: %s" % cnt)
        utils.set_start_time(cycle=True)
        action.run("sample_h2_quick_cycle_for_testing.act", "gc.h2.txt", sampledata["port_num"])

    sp='H2'
    relax_gc=True
    storegc=True
    prefix = "test h2"
    inst_id = "H11"
    datafile = "data.%s" % sp.lower()
    gcfile = "gc.%s.txt" % sp.lower()
    #process chromatograms and write data to data.sf6 and data.h2 files
    data = utils.process_gc(sp, gcfile, relax_gc)
    f = open(datafile, "a")
    print("%s %s" % (prefix, data), file=f)
    f.close()
    # archive the chromatogram if storegc=true
    if storegc:
        utils.archive_gcfile(sp.lower(), gcfile, inst_id)

    print("pause 10 sec to allow stopping between runs")
    time.sleep(10)



