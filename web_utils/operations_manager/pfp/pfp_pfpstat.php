<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$abbr = 'pfp';
$name = 'PFP';

BuildBanner($name,$abbr,GetUser());
BuildNavigator();

$perlcode = "${omdir}perl/ccg_pfpstats.pl";
$tmpfile = sprintf("${omdir}tmp/xxx-%d.txt",rand());
$args = "-o${tmpfile}";

$z = $perlcode.' '.$args;

#echo "$z";
#JavaScriptAlert($z);
exec($z,$arr,$ret);

if ($ret)
{
   #
   # Query Failed
   #
   $str = implode("\n", $arr);
   JavaScriptAlert($str);
}
else
{
   #
   # Query Succeeded
   #
   $output = file($tmpfile);
}
unlink($tmpfile);


MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global	$input,$output;

echo "<FORM name='mainform' method=POST>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center' valign='top'>";
echo "<TD align='center' class='XLargeBlueB'>Event Information</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE bgcolor='#DDDDDD' align='center' id='output' width=80% border='0' cellpadding='4' cellspacing='4'>";

if ($output)
{
	$n = count($output);

	#echo "<TR>";
	#echo "<TD align='left' class='LargeBlackB'>${n} line(s) returned</TD>";
	#echo "</TR>";
	echo "<TR>";
	echo "<TD align='left'>";

	echo "<PRE width=120>";
	#echo ${output};
	for ($i=0; $i<count($output); $i++) { echo sprintf("%s",$output[$i]); }
	echo "</PRE>";
	echo "</TD>";
	echo "</TR>";
}

echo "</TABLE>";
echo "</BODY>";
echo "</HTML>";
}
?>
