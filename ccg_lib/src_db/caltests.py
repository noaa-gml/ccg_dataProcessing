#!/usr/bin/env python

#Create and query calibration scale testing tables
#call -h to see help.

import os
import sys
import getopt
import argparse

#Load db lib
if('/ccg/src/db/db_utils' not in sys.path) : sys.path.append('/ccg/src/db/db_utils')
import db_conn

class Caltests(object) :
    def __init__(self, kwargs):
        super(Caltests, self).__init__()

        #Parse the arguements
        args=self.parseArgs(kwargs)

        if args['verbose']>1 :
            print("Arguments:")
            print(args)

        #Explicit on which db we are working on
        self.tdb="cal_scale_tests"
        if args['cal_scale_tests2'] :self.tdb="cal_scale_tests2"
        print("Using db:",self.tdb)

        #Called at beginning of testing round.  Wipes all previous data.
        if args['inittables']:
            #Make a rw connection to the db and call sp to init tables.
            db=db_conn.ProdDB()
            db.doquery("use "+self.tdb);
            procName="cal_initTest"
            if self.tdb=='cal_scale_tests2' :procName='cal_initTest2'

            a=db.doquery("call "+procName+"(%s)",(args['set_default_val'],),numRows=0);
            if a :
                print("--")
                print("--")
                print(str(a))
            else :
                print ("--")
                print ("--")
                print (" reftank.calibrations and ccgg.flask_data have been cloned into the "+self.tdb+" db.")
                #fetch last date of each new table clone
                date=db.doquery("select max(date) from "+self.tdb+".calibrations", numRows=0)
                print ("--")
                print ("Last calibration date: "+str(date))
                date=db.doquery("select max(date) from "+self.tdb+".flask_data",numRows=0)
                print ("--")
                print ("Last flask anal date: "+str(date))
                print ("--")
                if args['set_default_val'] :
                    print ("Mixratio, flask_data and a few other values have been set to -888.88 so that reprocessing can be verified")
                    print ("--")
                #print ("""You can select from fill_avgs_view, tanks_view or flask_view in the """+self.tdb+""" db for results (or call this script with appropriate flags).  Note; no results are returned from fill_avgs_view  until tanks are reprocessed.""")
                print("--")

        else:#NOT used anymore
            #Interactive queries after scale changes have been processed into the test tables using calpro or flpro
            #Make ro connection to db with local handle
            db=db_conn.RO()
            db.doquery("use "+self.tdb)
            form= 'txt' if args['outfile'] else 'scr' #formatted text output by request (not csv).  Can always add a csv option if desired.
            table=''
            if(args['avgs_view']):
                table='fill_avgs_view'
                col='avg_mixratio'
            if(args['tanks_view']):
                table='tanks_view'
                col='mixratio'
            if(args['flask_view']):
                table='flask_view'
                col='value'
            if(table):
                sql=db.sql #handle for the query builder. See /ccg/src/db/db_utils/bldsql.py for documentation.
                sql.initQuery() #Resets/initializes
                sql.table(table+" v") #Set tables and columns separately
                sql.col("v.*") #Select all cols
                #Filter if any passed.
                if(args['tanks_view'] or args['flask_view']):
                    if(args['min_date']):sql.where("v.date>=%s",(args['min_date']))
                    if(args['max_date']):sql.where("v.date<=%s",(args['max_date']))
                    if(args['tanks_view'] and args['retained']): sql.where("flag='.'")
                    if(args['flask_view'] and args['retained']): sql.where("flag like '.%%'")
                    if(args['parameter']) : sql.where("v.species=%s",(args['parameter']))
                if(args['flask_view'] and args['site']):
                    #sql.where("v.site in(%s)",(args['site']))
                    sql.wherein("v.site in ",args['site'].split(","))
                if(args['tanks_view'] and args['site']):
                    sql.wherein("v.location in ",args['site'].split(","))
                if(args['min_mr']):sql.where(col+"_old>=%s",(args['min_mr']))
                if(args['max_mr']):sql.where(col+"_old<=%s",(args['max_mr']))
                if(args['min_diff']):sql.where("abs(v.diff)>=%s",(args['min_diff']))

                db.doquery(outfile=args['outfile'],form=form)
            if(args['pc1l9']):
                print( "Collecting PC1 L9 comparison info")
                #Special comparison mode
                q="""   select p.serial_number, p.fill_code,
                        l.avg_mixratio_new as 'L9_avg_mr_new',l.avg_mixratio_old as 'L9_avg_mr_old',l.avg_mixratio_new-l.avg_mixratio_old as 'L9_diff',
                        p.avg_mixratio_new as 'PC1_avg_mr_new',p.avg_mixratio_old as 'PC1_avg_mr_old',p.avg_mixratio_new-p.avg_mixratio_old as 'PC1_diff',
                        l.avg_mixratio_new-p.avg_mixratio_new as 'L9_new-PC1_new',l.avg_mixratio_old-p.avg_mixratio_old as 'L9_old-PC1_old',
                        p.avg_co2c13_mr,p.avg_co2o18_mr
                    from fill_avgs_view p join fill_avgs_view l on p.serial_number=l.serial_number and p.fill_code=l.fill_code and p.species=l.species
                    where p.inst='PC1' and l.inst='L9' """
                if(args['min_mr']):q=q+" and p.avg_mixratio_old >= "+str(args['min_mr'])
                if(args['max_mr']):q=q+" and p.avg_mixratio_old <= "+str(args['max_mr'])

                db.doquery(q,outfile=args['outfile'],form=form)

    def parseArgs( self, kwargs ):
        #This defines the allowed list of arguments.

        descText="""
------------------
This script is used to initialize calibration scale testing tables in the cal_scale_tests[2] db and perform basic queries.
How to use:
-Call with -i or --inittables to create clones of calibration and flask_data tables in the cal_scale_test db
-Then reprocess data using new scale information passing 'cal_scale_tests[2]' as the database in calpro.py and flpro.py python scripts.
-Then can call this again with -a (fill_avgs_view), -t(tanks_view) or -f(flask_view) to retrieve comparison results.
call with a -h to see other filter options.


From command line, pass each arguement as --kword=value ...
See examples below.

        """
        epilogText="""
------------------
Examples:

###########
Command line Examples:
###########
#Init tables#
/ccg/src/db/caltests.py --inittables

#Init into 2nd test db and set values to -888.88
/ccg/src/db/caltests.py --inittables --cal_scale_tests2 -x

        """

    #Set up the parser rules
        parser=argparse.ArgumentParser(description=descText,epilog=epilogText,formatter_class=argparse.RawTextHelpFormatter)
        #parser.add_argument('-o',"--outfile",'--o',help="""Name of output file if calling queries""")
        parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')
        parser.add_argument("-i","--inittables",action="store_true",help="""Clears and makes copies of the reftank.calibrations table and ccgg.flask_data table in the cal_scale_tests[2] db.  Also creates 3 views; fill_avgs_view, tanks_view and flask_view to compare results.  Note; if this is called, the only other argument that is considered is -g --parameter.""")
        parser.add_argument("--cal_scale_tests2",action="store_true",help="""Use the 2nd dev database, cal_scale_tests2""")
        parser.add_argument("-x","--set_default_val",action="store_true",help="If passed then certain columns (ie flask_data.value, calibrations.mixration...) are set to -888.88")
        #parser.add_argument('-a','--avgs_view','--a',action="store_true",help="""select results from the fill_avgs_view. This shows avg values of new and old scale values for each serial_number,inst,species and fill_code.  Note; no results are returned from this option until tanks are reprocessed. """)
        #parser.add_argument('-p','--pc1l9',action='store_true', help='Retrieve averages for pc1 L9 comparison.  Note; no results are returned from this option until tanks are reprocessed.')
        #parser.add_argument('-t','--tanks_view','--t',action="store_true",help="select results from the tanks_view.  This shows new and old mr values for each calibration result.  Note; results are limited to the last 2 years of data to filter out long term drifting tanks.")
        #parser.add_argument('-f','--flask_view','--f',action="store_true",help="select results from the flask_view.  This shows new and old values for each flask_data value.")
        #parser.add_argument('--min_date',help='min date (flask_view or tanks_view only)')
        #parser.add_argument('--max_date',help='max date (inclusive) (flask_view or tanks_view only)')
        #parser.add_argument('--min_mr',help='min mixratio value (existing scale value)')
        #parser.add_argument('--max_mr',help='max mixratio value (inclusive) (existing scale value)')
        #parser.add_argument('-s','--site',help='limit to sample site (3 letter code)(flask_view or tanks_view onl)')
        #parser.add_argument('-d','--min_diff',help='only show results with an absolute difference greater or equal to this value')
        #parser.add_argument('-r','--retained',action='store_true',help='DISABLED-only retained data is returned')
        t=kwargs

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

    r = Caltests(t)#Create instance and init


    sys.exit( 0 )





