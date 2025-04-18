<?PHP

include_once "/var/www/html/inc/validator.php";
include_once "utils.php";

/**
*
* Product class that relates a cylinder and fill code to an order
*
* A product relates cylinder + fill code to a specific order.
*
* A product that does not have a specific cylinder specified is waiting for a 
* cylinder to be filled. Otherwise, a product should have a specific cylinder*
*  and fill code. 
*
* A product that does not have a specific order specified is a product extra. 
* A product extra is a cylinder in the analysis process that is waiting to be 
* assigned to an order. Otherwise, a product should have a specified order. 
*
*/

class Product
{
   /** Related DB_Order object */
   private $order_object;

   /** Related DB_Cylinder object */
   private $cylinder_object;

   /** Cylinder fill code */
   private $fill_code;

   /** Product status abbreviation */
   private $status_abbr;

   /** Cylinder size abbreviation */
   private $cylinder_size_abbr;

   /** Order comments */
   private $comments;

   /**
   * Contsructor method for instantiating a Product object
   *
   * @param $input_order_object (Order|'') Order object or ''
   * @param $input_cylinder_size (string) Cylinder size string
   * @return (Product) Product object.
   */
   public function __construct($input_order_object, $input_cylinder_size)
   {
      $this->setOrder($input_order_object);
      $this->setCylinderSize($input_cylinder_size);

      return $this;
   }

   /**
   * Method to set order
   *
   * @param $input_object (Order|'') Order object or empty string
   * @return void
   */
   public function setOrder($input_object)
   {
      if ( is_a($input_object, 'Order') ||
           $input_object == '' )
      { $this->order_object = $input_object; }
      else
      { throw new Exception ("Provided order must be an object of or subclass of class Order."); }
   }

   /**
   * Method to retrieve order
   *
   * @return (Order|'') Order object or empty string.
   */
   public function getOrder()
   {
      if ( isset($this->order_object) &&
           is_a($this->order_object, 'Order' ) )
      { return $this->order_object; }
      else
      { return ''; }
   }

   /**
   * Method to set cylinder
   *
   * @param $input_object (Cylinder|'') Cylinder object or empty string
   * @return void
   */
   public function setCylinder($input_object)
   {
      if ( is_a($input_object, 'Cylinder') ||
           $input_object == '' )
      { $this->cylinder_object = $input_object; }
      else
      { throw new Exception ("Provided cylinder must be an object of or subclass of class Cylinder or empty string ('')."); }
   }

   /**
   * Method to retrieve cylinder
   *
   * @return (Cylinder|'') Cylinder object or empty string.
   */
   public function getCylinder()
   {
      if ( isset($this->cylinder_object) &&
           is_a($this->cylinder_object, 'Cylinder' ) )
      { return $this->cylinder_object; }
      else
      { return ''; }
   }

   /**
   * Method to set the fill code of the cylinder
   *
   * This information is required so the system can determine which analysis
   * results to display based on cylinder and fill code
   *
   * @param $input_value (string) Fill code
   * @return void
   */
   public function setFillCode($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Z]$/', $input_value) )
      { $this->fill_code = $input_value; }
      else
      { throw new Exception ("Provided fill code '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the fill code
   *
   * @return (string) Fill code.
   */
   public function getFillCode()
   {
      if ( isset($this->fill_code) &&
           preg_match('/^[A-Z]$/', $this->fill_code) )
      { return $this->fill_code; }
      else
      { return ''; }
   }

   /**
   * Method to set the status
   *
   * This method is protected as it is used by its children
   *
   * @param $input_value (string) Status
   * @return void
   */
   protected function setStatus($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $input_value) )
      { $this->status_abbr = $input_value; }
      else
      { throw new Exception ("Provided status '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the status
   *
   * @return (string) Status
   */
   public function getStatus()
   {
      if ( isset($this->status_abbr) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $this->status_abbr) )
      { return $this->status_abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set the requested cylinder size
   *
   * @param $input_value (string) Cylinder size
   * @return void
   */
   public function setCylinderSize($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9]+$/', $input_value) )
      { $this->cylinder_size_abbr = $input_value; }
      else
      { throw new Exception ("Provided cylinder size '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the requested cylinder size
   *
   * @return (string) Cylinder size
   */
   public function getCylinderSize()
   {
      if ( isset($this->cylinder_size_abbr) &&
           preg_match('/^[A-Za-z0-9]+$/', $this->cylinder_size_abbr) )
      { return $this->cylinder_size_abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set comments
   *
   * @param $input_value (string) Input comments.
   * @return void
   */
   public function setComments($input_value)
   {
      $this->comments = $input_value;
   }

   /**
   * Method to retrieve comments
   *
   * @return (string) Comments.
   */
   public function getComments()
   {
      if ( isset($this->comments) )
      { return $this->comments; }
      else
      { return ''; }
   }

   /**
   * Method to determine if a given Product is equal to this one
   *
   * They should be exactly the same in all data.
   *
   * @param $input_object (Product) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getFillCode() === $input_object->getFillCode() &&
           $this->getStatus() === $input_object->getStatus() &&
           $this->getCylinderSize() === $input_object->getCylinderSize() &&
           $this->getComments() === $input_object->getComments() )
      {
         $order1 = $this->getOrder();
         $order2 = $input_object->getOrder();

         if ( is_a($order1, 'Order') &&
              is_a($order2, 'Order') &&
              $order1->matches($order2) )
         { }
         elseif ( $order1 === $order2 )
         { }
         else
         { return false; }

         $cylinder1 = $this->getCylinder();
         $cylinder2 = $input_object->getCylinder();

         if ( is_a($cylinder1, 'Cylinder') &&
              is_a($cylinder2, 'Cylinder') &&
              $cylinder1->matches($cylinder2) )
         { }
         elseif ( $cylinder1 === $cylinder2 )
         { }
         else
         { return false; }

         return true;
      }
      else
      { return false; }
   }

   /**
   * Method to determine if a given Product matches to this one
   *
   * They should have the same primary information. Think primary key.
   *
   * @param $input_object (Product) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getCylinderSize() === $input_object->getCylinderSize() )
      {
         if ( is_object($this->getOrder()) &&
              is_object($input_object->getOrder()) &&
              ! $this->getOrder()->matches($input_object->getOrder()) )
         { return false; }

         return true;
      }
      else
      { return false; }
   }
}
