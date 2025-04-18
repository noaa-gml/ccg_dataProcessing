#!/usr/bin/perl
#
# Listing dates for discrete events from flask_event by project and site
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# List profiles 
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "parameter|g=s", "project|p=s", "program=s", "quiet", "site|s=s", "strategy|st=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs(); }

$file = $Options{outfile};

@parameters = ();
if ( $Options{parameter} )
{
   @tmp = split(',',$Options{parameter});
   for ($i=0; $i<@tmp; $i++) { $parameters[$i] = lc($tmp[$i]); }
}

$project_abbr = ( $Options{project} ) ? $Options{project} : '';

@programs = ();
if ( $Options{program} )
{
   @tmp = split(',',$Options{program});
   for ($i=0; $i<@tmp; $i++) { $programs[$i] = lc($tmp[$i]); }
}

$quiet = ($Options{quiet}) ? 1 : 0;

@sites = ();
if ( $Options{site} )
{
   @tmp = split(',',$Options{site});
   for ($i=0; $i<@tmp; $i++)
   {
      if ( $tmp[$i] eq 'all' )
      {
         @sites = ();
         last;
      }
      $sites[$i] = lc($tmp[$i]);
   }
} else { &showargs(); }

if ( $Options{strategy} )
{ $strategy_abbr = $Options{strategy}; }
else { &showargs(); }

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

$t1 = "flask_event";
$t2 = "flask_data";
$t3 = "gmd.site";

#
# Build the parameter part of the WHERE statement
#

$where = ' WHERE 1=1';

#
# Parameter
#
if ( $#parameters > -1 )
{
   @sqlarr = ();
   foreach $parameter ( @parameters )
   {
      $parameter_num = &get_field("num","gmd.parameter","formula",$parameter);
      if ($parameter_num == 0 && !$quiet) {die("${parameter} not found in parameter table of DB\n")}

      push(@sqlarr,"${t2}.parameter_num='${parameter_num}'");

   }
   $where = $where.' AND ( '.join(' OR ', @sqlarr).' ) ';
}

if ( $project_abbr ne '' )
{
   #
   # Project
   #
   $project_num = &get_field("num","project","abbr",$project_abbr);
   
   if ( ! $quiet )
   {
      if ( $project_num == 0 )
      { die ("Project '${project_abbr}' not found in project table of DB\n")}
      elsif ( $project_num != 1 && $project_num != 2 )
      {
         print "This program is only useful for discrete sampling\n";
         exit;
      }
   }

   $where = $where." AND ${t1}.project_num = '$project_num'";
}

#
# Program
#
if ( $#programs > -1 )
{
   @sqlarr = ();
   foreach $program ( @programs )
   {
      $program_num = &get_field("num","gmd.program","abbr",$program);
      if ($program_num == 0 && !$quiet) {die("${program} not found in program table of DB\n")}

      push(@sqlarr,"${t2}.program_num='${program_num}'");

   }
   $where = $where.' AND ( '.join(' OR ', @sqlarr).' ) ';
}

#
# Strategy
#
$strategy_num = &get_field("num","strategy","abbr",$strategy_abbr);

if ( ! $quiet )
{
   if ( $strategy_num == 0 )
   { die ("Strategy '${strategy_abbr}' not found in strategy table of DB\n")}
   elsif ( $strategy_num != 1 && $strategy_num != 2 )
   {
      print "This program is only useful for discrete sampling\n";
      exit;
   }
}

$where = $where." AND ${t1}.strategy_num = '$strategy_num'";

#
# Site
#
if ( scalar $#sites > -1 )
{
   @sqlarr = ();
   foreach $site ( @sites )
   {
      $code = substr($site,0,3);
      $site_num = &get_field("num","gmd.site","code",$code);
      if ($site_num == 0 && !$quiet)
      {die("Site '${code}' not found in site table of DB\n")}
   
      $sqltmp = "(${t1}.site_num='$site_num'";

      #
      # Get binning information
      #
      &get_bin_params($site, $proj_abbr, *min, *max, *binby);
   
      if ( $binby ne '' )
      {
         push(@sqlarr,"(${t1}.site_num='$site_num' AND (${t1}.${binby} >= ${min} AND ${t1}.${binby} <= ${max}))"); 
      }
      else
      { push(@sqlarr,"${t1}.site_num='$site_num'"); }
   }
   $where = $where.' AND ( '.join(' OR ', @sqlarr).' ) ';
}

#print "$where\n";

#
# Build query
#

$select = "SELECT DISTINCTROW ${t1}.date";
if ( $strategy_num == 2 ) { $select = "$select, SUBSTRING_INDEX(id,'-',1)"; }
$select = "$select, site.code";

if ( $#parameters > -1 || $#programs > -1 )
{
   $from = " FROM ${t1}, ${t2}, ${t3}";
   $where = $where." AND ${t1}.num = ${t2}.event_num";
   $where = $where." AND ${t1}.site_num = ${t3}.num";
}
else
{
   $from = " FROM ${t1}, ${t3}";
   $where = $where." AND ${t1}.site_num = ${t3}.num";
}

$order = " ORDER BY date";
$sql = $select.$from.$where.$order;

#print "$sql\n";

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
$file = ($file) ? $file : "&STDOUT";
open(FILE,">${file}");

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
   print "ccg_eventlist\n";
   print "#########################\n\n";
   print "Create a listing of event dates\n";
   print "Note: If project is PFP, then query also shows the PFP IDs\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-g, -parameter\n";
   print "     paramater formulae\n";
   print "     Specify a single parameter (e.g., -parameter=co2)\n";
   print "     or any number of parameters\n";
   print "     (e.g., -parameter=co2,co2c13,co2o18,ch4,co)\n\n";
   print "-p, -project=[project]\n";
   print "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n\n";
   print "-program=[program]\n";
   print "     Required. Specify a program.\n";
   print "     (e.g., ccgg, arl, hats)\n\n";
   print "-quiet\n";
   print "     Do not print errors.\n\n"; 
   print "-s, -site=[site(s)]\n";
   print "     Required. site code\n";
   print "     Specify a single site (e.g., -site=brw)\n";
   print "     or any number of sites (e.g., -site=rpb,asc)\n";
   print "     Binned sites may be specified by name (e.g.,\n";
   print "     'pocn30', 'car030' where 030 equals 30 * 1000 masl)\n";
   print "     or constructed using the '-event' option (e.g., -event=lat:27.5,32.5,\n";
   print "     -event=alt:2500,3500).\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Required. Specify a strategy. (e.g., -strategy=pfp)\n";
   print "# Show all event dates for CAR\n";
   print "(ex) ccg_eventlist -site=car\n\n";
   print "# Show all event dates for CAR where co2 or ch4 was measured\n";
   print "(ex) ccg_eventlist -site=car -parameter=co2,ch4\n\n";
   print "# Show all event dates for all sites that have project ccg_surface\n";
   print "(ex) ccg_eventlist -site=all -project=ccg_surface\n\n";
   print "# Show all event dates for all sites that have project ccg_aircraft\n";
   print "#    and strategy pfp\n";
   print "(ex) ccg_eventlist -site=all -strategy=pfp -project=ccg_aircraft\n\n";
   print "# Show all event dates for CAR that have project ccg_aircraft\n";
   print "#    and strategy pfp. Use only the 030 bin\n";
   print "(ex) ccg_eventlist -site=car030 -strategy=pfp -project=ccg_aircraft\n\n";
   print "# Show all event dates for NHA. Write the output to /tmp/test\n";
   print "(ex) ccg_eventlist -site=nha -outfile=/tmp/test\n";
   exit;
}
