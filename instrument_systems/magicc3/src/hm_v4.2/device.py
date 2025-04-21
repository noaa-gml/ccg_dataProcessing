# vim: tabstop=4 shiftwidth=4 expandtab
""" device class for use with hm program """

import sys
import os

import logging
import time

import pyvisa
import errornum

from lock_file import LockFile

logger = logging.getLogger('hm')

#############################################################
class Device:
    """
    Class for device information.  A device is a physically
    connected instrument via serial interface to the computer.

    Current implementation can handle either a file device or
    a serial device.

    Members:
        name:      name of device used in action files
        bus:       currently only 'serial' or 'file'.
        devfile:   device visa id, e.g. ASRL/dev/ttyUSB2::INSTR
        use_cr:    set to 1 if the device uses a carriage return instead of newline
               for signaling the end of data e.g vurf
        baud:      baud rate of serial interface
        lock_file: name of file to use for locking, to insure only
               one process at a time is communicating with device.
        locked:    boolean specifying if device has been locked external
               to this class, i.e. with LockInterface action
        lock_f:    file handle to lock_file
        inst:       pyvisa resource instance

    Methods:
        send:                Send a one line string to device
        send_read:           Send one line string to device, read one line answer
        read:                Read one line answer without prompting
        send_lines:          Send one line at a time from a list of lines.
        send_read_multiline: Send a string of data to a device, then read multiple
                                     line answer from the device.

    Uses the pyvisa modules for actual communications through interface.
    """

    def __init__(self, rm, name="", bus="serial", devfile="none", use_cr=0, baud=9600):

        self.rm = rm  # pyVISA ResourceManager
        self.name = name
        self.bus = bus

        self.use_cr = int(use_cr)
        self.baud = int(baud)
        self.lock_file = "/tmp/%s.lock" % self.name
        self.locked = False
        self.lock_f = None
        self.inst = None
        self.inst_io = None
        self.file_mode = None

        if bus == "file":
            if self.use_cr:
                self.file_mode = "a"
            else:
                self.file_mode = "w"
            self.use_cr = 0

        self.opened = False

        if devfile.lower() == "none":
            self.devfile = None
        else:
            self.devfile = devfile

    #-----------------------------------------------------------
    def open(self):
        """ Open the device, and set parameters. """

        if self.bus == "file":
            try:
                logger.debug("trying to open file ", self.devfile)
                self.inst = open(self.devfile, self.file_mode)
            except IOError as err:
                logger.error("Cannot open %s. %s", self.devfile, err)
                print("Cannot open %s. %s" % (self.devfile, err), file=sys.stderr)
                sys.exit(errornum.OSERROR)

        elif self.bus == "serial":

            try:
                self.inst = self.rm.open_resource(self.devfile)
            except Exception as err:
                logger.error("Cannot open %s device %s. %s", self.bus, self.devfile, err)
                print("Cannot open %s. %s" % (self.devfile, err), file=sys.stderr)
                sys.exit(errornum.OSERROR)

            self.opened = True
            self.inst.timeout = 5000
            self.inst.baud_rate = self.baud
            self.inst.flow_control = pyvisa.constants.VI_ASRL_FLOW_XON_XOFF

#            self.inst.read_termination = '\r'

            if self.use_cr:
                self.inst.read_termination = '\r'
                self.inst.write_termination = '\r'
            else:
                self.inst.read_termination = '\n'
                self.inst.write_termination = '\r\n'


        else:
            logger.error("Unknown bus type %s. Must be one of 'serial' or 'file'.", self.bus)
            sys.exit(errornum.BADDEVICE)


    #-----------------------------------------------------------
    def show_members(self):
        """ Show some values for this class """

        print("      Device name:", self.name)
        print("      Device file:", self.devfile)
        print("      Bus Type: ", self.bus)
        print("      Baud Rate:", self.baud)
        print("      Lock File:", self.lock_file)
        print("      Is Locked:", self.locked)
        print("      Is Open:", self.opened)
        print("      Use Carriage Return:", self.use_cr)

    #-----------------------------------------------------------
    def lock(self):
        """ Lock the lock file.
        If another process has it already locked, wait until it becomes unlocked.
        """

        self.lock_f = LockFile(self.lock_file, wait=True, remove=False)
        logger.debug("Got file lock on %s", self.lock_file)

    #-----------------------------------------------------------
    def unlock(self):
        """ Unlock the lock file """

        self.lock_f.release()
        logger.debug("Release file lock on %s", self.lock_file)

    #-----------------------------------------------------------
    def send(self, data):
        """ Send one line of data to device. """

        if not self.opened:
            self.open()

        if not self.locked:
            self.lock()

        s = data
        retcode = 0
        try:
            self.inst.write(data)
            logger.debug("Send: %s", data)
            time.sleep(0.01)

        except Exception as err:
            logger.error(err)
            retcode = 2

        finally:
            if not self.locked:
                self.unlock()

        if self.bus == "file": self.inst.close()

        return retcode

    #-----------------------------------------------------------
    def send_lines(self, data):
        """ Send multiple lines of data to device. """

        if not self.opened:
            self.open()

        if not self.locked:
            self.lock()

        retcode = 0
        try:
            for line in data:
                if self.bus == "file":
                    self.inst.write(line + "\r\n")
                else:
                    self.inst.write(line)
                logger.debug("Send: %s", line)
                time.sleep(0.01)

        except Exception as err:
            logger.error(err)
            retcode = 2

        finally:
            if not self.locked:
                self.unlock()

        if self.bus == "file": self.inst.close()

        return retcode

    #-----------------------------------------------------------
    def send_read(self, command):
        """
        Send a string of data to a device, then
        read a one line answer from the device.
        """

        if not self.opened:
            self.open()

        if not self.locked:
            self.lock()

        line = ""
        try:
            logger.debug("SendRead write: '%s'", command)
            line = self.inst.query(command)
            logger.debug("SendRead read: '%s'", line)

        except Exception as err:
#        except pyvisa.errors.VisaIOError as err:
            logger.error("Error in send_read(): %s", err)

#        finally:
        if not self.locked:
            self.unlock()

        return line

    #-----------------------------------------------------------
    def send_read_multiline(self, command):
        """
        Send a string of data to a device, then
        read multiple line answer from the device.
        """

        if not self.opened:
            self.open()

        if not self.locked:
            self.lock()

        try:
            logger.debug("SendRead write: %s", command)
            self.inst.write(s)
            buffer_end = False
            lines = []
            while not buffer_end:
                line = self.inst.read()
                logger.debug("SendReadMultiline read: '%s'", line)
                if len(line) > 2:
                    lines.append(line)
                else:
                    buffer_end = True

        except Exception as err:
            logger.error(err)

        finally:
            if not self.locked:
                self.unlock()

        return lines

    #-----------------------------------------------------------
    def read(self):
        """ Read a string of data from a device """

        if not self.opened:
            self.open()

        if not self.locked:
            self.lock()

        line = ""
        try:
            line = self.inst.read()   # read a '\n' terminated line
#            logger.debug("Read read %d characters: '%s'", len(line), line)

        except  Exception as err:
            logger.error("Error in device.read(): %s", err)

        finally:
            if not self.locked:
                self.unlock()


        return line

    #-----------------------------------------------------------
    def clear(self):

        if not self.opened:
            self.open()

        self.inst.flush(pyvisa.constants.VI_READ_BUF_DISCARD)

    #-----------------------------------------------------------
    def read_raw(self):
        """ Read a string of data without decoding from a device """

        if not self.opened:
            self.open()

        if not self.locked:
            self.lock()

        line = ""
        try:
            line = self.inst.read_raw()
            logger.debug("Read_raw read %d characters: '%s'", len(line), line)

        except  Exception as err:
            logger.error("Error in device.read_raw(): %s", err)

        finally:
            if not self.locked:
                self.unlock()


        return line
