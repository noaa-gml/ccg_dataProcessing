#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Provide all information related to the user-supplied cylinder ID.
#
# July 19, 2007 - kam
# modified 3 March 2011 to allow selecting by instrument code and rejection flag- AMC
#
# Modified 4/16 to allow no id to be passed (wildcard).
#
#######################################
# Parse Arguments
#######################################
#
if ( $#ARGV == -1 ) { &showargs(); }

$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "parameter|p=s", "id|i=s", 
	"instrument|inst=s", "date|d=s", "retained|r=s");

if ( $noerror != 1 ) { exit; }

if ( $Options{help} ) { &showargs() }

#If 1 or more ids were passed, put into a quoted list to use in the where clause below.
my $idlist="";
if ( $Options{id} )
{
   @tmp = split(',', $Options{id});
   for ( $i=0; $i<@tmp; $i++ ) { 
	my $t="'".lc($tmp[$i])."'";
	$idlist.=($idlist)?",$t":$t; 
   }
}


# instrument list
@inst_list = ();

if ( $Options{instrument} )
{
   @tmp = split(',', $Options{instrument});
   for ( $i=0; $i<@tmp; $i++ ) { $inst_list[$i] = uc($tmp[$i]); }
}

# flag
$retained = ( $Options{retained} ) ? 1 : 0;

# parameter

$sp = ( $Options{parameter} ) ? $Options{parameter} : "";

# date range

@date = ();

if ( $Options{date} )
{
   @tmp = split(',', $Options{date});
   for ( $i=0; $i<@tmp; $i++ ) { $date[$i] = lc($tmp[$i]); }
   if ( $#tmp == 0 ) { $date[1] = $date[0] }
}
else { @date = ('1900-01-01', '9999-12-31') }

# output file

$file = ( $Options{outfile} ) ? $Options{outfile} : "";
#
#######################################
# Initialization
#######################################
#
@result = ();
$nres = 0;
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Get site information for each site
#######################################
#
$inst = "";
foreach $inst_code (@inst_list) { $inst = ( $inst eq "" ) ? "(inst='$inst_code'" : "${inst} OR inst='$inst_code'";}
if ( $inst ne "" ) { $inst = "$inst)";}
#print $inst, "\n";

# Get Site information

$and = "";

$select = "SELECT serial_number, date, time, species, mixratio, stddev, num, flag, method, inst";
$from = " FROM reftank.calibrations";
$where = " WHERE 1=1 ";
$and = "${and} AND date BETWEEN '${date[0]}' AND '${date[1]}'";
if ( $sp ) { $and = "${and} AND species='${sp}'" }
if ( $retained ) { $and = "${and} AND flag='.'" }
if ( $idlist) { $and = "${and} and lower(serial_number) in ($idlist)";}
if ( $inst ) { $and = "${and} AND $inst" }

$sql = $select.$from.$where.$and;
$sth = $dbh->prepare($sql);
$sth->execute();

while (@tmp = $sth->fetchrow_array()) { @result[$nres++] = join('|', @tmp) }

$sth->finish();
#print $sql."\n";
#
#######################################
# Write results
#######################################
#
$file = ($file) ? $file : "&STDOUT";
open(FILE,">${file}");

foreach $item (@result) { print FILE "${item}\n"; }
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
   print "ccg_cal.pl\n";
   print "#########################\n\n";
   print "Returns the following fields pertaining to user-supplied cylinder id(s).\n\n";
   print "serial_number, date, time, species, mixratio, stddev, num, flag, method, inst\n\n";
   print "\nOptions:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-i, -id=[id(s)]\n";
   print "     Specify a single cylinder id (e.g., -id=CC64042)\n";
   print "     or any number of ids (e.g., -id=CC64035,CC64052,CC64040).\n";
   print "     If missing then all cylinders are returned.\n";
   print "-p, -parameter=[parameter]\n";
   print "     If not specified, results for all species are returned.\n\n";
   print "-d, -date=[2006-01-02,2006-05-02]\n";
   print "     Constrain results by date range.\n\n";
   print "-r, -retained=1\n";
   print "     Only return retained values\n\n";
   print "-inst, -instrument='inst_code(s)' \n";
   print "     Specify a single instrument id code (e.g., -inst='H5')\n";
   print "     of any number of instrument id codes (e.g., -inst='H5,H4,H6')\n\n"; 
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "(ex) ./ccg_cal.pl -id=CC64042 -par=ch4 -date=2007-06-13\n\n";
   print "(ex) ./ccg_cal.pl -id=CC64042 -par=ch4 -date=2007-06-13 -r=1 -inst='H5,H6'\n\n";
   print "(ex) ./ccg_cal.pl -id=CC64035,CC64052,CC64040 -par=co2 \n\n";
   exit;
}
