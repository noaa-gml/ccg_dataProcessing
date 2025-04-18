<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!ccgg_connect())
{
   JavaScriptAlert("Cannot connect to server");
   exit;
}

global $ccgg_equip;

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : 'PSU';

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
#
# Remove temporary files that are day-old
#
RemoveFiles("${omdir}tmp/");
RemoveFiles("${omdir}pfp/src/tmp/");

echo "</BODY>";
echo "</HTML>";

exit;
