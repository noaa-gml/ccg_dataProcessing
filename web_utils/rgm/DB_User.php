<?PHP

require_once "User.php";

/**
* Database user class that represents a person that interacts with the software
*
* This class extends User class to handle database interactions and relational
* numbers.
*/

class DB_User extends User
{
   /** Relational database number */
   private $num;

   /** Checksum for authentication and validation */
   private $checksum;

   /** Timeout for accepted authentication period */
   private $timeout_datetime;

   /** Related DB object */
   private $database_object;

   /**
   * Constructor method to instantiate a DB_User object
   *
   * There are two ways to call this method.
   *  - Syntax 1: new DB_User($input_database_object, $input_num)
   *     - Instantiates a DB_User based on relational database number.
   *       The related information will be loaded from the database.
   *  - Syntax 2: new DB_User($input_database_object, $input_username, $input_checksum)
   *     - Instantiates a DB_User based on information provided.
   *
   * @param $input_database_object (DB) Database object
   * @param $input_num (int) Relational database number.
   * @param $input_username (string) Username
   * @param $input_checksum (string) Checksum
   * @return (DB_User) Instantiated object
   */
   public function __construct()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 2 )
      {
         $this->setDB($args[0]);
         $this->setNum($args[1]);
         $this->loadFromDB();
      }
      elseif ( $numargs == 3 )
      {
         $this->setDB($args[0]);
         $this->setUsername($args[1]);
         $this->setChecksum($args[2]);
         $this->loadFromDB();
      }
      else
      { throw new BadMethodCallException("Must provide user num or user name and string."); }
   }

   /**
   * Method to set the related DB object
   *
   * @param $input_object (DB) DB object.
   * @return void
   */
   public function setDB($input_object)
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
   * Method to set checksum
   *
   * Checksum is used for user validation
   *
   * @param $input_value (string) Input string
   * @return void
   */
   private function setChecksum($input_value)
   {
      $salt = '$1$NOAAGMDCCGG'.$this->getUsername().'$';
      $this->checksum = crypt($input_value, $salt);
   }

   /**
   * Method to retrieve checksum
   *
   * NOTE: This must be private
   *
   * @return (string) Checksum string
   */
   private function getChecksum()
   {
      if ( $this->checksum != '' )
      { return $this->checksum; }
      else
      { return ''; }
   }

   /**
   * Method to set Date time of Timeout
   *
   * The timeout is used in validation. If the current date & time is past
   * the timeout date & time then we need to re-authenticate
   *
   * @param $input_value (string) Date & time. Format 'YYYY-MM-DD HH:MM:SS'
   * @return void
   */
   private function setTimeoutDatetime($input_value)
   {
      if ( ValidDatetime($input_value) )
      { $this->timeout_datetime = $input_value; }
      else
      { throw new InvalidArgumentException("Provided timeout datetime is invalid."); }
   }

   /**
   * Method to retrieve the Date time of Timeout
   *
   * @return (string) Date & time of timeout. Format 'YYYY-MM-DD HH:MM:SS'
   */
   private function getTimeoutDatetime()
   {
      if ( ValidDatetime($this->timeout_datetime) )
      { return $this->timeout_datetime; }
      else
      { return ''; }
   }

   /**
   * Method to set the relational database number
   *
   * @param $input_value (int) Relational database number
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
   * Method to retrieve the relational database number
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
   * Method to load data from the database
   *
   * Using the primary key relational database number, load the rest of
   *  the information from the database to populate this instance.
   *
   * @return void
   */
   public function loadFromDB()
   {
      $database_object = $this->getDB();

      if ( ValidInt($this->getNum()) )
      {
         $sql = " SELECT t2.num, t2.abbr, t2.name, t2.email, t2.tel FROM user as t1, ccgg.contact as t2 WHERE t1.contact_num = t2.num AND t2.num = ?";
         $sqlargs = array($this->getNum());

         $results = $database_object->queryData($sql, $sqlargs);
      }
      else
      {
         $sql = " SELECT t2.num, t2.abbr, t2.name, t2.email, t2.tel FROM user as t1, ccgg.contact as t2 WHERE t1.contact_num = t2.num AND t2.abbr = ?";
         $sqlargs = array($this->getUsername());

         $results = $database_object->queryData($sql, $sqlargs);
      }

      #print_r($results);

      if ( count($results) == 1 )
      {
         $this->setNum($results[0]['num']);
         $this->setUsername($results[0]['abbr']);
         $this->setName($results[0]['name']);
         $this->setEmail($results[0]['email']);
         $this->setTelephone($results[0]['tel']);
      }
      elseif ( count($results) == 0 )
      {
         # Do not display these errors as they can be used for getting into
         #  the system

         #if ( ValidInt($this->getNum() ) )
         #{ throw new UnderflowException("User ID '".$this->getNum()."' not found."); }
         #else
         #{ throw new UnderflowException("User abbr '".$this->getUsername()."' not found."); }

         # Display general errors
         throw new UnderflowException("Invalid username or password.");
      }
      else
      {
         if ( ValidInt($this->getNum() ) )
         { throw new UnderflowException("More than one matching user id found for '".$this->getNum()."'."); }
         else
         { throw new UnderflowException("More than one matching user abbr found for '".$this->geEmail()."'."); }
      }
   }

   /**
   * Method to determine if a given DB_User is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (DB_User) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal.
   */
   private function equals(DB_User $input_user_obj)
   {
      if ( $this->getUsername() === $input_user_obj->getUsername() &&
           $this->getName() === $input_user_obj->getName() &&
           $this->getChecksum() === $input_user_obj->getChecksum() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given DB_User matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (DB_User  Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match.
   */
   public function matches($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
         $this->getUsername() === $input_object->getUsername() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to validate the user information
   *
   * This method uses the equals() method to validate the user. Validation
   * determines if the user should still have access. Specifically
   * the username, name and checksum are matched. If they are equal then
   * the timeout date & time is used to determine if the user is stall
   * valid.
   *
   * @return (bool) TRUE -> match. FALSE -> not match.
   */
   public function validate()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs != 3 )
      { return false; }

      $input_database_object = $args[0];
      $database_object = $this->getDB();

      $input_username = $args[1];
      $input_string = $args[2];

      $input_user_obj = new DB_User($input_database_object, $input_username, $input_string);

      $timediff = strtotime($this->getTimeoutDatetime()) - time();

      # Make sure that the timeout is in the future

      if ( $this->equals($input_user_obj) &&
           $input_database_object->matches($database_object) &&
           $timediff > 0 )
      {
         # If the timeout is within 5 minutes but the user is actively
         #  using the interface then push back the timeout date
         if ( $timediff < 300 )
         { $this->setTimeoutDatetime(date("Y-m-d H:i:s", strtotime("+5 minutes"))); }

         return true;
      }
      else
      {
         $this->setChecksum(crypt(date("Y-m-d H:i:s"), '~gs5]~}3[d|lXmuE[3'));
         return false;
      }
   }

   /**
   * Method to authenicate the user based on password
   *
   * This method takes $input_pw and checks if user should be authenticated.
   *
   * @param $input_pw (string) Input string
   * @return (bool) TRUE -> match. FALSE -> not match.
   */
   private function authenticatePassword($input_pw,$mellon_uid='')
   {
      # Method 1 authentication
      $sql = " SELECT t1.abbr FROM ccgg.contact as t1, refgas_orders.user as t2 WHERE pw = ? AND t1.num = t2.contact_num";
      $sqlargs = array(crypt($input_pw, '$1$ESRL-GMD-CCGG$'));
      
#var_dump($sqlargs);var_dump($sql);
	#We used to do ldap auth if user doesn't have a local pass set, but have moved to saml auth_mellon.  If user has already been authenticated,
      #their userID is in mellon_uid (set in login.php) in which case we just need to make sure they are in the contact and user tables.
      if($mellon_uid){
         $sql="select t1.abbr from ccgg.contact t1, user t2 where t1.num=t2.contact_num and t1.abbr=?";
         #actually, I think I'm going to loosen to just contact.  Below ldap basically just auth'd the user against whole noaa.  Later logic checks for ccgg.contact
         $sql="select t1.abbr from ccgg.contact t1 where t1.abbr=?";
         $sqlargs=array($mellon_uid);
      }

      $database_object = $this->getDB();

      $results = $database_object->queryData($sql, $sqlargs);
      foreach ( $results as $arr )
      {
         if ( $arr['abbr'] === $this->getUsername() )
         {
            return(TRUE);
         }
      }


      #No longer used.
      #Jörg
      # Please see the comments section of
      #   http://php.net/manual/en/function.ldap-search.php
      # Specifically the comment by kandsobrien at gmail dot com
      #

      # .htaccess file
      #------------------------------------
      # AuthType Basic
      # AuthBasicProvider ldap
      # AuthzLDAPAuthoritative Off
      # AuthName "NEMS Test"
      # AuthLDAPURL "ldaps://ldap-mountain.nems.noaa.gov/ou=people,o=noaa.gov?uid?sub?(objectClass=*)"

      # require valid-user
      #------------------------------------
      /*
      $ldapconfig['host'] = 'ldaps://ldap-mountain.nems.noaa.gov';
      $ldapconfig['basedn'] = 'ou=people,o=noaa.gov';

      $ds=@ldap_connect($ldapconfig['host']);

      $r = @ldap_search( $ds, $ldapconfig['basedn'], 'uid=' . $this->getUsername());
      if ($r)
      {
         $result = @ldap_get_entries( $ds, $r);
         if (isset($result[0]))
         {
            if (@ldap_bind( $ds, $result[0]['dn'], $input_pw) )
            {
               return(TRUE);
            }
         }
      }
      @ldap_unbind($ds);
      */
      return(FALSE);
   }

   /**
   * Method to authenicate the user
   *
   * This method takes $input_pw and checks if user should be authenicated.
   * This exists to also implement the 'Remember me' functionality. If
   * the user authenicatios successfully then the default is 10 minutes
   * of allowed access. It 'Remember me' is TRUE then 2 weeks of access
   * is granted.
   *
   * @param $input_pw (string) Input string
   * @param $input_remember_me (bool) Flag for 'Remember me' functionality
   * @return (bool) TRUE -> match. FALSE -> not match.
   */
   public function authenticate($input_pw, $input_remember_me=false,$mellon_uid='')
   {
      if ( $this->authenticatePassword($input_pw,$mellon_uid) == TRUE )
      {
         $this->setChecksum($this->getUsername().'+'.$_SERVER['HTTP_USER_AGENT']);
         if ( $input_remember_me )
         { $this->setTimeoutDatetime(date("Y-m-d H:i:s", strtotime("+2 weeks"))); }
         else
         { $this->setTimeoutDatetime(date("Y-m-d H:i:s", strtotime("+10 minutes"))); }

         return (TRUE);
      }

      return(FALSE);
   }

   /**
   * Method to update the password of the user
   *
   * Takes current password and two times of the new password. THis checks
   * for minimum security requirements, that the current password is authentic,
   * and that the two new passwords match.
   *
   * @param $input_curpwd (string) Current password
   * @param $input_newpwd1 (string) New password
   * @param $input_newpwd2 (string) New password, try #2
   * @return void
   */
   public function updatePassword($input_curpwd, $input_newpwd1, $input_newpwd2)
   {
      if ( $input_newpwd1 !== $input_newpwd2 )
      { throw new InvalidArgumentException("New passwords do not match."); }

      if ( strlen($input_newpwd1) < 12 ||
           strlen(preg_replace('{(.)\1+}','$1',$input_newpwd1)) < 5 ||
           count(array_values(array_unique(str_split($input_newpwd1)))) < 5 )
      { throw new InvalidArgumentException("New password does not meet password criteria. Password must be at least 12 characters in length and at least 5 different non-repeating characters."); }

      if ( $this->authenticatePassword($input_curpwd) )
      {
         $database_object = $this->getDB();

         $sql = " UPDATE user SET pw = ? WHERE contact_num = ? LIMIT 1";
         $sqlargs = array(crypt($input_newpwd1, '$1$ESRL-GMD-CCGG$'), $this->getNum());

         #print $sql."<BR>\n";
         #print join("|", $sqlargs)."<BR>\n";

         $database_object->executeSQL($sql, $sqlargs);
      }
      else
      { throw new InvalidArgumentException("Current password not valid."); }
   }

   /**
   * Method to retrieve user preferences
   *
   * @return array
   */
   public function getPreferences()
   {
      $database_object = $this->getDB();

      $sql = " SELECT value FROM user_preferences WHERE contact_num = ?";
      $sqlargs = array($this->getNum());

      #print $sql."<BR>\n";
      #print join("|", $sqlargs)."<BR>\n";

      $results = $database_object->queryData($sql, $sqlargs);

      if ( isset($results[0]) )
      {
         return unserialize(urldecode($results[0]['value']));
      }

      return array();
   }
}
