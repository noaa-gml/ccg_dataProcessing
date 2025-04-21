<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$strat_abbr = 'pfp';
$strat_name = 'PFP';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
exit;
?>
