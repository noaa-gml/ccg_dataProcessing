system_name = "Magicc_3"

database = "magicc.db"

#python environment
python = "/home/magicc/src/python_environment.sh"

# pages that are considered separate systems
# and their directories
# A separate tab page will be made for each.
sysdir = "/home/magicc"

# set the measurement path numbers for this system. Used to determine if a flask should be measured here
valid_measurement_paths = [1,6]  #1=gneric "magicc", 6="magicc-3" specifically

#systems = ["Picarro", "GC", "Aerodyne"]
systems = ["Picarro", "GC1", "GC2", "Aerodyne" ]

#systems = {"Picarro": ["CO2", "CH4"], "Aerodyne": ["N2O", "CO"], "GC": ["H2", "SF6"]}
systems = {"Picarro": ["CO2", "CH4"], "Aerodyne": ["N2O", "CO"], "GC1": ["SF6"], "GC2": ["H2"]}


# number of cycles for the response curve
num_response_curve_cycles = 6
num_tank_cal_cycles = 6


#config file
conffile = "magicc.conf"

# name of log file for run manager program
logfile = "magicc.log"


# these names are duplicted in /src/config.py so remember to change there if any changes are made here.
ref_name = "R0" #name of reference gas
junk_name = "J0" #name of junk air for continuous ref aliquot mode



main_frame = ""
child = None

# How often to refresh the status/results pages
status_refresh = 1000
page_refresh = 100000
qcplot_refresh = 300000

# Number of bytes to show in syslog page
log_size = 200000

# Number of days to plot in the co2 hourly average voltages
# Do not go back past the previous month
hravg_days = 14

# Number of hours for showing 10 second voltages
sec10_hours = 12

# Number of days for showing mixing ratio
mr_days = 5
# Number of days for showing qc data
qc_days = 5

# Number of days for plotting target results
tgt_days = 120

# Number of days for plotting gc signals
signal_days = 4

# Number of readings for co2 manual control plot
co2_man_ctrl = 120

# Update time in milliseconds for co2 manual control plot
co2_man_ctrl_update = 1000

analyzer_labels = ["CO2/CH4", "CO/N2O"]
refgas_labels = ["S", "S1", "S2", "S3", "S4", "TGT"]

worksheet_labels = {
"SYSTEM": [
	"S Tank Pressure: ",
	"S2 Tank Pressure: ",
	"S2 Tank Pressure: ",
	"S3 Tank Pressure: ",
	"S4 Tank Pressure: ",
	"Target Tank Pressure: ",
],

}

