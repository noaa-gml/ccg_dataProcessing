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
# Makes GMD header and ccg_tower data file
# Adapted from ccg_datarequest.pl
# 2009-11 (kam)
#

#
# Get arguments
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "dataargs=s", "eventargs=s", "exclusion!", "help|h", "not", "parameterprogram=s", "preliminary!", "project|p=s", "site|s=s", "strategy|st=s", "stdout", "outputdir=s");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

if ($Options{site})
{
   $site = $Options{site};
   ( $site_code, $ext ) = split "_", $site;
} else { &showargs() };

if ($Options{parameterprogram})
{
   @parameterprogram_abbrs = &unique_array(split(',', lc($Options{parameterprogram})));
   $parameterprogram_str = join(',', @parameterprogram_abbrs);
}  
else
{ &showargs() }

if ($Options{project}) { $project_abbr = $Options{project} } else { &showargs() };

if ($Options{strategy}) { $strategy_abbr = $Options{strategy} } else { &showargs() };

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
if ( $outputdir ne '' && $outputdir !~ m/\/$/ ) { $outputdir = $outputdir.'/'; }

%outopts = ();

#
#######################################
# Initialization
#######################################
#
$perldir = "/projects/src/db/";
$perlcode = "${perldir}ccg_tower.pl";
@errarr = ();

# Check inputs
if ( $#parameterprogram_abbrs > 0 )
{ push (@errarr, "ERROR: Only one parameter+programu may be requested at a time."); }
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

# 438|WGC|Walnut Grove, California|United States|38.2650|-121.4911|0.00|8|1|NOAA Earth System Research Laboratory|United States|ESRL|noaa_logo.gif|C|Quasi-continuous|3|Tower|DOE Environmental Energy Technologies Division at Lawrence Berkeley National Laboratory||-9999.9

#######################################
# Prepare Header
#######################################
 
$perl = "${perldir}ccg_dataheader.pl";
$z = "${perl} -parameterprogram=${parameterprogram_str} -project=${project_abbr} -strategy=${strategy_abbr} -site=${site_code}";
if ( $eventargs ne "" ) { $z = $z." -eventargs='$eventargs'"; }
if ( $dataargs ne "" ) { $z = $z." -dataargs='$dataargs'"; }
if ( $merge ) { $z = $z." -merge='$merge'"; }
if ( $not ) { $z = $z." -not"; }

#print "$z\n";
@header = `$z`;
@tmp = grep(index($_, "ERROR") != -1, @header);
push (@errarr, @tmp);

chomp @header;

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

#
#######################################
# Get Data
#######################################
#

$z = "${perlcode} -site=${site_code} -parameterprogram=${parameterprogram_str}";
if ( $preliminary ) { $z = $z." -preliminary"; }
if ( $exclusion ) { $z = $z." -exclusion"; }
if ( $eventargs ne "" ) { $z = "${z} -event=${eventargs}"; }
if ( $dataargs ne "" ) { $z = "${z} -data=${dataargs}"; }
if ( $not ) { $z = "${z} -not"; }

@outoptskeys = keys ( %outopts );

foreach $outoptskey ( @outoptskeys )
{
   if ( $outopts{$outoptskey} )
   { $z = $z." -$outoptskey"; }
}

$z = "${z} -stdout";
$z = "${z} -shownames";

#print $z."\n";
@data = `${z}`;

if ( $#data == 0 )
{
   push (@errarr, "ERROR: No data for PROJECT: '$project_abbr', STRATEGY: '$strategy_abbr', PARAMETERPROGRAM: '$parameterprogram_str', SITE: '$site_code'");
}
 
#######################################
# Prepare output by month
#######################################

# ccg_insitu.pl format

# site_code year month day hour minute seconds intake_height analysis_value total_uncertainty nonrandom_uncertainty random_uncertainty standard_deviation n_samples analysis_flag analysis_instrument
# BAO 2012 01 01 00 13 25     300.00    396.564   -999.990      0.092   -999.990   -999.990   1 .CP       L4
# site_code year month day hour minute seconds intake_height analysis_value measurement_uncertainty random_uncertainty standard_deviation scale_uncertainty n_samples analysis_flag analysis_instrument
# AMT 2010 01 01 00 09 55     107.00    135.803      4.333      3.032      5.111      1.358   4 ...  R6


# Data Request format

# site_code year month day hour minute seconds latitude longitude elevation intake_height measured_value measurement_uncertainty systematic_uncertainty random_uncertainty standard_deviation scale_uncertainty analysis_flag
# BAO 2008 06 12 00 29 57   40.0500 -105.0100 1584.000  22.00 402.918  0.050 0.045 0.013 0.046 0.07 F..

foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
{
   ($parameter_formula, $program_abbr) = split(/~/, $parameterprogram_abbr);

   push(@parameter_formulas, lc($parameter_formula));
   push(@program_abbrs, lc($program_abbr));
}

# Make the array unique
@parameter_formulas = &unique_array(@parameter_formulas);
@program_abbrs = &unique_array(@program_abbrs);

if ( $#program_abbrs > 0 )
{ $program_str = 'multi'; }
else
{ $program_str = $program_abbrs[0]; }

if ( $#parameter_formulas > 0 )
{ $parameter_str = 'multi'; }
else
{ $parameter_str = $parameter_formulas[0]; }

($junk, $project_str) = split(/_/, $project_abbr);

if ( $strategy_abbr =~ m/,/ )
{ $strategy_str = 'multi'; }
else
{ $strategy_str = $strategy_abbr; }


# determine start year and month
@tmp = split " ", $data[1];
$yr1 = $tmp[1]; $mo1 = $tmp[2];

# determine end year and month
@tmp = split " ", $data[$#data];
$yr2 = $tmp[1]; $mo2 = $tmp[2];

$formatstr = '%s_%s_%s-%s_1_%s_%s.txt';

for ( $yr=$yr1, $lyr=0, $lmo=0; $yr<=$yr2; $yr++ )
{
   for ( $mo=1; $mo<=12; $mo++ )
   {

      if ( $yr != $lyr and $mo != $lmo ) 
      { 
         @monthfile = &PrepareMonthOutput( $yr, $mo, @data );
         next if ( $#monthfile == (-1) );
         
         $yrmo = sprintf("%4.4d%2.2d", $yr, $mo );

         $outfile = $outputdir.'/'.sprintf($formatstr, $parameter_str, lc($site_code), lc($project_str), lc($strategy_str), $program_str, $yrmo);
         #print $outfile,"\n";

         if ( $stdout == 0 )
         {
            &WriteFile( $outfile, @monthfile )
         } else { foreach $item ( @monthfile ) { print $item,"\n"; } }
      }
      $lmo = $mo;
   }
   $lyr = $yr;
}

sub PrepareMonthOutput
{
   my ($yr, $mo, @data) = @_;
   my $row;
   my $format = "%6s %4.4d %2.2d %2.2d %2.2d %2.2d %2.2d %9.4f %9.4f %10.3f %9.1f %9.3f %9.3f %9.3f %9.3f %9.3f %4s";
   my $yrmo, $yrmo_;
   my @month, @tmp;
   my @monthfile;

   $yrmo_ = sprintf( "%4.4d%2.2d", $yr, $mo );

   @month = ();
   @monthfile = ();

   foreach $row (@data)
   {
      @tmp = split " ", $row;
      $yrmo = sprintf( "%4.4d%2.2d", $tmp[1], $tmp[2] );

      next if ( $yrmo lt $yrmo_ );
      last if ( $yrmo gt $yrmo_ );
      
      push @month, $row;
   }

   next if ( $#month == (-1) );

   # include header 
   push @monthfile, @header;

   # include format descriptor

   push @monthfile, '# data_fields: '.join(' ', 'site_code', 'year', 'month', 'day', 'hour', 'minute', 'seconds', 'latitude', 'longitude', 'elevation(masl)', 'intake_height(magl)', 'measured_value', 'measurement_uncertainty', 'random_uncertainty', 'standard_deviation', 'scale_uncertainty', 'analysis_flag');
   ($parameter_formula, $program_abbr) = split(/~/, $parameterprogram_abbrs[0]); 

   # include data

   foreach $row ( @month )
   {
      @tmp = split " ", $row;

      push @monthfile, sprintf( $format, @tmp[0 .. 6], @siteinfo[4..6], @tmp[7 .. 12], $tmp[14]);
   }

   return @monthfile;
}

#
#######################################
# Subroutines
#######################################
#
sub showargs()
{
print "\n#########################\n";
print "ccg_datarequest_tower\n";
print "#########################\n\n";
print "Creates the data aspect of a data request by calling\n";
print "ccg_dataheader.pl for the header and ccg_flask.pl\n";
print "for the data.\n\n";
print "Options:\n\n";
print "-dataargs=[analysis arguments]\n";
print "     Specify analysis constraints that are passed directly\n";
print "     ccg_flask.pl\n\n";
print "-eventargs=[sample arguments]\n";
print "     Specify sample constraints that are passed directly\n";
print "     ccg_flask.pl\n\n";
print "-h, -help\n";
print "     Produce help menu\n\n";
print "-not\n";
print "     Negate the flag constraint logic\n\n";
print "-parameterprogram=[parameter program(s)]\n";
print "     paramater formulae + program abbreviation\n";
print "     Specify a single parameter program (e.g., -parameterprogram=co2~ccgg)\n\n";
print "-outputdir=[output directory]\n";
print "     Specify the directory files will be created. Default\n";
print "     is the current working directory.\n";
print "-p, -project=[project]\n";
print "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n\n";
print "-s, -site=[site]\n";
print "     Specify the site\n\n";
print "-st, -strategy=[strategy]\n";
print "     Specify a strategy. (e.g., insitu)\n\n";
print "# Make data file for co2 at WKT\n";
print "   (ex) ccg_datarequest_tower -site=wkt -parameter=co2~ccgg -project=ccg_tower -strategy=insitu\n\n";
exit;
}
