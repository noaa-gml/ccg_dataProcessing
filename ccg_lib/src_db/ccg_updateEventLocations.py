#!/usr/bin/env python
"""Update event time/locations for multiple events.

"""

import os
import sys
import datetime
import argparse
import subprocess

if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
#if('/home/ccg/mund/dev/ccgdblib' not in sys.path) : sys.path.append('/home/ccg/mund/dev/ccgdblib')
import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
import py_utils.pyu_file_ops as pyu_file
import py_utils.pyu_util_functions as uf

#Function that can be called from main/call class obj
def update_event_locations (kwargs):

    #Create obj that will do work
    f=UpdateEventLocations(kwargs)
    #Return the results
    return f.update_events_from_file()

class UpdateEventLocations(uf.PYUUtilFunctions) :
    def __init__(self, kwargs):
        super(UpdateEventLocations, self).__init__()

        #Make connection handle to db
        #NOTE; dev: remember to reset permissions after deploying to prod:
        #chmod 700 ccg_updateEventLocations.py
        ###################
        self.db=db_conn.ProdDB()#ProdDB DevDB
        ###################

        #Parse any arguments
        self.args=self.parseArgs(kwargs)
        self.update=self.args['update']#pull these out for quick reference.  If no update option, this needs to be removed.
        self.verbose=self.args['verbose']
        self.filename=self.args['filename']
        self.updateElev=self.args['forceUpdateElev']

        self.logFileName="ccg_updateEventLocations.log"
        self.undoRows=[]
        self.updateSQL=[]
        self.updateParameters=[]

    def update_events_from_file(self):
        #create file handler
        fh=pyu_file.PYUFile(self.filename)
        if fh.isfile():
            i=0
            for row in fh.readf(delim=','):
                i+=1
                #Do basic sanity checks.  These will quit the program on fail.
                if i==1 :
                    self.validate_header(row)
                    continue
                else : self.validate_data_row(row)

                #build update statement
                self.bld_update_statement(row)

            #Write to log file/print then do update if needed.
            for i,sql in enumerate(self.updateSQL):
                #print/log sql & params
                t="Prev Values:"+self.listToStr(self.undoRows[i])+" | "+sql+" | "+self.listToStr(self.updateParameters[i])
                if self.update :
                    self.logit(t)
                    self.db.doquery(sql,self.updateParameters[i])
                else : print(t)
        else : self.error("Can't open file:"+self.filename)

    def bld_update_statement(self,row):
        #builds an update (and undo) statement for passed row and stores in the obj lists
        event_num,date,time,lat,lon,alt=row
        elev, comment='',''
        #See if this is appropriate ev type to update elev
        isAircraftPFP=False
        #if self.db.doquery("select count(*) from flask_event where num=%s and project_num=2 and strategy_num=2",(event_num,),numRows=0) == 1 :
        #loosened restriction to allow updates to aircraft flasks too.
        if self.db.doquery("select count(*) from flask_event where num=%s and project_num=2",(event_num,),numRows=0) == 1 :
            isAircraftPFP=True

        oldrow=self.db.doquery("select num as event_num,date_format(date,'%%Y-%%m-%%d') as day,time_format(time,'%%H:%%i:%%s')as time,lat,lon,alt,elev,comment from flask_event where num=%s",(event_num,),form='list')
        if(oldrow):
            oevent_num,odate,otime,olat,olon,oalt,oelev,ocomment=list(map(str,oldrow[0]))#convert all to strings.  Note a "0" string equivs to true (for below tests to see if a value was passed.)

            #Default elev and comment to their current values
            elev=oelev
            comment=ocomment

            #Build the update statement
            sql=''
            params=[]
            updateDD=False #Track if date updated so we can also update dd
            updateElev=False #Track if lat/lon updated so we can also update elev
            if date and date!=odate :
                sql=self.appendToList(sql,"date=%s")
                params.append(date)
                updateDD=True
            if time and time != otime:
                sql=self.appendToList(sql,"time=%s")
                params.append(time)
                updateDD=True
            if lat and float(lat)!=float(olat):
                sql=self.appendToList(sql,"lat=%s")
                params.append(lat)
                updateElev=True
            if lon and float(lon)!=float(olon):
                sql=self.appendToList(sql,"lon=%s")
                params.append(lon)
                updateElev=True
            if alt and float(alt)!=float(oalt) :
                sql=self.appendToList(sql,"alt=%s")
                params.append(alt)
            if updateDD : #date or time was changed
                newDate=date if date and date!=odate else odate
                newTime=time if time and time!=otime else otime
                sql=self.appendToList(sql,"dd=ccgg.f_date2dec(%s,%s)")
                params.append(newDate)
                params.append(newTime)

            if (updateElev or self.updateElev) : #Fetch new elevation/comment if updating lat lon or told to
                #This one is different than above datetime because we specifically want to allow updating elevations without
                #necessarily changing lat/lon (like if we start using a better dem)
                if isAircraftPFP :
                    newLat=lat if lat and lat!=olat else olat
                    newLon=lon if lon and lon!=olon else olon
                    elev,comment=self.getElev(newLat,newLon,ocomment,row)#Row is passed for logging.
                    sql=self.appendToList(sql,"elev=%s")
                    params.append(str(elev))
                    sql=self.appendToList(sql,"comment=%s")
                    params.append(str(comment))#Not sure from where, but this is returning a byte string unless converted to str
                else : self.error("You passed force update for elev (or updates that require elev update), but this is not an aircraft pfp",row)

            if sql :
                self.updateSQL.append("update flask_event set "+sql+" where num=%s")
                params.append(event_num)
                self.updateParameters.append(params)
                
                #Save off the old values for undo information
                self.undoRows.append([oevent_num,odate,otime,olat,olon,oalt,oelev,ocomment])
        else:
            self.error("couldn't find row for event_num:"+str(event_num),row)

    def getElev(self,lat,lon,comment,row):
        #Looks up elevation for passed lat lon and returns a tuple with elev and new comment (specifying the db used)
        #Note this logic must be synced with omi:/var/www/html/om/pfp/pfp_eventedit.php->DB_UpdateEventNum()
        #lat and lon are new values (or same if forceupdating).  Comment is old comment. Row is just used for logging.

        # Extract out the elevation source from the comment
        # because we need it to determine where we query
        # for the elevation. Also, so that we can replace
        # the old model (if any) with the correct model used.
        acomments=comment.split("~+~")
        newComment,elevSrc='',''
        for i,part in enumerate(acomments) :#loop through comment parts/sections
            tmp=part.split(":")
            if tmp[0] == 'elev' and len(tmp)==2:
                if tmp[1]=='DB' and self.updateElev==0 : self.error("Sanity check.. you passed an event to update elev but elev type was previous set with DB.  See John for how to handle.",row)
                acomments.pop(i)#Remove element and exit loop.
                break;
        #Either no previous elev src was set or it was one of the dems.  We'll replace it either way.
        #switched to py3 syscall. 1.31.22
        #res=self.sysCallWithOutput('/ccg/DEM/ccg_elevation.pl',['-lat='+str(lat),'-lon='+str(lon)])
        res=self.run_shell_cmd('/ccg/DEM/ccg_elevation.pl -lat='+str(lat)+' -lon='+str(lon))
        res=res.rstrip()
        #res is in the form elev|src
        if res : #It should always return something (maybe defaults)
            elev,elevSrc=res.split("|")
            acomments.append("elev:"+elevSrc)
            newComment="~+~".join(acomments)
            return (str(elev),str(newComment))
        else : self.error("Unexpected result from ccg_elevation.pl",row)

    def validate_data_row(self,row):
        #Does some basic sanity checks on the data values
        if not self.validate_int(row[0],1) : self.error("invalid event_num",row)
        if row[1]!='' :
            try: datetime.datetime.strptime(row[1],'%Y-%m-%d')
            except ValueError:
                self.error("Incorrect date format. Should be YYYY-MM-DD",row)
        if row[2]!='' :
            try: datetime.datetime.strptime(row[2],"%H:%M:%S")
            except ValueError : self.error("Incorrect time format. Should be HH:MM:SS 24hr (gmt)",row)
        if row[3]!='':
            if not self.validate_float(row[3],-90,90) : self.error("invalid lat",row)
        if row[4]!='':
            if not self.validate_float(row[4],-180,180) : self.error("invalid lon",row)
        if row[5]!='':
            if not self.validate_float(row[5],0) : self.error("invalid alt",row)

    def validate_float(self,i,min=None,max=None):
        try:
            v=float(i)
            if min != None:
                if v<min : return False
            if max != None :
                if v>max : return False
            return True
        except ValueError : return False

    def validate_int(self,i,min=None,max=None):
        try:
            v=int(i)
            if min != None :
                if v<min : return False
            if max != None :
                if v>max : return False
            return True
        except ValueError : return False

    def validate_header(self,headerRow):
        print(headerRow)
        #Does a simple check to make sure required cols are present.  This is mostly to make sure the user was atleast paying attention
        #to requirements and hopefully put the columns in the right order.
        if len(headerRow)< 6 : self.error("header row incorrect length",headerRow)#Changed to allow extra cols at end
        if headerRow[0]!='event_num' or headerRow[1] !='date' or headerRow[2]!= 'time' or headerRow[3]!= 'lat' or headerRow[4]!= 'lon' or headerRow[5]!= 'alt' :
            self.error("Incorrect header column names",headerRow)
            
    def error(self,txt,row=[]):
        #log error and exit.
        t=txt+": "+" | ".join(map(str,row))
        if self.update : self.logit(t)
        else : print(t)
        sys.exit();

    def logit(self,txt):
        logfile=pyu_file.PYUFile(self.logFileName)
        logfile.log(txt,self.verbose) #Log to file and output to screen if verbose.

    def parseArgs(self,kwargs):
        #Provide help menu and Parse any command line arg
        helpText="""This script will update multiple event locations (date,time,lat,lon,alt) from passed file.
        It will also update elevation and any other location based triggers (ie-met data).

        Updating elevations (and comnment) is currently limited to ccg_aircraft pfps.

        Full path to csv file (comma separated values) is passed in filename arg.
        File is required to have following columns in order:
        event_num, date, time, lat, lon, alt
        columns can be empty or same as existing value, both of which means they won't get updated.
        First row is header with column names (no comments)
        Date is in YYYY-MM-DD format, time is in 24hr HH:MM:SS format.  Both GMT
        ex:
            event_num,date,time,lat,lon,alt
            180316,2019-01-27,21:34:37,48.22,-98.11,10275
            180317,,21:40:03,48.42,-98.18,9570
            ....

        This script logs all updates.
        """
        examples="""./ccg_updateEventLocations.py -f=/home/ccg/mund/tmp/event_edits_for_kathryn.csv -v"""
        p=pyu_parser.PYUParser(helpText,examples)
        parser=p.parser

        #required arg
        parser.add_argument('-f','--filename',help='Path to csv file')

        #true false (default false)
        parser.add_argument("-u","--update",action='store_true',help="If passed, update.  Otherwise, print statements.")

        #elev from dem
        parser.add_argument("--forceUpdateElev", action='store_true',help='If passed, update elevation by looking up lat lon in elev regardless if lat, lon changed (aircraft pfps only).  Also forces update if previously set from db')

        #Parse into kw dict
        #kwargs can either be a dictionary (when called from code) or a list (sys.argv from command line callers)
        kw=p.parse_args(kwargs)

        return kw

# main body if called as script

if __name__ == "__main__":

    t=list(sys.argv[1:])#Make a copy of the command line arguments so we can append a little meta info to it

    #add help if no arguments were passed.
    if(len(t)==0):t.append("--help");

    r = update_event_locations(t)#call the wrapper function

    sys.exit( 0 )
