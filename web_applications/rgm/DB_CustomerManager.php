<?PHP

require_once "utils.php";
require_once "CCGDB.php";
require_once "DB_Customer.php";

/**
* DB_Customer manager class that provides methods to search and retrieve DB_Customers
*
* This class provides methods to search for customers based on relational number,
* first name, last name, etc...
* 
*/

class DB_CustomerManager
{
   /**
   * Method to search for DB_Customer by relational number
   *
   * @param $input_value (int) Search number
   * @return (array) Array of matching DB_Customer objects
   */
   public static function searchByNum($input_value)
   {
      $customer_objects = array();

      # See if the input value matches a specific customer
      try
      {
         $database_object = new CCGDB();

         $customer_object = new DB_Customer($database_object, $input_value);

         array_push($customer_objects, $customer_object);
      }
      catch ( Exception $e )
      {
         # Do nothing
      }

      $customer_objects = array_unique_obj($customer_objects);

      return ($customer_objects);
   }

   /**
   * Method to search for DB_Customer by first name
   *
   * @param $input_value (string) Input string.
   * @return (array) Array of matching DB_Customer objects
   */
   public static function searchByFirstName($input_value)
   {
      $customer_objects = array();

      $database_object = new CCGDB();

      $sql = " SELECT id FROM customers WHERE first_name LIKE ?";
      $sqlargs = array('%'.$input_value.'%');

      $res = $database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $customer_object = new DB_Customer($database_object, $aarr[0]);

         array_push($customer_objects, $customer_object);
      }

      $customer_objects = array_unique_obj($customer_objects);

      return ($customer_objects);
   }

   /**
   * Method to search for DB_Customer by last name
   *
   * @param $input_value (string) Input string.
   * @return (array) Array of matching DB_Customer objects
   */
   public static function searchByLastName($input_value)
   {
      $customer_objects = array();

      $database_object = new CCGDB();

      $sql = " SELECT id FROM customers WHERE last_name LIKE ?";
      $sqlargs = array('%'.$input_value.'%');

      $res = $database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $customer_object = new DB_Customer($database_object, $aarr[0]);

         array_push($customer_objects, $customer_object);
      }

      $customer_objects = array_unique_obj($customer_objects);

      return ($customer_objects);
   }

   /**
   * Method to search for DB_Customer email
   *
   * @param $input_value (string) Input string.
   * @return (array) Array of matching DB_Customer objects
   */
   public static function searchByEmail($input_value)
   {
      $customer_objects = array();

      $database_object = new CCGDB();

      $sql = " SELECT id FROM customers WHERE email LIKE ?";
      $sqlargs = array('%'.$input_value.'%');

      $res = $database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $customer_object = new DB_Customer($database_object, $aarr[0]);

         array_push($customer_objects, $customer_object);
      }

      $customer_objects = array_unique_obj($customer_objects);

      return ($customer_objects);
   }

   /**
   * Method to search for DB_Customer by input string
   *
   * This method calls searchByNum(), searchByFirstName(), searchByLastName()
   #   searchByEmail()
   *
   * @param $input_value (string) Input string.
   * @return (array) Array of matching DB_Customer objects
   */
   public function search($input_value)
   {
      $customer_objs = array ();

      $tmp_objs = DB_CustomerManager::searchByNum($input_value);

      if ( count($tmp_objs) > 0 )
      { $customer_objs = array_merge($customer_objs, $tmp_objs); }

      $tmp_objs = DB_CustomerManager::searchByFirstName($input_value);

      if ( count($tmp_objs) > 0 )
      { $customer_objs = array_merge($customer_objs, $tmp_objs); }

      $tmp_objs = DB_CustomerManager::searchByLastName($input_value);

      if ( count($tmp_objs) > 0 )
      { $customer_objs = array_merge($customer_objs, $tmp_objs); }

      $tmp_objs = DB_CustomerManager::searchByEmail($input_value);

      if ( count($tmp_objs) > 0 )
      { $customer_objs = array_merge($customer_objs, $tmp_objs); }

      #echo "<PRE>";
      #print_r($customer_objs);
      #echo "</PRE>";

      $customer_objs = array_values(array_unique_obj($customer_objs));

      usort($customer_objs, array("DB_CustomerManager", "cmp_abbr"));

      return($customer_objs);
   }

   /**
   * Method used for sorting DB_Customer objects
   *
   * This method is used in usort() to sort DB_Customer objects by full name
   *
   * @return void
   */
   static function cmp_abbr($a, $b)
   {
      $al = strtolower($a->getFullName());
      $bl = strtolower($b->getFullName());
      if ($al == $bl)
      {
         return 0;
      }
      return ($al > $bl) ? +1 : -1;
   }

}
