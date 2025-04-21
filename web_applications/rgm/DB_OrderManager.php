<?PHP

require_once "CCGDB.php";
require_once "DB_Order.php";
require_once "DB_CustomerManager.php";
require_once "/var/www/html/inc/validator.php";

/**
* DB_Order manager class that provides methods to search and retrieve DB_Orders
*
* This class provides methods to search for orders based on relational number,
* customer, cylinder, organization, etc.. Also, retrieves active and pending
* orders.
* 
*/

class DB_OrderManager
{

   /**
   * Method to search for DB_Order by relational number
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (int) Search number
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByNum($input_database_object, $input_value)
   {
      $order_objects = array();

      # See if the input value matches a specific order
      try
      {
         $order_object = new DB_Order($input_database_object, $input_value);

         array_push($order_objects, $order_object);
      }
      catch ( Exception $e )
      {
         # Do nothing
      }

      $order_objects = array_unique_obj($order_objects);

      return ($order_objects);
   }

   /**
   * Method to search for DB_Order by customer object or string
   *
   * This method searches for DB_Orders matching the search string$input_value.
   * $input_value is first used to try and instantiate a DB_Customer object.
   * If successful, all matching DB_Orders to that specific DB_Customer object
   * will be returned. If unsuccessful, then use $input_value to call
   * DB_CustomerManager::search() find all matching DB_Customers. Then using
   * the array of DB_Customers, look for matching DB_Orders to each element
   * in the array. 
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Input string
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByCustomer($input_database_object, $input_value)
   {
      $order_objects = array();

      # Try to instantiate a DB_Customer based on the input_value
      try
      { $customer_object = new DB_Customer($input_database_object, $input_value); }
      catch ( Exception $e )
      { $customer_object = ''; }

      $search_customer_objects = array();

      if ( is_object($customer_object) )
      {
         #
         # If we were able to instantiate a single DB_Customer then only search
         #   on that one
         #
         array_push($search_customer_objects, $customer_object);
      }
      else
      {
         $search_customer_objects = DB_CustomerManager::search($input_value);

         if ( count($search_customer_objects) > 100 )
         { throw new Exception ("Too many matching customers found."); }
      }

      #
      # Now search for all the orders matching specific customers
      #
      $order_objects = array();

      foreach ( $search_customer_objects as $search_customer_object )
      {
         $sql = " SELECT num FROM order_tbl WHERE primary_customer_user_id = ?";
         $sqlargs = array($search_customer_object->getNum());

         $res = $input_database_object->queryData($sql, $sqlargs);

         foreach ( $res as $aarr )
         {
            $order_object = new DB_Order($input_database_object, $aarr[0]);

            array_push($order_objects, $order_object);
         }

         $sql = " SELECT order_num FROM order_customer WHERE customer_user_id = ?";
         $sqlargs = array($search_customer_object->getNum());

         $res = $input_database_object->queryData($sql, $sqlargs);

         foreach ( $res as $aarr )
         {
            $order_object = new DB_Order($input_database_object, $aarr[0]);

            array_push($order_objects, $order_object);
         }
      }

      $order_objects = array_unique_obj($order_objects);

      return ($order_objects);
   }

   /**
   * Method to retrieve DB_Orders related to a specific cylinder search string
   *
   * This method takes $input_value and tries to instantiate a DB_Cylinder
   * object. Using that DB_Cylinder object, it calls
   * DB_ProductManager::searchByCylinder() to find related DB_Products.
   * Then it uses DB_Product::getOrder() to retrieve all related DB_Orders.
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Cylinder ID search string
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByCylinder($input_database_object, $input_value)
   {
      $order_objects = array();

      # See if the input value matches a specific cylinder
      try
      { $cylinder_object = new DB_Cylinder($input_database_object, $input_value, 'id'); }
      catch ( Exception $e )
      { $cylinder_object = ''; }

      if ( is_object($cylinder_object) )
      {
         $product_objects = DB_ProductManager::searchByCylinder($input_database_object, $cylinder_object);

         foreach ( $product_objects as $product_object )
         {
            if ( is_object($product_object->getOrder()) )
            { array_push($order_objects, $product_object->getOrder()); }
         }
      }

      $order_objects = array_unique_obj($order_objects);

      return ($order_objects);
   }

   /**
   * Method to search for DB_Order objects by organization related to search string
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Search string
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByOrganization($input_database_object, $input_value)
   {
      $order_objects = array();

      $sql = " SELECT num FROM order_tbl WHERE organization LIKE ?";
      $sqlargs = array('%'.$input_value.'%');

      $res = $input_database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $order_object = new DB_Order($input_database_object, $aarr[0]);

         array_push($order_objects, $order_object);
      }

      $order_objects = array_unique_obj($order_objects);

      return ($order_objects);
   }

   /**
   * Method to search for DB_Order objects by comments related to search string
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Search string
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByComments($input_database_object, $input_value)
   {
      $order_objects = array();

      $sql = " SELECT num FROM order_tbl WHERE comments LIKE ?";
      $sqlargs = array('%'.$input_value.'%');

      $res = $input_database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $order_object = new DB_Order($input_database_object, $aarr[0]);

         array_push($order_objects, $order_object);
      }

      $order_objects = array_unique_obj($order_objects);

      return ($order_objects);
   }

   /**
   * Method to retrieve DB_Orders related to a specific calservice search string
   *
   * This method takes $input_value and tries to instantiate a DB_CalService
   * object. Using that DB_CalService object, it calls
   * DB_CalRequestManager::searchByCalService() to find related DB_CalRequests.
   * Then it uses DB_CalRequest::getProduct()::getOrder() to retrieve all
   * related DB_Orders.
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (string) Calservice search string
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByCalService($input_database_object, $input_value)
   {
      $order_objects = array();

      # See if the input value matches a specific order
      try
      { $calservice_object = new DB_CalService($input_database_object, $input_value); }
      catch ( Exception $e )
      { $calservice_object = ''; }

      if ( is_object($calservice_object) )
      {
         $calrequest_objects = DB_CalRequestManager::searchByCalService($input_database_object, $calservice_object);

         foreach ( $calrequest_objects as $calrequest_object )
         {
            if ( is_object($calrequest_object->getProduct()->getOrder()) )
            { array_push($order_objects, $calrequest_object->getProduct()->getOrder()); }
         }
      }

      $order_objects = array_unique_obj($order_objects);

      return ($order_objects);
   }

   /**
   * Method to search for DB_Order objects with due date between a beginning date
   * and an ending date
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value_min (string) Beginning date. Format YYYY-MM-DD.
   * @param $input_value_max (string) Ending date. Format YYYY-MM-DD.
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByDueDate($input_database_object, $input_value_min, $input_value_max)
   {
      $order_objects = array();

      if ( ! ValidDate($input_value_min) )
      { throw new Exception ("Input value date '$input_value_min' is not valid date."); }

      if ( ! ValidDate($input_value_max) )
      { throw new Exception ("Input value date '$input_value_max' is not valid date."); }

      $sql = " SELECT num FROM order_tbl WHERE due_date BETWEEN ? AND ?";
      $sqlargs = array($input_value_min, $input_value_max);

      $res = $input_database_object->queryData($sql, $sqlargs);

      $order_objects = array();
      foreach ( $res as $aarr )
      {
         $order_object = new DB_Order($input_database_object, $aarr[0]);

         array_push($order_objects, $order_object);
      }

      return ($order_objects);
   }

   /**
   * Method to search for DB_Order objects with creation date between a beginning
   * date and an ending date
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value_min (string) Beginning date. Format YYYY-MM-DD.
   * @param $input_value_max (string) Ending date. Format YYYY-MM-DD.
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByCreationDate($input_database_object, $input_value_min, $input_value_max)
   {
      $order_objects = array();

      if ( ! ValidDate($input_value_min) )
      { throw new Exception ("Input value date '$input_value_min' is not valid date."); }

      if ( ! ValidDate($input_value_max) )
      { throw new Exception ("Input value date '$input_value_max' is not valid date."); }

      $sql = " SELECT num FROM order_tbl WHERE creation_datetime BETWEEN ? AND ?";
      $sqlargs = array($input_value_min, $input_value_max);

      $res = $input_database_object->queryData($sql, $sqlargs);

      $order_objects = array();
      foreach ( $res as $aarr )
      {
         $order_object = new DB_Order($input_database_object, $aarr[0]);

         array_push($order_objects, $order_object);
      }

      return ($order_objects);
   }

   /**
   * Method to search for DB_Order objects by status related to search string
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_value (int|string) Search string
   * @return (array) Array of matching DB_Order objects
   */
   public static function searchByStatus($input_database_object, $input_value)
   {
      $order_objects = array();

      if ( ValidInt($input_value) )
      { $sql = " SELECT num FROM order_status WHERE num = ?"; }
      else
      { $sql = " SELECT num FROM order_status WHERE abbr = ?"; }

      $sqlargs = array($input_value);

      $res = $input_database_object->queryData($sql, $sqlargs);

      $sql = " SELECT num FROM order_tbl WHERE order_status_num = ?";

      if ( isset($res[0]) &&
           isset($res[0][0]) )
      { $sqlargs = array($res[0][0]); }
      else
      { throw new Exception ("No order status found in database."); }

      $res = $input_database_object->queryData($sql, $sqlargs);

      $order_objects = array();
      foreach ( $res as $aarr )
      {
         $order_object = new DB_Order($input_database_object, $aarr[0]);

         array_push($order_objects, $order_object);
      }

      return ($order_objects);
   }

   /**
   * Method to retrieve all active orders
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of active DB_Orders
   */
   public function getActiveOrders($input_database_object)
   {
      $active_status_nums = array ('1', '2', '3', '4', '6');

      $order_objects = array();
      foreach ( $active_status_nums as $active_status_num )
      {
         $tmp_objects = DB_OrderManager::searchByStatus($input_database_object, $active_status_num);

         $order_objects = array_merge($order_objects, $tmp_objects);
      }


      return $order_objects;
   }

   /**
   * Method to retrieve all pending orders
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of pending DB_Orders
   */
   public function getPendingOrders($input_database_object)
   {
      $active_status_nums = array ('8');

      $order_objects = array();
      foreach ( $active_status_nums as $active_status_num )
      {
         $tmp_objects = DB_OrderManager::searchByStatus($input_database_object, $active_status_num);

         $order_objects = array_merge($order_objects, $tmp_objects);
      }


      return $order_objects;
   }

   /**
   * Method to encode $input_value into a coded string
   *
   * @return (string) Encoded string
   */
   public static function encodeString($input_value)
   {
      # We need to be able to encode to the same encoded number
      #   as users will reference that number

      $length = '8';
      $randomString = 'CcGg2013';

      return(base64_encode(str_rot13($length.$randomString.$input_value)));
   }

   /**
   * Method to decode $input_value into a decoded string
   *
   * @return (string) Decoded string
   */
   public static function decodeString($input_value)
   {
      $decoded_value = str_rot13(base64_decode($input_value));

      return(substr($decoded_value, substr($decoded_value, 0, 1)+1));
   }

   /**
   * Method to retrieve order statuses in array sorted in process sequence
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Associative array of relational number and abbrevation
   */
   public static function getOrderStatusSequence($input_database_object)
   {
      $status_nums = array ('1', '2', '3', '4', '5');

      $aarr = array();

      $sql = " SELECT abbr FROM order_status WHERE num = ?";

      foreach ( $status_nums as $status_num )
      {
         $sqlargs = array($status_num);

         $res = $input_database_object->queryData($sql, $sqlargs);

         if ( isset($res[0]) &&
              isset($res[0][0]) )
         {
            $aarr[$status_num] = $res[0][0];
         }
      }

      return ($aarr);

   }

   /**
   * Method to retrieve pending orders related to provided DB_Order
   *
   * Based on the provided DB_Order, search for pending orders based on
   * related customers, cylinders.
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_order_object (DB_Order) DB_Order object
   * @return (array) Array of matching DB_Order objects
   */ 
   public static function getRelatedPendingOrders($input_database_object, DB_Order $input_order_object)
   {
      $tmp_order_objects = array ();

      # Check for pending orders based on cylinder ID

      $product_objects = DB_ProductManager::searchByOrder($input_database_object, $input_order_object);

      foreach ( $product_objects as $product_object )
      {
         if ( is_object($product_object->getCylinder() ) )
         {
            $tmp_objects = DB_OrderManager::searchByCylinder($input_database_object, $product_object->getCylinder()->getID());

            $tmp_order_objects = array_merge($tmp_order_objects, $tmp_objects);
         }
      }

      # Check for pending orders based on primary customer

      $tmp_objects = DB_OrderManager::searchByCustomer($input_database_object, $input_order_object->getPrimaryCustomer()->getEmail());

      $tmp_order_objects = array_merge($tmp_order_objects, $tmp_objects);

      # Check for pending orders based on additional customers

      $customer_objects = $input_order_object->getCustomers();

      if ( count($customer_objects) > 0 )
      {
         foreach ( $customer_objects as $customer_object )
         {
            $tmp_objects = DB_OrderManager::searchByCustomer($input_database_object, $customer_object->getEmail());
            $tmp_order_objects = array_merge($tmp_order_objects, $tmp_objects);
         }
      }

      # Filter out only the pending orders
      $pending_order_objects = array();
      foreach ( $tmp_order_objects as $tmp_object )
      {
         if ( $tmp_object->isPending() &&
              ! $tmp_object->equals($input_order_object) )
         { array_push($pending_order_objects, $tmp_object); }
      }

      $pending_order_objects = array_unique_obj($pending_order_objects);

      return ($pending_order_objects);
   }
}
