#!/usr/bin/perl
#
require "/projects/src/db/ccg_utils.pl";
#
use Getopt::Std;
#
# Read FLASK sample raw files
#
# July 2006 - kam
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
&getopts('d:g:hi:np:s:');

if ($opt_h) { &showargs(); }

if (!($opt_g)) { &showargs(); }
$gas = lc($opt_g);

if ($opt_s) { @sites = split(/,/, uc($opt_s)); }

if (!($opt_i)) { &showargs(); }
@inst_list = split ',', $opt_i;

$project = ($opt_p) ? $opt_p : "flask";
if ($project eq "pfp") { $project = "aircraft"; }

$not = ($opt_n) ? 1 : 0;

@date = ($opt_d) ? split(/,/, $opt_d) : ("", "");
#
#######################################
# Initialization
#######################################
#
$rootdir = "/projects/${gas}/${project}/";
$perl = "/projects/src/db/ccg_getraw.pl";

$tmpfile = "/projects/tmp/qc".int(10**8*rand());

@results = ();
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

foreach $inst (@inst_list)
{
	$dir = "${rootdir}${inst}/raw/";
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
			next if $file !~ /\.${gas}/;
			next if (substr($file, 0, 10) lt $date[0]);
			last if (substr($file, 0, 10) gt $date[1]);
		
			system("${perl} -tn -r ${dir}${year}/${file} -o${tmpfile}");
			@tmp = &ReadFile($tmpfile);

			if ($#sites != (-1))
			{
				@zzz = ($not) ? @tmp : ();

				foreach $site (@sites)
				{
					if ($not) { @zzz = grep !/^$site/, @zzz; }
					else { push @zzz, grep /^$site/, @tmp; }
				}
				@tmp = @zzz;
			}
			push @raw, @tmp;
		}

	}
}
foreach $line (@raw) { print $line,"\n"; }
unlink($tmpfile);
exit;

sub showargs()
{
   print "\n#########################\n";
   print "read_flask_raw.pl\n";
   print "#########################\n\n";
   print "Options:\n\n";
   print "d    measurement date (single or range, default: current month)\n";
   print "h    product help menu\n";
   print "g    gas\n";
   print "p    project (pfp or flask, default: flask)\n";
   print "i    Specify a single analysis system (e.g., -iH4)\n";
   print "     or any number of systems (e.g., -iH4,H6)\n";
   print "s    site code\n";
   print "     Specify a single site (e.g., -sbrw)\n";
   print "     or any number of sites (e.g., -stst,bld)\n";
   print "n    If specified, exclude '-s' sites\n";
   print "\n(ex)\n\n";
   print "./read_flask_raw.pl -stap -d2005 -iL3,L8 -gco2\n";
   print "./read_flask_raw.pl -ssum,brw -gch4 -iH4,H6 -d2006-01-01,2006-03\n";
   print "./read_flask_raw.pl -sref -n -d2006-03,2006-04 -gco -iR5\n";
   exit;
}
