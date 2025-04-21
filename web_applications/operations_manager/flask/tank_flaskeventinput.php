<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$tankid = isset( $_POST['tankid'] ) ? $_POST['tankid'] : '';
$selectedflasks = isset( $_POST['selectedflasks'] ) ? $_POST['selectedflasks'] : '';
$infostr = isset( $_POST['infostr'] ) ? $_POST['infostr'] : '';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';

$sitecode = 'TNK';
$strat_abbr = 'flask';
$strat_name = 'Flask';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();

echo "<SCRIPT language='JavaScript' src='tank_flaskeventinput.js'></SCRIPT>";
echo "<SCRIPT language='JavaScript' src='../php_serialize.js'></SCRIPT>";

if ( $task == 'ok' )
{
   session_start();

   $infoaarr = unserialize($infostr);
   $siteinfoaarr = DB_GetSiteInfo(array('code'=>$sitecode));
   $projinfoaarr = DB_GetProjectInfo2(array('num'=>'1'));
   $stratinfoaarr = DB_GetStrategyInfo2(array('num'=>'1'));
   $sitedescinfoaarr = DB_GetSiteDescInfo(array('site_num'=>$siteinfoaarr['num'],'project_num'=>'1','strategy_num'=>'1'));
   #echo "<PRE>";
   #print_r($infoaarr);
   #echo "</PRE>";

   $ssdata_aarr = array();
   $ssdata_aarr['tankid'] = $tankid;
   $ssdata_aarr['site'] = array();
   $ssdata_aarr['site'] = $siteinfoaarr;
   $ssdata_aarr['project'] = array();
   $ssdata_aarr['project'] = $projinfoaarr;
   $ssdata_aarr['strategy'] = array();
   $ssdata_aarr['strategy'] = $stratinfoaarr;
   $ssdata_aarr['site_desc'] = array();
   $ssdata_aarr['site_desc'] = $sitedescinfoaarr;

   $ssdata_aarr['path'] = $infoaarr['path'];

   $ssdata_aarr['sampleinfo'] = array();

   $errcount = 0;
   if ( isset($infoaarr['flasks']) && ! empty($infoaarr['flasks']) )
   {

      $flasks = explode("~", $infoaarr['flasks']);

      foreach ( $flasks as $id )
      {
         $err = DB_PreEventNum($id);
         if ( $err != '' )
         {
            JavaScriptAlert("${err}");
            UpdateLog($log,"Unable to check in $id from $sitecode");
            continue;
         }

         $tmpaarr['sample'] = array();
         $tmpaarr['sample']['id'] = $id;
         $tmpaarr['sample']['date'] = $infoaarr['date'];
         $tmpaarr['sample']['time'] = $infoaarr['time'];
         $tmpaarr['sample']['method'] = $infoaarr['method'];
         $tmpaarr['sample']['path'] = $infoaarr['path'];
         $tmpaarr['sample']['comment'] = $infoaarr['comment'];
   
         list($yr, $mo, $dy) = explode('-', $tmpaarr['sample']['date']);
         list($hr, $mn, $sc) = explode(':', $tmpaarr['sample']['time']);

         $tmpaarr['sample']['dd'] = date2dec($yr, $mo, $dy, $hr, $mn, $sc);

         $tmpaarr['sample']['site'] = array();
         $tmpaarr['sample']['site'] = $siteinfoaarr;
         $tmpaarr['sample']['project'] = array();
         $tmpaarr['sample']['project'] = $projinfoaarr;
         $tmpaarr['sample']['strategy'] = array();
         $tmpaarr['sample']['strategy'] = $stratinfoaarr;
         $tmpaarr['sample']['site_desc'] = array();
         $tmpaarr['sample']['site_desc'] = $sitedescinfoaarr;

         $err = DB_SetEventNum($tmpaarr);
         if ( $err != '' )
         {
            JavaScriptAlert("${err}");
            UpdateLog($log,"Unable to check in ".$tmpaarr['sample']['id']." from ".$tmpaarr['sample']['site']['code']);
            continue;
         }
         else
         { UpdateLog($log,$tmpaarr['sample']['id']." checked in from ".$tmpaarr['sample']['site']['code']); }

         array_push($ssdata_aarr['sampleinfo'], $tmpaarr);
      }
   }

   if ( count($ssdata_aarr['sampleinfo']) > 0 )
   {
      # Set the session variable so that the information can be passed to the
      #  sample sheet
      $_SESSION['ssdatastr'] = serialize($ssdata_aarr);

      PrepareSampleSheet($tmpaarr['sample']['site']['code'], $tmpaarr['sample']['project']['abbr'], $tmpaarr['sample']['strategy']['abbr'], $tmpaarr['sample'], htmlspecialchars(SID));
   }

   JavaScriptCommand("document.location='tank_flaskcheckin.php'");

   exit;
}

MainWorkArea();
exit;

#
# function MainWorkArea ##########################################################
#
function MainWorkArea()
{
global $tankid;
global $sitecode;
global $selectedflasks;

$flasks = explode("~", $selectedflasks);
JavaScriptCommand("infoaarr['flasks'] = '".$selectedflasks."'");

JavaScriptCommand("nflasks = '".count($flasks)."'");
?>

<FORM name='mainform' method=POST>

<?php
   echo "<INPUT type='hidden' name='infostr'>";
   echo "<INPUT type='hidden' name='ssdatastr'>";
   echo "<INPUT type='hidden' name='task'>";
   echo "<INPUT type='hidden' name='tankid' value='$tankid'>";

 $pathinfo = DB_GetDefPath($sitecode,'ccg_surface','flask');
 list($pathno,$pathname) = split("\|",$pathinfo);
 $pathnos = explode(',', $pathno);
 $sys_defi = DB_GetSystemDefi();
 $today = gmdate("Y-m-d");
 $now = gmdate("H:i:s");
?>

<TABLE border='1' align='center'>
 <TR>
  <TD valign='top'>
   <TABLE>
    <TR>
     <TD valign='top'>
      <TABLE>
       <TR>
        <TD>Tank ID</TD>
       </TR>
       <TR>
        <?php echo "     <TD>$tankid</TD>"; ?>
       </TR>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD valign='top'>
      <TABLE>
       <TR>
        <TD>Flask IDs</TD>
       </TR>
       <?php
       for ( $i=0; $i<count($flasks); $i++ )
       {
          echo " <TR>";
          echo "  <TD>";
          echo "$flasks[$i]";
          echo "  </TD>";
          echo " </TR>";
       }
       ?>
      </TABLE>
     </TD>
    </TR>
   </TABLE>
  </TD>
  <TD valign='top'>
   <!-- Event details -->
   <TABLE>
    <TR>
     <TD colspan='2' align='center'>Event details</TD>
    </TR>
    <TR>
     <TD align='right'>Date [YYYY-MM-DD]</TD>
     <TD>
      <?php echo "      <INPUT type='text' class='MediumBlackN' id='date' value='$today' size='10' maxlength='10' disabled>"; ?>
     </TD>
    </TR>
    <TR>
     <TD align='right'>Time [HH:MM:SS]</TD>
     <TD>
      <?php echo "      <INPUT type='text' class='MediumBlackN' id='time' value='$now' size='8' maxlength='8' disabled>"; ?>
     </TD>
    </TR>
    <TR>
     <TD align='right'>Method [D]</TD>
     <TD>
      <INPUT type='text' class='MediumBlackN' id='method' value='N' size='3' maxlength='3'>
     </TD>
    </TR>
    <TR>
     <TD align='right'>Code</TD>
     <TD>
      <?php echo "$sitecode"; ?>
     </TD>
    </TR>
    <TR>
     <TD align='right'>Comment</TD>
     <TD>
      <?php echo "      <INPUT type='text' class='MediumBlackN' id='comment' value='cyl: $tankid' disabled>"; ?>
     </TD>
    </TR>
   </TABLE>
  </TD>
  <TD valign='top'>
   <!-- Measurement path -->
   <TABLE>
    <TR>
     <TD align='center'>Measurement path</TD>
    </TR>
    <?php
    for ( $i=0; $i<10; $i++ )
    {
       echo "    <TR>";
       echo "     <TD>";
       echo "      <SELECT class='MediumBlackN' id='path:$i'>";
       echo "       <OPTION value=''>--------------</OPTION>";
       for ( $j=0; $j<count($sys_defi); $j++ )
       {
          $fields = split("\|", $sys_defi[$j]);
          $selected = ( isset($pathnos[$i]) && $pathnos[$i] === $fields[0]) ? "SELECTED" : '';
          echo "       <OPTION value='".$fields[0]."' $selected>".$fields[1]."</OPTION>\n";
       }
       echo "      </SELECT>";
       echo "     </TD>";
       echo "    </TR>";
    }
    ?>
   </TABLE>
  </TD>
 </TR>
</TABLE>

<TABLE align='center'>
 <TR>
  <TD>
   <INPUT TYPE='button' class='Btn' value='Ok' onClick='OkayCB()'>
  </TD>
  <TD>
   <INPUT TYPE='button' class='Btn' value='Edit' onClick='EditCB()'>
  </TD>
  <TD>
   <INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>
  </TD>
 </TR>
</TABLE>
</FORM>

<?php
}

#
# DB_PreEventNum #####################################################################
#
function DB_PreEventNum($flaskid)
{
   $err = "";
   #
   # Is event description still required?
   #
   $select = "SELECT flask_inv.id";
   $from = " FROM flask_inv";
   $where = " WHERE flask_inv.id='${flaskid}'";
   $and = " AND flask_inv.sample_status_num='2'";
   
   $res = ccgg_query($select.$from.$where.$and);

   $n = count($res);
   if ($n == 0) { $err = "${flaskid} is no longer checked out."; }

   return $err;
}

#
# DB_SetEventNum #####################################################################
#
function DB_SetEventNum($aarr)
{
   #echo "<PRE>";
   #print_r($aarr);
   #echo "<PRE/>";

   $err = '';

   $select = "SELECT COUNT(*)";
   $from = " FROM flask_event";
   $where =" WHERE id='".$aarr['sample']['id']."'";
   $and = " AND date='".$aarr['sample']['date']."'";
   $and = "${and} AND time='".$aarr['sample']['time']."'";
   $and = "${and} AND me='".$aarr['sample']['method']."'";
   $and = "${and} AND site_num='".$aarr['sample']['site']['num']."'";
   $and = "${and} AND project_num='".$aarr['sample']['project']['num']."'";
   $and = "${and} AND strategy_num='".$aarr['sample']['strategy']['num']."'";

   $sql = $select.$from.$where.$and;
   #echo "$sql<BR>";
   $res = ccgg_query($sql);

   if ( $res[0] == '0' )
   {
      #
      # Create Event Number
      #
      $insert = " INSERT INTO flask_event";
      $list = " (num,site_num,project_num,strategy_num,date,time,dd,id,me,lat,lon,alt,comment)";

      $valuearr = array();
      array_push($valuearr, "NULL");
      array_push($valuearr, "'".$aarr['sample']['site']['num']."'");
      array_push($valuearr, "'".$aarr['sample']['project']['num']."'");
      array_push($valuearr, "'".$aarr['sample']['strategy']['num']."'");
      array_push($valuearr, "'".$aarr['sample']['date']."'");
      array_push($valuearr, "'".$aarr['sample']['time']."'");
      array_push($valuearr, "'".$aarr['sample']['dd']."'");
      array_push($valuearr, "'".$aarr['sample']['id']."'");
      array_push($valuearr, "'".$aarr['sample']['method']."'");
      array_push($valuearr, "'".$aarr['sample']['site']['lat']."'");
      array_push($valuearr, "'".$aarr['sample']['site']['lon']."'");
      if ( $aarr['sample']['site']['elev'] != '-9999.99' &&
           $aarr['sample']['site_desc']['intake_ht'] != '-9999.9' )
      {
         array_push($valuearr, "'".($aarr['sample']['site']['elev']+$aarr['sample']['site_desc']['intake_ht'])."'");
      }
      else
      {
         array_push($valuearr, "'-9999.99'");
      }
      array_push($valuearr, "'".$aarr['sample']['comment']."'");

      #print_r($valuearr);
      $values = ' VALUES('.join(',',$valuearr).')';

      $sql = $insert.$list.$values;
      #echo "$sql<BR>";
      $res = ccgg_insert($sql);
   }
   else
   {
      $err = "Event details already exist in DB.\\nNew event number not assigned.";
      return $err;
   }

   #
   # Get assigned event number
   #
   $select = "SELECT num";
   $from = " FROM flask_event";
   $where =" WHERE id='".$aarr['sample']['id']."'";
   $and = " AND date='".$aarr['sample']['date']."'";
   $and = "${and} AND time='".$aarr['sample']['time']."'";
   $and = "${and} AND me='".$aarr['sample']['method']."'";
   $and = "${and} AND site_num='".$aarr['sample']['site']['num']."'";
   $and = "${and} AND project_num='".$aarr['sample']['project']['num']."'";
   $and = "${and} AND strategy_num='".$aarr['sample']['strategy']['num']."'";
   $sql = $select.$from.$where.$and;
   #echo "$sql\n";

   $res = ccgg_query($sql);
   $ev_num = (isset($res[0])) ? $res[0] : 0;
   if ($ev_num == 0)
   {
      $err = "Problem retrieving event number in DB_SetEventNum";
      return $err;
   }

   $today=date("Y-m-d");
   #
   # Indicate that flask is now in analysis loop
   #
   $update = "UPDATE flask_inv";
   $set = " SET path = '".$aarr['sample']['path']."', event_num = '${ev_num}'";
   $set = $set.", sample_status_num = '3', date_in = '${today}'";
   $where = " WHERE id = '".$aarr['sample']['id']."'";

   $sql = $update.$set.$where;
   #echo "$sql<BR>";
   $res = ccgg_insert($sql);

   if (!empty($res)) { $err = "Update error in DB."; }

   return $err; 
}

#
# DB_GetSiteInfo #####################################################################
#
function DB_GetSiteInfo($inputaarr)
{
   $infoaarr = array();
   $table = "gmd.site";

   $sql = "DESCRIBE $table";
   $describeres = ccgg_query($sql);

   if ( isset($inputaarr['num']) && $inputaarr['num'] > -1 )
   { $sql = "SELECT * FROM $table WHERE num = '".$inputaarr['num']."'"; }
   elseif ( isset($inputaarr['code']) && $inputaarr['code'] != '' )
   { $sql = "SELECT * FROM $table WHERE code = '".$inputaarr['code']."'"; }
   else
   { $sql = "SELECT * FROM $table WHERE num != num"; }
   $selectres = ccgg_query($sql);

   $valueinfo = split("\|", $selectres[0]);
   for ( $i=0; $i<count($describeres); $i++ )
   {
      $fieldinfo = split("\|", $describeres[$i]);
      if ( !isset($valueinfo[$i])) { $valueinfo[$i] = ''; }
      $infoaarr[$fieldinfo[0]] = $valueinfo[$i];
   }

   return $infoaarr;
}
#
# DB_GetProjectInfo2 ####################################################################
#
function DB_GetProjectInfo2($inputaarr)
{
   $infoaarr = array();
   $table = "project";

   $sql = "DESCRIBE $table";
   $describeres = ccgg_query($sql);

   if ( isset($inputaarr['num']) && $inputaarr['num'] > -1 )
   { $sql = "SELECT * FROM $table WHERE num = '".$inputaarr['num']."'"; }
   elseif ( isset($inputaarr['abbr']) && $inputaarr['abbr'] != '' )
   { $sql = "SELECT * FROM $table WHERE abbr = '".$inputaarr['abbr']."'"; }
   else
   { $sql = "SELECT * FROM $table WHERE num != num"; }
   $selectres = ccgg_query($sql);

   $valueinfo = split("\|", $selectres[0]);
   for ( $i=0; $i<count($describeres); $i++ )
   {
      $fieldinfo = split("\|", $describeres[$i]);
      if ( !isset($valueinfo[$i])) { $valueinfo[$i] = ''; }
      $infoaarr[$fieldinfo[0]] = $valueinfo[$i];
   }

   return $infoaarr;
}
#
# DB_GetStrategyInfo2 ####################################################################
#
function DB_GetStrategyInfo2($inputaarr)
{
   $infoaarr = array();
   $table = "ccgg.strategy";

   $sql = "DESCRIBE $table";
   $describeres = ccgg_query($sql);

   if ( isset($inputaarr['num']) && $inputaarr['num'] > -1 )
   { $sql = "SELECT * FROM $table WHERE num = '".$inputaarr['num']."'"; }
   elseif ( isset($inputaarr['abbr']) && $inputaarr['abbr'] != '' )
   { $sql = "SELECT * FROM $table WHERE abbr = '".$inputaarr['abbr']."'"; }
   else
   { $sql = "SELECT * FROM $table WHERE num != num"; }
   $selectres = ccgg_query($sql);

   $valueinfo = split("\|", $selectres[0]);
   for ( $i=0; $i<count($describeres); $i++ )
   {
      $fieldinfo = split("\|", $describeres[$i]);
      if ( !isset($valueinfo[$i])) { $valueinfo[$i] = ''; }
      $infoaarr[$fieldinfo[0]] = $valueinfo[$i];
   }

   return $infoaarr;
}
#
# DB_GetSiteDescInfo #################################################################
#
function DB_GetSiteDescInfo($inputaarr)
{
   $infoaarr = array();
   $table = "ccgg.site_desc";

   $sql = "DESCRIBE $table";
   $describeres = ccgg_query($sql);

   if ( isset($inputaarr['site_num']) && $inputaarr['site_num'] > -1 &&
        isset($inputaarr['project_num']) && $inputaarr['project_num'] > -1 &&
        isset($inputaarr['strategy_num']) && $inputaarr['strategy_num'] > -1 )
   { 
      $select = " SELECT *";
      $from = " FROM $table";
      $where = " WHERE site_num = '".$inputaarr['site_num']."'";
      $and = " AND project_num = '".$inputaarr['project_num']."'";
      $and = "${and} AND strategy_num = '".$inputaarr['strategy_num']."'";
      $sql = $select.$from.$where.$and;
   }
   else
   { $sql = "SELECT * FROM $table WHERE site_num != site_num"; }
   $selectres = ccgg_query($sql);

   $valueinfo = split("\|", $selectres[0]);
   for ( $i=0; $i<count($describeres); $i++ )
   {
      $fieldinfo = split("\|", $describeres[$i]);
      if ( !isset($valueinfo[$i])) { $valueinfo[$i] = ''; }
      $infoaarr[$fieldinfo[0]] = $valueinfo[$i];
   }

   return $infoaarr;
}
?>
