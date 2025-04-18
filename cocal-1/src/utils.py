#!/usr/bin/python

import os
import sys
import datetime
#import pymysql as MySQLdb
import shutil
import subprocess
import logging
import zipfile
import re
import configparser
from math import pow

sys.path.append("/ccg/python/ccglib")
import ccg_dates

import config

# get routine for reading hm resources
sys.path.append("%s/src/hm" % config.HOMEDIR)
import action
act = action.Action(config.CONFFILE)




######################################################################
### get_resource
# pulls values from hm config file (for ex. co2cal.conf) for use in other areas
#  ex resource = utils.get_resource(key)
#
# if device specified, get resource from device specific config file, otherwise
#   get resource from main hm conf file
# 
def get_resource(key, device=None):

    #print("in get_resource, show_resources")
    #act.showResources()
    #sys.exit("clean exit")

    if device:
        # if device, use the device specific conf file
        # for now, code in location and device conf file, but should change to read main conffile.
        #device_conf = "/home/co2cal/config_files/%s.ini" % device.lower()
        devconfig = act.config[device]  #gets the device configuration file name

        config = configparser.ConfigParser()
        s = config.read(devconfig)
        val = config['DEFAULT'][key.lower()]

    else:
        # if not device, look in main hm conf file
        val = act.resources[key.lower()]

    return val






###########################################################
def getSysPid():

        pid = -1
        pidfile = config.HOMEDIR + "/.pid"
        if os.path.exists(pidfile):
                f = open(pidfile)
                pid = f.readline()
                f.close()
                pid = int(pid.strip("\n"))

        return pid

###########################################################
def getSysRunning():

        pid = getSysPid()
        if pid > 0:
                try:
                        os.kill(pid, 0)
                        return pid
                except OSError as err:
                        return False
        else:
                return False




######################################################################
# Get a value from the sys.setup file.
# The file has lines of "key: value" pairs. Return the value given the
# 'key' string.
######################################################################
def get_setup_value(key):

        #value = None

        try:
                f = open("sys.setup")
        except:
                #return value
                return None

        value = []

        for s in f:
                (label, val) = s.split(':')
                label = label.strip()
                val = val.strip()
                if label == key:
                        #value = val
                        value.append(val)
                        #break
        f.close()

        return value


######################################################################
# Get a value from the sys.stdset file.
# The file has lines of "key: value" pairs. Return the value given the
# 'key' string.  
######################################################################
def get_stdset(key="StdSet"):

        #value = None

        try:
                f = open("sys.stdset")
        except:
                #return value
                return None

        value = ""
        #value = []

        for s in f:
                (label, val) = s.split(':')
                label = label.strip()
                val = val.strip()
                if label == key:
                        value = val
                        #value.append(val)
                        #break
        f.close()

        return value




######################################################################
# Get the event numbers from the sample_table file
######################################################################
def getEvents(samplefile="sample_table"):

    events = []
    try:
        f = open(samplefile)
    except:
        print("Can't open file %s." % samplefile, file=sys.stderr)
        return events

    for line in f:
        (group, port, event) = line.split()
        event = int(event)

        events.append(event)

    f.close()

    return events


######################################################################
# backup data.* files into 
#   /home/magicc/data_file_backup/
# keep same number of backups as for log files but numbers will NOT match log files
def backup_datafiles():
        backupdir = "%s/datafile_backup" % (os.environ["HOME"])
        
        for datafile in config.datafiles:
                
            for i in range(config.num_logs-1, 0, -1):
                src = "%s/%s.%03d" % (backupdir, datafile, i)
                dest = "%s/%s.%03d" % (backupdir, datafile, i+1)
                if os.path.exists(src):
                    if os.path.exists(dest):
                        os.remove(dest)
                    os.rename(src,dest)
            if os.path.exists(datafile):
                dest = "%s/%s.%03d" % (backupdir, datafile, 1)
                os.rename(datafile, dest)
            f = open(datafile,"w")
            f.close()

######################################################################


######################################################################
#  MAKE_RAW
# THIS VERSION MAKES SIGNAL FILES AND QC FILES FROM THE PICARRO AND AERODYNE
# DATA FILES.  
#
# Create raw files from the data files generated during
# analysis and from information tables.
# Prints results to stdout if rawfile="", else write to file rawfile
# Input parameters are:
#   system - System name (ex CO2Cal-1)
#   inst - Instrument (Aerodyne, Picarro, NDIR)
#   type - Type of rawfile, one of "nl", "flask", "cals"
#   gas - gas name, i.e. "co2", "ch4" ...
#   qc - key to force creation of qc file rather than rawfile
#   rawfile - name of file to write output to.  ex 2014-12-03.1359.co2
#   stdset - standard set used. Ex. Primary_A, Primary_B, Secondary, Extended_range
#       Required for NL.
#       For type = NL write the standards in stdset to raw file header
#       For other types write id's listed in refid list (hard coded below).
#   serialnum - serial number of sample tank (for tank cals only)
#   pressure - pressure of sample tank (for tank cals only)
#   regulator - regulator name of sample tank (for tank cals only)
#
#
######################################################################
def make_raw(system, inst, type, qc=False, gas="", rawfile="", stdset="", serialnum="", pressure="", regulator="",valvename="",portnum=""):

    if inst.lower() not in ["qc", "gc", "gc1", "gc2", "picarro", "aerodyne", "aerolaser", "aeris"]:
        print("Unknown inst in make_raw '%s'. Should be on of Aerodyne, Picarro, gc, gc1, gc2" % inst, file=sys.stderr)
        sys.exit()
    if type not in ["nl", "flask", "cal", "cals", "aircraft", "pfp", "zero_air_cals", "qc"]:
        print("Unknown type in make_raw '%s'. Should be one of flask, nl, cals, aircraft or pfp, zero_air_cals, qc" % type, file=sys.stderr)
        sys.exit()

    if type.lower() == "aircraft": 
        sample_type = "pfp"
    else:
        sample_type = type

    #require stdset if type = NL
    if type.upper() == "NL" and not stdset:
        print("STDSET required for NL raw files.", file=sys.stderr)
        sys.exit()

    #set stdset gas 
    if type.upper() == "NL":
        if gas.upper() == "CO2C13" or gas.upper() == "CO2O18":
            stdset_gas = "CO2"
        else:
            stdset_gas = gas

    if inst.lower() == "qc":
        inst_id = ""
        inst_sernum = ""
    else:
        inst_id, inst_sernum = get_instrument_id(inst)  #reads instrument ID from sys.analyzer file

    starttime = get_start_time()            #reads start time from sys.start file

    location = "BLD"
    ntanks = 1

    #set names for instrument specific rawfiles and other system specific items.
    if inst.lower() == "picarro":
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = "CRDS"
        refid = ["R0"]
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc analysis_time_delta(secs) h2o cell_P(Torr) cell_P_sd(Torr) cell_P_n cell_T(C) das_T(C) etl_T(C) wb_T(C) inlet_P(Torr) flask_P(psia) flow(ml/min)"

    elif inst.lower() == "qc":
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = ""
        refid = ["R0"]
        datalist = ""
        qclist = "type gas yr mo dy hr mn sc manifold port cycle_time(secs) init_flask_P(psia) final_flask_P(psia) initial_evac_time(secs) initial_evac_P(Torr) evac_time(secs)  evac_P(Torr) room_T(C) room_P(Torr) idle_P(Torr) chiller_T(C) scroll_pump_P(Torr)" 
        if sample_type.upper() == "PFP" or sample_type.upper() == "FLASK":
            qclist = qclist + " port_evac_1Torr(secs) port_evac_100mTorr(secs) port_evac_P(Torr) port_evac_time(secs)" 

    elif inst.lower() == "aerodyne":
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = "QC-TILDAS"
        refid = ["R0"]
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc cell_T(K) cell_P(Torr) cell_P_sd(Torr) cell_P_n flow(ml/min)"

    elif inst.lower() == "aerolaser":
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = "VURF"
        refid = config.ref_name.upper()
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc  cell_T(K) cell_P(Torr) cell_P_sd(Torr) cell_P_n flow(ml/min)"

    elif inst.lower() == "aeris":
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = "Laser_Spectroscopy"
        refid = config.ref_name.upper()
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc  h2o(ppm) cell_T(C) cell_P(Torr) cell_P_sd(Torr) cell_P_n flow(ml/min)"

    elif inst.lower() == "gc" or inst.lower() == "gc1" or inst.lower() == "gc2":

        if gas.lower() == "h2":
            datafile = "data.h2"
            refid = config.h2_ref_name.upp()
            bcodes = "BB BP PB BFS"
        elif gas.lower() == "sf6":
            datafile = "data.sf6"
            refid = ["R0"]
            bcodes = "BB"
        else:
            datafile = "data.%s" % gas.lower()
            bcodes = "BB"

        method = "GC"
        datalist = "type gas yr mo dy hr mn sc pH pA Tr flag bc"
        qclist = "type gas yr mo dy hr mn sc analysis_time_delta(secs) smp_loop_P(Torr) flushing_P(Torr) flow(ml/min) smp_loop_relax" # new qc files for GC's

    else:
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = False
        refid = ["R0"]
        datalist = " "
        qclist = " "
        #format for species raw file
        format = "%3s  %-12s %s %s %s %s %s %s %9s %s %s %s %s\n"


    #make header info   
    output  = "System:         %s\n" % (system)
    if inst.upper() != "QC":
        output += "Instrument:     %s %s\n" % (inst_id, inst_sernum)
    output += "Site:           %s\n" % (location)
    output += "Date:           %d %02d %02d %02d %02d\n" % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute) 
    output += "Species:        %s\n" % (gas.upper())
    if inst.upper() != "QC":
        output += "Method:         %s\n" % (method)
    output += "Sample type:    %s\n" % (sample_type.lower())
    if qc:
        output += "File type:      QC\n"
    else:
        output += "File type:      Raw\n"

    #for NL add start date for the curve and stdset.  
    if type.upper() == "NL":
        if not qc:
            lastline = os.popen("tail -n 1 %s" % datafile).read()  
            (j1, j2, lyr, lmo, ldy, lhr, lmn, lsc, therest) = lastline.split(None, 8)
            lasttime = datetime.datetime(int(lyr), int(lmo), int(ldy), int(lhr), int(lmn))
            one_mn = datetime.timedelta(minutes=1)
            st = lasttime + one_mn
            output += "Start Date:     %4d %02d %02d %02d %02d\n" % (st.year, st.month, st.day, st.hour, st.minute)

        #print comment for standard set used if NL with Primary stds
        if stdset.lower().count("primary"):
            output += "Standard set:         Primary standards\n"
        elif stdset.lower().count("dilution"):
            output += "Standard set:  CO CH4 Dilution standards\n"
        elif stdset.lower().count("secondary"):
            output += "Standard set:  Secondary standards\n"
        elif stdset.lower() == "manual":
            output += "Standard set:         \n"
        else: 
            output += "Standard set:  Tertiary standards\n"

    if bcodes and not qc:
        output += "Baseline Codes: %s\n" % (bcodes)

    # print reference and standard ID's and serial numbers.
    try:
        f = open("sys.ref_tanks")
    except:
        print("Cannot open sys.tanks file.", file=sys.stderr)
        return

    for line in f:
        line = line.strip("\n")

        (sset, label, sn, manifold, port, press, reg) = line.split()
        
        if label.upper() in refid:
            output +=  "%s:             %s\n" % (label.upper(), sn)
            output +=  "%s Pressure:    %s\n" % (label.upper(), press)
            output +=  "%s Regulator:   %s\n" % (label.upper(), reg)
            
        # print other standards if nl passed
        if type == "nl":
            if sset.upper() == stdset.upper():
                output += "%s:             %s\n" % (label, sn)
                output += "%s Pressure:    %s\n" % (label, press)
                output += "%s Regulator:   %s\n" % (label, reg)
                output += "%s Manifold:   %s\n" % (label, manifold)
                output += "%s Port:   %s\n" % (label, port)

    f.close()

    if type == "cals":
        output += "N Sample Tanks: %s\n" % (ntanks)
        output += "W:              %s\n" % (serialnum)
        output += "W Manifold:      %s\n" % (valvename)
        output += "W Port:          %s\n" % (portnum)
        output += "W Pressure:      %s\n" % (pressure)
        output += "W Regulator:     %s\n" % (regulator)

    # write data column labels to header
    if qc:
        output += "Format: %s\n" % (qclist)
    else:
        output += "Format: %s\n" % (datalist)

    # end header
    output += ";+ Start of Data - Do not write below this line!!\n"



    # for each inst type, read data file and make raw file output strings
    try:
        f = open(datafile)
    except:
        return
    
    for line in f:
        flag = "." #reset flag each time so can identify bad aliquots with tests below  
        line = line.strip("\n")
        #print >> sys.stderr, line

        ####################################################
        if inst.lower() == "picarro":
            (gastype, g, yr, mo, dy, hr, mn, sc, co2, co2_sd, co2_n, ch4, ch4_sd, ch4_n,h2o, h2o_sd, h2o_n,
             cell_press, cell_press_sd, cell_press_n, cell_temp, cell_temp_sd, cell_temp_n,
             das_temp, das_temp_sd, das_temp_n, etl_temp, etl_temp_sd, etl_temp_n,
                 wb_temp, wb_temp_sd, wb_temp_n, 
             inlet_press, flow, flask_press, delta_time) = line.split()

            # append to output strings 
            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %4s %7s %9s %9s %9s %8s %8s %8s %8s %7s %6s %6s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, delta_time, h2o, cell_press, cell_press_sd, 
                            cell_press_n, cell_temp, das_temp, etl_temp, wb_temp, inlet_press, 
                            flask_press, flow )
            elif gas.lower() == "co2":
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %s %s %s %s\n"
                if int(co2_n) <= 0: flag = 'A'
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, co2, co2_sd, co2_n, flag)
            elif gas.lower() == "ch4":
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %s %s %s %s\n"
                if int(ch4_n) <= 0: flag = 'A'
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, ch4, ch4_sd, ch4_n, flag)

        ####################################################
        elif inst.lower() == "qc":
            (gastype, g, yr, mo, dy, hr, mn, sc, manifold, port, cycle_time, init_flask_press, final_flask_press, 
                initial_evac_time, initial_evac_press, evac_time, evac_press, 
                room_temp, room_press, idle_press, chiller_T, scroll_pump_P, 
                port_evac_time1, port_evac_time2, port_evac_P, port_evac_time) = line.split()

            format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %2s %2s %4s %6s %6s %6s %6s %5s %6s %6s %7s %7s %7s %9s" 
            output += format % (gastype, g, yr, mo, dy, hr, mn, sc, manifold, port, cycle_time, init_flask_press,final_flask_press, 
                    initial_evac_time, initial_evac_press, evac_time, evac_press,  
                    room_temp, room_press, idle_press, chiller_T, scroll_pump_P)
            # if pfp, include manifold evacuation qc data (time to 1Torr, time to 100mTorr, and final P)
            if sample_type.upper() == "PFP" or sample_type.upper() == "FLASK":
                format = " %4s %4s %7s %4s\n"   
                output += format % (port_evac_time1, port_evac_time2, port_evac_P, port_evac_time)
            
            else:
                output += "\n"


        ####################################################
        elif inst.lower() == "aerolaser":

            (gastype, g, yr, mo, dy, hr, mn, sc,
                co, co_sd, co_n,
                flow, cell_temp, cell_press, cell_press_sd, cell_press_n) = line.split()


            # append to output strings 
            if qc:
                format = "%3s  %-12s %s %s %s %s %s %s %12s %12s %12s %12s %7s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc,
                    cell_temp, cell_press, cell_press_sd, cell_press_n, flow)
            elif gas.lower() == "co":
                format = "%3s  %-12s %s %s %s %s %s %s %12s %12s %3s %s\n"
                if int(co_n) <= 0: flag = "A"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co, co_sd, co_n, flag)


        ####################################################
        elif inst.lower() == "aerodyne":

            (gastype, g, yr, mo, dy, hr, mn, sc, 
                n2o, n2o_sd, n2o_n,
                co, co_sd, co_n,
                cell_temp, cell_temp_sd, cell_temp_n,
                cell_press, cell_press_sd, cell_press_n,
                flow ) = line.split()


            # append to output strings 
            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, 
                        cell_temp, cell_press, cell_press_sd, cell_press_n, flow)
            elif gas.lower() == "co":
                format = "%3s  %-12s %s %s %s %s %s %s %9s %s %s %s\n"
                if int(co_n) <= 0: flag = 'A'
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co, co_sd, co_n, flag)
            elif gas.lower() == "n2o":
                format = "%3s  %-12s %s %s %s %s %s %s %9s %s %s %s\n"
                if int(n2o_n) <= 0: flag = 'A'
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, 
                            n2o, n2o_sd, n2o_n, flag)

        ####################################################
        elif inst.lower() == "aeris":
            (gastype, g, yr, mo, dy, hr, mn, sc, 
                n2o, n2o_sd, n2o_n,
                co, co_sd, co_n,
                h2o, h2o_sd, h2o_n,
                cell_temp, cell_temp_sd, cell_temp_n,
                cell_press, cell_press_sd, cell_press_n,
                flow ) = line.split()


            # append to output strings 
            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, 
                        cell_temp, cell_press, cell_press_sd, cell_press_n, flow)
            elif gas.lower() == "co":
                format = "%3s  %-12s %s %s %s %s %s %s %9s %s %s %s\n"
                if int(co_n) <= 0: flag = 'A'
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co, co_sd, co_n, flag)
            elif gas.lower() == "n2o":
                format = "%3s  %-12s %s %s %s %s %s %s %9s %s %s %s\n"
                if int(n2o_n) <= 0: flag = 'A'
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, 
                            n2o, n2o_sd, n2o_n, flag)


        ####################################################
        elif inst.lower() == "gc" or inst.lower() == "gc1" or inst.lower() == "gc2":
            #flag for gc data on magicc-3 is set in data.species files so can check
            #   for sample loop pressure relaxation. Not used currently.
            # relax is y/n (1/0) indicator for sample loop relax to room pressure
            (gastype, g, yr, mo, dy, hr, mn, sc, pH, pA, tr, bc, flow, press, smp_loop_press, relax, flag, delta_time) = line.split()

            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %5s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, delta_time, 
                        smp_loop_press, press, flow, relax) 
            else:
                format = "%3s  %-12s %s %s %s %s %s %s %s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc,
                        pH, pA, tr, flag, bc)   
            
    f.close()
        
    
    # Set output (either rawfile or stdout)
    if rawfile:
        try:
            outfile = open(rawfile, "w")
        except IOError as err:
            print("Can't open file %s for writing." % (rawfile), file=sys.stderr)
            print(err, file=sys.stderr)
            outfile = sys.stdout
            
    else:
        outfile = sys.stdout

    output = output.rstrip() # remove trailing \n
    print(output, file=outfile)
    #print output



######################################################################
def save_files(type, inst, gas, rawfile, data=False, qc=False ):

    if type.lower() not in ["nl", "flask", "cals", "pfp"]:
            print("Unknown file type in save_files '%s'. Should be one of 'flask','pfp', 'nl', cals, zero_air_cals'" % type, file=sys.stderr)
            return

    print("in utils.save_files,  rawfile=%s" % rawfile, file=sys.stderr)
    # get year from first 4 characters of raw file name
    year = int(rawfile[0:4])

    # get instrument code
    if inst.upper() == "QC":
        id = ' '
        sernum = ' '
    else:
        id, sernum = get_instrument_id(inst)


    # setup local backup directory
    backupdir = "%s/backup/%s/" % (os.environ["HOME"], type)
    if not os.path.isdir(backupdir):
            os.makedirs(backupdir)

    # copy raw files to /ccg and to local backup
    if inst.upper() == "QC":
        #destdir = where on ccg to write system qc files??
        #destdir = "/home/magicc/data/%s_qc/%s/%s/" %(config.SYSTEM_NAME,type.lower(), year)    
        destdir = "/ccg/%s_qc/%s/%s/" %(config.SYSTEM_NAME,type.lower(), year)  
    else:
        if not data and not qc:
            #destdir = "/ccg/%s/%s/%s/raw/%d/" % (gas.lower(), type, id, year)
            #destdir = "/home/magicc/data/%s/%s/%s/raw/%d/" % (gas.lower(), type.lower(), id.upper(), year)
            destdir = "/ccg/%s/%s/%s/raw/%d/" % (gas.lower(), type.lower(), config.SYSTEM_NAME.lower(), year)
        elif data:
            #destdir = "/ccg/%s/%s/%s/data/%d/" % (gas.lower(), type, id, year)
            #destdir = "/home/magicc/data/%s/%s/%s/data/%d/" % (gas.lower(), type.lower(), id.upper(), year)
            destdir = "/ccg/%s/%s/%s/data/%d/" % (gas.lower(), type.lower(), config.SYSTEM_NAME.lower(), year)
        elif qc:
            #destdir = "/ccg/%s/%s/%s/qc/%d/" % (gas.lower(), type, id, year)
            #destdir = "/home/magicc/data/%s/%s/%s/qc/%d/" % (gas.lower(), type.lower(), id.upper(), year)
            destdir = "/ccg/%s/%s/%s/qc/%d/" % (gas.lower(), type.lower(), config.SYSTEM_NAME.lower(), year)


    # if destdir does not exist, create it
    if not os.path.isdir(destdir): os.makedirs(destdir)

    # copy file to destination, move original file to backup location
    print("in utils.save_files,  destdir=%s" % destdir, file=sys.stderr)
    
    shutil.copy(rawfile, destdir)
    os.rename(rawfile, backupdir+rawfile)


######################################################################
# Process the rawfile.
# Call appropriate processing program.
#utils.process_data(caltype, process_filename, stdset)
######################################################################
def process_data(type, rawfile, stdset=""):
        print("in utils.process_data:  type=%s   rawfile=%s" % (type, rawfile), file=sys.stderr)

        if type == "nl":
            if stdset.upper() == "MANUAL":
                #don't drop any tanks when running manual response curve
                #overwrite co2cal-2 system default nulltanks listed in nlpro
                os.system("/ccg/bin/nlpro.py --nulltanks='default' -u %s" % (rawfile))
            else:
                os.system("/ccg/bin/nlpro.py -u %s" % (rawfile))

        elif type == "flask" or type == "pfp":
            os.system("/ccg/bin/flpro.py -u -v %s >> /home/magicc/flpro.log 2>&1" % (rawfile))

        elif type == "cals":
            os.system("/ccg/bin/calpro.py  -u %s" % (rawfile))

        elif type == "zero_air_cals":
            os.system("/ccg/bin/calpro.py -u %s" % (rawfile))

        else:
            print("Unknown type in processdata: %s. Must be one of 'nl', 'flask', 'pfp', 'cals' or 'zero_air_cals'" % (type), file=sys.stderr)


######################################################################
# Process to call the QC program for flasks
######################################################################
def qc_data(type, rawfile):

        if type == "nl":
            pass
        elif type == "flask" or type == "aircraft":
            os.system("/ccg/bin/flflag.py -u  %s" % (rawfile))
        elif type == "cals":
            pass
        elif type == "zero_air_cals":
            pass
        else:
            print("Unknown type in qc_data: %s. Must be one of 'nl', 'flask', 'aircraft', 'cals' or 'zero_air_cals'" % (type), file=sys.stderr)



######################################################################
# Create raw files from the data files generated during
# analysis and from information tables.
# Prints results to stdout if rawfile="", else write to file rawfile
# Input parameters are:
#   type - Type of rawfile, one of "nl", "flask", "cals"
#   gas - gas name, i.e. "co2", "ch4" ...
#   rawfile - Name of file to write output.  If empty, will write to stdout.
#   serialnum - serial number of sample tank (for tank cals only)
#   pressure - pressure of sample tank (for tank cals only)
#   regulator - regulator name of sample tank (for tank cals only)
#   events - list of event numbers for measured flasks ( for flask only )
# 
######################################################################
#def makeraw(project, gas, rawfile="", serialnum="", pressure="", regulator="", events=None):
#
#    if not project in ["nl", "flask", "cals", "aircraft"]:
#        print >> sys.stderr, "Unknown project in makeraw '%s'. Should be one of 'flask', 'nl', cals'" % project
#        sys.exit()
#
#    gas = gas.lower()
#    ucgas = gas.upper()
#    id, sernum = get_instrument_id(gas)
#    starttime = get_start_time()
#
#    location = "BLD"
#    ntanks = 1
#    bcodes = "BB BP PB"
#
#    if rawfile:
#        try:
#            output = open(rawfile, "w")
#        except IOError, err:
#            print >> sys.stderr, "Can't open %s for writing." % (rawfile)
#            print >> sys.stderr, err
#            output = sys.stdout
#    else:
#        output = sys.stdout
#
#    print >> output, "System:         %s" % ("MAGICC-2")
#    print >> output, "Instrument:     %s %s" % (id, sernum)
#    print >> output, "Site:           %s" % location
#    print >> output, "Date:           %d %d %d %d %d" % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute)
#    print >> output, "Species:        %s" % gas
#    if gas == "co2":
#        print >> output, "Method:         NDIR"
#    elif gas == "co":
#        print >> output, "Method:         VURF"
#    else:
#        print >> output, "Method:         GC";
#        print >> output, "Baseline Codes: %s" % bcodes
#
#    # this writes a line for every tank in sys.tanks for the gas.
#    # may want to change this to only write out lines for the labels in the data file
#    # which requires reading in the data file first, finding the labels etc...
#    f = open("sys.tanks")
#    for line in f:
#        line = line.strip("\n")
#        (g, label, sernum) = line.split()
#        if g.lower() == gas:
#            print >> output, "%-15s %s" % (label+":", sernum)
#
#    f.close()
#
#    if project == "cals":
#        print >> output, "N Sample Tanks: 1"
#        print >> output, "%-15s %s" % ("W:", serialnum)
#        print >> output, "%-15s %s" % ("W Pressure:", pressure)
#        print >> output, "%-15s %s" % ("W Regulator:", regulator)
#
#    print >> output, ";+ Start of Data - Do not write below this line!!"
#
#
#    if project == "nl":
#        try:
#            f = open("data.%s" % gas)
#        except:
#            return
#
#        for line in f:
#            line = line.strip("\n")
#            print >> output, line
#
#        f.close()
#
#    elif project == "flask" or project == "aircraft":
#        f  = open("data."+gas)
#    
#        n = 0
#        for line in f:
#            line = line.strip("\n")
#            (type, therest) = line.split(None, 1)
#            if type == "SMP":
#                event = events[n]
#                n = n + 1
#            else:
#                event = type
#                type = "REF"
#
#            print >> output, "%3s %8s %s" % (type, event, line[3:])
#
#        f.close()
#
#    elif project == "cals":
#
#        try:
#            f = open("data."+gas)
#        except:
#            return
#
#        for line in f:
#            line = line.strip("\n")
#            (name, year, month, day, hour, minute, second, val1, val2, val3, val4) = line.split()
#            if name == "SMP":
#                g = "W"
#            else:
#                g = name
#                name = "REF"
#
#            print >> output, "%3s %2s %s %s %s %s %s %s %s %s %s %s %s" % (name, g, year, month, day, hour, minute, second, val1, val2, val3, val4, ".")
#            
#    if output != sys.stdout:
#        output.close()


######################################################################
# Write the current time to the 'sys.start' file.
# Format is yyyy-mm-dd hh:mm:ss
######################################################################
def set_start_time(cycle=False):
    
    if cycle:
        filename = "sys.cycle_start"
    else:
        filename = "sys.start"

    try:
        f = open (filename, "w")
    except:
        print("Can't open %s for writing." % filename, file=sys.stderr)
        return

    now = datetime.datetime.now()
    s = now.strftime("%Y-%m-%d %H:%M:%S")
    f.write(s+'\n')
    f.close()

######################################################################
# Write the current time to the 'sys.end' file.
# Format is yyyy-mm-dd hh:mm:ss
######################################################################
def set_end_time(cycle=False):
    
    if cycle:
        filename = "sys.cycle_end"
    else:
        filename = "sys.end"

    try:
        f = open (filename, "w")
    except:
        print("Can't open %s for writing." % filename, file=sys.stderr)
        return

    now = datetime.datetime.now()
    s = now.strftime("%Y-%m-%d %H:%M:%S")
    f.write(s+'\n')
    f.close()

######################################################################
# Return a datetime object containing the start date and time 
# in the sys.start or sys.cycle_start file.
# The file has the start time in the format
#       2016-01-15 17:27:00
######################################################################
def get_start_time(cycle=False):

    if cycle:
        fn = "sys.cycle_start"
    else:
        fn = "sys.start"

    try:
        f = open(fn)
    except:
        logging.error("Can't get system/cycle start time")
        return None

    line = f.readline()
    f.close()

    (date, time) = line.split()
    (year, month, day) = date.split("-")
    (hour, minute, second) = time.split(":")
    year = int(year)
    month = int(month)
    day = int(day)
    hour = int(hour)
    minute = int(minute)
    second = int(second)

    dt = datetime.datetime(year, month, day, hour, minute, second)

    return dt

######################################################################
# Return a datetime object containing the END date and time 
# in the sys.end or sys.cycle_end file.
# The file has the start time in the format
#       2016-01-15 17:27:00
######################################################################
def get_end_time(cycle=False):

    if cycle:
        fn = "sys.cycle_end"
    else:
        fn = "sys.end"

    try:
        f = open(fn)
    except:
        logging.error("Can't get system/cycle start time")
        return None

    line = f.readline()
    f.close()

    (date, time) = line.split()
    (year, month, day) = date.split("-")
    (hour, minute, second) = time.split(":")
    year = int(year)
    month = int(month)
    day = int(day)
    hour = int(hour)
    minute = int(minute)
    second = int(second)

    dt = datetime.datetime(year, month, day, hour, minute, second)

    return dt


######################################################################
# Create the name for the raw file from the date contained in the
# sys.start file.
# Raw files are named yyyy-mm-dd.hhmm.gas
######################################################################
def get_rawfile_name(gas=False, inst_id=False):

    dt = get_start_time()

    if gas:
        if inst_id:
            name = "%4d-%02d-%02d.%02d%02d.%s.%s" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, inst_id.lower(), gas.lower())
        else:
            name = "%4d-%02d-%02d.%02d%02d.%s" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, gas.lower())
    else:
        if inst_id:
            name = "%4d-%02d-%02d.%02d%02d.%s" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, inst_id.lower())
        else:
            name = "%4d-%02d-%02d.%02d%02d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute)

    return name

############################################################
# Get date and time of chromatogram from first line of gc file.
############################################################
def get_gcfile_date(gcfile):

        try:
                f = open(gcfile)
        except:
                logging.error("Can't open gcfile %s", gcfile)
                return (0,0,0,0,0,0)

        line = f.readline()
        f.close()
        (year, month, day, hour, minute, second, n) = line.split()
        year = int(year)
        month = int(month)
        day = int(day)
        hour = int(hour)
        minute = int(minute)
        second = int(second)

        return (year, month, day, hour, minute, second)


######################################################################
# Get the instrument id and serial number from the sys.analyzer file.
# OLD - File format is like
# OLD -     gas1/gas2: id serial_number
# OLD - For example
# OLD -     CH4/N2O/SF6: H7 HP 6890 GC US00027040
# OLD -     CO/H2: P1 Peak Laboratories 008
# OLD -     CO2: L7 Licor 7000 IRG4-0319
#
# NEW - pass in inst name as 'gas'
# NEW - inst_nam: id type sn
#
# NEW - For example
# NEW      Picarro:  PC2  Picarro G2301, s/n 2473-CFADS2433
# NEW      Aerodyne:  AR2   Aerodyne QC-TILDAS, s/n 088
# NEW      GC1:  H6 HP 6890, s/n US00024677, GC_ECD
# NEW      GC2:  H11  Agilent 7890, s/n US10834030, GC_HePDD
# 
# Get the id part of the line
######################################################################
def get_instrument_id(gas):

    try:
        f = open("sys.analyzer")
    except:
        logging.error("Can't get system analyzer info (utils.get_instrument_id)")
        return gas
    
    for line in f:
        line = line.strip("\n")
        (gases, therest) = line.split(":")
        gaslist = [ x.upper() for x in gases.split("/") ]
        if gas.upper() in gaslist:
            (id, sernum) = therest.split(None, 1)
            return id, sernum

    return "NoId", "NoSernum"

############################################################
# Get the name of the zip archive file that holds the
# chromatorgram files.
# 'gas' is the gas name, e.g. 'co', 'ch4' ...
############################################################
def get_archive_name(gas, inst_id=None):

    dt = get_start_time()

    name = None
    if dt:
        if inst_id:
            name = "%4d-%02d-%02d.%02d%02d.%s.%s.zip" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, 
                inst_id.lower(), gas.lower())
        else:
            name = "%4d-%02d-%02d.%02d%02d.%s.zip" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, gas.lower())

    return name

############################################################
# Archive a gc file into a zip archive.
# Rename the gc file based on date and time of chromatogram.
######################################################
def archive_gcfile(sys, gcfile, inst_id=None):

    # open the gcfile, read first line (which has date and time),
    (year, month, day, hour, minute, second) = get_gcfile_date(gcfile)

    # now use cycle start time rather than injection time
    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    # and create new filename based on the date and time.
    #newfilename = "%4d%02d%02d%02d%02d.txt" % (year, month, day, hour, minute)
    newfilename = "%4d%02d%02d%02d%02d.txt" % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute)

    # Determine the zip archive name
    ziparchive = get_archive_name(sys, inst_id)
#   print ziparchive

    if ziparchive:
        # Open the zip archive, add gcfile to it with a new name
        logging.info("Add gcfile %s to zip archive %s." % (newfilename, ziparchive) )
        zip = zipfile.ZipFile(ziparchive, "a")
        zip.write(gcfile, newfilename, zipfile.ZIP_DEFLATED)
        zip.close()

#######################################################################
## Update/Insert event data into the mysql database.
## Project is one of 'flask' or 'aircraft'.
#######################################################################
#def updateEvents(project, samplefile="sample_table"):
#
#    events = []
#
#    project = project.lower()
#    if project not in ['flask', 'aircraft']:
#        print("Unknown data project in updateEvents: '%s'. Should be either 'flask' or 'aircraft'." % (project), file=sys.stderr)
#        return
#
#    # connect to mysql database
#    db = MySQLdb.connect(db='magicc')
#    c = db.cursor()
#
#    table = 'sample_info'
#    try:
#        f = open(samplefile)
#    except IOError as err:
#        print("Can't open file %s." % samplefile, file=sys.stderr)
#        return
#
#    # lines look like 
#    # 1  1   222-01 SAN 2012-12-17 15:01 A  -2.54  -54.71  4419.6 A. 1    7.5  -99.0   52.7
#    # group,  port,  flaskid,  site,  date,  time,  method,  lat,  lon,  alt
#    for line in f:
#
#        items = line.split()
#        flaskid = items[2]
#        site = items[3]
#        date = items[4]
#        time = items[5]
#        method = items[6]
#        if project == "aircraft":
#            lat = float(items[7])
#            lon = float(items[8])
#            alt = float(items[9])
#        
#
#        # check if sample already exists in database
#        sql  = "SELECT event_num FROM %s " % table
#        sql += "WHERE date='%s' AND time='%s' AND id='%s'" % (date, time, flaskid)
#        c.execute(sql)
#        result = c.fetchone()
#
#        (year, month, day) = [ int(x) for x in date.split('-') ]
#        (hour, minute) = [ int(x) for x in time.split(':') ]
#        
#        dd = ccg_dates.decimalDate(year, month, day, hour, minute, 0)
#
#        # if no result, then insert, else update
#        if c.rowcount == 0:
#            sql = "INSERT INTO %s SET " % table
#        else:
#            event_num = result[0]
#            sql = "UPDATE %s SET " % table
#
#        sql += "project='%s', " % project.capitalize()
#        sql += "id='%s', " % flaskid
#        sql += "site='%s', " % site
#        sql += "date='%s', " % date
#        sql += "time='%s', " % time
#        sql += "method='%s', " % method
#        sql += "dd=%f " % dd
#        if project == "aircraft":
#            sql += ", "
#            sql += "lat=%f, " % lat
#            sql += "lon=%f, " % lon
#            sql += "alt=%f " % alt
#
#        if c.rowcount > 0:
#            sql += " WHERE event_num=%d" % event_num
#
#        c.execute(sql)
#        db.commit()
#
#        sql = "SELECT event_num FROM %s WHERE date='%s' AND time='%s' AND id='%s'" % (table, date, time, flaskid)
#        c.execute(sql)
#        result = c.fetchone()
#        event_num = result[0]
#
#        events.append(event_num)
#
#    c.close()
#    db.close()
#
#    return events
#
######################################################################

##############################################################
def process_gc(gas, gcfile, relax_gc=True):
    """
    Integrate the chromatogram and return results

    Called with:
        process_gc(gas, gcfile)
    
    where 
        gas is the id of the gas to look for, e.g. "n2o"
        gcfile is the chromatogram data file,

        relax_gc is used on magicc-3 to indicate when gc sample loop was
        positive pressure and could be relaxed to room pressure. Writing 1 
        to indicate sample loop relaxed, 0 if not in qc file. 

    """

    gas = gas.lower()
    ucgas = gas.upper()
    if relax_gc: 
        flag = '.'
        relax_indicator=1
    else:
        flag = '.'
        relax_indicator=0

    if config.isZeroAirCal:
        gcdatadir = config.home + "/" + gas + config.zero_air_gcdir_suffix
    else:
        gcdatadir = config.home + "/" + gas

    if not os.path.exists(gcfile):
        logging.error("In process_gc, gcfile does not exist: %s", gcfile)
        return

    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime.now()

    # open the gcfile, read first line (which has date and time),
    (ayr, amo, ady, ahr, amn, asc) = get_gcfile_date(gcfile)
    if int(ayr) == 0:
        deltatime = starttime - starttime
    else:
        # get time diff between actual and start
        actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
        deltatime = actualtime - starttime

    com = "gcdata -c 0 -d %s %s" % (gcdatadir, gcfile)
    p = subprocess.Popen(com.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, errors = p.communicate()

    encoding='utf-8'
    output=str(output, encoding)

    #format = "%-3s %10s  %4d %02d %02d %02d %02d %12.6e %12.6e %5.1f %4s"
    format = "%4d %02d %02d %02d %02d %02d %12.6e %12.6e %5.1f %4s"

    # Default result
    #(year, month, day, hour, minute, second) = get_gcfile_date(gcfile)
    #result = format % (year, month, day, hour, minute, second, 0, 0, 0, "****")
    # Use cycle start time rather than actual measurement time for analysis date/time
    result = format % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second, 0, 0, 0, "****")

    if output:
        output = output.rstrip('\n')
        data = output.split('\n')
        for line in data:
            (year, month, day, hour, minute, second, port, channel, name, height, area, rt, bc) = line.split()
            #year = int(year)
            #month = int(month)
            #day = int(day)
            #hour = int(hour)
            #minute = int(minute)
            #second = int(second)    
            height = float(height)
            area = float(area)
            rt = float(rt)
            if name.lower() == gas:
                #result = format % (year, month, day, hour, minute, second, height, area, rt, bc)
                # Use cycle start time rather than actual measurement time for analysis date/time
                result = format % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second, height, area, rt, bc)

    #qcfile = "data.flow." + gas
    qcfile = "gc_qc.dat"
    # get GC qc data (same data for all sp on Magicc3) 
    try:
        fn = get_resource("gc_qc_datafile")
        f = open(fn, "r")
        lines = f.readlines()
        (j, flow, press, j, j) = lines[0].split()
        (j, smp_loop_press, j_room_press, j, j) = lines[1].split()
    except:
        flow = -99.9
        press = -99.9
        smp_loop_press = -99.9

        #relax_indicator=1
    result += "%7.1f %9.3f %9.3f %s %s" % (float(flow), float(press), float(smp_loop_press), relax_indicator, flag)
    result += " %d" % (deltatime.seconds)

    return(result)

##############################################################
def process_voltage(gas, tankid):

    datafile = gas + ".dat"

    if not os.path.exists(datafile):
        logging.error("In process_voltage, data file does not exist %s", datafile)
        return

    try:
        f = open(datafile)
    except:
        return

    line = f.readline()
    f.close()

    (t, val, sdv, n) = line.split()
    t = float(t)
    val = float(val)
    sdv = float(sdv)
    n = int(n)

    # Convert the timestamp to a date and time
    dt = datetime.datetime.fromtimestamp(t)

    format = "%3s %4d %02d %02d %02d %02d %02d %12.6e %9.3e %d"
    result = format % (tankid, dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, val, sdv, n)

    qcfile = "data.flow." + gas
    if os.path.exists(qcfile):
        fp = open(qcfile)
        for line in fp:
            (a, val, stdv, n) = line.split()
            result += "%7.1f" % (float(val))
        fp.close()

    datafile = "data." + gas
    fp = open(datafile, "a")
    fp.write(result + "\n")
    fp.close()



##############################################################
#def getCarouselStatus(q):
#    """ Get the message from the Queue 'q' and
#    determine if we are to stop or continue analysis.
#    If continue, also get number of flasks to analyze from carousel.
#    """
#
#    msg = q.get()
#
#    if "stop" in msg:
#        return "Stop", 0
#
#    else:
#        (s, numflasks) = msg.split()
#        numflasks = int(numflasks)
#        return "Continue", numflasks
#
##############################################################
#def CheckStatus():
#
#        sigfile = ".cont"
#        stopfile = ".stop"
#
#    numflasks = 8
#    status = "Continue"
#    while not os.path.exists(sigfile):
#
#        if os.path.exists(stopfile):
#            status = "Stop"
#            break
#
#        time.sleep(1)
#
#    if os.path.exists(".numflasks"):
#        f = open(".numflasks")
#        line = f.readline().strip("\n")
#        f.close()
#        numflasks = int(line)
#
#        return status, numflasks

##############################################################
# Call a separate program 'message' to show a popup window with a text message, 
# and an optional prompt and text box for entering a value.
#
# Input paramters:
#   msg - The message to display given as a string.
#   file - The message is the contents from a file with this name
#   prompt - Optional prompt string to display before a text input box
#   text - String to put in the text input box
#   nostop - Set to true if the 'Stop' button is not to be shown. A button
#      labeled 'Ok' will always be shown.
#
# Returns a string. The first word of the string will be either 'stop' or 'continue'.
#  Any additional words will be the text from the text input box.
#  The string will be only 'stop' or 'continue' if the optional text input box is not used.
#  An empty string means the user clicked on the close window button, not
#  on either the ok or stop buttons.
#  
#
# Example calling syntax:
#  answer = ShowMessage("this is a test")
#  answer = ShowMessage("this is a test', prompt="enter data here", text="a value")
#  answer = ShowMessage(file="input.txt")
#  answer = ShowMessage("Press 'ok' when ready", nostop=True)
#
# To pop up a message but not wait for an answer, use the nowait=True option:
#  answer = showMessage("this is a test", nowait=True)
#  answer = showMessage(file='message_file', nowait=True)
# In this case, answer will be an empty string ''
##############################################################
def ShowMessage(msg="", file="", prompt="", text="", nostop=False, nowait=False):

    args = ["message.py"]
    if text:
        args.append("-prompt")
        args.append(prompt)
        args.append("-text")
        args.append(text)
    if nostop:
        args.append("-nostop")

    p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE)

    if file:
        msg = open(file, 'r').read()

    if nowait:
        p.stdin.write(msg.encode())
        response = ""
    else:
        response = p.communicate(msg.encode())[0]

    return response.decode().strip("\n")







###################################################
def cvt_data(inst, filename, qc_filename=None, manifold=None, port=None, event_num=None):

        if inst.lower() == "picarro":
                result = cvt_picarro(filename, qc_filename)
        elif inst.lower() == "aerodyne":
                result = cvt_aerodyne(filename, qc_filename)
        elif inst.lower() == "aerolaser":
                result = cvt_aerolaser(filename, qc_filename)
        elif inst.lower() == "aeris":
                result = cvt_aeris(filename, qc_filename)
        elif inst.lower() == "lgr":
                result = cvt_lgr(filename, qc_filename)
        elif inst.lower() == "qc":
                result = cvt_qc(filename, manifold, port, event_num)
        else:
                result = ""

        return result

###################################################
# routine to save the qc data string
def cvt_qc (filename, manifold, port, event_num=None):
    # QC data:

    # OUTPUT LINE
    #YR MO DY HR MN SC INIT_PRESS FINAL_PRESS EVAC_TIME EVAC_PRESS ROOM_TEMP ROOM_PRESS IDLE_PRESS CHILLER_TEMP 
    #
    #temp storage of qc data. These are listed in config.py so they are available here 
    #and in run scripts.
    #        environment_qc_datafile = resources["environment_qc_datafile"]
    #        sys_evac_qc_datafile = resources["sys_evac_qc_datafile"]
    #        flask_press_datafile = resources["flask_press_datafile"]
    #        gc_qc_datafile = resources["gc_qc_datafile"]
    #        #aerodyne_qc_datafile = resources["aerodyne_qc_datafile"]
    #        #picarro_qc_datafile = resources["picarro_qc_datafile"]


    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get cycle end time (if no end time, assume 7 minute cycle, slightly shorter than true cycle time)
    endtime = get_end_time(cycle=True)
    if not endtime:
        dt = datetime.timedelta(minutes=7)
        endtime = starttime + dt

    # get cycle duration
    duration = endtime - starttime


    # get environmental qc data
    try:
        f = open(get_resource("environment_qc_datafile"),  "r")
        line = f.readline()

        (j, idle_press, room_press, room_temp, chiller_temp, scroll_pump_volt, j, j) = line.split()
        f.close()
    except:
        print("in cvt_qc did NOT open %s" % filename, file=sys.stderr)
        room_temp = -99.9
        idle_press = -99.9
        room_press = -99.9
        chiller_temp = -99.9
        scroll_pump_volt = -99.9

    #convert scroll pump pressure from volt to Torr (approximation from fit to reported Pirani 917 analog output in manual)
    # First function:  poly ---  [0.0004832813228159106, 0.004475011013640594, 0.06508023514569562, 0.08558483716994567]
    # Second function:  poly     [-20.4656340231495, 34.40905263917453, -19.025020314467294, 3.580573085736791]
    # Third function:  poly      [-65933.76154635355, 67968.57987942846, -23351.487776171878, 2674.083399875663]
    # voltage cutoff: 1.5   3.0

    scroll_pump_volt = float(scroll_pump_volt)  

    if scroll_pump_volt > 0:
        if scroll_pump_volt < 1.5:
            scroll_pump_press = 0.0004832813228159106 + 0.004475011013640594*scroll_pump_volt + 0.06508023514569562*pow(scroll_pump_volt, 2) + 0.08558483716994567*pow(scroll_pump_volt,3)
        elif scorll_pump_volt < 3.0:
            scroll_pump_press = -20.4656340231495 + 34.40905263917453*scroll_pump_volt+ -19.025020314467294*pow(scroll_pump_volt, 2) + 3.580573085736791*pow(scroll_pump_volt, 3)
        else:
            scroll_pump_press = -65933.76154635355 + 67968.57987942846*scroll_pump_volt+ -23351.487776171878*pow(scroll_pump_volt, 2) + 2674.083399875663*pow(scroll_pump_volt, 3)
    else:
        scroll_pump_press = -99.9
        
    
    # get system evac data
    try:
        f = open(get_resource("sys_evac_qc_datafile"),"r")
        lines = f.readlines()
        (initial_evac_time, initial_evac_press) = lines[0].split()
        (evac_time, evac_press) = lines[1].split()
        f.close()
    except:
        evac_time = -99.9
        evac_press = -99.9

    # get flask pressure (initial and final)
    try:
        f = open(get_resource("flask_press_datafile"),"r")
        lines = f.readlines()
        (j, init_press,j, j, j) = lines[0].split()
        (j, final_press, j, j) = lines[1].split()
        f.close()
    except:
        init_press = -99.9
        final_press = -99.9

    # get pfp and flask port evac qc data (time to 1Torr, time to 100 mTorr, final press)
    port_evac_datafile = "port_evac_%s.dat" % event_num
    if event_num and os.path.exists(port_evac_datafile):
        f = open(port_evac_datafile,"r")
        line = f.readline()
        (port_evac_time1, port_evac_time2, port_evac_final_press, port_evac_time) = line.split()
        f.close()
        os.remove(port_evac_datafile)
    else:
        port_evac_time1 = -99
        port_evac_time2 = -99
        port_evac_final_press = -99.999
        port_evac_time = -99
    
    # create output string
    result  = "%4d %02d %02d %02d %02d %02d " % (int(starttime.year), int(starttime.month), 
            int(starttime.day), int(starttime.hour), int(starttime.minute), int(starttime.second))
    result += "%2s %3s " % (manifold, port)
    result += "%5d " % (duration.seconds)
    result += "%9.2f " % (float(init_press))
    result += "%9.2f " % (float(final_press))
    result += "%5.1f %9.2f " % (float(initial_evac_time), float(initial_evac_press))
    result += "%5.1f %9.2f " % (float(evac_time), float(evac_press))
    result += "%9.2f " % (float(room_temp))
    result += "%9.2f " % (float(room_press))
    result += "%9.2f " % (float(idle_press))
    result += "%9.2f " % (float(chiller_temp))
    result += "%9.4f " % (float(scroll_pump_press))
    result += "%4d %4d %9.3f %4d" % (int(port_evac_time1), int(port_evac_time2), float(port_evac_final_press), int(port_evac_time))
    print("YR MO DY HR MN SC MANIFOLD PORT INIT_PRESS FINAL_PRESS INIT_EVAC_TIME INIT_EVAC_PRESS EVAC_TIME EVAC_PRESS ROOM_TEMP ROOM_PRESS IDLE_PRESS CHILLER_TEMP port_evac_time1 port_evac_time2 port_evac_final_P port_evac_time scroll_pump_press", file=sys.stderr)
    print("cvt_data QC result: %s" % result, file=sys.stderr)

    return result

###################################################
# routine to split the data string from the Aerodyne N2O/CO insturment and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the Aerodyne N2O CO anaylzer on the Magicc_3 flask system
# Reads the qc file aerodyne_qc.dat for pressures, flow rates, etc
def cvt_aerodyne (filename, qc_filename):

    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get flow rate, pressure from file qc.dat file
    try:
        f = open(qc_filename, "r")
        lines = f.readlines()
        (j, flow, j, j) = lines[0].split()
        f.close()
    except:
        logging.info("in cvt_aerodyne, no aerodyen qc file")
        inlet_press = -99.9
        flow = -99.9
        flask_press = -99.9

    #test aerodyne.dat to make sure it exists and is not empty
    # can get empty files b/c comms errors with AR
    if os.path.exists(filename) == False or os.path.getsize(filename) == 0:
        try:
            f = open("/home/magicc/sys.cycle_start")
            dt = f.readline()
            f.close()
        except:
            #dt = "9999-9-9 0:0:0"
            tmp_dt = datetime.datetime.now()
            dt = "%s-%02d-%02d  %02d:%02d:%02d" % (tmp_dt.year, tmp_dt.month, tmp_dt.day, tmp_dt.hour, tmp_dt.minute, tmp_dt.second)
            

        # 2018-03-27 11:36:49
        (date, time) = dt.split()
        (yr, mo, dy) = date.split("-")
        (hr, mn, sc) = time.split(":")
        d = "%s %s %s %s %s %s" % (yr, mo, dy, hr, mn, sc)

        line = "%s -999.9 -9 0 -999.9 -9 0 -999.9 -9 0 -999.9 -9 0 -99.9 -99.9 -99.9 -99.9" % (d)
                
    else:

        try:
            f = open(filename, "r")
        except:
            logging.error("cvt_aerodyne could not open file %s", filename)
            sys.exit()

        line = f.readline()
        f.close()


    # from datafile exchange
    #2025  3  5 16 35 34              : yr, mo, dy, hr, mn, sc
    #3824033729.454576 8.803399 30    : j, j, j
    #130.522397 0.040458 30           : co, co_sd, co_n
    #937.025740 2.450928 30           : j, j, j
    #331.373753 0.039803 30           : n2o, n2o_sd, n2o_n
    #400000.000000 0.000000 30        : j,j,j
    #331.373087 0.040005 30           : j, j, j  Is this water corrected values?
    #330.000000 0.000000 30           : j,j,j
    #-23236.231467 13554.939103 30    : j,j,j
    #3824033729.454576 8.803399 30    : j,j,j
    #2451.608667 0.081695 30          : j,j,j
    #-584.020000 0.009097 30          : j,j,j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #49.915982 0.000933 30            : cell_P, cell_P_sd, cell_P_n
    #296.913863 0.013318 30           : cell_T, cell_T_sd, cell_T_n
    #-116.568903 0.000350 30          : j, j, j
    #298.657093 0.077144 30           : j, j, j   ? another temperature, not sure where
    #2.506895 0.000013 30             : j, j, j
    #301.853980 0.022742 30           : j, j, j
    #4236.000000 0.000000 30          : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #11.692446 0.000373 30            : j, j, j
    #122.584100 0.299760 30           : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #10.704333 0.187996 30            : j, j, j
    #61.563867 0.010830 30            : j, j, j
    #40.487333 0.301078 30            : j, j, j
    #257.212500 0.011331 30           : j, j, j
    #3.000000 0.000000 30             : j, j, j
    #20.189000 0.257499 30            : j, j, j
    #257.212500 0.011331 30           : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #0.000000 0.000000 30             : j, j, j
    #1.000000 0.000000 30             : j, j, j
    #3650.959333 21.152694 30         : j, j, j
    #5827.397000 246.560575 30        : j, j, j
    #-32777.963333 1131.158944 30     : j, j, j
    #64329.193333 2553.439366 30      : j, j, j
    #-63160.100000 2837.086394 30     : j, j, j
    #24042.073333 1242.274389 30      : j, j, j
    #7287.899333 57.766712 30         : j, j, j
    #-20372.846667 371.275461 30      : j, j, j
    #46161.006667 948.633304 30       : j, j, j
    #-59742.246667 1204.531221 30     : j, j, j
    #37551.293333 760.159838 30       : j, j, j
    #-9216.436667 190.763553 30       : j, j, j

    #print(line, file=sys.stderr)
    values = line.split()
    #print("len(values): %s" % len(values), file=sys.stderr)
    ayr = values[0]
    amo = values[1]
    ady = values[2]
    ahr = values[3]
    amn = values[4]
    asc = values[5]
    co = values[9]
    co_sd = values[10]
    co_n = values[11]
    n2o = values[15]
    n2o_sd = values[16]
    n2o_n = values[17]
    cell_press = values[45]
    cell_press_sd = values[46]
    cell_press_n = values[47]
    cell_temp = values[48]
    cell_temp_sd = values[49]
    cell_temp_n = values[50]

    #print("date/time:   %s %s %s %s %s %s" % (ayr, amo, ady, ahr, amn, asc), file=sys.stderr)
    #print("co:          %s %s %s" % (co, co_sd, co_n), file=sys.stderr)
    #print("n2o:         %s %s %s" % (n2o, n2o_sd, n2o_n), file=sys.stderr)
    #print("Press:       %s %s %s" % (cell_press, cell_press_sd, cell_press_n), file=sys.stderr)
    #print("Temp:        %s %s %s" % (cell_temp, cell_temp_sd, cell_temp_n), file=sys.stderr)
    #sys.exit("clean exit")

    # get time diff between actual and start 
    actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
    deltatime = actualtime - starttime

    # Use actual measurement time rather than cycle start time for cocal system
    #result  = "%4d %02d %02d %02d %02d %02d " % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second)
    result  = "%4d %02d %02d %02d %02d %02d " % (actualtime.year, actualtime.month, actualtime.day, actualtime.hour, actualtime.minute, actualtime.second)
    result += "%12.4f %12.4f %d" % (float(n2o), float(n2o_sd), int(n2o_n))
    result += "%12.4f %12.4f %d" % (float(co), float(co_sd), int(co_n))
    #result += "%15.4f %15.4f %d" % (float(h2o), float(h2o_sd), int(h2o_n))
    result += "%12.3f %12.3f %d" % (float(cell_temp), float(cell_temp_sd), int(cell_temp_n))
    result += "%12.3f %12.3f %d" % (float(cell_press), float(cell_press_sd), int(cell_press_n))
    result += " %9.2f" % (float(flow))
    #result += " %d" % (deltatime.seconds)

    print("Aerodyne result: %s" % (result), file = sys.stderr)

    return result


###################################################
# routine to split the data string from the AeroLaser CO insturment (VURF) and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the AeroLaser CO anaylzer on the CO Cal system
# Reads the qc file aerolaser_qc.dat for flow rates
def cvt_aerolaser (filename, qc_filename):

    #get cycle start time
    starttime = get_start_time(cycle=True)
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get flow rate, pressure from file qc.dat file
    # [magicc@magicc-3 ~]$ more aerodyne_qc.dat 
    #  1488393307 729.053880 -0.148024  0 0
    #  1488393337 -0.1430777 0.0 1

    try:
        f = open(qc_filename, "r")
        lines = f.readlines()
        (j, j, j, j, j, j, cell_T, cell_T_sd, cell_T_n) = lines[0].split()
        (j, j, j, j, j, j, cell_P, cell_P_sd, cell_P_n) = lines[1].split()
        if len(lines) == 3:
            (j, flow, j, j) = lines[2].split()
        else:
            # there is no flow measurement (line 3) for zero air
            flow = -99.9
            f.close()
    except:
        logging.info("no qc file")
        flow = -99.9
        cell_T = -99.9
        cell_P = -99.9
        cell_P_sd = -99.9
        cell_P_n = -99

    #test aerolaser.dat to make sure it exists and is not empty
    # can get empty files b/c comms errors with AR
    if os.path.exists(filename) == False or os.path.getsize(filename) == 0:
        try:
            f = open("/home/cocal/sys.cycle_start")
            dt = f.readline()
            f.close()
        except:
            dt = "9999-9-9 0:0:0"


        # 2018-03-27 11:36:49
        (date, time) = dt.split()
        (yr, mo, dy) = date.split("-")
        (hr, mn, sc) = time.split(":")
        d = "%s %s %s %s %s %s" % (yr, mo, dy, hr, mn, sc)

        #line = "%s -999.9 -9 0 -99.9" % (d)
        line = "%s -999.9 -9 0 -99.9 -99.9 -99.9" % (d)

    else:

        try:
            f = open(filename, "r")
        except:
            logging.error("cvt_vurf could not open file %s", filename)
            sys.exit()

        line = f.readline()
        f.close()

    #print >> sys.stderr, "line:  %s" % line
    (ayr, amo, ady, ahr, amn, asc, co, co_sd, co_n) = re.split('[\s]+', line.strip())

    # get time diff between actual and start of cycle
    actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
    deltatime = actualtime - starttime

    #result  = "%4d %02d %02d %02d %02d %02d " % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second)
    # NOT USING CYCLE START TIME FOR ANALYSIS TIME ON CO CAL SYSTEM
    result  = "%4d %02d %02d %02d %02d %02d " % (actualtime.year, actualtime.month, actualtime.day, actualtime.hour, actualtime.minute, actualtime.second)
    result += "%15.4f %15.4f %d" % (float(co), float(co_sd), int(co_n))
    result += " %9.2f %9.2f %9.2f %9.2f %d" % (float(flow), float(cell_T), float(cell_P), float(cell_P_sd), int(cell_P_n))
    #result += " %d" % (deltatime.seconds)

    print("Aerolaser result: %s" % (result), file = sys.stderr)

    return result



###################################################
###################################################
# routine to split the data string from the Aeris N2O/CO insturment and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the Aeris N2O CO anaylzer on the CO Cal system
# Reads the qc file lgr_qc.dat for pressures, flow rates, etc
def cvt_aeris (filename, qc_filename):

    #get cycle start time 
    starttime = get_start_time(cycle=True)
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get flow rate, pressure from file qc.dat file
    # [magicc@magicc-3 ~]$ more aerodyne_qc.dat 
    #  1488393307 729.053880 -0.148024  0 0
    #  1488393337 -0.1430777 0.0 1

    try:
        f = open(qc_filename, "r")
        lines = f.readlines()
        (j, flow, j, j) = lines[0].split()
        f.close()
    except:
        logging.info("no qc file")
        flow = -99.9

    #test .dat to make sure it exists and is not empty
    # can get empty files b/c comms errors
    if os.path.exists(filename) == False or os.path.getsize(filename) == 0:
        try:
            f = open("/home/cocal/sys.cycle_start")
            dt = f.readline()
            f.close()
        except:
            dt = "9999-9-9 0:0:0"

        # 2018-03-27 11:36:49
        (date, time) = dt.split()
        (yr, mo, dy) = date.split("-")
        (hr, mn, sc) = time.split(":")
        d = "%s %s %s %s %s %s" % (yr, mo, dy, hr, mn, sc)

        line = "%s -999.9 -9 0 -999.9 -9 0 -999.9 -9 0 -999.9 -9 0 -999.9 -9 0 -99.9" % (d)

    else:

        try:
            f = open(filename, "r")
        except:
            logging.error("cvt_lgr could not open file %s", filename)
            sys.exit()

        line = f.readline()
        f.close()

    #   Aeris data line format
    #2024 11  4 12 25 48       #hm date/time       #ayr,amo,ady,ahr,amn,asc   #1,2,3,4,5,6
    #11.000000 0.000000 10     #inst mo            #j,j,j                     #7,8,9
    #4.000000 0.000000 10      #inst dy            #j,j,j                     #10,11,12
    #2024.000000 0.000000 10   #inst yr            #j,j,j                     #13,14,15
    #12.000000 0.000000 10     #inst hr            #j,j,j                     #16,17,18
    #27.000000 0.000000 10     #inst mn            #j,j,j                     #19,20,21
    #15.547400 3.007283 10     #inst sc            #j,j,j                     #22,23,24
    #1.000000 0.000000 10      #port?              #j,j,j                     #25,26,27
    #140.017200 0.050268 10    #cell press         #cell_P,cell_P_sd,cell_P_n #28,29,30
    #42.724050 0.003968 10     #gas temp           #cell_T,cell_T_sd,cell_T_n #31,32,33
    #40.530560 0.000467 10     #unk temp           #j,j,j                     #34,35,36
    #27.489340 0.096431 10     #unk temp           #j,j,j                     #37,38,39
    #45.615620 0.005608 10     #unk temp           #j,j,j                     #40,41,42
    #52.002900 0.000000 10     #unk temp           #j,j,j                     #43,44,45
    #42.724050 0.003968 10     #repeat gas T       #j,j,j                     #46,47,48
    #97172.800000 20.980414 10 #laser T readout    #j,j,j                     #49,50,51
    #60082.700000 6.498718 10  #detector T readout #j,j,j                     #52,53,54
    #-3.423782 0.005020 10     #unknown            #j,j,j                     #55,56,57
    #0.064283 0.000066 10      #unknown            #j,j,j                     #58,59,60
    #-0.000054 0.000000 10     #unknown            #j,j,j                     #61,62,63
    #-0.000000 0.000000 10     #unknown            #j,j,j                     #64,65,66
    #0.192253 0.000134 10      #unknown            #j,j,j                     #67,68,69
    #1.557103 0.012682 10      #unknown            #j,j,j                     #70,71,72
    #1.003090 0.000000 10      #unknown            #j,j,j                     #73,74,75
    #0.462033 0.000804 10      #unknown            #j,j,j                     #76,77,78
    #1.405127 0.011636 10      #unknown            #j,j,j                     #79,80,81
    #0.965875 0.000000 10      #unknown            #j,j,j                     #82,83,84
    #-0.762092 0.028853 10     #unknown            #j,j,j                     #85,86,87
    #0.044476 0.000215 10      #unknown            #j,j,j                     #88,89,90
    #-0.000006 0.000001 10     #unknown            #j,j,j                     #91,92,93
    #-0.000000 0.000000 10     #unknown            #j,j,j                     #94,95,96
    #0.177173 0.000122 10      #unknown            #j,j,j                     #97,98,99
    #1.880285 0.009774 10      #unknown            #j,j,j                     #100,101,102
    #1.000000 0.000000 10      #unknown            #j,j,j                     #103,104,105
    #0.091514 0.000140 10      #unknown            #j,j,j                     #106,107,108
    #0.795116 0.010919 10      #unknown            #j,j,j                     #109,110,111
    #-0.989410 0.000000 10     #unknown            #j,j,j                     #112,113,114
    #2.670978 0.000086 10      #unknown            #j,j,j                     #115,116,117
    #14.826620 0.000249 10     #Ramp Amplitude     #j,j,j                     #118,119,120
    #0.332630 0.000232 10      #N2O                #n2o,n2o_sd,n2o_n          #121,122,123
    #0.336316 0.000234 10      #N2O dry            #j,j,j                     #124,125,126
    #8562.360000 14.799866 10  #H2O                #h2o,h2o_sd,h2o_n          #127,128,129
    #0.167889 0.000227 10      #CO                 #co,co_sd,co_n             #130,131,132
    #0.169676 0.000231 10      #CO dry             #j,j,j                     #133,134,135
    #14688.200000 1.316561 10  #unkown             #j,j,j                     #136,137,138
    #40.420000 0.048305 10     #FET Temperature    #j,j,j                     #139,140,141
    #40.420000 0.048305 10     #FET Temperature    #j,j,j                     #139,140,141
    #0.000000 0.000000 10      #unknown            #j,j,j                     #142,143,144
    #0.000000 0.000000 10      #unknown            #j,j,j                     #145,146,147
    #0.000000 0.000000 10      #unknown            #j,j,j                     #148,149,150
    #0.000000 0.000000 10      #unknown            #j,j,j                     #151,152,153
    #59.100000 27.306694 10    #unknown            #j,j,j                     #154,155,156
    #1.000000 0.000000 10      #unknown            #j,j,j                     #157,158,159

    values = re.split('[\s]+', line.strip())


    ayr = values[0]
    amo = values[1]
    ady = values[2]
    ahr = values[3]
    amn = values[4]
    asc = values[5]
    cell_P = values[27]
    cell_P_sd = values[28]
    cell_P_n = values[29]
    cell_T = values[30]
    cell_T_sd = values[31]
    cell_T_n = values[32]
    n2o = values[120]
    n2o_sd = values[121]
    n2o_n = values[122]
    h2o = values[126]
    h2o_sd = values[127]
    h2o_n = values[128]
    co = values[129]
    co_sd = values[130]
    co_n = values[131]


    # get time diff between actual and start of cycle
    actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
    deltatime = actualtime - starttime

    #result  = "%4d %02d %02d %02d %02d %02d " % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second)
    # NOT USING CYCLE START TIME FOR ANALYSIS TIME ON CO CAL SYSTEM
    result  = "%4d %02d %02d %02d %02d %02d " % (actualtime.year, actualtime.month, actualtime.day,
            actualtime.hour, actualtime.minute, actualtime.second)
    result += "%15.4f %15.4f %d" % (float(n2o)*1000, float(n2o_sd)*1000, int(n2o_n))
    result += "%15.4f %15.4f %d" % (float(co)*1000, float(co_sd)*1000, int(co_n))
    result += "%15.4f %15.4f %d" % (float(h2o), float(h2o_sd), int(h2o_n))
    result += "%12.3f %12.3f %d" % (float(cell_T), float(cell_T_sd), int(cell_T_n))
    result += "%12.3f %12.3f %d" % (float(cell_P), float(cell_P_sd), int(cell_P_n))
    result += " %9.2f" % (float(flow))
    #result += " %d" % (deltatime.seconds)

    print("aeris result: %s" % (result), file = sys.stderr)

    return result







###################################################
# routine to split the data string from the Picarro and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the Picarro G2301 anaylzer on the Magicc_3 flask system
def cvt_picarro (filename, qc_filename):

    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get flow rate, pressure from file qc.dat
    # for this system where measuring two inst's at the same time, gc_raw.dat is the raw
    # qc scan data.  qc.dat is created before calling cvt_data so correct press and flow
    # is listed in the qc.dat file.
    try:
        f = open(qc_filename, "r")
        lines = f.readlines()
        (j, flow, inlet_press, j, j) = lines[0].split()
        (j, flask_press, j, j) = lines[1].split()
        f.close()
    except:
        logging.info("no qc file")
        inlet_press = -99.9
        flow = -99.9
        flask_press = -99.9

    try:
        f = open(filename, "r")
    except:
        logging.error("cvt_picarro could not open file %s", filename)
        sys.exit()

    line = f.readline()
    f.close()

    #  picarro.dat
    #[magicc@magicc3 ~]more picarro.dat 
    #2017  1 20 10 58 14           yr mo dy hr mn sc
    #0.000000 0.000000 0           j, j, j
    #139.998971 0.008475 31        cell_press
    #44.999910 0.000114 31         cell_temp
    #40.500000 0.000000 31         das_temp
    #45.073465 0.000091 31         etalon_temp
    #44.999697 0.000091 31         warmbox_temp
    #2.000000 0.816497 31          sp
    #496.830460 2.277691 10        co2
    #500.917030 2.154420 10        co2_dry
    #2.106636 0.000761 11          ch4
    #2.122955 0.000685 11          ch4_dry
    #0.603360 0.001291 10          h2o
    #20170120.000000 0.000000 10   j, j, j
    #0.000000 0.000000 0           j, j, j

    (ayr, amo, ady, ahr, amn, asc,
     j, j, j,
     cell_press, cell_press_sd, cell_press_n,
     cell_temp, cell_temp_sd, cell_temp_n,
     das_temp, das_temp_sd, das_temp_n,
     etl_temp, etl_temp_sd, etl_temp_n,
     wb_temp, wb_temp_sd, wb_temp_n,
     j,j,j,
     co2, co2_sd, co2_n,
     co2_dry, co2_dry_sd, co2_dry_n,
     ch4, ch4_sd, ch4_n,
     ch4_dry, ch4_dry_sd, ch4_dry_n,
     h2o, h2o_sd, h2o_n,
     j, j, j) = re.split('[\s]+', line.strip())

    # get time diff between actual and start
    actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
    deltatime = actualtime - starttime

    # Use cycle start time rather than actual measurement time for analysis date/time, record time delta (actual - starttime) in QC file
    result  = "%4d %02d %02d %02d %02d %02d " % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second)
    result += " %12.4f %12.4f %d" % (float(co2), float(co2_sd), int(co2_n))
    result += " %12.4f %12.4f %d" % (float(ch4)*1000.00, float(ch4_sd)*1000.00, int(ch4_n))
    result += " %12.4f %12.4f %d" % (float(h2o), float(h2o_sd), int(h2o_n))
    result += " %9.4f %8.4f %d" % (float(cell_press), float(cell_press_sd), int(cell_press_n))
    result += " %8.4f %8.4f %d" % (float(cell_temp), float(cell_temp_sd), int(cell_temp_n))
    result += " %8.4f %8.4f %d" % (float(das_temp), float(das_temp_sd), int(das_temp_n))
    result += " %8.4f %8.4f %d" % (float(etl_temp), float(etl_temp_sd), int(etl_temp_n))
    result += " %8.4f %8.4f %d" % (float(wb_temp), float(wb_temp_sd), int(wb_temp_n))
    result += " %9.2f %9.2f %9.2f" % (float(inlet_press),float(flow), float(flask_press))
    result += " %d" % (deltatime.seconds)

    #print >> sys.stdout, result
    return result


#######################################################################






############################################################
# write most recent nl filename to file
def write_last_nl_timestamp(timestamp):

        fn = ".last_nl_rawfile"
        try:
                f = open(fn, "w")
        except:
                logging.error("can't open file %s for writing" % fn)
                return

        print(timestamp, file=f)
        f.close()
        return

############################################################
# read most recent nl filename to file
def get_last_nl_timestamp():

        fn = ".last_nl_rawfile"
        try:
                f = open(fn)
        except:
                logging.error("can't open file %s " % fn)
                return
        timestamp = f.readline().rstrip('\n\r')
        f.close()
        return timestamp

