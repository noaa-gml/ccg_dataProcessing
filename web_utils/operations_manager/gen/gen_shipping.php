<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}
global $ccgg_equip;

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$id = isset( $_POST['id'] ) ? $_POST['id'] : '';
$code = isset( $_POST['code'] ) ? $_POST['code'] : '';

$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : ''; 

if ( empty($strat_abbr ) ) { $strat_abbr = 'pfp'; }
if ( empty($strat_name ) ) { $strat_name = 'PFP'; }

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_shipping.js'></SCRIPT>";


MainWorkArea();
exit;
#  
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $ccgg_equip;
   global $gen_type_num;
   global $gen_type_abbr;
   global $id;
   global $code;
   global $task;
   global $strat_name;
   global $strat_abbr;

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center' border='1'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} Shipping Manager</TD>";
   echo "</TR>";
   echo "</TABLE>";
   #
   ##############################
   # Define OuterMost Table
   ##############################
   #
   echo "<TABLE align='center' width=100% border='1' cellpadding='10' cellspacing='10'>";

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT type='HIDDEN' NAME='task' VALUE='search'>";
   echo "<INPUT type='HIDDEN' NAME='code' VALUE='$code'>";
   echo "<INPUT type='HIDDEN' NAME='date_out' VALUE=''>";
   echo "<INPUT type='HIDDEN' NAME='date_in' VALUE=''>";
   echo "<INPUT type='HIDDEN' NAME='invtype' VALUE='$gen_type_abbr'>";

   #
   ##############################
   # Row 1: Column Headers
   ##############################
   #
   echo "<TR>";
   echo "<TD align='center'>";

   #
   # Constrains Table
   #
   echo "<TABLE>";
   echo "<TR>";
   echo "<TD valign='top'>";

   # Id Table
   echo "<TABLE border='1' bgcolor='#D3D3D3'>";
   echo "<TR>";
   echo "<TD valign='top'>";
   echo "<FONT class='LargeBlackB'>Id</FONT></TD>";
   echo "<TD valign=top><INPUT type='text' class='LargeBlackB'
   onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
   onKeyUp='ClearChk(this)' size=10 name='id' value='$id'>";
   echo "<BR>Press ` to clear";
   echo "</TD>";
   echo "</TR>";
   # End of Id Table
   echo "</TABLE>";

   JavaScriptCommand("document.mainform.id.focus()");

   echo "</TD>";
   echo "<TD valign='top'>";

   # Site Table
   echo "<TABLE border='1' bgcolor='#D3D3D3'>";
   echo "<TR>";
   echo "<TD valign='top'>";
   echo "<FONT class='LargeBlackB'>Site</FONT></TD>";
   echo "<TD valign=top>";

   $siteinfo = DB_GetSiteList('',$strat_abbr);

   echo "<SELECT class='LargeBlackN' NAME='sitelist' SIZE='1'>";
   echo "<OPTION VALUE=''></OPTION>";
   for ($i=0; $i<count($siteinfo); $i++ )
   {
      $tmp=split("\|",$siteinfo[$i]);
      $selected = ($tmp[1] == $code) ? 'SELECTED' : '';
      echo "<OPTION $selected VALUE='$tmp[1]'>${tmp[1]}</OPTION>";
   }

   echo "</SELECT>";

   echo "<INPUT type='text' class='LargeBlackB'
   onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
   onKeyUp='ClearChk(this)' size=6 name='search4code' value=''>";
   echo "</TD>";
   echo "</TR>";
   # End of Site Table
   echo "</TABLE>";


   echo "</TD>";
   echo "<TD>";
   echo "<INPUT TYPE='button' name='search' class='Btn' value='Search' onClick='SearchCB()'>";
   echo "</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD colspan='3' align='center'>";
   echo "<FONT class='MediumBlueN'>[ Enter ID and/or Site ]</FONT>";
   echo "</TD>";
   echo "</TR>";
   #
   # End of Constrains Table
   #
   echo "</TABLE>";

   echo "</TD>";
   echo "</TR>";

   if ( ! empty($id) || ! empty($code))
   {
      echo "<TR>";
      echo "<TD align='center'>";
      echo "<TABLE align='center' border='1' cellpadding='5' cellspacing='5'>";
      echo "<TR>";
      echo "<TD class='MediumBlueB'>Id</TD>";
      echo "<TD class='MediumBlueB'>Site</TD>";
      echo "<TD class='MediumBlueB'>Project</TD>";
      echo "<TD class='MediumBlueB'>Date Out</TD>";
      echo "<TD class='MediumBlueB'>Date In Use</TD>";
      echo "<TD class='MediumBlueB'>Date Out Use</TD>";
      echo "<TD class='MediumBlueB'>Date In</TD>";
      echo "<TD class='MediumBlueB'>Notes</TD>";
      echo "<TD></TD>";
      echo "</TR>";

      #
      # Find all entries in gen_shipping
      #
      $select = " SELECT t3.gen_inv_id, t1.code, t2.abbr, t3.date_out, t3.date_inuse";
      $select = "${select}, t3.date_outuse, t3.date_in, t3.notes";
      $from = " FROM gmd.site AS t1, gmd.project AS t2, ${ccgg_equip}.gen_shipping AS t3";
      $where = " WHERE t3.gen_type_num = '".mysql_real_escape_string($gen_type_num)."'";

      $and = " AND t1.num = t3.site_num AND t2.num = t3.project_num";
      if ( ! empty($id) )
      {
         $and = "${and} AND t3.gen_inv_id = '".mysql_real_escape_string($id)."'";
      }
      if ( ! empty($code) )
      {
         $and = "${and} AND t1.code = '".mysql_real_escape_string($code)."'";
      }
      $etc = " ORDER BY t3.date_out DESC";
      $sql = $select.$from.$where.$and.$etc;

      $outarr = ccgg_query($sql);

      #
      # Find all entries in gen_inv
      #
      $select = " SELECT t3.id, t1.code, t2.abbr, t3.date_out, t3.date_inuse";
      $select = "${select}, t3.date_outuse, t3.date_in, t3.notes";
      $from = " FROM gmd.site AS t1, gmd.project AS t2, ${ccgg_equip}.gen_inv AS t3";
      $where = " WHERE t3.gen_type_num = '".mysql_real_escape_string($gen_type_num)."'";

      $and = " AND t1.num = t3.site_num AND t2.num = t3.project_num";
      if ( ! empty($id) )
      {
         $and = "${and} AND t3.id = '".mysql_real_escape_string($id)."'";
      }
      if ( ! empty($code) )
      {
         $and = "${and} AND t1.code = '".mysql_real_escape_string($code)."'";
      }
      $and = "${and} AND t3.gen_status_num = '3'";
      $sql = $select.$from.$where.$and;

      $tmparr = ccgg_query($sql);

      $outarr = array_merge($tmparr, $outarr);

      for ( $i=0; $i<count($outarr); $i++ )
      {
         $fields = explode("|", $outarr[$i]);
         echo "<TR>";
         for ( $j=0; $j<count($fields); $j++ )
         {
            echo "<TD>";
            if ( $j == count($fields) - 1 )
            {
               echo "<TEXTAREA class='MediumBlackN' DISABLED>";
               echo "$fields[$j]";
               echo "</TEXTAREA>";
            }
            else
            {
               echo "$fields[$j]";
            }
            echo "</TD>";
         }
         echo "<TD>";
         echo "<INPUT TYPE='button' class='Btn' value='Edit' onClick='EditCB(\"${fields[0]}|${fields[1]}|${fields[3]}|${fields[6]}\")'>";
         echo "</TD>";
         echo "</TR>";
      }


      echo "</TABLE>";
      echo "</TD>";
      echo "</TR>";
   }
   echo "</TABLE>";

   echo "</BODY>";
   echo "</HTML>";
}
