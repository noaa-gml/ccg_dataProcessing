
tankfile = "/home/ccg/ch4cal/sys.tanks"

refgases = {}

f = open(tankfile)
for line in f:
	(type, label, sn, pressure, regulator) = line.split()
	if type not in refgases:
		refgases[type] = []

	t = (label, sn, pressure, regulator)
	refgases[type].append(t)


print(refgases)
