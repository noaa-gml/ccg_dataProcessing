#!/usr/bin/perl
#

#
#######################################
# Flaskstats Calling Syntax
#######################################
#
# To call flaskstats: ./flaskstats.pl [ -o$filename ]
#
# -o option specifies an output file, otherwise the output goes to
#           standard output

#
#######################################
# Program Description
#######################################
#
#    Flaskstats.pl is used to make a diagnostics table on the
# flasks in the ccgg database. The information provided should
# include days since last check-in, the shipping time [how long
# it takes for a flask to be checked out and checked back in,
# the storage time [how long it takes for the sample to be
# collected and the analysis on the flask], the number of flasks
# currently checked out, the most recent check-in date with
# flasks checked-in that day, and the most recent check-out
# date with flasks checked-out that day.
#
# NOTE: The sites with the asteriks (*) by them signify that the
#    days since last check-in is longer than the turn around time.
# NOTE2: NULL signifies that there is no data in the database for
#    that specif information.

use DBI;
use Getopt::Std;
#use Switch;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
#######################################
# Output file name
#######################################
#

#
# Checks for -o$filename to see if the user passed in an output filename
#
&getopts('o:');

$file = $opt_o;

#
#######################################
# Initialize Variables
#######################################
#
@osite_code = ();
@oproj_abbr = ();
@olast_checkin = ();
@olast_checkin_days = ();
@olast_in_count = ();
@olast_checkout = ();
@olast_out_count = ();
@oout_count = ();
@oship_time = ();
@ostore_time = ();
@odays_gt_ta = ();
@odays_lt_ta = ();
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
#
#######################################
# Initialize database variables
#######################################
#
# Obtain all the site numbers that we want
@sitenum = ();

#
# Select the sites that are flasks and ongoing
# NOTE: strategy_num = 1 stands for 2.5 L flasks
# NOTE: status_num = 1 stands for ongoing projects
#

$select = "SELECT DISTINCT site_num, project_num ";
$from = "FROM site_desc ";
$where = "WHERE strategy_num = '1' ";
$where = "$where AND status_num = '1'";
$etc = "ORDER BY site_num, project_num";
$site_information = $select.$from.$where.$etc;
                                                                                
$sth = $dbh->prepare($site_information);
$sth->execute();

$n = 0;                                                                                
while (@tmp = $sth->fetchrow_array()) { @siteinfo[$n++] = join('|',@tmp) }
$sth->finish();

#
####################################
# Current Date
####################################
#
# Get the all the values for current time

$date = localtime(time);

#
# Grab the current day, named month, and year
#

@tmp = split(/\s+/, $date);
$day = $tmp[2]; 
$out_month = $tmp[1];
$fixed_year = $tmp[4];

#
# Grab the month number and create the earliest date we want to check
#    data for
#

$realmonth = (localtime)[4] + 1;
$checkdate = $tmp[4]-3 . "-" . $realmonth . "-" . $day;

foreach $site_info ( @siteinfo ) 
{
   ($site_num, $proj_num) = split(/\|/, $site_info);

   #
   # Error checking
   #print "$site_num,$proj_num\n";
   #

   #
   #######################################
   # SITE
   #######################################
   #
   # Decode the site number into the 3 letter acronym

   #
   # Calls the get_field function from ccgg_dbutils.pl
   # Returns the site code from site based off of the site number
   #
   $tmp = &get_field("code","gmd.site","num","$site_num");
   
   #
   # Check to see if anything was returned, if not, set it to NULL
   #
   $site_code = $tmp;
   if ( $tmp eq '' )
   {
      $site_code = NUL;
   }

   #
   #######################################
   # PROJECT
   #######################################
   #
   # Decode the project number into the project abbreviation

   #
   # Calls the get_field function from ccgg_dbutils.pl
   # Returns the site code from site based off of the site number
   #
   $tmp = &get_field("abbr","gmd.project","num","$proj_num");
   
   #
   # Check to see if anything was returned, if not, set it to NULL
   #
   $proj_abbr = $tmp;
   if ( $tmp eq '' )
   {
      $proj_abbr = NUL;
   }

   #
   # Error checking
   #print "$proj_abbr\n";
   #

   #
   #######################################
   # LAST CHK-IN
   #######################################
   #
   # Determines the most recent checkin date

   #
   # Calls the get_field function from ccgg_dbutils.pl
   # Returns the max date_in from flask_shipping based off of the site number
   #
   $select = " SELECT max(date_in)";
   $from = " FROM flask_shipping";
   $where = " WHERE site_num = '$site_num'";
   $and = " AND project_num = '$proj_num'";
   $sql_last_chkin = $select.$from.$where.$and;

   $sth = $dbh->prepare($sql_last_chkin);
   $sth->execute();

   # 
   # Check to see if anything was returned, if not, set it to NULL
   #
   @tmp = $sth->fetchrow_array();

   $last_checkin = @tmp[0];
   if ( @tmp[0] == "" )
   {
      $last_checkin = NULL;
   }

   #
   # Error checking
   #print "$last_checkin\n";
   #

   #
   #######################################
   # DAYS SINCE LAST CHK-IN
   #######################################
   #
   # Determines the days it has been since the last flask checkin

   if ( $last_checkin ne NULL )
   {
      #
      # Split the last checkin date by -'s
      #
      @tmp = split(/-/, $last_checkin);

      #
      # Convert the dates into decimal for easy arithmetic operation
      # print "TODAY: $fixed_year, $day, $realmonth\n";
      #
      $d1 = &date2dec($fixed_year,$realmonth,$day,12,0);
      $d2 = &date2dec($tmp[0],$tmp[1],$tmp[2],12,0);

      #
      # Subtract the decimal dates then multiply by 365 [days in a year]
      # to return days
      # print "$d1, $d2\n";
      #
      $last_checkin_days = 365*($d1-$d2);
      
      #
      # Error checking, just making sure that something was not
      # checked in after the current date [meaning, in the future]
      #
      if ( $last_checkin_days < 0 )
      {
         print "DATE ERROR: $site_num, $d1, $d2, $last_checkin\n";
      }
   }
   else
   {
      #
      # If last_checkin was NULL, then set last_checkin_days to NULL
      #
      $last_checkin_days = -1;
   }

   #
   # Error checking
   #print "$last_checkin_days\n";
   #

   #
   #######################################
   # LAST CHK-IN NUMBER
   #######################################
   #
   # The number of flasks checked in on the last checkin date

   $select = "SELECT count(date_in) ";
   $from = "FROM flask_shipping ";
   $where = "WHERE date_in = '$last_checkin'";
   $where = "$where AND site_num = '$site_num'";
   $where = "$where AND project_num = '$proj_num'";
   $in_count = $select.$from.$where;
   
   $sth = $dbh->prepare($in_count);
   $sth->execute();

   # 
   # Capture the output and put into $last_in_count
   #
   @tmp = $sth->fetchrow_array();

   $last_in_count = @tmp[0];
   if ( @tmp[0] == "" )
   {
      $last_in_count = NULL;
   }

   #
   # Error checking
   #print "$last_in_count\n";
   #

   #
   #######################################
   # LAST CHK-OUT
   #######################################
   #
   # The most recent check out date of one of the flasks

   #
   # Uses ccgg_dbutils.pl
   # Returns the maximum date_out from flask_inv given a site number
   #
   $select = "SELECT max(date_out) ";
   $from = "FROM flask_inv ";
   $where = "WHERE sample_status_num = '2' ";
   $where = "$where AND site_num = '$site_num'";
   $where = "$where AND project_num = '$proj_num'";
   $chkout_last = $select.$from.$where;
                                                                                
   $sth = $dbh->prepare($chkout_last);
   $sth->execute();
   
   #
   # Capture the output and put it into the $out_count variable
   #
   @tmp = $sth->fetchrow_array();

   $last_checkout = @tmp[0];
   if ( @tmp[0] == "" )
   {
      #
      # If the get_field function did not find anything, then set
      # $last_checkout to NULL
      #
      $last_checkout = NULL;
   }

   # More error checking
   #print "$last_checkout\n";
   #printf "%3d %10s", $site_num, $last_checkout;

   #
   #######################################
   # LAST CHK-OUT NUMBER
   #######################################
   #
   # The number of flasks that were checked out on the last check out date

   #
   # Check to make sure that there was a valid most recent check out date
   #
   if ( $last_checkout ne NULL )
   {
      $select = "SELECT count(date_out) ";
      $from = "FROM flask_inv ";
      $where = "WHERE date_out = '$last_checkout'";
      $where = "$where AND site_num = '$site_num'";
      $where = "$where AND project_num = '$proj_num'";
      $in_count = $select.$from.$where;

      #
      # Error checking
      # print "$in_count\n";
      #
                                                                                
      $sth = $dbh->prepare($in_count);
      $sth->execute();
             
      #                                                                   
      # Capture the output and put it into the variable $last_out_count
      #
      @tmp = $sth->fetchrow_array();

      $last_out_count = @tmp[0];
      if ( @tmp[0] == "" )
      {
         #
         # If the MySQL command returned nothing, set
         # $last_out_count to NULL
         #
         $last_out_count = NULL;
      }
   }
   else
   {

      #
      # If the most recent check out date was not found, set
      # $last_out_count to NULL
      #
      $last_out_count = NULL;
   }

   #
   # Error checking
   #print "$last_out_count\n";
   #

   #
   #######################################
   # FLASKS CHK'D-OUT
   #######################################
   #
   # Counts the number of flasks currently checked out

   #
   # It can easily be determined if a flask is checked out by
   # checking the sample_status_num. If it is equal to 2, that
   # means that the flask is checked out.
   #
   $select = "SELECT count(date_out) ";
   $from = "FROM flask_inv ";
   $where = "WHERE sample_status_num = 2 ";
   $where = "$where AND site_num = '$site_num'";
   $where = "$where AND project_num = '$proj_num'";
   $chkout_count = $select.$from.$where;
                                                                                
   $sth = $dbh->prepare($chkout_count);
   $sth->execute();

   #
   # Capture the output and put it into the $out_count variable
   #
   @tmp = $sth->fetchrow_array();

   $out_count = @tmp[0];
   if ( @tmp[0] == "" )
   {
      #
      # If the MySQL command returned nothing, set $out_count to NULL
      #
      $out_count = NULL;
   }

   #
   # Error checking
   #print "$out_count\n";
   #

   #
   #######################################
   # SHIPPING TIME (days)
   #######################################
   #
   # The average time [days] between check out and check in. All the
   # information is located in the flask shipping table. This
   # information shows us how long a flask is at a site.
   $select = "SELECT DISTINCTROW date_out, date_in";
   $from = " FROM flask_shipping";
   $where = " WHERE site_num = '$site_num'";
   $where = "$where AND project_num = '$proj_num'";
   $where = "$where AND date_out > '$checkdate'";
   $ship_time = $select.$from.$where;

   $sth = $dbh->prepare($ship_time);
   $sth->execute();

   #
   # Fetch results
   #
   $n=0;
   @arr = ();
   while (@tmp = $sth->fetchrow_array()) { @arr[$n++] = join(' ',@tmp) }
   $sth->finish();

   #
   # Initialize Variables
   #                                                       
   @o_date = ();
   @i_date = ();
   $num = 0;
   $count = 0;
   $total_ship = 0;

   #
   # Loops through all the dates returned from the SELECT command
   #    converting them into decimal date, subtracting them,
   #    then multiplying by 365 to obtain in unit of days again.
   #    NOTE: scalar() returns the length of an array
   while ( $count < scalar(@arr) )
   {
      @d_tmp = split(/ /,@arr[$count]);
      @o_date = split(/-/,$d_tmp[0]);
      @i_date = split(/-/,$d_tmp[1]);
      $d1 = &date2dec($o_date[0],$o_date[1],$o_date[2],12,0);
      $d2 = &date2dec($i_date[0],$i_date[1],$i_date[2],12,0);

      #
      # The turn around time in days should never be less than 0
      #   since a box cannot be shipped before it was received
      #
      if ( ($d2-$d1) < 0 )
      {
         print "SHIPPING TIME ERROR: $site_num $d_tmp[0] $d_tmp[1]\n";
      }
      else
      {
         if ( ($d2-$d1) != 0 )
         {
            #
            # Add the days to the running total and increment the
            # total number of days
            #
            $total_ship = $total_ship + 365*($d2-$d1);
            ++$num;
         }
      }
      ++$count;
   }

   #
   # Determine the average turn around time for this site
   #
   if ( $num != 0 )
   {
      $final_ship_time = $total_ship / $num;
   }
   else
   {
      $final_ship_time = -1;
   }

   #
   # Error checking
   #print "$final_ship_time\n";
   #

   #
   #######################################
   # STORAGE TIME (days)
   #######################################
   #
   # The average time [days] between sample and analysis. We need to 
   # access the data from flask_event and flask_data because that 
   # tells us the days between the date the sample was collected and
   # the date the analysis was done on the flask. Field sites do not
   # front their inventory so the flask boxes can sit for a long period.

   $select = "SELECT DISTINCTROW flask_event.date, flask_data.date ";
   $from = "FROM flask_data, flask_event ";
   $where = "WHERE site_num = '$site_num' and parameter_num = '1' ";
   $where = "$where AND flask_event.project_num = '$proj_num' ";
   $where = "$where AND flask_event.date > '$checkdate'";
   $where = "$where AND flask_event.num = flask_data.event_num ";
   $store_time = $select.$from.$where;

   $sth = $dbh->prepare($store_time);
   $sth->execute();
   
   #
   # Fetch results
   #
   $n=0;
   @arr = ();
   while (@tmp = $sth->fetchrow_array()) { @arr[$n++] = join(' ',@tmp) }
   $sth->finish();

   #
   # Initialize Variables
   #                                                       
   @s_date = ();
   @e_date = ();
   $num = 0;
   $count = 0;
   $total_store = 0;

   #
   # Loops through all the dates returned from the SELECT command
   #    converting them into decimal date, subtracting them,
   #    then multiplying by 365 to obtain in unit of days again.
   #    NOTE: scalar() returns the length of an array
   while ( $count < scalar(@arr) )
   {
      @d_tmp = split(/ /,@arr[$count]);
      @s_date = split(/-/,$d_tmp[0]);
      @e_date = split(/-/,$d_tmp[1]);
      $d1 = &date2dec($s_date[0],$s_date[1],$s_date[2],12,0);
      $d2 = &date2dec($e_date[0],$e_date[1],$e_date[2],12,0);
                                                                                
      #
      # The turn around time in days should never be less than 0
      #   since a box cannot be shipped before it was received
      #
      if ( ($d2-$d1) < 0 )
      {
         print "STORAGE TIME ERROR: $site_num $d_tmp[0] $d_tmp[1]\n";
      }
      else
      {
         if ( ($d2-$d1) != 0 )
         {
            #
            # Add the days to the running total and increment the
            # total number of days
            #
            $total_store = $total_store + 365*($d2-$d1);
            ++$num;
         }
      }
      ++$count;
   }

   #
   # Determine the average turn around time for this site
   #
   if ( $num != 0 )
   {
      $final_store_time = $total_store / $num;
   }
   else
   {
      $final_store_time = -1;
   }

   #
   # Error checking
   #print "$final_store_time\n";
   #

   #
   #######################################
   # Add to the output arrays
   #######################################
   #
   @osite_code[++$#osite_code] = $site_code;
   @oproj_abbr[++$#oproj_abbr] = $proj_abbr;
   @olast_checkin[++$#olast_checkin] = $last_checkin;
   @olast_checkin_days[++$#olast_checkin_days] = $last_checkin_days;
   @olast_in_count[++$#olast_in_count] = $last_in_count;
   @olast_checkout[++$#olast_checkout] = $last_checkout;
   @olast_out_count[++$#olast_out_count] = $last_out_count;
   @oout_count[++$#oout_count] = $out_count;
   @oship_time[++$#oship_time] = $final_ship_time;
   @ostore_time[++$#ostore_time] = $final_store_time;

   #
   # We want to sort the sites into two different arrays
   # One array will contain the sites that have days since
   # last check-in greater than the turn around time in days.
   # The other array will contain the sites that have days since
   # last check-in less than or equal to the turn around time in days.
   #
   if ( $last_checkin_days > $final_store_time && $final_store_time > 0)
   {
      @odays_gt_ta[++$#odays_gt_ta] = $site_code.'|'.$proj_abbr;
   }
   else
   {
      @odays_lt_ta[++$#odays_lt_ta] = $site_code.'|'.$proj_abbr;
   }
}

#
# Sort the two arrays
#
@odays_gt_ta = sort (@odays_gt_ta);
@odays_lt_ta = sort (@odays_lt_ta);

#
# Print out the output page
#
$print = 1;
if ( $print == 1 )
{

   #
   # If the user passed in a filename, print the output to that file
   #    otherwise just print it to standard output
   #
   if ($file) { $file = ">${file}"; }
   else { $file = ">&STDOUT"; }

   open(FILE,$file);

   print FILE "Flask Supply Summary\n\n";

   print FILE "Creation Date: $day $out_month $fixed_year\n\n";
   print FILE "SITE     PROJECT      DAYS SINCE   SHIPPING      STORAGE   # FLASKS     LAST CHK-IN    #    LAST CHK-OUT    #\n";
   print FILE "                     LAST CHK-IN  TIME (DAYS)  TIME (DAYS) CHK'D_OUT\n";
   print FILE "---- --------------- -----------  -----------  ----------- ---------  ----------------    -----------------\n";
   
   #
   # Print out the data in the array where days since last check-in
   # is greater than the turn around time
   #
   foreach $info ( @odays_gt_ta )
   {
      ($code,$abbr) = split(/\|/,$info);
      #
      # Find the array index number of the current site_code
      #
      $count = 0;
      while ( $code ne @osite_code[$count] || $abbr ne @oproj_abbr[$count] )
      {
         ++$count;
      }

      $format = "%3s*   %-15s  %4d         %3d          %3d         %3d      %10s    %3d   %10s     %3d\n";
      printf FILE $format, @osite_code[$count], @oproj_abbr[$count], @olast_checkin_days[$count], @oship_time[$count], @ostore_time[$count], @oout_count[$count], @olast_checkin[$count], @olast_in_count[$count], @olast_checkout[$count], @olast_out_count[$count];
      ++$count;
   }

   #
   # Print out the data in the array where days since last check-in
   # is less than or equal to the turn around time
   #
   foreach $info ( @odays_lt_ta )
   {
      ($code,$abbr) = split(/\|/,$info);
      #
      # Find the array index number of the current site_code
      #
      $count = 0;
      while ( $code ne @osite_code[$count] || $abbr ne @oproj_abbr[$count] )
      {
         ++$count;
      }

      $format = "%3s    %-15s  %4d         %3d          %3d         %3d      %10s    %3d   %10s     %3d\n";
      printf FILE $format,@osite_code[$count], @oproj_abbr[$count], @olast_checkin_days[$count], @oship_time[$count], @ostore_time[$count], @oout_count[$count], @olast_checkin[$count], @olast_in_count[$count], @olast_checkout[$count], @olast_out_count[$count];
      ++$count;
   }
   close(FILE);
}

#
# Error checking
# print "@olast_in_count";
#

$sth->finish();

#
#######################################
# Write results
#######################################
#

#$file = ($file) ? $file : "&STDOUT";
#open(FILE,">${file}");
                                                                                
#foreach $row (@out) { print FILE "${row}\n"; }
#close(FILE);

#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
#
