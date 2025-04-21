<?php
# iadv_banner.inc
#
# Function BuildBanner ########################################################
#
function BuildBanner()
{
global $load;
global $unload;

$load = (empty($load)) ? "" : htmlentities($load, ENT_QUOTES, 'UTF-8');
$unload = (empty($unload)) ? "" : htmlentities($unload, ENT_QUOTES, 'UTF-8');
$bg_color = constant("BG_COLOR");

print<<<HTML
   <!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
        <HTML>
        <HEAD>
        <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
        <LINK REL=STYLESHEET TYPE="text/css" HREF="iadv_style.css">
        </HEAD>

        <BODY BGCOLOR="${bg_color}" onLoad="${load}" onUnload="${unload}"
   leftmargin='0' topmargin='0' rightmargin='0'
   marginwidth='0' marginheight='0'>

   <TABLE cellspacing='0' cellpadding='0' border='0' width='100%' STYLE='background: URL(http://esrl.noaa.gov/img/gradient.gif) repeat-y #000066'>

   <TR>

        <TD align='left'>
           <A HREF='javascript:var newWindow = window.open("../../", "_blank"); newWindow.focus()'><img src="/img/banner_gmd.gif" alt="NOAA Earth System Research Laboratory" BORDER='0'></A>
        </TD>

   <TD align='center'>
   <A class='LargeWhiteB' HREF='index.php'>
   Interactive Atmospheric Data Visualization</A>
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
echo "<TABLE cols=7 cellspacing='0' cellpadding='0' border='0' bgcolor='#ABCDDDDD' width='100%'>";
echo "<TR>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='javascript:var newWindow = window.open(\"/gmd/ccgg/\", \"_blank\"); newWindow.focus()'>CCGG Home</A>";
echo "</TD>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='index.php'>IADV Home</A>";
echo "</TD>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='javascript:var newWindow = window.open(\"ftp://ftp.cmdl.noaa.gov/ccg/\", \"_blank\"); newWindow.focus()'>Data</A>";
echo "</TD>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='iadv_tables.php'>Tables</A>";
echo "</TD>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='javascript:var newWindow = window.open(\"/gmd/infodata/faq_cat-1.html\", \"_blank\"); newWindow.focus()'>FAQ</A>";
echo "</TD>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='iadv_support.php'>Support</A>";
echo "</TD>";

echo "<TD align='center'>";
echo "<A class='NoUnderlineBlueURL' href='iadv_help.php'>Help</A>";
echo "</TD>";

echo "</TR>";
echo "</TABLE>";
}

?>
