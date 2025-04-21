
""" A class for calling the hm program """

import sys
import os
import subprocess
import logging

#import logging.handlers


class RunAction():
    """ A class for calling the hm program in various ways:
        run - start hm in foreground with given action file
        runbg - start hm in background with given action file
        execute - start hm in foreground with given list of action lines


    Creation:
        action = RunAction(actiondir="somedir", configfile="someconfigfile", testMode=False|True)

    Running hm:

        r = action.run(actionfile)
        where r is the return value from hm process

        p = action.runbg(actionfile)
        where p is Popen object for the hm process

        r = action.execute(actionlist)
        where r is the return value from hm process

        For cases 1 and 3, any output from hm can be read from action.stdout.
        For case 2, output can be read with p.stdout.readline()

    """

    def __init__(self, actiondir="", configfile="hm.conf", bindir="", testMode=False, debug=False, rotate_logs=False):

        self.valid = False
        self.actiondir = actiondir
        self.configfile = configfile
        self.output = ""
        self.errors = None
        self.debug = debug

        # use ccg logger (normally created by ccg.py), if not already made, then no logging is done in this module.
        self.logger = logging.getLogger("ccg")
#        fhandler = logging.FileHandler("zzz.log")
#        self.logger.addHandler(fhandler)


        if bindir == "":
            home = os.environ["HOME"]
            self.bindir = home + "/bin"
        else:
            self.bindir = bindir


        if not os.path.exists(self.bindir + "/hm"):
            print("Warning: hm program does not exist in directory %s." % (self.bindir), file=sys.stderr)
        else:
            if rotate_logs:
                self.command = "%s/hm -c %s -r " % (self.bindir, self.configfile)
            else:
                self.command = "%s/hm -c %s " % (self.bindir, self.configfile)
            if testMode:
                self.command += "-t "
            if debug:
                self.command += "-d "
            self.valid = True

        if self.debug:
            print("hm command is", self.command)


    #-------------------------------------------------------------------------
    def run(self, actionfile, *args):
        """ Run an action in the foreground, wait for it to finish. """

        actionlines = self._get_actionfile(actionfile)
        if actionlines:
            arglist = self._get_command(*args)
            self.logger.info("run action %s with action file %s", " ".join(arglist), actionfile)
            retcode = self._run(arglist, actionlines)

            return retcode

        return -1


    #-------------------------------------------------------------------------
    def runbg(self, actionfile, *args):
        """ Run an action in the background, don't wait for it to finish. """


        arglist = self._get_command(*args)
        command = " ".join(arglist)

        self.logger.info("runbg action %s with action file %s", command, actionfile)
        try:
            p = subprocess.Popen(arglist, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            if actionfile is not None:
                actionlines = self._get_actionfile(actionfile)
                p.stdin.write(actionlines)
                p.stdin.close()

        except OSError as err:
            self.logger.error("Execution of %s failed: %s", command, err)
            p = None

        return p


    #-------------------------------------------------------------------------
    def execute(self, action_lines, *args):
        """ execute a list of action lines, wait for it to finish,
        then save any output or errors.
         """

        arglist = self._get_command(*args)
        actionlines = "\n".join(action_lines)
        retcode = self._run(arglist, actionlines)

        return retcode


    #-------------------------------------------------------------------------
    def _run(self, arglist, actionlines):
        """ Start a process in foreground that runs hm with given options and actions.
        Wait for it to finish and save any output and errors.
        """

        self.output = None
        self.errors = None
        command = " ".join(arglist)
#        if self.debug:
#            print("in action._run, arglist is", arglist)
#            print("in action._run, actionlines are", actionlines)
        try:
            # python 3.7 syntax
            p = subprocess.run(arglist, input=actionlines, capture_output=True, text=True)
            # python 3.6 syntax
#            p = subprocess.run(arglist, input=actionlines, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines=True)
            self.output = p.stdout
            self.errors = p.stderr
            retcode = p.returncode
            if retcode != 0:
                s = "hm returned error %d running command %s" % (retcode, command)
                print(self.errors, file=sys.stderr)
                self.logger.error(s)

        except OSError as err:
            self.errors = err
            self.logger.error("Execution of %s failed: %s", command, err)
            retcode = -1

        return retcode


    #-------------------------------------------------------------------------
    def _get_command(self, *args):
        """ combine the action filename and arguments into a list
        suitable for running with subprocess.
        """

        command = self.command.split()
        command.extend([str(x) for x in args])

        return command

    #-------------------------------------------------------------------------
    def _get_actionfile(self, actionfile):
        """ add the action directory name to the action file if it is set.
        Check if the actionfile exists. If so read in the lines from the file
        and return them.
        """

        if self.actiondir != "":
            filename = "%s/%s" % (self.actiondir, actionfile)
        else:
            filename = actionfile

        if not os.path.exists(filename):
            s = "Cannot find action file %s" % filename
            self.logger.error(s)
            print(s, file=sys.stderr)
            return None

        try:
            f = open(filename)
        except IOError as err:
            s = "Cannot open action file %s: %s" % (filename, err)
            self.logger.error(s)
            return None

        cmds = f.readlines()
        f.close()
        s = "".join(cmds)

        return s
