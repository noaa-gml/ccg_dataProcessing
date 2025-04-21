#!/usr/bin/perl
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
#
$noerror = GetOptions(\%Options, "help|h", "id=s", "outfile|o=s", "strategy|st=s");
#
if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

$id = $Options{id};

$strategy = ($Options{strategy}) ? $Options{strategy} : 'both';

$file = $Options{outfile};
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# List flasks in analysis loop
#######################################
#
if ($strategy eq 'flask' || $strategy eq 'both')
{
   $select = "SELECT flask_inv.event_num,gmd.site.code,flask_event.date";
   $select = "${select},flask_event.time,flask_event.id,flask_event.me";
   $from = " FROM flask_inv,flask_event,gmd.site";
   $where = " WHERE flask_inv.sample_status_num='3'";
   $and = " AND gmd.site.num=flask_inv.site_num";
   $and = "${and} AND flask_inv.event_num != '0'";
   $and = "${and} AND flask_inv.event_num = flask_event.num";

   if ($id) { $and = "${and} AND flask_inv.id = '${id}'"; }

   $sql = $select.$from.$where.$and;

   $sth = $dbh->prepare($sql);
   $sth->execute();
   #
   # Fetch results
   #
   @flask = ();
   $n = 0;
   while (@tmp = $sth->fetchrow_array()) { @flask[$n++]=join(' ',@tmp) }
   $sth->finish();
}
if ($strategy eq 'pfp' || $strategy eq 'both')
{
   $select = "SELECT pfp_inv.event_num,gmd.site.code,flask_event.date";
   $select = "${select},flask_event.time,flask_event.id,flask_event.me";
   $from = " FROM pfp_inv,flask_event,gmd.site";
   $where = " WHERE pfp_inv.sample_status_num='3'";
   $and = " AND gmd.site.num=pfp_inv.site_num";
   $and = "${and} AND pfp_inv.event_num != '0'";
   $and = "${and} AND pfp_inv.event_num = flask_event.num";

   if ($id)
   {
      ($pre, $suf) = split '-', $id;
      if ($suf =~ /FP/i) { $and = "${and} AND pfp_inv.id LIKE '${pre}-%'"; }
      else { $and = "${and} AND pfp_inv.id='${id}'"; }
   }

   $sql = $select.$from.$where.$and;

   $sth = $dbh->prepare($sql);
   $sth->execute();
   #
   # Fetch results
   #
   @pfp = ();
   $n = 0;
   while (@tmp = $sth->fetchrow_array()) { @pfp[$n++]=join(' ',@tmp) }
   $sth->finish();
}
@arr = ();

push @arr, @flask;
push @arr, @pfp;
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
   print "ccg_inanalysis\n";
   print "#########################\n\n";
   print "Show collection details and event number for ID specified.\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-id=[flask id]\n";
   print "     Specify flask id\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., pfp, flask)\n\n";
   print "# Show PFPs in analysis that have a prefix of 3033\n";
   print "   (ex) ccg_inanalysis -i3033-FP -ppfp\n\n";
   print "# Show flasks in analysis that have an id of 1241-99\n";
   print "(ex) ccg_inanalysis -i1241-99 -pflask\n";
   exit;
}
