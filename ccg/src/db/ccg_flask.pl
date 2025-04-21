#!/usr/bin/perl

use DBI;
use Getopt::Long;

require "/projects/src/db/ccg_utils.pl";
require "/projects/src/db/ccg_dbutils.pl";
require "/projects/src/db/ccg_dbutils2.pl";

my $productionDB=1;#FOR TESTING.

#
# Get flask data
#
#######################################
# Parse Arguments
#######################################
#
if ($#ARGV == -1) { &showargs(); }

$noerror = GetOptions(\%Options, "abbr", "comment", "data|d=s", "debug", "elevation", "event|e=s", "exclusion", "intake_height|intake_ht", "help|h", "list", "merge=i", "method|m=s", "noprogram", "noseconds", "not", "nouncertainty", "oldstyle", "outfile|o=s", "pairaverage", "parameter|g=s", "parameterprogram=s", "preliminary", "program=s", "project|p=s", "shownames", "site|s=s", "strategy=s", "status=s", "stdout", "showtags","tagdictionary");

if ( $noerror != 1 ) { exit; }

$abbr_output = ($Options{abbr}) ? 1 : 0;
$comment = ($Options{comment}) ? 1 : 0;
$elevation = ($Options{elevation}) ? 1 : 0;
$intake_height = ($Options{intake_height}) ? 1 : 0;
$shownames = ($Options{shownames}) ? 1 : 0;
$noprogram = ($Options{noprogram}) ? 1 : 0;
$noseconds = ($Options{noseconds}) ? 1 : 0;
$nouncertainty = ($Options{nouncertainty}) ? 1 : 0;
$debugmode = ($Options{debug}) ? 1 : 0;
$showtags = ($Options{showtags})? 1: 0;
$tagdictionary = ($Options{tagdictionary})?1:0;

%outopts = ();
$outopts{'abbr'} = $abbr_output;
$outopts{'comment'} = $comment;
$outopts{'elevation'} = $elevation;
$outopts{'intake_height'} = $intake_height;
$outopts{'shownames'} = $shownames;
$outopts{'noprogram'} = $noprogram;
$outopts{'noseconds'} = $noseconds;
$outopts{'nouncertainty'} = $nouncertainty;
$outopts{'showtags'} = $showtags;

$binby_data = $Options{data};
$binby_event = $Options{event};

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

@strat = ();
if ($Options{strategy})
{
   @strat = &unique_array(split(',',lc($Options{strategy})));
}

if ($Options{help}) { &showargs() }

$not = ($Options{not}) ? 'NOT' : '';

@status = ();
if ($Options{status})
{
   @status = &unique_array(split(',', lc($Options{status})));
}

$list = ($Options{list}) ? 1 : 0;

@method = ();
if ($Options{method})
{
   $binby_event = ($binby_event) ? "${binby_event}~me:" : "me:";

   @tmp = split(',',$Options{method});
   for ($i=0; $i<@tmp; $i++)
   {
      $method[$i] = uc($tmp[$i]);
      $binby_event = ($i) ? "${binby_event},${method[$i]}" : "${binby_event}${method[$i]}";
   }
}

$file = $Options{outfile};

$project_abbr = $Options{project};

$option = ($Options{merge} && ( $#parameter_formulas >= 0 || $#program_abbrs >= 0 || $#parameterprogram_abbrs >= 0 ) ) ? $Options{merge} : 0;

@site = ();
@code = ();
if ($Options{site})
{
   @tmp = split(',',$Options{site});
   for ($i=0; $i<@tmp; $i++)
   {
      $site[$i] = lc($tmp[$i]);
      $code[$i] = substr($tmp[$i],0,3);
   }
}

$stdout = $Options{stdout};

$pairaverage = ($Options{pairaverage} && $option == 0 && ( $#parameter_formulas >= 0 || $#program_abbrs >= 0 || $#parameterprogram_abbrs >= 0 ) ) ? 1 : 0;
$preliminary = ($Options{preliminary} && ( $#parameter_formulas >= 0 || $#program_abbrs >= 0 || $#parameterprogram_abbrs >= 0 ) ) ? 1 : 0;
$exclusion = ($Options{exclusion} && ( $#parameter_formulas >= 0 || $#program_abbrs >= 0 || $#parameterprogram_abbrs >= 0 ) ) ? 1 : 0;
$tagdelim=",";
#
# Disallow comment option if 'average' is set
#
#$comment = ($option || $pairaverage) ? '' : $comment;
#
# Disallow old style format if more than 
# one parameter is specified and averaging is not indicated
#
#JWM 5/16.  This is causing problems for some callers because it basically forces a merge mode which then hides anal data (date, time...)
# and breaks assumptions that some of the older programs were using.  
# I'm going to change the restriction to only apply when more than 1 param specified (which is what the above says 
#anyway).  Currently it restricts even on 1 param (>=0 to >0)
if ($Options{oldstyle}) { $oldstyle = ( ( $#parameter_formulas > 0 || $#program_abbrs > 0 || $#parameterprogram_abbrs > 0 ) && $option == 0) ? 0 : 1; }
#
#######################################
# Initialization
#######################################
#jwm 7/16 - adding tag display support
#Note we have 2 aliases for flask_data and flask_event.  $from_flask_data and $from_flask_event should be used in any from clause
#where we are selecting all the output columns.  $t2 and $t1 respectively should be used in all where clauses.
#This is to support having a left join to the appropriate tags table in the from clause when we are to show tag info.
#where clauses still need to refer to the table directly.  I would love to revamp this using views.. another day.
#We do this conditionally because we don't want to join if not requested (usual case) for better performance.
$t0 = "gmd.site";
$t1 = "flask_event";
$from_flask_event = "flask_event";
$t2 = "flask_data";
$from_flask_data = "flask_data";
$t3 = "site_desc";
$t4 = "gmd.parameter";
$t5 = "project";
$t6 = "strategy";
$t7 = "gmd.program";
$t8 = "data_summary";
if ($showtags) {
   $from_flask_data="flask_data left join (select data_num,group_concat(num separator '$tagdelim') as tags
                from flask_data_tag_view
                group by data_num) as dt on flask_data.num=dt.data_num";
   $from_flask_event="flask_event left join (select event_num, group_concat(num separator '$tagdelim') as tags
                from flask_event_tag_view
                group by event_num) as et on flask_event.num=et.event_num";

}

#
# Temporary tables for event and measurement data
#
$tt_event = "z".int(10**8*rand());
$tt_data = "z".int(10**8*rand());
$tt_avg = "z".int(10**8*rand());
$tt_merge = "z".int(10**8*rand());
$tt_output = "z".int(10**8*rand());

if ( $debugmode )
{
   print "tt_event: $tt_event\n";
   print "tt_data: $tt_data\n";
   print "tt_avg: $tt_avg\n";
   print "tt_merge: $tt_merge\n";
   print "tt_output: $tt_output\n";
}
$flag = "";
#
#######################################
# Connect to Database
#######################################
#
$dbh = &connect_db();
if(!$productionDB){demodb();}
#

if($tagdictionary){
        #Print the tag dictonary and exit.
        my $a=dosql("select * from tag_list",());
	#print "Tag,Name,Tag_type,Severity,Old_style_flag\n";
        printf "%-5s  %-25s  %-12s  %-4s  %s\n",'Tag','Tag type','Severity','Flag','Description';
	foreach my $row (@{$a}){
		my($tag,$name,$type,$sev,$flag)=@{$row}{qw(Tag_number Name Tag_Type Severity Old_style_flag)};
                #print "$tag,$name,$type,$sev,$flag\n ";
                printf "%-5s  %-25s  %-12s  %-4s  %s\n", $tag,$type,$sev,$flag,$name; 
        }
	exit(0);
}

#######################################
# Show Event and Data fields
#######################################
#
if ($list) { &listfields(@dbh); }
#
#######################################
# Get site_num for specified sites
#######################################
#
if ($#code >= 0)
{
   $binby_event = ($binby_event) ? "${binby_event}~site_num:" : "site_num:";

   for ($i=0; $i<@code; $i++)
   {
      $exitcode = 1;
      $z = &get_relatedfield($code[$i], 'site_code', 'site_num', $exitcode);
      if ( $exitcode > 0 ) {die("${code[$i]} not found in DB\n")}
      $binby_event = ($i) ? "${binby_event},${z}" : "${binby_event}${z}";
   }
}
#
#######################################
# Get project_num
#######################################
#
if ($project_abbr)
{
   $searchstr = '';
   if ( $project_abbr eq "surface" ) { $searchstr = "ccg_surface"; }
   if ( $project_abbr eq "aircraft" ) { $searchstr = "ccg_aircraft"; }
   if ( $searchstr eq '' ) { $searchstr = $project_abbr; }

   $exitcode = 1;
   $project_num = &get_relatedfield($searchstr, 'project_abbr', 'project_num', $exitcode);
   if ($exitcode > 0) {die("${project_abbr} not found in DB\n")}
   $binby_event = ($binby_event) ? "${binby_event}~project_num:" : "project_num:";
   $binby_event = "${binby_event}${project_num}";
}
else { $project_num = 0; }

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
# Figure out parameterprogram
#######################################
#
# @todo: Do I really need to use data_summary to figure out parameter program?
#        Is it enough to simply use the user input of parameter and program together?
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
            if($Options{site}){# if ($#code >= 0){
                #If user supplied site(s) filter the call to data_summary by those sites.  
                #Only relevant when 2 programs measure same param (hats sf6 ex), 
                #but can lead to duplicate parameters when not filtered.
                #jwm 1/28/16
                $argshash{site_code}=$Options{site};#just pass straight through.  We assume the site(s) have already been vetted above.
            }
            $argshash{parameter_num} = $parameter_num;
            %summarydata = &get_data_summary(%argshash);

            @program_nums = &unique_array(@ { $summarydata{program_num} });

            foreach $program_num ( @program_nums )
            {
               push(@parameterprogram_nums, 'parameter_num:'.$parameter_num.'~+~program_num:'.$program_num);
            }

            # If no programs were found then include a filler line so we still have
            # the correct output
            if ( scalar $#program_nums < 0 )
            {
               push(@parameterprogram_nums, 'parameter_num:'.$parameter_num.'~+~program_num:1');
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
}

#
#######################################
# Get strategy_num
#######################################
#
if ($#strat >= 0)
{
   @strategy_num = ();

   for ($i=0; $i<@strat; $i++)
   {
      $exitcode = 1;
      $z = &get_relatedfield($strat[$i], 'strategy_abbr', 'strategy_num', $exitcode);
      if ( $exitcode > 0 ) {die("${strat[$i]} not found in DB\n")}
      $strategy_num[$i] = $z;
   }
}
#
#######################################
# Get status_num
#######################################
#
if ($#status >= 0)
{
   @status_num = ();

   for ($i=0; $i<@status; $i++)
   {
      $exitcode = 1;
      $z = &get_relatedfield($status[$i], 'status_name', 'status_num', $exitcode);
      if ( $exitcode > 0 ) {die("${status[$i]} not found in DB\n")}
      $status_num[$i] = $z;
   }
}

#
# Prepare toplevel "flask_event" SELECT
#
$ev_select = "${t1}.num";
$ev_select = "${ev_select},${t0}.code";

$ev_select = "${ev_select},${t1}.dd,${t1}.date,${t1}.time";
$ev_select = "${ev_select},${t1}.id,${t1}.me,${t1}.lat,${t1}.lon,${t1}.alt,${t1}.elev";

$ev_select = "${ev_select},${t1}.comment, f_intake_ht(${t1}.alt, ${t1}.elev) as intake_height";
if ($showtags) {
    $ev_select .= ", et.tags as event_tags";
}else{
   #Need a place holder
   $ev_select .=", '' as event_tags";
}

#
# Prepare toplevel "flask_data" SELECT
#
$data_select = "${t2}.event_num,${t4}.formula,${t7}.abbr as program_abbr";
$data_select = "${data_select},${t2}.value as value";
$data_select = "${data_select},${t2}.unc,${t2}.flag,${t2}.inst";
$data_select = "${data_select},${t2}.date as adate,${t2}.time as atime";
$data_select = "${data_select},${t2}.comment as acomment";
if ($showtags) {
    $data_select .= ", dt.tags as measurement_tags";
}else{#Need a place holder
   $data_select .= ",'' as measurement_tags";
}

#print "BINNING: $binby_event\n";
#
#######################################
# Determine if query strategy is
# 1) get event then data
# or
# 2) get data then event
#######################################
#
if ($binby_event) { GetEventThenData(); }
else { GetDataThenEvent(); }

#
#######################################
# Do we need to get ws, wd, temp, press, rh data? 
#######################################
#
if ( $#parameterprogram_nums >= 0 )
{
   foreach $parameterprogram_num ( @parameterprogram_nums )
   {
      %tmphash = &nvpair_split($parameterprogram_num);

      $select = " SELECT DISTINCT ${t2}.date, ${t2}.time";
      $from = " FROM ${tt_data}, ${from_flask_data}";
      $where = " WHERE ${t2}.parameter_num='".$tmphash{parameter_num}."'";
      $where = $where." AND ${t2}.program_num='".$tmphash{program_num}."'";
      $and = " AND ${tt_data}.event_num = ${t2}.event_num";
      $order = " ORDER BY date DESC, time DESC";

      $sql = $select.$from.$where.$and.$order;

      $sth = $dbh->prepare($sql);
      $sth->execute();
      @tmp = $sth->fetchrow_array();
      $sth->finish();

      if ( $tmp[0] eq "0000-00-00" && $tmp[1] eq "00:00:00" )
      {
         GetParameterData($tmphash{parameter_num}, $tmphash{program_num});
      }
   }
   #
   #######################################
   # Get only unique entries from $tt_data
   #######################################
   #
   DistinctTable($tt_data);
}

#
#######################################
# Other data processing options
#######################################
#
if ( $exclusion ) { DataExclusion(); }

if ( $preliminary ) { FlagPreliminary(); }

if ( $option )
{
   #
   # Merging
   #
   Average();
   MergeData();
   $tt_outdata = $tt_merge;
}
elsif ( $pairaverage )
{
   #
   # Pair Averaging
   #
   PairAverage();
   $tt_outdata = $tt_avg;
}
else
{
   $tt_outdata = $tt_data;
}

#
#######################################
# Determine the correct output format
#######################################
#
if ( $#parameterprogram_nums >= 0 )
{
   if ( $pairaverage ) { $func = \&pairavgformat; }
   elsif ( $option )
   { $func = \&mergeformat; }
   else
   {
      if ( $oldstyle ) { $func = \&oldsiteformat; }
      else { $func = \&siteformat; }
   }
}
else
{
   if ( $oldstyle ) { $func = \&oldeventformat; }
   else { $func = \&eventformat; }
}


#
#######################################
# Build the output query
#######################################
#
#$create = "CREATE TABLE ${tt_output}";
$notable = 0;
if ( $#parameterprogram_nums >= 0 )
{
   if ( $pairaverage )
   {
      $select = " SELECT *";
      $from = " FROM ${tt_outdata}";
      #$order = " ORDER BY ${tt_outdata}.date, ${tt_outdata}.time";
      $order = " ORDER BY ${tt_outdata}.code, ${tt_outdata}.date, ${tt_outdata}.time";
      $sql = $select.$from.$order;

      if ( $debugmode ) { print $sql,"\n"; }
      $sth = $dbh->prepare($sql);
      $sth->execute();
   }
   else
   {
      $select = " SELECT *";
      $from = " FROM ${tt_event}, ${tt_outdata}";
      $where = " WHERE ${tt_event}.num = ${tt_outdata}.event_num";
      $order = " ORDER BY ${tt_event}.code, ${tt_event}.date, ${tt_event}.time, ${tt_event}.id";
      #$order = " ORDER BY ${tt_event}.date, ${tt_event}.time, ${tt_event}.code, ${tt_event}.id";
      $sql = $select.$from.$where.$order;

      if ( $debugmode ) { print $sql,"\n"; }
      $sth = $dbh->prepare($sql);
      $sth->execute();
   }
}
else
{
   #$sql = "SELECT * FROM ${tt_event} ORDER BY date, time, code";
   $sql = " SELECT * FROM ${tt_event} ORDER BY code, date, time";

   if ( $debugmode ) { print $sql,"\n"; }
   $sth = $dbh->prepare($sql);
   $sth->execute();
}

#
# Fetch results
#
@result = (); $nresult = 0;
@datatmp = ();
while (@tmp = $sth->fetchrow_array())
{
   @result[$nresult++] = $func->('0',@tmp);

   # Store the array so that we can generate the field names correctly
   @datatmp = @tmp;
}
$sth->finish();

#
#######################################
# Write results
#######################################
#
if ($file) { $file = ">${file}"; }
elsif ($stdout) { $file = ">&STDOUT"; }
else { $file = "| vim -"; }
open(FILE,$file);

if ( $shownames )
{
   $fieldnames = $func->('1',@datatmp);
   print FILE "# ${fieldnames}\n";
}


foreach $str (@result) { print FILE "${str}\n"; }
close(FILE);
#
#######################################
# Disconnect from DB
#######################################
#
&disconnect_db($dbh);
#
#######################################
# Subroutines
#######################################
#
sub GetEventThenData
{
   if ( $debugmode ) { print "E2D\n"; }
   my $i;

   #
   #######################################
   # Get Event Information
   #######################################
   #
   $create = "CREATE TEMPORARY TABLE ${tt_event} (INDEX (num))";

   $orderby = "${t0}.code,${t1}.dd";

   $select = " SELECT DISTINCT ${ev_select}";

   if ( $#status >= 0 )
   { $from = " FROM ${t0},${from_flask_event},${t3}"; }
   else
   { $from = " FROM ${t0},${from_flask_event}"; }

   $where = " WHERE ${t0}.num=${t1}.site_num";

   for ($i=0,$or=''; $i<@status; $i++)
   { $or = ($or) ?  "${or} OR ${t3}.status_num='${status_num[$i]}'" : "${t0}.num=${t3}.site_num AND ${t1}.project_num = ${t3}.project_num AND ${t1}.strategy_num = ${t3}.strategy_num AND (${t3}.status_num='${status_num[$i]}'"; }
   $and = ($or) ? " AND ${or})" : "";

   if ($project_num)
   {
      $and = "${and} AND ${t1}.project_num='${project_num}'";
      if ($#status >= 0)
      { $and = "${and} AND ${t1}.project_num=${t3}.project_num"; }
   }

   for ($i=0; $i<@strategy_num; $i++)
   {
      if ( $i == 0 )
      {
         $and = "${and} AND ( ${t1}.strategy_num='${strategy_num[$i]}'";
      }
      else
      { $and = "${and} OR ${t1}.strategy_num='${strategy_num[$i]}'"; }

           if ($i == ($#strategy_num ))
      { $and = "${and} )"; }
   }
   #######################################
   # Bin By Event Details?
   #######################################
   #
   if ( $binby_event )
   {
      $and  = "${and} AND ".&BinByEvent($t1, $binby_event, "");
   }

   if ($#site == 0)
   {
      &get_bin_params($site[0], $project_abbr, *min, *max, *binby);
      if (!grep(/$binby/,@bin) && $binby ne '')
      { $and = "${and} AND ${t1}.${binby} >= ${min} AND ${t1}.${binby} <= ${max}"}
   }

   $orderby = " ORDER BY ${orderby}";

   if ( $option == 2 )
   {
      $from = "${from},${from_flask_data}";
      $and = "${and} AND $t1.num = $t2.event_num";

      if ( $#parameterprogram_nums >= 0 )
      {
         %tmphash = &nvpair_split($parameterprogram_nums[0]);
         $and = "${and} AND $t2.parameter_num = '".$tmphash{parameter_num}."'";
      }
   }
   $sql = $create.$select.$from.$where.$and.$orderby;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   #
   #######################################
   # Get Measurement Data?
   #######################################
   #
   if ( $#parameterprogram_nums >= 0 )
   {
      $nresult = 0;
      @result = ();

      $orderby = " ORDER BY ${tt_event}.code,${tt_event}.date";
      $orderby = "${orderby},${tt_event}.time,${tt_event}.id,${tt_event}.me";
      
      #
      # Remove temporary table
      #
      DropTable($tt_data);

      $create = "CREATE TEMPORARY TABLE ${tt_data} (INDEX (event_num))";
      $select = " SELECT ${data_select}";

      $from = " FROM ${tt_event},${from_flask_data},${t4},${t7}";
      $where = " WHERE ${tt_event}.num=${t2}.event_num AND ${t2}.parameter_num = ${t4}.num AND ${t2}.program_num = ${t7}.num";
      $and = '';
      #
      #######################################
      # Bin By Measurement Details?
      #######################################
      #
      $and = ($binby_data) ? "${and} AND ".&BinByData($t2, $binby_data, $not) : $and;

      foreach $parameterprogram_num ( @parameterprogram_nums )
      {
         %tmphash = &nvpair_split($parameterprogram_num, ':', '~\+~');

         push(@tmparr, "( ${t2}.parameter_num = '".$tmphash{parameter_num}."' AND ${t2}.program_num = '".$tmphash{program_num}."' )");
      }

      if ( $#tmparr >= 0 )
      { $and = $and." AND ( ".join(' OR ', @tmparr)." ) "; }

      $sql = $create.$select.$from.$where.$and;
      if ( $debugmode ) { print $sql."\n"; }

      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();

   }
}

sub GetDataThenEvent
{
   if ( $debugmode ) { print "D2E\n"; }
   my $i;

   #
   #######################################
   # Get Data Information
   #######################################
   #
   #
   # Initialize return variables
   #
   $nresult = 0;
   @result = ();
   
   #
   #######################################
   # Get Measurement Data?
   #######################################
   #
   $create = "CREATE TEMPORARY TABLE ${tt_data} (INDEX (event_num))";
   $select = " SELECT ${data_select}";
   $from = " FROM ${from_flask_data},${t4},${t7}";
   
   $where = ' WHERE 1=1';

   if ( $#parameterprogram_nums >= 0 )
   {
      #
      # If option 2 merging ( constrain on the first parameter passed )
      #    is specified, then query the flask_data table based on the 
      #    first parameter. Second, query the flask_event table with
      #    data list. Lastly, query the flask_data table for all
      #    parameters based on the event list.
      # Otherwise, query the flask_data table based on all parameters
      #
      if ( $option == 2 )
      {
         %tmphash = &nvpair_split($parameterprogram_nums[0], ':', '~\+~');

         $where = $where." AND ( ${t2}.parameter_num = '".$tmphash{parameter_num}."' AND ${t2}.program_num = '".$tmphash{program_num}."' )";
      }
      else
      {
         foreach $parameterprogram_num ( @parameterprogram_nums )
         {
            %tmphash = &nvpair_split($parameterprogram_num, ':', '~\+~');

            push(@tmparr, "( ${t2}.parameter_num = '".$tmphash{parameter_num}."' AND ${t2}.program_num = '".$tmphash{program_num}."' )");
         }

         if ( $#tmparr >= 0 )
         { $where = $where." AND ( ".join(' OR ', @tmparr)." ) "; }
      }
   }

   #
   #######################################
   # Bin By Measurement Details?
   #######################################
   #

   if ( $binby_data )
   {
      $where = $where . " AND " . &BinByData($t2, $binby_data, $not);
   }

   $and = " AND ${t2}.parameter_num = ${t4}.num";
   $and = $and." AND ${t2}.program_num = ${t7}.num";

   $orderby = " ORDER BY ${t2}.event_num, ${t4}.formula, ${t7}.abbr";

   $sql = $create.$select.$from.$where.$and.$orderby;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   #
   # Now get event details
   #
   $create = "CREATE TEMPORARY TABLE ${tt_event}";
   $select = " SELECT DISTINCT ${ev_select}";
   $from = " FROM ${t0},${from_flask_event},${tt_data}";

   $where = " WHERE ${t1}.num = ${tt_data}.event_num";
   $and = " AND ${t0}.num = ${t1}.site_num";

   if ($project_num)
   { $and = "${and} AND ${t1}.project_num='${project_num}'"; }

   for ($i=0; $i<@strategy_num; $i++)
   {
      if ( $i == 0 )
      {
         $and = "${and} AND ( ${t1}.strategy_num='${strategy_num[$i]}'";
      }
      else
      { $and = "${and} OR ${t1}.strategy_num='${strategy_num[$i]}'"; }

           if ($i == ($#strategy_num ))
      { $and = "${and} )"; }
      
   }
   $sql = $create.$select.$from.$where.$and;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   if ( $option == 2 )
   {
      #
      # Remove temporary table
      #
      DropTable($tt_data);

      #
      # Query the flask_data table for all parameters based on the event list
      #    created from the first parameter in the parameter list
      #
      $create = "CREATE TEMPORARY TABLE ${tt_data} (INDEX (event_num))";
      $select = " SELECT ${data_select}";

      $from = " FROM ${tt_event},${from_flask_data},${t4},${t7}";
      $where = " WHERE 1=1";
      $and = '';
      #
      #######################################
      # Bin By Measurement Details?
      #######################################
      #
      $and = ($binby_data) ? "${and} AND ".&BinByData($t2, $binby_data, $not) : $and;

      foreach $parameterprogram_num ( @parameterprogram_nums )
      {
         %tmphash = &nvpair_split($parameterprogram_num, ':', '~\+~');

         push(@tmparr, "( ${t2}.parameter_num = '".$tmphash{parameter_num}."' AND ${t2}.program_num = '".$tmphash{program_num}."' )");
      }

      if ( $#tmparr >= 0 )
      { $and = $and." AND ( ".join(' OR ', @tmparr)." ) "; }

      $and = $and." AND ${tt_event}.num=${t2}.event_num";
      $and = $and." AND ${t2}.parameter_num=${t4}.num";
      $and = $and." AND ${t2}.program_num=${t7}.num";

      $orderby = " ORDER BY ${t2}.event_num, ${t4}.formula, ${t7}.abbr";

      $sql = $create.$select.$from.$where.$and.$orderby;
      if ( $debugmode ) { print $sql."\n"; }

      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();
   }

}

sub GetParameterData
{
   #
   # This function exists because ws, wd, temp, press, and rh are unique
   #    parameters that need to be dealt with in a special manner. Since
   #    their analysis date and time are default, if the user constrains
   #    on analysis date and time then they will not be found. However,
   #    they need to be shown if requested because they are tied in with
   #    the event information. So, if the user requests one of these
   #    special parameters then find them and put them into $tt_data
   #

   my($parameter_num, $program_num) = @_;
   my $i;
   $tt_tmp = "z".int(10**8*rand());

   DropTable($tt_tmp);

   $create = "CREATE TEMPORARY TABLE ${tt_tmp} (INDEX (event_num))";
   $select = " SELECT ${data_select}";
   $from = " FROM ${tt_data}, ${from_flask_data}, ${t4}, ${t7}";
   $where = " WHERE ${t2}.parameter_num = '$parameter_num'";
   $where = $where." AND ${t2}.program_num = '$program_num'";
   $and = " AND ${tt_data}.event_num = ${t2}.event_num";
   $and = "${and} AND ${t2}.parameter_num = ${t4}.num";
   $and = $and." AND ${t2}.program_num = ${t7}.num";

   $sql = $create.$select.$from.$where.$and;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   $insert = " INSERT INTO ${tt_data}";
   $select = " SELECT * FROM ${tt_tmp}";

   $sql = $insert.$select;

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   $sql = " DROP TABLE ${tt_tmp}";
   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();
}

sub DistinctTable()
{
   local($t) = @_;
   $tt_tmp = "z".int(10**8*rand());

   $sql = "SHOW TABLES LIKE '${t}'";

   $sth = $dbh->prepare($sql);
   $sth->execute();
   @name = $sth->fetchrow_array();
   $sth->finish();

   DropTable($tt_tmp);
   $create = " CREATE TEMPORARY TABLE ${tt_tmp}";
   $select = " SELECT DISTINCT * FROM ${t}";

   $sql = $create.$select;

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   $sql = "DELETE FROM ${t}";

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   $sql = "INSERT INTO ${t} SELECT DISTINCT * FROM ${tt_tmp}";

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();
}

sub parserow
{
   local($type, @arr) = @_;
   my %aarr;
   my @ymd_s;
   my @ymd_a;
   my @hms_s;
   my @hms_a;

   if ( $type eq 'site' )
   {
      # Example data
      # 825 ALT 1985.440449011 1985-06-10 18:20:00 387-85 P 82.4500 -62.5200 205.00 comment 825 co2 CCGG 349.2200 .X. U3 1985-08-01 11:36:00 acomment

      $aarr{'evn'} = $arr[0];
      $aarr{'site'} = $arr[1];
      $aarr{'date'} = $arr[3];
      $aarr{'time'} = $arr[4];
      $aarr{'id'} = $arr[5];
      $aarr{'me'} = $arr[6];
      $aarr{'lat'} = $arr[7];
      $aarr{'lon'} = $arr[8];
      $aarr{'alt'} = $arr[9];
      $aarr{'elev'} = $arr[10];
      $aarr{'comment'} = $arr[11];
      $aarr{'intake_height'} = $arr[12];
      $aarr{'event_tags'} = $arr[13];
      #flask_data.event_num
      $aarr{'formula'} = $arr[15];
      $aarr{'program'} = $arr[16];
      $aarr{'value'} = $arr[17];
      $aarr{'unc'} = $arr[18];
      $aarr{'flag'} = $arr[19];
      $aarr{'inst'} = $arr[20];
      $aarr{'adate'} = $arr[21];
      $aarr{'atime'} = $arr[22];
      $aarr{'acomment'} = $arr[23];
      $aarr{'data_tags'} = $arr[24];

      @ymd_s = split(/-/,$aarr{'date'});
      $aarr{'yr'} = $ymd_s[0];
      $aarr{'mo'} = $ymd_s[1];
      $aarr{'dy'} = $ymd_s[2];
      @ymd_a = split(/-/,$aarr{'adate'});
      $aarr{'ayr'} = $ymd_a[0];
      $aarr{'amo'} = $ymd_a[1];
      $aarr{'ady'} = $ymd_a[2];
      @hms_s = split(/:/,$aarr{'time'});
      $aarr{'hr'} = $hms_s[0];
      $aarr{'mn'} = $hms_s[1];
      $aarr{'sc'} = $hms_s[2];
      @hms_a = split(/:/,$aarr{'atime'});
      $aarr{'ahr'} = $hms_a[0];
      $aarr{'amn'} = $hms_a[1];
      $aarr{'asc'} = $hms_a[2];

      $aarr{'dd'} = sprintf("%14.9f", &date2dec($aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'},$aarr{'sc'}));
      $aarr{'add'} = sprintf("%14.9f", &date2dec($aarr{'ayr'},$aarr{'amo'},$aarr{'ady'},$aarr{'ahr'},$aarr{'amn'},$aarr{'asc'}));
   }
   elsif ( $type eq 'pairavg' )
   {
      # Example data
      # ALT 1985-06-17 19:27:00 P co2 CCGG 350.455000000000 ...
      $aarr{'site'} = $arr[0];
      $aarr{'date'} = $arr[1];
      $aarr{'time'} = $arr[2];
      $aarr{'me'} = $arr[3];
      $aarr{'formula'} = $arr[4];
      $aarr{'program'} = $arr[5];
      $aarr{'value'} = $arr[6];
      $aarr{'flag'} = $arr[7];
      $aarr{'lat'} = $arr[8];
      $aarr{'lon'} = $arr[9];
      $aarr{'alt'} = $arr[10];

      @ymd_s = split(/-/,$aarr{'date'});
      $aarr{'yr'} = $ymd_s[0];
      $aarr{'mo'} = $ymd_s[1];
      $aarr{'dy'} = $ymd_s[2];
      @hms_s = split(/:/,$aarr{'time'});
      $aarr{'hr'} = $hms_s[0];
      $aarr{'mn'} = $hms_s[1];
      $aarr{'sc'} = $hms_s[2];

      $aarr{'dd'} = sprintf("%14.9f", &date2dec($aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'},$aarr{'sc'}));
   }
   elsif ( $type eq 'merge' )
   {
	#print join(", ",@arr);exit;

      # Example data
      # 825 ALT 1985.440449011 1985-06-10 18:20:00 387-85 P 82.4500 -62.5200 205.00  825 co2 CCGG 349.22000000 .X. ch4 CCGG -999.99000000 FIL
      $aarr{'evn'} = $arr[0];
      $aarr{'site'} = $arr[1];
      $aarr{'date'} = $arr[3];
      $aarr{'time'} = $arr[4];
      $aarr{'id'} = $arr[5];
      $aarr{'me'} = $arr[6];
      $aarr{'lat'} = $arr[7];
      $aarr{'lon'} = $arr[8];
      $aarr{'alt'} = $arr[9];
      $aarr{'elev'} = $arr[10];
      $aarr{'comment'} = $arr[11];
      $aarr{'intake_height'} = $arr[12];
      
      @tmparr = ();
	#Note, need to skip the cols for tags and ev num
      for ( $set=0; $set<($#arr-14)/4; $set++ )
      {
         $tmpaarr = {};

         $tmpaarr->{'formula'} = $arr[15+$set*4];
         $tmpaarr->{'program'} = $arr[16+$set*4];
         $tmpaarr->{'value'} = $arr[17+$set*4];
         $tmpaarr->{'flag'} = $arr[18+$set*4];

         push(@tmparr, $tmpaarr);
      }

      $aarr{'parameters'} = [ @tmparr ];

      @ymd_s = split(/-/,$aarr{'date'});
      $aarr{'yr'} = $ymd_s[0];
      $aarr{'mo'} = $ymd_s[1];
      $aarr{'dy'} = $ymd_s[2];
      @hms_s = split(/:/,$aarr{'time'});
      $aarr{'hr'} = $hms_s[0];
      $aarr{'mn'} = $hms_s[1];
      $aarr{'sc'} = $hms_s[2];
   }
   elsif ( $type eq 'event' )
   {
      # Example data
      # 24784 BMW 1989.358476027 1989-05-11 20:15:00 555-81 P 32.2700 -64.8800 30.00 
      $aarr{'evn'} = $arr[0];
      $aarr{'site'} = $arr[1];
      $aarr{'date'} = $arr[3];
      $aarr{'time'} = $arr[4];
      $aarr{'id'} = $arr[5];
      $aarr{'me'} = $arr[6];
      $aarr{'lat'} = $arr[7];
      $aarr{'lon'} = $arr[8];
      $aarr{'alt'} = $arr[9];
      $aarr{'elev'} = $arr[10];
      $aarr{'comment'} = $arr[11];
      $aarr{'intake_height'} = $arr[12];
      $aarr{'event_tags'} = $arr[13];
      
      @ymd_s = split(/-/,$aarr{'date'});
      $aarr{'yr'} = $ymd_s[0];
      $aarr{'mo'} = $ymd_s[1];
      $aarr{'dy'} = $ymd_s[2];
      @hms_s = split(/:/,$aarr{'time'});
      $aarr{'hr'} = $hms_s[0];
      $aarr{'mn'} = $hms_s[1];
      $aarr{'sc'} = $hms_s[2];

      $aarr{'dd'} = sprintf("%14.9f", &date2dec($aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'},$aarr{'sc'}));
   }

   return %aarr;
}

sub pairavgformat
{
   local($fnflag,@arr) = @_;

   # If $fnflag is specifed, then only return the field names

   # %outopts is a global variable
   my $line;
   my @formatarr = ();
   my @valuearr = ();
   my @fnames = ();
   my $formatstr;
   my %aarr;

   %aarr = &parserow('pairavg', @arr);

   # site yr mo dy hr mn me formula program_abbr value flag
   #$format = "%s %4.4d %2.2d %2.2d %2.2d %2.2d %1s %8s %10.4f %3s";
   #$line = sprintf($format,uc($arr[0]),$ymd_s[0],$ymd_s[1],$ymd_s[2],
   #      $hms_s[0],$hms_s[1],$arr[3],$arr[4],$arr[5],$arr[6], $arr[7]);

   if ( $outopts{'abbr'} )
   {
      if ( $fnflag ) { push(@fnames,'sample_decimal_date','analysis_value'); }
      else
      {
         push(@formatarr,'%12.9f','%10.4f');
         push(@valuearr,$aarr{'dd'},$aarr{'analysis_value'});
      }
   }
   else
   {
      if ( $fnflag ) { push(@fnames,'sample_site_code','sample_year','sample_month','sample_day','hour','sample_minute'); }
      else
      {
         push(@formatarr,'%s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,uc($aarr{'site'}),$aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'sample_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'sc'});
         }
      }

      if ( $fnflag ) { push(@fnames,'sample_method','parameter_formula'); }
      {
         push(@formatarr,'%1s','%8s');
         push(@valuearr,$aarr{'me'},$aarr{'formula'});
      }

      if ( ! $outopts{'noprogram'} )
      {
         if ( $fnflag ) { push(@fnames,'analysis_group_abbr'); }
         {
            push(@formatarr,'%8s');
            push(@valuearr,$aarr{'program'});
         }
      }

      if ( $fnflag ) { push(@fnames,'analysis_value','analysis_flag'); }
      {
         push(@formatarr,'%10.4f','%3s');
         push(@valuearr,$aarr{'value'},$aarr{'flag'});
      }
   }

   if ( $fnflag ) { push(@fnames,'sample_latitude','sample_longitude','sample_altitude'); }
   else
   {
      push(@formatarr,'%8.4f','%9.4f','%8.2f');
      push(@valuearr,$aarr{'lat'},$aarr{'lon'},$aarr{'alt'});
   }

   if ( $fnflag ) { $line = join(" ", @fnames); }
   else
   {
      $formatstr = join(" ",@formatarr);
      $line = sprintf($formatstr, @valuearr);
   }

   return $line;
}

sub oldsiteformat
{
   local($fnflag,@arr) = @_;

   # %outopts is a global variable
   my $line;
   my @fnames = ();
   my @formatarr = ();
   my @valuearr = ();
   my %aarr;
   my $formatstr;
   my $commentstr;

   %aarr = &parserow('site', @arr);

   if ( $outopts{'abbr'} )
   {
      if ( $fnflag ) { push(@fnames,'sample_decimal_date','analysis_value'); }
      else
      {
         push(@formatarr,'%12.9f','%9.3f');
         push(@valuearr,$aarr{'dd'},$aarr{'value'});
      }
   }
   else
   {

      if ( $fnflag ) { push(@fnames,'sample_site_code','sample_year','sample_month','sample_day','sample_hour','sample_minute'); }
      else
      {
         push(@formatarr,'%s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,uc($aarr{'site'}),$aarr{'yr'}, $aarr{'mo'}, $aarr{'dy'}, $aarr{'hr'}, $aarr{'mn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'sample_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'sc'});
         }
      }


      if ( $fnflag )
      {
         push(@fnames,'sample_id','sample_method');

         if ( $#param > 0 )
         { push(@fnames,'analysis_value','analysis_flag'); }
         else
         { push(@fnames,lc($param[0]).'_analysis_value',lc($param[0]).'_analysis_flag'); }

         push(@fnames,'analysis_instrument','analysis_year','analysis_month','analysis_day','analysis_hour','analysis_minute');
      }
      else
      {
         push(@formatarr,'%8s','%1s','%8.3f','%3s','%3s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,$aarr{'id'},$aarr{'me'},$aarr{'value'},$aarr{'flag'},$aarr{'inst'},$aarr{'ayr'},$aarr{'amo'},$aarr{'ady'},$aarr{'ahr'},$aarr{'amn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'analysis_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'asc'});
         } 
      }

      # Add comments, if requested
      if ( $outopts{'comment'} )
      {
         if ( $fnflag ) { push (@fnames, 'comment'); }
         else
         {
            $commentstr = '';
            if ($aarr{'comment'} ne "") { $commentstr = $commentstr.' sample|'.$aarr{'comment'}; }
            if ($aarr{'acomment'} ne "") { $commentstr = $commentstr.' analysis|'.$aarr{'acomment'}; }

            push(@formatarr,'%s');
            push(@valuearr,$commentstr);
         }
      }
   }

   if ( $fnflag ) { $line = join(" ", @fnames); }
   else
   {
      $formatstr = join(" ",@formatarr);
      $line = sprintf($formatstr, @valuearr);
   }

   return $line;
}

sub siteformat
{
   local($fnflag,@arr) = @_;

   # %outopts is a global variable
   my $line;
   my @formatarr = ();
   my @valuearr = ();
   my @fnames = ();
   my %aarr;
   my $formatstr;
   my $commentstr;

   %aarr = &parserow('site', @arr);

   if ( $outopts{'abbr'} )
   {
      if ( $fnflag ) { push(@fnames,'sample_decimal_date','analysis_value','sample_latitude','sample_longitude','sample_altitude','event_number'); }
      else
      {
         push(@formatarr,'%12.9f','%9.3f','%8.4f','%9.4f','%8.2f','%8d');
         push(@valuearr,$aarr{'dd'},$aarr{'value'},$aarr{'lat'},$aarr{'lon'},$aarr{'alt'},$aarr{'evn'});
      }
   }
   else
   {

      if ( $fnflag ) { push(@fnames,'sample_site_code','sample_year','sample_month','sample_day','sample_hour','sample_minute'); }
      else
      {
         push(@formatarr,'%s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,uc($aarr{'site'}),$aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'sample_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'sc'});
         }
      }


      if ( $fnflag ) { push(@fnames,'sample_id','sample_method','parameter_formula'); }
      else
      {
         push(@formatarr,'%8s','%1s','%8s');
         push(@valuearr,$aarr{'id'},$aarr{'me'},$aarr{'formula'});
      }

      if ( ! $outopts{'noprogram'} )
      {
         if ( $fnflag ) { push(@fnames,'analysis_group_abbr'); }
         else
         {
            push(@formatarr,'%8s');
            push(@valuearr,$aarr{'program'});
         }
      }

      if ( $fnflag ) { push(@fnames,'analysis_value'); }
      else
      {
         push(@formatarr,'%9.3f');
         push(@valuearr,$aarr{'value'});
      }

      # Remove uncertainty, if requested
      if ( ! $outopts{'nouncertainty'} )
      {
         if ( $fnflag ) { push(@fnames,'analysis_uncertainty'); }
         else
         {
            push(@formatarr,'%9.3f');
            push(@valuearr,$aarr{'unc'});
         }
      }

      if ( $fnflag ) { push(@fnames,'analysis_flag','analysis_instrument','analysis_year','analysis_month','analysis_day','analysis_hour','analysis_minute'); }
      else
      {
         push(@formatarr,'%3s','%3s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,$aarr{'flag'},$aarr{'inst'},$aarr{'ayr'},$aarr{'amo'},$aarr{'ady'},$aarr{'ahr'},$aarr{'amn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'analysis_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'asc'});
         }
      }

      if ( $fnflag ) { push(@fnames,'sample_latitude','sample_longitude','sample_altitude'); }
      else
      {
         push(@formatarr,'%8.4f','%9.4f','%8.2f');
         push(@valuearr,$aarr{'lat'},$aarr{'lon'},$aarr{'alt'});
      }

      # Add elevation, if requested
      if ( $outopts{'elevation'} )
      {
         if ( $fnflag ) { push (@fnames, 'sample_elevation'); }
         else
         {
            push(@formatarr,'%8.2f');
            push(@valuearr,$aarr{'elev'});
         }
      }
      
      # Add intake_height, if requested
      if ( $outopts{'intake_height'} )
      {
         if ( $fnflag ) { push (@fnames, 'sample_intake_height'); }
         else
         {
            push(@formatarr,'%8.2f');
            push(@valuearr,$aarr{'intake_height'});
         }
      }
      
      if ( $fnflag ) { push(@fnames,'event_number'); }
      else
      {
         push(@formatarr,'%8d');
         push(@valuearr,$aarr{'evn'});
      }

      # Add comments, if requested
      if ( $outopts{'comment'} )
      {
         if ( $fnflag ) { push (@fnames, 'comment'); }
         else
         {
            $commentstr = '';
            if ($aarr{'comment'} ne "") { $commentstr = $commentstr.' sample|'.$aarr{'comment'}; }
            if ($aarr{'acomment'} ne "") { $commentstr = $commentstr.' analysis|'.$aarr{'acomment'}; }

            push(@formatarr,'%s');
            push(@valuearr,$commentstr);
         }
      }
      #add tags if requested
      if ($outopts{'showtags'}) {
        if ( $fnflag ) { push (@fnames, 'tags'); }
         else
         {
            $tagstr = '';
            if ($aarr{'event_tags'} ne "") { $tagstr .= $aarr{'event_tags'}; }
            if ($aarr{'data_tags'} ne "") {
               if($tagstr){$tagstr.=$tagdelim;}
               $tagstr .= $aarr{'data_tags'};
            }

            push(@formatarr,'%s');
            push(@valuearr,$tagstr);
         }
      }
      
   }

   if ( $fnflag ) { $line = join(" ", @fnames); }
   else
   {
      $formatstr = join(" ",@formatarr);
      $line = sprintf($formatstr, @valuearr);
   }

   return $line;
}

sub mergeformat
{
   local($fnflag,@arr) = @_;

   # %outopts is a global variable
   my $line;
   my @formatarr = ();
   my @valuearr = ();
   my @fnames = ();
   my %aarr;
   my $formatstr;
   my $commentstr;
   my $offset;

   %aarr = &parserow('merge', @arr);

   if ( $fnflag ) { push(@fnames,'sample_site_code','sample_year','sample_month','sample_day','sample_hour','sample_minute'); }
   else
   {
      push(@formatarr,'%s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
      push(@valuearr,uc($aarr{'site'}),$aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'});
   }

   # Remove seconds, if requested
   if ( ! $outopts{'noseconds'} )
   {
      if ( $fnflag ) { push(@fnames,'sample_seconds'); }
      else
      {
         push(@formatarr,'%2.2d');
         push(@valuearr,$aarr{'sc'});
      }
   }

   if ( $fnflag ) { push(@fnames,'sample_id','sample_method','sample_latitude','sample_longitude','sample_altitude'); }
   else
   {
      push(@formatarr,'%8s','%1s','%8.4f','%9.4f','%8.2f');
      push(@valuearr,$aarr{'id'},$aarr{'me'},$aarr{'lat'},$aarr{'lon'},$aarr{'alt'});
   }

   # Add elevation, if requested
   if ( $outopts{'elevation'} )
   {
      if ( $fnflag ) { push (@fnames, 'sample_elevation'); }
      else
      {
         push(@formatarr,'%8.2f');
         push(@valuearr,$aarr{'elev'});
      }
   }

   # Add intake_height, if requested
   if ( $outopts{'intake_height'} )
   {
      if ( $fnflag ) { push (@fnames, 'sample_intake_height'); }
      else
      {
         push(@formatarr,'%8.2f');
         push(@valuearr,$aarr{'intake_height'});
      }
   }
   
   if ( $fnflag ) { push(@fnames,'event_number'); }
   else
   {
      push(@formatarr,'%8d');
      push(@valuearr,$aarr{'evn'});
   }

   if ( ! $outopts{'noprogram'} )
   {
      $maxi = scalar @{ $aarr{'parameters'} };
      for ( $i = 0; $i < $maxi; $i++ )
      {
         if ( $fnflag )
         { push(@fnames,'parameter_formula','analysis_group_abbr','analysis_value','analysis_flag'); }
         else
         {
            push(@formatarr,'%8s','%8s','%9.3f','%3s');
            push(@valuearr,$aarr{'parameters'}->[$i]->{'formula'},$aarr{'parameters'}->[$i]->{'program'},$aarr{'parameters'}->[$i]->{'value'},$aarr{'parameters'}->[$i]->{'flag'});
         }
      }
   }
   else
   {
      $maxi = scalar @{ $aarr{'parameters'} };
      for ( $i = 0; $i < $maxi; $i++ )
      {
         if ( $fnflag )
         { push(@fnames,'parameter_formula','analysis_value','analysis_flag'); }
         else
         {
            push(@formatarr,'%8s','%9.3f','%3s');
            push(@valuearr,$aarr{'parameters'}->[$i]->{'formula'},$aarr{'parameters'}->[$i]->{'value'},$aarr{'parameters'}->[$i]->{'flag'});
         }
      }
   }

   # Add comments, if requested
   if ( $outopts{'comment'} )
   {
      if ( $fnflag ) { push (@fnames, 'comment'); }
      else
      {
         $commentstr = '';
         if ($aarr{'comment'} ne "") { $commentstr = $commentstr.' sample|'.$aarr{'comment'}; }

         push(@formatarr,'%s');
         push(@valuearr,$commentstr);
      }
   }

   if ( $fnflag ) { $line = join(" ", @fnames); }
   else
   {
      $formatstr = join(" ",@formatarr);
      $line = sprintf($formatstr, @valuearr);
   }

   return $line;
}

sub eventformat
{
   local($fnflag,@arr) = @_;

   # %outopts is a global variable
   my $line;
   my @formatarr = ();
   my @valuearr = ();
   my @fnames = ();
   my %dataaarr;
   my $formatstr;
   my $commentstr;

   %aarr = &parserow('event', @arr);

   if ( $outopts{'abbr'} )
   {
      if ( $fnflag ) { push(@fnames,'sample_decimal_date','sample_latitude','sample_longitude','sample_altitude','event_number'); }
      else
      {
         push(@formatarr,'%12.9f','%8.4f','%9.4f','%8.2f','%8d');
         push(@valuearr,$aarr{'dd'},$aarr{'lat'},$aarr{'lon'},$aarr{'alt'},$aarr{'evn'});
      }
   }
   else
   {

      if ( $fnflag ) { push(@fnames,'sample_site_code','sample_year','sample_month','sample_day','sample_hour','sample_minute'); }
      else
      {
         push(@formatarr,'%s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,uc($aarr{'site'}),$aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'sample_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'sc'});
         }
      }

      if ( $fnflag ) { push(@fnames,'sample_id','sample_method','sample_latitude','sample_longitude','sample_altitude'); }
      else
      {
         push(@formatarr,'%8s','%1s','%8.4f','%9.4f','%8.2f');
         push(@valuearr,$aarr{'id'},$aarr{'me'},$aarr{'lat'},$aarr{'lon'},$aarr{'alt'});
      }

      # Add elevation, if requested
      if ( $outopts{'elevation'} )
      {
         if ( $fnflag ) { push (@fnames, 'sample_elevation'); }
         else
         {
            push(@formatarr,'%8.2f');
            push(@valuearr,$aarr{'elev'});
         }
      }

      # Add intake_height, if requested
      if ( $outopts{'intake_height'} )
      {
         if ( $fnflag ) { push (@fnames, 'sample_intake_height'); }
         else
         {
            push(@formatarr,'%8.2f');
            push(@valuearr,$aarr{'intake_height'});
         }
      }
      
      if ( $fnflag ) { push(@fnames,'event_number'); }
      else
      {
         push(@formatarr,'%8d');
         push(@valuearr,$aarr{'evn'});
      }

      # Add comments, if requested
      if ( $outopts{'comment'} )
      {
         if ( $fnflag ) { push (@fnames, 'comment'); }
         else
         {
            $commentstr = '';
            if ($aarr{'comment'} ne "") { $commentstr = $commentstr.' sample|'.$aarr{'comment'}; }

            push(@formatarr,'%s');
            push(@valuearr,$commentstr);
         }
      }
      #add tags if requested
      if ($outopts{'showtags'}) {
        if ( $fnflag ) { push (@fnames, 'tags'); }
         else
         {
            $tagstr = '';
            if ($aarr{'event_tags'} ne "") { $tagstr .= $aarr{'event_tags'}; }
            
            push(@formatarr,'%s');
            push(@valuearr,$tagstr);
         }
      }
   }

   if ( $fnflag ) { $line = join(" ", @fnames); }
   else
   {
      $formatstr = join(" ",@formatarr);
      $line = sprintf($formatstr, @valuearr);
   }

   return $line;
}

sub oldeventformat
{
   local($fnflag,@arr) = @_;

   # %outopts is a global variable
   my $line;
   my @formatarr = ();
   my @valuearr = ();
   my @fnames = ();
   my %aarr;
   my $formatstr;
   my $commentstr;

   %aarr = &parserow('event', @arr);

   if ( $outopts{'abbr'} )
   {
      if ( $fnflag ) { push(@fnames,'sample_decimal_date','sample_latitude','sample_longitude','sample_altitude'); }
      else
      {
         push(@formatarr,'%12.9f','%6.2f','%7.2f','%6d');
         push(@valuearr,$aarr{'dd'},$aarr{'lat'},$aarr{'lon'},$aarr{'alt'});
      }
   }
   else
   {

      if ( $fnflag ) { push(@fnames,'sample_site_code','sample_year','sample_month','sample_day','sample_hour','sample_minute'); }
      else
      {
         push(@formatarr,'%s','%4.4d','%2.2d','%2.2d','%2.2d','%2.2d');
         push(@valuearr,uc($aarr{'site'}),$aarr{'yr'},$aarr{'mo'},$aarr{'dy'},$aarr{'hr'},$aarr{'mn'});
      }

      # Remove seconds, if requested
      if ( ! $outopts{'noseconds'} )
      {
         if ( $fnflag ) { push(@fnames,'sample_seconds'); }
         else
         {
            push(@formatarr,'%2.2d');
            push(@valuearr,$aarr{'sc'});
         }
      }


      if ( $fnflag ) { push(@fnames,'sample_id','sample_method','sample_latitude','sample_longitude','sample_altitude'); }
      else
      {
         push(@formatarr,'%8s','%1s','%6.2f','%7.2f','%6d');
         push(@valuearr,$aarr{'id'},$aarr{'me'},$aarr{'lat'},$aarr{'lon'},$aarr{'alt'});
      }

      # Add comments, if requested
      if ( $outopts{'comment'} )
      {
         if ( $fnflag ) { push (@fnames, 'comment'); }
         else
         {
            $commentstr = '';
            if ($aarr{'comment'} ne "") { $commentstr = $commentstr.' sample|'.$aarr{'comment'}; }

            push(@formatarr,'%s');
            push(@valuearr,$commentstr);
         }
      }
   }

   if ( $fnflag ) { $line = join(" ", @fnames); }
   else
   {
      $formatstr = join(" ",@formatarr);
      $line = sprintf($formatstr, @valuearr);
   }

   return $line;
}

sub PairAverage()
{
   $tt_tmp = "z".int(10**8*rand());

   $pflag = "..%";

   #
   # Find join the event and data table
   #
   $create = "CREATE TEMPORARY TABLE ${tt_tmp} ( INDEX(code, date, time, me, formula, lat, lon, alt, program_abbr) )";
   $select = " SELECT ${tt_event}.code, ${tt_event}.date, ${tt_event}.time, ${tt_event}.me, ${tt_event}.id, ${tt_data}.formula, ${tt_data}.program_abbr, avg(${tt_data}.value) as value, ${tt_data}.flag, ${tt_event}.lon, ${tt_event}.lat, ${tt_event}.alt";
   $from = " FROM ${tt_event},${tt_data}";
   $where = " WHERE ${tt_data}.flag LIKE '$pflag' AND ${tt_event}.num = ${tt_data}.event_num";
   $group = " GROUP BY ${tt_event}.code, ${tt_event}.date, ${tt_event}.time, ${tt_event}.me, ${tt_data}.formula, ${tt_data}.program_abbr, ${tt_event}.id, ${tt_event}.lon, ${tt_event}.lat, ${tt_event}.alt";

   $sql = $create.$select.$from.$where.$group;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();
   
   $create = "CREATE TEMPORARY TABLE ${tt_avg} ( INDEX(code, date, time, me, formula, program_abbr) )";
   $select = " SELECT code, date, time, me, formula, program_abbr, avg(value) as value, flag, lat, lon, alt";
   $from = " FROM ${tt_tmp}";
   $group = " GROUP BY code, date, time, me, formula, program_abbr, lat, lon, alt";

   $sql = $create.$select.$from.$group;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();
}

sub Average()
{
   $tt_tmp = "z".int(10**8*rand());
   
   #
   # Create a column named 'average' in the temporary tables, which is the
   #    average of the values grouped by event number, formula, and program
   #

   #
   # Find all the data with flag like ..%
   #
   $create = "CREATE TEMPORARY TABLE ${tt_avg} ( INDEX(event_num) )";
   $select = " SELECT *, avg(value) as average";
   $from = " FROM ${tt_data}";
   $where = " WHERE flag LIKE '..%'";
   $group = " GROUP BY event_num, formula, program_abbr";

   $sql = $create.$select.$from.$where.$group;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   #
   # Find all the data with a flag like .% but the event number does not
   #    already exist in the output average table
   #
   $create = "CREATE TEMPORARY TABLE ${tt_tmp} ( INDEX(event_num) )";
   $select = " SELECT ${tt_data}.*, AVG(${tt_data}.value) as average";
   $from = " FROM ${tt_data} LEFT JOIN ${tt_avg} ON (${tt_data}.event_num = ${tt_avg}.event_num AND ${tt_data}.formula = ${tt_avg}.formula )";
   $where = " WHERE ${tt_data}.flag LIKE '.%' AND ${tt_avg}.event_num IS NULL";
   $group = " GROUP BY ${tt_data}.event_num, ${tt_data}.formula, ${tt_data}.program_abbr";

   $sql = $create.$select.$from.$where.$group;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   $sql = "INSERT INTO ${tt_avg} SELECT * FROM ${tt_tmp}";
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   DropTable($tt_tmp);

   #
   # Get the rest of the event numbers that do not already exist in the
   #    output average table
   #
   $create = "CREATE TEMPORARY TABLE ${tt_tmp} ( INDEX(event_num) )";
   $select = " SELECT ${tt_data}.*, MAX(${tt_data}.value) as average";
   $from = " FROM ${tt_data} LEFT JOIN ${tt_avg} ON (${tt_data}.event_num = ${tt_avg}.event_num AND ${tt_data}.formula = ${tt_avg}.formula )";
   $where = " WHERE ${tt_data}.flag LIKE '%' AND ${tt_avg}.event_num IS NULL";
   $group = " GROUP BY ${tt_data}.event_num, ${tt_data}.formula, ${tt_data}.program_abbr";

   $sql = $create.$select.$from.$where.$group;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   $sql = "INSERT INTO ${tt_avg} SELECT * FROM ${tt_tmp}";
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();

   DropTable($tt_tmp);
}

sub FlagPreliminary()
{
   #
   # Chnage the comment field in the QC flag to P if the data are considered
   #   preliminary.
   
   #3/17-jwm.  Updated to use tagging logic.  Note I'd like to convert all to use releaseeable_flask_data_view, but it's slow (mysql version issues with view optimaztion).
   #
   $select = "SELECT DISTINCT site_num, project_num, strategy_num, gmd.program.num";
   $select = $select.", gmd.parameter.num";
   $from = " FROM flask_event, ${tt_data}, gmd.parameter, gmd.program";
   $where = " WHERE flask_event.num = ${tt_data}.event_num";
   $and = " AND ${tt_data}.formula = gmd.parameter.formula";
   $and = $and." AND ${tt_data}.program_abbr = gmd.program.abbr";
   #Exclude HATS data from this query as they are handled below.  We'll just hard code for now because only hats uses the prelim tags, but as soon as another group
   #starts using it, we should program a way to get this programmatically.
   #jwm - 2/6/18
   #jwm -20221215 - adding hats back in as a temp workaround.  we are publishing perseus data and isaac wants all to be marked prelim, so using this instead of adding massive tag for all hats data.  Once he's comfortable, we'll revert to his normal tag system.
   #$and = $and." and gmd.program.num!=8 ";
   
   $sql = $select.$from.$where.$and;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();

   my @data_arr = (); my $ndata_arr = 0;
   while (@tmp = $sth->fetchrow_array()) { @data_arr[$ndata_arr++] = join('~+~', @tmp) }
   $sth->finish();

   foreach $line ( @data_arr )
   {
      ($site_num, $project_num, $strategy_num, $program_num, $parameter_num) = split(/\~\+\~/, $line);

      if ( $debugmode )
      { print "$site_num, $project_num, $strategy_num, $program_num, $parameter_num\n"; }

      $where = &DataRelease($site_num, $project_num, $strategy_num, $program_num, $parameter_num, 'P');

      $where = ( $where eq "" ) ? "" : "${where} )";

      if ( $where ne "" )
      {
         $update = " UPDATE flask_event, ${tt_data}, gmd.parameter, gmd.program";
         $set = " SET ${tt_data}.flag = CONCAT(SUBSTRING(flag,1,2),'P')";
         $and = " AND flask_event.site_num = ?";
         $and = $and." AND flask_event.project_num = ?";
         $and = $and." AND flask_event.strategy_num = ?";
         $and = $and." AND gmd.program.num = ?";
         $and = $and." AND gmd.parameter.num = ?";
         $and = $and." AND flask_event.num = ${tt_data}.event_num";
         $and = $and." AND gmd.parameter.formula = ${tt_data}.formula";
         $and = $and." AND gmd.program.abbr = ${tt_data}.program_abbr";

         $sql = $update.$set.$where.$and;
         @sqlargs = ($site_num,$project_num,$strategy_num,$program_num,$parameter_num);

         if ( $debugmode )
         {
             print $sql."\n";
             print join('|', @sqlargs)."\n";
         }

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);
         $sth->finish();
         
                 
      }
   }
   
   #JWM 9/15
   #Also update Ben Miller's HATS data if the flag is set appropriately.  
   #my $sql="update ${tt_data} set flag = CONCAT(SUBSTRING(flag,1,2),'P')
   #         where upper(program_abbr) like 'HATS' and flag like '%0' ";
   
   #jwm-3/17 - updating to tags logic. Slightly annoying join because there's no data_num in the temp table at this point.
      #Not willing to figure out if it's safe to add one in though, so we'll just join through flask_data_view.
      #Note this used to be hats specific, but we will now use tag logic generically to support any program(need to update above query though).
      ##Note update is documented to work on multiple matches, but Havent tested that (not expected)
      ##Note; silly time comparison is to get around an apparent optimizer bug with 00:00:00 times
   #jwm 2/18 - this whole procedure (and excl below) should be rewritten to use releaseable_flask_data_view.  I was in process of changing this to use ccg_flask2.pl (which
   #does use it) but got delayed.
   $sql="update ${tt_data} t join flask_data_view v on
                  (t.program_abbr=v.program and t.event_num=v.event_num and t.formula=v.parameter
                     and t.adate=v.a_date and ((t.atime='00:00:00' and v.a_time='00:00:00') or t.atime=v.a_time) and t.inst=v.inst)
               join flask_data_tag_view d on d.data_num=v.data_num
            set t.flag = CONCAT(SUBSTRING(t.flag,1,2),'P')
            where d.prelim_data=1";
   $dbh->do($sql);
   #To be complete, do similar for event tags although we don't currently support prelim event tags
   $sql="update ${tt_data} t join flask_event_tag_view e on t.event_num=e.event_num
            set t.flag = CONCAT(SUBSTRING(t.flag,1,2),'P')
            where e.prelim_data=1";
   $dbh->do($sql);
   
   
}

sub DataExclusion()
{
   #
   # Change all of data values and the QC flags for exclusion data.
   #3/17-jwm.  Updated to use tagging logic.  Note I'd like to convert all to use releaseeable_flask_data_view, but it's slow (mysql version issues with view optimaztion).
   #
   $select = "SELECT DISTINCT site_num, project_num, strategy_num, gmd.program.num";
   $select = $select.", gmd.parameter.num";
   $from = " FROM flask_event, ${tt_data}, gmd.parameter, gmd.program";
   $where = " WHERE flask_event.num = ${tt_data}.event_num";
   $and = " AND ${tt_data}.formula = gmd.parameter.formula";
   $and = $and." AND ${tt_data}.program_abbr = gmd.program.abbr";
   #Exclude HATS data from this query as they are handled below.  We'll just hard code for now because only hats uses the prelim tags, but as soon as another group
   #starts using it, we should program a way to get this programmatically.
   #jwm - 2/6/18
   $and = $and." and gmd.program.num!=8 ";

   $sql = $select.$from.$where.$and;
   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();

   my @data_arr = (); my $ndata_arr = 0;
   while (@tmp = $sth->fetchrow_array()) { @data_arr[$ndata_arr++] = join('~+~', @tmp) }
   $sth->finish();

   foreach $line ( @data_arr )
   {
      ($site_num, $project_num, $strategy_num, $program_num, $parameter_num) = split(/\~\+\~/, $line);

      if ( $debugmode )
      { print "$site_num, $project_num, $strategy_num, $program_num, $parameter_num\n"; }

      $where = &DataRelease($site_num, $project_num, $strategy_num, $program_num, $parameter_num, 'E');

      $where = ( $where eq "" ) ? "" : "${where} )";

      if ( $where ne "" )
      {
         $delete = " DELETE ${tt_data}";
         $from = " FROM flask_event, ${tt_data}, gmd.parameter, gmd.program";
         $and = " AND flask_event.site_num = ?";
         $and = $and." AND flask_event.project_num = ?";
         $and = $and." AND flask_event.strategy_num = ?";
         $and = $and." AND gmd.program.num = ?";
         $and = $and." AND gmd.parameter.num = ?";
         $and = $and." AND flask_event.num = ${tt_data}.event_num";
         $and = $and." AND gmd.parameter.formula = ${tt_data}.formula";
         $and = $and." AND gmd.program.abbr = ${tt_data}.program_abbr";

         $sql = $delete.$from.$where.$and;
         @sqlargs = ($site_num,$project_num,$strategy_num,$program_num,$parameter_num);

         if ( $debugmode )
         {
            print $sql."\n";
            print join('|', @sqlargs)."\n";
         }

         $sth = $dbh->prepare($sql);
         $sth->execute(@sqlargs);
         $sth->finish();
      }
   }

   #
   # This is temporary code.
   # This removes any analysis done marked by Ben Miller
   # as data to be excluded
   # Updated 9/15 to remove check for %0 flagged data.  That is now considered preliminary instead of excluded data.
   #$delete = " DELETE ";
   #$from = " FROM ${tt_data}";
   #$where = " WHERE upper(program_abbr) like 'HATS' and flag LIKE '%9'";
   #$sql = $delete.$from.$where;
   #print "$sql\n";
   #$sth = $dbh->prepare($sql);
   #$sth->execute();
   #$sth->finish();
   
   #jwm -3.17 - updated to use new tag logic.  See comments in FlagPreliminary above. 
   $sql="delete t from ${tt_data} t join flask_data_view v on
                  (t.program_abbr=v.program and t.event_num=v.event_num and t.formula=v.parameter
                     and t.adate=v.a_date and ((t.atime='00:00:00' and v.a_time='00:00:00') or t.atime=v.a_time) and t.inst=v.inst)
               join flask_data_tag_view d on d.data_num=v.data_num
            where d.exclusion=1";
   $dbh->do($sql);
   $sql="delete t from ${tt_data} t join flask_event_tag_view e on t.event_num=e.event_num where e.exclusion=1";
   $dbh->do($sql);
   
}

sub MergeData()
{
   my $i;
   my $j;
   my $parameter_formula;
   my $parameter_formula_clean;
   my $program_abbr;
   my $program_abbr_clean;
   my $merge_join;

   #
   # Merge the results into one table
   # Option 1: Constrain on the event list
   # Option 2: Constrain on the first parameter specified
   # Option 3: Constrain on all the parameters
   #              ( Show only rows that have values for all parameters )
   #

   #
   # Initialization
   #
   $tt_mergetmp = "z".int(10**8*rand());
   $tt_mergetmp2 = "z".int(10**8*rand());
   $merge_select = "${tt_data}.event_num";

   if ( $debugmode )
   {
      print "tt_mergetmp: $tt_mergetmp\n";
      print "tt_mergetmp2: $tt_mergetmp2\n";
   }

   #
   #    Loop through and create a temporary table with event number, value, flag
   # for each parameter
   #
   $merge_join = '';

   foreach $parameterprogram_num ( @parameterprogram_nums )
   {
      %tmphash = &nvpair_split($parameterprogram_num);

      $parameter_formula = &get_relatedfield($tmphash{parameter_num}, 'parameter_num', 'parameter_formula');
      $parameter_formula_clean = lc($parameter_formula);
      $parameter_formula_clean =~ s/[^A-Za-z0-9]//g;
      $program_abbr = &get_relatedfield($tmphash{program_num}, 'program_num', 'program_abbr');
      $program_abbr_clean = lc($program_abbr);
      $program_abbr_clean =~ s/[^A-Za-z0-9]//g;

      $tt1 = "${tt_mergetmp}_".$parameter_formula_clean."_".$program_abbr_clean;
      if ( $debugmode ) { print "tt1: $tt1\n"; }

      #
      # The 'average' column is created in Average()
      #
      $create = "CREATE TEMPORARY TABLE ${tt1} ( INDEX(".$parameter_formula_clean."_".$program_abbr_clean."_event_num) )";
      $select = " SELECT event_num as ".$parameter_formula_clean."_".$program_abbr_clean."_event_num";
      $select = "${select}, formula as ".$parameter_formula_clean."_".$program_abbr_clean."_formula, program_abbr as ".$parameter_formula_clean."_".$program_abbr_clean."_program_abbr, average as ".$parameter_formula_clean."_".$program_abbr_clean."_value, flag as ".$parameter_formula_clean."_".$program_abbr_clean."_flag";
      $from = " FROM ${tt_avg}";
      $where = " WHERE formula = '$parameter_formula' AND program_abbr = '$program_abbr'";

      $sql = $create.$select.$from.$where;
      if ( $debugmode ) { print $sql."\n"; }

      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();

      #
      #    Create the select, join, and where strings for the merging query.
      # They are different based on the option selected
      #
      $merge_select = "${merge_select}, $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_formula, $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_program_abbr, $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_value, $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_flag";

      if ( $option == 1 )
      {
         # Based on event_num
         if ( $merge_join eq '' ) { $merge_join = "${tt_data} LEFT JOIN $tt1 ON ( ${tt_data}.event_num = $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_event_num )"; }
         else { $merge_join = "${tt_merge} LEFT JOIN $tt1 ON ( ${tt_merge}.event_num = $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_event_num )"; }
         $merge_where = '';
      }
      elsif ( $option == 2 )
      {
         #Based on first gas
         if ( $merge_join eq '' )
         {
            $merge_join = "$tt1, ${tt_data}";
            $merge_where = "$tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_event_num = ${tt_data}.event_num";
         }
         else
         {
            $merge_join = "${tt_merge} LEFT JOIN $tt1 ON ( ${tt_merge}.event_num = $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_event_num )";
            $merge_where = '';
         }
      }
      elsif ( $option == 3 )
      {
         #Based on all gases
         if ( $merge_join eq '' )
         {
            $merge_join = "${tt_data}, $tt1";
            $merge_where = "${tt_data}.event_num = $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_event_num";
         }
         else
         {
            $merge_join = "${tt_merge}, $tt1";
            $merge_where = "${tt_merge}.event_num = $tt1.".$parameter_formula_clean.'_'.$program_abbr_clean."_event_num";
         }
      }

      DropTable($tt_mergetmp2);

      # Execute new merge
      $create = " CREATE TEMPORARY TABLE ${tt_mergetmp2} ( INDEX ( event_num ) )";
      $select = " SELECT DISTINCT $merge_select";
      $from = " FROM $merge_join";
      if ( $merge_where ne '' ) { $where = " WHERE $merge_where"; }
      else { $where = ''; }

      $sql = $create.$select.$from.$where;
      if ( $debugmode ) { print $sql."\n"; }

      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();

      DropTable($tt_merge);

      $create = " CREATE TEMPORARY TABLE ${tt_merge} ( INDEX ( event_num ) )";
      $select = " SELECT *";
      $from = " FROM ${tt_mergetmp2}";

      $sql = $create.$select.$from;
      if ( $debugmode ) { print $sql."\n"; }

      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();

      #
      # Update all the fields that are empty to have filler information
      #
      $update = "UPDATE ${tt_merge}";
      $set = " SET ".$parameter_formula_clean.'_'.$program_abbr_clean."_formula = '$parameter_formula', ".$parameter_formula_clean.'_'.$program_abbr_clean."_program_abbr = '$program_abbr'";
      $set = "${set}, ".$parameter_formula_clean.'_'.$program_abbr_clean."_value = '-999.99', ".$parameter_formula_clean.'_'.$program_abbr_clean."_flag = 'FIL'";
      $where = " WHERE ".$parameter_formula_clean.'_'.$program_abbr_clean."_formula IS NULL AND ".$parameter_formula_clean.'_'.$program_abbr_clean."_program_abbr IS NULL AND ".$parameter_formula_clean.'_'.$program_abbr_clean."_flag IS NULL";

      $sql = $update.$set.$where;
      if ( $debugmode ) { print $sql."\n"; }

      $sth = $dbh->prepare($sql);
      $sth->execute();
      $sth->finish();

      $merge_select = "${tt_merge}.*";
   }
}

sub DataRelease()
{
   local($site_num, $project_num, $strategy_num, $program_num, $parameter_num, $type) = @_;

   $select = "SELECT data, begin, end";
   $from = " FROM ccgg.data_release";
   $where = " WHERE site_num = ? AND project_num = ? AND strategy_num = ?";
   $where = $where." AND program_num = ? and parameter_num = ?";
   $where = $where." AND type = ?";

   $sql = $select.$from.$where;
   @sqlargs = ($site_num,$project_num,$strategy_num,$program_num,$parameter_num,$type);

   if ( $debugmode )
   {
      print $sql."\n";
      print join(', ', @sqlargs)."\n";
   }

   $sth = $dbh->prepare($sql);
   $sth->execute(@sqlargs);
                                                                                          
   @releaseinfo = (); $nreleaseinfo = 0;
   while (@tmp = $sth->fetchrow_array())
   { @releaseinfo[$nreleaseinfo++] = join('~+~', @tmp) }
   $sth->finish();

   $where = "";

   # If no information in data_release then mark all as preliminary
   if ( $#releaseinfo < 0 && $type eq 'P' )
   { $where = " WHERE ( flask_event.date >= '1900-01-01' AND flask_event.date <= '9999-12-31'"; }
   else
   {
      foreach $line ( @releaseinfo )
      {
         ($data, $begin, $end) = split(/\~\+\~/, $line);

         if ( $data eq "S" )
         {
            if ( $where eq "" ) { $where = " WHERE ( (flask_event.date >= '$begin' AND flask_event.date <= '$end')"; }
            else { $where = "${where} OR (flask_event.date >= '$begin' AND flask_event.date <= '$end')"; }
         }
         if ( $data eq "A" )
         {
            if ( $where eq "" ) { $where = " WHERE ( (${tt_data}.adate >= '$begin' AND ${tt_data}.adate <= '$end')"; }
            else { $where = "${where} OR (${tt_data}.adate >= '$begin' AND ${tt_data}.adate <= '$end')"; }
         }
      }
   }

   return $where;
}

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

      if ( $binby eq "masl" ) { $binby = "alt"; }
      if ( $binby eq "magl" ) { $binby = "elev"; }
      if ( $binby eq "intake_ht" ) { $binby = "intake_height"; }
      if ( $binby eq "evn" ) { $binby = "num"; }
      if ( $binby eq "meth" ) { $binby = "me";}  #jwm 4/19.  added this to support data request web which incorrectly passed method as meth.  It was easier to add fix here then to change all the validation logic there.

      ($min, $max) = split(",",$range);
      if ($max eq "") { $max = $min; }
      else
      { $and = "${and} AND ${t1}.${binby} >= '${min}' AND ${t1}.${binby} <= '${max}'"; }

      if ($binby eq "date") { $min = &MinDate($min); $max = &MaxDate($max); }
      if ($binby eq "time") { $min = &MinTime($min); $max = &MaxTime($max); }

      if (grep(/\(/,$binby) && grep(/\)/,$binby))
      {
         $z = "${binby} >= '${min}' AND ${binby} <= '${max}'";
         $str = ($str) ? $str. " AND ".$z : $z;
      }
      elsif ($binby eq "me" ||
             $binby eq "site_num" ||
             $binby eq "id" ||
             $binby eq "project_num" )
      {
         if ( $binby eq "id" ) { $range =~ s/FP/\%/g; }
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

         $bdd = sprintf("%14.9f", &date2dec(@bdatearr, @btimearr));
         $edd = sprintf("%14.9f", &date2dec(@edatearr, @etimearr));

         $z = " ( (${t}.dd >= '$bdd' AND ${t}.dd <= '$edd') )";

         $str = ($str) ? $str." AND ".$z : $z;
      }
      elsif ( $binby eq "vp" )
      {
         #
         # Determine the beginning and ending date and time for vertical profiles
         #    based on what the user passes in. If the user only passes in a date
         #    then find all profiles that begin on that date. If the user only
         #    passes in a time, then find the vertical profiles that have that time
         #    in them. If the user passes in a date and time, find the vertical
         #    profile with that date and time in it.
         #
         @fields = split(/,/,$range);

         $str = "";
         foreach $sitecode ( @site )
         {
            $tmp = "/projects/src/db/ccg_vplist.pl -site=${sitecode}";
            if ( $fields[0] ne '' ) { $tmp = "${tmp} -date=$fields[0]"; }
            if ( $fields[1] ne '' ) { $tmp = "${tmp} -time=$fields[1]"; }

            if ( $debugmode ) { print $tmp."\n"; }

            @dates = `$tmp`;

            foreach $date ( @dates )
            {
               @datetime = split(/ /, $date);
               @dt1 = split(/\|/, $datetime[0]);
               @dt2 = split(/\|/, $datetime[1]);

               $z = "((${t}.date >= '$dt1[0]' AND ${t}.time >= '$dt1[1]')";
               $z = "${z} AND (${t}.date <= '$dt2[0]' AND ${t}.time <= '$dt2[1]')";

               $exitcode = 1;
               $snum = &get_relatedfield($sitecode, 'site_code', 'site_num', $exitcode);
               $z = "${z} AND ${t}.site_num = '$snum')";

               $str = ( $str eq '' ) ? "( ${z}" : "${str} OR ${z}";
            }
         }
         #
         # If $str is empty, that means that there is no vertical profile that
         #    meets the requested site+date+time. Therefor we want to return nothing
         #
         $str = ( $str eq '' ) ? "1 != 1" : "${str} )";

      }
      elsif ($binby eq "comment")
      {
         $z = BinByString($t, $binby, $range);
         $str = ($str) ? $str." AND ".$z : $z;
      }
      elsif ($binby eq "intake_height")
      {
         $z = " ( (f_intake_ht(${t}.alt, ${t}.elev) >= '$min' AND f_intake_ht(${t}.alt, ${t}.elev) <= '$max') )";

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

sub BinByData()
{
   local($t, $m, $not) = @_;
   my ($str, @bin, $i, $z);
   my ($binby, $range, $min, $max);

   $str = "";

   @bin = split("~",$m);

   for ($i=0; $i<@bin; $i++)
   {
      ($binby, $range) = split(":",$bin[$i],2);
      ($min, $max) = split(",",$range);
      if ($max eq "") { $max = $min; }

      if ($binby eq "date") { $min = &MinDate($min); $max = &MaxDate($max); }
      if ($binby eq "time") { $min = &MinTime($min); $max = &MaxTime($max); }

      if ($binby eq "inst")
      {
         $z = (grep(/\%/, $range) || grep (/\_/, $range)) ?  
         BinByLike($t, $binby, $range, "") : 
         BinByItem($t, $binby, $range);
         $str = ($str) ? $str." AND ".$z : $z;
      }
      elsif ($binby eq "flag")
      {
         $flag = $range;
         $z = BinByLike($t, $binby, $range, $not);
         $str = ($str) ? $str." AND ".$z : $z;
      }
      elsif ($binby eq "comment")
      {
         $z = BinByString($t, $binby, $range);
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

         $bdd = sprintf("%14.9f", &date2dec(@bdatearr, @btimearr));
         $edd = sprintf("%14.9f", &date2dec(@edatearr, @etimearr));

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

sub DropTable()
{
   my($t) = @_;
   my $sql;
   
   $sql = "DROP TABLE IF EXISTS ${t}";

   if ( $debugmode ) { print $sql."\n"; }

   $sth = $dbh->prepare($sql);
   $sth->execute();
   $sth->finish();
}

sub BinByString()
{
   local($t, $n, $r) = @_;
   my ($z, $i, @tmp); 

   @tmp = split(/\|/, $r);

   for ($i = 0, $z = ''; $i < @tmp; $i++)
   { $z = ($z) ?  "${z} OR ${t}.${n} LIKE '${tmp[$i]}'" : "(${t}.${n} ${not} LIKE '${tmp[$i]}'"; }

   $z = $z.")";
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

sub BinByRange()
{
   local($t, $n, $min, $max) = @_;
   my ($z); 


   $z =  "(${t}.${n} >= '${min}' AND ${t}.${n} <= '${max}')";
   return $z;
}

sub BinByItem()
{#jwm - 8-19, added not support for this.  
   local($t, $n, $r) = @_;
   my ($z,$z2, $i, @tmp); 
   $z2='';
   @tmp = split(",", $r);

   for ($i = 0, $z = ''; $i < @tmp; $i++)
   { 
	if($tmp[$i] =~ m/^\-/){#see if starts with minus sign.  These will get and'd to end
		$tmp[$i] =~ s/^\-//;#strip out
		$z2=($z2)?"${z2} AND ${t}.${n}!='${tmp[$i]}'" : "${t}.${n}!='${tmp[$i]}'";
	}else{
		$z = ($z) ?  "${z} OR ${t}.${n}='${tmp[$i]}'" : "(${t}.${n}='${tmp[$i]}'"; 
	}
   }
   $z=($z)?"${z})":$z;#append closing parens
   $z=($z and $z2)?"${z} and ${z2}":$z.$z2;#If both, and otherwise return whichever one has data
   return $z;
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

sub listfields()
{
   local (@dbh);
   my ($i, $sql);

   $sth = $dbh->prepare("SELECT * FROM flask_event LIMIT 1");
   $sth->execute();
   #
   # Fetch results
   #
   print "\n\nFields in \"flask_event\"\n\n";
   for ($i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++) { print $sth->{'NAME'}->[$i],"\n"; }
   $sth->finish();

   $sth = $dbh->prepare("SELECT * FROM flask_data LIMIT 1");
   $sth->execute();
   #
   # Fetch results
   #
   print "\n\nFields in \"flask_data\"\n\n";
   for ($i = 0; $i < $sth->{NUM_OF_FIELDS}; $i++) { print $sth->{'NAME'}->[$i],"\n"; }
   $sth->finish();

   &disconnect_db($dbh);
   exit;
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
   print HELP "ccg_flask\n";
   print HELP "#########################\n\n";
   print HELP "Create a table according to user-supplied options.\n";
   print HELP "Results are displayed in a \"vi\" session [default].  Enter\n";
   print HELP "\":q!\" to quit session.  Use \"-stdout\" option to send to STDOUT.\n";
   print HELP "Use \"-outfile\" option to redirect output.  Please see EXAMPLES\n";
   print HELP "below.\n\n";
   print HELP "Options:\n\n";
   print HELP "-abbr\n";
   print HELP "     Show abbreviated output.  This option is intended to facilitate\n";
   print HELP "     data manipulation and plotting.  Decimal year is included.\n";
   print HELP "     temperature, pressure, relative humidity [pfp]\n";
   print HELP "     when more than one gas formula is specified).\n\n";
   print HELP "-comment\n";
   print HELP "     Show event and data comments when appropriate.  Comments may be\n";
   print HELP "     associate with both event and data information.\n\n";
   print HELP "-d, -data=[analysis constraints]\n";
   print HELP "     Specify the DATA (e.g., measurement or analysis) constraints\n";
   print HELP "     The format of this argument is <attribute name>:<min>,<max>\n";
   print HELP "     where attribute name may be value, flag, inst, date, time, ...\n";
   print HELP "     The -l option will generate a list of data attributes.\n";
   print HELP "     Multiple bin conditions delimited by the tilda (~) may be\n";
   print HELP "     specified.\n\n";
   print HELP "     NOTE: A '%' may be used as a wildcard in the constraint.\n\n";
   print HELP "     (ex) -data=date:2000,2003\n";
   print HELP "     (ex) -data=inst:H4\n";
   print HELP "     (ex) -data=flag:..%\n";
   print HELP "     (ex) -data=date:2000-02-01,2000-11-03~inst:H4\n\n";
   print HELP "     NOTE: a minus sign can be used to negate an instrument.\n";
   print HELP "     (ex) -data=inst:-h4\n";
   print HELP "-elevation\n";
   print HELP "     Display the sample elevation in results.\n";
   print HELP "-e, -event=[sample constraints]\n";
   print HELP "     Specify the EVENT (e.g., sample collection) constraints\n";
   print HELP "     The format of this argument is <attribute name>:<min>,<max>\n";
   print HELP "     where attribute name may be date, time, lat, lon, alt,\n";
   print HELP "     ws, press, ...\n";
   print HELP "     The 'vp' constraint is used to constrain a vertical profile.\n";
   print HELP "     The arguments are date and time. If only a date is specified\n";
   print HELP "     then all vertical profiles that begin on that date are returned.\n";
   print HELP "     If a date and time are specified, then all vertical profiles\n";
   print HELP "     that contain that date and time are returned.\n";
   print HELP "     The -l option will generate a list of event attributes.\n";
   print HELP "     Multiple bin conditions delimited by the tilda (~) may\n";
   print HELP "     be specified.\n";
   print HELP "     NOTE: A '%' may be used as a wildcard in the constraint.\n\n";
   print HELP "     (ex) -event=date:2000,2003\n";
   print HELP "     (ex) -event=lat:-20,20\n";
   print HELP "     (ex) -event=date:2000-02-01,2000-11-03~alt:3000,4000\n\n";
   print HELP "     NOTE: a minus sign can be used to negate method or flask_id\n";
   print HELP "     (ex) -event=me:-H\n";
   print HELP "-exclusion\n";
   print HELP "     Set mixing ratios to default if the data are in the\n";
   print HELP "     time period to be excluded.\n\n";
   print HELP "-intake_ht, -intake-height\n";
   print HELP "      Display the sample intake height in results.\n";
   print HELP "-h, -help\n";
   print HELP "     Produce help menu\n\n";
   print HELP "-merge=[merge option]\n";
   print HELP "     Average multiple aliquots using the following strategy.\n";
   print HELP "     If there are multiple strings that match key then\n";
   print HELP "        the average of retained flask values is reported\n";
   print HELP "     or if there are no retained flask values\n";
   print HELP "        the average of non-background flask values is reported\n";
   print HELP "     or if there are no retained and non-background flask values\n";
   print HELP "        a single rejected flask value is reported\n";
   print HELP "     or if there are no measurements\n";
   print HELP "        a default value and flag is assigned.\n\n";
   print HELP "     1 - List a row for each event number\n";
   print HELP "     2 - List a row for each measurement of the first parameter\n";
   print HELP "             in the parameter list\n";
   print HELP "     3 - List a row where all parameters have a measurement\n";
   print HELP "             in the database\n";
   #print HELP "     An 'M' is assigned to 3rd column QC flag to\n";
   #print HELP "     indicate there were multiple measurements from the sample.\n";
   print HELP "-m, -method\n";
   print HELP "     Restrict collection method\n";
   print HELP "     Specify a single method (e.g., -method=D)\n";
   print HELP "     or any number of methods (e.g., -method=S,P,D)\n\n";
   print HELP "-noprogram\n";
   print HELP "     Do not display the analysis program in results.\n";
   print HELP "-noseconds\n";
   print HELP "     Do not display sample and analysis seconds..\n";
   print HELP "     If specified, only the hour and minute are shown.\n\n";
   print HELP "-not\n";
   print HELP "     Used with the QC 'flag' constraint to negate the logic.\n";
   print HELP "     (ex) -data=flag:..% -not will produce rejected and\n";
   print HELP "             non-background values only.\n";
   print HELP "     (ex) -data=flag:.% -not will produce rejected values only.\n";
   print HELP "     (ex) -data=flag:_._ -not will produce non-background values only.\n\n";
   print HELP "-nouncertainty\n";
   print HELP "     Do not display the analysis uncertainty in results.\n";
   print HELP "-oldstyle\n";
   print HELP "     Display result using 'old-style' site file format (single gas)\n";
   print HELP "     or old-style merged file when 'y' option is specified.\n\n";
   print HELP "-o, -outfile=[outfile]\n";
   print HELP "     Specify output file\n\n";
   print HELP "-pairaverage\n";
   print HELP "     When specified, returns the average of measurements based on\n";
   print HELP "     site code, collection date & time, method, parameter, latitude\n";
   print HELP "     longitude, and altitude\n\n";
   print HELP "-g, -parameter=[parameter(s)]\n";
   print HELP "     parameter formulae\n";
   print HELP "     Specify a single parameter (e.g., -parameter=co2)\n";
   print HELP "     or any number of parameters\n";
   print HELP "     (e.g., -parameter=co2,co2c13,co2o18,ch4,co)\n";
   print HELP "     This includes wind speed (ws), wind direction (wd)\n";
   print HELP "     temperature (temp), pressure (press), and relative\n";
   print HELP "     humidity (rh).\n\n";
   print HELP "-preliminary\n";
   print HELP "     Set 3rd column of QC flag to 'P' if the data are in the\n";
   print HELP "     time period considered as preliminary.\n\n";
   print HELP "-p, -project=[project]\n";
   print HELP "     Specify a project. (e.g., ccg_surface, ccg_aircraft)\n\n";
   print HELP "-program=[program]\n";
   print HELP "     Specify a program (e.g., -program=ccgg)\n\n";
   print HELP "     or any number of programs\n";
   print HELP "     (e.g., -program=ccgg,hats).\n";
   print HELP "-shownames\n";
   print HELP "     Print the field names as the first line of the output. A\n";
   print HELP "     space is used to deliminate the field names.\n\n";
   print HELP "-s, -site=[site(s)]\n";
   print HELP "     site code\n";
   print HELP "     Specify a single site (e.g., -site=brw)\n";
   print HELP "     or any number of sites (e.g., -site=rpb,asc)\n";
   print HELP "     Binned sites may be specified by name (e.g.,\n";
   print HELP "     'pocn30', 'car030' where 030 equals 30 * 1000 masl)\n";
   print HELP "     or constructed using the '-event' option\n";
   print HELP "     (e.g., -event=lat:27.5,32.5 and -event=alt:2500,3500).\n\n";
   print HELP "-st, -strategy=[strategy or strategies]\n";
   print HELP "     Specify a strategy. (e.g., -strategy=pfp)\n";
   print HELP "     or multiple strategies (-strategy=pfp,flask)\n\n";
   print HELP "-status=[status(es)]\n";
   print HELP "     Restrict project status\n";
   print HELP "     Specify a single project status (e.g., -status=ongoing)\n";
   print HELP "     or any number of status options (e.g., -status=ongoing,terminated)\n";
   print HELP "     Current project status options:\n";
   print HELP "     ongoing, special, terminated, other, binned\n\n";
   print HELP "-stdout\n";
   print HELP "     Send result to STDOUT.\n\n";
   print HELP "-uncertainty\n";
   print HELP "     Show analysis uncertainty when appropriate. Analysis\n";
   print HELP "     uncertainty does not appear with pair averaged,\n";
   print HELP "     merged, abbreviated, or old style output.\n\n";
   print HELP "-showtags\n";
   print HELP "     Show eventa and data tags when available.";
   print HELP "# List all co2 measurements for HAA using PFPs in altitude bin 015\n";
   print HELP "   (ex) ccg_flask -site=haa015 -parameter=co2 -strategy=pfp\n\n";
   print HELP "# List all co2c13 measurements for BRW where the analysis flag\n";
   print HELP "# does not begin with a '.'. Send output to STDOUT\n";
   print HELP "   (ex) ccg_flask -site=brw -parameter=co2c13 -data=flag:.% -not -stdout\n\n";
   print HELP "# List all co2c13 measurements for BRW where the analysis flag\n";
   print HELP "# begins with a '.'. Send output to STDOUT\n";
   print HELP "   (ex) ccg_flask -site=brw -parameter=co2c13 -data=flag:.% -stdout\n\n";
   print HELP "# List all co2, ch4, and co measurements for ALT where the\n";
   print HELP "# event number is between 3246 and 3246. Send the output to STDOUT\n";
   print HELP "# in the abbreviated format\n";
   print HELP "   (ex) ccg_flask -site=alt -parameter=co2,ch4,co -abbr -stdout\n";
   print HELP "           -event=num:3246,3246\n\n";
   print HELP "# List all co2, ch4, co measurements for BRW where the sample\n";
   print HELP "# date is in the year 2000\n";
   print HELP "   (ex) ccg_flask -site=brw -parameter=co2,ch4,co -event=date:2000,2000\n\n";
   print HELP "# List all co2, ch4, co measurements for POC where the sample\n";
   print HELP "# latitude is between -20 and -15\n";
   print HELP "   (ex) ccg_flask -site=poc -parameter=co2,ch4,co -event=lat:-20,-15\n\n";
   print HELP "# List all ch4 measurements for BRW where the analysis year\n";
   print HELP "# is between or equal to 2003-01-01 and 2004-01-01\n";
   print HELP "   (ex) ccg_flask -site=brw -parameter=ch4 -data=date:2003,2004\n\n";
   print HELP "# List all co2, ch4, co measurements for CAR sampled by a PFP and\n";
   print HELP "# altitude is between 1500 and 2500 masl\n";
   print HELP "   (ex) ccg_flask -site=car020 -parameter=co2,ch4,co -strategy=pfp\n";
   print HELP "   (ex) ccg_flask -site=car -parameter=co2,ch4,co -event=alt:1500,2500\n";
   print HELP "           -strategy=pfp\n\n";
   print HELP "# List all co2, co2 ch4 measurements for CAR sampled by a PFP and\n";
   print HELP "#    the sample date is 2000-10-16 and the PFP ID is 205\n";
   print HELP "   (ex) ccg_flask -site=car -parameter=co2,co,ch4 -strategy=pfp\n";
   print HELP "           -event=\"date:2000-10-16,2000-10-16~substring_index(id,'-',1):205,205\"\n\n";
   print HELP "# List all co2 measurements for MSC where the flask id suffix is 99\n";
   print HELP "   (ex) ccg_flask -site=msc -parameter=co2\n";
   print HELP "           -event=\"substring_index(id,'-',-1):99,99\"\n\n";
   print HELP "# List all co2, co, ch4 measurements where the sample year is 2000\n";
   print HELP "# and the latitude is between 0 ond 20. Send results to STDOUT\n";
   print HELP "   (ex) ccg_flask -parameter=co2,co,ch4 -event=date:2000,2000~lat:0,20\n";
   print HELP "           -stdout\n\n";
   print HELP "# List all co2 measurements where the sample year is 2000\n";
   print HELP "#    and the project status is ongoing or terminated. Send\n";
   print HELP "#    results to STDOUT\n";
   print HELP "   (ex) ccg_flask -parameter=co2 -stdout -event=date:2000,2000\n";
   print HELP "           -status=ongoing,terminated\n\n";
   print HELP "# List all co2, co measuremnts for MLO in a merged format\n";
   print HELP "#    constrained on the first parameter in the parameter list. Send\n";
   print HELP "#    results to STDOUT\n";
   print HELP "   (ex) ccg_flask -site=mlo -parameter=co2,co -stdout -merge=2\n\n";
   print HELP "# List all co2 measurements where the analysis date is between\n";
   print HELP "#    or equal to 2005-01-01 and 2005-04-01. Also the instrument\n";
   print HELP "#    is equal to H4. Send results to STDOUT\n";
   print HELP "   (ex) ccg_flask -parameter=co2 -data=date:2005-01,2005-04~inst:H4 -stdout\n";
   close(HELP);
   
   exit;
}
