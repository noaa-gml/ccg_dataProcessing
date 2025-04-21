#!/usr/bin/perl

use DBI;
use Getopt::Std;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Submit passed query to MySQL and
# send query result to standard out.
#
#######################################
# Initialization
#######################################
#
if (@ARGV ne 1) {exit;}

$sql=$ARGV[0];
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Submit query
#######################################
#
$sth = $dbh->prepare($sql);
$sth->execute();
#
# Fetch results
#
$n=0;
while (@tmp = $sth->fetchrow_array()) { @data[$n++]=join('|',@tmp) }
$sth->finish();
#
#######################################
# Send results to stdout
#######################################
#
foreach $row (@data)
{
   $row =~ s/\r\n/!C/c;
   print $row,"\n";
}

#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);

exit;
