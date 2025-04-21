<?PHP

require_once "Cylinder.php";
require_once "DB_Location.php";
require_once "DB_ProductManager.php";
require_once "DB_CalRequestManager.php";
require_once "DB_LocationManager.php";
require_once "Log.php";
require_once "DB_User.php";

/**
* Database cylinder class
*
* This class extends Cylinder to handle database interactions and
*  relational numbers. Also, this handles when a cylinder is filled.
*  And lastly, the user information when a cylinder location is
*  updated.
*/

class DB_Cylinder extends Cylinder
{
   /** Relational database number */
   private $num;

   /** Cylinder type relational database number */
   private $type_num;

   /** Status relational database number. Related to database table 'cylinder_status' */
   private $status_num;

   /** Check in status relational database number. Related to database table 'cylinder_status' */
   private $checkin_status_num;

   /** Associative array of information for filling */
   private $fill_info_aarr;

   /** Cylinder size relational database number */
   private $size_num;

   /** DB_User object of last location action*/
   private $location_action_user_object;

   /**
   * Constructor method for instantiating a DB_Cylinder object
   *
   * There are three ways to call this method
   *  - Syntax 1: new DB_Cylinder($input_database_object, $input_value)
   *     - Instantiates a DB_Cylinder using $input_value. First, trying
   *       to evaluate $input_value as a relational database number.
   *       If unsuccessful, then trying to evaluate $input_value as
   *       a cylinder ID string.
   *  - Syntax 2: new DB_Cylinder($input_database_object, $input_value, $input_value_type)
   *     - Instantiates a DB_Cylinder using $input_value_type to
   *       evaluate $input_value. If $input_value_type is 'num' then
   *       evaluate $input_value as a relational database number.
   *       If $input_value_type is 'id' then evaluate $input_value
   *       as a cylinder ID string.
   *  - Syntax 3: new DB_Cylinder($input_database_object, $input_value, $input_recertification_date)
   *     - Instantiates a DB_Cylinder using $input_value as a
   *       cylinder id and $input_recertification_date.
   *
   * @param $input_database_object (DB) Database object.
   * @param $input_value (int|string) Input value of relational database
   *   number or cylinder id string.
   * @param $input_value_type (string) Type of $input_value. 'num' or 'id'
   * @param $input_recertification_date (string) Recertification date.
   *   Format 'MM-YY'.
   * @return (DB_Cylinder) Instantiated object
   */
   public function __construct()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 2)
      {
         try
         {
            $instance = parent::__construct('XXX', '99-99');
            $instance->setDB($args[0]);
            $instance->setNum($args[1]);
            $instance->loadDataFromDB();
            return $instance;
         }
         catch (Exception $e)
         {
            try
            {
               $instance = parent::__construct('XXX', '99-99');
               $instance->setDB($args[0]);
               $instance->setID($args[1]);
               $instance->loadDataFromDB();
               return $instance;
            }
            catch (Exception $e)
            { throw $e; }
         }
      }
      if ( $numargs == 3 )
      {
         if ( $args[2] == 'num' )
         {
            $instance = parent::__construct('XXX', '99-99');
            $instance->setDB($args[0]);
            $instance->setNum($args[1]);
            $instance->loadDataFromDB();
            return $instance;
         }
         elseif ( $args[2] == 'id' )
         {
            $instance = parent::__construct('XXX', '99-99');
            $instance->setDB($args[0]);
            $instance->setID($args[1]);
            $instance->loadDataFromDB();
            return $instance;
         }
         elseif ( preg_match('/[0-9]{2}\-[0-9]{2}/', $args[2]) )
         {
            $instance = parent::__construct($args[1], $args[2]);

            $instance->setDB($args[0]);

            # Default type
            $instance->setType('1');

            # Default status
            $instance->setStatus('2');

            # Default checkin status
            $instance->setCheckInStatus('2');

            # Default size
            $instance->setSize('8');

            # Default location to NOAA
            $locationobj = new DB_Location($args[0], '1');
            $instance->setLocation($locationobj);

            return $instance;
         }
         else
         {
            throw new InvalidArgumentException("Invalid recertification date or type provided.");
         }
      }
      else
      {
         throw new BadMethodCallException("Must be called with num, id, or id and recertification date.");
      }

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
   * Method to update ID
   *
   * This is an interface for setID that checks to make sure the input ID
   *  does not already exist.
   *
   * @param $input_value (string) Input ID.
   * @return void
   */
   public function updateID($input_value)
   {
      $database_object = $this->getDB();

      try
      {
         $cylinder_obj = new DB_Cylinder($database_object, $input_value, 'id');
      }
      catch (Exception $e)
      {
         # Do nothing, as we hope that it fails
      }

      # If we were able to instantiate a cylinder object based on the
      #  input value and the cylinder object does not match this then
      #  it already exists in the database
      if ( isset($cylinder_obj) &&
           get_class($cylinder_obj) === 'DB_Cylinder' &&
           ! $this->matches($cylinder_obj) )
      {
         throw new InvalidArgumentException("Cylinder ID '$input_value' already exists.");
      }

      $this->setID($input_value);
   }

   /**
   * Method to set the relational database number
   *
   * @param $input_value (int) Input number
   * @return void
   */
   private function setNum($input_value)
   {
      if ( ValidInt($input_value) )
      { $this->num = $input_value; }
      elseif ( isBlank($input_value) )
      { $this->num = ''; }
      else
      { throw new InvalidArgumentException("Provided cylnider num is invalid."); }
   }

   /**
   * Method to retrieve relational database number
   *
   * @return (int|string) Relational database number or empty string.
   */
   public function getNum()
   {
      if ( $this->num != '' )
      { return $this->num; }
      else
      { return ''; }
   }

   /**
   * Method to set cylinder type
   *
   * There are two ways to call this method:
   *  - Syntax 1: setType($input_value)
   *     - Set the cylinder type using $input_value. If $input_value
   *       is an interger then evaluate it as a relational database
   *       number. Otherwise, try to evaluate it as an abbreviation. 
   *  - Syntax 2: setType($input_value, $input_value_type)
   *     - Set the cylinder type using $input_value_type to evaluate
   *       $input_value. If $input_value_type is 'num' then evaluate
   *       $input_value as a relational database number. If
   *       $input_value_type is 'abbr' then evaluate $input_value
   *       as an abbrevation.
   *
   * @param $input_value (int|string) Input relational number or
   *   abbreviation.
   * @param $input_value_type (string) Type of $input_value. 'num'
   *   or 'abbr'. 
   * @return void
   */
   public function setType()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      $database_object = $this->getDB();

      if ( $numargs == 1 )
      {
         $input_value = $args[0];
         if ( ValidInt($args[0]) )
         { $input_type = 'num'; }
         else
         { $input_type = 'abbr'; }
      }
      elseif ( $numargs == 2 )
      {
         $input_value = $args[0];
         $input_type = $args[1];
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }

      if ( $input_type === 'num' )
      {
         $sql = " SELECT num, abbr FROM cylinder_type WHERE num = ?";
         $sqlargs = array($args[0]);

         $results = $database_object->queryData($sql, $sqlargs);

         if ( count($results) == 1 )
         {
            $this->type_num = $results[0]['num'];
            parent::setType($results[0]['abbr']);
         }
         elseif ( count($results) == 0 )
         { throw new UnderflowException("Cylinder type number '".$args[0]."' not found."); }
         else
         { throw new UnderflowException("More than one matching cylinder type number found for '".$args[0]."'."); }
      }
      elseif ( $input_type === 'abbr' )
      {
         $sql = " SELECT num, abbr FROM cylinder_type WHERE abbr = ?";
         $sqlargs = array($args[0]);

         $results = $database_object->queryData($sql, $sqlargs);

         if ( count($results) == 1 )
         {
            $this->type_num = $results[0]['num'];
            parent::setType($results[0]['abbr']);
         }
         elseif ( count($results) == 0 )
         { throw new UnderflowException("Cylinder type '".$args[0]."' not found."); }
         else
         { throw new UnderflowException("More than one matching cylinder type found for '".$args[0]."'."); }
      }
      else
      { throw new InvalidArgumentException("Invalid type provided."); }
   }

   /**
   * Method to retrieve cylinder type
   *
   * There are two ways to call this method:
   *  - Syntax 1: getType()
   *     - Retrieve the cylinder type abbreviation.
   *  - Syntax 2: getType($input_type)
   *     - Retrieve the cylinder type based on $input_type. If
   *       $input_type is 'num' then retrieve the relational
   *       database number. If $input_type is 'abbr' then
   *       retrieve the abbreviation.
   *
   * @return (int|string) Relational database number or abbreviation.
   */
   public function getType()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      {
         return parent::getType();
      }
      elseif ( $numargs === 1 )
      {
         if ( $args[0] === 'num' )
         {
            if ( isset($this->type_num) &&
                 ValidInt($this->type_num) ) 
            { return $this->type_num; } 
            else
            { return ''; }
         }
         elseif ( $args[0] === 'abbr' )
         {
            return parent::getType();
         }
         else
         {
            throw new InvalidArgumentException("Invalid type requested.");
         }
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }
   }

   /**
   * Method to set cylinder status
   *
   * There are two ways to call this method:
   *  - Syntax 1: setStatus($input_value)
   *     - Set the cylinder status using $input_value. If $input_value
   *       is an interger then evaluate it as a relational database
   *       number. Otherwise, try to evaluate it as an abbreviation. 
   *  - Syntax 2: setStatus($input_value, $input_value_type)
   *     - Set the cylinder status using $input_value_type to evaluate
   *       $input_value. If $input_value_type is 'num' then evaluate
   *       $input_value as a relational database number. If
   *       $input_value_type is 'abbr' then evaluate $input_value
   *       as an abbrevation.
   *
   * @todo This should be made protected.
   * @param $input_value (int|string) Input relational number or
   *   abbreviation.
   * @param $input_value_type (string) Status of $input_value. 'num'
   *   or 'abbr'. 
   * @return void
   */
   public function setStatus()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      $database_object = $this->getDB();

      if ( $numargs == 1 )
      {
         $input_value = $args[0];
         if ( ValidInt($args[0]) )
         { $input_type = 'num'; }
         else
         { $input_type = 'abbr'; }
      }
      elseif ( $numargs == 2 )
      {
         $input_value = $args[0];
         $input_type = $args[1];
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }

      $prev_status_num = $this->getStatus('num');
      $prev_status_abbr = $this->getStatus('abbr');

      if ( $input_type === 'num' )
      {
         if ( $prev_status_num != $input_value ) 
         {
            $sql = " SELECT num, abbr FROM cylinder_status WHERE num = ?";
            $sqlargs = array($input_value);

            $results = $database_object->queryData($sql, $sqlargs);

            if ( count($results) == 1 )
            {
               $this->status_num = $results[0]['num'];
               parent::setStatus($results[0]['abbr']);
            }
            elseif ( count($results) == 0 )
            { throw new UnderflowException("Status number '".$input_value."' not found."); }
            else
            { throw new UnderflowException("More than one matching status number found for '".$input_value."'."); }
         }
      }
      elseif ( $input_type === 'abbr' )
      {
         if ( $prev_status_abbr != $input_value )
         {
            $sql = " SELECT num, abbr FROM cylinder_status WHERE abbr = ?";
            $sqlargs = array($input_value);

            $results = $database_object->queryData($sql, $sqlargs);

            if ( count($results) == 1 )
            {
               $this->status_num = $results[0]['num'];
               parent::setStatus($results[0]['abbr']);
            }
            elseif ( count($results) == 0 )
            { throw new UnderflowException("Status abbreviation '".$input_value."' not found."); }
            else
            { throw new UnderflowException("More than one matching status abbreviation found for '".$input_value."'."); }
         }
      }
      else
      { throw new InvalidArgumentException("Invalid type provided."); }

      # Handle checkin status when a cylinder is to be retired or comes back
      #  from being retired
      if ( $prev_status_num == '6' &&
           $this->getStatus('num') != '6' )
      {
         $this->setCheckInStatus('2', 'num');
      }
      elseif ( $this->getStatus('num') == '6' )
      {
         $this->setCheckInStatus('6', 'num');
      }
   }

   /**
   * Method to retrieve cylinder status
   *
   * There are two ways to call this method:
   *  - Syntax 1: getStatus()
   *     - Retrieve the cylinder status abbreviation.
   *  - Syntax 2: getStatus($input_type)
   *     - Retrieve the cylinder status based on $input_type. If
   *       $input_type is 'num' then retrieve the relational
   *       database number. If $input_type is 'abbr' then
   *       retrieve the abbreviation.
   *
   * @return (int|string) Relational database number or abbreviation.
   */
   public function getStatus()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      {
         return parent::getStatus();
      }
      elseif ( $numargs === 1 )
      {
         if ( $args[0] === 'num' )
         {
            if ( isset($this->status_num) &&
                 ValidInt($this->status_num) )
            { return $this->status_num; }
            else
            { return ''; }
         }
         elseif ( $args[0] === 'abbr' )
         {
            return parent::getStatus();
         }
         else
         {
            throw new InvalidArgumentException("Invalid type requested.");
         }
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }
   }

   /**
   * Method to set cylinder size
   *
   * There are two ways to call this method:
   *  - Syntax 1: setSize($input_value)
   *     - Set the cylinder size using $input_value. If $input_value
   *       is an interger then evaluate it as a relational database
   *       number. Otherwise, try to evaluate it as an abbreviation. 
   *  - Syntax 2: setSize($input_value, $input_value_type)
   *     - Set the cylinder size using $input_value_type to evaluate
   *       $input_value. If $input_value_type is 'num' then evaluate
   *       $input_value as a relational database number. If
   *       $input_value_type is 'abbr' then evaluate $input_value
   *       as an abbrevation.
   *
   * @param $input_value (int|string) Input relational number or
   *   abbreviation.
   * @param $input_value_type (string) Size of $input_value. 'num'
   *   or 'abbr'. 
   * @return void
   */
   public function setSize()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      $database_object = $this->getDB();

      if ( $numargs == 1 )
      {
         $input_value = $args[0];
         if ( ValidInt($args[0]) )
         { $input_type = 'num'; }
         else
         { $input_type = 'abbr'; }
      }
      elseif ( $numargs == 2 )
      {
         $input_value = $args[0];
         $input_type = $args[1];
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }

      if ( $input_type === 'num' )
      {
         $sql = " SELECT num, abbr FROM cylinder_size WHERE num = ?";
         $sqlargs = array($args[0]);

         $results = $database_object->queryData($sql, $sqlargs);

         if ( count($results) == 1 )
         {
            $this->size_num = $results[0]['num'];
            parent::setSize($results[0]['abbr']);
         }
         elseif ( count($results) == 0 )
         { throw new UnderflowException("Cylinder size number '".$args[0]."' not found."); }
         else
         { throw new UnderflowException("More than one matching cylinder size number found for '".$args[0]."'."); }
      }
      elseif ( $input_type === 'abbr' )
      {
         $sql = " SELECT num, abbr FROM cylinder_size WHERE abbr = ?";
         $sqlargs = array($args[0]);

         $results = $database_object->queryData($sql, $sqlargs);

         if ( count($results) == 1 )
         {
            $this->size_num = $results[0]['num'];
            parent::setSize($results[0]['abbr']);
         }
         elseif ( count($results) == 0 )
         { throw new UnderflowException("Cylinder size '".$args[0]."' not found."); }
         else
         { throw new UnderflowException("More than one matching cylinder size found for '".$args[0]."'."); }
      }
      else
      { throw new InvalidArgumentException("Invalid type provided."); }
   }

   /**
   * Method to retrieve cylinder size
   *
   * There are two ways to call this method:
   *  - Syntax 1: getSize()
   *     - Retrieve the cylinder size abbreviation.
   *  - Syntax 2: getSize($input_type)
   *     - Retrieve the cylinder size based on $input_type. If
   *       $input_type is 'num' then retrieve the relational
   *       database number. If $input_type is 'abbr' then
   *       retrieve the abbreviation.
   *
   * @return (int|string) Relational database number or abbreviation.
   */
   public function getSize()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      {
         return parent::getSize();
      }
      elseif ( $numargs === 1 )
      {
         if ( $args[0] === 'num' )
         {
            if ( isset($this->size_num) &&
                 ValidInt($this->size_num) )
            { return $this->size_num; }
            else
            { return ''; }
         }
         elseif ( $args[0] === 'abbr' )
         {
            return parent::getSize();
         }
         else
         {
            throw new InvalidArgumentException("Invalid type requested.");
         }
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }
   }

   /**
   * Method to set location of cylinder
   *
   * @param $input_object (DB_Location) Input object.
   * @param $input_comments (string) Input location comments. For example, '2D504'.
   * @param $input_datetime (string) Input date time of when the cylinder was put in
   *   the provided location. String format 'YYYY-MM-DD HH:MM:SS'.
   * @return void
   */
   protected function setLocation($input_object,$input_comments='',$input_datetime='')
   {
      if ( get_class($input_object) == 'DB_Location' )
      {
         parent::setLocation($input_object, $input_comments, $input_datetime);
      }
      else
      { throw new Exception ("Provided location must be an object of or subclass of class Location."); }
   }

   /**
   * Method to set location comments
   *
   * This also checks that location comments for NOAA DSRC 
   *  is a room location. For example, 2D504
   *
   * @param $input_value (string) Input location comments
   * @return void
   */
   protected function setLocationComments($input_value)
   {
      # If we are at location number 1 and a location_comment is provided
      #  then it should begin with something like 2D504
      if ( $this->getLocation()->getNum() === '1' )
      {
         if ( $input_value === '' ||
              strtolower($input_value) === 'south loading dock' ||
              preg_match('/^([0-9]|G)[A-Za-z][0-9]{3}/', $input_value) )
         {
            parent::setLocationComments($input_value);
         }
         else
         {
            throw new BadMethodCallException("Location comments must be a room number (e.g., 2D504) when cheking in a cylinder.");
         }
      }
      else
      {
         parent::setLocationComments($input_value);
      }
   }

   /**
   * Method to set location action user
   *
   * Location action user is the user that changed th. cylinder location.
   *
   * @param $input_object (DB_user) Input object.
   * @return void
   */
   private function setLocationActionUser($input_object)
   {
      if ( get_class($input_object) === 'DB_User' )
      { $this->location_action_user_object = $input_object; }
      else
      { throw new Exception ("Provided user must be an object of class DB_User."); }
   }

   /**
   * Method to retrieve location action user
   *
   * Location action user is the user that changed the cylinder location
   *
   * @return (DB_User) Location action user.
   */
   public function getLocationActionUser()
   {
      if ( isset($this->location_action_user_object) &&
           get_class($this->location_action_user_object) === 'DB_User' )
      { return $this->location_action_user_object; }
      else
      { return ''; }
   }

   /**
   * Method to set cylinder check in status
   *
   * There are two ways to call this method:
   *  - Syntax 1: setCheckInStatus($input_value)
   *     - Set the cylinder check in status using $input_value. If
   *       $input_value is an interger then evaluate it as a
   *       relational database number. Otherwise, try to evaluate
   *       it as an abbreviation. 
   *  - Syntax 2: setCheckInStatus($input_value, $input_value_type)
   *     - Set the cylinder check in status using $input_value_type
   *       to evaluate $input_value. If $input_value_type is 'num'
   *       then evaluate $input_value as a relational database
   *       number. If $input_value_type is 'abbr' then evaluate
   *       $input_value as an abbrevation.
   *
   * @param $input_value (int|string) Input relational number or
   *   abbreviation.
   * @param $input_value_type (string) Type of $input_value. 'num'
   *   or 'abbr'. 
   * @return void
   */
   public function setCheckInStatus()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      $database_object = $this->getDB();

      if ( $numargs == 1 )
      {
         $input_value = $args[0];
         if ( ValidInt($args[0]) )
         { $input_type = 'num'; }
         else
         { $input_type = 'abbr'; }
      }
      elseif ( $numargs == 2 )
      {
         $input_value = $args[0];
         $input_type = $args[1];
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }
      if ( $input_type === 'num' )
      {
         $sql = " SELECT num, abbr FROM cylinder_status WHERE num = ?";
         $sqlargs = array($args[0]);
      }
      else
      {
         $sql = " SELECT num, abbr FROM cylinder_status WHERE abbr = ?";
         $sqlargs = array($args[0]);
      }

      $results = $database_object->queryData($sql, $sqlargs);

      if ( count($results) == 1 )
      {
         // Throw an error if we are trying to fill an archive cylinder 
         if ( $results[0]['num'] == '1' &&
              ! $this->isFillable() )
         {
            throw new Exception("Unable to assign cylinder '".$this->getID()."' to be filled or refilled as it is an ".$this->getType()." cylinder.");
         }
         else
         {
            $this->checkin_status_num = $results[0]['num'];
            parent::setCheckInStatus($results[0]['abbr']);

            # If the cylinder is 'ready for order' or 'in progress'
            # (i.e., it is located at NOAA DSRC or Building 22)
            # then set the status to the checkin status
            # This is specifically to handle the case of a cylinder
            # that is at NOAA DSRC or Building 22 that needs to be
            # refilled
            if ( $this->getStatus('num') == '2' ||
                 $this->getStatus('num') == '3' )
            { $this->setStatus($results[0]['num'], 'num'); }
         }
      }
      elseif ( count($results) == 0 )
      {
         if ( $type === 'num' )
         { throw new UnderflowException("Status number '".$args[0]."' not found."); }
         else
         { throw new UnderflowException("Status abbreviation '".$args[0]."' not found."); }
      }
      else
      {
         if ( $type === 'num' )
         { throw new UnderflowException("More than one matching status number found for '".$args[0]."'."); }
         else
         { throw new UnderflowException("More than one matching status abbreviation found for '".$args[0]."'."); }
      }
   }

   /**
   * Method to retrieve cylinder checkin in status
   *
   * There are two ways to call this method:
   *  - Syntax 1: getCheckInStatus()
   *     - Retrieve the cylinder size abbreviation.
   *  - Syntax 2: getCheckinStatus($input_type)
   *     - Retrieve the cylinder check in status based on
   *       $input_type. If $input_type is 'num' then
   *       retrieve the relational database number. If
   *       $input_type is 'abbr' then retrieve the
   *       abbreviation.
   *
   * @return (int|string) Relational database number or abbreviation.
   */
   public function getCheckInStatus()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      {
         return parent::getCheckInStatus();
      }
      elseif ( $numargs === 1 )
      {
         if ( $args[0] === 'num' )
         {
            if ( isset($this->checkin_status_num) &&
                 ValidInt($this->checkin_status_num) )
            { return $this->checkin_status_num; }
            else
            { return ''; }
         }
         elseif ( $args[0] === 'abbr' )
         {
            return parent::getCheckInStatus();
         }
         else
         {
            throw new InvalidArgumentException("Invalid type requested.");
         }
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }
   }

   /**
   * Method to retrieve last fill code from database
   *
   * @return (string) Last fill code or empty string
   */
   public function getLastFillCodeFromDB()
   {
      try
      {
         $database_object = $this->getDB();

         # Find the most recent fill code
         $sql = " SELECT code FROM reftank.fill WHERE serial_number = ? ORDER BY code DESC LIMIT 1";
         $sqlargs = array ( $this->getID() );

         $results = $database_object->queryData($sql, $sqlargs);

         if ( isset($results[0]) )
         { return $results[0]['code']; }
         else
         { return ''; }
      }
      catch ( Exception $e )
      { throw new Exception ("Error determining last fill code."); }
   }

   /**
   * Method to retrieve next file code based on database
   *
   * Determines the next fill code based on entries in the database.
   *
   * @return (string) Next fill code.
   */
   private function getNextFillCodeFromDB()
   {
      $fill_code_arr = array ( 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z' );

      $prev_fill_code = $this->getLastFillCodeFromDB();

      # Return the first element of $fill_code_arr if there was no previous fill code
      if ( $prev_fill_code === '' ) { return $fill_code_arr[0]; }

      # Otherwise search for the matching fill code
      $fill_code_idx = array_search(strtoupper($prev_fill_code), $fill_code_arr);

      # Please note, this check must be !== (two equal signs) as != also evaluates
      #   to true for index 0
      if ( $fill_code_idx !== FALSE )
      {
         if ( $fill_code_idx == count($fill_code_arr)-1 )
         { throw new Exception ("Unable to determine next available fill code."); }
         else
         { return $fill_code_arr[$fill_code_idx+1]; }
      }
      else
      { throw new Exception ("Unable to determine next available fill code."); }
   }

   /**
   * Method for cylinder filling
   * 
   * @param $input_date (string) Fill code
   * @param $input_location (string) Fill location
   * @param $input_method (string) Fill method
   * @param $input_notes (string) Fill notes
   * @return void
   */
   public function fill()
   {
      if ( ! $this->isFillable() )
      { throw new Exception("Unable to assign  '".$this->getID()."' to be filled or refilled as it is an ".$this->getType()." cylinder."); }
 
      # If the checkin status is not equal to 'ready for filling' and 'ready for order'
      #   then throw an error.  jwm - added ready to ship so steve doesn't have to checkin before filling.
      if ( $this->getCheckInStatus('num') != '1' &&
           $this->getCheckInStatus('num') != '2' && $this->getCheckInStatus('num') != '4')
      { throw new Exception ("Cylinder ID '".$this->getID()."' is in analysis is unavailable for refill.<BR><A href='cylinder_find.php?id=".urlencode($this->getID())."'><INPUT type='button' value='Find Cylinder ".htmlentities($this->getID(), ENT_QUOTES, 'UTF-8')."'></A>"); }

      #
      # Constrain on recertification date
      #
      # In the database an example recertification date would be 2000-01-01
      #    This cylinder does not need to be recertified until 2000-02-01,
      #    so use the '<' not '<=' when comparing recertification dates
      #
      #jwm - 2021-04 skipping this now.  Duane doesn't want/need and is a pain in new fill screen.  If re-adding, make sure to look
      #add j/lib/cylfill.php->cf_addCylinder() and make logic work.  Currently this check happens first so throws an error instead of updating dot first.
      #if ( $this->isWithinDOTDate() == '0' )
      #{ throw new Exception ("Cylinder ID '".$this->getID()."' needs DoT recertification. Current DoT date of ".$this->getRecertificationDate()."."); } 


      $input_data_aarr = array();

      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 3 ||
           $numargs == 4 )
      {
          if ( ValidDate($args[0]) )
          { $input_data_aarr['date'] = $args[0]; }
          else
          { throw new Exception ("Provided fill date is invalid."); }

          if ( ! isBlank($args[1]) )
          { $input_data_aarr['location'] = $args[1]; }
          else
          { throw new Exception ("Fill location must be provided."); }

          if ( ! isBlank($args[2]) )
          { $input_data_aarr['method'] = $args[2]; }
          else
          { throw new Exception ("Fill method must be provided."); }

          if ( $numargs == 4 )
          {
             if ( ! isBlank($args[3]) )
             $input_data_aarr['notes'] = $args[3];
          }
      }
      else
      { throw new Exception("Invalid number of arguments passed."); }

      $input_data_aarr['code'] = $this->getNextFillCodeFromDB();
      $input_data_aarr['serial_number'] = $this->getID();

      $this->fill_info_aarr = $input_data_aarr;

      #  set the status as 'Processing'
      #
      # If the cylinder is ready for filling and it has been filled the
      #  set the status as 'Processing'
      #
      if ( $this->getStatus('num') == '1' )
      { $this->setStatus('3', 'num'); } 

      $this->setCheckInStatus('3','num');
   }

   /**
   * Method to ship a cylinder to the specified location
   *
   * There are two ways to call this method
   *   - Syntax 1: ship($input_location_object)
   *      Mark the cylinder as shipped to the provided $input_location_object
   *   - Syntax 2: ship($input_location_object, $input_location_comments)
   *      Mark the cylinder as shipped to the provided $input_location_object
   *       with additional $input__location_comments notes
   *
   * @param $input_location_object (DB_Location) Object. 
   * @param $input_location_comments (string) Comments. 
   * @return void
   */
   public function ship()
   {
      $database_object = $this->getDB();

      $input_data_aarr = array();
      $input_data_aarr['location_comments'] = '';

      if ( $this->isRetired() )
      {
         # Check if the cylinder is retired

         throw new Exception("Cylinder '".$this->getID()."' is retired and may not be shipped. <BR><A href='cylinder_edit.php?id=".urlencode($this->getID())."&action=update'><INPUT type='button' value='Update Cylinder ".htmlentities($this->getID(), ENT_QUOTES, 'UTF-8')."'></A>");
      }

      # Parse the input
      $args = func_get_args();
      $numargs = func_num_args();

      switch ( $numargs )
      {
         case 2:
            $input_data_aarr['location_comments'] = $args[1];
         case 1:
            if ( is_object($args[0]) &&
                 get_class($args[0]) === 'DB_Location' )
            { $input_data_aarr['location_object'] = $args[0]; }
            else
            { throw new Exception ("Provided location must be an object of class DB_Location."); }
            break;
         default:
            throw new Exception("Invalid number of arguments passed.");
            break;
      }

      # Check to see if the input location is one that may be shipped to
      $ship_locations = DB_LocationManager::getShipDBLocations($database_object);

      if ( ! equal_in_array($input_data_aarr['location_object'], $ship_locations) )
      { throw new Exception ("Must provide a location that may be shipped to."); }

      # Check if the cylinder is actively being processed 
      if ( $this->isActive() )
      {
         # If it is being processed then allow it to be shipped to one of the 'fill' locations.
         #This used to be only nwr, but now is an expanded list defined in the location manager
         #jwm. 11/15
         $fill_locations = DB_LocationManager::getFillDBLocations($database_object);
         
         if ( equal_in_array($input_data_aarr['location_object'], $fill_locations) )
            #if ( $input_data_aarr['location_object']->getNum() == '3' )
         {
            # If ship location is NWR then
            #   allow them an active cylinder bo shipped
            $this->setLocation($input_data_aarr['location_object'], $input_data_aarr['location_comments']);
         }
         else
         {
            throw new Exception("Cylinder '".$this->getID()."' is in analysis and may only be shipped to fill sites.");
         }

      }
      else
      {
         # If it is not being processed then ship it and set the status as shipped
         $this->setLocation($input_data_aarr['location_object'], $input_data_aarr['location_comments']);
         $this->setStatus('5');
      }
   }

   /**
   * Method to checkin a cylinder to the specified location
   *
   * Syntax: checkin($input_location_object, $input_location_comments)
   *  Mark the cylinder as checked in to the provided $input_location_object
   *   with additional $input__location_comments notes
   *
   * @param $input_location_object (DB_Location) Object. 
   * @param $input_location_comments (string) Comments. 
   * @return void
   */
   public function checkin()
   {
      $database_object = $this->getDB();
      $input_data_aarr = array();
      $input_data_aarr['location_comments'] = '';

      # Parse the input
      $args = func_get_args();
      $numargs = func_num_args();

      switch ( $numargs )
      {
         case 2:
            $input_data_aarr['location_comments'] = $args[1];
         case 1:
            if ( is_object($args[0]) &&
                 get_class($args[0]) === 'DB_Location' )
            { $input_data_aarr['location_object'] = $args[0]; }
            else
            { throw new Exception ("Provided location must be an object of class DB_Location."); }
            break;
         default:
            throw new Exception("Invalid number of arguments passed.");
            break;
      }

      # Check to see if the input location is one that may be shipped to
      $checkin_locations = DB_LocationManager::getCheckInDBLocations($database_object);

      if ( ! equal_in_array($input_data_aarr['location_object'], $checkin_locations) )
      { throw new Exception ("Must provide a location that may be checked in to."); }

      $this->setLocation($input_data_aarr['location_object'], $input_data_aarr['location_comments']);

      $this->setStatus($this->getCheckInStatus('num'), 'num');
   }

   /**
   * Method for final approval of a cylinder
   *
   * Syntax: readyToShip()
   *  Mark the cylinder as ready to ship as processing has been completed and
   *  has passed final approval
   *
   * @return void
   */
   public function readyToShip()
   {
      if ( $this->getStatus('num') != '3' )
      { throw new Exception ("Cylinder ID '".$this->getID()."' must be in processing before it can be completed and marked as ready to ship."); }
     
      $this->setStatus('4');
      $this->setCheckInStatus('4'); 
   }

   /**
   * Method to determine if a cylinder may be refilled
   *
   * An cylinder of type archive may not be refilled
   *
   * @return void
   */
   public function isFillable()
   {
      if ( $this->getType('num') == '2' )
      { return false; }
      else
      { return true; }
   }

   /**
   * Method to determine if a cylinder has already been assigned to an active
   *  product
   *
   * @return void
   */
   public function isActive()
   {
      $database_object = $this->getDB();

      $product_objects = DB_ProductManager::searchByCylinder($database_object, $this);

      $active_order = false;
      foreach ( $product_objects as $product_object )
      {
         if ( ( is_object($product_object->getOrder()) &&
                $product_object->getOrder()->isActive() )
              ||
              $product_object->isExtra() )
         {
            $active_order = true;
            break;
         }
      }

      if ( $active_order &&
           ( $this->getStatus('num') == '1' ||
             $this->getStatus('num') == '3' ) )
      { return TRUE; }

      return FALSE;
   }

   /**
   * Method to determine if a cylinder is retired
   *
   * @return void
   */
   public function isRetired()
   {
      if ( $this->getStatus('num') == '6' )
      { return TRUE; }

      return FALSE;
   }

   /**
   * Method to determine if a cylinder is within DOT recertification date
   *
   * @return void
   */
   public function isWithinDOTDate()
   {
      if ( $this->getRecertificationDate('date') == '9999-12-31' )
      { return (2); }

      if ( $this->getRecertificationDate('date') >= date("Y-m-01", strtotime("-5 years")) )
      { return (1); }

      return (0);
   }

   /**
   * Method to load data from the database
   *
   * Using the primary key relational database number, load the rest of
   *  the information from the database to populate this instance.
   *
   * @return void 
   */
   public function loadDataFromDB()
   {
      $database_object = $this->getDB();

      #query 
      $sql = " SELECT num, id, recertification_date, cylinder_size_num, cylinder_type_num, cylinder_status_num, cylinder_checkin_status_num, location_num, location_comments, location_datetime, location_action_user, comments FROM cylinder";;

      if ( ValidInt($this->getNum()) )
      {
         $sql = $sql." WHERE num = ?";
         $sqlargs = array($this->getNum());
      }
      else
      {
         $sql = $sql." WHERE id = ?";
         $sqlargs = array($this->getID());
      }

      $results = $database_object->queryData($sql, $sqlargs);

      #echo "<PRE>";
      #print_r($results);
      #echo "</PRE>";

      if ( count($results) == 1 )
      {
         parent::__construct($results[0]['id'],'01-00');
         $this->setRecertificationDate($results[0]['recertification_date'], 'date');
         $this->setNum($results[0]['num']);
         $this->setSize($results[0]['cylinder_size_num']);
         $this->setStatus($results[0]['cylinder_status_num'],'num');
         $this->setCheckInStatus($results[0]['cylinder_checkin_status_num'],'num');
         $this->setType($results[0]['cylinder_type_num']);
         $locationobj = new DB_Location($database_object, $results[0]['location_num']);
         $this->setLocation($locationobj, $results[0]['location_comments'], $results[0]['location_datetime']);
         $user_obj = new DB_User($database_object, $results[0]['location_action_user'], '');
         $this->setLocationActionUser($user_obj);
         $this->setComments($results[0]['comments']);
      }
      elseif ( count($results) == 0 )
      {
         # This phrase and exception type is checked in saveToDB()
         if ( ValidInt($this->getNum()) )
         { throw new UnderflowException("Cylinder num '".$this->getNum()."' not found."); }
         else
         { throw new UnderflowException("Cylinder ID '".$this->getID()."' not found. <BR><A href='cylinder_edit.php?id=".urlencode($this->getID())."&action=add'><INPUT type='button' value='Add Cylinder ".htmlentities($this->getID(), ENT_QUOTES, 'UTF-8')."'></A>"); }
      }
      else
      {
         if ( ValidInt($this->getNum()) )
         { throw new OverflowException("More than one matching cylinder num found for '".$this->getNum()."."); }
         else
         { throw new OverflowException("More than one matching cylinder ID found for '".$this->getID()."."); }
      }
   }

   /**
   * Method to save to the database
   *
   * This method is the only way to save a DB_Cylinder to
   *  the database. This allows us to make all the changes
   *  to an instantiated object. If there are errors while
   *  processing then they will occur before trying to save
   *  to the database. This makes it less likely we only
   *  save part of the information.
   *
   * @param $input_user_obj (DB_User) User calling this method.
   * @return void
   */
   public function saveToDB(DB_User $input_user_obj)
   {
      $database_object = $this->getDB();

      if ( is_array($this->fill_info_aarr) )
      {
         # Insert into the fill table

         $sqlarr = array_keys($this->fill_info_aarr);
         $sqlargs = array_values($this->fill_info_aarr);

         $sql = " INSERT INTO reftank.fill (".join(",", $sqlarr).") VALUES (".join(',',array_fill(0, count($sqlarr),'?')).")";

         $database_object->executeSQL($sql, $sqlargs);

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";

         $this->fill_info_aarr = '';
      }

      if ( $this->getNum() )
      {
         # UPDATE

         # Make sure this cylinder num already exists
         $db_cylinder_obj = new DB_Cylinder($database_object, $this->getNum(), 'num');

         # Make sure that the new location datetime is later in time
         $ts1 = strtotime($this->getLocationDatetime());
         $ts2 = strtotime($db_cylinder_obj->getLocationDatetime());

         $datediff = $ts1-$ts2;

         if ( $datediff < 0 )
         { throw new UnexpectedValueException("New datetime must be greater than current datetime."); }

         # Only update the cylinder location history if there has been a change in
         #  location, location comments, or an hour in the location date time
         if ( ! $db_cylinder_obj->getLocation()->equals($this->getLocation()) ||
              $db_cylinder_obj->getLocationComments() !== $this->getLocationComments() || 
              $datediff > 3600 )
         {
            $sqlarr = array();
            $sqlargs = array();

            array_push($sqlarr, 'cylinder_num');
            array_push($sqlargs, $db_cylinder_obj->getNum());

            array_push($sqlarr, 'location_num');
            array_push($sqlargs, $db_cylinder_obj->getLocation()->getNum());

            array_push($sqlarr, 'location_comments');
            array_push($sqlargs, $db_cylinder_obj->getLocationComments());

            array_push($sqlarr, 'location_datetime');
            array_push($sqlargs, $db_cylinder_obj->getLocationDatetime());

            array_push($sqlarr, 'location_action_user');
            array_push($sqlargs, $db_cylinder_obj->getLocationActionUser()->getUsername());

            $sql = " INSERT INTO cylinder_location (".join(',', $sqlarr).") VALUES (".join(',',array_fill(0, count($sqlarr),'?')).")";

            #print $sql."<BR>";
            #print join('|',$sqlargs)."<BR>";

            $database_object->executeSQL($sql, $sqlargs);
         }

         $this->setLocationActionUser($input_user_obj);

         if ( ! $this->equals($db_cylinder_obj) )
         {
            $sqlarr = array();
            $sqlargs = array();

            array_push($sqlarr, 'id = ?');
            array_push($sqlargs, $this->getID());

            array_push($sqlarr, 'recertification_date = ?');
            array_push($sqlargs, $this->getRecertificationDate('date'));

            array_push($sqlarr, 'cylinder_size_num = ?');
            array_push($sqlargs, $this->getSize('num'));

            array_push($sqlarr, 'cylinder_status_num = ?');
            array_push($sqlargs, $this->getStatus('num'));

            array_push($sqlarr, 'cylinder_checkin_status_num = ?');
            array_push($sqlargs, $this->getCheckInStatus('num'));

            array_push($sqlarr, 'cylinder_type_num = ?');
            array_push($sqlargs, $this->getType('num'));

            array_push($sqlarr, 'location_num = ?');
            array_push($sqlargs, $this->getLocation()->getNum());

            array_push($sqlarr, 'location_comments = ?');
            array_push($sqlargs, $this->getLocationComments());

            array_push($sqlarr, 'location_datetime = ?');
            array_push($sqlargs, $this->getLocationDatetime());

            array_push($sqlarr, 'location_action_user = ?');
            array_push($sqlargs, $this->getLocationActionUser()->getUsername());

            array_push($sqlarr, 'comments = ?');
            array_push($sqlargs, $this->getComments());

            $sql = " UPDATE cylinder SET ".join(",", $sqlarr)." WHERE num = ?";
            array_push($sqlargs, $this->getNum());

            #print $sql."<BR>";
            #print join('|',$sqlargs)."<BR>";

            #echo "<PRE>";
            #debug_print_backtrace();
            #echo "</PRE>";

            $database_object->executeSQL($sql, $sqlargs);

            #Log::update($input_user_obj->getUsername(), '(UPDATE OLD) '.$db_cylinder_obj->__toString()); 

            #echo "<PRE>";
            #print_r($db_cylinder_obj);
            #print_r($this);
            #echo "</PRE>";

            #Log::update($input_user_obj->getUsername(), '(UPDATE NEW) '.$this->diffToString($db_cylinder_obj).' '.$this->__toString()); 
            #JWM 1/17 - changing log to sql
            Log::update($input_user_obj->getUsername(), '(DB_Cylinder: update) cylinder.num:'.$this->getNum().' '.$this->diffToString($db_cylinder_obj).'   SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs)); 

            # Also, insert the information into the current reftank manager
            try
            {
               $this->addToReftank();
            }
            catch (Exception $e)
            {
               Log::update($input_user_obj->getUsername(), $e->__toString());
               throw new Exception("Please contact system admin with the following error: ".$e->getMessage());
            }

            #
            # Update related active or Extra products.
            #
            $product_objects = DB_ProductManager::searchByCylinder($database_object, $this);

            foreach ( $product_objects as $product_object )
            {
               if ( ( is_object($product_object->getOrder()) &&
                      $product_object->getOrder()->isActive() )
                    ||
                    $product_object->isExtra() )
               {
                  $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

                  if ( count($calrequest_objects) > 0 )
                  {
                     foreach ( $calrequest_objects as $calrequest_object )
                     { $calrequest_object->saveToDB($input_user_obj); }
                  }
                  else
                  {
                     # There may be no calrequests
                     $product_object->saveToDB($input_user_obj);
                  }
               }
            }
         }
      }
      else
      {
         # INSERT

         try
         {
            $db_cylinder_obj = new DB_Cylinder($database_object, $this->getID(), 'id'); 
         }
         catch(Exception $e)
         {
            # If no entry was found we will get an underflow exception
            # Otherwise rethrow the error
            if ( get_class($e) !== 'UnderflowException' )
            { throw $e; } 
         }

         if ( isset($db_cylinder_obj) && get_class($db_cylinder_obj) === 'DB_Cylinder' )
         {
            throw new LengthException("Cylinder ID '".$this->getID()."' already exists.<BR><A href='cylinder_edit.php?id=".urlencode($this->getID())."&action=update'><INPUT type='button' value='Update Cylinder ".htmlentities($this->getID(), ENT_QUOTES, 'UTF-8')."'></A>");
         }

         $this->setLocationActionUser($input_user_obj);

         $sqlarr = array();
         $sqlargs = array();

         array_push($sqlarr, 'id');
         array_push($sqlargs, $this->getID());

         array_push($sqlarr, 'recertification_date');
         array_push($sqlargs, $this->getRecertificationDate('date'));

         array_push($sqlarr, 'cylinder_size_num');
         array_push($sqlargs, $this->getSize('num'));

         array_push($sqlarr, 'cylinder_status_num');
         array_push($sqlargs, $this->getStatus('num'));

         array_push($sqlarr, 'cylinder_checkin_status_num');
         array_push($sqlargs, $this->getCheckInStatus('num'));

         array_push($sqlarr, 'cylinder_type_num');
         array_push($sqlargs, $this->getType('num'));

         array_push($sqlarr, 'location_num');
         array_push($sqlargs, $this->getLocation()->getNum());

         array_push($sqlarr, 'location_comments');
         array_push($sqlargs, $this->getLocationComments());

         array_push($sqlarr, 'location_datetime');
         array_push($sqlargs, $this->getLocationDatetime());

         array_push($sqlarr, 'location_action_user');
         array_push($sqlargs, $this->getLocationActionUser()->getUsername());

         array_push($sqlarr, 'comments');
         array_push($sqlargs, $this->getComments());

         $sql = " INSERT INTO cylinder (".join(",", $sqlarr).") VALUES (".join(',',array_fill(0, count($sqlarr),'?')).")";

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);

         #Log::update($input_user_obj->getUsername(), '(INSERT) '.$this->__toString());
         #jwm 1/17 - changing log output (moved below)
         
         # Query for the new auto increment number and assign it in this instance
         $sql2 = " SELECT LAST_INSERT_ID()";
         $lastID="";
         $results = $database_object->queryData($sql2);

         if ( isset($results) &&
              isset($results[0]) &&
              isset($results[0][0]) &&
              ValidInt($results[0][0]) )
         { $this->setNum($results[0][0]);
            $lastID=$results[0][0];
            Log::update($input_user_obj->getUsername(), '(DB_Cylinder: insert) cylinder.num:'.$lastID.' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs)); 
         
         }
         else
         { #log insert without id
            Log::update($input_user_obj->getUsername(), '(DB_Cylinder: insert) cylinder.num:? SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs)); 
            throw new LogicException("Unable to retrieve cylinder number.");
            }
         
         
         # Also, insert the information into the current reftank manager
         try
         {
            $this->addToReftank();
         }
         catch (Exception $e)
         {
            Log::update($input_user_obj->getUsername(), $e->__toString());
            throw new Exception("Please contact system admin with the following error: ".$e->getMessage());
         }

         #
         # Update related active or Extra products
         #
         $product_objects = DB_ProductManager::searchByCylinder($database_object, $this);

         foreach ( $product_objects as $product_object )
         {
            if ( ( is_object($product_object->getOrder()) &&
                   $product_object->getOrder()->isActive() )
                 ||
                 $product_object->isExtra() )
            {
               $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

               if ( count($calrequest_objects) > 0 )
               {
                  foreach ( $calrequest_objects as $calrequest_object )
                  { $calrequest_object->saveToDB($input_user_obj); }
               }
               else
               {
                  # There may be no calrequests
                  $product_object->saveToDB($input_user_obj);
               }
            }
         }
      }

   }

   /**
   * Method to determine if a given object is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (object) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals(DB_Cylinder $input_object)
   {
      if ( parent::equals($input_object) &&
           $this->getNum() == $input_object->getNum() &&
           $this->getLocation()->equals($input_object->getLocation()) &&
           $this->getLocationComments() === $input_object->getLocationComments() &&
           $this->getLocationDatetime() === $input_object->getLocationDatetime() &&
           $this->getStatus('num') == $input_object->getStatus('num') &&
           $this->getCheckInStatus('num') == $input_object->getCheckInStatus('num') &&
           $this->getSize('num') == $input_object->getSize('num') &&
           $this->getType('num') == $input_object->getType('num') )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given object matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (object) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches(DB_Cylinder $input_object)
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
      $database_object = $this->getDB();

      $tmp_cylinder_obj = $this;
      $tmp_user_obj = $tmp_cylinder_obj->getLocationActionUser();
      if ( get_class($tmp_user_obj) === 'DB_User' )
      {
         $tmp_user_obj2 = new DB_User($database_object, $tmp_user_obj->getUsername(), 'Default pa$$word.'.date("G:i:s"));
         $tmp_cylinder_obj->setLocationActionUser($tmp_user_obj2);
      }
      return 'Serialized data: '.serialize($tmp_cylinder_obj);
   }

   /**
   * Method to determine the differences between a given object and this one.
   *
   * This is primarily used when creating a log entry so that an user
   *  can quickly determine where to look for differences.
   *
   * @return (string) A string of variable names where the information
   *  has been updated.
   */
   public function diffToString(DB_Cylinder $input_cylinder_obj)
   {
      $diff_arr = array();

      if ( $this->getNum() !== $input_cylinder_obj->getNum() )
      { array_push($diff_arr, "num"); }

      if ( $this->getID() !== $input_cylinder_obj->getID() )
      { array_push($diff_arr, "id"); }

      if ( $this->getRecertificationDate('date') !== $input_cylinder_obj->getRecertificationDate('date') )
      { array_push($diff_arr, "recertification date"); }

      if ( $this->getComments() !== $input_cylinder_obj->getComments() )
      { array_push($diff_arr, "comments"); }

      if ( ! $this->getLocation()->equals($input_cylinder_obj->getLocation()) )
      { array_push($diff_arr, "location"); }

      if ( $this->getLocationComments() !== $input_cylinder_obj->getLocationComments() )
      { array_push($diff_arr, "location comments"); }

      if ( $this->getLocationDatetime() !== $input_cylinder_obj->getLocationDatetime() )
      { array_push($diff_arr, "location date time"); }

      if ( ! $this->getLocationActionUser()->matches($input_cylinder_obj->getLocationActionUser() ))
      { array_push($diff_arr, "location action user"); }

      if ( $this->getStatus() !== $input_cylinder_obj->getStatus() )
      { array_push($diff_arr, "status"); }

      if ( $this->getStatus('num') !== $input_cylinder_obj->getStatus('num') )
      { array_push($diff_arr, "status num"); }

      if ( $this->getCheckInStatus() !== $input_cylinder_obj->getCheckInStatus() )
      { array_push($diff_arr, "checkin status"); }

      if ( $this->getCheckInStatus('num') !== $input_cylinder_obj->getCheckInStatus('num') )
      { array_push($diff_arr, "checkin status num"); }

      if ( $this->getSize() !== $input_cylinder_obj->getSize() )
      { array_push($diff_arr, "size"); }

      if ( $this->getSize('num') !== $input_cylinder_obj->getSize('num') )
      { array_push($diff_arr, "size num"); }

      if ( $this->getType() !== $input_cylinder_obj->getType() )
      { array_push($diff_arr, "type"); }

      if ( $this->getType('num') !== $input_cylinder_obj->getType('num') )
      { array_push($diff_arr, "type num"); }

      $str = 'No differences found.';
      if ( count($diff_arr) > 0 )
      {
         $str = " The following information has been updated: ".join(', ', $diff_arr).".";
      }

      return($str);
   }
   
   /**
   * Method to add entry to reftank database
   *
   * This will add an entry to reftank.tankinfo if it does not
   * already exist
   * 
   * @return void
   */
   private function addToReftank()
   {
      $database_object = $this->getDB();

      $sql = " SELECT idx FROM reftank.tankinfo WHERE serial_number = ? and hydrotest = ?";
      $sqlargs = array($this->getID(), $this->getRecertificationDate('date'));

      $results = $database_object->queryData($sql, $sqlargs);

      if ( count($results) == 0 )
      {
         $sqlarr = array();
         $sqlargs = array();

         array_push($sqlarr, 'serial_number');
         array_push($sqlargs, $this->getID());

         array_push($sqlarr, 'hydrotest');
         array_push($sqlargs, $this->getRecertificationDate('date'));

         $sql = " INSERT INTO reftank.tankinfo (".join(",", $sqlarr).") VALUES (".join(',',array_fill(0, count($sqlarr),'?')).")";

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);
      }
   }
}

?>
