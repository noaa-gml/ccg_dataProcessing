#!/usr/bin/perl
#
require "/projects/src/db/ccg_utils.pl";
#
use Getopt::Std;
#
# Read SEMI-CONTINUOUS sample raw files
#
# September 2006 - kam
#
# Ken Masarie
# NOAA ESRL GMD Carbon Cycle
# kenneth.masarie@noaa.gov
#
#
#######################################
# Parse Arguments
#######################################
#
&getopts('d:g:hs:');

if ($opt_h) { &showargs(); }

if (!($opt_g)) { &showargs(); }
$gas = lc($opt_g);

if (!($opt_s)) { &showargs(); }
$site = lc($opt_s);

@date = ($opt_d) ? split(/,/, $opt_d) : ("", "");
#
#######################################
# Initialization
#######################################
#
$dir = "/projects/${gas}/in-situ/${site}_data/raw/";
#
# If date is not specified, use current month
#
if ($date[0] eq "") 
{
   ($d, $t) = split(/\s+/, $today);
   ($yr, $mo, $dy) = split(/-/, $d);
   @date = ("${yr}-${mo}-01", "${yr}-${mo}-31");
}
if ($#date == 0) { push @date, $date[0]; }
#
# Prepare date constraints
#
($yr, $mo, $dy) = split(/-/, $date[0]);

if ($mo eq "") { $mo = '01'; $dy = '01'; }
if ($dy eq "") { $dy = '01'; }

$date[0] = sprintf("%4.4d-%2.2d-%2.2d", $yr, $mo, $dy);

($yr, $mo, $dy) = split(/-/, $date[1]);

if ($mo eq "") { $mo = '12'; $dy = '31'; }
if ($dy eq "") { $dy = '31'; }

$date[1] = sprintf("%4.4d-%2.2d-%2.2d", $yr, $mo, $dy);
#
# Loop through raw files
#
@raw = ();
#
# ch4, co
# REF 2006 08 09 00 01  3 2.286568e+06 1.415572e+07  61.9   BB 184.2
# BRW 2006 08 09 00 08  5 2.281763e+06 1.412367e+07  61.9   BB 347.5
#
# co2
# SMP 2006 09 03 00 00 3.07918e-01 1.936e-04 232 .
# W3  2006 09 03 00 45 3.93797e-01 5.465e-05  11 .
# W2  2006 09 03 00 50 3.27214e-01 8.956e-05  12 .
# W1  2006 09 03 00 55 2.77088e-01 4.317e-05  12 .
#
# get list of relevant directories
#
opendir(DIR, $dir);
local(@years) = readdir(DIR);
closedir(DIR);

@years = sort @years;

foreach $year (@years)
{
	next if length($year) != 4;

	($yr1, $mo1, $dy1) = split '-', $date[0];
	($yr2, $mo2, $dy2) = split '-', $date[1];
	
	next if $year < $yr1;
	last if $year > $yr2;
	#
	# get list of raw files
	#
	opendir(DIR, $dir.$year);
	local(@files) = readdir(DIR);
	closedir(DIR);

	@files = sort @files;

	foreach $file (@files)
	{
		next if $file !~ /\.${gas}$/;
		next if (substr($file, 0, 10) lt $date[0]);
		last if (substr($file, 0, 10) gt $date[1]);
	
		@tmp = &ReadFile("${dir}${year}/${file}");
		push @raw, @tmp;
	}
}
foreach $line (@raw) { print $line,"\n"; }
exit;

sub showargs()
{
   print "\n#########################\n";
   print "read_insitu_raw.pl\n";
   print "#########################\n\n";
   print "Options:\n\n";
   print "d    measurement date (single or range, default: current month)\n";
   print "h    product help menu\n";
   print "g    gas\n";
   print "s    site code\n";
   print "     Specify a single site (e.g., -sbrw)\n";
   print "\n(ex)\n\n";
   print "./read_insitu_raw.pl -sbrw -d2005-01-01 -gco2\n";
   print "./read_insitu_raw.pl -smlo -d2006-01 -gco\n";
   print "./read_insitu_raw.pl -sbrw -d2006-03,2006-04 -gch4\n";
   exit;
}
