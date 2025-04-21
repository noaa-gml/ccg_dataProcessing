<?PHP

require_once "CCGDB.php";

/**
* DB_Cylinder manager class that provides methods for auxillary cylinder informationn
* 
* This class provides methods to retrieve cylinder information such as
* available cylinder sizes, types, and statuses.
*
*/

class DB_CylinderManager
{
   /**
   * Method to retrieve available cylinder sizes
   *
   * This method queries the database and returns an associative array
   * of available cylinder size.
   *
   * @return (array) Associative array of relational number and abbreviation
   */
   public static function getCylinderSizes($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      $sql = " SELECT num, abbr FROM cylinder_size ORDER BY num";
     
      $res = $input_database_object->queryData($sql);

      $ret_aarr = array();
      foreach ( $res as $aarr )
      {
         $ret_aarr[$aarr['num']] = $aarr['abbr'];
      }

      natsort($ret_aarr);

      return ($ret_aarr);
   }

   /**
   * Method to retrieve available cylinder types
   *
   * This method queries the database and returns an associative array
   * of available cylinder types.
   *
   * @return (array) Associative array of relational number and abbreviation
   */
   public static function getCylinderTypes($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }
      
      $sql = " SELECT num, abbr FROM cylinder_type ORDER BY num";
     
      $res = $input_database_object->queryData($sql);

      $ret_aarr = array();
      foreach ( $res as $aarr )
      {
         $ret_aarr[$aarr['num']] = $aarr['abbr'];
      }

      return ($ret_aarr);
   }

   /**
   * Method to retrieve available cylinder statuses
   *
   * This method queries the database and returns an associative array
   * of available cylinder statuses.
   *
   * @return (array) Associative array of relational number and abbreviation
   */
   public static function getCylinderStatuses($input_database_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }
      
      $sql = " SELECT num, abbr FROM cylinder_status ORDER BY num";
     
      $res = $input_database_object->queryData($sql);

      $ret_aarr = array();
      foreach ( $res as $aarr )
      {
         $ret_aarr[$aarr['num']] = $aarr['abbr'];
      }

      return ($ret_aarr);
   }

   /**
   * Method to retrive the status numbers of the related DB_Cylinders to a DB_Order
   *
   * Note: If a cylinder has not been set for a product then the status number
   *       returned will be NULL or ''.
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

      $sql = " SELECT t2.cylinder_status_num FROM product AS t1 LEFT JOIN cylinder AS t2 ON (t1.cylinder_num = t2.num) WHERE t1.order_num = ?";
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
