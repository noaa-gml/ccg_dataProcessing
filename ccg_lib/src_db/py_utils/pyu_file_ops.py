#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Python Utility Class to do common file operations
Note; This should be python2/3 compatible.

"""

import os
import sys

import datetime
import csv
import logging

class PYUFile(object):
    """Python Utilities wrapper for file operations
    -Currently has a csv reader/parser that can handle arbitrarily large files and a wrapper for native log file

    --need to add dict->csv writer and row->append to csv writer
    something like:
            file1=open(f2,"w")
            writes=csv.writer(file1,delimiter=' ',quoting=csv.QUOTE_ALL)
            g=mygen(reader)
            for x in g:
                writes.writerow([x])
    """

    def __init__(self,filename=""):
        super(PYUFile, self).__init__()
        self.filename=filename
        self.fieldnames=[]
        self.header_line=None
        self.skip_lines=0
        self.comment_char="#"
    def log(self,txt,echo=False):
        """Basic logging functionality
                logfile=pyu_file.PYUFile('/tmp/test.txt')
                logfile.log(txt)
                
        """
        logging.basicConfig(format='%(asctime)s: %(message)s',filename=self.filename,level=logging.DEBUG,filemode='w')#Clear on load
        logging.debug(txt)
        if echo : print(txt)

    def isfile(self):
        #Returns true if the filename exists as a file
        return os.path.isfile(self.filename)

    def writeCSV(self,rows,delim=','):
        #very simple csv writer. rows is a list of tuples to write out. no quotes or embedded delims allowed. overwrites existing file
        #Note; db_conn can write to csv directly (and more efficiently than reading from the db and passing to this)
        with open(self.filename,'w') as f:
            for row in rows:
                f.write(delim.join(map(str,row)))


    def readf(self,skip_lines=0,comment_char="#",delim=None):
        """This is just a wrapper to below that defaults to simple whitespace (split) mode as that is the one most often being used
        (parser is flaky)/  See below for comments."""
        return self.readfile(skip_lines=skip_lines, comment_char=comment_char, simple_whitespace=True,simple_delim=delim)

    def readfile(self,header_line=None,fieldnames=[],skip_lines=0,comment_char="#",simple_whitespace=False,simple_delim=None):
        """Returns an iterator for file
            jwm - 6/12/18.  This parser sucks for whitespace delimited files.  Use simple_whitespace=True.

            This should handle arbitrarily large files (tested 1gb)
            This reads file in 1 line at a time (does not load all into memory) and returns rows for each next call [for i in readfile()] or for row in readfile():

            This uses the 'generator' syntax and is memory efficient for large files assumming caller processes each row and doesn't store them in memory.
            In testing, 4 million row file (1.1gb) is iterated with < 30K total memory used.

            We attempt to handle python2/3 syntax

            :header_line - # of lines after comment and blank lines for the col headers.
                None - no header, returns list of values for each row
                0 - first non comment line is header row.  Returns dict for each row.
                n - nth row after comments is header row.  Returns dict for each row.
                -1 - last comment row is header row.  Returns dict for each row.

            Alternately, pass field_names
            :field_names - column headers.  Returns dict for each row.

            :skip_lines - skip n lines
            if skip_lines>0, we'll skip that many leading lines before processing.  header_line will be relative (after skipping lines)

            :comment_char - character that designates a comment row to be skipped.

            This skips leading blank and comment lines.

            simple_whitespace=True to skip csv parseing and do a simple split (needed for variable whitespace files because sniffer can't seem to read them)  (Only 2.x tested)
            Actually, the sniffer is kind of flaky, so I pretty much just use this now

            simple_delim=None does above on any whitespace. if specified (like ','), then we split on str.
        """
        self.fieldnames=fieldnames
        self.skip_lines=skip_lines
        self.header_line=header_line
        self.comment_char=comment_char
        if sys.version > '3':
            with open(self.filename, 'r', newline='',encoding='utf-8-sig') as file_:#I think safe to pass utf-8-sig.  see https://stackoverflow.com/questions/17912307/u-ufeff-in-python-string.  Apparently windows sometimes specifies endian (even on utf8) which causes confusion.
                if simple_whitespace : 
                    self._strip_comments(file_)
                    self._skip_lines(file_)
                    for line in file_:
                        line=line.strip()
                        a=line.split(simple_delim)
                        trimmed_list = [s.strip() for s in a]
                        yield trimmed_list # line.split(simple_delim)
                else :
                    reader=self._get_csv_reader(file_)
                    try:
                        for row in reader: yield row

                    except csv.Error as e:
                        sys.exit('file {}, line {}: {}'.format(filename, reader.line_num, e))

        else: #2.x
            with open(self.filename, 'rb') as file_:
                if simple_whitespace :
                    self._strip_comments(file_) #note this order is different than reader.  This is to skip comments, then skip header.  The complicated one below doesn't work on whitespace very well.
                    self._skip_lines(file_)
                    for line in file_:
                        line=line.strip()
                        yield line.split(simple_delim)
                else:
                    reader=self._get_csv_reader(file_)
                    try:
                        for row in reader: yield row

                    except csv.Error as e:
                        sys.exit('file {}, line {}: {}'.format(filename, reader.line_num, e))


    def _strip_comments(self,file_):
        """Strip out leading comments upto header line
        """
        prevRow=""
        while True :
            rowstart=file_.tell()#Mark the current line position
            row=file_.readline().strip()
            if row and not row.startswith(self.comment_char) : #readline returns '' on eof
                file_.seek(rowstart)#Reset to start of line
                break
            prevRow=row #save off so we have last comment row.

        #If no fieldnames have been set yet and we were told the header is last comment line, store now.
        if not self.fieldnames and self.header_line==-1 :
            self.fieldnames=next(csv.reader([prevRow[1:]])) #strip #

    def _skip_lines(self,file_):
        """Skips specified number of line.
        """
        if self.skip_lines>0 :
            for i in range(0,self.skip_lines) :
                row=file_.readline()

    def _find_header_line(self,file_,dialect=None):
        """Finds and sets header row if header_line was set.  Seeks the file pointer to row after
        """
        if self.header_line!=None and self.header_line>=0 :
            for i in range(-1,self.header_line) :
                row=file_.readline()
                if (i+1)==self.header_line :
                    if not self.fieldnames :
                        self.fieldnames=next(csv.reader([row],dialect))
                    break;
                i+=1


    def _get_csv_reader(self,file_):
        """sniffs file to get dialect & header, then returns a csv.reader
        """
        self._skip_lines(file_)
        self._strip_comments(file_)

        #Read the first bit of file to sniff
        tell=file_.tell()
        head=file_.read(2048)
        file_.seek(tell)#rewind

        #Attempt to detect csv dialect (quoting, delims...)
        dialect = csv.Sniffer().sniff(head)

        #Try to find header line if specified.
        self._find_header_line(file_,dialect)

        if(self.fieldnames):#return a dict
            reader=csv.DictReader(file_,self.fieldnames,dialect)
        else : reader=csv.reader(file_,dialect)
        #reader=csv.reader(file_,delimiter=" ")
        return reader
