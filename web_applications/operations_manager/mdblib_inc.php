<?php
# mdblib_inc.php 
#
#
# Function BuildBanner ########################################################
#
function BuildBanner($title)
{
global $bg_color,$bg_image;
global $code;

print<<<HTML

   <!doctype html public "-//W3C//DTD HTML 4.01 Transitional//EN">
   <HTML>
   <HEAD>
   <TITLE>NOAA CMDL CCGG - MetaData Management</TITLE>

   <META name="resource-type" content="document">
   <META name="author" content="NOAA CMDL CCGG kam">
   <META name="Content-Language" content="en-US">
   <META HTTP-EQUIV="Window-target" CONTENT="_top">

   <STYLE type="text/css">
   <!--
   .NoUnderlineBlackURL {  color: #000000; text-decoration: none; font-weight: bold}
   .NoUnderlineBlueURL {  color: blue; text-decoration: none; font-weight: bold}
   .NoUnderlineWhiteURL {  color: #FFFFFF; text-decoration: none}
   .NavBtn {font-size: 11pt; font-weight: bold; color: white; background-color: turquoise}
   .TextField {font-size: 12pt; font-weight: normal; color: red}
   .Btn {font-size: 13pt; font-weight: bold; color: white; background-color: turquoise}
   .List {font-size: 13pt; font-weight: normal; color: black; background-color: white}
   .BlueList {font-size: 13pt; font-weight: normal; color: blue; background-color: white}
   .GreenList {font-size: 13pt; font-weight: normal; color: green; background-color: white}
   .RedList {font-size: 13pt; font-weight: normal; color: red; background-color: white}
   -->
   </STYLE>
   </HEAD>
   <BODY BGCOLOR="$bg_color" BACKGROUND="$bg_image"
   leftmargin="0" topmargin="0" rightmargin="0"
   marginwidth="0" marginheight="0">

   <TABLE cellspacing="0" bgcolor='blue' cellpadding="0" border="0" width="100%">
   <TR>
   <TD rowspan="2">
   <A href="http://www.noaa.gov">
   <IMG src="../images/iadv_noaalogo.jpg" 
   alt="NOAA logo - Select to go to the NOAA homepage"
   width="85" height="78" border="0"></A>
   </TD>
   <TD align="left"> <font color='white' size='3'><B>
   Global Monitoring Laboratory
   </B></FONT></TD>
   <TD rowspan="2">
   <font color='white' size='4'><B>
   MetaData Management
   </B></FONT></TD>
   </TR>
   <TR>
   <TD><FONT color='white' size='5'><B>
HTML;
   print $title;

print<<<HTML
   </B></FONT>
   </TD>
   </TR>
   </TABLE>
HTML;
}
