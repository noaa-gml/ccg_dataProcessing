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
$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$site_notes = isset( $_POST['site_notes'] ) ? $_POST['site_notes'] : '';
$selectedflasks = isset( $_POST['selectedflasks'] ) ? $_POST['selectedflasks'] : '';

$strat_abbr = 'pfp';
$strat_name = 'PFP';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());

BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_checkin.js'></SCRIPT>";

$siteinfo = DB_GetAllSiteInfo("", $strat_abbr);

if ($code) { DB_GetPFPsAtSite($availablepfpinfo,$code); }

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $id;
global $code;
global $siteinfo;
global $site_notes;
global $availablepfpinfo;
global $chkout_date;
global $selectedflasks;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='id' VALUE=${id}>";
echo "<INPUT TYPE='HIDDEN' NAME='selectedflasks' VALUE='${selectedflasks}'>";
echo "<INPUT TYPE='HIDDEN' NAME='site_notes' VALUE='${site_notes}'>";

$selectedflaskinfo = (empty($selectedflasks)) ? array() : explode('~',$selectedflasks);

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Check In</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE col=2 width=100% border='0' cellpadding='0' cellspacing='0'>";
#
##############################
# Row 1: Column Headers
##############################
#
echo "<TR>";
echo "<TD width='58%' valign='top'>";

#
# Define Selection Table
#
echo "<TABLE col=3 border='0' cellpadding='8' cellspacing='8'>";
echo "<TR align='center'>";

$code = (empty($code)) ? 'None Selected' : $code;
echo "<TD width='48%' align='left' class='MediumBlackB'>Site - <FONT class='MediumBlueB'>${code}</FONT></TD>";

$n = (empty($availablepfpinfo)) ? '0' : count($availablepfpinfo);
echo "<TD width='26%' align='left' class='MediumBlackB'>Available - <FONT class='MediumBlueB'>${n}</FONT></TD>";

#$n = (empty($selectedflaskinfo)) ? '0' : count($selectedflaskinfo);
$n = count($selectedflaskinfo);
echo "<TD width='26%' align='left' class='MediumBlackB'>Selected - ";
echo "<FONT class='MediumBlueB' id='selectedflaskcnt'>${n}</FONT></TD>";

echo "</TR>";
#
##############################
# Row 2: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='10' onClick='SiteListCB()'>";

$num = -1;
for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp=split("\|",$siteinfo[$i]);

   $proj_num = $tmp[12];
   $strat_num = $tmp[13];

   $zz = "<TABLE width='90%' border='1' cellspacing='2' cellpadding='2'>";
                                                                                          
   $projinfo = DB_GetProjectInfo($proj_num);
   list($proj_name,$proj_abbr) = split("\|",$projinfo);
   $zz = "${zz}<TR><TD>";
   $zz = "${zz}<FONT class='MediumGreenB'>PROJECT</FONT>";
   $zz = "${zz}</TD><TD>";
   $zz = "${zz}<FONT class='MediumGreenB'>$proj_abbr</FONT>";
   $zz = "${zz}</TD></TR>";
                                                                                          
   if ( $tmp[7] != "NULL" && $tmp[7] != "" )
   {
      $zz = "${zz}<TR><TD>";
      $zz = "${zz}<FONT class='LargeBlueB'>ROUTING</FONT>";
      $zz = "${zz}</TD><TD>";
      $routing_notes = DB_GetFlaskRouting($tmp[7]);
      $zz = "${zz}<FONT class='LargeBlueB'>$routing_notes</FONT>";
      $zz = "${zz}</TD></TR>";
   }
                                                                                          
   if ( $tmp[10] != "NULL" && $tmp[10] != "" )
   {
      $zz = "${zz}<TR><TD>";
      $zz = "${zz}<FONT class='MediumRedB'>RETURN</FONT>";
      $zz = "${zz}</TD><TD>";
      $return_notes = str_replace("\r\n","<BR>",$tmp[10]);
      $zz = "${zz}<FONT class='MediumRedB'>$return_notes</FONT>";
      $zz = "${zz}</TD></TR>";
   #   $zz = "${zz}<FONT class='MediumRedB'>** RETURN **<BR>";
   #   $meas_notes = str_replace("\r\n","<BR>",$tmp[8]);
   #   $zz = "${zz}$meas_notes</FONT><BR><BR>";
   }
                                                                                          
   if ( $tmp[8] != "NULL" && $tmp[8] != "" )
   {
      $zz = "${zz}<TR><TD>";
      $zz = "${zz}<FONT class='MediumRedB'>MEASUREMENT</FONT>";
      $zz = "${zz}</TD><TD>";
      $meas_notes = str_replace("\r\n","<BR>",$tmp[8]);
      $zz = "${zz}<FONT class='MediumRedB'>$meas_notes</FONT>";
      $zz = "${zz}</TD></TR>";
   #   $zz = "${zz}<FONT class='MediumRedB'>** MEASUREMENT **<BR>";
   #   $return_notes = str_replace("\r\n","<BR>",$tmp[10]);
   #   $zz = "${zz}$return_notes</FONT><BR><BR>";
   }
   $zz = "${zz}</TABLE>";
   $zz = urlencode($zz);
                                                                                          
   $check = 0;
   if ( $i > 0 )
   {
      $field = split("\|",$siteinfo[$i-1]);
      if ( $tmp[0] == $field[0] )
      {
         JavaScriptCommand("site_notes[$num] = site_notes[$num]+\"<BR><BR>${zz}\"");
         $check++;
      }
   }
                                                                                          
   if ( $check == 0 )
   {
      $num++;
      $selected = ($tmp[1] == $code) ? 'SELECTED' : '';
      echo "<OPTION $selected VALUE=$tmp[1]>${tmp[1]} - ${tmp[2]}, ${tmp[3]}</OPTION>";
      JavaScriptCommand("site_notes[$num] = \"${zz}\"");
   }
                                                                                          
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='10' onClick='AvailableListCB()'>";

for ($i=0; $i<count($availablepfpinfo); $i++)
{
   $tmp=split("\|",$availablepfpinfo[$i]);
   $z = $tmp[0];
   if ($selectedflaskinfo) { $z = (in_array($z,$selectedflaskinfo)) ? "${z}*" : $z; }
   echo "<OPTION VALUE=${tmp[0]}>${z}</OPTION>";
   $zz = htmlspecialchars($tmp[1]);
   $zz = str_replace("\r\n","<BR>",$zz);
   JavaScriptCommand("flask_notes[$i] = \"${zz}\"");
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='selectedlist' SIZE='10'>";

for ($i=0; $i<count($selectedflaskinfo); $i++)
{
   if ($selectedflaskinfo[$i] == '') continue;
   echo "<OPTION VALUE=$selectedflaskinfo[$i]>${selectedflaskinfo[$i]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";

echo "</TR>";

echo "<TR>";
echo "<TD>";
echo "<INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='sitescan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='SiteScanCB()'>";
echo "</TD>";

echo "<TD>";
echo "<INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='flaskscan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='FlaskScanCB()'>";
echo "</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD colspan=3>";

#
# Define Button Table
#
echo "<TABLE width='20%' cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Ok' onClick='OkayCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
# End Button Table
#
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
# End Selection Table
#
echo "</TD>";
echo "<TD width='42%' valign='top'>";

#
# Begin Notes Table
#
echo "<TABLE border='0' cellpadding='8' cellspacing='8'>";
echo "<TR>";
echo "<TD width='100%' align='left' class='MediumBlackB'>Notes</TD>";
echo "</TR>";
echo "<TR>";
echo "<TD>";

echo "<FONT class='MediumRedB' id='flask_notes'></FONT>";

echo "<FONT id='site_notes'>".urldecode($site_notes)."</FONT>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
# End Notes Table
#


echo "</TD>";
echo "</TR>";
echo "</TABLE>";
#
# End Outermost Table
#

if (count($availablepfpinfo)) { JavaScriptCommand("document.mainform.flaskscan.focus()"); }
else { JavaScriptCommand("document.mainform.sitescan.focus()"); }


echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetPFPsAtSite ########################################################
#
function DB_GetPFPsAtSite(&$availablepfpinfo,$code)
{
   #
   # Get list of PFPs at site
   #
   $select = "SELECT id,pfp_inv.comments";
   $from = " FROM pfp_inv,gmd.site";
   $where = " WHERE gmd.site.code='${code}'";
   $and = " AND gmd.site.num=pfp_inv.site_num";
   $and = "${and} AND pfp_inv.sample_status_num='2'";
   $and = "${and} AND id LIKE '%-FP'";

   $availablepfpinfo = ccgg_query($select.$from.$where.$and);
   sort($availablepfpinfo,SORT_NUMERIC);
}
?>
