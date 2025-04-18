#!/usr/bin/perl

use strict;
use Time::Local;
use Getopt::Long;
use Cwd 'abs_path';
use File::Basename;

require(dirname(abs_path($0))."/as_comm_utils_L0.pl");
require(dirname(abs_path($0))."/as_comm_utils_L1.pl");
require(dirname(abs_path($0))."/as_comm_utils_L2.pl");

my $noerror;
my %Options;
my $infile = '';
my $serialport = '';
my @samplearr = ();
my $sampleline = '';
my $line = '';
my $rline = '';
my $version = '';
my $uid = '';
my $usitecode = '';
my $asid = '';
my $maxtries = 10;
my $try = 0; 
my @reply = ();
my @newreply = ();
my $line = ''; 
my $check = 1;
my $samplenum = 0;
my $alt = -999;
my $lat = -999;
my $lon = -999;
my $date = '9999-12-31';
my $time = '00:00:00';
my ($yr, $mo, $dy) = split('-', $date);
my ($hr, $mn, $sc) = split(':', $time);

#
#######################################
# Parse Arguments
#######################################
#
$noerror = GetOptions(\%Options, "infile|f=s", "help|h", "port|p=s");

$infile = $Options{infile};
$serialport = ($Options{port}) ? $Options{port} : "/dev/ttyr300";

# Read $infile
open(INFILE, "<$infile") || die ("Can't open file '$infile'");
@samplearr = <INFILE>;
close(INFILE);

$line = shift(@samplearr);
chomp($line);
($uid, $usitecode) = split (',', $line);
#print "$uid $usitecode\n";die();

if ( &check_as_memory($serialport) != 0 ) { die(); }
#print "memchecked";die();
$version = &get_as_version($serialport);
#print "version: $version";die();
$asid = &get_as_id($serialport, $version);

#print "$asid $uid\n";

if ( $asid ne $uid )
{
   &as_error("PFP ID number does not match the ID requested");
   die();
}

($sc, $mn, $hr, $dy, $mo, $yr) = (gmtime(time))[0, 1, 2, 3, 4, 5];
$yr = $yr+1900;
$mo = $mo+1;

&set_as_datetime($serialport, $version, $yr, $mo, $dy, $hr, $mn, $sc);

&set_as_sitecode($serialport, $version, $usitecode);

&delete_as_sampleplan($serialport, $version);

foreach $sampleline ( @samplearr)
{
   $sampleline =~ s/^\s+//;
   $sampleline =~ s/\s+$//;
   ($samplenum, $alt, $lat, $lon, $date, $time) = split(/\s+/, $sampleline, 6);

   $samplenum =~ s/^0+//;
   if ( $alt < -9999 ) { $alt = -999; }
   if ( $lat < -99 ) { $lat = -999; }
   if ( $lon < -999 ) { $lon = -999; }

   #print "$samplenum $alt $lat $lon $date $time\n";

   ($yr, $mo, $dy) = split('-', $date);
   ($hr, $mn, $sc) = split(':', $time);

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      if ( &goto_as_menu($serialport, $version, 'sample_plan') == 0 )
      {
         &as_send($serialport, '1', 'A');
         @reply = &as_send_and_read($serialport, '1', $samplenum);
      }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   $try = 0;
   $check = 1;
   while ( $check == 1 && $try < $maxtries)
   {
      while ( $#reply > -1 )
      {
         $line = pop(@reply);

         if ( $line =~ m/altitude/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $alt);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/latitude/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $lat);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/longitude/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $lon);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/year/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $yr);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/month/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $mo);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/day/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $dy);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/hour/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $hr);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/minute/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $mn);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/second/ )
         {
            @newreply = &as_send_and_read($serialport, '1', $sc);
            $check = 1;
            last;
         }
         elsif ( &check_as_menu($version, 'sample_plan', $line) == 0 )
         {
            $rline = pop(@reply);
            #print "RLINE: $rline\n";

            if ( $rline =~ m/^\s+$samplenum/ )
            { $check = 0; }
            else
            { $check = 1; }
            last;
         }
      }

      @reply = @newreply;
      $try++;
   }
}

@reply = &get_as_block($serialport, $version, 'sample_plan');

foreach $line ( @reply ) { print "$line\n"; }

&goto_as_menu($serialport, $version, 'main');

exit;
