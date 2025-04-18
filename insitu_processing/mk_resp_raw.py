#!/usr/bin/env python
"""
#
# Program mk_resp_raw.py
#
# Customized version for use at the observatories.
# For new system using LGR and Picarro analyzers for CO2,CH4,CO,N2O
#
# Process raw in-situ files, creating new raw files containing only the
# non-linear response cal data.
# These new 'nl' raw files will also contain header information
# so the format is the same as other nl raw files, and can be processed
# using the nlpro.py program.
#
"""
from __future__ import print_function

import sys
import os
import argparse

#sys.path.insert(1, "/ccg/src/python3/lib")

import ccg_rawfile
import ccg_refgasdb
import ccg_insitu_raw
import ccg_instrument


########################################################################
def getRawFileName(gas, site, line):
    """ Get the raw file name base on gas, site and date. """

    if site == "brw":
        dirname = "/ccg/%s/in-situ/%s_data/lgr/nl/%4d/" % (gas.lower(), site.lower(), line.date.year)
    else:
        dirname = "/ccg/%s/in-situ/%s_data/pic/nl/%4d/" % (gas.lower(), site.lower(), line.date.year)
    filename = "%4d-%02d-%02d.%02d%02d.%s" % (line.date.year, line.date.month, line.date.day, line.date.hour, line.date.minute, gas.lower())

    rawfile = dirname + filename

    return rawfile

########################################################################
def getRawHeader(rawfile):
    """ Get header lines from existing raw file. """

    f = open(rawfile)

    header = []
    for line in f:
        header.append(line.strip())
        if line[0:2] == ";+":
            break


    f.close()

    return header

########################################################################
def getHeader(gas, site, data, refdata):
    """ Get the header lines for the raw file.
    If a raw file already exists for the given site, gas and date,
    use the header lines from that file.
    Otherwise, create new header lines.
    """

    row = data[0]
    datestr = row.date.strftime("%Y %m %d %H %M")

    rawfile = getRawFileName(gas, site, row)

    if os.path.exists(rawfile):
        header = getRawHeader(rawfile)
    else:

        tanks = []
        # get list of tank ids used
        for line in data:
            if line.smptype == "REF" or line.smptype == "STD":
                if line.label not in tanks:
                    tanks.append(line.label)

        header = []
        if site.lower() == "brw":
#            sysname = "System:          %s-%s-LGR" % (site.upper(), gas.upper())
            sysname = "System:          LGR"
            systype = "lgr"
        elif site.lower() == "mlo":
#            sysname = "System:          %s-%s-PICARRO" % (site.upper(), gas.upper())
            sysname = "System:          PIC"
            systype = "pic"

        header.append(sysname)

        instru = ccg_instrument.instrument(site, gas, systype)
        inst = instru.getInstrumentId(row.date)


        header.append("Instrument:      %s" % inst)
        header.append("Site:            %s" % site)
        header.append("Date:            %s" % datestr)
        header.append("Start Date:      %s" % datestr)
        header.append("Species:         %s" % gas)
        if site.lower() == "brw":
            header.append("Method:          offaxis-ICOS")
        else:
            header.append("Method:          CRDS")
        for label in tanks:
            (sn, mr, unc) = refdata.getRefgasByLabel(label, row.date)
            header.append("%-17s%s" % (label+":", sn))

        header.append(";+ Start of Data - Do not write below this line!!")


    return header

########################################################################
def updateRawFlags(rawfilename, data):
    """ If a response raw file already exists, check and update the flags
    from that file into the data, i.e. don't overwrite existing flags with
    new non-flags.
    """

    # get raw from the existing raw response file
    raw = ccg_rawfile.Rawfile(rawfilename)

    if raw.numrows != len(data):
        print("Length of data from raw files and response raw file don't match.", rawfilename, file=sys.stderr)
        return

    for i in range(raw.numrows):
        row = raw.dataRow(i)
        if row.flag != data[i].flag:

            # Only '.' and '&' flags can be replaced.
            # If not one of these, keep flag from raw file
            if not row.flag in (".", "&"):
                data[i] = data[i]._replace(flag=row.flag)


########################################################################

update = False
show_names = False

# Get the command-line options

parser = argparse.ArgumentParser(description="Create separate 'response' raw files from the data in the normal in-situ raw files.")
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update existing results with new result.")
parser.add_argument('-n', '--shownames', action="store_true", default=False, help="Print list of raw file names that would be created.")
parser.add_argument('stacode', help="3 letter station code")
parser.add_argument('gas', help="gas being processed")
parser.add_argument('filename', nargs='+')
options = parser.parse_args()

sta = options.stacode.lower()

if sta not in ("brw", "mlo"):
    print("Unknown station code %s." % sta)
    parser.print_usage()
    sys.exit()

gas = options.gas.upper()

if gas not in ("CO2", "CH4", "CO", "N2O"):
    print("Unknown gas type %s." % gas)
    parser.print_usage()
    sys.exit()

files = options.filename
ir = ccg_insitu_raw.InsituRaw(sta, gas, files)

if ir.numrows == 0:
    print("No data found.", file=sys.stderr)
    sys.exit()

# format for raw file data lines
format_ = "%-3s %5s %s %11.5e %9.3e %3d %1s"

# reference gas file containing serial numbers for the different standards
#if sta == "brw":
#    refgasfile = "/ccg/%s/in-situ/%s_data/lgr/refgas.tab" % (gas.lower(), sta)
#elif sta == "mlo":
#    refgasfile = "/ccg/%s/in-situ/%s_data/pic/refgas.tab" % (gas.lower(), sta)
refdata = ccg_refgasdb.refgas(gas, location=sta, use_history_table=True)


start_modenum = 0

data = []
for i in range(ir.numrows):
    row = ir.dataRow(i)
#    print(row)

    # row contains "smptype", "label", "date", "value", "std", "n", "flag", "mode", "bc", "comment"


    # save all mode 2 lines until we switch out of mode 2.  Then process the saved data.
    # Will not process a nl cal that hasn't finished yet by the end of the raw data.
    # Also make sure we switch into mode 2 from another mode so that we don't pick up
    # the second part of a cal at the beginning of the raw data.
    if row['mode'] == 2 and start_modenum != 0:
        if "Line" not in row['label']:        # bug fix for brw lgr
            data.append(row)
    else:
        if row['mode'] != 2: start_modenum = row['mode']
        if len(data) > 0:

            if options.shownames:
                rawfile = getRawFileName(gas, sta, data[0])
                print(rawfile)

            else:

                header = getHeader(gas, sta.upper(), data, refdata)

                # open rawfile for writing if update option passed, otherwise print to stdout
                if options.update:
                    rawfile = getRawFileName(gas, sta, data[0])
                    if os.path.exists(rawfile):
                        updateRawFlags(rawfile, data)

                    try:
                        rf = open(rawfile, "w")
                    except:
                        print("Can't open raw file for writing:", rawfile, file=sys.stderr)
                        sys.exit()

                else:
                    rf = sys.stdout

                for s in header:
                    print(s, file=rf)
                for line in data:
                    print(format_ % (line['smptype'], line['label'], line['date'].strftime("%Y %m %d %H %M %S"), line['value'], line['stdv'], line['n'], line['flag']), file=rf)

                if options.update:
                    rf.close()

            data = []
