<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!ccgg_connect())
{
echo mysql_error();
#   JavaScriptAlert("Cannot connect to server");
   exit;
}

$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';

$strat_name = empty($strat_name) ? "" : $strat_name;
$strat_abbr = empty($strat_abbr) ? "om" : $strat_abbr;

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
#
# Remove temporary files that are day-old
#
RemoveFiles("${omdir}tmp/");
RemoveFiles("${omdir}pfp/src/tmp/");

echo "</BODY>";
echo "</HTML>";

exit;
