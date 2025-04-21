<?php
# omlib_inc.php
#
# Function BuildBanner ########################################################
#
function BuildBanner($title,$abbr,$user,$jlib=false)
{#Note; jlib true isn't really working.. I couldn't get the js to integrate within framework.  Ended up bailing and adding a j/lib and j/index.php.  jwm 7/18
global  $bg_color;

$abbr = strtolower($abbr);

#if ( $user != 'danlei.chao' )
#{
#print<<<HTML
#<HTML>
#<HEAD>
#  <meta http-equiv="refresh" content="0; URL=/om/om_down.html">
#</HEAD>
#HTML;
#
#exit;
#}

print<<<HTML
   <!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
   <HTML>
   <HEAD>
   <LINK REL=STYLESHEET TYPE="text/css" HREF="/om/om_style.css">
   <LINK REL=STYLESHEET TYPE="text/css" HREF="/om/pulldowns.css">
   <LINK REL=STYLESHEET TYPE="text/css" HREF="/inc/dbutils/dbutils.css">

   <TITLE>NOAA CMDL CCGG - Operations Manager</TITLE>

   <META name="resource-type" content="document">
   <META name="description" content="NOAA CMDL CCGG Operations Manager">
   <META name="author" content="NOAA CMDL CCGG kam">
   <META name="Content-Language" content="en-US">
   <META HTTP-EQUIV="Window-target" CONTENT="_top">
   <META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
   <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
   <META HTTP-EQUIV="expires" CONTENT="0">
   <SCRIPT language='JavaScript' src='/om/om_js_inc.php'></SCRIPT>
   <SCRIPT language='JavaScript' src='/inc/dbutils/dbutils.js'></SCRIPT>
HTML;

if($jlib){
   if(getcwd()=='/var/www/html/mund/om')$dbutils_webPath='../../inc/dbutils/';
   else $dbutils_webPath='../inc/dbutils/';
   echo "<SCRIPT language='JavaScript' src='${dbutils_webPath}/js/jquery-1.11.3.min.js'></SCRIPT>
    <SCRIPT language='JavaScript' src='${dbutils_webPath}/js/jquery-ui-1.11.4/jquery-ui.js'></SCRIPT>";
    echo get_dbutilsHeaderIncludes($dbutils_webPath);

}
JavaScriptCommand("allow.user = \"${user}\"");

print<<<HTML
   <SCRIPT language='JavaScript' src='/om/pulldowns.js'></SCRIPT>
   <SCRIPT language='JavaScript' src='/om/${abbr}_init.js'></SCRIPT>
   </HEAD>

   <BODY BGCOLOR="$bg_color" 
   leftmargin='0' topmargin='0' rightmargin='0'
   marginwidth='0' marginheight='0'
   style="margin: 0" onLoad='writeMenus();'
   onResize="if (isNS4) nsResizeHandler()">

   <TABLE cellspacing='0' bgcolor='blue' cellpadding='0' border='0' width='100%'>

   <TR>

   <TD align='left'>
   <IMG src='/om/images/noaa_logo3.gif' 
   ALT='NOAA logo' width='85' height='78' border='0'>
   </TD>

   <TD> <FONT class='MediumCyanB'>ESRL Global Monitoring Laboratory</FONT><BR>
   <FONT class='XlargeCyanB'>Carbon Cycle</FONT>
   </TD>

   <TD align='center'>
   <FONT class='LargeCyanB'>Operations Manager</FONT><BR>
   <FONT class='LargeWhiteB'>$title</FONT>
   </TD>
   </TR>
   </TABLE>
HTML;
}
#
# Function BuildInvBanner ########################################################
#
function BuildInvBanner($title,$user)
{
global  $bg_color;

$abbr = strtolower($title);

print<<<HTML
   <!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
   <HTML>
   <HEAD>
   <LINK REL=STYLESHEET TYPE="text/css" HREF="/om/om_style.css">
   <LINK REL=STYLESHEET TYPE="text/css" HREF="/om/pulldowns.css">

   <TITLE>NOAA CMDL CCGG - Operations Manager</TITLE>

   <META name="resource-type" content="document">
   <META name="description" content="NOAA CMDL CCGG Operations Manager">
   <META name="author" content="NOAA CMDL CCGG kam">
   <META name="Content-Language" content="en-US">
   <META HTTP-EQUIV="Window-target" CONTENT="_top">
   <META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
   <META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
   <META HTTP-EQUIV="expires" CONTENT="0">

   <SCRIPT language='JavaScript' src='/om/om_js_inc.php'></SCRIPT>
HTML;

JavaScriptCommand("allow.user = \"${user}\"");

print<<<HTML
   <SCRIPT language='JavaScript' src='/om/pulldowns.js'></SCRIPT>
   <SCRIPT language='JavaScript' src='/om/${abbr}_init.js'></SCRIPT>
   </HEAD>

   <BODY BGCOLOR="$bg_color" 
   leftmargin='0' topmargin='0' rightmargin='0'
   marginwidth='0' marginheight='0'
   style="margin: 0" onLoad='writeMenus();'
   onResize="if (isNS4) nsResizeHandler()">

   <TABLE cellspacing='0' bgcolor='blue' cellpadding='0' border='0' width='100%'>

   <TR>

   <TD align='left'>
   <IMG src='/om/images/noaa_logo3.gif' 
   ALT='NOAA logo' width='85' height='78' border='0'>
   </TD>

   <TD> <FONT class='MediumCyanB'>ESRL Global Monitoring Laboratory</FONT><BR>
   <FONT class='XlargeCyanB'>Carbon Cycle</FONT>
   </TD>

   <TD align='center'>
   <FONT class='LargeCyanB'>Operations Manager</FONT><BR>
   <FONT class='LargeWhiteB'>$title</FONT>
   </TD>
   </TR>
   </TABLE>
HTML;
}
#
# Function BuildNavigator ########################################################
#
function BuildNavigator()
{
   global $iadv_task;

   echo "<TABLE height='5%' cellspacing='0' cellpadding='0' border='0' bgcolor='#ABCDDDDD' width='100%'>";
   echo "<TR><TD>";
   echo "</TD></TR>";
   echo "</TABLE>";
}

?>
