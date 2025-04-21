#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Get key
# 
# If user supplies "old-style" primary key return event number
# If user supplies event number return "old-style" primary key
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "eventnum|e=i", "help|h", "outfile|o=s", "primarykey|k=s", "outfile|o=s", "stdout");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

$file = $Options{file};
$stdout = $Options{stdout};

$key = ($Options{primarykey}) ? $Options{primarykey} : '';
$evn = ($Options{eventnum}) ? $Options{eventnum} : '';

if ($key eq '' && $evn eq '') { &showargs(); }

#######################################
# Initialization
#######################################
#
$t1 = "gmd.site";
$t2 = "flask_event";
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Retrieve Data
#######################################
#
if ($evn)
{
   $select = "SELECT ${t1}.code,${t2}.date,${t2}.time,${t2}.id,${t2}.me";
   $select = "${select},${t2}.lat,${t2}.lon,${t2}.alt";
   $select = "${select},${t1}.lst2utc,${t2}.comment";
   $from = " FROM ${t1},${t2}";
   $where = " WHERE ${t2}.num=${evn}";
   $and = " AND ${t1}.num=${t2}.site_num";

   $sql = $select.$from.$where.$and;
}

if ($key)
{
   @field = split(/\s+/,$key);

   $date = sprintf("%04d-%02d-%02d", $field[1], $field[2], $field[3]);

   $select = "SELECT ${t2}.num";
   $from = " FROM ${t1},${t2}";
   $where = " WHERE ${t1}.code='${field[0]}'";
   $and = " AND ${t1}.num=${t2}.site_num";
   $and = "${and} AND ${t2}.date='${date}'";
   $and = "${and} AND HOUR(${t2}.time) = '${field[4]}'";
   $and = "${and} AND MINUTE(${t2}.time) = '${field[5]}'";
   $and = "${and} AND ${t2}.id='${field[6]}'";
   $and = "${and} AND ${t2}.me='${field[7]}'";

   $sql = $select.$from.$where.$and;
}

#print "$sql\n";
$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n=0;
while (@tmp = $sth->fetchrow_array()) { @arr[$n++] = join(' ',@tmp) }
$sth->finish();
#
#######################################
# Write results
#######################################
#
if ($file) { $file = ">${file}"; }
elsif ($stdout) { $file = ">&STDOUT"; }
else { $file = "| vim -"; }
open(FILE,${file});

foreach $str (@arr)
{
   if ($evn) { $str = &eventformat($str); }
   print FILE "${str}\n";
}
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
sub eventformat
{
   local($s)= @_;
   #
   # format record
   #
   @fields = split(/\s+/,$s);
   @ymd_s = split(/-/,$fields[1]);
   @hms_s = split(/:/,$fields[2]);

   $format = "%s %4.4d %2.2d %2.2d %2.2d %2.2d %8s %1s";
   $format = "${format} %8.2f %8.2f %8.2f %4d %s";

   $line = sprintf($format,uc($fields[0]),$ymd_s[0],$ymd_s[1],$ymd_s[2],
         $hms_s[0],$hms_s[1],$fields[3],$fields[4],
         $fields[5],$fields[6],$fields[7],$fields[8]);

   return $line;
}
sub showargs()
{
   print "\n#########################\n";
   print "ccg_getflaskkey\n";
   print "#########################\n\n";
   print "Extract event number if user supplies 'old-style' primary key.\n";
   print "Extract 'old-style' primary key if user supplies event number.\n";
   print "Results are displayed in a \"vi\" session [default].  Enter\n";
   print "\":q!\" to quit session.  Use \"-t\" option to send to STDOUT.\n";
   print "Use \"-o\" option to redirect output.\n\n";
   print "Options:\n\n";
   print "-e, -eventnum=[event number]\n";
   print "     Specify event number.\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]";
   print "     Specify output file\n\n";
   print "-k, -primarykey=[primary key string]\n";
   print "     Specify 'old-style' primary key.  Must include\n";
   print "     code date time id method.\n";
   print "     NOTE: Please put quotations around the string.\n";
   print "     See example below\n\n";
   print "-stdout\n";
   print "     Send result to STDOUT.\n\n";
   print "# Find 'old-style' primary key for event number 182000\n";
   print "   (ex) ccg_getflaskkey -eventnum=182000 -stdout\n\n";
   print "# Find event number for \"LEF 2003 10 08 20 25 203-15 A\"\n";
   print "#    'old-style' primary key\n";
   print "   (ex) ccg_getflaskkey -primarykey=\"BRW 1995 07 21 23 43  6054-66 P\"\n";
   print "           -stdout\n";
   exit;
}
