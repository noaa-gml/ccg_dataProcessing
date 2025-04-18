#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# ccg_dataheader
# 
# Build CCG data header.  Include generic 
# usage, reciprocity, and disclaimer.  Also
# include time stamp and PI information
#
# November 2006 - kam
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }
#
$noerror = GetOptions(\%Options, "average=s", "dataargs=s", "eventargs=s", "help|h", "merge=i", "not", "outfile|o=s", "parameter=s", "parameterprogram=s", "program=s", "project|p=s", "site|s=s", "strategy|st=s");
#
if ( $noerror != 1 ) { exit; }
#
if ($Options{help}) { &showargs() }
#
$dataargs = $Options{dataargs};

$eventargs = $Options{eventargs};

$merge = $Options{merge};

$not = $Options{not};

$outfile = ($Options{outfile}) ? $Options{outfile} : "";
#
@parameterprogram_abbrs = ();
if ($Options{parameterprogram})
{  
   @parameterprogram_abbrs = &unique_array(split(',', lc($Options{parameterprogram})));
}

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
#
if (!($Options{project})) { &showargs() }
$project_abbr = $Options{project};
#
if (!($Options{strategy})) { &showargs() }
$strategystr = $Options{strategy};

if (!($Options{site})) { &showargs() }
$site_code = $Options{site};

$average = ( $Options{average} ) ? $Options{average} : "";
#
#######################################
# Initialization
#######################################
#
$headdir = "/projects/ftp/readme";
@header = ();
@errarr = ();
$today = SysDate();
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();

#
#######################################
# Get program_num
#######################################
#
if ($#program_abbrs >= 0)
{
   @program_nums = ();

   for ($i=0; $i<@program_abbrs; $i++)
   {
      $exitcode = 1;
      $z = &get_relatedfield($program_abbrs[$i], 'program_abbr', 'program_num', $exitcode);
      if ( $exitcode > 0 ) {die("${program_abbrs[$i]} not found in DB\n")}
      $program_nums[$i] = $z;
   }
}
#
#######################################
# Get parameterprogram nums
#######################################
#
@parameterprogram_nums = ();
if ( scalar $#parameterprogram_abbrs > -1 )
{  
   # parameterprogram user specified
   foreach $parameterprogram_abbr ( @parameterprogram_abbrs )
   {
      ($parameter_formula, $program_abbr) = split('~', $parameterprogram_abbr);

      $exitcode = 1; 
      $parameter_num = &get_relatedfield($parameter_formula, 'parameter_formula', 'parameter_num', $exitcode);
      if ( $exitcode > 0 ) {die($parameter_formula." not found in DB\n")}

      $exitcode = 1; 
      $program_num = &get_relatedfield($program_abbr, 'program_abbr', 'program_num', $exitcode);
      if ( $exitcode > 0 ) {die($program_abbr." not found in DB\n")}

      push(@parameterprogram_nums, 'parameter_num:'.$parameter_num.'~+~program_num:'.$program_num);
   }
}
else
{  
   # parameterprogram NOT user specified

   if ( &in_array('all', @parameter_formulas) )
   {
      # parameter 'all' specified
      %summarydata = ();
      %argshash = ();
      $argshash{output} = 'hash';
      $argshash{orderby} = 'parameter_formula';
      %summarydata = &get_data_summary(%argshash);

      @parameter_nums = &unique_array(@ { $summarydata{parameter_num} });
   }
   else
   {
      # process each parameter to get the num
      @parameter_nums = ();
      foreach $parameter_formula ( @parameter_formulas )
      {
         $exitcode = 1;
         $parameter_num = &get_relatedfield($parameter_formula, 'parameter_formula', 'parameter_num', $exitcode);
         if ( $exitcode > 0 ) {die($parameter_formula." not found in DB\n")}

         push(@parameter_nums, $parameter_num);
      }
   }

   if ( scalar $#parameter_nums > -1 )
   {
      # Only do this is parameter(s) is/are specified

      if ( scalar $#program_nums < 0 )
      {
         # program NOT user specified
         foreach $parameter_num ( @parameter_nums )
         {
            %summarydata = ();
            %argshash = ();
            $argshash{output} = 'hash';
            $argshash{orderby} = 'program_formula';
            $argshash{parameter_num} = $parameter_num;
            %summarydata = &get_data_summary(%argshash);

            @program_nums = &unique_array(@ { $summarydata{program_num} });

            foreach $program_num ( @program_nums )
            {
               push(@parameterprogram_nums, 'parameter_num:'.$parameter_num.'~+~program_num:'.$program_num);
            }
         }
      }
      else
      {
         # program user specified
         foreach $parameter_num ( @parameter_nums )
         {
            foreach $program_num ( @program_nums )
            {
               push(@parameterprogram_nums, 'parameter_num:'.$parameter_num.'~+~program_num:'.$program_num);
            }
         }
      }
   }
   #
   # Only keep parameterprogram sets that exists within data_summary
   #
   @finalparameterprogram_nums = (); 
   foreach $parameterprogram_num ( @parameterprogram_nums )
   {
      %hash = &nvpair_split($parameterprogram_num, ':', '~\+~');

      %summarydata = (); 
      %argshash = (); 
      $argshash{output} = 'array';
      $argshash{parameter_num} = $hash{parameter_num};
      $argshash{program_num} = $hash{program_num};
      @summarydata = &get_data_summary(%argshash);

      if ( $#summarydata >= 0 )
      {
         push(@finalparameterprogram_nums, $parameterprogram_num);
      }
   }

   @parameterprogram_nums = @finalparameterprogram_nums;
}

if ( $#parameterprogram_nums < 0 )
{
   die ("Parameter, program, or parameterprogram not specified.");
}

#
#######################################
# Get project_num
#######################################
#
$exitcode = 1;
$project_num = &get_relatedfield($project_abbr, "project_abbr", "project_num", $exitcode);
if ($exitcode > 0) {die("Project '${project_abbr}' not found in DB\n");}
#
#######################################
# Get strategy numbers
#######################################
#
@strategy_abbrs = split(/,/, $strategystr);
@strategy_nums = ();

foreach $strategy_abbr ( @strategy_abbrs )
{
   $exitcode = 1;
   $strategy_num = &get_relatedfield($strategy_abbr, "strategy_abbr", "strategy_num", $exitcode);
   if ( $exitcode > 0 )
   { die("Strategy '".$strategy_abbr."' not found in DB\n"); }
   push(@strategy_nums, $strategy_num);
}

#
#######################################
# Get site_num
#######################################
#
$exitcode = 1;
$site_num = &get_relatedfield($site_code, 'site_code', 'site_num', $exitcode);
if ($exitcode > 1) {die("Site '$site_code' not found in DB\n")}
#
#######################################
# Get project PI information (by parameter)
#######################################
#
@contacts = ();

foreach $parameterprogram_num ( @parameterprogram_nums )
{
   %tmphash = &nvpair_split($parameterprogram_num);

   foreach $strategy_num ( @strategy_nums )
   {
      $select = " SELECT t2.name, t2.tel, t2.email, t3.name, t4.abbr";
      $from = " FROM project_contact as t1, contact as t2, strategy as t3";
      $from = $from.", gmd.program as t4";
      $where = " WHERE t1.site_num = ?";
      $where = $where." AND t1.project_num = ?";
      $where = $where." AND t1.strategy_num = ?";
      $where = $where." AND t1.program_num = ?";
      $where = $where." AND t1.parameter_num = ?";
      $where = $where." AND t1.contact_num = t2.num AND t1.strategy_num = t3.num";
      $where = $where." AND t1.program_num = t4.num";

      $sql = $select.$from.$where;
      @sqlargs = ($site_num, $project_num, $strategy_num, $tmphash{program_num}, $tmphash{parameter_num});

      #print "$sql\n";
      #print join('|', @sqlargs)."\n";

      $sth = $dbh->prepare($sql);
      $sth->execute(@sqlargs);
      #
      # Fetch result
      #
      @tmp = $sth->fetchrow_array();

      if ( $tmp[0] eq "" )
      {
         @args = ();
         push(@args,&get_relatedfield($site_num, 'site_num', 'site_code'));
         push(@args,&get_relatedfield($project_num, 'project_num', 'project_abbr'));
         push(@args,&get_relatedfield($strategy_num, 'strategy_num', 'strategy_abbr'));
         push(@args,&get_relatedfield($tmphash{program_num}, 'program_num', 'program_abbr'));
         push(@args,&get_relatedfield($tmphash{parameter_num}, 'parameter_num', 'parameter_formula'));

         $line = sprintf("No contact information for SITE: '%s', PROJECT: '%s', STRATEGY: '%s', PROGRAM: '%s', PARAMETER: '%s'", @args);
            push (@errarr, $line);
      }

      $parameter_formula = &get_relatedfield($tmphash{parameter_num}, 'parameter_num', 'parameter_formula');
      push @contacts, join('~+~', $parameter_formula, @tmp);
      $sth->finish();
   }
}

#
#######################################
# Get cooperating agency information
#######################################
#

@coops = ();
$ncoops = 0;
foreach $strategy_num ( @strategy_nums )
{

   $select = "SELECT name, abbr, url, comment";
   $from = " FROM ccgg.site_coop";
   $where = " WHERE site_num = ?";
   $and = " AND project_num = ?";
   $and = $and." AND strategy_num = ?";

   $sql = $select.$from.$where.$and;

   $sth = $dbh->prepare($sql);
   $sth->execute($site_num, $project_num, $strategy_num);
   #
   # Fetch result
   #

   while (@tmp = $sth->fetchrow_array()) { @coops[$ncoops++] = join('~+~', @tmp) }
   $sth->finish();
}

@coops = &unique_array(@coops);

#
#######################################
# Read Usage Text
#######################################
# 
$f = "${headdir}/general.usage";
@arr = &ReadFile($f);

unshift @arr, " ", " ************ USE OF GML DATA ****************", " ";

for ( $i=0; $i<=$#arr; $i++ )
{ $arr[$i] = 'comment: '.$arr[$i]; }
#jwm 4/30/21. add comment to see readme if available for citation text.  this is so it shows up in each file.
#note this shows up when doing a datarequest too (no readme file).
$arr[$i] = 'comment: Please see accompanying README file, if available, for citation text.';
push @header, @arr;
#
#######################################
# Read Disclaimer Text
#######################################
# 
$f = "${headdir}/general.warnings";
@arr = &ReadFile($f);

unshift @arr, ' ';

for ( $i=0; $i<=$#arr; $i++ )
{ $arr[$i] = 'comment: '.$arr[$i]; }

push @header, @arr;
#
#######################################
# Contact Information
#######################################
# 
#
# Extract all the names
#
foreach $line ( @contacts ) { push(@names, (split(/\~\+\~/, $line))[1]); }

#
# Get each unique name so that each name will only be listed once
#
@names = &unique_array(@names);

#
# Loop through and get all of the parameters by unique name
#
foreach $name ( @names )
{
   #
   # Get all the contact entries associated with a specific name
   #
   @tmp = grep($name eq (split(/\~\+\~/, $_))[1], @contacts);

   #
   # Combine multiple entries
   #
   $contact_name = "";
   $contact_tel = "";
   $contact_email = "";
   $strategy_name = "";
   @contact_params = ();
   foreach $line ( @tmp )
   {
      # parameter.formula, contact.name, contact.tel, contact.email, 
      # strategy.name, program.abbr
      @fields = split(/\~\+\~/, $line);
      push(@contact_params, uc($fields[0]).' '.$fields[5].' ('.$fields[4].')');
      $contact_name = $fields[1];
      $contact_tel = $fields[2];
      $contact_email = $fields[3];
   }

   @contact_params = &unique_array(@contact_params);

   if ( $#contact_params > -1 )
   {
      push @header, 'comment: ';
      foreach $contact_param ( @contact_params )
      {
         push (@header, 'contact_parameter: '.$contact_param);
      }
      push @header, "contact_name: ${contact_name}";
      push @header, "contact_telephone: ${contact_tel}";
      push @header, "contact_email: ${contact_email}";
   }
}
#
#######################################
# Cooperating Agency
#######################################
#
@collabarr = ();
for ($i=0; $i<=$#coops; $i++ )
{

   ($name, $abbr, $url, $comment) = split(/\~\+\~/, $coops[$i]);

   if ( $name ne "" )
   {  
      $abbr = ( $abbr ne "" ) ? " [${abbr}]" : "";

      push @collabarr, &SetLineWidth( $name.$abbr, 40, 'collaborator_name: ' );

      if ( $url ne "" )
      {
         push @collabarr, "collaborator_url: ${url}";
      }

      if ( $comment ne "" )
      {
         push @collabarr, &SetLineWidth( $comment, 40, 'collaborator_comment: ' );
      }

      if ( $i < $#coops ) { push (@collabarr, 'comment:'); }
   }
}

if ( $#collabarr > -1 )
{
   $text = 'NOAA thanks the following collaborators without whom these measurements would not be possible.';

   unshift @collabarr, &SetLineWidth( $text, 40, 'comment: '), 'comment: ';
   unshift @collabarr, 'comment: ', 'comment:  ************ COLLABORATORS ***************', 'comment: ';

   push @header, @collabarr;
}
#
#######################################
# Read Reciprocity Text
#######################################
# 
$f = "${headdir}/general.reciprocity";
@arr = &ReadFile($f);

unshift @arr, '', ' ************ RECIPROCITY AGREEMENT ***************', '';

for ( $i=0; $i<=$#arr; $i++ )
{ $arr[$i] = 'comment: '.$arr[$i]; }

push @header, @arr;

#
#######################################
# Put constraints into the file
#######################################
# 

push @header, 'comment:', 'comment:  ************ DATA DESCRIPTION ***************', 'comment:';

push @header, 'description_site-code: '.$site_code;
push @header, 'description_project-abbr: '.$project_abbr;
push @header, 'description_strategy-abbr: '.$strategystr;

if ( $eventargs )
{ push @header, 'description_sample-constraints: '.$eventargs; }
if ( $dataargs )
{ push @header, 'description_analysis-constraints: '.$dataargs; }
if ( $merge )
{ push @header, 'description_merge: '.$merge; }
if ( $not )
{ push @header, 'description_not-flag: '.$not; }
if ( $average )
{ push @header, 'description_average: '.$average; }
#
#######################################
# Creation Date
#######################################
# 
push @header, 'description_creation-time: '.$today;

#
#######################################
# File Content
#######################################
# 
push @header, 'comment:', 'comment:  ************ DATA DOCUMENTATION ***************', 'comment:';
push @header, 'comment: Please refer to the species-specific README file in the';
push @header, 'comment: appropriate directory folder at https://gml.noaa.gov/aftp/data/trace_gases/.';
push @header, 'comment:';

#
#######################################
# Write results
#######################################
#
$outfile = ($outfile) ? $file : "&STDOUT";
open(FILE,">${outfile}");

if ( $#errarr > -1 )
{ foreach $row (@errarr) { print FILE "ERROR: ${row}\n"; } }
else
{ foreach $row (@header) { print FILE "# ${row}\n"; } }
close(FILE);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);

exit;

sub SetLineWidth()
{
   my($str, $lw, $prefix) = @_;
   my @chars, $cnt, $line, $char;
   my @arr;

   @chars = split(//, $str);

   $cnt = 0;
   $line = $prefix;

   foreach $char ( @chars )
   {
      next if ( $char =~ /\r/ );

      if ( $char =~ / / )
      {
         if ( $cnt >= $lw )
         {
            push @arr, $line;
            $line = $prefix;
            $cnt = 0;
         } else { $line = $line.$char; }
      }
      elsif ( $char =~ m/(\n)/ )
      {
         push @arr, $line;
         $line = $prefix;
         $cnt = 0;
      }
      else { $line = $line.$char; }
      $cnt ++;
   }

   if ( $cnt > 0 )
   { push @arr, $line; }

   return @arr;
}

sub showargs()
{
   print "\n#########################\n";
   print "ccg_dataheader\n";
   print "#########################\n\n";
   print "Build the header for data request event files.\n";
   print "This includes parameter specific contact information,\n";
   print "general warnings, etc.\n\n";
   print "Options:\n\n";
   print "-h, -help\n";
   print "     Produce help menu\n\n";
   print "-o, -outfile=[outfile]\n";
   print "     Specify output file\n\n";
   print "-g, -parameter=[parameter(s)]\n";
   print "     paramater formulae\n";
   print "     Specify a single parameter (e.g., -parameter=co2)\n";
   print "     or any number of parameters\n";
   print "     (e.g., -parameter=co2,co2c13,co2o18,ch4,co)\n\n";
   print "-p, -project=[project]\n";
   print "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n\n";
   print "-program=[program]\n";
   print "     Specify a program. (e.g., -program=CCGG)\n";
   print "     or any number of programs\n";
   print "     (e.g., -project=CCGG,ARL)\n\n";
   print "-s, -site=[site]\n";
   print "     Specify a site\n\n";
   print "-st, -strategy=[strategy]\n";
   print "     Specify a strategy. (e.g., pfp, flask)\n";
   print "     or any number of strategies\n";
   print "     (e.g., -strategy=pfp,flask)\n\n";
   print "# Make the header for co2 at BLD with project ccg_surface\n";
   print "#    and strategy flask for program CCGG\n";
   print "   (ex) ccg_dataheader.pl -site=BLD -project=ccg_surface\n";
   print "           -strategy=flask -parameter=co2 -program=CCGG\n\n";
   print "# Make the header for co2 at BLD with project ccg_aircraft\n";
   print "#    and strategy pfp for program CCGG\n";
   print "   (ex) ccg_dataheader.pl -site=BLD -project=ccg_aircraft\n";
   print "           -strategy=pfp -parameter=co2 -program=CCGG\n\n";
   print "# Make the header for co2,ch4,co at BLD with project\n";
   print "#    ccg_aircraft and strategy pfpi for program CCGG\n";
   print "   (ex) ccg_dataheader.pl -site=BLD -project=ccg_aircraft\n";
   print "           -strategy=pfp -parameter=co2,ch4,co -program=CCGG\nn";
   exit;
}
