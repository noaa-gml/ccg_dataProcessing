# bldsql.py  
# vim: tabstop=4 shiftwidth=4 expandtab
"""
SQL Query builder class


.. package:: db_utils.bldsql
.. author:: John Mund

Revision History:
File created on 11/1/2016.

See example.py in same directory for sample code.
"""


class BldSQL(object):
    """Class to generate sql statements programmatically using a query builder"""
    def __init__(self):
        self.initQuery()
        
    def initQuery(self): 
        """ #call to reset query builder """
        self._tables=[]
        self._wheres=[]
        self._cols=[]
        self._distinctKeyword=""
        self._groupbys=[]
        self._orderbys=[]
        self._limitKeyword=''
        self._parameters=[]
        self._leftJoins=[]
        self._tempTableName=""
        self._tempTableIndex=""
        self._innerJoins=[]
        
    def col(self,column): 
        """ #add a column to the select.  It can be just the column or with an alias 'col as 'name' """
        if (column not in self._cols) : self._cols.append(column)
    
    def table(self,tableName): 
        """ #Add a table to the from clause.  Can be table name or with alias """
        if tableName not in self._tables : self._tables.append(tableName)
        
    def createTempTable(self,tempTableName,index=None):
        """
        #This creates temp table tempTableName with index using query
        #Index should be passed like: 'index_name (col1,col2)'
        """
        self._tempTableName=tempTableName
        if index : self._tempTableIndex=index
        
    def innerJoin(self,tableClause):
        """ #add inner join clause ex: inner join table2 t2 on baseTable.num=t2.num """
        ij="inner join "+tableClause
        if ij not in self._innerJoins : self._innerJoins.append(ij)
        
    def leftJoin(self,tableClause): 
        """ #Add a left join to the from clause """
        #Not sure this is working yet.. ran into trouble with other joins not being straight/inner and it gives error 'unknown col...'
        lj="left join "+tableClause
        if(lj not in self._leftJoins) : self._leftJoins.append(lj)
        
    def where(self,whereClause,bindParameter=None,replace=False): 
        """ #Add clause to the where conditions.  All are and'd together. """
        #If passing a bind param, use a %s place holder in the where clause like this: where('num=%s',event_num)
        #% can be escaped by doubling: where("name like 'john%%'")
        #you can also use replace=True to change the value (like for a loop)
        # we'll save every bindParameter, then filter out the None's in the bind() method
        # this allows a mix of setting bindParameter and still hvae the replace option work.
        i=None
        if(whereClause in self._wheres) : i=self._wheres.index(whereClause) #ugly!  why no find?!
        if(i is not None and replace):
            self._parameters[i]=bindParameter
        else:
            self._wheres.append(whereClause)
            self._parameters.append(bindParameter)
            
    def wherein(self,whereClause,bindParameters):
        """ #Pass the where clause like "id_num in " this will append '(%s,%s,%s...)' 
        for each bindParameter and then add them as params 
        """
        whereClause+=" ("
        t=""
        for p in bindParameters:
            t=self.appendToList(t,'%s') #build the bind placeholders
            self._parameters.append(p)
        whereClause+=t
        whereClause+=")"
        self._wheres.append(whereClause)
    
    def whereCount(self) : 
        """ #returns the number of where clauses """
        return len(self._wheres)
    
    def distinct(self) : 
        """ #set distinct """
        self._distinctKeyword="distinct"
        
    def orderby (self,column) : 
        """ #set order by columns """
        if(column not in self._orderbys) : self._orderbys.append(column)
    
    def groupby (self,column) : 
        """ #set group by columns """
        if(column not in self._groupbys) : self._groupbys.append(column)
        
    def limit (self,num) : 
        """ #set result set row limit """
        self._limitKeyword="limit %s" % str(num)
    
    def cmd (self): 
        """ #generate sql string for passing to doquery below.  Add newlines for debugging (mysql doesn't care) """

        #select
        sql="\nselect %s %s " % (self._distinctKeyword,", ".join(self._cols))
        #from
        sql+=" \nfrom %s " % (", ".join(self._tables))
        
        #inner joins
        ij=" ".join(self._innerJoins)
        if(ij) : sql+="\n "+ij
        
        #left join
        lj=" ".join(self._leftJoins)
        if(lj) : sql+="\n "+lj
        
        #where
        where=" and ".join(self._wheres)
        if(where) : sql+=" \nwhere %s " % (where)
        #group by
        group = ", ".join(self._groupbys)
        if(group) : sql+=" \ngroup by %s " % (group)
        #order by
        order = ", ".join(self._orderbys)
        if(order) : sql+=" \norder by %s " % (order)
        #limit
        sql+=self._limitKeyword
        
        if(self._tempTableName):
            index="(index "+self._tempTableIndex+")" if self._tempTableIndex else ""
            sql="create temporary table "+self._tempTableName+" "+index+" as ("+sql+")"
        return sql
    
    def bind (self): 
        """ #return bind parameters for use in doquery """
        if self._parameters:
            a = [val for val in self._parameters if val is not None]
            return tuple(a)

        return None
        
    #General utility functions
    def appendToList(self,a,b,delim=','):
        #Inspite of confusing name in python, (dev is used to this name :) list is not a python list, but a string of delimited values.
        #if a and b, returns a,b
        #if a and !b, returns a
        #if !a and b, returns b
        if(a and b) : return "%s%s%s" % (a,delim,b)
        if(a) : return a
        else : return b
