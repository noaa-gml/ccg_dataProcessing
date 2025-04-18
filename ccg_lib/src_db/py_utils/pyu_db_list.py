#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import pickle as pickle
import datetime
import time

if('/ccg/src/db/db_utils' not in sys.path) : sys.path.append('/ccg/src/db/db_utils')
if('/ccg/src/db' not in sys.path) : sys.path.append('/ccg/src/db')
import db_conn
#if('/home/ccg/mund/obspack/src/python/obspack/op/baseclasses' not in sys.path) : sys.path.append('/home/ccg/mund/obspack/src/python/obspack/op/baseclasses')
#import op_data
#!!!!!!!!!!!!TEST datetime sort!!!!!!!!!!!!!!!

class DBList(object):
    """Python Utilities wrapper for making a list type object that uses a temporary database table as it's storage.  This allows virtually unlimited size at performance cost
    It implements the basic list api (iteration, clear, append, len, getitem...) and can be used as a generla replacement (although slower).
    If pickled passed true, it pickles (serializes) passed object and unserializes on read.
    append is extended to include a sort and a sort_dt (datetime) column which will allow for far faster sorting.
    use setSortCol() and then sort().
    It does some simple cacheing to speed up operations.
    """

    def __init__(self,pickled=False, verbose=False):
        super(DBList, self).__init__()
        self.db=db_conn.RO()
        #Create data store.
        sql="""CREATE temporary table tmp.t_data (
                `num` INT NOT NULL AUTO_INCREMENT,
                `sort` VARCHAR(255) NULL DEFAULT '',
                `sort_dt` DATETIME NULL,
                `data` blob,
                PRIMARY KEY (`num`),
                INDEX `one` (`sort` ASC),
                INDEX `two` (`sort_dt` ASC));
        """
        self.db.doquery(sql)
        self.sortcol='sort'
        self.pickled=pickled
        self._cachedData=[]
        self._cachedNums=[]
        self._appendList=[]
        self._n=0
        self._verbose=verbose
        self._noSort_dt=''
    def __resetCache__(self):
        self._cachedData=[]
        self._cachedNums=[]
        self._n=0
        
    def __len__(self):
        self.submitAppendList()#submit any cached inserts
        a=self.db.doquery("select count(*) from tmp.t_data",numRows=0)#Always fetch total from db.
        return a

    #Iter
    def __iter__(self):
        self.submitAppendList()#submit any cached inserts
        num,lastnum=0, self.__len__()
        if self._verbose :
            sys.stdout.write("\n")
            sys.stdout.write("DBList->iter(): iterating from 0 - %s" % (lastnum-1,))
            sys.stdout.write("\n")
            sys.stdout.flush()
        #We'll use the yield construct which should be more effecient.
        while num < lastnum :
            a=self.__getitem__(num,flushInsertCache=False)
            yield a
            num+=1
        sys.stdout.write("\n")
        sys.stdout.flush()

    def __getitem__(self,key,flushInsertCache=True):
        if flushInsertCache : self.submitAppendList()#submit any cached inserts
        data=None
        if isinstance(key,slice) : #fetch requested range directly
            t2=[]
            print("doing slicke select %s:%s",(key.start+1,key.stop))
            t=self.db.doquery("select data from tmp.t_data where num between %s and %s order by num",(key.start+1,key.stop),form='list')#Note the switch to 1 based index, which db uses
            if t:
                for item in t:
                    if self.pickled : t2.append(pickle.loads(item[0]))
                    else : t2.append(item[0])
            return t2
        
        else: #Attempt to load from cache.. this is more complicated than initial implimentation (using list.index(key)), but should be faster (O(1) vs O(n))
            key+=1 #convert to 1 based index, which db uses.
            if len(self._cachedNums) >0 :
                firstNum=self._cachedNums[0]
                i=key-firstNum#Index we'll check to see if cached, ie if looking for 14 and 11-20 is cached, i==3 or list[3]
                if i>=0 and i<len(self._cachedNums):#i is in range of cache ( 24-11=13 so no, and 4-11=-7 so no, but 14-11=3 so yes)
                    if key==self._cachedNums[i] :
                        data=self._cachedData[key-firstNum] #Load data
                    else :#debugging...
                        print("error in cache logic. key %s" % (key-1))
                        print(self._cachedNums)
                        sys.exit()
            if data==None : #cache miss, load next batch.
                if self._verbose :
                    sys.stdout.write('\r')#else just update text
                    sys.stdout.write("   DBList->getitem(%s)" % (key,))
                    sys.stdout.flush()
                self._cachedNums=[]
                self._cachedData=[]
                #t=self.db.doquery("select num,data from tmp.t_data where num>=%s order by num limit 20000", (key,),form='list')
                t=self.db.doquery("select num,data from tmp.t_data where num between %s and %s order by num", (key,key+20000),form='list')
                if t :
                    for item in t :
                        self._cachedNums.append(item[0])
                        self._cachedData.append(item[1])
                    data=self._cachedData[0]
                else: raise IndexError

            if data and self.pickled : data = pickle.loads(data)#Unserialize if needed.
        return data


    #iter for data + sort (not cached!)  This is to support copy, but not used in initial implementation so not optimized.  This should do cacheing like above.
    def getFullItems(self):#iterator to return data+ sort info
        self.submitAppendList()#submit any cached inserts
        num,lastnum=0,self.__len__()
        while num<lastnum:
            a=self.getFullItem(num,flushInsertCache=False)
            yield a
            num+=1
            
    def getFullItem(self,num,flushInsertCache=True):#returns data+sort into
        if flushInsertCache : self.submitAppendList()#submit any cached inserts
        a=self.db.doquery("select data,sort,sort_dt from tmp.t_data where num=%s",(num+1,))
        if a :
            a= a[0]
            if self.pickled : a['data'] = pickle.loads(a['data'])
        return a
    
    #Sorting
    def setSortCol(self,col):#can be sort or sort_dt
        self.sortcol=col
        
    def sort(self,reverse=False, key=''):
        self.submitAppendList()#submit any cached inserts
        self.db.doquery("drop temporary table if exists tmp.t_datasorted")
        self.db.doquery("create temporary table tmp.t_datasorted like tmp.t_data")
        sql="insert tmp.t_datasorted (sort,sort_dt,data) select sort,sort_dt,data from tmp.t_data order by "+self.sortcol
        if reverse : sql += " desc"
        self.db.doquery(sql)
        self.db.doquery("drop temporary table tmp.t_data")
        self.db.doquery("create temporary table tmp.t_data like tmp.t_datasorted")
        self.db.doquery("insert tmp.t_data select * from tmp.t_datasorted")
        self.__resetCache__()
        
    #Inserts
    def appendone(self,data,sort='',sort_dt=''):
        #I don't recall the need for this, but inserts directly with no cacheing.
        if self.pickled : data= pickle.dumps(data,pickle.HIGHEST_PROTOCOL)
        a=self.db.doquery("""insert tmp.t_data (sort,sort_dt,data) values (%s,%s,%s)""",(sort,sort_dt,data))
        return a
    
    def append(self,data,sort='',sort_dt=''):
        #Append to list using a naive cacheing scheme to make the inserts a little more effecient (bundle 1000)
        
        #See if sort_dt was passed, if not look for a datetime attr of data
        if sort_dt=='' and hasattr(data,'datetime') : sort_dt=data.datetime
                
        if self.pickled : data= pickle.dumps(data,pickle.HIGHEST_PROTOCOL)
        self._appendList.append((sort,sort_dt,data))
        if len(self._appendList)>=1000 : self.submitAppendList() #arbitrary
        #self.dumplist()
        
    def submitAppendList(self):
        #Submit cached list of inserts (if any).  Should be called whenever list is read.
        if len(self._appendList) > 0 :
            if self._verbose and self._n==0 : sys.stdout.write("\n") #new line.
            a=self.db.doquery("""insert tmp.t_data (sort,sort_dt,data) values (%s,%s,%s)""",self._appendList,multiInsert=True)
            self._n+=len(self._appendList)
            self._appendList=[]
            if self._verbose :
                sys.stdout.write('\r')
                sys.stdout.write("DBList->append(): %s inserted" % (self._n,))
                sys.stdout.flush()
    #This is wrong def of count,, should be counting occurences i think...
    #This would be easy for native datatypes (just select against db), but complicated for serialized objects.
    #def count(self):
    #    return self.__len__()
    
    def clear(self):
        #Clear list
        self.db.doquery("delete from tmp.t_data")
        self.db.doquery("alter table tmp.t_data auto_increment=1")#Reset counter
        self.__resetCache__()
        
    def copy(self):
        b=DBList()
        #def _copydata(self):
        #    #super slow!  would need a perm table to do and fit in model
        for a in self.getFullItems():
            if self.pickled : a['data']=pickle.dumps(a['data'])#,pickle.HIGHEST_PROTOCOL)
            b.append(a['data'],a['sort'],a['sort_dt'])
        #b.dumplist()
        
    def copy2(self):#This doesn't currently work as the ro user doesn't have regular table create permissions.  Turns out wasn't needed so didn't persue, but should be much faster in theory.
        t0=time.time()
        b=DBList()
        tableName="t_%s" % (int(time.time()))
        self.db.doquery("create table tmp."+tableName+" as select * from tmp.t_data")
        b.fill(tableName)
        t1=time.time()
        print("copy operation: %s"%(t1-t0,))
        
    def fill(self,tableName):#NOT USED
        #fill data table from another table (in copy operation)
        self.clear()
        self.db.doquery("insert tmp.t_data select * from tmp."+tableName)
    
    def dumplist(self):#debugging...
        self.submitAppendList()#submit any cached inserts
        print("data:")
        self.db.doquery("select * from tmp.t_data",form='scr')
        
    def printList(self):#debugging...
        self.submitAppendList()#submit any cached inserts
        for a in self.getFullItems():
            print("Data:%s sort:%s sort_dt:%s" %(a['data'],a['sort'],a['sort_dt']))
        
        
        
        
        
        
        
        
        
        
        
        
        
