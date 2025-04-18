<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$id = isset( $_POST['id'] ) ? $_POST['id'] : '';
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

if ($id) { DB_GetShipById($id,$shipinfo); }

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $id;
global $shipinfo;
global $nsubmits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Shipping History By Flask Id</TD>";
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
# Row 1: Column Headers
##############################
#
echo "<TR align='center'>";

$id = (empty($id)) ? 'None Selected' : $id;
echo "<TD width='33%' align='left' class='MediumBlackB'>Flask Id - <FONT class='MediumBlueB'>${id}</FONT></TD>";

$n = (empty($shipinfo)) ? '0' : count($shipinfo);
$n = ($n >= 400) ? "400 most recent" : $n;
echo "<TD width='22%' align='left' class='MediumBlackB'>Entries - <FONT class='MediumBlueB'>${n}</FONT></TD>";

echo "</TR>";
#
##############################
# Row 2: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";
echo "<B><INPUT TYPE='text' class='LargeSizeBlackTurquoiseB' NAME='id' onChange='submit()' SIZE=10></TD>";

JavaScriptCommand("document.mainform.id.focus()");

echo "<TD>";
echo "<TEXTAREA class='MediumBlackMonoN' NAME='list' ROWS='15' COLS='64'>";
for ($i=0,$j=1; $i<count($shipinfo); $i++,$j++)
{
   if ($i == 0) 
   { echo sprintf("%-8s %6s %15s %12s %12s %5s\n", 'id', 'site', 'project', 'date out', 'date in', 'days'); }
   $tmp=split("\|",$shipinfo[$i]);
   echo sprintf("%-8s %6s %15s %12s %12s %5s\n",$tmp[0],$tmp[1],$tmp[2],$tmp[3],$tmp[4],$tmp[5]);
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
# Function DB_GetShipById ########################################################
#
function DB_GetShipById($id,&$arr)
{
   #
   # Get list of flasks checked out by site
   #
   $select = "SELECT flask_shipping.id,gmd.site.code,project.abbr";
   $select = "${select},flask_shipping.date_out,flask_shipping.date_in";
   $select = "${select},TO_DAYS(flask_shipping.date_in) - TO_DAYS(flask_shipping.date_out) AS days";
   $from = " FROM flask_shipping,gmd.site,project";
   $where = " WHERE flask_shipping.id='${id}'";
   $and = " AND gmd.site.num=flask_shipping.site_num";
   $and = "${and} AND project.num=flask_shipping.project_num";
   $etc = " ORDER BY flask_shipping.date_out DESC,gmd.site.code ASC LIMIT 400";

   $arr = ccgg_query($select.$from.$where.$and.$etc);
}
?>
