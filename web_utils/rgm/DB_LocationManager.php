<?PHP

require_once "CCGDB.php";
require_once "DB_Location.php";

/**
* DB_Location manager class that provides methods to search and retrieve DB_Locations
*
* This class provides methods to search for locations based on relational number,
* abbreviation, name, comments as well as retrieve check in and ship locations.
* 
*/

class DB_LocationManager
{
   /**
   * Method to query the database for information to instantiate DB_Location objects
   *
   * This is a private method used by other methods in this class to query data
   * from the database to instantiate DB_Location objects
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $sql (string) SQL prepared statement
   * @param $sqlargs (array) Array of arguments.
   * @return (array) Array of DB_Location's
   */
   private function queryDB($input_database_object, $sql, $sqlargs)
   {
      $results_aarr = $input_database_object->queryData($sql, $sqlargs);

      $location_objs = array();
      foreach ( $results_aarr as $aarr )
      {
         $location_obj = new DB_Location($input_database_object, $aarr[0]);

         array_push($location_objs, $location_obj);
      }

      return($location_objs);
   }

   /**
   * Method to search for DB_Location objects by relational number
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (int) Search number
   * @return (array) Array of matching DB_Location objects 
   */
   public function searchByNum($input_database_object, $input_value)
   {
      $sql = " SELECT num FROM location WHERE num = ?";
      $sqlargs = array($input_value);

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method to search for DB_Location objects based on abbreviation
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Search string
   * @return (array) Array of matching DB_Location objects 
   */
   public function searchByAbbreviation($input_database_object, $input_value)
   {
      if ( preg_match('/%/', $input_value) )
      { $sql = " SELECT num FROM location WHERE abbr LIKE ?"; }
      else
      { $sql = " SELECT num FROM location WHERE abbr = ?"; }
      $sqlargs = array($input_value);

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method to search for DB_Location objects based on name
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Search string
   * @return (array) Array of matching DB_Location objects 
   */
   public function searchByName($input_database_object, $input_value)
   {
      if ( preg_match('/%/', $input_value) )
      { $sql = " SELECT num FROM location WHERE name LIKE ?"; }
      else
      { $sql = " SELECT num FROM location WHERE name = ?"; }
      $sqlargs = array($input_value);

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method to search for DB_Location objects based on comments
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Search string
   * @return (array) Array of matching DB_Location objects 
   */
   public function searchByComments($input_database_object, $input_value)
   {
      if ( preg_match('/%/', $input_value) )
      { $sql = " SELECT num FROM location WHERE comments LIKE ?"; }
      else
      { $sql = " SELECT num FROM location WHERE comments = ?"; }
      $sqlargs = array($input_value);

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method to search for DB_Location objects based on the input
   *
   * This method calls the other specific search methods to find matching DB_Locations
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Search string
   * @return (array) Array of matching DB_Location objects 
   */
   public function search($input_database_object, $input_value)
   {
      $location_objs = array ();

      $tmp_objs = DB_LocationManager::searchByNum($input_database_object, $input_value);

      if ( count($tmp_objs) > 0 )
      { $location_objs = array_merge($location_objs, $tmp_objs); }

      $tmp_objs = DB_LocationManager::searchByAbbreviation($input_database_object, $input_value);

      if ( count($tmp_objs) > 0 )
      { $location_objs = array_merge($location_objs, $tmp_objs); }

      $tmp_objs = DB_LocationManager::searchByName($input_database_object, $input_value);

      if ( count($tmp_objs) > 0 )
      { $location_objs = array_merge($location_objs, $tmp_objs); }

      $tmp_objs = DB_LocationManager::searchByComments($input_database_object, $input_value);

      if ( count($tmp_objs) > 0 )
      { $location_objs = array_merge($location_objs, $tmp_objs); }

      #echo "<PRE>";
      #print_r($location_objs);
      #echo "</PRE>";

      $location_objs = array_values(array_unique_obj($location_objs));

      usort($location_objs, array("DB_LocationManager", "cmp_abbr"));

      return($location_objs);
   }

   /**
   * Method to retrieve all DB_Location objects
   *
   * This method retrieves all DB_Location objects from the database
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of DB_Location objects 
   */
   public function getDBLocations($input_database_object)
   {
      $sql = ' SELECT num FROM location ORDER BY abbr';

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method to retrieve DB_Location objects used for checkin
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of DB_Location objects
   */
   public function getCheckInDBLocations($input_database_object)
   {
      $location_objs = array();
      # This is also set in getShipDBLocations()
      $move_location_nums = array('1', '2', '7');

      $sqlarr = array();
      $sqlargs = array();

      foreach ( $move_location_nums as $location_num )
      {
         array_push($sqlarr, 'num = ?');
         array_push($sqlargs, $location_num);
      }

      $sql = ' SELECT num FROM location WHERE '.join(' OR ', $sqlarr).' and active_status = 1 ORDER BY abbr';

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method to retrieve DB_Location objects used for shipping
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of DB_Location objects
   */
   public function getShipDBLocations($input_database_object)
   {
      $location_objs = array();
      # This is also set in getCheckInDBLocations()
      $move_location_nums = array('1', '2', '7');

      $sqlarr = array();
      $sqlargs = array();

      foreach ( $move_location_nums as $location_num )
      {
         array_push($sqlarr, 'num != ?');
         array_push($sqlargs, $location_num);
      }

      $sql = ' SELECT num FROM location WHERE '.join(' AND ', $sqlarr).' and active_status = 1 ORDER BY abbr';

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }
   
   /**
   * Method to retrieve DB_Location objects used for filling
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of DB_Location objects
   */
   public function getFillDBLocations($input_database_object)
   {
      $location_objs = array();
      # This is also set in getCheckInDBLocations()
      $move_location_nums = array('3','4','63','100','101','104','105','108','109');

      $sqlarr = array();
      $sqlargs = array();

      foreach ( $move_location_nums as $location_num )
      {
         array_push($sqlarr, 'num = ?');
         array_push($sqlargs, $location_num);
      }

      $sql = ' SELECT num FROM location WHERE ('.join(' or ', $sqlarr).') and active_status = 1 ORDER BY abbr';

      return DB_LocationManager::queryDB($input_database_object, $sql, $sqlargs);
   }

   /**
   * Method used for sorting DB_Location objects
   *
   * This method is used in usort() to sort DB_Location objects by abbreviation 
   *
   * @return void
   */
   static function cmp_abbr($a, $b)
   {
      $al = strtolower($a->getAbbreviation());
      $bl = strtolower($b->getAbbreviation());
      if ($al == $bl)
      {
         return 0;
      }
      return ($al > $bl) ? +1 : -1;
   }
}
