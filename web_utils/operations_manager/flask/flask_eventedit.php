<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$path = isset( $_POST['path'] ) ? $_POST['path'] : '';
$search4event = isset( $_POST['search4event'] ) ? $_POST['search4event'] : '';
$event_detail = isset( $_POST['event_detail'] ) ? $_POST['event_detail'] : '';
$original_detail = isset( $_POST['original_detail'] ) ? $_POST['original_detail'] : '';

if ( empty($event_detail) ) { $ev_project = "ccg_surface"; }
else
{
   list($ev_code,$ev_project,$ev_id,$ev_date,$ev_time,$ev_meth,$ev_ws,$ev_wd,
   $ev_lat,$ev_lon,$ev_alt,$ev_comment,$ev_num,$lst2utc,$status_num,
   $ev_path) = split("\|",$event_detail);
}

$strat_abbr = 'flask';
$strat_name = 'Flask';
$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_eventedit.js'></SCRIPT>";

#
# Need this site list to verify codes
#
$siteinfo = DB_GetSiteListInfo($ev_project,$strat_abbr);
for ($i=0,$z=''; $i<count($siteinfo); $i++)
{
   $field = split("\|",$siteinfo[$i]);
   # code, lat, lon, elev, intake_ht
   $z = "${field[1]},${field[4]},${field[5]},${field[6]},${field[7]}";
   JavaScriptCommand("siteinfo[$i] = \"${z}\"");

   $sitelist[$i] = $field[1];
}

switch ($task)
{
   case "search":
      $event_detail = DB_GetEventDetails($search4event);
      if (empty($event_detail))
      { JavaScriptAlert("${search4event} does not exist as a FLASK event number"); }
      $original_detail = $event_detail;
      break;
   case "accept":
      #
      # update event details and analysis path
      #
      if (DB_UpdateEventNum($event_detail))
      {
         $z = "Event number ${ev_num} updated in DB";
         $z = "${z} (old):${original_detail}";
         $z = "${z} (new):${event_detail}";
         UpdateLog($log,$z);
         $event_detail = '';
      }
      else { JavaScriptAlert("Unable to update event number ${ev_num} in DB"); }
      break;
   case "discard":
      #
      # If sample has been measured, DO NOT DELETE!
      #
      if (DB_EventMeasured($ev_num))
      {
         $z = "Event number ${ev_num} has already been measured";
         $z = "${z}\\nand may not be deleted from DB";
         JavaScriptAlert($z);
         break;
      }
      #
      # delete event from DB
      #
      if (DB_DeleteEventNum($ev_num))
      {
         UpdateLog($log,"Event number ${ev_num} removed from DB ${event_detail}");
         $event_detail = '';
      } else { JavaScriptAlert("Unable to remove event number ${ev_num} from DB"); }
      break;
}
MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $strat_abbr;
global $path;
global $ev_num;
global $event_detail;
global $original_detail;
global $task;

#
# $event_detail is the variable that contains a lot of data delimited by
#    pipes. If there is no data, the pipes must still be there so
#    the subsequant variables will be set empty and we get no
#    offset error messages
#
if ( empty($event_detail) ) { $event_detail = '|||||||||||||||'; }

list($ev_code,$ev_project,$ev_id,$ev_date,$ev_time,$ev_meth,$ev_ws,$ev_wd,
$ev_lat,$ev_lon,$ev_alt,$ev_comment,$ev_num,$lst2utc,$status_num,
$ev_path) = split("\|",$event_detail);

if ($ev_num != '0' && $ev_num != '')
{
   $ev_date = DateFormat($ev_date,"2004-03-15_to_15MAR2004");
   $ev_time = TimeFormat2($ev_time,"11:24:00_to_112400");
   #
   # Reset Default time from 99:99:00 to 12:34:56
   # June 2006 - kam, pml
   #
   if (strcmp($ev_time, "123456") == 0) { $ev_time = "9999"; }

   #$ev_lat = Dec2Deg($ev_lat,'lat');
   #$ev_lon = Dec2Deg($ev_lon,'lon');
} else $ev_num = '';

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='task' VALUE='${task}'>";
echo "<INPUT TYPE='HIDDEN' NAME='event_detail' VALUE='${event_detail}'>";
echo "<INPUT TYPE='HIDDEN' NAME='original_detail' VALUE='${original_detail}'>";
echo "<INPUT TYPE='HIDDEN' NAME='ev_num' VALUE='${ev_num}'>";
echo "<INPUT TYPE='HIDDEN' NAME='path' VALUE='${path}'>";
echo "<INPUT TYPE='HIDDEN' NAME='lst2utc' VALUE='${lst2utc}'>";
echo "<INPUT TYPE='HIDDEN' NAME='status_num' VALUE='${status_num}'>";

echo "<INPUT TYPE='HIDDEN' NAME='last_code' VALUE='${ev_code}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_id' VALUE='${ev_id}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_date' VALUE='${ev_date}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_time' VALUE='${ev_time}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_meth' VALUE='${ev_meth}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_ws' VALUE='${ev_ws}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_wd' VALUE='${ev_wd}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_lat' VALUE='${ev_lat}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_lon' VALUE='${ev_lon}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_alt' VALUE='${ev_alt}'>";

# Extract out the elevation source from the comment
# so we can set the pull down correctly and
# the comment
$commentfields = explode("~+~", $ev_comment);

$ev_elev_source = '';
for ( $i=0; $i<count($commentfields); $i++ )
{
   $tmp = explode(':', $commentfields[$i]);

   if ( $tmp[0] === 'elev' )
   {
      $ev_elev_source = $tmp[1];
      # Remove this entry, then all the rest go into
      #  the comment field
      unset($commentfields[$i]);
      #$remove = array_pop($commentfields);
      break;
   }
}
$ev_comment = implode("~+~", $commentfields);

if ( $ev_elev_source == '' )
{ $ev_elev_source = 'DB'; }
else
{
   if ( $ev_elev_source != 'DB' )
   { $ev_elev_source = 'DEM'; }
}

echo "<INPUT TYPE='HIDDEN' NAME='last_elev_source' VALUE='${ev_elev_source}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_comment' VALUE='${ev_comment}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_path' VALUE='${ev_path}'>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Event Editing</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE cellspacing=10 cellpadding=10 width='50%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center'>";
echo "<FONT class='MediumBlackB'>Event Number </FONT>";
echo "<B><INPUT TYPE='text' class='LargeSizeBlackTurquoiseB' SIZE=10 NAME='search4event'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Search' onClick='SearchCB()'></TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE cellspacing=10 cellpadding=10 width='80%' align='center'>";
echo "<TR>";
echo "<TD align='left'>";
#
# Event Details
#
echo "<TABLE cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Event Num</TD>";
echo "<TD class='LargeRedB'>$ev_num</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Code</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_code' VALUE='${ev_code}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
onChange='SetPosition()' 
class='MediumBlackN' SIZE=10 MAXLENGTH=3></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Date [09Feb2004]</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_date' VALUE='${ev_date}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=9></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Time [014300]</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_time' VALUE='${ev_time}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=6></TD>";
echo "<TD><SELECT class='MediumBlackN' NAME='time_conv'
onChange='ConvertDT()' SIZE='1'>";
echo "<OPTION VALUE='utc'>UTC</OPTION>";
echo "<OPTION VALUE='lst'>LST</OPTION>";
echo "<OPTION VALUE='ldt'>LDT</OPTION>";
echo "<OPTION VALUE='julian'>JULIAN</OPTION>";
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Id</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_id' readonly disabled VALUE='${ev_id}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=10></TD>";#jwm 5.16.24. changed to readonly to prevent issue where this value is changed prior to magicc analysis, which looks up event_num from flask_id in flask_inv. Below logic doesn't update both.  Perhaps it should, but that quickly gets complicated (because of other records that may need to get fixed).  Decided to just make this field read only and force users to fix but updating other fields.or asking me.
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Method [D]</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_meth' VALUE='${ev_meth}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=1></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Wind Speed [-99.9]</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_ws' VALUE='${ev_ws}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=5></TD>";

if ( empty($ev_ws) && !empty($ev_num) )
{ JavaScriptCommand("document.mainform.ev_ws.value = defaults1.ws"); }

echo "<TD><SELECT class='MediumBlackN' NAME='ws_conv'
onChange='ConvertWS()'
SIZE='1'>";
echo "<OPTION VALUE='m/s'>m/s</OPTION>";
echo "<OPTION VALUE='knots'>knots</OPTION>";
echo "<OPTION VALUE='mph'>mph</OPTION>";
echo "<OPTION VALUE='kph'>kph</OPTION>";
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Wind Direction [999]</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_wd' VALUE='${ev_wd}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=3></TD>";

if ( empty($ev_wd) && !empty($ev_num) )
{ JavaScriptCommand("document.mainform.ev_wd.value = defaults1.wd"); }

echo "<TD><SELECT class='MediumBlackN' NAME='wd_conv'
onChange='ConvertWD()'
SIZE='1'>";
echo "<OPTION VALUE='degrees'>Degrees</OPTION>";
echo "<OPTION VALUE='cardinal'>Cardinal</OPTION>";
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Latitude</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_lat' VALUE='${ev_lat}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=8></TD>";
#echo "<TD><SELECT class='MediumBlackN' NAME='lat_conv'
#onChange='ConvertLAT()'
#SIZE='1'>";
#echo "<OPTION VALUE='degrees'>Degrees</OPTION>";
#echo "<OPTION VALUE='decimal'>Decimal</OPTION>";
#echo "</SELECT>";
echo "<TD>";
# Units selection table
echo "<TABLE>";
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='radio' NAME='ev_lat_units' VALUE='dec' CHECKED></INPUT>";
echo "</TD>";
echo "<TD>";
echo "Decimal&nbsp;[-99.9999]";
echo "</TD>";
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='radio' NAME='ev_lat_units' VALUE='deg'></INPUT>";
echo "</TD>";
echo "<TD>";
echo "Degrees&nbsp;[99&nbsp;99S]";
echo "</TR>";
echo "</TABLE>";
# End of Units selection table
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Longitude</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_lon' VALUE='${ev_lon}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=9></TD>";
#echo "<TD><SELECT class='MediumBlackN' NAME='lon_conv'
#onChange='ConvertLON()'
#SIZE='1'>";
#echo "<OPTION VALUE='degrees'>Degrees</OPTION>";
#echo "<OPTION VALUE='decimal'>Decimal</OPTION>";
#echo "</SELECT>";
echo "<TD>";
# Units selection table
echo "<TABLE>";
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='radio' NAME='ev_lon_units' VALUE='dec' CHECKED></INPUT>";
echo "</TD>";
echo "<TD>";
echo "Decimal&nbsp;[-999.9999]</INPUT>";
echo "</TD>";
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='radio' NAME='ev_lon_units' VALUE='deg'></INPUT>";
echo "</TD>";
echo "<TD>";
echo "Degrees&nbsp;[999&nbsp;99W]";
echo "</TR>";
echo "</TABLE>";
# End of Units selection table
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Altitude [-9999.99]</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_alt' VALUE='${ev_alt}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=8></TD>";
echo "<TD><SELECT class='MediumBlackN' NAME='alt_conv'
onChange='ConvertALT()'
SIZE='1'>";
echo "<OPTION VALUE='masl'>masl</OPTION>";
echo "<OPTION VALUE='ft'>ft</OPTION>";
echo "<OPTION VALUE='km'>km</OPTION>";
echo "<OPTION VALUE='miles'>miles</OPTION>";
echo "</SELECT>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Elevation source</TD>";
echo "<TD><SELECT class='MediumBlackN' NAME='ev_elev_source'
SIZE='1'>";

# Set the default based on project
if ( $ev_elev_source == '' )
{
   $proj_num = DB_GetProjectNum($ev_project);

   if ( $proj_num == 1 )
   { $ev_elev_source = 'DB'; }
   else
   { $ev_elev_source = 'DEM'; }
}

$selected = ( $ev_elev_source == 'DB' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='DB' $selected>Database</OPTION>";
$selected = ( $ev_elev_source != 'DB' ) ? 'SELECTED' : '';
echo "<OPTION VALUE='DEM' $selected>DEM</OPTION>";
echo "</SELECT>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Comment</TD>";
echo "<TD><INPUT TYPE='text' NAME='ev_comment' VALUE='${ev_comment}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=128></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";

echo "<TD align='center'>";
echo "<FONT class='MediumBlackB'>Project:</FONT><BR>";
if ( $status_num != 0 )
{ $onchange = "onChange='ProjListCB(this)'"; }
else
{ $onchange = ""; }
echo "<SELECT class='MediumBlackN' NAME='projlist' SIZE='1' $onchange>";

$sitedescinfo = DB_GetSiteDescNoSS($ev_code, $strat_abbr);
for ($j=0; $j<count($sitedescinfo); $j++)
{
   $tmp = split("\|",$sitedescinfo[$j]);
   $selected = ( $tmp[1] == $ev_project ) ? " SELECTED" : "";
   echo "<OPTION $selected VALUE='$sitedescinfo[$j]'>$tmp[1]</OPTION>";
}

echo "</SELECT>";
echo "</TD>";

if ($status_num != 0)
{
   echo "<TD align='right'>";
   #
   # Status
   #
   $status_defi = DB_GetSampleStatusDefi();

   if ($ev_num != '')
   {
      $field=split("\|",$status_defi[((int) $status_num)-1]);

      echo "<TABLE cellspacing='8' cellpadding='8' align='center'>";
      echo "<TR>";
      echo "<TD align='center'>";
      echo "<FONT class='MediumBlackB'>${ev_id} is currently </FONT>";
      echo "<FONT class='MediumRedB'>${field[1]}</FONT>";
      echo "</TD>";
      echo "</TR>";
      echo "</TABLE>";
   }

   if ($ev_num != '' && $status_num != '2' && $status_num != '4')
   {
      #
      # Measurement Path
      #
      $sys_defi = DB_GetSystemDefi();

      echo "<TABLE cellspacing='2' cellpadding='2' align='center'>";
      echo "<TR>";
      echo "<TD align='center'>";
      echo "<FONT class='MediumBlackB'>Measurement Path</FONT>";
      echo "</TD>";
      echo "</TR>";

      $n = count($sys_defi);
      JavaScriptCommand("npaths = \"${n}\"");

      $dummy = str_repeat("-",30);
      #
      # Measurement path assigned to sample
      #
      $apath = split(",",$ev_path);

      for ($i=0,$j=1; $i<$n; $i++,$j++)
      {
         echo "<TR>";
         echo "<TD>";
         echo "<FONT class='MediumBlackN'>${j}. </FONT>";
         echo "<SELECT class='MediumBlackN' NAME='path${j}' SIZE='1'>";
            echo "<OPTION VALUE=''}>$dummy</OPTION>";
            for ($ii=0; $ii<$n; $ii++)
            {
               $field=split("\|",$sys_defi[$ii]);

               $selected = '';
               if ($i < count($apath))
               { if ($field[0] == $apath[$i]) $selected = 'SELECTED'; }

               echo "<OPTION VALUE=${sys_defi[$ii]} $selected>${field[1]}</OPTION>";
            }
         echo "</SELECT>";
         echo "</TD>";
         echo "</TR>";
      }
      echo "</TABLE>";
   }
   echo "</TD>";
}
echo "</TR>";
echo "</TABLE>";

echo "<TABLE width='40%' cellspacing='2' cellpadding='2' align='center'>";

echo "<TR>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Accept' onClick='AcceptCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Discard' onClick='DiscardCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Clear' onClick='ClearCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Recall' onClick='RecallCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Defaults' onClick='SetDefaultsCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";

echo "</TR>";
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetEventDetails ########################################################
#
function DB_GetEventDetails($ev_num)
{
   #
   # Get event details associated with passed event number
   #
   $select = "SELECT gmd.site.code,project.abbr,flask_event.id";
   $select = "${select},flask_event.date,flask_event.time";
   $select = "${select},flask_event.me";
   $select = "${select},flask_event.lat,flask_event.lon,flask_event.alt";
   $select = "${select},flask_event.comment,flask_event.num,site.lst2utc";
   $from = " FROM gmd.site,flask_event,project";
   $where = " WHERE flask_event.num='${ev_num}'";
   $and = " AND gmd.site.num=flask_event.site_num";
   $and = "${and} AND flask_event.project_num = project.num";
   $and = "${and} AND flask_event.strategy_num='1'";

   #echo "$select$from$where$and<BR>";
   $ev = ccgg_query($select.$from.$where.$and);

   if (empty($ev[0])) { return ''; }

   $paramstr = "";
   $params = array("ws", "wd");
   for ( $i=0; $i<count($params); $i++ )
   {
      $param_num = DB_GetParamNum($params[$i]);

      $select = " SELECT value";
      $from = " FROM flask_data";
      $where = " WHERE event_num = '$ev_num'";
      $and = " AND parameter_num = '$param_num'";

      $sql = $select.$from.$where.$and;
      $res = ccgg_query($sql);

      $value = ( isset($res[0]) ) ? "$res[0]" : "";

      $paramstr = ($i == 0) ? "$value" : "$paramstr|$value";
   }

   $tmp = split("\|", $ev[0]);
   $ev_arr = array( $tmp[0], $tmp[1], $tmp[2], $tmp[3], $tmp[4], $tmp[5], $paramstr, $tmp[6], $tmp[7], $tmp[8], $tmp[9], $tmp[10], $tmp[11]);
   $ev[0] = implode("|", $ev_arr);

   #
   # Get ancillary information about event from inventory
   #
   $select = "SELECT sample_status_num,path";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.event_num='${ev_num}'";

   $anc = ccgg_query($select.$from.$where);
   #
   # Concatenate results
   #
   if (isset($anc[0])) { return $ev[0].'|'.$anc[0]; }
   else { return $ev[0].'|0|0|'; }
}
#
# Function DB_EventMeasured ########################################################
#
function DB_EventMeasured($ev)
{
   #
   # Determine if event sample has been measured
   #
   $select = "SELECT COUNT(event_num)";
   $from = " FROM flask_data";
   $where = " WHERE event_num='${ev}'";
   $res = ccgg_query($select.$from.$where);

   if ($res[0] > 0) { return(TRUE); }
   else { return(FALSE); }
}
#
# Function DB_DeleteEventNum ########################################################
#
function DB_DeleteEventNum($ev)
{
   #
   # Delete Event Number from DB
   #
   $update = "UPDATE flask_inv";
   $set = " SET event_num='0'";
   $where = " WHERE event_num='${ev}'";

   #echo "$update$set$where<BR>";
   $res = ccgg_insert($update.$set.$where);

   $delete = "DELETE";
   $from = " FROM flask_event";
   $where =" WHERE num='${ev}'";

   #echo "$delete$from$where<BR>";
   $res = ccgg_delete($delete.$from.$where);
   #$res = "";

   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_UpdateEventNum ########################################################
#
function DB_UpdateEventNum($event_detail)
{
   global $strat_abbr;

   list($ev_code,$ev_project,$ev_id,$ev_date,$ev_time,$ev_meth,$ev_ws,$ev_wd,
   $ev_lat,$ev_lon,$ev_alt,$ev_comment,$ev_num,$lst2utc,$status_num,
   $ev_path) = split("\|",$event_detail);
   #
   # Reset Default time from 99:99:00 to 12:34:56
   # June 2006 - kam, pml
   #
   if (!(strncmp($ev_time, "99", 2))) { $ev_time = "12:34:56"; }

   $site_num = DB_GetSiteNum($ev_code);
   $proj_num = DB_GetProjectNum($ev_project);

   list($yr,$mo,$dy) = split("-",$ev_date);
   list($hr,$mn,$sc) = split(":",$ev_time);
   $dd = date2dec($yr,$mo,$dy,$hr,$mn);

   # Extract out the elevation source from the comment
   # because we need it to determine where we query
   # for the elevation. Also, so that we can replace
   # 'DEM' with the correct model used.
   $commentfields = explode("~+~", $ev_comment);

   $ev_elev_source = '';
   for ( $i=0; $i<count($commentfields); $i++ )
   {
      $tmp = explode(':', $commentfields[$i]);

      if ( $tmp[0] === 'elev' )
      {
         $ev_elev_source = $tmp[1];
         # Remove this entry, then all the rest go into
         #  the comment field
         unset($commentfields[$i]);
         #$remove = array_pop($commentfields);
         break;
      }
   }

   if ( $ev_elev_source === 'DEM' && abs($ev_lat) < 90 && abs($ev_lon) < 180 )
   {
      exec(escapeshellcmd('/ccg/DEM/ccg_elevation.pl').' -lat='.escapeshellarg($ev_lat).' -lon='.escapeshellarg($ev_lon), $elevation_str);

      list($ev_elev, $elevation_source) = split("\|", $elevation_str[0], 2);
   }
   else
   {
      $sitedescinfo = DB_GetSiteDesc($ev_code, $strat_abbr);

      $ev_elev = '-9999.99';
      for ($j=0; $j<count($sitedescinfo); $j++)
      {
         $tmpfields = split("\|", $sitedescinfo[$j]);

         if ( $tmpfields[0] == $proj_num )
         {
            $ev_elev = $tmpfields[4];
            break;
         }
      }
      $elevation_source = 'DB';
   }

   array_push($commentfields, "elev:$elevation_source");
   $ev_comment = implode("~+~", $commentfields);


   #
   # Update Event Details
   #
   $update = "UPDATE flask_event";
   $set = " SET site_num='${site_num}',date='${ev_date}'";
   $set = "${set},project_num='${proj_num}',strategy_num='1',dd='${dd}'";
   $set = "${set},time='${ev_time}',id='${ev_id}'";
   $set = "${set},me='${ev_meth}',lat='${ev_lat}'";
   $set = "${set},lon='${ev_lon}',alt='${ev_alt}'";
   $set = "${set},elev='${ev_elev}'";
   $set = "${set},comment='${ev_comment}'";
   $where = " WHERE num = '${ev_num}'";

   #echo "$update$set$where<BR>";
   $res = ccgg_insert($update.$set.$where);
   #$res = "";

   if (!empty($res)) { return(FALSE); }

   $params = array("ws","wd");
   for ( $i=0; $i<count($params); $i++ )
   {
      $ev_var = "ev_${params[$i]}";
      $param_num = DB_GetParamNum($params[$i]);

      $select = " SELECT COUNT(*)";
      $from = " FROM flask_data";
      $where = " WHERE event_num = '${ev_num}'";
      $and = " AND parameter_num = '${param_num}'";

      $sql = $select.$from.$where.$and;
      #echo "$sql<BR>";
      $res = ccgg_query($sql);

      if ( ${$ev_var} == "" )
      {
         if ($res[0] == '0') { continue; }
         else
         {
            # Delete entry
            $delete = " DELETE";
            $from = " FROM flask_data";
            $where = " WHERE event_num = '${ev_num}'";
            $and = " AND parameter_num = '${param_num}'";

            #echo "$delete$from$where$and<BR>";
            $res = ccgg_delete($delete.$from.$where.$and);
            #$res = '';
                                                                                          
            if (!empty($res)) { return(FALSE); }
         }
      }
      else
      {
         if ($res[0] == '0')
         {
            # Insert entry
            $insert = " INSERT INTO flask_data";
            $list = " (event_num, parameter_num, value, inst)";
            $values = " VALUES('${ev_num}','${param_num}','${$ev_var}', 'MA')";

            #echo "$insert$list$values<BR>";
            $res = ccgg_insert($insert.$list.$values);
            #$res = '';
                                                                                          
            if (!empty($res)) { return(FALSE); }
         }
         else
         {
            # Update entry
            $update = " UPDATE flask_data";
            $set = " SET value = '${$ev_var}'";
            $where = " WHERE event_num = '${ev_num}'";
            $and = " AND parameter_num = '${param_num}'";

            #echo "$update$set$where$and<BR>";
            $res = ccgg_insert($update.$set.$where.$and);
            #$res = '';

            if (!empty($res)) { return(FALSE); }
         }
      }
   }

   if ($status_num == 0) { return(TRUE); }
   #
   # Update Site and Path
   #
   $update = "UPDATE flask_inv";
   $set = " SET site_num='${site_num}',path='${ev_path}'";
   $where = " WHERE event_num='${ev_num}'";

   #echo "$update$set$where<BR>";
   $res = ccgg_insert($update.$set.$where);

   return(TRUE);
}
?>
