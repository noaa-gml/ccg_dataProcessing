#!/usr/bin/env python
# vim: tabstop=4 shiftwidth=4 expandtab
""" hardware manager program

v4.2

- Added explicit lock_interface to actions that loop and take multiple
  readings (such as monitor_device, monitor_output ...). Thus one lock/unlock
  instead of a lock/unlock on every reading.


"""

import sys
import argparse
import signal
import time
import logging
import logging.handlers

# hm related modules
import action


logfile = "sys.log" # default log file name

LOGLEVEL = logging.INFO         # log level for logging to file
CLOGLEVEL = logging.ERROR       # log level for console messages

INTERVAL = 0.1          # interval in seconds to check about running actions



#############################################################
def end_program(signum, frame):
    """ Handler for interupt of program """

    logger.info("Got termination signal")

    shutdown()

#############################################################
def shutdown():
    """ Stop the program.
    First close any open serial devices.
     """

    # close serial interface
    for devname in act.devices:
        if act.devices[devname].opened:
            act.devices[devname].inst.close()

    sys.exit(0)


#############################################################
def create_logs(logfile, loglevel, cloglevel, rotate_logs):
    """
    Set up logging, both to a file and console.
    See http://docs.python.org/2/howto/logging-cookbook.html

    # set up logging to file
    logging.basicConfig(level=loglevel,
                format='%(levelname)-8s: %(asctime)s %(message)s',
                filename=logfile,
                filemode='a')

    # define a Handler which writes ERROR messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(cloglevel)

    # set a format which is simpler for console use
    formatter = logging.Formatter('%(levelname)s: %(message)s')

    # tell the handler to use this format
    console.setFormatter(formatter)

    # add the handler to the root logger
    logging.getLogger('').addHandler(console)

    """


    # create logger
    logger = logging.getLogger('hm')
    logger.setLevel(loglevel)

    # create a file handler, with timed rotation of logs if rotate_logs is True
    if not rotate_logs:
        ch = logging.handlers.WatchedFileHandler(logfile)
    else:
        ch = logging.handlers.RotatingFileHandler(logfile, maxBytes=1000000, backupCount=10)
    ch.setLevel(loglevel)
    formatter = logging.Formatter('%(levelname)-8s: %(asctime)s %(message)s') # create formatter
    ch.setFormatter(formatter)                               # add formatter to ch
    logger.addHandler(ch)                               # add ch to logger

    # define a Handler which writes ERROR messages or higher to the sys.stderr
    console = logging.StreamHandler()
    console.setLevel(cloglevel)
    formatter = logging.Formatter('%(levelname)s: %(message)s')     # set a format which is simpler for console use
    console.setFormatter(formatter)                 # tell the handler to use this format
    logger.addHandler(console)                     # add the handler to the logger

    return logger


#############################################################

signal.signal(signal.SIGTERM, end_program)      # Execute endprog on TERM signal
signal.signal(signal.SIGINT, end_program)      # Execute endprog on INT signal

parser = argparse.ArgumentParser(description="Run hardware manager program.")
parser.add_argument("-c", "--configfile", default="hm.conf", help="Set configuration file to use.  Default is 'hm.conf'.")
parser.add_argument("-t", "--test", action="store_true", default=False, help="Read config and process config file, show settings.")
parser.add_argument("-a", "--actions", action="store_true", default=False, help="Show action lines to process.")
parser.add_argument("-d", "--debug", action="store_true", default=False, help="Set logging to DEBUG level.")
parser.add_argument("-l", "--logfile", default="sys.log", help="Set log file name. Default is 'sys.log'")
parser.add_argument("-r", "--rotatelog", action="store_true", default=False, help="Rotate log files.")
parser.add_argument('args', nargs='*')
options = parser.parse_args()

if options.debug:
    LOGLEVEL = logging.DEBUG

logger = create_logs(options.logfile, LOGLEVEL, CLOGLEVEL, options.rotatelog)

# get resources and devices from the configuration file,
# and actions from stdin
act = action.Action(options.configfile, options.args, logger)

if options.test:
    act.showDevices()
    act.showVirtualDevices()
    act.showResources()

if options.test or options.actions:
    act.showActions()

# check that action devices and procedures exist
err = act.check()
if err != 0:
    sys.exit(err)

if options.test or options.actions or not act.valid:
    sys.exit(0)


# Now loop until all actions have been executed, then exit.
# Wait INTERVAL seconds after each check of actions to be run.
starttime = time.time()
while True:

    # time since we started
    elapsed_time = time.time() - starttime

    acts = act.actions[:]
    for action in acts:
        if elapsed_time >= action.second:

            if action.device in act.devices:        # to an actual device
                device = act.devices[action.device]
                name = device.name

            elif action.device in act.virtual_devices:  # to a virtual device
                v = act.virtual_devices[action.device]
                device = act.devices[v["name"]]
                name = device.name

            else:       # some actions don't use an actual device, but something else, like a filename
#                print(action)
                name = 'none'
                device = action.device
#                print(device.name)
#                print(act.classname.keys())
#                sys.exit("Bad device name '%s'" % action.device)

            # the call method will figure out the correct class method to run
#            act.classname[device.name].call(device, action, act.virtual_devices)
            act.classname[name].call(device, action, act.virtual_devices)

            # remove this action
            act.actions.remove(action)

    # If all the actions have been run, then we're done.
    if len(act.actions) == 0:
        shutdown()

    time.sleep(INTERVAL)
