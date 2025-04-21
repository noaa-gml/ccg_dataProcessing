<?PHP

require_once "CCGDB.php";
require_once "DB_Location.php";

$num = isset($_GET['num']) ? $_GET['num'] : '';

try
{
   $database_object = new CCGDB();

   $location_object = new DB_Location($database_object, $num);

   echo $location_object->getAddress();
}
catch (Exception $e)
{
   exit(1);
}

exit(0);
