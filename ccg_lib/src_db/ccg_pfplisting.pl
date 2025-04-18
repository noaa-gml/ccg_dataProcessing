#!/usr/bin/perl
#
use DBI;
use Getopt::Std;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# List profiles 
#
# This script is modified to include PFP Id as an input.
# The logic is as follows...
#
# If site is specified return PFP Id and sample date (as before)
# If PFP Id is specified return site and sample date
# Modified June 1, 2010 (kam)
#
#######################################
# Parse Arguments
#######################################
#
&getopts('hi:o:s:');

if ($opt_h) { &showargs() }

@code = ();

if ( $opt_s )
{
        @tmp = split(',',$opt_s);
        for ($i=0; $i<@tmp; $i++) { $code[$i] = lc($tmp[$i]); }
}

@id = ();

if ( $opt_i )
{
        @tmp = split(',',$opt_i);
        for ($i=0; $i<@tmp; $i++) { $id[$i] = lc($tmp[$i]); }
}

# site or ID must be set

if ( $#code == (-1) && $#id == (-1) ) { &showargs() }

# site and ID cannot BOTH be set

if ( $#code != (-1) && $#id != (-1) ) { &showargs() }

$file = $opt_o;
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

if ( $#code >= 0 )
{

   #
   #######################################
   # Get site_num for specified sites
   #######################################
   #
   @site_num = ();
   for ($i=0; $i<@code; $i++)
   {
      $z = &get_field("num","gmd.site","code",$code[$i]);
      if ($z == 0) {die("${code[$i]} not found in DB\n")}
      $site_num[$i] = $z;
   }
   #
   #######################################
   # Get PFP data
   #######################################
   #
   $t = "flask_event";
   $select = "SELECT DISTINCTROW date, SUBSTRING_INDEX(id,'-',1)";
   $from = " FROM ${t}";

   for ($i=0,$or=''; $i<@site_num; $i++)
   { $or = ($or) ?  "${or} OR ${t}.site_num='${site_num[$i]}'" : "(${t}.site_num='${site_num[$i]}'"; }
   $where = ($or) ? " WHERE ${or})" : " WHERE ${t}.site_num";

   $and = " AND project_num='2'";

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
}

if ( $#id >= 0 )
{

   #
   #######################################
   # Get Site data for specified PFP IDs
   #######################################
   #
   $t = "flask_event";
   $select = "SELECT DISTINCTROW date, site_num, gmd.site.code, SUBSTRING_INDEX(id,'-',1)";
   $from = " FROM ${t}, gmd.site";

   for ($i=0,$or=''; $i<@id; $i++)
   {

      ( $pre, $suf ) = split( '-', $id[$i] );
      $or = ($or) ?  "${or} OR ${t}.id LIKE '${pre}-%'" : "(${t}.id LIKE '${pre}-%'"; }

   $where = ($or) ? " WHERE ${or})" : " WHERE ${t}.id";

   $and = " AND strategy_num='2'";
   $and = "${and} AND gmd.site.num = flask_event.site_num";

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
}
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
	print "ccg_pfplisting\n";
	print "#########################\n\n";
	print "IF site code is specified, return PFP ID and sample date.\n";
	print "IF PFP Id is specified, return site code and sample date.\n";
	print "Options:\n\n";
	print "s    Site code\n";
	print "h    Produce help menu.\n";
	print "i    PFP Id (e.g., 3152-FP).\n";
	print "o    Specify output file.  If not specified use STDOUT.\n\n";
	print "(ex) ccg_pfplisting -scar\n\n";
	print "(ex) ccg_pfplisting -snha -o/tmp/test\n\n";
	print "(ex) ccg_pfplisting -i3152-FP\n\n";
	exit;
}
