#!/usr/bin/python

# code to upload the standards values to the new DB table

from __future__ import print_function
import sys
import argparse
sys.path.append("/ccg/src/python3/lib")
import os
import MySQLdb
import datetime
import inspect


from ccg_db import dbConnect

UPDATE = False
CHECK = False
now = datetime.datetime.now()
MODDATE = "%04d-%02d-%02d %02d:%02d:%02d" % (now.year, now.month, now.day, now.hour, now.minute, now.second)
SCALE = False
TABLE = "scale_assignments"
DATABASE = "reftank"

#########################################################################

parser = argparse.ArgumentParser(description="upload file of tank assignments to DB table scale_assignments")
group = parser.add_argument_group("Processing Options")
group.add_argument('-f', '--filename', help="text file of tank assignments")
group.add_argument('-s', '--scale', help="scale name - required")
group.add_argument('-c', '--check', help="check for duplicate entries for each fill")
group.add_argument('-u', '--update', help="update the DB table")
group.add_argument('-m', '--moddate', help="modification date to use rather than now()")
group.add_argument('--database', help="database to use, default is reftank. for example --database=cal_scale_tests")
parser.add_argument('args', nargs='*')

options = parser.parse_args()

if not options.filename or not options.scale:
    sys.exit("filename and scale required")

if options.check: CHECK = True
if options.update: UPDATE = True    
if options.database: DATABASE=options.database.lower()
print("database:  %s" % DATABASE)

if options.moddate: MODDATE = options.moddate

verbose = 0

try:
    f = open(options.filename)
except:
    print("Can't open file %s" % fn, file=sys.stderr)
    
db, c = dbConnect(DATABASE)

# get scale_number from scale table
query = "select idx from %s.scales where name like '%s';" % (DATABASE, options.scale)
c.execute(query)
list = c.fetchone()
if not list:
    print("No matching scale found in %s.scales for %s" % (DATABASE, options.scale), file=sys.stderr)
    sys.exit()
scale_num = list[0]
#print >> sys.stderr, scale_num

#if MODDATE:
#   mod_date = MODDATE
#else:
#    now = datetime.datetime.now()
#    mod_date = "%04d-%02d-%02d" % (now.year, now.month, now.day)


for line in f:
    
    line = line.rstrip('\r\n')
    line = line.lstrip()
    
    if line.startswith("#"): continue
    #print >> sys.stderr, " "
    #print >> sys.stderr, line

#SerialNumber fill_code Year Month Day Tzero coef0 Unc0 coef1 Unc1 coef2 Unc2 stddev standard_unc n level # station ID
#CC71638 F 2016 7 19 0 407.2933 0.0087 0 0 0 0 0.0171 0 4 Tertiary # BRW working std W2
#CB09608 B 2016 6 14 0 415.3626 0.0087 0 0 0 0 0.0083 0 4 Tertiary # BRW working std W3

    (info, comment) = line.split("#")
    #(sn, yr, mo, dy, t0, c0, u0, c1, u1, c2, u2, sd_resid, stdunc, level) = info.split()
    #(sn, fill_code, yr, mo, dy, t0, c0, u0, c1, u1, c2, u2, sd_resid, stdunc, n, level) = info.split()   # if includes fill_code and n
    #date = "%s-%02d-%02d" % (yr, int(mo), int(dy))
    (sn, fill_code, date, t0, c0, u0, c1, u1, c2, u2, sd_resid, stdunc, n, level) = info.split()   # if includes fill_code and n
    #(sn, yr, mo, dy, hr, mn, t0, c0, u0, c1, u1, c2, u2, sd_resid, stdunc, n, level) = info.split()   # if no fill code but has hr mn
    #(sn, yr, mo, dy, hr, mn, t0, c0, u0, c1, u1, c2, u2, sd_resid, stdunc, level) = info.split()   # if no fill code but has hr mn, no 'n'
    
    comment += " "

    #time = "%02d:00:00" % (int(hr))

    if CHECK:
        #get fill code from fill_end_dates_view
        query = "SELECT fill_code from fill_end_dates_view where serial_number like '%s' " % sn
        query += "and fill_start_date<='%s' " % date
        query += "and fill_end_date>'%s';" % date
        c.execute(query)
        list = c.fetchone()
        if list:
            fc = list[0]
            if fc.upper() == fill_code.upper(): 
                pass
                print("fill codes match", file=sys.stdout)
            else:
                print("******** FILL CODES DO NOT MATCH, %s on %s: passed fill_code=%s, returned fill_code=%s" % (sn, date, fill_code, fc), file=sys.stderr)
        else:
            print("!!!! No fill code found for %s on %s" % (sn, date), file=sys.stderr)
        
        # see if serial_number / fill code already exists in scale_assignments_view
        query = "SELECT 1 FROM reftank.scale_assignments_view where serial_number like '%s' " % sn
        query += "and scale like '%s' " % SCALE
        query += "and fill_code like '%s' " % fc
        query += "and current_assignment=1;"
        c.execute(query)
        test = c.fetchone()
        #print >> sys.stderr, test
        if test:
            print("******* ASSIGNMENT OF %s %s ALREADY EXISTS ON %s" % (sn, fc, SCALE), file=sys.stderr)
        else:
            pass
            #print >> sys.stderr, "ok to add %s %s to %s" % (sn, fc, SCALE)
    else:
        query = "INSERT INTO %s.%s SET " % (DATABASE, TABLE)
        query += "scale_num = %s, " % scale_num
        query += "serial_number = '%s', " % sn
        
        query += " start_date = '%s' " % date
        query += ", tzero = %9.5f " % float(t0)
        #query += ", tzero = %12.5f " % float(t0)
        query += ", coef0 = %15.6f " % float(c0)
        query += ", unc_c0 = %15.6f " % float(u0)
        query += ", coef1 = %15.6f " % float(c1)
        query += ", unc_c1 = %15.6f " % float(u1)
        query += ", coef2 = %15.6f " % float(c2)
        query += ", unc_c2 = %15.6f " % float(u2)
        query += ", sd_resid = %15.6f " % float(sd_resid)
        query += ", standard_unc = %15.6f " % float(stdunc)
        query += ", level = '%s' " % level
        query += ", n = %d " % int(n)
        if MODDATE:
            query += ", assign_date = '%s' " % MODDATE
        query += ", comment = '%s';" % comment
        

        if UPDATE:
            c.execute(query)
            db.commit()
        else:
            print("%s" % query, file=sys.stdout)


c.close()
db.close()
    
    
