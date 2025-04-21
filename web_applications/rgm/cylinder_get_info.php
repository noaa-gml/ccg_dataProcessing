<?PHP
/*This page is used to verify whether a cylinder id is valid and query the db for a requested data_element if so.
 *If not a valid cylinder id, then it returns whatever error message is returned by DB_Cylinder(), currently text
 *saying that the id was not found with a link to add the cylinder.
 *
 *Query parameters:
 *id - cylinder id to search for.
 *data_element - what cylinder data element to return (currenlty only 'comments' has been programmed).
 *
 *jwm 10/15
 *
 */

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "utils.php";


session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$input_id = isset ( $_GET['id'] ) ? $_GET['id'] : '';
$data_element = isset ( $_GET['data_element'] ) ? $_GET['data_element'] : '';//Requested data element

$errors = array();
$out="";

if ( $input_id != '' ){
   try #to create a db_cylinder and fetch requested data element.  Catch any errors to print below.
   {
      $cylinder_obj = new DB_Cylinder($database_object, $input_id, 'id');
      switch($data_element){
        case ("comments"):
            $out.=$cylinder_obj->getComments();
            if($out)$out="Cylinder comments:<br>$out";
            break;
        
      }
   }
   catch(Exception $e)
   { array_push($errors, $e); }
}


# Display errors
#

foreach ( $errors as $e ){
   $out.="<DIV style='color:red'>".$e->getMessage()."</DIV>";
}

//Send back what ever text we generated.
echo $out;

?>