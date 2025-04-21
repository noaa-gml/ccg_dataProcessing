"""
# Apply selection flags to ch4 observatory insitu data
"""

import sys
import datetime
import glob
import os

sys.path.insert(1, "/ccg/src/python3/lib")

import ccg_db


########################################################################
def select_ch4(stacode, data):
	"""
	Apply flags to data.
	Criteria are
	mlo:
		If hour of day is <=9 or >= 17 then apply 'C' flag
	brw:
		Flag if current hour wind direction or previous hour wind direction is
		outside of clean air sector (20 to 110 degrees) or
		wind speed is less than 1 m/s
	"""


	newdata = {}

	if stacode.lower() == "mlo":
		for (dt, t) in data.items():
			(mr, mrsd, unc, nv, flag, inst, intake_ht) = t

			flg = flag
			if (dt.hour <= 9 or dt.hour >= 17) and mr > 0:
				flg = flag[0] + "C" + flag[2]

			newdata[dt] = ((mr, mrsd, unc, nv, flg, inst, intake_ht))

	elif stacode.lower() == "brw":

		date = sorted(data.keys())[0]
		year = date.year

		met = get_metdb("brw", year)

		# get any preliminary met text files after the last date of met data from database
		if len(met) == 0:
			newdata = data
		else:
			last_date = max(met.keys())
			prelim_met = get_prelim_met_data("brw", year, last_date)
			met.update(prelim_met)

			for (dt, t) in data.items():
				(mr, mrsd, unc, nv, flag, inst, intake_ht) = t

				flg = flag

				if flg[0] == "." and len(met) > 0:

					if dt in met:
						(wd, ws) = met[dt]
						if wd > -999  and ws > -999:

							prev_hour = dt - datetime.timedelta(hours=1)

							if prev_hour in met:
								(wd1, ws1) = met[prev_hour]
								if wd1 > -999 and ws1 > -999:
									if not ((20 <= wd <= 110) and (20 <= wd1 <= 110) and ws >= 1 and ws1 >= 1):
										flg = flag[0] + 'C' + flag[2]
							else:
								if not (20 <= wd <= 110 and ws >= 1):
									flg = flag[0] + 'C' + flag[2]

				newdata[dt] = ((mr, mrsd, unc, nv, flg, inst, intake_ht))
	else:
		newdata = data


	return newdata


########################################################################
def get_metdb(sta, year):
	""" get met data from database, store in dict with date, hour as key """


	data = {}

	table = "%s_hour" % sta.lower()
	sql = "select date, hour, WD, WS from %s where year(date)=%s order by date, hour" % (table, year)

	result = ccg_db.dbQueryAndFetch(sql, "met")

	for (date, hour, wd, ws) in result:
		dt = datetime.datetime(date.year, date.month, date.day, hour)
		data[dt] = (wd, ws)


	return data

#################################################################
def get_prelim_met_data(code, year, last_date):
	""" get preliminary met data from files instead of database """

	metfiles = get_prelim_met_files(code, year, last_date)

	pdata = {}
	for f in metfiles:
		fp = open(f)
		for line in fp:
			try:
				a = line.split()
			except:
				continue

			yr = int(a[0])
			mon = int(a[1])
			day = int(a[2])
			hour = int(a[3])
			wd = float(a[4])
			ws = float(a[5])

			try:
				dt = datetime.datetime(yr, mon, day, hour)
			except:
				continue

			pdata[dt] = (wd, ws)


		fp.close()


	return pdata

#################################################################
def get_prelim_met_files(code, year, last_date):
	""" Get list of hourly averaged met text files after given last date """


	stanums = {'BRW': '199', 'MLO': '031', 'SMO':'191', 'SPO':'111'}

	met_dir = "/nfs/met/metprime/HOURLY/%s" % (code.upper())
	pattern = "%s/HLY%2d*.%s.txt" % (met_dir, year%100, stanums[code.upper()])


	files = sorted(glob.glob(pattern))

	dateval = (last_date.year%100)*10000 + last_date.month*100 + last_date.day
	metfiles = []
	for f in files:
		name = os.path.basename(f)
		yr = int(name[3:5])
		mn = int(name[5:7])
		dy = int(name[7:9])
		val = yr*10000 + mn*100 + dy

		if val > dateval:
			metfiles.append(f)

	return metfiles
