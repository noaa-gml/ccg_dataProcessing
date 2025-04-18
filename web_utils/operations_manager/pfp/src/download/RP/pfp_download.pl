#!/usr/bin/perl
#
# pfp_download.pl
#
# Script to download Portable Flask Package (PFP) history
#
$projdir = "/www/ccgg/dbms/om/pfp/";
$workdir = "${projdir}src/";

$outfile = ($ARGV[0]) ? $ARGV[0] : "";
#
# Download the history file from PFP
#
if ($outfile) { $err = system("${workdir}download/RP/get_as_history > ${outfile}"); }
else { $err = system("${workdir}download/RP/get_as_history"); }

if ($err)
{
        print "error running get_as_history\n";
	exit 2;
}

if (!($err) && $outfile) { chmod 0666, $outfile; }
