#!/usr/bin/perl
#
# pfp_uploadplan.pl
#
# Script to upload PFP sample plan.
# Compatible with version 2 or 3 PFP software
# Re-formats output.
#
# July 30, 2004 - kam

use DBI;
use Getopt::Std;
#
#######################################
# Parse Arguments
#######################################
#
&getopts('f:ho:p:');

$infile = $opt_f;
$serialport = ($opt_p) ? $opt_p : "/dev/ttyr100";
$outfile = $opt_o;
#
#######################################
# Initialization
#######################################
#
%months = ('JAN', 1, 'FEB', 2, 'MAR', 3, 'APR',  4, 'MAY',  5, 'JUN',  6,
	   'JUL', 7, 'AUG', 8, 'SEP', 9, 'OCT', 10, 'NOV', 11, 'DEC', 12);

%defs = ('alt', "-99999", 'lat', "-99.99", 'lon', "-999.99",
         'date', "9999-12-31", 'time', "00:00:00");

$workdir = "/var/www/html/om/pfp/src/";
$format = "%8s %2s %8s %8s %8s %12s %10s";
$outfile = "${workdir}tmp/xxx-".int(10**8*rand()).".log";
#
# Read sample plan input file
# Identify PFP version 
# If version 2, use year from first sample

open (FILE, $infile) || die "Can't open file $infile.\n";
$str = <FILE>;
close(FILE);

($case_id,$code) = split /,/, $str;
#
#
# Version 2 or 3?
#
$ver = ($case_id < 3000) ? 2 : 3;
#
# Upload sample plan to PFP
#
$exec = "${workdir}upload/as_fplan_v${ver} ${infile} ${serialport}";

$err = system("${exec} > ${outfile} 2>&1");
chmod 0666, $outfile;

if ($err)
{
	system("cat ${outfile}");
	exit 2;
}
#
# Prepare re-formatted output
#
open (FILE, $outfile) || die "Can't open file $outfile.\n";
@arr = <FILE>;
close(FILE);
chop(@arr);

@sum = ();
for ($i=0; $i<@arr; $i++)
{ 
	$arr[$i] =~ s/^ //;
	@field = split ' ', $arr[$i];

	next if ($#field < 2);

	if ($field[1] =~ "(valid)")
	{
		$alt = ($field[2] =~ "--") ? $defs{'alt'} : $field[2];
		$lat = ($field[4] =~ "--") ? $defs{'lat'} : $field[4];
		$lon = ($field[6] =~ "--") ? $defs{'lon'} : $field[6];

		($date,$time) = &date_time($ver,@field);
		$out = sprintf($format,"(valid)",$field[0],$alt,$lat,$lon,$date,$time);
	} 
	else { $out = sprintf($format,"NA",$field[0],$defs{'alt'},$defs{'lat'},
				$defs{'lon'},$defs{'date'},$defs{'time'}); }
	print $out,"\n";
}
exit 0;

sub	date_time
{
	local($ver,@arr) = @_;
	#
	# Build date and time strings
	#
	@zzz = ();

 	@tmp = localtime();
 	$year = sprintf("%4.4d",1900+$tmp[5]);
	#
        # version-specific code
        #
        if ($ver == 3)
        {
		$zzz[0] = ($arr[9] =~ "--") ? $defs{'date'} : $arr[9];
		$zzz[1] = ($arr[8] =~ "--") ? $defs{'time'} : $arr[8];
	}
	else
	{ 
		$t1 = $arr[8];
		$hr = substr($t1,0,2);
		$mn = substr($t1,3,2);

		$yr = ($#arr > 8) ? $year : '9999';
		$mo = ($#arr > 8) ? $months{uc($arr[10])} : '12';
		$dy = ($#arr > 8) ? $arr[11] : '31';

        	$zzz[0] = sprintf "%4.4d-%2.2d-%2.2d",$yr,$mo,$dy;
        	$zzz[1] = sprintf "%2.2d:%2.2d:00",$hr,$mn;
	}
	return @zzz;
}
