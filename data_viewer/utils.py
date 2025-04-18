# vim: tabstop=4 shiftwidth=4 expandtab
"""
A few utility functions
"""

import os
import sys
import subprocess
import tempfile


#######################################################
def get_path(path):
    """ return the correcgt directory path depending on platform """

    if sys.platform == "darwin":
        path = "/Volumes" + path

    return path


##################################################################################
def get_install_dir():
    """ get the installation directory of pydv """

    p = sys.argv[0]
    # This doesn't work if startup command is ./pydv
    rdir = os.path.realpath(p)
    idir = os.path.split(rdir)[0]
    return idir


###################################################
def write_to_tempfile(data):
    """ Write data to a tempfile and return the temp file name """

    fd, name = tempfile.mkstemp(suffix=".txt")
#    b = str.encode(data)
    os.write(fd, data)
    os.close(fd)

    return name


###################################################
def run_command(args):
    """ Run a process and return the output """

    try:
        p = subprocess.run(args, capture_output=True, text=True, check=False)
        output = p.stdout
        return 0, output
    except OSError as e:
        msg = "Error running process.\nCommand was: \n " + " ".join(args) + "\n\nError was: %s\n" % e
        return 1, msg


#############################################################
def clean_line(line):
    """
    Remove unwanted characters from line,
    such as leading and trailing white space, new line,
    and comments
    """

    line = line.strip('\n')                 # get rid on new line
    line = line.split('#')[0]               # discard '#' and everything after it
    line = line.strip()                     # strip white space from both ends
    line = line.replace("\t", " ")          # replace tabs with spaces

    return line


#############################################################
def cleanFile(filename, showError=True):
    """ Read a file and remove comments """

    data = []

    try:
        f = open(filename)
    except OSError as e:
        if showError:
            print("cleanFile: Can't open file", filename, e, file=sys.stderr)
        return data

    for line in f:
        line = clean_line(line)
        if line:
            data.append(line)

    f.close()

    return data
