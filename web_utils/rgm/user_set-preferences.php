<?PHP

#
# This script is used by AJAX to set the user preferences into the database
#  'id' is a unique identifier to associate preferences to
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

if ( ! isset($_GET['value']) )
{
   echo "Error: No value provided.";
   exit(1);
}

$input_id = $_GET['id'];
$input_value = $_GET['value'];

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

try
{
   $tmpaarr = DB_UserManager::getPreferences($user_obj->getDB(), $user_obj);

   if ( $input_value == '' )
   {
      if ( isset($tmpaarr[$input_id]) )
      {
         unset($tmpaarr[$input_id]);
      }
   }
   else
   {
      $tmpaarr[$input_id] = $input_value;
   }

   DB_UserManager::setPreferences($user_obj->getDB(), $user_obj, $tmpaarr); 

   exit(0);
}
catch ( Exception $e )
{
   echo "Error saving user preferences";
   exit(1);
}

?>
