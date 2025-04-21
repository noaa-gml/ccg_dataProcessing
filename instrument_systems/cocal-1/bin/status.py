#!/usr/bin/python

import sys
import os
import datetime

home = os.environ["HOME"]
sys.path.append("%s/src" % home)
sys.path.append("%s/src/hm" % home)
HOMEDIR = home

import utils

######################################################################
def get_mode():

        try:
            f = open("sys.setup")
            s = f.readline()
            f.close()
            (junk, mode) = s.split()
            mode = int(mode)
            return mode
        except:
            return 1

######################################################################
#1:      Flask Pre-Analysis Check
#2:      Sample / Standard Analysis
#3:      Single Reference Aliquot
#4:      Continuous Reference Aliquots
#5: Test Mode
def get_mode_title(mode=1):

    mode_title = "None"

    try:
        f = open("sys.modes")
        s = f.readlines()
        f.close()
        for line in s:
            (a, b) = line.split(":")
        if int(a) == int(mode):
            mode_title = b.strip()

        return mode_title
    except:
        return mode_title


######################################################################
def get_internal_mode():

    try:
        f = open("sys.current_sample")
        s = f.readline()
        f.close()
        internal_mode = s.strip()
        internal_mode = internal_mode.strip()

        return internal_mode
    except:
        return 1

######################################################################
# Determine which systems are to be used
# gaslist will hold system names, 
# processlist will hold gases that will be processed when finishing
######################################################################
def get_systems():
    syslist = []
    sysgases = {}

    try:
        f = open("sys.setup")
    except:
        return ["picarro"], {"picarro":"CO2"}

    for line in f:
        if "Flask_System" in line:
            (a, systems) = line.split(":")
            (sysname, gasstr) = systems.split("-")
            sysname = sysname.strip()
            sysname = sysname.lower()
            gases = gasstr.strip().split()
            sysgases[sysname] = gases

    f.close()


    # make sure syslist is in proper order of system names
    # i.e., can't use sysgases.keys() because they might not be in correct order.
    for name in ["Aerodyne","Aerolaser","Aeris", "GC1", "GC2"]:
        if name.lower() in sysgases: syslist.append(name.lower())

    if len(syslist) == 0:
        return ["picarro"], {"picarro":"CO2"}
    else:
        return syslist, sysgases






######################################################################
# Start of things

os.chdir(HOMEDIR)

# Get starting mode from sys.setup
mode = get_mode()
# get list of systems and gases
syslist, sysgases = get_systems()

#get mode title
modetitle = get_mode_title(mode)

#see if system is running
running=utils.getSysRunning()

start = utils.get_start_time()

# see if cont shots selected
run_shots = utils.get_setup_value("RunShots")[0]

now = datetime.datetime.now()
print("Updated at: %s" % (now.strftime("%Y-%m-%d %H:%M:%S")), file=sys.stdout)
print(" ", file=sys.stdout)
if running:
    print("System is running", file=sys.stdout)
    print("Analysis started at %s" % start, file=sys.stdout)
else:
    print("System is stopped", file=sys.stdout)

print(" ", file=sys.stdout)
print("Mode: %s  %s" %(mode, modetitle), file=sys.stdout)
if int(run_shots) != 0:
    print("Run Continuous Shots selected", file=sys.stdout)
else:
    print("Run Continuous Shots NOT selected", file=sys.stdout)
print(" ", file=sys.stdout)
print("Instruments and gases measured:", file=sys.stdout)
for s in syslist:
    if s.lower() == "gc1" or s.lower() == "gc2":
        print("     %s" %  s.upper(), file=sys.stdout)
    else:
        print("     %s" % s.capitalize(), file=sys.stdout)

    for gas in sysgases[s]:
        print("          %s" % gas.upper(), file=sys.stdout)

    print(" ", file=sys.stdout)
    



