<?PHP

include_once "/var/www/html/inc/validator.php";
include_once "utils.php";

/**
*
* Order class for order details and related customers
*
* An order has details such as due date, MOU number, organization,
*  primary customer, additional customers, and general order
*  status
*
*/

class Order
{
   /** Primary Customer object  */
   private $primary_customer_object;

   /** Additional Customer objects */
   private $customer_objects;

   /** Order creation date time */
   private $creation_datetime;

   /** Order due date */
   private $due_date;

   /** MOU number */
   private $MOU_number;

   /** Organization */
   private $organization;

   /** Location object of shipment */
   private $shipping_location_object;

   /** Status abbrevation*/
   private $status_abbr;

   /** Priority color in HTML. Ranges from yellow->orange->red as due date approaches. */
   private $priority_color_html;

   /** Order comments */
   private $comments;

   /**
   * Constructor method for instantiating an Order object
   *
   * @param $input_value (string) Due date string. Format 'YYYY-MM-DD'.
   * @return (Order) Instantiated object.
   */
   public function __construct($input_value)
   {
      $this->setCreationDatetime(date("Y-m-d H:m:s"));
      $this->setDueDate($input_value);

      return $this;
   }

   /**
   * Method to set primary Customer object
   *
   * @param $input_object (Customer) Customer object.
   * @return void
   */
   public function setPrimaryCustomer($input_object)
   {
      if ( ! is_a($input_object, 'Customer') )
      { throw new Exception ("Provided object must be of or subclass of class 'Customer'."); }

      $this->primary_customer_object = $input_object;
   }

   /**
   * Method to get primary Customer object
   *
   * If the primary customer is not set, then '' is returned
   *
   * @return (Customer|'') Returns Customer object or empty string ('').
   */
   public function getPrimaryCustomer()
   {
      if ( isset($this->primary_customer_object) &&
           is_a($this->primary_customer_object, 'Customer') )
      { return $this->primary_customer_object; }
      else
      { return ''; }
   }

   /**
   * Method to add an additional related customer 
   *
   * @param $input_object (Customer) Customer object.
   * @return void
   */
   public function addCustomer($input_object)
   {
      if ( ! is_a($input_object, 'Customer') )
      { throw new Exception ("Provided object must be of or subclass of class 'Customer'."); }

      $customer_objects = $this->getCustomers();

      if ( ! match_in_array($input_object, $customer_objects) )
      {
         array_push($customer_objects, $input_object);
         $this->customer_objects = $customer_objects;
      }
   }

   /**
   * Method to remove a customer from the array of related customers
   *
   * @todo This function is not used at all. Maybe remove it.
   *
   * @param $input_object (Customer) Customer object
   * @return void
   */
   public function removeCustomer($input_object)
   {
      if ( ! is_a($input_object, 'Customer') )
      { throw new Exception ("Provided object must be of or subclass of class 'Customer'."); }

      $customer_objects = $this->getCustomers();

      $tmp_objects = array();
      foreach ( $customer_objects as $customer_object )
      {
         if ( ! $customer_object->matches($input_object) )
         { array_push($tmp_objects, $input_object); }
      }

      $this->customer_objects = $tmp_objects;
   }

   /**
   * Method to set array of related additional customers
   *
   * @param $input_objects (array) Array of Customer objects.
   * @return void
   */
   public function setCustomers($input_objects = array())
   {
      $this->customer_objects = array();

      $tmp_objects = array();
      foreach ( $input_objects as $input_object )
      { $$this->addCustomer($input_object); }
   }

   /**
   * Method to retrieve array of related additional customers
   *
   * @return (array) Arary of Customer objects.
   */
   public function getCustomers()
   {
      if ( ! isset($this->customer_objects) &&
           ! is_array($this->customer_objects) )
      { return array(); }

      $tmp_objects = array();
      foreach ( $this->customer_objects as $customer_object )
      {
         if ( is_a($customer_object, 'Customer') )
         { array_push($tmp_objects, $customer_object); }
      }

      return $tmp_objects;
   }

   /**
   * Method to set due date of order
   *
   * Besides storing the due date of the order, this method also updates
   * the priority color of the order.
   *
   * @param $input_value (string) Due date string. Format 'YYYY-MM-DD'.
   * @return void
   */
   public function setDueDate($input_value)
   {
      if ( ValidDate($input_value) )
      {
         $this->due_date = $input_value;
         $this->setPriorityColorHTML();
      }
      else
      { throw new Exception ("Provided due date '".htmlentities($input_value)."' is not valid."); }
   }

   /**
   * Method to retrieve due date
   *
   * @return (string) Due date string or empty string ("').
   */
   public function getDueDate()
   {
      if ( isset($this->due_date) &&
           ValidDate($this->due_date) )
      { return $this->due_date; }
      else
      { return ''; }
   }


   /**
   * Method to set the priority color
   *
   * The priority color is changed based on the difference from today and
   *  and the due date
   *
   * @return void
   */
   public function setPriorityColorHTML()
   {
      $secondsdiff = strtotime($this->getDueDate()) - strtotime('now');
      $daysdiff = $secondsdiff / 86400;
      if ( $daysdiff <= 30 )
      {
         # Red
         $color = '#DF0024';
      } 
      elseif ( $daysdiff > 30 && $daysdiff <= 60 )
      {
         # Orange
         $color = '#EF9C00';
      } 
      elseif ( $daysdiff > 60 && $daysdiff <= 90 )
      {
         # Yellow 
         $color = '#F8F400';
      }
      else
      {
         # White
         $color = '#FFFFFF';
      }

      $this->priority_color_html = $color;
   }

   /**
   * Method to retrieve priority color in HTML hex code
   *
   * @return (string) HTML color code
   */
   public function getPriorityColorHTML()
   {
      if ( preg_match('/^#[A-Fa-f0-9]+$/', $this->priority_color_html) )
      { return $this->priority_color_html; }
      else
      { return '#000000'; }
   }

   /**
   * Method to set creation date time
   *
   * @param $input_value (datetime) Creation date time. Format 'YYYY-MM-DD HH:MM:SS'.
   * @return void
   */
   protected function setCreationDatetime($input_value)
   {
      if ( ValidDatetime($input_value) )
      { $this->creation_datetime = $input_value; }
      else
      { throw new Exception ("Provided creation date '".htmlentities($input_value)."' is not valid."); }
   }

   /**
   * Method to retrieve creation date time
   *
   * @return (datetime) Creation date time. Format 'YYYY-MM-DD HH:MM:SS'.
   */
   public function getCreationDatetime()
   {
      if ( isset($this->creation_datetime) &&
           ValidDatetime($this->creation_datetime) )
      { return $this->creation_datetime; }
      else
      { return ''; }
   }

   /**
   * Method to set MOU number
   *
   * @param $input_value (string) MOU number.
   * @return void
   */
   public function setMOUNumber($input_value)
   {
      $this->MOU_number = $input_value;
   }

   /**
   * Method to retrieve MOU number
   *
   * @return (string) MOU number or empty string ('').
   */
   public function getMOUNumber()
   {
      if ( isset($this->MOU_number) )
      { return $this->MOU_number; }
      else
      { return ''; }
   }

   /**
   * Method to set organization
   *
   * @param $input_value (string) Organization.
   */
   public function setOrganization($input_value)
   {
      $this->organization = $input_value;
   }

   /**
   * Method to retrieve organization
   *
   * @return (string) Organization or empty string ('').
   */
   public function getOrganization()
   {
      if ( isset($this->organization) )
      { return $this->organization; }
      else
      { return ''; }
   }

   /**
   * Method to set Location where order will be shipped to
   *
   * @param $input_object (Location) Shipment Location.
   * @return void
   */
   public function setShippingLocation($input_object)
   {
      if ( is_a($input_object, 'Location') )
      { $this->shipping_location_object = $input_object; }
      else
      { throw new Exception ("Provided object must be of or subclass of class 'Location'."); }

   }

   /**
   * Method to retrieve shipping location
   *
   * @return (Location|'') Shipment location or empty string ('').   
   */
   public function getShippingLocation()
   {
      if ( isset($this->shipping_location_object) &&
           is_a($this->shipping_location_object, 'Location') )
      { return $this->shipping_location_object; }
      else
      { return ''; }
   }

   /**
   * Method to set the status
   *
   * Such as 'In Analysis', 'Analysis Complete', 'Order Complete', etc...
   *
   * @param $input_value (string) Input status string.
   * @return void
   */
   protected function setStatus($input_value)
   {
      if ( preg_match('/^[A-Za-z0-9_\- ]+$/', $input_value) )
      { $this->status_abbr = $input_value; }
      else
      { throw new Exception ("Provided status '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the status
   *
   * Such as 'In Analysis', 'Analysis Complete', 'Order Complete', etc...
   *
   * @return (string) Status string.
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
   * Method to set comments
   *
   * @param $input_value (string) Input comments.
   * @return void
   */
   public function setComments($input_value)
   {
      # str_replace needs to occur as mb_unserialize incorrectly changes
      #  '"' to '\"'
      $this->comments = urlencode(str_replace('\"', '"', $input_value));
   }

   /**
   * Method to retrieve comments
   *
   * @return (string) Comments.
   */
   public function getComments()
   {
      if ( isset($this->comments) )
      { return urldecode($this->comments); }
      else
      { return ''; }
   }

   /**
   * Method to determine if a given Order is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (Order) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getDueDate() === $input_object->getDueDate() &&
           $this->getCreationDatetime() === $input_object->getCreationDatetime() &&
           $this->getMOUNumber() === $input_object->getMOUNumber() &&
           $this->getOrganization() === $input_object->getOrganization() &&
           $this->getPrimaryCustomer()->equals($input_object->getPrimaryCustomer()) &&
           $this->getStatus() === $input_object->getStatus() &&
           $this->getComments() === $input_object->getComments() )
      {

         # Check primary customer
         if ( is_object($this->getPrimaryCustomer()) )
         {
            if ( is_object($input_object->getPrimaryCustomer()) )
            {
               if ( ! $this->getPrimaryCustomer()->equals($input_object->getPrimaryCustomer()) )
               { return false; }
            }
            else
            { return false; }
         }
         else
         {
            if ( is_object($input_object->getPrimaryCustomer()) )
            { return false; }
            else
            {
               # Do nothing
            }
         }

         # Check shipping location
         if ( is_object($this->getShippingLocation()) )
         {
            if ( is_object($input_object->getShippingLocation()) )
            {
               if ( ! $this->getShippingLocation()->equals($input_object->getShippingLocation()) )
               { return false; }
            }
            else
            { return false; }
         }
         else
         {
            if ( is_object($input_object->getShippingLocation()) )
            { return false; }
            else
            {
               # Do nothing
            }
         }

         list($add_objects, $delete_objects) = compare_object_array($this->getCustomers(), $input_object->getCustomers());

         if ( count($add_objects) === 0 &&
              count($delete_objects) === 0 )
         { }
         else
         { return false; }

         return true;
      }
      else
      { return false; }
   }

   /**
   * Method to determine if a given Order matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (Order) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getCreationDatetime() === $input_object->getCreationDatetime() &&
           $this->getPrimaryCustomer()->equals($input_object->getPrimaryCustomer()) &&
           $this->getMOUNumber() === $input_object->getMOUNumber() )
      { return true; }
      else
      { return false; }
   }


}
