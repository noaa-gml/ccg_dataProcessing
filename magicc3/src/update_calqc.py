
"""
Read a magicc-3 qc file and insert the manifold and port settings
into the calibrations_qcdata database table, matching the index
number with what is in the calibrations table.
"""

import sys
import argparse

sys.path.append("/ccg/python/ccglib")
sys.path.append("/ccg/src/python3/nextgen")
import ccg_rawfile
#import ccg_db
import ccg_dbutils


parser = argparse.ArgumentParser(description="Insert manifold and port to database table. ")
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the database.")
parser.add_argument('qcfiles', nargs='*')
options = parser.parse_args()

db = ccg_dbutils.dbUtils("reftank", readonly=False)

for qcfile in options.qcfiles:

    raw = ccg_rawfile.Rawfile(qcfile)
    i = raw.sampleIndices()[0]  # get first SMP line
    row = raw.dataRow(i)

    # get calibration index numbers
    time = "%02d:%02d:%02d" % (raw.adate.hour, raw.adate.minute, raw.adate.second)
    sql = "select idx from calibrations where date='%s' and time='%s' and system='magicc-3'" % (raw.adate.date(), time)
    rtn = db.doquery(query=sql, insert=False)
    #print(rtn)

    for r in rtn:  # multiple gases may have been measured
        cal_idx = r["idx"]
        sql = "insert into calibrations_qcdata set cal_num=%d, manifold='%s', port='%s'" % (cal_idx, row.manifold, int(row.port))
        if options.update:
            db.doquery(query=sql, insert=True)
        else:
            print(sql)

