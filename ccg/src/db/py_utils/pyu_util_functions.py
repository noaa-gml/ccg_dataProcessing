#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Python Utility Class to do common utility functions
Note; This should be python2/3 compatible.
See template for how to include.
"""

import os
import sys

import datetime
import time
import csv
import logging
import subprocess
from os import access, R_OK
import hashlib
from pathlib import Path

class PYUUtilFunctions(object):
    """Python Utilities wrapper for common utility functions

    """
    def __init__(self):
        super(PYUUtilFunctions, self).__init__()
        self.timestampsDir="/ccg/src/db/py_utils/.processedTimesamps/"

    def appendToList(self,a,b,delim=','):
        #Inspite of confusing name in python, (dev is used to this name :) list is not a python list, but a string of delimited values.
        #This is just a convient way to build up a list of delim'd strings without having to worry if its the first one.
        #if a and b, returns a,b
        #if a and !b, returns a
        #if !a and b, returns b
        if(a and b) : return "%s%s%s" % (a,delim,b)
        if(a) : return a
        else : return b

    #Directory processing
    #Example use for processing recent files and having caller say when successfully processed:
    #import pyu_util_functions as pu
    #import time
    #
    #u=pu()
    #startTime=time.time()#Track start of processing
    #sdir="/ccg/co2c13/"
    #dataset=u.getHash(sdir)
    def processDirFiles(self,srcDir,onlyNew,dataset,fileName=None,prefix=None,suffix=None, ignoreCase=False,globPattern=None,update=True):
        #Iterates a directory return files (newly modified if onlyNew True, single file if fileName passed).
        #dataset is unique name to describe dataset; like 'brm_3DSonic' or 'djb_Picarro2099' or,better a hash of
        #full dir path:self.getHash(srcDir)
        #Tracks last processed time
        #globPattern is (new) shortcut for processing recursively.  Still uses srcdir, dataset & onlynew
        dt=self.getLastProcessedDT(dataset,onlyNew)
        t=time.time()#Track time we started
        s=fileName if fileName else suffix
        p=fileName if fileName else prefix
        ret=[]
        if globPattern:
            #Use passsed glob to fetch files recursively.  Ignore other filename filters.  ex: *.his
            for f in Path(srcDir).rglob(globPattern):
                if datetime.datetime.fromtimestamp(os.path.getmtime(f))<dt : continue
                #print(f)
                ret.append(str(f))
        else:
            for f in self.iterateFilesInDir(srcDir,fileSuffix=s,filePrefix=p,modDateAfter=dt,ignoreCase=ignoreCase):
                #print(f)
                ret.append(f)
        if update : self.setLastProcessedDT(dataset,t)
        return ret

    def getHash(self,text):
        """Returns hash of txt.  You can pass full directory path to use as unique dataset name"""
        h="c"+hashlib.sha256(str(text).encode("utf-8")).hexdigest()#make sure not starting with - (some systems)
        return h

    def iterateFilesInDir(self,srcDir,verbose=False,fileSuffix=None,filePrefix=None,maxFiles=-1,modDateAfter=None, ignoreCase=False):
        #Loop through files in passed directory, matching on fileSuffix and/or file prefix and yielding each filename
        #if ignoreCase, prefix/suffix match is case insensitive.
        #If maxFiles=-1, we process all.
        #if modDateAfter passed, only files modified after passed datetime are returned.
        #Note this could be enhanced to do recursive by using os.walk()
        i=0
        j=0
        matchSuffix=fileSuffix.lower() if ignoreCase else fileSuffix
        matchPrefix=filePrefix.lower() if ignoreCase else filePrefix

        for filename in os.listdir(srcDir):
            fullName=srcDir+"/"+filename
            matchFileName=filename.lower() if ignoreCase else filename

            if not os.path.isfile(fullName): continue
            i+=1 #file counter (skip dirs)
            if os.path.getsize(fullName)==0: continue
            if maxFiles>0 and j>maxFiles : continue
            if matchSuffix and not(matchFileName.endswith(matchSuffix)): continue
            if matchPrefix and not(matchFileName.startswith(matchPrefix)): continue
            if modDateAfter:
                if datetime.datetime.fromtimestamp(os.path.getmtime(fullName))<modDateAfter : continue

            if access(fullName, R_OK):
                j+=1 #got a match
                if verbose : print(("Processing: %s"%(filename,)))
                yield fullName
            else : print(("\n!!Couldn't open file:"+fullName+"\n"))

        if verbose : print(("Processeds %s of %s files in %s"%(j,i,srcDir)))


    def getLastProcessedDT(self,dataset,onlyNew=True):
        #helper function to record last processed time of passed module
        #If onlyNew=False, then we return a bot datetime
        #dataset is a unique job name like 'brm_3Dsonic'
        dtfile=self.timestampsDir+dataset
        if not os.path.isfile(dtfile) : onlyNew=False
        if onlyNew : dt=datetime.datetime.fromtimestamp(os.path.getmtime(dtfile))
        else : dt=datetime.datetime(1971,1,1)
        return dt

    def setLastProcessedDT(self,dataset,processedTime=None):
        #Sets last processed time for passed dataset (see above)
        #If processedTime not passed, defaults to now.
        #Creates file if not exists
        t=(processedTime,processedTime) if processedTime else None
        with open(self.timestampsDir+dataset,'a'): os.utime(self.timestampsDir+dataset,t)#Equiv to touch

    def touchFile(self,file_path,processedTime=None):
        #reset modification time of file (like touch).  This can be used to requeue a file that had an
        #error when iterating a directory with --onlyNew
        #fn is full file Path.  This does nothing if file doesn't exist
        #processedTime is time to set, none for now
        if os.path.exists(file_path):
            t=(processedTime,processedTime) if processedTime else None
            os.utime(file_path,t)#Equiv to touch

    #List printing
    def listToStr(self,lst, delim=','):
        #return passed list as string
        return delim.join(map(str,lst))

    def printList(self,lst,delim=","):
        #print passed list
        print((self.listToStr(lst,delim)))

    #validation functions

    def validate_isNone(self,s):
        #return True if s a 'none' value
        if s=='' or s=='None' or s=='NA' or s=='na' or s=='nan' or s=='NaN' :
            return True
        return False

    def validate_datetime(self,dt,allowNone=False):
        if allowNone and self.validate_isNone(dt) : return ''
        try:
            v=datetime.datetime.strptime(dt,'%Y-%m-%d %H:%M:%S')
            return v
        except ValueError:
            return False

    import datetime


    def validate_xdatetime(self, yr, mon, dy, hr, mn, sec=0, allowNone=False):
        """
        Validates and constructs a datetime object from components
        Returns:
        datetime.datetime: Valid datetime object if input is valid.
        str: Empty string if `allowNone` is True and input is None.
        bool: False if input is invalid.
        """

        # Check if `allowNone` is True and the input is considered "None".
        if allowNone and self.validate_isNone(yr):  # Assuming `validate_isNone` checks if input is None-like.
            return ''  # Return an empty string if None is allowed.

        try:
            # Construct a datetime string in the format 'YYYY-MM-DD HH:MM:SS'
            dt = f"{yr:0>4}-{mon:0>2}-{dy:0>2} {hr:0>2}:{mn:0>2}:{sec:0>2}"

            # Attempt to parse the string into a datetime object.
            v = datetime.datetime.strptime(dt, '%Y-%m-%d %H:%M:%S')
            return v  # Return the valid datetime object.

        except ValueError as e:
            # Catch and handle errors if the datetime components are invalid.
            print(f"Error: {e}")  # Print a user-friendly error message.
            return False  # Return False to indicate validation failure.


    def validate_int_csv(self,intstr,allowNone=False,unique=True):
        #validates a comma separated int list. returns false or list of 0+ integer nums
        if allowNone and self.validate_isNone(intstr) : return []
        try:
        # Split the input string by commas and convert each part to an integer
            #integers = [int(x) for x in intstr.split(',')]#this didn't handle strings with a leading comma
            if unique:integers = set(map(int, intstr.strip(',').split(',')))
            else : integers = list(map(int, intstr.strip(',').split(',')))

            # Return the list of integers
            return integers
        except ValueError:
            # If any part of the string is not a valid integer, handle the exception
            return False

    def validate_float(self,i,min=None,max=None,allowNone=False):
        if allowNone and self.validate_isNone(i) : return ''
        try:
            v=float(i)
            if min != None:
                if v<min : return False
            if max != None :
                if v>max : return False
            return v
        except ValueError : return False

    def validate_int(self,i,min=None,max=None,allowNone=False):
        if allowNone and self.validate_isNone(i) : return ''
        try:
            v=int(i.lstrip('0'))#strip leading zeros
            if min != None :
                if v<min : return False
            if max != None :
                if v>max : return False
            return v
        except ValueError :
            return False


    #OS call
    def run_shell_cmd(self, cmd,printOutput=True,quitOnError=True,stdin=None):
        """Run passed command and handle errors.  Py 3 compatible.  """
        #cmd is the primary command to run with arguments (e.g. ls -l)
        #stdin, if passed is piped into cmd.  This statement must have output (e.g. echo "asdf")
        #example:
        #   import utils as shell
        #   #to print directory listing
        #   shell.run_shell_cmd("ls -l")

        #   #to pipe ls through grep for svn files
        #   shell.run_shell_cmd("grep svn",stdin="ls -l")
        #This returns stdout
        try:
            if stdin : cmd=stdin+"|"+cmd
            p=subprocess.run(cmd,text=True,shell=True,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,check=quitOnError)
            if printOutput : print(p.stdout)
            return p.stdout

        except subprocess.CalledProcessError as e:
            print("Error: ",e.output)
            if quitOnError : sys.exit()

        return None
    def sysCallWithOutput(self,cmd,arguements=[]):
        #python 2.6+ compatible call to sys cmd and returns output
        #For calling other scripts (like perl scripts)
        #When adapted for v3, something like subprocess.check_output() should probably be used.
        #ex
        #import pyu_util_functions as pu
        #c=pu.PYUUtilFunctions()
        #print c.sysCallWithOutput('ls',['-l',])
        #FOR PYTHON 3 - see shell_utils.py or above run_shell_cmd.
        a=[cmd,]
        a.extend(arguements)
        o=subprocess.Popen(a,stdout=subprocess.PIPE).communicate()[0]
        return o
