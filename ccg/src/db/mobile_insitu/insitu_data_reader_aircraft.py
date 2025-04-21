#!/usr/bin/env python3
"""Procedures to import 10sec merge file from aircraft data file"""

import sys
import os
import pandas as pd
import dask.dataframe as dd
#import numpy as np
#import xarray as xr
import datetime as dt
import glob


if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
#if('/home/ccg/mund/dev/ccgdblib' not in sys.path) : sys.path.append('/home/ccg/mund/dev/ccgdblib')
import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
from insitu_data_reader import InsituDataReader

class InsituDataReader_Air(InsituDataReader):
    def __init__(self,opts):
        super().__init__(opts)
        
    def processFile(self,file_name):
        if self.opts['reader_ver']==1 : 
            print("v1 needs to be tested again before using");
            sys.exit()
            #return self.process_air_v1(fn,db,self.update)#not sure this is still working.
        else : 
            return self.process_air(file_name)
        
    def process_air(self,fn):
        #Kathryn's aircraft  files v2 (current default)
                
        #YYYYMMDD,UTC_Start,Lon_deg, Lat_deg,Alt_m,CH4_ppb,CH4_stdv,CH4_nvalue,CH4_unc,CH4_Instrument_ID,CO_ppb,CO_stdv,CO_nvalue,CO_unc,CO_Instrument_ID,CO2_ppm,CO2_stdv,CO2_nvalue,CO2_unc,CO2_Instrument_ID,H2O_percent,H2O_stdv,H2O_nvalue,H2O_unc,H2O_Instrument_ID,P_Pa,P_stdv,P_nvalue,P_unc,P_Instrument_ID,T_K,T_stdv,T_nvalue,T_unc,T_Instrument_ID,u_mps,u_stdv,u_nvalue,u_unc,u_Instrument_ID,v_mps,v_stdv,v_nvalue,v_unc,v_Instrument_ID,Profile_ID,Aircraft_ID
        #20171105,60200,-118.8740,55.1845, 669.76,2001.84,0.91,5,0.5,Picarro_CFKBDS2007,149.50,14.87,5,0.5,Picarro_CFKBDS2007,415.11,0.21,4,0.1,Picarro_CFKBDS2007,0.27,0.00,4,0.0,Picarro_CFKBDS2007,94888,14,19,100,Picarro_CFKBDS2007,265.5,0.1,16,0.4,Vaisala_HMP60,2.6,0.5,10,0.3,Aspen_Avionics_PFD1000,-0.2,0.1,10,0.3,Aspen_Avionics_PFD1000,0,ScientificAviation_MooneyOvation3_N617DH

        #Fill the parameters dict with ones we'll import.  Nums are gmd.parameter.num
        self.parameters['CH4_ppb']=2;self.parameters['CO_ppb']=3;self.parameters['CO2_ppm']=1;self.parameters['H2O_percent']=169;
        self.parameters['P_Pa']=61#pressure (aircraft) source in pa. db records mbar | pa/100=mbar
        self.parameters['T_K']=60;#src in K, db in C   | k− 273.15=C
        #self.parameters['u_mps']=0;self.parameters['v_mps']=0; #We'll handle these specially below.
        self.parameters['RH_percent']=62
        self.parameters['u_mps']=175
        self.parameters['v_mps']=176
        try:
            #load in some options from caller
            campaign_num=self.opts['campaign_id']
            interval_sec=self.opts['interval_sec']
            site_num=self.opts['site_num']
            db=self.db
            
            c=0;evt=0;flight_num=0;vehicle_id=None;skipped=0;
            
            print("Processing "+fn)
            df=pd.read_csv(fn)#Read into a pandas df
            
            vehicle_type_num=1;#aircraft
            project_num=2;#ccg_aircraft
            strategy_num=3;#insitu
            
            #If no flight_num provided, use datetime of first row
            if not flight_num : flight_num=str(df['YYYYMMDD'][0])+"_"+str(df['UTC_Start'][0])
            
            #Look up vehicle
            if 'Aircraft_ID' in df.columns : vehicle_id=df["Aircraft_ID"][0]#Assume same for whole file
            vehicle_num=self.getVehicleNum(vehicle_id,vehicle_type_num,True)#Auto add if not there.
            
            if not site_num : 
                print("Error; missing site_num")
            
            df['dt']=pd.to_datetime(df['YYYYMMDD'],format='%Y%m%d')+pd.to_timedelta(df['UTC_Start'], unit='s')#convert dt.  utc_start is #seconds since midnight yyyymmdd 
            for r in df.itertuples():
                #Insert, if needed, one at a time so we can get generated key

                profile_num = r.Profile_ID if 'Profile_ID' in df.columns else 0;

                if pd.isna(r.dt) or pd.isna(r.Lat_deg) or pd.isna(r.Lon_deg) or pd.isna(r.Alt_m) : 
                    print("Skipping row for missing primary key vals; yymmdd:",r.YYYYMMDD," utcstart:", r.UTC_Start," datetime:",r.dt," lat:",r.Lat_deg," lon:",r.Lon_deg,"alt:",r.Alt_m)
                    skipped+=1
                    continue
                if 'elev' in df.columns : 
                    elev=r.elev
                    elev_src='file'
                else:
                    (elev,elev_src)=self.getElev(r.Lat_deg,r.Lon_deg)
                    
                #elev = 0 if 'elev' not in df.columns else r.elev
                
                intake_id = 0 if 'Intake_id' not in df.columns else r.Intake_id
                
                insEvent="""insert ccgg.mobile_insitu_event (site_num,project_num,strategy_num,expedition_id,datetime,lat,lon,alt,elev,vehicle_num,profile_num,intake_id,campaign_num,elev_source)
                    values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
                vals=(site_num,project_num,strategy_num,flight_num,r.dt.isoformat(), r.Lat_deg,r.Lon_deg,r.Alt_m,elev,vehicle_num,profile_num, intake_id,campaign_num,elev_src)
                ukey=(r.dt.isoformat(),r.Lat_deg,r.Lon_deg,r.Alt_m,vehicle_num,intake_id)#unique lookup key for row if exists
                try:
                    a=db.doquery("select num,profile_num from ccgg.mobile_insitu_event where datetime=%s and lat=%s and lon=%s and alt=%s and vehicle_num=%s and intake_id=%s",(ukey))
                    if a :
                        evt=a[0]['num']#event num
                        #update  if needed.  
                        updEvent="update ccgg.mobile_insitu_event set expedition_id=%s, elev=%s, profile_num=%s,campaign_num=%s,elev_source=%s where num=%s"
                        updVals=(flight_num,elev,profile_num,campaign_num,elev_src,evt)
                        if self.update : db.doquery(updEvent,updVals)
                        else :print(updEvent,updVals)
                    else :
                        if self.update : evt=db.doquery(insEvent,vals,insert=True)
                        else : print(insEvent,vals)
                    
                    #Insert all parameters (that exist) for row
                    data=[]
                    insData="""insert ccgg.mobile_insitu_data (event_num,parameter_num,mobile_insitu_inst_num,value,stddev,n,interval_sec,unc)
                        values(%s,%s,%s,%s,%s,%s,%s,%s) on duplicate key update value=%s, stddev=%s, n=%s, unc=%s"""
        
                    for param,param_num in self.parameters.items():
                        (inst_num,val,stdv,nval,unc)=self.getParameterValues(df,r.Index, param)
                        if val and inst_num and interval_sec: #inst & interval are required, no point without val.
                            data.append((evt,param_num,inst_num,val,stdv,nval,interval_sec,unc,val,stdv,nval,unc))
                    
                    
                    #Calc windspeed and direction from uv if present.
                    #ws_num=58;wd_num=59;
                    #(inst_num,uval,stdv,nval,unc)=self.getParameterValues(df,r.Index, 'u_mps')
                    #(inst_num,vval,stdv,nval,unc)=self.getParameterValues(df,r.Index, 'v_mps')
                    
                    #if uval and vval and inst_num : #assume same inst.  Not sure what to do with stdv and nval, we'll use v for now and ask kathrin
                    #    ws="ccgg.f_windSpeed(%s,%s)" %(uval,vval)
                    #    wd="ccgg.f_windDir(%s,%s)" %(uval,vval)
                    #    data.append((evt,ws_num,inst_num,ws,stdv,nval,interval_sec,unc,ws,stdv,nval,unc))
                    #    data.append((evt,wd_num,inst_num,wd,stdv,nval,interval_sec,unc,wd,stdv,nval,unc))
                    
                    if(self.update):
                        for d in data : db.doquery(insData,d)
                    else : print(insData,data)
                    c+=1
                except Exception as e:
                    print(e)#db error on insert.
                    #continue
                    sys.exit()
            print("Rows processed successfully:",c)
            if skipped : print("Rows skipped: ",skipped)
            return c
        
        except Exception as e:
            print("Error reading "+fn)
            print(e)
            #sys.exit()
            return 0

    
    def getParameterValues(self, df,i, param):
        """Utility function to return tuple of parameter (inst_num,val,stdv,nval) if present else (None,None,None,None,None)"""
        #df; dataframe, i index of row, param is parameter value col name
        #Makes assumptions about column names.
        ret=(None,None,None,None,None)#pack Nones so above can unpack into vars
        p=param.split("_")[0]#get the parameter prefix
        if param in df.columns and not pd.isna(df.iloc[i][param]): #col present and not null
            val=df.iloc[i][param]
            #adjust if needed.
            if param == 'T_K' : val=val-273.15
            if param == 'P_Pa' : val=val/100
                    
            stdv=None if pd.isna(df.iloc[i][p+"_stdv"]) else df.iloc[i][p+"_stdv"]
            inst=None if pd.isna(df.iloc[i][p+"_Instrument_ID"]) else df.iloc[i][p+"_Instrument_ID"]
            nval=None if pd.isna(df.iloc[i][p+"_nvalue"]) else df.iloc[i][p+"_nvalue"]
            unc=None if pd.isna(df.iloc[i][p+"_unc"]) else df.iloc[i][p+"_unc"]
            ret=(self.getInstNum(inst,True),val,stdv,nval,unc)
        return ret
    
    
    
    
    
    
    
    
    
    def process_air_v1(fn,db,update,site_num,reader_version=1):
        #Kathryn's aircraft  files v1
    
        insEvent="""insert ccgg.mobile_insitu_event (site_num,project_num,strategy_num,expedition_id,datetime,lat,lon,alt,vehicle_num,profile_num,intake_id)
                values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
        insData="""insert ccgg.mobile_insitu_data (event_num,parameter_num,inst,value,stddev,n,interval_sec)
                values(%s,%s,%s,%s,%s,%s,%s) on duplicate key update value=%s, stddev=%s, n=%s"""
    
    
        #YYYYMMDD,UTC_Start,Lat_deg,Lon_deg,Alt_m,P_Pa,P_stdv,P_nvalue,T_K,T_stdv,
        #T_nvalue,RH_percent,RH_stdv,RH_nvalue,CO2_ppm,CO2_stdv,CO2_nvalue,CH4_ppb,CH4_stdv,
        #CH4_nvalue,CO_ppb,CO_stdv,CO_nvalue,H2O_percent,H2O_stdv,H2O_nvalue
        #20201230,26580,0.1902,32.5586,1211.7,86325,17,13,300.17,0.23,9,65.32,0.43,9,
        #421.27,0.87,3,2171.40,11.18,3,359.65,5.13,4,2.6273,0.0057,3
    
        #YYYYMMDD,UTC_Start,Lon_deg, Lat_deg,Alt_m,CH4_ppb,CH4_stdv,CH4_nvalue,CH4_unc,CH4_Instrument_ID,CO_ppb,CO_stdv,CO_nvalue,CO_unc,CO_Instrument_ID,CO2_ppm,CO2_stdv,CO2_nvalue,CO2_unc,CO2_Instrument_ID,H2O_percent,H2O_stdv,H2O_nvalue,H2O_unc,H2O_Instrument_ID,P_Pa,P_stdv,P_nvalue,P_unc,P_Instrument_ID,T_K,T_stdv,T_nvalue,T_unc,T_Instrument_ID,u_mps,u_stdv,u_nvalue,u_unc,u_Instrument_ID,v_mps,v_stdv,v_nvalue,v_unc,v_Instrument_ID,Profile_ID,Aircraft_ID
        #20171105,60200,-118.8740,55.1845, 669.76,2001.84,0.91,5,0.5,Picarro_CFKBDS2007,149.50,14.87,5,0.5,Picarro_CFKBDS2007,415.11,0.21,4,0.1,Picarro_CFKBDS2007,0.27,0.00,4,0.0,Picarro_CFKBDS2007,94888,14,19,100,Picarro_CFKBDS2007,265.5,0.1,16,0.4,Vaisala_HMP60,2.6,0.5,10,0.3,Aspen_Avionics_PFD1000,-0.2,0.1,10,0.3,Aspen_Avionics_PFD1000,0,ScientificAviation_MooneyOvation3_N617DH
        try:
            df=pd.read_csv(fn)
            c=0;evt=0;flight_num=0;
            #Load parameter keys.  These should probably all be looked up, but that seems wasteful as these don't change (famous last words)
            press_num=61; #source in pa. db records mbar | pa/100=mbar
            temp_num=60;#src in K, db in C   | k− 273.15=C
            rh_num=62;#%
            co2_num=1;ch4_num=2;co_num=3
            h2o_num=169;#%
            interval_sec=10;
            vehicle_type_num=1;#aircraft
            project_num=2;#ccg_aircraft
            strategy_num=3;#insitu
            ####These need to be retrieved from file header
            flight_num=1;site="UGD";vehicle_id='air1';intake_id=0
            ####s
            inst='PIC-008';####TEMP
            ####
            inst_id=db.doquery("select id from ccgg.inst where inst=%s",(inst,),numRows=0)
            site_num=db.doquery("select num from gmd.site where code=%s",(site,),numRows=0)
            vehicle_num=db.doquery("select num from vehicle where abbr=%s",(vehicle_id,),numRows=0)
            if not inst_id or not site_num : 
                print("Error; missing site/inst information or corresponding entry not in db. site:",site,":",site_num," inst:",inst,":",inst_id,". Sites need an entry in gmd.site, instruments n ccgg.inst")
                sys.exit()
            if not vehicle_num : #auto insert, the names can be cleaned up later.
                if update : vehicle_num=db.doquery("insert vehicle (name,abbr,vehicle_type_num) values (%s,%s,%s)",(vehicle_id,vehicle_id,vehicle_type_num),insert=True)
                else : vehicle_num=0
            
            print("Processing "+fn)
            df['dt']=pd.to_datetime(df['YYYYMMDD'],format='%Y%m%d')+pd.to_timedelta(df['UTC_Start'], unit='s')#convert dt
            for r in df.itertuples():
                #Insert, if needed, one at a time so we can get generated key
                profile_num=0
                if pd.isna(r.dt) or pd.isna(r.Lat_deg) or pd.isna(r.Lon_deg) or pd.isna(r.Alt_m) : 
                    print("Skipping row for missing primary key vals",r)
                    continue
                
                vals=(site_num,project_num,strategy_num,flight_num,r.dt.isoformat(),r.Lat_deg,r.Lon_deg,r.Alt_m,vehicle_num,profile_num,intake_id)
                ukey=(r.dt.isoformat(),r.Lat_deg,r.Lon_deg,r.Alt_m,vehicle_num,intake_id)#unique lookup key for row if exists
                try:
                    a=db.doquery("select num,profile_num from ccgg.mobile_insitu_event where datetime=%s and lat=%s and lon=%s and alt=%s and vehicle_num=%s and intake_id=%s",(ukey))
                    if a :
                        evt=a[0]['num']#event num
                        #update profile if needed.  This is the only one we'll update from file for now.
                        if a[0]['profile_num'] != profile_num:
                            u="update ccgg.mobile_insitu_event set profile_num=%s where num=%s"
                            if update : db.doquery(u,(profile_num,evt))
                            else :print(u,profile_num,evt)
                    else :
                        if update : evt=db.doquery(insEvent,vals,insert=True)
                        else : print(insEvent,vals)
                    
                    #ins/update data rows #event_num,parameter_num,inst,value,stddev,n,interval_sec
                    data=[]
                    if not pd.isna(r.CO2_ppm) and not pd.isna(r.CO2_stdv) and not pd.isna(r.CO2_nvalue):
                        data.append((evt,co2_num,inst_id,r.CO2_ppm,r.CO2_stdv,r.CO2_nvalue,interval_sec,r.CO2_ppm,r.CO2_stdv,r.CO2_nvalue))#co2 ppm
                    if not pd.isna(r.CH4_ppb) and not pd.isna(r.CH4_stdv) and not pd.isna(r.CH4_nvalue):
                        data.append((evt,ch4_num,inst_id,r.CH4_ppb,r.CH4_stdv,r.CH4_nvalue,interval_sec,r.CH4_ppb,r.CH4_stdv,r.CH4_nvalue))#ch4 ppb
                    if not pd.isna(r.CO_ppb) and not pd.isna(r.CO_stdv) and not pd.isna(r.CO_nvalue):
                        data.append((evt,co_num,inst_id,r.CO_ppb,r.CO_stdv,r.CO_nvalue,interval_sec,r.CO_ppb,r.CO_stdv,r.CO_nvalue))#co ppb
                    if not pd.isna(r.T_K) and not pd.isna(r.T_stdv) and not pd.isna(r.T_nvalue):
                        data.append((evt,temp_num,inst_id,r.T_K-273.15,r.T_stdv,r.T_nvalue,interval_sec,r.T_K-273.15,r.T_stdv,r.T_nvalue))#temp K->C (constant diff)
                    if not pd.isna(r.P_Pa) and not pd.isna(r.P_stdv) and not pd.isna(r.P_nvalue):
                        data.append((evt,press_num,inst_id,r.P_Pa/100,r.P_stdv/100,r.P_nvalue,interval_sec,r.P_Pa/100,r.P_stdv/100,r.P_nvalue))#press pa->mbar (change stdv by same multiple)
                    if not pd.isna(r.RH_percent) and not pd.isna(r.RH_stdv) and not pd.isna(r.RH_nvalue):
                        data.append((evt,rh_num,inst_id,r.RH_percent,r.RH_stdv,r.RH_nvalue,interval_sec,r.RH_percent,r.RH_stdv,r.RH_nvalue))#rh %
                    if not pd.isna(r.H2O_percent) and not pd.isna(r.H2O_stdv) and not pd.isna(r.H2O_nvalue):
                        data.append((evt,h2o_num,inst_id,r.H2O_percent,r.H2O_stdv,r.H2O_nvalue,interval_sec,r.H2O_percent,r.H2O_stdv,r.H2O_nvalue))#h2o %
                    if(update):
                        for d in data : db.doquery(insData,d)
                    else : print(insData,data)
                    c+=1
                except Exception as e:
                    print(e)#db error on insert.
                    #continue
                    sys.exit()
            print("Rows processed successfully:",c)
            return c
        
        except Exception as e:
            print("Error reading "+fn)
            print(e)
            sys.exit()
            return False

    
    
    
    
    
    
    
    
    
