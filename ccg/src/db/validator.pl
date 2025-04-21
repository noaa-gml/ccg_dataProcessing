#
# Form validation functions
#

use POSIX;

if ( $ENV{'CCG_PERLLIBDIR'} ne '' )
{ $CCG_PERLLIBDIR = $ENV{'CCG_PERLLIBDIR'}; }
else
{ $CCG_PERLLIBDIR = '/projects/src'; }

require "$CCG_PERLLIBDIR/db/validator.pl";

#
##################################
# Field validating functions
##################################
#
sub isBlank
{
   my ($val) = @_;
   my $char;

   # This is similar to the empty() check in PHP
   if ( $val eq '' || $val eq '0' || &isNULL($val) ) { return 1; }

   foreach (split //, $val)
   {
      $char = $_;

      if ( $char =~ m/[^ \t\n\r]/ ) { return 0; }
   }

   return 1;
}

sub ValidDate
{
   my ($d_val) = @_;

   if ( &isBlank($d_val) ) { return 0; }

   $d_val = &trim($d_val);

   if ( $d_val !~ m/^[0-9]{4}\-[0-9]{1,2}\-[0-9]{1,2}$/ ) { return 0; }

   my ($yr, $mo, $dy) = split(/\-/, $d_val);

   # Allow default date
   if ( $yr eq '0000' and $mo eq '00' and $dy eq '00' ) { return 1; }

   # Check year
   if ( ! &ValidinRange($yr,'1900','9999','int') ) { return 0; }

   # Check month
   if ( ! &ValidinRange($mo,'1','12','int') ) { return 0; }

   # Check day

   # First entry is 0 so that the index matches the month
   @lastdom = ( 0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 );

   my $leap = &leapyear($yr);
   if ( $leap ) { $lastdom[2] = 29; }

   $lastday = $lastdom[$mo];

   if ( ! &ValidinRange($dy,'1',$lastday,'int') ) { return 0; }

   return 1;   
}

sub ValidDatetime
{
   my ($dt_val) = @_;

   if ( &isBlank($dt_val) ) { return 0; }

   $dt_val = &trim($dt_val);

   my ( $date, $time ) = split (/\s/, $dt_val);

   if ( &ValidDate($date) && &ValidTime($time) )
   { return 1; }
   else
   { return 0; }
}

sub ValidFloat
{
   my ($flt_val) = @_;

   $flt_val = &trim($flt_val);

   # The regular expression reads
   # Match the string that begins with 0 or 1 -'s
   # Then 0 or more characters between 0 and 9 followed by
   #    0 or 1 periods followed by 1 or more characters between 0 and 9
   # OR
   # 1 or more characters between 0 and 0 followed by
   #    0 or 1 periods followed by 0 or more characters between 0 and 9
   if ( $flt_val =~ m/^-?([0-9]*\.?[0-9]+|[0-9]+\.?[0-9]*)$/ ) { return 1; }

   return 0;
}

sub ValidinRange
{
   my ($value, $min, $max, $type ) = @_;

   $value = &trim($value);
   $min = &trim($min);
   $max = &trim($max);
   $type = &trim($type);

   if ( &isBlank($type) ) { $type = "other"; }

   if ( $type eq 'date' )
   {
      if ( ! &ValidDate($value) ) { return 0; }

      my ($yr, $mo, $dy) = split(/\-/, $value);

      my $dec = &date2dec($yr, $mo, $dy, 12, 0);

      if ( ! &isNULL($min) )
      {
         if ( ! &ValidDate($min) ) { return 0; }

         my ($minyr, $minmo, $mindy) = split(/\-/, $min);
         my $mindec = &date2dec($minyr, $minmo, $mindy, 12, 0);
         if ( $dec < $mindec ) { return 0; }
      }

      if ( ! &isNULL($max) )
      {
         if ( ! &ValidDate($max) ) { return 0; }

         my ($maxyr, $maxmo, $maxdy) = split(/\-/, $max);
         my $maxdec = &date2dec($maxyr, $maxmo, $maxdy, 12, 0);
         if ( $dec > $maxdec ) { return 0; }
      }
      return 1;
   }
   elsif ( $type eq 'time' )
   {
      if ( ! &ValidTime($value) ) { return 0; }

      my ($hr, $mn, $sc) = split(/:/, $value);

      my $dec = &date2dec(2000, 1, 1, $hr, $mn, $sc);

      if ( ! &isNULL($min) )
      {
         if ( ! &ValidTime($min) ) { return 0; }

         my ($minhr, $minmn, $minsc) = split(/\-/, $min);
         my $mindec = &date2dec(2000, 1, 1, $minhr, $minmn, $minsc);
         if ( $dec < $mindec ) { return 0; }
      }

      if ( ! &isNULL($max) )
      {
         if ( ! &ValidDate($max) ) { return 0; }

         my ($maxhr, $maxmn, $maxsc) = split(/\-/, $max);
         my $maxdec = &date2dec(2000, 1, 1, $maxhr, $maxmn, $maxsc);
         if ( $dec > $maxdec ) { return 0; }
      }
      return 1;
   }
   elsif ( $type eq 'int' )
   {
      if ( ! &ValidInt($value) ) { return 0; }

      if ( ! &isNULL($min) )
      {
         if ( ! &ValidInt($min) ) { return 0; }
         if ( $value < $min ) { return 0; }
      }

      if ( ! &isNULL($max) )
      {
         if ( ! &ValidInt($max) ) { return 0; }
         if ( $value > $max ) { return 0; }
      }

      return 1;
   }
   elsif ( $type eq 'float' )
   {
      if ( ! &ValidFloat($value) ) { return 0; }

      if ( ! &isNULL($min) )
      {
         if ( ! &ValidFloat($min) ) { return 0; }
         if ( $value < $min ) { return 0; }
      }

      if ( ! &isNULL($max) )
      {
         if ( ! &ValidFloat($max) ) { return 0; }
         if ( $value > $max ) { return 0; }
      }
      return 1;

   }
   elsif ( $type eq 'char' )
   {
      if ( ! &isNULL($min) )
      { if ( $value lt $min ) { return 0; } }
      if ( ! &isNULL($max) )
      { if ( $value gt $max ) { return 0; } }
      return 1;
   }
   else
   {
      if ( ! &isNULL($min) )
      { if ( $value < $min ) { return 0; } }
      if ( ! &isNULL($max) )
      { if ( $value > $max ) { return 0; } }
      return 1;
   }

   return 0;
}

sub ValidInt
{
   my ($int_val) = @_;

   $int_val = &trim($int_val);

   if ( $int_val =~ m/^-?[0-9]+$/ ) { return 1; }

   return 0;
}

sub ValidLength
{
   my ($value, $min, $max) = @_;

   $value = &trim($value);
   $min = &trim($min);
   $max = &trim($max);

   if ( ! &ValidInt($min) ) { return 0; }
   if ( ! &ValidInt($max) ) { return 0; }

   if ( length($value) < $min ) { return 0; }
   if ( length($value) > $max ) { return 0; }

   return 1;
}

sub ValidTime
{
   my ($t_val) = @_;

   if ( &isBlank($t_val) ) { return 0; }

   $t_val = &trim($t_val);

   # If only the hour and minute were specified, add the seconds
   if ( $t_val =~ m/^[0-9]{1,2}:[0-9]{2}$/ )
   { $t_val = $t_val.":00"; }

   if ( $t_val !~ /^[0-9]{1,2}:[0-9]{2}:[0-9]{2}$/ )
   { return 0; }

   my ($hr, $mn, $sc) = split(/:/, $t_val);

   if ( ! &ValidinRange($hr,"0","23","int") ) { return 0; }
   if ( ! &ValidinRange($mn,"0","59","int") ) { return 0; }
   if ( ! &ValidinRange($sc,"0","59","int") ) { return 0; }

   ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime (time);

   ($chksc, $chkmn, $chkhr, $junk) = localtime(mktime ($sc, $mn, $hr, $mday, $mon, $year, $wday, $yday, $isdst));

   $t_chk1 = sprintf("%02d:%02d:%02d", $chkhr, $chkmn, $chksc);
   $t_chk2 = sprintf("%1d:%02d:%02d", $chkhr, $chkmn, $chksc);

   if ( $t_val eq $t_chk1 || $t_val eq $t_chk2 ) { return 1; }
   return 0;
}

#
##################################
# Single character validating functions
##################################
#
sub isAlphaNum
{
   my ($val) = @_;

   if ( &isLetter($val) || &isDigit($val) ) { return 1; }
   return 0;
}

sub isDigit
{
   my ($val) = @_;

   if ( length($val) > 1 ) { return 0; }
   if ( $val =~ m/^[0-9]$/ ) { return 1; }
   return 0;
}

sub isLetter
{
   my ($val) = @_;

   if ( &isLowerLetter($val) || &isUpperLetter($val) ) { return 1; }
   return 0;
}

sub isNULL
{
   my ($val) = @_;

   if ( $val eq "NULL" ) { return 1; }
   return 0;
}

sub isLowerLetter
{
   my ($val) = @_;

   if ( length($val) > 1 ) { return 0; }

   if ( $val =~ /^[a-z]$/ ) { return 1; }

   return 0;
}

sub isUpperLetter
{
   my ($val) = @_;

   if ( length($val) > 1 ) { return 0; }

   if ( $val =~ /^[A-Z]$/ ) { return 1; }

   return 0;
}

#
#####################################
# Miscellaneous functions
#####################################
#
sub inString
{
   my ($str, $cstr) = @_;

   $pos = index($str, $cstr);
   if ( $pos >= 0 ) { return 1; }
   return 0;
}

1;
