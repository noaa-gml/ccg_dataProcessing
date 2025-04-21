<?PHP

require_once "/var/www/html/inc/validator.php";

/**
* Calibration service class
*
* A calservice (calibration service) represents an analysis service
*  to be provided. Some examples are 'co2', 'ch4' and 'co'.
*  This includes related information such as units, reference scale,
*  reference paper, reproducability, period of validity, and
*  estimated processing days. 
*
*/

class CalService
{
   /** Abbreviation */
   private $abbr;

   /** Abbreviation in HTML */
   private $abbr_html;

   /** Name */
   private $name;

   /** Unit of measure */
   private $unit;

   /** Unit of measure in hTML */
   private $unit_html;

   /** Reference publications and papers */
   private $reference_papers;

   /** Reference scale reproducibility */
   private $reproducibility;

   /** Analysis period of validity */
   private $period_of_validity;

   /** Calibration method abbreviation */
   private $calibration_method_abbr;

   /** Calibration method name */
   private $calibration_method_name;

   /** Estimated days for analysis */
   private $estimated_processing_days;

   /**
   * Constructor method for instantiating a CalService object
   *
   * @param $input_abbr (string) calservice abbreviation
   * @param $input_abbr_html (string) HTML version of calservice abbreviation
   * @param $input_name (string) name of calservice 
   * @return (CalService) Instantiated object.
   */
   public function __construct ($input_abbr, $input_abbr_html, $input_name)
   {
      $this->setAbbreviation($input_abbr);
      $this->setAbbreviationHTML($input_abbr_html);
      $this->setName($input_name);

      return $this;
   }

   /**
   * Method to set the abbreviation
   *
   * @param $input_value (string) calservice abbreviation.
   * @return void
   */
   public function setAbbreviation($input_value)
   {
      if ( ! isBlank($input_value) && 
           preg_match('/^[A-Za-z0-9_ ]+$/', $input_value) )
      { $this->abbr = $input_value; }
      else
      { throw new Exception ("Provided abbr '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the abbreviation
   *
   * @return (string) calservice abbrevation or empty string ('').
   */
   public function getAbbreviation()
   {
      if ( isset($this->abbr) &&
           preg_match('/^[A-Za-z0-9_ ]+$/', $this->abbr) )
      { return $this->abbr; }
      else
      { return ''; }
   }

   /**
   * Method to set the HTML version of the calservice abbreviation
   *
   * @param $input_value (string) calservice abbreviation in HTML.
   * @return void
   */
   public function setAbbreviationHTML($input_value)
   {
      if ( ! isBlank($input_value) )
      { $this->abbr_html = $input_value; }
      else
      { throw new Exception ("Provided abbr HTML '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the HTML version of the calservice abbreviation.
   *
   * @return (string) calservice abbreviation in HTML or empty string ('').
   */ 
   public function getAbbreviationHTML()
   {
      if ( isset($this->abbr_html) )
      { return $this->abbr_html; }
      else
      { return ''; }
   }

   /**
   * Method to set the name
   *
   * @param $input_value (string) name of calservice.
   * @return void
   */
   public function setName($input_value)
   {
      if ( ! isBlank($input_value) && 
           preg_match('/^[A-Za-z0-9_\-\/\[\]& ]+$/', $input_value) )
      { $this->name = $input_value; }
      else
      { throw new Exception ("Provided name '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the name
   *
   * @return (string) Name of calservice or empty string.
   */
   public function getName()
   {
      if ( isset($this->name) &&
           preg_match('/^[A-Za-z0-9_\-\/ ]+$/', $this->name) )
      { return $this->name; }
      else
      { return ''; }
   }

   /**
   * Method to set the unit of measure
   *
   * @param $input_value (string) Unit of measure.
   * @return void
   */
   public function setUnit($input_value)
   {
      if ( ! isBlank($input_value) )
      { $this->unit = $input_value; }
      else
      { throw new Exception ("Provided unit '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the unit of measure
   *
   * @return (string) Unit of measure or empty string ('').
   */
   public function getUnit()
   {
      if ( isset($this->unit) &&
           preg_match('/^[A-Za-z0-9_ ]+$/', $this->unit) )
      { return $this->unit; }
      else
      { return ''; }
   }

   /**
   * Method to set the HTML version of the unit of measure
   *
   * @param $input_value (string) unit of measure in HTML.
   * @return void
   */
   public function setUnitHTML($input_value)
   {
      if ( ! isBlank($input_value) )
      { $this->unit_html = $input_value; }
      else
      { throw new Exception ("Provided unit HTML '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve the HTML version of the unit of measure
   *
   * @return (string) unit of measure in HTML or empty string ('').
   */ 
   public function getUnitHTML()
   {
      if ( isset($this->unit_html) )
      { return $this->unit_html; }
      else
      { return ''; }
   }

   /**
   * Method to set period of validity of analysis.
   *
   * @param $input_value (string) Period of validity of analysis.
   * @return void
   */
   public function setPeriodOfValidity($input_value)
   {
      if ( ! isBlank($input_value) && 
           preg_match('/^[A-Za-z0-9 ]+$/', $input_value) )
      { $this->period_of_validity = $input_value; }
      else
      { throw new Exception ("Provided reference scale '".htmlentities($input_value)."' is invalid."); }
   }

   /**
   * Method to retrieve period of validity of analysis.
   *
   * @return (string) Period of validity of analysis or empty string ("').
   */
   public function getPeriodOfValidity()
   {
      if ( isset($this->period_of_validity) &&
           preg_match('/^[A-Za-z0-9 ]+$/', $this->period_of_validity) )
      { return $this->period_of_validity; }
      else
      { return ''; }
   }

   /**
   * Method to set the estimated processing days.
   *
   * @param $input_value (int) Estimated processing days.
   * @return void
   */
   public function setEstimatedProcessingDays($input_value)
   {
      if ( ! isBlank($input_value) &&
           ValidInt($input_value) &&
           $input_value > 0 )
      { $this->estimated_processing_days = $input_value; }
      else
      { throw new Exception ("Provided estimated processing days '".$input_value." is invalid."); } 
   }

   /**
   * Method to retrieve the estimated processing days
   *
   * @return (int|'') Estimated processing days or empty string ('')
   */
   public function getEstimatedProcessingDays()
   {
      if ( isset($this->estimated_processing_days) &&
           ValidInt($this->estimated_processing_days) &&
           $this->estimated_processing_days > 0 )
      { return $this->estimated_processing_days; }
      else
      { return ''; }
      
   }

   /**
   * Method to determine if a given CalService is equal to this one
   *
   * They should be exactly the same in all data.
   *
   * @param $input_object (CalService) Input object to compare.
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function equals($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getAbbreviation() === $input_object->getAbbreviation() &&
           $this->getAbbreviationHTML() === $input_object->getAbbreviationHTML() &&
           $this->getName() === $input_object->getName() && 
           $this->getUnit() === $input_object->getUnit() && 
           $this->getUnitHTML() === $input_object->getUnitHTML() && 
           $this->getPeriodOfValidity() === $input_object->getPeriodOfValidity() ) 
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if a given CalService matches to this one
   *
   * They should have the same primary information. Think primary key.
   *
   * @param $input_object (CalService) Input object to compare.
   * @return (bool) TRUE -> match. FALSE -> not match. 
   */
   public function matches($input_object)
   {
      if ( get_class($this) === get_class($input_object) &&
           $this->getAbbreviation() === $input_object->getAbbreviation() &&
           $this->getName() === $input_object->getName() )
      { return true; }
      else
      { return false; }
   }
}
