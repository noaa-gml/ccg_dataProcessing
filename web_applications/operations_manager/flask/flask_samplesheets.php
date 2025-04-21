<?PHP

#include ("/var/www/html/om/om_inc.php");
#include ("/var/www/html/om/ccgglib_inc.php");
#include ("/var/www/html/om/omlib_inc.php");
require_once("../om_inc.php");
require_once("../ccgglib_inc.php");
require_once("../omlib_inc.php");

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

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_samplesheets.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$siteinfo = DB_GetAllSiteInfo('',$strat_abbr);

MainWorkArea();

if ($code) { PrepareSampleSheet($code, $proj_abbr, $strat_abbr); }
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global   $code;
global   $proj_abbr;
global   $siteinfo;
global   $nsubmits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_abbr' VALUE=${proj_abbr}>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Sample Sheets</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE align='center' col=2 width=80% border='0' cellpadding='8' cellspacing='8'>";
#
##############################
# Row 1: Column Headers
##############################
#
echo "<TR align='center'>";

echo "<TD align = 'center' class = 'MediumBlackB'>Site</FONT></TD>";

echo "</TR>";
#
##############################
# Row 2: Selection Window
##############################
#
echo "<TR>";
echo "<TD align = 'center'>";
echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='15' onClick = 'SampleSheetCB()'>";

for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp=split("\|",$siteinfo[$i]);
   $selected = ($tmp[1] == $code) ? 'SELECTED' : '';
   list($proj_name, $proj_abbr) = split("\|", DB_GetProjectInfo($tmp[12]));
   echo "<OPTION $selected VALUE='$tmp[1]~$proj_abbr'>${tmp[1]} ( ${proj_abbr} ) - ${tmp[2]}, ${tmp[3]}</OPTION>";
}
echo "</SELECT>";
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
?>
