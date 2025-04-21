<?PHP

require_once "Customer.php";

/**
* Database customer class
*
* This class extends Customer to handle database interations and relational numbers
*
*/

class DB_Customer extends Customer
{
   /** Relational database number */
   private $num;

   /** Related DB objec */
   private $database_object;

   /**
   * Constructor method to instantiate DB_Customer object
   *
   * There are two ways to call this method.
   *  - Syntax 1: new DB_Customer($input_database_object, $input_num)
   *     - Instantiates a DB_Customer based on relational database number.
   *       Load related data from specified database.
   *  - Syntax 2: new DB_Customer($input_database_object, $input_email)
   *     - Instantiates a DB_Customer based on email address
   *       Load related data from specified database.
   *
   * @param $input_num (int) Relational database number
   * @param $input_email (string) Email address
   * @return (DB_Customer) Instantiated object
   */
   public function __construct()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 2 )
      {
         if ( ValidInt($args[1]) )
         {
            $instance = parent::__construct('default@default', 'Default', 'Default');
            $instance->setDB($args[0]);
            $instance->setNum($args[1]);
            $instance->loadFromDB();
            return $instance;
         }
         else
         {
            $instance = parent::__construct('default@default', 'Default', 'Default');
            $instance->setDB($args[0]);
            $instance->setEmail($args[1]);
            $instance->loadFromDB();
            return $instance;
         }
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }
   }

   /**
   * Method to set the related DB object
   *
   * @param $input_object (DB) DB object. 
   * @return void
   */
   private function setDB($input_object)
   {
      if ( is_a($input_object, 'DB' ) )
      { $this->database_object = $input_object; }
      else
      { throw new Exception("Provided database must be an object of or be a subclass of class 'DB'."); }
   }

   /**
   * Method to retrieve the related DB object.
   *
   * @return (DB|'') Returns related DB object or empty string ('').
   */
   public function getDB()
   {
      if ( isset($this->database_object) &&
           is_a($this->database_object, 'DB') )
      { return $this->database_object; }
      else
      { return ''; }
   }

   /**
   * Method to set relational database number
   *
   * @param $input_value (int) Input relational database number
   * @return void
   */
   private function setNum($input_value)
   {
      if ( ValidInt($input_value) )
      { $this->num = $input_value; }
      else
      { throw new Exception("Provided number '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve relational database number
   *
   * @return (int|'') Relational database number or empty string
   */
   public function getNum()
   {
      if ( ValidInt($this->num) )
      { return $this->num; }
      else
      { return ''; }
   }

   /**
   * Method to load related information from database
   *
   * Load the related information using the relational database number
   * or email address.
   *
   * @return void
   */
   public function loadFromDB()
   {
      $dbobj = $this->getDB();

      if ( ValidInt($this->getNum()) )
      {
         $sql = " SELECT id, email, first_name, last_name, phone, fax, mobile, street, zip, city, country FROM customers WHERE id = ?";
         $sqlargs = array($this->getNum());

         $results = $dbobj->queryData($sql, $sqlargs);
      }
      else
      {
         $sql = " SELECT id, email, first_name, last_name, phone, fax, mobile, street, zip, city, country FROM customers WHERE email = ?";
         $sqlargs = array($this->getEmail());

         $results = $dbobj->queryData($sql, $sqlargs);
      }

      #print_r($results);

      if ( count($results) == 1 )
      {
         $this->setNum($results[0]['id']);
         $this->setEmail($results[0]['email']);
         $this->setFirstName($results[0]['first_name']);
         $this->setLastName($results[0]['last_name']);
         $this->setPhone($results[0]['phone']);
         $this->setFax($results[0]['fax']);
         $this->setMobile($results[0]['mobile']);
         $this->setStreet($results[0]['street']);
         $this->setZip($results[0]['zip']);
         $this->setCity($results[0]['city']);
         $this->setCountry($results[0]['country']);
      }
      elseif ( count($results) == 0 )
      {
         if ( ValidInt($this->getNum() ) )
         { throw new UnderflowException("Customer ID '".$this->getNum()."' not found."); }
         else
         { throw new UnderflowException("Customer email '".$this->getEmail()."' not found. Please add them through the Customer Manager in OTRS."); }
      }
      else
      {
         if ( ValidInt($this->getNum() ) )
         { throw new UnderflowException("More than one matching customer id found for '".$this->getNum()."'."); }
         else
         { throw new UnderflowException("More than one matching customer email found for '".$this->geEmail()."'."); }
      }
   }

   /**
   * Method to determine if a given DB_Customer is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (DB_Customer) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals($input_object)
   {
      if ( parent::equals($input_object) &&
           $this->getNum() == $input_object->getNum() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given DB_Customer matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (DB_Customer) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      if ( parent::matches($input_object) &&
           $this->getNum() == $input_object->getNum() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to convert the object into a string
   *
   * This is primarily used when creating a log entry
   *
   * @return (string) String version of the object.
   */
   public function __toString()
   {
      return 'Serialized data: '.serialize($this);
   }
}
