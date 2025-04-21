# vim: tabstop=4 shiftwidth=4 expandtab
"""
Function: read_ncdf()
    Load root and group variables and attributes from a NetCDF file as a python dictionary.
    NetCDF paths and variable/attribute names are retained as dictionary keys.

History
    Created Oct 2021, M. Trudeau (development version)

Example(s)::

    from ccg_ncdf import read_ncdf

    # read all NetCDF variables and attributes
    dat = read_ncdf("/nfs/footprints/stilt/ctl-na-v1.1/OCO2/2015/03/stilt-pkg2015x03x10x21x38x14.2577Nx124.0107W.nc")
    print(dat[".Title"])

    # read and subset NetCDF file content with a text search
    dat = read_ncdf("/nfs/footprints/stilt/ctl-na-v1.1/OCO2/2015/03/stilt-pkg2015x03x10x21x38x14.2577Nx124.0107W.nc", search="units")
    for k in dat.keys(): print(k)


Update
    version 1.1 - 15 Dec 2021 Kirk Thoning
        - If variable has a 'units' attribute that contains the word 'since',
          assume timestamp and create another variable 'date' with datetime object
          converted from timestamp.
        - Remove leading '.' in global attribute name
        - Add 'variables' key in dict that contains list of variable names
        - Rename module to ccg_ncdf.py
        - Removed .keys() when traversing through dict in search
        - minor formatting and doc changes
"""

import numpy as np
import pandas as pd
import netCDF4

def walktree(top):
    """ walk the group tree using a Python generator """

    values = top.groups.values()
    yield values
    for value in top.groups.values():
        for children in walktree(value):
            yield children

def format_ncvar(variable):
    """ called by read_ncdf to return formatted values """

    value = variable[:]

    try:
        if variable.dtype.char == 'S':  # this doesn't work for netcdf string variables
            value = netCDF4.chartostring(value[:])
    except:
        pass

    # to-do: if variable.units contains datetime information,
    # convert to datetime object w/ ccg_date_utils.date_conversions()
    # handled below with check for 'since' in 'units' attribute. kt

    return value

def read_ncdf(fname, search="", set_mask=False, datename=None, verbose=False):
    """ Read a netcdf file and return data and attributes as a dict.

    Args:
        fname : netcdf filename
        search : Include only variables where name matches search string
        set_mask : Set to True to convert variables to masked arrays
        datename : Name of variable converted to datetime objects from
                   'time since' variable. Default is to append '_date' to original variable name
        verbose : Set to True to print out extra messages

    Returns:
        mydict : dict of data from netcdf file.  Keys are for both
                 attributes and variables.  See mydict['variables'] for
                 list of variable names.
    """

    mydict = {}
    mydict['variables'] = []

    root = netCDF4.Dataset(fname, "r")
    if verbose: print(f"Opened for reading: {fname}")

    root.set_auto_mask(set_mask)

    for ncattr in root.ncattrs():
        if verbose: print(f"Appending global attribute: {ncattr}")
        mydict[f"{ncattr}"] = getattr(root, ncattr)

    for ncvar, variable in root.variables.items():
        if verbose: print(f"Appending variable: {ncvar}")
        mydict[ncvar] = format_ncvar(variable)
        mydict['variables'].append(ncvar)

        for ncattr in variable.ncattrs():
            if verbose: print(f"Appending variable attribute: {ncattr}")
            value = getattr(variable, ncattr)
            mydict[f"{ncvar}.{ncattr}"] = value
            if ncattr == "units" and "since" in value.lower():
                if datename is None:
                    varname = ncvar + '_date'  # append _date to original var name
                else:
                    varname = datename
                if verbose: print(f"Appending variable: {varname} converted from {ncvar}")
                mydict[varname] = netCDF4.num2date(mydict[ncvar], value)
                mydict['variables'].append(varname)


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
        d = {key:mydict[key] for key in mydict if search in key}
        d['variables'] = [name for name in mydict['variables'] if search in name]
        return d

    return mydict

def DataFrame(dataset):
    """ Return the variables in the dataset as a pandas DataFrame """

    b = []
    for varname in dataset['variables']:
        if dataset[varname].ndim > 1: continue

        b.append(pd.Series(dataset[varname], name=varname))

    df = pd.concat(b, axis=1)

    return df

def get_nc_attr(filename, attr_name):
    """ Get an attribute from a netcdf file """

    nc = netCDF4.Dataset(filename)
    attr_value = nc.getncattr(attr_name)
    nc.close()

    return attr_value

def get_nc_variable(filename, varname, unique=False):
    """ Get a netcdf variable

    Args:
        filename : netcdf filename
        varname: name of netcdf variable
        unique : If True, return only unique values of the variable
    """

    nc = netCDF4.Dataset(filename)
    vardata = nc.variables[varname][:]
    if unique:
        vardata = np.unique(vardata)

    return vardata


def update_ncdf_var(filename, varname, vardata):
    """ Update variable 'varname' with data from 'vardata' in netcdf file

    Args:
        filename : netcdf filename
        varname : netcdf variable name
        vardata : numpy array of data

    Lots of assumptions made, such as data type is same, data length is same ...
    Should only be used when values of a netcdf variable are changed,
    but nothing else, and you want to write back the changed values to file.

    vardata must be a numpy array
    """

    # open netcdf file for updates
    try:
        ds = netCDF4.Dataset(filename, "r+")
    except IOError as e:
        return -1

    # get dataset variable
    data = ds.variables[varname]

    # if variable is a character array, then convert strings to char
    if data.dtype.type is np.bytes_ and vardata.dtype.type is np.str_:
        strlen = data.shape[1]
        data[:] = [netCDF4.stringtoarr(s, strlen) for s in vardata]

    else:
        data[:] = vardata

    ds.close()


if __name__ == "__main__":

    filename = "/ccg/src/dv/v7.0/flsel/ARH_ch4_surface_event_NIWA.nc"
    filename = "/ccg/src/dv/v7.0/flsel/tst.nc"
    d = read_ncdf(filename, verbose=True)
#    print(d)
    for key in d:
        if key not in d['variables']:
            print("%30s: %s" % (key, d[key]))

    for v in d['variables']:
        print(v)
        print(d[v])

#    update_ncdf_var(filename, 'qcflag', d['qcflag'])
#    update_ncdf_var(filename, 'time', d['time'])
