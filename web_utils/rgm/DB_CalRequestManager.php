<?PHP

require_once "CCGDB.php";
require_once "DB_Product.php";
require_once "DB_CalRequest.php";
require_once "DB_CalService.php";

/**
* Manager class for DB_CalRequest
*
* Class that searches for DB_CalRequest objects and auxiliary information
*/

class DB_CalRequestManager
{

   /**
   * Method to search for DB_CalRequests related to provided DB_Product object
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_object (DB_Product) Input object
   * @return (array) Array of DB_CalRequest objects
   */
   public static function searchByProduct(DB $input_database_object, $input_object)
   {
      if ( get_class($input_object) !== 'DB_Product' )
      { throw new Exception ("Provided product must an object of class 'DB_Product'"); }

      $sql = " SELECT num FROM calrequest WHERE product_num = ? ORDER BY calservice_num";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $calrequest_objects = array();
      foreach ( $res as $aarr )
      {
         $calrequest_object = new DB_CalRequest($input_database_object, $aarr[0]);

         array_push($calrequest_objects, $calrequest_object);
      }

      return ($calrequest_objects);
   }

   /**
   * Method to search for DB_CalRequests related to provided DB_CalService object
   *
   * @param $input_database_object (DB) Input database object. 
   * @param $input_object (DB_CalService) Input object
   * @return (array) Array of DB_CalRequest objects
   */
   public static function searchByCalService(DB $input_database_object, $input_object)
   {
      if ( get_class($input_object) !== 'DB_CalService' )
      { throw new Exception ("Provided product must an object of class 'DB_CalService'"); }

      $sql = " SELECT num FROM calrequest WHERE calservice_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $calrequest_objects = array();
      foreach ( $res as $aarr )
      {
         $calrequest_object = new DB_CalRequest($input_database_object, $aarr[0]);

         array_push($calrequest_objects, $calrequest_object);
      }

      return ($calrequest_objects);
   }

   /**
   * Method to find DB_CalRequest objects that are 'In Progress'
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Array of DB_CalRequest objects 
   */
   public static function searchForAnalysis(DB $input_database_object)
   {
      #
      # Get all calrequests with status 'In Progress'
      #
      $sql = " SELECT num FROM calrequest WHERE calrequest_status_num = ?";
      $sqlargs = array('2');

      $res = $input_database_object->queryData($sql, $sqlargs);

      $calrequest_objects = array();
      foreach ( $res as $aarr )
      {
         $calrequest_object = new DB_CalRequest($input_database_object, $aarr[0]);

         array_push($calrequest_objects, $calrequest_object);
      }

      usort($calrequest_objects, array("DB_CalRequestManager", "sortByCylinderID"));

      return ($calrequest_objects);
   }

   /**
   * Method to retrieve associative array of analysis types
   *
   * Example of analysis types: 'Initial', 'Intermediate', etc...
   *
   * @param $input_database_object (DB) Input database object. 
   * @return (array) Associative array of analysis types. Relational
   *   databane number as the key, abbreviation as value.
   */
   public static function getAnalysisTypes(DB $input_database_object)
   {
      $retaarr = array();

      $sql = " SELECT num, abbr FROM analysis_type ORDER BY num";

      $res = $input_database_object->queryData($sql);

      foreach ( $res as $aarr )
      {
         $retaarr[$aarr['num']] = $aarr['abbr'];
      }

      return ($retaarr);
   }

   /**
   * Method to retrive the status numbers of the related DB_CalRequests to a DB_Product
   *
   * This method is used to significantly cut decrease processing speed within
   *  DB_Product.updateStatus()
   *
   * @return (array) Array of status numbers.
   */
   public static function getStatusNumsByProduct($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_Product' )
      { throw new Exception ("Provided object must be of class 'DB_Product'."); }

      # If there is no number, this product has not been saved to the database
      #   and thus has no related calrequests at this time
      if ( ! ValidInt($input_object->getNum()) )
      { return array(); }

      $sql = " SELECT calrequest_status_num FROM calrequest WHERE product_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $calrequest_status_nums = array();
      foreach ( $res as $aarr )
      {
         array_push($calrequest_status_nums, $aarr[0]);
      }

      return ($calrequest_status_nums);
   }

   /**
   * Method to retrive the status numbers of the related DB_CalRequests to a DB_Order
   *
   * This method is used to significantly cut decrease processing speed within
   *  DB_Product.updateStatus()
   *
   * @return (array) Array of status numbers.
   */
   public static function getStatusNumsByOrder($input_database_object, $input_object)
   {
      if ( ! is_a($input_database_object, 'DB' ) )
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }

      if ( get_class($input_object) !== 'DB_Order' )
      { throw new Exception ("Provided object must be of class 'DB_Order'."); }

      # If there is no number, this product has not been saved to the database
      #   and thus has no related calrequests at this time
      if ( ! ValidInt($input_object->getNum()) )
      { return array(); }

      $sql = " SELECT t1.calrequest_status_num FROM calrequest as t1, product as t2 WHERE t1.product_num = t2.num and t2.order_num = ?";
      $sqlargs = array($input_object->getNum());

      $res = $input_database_object->queryData($sql, $sqlargs);

      $calrequest_status_nums = array();
      foreach ( $res as $aarr )
      {
         array_push($calrequest_status_nums, $aarr[0]);
      }

      return ($calrequest_status_nums);
   }

   /**
   * Method to used to sort calrequest objects by cylinder ID in conjuction with usort()
   *
   * This method is used with usort() to sort calrequest objects by cylinder ID.
   *
   * @param $a (DB_CalRequest) Input object for comparison. 
   * @param $b (DB_CalRequest) Input object for comparison. 
   * @return (int) -1, 0, 1. -1 means $a is less than $b. 0 means $a is equal to $b. 1 means $a is greater than $b.
   */
   public static function sortByCylinderID($a, $b)
   {
      if ( get_class($a) != 'DB_CalRequest' &&
           get_class($b) == 'DB_CalRequest' )
      { return 1; }
      elseif ( get_class($a) == 'DB_CalRequest' &&
               get_class($b) != 'DB_CalRequest' )
      { return -1; }

      if ( is_object($a->getProduct()) )
      {
         $a_product = $a->getProduct();

         if ( is_object($b->getProduct()) )
         {
            $b_product = $b->getProduct();

            if ( is_object($a_product->getCylinder()) &&
                 ! is_object($b_product->getCylinder()) )
            { return 1; }
            elseif ( ! is_object($a_product->getCylinder()) &&
                 is_object($b_product->getCylinder()) )
            { return -1; }
            else
            {
               if ( $a_product->getCylinder()->getID() === $b_product->getCylinder()->getID() )
               { return 0; }
               
               return ( $a_product->getCylinder()->getID() < $b_product->getCylinder()->getID() ) ? -1 : 1;
            }
         }
         else
         {
            # $a has related product but $b does not.
            return -1;
         }
      }
      else
      {
         if ( is_object($b->getProduct()) )
         { return 1; }
         else
         { return 0; }
      }

   }
}
