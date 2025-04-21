<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
	JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
	exit;
}

$code = isset( $_GET['code'] ) ? $_GET['code'] : '';
$proj_abbr = isset( $_GET['proj_abbr'] ) ? $_GET['proj_abbr'] : '';
$id = isset( $_GET['id'] ) ? $_GET['id'] : '';
$plan = isset( $_GET['plan'] ) ? $_GET['plan'] : '';
$template = isset( $_GET['template'] ) ? $_GET['template'] : '';

$strat_abbr = 'pfp';
$strat_name = 'PFP';
$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

$pathinfo = DB_GetDefPath($code,$proj_abbr,$strat_abbr);
list($pathno,$pathname) = split("\|",$pathinfo);

$user = GetUser();


MakeHTMLtop("Operation Manager","PFP Sample Plan Form");
ShowForm();

#JavaScriptAlert('Print PFP Sample Sheet from Web browser.');

exit;
#
# Function MakeHTMLtop ########################################################
#
function MakeHTMLtop($Title,$Heading)
{
global	$bg_color;
global	$table;

print<<<HTML
	<HTML>
	<HEAD>
	<TITLE>$Title - $Heading</TITLE>
	<LINK REL=STYLESHEET TYPE="text/css" HREF="/om/om_style.css">
	</HEAD>
	<BODY BGCOLOR="white">
HTML;
}
#
# Function ShowForm ###############################################
#
function ShowForm()
{
global $project;
global $pathname;
global $user;
global $code;
global $id;
global $plan;
global $template;
global $proj_abbr;

$project_status_num='1';

$smallpad = str_repeat("_",6);
$mediumpad = str_repeat("_",12);
$largepad = str_repeat("_",45);
$xlargepad = str_repeat("_",70);
$today = date("D M j G:i:s T Y");

echo "<FORM NAME='mainform' METHOD=POST>";

echo "<TABLE WIDTH='100%' CELLPADDING='3' BORDER='0' CELLSPACING='2'";

echo "<TR>";
echo "<TD align='left' rowspan='2'>";

echo "<IMG alt='NOAA CMDL CCGG Logo' WIDTH='75' HEIGHT='75'
	CCGG' src='../images/iadv_noaalogo.png' border='0'>";
echo "</TD>";

echo "<TD align='left' colspan='2'>";

echo "<FONT class='LargeBlackB'>GREENHOUSE GAS REFERENCE NETWORK</FONT><BR>";
echo "</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD style='width:60%;' align='left' valign='top'>";
echo "<FONT class='MediumBlackB'>Global Monitoring Laboratory</FONT><BR>";
if ( $proj_abbr == 'ccg_surface' )
{
   echo "<FONT class='MediumBlackN'>Email:&nbsp;ccggpfp@noaa.gov Ph:&nbsp;+1 720 475 3117</FONT>";
}
else
{
   echo "<FONT class='MediumBlackN'>Email:&nbsp;ccggpfp@noaa.gov Ph:&nbsp;+1 720 475 3117</FONT>";
}
echo "</TD>";

echo "<TD align='right' valign='bottom'>";
echo "<FONT class='LargeBlueB'>AUTOMATED AIR SAMPLES</FONT><BR>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<HR>";

echo "<TABLE cellspacing=2 cellpadding=2 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Site Code</TD>";
echo "<TD align='left' class='MediumBlueB'>$code</TD>";
if ( $proj_abbr == 'ccg_surface' )echo "<TD align='left' class='SmallBlackB'>PCP #</TD>";
else echo "<TD align='left' class='SmallBlackB'>Tail #</TD>";
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
if ( $proj_abbr == 'ccg_surface' )
{
   echo "<TD align='left' class='SmallBlackB'>Install Date</TD>";
}
else
{
   echo "<TD align='left' class='SmallBlackB'>Flight Date</TD>";
}
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Project</TD>";
echo "<TD align='left' class='MediumBlueB'>$proj_abbr</TD>";
if ( $proj_abbr == 'ccg_aircraft' ){
    echo "<TD align='left' class='SmallBlackB'>Pilot Name</TD>";
    echo "<TD align='left' class='SmallBlackB'>${mediumpad}${mediumpad}</TD>";
}else echo "<td colspan='2'></td>";

if ( $proj_abbr == 'ccg_surface' )
{
   echo "<TD align='left' class='SmallBlackB'>Remove Date</TD>";
}
else
{
   echo "<TD align='left' class='SmallBlackB'>Departure Time</TD>";
}
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "</TR>";

echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>PFP #</TD>";
echo "<TD align='left' class='MediumBlueB'>$id</TD>";
echo "<TD align='left' class='SmallBlackB'>Leak check</TD>";
echo "<TD align='left' class='SmallBlackB'>$smallpad torr $smallpad min</TD>";

if ( $proj_abbr != 'ccg_surface' )
{
   echo "<TD align='left' class='SmallBlackB'>Return Time</TD>";
   echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
}
echo "</TR>";
if($proj_abbr=='ccg_aircraft'){
echo "<tr><td colspan='2'></td><TD colspan='4'><span class='SmallBlackB'> Extinguisher present on flight: Halon-1211 or Halotron (circle one)<br></td></tr>";}
echo "<TR><TD>";
echo "</TD></TR>";
echo "</TABLE>";

echo "<TABLE align='center' width='100%' border='1' cellpadding='0' cellspacing='0'>";
echo "<COLGROUP>";
echo "<THEAD align='center'><TR>";
echo "<TR class='SmallBlackB'><TH width='10%'>Sample<BR>No.";

echo "<TH width='15%'>Nominal Alt<BR>(ft asl)";
echo "<TH width='45%'>Comments/Errors/Deviations";
echo "<TH width='30%'>Measurement Path";
echo "<TBODY>";

$f = str_replace("/sample/","/measurement/",$template);
if ( file_exists($f) && filesize($f) > 0 )
{
   if (!($fp = fopen($f,"r")))
   { JavaScriptAlert("Unable to open ${f}.  Get help."); }
   $measplan = fread($fp, filesize($f));
   $measplan = split("\n",$measplan);
   fclose($fp);
}
else
{
   $measplan = array("");
}

for ( $i=0; $i<count($measplan); $i++ )
{
   $tmp = split(" +",$measplan[$i]);
   $index = $tmp[0];
   for ( $j=1; $j<count($tmp); $j++ )
   {
      if ( substr($tmp[$j],0,1) == "-" ) { continue; }
      $measarr[$index] = ( empty($measarr[$index]) ) ? "$tmp[$j]" : "$measarr[$index] - $tmp[$j]";
   }
}

$arr = explode('~',$plan);
for ($i=0; $i<count($arr); $i++)
{
	echo "<TR>";

	$field = preg_split("/\|/",trim($arr[$i]));
        $field[0] = ( isset($field[0] ) ) ? $field[0] : '';
        $field[1] = ( isset($field[1] ) ) ? $field[1] : '';

	echo "<TD align='center' valign='center' class='SmallBlackN'>${field[0]}</TD>";
	echo "<TD align='center' valign='center' class='SmallBlackN'>${field[1]}</TD>";
	echo "<TD align='left' valign='center' class='SmallBlackN'>&nbsp;<BR>&nbsp;</TD>";
	echo "<TD align='left' valign='center' class='SmallBlackN'>";
        if ( isset ($measarr[intval($field[0])] ) ) { echo $measarr[intval($field[0])]; }
        echo "</TD>";

	echo "</TR>";
}
echo "</TABLE>";

echo "<TABLE align='center' width='100%' border='0' cellpadding='2' cellspacing='2'>";
echo "<TR><TD align='center'><span class='MediumBlackB'> ";
echo "</TD></TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>ADDITIONAL COMMENTS</TD>";
echo "</TR>";
echo "<TR align='center'><TD class='SmallBlackN'><HR NOSHADE SIZE=1></TD></TR>";
echo "<TR align='center'><TD class='SmallBlackN'><HR NOSHADE SIZE=1></TD></TR>";

#echo "<TD align='center' class='SmallBlackB'>PLEASE DO NOT WRITE BELOW THIS LINE</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE cellspacing=2 cellpadding=2 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD>";

echo "<TABLE cellspacing=2 cellpadding=2 width='80%' align='left'>";
echo "<TR align='center'>";
echo "<TD align='right' colspan=3 class='SmallBlackB'>Initials</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Date Prepared</TD>";
echo "<TD align='left' class='SmallBlueB'>$today</TD>";
echo "<TD align='right' class='SmallBlueB'>$user</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Date Shipped</TD>";
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "<TD align='right' class='SmallBlackB'>$smallpad</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Date Checked In</TD>";
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "<TD align='right' class='SmallBlackB'>$smallpad</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Prefilled?</TD>";
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "<TD align='right' class='SmallBlackB'>$smallpad</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Valves Closed?</TD>";
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "<TD align='right' class='SmallBlackB'>$smallpad</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='SmallBlackB'>Evac. Pressure</TD>";
echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
echo "<TD align='right' class='SmallBlackB'>$smallpad</TD>";
echo "</TR>";
$tmp = explode('-',$pathname);
for ($i=0; $i<count($tmp); $i++)
{
   echo "<TR align='center'>";
   echo "<TD align='left' class='SmallBlackB'>${tmp[$i]} Analysis</TD>";
   echo "<TD align='left' class='SmallBlackB'>$mediumpad</TD>";
   echo "<TD align='right' class='SmallBlackB'>$smallpad</TD>";
   echo "</TR>";
}
echo "<TR align='center'>";
echo "<TD align='left' valign='top' class='SmallBlackB'>Comments</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "<TD>";

echo "<TABLE cellspacing=2 cellpadding=2 width='100%' align='right'>";
echo "<TR align='center'>";
echo "<TD align='left' class='MediumBlackB'>Site</TD>";
echo "<TD align='left' class='LargeBlueB'>$code</TD>";
echo "</TR>";
echo "<TR align='center'>";
echo "<TD align='left' class='MediumBlackB'>PFP #</TD>";
echo "<TD align='left' class='LargeBlueB'>$id</TD>";
echo "</TR>";
echo "<TR valign='top'>";
echo "<TD align='left' class='MediumBlackB'><U>ROUTING</U></TD>";
echo "<TD align='left' class='LargeBlueB'>";
$tmp = explode('-',$pathname);
for ($i=0; $i<count($tmp); $i++) { echo "${tmp[$i]}<BR>"; }
echo "</TD>";
echo "</TR>";
echo "</TABLE>";


echo "</FORM>";
echo "</BODY>";
echo "</HTML>";
}
?>
