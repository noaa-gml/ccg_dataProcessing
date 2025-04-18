<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$proj_abbr = isset( $_POST['proj_abbr'] ) ? $_POST['proj_abbr'] : '';
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';

if ( empty($proj_abbr) ) { $proj_abbr = "ccg_surface"; }

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_shipbysite.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$siteinfo = DB_GetSiteList($proj_abbr,$strat_abbr);
$projinfo = DB_GetAllProjectInfo();

if ($code) { $shipinfo = DB_GetShipBySiteProj($code, $proj_abbr); }

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $code;
global $proj_abbr;
global $siteinfo;
global $projinfo;
global $shipinfo;
global $nsubmits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_abbr' VALUE=${proj_abbr}>";
echo "<INPUT type='HIDDEN' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Shipping History By Site</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE align='center' col=2 width=90% border='0' cellpadding='8' cellspacing='8'>";
#
##############################
# Row 1: Project Selection
##############################
#
echo "<TR align='right'>";
echo "<TD align='left' colspan=2>"; echo "<FONT class='MediumBlackB'>Project - </FONT>";
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
#
##############################
# Row 2: Column Headers
##############################
#
echo "<TR align='center'>";

$code = (empty($code)) ? 'None Selected' : $code;
echo "<TD width='33%' align='left' class='MediumBlackB'>Site - <FONT class='MediumBlueB'>${code}</FONT></TD>";

$n = (empty($shipinfo)) ? '0' : count($shipinfo);
$n = ($n >= 400) ? "400 most recent" : $n;
echo "<TD width='22%' align='left' class='MediumBlackB'>Entries - <FONT class='MediumBlueB'>${n}</FONT></TD>";

echo "</TR>";
#
##############################
# Row 3: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='15' onClick='SiteListCB()'>";

for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp=split("\|",$siteinfo[$i]);
   $selected = ($tmp[1] == $code) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=$tmp[1]>${tmp[1]} - ${tmp[2]}, ${tmp[3]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<TEXTAREA class='MediumBlackMonoN' NAME='atsitelist' ROWS='15' COLS='45'>";
for ($i=0,$j=1; $i<count($shipinfo); $i++,$j++)
{
   if (!($i))
   { echo sprintf("%-4s %9s %11s %11s %5s\n", 'code', 'id', 'date out', 'date in', 'days'); }

   $tmp=split("\|",$shipinfo[$i]);
   echo sprintf("%-4s %9s %11s %11s %5s\n",$tmp[0],$tmp[1],$tmp[2],$tmp[3],$tmp[4]);
}
echo "</TEXTAREA>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE width='10%' align='center'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' NAME='Task' value='Back' onClick='history.go(${nsubmits});'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetShipBySite ########################################################
#
function DB_GetShipBySiteProj($code, $proj_abbr)
{
   #
   # Get list of flasks checked out by site
   #
   $select = "SELECT gmd.site.code,flask_shipping.id";
   $select = "${select},flask_shipping.date_out,flask_shipping.date_in";
   $select = "${select},TO_DAYS(flask_shipping.date_in) - TO_DAYS(flask_shipping.date_out) AS days";
   $from = " FROM flask_shipping,gmd.site,project";
   $where = " WHERE gmd.site.code='${code}'";
   $and = " AND project.abbr = '${proj_abbr}'";
   $and = "${and} AND gmd.site.num=flask_shipping.site_num";
   $and = "${and} AND project.num=flask_shipping.project_num";
   $etc = " ORDER BY flask_shipping.date_in DESC,flask_shipping.id ASC LIMIT 400";

   return ccgg_query($select.$from.$where.$and.$etc);
}
?>
