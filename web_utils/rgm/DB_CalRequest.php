<?PHP

require_once "CalRequest.php";
require_once "DB_Product.php";
require_once "DB_CalService.php";
require_once "DB_UserManager.php";
require_once "DB_LocationManager.php";
require_once ("/var/www/Swift/lib/swift_required.php");

require_once ("/var/www/html/inc/dbutils/dbutils.php");
db_connect("j/lib/config.php");

/**
* database calibration request class that relates a DB_Product to a DB_CalService
*
* A calrequest relates a specific product with a specific calservice. This class
* extends CalRequest to handle database interactions and relational numbers.
*
*/

class DB_CalRequest extends CalRequest
{
   /** Database relational number */
   private $num;

   /** Analysis type relational number. Related to database table 'analysis_type' */
   private $analysis_type_num;

   /** Status relational number. Related to database table 'calrequest_status' */
   private $status_num;

   private $num_calibrations;#number of ordered calibrations
   private $highlight_comment;#1/0 to highlight comments in the todo list.

   /** Status HTML hex color code */
   private $status_color_html;

   /** Related DB object */
   private $database_object;

   /** DB_User object of analysis submit */
   private $analysis_submit_user_object;


   /**
   * Constructor method to instantiate a DB_CalRequest object
   *
   * There are two ways to call this method.
   *  - Syntax 1: new DB_CalRequest($input_database_object, $input_num)
   *     - Instantiates a DB_CalRequest based on relational database number
   *       The related information will be loaded from the provided database.
   *  - Syntax 2: new DB_CalRequest($input_database_object, $input_product_object, $input_calservice_object, $input_target_value, $input_analysis_type, $num_calibrations=0,$highlight_comments=0)
   *     - Instantiates a DB_CalRequest based on information provided.
   *
   * @param $input_database_object (DB) Database object
   * @param $input_num (int) DB_CalRequest relational database number.
   * @param $input_product_object (DB_Product) DB_Product object.
   * @param $input_calservice_object (DB_CalService) DB_CalService object.
   * @param $input_target_value (float) Target value for analysis.
   * @param $input_analysis_type (num|string) Type of analysis. Either relational database number or string.
   * @param $num_calibrations int number of ordered cals
   * @param $highlight_comments 1/0 to highlight comments in todo list
   * @return (DB_CalRequest) Instantiated object
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
         #print("<script>alert('".$args[5]."');</script");
         return $this;
      }
      elseif ( $numargs >= 5 )
      {
         $this->setDB($args[0]);
         $this->setProduct($args[1]);
         $this->setCalService($args[2]);
         $this->setTargetValue($args[3]);
         $this->setAnalysisType($args[4]);

         if($numargs>=6){
            $n=$args[5];
            if($n===''){
               //Come up with a default value.
               $n=3;#3 in general
               if($args[4]===2 || $args[4]===3)$n=2;#intermediate/final, default to 2
            }

            $this->setNumCalibrations($n); #We made this param optional so we wouldn't have to add to every caller.

         }else $this->setNumCalibrations(3);#default

         if($numargs>=7)$this->setHighlightComments($args[6]);
         else $this->setHighlightComments(0);#default.

         $this->setStatus('5');

         return $this;
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
    *set num calibrations
    *jwm-adding this like the others, but not sure why needed (should just inherit from parent?)

   protected function setNumCalibrations($input_value){
      if ( ( ValidInt($input_value) && $input_value >= 0 )  || $input_value == '' ){
         #if(!$input_value)$input_value=0;#set blanks to zero.
         $this->num_calibrations = $input_value;
         #var_dump($input_value);
      }else{
         throw new Exception("Provided number '".htmlentities($input_value)."' is invalid.");
      }
   }
   public function getNumCalibrations(){
      if(ValidInt($this->num_calibrations)){
         return $this->num_calibrations;
      }
      return '';
   }*/
   /**
   * Method to set primary key relational database number
   *
   * If the number is set to '' then it is considered a new DB_CalRequest
   * (one that does not exist in the database).
   *
   * @param $input_value (int) Relational database number.
   * @return void
   */
   private function setNum($input_value)
   {
      if ( ( ValidInt($input_value) &&
             $input_value > 0 )
           ||
           $input_value == '' )
      { $this->num = $input_value; }
      else
      { throw new Exception("Provided number '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve primary key relational database number
   *
   * If the number is '' then it is considered a new DB_CalRequest
   * (one that odes not exist in the database).
   *
   * @return (int|'') Returns primary key relational database number
   * or empty string ('').
   */
   public function getNum()
   {
      if ( ValidInt($this->num) )
      { return $this->num; }
      else
      { return ''; }
   }

   /**
   * Method to set the related DB_Product object.
   *
   * This also ensures that the processing status of this DB_CalRequest
   * matches the DB_Product object. If the DB_Product object is
   * processing then set the DB_CalRequest as processing also.
   *
   * @param $input_object (DB_Product) Input DB_Product object.
   * @return void
   */
   protected function setProduct($input_object)
   {
      if ( get_class($input_object) === 'DB_Product' )
      {
         # Match the status of the CalRequest to the Product
         if ( ! $input_object->isPending() )
         { $this->process(); }

         parent::setProduct($input_object);
      }
      else
      { throw new Exception("Provided product must be an object of class 'DB_Product'."); }
   }

   /**
   * Method to set DB_CalService object.
   *
   * @param $input_object (DB_CalService) Input DB_CalService object.
   */
   protected function setCalService($input_object)
   {
      if ( get_class($input_object) === 'DB_CalService' )
      { parent::setCalService($input_object); }
      else
      { throw new Exception("Provided calservice must be an object of class 'DB_CalService'."); }
   }

   /**
   * Method to set status
   *
   * There are two ways to call this method:
   *  - Syntax 1: setStatus($input_status_value)
   *     - Set the status using $input_status_value. If $input_status_value
   *       is an integer then handle it as a relational database number.
   *       Otherwise handle it as a string.
   *  - Syntax 2; setStatus($input_status_value, $input_status_type)
   *     - Set the status using $input_status_type. If set to 'num' then
   *       evaluate $input_status_value as a relational database number.
   *       If $input_status_type is set to 'abbr' then evaluate
   *       $input_status_value as a string.
   *
   * @param $input_status_value (int|string) Input status value.
   * @param $input_status_type ('num'|'abbr') Input value type.
   * @return void
   */
   protected function setStatus()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      $database_object = $this->getDB();

      if ( $numargs == 1 )
      {
         $input_value = $args[0];

         # Determine the input_type based on if it is a valid integer or not
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

      # Query the database for the status relational database number,
      # abbreviation, HTML color representation of the status then
      # set the information
      if ( $input_type === 'num' )
      {
         if ( $prev_status_num != $input_value )
         {
            $sql = " SELECT num, abbr, color_html FROM calrequest_status WHERE num = ?";
            $sqlargs = array($input_value);

            $results = $database_object->queryData($sql, $sqlargs);

            if ( count($results) == 1 )
            {
               $this->status_num = $results[0]['num'];
               parent::setStatus($results[0]['abbr']);
               $this->status_color_html = $results[0]['color_html'];
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
            $sql = " SELECT num, abbr, color_html FROM calrequest_status WHERE abbr = ?";
            $sqlargs = array($input_value);

            $results = $database_object->queryData($sql, $sqlargs);

            if ( count($results) == 1 )
            {
               $this->status_num = $results[0]['num'];
               parent::setStatus($results[0]['abbr']);
               $this->status_color_html = $results[0]['color_html'];
            }
            elseif ( count($results) == 0 )
            { throw new UnderflowException("Status abbreviation'".$input_value."' not found."); }
            else
            { throw new UnderflowException("More than one matching status abbreviation found for '".$input_value."'."); }
         }
      }
      else
      {
         throw new InvalidArgumentException("Invalid type provided.");
      }
   }

   /**
   * Method to retrieve the status
   *
   * There are two ways to call this method:
   *  - Syntax 1: getStatus()
   *     - Retrieve the status abbreviation
   *  - Syntax 2; getStatus($input_status_type)
   *     - If $input_status_num is 'num' then retrieve the relational database
   *       number. If $input_status_num is 'abbr' the retrieve the
   *       abbreviation.
   *
   * @param $input_status_type ('num'|'abbr') Input status value type.
   * @return (integer|string|'') Returns status relational database number,
   *  abbreviation string, or empty string ('').
   */
   public function getStatus()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      { $input_type = 'abbr'; }
      elseif ( $numargs === 1 )
      { $input_type = $args[0]; }
      else
      { throw new Exception("Invalid number of arguments passed."); }

      if ( $input_type === 'num' )
      {
         if ( isset($this->status_num) &&
              ValidInt($this->status_num) )
         { return $this->status_num; }
         else
         { return ''; }
      }
      elseif ( $input_type === 'abbr' )
      {
         if ( isset($this->status_num) &&
              $this->status_num === '4' )
         {
            $database_object = $this->getDB();

            #
            # If the status is 'Cylinder not ready', determine why it's not ready
            #  Does it need a fill? Does it need to be checked in?
            #
            $checkin_locations = DB_LocationManager::getCheckInDBLocations($database_object);

            $tmparr = array();
            if ( is_object($this->getProduct()->getCylinder()) &&
                 is_object($this->getProduct()->getCylinder()->getLocation()) &&
                 ! equal_in_array($this->getProduct()->getCylinder()->getLocation(), $checkin_locations) )
            { array_push($tmparr, 'checkin'); }

            if ( is_object($this->getProduct()->getCylinder()) &&
                 $this->getProduct()->getCylinder()->getCheckInStatus('num') === '1' )
            { array_push($tmparr, 'fill'); }

            return parent::getStatus()." - needs ".join(', ', $tmparr);
         }
         else
         { return parent::getStatus(); }
      }
      else
      {
         throw new InvalidArgumentException("Invalid type requested.");
      }
   }

   /**
   * Method to update the status based on related information.
   *
   * @return void
   */
   private function updateStatus()
   {
      # Status is set to completed only in analysisComplete()
      $current_status_num = $this->getStatus('num');

      if ( ! is_object($this->getProduct()) )
      { throw new Exception ("Product must be specified for a calrequest!"); }

      if ( $this->getStatus('num') == 3 )
      {
         # Status 'Complete'
         # Do nothing
      }
      elseif ( $this->getStatus('num') == '5' )
      {
         # Status 'Pending'
         # Do nothing
      }
      elseif ( is_object($this->getProduct()->getCylinder()) )
      {
         # If the cylinder is in calibration then set the status to
         # 'In Progress'. Otherwise set it to 'Cylinder not ready'.
         if ( $this->getProduct()->getCylinder()->getStatus('num') == '3' )
         { $this->setStatus('2'); }
         else
         {
            $this->setStatus('4');
         }
      }
      else
      {
         # Otherwise, set the status to 'Incomplete details'
         $this->setStatus('1', 'num');
      }
   }

   /**
   * Method to get the HTML color code of the status
   *
   * The HTML color code is set within setStatus().
   *
   * @return (string) HTML code for a color.
   */
   public function getStatusColorHTML()
   {
      if ( preg_match('/^#[A-Fa-f0-9]+$/', $this->status_color_html) )
      { return $this->status_color_html; }
      else
      { return '#000000'; }

   }

   /**
   * Method to set the analysis type
   *
   * There are two ways to call this method:
   *  - Syntax 1: setAnalysisType($input_status_value)
   *     - Set the status using $input_status_value. If $input_status_value
   *       is an integer then handle it as a relational database number.
   *       Otherwise handle it as a string.
   *  - Syntax 2; setAnalysisType($input_status_value, $input_status_type)
   *     - Set the status using $input_status_type. If set to 'num' then
   *       evaluate $input_status_value as a relational database number.
   *       If $input_status_type is set to 'abbr' then evaluate
   *       $input_status_value as a string.
   *
   * @param $input_status_value (int|string) Input analysis type value.
   * @param $input_status_type ('num'|'abbr') Input value type.
   * @return void
   */
   public function setAnalysisType()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      $database_object = $this->getDB();

      if ( $numargs == 1 )
      {
         $input_value = $args[0];

         # Determine the input_type based on if it is a valid integer or not
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

      # Try and retrieve the information from the database based
      #  on the data that the user provided and set the related information
      if ( $input_type === 'num' )
      {
         $sql = " SELECT num, abbr FROM analysis_type WHERE num = ?";
         $sqlargs = array($args[0]);

         $results = $database_object->queryData($sql, $sqlargs);

         if ( count($results) == 1 )
         {
            $this->analysis_type_num = $results[0]['num'];
            parent::setAnalysisType($results[0]['abbr']);
         }
         elseif ( count($results) == 0 )
         { throw new UnderflowException("Analysis type number '".$args[0]."' not found."); }
         else
         { throw new UnderflowException("More than one matching type number found for '".$args[0]."'."); }
      }
      elseif ( $input_type === 'abbr' )
      {
         $sql = " SELECT num, abbr FROM analysis_type WHERE abbr = ?";
         $sqlargs = array($args[0]);

         $results = $database_object->queryData($sql, $sqlargs);

         if ( count($results) == 1 )
         {
            $this->analysis_type_num = $results[0]['num'];
            parent::setAnalysisType($results[0]['abbr']);
         }
         elseif ( count($results) == 0 )
         { throw new UnderflowException("Analysis type abbreviation'".$args[0]."' not found."); }
         else
         { throw new UnderflowException("More than one matching type abbreviation found for '".$args[0]."'."); }
      }
      else
      { throw new InvalidArgumentException("Invalid type provided."); }
   }

   /**
   * Method to retrieve the analysis type
   *
   * There are two ways to call this method:
   *  - Syntax 1: getAnalysisType()
   *     - Retrieve the analysis type abbreviation
   *  - Syntax 2; getAnalysisType($input_status_type)
   *     - If $input_status_num is 'num' then retrieve the relational database
   *       number. If $input_status_num is 'abbr' the retrieve the
   *       abbreviation.
   *
   * @param $input_status_type ('num'|'abbr') Input analysis type value type.
   * @return (integer|string|'') Returns analysis type relational database
   *  number, abbreviation string, or empty string ('').
   */
   public function getAnalysisType()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      {
         return parent::getAnalysisType();
      }
      elseif ( $numargs === 1 )
      {
         if ( $args[0] === 'num' )
         {
            if ( isset($this->analysis_type_num) &&
                 ValidInt($this->analysis_type_num) )
            { return $this->analysis_type_num; }
            else
            { return ''; }
         }
         elseif ( $args[0] === 'abbr' )
         {
            return parent::getAnalysisType();
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
   * Method to reset the status
   *
   * There are two main uses of this method. The first use is when a
   *  product extra is assigned to an order. The calibration
   *  requests related to that product need to be reset because the
   *  calibration manager needs to re-approve the analysis. The
   *  second use is when a DB_CalRequest is changed from 'Pending'
   *  to a processing status.
   *
   * @return void
   */
   public function resetStatus()
   {
      $this->setStatus('1', 'num');
      $this->setAnalysisValue('nan');
      $this->setAnalysisRepeatability('nan');
      $this->setAnalysisReferenceScale('');
      $this->setAnalysisCalibrationsSelected('');
      $this->setAnalysisSubmitDatetime('0000-00-00 00:00:00');
      $this->setAnalysisSubmitUser('');
      $this->updateStatus();
   }

   /**
   * Method to set analysis submit user
   *
   * Analysis submit user is the user that completed the analysis
   *
   * @param $input_object (DB_user) Input object.
   * @return void
   */
   public function setAnalysisSubmitUser($input_object)
   {
      if ( get_class($input_object) === 'DB_User' )
      { $this->analysis_submit_user_object = $input_object; }
      elseif ( $input_object == '' )
      { $this->analysis_submit_user_object = ''; }
      else
      { throw new Exception ("Provided user must be an object of class DB_User."); }
   }

   /**
   * Method to retrieve analysis submit user
   *
   * Analysis submit user is the user that completed the analysis
   *
   * @return (DB_User) Analysis submit user.
   */
   public function getAnalysisSubmitUser()
   {
      if ( isset($this->analysis_submit_user_object) &&
           get_class($this->analysis_submit_user_object) === 'DB_User' )
      { return $this->analysis_submit_user_object; }
      else
      { return ''; }
   }



   /**
   * Method to set the DB_CalRequest in a processing status
   *
   * This is used when a DB_CalRequest was created in a 'Pending'
   *  status and is now ready to be processed. When a
   *  DB_CalRequest is set to processing then the related
   *  DB_Product should be set as processing as well.
   *
   * @return void
   */
   public function process()
   {
      if ( $this->getStatus('num') == '5' )
      {
         $this->resetStatus();
      }
      else
      {
         # Do nothing
         # The calrequest is already processing
      }

      # If there is a related product then set it as processing
      # as well
      if ( is_object($this->getProduct()) )
      { $this->getProduct()->process(); }
   }

   /**
   * Method for when an analysis is complete
   *
   * This is used when a calibration manager has completed making the
   *  analysis on a particular DB_CalRequest.
   *
   * @param $input_user_object (DB_User) Submission user
   * @param $input_value (float) Input analysis value.
   * @param $input_repeatability (float) Input analysis repeatibility.
   * @param $input_calibrations_selected (string) Input analysis calibrations selected
   * @return void
   */
   public function analysisComplete(DB_User $input_user_object,$input_value, $input_repeatability, $input_calibrations_selected='')
   {
      # Only accept the input data if we are in the correct status
      if ( $this->getStatus('num') == '2' )
      {
         $this->setAnalysisValue($input_value);
         $this->setAnalysisRepeatability($input_repeatability);

         if ( ValidFloat($this->getAnalysisValue()) ||
              $input_calibrations_selected != '' )
         {
            $this->setAnalysisReferenceScale($this->getCalService()->getCurrentReferenceScale());
         }
         $this->setAnalysisSubmitDatetime(date("Y-m-d H:i:s"));
         $this->setAnalysisSubmitUser($input_user_object);
         $this->setAnalysisCalibrationsSelected($input_calibrations_selected);

         # Mark the Calibration as complete
         $this->setStatus('3', 'num');
      }
      else
      { throw new Exception ("CalRequest must be in progress before it can be marked as complete."); }
   }

   /**
   * Method to retrieve analysis output from database
   *
   * This method builds a call to /ccg/bin/reftank to retrieve the information
   *  in a formatted way.
   *
   * @return (array) Array of analysis results.
   */
   public function getAnalyzesFromDB()
   {
      # Must have a product set
      if ( ! is_object($this->getProduct()) )
      { throw new Exception ("Product information is necessary to retrieve calibrations data."); }

      # Must have a cylinder set
      if ( ! is_object($this->getProduct()->getCylinder()) )
      { throw new Exception ("Cylinder information is necessary to retrieve calibrations data."); }

      # Must have a fill code set
      if ( isBlank($this->getProduct()->getFillCode() ) )
      { throw new Exception ("Product fill code is necessary to retrieve calibrations data."); }

      # Script to retrieve analysis information from the database.
      # Please ask Kirk Thoning for questions about this script.
      $cmd = escapeshellcmd('/ccg/bin/reftank');

      # Build the shell command
      $args = array();
      array_push($args, escapeshellarg('-g'.$this->getCalService()->getAbbreviation()));
      array_push($args, escapeshellarg('-c'.$this->getProduct()->getFillCode()));
      array_push($args, escapeshellarg($this->getProduct()->getCylinder()->getID()));

      $res = array();
      exec($cmd.' '.join(' ', $args), $res);

      #echo $cmd.' '.join(' ', $args)."<BR>";

      if ( preg_grep('/No filling information/', $res) &&
           $this->getProduct()->getFillCode() == 'A' )
      {
         $args = array();
         array_push($args, escapeshellarg('-g'.$this->getCalService()->getAbbreviation()));
         array_push($args, escapeshellarg($this->getProduct()->getCylinder()->getID()));

         $res = array();
         exec($cmd.' '.join(' ', $args), $res2);

         return ($res2);
      }
      else
      {
         return ($res);
      }
   }

   /**
   * Method to determine the last analysis from database data
   *
   * Find the last analysis date for the most recent fill code.
   *
   * @return (string) Last analysis date
   */
   public function getLastAnalysisFromDB()
   {
      $res = array_reverse($this->getAnalyzesFromDB());

      $lastfillarr = array();

      for ( $i = 0; $i < count($res); $i++ )
      {
         $fields = preg_split('/\s+/', trim($res[$i]));

         # Find the first average line
         if ( count($fields) == 3 )
         {
            # Increment the counter
            $i++;

            # Loop until the find another average line
            #   or we are at the end of the array
            for ( $j = $i; $j < count($res); $j++ )
            {
               $fields = preg_split('/\s+/', trim($res[$j]));

               # If the line has 10 columns then push it to the array
               if ( count($fields) == 10 )
               { array_push($lastfillarr, $res[$j]); }
               elseif ( count($fields) == 3 )
               {
                  break;
               }
            }
            break;
         }
      }

      $lastdate = '';

      if ( count($lastfillarr) > 0 )
      {
         sort($lastfillarr);

         # Get the maximum date
         $fields = preg_split('/\s+/', trim($lastfillarr[count($lastfillarr)-1]));

         if ( ValidDate($fields[1]) )
         { $lastdate = $fields[1]; }
      }

      return $lastdate;
   }

   public function getLastCalDate(){
      /*Returns the last calibration date and regulator for cylinder.
      */
      $t="";
      if ( is_object($this->getProduct()) ){
         if (  is_object($this->getProduct()->getCylinder()) ){
            if( is_object($this->getCalService())){
               $id=$this->getProduct()->getCylinder()->getID();
               $abbr=$this->getCalService()->getAbbreviation();
               bldsql_init();
               bldsql_from("reftank.calibrations c");
               bldsql_where("c.serial_number=?",$id);
               bldsql_where("upper(c.species) like ?",$abbr);
               bldsql_col('c.date as t');
               bldsql_orderby("c.date desc");
               bldsql_limit(1);
               #return bldsql_printableQuery();
               $a=doquery();
               if($a){
                  extract($a[0]);
               }
            }
         }else return 'No Cyl';
      }else return 'No Prod';
      return $t;
   }
   /**
   * Method to retrieve the reproducibility
   *
   * Retrieve the reproducibility from the database function
   *  for the specified date. If the date is not specified, it defaults
   *  to today.
   *
   * @return (string) Reproducibility
   */
   public function getReproducibility($input_date='')
   {
      if ( $input_date == '' ) { $input_date = date("Y-m-d"); }

      $database_object = $this->getDB();

      $sql = " SELECT f_reproducibility(?,?,?) as reproducibility";
      $sqlargs = array($this->getCalService()->getAbbreviation(),$this->getAnalysisValue(),$input_date);
      #var_dump( $sql.join(',', $sqlargs));

      $res = $database_object->queryData($sql, $sqlargs);

      return $res[0]['reproducibility'];
   }

   /**
   * Method to retrieve the expanded uncertainty
   *
   * Retrieve the expanded uncertainty frrom the database function
   *  for the specified date. If the date is not specified, it defaults
   *  to today.
   *
   * @return (string) Expanded uncertainty
   */
   public function getExpandedUncertainty($input_date='')
   {
      if ( $input_date == '' ) { $input_date = date("Y-m-d"); }

      $database_object = $this->getDB();

      $sql = " SELECT f_expanded_uncertainty(?,?,?) as expanded_uncertainty";
      $sqlargs = array($this->getCalService()->getAbbreviation(),$this->getAnalysisValue(),$input_date);

      #print $sql."<BR>";
      #print join(',', $sqlargs)."<BR>";

      $res = $database_object->queryData($sql, $sqlargs);

      return $res[0]['expanded_uncertainty'];
   }

   /**
   * Method to email software users
   *
   * This is specifically to email software users to direct them to
   *  todo_list.php.
   *
   * @param $input_subject (string) Email subject.
   * @return void
   */
   public function emailUsers($input_subject,$message="")
   {
return;#jwm 10-19. disabling for now.. new version of swift on rebuilt omi is incompatible with this code :(
/*
      if ( isBlank($input_subject) )
      { throw new Exception('E-mail subject must be provided.'); }

      $database_object = $this->getDB();

      #echo "<PRE>";
      #print_r($order_object);
      #print_r($status_aarr);
      #echo "</PRE>";

      $body = "";
      $body .= "<HTML>\n";
      $body .= " <HEAD>\n";
      $body .= " </HEAD>\n";
      $body .= " <BODY>\n";
      $body .= "$message<br><br>";
      $body .= "  <A href='https://omi.cmdl.noaa.gov/rgm/todo_list2.php?cs_num=".$this->getCalService()->getNum()."'>View ".$this->getCalService()->getAbbreviationHTML()." todo list.</A>";
      $body .= " </BODY>\n";
      $body .= "</HTML>\n";

      $user_emails = array();

      $user_objects = DB_UserManager::searchByCalService($database_object, $this->getCalService());

      foreach ( $user_objects as $user_object )
      {
         array_push($user_emails, $user_object->getEmail());
      }
/*
      $message = Swift_Message::newInstance();
      $message->setFrom(array('refgas@noaa.gov' => 'NOAA Refgas Manager'));
#DEBUG
#$user_emails=array("john.mund@noaa.gov");
      $message->setTo($user_emails);
      $message->setSubject($input_subject);
      $message->setBody($body, "text/html");

      $transport = Swift_SendmailTransport::newInstance('/usr/sbin/sendmail -bs');
      $mailer = Swift_Mailer::newInstance($transport);

      #$attachment = Swift_Attachment::fromPath($pdffile, 'application/pdf');
      #$message->attach($attachment);


      $result = $mailer->send($message);

      if ( ! $result )
      {
         throw new Exception("Sending email to user was not successful.");
      }
*/
   }

   /**
   * Method to check if a DB_CalRequest is pending
   *
   * @return (bool) TRUE => is pending. FALSE => is not pending.
   */
   public function isPending()
   {
      if ( $this->getStatus('num') == '5' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to run checks before saving to the database.
   *
   * This can be useful to evaluate checks to make sure all
   *  appropriate information has been provided. For
   *  example, making sure that a cylinder is available for
   *  order assingment before creating the order.
   *
   * @return void
   */
   public function preSaveToDB()
   {
      $database_object = $this->getDB();

      $this->updateStatus();

      # Place checks here that need to occur before data should be saved
      #  to database

      # Check related user information
      $user_objects = DB_UserManager::searchByCalService($database_object, $this->getCalService());
   }

   /**
   * Method to save the DB_CalRequest to the database
   *
   * This method is the only way to save a DB_CalRequest to
   *  the database. This allows us to make all the changes
   *  to an instantiated object. If there are errors while
   *  processing then they will occur before trying to save
   *  to the database. This makes it less likely we only
   *  save part of the information.
   *
   * @param $input_user_object (DB_User) User calling this method.
   * @return void
   */
   public function saveToDB(DB_User $input_user_object)
   {
      $email_subject = '';

      $this->updateStatus();

      $this->preSaveToDB();

      # Re-set the product to do checking

      $database_object = $this->getDB();

      $sqlaarr = array();

      # Prepare the information to be stored
      $sqlaarr['product_num'] = $this->getProduct()->getNum();
      $sqlaarr['calservice_num'] = $this->getCalService()->getNum();
      $sqlaarr['analysis_type_num'] = $this->getAnalysisType('num');
      $sqlaarr['calrequest_status_num'] = $this->getStatus('num');
      $sqlaarr['target_value'] = $this->getTargetValue();
      $sqlaarr['analysis_value'] = $this->getAnalysisValue();
      $sqlaarr['analysis_repeatability'] = $this->getAnalysisRepeatability();
      $sqlaarr['analysis_reference_scale'] = $this->getAnalysisReferenceScale();
      $sqlaarr['analysis_submit_datetime'] = $this->getAnalysisSubmitDatetime();
      if ( is_object($this->getAnalysisSubmitUser()) )
      { $sqlaarr['analysis_submit_user'] = $this->getAnalysisSubmitUser()->getUsername(); }
      else
      { $sqlaarr['analysis_submit_user'] = ''; }
      $sqlaarr['analysis_calibrations_selected'] = $this->getAnalysisCalibrationsSelected();
      $sqlaarr['comments'] = $this->getComments();
      $sqlaarr['num_calibrations']=$this->getNumCalibrations();
      $sqlaarr['highlight_comments']=$this->getHighlightComments();

      if ( ValidInt($this->getNum()) )
      {
         # UPDATE

         $db_calrequest_object = new DB_CalRequest($database_object, $this->getNum());

         if ( ! $this->equals($db_calrequest_object) )
         {
            $setarr = array();
            $sqlargs = array();
            foreach ( $sqlaarr as $key=>$value )
            {
                if($key=='analysis_submit_datetime' && $value=='')$value=NULL;
               array_push($setarr, "$key = ?");
               array_push($sqlargs, $value);
            }

            $sql = " UPDATE calrequest SET ".join(', ', $setarr)." WHERE num = ?";
            array_push($sqlargs, $this->getNum());
#var_dump($sql);exit;
            $database_object->executeSQL($sql, $sqlargs);

            #Log::update($input_user_object->getUsername(), '(UPDATE NEW) '.$this->diffToString($db_calrequest_object).' '.$this->__toString());
            #JWM - 1/17 - changing log output
            Log::update($input_user_object->getUsername(), '(DB_CalReqeust.php: update) calrequest.num:'.$this->getNum().' '.$this->diffToString($db_calrequest_object).'   SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs));
            try
            {
               # If the status has changed to 'In Progress' then email
               #  calibration managers to let them know the cylinder
               #  is available for analysis
               if ( $db_calrequest_object->getStatus('num') != '2' &&
                    $this->getStatus('num') == '2' )
               {
                  $email_subject = "Cylinder ID '".$this->getProduct()->getCylinder()->getID()."' ready for '".$this->getCalService()->getAbbreviation()."' analysis.";
                  $this->emailUsers($email_subject);
               }
            }
            catch ( Exception $e )
            {
               # Do nothing on failure
            }
         }
      }
      else
      {
         # INSERT
        if ($sqlaarr['analysis_submit_datetime']=='')$sqlaarr['analysis_submit_datetime']=NULL;

         $sql = " INSERT INTO calrequest (".join(', ', array_keys($sqlaarr)).") VALUES (".join(', ', array_fill('0', count(array_values($sqlaarr)), '?')).")";

         $sqlargs = array_values($sqlaarr);

         #print $sql."<BR>";
         #print join(',', $sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);

         $sql2 = " SELECT LAST_INSERT_ID()";
         $res = $database_object->queryData($sql2);
         $this->setNum($res[0][0]);

         $logtext='(DB_CalRequest: insert) calrequest.num:'.$res[0][0].' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs);
         #Log::update($input_user_object->getUsername(), '(INSERT) '.$this->__toString());
         #jwm - 1/17 - changing log output.
         Log::update($input_user_object->getUsername(), $logtext. ' ID:'.$res[0][0]);

         # If the status is 'In Progress' then email calibration
         # managers to let them know the cylinder is available
         # for analysis
         if ( $this->getStatus('num') == '2' )
         {
            try
            {
               $email_subject = "Cylinder ID '".$this->getProduct()->getCylinder()->getID()."' ready for '".$this->getCalService()->getAbbreviation()."' analysis.";
               $this->emailUsers($email_subject);
            }
            catch ( Exception $e )
            {
               # Do nothing on failure
            }
         }
      }

      # Save the related DB_Product
      $this->getProduct()->saveToDB($input_user_object);
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
      # We must load by number
      if ( ! ValidInt($this->getNum()) )
      { throw new Exception ("Number must be set to load from database."); }

      $database_object = $this->getDB();

      $sql = " SELECT product_num, calservice_num, analysis_type_num, calrequest_status_num, target_value, analysis_value, analysis_repeatability, analysis_reference_scale, analysis_submit_datetime, analysis_submit_user, analysis_calibrations_selected, comments,num_calibrations,highlight_comments FROM calrequest WHERE num = ?";

      $sqlargs = array($this->getNum());
      $res = $database_object->queryData($sql, $sqlargs);

      # Throw an exception if there is more or less than one result
      if ( count($res) == 0 )
      { throw new Exception("No matching records found in database."); }
      elseif ( count($res) > 1 )
      { throw new Exception("Too many matching records found in database."); }

      # Set the information to this instance

      # Try to set the product
      try
      {
         $product_obj = new DB_Product($database_object, $res[0]['product_num']);
         $this->setProduct($product_obj);
      }
      catch(Exception $e)
      { }

      $calservice_obj = new DB_CalService($database_object, $res[0]['calservice_num']);
      $this->setCalService($calservice_obj);

      $this->setAnalysisType($res[0]['analysis_type_num']);
      $this->setStatus($res[0]['calrequest_status_num']);
      $this->setTargetValue($res[0]['target_value']);

      if ( ! isBlank($res[0]['analysis_value']) )
      { $this->setAnalysisValue($res[0]['analysis_value']); }

      if ( ! isBlank($res[0]['analysis_repeatability']) )
      { $this->setAnalysisRepeatability($res[0]['analysis_repeatability']); }

      if ( ! isBlank($res[0]['analysis_reference_scale']) )
      { $this->setAnalysisReferenceScale($res[0]['analysis_reference_scale']); }

      if ( ! isBlank($res[0]['analysis_submit_datetime']) )
      { $this->setAnalysisSubmitDatetime($res[0]['analysis_submit_datetime']); }

      if ( ! isBlank($res[0]['analysis_submit_user']) )
      {
         $user_obj = new DB_User($database_object, $res[0]['analysis_submit_user'], '');
         $this->setAnalysisSubmitUser($user_obj);
      }

      if ( ! isBlank($res[0]['analysis_calibrations_selected']) )
      { $this->setAnalysisCalibrationsSelected($res[0]['analysis_calibrations_selected']); }

      $this->setComments($res[0]['comments']);
      $this->setNumCalibrations($res[0]['num_calibrations']);
      $this->setHighlightComments($res[0]['highlight_comments']);
   }

   /**
   * Method to delete the related information from the database
   *
   * Delete information from the database related to the primary key
   *  relational database number. Then setNum() to empty string to
   *  mark this instance as new information.
   *
   * @param $input_user_object (DB_User) User calling this method.
   * @return void
   */
   public function deleteFromDB(DB_User $input_user_object)
   {
      # We must delete by number
      if ( ! ValidInt($this->getNum()) )
      { throw new Exception ("Number must be set to delete from database."); }

      $database_object = $this->getDB();

      $sql = " DELETE FROM calrequest WHERE num = ? LIMIT 1";
      $sqlargs = array($this->getNum());

      #print $sql."<BR>";
      #print join(',', $sqlargs)."<BR>";

      $database_object->executeSQL($sql, $sqlargs);

      #Log::update($input_user_object->getUsername(), '(DELETE) '.$this->__toString());
      #JWM - 1/17 - changing log output
      Log::update($input_user_object->getUsername(), '(DB_CalRequest: delete) calrequest.num:'.$this->getNum().' sql:'.$sql.' sqlargs:'.implode(',',$sqlargs));

      $this->setNum('');
   }

   /**
   * Method to determine if a given DB_CalRequest is equal to this one
   *
   * They should be exactly the same in all data. This calls the parent
   *  version of equals().
   *
   * @param $input_object (DB_CalRequest) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal.
   */
   public function equals($input_object)
   {
      # Be careful with these matches
      # strings should be compared with === (three equals)
      # numbers may be compared with == (two equals)

      if ( parent::equals($input_object) &&
           $this->getNum() == $input_object->getNum() &&
           $this->getStatus('num') == $input_object->getStatus('num') )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given DB_CalRequest matches to this one
   *
   * They should have the same primary information. Think primary key.
   *  This also calls the parent version of matches().
   *
   * @param $input_object (DB_CalRequest) Input object to compare.
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

   /**
   * Method to determine the differences between a given DB_CalRequest and this one.
   *
   * This is primarily used when creating a log entry so that an user
   *  can quickly determine where to look for differences.
   *
   * @return (string) A string of variable names where the information
   *  has been updated.
   */
   public function diffToString(DB_CalRequest $input_calrequest_object)
   {
      $diff_arr = array();

      if ( $this->getNum() !== $input_calrequest_object->getNum() )
      { array_push($diff_arr, 'num'); }

      if ( $this->getNumCalibrations() !== $input_calrequest_object->getNumCalibrations() )
      { array_push($diff_arr, 'num_calibrations'); }

      if ( $this->getHighlightComments() !== $input_calrequest_object->getHighlightComments() )
      { array_push($diff_arr, 'highlight_comments'); }

      if ( ! $this->getProduct()->equals($input_calrequest_object->getProduct()) )
      { array_push($diff_arr, 'product'); }

      if ( ! $this->getCalService()->equals($input_calrequest_object->getCalService()) )
      { array_push($diff_arr, 'calservice'); }

      if ( $this->getStatus('num') !== $input_calrequest_object->getStatus('num') )
      { array_push($diff_arr, 'status'); }

      if ( $this->getTargetValue() !== $input_calrequest_object->getTargetValue() )
      { array_push($diff_arr, 'target_value'); }

      if ( $this->getAnalysisType('num') !== $input_calrequest_object->getAnalysisType('num') )
      { array_push($diff_arr, 'analysis_type'); }

      if ( $this->getAnalysisValue() !== $input_calrequest_object->getAnalysisValue() )
      { array_push($diff_arr, 'analysis_value'); }

      if ( $this->getAnalysisRepeatability() !== $input_calrequest_object->getAnalysisRepeatability() )
      { array_push($diff_arr, 'analysis_repeatability'); }

      if ( $this->getAnalysisReferenceScale() !== $input_calrequest_object->getAnalysisReferenceScale() )
      { array_push($diff_arr, 'analysis_reference_scale'); }

      if ( $this->getAnalysisSubmitDatetime() !== $input_calrequest_object->getAnalysisSubmitDatetime() )
      { array_push($diff_arr, 'analysis_submit_datetime'); }

      if ( $this->getAnalysisCalibrationsSelected() !== $input_calrequest_object->getAnalysisCalibrationsSelected() )
      { array_push($diff_arr, 'analysis_calibrations_selected'); }

      $str = 'No differences found.';
      if ( count($diff_arr) > 0 )
      {
         $str = " The following information has been updated: ".join(', ', $diff_arr).".";
      }

      return($str);
   }
}
