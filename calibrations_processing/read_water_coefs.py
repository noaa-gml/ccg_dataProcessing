import os
import sys
import argparse
from dateutil.parser import parse

sys.path.append("/ccg/src/python3/nextgen")

import pic_h2o_corr
import ccg_dbutils

#filename = "/home/ccg/aircraft/picarro/CFKBDS2302/CFKBDS2302_20200827_water/CFKBDS2302_20200827_water_corr_coefs.txt"


pnums = {'CO2': 1, 'CH4': 2, 'CO': 3}

parser = argparse.ArgumentParser(description="Process picarro water correction raw files. ")
parser.add_argument('-c', '--check', action="store_true", default=False, help="Compare calculated values with those in database.")
parser.add_argument('-u', '--update', action="store_true", default=False, help="Update the database with values from file.")
parser.add_argument('files', nargs='+', help="raw files to process")
options = parser.parse_args()

db = ccg_dbutils.dbUtils("ccgg")

for filename in options.files:
    a = os.path.basename(filename).split("_")
    sernum = a[0]
    date = parse(a[1][0:8])

    print(sernum, date)

    query = f"select id from inst_description where serial_number like '%{sernum}%'"
    result = db.doquery(query)
    if result is None:
        print("ERROR: Instrument id not found for", sernum)
        continue
    else:
        inst_id = result[0]['id']

    results = []

    f = open(filename)
    for line in f:
        if line.startswith("#"): continue
        a = line.strip().split(",")
        if a[0] == "spp": continue

        gas = a[0]
        if gas == 'peak84': continue
        paramnum = pnums[gas.upper()]
        r = db.getCurrentScale(gas)
        scalenum = r['idx']

        coef0 = float(a[1])
        coef1 = float(a[2])
        coef2 = float(a[3])
        if a[4] == "nan":
            coef3 = 0
        else:
            coef3 = float(a[4])

        result = {
                    'gas': gas,
                    'parameter_num': paramnum,
                    'scale_num': scalenum,
                    'inst_id': inst_id,
                    'analysis_date': date,
                    'coef0': coef0,
                    'coef1': coef1,
                    'coef2': coef2,
                    'coef3': coef3,
                    'flag': '.',
                    'filename': os.path.basename(filename),
                }

        results.append(result)


    if options.check or options.update:
        h2ocorr = pic_h2o_corr.WaterCorrectionDb(results[0]['gas'], results[0]['inst_id'])

        if options.check:
            h2ocorr.checkDb(results)

        elif options.update:
            h2ocorr.updateDb(results)

    else:
        for row in results:
            s = pic_h2o_corr.getCorrResultString(row)
            print(s)
