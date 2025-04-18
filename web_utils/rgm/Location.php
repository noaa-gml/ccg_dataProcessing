<?PHP

/**
* Location class
*
* A location represents a physical place that a cylinder may be.
*/

class Location 
{
   /** Name */
   private $name;

   /** Abbrevation */
   private $abbreviation;

   /** Address */
   private $address;

   /** Comments */
   private $comments;

   /** Active status. 1 -> active. 0-> inactive */
   private $active_status;

   /**
   * Constructor method to instantiate a Location object
   *
   * Syntax: new Location($input_name, $input_abbreviation, $input_address)
   *   - Instantiate a Location using the provided name, abbreviation and
   *     address.
   *
   * @param $input_name (string) Name
   * @param $input_abbreviation (string) Abbreviation.
   * @param $input_address (string) Address.
   * @return (Location) Instantiated object.
   */
   public function __construct($input_name, $input_abbreviation, $input_address)
   {
      $this->setName($input_name);
      $this->setAbbreviation($input_abbreviation);
      $this->setAddress($input_address);
      $this->setActiveStatus('1');
   }

   /**
   * Method to set name
   *
   * @param $input_value (string) Name.
   * @return void
   */
   public function setName($input_value)
   {
      if ( ! preg_match('/[\n\r]/', $input_value)
           && strlen($input_value) < 256 )
      { $this->name = $input_value; }
      else
      {
         throw new InvalidArgumentException("Provided name is invalid.");
      }
   }

   /**
   * Method to retrieve name
   *
   * @return (string) Name or empty string ('').
   */
   public function getName()
   {
      if ( $this->name != '' )
      { return $this->name; }
      else
      { return ''; }
   }

   /**
   * Method to set abbreviation
   *
   * @param $input_value (string) Abbreviation.
   * @return void
   */
   public function setAbbreviation($input_value)
   {
      if ( preg_match('/^[A-Za-z0-9 \.\-_\/\\\]+$/', $input_value)
           && strlen($input_value) < 50 )
      { $this->abbreviation = $input_value; }
      else
      {
         throw new InvalidArgumentException("Provided abbreviation is invalid.");
      }
   }

   /**
   * Method to retrieve abbreviation
   *
   * @return (string) Abbreviation or empty string ('').
   */
   public function getAbbreviation()
   {
      if ( $this->abbreviation != '' )
      { return $this->abbreviation; }
      else
      { return ''; }
   }

   /**
   * Method to set active status
   *
   * '1' -> active location
   * '0' -> inactive location
   *
   * If a location is active, cylinders may be checked in/shipped there
   *
   * @param $input_value (int) Active status.
   * @return void
   */
   public function setActiveStatus($input_value)
   {
      if ( $input_value == '1' )
      { $this->active_status = '1'; }
      else
      { $this->active_status = '0'; }
   }

   /**
   * Method to retrieve active status
   *
   * '1' -> active location
   * '0' -> inactive location
   *
   * If a location is active, cylinders may be checked in/shipped there
   *
   * @return (string) Active status or empty string ('').
   */
   public function getActiveStatus()
   {
      if ( $this->active_status == '1' )
      { return '1'; }
      else
      { return '0'; }
   }

   /**
   * Method to set address
   *
   * @param $input_value (string) Address.
   * @return void
   */
   public function setAddress($input_value)
   {
      if ( strlen($input_value) > 0 )
      { $this->address = urlencode($input_value); }
      else
      { throw new LengthException("Address must be provided."); }
   }

   /**
   * Method to retrieve Address
   *
   * @return (string) Address or empty string ('').
   */
   public function getAddress()
   {
      if ( $this->address != '' )
      { return urldecode($this->address); }
      else
      { return ''; }
   }

   /**
   * Method to set comments
   *
   * @param $input_value (string) Comments.
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
   * @return (string) Comments or empty string ('').
   */
   public function getComments()
   {
      if ( $this->comments != '' )
      { return urldecode($this->comments); }
      else
      { return ''; }
   }

   /**
   * Method to determine if a given Location is equal to this one
   *
   * They should be exactly the same in all data.
   *
   * @param $input_object (Location) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals(Location $input_object)
   {
      if ( $this->getName() === $input_object->getName() &&
           $this->getAbbreviation() === $input_object->getAbbreviation() &&
           $this->getActiveStatus() === $input_object->getActiveStatus() &&
           $this->getAddress() === $input_object->getAddress() && 
           $this->getComments() === $input_object->getComments() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given Location matches to this one
   *
   * They should have the same primary information. Think primary key.
   *
   * @param $input_object (Location) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches(Location $input_object)
   {

      if ( strcasecmp($this->getName(),$input_object->getName()) == 0 &&
           strcasecmp($this->getAbbreviation(),$input_object->getAbbreviation()) == 0 &&
           strcasecmp($this->getAddress(),$input_object->getAddress()) == 0 )
      { return true; }
      else
      { return false; }
   }
}

?>
