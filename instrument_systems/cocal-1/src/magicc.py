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

from common import ShowStatus, de_activate_ports
import config
import modes
import utils


# Create a RunAction class instance
action = RunAction(actiondir=config.ACTIONDIR, configfile=config.CONFFILE, testMode=config.testmode)


############################################################
# Handler for shutting down program on SIGINT or SIGTERM signal.
# No need to call shutdown() because it will be called
# automatically from the sys.exit() because of the 
# atexit.register() statement.
############################################################
def endprog(signum, frame):

    logging.info("Got termination signal")
    sys.exit("Got termination signal")

############################################################
# Handler to execute on system exit.
# Set by the atexit.register() statement below.
############################################################
def shutdown():

    global action

    logging.info("Shutting down.")

    signal.signal(signal.SIGTERM, signal.SIG_IGN)   # ignore TERM signal
    signal.signal(signal.SIGINT, signal.SIG_IGN)    # ignore INT signal

    com = "at -f bin/checkidle.sh now + %s minutes" % config.idle_wait_time
    os.system(com)

    ##deactivate manifold ports
    #de_activate_ports(action, "A")
    #de_activate_ports(action, "B")
    
    #run end.act to shutdown cleanly
    action.run("end.act")
    now = datetime.datetime.now()
    s = "%s system stopped at %s" % ( config.SYSTEM_NAME,now.strftime("%c"))
    ShowStatus(s)



######################################################################
# Determine which systems are to be used
# gaslist will hold system names, 
# processlist will hold gases that will be processed when finishing
######################################################################
def get_systems():

        syslist = []
        sysgases = {}

        #Flask_System: Picarro - CO2
        #Flask_System: Aerodyne - CO2C13 CO2O18 CO2

        s = utils.get_setup_value("Flask_System")

        if s:
            for line in s:
                (sysname, gasstr) = line.split("-")
                sysname = sysname.strip()
                sysname = sysname.lower()
                gases = gasstr.strip().split()
                sysgases[sysname] = gases
        else:
                return ["aerodyne"], {"aerodyne":["CO2"]}


        # make sure syslist is in proper order of system names
        # Need isotope files in place before processing total co2
        # i.e., can't use sysgases.keys() because they might not be in correct order.
        # make sure syslist is all lowercase
        for name in ["gc1","gc2","aerolaser","aeris","aerodyne","picarro"]:
                if name.lower() in sysgases: syslist.append(name.lower())

        if len(syslist) == 0:
                return ["aerodyne"], {"aerodyne":["N2O","CO"]}
        else:
                return syslist, sysgases



######################################################################
def rotate_logs(logfile, count):
    
    for i in range(count-1, 0, -1):
        src="%s/logs/%s.%03d" % (config.HOMEDIR, os.path.basename(logfile), i)
        dest = "%s/logs/%s.%03d" % (config.HOMEDIR, os.path.basename(logfile), i+1)
        if os.path.exists(src):
            if os.path.exists(dest):
                os.remove(dest)
            os.rename(src,dest)

    if os.path.exists(logfile):
        dest = "%s/logs/%s.001" % (config.HOMEDIR, os.path.basename(logfile))
        os.rename(logfile, dest)

######################################################################
# Start of things

os.chdir(config.HOMEDIR)

# Lock the lock file. Also writes pid to lock file if successful. 
# If it fails, then a process already has a lock, so exit.
try:
    lock_f = LockFile(config.LOCKFILE)
except LockError:
    s = "%s is already running. Exiting..." % config.SYSTEM_NAME
    sys.exit(s)


# Set up logging
rotate_logs(config.LOGFILE, config.num_logs)
rotate_logs(config.PFPLOGFILE, config.num_logs)
rotate_logs("sys.log", config.num_logs)
logging.basicConfig(filename=config.LOGFILE, level=config.LOGLEVEL, format=config.LOGFORMAT)
logging.info("%s System startup" % config.SYSTEM_NAME)

# force pfp log file to create regardless of mode to keep numbering of archived log files the same
try:
    f = open(config.PFPLOGFILE, "w")
    now = datetime.datetime.now()
    f.write("%4d-%02d-%02d %02d:%02d   PFP Messages\n" % (now.year, now.month, now.day, now.hour, now.minute))
    f.close()
except:
    print("Can't open file %s for writing." % (config.PFPLOGFILE), file=sys.stderr)
    sys.exit()


# Get starting mode from sys.setup
s = utils.get_setup_value("Mode")
if s:
    mode = int(s[0])
else:
    mode = 1

#logging.info("Starting in mode %s", mode)
ShowStatus("Starting in mode %s" % mode)

# Determine which systems are to be used
#syslist, processlist = get_systems()
syslist, sysgases = get_systems()
#logging.info("Using systems %s", ",".join(syslist))
ShowStatus("Using systems %s" % (",".join(syslist)))

# Signals to catch
signal.signal(signal.SIGTERM, endprog)      # Execute endprog on TERM signal
signal.signal(signal.SIGINT, endprog)       # Execute endprog on INT signal
#signal.signal(signal.SIGUSR1, get_mode())  # Execute get_mode on USR1 signal

# backup the data files   (HANDLED IN MODES)

# Check if devices are responding
ShowStatus("Checking Devices...")
if action.run("check.act") != 0:
    s = "*** Device communication failure. ***"
    #logging.error(s)
    ShowStatus(s)
    sys.exit(s)

## run startup action to set up valve positions in sample manifolds
## keep this separate from startup.act so less likely to interfere with prep manifold
#ShowStatus("Setting manifold evac valves ...")
#if action.run("startup_manifolds.act") != 0:
#    s = "*** Error in sample manifold setup. ***"
#    logging.error(s)
#    ShowStatus(s)
#    sys.exit(s)

## find stops of Valco two position valves, hopefully will help keep valves from loosing positions.
#ShowStatus("Set stop positions of Valco two position valves")
#action.run("valco_two_position_find_stops.act", "GCbypass")
#action.run("valco_two_position_find_stops.act", "SF6_inject")

# run startup action to set up valves and A/D
ShowStatus("Initializing Devices...")
if action.run("startup.act") != 0:
    s = "*** Error in Device Initialization. ***"
    logging.error(s)
    ShowStatus(s)
    sys.exit(s)

# run config_daq action to configure channnels on hp34970
ShowStatus("Configuring the DAQ unit")
action.run("config_daq.act")

if mode != 6:  
    # if not running trap drying mode then setup
    # if running aerodyne then setup toggle controls and update scripts
    if "aerodyne" in syslist:
        ShowStatus("Setup Aerodyne")
        # test Aerodyne comms
        if not os.path.isfile(utils.get_resource("aerodyne_test_comms_file")): 
            msg = "Aerodyne communications not active, run aerodyne_mount to reconnect. Exiting ..."
            ShowStatus(msg)
            sys.exit(msg)

        # write scripts used by Aerodyne (setup, background, and fill)
        action.run("aerodyne_make_scripts.act")


        # Run setup script
        runscript_accepted = False
        try_cnt = 0  # limit number of tries to 5 times, exit if can't get comms to work

        while runscript_accepted == False and try_cnt < 5:

            # remove aerodyne_setup acknowledgement file if it exists
            try:
                os.remove(utils.get_resource("aerodyne_run_script_ack"))
            except:
                pass
         
            ShowStatus("Aerodyne run setup script")
            action.run("aerodyne_setup.act")  # 3 secs
            if os.path.isfile(utils.get_resource("aerodyne_run_script_ack")): runscript_accepted = True

            try_cnt += 1

        if runscript_accepted == False:
            msg = "Run Aerodyne setup script failed, exiting ..."
            ShowStatus(msg)
            sys.exit(msg)

    ##open idle solenoid valve 
    #action.run("closerelay.act", "@Idle")
    #action.run("openrelay.act", "@idle_mks_close_valve")

# Log our start time
ShowStatus("Starting analysis...")
#utils.set_start_time() # HANDLED IN MODES

# In case this script dies unexpectedly, shut down the child processes.
# This means that shutdown() will be called on sys.exit() too.
atexit.register(shutdown)

# execute the correct mode function
# These mode numbers must agree with what is in modes file
if   mode == 1:  modes.pre_analysis_check(syslist, sysgases)
elif mode == 2:  modes.sample_analysis(syslist, sysgases)
elif mode == 3:  modes.single_shot(syslist, sysgases)
elif mode == 4:  modes.continuous_shot(syslist, sysgases)
elif mode == 5:  modes.testmode(syslist, sysgases)
elif mode == 6:  modes.dry_trap(syslist, sysgases)
else:
    sys.exit("Unknown mode number %d" % mode)

if "aerodyne" in syslist:
    ShowStatus("turning off Aerodyne Write Data")
    action.run("aerodyne_stop_wd.act") # may need to check if this goes through

ShowStatus("Shutting down, ----- Run COMPLETED successfully")
sys.exit()
