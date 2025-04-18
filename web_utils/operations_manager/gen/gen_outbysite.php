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
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';

$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

if ( empty($strat_abbr) ) { $strat_abbr = 'flask'; }
if ( empty($strat_name) ) { $strat_name = 'Flask'; }

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_outbysite.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$siteinfo = DB_GetSiteList('',$strat_abbr);
$tmp = DB_GetUnitsOut();
$nout = count($tmp);

if ($code) { $atsiteinfo = DB_GetUnitsOutBySite($code); }

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
global $nout;
global $siteinfo;
global $atsiteinfo;
global $nsubmits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr}s Out By Site<BR>";
echo "<FONT class='MediumBlackN'>${nout} ${gen_type_abbr}s Checked Out (All Sites)</FONT></TD>";
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

$code = (empty($code)) ? 'None Selected' : $code;
echo "<TD width='33%' align='left' class='MediumBlackB'>Site - <FONT class='MediumBlueB'>${code}</FONT></TD>";

$n = (empty($atsiteinfo)) ? '0' : count($atsiteinfo);
echo "<TD width='22%' align='left' class='MediumBlackB'>${gen_type_abbr}s - <FONT class='MediumBlueB'>${n}</FONT></TD>";

echo "</TR>";
#
##############################
# Row 2: Selection Windows
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
echo "<TEXTAREA class='MediumBlackMonoN' NAME='atsitelist' ROWS='15' COLS='55'>";
for ($i=0,$j=1; $i<count($atsiteinfo); $i++,$j++)
{
   if (!($i)) { echo sprintf("%3s %6s %12s %12s %15s\n", '#', 'code', 'id', 'date out', 'project'); }
   $tmp=split("\|",$atsiteinfo[$i]);
   echo sprintf("%3d %6s %12s %12s %15s\n",$j,$tmp[0],$tmp[1],$tmp[2],$tmp[3]);
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
# Function DB_GetUnitsOut ########################################################
#
function DB_GetUnitsOut()
{
   global $ccgg_equip;
   global $gen_type_num;

   #
   # Get list of units checked out
   #
   $select = " SELECT t2.code, t1.id, t1.date_out, t3.abbr";
   $from = " FROM ${ccgg_equip}.gen_inv AS t1, gmd.site AS t2, gmd.project AS t3";
   $where = " WHERE t1.gen_status_num = '3' and t1.gen_type_num = '$gen_type_num'";
   $and = " AND t1.site_num = t2.num AND t1.project_num = t3.num";

   return ccgg_query($select.$from.$where.$and);
}
#
# Function DB_GetUnitsOutBySite ########################################################
#
function DB_GetUnitsOutBySite($code)
{
   global $ccgg_equip;
   global $gen_type_num;

   #
   # Get list of units checked out by site
   #
   $select = " SELECT t2.code, t1.id, t1.date_out, t3.abbr";
   $from = " FROM ${ccgg_equip}.gen_inv AS t1, gmd.site AS t2, gmd.project AS t3";
   $where = " WHERE t1.gen_status_num = '3' and t1.gen_type_num = '$gen_type_num'";
   $and = " AND t2.code='${code}'";
   $and = "${and} AND t1.site_num = t2.num AND t1.project_num = t3.num";

   $etc = " ORDER BY t1.date_out DESC";

   return ccgg_query($select.$from.$where.$and.$etc);
}
?>
