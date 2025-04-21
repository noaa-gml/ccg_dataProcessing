#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;

require(dirname(abs_path($0))."/as_comm_utils_L0.pl");
require(dirname(abs_path($0))."/as_comm_utils_L1.pl");
require(dirname(abs_path($0))."/as_comm_utils_L2.pl");

$device = '/dev/ttyr300';

## Testing basic utilities
#&as_send('/dev/ttyr300','1','');
#
print("out:\n");

system("open_as_sample_w_log.pl",'/dev/ttyr300','1');
system("close_as_sample_w_log.pl",'/dev/ttyr300','1');

#@arr = &as_send_and_read('/dev/ttyr300','1','');
#
#foreach $line ( @arr ) { print "$line\n"; }
# Testing general utilities
$prompt = &get_as_prompt($device,'');
#
print "$prompt\n";

&goto_as_menu($device,'','main');

#$version = &get_as_version($device);
#print "VERSION: $version\n";
#$version='3g';

#@fill= &get_as_block($device, $version, 'prefill_each_fill');
#print "prefill_each_fill\n";
#foreach (@fill) {print $_."\n";}
exit();
#@fill= &get_as_block($device, $version, 'prefill_each_flags');
#print "prefill_each_flags\n";
#foreach (@fill) {print $_."\n";}

#@fill= &get_as_block($device, $version, 'prefill_each_times');
#print "prefill_each_times\n";
#foreach (@fill) {print $_."\n";}

#@fill= &get_as_block($device, $version, 'prefill_all_fill');
#print "prefill_all_fill\n";
#foreach (@fill) {print $_."\n";}

#@fill= &get_as_block($device, $version, 'prefill_all_flags');
#print "prefill_all_flags\n";
#foreach (@fill) {print $_."\n";}

#@fill= &get_as_block($device, $version, 'prefill_all_times');
#print "prefill_all_times\n";
#foreach (@fill) {print $_."\n";}





exit;

#$id = &get_as_id($device, $version);
#print "ID: $id\n";

#############
$date = '2010-12-09';
$time = '22:55:00';
($yr, $mo, $dy) = split("-", $date);
($hr, $mn, $sc) = split(":", $time);
#&set_as_datetime($device, $version, $yr, $mo, $dy, $hr, $mn, $sc);

$datetime = &get_as_datetime($device, $version);
print "DATETIME: $datetime\n";

#############
#if ( &check_as_memory($device, $version) )
#{
#    #print "FAILED!\n";
#    &fix_as_memory($device, $version);
#}

#############
#&delete_as_sampleplan($device, $version);

#############
#$sitecode = &get_as_sitecode($device, $version);
#print "SITECODE: $sitecode\n";
#
#if ( &set_as_sitecode($device, $version, 'HAN') == 0 )
#{
#   print "SET!\n";
#}

#############
#&as_error('dan', 'dan2');

if ( &goto_as_menu($device, $version, 'main') == 0 )
{
   print "SUCCESS!\n";
}

exit;
