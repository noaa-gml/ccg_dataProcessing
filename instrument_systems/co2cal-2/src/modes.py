
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
action = RunAction(actiondir=config.ACTIONDIR, configfile=config.CONFFILE, testMode=config.testmode, debug=True)


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
    sys.exit(msg)

referencedata = {
    "manifold" : manifold,
    "port_num"  : portnum,
    "serial_num" : "NA",
    "sample_type" : "REF",   
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
    sys.exit(msg)

junkdata = {
    "manifold" : manifold,
    "port_num"  : portnum,
    "serial_num" : "NA",
    "sample_type" : "JNK",    # reset this field for each internal mode
    "sample_num"  : 1,
    "sample_id"   : config.junk_name,
    "event_num"   : None,
    "analysis_id" : None,
    "pressure"    : "NA",
    "regulator"   : "NA",
    "sample_id_num" : -9
    }




#################################################################
# Mode 1, pre analysis Warmup mode for system.
# Run a single sample from each reference gas through corresponding analyzer.
##############################################################
def pre_analysis_check(syslist, sysgases):

    global action, magiccdb
    global referencedata
    global junkdata

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("ref")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    config.storegc = True   # Don't archive chromatograms if False

    # backup the data files
    utils.backup_data_files()

    ShowStatus("Begin Pre-Analysis Mode")

    # Log our start time
    utils.set_start_time()


    ########
    now = datetime.datetime.now()
    s = now.strftime("%Y-%m-%d %H:%M:%S")
    dry_time = config.pre_analysis_dry_time #in seconds
    dry_minutes = dry_time / 60.0

    #start with idle gas to dry systems
    ShowStatus("Pre-analysis, Start with idle gas to dry system, start: %s , idle: %d minutes" % (s, dry_minutes ))
    time.sleep(dry_time)
    ########

    for loopnum in range(0,config.num_pre_analysis_loops):

        logging.info("Pre-analysis check loop %s", loopnum)
        flow_check = run_sample(action, syslist, sysgases, referencedata, None, "null", 
                                config.storegc, config.transducer_offset)





##############################################################
# Mode 2, Sample analysis
# Loops through ready manifolds and runs internal modes (flask, pfp, tankcal) according
# to the type of sample on the manifolds.
#   ready manifolds listed in file sys.ready_manifolds
#
def sample_analysis(syslist, sysgases):

    global action, magiccdb
    global referencedata
    global junkdata

    ShowStatus("Begin Sample Analysis")

    cnt = 0 # use to cycle in R0 occaisonally to keep ref regulator flushed. src/config.py num_junk_cycles defines number of J0 between R0

    current_manifold = magiccdb.get_next_manifold()
    
    # if sample list is empty, check to see if should idle on continuous aliquots. Use cnt to run R0 occaisonally
    if not current_manifold:
        s = utils.get_setup_value("RunShots")
        if s:
            runshots = int(s[0])
        else:
            runshots = 0
    
        if runshots != 0:
            cnt += 1
            if cnt % config.num_junk_cycles == 0:
                msg = "Continuous shots, cnt=%s --  Running R0" % (cnt)
                ShowStatus(msg)
                current_manifold = (referencedata["manifold"], "int_ref")  
            else:
                msg = "Continuous shots, cnt=%s --  Running J0" % (cnt)
                ShowStatus(msg)
                current_manifold = (junkdata["manifold"], "int_junk")  
                

    while current_manifold is not None:
        (manifold, sample_type) = current_manifold

        msg = "In modes/sample_analysis -  manifold: %s    sample_type: %s" % (manifold, sample_type)
        #print("%s" % msg, file=sys.stderr)
        logging.info(msg)

        # select internal mode by type of sample on the manifold
        # return here only after all consecutive samples of same sample type are done.
        if sample_type.upper() == "FLASK": 
            msg = "FLASK analysis not setup on %s, exiting." % config.SYSTEM
            sys.exit(msg)
            #flask_analysis(syslist, sysgases)
            cnt = 0 # reset counter for idling on continuos shots
        elif sample_type.upper() == "PFP": 
            msg = "PFP analysis not setup on %s, exiting." % config.SYSTEM
            sys.exit(msg)
            #pfp_analysis(syslist, sysgases)
            cnt = 0 # reset counter for idling on continuos shots
        elif sample_type.upper() == "CAL": 
            tankcal(syslist, sysgases)
            cnt = 0 # reset counter for idling on continuos shots
        elif sample_type.upper() == "NL": 
            lin_check(syslist, sysgases)  
            cnt = 0 # reset counter for idling on continuos shots
        elif sample_type.upper() == "WARMUP": 
            warmup(syslist, sysgases)
            cnt = 0 # reset counter for idling on continuos shots
        elif sample_type.upper() == "INT_REF": 
            internal_single_shot(syslist, sysgases)
        elif sample_type.upper() == "INT_JUNK": 
            internal_single_shot(syslist, sysgases, junk=True)
        else:
            print("sample type %s not defined for sample_analysis mode" % sample_type, file=sys.stderr)
            sys.exit()

        # see if there is another manifold ready for analysis
        current_manifold = magiccdb.get_next_manifold()

        # if sample list is empty, check to see if should continue running Ref aliquots
        if not current_manifold:
            s = utils.get_setup_value("RunShots")
            if s:
                runshots = int(s[0])
            else:
                msg = "Could not read setup value for RunShots, setting default = 0"
                ShowStatus(msg)
                runshots = 0

            if runshots == 0:
                msg = "Run continuous shots J0/R0 function not set"
                ShowStatus(msg)
            else:
                cnt += 1
                if cnt % config.num_junk_cycles == 0:
                    msg = "Idling on continuous shots, cnt=%s --  Running R0" % (cnt)
                    ShowStatus(msg)
                    current_manifold = (referencedata["manifold"], "int_ref")  
                else:
                    msg = "Idling on continuous shots, cnt=%s --  Running J0" % (cnt)
                    ShowStatus(msg)
                    current_manifold = (junkdata["manifold"], "int_junk")  
                    

    ShowStatus("No more ready manifolds, exiting ...")


##############################################################
# Internal Mode for Flask analysis
#       *** NOT SET UP ON CO2CAL-2
#
##############################################################
def flask_analysis(syslist, sysgases):

    global action, magiccdb
    global referencedata

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("flask")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    config.storegc = True

    ShowStatus("Begin Flask Analysis")

    # clear indicator lights
    de_activate_ports(action, "A")
    de_activate_ports(action, "B")

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()
    
    #set sample type of referencedata dictionary, use when prepping system for next aliquot at end of each cycle
    referencedata["sample_type"] = "flask"

    # get first sample to run
    sampledata, ready = magiccdb.get_next(sample_type="flask", asDict=True)

    if sampledata is None:
        # no flask data available
        return

    if not ready:
        # flask data available, but not ready
        # prompt operator to prep manifold, should not happen but just in case
        msg = "Flasks are not ready, Click OK to prep manfold and continue"
        answer = utils.ShowMessage(msg=msg, nostop=False)
        if "stop" in answer:
            sys.exit("manually stopping instead of preping flasks")
        else:
            ShowStatus("pause while prepping manifold for flask analysis")
            #!!! starting prep_manifold again may cause problems, just wait to see if become ready 
            #    since load flask step should have started prep_manifold.  Maybe should run a R0
            #    shot and then recheck
            #cmd = "/home/magicc/bin/prep_flask_manifold.py"
            #subprocess.Popen(cmd, shell=True, stdin=None, stdout=None, stderr=None)
            # run reference shot to give prep manifold time to finish
            config.transducer_offset = run_sample(action, syslist, sysgases, referencedata, None, "REF", 
                                                config.storegc, config.transducer_offset)
            # try to get sample info again
            sampledata, ready = magiccdb.get_next(sample_type="flask", asDict=True)
            
    
    # run first reference shot
    config.transducer_offset = run_sample(action, syslist, sysgases, referencedata, None, "REF", 
                                        config.storegc, config.transducer_offset)

    while sampledata is not None and ready == True:
        #check ups for low battery indicator
        #check_ups()

        logging.info("Analyzing flask %s from manifold %s port %s" % (sampledata["sample_id"], 
                sampledata["manifold"], sampledata["port_num"])) 

        #run sample
        activate_port(action, sampledata["manifold"], sampledata["port_num"])
        action.run("turn_multiposition.act", "Manifold%s_Evac" % sampledata["manifold"], "@system_on") # just to make sure
        config.transducer_offset = run_sample(action, syslist, sysgases, referencedata, sampledata, "SMP", 
                                            config.storegc, config.transducer_offset)
        de_activate_ports(action, sampledata["manifold"])

        #run reference
        config.transducer_offset = run_sample(action, syslist, sysgases, referencedata, None, "REF", 
                                            config.storegc, config.transducer_offset)

        # get next flask to analyze
        sampledata, ready = magiccdb.get_next(sample_type="flask", asDict=True)

        #if not ready and sampledata is not None:
        #   # prompt operator to prep manifold
        #   pass

    # Done with flask analysis, either finished all flasks or sample_type has changed
    # if leaving flask internal mode de-activate ports on both manifolds to clear lights
    de_activate_ports(action, "A")
    de_activate_ports(action, "B")

    #process flask data
    for inst in syslist:
        ShowStatus("Updating files for %s" % (inst))
        update_files(inst, sysgases, "flask")

    # update files for system qc (after flask)
    inst = "QC"
    ShowStatus("Updating files for %s" % (inst))
    update_files(inst, sysgases, "flask")

    # run flask flagging program
    for inst in syslist:
        ShowStatus("Run auto-flagging routine for files from %s" % (inst))
        run_auto_flag(inst, sysgases, "flask")


##############################################################
# Internal Mode for Tank calibrations
#
##############################################################
def tankcal(syslist, sysgases):

    global action, magiccdb
    global referencedata

    config.storegc = True

    ShowStatus("Begin tank calibration")

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("cals")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    #set sample type of referencedata dictionary, use when prepping system for next aliquot at end of each cycle
    referencedata["sample_type"] = "cal"

    # get first sample to run
    sampledata, ready = magiccdb.get_next(sample_type="cal", asDict=True)

    # exit cleanly if no samples ready
    if sampledata is None:
        ShowStatus("No ready sample tanks, returning")
        return

    while sampledata is not None:

        # backup the data files
        utils.backup_data_files()

        # Log our start time
        utils.set_start_time()

        #check ups for low battery indicator
        #check_ups()

        #current_port = sampledata["port_num"]
        current_sampledata = sampledata  #need to remember for processing after sampledata gets overwritten by next sample
        msg_prefix = "%s (Manifold %s, port %s) " % (current_sampledata["serial_num"], current_sampledata["manifold"],
                            current_sampledata["port_num"])
        # record current sample type for use in panel display
        try:
           f = open("sys.current_sample", "w")
           f.write("serialnum:  %s\n" % current_sampledata["serial_num"])
           f.write("regulator:  %s\n" % current_sampledata["regulator"])
           f.write("manifold:  %s\n" % current_sampledata["manifold"])
           f.write("portnum:    %s\n" % current_sampledata["port_num"])
           f.write("pressure:   %s\n" % current_sampledata["pressure"])
           f.close()
        except:
            ShowStatus("Could not open file %s for writing, continue ..."  % "sys.current_sample")

        # flush regulator of sample tank 
        ShowStatus("%s - Regulator flush. " % ( msg_prefix))
        
        if "picarro" in [x.lower() for x in syslist]:
                position = "B"
                flush_inst = "picarro"
        else:
                position = "A"
                flush_inst = "isotope"

        action.run("flush_regulator.act", sampledata["manifold"], sampledata["port_num"], position, 
                    flush_inst, utils.get_resource("monitor_device_result_file", "hp34970"))

        #get flow rate, pressure from file qc_raw.dat to test flow during regulator flush
        (j1, smp_press, smp_flow, ref_press, ref_flow, smp_flag, ref_flag, rT, cT) = utils.get_qc_raw_data()
        if smp_flag != 0:
            msg = "%s - Failed flow/pressure test during regulator flush.  SKIPPED" % ( msg_prefix)
            ShowStatus(msg)
            utils.ShowMessage(msg = msg, nostop=True, nowait=True)
            ShowStatus("after show message")

            # get all entries from db, check each one, if sample_id matches current and ready then mark as error
            rows = magiccdb.get_analysis_info()
            #print("len(rows): %s      type(rows): %s " % (len(rows), type(rows)), file=sys.stderr)
            for line in rows:
                #print("line: ",line, file=sys.stderr)

                if line[1] == sampledata["sample_id_num"] and line[12].upper() != "COMPLETE":
                    magiccdb.mark_error(line[0])

            # get next aliquot info
            sampledata, ready = magiccdb.get_next(sample_type="cal", asDict=True)
            continue

        # Loop until number of aliquots reached, indicated by change in sample_id_num
        while sampledata["sample_id_num"] == current_sampledata["sample_id_num"]:
            ShowStatus("%s - run_sample" % msg_prefix)
            flow_check = run_sample(action, syslist, sysgases, referencedata, sampledata, "cal", 
                                config.storegc, config.transducer_offset)

            # get next aliquot info
            sampledata, ready = magiccdb.get_next(sample_type="cal", asDict=True)
            if sampledata is None:
                #print("sample data returned NONE so break", file=sys.stderr)
                break


        
        #process data
        for inst in syslist:
            ShowStatus("%s - Updating files for %s" % (msg_prefix, inst))
            update_files(inst, sysgases, "cals", serialnum=current_sampledata["serial_num"], 
                manifold=current_sampledata["manifold"], portnum=current_sampledata["port_num"], 
                pressure=current_sampledata["pressure"], regulator=current_sampledata["regulator"])

        ## update files for system qc
        #inst = "QC"
        #ShowStatus("Updating files for %s" % (inst))
        #update_files(inst, sysgases, "cals", serialnum=current_sampledata["serial_num"], 
        #        pressure=current_sampledata["pressure"], regulator=current_sampledata["regulator"], 
        #        manifold=current_sampledata["manifold"], portnum=current_sampledata["port_num"])

        # if calibration and request number available then reset sort_num in refgas manager DB
        request_num = current_sampledata["event_num"]
        if request_num != 0:
                utils.reset_refgasmanager_sort(request_num)


##############################################################
# Internal Mode for PFP analysis
#       *** NOT SET UP ON CO2CAL-2
#
##############################################################
def pfp_analysis(syslist, sysgases):

    global action, magiccdb
    global referencedata

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("pfp")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    config.storegc = True
    previous_sample_id_num = None
    previous_pfp = None
    pfp_error_tag = False

    # remove pfp_qc_datafile 
    #if os.path.exists(utils.resources["pfp_qc_datafile"]): os.remove(utils.resources["pfp_qc_datafile"])

    # create a Manager to allow data to be passed out of subprocess. Need to keep track of transducer offset.
    mgr = multiprocessing.Manager()
    namespace = mgr.Namespace()
    namespace.transducer_offset = config.transducer_offset

    ShowStatus("Begin PFP Analysis")

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()

    #set sample type of referencedata dictionary, use when prepping system for next aliquot at end of each cycle
    referencedata["sample_type"] = "pfp"

    # get first sample to run
    sampledata, ready = magiccdb.get_next(sample_type = "pfp", asDict=True)

    # exit cleanly if no samples ready
    if sampledata is None:
        ShowStatus("No pfp samples ready, returning")
        return

    while sampledata:
        #check ups for low battery indicator
        #check_ups()

        #run reference, need to run in background so can start the evac cycle
            # remove pfp_qc_datafile so defaults will apply for REF
            #if os.path.exists(utils.resources["pfp_qc_datafile"]): os.remove(utils.resources["pfp_qc_datafile"])
        p = multiprocessing.Process(target=run_sample, name="ref", args=(action, syslist, sysgases, 
                        referencedata, None, "REF", config.storegc, config.transducer_offset, namespace))
        p.daemon=True
        p.start()
        ShowStatus("Start reference run as subprocess %s pid %s" % (p.name, p.pid))

        #check pfp serial number (if it is a new port) and activate the port
        if sampledata["sample_id_num"] != previous_sample_id_num:
            
            if previous_pfp:
                (prev_sn, prev_flask) = previous_pfp.split('-')
                if pfp_error_tag:
                    Log_PFPerror("pfp %s did NOT run successfully, check logs for errors" % (prev_sn))
                else:
                    Log_PFPerror("pfp %s ran successfully" % (prev_sn))

            # reset tag for indication of error with pfp
            pfp_error_tag = False

            # activate port - ONLY ACTIVATE ONCE AT THE START 
            de_activate_ports(action, "A")
            de_activate_ports(action, "B")
            activate_port(action, sampledata["manifold"], sampledata["port_num"])

            # check pfp serial number on first flask analysis only
            ShowStatus("Checking pfp serial number ...")
            (pfp_check, listed_sn, actual_sn) = getPFPID(action, sampledata["manifold"], 
                sampledata["port_num"], sampledata["serial_num"])
            ShowStatus("Check pfp serial number: Listed: %s    Actual: %s" % (listed_sn, actual_sn))

            # if pfp_check fails then skip all samples in pfp
            if not pfp_check:
                pfp_error_tag = True
                err_msg = "Wrong pfp connected to manifold %s port %s (listed: %s    actual: %s)." % (
                    sampledata["manifold"], sampledata["port_num"], listed_sn, actual_sn)
                #write pfp error to log file    
                Log_PFPerror(err_msg)
                
                # get all entries from magiccdb, check each one, if sample_id_num matches current and ready then mark as error
                rows = magiccdb.get_analysis_info()
                for line in rows:
                    if line[1] == sampledata["sample_id_num"] and line[12].upper() != "COMPLETE":
                        magiccdb.mark_error(line[0])
                        Log_PFPerror("%s skipped" % (line[4]))

                #reset previous sample_id_num (need this here so error message from bad comms with pfp gets stamped with the correct pfp number)
                previous_sample_id_num = sampledata["sample_id_num"]
                previous_pfp = sampledata["sample_id"]

                # get next flask to analyze and continue while loop after R0 finishes   
                sampledata, ready = magiccdb.get_next(sample_type="pfp", asDict=True)
                # wait for ref cycle to finish
                p.join()
                continue 

        #reset previous sample_id_num
        previous_sample_id_num = sampledata["sample_id_num"]
        previous_pfp = sampledata["sample_id"]

        #evac pfp manifold (check time to look for open flasks)
        pfp_evac_check, check_msg = evac_pfp(action, sampledata["manifold"], sampledata["port_num"], sampledata["event_num"])
        
        # handle pfp_evac error (returns true if successful, false if not). False means flask left open or a leak, skip rest of pfp
        if not pfp_evac_check:
            pfp_error_tag = True
            err_msg = "pfp %s (manifold_%s, port %s) failed evac test. Internal message: %s" % (
                sampledata["sample_id"], sampledata["manifold"], sampledata["port_num"], check_msg)
            #write pfp error to log file    
            Log_PFPerror(err_msg)

            # get all entries from db, check each one, if pfp num matches current and ready then mark as error
            rows = magiccdb.get_analysis_info()
            for line in rows:
                if line[1] == sampledata["sample_id_num"] and line[12].upper() != "COMPLETE":
                    magiccdb.mark_error(line[0])
                    Log_PFPerror("%s skipped" % (line[4]))

            # get next flask to analyze and continue while loop after R0 finishes   
            sampledata, ready = magiccdb.get_next(sample_type="pfp", asDict=True)
            # wait for ref cycle to finish
            p.join()
            continue

        #open pfp flask
        ShowStatus("opening pfp valve")
        open_check = open_as_sample(action, sampledata["manifold"], sampledata["port_num"], 
                sampledata["serial_num"], sampledata["sample_num"])
    
        # handle flask open error. If fails to open, then skip this flask
        if not open_check:
            pfp_error_tag = True
            err_msg = "pfp %s flask #%s (manifold_%s, port %s) failed to open." % (
                sampledata["sample_id"], sampledata["sample_num"], sampledata["manifold"], sampledata["port_num"])
            #write pfp error to log file    
            Log_PFPerror(err_msg)
            magiccdb.mark_error(sampledata["analysis_id"])
            Log_PFPerror("pfp %s flask %s skipped" % (sampledata["sample_id"],sampledata["sample_num"]))

            # get next flask to analyze and continue while loop after R0 finishes   
            sampledata, ready = magiccdb.get_next(sample_type="pfp", asDict=True)
            # wait for ref cycle to finish 
            p.join()
            continue

        # wait for ref cycle to finish 
        p.join()
        # read new value for transducer offset from namespace
        config.transducer_offset = namespace.transducer_offset

        
        #run sample
        ShowStatus("run pfp sample")
        action.run("turn_multiposition.act", "Manifold%s_Evac" % sampledata["manifold"], "@system_on") # just to make sure
        # cp pfp manifold evac data collected during reference cycle to current pfp_gc_datafile
            #try:
        #       shutil.copy(utils.resources["tmp_pfp_qc_datafile"], utils.resources["pfp_qc_datafile"])
            #except:
        #       ShowStatus("failed to copy %s to %s" % (utils.resources["tmp_pfp_qc_datafile"], utils.resources["pfp_qc_datafile"]))

        config.transducer_offset = run_sample(action, syslist, sysgases, referencedata, sampledata, "SMP", 
                                            config.storegc, config.transducer_offset)

        # close pfp flask valve (returns True for successful, False for close error)
        ShowStatus("close pfp valve")
        close_check = close_as_sample(action, sampledata["manifold"], sampledata["port_num"], 
                sampledata["serial_num"], sampledata["sample_num"])

        # handle flask close error
        if not close_check:
            err_msg = "pfp %s flask #%s (manifold_%s, port %s) failed to close. Error message returned from pfp, continue with next flask in case it did actually close" % (
                sampledata["sample_id"], sampledata["sample_num"], sampledata["manifold"], sampledata["port_num"])
            #write pfp error to log file    
            Log_PFPerror(err_msg)

        # get next flask to analyze
        sampledata, ready = magiccdb.get_next(sample_type="pfp", asDict=True)

    #run final reference
    #if os.path.exists(utils.resources["pfp_qc_datafile"]): os.remove(utils.resources["pfp_qc_datafile"])
    config.transducer_offset = run_sample(action, syslist, sysgases, referencedata, None, "REF", 
                                        config.storegc, config.transducer_offset)

    # if leaving pfp internal mode de-activate ports on both manifolds to clear lights and power down pfp's
    de_activate_ports(action, "A")
    de_activate_ports(action, "B")

    if previous_pfp:
        (prev_sn, prev_flask) = previous_pfp.split('-')
        if pfp_error_tag:
            Log_PFPerror("pfp %s did NOT run successfully, check logs for errors" % (prev_sn))
        else:
            Log_PFPerror("pfp %s ran successfully" % (prev_sn))
    
#   #process pfp data
    for inst in syslist:
        ShowStatus("Updating files for %s" % (inst))
        update_files(inst, sysgases, "pfp")

    # update files for system qc (after pfp run)
    inst = "QC"
    ShowStatus("Updating files for %s" % (inst))
    update_files(inst, sysgases, "pfp")

    # run flask flagging program
    for inst in syslist:
        ShowStatus("Run auto-flagging routine for files from %s" % (inst))
        run_auto_flag(inst, sysgases, "pfp")

    #if any pfp errors, display information 
    if os.path.exists(config.PFPLOGFILE):   
        f = open(config.PFPLOGFILE,'r')
        lines = f.readlines()
        f.close()
        if len(lines) > 1:
            utils.ShowMessage(file = config.PFPLOGFILE, nostop=True, nowait=True)


##############################################################
# Internal Mode for Response Curves
# 
##############################################################
def lin_check(syslist, sysgases):

    global action, magiccdb
    global referencedata

    config.storegc = True

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("nl")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    # get stdset from sys.stdset
    stdset = utils.get_stdset("StdSet")

    ShowStatus("Begin linearity check (%s)" % (stdset))

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()

    # set sample type of referencedata dictionary, use when prepping system for next aliquot at end of each cycle
    referencedata["sample_type"] = "nl"

    # get first sample to run
    sampledata, ready = magiccdb.get_next(sample_type="nl", asDict=True) 

    # exit cleanly if no samples ready
    if sampledata is None:
        ShowStatus("No NL standards ready, returning")
        return

#   #use keyword to start with reference on the first std.
    first_ref = True

    while sampledata is not None:
        msg_prefix = "%s (Manifold %s, port %s) " % (sampledata["serial_num"], sampledata["manifold"],
                            sampledata["port_num"])

        #check ups for low battery indicator
        #check_ups()

        #current_port = sampledata["port_num"]
        current_sample_id_num = sampledata["sample_id_num"]

        # flush regulator of sample tank 
        ShowStatus("%s - Regulator flush. " % ( msg_prefix))
        if "picarro" in [x.lower() for x in syslist]:
                position = "B"
                flush_inst = "picarro"
        else:
                position = "A"
                flush_inst = "isotope"

        action.run("flush_regulator.act", sampledata["manifold"], sampledata["port_num"], position, 
                    flush_inst, utils.get_resource("monitor_device_result_file", "hp34970"))

        #get flow rate, pressure from file qc_raw.dat
        (j1, smp_press, smp_flow, ref_press, ref_flow, smp_flag, ref_flag, rT, cT) = utils.get_qc_raw_data()
        if smp_flag != 0:
            msg = "%s - Failed flow/pressure test during regulator flush.  SKIPPED" % ( msg_prefix)
            ShowStatus(msg)
            utils.ShowMessage(msg = msg, nostop=True, noresponse=True)

            # get all entries from db, check each one, if sample_id matches current and ready then mark as error
            rows = magiccdb.get_analysis_info()
            for line in rows:
                if line[1] == sampledata["sample_id_num"] and line[12].upper() != "COMPLETE":
                    magiccdb.mark_error(line[0])

            # get next aliquot info
            sampledata, ready = magiccdb.get_next(sample_type="cal", asDict=True)
            continue

        # Loop until number of aliquots is reached.
        while sampledata["sample_id_num"] == current_sample_id_num:
            msg_prefix = "%s (Manifold %s, port %s) " % (sampledata["serial_num"], sampledata["manifold"],
                                sampledata["port_num"])
            ShowStatus("%s - run_sample" % msg_prefix)
            flow_check = run_sample(action, syslist, sysgases, referencedata, sampledata, "nl", 
                                    config.storegc, config.transducer_offset)

            # get next aliquot info
            sampledata, ready = magiccdb.get_next(sample_type="nl", asDict=True)  
            if sampledata is None:
                print("sample data returned NONE so break", file=sys.stderr)
                break
    
    # Create non-linearity raw and data files
    for inst in syslist:
        ShowStatus("%s - Updating files for %s" % (msg_prefix, inst))
        update_files(inst, sysgases, "nl", stdset )

    ## update files for system qc
    #inst = "QC"
    #ShowStatus("Updating files for %s" % (inst))
    #update_files(inst, sysgases, "nl", stdset )

    # record timestamp of nl run (use when combining split runs. run combining code prior to this if used)
    timestamp = utils.get_rawfile_name()
    utils.write_last_nl_timestamp(timestamp)
    



##############################################################
# Internal mode for warmup shots (uses the sample run list)
#
##############################################################
def warmup(syslist, sysgases):
    global action
    global referencedata
    global junkdata

    config.storegc = False  # Don't archive chromatograms 

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("warmup")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    ShowStatus("Begin Warmup Mode")

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()

    # set sample type of referencedata dictionary, use when prepping system for next aliquot at end of each cycle
    referencedata["sample_type"] = "warmup"

    # get first sample to run
    sampledata, ready = magiccdb.get_next(sample_type="warmup", asDict=True) 

    # exit cleanly if no samples ready
    if sampledata is None:
        ShowStatus("No warmup samples ready, returning")
        return


    while sampledata is not None:
        junk = False

        #current_port = sampledata["port_num"]
        current_sample_id_num = sampledata["sample_id_num"]

        if sampledata["sample_id"] == config.junk_name: junk=True
        ShowStatus("warmup mode, junk = %s" % junk)

        if junk:
            # Turn Manifold Select and Manifold to correct ports for junk air
            if sampledata["manifold"].upper() != 'D':
                ShowStatus("setting up for junk air analysis")
                action.run("turn_multiposition.act", "ManifoldSelect", "@Manifold%s_port" % sampledata["manifold"])
                # Turn manifold to port tank is connected to
                action.run("turn_multiposition.act", "Manifold%s" % sampledata["manifold"], " %s" % sampledata["port_num"])
        else:
            referencedata["analysis_id"] = sampledata["analysis_id"]

        #run sample -
        if junk:
            flow_check = run_sample(action, syslist, sysgases, None, sampledata, "warmup", 
                                config.storegc, config.transducer_offset)
        else:
            flow_check = run_sample(action, syslist, sysgases, referencedata, None, "warmup", 
                                config.storegc, config.transducer_offset)

        # get next aliquot info
        sampledata, ready = magiccdb.get_next(sample_type="warmup", asDict=True)  
        if sampledata is None:
            print("sample data returned NONE so break", file=sys.stderr)
            break
    


##############################################################
# Internal Mode for Single shot of reference gas
#   Used for continuous Junk / Ref shots after completion of
#   sample run list.
##############################################################
def internal_single_shot(syslist, sysgases, junk=False):
    
    global action
    global referencedata
    global junkdata

    config.storegc = False  # Don't archive chromatograms 
    
    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("int_ref")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    ShowStatus("Begin Internal Single Reference Mode")
    
    if junk:
        # turn ManifoldSelect and Manifold to junk air port
        action.run("turn_multiposition.act", "ManifoldSelect", "Manifold%s_port" % junkdata["manifold"])
        action.run("turn_multiposition.act", "Manfold%s" % junkdata["manifold"],junkdata["port_num"])
        flow_check = run_sample(action, syslist, sysgases, junkdata, None, "REF", 
                            config.storegc, config.transducer_offset)
    else:
        flow_check = run_sample(action, syslist, sysgases, referencedata, None, "REF", 
                            config.storegc, config.transducer_offset)



##############################################################
# Mode 6, Single shot of reference gas
##############################################################
def single_shot(syslist, sysgases):
    
    global action
    global referencedata
    config.storegc = False  # Don't archive chromatograms 
    
    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("ref")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")


    ShowStatus("Begin Single Reference Mode")

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()

    flow_check = run_sample(action, syslist, sysgases, referencedata, None, "NUL", 
                        config.storegc, config.transducer_offset)



##############################################################
# Mode 7, Continuous shot of reference gas
##############################################################
def continuous_shot(syslist, sysgases):

    global action
    global referencedata

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("ref")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    config.storegc = True   # Archive chromatograms 

    ShowStatus("Begin Continuous Reference Mode")

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()
            
    while True:
        
        flow_check = run_sample(action, syslist, sysgases, referencedata, None, "NUL", 
                            config.storegc, config.transducer_offset)




###############################################################
## Mode 9, zero air tank calibration
## 
##  NOT TESTED YET!!!!!!!!!
##
###############################################################
#def zero_air_cal(syslist, processlist):
#
#   global action
#
#   config.isZeroAirCal = True
#
#   config.storegc = True
#
#   logging.info("Begin zero air tank calibration")
#
#   #get actual valve name and port# for reference gas from listed portnum in conf file
#   # use this in case we ever put R0 on the standard manifold to expand the number of
#   # sample manifolds.
#   try:
#       ref_manifold, ref_portnum, ref_next_off = utils.resources[config.ref_name.lower()].split()
#   except:
#       msg = "%s is NOT a valid port number, continue with next tank sample" % (config.ref_name)
#       logging.info(msg)
#       sys.exit()
#
#        # get list of sample tanks to cal
#        sampletanks = getSampleList()
#
#        while len(sampletanks):
#                #check ups for low battery indicator
##                check_ups()
#
#                samplestring = sampletanks[0]
#
#                #(serialnum, pressure, regulator, numaliquots, portnum) = samplestring.rstrip().split()
#                (portnum, serialnum, pressure, regulator, numaliquots, primary_key) = samplestring.rstrip().split()
#                numaliquots = int(numaliquots)
#
#                #get actual valve name and port# from listed portnum in conf file
#                # if not a valid port then continue with next tank sample
#                portname="PORT%s" % portnum
#
#                try:
#                        smp_manifold, smp_portnum, smp_next_off = utils.resources[portname.lower()].split()
#                except:
#                        msg = "%s is NOT a valid port number, continue with next tank sample" % (portname)
#                        logging.info(msg)
#                        # update completed list and get sample list again
#                        sampletanks = getSampleList(samplestring)
#                        continue
#
#                portnum = int(portnum)
#
#                # backup the data files, and save our start time
#        utils.backup_data_files()
#                utils.set_start_time()
#
#                # Write sample tank info to sys.current_sample so we can use it
#                # in results
#                s = "%s %s %s %s %s %s %s\n" % (serialnum, pressure, regulator, numaliquots, smp_manifold, smp_portnum, primary_key)
#                f = open("sys.current_sample", "w")
#                f.write(s)
#                f.close()
#
#
#       #Set up manifold #####################
#       ######################################
#
#       # flush regulator
#       action.run("flush_regulator.act", smp_manifold)
#   
#       #run reference
#       for i in range(config.num_zero_air_cal_refs+1):
#           run_sample(action, syslist, sysgases, "Tank", ref_manifold, ref_portnum, ref_next_off, "REF", config.ref_name)
#
#       #run sample 
#                for loopnum in range(1, numaliquots+1):
#           run_sample(action, syslist, sysgases, "Tank", smp_manifold, smp_portnum, smp_next_off, "SMP", tankid.upper())
#
#       #finish with reference
#       for i in range(config.num_zero_air_cal_refs+1):
#           run_sample(action, syslist, sysgases, "Tank", ref_manifold, ref_portnum, ref_next_off, "REF", config.ref_name)
#
#       #process data
#       for inst in syslist:
#           ShowStatus("Updating files for %s" % (inst))
#           update_files(inst, sysgases, "cals", serialnum=serialnum, pressure=pressure, 
#                   regulator=regulator, manifold=smp_manifold, portnum=smp_portnum)
#
#       # update files for system qc
#       inst = "QC"
#       ShowStatus("Updating files for %s" % (inst))
#       update_files(inst, sysgases, "cals", serialnum=serialnum, pressure=pressure, 
#               regulator=regulator, manifold=smp_manifold, portnum=smp_portnum)



##############################################################
# Mode 5, Test Mode
##############################################################
def testmode(syslist, sysgases):

    global action
    global referencedata

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("test")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")


    ShowStatus("Begin Test Mode")

    # backup the data files
    utils.backup_data_files()

    # Log our start time
    utils.set_start_time()
    
    flow_check = run_sample(action, syslist, sysgases, referencedata, None, "NUL", position, 
                        config.storegc, config.transducer_offset)

    #for n in range(0,1):
    #    for nn in range(0,1):
    #        ShowStatus("Start reference")

    #        flow_check = run_sample(action, syslist, sysgases, referencedata, None, "REF", 
    #                           config.storegc, config.transducer_offset)

    #    for nn in range(0,1):
    #        ShowStatus("Start sample")
    #        sampledata = {
    #            "manifold"    : "C",
    #            "port_num"     : 1,
    #            "serial_num"   : "FB03861",
    #            "sample_type"  : "cal",
    #            "sample_num"   : 1,         
    #            "sample_id"    : "W1",      
    #            "event_num"    : 0,         
    #            "analysis_id"  : None,
    #            "pressure"     : "0",       
    #            "regulator"    : "0",       
    #            }

    #        flow_check = run_sample(action, syslist, sysgases, referencedata, sampledata, "SMP", config.storegc, config.transducer_offset)






##############################################################
# Mode 6, Dry water trap
#           !!!!!!NOT YET
##############################################################
def dry_trap(syslist, sysgases):

    global action
    global referencedata

    # datafile for trap dry QC data
    datafile = "data.trap_dry_qc"
    if os.path.exists(datafile): os.rename(datafile, "tmp/"+datafile)

    # record current sample type for use in panel
    try:
       f = open("sys.internal_mode", "w")
       f.write("DryTrap")
       f.close()
    except:
       ShowStatus("Could not open file %s for writing, continue ..."  % "sys.internal_mode")

    config.storegc = False
    manifold_trap_on = False

    dry_time = datetime.timedelta(hours = 24)
    #dry_time = datetime.timedelta(minutes = 4)  # use 2 minutes for code testing
    manifold_trap_delay = datetime.timedelta(minutes = 120)

    start_dry = datetime.datetime.now()
    s = start_dry.strftime("%Y-%m-%d %H:%M:%S")

    ShowStatus("Begin Dry Trap mode at: %s" % (s))
    action.run("start_drying_trap.act")
    now = datetime.datetime.now()
    #loop until now > (start_dry + dry_time)
    while now < (start_dry + dry_time):
        time.sleep(300)
        #time.sleep(10) # use for testing
        now = datetime.datetime.now()
        action.run("dry_trap_measure_qc.act")
        #@sample_flow,@room_temp,@chiller_temp,@trap_humidity
        (j, flow, rT, cT, H,j, j) = action.output.split()
        dataline = "REF R0 %4d %02d %02d %02d %02d %02d %6.1f %6.1f %6.1f %6.1f\n" % (now.year, now.month, now.day, 
            now.hour, now.minute, now.second, float(flow), float(rT), float(cT), float(H))
        
        try:
           f = open(datafile, "a")
           f.write(dataline)
           f.close()
        except:
           ShowStatus("Could not open file %s for writing, continue ..."  % datafile)
        
        # after 2 hours, start drying the sample manifold traps
        if not manifold_trap_on:
            if now > (start_dry + manifold_trap_delay):
                s = now.strftime("%Y-%m-%d %H:%M:%S")
                ShowStatus("Begin Dry Manifold Traps at: %s" % (s))
                action.run("start_drying_manifold_traps.act")
                manifold_trap_on = True
            

    # end dry gas flow after 8 hours
    action.run("stop_drying_trap.act")






