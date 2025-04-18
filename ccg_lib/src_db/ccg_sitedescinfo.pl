#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Get site definition for one or all sampling locations
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "project|p=s", "site|s=s", "strategy|st=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

$site = $Options{site};
$site =~ tr/A-Z/a-z/;

$code = substr($site,0,3);

$proj_abbr = ($Options{project});
$strat_abbr = ($Options{strategy});

$file = $Options{outfile};

#######################################
# Initialization
#######################################
#
$t1 = "gmd.site";
$t2 = "site_desc";
$t3 = "project";
$t4 = "status";
$t5 = "strategy";
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get proj_num if proj_abbr is specified 
#######################################
#
$proj_num = ($proj_abbr) ? &get_field("num",$t3,"abbr",$proj_abbr) : 0;
#
#######################################
# Get strat_num if strat_abbr is specified 
#######################################
#
$strat_num = ($strat_abbr) ? &get_field("num",$t5,"abbr",$strat_abbr) : 0;
#
#######################################
# Is this a binned site?
#######################################
#
&get_bin_params($site,$proj_abbr,*min,*max,*binby);
#
#######################################
# Get site_num if site is specified 
#######################################
#
$z = ($binby ne 'alt') ? $site : $code;

$site_num = ($code) ? &get_field("num",$t1,"code",$z) : 0;

if ( $site_num eq '' ) { die "No related information found in DB.\n"; }

#
#######################################
# Get site information
#######################################
#
$select = "SELECT DISTINCTROW ${t1}.num,${t1}.code,${t1}.name,${t1}.country";
$select = "${select},${t1}.lat,${t1}.lon,${t2}.intake_ht";
$select = "${select},${t1}.elev,${t1}.lst2utc,${t3}.abbr,${t4}.name,${t5}.abbr";

$from = " FROM ${t1},${t2},${t3},${t4},${t5}";

if ($site_num)
{
   $where = " WHERE ${t1}.num='${site_num}'";
   $and = " AND ${t2}.site_num='${site_num}'";
}
else
{
   $where = " WHERE ${t1}.num=${t2}.site_num";
   $and = "";
}

if ( $proj_num ) { $and = "${and} AND ${t2}.project_num='${proj_num}'"; }
if ( $strat_num ) { $and = "${and} AND ${t2}.strategy_num='${strat_num}'"; }

$and = "${and} AND ${t2}.project_num = ${t3}.num";
$and = "${and} AND ${t2}.strategy_num = ${t5}.num";
$and = "${and} AND ${t2}.status_num = ${t4}.num";

$etc = ($code) ? "" : " ORDER BY ${t1}.code";

$sql = $select.$from.$where.$and.$etc;

$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n=0;
while (@tmp = $sth->fetchrow_array()) { @arr[$n++] = join('|',@tmp) }
$sth->finish();

if ( $#arr == -1 ) { die "No related information found in DB.\n" }

#
# Add the binning information if the site is a binned site
#
$n = 0;
foreach $row (@arr)
{
   @field = split(/\|/, $row);

   if ( $field[10] eq 'Binned' || $field[9] eq 'ccg_aircraft' )
   {
      &get_bin_params($site,$field[9],*min,*max,*binby);
      $row = join('|',$row,$binby,$min,$max);
   }

   $alt = substr($site,3);
   if ( $field[9] eq 'ccg_surface' && $field[11] eq 'Flask' && $alt ne '' )
   {
      $elev = $alt - $field[6];
      $elev = sprintf("%.2f", $elev);
      #print "$elev\n";
      $field[7] = $elev;
      $row = join('|',@field);
   }
   $outarr[$n++] = $row;
}

#
#######################################
# Write results
#######################################
#
$file = ($file) ? $file : "&STDOUT";
open(FILE,">${file}");

foreach $row (@outarr) { print FILE "${row}\n"; }
close(FILE);
### Disconnect

&disconnect_db($dbh);
#
#######################################
# Subroutines
#######################################
#
sub showargs()
{
   print "\n#########################\n";
   print "ccg_siteinfo\n";
   print "#########################\n\n";
   print "Creates a list of sites from the ccgg database\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-p, -project=[project]\n";
   print "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n";
   print "     If project is not found in the database, option is\n";
   print "     ignored\n\n";
   print "-s, -site=[site]\n";
   print "     Specify the site\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., pfp, flask)\n\n";
   print "     If strategy is not found in the database, option is\n";
   print "     ignored\n\n";
   print "# List all ccg_surface site information\n";
   print "   (ex) ccg_siteinfo -project=ccg_surface\n\n";
   print "# List information for project ccg_surface at ALT\n";
   print "   (ex) ccg_siteinfo -project=ccg_surface -site=alt\n\n";
   print "# List information for project ccg_surface at ALT. Direct the\n";
   print "#    output to info.txt\n";
   print "   (ex) ccg_siteinfo -project=ccg_surface -site=alt -outfile=info.txt\n";
   exit;
}

