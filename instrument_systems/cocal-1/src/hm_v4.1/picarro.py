# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for the picarro analyzer
"""

import sys
import configparser
import hmsubs
import datetime
from collections import defaultdict

class picarro(hmsubs.hmsub):
    """ subclass for the picarro analyzer """

    def __init__(self, configfile=None):
        super(picarro, self).__init__()

        self.my_procs = {
            "GetPicarroBuffer"   : self.get_picarro_buffer,
        }
        self.action_procs.update(self.my_procs)

        self.config = None
        if configfile:
            self.config = configparser.ConfigParser()
            s = self.config.read(configfile)
            if len(s) == 0:
                self.config = None


    #------------------------------------------------------------------------
    def _setValues(self, v, values):
        """ Update the v lists with new values from list 'values'.
        If device is a picarro, then do additional steps based on species_column and water_corrected.
        """

        # picarro output string is configurable, but usually is
        # timestamp cavitypressure cavitytemp dastemp etalontemp warmboxtemp speciesnumber species1 species2 species3 species4 date time
        # 1569862689.12   140.0013    45.0001    40.7500    45.1082    45.0002     1.0000   405.7091    1.9143   0.0009 20190930.0000 165809.1200 (non-water corrected, co2, ch4 and h2o)
        # 1569862689.12   140.0013    45.0001    40.7500    45.1082    45.0002     1.0000   405.7091   405.7202     1.9143     1.9147     0.0009 20190930.0000 165809.1200 (water corrected)
        # By default, speciesnumber is column 6 (starting with 0), but can be different and set by the variable 'sp_col'.
        # Use the species number value to get to the actual column where the value is,
        # e.g. if species = 1, then we want column 7, if species number = 2, we want column 8 etc.
        # If water corrected values are also included, then they are in the column after
        # the non-water corrected value.  So if species = 1, we want columns 7 and 8 etc.

        #self.logger.debug(" in setValues, values: %s" % values)
        
        if self.config:
            water_corrected = self.config['DEFAULT']['water_corrected']
        else:
            water_corrected = 0
        species_column = 6

        # picarro species number (1 through 3 or 4)
        sp = values[species_column]

        for i, val in enumerate(values):
            #self.logger.debug("val %d = %f" % (i,val))

            # values before the species number column
            if i <= species_column:
                #self.logger.debug("prior to species col.  val = %f",val)
                v[i].append(val)

            # values after the species number column.  These are the gas values
            else:
                # get value at column species_column+sp.  If water_corrected get the next one too.
                # Will get one of the time fields after H2O when using water corrected
                # values since there isn't a water corrected H2O field following H2O.
                if water_corrected:
                    # get value of current species
                    curr_idx = species_column + ((sp - 1) * 2) + 1   # index of gas value
                    curr_idx2 = curr_idx + 1                         # index of water corrected gas value
                    if i == curr_idx or i == curr_idx2:
                        self.logger.debug("getting value of current sp. Val = %f", val)
                        v[i].append(val)
                    else:
                        #self.logger.debug("NOT current sp, val = %f", val)
                        pass
                else:
                    #get value at column [species_column + sp]
                    if i == (species_column + sp):
                        self.logger.debug("getting value of current sp.  Val = %f", val)
                        #print("getting value of current sp.  Val = %f", val)
                        v[i].append(val)
                    else:
                        self.logger.debug("NOT the current sp,  val = %f", val)
                        #print("NOT the current sp,  val = %f", val)
                        pass
        return v



##########################################################################
# 
#   Picarro version of getResultString - used to only include new measurements of
#   each species. Use self._setValues to split based on current species measured.
#
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

            """
                    ORIGINAL CODE, CHANGE TO ONLY INCLUDE NEW CURRENT SP MEASURED 
            # put each column value into the v lists
            for i, val in enumerate(values):
                v[i].append(val)
            """
            # Use self._setValues to ignore duplicate reported values in Picarro data stream
            v = self._setValues(v, values)

        # for each column list, get mean, stdv, add to result string
        #for n in v:
        #    vals = v[n]
        #    #print("\nin getResultString, vals: %s" % vals, file=sys.stderr)
        #    avg, std, num = self._meanstdv(vals)
        #    result += " %f %f %d" % (avg, std, num)
        #    print(" in getResultString, result[%d]:   %f %f %d" % (n, avg, std, num), file=sys.stderr)


        for n in range(len(v)):
            vals = v[n]
            #print("\nin getResultString, vals: %s" % vals, file=sys.stderr)
            avg, std, num = self._meanstdv(vals)
            result += " %f %f %d" % (avg, std, num)
            #print("*in getResultString, result[%d]:   %f %f %d" % (n, avg, std, num), file=sys.stderr)
            



        return result













    #########################################################################
    def get_picarro_buffer(device, option):
        """
        Get the buffer from a Picarro analyzer.  Parse lines into averages for
        each field.  Only include data in the average for the species that was
        actually measured to produce the data line.  Use the picarro "species"
        field to indicate which species is current for each line.

        GetPicarroBuffer  time_avg  sp_column  include_water_corrected_data filename GMT return_all

        Options:
            time_avg          Averaging time in seconds.
            sp_column          Index of column in the buffer data containing current species code.
                        First column is 0.  Default is 6.
            water_correction   The water corrected data is included in the Picarro buffer.
                        Default 0 = No, 1 = Yes.
            filename        Print data to file filename.  Default 0 is to stdout
            GMT              Save data on GMT time rather than local time.
                        Default 0 = Local, 1 = GMT  ***NOT WORKING YET
            return_all         Return all the raw data lines rather than the averages.
                        Default 0 = No, 1 = Yes.

        0  GetPicarroBuffer  30  0  0  0

        """

        timeavg = 0
        sp_col = 6  #position after skipping the datetime field is minus one
        gmt = False
        raw_data = False
        water_corrected = False
        return_all = False
        output_file = sys.stdout
        save2file = False

        try:
            vals = option.split()
            timeavg = int(vals[0])
            if len(vals) > 1:
                a = int(vals[1])
                if a > 0:
                    sp_col = a
            if len(vals) > 2:
                a = int(vals[2])
                if a >= 1:
                    water_corrected = True
            if len(vals) > 3:
                a = vals[3]
                if a != "0" and a != "-1":
                    filename = a
                    try:
                        output_file = open(filename, "w")
                        save2file = True
                    except:
                        _error_exit("could not open file %s" % filename)

            if len(vals) > 4:
                a = int(vals[4])
                if a >= 1:
                    gmt = True
            if len(vals) > 5:
                a = int(vals[5])
                if a >= 1:
                    return_all = True

        except ValueError as err:
            self.logger.error(err)
            _error_exit("GetPicarroBuffer error for %s. Incorrect option string '%s'." % (device.name, option))

        sp_col = sp_col - 1  # reset sp_col to minus 1 since the date/time field from the picarro is ignored

        self.logger.info("GetPicarroBuffer %s %s", device.name, option)

        #clear buffer
        device.clear_buffer()

        #clear Picarro buffer and get starttime.
        #Time is the beginning of the measurement averaging window
        lock_interface(device, "LOCK")
        command = "_Meas_ClearBuffer"
        r = device.send_read(command)
        if gmt:
            #***** GMT not working yet, both are on local time
            dt = datetime.datetime.now()
        else:
            dt = datetime.datetime.now()
        self.logger.info("GetPicarroBuffer, Clear buffer returned %s", r)
        lock_interface(device, "UNLOCK")

        #sleep through the averaging period
        time.sleep(timeavg)

        # Get the buffer from the Picarro
        command = "_Meas_GetBuffer"
        lock_interface(device, "LOCK")
        answer = device.send_read_multiline(command)
        lock_interface(device, "UNLOCK")

        result = "%4d %02d %02d %02d %02d %02d" % (dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second)

        if return_all:

            print("Start time:  %s" % (result), file=output_file)
            for line in answer[1:]:
                line = line.lstrip()
                print(line.rstrip(';'), file=output_file)
        else:
            for ii, line in enumerate(answer[1:]): #skip first line containing num of lines
                line = line.rstrip(';') #strip terminating ; from line
                values = [float(x) for x in re.split(';', line.strip())[1:]] #skip date at start of line

                if ii == 0:
                    n = len(values)
                    #n = len(values)
                    v = [[] for x in range(0, n)]

                self.logger.debug("GetPicarroBuffer: %s", line)
                # Only append new data as indicated by the species column
                sp = values[sp_col]
                for i, val in enumerate(values):
                    self.logger.debug("i =  %d ", i)
                    if i <= sp_col:
                        self.logger.debug("prior to species col.  val = %f", val)
                        v[i].append(val)
                    else:
                        # get value of sp_col+sp.  If water_corrected get the next one too.
                        # Will get one of the time fields after H2O when using water corrected
                        # values since there isn't a water corrected H2O field following H2O.
                        if water_corrected:
                            # get value of current species
                            curr_idx = sp_col + ((sp - 1) * 2) + 1
                            curr_idx2 = curr_idx + 1
                            if i == curr_idx or i == curr_idx2:
                                self.logger.debug("getting value of current sp. Val = %f", val)
                                v[i].append(val)
                            else:
                                self.logger.debug("NOT current sp, val = %f", val)
                        else:
                            #get value of [sp_col + sp]
                            if i == (sp_col + sp):
                                self.logger.debug("getting value of current sp.  Val = %f", val)
                                v[i].append(val)
                            else:
                                self.logger.debug("NOT the current sp,  val = %f", val)

            for values in v:
                avg, std, num = _meanstdv(values)
                result += " %f %f %d" % (avg, std, num)

            print(result, file=output_file)
            if save2file: output_file.close()

            self.logger.debug("GetPicarroBuffer result: %s", result)


        sys.stdout.flush()
