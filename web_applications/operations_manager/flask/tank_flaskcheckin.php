<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$sitecode = 'TNK';
$strat_abbr = 'flask';
$strat_name = 'Flask';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();

echo "<SCRIPT language='JavaScript' src='tank_flaskcheckin.js'></SCRIPT>";

MainWorkArea();
exit;

#
# Function MainWorkArea() ##########################################################
#
function MainWorkArea()
{
   global $sitecode;
   $tankidlist = DB_GetAllTankIDs();
   $flasklist_checkedout = DB_GetFlasksOutBySite($sitecode);
   usort($flasklist_checkedout, 'sortbyid');

   echo "<FORM name='mainform' method='POST'>\n";

   echo "<INPUT type='hidden' name='task'>";
   echo "<INPUT type='hidden' name='tankid'>";
   echo "<INPUT type='hidden' name='selectedflasks'>";

   # Title
   echo "<DIV align='center' class='XLargeBlueB'>Tank Flask Check In</DIV>";
   echo "<BR>";

   # Begining of Main table
   echo "<TABLE width='90%' border='1' align='center'>\n";

   #
   ############################
   # Row 1: Column Headers
   ############################
   #
   echo " <TR>\n";
   echo "  <TD width='30%' align='left' class='MediumBlackB'>\n";
   echo "   Tank\n";
   echo "  </TD>\n";
   echo "  <TD width='20%' align='left' class='MediumBlackB'>\n";
   echo "   Checked Out\n";
   echo "  </TD>\n";
   echo "  <TD width='20%' align='left' class='MediumBlackB'>\n";
   echo "   Selected\n";
   echo "  </TD>\n";
   echo "  <TD width='30%' align='left' class='MediumBlackB'>\n";
   echo "   Notes\n";
   echo "  </TD>\n";
   echo " </TR>\n";

   #
   ############################
   # Row 2: Selection Lists
   ############################
   #
   echo " <TR>\n";
   echo "  <TD>\n";
   echo "   <SELECT class='MediumBlackN' name='tanklist' size='15' onClick='TankListCB()'>\n";
   for ( $i=0; $i<count($tankidlist); $i++ )
   {
      echo "    <OPTION value='$tankidlist[$i]'>$tankidlist[$i]</OPTION>\n";
   }
   echo "   </SELECT>\n";
   echo "  </TD>\n";
   echo "  <TD>\n";
   echo "   <SELECT class='MediumBlackN' name='flasklist_checkedout' size='15' onClick='AvailableListCB()'>\n";
   for ( $i=0; $i<count($flasklist_checkedout); $i++ )
   {
      list($id, $comment) = explode("|", $flasklist_checkedout[$i]);
      echo "    <OPTION value='$id'>$id</OPTION>\n";
      $zz = str_replace("\r\n","<BR>",$comment);
      JavaScriptCommand("flask_notes['$id'] = \"${zz}\"");
   }
   echo "   </SELECT>\n";
   echo "  </TD>\n";
   echo "  <TD>\n";
   echo "   <SELECT class='MediumBlackN' name='flasklist_selected' size='15'>\n";
   echo "   </SELECT>\n";
   echo "  </TD>\n";
   echo "  <TD>\n";
   echo "   <DIV class='MediumRedB' id='send_notes'></DIV>";
   echo "   <BR><BR>\n";
   echo "   <DIV class='MediumRedB' id='flask_notes'></DIV>";
   echo "  </TD>\n";
   echo " </TR>\n";

   #
   ############################
   # Row 1: Search boxes
   ############################
   #
   echo " <TR>\n";
   echo "  <TD>\n";
   echo "<INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='tankscan' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='TankScanCB()'>";
   echo "  </TD>\n";
   echo "  <TD>\n";
   echo "<INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='flaskscan' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='FlaskScanCB()'>";
   echo "  </TD>\n";
   echo "  <TD>\n";
   echo "  </TD>\n";
   echo "  <TD>\n";
   echo "  </TD>\n";
   echo " </TR>\n";


   echo "</TABLE>\n";
   # End of Main table

   echo "<TABLE width='20%' cellspacing='2' cellpadding='2' align='center'>";
   echo " <TR>";
   echo "  <TD align='center'>";
   echo "   <B><INPUT TYPE='button' class='Btn' value='Ok' onClick='OkayCB()'></B>";
   echo "  </TD>";

   echo "  <TD align='center'>";
   echo "   <B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'></B>";
   echo "  </TD>";
   
   echo " </TR>";
   echo "</TABLE>";

   JavaScriptCommand("document.mainform.tankscan.focus()");
}

#
# Function GetAllTankIDs() #########################################################
#
function DB_GetAllTankIDs()
{
   $select = "SELECT DISTINCT serial_number";
   $from = " FROM reftank.fill";
   $order = " ORDER BY serial_number";

   $sql = $select.$from.$order;
   return ccgg_query($sql);
}

#
# Function DB_GetFlasksOutBySite ########################################################
#
function DB_GetFlasksOutBySite($code)
{
   #
   # Get list of flasks checked out by site
   #
   $select = " SELECT t1.id, t1.comments";
   $from = " FROM ccgg.flask_inv as t1, gmd.site as t2, project as t3";
   $where = " WHERE t1.sample_status_num = '2'";
   $and = " AND t2.code='${code}'";
   $and = "${and} AND t2.num = t1.site_num";
   $and = "${and} AND t1.project_num = t3.num";
   $etc = " ORDER BY t1.id";

   return ccgg_query($select.$from.$where.$and.$etc);
}

#
# Function sortbyid
#
function sortbyid($a, $b)
{
   list($aid, $acomment) = explode("|", $a, 2);
   list($bid, $bcomment) = explode("|", $b, 2);

   $aid = preg_replace('/^[A-Za-z]/', '', $aid);
   $bid = preg_replace('/^[A-Za-z]/', '', $bid);

   list($aprefix, $asuffix) = explode('-', $aid, 2);
   list($bprefix, $bsuffix) = explode('-', $bid, 2);

   $aprefix = intval($aprefix, 10);
   $bprefix = intval($bprefix, 10);

   if ($aprefix == $bprefix)
   {
      return 0;
   }
   return ($aprefix < $bprefix) ? -1 : 1;
}
?>
