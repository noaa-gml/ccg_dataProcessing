#!/usr/bin/perl

use Cwd 'abs_path';
use File::Basename;

require(dirname(abs_path($0))."/as_comm_utils_L0.pl");
require(dirname(abs_path($0))."/as_comm_utils_L1.pl");
require(dirname(abs_path($0))."/as_comm_utils_L2.pl");

$device = '/dev/ttyr300';
$version='4.22';
if($version =~ /^4/){print "eq";}else{print"nope";}
exit();
&as_send($device,'1','');

#$prompt = &get_as_prompt($device,'');


$version = &get_as_version($device);
print "VERSION: $version\n";
#$version="3g";
#$version='3g';


#change altitude to any of those block commands
@block = &get_as_block($device, $version, 'altitude');





foreach (@block) {print $_."\n";}

exit();
