<?PHP

require_once "/var/www/html/inc/validator.php";

/**
*
*  calibration request class that relates Product to CalService (calibration service).
*
*  A calrequest (calibration request) relates a specific product
*  with a specific calservice (calibration service). For example,
*  product #1 and calibration service for co2.
*  This also keeps track of target value, analysis value, analysis repeatability
*  and the )type of calibration ('initial', 'intermediate', 'final') 
*
*/
class CalRequest
{
   /** Related Product object */
   private $product_object;

   /** Related CalService object */
   private $calservice_object;

   /** Status abbrevation */
   private $status_abbr;

   /** Target value */
   private $target_value;

   /** Analysis type abbreviation */
   private $analysis_type_abbr;

   /** Analysis value */
   private $analysis_value;

   /** Analysis repeatability */
   private $analysis_repeatability;

   /** Analysis reference scale */
   private $analysis_reference_scale;

   /** Analysis submission datetime */
   private $analysis_submit_datetime;

   /** Analysis calibrations selected */
   private $analysis_calibrations_selected;

   /** Comments */
   private $comments;

   /* number of calibrations ordered*/
   private $num_calibrations;
   
   /*highlight comment*/
   private $highlight_comments;
   
   /**
   * Constructor method for instantiating a CalRequest object.
   *
   * @param $input_product_object (Product) Product object.
   * @param $input_calservice_object (CalService) CalService object.
   * @param $input_target_value (float) Target value for analysis.
   * @param $input_analysis_type_abbr (string) Type of analysis.
   * @param $num_calibrations (int) number of calibrations ordered (optional)
   * @return (CalRequest) Instantiated object
   */
   public function __construct($input_product_object, $input_calservice_object, $input_target_value, $input_analysis_type_abbr,$num_calibrations='')
   {
      $this->setProduct($input_product_object);
      $this->setCalService($input_calservice_object);
      $this->setTargetValue($input_target_value);
      $this->setAnalysisType($input_analysis_type_abbr);
      
      
      $this->setNumCalibrations($num_calibrations);
      return $this;
   }

   /**
   * Method to set the related Product object
   *
   * If the user wants to change the product they should instead
   * create a new CalRequest.
   *
   * @param $input_object (Product) Product object. 
   * @return void
   */
   protected function setProduct($input_object)
   {
      if ( is_a($input_object, 'Product' ) )
      { $this->product_object = $input_object; }
      else
      { throw new Exception("Provided product must be an object of or be a subclass of class 'Product'."); }
   }

   /**
   * Method to retrieve the related Product object.
   *
   * @return (Product|'') Returns related Product object or empty string ('').
   */
   public function getProduct()
   {
      if ( isset($this->product_object) &&
           is_a($this->product_object, 'Product') )
      { return $this->product_object; }
      else
      { return ''; }
   }
   /*Set/get num_calibrations
    */
   public function setNumCalibrations($input_value){
      
      if ( ( ValidInt($input_value) && $input_value >= 0 )  || $input_value == '' ){
         if(!$input_value)$input_value=0;#set blanks to zero.
         $this->num_calibrations = $input_value;
         
      }else{
         throw new Exception("Provided number '".htmlentities($input_value)."' is invalid.");
      }
   }
   public function getNumCalibrations(){
      if(ValidInt($this->num_calibrations)){
         return $this->num_calibrations;
      }
      return '';
   }
   #get/set highlight comments
   public function setHighlightComments($highlight){
      $val=0;
      if(ValidInt($highlight))$val=$highlight;
      else throw new Exception("Provided value for highlight comments is invalid: ".htmlentities($highlight));
      $this->highlight_comments=$val;
   }
   public function getHighlightComments(){
      return $this->highlight_comments;
   }
   /**
   * Method to set related CalService object
   *
   * If the user wants to change the calservice object they should instead
   * create a new CalRequest.
   *
   * @param $input_object (CalService) CalService object.
   * @return void
   */
   protected function setCalService($input_object)
   {
      if ( is_a($input_object, 'CalService' ) )
      {
         if ( ! isset($this->calservice_object) )
         { $this->calservice_object = $input_object; }
         else
         { throw new Exception("CalRequest calservice already set. Create a new CalRequest instead."); }
      }
      else
      { throw new Exception("Provided calservice must be an object of or be a subclass of class 'CalService'."); }
   }

   /**
   * Method to retrieve the related CalService object
   *
   * @return (CalService|'') Returns CalService object or empty string (''). 
   */
   public function getCalService()
   {
      if ( isset($this->calservice_object) &&
           is_a($this->calservice_object, 'CalService') )
      { return $this->calservice_object; }
      else
      { return ''; }
   }

   /**
   * Method to set the status of the CalRequest.
   *
   * Such as 'In Progress', 'Complete', etc...
   *
   * @param $input_value (string) Input status string.
   * @return void
   */
   protected function setStatus($input_value)
   {
      if ( preg_match('/^[A-Za-z0-9_\- ]+$/', $input_value) )
      { $this->status_abbr = $input_value; }
      else
      { throw new Exception ("Provided status '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the status of the CalRequest.
   *
   * Such as 'In Prograss', 'Complete', etc...
   *
   * @return (string) Status string.

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
   * Method to set the requested target value for analysis
   *
   * @param $input_value (float) Input floating point target value.
   * @return void
   */
   public function setTargetValue($input_value)
   {
      if ( ValidFloat($input_value) ||
           strtolower($input_value) == 'ambient' )
      { $this->target_value = strtolower($input_value); }
      else
      { throw new Exception ("Provided target value '".htmlentities($input_value)."' is invalid"); }
   }

   /**
   * Method to retrieve the requested target value for analysis
   *
   * @return (float|'') Floating point target value or empty string ('').
   */
   public function getTargetValue()
   {
      if ( isset($this->target_value) &&
           ( ValidFloat($this->target_value) ||
             $this->target_value == 'ambient' ) )
      { return $this->target_value; }
      else
      { return ''; }
   }

   /**
   * Method to set the analysis type
   *
   * For example, 'Initial', 'Intermediate', 'Final'.
   *
   * @param $input_value (string) Input analysis type string.
   * @return void
   */
   public function setAnalysisType($input_value)
   {
      if ( ! isBlank($input_value) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $input_value) )
      { $this->analysis_type_abbr = $input_value; }
      else
      { throw new Exception ("Provided status '".htmlentities((string)$input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the analysis type
   *
   * For example, 'Initial', 'Intermediate', 'Final'.
   *
   * @return (string) Analysis type string.
   */
   public function getAnalysisType()
   {
      if ( isset($this->analysis_type_abbr) &&
           preg_match('/^[A-Za-z0-9_\- ]+$/', $this->status_abbr) )
      { return $this->analysis_type_abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set the analysis value
   *
   * This result is provided by the calibration manager for a specific
   * calservice. It is used in the calibration certificates.
   *
   * @param $input_value (float) Input floating point analysis value.
   * @return void
   */
   protected function setAnalysisValue($input_value)
   {
      if ( ValidFloat($input_value) ||
           $input_value == 'NaN' ||
           $input_value == 'nan' ||
           $input_value == 'n/a' ||
           $input_value == 'skipped' ||
           $input_value == 'completed' )
      { $this->analysis_value = strtolower($input_value); }
      else
      { throw new Exception ("Provided analysis value '".htmlentities($input_value)."' is invalid. Must be float or 'NaN'."); }
   }

   /**
   * Method to retrieve the analysis value
   *
   * This result is provided by the calibration manager for a specific
   * calservice. It is used in the calibration certificates.
   *
   * @return (float) Floating point analysis value.
   */
   public function getAnalysisValue()
   {
      if ( isset($this->analysis_value) &&
           ( ValidFloat($this->analysis_value) ||
             strtolower($this->analysis_value) == 'nan' ||
             $this->analysis_value=='n/a' ||
             $this->analysis_value == 'skipped' ||
             $this->analysis_value == 'completed' ) )
      { return $this->analysis_value; }
      else
      { return ''; }
   }

   /**
   * Method to set the analysis repeatability
   *
   * This result is provided by the calibration manager for a specific
   * calservice. It is used in the calibration certificates.
   *
   * @param $input_value (float|'NaN') Input floating point analysis repeatability or 'NaN'.
   * @return void
   */
   protected function setAnalysisRepeatability($input_value)
   {
      if ( ValidFloat($input_value) || 
           $input_value == 'NaN' ||
           $input_value == 'nan' ||
           $input_value == 'n/a' ||
           $input_value == 'skipped' ||
           $input_value == 'completed' )
      { $this->analysis_repeatability = strtolower($input_value); }
      else
      { throw new Exception ("Provided analysis repeatability '".htmlentities($input_value)."' is invalid. Must be float or 'NaN'."); }
   }

   /**
   * Method to retrieve the analysis repeatability
   *
   * This result is provided by the calibration manager for a specific
   * calservice. It is used in the calibration certificates.
   *
   * @return (float|'') Floating point analysis repeatability or empty string ('').
   */
   public function getAnalysisRepeatability()
   {
      if ( isset($this->analysis_repeatability) &&
           ( ValidFloat($this->analysis_repeatability) ||
             strtolower($this->analysis_repeatability) == 'nan' ||
             $this->analysis_repeatability == 'n/a' ||
             $this->analysis_repeatability == 'skipped' ||
             $this->analysis_repeatability == 'completed' ) )
      { return $this->analysis_repeatability; }
      else
      { return ''; }
   }

   /**
   * Method to set the reference scale
   *
   * This information is provided when the calibration manager submits
   *  a specific calrequest. It is used in the calibration certificates.
   * This also allows us to keep track of which scale the submitted
   *  value was on. 
   *
   * @param $input_value (string) Input reference scale
   * @return void
   */
   protected function setAnalysisReferenceScale($input_value)
   {
      $this->analysis_reference_scale = $input_value;
   }

   /**
   * Method to retrieve the reference scale
   *
   * This information is provided when the calibration manager submits
   *  a specific calrequest. It is used in the calibration certificates.
   * This also allows us to keep track of which scale the submitted
   *  value was on. 
   *
   * @return (string) Analysis reference scale
   */
   public function getAnalysisReferenceScale()
   {
      if ( isset($this->analysis_reference_scale) )
      { return $this->analysis_reference_scale; }
      else
      { return ''; }
   }

   /**
   * Method to set analysis submission date time
   *
   * @param $input_value (datetime) Submission date time. Format 'YYYY-MM-DD HH:MM:SS'.
   * @return void
   */
   protected function setAnalysisSubmitDatetime($input_value)
   {
      if ( $input_value == '0000-00-00 00:00:00' ||
           ValidDatetime($input_value) )
      { $this->analysis_submit_datetime = $input_value; }
      else
      { throw new Exception ("Provided analysis submission date '".htmlentities($input_value)."' is not valid."); }
   }

   /**
   * Method to retrieve analysis submission date time
   *
   * @return (datetime) Submission date time. Format 'YYYY-MM-DD HH:MM:SS'.
   */
   public function getAnalysisSubmitDatetime()
   {
      if ( isset($this->analysis_submit_datetime) &&
           ValidDatetime($this->analysis_submit_datetime) )
      { return $this->analysis_submit_datetime; }
      else
      { return ''; }
   }

   /**
   * Method to set the calibrations associated with an analysis
   *
   * This information is provided by the calibration manager for a 
   *  specific calrequest. It is used in the calibration certificates.
   * This also allows us to keep track of which scale the submitted
   *  value was on. 
   *
   * @param $input_value (string) Input reference scale
   * @return void
   */
   protected function setAnalysisCalibrationsSelected($input_value)
   {
      $this->analysis_calibrations_selected = urlencode($input_value);
   }

   /**
   * Method to retrieve the calibrations associated with an analysis
   *
   * This information is provided when the calibration manager for a 
   *  specific calrequest. It is used in the calibration certificates.
   * This also allows us to keep track of which scale the submitted
   *  value was on. 
   *
   * @return (string) Analysis reference scale
   */
   public function getAnalysisCalibrationsSelected()
   {
      if ( isset($this->analysis_calibrations_selected) )
      { return urldecode($this->analysis_calibrations_selected); }
      else
      { return ''; }
   }

   /**
   * Method to set comments
   *
   * @param $input_value (string) Input comments.
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
   * @return (string) Comments.
   */
   public function getComments()
   {
      if ( isset($this->comments) )
      { return urldecode($this->comments); }
      else
      { return ''; }
   }

   /**
   * Method to calculate the estimated processing time in days
   *
   * This is used for us to calculate what the due date should be.
   *
   * @return (int) Estimated number of days for processing. 
   */
   public function calculateEstimatedProcessingDays()
   {
      return $this->getCalService()->getEstimatedProcessingDays();
   }

   /**
   * Method to determine if a given CalRequest is equal to this one
   *
   * They should be exactly the same in all data.
   *
   * @param $input_object (CalRequest) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals($input_object)
   {
      # Be careful with these matches
      # strings should be compared with === (three equals)
      # numbers may be compared with == (two equals)
      # getTargetValue may be 293.0 and 293.00, which are equal
      if ( get_class($this) === get_class($input_object) &&
           $this->getProduct()->equals($input_object->getProduct()) &&
           $this->getCalService()->equals($input_object->getCalService()) &&
           $this->getTargetValue() == $input_object->getTargetValue() &&
           $this->getAnalysisType() === $input_object->getAnalysisType() &&
           $this->getStatus() === $input_object->getStatus() &&
           $this->getAnalysisValue() == $input_object->getAnalysisValue() &&
           $this->getAnalysisRepeatability() == $input_object->getAnalysisRepeatability() &&
           $this->getAnalysisReferenceScale() == $input_object->getAnalysisReferenceScale() &&
           $this->getAnalysisSubmitDatetime() == $input_object->getAnalysisSubmitDatetime() &&
           $this->getAnalysisCalibrationsSelected() == $input_object->getAnalysisCalibrationsSelected() &&
           $this->getComments() == $input_object->getComments()  &&
           $this->getNumCalibrations() == $input_object->getNumCalibrations() &&
           $this->getHighlightComments() == $input_object->getHighlightComments())
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given CalRequest matches to this one
   *
   * They should have the same primary information. Think primary key.
   *
   * @param $input_object (CalRequest) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getProduct()->matches($input_object->getProduct()) &&
           $this->getCalService()->matches($input_object->getCalService()) )
      { return true; }
      else
      { return false; }
   }
}
