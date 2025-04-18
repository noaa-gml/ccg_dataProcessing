# vim: tabstop=4 shiftwidth=4 expandtab
"""
Define the class for holding action data.

Action data comes from a text file of 'action' lines.
Each line consists of 4 fields, separated by white space:

    time action_name device parameters

For example,
    0 ScaleValue hp34970 1 10

The device and parameter fields can use substitutions using '@' and '$' symbols,
such as @name and $1.  The '@' symbol means to replace 'name' with the
corresponding name in the hm configuration file.  The '$' symbol means to
replace the number with the argument number from the hm command line.

Examples:
--------
If we have in hm.conf the line
Line1       1

and have in our action file
0 TurnValve valcovalve @Line1

the '@Line1' will be replaced with '1'.

--------
If we have in our action line

0 TurnValve valcovalve $1

and we call hm with
    hm 1

then the '$1' in the action line will be replaced with '1'


"""

import sys
import re
from collections import namedtuple
import importlib
import logging

import pyvisa

from hmsubs import hmsub
import errornum
import device

#############################################################
def clean_line(line):
    """
    Remove unwanted characters from line,
    such as leading and trailing white space, new line,
    and comments
    """

    line = line.strip('\n')            # get rid on new line
    line = line.strip()            # strip white space from both ends
    line = line.replace("\t", " ")        # replace tabs with spaces
#    line = line.split('#')[0]        # discard '#' and everything after it
    a = line.split()
    b = []
    for t in a:
        if not t.startswith("#"):
            if t.startswith("\\"):
                t = t.strip("\\")
            b.append(t)
        else:
            break

    line = " ".join(b)

    return line


#############################################################
class Action():
    """
    Class for containing information about the actions lines
    that are read from stdin on startup.

    Args:
        configfile : The hm configuration file to read
        args : Any command line arguments to associate with $n items in action lines
        logger : logger to use for logging

    Members:
        resources : dict with key/value settings from hm configuration file
        devices : dict with device class objects for devices requested
        modules : dict of module names for requested devices
        config  : dict of configuration files for modules
        virtual_devices : list of virtual device names from configuration file
        actions : list of actions to perform.  Each item is a namedtuple with
            line: Duplicate of action line
            second: Time in seconds for when to start action
            action: action name, must match key name in action_procs
            device: device name
            option: option string, varies with each action
        classname : dict with module class objects, device name as key
        valid : True if no errors reading and parsing files, False if errors found.

    Methods:
        check() - check that device names and action names are valid
        showDevices() -  print out list of devices being used
        showVirtualDevices() - print out list of virtual devices
        showResources() - print out resources from configuration file
        showActions() - print out list of actions to perform
    """

    def __init__(self, configfile, args=None, logger=None):

        self.resources = {}
        self.devices = {}
        self.modules = {}
        self.config = {}
        self.virtual_devices = {}
        self.actions = []
        self.classname = {}  # a dict of class objects, with device name as key
        self.valid = True
        if logger is None:
            self.logger = logging.getLogger('hm')
        else:
            self.logger = logger

        names = ["line", "second", "action", "device", "option"]
        self.Action = namedtuple('Action', names)

        self._get_resources(configfile)
        if args is not None:
            self._read_actions(args)
        self._get_modules()

    #------------------------------------------------------------------------
    def showDevices(self):
        """ print devices """

        print("Device list: ")
        for devname in self.devices:
            if devname == "none": continue
            print("  ", devname)
            dev = self.devices[devname]
            dev.show_members()
            if devname in self.modules:
                print("      Module:", self.modules[devname])
            if devname in self.config:
                print("      Configuration file:", self.config[devname])
        print()

    #------------------------------------------------------------------------
    def showVirtualDevices(self):
        """ Print virtual devices """

        print("Virtual Device list:")
        for name in self.virtual_devices:
            v = self.virtual_devices[name]
            print("  ", name)
            print("      Device name:", v["name"])
            print("      Option:", v["option"])
        print()

    #------------------------------------------------------------------------
    def showResources(self):
        """ Print resources """

        print("Resource list: ")
#        if len(list(self.resources.keys())) > 0:
        if list(self.resources.keys()):
            maxlen = max(len(s) for s in list(self.resources.keys()))
            format_ = "   %%%ds : '%%s'" % maxlen
            for key in sorted(self.resources):
                print(format_ % (key, self.resources[key]))
        print()

    #------------------------------------------------------------------------
    def showActions(self):
        """ Print actions """

        print("Action list: ")
        maxlen = max(len(action.line) for action in self.actions)
        format_ = "   %%-%ds => '%%s %%s %%s %%s'" % maxlen
        for action in self.actions:
            print(format_ % (action.line, action.second, action.action, action.device, action.option))
        print()

    #------------------------------------------------------------------------
    def _get_modules(self):
        """ Determine which 'modules' are needed for the requested devices.

        Import the modules, instantiate the class objects, and store the object
        in the 'classname' dict, with the device name as the key.

        Requires that the class name and the module name are the same,
        e.g. in the module 'scpi.py' is class scpi
        """

        # create the hmsubs class object for each device
        # always include 'none' module
        self.classname['none'] = hmsub()

        # for each device, determine the module it uses,
        # and create the class object
        for devname in list(self.devices.keys()):
            if devname in self.modules:
                module_name = self.modules[devname]
                module = importlib.import_module(module_name)
                class_ = getattr(module, module_name)
                if devname in self.config:
                    self.classname[devname] = class_(configfile=self.config[devname])
                else:
                    self.classname[devname] = class_()
            else:
                # if device specified, but no module, use default class
                if devname in self.config:
                    self.classname[devname] = hmsub(configfile=self.config[devname])
                else:
                    self.classname[devname] = hmsub()


    #------------------------------------------------------------------------
    def check(self):
        """ Check that action device exists in either the devices list
        or as a virtual device in resources.
        Also check the action method name is available from the class for that device
        """

#        print("@@@@@@@@ inside action check ")
        err = 0
        # Check on device for all but certain actions
        for action in self.actions:
#            print(action)

            # check that device name is valid
            if action.device != "none":
                if action.action.lower() not in ['showstatus', 'logdatadb']:
                    if action.device not in self.devices and action.device not in self.virtual_devices:
                        print("Unknown device %s." % (action.device), file=sys.stderr)
                        self.logger.error("Unknown device %s.", action.device)
                        err = errornum.NODEVICE
                        continue

            # check that action name is valid, i.e. it exists in the module
            if action.device in self.devices:
#                print(self.classname[action.device].action_procs.keys())
                if action.action not in self.classname[action.device].action_procs:
                    self.logger.error("Unknown action '%s' for device %s", action.action, action.device)
                    err = errornum.NOACTION

            # check that virtual action name is valid, i.e. it exists in the module
            elif action.device in self.virtual_devices:
#                print(self.virtual_devices)
                devname = self.virtual_devices[action.device]["name"]
                if action.action not in self.classname[devname].action_procs:
                    self.logger.error("Unknown action '%s' for virtual device %s, %s", action.action, action.device, devname)
                    err = errornum.NOACTION


        return err


    #------------------------------------------------------------------------
    def _get_resources(self, configfile):
        """
        Read in the configuration file, and store the name:value
        resources from the file in the 'resources' dict.
        Also for lines that start with 'device', 'module' and 'config',
        save info for those lines in separate dicts.
        """

        rm = pyvisa.ResourceManager()

        try:
            fp = open(configfile)
        except IOError as err:
            self.logger.error("Cannot open configuration file. %s", err)
            sys.exit(errornum.NOCONFIGFILE)

        # always create a "none" device
        self.devices["none"] = device.Device(rm, "none")

        for line in fp:
            line = clean_line(line)
            if line:
                try:
                    (name, value) = line.split(None, 1)
                except ValueError as err:
                    self.logger.error("Bad formatted line in file %s: '%s'. %s", configfile, line, err)
                    print("Bad formatted line in file %s: '%s'. %s" % (configfile, line, err), file=sys.stderr)
                    sys.exit(errornum.BADCONFLINE)

                name = name.lower()
                if name == "device":
                    try:
                        (devname, bus, devfile, use_cr, baud) = value.split()
                    except ValueError as err:
                        self.logger.error("Bad formatted line in file %s: '%s'. %s", configfile, line, err)
                        print("Bad formatted line in file %s: '%s'. %s" % (configfile, line, err), file=sys.stderr)
                        sys.exit(errornum.BADCONFLINE)

                    devname = devname.lower()
                    self.devices[devname] = device.Device(rm, devname, bus, devfile, use_cr, baud)

                elif name == "module":
                    try:
                        (devname, module_name) = value.split()
                    except ValueError as err:
                        self.logger.error("Bad formatted line in file %s: '%s'. %s", configfile, line, err)
                        print("Bad formatted line in file %s: '%s'. %s" % (configfile, line, err), file=sys.stderr)
                        sys.exit(errornum.BADCONFLINE)

                    devname = devname.lower()
                    self.modules[devname] = module_name.lower()

                # device dependent configuration
                elif name == "config":
                    try:
                        (devname, conffile) = value.split()
                    except ValueError as err:
                        self.logger.error("Bad formatted line in file %s: '%s'. %s", configfile, line, err)
                        print("Bad formatted line in file %s: '%s'. %s" % (configfile, line, err), file=sys.stderr)
                        sys.exit(errornum.BADCONFLINE)

                    self.config[devname] = conffile

                else:
                    self.resources[name] = value

        fp.close()

        self.logger.debug("devices: %s", self.devices)
        self.logger.debug("modules: %s", self.modules)
        self.logger.debug("config: %s", self.config)
        self.logger.debug("resources: %s", self.resources)

        # now go through resources and find "virtual" devices. These are resources where
        # the first field in the value matches a real device.
        # Store the virtual device name as the key,
        # and real device name and the option that goes with the virtual device as the value.
        for name in self.resources:
            value = self.resources[name]
            items = value.split()
            if items[0].lower() in list(self.devices.keys()):
                self.virtual_devices[name] = {"name": items[0].lower(), "option": " ".join(items[1:])}

        self.logger.debug("virtual_devices: %s", self.virtual_devices)


    #------------------------------------------------------------------------
    def _read_actions(self, args):
        """
        Read in the action file and do the $n and @ref substitutions.
        Ignore the action procedures for now. Those will be set
        in the check loop in the main section.

        Populate the self.actions list with Action classes
        """

        # first do $n substitutions.
        # @ substitutions will be done on second pass.
        # This allows a command argument to have spaces in it

        new_lines = []
        for line in sys.stdin:
            line = clean_line(line)

            if not line:
                continue        # ignore blank lines

            # every action line must have 4 fields.
            # The option field can have space separated fields too.
            try:
                (second, name, devicename, option) = line.split(None, 3)
            except ValueError:
                self.logger.error("Bad formatted action line: '%s'.", line)
                print("Bad formatted action line: '%s'." % line, file=sys.stderr)
                sys.exit(errornum.BADACTIONLINE)

            devicename = devicename.lower()

            # Replace any $n for device
            result = re.findall(r"\$\d+", devicename)
            for pattern in result:
                b = pattern.strip('$')
                n = int(b) - 1
                if 0 <= n < len(args):
                    devicename = devicename.replace(pattern, args[n]).lower()
                    devicename = devicename.lower()
                else:
                    self.logger.error("*** No argument for $%d in '%s'", n+1, line)
                    print("ERROR: *** No argument for $%d in '%s'" % (n+1, line), file=sys.stderr)
                    self.valid = False


            # Split the option field into separate items.
            # For each item, replace $1, $2... with command line arguments,
            # and @str... items with the actual values from config file resources
            items = []
            for item in option.split():

                # do the $n first, since they may contain @ref values
                val = item

                # Find all occurences of $n
                result = re.findall(r"\$\d+", val)

                # replace any $1, $2... with the command line argument
                for pattern in result:
                    b = pattern.strip('$')
                    n = int(b) - 1
                    if "+%s" % pattern in val: continue  # allow the + in the string to prevent $ substitution
                    if 0 <= n < len(args):
                        val = val.replace(pattern, args[n])
                    else:
                        self.logger.error("*** No argument for $%d in '%s'", n+1, line)
                        print("ERROR: *** No argument for $%d in '%s'" % (n+1, line), file=sys.stderr)
                        self.valid = False

                items.append(val)

            option_string = " ".join(items)
            new_action_line = "%s %s %s %s" % (second, name, devicename, option_string)
            new_lines.append(new_action_line)


        # now do @ substitutions
        for line in new_lines:
#            print(line)

            (second, name, devicename, option) = line.split(None, 3)
            second = float(second)
            items = []
            for item in option.split():

                val = item
#                print("val is", val)

                # If option starts with '@', then remove '@' and replace the
                # remaining characters with value from resources,
                # e.g. if resources['valve1'] = 202, then @valve1 is changed to 202.
                # Take into account there can be multitple @vals separated by ','.
                if val.startswith('@'):
                    vals = []
                    opts = val.split(',')
                    for opt in opts:
                        opt = opt.strip('@').lower()
                        if opt in self.resources:
                            vals.append(self.resources[opt])
                        else:
                            self.logger.error("*** @ reference not found in config for '%s' in '%s'", val, line)
                            print("*** @ reference not found in config for '%s' in '%s'" % (val, line), file=sys.stderr)
                            self.valid = False

                    val = ",".join(vals)    # put the replaced values back together separated by ','

#                items.append(val)
                items.append(val.strip('"'))

            option_string = " ".join(items)

            act = self.Action._make((line, second, name, devicename, option_string))
            self.actions.append(act)

        self.logger.debug("actions: %s", self.actions)
