
"""
Common routines used by more than 1 mode.


 
"""

import os
import sys
import shutil
import time
import  multiprocessing
import logging
import subprocess
import datetime

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

    # Evacuate AR cell
    runscript_accepted = False
    try_cnt = 0  # limit number of tries to 5 times, exit if can't get comms to work
    #action.run("aerodyne_evac.act")
    while runscript_accepted == False and try_cnt < 5:
        try:    
            # remove old acknowledgment files
            os.remove(utils.get_resource("aerodyne_run_script_ack"))
        except:
            pass

        ShowStatus("Aerodyne Evac (try %s):  %s   %s" % (try_cnt, gastype, gasname))
        action.run("aerodyne_start_evac.act")
        if os.path.isfile(utils.get_resource("aerodyne_run_script_ack")): runscript_accepted = True
        try_cnt += 1

    # wait for Aerodyne cell to evacuate
    ShowStatus("Waiting for Aerodyne to evacuate")
    action.run("aerodyne_evac_wait.act")

    # fill of Aerodyne cell.  Check acknowledgement of runscript command, repeat if not acknowledged.
    runscript_accepted = False
    try_cnt = 0  # limit number of tries to 5 times, exit if can't get comms to work

    while runscript_accepted == False and try_cnt < 5:
        try:    
            # remove old acknowledgment files
            os.remove(utils.get_resource("aerodyne_run_script_ack"))
        except:
            pass
        
        if measure:
            ShowStatus("Aerodyne Fill and start write data to transient data file:  %s   %s" % (gastype, gasname))
            action.run("aerodyne_fill_and_write_data.act") #3 secs 
        else:
            ShowStatus("Aerodyne Fill:  %s   %s" % (gastype, gasname))
            action.run("aerodyne_fill.act") #3 secs 

        if os.path.isfile(utils.get_resource("aerodyne_run_script_ack")): runscript_accepted = True
        try_cnt += 1
    
    # wait for 15 secs to fill cell to 50 Torr, takes about 10 seconds with 0.006" critical flow orifice. 
    # wait for 20 secs to fill cell to 50 Torr, takes about 16 seconds with 0.004" critical flow orifice. 
    #For background wait aerodyne_abg_duration + 10s for fill
    ShowStatus("waiting for fill to finish")
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

    return transducer_offset


##############################################################

##############################################################
def run_sample(action, syslist, sysgases, referencedata, h2_referencedata, sampledata=None, gastype="NUL", storegc=False, transducer_offset=0.0, namespace=None):
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
            use to make sure don't relax sample loop unless positive pressure. Re-set each cycle to 
            account for any drift.

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
    #fn_list.append(utils.get_resource("picarro_datafile"))
    #fn_list.append(utils.get_resource("monitor_device_save_file", "picarro"))
    #fn_list.append(utils.get_resource("picarro_qc_datafile"))
    #
    fn_list.append(utils.get_resource("aerodyne_datafile"))
    fn_list.append(utils.get_resource("monitor_device_save_file", "aerodyne"))
    fn_list.append(utils.get_resource("aerodyne_qc_datafile"))
    #
    fn_list.append(utils.get_resource("aerolaser_datafile"))
    fn_list.append(utils.get_resource("monitor_device_save_file", "aerolaser"))
    fn_list.append(utils.get_resource("aerolaser_qc_datafile"))
    #
    fn_list.append(utils.get_resource("aeris_datafile"))
    fn_list.append(utils.get_resource("monitor_device_save_file", "aeris"))
    fn_list.append(utils.get_resource("aeris_qc_datafile"))

    for fn in fn_list:
        if os.path.exists(fn): os.remove(fn)

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

    ## measure system QC data
    #ShowStatus("Measure system qc data at start of cycle")
    #action.run("measure_qc.act", utils.get_resource("environment_qc_datafile"))

    #Vent any residual pressure in the system 
    ShowStatus("vent residual pressure in system")
    action.run("vent_system.act")




    # If running H2 GC, flush sample loop then run chromatography in background
    if "gc1" in syslist:
        ShowStatus("Flush H2 sample loop:  %s" % (gastype))
        if run_ref:
            action.run("flush_gc.act", h2_ref_data["manifold"], utils.get_resource("gc_qc_datafile"))
            _port = h2_ref_data["port_num"]
        else:
            action.run("flush_gc.act", sampledata["manifold"], utils.get_resource("gc_qc_datafile"))
            _port = sampledata["port_num"]

        ShowStatus("Run H2 chromatography")
        proc2 = action.runbg("sample_h2.act", "gc.h2.txt", _port)
        proc2_on = True

    # turn manifold select to manifold port if any optical analyzer running
    if "lgr" in syslist or "aerolaser" in syslist or "picarro" in syslist or "aeris" in syslist or "aerodyne" in syslist:
        ShowStatus("Move ManifoldSelect to Manifold%s_port" % (sampledata["manifold"]))
        action.run("turn_multiposition.act",  "ManifoldSelect", "@Manifold%s_port" % (sampledata["manifold"]))


    #### Combined Aerodyne and AeroLaser measurements
    if "aerodyne" in syslist or "aerolaser" in syslist:
        if "aerolaser" in syslist:
            # initiate internal zero. VURF already on external zero so if initiate zero
            # before sample air, the flushing time is shorter since doesn't see real air.
            # Waits 10 secs before returning to give cell extra flushing time without running sample air
            ShowStatus("Initiating internal scrubber in AeroLaser")
            try:
                action.run("aerolaser_start_internal_zero.act")
                msg = action.output
                ShowStatus("Output from action: %s" % msg)
            except:
                ShowStatus("Action failed")
        else:
            time.sleep(2)

        ShowStatus("Start flushing sample/standard through system using Aerolaser")
        action.run("aerolaser_start_flush.act", sampledata["manifold"]) # waits 5 secs before returning

        if "aerolaser" in syslist:
            # initiate internal zero measurement
            ###### MAY NEED WAIT STATEMENT HERE IF NEED MORE FLUSHING 
            ShowStatus("Measuring zero on AeroLaser (using internal scrubber)")
            action.run("measure_aerolaser.act", utils.get_resource("aerolaser_datafile"), utils.get_resource("aerolaser_qc_datafile"))

            # process zero measurement into data.aerolaser file so doesn't get overwritten
            process_aerolaser_zero("aerolaser", sampledata["manifold"])

            ## process zero measurement into data.aerolaser file so doesn't get overwritten
            #datafile = "data.%s" % _inst.lower()
            #high_freq_datafile = "%s.high_freq" % datafile

            ## add averages to data.'inst' - will turn into rawfile
            #data = utils.cvt_data( _inst, utils.get_resource("aerolaser_datafile"), utils.get_resource("aerolaser_qc_datafile"))
            #f = open(datafile, "a")
            #print("%-4s %10s %s" % ("REF", "Z", data), file = f)
            #f.close()

            ## add high freq data to high_freq_data.'inst' - will turn into data file
            #f2 = open(utils.get_resource("monitor_device_save_file","aerolaser"), "r")
            #high_freq_data = f2.readlines()
            #f2.close()
            #f = open(high_freq_datafile, "a")
            #for line in high_freq_data:
            #    print("%-4s %10s %s" % ("REF", "Z", line.rstrip()), file = f)
            #f.close()

        else:
            time.sleep(60)   # check this timing

        if "aerolaser" in syslist:
            # turn off internal zero in aerolaser
            ShowStatus("Turning off internal scrubber in AeroLaser")
            try:
                action.run("aerolaser_stop_internal_zero.act")
                msg = action.output
                ShowStatus("Output from action: %s" % msg)
            except:
                ShowStatus("Action failed")
            

        else:
            time.sleep(2)

        if "aerodyne" in syslist:
            # evac aerodyne and fill (~34 secs)
            ShowStatus("Evac Aerodyne, first flush")
            #def fill_aerodyne(action, gastype, gasname, aerodyne_qc_datafile="aerodyne_qc.dat",  measure=False):
            fill_aerodyne(action, gastype, sampledata["sample_id"], measure=False)

            # evac aerodyne and fill (~34 secs)
            ShowStatus("Evac Aerodyne, second flush")
            fill_aerodyne(action, gastype, sampledata["sample_id"], measure=False)
            
            ##measure gas flow rate just prior to third filling
            action.run("measure_flow.act", utils.get_resource("aerodyne_qc_datafile"), "Replace")

            # evac aerodyne and fill (~34 secs)
            ShowStatus("Evac Aerodyne, third flush, measure this time")
            fill_aerodyne(action, gastype, sampledata["sample_id"], measure=True)

            #put measure_aerodyne in background
            #flow measured within evac/fill step
            ShowStatus("Measure Aerodyne (in background):  %s  %s" % (gastype, sampledata["sample_id"]))
            proc3 = action.runbg("aerodyne_measure.act", utils.get_resource("aerodyne_datafile"))
            proc3_on = True
        else:
            proc3_on = False
            time.sleep(102) # make sure this time equals time typically used by Aerodyne to flush/fill


        # measure aerolaser
        if "aerolaser" in syslist:
            ShowStatus("Measure AeroLaser:  %s  %s" % (gastype, sampledata["sample_id"]) )
            action.run("measure_aerolaser.act", utils.get_resource("aerolaser_datafile"), utils.get_resource("aerolaser_qc_datafile"))

        ShowStatus("Stop flushing Aerolaser")
        action.run("aerolaser_stop_flush.act")




    # If running Aeris, flush and measure Aeris
    if "aeris" in syslist:
        ShowStatus("Flush and measure Aeris:  %s  %s" % (gastype, sampledata["sample_id"]))
        action.run("measure_aeris.act",   utils.get_resource("aeris_datafile"), utils.get_resource("aeris_qc_datafile"))


    # turn manifold select to next off port
    ShowStatus("Turning to off port on manifold select")
    #action.run("turn_multiposition.act", "@%s" % next_off_manifold)
    action.run("turn_multiposition.act", "ManifoldSelect", "4")

    # wait for Aerodyne to finish measurement
    if proc3_on:
        ShowStatus("Waiting for Aerodyne to finish")
        proc3.wait()

    # wait for H2 GC to finish
    if proc2_on:
        ShowStatus("Waiting for H2 chromatography to finish")
        proc2.wait()

    # update sample list database if measuring samples or standards  
    if mode == 2 and (gastype.upper() == "SMP" or gastype.upper() == "STD" or sampledata["sample_type"].upper() == "WARMUP"):
        magiccdb.mark_complete(sampledata["analysis_id"])


    ## handle error from Aerodyne (on comms failure skip all samples but finish with ref and process data)
    #if aerodyne_check == False:
    #    # need to raise error message here
    #    msg = "Aerodyne communication error on  %s   Rest of run skipped" % (status_tag)
    #    ShowStatus("ERROR: %s" % msg)
    #    #answer = ShowMessage(msg=msg, nostop=True)

    #    # mark all "ready" samples as "error" 
    #    rows = magiccdb.get_analysis_info()
    #    for line in rows:
    #        if line[12].upper() == "READY":
    #            magiccdb.mark_error(line[0])

    action.run("aerodyne_stop_wd.act") #As long as running it doesn't matter if this goes through or not so no need to check for acknowledgement.

    # set cycle end time so can calculate duration of cycle
    utils.set_end_time(cycle=True) 

    # process data 
    if gastype.upper() == "SMP" and (sampledata["sample_type"] == 'pfp' or sampledata["sample_type"] == 'flask'):
        prefix = "%-4s %10s" % (gastype, sampledata["event_num"])
        event_num_for_cvt_data = sampledata["event_num"]
    else:
        prefix = "%-4s %10s" % (gastype, sampledata["sample_id"])
        event_num_for_cvt_data = None 

    ## first process qc data #### No system QC data for cocal system
    #ShowStatus("Processing system QC data:  %s" % (status_tag))
    #datafile = "data.qc"
    #data = utils.cvt_data("QC", utils.get_resource("environment_qc_datafile"), utils.get_resource("environment_qc_datafile"), 
    #        sampledata["manifold"], sampledata["port_num"], event_num_for_cvt_data)
    #f = open(datafile, "a")
    #print("%s %s" % (prefix, data), file=f)
    #f.close()

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

        #elif inst.upper() == "AEROLASER":
        #    datafile = "data.%s" % inst.lower()
        #    high_freq_datafile = "%s.high_freq" % datafile
        #
        #    # process zero measurement first
        #    tmp_inst = "aerolaser_zero"
        #    tmp_datafile = "%s.dat" % tmp_inst.lower()
        #    tmp_highfreq_datafile = "%s_high_freq.dat" % tmp_inst.lower()
        #    tmp_qc_datafile = "%s_qc.dat" % tmp_inst.lower()
        #
        #    # add averages to data.'inst' - will turn into rawfile
        #    data = utils.cvt_data( tmp_inst, tmp_datafile, tmp_qc_datafile)
        #    f = open(datafile, "a")
        #    print("%3s %3s %s" % ("REF", "Z", data), file = f)
        #    f.close()
        #
        #    # add high freq data to high_freq_data.'inst' - will turn into data file
        #    f2 = open(tmp_highfreq_datafile, "r")
        #    high_freq_data = f2.readlines()
        #    f2.close()
        #    f = open(high_freq_datafile, "a")
        #    for line in high_freq_data:
        #        print("%3s %3s %s" % ("REF", "Z", line.rstrip()), file = f)
        #    f.close()
        #
        #
        #
        #    # process air measurement
        #    tmp_datafile = "%s.dat" % inst.lower()
        #    tmp_highfreq_datafile = "%s_high_freq.dat" % inst.lower()
        #    tmp_qc_datafile = "%s_qc.dat" % inst.lower()
        #
        #    # add averages to data.'inst' - will turn into rawfile
        #    data = utils.cvt_data( tmp_inst, tmp_datafile, tmp_qc_datafile)
        #    f = open(datafile, "a")
        #    print("%3s %3s %s" % (gastype, sampledata["sample_id"], data), file = f)
        #    f.close()
        #
        #    # add high freq data to high_freq_data.'inst' - will turn into data file
        #    f2 = open(tmp_highfreq_datafile, "r")
        #    high_freq_data = f2.readlines()
        #    f2.close()
        #    f = open(high_freq_datafile, "a")
        #    for line in high_freq_data:
        #        print("%3s %3s %s" % (gastype, sampledata["sample_id"], line.rstrip())), file = f)
        #    f.close()
        #
        #

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






#####################################################################
#  For cocal-1 -- common code for running final zero aliquot on aerolaser
#  Used after last Ref aliquot in tank_cal and lin_check modes.
#---------------------------
def final_aerolaser_zero(action, inst, manifold):
        ShowStatus("Running final Aerolaser zero measurement")

        # initiate internal zero measurement
        ShowStatus("Initiating internal scrubber in AeroLaser")
        try:
            action.run("aerolaser_start_internal_zero.act")
            msg = action.output
            ShowStatus("Output from action: %s" % msg)
        except:
            ShowStatus("Action failed")


        # turn manifold select to manifold port if any optical analyzer running
        ShowStatus("Move ManifoldSelect to Manifold%s_port" % (manifold))
        action.run("turn_multiposition.act",  "ManifoldSelect", "@Manifold%s_port" % manifold)

        ShowStatus("Start flushing sample/standard through system using Aerolaser for final zero measurement")
        action.run("aerolaser_start_flush.act", manifold) # waits 5 secs before returning

        ###### MAY NEED WAIT STATEMENT HERE IF NEED MORE FLUSHING 

        ShowStatus("Measuring zero on AeroLaser (using internal scrubber)")
        action.run("measure_aerolaser.act", utils.get_resource("aerolaser_datafile"), utils.get_resource("aerolaser_qc_datafile"))

        # turn off internal zero in aerolaser
        ShowStatus("Turning off internal scrubber in AeroLaser")
        try:
            action.run("aerolaser_stop_internal_zero.act")
            msg = action.output
            ShowStatus("Output from action: %s" % msg)
        except:
            ShowStatus("Action failed")

        process_aerolaser_zero(inst, manifold)

        return

            

#####################################################################
#  For cocal-1 -- common code for processing zero aliquot on aerolaser
#  Zero measurements use same files as smp/std measurements so need to 
#  be processed just after collection.
#  Processing from aerolaser.dat into data.aerolaser file.
#---------------------------
def process_aerolaser_zero(inst, manifold):

        # process zero measurement into data.aerolaser file so doesn't get overwritten
        datafile = "data.%s" % inst.lower()
        high_freq_datafile = "%s.high_freq" % datafile

        # add averages to data.'inst' - will turn into rawfile
        data = utils.cvt_data( inst, utils.get_resource("aerolaser_datafile"), utils.get_resource("aerolaser_qc_datafile"))
        f = open(datafile, "a")
        print("%-4s %10s %s" % ("REF", "Z", data), file = f)
        f.close()

        # add high freq data to high_freq_data.'inst' - will turn into data file
        f2 = open(utils.get_resource("monitor_device_save_file","aerolaser"), "r")
        high_freq_data = f2.readlines()
        f2.close()
        f = open(high_freq_datafile, "a")
        for line in high_freq_data:
            print("%-4s %10s %s" % ("REF", "Z", line.rstrip()), file = f)
        f.close()

        # remove temp high freq file so empty for next read
        os.rename(utils.get_resource("monitor_device_save_file","aerolaser"), "backup_%s" % utils.get_resource("monitor_device_save_file","aerolaser"))

        return


