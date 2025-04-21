
import sys
import os
import sqlite3
import datetime

class magiccDB:


        #-----------------------------------------------------------------
    def __init__(self, db_filename, empty=False):


        db_exists = True
        if not os.path.exists(db_filename):
            db_exists = False

        self.conn = sqlite3.connect(db_filename)
        if db_exists is False:
            self.create_schema()
    
        self.c = self.conn.cursor()

        if empty:
            self.clear()


        #-----------------------------------------------------------------
    def insert_sample_info(self, data):

        
        if len(data) != 5 and len(data) != 7:
            print("magiccDB insert_sample_info: Wrong number of parameters.", file=sys.stderr)
            return

        if len(data) == 5:
            self.c.execute("insert into sample_info (manifold, port, serial_num, sample_type, num_samples) values (?, ?, ?, ?, ?)", data)
        else:
            self.c.execute("insert into sample_info (manifold, port, serial_num, sample_type, num_samples, pressure, regulator) values (?, ?, ?, ?, ?, ?, ?)", data)
        
        self.conn.commit()
        rowid = self.c.lastrowid

        return rowid

        #-----------------------------------------------------------------
    def insert_analysis_info(self, data):
        """
        sample_id is same as rowid from sample_info table
        """

        if len(data) != 4:
            print("magiccDB insert_analysis_info: Wrong number of parameters.", file=sys.stderr)
            return

        self.c.execute("insert into analysis (sample_id, sample_num, flask_id, event_num) values (?, ?, ?, ?)", data)
        
        self.conn.commit()
        rowid = self.c.lastrowid

        return rowid

        #-----------------------------------------------------------------
    def insert_entry(self, sample_info, analysis_info):
        """ Insert new data into the sample_info and analysis tables. """


        if len(sample_info) != 7 or len(analysis_info) != 3:
            print("magiccDB insert_entry: Wrong number of parameters.", file=sys.stderr)
            return

        (manifold, port, serial_num, sample_type, num_samples, pressure, regulator) = sample_info
        (flask_nums, flaskid, eventnum) = analysis_info # flask_nums, flask id, and eventnum are lists for pfp's

        sql = "insert into sample_info (manifold, port, serial_num, sample_type, num_samples, pressure, regulator) values (?, ?, ?, ?, ?, ?, ?)"
        self.c.execute(sql, sample_info)
        rowid = self.c.lastrowid

        if sample_type == "flask":
            t = (rowid, 1, flaskid, eventnum)
            sql = "insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'not_ready')"
            self.c.execute(sql, t)

        elif sample_type == "cal":
            for i in range(num_samples):
                t = (rowid, i+1, flaskid, eventnum)
                sql = "insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')"
                self.c.execute(sql, t)

        elif sample_type == "warmup":
            for i in range(num_samples):
                t = (rowid, i+1, flaskid, 0)
                sql = "insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')"
                self.c.execute(sql, t)

        elif sample_type == "nl":
            for i in range(num_samples):
                t = (rowid, i+1, flaskid, 0)
                sql = "insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')"
                self.c.execute(sql, t)

        elif sample_type == "pfp":
            for i in range(num_samples):
                t = (rowid, flask_nums[i], flaskid[i], eventnum[i])
                sql = "insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')"
                self.c.execute(sql, t)

        self.conn.commit()

        #-----------------------------------------------------------------
    def update_entry(self, rowid, sample_info, analysis_info):
        """ Update the sample_info at 'rowid' and also any corresponding analysis info.
        """

        if len(sample_info) != 7 or len(analysis_info) != 3:
            print("magiccDB update_entry: Wrong number of parameters.", file=sys.stderr)
            return

        # extract values from the passed in data variables
        (manifold, port, serial_num, sample_type, num_samples, pressure, regulator) = sample_info
        (flask_nums, flaskid, eventnum) = analysis_info # flask_nums, flask id, and eventnum are lists for pfp's

        # update the sample_info table
        t = (manifold, port, serial_num, sample_type, num_samples, rowid)
        self.c.execute("update sample_info set manifold=?, port=?, serial_num=?, sample_type=?, num_samples=? where id=?", t)

        # first clear out old entries (because the number of aliquots may have changed) from analysis table
        sql = "delete from analysis where sample_id=?"
        self.c.execute(sql, (rowid,))

        # insert new entries
        if sample_type == "flask":
            t = (rowid, 1, flaskid, eventnum)
            self.c.execute("insert into analysis (sample_id, sample_num, flask_id, event_num) values (?, ?, ?, ?)", t)

        elif sample_type == "cal":
            for i in range(num_samples):
                # t is sample_id, sample_number, serial_number, event_number)
                t = (rowid, i+1, flaskid, eventnum)
                self.c.execute("insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')", t)

        elif sample_type == "nl":
            for i in range(num_samples):
                # t is sample_id, sample_number, serial_number, event_number)
                t = (rowid, i+1, flaskid, 0)
                self.c.execute("insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')", t)

        elif sample_type == "pfp":
            for i in range(num_samples):
                # t is sample_id, pfp flask number, pfp flask id, pfp flask event_number)
                t = (rowid, flask_nums[i], flaskid[i], eventnum[i])
                self.c.execute("insert into analysis (sample_id, sample_num, flask_id, event_num, status) values (?, ?, ?, ?, 'ready')", t)


        self.conn.commit()

        #-----------------------------------------------------------------
    def delete_entry(self, rowid):
        """ Delete the row from the sample_info table, and delete all entries
        in the analysis table that correspond to the sample entry.
        """

        sql = "delete from sample_info where id=?"
        self.c.execute(sql, (rowid,))

        sql = "delete from analysis where sample_id=?"
        self.c.execute(sql, (rowid,))

        self.conn.commit()

        #-----------------------------------------------------------------
    def insert_nl_entries(self, data, num_cycles):
        """ Insert the entries for a nl response curve calibration into
        the analysis table.

        Data contains a list of tuples, each tuple has information about one standard,
            (id string, serial number, manifold, port number)

        Calls self.insert_entry for each standard with serial number of the tank,
        the manifold and port it's connected to, and the id string of the
        standard, such as 'S1', 'S2', 'S3'...
        """

        # add one entry for each std in the nl response curve
        for (std_id, sernum, manifold, port, press, reg) in data:
            t = (manifold, port, sernum, 'nl', num_cycles, press, reg)
            a = [None, std_id, None]
            rowid = self.insert_entry(t, a)

        #-----------------------------------------------------------------
    def set_status(self, rowid, status):

        self.c.execute("update analysis set status=? where id=? ", (status, rowid))
        self.conn.commit()

        #-----------------------------------------------------------------
    def mark_complete(self, rowid):
        """ Mark the status field for an entry in the analysis table as 'complete',
        and update the adate field with the current time.
         """

        now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        sql = "update analysis set status='complete', adate=? where id=? "
        self.c.execute(sql, (now, rowid))
        self.conn.commit()

        #-----------------------------------------------------------------
    def mark_ready(self, rowid):

        sql = "update analysis set status='ready' where id=? "
        self.c.execute(sql, (rowid,))
        self.conn.commit()

        #-----------------------------------------------------------------
    def mark_not_ready(self, rowid):

        sql = "update analysis set status='not_ready' where id=? "
        self.c.execute(sql, (rowid,))
        self.conn.commit()

        #-----------------------------------------------------------------
    def mark_error(self, rowid):

        sql = "update analysis set status='error' where id=? "
        self.c.execute(sql, (rowid,))
        self.conn.commit()

        #-----------------------------------------------------------------
    def get_id(self, data):

        sql = "select id from sample_info where manifold=? and port=? and serial_num=? and sample_type=?"
        self.c.execute(sql, data)
        row = self.c.fetchone()

        return row[0]

        #-----------------------------------------------------------------
    def get_next(self, sample_type=None, asDict=False):
        """ Get information about the next sample to analyze.
        Returns a tuple of the information or optionally if asDict is True, a dict, 
        or returns None if nothing is left to do.

        If sample_type is set, then also check that the next sample is of the requested type.

        Return a tuple with (sample data, ready flag).  The ready flag is True if data is
        marked as 'ready', and False if not marked as 'ready'.

        NOTE: will still need to modify this to take into account samples that are skipped due
        to errors, with possible status 'error'.

        if asDict is true, the dict contains:
            "manifold"    : A (A, B, or C)
            "port_num"    : 1 (1,3,5,7 ...)
            "serial_num"  : flask id for flasks, tank serial number for cal and nl, pfp package id for pfp
            "sample_type" : 'flask' or 'pfp' or 'cal' or 'nl'
            "sample_num"  : 1 for flask, sample number for others
            "sample_id"   : flaskid for flask and pfp, serial_number for cal, std id for nl (S1, S2 ...) 
            "event_num"   : event number for flask and pfp, 0 for nl and cal
            "analysis_id" : id number from analysis table for this sample
            "pressure"    : pressure for cal, '' for others
            "regulator"   : regulator name for cal, '' for others

        if asDict is False, the tuple contains:
            (manifold, port, serial_num, sample_type, sample_num, sample_id, event_num, analysis_id, pressure, regulator)
        """

        # key names must be in same order as fields in sql select statement below
        keys = ["manifold", "port_num", "serial_num", "sample_type", "sample_num", "sample_id", "event_num", 
            "analysis_id", "pressure", "regulator", "sample_id_num"]

        # get the first entry after the last one marked 'complete' and has status 'ready'.
        #sql = "select manifold,port,sample_info.serial_num,sample_type,sample_num,flask_id,event_num,analysis.id,pressure,regulator from sample_info, analysis "
        sql = "select manifold,port,sample_info.serial_num,sample_type,sample_num,flask_id,event_num,analysis.id,pressure,regulator,sample_info.id from sample_info, analysis "
        sql += "where sample_info.id=analysis.sample_id "
        sql += "and status='ready' "
        sql += "order by sample_info.id, analysis.id limit 1"
#       sql += "order by analysis.id  limit 1"
        self.c.execute(sql)
        row = self.c.fetchone()


        # originally checked for not-ready samples (flasks that have not been evacuated and opened)
        # so that we could prompt user.  For now we're just letting the system stop if there are no
        # ready flasks so don't want to return not_ready info.  Problem is in common.prep_system. Don't 
        # want that code evacuating back to a manifold with 'not_ready' flasks on it since it is probably
        # in use with the prep_flask_manifold.py procedure. Rather than handle the case of waiting for 
        # that to finish we'll just stop and have the user restart.  

        if row is None:
            # for now if no ready samples found, just return none
            return None, False

#original code looked for 'not_ready' samples with the below lines
#           # if no sample data found, check if there are entries marked 'not_ready'
#           sql = "select manifold,port,sample_info.serial_num,sample_type,sample_num,flask_id,event_num,analysis.id,pressure,regulator from sample_info, analysis "
#           sql += "where sample_info.id=analysis.sample_id "
#           #sql += "and status!='complete' and status!='ready' "
#           sql += "and status='not_ready' "
#           sql += "order by sample_info.id, analysis.sample_num limit 1"
#           self.c.execute(sql)
#           row = self.c.fetchone()
#
#           # if still nothing, return none
#           if row is None:
#               return None, False
#           else:
#               # double check that sample type is what was requested
#               if sample_type is not None:
#                   stype = row[3]
#                   if stype.lower() != sample_type.lower():
#                       return None, False
#
#               if asDict == True:
#                   d = {}
#                   for n, key in enumerate(keys):
#                       d[key] = row[n]
#                   return d, False
#
#               else:
#                   return row, False
#
#
        # ready data was found, double check that the sample type is what was requested
        else:

            if sample_type is not None:
                stype = row[3]
                if stype.lower() != sample_type.lower():
                    return None, False

            if asDict == True:
                d = {}
                for n, key in enumerate(keys):
                    d[key] = row[n]
                return d, True
            else:
                return row, True


        #-----------------------------------------------------------------
    def get_next_manifold(self):
        """ Get information about the next manifold to analyze.
        Returns a tuple of (manifold, sample_type),
        or returns None if nothing is left to do.
        """

        sql = "select manifold,sample_type from sample_info, analysis "
        sql += "where sample_info.id=analysis.sample_id "
        sql += "and status='ready' "
#       sql += "order by sample_info.id, analysis.sample_num limit 1"
        sql += "order by sample_info.id, analysis.id limit 1"
        self.c.execute(sql)
        row = self.c.fetchone()

        return row

        #-----------------------------------------------------------------
    def get_column_names(self, table):

        self.c.execute("select * from %s" % table)
        colnames = [colinfo[0] for colinfo in self.c.description]

        return colnames

        #-----------------------------------------------------------------
    def get_all(self):

        self.c.execute("select * from sample_info order by id")
        rows = self.c.fetchall()

        return rows

        #-----------------------------------------------------------------
    def create_schema(self):
        """ The 'id' number in the sample_info table is used as the
        'sample_id' number in the analysis table to join them together.
        """

        schema = """ 
        create table analysis (
            id            integer primary key autoincrement not null,
            sample_id     integer,
            sample_num    integer,
            flask_id      text,
            event_num     integer,
            status        text default '',
            adate         text default '',
            req_num       integer
        ); 

        create table sample_info (
            id            integer primary key autoincrement not null,
            manifold      text,
            port          integer,
            serial_num    text,
            sample_type   text,
            num_samples   integer,
            pressure      integer,
            regulator     text
        );

        """

        self.conn.executescript(schema)

        #-----------------------------------------------------------------
    def close(self):

        self.conn.close()

        #-----------------------------------------------------------------
    def clear(self):
        """ Remove all entries from the tables, and reset the autoincrement number """

        sql = "delete from analysis"
        self.c.execute(sql)

        sql = "delete from sample_info"
        self.c.execute(sql)

        sql = "UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = 'analysis'"
        self.c.execute(sql)

        sql = "UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = 'sample_info'"
        self.c.execute(sql)

        self.conn.commit()

        #-----------------------------------------------------------------
    def get_analysis_info(self):
        """ Get analysis info that will be shown on the control panel details page. """

        data = []

        rows = self.get_all()
        for row in rows:
            (rowid, manifold, port, serial_num, sample_type, num_samples, pressure, regulator) = row
            #sql = "select sample_num, flask_id, event_num, status, adate from analysis where sample_id=? order by sample_id, sample_num"
            # include id from analysis table 
            sql = "select id, sample_num, flask_id, event_num, status, adate from analysis where sample_id=? order by sample_id, id"
            self.c.execute(sql, (rowid,))
            results = self.c.fetchall()
            for result in results:
                (analysis_id, sample_num, flask_id, event_num, status, adate) = result
                t = (analysis_id, rowid, manifold, port, serial_num, sample_type, num_samples, pressure, regulator,
                    sample_num, flask_id, event_num, status, adate)
                #output = analysis_id, rowid, manifold, port, serial_num, sample_type, 
                #   num_samples, pressure, regulator, sample_num, flask_id, event_num, status, adate 
                #t = row + result
                data.append(t)

        return data
