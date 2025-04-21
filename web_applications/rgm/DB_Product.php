<?PHP

require_once "Log.php";
require_once "Product.php";
require_once "DB_Order.php";
require_once "DB_Cylinder.php";
require_once "DB_CalRequestManager.php";
require_once "DB_CalServiceManager.php";

/**
* Database product class that relates DB_Cylinder and fill code to DB_Order
*
* A product relates cylinder information to an order. 
* If a DB_Cylinder is not specified, the product will be displayed as waiting
*  for a cylinder to be filled.
* If a DB_Order is not specified, the product is considered a product extra.
* Analyzes can be processed however the product is waiting to be assigned to
* an order.
*
* This class extends Product to handle database interactions and relational
* numbers.
*
*/

class DB_Product extends Product
{
   /** Relational database number */
   private $num;

   /** Status relational database number. Related to database table 'product_status' */
   private $status_num;

   /** Cylinder size relational database number */
   private $cylinder_size_num;

   /** Related DB object */
   private $database_object;

   /**
   * Constructor method to instantiate a DB_Product object
   * 
   * There are two ways to call this method.
   *  - Syntax 1: new DB_Product($input_database_object, $input_num)
   *     - Instantiates a DB_Product based on relational database number.
   *       The related information will be loaded from the specified
   *       database.
   *  - Syntax 2: new DB_Product($input_database_object, $input_order_object, $input_cylinder_size)
   *     - Instantiates a DB_Product based on information provided from
   *       the specified database
   *
   * @param $input_database_object (DB) Database object
   * @param $input_num (int) Relational database number.
   * @param $input_order_object (DB_Order) DB_Order object.
   * @param $input_cylinder_size (string) Cylinder size.
   * @return (DB_Product) Instantiated object
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
         $this->setOrder($args[1]);
         $this->setCylinderSize($args[2]);
         $this->setStatus('5', 'num');
      }
      else
      { throw new Exception("Invalid number of arguments passed in instantiating DB_Product."); }
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
   * If the number is set to '' then it is considered a new DB_Product
   * (one that does not exist in the database).  
   *
   * @param $input_value (int) Relational database number.
   * @return void
   */
   private function setNum($input_value)
   {
      if ( $input_value == '' ||
           ValidInt($input_value) )
      { $this->num = $input_value; }
      else
      { throw new Exception("Provided number '".htmlentities((string)$input_value)."' is invalid."); }
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
   * Method to set the related DB_Order object.
   * 
   * @param $input_object (DB_Order|'') Input object or empty string.
   * @return void 
   */
   public function setOrder($input_object)
   {
      if ( get_class($input_object) === 'DB_Order' || 
           $input_object == '' )
      { parent::setOrder($input_object); }
      else
      { throw new Exception("Provided input must be an object of class 'DB_Order' or empty string."); }
   }

   /**
   * Method to set the related DB_Cylinder object.
   * 
   * @param $input_object (DB_Cylinder|'') Input object or empty string.
   * @return void 
   */
   public function setCylinder($input_object)
   {
      if ( get_class($input_object) === 'DB_Cylinder' ||
           $input_object == '' )
      {
         parent::setCylinder($input_object);

         if ( is_object($input_object) )
         {
            $this->setCylinderSize($input_object->getSize());
            if ( $this->getCylinder()->getCheckInStatus('num') == '2' )
            {
               # When a cylinder is added to a product,
               #   default the checkin status to in calibration
               $this->getCylinder()->setCheckInStatus('3', 'num');
            } 
         }
      }
      else
      { throw new Exception("Provided cylinder must be an object of class 'DB_Cylinder'."); }
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
   *       
   */
   protected function setStatus()
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
            $sql = " SELECT num, abbr FROM product_status WHERE num = ?";
            $sqlargs = array($input_value);

            #$res = debug_backtrace();
            #echo "<PRE>";
            #print_r($res);
            #echo "</PRE>";

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
            $sql = " SELECT num, abbr FROM product_status WHERE abbr = ?";
            $sqlargs = array($input_value);

            $results = $database_object->queryData($sql, $sqlargs);

            if ( count($results) == 1 )
            {
               $this->status_num = $results[0]['num'];
               parent::setStatus($results[0]['abbr']);
            }
            elseif ( count($results) == 0 )
            { throw new UnderflowException("Status abbreviation'".$input_value."' not found."); }
            else
            { throw new UnderflowException("More than one matching status abbreviation found for '".$input_value."'."); }
         }
      }
      else
      { throw new InvalidArgumentException("Invalid type provided."); }
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
   * Method to update the status based on related information.
   *
   * @return void
   */
   private function updateStatus()
   {
      $database_object = $this->getDB();

      #  Update status based on the status of calrequest objects
      $current_status_num = $this->getStatus('num');

      $status_arr = array_values(array_unique(DB_CalRequestManager::getStatusNumsByProduct($database_object, $this)));

      if ( $this->getStatus('num') == '5' )
      {
         # Do nothing
      }
      elseif ( $this->getStatus('num') == '6' )
      {
         # Do nothing
      }
      elseif ( count($status_arr) == 0 )
      {
         # Handle the case where there are no calrequests

         if ( is_object($this->getCylinder()) )
         {
            if ( $this->getCylinder()->getStatus('num') == '3' )
            { $this->setStatus('3'); }
            else
            { $this->setStatus('4'); }
         }
         else
         { $this->setStatus('1'); }
      }
      elseif ( count($status_arr) == 1 && in_array('3', $status_arr) )
      { $this->setStatus('3', 'num'); }
      elseif ( in_array('4', $status_arr) )
      { $this->setStatus('4', 'num'); }
      elseif ( in_array('2', $status_arr) )
      { $this->setStatus('2', 'num'); }
      else
      { $this->setStatus('1', 'num'); }
   }

   /**
   * Method to set cylinder size
   *
   * There are two ways to call this method:
   *  - Syntax 1: setCylinderSize($input_value)
   *     - Set the cylinder size using $input_value. If $input_value
   *       is an integer then handle it as a relational database number.
   *       Otherwise handle it as a string. 
   *  - Syntax 2; setCylinderSize($input_value, $input_type)
   *     - Set the cylinder size using $input_type. If set to 'num' then
   *       evaluate $input_value as a relational database number.
   *       If $input_type is set to 'abbr' then evaluate
   *       $input_value as a string.
   * 
   * @param $input_value (int|string) Input value.
   * @param $input_type ('num'|'abbr') Input value type.
   * @return void
   *       
   */
   public function setCylinderSize()
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
            $this->cylinder_size_num = $results[0]['num'];
            parent::setCylinderSize($results[0]['abbr']);
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
            $this->cylinder_size_num = $results[0]['num'];
            parent::setCylinderSize($results[0]['abbr']);
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
   * Method to retrieve the cylinder size 
   *
   * There are two ways to call this method:
   *  - Syntax 1: getCylinderSize()
   *     - Retrieve the cylinder size abbreviation 
   *  - Syntax 2; getCylinderSize($input_type)
   *     - If $input_num is 'num' then retrieve the relational database
   *       number. If $input_num is 'abbr' the retrieve the
   *       abbreviation.
   * 
   * @param $input_type ('num'|'abbr') Input value type.
   * @return (integer|string|'') Returns relational database number,
   *  abbreviation string, or empty string ('').
   */
   public function getCylinderSize()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs === 0 )
      {
         return parent::getCylinderSize();
      }
      elseif ( $numargs === 1 )
      {
         if ( $args[0] === 'num' )
         {
            if ( isset($this->cylinder_size_num) &&
                 ValidInt($this->cylinder_size_num) )
            { return $this->cylinder_size_num; }
            else
            { return ''; }
         }
         elseif ( $args[0] === 'abbr' )
         {
            return parent::getCylinderSize();
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
   * Method to calculate the estimated days to process this product
   *
   * All these estimates are based on the MOU agreements. 6 wooks
   * for a cylinder that needs to be filled. Each calservice has
   * its estimated processing time.
   *
   * @return (int) Estimated processing time in days
   */
   public function calculateEstimatedProcessingDays()
   {
      $database_object = $this->getDB();

      $days = 0;

      if ( ! is_object($this->getCylinder()) ||
           $this->getCylinder()->getCheckInStatus('num') == '1' )
      {
         # Add 6 weeks for cylinders that need to be filled
         $days += 42;
      }

      $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $this);

      foreach ( $calrequest_objects as $calrequest_object )
      {
         $days += $calrequest_object->calculateEstimatedProcessingDays();
      }

      return $days;
   }

   /**
   * Method to determine if the product is active
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function isActive()
   {
      # If a product is Active(), it should not be deleted or modified
      #    but the cylinder may be filled or at NOAA DSRC for calibration
      if ( $this->getStatus('num') == '4' ||
           $this->getStatus('num') == '2' ||
           $this->getStatus('num') == '3' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if the product is a 'product extra'
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function isExtra()
   {
      if ( ! is_object($this->getOrder()) )
      { return true; }
      else
      { return false; } 
   }

   /**
   * Method to determine if the product is in processing
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function inProcessing()
   {
      # If the product is in processing or processingn complete then
      #    do not delete or modify
      if ( $this->getStatus('num') == '2' ||
           $this->getStatus('num') == '3' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method for final approval of a product
   *
   * This is used when a product has completed processing and has final
   * approval so it may be shipped
   *
   * @return void
   */
   public function readyToShip()
   {
      if ( $this->getStatus('num') != '3' )
      { throw new Exception ("Product processing must be complete before it may be marked as ready to ship."); }

      $this->setStatus('6', 'num');

      if ( is_object($this->getCylinder()) )
      { $this->getCylinder()->readyToShip(); }
   }

   /**
   * Method to start processing a product
   *
   * This is used when a product is pending and needs to begin processing.
   * This also updates the related DB_Order to processing as well.
   *
   * @return void
   */
   public function process()
   {
      if ( $this->getStatus('num') == '5' )
      {
         $this->setStatus('1', 'num');

      }
      else
      {
         # Do nothing
         # The product is already processing
      }

      if ( is_object($this->getOrder()) )
      { $this->getOrder()->process(); }
   }

   /**
   * Method to determine if the product is pending
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal. 
   */
   public function isPending()
   {
      if ( $this->getStatus('num') == '5' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to retrieve all analyzes results from the database
   *
   * This method calls /ccg/bin/reftank to retrieve the results. Please
   * contact Kirk Thoning (kirk.thoning@noaa.gov) for questions.
   *
   * @return (array) Array of results
   */
   private function getAllAnalyzes()
   {
      if ( ! is_object($this->getCylinder()) )
      { throw new Exception ("Cylinder information is necessary to retrieve calibrations data."); }

      $cmd = escapeshellcmd('/ccg/bin/reftank');

      $args = array();

      array_push($args, escapeshellarg($this->getCylinder()->getID()));

      $res = '';
      exec($cmd.' '.join(' ', $args), $res);

      #echo $cmd.' '.join(' ', $args)."<BR>";

      return ($res);
   }

   /**
   * Method to create an analysis certificate or report
   *
   * This method calls make_calibration_certificate.php  or
   * make_report_of_analysis.php to to generate an
   * analysis document that may be sent to the customer.
   *
   * @param $input_user_object (DB_User) User object.
   * @return void
   */
   public function makeAnalysisDocuments(DB_User $input_user_object)
   {
      if ( $this->getStatus('num') == '6' || true)#!!! removing status filter per users request.  They will decide to send when ready, but want to be able to create on demand.
      {
         if ( ! ValidInt($this->getNum()) )
         { throw new Exception("Error creating analysis documents. Not a database product."); }

         $database_object = $this->getDB();

         $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $this);

         #
         # Determine which documents need to be made based on if the analysis value
         #  is within the reference scale span
         #
         $make_certificate_of_analysis = 0;
         $make_report_of_analysis = 0;

         foreach ( $calrequest_objects as $calrequest_object )
         {
            # Only put the analysis on a certificate or report if there is a
            #  valid analysis value 
            if ( ValidFloat($calrequest_object->getAnalysisValue()) )
            {
               list($reference_scale_span_min, $reference_scale_span_max) = split(',',$calrequest_object->getCalService()->getReferenceScaleSpan($calrequest_object->getAnalysisReferenceScale()));
               #var_dump($calrequest_object->getAnalysisValue());var_dump($reference_scale_span_min);var_dump($reference_scale_span_max);exit;
               	if($reference_scale_span_min!=$reference_scale_span_max){#Only do reports/certs if we have a scale range
			if ( $calrequest_object->getAnalysisValue() >= $reference_scale_span_min && $calrequest_object->getAnalysisValue() <= $reference_scale_span_max ){ 
				$make_certificate_of_analysis++; 
			}else{ 
				$make_report_of_analysis++; 
			}
		}
            }
         }

         $productnum = $this->getNum();
         $usernum = $input_user_object->getNum();

         #
         #####################
         # Make certificate of analysis
         #####################
         #
         if ( $make_certificate_of_analysis > 0 )
         {
            #$script = 'make_certificate_of_analysis.php';
            $script = 'make_analysis_documents2.php';
            $certificate_number = $this->getCylinder()->getID().'-'.$this->getFillCode();

            # I am not sure why I could not get these to work together so I separated
            # them into two preg_replace statements
            $certificate_number = preg_replace('/[\\\]/', '', $certificate_number);
            $certificate_number = preg_replace('/[\/\:\*\?"<>|\s]/', '', $certificate_number);

            # Make the footer HTML file
            $footerfile = 'documents/'.$certificate_number.'_'.date('Y-m-d-His').'_P'.$productnum.'_footer.html';
            $footerHTML="<!doctype html>
                <html>
                <head>
                    <meta charset='utf-8'>
                    <script>
                        function substitutePdfVariables() {

                            function getParameterByName(name) {
                                var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
                                return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
                            }

                            function substitute(name) {
                                var value = getParameterByName(name);
                                var elements = document.getElementsByClassName(name);

                                for (var i = 0; elements && i < elements.length; i++) {
                                    elements[i].textContent = value;
                                }
                            }

                            ['frompage', 'topage', 'page', 'webpage', 'section', 'subsection', 'subsubsection']
                                .forEach(function(param) {
                                    substitute(param);
                                });
                        }
                    </script>
                </head>
                <body onload='substitutePdfVariables()'>
                <p><span style='float:left;text-align:left; font-size:10pt; font-family:\"Times\"; color:red;'>".$certificate_number."</span>&nbsp;&nbsp;<span style='float:right;font-size:8pt; font-family:\"Times\";text-align:right;'>Page <span class='page'></span> of <span class='topage'></span></span></p>
                </body>
                </html>";
            file_put_contents($footerfile, $footerHTML);#"<DIV style='text-align:left; font-size:10pt; font-family:\"Times\"; color:red;'>".$certificate_number."</DIV>");

            # Make the HTML file
            $htmlfile = 'documents/'.$certificate_number.'_'.date('Y-m-d-His').'_P'.$productnum.'.html';
            system(escapeshellcmd("/usr/bin/php $script")." ".escapeshellarg($productnum)." ".escapeshellarg($usernum)." cert > ".escapeshellarg("$htmlfile"), $return_status);
            if ( $return_status != '0' )
            { throw new Exception("Error creating HTML version of certificate of analysis.  Error:$return_status."); }

            # Now make the PDF

            # Please see the following documentation for the reasoning behind the
            #  call to wkhtmltopdf
            #
            # http://www.gnetconsulting.com/use-wkhtmltopdf-save-pdf-without-image-quality-loss-chopiness/
            # https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1527
            # http://blog.gluga.com/2012/05/wkhtmltopdf-font-and-sizing-issues.html
            $pdffile = preg_replace("/\.html$/", ".pdf", $htmlfile);
            system(escapeshellcmd("/usr/local/bin/wkhtmltopdf")." --margin-bottom 25 --margin-top 20 --zoom 1.35 --footer-html ".escapeshellarg($footerfile).' '.escapeshellarg("$htmlfile").' '.escapeshellarg("$pdffile"), $return_status);

            if ( ! file_exists("$pdffile") )
            { throw new Exception("Error creating PDF version of certificate of analysis.");
	    }else{#NOT FINISHED.  need to add to report logic below and then test, make sure what happens when file already exists.
		#Make a copy on shared drive
		#system("cp $pdffile /ccg/refgas/rgm_cert-rep/");
	    } 
         }

         #
         #####################
         # Make report of analysis
         #####################
         #
         if ( $make_report_of_analysis > 0 )
         {
            $script = 'make_analysis_documents2.php';
            $report_number = $this->getCylinder()->getID().'-'.$this->getFillCode().'_ROA';

            # I am not sure why I could not get these to work together so I separated
            # them into two preg_replace statements
            $report_number = preg_replace('/[\\\]/', '', $report_number);
            $report_number = preg_replace('/[\/\:\*\?"<>|\s]/', '', $report_number);

            # Make the footer HTML file
            $footerfile = 'documents/'.$report_number.'_'.date('Y-m-d-His').'_P'.$productnum.'_footer.html';
	    
            file_put_contents($footerfile,"<DIV style='text-align:left; font-size:10pt; font-family:\"Times\"; color:red;'>".$report_number."</DIV>");

            # Make the HTML file
            $htmlfile = 'documents/'.$report_number.'_'.date('Y-m-d-His').'_P'.$productnum.'.html';
            system(escapeshellcmd("/usr/bin/php $script")." ".escapeshellarg($productnum)." ".escapeshellarg($usernum)." report > ".escapeshellarg("$htmlfile"), $return_status);

            if ( $return_status != '0' )
            { throw new Exception("Error creating HTML version of report of analysis."); }

            # Now make the PDF
            #
            # Please see the following documentation for the reasoning behind the
            #  call to wkhtmltopdf
            #
            # http://www.gnetconsulting.com/use-wkhtmltopdf-save-pdf-without-image-quality-loss-chopiness/
            # https://github.com/wkhtmltopdf/wkhtmltopdf/issues/1527
            # http://blog.gluga.com/2012/05/wkhtmltopdf-font-and-sizing-issues.html
            $pdffile = preg_replace("/\.html$/", ".pdf", $htmlfile);
            system(escapeshellcmd("/usr/local/bin/wkhtmltopdf")." --margin-bottom 25 --margin-top 20 --zoom 1.35 --footer-html ".escapeshellarg($footerfile).' '.escapeshellarg("$htmlfile").' '.escapeshellarg("$pdffile"), $return_status);

            if ( ! file_exists("$pdffile") )
            { throw new Exception("Error creating PDF version of report of analysis."); }
         }
      }
      else
      { throw new Exception("Calibrations must be completed before an analysis document can be made."); }
   }

   /**
   * Method to get all the analysis documents generated for this product
   *
   * JWM - 9/17.  Note; I needed a way to get the list of analysis docs and initially used this method, but the overhead was too slow (loading all the objects) for this use, so I just programmed
   * it to fetch the product nums from db and look for certs using below logic.  If that logic changes be sure to update this method too.
   * j/lib/orders_funcs.php -> ord_getCertificateFiles()
   * @return (array) Array of matching files
   */
   public function getAnalysisDocuments()
   {
      $files = array();

      if ( ValidInt($this->getNum()) )
      {
         # We search based on the product number
         $target = "documents/*_P".$this->getNum().".pdf";

         $files = glob($target);
      }

      return ($files);
   }

   /**
   * Method to deterimine Period of Analysis
   *
   * This method calls DB_CalRequest::getLastAnalysisFromDB()
   * for each related DB_CalRequest and determines the most
   * recent one
   *
   * @return (string) Last analysis string
   */
   public function getLastAnalysisFromDB()
   {
      $database_object = $this->getDB();

      $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $this);

      $lastdatearr = array();
      foreach ( $calrequest_objects as $calrequest_object )
      {
         $lastdate = $calrequest_object->getLastAnalysisFromDB();

         if ( ValidDate($lastdate) )
         { array_push($lastdatearr, $lastdate); }
      }

      if ( count($lastdatearr) > 0 )
      {
         $lastdate = max($lastdatearr);

         #echo "$mindate $lastdate<BR>";

         list($lastyr, $lastmo, $lastdy) = preg_split('/\-/', $lastdate, 3);

         $lastmoname = date("F", mktime(0, 0, 0, $lastmo, 10));

         return ($lastmoname.' '.$lastyr);
      }
      else
      {
         return ("Not enough information to calculate.");
      }
   }

   /**
   * Method to run checks before saving to the database.
   *
   * This can be useful to evaluate checks to make sure all
   *  appropriate information has been provided. For
   *  example, making sure that a cylinder is available for
   *  filling before assigning it to be refilled
   *
   * @return void
   */
   public function preSaveToDB()
   {
      $this->updateStatus();

      $database_object = $this->getDB();

      # Check Cylinder information
      $cylinder_object = $this->getCylinder();

      if ( is_object($cylinder_object) )
      {
         if ( $cylinder_object->getCheckInStatus('num') == 1 && 
              ! $cylinder_object->isFillable() )
         {
            throw new Exception("Unable to assign cylinder '".$cylinder_object->getID()."' to be filled or refilled as it is an ".$cylinder_object->getType()." cylinder.");
         }
         elseif ( ! $this->isPending() )
         {
            # If the cylinder is retired, do not allow it to be added to an order
            if ( $cylinder_object->isRetired() )
            {
               throw new Exception("Cylinder '".$cylinder_object->getID()."' is retired and may not be added to an order. <A href='cylinder_edit.php?id=".urlencode($cylinder_object->getID())."&action=update'><BR><INPUT type='button' value='Update Cylinder ".htmlentities($cylinder_object->getID(), ENT_QUOTES, 'UTF-8')."'>");
            }

            # Make sure this cylinder is associated with this product
            #    or no active products if this is a new product

            $product_objects = DB_ProductManager::searchByCylinder($database_object, $cylinder_object);

            $cylinder_available = true;
            foreach ( $product_objects as $product_object )
            {
               if ( ( is_object($product_object->getOrder()) &&
                      $product_object->getOrder()->isActive() ) ||
                      $product_object->isExtra() )
               {
                  if ( ! $product_object->matches($this) )
                  { $cylinder_available = false; }
                  break;
               }
            }
   
            if ( ! $cylinder_available )
            { throw new Exception("Cylinder '".$cylinder_object->getID()."' is already assigned to an active order/product."); } 
         }
      }

      # Check Order information
      if ( is_object($this->getOrder()) )
      {
         if ( $this->isPending() &&
              ! $this->getOrder()->isPending() )
         { throw new Exception("Pending products may only be added to pending orders"); }
         elseif ( ! $this->isPending() &&
               $this->getOrder()->isPending() )
         { throw new Exception("Processing products may only be added to processing orders"); }
      }

      if ( ValidInt($this->getNum()) )
      {
         $db_product_object = new DB_Product($database_object, $this->getNum());

         if ( $db_product_object->isExtra() &&
              ! $this->isExtra() )
         {
            # Make sure the new order is in processing
            if ( ! $this->isPending() &&
                 ( ! is_object($this->getOrder()) ||
                   ! $this->getOrder()->isProcessing() ) )
            { throw new Exception ("Product extras may only be added to processing orders."); }
         }
      }
   }

   /**
   * Method to save to the database
   *
   * This method is the only way to save a DB_Product to
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
      $this->updateStatus();

      $this->preSaveToDB();

      #
      # While the product is processing keep getting the last
      #   fill code so that we may retrieve the correct analyzes
      #
      if ( $this->getStatus('num') == '2' &&
           is_object($this->getCylinder()) )
      {
         $last_fill_code = $this->getCylinder()->getLastFillCodeFromDB(); 

         if ( $last_fill_code != '' )
         { $this->setFillCode($last_fill_code); }
         else
         { $this->setFillCode('A'); }
      }

      #
      # If we are in processing complete and the fill code
      #  is not set yet then set it
      #
      if ( $this->getFillCode() == '' &&
           $this->getStatus('num') == '3' &&
           is_object($this->getCylinder()) )
      {
         $last_fill_code = $this->getCylinder()->getLastFillCodeFromDB(); 

         if ( $last_fill_code != '' )
         { $this->setFillCode($last_fill_code); }
         else
         { $this->setFillCode('A'); }
      }

      $database_object = $this->getDB();

      $sqlaarr = array();

      # Save the information where we have it
      if ( is_object($this->getOrder()) )
      { $sqlaarr['order_num'] = $this->getOrder()->getNum(); }
      else
      { $sqlaarr['order_num'] = '0'; }

      if ( is_object($this->getCylinder()) )
      { $sqlaarr['cylinder_num'] = $this->getCylinder()->getNum(); }
      else
      { $sqlaarr['cylinder_num'] = 0; }

      if ( $this->getFillCode() != '' )
      { $sqlaarr['fill_code'] = $this->getFillCode(); }

      $sqlaarr['cylinder_size_num'] = $this->getCylinderSize('num');
      $sqlaarr['product_status_num'] = $this->getStatus('num');
      $sqlaarr['comments'] = $this->getComments();

      if ( ValidInt($this->getNum()) )
      {
         # UPDATE
         $db_product_object = new DB_Product($database_object, $this->getNum());

         if ( ! $this->equals($db_product_object) )
         {
            $setarr = array();
            $sqlargs = array();
            foreach ( $sqlaarr as $key=>$value )
            {
               array_push($setarr, "$key = ?");
               array_push($sqlargs, $value);
            }

            $sql = " UPDATE product SET ".join(', ', $setarr)." WHERE num = ? LIMIT 1";
            array_push($sqlargs, $this->getNum());

            #print $sql."<BR>"; 
            #print join(',', $sqlargs)."<BR>";

            $database_object->executeSQL($sql, $sqlargs);

            #Log::update($input_user_object->getUsername(), '(UPDATE NEW) '.$this->diffToString($db_product_object).' '.$this->__toString());
            #jwm - 1/17 - updating log output
            Log::update($input_user_object->getUsername(), '(DB_Product: update) product.num:'.$this->getNum().' '.$this->diffToString($db_product_object).' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs));
            

            #echo "<PRE>";
            #var_dump(debug_backtrace());
            #echo "</PRE>";

            #
            # If this product was an extra and is now being assigned to an order
            #  then reset the status of the calrequests
            #
            if ( ( $db_product_object->isExtra() &&
                   ! $this->isExtra() )
                 ||
                 ( is_object($db_product_object->getCylinder()) &&
                   ! is_object($this->getCylinder()) ) 
                 ||
                 ( ! is_object($db_product_object->getCylinder()) &&
                   is_object($this->getCylinder()) ) )
            {
               $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $this);

               foreach ( $calrequest_objects as $calrequest_object )
               {
                  # Only reset the status if the calrequest is not pending
                  if ( ! $calrequest_object->isPending() )
                  { $calrequest_object->resetStatus(); }
                  $calrequest_object->saveToDB($input_user_object);
               }
            }

            # If this product was not an extra and is now an extra, we need to
            # save the order to update the status
            if ( ! $db_product_object->isExtra() &&
                 $this->isExtra() )
            {
               if ( is_object($db_product_object->getOrder()) )
               { $db_product_object->getOrder()->saveToDB($input_user_object); }
            }

            # If the product changed from pending to not pending then
            #   update all related calrequests to be not pending

            if ( $db_product_object->isPending() &&
                 ! $this->isPending() )
            {
               $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $this);
      
               foreach ( $calrequest_objects as $calrequest_object )
               {
                  $calrequest_object->process();
                  $calrequest_object->saveToDB($input_user_object);
               }
            }
         }
      }
      else
      {
         # INSERT
         #JWM - 1/17 - Note this only gets called on insert without a clyinder.  I couldn't trace down how a insert with
         #cylinder actually gets inserted?!?  I gave up looking after 20 min to finish what I was working on.
         
         $sql = " INSERT INTO product (".join(', ', array_keys($sqlaarr)).") VALUES (".join(', ', array_fill('0', count(array_values($sqlaarr)), '?')).")";

         $sqlargs = array_values($sqlaarr);

         #print $sql."<BR>"; 
         #print join(',', $sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);
         
         $sql2 = " SELECT LAST_INSERT_ID()";
         $res = $database_object->queryData($sql2);
         $this->setNum($res[0][0]);
         
         $logtext='(DB_Product: insert) product.num:'.$res[0][0].' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs);
         
         #Log::update($input_user_object->getUsername(), '(INSERT) '.$this->__toString());
         #jwm - 1/17 - updating log output
         Log::update($input_user_object->getUsername(), '(DB_product: insert) '.$logtext); 
      }

      if ( is_object($this->getCylinder()) )
      { $this->getCylinder()->saveToDB($input_user_object); }

      if ( is_object($this->getOrder()) )
      { $this->getOrder()->saveToDB($input_user_object); }

      # Load the information in the database to this instance so that
      #  they match. This is if the status is updated in particular
      $this->loadFromDB();
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

      $sql = " SELECT order_num, cylinder_num, fill_code, cylinder_size_num, product_status_num, comments FROM product WHERE num = ?";

      $sqlargs = array($this->getNum());
      $res = $database_object->queryData($sql, $sqlargs);

      # Throw errors if we get more or less than one result
      if ( count($res) == 0 )
      { throw new Exception("No matching records found in database."); } 
      elseif ( count($res) > 1 )
      { throw new Exception("Too many matching records found in database."); }

      $this->setCylinderSize($res[0]['cylinder_size_num']);

      # The status needs to be set before setOrder()
      $this->setStatus($res[0]['product_status_num']);

      # Try to set the order
      try
      {
         $order_obj = new DB_Order($database_object, $res[0]['order_num']);
         $this->setOrder($order_obj);
      }
      catch ( Exception $e )
      { }

      # Try to set the cylinder
      try
      {
         $cylinder_obj = new DB_Cylinder($database_object, $res[0]['cylinder_num']);
         $this->setCylinder($cylinder_obj);
      }
      catch ( Exception $e )
      { }

      # Try to set the fill code
      try
      { $this->setFillCode($res[0]['fill_code']); }
      catch ( Exception $e )
      { }

      $this->setComments($res[0]['comments']);
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
      if ( $this->getStatus('num') == '2' )
      { throw new Exception ("Cannot delete product in progress."); }

      if ( ! ValidInt($this->getNum()) )
      { throw new Exception ("Number must be set to load from database."); }

      $database_object = $this->getDB();

      # Find all related CalRequests and delete them
      $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $this);

      foreach ( $calrequest_objects as $calrequest_object )
      {
         $calrequest_object->deleteFromDB($input_user_object);
      }

      # Delete the product entry
      $sql = " DELETE FROM product WHERE num = ? LIMIT 1";
      $sqlargs = array($this->getNum());

      $database_object->executeSQL($sql, $sqlargs);

      #Log::update($input_user_object->getUsername(), '(DELETE) '.$this->__toString());
      #jwm - 1/17 - chaning log output
      Log::update($input_user_object->getUsername(), '(DB_Product: delete) product.num:'.$this->getNum().' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs)); 

      #
      # Change the check in status after the product has been deleted
      #  because DB_Cylinder->saveToDB() finds related Products
      #
      # This should eventually be put within DB_Cylinder as status
      #  updates should be encapsulated
      $cylinder_object = $this->getCylinder();
      if ( is_object($cylinder_object) )
      {
         $cylinder_object->setCheckInStatus('2', 'num');

         if ( $cylinder_object->getStatus('num') == '1' ||
              $cylinder_object->getStatus('num') == '3' ||
              $cylinder_object->getStatus('num') == '4' )
         {
            $cylinder_object->setStatus('2', 'num');
         }
         $cylinder_object->saveToDB($input_user_object);
      }

      # Unset the information to match the database
      $this->setNum('');

      if ( is_object($this->getOrder()) )
      { $this->getOrder()->saveToDB($input_user_object); }
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
   public function equals($input_object)
   {
      if ( parent::equals($input_object) &&
           $this->getNum() == $input_object->getNum() &&
           $this->getStatus('num') == $input_object->getStatus('num') &&
           $this->getCylinderSize('num') == $input_object->getCylinderSize('num') )
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
   public function matches($input_object)
   {
      if ( $this->getNum() == $input_object->getNum() &&
           parent::matches($input_object) )
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
   * Method to determine the differences between a given object and this one.
   *
   * This is primarily used when creating a log entry so that an user
   *  can quickly determine where to look for differences.
   *
   * @return (string) A string of variable names where the information
   *  has been updated.
   */
   public function diffToString(DB_Product $input_product_object)
   {
      $diff_arr = array();

      if ( $this->getNum() !== $input_product_object->getNum() )
      { array_push($diff_arr, 'num'); } 

      if ( is_object($this->getOrder()) )
      {
         if ( is_object($input_product_object->getOrder()) )
         {
            # Both are objects
            if ( ! $this->getOrder()->equals($input_product_object->getOrder()) )
            { array_push($diff_arr, 'order'); }
         }
         else
         {
            # One is object and the other is not
            array_push($diff_arr, 'order'); 
         }
      }
      else
      {
         if ( is_object($input_product_object->getOrder()) )
         {
            # One is object and the other is not
            array_push($diff_arr, 'order');
         }
         else
         {
            # Both are not objects
            # Do nothing
         }
      }

      if ( is_object($this->getCylinder()) )
      {
         if ( is_object($input_product_object->getCylinder()) )
         {
            # Both are objects
            if ( ! $this->getCylinder()->equals($input_product_object->getCylinder()) )
            { array_push($diff_arr, 'cylinder'); }
         }
         else
         {
            # One is object and the other is not
            array_push($diff_arr, 'cylinder');
         }
      }
      else
      {
         if ( is_object($input_product_object->getCylinder()) )
         {
            # One is object and the other is not
            array_push($diff_arr, 'cylinder');
         }
         else
         {
            # Both are not objects
            # Do nothing
         }
      }

      if ( $this->getFillCode() !== $input_product_object->getFillCode() )
      { array_push($diff_arr, 'fill_code'); }

      if ( $this->getStatus('num') !== $input_product_object->getStatus('num') )
      { array_push($diff_arr, 'status'); }

      if ( $this->getCylinderSize() !== $input_product_object->getCylinderSize() )
      { array_push($diff_arr, 'cylinder_size'); }

      if ( $this->getComments() !== $input_product_object->getComments() )
      { array_push($diff_arr, 'comments'); }

      $str = 'No differences found.';
      if ( count($diff_arr) > 0 )
      {
         $str = " The following information has been updated: ".join(', ', $diff_arr).".";
      }

      return($str);
   }
}
