# vim: tabstop=4 shiftwidth=4 expandtab
"""
hmsubs subclass for Valco valves
"""

import configparser

import hmsubs

class valco(hmsubs.hmsub):
    """ subclass for Valco valves
    Methods:
        Optional arguments are enclosed in []

        valco_current_position
            Get the current position of a valve.
            syntax: 0 ValcoCurrentPosition valve_name None

        turn_valve
            Turn a valve to a given position.
            syntax: 0 TurnValve valve_name position [direction]

        valco_find_stops
            Find stops on Valco two position valve.
            syntax: 0 ValcoFindStops valve_name None


        valve_name is either an actual device name, or a
        virtual device name
    """

    def __init__(self, configfile=None):
        super().__init__(configfile=configfile)

        self.my_procs = {
            "ValcoCurrentPosition"  : self.valco_current_position,
            "ValcoFindStops"        : self.valco_find_stops,
            "TurnValve"             : self.turn_valve,
            "TurnUniversalActuator" : self.turn_valve,  # legacy name
        }
        self.action_procs.update(self.my_procs)

    #------------------------------------------------------------------------
    def _get_valve_info(self, info):
        """ get the device name and specs for the valve. opt depends on if multiposition or 2-position """

        load = "A"
        inject = "B"
        max_position = 0
        style = "None"
        valve_id = "*"
        if info is not None:
            try:
                (style, valve_id, opt) = info.split(None, 2)
                self.logger.debug("style: %s    valve_id: %s ", style, valve_id)
                if style.upper() == "MULTIPOSITION":
                    max_position = int(opt)
                elif style.upper() == "TWO_POSITION":
                    (load, inject) = opt.split()
                else:
                    self._error_exit("Unknown valve style '%s'. Must be one of Multiposition, Two_position" % style)

            except ValueError as err:
                self.logger.error(err)
                self._error_exit("ERROR: Incorrect valve_info string '%s'. %s" % (info, err))

        return (style, valve_id, max_position, load, inject)

    #------------------------------------------------------------------------
    def valco_current_position(self, device, option, valve_name=None, valve_info=None):
        """ Get the curent position from a valco universal actuator
        Option string syntax is:
          time    ValcoCurrentPostion     valve_name    none
        """

        position = "0"
        name = device.name
        if valve_name is not None: name = valve_name

        # get the device name and specs for the valve. opt depends on if multiposition or 2-position
        (style, valve_id, max_position, load, inject) = self._get_valve_info(valve_info)

        command = "CP"
        if valve_id == "*":
            cmd = command
        else:
            cmd = "%s%s" % (valve_id, command)
        self.logger.debug("ValcoCurrentPosition command = '%s'", cmd)

        answer = device.send_read(cmd)
        if not answer:
            self.logger.error("Valco_current_position failed on device %s.", name)
            return

        self.logger.debug("Valco %s current position = %s", name, answer)
#        cp = answer.strip("CP")
        (j, cp) = answer.split("P")
        self.logger.debug("Valco %s current position = %s", name, cp)

        print(int(cp))


    #------------------------------------------------------------------------
    def valco_find_stops(self, device, option, valve_name, valve_info):
        """ Find stops on Valco two position valve
        Option string syntax is:
          time    ValcoFindStops          valve_name    none

        valco_find_stops   ValcoFindStops
        """

        name = device.name
        if valve_name is not None: name = valve_name

        # get the device name and specs for the valve. opt depends on if multiposition or 2-position
        try:
            (style, valve_id, opt) = valve_info.split(None, 2)
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("ValcoFindStops error for %s. Incorrect valve_info string '%s'. %s" % (name, valve_info, err))

        if style.upper() == "MULTIPOSITION":
            self.logger.debug("Can not find stops on multiposition valve")
        else:
            command = "LRN"
            cmd = "%s%s" % (valve_id, command)
            self.logger.debug("ValcoFindStops command = '%s'", cmd)
            device.send(cmd)


    #------------------------------------------------------------------------
    def turn_valve(self, device, option, valve_name=None, valve_info=None):
        """
        Turn a Valco valve with Universal Acutator.  Either multiposition or two
        position valve.

        Option string syntax is:
          time    TurnValve      valve_name    position  (direction)

        e.g.
          0    TurnValve    SampleSelect    2     (up or down)
          direction (optional argument for multiposition valves):
                up = CW (clockwise)
                down = CC (counter clockwise)
                default if no direction given is shortest

          or for two position valves
          0    TurnUniversalAcuator    CH4inject    Load

        valve name can be either the device name set in the configuration file,
        or a 'virtual' name defined in the conf file with an associated device
        e.g.
            device definition (can have one or many valves on same serial port)
            device  ValcoValves      serial /dev/ttyS1 0 9600

            # Information on multi-position valves
            # type = multiposition
            #name           device       type           id  max_positions
            SampleSelect    ValcoValves  multiposition  0   16
            Use '*' for id if valve is not set with an id number

            # Information of 2-position valves
            # type = two_position
            # name          device    type  id  load_position  Inject_position
            # ch4_inject    ValcoValves  two_position  1  A  B

            Then use either
            0 TurnValve ValcoValves 4
            or
            0 TurnValve SampleSelect 4

        The 'virtual' name method is required if multiple valves are connected to the same
        interface, using different ID numbers for each valve.

        """

        position = "0"
        direction = "None"
        name = device.name
        if valve_name is not None: name = valve_name

        try:
            vals = option.split()
            position = vals[0]
            if len(vals) > 1:
                direction = vals[1].lower()
        except ValueError as err:
            self.logger.error(err)
            self._error_exit("TurnValve error for %s. Incorrect option string '%s'." % (name, option))


        (style, valve_id, max_position, load, inject) = self._get_valve_info(valve_info)

        #check to see if a direction was passed (up or down only), set command to appropriate CW or CC
        #CW and CC commands only valid with multiposition valve, use default "GO" for 2-position
        command = "GO"
        if style.upper() == "MULTIPOSITION":
            if direction.upper() == "UP":
                command = "CW"
            elif direction.upper() == "DOWN":
                command = "CC"
            else:
                # No other direction valid, use default shortest path "GO" command
                pass

        self.logger.debug("direction = %s, command = %s", direction, command)

        #check to see if dealing with load/inject, set position
        if position.upper() == "LOAD":
            position_ = load
        elif position.upper() == "INJECT":
            position_ = inject
        else:
            position_ = position

        if valve_id == "*":
            cmd = "%s%s" % (command, position)
        else:
            cmd = "%s%s%s" % (valve_id, command, position_)
        self.logger.debug("TurnValve command = '%s'", cmd)

        n = device.send(cmd)
        if n != 0:
            self._error_exit("TurnValve failed on device %s: %s" % (name, cmd))

        self.logger.info("TurnValve %s %s", name, option)
