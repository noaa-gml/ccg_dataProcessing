#!/usr/bin/perl

use strict;
use Cwd 'abs_path';
use File::Basename;

sub as_send()
{
   my ($device, $wait, $command) = @_;

   my $cprog = dirname(abs_path($0)).'/as_send';

   if ( $wait eq '' ) { $wait = 1; }

   my $tmp = $cprog.' '.$device.' '.$wait;

   if ( $command ne '' )
   {
      $command =~ s/"/\\"/g;
      $tmp = $tmp.' "'.$command.'"';
   }

   #print "$tmp\n";
   system($tmp);
}

sub as_send_and_read()
{
   my ($device, $wait, $command) = @_;
   my @arr = ();
   my $tmp = '';
   my $chkcommand = '';

   my $cprog = dirname(abs_path($0)).'/as_send_and_read';

   if ( $wait eq '' ) { $wait = 1; }

   my $tmp = $cprog.' '.$device.' '.$wait;

   if ( $command ne '' )
   {
      $command =~ s/"/\\"/g;
      $tmp = $tmp.' "'.$command.'"';
   }

   #print "$tmp\n";

   open FH, "$tmp |" or die "Failed to open pipeline";
   while(<FH>)
   {
      chomp($_);
      push(@arr, $_);
   }
   close(FH);

   #foreach $line ( @arr ) { print "FN: $line\n"; }

   $chkcommand = shift(@arr);
   $chkcommand =~ s/[\r\n]//g;

   if ( $command =~ m/[^\s\r\n]/ )
   {
      if ( $command ne $chkcommand )
      {
         &as_error("Command sent to AS does not match echo from AS\n");
         print "command:'$command' \nreturned from pfp:'$chkcommand'\n";
      }
   }

   return (@arr);
}

sub as_error()
{
   my @errors = @_;

   my ($package, $filename, $line, $subroutine, $hasargs, $wantarray, $evaltext, $is_require, $hints, $bitmask, $hinthash) = caller(0);

   my $error = '';

   #print $package.' '.$filename."\n";

   foreach $error ( @errors )
   { print STDERR "Error: $error at $filename line $line.\n"; }
}

1;
