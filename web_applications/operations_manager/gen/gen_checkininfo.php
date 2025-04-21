<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

global $ccgg_equip;
$id = isset( $_POST['id'] ) ? $_POST['id'] : '';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$invtype = isset( $_POST['invtype'] ) ? $_POST['invtype'] : '';

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$proj_num = isset( $_POST['proj_num'] ) ? $_POST['proj_num'] : '';
$fm_dateinuse = isset( $_POST['fm_dateinuse'] ) ? $_POST['fm_dateinuse'] : '';
$fm_dateoutuse = isset( $_POST['fm_dateoutuse'] ) ? $_POST['fm_dateoutuse'] : '';
$shipping_notes = isset( $_POST['shipping_notes'] ) ? $_POST['shipping_notes'] : '';

if ( empty($strat_abbr) ) { $strat_abbr = 'flask'; }
if ( empty($strat_name) ) { $strat_name = 'Flask'; }

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

$sql = "SELECT num, abbr FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr) = explode("|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_checkininfo.js'></SCRIPT>";

$unitinfo = DB_GetUnitInfo($id, $gen_type_num);
$unitinfo = $unitinfo[0];

#
# Show check out notes?
#
switch ( $gen_type_num )
{
   case '2':
      $shownotes = 1;
      break;
   default:
      $shownotes = 0;
}


switch ($task)
{
   case "Accept":
      DB_PreEventNum($id, $z);
      $err = '';
      if ($z != "") { $err = "${err}\\n${z}"; }
      if ($err != '')
      {
         JavaScriptAlert("${err}\\n\\nError checking unit in..");
         JavaScriptCommand("document.location='gen_checkin.php?invtype=${gen_type_abbr}'");
         break;
      }

      if (DB_SetEventNum($id))
      {
         list($code, $id, $date_out, $date_in, $comments, $proj_num, $date_inuse, $date_outuse, $shipping_notes, $event_num, $gen_status_num) = explode("|", $unitinfo);
         UpdateLog($log,"${id} checked in from ${code}");
      }
      else
      { JavaScriptAlert("Unable to check in ${id}"); }
      $selectedunits='';

      JavaScriptCommand("document.location='gen_checkin.php?invtype=${gen_type_abbr}&strat_name=${strat_name}&strat_abbr=${strat_abbr}'");
      break;
}


MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $gen_type_num;
global $gen_type_abbr;
global $unitinfo;

list($code, $id, $date_out, $date_in, $comments, $proj_num, $date_inuse, $date_outuse, $shipping_notes, $event_num, $gen_status_num) = explode("|", $unitinfo);

$today = date("Y-m-d");
$date_in = $today;

global $proj_num;
global $strat_abbr;
global $strat_name;
global $shownotes;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='id' VALUE='${id}'>";
echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE='${code}'>";
echo "<INPUT TYPE='HIDDEN' NAME='strat_abbr' VALUE='${strat_abbr}'>";
echo "<INPUT TYPE='HIDDEN' NAME='strat_name' VALUE='${strat_name}'>";
echo "<INPUT TYPE='HIDDEN' NAME='invtype' VALUE='${gen_type_abbr}'>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_num' VALUE='${proj_num}'>";
echo "<INPUT TYPE='HIDDEN' NAME='date_out' VALUE='${date_out}'>";
echo "<INPUT TYPE='HIDDEN' NAME='date_in' VALUE='${date_in}'>";

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
echo "<TABLE width=80% align='center' border='0' cellpadding='8' cellspacing='8' BORDER='1'>";
echo "<TR>";
echo "<TD>";

echo "<TABLE border='1' cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> ID</TD>";
echo "<TD align='left'>";
echo "<FONT class='LargeBlueB'>${id}</FONT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> Site</TD>";
echo "<TD align='left'>";
echo "<FONT class='MediumBlueB'>${code}</FONT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> Project</TD>";
echo "<TD align='left'>";
echo "<SELECT class='MediumBlackN' NAME='projlist' SIZE='1'>";
$sitedescinfo = DB_GetSiteDesc($code, $strat_abbr);
for ( $i=0; $i<count($sitedescinfo); $i++ )
{
   $tmp = explode("|", $sitedescinfo[$i]);
   $selected = ( $tmp[0] == $proj_num ) ? "SELECTED" : "";
   echo "<OPTION $selected VALUE='$tmp[0]'>$tmp[1]</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> Date Out</TD>";
echo "<TD align='left'>";
echo "<FONT class='MediumBlueB''>${date_out}</FONT>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> Date In Use [2000-12-31]</TD>";
echo "<TD align='left'>";
echo "<INPUT TYPE='text' NAME='fm_dateinuse' VALUE='${date_inuse}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=10 autocomplete='off'>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> Date Out of Use [2000-12-31]</TD>";
echo "<TD align='left'>";
echo "<INPUT TYPE='text' NAME='fm_dateoutuse' VALUE='${date_outuse}'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' 
class='MediumBlackN' SIZE=10 MAXLENGTH=10 autocomplete='off'></TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='MediumBlackN'> Date In</TD>";
echo "<TD align='left'>";
echo "<FONT class='MediumBlueB'>${date_in}</FONT>";
echo "</TD>";
echo "</TR>";
if ( $shownotes )
{
   echo "<TR>";
   echo "<TD align='left' class='MediumBlackN'>Reason for Return</TD>";
   echo "<TD align='left'>";
   echo "<TEXTAREA class='MediumBlackN' name='shipping_notes' cols=40 rows=3 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
   echo $shipping_notes;
   echo "</TEXTAREA></TD>";
   echo "</TR>";
}
else
{
   echo "<INPUT TYPE='HIDDEN' NAME='shipping_notes' VALUE=''>";
}
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD></TR>";
echo "</TABLE>";

echo "<TABLE cellspacing='2' cellpadding='2' align='center'>";

echo "<TR>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='submit' class='Btn' NAME='task' value='Accept'
onClick='if (AcceptCB()) return true; else return false;'>";
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
# Function DB_GetUnitInfo #########################################
#
function DB_GetUnitInfo($id, $gen_type_num)
{
   global $ccgg_equip;

   #
   # Get list of units that require event information
   #
   $select = " SELECT t1.code, t2.id";
   $select = "${select}, t2.date_out, t2.date_in";
   $select = "${select}, t2.comments, t2.project_num";
   $select = "${select}, t2.date_inuse, t2.date_outuse";
   $select = "${select}, t2.notes, t2.event_num";
   $select = "${select}, t2.gen_status_num";
   $from = " FROM gmd.site as t1, ${ccgg_equip}.gen_inv as t2";
   $where = " WHERE t2.gen_type_num = '${gen_type_num}'";
   $and = " AND t2.id = '${id}'";
   $and = "${and} AND t1.num = t2.site_num";

   #echo "$select$from$where$and<BR>";
   return ccgg_query($select.$from.$where.$and);
}
#
# Function DB_PreEventNum ########################################################
#
function DB_PreEventNum($id,&$err)
{
   global $ccgg_equip;
   global $gen_type_num;

   $err = "";
   #
   # Is event description still required?
   #
   $select = "SELECT id";
   $from = " FROM ${ccgg_equip}.gen_inv";
   $where =" WHERE id='${id}'";
   $and = " AND event_num = '0'";
   $and = "${and} AND gen_type_num = '${gen_type_num}'";
   $and = "${and} AND gen_status_num = '3'";

   $res = ccgg_query($select.$from.$where.$and);

   $n = count($res);
   if ($n == 0) { $err = "${id} event description is no longer required"; }
}
#
# Function DB_SetEventNum ########################################################
#
function DB_SetEventNum($id)
{
   global $ccgg_equip;
   global $gen_type_num;
   global $fm_dateinuse;
   global $fm_dateoutuse;
   global $shipping_notes;
   global $proj_num;
   global $shownotes;

   $today = date("Y-m-d");

   #
   # Check the units in
   #
   $update = " UPDATE ${ccgg_equip}.gen_inv";
   $set = " SET event_num = '1'";
   $set = "${set}, date_inuse = '${fm_dateinuse}'";
   $set = "${set}, date_outuse = '${fm_dateoutuse}'";
   $set = "${set}, date_in = '${today}'";
   $set = "${set}, gen_status_num = '1'";
   if ( $shownotes )
   { $set = "${set}, notes = '".mysql_real_escape_string($shipping_notes)."'"; }
   $where = " WHERE id = '${id}'";
   $and = " AND gen_type_num = '${gen_type_num}'";

   #echo "$update$set$where$and<BR>";
   $res = ccgg_insert($update.$set.$where.$and);
   #$res = "";

   if (!empty($res)) { return(FALSE); }

   #
   # If checking a unit in, then copy the information to gen_shipping
   #
   $select = "SELECT site_num, project_num, date_out, date_inuse, date_outuse";
   $select = "${select}, date_in, notes ";
   $from = "FROM ${ccgg_equip}.gen_inv ";
   $where = "WHERE id = '${id}'";
   $and = " AND gen_type_num = '${gen_type_num}'";

   $dateinfo = ccgg_query($select.$from.$where.$and);
   $tmp = explode("|",$dateinfo[0]);

   $insert = "INSERT INTO ${ccgg_equip}.gen_shipping ";
   $values = "VALUES ('${id}','${gen_type_num}','${tmp[0]}','${tmp[1]}','${tmp[2]}','${tmp[3]}','${tmp[4]}','${tmp[5]}','".mysql_real_escape_string($tmp[6])."')";
   #echo "$insert$values<BR>";
   $res2 = ccgg_insert($insert.$values);
   #$res2 = "";
   if (!empty($res2)) { return(FALSE); }

   return(TRUE);
}
?>
