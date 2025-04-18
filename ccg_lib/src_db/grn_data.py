#!/usr/bin/env python
"""Query tool for ccgg/hats database (discrete and insitu measurements).
call from command line with -h for help.

"""

import os
import sys
import datetime
import argparse

import db_utils.db_conn
import db_utils.bldsql



def grn_data (kwargs):
    '''Select data from ccgg db'''

    #This is a wrapper for below class so that it can be called as a function and for command line use.

    #If calling as a function from python code (not command line), kwargs is a dictionary of arguments ['option':'value'].
    #Note for backward compatibility the dict keys can be just the keyword or prefixed with '--'.
    #Call from cmd line with -h for details and examples.

    #otherwise we assume being called from commandline and kwargs is a list of strings (ie. from sys.argv).

    #Create flask obj that will build and do query
    f=GRNData(kwargs)

    #Return the results
    return f.doQuery()


#Dev Note; new filters need to be added to bldBaseQuery() and parseArgs() methods
#new columns need to be documented in parseArgs() and added to bldSelectQuery()
class GRNData(object) :
    def __init__(self, kwargs):
        super(GRNData, self).__init__()
        self.dev=False
        self.version=1.0
        self.args={}
        self.defaultValue=-999.9900 #for use when subing in for null
        self.defaultIntValue=-999
        self.defaultDateValue='1900-01-01'
        #Make ro connection to db with local handle
        #self.db=db_utils.db_conn.ReadOnlyDB()##below uses tmp. db for temp tables
        self.db=db_utils.db_conn.RO()
        self.setArgs(kwargs)#Note this can be called again on an instance to reset the query parameters and then recall doQuery().

        if self.args['verbose']>0 :
            print(("grn_data.py version: " + str(self.version)))
            if self.args['verbose']>1 :
                print("Arguments:")
                print((self.args))

    def doQuery(self):

        a=None
        sql=self.db.sql

        #Build the base query and fill temp table with target ids
        filtered=self.bldBaseQuery()

        #Build the select query using passed parameters
        self.bldSelectQuery()

        #If outputting tag dictonary, do that now.  Note, this must run after bldSelectQuery so that temp tables are created (if needed).
        if(self.args['tagDictionaryOutFile']):self.outTagDictionary(filtered,self.args['tagDictionaryOutFile'])

        #Figure out the requested output type
        output=self.args['output']
        outfile=self.args['outfile']
        fileFormats= self.db.availableFileFormats()
        if outfile: #if an outfile was passed, force file output.  Use file extension for format if not provided.
            if(output in fileFormats):
                form=output
            else : #parse extension for form.
                ext=os.path.splitext(outfile)[1][1:]
                form=ext if ext in fileFormats else 'txt' #default to txt if no valid passed.

        elif (output in fileFormats) : #output to file, no outfile provided, make a name up
            outfile = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")+"."+output
            form=output

        elif output=='screen' : form = 'std' #'scr'
        elif output=='map' :
            form="numpy"
            self.args['columns']=('lat','lon')
            self.db.sql.col('lat')
            self.db.sql.col('lon')
            self.db.sql.where("v.lat>-999 and v.lon>-999")
            self.db.sql.distinct()
            self.db.sql.orderby("lat desc")
            #self.db.sql.limit(150)

        else: #called from python, just pass return type or defaulted one if none.
            form=output

        if(self.args.get('verbose')>1):
            print(("Output query:" + sql.cmd() + "\nParameters:"))
            print((sql.bind()))

        #Set timer if requested
        timerName=None
        if self.args.get('verbose') : timerName="Retrieving and formatting data"

        #Do the query
        a=self.db.doquery(query=sql.cmd(),parameters=sql.bind(),form=form, outfile=outfile,timerName=timerName)

        if output=='map' : self.outputMap(a)

        return a
    def outputMap(self,a):
        if a :
            import py_utils.map
            map=py_utils.map.MapPlot(self.args.get('verbose'))
            map.createMap(a['lat'],a['lon'],self.args.get('mapZoom'))
        else : print("No data to plot")

    def bldSelectQuery(self):
        #Set and verify columns
        #Note; it would be easier to just pass on whatever user passed, but not very secure.  So we'll verify all cols are as expected.

        #define the macro cols
        #passed column of 'eventCols' expands to this:
        eventCols=['event_num','site','project','strategy','ev_datetime','ev_dd','flask_id','me','lat','lon','alt','elev']
        #eventCols2 has expanded date parts
        eventCols2=['event_num','site','project','strategy','ev_datetime','ev_year','ev_month','ev_day','ev_hour','ev_minute','ev_second','ev_dd','flask_id','me','lat','lon','alt','elev']
        #passed column of 'dataCols' expands to this:
        dataCols=['data_num','program','parameter','value','unc','flag','inst','a_datetime','a_dd','system']

        #define the superset(s) of avaialable columns
        allEventCols=['event_num','site','site_num','project','strategy','ev_date','ev_time','ev_datetime','ev_dd','flask_id','me','lat','lon','alt','elev','ev_comment','ev_year','ev_month','ev_day','ev_hour','ev_minute','ev_second','ev_alt_source','unique_sample_location_num']
        allDataCols=['data_num','program','parameter','value','unc','flag','inst','a_date','a_time','a_datetime','a_dd','a_comment','update_flag_from_tags']
        allTagCols=['tag_nums','tags','tag_names','tag_details','tag_details_formatted']
        dbMetCols=['press','temp','rh','ws','wd']
        narrMetCols=['narr_pressure','narr_air_temp','narr_spec_humidity']
        #era5MetCols=['era5_pressure','era5_air_temp','era5_rel_humidity','era5_spec_humidity','era5_potential_vorticity']
        era5MetCols=['era5_pressure','era5_air_temp','era5_spec_humidity']
        specialCols=['dataRequestCols_old','ccg_flask_compat']
        allMetCols=dbMetCols+narrMetCols+era5MetCols
        eventDetailCols=['prefill_manifold_flush', 'prefill_sample_flush', 'prefill_fill_vol', 'prefill_fill_pressure', 'prefill_each_duration_sec',
            'prefill_all_duration_sec', 'time_start_dt', 'time_end_dt'] # changing st/end to duration to deemphasize actual times which
            #may be inaccurate 'prefill_each_time_start_dt', 'prefill_each_time_end_dt' 'prefill_all_time_start_dt', 'prefill_all_time_end_dt',
        analysisCols=['anal_start_time','anal_end_time','anal_initial_press','anal_final_press','anal_system']
        #dict of actual col names in table (so can use in query below)
        analysisColSQLNames={'anal_start_time':'start_datetime','anal_end_time':'end_datetime','anal_initial_press':'initial_flask_press','anal_final_press':'final_flask_press','anal_system':'system'}
        footprintCols=['footprint_dir','footprint_file','footprint_type','footprint_subtype']
        footprintColSQLNames={'footprint_dir':'directory','footprint_file':'filename','footprint_type':'type','footprint_subtype':'subtype'}
        drierHistCols=['drier_type','method_abbr','d1_location','d2_location','d1_path_order','d2_path_order','d1_chiller_type','d2_chiller_type','d1_trap_type','d2_trap_type','d1_chiller_setpoint','d2_chiller_setpoint','d1_pressure_setpoint','d2_pressure_setpoint','d1_est_max_sample_h2o','d2_est_max_sample_h2o']

        allCols=allEventCols+allDataCols+allTagCols+allMetCols+specialCols+analysisCols+eventDetailCols+footprintCols+drierHistCols

        hasDataCol=False #Track whether we need to add a distinct
        tagProcCalled=False #Track whether we've already called the tag sp

        #Initialize and start the query builder
        db=self.db
        sql=db.sql
        sql.initQuery() #clear any previous queries.

        if self.args['cal_scale_test']:#use alt testing db
            sql.table("cal_scale_tests.cst_flask_data_view v");
        else :
            sql.table("ccgg.flask_data_view v")#Always select from this.  Note this will exclude flask_events that don't have any analysis measurements!
        sql.innerJoin("tmp.t_data t on v.data_num=t.data_num")#target ids
        #sql.where("v.data_num=t.data_num")
        sql.orderby("v.ev_datetime")
        sql.orderby("v.event_num")

        cols=[] #New list to hold all requested columns

        #Parse the requested col list, expanding any macro columns
        columns=self.args['columns']
        if(columns):
            a=columns.split(",")

            if(self.args.get('merge') or self.args.get('psuedo_pair_avg')):
                #force column list when in merge mode.
                if self.args.get('merge') and self.args.get('psuedo_pair_avg'):
                    print("Error, psuedo_pair_avg and merge modes can't be used together.")
                    sys.exit()
                if(self.args.get('merge')==2): #has date exploded and adds flags
                    for t in eventCols2 : cols.append(t)
                else:
                    for t in eventCols : cols.append(t)

                #if merge=4, add drier and ev tag cols too
                if(self.args.get('merge')==4):
                    for t in allMetCols : cols.append(t)
                    cols.append('eventTagNums')
                    cols.append('drier_type')
                    cols.append('method_abbr')

                #add some meta cols for below logic to process.
                if(self.args.get('merge')) : cols.append('mValues')
                if(self.args.get('psuedo_pair_avg')):cols.append('pairavg')

                #for t in mParamCols : cols.append(t)
                if not self.args.get('parameter_num') and not self.args.get("parameterprogram"):
                    print("Error, parameter(s) must be specified in merge mode and psuedo_pair_avg mode")
                    sys.exit()
            else:

                for col in a:
                    if(col=='eventCols'): cols.extend(eventCols)
                    elif(col=='eventCols2'): cols.extend(eventCols2)
                    elif(col=='dataCols'): cols.extend(dataCols)
                    elif(col=='dbMetCols'): cols.extend(dbMetCols)
                    elif(col=='narrMetCols'): cols.extend(narrMetCols)
                    elif(col=='era5MetCols'): cols.extend(era5MetCols)
                    elif(col=='allMetCols'): cols.extend(allMetCols)
                    elif(col=='analysisCols'): cols.extend(analysisCols)
                    elif(col=='eventDetailCols'): cols.extend(eventDetailCols)
                    elif(col=='footprintCols'): cols.extend(footprintCols)
                    elif(col=='drierHistCols'): cols.extend(drierHistCols)
                    else:
                        if (col in allCols) : cols.append(col)
                        else :
                            print(("Error: '%s' is not an available column (yet).  You can request that it be added." % (col,)))
                            #print(allCols)
                            sys.exit()

            if (self.args.get('tagDictionaryOutFile') and not ("tag_nums" in cols)) :
                cols.append("tag_nums") #ensure one tag col in cols if we are outputting dictionary (so proc gets run)

            #for each column, add to query with any needed joins.
            for col in cols:
                #track whether we need to add a distinct if event only data.  Note we'll just do it in all other cases, although some of the special ones may not need it.
                if(col in allDataCols):hasDataCol=True

                #special cases.  Note, this is in a loop so cases may be called more than once.  Care should be taken to not do extra work.
                if(col in allTagCols):
                    if(not tagProcCalled):
                    	#Make call to sp to fetch tagging details.
                    	db.doquery("drop temporary table if exists tmp.t_data_nums")
                    	db.doquery("create temporary table tmp.t_data_nums(index(num)) as select data_num as num from tmp.t_data")
                    	db.doquery("call tmp.tag_getTagDetails()")
                    	sql.leftJoin("tmp.t_tag_details td on t.data_num=td.data_num")
                    	tagProcCalled = True #Note this gets reset each time this method is called (if ever called again).

                    sql.col("td."+col)
                elif(col in footprintCols):
                    #join to stilt and hysplit tables
                    sql.leftJoin("footpack.info_v11 as stilt on stilt.event_num=v.event_num and stilt.type!='hatsflask' and stilt.subtype!='hats' and stilt.alt_index=0 and stilt.alt_type='agl'")
                    sql.leftJoin("footpack.hysplit as hysplit on hysplit.event_num=v.event_num and hysplit.type!='hatsflask' and hysplit.subtype!='hats' and hysplit.alt_index=0 and hysplit.alt_type='agl'")
                    #sql.where("(stilt.filename is not null or hysplit.filename is not null)")#THIS filters way too much.. I can't figure out why though.  Changed to normal left join. May want to split into different options
                    sql.col("stilt."+footprintColSQLNames[col]+" as '"+col+"_stilt'")
                    sql.col("hysplit."+footprintColSQLNames[col]+" as '"+col+"_hysplit'")
                elif(col in narrMetCols or col in era5MetCols):
                    #Join to flask_met
                    sql.leftJoin("flask_met met on v.event_num=met.event_num")
                    #sql.where("met.event_num=v.event_num",replace=True) #Only add once
                    sql.col("ifnull(met."+col+","+str(self.defaultValue)+") as '"+col+"'")#Default in when null/not present
                elif(col in drierHistCols):
                    #join to drier_hist_view
                    sql.leftJoin("drier_event_view dri on dri.event_num=v.event_num")
                    sql.col("ifnull(dri."+col+",'') as '"+col+"'")

                elif(col=='unique_sample_location_num'):
                    sql.leftJoin("obspack.gv_samples gvs on v.lat=gvs.lat and v.lon=gvs.lon and v.alt=gvs.alt and v.ev_datetime=gvs.start_dt and v.ev_datetime=gvs.mid_dt")
                    sql.col("ifnull(gvs.num,"+str(self.defaultIntValue)+") as '"+col+"'")

                elif(col in eventDetailCols):
                    #join to flask_event_detail
                    sql.leftJoin("flask_event_detail fl_ev_dt on v.event_num=fl_ev_dt.event_num")
                    if col.endswith("_dt") : sql.col("ifnull(fl_ev_dt."+col+",'"+str(self.defaultDateValue)+"') as '"+col+"'")
                    elif col == 'prefill_each_duration_sec' : #still not sure exactly why, but had to quote defaultValue for next two.  They were getting rounded to -1000.  Might be because
                        #some of col values were ints?  Appears to be in python (db query works as exected).
                        sql.col("ifnull(TIMESTAMPDIFF(second, fl_ev_dt.prefill_each_time_start_dt, fl_ev_dt.prefill_each_time_end_dt),'"+str(self.defaultValue)+"') as '"+col+"'")
                    elif col == 'prefill_all_duration_sec' :
                        sql.col("ifnull(TIMESTAMPDIFF(second, fl_ev_dt.prefill_all_time_start_dt, fl_ev_dt.prefill_all_time_end_dt),'"+str(self.defaultValue)+"') as '"+col+"'")
                    else : sql.col("ifnull(fl_ev_dt."+col+","+str(self.defaultValue)+") as '"+col+"'")#Default in when null/not present
                elif(col in analysisCols):
                    #join to flask_analysis
                    sqlcol=analysisColSQLNames[col]
                    sql.leftJoin("flask_analysis fl_an on v.event_num=fl_an.event_num and v.a_datetime>=fl_an.start_datetime and v.a_datetime<fl_an.end_datetime")
                    sql.col("ifnull(fl_an."+sqlcol+","+str(self.defaultValue)+") as '"+col+"'")
                elif(col in dbMetCols):#These are stored with params, so need to transform... pia.
                    #Subquery (cleanest) is super slow, our version of mysql doesn't optimize subqueries very well :(
                    #2nd try, left joining flask_data repeatedly was even worse on large sets
                    #3rd try, creating temp tables for each, seems to work pretty good.
                    # sql.col("""(select min(d_.value) from flask_data d_, gmd.parameter p_
                    #             where d_.event_num=v.event_num and d_.parameter_num=p_.num and lower(p_.formula) like lower('%s') ) as %s """ %(col,col))
                    num=self.db.doquery("select num from gmd.parameter where lower(formula) like lower(%s)",(col,),numRows=0)
                    if(num):  # I tried several variations, this turned out to be fastest.
                        # sql.leftJoin("flask_data d_%s on v.event_num=d_%s.event_num and d_%s.parameter_num=%s" % (col,col,col,num))
                        # sql.col("d_%s.value as %s" % (col,col))
                        db.doquery("drop temporary table if exists tmp.met_%s " % (col,))
                        db.doquery("""create temporary table tmp.met_%s (index i (event_num))  as
                                    select d.event_num,d.value
                                    from flask_data d, tmp.t_data t
                                    where d.num=t.data_num and d.parameter_num=%%s""" % (col,),(num,))#note 2nd param is bound
                        sql.leftJoin("tmp.met_%s on v.event_num=tmp.met_%s.event_num" % (col,col))
                        sql.col("ifnull(tmp.met_"+col+".value,"+str(self.defaultValue)+") as '"+col+"'")

                elif(col=='a_comment'):sql.col("v.comment as a_comment")
                elif(col=='eventTagNums'):sql.col("(select group_concat(tag_num) from flask_event_tag_view where event_num=v.event_num) as event_tags")
                elif(col=='mValues'):
                    parameters=self.args['parameter'].split(",")

                    for p in parameters :
                        flag='%' if self.args.get('flag')==None else self.args.get('flag')#jwm - 4/22.  Note defaults to .% unless specified because otherwise you may average multiple aliquots with one rejected
                        table="tmp.t_"+p
                        if self.args['cal_scale_test']:#use alt testing db
                            fl_tab="cal_scale_tests.flask_data"
                        else:
                            fl_tab="ccgg.flask_data"

                        if(self.args.get('merge')==3 or self.args.get('merge')==4) : #Sourish mode; special handling, no averaging, extra columns.  Mostly to support co2c14 queries.
                            #added 4 (gaby mode) to report tag_nums.
                            db.doquery("drop temporary table if exists "+table)
                            s="""create temporary table """+table+""" (index i (event_num)) as
                                       select d.num as data_num,d.event_num,d.value as value,d.flag, d.unc, d.comment
                                                from """+fl_tab+""" d, gmd.parameter p, tmp.t_data t
                                                where d.parameter_num=p.num and d.num=t.data_num
                                                    and upper(p.formula)=upper(%s)
                                                    and flag like %s"""
                            db.doquery(s,(p,flag))
                            sql.innerJoin(table+" on v.event_num="+table+".event_num")
                            sql.col("round(ifnull("+table+".value,-999.990),4) as '"+p+"'")#note; I left as ifnulls so can easily switch back to left join if requested.
                            sql.col("ifnull("+table+".unc,-999.99) as "+p+"_unc")
                            sql.col("ifnull("+table+".comment,'') as "+p+"_acomment")
                            sql.col("ifnull("+table+".flag,'') as "+p+"_flag")#jwm - 4/22 adding flag for all modes
                            sql.col("ifnull("+table+".data_num,'') as "+p+"_data_num")
                            if(self.args.get('merge')==4):
                                sql.col("(select group_concat(tag_num) from flask_data_tag_view where data_num="+table+".data_num) as "+p+"_data_tags")

                        else:
                            flag='.%' if self.args.get('flag')==None else self.args.get('flag')#jwm - 4/22.  Note defaults to .% unless specified because otherwise you may average multiple aliquots with one rejected
                            db.doquery("drop temporary table if exists "+table)
                            #jwm - rewrote to use paramertized, added -999 filter (incase flag passed %) Note; max(flag) is incorrect (misses !.. for ...) when flag passed %.  Didn't have an easy answer for this
                            s="""create temporary table """+table+""" (index i (event_num)) as
                                       select d.event_num,avg(d.value) as value,max(d.flag) as flag, avg(d.unc) as unc, group_concat(d.comment) as comment
                                                from """+fl_tab+""" d, gmd.parameter p, tmp.t_data t
                                                where d.parameter_num=p.num and d.num=t.data_num and d.value!=-999.99
                                                    and upper(p.formula)=upper(%s)
                                                    and flag like %s
                                                    group by d.event_num"""
                            db.doquery(s,(p,flag))
                            sql.leftJoin(table+" on v.event_num="+table+".event_num")
                            sql.col("round(ifnull("+table+".value,-999.990),4) as '"+p+"'")
                            sql.col("ifnull("+table+".flag,'') as "+p+"_flag")#jwm - 4/22 adding flag for all modes

                    sql.distinct()#Not sure if this is needed here, but was taking out for performance when not needed.. leaving here just in case

                elif(col=='pairavg') :
                    #real and psuedo pair averages.  see ccg_pairAverage sp for comments and details.
                    parameters=self.args['parameter'].split(",")
                    parameter='all' if(len(parameters)>1) else self.args['parameter']
                    if not self.args.get('site') :
                                print("Error, site must be specified psuedo_pair_avg mode")
                                sys.exit()
                    site=self.args['site'].split(",")[0]#just take the first one and ignore any others.

                    sdate=db.doquery("select date_format(min(ev_date),'%Y-%m-%d') from flask_data_view v join tmp.t_data t on v.data_num=t.data_num",numRows=0)
                    edate=db.doquery("select date_format(max(ev_date),'%Y-%m-%d') from flask_data_view v join tmp.t_data t on v.data_num=t.data_num",numRows=0)

                    #call proc to create temp db with results.
                    db.doquery("call tmp.ccg_pairAverage(%s,%s,%s,%s,%s)", (site,sdate,edate,parameter,self.args.get('psuedo_pair_avg')))
                    for p in parameters:
                        #create a temp table for each parameter, that contains value per event num
                        table="tmp.t_"+p
                        db.doquery("drop temporary table if exists "+table)
                        db.doquery("""create temporary table """+table+""" (index i (grp_event_num)) as
                               select distinct a.grp_event_num,a.avg_value,a.stddev_value,a.num_vals
                                        from flask_data_view d, tmp.t_pairAverages a, tmp.t_data t
                                        where d.data_num=t.data_num and a.grp_event_num=d.event_num
                                            and upper(d.parameter)=upper('"""+p+"""')
                        and a.parameter_num=d.parameter_num""")

                        sql.leftJoin(table+" on v.event_num="+table+".grp_event_num")
                        sql.col("round(ifnull("+table+".avg_value,-999.990),4) as '"+p+"'")
                        sql.col("round(ifnull("+table+".stddev_value,-999.990),4) as '"+p+"_stddev'")
                        sql.col("ifnull("+table+".num_vals,0) as '"+p+"_n'")

                    sql.innerJoin("tmp.t_pairAverages a on v.event_num=a.grp_event_num and v.parameter_num=a.parameter_num")#relies on distinct to uniquify
                    sql.distinct()
                    sql.col("a.grp_id")#uniquely ids the psuedo pair
                elif(col=='flag') :#If prelim was passed, sub in ..P as appropriate.
                    if(self.args['preliminary']):
                        sql.innerJoin("releaseable_flask_data_view rel on rel.data_num=v.data_num")
                        sql.col("case when rel.prelim=1 then concat(substring(v.flag,1,2),'P') else v.flag end as flag")
                    else : sql.col("v.flag")
                elif(col=='dataRequestCols_old' or col=='ccg_flask_compat'):#Special case to mimic old style of datarequest/ccg_flask
                    sql.col("v.site as sample_site_code")
                    sql.col("year(v.ev_date) as sample_year")
                    sql.col("month(v.ev_date) as sample_month")
                    sql.col("day(v.ev_date) as sample_day")
                    sql.col("hour(v.ev_datetime) as sample_hour")
                    sql.col("minute(v.ev_datetime) as sample_minute")
                    sql.col("second(v.ev_datetime) as sample_seconds")
                    sql.col("v.flask_id as sample_id")
                    sql.col("v.me as sample_method")
                    sql.col("v.parameter as parameter_formula")
                    sql.col("v.program as analysis_group_abbr")
                    sql.col("v.value as analysis_value")
                    sql.col("v.unc as analysis_uncertainty")
                    sql.col("v.flag as analysis_flag")
                    sql.col("v.inst as analysis_instrument")
                    sql.col("year(v.a_date) as analysis_year")
                    sql.col("month(v.a_date) as analysis_month")
                    sql.col("day(v.a_date) as analysis_day")
                    sql.col("hour(v.a_datetime) as analysis_hour")
                    sql.col("minute(v.a_datetime) as analysis_minute")
                    sql.col("second(v.a_datetime) as analysis_seconds")
                    sql.col("v.lat as sample_latitude")
                    sql.col("v.lon as sample_longitude")
                    sql.col("v.alt as sample_altitude")
                    sql.col("v.elev as sample_elevation")
                    sql.col("f_intake_ht(v.alt,v.elev) as sample_intake_height")
                    sql.col("v.event_num as event_number")
                    if(col=='ccg_flask_compat'):
                        sql.col("v.system")

                elif(col=='value') : sql.col("round(v.value,4) as value")
                elif(col=='ev_year') : sql.col("year(v.ev_date) as ev_year")
                elif(col=='ev_month') : sql.col("month(v.ev_date) as ev_month")
                elif(col=='ev_day') : sql.col("day(v.ev_date) as ev_day")
                elif(col=='ev_hour') : sql.col("hour(v.ev_time) as ev_hour")
                elif(col=='ev_minute') : sql.col("minute(v.ev_time) as ev_minute")
                elif(col=='ev_second') : sql.col("second(v.ev_time) as ev_second")
                elif(col=='ev_alt_source'): sql.col("case when locate('alt:',ev_comment)=0 then '' else substr(ev_comment,locate('alt:',ev_comment)+4,locate('~',ev_comment,locate('alt:',ev_comment))-(locate('alt:',ev_comment)+4)) end as ev_alt_source")
                else:
                    sql.col("v."+col)

            if(not hasDataCol):sql.distinct() # This is needed if all columns are event cols as current logic does filtering by data_num.  Note this is depended on by some callers (to get list of included tags)
            #print(sql.cmd())

            return True

        else : return False

    def outTagDictionary(self,filtered,outfile):
        #Returns dictionary list of tags.  If filtered=0, then all tags are returned, else just the tags for selected dataset.
        #select distinct concat(v.num,': (',v.group_name,') ',v.display_name) from t_range_nums t join tag_ranges r on t.range_num=r.num join tag_view v on v.num=r.tag_num order by v.num$$
        sql=db_utils.bldsql.BldSQL() #Open a 2nd sql instance so we don't overwrite the current query
        sql.initQuery()
        sql.table("tag_view v")
        sql.col("v.num as tag_num")
        sql.col("v.group_name")
        sql.col("v.display_name as description")
        #sql.col("concat(v.num,': (',v.group_name,') ',v.display_name) as 'display_name'")
        sql.distinct()
        if(filtered):
            sql.innerJoin("tag_ranges r on v.num=r.tag_num")
            sql.innerJoin("tmp.t_range_nums t on t.range_num=r.num")
        sql.orderby("v.num")

        #Parse outfile ext for type of file to create
        fileFormats= self.db.availableFileFormats()
        ext=os.path.splitext(outfile)[1][1:]
        form=ext if ext in fileFormats else 'txt' #default to txt if no valid passed.

        a=self.db.doquery(query=sql.cmd(), form=form, outfile=outfile)


    def bldBaseQuery(self):
        #Builds a temp table of target ids using all applicable filters.
        #This intermediate step is for flexibility.  This allows us to do further processing on the target
        #data (calling procedures like pair averaging, fetching tags...), using temp tables when needed and avoiding
        #the need for complicated joins.
        #Note that further filtering may be done above in the final select, this is just filtering basic ev/data to the target rows.

        #Returns the number of filters used (where count).  If 0, the temp table is just create (with a 1=0).

        #Alias some functions for lazy programmer
        sql=self.db.sql
        args=self.args
        f=self.setFilter

        #For the main join columns, do a little preprocessing to get the id values to make lookups more effecient by skipping the join to the lookup table.
        #This shouldn't be necessary, but the mysql optimizer (this ver) doesn't do this as well as it could (especially doing lookups on flask_data_view)
        #This will allow us to just query the 2 base tables in most cases.
        if(args.get('site')) : args['site_num']=self.getNumList('num','code','gmd.site',args['site'])
        if(args.get("parameter")) : args['parameter_num']=self.getNumList('num','formula','gmd.parameter',args['parameter'])
        if(args.get('strategy')) : args['strategy_num']=self.getNumList('num','abbr','ccgg.strategy',args['strategy'])
        if(args.get('project')) : args['project_num']=self.getNumList('num','abbr','gmd.project',args['project'])
        if(args.get('program')) : args['program_num']=self.getNumList('num','abbr','gmd.program',args['program'])

        #Special handling for parameterprogram.  looks like ch4~ccgg,sf6~hats.  This is for compat with ccg_flask.pl
        parameterprogram_whr=''
        if args.get("parameterprogram") :
            t=""
            try:
                for pp in args["parameterprogram"].split(","):
                    param,prog = pp.split("~") #errors if bad format
                    #Get the corresponding id nums.  It would be more efficient to pull out all and package together, but this is a compatibility option so we'll save that for later...
                    param_num=self.getNumList('num','formula','gmd.parameter',param)
                    prog_num=self.getNumList('num','abbr','gmd.program',prog)
                    t=sql.appendToList(t,"(d.program_num="+prog_num+" and d.parameter_num="+param_num+")"," or ")
                parameterprogram_whr="("+t+")"
            except Exception as e:
                    print(("Error parsing parameterprogram "+args.get("parameterprogram")))
                    raise Exception(e)
                    sys.exit();

        #Unpack legacy event and data constraints for compatiblity with callers to ccg_flask.pl
        #Format like lat:200,400~lon:80,90...
        if(args.get("event_constraints")):
            for t in args['event_constraints'].split("~"):
                col,constraints=t.split(":",1)#only split first match (in case there are times 12:32...)
                self.parseLegacyConstraints("event", col, constraints)
        if(args.get("data_constraints")):
            for t in args['data_constraints'].split("~"):
                col,constraints=t.split(":",1)
                self.parseLegacyConstraints("data", col, constraints)

        #Init the query builder
        sql.initQuery()

        #We'll build a temp table of ids to use in final select.  Note, we always select data_num even if caller is just selecting
        #event data.  This was a judgement call that not many callers only get flask data so the performance hit of doing a distinct in
        #final select is worth not having to excessively complicate the join logic with 2 logic paths
        sql.createTempTable("tmp.t_data","i(data_num)")

        sql.col('d.num as data_num')
        if args['cal_scale_test']:#use alt testing db
            sql.table("cal_scale_tests.flask_data d")
        else:
            sql.table("ccgg.flask_data d")
        sql.innerJoin("flask_event e on d.event_num=e.num")

        if args['exclusion']: #Filter out excluded data
            sql.innerJoin("releaseable_flask_data_view rel on d.num=rel.data_num")
            sql.where("rel.excluded=0")

        #Add all the filters.  Note I sometimes use the setFilter (f) wrapper when convienent, but it's just for laziness.  It adds them in same way.

        #Event filters
        f('event_num',comparator="in", ta='e',altColName='num')

        #   date ranges
        if args.get('from_ev_date') : sql.where("e.date>=%s",args['from_ev_date'])
        if args.get('from_ev_datetime') : sql.where("e.date>=%s",args['from_ev_datetime'])#This one is to make sure the query can use the date index
        if args.get('from_ev_datetime') : sql.where("timestamp(e.date,e.time)>=%s",args['from_ev_datetime'])#this one does the actual datetime filter
        if args.get('from_ev_dd') : sql.where("e.dd>=%s",args['from_ev_dd'])
        if args.get('from_ev_time') : sql.where('e.time>=%s',args['from_ev_time'])

        if args.get('to_ev_date') : sql.where("e.date<%s",args['to_ev_date'])
        if args.get('to_ev_date_inclusive') : sql.where("e.date<=%s",args['to_ev_date_inclusive'])
        if args.get('to_ev_datetime') : sql.where("e.date<%s",args['to_ev_datetime'])#This one is to make sure the query can use the date index
        if args.get('to_ev_datetime') : sql.where("timestamp(e.date,e.time)<%s",args['to_ev_datetime'])#this one does the actual datetime filter
        if args.get('to_ev_datetime_inclusive') : sql.where("e.date<=%s",args['to_ev_datetime_inclusive'])#This one is to make sure the query can use the date index
        if args.get('to_ev_datetime_inclusive') : sql.where("timestamp(e.date,e.time)<=%s",args['to_ev_datetime_inclusive'])#this one does the actual datetime filter
        if args.get('to_ev_dd') : sql.where("e.dd<%s",args['to_ev_dd'])
        if args.get('to_ev_time') : sql.where('e.time<%s',args['to_ev_time'])
        if args.get('to_ev_time_inclusive') :sql.where("e.time<=%s",args['to_ev_time_inclusive'])


        #f('site',comparator="in")
        f('site_num',comparator='in', ta='e')

        f('project_num',comparator='in', ta='e')
        f('strategy_num',comparator="in", ta='e')
        if args.get('ev_comment') : sql.where("e.comment like %s",args['ev_comment'])
        f('flask_id', ta='e',comparator='like', altColName='id')
        f('method', ta='e',comparator='in',altColName='me')
        f('from_lat',comparator='>=',altColName='lat', ta='e')
        f('from_lon',comparator='>=',altColName='lon', ta='e')
        f('from_alt',comparator='>=',altColName='alt', ta='e')
        f('from_elev',comparator='>=',altColName='elev', ta='e')
        f('to_lat',comparator='<',altColName='lat', ta='e')
        f('to_lon',comparator='<',altColName='lon', ta='e')
        f('to_alt',comparator='<',altColName='alt', ta='e')
        f('to_elev',comparator='<',altColName='elev', ta='e')
        f('to_lat_inclusive',comparator='<=',altColName='lat', ta='e')
        f('to_lon_inclusive',comparator='<=',altColName='lon', ta='e')
        f('to_alt_inclusive',comparator='<=',altColName='alt', ta='e')
        f('to_elev_inclusive',comparator='<=',altColName='elev', ta='e')

        #Data filters
        f('data_num',comparator="in",altColName='num')#convience wrapper for lazy programmer

        if args.get('from_a_date') : sql.where("d.date>=%s",args['from_a_date'])
        if args.get('from_a_datetime') : sql.where("d.date>=%s",args['from_a_datetime'])#This one is to make sure the query can use the date index
        if args.get('from_a_datetime') : sql.where("timestamp(d.date,d.time)>=%s",args['from_a_datetime'])#this one does the actual datetime filter
        if args.get('from_a_dd') : sql.where("d.dd>=%s",args['from_a_dd'])
        if args.get('from_a_time') : sql.where("d.time>=%s",args['from_a_time'])
        if args.get('to_a_time') :sql.where("d.time<%s",args['to_a_time'])
        if args.get('to_a_time_inclusive') :sql.where("d.time<=%s",args['to_a_time_inclusive'])
        if args.get('to_a_date') : sql.where("d.date<%s",args['to_a_date'])
        if args.get('to_a_datetime') : sql.where("d.date<%s",args['to_a_datetime'])#This one is to make sure the query can use the date index
        if args.get('to_a_datetime') : sql.where("timestamp(d.date,d.time)<%s",args['to_a_datetime'])#this one does the actual datetime filter
        if args.get('to_a_date_inclusive') : sql.where("d.date<=%s",args['to_a_date_inclusive'])
        if args.get('to_a_datetime_inclusive') : sql.where("d.date<=%s",args['to_a_datetime_inclusive'])#This one is to make sure the query can use the date index
        if args.get('to_a_datetime_inclusive') : sql.where("timestamp(d.date,d.time)<=%s",args['to_a_datetime_inclusive'])#this one does the actual datetime filter
        if args.get('to_a_dd') : sql.where("d.dd<%s",args['to_a_dd'])

        f('program_num',comparator='in')
        f('parameter_num',comparator="in")
        if parameterprogram_whr:sql.where(parameterprogram_whr)

        f('from_value',comparator=">=",altColName='value')
        f('to_value',comparator="<",altColName='value')
        f('from_unc',comparator=">=",altColName='unc')
        f('to_unc',comparator="<",altColName='unc')
        if(args.get('not_flag')):f('flag',comparator='not like')
        else:f('flag',comparator='like')

        f('inst')

        if args.get('a_comment') : sql.where("d.comment like %s",args['a_comment'])
        f('update_flag_from_tags')#1 or 0

        #search on tag
        #./grn_data.py --not_tag_num=10 -s=sgp --from_ev_date=20210801
        if args.get('tag_num'):
            #we can't conviently use parameterized query here, so pull out and filter if needed
            tag_nums=self.cleanNumList(args.get('tag_num'))
            if tag_nums:
                #join flask_data_tag_range dt on d.num=dt.data_num join tag_ranges r on dt.range_num=r.num;
                sql.leftJoin("flask_data_tag_view i_dtr on d.num=i_dtr.data_num")
                sql.leftJoin("flask_event_tag_view i_etr on d.event_num=i_etr.event_num")
                whr="(i_dtr.tag_num in ("+tag_nums+") or i_etr.tag_num in ("+tag_nums+"))"
                sql.where(whr)

        if args.get('not_tag_num'):
            tag_nums=self.cleanNumList(args.get('not_tag_num'))
            if tag_nums:
                #join flask_data_tag_range dt on d.num=dt.data_num join tag_ranges r on dt.range_num=r.num;
                sql.leftJoin("flask_data_tag_view e_dtr on d.num=e_dtr.data_num")
                sql.leftJoin("flask_event_tag_view e_etr on d.event_num=e_etr.event_num")
                whr="(e_dtr.tag_num is null or e_dtr.tag_num not in ("+tag_nums+")) and (e_etr.tag_num is null or e_etr.tag_num not in ("+tag_nums+"))"
                sql.where(whr)
        #print(sql.cmd())
        if(self.args.get('verbose')>1): #For debugging...
            print(("Target row query:" + sql.cmd() + "\nParameters:"))
            print((sql.bind()))

        #If there were no filters, just create the table.  This could be for getting other meta data(tag dictionary) or user error.  We don't want to allow whole db to get dumped in this case
        whereCount=sql.whereCount()
        if(sql.whereCount()==0):
            sql.where("1=0")

        #Send the query through.
        timerName=None if self.args.get('verbose')==0 else "Finding target rows"
        self.db.doquery(timerName=timerName)

        return whereCount


    def setFilter(self, arg, ta="d", comparator="=", altColName=None):
        #Helper convience method to add where clauses to the query builder
        #comparator can be standard sql comparators =,<=,<,>,>=, like or 'in' which does a where in (...)
        #ta (tableAlias) references the joined table alias name.  Default d refers to flask_data d
        if self.args.get(arg) :
            colname=ta+"."+arg if altColName==None else ta+"."+altColName
            if comparator == "in" :
                t=self.args[arg]
                if t.startswith("-"):#Not in
                    t=t[1:]#Strip the -
                    self.db.sql.wherein(colname+" not in ",t.split(","))
                else : self.db.sql.wherein(colname+" in ",self.args[arg].split(","))
            elif comparator == 'like' : self.db.sql.where(colname+" like %s",self.args[arg])
            elif comparator == 'not like' : self.db.sql.where(colname+" not like %s",self.args[arg])
            else : self.db.sql.where(colname+comparator+"%s",self.args[arg])

    def cleanNumList(self,numlist):
        #validate list of comma sep nums is actually all numbers.  For use when can't parameterize query input (like in join)
        a=[]
        t=numlist.split(',')
        for i in t:
            try:
                x=int(i)
                a.append(x)
            except:
                print("invalid tag_num:",i)
                sys.exit()
        r=",".join([str(i)for i in a])
        return r

    def getNumList(self,idcol,abbr,table,values):
        #helper convienence method to return id list for abbr/code list on lookup tables
        #If only 1 value this returns 1 num, if values is comma separated list of values (co2,ch4,co...) it returns a list of corresponding nums (not ordered)
        sql=self.db.sql
        sql.initQuery()
        sql.table(table)
        sql.col("group_concat("+idcol+")")
        sql.wherein(abbr+" in ",values.split(","))
        a=self.db.doquery(None,None,0)
        #make sure we could find all passed
        if a==None or len(str(values).split(','))!=len(str(a).split(',')):
            print(("Error, 1 or more parameters not found:"+values))
            sys.exit()
        return a

    def setArgs(self,kwargs):
        #Set defaults or overrides into master args list.

        self.args={} #Reset each call for re-use.
        kw=self.parseArgs(kwargs)#Filters and sets defaults for all arguments.

        #Attempt to set a rational default for output (screen) if caller is cmdline.
        if (kw['output'] == 'dict' or kw['output']=='list' or kw['output']=='numpy') and kw['callsrc']=='cmdline': kw['output']='screen'

        self.args=kw
    def parseLegacyConstraints(self, tbl, col, constraints):
        #Utility to parse legacy constraints
        #Format like lat:200,400~lon:80,90...
        args=self.args
        c=constraints.split(",")#1 or more

        if(tbl=='event'):
            #first few are 1+ lists.
            if col == 'num' : args['event_num']=constraints
            if col == 'site_num' : args['site_num']=constraints
            if col == 'project_num' : args['project_num']=constraints
            if col == 'strategy_num' : args['strategy_num']=constraints
            #Note sure if legacy supported multiple for these, be we only support 1
            if col == 'id' : args['flask_id']=c[0]
            if col == 'me' : args['me']=c[0]
            if col == 'comment' : args['ev_comment']=constraints #don't try to parse this one
            #ranges
            if col == 'date':
                args['from_ev_date']=c[0]
                if(len(c)>1):args['to_ev_date_inclusive']=c[1]
            if col == 'time':
                args['from_ev_time']=c[0]
                if(len(c)>1):args['to_ev_time_inclusive']=c[1]
            if col == 'lat':
                args['from_lat']=c[0]
                if(len(c)>1):args['to_lat_inclusive']=c[1]
            if col == 'lon':
                args['from_lon']=c[0]
                if(len(c)>1):args['to_lon_inclusive']=c[1]
            if col == 'alt':
                args['from_alt']=c[0]
                if(len(c)>1):args['to_alt_inclusive']=c[1]
            if col == 'elev':
                args['from_elev']=c[0]
                if(len(c)>1):args['to_elev_inclusive']=c[1]
        else:#flask data
            if col == 'num' : args['data_num']=constraints
            if col == 'event_num' : args['event_num']=constraints
            if col == 'program_num' : args['program_num']=constraints
            if col == 'parameter_num' : args['parameter_num']=constraints
            if col == 'date':
                args['from_a_date']=c[0]
                if(len(c)>1):args['to_a_date_inclusive']=c[1]
            if col == 'time':
                args['from_a_time']=c[0]
                if(len(c)>1):args['to_a_time_inclusive']=c[1]
            if col == 'value':
                args['from_value']=c[0]
                if(len(c)>1):args['to_value']=c[1]
            if col == 'unc':
                args['from_unc']=c[0]
                if(len(c)>1):args['to_unc']=c[1]
            if col == 'flag': args['flag']=constraints
            if col == 'inst': args['inst']=constraints
            if col == 'comment': args['a_comment']=constraints


    def parseArgs( self, kwargs ):
        #Common parsing logic for python code and command line callers.
        #This defines the allowed list of arguments.

        descText="grn_data.py version: "+str(self.version)+"""
------------------

This program retrieves data from ccgg flask/pfp measurements

(Note; calling format for parameters has recently changed!)

This can be called from command line as a script or natively from
python as a function.

Parameters are passed slightly differently depending on whether this
is being called from command line or from python code.
From command line, pass each arguement as --kword=value ...
Python code should pass as a dict ({'kword':'value','--kword2':'value'...})
Note for flag type options, pass value as literal boolean True:
{'cal_scale_test':True}
See examples below.

        """
        epilogText="""
------------------
Examples:

###########
Calling from python program:
###########
#!/usr/bin/env python

import sys

if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')

from grn_data import grn_data

#default output format is a list of row dictionaries.  Pass flag options as boolean True
args={'site':'car', 'from_ev_date':'2004-03-01', 'to_ev_date':'2004-04-01','g':'co2,ch4','preliminary':True}
a=grn_data(args)
if a :
    for row in a:
        print ("num: %s datetime: %s parameter: %s value: %s" % (row['event_num'],row['ev_datetime'],row['parameter'],row['value']))


#If numpy is available, you can output directly to numpy arrays
args['output']='numpy'
a=grn_data(args)
if a : #a is a dictionary of column arrays (colname:coldata)
    print(a)

#you can also output directly to file if needed:
args['output']='csv'
args['outfile']='out.dat'
a=grn_data(args) #output written to out.dat in current working directory

#columns can be specified:
args['cols']='event_num,site,ev_datetime,parameter,value,narrMetCols,era5MetCols'
a=grn_data(args)


###########
Command line Examples:
###########
/ccg/src/db/grn_data.py --cols='eventCols,narrMetCols,era5MetCols' --site=CAR --from_ev_date=2004-01-01 --to_ev_date=2005-01-01
    ->event details + narr met cols for car, samples in 2004

/ccg/src/db/grn_data.py --site=CAR,alt --from_ev_date=2004-02-02 -g=co2,ch4 --flag=..%
    -> car and alt, from date, 2 gases, non rejected, standard columns

/ccg/src/db/grn_data.py --inst=pr1 --cols=event_num --from_a_date='2016-01-01'
    -> all event #'s with PR1 measurements since 2016

/ccg/src/db/grn_data.py --site='car' -g=co2 --from_ev_dd=2004.0 --to_ev_dd=2004.6 --to_alt=6000 --outfile='/tmp/out.csv'
    -> car measurements from first half of 2004, under alt:6000, send to csv file

/ccg/src/db/grn_data.py --site=NWR --psuedo_pair_avg=1 -g=co2,co2c14 --flag='.%%'
    -> nwr co2,co2c14 with actual and psuedo pairs averaged together.

/ccg/src/db/grn_data.py --site=car --program=hats --from_ev_date='2015-01-01' --cols='eventCols,dataCols,tag_nums' --tagDictionaryOutFile=/tmp/tags.txt --flag='.%' --not_flag
    ->reject data from 2015 forward for hats CAR data, write tag defs to file.
bs_getJSTimestamp
/ccg/src/db/grn_data.py --site=hip --to_ev_date=2010-01-01 --output=map -g=co2
    ->show hippo samples thru 2010 on a map

/ccg/src/db/grn_data.py --from_a_date='2019-05-01' --to_a_date='2019-09-01' --cols='event_num,dataCols,analysisCols' -g='co2'
    ->show analysis details of co2 measurements since 2019-05-01 including analysis system details (flask pressures and start/end times)

/ccg/src/db/grn_data.py --from_lat=50 --cols=eventCols,footprintCols -g=co2,ocs,co2c13 --outfile=/home/ccg/mund/tmp/t.csv
    ->show events >= 50 degrees lat that measured co2,ocs or co2c13 with any footprints available.  Write to outfile

        """
        #Set up the parser rules
        parser=argparse.ArgumentParser(description=descText,epilog=epilogText,formatter_class=argparse.RawTextHelpFormatter)
        parser.add_argument('-c','--columns', '--cols',default='eventCols,dataCols',help="""A list of columns to output (comma separated)
The default if not specified is the commom columns from sample and measurements
~Can use macros:
    eventCols=['event_num','site','project','strategy','ev_datetime','ev_dd',
        'flask_id','me','lat','lon','alt','elev']
    dataCols=['data_num','program','parameter','value','unc','flag','inst',
        'a_datetime','a_dd']
    dbMetCols=['press','temp','rh','ws','wd']
    narrMetCols=['narr_pressure','narr_air_temp','narr_spec_humidity']
    era5MetCols=['era5_pressure','era5_air_temp',era5_spec_humidity]
    allMetCols=dbMetCols and narrMetCols and era5MetCols
    eventDetailCols=['prefill_manifold_flush', 'prefill_sample_flush', 'prefill_fill_vol', 'prefill_fill_pressure', 'prefill_each_duration_sec','prefill_all_duration_sec', 'time_start_dt','time_end_dt']
        analysisCols=['anal_start_time','anal_end_time','anal_initial_press','anal_final_press','anal_system']
    dataRequestCols_old=columns (and names) used by the datarequest handler
    ccg_flask_compat=columns (and names) as ouput by ccg_flask.pl (for compatability)
    analysisCols=Analysis system details (when available)['anal_start_time','anal_end_time','anal_initial_press','anal_final_press','anal_system']
    footprintCols=['footprint_dir','footprint_file','footprint_type','footprint_subtype']
    drierHistCols=['drier_type','d1_location','d2_location','d1_path_order','d2_path_order','d1_chiller_type','d2_chiller_type','d1_trap_type','d2_trap_type','d1_chiller_setpoint','d2_chiller_setpoint','d1_pressure_setpoint','d2_pressure_setpoint','d1_est_max_sample_h2o','d2_est_max_sample_h2o','method_abbr']

    Note; footprint files are restricted to alt_index=0 and alt_type='agl'

~Default is 'eventCols,dataCols'
~You can also mix with individual columns, master list of available columns is:
    'event_num','site','site_num','project','strategy','ev_date','ev_time',
    'ev_datetime','ev_dd','flask_id','me','lat','lon','alt','elev',
    'ev_comment','data_num','program','parameter','value','unc','flag','inst',
    'a_date','a_time','a_datetime','a_dd','a_comment','update_flag_from_tags',
    'tag_nums','tags','tag_names','tag_details','tag_details_formatted','press','temp','rh','ws','wd',
    'prefill_manifold_flush', 'prefill_sample_flush', 'prefill_fill_vol', 'prefill_fill_pressure', 'prefill_each_duration_sec', 'prefill_all_duration_sec', 'time_start_dt','time_end_dt', 'narr_pressure','narr_air_temp', 'narr_spec_humidity', 'ev_alt_source', 'era5_pressure', 'era5_air_temp', 'era5_spec_humidity',
    'anal_start_time', 'anal_end_time','anal_initial_press', 'anal_final_press', 'anal_system'
    'footprint_dir','footprint_file','footprint_type','footprint_subtype,'unique_sample_location_num',
    'drier_type','method_abbr','d1_location','d2_location','d1_path_order','d2_path_order','d1_chiller_type','d2_chiller_type','d1_trap_type','d2_trap_type','d1_chiller_setpoint','d2_chiller_setpoint','d1_pressure_setpoint','d2_pressure_setpoint','d1_est_max_sample_h2o','d2_est_max_sample_h2o'
    Note; all met variables have a default value of -999.99
    Note; footprint files are restricted to alt_index=0 and alt_type='agl'
    ex: 'eventCols, parameter, value'
    or: 'site,ev_datetime,parameter,value,narr_pressure'
""")

        #Note output default of 'dict' is looked for in setArgs code above, so check there if changing.
        parser.add_argument("--output",default='dict',help="""Output format.
Defaults to a list of row dictionaries for native python calls
and screen for command line callers.
~python native options(must be called from python as function):
    'dict' -> (Default for python calls) a list of row dictionaries.
        Each row is a dictionary with a colname:value for each selected column
    'list' -> a list of row lists.
        Each row is in same order as specified in columns
    'numpy'-> a dictionary of numpy column arrays.
        Each key is the column name. (Must have numpy installed)

~command line specific
    'screen' -> (Default for command line calls) output sent to standard out

~file output formats either caller can use
    'csv'   -> Comma separated values.  Text fields are quoted, quotes are
        double quoted to escape.
    'tsv'   -> tab separated values.  Any embedded tabs are removed from
        text fields
    'dat'   -> formatted text lines
    'txt'   -> formatted text lines
    'excel' -> excel compatible csv output
    'csv-nq'-> csv, no quoting
    'map'   -> plot events on a global map.  Requires X windows.  While not required,
                specifying a species (-g=co2) makes it much faster.  You can use --mapZoom=[1,2,3]
                to zoom display
    (not programmed yet)'npy'   -> numpy native format.

If no outfile is specified, one will be created in current
directory using current datetime and output format ext
""")
        parser.add_argument('-o',"--outfile",'--o',help="""Name of output file.  If an output specified (above), format will
follow file extension.  See --output for allowed extensions""")#--o is for backwards compat with python callers (so 'g':'co' is accepted)
        parser.add_argument('-m','--merge','--m',default=0,choices=(0,1,2,3,4), type=int,help="Merge multiple parameters onto 1 line for a sample.  0-> no merge (default), 1-> merge multiple parameters onto 1 line and average multiple aliquots, 2-> same, but with flag and expanded date cols, 3-> Sourish mode; merge multiple parameters onto one line, limits to rows with values for all parameters and adds unc, flag & acomment for each parameter.  No averaging, so some values may be repeated if there are multiple aliquots for one of the reported species. 4 (Gaby mode), same as Sourish mode (no averaging) but with narr/era5 cols, event tag nums and data tag nums for each species. Note preliminary (..P) flag is not applied in merge mode. Also note; merge mode 1 & 2 default to flag filter of .%% (retained data only) and substitute a -999.99 value and '' for flag when rejected.  This is because data is averaged and rejected data would get averaged with retained when there are multiple aliquots.  If you want to see flagged data, pass --flag=%%")
        parser.add_argument('--psuedo_pair_avg',default=0,choices=(0,1,2), type=int, help="""If passed 1, actual flask pair and psuedo pair values are averaged together.  Output columns are not configureable.  Mode 1 is defined as:
        -Only considers ccg_surface/aircraft, flask/pfp
        -same site, project,strategy, method and:
            -strategy flask -> no psuedo pairs, always have same datetime.
            -strategy pfp, project surface -> datetime within 30 min
            -strategy pfp, project aircraft same time only-> no atempt at psuedo pairing is made because the 2nd cylinder of the pair is always for co2c14.
    If passed 2, then only actual pairs are returned (same datetime), no time window pairs.

	Site is required for this option.  Only one site can be used per call.
	Average value for each passed gas, stddev and n are reported along with a unique grp_id which identifies the psuedo pair (which can contain more than 2 flasks).  The grp_id is a concatenation of member event numbers.
	Event data from first event is reported.
	Some measurement filters may not be entirely honored ie- data from paired events may be included in averages even if they don't meet a passed measurement filter (like anal date).  See John for questions.
	""")

        parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')
        parser.add_argument("--exclusion",action='store_true',help="If passed, excluded data is removed from output")
        parser.add_argument("--preliminary",action='store_true',help="If passed, preliminary data is flagged with a 3rd column P. Note preliminary (..P) flag is not applied in merge mode.")

        parser.add_argument("--tagDictionaryOutFile",help="File name to write tag dictonary to.  If called without other query parameters, entire dictionary is output.  If called with query parameters (normal data query), only applicable tags are output.  Use file extension to create appropriate file type (e.g. .csv for a comma separated file, .txt for formatted text file...)",default='')
        parser.add_argument('--mapZoom', default=0,choices=(0,1,2,3),type=int, help='When output=map, mapZoom can be used to zoom in the map from 0 (none) to 3(most)')
        #Sample filters
        evgrp=parser.add_argument_group("Sample Event Filters")
        evgrp.add_argument("-e",'--event_num',help="One or more (comma separated) event numbers");
        evgrp.add_argument("--event_constraints",help="Event constraints in format of ccg_flask.pl (compatibility)")
        evgrp.add_argument('-s','--site','--s',help='One or more (comma separated) site codes. Prefix with a - to exclude list.')
        evgrp.add_argument("--strategy","--st",help="""One or more (comma separated) strategies (flask,pfp,insitu)
(insitu not programmed yet)""")
        evgrp.add_argument('--project',help='One or more (comma separated) projects (ccg_surface,ccg_aircraft)')
        #Sample date/time
        evgrp.add_argument('--from_ev_date',help="Sample date >= from_ev_date")
        evgrp.add_argument('--from_ev_datetime',help="Sample date+time >= from_ev_datetime (ex: '2015-02-03 12:34:22')")
        evgrp.add_argument('--from_ev_time',help="Sample time>= from_ev_time (allows filtering by hours of the day)")
        evgrp.add_argument('--from_ev_dd',help="Sample digital date >= from_ev_dd")
        evgrp.add_argument('--to_ev_date',help="Sample date < to_ev_date")
        evgrp.add_argument('--to_ev_date_inclusive',help="Sample date <= to_ev_date_inclusive")
        evgrp.add_argument('--to_ev_datetime',help="Sample date+time < to_ev_datetime (ex: '2015-02-03 12:34:22')")
        evgrp.add_argument('--to_ev_datetime_inclusive',help="Sample date+time <= to_ev_datetime_inclusive (ex: '2015-02-03 12:34:22')")
        evgrp.add_argument('--to_ev_time',help="Sample time < to_ev_time (allows filtering by hours of the day)")
        evgrp.add_argument('--to_ev_time_inclusive',help="Sample time <= to_ev_time_inclusive (allows filtering by hours of the day)")
        evgrp.add_argument('--to_ev_dd',help="Sample digital date < to_ev_dd")
        #ID/Method
        evgrp.add_argument('--flask_id','--id',help="Flask ID")
        evgrp.add_argument('--method','--me',help="Collection Method.  Prefix with a '-' to exclude list.")
        #Position
        evgrp.add_argument('--from_lat',help="Events with lat >= from_lat")
        evgrp.add_argument('--to_lat',help="Events with lat < to_lat")
        evgrp.add_argument('--to_lat_inclusive',help="Events with lat <= to_lat")
        evgrp.add_argument('--from_lon',help="Events with lon >= from_lon")
        evgrp.add_argument('--to_lon',help="Events with lon < to_lon")
        evgrp.add_argument('--to_lon_inclusive',help="Events with lon <= to_lon")
        evgrp.add_argument('--from_alt',help="Events with alt >= from_alt")
        evgrp.add_argument('--to_alt',help="Events with alt < to_alt")
        evgrp.add_argument('--to_alt_inclusive',help="Events with alt <= to_alt")
        evgrp.add_argument('--from_elev',help="Events with elevation >= from_elev")
        evgrp.add_argument('--to_elev',help="Events with elevation < to_elev")
        evgrp.add_argument('--to_elev_inclusive',help="Events with elevation <= to_elev")
        evgrp.add_argument('--ev_comment',help="Events with comment equal to string ev_comment.  Use %% for wildcards")
        #Measurement filters
        dgrp=parser.add_argument_group("Data (measurement) Filters")
        dgrp.add_argument('--data_num','--data_nums',help="One or more (comma separated) data numbers")
        dgrp.add_argument("--data_constraints",help="Data constraints in format of ccg_flask.pl (compatibility)")
        dgrp.add_argument('--program',help="One or more programs (ccgg,sil,arl,curl,hats)")
        dgrp.add_argument('-g','--parameter','--parameters','--g',help='One or more parameters (comma separated).  Prefix with a - to exclude list.')#--g is for backwards compat with python callers (so 'g':'co' is accepted)
        dgrp.add_argument("--parameterprogram",help='Pass this to specifiy the program for parameter (for gases like sf6 that are measured by hats and ccgg).  Pairs have a tilde join, multiple are separated by comma like; sf6~hats,co~ccgg')
        #anal time
        dgrp.add_argument('--from_a_date',help='Analysis date >= from_a_date')
        dgrp.add_argument('--from_a_datetime',help="Analysis date+time >= from_a_datetime (ex: '2015-02-03 12:34:22')")
        dgrp.add_argument('--from_a_dd',help='Analysis digital date >= from_a_dd')
        dgrp.add_argument('--from_a_time',help='Analysis time >= from_a_time')

        dgrp.add_argument('--to_a_date',help='Analysis date < to_a_date')
        dgrp.add_argument('--to_a_date_inclusive',help='Analysis date <= to_a_date_inclusive')
        dgrp.add_argument('--to_a_datetime',help="Analysis date+time < to_a_datetime (ex: '2015-02-03 12:34:22')")
        dgrp.add_argument('--to_a_datetime_inclusive',help="Analysis date+time <= to_a_datetime_inclusive (ex: '2015-02-03 12:34:22')")
        dgrp.add_argument('--to_a_dd',help='Analysis digital date < to_a_dd')
        dgrp.add_argument('--to_a_time',help='Analysis time < to_a_time')
        dgrp.add_argument('--to_a_time_inclusive',help='Analysis time <= to_a_time_inclusive')

        #val/unc
        dgrp.add_argument('--from_value',help="Values >= from_value")
        dgrp.add_argument('--to_value',help="Values < to_value")
        dgrp.add_argument('--from_unc',help="Uncertainty >= from_unc")
        dgrp.add_argument('--to_unc',help="Uncertainty < to_unc")

        #flag/inst/comment
        dgrp.add_argument('-f','--flag',help="3 letter traditional external flag is like [flag]. Uses %% for wild card ex; pass '..%%' to get all non-rejected, non-selection issue measurements. Default is '' which returns all data.  Note when in merge mode (multiple parameters), rejected parameters will have -999.99 for a value")
        dgrp.add_argument("--not_flag",action='store_true',help="Pass --not_flag to negate --flag option.  For example --flag='.%%' returns all non-rejected data.  If --not_flag is added, then only rejected data is returned.")
        dgrp.add_argument('--inst',help='Measurement instrument')
        dgrp.add_argument('--a_comment',help='Analysis rows with comment equal to string a_comment.  Use %% for wildcards')
        dgrp.add_argument('--cal_scale_test',action='store_true',help='Pass this to select measurement data from the calibration scale testing database.  Note; only ccgg gases available at the moment, and flagging may not be consistent.  Does not work with pair averaging or data exclusion/release.  Other caveats apply, ask John Mund for details if you want to use.')
        dgrp.add_argument('--tag_num',help="One or more (comma separated) tag numbers.  Results filtered to include only rows with 1+ passed tags")
        dgrp.add_argument("--not_tag_num",help="One or more (comma separated) tag numbers.  Results filterd to exclude rows with 1+ passed tags")
        #Hidden argument for internal logic
        parser.add_argument('--callsrc',default='python',help=argparse.SUPPRESS, choices=('python','cmdline'))

        #kwargs can either be a dictionary (when called from code) or a list (sys.argv from command line callers)
        #If a dict, turn it into a list like sys.argv so we can use the common parsing logic.
        t=list()

        if isinstance(kwargs,dict):
            for n,v in list(kwargs.items()):
                if n.startswith("-") : t.append(n) #if it already starts with a -, just pass through.
                else : t.append("--"+n) #prepend with the '--option' syntax for the argparser below.
                #Followed by the value , if passed true, assume a flag type and skip
                if v is True and type(v) == bool : continue
                else :t.append(v)
        else : t=kwargs

        #add help if no arguments were passed.
        if(len(t)==0):t.append("--help");

        #Pass through the parser
        opts = parser.parse_args(t)

        #Create a keyword dictionary of the results
        keyw = {}
        keyw=vars(opts);
        return keyw

#####################End class def





# main body if called as script

if __name__ == "__main__":

    t=list(sys.argv[1:])#Make a copy of the command line arguments so we can append a little meta info to it

    #add help if no arguments were passed.
    if(len(t)==0):t.append("--help");

    t.append("--callsrc=cmdline")#This sets some defaults (like output to screen) when needed.

    r = grn_data(t)#call the wrapper function

    sys.exit( 0 )
