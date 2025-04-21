<?PHP

require_once "/var/www/html/inc/validator.php";
require_once "Location.php";

/**
* Database Location class
*
* A location represents a physical place that a cylinder may be. This class
* extends the Location class to handle database interactions and relational
* numbers.
*/

class DB_Location extends Location
{
   /** Relational database number */
   private $num;

   /** Related DB object */
   private $database_object;

   /**
   * Constructor method to instantiate a DB_Location object
   *
   * There are three ways to call this method.
   *  - Syntax 1: new DB_Location($input_database_object, $input_num)
   *     - Instantiates a DB_Location based on relational database number.
   *       The related information will be loaded from the specified
   *       database.
   *  - Syntax 2: new DB_Location($input_database_object, $input_abbrevation)
   *     - Instantiates a DB_Location based on abbreviation
   *       The related information will be loaded from the specified
   *       database.
   *  - Syntax 3: new DB_Location($input_database_object, $input_name, $input_abbrevation, $input_address)
   *     - Instantiates a DB_Location based on information provided.
   *
   * @param $input_database_object (DB) Database object
   * @param $input_num (int) Relational database number.
   * @param $input_abbrevation (string) Abbrevation string.
   * @param $input_name (string) Location name.
   * @param $input_address (string) Location address.
   * @return (DB_Location) Instantiated object
   */
   public function __construct()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 2 )
      {
         $this->setDB($args[0]);

         try
         {
            # By num
            $this->setNum($args[1]);

            # Query database
            $this->loadDataFromDB();
         }
         catch (Exception $e)
         {
            try
            {
               # By abbreviation
               $this->setAbbreviation($args[1]);

               # Query database
               $this->loadDataFromDB();
            }
            catch (Exception $e)
            { throw $e; }
         }
      }
      elseif ( $numargs == 4 )
      {
         $this->setDB($args[0]);
         parent::__construct($args[1], $args[2], $args[3]);
      }
      else
      {
         throw new BadMethodCallException("Must be called with num, or abbreviation, or name, abbreviation, and address");
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
   * Method to set primary key relational database number
   *
   * @param $input_value (int) Relational database number.
   * @return void
   */
   private function setNum($input_num)
   {
      if ( ValidInt($input_num) &&
           $input_num > 0 )
      { $this->num = $input_num; }
      else
      { throw new OutofRangeException("Number must be a positive integer."); }
   }

   /**
   * Method to retrieve primary key relational database number
   *
   * If the number is '' then it is considered a new DB_Location
   * (one that odes not exist in the database).
   *
   * @return (int|'') Returns primary key relational database number
   * or empty string ('').
   */
   public function getNum()
   {
      if ( $this->num != '' )
      { return $this->num; }
      else
      { return ''; }
   }

   /**
   * Method to load data from the database
   *
   * Using the primary key relational database number or abbrevation, load the
   *  rest of the information from the database to populate this instance.
   *
   * @return void 
   */
   public function loadDataFromDB()
   {
      $database_object = $this->getDB();

      #query 
      $sql = " SELECT num, name, abbr, active_status, address, comments FROM location";

      if ( ValidInt($this->getNum()) && $this->getNum() > 0 )
      {
         $sql = $sql." WHERE num = ?";
         $sqlargs = array($this->getNum());
      }
      else
      {
         $sql = $sql." WHERE abbr = ?";
         $sqlargs = array($this->getAbbreviation());
      }

      $results = $database_object->queryData($sql, $sqlargs);

      #print_r($results);

      if ( count($results) == 1 )
      {
         $this->setNum($results[0]['num']);
         $this->setName($results[0]['name']);
         $this->setActiveStatus($results[0]['active_status']);
         $this->setAbbreviation($results[0]['abbr']);
         $this->setAddress($results[0]['address']);
         $this->setComments($results[0]['comments']);
      }
      elseif ( count($results) == 0 )
      {
         if ( ValidInt($this->getNum()) && $this->getNum() > 0 )
         {
            throw new UnderflowException("Location number '".$this->getNum()."' not found.");
         }
         else
         {
            throw new UnderflowException("Location abbreviation '".$this->getAbbreviation()."' not found.");
         }
      }
      else
      {
         if ( ValidInt($this->getNum()) && $this->getNum() > 0 )
         {
            throw new OverflowException("More than one matching location found for number '".$this->getNum()."'.");
         }
         else
         {
            throw new OverflowException("More than one matching location found for abbreviation '".$this->getAbbreviation()."'.");
         }
      }
   }

   /**
   * Method to save the DB_Location to the database
   *
   * This method is the only way to save a DB_Location to
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

      if ( $this->getNum() )
      {
         # UPDATE

         # Make sure this location number exists in the database
         $db_location_obj = new DB_Location($database_object, $this->getNum());

         $sqlarr = array();
         $sqlargs = array();
         array_push($sqlarr, 'name = ?');
         array_push($sqlargs, $this->getName());

         array_push($sqlarr, 'abbr = ?');
         array_push($sqlargs, $this->getAbbreviation());

         array_push($sqlarr, 'active_status = ?');
         array_push($sqlargs, $this->getActiveStatus());

         array_push($sqlarr, 'address = ?');
         array_push($sqlargs, $this->getAddress());

         array_push($sqlarr, 'comments = ?');
         array_push($sqlargs, $this->getComments());

         $sql = " UPDATE location SET ".join(",", $sqlarr)." WHERE num = ?";
         array_push($sqlargs, $this->getNum());

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);

         #Log::update($input_user_obj->getUsername(), '(UPDATE OLD) '.$db_location_obj->__toString());
         #Log::update($input_user_obj->getUsername(), '(UPDATE NEW) '.$this->diffToString($db_location_obj).' '.$this->__toString());
         #jwm - 1/17 - changing log output
         Log::update($input_user_obj->getUsername(), '(DB_Location: update) sql:'.$sql.' sqlargs:'.implode(',',$sqlargs));
      }
      else
      {
         # INSERT

         try
         {
            $db_location_obj = new DB_Location($database_object, $this->getAbbreviation());
         }
         catch(Exception $e)
         {
            # If no entry was found we will get an underflow exception
            # Otherwise rethrow the error
            if ( get_class($e) !== 'UnderflowException' )
            { throw $e; }
         }

         if ( isset($db_location_obj) && get_class($db_location_obj) === 'DB_Cylinder' )
         {
            throw new LengthException("Location '".$this->getAbbreviation()."' already exists.");
         }

         $sqlarr = array();
         $sqlargs = array();
         array_push($sqlarr, 'name');
         array_push($sqlargs, $this->getName());

         array_push($sqlarr, 'abbr');
         array_push($sqlargs, $this->getAbbreviation());

         array_push($sqlarr, 'active_status');
         array_push($sqlargs, $this->getActiveStatus());

         array_push($sqlarr, 'address');
         array_push($sqlargs, $this->getAddress());

         array_push($sqlarr, 'comments');
         array_push($sqlargs, $this->getComments());

         $sql = " INSERT INTO location (".join(",", $sqlarr).") VALUES (".join(',',array_fill(0, count($sqlarr),'?')).")";

         #print $sql."<BR>";
         #print join('|',$sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);

         #Log::update($input_user_obj->getUsername(), '(INSERT) '.$this->__toString());
         #jwm - 1/17 - updating log output
         Log::update($input_user_obj->getUsername(), '(DB_Location: insert) sql:'.$sql.' sqlargs:'.implode(',',$sqlargs));

         # Query for the new auto increment number and assign it in this instance
         $sql = " SELECT LAST_INSERT_ID()";

         $results = $database_object->queryData($sql);

         if ( isset($results) &&
              isset($results[0]) &&
              isset($results[0][0]) &&
              ValidInt($results[0][0]) )
         { $this->setNum($results[0][0]); }
         else
         { throw new LogicException("Unable to retrieve location number."); }
      }
   }

   /**
   * Method to determine if a given DB_Location is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (DB_Location) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals(DB_Location $input_object)
   {
      if ( parent::equals($input_object) &&
           $this->getNum() === $input_object->getNum() )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given DB_Location matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (DB_Location) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches(DB_Location $input_object)
   {
      if ( parent::matches($input_object) )
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
      $tmp_obj = $this;
      return 'Seralized data: '.serialize($tmp_obj);
   }

   /**
   * Method to determine the differences between a given DB_Location and this one.
   *
   * This is primarily used when creating a log entry so that an user
   *  can quickly determine where to look for differences.
   *
   * @return (string) A string of variable names where the information
   *  has been updated.
   */
   public function diffToString(DB_Location $input_location_obj)
   {
      $diff_arr = array();

      if ( $this->getNum() !== $input_location_obj->getNum() )
      { array_push($diff_arr, 'num'); }

      if ( $this->getName() !== $input_location_obj->getName() )
      { array_push($diff_arr, 'name'); }

      if ( $this->getActiveStatus() !== $input_location_obj->getActiveStatus() )
      { array_push($diff_arr, 'active_status'); }

      if ( $this->getAbbreviation() !== $input_location_obj->getAbbreviation() )
      { array_push($diff_arr, 'abbreviation'); }

      if ( $this->getComments() !== $input_location_obj->getComments() )
      { array_push($diff_arr, 'comments'); }

      $str = 'No differences found.';
      if ( count($diff_arr) > 0 )
      {
         $str = " The following information has been updated: ".join(', ', $diff_arr).".";
      }

      return($str);
   }
}

?>
