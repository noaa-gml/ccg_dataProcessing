#!/usr/bin/perl
#
use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";

#
# Extract high-frequency met data from met.<site>_minute tables
#
# 2011-02-09 - kam
# modified to accommodate Kirk's new met tables. 2012-10-25 (kam)
#
 
#######################################
# Parse Arguments
#######################################
 
if ( $#ARGV == -1 ) { &showargs(); }

$noerror = GetOptions( \%Options, "data|d=s", "dd", "event|e=s", "help|h", "namefields=s", 
                                  "nodef", "outfile|o=s", "average|a=s", "shownames", "site|s=s", "stdout" );

if ( $noerror != 1 ) { exit; }

if ( $Options{help} ) { &showargs() }

$binby_event = $Options{event};
$binby_data = $Options{data};

$file = $Options{outfile};

$site = ( $Options{site} ) ? lc( $Options{site} ) : &showargs();

$shownames = ( $Options{shownames} ) ? 1 : 0;
$stdout = $Options{stdout};
$dd = ( $Options{dd} ) ? 1 : 0;
$nodef = ( $Options{nodef} ) ? 1 : 0;

$average = ( $Options{average} ) ? $Options{average} : "hour";
if ( $average !~ /minute/i and $average !~ /hour/i ) { &showargs() }

# This is an admin option
$select_nfstr = $Options{namefields};

#######################################
# Connect to Database
#######################################
 
$dbh = &connect_db();

#######################################
# Initialization
#######################################

$tt_event = "z".int(10**8*rand());
$site_num = &get_field( "num", "gmd.site", "code", "$site" );
$table = ( $site eq 'chs' ) ? lc( "met.${site}" ) : lc( "met.${site}_minute" );

if ( $average =~ /minute/i )
{
   $table = ( $site eq 'chs' ) ? lc( "met.${site}" ) : lc( "met.${site}_minute" );
   $timefield = "time";
}
elsif ( $average =~ /hour/i )
{
   $table = lc( "met.${site}_hour" );
   $timefield = "hour";
}

 
# Select data from temporary table
 
if ( $select_nfstr )
{
   @select_nfarr = split('\|', $select_nfstr);
}
else
{
   if ( $average =~ /minute/i )
   {
      if ( $site eq 'chs' )
      {
         @select_nfarr = ( "site:'".uc($site)."'",'year:YEAR(date)','month:LPAD(MONTH(date),2,"0")',
                           'day:LPAD(DAY(date),2,"0")','hr:LPAD(HOUR(time),2,"0")',
                           'min:LPAD(MINUTE(time),2,"0")','sec:LPAD(SECOND(time),2,"0")',
                           'wind_speed:LPAD(wind_speed, 8, " ")','wind_dir:LPAD(wind_dir, 8, " ")',
                           'bar_press:LPAD(bar_press, 6, " ")', 'flag:LPAD(flag,4," ")' );
      }
      else
      {
         @select_nfarr = ( "site:'".uc($site)."'",'year:YEAR(date)','month:LPAD(MONTH(date),2,"0")',
                           'day:LPAD(DAY(date),2,"0")','hr:LPAD(HOUR(time),2,"0")',
                           'min:LPAD(MINUTE(time),2,"0")','sec:LPAD(SECOND(time),2,"0")',
                           'wind_speed_10m:LPAD(ws, 8, " ")','wind_dir_10m:LPAD(wd, 8, " ")',
                           'bar_press:LPAD(p, 8, " ")','rh:LPAD(u, 8, " ")',
                           'temp_2m:LPAD(t, 8, " ")','temp_10m:LPAD(t1, 8, " ")','temp_top:LPAD(t2, 8, " ")',
                           'precip:LPAD(wi, 8, " ")','wind_steadiness:LPAD(wdg, 8, " ")' ); #,'flag:LPAD(flag,4," ")' );
      }
   }
   elsif ( $average =~ /hour/i )
   {
      if ( $site eq 'chs' )
      {
         print "Hourly data from CHS are not currently available.\n";
         exit;
      }
      else
      {
         @select_nfarr = ( "site:'".uc($site)."'",'year:YEAR(date)','month:LPAD(MONTH(date),2,"0")',
                           'day:LPAD(DAY(date),2,"0")','hr:LPAD(hour,2,"0")',
                           'wind_speed_10m:LPAD(ws, 8, " ")','wind_dir_10m:LPAD(wd, 8, " ")',
                           'bar_press:LPAD(p, 8, " ")','rh:LPAD(u, 8, " ")',
                           'temp_2m:LPAD(t, 8, " ")','temp_10m:LPAD(t1, 8, " ")','temp_top:LPAD(t2, 8, " ")',
                           'precip:LPAD(wi, 8, " ")','wind_steadiness:LPAD(wdg, 8, " ")' ); #,'flag:LPAD(flag,4," ")' );
      }
   }
   if ( $dd ) { push @select_nfarr, "dd:dd" }
}

# Does table exist?

if ( !(DBexist( $table )) ) { die( "${table} not found in MET DB.\n") }

# Select data from main table into temporary table
 
$create = " CREATE TEMPORARY TABLE ${tt_event} (INDEX (date, ${timefield} ) )";

$select = " SELECT *";
$from = " FROM $table";
$where = " WHERE 1=1";

if ( $binby_event ) { $where = $where." AND ".&BinByEvent($table, $binby_event, ""); }

if ( $binby_data ) { $where = $where." AND ".&BinByEvent($table, $binby_data, ""); }

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
  
$order = " ORDER BY dd";

$sql = $select.$from.$order;
# print "$sql\n";

$sth = $dbh->prepare($sql);
$sth->execute();

 
# bind_columns is faster than fetchrow_array!
# Create an array with 'undef' elements equal to the number of columns
 
my @row = (undef) x $sth->{NUM_OF_FIELDS};
$sth->bind_columns( \(@row) );

 
################################
# Prepare the output location
################################
 
if ($file) { $file = ">${file}"; }
elsif ($stdout) { $file = ">&STDOUT"; }
else { $file = "| vim -"; }
open(FILE,${file});

#
# Print the field names if the user requested them
#
if ( $shownames )
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
 
#######################################
# Disconnect from DB
#######################################
 
&disconnect_db($dbh);


exit;

#######################################
# Subroutines
#######################################

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
   local($e, $scode) = @_;

   if ( $e =~ m/~?alt:/i )
   {
      $elev = &get_field("elev", "gmd.site", "code", $scode);

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

sub DBexist()
{
   local( $t ) = @_;
   my $db, $table;

   # Check table existence

   ( $db, $table ) = split /\./, $t;

   $dbh->do("USE ${db}");
    
   $sql = "SHOW TABLES LIKE '$table'";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   $rows = $sth->rows;
   $sth->finish();

   $z = ( $rows != 1 ) ? 0 : 1;

   return $z;
}

sub DataRelease()
{
   local($proj_num, $strat_num, $param_num, $site_num, $type) = @_;

   $select = "SELECT data, begin, end";
   $from = " FROM data_release";
   $where = " WHERE project_num = '$proj_num' AND strategy_num = '$strat_num'";
   $and = " AND parameter_num = '$param_num' AND site_num = '$site_num'";
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
   #print "$proj_num, $strat_num, $param_num, $site_num\n";

   $where = &DataRelease($proj_num, $strat_num, $param_num, $site_num, 'P');

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

   #print "$proj_num, $strat_num, $param_num, $site_num\n";

   $where = &DataRelease($proj_num, $strat_num, $param_num, $site_num, 'E');

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
   print HELP "ccg_met.pl\n";
   print HELP "#########################\n\n";
   print HELP "This script extracts high-frequency met data from the MET DB.\n\n";
   print HELP "Create a table according to user-supplied options.\n";
   print HELP "Results are displayed in a \"vi\" session [default].  Enter\n";
   print HELP "\":q!\" to quit session.  Use \"-stdout\" option to send to STDOUT.\n";
   print HELP "Use \"-outfile\" option to redirect output.  Please see EXAMPLES\n";
   print HELP "below.\n\n";
   print HELP "Options:\n\n";
   print HELP "-dd\n";
   print HELP "     Include decimal date at the end of each row.\n";
   print HELP "     (ex) -dd\n\n";
   print HELP "-a, -average=[time average resolution of data]\n";
   print HELP "     May be either \"minute\" or \"hour\" (default) averages.\n";
   print HELP "     Only minute values available for Cherskii.\n";
   print HELP "     (ex) -average=minute\n";
   print HELP "-e, -event=[sample constraints]\n";
   print HELP "     Specify the EVENT (e.g., sample collection) constraints\n";
   print HELP "     The format of this argument is <attribute name>:<min>,<max>\n";
   print HELP "     where attribute name include date, time, wind_speed, ...\n";
   print HELP "     (ex) -event=date:2000-01-01,2000-01-03\n";
   print HELP "-h, -help\n";
   print HELP "     Produce help menu\n\n";
   print HELP "-o, -outfile=[outfile]\n";
   print HELP "     Specify output file\n\n";
   print HELP "-shownames\n";
   print HELP "     Print the field names as the first line of the output. A\n";
   print HELP "     space is used to deliminate the field names.\n\n";
   print HELP "-s, -site=site code\n";
   print HELP "     (ex) -site=brw\n\n";
   print HELP "-stdout\n";
   print HELP "     Send result to STDOUT.\n\n";
   print HELP "# EXAMPLES\n\n";
   print HELP "   (ex) ./ccg_met.pl -site=chs -event=date:2010-01-01,2010=01-03 -average=minute -shownames\n";
   print HELP "   (ex) ./ccg_met.pl -site=brw -event=date:2010-01-02,2010-01-03\n";
   print HELP "   (ex) ./ccg_met.pl -site=mlo -event=date:2010-01-02,2010-01-03~wind_speed_10m:3,6 -average=minute -shownames\n";
   close(HELP);
   
   exit;
}
