#!/usr/bin/env python
"""Template for python scripts
"""

import os
import sys
import datetime
import argparse

if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
#if('/home/ccg/mund/dev/ccgdblib' not in sys.path) : sys.path.append('/home/ccg/mund/dev/ccgdblib')
import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
import py_utils.pyu_file_ops as pyu_file
import py_utils.pyu_util_functions as uf


#Function that can be called from main/call class obj
def [func_name] (kwargs): #Change Name here and main call at bottom
    print "asdf"
    #Create obj that will do work
    #f=[ClassName](kwargs)
    #Return the results
    #return f.[doWork]()

class [ClassName](uf.PYUUtilFunctions) :#Change ClassName
    def __init__(self, kwargs):
        super([ClassName], self).__init__()#Change ClassName to match above

        #Make ro connection to db with local handle, readonly except for tmp db
        #Can also do ICPDB and ProdDB and DevDB (mund_dev)
        self.db=db_conn.RO()

        #Parse any arguements
        self.args=self.parseArgs(kwargs)
        self.update=self.args['update']#pull these out for quick reference.  If no update option, this needs to be removed.
        self.verbose=self.args['verbose']

        self.logFileName="/tmp/logfile.txt"


        #Functions in pyu_util_functions can be called by self.[func]

        #create file handler
        #create file handler
        #fh=pyu_file.PYUFile(self.filename)
        #if fh.isfile():
        #    for row in fh.readf(delim=','):
        #        dt=row[2]+'-'+row[3]+'-'+row[4]+' '+row[5]+":"+row[6]+":"+row[7]
        #   ...

    def logit(self,txt):
        logfile=pyu_file.PYUFile(self.logFileName)
        logfile.log(txt,self.verbose) #Log to file and output to screen if verbose.

    def parseArgs(self,kwargs):
        #Provide help menu and Parse any command line arg
        p=pyu_parser.PYUParser("[Description]","[Epilog]")
        parser=p.parser

        #required arg
        parser.add_argument('requiredOption')

        #optional arg
        parser.add_argument('-o','--optionalArg',default='asdf', help="help text")

        #choices
        parser.add_argument('-m','--merge','--m',default=0,choices=(0,1,2), type=int,help="Merge multiple parameters onto 1 line and average mulitple aliquots of same parameter for a sample.  0-> no merge (default), 1-> merge multiple parameters onto 1 line and average multiple aliquots, 2-> same, but with flag and expanded date cols.")

        #levels of verbosity (this one is actually included by default below, but the count construct is a useful example)
        #parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')

        #true false (default false)
        parser.add_argument("-u","--update",action='store_true',help="If passed, update")
        #add group
        evgrp=parser.add_argument_group("Sample Event Filters")
        evgrp.add_argument("-e",'--event_num',help="One or more (comma separated) event numbers");

        #Parse into kw dict
        #kwargs can either be a dictionary (when called from code) or a list (sys.argv from command line callers)
        kw=p.parse_args(kwargs)

        return kw

# main body if called as script

if __name__ == "__main__":

    t=list(sys.argv[1:])#Make a copy of the command line arguments so we can append a little meta info to it

    #add help if no arguments were passed.
    if(len(t)==0):t.append("--help");

    #t.append("--callsrc=cmdline")#If needed

    r = [func_name](t)#call the wrapper function

    sys.exit( 0 )
