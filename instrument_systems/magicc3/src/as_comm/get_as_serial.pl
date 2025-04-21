#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;

require(dirname(abs_path($0))."/as_comm_utils_L0.pl");
require(dirname(abs_path($0))."/as_comm_utils_L1.pl");
require(dirname(abs_path($0))."/as_comm_utils_L2.pl");

my $device = '';
my $version = '';
my @reply = ();

my $log = '/home/magicc/src/l1_get_as_prompt.log';
open(my $fh,'>>',$log) or die "Couldn't open log file $log";
print $fh "****** start get_as_serial.pl at: ".localtime()."*************\n";
close $fh;

if ( $#ARGV != 0 )
{
   &as_error("Wrong number of arguments.");
   exit 1;
}

$device = $ARGV[0];

if ( &check_as_memory($device) != 0 ) { die(); }

$version = &get_as_version($device);

$id = &get_as_id($device, $version);

&goto_as_menu($device, $version, 'main');

$id =~ s/[^A-Za-z0-9]//g;

print "$id";

exit 0;
