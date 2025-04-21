<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$proj_name = isset( $_GET['proj_name'] ) ? $_GET['proj_name'] : 'om';
$proj_abbr = isset( $_GET['proj_abbr'] ) ? $_GET['proj_abbr'] : 'om';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';

session_start();
$sid = isset( $_POST['sid'] ) ? $_POST['sid'] : '';

if (empty($sid))
{
  $sid = session_id();

  JavaScriptAlert("new session");

  unset($_SESSION['project']);
  unset($_SESSION['code']);
  unset($_SESSION['site_table']);
  unset($_SESSION['nsubmits']);
}
else
{
   session_id($sid);
}

$project = isset( $_POST['project'] ) ? $_POST['project'] : '';
$_SESSION['project'] = $project;

if ( $task == 'showinfo' )
{
   $code = isset( $_POST['code'] ) ? $_POST['code'] : '';
   $site_table = isset( $_POST['site_table'] ) ? $_POST['site_table'] : '';
   $nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';

   $_SESSION['code'] = $code;
   $_SESSION['site_table'] = $site_table;
   $_SESSION['nsubmits'] = $nsubmits;

   MakeHTMLtop("Carbon Cycle Greenhouse Gases","Meta Data");
   ShowForm($code,$project,$site_table);
}
else
{
   $code = isset( $_SESSION['code'] ) ? $_SESSION['code'] : '';
   $site_table = isset( $_SESSION['site_table'] ) ? $_SESSION['site_table'] : '';
   $nsubmits = isset( $_SESSION['nsubmits'] ) ? $_SESSION['nsubmits'] : '';

   BuildBanner($proj_name,$proj_abbr,GetUser());
   BuildNavigator();
   echo "<SCRIPT language='JavaScript' src='om_sites3.js'></SCRIPT>";

   $projinfo = DB_GetAllProjectInfo();

   if ( empty($project) )
   {
      if ( $proj_abbr == 'om' ) { $project = 'flask'; }
      else { $project = $proj_abbr; }
   }

   if (empty($site_table)) {$site_table = array('site');}

   $siteinfo = ($project == 'om') ? '' : DB_GetSiteList($project);

   MainWorkArea();
}
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

session_write_close();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $sid;
global $code,$project;
global $siteinfo;
global $projinfo;
global $nsubmits;
global $site_table;

echo "<FORM name='mainform' method=POST>";

echo "<INPUT TYPE='HIDDEN' NAME='sid' VALUE='${sid}'>";
echo "<INPUT TYPE='HIDDEN' NAME='code' VALUE=${code}>";
echo "<INPUT TYPE='HIDDEN' NAME='task' VALUE=''>";
echo "<INPUT TYPE='HIDDEN' NAME='project' VALUE=${project}>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Site Information</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE align='center' width=100% border='0' cellpadding='20' cellspacing='20'>";
#
##############################
# Row 1: Selection Windows
##############################
#
echo "<TR>";
echo "<TD>";

echo "<TABLE align='center' border='0' cellpadding='8' cellspacing='8'>";

echo "<TR align='left'>";
echo "<TD>";
echo "<FONT class='LargeBlackN'>Project</FONT>";
echo "</TD><TD>";
echo "<SELECT class='LargeBlackN' NAME='selectproject' SIZE='1' onChange='SelectProjectCB();'>";

for ($i=0; $i<count($projinfo); $i++)
{
	$tmp = split("\|",$projinfo[$i]);
	$selected = (!(strcasecmp($tmp[2],$project))) ? 'SELECTED' : '';
	echo "<OPTION $selected VALUE=${tmp[0]}>${tmp[2]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";

if ($siteinfo != '')
{
	echo "<TR align='left'>";
	echo "<TD>";
        echo "<FONT class='LargeBlackN'>Site</FONT>";
        echo "</TD><TD>";
	echo "<SELECT class='LargeBlackN' NAME='selectsite' SIZE='1'>";

	for ($i=0; $i<count($siteinfo); $i++)
	{

		$tmp = split("\|",urldecode($siteinfo[$i]));
		$selected = ($tmp[1] == $code) ? 'SELECTED' : '';
		$z = sprintf("%s (%s) - %s, %s",$tmp[1],$tmp[0],$tmp[2],$tmp[3]);
		echo "<OPTION $selected VALUE=$tmp[1]>${z}</OPTION>";
	}
	echo "</SELECT>";
	echo "</TD>";
	echo "</TR>";
}

echo "<TR align='center'>";
echo "<TD class='MediumBlackN' colspan=2>";

$tablen = array('Definition','Description','Cooperating Agency',
		'Shipping/Receiving');
$tablev = array('site','site_desc','site_coop','site_shipping');

for ($i=0; $i<count($tablen); $i++)
{
   $checked = (in_array($tablev[$i],$site_table)) ? "CHECKED" : "";
   echo "<INPUT TYPE='checkbox' NAME='site_table[]' $checked VALUE='${tablev[$i]}'>${tablen[$i]}";
}
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TD>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE width='10%' align='center'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Submit' onClick='SubmitCB()'>";
echo "</TD>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Reset' onClick='ResetCB()'>";
echo "</TD>";
echo "<TD align='center'>";
echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='history.go(${nsubmits});'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";

JavaScriptCommand("SetOptions()");
}

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
function ShowForm($code,$project,$site_table)
{
global $sitelist;
global $sid;
#
################################################################
# Query db for site definition
################################################################
#
$select="SELECT num,code,name,country";
$from=" FROM site";
$where=" WHERE site.code='$code'";
$sql=$select.$from.$where;
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "|||";
list($site_num,$code,$name,$country)=split("\|",$res[0]);
#
################################################################
# Query db for project information  
################################################################
#
$select="SELECT num,title";
$from=" FROM project";
$where=" WHERE abbr='$project'";
$sql=$select.$from.$where;
$tmp=ccgg_query($sql);
list($proj_num,$proj_title)=split("\|",$tmp[0]);

echo "<FORM NAME='mainform' METHOD=POST>";

echo "<INPUT type='hidden' name='sitelist' value='${sitelist}'>";
echo "<INPUT type='hidden' name='code' value='${code}'>";
echo "<INPUT type='hidden' name='sid' value='${sid}'>";

for ( $i=0; $i<count($site_table); $i++ )
{
   echo "<INPUT type='hidden' name='site_table[]' value='${site_table[$i]}'>";
}

echo "<TABLE bgcolor='white' WIDTH='100%' CELLPADDING='4' BORDER='0' CELLSPACING='0'>";

echo "<TR>";
echo "<TD align='left'>";

echo "<IMG alt='NOAA CMDL CCGG Logo' WIDTH='130' HEIGHT='130' 
	CCGG' src='images/iadv_noaalogo.png' border='0'>";
echo "</TD>";

echo "<TD align='right'>";

echo "<P><FONT class='ProjectTitle'>$proj_title</FONT></P>";
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
	if ($site_table[$i] == 'site') PostDefi($site_num,$proj_num);
	if ($site_table[$i] == 'site_desc') PostDesc($site_num,$proj_num);
	if ($site_table[$i] == 'site_coop') PostCoop($site_num,$proj_num);
	if ($site_table[$i] == 'site_shipping') PostShip($site_num,$proj_num);
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
function PostDefi($site_num,$proj_num)
{
#
################################################################
# Query db for site definition
################################################################
#
$select="SELECT num,code,name,country,lat,lon,elev,lst2utc,flag,topo,windrose";
$from=" FROM site";
$where=" WHERE num='$site_num'";

$sql=$select.$from.$where;
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "||||||||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
list($num,$code,$name,$country,$lat,$lon,$elev,$lst2utc,$flag,$topo,$wr)=split("\|",$tmp);

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
LineEntry('TOPOGRAPHY',$topo);
LineEntry('WIND ROSE',$wr);

echo "</TABLE>";

echo "</BLOCKQUOTE>";
echo "<HR>";
}
#
# Function PostDesc ########################################################
#
function PostDesc($site_num,$proj_num)
{
#
################################################################
# Query db for site description
################################################################
#
$select="SELECT project.name";
$select="${select},project_status.name,intake_ht";
$select="${select},image,site_desc.comments,sample_freq,sample_tod";
$select="${select},sample_storage";
$from=" FROM project,project_status,site_desc";
$where=" WHERE site_desc.site_num='$site_num'";
$and=" AND site_desc.project_num='$proj_num'";
$and=$and." AND project.num='$proj_num'";
$and=$and." AND project_status.num=site_desc.project_status_num";

$sql=$select.$from.$where.$and;
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "|||||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
list($proj,$status,$intake,$image,$comments,$freq,$tod,$storage)=split("\|",$tmp);

echo "<P align='center'><FONT class='TableTitle'>SITE DESCRIPTION</FONT></P>";

echo "<BLOCKQUOTE>";

echo "<TABLE width='100%'>";

LineEntry('PROJECT',$proj);
LineEntry('STATUS',$status);
LineEntry('INTAKE HEIGHT (m above surface)',$intake);
LineEntry('IMAGE',$image);
LineEntry('COMMENTS',$comments);
LineEntry('SAMPLE FREQUENCY',$freq);
LineEntry('SAMPLE TIME-0F-DAY',$tod);
LineEntry('SAMPLE STORAGE',$storage);

echo "</TABLE>";

echo "</BLOCKQUOTE>";
echo "<HR>";
}
#
# Function PostCoop ########################################################
#
function PostCoop($site_num,$proj_num)
{
#
################################################################
# Query db for cooperating agency information  
################################################################
#
$select="SELECT name,abbr,url,logo,contact,address,tel,fax,email";
$from=" FROM site_coop";
$where=" WHERE site_num='$site_num'";
$and=" AND project_num='$proj_num'";

$sql=$select.$from.$where.$and;
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
function PostShip($site_num,$proj_num)
{
#
################################################################
# Query db for shipping information  
################################################################
#
$select="SELECT *";
$from=" FROM site_shipping";
$where=" WHERE site_shipping.site_num='$site_num'";
$and=" AND site_shipping.project_num='$proj_num'";

$sql=$select.$from.$where.$and;
$res=ccgg_query($sql);

$res[0] = ( isset($res[0]) ) ? $res[0] : "|||||||||||||";
$tmp=str_replace("\r\n","<BR>",$res[0]);
$arr=split("\|",$tmp);
$send_address=$arr[2];
$send_carrier=$arr[3];
$send_doc=$arr[4];
$send_comments=$arr[5];
$return_address=$arr[6];
$return_carrier=$arr[7];
$return_doc=$arr[8];
$return_comments=$arr[9];
$sample_sheet=$arr[10];
$meas_comments=$arr[12];
$flask_type=$arr[13];

$code = DB_GetSiteCode($site_num);
$proj_info = DB_GetProjectInfo($proj_num);
list($name,$abbr) = split("\|",$proj_info);
$path_info = DB_GetDefPath($code,$abbr);
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
