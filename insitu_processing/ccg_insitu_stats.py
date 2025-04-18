from __future__ import print_function
import numpy

import ccg_utils

#----------------------------------------------------------------------------------------------
def gcstats(isdata, verbose=False):
	""" Print out a table of statistics for gc measurements """

	if isdata.sample_type == "TGT":
		isdata._target_stats(raw, verbose)
		return


	nk = 0
	num = 0
	minratio = 9999.9
	maxratio = 0
	tk_area = [0, 0, 0]
	tk_hite = [0, 0, 0]
	mr_area = []
	mr_hite = []
	prev_sn = None
	prev_start = None
	prev_end = None

	start = None

	for i in isdata.raw.sampleIndices(stype="REF"):
		row = isdata.raw.dataRow(i)

		# bc is either baseline code for gc, or flag for ndir,lgr
		if isdata.system == "GC":
			bcodes = ccg_utils.getBC(isdata.stacode, isdata.species, row.date)
			sn, conc, unc = isdata.refgas.getRefgasByLabel("S1", row.date)
			bc = row.bc
			pa = row.pa
			ph = row.ph
		else:
			bcodes = ['.']
			bc = row.flag
			sn, conc, unc = isdata.refgas.getRefgasByLabel("R0", row.date)
			pa = row.std
			ph = row.value

		if ph == 0 or pa == 0 or bc not in bcodes:
			nk = 0
			tk_area = [0, 0, 0]
			tk_hite = [0, 0, 0]
			continue

		if isdata.useResponseCurves:
			coef = list(isdata.resp.getResponseCoef(row.date))
		else:
			coef = [0, conc, 0]

		# if we changed reference gases, print results and start over
		if sn != prev_sn:
			print_gcstats(isdata, mr_area, mr_hite, prev_start, prev_end, prev_sn, minratio, maxratio, verbose)
			prev_start = row.date
			prev_sn = sn
			nk = 0
			minratio = 9999.9
			maxratio = 0
			tk_area = [0, 0, 0]
			tk_hite = [0, 0, 0]
			mr_area = []
			mr_hite = []

		prev_end = row.date


		tk_area[nk] = pa
		tk_hite[nk] = ph
		ratio = tk_area[nk]/tk_hite[nk]
#		if isdata.debug:
#			print "area, height, ratio", pa, ph, ratio

		if ratio < minratio: minratio = ratio
		if ratio > maxratio: maxratio = ratio

		nk = nk + 1

		if nk == 3:
			avg_area = (tk_area[0] + tk_area[2]) / 2.0
			avg_hite = (tk_hite[0] + tk_hite[2]) / 2.0
			rr_a = tk_area[1]/avg_area
			rr_h = tk_hite[1]/avg_hite
#			mr_a = rr_a * conc
#			mr_h = rr_h * conc
			mr_a = ccg_utils.poly(rr_a, coef)
			mr_h = ccg_utils.poly(rr_h, coef)
			mr_area.append(mr_a)
			mr_hite.append(mr_h)

			if isdata.debug:
				print("date", row.date, "   avg_ref %10.3f" % avg_hite, "   coef", coef, "   height mr %.3f" % mr_h)
#				print "date", adate
#				print "   area, hite", avg_area, avg_hite
#				print "   coef", coef
#				print "   area mr, hite mr", mr_a, mr_h

			tk_area[0] = tk_area[1]
			tk_area[1] = tk_area[2]
			tk_hite[0] = tk_hite[1]
			tk_hite[1] = tk_hite[2]
			nk = 2


	print_gcstats(isdata, mr_area, mr_hite, prev_start, prev_end, prev_sn, minratio, maxratio, verbose)


#----------------------------------------------------------------------------------------------
def print_gcstats(isdata, mr_area, mr_hite, start, adate, sernum, minratio, maxratio, verbose):

	if len(mr_area) == 0: return

	nref = len(mr_area)

	area_mean = numpy.average(mr_area)
	area_sd = numpy.std(mr_area, ddof=1)
	area_pr = area_sd/area_mean * 100
	hite_mean = numpy.average(mr_hite)
	hite_sd = numpy.std(mr_hite, ddof=1)
	hite_pr = hite_sd/hite_mean * 100

	if isdata.system == "GC":
		peaktype = ccg_utils.getPeakType(isdata.system, start, isdata.lcspecies, isdata.defaults)
		ref_label = "S1"
	else:
		peaktype = "height"  # this will match up with correct field for lgr and ndir
		ref_label = "R0"

	sn, conc, unc = isdata.refgas.getRefgasByLabel(ref_label, start)

	if peaktype == "area":
		mean = area_mean
		sd = area_sd
		pr = area_pr
	else:
		mean = hite_mean
		sd = hite_sd
		pr = hite_pr

	inst = isdata.inst.getInstrumentId(start)

	if verbose:

		print("Statistics for %s insitu raw data" % isdata.species)
		print("Reference Tank %s                      :  %s %.2f" % (ref_label, sn, conc))
		print("Analyzer                               : ", inst)
		print("Analytical sequence started            : ", start.strftime("%Y-%m-%d %H:%M:%S"))
		print("Analytical sequence ended              : ", adate.strftime("%Y-%m-%d %H:%M:%S"))
		print()
		print("Total Number of Reference Aliquots     : ", nref)
		if isdata.system == "GC":
			print()
			print("Range of Area/Height Ratios            :     Minimum       Maximum")
			print("                                          %10.3f    %10.3f" % (minratio, maxratio))
			print()
			print("Reference gas statistics               :     Height        Area")
			print("Mole Fraction Mean                     :   %9.3f     %9.3f" % (hite_mean, area_mean))
			print("Standard Deviation                     :   %9.3f     %9.3f" % (hite_sd, area_sd))
			print("Precision (%% of assigned m.f.)         :   %9.3f     %9.3f" % (hite_pr, area_pr))
		else:
			print("Mole Fraction Mean                     :   %9.3f" % (hite_mean))
			print("Standard Deviation                     :   %9.3f" % (hite_sd))
			print("Precision (%% of assigned m.f.)         :   %9.3f" % (hite_pr))

	else:
		fmt = "%s to %s:  %6.3f %6.3f %10s %8.2f %8.3f %8.3f %8.3f %5d %s"
		print(fmt % (start.strftime("%Y-%m-%d %H:%M:%S"), adate.strftime("%Y-%m-%d %H:%M:%S"), minratio, maxratio, sn, conc, mean, sd, pr, nref, inst))



#--------------------------------------------------------------------------
def _target_stats(isdata, raw, verbose):

	maxval = 0
	minval = 9e34

	a = []
	for (sta, dt, mr, mrsd, nv, flag, smptype) in isdata.results:
		if mr < -900: continue
		if mr > maxval: maxval = mr
		if mr < minval: minval = mr
		a.append(mr)

	mean = numpy.average(a)
	sd = numpy.std(a, ddof=1)
	pr = sd/mean * 100
	nref = len(isdata.results)

	start = isdata.results[0][1]
	end = isdata.results[-1][1]
	inst = isdata.inst.getInstrumentId(start)
	sn, conc, unc = isdata.refgas.getRefgasByLabel("TGT", start)

	fmt = "%s to %s:  %6.3f %6.3f %10s %8.2f %8.3f %8.3f %8.3f %5d %s"
	print(fmt % (start.strftime("%Y-%m-%d %H:%M:%S"), end.strftime("%Y-%m-%d %H:%M:%S"), minval, maxval, sn, conc, mean, sd, pr, nref, inst))
