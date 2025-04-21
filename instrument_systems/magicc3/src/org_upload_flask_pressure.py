#!/usr/bin/python
"""
#
# Program upload_flask_pressure.py
#
# code to put flask initial and final pressures into DB table ccgg.flask_analysis
# Use for magicc-3 data only.  Reads the magicc-3_qc files located in /ccg/magicc-3_qc
# Only for flask and pfp samples
#
"""
import sys
sys.path.append("/ccg/src/python/")
import os
import getopt
import MySQLdb
import datetime

from db import *

UPDATE = False
TABLE = "ccgg.flask_analysis"

########################################################################
def usage():
    print """
Usage:
  upload_flask_pressure.py
  
  [-u] magicc-3 system qc file

 where 
    -f - file to import
    -u - update 
        -h - print a help message

 No options means print out result strings to stdout.
"""

# Get the command-line options
try:
    opts, args = getopt.getopt(sys.argv[1:], "hvuf:" )
except getopt.GetoptError, err:
    # print help information and exit:
    print str(err) # will print something like "option -a not recognized"
    usage()
    sys.exit()

for o, a in opts:
        if o == "-v": debug = True
    elif o == "-u": UPDATE = True
    elif o == "-f": fn = a
    elif o in ("-h", "--help"):
        usage()
        sys.exit()
    else:
        assert False, "unhandled option"

verbose = 0

try:
    f = open(fn)
except:
    print >> sys.stderr, "Can't open file", fn
    
if UPDATE:
    db = dbConnect("ccgg")
    c = db.cursor()

header = True

for line in f:
    line = line.rstrip('\r\n')
    line = line.lstrip()
    if line.startswith("#"): continue
    
        if header:
            if line.startswith(';+'):
                header = False
            else:
                (key, value) = line.split(':', 1)
                if key.upper() == "SYSTEM": system = value.strip()
        else:        
            
            vals = line.split()
            
            if vals[0].upper() == "SMP":
                startdate = datetime.datetime(int(vals[2]), int(vals[3]), int(vals[4]), int(vals[5]), int(vals[6]), int(vals[7]))
                cycle_time = datetime.timedelta(seconds=int(vals[10]))
                enddate = startdate + cycle_time
        
                query = "INSERT INTO %s SET " % TABLE
                query += " event_num = '%s', " % vals[1]
                query += " system = '%s', " % system
                query += " start_datetime = '%s', " % startdate.isoformat().replace('T',' ')
                query += " end_datetime = '%s', " % enddate.isoformat().replace('T',' ')
                query += " initial_flask_press = %6.2f, " % float(vals[11])
                query += " final_flask_press = %6.2f, " % float(vals[12])
                query += " manifold = '%s', " % vals[8]
                query += " port = '%s';" % vals[9]
        
                if UPDATE:
                    c.execute(query)
                    db.commit()
        
                else:
                    print >> sys.stderr, "%s" % query

if UPDATE:
    c.close()
    db.close()
    
    
