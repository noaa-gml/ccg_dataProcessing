<?PHP

#
# This script is used by AJAX to get the user preferences from the database
#  'id' is a unique identifier to determine which preferences to retrieve
#

require_once "CCGDB.php";
require_once "DB_User.php";
require_once "DB_UserManager.php";

session_start();

if ( ! isset($_GET['id']) ||
     $_GET['id'] == '' )
{
   echo "Error: No id provided.";
   exit(1);
}

$input_id = $_GET['id'];

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

try
{
   $tmpaarr = DB_UserManager::getPreferences($user_obj->getDB(), $user_obj);

   if ( isset($tmpaarr[$input_id]) )
   {
      echo $tmpaarr[$input_id];
   }
   else
   {
      echo '';
   }

   exit(0);
}
catch ( Exception $e )
{
   echo "Error getting user preferences";
   exit(1);
}

?>
