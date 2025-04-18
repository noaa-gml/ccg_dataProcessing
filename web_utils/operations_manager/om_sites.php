<?PHP

# Only display strategy options that exist in the project

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : 'om';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : 'om';

$proj_num = isset( $_POST['proj_num'] ) ? $_POST['proj_num'] : '';
$strat_num = isset( $_POST['strat_num'] ) ? $_POST['strat_num'] : '';

$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : 0;

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='om_sites.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;

$projinfo = DB_GetAllProjectInfo();
$stratinfo = DB_GetAllStrategyInfo();

for ( $i=0; $i<count($projinfo); $i++ )
{
   $field = split("\|",$projinfo[$i]);

   $projnum = 0;
   for ( $j=0; $j<count($stratinfo); $j++ )
   {
      $tmp = split("\|",$stratinfo[$j]);
      $siteinfo = DB_GetSiteList($field[2],$tmp[2]);

      if ( count($siteinfo) > 0 ) { $projnum++; }
   }

   if ( $projnum > 0 )
   {
      JavaScriptCommand("sitelist[$field[0]] = new Array(".$projnum.")");

      for ( $j=0; $j<count($stratinfo); $j++ )
      {
         $tmp = split("\|",$stratinfo[$j]);
         $siteinfo = DB_GetSiteList($field[2],$tmp[2]);

         if ( count($siteinfo) > 0 )
         {
            JavaScriptCommand("sitelist[$field[0]][$tmp[0]] = new Array(".count($siteinfo).")");
            for ( $k=0; $k<count($siteinfo); $k++ )
            {
               JavaScriptCommand("sitelist[$field[0]][$tmp[0]][$k] = '$siteinfo[$k]'");
            }
         }
      }
   }
}

if ( $strat_abbr == 'om' )
{
   $field = split("\|",$stratinfo[0]);   
   $strat_num = $field[0];
   $strategy = $field[2];
}
else
{
   $strat_num = DB_GetStrategyNum($strat_abbr);
   $strategy = $strat_abbr;
}

if ( empty($proj_num) )
{
   if ( $strat_abbr == "pfp" ) { $project = "ccg_aircraft"; }
   else { $project = "ccg_surface"; }
   $proj_num = DB_GetProjectNum($project);
}

$siteinfo = DB_GetSiteList($project,$strategy);

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $proj_num;
global $projinfo;
global $strat_num;
global $siteinfo;
global $stratinfo;
global $nsubmits;

echo "<FORM name='mainform' method=POST target='siteinfo'>";

echo "<INPUT TYPE='HIDDEN' NAME='code'>";
echo "<INPUT TYPE='HIDDEN' NAME='proj_num'>";
echo "<INPUT TYPE='HIDDEN' NAME='strat_num'>";
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
echo "<TD align='right'>";
echo "<FONT class='LargeBlackN'>Project</FONT>";
echo "</TD><TD>";
echo "<SELECT class='LargeBlackN' NAME='selectproject' SIZE='1' onChange='SelectProjectCB();'>";

for ($i=0; $i<count($projinfo); $i++)
{
   $tmp = split("\|",$projinfo[$i]);
   $selected = (!(strcasecmp($tmp[0],$proj_num))) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE='${tmp[0]}'>${tmp[1]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";

echo "<TR align='left'>";
echo "<TD align='right'>";
echo "<FONT class='LargeBlackN'>Strategy</FONT>";
echo "</TD><TD>";
echo "<SELECT class='LargeBlackN' NAME='selectstrategy' SIZE='1' onChange='SelectStrategyCB();'>";

for ($i=0; $i<count($stratinfo); $i++)
{
   $tmp = split("\|",$stratinfo[$i]);
   $selected = (!(strcasecmp($tmp[0],$strat_num))) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE=${tmp[0]}>${tmp[2]}</OPTION>";
}
echo "</SELECT>";
echo "</TD>";
echo "</TR>";

echo "<TR align='left'>";
echo "<TD align='right'>";
echo "<FONT class='LargeBlackN'>Site</FONT>";
echo "</TD><TD>";
echo "<SELECT class='LargeBlackN' NAME='selectsite' onClick='SelectSiteCB()' SIZE='1'>";

for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp = split("\|",urldecode($siteinfo[$i]));
   $z = sprintf("%s (%s) - %s, %s",$tmp[1],$tmp[0],$tmp[2],$tmp[3]);
   echo "<OPTION $selected VALUE=$tmp[1]>${z}</OPTION>";
}

echo "</SELECT>";
echo "</TD>";
echo "</TR>";

echo "<TR align='center'>";
echo "<TD class='MediumBlackN' colspan=2>";

$tablen = array('Definition','Description','Cooperating Agency',
		'Shipping/Receiving');
$tablev = array('gmd.site','site_desc','site_coop','site_shipping');

for ($i=0; $i<count($tablen); $i++)
{ echo "<INPUT TYPE='checkbox' NAME='site_table[]' CHECKED VALUE='${tablev[$i]}'>${tablen[$i]}"; }
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
JavaScriptCommand("SelectProjectCB()");

}
?>
