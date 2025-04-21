<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$proj_abbr = isset( $_POST['proj_abbr'] ) ? $_POST['proj_abbr'] : '';
$selectedflasks = isset( $_POST['selectedflasks'] ) ? $_POST['selectedflasks'] : '';
$send_notes = isset( $_POST['send_notes'] ) ? $_POST['send_notes'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';

if ( empty($proj_abbr) ) { $proj_abbr = "ccg_surface"; }

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name, $strat_abbr, GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_checkout.js'></SCRIPT>";

switch ($task)
{
   case "Ok":
   #
   # Are selected flasks still available to check out?
   #
   $precheckflaskinfo = (empty($selectedflasks)) ? '' : explode('~',$selectedflasks);

   $postcheckflaskinfo = array();
   for ($i=0,$err=''; $i<count($precheckflaskinfo); $i++)
   {
      DB_PreCheckout($precheckflaskinfo[$i],$z);
      if ($z != "") { $err = "${err}\\n${z}"; }
      else { $postcheckflaskinfo[] = $precheckflaskinfo[$i]; }
   }
   if ($err != '')
   {
      JavaScriptAlert("${err}\\n\\nCheck Out aborted.");
      $selectedflasks = implode('~',$postcheckflaskinfo);
      break;
   }
   #
   # Okay.  Check flasks out.
   #
   #
   # Get appropriate collection method and samplesheet information 
   # 
   $samplesheetinfo = DB_GetSampleSheetInfo($code, $proj_abbr, $strat_abbr);
   for ($i=0, $out = 0; $i<count($postcheckflaskinfo); $i++)
   {
      if (DB_Checkout($postcheckflaskinfo[$i],$code,$proj_abbr))
      {
         UpdateLog($log,"${postcheckflaskinfo[$i]} checked out to ${proj_abbr} at ${code}"); 
         $out++;
      }
      else
      { JavaScriptAlert("Unable to check out ${postcheckflaskinfo[$i]} to ${code}"); }
   }

   if ($out) { PrepareSampleSheet($code, $proj_abbr, $strat_abbr); }

   $code = '';
   $selectedflasks = '';
   $send_notes = '';
   break;
}

$siteinfo = DB_GetAllSiteInfo($proj_abbr, $strat_abbr);
$projinfo = DB_GetAllProjectInfo();

if ($code) { $availableflaskinfo = DB_GetAvailableFlasksToShip($code); }

MainWorkArea();

# if ($code) { PrepareSampleSheet($code, $strat_abbr); }

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
global $availableflaskinfo;
global $selectedflasks;
global $send_notes;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_abbr' VALUE=${proj_abbr}>";
echo "<INPUT TYPE='HIDDEN' NAME='task'>";
echo "<INPUT TYPE='HIDDEN' NAME='selectedflasks' VALUE='${selectedflasks}'>";
echo "<INPUT TYPE='HIDDEN' NAME='send_notes' VALUE='${send_notes}'>";

$selectedflaskinfo = (empty($selectedflasks)) ? array() : explode('~',$selectedflasks);

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Check Out</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE col=4 width=100% border='0' cellpadding='8' cellspacing='8'>";

#
##############################
# Row 1: Project Selection
##############################
#
echo "<TR align='right'>";
echo "<TD align='left' colspan=4>";
echo "<FONT class='MediumBlackB'>Project - </FONT>";
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

$n = (empty($availableflaskinfo)) ? '0' : count($availableflaskinfo);
echo "<TD width='12%' align='left' class='MediumBlackB'>Available - <FONT class='MediumBlueB'>${n}</FONT></TD>";

$n = count($selectedflaskinfo);
echo "<TD width='12%' align='left' class='MediumBlackB'>Selected - ";
echo "<FONT class='MediumBlueB' id='selectedflaskcnt'>${n}</FONT></TD>";

echo "<TD width='42%' align='left' class='MediumBlackB'>Notes</TD>";

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

   $zz = str_replace("\r\n","<BR>",$tmp[9]);
   JavaScriptCommand("send_notes[$i] = \"".urlencode($zz)."\"");
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='15' onClick='AvailableListCB()'>";

for ($i=0; $i<count($availableflaskinfo); $i++)
{
   $tmp=split("\|",$availableflaskinfo[$i]);
   $z = (in_array($tmp[0],$selectedflaskinfo)) ? "${tmp[0]}*" : $tmp[0];
   echo "<OPTION VALUE=${tmp[0]}>${z}</OPTION>";
   $zz = str_replace("\r\n","<BR>",$tmp[1]);
   JavaScriptCommand("flask_notes[$i] = \"${zz}\"");
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='selectedlist' SIZE='15'>";

for ($i=0; $i<count($selectedflaskinfo); $i++)
{
   if ($selectedflaskinfo[$i] == '') continue;
   echo "<OPTION VALUE=$selectedflaskinfo[$i]>${selectedflaskinfo[$i]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";

echo "<TD>";
echo "<FONT class='MediumRedB' id='send_notes'>".urldecode($send_notes)."<BR><BR></FONT>";

echo "<FONT class='MediumRedB' id='flask_notes'></FONT>";
echo "</TD>";

echo "</TR>";

#
##############################
# Row 4: Search boxes
##############################
#
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
echo "</TABLE>";

if (count($availableflaskinfo)) { JavaScriptCommand("document.mainform.flaskscan.focus()"); }
else { JavaScriptCommand("document.mainform.sitescan.focus()"); }

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

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_PreCheckout ########################################################
#
function DB_PreCheckout($id,&$err)
{
   $err = "";

   $sql="SELECT id,sample_status_num FROM flask_inv WHERE id='${id}'";

   $res = ccgg_query($sql);

   $n = count($res);
   if ($n == 0) { $err = "${id} no longer exists in DB."; }
   elseif ($n > 1) { $err = "${id} exists multiple times in DB."; }
   else
   {
      $tmp=split("\|",$res[0]);
      if ($tmp[1] != '1') { $err = "${id} no longer available for check out."; }
   }
}
#
# Function DB_Checkout ########################################################
#
function DB_checkout($id,$code,$proj_abbr)
{
   #
   # Check flask out in DB
   #
   $now = date("Y-m-d");
   $site_num = DB_GetSiteNum($code);
   $proj_num = DB_GetProjectNum($proj_abbr);

   $update = "UPDATE flask_inv";
   $set = " SET site_num=$site_num,date_out='${now}'";
   $set = "${set},date_in='0000-00-00',sample_status_num='2',path=''";
   $set = "${set},event_num='0',project_num='${proj_num}'";
   $where = " WHERE id='${id}'";

   #echo "$update$set$where";
   $res = ccgg_insert($update.$set.$where);
   #$res = "";
   if (!empty($res)) { return(FALSE); } 
   return(TRUE);
}
?>
