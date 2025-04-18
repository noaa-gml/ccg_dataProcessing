#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# List program details
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "program=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

@program_abbrs = ();
if ($Options{program})
{
   @tmp = split(',',$Options{program});
   for ($i=0; $i<@tmp; $i++) { $program_abbrs[$i] = lc($tmp[$i]); }
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
# Get list of programs if -gall 
#######################################
#
if ($program_abbrs[0] eq 'all')
{ @program_abbrs = &get_all_fields("abbr","gmd.program"); }
#
#######################################
# Get Gas Information
#######################################
#
$n=0;
for ($i=0; $i<@program_abbrs; $i++)
{
   $select = "SELECT *";
   $from = " FROM gmd.program";

   $z = BinByItem('gmd.program', 'abbr', $program_abbrs[$i]);

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
   print "ccg_programinfo\n";
   print "#########################\n\n";
   print "Create a listing of program information for the\n";
   print "specified program abbreviation.\n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-program=[program(s)]\n";
   print "     program abbreviation\n";
   print "     Specify a single program (e.g., -program=ccgg)\n";
   print "     or any number of parameters\n\n";
   print "     (e.g., -program=ccgg,arl)\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "# Show program information for ccgg\n";
   print "   (ex) ccg_programinfo -program=ccgg\n\n";
   print "# Show program information for ccgg and arl\n";
   print "   (ex) ccg_programinfo -program=ccgg,arl\n\n";
   print "# Show program information for all programs\n";
   print "   (ex) ccg_programinfo -program=all\n\n";
   exit;
}
