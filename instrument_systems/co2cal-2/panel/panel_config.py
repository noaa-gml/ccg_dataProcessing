
system_name = "co2cal-2"

database = "magicc.db"

# pages that are considered separate systems
# and their directories
# A separate tab page will be made for each.
sysdir = "/home/co2cal"

#systems = ["CO2", "CH4", "CO/H2", "N2O/SF6"]
systems = ["Picarro", "LGR", "Aerodyne"]

systems = {"Picarro": ["CO2", "CH4"], "LGR": ["CO2C13", "CO2O18", "CO2"], "Aerodyne": ["CO2C13", "CO2O18","CO2"]}

#config file
conffile = "co2cal.conf" 

# these names are duplicted in /src/config.py so remember to change there if any changes are made here.
ref_name = "R0" #name of reference gas
junk_name = "J0" #name of junk air for continuous ref aliquot mode

# name of log file for run manager program
logfile = "co2cal.log"

#num of cycles per cylinder in response curves
num_response_curve_cycles = 8



main_frame = ""
child = None

# How often to refresh the status/results pages
status_refresh = 1000
page_refresh = 900000
qcplot_refresh = 300000

# Number of bytes to show in syslog page
log_size = 200000
#log_refresh = 1000
log_refresh = 300000

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

#analyzer_labels = ["CO2/CH4", "CO/N2O"]
analyzer_labels = ["CO2"]
refgas_labels = ["R0"]

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

