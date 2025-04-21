
"""
Common routines used by more than 1 mode.

V23 (2024-12-11)  - Changes comms with AR to use DEFT instead of RS232
 
"""

import os
import sys
import shutil
import time
import  multiprocessing
import logging
import subprocess
import datetime
from collections import deque
from statistics import median, mean

import config
import utils

# open connection to database file that has the sample information
from magiccdb import *
db_filename = 'magicc.db'
# db_filename = config.databasefile # could put this in config.py instead
magiccdb = magiccDB(db_filename)


############################################################
# Write a message string to the file 'sys.status'
############################################################
def ShowStatus(msg):

    logging.info(msg)

    f = open("sys.status", "w")
    f.write(msg)
    f.write("\n")
    f.close()
    print(msg, file=sys.stderr)

############################################################
# Write a message string to the file pfp_error_log
############################################################
def Log_PFPerror(msg):

    ShowStatus("PFP:  %s" % msg)

    now = datetime.datetime.now()
    f = open(config.PFPLOGFILE, "a")
    f.write("%s   %s\n" % (now.strftime("%Y-%m-%d %H:%M:%S"), msg))
    f.close()
    print(msg, file=sys.stderr)

##############################################################
def run_auto_flag(inst, sysgases, caltype):
    """
    Run the flask qc program on each rawfile

    """

        # if type = pfp change to aircraft so directory path with be correct
    if caltype.lower() == "pfp" or caltype.lower() == "aircraft" or caltype.lower() == "flask":
        processtype = "flask"
    else:
        processtype = caltype.lower()

    # get instrument code
    inst_id, sernum = utils.get_instrument_id(inst)
    
    # make each gas species raw file
    for sp in sysgases[inst]:
        rawfile = utils.get_rawfile_name(sp, inst_id)
        ShowStatus("Running auto flagging routine for %s %s" % (inst, sp))
        year = int(rawfile[0:4])
        process_filename = "/ccg/%s/%s/%s/raw/%d/%s" % (sp.lower(), processtype.lower(), config.SYSTEM_NAME.lower(), year, rawfile)
        utils.qc_data(processtype, process_filename)    


##############################################################
def update_files(inst, sysgases, caltype, stdset="", serialnum="", pressure="", regulator="", manifold="", 
        portnum="", primary_key="" ):
    """ 
    Make rawfiles, save data to server, process results
    """
    print("in update_files:  inst=%s caltype=%s" % (inst, caltype), file = sys.stderr)

    # if type = pfp change to aircraft so directory path with be correct
    #if caltype.lower() == "pfp": caltype = "aircraft"
    if caltype.lower() == "pfp" or caltype.lower() == "aircraft" or caltype.lower() == "flask":
        processtype = "flask"
    else:
        processtype = caltype.lower()

    # get instrument code
    inst_id, sernum = utils.get_instrument_id(inst)

    if inst.upper() != "QC": 

        # make each gas species raw file
        for sp in sysgases[inst]:
            rawfile = utils.get_rawfile_name(sp, inst_id)
            ShowStatus("making raw file for %s %s.  rawfile: %s" % (inst.upper(), sp.upper(), rawfile))
            utils.make_raw(config.SYSTEM_NAME, inst, caltype, qc=False, gas=sp, rawfile=rawfile, stdset=stdset,
                serialnum=serialnum, pressure=pressure, regulator=regulator, 
                valvename="%s" % manifold, portnum=portnum)
            ShowStatus("saving raw file for %s %s.  Rawfile: %s" % (inst.upper(), sp.upper(), rawfile))
            utils.save_files(processtype, inst, sp, rawfile)
    
        # process each rawfile
        for sp in sysgases[inst]:
            rawfile = utils.get_rawfile_name(sp, inst_id)
            #ShowStatus("processing raw file for %s %s.  Rawfile: %s" % (inst.upper(), sp.upper(), rawfile))
            year = int(rawfile[0:4])
            process_filename = "/ccg/%s/%s/%s/raw/%d/%s" % (sp.lower(), processtype.lower(), config.SYSTEM_NAME.lower(), year, rawfile)
            ShowStatus("processing raw file for %s %s.  Rawfile: %s" % (inst.upper(), sp.upper(), process_filename))
            utils.process_data(processtype, process_filename, stdset)

        # qc raw file  
        for sp in sysgases[inst]:
            ShowStatus("Making QC file for %s %s. " % (inst.upper(), sp.upper()))
            qcrawfile = utils.get_rawfile_name(sp, inst_id) + ".qc"
            utils.make_raw(config.SYSTEM_NAME, inst, caltype, qc=True, gas=sp, rawfile=qcrawfile, stdset=stdset,
                serialnum=serialnum, pressure=pressure, regulator=regulator, 
                valvename="%s" % manifold, portnum=portnum)
            utils.save_files(processtype, inst, sp, qcrawfile, qc=True)

        # data file, for GC's these files are the raw chromatograms. For optical analyzers these
        # files are the result strings from the analyzer.
        # the Aerodyne and Picarro have one data file but put into both locations so do not have
        # to have linked directories
        if inst.lower() == "gc" or inst.lower() == "gc1" or inst.lower() == "gc2":
            for sp in sysgases[inst]:
                ziparchive = utils.get_archive_name(sp, inst_id)
                utils.save_files(processtype, inst, sp, ziparchive, data=True)
        else:
            for sp in sysgases[inst]:     ####HERE
                current_fn = "data.%s.high_freq" % inst.lower()
                datafile = utils.get_rawfile_name(sp, inst_id) + ".dat"
                ShowStatus("Making inst %s data file %s" % (inst.upper(), datafile))
                os.system("cp "+current_fn+" "+datafile)
                utils.save_files(processtype, inst, sp, datafile, data=True)

    else:
        #process system wide QC files
        ShowStatus("Making system wide QC data file ")
        system_qc_rawfile = utils.get_rawfile_name("qc", config.SYSTEM_NAME)
        utils.make_raw(config.SYSTEM_NAME, inst, caltype, qc=True, gas="QC", rawfile=system_qc_rawfile, stdset=stdset,
                serialnum=serialnum, pressure=pressure, regulator=regulator, 
                valvename="%s" % manifold, portnum=portnum)
        # save system qc file
        ShowStatus("Saving system wide QC data file ")
        utils.save_files(processtype, inst, config.SYSTEM_NAME, system_qc_rawfile)

        # put flask pressures (initial and final) into DB table
        if processtype.lower() == "flask": 
            ShowStatus("Uploading flask pressures into DB table ")
            year = int(system_qc_rawfile[0:4])
            process_filename = "/ccg/magicc-3_qc/%s/%s/%s" % (processtype.lower(), year, system_qc_rawfile)
            cmd = "/home/magicc/src/upload_flask_pressure.py -u -f %s" % (process_filename)
            if os.path.exists(process_filename): 
                subprocess.Popen(cmd, shell=True, stdin=None, stdout=None, stderr=None)

        # put tank cal manifold and port number into DB table calibrations_qcdata
        if processtype.lower() == "cals":
            ShowStatus("Uploading cal info (manifold,port) to DB table ")
            year = int(system_qc_rawfile[0:4])
            process_filename = "/ccg/magicc-3_qc/%s/%s/%s" % (processtype.lower(), year, system_qc_rawfile)
            cmd = "python /home/magicc/src/update_calqc.py -u %s" % (process_filename)
            if os.path.exists(process_filename): 
                subprocess.Popen(cmd, shell=True, stdin=None, stdout=None, stderr=None)
            

    # Run auto-flagging routine here if do one species at a time
    if processtype.lower() == "flask":
        pass    
    else:
        pass


##############################################################
def prep_system(action, sampledata, referencedata, mode):
    """ 
    prepare the system for the next sample while waiting
    for GC runs to finish.

    sampledata = dictionary for current sample
    referencedata = dictionary for reference    

    """

    ####################################
    # Prep system for the next sample.
    # if not currently running REF the next is REF. 
    if sampledata["sample_id"].upper() != referencedata["sample_id"].upper():
        next_sampledata = referencedata
    else: #if on REF
        if mode == 2:
            # if currently on R0 in mode 2 then look to see if there is another sample of the same type
            next_sampledata, ready = magiccdb.get_next(sample_type=sampledata["sample_type"], asDict=True)
            if next_sampledata == None:  # either no more samples ready or next one switches type go back to R0
                next_sampledata = referencedata
            else:  #if next ready sample is the same type
                pass

        elif mode == 5:   # test mode gets complicated,  hard code things here, change as needed
            #if sampledata["port_num"] == 1:
            #   next_portnum = 3
            #else:
            #   next_portnum = 1
            next_portnum = 3
            next_sampledata = {
                "manifold"    : "C",
                "port_num"     : int(next_portnum),
                "sample_id"     : "NA",
                "sample_type"  : "cal",
                "analysis_id" : None
                }
            
        else:
            # modes with continuous REF shots
            next_sampledata = referencedata


    #evac system in preparation for next sample
    evac_err, evac_time, evac_press = evac_system(action, next_sampledata, float(config.first_system_evac_limit), "prep for next cycle") 

    # record system evacuation time and final evac pressure
    try:
       f = open(utils.get_resource("initial_sys_evac_qc_datafile"), "w")
       f.write("%s   %s\n" % (evac_time, evac_press))
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, exiting ..." % utils.get_resource("initial_sys_evac_qc_datafile"))
       sys.exit()

    return evac_err


##############################################################
def evac_system(action, sampledata, limit, msg=""):
    """
    evacutate the system to limit torr

    check position of manifold valco valve, if not portnum -1 or portnum +1 then turn to portnum -1
    We don't want to turn the manifold past other ports after the evacuation step
    
    sampledata = dictionary of current sample info

    limit = evac pressure limit
    msg = message to display with showstatus

    returns  evac_err(0 pass, 1 fail), evac_time.total_seconds(), press

    """

    ShowStatus("In evac_system: Evacuating for sample on manifold %s  port %s" %(sampledata["manifold"], sampledata["port_num"]))

    # check position of manifold valve, turn to portnum - 1 if not correct
    # For pfp's port can also be the actual port since it will be on the port during pfp manifold evac
    # other types of samples need to be on an off port
    manifoldname = "Manifold%s" % sampledata["manifold"]
    #config file line:  ValcoValves multiposition 4 16
    (vdevice, vtype, vid, max_positions)  = utils.get_resource(manifoldname).split()
    action.run("valco_current_position.act", "Manifold%s" % sampledata["manifold"].upper())
    #print >> sys.stderr, "output: %s" % action.output
    cp = int(action.output)
    ShowStatus("In evac_system: current position is %s" % (cp))
    

    noff = int(sampledata["port_num"]) + 1
    if int(sampledata["port_num"]) == 1:
        poff = int(max_positions)
    else:
        poff = int(sampledata["port_num"]) - 1

    ShowStatus("port_num = %s, max_port = %s, cp = %s,  noff = %s,  poff = %s" % (sampledata["port_num"],max_positions, cp, noff, poff))
    # for pfp's, need to make sure we don't turn the manifold to an off port
    # since background process may be evacuating the pfp manifold. 
    # Remember the referencedata will have same sample_type as the internal mode samples
    if sampledata["sample_type"].upper() == "PFP" and sampledata["sample_id"].upper() != config.ref_name.upper():
        if cp != poff and cp != noff and cp != int(sampledata["port_num"]):
            ShowStatus("In evac_system: manifold not on prev or next off port OR for pfp not on port. Turning manifold valve")
            action.run("turn_multiposition.act", "Manifold%s" % sampledata["manifold"], poff)   
    else:
        if cp != poff and cp != noff:
            ShowStatus("In evac_system: manifold not on prev or next off port. Turning manifold valve")
            action.run("turn_multiposition.act", "Manifold%s" % sampledata["manifold"], poff)   
            time.sleep(5)

    # Start evac of system   
    evac_time_start = datetime.datetime.now()

    # Start evac of system and Test for failure of solenoid valves to fire
    ShowStatus("start system evac (%s):  Manifold %s  port %s " %(msg, sampledata["manifold"], sampledata["port_num"]))
    try_count = 0

    # grab initial pressure
    action.run("measure_system_pressure.act" )
    (j, press1, j, j) = action.output.split()
    ShowStatus("test system evac solenoid actuation:  Initial pressure %s" % (press1))

    # start evac
    action.run("start_system_evac.act", sampledata["manifold"])

    while True:
        time.sleep(5.0)
        # get second pressure to make sure dropping
        action.run("measure_system_pressure.act" )
        (j, press2, j, j) = action.output.split()
        ShowStatus("test system evac solenoid actuation:  Second pressure %s" % (press2))

        if float(press1) > float(press2)+1.0: 
            break
        else:
            # if pressure not dropping, retry solenoids
            ShowStatus("*** SYSTEM PRESSURE NOT DROPPING, RETRY SOLENOID VALVES")
            action.run("start_system_evac.act", sampledata["manifold"])

            if try_count == 3:
                #if the GCbypass valve doesn't turn to "include" the evac will not work so make sure 
                #if is in "include" if we get an error
                ShowStatus("system not evacuating, switch GCbypass and retry")
                action.run("switch_two_position_valve.act", "GCbypass", "@Bypass")
                time.sleep(2.0)
                action.run("switch_two_position_valve.act", "GCbypass", "@Include")
                time.sleep(2.0)

            #if try_count == 3:
            #    ShowStatus("************ System still not evacuating, try finding stops of GCbypass valve")
            #    action.run("valco_two_position_find_stops.act", "GCbypass") # 


            if try_count > 4: 
                ShowStatus("!!!!!!!!!!!!! SYSTEM EVACUATION FAILING ")
                return 1, -999.9, -999.9
                #sys.exit("evacuation failing repeatedly")

            try_count = try_count + 1
            
    ShowStatus("System evac (%s):  Manifold %s  port %s " %(msg, sampledata["manifold"], sampledata["port_num"]))

    # wait until system pressure drops to LT limit OR time out if can not get to correct pressure
    while True:
        action.run("measure_system_pressure.act" )
        (j, press, j, j) = action.output.split()
        
        if float(press) < float(limit): break

        evac_time_delta = datetime.datetime.now() - evac_time_start
        if evac_time_delta.total_seconds() > config.system_evac_time_limit:  
            ShowStatus("System evac:  Manifold %s  port %s TIMED OUT - Final pressure reading: %10.2f" %( sampledata["manifold"], sampledata["port_num"], float(press)))
            break

        time.sleep(1.0)

    #determine time for evacuation step
    evac_time = datetime.datetime.now() - evac_time_start

    # Stop evac of system 
    ShowStatus("stop system evac:  Manifold %s  port %s " % (sampledata["manifold"], sampledata["port_num"]))
    action.run("stop_system_evac.act") 

    #test final pressure. If within +10 Torr of limit assume ok to prevent crashing on wet samples
    if float(press) <= float(limit)+10.0:
        evc_error = 0
        ShowStatus("System evac: final pressure within %s + 10 Torr" % limit)
    else:
        evc_error = 1
        ShowStatus("System evac: final pressure ABOVE %s + 10 Torr" % limit)

    ShowStatus("System evacuation (%s) time: %s seconds    Final evac pressure: %s" % (msg, evac_time.total_seconds(), press))

    return evc_error, evac_time.total_seconds(), press






##############################################################
def fill_aerodyne(action, gastype, gasname, aerodyne_qc_datafile="aerodyne_qc.dat",  measure=False):
    """
        fill_aerodyne(action, gastype, gasname)
    evacuate and fill the Aerodyne sample cell when running
    in stop flow mode 
        Typically takes 5 - 7 seconds to fill
    if background = True then do automatic background under evac before filling - NOT USED so removed

    V23 - if measure set true, initiate the writing of data by the AR. Assumes AR is configured to use the transient file for DEFT

    """

    # evac of Aerodyne cell.  Check acknowledgement of runscript command, repeat if not acknowledged.
    runscript_accepted = False

    try:    
        # remove old acknowledgment files
        os.remove(utils.get_resource("aerodyne_fill_script_ack"))
    except:
        pass

    # Evacuate AR cell
    ShowStatus("Aerodyne Evac:  %s   %s" % (gastype, gasname))
    action.run("aerodyne_evac.act")

    #------- record evac pressure here if wanted 
    action.run("aerodyne_qc.act", aerodyne_qc_datafile) # 1 secs

    # fill of Aerodyne cell.  Check acknowledgement of runscript command, repeat if not acknowledged.
    runscript_accepted = False
    try_cnt = 0  # limit number of tries to 5 times, exit if can't get comms to work

    while runscript_accepted == False and try_cnt < 5:
        try_cnt += 1
        
        if measure:
            ShowStatus("Aerodyne Fill and start write data to transient data file:  %s   %s" % (gastype, gasname))
            action.run("aerodyne_fill_and_write_data.act") #3 secs 
        else:
            ShowStatus("Aerodyne Fill:  %s   %s" % (gastype, gasname))
            action.run("aerodyne_fill.act") #3 secs 

        if os.path.isfile(utils.get_resource("aerodyne_fill_script_ack")): runscript_accepted = True
    
    # wait for 15 secs to fill cell to 50 Torr, takes about 10 seconds with 0.006" critical flow orifice. 
    # wait for 20 secs to fill cell to 50 Torr, takes about 16 seconds with 0.004" critical flow orifice. 
    #For background wait aerodyne_abg_duration + 10s for fill
    if measure: 
        fill_time = 15 
    else: 
        fill_time = 20

    time.sleep(fill_time)

    ShowStatus("Finished filling Aerodyne cell.  Measure=%s" % (measure))

    return runscript_accepted   # True indicates no errors, False indicates error

##############################################################


##############################################################
def initial_pressure_transducer_test(action, referencedata, transducer_offset=0.0):
    """
        Test the inital pressure transducer offset on startup

        Starts with high guess of transducer offset listed as single value in config. 
        After this we keep a running average (or median) so reset config.transducer_offset 
        with a collection.deque to make this easier
    """

    ShowStatus("start initial pressure transducer test")

    #pull slight vaccum on system
    evac_err, evac_time, evac_press = evac_system(action, referencedata, config.transducer_test_evac_limit, "initial transducer test") 

    ShowStatus("in initial pressure transducer test: evac_err = %s" % evac_err) 
    #test for successful system evacuation
    if evac_err == 1: 
        ShowStatus("Error on system evacuation")
        sys.exit()

    # prep system for test
    action.run("setup_inital_pressure_transducer_test.act", referencedata["manifold"], referencedata["port_num"], int(referencedata["port_num"])+1)

    # test pressure in GC sample loops to see if should relax to room pressure
    action.run("test_sample_loop_pressure.act" )
    (j, sample_loop_press, room_press, j, j) = action.output.split()
    ShowStatus("INITIAL TEST (before venting)- Sample loop pressure: %s      Room pressure: %s   Transducer offset: %s" % (
            sample_loop_press, room_press, transducer_offset))
    
    if float(sample_loop_press) - float(transducer_offset) <= float(room_press):
        ShowStatus("Initial test of pressure transducer offset failed, check R0 tank or ice in trap, exiting ...")
        sys.exit()

    #open vent valve to relax sample loop to room pressure
    action.run("closerelay.act", "@gc_sample_loop_relax")  
    time.sleep(10)

    # Measure sample loop and room pressures
    action.run("gc_sample_loop_stabilize.act", utils.get_resource("gc_qc_datafile"))
    (j, sample_loop_press, room_press, j, j) = action.output.split()

    transducer_offset = float(sample_loop_press) - float(room_press) #difference between sample loop transducer and room air transducer
    ShowStatus("INITIAL TEST ------ Sample loop pressure: %s      Room pressure: %s   Transducer offset: %s" % (
            sample_loop_press, room_press, transducer_offset))

    # close the GC sample loop relax valve
    action.run("openrelay.act", "@gc_sample_loop_relax")  
    
    # set gcbypss back to "include" position
    action.run("switch_two_position_valve.act", "GCbypass", "@Include")

    # convert the measured offset to a collections.deque to make handling running mean easier. Test to make sure it is less than 
    # config.max_transducer_offset. If greater than this value exit and ask user to fix
    if transducer_offset > config.max_transducer_offset:
        msg = "In common.py, initial_pressure_transducer_test:  measured transducer offset is greater than max allowed transducer offset. Exiting ..."
        ShowStatus(msg)
        sys.exit(msg)
    else:
        #convert config.transducer_offset to a collections.deque
        transducer_offset = deque([transducer_offset], maxlen=10)

    return transducer_offset


##############################################################

##############################################################
def run_sample(action, syslist, sysgases, referencedata, sampledata=None, gastype="NUL", storegc=False, transducer_offset=0.0, namespace=None):
    """
    Run a gas sample for each system
    Some will be run in background, so wait until all 
    samples are done before returning.

    referencedata dictionary, needed for prepping for next sample so pass in each time 
            Same structure as sampledata, global definition in modes.py

    sampledata - dictionary for sample (or std) info.  If None then will run referencedata.
        sampledata dictionary:
                        "manifold"    : A (A, B, or C)
                        "port_num"    : 1 (1,3,5,7 ...)
                        "serial_num"  : flask id for flasks, tank serial number for cal and nl, pfp package id for pfp
                        "sample_type" : 'flask' or 'pfp' or 'cal' or 'nl'
                        "sample_num"  : 1 for flask, sample number for others
                        "sample_id"   : flaskid for flask and pfp, serial_number for cal, std id for nl (S1, S2 ...) 
                        "event_num"   : event number for flask and pfp, 0 for nl and cal
                        "analysis_id" : id number from analysis table for this sample
                        "pressure"    : pressure for cal, '' for others
                        "regulator"   : regulator name for cal, '' for others


    gastype = REF, SMP, STD, WARMUP, NUL

    storegc = if true then archive chromatograms

    transducer_offset = difference between sample loop press transducer and room air transducer when both measure room
            use to make sure don't relax sample loop unless positive pressure. Use a running meaan of the last 10 aliquots
            Make sure the new measured offset is less than config.max_transducer_offset to keep bad values from getting included. 
            Bad values occur when solenoid valve doesn't open. Default value of 0.0 needs to be converted to deque.
            

    namespace = A manager that allows transducer offset to be sent back to main code when run_sample run 
            in background for pfp's. 
            When namespace = None, run_sample is not in background so not used and simply return the value.

    Assumes sample manifold is prep'd and ready
        for flasks, evac'd after installing flasks, and flasks open
        for pfp, evac'd just prior to calling this routine, and pfp flasks opened
        for tanks, no evac
        for reference, no evac

    temp storage of qc data (*** THESE ARE HARDCODED INTO CONFIG.PY SO ARE AVAILABLE
    HERE AND IN CVT_DATA SCRIPTS IN UTILS.PY)
    --------------------------------------------------------------------------------
    environment_qc_datafile = utils.get_resource("environment_qc_datafile")
    sys_evac_qc_datafile =  utils.get_resource("sys_evac_qc_datafile")
    initial_sys_evac_qc_datafile =  utils.get_resource("initial_sys_evac_qc_datafile")
    flask_press_datafile =  utils.get_resource("flask_press_datafile")
    gc_qc_datafile =  utils.get_resource("gc_qc_datafile")     #filename follows template "inst"_qc.dat
    aerodyne_qc_datafile =  utils.get_resource("aerodyne_qc_datafile", "aerodyne")  #filename follows template "inst"_qc.dat
    picarro_qc_datafile =  utils.get_resource("picarro_qc_datafile", "picarro")   #filename follows template "inst"_qc.dat
               utils.get_resource("pfp_qc_datafile")
    """

    # if transducer_offset is not a deque type, then convert
    if not isinstance(transducer_offset, deque):
        ShowStatus("transducer offset was not a collections.deque type, converted within common.py so running average has been reset")
        transducer_offset = deque([transducer_offset], maxlen=10)

    # **** IF NO SAMPLE DATA PASSED IN, RUN REFERENCE ****
    run_ref = False
    if not sampledata:
        sampledata = referencedata
        run_ref = True

    # write sample cycle start time to sys.cycle_start for use in qc file
    status_tag = "Manifold %s, port %s,  gastype %s,  event_num %s,  sample_id %s, serial_num %s" % (
        sampledata["manifold"],sampledata["port_num"], gastype, sampledata["event_num"], 
        sampledata["sample_id"], sampledata["serial_num"])
    ShowStatus("################   BEGIN RUN_SAMPLE:  %s" % (status_tag))
    utils.set_start_time(cycle=True) 

    # configure the DAQ unit every cycle to ensure channels are set correctly
    ShowStatus("Configuring the DAQ unit")
    action.run("config_daq.act")
    
    # remove temp data files so get nothing if comms fail rather than prior data again.
    fn_list = []
    fn_list.append(utils.get_resource("picarro_datafile"))
    fn_list.append(utils.get_resource("monitor_device_save_file", "picarro"))
    fn_list.append(utils.get_resource("picarro_qc_datafile"))
    fn_list.append(utils.get_resource("aerodyne_datafile"))
    fn_list.append(utils.get_resource("monitor_device_save_file", "aerodyne"))
    fn_list.append(utils.get_resource("aerodyne_qc_datafile"))

    for fn in fn_list:
        #if os.path.exists(fn): os.remove(fn)
        utils.backup_temp_datafiles(fn)

    aerodyne_check = True # set check to true in case not measuring Aerodyne

    # Get starting mode from sys.setup, used later for decisions  
    s = utils.get_setup_value("Mode")
    if s:
        mode = int(s[0])
    else:
        mode = 1

    # if running GC's and/or Aerodyne then sample in background. Use these keys to wait for processes to finish
    proc1_on = False
    proc2_on = False
    proc3_on = False

    #define next off port on manifold select
    next_off_manifold = "@Manifold%s_port_off" % sampledata["manifold"]

    # measure system QC data
    ShowStatus("Measure system qc data at start of cycle")
    action.run("measure_qc.act", utils.get_resource("environment_qc_datafile"))

    #purge system with sample gas (also measure initial flask pressure) 
    ShowStatus("quickly fill system with sample")
    action.run("quick_condition_system.act", sampledata["manifold"], sampledata["port_num"], 
            int(sampledata["port_num"])+1, utils.get_resource("flask_press_datafile"))
    ####################################################################################################
    ##### HERE LET'S LOOK AT THE INITIAL FLASK PRESSURE. IF GET VALUE THAT IS EQAUL TO AN EVACUATED MANIFOLD THEN WE KNOW THE
    # FLASKS DIDN'T OPEN. THIS WILL CAUSE THE NEXT SYSTEM EVAC STEP TO THINK THE SOLENOID ISN'T FIRING SKIPPING ALL FLASKS
    # INSTEAD, IF WE SEE A LOW VALUE (IE FLASK VALVE DIDNT' OPEN) THEN WE WILL SKIP THIS FLASK BUT CONTINUE WITH REST OF 
    # THE PFP AND ALL OTHERS.  BETTER OPTION MAY BE TO USE TRANSDUCER IN PFP MANIFOLD TO LOOK FOR VALVES NOT OPEN
    # PUT READING AND TEST IN MODES.PY RIGHT AFTER OPENING THE FLASK.
    (j, initial_flask_press, initial_sample_loop_press, j, j) = action.output.split()
    ShowStatus("%s  ----  Initial flask pressure: %s" % (status_tag, initial_flask_press))
    if float(initial_flask_press) < 2.0:
        msg = "%s --- Initial flask pressure < 2.0, likely indicates flask valve not open, skip this flask" % (status_tag)
        ShowStatus(msg)
        if not run_ref:
            if sampledata["sample_type"].lower() == 'pfp':
                Log_PFPerror(msg)
            magiccdb.mark_error(sampledata["analysis_id"])

        if namespace:
            namespace.transducer_offset = transducer_offset
            return
        else:
            return transducer_offset
    
    ####################################################################################################

    #evacuate the system again
    # first copy initial evac qc data file to sys_evac datafile to preserve initial evac information, 
    # it gets overwritten during prep for next sample
    try:
        shutil.copy(utils.get_resource("initial_sys_evac_qc_datafile"), utils.get_resource("sys_evac_qc_datafile"))
    except:
        ShowStatus("failed to copy %s to %s" % (utils.get_resource("initial_sys_evac_qc_datafile"), utils.get_resource("sys_evac_qc_datafile")))
        f = open(utils.get_resource("sys_evac_qc_datafile"), "w")
        f.write("%s   %s\n" % (-99, -99.9))
        f.close()
    
    evac_err, evac_time, evac_press = evac_system(action, sampledata, float(config.second_system_evac_limit), "start") 

    #test for successful system evacuation
    #mark all ready samples as error so will exit cleanly  ***MAY NEED TO CARRY AN ERROR CODE BACK TO MODES.PY SO WILL NOT TRY NEXT REF
    if evac_err == 1: 
        ShowStatus("Error on system evacuation, start of run_sample")
        magiccdb.mark_error(sampledata["analysis_id"])
        # mark all "ready" samples as "error" 
        rows = magiccdb.get_analysis_info()
        for line in rows:
            if line[12].upper() == "READY":
                magiccdb.mark_error(line[0])
        if namespace:
            namespace.transducer_offset = transducer_offset
            return
        else:
            return transducer_offset
    
    try:
        f = open(utils.get_resource("sys_evac_qc_datafile"), "a")
        f.write("%s   %s\n" % (evac_time, evac_press))
        f.close()
    except:
        ShowStatus("Could not open file %s for writing, exiting ..." % utils.get_resource("sys_evac_qc_datafile"))
        sys.exit()
    
    # start condition system 
    ShowStatus("start conditioning system (no sample flow during this step):  %s" % (status_tag))
    action.run("start_sys_condition.act", sampledata["manifold"], sampledata["port_num"])   

    # If Aerodyne in use, also condition Aerodyne cell while conditioning system
    # sleep keeps conditioning time basically the same if Aerodyne not running
    if "aerodyne" in syslist:
        # aerodyne_abg            amabg1
        #j, run_bkg = utils.get_resource("aerodyne_abg").split('g')
        aerodyne_check = fill_aerodyne(action, gastype, sampledata["sample_id"])
    else:
        time.sleep(35)

    # SECOND AERODYNE FLUSH
    # If Aerodyne in use, also condition Aerodyne cell while conditioning system
    # sleep keeps conditioning time basically the same if Aerodyne not running
    # Only do this second fill if the first fill was successful
    time.sleep(3)
    if "aerodyne" in syslist and aerodyne_check == True:
        aerodyne_check = fill_aerodyne(action, gastype, sampledata["sample_id"])
    else:
        time.sleep(35)

    # stop condition system.  Wait period for aerodyne to fill is in fill_aerodyne step.
    # Total of ~68 secs including fill_aerodyne steps (25 secs each) 
    ShowStatus("conditioning system (no sample flow during this step):  %s" % (status_tag))
    action.run("stop_sys_condition.act") 

    # flush GC sample loops. Uses one of the laser spectroscopic instruments to pull sample
    # Run flush GC if using GC or not to keep flush cycle the same and get QC measurements
    ShowStatus("flush_gc.act:  %s" % (status_tag))
    action.run("flush_gc.act", sampledata["manifold"], sampledata["port_num"], utils.get_resource("gc_qc_datafile"))

    # test pressure in GC sample loops to see if should relax to room pressure prior to injecting   
    # waits 5 secs to let pressure stabalize after switching bypass valve at end of flush_gc.act
    action.run("test_sample_loop_pressure.act" )
    (j, sample_loop_press, room_press, j, j) = action.output.split()
    delta = (float(sample_loop_press) - mean(transducer_offset)) - float(room_press)
    ShowStatus("%s Sample loop pressure (Before venting): %7.2f      Room pressure: %7.2f   Transducer offset: %7.2f   delta: %7.2f" % (
            status_tag, float(sample_loop_press), float(room_press), mean(transducer_offset), delta ))
    
    if float(sample_loop_press) - mean(transducer_offset) <= float(room_press):
        ShowStatus("!!!! %s Sample loop pressure less than room pressure, Do Not Relax GC sample loops" % (status_tag)) 
        relax_gc = False
    else:
        relax_gc = True

    # if sample loop pressure is positive, open vent to relax to room pressure
    if relax_gc:
        ShowStatus("Relax GC sample loops to room pressure") 
        action.run("closerelay.act", "@gc_sample_loop_relax")  

    # relax time and final sample loop pressure measurement
    ShowStatus("GC sample loop relax or stabilize")
    action.run("gc_sample_loop_stabilize.act", utils.get_resource("gc_qc_datafile"))   
    (j, sample_loop_press, room_press, j, j) = action.output.split()

    # if sample loop is relaxed to room pressure, remember the offset between the sample loop and room pressure transducers
    if relax_gc:
        new_transducer_offset = float(sample_loop_press) - float(room_press)
        if new_transducer_offset < config.max_transducer_offset:
            transducer_offset.append(new_transducer_offset)
        else:
            ShowStatus("New measured transducer offset (%7.2f) is greater than max allowed offset (%7.2f). Not added to the running average" % 
                    (new_transducer_offset, config.max_transducer_offset))

    ShowStatus("%s Sample loop pressure (After venting): %7.2f      Room pressure: %7.2f   New Transducer offset: %7.2f   " % (
            status_tag, float(sample_loop_press), float(room_press), mean(transducer_offset)))

    # run gc1 chromatography (in background)
    if "gc1" in syslist:
        ShowStatus("Run GC1 (SF6)")
        for sp in sysgases['gc1']:
            if sp.upper() == "SF6":
                ShowStatus("Run SF6 chromatography")
                proc1 = action.runbg("sample_sf6.act", "gc.sf6.txt", sampledata["port_num"] )
                proc1_on = True
                #ShowStatus("Waiting for sf6 chromatography to spin up")
                #time.sleep(3)


    # run gc2 chromatography (in background)
    if "gc2" in syslist:
        ShowStatus("Run GC2 (H2)")
        for sp in sysgases['gc2']:
            if sp.upper() == "H2":
                ShowStatus("Run H2 chromatography")
                #proc2 = action.run("sample_h2.act", "gc.h2.txt", sampledata["port_num"]) 
                proc2 = action.runbg("sample_h2.act", "gc.h2.txt", sampledata["port_num"]) 
                proc2_on = True

    # close the GC sample loop relax valve (if used)
    if relax_gc:
        #time.sleep(5)
        ShowStatus("Close GC sample loop relax valve") 
        action.run("openrelay.act", "@gc_sample_loop_relax")  

    # Continue flushing prior to sampling with Aerodyne (even if not using Aerodyne to keep timing the same)
    if "aerodyne" in syslist or "picarro" in syslist:
        ShowStatus("Continue flushing prior to Aerodyne and Picarro sampling:  %s" % (status_tag))
        action.run("flush_pre-aerodyne.act")

    # for stop flow measurement on Aerodyne, only do if first two aerodyne fills were successful
    if "aerodyne" in syslist and aerodyne_check == True:
        aerodyne_check = fill_aerodyne(action, gastype, sampledata["sample_id"], utils.get_resource("aerodyne_qc_datafile"), measure=True)
    else:
        # if not running AR or comms failed then keep timing approximately the same
        time.sleep(35)

    # measure Aerodyne in background.  The measure action file let's the AR cell equilibrate for 30 secs before measuring.
    if "aerodyne" in syslist: 
        if aerodyne_check == True:
            ShowStatus("Aerodyne Measure (in background):  %s" % (status_tag))
            proc3 = action.runbg("aerodyne_measure.act", utils.get_resource("aerodyne_datafile")) 
            proc3_on = True
            #aerodyne_measure = multiprocessing.Process(target=measure_aerodyne_datafile_exchange, args=(action,
            #    status_tag, "aerodyne", utils.get_resource("aerodyne_datafile"), utils.get_resource("aerodyne_high_freq_datafile")))
            #aerodyne_measure.start()
    if "picarro" in syslist:
        # Continue flushing prior to sampling with Picarro, 
        ShowStatus("Continue flushing prior to Picarro sampling:  %s" % (status_tag))
        action.run("flush_pre-picarro.act")
        # measure picarro
        ShowStatus("Measure Picarro - measure_picarro.act:  %s" % (status_tag))
        action.run("measure_picarro.act", utils.get_resource("picarro_datafile"), utils.get_resource("picarro_qc_datafile"))

    # Turn Manifold to next off port, ManifoldSelect Off, and sample mks pressure control valve close
    ShowStatus("end sample flow:  %s" % (status_tag))
    action.run("closerelay.act","@Sample_mks_close_valve")
    action.run("openrelay.act", "@pc_sample")
    # final flask pressure measurement 
    action.run("measure_flask_pressure.act", utils.get_resource("flask_press_datafile"))
    # turn manifold to next off port
    action.run("turn_multiposition.act", "Manifold%s" % (sampledata["manifold"]), int(sampledata["port_num"])+1)
    # turn Manifold Select to off port
    action.run("turn_multiposition.act", "ManifoldSelect", next_off_manifold)

    # update sample list database if measuring samples or standards  
    if mode == 2 and (gastype.upper() == "SMP" or gastype.upper() == "STD" or sampledata["sample_type"].upper() == "WARMUP"):
        magiccdb.mark_complete(sampledata["analysis_id"])


    # handle error from Aerodyne (on comms failure skip all samples but finish with ref and process data)
    if aerodyne_check == False:
        # need to raise error message here
        msg = "Aerodyne communication error on  %s   Rest of run skipped" % (status_tag)
        ShowStatus("ERROR: %s" % msg)
        #answer = ShowMessage(msg=msg, nostop=True)

        # mark all "ready" samples as "error" 
        rows = magiccdb.get_analysis_info()
        for line in rows:
            if line[12].upper() == "READY":
                magiccdb.mark_error(line[0])

    # prep system for next sample while waiting for chromatography to finish
    ShowStatus("Prep System for next sample")
    evac_err = prep_system(action, sampledata, referencedata, mode)

    # wait for GC processes to finish
    ShowStatus("Waiting for background processes to finish:  %s" % (status_tag))
    if proc1_on:  proc1.wait()
    if proc2_on:  proc2.wait()
    if proc3_on:  proc3.wait()

    action.run("aerodyne_stop_wd.act") # may need to check if this goes through

    # set cycle end time so can calculate duration of cycle
    utils.set_end_time(cycle=True) 

    # process data 
    if gastype.upper() == "SMP" and (sampledata["sample_type"] == 'pfp' or sampledata["sample_type"] == 'flask'):
        prefix = "%-4s %10s" % (gastype, sampledata["event_num"])
        event_num_for_cvt_data = sampledata["event_num"]
    else:
        prefix = "%-4s %10s" % (gastype, sampledata["sample_id"])
        event_num_for_cvt_data = None 

    # first process qc data
    ShowStatus("Processing system QC data:  %s" % (status_tag))
    datafile = "data.qc"
    data = utils.cvt_data("QC", utils.get_resource("environment_qc_datafile"), utils.get_resource("environment_qc_datafile"), 
            sampledata["manifold"], sampledata["port_num"], event_num_for_cvt_data)
    f = open(datafile, "a")
    print("%s %s" % (prefix, data), file=f)
    f.close()

    # process instrument data
    for inst in syslist:
        ShowStatus("Processing %s data into data.* files:  %s" % (inst, status_tag))
        inst_id, sernum = utils.get_instrument_id(inst)
        if inst.upper() == "GC" or inst.upper() == "GC1" or inst.upper() == "GC2":
            for sp in sysgases[inst.lower()]:
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

        else:

            # process Aerodyne and PC data here.  
            datafile = "data.%s" % inst.lower()
            high_freq_datafile = "%s.high_freq" % datafile
        
            #temp_datafile = utils.get_resource("%s_datafile" % inst.lower())
            #temp_qc_datafile = utils.get_resource("%s_qc_datafile" % inst.lower())

            data = utils.cvt_data( inst, utils.get_resource("%s_datafile" % inst.lower()), utils.get_resource("%s_qc_datafile" % inst.lower()))
            f = open(datafile, "a")
            print("%s %s" % (prefix, data), file=f)
            f.close()

            # add high freq data to high_freq_data.'inst' - will turn into data file.
            # add the cycle start time to line to help finding data
            dt = utils.get_start_time(cycle=True)
            time_tag = "%4d %02d %02d %02d %02d %02d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)
            f2 = open(utils.get_resource("monitor_device_save_file", "%s" % inst.lower()), "r")
            high_freq_data = f2.readlines()
            f2.close()
            f = open(high_freq_datafile, "a")
            for line in high_freq_data:
                #print("%s %s" % (prefix, line.rstrip()), file=f)
                print("%s %s %s" % (prefix, time_tag, line.rstrip()), file=f)
            f.close()
    
    ShowStatus("################  END RUN_SAMPLE:  %s" % (status_tag))

    # if error during system evacuation step then stop analysis
    # Mark all ready samples as error so code will process data files before exiting
    # Note: since running REF shot in background we start the next pfp flask and then wait for the REF shot to finish 
    #       before actually running the sample flask. This means that when we get a system evac error (evac_err)
    #       and mark all the samples as "error" here, the current pfp flask will still be run. This could be
    #       a problem if the system was not evacuated correctly. Will need to check on this error mark in modes.py 
    #       where we wait for the REF to finish to fix.
    if evac_err == 1: 
        ShowStatus("!!! Error on system evacuation, mark all ready samples as error")
        if mode == 5 or mode == 4 or mode == 3 or mode == 1:   # test mode or continuous ref shots, exit when evac error happens
            ShowStatus("!!! Error on system evacuation, Exiting ....")
            sys.exit()
        # mark all "ready" samples as "error" 
        rows = magiccdb.get_analysis_info()
        for line in rows:
            if line[12].upper() == "READY":
                magiccdb.mark_error(line[0])


    #if run_sample is run in background, use namespace to return new offset value
    # otherwise just return new value
    if namespace:
        namespace.transducer_offset = transducer_offset
    else:
        return transducer_offset
    

##############################################################
# Check the status of the UPS low battery signal.
# Shutdown in safe position if low battery indicated
def check_ups():

    actionfile = "check_ups.act"

    # This requires action to use PrintData instead of LogData
    action.run(actionfile)
    line = action.output

    (j, v, jj, jjj) = line.split()
    volt = float(v)

    s = "UPS Low battery indicator signal:  %10.2f" % volt
    logging.info(s)
    #test voltage, shutdown if low
    if volt < 0.2:
            now = datetime.datetime.now()
            s = "UPS indicated LOW BATTERY at %s, shutting down" % now.strftime("%c")
            ShowStatus(s)
            endprog()



#####################################################################
# PFP functions
#####################################################################
# Evac pfp manifold, checks for open flasks
#  
def evac_pfp(action, manifold, port, event_num=None):

    evac_check = False
    evac_1torr_time = False
    evac_100mtorr_time = False
    press = False
    msg = None

    ShowStatus("Start pfp evac  Manifold%s   Port %s   Event_num %s" % (manifold, port, event_num))

    # turn manifold valve to correct port
    action.run("turn_multiposition.act", "Manifold%s" % manifold, port)  
    time.sleep(1)

    # Start evacuation
    action.run("turn_multiposition.act", "Manifold%s_Evac" % manifold, "@evac_on")

    # set start time 
    evac_time_start = datetime.datetime.now()
    evac_time_end = evac_time_start + datetime.timedelta(seconds=config.pfp_evac_time)
    above_1torr = True
    above_100mtorr = True
    time.sleep(5) # 5 secs to let valves get into position before checking

    # check posistions of valves to make sure correct. Only try to correct once then skip pfp if evac fails by being too fast
    action.run("valco_current_position.act", "Manifold%s" % manifold)
    cp = int(action.output)
    ShowStatus("In evac_pfp: current position Manifold%s is %s." % (manifold, cp))
    if cp != int(port):
        ShowStatus("In evac_pfp: current position Manifold%s is %s. Wrong port!!! trying again" % (manifold, cp))
        # turn manifold valve to correct port
        action.run("turn_multiposition.act", "Manifold%s" % manifold, port)  

    action.run("valco_current_position.act", "Manifold%s_Evac" % manifold)
    cp = int(action.output)
    ShowStatus("In evac_pfp: current position Manifold%s_Evac is %s." % (manifold, cp))
    if cp != int(utils.get_resource("evac_on")):
        ShowStatus("In evac_pfp: current position Manifold%s_Evac is %s. Wrong port!!! trying again" % (manifold, cp))
        # Start evacuation
        action.run("turn_multiposition.act", "Manifold%s_Evac" % manifold, "@evac_on")

    # monitor pressure on vacuum gauge
    while datetime.datetime.now() <= evac_time_end:
        action.run("measure_manifold_vacuum.act", "Manifold%s" % manifold )
        (j, p, j, j) = action.output.split()
        #check returned value, if above 10V then is bad data point, skip and try again
        if float(p) >= 10.0 or float(p) <= 0.0:
            ShowStatus("Bad value (%s) from transducer, retry" % (p))
            time.sleep(2.0)
            continue

        press = 10**(float(p)-4.0)
        #print("manifold press signal:  %7.3f Torr (%7.3f V)" % (press, float(p)), file=sys.stderr)
        if above_1torr and float(press) <= 1.0 :   #4V = 1 Torr
            evac_1torr_time = datetime.datetime.now() - evac_time_start
            above_1torr = False
            ShowStatus("Time for pfp manifold to evac to 1 Torr = %s seconds" % evac_1torr_time.seconds)
        if above_100mtorr and float(press) <= 0.1 :   
            evac_100mtorr_time = datetime.datetime.now() - evac_time_start
            above_100mtorr = False
            ShowStatus("Time for pfp manifold to evac to 100 mTorr = %s seconds" % evac_100mtorr_time.seconds)
        time.sleep(2.0)

    #determine time for evacuation step
    evac_time = datetime.datetime.now() - evac_time_start

    # if never got to 1 Torr, set to time after timeout
    if not evac_1torr_time:
        evac_1torr_time = evac_time
    if not evac_100mtorr_time:
        evac_100mtorr_time = evac_time
    if not press:
        press = -99.9
    

#   # test time pfp took to hit 1 Torr to check for open flasks
    if evac_1torr_time.seconds <= config.pfp_evac_1torr_time_limit:
        # test time pfp took to hit 100 mTorr to check for evac valve not turning to correct port
        if evac_100mtorr_time.seconds > config.pfp_evac_100mtorr_time_limit:
            evac_check = True
            msg = "passed both checks"
        else:
            msg = "100mTorr test fast (%s seconds)" % evac_100mtorr_time.seconds
    else:
        msg = "1 Torr test slow (%s seconds)" % evac_1torr_time.seconds 


    # turn manifold valve to next off port
    action.run("turn_multiposition.act", "Manifold%s" % manifold, int(port)+1)  
    time.sleep(2)
    # Stop evacuation
    action.run("turn_multiposition.act", "Manifold%s_Evac" % manifold, "@system_on")

    # record final pressure
    ShowStatus("Time for pfp manifold to evac to 1 Torr = %s seconds" % evac_1torr_time.seconds)
    ShowStatus("Time for pfp manifold to evac to 100 mTorr = %s seconds" % evac_100mtorr_time.seconds)
    ShowStatus("Final pfp manifold evac pressure signal:  %7.3f Torr  (%7.3f V)" % (press, float(p)))

    # record system evacuation time and final evac pressure
    temp_datafile = "port_evac_%s.dat" % (event_num)
    try:
           f = open(temp_datafile, "w")
           f.write("%s  %s  %7.3f %s\n" % (evac_1torr_time.seconds, evac_100mtorr_time.seconds, press, evac_time.seconds))
           f.close()
    except:
            ShowStatus("Could not open file %s for writing, continue ..." % temp_datafile)
            evac_check = False

    # return pass/fail and msg
    return evac_check, msg
#####################################################################



#####################################################################
# query status of 1:8 pfp splitter
def query_pfp_splitter(action, manifold):
    
    device_name = "Manifold%s_control" % manifold

    action.run("query_pfp_comm_splitter.act", device_name) 
        

#####################################################################
# Activate Port.  Sets pfp comms switch to correct port.
# used by other pfp comm commands and by flask/tank cal routines to 
# light up active port indicator lights on manifolds.
def activate_port(action, manifold, portnum):
    device_name = "Manifold%s_control" % manifold
    n = (int(portnum) // 2) +1
    cmd = "P%s" % n
    action.run("send_command.act", device_name, cmd)    
    time.sleep(5.0)
    
        
#####################################################################
# De-Activate All Ports.  
def de_activate_ports(action, manifold):
    device_name = "Manifold%s_control" % manifold
    cmd = "OFF"
    action.run("send_command.act", device_name, cmd)    
    # may want to check the results and return pass/fail 
        

#####################################################################
# Get pfp serial number and test against listed value.  
# Uses activate_port to select correct port on comms splitter
#
# Returns True if match, Flase if don't
#---------------------------
def getPFPID(action, manifold, port, pfpid):

    #  Test the pfp serial number here, skip to next pfp if doesn't match what is listed in
    #  pfp_table. (Will also fail with comm. error) If fails, try again then go to next pfp.

    # get manifold comms port from magicc.conf file
    device_name = "Manifold%s_host" % manifold
    #devfile = utils.devices[device_name.lower()].devfile
    devfile = utils.get_resource(device_name.lower())

    listed_serial = "%s" % (pfpid)

    try:
        rtn = subprocess.check_output("/home/magicc/bin/get_as_serial.pl %s" % devfile, shell=True)
        #return response.decode().strip("\n")
        returned_id = rtn.decode().strip("\n")
    except subprocess.CalledProcessError as e:
        returned_id = ""

    print("In common.getPFPID: first returned_id: %s" % returned_id, file=sys.stderr)
    actual_serial = "%s-FP" % (returned_id)

    if listed_serial != actual_serial:
        logging.error("First try failed, Pfp id MISMATCH:  Listed %s Actual %s " % (listed_serial, actual_serial))

        # power cycle pfp
        de_activate_ports(action, manifold)
        time.sleep(5)   
        activate_port(action, manifold, port)

        try:    
            rtn=subprocess.check_output("/home/magicc/bin/get_as_serial.pl %s" % devfile, shell=True)
            returned_id = rtn.decode().strip("\n")
        except subprocess.CalledProcessError as e:
            returned_id = ""

        print("In common.getPFPID: second returned_id: %s" % returned_id, file=sys.stderr)
        actual_serial = "%s-FP" % (returned_id)

        if listed_serial != actual_serial:
            logging.error("Second try failed, Pfp id MISMATCH:  Listed %s Actual %s " % (listed_serial, actual_serial))
            return False, listed_serial, actual_serial

    return True, listed_serial, actual_serial


#####################################################################
# open pfp flask
#---------------------------
def open_as_sample(action, manifold, port, pfp_id, flasknum):

    # Open the pfp flask
    ShowStatus("OPENING PFP FLASK VALVE, (%s, flask %s)" % (pfp_id, flasknum))

    # get manifold comms port from magicc.conf file
    device_name = "Manifold%s_host" % manifold
    #devfile = utils.devices[device_name.lower()].devfile
    devfile = utils.get_resource(device_name.lower())

    p = subprocess.call("/home/magicc/bin/open_as_sample.pl %s %s" % (devfile, flasknum), shell=True)

    if p != 0:
        # If could not open flask, try again 
        msg = "Error on flask OPEN:  %s flask %s" % (pfp_id, flasknum)
        logging.error("%s" % (msg))
        ShowStatus("%s" % (msg))

        ShowStatus("Attempting to close valve in case valve partially opened.")
        subprocess.call("/home/magicc/bin/close_as_sample.pl %s %s" % (devfile, flasknum), shell=True) #try to close valve in case it partially opened.

        # try opening pfp flask again
        ShowStatus("SECOND ATTEMPT OPENING PFP FLASK VALVE, (%s, flask %s)" % (pfp_id, flasknum))
        p2 = subprocess.call("/home/magicc/bin/open_as_sample.pl %s %s" % (devfile, flasknum), shell=True)
        if p2 != 0:
                # If could not open flask, skip and continue with rest of pfp
                msg = "Error when OPENING pfp valve (%s flask %s)" % (pfp_id, flasknum)
                logging.error(msg)
                ShowStatus("Attempting to close valve in case valve partially opened.")
                subprocess.call("/home/magicc/bin/close_as_sample.pl %s %s" % (devfile, flasknum), shell=True) #try to close valve in case it partially opened.
                return False

    return True


#####################################################################
# close pfp flask
#---------------------------
def close_as_sample(action, manifold, port, pfp_id, flasknum):

    # close pfp flasks
    ShowStatus("CLOSE PFP FLASK VALVE, (%s, flask %s)" % (pfp_id, flasknum))

    # activate manifold port  # DO NOT RE-ACTIVATE ON EACH STEP UNTIL JACK FIXES SPLITTER CODE
    #activate_port(action, manifold, port)

    # get manifold comms port from magicc.conf file
    device_name = "Manifold%s_host" % manifold
    #devfile = utils.devices[device_name.lower()].devfile
    devfile = utils.get_resource(device_name.lower())

    p = subprocess.call("/home/magicc/bin/close_as_sample.pl %s %s" % (devfile, flasknum), shell=True)

    if p != 0:
            # If could not close flask, try again 
            ShowStatus("CLOSEING PFP FLASK VALVE, Second attempt (%s, flask %s)" % (pfp_id, flasknum))
            p2 = subprocess.call("/home/magicc/bin/close_as_sample.pl %s %s" % (devfile, flasknum), shell=True) 

            if p2 != 0:
                ShowStatus("***Could not close pfp flask:  %s, flask %s." % (pfp_id, flasknum))
                return False

    return True












