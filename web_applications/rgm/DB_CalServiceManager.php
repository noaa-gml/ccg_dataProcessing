<?PHP

require_once "CCGDB.php";
require_once "DB_User.php";
require_once "DB_CalService.php";

/**
* Manager class for DB_CalService
*
* Class that searches for DB_CalService objects
*/

class DB_CalServiceManager
{

   /**
   * Method to search for DB_CalService related to provided DB_User object
   *
   * This is used to find which DB_CalService(s) a DB_User is associated
   *  to by e-mail. When a cylinder is available for analysis, the DB_User
   *  related to a DB_CalService recieves an e-mail.
   *
   * @param $input_database_object (DB) Input database object
   * @param $input_user_object (DB_User) Input user object.
   * @return (array) Array of DB_CalService objects
   */
   public static function searchByUser($input_database_object, $input_user_object)
   {
      if ( ! is_a($input_database_object, 'DB') )
      { throw new Exception ("Provided database object must be class or subclass of 'DB'."); }

      if ( get_class($input_user_object) !== 'DB_User' )
      { throw new Exception ("Provided object must be of class 'DB_User'."); }

      if ( ! ValidInt($input_user_object->getNum()) )
      { throw new Exception ("Provided object must be a database DB_User."); }

      $sql = " SELECT calservice_num FROM calservice_user WHERE contact_num = ?";
      $sqlargs = array($input_user_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $calservice_objects = array();
      foreach ( $res as $aarr )
      {
         $calservice_object = new DB_CalService($input_database_object, $aarr[0]);

         array_push($calservice_objects, $calservice_object);
      }

      return ($calservice_objects);
   }

   /**
   * Method to retrieve DB_CalService objects that may be analyzed
   *
   * This is used to generate a list of options. This may also be used
   *  to constrain which ones are available for use.
   *
   * @param $input_database_object (DB) Input database object
   * @return (array) Array of DB_CalService objects
   */
   public static function getAnalysisCalServices($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB') )
      { throw new Exception ("Provided database object must be class or subclass of 'DB'."); }

      $sql = " SELECT num FROM calservice ORDER BY abbr";

      $res = $input_database_object->queryData($sql);

      $calservice_objects = array();
      foreach ( $res as $aarr )
      {
         $calservice_object = new DB_CalService($input_database_object, $aarr[0]);
         array_push($calservice_objects, $calservice_object);
      }

      return ($calservice_objects);
   }

   /**
   * Method to retrieve DB_CalService objects that may be displayed on
   *  a calibration certificate.
   *
   * @param $input_database_object (DB) Input database object
   * @return (array) Array of DB_CalService objects
   */
   public static function getCertificateCalServices($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB') )
      { throw new Exception ("Provided database object must be class or subclass of 'DB'."); }

      $calservice_nums = array('1','2','3','4','5');

      $calservice_objects = array();
      foreach ( $calservice_nums as $calservice_num )
      {
         $calservice_object = new DB_CalService($input_database_object, $calservice_num);
         array_push($calservice_objects, $calservice_object);
      }

      return ($calservice_objects);
   }
}

?>
