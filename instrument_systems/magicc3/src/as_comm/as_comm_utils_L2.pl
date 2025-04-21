#!/usr/bin/perl

use strict;

sub get_as_id()
{
   my ($device, $version) = @_;

   my @block = ();
   my $line = '';
   my $str = '';
   my $asid = '';

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      @block = &get_as_block($device, $version, 'unit');

      foreach $line ( @block )
      {
         #jwm-12.9.15 With version 3g, serial number changed to PFP_serial_number and there is a new PCP_serial_number.
         if ( $line =~ m/^serial_number:/ or $line =~ m/^PFP_serial_number:/i)
         {
            ($str, $asid) = split(':', $line);
            # Remove leading spaces
            $asid =~ s/^\s+//;
            # Remove trailing spaces
            $asid =~ s/\s+$//;

            return $asid;
         }
      }

   }
   else
   { &as_error("Invalid version '$version' specified."); }

   if ( $asid eq '' )
   { &as_error("Could not get AS ID."); }

   return $asid;
}

sub get_as_datetime()
{
   my ($device, $version) = @_;

   #
   # This function should always return the date in the
   #  format YYYY-MM-DD HH:MM:SS
   #

   my @reply = ();
   my $line = '';
   my $date = '';
   my $time = '';
   my $datetime = '';

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      if ( &goto_as_menu($device, $version, 'manual') == 0 )
      { @reply = &as_send_and_read($device, '1', 'D'); }

      foreach $line ( @reply )
      {
         #print "$line\n";
         if ( $line =~ /[0-9]{4}-[0-9]{2}-[0-9]{2}/ )
         {
            $line =~ s/^\s+//;
            ($date, $time) = split(/\s+/, $line, 2);

            $datetime = $date.' '.$time;
            return $datetime;
         }
      }

      if ( $datetime eq '' )
      { &as_error("Could not get AS Date Time."); }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   return $datetime;
}

sub set_as_datetime()
{
   my ($device, $version, $yr, $mo, $dy, $hr, $mn, $sc) = @_;
   my $maxtries = 10;
   my $try = 0;
   my @reply = ();
   my @newreply = ();
   my $line = '';
   my $rline = '';
   my $check = 1;

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      if ( &goto_as_menu($device, $version, 'setup') == 0 )
      { @reply = &as_send_and_read($device, '1', 'D'); }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   while ( $check == 1 && $try < $maxtries)
   {
      while ( $#reply > -1 )
      {
         $line = pop(@reply);

         if ( $line =~ m/year/ )
         {
            @newreply = &as_send_and_read($device, '1', $yr);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/month/ )
         {
            @newreply = &as_send_and_read($device, '1', $mo);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/day/ )
         {
            @newreply = &as_send_and_read($device, '1', $dy);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/hour/ )
         {
            @newreply = &as_send_and_read($device, '1', $hr);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/minute/ )
         {
            @newreply = &as_send_and_read($device, '1', $mn);
            $check = 1;
            last;
         }
         elsif ( $line =~ m/second/ )
         {
            @newreply = &as_send_and_read($device, '1', $sc);
            $check = 1;
            last;
         }
         elsif ( &check_as_menu($version, 'setup', $line) == 0 )
         {
            $rline = pop(@reply);
            #print "RLINE: $rline\n";

            if ( $rline =~ m/Date and Time now set/ )
            { $check = 0; }
            else
            { $check = 1; }
            last;
         }
      }

      @reply = @newreply;
      $try++;
   }

   if ( $check == 1 )
   { &as_error("Unable to set date time."); }

   return $check;
}

sub delete_as_sampleplan()
{
   my ($device, $version) = @_;
   my @reply = ();
   my @fields = ();
   my $line = '';
   my $count = 0;
   my $i = 0;

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      @reply = &get_as_block($device, $version, 'sample_plan');

      while ( $#reply > -1 )
      {
         $line = pop(@reply);

         if ( $line =~ m/^\s*[0-9]/ )
         { $count++; }
      }

      if ( &goto_as_menu($device, $version, 'sample_plan') == 0 )
      {
         for ( $i=1; $i<=$count; $i++ )
         {
            &as_send($device, '1', 'D');
            &as_send($device, '1', $i);
            @reply = &as_send_and_read($device, '1', 'Y');

            #foreach $line ( @reply ) { print "$line\n"; }
         }

         if ( $count > 0 ) { return 0; }
      }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   &as_error("Unable to delete AS pample plan.");
   return 1;
}

sub get_as_sitecode()
{
   my ($device, $version) = @_;

   my @block = ();
   my $line = '';
   my $str = '';
   my $sitecode = '';

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      @block = &get_as_block($device, $version, 'unit');

      foreach $line ( @block )
      {
         # print "$line\n";

         if ( $line =~ m/site_code:/ )
         {
            ($str, $sitecode) = split(':', $line);
            # Remove leading spaces
            $sitecode =~ s/^\s+//;
            # Remove trailing spaces
            $sitecode =~ s/\s+$//;

            return $sitecode;
         }
      }

      if ( $sitecode eq '' )
      { &as_error("Could not get AS sitecode."); }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   return $sitecode;
}

sub set_as_sitecode()
{
   my ($device, $version, $sitecode) = @_;
   my @reply = ();
   my $line = '';
   my $chksitecode = '';

   if ( $version eq '3.06j' ||
        $version eq '3.06p' ||
        $version eq '3.06s' ||
        $version =~ m/^3[A-Za-z]$/ || 
        $version =~ /^4/ )
   {
      if ( &goto_as_menu($device, $version, 'setup' ) == 0 )
      {
         &as_send($device, '1', 'C');
         @reply = &as_send_and_read($device, '1', $sitecode);
      }

      foreach $line ( @reply )
      {
         if ( $line =~ m/new site code set to/ )
         {
            $chksitecode = $line;
            $chksitecode =~ s/new site code set to//;
            $chksitecode =~ s/^\s+//g;
            $chksitecode =~ s/\s+$//g;

            if ( $sitecode eq $chksitecode )
            { return 0; }
         }
      }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   &as_error("Unable to set sitecode.");
   return 1;
}

1;
