
"""
Routines for applying selection flags to the co2 hourly average in-situ data
"""

import sys
import datetime

sys.path.insert(1, "/ccg/src/python3/lib")

import ccg_db

########################################################################
def std_check(stacode, date):
	"""
	See if standard deviation is available.
	Minute voltages were stored with
	cams, so that a within hour variability could be computed.
	Data before cams should retain any V flags because those were
	manually applied, and can't be reproduced.

	The _insitu database tables don't exactly correspond with cams
	when std dev was used.
	These dates are for what is in the database tables.
	"""

	cams = 1
	if date.year < 1986: return 0
	if date.year > 1986: return 1
	if stacode == "brw" and date.month < 8: cams = 0
	if stacode == "mlo" and date.month < 7: cams = 0
	if stacode == "smo" and date.month < 8: cams = 0
	if stacode == "spo" and date.month < 2: cams = 0

	return cams



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
def select_co2(stacode, data):
	""" selection (flagging) of co2 in-situ hourly averages.
	Meant to be called from makeavg.py script
	"""


	MAXDIFF = 0.25
	MAXSDEV = 0.30

	# 'data' is a dict of tuples, each tuple has (value, sdev, n, flag, inst_id, intake_height)
	# Extract fields into separate lists
#	co2 = {'year':[], 'month':[], 'day':[], 'hour':[], 'value':[], 'sdev':[], 'n':[], 'flag':[] }
	co2 = {'date':[], 'hour':[], 'value':[], 'sdev':[], 'n':[], 'flag':[]}
	for dt in sorted(data.keys()):
		a = data[dt]

		co2['date'].append(dt)
		co2['hour'].append(dt.hour)
		co2['value'].append(float(a[0]))
		co2['sdev'].append(float(a[1]))
		co2['n'].append(int(a[3]))
		co2['flag'].append(a[4])


	ndata = len(co2['value'])

	# shortcuts
	f = co2['flag']
	v = co2['value']
	sd = co2['sdev']

	#	if co2['code'][0].lower() == "spo": MAXDIFF = 0.15



	for i in range(ndata):
		flag = f[i]

#		print flag, sd[i], co2['date'][i]
		# remove any existing 2nd column flags from file
		# except for pre cams era.  Those flags were manually
		# applied and can't be reproduced, so they should remain
		if std_check(stacode.lower(), co2['date'][i]):
			if flag[1] != "." and sd[i] != 0 and sd[i] > -99:
				flag = flag[0] + "." + flag[2]

		# double check that 9'd out values have a first column flag
		if v[i] < 0 and flag[0] == ".":
			flag = "I" + flag[1:3]


		f[i] = flag


	# apply meteorological flags first

	# for mlo, apply upslope flag
	if stacode.lower() in ["mlo", "mko"]:
		for i, (hour, flag) in enumerate(zip(co2['hour'], f)):
			if (hour >= 21 or hour <= 5) and flag[0:2] == "..":
				f[i] = flag[0] + "U" + flag[2]

	# for spo, apply wind direction flag if met data is available
	if stacode.lower() == "spo":
		date = sorted(data.keys())[0]
		year = date.year
		met = get_metdb("spo", year)
		if len(met) > 0:
			for i, (date, flag) in enumerate(zip(co2['date'], f)):
				if date in met and flag[0:2] == "..":
					(wd, ws) = met[date]
					if 150 < wd < 300:
						f[i] = flag[0] + "W" + flag[2]

	if stacode.lower() == "smo":
		date = sorted(data.keys())[0]
		year = date.year
		met = get_metdb("smo", year)
		if len(met) > 0:
			for i, (date, flag) in enumerate(zip(co2['date'], f)):
				if date in met and flag[0:2] == "..":
					(wd, ws) = met[date]
					if 155 < wd < 310:
						f[i] = flag[0] + "W" + flag[2]

	# apply within hour variability flag
	for i in range(ndata):
		if sd[i] >= MAXSDEV and f[i][1] == ".":
			f[i] = f[i][0] + "V" + f[i][2]

	# flag hour to hour difference
	for i in range(1, ndata):
		if v[i] < 0 or f[i][1] != ".": continue	# skip this hour if missing or already flagged

		# if previous hour is missing, check with 2 hours ago
		k = 1
		if v[i-1] < 0 and i > 1:
			if v[i-2] < 0: continue
			if f[i-2][1] != ".": continue
			k = 2

		# if difference between 2 hours is > MAXDIFF, flag both current and preceeding hour
		diff1 = abs(v[i] - v[i-k])
		if diff1 > MAXDIFF * k:
			f[i] = f[i][0] + 'D' + f[i][2]
			if f[i-k][1] == ".":
				f[i-k] = f[i-k][0] + 'D' + f[i-k][2]

	# check for single hours bracketed by flagged hours
	for i in range(1, ndata-1):
		if f[i][0:2] == ".." and f[i-1][0:2] != ".." and f[i+1][0:2] != "..":
			f[i] = ".S" + f[i][2]


	# check that data has retained data within +/- hour_range hours
	# if not, flag with 'N'
	# meant to catch pairs of unflagged fliers surrounded by flagged data
	hour_range = 8
	z = []
	for i in range(1, ndata):

		# skip if already flagged
		if f[i][0:2] != '..': continue

		# skip if adjacent values on each side are retained.
		if i != ndata-1:
			if f[i-1][0:2] == ".." and f[i+1][0:2] == "..": continue


		# check for retained value in previous hours
		# don't check adjacent value
		left = 0 if i-hour_range < 0 else i-hour_range
		foundleft = False
		for k in range(left, i-1):
			if f[k][0:2] == '..':
				foundleft = True
				break


		# check for retained value in next hours
		# don't check adjacent value
		right = ndata-1 if i+hour_range >= ndata else i+hour_range
		foundright = False
		for k in range(i+2, right+1):
			if f[k][0:2] == '..':
				foundright = True
				break


		if not foundleft and not foundright:
			z.append(i)

	for i in z:
		f[i] = ".N" + f[i][2]


	# check for D flags where the previous 3 hours are unflagged, or the next 3 hours are unflagged
	# change them back to '.'
	# catch D flags on edge of retained data
	z = []
	for i in range(0, ndata):
		if f[i][0:2] != ".D": continue

		leftok = True
		left = 0 if i-3 < 0 else i-3
		for k in range(left, i):
			if f[k][0:2] != '..': leftok = False

		rightok = True
		right = ndata-1 if i+3 >= ndata else i+3
		for k in range(i+1, right+1):
			if f[k][0:2] != '..': rightok = False

		if leftok or rightok: z.append(i)

	for i in z:
		f[i] = ".." + f[i][2]


	#if co2['code'][0].lower() == "brw": brw_select()

#	format = "%3s %4d %02d %02d %02d %8.2f %6.2f %3d %3s"
	newdata = {}
	for i in range(ndata):

		dt = co2['date'][i]

		(val, sdev, unc, n, flag, inst, intake_ht) = data[dt]

		# replace flag with new flag
		flag = co2['flag'][i]

		t = (val, sdev, unc, n, flag, inst, intake_ht)

		newdata[dt] = t

	return newdata
