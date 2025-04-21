#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/validator.pl";
require "/projects/src/db/ccg_dbutils2.pl";

#
#
#       ************************** WARNING ****************************
#       This procedure modifies a U.S. Government Scientific Database.
#       Contact Ken Masarie (kenneth.masarie@noaa.gov) before using.
#       ***************************************************************
#
#       Update or Insert flask/pfp measurement results
#       into the NOAA CMDL CCGG RDBMS.
#
#       Expected format...
#
#       evn:159040|program:CCGG|param:CH4|value:1801.17|flag:...|inst:H4|yr:2004|mo:03|dy:22|hr:09|mn:11
#
# Notes
#    - '' is a valid value, but only for the comment field
#    - To redirect standard out and standard error to
#      different files, use the following command in bash shell:
#      ccg_flaskupdate.pl -file=testfile 1>stdout.txt 2>stderr.txt
# 
# Programmer notes
#    - This should be the only perl script to actually update the database
#
#
#JWM- 4/16 - added support for new tagging system.  We basically pass any flag updates off to ccg_addtag.pl
#See notes below for details.
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "comment", "file|f=s", "flag", "help|h", "nopreserve", "unc", "update|u", "value", "verbose","dev");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }
if (!($Options{file})) { &showargs() }

$file = $Options{file};
$nopreserve = $Options{nopreserve};
$updatedb = $Options{update};
$verbose = $Options{verbose};

#
#######################################
# Initialization
#######################################
#
# Optional fields
@optionalnames = ( );

#
# Required fields to update
#
@requirednames = ( 'evn', 'program', 'param', 'inst', 'yr', 'mo', 'dy', 'hr', 'mn', 'sc');

#
# Fields that can be updated
#
@setnames = ( 'comment', 'flag', 'value', 'unc' );

# Assign the fields that we are going to update/insert based on the flags
@updatenames = ();
if ( $Options{comment} ) { push(@updatenames, "comment") };
if ( $Options{flag} ) { push(@updatenames, "flag") };
if ( $Options{value} ) { push(@updatenames, "value") };
if ( $Options{unc} ) { push(@updatenames, "unc") };

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
if($Options{dev}){demodb();}#Passing dev option, switch to mund_dev db (testing purposes).


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
   @nvpairs = split(/\|/, $line);

   $err = '';
   foreach $nv ( @nvpairs )
   {
      #
      # Split the name value pair into name and value
      #
      ($name, $value) = split(':', $nv, 2);

      # Remove leading spaces in the value
      $value =~ s/^\s+//g;

      # If the user specified an unrecognized field, then alert them
      if ( in_array($name,@optionalnames) ||
           in_array($name,@requirednames) ||
           in_array($name,@setnames) )
      { $curnv_aarr{"$name"} = $value; }
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

   $err = '';
   $warning = '';
   # Check if there is a value for each field set to be updated.
   #    However, the comment field can have an empty value.
   foreach $updatename ( @updatenames )
   {
      if (exists($curnv_aarr{$updatename}) )
      {
         if ( $updatename ne 'comment' && $curnv_aarr{$updatename} eq '' )
         {
            $errstr = "Field '${updatename}' is set for update with no value.";
            $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
         }
      }
      else
      {
         $warningstr = "Field '${updatename}' is set for update but not in input string.";
         $warning = ( $warning eq '' ) ? $warningstr : $warning." ".$warningstr;
      }
   }

   # Print warnings, if there are any
   if ( $warning ne '' )
   {
      print STDERR "WARNING: ${line} ( $warning )\n";
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
   # Get and check program number
   #
   $curnv_aarr{"program_num"} = &get_field("num","gmd.program","abbr",$curnv_aarr{"program"});
   #
   # Get and check parameter number
   #
   $curnv_aarr{"parameter_num"} = &get_field("num","gmd.parameter","formula",$curnv_aarr{"param"});
   my $parameter=$curnv_aarr{"param"};#Save off for use by tag script call.
   #
   ########################
   # Validate the input
   ########################
   #

   $err = '';

   # Check evn
   if ( &ValidInt($curnv_aarr{"evn"}) && $curnv_aarr{"evn"} > 0 )
   { $clncurnv_aarr{"evn"} = $curnv_aarr{"evn"}; }
   else
   {
      $errstr = "'evn' provided must be an integer and greater than 0.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check program_num
   if ( &ValidInt($curnv_aarr{"program_num"}) && $curnv_aarr{"program_num"} > 0 )
   { $clncurnv_aarr{"program_num"} = $curnv_aarr{"program_num"}; }
   else
   {
      $errstr = "Program abbr '".$curnv_aarr{"program"}."' not found.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check parameter_num
   if ( &ValidInt($curnv_aarr{"parameter_num"}) && $curnv_aarr{"parameter_num"} > 0 )
   { $clncurnv_aarr{"parameter_num"} = $curnv_aarr{"parameter_num"}; }
   else
   {
      $errstr = "Parameter formula '".$curnv_aarr{"param"}."' not found.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }

   # Check inst
   if ( $curnv_aarr{"inst"} =~ /^[A-Za-z0-9]{2,4}$/ )
   { $clncurnv_aarr{"inst"} = $curnv_aarr{"inst"}; }
   else
   {
      $errstr = "Instrument ID must be between 2 and 4 alphanumeric characters.";
      $err = ( $err eq '' ) ? $errstr : $err." ".$errstr;
   }
   
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

   # Rename key "evn" to key "event_num" to be consistent with the
   #    field in the database. This is so I can cleanly create
   #    the insert statement
   $clncurnv_aarr{"event_num"} = $clncurnv_aarr{"evn"};
   delete $clncurnv_aarr{"evn"};

   # At this point, "program_num" is the key we want to keep, so
   #    remove "program"
   delete $clncurnv_aarr{"program"};

   # At this point, "parameter_num" is the key we want to keep, so
   #    remove "param"
   delete $clncurnv_aarr{"param"};

   # Remove leading zeroes from the event number
   $clncurnv_aarr{"event_num"} =~ s/^0+//g;

   # Since sc (seconds) is optional, if it is not set then set it to 0
   if ( !exists($clncurnv_aarr{"sc"}) )  { $clncurnv_aarr{"sc"} = 0; }

   # Set the date, time, and dd values in the associate array
   $clncurnv_aarr{"date"} = sprintf("%4d-%02d-%02d", $clncurnv_aarr{"yr"}, $clncurnv_aarr{"mo"}, $clncurnv_aarr{"dy"});
   $clncurnv_aarr{"time"} = sprintf("%02d:%02d:%02d", $clncurnv_aarr{"hr"}, $clncurnv_aarr{"mn"}, $clncurnv_aarr{"sc"});
   $clncurnv_aarr{"dd"} = &date2dec($clncurnv_aarr{"yr"},$clncurnv_aarr{"mo"},$clncurnv_aarr{"dy"},$clncurnv_aarr{"hr"},$clncurnv_aarr{"mn"},$clncurnv_aarr{"sc"});
   # Remove yr, mo, dy from the associative array now that we are done
   #    with them. Please see IMPORTANT NOTE for explaination
   delete $clncurnv_aarr{"yr"};
   delete $clncurnv_aarr{"mo"};
   delete $clncurnv_aarr{"dy"};
   # Remove hr, mn, sc from the associative array now that we are done
   #    with them. Please see IMPORTANT NOTE for explaination
   delete $clncurnv_aarr{"hr"};
   delete $clncurnv_aarr{"mn"};
   delete $clncurnv_aarr{"sc"};

   # Only update/insert the fields that the user specified.
   #    Remove the ones that were set in the file but will
   #    not be updated/inserted to the database. Please see
   #    the IMPORTANT NOTE
   foreach $setname ( @setnames )
   {
      if ( ! in_array($setname,@updatenames) )
      { delete $clncurnv_aarr{"$setname"}; }
   }
   #New flag logic uses the ccg_addtag.pl script to handle flag/tags.  So we'll pull here (if present)
   #so the below update/insert logic doesn't attempt to modify flags.
   my $tagUpdateCmd=""; 
   my $newflag="";
   if ( exists($clncurnv_aarr{"flag"})){
	my $mergeMode=($nopreserve)?2:1;#2 clobber mode:1 is same as qcflag logic below..
	$newflag=$clncurnv_aarr{"flag"};
	my $productionDB=($Options{dev})?0:1;#use prod or demo db.
	my $tagupdate=($updatedb)?"-update":"";
	my $verbose=($verbose)?"-verbose":"";
	$verbose='';#Verbose actually caused problems because it blew up the output causing an error looping through the output in ccg_flaskupdate.pro
	
	#Remove the flag nv from the clean array so it doesn't get processed below.
	delete $clncurnv_aarr{"flag"};
	
	#build up the perl cmd to update flag/tag.	
	my $perlScript="/ccg/src/db/ccg_addtag.pl";
	my $args="-f='$newflag' -event_num=".$clncurnv_aarr{"event_num"};
	$args.=" -parameter=$parameter";
	$args.=" -adate='".$clncurnv_aarr{"date"}."'";
	$args.=" -atime='".$clncurnv_aarr{"time"}."'";
	$args.=" -inst=".$clncurnv_aarr{"inst"};
	$args.=" -productionDB=$productionDB -mergeMode=$mergeMode $tagupdate $verbose";
	$tagUpdateCmd="$perlScript $args";
   }
   #
   # Does event number exist in DB?
   #
   $sql = "SELECT num FROM flask_event WHERE num=".&quote($clncurnv_aarr{"event_num"});
   #print $sql."\n";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   $rows = $sth->rows;
   $sth->finish();
   if ( $rows == 1)
   {
      # One match found

      #
      # Does analysis result already exist?
      #
      $select = "SELECT event_num,program_num,parameter_num,value,unc,flag,inst,date,time,dd,comment";
      $from = " FROM flask_data";
      $where = " WHERE event_num=".&quote($clncurnv_aarr{"event_num"});
      $and = " AND program_num=".&quote($clncurnv_aarr{"program_num"});
      $and = "${and} AND parameter_num=".&quote($clncurnv_aarr{"parameter_num"});
      $and = "${and} AND inst=".&quote($clncurnv_aarr{"inst"});
      $and = "${and} AND date=".&quote($clncurnv_aarr{"date"});
      $and = "${and} AND time=".&quote($clncurnv_aarr{"time"});
      $sql = $select.$from.$where.$and;

      #print $sql."\n";
      $sth = $dbh->prepare($sql);
      $sth->execute();

      @records = ();
      $nrecords = 0;

      while (@tmp = $sth->fetchrow_array()) { @records[$nrecords++] = join('|',@tmp) }
      $sth->finish();

      if ($nrecords == 1)
      {
         #
         # Update
         # If only one analysis record was found, then we should update it
         #

         @oldfieldarr = split '\|', $records[0], 11;

         # Define the old string
         $oldline = "(OLD)      ".join('|', @oldfieldarr);

         #
         # Apply flag logic, if the flag exists
         # The logic was moved above so can be shared with insert case.  Leaving commented old code below for reference.
         
         #if ( exists($clncurnv_aarr{"flag"}) && ! $nopreserve )
         #{
         #   $clncurnv_aarr{"flag"} = &QCflag($oldflag,$clncurnv_aarr{"flag"});
         #}

         if ( $updatedb )
         {
            #
            # Update the database
            #

            $update = "UPDATE flask_data";

            $set = '';
            foreach $updatename ( @updatenames )
            {
               #
               # If the field exists in the associative array,
               #    then it must have a value unless it is the
               #    comment field. Note we handle flag updates below.
               #
               if ( exists($clncurnv_aarr{"$updatename"})  &&
                    ( $clncurnv_aarr{"$updatename"} ne '' || $updatename eq 'comment' ) )
               {
                  $set = ( $set eq '' ) ? " SET $updatename = ".&quote($clncurnv_aarr{"$updatename"}) : $set.", $updatename = ".&quote($clncurnv_aarr{"$updatename"});
               }
            }
            $where = " WHERE event_num=".&quote($clncurnv_aarr{"event_num"});
            $and = " AND program_num=".&quote($clncurnv_aarr{"program_num"});
            $and = "${and} AND parameter_num=".&quote($clncurnv_aarr{"parameter_num"});
            $and = "${and} AND inst=".&quote($clncurnv_aarr{"inst"});
            $and = "${and} AND date=".&quote($clncurnv_aarr{"date"});
            $and = "${and} AND time=".&quote($clncurnv_aarr{"time"});
            #$and = "${and} AND dd='${dd}'";
            $sql = $update.$set.$where.$and;

            #print $sql,"\n";
            
	    #If flag was the only field getting updated, we won't have anything to update here (because we removed it from array above),
            #so skip the update
            if($set){
            	$sth = $dbh->prepare($sql);
            	$sth->execute();
            	$sth->finish();
	    }
		
	    #Now make call to update flag if needed.
	    if($tagUpdateCmd){
		my $status=system($tagUpdateCmd);
		if($status != 0){
			print STDERR "ERROR: ${tagUpdateCmd} ( $status )\n";
      			next;				
		}
	    }
	 
            $select = "SELECT event_num,program_num,parameter_num,value,unc,flag,inst,date,time,dd,comment";
            $from = " FROM flask_data";
            $sql = $select.$from.$where.$and;

            #print $sql,"\n";
            $sth = $dbh->prepare($sql);
            $sth->execute();
            @tmp = $sth->fetchrow_array();
            $newline = '(UPDATE Y) '.join('|', @tmp);
            $sth->finish();
         }
         else
         {
            #
            # Update but do not update the database. This prints what we
            #    expect the new line to be.
            #

            #
            # Copy the fields from the database into the appropriate keys in
            #    the old associative array.
            #
            $oldnv_aarr{"event_num"} = $oldfieldarr[0];
            $oldnv_aarr{"program_num"} = $oldfieldarr[1];
            $oldnv_aarr{"parameter_num"} = $oldfieldarr[2];
            $oldnv_aarr{"value"} = $oldfieldarr[3];
            $oldnv_aarr{"unc"} = $oldfieldarr[4];
            $oldnv_aarr{"flag"} = $oldfieldarr[5];
            $oldnv_aarr{"inst"} = $oldfieldarr[6];
            $oldnv_aarr{"date"} = $oldfieldarr[7];
            $oldnv_aarr{"time"} = $oldfieldarr[8];
            $oldnv_aarr{"dd"} = $oldfieldarr[9];
            $oldnv_aarr{"comment"} = $oldfieldarr[10];

            #
            # Overwrite the old associative array with the values that the
            #    current name value line that we are working on. This
            #    simulates an update because it updates the old information
            #    with the new information
            #
            @clncurnv_keyarr = keys %clncurnv_aarr;
            foreach $key ( @clncurnv_keyarr )
            { $oldnv_aarr{$key} = $clncurnv_aarr{$key}; }
	    if($tagUpdateCmd){
		#update the tag too (not in the clncurnv array anymore)
		$oldnv_aarr{flag}=$newflag;
	    }
	    #                                                                                                                        }
            # Create the output string without updating the database (N)
            $newline = '(UPDATE N) '.$oldnv_aarr{"event_num"}.'|'.$oldnv_aarr{"program_num"}.'|'.$oldnv_aarr{"parameter_num"}.'|'.$oldnv_aarr{"value"}.'|'.$oldnv_aarr{"unc"}.'|'.$oldnv_aarr{"flag"}.'|'.$oldnv_aarr{"inst"}.'|'.$oldnv_aarr{"date"}.'|'.$oldnv_aarr{"time"}.'|'.$oldnv_aarr{"dd"}.'|'.$oldnv_aarr{"comment"};
            
         }

         if ( $verbose )
         {
            print STDOUT $oldline."\n";
            print STDOUT $newline."\n\n";
         }
      }
      elsif ( $nrecords > 1 )
      {
         print STDERR "ERROR: ${line} (Multiple matches found in database.)\n";
      }
      else
      {
         # insert

         # When inserting an entry into the database, an analysis
         #    value must be specified
         @clncurnv_keyarr = keys %clncurnv_aarr;
         if ( in_array('value', @clncurnv_keyarr) )
         {
            if ( $updatedb )
            {
               #
               # Insert into the database.
               #

               #
               # IMPORTANT NOTE
               # I remove the unnecessary fields from the associative array
               #    because when I insert into the database, I use the
               #    keys and values of the associative array. By removing
               #    the unnecessary fields, it allows for very clean
               #    code
               #

               # Quote all the values
               foreach $key ( @clncurnv_keyarr )
               { $q_clncurnv_aarr{$key} = &quote($clncurnv_aarr{$key}); }

               $insert = "INSERT INTO flask_data";
               $list = " (".join(",",keys %q_clncurnv_aarr).")";
               $values = " VALUES (".join(",",values %q_clncurnv_aarr).")";
               $sql = $insert.$list.$values;

               #print $sql,"\n";
               $sth = $dbh->prepare($sql);
               $sth->execute();
               $sth->finish();
		
		#update the flag if needed
		if($tagUpdateCmd){
			my $status=system($tagUpdateCmd);
			if($status != 0){
				print STDERR "ERROR: ${tagUpdateCmd} ( $status )\n";
				next;
			}
	        }
               #
               # Get the field that we just inserted
               #
               $select = "SELECT event_num,program_num,parameter_num,value,unc,flag,inst,date,time,dd,comment";
               $from = " FROM flask_data";
               $where = " WHERE event_num=".&quote($clncurnv_aarr{"event_num"});
               $and = " AND program_num=".&quote($clncurnv_aarr{"program_num"});
               $and = "${and} AND parameter_num=".&quote($clncurnv_aarr{"parameter_num"});
               $and = "${and} AND inst=".&quote($clncurnv_aarr{"inst"});
               $and = "${and} AND date=".&quote($clncurnv_aarr{"date"});
               $and = "${and} AND time=".&quote($clncurnv_aarr{"time"});
               $sql = $select.$from.$where.$and;

               #print $sql,"\n";
               $sth = $dbh->prepare($sql);
               $sth->execute();
               @tmp = $sth->fetchrow_array();
               $newline = "(INSERT Y) ".join('|', @tmp);
               $sth->finish();
            }
            else
            {
               #
               # Insert, but do not update the database. This prints what
               #    we expect the new line to be.
               #

               # Get the defaults from flask_data
               $sql = "DESCRIBE flask_data";

               #print $sql,"\n";
               $sth = $dbh->prepare($sql);
               $sth->execute();

               while (@tmp = $sth->fetchrow_array())
               { $oldnv_aarr{$tmp[0]} = $tmp[4]; }
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
               { $oldnv_aarr{$key} = $clncurnv_aarr{$key}; }

		if($tagUpdateCmd){
			#update the tag too (not in the clncurnv array anymore
			$oldnv_aarr{flag}=$newflag;
	    	}

               $newline = '(INSERT N) '.$oldnv_aarr{"event_num"}.'|'.$oldnv_aarr{"program_num"}.'|'.$oldnv_aarr{"parameter_num"}.'|'.$oldnv_aarr{"value"}.'|'.$oldnv_aarr{"unc"}.'|'.$oldnv_aarr{"flag"}.'|'.$oldnv_aarr{"inst"}.'|'.$oldnv_aarr{"date"}.'|'.$oldnv_aarr{"time"}.'|'.$oldnv_aarr{"dd"}.'|'.$oldnv_aarr{"comment"};
            }

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
   }
   else
   {
      # No matches found
      print STDERR "ERROR: ${line} (Event '".$clncurnv_aarr{"event_num"}."' not found.)\n";
print STDERR "\n".$clncurnv_aarr{'flag'}."\n";	
      next;
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
   # NOTE! this is no longer called.  This logic is now encapsulated in ccg_addtag.pl.  See that for details.
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
   print HELP "ccg_flaskupdate.pl\n";
   print HELP "#########################\n\n";
   print HELP "**************** WARNING *****************\n";
   print HELP "This script modifies the NOAA CMDL CCGG\n";
   print HELP "measurement database.  Contact Ken Masarie\n";
   print HELP "(kenneth.masarie@noaa.gov) before using.\n";
   print HELP "******************************************\n\n";
   print HELP "Process flask/pfp measurement results. If the 'update' keyword\n";
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
   print HELP "    Event number (evn), program abbreviation (program),\n";
   print HELP "    parameter formula (param),\n";
   print HELP "    2-character instrument Id (inst), analysis\n";
   print HELP "    year (yr), month (mo), day (dy), hour (hr),\n";
   print HELP "    minute (mn) and seconds (sc). Please note that\n";
   print HELP "    the analysis date and time are in local time.\n";
   print HELP "\n";
   print HELP "   Optional name:value pairs ...\n";
   print HELP "    Measurement value (value), QC flag (flag), analysis\n";
   print HELP "    comment (comment), and uncertainty (unc).\n";
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
   print HELP "   evn:159040|program:CCGG|param:ch4|value:1801.17|flag:...|inst:H4|yr:2004|mo:03|dy:22|hr:09|mn:11\n";
   print HELP "  (ex)\n";
   print HELP "   evn:105424|program:CCGG|param:co2o18|value:0.5670|flag:...|inst:o1|yr:2003|mo:05|dy:21|hr:18|mn:26\n";
   print HELP "\n";
   print HELP "     Note:  File may include records/lines/rows containing\n";
   print HELP "            measurements results for one or more parameters.\n";
   print HELP "\n-------------------------------------------------------------\n";
   print HELP "Options:\n\n";
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
   print HELP "-nopreserve\n";
   print HELP "     If specified and 'flag' keyword is also\n"; 
   print HELP "     specified, use the value of the QC flag\n";
   print HELP "     name:value pair but DO NOT apply flag logic.\n";
   print HELP "\n";
   print HELP "     If not specified but the 'flag' keyword is\n";
   print HELP "     specified, use the value of the QC flag\n";
   print HELP "     name:value pair and DO apply flag logic.\n";
   print HELP "\n";
   print HELP "     Flag logic:\n";
   print HELP "      Overwrite an existing 1st column flag if an\n";
   print HELP "         existing 1st column flag is '*' OR '.'\n";
   print HELP "         OR the new flag has an '*' in the 1st\n";
   print HELP "         column.\n";
   print HELP "      Never overwrite an existing 2nd column flag\n";
   print HELP "      Never overwrite an existing 3rd column flag\n\n";
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
   print HELP "(ex) ccg_flaskupdate.pl -file=testfile -flag\n\n";
   print HELP "# Process the QC flag in testfile. Only errors will be\n";
   print HELP "#    printed. Print all diagnostic messages. The CCGG\n";
   print HELP "#    database is not updated.\n";
   print HELP "(ex) ccg_flaskupdate.pl -file=testfile -flag -verbose\n\n";
   print HELP "# Update CCGG database with information in testfile.\n";
   print HELP "#    Only update QC flag. Only errors will be\n";
   print HELP "#    printed.\n";
   print HELP "(ex) ccg_flaskupdate.pl -file=testfile -flag -update\n\n";
   print HELP "# Update CCGG database with information in testfile.\n";
   print HELP "#    Only update QC flag. All diagnostic messages\n";
   print HELP "#    will be printed.\n";
   print HELP "(ex) ccg_flaskupdate.pl -file=testfile -flag -update -verbose\n\n";
   close(HELP);
   exit;
}

