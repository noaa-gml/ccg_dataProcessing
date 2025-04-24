#! /usr/bin/env python
"""
 code to batch re-assign  standards  - into cal_scale_tests DB or live DB when ready

    V02 - uses the update option of caldrift rather than writing to text file. This option only
        writed to 'reftank' so need to do testing in a test scale. Otherwise it goes live.

       Can be used as template for species specific runs rather than all command line calls
   
"""


import sys
import os
import argparse
import subprocess
import datetime




###########################################################
def build_std_list(fn=None):
    """ Build list of stds and processing options for each standard.

        ***** will move this to a file passed in so can create versions/ lists of tanks to process.
                Will need to find common format for text files that can be generated from DB tables
                and then edited manually. 

        

        dictionary format:
            process         (0=no,1=y)
            set,            Set of standards this tank belongs to. Information only, not used.
            sn, 
            fc, 
            fit,            specify mean, linea, quadratic. If None use auto fit
            fit_inst,       specify inst to fit (default None = --fit_official)
            fit_daterange,  specifiy specific date range to use for the fit
            comment,        notes to apply to comments field in scale_assignments
            code,           allows different code to be used. If None then use the default /ccg/bin/caldrift 


    """

    full_list = []

    if fn:

        try:
            f=open(fn,'r')
            lines = f.readlines()
            f.close()
        except:
            sys.exit("file %s could not be read, exiting ..." % (fn))
    else:
        sys.exit("no filename passed in, exiting ...")


    process_list = []
    for line in lines:
        tmp_data = {}

        line = line.lstrip()
        line = line.rstrip('\n')
        #print(line)
        if line.startswith("#"): continue

        ncomments = line.count('#')

        if ncomments == 2:
            (data, db_comment, notes) = line.split('#')
            db_comment = db_comment.lstrip()
            db_comment = db_comment.rstrip()
        elif ncomments == 1:
            (data, db_comment) = line.split('#')
            db_comment = db_comment.lstrip()
            db_comment = db_comment.rstrip()
            notes = "none"
        else:
            data = line
            db_comment = "none"
            notes = "none"

        process, sset, sn, fc, start_date, level, std_unc, fit, fit_inst, fit_option, fit_daterange, code = data.split()

        if int(process) > 0:
            #tmp_data[""] =  
            tmp_data["sn"] = sn 
            tmp_data["fillcode"] = fc
            tmp_data["start_date"] = start_date 
            tmp_data["level"] =  level
            tmp_data["std_unc"] = std_unc 

            if fit.lower() == "none": 
                tmp_data["fit"] = None
            else:
                tmp_data["fit"] = fit 

            if fit_option.lower() == "none":
                tmp_data["fit_option"] = None
            else:
                tmp_data["fit_option"] = fit_option

            if fit_inst.lower() == "none":
                tmp_data["fit_inst"] = None
            else:
                tmp_data["fit_inst"] = fit_inst

            if fit_daterange.lower() == "none":
                tmp_data["fit_daterange"] = None
            else:
                tmp_data["fit_daterange"] = fit_daterange 

            if db_comment.lower() == "none":
                tmp_data["comment"] = ""
            else:
                tmp_data["comment"] = db_comment 

            if code.lower() == "none":
                tmp_data["code"] = None
            else:
                tmp_data["code"] = code

            process_list.append(tmp_data)

    return process_list




###########################################################
# START MAIN CODE
#
parser = argparse.ArgumentParser(description="Re-assign CO2 secondary standards")

#        epilog="Only one of the output options should be given.  No options means print out a single result line to stdout.")

group = parser.add_argument_group("Data Selection Options")

#group.add_argument('--fillcode', type=str.upper, help="Specify fillcode. Default is None which causes code to return list and ask")
#group.add_argument('--inst', help="Specify inst codes to pull from database, default is all. For example --inst=L9,PC1 ")
group.add_argument('--species', default='co', help="species to process")
group.add_argument('--database', default="reftank", help="Select database to compare/update results. Default is 'reftank'.")
group.add_argument('--scale', default=None, help="Scale for value assignments")
group.add_argument('--check', action="store_true", default=False, help="Check  ")
group.add_argument('--update', action="store_true", default=False, help="Updates the REFTANK.scale_assignments table in database. BE VERY CAREFUL DURING TESTING TO SELECT THE CORRECT SCALE! ")
group.add_argument('--savefile', default=None, help="Text file to save the results to, default is tmp_value_assignment_results.txt in current directory.")


#group = parser.add_argument_group("Fitting Options for scale relationship")
#group.add_argument('--edit', action="store_true", default=False, help="Allow user to select/edit data offline prior to fit.")
#group.add_argument('--fit_differences', action="store_true", default=False, help="Fit differences rather than odr fit to values")
#group.add_argument('--fit_official', action="store_true", default=False, help="Use only official calibration instruments in the fit.  This is an alternative to --fit_inst ")
#group.add_argument('--auto_fit', action="store_true", default=False, help="Show results of auto significance testing of fits.")
#group.add_argument('--mean', action="store_true", default=False, help="Show weighted mean (default is False).")
#group.add_argument('--linear', action="store_true", default=False, help="Show linear fit (default is False).")
#group.add_argument('--quadratic', action="store_true", default=False, help="Show quadratic fit (default is False).")
#group.add_argument('--include_flag', default=".", help="Specify flags to include in fit (default is '.'). For example --include_flag=.,S,r")
#group.add_argument('--fit_range', default="-800,9999", help="Specify mole fraction range to include in fit (default is -9999 to +9999). For example --fit_range=350,450")
#group.add_argument('--use_sd', action="store_true", default=False, help="Use std dev of episode for weighting in fit. Ignores the scale transfer uncertainty term (Default is false). Helpful when including inst without a defined scale transfer unc.")
#group.add_argument('--use_external', action="store_true", default=False, help="Use external calibration data")

#group = parser.add_argument_group("Selection Options")
#group.add_argument('--meas_lab_num', default=None, help="Select by measurement lab number in addition to scale/species")
#group.add_argument('--fit_inst', default=None, help="Base NOAA value on fitting one analyzer. --fit_inst=pc1")
#group.add_argument('--scale', help="Scale to use for reprocessing (default is current). For example --scale=CO_X2004")
#group.add_argument('-w', '--refgasfile', help="Choose a text reference gas file instead of database for assigned values.")
#group.add_argument('-r', '--respfile', help="Select a non-standard response file for reprocessing.")
#group.add_argument('-p', '--peaktype', choices=['area', 'height'], help="Use 'peaktype' instead of default.  'peaktype' must be either 'area' or 'height'")
#group.add_argument('--program', help="Path to non-standard version of calpro for reprocessing. For example --program=/home/ccg/.../.../test_version_calpro.py")
#group.add_argument('--extra_option', help="List of options to pass to calpro.py for reprocessing, separated by commas. For example --c13=*,--018=*,etc")

group = parser.add_argument_group("Output Options")
group.add_argument('--plot', action="store_true", default=False, help="Shows plot of each standard as processed. Default is False.")
group.add_argument('--plot_assigned', action="store_true", default=False, help="Shows current value assignments on plots. Default is False.")

#group.add_argument('--plot_differences', action="store_true", default=False, help="Plot external_scale minus NOAA differences as functio of external scale. Default is False")
#group.add_argument('--plot_residuals', action="store_true", default=False, help="Plot residuals from fit. Default is False")
#group.add_argument('--plot_unc', action="store_true", default=False, help="Plot uncertainty of scale conversion. Default is False")
#group.add_argument('--plot_curve_differences', action="store_true", default=False, help="Plot date range curve differences, requires two date ranges and only one fit type. Default is False")
#group.add_argument('--hide_residual_unc', action="store_true", default=False, help="Supress error bars in residuals plot. Default is False")
#group.add_argument('--plot_flag', default="Q", help="Flag to include in plots but not in the fit (default is Q for stds outside fit_range). For example --plot_flag=Q,S")
group.add_argument('--save_results', action="store_true", default=False, help="Save fit results to tempfile (default is False)")
group.add_argument('--save_json', action="store_true", default=False, help="Save data and results to json file (default is False)")
group.add_argument('--json_dir', help="dir for json file (default is current directory)")
#group.add_argument('--fit_debug', action="store_true", default=False, help="Used to print debugging information on statistical testing used in auto fit routine (default is False)")
#group.add_argument('--no_legend', action="store_true", default=False, help="Set to remove legend from plot")
#group.add_argument('--date_extension', default=0.2, help="Decimal years to extend plot past last calibration result (default is 0.2). For example --date_extension=1.5")
#group.add_argument('--min_date', default=None, help="Minimum date for plotting (default is cylinder fill date). For example --min_date=2020-01-01")
#group.add_argument('--info', action="store_true", default=False, help="Print out input data and residuals.")
#group.add_argument('--vertical_mark', default=None, help="Place vertical mark on plots - NOT YET")
#group.add_argument('-u', '--update', action="store_true", default=False, help="Save fit parameters in scale assignment database table. Only one fit type can be used.")
group.add_argument('-v', '--verbose', action="store_true", default=False, help="Print out extra information.")
group.add_argument('-d', '--debug', action="store_true", default=False, help="Print out extra debugging information.")

parser.add_argument('args', nargs='*')
options = parser.parse_args()





inputfiles = options.args



###############  SETUP REPROCESSING 
if not options.species:
    sys.exit("Species keyword required, exiting ...")
species = options.species

#set Database
if options.database:
    database = options.database
else:
    sys.exit("Database option required, exiting ...")

# set dir for json files
if options.json_dir:
    json_dir = options.json_dir
else:
    json_dir = "./"

# set Scale
#scale_option=" --scale=CO2_Test"
if options.scale: 
    scale = options.scale
else:
    scale = ""

if options.save_results:
    if options.savefile:
        savefile=options.savefile
    else:
        savefile="tempfile_value_assignment_results.txt"
    #clear the save file
    f_save=open(savefile,'w')
    f_save.close()
    


# if update option, check to make sure this was intended
UPDATE = False
if options.update:
    print("\n\n\n", file=sys.stderr)
    msg = "********* THE UPDATE OPTION IS SET"
    msg += "\n    Code will write to the live DB (REFTANK.SCALE_ASSIGNMENTS) as scale=%s" % (scale.upper())
    msg += "\nConfirm you want to do this (Yes/No)"
    ans = input("%s\n>>>" % msg)

    if ans.lower() != "yes":
        sys.exit("ans was %s, no uploads submitted to DB, exiting..." % ans) 
    UPDATE = True




fit_results = []
output = []


#loop through passed files
for inputfilename in inputfiles:

    # get list of stds to assign
    process_list = build_std_list(inputfilename)


    for std in process_list:
        tmp_fit_result={}
        #list.append({process, set, sn, fc, fit, fit_daterange,comment, code})

        #print("processing %s (fill %s) " % (std["sn"], std["fillcode"]), file=sys.stderr)
        if std["code"]:
            cmd = "python %s " % std["code"]
        else:
            cmd = "/ccg/bin/caldrift "

        if UPDATE:
            cmd += " --update"

        cmd += " --fillcode=%s" % std["fillcode"]
        cmd += " --database=%s" % database
        cmd += " --scale=%s" % scale

        if std["fit_inst"]:
            if std["fit_inst"].lower() == "official":
                cmd += " --official"
            else:
                cmd += " --fit_inst=%s" % std["fit_inst"]

        if std["fit"]:
            cmd += " --noauto_fit --%s" % std["fit"]

        if std["fit_daterange"]:
            cmd += " --fit_daterange=%s" % std["fit_daterange"]

        if std["fit_option"]:
            for opt in std["fit_option"].split(';'):
                cmd += " %s" % opt
        
        cmd += " --level=%s" % std["level"]    

        if std["comment"]:
            cmd += " --comment='%s'" % (std["comment"])

        if options.save_json:
            #cmd2 is without plotting so can save json. Pipe to json file
            json_file = "%s/%s_%s_%s.json" % (json_dir, std["sn"].lower(), std["fillcode"].lower(), species.lower())
            cmd2 = "%s  --json %s %s > %s" % (cmd, species, std["sn"], json_file)

        if options.plot:
            cmd += " --plot --plot_residuals --plot_uncertainty"
            if options.plot_assigned:    # DOESN'T WORK, CALDRIFT HARDCODED TO READ REFTANK.SCALE_ASSIGNMENTS - will need to fix later
                cmd += " --plot_assigned"

        cmd += " %s  %s" % (species, std["sn"])
        print("**** cmd:  %s" % cmd, file=sys.stderr)

        rtn = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE)
        results = rtn.stdout.decode('utf-8')
        results = results.rstrip("\t\n")

        #print("\n", file=sys.stderr)
        #print("result: \n%s" % results, file=sys.stderr)
        #print("\n", file=sys.stderr)        

        lines = results.split('\n')
        
        if "#" in lines[1]:
            (strfit, comment) = lines[1].split("#", 1)
        else:
            strfit = lines[1]
            comment = " "
        
        fit = strfit.split()
        
        output_line = "%s" % std["sn"]
        output_line += " %s" % std["fillcode"]
        output_line += " %s" % std["start_date"]
        output_line += " %12.6f" % float(fit[3]) # t0
        output_line += " %15.6f" % float(fit[4])    # c0
        output_line += " %15.6f" % float(fit[7])    # u0
        output_line += " %15.6f" % float(fit[5])    # c1
        output_line += " %15.6f" % float(fit[8])    # u1
        output_line += " %15.6f" % float(fit[6])    # c2
        output_line += " %15.6f" % float(fit[9])    # u2
        output_line += " %15.6f" % float(fit[10])   # sd_resid
        output_line += " %15.6f" % 0.0   # sdt_unc
        output_line += " %4d" % int(fit[11])   # n
        output_line += " %12s" % fit[13]   # level
        output_line += " #%s" % comment   # comment
   
        #print("output_line: %s" % output_line) 

        output.append(output_line)    

        # cmd2 for json file if called for
        if options.save_json:
            print("**** For json file, cmd2: %s     " % (cmd2), file=sys.stderr)
            rtn2 = subprocess.run(cmd2, shell=True, stdout=subprocess.PIPE)

    #print results to screen and savefile
    if options.save_results:
        print("Writing results to - %s" % savefile, file=sys.stderr)
        f_save=open(savefile,'a')
        for line in output:
            print(line, file=f_save) 
        f_save.close()
    else: 
        print("\n\n\n", file=sys.stdout)
        for line in output:
            print(line, file=sys.stdout) 






