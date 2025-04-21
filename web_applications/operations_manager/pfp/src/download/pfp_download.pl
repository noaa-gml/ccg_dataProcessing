#!/usr/bin/perl
#
# pfp_download.pl
#
# Script to download Portable Flask Package (PFP) history
#
$projdir = "/var/www/html/om/";
$workdir = "${projdir}pfp/src/";

$serialport = ($ARGV[0]) ? $ARGV[0] : "/dev/ttyr300";
$outfile = ($ARGV[1]) ? $ARGV[1] : "";
#
# Download the history file from PFP
#
if ($outfile) { $err = system("${workdir}download/get_pfp_history_v306j ${serialport} > ${outfile}"); }
else { $err = system("${workdir}download/get_pfp_history_v306j ${serialport} "); }

if ($err)
{
        print "error running get_as_history\n";
	exit 2;
}

if (!($err) && $outfile) { chmod 0666, $outfile; }
