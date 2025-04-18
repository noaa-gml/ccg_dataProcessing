#!/usr/bin/env python3
"""Procedures to import 10sec merge file from shipboard data file"""
!!!!Not programmed yet.. just a copy/stub
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

    
def process_air_v1(fn,db,update):
    #Kathryn's ai files v1
    
    insEvent="""insert ccgg.insitu_event (site_num,project_num,strategy_num,expedition_id,datetime,lat,lon,alt,vehicle_num,profile_num,intake_id)
            values(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)"""
    insData="""insert ccgg.insitu_data (event_num,parameter_num,inst,value,stddev,n,interval_sec)
            values(%s,%s,%s,%s,%s,%s,%s) on duplicate key update value=%s, stddev=%s, n=%s"""
    
    
    #YYYYMMDD,UTC_Start,Lat_deg,Lon_deg,Alt_m,P_Pa,P_stdv,P_nvalue,T_K,T_stdv,
    #T_nvalue,RH_percent,RH_stdv,RH_nvalue,CO2_ppm,CO2_stdv,CO2_nvalue,CH4_ppb,CH4_stdv,
    #CH4_nvalue,CO_ppb,CO_stdv,CO_nvalue,H2O_percent,H2O_stdv,H2O_nvalue
    #20201230,26580,0.1902,32.5586,1211.7,86325,17,13,300.17,0.23,9,65.32,0.43,9,
    #421.27,0.87,3,2171.40,11.18,3,359.65,5.13,4,2.6273,0.0057,3
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
                a=db.doquery("select num,profile_num from ccgg.insitu_event where datetime=%s and lat=%s and lon=%s and alt=%s and vehicle_num=%s and intake_id=%s",(ukey))
                if a :
                    evt=a[0]['num']#event num
                    #update profile if needed.  This is the only one we'll update from file for now.
                    if a[0]['profile_num'] != profile_num:
                        u="update ccgg.insitu_event set profile_num=%s where num=%s"
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

    
    
    
    
    
    
    
    
    
