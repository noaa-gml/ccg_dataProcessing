# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for the vurf co analyzer
"""
import time
import configparser

import hmsubs

class vurf(hmsubs.hmsub):
    """ subclass for the vurf co analyzer """

    def __init__(self, configfile=None):
        super().__init__(configfile=configfile)

        self.my_procs = {
            "ReadNumber"             : self.read_number,
            "ReadData"               : self.read_number,
            "ReadChannel"            : self.read_number,
            "ConfigChannel"          : self.config_channel,
            "MeasureChannel"         : self.measure_channel,
            "SampleData"             : self.sample_data,

        }
        self.action_procs.update(self.my_procs)

    #------------------------------------------------------------------------
    def read_number(self, device, option):
        """ Read a single floating point value back from a device
            Action line syntax:
               0 ReadData device None

            Assumes device is already configured for the desired data type.
        """

        command = "SIG?"
        self.logger.debug("ReadNumber command = %s", command)

        answer = device.send_read(command)
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

        command = "SIG?"

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
        """

        command = "SIG?"
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
        # Unfortunately, the CO vurf analyzer sometimes returns a 0
        # instead of the correct value, so we need to go through all
        # the readings and remove these bad data points.

        a = [x for x in a if 100 < x < 10000000]

        self.last_data, self.last_sdev, self.last_n = self._meanstdv(a)

        self.logger.info("SampleData stop: %s %s", device.name, option)
