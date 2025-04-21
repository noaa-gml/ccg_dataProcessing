<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");
include ("/var/www/html/inc/dbutils/dbutils.php");
db_connect();


if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : 'om';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : 'om';

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$stacode = isset( $_POST['stacode'] ) ? $_POST['stacode'] : '';
$proj_abbr = isset( $_POST['proj_abbr'] ) ? $_POST['proj_abbr'] : '';
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';
$site_info = isset( $_POST['site_info'] ) ? $_POST['site_info'] : '';
$desc_info = isset( $_POST['desc_info'] ) ? $_POST['desc_info'] : '';
$coop_info = isset( $_POST['coop_info'] ) ? $_POST['coop_info'] : '';
$spon_info = isset( $_POST['spon_info'] ) ? $_POST['spon_info'] : '';
$ship_info = isset( $_POST['ship_info'] ) ? $_POST['ship_info'] : '';

BuildBanner($strat_name,$strat_abbr,GetUser(),true);
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='om_siteedit.js'></SCRIPT>";

#if ( $strat_name == "Flask" ) { $strat_name = "Surface"; }
#if ( $strat_abbr == "flask" ) { $strat_abbr = "ccg_surface"; }

$yr = date("Y");
$log = "{$omdir}log/{$strat_abbr}.{$yr}";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

switch ($task)
{
   case 'addsite':
      if ($strat_abbr == 'om')
      {
         if (DB_AddSite($stacode))
         { UpdateLog($log,"{$stacode} added to DB"); }
         else { JavaScriptAlert("Unable to add {$stacode} to DB"); }
         $task = '';
      }
      else { JavaScriptAlert("Sites may only be added at OM level"); }
   break;
   case 'update':
      if ($strat_abbr == 'om')
      {
         $table = 'gmd.site';
         if (DB_UpdateInfo($table,$stacode,$site_info,$proj_abbr,$strat_abbr))
         { UpdateLog($log,"{$stacode} updated in {$table}"); }
         else { JavaScriptAlert("Unable to update {$table}"); }
      }
      else
      {
         $table = 'site_desc';
         if (DB_UpdateInfo($table,$stacode,$desc_info,$proj_abbr,$strat_abbr))
         { UpdateLog($log,"{$stacode} {$strat_abbr} updated in {$table}"); }
         else { JavaScriptAlert("Unable to update {$table}"); }

         $table = 'site_coop';
         if (DB_UpdateInfo($table,$stacode,$coop_info,$proj_abbr,$strat_abbr))
         { UpdateLog($log,"{$stacode} {$strat_abbr} updated in {$table}"); }
         else { JavaScriptAlert("Unable to update {$table}"); }

         $table = 'site_shipping';
         if (DB_UpdateInfo($table,$stacode,$ship_info,$proj_abbr,$strat_abbr))
         { UpdateLog($log,"{$stacode} {$strat_abbr} updated in {$table}"); }
         else { JavaScriptAlert("Unable to update {$table}"); }
      }
   break;
   case 'delete':
      if ($strat_abbr == 'om')
      {
         $table = 'gmd.site';
         if (DB_DeleteInfo($table,$stacode,$proj_abbr,$strat_abbr))
         { UpdateLog($log,"{$stacode} deleted from {$table}"); }
         else { JavaScriptAlert("Unable to delete from {$table}"); }
      }
      $table = 'site_desc';
      if (DB_DeleteInfo($table,$stacode,$proj_abbr,$strat_abbr))
      { UpdateLog($log,"{$stacode} {$strat_abbr} deleted from {$table}"); }
      else { JavaScriptAlert("Unable to delete from {$table}"); }

      $table = 'site_coop';
      if (DB_DeleteInfo($table,$stacode,$proj_abbr,$strat_abbr))
      { UpdateLog($log,"{$stacode} {$strat_abbr} deleted from {$table}"); }
      else { JavaScriptAlert("Unable to delete from {$table}"); }

      $table = 'site_shipping';
      if (DB_DeleteInfo($table,$stacode,$proj_abbr,$strat_abbr))
      { UpdateLog($log,"{$stacode} {$strat_abbr} deleted from {$table}"); }
      else { JavaScriptAlert("Unable to delete from {$table}"); }
   break;
}
#
# Server side to client side
#
$siteinfo = DB_GetSiteList2($strat_abbr);
for ($i=0,$z=''; $i<count($siteinfo); $i++)
{
   $field = split("\|",$siteinfo[$i]);
   $z = ($i == 0) ? $field[1] : "{$z},{$field[1]}";
}
JavaScriptCommand("sites = \"{$z}\"");
#
# Server side to client side
#
$sysinfo = DB_GetSystemDefi();
for ($i=0,$z=''; $i<count($sysinfo); $i++)
{
   $z = ($i == 0) ? $sysinfo[$i] : "{$z}~{$sysinfo[$i]}";
}
JavaScriptCommand("sysinfo = \"{$z}\"");
#
# Server side to client side
#
$statusinfo = DB_GetStatus();
for ($i=0,$z=''; $i<count($statusinfo); $i++)
{
   $z = ($i == 0) ? $statusinfo[$i] : "{$z}~{$statusinfo[$i]}";
}
JavaScriptCommand("statusinfo = \"{$z}\"");

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global   $strat_abbr;
global   $proj_abbr;
global   $stacode;
global   $siteinfo;
global   $nsubmits;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='task'>";
echo "<INPUT TYPE='HIDDEN' NAME='stacode' VALUE={$stacode}>";
echo "<INPUT type='hidden' name='strat_abbr' value=$strat_abbr>";
echo "<INPUT type='hidden' name='proj_abbr' value=$proj_abbr>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<INPUT type='hidden' name='site_info'>";
echo "<INPUT type='hidden' name='desc_info'>";
echo "<INPUT type='hidden' name='coop_info'>";
echo "<INPUT type='hidden' name='spon_info'>";
echo "<INPUT type='hidden' name='ship_info'>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Site Manager</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE align='center' width=90% border='0' cellpadding='2' cellspacing='2'>";
#
##############################
# Row 1: Column Headers
##############################
#
#
##############################
# Row 2: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";
echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='1' onChange='SiteListCB()'>";

echo "<OPTION VALUE=''>Select Site</OPTION>";
for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp=split("\|",urldecode($siteinfo[$i]));
   $selected = (!(strcasecmp($tmp[1],$stacode))) ? 'SELECTED' : '';
   $z = sprintf("%s (%s) - %s, %s",$tmp[1],$tmp[0],$tmp[2],$tmp[3]);
   echo "<OPTION $selected VALUE=$tmp[1]>{$z}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "<TD>";
echo "<B><INPUT TYPE='text' class='MediumSizeBlackTurquoiseB' onChange='SearchCB()' SIZE=4 NAME='search4code'>";

JavaScriptCommand("document.mainform.search4code.focus()");

echo "<B><INPUT TYPE='button' class='Btn' value='Search' onClick='SearchCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Update' onClick='UpdateCB(\"{$strat_abbr}\")'>";
echo "</TD>";

if ($strat_abbr == 'om')
{
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Delete' onClick='DeleteCB(\"{$strat_abbr}\")'>";
   echo "</TD>";
}

echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='history.go({$nsubmits});'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

$site_num = DB_GetSiteNum($stacode);

if ($site_num)
{
   $site_num = DB_GetSiteNum($stacode);
   $strat_num = DB_GetStrategyNum($strat_abbr);
   if ( empty($proj_abbr) )
   {
      $info = DB_FindDefaultProject($site_num, $strat_num);
      if ( $info == 0 ) { $info = "0|"; }
      list ( $proj_num, $proj_abbr ) = split ( "\|", $info );
      JavaScriptCommand("document.mainform.proj_abbr.value = '{$proj_abbr}'");
   }
   else { $proj_num = DB_GetProjectNum($proj_abbr); }

   #echo "INFO: $proj_abbr $proj_num";

   echo "<TABLE align='center' col=2 width=75% border='0' cellpadding='2' cellspacing='2'>";

   switch($strat_abbr)
   {
   case 'om':
      PostTable2Edit('gmd.site',$site_num,$proj_num,$strat_num,'DEFINITION');
      break;
   default:

      PostTable('gmd.site',$site_num,$proj_num,$strat_num,'DEFINITION');
      PostTable2Edit('site_desc',$site_num,$proj_num,$strat_num,'DESCRIPTION');
      PostTable2Edit('site_coop',$site_num,$proj_num,$strat_num,'COOPERATING AGENCY');
      PostTable2Edit('site_shipping',$site_num,$proj_num,$strat_num,'SHIPPING and RECEIVING');
      break;
   }
   echo "</TABLE>";

}
#echo DB_getArchiveHistoryPopup('site_coop_archive',$site_num,$proj_num,$strat_num);
#echo DB_getArchiveHistoryPopup('site_shipping_archive',$site_num,$proj_num,$strat_num);
echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetTableContents ########################################################
#

function DB_GetTableContents($t,$site_num,$proj_num,$strat_num)
{
   #
   # Get contents of passed table
   #
   ccgg_fields($t,$name,$type,$length);

   for ($i=0,$and=''; $i<count($name); $i++)
   {
      if ($name[$i] == 'strategy_num') { $and = "{$and} AND strategy_num='{$strat_num}'"; }
      if ($name[$i] == 'project_num') { $and = "{$and} AND project_num='{$proj_num}'"; }
   }

   $z = ($t == 'gmd.site') ? 'num' : 'site_num';

   $select = "SELECT * ";
   $from = " FROM {$t}";
   $where = " WHERE {$z}='{$site_num}'";

   return ccgg_query($select.$from.$where.$and);
}
#
# Function PostTable ########################################################
#
function PostTable($t,$site_num,$proj_num,$strat_num,$title)
{
   $hline = str_pad('_',50,'_');

   echo "<TR>";
   echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>{$hline}</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD class='LargeBlueB' COLSPAN=2 ALIGN='center'>{$title}</TD>";
   echo "</TR>";
   echo "<TR><TD></TD></TR>";
   echo "<TR>";

   $res = ccgg_fields($t,$name,$type,$length);
   $info = DB_GetTableContents($t,$site_num,$proj_num,$strat_num);

        if ( isset($info[0]) ) { $field = split("\|",$info[0]); }

   for ($i=0; $i<count($name); $i++)
   {
      if ($name[$i] == 'flag') continue;
      if ($name[$i] == 'topo') continue;
      if ($name[$i] == 'windrose') continue;

      $value = urldecode($field[$i]);
      echo "<TR>";
      echo "<TD ALIGN='right' class='LargeBlueN'>$name[$i]</TD>";
      echo "<TD ALIGN='left' class='MediumBlackN'>$value</TD>";
      echo "</TR>";
   }
}
#
# Function PostTable2Edit ########################################################
#
function PostTable2Edit($t,$site_num,$proj_num,$strat_num,$title)
{

   $hline = str_pad('_',50,'_');
   $link='';
   if($t=='site_coop')$link=DB_getArchiveHistoryLink("site_coop",$site_num,$proj_num,$strat_num);
   elseif($t=='site_shipping')$link=DB_getArchiveHistoryLink("site_shipping",$site_num,$proj_num,$strat_num);


   echo "<TR>";
   echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>{$hline}</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD class='LargeBlueB' COLSPAN=2 ALIGN='center'>{$title}<span class='title4' style='float:right'>$link</span></TD>";
   echo "</TR>";
   echo "<TR><TD></TD></TR>";
   echo "<TR>";

   $res = ccgg_fields($t,$name,$type,$length);
   $info = DB_GetTableContents($t,$site_num,$proj_num,$strat_num);

   if ( isset($info[0]) ) { $field = split("\|",$info[0]); }

   for ($i=0; $i<count($name); $i++)
   {
      if ($name[$i] == 'strategy_num') continue;
      if ($name[$i] == 'site_num') continue;

      $value = '';
      if ( isset($field[$i]) ) { $value = urldecode($field[$i]); }

      echo "<TR>";

      if ($name[$i] == 'project_num')
      {
         if ( $t == "site_desc" )
         {
            CreateProjectSelectButton($site_num, $value, $strat_num, $proj_num);
         }
         continue;
      }
      elseif ($name[$i] == 'default_project')
      {
         $checked = ( $value ) ? "CHECKED" : "";
         echo "<TD ALIGN='right' class='LargeBlueN'>default?</TD>";
         echo "<TD>";
         echo "<INPUT type=checkbox name='default_project' class='MediumBlackN' $checked>";
         echo "</TD>";
         continue;
      }elseif($name[$i]=='include_temp_rh'){
	if($strat_num==2){#Not relevant for flasks, just pfps (for now).  Default value is 0, so anything not checked in below box gets a 0.
        #jwm - 6/17 - adding check box to include temp_rh readings (for sites with sensors) because we get false positives (sometimes) otherwise
        	$checked = ($value)?"CHECKED" : "";
		$help="<button name='help' onClick='alert(\"Check this box to include Temp & RH readings when downloading a pfp.  PFPs from sites without actual sensors hooked up can pass garbage values for temperature and relative humidity that end up in the database.  This check box determines whether the Temp and RH will be imported or skipped during download/checkin for PFPs from this site/project.  You can temporarily check/uncheck the box for special circumstances\");return false;' >?</button>";
        	echo "<td align='right' class='LargeBlueN'>Include Temp & RH?</td><td><input type='checkbox' name='include_temp_rh' class='MediumBlackN' $checked>$help</td>";
	}
        continue;

      }elseif ($name[$i] == 'status_num')
      {
         CreateStatusSelectButton($value);
         continue;
      }
	$displayName=$name[$i];
	if($name[$i]=='target_num_checked_out')$displayName='Target # flask/pfps checked out';
      echo "<TD ALIGN='right' class='LargeBlueN'>$displayName</TD>";

      if ($name[$i] == 'num')
      {
         echo "<TD ALIGN='left' class='LargeBlackN'>$value</TD>";
         continue;
      }


      switch ($type[$i])
      {
      case "blob":
         echo "<TD ALIGN='left'>";
         echo "<TEXTAREA class='MediumBlackN' name='{$t}:$name[$i]' cols=60 rows=5
         onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
         echo $value;
         echo "</TEXTAREA></TD>";
         break;
      default:
         $value=htmlspecialchars($value,ENT_QUOTES);//Perhaps this should be done for all types (blob too?).  Following minimal change doctrine for quick fix of single quotes issue. jwm 1/16
         echo "<TD ALIGN='left'>";
         echo "<INPUT type=text class='MediumBlackN'
         name='{$t}:$name[$i]' value='{$value}' size='60'
         onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";

         if ($name[$i] == 'meas_path')
         { echo "<INPUT TYPE='button' class='Btn' value='?' onClick='PathListCB()'>"; }

         if ($name[$i] == 'samplesheet')
         { echo "<INPUT TYPE='button' class='Btn' value='?' onClick='SampleSheetCB()'>"; }

         echo "</TD>";
         break;
      }
      echo "</TR>";
   }
}
#
# Function CreateProjectSelectButton ####################################################
#
function CreateProjectSelectButton($site_num, $proj_num, $strat_num, $base_proj)
{

   echo "<TD ALIGN='right' class='LargeBlueN'>project</TD>";
   echo "<TD ALIGN='left'>";

   $projinfo = DB_GetAllProjectInfo();

   $select = " SELECT project_num";
   $from = " FROM site_desc";
   $where = " WHERE site_num = '$site_num' AND strategy_num = '$strat_num'";
   $order = " ORDER BY project_num";

   $sql = $select.$from.$where.$order;
   #echo "<BR>$sql<BR>";
   $availproj = ccgg_query($sql);
   #print_r ($availproj);

   #$select = " SELECT project_num";
   #$from = " FROM site_desc";
   #$where = " WHERE site_num = '$site_num' AND strategy_num = '$strat_num'";
   #$and = " AND base = '1'";
   #
   #$sql = $select.$from.$where.$and;
   #echo "<BR>$sql<BR>";
   #$res = ccgg_query($sql);
   #if ( empty($res) )
   #{
   #   if ( empty($availproj) ) { $base_proj = '0'; }
   #   else { $base_proj = $availproj[0]; }
   #}
   #else { $base_proj = $res[0]; }
   #echo "<BR>$base_proj<BR>";;

   echo "<SELECT NAME='projlist' class='MediumBlackN' SIZE=1 onChange='ProjectListCB()'>";
   echo "<OPTION VALUE='0'>None</OPTION>";
   for ($i=0; $i<count($projinfo); $i++)
   {
      $field = split("\|",$projinfo[$i]);

                $class = ( in_array($field[0], $availproj ) ) ? "MediumBlackN" : "MediumGrayN";
                $selected = ( $field[0] == $base_proj ) ? "SELECTED" : "";

      echo "<OPTION class='$class' VALUE='$field[2]' $selected>$field[1]</OPTION>";
   }
   echo "</SELECT>";

   #echo "<INPUT TYPE='button' class='Btn' value='?' onClick='StatusListCB()'>";
   echo "</TD>";
}
#
# Function CreateStatusSelectButton ####################################################
#
function CreateStatusSelectButton($status_num)
{

   echo "<TD ALIGN='right' class='LargeBlueN'>status</TD>";
   echo "<TD ALIGN='left'>";
   echo "<SELECT NAME='status' class='MediumBlackN' SIZE=1>";

   $info = DB_GetStatus();

   echo "<OPTION VALUE='0'>None</OPTION>";
   for ($i=0; $i<count($info); $i++)
   {
      $field = split("\|",$info[$i]);
      $selected=($field[0] == $status_num) ? "SELECTED" : "";

      echo "<OPTION VALUE='$field[0]' $selected>$field[1]</OPTION>";
   }
   echo "</SELECT>";

   echo "<INPUT TYPE='button' class='Btn' value='?' onClick='StatusListCB()'>";
   echo "</TD>";
}
#
# Function DB_GetSiteList2 ########################################################
#
function DB_GetSiteList2($strategy_abbr)
{
   $arr1 = array();
   $arr2 = array();
   $arr3 = array();

   $strat_num = DB_GetStrategyNum($strategy_abbr);

   $select = "SELECT DISTINCT gmd.site.num,gmd.site.code,gmd.site.name";
   $select = "{$select},gmd.site.country";
   $from = " FROM gmd.site,site_desc";
   $where = " WHERE gmd.site.num=site_desc.site_num";
   $and = " AND site_desc.strategy_num = '{$strat_num}'";
   $etc = " ORDER BY gmd.site.code ASC";
   $arr1 = ccgg_query($select.$from.$where.$and.$etc);

   $select = "SELECT DISTINCT gmd.site.num,gmd.site.code,gmd.site.name";
   $select = "{$select},gmd.site.country";
   $from = " FROM gmd.site,site_desc";
   $where = " WHERE gmd.site.num=site_desc.site_num";
   $and = " AND site_desc.strategy_num != '{$strat_num}'";
   $etc = " ORDER BY gmd.site.code ASC";
   $arr2 = ccgg_query($select.$from.$where.$and.$etc);

   #
   # If a site already exists in the $arr1, remove it from $arr2
   #
   for ($i=0; $i<count($arr2); $i++)
   {
      if ( in_array($arr2[$i], $arr1) ) { unset($arr2[$i]); }
   }

   $arr2 = array_values($arr2);

   #
   # Include in list, sites that have no project assigned to them
   #
   $select = "SELECT DISTINCT num,code,name,country";
   $from = " FROM gmd.site LEFT JOIN site_desc";
   $on = " ON gmd.site.num = site_desc.site_num";
   $where = " WHERE site_desc.site_num IS NULL";
   $etc = " ORDER BY code";
   $arr3 = ccgg_query($select.$from.$on.$where.$etc);

   $arr = array_merge($arr1,$arr2,$arr3);
   return array_values(array_unique($arr));
}
#
# Function DB_AddSite ########################################################
#
function DB_AddSite($c)
{
   #
   # Insert site into DB
   #
   $sql = "INSERT INTO gmd.site (code) VALUES('{$c}')";
   #echo "$sql";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_FindDefaultProject ###################################################
#
function DB_FindDefaultProject ($site_num, $strategy_num)
{
   $select = " SELECT site_desc.project_num, project.abbr";
   $from = " FROM site_desc, project";
   $where = " WHERE site_num = '$site_num' and strategy_num = '$strategy_num'";
   $and = " AND site_desc.project_num = project.num";
   $etc = " ORDER BY default_project DESC LIMIT 1";

   $sql = $select.$from.$where.$and.$etc;
   #echo "$sql<BR>";

   $res = ccgg_query($sql);

   if ( empty ( $res ) ) { return 0; }
   return $res[0];

}
#
# Function DB_UpdateInfo ########################################################
#
function DB_UpdateInfo($t,$c,$s,$p,$st)
{
   $num = DB_GetSiteNum($c);
   $proj_num = DB_GetProjectNum($p);
   $strat_num = DB_GetStrategyNum($st);
   $datapairs = split("\|",$s);
   $task = 'update';
   $archive = false;
   if ($t != 'gmd.site')
   {
      #
      # Do we need to INSERT or UPDATE?
      #
      $sql = "SELECT COUNT(*) FROM {$t} WHERE site_num='{$num}' AND project_num='{$proj_num}' AND strategy_num = '{$strat_num}'";
      #echo "<BR>$sql<BR>";
      $res = ccgg_query($sql);

      $task = ($res[0] == '0') ? 'insert' : 'update';
   }

   switch ($task)
   {
   case 'insert':
      for ($i=0,$acc='',$list='',$values=''; $i<count($datapairs); $i++)
      {
         list($n,$v) = split("~",$datapairs[$i]);
         if ( $t == "site_desc" && $n == "default_project" && $v == 1 )
         {
            if ( !DB_ClearDefaultProject($num, $strat_num) )
            { return (FALSE); }
         }
	if($v){//jwm 5/23. conditional because '' isn't valid default value on new server version.
         $acc = "{$acc}{$v}";
         $v = addslashes($v);
         $list = ($list=='') ? "{$n}" : "{$list},{$n}";
         $values = ($values == '') ? "'{$v}'" : "{$values},'{$v}'";
	}
      }
      $sql = "INSERT INTO {$t} (site_num,project_num,strategy_num,{$list})";
      $sql = "{$sql} VALUES('{$num}','{$proj_num}','{$strat_num}',{$values})";
      break;
   case 'update':
//var_dump($datapairs);exit;
      for ($i=0,$acc='',$set=''; $i<count($datapairs); $i++)
      {
         list($n,$v) = split("~",$datapairs[$i]);
         if ( $t == "site_desc" && $n == "default_project" && $v == 1 )
         {
            if ( !DB_ClearDefaultProject($num, $strat_num) )
            { return (FALSE); }
         }
	#if($v){#removed because we relaxed server restrictions and because its needed to remove a value
	 $v=trim($v);#jwm 8/23. added because trailing spaces on meas_path caused chaos.
         $acc = "{$acc}{$v}";
         $v = addslashes($v);
         $set = ($set== '') ? "{$n}='{$v}'" : "{$set},{$n}='{$v}'";
	#}
      }
      $sql = "UPDATE {$t} SET {$set}";

      if ($t == 'gmd.site') $sql = "{$sql} WHERE num='{$num}'";
      else{
         $sql = "{$sql} WHERE site_num='{$num}' AND project_num='{$proj_num}' AND strategy_num='{$strat_num}'";
         $archive=DB_snapshotEntry($t,$num,$proj_num,$strat_num);
      }
      break;
   }
   #
   # Do not create a table entry if all fields are empty
   #
   if (empty($acc)) { DB_DeleteInfo($t,$c,$p,$st); }
   else
   {
      #echo "$sql";
      $res = ccgg_insert($sql);
      #$res = "";
      if (!empty($res)) {var_dump($sql); return(FALSE); }
      elseif($archive) {
         DB_saveArchiveSnapShot($t);
      }
   }
   return(TRUE);
}
#Archiving...
function DB_snapshotEntry($table,$site_num,$project_num,$strategy_num){
   #Make a copy of the row to insert into the archive if update is successful.
   ccgg_insert("drop temporary table if exists t_archive");
   $res=ccgg_insert("create temporary table t_archive as select * from $table where site_num='$site_num' AND project_num='$project_num' AND strategy_num='$strategy_num'");
   $archive=(empty($res));
   return $archive;
}
function DB_saveArchiveSnapShot($t,$force=false){
   #Takes snapshot and stores in archive table if changed.  Pass force true to save even if no change (before deleting).
   $sql='';
   #We'll archive select tables.  Only on updates.  This is a convienence, not bullet proof history (deletes are saved currently). jwm -7-18.
   #Note, if no entries are present in a table, the logic of this page deletes the entry which then doesn't get archived.  Not ideal, but not a huge issue as it's not expected to happen in regular practice.
   if($t=='site_coop'){
      $c="select count(*) from site_coop c join t_archive a on c.site_num=a.site_num and c.project_num=a.project_num and c.strategy_num=a.strategy_num
            where c.name!=a.name or c.abbr!=a.abbr or c.url!=a.url or c.logo!=a.logo or c.contact!=a.contact or c.address!=a.address or c.tel!=a.tel
            or c.fax!=a.fax or c.email!=a.email or c.comment!=a.comment";
      $res=ccgg_query($c);#This is called on all tables, so check to see if anything interesting actually changed before archiving.
      if($res[0]==1 || $force)$sql="insert site_coop_archive (site_num,project_num,strategy_num,name,abbr,url,logo,contact,address,tel,fax,email,comment,modification_datetime)
         select site_num,project_num,strategy_num,name,abbr,url,logo,contact,address,tel,fax,email,comment,now() from t_archive";
   }elseif($t=='site_shipping'){
      $c="select count(*) from site_shipping c join t_archive a on c.site_num=a.site_num and c.project_num=a.project_num and c.strategy_num=a.strategy_num
         where c.send_address!=a.send_address or c.send_carrier!=a.send_carrier or c.send_doc!=a.send_doc or c.send_comments!=a.send_comments or c.return_address!=a.return_address
         or c.return_carrier!=a.return_carrier or c.return_doc!=a.return_doc or c.return_comments!=a.return_comments or c.samplesheet!=a.samplesheet or c.meas_path!=a.meas_path
         or c.flask_type!=a.flask_type or c.name!=a.name or c.tel!=a.tel or c.fax!=a.fax or c.email!=a.email or c.mail_address!=a.mail_address or c.name2!=a.name2 or
         c.tel2!=a.tel2 or c.fax2!=a.fax2 or c.email2!=a.email2";
      $res=ccgg_query($c);
      if($res[0]==1 || $force)$sql="insert site_shipping_archive (site_num,project_num,strategy_num,send_address,send_carrier,send_doc,send_comments,return_address,return_carrier,return_doc,
         return_comments,samplesheet,meas_path,flask_type,name,tel,fax,email,mail_address,name2,tel2,fax2,email2,modification_datetime)
         select site_num,project_num,strategy_num,send_address,send_carrier,send_doc,send_comments,return_address,return_carrier,return_doc,
         return_comments,samplesheet,meas_path,flask_type,name,tel,fax,email,mail_address,name2,tel2,fax2,email2,now() from t_archive";
   }
   #var_dump($sql);
   if($sql)ccgg_insert($sql);#don't error chk.
}
function DB_getArchiveHistoryLink($table,$site_num,$project_num,$strategy_num){
   #Tried to integrate nice jquery popups and display logic, but the js was a disaster. Separated new logic into new set of pages
   if($table=='site_coop')$label="Cooperating Agency History";
   elseif($table='site_shipping')$label='Shipping and Receiving History';
   else return 'unknow table';
   $label='History';#actually, just short it.
   $html="<a href='j/index.php?mod=smh&table=$table&site_num=$site_num&project_num=$project_num&strategy_num=$strategy_num' target='_new'>$label</a>";
   return $html;
}
#
# Function DB_DeleteInfo ########################################################
#
function DB_DeleteInfo($t,$c,$p,$st)
{
   $num = DB_GetSiteNum($c);
   $proj_num = DB_GetProjectNum($p);
   $strat_num = DB_GetStrategyNum($st);
   $archive=false;

   if($t=='site_coop' || $t='site_shipping'){
      $archive=DB_snapshotEntry($t,$num,$proj_num,$strat_num);
   }


   $and = ($st == 'om') ? '' : "AND project_num='{$proj_num}' AND strategy_num='{$strat_num}'";

   if ($t != 'gmd.site')
   { $sql = "DELETE FROM {$t} WHERE site_num='{$num}' {$and}"; }
   else { $sql = "DELETE FROM {$t} WHERE num='{$num}'"; }

   #echo "$sql";
   $res = ccgg_delete($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   if($archive)DB_saveArchiveSnapShot($t,true);
   return(TRUE);
}
#
# Function DB_ClearDefaultProject######################################################
#
function DB_ClearDefaultProject($site_num, $strategy_num)
{
   $update = " UPDATE site_desc";
   $set = " SET default_project = '0'";
   $where = " WHERE site_num = '{$site_num}' AND strategy_num = '{$strategy_num}'";

   $sql = $update.$set.$where;
   #echo "$sql";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
?>
