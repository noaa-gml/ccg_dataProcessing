<?php
# om_inc.php
# jwm. 4/25.  Made several updates to make work in current PHP during server build.
#
$bg_color = "EEEEEEEE";
$omdir = "/var/www/html/om/";
$omurl = "/om/";
#For dev directory...
$cwd=getcwd();
if($cwd=='/var/www/html/mund/om/flask' || $cwd=='/var/www/html/mund/om/pfp'){
	$omdir="/var/www/html/mund/om";
	$omurl="/mund/om/";
}
$user = "";

$ccgg_equip = 'ccgg_equip';
#
# ccgg_db common functions
#
#
# Function ccgg_connect ########################################################
#
function ccgg_connect()
{
 
    require_once("/var/www/html/inc/dbutils/dbutils.php");
    db_connect('','','','','');
    return true;

}
#
# Function ccgg_disconnect ########################################################
#
function ccgg_disconnect($db_c)
{
   #mysql_close($db_c);
}
#
# Function ccgg_insert ########################################################
#
function ccgg_insert($sql)
{
    $result = doquery($sql);
    if ($result === false) {
        return "Error in query: $sql";
    }
    return ""; // No error
   # if (!mysql_query($sql)) return(mysql_error());
   #else return("");
}
#
# Function ccgg_delete ########################################################
#
function ccgg_delete($sql)
{
    $result = doquery($sql);
    if ($result === false) {
        return "Error in query: $sql";
    }
    return ""; // No error

   # if (!mysql_query($sql)) return(mysql_error());
   #else return("");
}
#
# Function ccgg_query ########################################################
#
function ccgg_query($sql,$delimiter='|')
{
   $rows = doquery($sql);
    if ($rows === false) {
        return "Error in query: $sql";
    }

    $arr = array();
    foreach ($rows as $row) {
        $z = array_values($row); // Extract values as a simple array
        $arr[] = implode($delimiter, $z); // Combine values with "|"
    }

    return $arr; // Array of concatenated row values

   /*$result=mysql_query($sql);

    if (!$result) return(mysql_error());

    $arr=array();
   while($row=mysql_fetch_row($result))
   {
      $z=array();
      for ($i=0,$str=""; $i<mysql_num_fields($result); $i++)
      {
         $z[]=$row[$i];
      }
      $arr[]=implode($delimiter,$z);
   }
   mysql_free_result($result);
    return($arr);*/
}
#
# Function ccgg_query2 ########################################################
#
function ccgg_query2($sql)
{
    $rows = doquery($sql);
    if ($rows === false) {
        return "Error in query: $sql";
    }

    return $rows; // Return the result set as an array of associative arrays
/*
   $result=mysql_query($sql);

    if (!$result) return(mysql_error());

    $arr=array();
   while($row=mysql_fetch_array($result))
   {
      $arr[]=$row;
   }
   mysql_free_result($result);
   return($arr);*/
}
#
# Function ccgg_fields ########################################################
#
function ccgg_fields($table,&$field_name,&$field_type,&$field_len)
{
global   $omdb;

    $sql = "DESCRIBE $table"; // Use the DESCRIBE statement to fetch field info
    $rows = doquery($sql);

    if ($rows === false) {
        return false; // Query failed
    }

    $field_name = array();
    $field_type = array();
    $field_len = array();

    foreach ($rows as $row) {
        $field_name[] = $row['Field'];
        $field_type[] = $row['Type'];

        // Extract field length if possible
        if (preg_match('/\((\d+)\)/', $row['Type'], $matches)) {
            $field_len[] = (int)$matches[1];
        } else {
            $field_len[] = null; // Unknown length
        }
    }

    return true; // Success
    /*
   $result=mysql_query("SHOW COLUMNS FROM $table");

    if (!$result) return(FALSE);

   $field_len=array();
   $field_name=array();
   $field_type=array();

        if (mysql_num_rows($result) > 0)
        {
           while ($row = mysql_fetch_assoc($result))
           {
              $field_len[]=mysql_fetch_lengths($result);
              $field_name[]=$row["Field"];
              $field_type[]=$row["Type"];
           }
        }

   mysql_free_result($result);
   return(TRUE);*/
}
#
# Function DB_GetProjectNum ########################################################
#
function DB_GetProjectNum($abbr)
{
   #
   # Get project number
   #
   $sql="SELECT num FROM project WHERE abbr='${abbr}'";
   $res = ccgg_query($sql);
   $z = (empty($res)) ? 0 : $res[0];
   return $z;
}
#
# Function DB_GetProjectInfo ########################################################
#
function DB_GetProjectInfo($num)
{
   #
   # Get project name and abbreviation
   #
   $sql="SELECT name,abbr FROM project WHERE num='${num}'";
   $res = ccgg_query($sql);
   $z = (empty($res)) ? 0 : $res[0];
   return $z;
}
#
# Function DB_GetAllProjectInfo ########################################################
#
function DB_GetAllProjectInfo($delimiter='|')
{
   #
   # Get project information
   #
   $sql = "SELECT num, name, abbr, description, comments FROM project";
   return ccgg_query($sql,$delimiter);
}
#
# Function DB_GetStrategyNum ########################################################
#
function DB_GetStrategyNum($abbr)
{
   #
   # Get strategy number
   #
   $sql="SELECT num FROM strategy WHERE abbr='${abbr}'";
   $res = ccgg_query($sql);
   $z = (empty($res)) ? 0 : $res[0];
   return $z;
}
#
# Function DB_GetStrategyInfo ########################################################
#
function DB_GetStrategyInfo($num)
{
   #
   # Get project name and abbreviation
   #
   $sql="SELECT name,abbr FROM strategy WHERE num='${num}'";
   $res = ccgg_query($sql);
   $z = (empty($res)) ? 0 : $res[0];
   return $z;
}
#
# Function DB_GetAllStrategyInfo ########################################################
#
function DB_GetAllStrategyInfo($delimiter='|')
{
   #
   # Get project information
   #
   $sql = "SELECT num, name, abbr FROM strategy";
   return ccgg_query($sql,$delimiter);
}
#
# Function DB_GetSiteNum ########################################################
#
function DB_GetSiteNum($code)
{
   #
   # Get site number
   #
   $sql="SELECT num FROM gmd.site WHERE code='${code}'";
   $res = ccgg_query($sql);
   $z = (empty($res)) ? 0 : $res[0];
   return $z;
}
#
# Function DB_GetSiteCode ########################################################
#
function DB_GetSiteCode($site_num)
{
   #
   # Get site code
   #
   $sql="SELECT code FROM gmd.site WHERE num='${site_num}'";
   $res = ccgg_query($sql);
   return $res[0];
}
#
# Function DB_GetFlaskRouting ########################################################
#
function DB_GetFlaskRouting($str)
{
   #
   # Get Flask Routing information
   #
   $path = explode(",",$str);
   for ($i=0,$list = array(); $i<count($path); $i++)
   {
      $sql = "SELECT route FROM system WHERE num=$path[$i]";
      $res = ccgg_query($sql);
      $list[$i] = $res[0];
   }
   return implode(" - ",array_values(array_unique($list)));
}
#
# Function DB_GetDefProject ########################################################
#
function DB_GetDefProject($code,$strat_abbr)
{

   $select = " SELECT project.abbr";
   $from = " FROM site_desc,project,gmd.site,strategy";
   $where = " WHERE gmd.site.code = '${code}'";
   $and = " AND strategy.abbr='${strat_abbr}'";
   $and = "${and} AND site_desc.site_num=gmd.site.num";
   $and = "${and} AND site_desc.strategy_num=strategy.num";
   $and = "${and} AND site_desc.project_num=project.num";
   $etc = " ORDER BY site_desc.default_project DESC";
   $etc = "${etc} LIMIT 1";

   $res = ccgg_query($select.$from.$where.$and.$etc);
   $res[0] = isset( $res[0]) ? $res[0] : '';
   return $res[0];
}
#
# Function DB_GetDefPath ########################################################
#
function DB_GetDefPath($code,$proj_abbr,$strat_abbr)
{
   #
   # Get Default Analysis Path information
   #
   $select = "SELECT meas_path";
   $from = " FROM site_shipping,gmd.site,strategy,project";
   $where = " WHERE gmd.site.code='${code}'";
   $and = " AND gmd.site.num=site_shipping.site_num";
   $and = "${and} AND strategy.abbr='${strat_abbr}'";
   $and = "${and} AND project.abbr='${proj_abbr}'";
   $and = "${and} AND site_shipping.strategy_num=strategy.num";
   $and = "${and} AND site_shipping.project_num=project.num";
   $res = ccgg_query($select.$from.$where.$and);
   $res[0] = isset( $res[0]) ? $res[0] : '';
   $res[0]= str_replace(' ', '', $res[0]);
   $pathno = split(",",$res[0]);
   #
   # Resolve path numbers
   #
   $sysinfo = DB_GetSystemDefi();
   for ($i=0,$path=''; $i<count($pathno); $i++)
   {
      for ($ii=0; $ii<count($sysinfo); $ii++)
      {
         list($sys_num,$abbr) = split("\|",$sysinfo[$ii]);
         if ($pathno[$i] == $sys_num)
         {
            $path = ($path == '') ? "${abbr}" : "${path}-${abbr}";
            break;
         }
      }
   }
   return "${res[0]}|${path}";
}
#
# Function DB_GetSampleStatusDefi ########################################################
#
function DB_GetSampleStatusDefi()
{
   #
   # Get Sample Status Definitions
   #
   $sql="SELECT num,name FROM sample_status";
   return ccgg_query($sql);
}
#
# Function DB_GetStatus ########################################################
#
function DB_GetStatus()
{
   #
   # Get Project Status Definitions
   #
   $sql="SELECT * FROM gmd.status";
   return ccgg_query($sql);
}
#
# Function DB_GetSystemDefi ########################################################
#
function DB_GetSystemDefi()
{
   #
   # Get System Definitions
   #
   $sql="SELECT num,abbr FROM system";
   return ccgg_query($sql);
}
#
# Function DB_GetPFPNumFlasks ########################################################
#
function DB_GetPFPNumFlasks($id)
{
   $sql = "SELECT nflasks FROM pfp_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   return $res[0];
}
#
# Function DB_GetAllParamInfo ########################################################
#
function DB_GetAllParamInfo()
{
   $select = " SELECT DISTINCT t1.num, t1.formula,name, t1.unit, t1.unit_name";
   $select = $select.", t1.formula_html, t1.unit_html, t1.formula_idl, t1.unit_idl";
   $select = $select.", t1.description";
   $from = " FROM gmd.parameter as t1, ccgg.data_summary AS t2";
   $where = " WHERE t1.num = t2.parameter_num";
   $sql = $select.$from.$where;
   return ccgg_query($sql);
}
#
# Function DB_GetGasNum ########################################################
#
function DB_GetParamNum($formula)
{
   $sql = "SELECT num FROM gmd.parameter WHERE formula='${formula}'";
   $res = ccgg_query($sql);
   return $res[0];
}
#
# Function DB_GetAllSiteInfo ########################################################
#
function DB_GetAllSiteInfo($proj_abbr, $strat_abbr)
{
   $select = "SELECT DISTINCT gmd.site.num,gmd.site.code,gmd.site.name";
   $select = "${select},gmd.site.country,gmd.site.lat,gmd.site.lon,gmd.site.elev";
   $select = "${select},site_shipping.meas_path,site_shipping.meas_comments";
   $select = "${select},site_shipping.send_comments,site_shipping.return_comments";
   $select = "${select},site_desc.intake_ht,site_desc.project_num";
   $select = "${select},site_desc.strategy_num";
   $from = " FROM gmd.site,site_desc,site_shipping";
   $where = " WHERE gmd.site.num=site_desc.site_num";
   $where = "${where} AND site_shipping.site_num=site_desc.site_num";
   $where = "${where} AND site_shipping.project_num=site_desc.project_num";
   $where = "${where} AND site_shipping.strategy_num=site_desc.strategy_num";

   $and = "";
   if ( !empty($proj_abbr) )
   {
      $from = "${from},project";
      $and = "${and} AND site_desc.project_num=project.num";
      $and = "${and} AND site_shipping.project_num=project.num";
      $and = "${and} AND project.abbr='${proj_abbr}'";
   }
   if ( !empty($strat_abbr) )
   {
      $from = "${from},strategy";
      $and = "${and} AND site_desc.strategy_num=strategy.num";
      $and = "${and} AND site_shipping.strategy_num=strategy.num";
      $and = "${and} AND strategy.abbr='${strat_abbr}'";
   }
   $and = "${and} AND (site_desc.status_num='1'";
   $and = "${and} OR site_desc.status_num='2'";
   $and = "${and} OR site_desc.status_num='4')";

   $etc = " ORDER BY gmd.site.code";

   #echo "$select$from$where$and$etc\n";

   $arr = ccgg_query($select.$from.$where.$and.$etc);
   return $arr;
}
#
# Function DB_GetSiteListInfo #####################################################
#
function DB_GetSiteListInfo($proj_abbr,$strat_abbr)
{
   $select = "SELECT DISTINCT gmd.site.num,gmd.site.code,gmd.site.name";
   $select = "${select},gmd.site.country,gmd.site.lat,gmd.site.lon,gmd.site.elev";
   $select = "${select},site_desc.intake_ht,site_desc.project_num";
   $select = "${select},site_desc.strategy_num";
   $from = " FROM gmd.site,site_desc";
   $where = " WHERE gmd.site.num=site_desc.site_num";

   $and = "";
   if ( !empty($proj_abbr) )
   {
      $select = "${select},site_desc.project_num";
      $from = "${from},project";
      $and = "${and} AND site_desc.project_num=project.num";
      $and = "${and} AND project.abbr='${proj_abbr}'";
   }
   if ( !empty($strat_abbr) )
   {
      $select = "${select},site_desc.strategy_num";
      $from = "${from},strategy";
      $and = "${and} AND site_desc.strategy_num=strategy.num";
      $and = "${and} AND strategy.abbr='${strat_abbr}'";
   }

   $etc = " ORDER BY gmd.site.code";

   $arr = ccgg_query($select.$from.$where.$and.$etc);
   return $arr;
}
#
# Function DB_GetSiteList ##########################################################
#
function DB_GetSiteList($proj_abbr,$strat_abbr)
{
   $select = "SELECT DISTINCT gmd.site.num,gmd.site.code,gmd.site.name";
   $select = "${select},gmd.site.country";
   $from = " FROM gmd.site,site_desc";
   $where = " WHERE gmd.site.num=site_desc.site_num";

   $and = "";
   if ( !empty($proj_abbr) )
   {
      $select = "${select},site_desc.project_num";
      $from = "${from},project";
      $and = "${and} AND site_desc.project_num=project.num";
      $and = "${and} AND project.abbr='${proj_abbr}'";
   }
   if ( !empty($strat_abbr) )
   {
      $select = "${select},site_desc.strategy_num";
      $from = "${from},strategy";
      $and = "${and} AND site_desc.strategy_num=strategy.num";
      $and = "${and} AND strategy.abbr='${strat_abbr}'";
   }

   $etc = " ORDER BY gmd.site.code";

   $arr = ccgg_query($select.$from.$where.$and.$etc);
   return $arr;
}
#
# Function DB_GetSiteDescNoSS ########################################################
#
function DB_GetSiteDescNoSS($code, $strat_abbr)
{
   $select = "SELECT project.num,project.abbr";
   $select = "${select},site_desc.method,site_desc.intake_ht";
   $select = "${select},gmd.site.elev";
   $from = " FROM site_desc,gmd.site,project,strategy";
   $where = " WHERE gmd.site.code = '$code'";
   $and = " AND strategy.abbr = '$strat_abbr'";
   $and = "${and} AND site_desc.site_num = gmd.site.num";
   $and = "${and} AND site_desc.strategy_num = strategy.num";
   $and = "${and} AND site_desc.project_num = project.num";

   $sql = $select.$from.$where.$and;

   return ccgg_query($sql);
}
#
# Function DB_GetSiteDesc ########################################################
#
function DB_GetSiteDesc($code, $strat_abbr)
{
   $select = "SELECT project.num,project.abbr";
   $select = "${select},site_desc.method,site_desc.intake_ht";
   $select = "${select},gmd.site.elev,site_shipping.meas_path";
   $from = " FROM site_desc,site_shipping,gmd.site,project,strategy";
   $where = " WHERE gmd.site.code = '$code'";
   $and = " AND strategy.abbr = '$strat_abbr'";
   $and = "${and} AND site_desc.site_num = gmd.site.num";
   $and = "${and} AND site_desc.strategy_num = strategy.num";
   $and = "${and} AND site_desc.strategy_num = site_shipping.strategy_num";
   $and = "${and} AND site_desc.project_num = project.num";
   $and = "${and} AND site_desc.project_num = site_shipping.project_num";
   $and = "${and} AND site_desc.site_num = site_shipping.site_num";

   $sql = $select.$from.$where.$and;

   return ccgg_query($sql);
}
#
# Function DB_GetAvailableFlasksToShip ##############################################
#
function DB_GetAvailableFlasksToShip($code)
{

   #
   # Get list of flasks available for shipping
   #
   $select = "SELECT id,comments";
   $from = " FROM flask_inv";
   $where = " WHERE sample_status_num='1'";
   $etc = " ORDER BY id";

   switch ( $code )
   {
      #jwm 6-17.  removing filters for bld so all are available (pat request)
      case "BLD":
	break;
      case "CEI":
         $where = "${where} AND NOT id REGEXP '^T[0-9]+.*'";
         break;
      case "CRV":
      case "BRW";
         $where = "${where} AND NOT id REGEXP '^C[0-9]+.*' AND NOT id REGEXP '^T[0-9]+.*'";
         break;
	#Commenting out tnk restriction per pat request 9/16
      #case "TNK":
         # This should be TNK, changed for debugging
         # 12345
         #$where = "${where} AND id REGEXP '^A[0-9]+.*'";
         #break;
      case "TST":
         $where = "${where} AND NOT id REGEXP '^C[0-9]+.*'";
         break;
      default:
         $where = "${where} AND NOT id REGEXP '^C[0-9]+.*' AND NOT id REGEXP '^T[0-9]+.*' AND NOT id REGEXP '^JB.*' ";
         break;
   }

   return ccgg_query($select.$from.$where.$etc);
}
#
# Function DB_DescribeTable #######################################################
#
function DB_DescribeTable($table)
{
   $sql = "DESCRIBE $table";
   $res = ccgg_query($sql);

   $outaarr = array();

   for ( $i=0; $i<count($res); $i++ )
   {
      $fields = split('\|', $res[$i]);

      $outaarr[$fields[0]] = array();
      $outaarr[$fields[0]]['type'] = $fields[1];
      $outaarr[$fields[0]]['null'] = $fields[2];
      $outaarr[$fields[0]]['key'] = $fields[3];
      $outaarr[$fields[0]]['default'] = $fields[4];
      $outaarr[$fields[0]]['extra'] = $fields[5];
   }

   #print_r($outaarr);
   return($outaarr);
}
#
# Function RemoveFiles ########################################################
#
function RemoveFiles($dir)
{
   #
   # Remove temporary files that are day-old
   #
   $today = date("YmdHi");

   $dp = opendir($dir);
   while (false !== ($file = readdir($dp)))
   {
      if ($file == "." || $file == "..") { continue; }
      if (!(strstr($file,"xxx"))) { continue; }
      $ts = date ("YmdHi", filemtime("${dir}${file}"));
      if (strncmp($today,$ts,8)) { unlink("${dir}${file}"); }
   }
   closedir($dp);
}

#
# Function UpdateLog ########################################################
#
function UpdateLog($f,$s)
{
   #
   # Get user name
   #
   if (!($fp = fopen($f,"a")))
   { JavaScriptAlert("Unable to open ${f}.  Get help."); return; }

   $now = date("Y-m-d.H:i:s");
   $user = GetUser();

   $str = "${now} (${user}):  ${s}\n";

   #fputs($fp,$str);
   fwrite($fp,$str);
   fclose($fp);
}
#
# Function GetUser ########################################################
#
function GetUser()
{
   #
   # Get user name
   #
   #list($uid,$ou,$o) = split(",",$_SERVER['PHP_AUTH_USER']);
   #list($a,$b) = split("=",$uid);
   $u="Unknown User";
   if(isset($_SERVER['MELLON_uid']) && $_SERVER['MELLON_uid'])$u=$_SERVER['MELLON_uid'];
   else if(isset($_SERVER['REMOTE_USER']) && $_SERVER['REMOTE_USER']) $u=$_SERVER['REMOTE_USER'];
   else if(isset($_SERVER['PHP_AUTH_USER']) && $_SERVER['PHP_AUTH_USER']) $u=$_SERVER['PHP_AUTH_USER'];
   return $u;

   #return $_SERVER['REMOTE_USER'];
   #return $b;
}
#
# Function GetAdmin ########################################################
#
function GetAdmin($f)
{
   #
   # Get Administrator list from passed file
   #
   $arr = file($f);

   for ($i=0,$res=''; $i<count($arr); $i++)
   {
      $z = chop($arr[$i]);
      if (substr($z,0,1) == '#') continue;
      $res = ($res=='') ? $z : "${res},${z}";
   }
   return $res;
}
#
# Function GetUserIP ########################################################
#
function GetUserIP()
{
   #
   # Get user IP
   #
   return $_SERVER['REMOTE_ADDR'];
}
#
# Function GetMonthName ########################################################
#
function GetMonthName($m)
{
    $arr=array('na','jan','feb','mar','apr','may','jun',
              'jul','aug','sep','oct','nov','dec');

   for ($i=0; $i<count($arr); $i++) { if ($i == $m) return $arr[$i]; }
   return '';
}
#
# Function GetMonthNum ########################################################
#
function GetMonthNum($m)
{
    $arr=array('na','jan','feb','mar','apr','may','jun',
              'jul','aug','sep','oct','nov','dec');

   for ($i=0; $i<count($arr); $i++) { if (!strcasecmp($arr[$i],$m)) return $i; }
   return 0;
}
#
# Function Julian2Date ########################################################
#
function Julian2Date($j)
{
   #
   # Convert julian date (1992051) 21FEB1992 format.
   #
   $arr = array(array(-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334),
                array( -9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 ));

   $yr = $j/1000;
   $leap = ($yr%4==0 && $yr%100!=0) || $yr%400==0;
   $doy = $julian%1000;

   for ($mo=1; $mo<13; $mo++)
      if ($diy[$leap][$mo] >= $doy) break;
   $mo-=1;
   $dy=$doy-$diy[$leap][$mo];

   $mon = GetMonthName($mo);

   return sprintf("%02d%s%4d",$dy,$mon,$yr);
}
#
# Function Date2Dec ########################################################
#
function Date2Dec($yr=1900,$mo=1,$dy=1,$hr=0,$mn=0,$sc=0)
{
   #
   #######################################
   # Convert yr mo dy hr mn to decimal year
   #######################################
   #
   $siy = array (31536000, 31622400);

   $leap = (($yr%4==0 && $yr%100 != 0) || ($yr%400 == 0)) ? 1.0 : 0.0;

   $yrdoy = Ymd2Doy($yr, $mo, $dy);

   $doy = $yrdoy - $yr * 1000;

   $soy = ($doy - 1) * floatval(86400) + $hr * floatval(3600) + $mn * floatval(60) + $sc;

   $dd = $yr + floatval($soy) / $siy[$leap];

   return $dd;
}
#
# Function Ymd2Doy #################################################3#
#
function Ymd2Doy($yr=1900,$mo=1,$dy=1)
{
   $yr = intval($yr);
   $mo = intval($mo);
   $dy = intval($dy);

   $diy = array (-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 999);
   $dil = array (-9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 999);

   $leap = (($yr%4==0 && $yr%100 != 0) || ($yr%400 == 0)) ? 1.0 : 0.0;

   if ($leap)
   {
      $doy = $dil[$mo] + $dy;
   }
   else
   {
      $doy = $diy[$mo] + $dy;
   }

   return $yr * 1000 + $doy;
}
#
# Function Deg2Dec ########################################################
#
function Deg2Dec($l)
{
   list($deg,$z) = preg_split("/\s+/",$l);
   $h = strtolower(substr($z,strlen($z)-1,1));
   $min = substr($z,0,strlen($z)-1);

   if (($h == 's' || $h == 'n') && $deg == '99') return -99.9999;
   if (($h == 'e' || $h == 'w') && $deg == '999') return -999.9999;

   $sign = ($h == 's' || $h == 'w') ? -1 : 1;
   return $sign*($deg + ($min/60));
}
#
# Function Dec2Deg ########################################################
#
function Dec2Deg($v,$type)
{
   $deg = floor(abs($v));
   $min = round((abs($v) - $deg)*60);

   switch($type)
        {
   case 'lat':

      $h = ($v >= 0) ? 'N' : 'S';
      if ($v == '-99.99') $min = '99';
      break;
   case 'lon':
      $h = ($v >= 0) ? 'E' : 'W';
      if ($v == '-999.99') $min = '99';
      break;
   }
   return "${deg} ${min}${h}";
}
#
# Function DateFormat ########################################################
#
function DateFormat($v,$conv)
{
   $mon = array('NA','JAN','FEB','MAR','APR','MAY','JUN',
      'JUL','AUG','SEP','OCT','NOV','DEC');

   switch($conv)
        {
   case '2004-03-15_to_15MAR2004':
      list($yr,$mo,$dy) = split("-",$v);
      $v = "${dy}${mon[(int)$mo]}${yr}";
   default:
   }
   return $v;
}
#
# Function TimeFormat ########################################################
#
function TimeFormat($v,$conv)
{

   switch($conv)
        {
   case '11:24:00_to_1124':
      list($hr,$mn,$sc) = split(":",$v);
      $v = "${hr}${mn}";
   default:
   }
   return $v;
}
#
# Function TimeFormat2 ########################################################
#
function TimeFormat2($v,$conv)
{

   switch($conv)
        {
   case '11:24:00_to_112400':
      list($hr,$mn,$sc) = split(":",$v);
      $v = sprintf("%02d%02d%02d",$hr,$mn,$sc);
   default:
   }
   return $v;
}
#
# Function ChkPassword ########################################################
#
function ChkPassword($abbr,$pwd)
{
   $p = file("/ccg/src/om/.om.txt");
   for ($i=0,$access=0; $i<count($p); $i++)
   {
      $field = preg_split("/\s+/",$p[$i]);
      if ($field[0] == $abbr && $pwd == rtrim($field[1])) $access = 1;
      if ($field[0] == 'om' && $pwd == rtrim($field[1])) $access = 1;
   }
   return $access;
}
#
# Function PWDRequest ########################################################
#
function PWDRequest()
{
   global   $nsubmits;

   echo "<FORM name='mainform' method=POST onSubmit='PasswordCB()'>";

   echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";
   echo "<INPUT TYPE='HIDDEN' NAME='task'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Password Required</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='75%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='right'><FONT class='MediumBlackB'>Enter Password</FONT></TD>";
   echo "<TD align='left'><B><INPUT TYPE='password' class='LargeSizeBlackTurquoiseB'
   SIZE=10 NAME='pwd'></TD>";
   echo "</TR>";
   echo "</TABLE>";

   JavaScriptCommand("document.mainform.pwd.focus()");

   echo "<TABLE cellspacing=10 cellpadding=10 width='20%' align='center'>";
   echo "<TR>";
   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Ok' onClick='PasswordCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Cancel' onClick='history.go(${nsubmits});'>";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";

   echo "</BODY>";
   echo "</HTML>";
}
#
# Function Meters2Feet ########################################################
#
function Meters2Feet($m)
{
   return (double)$m / 0.3048;
}
#
# Function DB_GetMethod ########################################################
#
function DB_GetMethod($code, $proj_abbr, $strat_abbr)
{
   #
   # Get sample sheet information
   #
   $select = "SELECT method";
   $from = " FROM gmd.site, site_desc, strategy, project";
   $where = " WHERE gmd.site.code='${code}'";
   $and = " AND gmd.site.num=site_desc.site_num";
   $and = "${and} AND project.abbr='${proj_abbr}'";
   $and = "${and} AND strategy.abbr='${strat_abbr}'";
   $and = "${and} AND project.num = site_desc.project_num";
   $and = "${and} AND strategy.num = site_desc.strategy_num";

   $z = ccgg_query($select.$from.$where.$and);
   if($z)return($z[0]);
   else return '';
}
#
# Function DB_GetSampleSheetInfo ########################################################
#
function DB_GetSampleSheetInfo($code, $proj_abbr, $strat_abbr)
{
   #
   # Get sample sheet information
   #
   $select = "SELECT samplesheet";
   $from = " FROM gmd.site, site_shipping, strategy, project";
   $where = " WHERE gmd.site.code='${code}'";
   $and = " AND gmd.site.num=site_shipping.site_num";
   $and = "${and} AND project.abbr='${proj_abbr}'";
   $and = "${and} AND strategy.abbr='${strat_abbr}'";
   $and = "${and} AND project.num=site_shipping.project_num";
   $and = "${and} AND strategy.num=site_shipping.strategy_num";

   $z = ccgg_query($select.$from.$where.$and);
   return($z[0]);
}
#
# Function PrepareSampleSheet ########################################################
#
function PrepareSampleSheet($code, $proj_abbr, $strat_abbr, $SID='')
{
global $omurl;

#
# Get measurement path
#
$pathinfo = DB_GetDefPath($code, $proj_abbr, $strat_abbr);
list($pathno, $pathname) = split("\|", $pathinfo);

#
# Get sample collection method
#
$method = DB_GetMethod($code, $proj_abbr, $strat_abbr);

#
# Return if method is '?'
#
if ($method == "?") { return; }
#
# Get sample collection method
#
$ssinfo = DB_GetSampleSheetInfo($code, $proj_abbr, $strat_abbr);

$tmp = split(" ", $ssinfo);
$language = isset($tmp[0]) ? $tmp[0] : '';
$position = isset($tmp[1]) ? $tmp[1] : '';

$arg2 = "scrollbars=yes,menubar=yes,resizeable=yes,width=600,height=800";

switch ($language)
{
   case "english":
         if ( in_array($code, array("TNK")) )
         {
            $z = "flask_ss_template7.php";

            $arg1 = "${omurl}flask/${z}?code=${code}&method=$method&path=$pathname";
            if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
            if (!empty($SID)) { $arg1 = "${arg1}&SID=$SID"; }
            JavaScriptCommand("window.open('${arg1}','','${arg2}');");
         }
         else
         {
            # COB added by Pat for John Miller
            if (in_array($code, array("COB", "OBN", "TST", "BLD")))
            {
               $z = "flask_ss_template5.php";
            }
            else
            {
               $z = "flask_ss_template1.php";
            }

            $arg1 = "${omurl}flask/${z}?code=${code}&method=$method&path=$pathname";
            if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
            JavaScriptCommand("window.open('${arg1}','','${arg2}');");
         }
         break;
   case "spanish":
         $arg1 = "${omurl}flask/flask_ss_template3.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "german":
         $arg1 = "${omurl}flask/flask_ss_template4.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "french":
         $arg1 = "${omurl}flask/flask_ss_template2.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "russian":
         $arg1 = "${omurl}flask/flask_ss_template6.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "chinese":
         $arg1 = "${omurl}flask/flask_ss_template8.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "korean":
         $arg1 = "${omurl}flask/flask_ss_template9.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "simplified_chinese":
	 $arg1 = "${omurl}flask/flask_ss_simplified_chinese.php?code=${code}&method=$method&path=$pathname";
         if (!empty($position)) { $arg1 = "${arg1}&position=$position"; }
         JavaScriptCommand("window.open('${arg1}','ss','${arg2}');");
         break;
   case "tank":
         break;
   default:
         break;
}
}
#
# Function isset_else ###############################################################
#
function isset_else( &$v, $value )
{
   if( isset( $v ))
       $v = $v;
   else
       $v = $value;
}
?>
