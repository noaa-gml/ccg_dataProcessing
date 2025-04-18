# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for the Peak Labs chromatograph
"""

import datetime

import hmsubs

class pp(hmsubs.hmsub):
    """ subclass for the Peak Labs co gc """

    def __init__(self):
        super(pp, self).__init__()

        self.my_procs = {
            "PPRun"              : self.pprun,
        }
        self.action_procs.update(self.my_procs)


    #------------------------------------------------------------------------
    def pprun(self, device, option):
        """
        Start a run on a Peak Labs chromatograph.  This device requires a
        start run string of '^BS^C'.  It then sends one data point per line,
        then a string '^BE^C' after the last data point.
        This end of data string doesn't have a new line character, so we
        will read one character at a time and store it all in one string. Any
        new line characters will be replaced with a space.
        When run is completed, split the string into values, and
        write out data to a file in gc txt format.
        """

        samplerate = 5

        a = option.split()
        gcfile = a[0]
        port = int(a[1])

        tm = datetime.datetime.now()
        command = "\x02S\x03"
        self.logger.debug("PPRun: Sending string '%s'.", command)
        n = device.send(command)
        if n != 0:
            self._error_exit("PPRun failed on device %s: %s" % (device.name, command))

        answ = ""
        endofdata = '\x02E\x03'
        empty = False
    #    device.ser.open()

        # read one character at a time until endofdata string is found.
        # If a blank line is returned, there was likely a read timeout.
        while True:
            s = device.ser.read()
            if not s:
                empty = True
                break
            if s == '\n': s = ' '
            answ += s

            if endofdata in answ: break

        if not empty:
            self.logger.debug("PPRun: Got End of Data string.")
        else:
            self.logger.debug("PPRun: Got empty string.")

    #    device.ser.close()

        # split the answer into a list of data values
        answ = answ.strip(endofdata)
        data = [int(x) for x in answ.split()]
        np = len(data)

        self._write_gc(gcfile, tm, port, samplerate, np, data)

        self.logger.info("PPRun: %d points written to %s", np, gcfile)
