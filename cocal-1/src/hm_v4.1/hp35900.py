# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for the hp 35900 integrator
"""

import time
import datetime

import hmsubs

class hp35900(hmsubs.hmsub):
    """ subclass for the hp35900 integrator """

    def __init__(self):
        super(hp35900, self).__init__()

        self.run_time = 0

        self.my_procs = {
            "StartRun"   : self.start_run,
            "StopRun"    : self.stop_run,
            "StoreData"  : self.store_data,
        }
        self.action_procs.update(self.my_procs)


    #------------------------------------------------------------------------
    def start_run(self, device, option):
        """ Start a run on the HP 35900 Dual Channel Interface.
        Action line syntax:
            0 StartRun HP35900 channel

        where channel should be either 'A' or 'B'.
        """

        channel = option.upper()
        if channel not in ["A", "B"]:
            self._error_exit("StartRun error for %s. Bad channel option %s. Must be 'A' or 'B'." % (device.name, option))

        lines = ["%sRGR" % channel, "%sRST" % channel, "%sVST" % channel]
        n = device.send_lines(lines)
        if n != 0:
            self._error_exit("StartRun failed on device %s: %s" % (device.name, option))

        self.run_time = time.time()
        self.logger.info("StartRun %s %s", device.name, option)


    #------------------------------------------------------------------------
    def stop_run(self, device, option):
        """ Stop a run on the HP 35900 Dual Channel Interface
        Action line syntax:
            0 StopRun HP35900 Channel

        where Channel should be either 'A' or 'B'.
        """

        channel = option.upper()
        if channel not in ["A", "B"]:
            self._error_exit("StopRun error for %s. Bad channel option %s. Must be 'A' or 'B'." % (device.name, option))

        lines = ["%sRSP" % channel, "%sVSP" % channel]
        n = device.send_lines(lines)
        if n != 0:
            self._error_exit("StopRun failed on device %s: %s" % (device.name, option))

        self.logger.info("StopRun %s %s", device.name, option)

    #------------------------------------------------------------------------
    def store_data(self, device, option):
        """ Read back the data from the dci, write values to file.
        File is in gc TEXT format. (see /usr/local/integrator/src)
        'Option' must contain 4 fields:
            the channel letter either 'A' or 'B',
            the filename to store the data,
            the port number where the sample came from,
            the samplerate of the data in Hz

        Action line syntax:
             0 StoreData HP35900 channel filename port samplerate

        """

        (channel, filename, port, samplerate) = option.split()
        channel = channel.upper()
        if channel not in ["A", "B"]:
            self._error_exit("StoreData error for %s. Bad channel option %s. Must be 'A' or 'B'." % (device.name, channel))

        command = "%sVSS" % channel
        self.logger.debug("StoreData: Sending string '%s'.", command)
        answer = device.send_read(command)
        self.logger.debug("StoreData: Response is '%s'.", answer)

        # answer should look like
        # AVSS OFF, 142, 12, 149, 6036980
        # Get total number of readings from the 4th item
        items = answer.split(',')
        np = int(items[3])

        # Read in the data strings from dci
        data = []
        while len(data) < np:

            com = "%sVRD" % channel
            answer = device.send_read(com)

            # answer should look like
            # AVRD DEC, 020;999999999,999999999,999999999, ...
            self.logger.debug("StoreData: data string = '%s'", answer)
            (s1, datastr) = answer.split(";")
            (com, s, count) = s1.split()
            if "VRD" not in com:
                self._error_exit("StoreData: Did not get correct response from DCI for %s command: %s" % (com, answer))

            # leave loop if no more data available
            count = int(count)
            if count == 0 or 'OFF' in s:
                break

            a = datastr.split(',')
            a = a[0:count]
            for val in a:
                data.append(int(val))

        tm = datetime.datetime.fromtimestamp(self.run_time)
        self._write_gc(filename, tm, port, samplerate, np, data)

        self.logger.info("StoreData: %d points written to %s", np, filename)
