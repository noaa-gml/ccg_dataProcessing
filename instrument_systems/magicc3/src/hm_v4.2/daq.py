# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for superlogics daq units
"""

import time

import hmsubs

class daq(hmsubs.hmsub):
    """ subclass for rs-485 daq units
    Methods:

        read_number
            Read back a value from the daq
        measure_channel
            An alias for read_number

    """

    def __init__(self, configfile=None):
        super().__init__(configfile=configfile)

        self.my_procs = {
            "ReadNumber"  : self.read_number,
            "ReadChannel" : self.read_number,
            "MeasureChannel" : self.read_number,
            "CloseRelay" : self.close_relay,
            "OpenRelay" : self.open_relay,
        }
        self.action_procs.update(self.my_procs)

    #------------------------------------------------------------------------
    def read_number(self, device, option):
        """ Read a single floating point value back from a device

            Has alias names ReadChannel, MeasureChannel
            Action line syntax:
               0 ReadData device channelnum
               0 ReadChannel device channelnum
               0 MeasureChannel device channelnum

            Assumes device is already configured for the desired data type.

            option is a string containing 'AAN' where AA is the hex id number of the device,
            and N is the channel number, eg. 011 is id 1, channel 1
        """

        cmd = "#%s" % (option)

        self.logger.debug("ReadNumber command = %s", cmd)
        answer = device.send_read(cmd)

        if not answer:
            self.logger.error("ReadNumber failed on device %s.", device.name)

        self.logger.debug("ReadNumber answer = %s", answer)

        try:
            if answer.startswith(">"):
                val = float(answer[1:])
            elif answer.startswith("?"):
                self.logger.error("ReadNumber: Error response from daq '%s'.", answer)
                return 0

        except ValueError as err:
            self.logger.error("ReadNumber: Cannot scan value from string '%s'.", answer)
            self.logger.error(err)
            return 0

        self.last_time = time.time()
        self.last_data = val
        self.last_sdev = 0.0
        self.last_n = 1

        self.logger.info("ReadNumber %s %s %f at %s", device.name, option, val, self.last_time)

        return val

    #------------------------------------------------------------------------
    def close_relay(self, device, option):
        """ Close a relay on a switch device.
            Action line syntax:
                 0 CloseRelay device 207

            option is a string containing 'AAN' where AA is the hex id number of the device,
            and N is the channel number, eg. 011 is id 1, channel 1

            e.g. 0 CloseRelay daq 060  # close relay 0 on device id 06
        """

        val = int(option)
        card = val/10
        relay = val % 10

        cmd = "#%02d1%d01" % (card, relay)

        self.logger.debug("CloseRelay command = %s", cmd)
        answer = device.send_read(cmd)

        if not answer:
            self.logger.error("CloseRelay failed on device %s.", device.name)

        self.logger.debug("CloseRelay answer = %s", answer)

        try:
            if answer.startswith(">"):
                pass
            elif answer.startswith("?"):
                self.logger.error("CloseRelay: Error response from daq '%s'.", answer)
                return 0

        except ValueError as err:
            self.logger.error("CloseRelay: Cannot check reply from string '%s'.", answer)
            self.logger.error(err)

        return 0

    #------------------------------------------------------------------------
    def open_relay(self, device, option):
        """ Open a relay on a switch device.
            Action line syntax:
                 0 OpenRelay device 207

            option is a string containing 'AAN' where AA is the hex id number of the device,
            and N is the channel number, eg. 011 is id 1, channel 1

            e.g. 0 OpenRelay daq 060  # open relay 0 on device id 06
        """

        val = int(option)
        card = val/10
        relay = val % 10

        cmd = "#%02d1%d00" % (card, relay)

        self.logger.debug("OpenRelay command = %s", cmd)
        answer = device.send_read(cmd)

        if not answer:
            self.logger.error("OpenRelay failed on device %s.", device.name)

        self.logger.debug("OpenRelay answer = %s", answer)

        try:
            if answer.startswith(">"):
                pass
            elif answer.startswith("?"):
                self.logger.error("OpenRelay: Error response from daq '%s'.", answer)
                return 0

        except ValueError as err:
            self.logger.error("OpenRelay: Cannot check reply from string '%s'.", answer)
            self.logger.error(err)

        return 0
