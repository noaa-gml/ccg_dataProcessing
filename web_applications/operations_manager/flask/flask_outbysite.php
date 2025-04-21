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

$strat_abbr = 'flask';
$strat_name = 'Flask';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_outbysite.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$siteinfo = DB_GetSiteList('',$strat_abbr);
$tmp = DB_GetFlasksOut();
$nout = count($tmp);

if ($code) { $atsiteinfo = DB_GetFlasksOutBySite($code); }

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global	$code;
global	$nout;
global	$siteinfo;
global	$atsiteinfo;
global	$nsubmits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Flasks Out By Site<BR>";
echo "<FONT class='MediumBlackN'>${nout} Flasks Checked Out (All Sites)</FONT></TD>";
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
echo "<TD width='22%' align='left' class='MediumBlackB'>Flasks - <FONT class='MediumBlueB'>${n}</FONT></TD>";

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
	echo sprintf("%3d %6s %12s %12s %15s\n",$j,$tmp[1],$tmp[0],$tmp[2],$tmp[3]);
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
# Function DB_GetFlasksOut ########################################################
#
function DB_GetFlasksOut()
{
	#
	# Get list of flasks checked out
	#
   $select = " SELECT flask_inv.id, gmd.site.code, flask_inv.date_out";
   $select = "${select}, project.abbr";
   $from = " FROM flask_inv, gmd.site, project";
   $where = " WHERE flask_inv.sample_status_num = '2'";
   $and = " AND gmd.site.num = flask_inv.site_num";
   $and = "${and} AND flask_inv.project_num = project.num";

	return ccgg_query($select.$from.$where.$and);
}
#
# Function DB_GetFlasksOutBySite ########################################################
#
function DB_GetFlasksOutBySite($code)
{
	#
	# Get list of flasks checked out by site
	#
        $select = " SELECT flask_inv.id, gmd.site.code, flask_inv.date_out";
        $select = "${select}, project.abbr";
        $from = " FROM flask_inv, gmd.site, project";
        $where = " WHERE flask_inv.sample_status_num = '2'";
	$and = " AND gmd.site.code='${code}'";
        $and = "${and} AND gmd.site.num = flask_inv.site_num";
        $and = "${and} AND flask_inv.project_num = project.num";

	$etc = " ORDER BY flask_inv.date_out DESC";

	return ccgg_query($select.$from.$where.$and.$etc);
}
?>
