#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Get flask data
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }
#
$noerror = GetOptions(\%Options, "help|h", "id=s", "outfile|o=s");
#
if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

if (!($pfp = $Options{id})) { &showargs() }

$file = $Options{outfile};
#
#######################################
# Initialization
#######################################
#
$t1 = "gmd.site";
$t2 = "pfp_inv";
$t3 = "flask_event";
($pre, $suf) = split("-", $pfp);
$and = "";
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Show Event and Data fields
#######################################
#

$select = "SELECT $t1.code, $t3.date, $t3.time, $t3.id, $t3.me, $t3.lat, $t3.lon, $t3.alt, $t3.num, $t2.path";
$from = " FROM $t1, $t2, $t3";
$where = " WHERE $t2.id LIKE '$pre%'";
$and = "${and} AND $t2.sample_status_num = 3";
$and = "${and} AND $t2.event_num != 0";
$and = "${and} AND $t3.num = $t2.event_num";
$and = "${and} AND $t2.site_num = $t1.num";

$sql = $select.$from.$where.$and;
#print $sql,"\n";

$sth = $dbh->prepare($sql);
$sth->execute();

#
# Fetch results
#
$n=0;
while (@tmp = $sth->fetchrow_array()) { @arr[$n++]=join(' ',@tmp) }
$sth->finish();
#
#######################################
# Write results
#######################################
#
if ($file) { $file = ">${file}"; } else { $file = ">&STDOUT"; }
open(FILE,${file});

foreach $str (@arr) { print FILE "${str}\n"; }
close(FILE);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);

exit;

sub showargs()
{
   print "\n#########################\n";
   print "ccg_pfpinfo\n";
   print "#########################\n\n";
   print "Show PFP information.\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-id=[PFP id]\n";
   print "     Specify PFP id\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "# Show PFP information for PFP ids in 3033-FP\n";
   print "(ex) ccg_pfpinfo -i3033-FP\n";
   exit;
}
