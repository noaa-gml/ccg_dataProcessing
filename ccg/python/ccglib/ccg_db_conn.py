# vim: tabstop=4 shiftwidth=4 expandtab
# db_conn.py

"""
.. package:: db.ccg_db
.. author:: John Mund

Revision History:
File created on 11/1/2016.

Use as the database server - May 17, 2023

"""

import subprocess
import sys, errno
import datetime, time
import decimal
import csv
try:
        # for python MySQLdb
        import MySQLdb
        from MySQLdb.converters import conversions
        from MySQLdb.constants import FIELD_TYPE

except ImportError:
        # for python PyMySQL
        import pymysql as MySQLdb
        from pymysql.converters import conversions
        from pymysql.constants import FIELD_TYPE

#import MySQLdb #Note; python3 installations must install mysqlclient, which is a 3 compliant fork.  We may want to look into
#other client libs like native mysql connector.

import ccg_bldsql as bldsql


class DatabaseConn:
    """db abstraction utility class

    There is a convience class to log you in:
    RO() which logs into ccgg (readonly)
    or for !!db developer only!! - ProdDB() ->ccgg(readwrite)

    Most callers/users should use RO()
       which logs you into the production ccgg database with read only
       rights and temp table/exec/insert rights on the tmp database

    Example
    -------
    Import and make readonly Connection

    import db_utils.db_conn as db_conn
    db=db_conn.RO()

    Pass select query using %s as place holder for parameterized query to sanitize inputs

    a=db.doquery("select num as data_num, v.* from flask_data v where date > %s limit 10",('2016-01-01',))
    if a :
        for row in a :
            print(("num: %s date: %s time: %s" % (row['data_num'],row['date'],row['time'])))


    See example.py for further examples.
    """

    def __init__(self, user='readonly', password='', db='', host='', convertDecToFloat=True):

        #Class instance variables
        self._c = None
        self._conn = None
        self.sql = bldsql.BldSQL()

        try:
            # Mapping mysql dec to python native floats (instead of dec obj) results in ~3x speed up on large selects
            if convertDecToFloat:
                # I don't think it causes any issues, but making fully optional just in case.
#                from MySQLdb.converters import conversions
#                from MySQLdb.constants import FIELD_TYPE
                conversions[FIELD_TYPE.DECIMAL] = float
                conversions[FIELD_TYPE.NEWDECIMAL] = float
                self._conn = MySQLdb.connect(host=host ,user=user, passwd=password, db=db, conv=conversions)
            else:
                self._conn = MySQLdb.connect(host=host ,user=user, passwd=password, db=db)

        except Exception as e:
            raise Exception(e)

    def __del__(self):
        self._conn.close()


    def doquery(self,
        query=None,
        parameters=None,
        numRows=-1,
        form='dict',
        numpyFloat64=True,
        outfile=None,
        timerName=None,
        commit=True,
        multiInsert=False,
        insert=False
    ):
        """ This is used to issue a sql query.

        #  Returns, by default, a list of row dictionaries with col name as key, None if no results and raises exception/exits on error.
        #  All selects (except to csv) are limited by mem size or other python mysqldb constraints.
        #  -form is the output format
        #       python native:
        #       -'dict' (default) returns a list of row dictionaries with col names as keys.
        #       -'list' (faster for large sets) it returns a list of row lists
        #       -'numpy' results are a dictionary of numpy arrays, 1 array for each column.  Col names are keys into the dictionary.
        #           if numpy and nympyFloat64 is true, number arrays that are automatically created as decimal.Decimal objects will be created as float64 types instead (default)
        #       -'text' it returns a nicely formatted list of strings

        #       file output: (requires outfile)
        #       -'csv' sends to outfile in csv format.  all strings are quoted, embedded quotes are double quoted.  comma separator.
        #           Note; this operation is scalable (tested on 8 mil rows) as it fetches in chunks.
        #       -'tsv' sends to outfile in tab separated format.  all strings are quoted, embedded quotes are double quoted.  comma separator
        #       -'dat' sends formatted text lines to outfile
        #       -'txt' sends formatted text lines to outfile
        #       -'excel' sends excel compatible csv file to outfile
        #       -'npy' creates a npy format result file that can be imported in other programs.(not programmed yet)
        #           You can call availableFileFormats() to get a list of available formats
        #       -'csv-nq' sends to outfile without any quoting

        #       screen output:
        #       -'std' formatted text output to standard out (using print)
        #       -'scr' formatted text output to screen (less viewer)

        #  -If numRows=0, this returns the first value of the first row (convienence), None on no results
        #       -1 (default) for all results, or dml statement (like drop table.)
        #
        #  -parameters is a tuple of bind parameters in same order as %s place holders in the query.
        #   Bind parameters should be used in general for where clauses to prevent sql injection on unknown sourced params. If only 1 bind parameter, follow with , eg: (myvar,)
        #   To pass insert/update to mysql null, use None in python bind value

        #  -If timerName is passed, a the query is timed results printed.

        #  You can use the BldSQL sql object to build a query (see it's documentation), which is convient when building programmatically.
        #  As a convience, If you don't pass query (or parameters), then the BldSQL object is used to generate the query (and parameters)
        #       You could also use sql.cmd() and sql.bind() to get them
        # If commit=True, then autocommit is set true and every command is implicitly commited.
            #jwm - 3.23 - changing to use connection autocommit.
            #To manually use transactions you can use either pass in batch command like this:
            #a=db.doquery("start transaction; call tagwr_addFlaskDataTag(%s,%s,%s,%s); commit",[12357175, 10, '','John'])
            # or if wanting to span multiple calls to doquery, pass commit=False in each command so it doesn't get turned on
            #a=db.doquery("start transaction", commit=False)
            #a=db.doquery("call tagwr_addFlaskDataTag(%s,%s,%s,%s)",[12357175, 10, '','John'],commit=False)
            #a=db.doquery("rollback", commit=False)
        # If multiInsert=True then we do a executeMany instead of execute.  Parameters should be a list of tuples
        # If insert=True, this returns lastinsertid (if appropriate)
        #   syntax looks like:
        #   c.executemany("insert into T (F1,F2) values (%s, %s)",[('a','b'),('c','d')])
        #   See doMultiInsert() below for example and wrapper
        #

        #See /ccg/src/db/db_utils/examples.py for working examples
        """



        start = time.time()#For timing purposes
        end = 0
        ret = None
        #If no query (or params) passed, load them from the BldSQL object.
        if query is None:
            query = self.sql.cmd()
            if parameters is None:
                parameters = self.sql.bind() #Only check this if query is using query builder too.

        try:
            self._conn.autocommit(commit)#jwm added 3/25
            self._c = self._conn.cursor()
            self._c._defer_warnings = True #Not entirely clear on effect this has, but put it in on rec from the internets to suppress annoying warning messages on things like drop table if exists

            #For file output we'll iterate over the results so we don't need to bring the whole set into memory.
            outToFile = True if form in self.availableFileFormats() else False

            if multiInsert:
                self._c.executemany(query, parameters)
                #self._conn.commit()
                self._c.close()
                return
            elif insert:
                self._c.execute(query, parameters)
                #self._conn.commit()
                id = self._c.lastrowid
                self._c.close()
                return id
            elif outToFile:
                #Select results into a temp table to iterate over.
                #This adds time (particularly on large datasets), but is safetest way to chunk
                #through the results without trying to load here or altering query.
                #See comments below in outputToFile
                self._c.execute("drop temporary table if exists tmp.t__db_conn_work_tbl", None)
                self._c.execute("create temporary table tmp.t__db_conn_work_tbl as " + query, parameters)

            else:
                self._c.execute(query, parameters)

            end = time.time() #Skips post processing
            a = None

            if form in ['numpy', 'npy', 'dataframe']:
                #Only load conditionally as not all environments will have this available. Note we'll let this fail ungracefully
                import numpy as np
            if form == 'dataframe':
                import pandas as pd
            #on error for now.

            if self._c.rowcount > 0:
                if numRows == 0:
                    a = self._c.fetchone()
                    if a: ret = a[0]
                if numRows == -1:

                    if outToFile:
                        ret = self.outputToFile(outfile, form, timerName)

                    #The rest of the output formats all return the data in a list or massage the list first and return, so fetch all results (inefficient on large sets!)
                    #and process as needed.
                    else:
                        a = list(self._c)

                        if a: #if we have a result set, package up per request and return it.
                            header = [li[0] for li in self._c.description] #list of column names

                            if form == 'dict':#a list of row dictionaries with col names as keys
                                b = list()
                                for row in a:
                                    b.append(dict(zip(header, row)))
                                ret = b

                            elif form in ('numpy', 'dataframe'): #dict of numpy arrays, 1 per col.  dict keys are column names
                                keys = [li[0] for li in self._c.description]
                                cols = zip(*a)#convert to column lists
                                b = dict()
                                for i, col in enumerate(cols):
                                    dtype = None #default to auto detect type

                                    if numpyFloat64 : #Check to see if number is a 'decimal' type and force to be float64 (for compatibility with downstream uses)
                                        #jwm - 1/19 - added logic to find first non-none value
                                        first = next((item for item in col if item is not None), None)
                                        if isinstance(first, (decimal.Decimal,)) : dtype=np.float64

                                    arr = np.asarray(col, dtype=dtype)

                                    b[keys[i]] = arr #Set results into dictionary

                                if form == 'dataframe':
                                    ret = pd.DataFrame(b)
                                else:
                                    ret = b

                            elif form == 'text': #formatted text output
                                ret = self.listToTextCols(a, header)

                            elif form == 'scr': #formatted text to less editor (if available)
                                self.outputToScreen(self.listToTextCols(a, header))

                            elif form == 'std': #formatted text to standard out
                                out = self.listToTextCols(a, header)
                                for line in out: print(line)

                            else: #list of lists
                                ret = a

                        else :
                            #if commit: self._conn.commit() #Send through commit if requested
                            ret = self._c.rowcount #DML statement, return number of rows affected (if any)
            self._c.close()


        except Exception as e:
            self._c.close()
            print("\n\nSQL that cause error:\n%s" % (query,))
            print("\nBind parameters: " )
            print(parameters)
            print("\n\n")
            raise Exception(e)


        if timerName: print("%s (s):%s" % (timerName,str(end-start)))

        return ret

    def doMultiInsert(self, sql, params, maxLen=10000, all=False):
        """
        #wrapper to do a multi insert.. mostly just to handle when to send through if appending in a loop.
        #Call with all=True after loop to send through any remaining
        #Returns true when data was submitted (and params[] should be cleared), false if we haven't hit the threshold yet.
        #   example block:
        #     params=[]
        #     i=1
        #     sql="insert mund_dev.t_brmAerodyneData (dt,c2h6,ch4) values (%s,%s,%s)"
        #     for row in fh.readf(delim=',',skip_lines=1):
        #         c2h6=row[0]
        #         ch4=row[1]
        #         dt=row[2]
        #         params.append([dt,c2h6,ch4])
        #         if self.db.doMultiInsert(sql,params):params=[]
        #
        #    self.db.doMultiInsert(sql,params,all=True)#Send any remaining through.
        """

        if len(params)>maxLen or all:#send thru
            self.doquery(sql, params, commit=True, multiInsert=True)
            return True
        return False

    def availableFileFormats(self):
        """ #returns a list of currently available file output formats """
        return ['csv','tsv','dat','txt','excel','csv-nq']

    def outputToFile(self, outfile, form, timerName):
        """
        #Output current result set to file.  See comments above for available form (file formats)
        #We don't pass results because we don't want to load the full set into memory if we don't have to.. we'll just read/write a chunk at time.
        #Note, the mysqldb lib apparently reads the whole rs into memory even when using fetch many, so we'll implement our own,
        #Also note, we use a temp table intermediate because altering the query directly (adding limit) could have weird effects
        #depending on the query (like a group by).  Using a tmp table seems pretty safe, although slower.
        """

        if outfile is None:
            print("outfile is required for file output")
            sys.exit()
        query = "select * from tmp.t__db_conn_work_tbl"
        f = open(outfile,'wt')
        try:
            #If we're writing a text formatted (space delim) file, read whole results into a list, format and write out.  Hopefully not too big
            if (form=='dat' or form=='txt') :
                self._c.execute(query)
                header = [li[0] for li in self._c.description] #list of column names
                b = self.listToTextCols(list(self._c), header)
                for row in b:
                    f.write('%s\n' % row)

            else: #use the csv writer to format output as requested.
                if form == 'excel':
                    writer = csv.writer(f, dialect='excel')
                else:
                    delim = ' ' if form == 'tsv' else ','
                    quoting = csv.QUOTE_NONNUMERIC if form != 'csv-nq' else csv.QUOTE_NONE
                    writer = csv.writer(f, delimiter=delim, quoting=quoting)

                chunk = 100000 #arbitrary
                limitFrom = 0

                #fetch the first chunk and extract header info
                self._c.execute("%s limit %s,%s"%(query, limitFrom, chunk))
                header = [li[0] for li in self._c.description] #list of column names
                writer.writerow(header)

                n = self._c.rowcount

                #Write out and fetch any remaining.
                while n :
                    if timerName : print("Timer:%s writing rows %s to %s"%(timerName, limitFrom, limitFrom+chunk-1))
                    for row in self._c :
                        writer.writerow(row)
                    limitFrom += chunk
                    self._c.execute("%s limit %s,%s"%(query, limitFrom, chunk))
                    n = self._c.rowcount

        finally:
            f.close()

        return True

    def outputToFileOld(self, outfile, form):
        """
        #Output current result set to file.  See comments above for available form (file formats)
        #We don't pass results because we don't want to load the full set into memory if we don't have to.. we'll just read/write a line at time.
        """

        if outfile is None :
            print("outfile is required for file output")
            sys.exit()

        f = open(outfile,'wt')
        try:
            header = [li[0] for li in self._c.description] #list of column names

            #If we're writing a text formatted (space delim) file, read whole results into a list, format and write out.
            if form=='dat' or form=='txt':
                b = self.listToTextCols(list(self._c), header)
                for row in b:
                    f.write('%s\n' % row)

            else: #use the csv writer to format output as requested.
                if form=='excel':
                    writer = csv.writer(f, dialect='excel')
                else:
                    delim = ' ' if form == 'tsv' else ','
                    quoting = csv.QUOTE_NONNUMERIC if form != 'csv-nq' else csv.QUOTE_NONE
                    writer = csv.writer(f, delimiter=delim, quoting=quoting)

                writer.writerow(header)
                for row in self._c :
                    writer.writerow(row)
        finally:
            f.close()

        return True

    def outputToScreen(self, lines):
        """ #Outputs lines to less viewer """

        try:
            #editor=os.getenv('EDITOR','vi') less worked better...
            pager = subprocess.Popen(['less', '-F', '-R', '-S', '-X', '-K'], stdin=subprocess.PIPE, stdout=sys.stdout, text=True)
            for row in lines:
                pager.stdin.write('%s\n' % str(row))
            #pager.communicate()
            pager.stdin.close()
            pager.wait()

        except OSError as e:
            if e.errno==2: #less not available, print to stderr
                #print >> sys.stderr,"\n".join(lines) #not working in py3 (syntax)
                print("\n".join(lines))#couldn't figure the py3 stderr syntax
            else : print(e.strerror)
            sys.exit()
        except IOError as e: #quitting less causes a broken pipe exception.  I'm probably not using Popen properly...
            if e.errno != errno.EPIPE:
                raise Exception(e)

        return True

    def listToTextCols(self, lines, header):
        """
        #Returns a formatted list of passed list of output lines
        #These will be space delimited with min 3 space gap
        """

        spacing = 3

        #We need the headers in with the lines to figure out the widths, but don't want to insert (inefficient) so we'll add temporarily to the end
        lines.append(header)
        widths = [max(len(str(value)) for value in column) + spacing
              for column in zip(*lines)]
        lines.pop() #pull off the header

        out = []
        #Insert the column headers
        out.append(''.join('%-*s' % item for item in zip(widths, header)))
        #and all the data
        for line in lines:
            out.append(''.join('%-*s' % item for item in zip(widths, line)))

        return out

    def getSelectedDB(self):
        """ return name of database being used """

        return self.doquery("select database()", numRows=0)


#Convience subclasses to log in to user/dbs. 
class DevDB(DatabaseConn):
    def __init__(self, db="mund_dev"):
        pw = "" #so doesn't show up in error messages
        DatabaseConn.__init__(self, user="", password=pw, db=db)
        print ("Using database:"+str(self.getSelectedDB())) #During dev, doquery sometimes returns weird values

class ProdDB(DatabaseConn):
    def __init__(self, db='ccgg'):
        pw=""
        DatabaseConn.__init__(self, user="", password=pw, db=db)

class RO(DatabaseConn):#Has write permissions in tmp db
    def __init__(self, db="ccgg"):
        pw=""
        DatabaseConn.__init__(self, user="", password=pw, db=db)

