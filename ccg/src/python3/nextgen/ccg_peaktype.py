"""
Determine peak type to use for a gc instrument

These settings were originally in a 'defaults' file, e.g. /ccg/ch4/defaults
but were moved into this module with new version of flpro in late 2022.
"""

peaks = {}

peaks['ch4'] = {
    'C2': 'height',
    'C3': 'height',
    'C4': 'height',
    'C7': 'height',
    'H1': 'height',
    'H4': 'area',
    'H5': 'area',
    'H6': 'area',
    'H11': 'area',
}

peaks['co'] = {
    'R2': 'area',
    'R4': 'area',
    'R5': 'area',
    'R6': 'area',
    'R7': 'area',
}

peaks['h2'] = {
    'R4': 'height',
    'R5': 'height',
    'R6': 'height',
    'R7': 'height',
    'H8': 'height',
    'H9': 'height',
    'H11': 'height',
}

peaks['n2o'] = {
    'D1': 'height',
    'H4': 'height',
    'H6': 'height',
}

peaks['sf6'] = {
    'D1': 'height',
    'H4': 'height',
    'H6': 'height',
}

def getPeaktype(inst_id, gas):
    """ Determine the chromatogram peak type to use for processing.

    gc's can use either the peak height or peak area of a chromatogram
    for determining the amount of a gas.  This setting can be different
    fof different gases and different gc's.  Define what to use here.

    Args:
        inst_id : instrument id (str)
        gas : the gas formula (str)

    Returns:
        Either 'height' or 'area', depending on the instrument and gas
    """

    if gas.lower() in peaks:
        d = peaks[gas.lower()]
        if inst_id.upper() in d:
            peaktype = d[inst_id.upper()]
            return peaktype

    return 'area'
