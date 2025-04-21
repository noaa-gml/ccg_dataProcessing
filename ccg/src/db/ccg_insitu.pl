#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Extract quasi-continuous surface data
# Optimized for speed.
#
# This will become the primary Perl driver script for 
# accessing high-frequency and averaged quasi-continuous data from 
# CCGG database (kam).
#
# 2008 - Created by Dan Chao
# 2010-04-28 - Updated by Dan Chao
# 2010-07-16 - Adapted from Dan's ccg_tower.pl (kam)
#
# 2018-3-8 - updates to handle separation of unc to std_dev/unc
#
#######################################
# Parse Arguments
#######################################
 
if ($#ARGV == -1) { &showargs(); }

@args = @ARGV;

$noerror = GetOptions( \%Options, "average|a=s", "data|d=s", "dd", "event|e=s", "exclusion", "help|h", 
                                  "namefields=s", "nodef", "outfile|o=s", "parameter|g=s", "position", "project=s", 
                                  "preliminary", "shownames", "site|s=s", "stdout", "target", "unc" );

$site = ( $Options{site} ) ? lc( $Options{site} ) : &showargs();
$parameter = ( $Options{parameter} ) ? lc( $Options{parameter} ) : &showargs();
$project = ( $Options{project} ) ? lc( $Options{project} ) : &showargs();

#######################################
# Initialization
#######################################

$dbdir = "/ccg/src/db/";

if ( $Options{average} )
{

   if ( $project eq "ccg_obs" || ( $project eq "ccg_surface" && $site =~ /chs/i ) )
   {
      exec( $dbdir."ccg_obs_average.pl ".join( " ", @args ) );
   }
   elsif ( $project eq "ccg_tower" || ( $project eq "ccg_surface" && $site !~ /chs/i ) )
   {
      # Currently, observatory and tower hour tables are identical.
      # 2013-04-19 (kam)
      exec( $dbdir."ccg_obs_average.pl ".join( " ", @args ) );
   }
} 
else
{

   $table = lc( "$site\_$parameter\_insitu" );

   if ( $project eq "ccg_obs" || ( $project eq "ccg_surface" && $site =~ /chs/i ) )
   {
      exec( $dbdir."ccg_obs_insitu.pl ".join( " ", @args ) );
   }
   elsif ( $project eq "ccg_tower" || ( $project eq "ccg_surface" && $site !~ /chs/i ) )
   {
      exec( $dbdir."ccg_tower.pl ".join( " ", @args ) );
   }
} 

exit;

sub showargs()
{
   open(HELP,"| less");

   print HELP "<----------------------- HELP ----------------------->\n";
   print HELP "Navigation Keys: Arrow keys, Page Up, Page Down\n";
   print HELP "Search: /<text> (Similar to vim)\n";
   print HELP "Quit: q\n";
   print HELP "<---------------------------------------------------->\n";
   print HELP "\n";
   print HELP "\n#########################\n";
   print HELP "ccg_insitu.pl\n";
   print HELP "#########################\n\n";
   print HELP "This will become the primary script for extracting\n";
   print HELP "quasi-continuous data from the database.\n\n";
   print HELP "Create a table according to user-supplied options.\n";
   print HELP "Results are displayed in a \"vi\" session [default].  Enter\n";
   print HELP "\":q!\" to quit session.  Use \"-stdout\" option to send to STDOUT.\n";
   print HELP "Use \"-outfile\" option to redirect output.  Please see EXAMPLES\n";
   print HELP "below.\n\n";
   print HELP "Options:\n\n";
   print HELP "-average=[ hour | day | month ]\n";
   print HELP "     Specify the averaging interval.  If not specified, high frequency\n";
   print HELP "     data will be returned. Please be aware that not all averages\n";
   print HELP "     are available at this time.\n";
   print HELP "     (ex) -average=hour\n\n";
   print HELP "-dd\n";
   print HELP "     Include decimal date at the end of each row.\n";
   print HELP "     (ex) -dd\n\n";
   print HELP "-e, -event=[sample constraints]\n";
   print HELP "     Specify the EVENT (e.g., sample collection) constraints\n";
   print HELP "     The format of this argument is <attribute name>:<min>,<max>\n";
   print HELP "     where attribute name may be date, time, lat, lon, alt, ...\n";
   print HELP "     (ex) -event=date:2000,2003\n";
   print HELP "     (ex) -event=lat:-20,20\n";
   print HELP "     (ex) -event=date:2000-02-01,2000-11-03~alt:450,460\n\n";
   print HELP "-exclusion\n";
   print HELP "     Set mixing ratios to default if the data are in the\n";
   print HELP "     time period to be excluded.\n\n";
   print HELP "-g, -parameter=[parameter(s)]\n";
   print HELP "     Required. paramater formulae\n";
   print HELP "     Specify a single parameter (e.g., -parameter=co2)\n";
   print HELP "     or any number of parameters\n";
   print HELP "     (e.g., -parameter=co2,ch4,co)\n\n";
   print HELP "-h, -help\n";
   print HELP "     Produce help menu\n\n";
   print HELP "-n, -nodef\n";
   print HELP "     Exclude all default (-999.99) values.\n";
   print HELP "     (ex) -nodef\n\n";
   print HELP "-o, -outfile=[outfile]\n";
   print HELP "     Specify output file\n\n";
   print HELP "-position\n";
   print HELP "     Include site latitude, longitude and elevation (masl) to the end of each record.\n\n";
   print HELP "-preliminary\n";
   print HELP "     Set 3rd column of QC flag to 'P' if the data are in the\n";
   print HELP "     time period considered as preliminary.\n\n";
   print HELP "-p, -project=[project]\n";
   print HELP "     Required. Specify a project. (e.g., ccg_obs, ccg_tower)\n\n";
   print HELP "-shownames\n";
   print HELP "     Print the field names as the first line of the output. A\n";
   print HELP "     space is used to deliminate the field names.\n\n";
   print HELP "-s, -site=[site(s)]\n";
   print HELP "     Required. site code\n";
   print HELP "     Specify a single site (e.g., -site=smo)\n\n";
   print HELP "-stdout\n";
   print HELP "     Send result to STDOUT.\n\n";
   print HELP "-target\n";
   print HELP "     Output will be from <site>_<parameter>_target table.\n";
   print HELP "     (ex) -target\n\n";
   print HELP "-unc\n";
   print HELP "     Output separate std_dev and unc when available.\n\n";
   print HELP "# EXAMPLES\n\n";
   print HELP "     (ex) ccg_insitu -site=brw -param=ch4 -project=ccg_obs -event=date:2011-01-16,2011-01-28~hour:22,2 -shownames -average=hour.\n";
   close(HELP);
   
   exit;
}
