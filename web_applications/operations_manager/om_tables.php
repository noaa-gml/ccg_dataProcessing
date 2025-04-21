<?PHP

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

$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';
$project = isset( $_POST['project'] ) ? $_POST['project'] : '';
$strategy = isset( $_POST['strategy'] ) ? $_POST['strategy'] : '';
$param = isset( $_POST['param'] ) ? $_POST['param'] : '';
$table = isset( $_POST['table'] ) ? $_POST['table'] : '';

if ( empty($project) )
{
   if ( $strat_abbr == "pfp" ) { $project = "ccg_aircraft"; }
   else { $project = "ccg_surface"; }
}

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='om_tables.js'></SCRIPT>";
$nsubmits=(int)$nsubmits;#explicit cast to int
$nsubmits -= 1;
#
################################################################
# Query db for parameter information  
################################################################
#
$select = " SELECT DISTINCT t1.formula";
$from = " FROM gmd.parameter AS t1, ccgg.data_summary AS t2";
$where = " WHERE t1.num = t2.parameter_num";
$etc = " ORDER BY t1.formula";
$sql = $select.$from.$where.$etc;
$paraminfo = ccgg_query($sql);
#
################################################################
# Query db for project information  
################################################################
#
$projinfo = DB_GetAllProjectInfo();
#
################################################################
# Query db for strategy information  
################################################################
#
$stratinfo = DB_GetAllStrategyInfo();

$table = (empty($table)) ? 'active_less' : $table;
$strategy = (empty($strategy)) ? $strat_abbr : $strategy;

echo "<FORM NAME='mainform' METHOD=POST>";
echo "<INPUT type='hidden' name='strat_name' value='${strat_name}'>";
echo "<INPUT type='hidden' name='strat_abbr' value='${strat_abbr}'>";
echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";
echo "<INPUT type='hidden' name='project' value='${project}'>";
echo "<INPUT type='hidden' name='strategy' value='${strategy}'>";
echo "<INPUT type='hidden' name='param' value='${param}'>";
echo "<INPUT type='hidden' name='table' value='${table}'>";

echo "<H1 align='center'>TABLES</H1>";

echo "<TABLE WIDTH='100%' CELLPADDING='4' BORDER='0' CELLSPACING='2'>";

echo "<TR>";
echo "<TD>";
echo "<TABLE CELLPADDING='4' BORDER='0' CELLSPACING='0'";

echo "<TR BGCOLOR='#EEEEEEEE'>";
echo "<TD>";
$checked = (strstr($table,'active')) ? 'CHECKED' : '';
echo "<INPUT TYPE='radio' NAME='radio' VALUE='om_tables_list_active.php' ${checked}>";
echo "<FONT COLOR='black' SIZE='5'> Active Sites</FONT>";
echo "<FONT COLOR='black' SIZE='3'>   (Select a </FONT>";
echo "<FONT COLOR='purple' SIZE='3'><B>PROJECT</FONT></B>";
echo "<FONT COLOR='black' SIZE='3'> and </FONT>";
echo "<FONT COLOR='green' SIZE='3'><B>STRATEGY</FONT></B>)";
echo "<FONT SIZE='2'>";
$z = ($table == 'active_more') ? 'active_less' : 'active_more';
$detail = substr(strrchr($z, "_"), 1);
echo "<A HREF=\"javascript:DetailCB('${z}')\" class='SmallBlackN'>[ ${detail} detail ]</A>";
echo "</FONT>";
echo "</TD>";
echo "</TR>";

if ($table == 'active_more')
{

	echo "<TR BGCOLOR='#EEEEEEEE'>";
	echo "<TD>";
	echo "<BLOCKQUOTE>";
	echo "<FONT COLOR='black' SIZE='3'><B>Select fields</FONT></B><BR>";


	$a = 'gmd.site';
	$b = 'site_desc';
	$c = 'site_coop';

	$fieldn = array('num','code','name','lat','lon','elev','alt','lst2utc','coop agency');
	$fieldv = array("${a}.num","${a}.code","${a}.name","${a}.lat","${a}.lon","${a}.elev",
			"${b}.intake_ht","${a}.lst2utc","${c}.name");

	for ($i=0; $i<count($fieldn); $i++)
	{
                if ( $i % 7 == 0 && $i != 0 ) { echo "<BR>"; }
		$checked = ($i==0 || $i==5 || $i==7) ? "" : 'CHECKED';
		echo "<INPUT TYPE='checkbox' NAME='active_field[]'
		${checked} VALUE='${fieldv[$i]}'>${fieldn[$i]}";
	}
	echo "</BLOCKQUOTE>";
	echo "</TD>";
	echo "</TR>";

	echo "<TR BGCOLOR='#EEEEEEEE'>";
	echo "<TD>";
	echo "<BLOCKQUOTE>";
	echo "<FONT COLOR='black' SIZE='3'><B>Select lat/lon unit</FONT></B><BR>";
	echo "<INPUT TYPE='radio' NAME='active_position' CHECKED VALUE='decimal'>decimal degree";
	echo "<INPUT TYPE='radio' NAME='active_position' VALUE='degree'>degree minute";
	echo "</BLOCKQUOTE>";
	echo "</TD>";
	echo "</TR>";

	echo "<TR BGCOLOR='#EEEEEEEE'>";
	echo "<TD>";
	echo "<BLOCKQUOTE>";
	echo "<FONT COLOR='black' SIZE='3'><B>Sort by</FONT></B><BR>";
	for ($i=0; $i<count($fieldn); $i++)
	{
                if ( $i % 7 == 0 && $i != 0 ) { echo "<BR>"; }
		$checked = ($i==1) ? 'CHECKED' : '';
		echo "<INPUT TYPE='radio' NAME='active_sort' ${checked} VALUE='${fieldv[$i]}'>${fieldn[$i]}";
	}
	echo "</BLOCKQUOTE>";
	echo "</TD>";
	echo "</TR>";
}

echo "<TR>";
echo "<TD>";
echo "</TD>";
echo "</TR>";

echo "<TR BGCOLOR='#EEEEEEEE'>";
echo "<TD>";
$checked = (strstr($table, 'available')) ? 'CHECKED' : '';
echo "<INPUT TYPE='radio' NAME='radio' VALUE='om_tables_list_available.php' ${checked}>";
echo "<FONT COLOR='black' SIZE='5'> Available Data</FONT>";
echo "<FONT COLOR='black' SIZE='3'>   (Select a </FONT>";
echo "<FONT COLOR='purple' SIZE='3'><B>PROJECT</FONT></B>";
echo "<FONT COLOR='black' SIZE='3'>, </FONT>";
echo "<FONT COLOR='green' SIZE='3'><B>STRATEGY</FONT></B>";
echo "<FONT COLOR='black' SIZE='3'> and </FONT>";
echo "<FONT COLOR='red' SIZE='3'><B>PARAMETER</FONT></B>)";
echo "<FONT SIZE='2'>";
$z = ($table == 'available_more') ? 'available_less' : 'available_more';
$detail = substr(strrchr($z, "_"), 1);

echo "<A HREF=\"javascript:DetailCB('${z}')\" class='SmallBlackN'>[ ${detail} detail ]</A>";
echo "</FONT>";
echo "</TD>";
echo "</TR>";

if ($table == 'available_more')
{
	echo "<TR BGCOLOR='#EEEEEEEE'>";
	echo "<TD>";
	echo "<BLOCKQUOTE>";
	echo "<FONT COLOR='black' SIZE='3'><B>Select fields</FONT></B><BR>";

	$a='gmd.site';
	$b='site_desc';
	$c='data_summary';

	$fieldn = array('num','code','name','lat','lon','elev','alt','lst2utc','# samples/profiles','first','last','status');
	$fieldv = array("${a}.num","${a}.code","${a}.name","${a}.lat","${a}.lon","${a}.elev",
			"${b}.intake_ht","${a}.lst2utc","${c}.count","${c}.first","${c}.last","${c}.status_num");

	for ($i=0; $i<count($fieldn); $i++)
	{
                if ( $i % 7 == 0 && $i != 0 ) { echo "<BR>"; }
		$checked = ($i==0 || $i==5 || $i==7) ? "" : 'CHECKED';
		echo "<INPUT TYPE='checkbox' NAME='available_field[]' ${checked} VALUE='${fieldv[$i]}'>${fieldn[$i]}";
	}
	echo "</BLOCKQUOTE>";
	echo "</TD>";
	echo "</TR>";

	echo "<TR BGCOLOR='#EEEEEEEE'>";
	echo "<TD>";
	echo "<BLOCKQUOTE>";
	echo "<FONT COLOR='black' SIZE='3'><B>Select lat/lon unit</FONT></B><BR>";
	echo "<INPUT TYPE='radio' NAME='available_position' CHECKED VALUE='decimal'>decimal degree";
	echo "<INPUT TYPE='radio' NAME='available_position' VALUE='degree'>degree minute";
	echo "</BLOCKQUOTE>";
	echo "</TD>";
	echo "</TR>";

	echo "<TR BGCOLOR='#EEEEEEEE'>";
	echo "<TD>";
	echo "<BLOCKQUOTE>";
	echo "<FONT COLOR='black' SIZE='3'><B>Sort by</FONT></B><BR>";
	for ($i=0; $i<count($fieldn); $i++)
	{
                if ( $i % 7 == 0 && $i != 0 ) { echo "<BR>"; }
		$checked = ($i==1) ? 'CHECKED' : '';
		echo "<INPUT TYPE='radio' NAME='available_sort' ${checked} VALUE='${fieldv[$i]}'>${fieldn[$i]}";
	}
	echo "</BLOCKQUOTE>";
	echo "</TD>";
	echo "</TR>";
}
echo "<TR>";
echo "<TD>";
echo "</TD>";
echo "</TR>";

echo "</TABLE>";
echo "</TD>";

echo "<TD>";
echo "<TABLE  CELLPADDING='4' BORDER='0' CELLSPACING='2'";

echo "<TR>";
echo "<TD>";
echo "<FONT size='4' COLOR='purple'><B>PROJECT</FONT></B>";
echo "</TD>";
echo "<TD>";
echo "<SELECT class='PurpleList' NAME='projectlist' SIZE='1'>";

for ($i=0; $i<count($projinfo); $i++)
{
	$field = split("\|",$projinfo[$i]);
	$selected = (!strcasecmp($project,$field[2])) ? 'SELECTED' : '';

	echo "<OPTION $selected VALUE=$field[2]>$field[1]</OPTION>";
}
echo "<OPTION VALUE='all'>Combined</OPTION>";

echo "</SELECT>";
echo "</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD>";
echo "<FONT size='4' COLOR='green'><B>STRATEGY</FONT></B>";
echo "</TD>";
echo "<TD>";
echo "<SELECT class='GreenList' NAME='strategylist' SIZE='1'>";

for ($i=0; $i<count($stratinfo); $i++)
{
	list($a,$b,$c) = split("\|",$stratinfo[$i]);
	$selected = (!strcasecmp($strategy,$c)) ? 'SELECTED' : '';

	echo "<OPTION $selected VALUE=$c>$b</OPTION>";
}
echo "<OPTION VALUE='all'>Combined</OPTION>";

echo "</SELECT>";
echo "</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD>";
echo "<FONT size='4' COLOR='red'><B>PARAMETER</FONT></B>";
echo "</TD>";
echo "<TD>";
echo "<SELECT class='RedList' NAME='paramlist' SIZE='1'>";

for ($i=0; $i<count($paraminfo); $i++)
{
	$z = strtoupper($paraminfo[$i]);
	$selected = (!strcasecmp($param,$z)) ? 'SELECTED' : '';
	echo "<OPTION $selected VALUE=$z>$z</OPTION>";
}

echo "</SELECT>";
echo "</TD>";
echo "</TR>";

echo "<TR><TD>";
echo "</TD></TR>";
echo "<TR><TD>";
echo "</TD></TR>";

echo "</TABLE>";

echo "<TABLE  ALIGN='left' CELLPADDING='4' BORDER='0' CELLSPACING='2'";

echo "<TR>";
echo "<TD align='center'><B>";
echo "<INPUT TYPE='button' class='Btn' VALUE='Submit' onClick='SubmitCB()'>";
echo "</B></TD>";
echo "<TD align='center'><B>";
echo "<INPUT TYPE='button' class='Btn' VALUE='Back' onClick='history.go(${nsubmits});'>";
echo "</B></TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TR>";
echo "</TABLE>";

echo "</FORM>";
echo "</BODY>";
echo "</HTML>";
?>
