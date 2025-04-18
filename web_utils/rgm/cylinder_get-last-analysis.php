<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";

$dbobj = new CCGDB();

if ( ! isset($_GET['id']) ||
     $_GET['id'] == '' )
{
   echo "Error: No cylinder ID passed.";
   exit(1);
}

if ( ! isset($_GET['calservice']) ||
     $_GET['calservice'] == '' )
{
   echo "Error: No calservice passed.";
   exit(1);
}

try
{
   $cylinder_object = new DB_Cylinder($dbobj, $_GET['id']);
}
catch ( Exception $e )
{
   echo "Error: Provided cylinder ID not found in database.";
   exit(1);
}

try
{
   $calservice_object = new DB_CalService($dbobj, $_GET['calservice']);
}
catch ( Exception $e )
{
   echo "Error: Calservice not found. Please contact system administrator.";
   exit(1);
}

#
###############
# Get the most recent fill code
###############
#

# Script to retrieve analysis information from the database.
# Please ask Kirk Thoning for questions about this script.
$cmd = escapeshellcmd('/ccg/bin/reftank');

# Build the shell command
$args = array();
array_push($args, escapeshellarg('-f'));
array_push($args, escapeshellarg($cylinder_object->getID()));

$res_fills = array();
exec($cmd.' '.join(' ', $args), $res_fills, $exitcode);

#echo $cmd.' '.join(' ', $args)."<BR>";

if ( $exitcode != 0 )
{
   echo "Error: reftank script exited with error status.";
   exit(1);
}

#echo "<PRE>";
#print_r($res_fills);
#echo "</PRE>";

if ( count($res_fills) == 0 )
{
   echo "Error: No filling information found.";
   exit(1);
}

$last_fill_line = array_pop($res_fills);

$last_fill_fields = preg_split('/\s+/', trim($last_fill_line));

#echo "<PRE>";
#print_r($last_fill_fields);
#echo "</PRE>";

$last_fill_code = $last_fill_fields[2];
# The fill code should be one capital letter of the alphabet
if ( ! preg_match("/^[A-Z]$/", $last_fill_code) )
{
   echo "Error: Unexpected fill code found.";
   exit(1);
}

#
###############
# Retrieve the analyzes
###############
#
$cmd = escapeshellcmd('/ccg/bin/reftank');

# Build the shell command
#jwm - 3/18. this broke when format of output changed.  I switched to using -a which is a fixed 1 line output.
$args = array();
array_push($args, escapeshellarg('-g'.$calservice_object->getAbbreviation()));
array_push($args, escapeshellarg('-c'.$last_fill_code));
array_push($args, escapeshellarg('-a'));#only output avgs
array_push($args, escapeshellarg($cylinder_object->getID()));

$res_analyzes = array();
exec($cmd.' '.join(' ', $args), $res_analyzes);

#echo $cmd.' '.join(' ', $args)."<BR>";

#echo "<PRE>";
#print_r($res_analyzes);
#echo "</PRE>";
if(!$res_analyzes){
	echo "Error: no previous calibration data found for this fill";
	exit();
}
$last_analysis_line = array_pop($res_analyzes);
if(!$last_analysis_line && $res_analyzes)$last_analysis_line = array_pop($res_analyzes);#Sometimes there's a blank row at the end

#These warnings aren't applicable for -a avg output any more, but do no harm.

if ( preg_match("/^No.*data for/", $last_analysis_line) )
{
   echo 'Error: '.$last_analysis_line;
   exit(1);
}

# Check for warnings
$warning_arr = preg_grep("/WARNING:/", $res_analyzes);

if ( count($warning_arr) > 0 )
{
   echo 'Error: '.array_pop($warning_arr);
   exit(1);
}

$last_analysis_fields = preg_split('/\s+/', trim($last_analysis_line));

#echo "<PRE>";
#print_r($last_analysis_fields);
#echo "</PRE>";

if ( count($last_analysis_fields) != 6 )
{
   echo "Error: Unexpected number of analysis fields";
   exit(1);
}
elseif ( $last_analysis_fields[3] === 'nan' )
{
   echo "Error: Analysis average is 'nan'".
   exit(1);
}

echo $last_analysis_fields[3];
exit(0);

?>
