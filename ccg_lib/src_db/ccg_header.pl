#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# ccg_dataheader
# 
# Builds a general-purpose header (non-data specific)
# that includes generic usage, reciprocity, and disclaimer.  
# Also include time stamp.
#
# User passes project and PI information (see help)
#
# February 2011 - kam
 
#######################################
# Parse Arguments
#######################################
 
if ($#ARGV == -1) { &showargs(); }
 
$noerror = GetOptions(\%Options, "help|h", "contact_user|c=s", "contact_info=s", "project_abbr|p=s", "project_info=s" );
 
if ( $noerror != 1 ) { exit; }
 
if ($Options{help}) { &showargs() }
 
$outfile = ($Options{outfile}) ? $Options{outfile} : "";
 
@project_abbr = ();
if ( $Options{project_abbr} )
{
   @tmp = split( ',', $Options{project_abbr} );
   for ( $i=0; $i<@tmp; $i++ ) { $project_abbr[$i] = $tmp[$i]; }
}

@project_info = ();
if ( $Options{project_info} )
{
   @tmp = split( ',', $Options{project_info} );
   for ( $i=0; $i<@tmp; $i++ ) { $project_info[$i] = $tmp[$i]; }
}

@contact_info = ();
if ( $Options{contact_info} )
{
   @tmp = split( ',', $Options{contact_info} );
   for ( $i=0; $i<@tmp; $i++ ) { $contact_info[$i] = $tmp[$i]; }
}

@contact_user = ();
if ( $Options{contact_user} )
{
   @tmp = split( ',', $Options{contact_user} );
   for ( $i=0; $i<@tmp; $i++ ) { $contact_user[$i] = lc($tmp[$i]); }
}
 
#######################################
# Initialization
#######################################
 
$headdir = "/projects/ftp/readme";
@header = ();
@errarr = ();
$today = SysDate();
 
#######################################
# Connect to Database
#######################################
 
$dbh = &connect_db();
 
#######################################
# Project information from DB if project_abbr specified
#######################################
 
foreach $p ( @project_abbr )
{
   $sql = "SELECT name FROM project WHERE abbr = '${p}'";

   $sth = $dbh->prepare($sql);
   $sth->execute();
    
   # Fetch result

   @tmp = $sth->fetchrow_array();

   if ( $tmp[0] eq "" ) { die "No project information in GML DB for ${p}\n" }

   push @project_info, join( ",", @tmp );
   $sth->finish();
}

#######################################
# PI information from DB if contact_user specified
#######################################
 
foreach $u ( @contact_user )
{
   $sql = "SELECT name, tel, email, affiliation FROM ccgg.contact WHERE abbr = '${u}'";

   $sth = $dbh->prepare($sql);
   $sth->execute();
    
   # Fetch result

   @tmp = $sth->fetchrow_array();

   if ( $tmp[0] eq "" ) { die "No contact information in CCGG DB for ${u}\n" }

   push @contact_info, join( ",", @tmp );
   $sth->finish();
}
 
#######################################
# Read Usage Text
#######################################
  
$f = "${headdir}/general.usage";
@arr = &ReadFile($f);

push @header, " ", " ************ USE OF GML DATA ****************", " ", @arr;
 
#######################################
# Read Disclaimer Text
#######################################
  
$f = "${headdir}/general.warnings";
@arr = &ReadFile($f);

push @header, " ", @arr;
 
#######################################
# Creation Date
#######################################
  
push @header, " ", "File Creation:  ${today}";

 
#######################################
# Project Information
#######################################
  
push @header, " ", "Project: ";

foreach $line ( @project_info ) { push @header, "\n   ${line}";
}
 
#######################################
# Contact Information
#######################################
  
push @header, " ", "Contact: ";

foreach $line ( @contact_info )
{
   @fields = split( ",", $line );

   if ( $#fields != 3 ) { push @header, "\n   ${line}" }
   else { push @header, "\n   ${fields[0]}", "   tel: ${fields[1]}", "   email: ${fields[2]} (${fields[3]})" }
}
 
#######################################
# Read Reciprocity Text
#######################################
  
$f = "${headdir}/general.reciprocity";
@arr = &ReadFile($f);

push @header, " ", " ************ RECIPROCITY AGREEMENT ***************", " ", @arr;
push @header, " ", " **************************************************", " ";
 
#######################################
# Write results
#######################################
 
$outfile = ($outfile) ? $file : "&STDOUT";
open(FILE,">${outfile}");

if ( $#errarr > -1 )
{ foreach $row (@errarr) { print FILE "ERROR: ${row}\n"; } }
else
{ foreach $row (@header) { print FILE "${row}\n"; } }
close(FILE);
 
#######################################
# Disconnect from DB
#######################################
 
&disconnect_db($dbh);

exit;

sub SetLineWidth()
{
   local($str, $lw) = @_;
   my @chars, $cnt, $line, $char;

   @chars = split(//, $str);

   $cnt = 0;
   $line = '';

   foreach $char ( @chars )
   {
      next if ( $char =~ /\r/ );

      if ( $char =~ / / )
      {
         if ( $cnt >= $lw )
         {
            $line = $line."\n";
            $cnt = 0;
         } else { $line = $line.$char; }
      }
      elsif ( $char =~ m/(\n)/ )
      {
         $line = $line."\n";
         $cnt = 0;
      }
      else { $line = $line.$char; }
      $cnt ++;
   }

   return $line;
}

sub showargs()
{
   print "\n#########################\n";
   print "ccg_header.pl\n";
   print "#########################\n\n";
   print "Build a general purpose (non-data specific) header.\n";
   print "general warnings, etc.\n\n";
   print "Builds a general purpose header (non-data specific)\n";
   print "that includes generic usage, reciprocity, disclaimer\n";  
   print "and time stamp. Project and PI information supplied by user. \n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-c, -contact_user=[user(s)].  User is a GMD Linux LDAP username.\n";
   print "     Specify a single user (e.g., -contact_user=ken)\n";
   print "     or any number of users (e.g., -contact_user=ken,dan)\n\n";
   print "    -contact_info=[contact info(s)].  User-supplied contact information.\n";
   print "     (e.g., -contact_info='Dr. John Doe'\n";
   print "     (e.g., -contact_info='Dr. John Doe','Dr. Jane Doe')\n\n";
   print "-p, -project=[project_abbr]\n";
   print "     Specify a single GMD project (e.g., -project=ccg_surface)\n";
   print "     or any number of GMD projects (e.g., -project=ccg_surface, ccg_aircraft)\n\n";
   print "    -project_info=[project info] User-supplied project information.\n";
   print "     (e.g., -project_info=GLOBALVIEW\n";
   print "     (e.g., -project_info=GLOBALVIEW,'CarbonTracker North America')\n\n";
   print "   (ex) ccg_header.pl -project_abbr=ccg_surface,ccg_aircraft\n";
   print "           -project_info=GLOBALVIEW -contact_user=tom,colm,ken -contact_info='John Doe'\n\n";
   exit;
}
