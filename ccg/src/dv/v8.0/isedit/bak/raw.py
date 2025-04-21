# vim: tabstop=4 shiftwidth=4 expandtab
"""
Routines for dealing with 'raw' data files.
"""

import glob
import numpy

import ccg_insitu_raw

#############################################################
def read_raw(species, code, year, month, system):
    """ read raw files to get voltage data """


    # Get a list of all files for the month
    if system == "LGR":
        rawdir = "/ccg/%s/in-situ/%s_data/lgr/raw/%s/%d-%02d-*.%s" % (species, code, year, year, month, species)
    elif system == "PICARRO":
        rawdir = "/ccg/%s/in-situ/%s_data/pic/raw/%s/%d-%02d-*.%s" % (species, code, year, year, month, species)
    else:
        rawdir = "/ccg/%s/in-situ/%s_data/raw/%s/%d-%02d-*.%s" % (species, code, year, year, month, species)

    files = sorted(glob.glob(rawdir))

    if len(files) > 0:

        # read in the raw files and add to a list of raw data
#        print files
        ir = ccg_insitu_raw.InsituRaw(code, species, files, system=system)
        return ir

    return None

#################################################################
def updateRawFiles(parent, gas, code, changes):
    """
    Given a list of 'changes', update the raw file, replacing the
    fields in the raw file with those in 'changes'.
    """

    tyr = 0
    tmon = 0
    tdy = 0
    filename = None
    ir = None

    for (date, value, unc, num, label, newflag) in changes:

        # If new day, write previous day's raw data back to file
        # and read in new day of raw data
        if date.year != tyr or date.month != tmon or date.day != tdy:

            # If we read in a day of raw data, write it back
            if filename is not None:
                ir.update(filename, backup=True)

            filename = "/ccg/%s/in-situ/%s_data/raw/%d/%4d-%02d-%02d.%s" % (gas.lower(), code.lower(), date.year, date.year, date.month, date.day, gas)
            ir = ccg_insitu_raw.InsituRaw(code, gas, filename)

        w = numpy.where((ir.T[2] == date) & (ir.T[1] == label))
        ir.data[w][3] = value
        ir.data[w][4] = unc
        ir.data[w][5] = num
        ir.data[w][6] = newflag

        tyr = date.year
        tmon = date.month
        tdy = date.day


    if filename is not None:
        ir.update(filename, backup=True)

    return 0
