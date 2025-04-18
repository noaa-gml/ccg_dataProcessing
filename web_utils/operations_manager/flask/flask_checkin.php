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
$site_notes = isset( $_POST['site_notes'] ) ? $_POST['site_notes'] : '';
$selectedflasks = isset( $_POST['selectedflasks'] ) ? $_POST['selectedflasks'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_checkin.js'></SCRIPT>";

switch ($task)
{
        case "Ok":
   #
   # Are selected flasks still available to check in?
   #
   $precheckflaskinfo = (empty($selectedflasks)) ? '' : explode('~',$selectedflasks);

   $postcheckflaskinfo = array();
   for ($i=0,$err=''; $i<count($precheckflaskinfo); $i++)
   {
      DB_PreCheckin($precheckflaskinfo[$i],$z);
      if ($z != "") { $err = "${err}\\n${z}"; }
      else { $postcheckflaskinfo[] = $precheckflaskinfo[$i]; }
   }
   if ($err != '')
   {
      JavaScriptAlert("${err}\\n\\nCheck In aborted.");
      $selectedflasks = implode('~',$postcheckflaskinfo);
      break;
   }
   #
   # Okay.  Check flasks in.

   for ($i=0; $i<count($postcheckflaskinfo); $i++)
   {
      $select = " SELECT project.abbr";
      $from = " FROM flask_inv,project";
      $where = " WHERE flask_inv.id = '$postcheckflaskinfo[$i]'";
      $and = " AND flask_inv.project_num = project.num";

      $sql = $select.$from.$where.$and;
      $res = ccgg_query($sql);

      if ( !empty($res) ) { $proj_abbr = $res[0]; }
      else { $proj_abbr = DB_GetDefProject($code, $strat_abbr); }

      #
      # Get Default Analysis Path Information
      #
      $pathinfo = DB_GetDefPath($code,$proj_abbr,$strat_abbr);

      list($pathno,$pathname) = split("\|",$pathinfo);

      if (DB_Checkin($postcheckflaskinfo[$i],$code,$proj_abbr,$pathno))
      { UpdateLog($log,"${postcheckflaskinfo[$i]} checked in from ${code}"); }
      else
      { JavaScriptAlert("Unable to check in ${postcheckflaskinfo[$i]} from ${code}"); }
   }
   $code = '';
   $selectedflasks = '';
   break;
}

$siteinfo = DB_GetAllSiteInfo("", $strat_abbr);

if ($code) { DB_GetFlasksAtSite($availableflaskinfo,$code); }

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $code;
global $siteinfo;
global $site_notes;
global $availableflaskinfo;
global $selectedflasks;
global $chkout_date;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='task'>";
echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
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
echo "<TABLE col=4 width=100% border='0' cellpadding='8' cellspacing='8'>";
#
##############################
# Row 1: Column Headers
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
# Row 2: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='15' onClick='SiteListCB()'>";

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
echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='15' onClick='AvailableListCB()'>";

for ($i=0; $i<count($availableflaskinfo); $i++)
{
   $tmp=split("\|",$availableflaskinfo[$i]);
   $z = $tmp[0];
   if ($selectedflaskinfo) { $z = (in_array($z,$selectedflaskinfo)) ? "${z}*" : $z; }
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

echo "<FONT class='MediumRedB' id='flask_notes'></FONT><BR><BR>";

echo "<FONT id='site_notes'>".urldecode($site_notes)."</FONT>";
echo "</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD align='left'>";
echo "<B><INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='sitescan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='SiteScanCB()'>";
echo "</TD>";

echo "<TD align='left'>";
echo "<B><INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='flaskscan'
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
# Function DB_GetFlasksAtSite ########################################################
#
function DB_GetFlasksAtSite(&$availableflaskinfo,$code)
{
   #
   # Get list of flasks at site
   #
   $select = "SELECT id,flask_inv.comments";
   $from = " FROM flask_inv,gmd.site";
   $where = " WHERE gmd.site.code='${code}'";
   $and = " AND gmd.site.num=flask_inv.site_num";
   $and = "${and} AND flask_inv.sample_status_num='2'";

   $availableflaskinfo = ccgg_query($select.$from.$where.$and);
   sort($availableflaskinfo,SORT_NUMERIC);
}
#
# Function DB_PreCheckin ########################################################
#
function DB_PreCheckin($id,&$err)
{
   $err = "";

   $sql = "SELECT id,sample_status_num FROM flask_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   $n = count($res);

   if ($n == 0) { $err = "${id} no longer exists in DB."; }
   elseif ($n > 1) { $err = "${id} exists multiple times in DB."; }
   else
   {
      $tmp=split("\|",$res[0]);
      if ($tmp[1] != '2') { $err = "${id} no longer available for check in."; }
   }
}
#
# Function DB_Checkin ########################################################
#
function DB_Checkin($id,$code,$proj_abbr,$path)
{
   #
   # Check flask in
   #
   $now=date("Y-m-d");
   $site_num=DB_GetSiteNum($code);
   $proj_num=DB_GetProjectNum($proj_abbr);

   $update = "UPDATE flask_inv";
   $set = " SET site_num='${site_num}',date_in='${now}'";
   $set = "${set},sample_status_num='3',path='${path}'";
   $set = "${set},event_num='0'";
   $where = " WHERE id='${id}'";
   #echo "$update$set$where\n";
   $res = ccgg_insert($update.$set.$where);
   $res = "";
   if (!empty($res)) { return(FALSE); }
   #
   # Retrieve ship date
   #
   $sql = "SELECT date_out FROM flask_inv WHERE id='${id}'";
   $then = ccgg_query($sql);
   #
   # Update shipping table
   #
   $insert = "INSERT INTO flask_shipping";
   $list = " (site_num,project_num,id,date_out,date_in)";
   $values = " VALUES('${site_num}','${proj_num}','${id}','${then[0]}','${now}')";
   #echo "$insert$list$values\n";
   $res = ccgg_insert($insert.$list.$values);
   return(TRUE);
}
?>
