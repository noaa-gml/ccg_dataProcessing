# vim: tabstop=4 shiftwidth=4 expandtab
"""
routines for processing the chromatogram
"""

import os
import zipfile
import platform
from numpy import array

from graph5.font import Font
from common import utils


##############################################################################
def get_source_file(archive, filename):
    """ Determine source of gc chromatogram file.  If it's in an archive,
    then extract it and write to a temporary file, return the name of
    the temporary file.  If it's a stand alone file, return the filename.
    """

    remove_temp = 0
    if archive is not None:
        # Extract the file from the archive, write to temporary file

        if zipfile.is_zipfile(archive):
            with zipfile.ZipFile(archive) as z:
                output = z.read(filename)
            r = 0
        else:
            com = ["ar", "-p", archive, filename]
            r, output = utils.run_command(com)
            output = str.encode(output)

        if not r:
            sourcefile = utils.write_to_tempfile(output)
            remove_temp = 1
    else:
        sourcefile = filename

    return sourcefile, remove_temp


##############################################################################
def getData(parent, archive=None, filename=None):
    """ Run the gcdata helper program for reading the chromatogram file,
        then printing out columns of data for the different results.

        'parent' is the class that has the graphs
        'archive' is the archive name, None if not used.
        'filename' is the name of the chromatogram file, either standalone
        or a file within the archive
    """

    graph = parent.plot        # chromatogram graph
    graph2 = parent.plot2        # slope graph

    # call gcdata to get chromatogram data
    output = getPeakData(parent, archive, filename, peakInfo=False)

    x = []
    y1 = []
    y2 = []
    y3 = []
    y4 = []
    y5 = []
    y6 = []
    y7 = []
    for line in output.split("\n"):
        a = line.split()
        if len(a) == 7:
            x.append(float(a[0]))   # time
            y1.append(float(a[1]))  # data
            y2.append(float(a[2]))  # smooth
            y3.append(float(a[3]))  # detrend
            y4.append(float(a[4]))  # slope
            y5.append(float(a[5]))  # threshold
            y6.append(-float(a[5]))  # -threshold
            y7.append(float(a[6]))  # bfit

    graph.clear()
    graph2.clear()

    graph.title.SetText(filename)
    graph2.title.SetText(filename)

    graph.createDataset(x, y1, 'chromatogram', symbol="none")
    graph.createDataset(x, y3, 'detrended', symbol="none")
    graph.createDataset(x, y2, 'smoothed', symbol="none")
    graph2.createDataset(x, y4, 'slope', symbol="none")
    graph2.createDataset(x, y5, 'threshold +', symbol="none")
    graph2.createDataset(x, y6, 'threshold -', symbol="none")

    # Run helper again to get peak info.
    output = getPeakData(parent, archive, filename, peakInfo=True)

    font = Font(8)
    font.setFixedFont()

    # Each line has peak name, height, area, retention time, peak width,
    # baseline code, start time, stop time, start level, stop level.
    for line in output.split("\n"):
        a = line.split()
        if len(a) == 10:
            name = a[0]
            height = float(a[1])
            area = float(a[2])
            retention_time = float(a[3])
            peak_width = float(a[4])
            baseline_code = a[5]
            start_time = float(a[6])
            end_time = float(a[7])
            start_level = int(a[8])
            end_level = int(a[9])

            s  = "     Peak Name: %s\n" % name
            s += "   Peak Height: %g\n" % height
            s += "     Peak Area: %g\n" % area
            s += "Retention Time: %g\n" % retention_time
            s += "    Peak Width: %g\n" % peak_width
            s += " Baseline Code: %s\n" % baseline_code
            s += "    Start Time: %g\n" % start_time
            s += "      End Time: %g\n" % end_time
            s += "   Start Level: %d\n" % start_level
            s += "     End Level: %d"   % end_level

            t = graph.Text(retention_time, start_level, name, s)
            t.setPopup(1)
            t.setFont(font)

            # Create dataset for peak baseline
            # Just use linear line for now. Actual baseline could be
            # curved, but that requires more work.
            xp = [start_time, end_time]
            yp = [start_level, end_level]
            graph.createDataset(xp, yp, name + " baseline", symbol="circle")

    if parent.integration_file is not None:
        xp = []
        yp = []
        lines = utils.cleanFile(parent.integration_file)
        for line in lines:
            a = line.split()
            if len(a) >= 2:
                if a[1] == "CB":
                    time = float(a[0])
                    xp.append(time)
                    t, v = find_nearest(x, time)
                    yp.append(y1[t])

        graph.createDataset(xp, yp, "CB", symbol="circle", markersize=4, linetype="none")

        # only show baseline fit between first and last CB points
        if len(xp) > 0:
            xx = []
            yy = []
            for xz, yz in zip(x, y7):
                if xp[0] < xz < xp[-1]:
                    xx.append(xz)
                    yy.append(yz)

            graph.createDataset(xx, yy, 'bfit', symbol="none", linewidth=2)

    graph.update()
    graph2.update()


#########################################################################
def getPeakData(parent, archive=None, filename=None, peakInfo=False):
    """ Run the gcdata command to get chromatogram data, such as
    levels, smoothed chromatogram, slope, etc.

    Return the output from the command
    """

    sourcefile, remove_temp = get_source_file(archive, filename)

    # Run helper program on source file, get output
    command = []
    if platform.system() == "Darwin":
        command.append(os.path.normpath(parent.install_dir + "/bin/mac/gcdata"))
    else:
        a = platform.architecture()
        if a[0] == "64bit":
            command.append(os.path.normpath(parent.install_dir + "/bin/x86_64/gcdata"))
        else:
            command.append(os.path.normpath(parent.install_dir + "/bin/gcdata"))
    if parent.integration_file is not None:
        command.append("-t")
        command.append(parent.integration_file)
        if parent.peakid_file is not None:
            command.append("-i")
            command.append(parent.peakid_file)
    else:
        if parent.data_directory is not None:
            command.append("-d")
            command.append(parent.data_directory)

    if peakInfo:
        command.append("-r")
    command.append(sourcefile)

    print(" ".join(command))
    r, output = utils.run_command(command)
    output = output.strip("\n")
    print(output)
    if r:
        print(f"Error in running command {command}: {output}")
        output = None

    if remove_temp:
        os.remove(sourcefile)

    return output


#########################################################################
def find_nearest(nlist, value):
    """ Find index in nlist (a list of numbers) whose value is closest to the given value."""

    diff = 1e38
    for i, val in enumerate(nlist):
        d = abs(value-val)
        if d < diff:
            diff = d
            idx = i

    return idx, array[idx]
