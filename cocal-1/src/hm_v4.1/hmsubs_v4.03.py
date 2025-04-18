
# vim: tabstop=4 shiftwidth=4 expandtab
"""
Base class for subroutines used by the hm program.
This is meant to be subclassed for each device that
will be used by hm.

Subclass device modules are:
scpi
vurf
valco
hp35900
pp
picarro
lgr
daq
test

"""

from __future__ import print_function

import sys
import time
import logging
import datetime
from collections import defaultdict
import configparser
from math import sqrt
import re

import errornum

class hmsub():
    """ Class of subroutines for the hm program """

    def __init__(self, configfile=None):

        self.last_time = 0
        self.last_data = 0
        self.last_sdev = 0
        self.last_n = 0
        self.run_time = 0

        self.logger = logging.getLogger('hm')

        # All hm actions that are in this class
        # need to be listed here with a virutal name to actual method key->value.
        # For hmsub class, these methods are the ones that don't use
        # an actual physical device or apply to all devices.
        # Methods that do use a device will be listed in the subclass
        self.action_procs = {
            "SendCommand"            : self.send_command,
            "SendMultilineCommand"   : self.send_multiline_command,
            "QueryDevice"            : self.query_device,
            "CheckDevice"            : self.query_device,
            "ScaleValue"             : self.scale_value,
            "PrintData"              : self.print_data,
            "PrintDataGMT"           : self.print_data_gmt,
            "LogData"                : self.log_data,
            "LogDataGMT"             : self.log_data_gmt,
            "ShowStatus"             : self.show_status,
            "LockInterface"          : self.lock_interface,
            "ReadDevice"             : self.read_device,
            "PrintReply"             : self.print_reply,
            "DeviceClear"            : self.device_clear,
            "Noop"                   : self.no_op,
            "StartLog"               : self.start_log,
            "StopLog"                : self.stop_log,
            "LogEntry"               : self.log_entry,
            "MonitorOutput"          : self.monitor_output,
            "MonitorDevice"          : self.monitor_device,
        }

        self.config = None
        if configfile:
            self.config = configparser.ConfigParser()
            s = self.config.read(configfile)
            if len(s) == 0:
                self.config = None


    #------------------------------------------------------------------------
    def call(self, device, action, virtual_devices):
        """ Main method for calling the desired method for the action procedure

        The 'virtual' method name is in action.action.
        We need to convert that to an actual method name with
        the self.action_procs dict, and call that method
        with the normal device and option arguments.
        """

#        print("inside hmsubs call")
#        print(action)
#        print(virtual_devices)
        if action.device in virtual_devices:
            name = action.device
            info = virtual_devices[action.device]['option']
            self.action_procs[action.action](device, action.option, name, info)
        else:
            self.action_procs[action.action](device, action.option)

    #-------------------------------------------------------------------------
    def _error_exit(self, msg):
        """ Log an error message and exit the program. """

        self.logger.error(msg)
        sys.exit(errornum.HMSUBERROR)

    #-------------------------------------------------------------------------
    def _meanstdv(self, x):
        """ Calculate mean and standard deviation of data x[]:
        mean = { sum_i x_i  over n}
        std = sqrt( sum_i (x_i - mean)^2  over n-1)
        """

        n, mean, std = len(x), 0, 0

        if n == 1:
            mean = x[0]

        elif n > 1:

            for a in x:
                mean = mean + a
            mean = mean / n

            for a in x:
                std = std + (a - mean)**2

            std = sqrt(std / (n-1))

        return mean, std, n

    #-------------------------------------------------------------------------
    def _write_gc(self, filename, tm, port, samplerate, np, data):
        """ write gc data to file in text format for integrator software """

        try:
            fp = open(filename, "w")
        except IOError as err:
            self.logger.error("StopRun failed.  Cannot write to file %s. %s", filename, err)
            return

        print("%d %d %d %d %d %d %d" % (tm.year, tm.month, tm.day, tm.hour, tm.minute, tm.second, 0), file=fp)
        print("%s" % port, file=fp)
        print("%s" % samplerate, file=fp)
        print(" 1 %d" % np, file=fp)
        for val in data:
            print(val, file=fp)
        fp.close()


    #-------------------------------------------------------------------------
    def _write_result(self, result, filename=None, filemode="append"):
        """ Write a result string to either file (if filename is not None)
        or to stdout.  If to a file, then either replace or append to the
        file based on value in filemode.
        """

        if filename:
            mode = "w"
            if filemode == "append": mode = "a"
            output_file = open(filename, mode)
            print(result, file=output_file)
            output_file.close()
        else:
            print(result, file=sys.stdout)
            sys.stdout.flush()

    #-------------------------------------------------------------------------
    def _getStartTime(self, prev_time, timeavg, reg_time_interval):
        """ return a time stamp set to either a given time (prev_time)
        or a second of the minute if reg_time_interval is true.
        """

        if reg_time_interval and timeavg:
            start_time = timeavg * (int(prev_time) // timeavg)
        else:
            start_time = prev_time

        return start_time

    #-------------------------------------------------------------------------
    def scale_value(self, device, option):
        """ Do a linear scaling of the last_data value .
        The scaling coefficients are in the 'option' variable
        Action line syntax:
           0 ScaleValue None a b
        where y = a+b*x
        """

        ld = self.last_data
        (a, b) = option.split()
        a = float(a)
        b = float(b)
        self.logger.debug("ScaleValue: y = %f + %f * %f", a, b, self.last_data)

        self.last_data = a + b*self.last_data

        self.logger.info("ScaleValue a,b = %s, unscaled value = %f, scaled value = %f", option, ld, self.last_data)

    #-------------------------------------------------------------------------
    def show_status(self, device, option):
        """ Write a one line string to a file.
        The file is always overwritten.
        Action line syntax:
           0 ShowStatus filename string
        """

        filename = device
        try:
            f = open(filename, "w")
            f.write(option + "\n")
            f.close()
            self.logger.info("ShowStatus %s %s", filename, option)

        except IOError as e:
            self.logger.error("ShowStatus: %s", e)


    #-------------------------------------------------------------------------
    def log_data_gmt(self, device, option):
        """ Write the value stored in the 'last_data' variable to a file.
        Data is either appended to or replaces the file, depending on
        the value of option.  Default is to append.
        Include the time stamp when data was taken.
        The filename is the first work in the 'option' variable
        If filename is 'None', then print to stdout instead of to file
        Action line syntax:
           0 LogData device filename Append | Replace
        """

        filemode = "append"
        a = option.split()
        if len(a) == 1:
            filename = a[0]
        elif len(a) == 2:
            filename = a[0]
            filemode = a[1].lower()
        else:
            self._error_exit("LogDataGMT Error for %s. Incorrect option string '%s'." % (device.name, option))

        mode = "w" if filemode == 'replace' else "a"

        try:
            fp = open(filename, mode)
        except IOError as err:
            self.logger.error("LogDataGMT: %s", err)
            return

        if self.last_time != 0:
            dt = datetime.datetime.fromtimestamp(self.last_time)
            s = "%s %s %s %d" % (dt.strftime('%Y %m %d %H %M %S'), self.last_data, self.last_sdev, self.last_n)
            fp.write(s + '\n')
            fp.close()
            self.logger.info("LogDataGMT %s %s %s", filename, filemode, s)
        else:
            self.logger.error("No readings for LogData.")


    #-------------------------------------------------------------------------
    def log_data(self, device, option):
        """ Write the value stored in the 'last_data' variable to a file.
        Data is either appended to or replaces the file, depending on
        the value of option.  Default is to append.
        Include the time stamp when data was taken.
        The filename is the first word in the 'option' variable
        Action line syntax:
           0 LogData device filename Append | Replace
        """

        filemode = "append"
        a = option.split()
        if len(a) == 1:
            filename = a[0]
        elif len(a) == 2:
            filename = a[0]
            filemode = a[1].lower()
        else:
            self._error_exit("LogDataGMT Error for %s. Incorrect option string '%s'." % (device.name, option))

        mode = "w" if filemode == 'replace' else "a"

        try:
            f = open(filename, mode)
        except IOError as e:
            self.logger.error("LogData: %s", e)
            return

        if self.last_time != 0:
            s = "%ld %s %s %d" % (self.last_time, self.last_data, self.last_sdev, self.last_n)
            f.write(s + '\n')
            f.close()
            self.logger.info("LogData %s %s %s", filename, option, s)
        else:
            self.last_time = -99.99
            s = "%ld %s %s %d" % (self.last_time, self.last_data, self.last_sdev, self.last_n)
            f.write(s + '\n')
            f.close()
            self.logger.info("LogData %s %s %s", filename, option, s)
    #    logger.error("No readings for LogData.")

    #-------------------------------------------------------------------------
    def print_data(self, device, option):
        """ Print the 'last_data' variable value to stdout, with its
        corresponding time, standard deviation and n.
        """

        if self.last_time == 0: self.last_time = -99.99

        s = "%ld %s %s %d" % (self.last_time, self.last_data, self.last_sdev, self.last_n)
        print(s)
        self.logger.info("PrintData %s", s)

    #-------------------------------------------------------------------------
    def print_data_gmt(self, device, option):
        """ Print the 'last_data' variable value to stdout, with its
        corresponding calendar date and time, standard deviation and n.
        """

        dt = datetime.datetime.fromtimestamp(self.last_time)
        s = "%d %2d %2d %2d %2d %2d %s %s %d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second, self.last_data, self.last_sdev, self.last_n)
        print(s)
        self.logger.info("PrintDataGMT %s", s)


    #-------------------------------------------------------------------------
    def lock_interface(self, device, option):
        """ Lock the interface to a device for exclusive use of the device.

        This allows multiple actions to be run on a device without any
        other process interfering.

        To lock:
            0 LockInterface devicename Lock
        To unlock
            0 LockInterface devicename Unlock

        example usage:
            0 LockInterface hp34970 LOCK
            0 ShowStatus sys.status Measuring channel 102
            0 ReadValue hp34970 @channel_102
            0 ScaleValue hp34970 @scale_102
            0 LogDataGMT /data/qc/2012/ndir_temp/2012-11-07 Append
            0 ShowStatus sys.status Measuring channel 103
            0 ReadValue hp34970 @channel_103
            0 ScaleValue hp34970 @scale_103
            0 LogDataGMT /data/qc/2012/sample_flow/2012-11-07 Append
            0 LockInterface hp34970 UNLOCK
        """

        if option.lower() == "lock" and device.locked is False:
            device.lock()
            device.locked = True

        if option.lower() == "unlock" and device.locked is True:
            device.unlock()
            device.locked = False

        self.logger.debug("LockInterface %s %s", device.name, option)


    #-------------------------------------------------------------------------
    def print_reply(self, device, option):
        """ Query a device, get an answer, then
        print the answer to stdout.
        Action line syntax:
           0 PrintReply device string

        where string is the query string to send to the device.
        """

        command = option
        command = command.replace("\s", " ")
        answer = self.query_device(device, command)
        print(answer)


    #-------------------------------------------------------------------------
    def no_op(self, device, option):
        """ No operation, i.e. do nothing.  Useful for inserting delays
        at the end of actions before quitting.

        Action line syntax:
             0 Noop None None
        """

        self.logger.info("No-op %s %s", device, option)


    #-------------------------------------------------------------------------
    def start_log(self, device, option):
        """ Turn on logger of individual readings in several of the routines """

        self.logger.disable(logging.DEBUG)

    #-------------------------------------------------------------------------
    def stop_log(self, device, option):
        """ Turn off logger of individual readings in several of the routines """

        self.logger.disable()

    #-------------------------------------------------------------------------
    def log_entry(self, device, option):
        """ Add an entry to the log file """

        self.logger.info(option)

    #------------------------------------------------------------------------
    def send_command(self, device, option):
        """ Send a string to a device.
            Action line syntax:
            0 SendCommand device string
        """

        command = option
        command = command.replace("\s", " ")
        n = device.send(command)
        if n != 0:
            self._error_exit("SendCommand failed on device %s: %s" % (device.name, command))

        self.logger.info("SendCommand %s %s", device.name, option)

    #------------------------------------------------------------------------
    def send_multiline_command(self, device, option):
        """ Send a set of strings to a device.
            Action line syntax:
            0 SendCommand device string string string
        """
        commands = []

        try:
            commands = option.split()
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("send_multiline_command: Can't parse option string '%s'." % (option))

        n = device.send_lines(commands)
        if n != 0:
            self._error_exit("SendMultilineCommand failed on device %s: %s" % (device.name, commands))

        self.logger.info("SendMultilineCommand %s %s", device.name, option)

    #------------------------------------------------------------------------
    def query_device(self, device, option):
        """ Send a command string to a device, and read back the
        one line answer.
        Action line syntax:
           0 QueryDevice device string

        where string is the query string to send to the device.
        """

        self.logger.info("QueryDevice %s Query %s", device.name, option)
        answer = device.send_read(option)
        if not answer:
            self._error_exit("QueryDevice failed on device %s." % device.name)

        self.logger.info("QueryDevice %s Response %s", device.name, answer)

        return answer

    #------------------------------------------------------------------------
    def read_device(self, device, option=None):
        """ Read one line from a device without prompting.
        """

        answer = device.read()
#        self.logger.debug("ReadDevice: %s", answer)

        return answer

    #------------------------------------------------------------------------
    def device_clear(self, device, option):
        """ Send the command to clear a device. """

        s = "%c" % 3
        s = "\x03"
    #    s = "*RST"
        device.send(s)

    #------------------------------------------------------------------------
    def _get_answer(self, device, command):
        """ Get one line response from device,
        using a prompt if command is not None.
        """

        if command:
            answer = self.query_device(device, command)
        else:
            answer = self.read_device(device)

        return answer

    #------------------------------------------------------------------------
    def monitor_output(self, device, option):
        """
        Read output from device, either with a prompt or from
        a nonpolled instrument without a prompt.

        Reads the output string from a device and writes to either stdout
        or a file.

        'option' contains the command to send to device if it needs a prompt before
        sending output.  Use 'None' for a device that outputs data
        without prompting.

        Does not do any processing of the output string, such as averaging,
        parsing the string etc.  To do those operations, use the
        monitor_device routine.

        Filename and filemode are optional.  If filename not set, or set to 'none',
        then print to stdout

        Action line syntax:
             0 MonitorOutput device None [Filename] [Append|Replace]

        """

        # or do a call to monitor_polled with
        # option 'command 0 1 0 filename mode' ?

        fields = option.split()

        command = None
        if fields[0].lower() != 'none':
            command = fields[0]
            command = command.replace("\s", " ")

        filename = None
        if len(fields) >= 2 and fields[1].lower() != 'none':
            filename = fields[1]

        mode = "a"
        if len(fields) >= 3:
            filemode = fields[2].lower()
            mode = "w" if filemode == 'replace' else "a"

        if filename:
            try:
                fp = open(filename, mode)
            except IOError as err:
                self.logger.error("MonitorOutput: %s", err)
                return
        else:
            fp = sys.stdout

        # Time is when sampling starts
        self.logger.info("MonitorOutput start %s %s", device.name, option)
        print("MonitorOutput start %s %s" % (device.name, option), file=sys.stderr)
        # take a reading

        # drop first reading without encoding if command not needed
        # sometimes might get partial byte string with non-ascii characters
        device.clear()
        if command is None:
            device.read_raw()
#            device.read()
        else:
            answer = self._get_answer(device, command)

        while True:

            answer = self._get_answer(device, command)
            self.logger.debug("MonitorOutput: %s", answer)
            print("MonitorOutput: %s" % answer, file=sys.stderr)
            
            if len(answer) == 0:
                break
            print(answer.strip(), file=fp)
            fp.flush()
            if command:
                time.sleep(0.1)




    #########################################################################
    def _getMonitorOptions(self, option):
        """ Get the options for monitor_polled_data.
            Option string can have up to 6 fields:
            'command timeavg forever reg_time filename replace|append'
            All fields except 'command' are optional.
        """

        self.logger.debug("GetMonitorOptions, option is %s", option)

        command = None
        timeavg = 0
        forever = 0
        reg_time_interval = 0
        filename = None
        filemode = "replace"

        try:
            vals = option.split()
            command = vals[0]
            if command.lower() == "none":
                command = None
            if len(vals) > 1:
                timeavg = int(vals[1])
            if len(vals) > 2:
                forever = int(vals[2])
            if len(vals) > 3:
                reg_time_interval = int(vals[3])
            if len(vals) > 4:
                if vals[4].lower() != 'none': filename = vals[4]
            if len(vals) > 5:
                mode = vals[5].lower()
                if mode in ["append", "replace", "none"]:
                    if mode != 'none': filemode = mode
                else:
                    self._error_exit("_getMonitorOptions: Bad file mode option %s. Should be either 'append', 'replace', or 'none'" % vals[5])

        except ValueError as err:
            self.logger.error(err)
            self._error_exit("_getMonitorOptions: Error. Incorrect option string '%s'." % (option))


        # test if filename is writeable.
        if filename:
            if filemode == "replace":
                mode = "w"
            else:
                mode = "a"
            try:
                output_file = open(filename, mode)
            except IOError as e:
                self._error_exit("_getMonitorOptions: Could not open file %s. %s" % (filename, e))
            output_file.close()


        return (command, timeavg, forever, reg_time_interval, filename, filemode)

    #########################################################################
    def _check_save_data(self):
        """ check if we want to save device output strings to a file
        from the monitor_device action.
        This is set in a device configuration file.
        """

        fp = None
        save_data = False
        if self.config:
            if 'monitor_device_save_data' in self.config['DEFAULT']:
                save_data = self.config['DEFAULT']['monitor_device_save_data']
                if save_data:
                    save_file = self.config['DEFAULT']['monitor_device_save_file']
                    self.logger.info("MonitorDevice save file is %s", save_file)
                    try:
                        fp = open(save_file, "a")
                    except:
                        self.logger.error("Cannot open monitor device save file %s" % save_file)
                        save_data = False

        return save_data, fp

    #########################################################################
    def _process_answer(self, answer):
        """ Take a reading from the device (with an optional prompt if 'command' is set),
        strip leading and trailing letters from the string, then split up the string
        and convert each field to a float value.  Return a list of the float values.
        """

    #!!!!!!!!!!!!!!!!!!!
    # remove after testing
#            if device.name == "lgr_ch4":
#                answer = lgr_test("CH4")
#                logger.debug("ReadDevice: %s", answer)
#            else:
#                answer = lgr_test("N2O")


        # assume empty string is from timeout, so device is not sending data.
        # return a None in this case.
        if not answer:
            self.logger.error("No data returned.")
            return None

        # The isotope LGR now has "disabled" in the last field of the output string
        # First remove any letters at the end of the string, then remove any
        # trailing field seperators (space, comma, etc), Finally split on column
        # separators and turn into float numbers.
        ans = re.sub('[a-zA-Z]+$', ' ', answer)

        #Aerodyne puts a letter at the begining of the string for some reason, remove any leading letters
        ans = re.sub(r'^[a-zA-Z]+', ' ', ans)
        ans = re.sub(r'^[>]+', ' ', ans)  # for daq answer, remove leading '>'
        ans = re.sub(r'[:/,;\s]+$', '', ans)

        try:
            values = [float(x) for x in re.split(r'[:/,;\s]+', ans.strip())]
        except:
            self.logger.error("*** Split in MonitorDevice FAILED on %s", answer)
            print("ERROR: *** Split in MonitorDevice FAILED on %s" % answer, file=sys.stderr)
            return None

        return values


    #########################################################################
    def monitor_device(self, device, option):
        """
        Read data from either a polled or non-polled instrument that outputs single or multiple
        data streams as one digital output string.
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
            'command timeavg forever reg_time filename replace|append'

        Action line syntax:
            0 MonitorDevice device command time_avg? forever? reg_time_interval? filename? filemode?

        where,
            command - string to prompt device for output.  Use 'None' for non-polled device.

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

        0  MonitorDevice device  None 10 1

            will read device and average the readings for 10 seconds
            before printing out, and it will loop forever.

        0  MonitorDevice device  None 10

            will read device and average the readings for 10 seconds
            before printing out, and it will NOT loop forever so will exit
            after the first 10 sec average is printed.

        0  MonitorDevice device  None 0 1

            will read device but will NOT average, instead it will print out
            all of the data points and it will continue forever.

        0  MonitorDevice device Read? 10  1  1

            will read device and average the readings for 10 sec, loop forever,
            and keep a regular pattern to the timestamps (ie every even 10 seconds of the minute).
            Prompts the device with the 'Read?' string.

        possible subclass overrides

            self._process_answer()
            self._getResultString()

        """

        self.logger.info("MonitorDevice start %s %s", device.name, option)

        # split up option string into separeate variables
        (command, timeavg, forever, reg_time_interval, filename, filemode) = self._getMonitorOptions(option)
        self.logger.info("MonitorDevice timeavg is %s, forever is %s, reg_time_interval is %s", timeavg, forever, reg_time_interval)

        if command is not None:
            command = command.replace("\s", " ")

        if filename:
            mode = "a" if filemode == "append" else "w"
            output_file = open(filename, mode)
        else:
            output_file = sys.stdout

        # check if we want to save the output strings to file.
        # this is for every string read from device.  filename and filemode are for averaged results
        save_data, fp = self._check_save_data()
        self.logger.info("MonitorDevice save_data is %s", save_data)

        #clear buffer
        device.clear()
        # take a reading and throw it away, it might be just a partial string
        self.logger.debug("MonitorDevice taking first reading. command is %s", command)
        if command is None:
            device.read_raw()
        else:
            answer = self._get_answer(device, command)
        self.logger.debug("MonitorDevice: First reading discarded")

        # If set reg_time_interval then correct start_time so that the time intervals will
        # fall on a repeating "second past the minute", ie for 10 second averages the data points
        # will be at 0, 10, 20, 30 etc seconds of each minute.
        prev_time = time.time()
        start_time = self._getStartTime(prev_time, timeavg, reg_time_interval)

        # data will hold each reply from device
        data = []
        while True:
            # Get a single line of data from device
            answer = self._get_answer(device, command)
            self.logger.debug("MonitorDevice: %s", answer)
            if save_data:
                fp.write(answer)
                fp.flush()

            if len(answer) == 0:
                break

            data.append(answer)
            prev_time = time.time()

            # if we've gone past the time average time, calculate average and write output
            if prev_time > start_time + timeavg:
                result = self._getResultString(timeavg, prev_time, start_time, data)
                self.logger.debug("MonitorDevice result: %s", result)

                # write result to file or stdout
#                self._write_result(result, filename, filemode)
#                if output_file:
#                    output_file.write(result)
#                else:
#                    print(result)
                print(result, file=output_file)
                output_file.flush()

                start_time = self._getStartTime(prev_time, timeavg, reg_time_interval)

                if not forever:
                    break    # break out of while loop

                data = []

            # wait a bit before asking for another line of data for polled devices.
            if command is not None:
                time.sleep(1)

        fp.close()
        self.logger.info("MonitorDevice stop %s %s", device.name, option)



##########################################################################3
    def _getResultString(self, timeavg, prev_time, start_time, data):
        """ create a result string with the averages of each column 
        from the saved device answer strings
        """

        if timeavg == 0:
            dt = datetime.datetime.fromtimestamp(prev_time)
        else:
            dt = datetime.datetime.fromtimestamp(start_time)
        result = "%4d %2d %2d %2d %2d %2d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)
#        result = "%s" % dt

        v = defaultdict(list)
        for answer in data:
            # process the answer.  could be device dependent
            # split into list of values
            values = self._process_answer(answer)
            if values is None:
                continue

            # put each column value into the v lists
            for i, val in enumerate(values):
                v[i].append(val)

        # for each column list, get mean, stdv, add to result string
        for n in v:
            vals = v[n]
            avg, std, num = self._meanstdv(vals)
            result += " %f %f %d" % (avg, std, num)

        return result

#########################################################################
    def no_op(self, device, option):
        """ No operation, i.e. do nothing.  Useful for inserting delays
        at the end of actions before quitting.

        Action line syntax:
             0 Noop None None
        """

        self.logger.info("No-op %s %s", device.name, option)











