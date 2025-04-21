"""
Function: read_ncdf()
    Load root and group variables and attributes from a NetCDF file as a python dictionary.
    NetCDF paths and variable/attribute names are retained as dictionary names. 

History
    Created Oct 2021, M. Trudeau (development version)

Example(s):
    from ccg_file_utils import read_ncdf

    # read all NetCDF variables and attributes
    dat = read_ncdf("/nfs/footprints/stilt/ctl-na-v1.1/OCO2/2015/03/stilt-pkg2015x03x10x21x38x14.2577Nx124.0107W.nc")
    print(dat[".Title"])

    # read and subset NetCDF file content with a text search
    dat = read_ncdf("/nfs/footprints/stilt/ctl-na-v1.1/OCO2/2015/03/stilt-pkg2015x03x10x21x38x14.2577Nx124.0107W.nc", search="units")
    for k in dat.keys(): print(k)
"""

from netCDF4 import Dataset, chartostring

def walktree(top):

    # walk the group tree using a Python generator
    values = top.groups.values()
    yield values
    for value in top.groups.values():
        for children in walktree(value):
            yield children

def format_ncvar(variable):

    # called by read_ncdf to return formatted values
    value = variable[:]

    if (variable.dtype.char == 'S'):
        value = chartostring(value[:])

    # to-do: if variable.units contains datetime information, convert to datetime object w/ ccg_date_utils.date_conversions()

    return value

def read_ncdf(fname, search="", set_mask=False, verbose=False):

    mydict = {}

    root = Dataset(fname, "r")
    if verbose: print(f"Opened for reading: {fname}")

    root.set_auto_mask(set_mask)

    for ncattr in root.ncattrs():
        if verbose: print(f"Appending global attribute: {ncattr}")
        mydict[f".{ncattr}"] = getattr(root, ncattr)

    for ncvar, variable in root.variables.items():
        if verbose: print(f"Appending variable: {ncvar}")
        mydict[ncvar] = format_ncvar(variable) 

        for ncattr in variable.ncattrs():
            if verbose: print(f"Appending variable attribute: {ncattr}")
            mydict[f"{ncvar}.{ncattr}"] = getattr(variable, ncattr)

    for groups in walktree(root):
        for group in groups:

            for ncattr in group.ncattrs():
                if verbose: print(f"Appending group attribute: {ncattr}")
                mydict["{}/.{}".format(group.path[1:], ncattr)] = getattr(group, ncattr)

            for ncvar, variable in group.variables.items():
                if verbose: print(f"Appending variable: {ncvar}")
                mydict["{}/{}".format(group.path[1:], ncvar)] = format_ncvar(variable) 

                for ncattr in variable.ncattrs():
                    if verbose: print(f"Appending variable attribute: {ncattr}")
                    mydict["{}/{}.{}".format(group.path[1:], ncvar, ncattr)] = getattr(variable, ncattr)

    root.close()

    if search: # allow for simple searches to subset dictionary
        return {key:mydict[key] for key in mydict.keys() if search in key}
    else:
        return mydict
