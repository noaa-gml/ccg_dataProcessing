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
print "mem checked\n";
$version = &get_as_version($serialport);
print "version:$version\n";
if ($outfile) { $outfile = ">${outfile}"; }
else { $outfile = ">&STDOUT"; }

open(OUTFILE,$outfile);
#jwm -9/19 - changed logic to handle large datalog files. Previous (get_as_block) blew up somewhere loading whole response into array to pass back
#old:
#@block = &get_as_block($serialport, $version, 'datalog');
#foreach $line ( @block ) { print OUTFILE "$line\n"; }

if(&goto_as_menu($serialport, $version, 'history') == 0){
	#Send the D (datalog) command.  This will respond with a D echo'd back and then start filling the buffer with actual datalog.
	&as_send_and_read($serialport,1,'D');
	
	#Call again to start receiving the datalog in buffer.  We'll do it straight through shell command to avoid having to load into perl vars
	my $cprog = dirname(abs_path($0)).'/as_send_and_read';
	my $tmp = $cprog.' '.$serialport.' 1';
	#Open a filehandle/pipeline to command
	open FH, "$tmp |" or die "Failed to open pipeline:$tmp";
   	while(<FH>)
   	{#send to outfile
		print OUTFILE $_;
   	}
   	close(FH);
}else{print "Error opening history menu\n";}
close(OUTFILE);

&goto_as_menu($serialport, $version, 'main');

exit;
