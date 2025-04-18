# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsub routines for a 'test' device, that is, some routines
available which mimic actual device routines, but don't do
any actual communications with a device.

Mainly used to test upstream hm code.
"""
from __future__ import print_function

import datetime
import time
import configparser
import random

import hmsubs

species = 0
sample = 'Line1'

#------------------------------------------------------------------------
def lgr_test(sysname):
    """ Simulate an lgr output string """


#ch4, j, h2o, j, co2, j, cell_pressure, j, cell_temp, j, j, j, ring_down, j, ring_down, j, j

# co, j, n2o, j, h2o, j, co_dry, j, n2o_dry, j, press, j, temp, j, j, j, j, j, j

    dt = datetime.datetime.now()

#    s = "%4d %d %d %d %d %d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)

    if "CH4" in sysname:
        ch4 = 1.920 + random.gauss(0, 0.015)
        co2 = 410 + random.gauss(0, 0.8)
        cell_temp = 45 + random.gauss(0, 0.03)
        cell_press = 140 + random.gauss(0, 0.2)

#s = "    02/06/13 15:15:36.889,    1.93523e+00,    0.00000e+00,    1.67759e+02,    0.00000e+00,    4.28262e+02,    0.00000e+00,    1.39713e+02,    0.00000e+00,    4.51228e+01,    0.00000e+00,    5.90411e+00,    0.00000e+00,    1.08492e+01,    0.00000e+00,    7.97098e+00,    0.00000e+00,              3"

        data = "    %02d/%02d/%02d %02d:%02d:%06.3f,    %11.5e,    0.00000e+00,    1.67759e+02,    0.00000e+00,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,    5.90411e+00,    0.00000e+00,    1.08492e+01,    0.00000e+00,    7.97098e+00,    0.00000e+00,              3" % (dt.month, dt.day, dt.year-2000, dt.hour, dt.minute, dt.second + dt.microsecond/1000000, ch4, co2, cell_press, cell_temp)


    else:
        n2o = 338 + random.gauss(0, 0.2)
        co = 125 + random.gauss(0, 0.8)
        cell_temp = 39 + random.gauss(0, 0.1)
        cell_press = 85 + random.gauss(0, 0.2)

        data = "    %02d/%02d/%02d %02d:%02d:%06.3f,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,      1.67759e+02,    0.00000e+00,    0.00000e+00,    0.00000e+00,    0.00000e+00,    0.00000e+00,    %11.5e,    0.00000e+00,    %11.5e,    0.00000e+00,    1.08492e+01,    0.00000e+00,    7.97098e+00,    0.00000e+00,              3" % (dt.month, dt.day, dt.year-2000, dt.hour, dt.minute, dt.second + dt.microsecond/1000000, co, n2o, cell_press, cell_temp)


    return data


def licor_test():

    sec10 = datetime.timedelta(seconds=10)

    prev_dt = datetime.datetime.now()

#    startdt = dt - sec10
#    s = "%4d %d %d %d %d %d" % (startdt.year, startdt.month, startdt.day, startdt.hour, startdt.minute, startdt.second)

    f = open("/home/ccg/sys.sample")
    line = f.readline()
    f.close()

    if "Line" in line:
        co2 = 412 + random.gauss(0, 0.8)
    elif "R0" in line:
        co2 = 408 + random.gauss(0, 0.1)
    elif "S1" in line:
        co2 = 385 + random.gauss(0, 0.1)
    elif "S2" in line:
        co2 = 400 + random.gauss(0, 0.1)
    elif "S3" in line:
        co2 = 415 + random.gauss(0, 0.1)
    elif "S4" in line:
        co2 = 430 + random.gauss(0, 0.1)
    elif "TGT" in line:
        co2 = 420 + random.gauss(0, 0.1)
    elif "None" in line:
        co2 = 412 + random.gauss(0, 0.8)

    water = 0.001 + random.gauss(0, 0.0005)
    temp = 34 + random.gauss(0, 0.2)
    pressure = 85 + random.gauss(0, 0.2)
    # mimic data from licor serial output
    # co2, water, temp, pressure
    data = " %7.3f %.3f %.3f %.3f" % (co2, water, temp, pressure)
#            data = s + " %7.3f 0.002 10 0.001 0 10 34.001 .005 10 85.123 .004 10" % co2

    return data

def picarro_test():
    global species, sample
    sec10 = datetime.timedelta(seconds=10)

    dt = datetime.datetime.now()

#    startdt = dt - sec10
#    s = "%4d %d %d %d %d %d" % (startdt.year, startdt.month, startdt.day, startdt.hour, startdt.minute, startdt.second)

    try:
        f = open("/home/ccg/sys.sample")
        line = f.readline()
        f.close()
    except:
        line = "Line1"

    # use previous sample to avoid getting wrong value on gas change

    if "Line" in sample:
        co2 = 412 + random.gauss(0, 0.8)
        co = 100 + random.gauss(0, 2.0)
        ch4 = 2000 + random.gauss(0, 2.0)
    elif "R0" in sample:
        co2 = 408 + random.gauss(0, 0.1)
        co = 80 + random.gauss(0, 1.0)
        ch4 = 2050 + random.gauss(0, 1.0)
    elif "S1" in sample:
        co2 = 385 + random.gauss(0, 0.1)
        co = 40 + random.gauss(0, 1.0)
        ch4 = 1800 + random.gauss(0, 1.0)
    elif "S2" in sample:
        co2 = 400 + random.gauss(0, 0.1)
        co = 85 + random.gauss(0, 1.0)
        ch4 = 1900 + random.gauss(0, 1.0)
    elif "S3" in sample:
        co2 = 415 + random.gauss(0, 0.1)
        co = 110 + random.gauss(0, 1.0)
        ch4 = 2050 + random.gauss(0, 1.0)
    elif "S4" in sample:
        co2 = 430 + random.gauss(0, 0.1)
        co = 150 + random.gauss(0, 1.0)
        ch4 = 2200 + random.gauss(0, 1.0)
    elif "S5" in sample:
        co2 = 445 + random.gauss(0, 0.1)
        co = 200 + random.gauss(0, 1.0)
        ch4 = 2300 + random.gauss(0, 1.0)
    elif "TGT1" in sample:
        co2 = 420 + random.gauss(0, 0.1)
        co = 95 + random.gauss(0, 1.0)
        ch4 = 1980 + random.gauss(0, 1.0)
    elif "TGT2" in sample:
        co2 = 405 + random.gauss(0, 0.1)
        co = 95 + random.gauss(0, 1.0)
        ch4 = 1980 + random.gauss(0, 1.0)
    elif "TGT" in sample:
        co2 = 420 + random.gauss(0, 0.1)
        co = 95 + random.gauss(0, 1.0)
        ch4 = 1980 + random.gauss(0, 1.0)
    elif "None" in sample:
        co2 = 412 + random.gauss(0, 0.8)
        co = 100 + random.gauss(0, 2.0)
        ch4 = 2000 + random.gauss(0, 2.0)

    sample = line

    h2o = 0.018 + random.gauss(0, 0.01)
    warmbox_temp = 45 + random.gauss(0, 0.1)
    etalon_temp = 45 + random.gauss(0, 0.1)
    das_temp = 40 + random.gauss(0, 0.1)
    cavity_temp = 45 + random.gauss(0, 0.02)
    cavity_pressure = 140 + random.gauss(0, 0.1)
    # mimic data from licor serial output
    # co2, water, temp, pressure
#            data = s + " %7.3f 0.002 10 0.001 0 10 34.001 .005 10 85.123 .004 10" % co2
#1585262150.76   140.0052    44.9982    40.6250    44.7779    44.9976     1.0000     0.1041   412.7222     1.9120     0.0173 20200326.0000 223550.7640

    species = species + 1 # 1 to 4
    if species > 4: species = 1
    dt1 = dt.strftime("%Y%m%d")
    dt2 = dt - datetime.datetime(dt.year, dt.month, dt.day)
    sod = dt2.total_seconds()

    tm = dt.timestamp()
    fmt = "%13.2f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %10.4f %s.0000 %11.4f" 
    data = fmt % (tm, cavity_pressure, cavity_temp, das_temp, etalon_temp, warmbox_temp, species, co, co2, ch4, h2o, dt1, sod)
#    print(data)

    return data

class test(hmsubs.hmsub):
    """ subclass for test device """

    def __init__(self, configfile=None):
        super(test, self).__init__()

        self.my_procs = {
            "ReadNumber"    : self.read_number,
            "MonitorTest"   : self.monitor_test,
            "SwitchValve"   : self.switch_valve,
            "LockInterface" : self.lock_interface,
            "MeasureChannel": self.measure_channel,
        }
        self.action_procs.update(self.my_procs)

        self.config = None
        if configfile:
            self.config = configparser.ConfigParser()
            self.config.read(configfile)


    #------------------------------------------------------------------------
    def read_number(self, device, option):
        """
        Simulate getting a number from a device,
        but generate a random number instead.

            Action line syntax:
               0 ReadNumberTest device None

        Use LogData or PrintData to get the number, which is stored in 'last_data'.

        """

        answer = "%.5f" % random.uniform(0, 10)
        val = float(answer)

        self.logger.debug("ReadNumberTest answer = %s", answer)

        self.last_time = time.time()
        self.last_data = val
        self.last_sdev = 0.0
        self.last_n = 1

        self.logger.debug("ReadNumberTest %f", val)

        return val


    #------------------------------------------------------------------------
    def monitor_test(self, device, option):
        """
        Simulate the monitor_data routine, but using random number as a result.

        No actual communications with device are done.
        Instead, a random number is generated at specified sample rate,
        and that number printed to stdout.

            Be warned that this routine does NOT return to the main
            loop in hm.py.  Only way to stop hm is by killing the process.

            Action line syntax:
                0 MonitorTest device interval time_avg

            where
                - interval is time between readings in milliseconds,
                - time_avg is length of time to average readings before printing
                  out the values, in seconds. A time_avg value of 0 will cause
                  hm to print out every reading.

            For example,
                0 MonitorTest Test 500 10

            which will cause this routine to make a random number every 500 milliseconds
            and averages these numbers for 10 seconds before printing out.
            """


        #Time when sampling starts
        self.logger.info("MonitorTest start %s", option)

        # Option line has sample rate in milliseconds and the
        #  number of readings to take.
        try:
            (rate, timeavg) = option.split()
            rate = int(rate)
            timeavg = int(timeavg)
            sec = rate/1000.0
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("MonitorTest: Can't parse option string '%s'." % (option))

        a = []
        t = time.time()
        starttime = self._getStartTime(t, timeavg, True)

        while True:
            t = time.time()
            self.logger.debug("MonitorTest: time is %s", t)
            val = random.uniform(0, 10)
            self.logger.debug("MonitorTest: val is %s", val)
            a.append(val)
            if t - starttime >= timeavg:
                if timeavg == 0:
                    dt = datetime.datetime.fromtimestamp(t)
                else:
                    dt = datetime.datetime.fromtimestamp(starttime)
                avg, stdv, n = self._meanstdv(a)
                s = "%s %f %f %d" % (dt.strftime("%Y %m %d %H %M %S"), avg, stdv, n)

                self._write_result(s)
                self.logger.debug(s)

                a = []
                starttime = self._getStartTime(t, timeavg, True)
                if timeavg != 0:
                    self.logger.debug("new starttime is %s", starttime)

            t2 = time.time()
            amount = sec - (t2-t)
            self.logger.debug("MonitorTest: wait amount is %s", amount)
            if amount > 0:
                time.sleep(amount)

    #------------------------------------------------------------------------
    def _get_answer(self, device, command):
        """ generate a fake response from analyzer.
        Overrides _get_answer in hmsubs.py
        """

        if device.name == "lgr_ch4":
            answer = lgr_test("CH4")
            self.logger.debug("ReadDevice: %s", answer)
        elif device.name == "licor":
            answer = licor_test()
        elif device.name == "picarro":
            answer = picarro_test()
        else:
            answer = lgr_test("N2O")

        # put a delay in so we don't make too many fake data lines
        # i.e. simulate real output invervals from analyzer
        time.sleep(1)

        return answer

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
              Ch4Load  VxiRelay 200 201
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

        self.logger.debug("Close Relay %s", relay_option)

        time.sleep(0.3)

        self.logger.debug("Open Relay %s", relay_option)

        self.logger.info("SwitchValve %s %s", valve_name, option)

    #-------------------------------------------------------------------------
    def lock_interface(self, device, option):

        self.logger.debug("LockInterface %s %s", device.name, option)

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

            option is something like 
                '206 DCVOLT sample_flow instrument picarro' or
                '212 THER 2252 temperature misc room'
        """

        tc_type = None
        a = option.split()
        loc = int(a[0]) # channel number
        measurement_type = a[1] 
        if len(a) == 6:
            tc_type = a[2]


#        if len(a) == 3:
#            tc_type = a[2]
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

# put in fake data here
        answer = "1.2345"
        if len(a) == 6:
            field = a[3]
            loc = a[4]
            loc2 = a[5]
        else:
            field = a[2]
            loc = a[3]
            loc2 = a[4]
        if field == "flow":
                value = random.gauss(20, 1)
        elif field == "bleed_flow":
                value = random.gauss(4, 1)
        elif field == "pressure":
                if "inlet" in loc:
                        value = random.gauss(16, 1)
                elif "tank" in loc:
                        if loc2 == "S1":
                            value = random.gauss(1800, 5)
                        elif loc2 == "S2":
                            value = random.gauss(1200, 5)
                        elif loc2 == "S3":
                            value = random.gauss(1300, 5)
                        elif loc2 == "S4":
                            value = random.gauss(600, 5)
                        elif loc2 == "R0":
                            value = random.gauss(900, 5)
                        elif loc2 == "TGT":
                            value = random.gauss(1450, 5)
                        elif loc2 == "TGT1":
                            value = random.gauss(1250, 5)
                        elif loc2 == "TGT2":
                            value = random.gauss(1750, 5)
                        else:
                            value = random.gauss(1600, 5)
                elif "ndir" in loc2:
                        value = random.gauss(50, 1)
        elif field == "dew_point":
                value = random.gauss(15, 1)
        elif field == "dried_dew_point":
                value = random.gauss(1, 1)
        elif field == "back_pressure":
                value = random.gauss(5, 1)
        elif field == "temperature":
                if "ndir" in loc2:
                        value = random.gauss(26, 1)
                elif "room" in loc2:
                        value = random.gauss(22, 1)
                elif "trap" in loc2:
                        value = random.gauss(-60, 4)
        elif field == "sample_flow":
                value = random.gauss(102, 1)
        elif field == "sample_pressure":
                value = random.gauss(700, 1)
        elif field == "zero_flow":
                value = random.gauss(10, 1)
        else:
                value = 1.2345


#        answer = device.send_read(command)
        answer = str(value)
        if not answer:
            self.logger.error("MeasureChannel failed on device %s.", device.name)

        self.logger.debug("MeasureChannel answer = %s", answer)

        try:
            val = float(answer)
#            val = value
        except ValueError as err:
            self.logger.error("MeasureChannel: Cannot scan value from string '%s'.", answer)
            self.logger.error(err)
            return

        self.last_time = time.time()
        self.last_data = val
        self.last_sdev = 0.0
        self.last_n = 1

#        print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@", self.last_data)

        self.logger.info("MeasureChannel %s %s %s", device.name, option, self.last_data)
