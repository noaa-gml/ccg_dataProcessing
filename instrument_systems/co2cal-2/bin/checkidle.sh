#!/bin/bash
#
# Check if idle gas needs to be switched to room air
#
# 
# The co2cal process must not be running, and it must
# be > 30 minutes since it ended.

set -x

tempoutfile=/home/co2cal/checkidle_output.txt
echo "checkidle.sh started" > $tempoutfile

# Get pid of co2cal process
read pid < .pid
echo "pid:  $pid " >> $tempoutfile
#pid=3688

# check if it is running
kill -s 0  $pid 2> /dev/null
a=$?

sys_running=0

# if process is running (a=0) then double check it is a co2cal
if [ $a -eq 0 ]
then
	# double check process is actually a co2cal
	s=`ps -p $pid -o cmd --no-headers | grep co2cal`
	if [ "$s" != "" ]
	then
		sys_running=1
		echo "system is running" >> $tempoutfile
	fi
fi

# if cal is not running, check if enough time has passed to switch idle gas
if [ $sys_running -eq 0 ]
then

	# get last mod time of sys.status
	# cal writes out a completed message when done
	filemtime=`stat -c %Y sys.status`

	# get current time
	currtime=`date +%s`

	# calc elapsed time in minutes
	diff=$(( (currtime - filemtime) / 60 ))
	echo "time diff:  $diff" >> $tempoutfile

	past_delay=0
	if [ $diff -gt 60 ]
	then
		past_delay=1
	fi

	echo "past_delay: $past_delay" >> $tempoutfile

	if [ $past_delay -eq 1 ]
	then
		# execute script to switch idle gas valve
		echo "switch idle gas" >> $tempoutfile

		echo "0 OpenRelay hp34970 @Idle" | hm -c config/co2cal.conf


	fi
fi
