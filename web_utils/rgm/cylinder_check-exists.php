<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";

if ( ! isset($_GET['id']) ||
     $_GET['id'] == '' )
{
   echo "No cylinder ID passed.";
   exit(1);
}

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
   #echo "Cylinder not found.";
   echo "0";
   exit(0);
}

#echo "Cylinder exists.";
echo "1";
exit(1);

?>
