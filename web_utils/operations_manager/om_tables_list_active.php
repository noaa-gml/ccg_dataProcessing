<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!ccgg_connect())
{
   JavaScriptAlert("Cannot connect to server");
   exit;
}

$project = isset( $_GET['project'] ) ? $_GET['project'] : '';
$strategy = isset( $_GET['strategy'] ) ? $_GET['strategy'] : '';
$active_field = isset( $_POST['active_field'] ) ? $_POST['active_field'] : '';
$active_position = isset( $_POST['active_position'] ) ? $_POST['active_position'] : '';
$active_sort = isset( $_POST['active_sort'] ) ? $_POST['active_sort'] : '';

if (empty($project)) {$project='ccg_surface';}
if (empty($strategy)) {$strategy='flask';}

if (empty($active_field))
{$active_field= array('gmd.site.code','gmd.site.name','gmd.site.lat',
'gmd.site.lon','site_desc.intake_ht','site_coop.name');}

if (empty($active_position)) 
{$active_position='decimal';}

if (empty($active_sort)) 
{$active_sort='code';}

MakeHTMLtop("Carbon Cycle Greenhouse Gases","Meta Data");
ShowForm($active_field,$active_position,$active_sort);

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
   <STYLE type="text/css">
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
global $project;
global $strategy;

$status_num='1';

echo "<FORM NAME='mainform' METHOD=POST>";
#
################################################################
# Query db for project information  
################################################################
#
if ($project == 'all')
{
   $sql="SELECT name FROM project";
   $proj_info=ccgg_query($sql);

   $project_num=0;
   $project_title='Combined Projects';
}
else
{
   $select="SELECT num,name";
   $from=" FROM project";
   $where=" WHERE abbr='$project'";
   $sql=$select.$from.$where;
   $tmp=ccgg_query($sql);
   list($project_num,$project_title)=split("\|",$tmp[0]);
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

   $strategy_num=0;
   $strategy_title='Combined Sampling Strategies';
}
else
{
   $select="SELECT num,name";
   $from=" FROM strategy";
   $where=" WHERE abbr='$strategy'";
   $sql=$select.$from.$where;
   $tmp=ccgg_query($sql);
   list($strategy_num,$strategy_title)=split("\|",$tmp[0]);
}
#
################################################################
# Query db for active sites information  
################################################################
#
$select="SELECT gmd.site.num,gmd.site.code,gmd.site.name,gmd.site.country";
$select=$select.",gmd.site.lat,gmd.site.lon,gmd.site.elev";
$select=$select.",gmd.site.lst2utc,site_desc.intake_ht";
$select=$select.",site_coop.name,site_coop.abbr";
$select=$select.",site_desc.project_num,site_desc.strategy_num";

$from=" FROM gmd.site,site_desc LEFT JOIN site_coop ON (site_coop.site_num = site_desc.site_num AND site_coop.project_num = site_desc.project_num AND site_coop.strategy_num = site_desc.strategy_num )";

$where=" WHERE gmd.site.num=site_desc.site_num";

$and=" AND site_desc.status_num='$status_num'";
if ($project_num)
{
   $and=$and." AND site_desc.project_num='$project_num'";
}

if ($strategy_num)
{
   $and=$and." AND site_desc.strategy_num='$strategy_num'";
}
$etc=" ORDER BY ${sort}";

$sql=$select.$from.$where.$and.$etc;
$res=ccgg_query($sql);

echo "<TABLE WIDTH='100%' CELLPADDING='4' BORDER='0' CELLSPACING='2'";

echo "<TR>";
echo "<TD align='left'>";

echo "<IMG alt='NOAA CMDL CCGG Logo' WIDTH='150' HEIGHT='150' 
   CCGG' src='images/iadv_noaalogo.png' border='0'>";
echo "</TD>";

echo "<TD align='right'>";
echo "<H1>";
echo "${project_title}";
echo "</H1>";

echo "<H1>";
echo "${strategy_title}";
echo "</H1>";

echo "<H2><U>";
for ( $i=0; $i<count($res); $i++ )
{
   $tmp = split( "\|", $res[$i]);
   $res_codes[$i] = $tmp[0];
}
if ( !(isset ( $res_codes ) ) ) { $res_codes = array(""); }

echo count(array_values(array_unique($res_codes)))."</U> ACTIVE sites";
echo "</H2>";

$today=date("D M j G:i:s T Y");
echo "<H4>";
echo "${today}";
echo "</H4>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

$labeln=array('NUM','CODE','NAME','LAT','LON','ELEV (m.a.s.l.)',
      'ALT (m.a.s.l.)','LST2UTC','COOPERATING AGENCY');
$labelv=array('gmd.site.num','gmd.site.code','gmd.site.name',
      'gmd.site.lat','gmd.site.lon','gmd.site.elev',
      'site_desc.intake_ht','gmd.site.lst2utc','site_coop.name');

echo "<TABLE WIDTH='100%' CELLPADDING='2' BORDER='1' CELLSPACING='2' BGCOLOR='white'";

echo "<TR>";

for ($i=0; $i<count($labelv); $i++)
{
   if (preg_grep("/${labelv[$i]}/",$field))
   {
      echo "<TH>";
      echo "<FONT class='Label'>${labeln[$i]}</FONT>";
      echo "</TH>";
   }
}

if (!($project_num))
{
   echo "<TH>";
   echo "<FONT class='Label'>PROJECT</FONT>";
   echo "</TH>";
}
if (!($strategy_num))
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
   list($num,$code,$name,$country,$lat,$lon,$elev,$lst2utc,$ht,$coop,$abbr,$proj,$strat)=split("\|",$tmp);

   if (preg_grep("/gmd.site.num/",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${num}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-4s",$text,$num);
   }
   if (preg_grep("/gmd.site.code/",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${code}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-6s",$text,$code);
   }
   if (preg_grep("/gmd.site.name/",$field))
   {
      $z = "${name}, ${country}";
      echo "<TD>";
      echo "<FONT class='Text'>${z}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-50s",$text,$z);
   }
   $tmp=split(",",Position2Html($lat,$lon,$elev));

   if (preg_grep("/gmd.site.lat/",$field))
   {
      $pos = ($position == 'degree') ? $tmp[0] : $lat;
      $pos = ($lat <= -99) ? "Variable" : $pos;
      echo "<TD>";
      echo "<FONT class='Text'>${pos}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,str_replace('o','',strip_tags($pos)));
   }
   if (preg_grep("/gmd.site.lon/",$field))
   {
      $pos = ($position == 'degree') ? $tmp[1] : $lon;
      $pos = ($lon <= -999) ? "Variable" : $pos;
      echo "<TD>";
      echo "<FONT class='Text'>${pos}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,str_replace('o','',strip_tags($pos)));
   }
   if (preg_grep("/gmd.site.elev/",$field))
   {
      $pos = ($elev <= -99) ? 'Variable' : $tmp[2];
      echo "<TD>";
      echo "<FONT class='Text'>${pos}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$pos);
   }
   if (preg_grep("/site_desc.intake_ht/",$field))
   {
      $ht = ($ht <= -99) ? 'Variable' : (int) $ht+$elev;
      echo "<TD>";
      echo "<FONT class='Text'>${ht}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$ht);
   }
   if (preg_grep("/gmd.site.lst2utc/",$field))
   {
      $lst2utc = (strcmp($lst2utc,"")) ? $lst2utc : "Variable";
      echo "<TD>";
      echo "<FONT class='Text'>${lst2utc}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %10s",$text,$lst2utc);
   }
   if (preg_grep("/site_coop.name/",$field))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${coop}</FONT>";
      echo "</TD>";
      $text = sprintf("%s  %-50s",$text,$coop);
   }
   if (!($project_num))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${proj_info[$proj-1]}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-15s",$text,$proj_info[$proj-1]);
   }
   if (!($strategy_num))
   {
      echo "<TD>";
      echo "<FONT class='Text'>${strat_info[$strat-1]}</FONT>";
      echo "</TD>";
      $text = sprintf("%s %-15s",$text,$strat_info[$strat-1]);
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
