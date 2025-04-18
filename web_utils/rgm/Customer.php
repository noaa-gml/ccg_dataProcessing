<?PHP

include_once "/var/www/html/inc/validator.php";

/**
* Customer class
*
* A customer represents a recipient of communcation and/or an analysis
*  order.
*/

class Customer
{
   /** Email address */
   private $email;

   /** Title */
   private $title;

   /** First name */
   private $first_name;

   /** Last name */
   private $last_name;

   /** Phone number */
   private $phone;

   /** Fax number */
   private $fax;

   /** Mobile number */
   private $mobile;

   /** Street address */
   private $street;

   /** Zip code */
   private $zip;

   /** City */
   private $city;

   /** Country */
   private $country;

   /**
   * Constructor method for instantiating a Customer object
   *
   * @param $input_email (string) Contact email
   * @param $input_first_name (string) First name
   * @param $input_last_name (string) Fast name
   * @return (Customer) Instantiated object
   */
   public function __construct($input_email, $input_first_name, $input_last_name)
   {
      $this->setEmail($input_email);
      $this->setFirstName($input_first_name);
      $this->setLastName($input_last_name);

      return $this;
   }

   /**
   * Method to set email address
   *
   * @param $input_value (string) Input email address
   * @return void
   */
   protected function setEmail($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9\-\._]+\@[A-Za-z0-9\-\._]+$/', $input_value) )
      { $this->email = $input_value; }
      else
      { throw new Exception ("Provided email '".htmlentities($input_value)."' is not valid."); }
   }

   /**
   * Method to retrieve email address
   *
   * @return (string) Email address or empty string
   */
   public function getEmail()
   {
      if ( isset($this->email) &&
           preg_match('/^[A-Za-z0-9\-\.]+@[A-Za-z0-9\-\.]+$/', $this->email) )
      { return $this->email; }
      else
      { return ''; }
   }

   /**
   * Method to set title
   *
   * Examples: Mr., Ms., and Mrs.
   *
   * @param $input_value (string) Input title
   * @return void
   */
   public function setTitle($input_value)
   {
      $this->title = $input_value;
   }

   /**
   * Method to retrieve title
   *
   * Examples: Mr., Ms., and Mrs
   */
   public function getTitle()
   {
      if ( isset($this->title) )
      { return $this->title; }
      else
      { return ''; }
   }

   /**
   * Method to set first name
   *
   * @param $input_value (string) Input first name
   * @return void
   */
   public function setFirstName($input_value)
   {
      $this->first_name = $input_value;
   }

   /**
   * Method to retrieve first name
   *
   * @return (string) First name or empty string
   */
   public function getFirstName()
   {
      if ( isset($this->first_name) )
      { return $this->first_name; }
      else
      { return ''; }
   }

   /**
   * Method to set last name
   *
   * @param $input_value (string) Input last name
   * @return void
   */
   public function setLastName($input_value)
   {
      $this->last_name = $input_value;
   }

   /**
   * Method to retrieve last name
   *
   * @return (string) Last name or empty string
   */
   public function getLastName()
   {
      if ( isset($this->last_name) )
      { return $this->last_name; }
      else
      { return ''; }
   }

   /**
   * Method to set phone number
   *
   * @param $input_value (string) Input phone number
   * @return void
   */
   public function setPhone($input_value)
   {
      $this->phone = $input_value;
   }

   /**
   * Method to retrieve phone number
   *
   * @return (string) Phone number or empty string
   */
   public function getPhone()
   {
      if ( isset($this->phone) )
      { return $this->phone; }
      else
      { return ''; }
   }

   /**
   * Method to set fax number
   *
   * @param $input_value (string) Input fax number
   * @return void
   */
   public function setFax($input_value)
   {
      $this->fax = $input_value;
   }

   /**
   * Method to retrieve fax number
   *
   * @return (string) Fax number or empty string
   */
   public function getFax()
   {
      if ( isset($this->fax) )
      { return $this->fax; }
      else
      { return ''; }
   }

   /**
   * Method to set mobile phone number
   *
   * @param $input_value (string) Input moblle number
   * @return void
   */
   public function setMobile($input_value)
   {
      $this->mobile = $input_value;
   }

   /**
   * Method to retrieve mobile phone number
   *
   * @return (string) Mobile number or empty string
   */
   public function getMobile()
   {
      if ( isset($this->mobile) )
      { return $this->mobile; }
      else
      { return ''; }
   }

   /**
   * Method to set street address
   *
   * @param $input_value (string) Input street address
   * @return void
   */
   public function setStreet($input_value)
   {
      $this->street = $input_value;
   }

   /**
   * Method to retrieve street address
   *
   * @return (string) Street address or empty string
   */
   public function getStreet()
   {
      if ( isset($this->street) )
      { return $this->street; }
      else
      { return ''; }
   }

   /**
   * Method to set zip code
   *
   * @param $input_value (string) Input zip code
   * @return void
   */
   public function setZip($input_value)
   {
      $this->zip = $input_value;
   }

   /**
   * Method to retrieve zip code
   *
   * @return (string) Zip code or empty string
   */
   public function getZip()
   {
      if ( isset($this->zip) )
      { return $this->zip; }
      else
      { return ''; }
   }

   /**
   * Method to set address city
   *
   * @param $input_value (string) Input address city
   * @return void
   */
   public function setCity($input_value)
   {
      $this->city = $input_value;
   }

   /**
   * Method to retrieve address city
   *
   * @return (string) Address city or empty string
   */
   public function getCity()
   {
      if ( isset($this->city) )
      { return $this->city; }
      else
      { return ''; }
   }

   /**
   * Method to set address country
   *
   * @param $input_value (string) Input address country
   * @return void
   */
   public function setCountry($input_value)
   {
      $this->country = $input_value;
   }

   /**
   * Method to retrieve address country
   *
   * @return (string) Address country or empty string
   */
   public function getCountry()
   {
      if ( isset($this->country) )
      { return $this->country; }
      else
      { return ''; }
   }

   /**
   * Method to retrieve full name
   *
   * @return (string) Full name
   */
   public function getFullName()
   {
      $fullname = '';

      if ( $this->getFirstName() == $this->getLastName() )
      { $fullname = $this->getFirstName(); }
      elseif ( $this->getFirstName() == '' &&
               $this->getLastName() != '' )
      { $fullname = $this->getLastName(); }
      elseif ( $this->getFirstName() != '' &&
               $this->getLastName() == '' )
      { $fullname = $this->getFirstName(); }
      else
      { $fullname = $this->getFirstName().' '.$this->getLastName(); }

      return $fullname;
   }

   /**
   * Method to retrieve full address
   *
   * Address includes name, street, city, zip, and country
   *
   * @return (string) Full address
   */
   public function getAddress()
   {
      $results = array();

      array_push($results, $this->getFullName());
      array_push($results, $this->getStreet());
      array_push($results, $this->getCity().', '.$this->getZip());
      array_push($results, $this->getCountry());

      return(join("\n", $results));
   }

   /**
   * Method to check if a Customer object is exactly the same as this one
   *
   * All details have to be exactly the same for check to be TRUE.
   *
   * @param $input_object (Customer) Input object to compare
   * @return (bool) TRUE -> equal. FALSE -> not equal.
   */
   public function equals($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getEmail() === $input_object->getEmail() &&
           $this->getTitle() === $input_object->getTitle() &&
           $this->getFirstName() === $input_object->getFirstName() &&
           $this->getLastName() === $input_object->getLastName() && 
           $this->getPhone() === $input_object->getPhone() && 
           $this->getFax() === $input_object->getFax() && 
           $this->getMobile() === $input_object->getMobile() && 
           $this->getStreet() === $input_object->getStreet() && 
           $this->getZip() === $input_object->getZip() && 
           $this->getCity() === $input_object->getCity() && 
           $this->getCountry() === $input_object->getCountry() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given Customer object matches to this one
   *
   * They should have the same primary information. Think primary key.
   *
   * @param $input_object (Customer) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getEmail() === $input_object->getEmail() )
      { return true; }
      else
      { return false; }
   }
}
