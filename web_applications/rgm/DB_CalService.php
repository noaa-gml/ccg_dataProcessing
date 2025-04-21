<?PHP

require_once "CalService.php";

/**
* Database calservice class
*
* This class extends CalService to handle database interactions and relational
*  database numbers.
*/

class DB_CalService extends CalService
{
   /** Database relational number */
   private $num;

   /** Related DB object */
   private $database_object;

   /** Array of calservices that have scale information in reftank database */
   private $reftank_calservice_nums = array ('1','2','3','4','5');

   /**
   * Constructor method to instantiate DB_CalService object
   *
   * There are two ways to call this method:
   *  - Syntax 1: new DB_CalRequest($input_database_object, $input_value)
   *     - Instantiate a DB_CalRequest based on $input_value. Try
   *       to instantiate using $input_value as a relational database
   *       number. If not successful, then try to instantiate
   *       using $input_value as an abbreviation.
   *  - Syntax 2: new DB_CalRequest($input_database_object, $input_value, $input_value_type)
   *     - Instantiate a DB_CalRequest using $input_value based on
   *       $input_value_type from database $input_database_object. If
   *       $input_value_type is set to 'num' then try to instantiate
   *       using $input_value as a relational database number. If
   *       $input_value_type is set to 'abbr' then try to
   *       instantiate using $input_value as an abbreviation. 
   *
   * @param $input_database_object (DB) Database object
   * @param $input_value (int|string) Input relational database number or
   *   abbreviation
   * @param $input_value_type (string) Type of $input_value. 'num' or 'abbr'
   * @return (DB_CalRequest) Instantiated object
   */
   public function __construct()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 2 )
      {
         try
         {
            #
            # Try to instantiate the object using $input_value
            #  as a relational database number
            #
            $instance = parent::__construct('xxx', 'xxx', 'xxx');
            $instance->setDB($args[0]);
            $instance->setNum($args[1]);
            $instance->loadFromDB();
            return $instance;
         }
         catch (Exception $e)
         {
            try
            {
               #
               # Try to instantiate the object using $input_object
               #  as an abbreviation
               #
               $instance = parent::__construct('xxx', 'xxx', 'xxx');
               $instance->setDB($args[0]);
               $instance->setAbbreviation($args[1]);
               $instance->loadFromDB();
               return $instance;
            }
            catch (Exception $e)
            { throw $e; }
         }
      }
      elseif ( $numargs == 3 )
      {
         if ( $args[2] == 'num' )
         {
            #
            # Instantiate using $input_value as a relational database number
            #
            $instance = parent::__construct('xxx', 'xxx', 'xxx');
            $instance->setDB($args[0]);
            $instance->setNum($args[1]);
            $instance->loadFromDB();
            return $instance;
         }
         elseif ( $args[2] == 'abbr' )
         {
            #
            # Instantiate using $input_value as an abbreviation
            #
            $instance = parent::__construct('xxx', 'xxx', 'xxx');
            $instance->setDB($args[0]);
            $instance->setAbbreviation($args[1]);
            $instance->loadFromDB();
            return $instance;
         }
         else
         {
            throw new InvalidArgumentException("Invalid type provided.");
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
   * Method to retrieve current reference scale
   *
   * @return (string) Reference scale
   */
   public function getCurrentReferenceScale()
   {
      $dbobj = $this->getDB();

      # Search calservice.reference_scale first

      $sql = "SELECT reference_scale FROM calservice WHERE num = ?";
      $sqlargs = array($this->getNum());

      $results = $dbobj->queryData($sql, $sqlargs);
     
      # There will only be one result here 
      if ( $results[0]['reference_scale'] != '' )
      {
         return $results[0]['reference_scale'];
      }
      elseif ( in_array($this->getNum(), $this->reftank_calservice_nums) )
      {
         $sql = " SELECT name FROM reftank.scales WHERE species = ? AND current = 1";
         $sqlargs = array($this->getAbbreviation());

         $results2 = $dbobj->queryData($sql, $sqlargs);

         if ( count($results2) > 1 )
         { throw new Exception ("More than one current reference scale found in reftank.scales for ".$this->getAbbreviation()."."); }
         elseif ( count($results2) == 1 )
         {
            if ( $results2[0]['name'] != '' )
            { return $results2[0]['name']; }
         }
      }
    
      # Unable to find reference scale
      return '';
   }

   /**
   * Method to retrieve reference scale span
   *
   * @param $input_reference_scale (string) Reference scale 
   * @return (string) Comma separated string min, max
   */
   public function getReferenceScaleSpan($input_reference_scale='')
   {
      if ( $input_reference_scale == '' )
      { return '9999,9999'; }
      
      $dbobj = $this->getDB();

      # Search calservice.reference_scale first

      $sql = "SELECT reference_scale, reference_scale_span_min, reference_scale_span_max FROM calservice WHERE num = ?";
      $sqlargs = array($this->getNum());

      $results = $dbobj->queryData($sql, $sqlargs);
     
      # There will only be one result here 
      if ( $results[0]['reference_scale'] == $input_reference_scale )
      {
         return $results[0]['reference_scale_span_min'].','.$results[0]['reference_scale_span_max'];
      }
      elseif ( in_array($this->getNum(), $this->reftank_calservice_nums) )
      {
         $sql = " SELECT name, scale_min, scale_max FROM reftank.scales WHERE species = ?";
         $sqlargs = array($this->getAbbreviation());

         $results2 = $dbobj->queryData($sql, $sqlargs);

         foreach ( $results2 as $tmpaarr )
         {
            if ( $tmpaarr['name'] == $input_reference_scale )
            {
               return $tmpaarr['scale_min'].','.$tmpaarr['scale_max'];
            }
         }
      }
     
      # Default
      return '9999,9999';
   }

   /**
   * Method to load related information from database
   *
   * Query the database using the relational database number or abbreviation
   *  to retrieve the related information.
   *
   * @return void
   */
   public function loadFromDB()
   {
      $dbobj = $this->getDB();

      if ( ValidInt($this->getNum()) )
      {
         $sql = " SELECT num, abbr, abbr_html, name, unit, unit_html, period_of_validity, estimated_processing_days FROM calservice WHERE num = ?";
         $sqlargs = array($this->getNum());
      }
      elseif ( ! isBlank($this->getAbbreviation()) )
      {
         $sql = " SELECT num, abbr, abbr_html, name, unit, unit_html, period_of_validity, estimated_processing_days FROM calservice WHERE abbr = ?";
         $sqlargs = array($this->getAbbreviation());
      }
      else
      { throw new Exception ("Number or abbr must be set."); }

      $results = $dbobj->queryData($sql, $sqlargs);

      #print_r($results);

      if ( count($results) == 1 )
      {
         $this->setNum($results[0]['num']);
         $this->setAbbreviation($results[0]['abbr']);
         $this->setAbbreviationHTML($results[0]['abbr_html']);
         $this->setName($results[0]['name']);

         if ( !isBlank($results[0]['unit']) )
         { $this->setUnit($results[0]['unit']); }

         if ( !isBlank($results[0]['unit_html']) )
         { $this->setUnitHTML($results[0]['unit_html']); }

         if ( !isBlank($results[0]['period_of_validity']) )
         { $this->setPeriodOfValidity($results[0]['period_of_validity']); }

         if ( !isBlank($results[0]['estimated_processing_days']) )
         { $this->setEstimatedProcessingDays($results[0]['estimated_processing_days']); }

      }
      elseif ( count($results) == 0 )
      {
         if ( ValidInt($this->getNum()) )
         { throw new UnderflowException("CalService number '".$this->getNum()."' not found."); }
         else
         { throw new UnderflowException("CalService abbr '".$this->getAbbreviation()."' not found."); }
         
      }
      else
      {
         if ( ValidInt($this->getNum()) )
         { throw new UnderflowException("More than one matching calservice number found for '".$this->getNum()."'."); }
         else
         { throw new UnderflowException("More than one matching calservice abbr found for '".$this->getAbbreviation()."'."); }
      }
   }

   /**
   * Method to determine if a given DB_CalService is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (DB_CalService) Input object to compare.
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
   * Method to determine if a given DB_CalService matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (DB_CalService) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      # This intentionally does not call the parent matches()
      if ( $this->getNum() == $input_object->getNum() )
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
