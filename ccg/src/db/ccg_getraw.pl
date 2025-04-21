#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Construct raw data table
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "noheader", "outfile|o=s", "rawfile|r=s", "stdout");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }
if (!$Options{rawfile}) { &showargs() }

$noheader = ($Options{noheader}) ? 1 : 0;

$rawfile = $Options{rawfile};
$file = $Options{outfile};
$stdout = $Options{stdout};
#
#######################################
# Initialization
#######################################
#
$t0 = "gmd.site";
$t1 = "flask_event";
$format = "%s %10s %8s %10s %1s %s";

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get Event Information
#######################################
#
$select = "SELECT ${t0}.code,${t1}.date,${t1}.time";
$select = "${select},${t1}.id,${t1}.me";
$from = " FROM ${t0},${t1}";
$where = " WHERE ${t0}.num=${t1}.site_num";
#
# format record
#
open(FILE, $rawfile) || die "Can't open file $rawfile.\n";
@rows = <FILE>;
close(FILE);
chop(@rows);

$dbh = &connect_db();

$n = 0;
@arr = ();

foreach $row (@rows)
{
   @fields = split ' ', $row;

   if ($fields[0] eq "SMP")
   {
      $and = " AND ${t1}.num = ${fields[1]}";
      $sql = $select.$from.$where.$and;
      $sth = $dbh->prepare($sql);
      $sth->execute();
      @tmp = $sth->fetchrow_array();
      $sth->finish();
      $row = sprintf($format,$tmp[0],$tmp[1],$tmp[2],$tmp[3],$tmp[4],
      join(' ',@fields[2..$#fields]));
   }
   elsif ($fields[0] eq "REF" || $fields[0] eq "TRP" || $fields[0] eq "STD")
   {
      @tmp = grep /$fields[1]:/, @rows;
      ($label, $sn) = split(/:/, $tmp[0]);
      $sn =~ s/\s+//;

      if ($sn eq "") { $sn = 'na'; }

      $row = sprintf($format,'REF','1900-01-01','00:00:00',$sn,'A',
      join(' ',@fields[2..$#fields]));
   }
   $arr[$n++] = $row;
}
#
# Remove header information ?
#
if ($noheader)
{
   for ($i = 0; $i < @arr; $i ++)
   {
      last if (($z = grep(/^;+/, $arr[$i])) != 0);
      last if (($z = grep(/^\*/, $arr[$i])) != 0);
   }
   @arr = @arr[ $i + 1 .. $#arr];
}
#
#######################################
# Write results
#######################################
#
if ($file) { $file = ">${file}"; }
elsif ($stdout) { $file = ">&STDOUT"; }
else { $file = "| vim -"; }
open(FILE,${file});

foreach $str (@arr) { print FILE "${str}\n"; }
close(FILE);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);

sub showargs()
{
   print "\n#########################\n";
   print "ccg_getraw\n";
   print "#########################\n\n";
   print "Show flask/pfp raw file.\n";
   print "Results are displayed in a \"vi\" session [default].  Enter\n";
   print "\":q!\" to quit session.  Use \"-t\" option to send to STDOUT.\n";
   print "Use \"-o\" option to redirect output.\n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-noheader\n";
   print "     Exclude header information\n\n";
   print "-o, -outfile=[outfile]";
   print "     Specify output file\n\n";
   print "-r, -rawfile=[rawfile]";
   print "     Specify raw file to view\n\n";
   print "-stdout\n";
   print "     Send result to STDOUT.\n\n";
   print "# Show raw file /projects/co2/flask/L3/raw/2004/2004-08-31.1314.co2. Send\n";
   print "#    results to STDOUT\n";
   print "   (ex) ccg_getraw -r=/projects/co2/flask/L3/raw/2004/2004-08-31.1314.co2\n";
   print "           -stdout\n\n";
   exit;
}
