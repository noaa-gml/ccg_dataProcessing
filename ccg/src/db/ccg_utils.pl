#
########################################
# Convert yr mo dy hr mn sc to decimal year
########################################
#
sub date2dec
{
   my (@params) = @_;

   my $i;
   my ($soy, $doy, $leap, $dd);
   my @siy = (31536000, 31622400);
   my @diy = (-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
   my @dil = (-9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);
   my @input = (1900, 1, 15, 12, 0, 0);
   for ($i = 0; $i < @params; $i ++) { $input[$i] = $params[$i]; }
   my $yr = $input[0];
   my $mo = $input[1];
   my $dy = $input[2];
   my $hr = $input[3];
   my $mn = $input[4];
   my $sc = $input[5];

   $leap = &leapyear($yr);

   $yrdoy = &ymd2jul($yr, $mo, $dy);
   $doy = $yrdoy - $yr * 1000;

   $soy = ($doy - 1) * 86400 + $hr * 3600 + $mn * 60 + $sc;

   $dd = $yr + $soy / $siy[$leap];

   return $dd;
}
#
#######################################
# Convert decimal year to yr mo dy hr mn
#######################################
#
sub dec2date
{
   my ($dd) = @_;

   my ($yr, $mo, $dy, $hr, $mn, $sc);
   my ($dyr, $fyr, $soy, $doy, $leap);
   my ($tsc, $ndy, $nsc);

   $dyr = int($dd);
   $fyr = $dd - $dyr;

   $leap = &leapyear($dyr);

   #$tsc = int($fyr * ((365 + $leap) * 86400));
   $tsc = $fyr * ((365 + $leap) * 86400);

   $ndy = int($tsc / 86400);

   $doy = $ndy + 1;
   
   ($yr, $mo, $dy) = &jul2ymd($dyr * 1000 + $doy);

   $nsc = $tsc - int($ndy * 86400);
   $hr = int($nsc / 3600);
   $mn = int(($nsc - ($hr * 3600)) / 60);

   $sc = $nsc - ($hr * 3600.0) - ($mn * 60.0);

   $sc = &round($sc, 0);
   if ($sc == 60)
   {
      $sc = 0; $mn ++;
      if ($mn == 60)
      {
         $mn = 0; $hr ++;
         if ($hr == 24)
         {
            $hr = 0; $doy ++;
            ($yr, $mo, $dy) = &jul2ymd($dyr * 1000 + $doy);
         }
      }
   }
   return $yr, $mo, $dy, $hr, $mn, $sc;
}
#
#######################################
# Convert yr mo dy to julian yrdoy
#######################################
#
sub ymd2jul
{
   my ($yr, $mo, $dy) = @_;

   my ($leap, $doy, @tmp);
   my @diy = (-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
   my @dil = (-9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335);

   $leap = &leapyear($yr);

   @tmp = ($leap) ? @dil : @diy;

   $doy = ($leap) ? $tmp[$mo] + $dy : $tmp[$mo] + $dy;

   return $yr * 1000 + $doy;
}
#
#######################################
# Convert julian yrdoy to yr mo dy
#######################################
#
sub jul2ymd
{
   my ($jul) = @_;

   my ($leap, $doy);
   my ($yr, $mo, $dy);
   my @diy = (-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 999);
   my @dil = (-9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 999);

   $yr = int($jul / 1000);
   $doy = $jul % 1000;

   $leap = &leapyear($yr);

   @tmp = ($leap) ? @dil : @diy;

   $mo = 0;
   do { $mo ++; } while ($mo < 13 && $tmp[$mo] < $doy);
   $mo --;

   $dy = $doy - $tmp[$mo];

   return $yr, $mo, $dy;
}
#
#######################################
# Determine leap year status
#######################################
#
sub leapyear
{
   my ($yr) = @_;
   my ($l);

   $l = (($yr % 4 == 0 && $yr % 100 != 0) || ($yr % 400 == 0)) ? 1 : 0;
   return $l;
}

sub round
{
   local($n, $power)=@_;

   my ($t, $t1);

   $t=$n*(10.0**(-1*$power));
   $t1=($t<0) ? $t-0.5 : $t+0.5;
   return(int($t1)*(10.0**$power));
}

sub SysDate
{
   my ( $opt ) = @_;
   my ($yr, $mo, $dy, $hr, $mn, $sc);
   my ($wk, $doy, $dst);

   my @day = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
   my @mon = ("na", "Jan", "Feb", "Mar", "Apr", "May", "Jun", 
                      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec");
   
   if ( $opt =~ /utc/i ) { ($sc, $mn, $hr, $dy, $mo, $yr, $wk, $doy, $dst) = gmtime(time) }
   else { ($sc, $mn, $hr, $dy, $mo, $yr, $wk, $doy, $dst) = localtime(time) }

   return (sprintf("%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d",
   $yr + 1900, $mo + 1, $dy, $hr, $mn, $sc));
}

sub ReadFile
{
	#jwm 8/18. Using chop caused issues when file was missing line ending on last line.  Not sure of the
	#history on why chop used (removes last char whatever it is), perhaps because of files with weird line endings?
	#See perllib.pl->ReadLine2 comments (it uses chomp).
	#j2m 9/22.  This is still causing issues, switching to chomp.  I can't think of legit reason to need to take last char when 
	# not a line ending.  It appears to be used (on array) to remove newlines from each element.  chomp 'should' be the correct function to use.
   my ($f) = @_;

   my @arr = ();

   open (FILE, $f) || return @arr;
   my (@arr) = <FILE>;
   chomp (@arr);
   close (FILE);

   return @arr;
}

sub WriteFile
{
   my ($f, @arr) = @_;
   my $i;

   open (FILE, ">${f}") || die "Can't open file ${f}.\n";
   for ($i = 0; $i < @arr; $i ++) { printf FILE "${arr[$i]}\n"; }
   close (FILE);
}

sub FindInArray
{
   my ($str, $grep, @arr) = @_;
   my ($i, $z);

   for ($i = 0; $i < @arr; $i ++)
   {
      if ($grep) { if (($z = grep(/$str/, $arr[$i])) != 0) { return $i } }
      else { if ($arr[$i] eq $str) { return $i } }
   }
   return -1;
}

sub AverageVar
{
   #
   # Courtesy of KWT
   #
   my (@arr) = @_;
   my ($ave, $svar, $v, $d, $sdev);

   return (-999.99, -9.9) unless $#arr >= 0;

   $ave = &sum(@arr)/(1+$#arr);

   return (-999.99, -9.9) unless $ave > -999;

   $svar = 0.0;
   foreach $v (@arr) {
      $d = $v - $ave;
      $svar += $d*$d;
   }

   if ($#arr > 0)
   {
      $sdev = sqrt ($svar / $#arr);
   }
   else
   {
      $sdev = -9.9;
   }
   return ($ave, $sdev);
}

sub sum
{
   #
   # Courtesy of KWT
   #
   my (@arr) = @_;
   my $v;
   my $s = 0.0;

   foreach $v (@arr) { $s += $v; }
   return $s;
}

sub trim
{
   my ($val) = @_;

   $val = &ltrim($val);
   $val = &rtrim($val);

   return $val;
}

sub ltrim
{
   my ($val) = @_;

   $val =~ s/^\s+//;

   return $val;
}

sub rtrim
{
   my ($val) = @_;

   $val =~ s/\s+$//;

   return $val;
}

sub in_array
{
   #
   # Check if the needle is in the haystack
   #   
    my $val = shift(@_);

    foreach $elem(@_) {
        if($val eq $elem) {
            return 1;
        }
    }
    return 0;
}

sub GV2CCGG
{
   my ( $gv_strategy, $gv_platform ) = @_;

   $gv_strategy = uc($gv_strategy);

   if ( $gv_strategy eq 'D' && $gv_platform eq '0' )
   {
      $ccgg_project_num = '1';
      $ccgg_strategy_num = '1';
   }
   elsif ( $gv_strategy eq 'D' && $gv_platform eq '1' )
   {
      $ccgg_project_num = '1';
      $ccgg_strategy_num = '1';
   }
   elsif ( $gv_strategy eq 'P' && $gv_platform eq '1' )
   {
      $ccgg_project_num = '1';
      $ccgg_strategy_num = '2';
   }
   elsif ( $gv_strategy eq 'P' && $gv_platform eq '0' )
   {
      $ccgg_project_num = '1';
      $ccgg_strategy_num = '2';
   }
   elsif ( $gv_strategy eq 'D' && $gv_platform eq '2' )
   {
      $ccgg_project_num = '2';
      $ccgg_strategy_num = '1';
   }
   elsif ( $gv_strategy eq 'P' && $gv_platform eq '2' )
   {
      $ccgg_project_num = '2';
      $ccgg_strategy_num = '2';
   }
   elsif ( $gv_strategy eq 'D' && $gv_platform eq '3' )
   {
      $ccgg_project_num = '1';
      $ccgg_strategy_num = '1';
   }
   elsif ( $gv_strategy eq 'C' && $gv_platform eq '3' )
   {
      $ccgg_project_num = '3';
      $ccgg_strategy_num = '3';
   }
   elsif ( $gv_strategy eq 'C' && $gv_platform eq '0' )
   {
      $ccgg_project_num = '4';
      $ccgg_strategy_num = '3';
   }
   elsif ( $gv_strategy eq 'P' && $gv_platform eq '3' )
   {
      $ccgg_project_num = '1';
      $ccgg_strategy_num = '2';
   }
   else
   {
      $ccgg_project_num = '-1';
      $ccgg_strategy_num = '-1';
   }

   return ($ccgg_project_num, $ccgg_strategy_num);
}

sub unique_array
{
   my(@arr) = @_;

   my %seen = ();
   my @uniq = ();
   my $item;

   foreach $item ( @arr )
   {
      unless ($seen{$item})
      {
         # if we get here, we have not seen it before
         $seen{$item} = 1;
         push(@uniq, $item);
      }
   }

   return @uniq;
}

sub nvpair_split
{
   my ($nvstr, $nvdelim, $nvpairdelim) = @_;

   my @nvpairs = ();
   my %nvhash = ();
   my $nvpair;
   my ($name, $value);

   if ( $nvdelim eq '' ) { $nvdelim = ':'; }
   if ( $nvpairdelim eq '' ) { $nvpairdelim = '~\+~'; }

   #print $nvpairdelim."\n";

   @nvpairs = split(/$nvpairdelim/, $nvstr);

   foreach $nvpair ( @nvpairs )
   {
      ($name, $value) = split(/$nvdelim/, $nvpair, 2);

      $nvhash{$name} = $value;
   }

   return %nvhash;
}

sub urlencode {
    my $s = shift;
    $s =~ s/([^A-Za-z0-9\- ])/sprintf("%%%02X", ord($1))/seg;
    $s =~ s/ /+/g;
    return $s;
}

sub urldecode {
    my $s = shift;
    $s =~ s/\+/ /g;
    $s =~ s/\%([A-Fa-f0-9]{2})/pack('C', hex($1))/seg;
    return $s;
}

1;
