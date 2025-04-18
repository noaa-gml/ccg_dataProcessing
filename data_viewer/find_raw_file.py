# vim: tabstop=4 shiftwidth=4 expandtab
"""
function to find the name (including path) of a flask qc file
given the gas, system name, analysis date and event number.

Returns the qc file name if found, or 'None' if not found.
"""

import datetime
import glob

import ccg_rawfile
from common.utils import get_path


#########################################################################
def findRawFile(gas, system, date, event, filetype="raw"):
    """ Find the qc or raw file name and directory for the selected flask.
        Because the flask_data entry in the database doesn't have the
        start time of a raw file, only the analysis date and time,
        we need to search the directory to make sure we have the right file.
        We then need to search through the possible raw files to find the
        event number in the file, and return that raw file name.

    Input:
        gas - gas formula string, e.g. 'CO2'
        system - analysis system name, e.g. 'magicc-1'
        date - date object of analysis date for the flask
        event - event number for the flask

    Output:
        Return the raw file name containing the flask analysis, or
        return 'None' if not found.
    """

    # Directory should be easy, unless analysis started on Dec 31 and flask analyzed on Jan 1
    # Check both flask and aircraft directories

    dir1 = "/ccg/%s/flask/%s/%s/%d" % (gas.lower(), system, filetype, date.year)
    dir1 = get_path(dir1)

    # Check files on same analysis day and 1 day before
    date1 = date
    tdelta = datetime.timedelta(days=1)
    date2 = date1 - tdelta

    if filetype == "raw":
        pattern1 = "%s/%s.*.%s" % (dir1, date1.strftime("%Y-%m-%d"), gas.lower())
        pattern2 = "%s/%s.*.%s" % (dir1, date2.strftime("%Y-%m-%d"), gas.lower())
    else:
        pattern1 = "%s/%s.*.qc" % (dir1, date1.strftime("%Y-%m-%d"))
        pattern2 = "%s/%s.*.qc" % (dir1, date2.strftime("%Y-%m-%d"))

    filelist = []
    filelist.extend(glob.glob(pattern1))
    filelist.extend(glob.glob(pattern2))

    # another check, if analysis date is jan 1, check if its in dec 31 of previous year raw file
    if date.month == 1 and date.day == 1:
        dir1 = "/ccg/%s/flask/%s/%s/%d" % (gas.lower(), system, filetype, date.year-1)
        if filetype == "raw":
            # flask dec 31 previous year
            pattern5 = "%s/%d-%02d-%02d.*.%s" % (dir1, date.year-1, 12, 31, gas.lower())
        else:
            # flask dec 31 previous year
            pattern5 = "%s/%d-%02d-%02d.*.qc" % (dir1, date.year-1, 12, 31)

        pattern5 = get_path(pattern5)
        filelist.extend(glob.glob(pattern5))

#    print filelist

    # Check that event number is in the raw file
    for filename in filelist:

        flraw = ccg_rawfile.Rawfile(filename)
        if not flraw.valid: continue

        if event in flraw.getSampleEvents():
            return filename

    # If we get here, the event number wasn't found in file
    return None


if __name__ == "__main__":

    eventnum = 469806
    systemname = 'magicc-3'
    gasname = 'CO2'
    adate = datetime.date(2020, 2, 6)

    rawfile = findRawFile(gasname, systemname, adate, eventnum)
    print(rawfile)
    rawfile = findRawFile(gasname, systemname, adate, eventnum, "qc")
    print(rawfile)
