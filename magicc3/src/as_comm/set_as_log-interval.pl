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
my $serialport = '';
my $log_interval = 0;
my $tmp_interval = 0;
my $version = '';
my @reply = ();
my @newreply = ();
my $day = 0;
my $hour = 0;
my $min = 0;
my $sec = 0;
my $maxtries = 10;
my $line = '';
my $rline = '';

#
#######################################
# Parse Arguments
#######################################
#
$noerror = GetOptions(\%Options, "help|h", "interval=i", "port|p=s");

$log_interval = ($Options{interval}) ? $Options{interval} : 0;
$serialport = ($Options{port}) ? $Options{port} : "/dev/ttyr300";

$day = ($log_interval - ( $log_interval % 86400 ) ) / 86400;
$tmp_interval = $log_interval % 86400;

$hour = ($tmp_interval - ( $tmp_interval % 3600 ) ) / 3600;
$tmp_interval = $tmp_interval % 3600;

$min = ($tmp_interval - ( $tmp_interval % 60 ) ) / 60;
$tmp_interval = $tmp_interval % 60;

$sec = $tmp_interval;

#print $day.' '.$hour.' '.$min.' '.$sec."\n";

if ( &check_as_memory($serialport) != 0 ) { die(); }

$version = &get_as_version($serialport);

if ( $version eq '3.06j' ||
     $version eq '3.06p' ||
     $version eq '3.06s' ||
     $version eq '3a' ||
     $version eq '3b' || 
     $version =~ /^4/ )
{
   if ( &goto_as_menu($serialport, $version, 'flight_log') == 0 )
   {
      @reply = &as_send_and_read($serialport, '1', 'I');
   }
}
else
{ &as_error("Invalid version '$version' specified."); }

my $try = 0;
my $check = 1;
while ( $check == 1 && $try < $maxtries)
{
   while ( $#reply > -1 )
   {
      $line = pop(@reply);

      if ( $line =~ m/days/ )
      {
         @newreply = &as_send_and_read($serialport, '1', $day);
         $check = 1;
         last;
      }
      elsif ( $line =~ m/hours/ )
      {
         @newreply = &as_send_and_read($serialport, '1', $hour);
         $check = 1;
         last;
      }
      elsif ( $line =~ m/min/ )
      {
         @newreply = &as_send_and_read($serialport, '1', $min);
         $check = 1;
         last;
      }
      elsif ( $line =~ m/sec/ )
      {
         @newreply = &as_send_and_read($serialport, '1', $sec);
         $check = 1;
         last;
      }
      elsif ( &check_as_menu($version, 'flight_log', $line) == 0 )
      {
         $rline = pop(@reply);
         #print "RLINE: $rline\n";

         if ( $rline =~ m/^\s+data logging interval/ )
         { $check = 0; }
         else
         { $check = 1; }
         last;
      }
   }

   @reply = @newreply;
   $try++;
}

&goto_as_menu($serialport, $version, 'main');

exit;
