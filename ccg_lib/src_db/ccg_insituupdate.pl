#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/validator.pl";

#
#
#       ************************** WARNING ****************************
#       This procedure modifies a U.S. Government Scientific Database.
#       Contact Ken Masarie (kenneth.masarie@noaa.gov) before using.
#       ***************************************************************
#
#       Update or Insert insitu measurement results
#       into the NOAA CMDL CCGG RDBMS.
#
#       Expected format...
#
#       For project=ccg_tower
#       site:AMT|param:CO2|yr:2012|mo:01|dy:31|hr:23|mn:59|sc:59|intake_ht:10.0|inst:L4|value:395.23|meas_unc:0.63|random_unc:0.28|std_dev:0.12|scale_unc:0.18|flag:...
#
#       For project=ccg_obs
#       Need to fill in this information
#
# Notes
#    - To redirect standard out and standard error to
#      different files, use the following command in bash shell:
#      ccg_insituupdate.pl -file=testfile 1>stdout.txt 2>stderr.txt
# 
# Programmer notes
#    - This should be the only perl script to actually update the database
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "average=s", "comment", "file|f=s", "flag", "help|h", "meas_unc", "nopreserve", "project=s", "random_unc", "std_dev", "scale_unc", "unc", "update|u", "value", "verbose");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }
if (!($Options{file})) { &showargs() }
if (!($Options{project})) { &showargs() }

# valid "average" options

@aveoptions = ( "hour", "insitu" );

if ( $Options{average} )
{
   @tmp = grep /^$Options{average}/i, @aveoptions;
   if ( $#tmp == (-1) ) { &showargs } else { $average = $tmp[0] }
}
else
{ $average = 'insitu'; }

$project = $Options{project};
$file = $Options{file};
$nopreserve = $Options{nopreserve};
$updatedb = $Options{update};
$verbose = $Options{verbose};

#
#######################################
# Initialization
#######################################
#
if ( $average eq 'hour' )
{
   # Optional fields
   @optionalnames = ( 'n' );

   #
   # Required fields to update
   #
   @requirednames = ( 'site', 'param', 'yr', 'mo', 'dy', 'hr', 'intake_ht', 'inst');

   #
   # Fields that can be updated
   #
   @setnames = ( 'flag', 'value', 'unc' );

   # Assign the fields that we are going to update/insert based on the flags
   @updatenames = ();
   if ( $Options{flag} ) { push(@updatenames, "flag") };
   if ( $Options{value} ) { push(@updatenames, "value") };
   if ( $Options{unc} ) { push(@updatenames, "unc") };
}
elsif ( $average eq 'insitu' )
{
   if ( $project eq 'ccg_tower' )
   {
      # Optional fields
      @optionalnames = ( 'n' );

      #
      # Required fields to update
      #
      @requirednames = ( 'site', 'param', 'yr', 'mo', 'dy', 'hr', 'mn', 'sc', 'intake_ht', 'inst');

      #
      # Fields that can be updated
      #
      @setnames = ( 'comment', 'flag', 'meas_unc', 'random_unc', 'std_dev', 'scale_unc', 'value' );

      # Assign the fields that we are going to update/insert based on the flags
      @updatenames = ();
      if ( $Options{comment} ) { push(@updatenames, "comment") };
      if ( $Options{flag} ) { push(@updatenames, "flag") };
      if ( $Options{meas_unc} ) { push(@updatenames, "meas_unc") };
      if ( $Options{random_unc} ) { push(@updatenames, "random_unc") };
      if ( $Options{std_dev} ) { push(@updatenames, "std_dev") };
      if ( $Options{scale_unc} ) { push(@updatenames, "scale_unc") };
      if ( $Options{value} ) { push(@updatenames, "value") };
   }
   else
   {
      # Optional fields
      @optionalnames = ( 'n' );

      #
      # Required fields to update
      #
      @requirednames = ( 'site', 'param', 'yr', 'mo', 'dy', 'hr', 'mn', 'sc', 'intake_ht', 'inst');

      #
      # Fields that can be updated
      #
      @setnames = ( 'comment', 'flag', 'unc', 'value' );

      # Assign the fields that we are going to update/insert based on the flags
      @updatenames = ();
      if ( $Options{comment} ) { push(@updatenames, "comment") };
      if ( $Options{flag} ) { push(@updatenames, "flag") };
      if ( $Options{unc} ) { push(@updatenames, "unc") };
      if ( $Options{value} ) { push(@updatenames, "value") };
   }
}

# Get the hostname
$hostname = `hostname`;
chomp($hostname);

#
# Error out if the user specified no fields to insert/update
#
if ( $#updatenames < 0 )
{
   print STDERR "ERROR: No fields set to be updated. Exiting...\n";
   exit;
}

#
# Read input file
#
open(FILE, $file) || die "Can't open file $file.\n";
@arr = <FILE>;
close(FILE);
chop(@arr);
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

#
# Get and check project number
#
$project_num = &get_field("num","project","abbr",$project);

# Check program_num
if ( ! &ValidInt($project_num) || $project_num == 0 )
{
   $errstr = "Project abbr '".$curnv_aarr{"project"}."' not found.";
   print STDERR "ERROR: $errstr\n";
   exit;;
}

#
#######################################
# Loop thru string array
#######################################
#

foreach $line ( @arr )
{
   chomp($line);
   if ( $line =~ m/^\s*$/i ) { next; }

   # Clear the associative arrays
   undef %curnv_aarr;
   undef %clncurnv_aarr;
   undef %q_clncurnv_aarr;
   undef %oldnv_aarr;

   #
   ########################
   # Check the input
   ########################
   #

   # Strip out all carriage returns.
   # See http://kb.iu.edu/data/acux.html
   $line =~ s/\r//g;

   # Strip out all control Ms.
   $line =~ s///g;

   # Escape all single quotes
   # $line =~ s/'/\\'/g;

   # Search the string for unexpected characters
   # http://www.asciitable.com/
   $err = '';
   @ascii_values = unpack("C*", $line);
   foreach $ascii_value ( @ascii_values )
   {
      if ( $ascii_value < 32 || $ascii_value > 126 )
      {
         $errstr = "Unexpected ASCII value '$ascii_value' in string.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Next line if there are any unrecognized characters
   if ( $err ne '' )
   {
      print STDERR "ERROR: ${line} ( $err )\n";
      next;
   }

   #
   # Split the input line into the name value pairs
   #
   %tmphash = &nvpair_split($line, ':', '\|');

   $err = '';
   foreach $name ( keys(%tmphash) )
   {
      # Remove leading spaces in the value
      $tmphash{$name} =~ s/^\s+//g;

      # If the user specified an unrecognized field, then alert them
      if ( in_array($name,@optionalnames) ||
           in_array($name,@requirednames) ||
           in_array($name,@setnames) )
      { $curnv_aarr{"$name"} = $tmphash{$name}; }
      else
      {
         $errstr = "Unexpected field '${name}'.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Next line if there are any unrecognized fields
   if ( $err ne '' )
   {
      print STDERR "ERROR: ${line} ( $err )\n";
      next;
   }

   $err = '';
   # Check that all the required fields are set
   foreach $requiredname ( @requirednames )
   {
      #
      # If there is a required field missing, then error out
      #
      if (!exists($curnv_aarr{$requiredname}) || $curnv_aarr{$requiredname} eq '' )
      {
         $errstr = "Required field '${requiredname}' is not found.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Next line if there are any problems
   if ( $err ne '' )
   {
      print STDERR "ERROR: ${line} ( $err )\n";
      next;
   }

   #
   ########################
   # Query database for any information
   ########################
   #
   #
   # Get and check site number
   #
   $curnv_aarr{"site_num"} = &get_field("num","gmd.site","code",$curnv_aarr{"site"});
   #
   # Get and check parameter number
   #
   $curnv_aarr{"parameter_num"} = &get_field("num","gmd.parameter","formula",$curnv_aarr{"param"});

   #
   ########################
   # Validate the input
   ########################
   #

   $err = '';

   # Check yr
   if ( &ValidInt($curnv_aarr{"yr"}) &&
        &ValidinRange($curnv_aarr{"yr"}, '1900', '9999', 'int') )
   { $clncurnv_aarr{"yr"} = $curnv_aarr{"yr"}; }
   else
   {
      $errstr = "Year must be a 4 digit integer greater than 1000.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check mo
   if ( &ValidInt($curnv_aarr{"mo"}) &&
        &ValidinRange($curnv_aarr{"mo"}, '1', '12', 'int') )
   { $clncurnv_aarr{"mo"} = $curnv_aarr{"mo"}; }
   else
   {
      $errstr = "Month must be between 1 and 12.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }


   if ( exists($clncurnv_aarr{"mo"}) )
   {
      # Only check dy if the month is valid

      # First entry is 0 so that the index matches the month
      @lastdom = ( 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

      $leap = &leapyear($curnv_aarr{"yr"});
      if ( $leap )
      { $lastdom[2] = 29; }

      $lastday = $lastdom[$clncurnv_aarr{"mo"}];
      if ( &ValidInt($curnv_aarr{"dy"}) &&
           &ValidinRange($curnv_aarr{"dy"}, 1, $lastday, 'int') )
      { $clncurnv_aarr{"dy"} = $curnv_aarr{"dy"}; }
      else
      {
         $errstr = "Day must be between 1 and the last day of the month.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check hr
   if ( &ValidInt($curnv_aarr{"hr"}) &&
        &ValidinRange($curnv_aarr{"hr"}, 0, 23, 'int') )
   { $clncurnv_aarr{"hr"} = $curnv_aarr{"hr"}; }
   else
   {
      $errstr = "Hour must be between 0 and 23.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   if ( $average eq 'insitu' )
   {
      # Check mn
      if ( &ValidInt($curnv_aarr{"mn"}) &&
           &ValidinRange($curnv_aarr{"mn"}, 0, 59, 'int') )
      { $clncurnv_aarr{"mn"} = $curnv_aarr{"mn"}; }
      else
      {
         $errstr = "Minute must be between 0 and 59.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }

      # Check sc
      if ( exists($curnv_aarr{"sc"}) )
      {
         if ( &ValidInt($curnv_aarr{"sc"}) &&
              &ValidinRange($curnv_aarr{"sc"}, 0, 59, 'int') )
         { $clncurnv_aarr{"sc"} = $curnv_aarr{"sc"}; }
         else
         {
            $errstr = "Seconds must be between 0 and 59.";
            $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
         }
      }
   }

   # Check intake_ht
   if ( exists($curnv_aarr{"intake_ht"}) )
   {
      if ( &ValidFloat($curnv_aarr{"intake_ht"}) &&
           &ValidinRange($curnv_aarr{"intake_ht"}, 0, 1000 , 'float') )
      { $clncurnv_aarr{"intake_ht"} = $curnv_aarr{"intake_ht"}; }
      else
      {
         $errstr = "Intake height must be between 0 and 1000.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check inst
   if ( $curnv_aarr{"inst"} =~ /^[A-Za-z0-9]{2,4}$/ )
   { $clncurnv_aarr{"inst"} = $curnv_aarr{"inst"}; }
   else
   {
      $errstr = "Instrument ID must be between 2 and 4 alphanumeric characters.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check site_num
   if ( &ValidInt($curnv_aarr{"site_num"}) && $curnv_aarr{"site_num"} > 0 )
   {
      $clncurnv_aarr{"site_num"} = $curnv_aarr{"site_num"};
      $clncurnv_aarr{"site"} = $curnv_aarr{"site"};
   }
   else
   {
      $errstr = "Site code '".$curnv_aarr{"site"}."' not found.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check parameter_num
   if ( &ValidInt($curnv_aarr{"parameter_num"}) && $curnv_aarr{"parameter_num"} > 0 )
   {
      $clncurnv_aarr{"parameter_num"} = $curnv_aarr{"parameter_num"};
      $clncurnv_aarr{"param"} = $curnv_aarr{"param"};
   }
   else
   {
      $errstr = "Parameter formula '".$curnv_aarr{"param"}."' not found.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check comment
   if ( exists($curnv_aarr{"comment"}) )
   {
      if ( length($curnv_aarr{"comment"}) < 256 )
      {
         $clncurnv_aarr{"comment"} = $curnv_aarr{"comment"};
      }
      else
      {
         $errstr = "Comment must be less than 256 characters.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check flag
   if ( exists($curnv_aarr{"flag"}) )
   {
      if ( length($curnv_aarr{"flag"}) == 3 )
      { $clncurnv_aarr{"flag"} = $curnv_aarr{"flag"}; }
      else
      {
         $errstr = "Flag must be 3 characters.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check value
   if ( exists($curnv_aarr{"value"}) )
   {
      if ( &ValidFloat($curnv_aarr{"value"}) )
      { $clncurnv_aarr{"value"} = $curnv_aarr{"value"}; }
      else
      {
         $errstr = "Value is invalid.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check unc
   if ( exists($curnv_aarr{"unc"}) )
   {
      if ( &ValidFloat($curnv_aarr{"unc"}) )
      { $clncurnv_aarr{"unc"} = $curnv_aarr{"unc"}; }
      else
      {
         $errstr = "Uncertainty is invalid.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check meas_unc
   if ( exists($curnv_aarr{"meas_unc"}) )
   {
      if ( &ValidFloat($curnv_aarr{"meas_unc"}) )
      { $clncurnv_aarr{"meas_unc"} = $curnv_aarr{"meas_unc"}; }
      else
      {
         $errstr = "Measurement uncertainty is invalid.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check random_unc
   if ( exists($curnv_aarr{"random_unc"}) )
   {
      if ( &ValidFloat($curnv_aarr{"random_unc"}) )
      { $clncurnv_aarr{"random_unc"} = $curnv_aarr{"random_unc"}; }
      else
      {
         $errstr = "Random uncertainty is invalid.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }
   
   # Check std_dev
   if ( exists($curnv_aarr{"std_dev"}) )
   {
      if ( &ValidFloat($curnv_aarr{"std_dev"}) )
      { $clncurnv_aarr{"std_dev"} = $curnv_aarr{"std_dev"}; }
      else
      {
         $errstr = "Standard deviacion is invalid.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Check scale_unc
   if ( exists($curnv_aarr{"scale_unc"}) )
   {
      if ( &ValidFloat($curnv_aarr{"scale_unc"}) )
      { $clncurnv_aarr{"scale_unc"} = $curnv_aarr{"scale_unc"}; }
      else
      {
         $errstr = "Scale uncertainty is invalid.";
         $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
      }
   }

   # Next line if there are any problems
   if ( $err ne '' )
   {
      print STDERR "ERROR: ${line} ( $err )\n";
      next;
   }

   #
   ######################################
   # Input is good, process the line
   ######################################
   #

   $database_table = sprintf("%s\_%s\_%s", lc($clncurnv_aarr{"site"}), lc($clncurnv_aarr{"param"}), $average);

   $clncurnv_aarr{"date"} = sprintf("%4d-%02d-%02d", $clncurnv_aarr{"yr"}, $clncurnv_aarr{"mo"}, $clncurnv_aarr{"dy"});

   if ( $average eq 'hour' )
   {
      # Set the date and dd values in the associate array
      $clncurnv_aarr{"dd"} = &date2dec($clncurnv_aarr{"yr"},$clncurnv_aarr{"mo"},$clncurnv_aarr{"dy"},$clncurnv_aarr{"hr"});
   }
   elsif ( $average eq 'insitu' )
   {
      # If it is not set then set it to 0
      if ( !exists($clncurnv_aarr{"sc"}) )  { $clncurnv_aarr{"sc"} = 0; }

      # Set the date and dd values in the associate array
      $clncurnv_aarr{"dd"} = &date2dec($clncurnv_aarr{"yr"},$clncurnv_aarr{"mo"},$clncurnv_aarr{"dy"},$clncurnv_aarr{"hr"},$clncurnv_aarr{"mn"},$clncurnv_aarr{"sc"});
   }

   # Only update/insert the fields that the user specified.
   #    Remove the ones that were set in the file but will
   #    not be updated/inserted to the database. Please see
   #    the IMPORTANT NOTE
   foreach $setname ( @setnames )
   {
      if ( ! in_array($setname,@updatenames) )
      { delete $clncurnv_aarr{"$setname"}; }
   }

   #
   # Does entry exist in DB?
   #
   @wherestrs = ();
   @wherevalues = ();

   @results = ();
   if ( $average eq 'hour' )
   {
      push(@wherestrs, 'date = ?');
      push(@wherevalues, $clncurnv_aarr{"date"});
      push(@wherestrs, 'hour = ?');
      push(@wherevalues, $clncurnv_aarr{"hr"});
      push(@wherestrs, 'intake_ht = ?');
      push(@wherevalues, $clncurnv_aarr{"intake_ht"});
      push(@wherestrs, 'inst = ?');
      push(@wherevalues, $clncurnv_aarr{"inst"});

      $sql = "SELECT date, hour, dd, intake_ht, value, unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
      @sqlargs = (@wherevalues);

      #print $sql."\n";
      #print join('|', @sqlargs)."\n";

      $sth = $dbh->prepare($sql);
      $sth->execute(@sqlargs);

      @results = ();   
      while (@tmp = $sth->fetchrow_array())
      {
         $aarr = {};
         $aarr->{"date"} = $tmp[0];
         $aarr->{"hr"} = $tmp[1];
         $aarr->{"dd"} = $tmp[2];
         $aarr->{"intake_ht"} = $tmp[3];
         $aarr->{"value"} = $tmp[4];
         $aarr->{"unc"} = $tmp[5];
         $aarr->{"n"} = $tmp[6];
         $aarr->{"flag"} = $tmp[7];
         $aarr->{"inst"} = $tmp[8];

         $aarr->{"site"} = $clncurnv_aarr{"site"};
         $aarr->{"param"} = $clncurnv_aarr{"param"};

         push(@results, $aarr);
      }
      $sth->finish();
   }
   elsif ( $average eq 'insitu' )
   {
      if ( $project eq 'ccg_tower' )
      {
         push(@wherestrs, 'date = ?');
         push(@wherevalues, $clncurnv_aarr{"date"});
         push(@wherestrs, 'hr = ?');
         push(@wherevalues, $clncurnv_aarr{"hr"});
         push(@wherestrs, 'intake_ht = ?');
         push(@wherevalues, $clncurnv_aarr{"intake_ht"});
         push(@wherestrs, 'inst = ?');
         push(@wherevalues, $clncurnv_aarr{"inst"});
         push(@wherestrs, 'min = ?');
         push(@wherevalues, $clncurnv_aarr{"mn"});
         push(@wherestrs, 'sec = ?');
         push(@wherevalues, $clncurnv_aarr{"sc"});

         $sql = "SELECT date, hr, min, sec, dd, intake_ht, value, meas_unc, random_unc, std_dev, scale_unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
         @sqlargs = (@wherevalues);
         #print $sql."\n";
         #print join('|', @sqlargs)."\n";

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);

         @results = ();   
         while (@tmp = $sth->fetchrow_array())
         {
            $aarr = {};
            $aarr->{"date"} = $tmp[0];
            $aarr->{"hr"} = $tmp[1];
            $aarr->{"mn"} = $tmp[2];
            $aarr->{"sc"} = $tmp[3];
            $aarr->{"dd"} = $tmp[4];
            $aarr->{"intake_ht"} = $tmp[5];
            $aarr->{"value"} = $tmp[6];
            $aarr->{"meas_unc"} = $tmp[7];
            $aarr->{"random_unc"} = $tmp[8];
            $aarr->{"std_dev"} = $tmp[9];
            $aarr->{"scale_unc"} = $tmp[10];
            $aarr->{"n"} = $tmp[11];
            $aarr->{"flag"} = $tmp[12];
            $aarr->{"inst"} = $tmp[13];

            $aarr->{"site"} = $clncurnv_aarr{"site"};
            $aarr->{"param"} = $clncurnv_aarr{"param"};

            push(@results, $aarr);
         }
         $sth->finish();
      }
      else
      {
         push(@wherestrs, 'date = ?');
         push(@wherevalues, $clncurnv_aarr{"date"});
         push(@wherestrs, 'hr = ?');
         push(@wherevalues, $clncurnv_aarr{"hr"});
         push(@wherestrs, 'intake_ht = ?');
         push(@wherevalues, $clncurnv_aarr{"intake_ht"});
         push(@wherestrs, 'inst = ?');
         push(@wherevalues, $clncurnv_aarr{"inst"});
         push(@wherestrs, 'min = ?');
         push(@wherevalues, $clncurnv_aarr{"mn"});
         push(@wherestrs, 'sec = ?');
         push(@wherevalues, $clncurnv_aarr{"sc"});

         $sql = "SELECT date, hr, min, sec, dd, intake_ht, value, unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
         @sqlargs = (@wherevalues);
         #print $sql."\n";
         #print join('|', @sqlargs)."\n";

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);

         @results = ();   
         while (@tmp = $sth->fetchrow_array())
         {
            $aarr = {};
            $aarr->{"date"} = $tmp[0];
            $aarr->{"hr"} = $tmp[1];
            $aarr->{"mn"} = $tmp[2];
            $aarr->{"sc"} = $tmp[3];
            $aarr->{"dd"} = $tmp[4];
            $aarr->{"intake_ht"} = $tmp[5];
            $aarr->{"value"} = $tmp[6];
            $aarr->{"unc"} = $tmp[7];
            $aarr->{"n"} = $tmp[8];
            $aarr->{"flag"} = $tmp[9];
            $aarr->{"inst"} = $tmp[10];

            $aarr->{"site"} = $clncurnv_aarr{"site"};
            $aarr->{"param"} = $clncurnv_aarr{"param"};

            push(@results, $aarr);
         }
         $sth->finish();
      }
   }

   #print 'RESULTS: '.$#results."\n";

   if ( $#results == 0 )
   {
      # One match found
      #12345

      $oldnv_aarr = $results[0];

      if ( $average eq 'hour' )
      {
         $oldline = '(OLD)      '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
      }
      elsif ( $average eq 'insitu' )
      {
         if ( $project eq 'ccg_tower' )
         {
            $oldline = '(OLD)      '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"},$oldnv_aarr->{"mn"}, $oldnv_aarr->{"sc"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"meas_unc"}, $oldnv_aarr->{"random_unc"}, $oldnv_aarr->{"std_dev"}, $oldnv_aarr->{"scale_unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
         }
         else
         {
            $oldline = '(OLD)      '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"},$oldnv_aarr->{"mn"}, $oldnv_aarr->{"sc"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
         }
      }

      @setstrs = ();
      @setvalues = ();
      @sqlargs = ();

      $set = '';
      foreach $updatename ( @updatenames )
      {
         #
         # If the field exists in the associative array,
         #    then it must have a value unless it is the
         #    comment field
         #
         if ( exists($clncurnv_aarr{"$updatename"}) && 
              ( $clncurnv_aarr{"$updatename"} ne '' || $updatename eq 'comment' ) )
         {
            push(@setstrs, "$updatename = ?");
            push(@setvalues, $clncurnv_aarr{"$updatename"});
         }
         else
         { delete $clncurnv_aarr{"$updatename"}; }
      }

      if ( $updatedb )
      {
         #
         # Update
         # If only one analysis record was found, then we should update it
         #

         $sql = " UPDATE $database_table SET ".join(',', @setstrs)." WHERE ".join(' AND ', @wherestrs);
         @sqlargs = (@setvalues, @wherevalues);

         #print $sql,"\n";
         #print join('|', @sqlargs)."\n";

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);
         $sth->finish();

         if ( $average eq 'hour' )
         {
            $sql = "SELECT '".$clncurnv_aarr{"site"}."', '".$clncurnv_aarr{"param"}."', date, hour, dd, intake_ht, value, unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
         }
         elsif ( $average eq 'insitu' )
         {
            if ( $project eq 'ccg_tower' )
            {
               $sql = "SELECT '".$clncurnv_aarr{"site"}."', '".$clncurnv_aarr{"param"}."', date, hr, min, sec, dd, intake_ht, value, meas_unc, random_unc, std_dev, scale_unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
            }
            else
            {
               $sql = "SELECT '".$clncurnv_aarr{"site"}."', '".$clncurnv_aarr{"param"}."', date, hr, min, sec, dd, intake_ht, value, unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
            }
         }
         @sqlargs = (@wherevalues);

         #print $sql,"\n";
         #print join('|', @sqlargs)."\n";

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);
         @tmp = $sth->fetchrow_array();
         $newline = '(UPDATE Y) '.join('|', @tmp);
         $sth->finish();

         if ( $verbose )
         {
            print STDOUT $oldline."\n";
            print STDOUT $newline."\n\n";
         }
      }
      else
      {
         # Update but do not update the database. This prints what we
         #    expect the new line to be.

         #
         # Overwrite the old associative array with the values that the
         #    current name value line that we are working on. This
         #    simulates an update because it updates the old information
         #    with the new information
         #
         @clncurnv_keyarr = keys %clncurnv_aarr;
         foreach $key ( @clncurnv_keyarr )
         { $oldnv_aarr->{$key} = $clncurnv_aarr{$key}; }

         if ( $average eq 'hour' )
         {
            $newline = '(UPDATE N) '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
         }
         elsif ( $average eq 'insitu' )
         {
            if ( $project eq 'ccg_tower' )
            {
               $newline = '(UPDATE N) '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"},$oldnv_aarr->{"mn"}, $oldnv_aarr->{"sc"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"meas_unc"}, $oldnv_aarr->{"random_unc"}, $oldnv_aarr->{"std_dev"}, $oldnv_aarr->{"scale_unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
            }
            else
            {
               $newline = '(UPDATE N) '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"},$oldnv_aarr->{"mn"}, $oldnv_aarr->{"sc"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
            }
         }

         if ( $verbose )
         {
            print STDOUT $oldline."\n";
            print STDOUT $newline."\n\n";
         }
      }
   }
   elsif ( $#results > 1 )
   {
      print STDERR "ERROR: ${line} (Multiple matches found in database.)\n";
   }
   else
   {
      # insert

      if ( $updatedb )
      {
         # When inserting an entry into the database, an analysis
         #    value must be specified
         @clncurnv_keyarr = keys %clncurnv_aarr;
         if ( in_array('value', @clncurnv_keyarr) )
         {
            #
            # IMPORTANT NOTE
            # I remove the unnecessary fields from the associative array
            #    because when I insert into the database, I use the
            #    keys and values of the associative array. By removing
            #    the unnecessary fields, it allows for very clean
            #    code
            #

            $site = $clncurnv_aarr{"site"};
            $param = $clncurnv_aarr{"param"};

            # Remove parameter and site information
            delete $clncurnv_aarr{"param"};
            delete $clncurnv_aarr{"parameter_num"};
            delete $clncurnv_aarr{"site"};
            delete $clncurnv_aarr{"site_num"};

            # Remove yr, mo, dy from the associative array now that we are done
            #    with them. Please see IMPORTANT NOTE for explaination
            delete $clncurnv_aarr{"yr"};
            delete $clncurnv_aarr{"mo"};
            delete $clncurnv_aarr{"dy"};

            if ( $average eq 'hour' )
            {
               $clncurnv_aarr{"hour"} = $clncurnv_aarr{"hr"};
               delete $clncurnv_aarr{"hr"};
            }
            if ( $average eq 'insitu' )
            {
               # Rename the fields to the ones in the database
               $clncurnv_aarr{"min"} = $clncurnv_aarr{"mn"};
               $clncurnv_aarr{"sec"} = $clncurnv_aarr{"sc"};
               delete $clncurnv_aarr{"mn"};
               delete $clncurnv_aarr{"sc"};
            }

            $sql = " INSERT INTO $database_table (".join(',', keys(%clncurnv_aarr)).") VALUES (".join(',', ('?') x keys(%clncurnv_aarr)).")";
            @sqlargs = values(%clncurnv_aarr);

            #print $sql."\n";
            #print join('|', @sqlargs)."\n";

            $sth = $dbh->prepare($sql);
            $sth->execute(@sqlargs);
            $sth->finish();

            if ( $average eq 'hour' )
            {
               $sql = "SELECT '$site', '$param', date, hour, dd, intake_ht, value, unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
            }
            elsif ( $average eq 'insitu' )
            {
               if ( $project eq 'ccg_tower' )
               {
                  $sql = "SELECT '$site', '$param', date, hr, min, sec, dd, intake_ht, value, meas_unc, random_unc, std_dev, scale_unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
               }
               else
               {
                  $sql = "SELECT '$site', '$param', date, hr, min, sec, dd, intake_ht, value, unc, n, flag, inst FROM $database_table WHERE ".join(' AND ', @wherestrs);
               }
            }
            @sqlargs = (@wherevalues);

            #print $sql,"\n";
            #print join('|', @sqlargs)."\n";

            $sth = $dbh->prepare($sql);
            $sth->execute(@sqlargs);
            @tmp = $sth->fetchrow_array();
            $newline = '(INSERT Y) '.join('|', @tmp);
            $sth->finish();

            if ( $verbose )
            {
               print STDOUT $newline."\n\n";
            }
         }
         else
         {
            if ( in_array('value', @updatenames ) )
            {
               # If value was set to be updated but it is not in the data associative array,
               #    it means that it could not be found in the input string.
               print STDERR "ERROR: ${line} ( 'value' name value pair must be in input string. )\n";
            }
            else
            {
               # The value was not set to be updated and it was not found in the data
               #    associative array
               print STDERR "ERROR: ${line} ( 'value' keyword must be set when inserting into database. )\n";
            }
            next;
         }
      }
      else
      {
         #
         # Insert, but do not update the database. This prints what
         #    we expect the new line to be.
         #

         # Get the defaults from $database_table
         $sql = "DESCRIBE $database_table";

         #print $sql,"\n";
         $sth = $dbh->prepare($sql);
         $sth->execute();

         while (@tmp = $sth->fetchrow_array())
         { $oldnv_aarr->{$tmp[0]} = $tmp[4]; }
         $sth->finish();

         #
         # Copy the new values over the default values. This
         #    simulates an insert. On an insert, any
         #    unspecified fields are set to their defaults.
         #    So, we get the defaults from the database
         #    and copy the new information over it so that
         #    any unspecified fields are set to the default.
         #
         @clncurnv_keyarr = keys %clncurnv_aarr;
         foreach $key ( @clncurnv_keyarr )
         { $oldnv_aarr->{$key} = $clncurnv_aarr{$key}; }

         if ( $average eq 'hour' )
         {
            $newline = '(INSERT N) '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
         }
         elsif ( $average eq 'insitu' )
         {
            if ( $project eq 'ccg_tower' )
            {
               $newline = '(INSERT N) '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"},$oldnv_aarr->{"mn"}, $oldnv_aarr->{"sc"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"meas_unc"}, $oldnv_aarr->{"random_unc"}, $oldnv_aarr->{"std_dev"}, $oldnv_aarr->{"scale_unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
            }
            else
            {
               $newline = '(INSERT N) '.join('|', $oldnv_aarr->{"site"}, $oldnv_aarr->{"param"}, $oldnv_aarr->{"date"}, $oldnv_aarr->{"hr"},$oldnv_aarr->{"mn"}, $oldnv_aarr->{"sc"}, $oldnv_aarr->{"dd"}, $oldnv_aarr->{"intake_ht"}, $oldnv_aarr->{"value"}, $oldnv_aarr->{"unc"}, $oldnv_aarr->{"n"}, $oldnv_aarr->{"flag"}, $oldnv_aarr->{"inst"});
            }
         }

         if ( $verbose )
         {
            print STDOUT $newline."\n\n";
         }
      }
   }
}

#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
exit;
#
#######################################
# Subroutines
#######################################
#
sub QCflag()
{
   my ($old, $new) = @_;
   #
   # Logic for retaining and overwriting existing QC flags
   #
   # Overwrite an existing 1st column flag IF an existing 1st column flag IS '*' OR '.'
   # OR the new flag has an '*' in the 1st column
   #
   # Never overwrite an existing 2nd column flag
   # Never overwrite an existing 3rd column flag
   #
   ($f1,$f2,$f3) = split //, $old;
   ($n1,$n2,$n3) = split //, $new;

   if ($f1 eq '*' || $f1 eq '.' || $n1 eq '*') { $f1 = $n1; }
   if ($f2 eq '.') { $f2 = $n2; }
   if ($f3 eq '.') { $f3 = $n3; }
   
   return $f1.$f2.$f3;
}

sub quote()
{
   my ($str) = @_;
   my $nstr;
   #
   # Enclose value in single quotes and escape single quotes and backslashes
   #    is the string.
   # Please see
   # http://madhaus.utcs.utoronto.ca/local/mysqlperl.html#_E_gt_quote_str_length_
   #
   $nstr = $dbh->quote($str);

   return $nstr;
}

sub showargs()
{
   open(HELP,"| less");

   print HELP "<----------------------- HELP ----------------------->\n";
   print HELP "Navigation Keys: Arrow keys, Page Up, Page Down\n";
   print HELP "Search: /<text> (Similar to vim)\n";
   print HELP "Quit: q\n";
   print HELP "<---------------------------------------------------->\n";
   print HELP "\n";
   print HELP "\n#########################\n";
   print HELP "ccg_insituupdate.pl\n";
   print HELP "#########################\n\n";
   print HELP "**************** WARNING *****************\n";
   print HELP "This script modifies the NOAA CMDL CCGG\n";
   print HELP "measurement database.  Contact Ken Masarie\n";
   print HELP "(kenneth.masarie@noaa.gov) before using.\n";
   print HELP "******************************************\n\n";
   print HELP "Process insitu measurement results. If the 'update' keyword\n";
   print HELP " is specified, then UPDATE or INSERT the results into the NOAA\n";
   print HELP " ESRL CCGG RDBMS. The procedure uses the required name:value\n";
   print HELP " pairs (described below) to identify a unique entry in the\n";
   print HELP " database. If a unique entry is found, then UPDATE the results\n";
   print HELP " in the database. If no entry is found, then INSERT the\n";
   print HELP " results into the database. When the results are being sent\n";
   print HELP " to the database ('update' keyword is set), the interactions\n";
   print HELP " are followed by a 'Y'. For example, 'UPDATE Y' means that\n";
   print HELP " the results were UPDATEd in the database. If the 'update'\n";
   print HELP " keyword is not set, then process the results and print the\n";
   print HELP " expected interaction with the database (e.g., UPDATE or\n";
   print HELP " INSERT). Expected interactions with the database are followed\n";
   print HELP " by an 'N'.\n";
   print HELP "\n";
   print HELP " The contents of the file must contain...\n";
   print HELP "\n";
   print HELP "  One record, line or row per measurement result.\n";
   print HELP "\n";
   print HELP "   Required name:value pairs ...\n";
   print HELP "    site code (site), parameter formula (param),\n";
   print HELP "    year (yr), month (mo), day (dy), hour (hr),\n";
   print HELP "    minute (mn) and seconds (sc),\n";
   print HELP "    intake height also known as magl (intake_ht), and\n";
   print HELP "    instrument id (inst).\n";
   print HELP "\n";
   print HELP "   Optional name:value pairs ...\n";
   print HELP "    Measurement value (value), QC flag (flag), analysis\n";
   print HELP "    comment (comment), total uncertainty (unc),\n";
   print HELP "    measurement uncertainty (meas_unc),\n";
   print HELP "    random uncertainty (random_unc),\n";
   print HELP "    standard deviation (std_dev),\n";
   print HELP "    and scale uncertainty (scale_unc).\n";
   print HELP "\n";
   print HELP "   Each record, line or row must be made up of name:value\n"; 
   print HELP "   pairs delimited by pipes ('|'). Each name:value pair\n";
   print HELP "   is separated by a colon (':').\n";
   print HELP "\n";
   print HELP "   If an optional name:value pair is in the record/line/row\n";
   print HELP "   and the corresponding option (described below) IS set,\n";
   print HELP "   then the optional name:value pair will be processed.\n";
   print HELP "\n";
   print HELP "   If an optional name:value pair is in the record/line/row\n";
   print HELP "   and the corresponding option IS NOT set, then the\n";
   print HELP "   optional name:value pair is ignored.\n";
   print HELP "\n";
   print HELP "   If an optional name:value pair is NOT in the record/line/row\n";
   print HELP "   and the corresponding option IS set, then a warning will be\n";
   print HELP "   generated.\n";
   print HELP "\n";
   print HELP "  (ex)\n";
   print HELP "    site:AMT|param:CO2|yr:2012|mo:01|dy:31|hr:23|mn:59|sc:59|intake_ht:10.0|inst:L4|value:395.23|meas_unc:0.63|random_unc:0.2|std_dev:0.28|scale_unc:0.12|flag:...\n";
   print HELP "\n";
   print HELP "     Note:  File may include records/lines/rows containing\n";
   print HELP "            measurements results for one or more parameters.\n";
   print HELP "\n-------------------------------------------------------------\n";
   print HELP "Options:\n\n";
   print HELP "-average=[time resolution]\n";
   print HELP "     Specify the resolution of the input data.\n";
   print HELP "     Defaults to 'insitu' if not specified.\n";
   print HELP "     Valid values: 'hour' or 'insitu'.\n\n";
   print HELP "-comment\n";
   print HELP "     If specified, the analysis comment name:value pair\n";
   print HELP "     will be processed in each record/line/row.\n\n";
   print HELP "-f, -file=[input file]\n";
   print HELP "     Specify input file containing measurement results\n\n";
   print HELP "-flag\n";
   print HELP "     If specified, the QC flag name:value pair will be\n";
   print HELP "     processed in each record/line/row.\n\n";
   print HELP "-h, -help\n";
   print HELP "     Produce help menu\n\n";
   print HELP "-meas_unc\n";
   print HELP "     If specified, the measurement uncertainty name:value pair\n";
   print HELP "     will be processed in each record/line/row.\n\n";
   print HELP "-project=[project]\n";
   print HELP "     Required. Specify the project of the measurements.\n";
   print HELP "     For example, 'ccg_tower' or 'ccg_obs'.\n\n";
   print HELP "-random_unc\n";
   print HELP "     If specified, the random uncertainty name:value pair\n";
   print HELP "     will be processed in each record/line/row.\n\n";
   print HELP "-scale_unc\n";
   print HELP "     If specified, the scale uncertainty name:value pair\n";
   print HELP "     will be processed in each record/line/row.\n\n";
   print HELP "-std_dev\n";
   print HELP "     If specified, the standard deviation name:value pair\n";
   print HELP "     will be processed in each record/line/row.\n\n";
   print HELP "-unc\n";
   print HELP "     If specified, the uncertainty name:value pair will be\n";
   print HELP "     processed in each record/line/row.\n\n";
   print HELP "-value\n";
   print HELP "     If specified, the mixing/isotope ratio name:value pair\n";
   print HELP "     will be processed in each record/line/row.\n\n";
   print HELP "-verbose\n";
   print HELP "     If specified, print diagnostic messages to standard out.\n";
   print HELP "     If specified and the 'update' keyword is not set, the\n";
   print HELP "     program will print what it expects to do. The INSERT\n";
   print HELP "     or UPDATE message is followed by an 'N' because the\n";
   print HELP "     program is not updating the database.\n";
   print HELP "     If specified and the 'update' keyword is set, the\n";
   print HELP "     program will update the database and then query\n";
   print HELP "     for the row it just updated or inserted.i The INSERT\n";
   print HELP "     or UPDATE message is followed by a 'Y' because the\n";
   print HELP "     program is updating the database.\n";
   print HELP "     If not specified, the program will only print error\n";
   print HELP "     messages.\n\n";
   print HELP "-update\n";
   print HELP "     If specified, update the database.\n";
   print HELP "     Please see 'verbose' keyword comments.\n\n";
   print HELP "# Process the QC flag in testfile. Only errors will be\n";
   print HELP "#    printed. The CCGG database is not updated.\n";
   print HELP "(ex) ccg_insituupdate.pl -average=hour -file=testfile -flag\n\n";
   print HELP "# Process the QC flag in testfile. Only errors will be\n";
   print HELP "#    printed. Print all diagnostic messages. The CCGG\n";
   print HELP "#    database is not updated.\n";
   print HELP "(ex) ccg_insituupdate.pl -project=ccg_obs -average=hour -file=testfile -flag -verbose\n\n";
   print HELP "# Update CCGG database with information in testfile.\n";
   print HELP "#    Only update QC flag. Only errors will be\n";
   print HELP "#    printed.\n";
   print HELP "(ex) ccg_insituupdate.pl -project=ccg_obs -average=hour -file=testfile -flag -update\n\n";
   print HELP "# Update CCGG database with information in testfile.\n";
   print HELP "#    Only update QC flag. All diagnostic messages\n";
   print HELP "#    will be printed.\n";
   print HELP "(ex) ccg_insituupdate.pl -project=ccg_obs -average=hour -file=testfile -flag -update -verbose\n\n";
   close(HELP);
   exit;
}

