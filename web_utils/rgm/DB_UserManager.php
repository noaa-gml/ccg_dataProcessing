<?PHP

require_once "CCGDB.php";
require_once "DB_User.php";

/**
* DB_User manager class that privodes methods to search and retrieve DB_Users
*
*/

class DB_UserManager
{
   /**
   * Method to search for DB_Users related to input DB_CalService
   *
   * @param $input_database_object (DB) Input database object
   * @param $input_object (DB_CalService) Input object
   * @return (array) Array of matching DB_CalService objects 
   */
   public static function searchByCalService($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_CalService' )
      { throw new Exception ("Provided object must be of class 'DB_CalService'"); }

      $sql = " SELECT contact_num FROM calservice_user WHERE calservice_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $user_objects = array();
      foreach ( $res as $aarr )
      {
         $user_object = new DB_User($input_database_object, $aarr[0]);

         array_push($user_objects, $user_object);
      }

      return ($user_objects);
   }

   /**
   * Method to retrieve user preferences
   *
   * @param $input_database_object (DB) Input database object
   * @param $input_object (DB_User) Input object
   * @return (array) Associative array of user preferences
   */
   public static function getPreferences($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_User' )
      { throw new Exception ("Provided object must be of class 'DB_User'"); }

      $sql = " SELECT value FROM user_preferences WHERE contact_num = ?";
      $sqlargs = array($input_object->getNum());

      #print $sql."<BR>\n";
      #print join("|", $sqlargs)."<BR>\n";

      $results = $input_database_object->queryData($sql, $sqlargs);

      if ( isset($results[0]) )
      {
         return unserialize(urldecode($results[0]['value']));
      }

      return array();
   }

   /**
   * Method to save user preferences
   *
   * @param $input_database_object (DB) Input database object
   * @param $input_object (DB_User) Input object
   * @param $input_array (array) Associative array of user preferences
   * @return void
   */
   public static function setPreferences($input_database_object, $input_object, $input_array=array())
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_User' )
      { throw new Exception ("Provided object must be of class 'DB_User'"); }

      $sql = " SELECT COUNT(*) FROM user_preferences WHERE contact_num = ?";
      $sqlargs = array($input_object->getNum());

      $results = $input_database_object->queryData($sql, $sqlargs);

      if ( $results[0][0] == '0' )
      {
         # INSERT
         $sql = " INSERT INTO user_preferences";
         $sql = $sql." (contact_num, value)";
         $sql = $sql." VALUES (?,?)";
         $sqlargs = array($input_object->getNum(), urlencode(serialize($input_array)));

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";
 
         $input_database_object->executeSQL($sql, $sqlargs);
      }
      else
      {
         # UPDATE
         $sql = " UPDATE user_preferences";
         $sql = $sql." SET value = ?";
         $sql = $sql." WHERE contact_num = ?";
         $sqlargs = array(urlencode(serialize($input_array)), $input_object->getNum());

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";
         
         $input_database_object->executeSQL($sql, $sqlargs);
      }
   }


}
