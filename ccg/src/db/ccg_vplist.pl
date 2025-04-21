#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/validator.pl";
require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/validator.pl";

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

$noerror = GetOptions(\%Options, "date=s", "help|h", "outfile|o=s", "quiet", "site|s=s", "strategy|st=s", "time=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs(); }
if ( ! $Options{site}) { &showargs(); }

$date = $Options{date};
$time = $Options{time};
$code = $Options{site};
$file = $Options{outfile};
$strat_abbr = $Options{strategy};
$quiet = ($Options{quiet}) ? 1 : 0;

#
# Find the site number and project number
#
$proj_abbr = 'ccg_aircraft';
@lastdom = ( 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

$site_num = &get_field("num","gmd.site","code",$code);
if ($site_num == 0 && !$quiet)
{die("Site '${code}' not found in site table of DB\n")}

$proj_num = &get_field("num","project","abbr",$proj_abbr);

if ( $strat_abbr )
{ $strat_num = &get_field("num","ccgg.strategy","abbr",$strat_abbr); }
else
{ $strat_num = 0;}

#
# Get a list of all events for the site, project
#
$select = " SELECT SUBSTRING_INDEX(id,'-',1), date, time";
$from = " FROM flask_event";
$where = " WHERE site_num = '".$site_num."' and project_num = '".$proj_num."'";

if ( $strat_num > 0 )
{
   $where = $where." AND strategy_num = '".$strat_num."'";
}

$etc = " ORDER BY date, time";

#
# Apply an initial date range constraint if the date constraint is set.
# More elaborate checking occurs later
#
if ( $date ne '' )
{
   @chkdate = split(/-/, $date);

   if ( $chkdate[2] ne '' )
   {
      #YYYY-MM-DD
      $where = "$where AND ABS(DATEDIFF(date,'$date')) <= 1";
   }
   elsif ( $chkdate[1] ne '' )
   {
      #YYYY-MM
      $where = "$where AND DATEDIFF(date,'$date-01') BETWEEN -1 AND 35";
   }
   else
   {
      #YYYY
      $where = "$where AND DATEDIFF(date,'$date-01-01') BETWEEN -1 AND 370";
   }
}

$sql = $select.$from.$where.$etc;
#print "$sql\n";

$sth = $dbh->prepare($sql);
$sth->execute();

#
# Fetch results
#
$n=0;
@events = ();
while (@tmp = $sth->fetchrow_array()) { @events[$n++]=join('|',@tmp) }
$sth->finish();

#
# The first entry is the beginning of the first flight
#
$begin = $events[0];
($bid, $bdate, $btime) = split(/\|/, $begin);
($byr, $bmo, $bdy) = split(/-/, $bdate);
($bhr, $bmn, $bsc) = split(/:/, $btime);

#
# Loop through the event list, starting from the second entry
#
for ( $i=1; $i<=$#events; $i++ )
{
   $enddatefound = 0;
   ($previd, $prevdate, $prevtime) = split(/\|/, $events[$i-1]);
   ($prevyr, $prevmo, $prevdy) = split(/-/, $prevdate);
   ($prevhr, $prevmn, $prevsc) = split(/:/, $prevtime);

   ($curid, $curdate, $curtime) = split(/\|/, $events[$i]);
   ($curyr, $curmo, $curdy) = split(/-/, $curdate);
   ($curhr, $curmn, $cursc) = split(/:/, $curtime);

   #print "$curid $previd\n";
   $curdd = &date2dec($curyr, $curmo, $curdy, $curhr, $curmn, $cursc);
   $prevdd = &date2dec($prevyr, $prevmo, $prevdy, $prevhr, $prevmn, $prevsc);

   #
   #    If the current id is not equal to the previous id and there is a gap
   # of more than 1 hours, then we have found the end of one flight.
   # Otherwise, if there is a gap of 8 hours then we have found the end of
   # a flight.
   #
   if ( $curid ne $previd && ( $curdd - $prevdd ) > ( 1.5 * 0.000114155 ) )
   {
      $enddatefound++;
   }
   elsif ( ( $curdd - $prevdd ) > ( 8 * 0.000114155 ) )
   {
      $enddatefound++;
   }

   #
   # If the end of a flight has been found, or it is the last element in the array
   #
   if ( $enddatefound || $i == $#events ) 
   {
      # Add to the flights array
      $end = $events[$i-1];
      @bfields = split(/\|/, $begin);
      @efields = split(/\|/, $end);

      # If a time constraint is set, check it
      if ( $time ne '' )
      {
         $timecheck = 0;
         if ( $bfields[1] eq $efields[1] )
         { $timecheck = &datetimebetween($bfields[1], $bfields[2], $efields[1], $efields[2], $bfields[1], $time); }
         elsif ( $bfields[1] ne $efields[1] )
         {
            if ( $time eq $bfields[2] || $time eq $efields[2] )
            {
               $timecheck = 1;
            }
            elsif ( $time gt $bfields[2] )
            { $timecheck = &datetimebetween($bfields[1], $bfields[2], $efields[1], $efields[2], $bfields[1], $time); }
            elsif ( $time lt $efields[2] )
            { $timecheck = &datetimebetween($bfields[1], $bfields[2], $efields[1], $efields[2], $efields[1], $time); }
         }
      }

      # If a date constraint is set, check it
      if ( $date ne '' )
      {
         $datecheck = 0;
         @dfields = split(/-/, $date);

         if ( $#dfields == 2 )
         {
            if ( &ValidinRange($date, $bfields[1], $efields[1], 'date') )
            { $datecheck = 1; }
         }
         elsif ( $#dfields == 1 )
         {
            $date1 = $date.'-01';
            $date2 = $date.'-'.$lastdom[$dfields[1]];
            if ( &ValidinRange($bfields[1], $date1, $date2, 'date') &&
                 &ValidinRange($efields[1], $date1, $date2, 'date') )
            { $datecheck = 1; }
         }
         elsif ( $#dfields == 0 )
         {
            $date1 = $date.'-01-01';
            $date2 = $date.'-12-31';
            if ( &ValidinRange($bfields[1], $date1, $date2, 'date') &&
                 &ValidinRange($efields[1], $date1, $date2, 'date') )
            { $datecheck = 1; }
         }
      }

      # Based on which options were set, we need to make sure that the
      # checks passed
      $passedchecks = 0;
      if ( $time ne '' )
      {
         if ( $date ne '' )
         {
            # Both date and time constraints were set
            if ( $timecheck == 1 && $datecheck == 1 )
            { $passedchecks = 1; }
         }
         else
         {
            # Only time constraint was set
            if ( $timecheck == 1 )
            { $passedchecks = 1; }
         }
      }
      else
      {
         if ( $date ne '' )
         {
            # Only date constraint was set
            if ( $datecheck == 1 )
            { $passedchecks = 1; }
         }
         else
         {
            # Neither time nor date constraints were set
            $passedchecks = 1;
         }
      }

      if ( $passedchecks == 1 )
      { push(@flights, $bfields[1].'|'.$bfields[2].' '.$efields[1].'|'.$efields[2].' '.uc($code)); }

      # We found a flight date, but it may not match the input constraints
      # However, we still need to set the new beginning date of the
      # next flight
      $begin = $events[$i];
      ($bid, $bdate, $btime) = split(/\|/, $begin);
      ($byr, $bmo, $bdy) = split(/-/, $bdate);
      ($bhr, $bmn, $bsc) = split(/:/, $btime);
   }
}

#
#######################################
# Write results
#######################################
#
$file = ($file) ? $file : "&STDOUT";
open(FILE,">${file}");

foreach $flight ( @flights ) { print FILE "$flight\n"; }
close(FILE);


#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);

exit;

sub showargs()
{
   print "\n#########################\n";
   print "ccg_vplist\n";
   print "#########################\n\n";
   print "Display a list of beginning and ending date times for vertical\n";
   print "profiles. This implies that the program can only be used with\n";
   print "the aircraft project (ccg_aircraft).\n";
   print "Results are displayed in a \"vi\" session [default].  Enter\n";
   print "\":q!\" to quit session. Use \"-file\" option to redirect output.\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-s, -site=[site(s)]\n";
   print "     site code\n";
   print "     Specify a single site (e.g., -site=brw)\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., -strategy=pfp)\n";
   exit;
}

sub datetimebetween
{
   local($bdate,$btime,$edate,$etime,$chkdate,$chktime) = @_;

   $check = 0;

   @bd = split(/-/,$bdate);
   @ed = split(/-/,$edate);
   @chkd = split(/-/,$chkdate);

   @bt = split(/:/,$btime);
   @et = split(/:/,$etime);
   @chkt = split(/:/,$chktime);

   $bdd = &date2dec($bd[0],$bd[1],$bd[2],$bt[0],$bt[1],$bt[2]);
   $edd = &date2dec($ed[0],$ed[1],$ed[2],$et[0],$et[1],$et[2]);
   $chkdd = &date2dec($chkd[0],$chkd[1],$chkd[2],$chkt[0],$chkt[1],$chkt[2]);

   if ( $bdd <= $chkdd && $chkdd <= $edd ) { $check = 1; }

   return $check;
}

