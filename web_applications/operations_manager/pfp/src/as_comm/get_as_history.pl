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

print OUTFILE "Unit History\n";
@block = &get_as_block($serialport, $version, 'unit');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

# Get time difference
$datetime = &get_as_datetime($serialport, $version);
#print OUTFILE "$datetime\n";

($date, $time) = split(/\s/, $datetime);
($yr,$mo,$dy) = split(/-/, $date);
($hr,$mn,$sc) = split(/:/, $time);

$astime = timegm($sc, $mn, $hr, $dy, $mo-1, $yr-1900);

($sc, $mn, $hr, $dy, $mo, $yr) = (gmtime(time))[0, 1, 2, 3, 4, 5];
$systime = timegm($sc, $mn, $hr, $dy, $mo, $yr);

print OUTFILE "pfp_minus_sys_time: ".($astime-$systime)."\n";

# Get front pressure
@block = &get_as_block($serialport, $version, 'monitor');
foreach $line ( @block )
{
   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ ||
        $version =~ /^4/ )
   {
      if ( $line =~ m/pressure/ )
      {
         $pressure = $line;
         $pressure =~ s/pressure//g;
         $pressure =~ s/psia//g;
         $pressure =~ s/^\s+//;
         $pressure =~ s/\s+$//;

         print OUTFILE "front_pressure: $pressure\n";
         last;
      }
   }
}

# Get average pressure
if ( &goto_as_menu($serialport, $version, 'test' ) == 0 )
{
   &as_send($serialport, '1', 'B');
   &as_send($serialport, '1', 'O');
   sleep(2);
   &as_send($serialport, '1', 'B');
   &as_send($serialport, '1', 'C');

   @block = &get_as_block($serialport, $version, 'monitor');
   foreach $line ( @block )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $line =~ m/pressure/ )
         {
            $pressure = $line;
            $pressure =~ s/pressure//g;
            $pressure =~ s/psia//g;
            $pressure =~ s/^\s+//;
            $pressure =~ s/\s+$//;

            print OUTFILE "avg_pressure: $pressure\n";
            last;
         }
      }
   }
}

print OUTFILE "\n";

print OUTFILE "Altitude History\n";
@block = &get_as_block($serialport, $version, 'altitude');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

print OUTFILE "\n";

print OUTFILE "Location History\n";
@block = &get_as_block($serialport, $version, 'location');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

print OUTFILE "\n";

print OUTFILE "Time History\n";
@block = &get_as_block($serialport, $version, 'time');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

print OUTFILE "\n";

print OUTFILE "Fill History\n";
@block = &get_as_block($serialport, $version, 'fill');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

print OUTFILE "\n";

print OUTFILE "Flag History\n";
@block = &get_as_block($serialport, $version, 'flags');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

print OUTFILE "\n";

print OUTFILE "Ambient History\n";
@block = &get_as_block($serialport, $version, 'conditions');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

print OUTFILE "\n";

print OUTFILE "GPS History\n";
@block = &get_as_block($serialport, $version, 'gps');
if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
foreach $line ( @block ) { print OUTFILE "$line\n"; }

if ( $version eq '3f' )
{
   print OUTFILE "\n";

   print OUTFILE "Prefill Fill History\n";
   @block = &get_as_block($serialport, $version, 'prefill_fill');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   print OUTFILE "Prefill Flag History\n";
   @block = &get_as_block($serialport, $version, 'prefill_flags');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   # Commented out this line because it is not needed.
   # 2014-05-08 (kam)
   print OUTFILE "Limits History\n";
   @block = &get_as_block($serialport, $version, 'limits');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }
}
#Starting in 3g, prefill is subdivided into each and all.
elsif ($version gt '3f')
{
   print OUTFILE "\n";

   print OUTFILE "Prefill Each Fill History\n";
   @block = &get_as_block($serialport, $version, 'prefill_each_fill');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   print OUTFILE "Prefill Each Flag History\n";
   @block = &get_as_block($serialport, $version, 'prefill_each_flags');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   print OUTFILE "Prefill Each Time History\n";
   @block = &get_as_block($serialport, $version, 'prefill_each_times');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   print OUTFILE "Prefill All Fill History\n";
   @block = &get_as_block($serialport, $version, 'prefill_all_fill');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   print OUTFILE "Prefill All Flag History\n";
   @block = &get_as_block($serialport, $version, 'prefill_all_flags');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   print OUTFILE "Prefill All Time History\n";
   @block = &get_as_block($serialport, $version, 'prefill_all_times');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   print OUTFILE "\n";

   # Commented out this line because it is not needed.
   # 2014-05-08 (kam)
   print OUTFILE "Limits History\n";
   @block = &get_as_block($serialport, $version, 'limits');
   if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
   foreach $line ( @block ) { print OUTFILE "$line\n"; }

   if ($version gt '4.0'){#adding per flask limits and pcp used for each sample for 4.01+ boards. jwm -12.19
       print OUTFILE "\n";
   
       print OUTFILE "Flask Limits\n";
       @block = &get_as_block($serialport, $version, 'flasklimits');
       if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
       foreach $line ( @block ) { print OUTFILE "$line\n"; }

       print OUTFILE "\n";
   
       print OUTFILE "PCP History\n";
       @block = &get_as_block($serialport, $version, 'pcpnums');
       if ( $block[$#block] !~ m/^\s*[0-9]/ ) { $prompt = pop(@block); }
       foreach $line ( @block ) { print OUTFILE "$line\n"; }
   }
}
close(OUTFILE);

&goto_as_menu($serialport, $version, 'main');

exit;
