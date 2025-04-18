# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsub subclass for devices that use the scpi protocol
"""

import sys
import time
import datetime
import configparser

import hmsubs

class scpi(hmsubs.hmsub):
    """ subclass for devices that adhere to scpi """

    def __init__(self, configfile=None):
        super(scpi, self).__init__()

        self.my_procs = {
            "OpenRelay"              : self.open_relay,
            "CloseRelay"             : self.close_relay,
            "ReadValue"              : self.read_value,
            "ReadNumber"             : self.read_number,
            "ReadData"               : self.read_number,
            "ReadChannel"            : self.read_number,
            "ConfigChannel"          : self.config_channel,
            "MeasureChannel"         : self.measure_channel,
            "ScaleChannel"           : self.scale_channel,
            "DeviceClear"            : self.device_clear,
            "SampleData"             : self.sample_data,
            "StartScan"              : self.start_scan,
            "StopScan"               : self.stop_scan,
            "ScanData"               : self.scan_data,
            "SingleScan"             : self.single_scan,
            "SwitchValve"            : self.switch_valve,
        }
        self.action_procs.update(self.my_procs)

        # Currently not used for anything (Mar 5, 2024)
        self.config = None
        if configfile:
            self.config = configparser.ConfigParser()
            s = self.config.read(configfile)
            if len(s) == 0:
                self.config = None


    #------------------------------------------------------------------------
    def open_relay(self, device, option):
        """ Open a relay on a switch device.
            Action line syntax:
                 0 OpenRelay device 207 [lock]

                 [lock|unlock] optional - use internal lock file on device. 
                    Default is True, set to 'unlock' to use explicit external 
                    calls to lock file.
        """

        lock=True
        options = option.split()

        val = int(options[0])
        card = val/100
        relay = val % 100

        if len(options) > 1: 
            if options[1].lower() == 'unlock'
                lock=False


        command = "ROUTE:OPEN (@%d%02d)" % (card, relay)
        self.logger.debug("OpenRelay command = %s", command)

        if lock: self.lock_interface(device, "LOCK")
        n = device.send(command)
        if lock: self.lock_interface(device, "UNLOCK")

        if n != 0:
            self._error_exit("OpenRelay failed on device %s: %s" % (device.name, command))
        else:
            self.logger.info("OpenRelay %s %s", device.name, option)

        return 0

    #------------------------------------------------------------------------
    def close_relay(self, device, option):
        """ Close a relay on a switch device.
            Action line syntax:
                 0 CloseRelay device 207 [lock]

                 [lock|unlock] optional - uses internal lock file on device. 
                    Default is True, set to 'unlock' to use explicit external 
                    calls to lock file.
        """
        lock=True
        options = option.split()

        val = int(options[0])
        card = val/100
        relay = val % 100
        if len(options) > 1:
            if options[1].lower() == 'unlock'
                lock = False

        command = "ROUTE:CLOSE (@%d%02d)" % (card, relay)
        self.logger.debug("CloseRelay: command = %s", command)
        
        if lock: self.lock_interface(device, "LOCK")
        n = device.send(command)
        if lock: self.lock_interface(device, "UNLOCK")

        if n != 0:
            self._error_exit("CloseRelay failed on device %s: %s" % (device.name, command))
        else:
            self.logger.info("CloseRelay %s %s", device.name, option)

        return 0

    #------------------------------------------------------------------------
    def check_close_relay(self, device, option):
        """ Check to see if a relay on a switch
            on HP34970A is closed.
            Returns 1 if the channel is closed
            Returns 0 if the channel is open

            Action line syntax:
                 0 CheckCloseRelay device 207
        """

        val = int(option)
        card = val/100
        relay = val % 100

        command = "ROUTE:CLOSE? (@%d%02d)" % (card, relay)

        self.logger.debug("CheckCloseRelay: command = %s", command)

        answer = device.send_read(command)
        if not answer:
            self.logger.error("CheckCloseRelay failed on device %s.", device.name)

        self.logger.debug("CheckCloseRelay answer = %s", answer)

        return answer


    #------------------------------------------------------------------------
    def read_value(self, device, option):
        """ Configure a channel and then read a value from it.
        This is the same as a ConfigChannel followed by a ReadNumber.

        Put device locks in hm code.  Do not use external device locks with ReadValue
        """

        self.lock_interface(device, "LOCK")
        self.config_channel(device, option)
        val = self.read_number(device, option)
        self.lock_interface(device, "UNLOCK")

        return val


    #------------------------------------------------------------------------
    def read_number(self, device, option):
        """ Read a single floating point value back from a device

            Has a couple alias names, ReadData, ReadChannel
            Action line syntax:
               0 ReadData device None|channelnum
               0 ReadChannel device None|channelnum
               0 ReadNumber device 101

            Assumes device is already configured for the desired data type.
        """

        if option.lower() == "none":
            command = "READ?"
            self.logger.debug("ReadNumber command = %s", command)
            self.logger.info("ReadNumber command = %s", command)
            answer = device.send_read(command)
        else:
            channel = option.split()[0]
            comlist = [
                "ROUTE:SCAN (@%s)" % (channel),
                "READ?",
            ]
            self.logger.debug("ReadNumber command = %s", ",".join(comlist))
            self.logger.info("ReadNumber command = %s", ",".join(comlist))
            device.send_lines(comlist)
            answer = device.read()


        if not answer:
            self.logger.error("ReadNumber failed on device %s.", device.name)

        self.logger.debug("ReadNumber answer = %s", answer)

        try:
            val = float(answer)
        except ValueError as err:
            self.logger.error("ReadNumber: Cannot scan value from string '%s'.", answer)
            self.logger.error(err)
            return 0

        self.last_time = time.time()
        self.last_data = val
        self.last_sdev = 0.0
        self.last_n = 1

        self.logger.debug("ReadNumber %s %s %f", device.name, option, val)

        return val

    #------------------------------------------------------------------------
    def config_channel(self, device, option):
        """ Configure a channel on a multiplexor.
            Action line syntax:
            0 ConfigChannel device location type

            where location is the card/channel locations (vxi only?),
            and type is the measurement type (dcvolt, resistance, current etc.).
            The location and type syntax are device dependent.
            Type must be one of DCVOLT, ACVOLT, RES, FRES, TC, THER THERREF, RTD, FRTD, DCCURR
        """


        tc_type = ""
        a = option.split()
        loc = int(a[0])
        measurement_type = a[1]
        if len(a) == 3:
            tc_type = a[2]
        if measurement_type == "DCVOLT":
            if tc_type:
                command = "CONF:VOLT:DC AUTO,%s, (@%d)" % (tc_type, loc)
            else:
                command = "CONF:VOLT:DC AUTO,MAX, (@%d)" % loc
        elif measurement_type == "ACVOLT":
            command = "CONF:VOLT:AC (@%d)" % loc
        elif measurement_type == "RES":
            command = "CONF:RES (@%d)" % loc
        elif measurement_type == "FRES":
            command = "CONF:FRES (@%d)" % loc
        elif measurement_type == "TC":
            command = "CONF:TEMP TC,%s,1,MAX, (@%d)" % (tc_type, loc)
        elif measurement_type == "THER":
            command = "CONF:TEMP THER,%s,1,MAX, (@%d)" % (tc_type, loc)
        elif measurement_type == "THERREF":
            command = "CONF:TEMP THER,5000,1,MAX, (@%d)" % loc
        elif measurement_type == "RTD":
            command = "CONF:TEMP RTD,85,(@%d)" % loc
        elif measurement_type == "FRTD":
            command = "CONF:TEMP FRTD,85,(@%d)" % loc
        elif measurement_type == "DCCURR":
            command = "CONF:CURR:DC (@%d)" % loc
        else:
            self.logger.error("ConfigChannel failed on device %s type %s. No such measurement type.", device.name, measurement_type)
            return

        self.logger.debug("ConfigChannel command = %s ", command)

        n = device.send(command)
        if n != 0:
            self._error_exit("ConfigChannel failed on device %s: %s" % (device.name, command))

        self.logger.info("ConfigChannel %s %s", device.name, option)

    #------------------------------------------------------------------------
    def measure_channel(self, device, option):
        """ Measure a channel on a multiplexor.
            Action line syntax:
            0 MeasureChannel device location type

            where location is the card/channel locations (vxi only?),
            and type is the measurement type (dcvolt, resistance, current etc.).
            The location and type syntax are device dependent.
            Type must be one of DCVOLT, ACVOLT, RES, FRES, TC, THER THERREF, RTD, FRTD, DCCURR

            Equivalent to a ConfigChannel followed by ReadNumber
        """

        tc_type = None
        a = option.split()
        self.logger.debug("MeasureChannel option = %s", option)
        loc = int(a[0])
        measurement_type = a[1]
        if len(a) == 3:
            tc_type = a[2]
        if measurement_type == "DCVOLT":
            if tc_type:
                command = "MEAS:VOLT:DC? AUTO,%s, (@%d)" % (tc_type, loc)
            else:
                command = "MEAS:VOLT:DC? (@%d)" % loc
        elif measurement_type == "ACVOLT":
            command = "MEAS:VOLT:AC? (@%d)" % loc
        elif measurement_type == "RES":
            command = "MEAS:RES? (@%d)" % loc
        elif measurement_type == "FRES":
            command = "MEAS:FRES? (@%d)" % loc
        elif measurement_type == "TC":
            command = "MEAS:TEMP? TC,%s,1,MAX, (@%d)" % (tc_type, loc)
        elif measurement_type == "THER":
            command = "MEAS:TEMP? THER,%s,1,MAX, (@%d)" % (tc_type, loc)
        elif measurement_type == "THERREF":
            command = "MEAS:TEMP? THER,5000,1,MAX, (@%d)" % loc
        elif measurement_type == "RTD":
            command = "MEAS:TEMP? RTD,85,(@%d)" % loc
        elif measurement_type == "FRTD":
            command = "MEAS:TEMP? FRTD,85,(@%d)" % loc
        elif measurement_type == "DCCURR":
            command = "MEAS:CURR:DC? (@%d)" % loc
        else:
            self.logger.error("MeasureChannel failed on device %s type %s. No such measurement type.", device.name, measurement_type)
            return

        self.logger.debug("MeasureChannel command = %s ", command)

        answer = device.send_read(command)
        if not answer:
            self.logger.error("MeasureChannel failed on device %s.", device.name)

        self.logger.debug("MeasureChannel answer = %s", answer)

        try:
            val = float(answer)
        except ValueError as err:
            self.logger.error("MeasureChannel: Cannot scan value from string '%s'.", answer)
            self.logger.error(err)
            return

        self.last_time = time.time()
        self.last_data = val
        self.last_sdev = 0.0
        self.last_n = 1

        self.logger.info("MeasureChannel %s %s", device.name, option)


    #------------------------------------------------------------------------
    def scale_channel(self, device, option):
        """ Set the scale values for a channel """

        (chan, offset, gain) = option.split()

        command = "CALC:SCALE:GAIN %s, (@%s)" % (gain, chan)
        n = device.send(command)
        if n != 0:
            self._error_exit("ScaleChannel failed on device %s: %s" % (device.name, command))

        command = "CALC:SCALE:OFFSET %s, (@%s)" % (offset, chan)
        n = device.send(command)
        if n != 0:
            self._error_exit("ScaleChannel failed on device %s: %s" % (device.name, command))

        self.logger.info("ScaleChannel %s %s", device.name, option)


    #------------------------------------------------------------------------
    def device_clear(self, device, option):
        """ Send the command to clear a device. """

        s = "*RST"
        device.send(s)


    #------------------------------------------------------------------------
    def sample_data(self, device, option):
        """
        Read data from a device at a specified sample rate
        for a specified number of times.  Store the average of the
        readings in the last_data variable. Use one of the LogData routines
        to save the readings to file.

        Be warned that this routine does NOT return to the main
        loop in hm.c UNTIL all readings have been taken.

        Action line syntax is:
             0  SampleData  device interval number channel_configuration

        channel_configuration is optional, and if included, then configure the channel
        using ConfigChannel before taking each reading.  The channel_configuration
        string is passed into ConfigChannel as the option.

        e.g.
            0 SampleData device 100 50 200 DCVOLT
        or
            0 SampleData device 100 50

        The first example is for a device that will be configured to read from
        channel 200 for dc voltage, and 50 readings will be taken at 100 millisecond intervals.
        Use this option if another process is using the device at the same time
        and may change channels.

        The second example is for a device that does not need to be configured
        but just have a value read back. Use this option if only one process will
        be using the device.  Should run a ConfigChannel first to ensure channel config.
        """

        # parse the option string, get the rate, numreadings, and possible channel config info
        option2 = ""
        try:
            (rate, numreadings, option2) = option.split(None, 2)
        except ValueError as err:
            try:
                (rate, numreadings) = option.split(None, 1)
            except ValueError as err2:
                self.logger.error(err2)
                self._error_exit("SampleData: Can't parse option string '%s'." % (option))

        try:
            sec = float(rate) / 1000.0
            numreadings = int(numreadings)
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("SampleData: Can't determine rate (%s) and/or numreadings (%s)." % (rate, numreadings))

        self.logger.info("SampleData: %d readings every %f seconds.", numreadings, sec)

        if option2:
            self.config_channel(device, option2)

        a = []
        while True:
            t = time.time()
            val = self.read_number(device, "None")
            a.append(val)
            if len(a) == numreadings:
                break

            t2 = time.time()
            amount = sec - (t2-t)
            if amount > 0:
                time.sleep(amount)

        # Calculate the average value and standard deviation.
        self.last_data, self.last_sdev, self.last_n = self._meanstdv(a)

        self.logger.info("SampleData stop: %s %s", device.name, option)


    #------------------------------------------------------------------------
    def start_scan(self, device, option):
        """ starts a scans list of channels on Agilent 34970.

        assumes channels already configured

        Action line syntax:
            0 StartScan device  101,102,103  rate

                list of channels, comma separated
                rate = time between sweeps

        """

        # option line has channels as comma separated list
        # option line has the number of seconds to read for the averaging window,
        rate = 1
        try:
            vals = option.split()
            channels = vals[0]
            if len(vals) > 1:
                rate = int(vals[1])
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("StartScan error for %s. Incorrect option string '%s'." % (device.name, option))

        # Time is when sampling starts
        self.logger.info("StartScan start %s %s", device.name, option)

        #set up device
        comlist = [
            "ROUTE:SCAN (@%s)" % (channels),
            "TRIG:SOURCE TIMER",
            "TRIG:TIMER %d" % (rate),
            "INIT"
        ]
        device.send_lines(comlist)


        start_time = time.time()
        #store start_time in last_time to be used by stop_scan and logger routines
        self.last_time = start_time

    #------------------------------------------------------------------------
    def stop_scan(self, device, option=""):
        """ stops a scans list of channels on Agilent 34970.

        assumes channels already configured

        Action line syntax:
            0 StopScan device  @scale1,@scale2,@scale3

                list of scaling factors for channels, comma separated
                Should be one for each channel if used.

        """

        scale_data = False
        if option:
            scale_data = True
            scales = option.split(",")

        # read averages from device
        command = "CALC:AVERAGE:AVERAGE?"
        answer = device.send_read(command)
        self.logger.debug("StopScan, answer: %s", answer)

        #stop the scan
        command = "ABOR"
        device.send(command)

        # split answer string
        values = [float(x) for x in answer.split(',')]

        result = ""
        for i, val in enumerate(values):
            if scale_data:
                self.last_data = val
                self.scale_value("none", scales[i])
                result += "%f " % (self.last_data)
            else:
                result += "%f " % (val)

        self.last_data = result

        self.logger.debug("StopScan result: %s", result)
        self.logger.info("StopScan stop %s %s", device.name, option)


    #------------------------------------------------------------------------
    def scan_data(self, device, option):
        """ scans list of channels on Agilent 34970.

        assumes channels already configured

        Action line syntax:
            0 ScanData device  101,102,103  time_avg  rate

                list of channels, comma separated
                time_avg = time to have device average over
                rate = time between sweeps

        Equivalent to a StartScan followed by StopScan

        """

        # option line has channels as comma separated list
        # option line has the number of seconds to read for the averaging window,
        timeavg = 1
        rate = 1
        scales = ""
        try:
            vals = option.split(None, 3)
            channels = vals[0]
            if len(vals) > 1:
                timeavg = int(vals[1])
            if len(vals) > 2:
                rate = int(vals[2])
            if len(vals) > 3:
                scales = vals[3]

        except ValueError as err:
            self.logger.error(err)
            self._error_exit("ScanData error for %s. Incorrect option string '%s'." % (device.name, option))


        optstr = "%s %s" % (channels, rate)
        self.start_scan(device, optstr)

        time.sleep(timeavg)

        self.stop_scan(device, scales)

        dt = datetime.datetime.fromtimestamp(self.last_time)
        result = "%4d %2d %2d %2d %2d %2d " % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)
        result = result + self.last_data
        print(result)
        sys.stdout.flush()


    #------------------------------------------------------------------------
    def single_scan(self, device, option):
        """ scan one time list of channels on Agilent 34970.

        assumes channels already configured

        Action line syntax:
            0 ScanData device  101,102,103  @scale1,@scale2,@scale3...

                list of channels, comma separated
                list of scaling, comma separated

        """

        # option line has channels as comma separated list
        # option line has the number of seconds to read for the averaging window,
        channels = None
        scales = None
        try:
            vals = option.split(None, 1)
            channels = vals[0]
            if len(vals) > 1:
                scales = vals[1].split(',')
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("SingleScan error for %s. Incorrect option string '%s'." % (device.name, option))

        self.logger.info("-- SingleScan Start %s %s", device.name, option)

        #set up device
        comlist = [
    #        "ABORT",
    #        "\x03",
            "ROUTE:SCAN (@%s)" % (channels),
            "TRIG:SOURCE TIMER",
            "TRIG:COUNT 1",
            "READ?",
    #        "*TRG"
        ]
        device.send_lines(comlist)

        start_time = time.time()
        #store start_time in last_time to be used by stop_scan and logger routines
        self.last_time = start_time

        # read averages from device
        answer = device.read()
        self.logger.info("SingleScan, answer: %s", answer)
        self.logger.debug("SingleScan, answer: %s", answer)

        # split answer string
        values = [float(x) for x in answer.split(',')]

        result = ""
        for i, val in enumerate(values):
            if scales:
                self.last_data = val
                self.logger.debug("SingleScan %d %f %s", i, val, scales[i])
                self.scale_value("none", scales[i])
                result += "%f " % (self.last_data)
            else:
                result += "%f " % (val)

        self.last_data = result

    #------------------------------------------------------------------------
    def switch_valve(self, device, option, valve_name=None, valve_info=None):
        """ Turn a 2 postion Valco valve to the either the load position
        or inject position by using relays for activating the load or
        inject line.

        Option string should contain:
        either 'Load' or 'Inject'

        Syntax:
              0       SwitchValve     valve_name      Inject | Load

        Requires a line in the configuration file with the valve_name-option pair,
        where the option string should contain:
        the device name where the relays are connected,
        the channel of the relay for the load line,
        the channel of the relay for the inject line.

        e.g.
              Ch4Load  hp34970 200 201
        """

        if option.lower() != "inject" and option.lower() != "load":
            self._error_exit("SwitchValve error for %s. Incorrect option string '%s'. Must be either 'inject' or 'load'." % (device, option))


        # get the real device name and specs
        try:
            (load, inject) = valve_info.split()
            load = int(load)
            inject = int(inject)
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("SwitchValve error for %s. Incorrect option string '%s'." % (valve_name, valve_info))

        self.logger.debug("SwitchValve load: %s inject: %s", load, inject)

        if option.lower() == "load":
            relay_option = "%d" % load
        else:
            relay_option = "%d" %  inject

        r = self.close_relay(device, relay_option)
        if r != 0:
            self._error_exit("CloseRelay error in SwitchValve.")

        time.sleep(0.3)

        r = self.open_relay(device, relay_option)
        if r != 0:
            self._error_exit("OpenRelay error in SwitchValve.")

        self.logger.info("SwitchValve %s %s", valve_name, option)
