#!/usr/bin/env python
"""
Automatically tag flask data outliers, based on deviation
from a smooth curve

Uses quickfilter module for finding outliers
Outliers will be given a tag number 2 if the --update option is set
"""

import sys
import os
import argparse
import datetime
import numpy
from dateutil.parser import parse

import matplotlib.pyplot as plt
from matplotlib.ticker import (MultipleLocator, AutoMinorLocator)
from matplotlib.dates import YearLocator

sys.path.append("/ccg/python/ccglib")
from ccg_flask_data import FlaskData
from ccg_quickfilter import quickFilter
from ccg_filter_params import filterParameters
import ccg_utils
import ccg_dbutils
import ccg_dates


###################################################################################################
def readinit(filename, site):
    """ Read an initialization file for data extension
    and get the curve fitting parameters
    """

    # get default filter parameter settings
    parameters = filterParameters()

    if filename is None:
        return parameters

    if not os.path.exists(filename):
        print("initfile", filename, "does not exist.", file=sys.stderr)
        return parameters

    lines = ccg_utils.cleanFile(filename)  # remove comments from file

    # skip 3 header lines
    for line in lines[3:]:
        a = line.split()
        if len(a) < 15:
            print("ERROR: Bad formatted init file line - '%s'" % line )
            sys.exit()

        if site.lower() in a[0].lower():
            parameters.npoly = int(a[6])
            parameters.nharm = int(a[7])
            parameters.interval = float(a[8])
            parameters.short_cutoff = float(a[9])
            parameters.long_cutoff = float(a[10])
            parameters.sigmaminus = float(a[13])
            parameters.sigmaplus = float(a[14])
            print(parameters)


    return parameters


#####################################################################
sdate = datetime.datetime(1960, 1, 1)   # default start date of data
edate = datetime.datetime.now()         # default end date of data

epilogtxt = """
Example:
	flsel.py -u mlo co2

    will determine flagged data for the entire mauna loa co2 record, but will update the
    flag field in the database only for data in current year and previous year.
"""

# Get the command-line options
parser = argparse.ArgumentParser(description="Tag the outliers of flask data. Outliers are given tag #2 ", epilog=epilogtxt)
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with tagged data.")
parser.add_argument('-y', '--years', help='Specify range of years of data to use in curve fits. e.g. 1990,2020. Default is to use all years.')
parser.add_argument('--startdate', help='Specify start date of data to use in curve fits. e.g. 1990-11-15. End date is current date.')
parser.add_argument('--flagall', action="store_true", default=False, help='Flag all years of data.  Default is current year and previous year only.')
parser.add_argument('--initfile', help='Specify init file for curve fitting parameters')
parser.add_argument('--flagyears', help='Specify non-default years to flag.  Comma separated list of years.')
parser.add_argument('--plot', action="store_true", default=False, help='Plot data showing automatically selected data in different symbol.')
parser.add_argument('gas', help="Gas formula, e.g. CO2")
parser.add_argument('stacode', nargs='*', help="station codes to process")

options = parser.parse_args()

gas = options.gas


# check for dates of data to use
if options.years:
    lst = options.years.split(",")
    if len(lst) != 2:
        print("Error in year argument.", file=sys.stderr)
        parser.print_usage()
        sys.exit()
    startyear = int(lst[0])
    endyear = int(lst[1])
    sdate = datetime.datetime(startyear, 1, 1)
    edate = datetime.datetime(endyear+1, 1, 1)
elif options.startdate:
    sdate = parse(options.startdate)

# comma separated list of station codes to skip flagging
skipcodes = ['BLD','TST','MSC','POC','TNK','CEI']
skipstr = ",".join(("'" + item + "'" for item in skipcodes))  # create string with ' around codes

now = datetime.datetime.now()

if len(options.stacode) == 0:

    # get sites that have samples in previous year
    year = now.year
    year = year - 1

    db = ccg_dbutils.dbUtils()

    # get list of sites from database
    sql="select distinct code from flask_event,gmd.site where year(date)=%s and flask_event.site_num=gmd.site.num and flask_event.project_num=1 and code not in (%s) order by code;" % (year, skipstr)
    result = db.doquery(sql)

    sitelist = [row['code'] for row in result]

else:
    sitelist = options.stacode


# loop through all sites and do flask selection
for site in sitelist:

    print("\n*************************************************************\n")
    print(site.upper(), gas.upper())


    # get curve fit parameters for this site
    parameters = readinit(options.initfile, site)

    # only surface flasks can be selected
    projnum = 1

    # get flask data from database
    f = FlaskData(gas, site)
    f.setRange(start=sdate, end=edate)
    f.setProject(projnum)
    f.setStrategy(True, False)  # don't use pfp samples
    f.setPrograms(1)
    f.includeFlaggedData()
    data = f.run(as_arrays=True)

    if data:
        # set years to apply flags to
        flag_year = [now.year-1, now.year]
        if options.flagall:
            syear = data['date'][0].year
            eyear = data['date'][-1].year
            flag_year = range(syear, eyear+1)

        elif options.flagyears:
            lst = options.flagyears.split(",")
            flag_year = [int(year) for year in lst]


        # flagged = 0  use data in curve fit
        # flagged  != 0 don't use data in curve fit, keep existing flag
        # flagged = 1 will mean flag was automatically applied

        npoints = len(data['qcflag'])
        flagged = numpy.zeros(npoints)
        for i, flg in enumerate(data['qcflag']):
            # keep non X flags for all years
            if flg[1] not in ['.', 'X']:
                flagged[i] = 3

            # keep X flags for the non flag_years
            if flg[1] == 'X' and data['date'][i].year not in flag_year:
                flagged[i] = 3

        # now do the selection using quickFilter module
        qf = quickFilter(data['time_decimal'], data['value'], flagged)
        qf.setFlagYears(flag_year)
        qf.params = parameters
        qf.run()

        print(qf.summaryText)

        fmt2 = "  Data number %9d Changed event %7s %10s %10s %1s %8.2f -> %s"
        if options.update:
            print("\nUpdate tags in database")
            print("====================================================")
            for i in range(npoints):
                # any flags == 1 should have a tag number 2 set
                if qf.flags[i] == 1 and data['date'][i].year in flag_year:

                    ccg_utils.addTagNumberToDatanum(2, data['data_number'][i], mode=2, verbose=False, update=True)

                    print(fmt2 % (
                        data['data_number'][i],
                        data['event_number'][i],
                        data['date'][i],
                        data['flaskid'][i],
                        data['method'][i],
                        data['value'][i], 'Add tag #2: .X.'))

        if options.plot:

            # rejected data
            w = numpy.where(qf.flags == -1)
            xb = data['date'][w]
            yb = data['value'][w]

            # non flagged data
            w = numpy.where(qf.flags == 0)
            x = data['date'][w]
            y = data['value'][w]

            # auto flagged data
            w = numpy.where(qf.flags == 1)
            xnf = data['date'][w]
            ynf = data['value'][w]

            # out of range data
            w = numpy.where(qf.flags == 2)
            xnf2 = data['date'][w]
            ynf2 = data['value'][w]

            # already flagged data
            w = numpy.where(qf.flags == 3)
            xf = data['date'][w]
            yf = data['value'][w]


            xi = [ccg_dates.datetimeFromDecimalDate(dt) for dt in qf.filt.xinterp]
            yi = qf.filt.getSmoothValue(qf.filt.xinterp)

            sigma3plus = parameters.sigmaplus * qf.filt.rsd2
            sigma3minus = parameters.sigmaminus * qf.filt.rsd2
            y1plus3 = yi + sigma3plus
            y1minus3 = yi - sigma3minus

            fig = plt.figure(figsize=(11,7))
            fig.subplots_adjust(left=0.08, right=0.96, bottom=0.08, top=0.93)

            plt.plot(xi, yi, color='#00c800', linewidth=0.5)
            plt.plot(xi, y1plus3, color='#00c8c8', linewidth=0.5)
            plt.plot(xi, y1minus3,color='#00c8c8', linewidth=0.5)

            plt.plot(x, y, marker='o', markerfacecolor='#0066ff', markeredgecolor='#000000', linestyle='none', markersize=4, markeredgewidth=0.3, label="Data")
            plt.plot(xf, yf, marker='o', markerfacecolor='#ff0000', markeredgecolor='#000000', linestyle='none', markersize=4, markeredgewidth=0.3, label="Flagged Data")
            plt.plot(xnf, ynf, marker='s', markerfacecolor='#ffff00', markeredgecolor='#000000', linestyle='none', markersize=4, markeredgewidth=0.3, label="New Flagged Data")

            plt.title("%s %s" % (site.upper(), gas.upper()))
            plt.legend()
            ax = plt.gca()
            ax.xaxis.set_minor_locator(YearLocator(1))
            ax.yaxis.set_minor_locator(MultipleLocator(5))
            plt.show()
