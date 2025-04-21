#!/usr/bin/perl
#
use DBI;
use Cwd;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/perllib.pl";
#
# Makes GMD header and ccg_flask data file
#

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

#
# Get arguments
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "comment", "dataargs=s", "eventargs=s", "exclusion!", "help|h", "merge=i", "noprogram", "noseconds", "not", "nouncertainty", "outputdir=s", "parameter=s", "parameterprogram=s", "preliminary!", "program=s", "project|p=s", "site|s=s", "stdout", "strategy|st=s", "showtags");

if ( $noerror != 1 ) { exit; }

if ($Options{help}) { &showargs() }

if ($Options{site}) { $site_code = $Options{site} } else { &showargs() };

@parameter_formulas = ();
if ($Options{parameter})
{
   @parameter_formulas = &unique_array(split(',',lc($Options{parameter})));
}

@program_abbrs = ();
if ($Options{program})
{
   @program_abbrs = &unique_array(split(',',lc($Options{program})));
}

if ($Options{parameterprogram})
{
   @tmpparameterprogram_abbrs = &unique_array(split(',', lc($Options{parameterprogram})));

   foreach $tmpparameterprogram_abbr ( @tmpparameterprogram_abbrs )
   {
      ($parameter_formula, $program_abbr) = split('~', $tmpparameterprogram_abbr, 2);
      push(@parameterprogram_abbrs, 'parameter_formula:'.$parameter_formula.'~+~program_abbr:'.$program_abbr);
   }
}
else
{
   if ( scalar $#parameter_formulas > -1 )
   {
      # Only do this is parameter(s) is/are specified

      if ( scalar $#program_abbrs < 0 )
      {
         # program NOT user specified
         foreach $parameter_formula ( @parameter_formulas )
         {
            %summarydata = ();
            %argshash = ();
            $argshash{output} = 'hash';
            $argshash{orderby} = 'parameter_formula';
            $argshash{parameter_formula} = $parameter_formula;
            %summarydata = &get_data_summary(%argshash);

            @program_abbrs = &unique_array(@ { $summarydata{program_abbr} });

            foreach $program_abbr ( @program_abbrs )
            {
              push(@parameterprogram_abbrs, 'parameter_formula:'.$parameter_formula.'~+~program_abbr:'.$program_abbr);
            }
         }
      }
      else
      {
         # program user specified
         foreach $parameter_formula ( @parameter_formulas )
         {
            foreach $program_abbr ( @program_abbrs )
            {
               push(@parameterprogram_abbrs, 'parameter_formula:'.$parameter_formula.'~+~program_abbr:'.$program_abbr);
            }
         }
      }
   }

#
# Only keep parameterprogram sets that exists within data_summary
#
   @finalparameterprogram_abbrs = ();
   foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
   {
      %hash = &nvpair_split($parameterprogram_abbr, ':', '~\+~');

      %summarydata = ();
      %argshash = ();
      $argshash{output} = 'array';
      $argshash{parameter_formula} = $hash{parameter_formula};
      $argshash{program_abbr} = $hash{program_abbr};
      @summarydata = &get_data_summary(%argshash);

      if ( $#summarydata >= 0 )
      {
         push(@finalparameterprogram_abbrs, $parameterprogram_abbr);
      }
   }

   @parameterprogram_abbrs = @finalparameterprogram_abbrs;
}

if ( scalar $#parameterprogram_abbrs < 0 ) 
{ &showargs; }

@tmparr = ();
foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
{
   %hash = &nvpair_split($parameterprogram_abbr, ':', '~\+~');
   push(@tmparr, $hash{parameter_formula}.'~'.$hash{program_abbr});
}
$parameterprogram_str = join(',', @tmparr);

if ($Options{project}) { $project_abbr = lc($Options{project}) } else { &showargs() };

if ($Options{strategy}) { $strategy_abbr = lc($Options{strategy}) } else { &showargs() };

# Default $preliminary to 1
my $preliminary = 1;
$preliminary = ( $Options{preliminary} ne '' ) ? $Options{preliminary} : $preliminary;
# Default $exclusion to 1
my $exclusion = 1;
$exclusion = ( $Options{exclusion} ne '' ) ? $Options{exclusion} : $exclusion;
$dataargs = $Options{dataargs};
$eventargs = $Options{eventargs};
$not = $Options{not};
$merge = $Options{merge};
$comment = $Options{comment};
$showtags = $Options{showtags};

$stdout = ( $Options{stdout} ) ? 1 : 0;
$outputdir = ( $Options{outputdir} ) ? $Options{outputdir} : getcwd;
if ( $outputdir ne '' && $outputdir !~ m/\/$/ ) { $outputdir = $outputdir.'/'; }

%outopts = ();
$outopts{'noprogram'} = ($Options{noprogram}) ? 1 : 0;
$outopts{'noseconds'} = ($Options{noseconds}) ? 1 : 0;
$outopts{'nouncertainty'} = ($Options{nouncertainty}) ? 1 : 0;

# Elev and intake height are now always included
$outopts{'elevation'} = 1;
$outopts{'intake_height'} = 1;


#
#######################################
# Initialization
#######################################
#
$perldir = "/projects/src/db/";
#$perlcode = "${perldir}ccg_flask.pl";
$perlcode = "${perldir}ccg_flask2.py";
$perlcode = "/home/ccg/mund/dev/ccgdblib/ccg_flask2.py";
@errarr = ();

#
#######################################
# Prepare Header
#######################################
#
$z = "${perldir}ccg_dataheader.pl";
$z = $z." -project=$project_abbr -strategy=$strategy_abbr -site=$site_code -parameterprogram=$parameterprogram_str";
if ( $eventargs ne "" ) { $z = $z." -eventargs='$eventargs'"; }
if ( $dataargs ne "" ) { $z = $z." -dataargs='$dataargs'"; }
if ( $merge ) { $z = $z." -merge='$merge'"; }
if ( $not ) { $z = $z." -not"; }

@header = `$z`;
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

$z = "${perlcode} -site='${site_code}' -project='${project_abbr}'";
$z = $z." -strategy='${strategy_abbr}' -parameterprogram='${parameterprogram_str}'";
if ( $preliminary ) { $z = $z." -preliminary"; }
if ( $exclusion ) { $z = $z." -exclusion"; }
if ( $eventargs ne "" ) { $z = $z." -event='${eventargs}'"; }
if ( $dataargs ne "" ) { $z = $z." -data='${dataargs}'"; }
if ( $merge ) { $z = $z." -merge='${merge}'"; }
if ( $comment ) { $z = $z." -comment"; }
if ( $not ) { $z = $z." -not"; }
if ($showtags) {$z.=" -showtags";}

$z= "${perlcode} --site=$site_code --project=$project_abbr --strategy=$strategy_abbr --parameterprogram=$parameterprogram_str";
if ($preliminary) {$z.=" --preliminary";}
if ($exclusion) {$z.=" --exclusion";}
if ( $eventargs ne "" ) { $z.=" --event_constraints=${eventargs}"; }
if ( $dataargs ne "" ) { $z .=" --data_constraints=${dataargs}"; }
if ( $merge ) { $z = $z." --merge=1"; }
$columns="dataRequestCols_old";
if ( $comment ) { $columns.=",ev_comment,a_comment"; }
if ($showtags) {
   $columns.=",tag_nums";
   $z.=" --tagDictionaryOutFile='/tmp/tagDict.txt'";
}
$z.=" --cols=$columns";

if ( $not ) { $z = $z." --not_flag"; }


@outoptskeys = keys ( %outopts );

#NEED TO PARSE AND BREAK THESE OUT
#foreach $outoptskey ( @outoptskeys )
#{
#   if ( $outopts{$outoptskey} )
#   { #$z = $z." --$outoptskey"; }
#}

#
# DYC - 2008-10-22
# Added for Jocelyn so Ken could use this program to make
# FTP files of co2c14 that had uncertainty. Ken also
# needs the comments
#
foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
{
   if ( $parameterprogram_abbr =~ m/^co2c14~/i )
   {
      $z = $z." --comment";
      last;
   }
}
#$z = $z." -stdout";
#$z = $z." -shownames";
#toLogFile($z);
print "$z\n";
@data = `${z}`;

if ( $#data == 0 )
{
   push (@errarr, "ERROR: No data for PROJECT: '$project_abbr', STRATEGY: '$strategy_abbr', PARAMETERPROGRAM: '$parameterprogram_str', SITE: '$site_code'");
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

   foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
   {
      %hash = &nvpair_split($parameterprogram_abbr, ':', '~\+~');
      push(@tmpparameter_formulas, lc($hash{parameter_formula}));
      push(@tmpprogram_abbrs, lc($hash{program_abbr}));
   }

   # Make the array unique
   @tmpparameter_formulas = &unique_array(@tmpparameter_formulas);
   @tmpprogram_abbrs = &unique_array(@tmpprogram_abbrs);

   if ( $#tmpprogram_abbrs > 0 ) 
   { $program_str = 'multi'; }
   else
   { $program_str = $tmpprogram_abbrs[0]; }

   if ( $#tmpparameter_formulas > 0 ) 
   { $parameter_str = 'multi'; }
   else
   { $parameter_str = $tmpparameter_formulas[0]; }

   ($junk, $project_str) = split(/_/, $project_abbr);

   if ( $strategy_abbr =~ m/,/ )
   { $strategy_str = 'multi'; }
   else
   { $strategy_str = $strategy_abbr; }


   # (ex) co2_alt_surface-flask_ccgg_event.txt
   $formatstr = '%s_%s_%s-%s_1_%s_event.txt';

   if ( $merge )
   { $file = $outputdir.sprintf($formatstr, 'merge', lc($site_code), lc($project_str), lc($strategy_str), $program_str); }
   else
   { $file = $outputdir.sprintf($formatstr, $parameter_str, lc($site_code), lc($project_str), lc($strategy_str), $program_str); }
}

if ( $#errarr != -1 )
{
   #
   # If there is an error, send it to STDERR
   #
   @output = @errarr;
   open(FPOUT,">&STDERR");
}
else { open(FPOUT,">${file}") or die ("Could not open file '$file'"); }

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
   print "ccg_datarequest\n";
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
   print "-m, -merge=[merge option]\n";
   print "     See ccg_flask.pl documentation\n\n";
   print "-not\n";
   print "     Negate the flag constraint logic\n\n";
   print "-outputdir=[output directory]\n";
   print "     Specify the directory files will be created. Default\n";
   print "     is the current working directory.\n";
   print "-g, -parameter=[parameter(s)]\n";
   print "     paramater formulae\n";
   print "     Specify a single parameter (e.g., -parameter=co2)\n";
   print "     or any number of parameters\n\n";
   print "     (e.g., -parameter=co2,co2c13,co2o18,ch4,co)\n";
   print "-p, -project=[project]\n";
   print "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n\n";
   print "-s, -site=[site]\n";
   print "     Specify the site\n\n";
   print "-stdout\n";
   print "     Send result to STDOUT.\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., pfp, flask)\n\n";
   print "# Make data file for co2 at CAR with project ccg_aircraft\n";
   print "   (ex) ccg_datarequest -site=car -project=ccg_aircraft\n";
   print "           -parameter=co2\n\n";
   print "# Make data file for co2, ch4 at CAR with project ccg_aircraft\n";
   print "   (ex) ccg_datarequest -site=car -project=ccg_aircraft\n";
   print "           -parameter=co2,ch4\n\n";
   print "# Make data file for co2, ch4 at CAR with project ccg_surface\n";
   print "#    and strategy flask. Merge the output\n";
   print "   (ex) ccg_datarequest -site=car -project=ccg_surface\n";
   print "           -strategy=flask -parameter=co2,ch4 -merge=1\n\n";
   print "# Make data file for co2, ch4 at CAR with project ccg_surface\n";
   print "#    and strategy flask. Constrain analysis results where the\n";
   print "#    flag is not like ..%\n";
   print "   (ex) ccg_datarequest -site=car -project=ccg_surface\n";
   print "           -parameter=co2,ch4 -dataargs=flag:..% -not\n";
   exit;
}
