# vim: tabstop=4 shiftwidth=4 expandtab
"""
function to get text results from a response curve
Input is an nldata class instance
"""


def view_nl_data(nldata):
    """ print out data for the response curve. """

    s = ""
    s += "Analysis Date:       %s\n" % (nldata.adate.strftime("%Y %m %d %H"))
    s += "Analyzer:            %s\n" % (nldata.analyzer_id)
    (sn, mr, sd) = nldata.refgas[nldata.refid]
    s += "Reference:           %s %s %s\n" % (nldata.refid, sn, mr)

    s += "\nResponse Curve Coefficients\n"
    s += "-------------------------------------------------------------\n"
    for c in nldata.results[0]['coeffs']:
        s += "%.6f " % c
    s += "\n"
    s += "Response curve type: %s\n" % nldata.results[0]['function']

    tlist = [(xp, xpsd, yp, ypsd, n, key) for key, (xp, xpsd, yp, ypsd, n) in nldata.avg.items()]

    # sort by ratio
    s += "\nInput Data\n"
    s += "       x      xsd          y      ysd label    sernum     m.f.        resid\n"
    s += "---------------------------------------------------------------------------\n"
    for (xp, xpsd, yp, ypsd, n, label) in sorted(tlist):
        resid = yp - nldata._calc_func(xp, nldata.results[0]['coeffs'])
        sn, mr, sd = nldata.refgas[label]
        s += "%f %f %10.3f %f %4s %10s %8.2f %12.8f\n" % (xp, xpsd, yp, ypsd, label, sn, mr, resid)


#    s += "\nResidual Data\n"
#    s += "-------------------------------------------------------------\n"
#    for (xp, xpsd, yp, ypsd, n, label) in sorted(tlist):
#        resid = yp - nldata._calc_func(xp, nldata.results[0].coeffs)
#        sn, mr, unc = nldata.refgas[label]
#        s += "%.8f %12.8f %4s %10s %.2f\n" % (xp, resid, label, sn, mr)

    return s
