#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Get site binning information if it exists
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "project|p=s", "site|s=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }
if (!($Options{site})) { &showargs() }

$site = $Options{site};
$site =~ tr/A-Z/a-z/;

$proj_abbr = $Options{project};

$outfile = $Options{outfile};

#######################################
# Initialization
#######################################
#
$t1 = "gmd.site";
$t2 = "project";
$t3 = "data_binning";
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get site_num if site is specified 
#######################################
#
$code = substr($site, 0, 3);
$site_num = ($code) ? &get_field("num", "gmd.site", "code", $code) : 0;
#
#######################################
# Get project number if project is specified
# Default: flask
#######################################
#
$proj_num = ($proj_abbr) ? &get_field("num", "project", "abbr", $proj_abbr) : 0;
#
#######################################
# Get binning information
#######################################
#
$select = "SELECT ${t1}.num,${t1}.code,${t3}.project_num";
$select = "${select},${t3}.begin,${t3}.end,${t3}.method,${t3}.min";
$select = "${select},${t3}.max,${t3}.width,${t3}.target_num";

$from = " FROM ${t1},${t2},${t3}";

if ($site_num)
{
   $where = " WHERE ${t1}.num='${site_num}'";
   $and = " AND ${t3}.site_num='${site_num}'";
}
else
{
   $where = " WHERE ${t1}.num=${t3}.site_num";
   $and = "";
}

if ($proj_num)
{
   $and = "${and} AND ${t2}.num='${proj_num}'";
   $and = "${and} AND ${t3}.project_num='${proj_num}'";
}
else
{
   $and = "${and} AND ${t2}.num=${t3}.project_num";
}

$etc = ($code) ? "" : " ORDER BY ${t1}.code";

$sql = $select.$from.$where.$and.$etc;

$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n = 0;
while (@tmp = $sth->fetchrow_array()) { @arr[$n++] = join('|',@tmp) }
$sth->finish();
#
#######################################
# Write results
#######################################
#
$outfile = ($outfile) ? $outfile : "&STDOUT";
open(FILE,">${outfile}");

foreach $row (@arr) { print FILE "${row}\n"; }
close(FILE);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
#
#######################################
# Subroutines
#######################################
#
sub showargs()
{
   print "\n#########################\n";
   print "ccg_binning\n";
   print "#########################\n\n";
   print "Extract binning information (if it exists)\n";
   print "for passed site from DB.\n";
   print "Fields are delimited by pipes (|).\n";
   print "Results are sent to STDOUT.\n";
   print "Use \"-o\" option to redirect output.\n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-p, -project=[project]\n";
   print "     Specify project. Examples: ccg_surface [default],\n";
   print "        ccg_aircraft, etc\n\n";
   print "-s, -site=[site]\n";
   print "     Specify the site\n";
   print "\n";
   print "# List all binning information for SGP\n";
   print "   (ex) ccg_binning -site=sgp\n\n";
   print "# List all binning for ccg_aircraft project at CAR\n";
   print "   (ex) ccg_binning -site=car -project=ccg_aircraft\n";
   exit;
}
