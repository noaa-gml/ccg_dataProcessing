<?PHP

require_once "/var/www/html/inc/validator.php";

/**
* Cylinder class
*
* A cylinder object is the digital representation af physical
*  cylinder tank. This include information such as cylinder ID,
*  recertification date, cylinder size, and current location.
*/

class Cylinder
{
   /** Identification. (Stamped on cylinder) */
   private $id;

   /** Cylinder recertification date */
   private $recertification_date;

   /** Cylinder type abbreviation */
   private $type_abbr;

   /** Status abberivation */
   private $status_abbr;

   /** Checkin status abbrevation */
   private $checkin_status_abbr;

   /** Cylinder size abbrevation */
   private $size_abbr;

   /** Related Location object */
   private $location_object;

   /** Related location comments */
   private $location_comments;

   /** Date time of location update */
   private $location_datetime;

   /** Cylinder comments */
   private $comments;

   /**
   * Constructor method for instantiating a Cylinder object
   *
   * @param $input_id (string) Input ID
   * @param $input_recertification_date (string) Recertification date in format MM-YY
   * @return (Cylinder) Instantiated object 
   */
   public function __construct($input_id, $input_recertification_date)
   {
      $this->setID($input_id);
      $this->setRecertificationDate($input_recertification_date);

      return $this;
   }

   /**
   * Method to set ID
   *
   * @param $input_value (string) Input ID
   * @return void
   */
   protected function setID($input_value)
   {
      if ( preg_match('/^[A-Za-z0-9\-]+$/', $input_value) &&
           strlen($input_value) > 2 &&
           strlen($input_value) < 25 )
      { $this->id = $input_value; }
      else
      {
         throw new InvalidArgumentException("Provided cylinder ID '".htmlentities($input_value)."' is invalid.");
      }
   }

   /**
   * Method to retrieve ID
   *
   * @return (string) ID or empty string
   */
   public function getID()
   {
      if ( $this->id != '' )
      { return $this->id; }
      else
      { return ''; }
   }

   /**
   * Method to set recertification date
   *
   * There are two ways to call this method:
   *  - Syntax 1: setRecertificationDate($input_value)
   *     - Set the recertification date using $input_value which is
   *       of format MM-YY. For example, January 2014 is '01-14'.
   *  - Syntax 2; setRecertificationDate($input_value, 'date')
   *     - Set the recertification date using $input_value whch is
   *       of format YYYY-MM-DD. For example, January 1st, 2014 is
   *       '2014-01-01'
   *
   * A default value for $input_value is '99-99' or '9999-12-31'
   *
   * @param $input_value (string) Input date of format MM-YY or YYYY-MM-DD
   *  depending on call syntax
   * @param $format (string) Format of $input_value. 'date' or ''.
   * @return void
   */
   public function setRecertificationDate($input_value, $format='')
   {
      if ( $format === 'date' )
      {
         $date_value = $input_value;
      }
      elseif ( $input_value === '99-99' )
      {
         $date_value = '9999-12-31';
      }
      elseif ( preg_match('/^[0-9]{1,2}-[0-9]{2}$/', $input_value) )
      {
         $fields = explode('-', $input_value, 2);

         # If the year is less than 50, then add 2000.
         # Otherwise add 1900
         if ( $fields[1] < 50 )
         { $fields[1] = $fields[1] + 2000; }
         else
         { $fields[1] = $fields[1] + 1900; }

         $date_value = sprintf('%04d-%02d-%02d', $fields[1], $fields[0], 1);
      }
      else
      { $date_value = ''; }

      if ( ValidDate($date_value) )
      {
         $this->recertification_date = $date_value;
      }
      else
      {
         throw new InvalidArgumentException("Provided recertification date is invalid.");
      }
   }

   /**
   * Method to retrieve recertification date
   *
   * There are two ways to call this method:
   *  - Syntax 1: getRecertificationDate()
   *     - Returns the recertification date in format MM-YY
   *  - Syntax 2: getRecertificationDate('date')
   *     - Returns the recertification date in format YYYY-MM-DD
   *
   * @return (string) Recertification date of format MM-YY or YYYY-MM-DD
   *  depending on call syntax
   */
   public function getRecertificationDate($format='')
   {
      if ( ValidDate($this->recertification_date) )
      {
         if ( $format === 'date' )
         { return $this->recertification_date; }
         else
         {
            list($yr, $mo, $dy) = explode('-', $this->recertification_date, 3);

            if ( $yr == '9999' )
            { return '99-99'; }
            else
            { return $mo.'-'.substr($yr, -2, 2); }
         }
      }
      else
      { return ''; }
   }

   /**
   * Method to set type
   *
   * Examples: 'Normal', 'Archive' -> Do not refill
   *
   * @param $input_value (string) Input cylinder type
   * @return void
   */
   public function setType($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9 ]+$/', $input_value) )
      { $this->type_abbr = $input_value; }
      else
      { throw new Exception ("Provided type '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve cylinder type
   *
   * Examples: 'Normal', 'Archive' -> Do not refill
   *
   * @return (string) Cylinder type
   */
   public function getType()
   {
      if ( isset($this->type_abbr) &&
           preg_match('/^[A-Za-z0-9 ]+$/', $this->type_abbr) )
      { return $this->type_abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set cylinder size
   *
   * Examples: '150A', '100A', '80A', '50A' ,'30A'
   *
   * @param $input_value (string) Input cylinder size
   * @return void
   */
   public function setSize($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9 ]+$/', $input_value) )
      { $this->size_abbr = $input_value; }
      else
      { throw new Exception ("Provided size '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve cylinder size
   *
   * Examples: '150A', '100A', '80A', '50A' ,'30A'
   *
   * @return (string) Cylinder size
   */
   public function getSize()
   {
      if ( isset($this->size_abbr) &&
           preg_match('/^[A-Za-z0-9 ]+$/', $this->size_abbr) )
      { return $this->size_abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set cylinder status
   *
   * Examples: 'Ready for filling', 'Ready for order', etc...
   *
   * @param $input_value (string) Input cylinder status
   * @return void
   */
   public function setStatus($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $input_value) )
      { $this->status_abbr = $input_value; }
      else
      { throw new Exception ("Provided status '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve cylinder status
   *
   * Examples: 'Ready for filling', 'Ready for order', etc...
   *
   * @return (string) Cylinder status
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
   * Method to set check in status
   *
   * This is used when a cylinder is checked in. This is used to handle
   *  when a cylinder is checked in and needs to be filled/refilled and
   *  once it is filled/refilled then the next time it is checked in
   *  it may be 'In calibration'
   *
   * @param $input_value (string) Input check in status
   * @return void
   */
   public function setCheckInStatus($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $input_value) )
      { $this->checkin_status_abbr = $input_value; }
      else
      { throw new Exception ("Provided status '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve check in status
   *
   * This is used when a cylinder is checked in. This is used to handle
   *  when a cylinder is checked in and needs to be filled/refilled and
   *  once it is filled/refilled then the next time it is checked in
   *  it may be 'In calibration'
   *
   * @return (string) Check in status
   */
   public function getCheckInStatus()
   {
      if ( isset($this->checkin_status_abbr) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $this->checkin_status_abbr) )
      { return $this->checkin_status_abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set location of cylinder
   * 
   * @param $input_object (Location) Input object.
   * @param $input_comments (string) Input location comments. For example, '2D504'.
   * @param $input_datetime (string) Input date time of when the cylinder was put in
   *   the provided location. String format 'YYYY-MM-DD HH:MM:SS'.
   * @return void
   */
   protected function setLocation($input_object,$input_comments='',$input_datetime='')
   {
      if ( is_a($input_object, 'Location') )
      {
         $this->location_object = $input_object;
         $this->setLocationComments($input_comments);

         if ( $input_datetime != '' )
         { $this->setLocationDatetime($input_datetime); }
         else
         { $this->setLocationDatetime(date("Y-m-d H:i:s")); }
      }
      else
      { throw new Exception ("Provided location must be an object of class DB_Location."); }
   }

   /**
   * Method to retrieve location object
   *
   * @return (Location) Location of cylinder.
   */
   public function getLocation()
   {
      if ( isset($this->location_object) &&
           is_a($this->location_object, 'Location') )
      { return $this->location_object; }
      else
      { return ''; }
   }

   /**
   * Method to set location comments
   *
   * @param $input_value (string) Input location comments
   * @return void
   */
   protected function setLocationComments($input_value)
   {
      $this->location_comments = urlencode($input_value);
   }

   /**
   * Method to retrieve location comments
   *
   * @return (string) Location comments
   */
   public function getLocationComments()
   {
      if ( isset($this->location_comments) &&
           $this->location_comments != '' )
      { return(urldecode($this->location_comments)); }
      else
      { return ''; }
   }

   /**
   * Method to set location date time of when cylinder was put there 
   *
   * @param $input_value (string) Input date time in format 'YYYY-MM-DD HH:MM:SS'
   * @return void
   */
   protected function setLocationDatetime($input_value)
   {
      if ( ValidDatetime($input_value) )
      {
         $this->location_datetime = $input_value;
      }
      else
      {
         throw new InvalidArgumentException("Provided location datetime is invalid.");
      }
   }

   /**
   * Method to retrieve location date time of when cylinder was put there
   *
   * @return (string) Date time of location action in format 'YYYY-MM-DD HH:MM:SS'
   */
   public function getLocationDatetime()
   {
      if ( ValidDatetime($this->location_datetime) )
      { return $this->location_datetime; }
      else
      { return ''; }
   }

   /**
   * Method to set cylinder comments
   *
   * @param $input_value (string) Input cylinder comments
   * @return void
   */
   public function setComments($input_value)
   {
      # str_replace needs to occur as mb_unserialize incorrectly changes
      #  '"' to '\"'
      $this->comments = urlencode(str_replace('\"', '"', $input_value));
   }

   /**
   * Method to retrieve cylinder comments
   *
   * @return (string) Cylinder comments
   */
   public function getComments()
   {
      if ( isset($this->comments) &&
           $this->comments != '' )
      { return(urldecode($this->comments)); }
      else
      { return ''; }
   }

   /**
   * Method to determine if a given Cylinder is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (Cylinder) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals(Cylinder $input_object)
   {
      if ( $this->getID() === $input_object->getID() &&
           $this->getRecertificationDate() === $input_object->getRecertificationDate() &&
           $this->getComments() === $input_object->getComments() &&
           $this->getStatus() === $input_object->getStatus() &&
           $this->getCheckInStatus() === $input_object->getCheckInStatus() &&
           $this->getSize() === $input_object->getSize() && 
           $this->getType() === $input_object->getType() ) 
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given Cylinder matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (Cylinder) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches(Cylinder $input_object)
   {
      if ( strcasecmp($this->getID(), $input_object->getID()) == 0 )
      { return true; }
      else
      { return false; }
   }
}

?>
