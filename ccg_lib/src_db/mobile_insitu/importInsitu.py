#!/usr/bin/env python
"""import insitu merge files
"""

import os
import sys
import datetime
import argparse
import hashlib
#if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
#if('/home/ccg/mund/dev/ccgdblib' not in sys.path) : sys.path.append('/home/ccg/mund/dev/ccgdblib')

import db_utils.db_conn as db_conn
import py_utils.pyu_parser as pyu_parser
import py_utils.pyu_file_ops as pyu_file
import py_utils.pyu_util_functions as uf

from insitu_data_reader_aircraft import InsituDataReader_Air

import pandas as pd

#Function that can be called from main/call class obj
def importInsitu (kwargs): #Change Name here and main call at bottom
    
    #Create obj that will do work
    f=ImportInsitu(kwargs)
    #Return the results
    return f.main()

class ImportInsitu(uf.PYUUtilFunctions) :
    def __init__(self, kwargs):
        super().__init__()

        #Make rw connection to db with local handle
        self.db=db_conn.ProdDB()

        #Parse any arguements
        args=self.parse_args(kwargs)
        self.update=args['update']
        self.verbose=args['verbose']
        self.srcDir=args['srdDir']
        if not self.srcDir.endswith("/") : self.srcDir+="/"
        self.delete=args['delete']
        self.all=(args['all'] or self.delete)
        
        self.site_num=0;self.file_prefix='';
        self.file_suffix=args['suffix'];
        #create dir handler
        self.dh=uf.PYUUtilFunctions()
        self.set_options()
        
        #fh=pyu_file.PYUFile(filename)
        #if fh.isfile():
        #    for row in fh.readf():
        #        dt=row[2]+'-'+row[3]+'-'+row[4]+' '+row[5]+":"+row[6]+":"+row[7]
        #   ...
    def main(self):
        """Import files from srcdir"""
        n=0
        n=self.import_data()
        self.logit("Processed "+str(n)+" row(s)")
        
    def set_options(self):
        """Sets options based on src directory"""
        #We'll see if this is flexible enough.  May need to add support for multiple file types or other options by 
        #passing an optional reader profile or similar.
        if self.file_suffix=='' : self.file_suffix='txt';#default to txt if not passed in
        self.reader_ver=0;#default is current
        self.campaign_num=None;
        self.file_reader=InsituDataReader_Air #Kathryn's 10 second merge files for aircraft insitu as default
        self.interval_sec=10;#Default to 10 seconds.
        if self.srcDir=='/home/ccg/aircraft/Campaigns/Priority1/Uganda/Data/merge_10sec/':
            self.site_num=996 #ugd
            self.prefix='Uganda_aircraft_merge_10sec_'
            #self.reader_ver=1        # (first iteration)
        if self.srcDir=='/home/ccg/aircraft/Campaigns/ABoVE/Data/merge_10sec_db/':
            self.campaign_num=29 #above
            self.site_num=522 #crv
            self.file_prefix="ABoVE_merge_10sec_"
        if self.srcDir=='/home/ccg/aircraft/Campaigns/Africa/Woolpert/Data/merge_10sec/' :
            self.site_num=1077
            self.prefix='AFO_merge_10sec_2023'#filtered to these for now.  New files not qc'd. also used a suffix of _v20240910.txt and _v20240911.txt            
        
        #Set vars needed in reader into a dict to pass to reader
        self.options={
            'site_num':self.site_num, 
            'db_conn':self.db, 
            'update':self.update,
            'campaign_id':self.campaign_num,
            'reader_ver':self.reader_ver,
            'interval_sec':self.interval_sec,
            }
        
    def import_data(self):
        """"""
        dirhash=self.dh.getHash(self.srcDir)
        
        
        ######Not sure on this logic...
        if self.delete and self.update : 
            if self.site_num:
                self.logit("Deleting all data for site_num "+str(self.site_num))
                self.db.doquery("delete from ccgg.mobile_insitu_event where site_num=%s",[self.site_num,])
            else:
                print("Error, delete passed but no site_num defined")
        
        self.logit("Finding files to process:")
        files=self.dh.processDirFiles(self.srcDir,(not self.all),dirhash,prefix=self.file_prefix,suffix=self.file_suffix,update=self.update)
        n=0
        
        if files : 
            r=self.file_reader(self.options)
            self.logit("Processing files.")
            for fn in files:
                #print("Processing ", fn)
                t=r.processFile(fn)
                if t==0 : 
                    print("0 rows processed in file",fn)
                    sys.exit()
                n+=t
        
        else : self.logit("No files to process.")
        
        return n
    
        
    def logit(self,txt,verbose=False):
        logfile=pyu_file.PYUFile('log.txt')
        logfile.log(txt,(self.verbose or verbose)) #Log to file and output to screen if verbose.

    def parse_args(self,kwargs):
        #Provide help menu and Parse any command line arg
        p=pyu_parser.PYUParser("[Description]","[Epilog]")
        parser=p.parser

        #required arg
        parser.add_argument('srdDir',help='source directory of target files')
        #parser.add_argument("fileType",help="type of source file.  Currently supported '10secmergeAir'")
        #optional arg
        parser.add_argument('-a','--all',action='store_true', help="""Process all files in dir.  Default is only files modified since last processing. """)
        parser.add_argument('-s','--suffix',default='',help="""End of file to match against when searching directory""")
        #choices
        #parser.add_argument('-m','--merge','--m',default=0,choices=(0,1,2), type=int,help="Merge multiple parameters onto 1 line and average mulitple aliquots of same parameter for a sample.  0-> no merge (default), 1-> merge multiple parameters onto 1 line and average multiple aliquots, 2-> same, but with flag and expanded date cols.")

        #levels of verbosity (this one is actually included by default below, but the count construct is a useful example)
        #parser.add_argument("-v","--verbose",action='count',default=0,help='debugging output')

        #true false (default false)
        parser.add_argument("-u","--update",action='store_true',help="If passed, update")
        parser.add_argument('--delete',action='store_true',help="""Pass -d to delete all data for site and reprocess all files.  Implies -a""")

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

    r = importInsitu(t)#call the wrapper function

    sys.exit( 0 )
