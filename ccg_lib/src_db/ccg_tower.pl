#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/ccg_dbutils2.pl";
#
# Extract quasi-continuous tower data
# Optimized for speed.
#
# 2008 - Created by Dan Chao
# 2010-04-28 - Updated by Dan Chao
#
# 2018-3-8 - added unc Option for call compatability with other insitu scripts.  This script
# already outputs uncertainties by default.  We could program it to do it optionally (like other insitu scripts)
# but no one asked for that.  This is added so ccg_insitu.pl can pass it's params into this without error.
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "data|d=s", "dd", "event|e=s", "exclusion", "help|h", "namefields=s", "nodef", "outfile|o=s", "parameterprogram=s", "position", "project|p=s", "preliminary", "shownames", "site|s=s", "stdout", "unc");

if ( $noerror != 1 ) { exit; }

$binby_event = $Options{event};
$binby_data = $Options{data};

$file = $Options{outfile};

$site_code = ( $Options{site} ) ? lc( $Options{site} ) : &showargs();

$exclusion = ($Options{exclusion}) ? 1 : 0;
$preliminary = ($Options{preliminary}) ? 1 : 0;
$position = ( $Options{position} ) ? 1 : 0;

if ($Options{parameterprogram})
{
   @parameterprogram_abbrs = &unique_array(split(',', lc($Options{parameterprogram})));
   $parameterprogram_str = join(',', @parameterprogram_abbrs);
}
else
{ &showargs() }

# This is an admin option

$select_nfstr = $Options{namefields};

$stdout = $Options{stdout};
$dd = ( $Options{dd} ) ? 1 : 0;
$nodef = ( $Options{nodef} ) ? 1 : 0;

if ($Options{help}) { &showargs() }

%outopts = ();
$outopts{'shownames'} = ($Options{shownames}) ? 1 : 0;

#
#######################################
# Initialization
#######################################
#
$project = "ccg_tower";
$dbdir = "/projects/src/db/";

( $parameter_formula, $program_abbr ) = split(/~/, $parameterprogram_abbrs[0]);

$table = $site_code.'_'.$parameter_formula.'_insitu';
$tt_event = "z".int(10**8*rand());

#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();


#See if using new merged Table
$merged=dosqlval("select case when exists(select * from insitu_view where site=? and parameter=?) then 1 else 0 end",($site_code,$parameter_formula));
#on hold during transition. 4/24
$merged=0;

if($merged==1){#New merged table source
    $table = lc( "insitu\_view" );
}

#
# Check table existence
#
$sql = "SHOW TABLES LIKE '$table'";
$sth = $dbh->prepare($sql);
$sth->execute();
$rows = $sth->rows;
$sth->finish();

if ( $rows != 1 ) { die("Table($table) not found for site '$site_code' and parameter '$parameter_formula' in DB.\n"); }

$site_num = &get_relatedfield($site_code, "site_code", "site_num");
$parameter_num = &get_relatedfield($parameter_formula, "parameter_formula", "parameter_num");
$project_num = &get_relatedfield($project, 'project_abbr', 'project_num');
$strategy_num = 3;

# Get position information

if ( $position )
{
   $cmd = "${dbdir}ccg_siteinfo.pl -site='${site_code}'";
   @siteinfo = split( '\|', `${cmd}` );
}

#
# Select data from main table into temporary table
#
$create = " CREATE TEMPORARY TABLE ${tt_event} (INDEX (date, hr, min, sec) )";
$select = " SELECT *";
$from = " FROM $table";
$where = " WHERE 1=1";
if($merged){
    $where=$where." and ${table}.parameter_num=${parameter_num} and ${table}.site_num=${site_num}";
}

if ( $nodef == 1 ) { $where = $where." AND ${table}.value > -999" }

if ( $binby_event )
{
   $binby_event = &BinByEventAlt($binby_event, $site_code);
   $where = $where." AND ".&BinByEvent($table, $binby_event, "");
}
if ( $binby_data )
{ $where = $where." AND ".&BinByEvent($table, $binby_data, ""); }

$sql = $create.$select.$from.$where;
#print "$sql\n";
$sth = $dbh->prepare($sql);
$sth->execute();
$sth->finish();

#
#######################################
# Other data processing options
#######################################
#
if ( $preliminary ) { FlagPreliminary(); }

if ( $exclusion ) { DataExclusion(); }

#
# Select data from temporary table
#
if ( $select_nfstr )
{
   @select_nfarr = split('\|', $select_nfstr);
}
else
{
   #@select_nfarr = ("site:'".uc($site_code)."'",'yr:YEAR(date)','mo:LPAD(MONTH(date),2,"0")','dy:LPAD(DAY(date),2,"0")','hr:LPAD(hr,2,"0")', 'min:LPAD(min,2,"0")', 'sec:LPAD(sec,2,"0")', 'intake_ht:intake_ht', 'value:value', 'unc:unc', 'analunc:analunc', 'n:n', 'flag:flag', 'inst:inst');

   # The above statement only partially formatted output string.  Full format is below. 2011-02-11 (kam)
   # jwm - 3/31/16.  Changed inst pad to 7 to account for longer instrument names.  I didn't see anything obvious that will break from changing this
   # width, but if something comes up, we could leave at 3 and optionally output the full length.
    @select_nfarr = ( "site_code:'".uc($site_code)."'",'year:YEAR(date)','month:LPAD(MONTH(date),2,"0")', 'day:LPAD(DAY(date),2,"0")','hour:LPAD(hr,2,"0")', 'minute:LPAD(min,2,"0")','seconds:LPAD(sec,2,"0")', 'intake_height:LPAD(intake_ht, 10, " ")', 'analysis_value:LPAD(value, 10, " ")','measurement_uncertainty:LPAD(meas_unc, 10, " ")', 'random_uncertainty:LPAD(random_unc, 10, " ")','standard_deviation:LPAD(std_dev, 10, " ")', 'scale_uncertainty:LPAD(scale_unc, 10, " ")', 'n_samples:LPAD(n, 3, " ")','analysis_flag:flag','analysis_instrument:LPAD(inst,7," ")' );
    if($merged==1){
        @select_nfarr = ( "site_code:'".uc($site_code)."'",'year:YEAR(date)','month:LPAD(MONTH(date),2,"0")', 'day:LPAD(DAY(date),2,"0")','hour:LPAD(hr,2,"0")', 'minute:LPAD(min,2,"0")','seconds:LPAD(sec,2,"0")', 'intake_height:LPAD(intake_ht, 10, " ")', 'analysis_value:LPAD(value, 10, " ")','measurement_uncertainty:LPAD(meas_unc, 10, " ")', 'random_uncertainty:LPAD(random_unc, 10, " ")','standard_deviation:LPAD(std_dev, 10, " ")', 'n_samples:LPAD(n, 3, " ")','analysis_flag:flag','analysis_instrument:LPAD(inst,7," ")' );

    }
}

if ( $dd ) { push @select_nfarr, "dd:dd" }

if ( $position )
{
   push @select_nfarr,
   "lat:'".sprintf("%10.3f", $siteinfo[4])."'",,
   "lon:'".sprintf("%10.3f", $siteinfo[5])."'",,
   "elev:'".sprintf("%10.2f", $siteinfo[6])."'";
}


@selectfld_hdrarr = ();
@selectfld_arr = ();
foreach $nf ( @select_nfarr )
{
   ($name, $field ) = split(/:/, $nf, 2);

   push(@selectfld_namearr, $name);
   push(@selectfld_arr, $field);
}

$selectfld_namestr = join(" ", @selectfld_namearr);
$selectfld_str = join(",", @selectfld_arr);

$select = " SELECT ${selectfld_str}";
$from = " FROM ${tt_event}";
$order = " ORDER BY date, hr, min, sec";

$sql = $select.$from.$order;
#print "$sql\n";

$sth = $dbh->prepare($sql);
$sth->execute();

#
# bind_columns is faster than fetchrow_array!
# Create an array with 'undef' elements equal to the number of columns
#
my @row = (undef) x $sth->{NUM_OF_FIELDS};
$sth->bind_columns( \(@row) );

#
################################
# Prepare the output location
################################
#
if ($file) { $file = ">${file}"; }
elsif ($stdout) { $file = ">&STDOUT"; }
else { $file = "| vim -"; }
open(FILE,${file});

#
# Print the field names if the user requested them
#
if ( $outopts{'shownames'} )
{
   print FILE "$selectfld_namestr\n";
}

#
# Loop through the SELECT results and print them to the output
#
while ($sth->fetch)
{
   print FILE join(' ', @row)."\n";
}

close(FILE);

$sth->finish();
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);


exit;

sub BinByEvent()
{
   local($t, $e, $not) = @_;
   my ($str, @bin, $i, $z);
   my ($binby, $range, $min, $max);

   $str = "";

   @bin = split("~",$e);

   for ($i=0; $i<@bin; $i++)
   {
      ($binby, $range) = split(":",$bin[$i],2);

      ($min, $max) = split(",",$range);
      if ($max eq "") { $max = $min; }
      else
      { $and = "${and} AND ${t1}.${binby} >= '${min}' AND ${t1}.${binby} <= '${max}'"; }

      if ($binby eq "date") { $min = &MinDate($min); $max = &MaxDate($max); }

      if (grep(/\(/,$binby) && grep(/\)/,$binby))
      {
         $z = "${binby} >= '${min}' AND ${binby} <= '${max}'";
         $str = ($str) ? $str. " AND ".$z : $z;
      }
      elsif ($binby eq "inst" ||
             $binby eq "flag")
      {
         $z = (grep(/\%/, $range) || grep (/\_/, $range)) ?
         BinByLike($t, $binby, $range, "") :
         BinByItem($t, $binby, $range);

         $str = ($str) ? $str." AND ".$z : $z;
      }
      elsif ( $binby eq "datetime" )
      {
         ($bdate,$btime) = split(/_/, $min);
         ($edate,$etime) = split(/_/, $max);

         $bdate = &MinDate($bdate);
         $btime = &MinTime($btime);
         $edate = &MaxDate($edate);
         $etime = &MaxTime($etime);

         @bdatearr = split(/-/, $bdate);
         @btimearr = split(/:/, $btime);
         @edatearr = split(/-/, $edate);
         @etimearr = split(/:/, $etime);

         $bdd = &date2dec(@bdatearr, @btimearr);
         $edd = &date2dec(@edatearr, @etimearr);

         $z = " ( (${t}.dd >= '$bdd' AND ${t}.dd <= '$edd') )";

         $str = ($str) ? $str." AND ".$z : $z;
      }
      elsif ( $binby eq "hr" )
      {
         if ( $min > $max )
         {
            $z = "( ${t}.hr >= '$min' OR ${t}.hr <= '$max' )";
         }
         else
         {
            $z = "( ${t}.hr >= '$min' AND ${t}.hr <= '$max' )";
         }
         $str = ($str) ? $str." AND ".$z : $z;
      }
      else
      {
         $z = BinByRange($t, $binby, $min, $max);
         $str = ($str) ? $str." AND ".$z : $z;
      }
   }
   return $str;
}

sub BinByEventAlt()
{
   my($e, $site_code) = @_;

   if ( $e =~ m/~?alt:/i )
   {
      $elev = &get_relatedfield($site_code, 'site_code', 'site_elev');

      #
      # If the elevation is the default value, then
      #    treat the altitude as intake_ht so that
      #    the code exits gracefully
      #
      if ( $elev eq "-9999.99" ) { $elev = 0; }

      @bin = split("~",$e);

      for ($i=0; $i<@bin; $i++)
      {
         ($binby, $range) = split(":",$bin[$i],2);

         if ( $binby eq "alt" )
         {
            ($min, $max) = split(",",$range);
            if ($max eq "") { $max = $min; }

            $min = $min-$elev-1;
            if ( $min < 0 ) { $min = 0; }

            $max = $max-$elev+1;
            if ( $max < 0 ) { $max = 0; }

            $bin[$i] = "intake_ht:$min,$max";
         }
      }

      $e = join("~", @bin);
   }

   return $e;
}

sub BinByItem()
{
   local($t, $n, $r) = @_;
   my ($z, $i, @tmp);

   @tmp = split(",", $r);

   for ($i = 0, $z = ''; $i < @tmp; $i++)
   { $z = ($z) ?  "${z} OR ${t}.${n}='${tmp[$i]}'" : "(${t}.${n}='${tmp[$i]}'"; }

   $z = $z.")";

   return $z;
}

sub BinByRange()
{
   local($t, $n, $min, $max) = @_;
   my ($z);


   $z =  "(${t}.${n} >= '${min}' AND ${t}.${n} <= '${max}')";
   return $z;
}

sub BinByLike()
{
   local($t, $n, $r, $not) = @_;
   my ($z, $i, @tmp);

   @tmp = split(",", $r);

   for ($i = 0, $z = ''; $i < @tmp; $i++)
   { $z = ($z) ?  "${z} OR ${t}.${n} ${not} LIKE '${tmp[$i]}'" : "(${t}.${n} ${not} LIKE '${tmp[$i]}'"; }

   $z = $z.")";
   return $z;
}

sub DataRelease()
{
   local($project_num, $strategy_num, $parameter_num, $site_num, $type) = @_;

   $select = "SELECT data, begin, end";
   $from = " FROM data_release";
   $where = " WHERE project_num = '$project_num' AND strategy_num = '$strategy_num'";
   $and = " AND parameter_num = '$parameter_num' AND site_num = '$site_num'";
   $and = "${and} AND type = '$type'";

   $sql = $select.$from.$where.$and;
   #print "$sql\n";

   $sth = $dbh->prepare($sql);
   $sth->execute();

   @releaseinfo = (); $nreleaseinfo = 0;
   while (@tmp = $sth->fetchrow_array())
   { @releaseinfo[$nreleaseinfo++] = join('|', @tmp) }
   $sth->finish();

   $where = "";

   # If no information in data_release then mark all as preliminary
   if ( $#releaseinfo < 0 && $type eq 'P' )
   { $where = " WHERE ( ${tt_event}.date >= '1900-01-01' AND ${tt_event}.date <= '9999-12-31'"; }
   else
   {
      foreach $line ( @releaseinfo )
      {
         ($data, $begin, $end) = split(/\|/, $line);

         if ( $where eq "" ) { $where = " WHERE ( (${tt_event}.date >= '$begin' AND ${tt_event}.date <= '$end')"; }
         else { $where = "${where} OR (${tt_event}.date >= '$begin' AND ${tt_event}.date <= '$end')"; }
      }
   }

   return $where;
}

sub FlagPreliminary()
{
   #print "$project_num, $strategy_num, $parameter_num, $site_num\n";

   $where = &DataRelease($project_num, $strategy_num, $parameter_num, $site_num, 'P');

   $where = ( $where eq "" ) ? "" : "${where} )";

   if ( $where ne "" )
   {
      $update = " UPDATE ${tt_event}";
      $set = " SET ${tt_event}.flag = CONCAT(SUBSTRING(flag,1,2),'P')";

      $sql = $update.$set.$where;
      #print "$sql\n";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();
   }
}

sub DataExclusion()
{

   #print "$project_num, $strategy_num, $parameter_num, $site_num\n";

   $where = &DataRelease($project_num, $strategy_num, $parameter_num, $site_num, 'E');

   $where = ( $where eq "" ) ? "" : "${where} )";

   if ( $where ne "" )
   {
      $delete = " DELETE";
      $from = " FROM ${tt_event}";

      $sql = $delete.$from.$where;
      #print "$sql\n";
      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();
   }
}

sub MinDate()
{
   local($m) = @_;
   my ($yr, $mo, $dy);

   ($yr,$mo,$dy) = split("-",$m);
   $yr = ($yr) ? $yr : '1900';
   $mo = ($mo) ? $mo : '01';
   $dy = ($dy) ? $dy : '01';
   return "${yr}-${mo}-${dy}";
}

sub MaxDate()
{
   local($m) = @_;
   my ($yr, $mo, $dy);

   ($yr,$mo,$dy) = split("-",$m);
   $yr = ($yr) ? $yr : '9999';
   $mo = ($mo) ? $mo : '12';
   $dy = ($dy) ? $dy : '31';
   return "${yr}-${mo}-${dy}";
}

sub MinTime()
{
   local($m) = @_;
   my ($hr, $mn, $sc);

   ($hr,$mn,$sc) = split(":",$m);
   $hr = ($hr) ? $hr : '00';
   $mn = ($mn) ? $mn : '00';
   $sc = ($sc) ? $sc : '00';
   return "${hr}:${mn}:${sc}";
}

sub MaxTime()
{
   local($m) = @_;
   my ($hr, $mn, $sc);

   ($hr,$mn,$sc) = split(":",$m);
   $hr = ($hr) ? $hr : '23';
   $mn = ($mn) ? $mn : '59';
   $sc = ($sc) ? $sc : '59';
   return "${hr}:${mn}:${sc}";
}

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
   print HELP "ccg_tower\n";
   print HELP "#########################\n\n";
   print HELP "Create a table according to user-supplied options.\n";
   print HELP "Results are displayed in a \"vi\" session [default].  Enter\n";
   print HELP "\":q!\" to quit session.  Use \"-stdout\" option to send to STDOUT.\n";
   print HELP "Use \"-outfile\" option to redirect output.  Please see EXAMPLES\n";
   print HELP "below.\n\n";
   print HELP "Options:\n\n";
   print HELP "-d, -data=[analysis constraints]\n";
   print HELP "     Note: This option is synonymous with the 'event' option.\n";
   print HELP "     Specify the DATA (e.g., measurement or analysis) constraints\n";
   print HELP "     The format of this argument is <attribute name>:<min>,<max>\n";
   print HELP "     where attribute name may be value, flag, inst, date, time, ...\n";
   print HELP "     The -l option will generate a list of data attributes.\n";
   print HELP "     Multiple bin conditions delimited by the tilda (~) may be\n";
   print HELP "     specified.\n\n";
   print HELP "     (ex) -data=date:2000,2003\n";
   print HELP "     (ex) -data=inst:H4\n";
   print HELP "     (ex) -data=flag:..%\n";
   print HELP "     (ex) -data=date:2000-02-01,2000-11-03~inst:H4\n\n";
   print HELP "-dd\n";
   print HELP "     Include decimal date at the end of each row.\n";
   print HELP "     (ex) -dd\n\n";
   print HELP "-e, -event=[sample constraints]\n";
   print HELP "     Note: This option is synonymous with the 'data' option.\n";
   print HELP "     Specify the EVENT (e.g., sample collection) constraints\n";
   print HELP "     The format of this argument is <attribute name>:<min>,<max>\n";
   print HELP "     where attribute name may be date, time, lat, lon, alt, ...\n";
   print HELP "     (ex) -event=date:2000,2003\n";
   print HELP "     (ex) -event=lat:-20,20\n";
   print HELP "     (ex) -event=date:2000-02-01,2000-11-03~alt:450,460\n\n";
   print HELP "-exclusion\n";
   print HELP "     Set mixing ratios to default if the data are in the\n";
   print HELP "     time period to be excluded.\n\n";
   print HELP "-h, -help\n";
   print HELP "     Produce help menu\n\n";
   print HELP "-n, -nodef\n";
   print HELP "     Exclude all default (-999.99) values.\n";
   print HELP "     (ex) -nodef\n\n";
   print HELP "-o, -outfile=[outfile]\n";
   print HELP "     Specify output file\n\n";
   print HELP "-g, -parameter=[parameter(s)]\n";
   print HELP "     paramater formulae\n";
   print HELP "     Specify a single parameter (e.g., -parameter=co2)\n";
   print HELP "     or any number of parameters\n";
   print HELP "     (e.g., -parameter=co2,ch4,co)\n\n";
   print HELP "-preliminary\n";
   print HELP "     Set 3rd column of QC flag to 'P' if the data are in the\n";
   print HELP "     time period considered as preliminary.\n\n";
   print HELP "-shownames\n";
   print HELP "     Print the field names as the first line of the output. A\n";
   print HELP "     space is used to deliminate the field names.\n\n";
   print HELP "-s, -site=[site(s)]\n";
   print HELP "     site code\n";
   print HELP "     Specify a single site (e.g., -site=wgc)\n";
   print HELP "     or any number of sites (e.g., -site=wgc,sct)\n";
   print HELP "-stdout\n";
   print HELP "     Send result to STDOUT.\n\n\n";
   print HELP "# EXAMPLES\n\n";
   print HELP "# List all co2 measurements for WGC.\n";
   print HELP "   (ex) ccg_tower -site=wgc -parameter=co2 -stdout\n\n";
   print HELP "# List all P1 co2 measurements for WGC.\n";
   print HELP "   (ex) ./ccg_tower -site=wgc -parameter=co2  -data=inst:P1\n\n";
   print HELP "# List all co measurements for SNP for the period 2009-1 through 2009-2.\n";
   print HELP "   (ex) ccg_tower -site=snp -par=co -event=date:2009-1,2009-2.\n";
   close(HELP);

   exit;
}
