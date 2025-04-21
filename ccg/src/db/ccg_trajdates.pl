#!/usr/bin/perl

use DBI;
use Getopt::Std;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Prepare trajectory input files for Joyce Harris
#
# August 27, 2003 - kam
# Edited on May 10, 2005 - chao
#   Notes: Changed to work with ccgg database instead of ccgg1
# Edited on March 24, 2006 - chao
#   Notes: Changed to call ccg_flask.pl for data
#
#######################################
# Parse Arguments
#######################################
#
&getopts('o');

$save = $opt_o;
#
#######################################
# Initialization
#######################################
#
$wdir = "/projects/src/db/";
$ddir = "/ftp/transport/ccgg/events/";

$t1 = "site";
$t2 = "site_desc";

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get site information
#######################################
#
$select = "SELECT DISTINCTROW ${t1}.num, ${t1}.code, ${t1}.name, ${t1}.country,";
$select = "${select} ${t1}.elev, ${t1}.lat, ${t1}.lon,";
$select = "${select} ${t2}.intake_ht, ${t2}.project_num ";

$from="FROM ${t1},${t2} ";

$where="WHERE ${t1}.num=${t2}.site_num ";
#
# Consider only PFP and network flask data
#
$and="AND (${t2}.project_num='1' OR ${t2}.project_num='2')";
#
# Site must be active or terminated
#
$and="${and} AND (${t2}.project_status_num='1' OR ${t2}.project_status_num='3')";

$etc=($code) ? "" : " ORDER BY ${t1}.code";

$sql=$select.$from.$where.$and.$etc;
#print "$sql\n";

$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n=0; @arr = ();
while (@tmp = $sth->fetchrow_array()) { @arr[$n++]=join('|',@tmp) }
$sth->finish();

#Cape Grim, Tasmania               40 40'S 144 40'E    94m
#CGO|1984|04|19|06|  -40.68|  144.68|      94|Cape Grim, Tasmania, Australia

foreach $element (@arr)
{
	@tmp = split('\|', $element);
	$site_num = $tmp[0];
	$code = $tmp[1];
	$name = $tmp[2];
	$country = $tmp[3];
	$elev = $tmp[4];
	$lat = $tmp[5];
	$lon = $tmp[6];
	$ht = $tmp[7];
	$proj_num = $tmp[8];

	$elev_ht = int($elev)+int($ht);

        #print "**********************************************************\n";
        #print "$proj_num\n";
        #print "**********************************************************\n";
	$strategy = ($proj_num == 1) ? 'flask' : 'pfp';
	#
	#######################################
	# Bin site?
	#######################################
	#
	&get_binlist($code,$strategy,*binlist);

	#print "1: $code $#binlist @binlist\n";

        #
	# If there are no bin sites, then set the first element in the list
	# as the site itself. If there are bin sites, then set a new element
	# in the list as the main site.
	#
	if ($#binlist < 0) { $binlist[0] = $code; }
	else { $binlist[++$#binlist] = $code; }
	
	#print "2: $code $#binlist @binlist\n";
	
	foreach $binnedsite (@binlist)
	{
		$uppercode = uc($binnedsite);
		$lowercode = lc($binnedsite);

                @events = ();

		#
		# Call ccg_flask.pl and parse through the returned information
		# getting only the information that we want and storing it
		# in the $events variable
		#
                $perlcode = "/projects/src/db/ccg_flask.pl -s$lowercode -t";
		#print "$perlcode\n";
		open (EVENTLIST, "/usr/bin/perl $perlcode |");
		while(<EVENTLIST>)
		{
		   chomp($_);
		   @field = split(/ +/,$_);
		   #date, hour, minute, lat, lon, alt
		   $events[++$#events] = "$field[1]-$field[2]-$field[3]|$field[4]|$field[5]|$field[8]|$field[9]|$field[10]\n";
		}
		close EVENTLIST;

                #
		# If data was returned from the call to ccg_flask.pl
		#
		next if ($#events < 1);

		$file = ($save) ? "${ddir}${lowercode}.eve" : "&STDOUT";
                #print "$file\n";
                #$file = "&STDOUT";
		open(FILE,">${file}");

		$lyr = $yr; $lmo = $mo; $ldy = $dy;
		for ($i=0; $i<@events; $i++)
		{
			#
			# Provide singular dates
			# 
			# Provide the average of the hours for
			# samples collected on the same day.
			# This is a reasonable treatment for
			# most samples.
			# 
			@fields = split('\|',$events[$i]);
			@tmp = split('-',$fields[0]);

			$yr = $tmp[0];
			$mo = $tmp[1];
			$dy = $tmp[2];
			$hr = $fields[1];
			$mn = $fields[2];
			# $lat = ($binby eq 'lat') ? ($min+$max)/2.0 : $fields[3];
			$lat = $fields[3];
			$lon = $fields[4];
			$alt = $fields[5];
			# $alt = ($binby eq 'alt') ? substr($lowercode,3) : $fields[5];
			#
			# Do not prepare a trajectory if ...
			# hour has a default (99) value
			# lat has a default (-99.99) value
			# lon has a default (-999.99) value
			# alt has a default (-99999) value
			#
			next if ($hr == '99');
			next if ($lat < -90);
			next if ($lon < -900);
			next if ($alt < -9000);
			
			$z = ($proj_num == 1) ? $elev_ht : $alt;

			next if ($proj_num == 2 && $alt == 0);

			$pos = sprintf("%8.2f|%8.2f|%8d|%s",$lat,$lon,$alt,"${name}, ${country}");

			if ($i == 0 || $yr eq $lyr && $mo eq $lmo && $dy eq $ldy)
			{
				$acc += $hr;
				$nacc += 1;
			}
			else
			{
				$mhr = ($nacc == 0) ? $hr : int $acc/$nacc;
				$z = sprintf("%s|%4.4d|%2.2d|%2.2d|%2.2d|%s",
				$uppercode,$lyr,$lmo,$ldy,$mhr,$pos);
	 		 	if ($mhr < 24) { print FILE "${z}\n"; }
				$acc = 0; $nacc = 0;
			}
			$lyr = $yr; $lmo = $mo; $ldy = $dy;
		}
		close(FILE);
	}
}

### Disconnect

&disconnect_db($dbh);
