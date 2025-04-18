#!/usr/bin/env python
"""Query tool for ccgg database (mobile_insitu measurements).
call from command line with -h for help.
This is python3 compatable
"""

import os
import sys
import datetime
import argparse

import db_utils.db_conn
import db_utils.bldsql



def ccg_mobile_insitu (kwargs):
    '''Select data from ccgg db mobile insitu tables'''

    #This is a wrapper for below class so that it can be called as a function and for command line use.

    #If calling as a function from python code (not command line), kwargs is a dictionary of arguments ['option':'value'].
    #Note for backward compatibility the dict keys can be just the keyword or prefixed with '--'.
    #Call from cmd line with -h for details and examples.

    #otherwise we assume being called from commandline and kwargs is a list of strings (ie. from sys.argv).

    #Create  obj that will build and do query
    f=CCGMobileInsitu(kwargs)

    #Return the results
    return f.doQuery()


#Dev Note; new filters need to be added to bldBaseQuery() and parseArgs() methods
#new columns need to be documented in parseArgs() and added to bldSelectQuery()
class CCGMobileInsitu(object) :
    def __init__(self, kwargs):
        super(CCGMobileInsitu, self).__init__()
        self.dev=False
        self.version=1.0
        self.args={}
        self.defaultValue=-999.9900 #for use when subing in for null
        self.defaultDateValue='1900-01-01'
        #Make ro connection to db with local handle
        self.db=db_utils.db_conn.ReadOnlyDB()

        #define the macro cols.  Needs to be here so can use in help.
        #passed column of 'eventCols' expands to this:
        self.eventCols=['event_num','site','project','strategy','ev_datetime','ev_dd','lat','lon','alt','elev','expedition_id','vehicle','profile_num','intake_id','campaign']
        #passed column of 'dataCols' expands to this:
        self.dataCols=['data_num','program','parameter','value','unc','flag','inst','stddev','n','unc','interval_sec']
        #define the superset(s) of avaialable columns
        self.allCols=self.eventCols+self.dataCols

        self.setArgs(kwargs)#Note this can be called again on an instance to reset the query parameters and then recall doQuery().

        if self.args['verbose']>0 :
            print(("ccg_mobile_insitu.py version: " + str(self.version)))
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

        eventCols=self.eventCols
        dataCols=self.dataCols
        allCols=self.allCols

        hasDataCol=False #Track whether we need to add a distinct

        #Initialize and start the query builder
        db=self.db
        sql=db.sql
        sql.initQuery() #clear any previous queries.

        sql.table("ccgg.mobile_insitu_data_view v")#Always select from this.  Note this will exclude events that don't have any analysis measurements!
        sql.innerJoin("t_data t on v.data_num=t.data_num")#target ids
        sql.orderby("v.ev_datetime")
        sql.orderby("v.event_num")

        cols=[] #New list to hold all requested columns

        #Parse the requested col list, expanding any macro columns
        columns=self.args['columns']
        if(columns):
            a=columns.split(",")

            if self.args.get('merge'):
                #force column list when in merge mode.
                for t in eventCols : cols.append(t)

                #add some meta cols for below logic to process.
                if(self.args.get('merge')) : cols.append('mValues')

                #for t in mParamCols : cols.append(t)
                if not self.args.get('parameter_num') and not self.args.get("parameterprogram"):
                    print("Error, parameter(s) must be specified in merge mode and psuedo_pair_avg mode")
                    sys.exit()
            else:

                for col in a:
                    if(col=='eventCols'): cols.extend(eventCols)
                    elif(col=='dataCols'): cols.extend(dataCols)
                    else:
                        if (col in allCols) : cols.append(col)
                        else :
                            print(("Error: '%s' is not an available column (yet).  You can request that it be added." % (col,)))
                            sys.exit()

            #for each column, add to query with any needed joins.
            for col in cols:
                #track whether we need to add a distinct if event only data.  Note we'll just do it in all other cases, although some of the special ones may not need it.
                if(col in dataCols):hasDataCol=True

                #special cases.  Note, this is in a loop so cases may be called more than once.  Care should be taken to not do extra work.
                if(col=='mValues'):
                    parameters=self.args['parameter'].split(",")
                    flag='.%' if self.args.get('flag')==None else self.args.get('flag')
                    for p in parameters :
                        table="t_"+p
                        fl_tab="ccgg.mobile_insitu_data_view"

                        db.doquery("drop temporary table if exists "+table)
                        db.doquery("""create temporary table """+table+""" (index i (event_num)) as
                                   select d.event_num,avg(d.value) as value,max(d.flag) as flag, avg(d.unc) as unc, avg(d.stddev) as stddev, sum(d.n) as n,max(d.instrument) as inst
                                            from """+fl_tab+""" d, gmd.parameter p, t_data t
                                            where d.parameter_num=p.num and d.num=t.data_num
                                                and upper(p.formula)=upper('"""+p+"""')
                                                and flag like '"""+flag+"""'
                                                group by d.event_num""")
                        if(self.args.get('merge')==3 and self.args['parameter'].startswith(p)):#primary mode, require first parameter exists.
                            sql.innerJoin(table+" on v.event_num="+table+".event_num")
                        else :
                            sql.leftJoin(table+" on v.event_num="+table+".event_num")
                        sql.col("round(ifnull("+table+".value,-999.990),4) as '"+p+"'")
                        if(self.args.get('merge')>=2) :
                            if self.args['preliminary'] :
                                sql.col("concat(substring(ifnull("+table+".flag,'...'),1,2),'P') as "+p+"_flag")
                            else : sql.col("ifnull("+table+".flag,'...') as "+p+"_flag")
                            sql.col("round(ifnull("+table+".unc,-999.990),4) as "+p+"_unc")
                            sql.col("round(ifnull("+table+".stddev,-999.990),4) as "+p+"_stddev")
                            sql.col("round(ifnull("+table+".n,-999.990),4) as "+p+"_n")
                            sql.col("ifnull("+table+".inst,'') as "+p+"_inst")
                    sql.distinct()#Not sure if this is needed here, but was taking out for performance when not needed.. leaving here just in case

                #elif(col=='flag') :#If prelim was passed, sub in ..P as appropriate.
                #    if(self.args['preliminary']):
                #        sql.innerJoin("releaseable_flask_data_view rel on rel.data_num=v.data_num")
                #        sql.col("case when rel.prelim=1 then concat(substring(v.flag,1,2),'P') else v.flag end as flag")
                #    else : sql.col("v.flag")
                #####!!!!hard coding for now as we don't have a mechanism to record yet!!!
                elif(col=='flag' and self.args['preliminary']) :
                    sql.col("concat(substring(v.flag,1,2),'P') as flag")
                elif(col=='value') : sql.col("round(v.value,4) as value")
                elif(col=='campaign') : sql.col("v.campaign_abbr as 'campaign'")
                elif(col=='inst') : sql.col("instrument as inst")
                else:
                    sql.col("v."+col)

            if(not hasDataCol):sql.distinct() # This is needed if all columns are event cols as current logic does filtering by data_num.  Note this is depended on by some callers (to get list of included tags)
            #print(sql.cmd())

            return True

        else : return False


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
        if(args.get('inst')) : args['mobile_insitu_inst_num']=self.getNumList('num','abbr','ccgg.mobile_insitu_instruments',args['inst'])
        if(args.get('campaign')) : args['campaign_num']=self.getNumList('num','abbr','obspack.campaign',args['campaign'])

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

        #Init the query builder
        sql.initQuery()

        #We'll build a temp table of ids to use in final select.  Note, we always select data_num even if caller is just selecting
        #event data.  This was a judgement call that not many callers only get flask data so the performance hit of doing a distinct in
        #final select is worth not having to excessively complicate the join logic with 2 logic paths
        sql.createTempTable("t_data","i(data_num)")

        sql.col('d.num as data_num')
        sql.table("ccgg.mobile_insitu_data d")
        sql.innerJoin("mobile_insitu_event e on d.event_num=e.num")

        #if args['exclusion']: #Filter out excluded data
        #    sql.innerJoin("releaseable_flask_data_view rel on d.num=rel.data_num")
        #    sql.where("rel.excluded=0")

        #Add all the filters.  Note I sometimes use the setFilter (f) wrapper when convienent, but it's just for laziness.  It adds them in same way.

        #Event filters
        f('event_num',comparator="in", ta='e',altColName='num')

        #   date ranges
        if args.get('from_ev_date') : sql.where("date(e.datetime)>=%s",args['from_ev_date'])
        if args.get('from_ev_datetime') : sql.where("e.datetime>=%s",args['from_ev_datetime'])
        if args.get('from_ev_dd') : sql.where("f_dt2dec(e.datetime)>=%s",args['from_ev_dd'])
        if args.get('from_ev_time') : sql.where('time(e.datetime)>=%s',args['from_ev_time'])

        if args.get('to_ev_date') : sql.where("date(e.datetime)<%s",args['to_ev_date'])
        if args.get('to_ev_date_inclusive') : sql.where("date(e.datetime)<=%s",args['to_ev_date_inclusive'])
        if args.get('to_ev_datetime') : sql.where("e.datetime<%s",args['to_ev_datetime'])
        if args.get('to_ev_datetime_inclusive') : sql.where("e.datetime<=%s",args['to_ev_datetime_inclusive'])
        if args.get('to_ev_dd') : sql.where("f_dt2dec(e.datetime)<%s",args['to_ev_dd'])
        if args.get('to_ev_time') : sql.where('time(e.datetime)<%s',args['to_ev_time'])
        if args.get('to_ev_time_inclusive') :sql.where("time(e.datetime)<=%s",args['to_ev_time_inclusive'])


        #f('site',comparator="in")
        f('site_num',comparator='in', ta='e')

        f('project_num',comparator='in', ta='e')
        f('strategy_num',comparator="in", ta='e')
        #if args.get('ev_comment') : sql.where("e.comment like %s",args['ev_comment'])
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
        f('campaign_num',comparator="in",ta='e')
        #Data filters
        f('data_num',comparator="in",altColName='num')#convience wrapper for lazy programmer
        f('program_num',comparator='in')
        f('parameter_num',comparator="in")
        if parameterprogram_whr:sql.where(parameterprogram_whr)

        f('from_value',comparator=">=",altColName='value')
        f('to_value',comparator="<",altColName='value')
        f('from_unc',comparator=">=",altColName='unc')
        f('to_unc',comparator="<",altColName='unc')
        if(args.get('not_flag')):f('flag',comparator='not like')
        else:f('flag',comparator='like')

        f('mobile_insitu_inst_num',comparator="in",ta='d')

        #if args.get('a_comment') : sql.where("d.comment like %s",args['a_comment'])

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

    def parseArgs( self, kwargs ):
        #Common parsing logic for python code and command line callers.
        #This defines the allowed list of arguments.

        descText="ccg_mobile_insitu.py version: "+str(self.version)+"""
------------------

This program retrieves data from ccgg mobile insitu measurements

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

#This not needed if using ccgg conda environment
if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')

from ccg_mobile_insitu import ccg_mobile_insitu

#default output format is a list of row dictionaries.  Pass flag options as boolean True
args={'site':'car', 'from_ev_date':'2004-03-01', 'to_ev_date':'2004-04-01','g':'co2,ch4','preliminary':True}
a=ccg_mobile_insitu(args)
if a :
    for row in a:
        print ("num: %s datetime: %s parameter: %s value: %s" % (row['event_num'],row['ev_datetime'],row['parameter'],row['value']))


#If numpy is available, you can output directly to numpy arrays
args['output']='numpy'
a=ccg_mobile_insitu(args)
if a : #a is a dictionary of column arrays (colname:coldata)
    print(a)

#you can also output directly to file if needed:
args['output']='csv'
args['outfile']='out.dat'
a=ccg_mobile_insitu(args) #output written to out.dat in current working directory

#columns can be specified:
args['cols']='event_num,site,ev_datetime,parameter,value'
a=ccg_mobile_insitu(args)


###########
Command line Examples:
###########
/ccg/src/db/ccg_mobile_insitu.py --cols='eventCols' --site=UGD --from_ev_date=2004-01-01 --to_ev_date=2005-01-01
    ->event details for ugd, samples in 2004

/ccg/src/db/ccg_mobile_insitu.py --site=UGD,alt --from_ev_date=2004-02-02 -g=co2,ch4 --flag=..%
    -> UGD and alt, from date, 2 gases, non rejected, standard columns

/ccg/src/db/ccg_mobile_insitu.py --inst=pr1 --cols=event_num --from_a_date='2016-01-01'
    -> all event #'s with PR1 measurements since 2016

/ccg/src/db/ccg_mobile_insitu.py --site='UGD' -g=co2 --from_ev_dd=2004.0 --to_ev_dd=2004.6 --to_alt=6000 --outfile='/tmp/out.csv'
    -> UGD measurements from first half of 2004, under alt:6000, send to csv file

/ccg/src/db/ccg_mobile_insitu.py --site=UGD -g=co2,co2c14 --flag='.%%'
    -> UGD co2,co2c14 .

/ccg/src/db/ccg_mobile_insitu.py --site=UGD --program=hats --from_ev_date='2015-01-01' --cols='eventCols,dataCols' --flag='.%' --not_flag
    ->reject data from 2015 forward for hats UGD data.

/ccg/src/db/ccg_mobile_insitu.py --site=UGD --to_ev_date=2022-01-01 --output=map -g=co2
    ->show UGD samples thru 2022 on a map


        """
        #Set up the parser rules
        parser=argparse.ArgumentParser(description=descText,epilog=epilogText,formatter_class=argparse.RawTextHelpFormatter)
        eventCols=', '.join(map(str,self.eventCols))
        dataCols=', '.join(map(str,self.dataCols))
        allCols=', '.join(map(str,self.allCols))
        parser.add_argument('-c','--columns', '--cols',default='eventCols,dataCols',help="""A list of columns to output (comma separated)
The default if not specified is the commom columns from sample and measurements
~Can use macros:
    eventCols="""+eventCols+"""
    dataCols="""+dataCols+"""

~Default is 'eventCols,dataCols'
~You can also mix with individual columns, master list of available columns is:
    """+allCols+"""
ex: 'eventCols, parameter, value'
    or: 'site,ev_datetime,parameter,value'
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
        parser.add_argument('-m','--merge','--m',default=0,choices=(0,1,2,3), type=int,help="Merge multiple parameters onto 1 line.  0-> no merge (default), 1-> merge multiple parameters onto 1 line, 2-> same, but with flag, unc,inst, stddev & n., 3-> same but only return rows when first param exists (primary).  useful when retrieving a gas like co2 + rh,press, temp...")
        parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')
        #parser.add_argument("--exclusion",action='store_true',help="If passed, excluded data is removed from output")
        parser.add_argument("--preliminary",action='store_true',help="If passed, all returned data is marked with a ..P preliminary flag.")

        parser.add_argument('--mapZoom', default=0,choices=(0,1,2,3),type=int, help='When output=map, mapZoom can be used to zoom in the map from 0 (none) to 3(most)')
        #Sample filters
        evgrp=parser.add_argument_group("Sample Event Filters")
        evgrp.add_argument("-e",'--event_num',help="One or more (comma separated) event numbers");
        evgrp.add_argument('-s','--site','--s',help='One or more (comma separated) site codes. Prefix with a - to exclude list.')
        evgrp.add_argument("--strategy","--st",help="""One or more (comma separated) strategies (flask,pfp,insitu)
(insitu not programmed yet)""")
        evgrp.add_argument('--project',help='One or more (comma separated) projects (ccg_surface,ccg_aircraft)')
        evgrp.add_argument("--campaign',help='One or more (comma separated) campaigns (ie above)'")
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
        #evgrp.add_argument('--ev_comment',help="Events with comment equal to string ev_comment.  Use %% for wildcards")
        #Measurement filters
        dgrp=parser.add_argument_group("Data (measurement) Filters")
        dgrp.add_argument('--data_num','--data_nums',help="One or more (comma separated) data numbers")
        dgrp.add_argument('--program',help="One or more programs (ccgg,sil,arl,curl,hats)")
        dgrp.add_argument('-g','--parameter','--parameters','--g',help='One or more parameters (comma separated).  Prefix with a - to exclude list.')#--g is for backwards compat with python callers (so 'g':'co' is accepted)
        dgrp.add_argument("--parameterprogram",help='Pass this to specifiy the program for parameter (for gases like sf6 that are measured by hats and ccgg).  Pairs have a tilde join, multiple are separated by comma like; sf6~hats,co~ccgg')

        #val/unc
        dgrp.add_argument('--from_value',help="Values >= from_value")
        dgrp.add_argument('--to_value',help="Values < to_value")
        dgrp.add_argument('--from_unc',help="Uncertainty >= from_unc")
        dgrp.add_argument('--to_unc',help="Uncertainty < to_unc")

        #flag/inst/comment
        dgrp.add_argument('-f','--flag',help="3 letter traditional external flag is like [flag]. Uses %% for wild card ex; pass '..%%' to get all non-rejected, non-selection issue measurements. Default is '' which returns all data.  Note when in merge mode (multiple parameters), rejected parameters will have -999.99 for a value")
        dgrp.add_argument("--not_flag",action='store_true',help="Pass --not_flag to negate --flag option.  For example --flag='.%%' returns all non-rejected data.  If --not_flag is added, then only rejected data is returned.")
        dgrp.add_argument('--inst',help='Measurement instrument')
        #dgrp.add_argument('--a_comment',help='Analysis rows with comment equal to string a_comment.  Use %% for wildcards')

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

    r = ccg_mobile_insitu(t)#call the wrapper function

    sys.exit( 0 )
