#!/usr/bin/python

import sys
import os

sys.path.append(os.environ["HOME"])
sys.path.append("%s/src" % os.environ["HOME"])
sys.path.append("/ccg/src/python/lib")

import datetime
import subprocess
import signal
import atexit
import logging
import collections
#import dbutils

#from lock_file import LockFile, LockError
#from runaction import *

import utils
import config

# open connection to database file that has the sample information
from magiccdb import *
db_filename = 'magicc.db'
# db_filename = config.databasefile # could put this in config.py instead
magiccdb = magiccDB(db_filename)



home = os.environ["HOME"]

HOMEDIR = home                       # Our home


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
def get_internal_mode():

        try:
            f = open("sys.internal_mode")
            s = f.readline()
            f.close()
            internal_mode = s.strip()
            internal_mode = internal_mode.strip()
                
            return internal_mode
        except:
            return 1 
######################################################################
def get_current_sample_info(key):

        c_value = ""

        try:
            f = open("sys.current_sample")
            s = f.readlines()
            f.close()

            for line in s:
                (a, b) = line.split(":")
                if a.lower() == key.lower():
                    c_value = b.strip()
        except:
                print("could not read sys.current_sample", file = sys.stderr)

        return c_value



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
        for name in ["Aerodyne","Aerolaser", "Aeris", "GC1", "GC2"]:
                if name.lower() in sysgases: syslist.append(name.lower())
                #if name.lower() in sysgases: syslist.append(name)

        if len(syslist) == 0:
                return ["picarro"], {"picarro":"CO2"}
        else:
                return syslist, sysgases


######################################################################
def default_results():

    tempfile = "display_results_tempraw"
    for inst in syslist:

            if inst.lower() == "gc1": inst = "SF6"
            if inst.lower() == "gc2": inst = "H2"

            print("Data from instrument %s" % (inst))
            print("---------------------------------------")
            fn = "data.%s" % (inst.lower())
            try:
                fp = open(fn)
            except:
                results = "No data available"
                print(results)
                return

            if inst.lower() == "picarro":
                print("type id yr  mo dy hr mn sc co2     co2_sd co2_n ch4 ch4_sd ch4_n h2o cellP  cellT  sampleP flow flaskP")
                for line in fp:
                    (type, id, yr, mo, dy, hr, mn, sc, 
                        co2, co2_sd, co2_n, 
                        ch4, ch4_sd, ch4_n,
                        h2o, h2o_sd, h2o_n,
                        cellP, cellP_sd, cellP_n, 
                        cellT, cellT_sd, cellT_n, 
                        j,j,j,
                        j,j,j,
                        j,j,j,
                        sampleP, flow, flaskP, at) = line.split()

                    print("%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (type, id, yr, mo, dy, hr, mn, sc, 
                        co2, co2_sd, co2_n,ch4,ch4_sd,ch4_n,h2o,cellP,cellT,sampleP,flow,flaskP))

            if inst.lower() == "sf6" or inst.lower() == "h2":
                print("type id yr   mo dy hr mn sc pH pA Tr bc flow sampleP flaskP inject flag")
                for line in fp:
                    (type, id, yr, mo, dy, hr, mn, sc,
                        height, area, tr, bc, flow, sampleP, flaskP, inject, flag, at) = line.split()

                    print("%s  %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (
                        type, id, yr, mo, dy, hr, mn, sc, 
                        height, area, tr, bc, flow, sampleP, flaskP, inject, flag))

            if inst.lower() == "aerodyne":
                print("type id yr   mo dy hr mn sc n2o n2o_sd n2o_n co co_sd co_n  cellT(K)  cellP(Torr) sampleP flow flaskP")
                for line in fp:
                    (type, id, yr, mo, dy, hr, mn, sc,
                        n2o, n2o_sd, n2o_n,
                        co, co_sd, co_n,
                        cellT, cellT_sd, cellT_n,
                        cellP, cellP_sd, cellP_n,
                        sampleP, flow, flaskP, at) = line.split()

                    print("%s  %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (
                        type, id, yr, mo, dy, hr, mn, sc, 
                        n2o, n2o_sd, n2o_n,
                        co, co_sd, co_n,
                        cellT, cellP, sampleP, flow, flaskP))

            fp.close()

            print("   ")


######################################################################
def sample_results(internal_mode):

    global syslist, sysgases, magiccdb
    
    tempfile = "display_results_tempraw"

    # get current tank id for cals
    # next_sampledata, ready = magiccdb.get_next(sample_type=sampledata["sample_type"], asDict=True)
    if internal_mode.lower() == "cals":
        serialnum = get_current_sample_info("serialnum")
        pressure = get_current_sample_info("pressure")
        regulator = get_current_sample_info("regulator")
        manifold = get_current_sample_info("manifold")
        portnum = get_current_sample_info("portnum")
        #process_cmd = "/ccg/bin/calpro.py -t "
        process_cmd = "/ccg/src/python3/nextgen/calpro.py -t "
    else:
        serialnum = ""
        pressure = ""
        regulator = ""
        manifold = ""
        portnum = ""
        #process_cmd = "/ccg/bin/flpro.py -t "
        process_cmd = "/ccg/src/python3/nextgen/flpro.py -t "

    for inst in syslist:
        # get instrument code
        inst_id, sernum = utils.get_instrument_id(inst)

        for sp in sysgases[inst]:
            rawfile = "/home/magicc/display_results_rawfile.%s.%s" % (inst_id.lower(), sp.lower())
            utils.make_raw(config.SYSTEM_NAME, inst, internal_mode, qc=False, gas=sp, rawfile=rawfile,
                            serialnum=serialnum, pressure=pressure, regulator=regulator,
                            valvename=manifold, portnum=portnum)

            if os.path.isfile(rawfile):     
                #os.system(cmd + fn)
                os.system(process_cmd + rawfile + " 2>/dev/null")
            else:
                print("file %s is NOT found" % rawfile, file = sys.stderr)



######################################################################
# Start of things

os.chdir(HOMEDIR)

# Get starting mode from sys.setup
mode = get_mode()

syslist, sysgases = get_systems()

now = datetime.datetime.now()
print("Updated at: %s" % (now.strftime("%Y-%m-%d %H:%M:%S")))
print(" ")


if   mode == 1: default_results()
elif mode == 2:
    # get internal mode
    internal_mode = get_internal_mode()
    if internal_mode.lower() == "flask" or internal_mode.lower() == "pfp" or internal_mode.lower() == "cals":
        sample_results(internal_mode)
    else:
        default_results()
    
elif mode == 3: default_results()
elif mode == 4: default_results()
elif mode == 5: default_results()

else:
        sys.exit("Unknown mode number %d" % mode)



