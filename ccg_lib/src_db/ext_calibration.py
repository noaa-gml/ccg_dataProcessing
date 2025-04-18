#!/usr/bin/env python

#call -h to see help.
#for use to wipe reftank.external_calibrations table during Andy's code testing.  This should be temporary.

import os
import sys
import getopt
import argparse

#Load db lib
if('/ccg/src/db/db_utils' not in sys.path) : sys.path.append('/ccg/src/db/db_utils')
import db_conn

class ExternalCalibrations(object) :
    def __init__(self, kwargs):
        super(ExternalCalibrations, self).__init__()
        
        #Parse the arguements
        args=self.parseArgs(kwargs)
        
        if args['verbose']>1 :
            print("Arguments:")
            print(args)

        #Called at beginning of testing round.  Wipes all previous data.
        if args['inittables']:
            #Make a rw connection to the db and call sp to init tables.
            db=db_conn.ProdDB()
            db.doquery("use reftank");
            a=db.doquery("delete from reftank.external_calibrations");
            if a : 
                print("--")
                print("--")
                print("Rows deleted: ",str(a))

    def parseArgs( self, kwargs ):
        #This defines the allowed list of arguments.

        descText="""
------------------
This script is used to initialize ExternalCalibrations table (for now).  Maybe other stuff later.

-Call with --inittable to wipe the reftank.external_calibrations table

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
/ccg/src/db/ext_calibration.py --inittables

        """
        
    #Set up the parser rules
        parser=argparse.ArgumentParser(description=descText,epilog=epilogText,formatter_class=argparse.RawTextHelpFormatter)
        parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')
        parser.add_argument("--inittables",action="store_true",help="""Clears the reftank.external_calibrations table.""")
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
        
    r = ExternalCalibrations(t)#Create instance and init 


    sys.exit( 0 )
    
    
    
    
    
