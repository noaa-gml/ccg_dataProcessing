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
$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$proj_abbr = isset( $_POST['proj_abbr'] ) ? $_POST['proj_abbr'] : '';
$shipping_notes = isset( $_POST['shipping_notes'] ) ? $_POST['shipping_notes'] : '';
$selectedunits = isset( $_POST['selectedunits'] ) ? $_POST['selectedunits'] : '';

$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

if ( empty($strat_abbr) ) { $strat_abbr = 'flask'; }
if ( empty($strat_name) ) { $strat_name = 'Flask'; }

if ( empty($proj_abbr) )
{
   switch($strat_abbr)
   {
      case 'pfp':
         $proj_abbr = "ccg_aircraft";
         break;
      case 'flask':
      default:
         $proj_abbr = "ccg_surface";
         break;
   }
}

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();

echo "<SCRIPT language='JavaScript' src='gen_checkout.js'></SCRIPT>";

#if (!empty($task))
#{
#   $selectedunits = split("-", $selectedunits);
#}

switch ( $task )
{
   case "chkout":
      #
      # Check to make sure that the unit is status 1: "Available" before we
      # allow it to be checked in
      #
      if ( DB_PreCheck($selectedunits,"Available") )
      {
         #JavaScriptAlert($selectedunits);
         if ( !(DB_Checkout($selectedunits,$code, $proj_abbr,$shipping_notes) ) )
         {
            $tmparr = explode("~", $selectedunits);
            for ($i=0; $i<count($tmparr); $i++ )
            {
               JavaScriptAlert("Unable to Check Out ".$tmparr[$i]);
            }
         }
         else
         {
            $tmparr = explode("~", $selectedunits);
            for ($i=0; $i<count($tmparr); $i++ )
            {
               UpdateLog($log,"${tmparr[$i]} checked out to ${code} ${proj_abbr}");
            }
         }
         $code='';
         $task='';
         $selectedunits='';
      }
      break;
}

$siteinfo = DB_GetAllSiteInfo($proj_abbr, $strat_abbr);
$projinfo = DB_GetAllProjectInfo();
if ($code)
{
   DB_GetAvailableUnits($availableunitinfo,$gen_type_num);
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
global $code;
global $proj_abbr;
global $siteinfo;
global $projinfo;
global $availableunitinfo;
global $chkout_date;
global $selectedunits;
global $task;

#
# Can multiple items be selected?
#
switch ( $gen_type_num )
{
#   case '2':
#      $multiselect = 0;
#      break;
   default:
      $multiselect = 0;
}

#
# Show check out notes?
#
switch ( $gen_type_num )
{
   case '1':
      $shownotes = 1;
      break;
   default:
      $shownotes = 0;
}

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_abbr' VALUE=${proj_abbr}>";
echo "<INPUT TYPE='HIDDEN' NAME='task' VALUE=${task}>";
echo "<INPUT TYPE='HIDDEN' NAME='selectedunits' VALUE='${selectedunits}'>";

$selectedunitinfo = (empty($selectedunits)) ? array() : explode('~',$selectedunits);

echo "<TABLE border='0' cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";

echo "<TD align='center' class='XLargeBlueB'>$gen_type_abbr Check Out</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE width=100% border='0' cellpadding='0' cellspacing='0'>";

#
##############################
# Row 1: Project Selection
##############################
#
echo "<TR align='right'>";
echo "<TD align='left' colspan=2>";
echo "<TABLE width=100% border='0' cellpadding='8' cellspacing='8'>";
echo "<TR>";
echo "<TD>";
echo "<FONT class='MediumBlackB'>Project - </FONT>";
echo "<SELECT class='MediumBlackN' NAME='projlist' SIZE='1' onChange='ProjListCB()'>";
for ($i=0; $i<count($projinfo); $i++)
{
   $tmp=split("\|",$projinfo[$i]);
   $selected = ($tmp[2] == $proj_abbr) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=$tmp[2]>${tmp[2]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";

echo "<TR><TD width=60%>";
#
##############################
# Define Left Table
##############################
#
echo "<TABLE width=100% border='0' cellpadding='8' cellspacing='8'>";
echo "<TR align='center'>";

#
##############################
# Define Column Titles
##############################
#
$code = (empty($code)) ? 'None Selected' : $code;
echo "<TD width='60%' align='left' class='MediumBlackB'>Site - <FONT class='MediumBlueB'>${code}</FONT></TD>";

$n = (empty($availableunitinfo)) ? '0' : count($availableunitinfo);
echo "<TD width='20%' align='left' class='MediumBlackB'>Available - <FONT class='MediumBlueB'>${n}</FONT></TD>";

#$n = (empty($selectedunitinfo)) ? '0' : count($selectedunitinfo);
$n = count($selectedunitinfo);
echo "<TD width='20%' align='left' class='MediumBlackB'>Selected - ";
echo "<FONT class='MediumBlueB' id='selectedunitcnt'>${n}</FONT></TD>";

echo "</TR>";

#
##############################
# Row 2: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='10' onClick='SiteListCB()'>";

for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp=split("\|",$siteinfo[$i]);
   $selected = ($tmp[1] == $code) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=$tmp[1]>${tmp[1]} - ${tmp[2]}, ${tmp[3]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='10' onClick='AvailableListCB(\"$multiselect\",\"$shownotes\")'>";

for ($i=0; $i<count($availableunitinfo); $i++)
{
   $tmp=split("\|",$availableunitinfo[$i]);
   $z = $tmp[0];
   if ($selectedunitinfo) { $z = (in_array($z,$selectedunitinfo)) ? "${z}*" : $z; }
   echo "<OPTION VALUE='${z}'>${z}</OPTION>";
   $zz = str_replace("\r\n","<BR>",$tmp[1]);
   $zz = htmlentities($zz, ENT_QUOTES, 'UTF-8');
   $zz = mysql_real_escape_string($zz);
   JavaScriptCommand("unit_notes[$i] = '${zz}'");
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='selectedlist' SIZE='10'>";

for ($i=0; $i<count($selectedunitinfo); $i++)
{
   if ($selectedunitinfo[$i] == '') continue;
   echo "<OPTION VALUE=$selectedunitinfo[$i]>${selectedunitinfo[$i]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";

#
##############################
# Row 3: Scan fields
##############################
#
echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='sitescan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='SiteScanCB()'>";
echo "</TD>";

echo "<TD>";
echo "<INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='unitscan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='UnitScanCB(\"$multiselect\")'>";
echo "</TD>";
echo "<TR>";
echo "<TD colspan=3>";
#
##############################
# Row 4: Table for action buttons
##############################
#
echo "<TABLE border='0' width='50%' cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Check Out' onClick='OkayCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "<TD valign='top' align='left' width=42%>";

#
##############################
# Right Table for notes
##############################
#
echo "<TABLE width=100% border='0' cellpadding='8' cellspacing='8'>";
if ( $shownotes )
{
   echo "<TR><TD align='left' class='MediumBlackB'>Project Notes</TD></TR>";
   echo "<TR><TD>";
   echo "<TEXTAREA class='MediumBlackN' name='shipping_notes' cols=40 rows=3 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' DISABLED>";
   echo "</TEXTAREA></TD>";
   echo "</TD></TR>";
}
else
{
   echo "<INPUT TYPE='HIDDEN' NAME='shipping_notes' VALUE=''>";
}
echo "<TR><TD align='left' class='MediumBlackB'>Notes</TD></TR>";
echo "<TR><TD><FONT class='MediumRedB' id='unit_notes'></FONT></TD></TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";

if (count($availableunitinfo)) { JavaScriptCommand("document.mainform.unitscan.focus()"); }
else { JavaScriptCommand("document.mainform.sitescan.focus()"); }

echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetAvailableUnits ########################################################
#
function DB_GetAvailableUnits(&$availableunitinfo,$gen_type_num)
{
   global $ccgg_equip;

   #
   # Get list of units available for shipping
   #
   $select = " SELECT id, comments ";
   $from = " FROM ${ccgg_equip}.gen_inv ";
   $where = " WHERE gen_status_num='2' AND gen_type_num = '$gen_type_num'";
   $order = "ORDER BY id";

   $availableunitinfo = ccgg_query($select.$from.$where.$order);
}
#
# Function DB_PreCheckin ########################################################
#
function DB_PreCheck($selectedunits,$name)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Make sure that what the user wants to do is still available to be done.
   # If, for example, the user opens the page and selects an unit to be checked out
   # and then another user opens the page and retires the unit, we want to
   # notify the first user that the unit cannot be checked out.
   #
   $units = split("~",$selectedunits);

   for ( $i = 0; $i < count($units); $i++ )
   {
      $select = " SELECT gen_status.name";
      $from = " FROM ${ccgg_equip}.gen_inv LEFT JOIN ${ccgg_equip}.gen_status ON";
      $from = "${from} ( gen_inv.gen_status_num = gen_status.num )";
      $where = " WHERE gen_inv.id = '$units[$i]'";
      $and = " AND gen_inv.gen_type_num = '${gen_type_num}'";

      $chk_status = ccgg_query($select.$from.$where.$and);

      $tmp = split("\|",$chk_status[0]);
      if ( $tmp[0] != $name )
      {
         JavaScriptAlert($selectedunits." cannot be checked in\\nbecause it is ".$tmp[0]);
         return(FALSE);
      }
   }
   return(TRUE);
}
#
# Function DB_Checkout ########################################################
#
function DB_Checkout($selectedunits,$code,$proj_abbr,$shipping_notes)
{
   global $ccgg_equip;
   global $gen_type_num;

   #
   # Check out the unit
   #
   $site_num = DB_GetSiteNum($code);

   $proj_num = DB_GetProjectNum($proj_abbr);

   $today = date("Y-m-d");

   $units = split("~",$selectedunits);

   for ( $i = 0; $i < count($units); $i++ )
   { 
      #
      # Checking unit out
      #
      $update = " UPDATE ${ccgg_equip}.gen_inv";
      $set = " SET gen_status_num = '3'";
      $set = "${set}, date_out = '$today'";
      $set = "${set}, date_inuse = '0000-00-00'";
      $set = "${set}, date_outuse = '0000-00-00'";
      $set = "${set}, date_in = '0000-00-00'";
      $set = "${set}, site_num = '$site_num'";
      $set = "${set}, project_num = '${proj_num}'";
      $set = "${set}, event_num = '0'";
      $set = "${set}, notes = '".mysql_real_escape_string($shipping_notes)."'";
      $where = " WHERE id = '$units[$i]'";
      $and = " AND gen_type_num = '${gen_type_num}'";

      #echo "$update$set$where$and<BR>";
      $res = ccgg_insert($update.$set.$where.$and);
      #$res = "";
      if (!empty($res)) { return(FALSE); }
   }

   return(TRUE);
}
?>
