#!/usr/bin/perl

#
# Return logic:
#    0 - No errors
#    1 - Errors
#
# Default for a function should return 1
#
# Check success before executing commands
#    For example, check success of goto_as_menu before executing commands
#
#

use strict;

sub get_as_version()
{
   # Multiple tries should only be implemented in goto_as_menu(), get_as_version()
   #   and get_as_prompt()

   my ($device) = @_;
   my @block = ();
   my $line = '';
   my $str = '';
   my $version = '';
   my $maxtries = 5;
   my $try = 0;

   while ( $version eq '' && $try < $maxtries )
   {
      @block = &get_as_block($device, $version, 'unit');

      foreach $line ( @block )
      {
         #print "$line\n";

         if ( $line =~ m/firmware:/ )
         {
            ($str, $version) = split(':', $line);
            $version =~ s/^\s+//;
            $version =~ s/\s+$//;

            return $version;
         }
      }

      $try++;
   }

   if ( $version eq '' )
   { &as_error("Could not get AS version after '$maxtries'."); }

   return $version;
}

sub goto_as_menu()
{
   # Multiple tries should only be implemented in goto_as_menu(), get_as_version()
   #   and get_as_prompt()

   my ($device, $version, $menu) = @_;
   my $prompt = '';
   my $maxtries = 5;
   my $check = 1;
   my $try = 0;

   $prompt = &get_as_prompt($device, $version);

   $check = &check_as_menu($version,$menu,$prompt);

   if ( $check == 0 ) { return; }

   while ( $check == 1 && $try < $maxtries )
   {
      if ( $menu eq 'fix_memory' )
      {
         if ( $version eq '' ||
              $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'F'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'flight_log' )
      {
         # Flight Log is the menu to set the data log parameters
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'setup') == 0 )
            { &as_send($device, '1', 'F'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'history' )
      {
         # $version is equal to '' when the AS is trying to retrieve the version
         if ( $version eq '' ||
              $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'H'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'prefill_each')
      {
         if ($version gt '3.f')
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            {
               &as_send($device, '1', 'H');
               &as_send($device, '1', 'P');
               &as_send($device, '1', 'E');
            }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'prefill_all')
      {
         if ($version gt '3.f')
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            {
               &as_send($device, '1', 'H');
               &as_send($device, '1', 'P');
               &as_send($device, '1', 'A');
            }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'main' )
      {
         # $version is equal to '' when the AS is trying to retrieve the version
         if ( $version eq '' ||
              $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            &as_send($device, '1', 'Q');
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'manual' )
      {
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'M'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'test' )
      {
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'T'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'sample_plan' )
      {
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'setup') == 0 )
            { &as_send($device, '1', 'S'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'setup' )
      {
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'S'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'unload' )
      {
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'U'); }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }
      elsif ( $menu eq 'limits' )
      {
         if ( $version eq '3.06j' ||
              $version eq '3.06p' ||
              $version eq '3.06s' ||
              $version =~ m/^3[A-Za-z]$/ ||
              $version =~ /^4/ )
         {
            if ( &goto_as_menu($device, $version, 'main') == 0 )
            { &as_send($device, '1', 'S');
              &as_send($device, '1', 'L');
            }
         }
         else
         {
            &as_error("Invalid version '$version' specified.");
            return 1;
         }
      }

      else
      {
         &as_error("Invalid menu '$menu'.");
         return 1;
      }

      $prompt = &get_as_prompt($device, $version);
      #print "$prompt\n";

      $check = &check_as_menu($version,$menu,$prompt);

      $try++;
   }

   if ( $check == 1 )
   {
      &as_error("Could not get '$menu' prompt after '$maxtries' tries.");
   }

   return $check;
}

sub get_as_prompt()
{
   # Multiple tries should only be implemented in goto_as_menu(), get_as_version()
   #   and get_as_prompt()

   my ($device,$version) = @_;
   my $maxtries = 3;
   my $prompt = '';
   my $try = 0;
   my @reply = ();
   my $line = '';
   
   while ( $try < $maxtries && $prompt eq '' )
   {
      @reply = &as_send_and_read($device, '1');

      while ( $#reply > -1 )
      {
         $line = pop(@reply);
         $line =~ s/\/done//;#Some test pfps will come back with AS/done> as the prompt.  We're not exactly sure the details, but strip out so logic will process.
         #print $line."\n";

         if ( $line =~ m/>\s*$/ )
         {
            $prompt = $line;
            return $prompt;
         }
      }
      $try++;
   }

   #print "$prompt\n";

   if ( $prompt eq '' )
   {
      &as_error("Could not get current prompt after '$maxtries' tries.");
      die;
   }

   return $prompt;
}

sub check_as_menu()
{
   my ($version, $menu, $prompt) = @_;

   if ( $menu eq 'flight_log' )
   {
      # Flight Log is the menu to set the data log parameters
      if ( $version eq '' ||
           $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*DATALOG>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'fix_memory' )
   {
      if ( $version eq '' ||
           $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*FIX MEMORY>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'history' )
   {
      # $version is equal to '' when the AS is trying to retrieve the version
      if ( $version eq '' ||
           $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*HISTORY>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   #Starting with version 3g, prefill is subdivided into each and all
   elsif ( $menu eq 'prefill_each')
   {
      if ($version gt '3.f')
      {
         if ( $prompt =~ m/^\s*PREFILL EACH>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }

   }
   elsif ( $menu eq 'prefill_all')
   {
      if ($version gt '3.f')
      {
         if ( $prompt =~ m/^\s*PREFILL ALL>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }

   }
   elsif ( $menu eq 'main' )
   {
      # $version is equal to '' when the AS is trying to retrieve the version
      if ( $version eq '' ||
           $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*AS>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'manual' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*MANUAL>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'test' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*TEST>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'sample_plan' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*SAMPLE PLAN>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'setup' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*SETUP>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'unload' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*UNLOAD>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $menu eq 'limits' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( $prompt =~ m/^\s*LIMITS>\s*$/ ) { return 0; }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }

   else
   { &as_error("Invalid menu '$menu'."); }

   return 1;
}

sub get_as_block()
{
   my ($device, $version, $block) = @_;
   my $prompt = '';
   my @reply = ();

   if ( $block eq 'altitude' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'A'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'conditions' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'C'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'datalog' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'D'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'fill' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'F'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'flags' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'E'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'gps' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'G'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'location' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'L'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'monitor' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'test') == 0 )
         { @reply = &as_send_and_read($device, '1', 'M'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
#PREFILL
   #PREFILL FILL
   elsif ( $block eq 'prefill_fill' )#pre 3g
   {
      if ( $version =~ m/^3f$/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'P'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'prefill_each_fill')
   {
      if ($version gt '3f'){#3g+ added prefilleach & all) {
         if ( &goto_as_menu($device, $version, 'prefill_each') == 0 ){
            @reply = &as_send_and_read($device, '1', 'F');
         }
      }

   }
   elsif ( $block eq 'prefill_all_fill')
   {
      if ($version gt '3f'){#3g+ added prefilleach & all) {
         if ( &goto_as_menu($device, $version, 'prefill_all') == 0 ){
            @reply = &as_send_and_read($device, '1', 'F');
         }
      }

   }
   #PREFILL FLAGS
   elsif ( $block eq 'prefill_flags' )
   {
      if ( $version =~ m/^3f$/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'R'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'prefill_each_flags')
   {
      if ($version gt '3f'){#3g+ added prefilleach & all) {
         if ( &goto_as_menu($device, $version, 'prefill_each') == 0 ){
            @reply = &as_send_and_read($device, '1', 'E');
         }
      }

   }
   elsif ( $block eq 'prefill_all_flags')
   {
      if ($version gt '3f'){#3g+ added prefilleach & all) {
         if ( &goto_as_menu($device, $version, 'prefill_all') == 0 ){
            @reply = &as_send_and_read($device, '1', 'E');
         }
      }

   }
   #PREFILL TIMES
   elsif ( $block eq 'prefill_each_times')
   {
      if ($version gt '3f'){#3g+ added prefilleach & all) {
         if ( &goto_as_menu($device, $version, 'prefill_each') == 0 ){
            @reply = &as_send_and_read($device, '1', 'T');
         }
      }

   }
   elsif ( $block eq 'prefill_all_times')
   {
      if ($version gt '3f'){#3g+ added prefilleach & all) {
         if ( &goto_as_menu($device, $version, 'prefill_all') == 0 ){
            @reply = &as_send_and_read($device, '1', 'T');
         }
      }

   }

   elsif ( $block eq 'limits' )
   {
      if ( $version =~ m/^3f$/ or $version gt '3f')
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'S'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'sample_plan' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'sample_plan') == 0 )
         { @reply = &as_send_and_read($device, '1', 'L'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'time' )
   {
      if ( $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'T'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   elsif ( $block eq 'pcpnums'){#adding for new 4.x boards. pcp in use for each flask sample. jwm - 12.19
        if($version gt '4.009'){#added in 4.010
            if ( &goto_as_menu($device, $version, 'history') == 0 ){
               @reply = &as_send_and_read($device, '1', '1');
            }
        }else{
            &as_error("Invalid version '$version' specified.");
        }
   }
   elsif ( $block eq 'flasklimits'){#adding for new 4.x boards.  limits used for each flask jwm - 12.19
        if($version gt '4.009'){#added in 4.010
            if ( &goto_as_menu($device, $version, 'history') == 0 ){
               @reply = &as_send_and_read($device, '1', '2');
            }
        }else{
            &as_error("Invalid version '$version' specified.");
        }
   }
   elsif ( $block eq 'unit' )
   {
      # Used by get_as_version() to obtained the version, so
      #  no version is set yet
      if ( $version eq '' ||
           $version eq '3.06j' ||
           $version eq '3.06p' ||
           $version eq '3.06s' ||
           $version =~ m/^3[A-Za-z]$/ ||
           $version =~ /^4/ )
      {
         if ( &goto_as_menu($device, $version, 'history') == 0 )
         { @reply = &as_send_and_read($device, '1', 'U'); }
      }
      else
      { &as_error("Invalid version '$version' specified."); }
   }
   else
   { &as_error("Invalid block '$block'."); }

   return @reply;

}

sub check_as_memory()
{
   my ($device, $version) = @_;
   my @reply = ();
   my $line = '';

   if ( $version eq '3.06j' ||
        $version eq '3.06p' )
   {
      if ( &goto_as_menu($device, $version, 'fix_memory') == 0 )
      { @reply = &as_send_and_read($device, '1', 'C'); }

      foreach $line ( @reply )
      {
         #print "$line\n";
         if ( $line =~ m/memory okay/ )
         { return 0; }
      }
   }
   else
   {
      if ( &goto_as_menu($device, $version, 'main') == 0 )
      { @reply = &as_send_and_read($device, '1', 'H'); }

      foreach $line ( @reply )
      {
         if ( $line =~ m/invalid memory/ )
         {
            &as_error("AS memory is invalid.");
            return 1;
         }
      }

      return 0;
   }

   return 1;
}

sub fix_as_memory()
{
   my ($device, $version) = @_;
   my @reply = ();
   my $line = '';

   if ( $version eq '3.06j' ||
        $version eq '3.06p' )
   {
      if ( &goto_as_menu($device, $version, 'fix_memory') == 0 )
      {
         &as_send($device, '1', 'F');
         @reply = &as_send_and_read($device, '1', 'Y');
      }

      foreach $line ( @reply )
      {
         #print "$line\n";
         if ( $line =~ /all checksums have been updated/ )
         { return 0; }
      }
   }
   else
   { &as_error("Invalid version '$version' specified."); }

   &as_error("Fix memory failed.");
   return 1;
}

1;
