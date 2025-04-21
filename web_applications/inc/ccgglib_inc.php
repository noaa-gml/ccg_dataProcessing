<?php
# ccgg_lib.inc
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


	#$str = "${dlat}${sup}o${nsup} ${mlat}' ${slat}, ${dlon}${sup}o${nsup} ${mlon}' ${slon}, ${ielev} masl";
	$str = "${dlat}${sup}o${nsup} ${mlat}' ${slat}, ${dlon}${sup}o${nsup} ${mlon}' ${slon}, ${ielev}";
	return($str);
}
#
# Function JavaScriptLoad ########################################################
#
function JavaScriptLoad($html)
{
   $z = htmlentities($html, ENT_QUOTES, 'UTF-8');
	echo (
	"\n<SCRIPT LANGUAGE='JavaScript'>\n" .
	"<!-- \n" .
	"location=\"$z\";\n" .
	" // --> \n" .
	"</SCRIPT>\n");
}
#
# Function JavaScriptAlert ########################################################
#
function JavaScriptAlert($msg)
{
   $z = htmlentities($msg, ENT_QUOTES, 'UTF-8');
	echo (
	"\n<SCRIPT LANGUAGE='JavaScript'>\n" .
	"<!-- \n" .
	"alert (\"$z\");\n" .
	" // --> \n" .
	"</SCRIPT>\n");
	return(1);
}
#
# Function JavaScriptCommand ########################################################
#
function JavaScriptCommand($z)
{
   # Whenever this function is used, need to make sure the input is validated.
   # If used to set a variable, be sure to use htmlentities() on the value
	echo (
	"\n<SCRIPT LANGUAGE='JavaScript'>\n" .
	"<!-- \n" .
	"$z;\n" .
	" // --> \n" .
	"</SCRIPT>\n");
}
#
# Function JavaScriptStart ########################################################
#
function JavaScriptStart()
{
   # Whenever this function is used, need to make sure the input is validated.
   # If used to set a variable, be sure to use htmlentities() on the value
#       "<!-- \n");
        echo (
        "\n<script type='text/javascript'>\n" .
        "//<![CDATA[\n"
        );
}
#
# Function JavaScriptEnd ########################################################
#
function JavaScriptEnd()
{
   # Whenever this function is used, need to make sure the input is validated.
   # If used to set a variable, be sure to use htmlentities() on the value
#       " // --> \n" .
        echo (
        "//]]>\n" .
        "</script>\n");
}
#
# Function JavaScriptCode ########################################################
#
function JavaScriptCode($z)
{
   # Whenever this function is used, need to make sure the input is validated.
   # If used to set a variable, be sure to use htmlentities() on the value
        echo (
        "$z;\n");
}
#
# Function SendtoJS ##################################################################
#
function SendtoJS($varname,$arr,$namearr=array())
{
   $type = gettype($arr);
   #echo "$type:";

   switch($type)
   {
      case 'array':
         $namestr = '';
         for ( $i=0; $i<count($namearr); $i++ )
         {
            $namestr = $namestr."['$namearr[$i]']";
         }

         JavaScriptCommand("$varname$namestr = []");

         foreach ( $arr as $name=>$value )
         {
            $nametype = gettype($name);

            #
            # Add the name onto the name array for when we print the value
            #
            array_push($namearr, $name);

            #
            # Call SendtoJS on the subarray
            #
            SendtoJS($varname,$arr[$name], $namearr);

            #
            # Remove the name from the name array, so that the next iteration
            #    does not use it
            #
            $junk = array_pop($namearr);
         }
         break;
      default:
         #
         # Found something that is not an array, so print it out
         #
         $namestr = '';
         for ( $i=0; $i<count($namearr); $i++ )
         {
            $namestr = $namestr."['$namearr[$i]']";
         }
         JavaScriptCommand("$varname$namestr = '$arr'");
         #echo "$namestr:$arr<BR>";
   }
}
?>
