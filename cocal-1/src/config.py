
import os
import logging

home = os.path.expanduser('~')

SYSTEM_NAME = "cocal-1"
HOMEDIR    = home                       # Our home
LOGFILE    = HOMEDIR + "/cocal.log"    # log file
ERRORFILE  = HOMEDIR + "/cocal_error.log" # error message file, used for press/flow errors
PFPLOGFILE = HOMEDIR + "/pfp_error.log" # pfp error log file
CONFFILE   = HOMEDIR + "/config/cocal.conf"   # hm configuration file
ACTIONDIR  = HOMEDIR + "/actions"       # Action directory
LOCKFILE   = HOMEDIR + "/.pid"          # lock file for this process
#LOGLEVEL   = logging.INFO               # change to logging.INFO for normal operation
LOGLEVEL   = logging.DEBUG             # change to logging.INFO for normal operation
LOGFORMAT  = "%(levelname)-8s: %(asctime)s %(message)s"


WAIT = os.P_WAIT        # wait for process to end before continuing
NOWAIT = os.P_NOWAIT    # run process in background and not wait for it to finish

# put runaction in test mode if true, set to false to actually run things
#testmode = True
testmode = False

# Save GC chromatograms in zip file?
storegc = True          # True to save chromatograms in zip file

# these names are duplicted in /panel/config.py so remember to change there if any changes are made here.
ref_name = "R0" #name of reference gas
h2_ref_name = "R1" #name of reference gas
junk_name = "J0" #name of junk air for continuous ref aliquot mode

num_pre_analysis_loops = 4

# during idling on continuous shots, number of junk air aliquots between R0 shots - use to conserve R0 but keep regulator flushed
num_junk_cycles = 15 

# *** num cycles for response curve is in the panel config file
num_dilution_cycles = 8

# used in pre-analysis check
pre_analysis_dry_time = 600

# number of past log files to keep 
num_logs = 999  

# list of data files
datafiles = ["data.picarro", "data.aerodyne", "data.aerolaser", "data.aeris", "data.sf6", "data.h2", "data.qc", "data.trap_dry_qc",
                "data.picarro.high_freq", "data.aerodyne.high_freq", "data.aerolaser.high_freq", "data.aeris.high_freq"]

# first guess for transducer offset between sample loop transducer and room air transducer
# will be measured initially and during the run.
transducer_offset = 10


# info for zero air calibrations - if used
num_zero_air_cal_refs = 2       # number of reference gas aliquots before and after samples
isZeroAirCal = False
zero_air_gcdir_suffix = "_zeroair"      # suffix on directory name where GC integration parameters are set


# number of minutes to wait before switching from idle gas to room air
idle_wait_time = 301  

# idle time during continuous shots at end of run.  
runshots_idle = 1800

# limits for sample and reference pressures and flows
gc_pressure_limit = 12.3  # may not use this
press_limit = 720  # 700 torr # may not use this
flow_limit = 100   # 100 sccm # may not use this
flow_check = 0    # may not use this


# limit for system evac (Torr)
first_system_evac_limit =  35    #normally 35, increase for quicker testing, accept final pressure within 10 Torr of this limit in code to prevent crashing on wet samples
second_system_evac_limit = 100  #normally 100, increase for quicker testing, accept final pressure within 10 Torr of this limit in code to prevent crashing on wet samples
system_evac_time_limit = 200    #seconds, use for timing out on sys evac step
transducer_test_evac_limit = 500

# pfp manifold evac time (seconds)
pfp_evac_time = 300
# time limit for pfp manifold to evac to 1 Torr (seconds)
pfp_evac_1torr_time_limit = 40
# min time limit for pressure to hit 100mTorr.  Checks for evac valve not getting to correct port
pfp_evac_100mtorr_time_limit = 40

# limits for flask manifold evac
flask_evac_cutoff = 0.050    # 50 mTorr
#flask_evac_cutoff = 0.100    # 100 mTorr
flask_evac_time_limit = 70      # timeout in seconds for flask stem evacuation
min_flask_evac_time = 5  #min time, looks for evac valve not on correct position


