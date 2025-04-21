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
$selectedunits = isset( $_POST['selectedunits'] ) ? $_POST['selectedunits'] : '';

$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

if ( empty($strat_abbr) ) { $strat_abbr = 'flask'; }
if ( empty($strat_name) ) { $strat_name = 'Flask'; }

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

$sql = "SELECT num, abbr FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr) = explode("|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();

echo "<SCRIPT language='JavaScript' src='gen_checkin.js'></SCRIPT>";

$siteinfo = DB_GetAllSiteInfo('', $strat_abbr);
$projinfo = DB_GetAllProjectInfo();
if ($code)
{
   DB_GetUnitsAtSite($availableunitinfo,$gen_type_num,$code);
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
global $strat_abbr;
global $strat_name;
global $siteinfo;
global $projinfo;
global $availableunitinfo;
global $chkout_date;
global $selectedunits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='id' VALUE=''>";
echo "<INPUT TYPE='HIDDEN' NAME='invtype' VALUE='${gen_type_abbr}'>";
echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='strat_abbr' VALUE=${strat_abbr}>";
echo "<INPUT TYPE='HIDDEN' NAME='strat_name' VALUE=${strat_name}>";
echo "<INPUT TYPE='HIDDEN' NAME='selectedunits' VALUE='${selectedunits}'>";
echo "<INPUT TYPE='HIDDEN' NAME='gen_type_abbr' VALUE='${gen_type_abbr}'>";

$selectedunitinfo = (empty($selectedunits)) ? array() : explode('~',$selectedunits);

echo "<TABLE border='0' cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";

echo "<TD align='center' class='XLargeBlueB'>$gen_type_abbr Check In</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE width=100% border='0' cellpadding='0' cellspacing='0'>";

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

$sitearr = array();
for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp=split("\|",$siteinfo[$i]);
   array_push($sitearr,"${tmp[0]}|${tmp[1]}|${tmp[2]}|${tmp[3]}");
}

$sitearr = array_values(array_unique($sitearr));

for ($i=0; $i<count($sitearr); $i++)
{
   $tmp=split("\|",$sitearr[$i]);
   $selected = ($tmp[1] == $code) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=$tmp[1]>${tmp[1]} - ${tmp[2]}, ${tmp[3]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='10' onClick='AvailableListCB()'>";

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
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='UnitScanCB()'>";
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
echo "<B><INPUT TYPE='button' class='Btn' value='Check In' onClick='OkayCB()'>";
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
# Function DB_GetUnitsAtSite ########################################################
#
function DB_GetUnitsAtSite(&$availableunitinfo,$gen_type_num,$code)
{
   global $ccgg_equip;

   #
   # Get list of units at site
   #
   $select = " SELECT t1.id, t1.comments";
   $from = " FROM ${ccgg_equip}.gen_inv as t1, gmd.site as t2";
   $where = " WHERE t2.code='${code}'";
   $and = " AND t2.num = t1.site_num";
   $and = "${and} AND t1.gen_type_num='${gen_type_num}' ";
   $and = "${and} AND t1.gen_status_num='3' ";
   $order = "ORDER by t1.id";

   $availableunitinfo = ccgg_query($select.$from.$where.$and.$order);
}
?>
