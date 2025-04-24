#!/usr/bin/env python

# code to upload the gravimetric standards values to the new DB tables
#
# changes Dec 2021 - use python3, do more extensive tests to prevent mismatches in parameter name / numbers. AMC
# updated Dec 2022 - verified that works with new names for some compounds. AMC
#  
# 

import sys
sys.path.append("/ccg/src/python3/lib/")
import os
import argparse
import textwrap
#import MySQLdb
import datetime
import inspect
import copy
import re

import ccg_utils

#import dbutils
import ccg_db

now = datetime.datetime.now()
UPDATE = False
TEST = False
MODDATE = now.strftime("%Y-%m-%d %H:%M:%S")
debug = False
REPLACE = False


parser = argparse.ArgumentParser(prog='update_grav_DB_tables.py', 
    formatter_class=argparse.RawDescriptionHelpFormatter, 
    description = textwrap.dedent('''\

Code for updating DB tables for new gravimetric standards OR for updating the 
    value assignments for existing gravimetric standards.

This code will insert a new record in the fill table if a record of the filling 
    is not already there. Subsequent runs of this code will NOT change the fill 
    table. To change information in the fill table see DB administrator.

This code will insert a new record in the grav_stds table if the standard is not 
    already in the table. Subsequent runs of this code will NOT change the 
    information in the grav_stds table. To change information in grav_stds see
    the DB administrator.

This code will add a new record with a new modification date to the grav_value
    table each time it is run with the update option. This preserves the history
    of the value assignements. The latest modification date is assumed to be 
    the correct value.   

FORMATS FOR REQUIRED TEXT FILES:
    Use ';' separator 
    All fields required so use NA for missing text values, -999 or 0 for missing
         numerical values. 
    Lines beginning with '#' indicate comment line and will be skipped
    Dates should be YYYY/MM/DD or YYYY-MM-DD
    Species names must match DB table gml.parameter field 'formula'.
        (viewable at https://omi.cmdl.noaa.gov/lookups/ under column 'Parameter')
    Values and unc are in mole/mole. Conversion to normal atmospheric units 
        available on data extraction.


    INFO_FILE - one line per standard
        Format:  #Serial_num;Project;Type;Creator;Date;fill_code;NoteBook;Page;Parent;MW;O2 content;ProductionNotes
        Example: AAL072081;COS;grav;Hall;2021/11/09;B;16;68;FF57627;28.8569;21.100;Airgas UHP zero, no scrubbers, with CO2
                 CC736506;COS;grav;Hall;2021/11/09;B;16;68;FF57627;28.8579;21.100;Airgas UHP zero, no scrubbers, with CO2

    VALUES_FILE - one line for each species in each standard. Serial numbers and dates must match those in info file.
        Format:   #Serial_num;Date;Species;Value;Flag;Uncertainty;2nd_Uncertainty;comment
        Example:  AAL072081;2021/11/09;OCS;3.9700E-10;.;1.310E-12;3.800E-13;source Synquest 00015578
                  AAL072081;2021/11/09;F11;1.2940E-10;.;1.000E-13;0.000E+00;N/A;
                  AAL072081;2021/11/09;co2;3.9100E-04;.;3.500E-13;0.000E+00;N/A
                  CC736506;2021/11/09;OCS;3.0130E-10;.;1.020E-12;3.800E-13;source Synquest 00015578;
                  CC736506;2021/11/09;F11;5.0600E-11;.;1.000E-13;0.000E+00;N/A;
                  CC736506;2021/11/09;co2;3.8440E-04;.;3.500E-07;0.000E+00;N/A;
    '''))


group = parser.add_argument_group("Options")
group.add_argument('--info_file', type=str, help="The info file containing information on each standard. Required.", required=True)
group.add_argument('--value_file', type=str, help="The value file containing mole fractions for each compound in each standard. Required.", required=True)
group.add_argument('--moddate', help="Use a different modification date rather than the default current date/time. Enter as YYYY-MM-DD [00:00:00]")
group.add_argument('-u','--update', action="store_true", default=False, help="Run in update mode, write data to DB")
group.add_argument('-d','--debug', action="store_true", default=False, help="Debug mode, prints extra information")

options = parser.parse_args()

if not options.info_file and options.value_file:
    msg = "Info file and value file required. exiting..."
    sys.exit(msg)

if options.moddate:
    MODDATE = re.sub('[\[\]]','',options.moddate)
if options.update:
    UPDATE = True
if options.debug:
    debug = True

verbose = 0

# connect to DB
filltable = "fill"
infotable = "grav_stds"
valuetable = "grav_values"
#filltable = "test_fill"          # use for testing
#infotable = "test_grav_stds"     # use for testing
#valuetable = "test_grav_values"  # use for testing



# Read the info file
msg = "\nReading the info file %s\n" % (options.info_file)
msg = msg + "\tTesting each line for\n"
msg = msg + "\t\t1) correctly formated date strings\n"
msg = msg + "\t\t2) check if DB already has fill table entry\n"
msg = msg + "\t\t3) check that fill code is not a duplicate and is next in line to be used"
print(msg)

try:
    f = open(options.info_file)
    info_lines = f.readlines()
    f.close()
except:
    msg = "Can't open file " % options.info_file
    sys.exit(msg)

# clean up and check info lines
all_dates = []
info = [] # list of all info lines

for line in info_lines:
    print("\n")
    tmp_dict = {}

    line = line.lstrip()
    if line.startswith("#"): continue

    line = line.rstrip('\r\n')
    line = line.rstrip(';')
    line = line.replace('"','')
    line = line.replace("'",'')
    (sn, project, typ, prepared_by, date, fc, nb, pp, parent, mw, o2, notes) = line.split(';')
    date = date.replace('/','-')
    nb = nb.replace('N/A', 'NA')
    pp = pp.replace('N/A', 'NA')
    parent = parent.replace('N/A', 'NA')
    mw = mw.replace('N/A', 'NA')
    o2 = o2.replace('N/A', 'NA')
    notes = notes.replace('N/A', 'NA')

    print("%s   %s  %s" % (sn, date, fc))
    #print("date: %s" % (date))

    try: 
        dt = datetime.datetime.strptime(date, '%Y-%m-%d')
    except: 
        msg = "\n\n**** Incorrect date format in the INFO file:\t%s" % (options.info_file)
        msg = msg + "\n\tline:\t%s\n" % (line)
        msg = msg + "\tdates should be YYYY-MM-DD or YYYY/MM/DD.\n*** NO UPLOADS SUBMITTED TO DB, exiting ..."
        print(msg)
        sys.exit()

    all_dates.append(dt)

    
    tmp_dict["serial_number"] = sn.upper()
    tmp_dict["project"] = project
    tmp_dict["typ"] = typ
    tmp_dict["prepared_by"] = prepared_by    
    tmp_dict["date"] = date    
    tmp_dict["dt"] = dt    
    tmp_dict["fillcode"] = fc.upper()    
    tmp_dict["notebook"] = nb     
    tmp_dict["pages"] = pp    
    tmp_dict["parent"] = parent    
    tmp_dict["mw"] = mw    
    tmp_dict["o2"] = o2     
    tmp_dict["notes"] = notes    

    # check fill code for each tank compared to history in the fill table. 
    # make sure it is not a duplicate and is next in line
    fill_index = -999
    msg_prefix = "Checking reftank.%s for existing record:  " % (filltable)
    query = "SELECT idx,code,date,location,method,notes from %s " % filltable
    query += "WHERE serial_number ='%s';" % sn
    rtn = ccg_db.dbQueryAndFetch(query, database='reftank', readonly=True, asDict=True, conn=None)

    if len(rtn) > 0: 
            c_list = []
            # loop through fill history see if fill already exists. If yes, save index for later 
            # This will be true for modifications of values
            for v in rtn:
                if v["code"].upper() == fc.upper() and v["date"].strftime("%Y-%m-%d") == dt.strftime("%Y-%m-%d"):
                    # indicates fill already exists, record index number for later use
                    fill_index = v["idx"]
                    msg = msg_prefix + "Fill entry already exists, will use fill %s" % (fc.upper())
                    print(msg)

            # if fill entry not found (indicated by fill_index still = -999) - check to make sure passed fc not a duplicate
            if fill_index < 0:
                msg = msg_prefix + "Fill entry not found, will add record to reftank.%s" % (filltable)
                print(msg)
                for v in  rtn:
                    msg_b = "Checking for duplicate fill code:  "
                    if v["code"].upper() == fc.upper():
                        msg_b = msg_b + "!!! Duplicate fill code %s passed in\n" % (fc)
                        msg_b = msg_b + " Please correct conflict. NO UPLOADS SUBMITTED TO DB, exiting ..."
                        sys.exit(msg_b)
                    msg_b = msg_b + "Fill code %s is not a duplicate" %(fc.upper())
 
                # check that passed fc is the next expected fillcode from DB history, ask user to verify if not
                for v in  rtn:
                    c_list.append(v["code"])

                next_fc = chr(ord(max(c_list))+1) 
                if fc.upper() != next_fc.upper():
                    msg = "\n\nPassed fill code for %s is NOT the next fc to be used based on fill history in DB" % (sn.upper())
                    msg = msg + "\n  Text file passed in %s" % (fc.upper)
                    msg = msg + "\n  DB expects %s as the next fill code." % (next_fc)
                    msg = msg + "\nUSER VERIFICATION: Ok to continue with fill %s? (yes/no)" % (fc.upper())
                    ans = input("%s\n>>>" % msg)
                    if ans.lower() != "yes" and ans.lower() != "y":
                        sys.exit("NO UPLOADS SUBMITTED TO DB, exiting...")
    else:

        msg = msg_prefix + "No record found, will add record to reftank.%s" % (filltable)
        print(msg)
        # if first filling, should use fill code A
        if fc.upper() != 'A':
            msg = "No fill history for %s, first fill_code should be A, but %s passed in." % (sn.upper(), fc.upper())
            msg = msg + "\nUSER VERIFICATION: Ok to continue with fill %s? (yes/no)" % (fc.upper())
            ans = input("%s\n>>>" % msg)
            if ans.lower() != "yes" and ans.lower() != "y":
                sys.exit("NO UPLOADS SUBMITTED TO DB, exiting...")

    # record fill index for later use (either real index or -999 if not found)        
    tmp_dict["fill_index"] = fill_index


    # add a check to get std_index value from grav_stds - if not present set to -999 and update later on.
    # this will make it easier to modify values vs initial upload
    # can probably make this query only on fill_num 
    msg_prefix = "Checking reftank.%s for existing record: " % (infotable)
    grav_stds_index = -999
    query = "SELECT id from %s " % infotable
    query += "WHERE serial_number ='%s' and date = '%s' and fill_num = %s;" % (sn, date, tmp_dict["fill_index"])
    rtn = ccg_db.dbQueryAndFetch(query, database='reftank', readonly=True, asDict=True, conn=None)

    if len(rtn) == 1: 
        #if one record found, we'll update values only
        grav_stds_index = rtn[0]["id"]
        msg = msg_prefix + " found 1 record, will update grav values table only"
        print(msg)
    elif len(rtn) == 0:
        #if no record found, we'll add later
        msg = msg_prefix + " found 0 record, will update grav info and grav values tables"
        print(msg)
        pass
    else:
        # if multiple records, found there is a problem so exit and figure it out
        msg = msg_prefix + "!!!found multiple records, check DB tables for potential duplicates"
        msg = msg + "\nNO UPLOADS SUBMITTED TO DB, exiting..." 
        sys.exit(msg)
        
    tmp_dict["grav_std_index"] = grav_stds_index

    info.append(tmp_dict)

msg = "info file passed checks"
print(msg) 
    



# Read the value file
msg = "\nReading the value file %s.\n" % (options.value_file)
msg = msg + "\tTesting each line for\n"
msg = msg + "\t\t1) correctly formated date strings\n"
msg = msg + "\t\t2) parameter_num in omi lookup table matching passed sp_name\n"
msg = msg + "\t\t3) exactly one matching entry in the info file for each value line\n" 
print(msg)

try:
    f = open(options.value_file)
    value_lines = f.readlines()
    f.close()
except:
    msg = "Can't open file " % options.value_file
    sys.exit(msg)

# clean up and check value lines
values = [] # list of all value dictionaries

for line in value_lines:
    tmp_dict = {}

    line = line.lstrip()
    if line.startswith("#"): continue
    line = line.rstrip('\r\n')
    line = line.rstrip(';')
    line.replace('"','')
    line.replace("'",'')
    (sn, date, sp_name, value, flg, unc, unc2, notes) = line.split(';')
    date = date.replace('/','-')
    notes = notes.replace('N/A', 'NA')

    try: 
        dt = datetime.datetime.strptime(date, '%Y-%m-%d')
    except:
        msg = "\n\n**** Incorrect date format in the VALUE file:\t%s" % (options.value_file)
        msg = msg + "\n\tline:\t%s\n" % (line)
        msg = msg + "\tDates should be YYYY-MM-DD or YYYY/MM/DD.\n*** NO UPLOADS SUBMITTED TO DB, exiting ..."
        print(msg)
        sys.exit()
        
    all_dates.append(dt)

    tmp_dict["serial_number"] = sn.upper()
    tmp_dict["date"] = date 
    tmp_dict["dt"] = dt 
    tmp_dict["sp_name"] = sp_name
    tmp_dict["value"] = float(value) 
    tmp_dict["flag"] = flg  
    tmp_dict["unc"] = float(unc) 
    tmp_dict["unc2"] = float(unc2)  
    tmp_dict["notes"] = notes  

    # Get the parameter number for the species we are using. 
    # Don't allow processig if name doesn't match parameter names in DB
    sp_num = ccg_db.getGasNum(sp_name)
    if sp_num < 0: 
        msg = "**** PARAMETER_NUM NOT FOUND FOR %s, check species name for typos or see J. Mund to add new species. NO UPLOADS SUBMITTED TO DB, exiting ..." % (sp_name)
        sys.exit(msg)
    else:
        msg = "Parameter number (%s) found for %s" % (sp_num, sp_name)
        if debug:  print(msg)

    tmp_dict["sp_num"] = sp_num

    #Verify there is a match in the info table for each value.  
    # Each value line should be associated with exactly one info line - exit if 0 or multiple matches
    check = 0
    for i, dic in enumerate(info):
        if dic["serial_number"].upper() ==  sn.upper() and dic["dt"] == dt:
            check += 1

    if check > 1:
        msg = "\n***** Multiple matches in info table found for %s %s %s. NO UPLOADS SUBMITTED TO DB, exiting ..." % (sn.upper(), date, sp_name)
        sys.exit(msg) 
    elif check == 0:
        msg = "\n***** No match found in info table for %s %s %s. NO UPLOADS SUBMITTED TO DB, exiting ..." % (sn.upper(), date, sp_name)
        sys.exit(msg) 
    else:
        msg = "Match found for %s %s %s" % (sn.upper(), date, sp_name)
        if debug:  print(msg)
        pass

    values.append(tmp_dict)



############  START DATA CHECKS TO MAKE SURE INFO PASSED IN IS OK
# check  - date strings - Done during file read above
# check  - verify that each species has an associated parameter_number in the parameters DB table - DONE DURING FILE READ STEP ABOVE
# check  - verify that all "values" lines have an associated "info" line - DONE DURING THE FILE READ STEP ABOVE

# check  - verify that all "info" lines have at least one "value" line - verify this is correct before uploading "empty" grav
msg = "\nVerifing that all info lines have at least one value assigned\n"
print(msg)

msg = "\tSummary of the upload files:"
print(msg)
for i, info_dict in enumerate(info):
    check = 0
    sp_list = [] 
    for values_dic in values:
        if values_dic["serial_number"].upper() == info_dict["serial_number"].upper() and values_dic["dt"] == info_dict["dt"]:
            check +=1
            sp_list.append(values_dic["sp_name"])

    #check
    if check == 0:
            msg = "\n\nGrav std %s (filled %s) has NO SPECIES VALUE ASSOCIATED WITH IT, OK TO CONTINUE? (yes/no).\n" % (info_dict["serial_number"], info_dict["date"])
            ans = input("%s\n>>>" % msg)
            if ans.lower() != "yes" and ans.lower() != "y":
                sys.exit("NO UPLOADS SUBMITTED TO DB, exiting...")

    msg = "%s:\t(filled %s)\t has %d species associated with it. (" % (info_dict["serial_number"], info_dict["date"], check)
    for s in sp_list:
        msg = msg + ("  %s" % s)
    msg = msg + ")" 
    print(msg)

# ask user to verify
msg = "\n\nUSER VERIFICATION:  Does this summary information look correct? (yes/no)"
ans = input("%s\n>>>" % msg)
if ans.lower() != "yes" and ans.lower() != "y":
        sys.exit("NO UPLOADS SUBMITTED TO DB, exiting...")




# check  - verify that the date range makes sense to the user
min_dt = min(all_dates)
max_dt = max(all_dates)
msg = "\n\nChecking date range:\nDATE RANGE listed for all entries in both files:  %s to %s." % (min_dt.strftime("%Y-%m-%d"), max_dt.strftime("%Y-%m-%d"))
print(msg)
msg = "USER VERIFICATION: Is this DATE RANGE correct? (yes/no)" 
ans = input("%s\n>>>" % msg)
if ans.lower() != "yes" and ans.lower() != "y":
    msg = "Date range does NOT look correct, NO UPLOADS SUBMITTED TO DB. exiting ..."
    sys.exit(msg) 


if UPDATE:
    msg = "\n\n************** SUMMARY OF DB ACTIONS TAKEN"
else:
    msg = "\n\n************** SUMMARY OF PLANNED DB ACTIONS"
print(msg)


##########################################################
# ADD NEW ENTRIES IN FILL TABLES WHERE NEEDED
msg = "\nAdding new entries into fill table (where needed).\n"
print(msg)

for i, info_dict in enumerate(info):

    if info_dict["fill_index"] < -1:

        msg = "Inserting new fill record into reftank.%s:\t%s\t%s\t%s" % (filltable, 
                info_dict["serial_number"], info_dict["fillcode"], info_dict["date"])
        print(msg)
        # insert in to fill table
        query = "INSERT INTO %s SET " % filltable
        query += "serial_number = '%s'" % info_dict["serial_number"]
        query += ", date = '%s'" % info_dict["date"]
        query += ", code = '%s'" % info_dict["fillcode"]
        query += ", location = 'BLD'"
        query += ", method = 'Gravimetric'"
        query += ", type = ''"
        query += ", h2o = ''"
        query += ", notes = '%s';" % (info_dict["project"])
        
        #if update then add missing fill information
        if UPDATE:
            ccg_db.dbExecute(query, database="reftank")

            # return new fill index number from fill table
            query = "SELECT idx from %s " % filltable
            query += "WHERE serial_number ='%s'" % info_dict["serial_number"]
            query += "AND date = '%s';" % info_dict["date"]
            rtn = ccg_db.dbQueryAndFetch(query, database='reftank',asDict=True)
            if len(rtn) > 0: 
                info[i]["fill_index"] = rtn[0]["idx"]
            else:
                msg = "Could not get fill index after adding new record. Some uploads may have occurred. "
                msg = msg + "Potential for DB problems. See J. Mund for help"
                sys.exit(msg)
        else:
            print("QUERY: %s" % query)

    else:
        msg = "%s:\trecord for %s filling already exists in reftank.%s." % (info_dict["serial_number"], info_dict["date"], filltable)
        msg = msg + "\tNo update required"
        print(msg)




# loop through each entry in the info table, add entries to grav_std and grav_values tables.
msg = "\n\nAdding information to grav_std (where needed) and grav_info tables"
print(msg)

for info_dict in info:
    print("\n%s   %s   %s" % (info_dict["serial_number"], info_dict["date"], info_dict["fillcode"]))
    # final check
    if UPDATE and info_dict["fill_index"] < 0:
        msg = "problem with %s. Exiting afer potentially partial upload so possible DB problems" % (info_dict["serial_number"])        
        sys.exit(msg)

    # check to see if already in grav_std, do not put in duplicate entry
    if info_dict["grav_std_index"] < 0:
        msg = "---\tAdding record to reftank.%s." % (infotable)
        print(msg)

        # Insert info into grav_stds table if not already there
        query = "INSERT INTO %s SET " % infotable
        query += " fill_num = '%s'" % info_dict["fill_index"]
        query += ", serial_number = '%s'" % info_dict["serial_number"]
        query += ", date = '%s'" % info_dict["date"]
        query += ", project = '%s'" % info_dict["project"]
        query += ", notebook = '%s'" % info_dict["notebook"]
        query += ", pages = '%s'" % info_dict["pages"]
        query += ", prepared_by = '%s'" % info_dict["prepared_by"]
        query += ", parent = '%s'" % info_dict["parent"]
        query += ", o2_content = '%s'" % info_dict["o2"]
        query += ", calc_mw = '%s'" % info_dict["mw"]
        query += ", notes = '%s';" % info_dict["notes"]
        
        # add entry in grav_info db table 
        if UPDATE: 
            ccg_db.dbExecute(query, database='reftank')
        else:
            print(query)
                    
        # return grav_std index number to use in the grav_value table
        query = "SELECT id FROM %s " % (infotable)
        query += " WHERE serial_number='%s' " % (info_dict["serial_number"])
        query += " AND date='%s';" % (info_dict["date"])
        if UPDATE:
            rtn = ccg_db.dbQueryAndFetch(query, database='reftank',asDict=True)
            if len(rtn) > 0: 
                info_dict["grav_std_index"] = rtn[0]["id"]
            else:
                msg = "Could not get std index from grav_stds after adding new record."
                msg = msg + " Some uploads may have occurred so potential for DB problems. Exiting ..."
                sys.exit(msg)
        else:
            info_dict["grav_std_index"] = "-999"

    else:
        msg = "---\tRecord already exists in reftank.%s. No update required" % (infotable)
        print(msg)
        
    #if info_dict["grav_std_index"] < 0:
    # add values for current tank
    for value_dict in values:
                
        # if not correct sn and date then skip
        if value_dict["serial_number"].upper() != info_dict["serial_number"]: continue
        if value_dict["date"] != info_dict["date"]: continue

        msg = "---\tAdding record for %s to reftank.%s." % (value_dict["sp_name"], valuetable)
        print(msg)
                
        query = "INSERT INTO %s SET " % valuetable
        query += "std_idx = '%s'" % info_dict["grav_std_index"]
        query += ", species = '%s'" % value_dict["sp_name"]
        query += ", species_num = '%s'" % value_dict["sp_num"]
        query += ", value = '%s'" % value_dict["value"]
        query += ", unc = '%s'" % value_dict["unc"]
        query += ", partial_unc = '%s'" % value_dict["unc2"]
        query += ", flag = '%s'" % value_dict["flag"]
        query += ", mod_date = '%s'" % MODDATE
        query += ", comments = '%s';" % value_dict["notes"]
    
        if UPDATE: 
            if info_dict["grav_std_index"] > 0:
                ccg_db.dbExecute(query, database='reftank')
            else:
                msg = "no index from grav_stds table could not process %s" % query
                msg = msg + "\n Some data may have uploaded so potential for DB problems"
                sys.exit(msg) 
        else:
            print("%s" % query)
                
                
                
    


