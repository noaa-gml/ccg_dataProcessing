<?PHP
#jwm - 2.17 - don't think this is used after new unified template introduced.
# SAMPLE SHEET - ENGLISH
# Sites: TNK
#
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
$SID = isset( $_GET['SID'] ) ? $_GET['SID'] : '';

session_start($SID);
$ssdatastr = isset( $_SESSION['ssdatastr'] ) ? $_SESSION['ssdatastr'] : '';
$ssdata_aarr = unserialize($ssdatastr);

if ( isset($ssdata_aarr['site']['code']) && ! empty($ssdata_aarr['site']['code']) )
{
   if ( $code != '' )
   {
      if ( $code != $ssdata_aarr['site']['code'] )
      { print "Site codes do not match. Exciting..."; exit; }
   }
   else
   {
      $code = $ssdata_aarr['site']['code'];
   }
}
else
{
   if ( $code === '' )
   { print "No site code provided. Exiting..."; exit; }
}

if ( isset($ssdata_aarr['path']) && ! empty($ssdata_aarr['path']) )
{
   $sys_defi = DB_GetSystemDefi();
   $pathnums = explode(",", $ssdata_aarr['path']);
   $pathnames = array();
   
   for ( $i=0; $i<count($pathnums); $i++ )
   {
      for ( $j=0; $j<count($sys_defi); $j++ )
      {
         $fields = split("\|", $sys_defi[$j]);

         if ( $pathnums[$i] === $fields[0] )
         {
            array_push($pathnames, $fields[1]);
            break;
         }
      }
   }

   $path = join("-", $pathnames);
}

#unset($_SESSION['ssdatastr']);
#echo "DATA: $ssdatastr\n";
#
#
#// Unset all of the session variables.
#$_SESSION = array();
#
#// If it's desired to kill the session, also delete the session cookie.
#// Note: This will destroy the session, and not just the session data!
#if (isset($_COOKIE[session_name()])) {
#    setcookie(session_name(), '', time()-42000, '/');
#}

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
global $ssdata_aarr;

$smallpad = str_repeat("_",6);
$mediumpad = str_repeat("_",10);
$largepad = str_repeat("_",18);
$today = date("D M j, Y");

echo "<FORM NAME='mainform' METHOD=POST>";
#
#########################################
# Banner
#########################################
#
echo "<TABLE width = '100%' align = 'center' cellpadding = 4 border = 0 cellspacing = 2";

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
echo "<TABLE cellspacing = 2 cellpadding = 2 width = '100%' align = 'center'>";
echo "<TR valign = 'top' align='center'>";
echo "<TD align = 'left'>";
#
#########################################
# Sampling Container
#########################################
#
echo "<TABLE cellspacing = 2 cellpadding = 2 width = '100%' align = 'center'>";
#
#########################################
# Code, Cylinder, Initials
#########################################
#
echo "<TR>";
echo "<TD align = 'left'>";
echo "<TABLE width = '100%' align = 'center' cellspacing = 2 cellpadding = 2>";
echo "<TR>";
echo "<TD align='center' class='SmallBlackB'>SITE CODE ";
echo "<FONT class = 'XLargeBlueB'>${code}</FONT></TD>";

if ( isset($ssdata_aarr['tankid']) &&
     !empty($ssdata_aarr['tankid']) )
{
   echo "<TD align='center' class='SmallBlackB'>CYLINDER # ";
   echo "<FONT class='LargeBlueB'>".$ssdata_aarr['tankid'];
   echo "</TD>";
}
else
{
   echo "<TD align='center' class='SmallBlackB'>CYLINDER # ${largepad}</TD>";
}
echo "<TD align='center' class='SmallBlackB'>INITIALS ${largepad}</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";
#
#########################################
# Fill Details
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE align = 'center' width = '100%' cellspacing = 2 cellpadding = 2>";

echo "<TR>";
echo "<TH align='left' class='SmallBlackB'>FLASK #</TH>";

for ($i=0; $i<5; $i++)
{
   if ( isset($ssdata_aarr['sampleinfo'][$i]['sample']['id']) &&
        !empty($ssdata_aarr['sampleinfo'][$i]['sample']['id']) )
   { $value = $ssdata_aarr['sampleinfo'][$i]['sample']['id']; }
   else
   { $value = $mediumpad; }
   echo "<TD class = 'MediumBlackN'>$value</TD>";
}
echo "</TR>";

echo "<TR>";
echo "<TH align='left' class='SmallBlackB'>DATE</TH>";

for ($i=0; $i<5; $i++)
{
   if ( isset($ssdata_aarr['sampleinfo'][$i]['sample']['date']) &&
        !empty($ssdata_aarr['sampleinfo'][$i]['sample']['date']) )
   { $value = $ssdata_aarr['sampleinfo'][$i]['sample']['date']; }
   else
   { $value = $mediumpad; }
   echo "<TD class = 'MediumBlackN'>$value</TD>";
}
echo "</TR>";

echo "<TR>";
echo "<TH align='left' class='SmallBlackB'>TIME (UTC)</TH>";

for ($i=0; $i<5; $i++)
{
   if ( isset($ssdata_aarr['sampleinfo'][$i]['sample']['time']) &&
        !empty($ssdata_aarr['sampleinfo'][$i]['sample']['time']) )
   { $value = $ssdata_aarr['sampleinfo'][$i]['sample']['time']; }
   else
   { $value = $mediumpad; }
   echo "<TD class = 'MediumBlackN'>$value</TD>";
}
echo "</TR>";

echo "<TR>";
echo "<TH align='left' class='SmallBlackB'>METHOD</TH>";

for ($i=0; $i<5; $i++)
{
   if ( isset($ssdata_aarr['sampleinfo'][$i]['sample']['method']) &&
        !empty($ssdata_aarr['sampleinfo'][$i]['sample']['method']) )
   { $value = $ssdata_aarr['sampleinfo'][$i]['sample']['method']; }
   else
   { $value = $mediumpad; }
   echo "<TD class = 'MediumBlackN'>$value</TD>";
}
echo "</TR>";

echo "</TABLE>";
echo "</TD></TR>";
#
#########################################
# Comments
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%' cellspacing = 2 cellpadding = 2>";
echo "<TR>";
echo "<TD align = 'left' width = '15%' class='SmallBlackB'>COMMENTS</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
echo "</TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
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
#
#########################################
# End of Sampling Container
#########################################
#
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";
#
#########################################
# Analysis Container
#########################################
#
echo "<TR>";
echo "<TD align='center'>";

echo "<TABLE frame = 1 bgcolor = '#EEEEEE' cellspacing = 2 cellpadding = 2 width='100%' align='center'>";
#
#########################################
# Routing
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE align = 'center' width = '50%' cellspacing = 3 cellpadding = 3>";
echo "<TR>";
echo "<TD align='center' class='SmallBlackB'>SYSTEM</TD>";
echo "<TD align='center' class='SmallBlackB'>ANALYSIS DATE</TD>";
echo "<TD align='center' class='SmallBlackB'>INITIALS</TD>";
echo "</TR>";

echo "<TR><TD> </TD></TR>";

$tmp = explode('-',$path);

for ($i=0; $i<count($tmp); $i++)
{
   # Make the name appear on one line
   $tmp[$i] = preg_replace('/\s/', '&nbsp;', $tmp[$i]);
   echo "<TR>";
   echo "<TH align='center' class='MediumBlueB'>${tmp[$i]}</TH>";
   echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
   echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>";
   echo "</TR>";
}
echo "</TABLE>";
#
#########################################
# Fill Details
#########################################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE border = 0 cellspacing=2 cellpadding=2 width='100%' align='center'>";

echo "<TR>";
echo "<TD>";

echo "<TABLE width = '100%' cellspacing = 2 cellpadding = 2>";

echo "<TR>";
echo "<TH align='center' class='SmallBlackB'>PORT #</TH>";
for ($i=0; $i<8; $i++) { echo "<TD align = 'center' class = 'MediumBlackN'>${smallpad}</TD>"; }
echo "</TR>";

echo "<TR><TD></TD></TR>";

echo "<TR>";
echo "<TH align='center' class='SmallBlackB'>GAS</TH>";
for ($i=0; $i<8; $i++) { echo "<TD align = 'center' class = 'SmallBlackB'>VALUE</TD>"; }
echo "</TR>";

for ($i = 0; $i < 6; $i++)
{
   echo "<TR>";
   echo "<TH align='center' class='MediumBlackN'>${smallpad}</TH>";
   for ($ii = 0; $ii < 8; $ii++) { echo "<TD align = 'center' class = 'MediumBlackN'>${smallpad}</TD>"; }
   echo "</TR>";
}
echo "</TABLE>";
echo "</TD></TR>";

echo "<TR><TD></TD></TR>";

echo "<TABLE width = '100%' cellspacing = 2 cellpadding = 2>";
echo "<TR>";
echo "<TD align = 'left' width = '15%' class='SmallBlackB'>COMMENTS</TD>";
echo "<TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>";
echo "</TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "<TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>";
echo "</TABLE>";
#
#########################################
# End of Analysis Container
#########################################
#
echo "</TABLE>";
#
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
echo "<TD align='left' class='SmallBlackB'>ALTITUDE ${pad}</TD>";

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
echo "<TD align='left' class = 'LessTinyBlackB'>masl</TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";
}

function HATS($pad)
{
echo "<TABLE width = '100%' border = 1 cellspacing = 1 cellpadding = 1>";

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
}
?>
