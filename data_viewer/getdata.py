# vim: tabstop=4 shiftwidth=4 expandtab
"""
Class for holding settings and getting data from
the database for flask or insitu data.  Uses the three modules
ccg_flask_data.py, ccg_insitu_data.py and ccg_tower_data.py for fetching the data.

Settings are set with the get.py module, which is a dialog
for selecting site, parameter ...

Usual use is

    from common import get

    dlg = get.GetDataDialog(self)

Then get datasets with

    d = dlg.data.process_data()
    for dataset in d.datasets:
        x = dataset.x
        y = dataset.y
        ...

"""

import datetime
from collections import defaultdict
from dataclasses import dataclass
import numpy

import ccg_insitu_data2
import ccg_flask_data
import ccg_tower_data


##########################################################################
@dataclass
class GetDataset:
    """ Class for a dataset. """

    x = []
    y = []
    name = ""


#####################################################################
class GetData:
    """ Class for holding settings and getting data from database """

    def __init__(self):
        self.project = 1
        self.sitenum = 75
        self.stacode = "MLO"
        self.parameter = 1
        self.paramname = "co2"
        self.parameter_list = [1]
        self.intake_ht = 0
        self.byear = 0
        self.eyear = 0
        self.use_flask = True
        self.use_pfp = True
        self.bin_method = None
        self.use_soft_flags = False
        self.use_hard_flags = False
        self.use_strategy = False
        self.min_bin = 0
        self.max_bin = 0
        self.bin_data = False
        self.obs_avg = 'Daily'
        self.obs_use_soft_flags = False
        self.flags_symbol = False
#        self.hard_flags_symbol = False
        self.datasets = []
        self.useDatetime = False
#        self.programs = ('CCGG')  #  use numbers instead?  self.programs = (1)
        self.programs = (1, 8, 11, 12, 13)
        self.datalist = []
        self.methods = []
        self.methods_symbol = False

    # ----------------------------------------------
    def process_data(self, useDatetime=False):
        """ process the data using saved settings """

        self.useDatetime = useDatetime

        if self.project in [1, 2]:
            self._flask_process_data()
        elif self.project == 3 or self.project == 5:
            self._tower_process_data()
        elif self.project == 4:
            self._obs_process_data()

    # ----------------------------------------------
    def _obs_process_data(self):
        """ process observatory insitu data """

        self.datasets = []

        datatypes = {"Raw": 0, "Hourly": 1, "Daily": 2, "Monthly": 3}
        which = datatypes[self.obs_avg]

        d = ccg_insitu_data2.InsituData(self.paramname, self.stacode, which)
        t1 = datetime.datetime(self.byear, 1, 1)
        t2 = datetime.datetime(self.eyear+1, 1, 1)
        d.setRange(t1, t2)
        if self.use_soft_flags:
            d.includeFlaggedData()

        d.run(as_arrays=True)
        if d.results is None:
            return

        name = self.stacode + " Obs " + self.paramname

        if "Hourly" in self.obs_avg and self.use_soft_flags and self.flags_symbol:
            # extract unflagged data
            self._get_unflagged_data(d, name)

            # extract dataset for every flag
            self._get_flagged_data(d, name)
        else:
            self._get_dataset(d, name)

    # ----------------------------------------------
    def _tower_process_data(self):
        """ process tower insitu data """

        self.datasets = []

        datatypes = {"Raw": 0, "Hourly": 1, "Daily": 2, "Monthly": 3}
        which = datatypes[self.obs_avg]

        print("which is", which)

# need to decide which db table to use
# cao uses insitu_xxx, other use site/gas/specific table
        if self.stacode.lower() == "cao":
            d = ccg_insitu_data2.InsituData(self.paramname, self.stacode, which)
        else:
            d = ccg_tower_data.TowerData(self.paramname, self.stacode, which)
        t1 = datetime.datetime(self.byear, 1, 1)
        t2 = datetime.datetime(self.eyear+1, 1, 1)
        d.setRange(t1, t2)
        d.setIntakeHeight(self.intake_ht)
        if self.use_soft_flags:
            d.includeFlaggedData()

        d.run(as_arrays=True)

        if d.results is None:
            return

        name = self.stacode + " Tower " + self.paramname

        if self.use_soft_flags and self.flags_symbol:
            # extract unflagged data
            self._get_unflagged_data(d, name)

            # extract dataset for every flag
            self._get_flagged_data(d, name)
        else:
            self._get_dataset(d, name)

    # ----------------------------------------------
    def _flask_process_data(self):
        """ get flask data """

        self.datasets = []

        f = ccg_flask_data.FlaskData(self.parameter, self.sitenum)
        t1 = datetime.datetime(self.byear, 1, 1)
        t2 = datetime.datetime(self.eyear+1, 1, 1)
        f.setRange(t1, t2)
        f.setProject(self.project)
        f.setMethods(self.methods)
        print("set programs to", self.programs)
        f.setPrograms(self.programs)
        f.setStrategy(self.use_flask, self.use_pfp)
        if self.use_soft_flags:
            f.includeFlaggedData()
        if self.use_hard_flags:
            f.includeHardFlags()
        if self.bin_data and self.bin_method:
            f.setBin(self.bin_method, self.min_bin, self.max_bin)

#        f.showQuery()
        f.run(as_arrays=True)
        if f.results is None:
            return

        name = self.stacode + " " + self.paramname
        if self.bin_method and self.bin_data:
            name += " %g - %g m" % (self.min_bin, self.max_bin)

        # 4 ways to split data
        # 1 - no splitting
        # 2 - split by method only, ignore flags
        # 3 - split by flag only, ignore method
        # 4 - split by both flag and method

        if (self.use_soft_flags or self.use_hard_flags) and self.flags_symbol:
            # extract unflagged data
            self._get_unflagged_data(f, name)
# Need a _get_unflagged_method_data routine if self.methods.symbol is true

            if self.methods_symbol:
                # extract dataset for every flag and method
                # 4
                self._get_flagged_method_data(f, name)
            else:
                # extract dataset for every flag
                # 3
                self._get_flagged_data(f, name)

        else:

            if self.methods_symbol:
                # 2
                self._get_method_data(f, name)
            else:
                # 1
                self._get_dataset(f, name)

    # ----------------------------------------------
    def _get_dataset(self, data, name):
        """ Get a dataset from results of database query

            This is for a straightforward result to dataset,
            no need for splitting data by method, flag etc.
        """

        ds = GetDataset()
        ds.name = name
        if self.useDatetime:
            ds.x = data.results['date']
        else:
            ds.x = data.results['time_decimal']
        ds.y = data.results['value']

        self.datasets.append(ds)

    # ----------------------------------------------
    def _get_method_data(self, data, name):
        """ Get datasets for data from database query split by flask sampling method

        There will be a dataset for each method
        """

        x = defaultdict(list)
        y = defaultdict(list)
        for dt, xp, yp, method in zip(data.results['date'],
                                      data.results['time_decimal'],
                                      data.results['value'],
                                      data.results['method']):
            if self.useDatetime:
                x[method].append(dt)
            else:
                x[method].append(xp)
            y[method].append(yp)

        for flag in sorted(x.keys()):
            ds = GetDataset()
            ds.x = numpy.array(x[flag])
            ds.y = numpy.array(y[flag])
            ds.name = name + "  " + flag
            self.datasets.append(ds)

    # ----------------------------------------------
    def _get_unflagged_data(self, data, name):
        """ Get a dataset from results of database query

            This is for getting only unflagged data.
            Look at the 'qcflag' array to find unflagged data
        """

        w = [s[0:2] == '..' for s in data.results['qcflag']]
        ds = GetDataset()
        ds.name = name
        if self.useDatetime:
            ds.x = data.results['date'][w]
        else:
            ds.x = data.results['time_decimal'][w]
        ds.y = data.results['value'][w]

        self.datasets.append(ds)

    # ----------------------------------------------
    def _get_flagged_data(self, data, name):
        """ Get datasets for flagged data from database query

        There will be a dataset for each flag character
        """

        x = defaultdict(list)
        y = defaultdict(list)
        for dt, xp, yp, flag in zip(data.results['date'],
                                    data.results['time_decimal'],
                                    data.results['value'],
                                    data.results['qcflag']):
            if self.use_soft_flags and self.use_hard_flags:
                if flag[0:2] == "..":
                    continue
                f = flag[0:2].strip('.')
            elif self.use_hard_flags:
                if flag[0] == ".":
                    continue
                f = flag[0]
            elif self.use_soft_flags:
                if flag[1] == ".":
                    continue
                f = flag[1]

            if self.useDatetime:
                x[f].append(dt)
            else:
                x[f].append(xp)
            y[f].append(yp)

        for flag in sorted(x.keys()):
            ds = GetDataset()
            ds.x = numpy.array(x[flag])
            ds.y = numpy.array(y[flag])
            ds.name = name + "  " + flag
            self.datasets.append(ds)

    # ----------------------------------------------
    def _get_flagged_method_data(self, data, name):
        """ Get datasets for flagged data from database query

        There will be a dataset for each flag-method combination
        """

        x = defaultdict(list)
        y = defaultdict(list)
        for dt, xp, yp, flag, method in zip(data.results['date'],
                                            data.results['time_decimal'],
                                            data.results['value'],
                                            data.results['qcflag'],
                                            data.results['method']):
            if self.use_soft_flags and self.use_hard_flags:
                if flag[0:2] == "..":
                    continue
                f = flag[0:2].strip('.')
            elif self.use_hard_flags:
                if flag[0] == ".":
                    continue
                f = flag[0]
            elif self.use_soft_flags:
                if flag[1] == ".":
                    continue
                f = flag[1]

            label = f + " " + method
            if self.useDatetime:
                x[label].append(dt)
            else:
                x[label].append(xp)
            y[label].append(yp)

        for flag in sorted(x.keys()):
            ds = GetDataset()
            ds.x = numpy.array(x[flag])
            ds.y = numpy.array(y[flag])
            ds.name = name + "  " + flag
            self.datasets.append(ds)


if __name__ == "__main__":

    d = GetData()
    d.project = 1
    d.stacode = 'MLO'
    d.byear = 1990
    d.eyear = 2021
    d.intake_ht = 396
    d.paramname = "C2H6"
#    d.obs_avg = "Hourly"
#    d.use_soft_flags = True
#    d.use_hard_flags = True
#    d.flags_symbol = True
#    d.methods_symbol = True
    d.process_data()  # useDatetime=True)

    print("num datasets", len(d.datasets))
    for dset in d.datasets:
        print(dset.name)
        print(dset.x)
        print(dset.y)
#        print()
