#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;

require(dirname(abs_path($0))."/as_comm_utils_L0.pl");
require(dirname(abs_path($0))."/as_comm_utils_L1.pl");
require(dirname(abs_path($0))."/as_comm_utils_L2.pl");

my $device = '';
my $samplenum = '';
my $version = '';
my @reply = ();

if ( $#ARGV != 1 )
{
   &as_error("Wrong number of arguments.");
   exit 1;
}

$device = $ARGV[0];
$samplenum = $ARGV[1];

if ( $samplenum < 1 || $samplenum > 20 )
{
   &as_error("Impractical sample number '$samplenum' given, needs to be 1-20");
   exit 1;
}

if ( &check_as_memory($device) != 0 ) { die(); }

$version = &get_as_version($device);

if ( $version eq '3.06j' ||
     $version eq '3.06p' ||
     $version eq '3.06s' ||
     $version =~ m/^3[A-Za-z]$/ ||
     $version =~ /^4/ )
{
   if ( &goto_as_menu($device, $version, 'unload') == 0 )
   {
      &as_send($device, '1', 'C');

      # The AS takes at least 10 seconds to reply
      @reply = &as_send_and_read($device, '10', $samplenum);
   }
}
else
{ &as_error("Invalid version '$version' specified."); }

&goto_as_menu($device, $version, 'main');

foreach $line ( @reply )
{
   if ( $line =~ m/valve closed/)
   {
      #print "SUCCESS!\n";
      exit 0;
   }
}

&as_error("Sample valve '$samplenum' falied to close");
exit 1;
