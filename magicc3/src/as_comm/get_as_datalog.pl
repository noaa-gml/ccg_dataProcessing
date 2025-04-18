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
my $outfile = '';
my $serialport = '';
my @block = ();
my $line = '';
my $version = '';
my $prompt = '';
my $pressure = '';
my $datetime = '';
my $date = '';
my $time = '';
my $astime = '';
my $systime = '';
my $yr = 0;
my $mo = 0;
my $dy = 0;
my $hr = 0;
my $mn = 0;
my $sc = 0;

#
#######################################
# Parse Arguments
#######################################
#
$noerror = GetOptions(\%Options, "help|h", "outfile|o=s", "port|p=s");

$outfile = $Options{outfile};
$serialport = ($Options{port}) ? $Options{port} : "/dev/ttyr300";

if ( &check_as_memory($serialport) != 0 ) { die(); }

$version = &get_as_version($serialport);

if ($outfile) { $outfile = ">${outfile}"; }
else { $outfile = ">&STDOUT"; }

open(OUTFILE,$outfile);

@block = &get_as_block($serialport, $version, 'datalog');
foreach $line ( @block ) { print OUTFILE "$line\n"; }

close(OUTFILE);

&goto_as_menu($serialport, $version, 'main');

exit;
