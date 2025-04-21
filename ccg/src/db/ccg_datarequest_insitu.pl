#!/usr/bin/perl
#
use DBI;
use Getopt::Long;
use Cwd;
use File::Path;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
#
# Prepares aggregated and high-frequency quasi-continuous data 
# with GMD header.  Adapted from ccg_datarequest_tower.pl
#
# 2010-08 (kam)
#
#
# Get arguments
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "dataargs=s", "eventargs=s", "exclusion!", "help|h", "not", "parameter|g=s", "parameterprogram=s", "preliminary!", "site|s=s", "stdout", "outputdir=s", "project=s", "strategy=s", "average=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

if ($Options{site})
{
   $site = $Options{site};
   ( $code, $ext ) = split "_", $site;
} else { &showargs() };

if ($Options{parameterprogram})
{
   ($params, $program) = split(/~/, $Options{parameterprogram});
}
elsif ( $Options{parameter} )
{
   $params = $Options{parameter};
   $program = "ccgg";
}
else
{ &showargs() }


if ($Options{average}) { $average = $Options{average} } else { $average = "" };
if ($Options{project}) { $proj_abbr = $Options{project} } else { &showargs() };
if ($Options{strategy}) { $strat_abbr = $Options{strategy} } else { &showargs() };

# Default $preliminary to 1
my $preliminary = 1;
$preliminary = ( $Options{preliminary} ne '' ) ? $Options{preliminary} : $preliminary;

# Default $exclusion to 1
my $exclusion = 1;
$exclusion = ( $Options{exclusion} ne '' ) ? $Options{exclusion} : $exclusion;

$dataargs = $Options{dataargs};
$eventargs = $Options{eventargs};
$not = $Options{not};

$stdout = ( $Options{stdout} ) ? 1 : 0;
$outputdir = ( $Options{outputdir} ) ? $Options{outputdir} : getcwd;


#
#######################################
# Initialization
#######################################
#
$perldir = "/projects/src/db/";
@errarr = ();
 

# Check inputs
if ( $params =~ m/,/g )
{ push (@errarr, "ERROR: Only one parameter may be requested at a time."); }
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
 
#######################################
# Get Site Information
#######################################

$z = "${perldir}ccg_siteinfo.pl -site=${site}";
$siteinfostr = `${z}`;

if ( $siteinfostr eq '' )
{ push (@errarr, "ERROR: No site information for site '$site'."); }

@siteinfo = split '\|', $siteinfostr;

# 15|BRW|Barrow, Alaska|United States|71.3230|-156.6114|11.00|9|1|NOAA Earth System Research Laboratory|United States|ESRL|noaa_logo.gif|C|Quasi-continuous|0|Single Fixed Position|||

#######################################
# Prepare Header
#######################################
 
$perl = "${perldir}ccg_dataheader.pl";
$args = " -parameter=${params} -project=${proj_abbr} -strategy=${strat_abbr} -program=${program} -site=${code}";
if ( $eventargs ne "" ) { $args = $args." -event=${eventargs}"; }
if ( $dataargs ne "" ) { $args = $args." -data=${dataargs}"; }
if ( $average ) { $args = $args." -average=${average}"; }

@header = `${perl} ${args}`;
@tmp = grep(index($_, "ERROR") != -1, @header);
push (@errarr, @tmp);

chop @header;

@output = @header;

#
#######################################
# Number of header lines
#######################################
#
# Plus one for the addition of the new line
# Plus one for the data_fields line
# Plus one for $#output return (referenced to 0)

$count = scalar $#output + 1 + 1 + 1;
unshift @output, '# number_of_header_lines: '.$count;

chomp @output;
 
#######################################
# Get Data
#######################################


$perl = "${perldir}ccg_insitu.pl";

$args = '';
$args = $args." -site=${code} -parameter=${params}";
if ( $preliminary ) { $args = $args." -preliminary"; }
if ( $exclusion ) { $args = $args." -exclusion"; }
if ( $eventargs ne "" ) { $args = $args." -event=${eventargs}"; }
if ( $dataargs ne "" ) { $args = $args." -data=${dataargs}"; }
if ( $not ) { $args = $args." -not"; }

if ( $average ) { $args = $args." -average=${average}"; }

$args = $args." -stdout";
$args = $args." -shownames";
$args = $args." -project=${proj_abbr}";

@data = `${perl} ${args}`;

if ( $#data eq -1 )
{
   push (@errarr, "ERROR: No data for PROJECT: '$proj_abbr', STRATEGY: '$strat_abbr', PARAMETER: '$params', SITE: '$code'");
}

# Add the name to the data fields line
$data[0] =~ s/^#/# data_fields:/;

push @output, @data;

if ( $stdout )
{
   $file = "&STDOUT";
}
else
{
   if ( ! -e $outputdir )
   { push (@errarr, "ERROR: Output directory '".$outputdir."' does not exist."); }

   # (ex) co2_alt_surface-flask_1_ccgg.txt

   ($junk, $project_str) = split(/_/, $proj_abbr);

   # Exception.  project "ccg_obs" output files are named "surface-insitu" (2014-06-27, kam)

   if ( $project_str == "obs" ) { $project_str = "surface"; }

   if ( $average )
   {
      if ( $average ne "hour" ) { $file = $outputdir.'/'.lc($params).'_'.lc($code).'_'.$project_str.'-insitu_1_ccgg_'.${average}.'.txt'; }
      else
      {
         @z1 = split( /date\:/i, $eventargs );
         @z2 = split( /,/, $z1[1] );

         if ( $#z2 == 0 )
         {
            $file = $outputdir.'/'.lc($params).'_'.lc($code).'_'.$project_str.'-insitu_1_ccgg_'.${average}.'_'.$z2[0].'.txt';
         }
         else
         {
            if ( substr( $z2[0],0,4 ) ne substr( $z2[1],0,4 ) )
            {
               $file = $outputdir.'/'.lc($params).'_'.lc($code).'_'.$project_str.'-insitu_1_ccgg_'.${average}.'_merge.txt';
            }
            else
            {
               $file = $outputdir.'/'.lc($params).'_'.lc($code).'_'.$project_str.'-insitu_1_ccgg_'.${average}.'_'.$z2[0].'.txt';
            }
         }
      }
   }
   else { $file = $outputdir.'/'.lc($params).'_'.lc($code).'_'.$project_str.'-insitu_1_ccgg_all.txt'; }
}

if ( $#errarr != -1 )
{
   #
   # If there is an error, send it to STDERR
   #
   @output = @errarr;
   open(FPOUT,">&STDERR");
}
else { open(FPOUT,">${file}"); }

foreach $row (@output)
{
   chomp($row);
   print FPOUT "${row}\n";
}
close(FPOUT);
#
#######################################
# Subroutines
#######################################
#
sub showargs()
{
print "\n#########################\n";
print "ccg_datarequest_insitu.pl\n";
print "#########################\n\n";
print "Prepares aggregated and high-frequency quasi-continuous data.\n"; 
print "This script calls ccg_dataheader.pl and ccg_insitu.pl.\n\n";
print "Options:\n\n";
print "-dataargs=[analysis arguments]\n";
print "     Specify analysis constraints that are passed directly\n";
print "     ccg_insitu.pl\n\n";
print "-eventargs=[sample arguments]\n";
print "     Specify sample constraints that are passed directly\n";
print "     ccg_insitu.pl\n\n";
print "-h, -help\n";
print "     Produce help menu\n\n";
print "-g, -parameter=[parameter(s)]\n";
print "     paramater formulae\n";
print "     Specify a single parameter (e.g., -parameter=co2)\n\n";
print "-outputdir=[output directory]\n";
print "     Specify the directory files will be created. Default\n";
print "     is the current working directory.\n";
print "-p, -project=[project]\n";
print "     Specify a project. (e.g., ccg_obs, ccg_tower)\n\n";
print "-s, -site=[site]\n";
print "     Specify the site\n\n";
print "-st, -strategy=[strategy]\n";
print "     Specify a strategy. (e.g., insitu)\n\n";
print "-average=[hour | day | month ]\n";
print "     Specify a averaging interval. If not specified, high frequency\n";
print "     will be presented.\n\n";
print "# Make data file for co2 at MLO\n";
print "   (ex) ./ccg_datarequest_insitu.pl -site=mlo -par=co2 -average=day  -data=date:2010 -project=ccg_obs -strategy=insitu -stdout\n\n";
exit;
}
