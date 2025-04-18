# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for the Aerodyne analyzer
"""

import sys
import os
import configparser
import time

import hmsubs

class aerodyne(hmsubs.hmsub):
    """ subclass for the Aerodyne analyzer """

    def __init__(self, configfile=None):
        super().__init__(configfile=configfile)

        self.my_procs = {
            "MonitorDeviceFileTransfer" : self.monitor_device_file_transfer,
        }
        self.action_procs.update(self.my_procs)

    #------------------------------------------------------------------------


    #########################################################################
    def monitor_device_file_transfer(self, device, option):
        """
        Read data from an instrument using file exchange data transfer

        It skips any leading character strings in the instrument output.
        Sampling rate is set by the instrument for non-polled devices,
        hard coded here to 1 second for polled devices.

        Can either loop forever OR take a single reading (or single average reading).
        Print each reading to stdout OR an average from a specified
        time period to stdout.

        Be warned that this routine does NOT return to the main
        loop in hm when looping forever.  Only way to stop hm is by
        killing the process.

        Option string can have up to 6 fields. Only the first is required:
            'source_datafile timeavg forever reg_time filename replace|append'

        Action line syntax:
            0 MonitorDeviceFileTransfer device command time_avg? forever? reg_time_interval? filename? filemode?

        where,
            command - command to send if needed 

            time_avg - length of time in seconds to average readings before
                 printing out the values. A time_avg value of 0 will cause
                 hm to print out every reading.

            forever - specifies wheather to loop forever (1) or to stop after one
                time_avg cycle (0). Default is 0.

            reg_time_interval? - 0 or 1 specifies if the user wants the timestamps to be
                on a regular repeating pattern.  For example 10 second averages would
                be recorded with timestamps of 10, 20, 30, etc seconds after the minute.
                Default is 0.

            filename - prints data lines to file "filename". Leave empty or use 'None' to default to stdout

            filemode - one of 'append' or 'replace' or 'none'.  If 'append' add new lines to filename,
                otherwise write over filename.  Default is 'replace'. If 'none' set with filename,
                defaults to 'replace'


        For example,

        0  MonitorDeviceFileTransfer device  None 10 1

            will read device and average the readings for 10 seconds
            before printing out, and it will loop forever.

        0  MonitorDeviceFileTransfer device  None 10

            will read device and average the readings for 10 seconds
            before printing out, and it will NOT loop forever so will exit
            after the first 10 sec average is printed.

        0  MonitorDeviceFileTransfer device  None 0 1

            will read device but will NOT average, instead it will print out
            all of the data points and it will continue forever.

        0  MonitorDeviceFileTransfer device Read? 10  1  1

            will read device and average the readings for 10 sec, loop forever,
            and keep a regular pattern to the timestamps (ie every even 10 seconds of the minute).
            Prompts the device with the 'Read?' string.

        possible subclass overrides

            self._process_answer()
            self._getResultString()

        """

        self.logger.info("MonitorDeviceFileTransfer start %s %s", device.name, option)

        if self.config:
            source_file = self.config['DEFAULT']['monitor_device_source_file']
            read_file = self.config['DEFAULT']['monitor_device_read_file']
            
        else:
            self.logger.error("data transfer by file exchange requires source and read files defined in instrument ini file")
            sys.exit()

        # split up option string into separeate variables
        (command, timeavg, forever, reg_time_interval, filename, filemode) = self._getMonitorOptions(option)
        self.logger.info("MonitorDeviceFileTransfer timeavg is %s, forever is %s, reg_time_interval is %s", timeavg, forever, reg_time_interval)

        if filename:
            mode = "a" if filemode == "append" else "w"
            output_file = open(filename, mode)
        else:
            output_file = sys.stdout

        # check if we want to save the output strings to file.
        # this is for every string read from device.  filename and filemode are for averaged results
        save_data, fp = self._check_save_data()
        self.logger.info("MonitorDeviceFileTransfer save_data is %s", save_data)
        
        ######################################
        #clear transient file 
        self.logger.info("MonitorDeviceFileTransfer, clearing transient source file")
        mv_check = self._move_transient_file(source_file, read_file)
        if mv_check:
            self.logger.info("MonitorDeviceFileTransfer, clearing source file successful (mv_check: %s)", mv_check)
        else:
            self.logger.info("MonitorDeviceFileTransfer, clearing source file NOT successful (mv_check: %s)", mv_check)
            # how to handle this???


        # If set reg_time_interval then correct start_time so that the time intervals will
        # fall on a repeating "second past the minute", ie for 10 second averages the data points
        # will be at 0, 10, 20, 30 etc seconds of each minute.
        prev_time = time.time()
        start_time = self._getStartTime(prev_time, timeavg, reg_time_interval)

        # data will hold each reply from device
        data = []
        while True:
            prev_time = time.time()

            # if we've gone past the time average time, get data file, calculate average and write output
            if prev_time > start_time + timeavg:
                #move source file to read file
                self.logger.info("MonitorDeviceFileTransfer, moving source file")
                mv_check = self._move_transient_file(source_file, read_file)
                if mv_check:
                    self.logger.info("MonitorDeviceFileTransfer, move source file successful (mv_check: %s)", mv_check)
                else:
                    self.logger.info("MonitorDeviceFileTransfer, move source file NOT successful (mv_check: %s)", mv_check)
                    # how to handle this???

                #get data from read_file
                fp_rf = open(read_file, 'r')
                data = fp_rf.readlines()
                fp_rf.close()

                #if save_data, write lines to high freq file
                if int(save_data) > 0:
                    for line in data:
                        fp.write(line)
                        fp.flush()

                #calculate averages
                result = self._getResultString(timeavg, prev_time, start_time, data)
                self.logger.info("MonitorDeviceFileTransfer result: %s", result)

                # write result to file or stdout
                print(result, file=output_file)
                output_file.flush()

                start_time = self._getStartTime(prev_time, timeavg, reg_time_interval)

                if not forever:
                    break    # break out of while loop

                data = []

            # wait a bit before asking for another line of data for polled devices.
            if command is not None:
                time.sleep(0.1)

        self.logger.info("MonitorDeviceFileTransfer stop %s %s", device.name, option)


    
    #------------------------------------------------------------------------
    def _move_transient_file(self,sfn,rfn):
        """ move transient source file to read file
            Need to loop to make sure conflicts with AR write are ok
        """
        if os.path.isfile(rfn): os.remove(rfn)
        status = 0
        cnt = 0
        while cnt <= 25:
            cnt += 1
            self.logger.info("moving source file (%s) to read file (%s), cnt=%s", sfn, rfn, cnt) 
            if os.path.isfile(sfn): 
                try:
                    os.rename(sfn,rfn)
                except:
                    pass
            if os.path.isfile(rfn): 
                status = 1
                break
            time.sleep(0.1)
        return status

