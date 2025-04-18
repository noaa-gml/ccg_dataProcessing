#!/bin/env python
"""CCG Utilities for CSV files
"""
#import pandas as pd
from pandas import DataFrame,concat,read_csv 
from pandas import __version__ as pd_version
from os.path import isfile 
from numpy import nan

# Read and concatenate CSV files that may have differing
# number of colums.  Reads each csv file to get the header
# and then uses pd.read_csv to read the columns for that 
# file.  Concatenates the data frames, filling with np.nan
def readcsv_bycol(file_glob,usemod_ifexist=False,prtmsgs=True,num_skip=0,delim=','):

    """Read and concatenate a list of CSV files specified by a file glob 
       that may have differing numbers of columns.  Reads each CSV file 
       to get the header and then uses pandas read_csv to read the columns 
       for that file. Concatenates the dataframes and fills any missing 
       column with np.nan.  You may specifiy the delimeter and a number
       of lines to skip at the top of each file that contain meta data
       (before the header line).
    
    Args:
        file_glob     (str): file glob of files to load (e.g. glob.glob("*.dat")
        usemod_ifexist (bool): If True, read .mod file if it exists instad of the normal (e.g. .dat) file.  (Default = False)
        prtmsgs        (bool): If True, print messages while reading files (Default = True)
        num_skip       (int): number of rows of meta data to skip at top of file before the CSV header (Default = 0)
        delim          (str): column delimeter (Default=',')

    Returns:
        pandas.core.frame.DataFrame: dataframe containing all data/all columns for all files matching the file_glob

    Example::

        # Suppose data0.csv, data1.csv, data1.csv.mod, data2.csv exist
        # in the current directory.  From ipython:

        In [01]: import ccg_csv_utils as ccu
        In [02]: import glob
        In [03]: fl=glob.glob('*.csv')
        In [04]: df=ccu.readcsv_bycol(fl,usemod_ifexist=True,prtmsgs=True,num_skip=1)

        # Creates a single dataframe (df) that contains the data from 
        # all files ending in csv in the current directory. The files in
        # this case would each have 1 meta data line before the csv header
        # (therefore num_skip=1).
        # Also since data1.csv.mod exists, and the usemod_ifexist
        # parameter was set to True, data1.csv.mod is read instead of 
        # data1.csv
       
    """

    # Create empty data (primary) data frame to put concatenated
    # data frames into
    df=DataFrame()
    list_=[]

    # Loop through all files in the file_glob
    for file in file_glob:
        # Let the user know what file is processing
        if prtmsgs:
            print('Reading: {}'.format(file))

        # Create temp data frame for the current file being read
        dfs=DataFrame()

        #### towers_read.py already takes care of this step.
        # Read .mod file over .dat file if .mod file exists
        if usemod_ifexist:
            if isfile(file+'.mod'):
                file=file+'.mod'
                print("\t{} has .mod file, reading .mod file".format(file))
                #prYellow("\t{} has .mod file, reading .mod file".format(file))

        # Open each file and read the header
        with open(file) as fp:
            if not num_skip == 0:
                for i in range(num_skip):
                    # read but don't parse rows to be skipped.
                    x=fp.readline()
            # The line after the skipped rows should contain a csv
            # list of variables
            hdr=fp.readline().split(delim)
            hdr=[i.replace('"','') for i in hdr]
            hdr=[i.replace('\'','') for i in hdr]
            hdr=[i.replace(' ','_') for i in hdr]
            hdr=[i.replace('\n','') for i in hdr]
            hdr=[i.replace('\r','') for i in hdr]
 
            # basic check for headers... 
            # All column headers should start with a letter(aka alpha) 
            valid_header=True
            for i in hdr:
                if i[0].isalpha():
                    continue
                else:
                    if prtmsgs:
                        print("ERROR: metadata line not found for {}".format(file))
                        print("WARNING: {} not loaded".format(file))
                    valid_header=False

            # skip loading file if headers aren't valid 
            if not valid_header:
                continue
            # else grab the first line of data for length comparison
            else:
                d=fp.readline().split(delim)

            # Check if number of header and data columns match, else skip file
            if len(d) == len(hdr):
                # sort the header for good measure
                current_header=sorted(hdr)
            
                # Read the current file in to temporary dataframe
                dfs=read_csv(file,usecols=current_header,skiprows=num_skip,header=0)
            else:
                if prtmsgs:
                    print("ERROR: number of header and data columns don't match")
                    print("WARNING: {} not loaded".format(file))
                continue 
        
        # Concatenate the primary df with the temporary df and
        # fill any empty column(s) with nan.
        #pandas_ver=int(pd.__version__.split('.')[1])
        pandas_ver=int(pd_version.split('.')[1])

        # 9/2021 PLH appending to list and concatenating in
        # single step provide performance enhancement vs 
        # concatenating each time
        list_.append(dfs)
        #if pandas_ver < 23:
        #    df=concat([df,dfs]).fillna(nan)
        #else:
        #    #df=concat([df,dfs],sort=False).fillna(nan)
        #    list_.append(dfs)

    
    # index from each dfs above ranges from 0-119(30sec intevals over 1 hr)
    # for towers hourly files.
    # keep this index as 'orig_index', and create a new index from 0
    # to the number of records-1
    if pandas_ver < 23:
        df=concat(list_,sort=False).fillna(nan)
    else:
        df=concat([df,dfs],sort=False).fillna(nan)
    df['orig_index']=df.index
    df.reset_index(inplace=True,drop=True)

    # Return the (primary) concatenated dataframe
    return df
