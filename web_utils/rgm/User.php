<?PHP

require_once "/var/www/html/inc/validator.php";

/**
*
* User class represents a person that interacts with the software
*
* A user is someone that may interact with the Refgas Manager software.
*
*/

class User
{
   /** User lgoin name */
   private $username;

   /** Email address */
   private $email;

   /** User full name */
   private $name;

   /** Telephone number*/
   private $telephone;

   /**
   * Constructor method for instantiating a User object
   *
   * @param $input_username (string) Username string.
   *
   */
   public function __construct($input_username)
   {
      $this->setUsername($input_username);

      return $this;
   }

   /**
   * Method to set the username
   *
   * This method is protected as it is used in the children.
   * @todo This should be updated to a private function.
   *
   * @param $input_value (string) Username string.
   * @return void
   */
   protected function setUsername($input_value)
   {
      if ( preg_match('/^[A-Za-z0-9\.\-]+$/', $input_value) )
      {
         $this->username = $input_value;
      }
      else
      {
         throw new InvalidArgumentException('Invalid username provided.');
      }
   }

   /**
   * Method to retrieve the username
   *
   * @return (string) Username string.
   */
   public function getUsername()
   {
      if ( $this->username != '' )
      { return $this->username; }
      else
      { return ''; }
   }

   /**
   * Method to set the email
   *
   * This method is protected as it is used in the children.
   *
   * @param $input_value (string) Email string.
   * @return void
   */
   protected function setEmail($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9\-\.]+\@[A-Za-z0-9\-\.]+$/', $input_value) )
      { $this->email = $input_value; }
      else
      { throw new Exception ("Provided email '".htmlentities($input_value)."' is not valid."); }
   }

   /**
   * Method to retrieve the email
   *
   * @return (string) Email string.
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
   * Method to set the name
   *
   * This method is protected as it is used in the children.
   *
   * @param $input_value (string) Email string.
   * @return void
   */
   protected function setName($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9_\.\- ]+$/', $input_value) )
      { $this->name = $input_value; }
      else
      { throw new Exception ("Provided name '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the name
   *
   * @return (string) Name string.
   */
   public function getName()
   {
      if ( isset($this->name) &&
           preg_match('/^[A-Za-z0-9_\.\- ]+$/', $this->name) )
      { return $this->name; }
      else
      { return ''; }
   }

   /**
   * Method to set the phone number
   *
   * This method is protected as it is used in the children.
   *
   * @param $input_value (string) Telephone string.
   * @return void
   */
   protected function setTelephone($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^\([0-9]{3}\) [0-9]{3}\-[0-9]{4}$/', $input_value) )
      { $this->telephone = $input_value; }
      else
      { throw new Exception ("Provided telephone number '".htmlentities($input_value)."' is not valid."); }
   }

   /**
   * Method to retrieve the phone number
   *
   * @return (string) Telephone string.
   */
   public function getTelephone()
   {
      if ( isset($this->telephone) &&
           preg_match('/^\([0-9]{3}\) [0-9]{3}\-[0-9]{4}$/', $this->telephone) )
      { return $this->telephone; }
      else
      { return ''; }
   }
}
