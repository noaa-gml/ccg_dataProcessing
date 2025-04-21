<?PHP
#
# SAMPLE SHEET - ENGLISH
#
## JWM - 9/16 - Rewrote html template logic to have a single template with translation table.
#  See flask_ss_template1.php for english version of these variables.

$siteLabel="SITE CODE";
#flask
$flaskLabel="FLASK #";
$pumpLabel="pump";
$returnLabel="return";

#date & time
$dayLabel="DAY";
$monthLabel="MONTH";
$yearLabel="YEAR";
$hourLabel="HOUR";
$minuteLabel="MINUTE";
$universalTimeLabel="UNIVERSAL TIME (UTC)";
$localStdLabel="LOCAL STANDARD TIME (LST)";
$daylightSavingsLabel="DAYLIGHT SAVINGS TIME (DST)";
$noteLabel="USE SAME TIME ZONE FOR BOTH DATE & TIME";

#Lat, Lon & Alt
$latLabel="LATITUDE";
$lonLabel="LONGITUDE";
$sampleHeightLabel="SAMPLE DEPTH";

#wind
$windSpeedLabel="WIND SPEED";
$relWindSpeedLabel="REL. WIND SPEED";
$metersPerSecLabel="m/s";
$knotsLabel="KNOTS";
$mphLabel="MPH";

$windDirectionLabel="WIND DIRECTION";
$relWindDirectionLabel="REL. WIND DIRECTION";
$degreeLabel="(DEG)";
$obsWindDirectionLabel="OBS. WIND DIRECTION";

#Voltage,flow rage & pump pressure
$pad=str_repeat("_",12);#Some translations need this in the middle..
$voltageLabel="VOLTAGE $pad";
$flowRateLabel="FLOW RATE $pad";
$pumpPressureLabel="PUMP PRESSURE $pad";

#Remarks, observer, inventory & contact
$remarksLabel="REMARKS";
$observerLabel="OBSERVER";
$inventoryLabel="# OF UNSAMPLED BOXES";
$emailLabel="E-MAIL";

#LEDs
$LEDInstructionLabel="PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED";

#Shipping box
$doNotWriteInThisBoxLabel="DO NOT WRITE IN THIS BOX";

require_once("flask_ss_template.php");
exit;

/*OLD VERSION
include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$path = isset( $_GET['path'] ) ? $_GET['path'] : '';
$code = isset( $_GET['code'] ) ? $_GET['code'] : '';
$method = isset( $_GET['method'] ) ? $_GET['method'] : '';
$position = isset( $_GET['position'] ) ? $_GET['position'] : '';

$abbr = 'flask';
$name = 'Flask';
$yr = date("Y");
$user = GetUser();

MakeHTMLtop("Operation Manager","Flask Sampling Form");
ShowForm();

exit;
#
# Function MakeHTMLtop ########################################################
#
function MakeHTMLtop($Title,$Heading)
{
global $bg_color;
global $table;

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
global $path;
global $user;
global $code;
global $method;
global $position;

$smallpad = str_repeat("_",8);
$mediumpad = str_repeat("_",12);
$largepad = str_repeat("_",20);
$today = date("D M j, Y");

echo "<FORM NAME='mainform' METHOD=POST>";
#
#########################################
# Banner
#########################################
#
echo "<TABLE width = '100%' align = 'center' cellpadding = 4 border = '0' cellspacing = 2>";
echo "<TR>";
echo "<TD align='center'>";

echo "<IMG alt='NOAA CMDL CCGG Logo' WIDTH='75' HEIGHT='75'
   CCGG' src='../images/noaalogo.jpg' border='0'>";
echo "</TD>";

echo "<TD align='center'>";

echo "<FONT class='MediumBlackN'>ESRL Global Monitoring Division</FONT><BR>";
echo "<FONT class='LargeBlackB'>CARBON CYCLE</FONT><BR><BR>";
echo "<FONT class='MediumBlueB'>COOPERATIVE GLOBAL AIR SAMPLING NETWORK</FONT><BR>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
#########################################
# Sample Sheet Container
#########################################
#
echo "<TABLE cellspacing=2 cellpadding=2 width='100%' align='center' border='0'>";
echo "<TR valign = 'top' align='center'>";
echo "<TD align = 'left'>";
#
#########################################
# Left Container
#########################################
#
echo "<TABLE cellspacing = 2 cellpadding = 2 width='100%' align='center'  border='0'>";
#
#########################################
# Code
#########################################
#
echo "<TR>";
echo "<TD align = 'left'>";
echo "<TABLE width = '75%' align = 'left' cellspacing = 2 cellpadding = 2>";
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>SITE CODE</TD>";
echo "<TD align='left' class='XLargeBlueB'>${code}</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD></TR>";
#
#########################################
# Id
#########################################
#
echo "<TR><TD>";
echo "</TD></TR>";
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>FLASK # ${largepad}(pump)</TD>";
echo "</TR>";

echo "<TR><TD>";
echo "</TD></TR>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>FLASK # ${largepad}(return)</TD>";
echo "</TR>";

if (strstr($position, 'id'))
{
   echo "<TR><TD>";
   echo "</TD></TR>";

   echo "<TR>";
   echo "<TD align='left' class='SmallBlackB'>FLASK # ${largepad}</TD>";
   echo "</TR>";
}
echo "<tr><td align='left' class='SmallBlackB'>PSU # ${largepad}</td></tr>";
#
#########################################
# Date
#########################################
#
echo "<TR>";
echo "<TD align='left'>";

echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "</TD>";
echo "<TD align='left'>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "</TD>";
echo "<TD align='left'>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "</TD>";
echo "<TR>";
echo "<TD align='center' class = 'SmallBlackB'>DAY</TD>";
echo "<TD align='center' class = 'SmallBlackB'>MONTH</TD>";
echo "<TD align='center' class = 'SmallBlackB'>YEAR</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
#
#########################################
# Time
#########################################
#
echo "<TR>";
echo "<TD align='left'>";

echo "<TABLE>";

echo "<TR>";
echo "<TD align='left'>";

echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "</TD>";
echo "<TD align='left'>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "<IMG src = 'square.gif' height = 20 width = 20>";
echo "</TD>";
echo "<TD align='left'>";

echo "<TR>";
echo "<TD align='center' class = 'SmallBlackB'>HOUR</TD>";
echo "<TD align='center' class = 'SmallBlackB'>MINUTE</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "<TD align='left'>";

echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>UNIVERSAL TIME (UTC)</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>LOCAL STANDARD TIME (LST)</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>DAYLIGHT SAVINGS TIME (DST)</TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

if (!strcasecmp($code, "nwr"))
{
   echo "<TR>";
   echo "<TD align = 'left'>";

   HATS($smallpad);

   echo "</TD>";
   echo "</TR>";
}

#
#########################################
# Wind Speed
#########################################
#
$ws = 'WIND SPEED';
if (strstr($position, 'lat') || strstr($position, 'lon')) { $ws = "REL. ${ws}"; }

echo "<TR>";
echo "<TD align='left'>";

echo "<TABLE>";

echo "<TR>";
echo "<TD align='left'>";


echo "<TABLE cellspacing = 1 cellpadding = 1>";
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>${ws} ${mediumpad}</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";

echo "<TD align='left'>";
echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>m/s</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>KNOTS</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>MPH</TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
#########################################
# Wind Direction
#########################################
#
$wd = 'WIND DIRECTION';
if (strstr($position, 'lat') || strstr($position, 'lon')) { $wd = "REL. ${wd}"; }
echo "<TR>";
echo "<TD align='left'>";

echo "<TABLE>";

echo "<TR>";
echo "<TD align='left'>";

echo "<TABLE cellspacing = 1 cellpadding = 1>";
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>${wd} ${mediumpad}</TD>";
echo "<TD align='left' class='LessTinyBlackB'>(DEG)</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

if (strstr($position, 'obswd'))
{
   echo "<TR>";
   echo "<TD align='left'>";

   echo "<TABLE>";

   echo "<TR>";
   echo "<TD align='left'>";

   echo "<TABLE cellspacing = 1 cellpadding = 1>";
   echo "<TR>";
   echo "<TD align='left' class='SmallBlackB'>OBS. WIND DIRECTION ${mediumpad}</TD>";
   echo "<TD align='left' class='LessTinyBlackB'>(DEG)</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";
}

if (strstr($position, 'lat'))
{
   echo "<TR>";
   echo "<TD align = 'left'>";

   Latitude($mediumpad);

   echo "</TD>";
   echo "</TR>";
}

if (strstr($position, 'lon'))
{
   echo "<TR>";
   echo "<TD align = 'left'>";

   Longitude($mediumpad);

   echo "</TD>";
   echo "</TR>";
}

if (strstr($position, 'alt'))
{
   echo "<TR>";
   echo "<TD align = 'left'>";

   Altitude($mediumpad);

   echo "</TD>";
   echo "</TR>";
}

echo "<TR>";
echo "<TD>";

if ($method == 'P') { MethodP($mediumpad); }
if ($method == 'N') { MethodN($mediumpad); }
if ($method == 'D') { MethodD($mediumpad); }
if ($method == 'G') { MethodD($mediumpad); }

echo "</TD>";
echo "</TR>";

#
#########################################
# End of Left Container
#########################################
#Fairly certain these are superfilous.jwm
#echo "</TD>";
#echo "</TR>";
echo "</TABLE>";
#
#########################################
# Right Container
#########################################
#
echo "</TD>";
echo "<TD align='center'>";
echo "<FONT class = 'SmallBlackB'>DO NOT WRITE IN THIS BOX</FONT>";

echo "<TABLE bgcolor = '#EEEEEE' cellspacing = 2 border = 2 cellpadding = 2 width='100%' align='center'>";
echo "<TR>";
echo "<TD>";
#
#########################################
# Shipping/Receiving Container
#########################################
#

echo "<TABLE border = 0 cellspacing=2 cellpadding=2 width='100%' align='center'>";

echo "<TR><TD align = 'center' class = 'MediumBlackB'>SHIPPING and RECEIVING</TD></TR>";

echo "<TR>";
echo "<TD>";
echo "<TABLE width = '100%' cellpadding = 3 cellspacing = 3>";
echo "<TR align = 'left'>";
echo "<TD align='left' class='SmallBlackB'>SHIPPED</TD>";
echo "<TD class = 'SmallBlueB'>${today}</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>RECEIVED</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%'>";
echo "<TR>";
echo "<TD align = 'left' width = '35%' class='SmallBlackB'>REMARKS</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>";
echo "</TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "</TABLE>";
#
#########################################
# End of Shipping/Receiving Container
#########################################
#
echo "</TABLE>";
#
#########################################
# Shipping/Receiving Container
#########################################
#
echo "<TABLE border = 0 cellspacing = 2 cellpadding = 2 width = '100%' align = 'center'>";

echo "<TR><TD align = 'center' class = 'MediumBlackB'>SAMPLE ANALYSIS</TD></TR>";
#
#########################################
# Routing
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE cellspacing = 3 cellpadding = 3>";
echo "<TR>";
echo "<TD align='center' class='SmallBlackB'>SYSTEM</TD>";
echo "<TD align='center' class='SmallBlackB'>ANALYSIS DATE</TD>";
echo "<TD align='center' class='SmallBlackB'>INITIALS</TD>";
echo "</TR>";

echo "<TR><TD> </TD></TR>";

$tmp = explode('-',$path);

for ($i=0; $i<count($tmp); $i++)
{
   echo "<TR>";
   echo "<TH align='center' class='MediumBlueB'>${tmp[$i]}</TH>";
   echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
   echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
   echo "</TR>";
}
echo "</TABLE>";

echo "</TABLE>";
#
#########################################
# End of Shipping/Receiving Container
#########################################
#
echo "</TABLE>";
#


//Moving some items to the right for layout space savings.
echo "<br><br>
      <table width='100%'>";
#
#########################################
# Remarks
#########################################

echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%'>";
echo "<TR>";
echo "<TD align = 'left' width = '25%' class='SmallBlackB'>REMARKS</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
echo "</TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";

#
#########################################
# OBSERVER
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%'>";
echo "<TR>";
echo "<TD align = 'left' width = '25%' class='SmallBlackB'>OBSERVER</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
#
#########################################
# INVENTORY
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%'>";
echo "<TR>";
echo "<TD align = 'left' width = '55%' class='SmallBlackB'># OF UNSAMPLED BOXES</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
#
#########################################
# CONTACT US
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE width = '90%'>";
echo "<TR>";
echo "<TD align = 'left' class='SmallBlackB'>E-MAIL</TD>";
echo "<TD align = 'right' class = 'MediumBlackB'>ccggflask@noaa.gov</FONT></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</table>";

//
#########################################
# End of Right Container
#########################################
#
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
#########################################
# End of Sample Sheet Container
#########################################
#
echo "</TD>";
echo "</TR>";
echo "</TABLE>";


echo "</FORM>";
echo "</BODY>";
echo "</HTML>";
}

function MethodP($pad)
{
echo "<TABLE frame = 1 cellpadding = 3 cellspacing = 3 width = '100%'>";
#
#########################################
# Voltage
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>VOLTAGE ${pad} (V)</TD>";
echo "</TR>";
#
#########################################
# Flow Rate
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>FLOW RATE ${pad} (LPM)</TD>";
echo "</TR>";
#
#########################################
# Pump Pressure
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>PUMP PRESSURE ${pad} (PSI)</TD>";
echo "</TR>";

echo "</TABLE>";
}

function MethodN($pad)
{
echo "<TABLE frame = 1 cellpadding = 3 cellspacing = 3 width = '100%'>";
#
#########################################
# Voltage
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>VOLTAGE ${pad} (V)</TD>";
echo "</TR>";
#
#########################################
# Flow Rate
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>FLOW RATE ${pad} (LPM)</TD>";
echo "</TR>";
#
#########################################
# Pump Pressure
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>PUMP PRESSURE ${pad} (PSI)</TD>";
echo "</TR>";

echo "</TABLE>";
}

function MethodD($pad)
{
#new
echo "<TABLE frame = 1 cellpadding = 3 cellspacing = 3 width = '100%'>";
#
#########################################
# Voltage
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>VOLTAGE ${pad} (V)</TD>";
echo "</TR>";
#
#########################################
# Flow Rate
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>FLOW RATE ${pad} (LPM)</TD>";
echo "</TR>";
#
#########################################
# Pump Pressure
#########################################
#
echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>PUMP PRESSURE ${pad} (PSI)</TD>";
echo "</TR>";

echo "</TABLE>";

echo "<TABLE frame = 1 cellpadding = 3 cellspacing = 3 width = '100%'>";
#
#########################################
# LEDs
#########################################
#
echo "<TR>";
echo "<TD align='center' class='LessTinyBlackB'>PLEASE CHECK WHICH LAMPS WERE ON<BR>WHEN SAMPLE ENDED</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%'>";
echo "<TR>";
echo "<TD align='center' class='SmallBlackB'>SAMPLE</TD>";
echo "<TD align='center' class='SmallBlackB'>DRY</TD>";
echo "<TD align='center' class='SmallBlackB'>BATT.</TD>";
echo "<TD align='center' class='SmallBlackB'>TEMP.</TD>";
echo "<TD align='center' class='SmallBlackB'>LEAK</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD valign = 'center' align='center'>";
echo "<IMG src = 'square.gif' height = 20 width = 20></TD>";
echo "<TD valign = 'center' align='center'>";
echo "<IMG src = 'square.gif' height = 20 width = 20></TD>";
echo "<TD valign = 'center' align='center'>";
echo "<IMG src = 'square.gif' height = 20 width = 20></TD>";
echo "<TD valign = 'center' align='center'>";
echo "<IMG src = 'square.gif' height = 20 width = 20></TD>";
echo "<TD valign = 'center' align='center'>";
echo "<IMG src = 'square.gif' height = 20 width = 20></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
#
#########################################
# Final LED
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%'>";
echo "<TR><TD align='center' class='SmallBlackB'>GOOD SAMPLE/DONE</TD></TR>";
echo "<TR>";
echo "<TD valign = 'center' align='center'>";
echo "<IMG src = 'square.gif' height = 20 width = 20></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";

echo "</TABLE>";

}

function Latitude($pad)
{
echo "<TABLE cellspacing = 1 cellpadding = 1>";

echo "<TR>";

echo "<TD align='left' class='SmallBlackB'>LATITUDE ${pad}</TD>";

echo "<TD align='left'>";
echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>N</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>S</TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
}

function Longitude($pad)
{
echo "<TABLE cellspacing = 1 cellpadding = 1>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>LONGITUDE ${pad}</TD>";

echo "<TD align='left'>";
echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>W</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>E</TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
}

function Altitude($pad)
{
echo "<TABLE cellspacing = 1 cellpadding = 1>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>SAMPLE HEIGHT ${pad}</TD>";

echo "<TD align='left'>";
echo "<TABLE>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>ft</TD>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD align='left'>";
echo "<IMG src = 'circle.gif' height = 10 width = 10></TD>";
echo "<TD align='left' class = 'LessTinyBlackB'>m</TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
}

function HATS($pad)
{
echo "<TABLE frame = 1 width = '100%' cellspacing = 1 cellpadding = 1>";

echo "<TR>";
echo "<TD align='center' class='MediumBlackB'> ** HATS SAMPLING **</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD align='center'>";

echo "<TABLE border = 0 width = '100%' cellspacing = 3 cellpadding = 3>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>FLASK # ${pad}</TD>";
echo "<TD align='left' class='SmallBlackB'>FLASK # ${pad}</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>TIME ${pad} UTC</TD>";
echo "<TD align='left' class='SmallBlackB'>TIME ${pad} UTC</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>AIR TEMP ${pad} <SUP>o</SUP>C</TD>";
echo "<TD align='left' class='SmallBlackB'>PRESS ${pad} PSIG</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD align='left' class='SmallBlackB'>RH ${pad} %</TD>";
echo "<TD align='left' class='SmallBlackB'>DP ${pad} <SUP>o</SUP>C</TD>";
echo "</TR>";

echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
}*/
?>
