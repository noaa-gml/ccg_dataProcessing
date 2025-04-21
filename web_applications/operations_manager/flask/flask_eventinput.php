<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");
include ("/var/www/html/inc/dbutils/dbutils.php");
db_connect();#For jlib db functions

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$path = isset( $_POST['path'] ) ? $_POST['path'] : '';
$proj_num = isset( $_POST['proj_num'] ) ? $_POST['proj_num'] : '';
$selectedflasks = isset( $_POST['selectedflasks'] ) ? $_POST['selectedflasks'] : '';
$fm_date = isset( $_POST['fm_date'] ) ? $_POST['fm_date'] : '';
$fm_time = isset( $_POST['fm_time'] ) ? $_POST['fm_time'] : '';
$fm_method = isset( $_POST['fm_method'] ) ? $_POST['fm_method'] : '';
$fm_ws = isset( $_POST['fm_ws'] ) ? $_POST['fm_ws'] : '';
$fm_wd = isset( $_POST['fm_wd'] ) ? $_POST['fm_wd'] : '';
$fm_lat = isset( $_POST['fm_lat'] ) ? $_POST['fm_lat'] : '';
$fm_lat_units = isset( $_POST['fm_lat_units'] ) ? $_POST['fm_lat_units'] : '';
$fm_lon = isset( $_POST['fm_lon'] ) ? $_POST['fm_lon'] : '';
$fm_lon_units = isset( $_POST['fm_lon_units'] ) ? $_POST['fm_lon_units'] : '';
$fm_alt = isset( $_POST['fm_alt'] ) ? $_POST['fm_alt'] : '';
$fm_elev_source = isset( $_POST['fm_elev_source'] ) ? $_POST['fm_elev_source'] : '';
$fm_comment = isset( $_POST['fm_comment'] ) ? $_POST['fm_comment'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';
$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_eventinput.js'></SCRIPT>";

switch ($task)
{
   case "Accept":
   case "Discard":
   #
   # Do selected flasks still need event information?
   #
   $precheckflaskinfo = (empty($selectedflasks)) ? '' : explode('~',$selectedflasks);

   $postcheckflaskinfo = array();
   for ($i=0,$err=''; $i<count($precheckflaskinfo); $i++)
   {
      $field=split("\|",$precheckflaskinfo[$i]);
      DB_PreEventNum($field[0],$field[1],$z);
      if ($z != "") { $err = "${err}\\n${z}"; }
      else { $postcheckflaskinfo[] = $precheckflaskinfo[$i]; }
   }
   if ($err != '')
   {
      JavaScriptAlert("${err}\\n\\nAssigning Event Number(s) Aborted.");
      $selectedflasks = implode('~',$postcheckflaskinfo);
      break;
   }

   #
   # Assign event numbers
   #

   # Store the original comment
   $original_fm_comment = $fm_comment;
   for ($i=0; $i<count($postcheckflaskinfo); $i++)
   {
      $field=split("\|",$postcheckflaskinfo[$i]);

      if ($task == 'Discard')
      {
         if (DB_FlaskToPrep($field[1]))
         {
            UpdateLog($log,"${field[1]} returned to Prep Room");
         }
         else
         { JavaScriptAlert("Failed trying to return ${field[1]} to Prep Room"); }

         continue;
      }

      # Determine the elevation based on the DEM or from the database
      # based on what the user passed in
      if ( $fm_elev_source === 'DEM' && abs($fm_lat) < 90 && abs($fm_lon) < 180 )
      {
         exec(escapeshellcmd('/ccg/DEM/ccg_elevation.pl').' -lat='.escapeshellarg($fm_lat).' -lon='.escapeshellarg($fm_lon), $elevation_str);

         list($fm_elev, $elevation_source) = split("\|", $elevation_str[0], 2);
      }
      else
      {
         $sitedescinfo = DB_GetSiteDesc($field[0], $strat_abbr);

         $fm_elev = '-9999.99';
         for ($j=0; $j<count($sitedescinfo); $j++)
         {
            $tmpfields = split("\|", $sitedescinfo[$j]);

            if ( $tmpfields[0] == $proj_num )
            {
               $fm_elev = $tmpfields[4];
               break;
            }
         }
         $elevation_source = 'DB';
      }

      # Add elevation source to the comment
      if ( $original_fm_comment == '' )
      { $fm_comment = 'elev:'.$elevation_source; }
      else
      { $fm_comment = $original_fm_comment.'~+~elev:'.$elevation_source; }

      if (DB_SetEventNum($field[0],$field[1]))
      {
         UpdateLog($log,"Event number assigned to ${field[1]}");
      }
      else
      { JavaScriptAlert("Unable to assign event number for ${field[1]}"); }
   }
   $selectedflasks='';
   break;
}
DB_GetFlasksNeedingEventDetails($availableflaskinfo);
$projinfo = DB_GetAllProjectInfo();
MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $path;
global $proj_num;
global $strat_abbr;
global $projinfo;
global $availableflaskinfo;
global $selectedflasks;
global $fm_date,$fm_time,$fm_method,$fm_ws,$fm_wd;
global $fm_lat,$fm_lon,$fm_alt,$fm_elev_source,$fm_comment;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='path' VALUE='${path}'>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_num' VALUE='${proj_num}'>";
echo "<INPUT TYPE='HIDDEN' NAME='selectedflasks' VALUE='${selectedflasks}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_date' VALUE='${fm_date}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_time' VALUE='${fm_time}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_method' VALUE='${fm_method}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_ws' VALUE='${fm_ws}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_wd' VALUE='${fm_wd}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_lat' VALUE='${fm_lat}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_lon' VALUE='${fm_lon}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_alt' VALUE='${fm_alt}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_elev_source' VALUE='${fm_elev_source}'>";
echo "<INPUT TYPE='HIDDEN' NAME='last_comment' VALUE='${fm_comment}'>";

$selectedflaskinfo = (empty($selectedflasks)) ? '' : explode('~',$selectedflasks);

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Event Description</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE col=3 width=80% align='center' border='0' cellpadding='8' cellspacing='8' BORDER='1'>";
#
##############################
# Row 1: Column Headers
##############################
#
echo "<TR align='center'>";

$n = (empty($availableflaskinfo)) ? '0' : count($availableflaskinfo);
echo "<TD width='22%' align='left' class='MediumBlackB'>Available - <FONT class='MediumBlueB'>${n}</FONT></TD>";

$n = (empty($selectedflaskinfo)) ? '0' : count($selectedflaskinfo);
echo "<TD width='22%' align='left' class='MediumBlackB'>Selected - ";
echo "<FONT class='MediumBlueB' id='selectedflaskcnt'>${n}</FONT></TD>";

echo "<TD width='100%' align='left' class='MediumBlackB'>Notes</TD>";

echo "</TR>";
#
##############################
# Row 2: Selection Windows
##############################
#
echo "<TR>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='8' onClick='AvailableListCB()'>";

$sitelist = array();
for ($i=0; $i<count($availableflaskinfo); $i++)
{
   $tmp=split("\|",$availableflaskinfo[$i]);
   $str = "${tmp[0]} ${tmp[1]}";
   $value = htmlentities($availableflaskinfo[$i], ENT_QUOTES, 'UTF-8');
   $value = str_replace("\r\n","<BR>",$value);
   echo "<OPTION VALUE='$value'>$str</OPTION>";
   $zz = htmlentities($tmp[5], ENT_QUOTES, 'UTF-8');
   $zz = str_replace("\r\n","<BR>",$zz);
   JavaScriptCommand("flask_notes[$i] = \"${zz}\"");
   $zz = htmlentities($tmp[11], ENT_QUOTES, 'UTF-8');
   $zz = str_replace("\r\n","<BR>",$zz);
   JavaScriptCommand("meas_notes[$i] = \"${zz}\"");

   $sitelist[$i] = $tmp[0];
}
echo "</SELECT>";
echo "</TD>";

#
# Create the site description information array
#
sort($sitelist);
$sitelist = array_values(array_unique($sitelist));
for ($i=0; $i<count($sitelist); $i++)
{
   $code = $sitelist[$i];
   JavaScriptCommand("sitedesc['$code'] = new Array()");

   $sitedescinfo = DB_GetSiteDesc($code, $strat_abbr);
   #print_r($sitedescinfo);

   for ($j=0; $j<count($sitedescinfo); $j++)
   { JavaScriptCommand("sitedesc['$code'][$j] = \"$sitedescinfo[$j]\""); }
}

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='selectedlist' SIZE='8'>";

#for ($i=0; $i<count($selectedflaskinfo); $i++)
#{
#   if ($selectedflaskinfo[$i] == '') continue;
#   $tmp=split("\|",$selectedflaskinfo[$i]);
#   echo "<OPTION VALUE=$selectedflaskinfo[$i]>${tmp[0]} ${tmp[1]}</OPTION>";
#}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<FONT class='MediumRedB' id='meas_notes'></FONT><BR><BR>";
echo "<FONT class='MediumRedB' id='flask_notes'></FONT>";
echo "</TD>";

echo "</TR>";
echo "</TABLE>";

echo "<TABLE border='1' width='80%' cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";
echo "<TD align='left'>";
#
# Event Details
#
echo "<TABLE cellspacing='2' cellpadding='2' align='center'>";
echo "<tr align='right'><td colspan='2'>".DB_getSubSiteSelect()."<br><br></td></tr>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Date [09Feb2004]</TD>";
echo "<TD><INPUT TYPE='text' NAME='fm_date'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=9 autocomplete='off'></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Time [0143]</TD>";
echo "<TD><INPUT TYPE='text' NAME='fm_time'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=4 autocomplete='off'></TD>";
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
echo "<TD align='right' class='MediumBlackN'> Method [D]</TD>";
echo "<TD><INPUT TYPE='text' NAME='fm_method'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=1 autocomplete='off'></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Wind Speed [-99.9]</TD>";
echo "<TD><INPUT TYPE='text' NAME='fm_ws'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=5 autocomplete='off'></TD>";
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
echo "<TD><INPUT TYPE='text' NAME='fm_wd'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=3 autocomplete='off'></TD>";
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
echo "<TD><INPUT TYPE='text' NAME='fm_lat'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=8 autocomplete='off'></TD>";
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
echo "<INPUT TYPE='radio' NAME='fm_lat_units' VALUE='dec' CHECKED></INPUT>";
echo "</TD>";
echo "<TD>";
echo "Decimal&nbsp;[-99.9999]";
echo "</TD>";
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='radio' NAME='fm_lat_units' VALUE='deg'></INPUT>";
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
echo "<TD><INPUT TYPE='text' NAME='fm_lon'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=9 autocomplete='off'></TD>";
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
echo "<INPUT TYPE='radio' NAME='fm_lon_units' VALUE='dec' CHECKED></INPUT>";
echo "</TD>";
echo "<TD>";
echo "Decimal&nbsp;[-999.9999]</INPUT>";
echo "</TD>";
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='radio' NAME='fm_lon_units' VALUE='deg'></INPUT>";
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
echo "<TD><INPUT TYPE='text' NAME='fm_alt'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=8 autocomplete='off'></TD>";
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
echo "<TD><SELECT class='MediumBlackN' NAME='fm_elev_source'
SIZE='1'>";
echo "<OPTION VALUE='DB'>Database</OPTION>";
echo "<OPTION VALUE='DEM'>DEM</OPTION>";
echo "</SELECT>";
echo "</TR>";
echo "<TR>";
echo "<TD align='right' class='MediumBlackN'> Comment</TD>";
echo "<TD><INPUT TYPE='text' NAME='fm_comment'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
class='MediumBlackN' SIZE=10 MAXLENGTH=128 autocomplete='off'></TD>";
echo "</TABLE>";
echo "</TD>";

echo "<TD align='center'>";
echo "<FONT class='MediumBlackB'>Project:</FONT><BR>";
echo "<SELECT class='MediumBlackN' NAME='projlist' SIZE='1' onChange='ProjListCB(this)'>";
echo "</SELECT>";
echo "</TD>";
#
# Measurement Path
#
$sys_defi = DB_GetSystemDefi();

echo "<TD align='right'>";

echo "<TABLE cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";
echo "<TD></TD>";
echo "<TD class = 'MediumBlackB'>Measurement Path</TD>";
echo "</TR>";

$n = count($sys_defi);
JavaScriptCommand("npaths = \"${n}\"");

$dummy = str_repeat("-",30);

for ($i=0,$j=1; $i<$n; $i++,$j++)
{
   echo "<TR>";
   echo "<TD align = 'right'><FONT class='MediumBlackN'>${j}. </FONT></TD>";
   echo "<TD align = 'left'>";
   echo "<SELECT class='MediumBlackN' NAME='path${j}' SIZE='1'>";
      echo "<OPTION VALUE=''}>$dummy</OPTION>";
      for ($ii=0; $ii<$n; $ii++)
      {
         $field=split("\|",$sys_defi[$ii]);
         echo "<OPTION VALUE=${sys_defi[$ii]}>${field[1]}</OPTION>";
      }
   echo "</SELECT>";
   echo "</TD>";
   echo "</TR>";
}

echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE width='40%' cellspacing='2' cellpadding='2' align='center'>";

echo "<TR>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='submit' class='Btn' NAME='task' value='Accept'
onClick='if (AcceptCB()) return true; else return false;'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='submit' class='Btn' NAME='task' value='Discard'
onClick='if (DiscardCB()) return true; else return false;'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' NAME='task' value='Clear' onClick='ClearCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' NAME='task' value='Recall' onClick='RecallCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' NAME='task' value='Defaults' onClick='SetDefaultsCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' NAME='task' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";

echo "</TR>";
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetFlasksNeedingEventDetails #########################################
#
function DB_GetFlasksNeedingEventDetails(&$availableflaskinfo)
{
   #
   # Get list of flasks that require event information
   #
   $select = "SELECT gmd.site.code,flask_inv.id";
   $select = "${select},flask_inv.date_out,flask_inv.date_in";
   $select = "${select},flask_inv.path,flask_inv.comments";
   $select = "${select},gmd.site.lat,gmd.site.lon,gmd.site.elev";
   $select = "${select},gmd.site.lst2utc,site_desc.method";
   $select = "${select},site_shipping.meas_comments,site_desc.intake_ht";
   $select = "${select},flask_inv.project_num";
   $from = " FROM flask_inv,gmd.site,site_shipping,site_desc";
   $where = " WHERE flask_inv.event_num='0'";
   $and = " AND flask_inv.sample_status_num='3'";
   $and = "${and} AND gmd.site.num=flask_inv.site_num";
   $and = "${and} AND site_shipping.site_num=flask_inv.site_num";
   $and = "${and} AND site_desc.site_num=flask_inv.site_num";
   $and = "${and} AND site_shipping.project_num = site_desc.project_num";
   $and = "${and} AND site_shipping.strategy_num = site_desc.strategy_num";
   $and = "${and} AND site_desc.project_num = flask_inv.project_num";
   $and = "${and} AND site_shipping.strategy_num='1'";
   $and = "${and} AND site_desc.strategy_num='1'";

   $availableflaskinfo = ccgg_query($select.$from.$where.$and);
   sort($availableflaskinfo);
}
#
# Function DB_PreEventNum ########################################################
#
function DB_PreEventNum($code,$id,&$err)
{
global   $fm_date;
global   $fm_time;
global   $fm_method;
global   $fm_ws;
global   $fm_wd;
global   $fm_lat;
global   $fm_lon;
global   $fm_alt;
global   $fm_comment;
global   $path;

   $err = "";
   #
   # Is event description still required?
   #
   $select = "SELECT flask_inv.id";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.id='${id}'";
   $and = " AND flask_inv.event_num='0'";
   $and = "${and} AND flask_inv.sample_status_num='3'";

   $res = ccgg_query($select.$from.$where.$and);

   $n = count($res);
   if ($n == 0) { $err = "${id} event description is no longer required"; }
}
#
# Function DB_SetEventNum ########################################################
#
function DB_SetEventNum($code,$id)
{
global $fm_date;
global $fm_time;
global $fm_method;
global $fm_ws;
global $fm_wd;
global $fm_lat;
global $fm_lat_units;
global $fm_lon;
global $fm_lon_units;
global $fm_alt;
global $fm_elev;
global $fm_comment;
global $path;
global $proj_num;

   #
   # Prepare date/time/code
   #
   $yr = substr($fm_date,5,4);
   $dy = substr($fm_date,0,2);
   $mo = GetMonthNum(substr($fm_date,2,3));
   $date = "${yr}-${mo}-${dy}";

   if ( ! preg_match('/^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$/', $date) )
   {
      JavaScriptAlert("Problem with event date.");
      return(FALSE);
   }

   #
   # Reset Default time from 9999 to 12:34:56
   # June 2006 - kam, pml
   #
   if (!(strncmp($fm_time, "99", 2)))
   {
      $hr = "12";
      $mn = "34";
      $sc = "56";
   }
   else
   {
      $hr = substr($fm_time,0,2);
      $mn = substr($fm_time,2,2);
      $sc = "00";
   }
   $time = "{$hr}:${mn}:${sc}";

   if ( ! preg_match('/^[0-9]{1,2}:[0-9]{2}:[0-9]{2}$/', $time) )
   {
      JavaScriptAlert("Problem with event time.");
      return(FALSE);
   }

   $dd = date2dec($yr,$mo,$dy,$hr,$mn);
   $meth = strtoupper($fm_method);
   $site_num = DB_GetSiteNum($code);
   #
   # Convert lat/lon to decimal, if it is in degrees
   #
   if ( $fm_lat_units == "deg" )
   { $lat = Deg2Dec($fm_lat); }
   else { $lat = $fm_lat; }

   if ( $fm_lon_units == "deg" )
   { $lon = Deg2Dec($fm_lon); }
   else { $lon = $fm_lon; }
   #
   # If event information already exists do not
   # assign another event number
   #
   $select = "SELECT COUNT(*)";
   $from = " FROM flask_event";
   $where =" WHERE id='${id}'";
   $and = " AND date='${date}'";
   $and = "${and} AND time='${time}'";
   $and = "${and} AND me='${fm_method}'";
   $and = "${and} AND site_num='${site_num}'";
   $and = "${and} AND project_num='${proj_num}'";
   $and = "${and} AND strategy_num='1'";

   $res = ccgg_query($select.$from.$where.$and);

   if ($res[0] == '0')
   {
      #
      # Assign Event Number
      #
      $insert = "INSERT INTO flask_event";
      $list = " (num,site_num,project_num,strategy_num,date,time,dd,id,me,lat,lon,alt,elev,comment)";
      $values = " VALUES(NULL,'${site_num}','${proj_num}','1','${date}','${time}','${dd}','${id}','${meth}'";
      $values = "${values},'${lat}','${lon}','${fm_alt}','${fm_elev}'";
      $values = "${values},'${fm_comment}')";

      #echo "$insert$list$values<BR>";
      $res = ccgg_insert($insert.$list.$values);
      #$res = "";

      if (!empty($res)) { return(FALSE); }
   }
   else JavaScriptAlert("Event details already exist in DB.\\nNew event number not assigned.");

   #
   # Get assigned event number
   #
   $select = "SELECT num";
   $from = " FROM flask_event";
   $where =" WHERE id='${id}'";
   $and = " AND date='${date}'";
   $and = "${and} AND time='${time}'";
   $and = "${and} AND me='${fm_method}'";
   $and = "${and} AND site_num='${site_num}'";
   $and = "${and} AND project_num='${proj_num}'";
   $and = "${and} AND strategy_num='1'";

   $res = ccgg_query($select.$from.$where.$and);
   $ev_num = (isset($res[0])) ? $res[0] : 0;
   if ($ev_num == 0)
   {
      JavaScriptAlert("Problem retrieving event number in DB_SetEventNum");
      return(FALSE);
   }
   #
   # Insert/Update wind speed and wind direction information
   #
   $params = array("ws", "wd");
   for ( $i=0; $i<count($params); $i++ )
   {
      $fm_var = "fm_${params[$i]}";
      if ( $params[$i] == 'ws' && ${$fm_var} == '-99.9' ) { continue; }
      if ( $params[$i] == 'wd' && ${$fm_var} == '999' ) { continue; }

      $param_num = DB_GetParamNum($params[$i]);

      $select = " SELECT COUNT(*)";
      $from = " FROM flask_data";
      $where = " WHERE event_num = '$ev_num'";
      $and = " AND parameter_num = '$param_num'";

      $sql = $select.$from.$where.$and;
      $res = ccgg_query($sql);

      if ($res[0] == '0')
      {
         # INSERT
         $insert = " INSERT INTO flask_data";
         $list = " (event_num, parameter_num, value, inst)";
         $values = " VALUES('${ev_num}','${param_num}','${$fm_var}', 'MA')";

         $sql = $insert.$list.$values;
         #echo "$sql<BR>";
         $res = ccgg_insert($sql);
         #$res = "";

         if (!empty($res)) { return(FALSE); }
      }
      else
      {
         # UPDATE
         $update = " UPDATE flask_data";
         $set = " SET value = '${$fm_var}'";
         $where = " WHERE event_num = '$ev_num'";
         $and = " AND parameter_num = '$param_num'";

         $sql = $update.$set.$where.$and;
         #echo "$sql<BR>";
         $res = ccgg_insert($sql);
         #$res = "";

         if (!empty($res)) { return(FALSE); }
      }
   }


   #
   # Indicate that flask is now in analysis loop
   #
   $update = "UPDATE flask_inv";
   $set = " SET path='${path}',event_num='${ev_num}'";
   $where = " WHERE id='${id}'";

   #echo "$update$set$where<BR>";
   $res = ccgg_insert($update.$set.$where);
   #$res = "";

   if (!empty($res)) { return(FALSE); }

   return(TRUE);
}
#
# Function DB_FlaskToPrep ########################################################
#
function DB_FlaskToPrep($id)
{
   #
   # Indicate flask is in prep room
   #
   $update = "UPDATE flask_inv";
   $set = " SET sample_status_num='1'";
   $where = " WHERE id='${id}'";

   #echo "$update$set$where<BR>";
   $res = ccgg_insert($update.$set.$where);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return TRUE;
}
function DB_getSubSiteSelect(){
//THIS needs to handle elevation/alt.  see dev notes
    bldsql_init();
    bldsql_from("site_subsites s");
    bldsql_col("num as value");
    bldsql_col("description as display_name");
    bldsql_col("lat");
    bldsql_col("lon");
    bldsql_col("alt");#NEED to select elev and overhaul interface to allow entry (3rd option)
    bldsql_col("me");
    bldsql_col("comment");

    $a=doquery();
    $inp=getSelect($a,'subsite','',array('onChangeFunc'=>'subsite_selected','addBlankRow'=>true));
    $html="<div><span>Sub Site</span>$inp</div><script>
        const dataArray = " . json_encode($a) . ";
        function subsite_selected(id) {
            // Search for the object with the matching value
            const val=document.getElementById(id).value;
            const result = dataArray.find(item => item.value === val);

            if (result) {
                var f = document.mainform;
                //f.fm_method.value = result.me;
                f.fm_lat.value = result.lat;
                f.fm_lon.value = result.lon;
                setRadioValue(f.fm_lat_units, 'dec');
                setRadioValue(f.fm_lon_units, 'dec');
                setSelectValue(f.fm_elev_source, 'DEM');
                f.fm_alt.value = result.alt;
                console.log('selected subsite:',result);
            } else {
                console.log('Value not found:',val);
            }
        }


    </script>";
    return $html;

}
?>
