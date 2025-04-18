# vim: tabstop=4 shiftwidth=4
"""
Class for dealing with ResponseCurves.xxx files (where xxx is gas, e.g. 'co2'),
which have instrument response data for the gas.  Lines in these files look
something like

 PC2 2019 10 08 09 44           2.43330519        1908.06679254           0.00000000    0.06606    11 poly Ref_Divide 2019-10-07.1654.ch4
 PC2 2019 10 22 09 16           2.44015878        1908.04697557           0.00000000    0.06002    11 poly Ref_Divide 2019-10-21.1634.ch4

Fields are
    instrument id, year, month, day, hour, minute coef0, coef1, coef2, rsd, n, function type, operator type, raw file
"""
from __future__ import print_function

import datetime
from collections import namedtuple

import ccg_utils

##################################################################
def getResponseValue(x, result):
	""" Calculate response curve value at given point """

	coeffs = result.coeffs
	functype = result.functype

	if functype == "power":
		mr = ccg_utils.power(x, coeffs)
	else:
		mr = ccg_utils.poly(x, coeffs)

	return mr

##################################################################
def getResponseResultString(result):
	"""
	Generate a nicely formatted string from the response data in the tuple 'result'.
	'result' is a namedtuple created from ccg_nl.py module
	"""

	# new style format that has function name in result
	if "poly" in result or "power" in result:
		cstr = " ".join(["%20.8f" % c for c in result.coeffs])
		frmt = "%4s %s %s %9.5f %5d %s %s %s"
		s = frmt % (result.analyzer_id,
					result.date.strftime("%Y %m %d %H %M"),
					cstr, result.rsd, result.n, result.functype, result.ref_op, result.rawfile)

# this may not be needed anymore.  All repsonse curve files have a function type entry now
	else:
		cstr = " ".join(["%9.4f" % c for c in result.coeffs])
		frmt = "%4s %s %s %7.3f %5d  %s"
		s = frmt % (result.analyzer_id,
					result.date.strftime("%Y %m %d %H %M"),
					cstr, result.rsd, result.n, result.rawfile)

	return s


##################################################################
class ResponseFile():
	"""
	Usage:
	    resp = ccg_refsponse_table.ResponseFile(filename, inst_id, enddate)

	Input arguments:
	    filename - response curve filename (required)
	    inst_id - instrument id. Retrieve only lines from file that match id
	    enddate - Retrieve only lines that come before this date

	Members:
	    data - List of namedtuples with repsonse data for all the lines that matched. Each tuple has
			(analyzer_id, date, coeffs, rsd, n, functype, ref_op, rawfile)
	    last_response - Single namedtuple of data for the last response from the file, matching inst_id
			and enddate if requested.  This is usually what is needed.
	    hasResponseCurves - Boolean if response curve data is available

	"""

	#---------------------------------------------------
	def __init__(self, response_file, inst_id=None, startdate=None, enddate=None):

		self.all_entries = []
		self.responsefile = response_file
		self.hasResponseCurves = False

		self.inst_id = inst_id
		self.enddate = enddate
		self.startdate = startdate

		self.Result = namedtuple('response', ['analyzer_id', 'date', 'coeffs', 'rsd', 'n', 'functype', 'ref_op', 'rawfile'])

		self.all_entries, self.data = self._read_response_file(response_file)

		self.last_response = None
		if self.data:
			self.last_response = self.data[-1]
			self.hasResponseCurves = True

	#---------------------------------------------------
	def _read_response_file(self, respfile):
		""" Read a response file, keep entries that are <= enddate for the given instrument id,
		or all entries if neither inst_id or enddate is given.
		Save entries in a list of tuples, each tuple has
		(inst, date, coeffs, rsd, n, file)
		These tuple entries must be same as the results from compute_nl()
		 """

		a = ccg_utils.cleanFile(respfile)
		if not a:
			return [], []

		tmplist = []
		all_entries = []
		for line in a:

			# this version assumes that the file has all fields.
			fields = line.split()
			nfields = len(fields)
			ncoeff = nfields - 11  # normally 3, can be more
			(rsd, n, funcname, ref_op, filename) = fields[-5:]
			(inst, yr, mo, dy, hr, mn) = fields[0:6]
			coeffs = [float(c) for c in fields[6:6+ncoeff]]

			date = datetime.datetime(int(yr), int(mo), int(dy), int(hr), int(mn))
			rsd = float(rsd)
			n = int(n)

			t = self.make_result((inst, date, coeffs, rsd, n, funcname, ref_op, filename))

			all_entries.append(t)

			# skip entries where instrument id's don't match
			if self.inst_id and self.inst_id.upper() != t.analyzer_id.upper(): continue

			# don't keep curves before the start date
			if self.startdate and t.date < self.startdate: continue

			# don't keep curves after the end date
			if self.enddate and t.date > self.enddate: continue

			tmplist.append(t)

		# sort by instrument id, date
		tmplist.sort()

		return all_entries, tmplist

	#---------------------------------------------------
	def make_result(self, t):
		""" Create a result namedtuple from the regular tuple 't' """

		return self.Result._make(t)

	#---------------------------------------------------
	def getResponseCoef(self, date):
		""" Find first response line before or equal to the given date """

		# loop backwards through the response data
		for r in self.data[::-1]:
			if self.inst_id:
				if self.inst_id == r.analyzer_id and r.date <= date:
					return r.coeffs

			else:
				if r.date <= date:
					return r.coeffs

		# return the first response data by default
		return self.data[0].coeffs

	#---------------------------------------------------
	def findResponse(self, date):
		""" Find first response line before or equal to the given date """

		# loop backwards through the response data
		for r in self.data[::-1]:
			if self.inst_id:
				if self.inst_id == r.analyzer_id and r.date <= date:
					return r

			else:
				if r.date <= date:
					return r

		# return the first response data by default
		return self.data[0]


	#---------------------------------------------------
	def getCoeffs(self, resp=None):
		""" Get the coefficients of the response curve.
		If resp is not set, use the last_response data.
		"""

		if resp:
			coeffs = resp.coeffs
		else:
			coeffs = self.last_response.coeffs

		return coeffs

	#---------------------------------------------------
	def getFunction(self, resp=None):
		""" Get the function used for the response curve.
		If resp is not set, use the last_response data.
		"""

		if resp:
			func = resp.functype
		else:
			func = self.last_response.functype

		return func

	#---------------------------------------------------
	def getOperator(self, resp=None):
		""" Get the operator used for the response curve.
		If resp is not set, use the last_response data.
		"""

		if resp:
			oper = resp.ref_op
		else:
			oper = self.last_response.ref_op

		return oper

	#---------------------------------------------------
	def getAdate(self, resp=None):
		""" Get the analysis date used for the response curve.
		If resp is not set, use the last_response data.
		"""

		if resp:
			adate = resp.date
		else:
			adate = self.last_response.date

		return adate

	#--------------------------------------------------------------------------
	def getResponseValue(self, sample_value, ref_value, resp=None):
		""" Calculate response curve value at given point """

		coeffs = self.getCoeffs(resp)
		functype = self.getFunction(resp)
		ref_op = self.getOperator(resp)

		rr = -999.99
		if ref_op == "Ref_Divide":
			rr = sample_value / ref_value
		elif ref_op == "Ref_Subtract":
			rr = sample_value - ref_value
		elif ref_op == "Ref_None":
			rr = sample_value
		else:
			raise ValueError("Unknown ref_op:  %s" % ref_op)

		if functype == "poly":
			value = ccg_utils.poly(rr, coeffs)
		elif functype == "power":
			value = ccg_utils.power(rr, coeffs)
		else:
			raise ValueError("Unknown function type: %s" % functype)

		return value, rr

	#--------------------------------------------------------------------------
	def checkDb(self, result):
		""" Check if result string is in response file, and show existing and new strings. """

		match_idx = self._find_match(result, usedate=True)

		if match_idx is not None:
			t = self.all_entries[match_idx]
			print("Existing data: ", getResponseResultString(t))
			print("New data:      ", getResponseResultString(result))
		else:
			print(getResponseResultString(result), " not found.")

	#--------------------------------------------------------------------------
	def updateDb(self, results):
		""" Update the response curve file with calculated results """

		# first remove any entries that have the same instrument and raw file name
		for result in results:
			match_idx = self._find_match(result, usedate=False)
			if match_idx is not None:
				del self.all_entries[match_idx]

		self.all_entries.extend(results)

		self._write_to_file()

	#--------------------------------------------------------------------------
	def deleteDb(self, result):
		""" Delete the result from the response curve file """

		# delete any existing entries where instrument id and raw file name match result
		del_idx = self._find_match(result, usedate=True)

		if del_idx:
			del self.all_entries[del_idx]
			self._write_to_file()

	#--------------------------------------------------------------------------
	def _find_match(self, result, usedate=True):
		""" Find a match for 'result' in the response file
		A match is where instrument id and analysis date and time
		parts of the filenames agree.
		'result' is a namedtuple created in ccg_nl.py
		"""

		for i, t in enumerate(self.all_entries):
			# date and time are first two parts of filename separated by '.'
			a = t.rawfile.split(".")
			b = result.rawfile.split(".")
			#    date              time                     inst
			if usedate:
				if a[0] == b[0] and a[1] == b[1] and result.analyzer_id == t.analyzer_id and result.date == t.date:
					return i
			else:
				if a[0] == b[0] and a[1] == b[1] and result.analyzer_id == t.analyzer_id:
					return i

		return None

	#--------------------------------------------------------------------------
	def _write_to_file(self):
		""" write the updated entries to file """

		f = open(self.responsefile, "w")
		for t in sorted(self.all_entries):
			print(getResponseResultString(t), file=f)
		f.close()
