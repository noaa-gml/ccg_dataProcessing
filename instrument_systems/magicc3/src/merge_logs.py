#!/usr/bin/python

import os
import sys
import datetime
import time
#import MySQLdb
#import pymysql as mysql
import pymysql as MySQLdb
import multiprocessing
import subprocess

from operator import itemgetter

import config
sys.path.append("%s/src" % config.HOMEDIR)
sys.path.append("%s/src/hm" % config.HOMEDIR)

from common import *
from runaction import *
import utils


from collections import deque
from statistics import median, mean


## open connection to database file that has the sample information
#from magiccdb import *
#db_filename = 'magicc.db'
## db_filename = config.databasefile # could put this in config.py instead
#magiccdb = magiccDB(db_filename)



## Create a RunAction class instance to use in all the modes
#action = RunAction(actiondir=config.ACTIONDIR, configfile=config.CONFFILE, testMode=config.testmode)


print("start of test code", file = sys.stderr)

#hmlog = "/home/magicc/sys.log"
#magicclog = "/home/magicc/magicc.log"
hmlog = "/home/magicc/tmp_sys.log"
magicclog = "/home/magicc/tmp_magicc.log"

print("hmlog:  %s" % hmlog, file=sys.stderr)
print("magicclog: %s" % magicclog, file=sys.stderr)


f = open(hmlog, "r")
hm_lines = f.readlines()
f.close()

f = open(magicclog, "r")
magicc_lines = f.readlines()
f.close()


merged_lines = []
for line in magicc_lines:
    (level, j, d, t, text) = line.split(None,4)
    #print("%s %s" % (d,t))
    (yr, mo, dy) = d.split('-')
    (hr,mn,sc) = t.split(':')
    sc = sc.replace(',','.')
    iso_format = "%s-%02d-%02d %02d:%02d:%06.3f" % (yr, int(mo), int(dy), int(hr), int(mn), float(sc))
    #print(iso_format)
   
    dt = datetime.datetime.fromisoformat(iso_format)
    new_line = {"source":"MAGICC.LOG", "dt":dt, "line":line.rstrip()}
    #print(new_line)
    merged_lines.append(new_line)


new_hm_lines = []
for line in hm_lines:
    #print(line)
    test_split = line.split()
    if len(test_split) < 2: continue
    (level, j, d, t, text) = line.split(None,4)
    if level.upper() not in ['INFO','DEBUG', 'ERROR']: continue
    #print("%s %s" % (d,t))
    (yr, mo, dy) = d.split('-')
    (hr,mn,sc) = t.split(':')
    sc = sc.replace(',','.')
    iso_format = "%s-%02d-%02d %02d:%02d:%06.3f" % (yr, int(mo), int(dy), int(hr), int(mn), float(sc))
    #print(iso_format)
   
    dt = datetime.datetime.fromisoformat(iso_format)
    new_line = {"source":"SYS.LOG", "dt":dt, "line":line.rstrip()}
    #print(new_line)
    merged_lines.append(new_line)

merged_data = sorted(merged_lines, key=itemgetter('dt','source'))

for n, data in enumerate(merged_data):
    if data["source"].upper() == "MAGICC.LOG":
        print(data["source"], " - ",  data["line"])
    else:
        print("         ", data["source"], " - ",  data["line"])




print("end of test code", file = sys.stderr)
