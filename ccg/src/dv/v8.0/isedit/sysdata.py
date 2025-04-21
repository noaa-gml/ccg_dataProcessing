# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for containing routines and information for different
insitu systems for isedit

Meant to be subclassed for each particular system, which will
contain specific routines for getting data.

This class contains routines that are common to all systems.
such as mole fractions, temperatures ...
"""

import os
import datetime
import calendar
import glob
from collections import defaultdict

from common.utils import get_path

import ccg_insitu_data2
import ccg_db_conn
import ccg_utils
import ccg_nl
#import ccg_insitu_files_mac as ccg_insitu_files
import ccg_insitu_files
import ccg_insitu


class sysdata:
    """ class for handling generic system data
    Specific systems are a subclass of this one, but methods
    common to all systems are here.
    """

    def __init__(self, code, gas, year, month, system):

        self.gas = gas.lower()
        self.code = code.lower()
        self.year = year
        self.month = month
        self.system = system
        self.nlfiles = None  # this will be set in subclasses

        (a, self.daysinmonth) = calendar.monthrange(self.year, self.month)
        self.startdate = "%d-%d-%d" % (self.year, self.month, 1)
        self.enddate = "%d-%d-%d" % (self.year, self.month, self.daysinmonth)
        self.firstday = datetime.datetime(self.year, self.month, 1)
        self.lastday = datetime.datetime(self.year, self.month, self.daysinmonth) + datetime.timedelta(days=1)

        self.hour_table = "%s_%s_hour" % (self.code, self.gas)

        if "GC" in self.system.upper():
            # Open the defaults file, which specifies which
            # peak type to use when calculating mixing ratios.
            self.defaults = ccg_utils.getDefaults(code, gas)

            self.choices = [
                "Mole Fractions",
                "Avg. Signals",
                "Raw Signal",
                "Inlet Line Difference",
                "Wind Direction",
                "Wind Speed",
                "Pressure",
                "Ambient Temperature",
                "Flagged Hourly Averages",
                "Sample PH",
                "Sample PA",
                "Sample PH/PA",
                "Sample RT",
                "Ref PH",
                "Ref PA",
                "Ref PH/PA",
                "Ref RT",
                ]

        else:
            self.choices = [
                "Mole Fractions",
                "Std. Dev.",
                "Measurement Uncertainty",
                "Random Uncertainty",
                "Avg. Signals",
                "Avg. Signals StdDev",
                "Raw Signal",
                "Inlet Line Difference",
#                "Response Curve",
                "Response Curve Residuals",
                "Wind Direction",
                "Wind Speed",
                "Pressure",
                "Ambient Temperature",
                "Target",
                "Flagged Hourly Averages",
                ]

        # now add available qc parameters

        if code.lower() == "bnd":
            self.choices.remove("Inlet Line Difference")
            self.choices.remove("Response Curve Residuals")
            self.choices.remove("Target")
            self.choices.remove("Wind Direction")
            self.choices.remove("Wind Speed")
            self.choices.remove("Pressure")
            self.choices.remove("Ambient Temperature")

        if code.lower() == "cao":
            self.choices.remove("Wind Direction")
            self.choices.remove("Wind Speed")
            self.choices.remove("Pressure")
            self.choices.remove("Ambient Temperature")

        qcdir = "/ccg/insitu/%s/%s/qc" % (code.lower(), system)
        qcdir = get_path(qcdir)
        subdirs = os.listdir(qcdir)

        labels = [s.replace('_', ' ').title() for s in subdirs]
        self.choices.extend(sorted(labels))

        # set up label to directory name for qc params
        self.channels = {}
        for label, dirname in zip(labels, subdirs):
            self.channels[label] = dirname

        srcdir = "/ccg/%s/in-situ/%s_data/%s/nl/%d/" % (gas.lower(), code.lower(), system.lower(), year)
        srcdir = get_path(srcdir)
        pattern = "%4d-%02d*.%s" % (year, month, gas.lower())
        self.nlfiles = sorted(glob.glob(srcdir+pattern))

    # ----------------------------------------------------------------
    def getParam(self, plot, param, data, voltlist, target):
        """ plot the data for the given parameter """

        if param == "Std. Dev.":
            self.getStdDev(plot, data)
        elif param == "Measurement Uncertainty":
            self.getUncert(plot, data, param)
        elif param == "Random Uncertainty":
            self.getUncert(plot, data, param)
        elif param == "Inlet Line Difference":
            self.getLineDiff(plot, voltlist)
        elif param == "Flagged Hourly Averages":
            self.getFlaggedData(plot)
        elif param == "Wind Direction":
            self.getMetData(plot, "WD")
        elif param == "Wind Speed":
            self.getMetData(plot, "WS")
        elif param == "Pressure":
            self.getMetData(plot, "P")
        elif param == "Ambient Temperature":
            self.getMetData(plot, "T")
        elif param == "Avg. Signals":
            self.getAvgSignal(plot, voltlist)
        elif param == "Avg. Signals StdDev":
            self.getAvgSignalSdev(plot, voltlist)
        elif param == "Target":
            self.getTarget(plot, target)
        elif param == "Target/R0 Ratio":
            self.getTargetRatio(plot, voltlist)
        elif param == "Raw Signal":
            if "GC" in self.system.upper():
                self._getGCRawSignal(plot, data)
            else:
                self._getRawSignal(plot)
        elif param == "Response Curve":
            self._response_curve(plot)
        elif param == "Response Curve Residuals":
            self._residuals(plot)
        elif param in self.channels:
            self._getQC(plot, param)
        else:
            self._getQCGC(plot, param, data)

    # ----------------------------------------------------------------
    def _getRawSignal(self, plot):
        """ Get the picarro raw signal (10 second output values) """

        files = ccg_insitu_files.insitu_data_files(self.code, self.gas, self.system, self.year, self.month)
#        print(files)
        data = ccg_insitu_files.read_insitu_data_files(self.code, files)
        x = data['date_time']
        y = data['value']
#        print(x)

        title = self.system + " Output"
        plot.createDataset(x, y, title.title(), symbol='none', linecolor='red')

    # ----------------------------------------------------------------
    def _getGCRawSignal(self, plot, rawdata):
        """ Get and plot raw gc signal (peak height/area vs time) """

        x = []
        y = []
        for i in range(rawdata.numrows):
            row = rawdata.dataRow(i)
            peaktype = ccg_utils.getPeakType(self.code, row.date, self.gas, self.defaults)
            val = row.ph if peaktype == "height" else row.pa

            x.append(row.date)
            y.append(val)

        name = "Peak " + peaktype.capitalize()
        plot.createDataset(x, y, name, color='red', symbol='none', linecolor='red')

    # ----------------------------------------------------------------
    def _getQC(self, plot, param):
        """ Get the picarro qc data specified by 'param'. """

        channel = self.channels[param]

        filenames = []
        for day in range(self.daysinmonth):
            date = datetime.datetime(self.year, self.month, day+1)
            filename = ccg_insitu_files.qc_filename(self.code, self.system, date, channel)
#            print(param, filename)
            if filename is None:
                continue
            filenames.append(filename)

        d = ccg_insitu_files.read_insitu_qc(filenames)

        if d is not None:
            x = d['date_time']
            y = d['value']
        else:
            x = []
            y = []

        plot.createDataset(x, y, param, symbol='none', linecolor='red')

    # ----------------------------------------------------------------
    def _getQCGC(self, plot, param, raw):
        """ These aren't actual qc data, but data derived from the raw values. """

        if "REF" in param.upper():
            idx = raw.sampleIndices("REF")
        else:
            idx = raw.sampleIndices("SMP")
        x = raw.data['date'][idx]

        if "PH/PA" in param:
            pa = raw.data['pa'][idx]
            ph = raw.data['ph'][idx]
            y = ph/pa
        elif "PH" in param:
            y = raw.data['ph'][idx]
        elif "PA" in param:
            y = raw.data['pa'][idx]
        elif "RT" in param:
            y = raw.data['rt'][idx]

        x = x.tolist()
        y = y.tolist()
        plot.createDataset(x, y, param, symbol='none', linecolor='red')

    # ----------------------------------------------------------------
    def getMixingRatios(self, plot, data):
        """ Get and plot mixing ratio data for the given time period.
        Data is split up by sample inlet, that is, a separate plot
        dataset for each inlet. """

        x = defaultdict(list)
        y = defaultdict(list)
        xflagged = defaultdict(list)
        yflagged = defaultdict(list)

        if data is None:
            return

        for row in data.itertuples():
            if row.value > -999 and row.qcflag[0] == ".":
                y[row.inlet].append(row.value)
                x[row.inlet].append(row.date)
            else:
                if row.value > -999:
                    yflagged[row.inlet].append(row.value)
                    xflagged[row.inlet].append(row.date)

        inlet_list = sorted(x.keys())
        inlet_list_flagged = sorted(xflagged.keys())

        # get unique list of inlets
        inlet_list = list(set(inlet_list + inlet_list_flagged))

        for n, intk in enumerate(inlet_list):
            color = plot.colors[n % 11]
            if intk == "Line1": color = (255, 0, 0)
            if intk == "Line2": color = (0, 0, 255)
            if intk == "Line3": color = (0, 205, 0)
            plot.createDataset(x[intk],
                               y[intk],
                               name='Inlet ' + str(intk),
                               color=color,
                               symbol='square',
                               connector='none')
            plot.createDataset(xflagged[intk],
                               yflagged[intk],
                               name='Flagged ' + str(intk),
                               outlinecolor=color,
                               outlinewidth=2,
                               symbol='plus',
                               markersize=3,
                               connector='none')

    # ----------------------------------------------------------------
    def getFlaggedData(self, plot):
        """ Get flags on hourly averaged mixing ratios, plot each flag
        type as separate dataset
        """

        f = ccg_insitu_data2.InsituData(self.gas, self.code, 1)
        f.setRange(self.firstday, self.lastday)
        f.includeFlaggedData()
        f.run(as_dataframe=True)

        if f.results is None:
            return

        x = defaultdict(list)
        y = defaultdict(list)
        for row in f.results.itertuples():
            x[row.qcflag].append(row.date)
            y[row.qcflag].append(row.value)

        n = 0
        for flag in sorted(x):
            plot.createDataset(x[flag],
                               y[flag],
                               name=flag,
                               color=plot.colors[n % 11],
                               symbol='square',
                               connector='none')
            n += 1

    # ----------------------------------------------------------------
    def getMetData(self, plot, param):
        """ Get meteorology data from database """

        names = {"WD": "Wind Direction", "WS": "Wind Speed", "T": "Temperature", "P": "Pressure"}

        table = f"{self.code}_minute"

        sql = f"SELECT date, time, {param} as value "
        sql += f"FROM {table} WHERE date>='{self.startdate}' AND date<='{self.enddate}' "
        if param != "T":
            sql += f"AND {param} >= 0 "
        else:
            sql += f"AND {param} > -999 "
        sql += "ORDER BY date, time "
#        print(sql)
        db = ccg_db_conn.RO(db="met")
        result = db.doquery(sql)

        x = []
        y = []
        if result:
            for row in result:
                date = row['date']
                time = row['time']
                value = row['value']
                dt = datetime.datetime(date.year, date.month, date.day) + time
                x.append(dt)
                y.append(float(value))

        if param == "WD":
            plot.createDataset(x,
                               y,
                               name=names[param],
                               symbol='square',
                               connector='none',
                               outlinecolor='red',
                               markersize=1)
        else:
            plot.createDataset(x, y, name=names[param], symbol='none', linecolor='red')

    # ----------------------------------------------------------------
    def getFlaskData(self, plot, data):
        """ Plot flask data, different symbol for each method """

        if data is None:
            return

        x = defaultdict(list)
        y = defaultdict(list)
        for row in data.itertuples():
            if row.value > -999:
                y[row.method].append(row.value)
                x[row.method].append(row.date)

        n = 4
        for method in x:
            plot.createDataset(x[method],
                               y[method],
                               name='Flask Data ' + method,
                               color=plot.colors[n],
                               symbol='circle',
                               connector='none',
                               markersize=4)
            n += 1

    # ----------------------------------------------------------------
    def getStdDev(self, plot, data):
        """ Get and plot standard deviation of mole fractions,
        different symbol for each intake height """

        if data is None:
            return

        x = defaultdict(list)
        y = defaultdict(list)

        #        for (date, value, stdv, unc, num, intake, flag, inlet) in data:
        for row in data.itertuples():
            if row.std_dev > -99 and row.qcflag[0] == ".":
                y[row.inlet].append(row.std_dev)
                x[row.inlet].append(row.date)

        intake_list = sorted(x.keys())
        for n, intk in enumerate(intake_list):
            plot.createDataset(x[intk],
                               y[intk],
                               name='Std. Dev. ' + str(intk),
                               color=plot.colors[n % 11],
                               symbol='square',
                               connector='none')

    # ----------------------------------------------------------------
    def getUncert(self, plot, data, param):
        """ Get and plot standard deviation of mole fractions,
        different symbol for each intake height """

        if data is None:
            return

        x = defaultdict(list)
        y = defaultdict(list)

        #        for (date, value, stdv, unc, num, intake, flag, inlet) in data:
        for row in data.itertuples():
            if "measurement" in param.lower():
                val = row.meas_unc
            else:
                val = row.random_unc

            if val > -99 and row.qcflag[0] == ".":
                y[row.inlet].append(val)
                x[row.inlet].append(row.date)

        intake_list = sorted(x.keys())
        for n, intk in enumerate(intake_list):
            plot.createDataset(x[intk],
                               y[intk],
                               name=param + " " + str(intk),
                               color=plot.colors[n % 11],
                               symbol='square',
                               connector='none')

    # ----------------------------------------------------------------
    def getAvgSignal(self, plot, rawdata):
        """ Get and plot average signals (voltages, peak areas),
        with each sample gas having a different symbol/color.
        The average signals is from the raw data files.
        """

        if not rawdata:
            return

        x = defaultdict(list)
        y = defaultdict(list)
        x2 = defaultdict(list)
        y2 = defaultdict(list)

        for i in range(rawdata.numrows):
            row = rawdata.dataRow(i)
            if "gc" in self.system:
                peaktype = ccg_utils.getPeakType(self.code, row.date, self.gas, self.defaults)
                val = row.ph if peaktype == "height" else row.pa
            else:
                val = row.value

            if row.flag in (".", "*"):
                x[row.label].append(row.date)
                y[row.label].append(val)
            else:
                x2[row.label].append(row.date)
                y2[row.label].append(val)

        for n, gas in enumerate(sorted(x.keys())):
            name = str(gas)
            name2 = str(gas) + " Flag"
            color = plot.colors[n % 11]
            if gas == "Line1": color = (255, 0, 0)
            if gas == "Line2": color = (0, 0, 255)
            if gas == "Line3": color = (0, 205, 0)
            plot.createDataset(x[gas],
                               y[gas],
                               name,
                               outlinecolor=color,
                               color=color,
                               symbol='square')
            plot.createDataset(x2[gas],
                               y2[gas],
                               name2,
                               outlinecolor=color,
                               outlinewidth=2,
                               symbol='plus',
                               markersize=3,
                               connector="none")

    # ----------------------------------------------------------------
    def getAvgSignalSdev(self, plot, rawdata):
        """ Get and plot standard deviation of the average signal values """

        if not rawdata:
            return

        x = defaultdict(list)
        y = defaultdict(list)
        x2 = defaultdict(list)
        y2 = defaultdict(list)

        for i in range(rawdata.numrows):
            row = rawdata.dataRow(i)
            # no sdev for gc
            if "gc" in self.system:
                x[row.label].append(row.date)
                y[row.label].append(0)
            else:
                if row.flag in (".", "*"):
                    x[row.label].append(row.date)
                    y[row.label].append(row.stdv)
                else:
                    x2[row.label].append(row.date)
                    y2[row.label].append(row.stdv)

        for n, gas in enumerate(sorted(x.keys())):
            plot.createDataset(x[gas],
                               y[gas],
                               gas,
                               outlinecolor=plot.colors[n % 11],
                               color=plot.colors[n % 11],
                               symbol='square')
            plot.createDataset(x2[gas],
                               y2[gas],
                               gas + " Flag",
                               outlinecolor=plot.colors[n % 11],
                               outlinewidth=2,
                               symbol='plus',
                               markersize=3,
                               connector="none")

    # ----------------------------------------------------------------
    def getTargetRatio(self, plot, rawdata):
        """ Get the ratio of TGT/R0 """

        if not rawdata:
            return

        x = []
        y = []

        for i in rawdata.data_by_label("TGT"):
            row = rawdata.dataRow(i)
            ref1 = rawdata.findPrevRef(i, "REF", "R0")
            ref2 = rawdata.findNextRef(i, "REF", "R0")

            if ref1 > 0 and ref2 > 0:
                row1 = rawdata.dataRow(ref1)
                row2 = rawdata.dataRow(ref2)
                avgref = (row1.value + row2.value) / 2
                ratio = row.value / avgref
                x.append(row.date)
                y.append(ratio)

        plot.createDataset(x, y, 'TGT/R0 Ratio')

    # ----------------------------------------------------------------
    def getTarget(self, plot, data):
        """ Plot target gas values """

        if data is None:
            return

        x = defaultdict(list)
        y = defaultdict(list)
        xflagged = defaultdict(list)
        yflagged = defaultdict(list)

        #        for (date, value, flag, name) in data:
        for row in data.itertuples():
            if row.value > -999 and row.qcflag[0] == ".":
                x[row.inlet].append(row.date)
                y[row.inlet].append(row.value)
            else:
                if row.value > -999:
                    xflagged[row.inlet].append(row.date)
                    yflagged[row.inlet].append(row.value)

        for name in x:
            plot.createDataset(x[name], y[name], name, color=(0, 0, 255))
            plot.createDataset(xflagged[name],
                               yflagged[name],
                               name='Flagged ' + str(name),
                               outlinewidth=2,
                               symbol='plus',
                               outlinecolor = (0, 0, 255),
                               markersize=3,
                               connector='none')

    # ------------------------------------------------------------------------
    def getLineDiff(self, plot, rawdata):
        """ Plot the difference in the analyzer output between
        Line1 and Line2 samples.
        Difference is Line1 - average of the bracketing line 2 samples.
        """

        minutes5 = datetime.timedelta(minutes=5)
        x = []
        y = []

        for i in rawdata.data_by_label("Line1"):
            row = rawdata.dataRow(i)
            if row.flag not in (".", "*"):
                continue

            idx = rawdata.findPrevRef(i, "SMP", "Line2")
            idx2 = rawdata.findNextRef(i, "SMP", "Line2")
            if idx >= 0 and idx2 >= 0:
                row1 = rawdata.dataRow(idx)
                row2 = rawdata.dataRow(idx2)
                if row.date - row1.date > minutes5: continue
                if row2.date - row.date > minutes5: continue
                if row1.flag not in (".", "*"): continue
                if row2.flag not in (".", "*"): continue
                avg = (row1.value + row2.value) / 2.0
                diff = (row.value - avg)  # * scalefactor
                x.append(row.date)
                y.append(diff)

        plot.createDataset(x, y, 'Line1 - Line2')

    # ------------------------------------------------------------------------
    def _response_curve(self, plot):
        """ plot response curve and input data for the curve """

        for n, rawfile in enumerate(self.nlfiles):

            nldata = ccg_nl.Response(rawfile)

            # find max input value along x axis
            xi = []
            yi = []
            for key, (xp, xpsd, yp, ypsd, num) in nldata.avg.items():
                xi.append(xp)
                yi.append(yp)

            xmin = min(xi)
            xmax = max(xi)

            x, y = nldata.get_values(xmin, xmax)

            plot.createDataset(x,
                               y,
                               "Response %s" % nldata.adate.strftime("%Y-%m-%d"),
                               symbol='none',
                               linecolor=plot.colors[n % 11])
            plot.createDataset(xi,
                               yi,
                               "Input data %s" % nldata.adate.strftime("%Y-%m-%d"),
                               symbol='circle',
                               color=plot.colors[n % 11],
                               markersize=5,
                               connector="None")

    # ----------------------------------------------------------------
    def _residuals(self, plot):
        """ plot residuals from the response curve """

        x = defaultdict(list)
        y = defaultdict(list)
        stds = ["S1", "S2", "S3", "S4", "S5", "S6"]

        if self.code in ["brw", "mlo"]:
            for rawfile in self.nlfiles:

                nldata = ccg_nl.Response(rawfile)
                xs, ys = nldata.getResiduals()

                i = 0
                for xp, yp in zip(xs, ys):
                    label = stds[i]
                    x[label].append(nldata.adate)
                    y[label].append(yp)
                    i = i + 1

        else:

            rawfiles = ccg_insitu_files.insitu_raw_files(self.code, self.gas, self.system, self.year, self.month)
            isdata = ccg_insitu.insitu(self.code, self.gas, rawfiles, self.system)
            isdata.compute_mf()
            for date, (xs, ys, xsd, ysd) in zip(isdata.obj.coeffs, isdata.obj.input_data):
                i = 0
                for xp, yp in zip(xs, ys):
                    fit = isdata.obj.coeffs[date][0]
                    resid = yp - ccg_utils.poly(xp, fit.beta)

                    label = stds[i]

                    x[label].append(date)
                    y[label].append(resid)
                    i = i + 1

        for name in x:
            plot.createDataset(x[name], y[name], name)
