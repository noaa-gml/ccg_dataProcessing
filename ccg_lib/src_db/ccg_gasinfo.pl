#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# List parameter details
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "parameter|g=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

@param = ();
if ($Options{parameter})
{
   @tmp = split(',',$Options{parameter});
   for ($i=0; $i<@tmp; $i++) { $param[$i] = lc($tmp[$i]); }
} else { &showargs() }

$file = ($Options{outfile}) ? $Options{outfile} : "";
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get list of parameters if -gall 
#######################################
#
if ($param[0] eq 'all') { @param = &get_all_fields("formula","gmd.parameter"); }
#
#######################################
# Get Gas Information
#######################################
#
$n=0;
for ($i=0; $i<@param; $i++)
{
   $select = "SELECT *";
   $from = " FROM gmd.parameter";

   $z = BinByItem('gmd.parameter', 'formula', $param[$i]);

   $where = " WHERE ${z}";

   $sql = $select.$from.$where;

   $sth = $dbh->prepare($sql);
   $sth->execute();

   #
   # Fetch results
   #
   while (@tmp = $sth->fetchrow_array()) { @arr[$n++]=join('|',@tmp) }
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
sub BinByItem()
{
   local($t, $n, @items) = @_;
   my ($z, $i);

   for ($i = 0, $z = ''; $i < @items; $i++)
   { $z = ($z) ?  "${z} OR ${t}.${n}='${items[$i]}'" : "(${t}.${n}='${items[$i]}'"; }

   $z = $z.")";

   return $z;
}

sub showargs()
{
   print "\n#########################\n";
   print "ccg_paraminfo\n";
   print "#########################\n\n";
   print "Create a listing of species or parameter information for the\n";
   print "specified parameter formula(e).\n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-g, -parameter=[parameter(s)]\n";
   print "     paramater formulae\n";
   print "     Specify a single parameter (e.g., -parameter=co2)\n";
   print "     or any number of parameters\n\n";
   print "     (e.g., -parameter=co2,co2c13,co2o18,ch4,co)\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "# Show parameter information for co2\n";
   print "   (ex) ccg_paraminfo -parameter=co2\n\n";
   print "# Show parameter information for co2, co2c13 and mebr\n";
   print "   (ex) ccg_paraminfo -parameter=co2,co2c13,mebr\n\n";
   print "# Show parameter information for all parameters\n";
   print "   (ex) ccg_paraminfo -parameter=all\n\n";
   exit;
}
