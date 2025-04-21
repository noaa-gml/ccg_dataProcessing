<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!ccgg_connect())
{
   JavaScriptAlert("Cannot connect to server");
   exit;
}

$param = isset( $_GET['param'] ) ? $_GET['param'] : '';
$project = isset( $_GET['project'] ) ? $_GET['project'] : '';
$strategy = isset( $_GET['strategy'] ) ? $_GET['strategy'] : '';
$available_field = isset( $_POST['available_field'] ) ? $_POST['available_field'] : '';
$available_position = isset( $_POST['available_position'] ) ? $_POST['available_position'] : '';
$available_sort = isset( $_POST['available_sort'] ) ? $_POST['available_sort'] : '';

if (empty($param)) {$param='co2';}
if (empty($project)) {$project='ccg_surface';}
if (empty($strategy)) {$strategy='flask';}

if (empty($available_field))
{$available_field= array('gmd.site.code','gmd.site.name','gmd.site.lat',
'gmd.site.lon','site_desc.intake_ht','data_summary.count','data_summary.first',
'data_summary.last','data_summary.status_num');}

if (empty($available_position)) 
{$available_position='decimal';}

if (empty($available_sort)) 
{$available_sort= 'code';}

MakeHTMLtop("Carbon Cycle Greenhouse Gases","Meta Data");

ShowForm($available_field,$available_position,$available_sort);

exit;
#
# Function MakeHTMLtop ########################################################
#
function MakeHTMLtop($Title,$Heading)
{
global   $bg_color;
global   $table;

print<<<HTML
   <HTML>
   <HEAD>
   <TITLE>$Title - $Heading</TITLE>
   <STYLE>
   <!--
         .Label {font-size: 12pt; font-weight: bold; color: blue}
         .Text {font-size: 10pt; font-weight: normal; color: black}
         -->
        </STYLE>
   </HEAD>
   <BODY BGCOLOR="white">
HTML;
}
#
# Function ShowForm ###############################################
#
function ShowForm($field,$position,$sort)
{
global $bg_color;
global $project;
global $strategy;
global $param;

echo "<FORM NAME='mainform' METHOD=POST>";
#
################################################################
# Query db for parameter information  
################################################################
#
$select="SELECT num,name,formula,formula_html";
$from=" FROM gmd.parameter";
$where=" WHERE formula='$param'";
$sql=$select.$from.$where;
$tmp=ccgg_query($sql);
list($param_num,$param_name,$param_formula,$param_formula_html)=split("\|",$tmp[0]);
#
################################################################
# Query db for project information  
################################################################
#
if ($project == 'all')
{
   $sql="SELECT abbr FROM project";
   $proj_info=ccgg_query($sql);

   $proj_num=0;
   $proj_title='Combine Measurement Projects';
}
else
{

   $select="SELECT num,name";
   $from=" FROM project";
   $where=" WHERE abbr='$project'";
   $sql=$select.$from.$where;
   $tmp=ccgg_query($sql);
   list($proj_num,$proj_title)=split("\|",$tmp[0]);
}
#
################################################################
# Query db for strategy information  
################################################################
#
if ($strategy == 'all')
{
   $sql="SELECT abbr FROM strategy";
   $strat_info=ccgg_query($sql);

   $strat_num=0;
   $strat_title='Combine Measurement Programs';
}
else
{

   $select="SELECT num,name";
   $from=" FROM strategy";
   $where=" WHERE abbr='$strategy'";
   $sql=$select.$from.$where;
   $tmp=ccgg_query($sql);
   list($strat_num,$strat_title)=split("\|",$tmp[0]);
}
#
################################################################
# Query db for measurement history.  
################################################################
#
$select="SELECT gmd.site.num,gmd.site.code,gmd.site.name,gmd.site.country";
$select=$select.",gmd.site.lat,gmd.site.lon,gmd.site.elev";
$select=$select.",gmd.site.lst2utc,site_desc.intake_ht";
$select=$select.",SUM(data_summary.count),MIN(data_summary.first)";
$select=$select.",MAX(data_summary.last),MIN(data_summary.status_num)";
$select=$select.",site_desc.project_num,site_desc.strategy_num,count(*)";

$from=" FROM gmd.site,site_desc,data_summary,status,gmd.parameter";

$where=" WHERE gmd.site.num=site_desc.site_num";
$and=" AND gmd.site.num=data_summary.site_num";
$and=$and." AND parameter.num='$param_num'";
$and=$and." AND parameter.num=data_summary.parameter_num";
$and=$and." AND status.num=data_summary.status_num";

#
# Select Ongoing or Terminated sites from site_desc
#
$and=$and." AND (site_desc.status_num = '1' OR";
$and=$and." site_desc.status_num = '3')";
if ($proj_num)
{
   $and=$and." AND data_summary.project_num='$proj_num'";
   $and=$and." AND site_desc.project_num='$proj_num'";
}
else
{
   $and=$and." AND site_desc.project_num=data_summary.project_num";
}

if ($strat_num)
{
   $and=$and." AND data_summary.strategy_num='$strat_num'";
   $and=$and." AND site_desc.strategy_num='$strat_num'";
}
else
{
   $and=$and." AND site_desc.strategy_num=data_summary.strategy_num";
}
$groupby = " GROUP BY gmd.site.num, site_desc.project_num";
$etc=" ORDER BY ${sort}";

$sql=$select.$from.$where.$and.$groupby.$etc;
#echo "$sql\n";
$res=ccgg_query($sql);

echo "<TABLE WIDTH='100%' CELLPADDING='4' BORDER='0' CELLSPACING='2'";

echo "<TR>";
echo "<TD align='left'>";


echo "<IMG alt='NOAA CMDL CCGG Logo' WIDTH='150' HEIGHT='150' 
   CCGG' src='images/iadv_noaalogo.png' border='0'>";
echo "</TD>";

echo "<TD align='right'>";

#echo "<H2>";
#echo "NOAA CMDL Carbon Cycle Greenhouse Gases";
#echo "</H2>";

echo "<H1>";
echo "${strat_title}";
echo "</H1>";

echo "<H2>";
echo "${param_formula_html} measurements made at <U>".count($res)."</U> locations";
echo "</H2>";

$today=date("D M j G:i:s T Y");
echo "<H4>";
echo "${today}";
echo "</H4>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

if ( $strat_num == 2 )
{
   $labeln=array('NUM','CODE','NAME','LAT','LON','ELEV (m.a.s.l.)',
      'ALT (m.a.s.l.)','LST2UTC','# OF PROFILES','FIRST','LAST','STATUS');
}
else
{
   $labeln=array('NUM','CODE','NAME','LAT','LON','ELEV (m.a.s.l.)',
      'ALT (m.a.s.l.)','LST2UTC','# OF SAMPLES','FIRST','LAST','STATUS');
}
$labelv=array('gmd.site.num','gmd.site.code','gmd.site.name',
      'gmd.site.lat','gmd.site.lon','gmd.site.elev',
      'site_desc.intake_ht','gmd.site.lst2utc',
      'data_summary.count','data_summary.first',
                'data_summary.last','data_summary.status_num');

echo "<TABLE WIDTH='100%' CELLPADDING='4' BORDER='1' CELLSPACING='2' BGCOLOR='white'";

echo "<TR>";

for ($i=0; $i<count($labelv); $i++)
{
   if (in_array("${labelv[$i]}", $field))
   {
      echo "<TH>";
      echo "<FONT class='Label'>${labeln[$i]}</FONT>";
      echo "</TH>";
   }
}

if (!($proj_num))
{
   echo "<TH>";
   echo "<FONT class='Label'>PROJECT</FONT>";
   echo "</TH>";
}
if (!($strat_num))
{
   echo "<TH>";
   echo "<FONT class='Label'>STRATEGY</FONT>";
   echo "</TH>";
}

echo "</TR>";

#
# Save a text version of table
#
$id=rand();
$textfile="xxx_${id}.txt";
$fp = fopen("tmp/${textfile}","w");

for ($i=0; $i<count($res); $i++)
{
   $text = '';

   echo "<TR>";
   $tmp=str_replace("\r\n","<BR>",$res[$i]);
   list($num,$code,$name,$country,$lat,$lon,$elev,$lst2utc,$ht,
   $count,$first,$last,$status,$proj,$strat,$rowcount)=split("\|",$tmp);

   if (in_array("gmd.site.num",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${num}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-4s",$text,$num);
   }
   if (in_array("gmd.site.code",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${code}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-6s",$text,$code);
   }
   if (in_array("gmd.site.name",$field))
   {
      $z = "${name}, ${country}";
      echo "<TD>";
      echo "<FONT class='Text'>${z}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-50s",$text,$z);
   }
   $tmp=split(",",Position2Html($lat,$lon,$elev));

   if (in_array("gmd.site.lat",$field))
   {
      $pos = ($position == 'degree') ? $tmp[0] : $lat;
      $pos = ($lat <= -99) ? "Variable" : $pos;
      echo "<TD>";
      echo "<FONT class='Text'>${pos}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,str_replace('o','',strip_tags($pos)));
   }
   if ( in_array("gmd.site.lon",$field))
   {
      $pos = ($position == 'degree') ? $tmp[1] : $lon;
      $pos = ($lon <= -999) ? "Variable" : $pos;
      echo "<TD>";
      echo "<FONT class='Text'>${pos}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,str_replace('o','',strip_tags($pos)));
   }
   if ( in_array("gmd.site.elev",$field))
   {
      $pos = ($elev <= -99) ? 'Variable' : $tmp[2];
      echo "<TD>";
      echo "<FONT class='Text'>${pos}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$pos);
   }
   if ( in_array("site_desc.intake_ht",$field))
   {
      $ht = ($ht <= -99) ? 'Variable' : (int) $ht+$elev;
      echo "<TD>";
      echo "<FONT class='Text'>${ht}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$ht);
   }
   if ( in_array("gmd.site.lst2utc",$field))
   {
      $lst2utc = ($lst2utc <= -99 ) ? "Variable" : $lst2utc;
      echo "<TD>";
      echo "<FONT class='Text'>${lst2utc}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$lst2utc);
   }
   if ( in_array("data_summary.count",$field))
   {
      $count = ( $count < 0 ) ? "Continuous" : $count; 
      echo "<TD>";
      echo "<FONT class='Text'>${count}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %8s",$text,$count);
   }
   if ( in_array("data_summary.first",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${first}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$first);
   }
   if ( in_array("data_summary.last",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${last}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$last);
   }
   if ( in_array("data_summary.status_num",$field))
   {
      $sql = "SELECT name FROM status WHERE num = '$status'";
      $tmp = ccgg_query($sql);
      $status_name = $tmp[0];

      echo "<TD>";
      echo "<FONT class='Text'>${status_name}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-15s",$text,$status_name);
   }
   if (!($proj_num))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${proj_info[$proj-1]}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-10s",$text,$proj_info[$proj-1]);
   }
   if (!($strat_num))
   {
      echo "<TD>";
      #
      # If there are multiple strategies for this site+project, then
      # display them all in a comma separated list
      #
      if ( $rowcount > 1 )
      {
         $select = "SELECT strategy.abbr";
         $from = " FROM site_desc, strategy";
         $where = " WHERE site_num = '$num' AND project_num = '$proj'";
         $and = " AND site_desc.strategy_num = strategy.num";
         $etc = " ORDER BY strategy.num";
         $sql = $select.$from.$where.$and.$etc;
         #echo "$sql<BR>";
         $strat_tmp = ccgg_query($sql);

         $outtext = "";
         for ( $j=0; $j<count($strat_tmp); $j++ )
         {
            $outtext = ( empty($outtext) ) ? "$strat_tmp[$j]" : "$outtext,".$strat_tmp[$j];
         }
      }
      else { $outtext = $strat_info[$strat-1]; }
      echo "<FONT class='Text'>$outtext</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-10s",$text,$outtext);
   }
   echo "</TR>";
   fputs($fp,"${text}\n");
}
fclose($fp);

echo "</FONT>";

echo "</TABLE>";

echo "<A class='label' HREF='tmp/${textfile}'>Text Version</A>";

echo "</FORM>";
echo "</BODY>";
echo "</HTML>";
}
?>
