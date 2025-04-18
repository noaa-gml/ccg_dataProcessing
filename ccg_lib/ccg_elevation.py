#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab

"""
Determine surface elevation using passed latitude and longitude.

Compute surface elevation at any location on earth given latitude and
longitude. I am using data sets from 2 primary Digital Elevation Models
(DEMs) for this work, 1) the Shuttle Radar Topography Mission (SRTM)
prepared by NASA and the National Geospatial-Intelligence Agency (NGA) and
2) GTOPO30 prepared by USGS.  SRTM1 provides elevations at 30 m resolution
for the contiguous U.S., Hawaii, and Aleutian Islands.   SRTM3 has 90 m
resolution from 60N to 60S on the continents.  SRTM30 has 900 m and is
directly comparable to GTOPO30, which is also at 900 m resolution.  Only
GTOPO30 has full global coverage.

For any input latitude and longitude, compute elevation using the highest
resolution data set available.

Main routine prints elevation and source data set separated by a pipe (|).

Note:  It seems that Perl or perhaps the way I am reading the binary
       files does not properly convert negative elevations.  As a result,
       I must check for values exceeding void_value and make a correction.
       This is done in ChkElevation().

September 9, 2012 - kam

7/16 jwm
Made some minor changes to improve speed for users calling this repeatedly.  Basically just
reduced disk io.

7/2024 kwt
Ported to python class to handle large amount of calls
without having to start a new proces for each one

10/2024 kwt
Cached current elevation file info so that repeated calls that use the same
elevation file as the previous call will not have to reopen the file on each call.

Command line usage::

  python ccg_elevation.py --lat=39.991 --lon=-105.2607

Output:
  1664|SRTM1

Class Usage::

  from ccg_elevation import DEM
  dem = DEM()
  elev, source = dem.GetElevation(lat, lon)

Using the class in a python script is much much faster than the command line usage
for a large number of calls.

"""
from __future__ import print_function

import os
import math
import glob
import argparse
import numpy as np


########################################################################
class DEM:
    """ Determine surface elevation using Digital Elevation Models

    Args:
        verbose (bool): True for extra output

    Usage:

        Usage of this class is a 2 step process

        1. Create the class
        2. Submit latitude and longitude coordinates and get elevation

    Example::

        from ccg_elevation import DEM
        dem = DEM()
        elev, source = dem.getElevation(lat, lon)

    """

    def __init__(self, verbose=False):

        self.workdir = "/ccg/DEM"
        self.srtmdir = self.workdir + "/SRTM"
        self.gtopodir = self.workdir + "/GTOPO30/"
        self.elev = -999.999
        self.void_value = 32768
        self.srtm30dat = None
        self.verbose = verbose
        self.current_file = None
        self.fileopened = False
        self.lonarr = None
        self.latarr = None
        self.fp = None
        self.ncols = None
        self.nodata = None

        # get list of all srtm1 files
        sdir = self.srtmdir + "/srtm1/"
        self.srtm1files = sorted(glob.glob(sdir + "*.hgt"))

        # get list of all srtm3 files
        sdir = self.srtmdir + "/srtm3/"
        self.srtm3files = sorted(glob.glob(sdir + "*.hgt"))

        self._readSRTM30()

    #----------------------------------------------------------------
    def _readSRTM30(self):
        """ read and save srtm30 file info """

        self.srtm30dat = {}
        sdir = self.srtmdir + "/srtm30/"
        fp = open(sdir + "srtm30_fileinfo.txt")
        for line in fp:
            if line.startswith("#"): continue
            a = line.split()
            self.srtm30dat[a[0]] = [int(x) for x in a[1:]]
        fp.close()

    #----------------------------------------------------------------
    def getElevation(self, lat, lon):
        """ get elevation for given latitude and longitude

        Parameters
        ----------
            lat : float
                latitude value between -90 and 90
            lon : float
                longitude value between -180 and 180

        Returns
        -------
            elev : int
                elevation in meters
            source : str
                source model name

        Checks srtm1, srtm3, srtm30, gtopo files for elevation data
        in that order.
        """

        if abs(lat) > 90 or abs(lon) > 180:
            return "%s|NA" % self.elev

        #######################################
        # Build an SRTM1 file name from user input
        #######################################

        if lat < 0:
            lat_str = "S%02d" % math.ceil(abs(lat))
        else:
            lat_str = "N%02d" % math.floor(abs(lat))

        if lon < 0:
            lon_str = "W%03d" % math.ceil(abs(lon))
        else:
            lon_str = "E%03d" % math.floor(abs(lon))

        fileroot = lat_str + lon_str

        #######################################
        # Is this within SRTM1 region?
        #######################################

        sdir = self.srtmdir + "/srtm1/"
        heightfile = sdir + fileroot + ".hgt"

        if heightfile in self.srtm1files:
            source = "SRTM1"
            elev = self._get_SRTM1(heightfile, lat, lon)
            return elev, source

        #######################################
        # Is this within SRTM3 region?
        #######################################

        sdir = self.srtmdir + "/srtm3/"
        heightfile = sdir + fileroot + ".hgt"

        if heightfile in self.srtm3files:
            source = "SRTM3"
            elev = self._get_SRTM1(heightfile, lat, lon)
            return elev, source

        #######################################
        # If not in SRTM1 or SRTM3 range or
        # elevation is a void value, use SRTM30
        #######################################

        sdir = self.srtmdir + "/srtm30/"
        source = "SRTM30"

        for key, t in self.srtm30dat.items():
            if t[0] <= lat <= t[1] and t[2] <= lon <= t[3]:
                fileroot = key

        srtm30files = sorted(glob.glob(sdir + fileroot + "*"))

        if len(srtm30files) == 0:
            sdir = self.gtopodir
            source = "GTOPO30"

        elev = self._get_SRTM30(sdir, fileroot, lat, lon)

        return elev, source


    #----------------------------------------------------------------
    def _get_SRTM1(self, filename, lat, lon):
        """ Get elevation from srtm1 or srtm3 files

        # The file names represent the bottom left corner of your map.
        # The naming convention of the files is "N49W110.hgt", for example
        # this file covers the region from 49-50 deg North and 109-110 deg West.
        # In the southern hemisphere, the file "S17E142.hgt" covers the
        # region 16-17 deg South and 142-143 deg East.
        """


        # Determine array dimensions
        if "srtm1" in filename:
            dim = 3601
        else:
            dim = 1201

        if filename != self.current_file:

            # Parse file name to retrieve file lat and lon minimum values
            basename = os.path.basename(filename)
            latsign = 1 if "N" in basename else -1
            lonsign = 1 if "E" in basename else -1

            latmin = latsign * int(basename[1:3])
            lonmin = lonsign * int(basename[4:7])
            lonmax = lonmin + 1
            latmax = latmin + 1

            self.lonarr = np.linspace(lonmin, lonmax, dim, endpoint=False)
            self.latarr = np.linspace(latmin, latmax, dim, endpoint=False)
            self.latarr = self.latarr[::-1]

            self.current_file = filename
            if self.fileopened:
                self.fp.close()
            self.fp = open(filename, 'rb')
            self.fileopened = True

        # Find index into lonarr where abs(lonarr-lon) is minimum
        # Find index into latarr where abs(latarr-lon) is minimum
        ptr_lat = np.abs(self.latarr - lat).argmin()
        ptr_lon = np.abs(self.lonarr - lon).argmin()

        offset = ((ptr_lat * dim) + ptr_lon) * 2

        self.fp.seek(offset, 0)
        elev = np.fromfile(self.fp, '>u2', count=1)[0]

        if abs(elev) != self.void_value:
            elev = self._chk_elevation(elev)

        if self.verbose:
            print("lat range: ", self.latarr[0], self.latarr[-1])
            print("lon range: ", self.lonarr[0], self.lonarr[-1])
            print("lat ptr: ", ptr_lat)
            print("lon ptr: ", ptr_lon)
            print("file:", filename)
            print("elev:", elev)

        return elev

    #----------------------------------------------------------------
    def _get_SRTM30(self, sdir, fileroot, lat, lon):
        """ get elevation data from srtm30 or gtopo files """

        filename = sdir + fileroot + '.DEM'
        if filename != self.current_file:

            data = {}
            fp = open(sdir + fileroot + '.HDR')
            for line in fp:
                a = line.split()
                data[a[0]] = a[1]
            fp.close()

            nrows = int(data['NROWS'])
            self.ncols = int(data['NCOLS'])
            ulxmap = float(data['ULXMAP'])
            ulymap = float(data['ULYMAP'])
            xdim = float(data['XDIM'])
            ydim = float(data['YDIM'])
            self.nodata = int(data['NODATA'])

            # Coordinates in file name correspond to top left corner of array.

            self.lonarr = np.arange(ulxmap, ulxmap + xdim*self.ncols, xdim)
            self.latarr = np.arange(ulymap, ulymap - ydim*nrows, -ydim)

            self.current_file = filename
            if self.fileopened:
                self.fp.close()
            self.fp = open(filename, 'rb')
            self.fileopened = True

        ptr_lat = np.abs(self.latarr - lat).argmin()
        ptr_lon = np.abs(self.lonarr - lon).argmin()

        offset = ((ptr_lat * self.ncols) + ptr_lon) * 2

        self.fp.seek(offset, 0)
        elev = np.fromfile(self.fp, '>u2', count=1)[0]

        if elev == self.nodata:
            elev = 0

        elev = self._chk_elevation(elev)

        if self.verbose:
            print("lat range: ", self.latarr[0], self.latarr[-1])
            print("lon range: ", self.lonarr[0], self.lonarr[-1])
            print("lat ptr: ", ptr_lat)
            print("lon ptr: ", ptr_lon)
            print("file:", filename)
            print("elev:", elev)

        return elev

    #----------------------------------------------------------------
    def _chk_elevation(self, elev):
        """ check if elevation value is void value """

        if abs(elev) > self.void_value:
            elev -= (2*self.void_value)

        return elev


########################################################################

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Get elevation data for a latitude and longidute. ")

    parser.add_argument('--lat', required=True, help="Latitude. Specified in decimal degrees.")
    parser.add_argument('--lon', required=True, help="Longitude. Specified in decimal degrees.")
    parser.add_argument('-v', '--verbose', action="store_true", default=False, help="Include additional output")

    options = parser.parse_args()

    latitude = float(options.lat)
    longitude = float(options.lon)

    dem = DEM(verbose=options.verbose)

    elevation, model_source = dem.getElevation(latitude, longitude)
    print("%s|%s" % (elevation, model_source))
