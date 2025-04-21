<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");
include ("/var/www/html/inc/validator.php");
include ("/var/www/html/inc/ccggdb_utils.php");

if (!($fpdb = ccgg_connect()))
{  
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}  
   
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : 'flask';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : 'flask';

$clnarray = array ();

if ( isset( $_POST['project_list'] ) && ValidInt($_POST['project_list']) )
{
   $clnarray['project_num'] = $_POST['project_list'];
}
else
{
   if ( $strat_abbr == 'pfp' )
   { $clnarray['project_num'] = '2'; }
   else
   { $clnarray['project_num'] = '1'; }
}

$clnarray['dateconstraint'] = ( isset( $_POST['date_textbox'])  && ValidDate($_POST['date_textbox'])) ? $_POST['date_textbox'] : date("Y-m-d", mktime(0, 0, 0, date("m"), date("d"), date("Y")-1));

$strategy_infos = DB_GetAllStrategyInfo('~+~');

foreach ( $strategy_infos as $strategy_info )
{
   $fields = split('~\+~', $strategy_info);

   if ( strtolower($fields[2]) == strtolower($strat_abbr) )
   {
      $clnarray['strategy_num'] = $fields[0];
      $clnarray['strategy_abbr'] = $fields[2];
      break;
   }
}

$project_infos = DB_GetAllProjectInfo('~+~');

foreach ( $project_infos as $project_info )
{
   $fields = split('~\+~', $project_info);

   if ( $fields[0] == $clnarray['project_num'] )
   {
      $clnarray['project_abbr'] = $fields[2];
      break;
   }
}

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
#echo "<SCRIPT language='JavaScript' src='om_samplefreq.js'></SCRIPT>";

MainWorkArea();
exit;

#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $clnarray;
global $dateconstraint;


#print_r($proj_infos);
$args['constraints'] = "strategy_num = ".$clnarray['strategy_num'];
$args['delimiter'] = '~+~';

list($fieldnames, $data) = DB_DataSummaryInfo($args);

$project_num_idx = array_search('project_num', $fieldnames);
$project_abbr_idx = array_search('project_abbr', $fieldnames);

$project_infos = array();
for ( $i=0; $i<count($data); $i++ )
{
   $datafields = split('~\+~', $data[$i]);

   array_push($project_infos, $datafields[$project_num_idx].'~'.$datafields[$project_abbr_idx]);
}
$project_infos = array_values(array_unique($project_infos));

#print_r($project_infos);

?>
   <FORM name='mainform' method='POST'>
    <TABLE width='90%' cellpadding=5 cellspacing=5 border=0 align='center'>
     <TR>
      <TD align='center'>
       <DIV class='XLargeBlueB'>Sample Frequency</DIV>
      </TD>
     </TR>
     <TR>
      <TD align='center'>
       <TABLE border='1'>
        <TR>
         <TD align='center'>
          Project
         </TD>
         <TD align='center'>
          Date
         </TD>
         <TD rowspan='2'>
          <INPUT type='submit' value='Submit' class='Btn'>
         </TD>
        </TR>
        <TR>
         <TD>
          <SELECT name='project_list'>
<?php
   foreach ($project_infos as $project_info)
   {
      list($project_num, $project_abbr) = split('~', $project_info);
      $selected = ( $project_num === $clnarray['project_num'] ) ? 'SELECTED' : '';
      echo "<OPTION value='$project_num' $selected>$project_abbr</OPTION>\n";
   }
?>
          </SELECT>
         </TD>
         <TD>
<?php
   echo "<INPUT type='text' name='date_textbox' size='12' maxlength='10' value='".$clnarray['dateconstraint']."'>";
?>
         </TD>
        </TR>
       </TABLE>
      </TD>
     </TR>
     <TR>
      <TD align='center'>
       <HR>
       <DIV>Project:
<?PHP
   foreach ($project_infos as $project_info)
   {
      list($project_num, $project_abbr) = split('~', $project_info);
      if ( $project_num === $clnarray['project_num'] )
      {
         echo "<SPAN class='MediumBlueN'>$project_abbr</SPAN>.";
         break;
      }
   }
?>
       Samples since:
<?PHP
echo "<SPAN class='MediumBlueN'>".$clnarray['dateconstraint']."</SPAN>";
?>
       </DIV>
       <TABLE border='1' cellpadding=5 cellspacing=5>
        <TR>
         <TH>Site</TH> 
         <TH>Mean [days]</TH> 
         <TH>Std Dev [days]</TH> 
         <TH>Num</TH> 
        </TR>
<?PHP

$args['constraints'] = "project_num = ".$clnarray['project_num']." AND strategy_num = ".$clnarray['strategy_num']." AND status_num = 1";
$args['orderby'] = 'site_code';
$args['delimiter'] = '~+~';

list($fieldnames, $data) = DB_DataSummaryInfo($args);

#print_r($fieldnames);
#print_r($data);

$site_num_idx = array_search('site_num', $fieldnames);
$site_code_idx = array_search('site_code', $fieldnames);

$site_infos = array();
for ( $i=0; $i<count($data); $i++ )
{
   $datafields = split('~\+~', $data[$i]);

   array_push($site_infos, $datafields[$site_num_idx].'~'.$datafields[$site_code_idx]);
}
$site_infos = array_values(array_unique($site_infos));

#print_r($site_infos);

foreach ($site_infos as $site_info)
{
   list($site_num, $site_code) = split('~', $site_info);
   #print "$site_info<BR>";

   if ( $clnarray['project_num'] == 2 )
   {
      $perlcode = "/projects/src/db/ccg_vplist.pl";
      $tmp = "$perlcode -site=$site_code -strategy=".$clnarray['strategy_abbr'];

      $event_dataarr = array();

      exec($tmp,$event_dataarr);

      list($yr,$mo,$dy) = explode('-',$clnarray['dateconstraint']);
      list($hr,$mn,$sc) = explode(':','23:59:59');

      $dateconstraint_dd = &date2dec($yr,$mo,$dy,$hr,$mn,$sc);

      $event_dates = array();
      $event_times = array();
      foreach ($event_dataarr as $event_dataline)
      {
         list($datetime1,$datetime2) = split(' ', $event_dataline);

         list($date,$time) = split('\|', $datetime1);

         list($yr,$mo,$dy) = explode('-',$date);
         list($hr,$mn,$sc) = explode(':',$time);

         $cur_dd = &date2dec($yr,$mo,$dy,$hr,$mn,$sc);

         if ( $cur_dd > $dateconstraint_dd )
         {
            array_push($event_dates, $date);
            array_push($event_times, $time);
         }
      }
   }
   else
   {
      $args['constraints'] = "event_date > '".$clnarray['dateconstraint']."' AND site_num = $site_num AND project_num = ".$clnarray['project_num']." AND strategy_num = ".$clnarray['strategy_num'];
      $args['orderby'] = 'event_date';
      $args['delimiter'] = '~+~';
      list($event_fieldnames, $event_dataarr) = DB_EventInfo($args);

      #print_r($event_dataarr);
      if ( count($event_dataarr) < 2 ) { continue; }

      $event_date_idx = array_search('event_date', $event_fieldnames);
      $event_time_idx = array_search('event_time', $event_fieldnames);

      $event_dates = array();
      $event_times = array();
      for ( $i=0; $i<count($event_dataarr); $i++ )
      {
         $datafields = split('~\+~', $event_dataarr[$i]);

         array_push($event_dates, $datafields[$event_date_idx]);
         array_push($event_times, $datafields[$event_time_idx]);
      }
   }

   if ( count($event_dates) < 2 ) { continue; }

   $prev_event_date = array_shift($event_dates);
   $prev_event_time = array_shift($event_times);

   list($yr,$mo,$dy) = explode('-',$prev_event_date);
   list($hr,$mn,$sc) = explode(':',$prev_event_time);

   $prev_event_dd = &date2dec($yr,$mo,$dy,$hr,$mn,$sc);

   $diffdds = array ();
   for ( $i=0; $i<count($event_dates); $i++ )
   {
      list($yr,$mo,$dy) = explode('-',$event_dates[$i]);
      list($hr,$mn,$sc) = explode(':',$event_times[$i]);
      $event_dd = &date2dec($yr,$mo,$dy,$hr,$mn,$sc);
      
      #
      # There are 8760 hours in a year
      #
      if ( $event_dd - $prev_event_dd < ( 24 * (1/8760) ) )
      { continue; }
      else
      {
         array_push($diffdds, ($event_dd-$prev_event_dd) * 365);
         $prev_event_dd = $event_dd; 
      }
   }

   #print_r($diffdds);

   $mean = mean($diffdds);
   if ( $mean == FALSE ) { $mean = -999.99; }
   $stddev = standard_deviation($diffdds);
   if ( $stddev == FALSE ) { $stddev = -999.99; }
   $line = sprintf ("<TR><TD>%-7s</TD><TD>%7.2f</TD><TD>%7.2f</TD><TD>%7d</TD></TR>", $site_code, $mean, $stddev, count($diffdds));
   print "$line\n";
}

?>
       </TABLE>
      </TD>
     </TR>
    </TABLE>
   </FORM>
<?PHP
}

#
# Function mean #######################################################################
#
# From http://php.net/manual/en/ref.math.php
function mean($arr)
{
    if (!count($arr)) return FALSE;

    $sum = 0;
    for ($i = 0; $i < count($arr); $i++)
    {
        $sum += $arr[$i];
    }

    return $sum / count($arr);
}

#
# Function variance ####################################################################
#
# From http://php.net/manual/en/ref.math.php
function variance($arr)
{
    if ( count($arr) < 2 ) return FALSE;

    $mean = mean($arr);

    $sos = 0;    // Sum of squares
    for ($i = 0; $i < count($arr); $i++)
    {
        $sos += ($arr[$i] - $mean) * ($arr[$i] - $mean);
    }

    return $sos / (count($arr)-1);  // denominator = n-1; i.e. estimating based on sample
                                    // n-1 is also what MS Excel takes by default in the
                                    // VAR function
}

#
# Function standard_deviation #########################################################
#
function standard_deviation($arr)
{
   if (!count($arr)) return FALSE;

   $variance = variance($arr);

   return sqrt($variance);
}
?>
