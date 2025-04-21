#!/usr/bin/perl

my $os = $^O;
my $username;

use if $os eq 'MSWin32', Win32;

#print $os."\n";
if ( $os eq 'MSWin32' )
{
   $username = Win32::LoginName;
}
else
{
   $username = $ENV{LOGNAME} || $ENV{USER} || getpwuid($<);
}

chomp($username);
$username =~ s///g;
print $username."\n";

exit;
