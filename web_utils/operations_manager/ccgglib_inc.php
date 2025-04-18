<?php
# ccgg_lib_inc.php
#
# ccgg_lib common functions
#
#
# Function Position2Html ########################################################
#
function Position2Html($x,$y,$z)
{
   $slat = ($x < 0) ? "S" : "N";
   $dlat = (int) ABS($x);
   $mlat = (int) (60*(ABS($x) - $dlat));
   $slon = ($y < 0) ? "W" : "E";
   $dlon = (int) ABS($y);
   $mlon = (int) (60*(ABS($y) - $dlon));
   $ielev = (int) $z;

   $sup = "<SUP>";
   $nsup = "</SUP>";


   $str = "${dlat}${sup}o${nsup} ${mlat}' ${slat}, ${dlon}${sup}o${nsup} ${mlon}' ${slon}, ${ielev} masl";
   return($str);
}
#
# Function JavaScriptLoad ########################################################
#
function JavaScriptLoad($html)
{
   echo (
   "\n<SCRIPT LANGUAGE='JavaScript'>\n" .
   "<!-- \n" .
   "location=\"$html\";\n" .
   " // --> \n" .
   "</SCRIPT>\n");
}
#
# Function JavaScriptAlert ########################################################
#
function JavaScriptAlert($msg)
{
   echo (
   "\n<SCRIPT LANGUAGE='JavaScript'>\n" .
   "<!-- \n" .
   "alert (\"$msg\");\n" .
   " // --> \n" .
   "</SCRIPT>\n");
   return(1);
}
#
# Function JavaScriptConfirm ########################################################
#
function JavaScriptConfirm($msg)
{
   echo (
   "\n<SCRIPT LANGUAGE='JavaScript'>\n" .
   "<!-- \n" .
   "if ( confirm(\"$msg\") ) { return 1 } else { return 0 };\n" .
   " // --> \n" .
   "</SCRIPT>\n");
   # return(1);
}
#
# Function JavaScriptCommand ########################################################
#
function JavaScriptCommand($z)
{
   echo (
   "\n<SCRIPT LANGUAGE='JavaScript'>\n" .
   "<!-- \n" .
   "$z;\n" .
   " // --> \n" .
   "</SCRIPT>\n");
}
?>
