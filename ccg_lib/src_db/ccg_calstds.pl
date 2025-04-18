#!/usr/bin/perl
#
use DBI;
use Getopt::Long;


# Written on 2009-05-21 - dyc
# This code is very similar to /data/www/gmd-int/http/gmd/dv/ccg/refgas/refgas.php
#

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
#
#######################################
# Parse Arguments
#######################################
#
$noerror = GetOptions(\%Options, "help|h", "infile|i=s", "outfile|o=s", "parameter|g=s", "shownames", "stdout");

if ( $noerror != 1 ) { exit; }

if ( $Options{help} ) { &showargs(); }

if ( ! $Options{infile}) { &showargs; }
if ( ! $Options{parameter}) { &showargs; }

$infile = $Options{infile};
$outfile = $Options{outfile};
$parameter = $Options{parameter};
$stdout = $Options{stdout};
$shownames = ($Options{shownames}) ? 1 : 0;

@result = ();

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

# Temprorary table name
$tt_calibrations = "z".int(10**8*rand());

# Read input file
open(INPUTFILE, $infile);
@arr = <INPUTFILE>;
close(INPUTFILE);

# Loop through each line of the input file
foreach $line ( @arr )
{

   # Skip comment lines
   if ( $line =~ m/^#/ ) { next; }

   chomp($line);

   #print "$line\n";

   @nvpairs = split(/\|\|/, $line);

   %inputaarr = {};
   foreach $nvpair ( @nvpairs )
   {
      ($name, $value) = split(/:/, $nvpair, 2);
      $inputaarr{$name} = $value;
   }

   # If we don't have the required fields then skip this line 
   if ( $inputaarr{"installed"} eq undef ) { next; }
   if ( $inputaarr{"serial"} eq undef ) { next; }

   ($date,$time) = split(/T/, $inputaarr{"installed"});
   ($yr,$mo,$dy) = split(/-/, $date);

   # Correct any default values
   $mo = ( $mo eq '99' ) ? '12' : $mo;
   $dy = ( $dy eq '99' ) ? '31' : $dy;

   # Create the database formatted dates
   $dbdate = sprintf("%04d-%02d-%02d", $yr, $mo, $dy);
   $dbdd = &date2dec($yr, $mo, $dy, 12, 0);

   #
   # Get all of the fill dates and fill codes
   #
   $select = " SELECT date, code";
   $from = " FROM reftank.fill";
   $where = " WHERE serial_number = '".$inputaarr{"serial"}."'";
   $etc = " ORDER BY date";
   $sql = $select.$from.$where.$etc;

   #print "$sql\n";
   $sth = $dbh->prepare($sql);
   $sth->execute();

   @fillinfos = (); $nfillinfos = 0;
   while (@tmp = $sth->fetchrow_array()) { @fillinfos[$nfillinfos++] = join("|",@tmp) }
   $sth->finish();

   # Add a default 'A' fill date and code if none are in the database
   #  This was added based on refgas.php
   if ( $#fillinfos < 0 )
   { push(@fillinfos, '1900-01-01|A'); }

   #
   # Add a final fill date and default fill code
   #
   push(@fillinfos, '9999-12-31|ZZ');

   $fillcode = 'ZZ';
   # Loop through the fill information
   for ( $i=0; $i<$#fillinfos; $i++ )
   {
      if ( $fillinfos[$i] eq '9999-12-31' ) { last; }

      ($curfilldate, $curfillcode) = split(/\|/, $fillinfos[$i]);
      ($nextfilldate, $nextfillcode) = split(/\|/, $fillinfos[$i+1]);

      #print "$fillinfos[$i] $fillinfos[$i+1]\n";

      $curfilldd = &date2dec(split(/-/, $curfilldate), 12, 0);
      $nextfilldd = &date2dec(split(/-/, $nextfilldate), 12, 0);

      #print "$curfilldd $nextfilldd\n";

      if ( $dbdd > $curfilldd && $dbdd < $nextfilldd ) { $fillcode = $curfillcode; }

      # Insert the calibration information into a temporary table
      #  but with the fill code at the end
      $create = " CREATE TEMPORARY TABLE IF NOT EXISTS ${tt_calibrations} (INDEX (date))";
      $select  = " SELECT date,mixratio,stddev,location,pressure,inst,flag,'$curfillcode' as fillcode";
      $from = " FROM reftank.calibrations";
      $where = " WHERE serial_number='".$inputaarr{"serial"}."' AND species='$parameter'";
      $and = " AND date >= '$curfilldate'  AND date < '$nextfilldate'";
      $and = $and." AND flag = '.'";

      if ( lc($parameter) eq 'co2' )
      {
         $and = $and." AND location='BLD'"; 
         $and = $and." AND inst != 'L8' AND inst != 'L3' AND inst != 'L4'";
      }
      elsif ( lc($parameter) eq 'ch4' )
      {
         $and = $and." AND inst = 'H5'";
      }

      $etc = " ORDER BY date";
      $sql = $create.$select.$from.$where.$and.$etc;

      #print "$sql\n";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();

#      print "$sql\n";
#      $sth = $dbh->prepare($sql);
#      $sth->execute();
#
#      @calibrations = (); $ncalibrations = 0;
#      while (@tmp = $sth->fetchrow_array())
#      { @calibrations[$ncalibrations++] = join(" ",@tmp) }
#      $sth->finish();
#
   }

#
#   Print all of the calibration information for the specific serial_number, parameter
#
#   $sql = " SELECT * FROM ${tt_calibrations}";
#   print "$sql\n";
#   $sth = $dbh->prepare($sql);
#   $sth->execute();
#
#   @calibrations = (); $ncalibrations = 0;
#   while (@tmp = $sth->fetchrow_array())
#   { @calibrations[$ncalibrations++] = join(" ",@tmp) }
#   $sth->finish();
#
#   foreach $calibration ( @calibrations )
#   {
#      print $calibration."\n";
#   }

   #print "FILLCODE: $fillcode\n";

   #$sql = " SELECT * FROM ${tt_calibrations} WHERE fillcode = '$fillcode'";
   ##print "$sql\n";
   #$sth = $dbh->prepare($sql);
   #$sth->execute();
   #
   #@calibrations = (); $ncalibrations = 0;
   #while (@tmp = $sth->fetchrow_array())
   #{ @calibrations[$ncalibrations++] = join(" ",@tmp) }
   #$sth->finish();
   #
   #foreach $calibration ( @calibrations )
   #{
   #   print $calibration."\n";
   #}

   #
   # Get the average of the mixing ratio, standard deviation, and the
   #  count of the number of calibrations before the tank was in use
   #  for a specific fill code
   #
   @bcalibrationsinfo = ();
   $select = " SELECT AVG(mixratio), STD(mixratio), COUNT(*)";
   $from = " FROM ${tt_calibrations}";
   $where = " WHERE fillcode = '$fillcode'";
   $and = " AND date <= '${dbdate}'";
   $etc = " ORDER BY date";
   $sql = $select.$from.$where.$and.$etc;

   #print "$sql\n";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   @bcalibrationsinfo = $sth->fetchrow_array();
   $sth->finish();

   # If nothing was found, then set some defaults
   if ( $bcalibrationsinfo[2] < 1 )
   {
      @bcalibrationsinfo = ( '-999.99', '-9.99', '-1');
   }

   #
   # Get the average of the mixing ratio, standard deviation, and the
   #  count of the number of calibrations after the tank stopped being
   #  used. Query based on a specific fill code
   #
   @ecalibrationsinfo = ();
   $select = " SELECT AVG(mixratio), STD(mixratio), COUNT(*)";
   $from = " FROM ${tt_calibrations}";
   $where = " WHERE fillcode = '$fillcode'";
   $and = " AND date > '${dbdate}'";
   $etc = " ORDER BY date";
   $sql = $select.$from.$where.$and.$etc;

   #print "$sql\n";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   @ecalibrationsinfo = $sth->fetchrow_array();
   $sth->finish();

   # If nothing was found, then set some defaults
   if ( $ecalibrationsinfo[2] < 1 )
   {
      @ecalibrationsinfo = ( '-999.99', '-9.99', '-1');
   }

   if ( $inputaarr{"site"} eq undef ) { $inputaarr{"site"} = 'ZZZ'; }
   if ( $inputaarr{"transducer"} eq undef ) { $inputaarr{"transducer"} = 'ZZZ'; }
   if ( $inputaarr{"coef0"} eq undef ) { $inputaarr{"coef0"} = -999.9; }
   if ( $inputaarr{"desc"} eq undef ) { $inputaarr{"desc"} = 'ZZZ'; }

   @headers = ( 'date', 'serial', 'fillcode', 'average', 'stddev', 'number', 'average', 'stddev', 'number', 'site', 'transducer','coef0', 'desc');
   $outputline = sprintf("%10s %12s %2s %7.2f %6.2f %2d %7.2f %6.2f %2d %8s %5s %7.2f %20s", $dbdate, $inputaarr{"serial"}, $fillcode, @bcalibrationsinfo, @ecalibrationsinfo, $inputaarr{"site"}, $inputaarr{"transducer"}, $inputaarr{"coef0"}, $inputaarr{"desc"});
   #print $outputline."\n";
   push(@result, $outputline);

   $sql = " DELETE FROM ${tt_calibrations}";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();
   
}
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);

#
#######################################
# Write results
#######################################
#
if ($outfile) { $outfile = ">${outfile}"; }
elsif ($stdout) { $outfile = ">&STDOUT"; }
else { $outfile = "| vim -"; }
open(FILE,${outfile});

if ( $shownames ) { print FILE join(' ',@headers)."\n"; }
foreach $str (@result) { print FILE "${str}\n"; }
close(FILE);

exit;

#
#######################################
# Subroutines
#######################################
#

sub showargs()
{
   print "\n#########################\n";
   print "ccg_calstds.pl\n";
   print "#########################\n\n";
   print "This program returns the fill code, average mixing ratio and standard.\n";
   print "deviation of the mixing ratio(s) for before the calibration tank was\n";
   print "used and after it was used.\n";
   print " (ex) serial:CC1788||installed:2001-01-01T00:00:00||\n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-infile=[infile]\n";
   print "     REQUIRED. Specify an input file.\n";
   print "     The input file should contain the beginning date for when the tank\n";
   print "     was used, the ending date, and the calibration tank id. One row for\n";
   print "     each entry.\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-p, -parameter=[parameter]\n";
   print "     REQUIRED. Specify a parameter.\n\n";
   print "-shownames\n";
   print "     Print the field names as the first line of the output. A\n";
   print "     space is used to deliminate the field names.\n\n";
   print "-stdout\n";
   print "     Send result to STDOUT.\n\n";
   print "(ex) ./ccg_calstds.pl -infile=stds.dat -parameter=co2\n\n";
   print "(ex) ./ccg_calstds.pl -infile=stds.dat -parameter=co2 -stdout\n\n";
   print "(ex) ./ccg_calstds.pl -infile=stds.dat -parameter=co2 -outfile=out.dat\n\n";
   exit;
}
