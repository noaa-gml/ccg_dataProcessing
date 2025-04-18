<?PHP
/*jwm 10/15.  Added ability to request cylinder comments along with dot data.
Pass include_comments=1 to append comments after any other message.
*/

require_once "CCGDB.php";
require_once "DB_Cylinder.php";

if ( ! isset($_GET['id']) ||
     $_GET['id'] == '' )
{
   echo "No cylinder ID passed.";
   exit(1);
}

$include_comments=(isset($_GET['include_comments']) && $_GET['include_comments']==1);

try
{
   $dbobj = new CCGDB();
}
catch ( Exception $e )
{
   echo "Problem connecting to database.";
   exit(1);
}

try
{
   $cylinder_object = new DB_Cylinder($dbobj, $_GET['id']);
}
catch ( Exception $e )
{
   echo "Cylinder not found. <A href='cylinder_edit.php?id=".urlencode($_GET['id'])."&action=add'><INPUT type='button' value='Add Cylinder'></A>";
   exit(1);
}

$out="";
   
if ( $cylinder_object->isWithinDOTDate() == '2' )
{
   $out="Please check DOT date on cylinder. <A href='cylinder_edit.php?id=".urlencode($_GET['id'])."&action=update'><INPUT type='button' value='Update Cylinder'></A>";
}
elseif ( $cylinder_object->isWithinDOTDate() == '0' )
{
   $out="Cylinder needs DOT recertefication. <A href='cylinder_edit.php?id=".urlencode($_GET['id'])."&action=update'><INPUT type='button' value='Update Cylinder'></A>";
}

//Highlight any DOT data in red.
if($out)$out="<font style='color:red; word-wrap: break-word;'>$out</font>";


if($include_comments && $cylinder_object->getComments()!=""){
   //Also output any cylinder comments that may be present
   if($out) $out.="<br><br>";
   $out=$out."Cylinder comments:<br>".$cylinder_object->getComments();
}

echo $out;

exit(0);

?>
