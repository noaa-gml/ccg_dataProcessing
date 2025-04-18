"""
Reader utility class for insitu imports.  Needs to be subclassed.

"""

import sys
import os
import pandas as pd
import dask.dataframe as dd
#import numpy as np
#import xarray as xr
import datetime as dt
import glob

import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
import py_utils.pyu_util_functions as uf

class InsituDataReader():
    def __init__(self,opts):
        super().__init__()
        self.opts=opts
        self.update=opts['update']
        self.db=opts['db_conn']
        
        #These could/should be looked up dynamiclly
        self.parameters={}
        self.instruments={}
        self.utils=uf.PYUUtilFunctions()
    
    def processFile(self,file_name):
        """To be overridden by subclass to do work."""
        return 0;
    
    def getParameterNum(self, parameter):
        """Return num from gmd.parameter"""
        return self.db.doquery("select num from gmd.parameter where formula like %s", (parameter,),numRows=0)    
    
    def getInstNum(self,inst,autoadd=False):
        """Return num from ccgg.inst"""
        #See if in cache already
        if inst in self.instruments : return self.instruments[inst]

        #look up and maybe add if needed.
        num= self.db.doquery("select num from ccgg.mobile_insitu_instruments where name=%s",(inst,),numRows=0)
        if not num and autoadd :
            num=self.db.doquery("insert mobile_insitu_instruments (name, abbr) values (%s,%s)",(inst,inst),insert=True)

        if num : self.instruments[inst]=num#cache for reuse
        #print(num,inst,autoadd,self.instruments)
        return num
        
    def getSiteNum(self,site):
        """Return num from gmd.site"""
        return self.db.doquery("select num from gmd.site where code=%s",(site,),numRows=0)
        
    def getVehicleNum(self,vehicle_id,vehicle_type_num, autoadd=False):
        """Return num from ccgg.vehicle"""
        #If autoadd, we insert vehicle and return new key.
        num=self.db.doquery("select num from vehicle where abbr=%s and vehicle_type_num=%s",(vehicle_id,vehicle_type_num),numRows=0)
        if not num and autoadd :
            num=self.db.doquery("insert vehicle (name, abbr,vehicle_type_num) values (%s,%s,%s)",(vehicle_id,vehicle_id,vehicle_type_num),insert=True)
        return num
    
    def getElev(self,lat,lon):
        #Returns elevation and src from DEM database lookup for passed lat, lon
        res=self.utils.run_shell_cmd('/ccg/DEM/ccg_elevation.pl -lat='+str(lat)+' -lon='+str(lon),False)
        res=res.rstrip()
        #res is in the form elev|src
        if res : #It should always return something (maybe defaults)
            elev,elevSrc=res.split("|")
            return (elev,elevSrc)
        else : return (None,None)

   
   