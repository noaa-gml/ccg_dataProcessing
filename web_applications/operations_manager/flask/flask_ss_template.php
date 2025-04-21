<?PHP
#
# JWM - 9/16 - Rewrote html template logic to have a single template with translation table.
#  To add new items to flask_ss_template.php, the translation variable ([varname]Label) must exist in all the flask_ss_template[x].php files
#  Currently there is 1,2,3,4 & 6 (eng,french,spanish,german,russian,chinese)
#  It is not required for the variable to have a value, but it must be declared for each language.
# jwm - 8/21 - added chinese. Add new template dict file, Add entry to ../om_inc.php->PrepareSampleSheet(), added new lang to ../om_siteedit.js list (search on russian to find where)
# should update this logic a bit, like change file names to be lang instead of number, put langs into a select.

# SAMPLE SHEET - new unified template
# Methods P, D, G, and N
# Requires translated label variables to already be set.  See flask_ss_template1.php for example.

#Note remarks <hr> trick to get variable width lines doesn't seem to work on ie.. since we don't use ie, not
#fixing for now..

###jwm 5/23.  Adding a second template for redesign project.  Starting with just chinese, but will
#likely move to other languages too.  2nd template is flask_ss_template_b.php
###

#
include_once ("/var/www/html/om/om_inc.php");
include_once ("/var/www/html/om/ccgglib_inc.php");
include_once ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$path = isset( $_GET['path'] ) ? $_GET['path'] : '';
$code = isset( $_GET['code'] ) ? $_GET['code'] : '';
$method = isset( $_GET['method'] ) ? $_GET['method'] : '';
$position = isset( $_GET['position'] ) ? $_GET['position'] : '';

$abbr = 'flask';
$name = 'Flask';
$yr = date("Y");
$user = GetUser();

#Some reuseable elements
$smallpad = str_repeat("_",8);
$mediumpad = str_repeat("_",12);
$largepad = str_repeat("_",20);
$today = date("D M j, Y");
$sq="<IMG src = 'square.gif' height = 20 width = 20>";

#Optional and conditional output
###

$thirdID="";
if (strstr($position, 'id')){#Not even sure when this is used...
    $thirdID="<TR><TD></TD></TR><TR><TD align='left' class='SmallBlackB'>$flaskLabel $largepad($returnLabel)</TD></TR>";
}

#hats
$nwr=(!strcasecmp($code, "nwr"))?"<TR><TD align = 'left'>".HATS($smallpad)."</TD></TR>":"";

#Fixed or relative wind speed (note these aren't always translated)
$ws = $windSpeedLabel;
if (strstr($position, 'lat') || strstr($position, 'lon')) { $ws = $relWindSpeedLabel; }
$wd = $windDirectionLabel;
if (strstr($position, 'lat') || strstr($position, 'lon')) { $wd = $relWindDirectionLabel; }

#Show mph?
$mph=($mphLabel)?"<TR><TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD><TD align='left' class = 'LessTinyBlackB'>$mphLabel</TD></TR>":"";

#OBSWD
$obsWD="";
if (strstr($position, 'obswd')){#Leaving crazy nested tables for now because they impact spacing.
    $obsWD="<TR><TD align='left'>
                <TABLE><TR><TD align='left'>
                <TABLE cellspacing = 1 cellpadding = 1>
                    <TR>
                        <TD align='left' class='SmallBlackB'>$obsWindDirectionLabel $mediumpad</TD>
                        <TD align='left' class='LessTinyBlackB'>($degreeLabel)</TD>
                    </TR>
                </TABLE>
                </TD></TR></TABLE>
            </td></tr>";
}

#Need led boxes?
$leds=($method=='D' || $method=='G')?LEDs($sq,$LEDInstructionLabel):"";

#LAT, LON & ALT
$lat=(strstr($position, 'lat'))?"<TR><TD align = 'left'>".Latitude($mediumpad,$latLabel)."</TD></TR>":"";
$lon=(strstr($position, 'lon'))?"<TR><TD align = 'left'>".Longitude($mediumpad,$lonLabel)."</TD></TR>":"";
$alt=(strstr($position, 'alt'))?"<TR><TD align = 'left'>".Altitude($mediumpad,$sampleHeightLabel)."</TD></TR>":"";

#Output the html.
print<<<HTML
<HTML>
<HEAD>
    <TITLE>Operation Manager - Flask Sampling Form</TITLE>
    <LINK REL=STYLESHEET TYPE="text/css" HREF="/om/om_style.css">
</HEAD>
<BODY BGCOLOR="white">
    <FORM NAME='mainform' METHOD=POST>
        <!-- Banner -->
        <TABLE width = '100%' align = 'center' cellpadding = 4 border = '0' cellspacing = 2>
            <TR>
                <TD align='center'>
                    <IMG alt='NOAA CMDL CCGG Logo' WIDTH='75' HEIGHT='75' src='../images/noaalogo.jpg' border='0'>
                </TD>
                <TD align='center'>
                    <FONT class='MediumBlackN'>ESRL Global Monitoring Division</FONT><BR>
                    <FONT class='LargeBlackB'>CARBON CYCLE</FONT><BR><BR>
                    <FONT class='MediumBlueB'>COOPERATIVE GLOBAL AIR SAMPLING NETWORK</FONT><BR>
                </TD>
            </TR>
        </TABLE>

        <!--Sample Sheet Container-->
        <TABLE cellspacing=2 cellpadding=2 width='100%' align='center' border='0'>
            <TR valign = 'top' align='center'>
                <TD align = 'left'>

                    <!--Left Container-->
                    <TABLE cellspacing = 2 cellpadding = 2 width='100%' align='center'  border='0'>

                        <!--Code-->
                        <TR>
                            <TD align = 'left'>
                                <TABLE width = '75%' align = 'left' cellspacing = 2 cellpadding = 2>
                                    <TR>
                                        <TD align='left' class='SmallBlackB'>$siteLabel</TD>
                                        <TD align='left' class='XLargeBlueB'>$code</TD>
                                    </TR>
                                </TABLE>
                            </TD>
                        </TR>

                        <!--Id-->
                        <TR><TD></TD></TR>
                        <TR>
                            <TD align='left' class='SmallBlackB'>$flaskLabel $largepad($pumpLabel)</TD>
                        </TR>
                        <TR><TD></TD></TR>
                        <TR>
                            <TD align='left' class='SmallBlackB'>$flaskLabel $largepad($returnLabel)</TD>
                        </TR>
                        $thirdID
                        <tr><td align='left' class='SmallBlackB'>PSU # $largepad</td></tr>

                        <!--Date-->
                        <TR>
                            <TD align='left'>
                                <TABLE>
                                    <TR>
                                        <TD align='left'>${sq}${sq}</TD>
                                        <TD align='left'>${sq}${sq}${sq}</TD>
                                        <TD align='left'>${sq}${sq}${sq}${sq}</TD>
                                    </tr>
                                    <TR>
                                        <TD align='center' class = 'SmallBlackB'>$dayLabel</TD>
                                        <TD align='center' class = 'SmallBlackB'>$monthLabel</TD>
                                        <TD align='center' class = 'SmallBlackB'>$yearLabel</TD>
                                    </TR>
                                </TABLE>
                            </TD>
                        </TR>

                        <!--Time-->
                        <TR>
                            <TD align='left'>
                                <TABLE>
                                    <TR>
                                        <TD align='left'>
                                            <TABLE>
                                                <TR>
                                                    <TD align='left'>${sq}${sq}</TD>
                                                    <TD align='left'>${sq}${sq}</TD>
                                                </tr>
                                                <TR>
                                                    <TD align='center' class = 'SmallBlackB'>$hourLabel</TD>
                                                    <TD align='center' class = 'SmallBlackB'>$minuteLabel</TD>
                                                </TR>
                                            </TABLE>
                                        </TD>
                                        <TD align='left'>
                                            <TABLE>
                                                <TR>
                                                    <TD align='left'>
                                                        <IMG src = 'circle.gif' height = 10 width = 10></TD>
                                                    <TD align='left' class = 'LessTinyBlackB'>$universalTimeLabel</TD>
                                                    </TD>
                                                </TR>
                                                <TR>
                                                    <TD align='left'>
                                                        <IMG src = 'circle.gif' height = 10 width = 10></TD>
                                                    <TD align='left' class = 'LessTinyBlackB'>$localStdLabel</TD>
                                                    </TD>
                                                </TR>
                                                <TR>
                                                    <TD align='left'>
                                                        <IMG src = 'circle.gif' height = 10 width = 10></TD>
                                                        <TD align='left' class = 'LessTinyBlackB'>$daylightSavingsLabel</TD>
                                                        </TD>
                                                </TR>
                                            </TABLE>
                                        </TD>
                                    </TR>
                                </TABLE>
                            </td>
                        </tr>
                        $nwr

                        <!---Wind Speed-->
                        <TR>
                            <TD align='left'>
                                <TABLE>
                                    <TR>
                                        <TD align='left'>
                                            <TABLE cellspacing = 1 cellpadding = 1>
                                                <TR>
                                                    <TD align='left' class='SmallBlackB'>$ws $mediumpad</TD>
                                                </TR>
                                            </TABLE>
                                        </TD>
                                        <TD align='left'>
                                            <TABLE>
                                                <TR>
                                                    <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                                                    <TD align='left' class = 'LessTinyBlackB'>$metersPerSecLabel</TD>
                                                </TR>
                                                <TR>
                                                    <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                                                    <TD align='left' class = 'LessTinyBlackB'>$knotsLabel</TD>
                                                </TR>
                                                $mph
                                            </TABLE>
                                        </TD>
                                    </TR>
                                </TABLE>
                            </td>
                        </tr>


                        <!--Wind Direction-->
                        <TR>
                            <TD align='left'>
                                <TABLE>
                                    <TR>
                                        <TD align='left'>
                                            <TABLE cellspacing = 1 cellpadding = 1>
                                                <TR>
                                                    <TD align='left' class='SmallBlackB'>$wd $mediumpad</TD>
                                                    <TD align='left' class='LessTinyBlackB'>$degreeLabel</TD>
                                                </TR>
                                            </TABLE>
                                        </TD>
                                    </TR>
                                </TABLE>
                            </td>
                        </tr>
                        $obsWD
                        $lat
                        $lon
                        $alt
                        <tr>
                            <td>
                                <TABLE frame = 1 cellpadding = 3 cellspacing = 3 width = '100%'>
                                    <tr><TD align='left' class='SmallBlackB'>$voltageLabel (V)</TD></tr>
                                    <tr><TD align='left' class='SmallBlackB'>$flowRateLabel (LPM)</TD></tr>
                                    <tr><TD align='left' class='SmallBlackB'>$pumpPressureLabel (PSI)</TD></tr>
                                </table>
                            </td>
                        </tr>
                        <tr><td>$leds</td></tr>
                    </table>
                </td>

                <!--End of Left Container-->

                <!--Start of Right Container -->

                <TD align='center'>
                    <FONT class = 'SmallBlackB'>$doNotWriteInThisBoxLabel</FONT>

                    <!--'do not write in this box' container.-->
                    <TABLE bgcolor = '#EEEEEE' style='border:thin black solid;padding:2px;' width='100%' align='center'>
                        <TR>
                            <TD>
                                <!--Shipping/Receiving Container-->
                                <TABLE border = 0 cellspacing=2 cellpadding=2 width='100%' align='center'>
                                    <TR><TD align = 'center' class = 'MediumBlackB'>SHIPPING and RECEIVING</TD></TR>
                                    <TR>
                                        <TD>
                                            <TABLE width = '100%' cellpadding = 3 cellspacing = 3>
                                                <TR align = 'left'>
                                                    <TD align='left' class='SmallBlackB'>SHIPPED</TD>
                                                    <TD class = 'SmallBlueB'>${today}</TD>
                                                </TR>
                                                <TR>
                                                    <TD align='left' class='SmallBlackB'>RECEIVED</TD>
                                                    <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>
                                                </TR>
                                            </TABLE>
                                        </TD>
                                    </TR>
                                    <TR>
                                        <TD>
                                            <TABLE width = '100%'>
                                                <TR>
                                                    <TD align = 'left' width = '35%' class='SmallBlackB'>REMARKS</TD>
                                                    <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>
                                                </TR>
                                                <TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>
                                                <TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>
                                                <TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>
                                            </TABLE>
                                        </td>
                                    </tr>
                                </table>

                                <!--Sample Anal Routing-->
                                <TABLE border = 0 cellspacing = 2 cellpadding = 2 width = '100%' align = 'center'>
                                    <TR><TD align = 'center' class = 'MediumBlackB'>SAMPLE ANALYSIS</TD></TR>
                                    <TR>
                                        <TD>
                                            <TABLE cellspacing = 3 cellpadding = 3>
                                                <TR>
                                                    <TD align='center' class='SmallBlackB'>SYSTEM</TD>
                                                    <TD align='center' class='SmallBlackB'>ANALYSIS DATE</TD>
                                                    <TD align='center' class='SmallBlackB'>INITIALS</TD>
                                                </TR>
                                                <TR><TD> </TD></TR>
HTML;

$tmp = explode('-',$path);

for ($i=0; $i<count($tmp); $i++)
{
   echo "                                       <TR>
                                                    <TH align='center' class='MediumBlueB'>${tmp[$i]}</TH>
                                                    <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>
                                                    <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>
                                                </TR>";
}
print<<<HTML
                                            </TABLE>
                                        </td>
                                    </tr>
                                </table>
                                <!--End of Shipping/Receiving Container-->
                            </td>
                        </tr>
                    </table>

                    <!--Remarks, observer, inventory & contact us-->

                    <br><br>
                    <table width='100%'>

                        <!-- Remarks-->
                        <TR>
                            <TD>
                                <TABLE width = '100%'>
                                    <TR>
                                        <TD align = 'left' width = '25%' class='SmallBlackB'>$remarksLabel</TD>
                                        <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></TD>
                                    </TR>
                                    <TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>
                                    <TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>
                                    <TR><TD class = 'SmallBlackN' colspan = 2><HR NOSHADE SIZE = 1></TD></TR>
                                </TABLE>
                            </TD>
                        </TR>

                        <!-- OBSERVER-->
                        <TR>
                            <TD>
                                <TABLE width = '100%'>
                                    <TR>
                                        <TD align = 'left' width = '25%' class='SmallBlackB'>$observerLabel</TD>
                                        <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>
                                    </TR>
                                </TABLE>
                            </TD>
                        </TR>

                        <!-- INVENTORY-->
                        <TR>
                            <TD>
                                <TABLE width = '100%'>
                                    <TR>
                                        <TD align = 'left' width = '55%' class='SmallBlackB'>$inventoryLabel</TD>
                                        <TD class = 'SmallBlackN'><HR NOSHADE SIZE = 1></FONT></TD>
                                    </TR>
                                </TABLE>
                            </TD>
                        </TR>
                        <!-- CONTACT US-->
                        <TR>
                            <TD>
                                <TABLE width = '90%'>
                                    <TR>
                                        <TD align = 'left' class='SmallBlackB'>$emailLabel</TD>
                                        <TD align = 'right' class = 'MediumBlackB'>ccggflask@noaa.gov</FONT></TD>
                                    </TR>
                                </TABLE>
                            </TD>
                        </TR>
                    </table>

                <!-- End of Right Container-->
                </TD>
            </TR>
        </TABLE>

        <!-- End of Sample Sheet Container-->
    </FORM>
</BODY>
</HTML>
HTML;




function LEDs($sq,$LEDInstructionLabel)
{
    $html="
    <TABLE frame = 1 cellpadding = 3 cellspacing = 3 width = '100%'>

        <!--LEDs-->
        <TR>
            <TD align='center' class='LessTinyBlackB'>$LEDInstructionLabel</TD>
        </TR>
        <TR>
            <TD>
                <TABLE width = '100%'>
                    <TR>
                        <TD align='center' class='SmallBlackB'>SAMPLE</TD>
                        <TD align='center' class='SmallBlackB'>DRY</TD>
                        <TD align='center' class='SmallBlackB'>BATT.</TD>
                        <TD align='center' class='SmallBlackB'>TEMP.</TD>
                        <TD align='center' class='SmallBlackB'>LEAK</TD>
                    </TR>

                    <TR>
                        <TD valign = 'center' align='center'>$sq</TD>
                        <TD valign = 'center' align='center'>$sq</TD>
                        <TD valign = 'center' align='center'>$sq</TD>
                        <TD valign = 'center' align='center'>$sq</TD>
                        <TD valign = 'center' align='center'>$sq</TD>
                    </TR>
                </TABLE>
            </TD>
        </TR>

        <!--Final LED-->
        <TR>
            <TD>
                <TABLE width = '100%'>
                    <TR><TD align='center' class='SmallBlackB'>GOOD SAMPLE/DONE</TD></TR>
                    <TR>
                        <TD valign = 'center' align='center'>$sq</TD>
                    </TR>
                </TABLE>
            </TD>
        </TR>
    </TABLE>";
    return $html;

}

function Latitude($pad,$latLabel)
{
    $html="
    <TABLE cellspacing = 1 cellpadding = 1>
        <TR>
            <TD align='left' class='SmallBlackB'>$latLabel $pad</TD>
            <TD align='left'>
                <TABLE>
                    <TR>
                        <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                        <TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>N</TD>
                    </TR>
                    <TR>
                        <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                        <TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>S</TD>
                    </TR>
                </TABLE>
            </TD>
        </TR>
    </TABLE>";
    return $html;
}

function Longitude($pad,$lonLabel)
{
    $html="
    <TABLE cellspacing = 1 cellpadding = 1>
        <TR>
            <TD align='left' class='SmallBlackB'>$lonLabel $pad</TD>
            <TD align='left'>
                <TABLE>
                    <TR>
                        <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                        <TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>W</TD>
                        </TR>
                    <TR>
                        <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                        <TD align='left' class = 'LessTinyBlackB'><SUP>o</SUP>E</TD>
                    </TR>
                </TABLE>
            </TD>
        </TR>
    </TABLE>";
    return $html;
}

function Altitude($pad,$sampleHeightLabel)
{
    $html="
    <TABLE cellspacing = 1 cellpadding = 1>
        <TR>
            <TD align='left' class='SmallBlackB'>$sampleHeightLabel $pad</TD>
            <TD align='left'>
                <TABLE>
                    <TR>
                        <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                        <TD align='left' class = 'LessTinyBlackB'>ft</TD>
                    </TR>
                    <TR>
                        <TD align='left'><IMG src = 'circle.gif' height = 10 width = 10></TD>
                        <TD align='left' class = 'LessTinyBlackB'>m</TD>
                    </TR>
                </TABLE>
            </TD>
        </TR>
    </TABLE>";
    return $html;
}

function HATS($pad)
{   #Not currently translated
    $html="
    <TABLE frame = 1 width = '100%' cellspacing = 1 cellpadding = 1>
        <TR>
            <TD align='center' class='MediumBlackB'> ** HATS SAMPLING **</TD>
        </TR>
        <TR>
            <TD align='center'>
                <TABLE border = 0 width = '100%' cellspacing = 3 cellpadding = 3>
                    <TR>
                        <TD align='left' class='SmallBlackB'>FLASK # $pad</TD>
                        <TD align='left' class='SmallBlackB'>FLASK # $pad</TD>
                    </TR>
                    <TR>
                        <TD align='left' class='SmallBlackB'>TIME $pad UTC</TD>
                        <TD align='left' class='SmallBlackB'>TIME $pad UTC</TD>
                    </TR>
                    <TR>
                        <TD align='left' class='SmallBlackB'>AIR TEMP $pad <SUP>o</SUP>C</TD>
                        <TD align='left' class='SmallBlackB'>PRESS $pad PSIG</TD>
                    </TR>
                    <TR>
                        <TD align='left' class='SmallBlackB'>RH $pad %</TD>
                        <TD align='left' class='SmallBlackB'>DP $pad <SUP>o</SUP>C</TD>
                    </TR>
                </TABLE>
            </TD>
        </TR>
    </TABLE>";
    return $html;
}
?>
