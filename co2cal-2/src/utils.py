#!/usr/bin/python

import os
import sys
import datetime
#import MySQLdb
import shutil
import subprocess
import logging
import zipfile
import re
import configparser


import config
#import ccg_dates

sys.path.append("%s/src/hm" % config.HOMEDIR)
sys.path.append("/ccg/python/ccglib")

import ccg_dbutils
import ccg_db_conn

# for access to resources listed in co2cal.conf file
import action
act = action.Action(config.CONFFILE)
# usage: manifold, portnum = act.resources[config.ref_name.lower()].split()
# usage to get device conf file name:  devconfig = act.config[device]  

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
def backup_data_files():
        backupdir = "%s/data_file_backup" % (os.environ["HOME"])
        
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
def make_raw(system, inst, type, qc=False, gas="", rawfile="", stdset="", serialnum="", pressure="", regulator="",manifold="",portnum=""):

    if inst.lower() not in ["lgr", "picarro", "aerodyne"]:
        print("Unknown inst in make_raw '%s'. Should be on of Aerodyne, Picarro, gc, gc1, gc2" % inst, file=sys.stderr)
        sys.exit()
    if type not in ["nl", "flask", "cals", "aircraft", "pfp", "zero_air_cals", "qc"]:
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
        #datafile = "data.%s" % inst.lower()
        datafile = get_resource("datafile", inst)
        bcodes = False
        method = "CRDS"
        refid = ["R0"]
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc analysis_time_delta(secs) h2o(percent) cell_press(Torr) cell_temp(C) das_temp(C) etl_temp(C) wb_temp(C) roomT(C) chillerT(C) flow(ml/min) inlet_press(Torr)"
        flag = "."  

    elif inst.lower() == "qc":
        pass

    elif inst.lower() == "aerodyne":
        #datafile = "data.%s" % inst.lower()
        datafile = get_resource("datafile", inst)
        bcodes = False
        method = "QC-TILDAS"
        refid = ["R0"]
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc analysis_time_delta(secs)  cellT(K) cellP(Torr) roomT(C) chillerT(C) flow(ml/min) inlet_press(Torr)"
        flag = "."  

    elif inst.lower() == "lgr":
        #datafile = "data.%s" % inst.lower()
        datafile = get_resource("datafile", inst)
        bcodes = False
        method = "offaxis-ICOS"
        refid = ["R0"]
        datalist = "type gas yr mo dy hr mn sc sig sig_sd sig_n flag"
        qclist = "type gas yr mo dy hr mn sc analysis_time_delta(secs) cellP(Torr) cellT(C) roomT(C) chillerT(C) flow(ml/min) inlet_press(Torr)"
        flag = "."  

    else:
        datafile = "data.%s" % inst.lower()
        bcodes = False
        method = False
        refid = ["R0"]
        datalist = " "
        qclist = " "
        flag = "."  
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

        (sset, label, sn, std_manifold, port, press, reg) = line.split()
        
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
                output += "%s Manifold:   %s\n" % (label, std_manifold)
                output += "%s Port:   %s\n" % (label, port)

    f.close()

    if type == "cals":
        output += "N Sample Tanks: %s\n" % (ntanks)
        output += "W:              %s\n" % (serialnum)
        output += "W Manifold:      %s\n" % (manifold)
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

    #common rawfile format 
    rawfile_format = "%3s  %-12s %5s %2s %2s %2s %2s %2s %s %s %s %s\n"

    # for each inst type, read data file and make raw file output strings
    try:
        f = open(datafile)
    except:
        return
    
    for line in f:
        line = line.strip("\n")
        #print >> sys.stderr, line

        if inst.lower() == "picarro":
            (gastype, g, yr, mo, dy, hr, mn, sc, co2, co2_sd, co2_n, ch4, ch4_sd, ch4_n,h2o, h2o_sd, h2o_n,
             cell_press, cell_press_sd, cell_press_n, cell_temp, cell_temp_sd, cell_temp_n,
             das_temp, das_temp_sd, das_temp_n, etl_temp, etl_temp_sd, etl_temp_n,
                 wb_temp, wb_temp_sd, wb_temp_n, 
             flow, press, rT, cT, delta_time) = line.split()

            # append to output strings 
            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %s %s %s %s %s %s %s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, delta_time, h2o, cell_press, cell_temp, das_temp, 
                        etl_temp, wb_temp, rT, cT, flow, press )
            elif gas.lower() == "co2":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc, co2, co2_sd, co2_n, flag)
            elif gas.lower() == "ch4":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc, ch4, ch4_sd, ch4_n, flag)

        elif inst.lower() == "qc":
            pass

        elif inst.lower() == "lgr":

            (gastype, g, yr, mo, dy, hr, mn, sc, 
                co2, co2_sd, co2_n,
                c13, c13_sd, c13_n,
                o18, o18_sd, o18_n,
                o17, o17_sd, o17_n,
                cell_press, cell_press_sd, cell_press_n,
                cell_temp, cell_temp_sd, cell_temp_n,
                j,j,j,
                flow, inlet_press, rT, cT,
                co2_626_ppm, co2_626_ppm_sd, co2_626_ppm_n,
                co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n,
                co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n,
                delta_time) = line.split()

            # append to output strings  
        #qclist = "type gas yr mo dy hr mn sc analysis_time_delta(secs) cellP(Torr) cellT(C)  roomT(C) chillerT(C) flow(ml/min) inlet_press(Torr)"
            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %s %s %s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, delta_time, 
                        cell_press, cell_temp, rT, cT, flow, inlet_press)
            elif gas.lower() == "co2":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co2_626_ppm, co2_626_ppm_sd, co2_626_ppm_n, flag)
            elif gas.lower() == "co2c13":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n, flag)
            elif gas.lower() == "co2o18":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n, flag)


        elif inst.lower() == "aerodyne":

            (gastype, g, yr, mo, dy, hr, mn, sc, 
                co2_626_ppm, co2_626_ppm_sd, co2_626_ppm_n,
                co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n,
                co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n,
                co2_627_ppm, co2_627_ppm_sd, co2_627_ppm_n,
                cell_temp, cell_temp_sd, cell_temp_n,
                cell_press, cell_press_sd, cell_press_n,
                flow, inlet_press, rT, cT, delta_time) = line.split()

            # append to output strings  
            if qc:
                format = "%3s  %-12s %4s %2s %2s %2s %2s %2s %5s %s %s %s %s %s\n"
                output += format % (gastype, g, yr, mo, dy, hr, mn, sc, delta_time, 
                        cell_temp, cell_press, rT, cT, flow, inlet_press)
            elif gas.lower() == "co2":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co2_626_ppm, co2_626_ppm_sd, co2_626_ppm_n, flag)
            elif gas.lower() == "co2c13":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n, flag)
            elif gas.lower() == "co2o18":
                output += rawfile_format % (gastype, g, yr, mo, dy, hr, mn, sc,
                            co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n, flag)


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
    #print >> outfile, output
    print(output, file=outfile)



######################################################################
def save_files(type, inst, gas, rawfile, data=False, qc=False ):

    if type.lower() not in ["nl", "flask", "cals", "aircraft", "pfp"]:
            print("Unknown file type in save_files '%s'. Should be one of 'flask', 'nl', cals, zero_air_cals'" % type, file=sys.stderr)
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
        destdir = "/ccg/%s_qc/%s/%s/" %(config.SYSTEM_NAME,type.lower(), year)  
    else:
        if not data and not qc:
            destdir = "/ccg/%s/%s/%s/raw/%d/" % (gas.lower(), type.lower(), config.SYSTEM_NAME.lower(), year)
        elif data:
            destdir = "/ccg/%s/%s/%s/data/%d/" % (gas.lower(), type.lower(), config.SYSTEM_NAME.lower(), year)
        elif qc:
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
######################################################################
def process_data(type, rawfile, stdset=""):

        if type == "nl":
                if stdset.upper() == "MANUAL":
                        #don't drop any tanks when running manual response curve
                        #overwrite co2cal-2 system default nulltanks listed in nlpro
                        #os.system("/ccg/bin/nlpro.py --nulltanks='default' -u %s" % (rawfile))
                        os.system("/ccg/python/python /ccg/bin/nlpro.py --nulltanks='default' -u %s" % (rawfile))
                else:
                        #os.system("/ccg/bin/nlpro.py -u %s" % (rawfile))
                        os.system("/ccg/python/python /ccg/bin/nlpro.py -u %s" % (rawfile))

        elif type == "flask" or type == "aircraft" or type == "pfp":
                #os.system("/ccg/bin/flpro.py -u -v %s >> /home/magicc/flpro.log 2>&1" % (rawfile))
                os.system("/ccg/python/python /ccg/bin/flpro.py -u -v %s >> /home/magicc/flpro.log 2>&1" % (rawfile))

        elif type == "cals":
                #os.system("/ccg/bin/calpro.py  -u %s" % (rawfile))
                os.system("/ccg/python/python /ccg/bin/calpro.py  -u %s" % (rawfile))

        elif type == "zero_air_cals":
                #os.system("/ccg/bin/calpro.py -u %s" % (rawfile))
                os.system("/ccg/python/python /ccg/bin/calpro.py -u %s" % (rawfile))

        else:
                print("Unknown type in processdata: %s. Must be one of 'nl', 'flask', 'aircraft', 'cals' or 'zero_air_cals'" % (type), file=sys.stderr)


######################################################################
# Process to call the QC program for flasks
######################################################################
def qc_data(type, rawfile):

        if type == "nl":
            pass
        elif type == "flask" or type == "aircraft" or type == "pfp":
                os.system("/ccg/bin/flflag.py -u  %s" % (rawfile))
        elif type == "cals":
            pass
        elif type == "zero_air_cals":
            pass
        else:
                print("Unknown type in qc_data: %s. Must be one of 'nl', 'flask', 'aircraft', 'cals' or 'zero_air_cals'" % (type), file=sys.stderr)





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
            return "NoId", "NoSernum"
    
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
    newfilename = "%4d%02d%02d%02d%02d.txt" % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute)

    # Determine the zip archive name
    ziparchive = get_archive_name(sys, inst_id)

    if ziparchive:
        # Open the zip archive, add gcfile to it with a new name
        logging.info("Add gcfile %s to zip archive %s." % (newfilename, ziparchive) )
        zip = zipfile.ZipFile(ziparchive, "a")
        zip.write(gcfile, newfilename, zipfile.ZIP_DEFLATED)
        zip.close()

######################################################################
# Update/Insert event data into the mysql database.
# Project is one of 'flask' or 'aircraft'.
######################################################################
#def updateEvents(project, samplefile="sample_table"):
#
#    events = []
#
#    project = project.lower()
#    if project not in ['flask', 'aircraft', 'pfp']:
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

######################################################################



######################################################################
# Reset sort_number in refgas manager DB
def reset_refgasmanager_sort(primary_key=""):
    #the update statement is:
    #update refgas_orders.calrequest set sort_order=null where num=primary_key

    database = 'refgas_orders'
    table = 'calrequest'

    # make sure primary key is an integer
    try:
        int(primary_key)
    except:
        print("primary_key %s is not an integer" % primary_key, file=sys.stderr)
        return

    # connect to mysql database
    db = ccg_dbutils.dbUtils()
    #db, c = ccg_dbutils.dbConnect(database)

    sql = "call refgas_orders.rgm_calibrationFinished(%s);" % primary_key
    db.doquery(sql)
    #c.execute(sql)
    #db.commit()

    #c.close()
    #db.close()






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
    # get_resource["gc_qc_datafile"]
    try:
        f = open(get_resource("gc_qc_datafile"),"r")
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

#   if os.path.exists(qcfile):
#       fp = open(qcfile)
#       for line in fp:
#           (a, val, sdv, n) = line.split()
#           result += "%7.1f" % (float(val))
#       fp.close()

    #datafile = "data." + gas
    #fp = open(datafile, "a")
    #fp.write(result + "\n")
    #fp.close()
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
def getCarouselStatus(q):
    """ Get the message from the Queue 'q' and
    determine if we are to stop or continue analysis.
    If continue, also get number of flasks to analyze from carousel.
    """

    msg = q.get()

    if "stop" in msg:
        return "Stop", 0

    else:
        (s, numflasks) = msg.split()
        numflasks = int(numflasks)
        return "Continue", numflasks

##############################################################
def CheckStatus():

    sigfile = ".cont"
    stopfile = ".stop"

    numflasks = 8
    status = "Continue"
    while not os.path.exists(sigfile):

        if os.path.exists(stopfile):
            status = "Stop"
            break

        time.sleep(1)

    if os.path.exists(".numflasks"):
            f = open(".numflasks")
            line = f.readline().strip("\n")
            f.close()
            numflasks = int(line)

    return status, numflasks

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

    p = subprocess.Popen(args, stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True)

    if file:
        msg = open(file, 'r').read()

    if nowait:
        p.stdin.write(msg)
        response = ""
    else:
        response = p.communicate(msg)[0]

    return response.strip("\n")







###################################################
def cvt_data(inst, filename, qc_filename=None, manifold=None, port=None, event_num=None):

        if inst.lower() == "picarro":
            result = cvt_picarro(filename, qc_filename)
        elif inst.lower() == "aerodyne":
            result = cvt_aerodyne(filename, qc_filename)
        elif inst.lower() == "lgr":
            result = cvt_lgr(filename, qc_filename)
        elif inst.lower() == "qc":
            #files specified below in cvt_qc
            result = cvt_qc("None", manifold, port, event_num)
        else:
            result = ""

        return result

###################################################
# routine to save the qc data string
def cvt_qc (filename, manifold, port, event_num=None):
#       QC data:

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
        f = open(get_resource("environment_qc_datafile", "hp34970"), "r")
        line = f.readline()

        (j, room_temp, chiller_temp, j, j) = line.split()
        f.close()
    except:
        print("in cvt_qc did NOT open %s" % filename, file=sys.stderr)
        room_temp = -99.9
        chiller_temp = -99.9

    
    ## get system evac data
    #try:
    #    f = open(get_resource("sys_evac_qc_datafile"),"r")
    #    lines = f.readlines()
    #    (initial_evac_time, initial_evac_press) = lines[0].split()
    #    (evac_time, evac_press) = lines[1].split()
    #    f.close()
    #except:
    #    evac_time = -99.9
    #    evac_press = -99.9

    ## get flask pressure (initial and final)
    #try:
    #    f = open(get_resource("flask_press_datafile"),"r")
    #    lines = f.readlines()
    #    (j, init_press,j, j, j) = lines[0].split()
    #    (j, final_press, j, j) = lines[1].split()
    #    f.close()
    #except:
    #    init_press = -99.9
    #    final_press = -99.9

    ## get pfp and flask port evac qc data (time to 1Torr, time to 100 mTorr, final press)
    #port_evac_datafile = "port_evac_%s.dat" % event_num
    #if event_num and os.path.exists(port_evac_datafile):
    #    f = open(port_evac_datafile,"r")
    #    line = f.readline()
    #    (port_evac_time1, port_evac_time2, port_evac_final_press, port_evac_time) = line.split()
    #    f.close()
    #    os.remove(port_evac_datafile)
    #else:
    #    port_evac_time1 = -99
    #    port_evac_time2 = -99
    #    port_evac_final_press = -99.999
    #    port_evac_time = -99
    
    # create output string
    result  = "%4d %02d %02d %02d %02d %02d " % (int(starttime.year), int(starttime.month), 
            int(starttime.day), int(starttime.hour), int(starttime.minute), int(starttime.second))
    result += "%2s %3s " % (manifold, port)
    result += "%5d " % (duration.seconds)
    #result += "%9.2f " % (float(init_press))
    #result += "%9.2f " % (float(final_press))
    #result += "%5.1f %9.2f " % (float(initial_evac_time), float(initial_evac_press))
    #result += "%5.1f %9.2f " % (float(evac_time), float(evac_press))
    result += "%9.2f " % (float(room_temp))
    #result += "%9.2f " % (float(room_press))
    #result += "%9.2f " % (float(idle_press))
    result += "%9.2f " % (float(chiller_temp))
    #result += "%4d %4d %9.3f %4d" % (int(port_evac_time1), int(port_evac_time2), float(port_evac_final_press), int(port_evac_time))

    return result

###################################################
###################################################
# routine to split the data string from the Aerodyne CO2 isotope insturment and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the Aerodyne CO2 isotope anaylzer on the CO2 calibration system
def cvt_aerodyne (filename, qc_filename):

    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get flow rate, pressure from file qc.dat
    try:
        f = open(qc_filename, "r")
        for line in f:
            # time, pressure, flow, room_temp, chiller_temp, j, j
            (j, press, flow, roomT, chillerT, j, j) = line.split()
        f.close()
    except:
        logging.info("no qc file")
        flow = -99.9
        press = -99.9
        roomT = -99.9
        chillerT = -99.9
        pass

    try:
        f = open(filename, "r")
    except:
        logging.error("cvt_aerodyne could not open file %s", filename)
        sys.exit()

    line = f.readline()
    f.close()

    #[ccg@localhost ~]$ more aerodyne.dat 
    # 2016  1  5 16 58 28 
    # 3534865217.796000 3.316625 11    time = junk
    # 730156.272727 14823.195817 11    626
    # 792457.000000 16049.106548 11    627
    # 755760.636364 15218.415287 11    628
    # 736783.000000 14744.636733 11    636
    # 791685.818182 1447.631087 11     ambient
    # 294.503727 0.001618 11    temperature
    # 20.001000 0.005196 11     cell press

    (ayr, amo, ady, ahr, amn, asc,
     j, j, j,
    co2_626_ppb, co2_626_ppb_sd, co2_626_ppb_n,
    co2_627_ppb, co2_627_ppb_sd, co2_627_ppb_n,
    co2_628_ppb, co2_628_ppb_sd, co2_628_ppb_n,
    co2_636_ppb, co2_636_ppb_sd, co2_636_ppb_n,
    amb_co2, amb_co2_sd, amb_co2_n,
    cell_temp, cell_temp_sd, cell_temp_n,
    cell_press, cell_press_sd, cell_press_n) = re.split('[\s]+', line.strip())

    # get time diff between actual and start
    actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
    deltatime = actualtime - starttime

    # Adjust Aerodyne mole fractions from ppb to ppm, and correct for the Hitran fractional abundance 
    # Hitran ratios used to convert adjusted ppm back to isotopologue specific mole fractions.
    hitran_626 = 0.9842
    hitran_636 = 1.106e-2
    hitran_628 = 3.947e-3
    hitran_627 = 7.339e-4

    # Use cycle start time rather than actual measurement time for analysis date/time, record time delta (actual - starttime) in QC file
    result  = "%4d %02d %02d %02d %02d %02d " % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second)
    result += "%15.8f %15.8f %d" % (float(co2_626_ppb)*hitran_626/1000.0, float(co2_626_ppb_sd)*hitran_626/1000.0, int(co2_626_ppb_n))
    result += "%15.8f %15.8f %d" % (float(co2_636_ppb)*hitran_636/1000.0, float(co2_636_ppb_sd)*hitran_636/1000.0, int(co2_636_ppb_n))
    result += "%15.8f %15.8f %d" % (float(co2_628_ppb)*hitran_628/1000.0, float(co2_628_ppb_sd)*hitran_628/1000.0, int(co2_628_ppb_n))
    result += "%15.8f %15.8f %d" % (float(co2_627_ppb)*hitran_627/1000.0, float(co2_627_ppb_sd)*hitran_627/1000.0, int(co2_627_ppb_n))
    result += "%12.4f %12.4f %d" % (float(cell_temp), float(cell_temp_sd), int(cell_temp_n))
    result += "%12.4f %12.4f %d" % (float(cell_press), float(cell_press_sd), int(cell_press_n))
    result += " %9.1f %9.1f %9.1f %9.1f" % (float(flow), float(press), float(roomT), float(chillerT))
    result += " %d" % (deltatime.seconds)


    return result



###################################################
# routine to split the data string from the lgr and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the LGR CO2 isotope anaylzer on the CO2 calibration system
def cvt_lgr (filename, qc_filename):


    #print("qc_filename: %s " % qc_filename, file=sys.stderr)
    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #print "%s %s" % (filename, sp)
    #get flow rate, pressure from file qc.dat
    try:
        f = open(qc_filename, "r")
    except:
        print("no qc file", file=sys.stderr)
        logging.info("no qc file")
        flow = -99.9
        press = -99.9
        roomT = -99.9
        chillerT = -99.9


    for line in f:
        # time, pressure, flow, room_temp, chiller_temp, j, j
        (j, press, flow, roomT, chillerT, j, j) = line.split()
    f.close()

    try:
        f = open(filename, "r")
    except:
        logging.error("cvt_lgr could not open file %s", filename)
        sys.exit()

    line = f.readline()
    f.close()
    #print line
    #print line
    (ayr, amo, ady, ahr, amn, asc,
     j,j,j, #lgr mo
     j,j,j, #lgr dy
     j,j,j, #lgr yr
     j,j,j, #lgr hr
     j,j,j, #lgr mn
     j,j,j, #lgr sc
     co2, co2_sd, co2_n,  #lgr co2
     j,j,j, #lgr co2_sd
     c13_co2, c13_co2_sd, c13_co2_n, #lgr D13C_VPDB_CO2
     j,j,j, # lgr D13C_VPDB_sd
     o18_co2, o18_co2_sd, o18_co2_n, #lgr D18O_VPDB_CO2
     j,j,j, #lgr D18O_VPDB_sd
     o17_co2, o17_co2_sd, o17_co2_n, #lgr D17O_VPDB_CO2
     j,j,j, #lgr D17O_VPDB_CO2_sd
     co2_626_ppm, co2_626_ppm_sd, co2_626_ppm_n, #lgr [CO2_626]_ppm
     j,j,j, #lgr [CO2_626]_ppm_sd
     co2_636_ppm, co2_636_ppm_sd, co2_636_ppm_n, #lgr [CO2_636]_ppm
     j,j,j, #lgr [CO2_636]_ppm_sd
     co2_628_ppm, co2_628_ppm_sd, co2_628_ppm_n, #lgr [CO2_628]_ppm
     j,j,j, #lgr [CO2_628]_ppm_sd
     j,j,j, #lgr [CO2_627]_ppm
     j,j,j, #lgr [CO2_627]_ppm_sd
     j,j,j, #lgr [H2O]_ppm
     j,j,j, #lgr [H2O]_ppm_sd
     j,j,j, #lgr CO2_626B_ppm
     j,j,j, #lgr CO2_626B_ppm
     j,j,j, #lgr R_626_ppm
     j,j,j, #lgr R_626_ppm_sd
     j,j,j, #lgr R_636_ppm
     j,j,j, #lgr R_636_ppm_sd
     j,j,j, #lgr R_628_ppm
     j,j,j, #lgr R_628_ppm_sd
     j,j,j, #lgr R_627_ppm
     j,j,j, #lgr R_627_ppm_sd
     cell_press, cell_press_sd, cell_press_n, #lgr GasP_torr
     j,j,j, #lgr GasP_torr_sd
     cell_temp, cell_temp_sd, cell_temp_n, #lgr GasT_C
     j,j,j, #lgr GasT_C_sd
     amb_temp, amb_temp_sd, amb_temp_n, #lgr AmbT_C
     j,j,j, #lgr AmbT_C_sd
     j,j,j, #lgr LTCO_V
     j,j,j, #lgr LTCO_V_sd
     j,j,j, #lgr AIN6
     j,j,j, #lgr AIN6_sd
     j,j,j, #lgr DetOff
     j,j,j, #lgr DetOff_sd
     j,j,j, #lgr Fit_Flag
     j,j,j, #lgr MIU_VALVE
     ) = re.split('[\s]+', line.strip())

    # get time diff between actual and start
    actualtime = datetime.datetime(int(ayr), int(amo), int(ady), int(ahr), int(amn), int(asc))
    deltatime = actualtime - starttime



    result  = "%4d %02d %02d %02d %02d %02d " % (starttime.year, starttime.month, starttime.day, starttime.hour, starttime.minute, starttime.second)
    result += " %12.4f %12.4f %d" % (float(co2), float(co2_sd), int(co2_n))
    result += " %12.4f %12.4f %d" % (float(c13_co2), float(c13_co2_sd), int(c13_co2_n))
    result += " %12.4f %12.4f %d" % (float(o18_co2), float(o18_co2_sd), int(o18_co2_n))
    result += " %12.4f %12.4f %d" % (float(o17_co2), float(o17_co2_sd), int(o17_co2_n))
    result += " %9.4f %9.4f %d" % (float(cell_press), float(cell_press_sd), int(cell_press_n))
    result += " %8.4f %8.4f %d" % (float(cell_temp), float(cell_temp_sd), int(cell_temp_n))
    #result += " %8.4f %8.4f %d" % (float(ringdown), float(ringdown_sd), int(ringdown_n))
    result += " %8.4f %8.4f %d" % (float(amb_temp), float(amb_temp_sd), int(amb_temp_n))
    result += " %9.1f %9.1f %9.1f %9.1f" % (float(flow), float(press), float(roomT), float(chillerT))
    result += " %15.8f %15.8f %d" % (float(co2_626_ppm), float(co2_626_ppm_sd), int(co2_626_ppm_n))
    result += " %15.8f %15.8f %d" % (float(co2_636_ppm), float(co2_636_ppm_sd), int(co2_636_ppm_n))
    result += " %15.8f %15.8f %d" % (float(co2_628_ppm), float(co2_628_ppm_sd), int(co2_628_ppm_n))
    result += " %d" % (deltatime.seconds)

    #print >> sys.stdout, result
    return result










###################################################
# routine to split the data string from the Picarro and save the relevent
# fields.  Use when Will be different for each instrument
# Set up here for use with the Picarro G2301 anaylzer on the co2cal-2 cal system
def cvt_picarro (filename, qc_filename):

    #get cycle start time
    starttime = get_start_time(cycle=True) 
    if not starttime:
        starttime = datetime.datetime(1900, 1, 1, 0, 0, 0)

    #get press, flow rate, rT, cT from temp qc file
    # for this system where measuring two inst's at the same time, gc_raw.dat is the raw
    # qc scan data.  qc.dat is created before calling cvt_data so correct press and flow
    # is listed in the qc.dat file.
    try:
        f = open(qc_filename, "r")
        lines = f.readlines()
        (j, press, flow, roomT, chillerT, j, j) = lines[0].split()
        #(j, flask_press, j, j) = lines[1].split()
        f.close()
    except:
        logging.info("no qc file")
        press = -99.9
        flow = -99.9
        roomT = -99.9
        chillerT = -99.9

    try:
            #print("in cvt_picarro, filename=%s" % filename, file=sys.stderr)
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
####  NOT USED ON CAL SYSYTEM 500.917030 2.154420 10        co2_dry
#2.106636 0.000761 11          ch4
####  NOT USED ON CAL SYSYTEM 2.122955 0.000685 11          ch4_dry
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
     #co2_dry, co2_dry_sd, co2_dry_n,
     ch4, ch4_sd, ch4_n,
     #ch4_dry, ch4_dry_sd, ch4_dry_n,
     h2o, h2o_sd, h2o_n,
     j, j, j,
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
    result += " %9.1f %9.1f %9.1f %9.1f" % (float(flow),float(press), float(roomT), float(chillerT))
    result += " %d" % (deltatime.seconds)

    return result


#######################################################################
#def rotate_logs(logfile, count):
#
#        for i in range(count-1, 0, -1):
#                src="%s.%03d" % (logfile, i)
#                dest = "%s.%03d" % (logfile, i+1)
#                if os.path.exists(src):
#                        if os.path.exists(dest):
#                                os.remove(dest)
#                        os.rename(src,dest)
#        if os.path.exists(logfile):
#                os.rename(logfile, "%s.001" % logfile)




############################################################
# write most recent nl filename to file
def write_last_nl_timestamp(timestamp):

        fn = ".last_nl_rawfile"
        try:
                f = open(fn, "w")
        except:
                logging.error("can't open file %s for writing" % fn)
                return

        #print >> f, timestamp
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

#############################################################
#def getRefTanks(rangeName=None):
#        """ 
#        Get list of tanks to use in the response curve.
#
#        """
#
#        stdlist =[]
#
#        # read list
#        try:
#                f = open("%s/sys.ref_tanks" % config.HOMEDIR)
#        except:
#                print >> sys.stderr, "Cannot open file 'sys.ref_tanks'."
#                sys.exit()
#        a = f.readlines()
#        f.close()
#
#   # Normal_range    S1          CA07413  ManifoldC    1       9999                  rrr
#        for line in a:
#                (range_name, sid, serial_num, smanifold, sport, spress, sreg) = line.split()
#       if rangeName is not None:
#           if range_name.lower() == rangeName.lower():
#               manifold = smanifold.strip("Manifold")
#               port = int(sport)
#               t = (sid, serial_num, manifold, port)
#               stdlist.append(t)
#
#       else:
#           manifold = smanifold.strip("Manifold")
#           port = int(sport)
#           t = (sid, serial_num, manifold, port)
#           stdlist.append(t)
#
#        return stdlist


##############################################################
def get_qc_raw_data():

    #get flow rate, pressure from file qc_raw.dat
    try:
        f = open(get_resource("monitor_device_result_file", "hp34970"), "r")
        for line in f:
            (j1, smp_press, smp_flow, ref_press, ref_flow, rT, cT, j2, j3) = line.split()
        f.close()
    except:
        logging.info("no qc file")
        print("no qc file", file=sys.stderr)
        j1 = 0
        j2 = 0
        j3 = 0
        smp_flow = -999.99
        smp_press = -999.99
        ref_flow = -999.99
        ref_press = -999.99
        rT = -999.99
        cT = -999.99

    #test flow rates and pressures against limits
    smp_flag = 0
    ref_flag = 0
    if float(smp_flow) != -999.99:
        if float(smp_press) < float(config.press_limit) or float(smp_flow) < float(config.flow_limit):
            smp_flag = 1
    if float(ref_flow) != -999.99:
        if float(ref_press) < float(config.press_limit) or float(ref_flow) < float(config.flow_limit):
            ref_flag = 1

    msg = "smp_press: %4d  smp_flow: %4d  smp_flag: %s      ref_press: %4d  ref_flow: %4d  ref_flag: %s" % (
        float(smp_press), float(smp_flow), smp_flag, float(ref_press), float(ref_flow), ref_flag)
    logging.info("Check Flow/Press:   %s" % (msg))
    #print(msg, file=sys.stderr)

    return (j1, smp_press, smp_flow, ref_press, ref_flow, smp_flag, ref_flag, rT, cT)



