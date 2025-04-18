#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# ccg_trajprep.pl
#
# This script has gone through a few evolutions
# Prepare files containing events for which we 
# desire trajectories.
#
# Developed.  August 27, 2003 - kam
#
# Modified.   September 2006 - kam
# No longer averages time.  Places all sample events
# in a file.  There now exists a trajectory script
# that reads these files and determines given current
# capabilities, which trajectories are produced.
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "directory|d=s", "help|h", "site|s=s", "save");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

$ddir = ($Options{directory}) ? $Options{directory} : "/ftp/transport/ccgg/events/";

@sitelist = ($Options{site}) ? split ',', lc($Options{site}) : 'all';

$save = $Options{save};

#
#######################################
# Initialization
#######################################
#
$wdir = "/projects/src/db/";

$t1 = "gmd.site";
$t2 = "site_desc";
$t3 = "flask_event";

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get site list from DB
#######################################
#
$select = "SELECT DISTINCTROW ${t1}.num, ${t1}.code, ${t1}.name, ${t1}.country,";
$select = "${select} ${t1}.elev, ${t1}.lat, ${t1}.lon,";
$select = "${select} ${t2}.intake_ht";

$from = " FROM ${t1},${t2} ";

$where = " WHERE ${t1}.num=${t2}.site_num ";
#
# Consider only PFP and network flask data
#
$and = " AND (${t2}.project_num='1' OR ${t2}.project_num='2')";
#
# Site must be active or terminated
#
$and = "${and} AND (${t2}.status_num='1' OR ${t2}.status_num='3')";

$etc = ($code) ? "" : " ORDER BY ${t1}.code";

$sql = $select.$from.$where.$and.$etc;
#print "$sql\n";

$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n = 0; @dbsites = ();
while (@tmp = $sth->fetchrow_array()) { @dbsites[$n ++] = join('|', @tmp) }
$sth->finish();
#
#######################################
# Loop thru site list from DB
#######################################
#
foreach $site (@dbsites)
{
   ($site_num, $code, $name, $country, $elev, $lat, $lon, $ht) = split('\|', $site);
   $elev_ht = int($elev) + int($ht);
   #
   # skip site?
   #
   next if ($sitelist[0] ne "all" && ($z = grep(/$site/i, @sitelist)) == 0);
   #
   # Obtain event details
   #
   $select = "SELECT DISTINCTROW ${t3}.date, ${t3}.time, ${t3}.lat, ${t3}.lon, ${t3}.alt";
   $from = " FROM ${t3}";
   $where = " WHERE ${t3}.site_num = ${site_num}";

   $etc = " ORDER BY ${t3}.date, ${t3}.time";
   $sql = $select.$from.$where.$etc;

   $sth = $dbh->prepare($sql);
   $sth->execute();
   #
   # Fetch results
   #
   $n = 0; @events = ();
   while (@tmp = $sth->fetchrow_array()) { @events[$n ++] = join('|', @tmp) }
   
   next if ($#events < 1);
   #
   # direct output
   #
   $file = ($save) ? $ddir.lc($code).".eve" : "&STDOUT";
   open(FILE, ">${file}");
   #
   # loop through event details
   #
   foreach $event (@events)
   {
      #
      # parse event string
      #
      ($date, $time, $lat, $lon, $alt) = split('\|', $event);
      ($yr, $mo, $dy) = split('-', $date);
      ($hr, $mn, $sc) = split(':', $time);

      next if ($lat < -90);
      next if ($lon < -900);
      next if ($alt < -9000);
      #
      # format output
      #
      # mhd|1999|1|7|13|53.33|-9.9,42|Mace Head, Ireland
      #
      $str = sprintf("%s|%4.4d|%2.2d|%2.2d|%2.2d|%.4f|%.4f|%.2f|%s",
      $code, $yr, $mo, $dy, $hr, $lat, $lon, $alt,"${name}, ${country}");
       
      print FILE $str, "\n";
   }
   close(FILE);
}
#
#######################################
# Disconnect from Database
#######################################
#
&disconnect_db($dbh);
exit;

sub showargs()
{
   print "\n#########################\n";
   print "ccg_trajprep.pl\n";
   print "#########################\n\n";
   print "Prepare files containing events for which we desire trajectories.\n";
   print "Options:\n\n";
   print "-d, -directory\n";
   print "     Destination directory.  Default: /ftp/transport/ccgg/events/.\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-s, -site=[site(s)]\n";
   print "     site code\n";
   print "     Specify a single site (e.g., -site=brw)\n";
   print "     or any number of sites (e.g., -site=rpb,asc)\n\n";
   print "-save\n";
   print "     If specified, output is saved in destination directory. Otherwise\n";
   print "     output is sent to STDOUT\n\n";
   print "# Prepare files for CAR\n";
   print "   (ex) ccg_trajprep.pl -site=scar\n\n";
   print "# Prepare files for TAP and SUM. Save them to /ftp/transport/ccgg/events/\n";
   print "   (ex) ccg_trajprep.pl -site=tap,sum -save\n\n";
   print "# Prepare files for all sites. Save them to /home/ccg/ken/tmp/\n";
   print "   (ex) ccg_trajprep.pl -save -d/home/ccg/ken/tmp/\n\n";
   exit;
}
