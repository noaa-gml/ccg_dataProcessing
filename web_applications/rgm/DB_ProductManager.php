<?PHP

require_once "DB_Order.php";
require_once "DB_Product.php";
require_once "DB_Cylinder.php";
require_once "/var/www/html/inc/validator.php";

/**
* DB_Product manager class that provides methods to search and retrieve DB_Product's
*
* This class provides methods to search for products based on cylinder, order,
*  etc...
*/

class DB_ProductManager
{
   /**
   * Method to search for related DB_Products to the provided DB_Cylinder
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_object (DB_Cylinder) Input cylinder object.
   * @return (array) Array of matching DB_Product objects
   */
   public static function searchByCylinder($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_Cylinder' ||
           ! ValidInt($input_object->getNum() ))
      { throw new Exception ("Provided cylinder must be an object of class 'DB_Cylinder'."); }

      $sql = " SELECT num FROM product WHERE cylinder_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $product_objects = array();
      foreach ( $res as $aarr )
      {
         $product_object = new DB_Product($input_database_object, $aarr[0]);

         array_push($product_objects, $product_object);
      }

      return ($product_objects);
   }

   /**
   * Method to search for related DB_Products to the provided DB_Order
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_object (DB_Order) Input order object.
   * @return (array) Array of matching DB_Product objects
   */
   public static function searchByOrder($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_Order' )
      { throw new Exception ("Provided order must be an object of class 'DB_Order'."); }

      # If there is no number, this order has not been saved to the database
      #   and thus has no related products at this time
      if ( ! ValidInt($input_object->getNum()) )
      { return array(); }

      $sql = " SELECT num FROM product WHERE order_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $product_objects = array();
      foreach ( $res as $aarr )
      {
         $product_object = new DB_Product($input_database_object, $aarr[0]);

         array_push($product_objects, $product_object);
      }

      return ($product_objects);
   }

   /**
   * Method to search for DB_Products that are waiting for a fill
   *
   * This means either there is no cylinder assigned or the
   * assigned cylinder is waiting to be refilled
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of matching DB_Product objects
   */
   public static function searchForFilling($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      $product_objects = array();

      # First get the products that do not have a cylinder set
      $sql = " SELECT num FROM product WHERE cylinder_num = ? AND product_status_num != 5";
      $sqlargs = array('0');

      $res = $input_database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $product_object = new DB_Product($input_database_object, $aarr[0]);

         array_push($product_objects, $product_object);
      }

      # Then get the products that are waiting on the cylinder and the cylinder
      #   will be for filling when checked in
      $sql = " SELECT t1.num FROM product as t1, cylinder as t2 WHERE t1.product_status_num = 4 AND t2.cylinder_checkin_status_num = 1 and t1.cylinder_num = t2.num";

      $res = $input_database_object->queryData($sql);

      foreach ( $res as $aarr )
      {
         $product_object = new DB_Product($input_database_object, $aarr[0]);

         array_push($product_objects, $product_object);
      }

      return ($product_objects);
   } 

   /**
   * Method to search for DB_Products that are marked as extra
   *
   * This means that there is no related DB_Order
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of matching DB_Product objects
   */
   public static function searchForExtras($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      $product_objects = array();

      # First get the products that do not have a cylinder set
      $sql = " SELECT num FROM product WHERE order_num = 0";

      $res = $input_database_object->queryData($sql);

      foreach ( $res as $aarr )
      {
         $product_object = new DB_Product($input_database_object, $aarr[0]);

         array_push($product_objects, $product_object);
      }

      return ($product_objects);
   } 

   /**
   * Method to retrive the status numbers of the related DB_Products to a DB_Order
   *
   * This method is used to significantly cut decrease processing speed within
   *  DB_Order.updateStatus()
   *
   * @return (array) Array of status numbers.
   */
   public static function getStatusNumsByOrder($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_Order' )
      { throw new Exception ("Provided order must be an object of class 'DB_Order'."); }

      # If there is no number, this order has not been saved to the database
      #   and thus has no related products at this time
      if ( ! ValidInt($input_object->getNum()) )
      { return array(); }

      $sql = " SELECT product_status_num FROM product WHERE order_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);
      
      $product_status_nums = array();
      foreach ( $res as $aarr )
      {
         array_push($product_status_nums, $aarr[0]);
      }

      return ($product_status_nums);
   }
}
