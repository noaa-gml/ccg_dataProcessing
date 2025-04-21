<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!ccgg_connect())
{
	JavaScriptAlert("Cannot connect to server");
	exit;
}

$code = isset( $_POST['code'] ) ? $_POST['code'] : '';
$proj_num = isset( $_POST['proj_num'] ) ? $_POST['proj_num'] : '';
$strat_num = isset( $_POST['strat_num'] ) ? $_POST['strat_num'] : '';
$site_table = isset( $_POST['site_table'] ) ? $_POST['site_table'] : '';

$proj_info = DB_GetProjectInfo($proj_num);
list($proj_name,$project) = split("\|",$proj_info);
$strat_info = DB_GetStrategyInfo($strat_num);
list($strat_name,$strategy) = split("\|",$strat_info);

if (empty($code)) {$code = 'mid';}
if (empty($project)) {$project = 'ccg_surface';}
if (empty($strategy)) {$strategy = 'flask';}

if (empty($site_table)) {$site_table = array('gmd.site');}

MakeHTMLtop("Carbon Cycle Greenhouse Gases","Meta Data");
ShowForm($code,$project,$strategy,$site_table);
exit;
#
# Function MakeHTMLtop ########################################################
#
function MakeHTMLtop($Title,$Heading)
{
global	$bg_color,$bg_image;
global	$table;

print<<<HTML
	<HTML>
	<HEAD>
	<TITLE>$Title - $Heading</TITLE>
	<STYLE type="text/css">
	<!--
         .ProjectTitle {font-size: 13pt; font-weight: bold; color: blue}
         .SiteTitle {font-size: 22pt; font-weight: bold; color: blue}
         .Label {font-size: 12pt; font-weight: bold; color: blue}
         .Text {font-size: 12pt; font-weight: normal; color: black}
         .OutLabel {font-size: 12pt; font-weight: bold; color: green}
         .OutText {font-size: 12pt; font-weight: normal; color: black}
         .InLabel {font-size: 12pt; font-weight: bold; color: red}
         .InText {font-size: 12pt; font-weight: normal; color: black}
         .InTitle {font-size: 13pt; font-weight: bold; color: red}
         .OutTitle {font-size: 13pt; font-weight: bold; color: green}
         .TableTitle {font-size: 13pt; font-weight: bold; color: black}
         -->
        </STYLE>

	</HEAD>
	<BODY bgcolor='#FFFFFFFF'>
HTML;
}
#
# Function ShowForm ###############################################
#
function ShowForm($code,$project,$strategy,$site_table)
{
global	$sitelist;
#
################################################################
# Query db for site definition
################################################################
#
$select="SELECT num,code,name,country";
$from=" FROM gmd.site";
$where=" WHERE gmd.site.code='$code'";
$sql=$select.$from.$where;
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "|||";
list($site_num,$code,$name,$country)=split("\|",$res[0]);
#
################################################################
# Query db for project information  
################################################################
#
$select="SELECT num,name";
$from=" FROM project";
$where=" WHERE abbr='$project'";
$sql=$select.$from.$where;
$tmp=ccgg_query($sql);
list($proj_num,$proj_title)=split("\|",$tmp[0]);
#
################################################################
# Query db for strategy information  
################################################################
#
$select="SELECT num,name";
$from=" FROM strategy";
$where=" WHERE abbr='$strategy'";
$sql=$select.$from.$where;
$tmp=ccgg_query($sql);
list($strat_num,$strat_title)=split("\|",$tmp[0]);

echo "<FORM NAME='mainform' METHOD=POST>";

echo "<INPUT type='hidden' name='sitelist' value='${sitelist}'>";

echo "<TABLE bgcolor='white' WIDTH='100%' CELLPADDING='4' BORDER='0' CELLSPACING='0'>";

echo "<TR>";
echo "<TD align='left'>";

echo "<IMG alt='NOAA CMDL CCGG Logo' WIDTH='130' HEIGHT='130' 
	CCGG' src='images/iadv_noaalogo.png' border='0'>";
echo "</TD>";

echo "<TD align='right'>";

echo "<P><FONT class='ProjectTitle'>$proj_title ( $strat_title )</FONT></P>";
echo "<P><FONT class='SiteTitle'>$code</FONT></P>";
echo "<P><FONT class='InText'>$name, $country</FONT></P>";

$today=date("D M j G:i:s T Y");
echo "<P><FONT class='TableTitle'>$today</FONT></P>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<HR>";

for ($i=0; $i<count($site_table); $i++)
{
	if ($site_table[$i] == 'gmd.site') PostDefi($site_num,$proj_num,$strat_num);
	if ($site_table[$i] == 'site_desc') PostDesc($site_num,$proj_num,$strat_num);
	if ($site_table[$i] == 'site_coop') PostCoop($site_num,$proj_num,$strat_num);
	if ($site_table[$i] == 'site_shipping') PostShip($site_num,$proj_num,$strat_num);
}

echo "</FORM>";
echo "</BODY>";
echo "</HTML>";
}
#
# Function LineEntry ########################################################
#
function LineEntry($label,$text)
{
echo "<TR valign='top'>";
echo "<TD width='30%' align='left'><FONT class='Label'>${label}</FONT></TD>";
echo "<TD align='left'><FONT class='Text'>${text}</FONT></TD>";
echo "</TR>";
}
#
# Function PostDefi ########################################################
#
function PostDefi($site_num,$proj_num,$strat_num)
{
#
################################################################
# Query db for site definition
################################################################
#
$select="SELECT num,code,name,country,lat,lon,elev,lst2utc,flag";
$from=" FROM gmd.site";
$where=" WHERE num='$site_num'";

$sql=$select.$from.$where;
#echo "$sql";
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "||||||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
list($num,$code,$name,$country,$lat,$lon,$elev,$lst2utc,$flag)=split("\|",$tmp);

echo "<P align='center'><FONT class='TableTitle'>SITE DEFINITION</FONT></P>";

echo "<BLOCKQUOTE>";

echo "<TABLE width='100%'>";

LineEntry('NUMBER',$num);
LineEntry('CODE',$code);
LineEntry('NAME',$name);
LineEntry('COUNTRY',$country);
LineEntry('LATITUDE',$lat);
LineEntry('LONGITUDE',$lon);
LineEntry('ELEVATION (masl)',$elev);
LineEntry('LST to UTC',$lst2utc);
LineEntry('FLAG',$flag);

echo "</TABLE>";

echo "</BLOCKQUOTE>";
echo "<HR>";
}
#
# Function PostDesc ########################################################
#
function PostDesc($site_num,$proj_num,$strat_num)
{
#
################################################################
# Query db for site description
################################################################
#
$select="SELECT project.name,strategy.name";
$select="${select},status.name,intake_ht";
$select="${select},image,site_desc.comments";
$from=" FROM strategy,status,site_desc,project";
$where=" WHERE site_desc.site_num='$site_num'";
$and=" AND site_desc.strategy_num='$strat_num'";
$and=$and." AND strategy.num='$strat_num'";
$and=" AND site_desc.project_num='$proj_num'";
$and=$and." AND project.num='$proj_num'";
$and=$and." AND status.num=site_desc.status_num";

$sql=$select.$from.$where.$and;
#echo "$sql";
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "|||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
list($proj,$strat,$status,$intake,$image,$comments)=split("\|",$tmp);

echo "<P align='center'><FONT class='TableTitle'>SITE DESCRIPTION</FONT></P>";

echo "<BLOCKQUOTE>";

echo "<TABLE width='100%'>";

LineEntry('PROJECT',$proj);
LineEntry('STRATEGY',$strat);
LineEntry('STATUS',$status);
LineEntry('INTAKE HEIGHT (m above surface)',$intake);
LineEntry('IMAGE',$image);
LineEntry('COMMENTS',$comments);

echo "</TABLE>";

echo "</BLOCKQUOTE>";
echo "<HR>";
}
#
# Function PostCoop ########################################################
#
function PostCoop($site_num,$proj_num,$strat_num)
{
#
################################################################
# Query db for cooperating agency information  
################################################################
#
$select="SELECT name,abbr,url,logo,contact,address,tel,fax,email";
$from=" FROM site_coop";
$where=" WHERE site_num='$site_num'";
$and=" AND strategy_num='$strat_num' AND project_num='$proj_num'";

$sql=$select.$from.$where.$and;
#echo "$sql";
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "||||||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
list($name,$abbr,$url,$logo,$contact,$address,$tel,$fax,$email)=split("\|",$tmp);

echo "<P align='center'><FONT class='TableTitle'>COOPERATING AGENCY</FONT></P>";

echo "<BLOCKQUOTE>";

echo "<TABLE width='100%'>";

LineEntry('NAME',$name);
LineEntry('ABBR',$abbr);
LineEntry('URL',$url);
LineEntry('LOGO',$logo);
LineEntry('CONTACT',$contact);
LineEntry('ADDRESS',$address);
LineEntry('TEL',$tel);
LineEntry('FAX',$fax);
LineEntry('E-MAIL',$email);

echo "</TABLE>";

echo "</BLOCKQUOTE>";
echo "<HR>";
}
#
# Function PostShip ########################################################
#
function PostShip($site_num,$proj_num,$strat_num)
{
#
################################################################
# Query db for shipping information  
################################################################
#
$select="SELECT *";
$from=" FROM site_shipping";
$where=" WHERE site_shipping.site_num='$site_num'";
$and=" AND strategy_num='$strat_num' AND project_num='$proj_num'";

$sql=$select.$from.$where.$and;
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "||||||||||||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
$arr=split("\|",$tmp);
$send_address=$arr[3];
$send_carrier=$arr[4];
$send_doc=$arr[5];
$send_comments=$arr[6];
$return_address=$arr[7];
$return_carrier=$arr[8];
$return_doc=$arr[9];
$return_comments=$arr[10];
$sample_sheet=$arr[11];
$meas_comments=$arr[13];
$flask_type=$arr[14];

$code = DB_GetSiteCode($site_num);
$proj_info = DB_GetProjectInfo($proj_num);
list($proj_name,$proj_abbr) = split("\|",$proj_info);
$strat_info = DB_GetStrategyInfo($strat_num);
list($strat_name,$strat_abbr) = split("\|",$strat_info);
$path_info = DB_GetDefPath($code,$proj_abbr,$strat_abbr);
list($path_no,$meas_path) = split("\|",$path_info);

echo "<P align='center'>";
echo "<FONT class='TableTitle'>SHIPPING and RECEIVING</FONT>";
echo "</P>";

echo "<TABLE align='center' width='100%' cellpadding='10' cellspacing='0' border='0'>";

echo "<TR>";
echo "<TD width='50%' valign='top'>";

echo "<P align='center'><FONT class='OutTitle'>OUTGOING INFORMATION</FONT></P>";

echo "<FONT class='OutLabel'>ADDRESS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='OutText'>${send_address}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='OutLabel'>CARRIER</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='OutText'>${send_carrier}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='OutLabel'>DOCUMENTS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='OutText'>${send_doc}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='OutLabel'>COMMENTS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='OutText'>${send_comments}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='OutLabel'>FLASK TYPE</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='OutText'>${flask_type}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "</TD>";

echo "<TD width='50%' valign='top'>";

echo "<P align='center'><FONT class='InTitle'>RETURN INFORMATION</FONT></P>";

echo "<FONT class='InLabel'>ADDRESS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${return_address}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='InLabel'>CARRIER</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${return_carrier}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='InLabel'>DOCUMENTS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${return_doc}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='InLabel'>COMMENTS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${return_comments}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='InLabel'>SAMPLE SHEET</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${sample_sheet}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='InLabel'>MEASUREMENT PATH</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${meas_path}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "<FONT class='InLabel'>MEASUREMENT COMMENTS</FONT>";

echo "<BLOCKQUOTE>";
echo "<P>";
echo "<FONT class='InText'>${meas_comments}</FONT>";
echo "</P>";
echo "</BLOCKQUOTE>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</BLOCKQUOTE>";

echo "<HR>";
}
?>
