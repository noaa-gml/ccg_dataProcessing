<?PHP

require_once ("Log.php");
require_once ("EmailLog.php");
require_once ("Order.php");
require_once ("DB_Customer.php");
require_once ("DB_ProductManager.php");
require_once ("DB_OrderManager.php");
require_once ("DB_CylinderManager.php");
require_once ("DB_CalRequestManager.php");
require_once ("/var/www/Swift/lib/swift_required.php");

/**
* Database order class for order details and related customers.
*
* This class extends Order to handle database interactions and relational numbers.
*/

class DB_Order extends Order
{
   /** Relational database number */
   private $num;

   /** Related DB object */
   private $database_object;

   /** Status relational database number. Related to database table 'order_status' */
   private $status_num;

   /**
   * Constructor method to instantiate a DB_Order object
   *
   * There are two ways to call this method.
   *  - Syntax 1: new DB_Order($input_database_object, $input_num)
   *     - Instantiates a DB_Order based on relational database number
   *       The related information will be loaded from the provided database.
   *  - Syntax 2: new DB_Order($input_database_object, $input_due_date)
   *     - Instantiates a DB_Order based on information provided.
   *
   * @param $input_database_object (DB) Database object
   * @param $input_num (int) DB_Order relational database number.
   * @param $input_due_date (string) Order due date. Format 'YYYY-MM-DD'.
   * @return (DB_Order) Instantiated object
   */
   public function __construct()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 2 )
      {
         if ( ValidInt($args[1]) )
         {
            $this->setDB($args[0]);
            $this->setNum($args[1]);
            $this->loadFromDB();
         }
         else
         {
            parent::__construct($args[1]);
            $this->setDB($args[0]);
            $this->setStatus('8');
         }
      }
      else
      { throw new Exception("Invalid number of arguments passed in instantiating DB_Order."); }
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
   * If the number is set to '' then it is considered a new DB_Order
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
   * If the number is '' then it is considered a new DB_Order
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
            $sql = " SELECT num, abbr FROM order_status WHERE num = ?";
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
            $sql = " SELECT num, abbr FROM order_status WHERE abbr = ?";
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
      # Order status 5 is set by complete()
      # Order status 7 is set by cancel()

      $current_status_num = $this->getStatus('num');

      if ( $current_status_num == '5' ||
           $current_status_num == '7' )
      { return; }

      $database_object = $this->getDB();

      $product_status_arr = array_values(array_unique(DB_ProductManager::getStatusNumsByOrder($database_object, $this)));

      if ( $this->getStatus('num') == '8' )
      {
         # Do nothing
      }
      elseif ( count($product_status_arr) == 1 &&
           in_array('6', $product_status_arr) )
      {
         # If all of the related products are marked as 'ready to ship' then
         #  the order is 'ready to ship'
         $this->setStatus('6');
      }
      elseif ( count($product_status_arr) > 0 &&
               count(array_diff($product_status_arr, array('3', '6'))) == 0 )
      {
         # If substracting array('3', '6') from $product_status_arr results
         #  in an empty array that means that $product_status_arr only
         #  consists of elements that are '3' or '6'
         $this->setStatus('4');
      }
      elseif ( in_array('2', $product_status_arr) )
      { $this->setStatus('3'); }
      elseif ( count($product_status_arr) > 0 )
      { $this->setStatus('2'); }
      else
      { $this->setStatus('1'); }
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
      $days = 0;

      $database_object = $this->getDB();

      $product_objects = DB_ProductManager::searchByOrder($database_object, $this);

      foreach ( $product_objects as $product_object )
      {
         $days += $product_object->calculateEstimatedProcessingDays();
      }

      #echo "DAYS: $days";

      return $days;
   }

   /**
   * Method to calculate the estimated due date to process this order
   *
   * Call calculateEstimatedProcessingDays() and adds that to the
   * input date or creation datetime to estimate due date.
   *
   * @param $input_due_date (string) Input start date. Format 'YYYY-MM-DD'.
   * @return void
   */
   public function calculateDueDate()
   {
      $args = func_get_args();
      $numargs = func_num_args();

      if ( $numargs == 1 )
      {
         # Use the input date
         $input_date = $args[0];
         if ( ! ValidDate($input_date) )
         { throw new Exception ("Provided date '$input_date' is invalid."); }
      }
      else
      {
         # Otherwise, use the order creation date
         if ( ! ValidDatetime($this->getCreationDatetime()) )
         { throw new Exception ("Creation datetime not set."); }

         list($input_date, $input_time) = split (' ', $this->getCreationDatetime(), 2);
      }

      list($year, $month, $day) = split('-', $input_date, 3);
      $day_of_week = date('w', mktime(0, 0, 0, $month, $day+$this->calculateEstimatedProcessingDays(), $year));

      # Make sure the due date does not fall on Saturday or Sunday
      if ( $day_of_week == 0 )
      {
         # Sunday
         $add_days = 1;
      }
      elseif ( $day_of_week == 6 )
      {
         # Saturday
         $add_days = 2;
      }
      else
      { $add_days = 0; }

      # Calculate the new due date and set it
      $due_date = date('Y-m-d', mktime(0, 0, 0, $month, $day+$this->calculateEstimatedProcessingDays()+$add_days, $year));

      #echo "DATE: $due_date";
      $this->setDueDate($due_date);
   }

   /**
   * Method to complete an order
   *
   * An order may only be completed if it is 'ready to ship'
   *
   * @return void
   */
   public function complete()
   {
      if ( $this->getStatus('num') == '6' )
      {
         $this->setStatus('5', 'num');
      }
      else
      { throw new Exception("Order may only be completed after it has been marked 'ready to ship'."); }
   }

   /**
   * Method to cancel an order
   *
   * An order may not be cancelled that is completed
   *
   * @return void
   */
   public function cancel()
   {
      if ( $this->getStatus('num') != '5' )
      {
         $this->setStatus('7', 'num');
      }
      else
      { throw new Exception("Order must not be complete or shipped to be cancelled."); }
   }

   /**
   * Method to set primary Customer object
   *
   * @param $input_object (Customer) Customer object.
   * @return void
   */
   public function setPrimaryCustomer($input_object)
   {
      if ( get_class($input_object) === 'DB_Customer' )
      { parent::setPrimaryCustomer($input_object); }
      else
      { throw new Exception("Provided input must be object of class 'DB_Customer'."); }
   }

   /**
   * Method to add an additional related customer
   *
   * @param $input_object (Customer) Customer object.
   * @return void
   */
   public function addCustomer($input_object)
   {
      if ( get_class($input_object) === 'DB_Customer' )
      { parent::addCustomer($input_object); }
      else
      { throw new Exception("Provided input must be object of class 'DB_Customer'."); }
   }

   /**
   * Method to set array of related additional customers
   *
   * @param $input_objects (array) Array of Customer objects.
   * @return void
   */
   public function setCustomers($input_objects = array())
   {
      parent::setCustomers();

      $tmp_objects = array();
      foreach ( $input_objects as $input_object )
      { $this->addCustomer($input_object); }
   }

   /**
   * Method to set Location where order will be shipped to
   *
   * @param $input_object (Location) Shipment Location.
   * @return void
   */
   public function setShippingLocation($input_object)
   {
      if ( get_class($input_object) === 'DB_Location' )
      { parent::setShippingLocation($input_object); }
      else
      { throw new Exception("Provided input must be object of class 'DB_Location'."); }
   }

   /**
   * Method to email documents to related customers
   *
   * Documents include calibration certificates and shipping documents.
   *
   * @return void
   */
   public function emailDocuments()
   {
      #
      # This method is to address the case where the order has been completed
      #   but new calibration certificates have been created.
      #

      if ( $this->getStatus('num') != '5' )
      { throw new Exception("May only email documents once the order is completed."); }

      $input_subject = 'New documents available.';

      # This has been turned off and waiting redesign
      # $this->emailCustomers($input_subject);

   }

   /**
   * Method to email related customers
   *
   * @todo This has been turned off and waiting redesign
   * Currently this has been turned off and is waiting for redesign. Having
   * e-mails sent automatically to customers is no longer desired.
   *
   * This is the main method to e-mail customers so that it is standardized
   * @return void
   */
   private function emailCustomers($input_subject)
   {
      return true;
      $database_object = $this->getDB();

      if ( isBlank($input_subject) )
      { throw new Exception('E-mail subject must be provided.'); }

      $status_aarr = DB_OrderManager::getOrderStatusSequence($database_object);

      #echo "<PRE>";
      #print_r($order_object);
      #print_r($status_aarr);
      #echo "</PRE>";

      $body = "";
      $body .= "<HTML>\n";
      $body .= " <HEAD>\n";
      $body .= " </HEAD>\n";
      $body .= " <BODY>\n";
      $body .= "  <A href='https://omi.cmdl.noaa.gov/rgm/customer_view.php?order=".DB_OrderManager::encodeString($this->getNum())."'>View real time status</A>";

      if ( $this->getStatus('num') == '5' )
      {
         $calibration_certificates = $this->getAnalysisDocuments();

         if ( count($calibration_certificates) > 0 )
         { $body .= " <H4>Please find the analysis certificates and reports attached.</H4>"; }
      }
      $body .= "  <TABLE cellspacing='3' cellpadding='3'>\n";
      $body .= "   <TR>\n";
      $body .= "    <TD>\n";
      $body .= "     <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
      $body .= "      <TR>\n";
      $body .= "       <TH colspan='2'>Order Details</TH>\n";
      $body .= "      </TR>\n";
      $body .= "      <TR>\n";
      $body .= "       <TD>Creation Date & Time</TD>\n";
      $body .= "       <TD>\n";
      $body .= $this->getCreationDatetime();
      $body .= "       </TD>\n";
      $body .= "      </TR>\n";
      $body .= "      <TR>\n";
      $body .= "       <TD>Due Date</TD>\n";
      $body .= "       <TD>\n";
      $body .= $this->getDueDate();
      $body .= "       </TD>\n";
      $body .= "      </TR>\n";
      $body .= "      <TR>\n";
      $body .= "       <TD>MOU number</TD>\n";
      $body .= "       <TD>\n";
      $body .= $this->getMOUNumber();
      $body .= "       </TD>\n";
      $body .= "      </TR>\n";
      $body .= "      <TR>\n";
      $body .= "       <TD>Primary Customer</TD>\n";
      $body .= "       <TD>\n";

      if ( is_object($this->getPrimaryCustomer()) )
      { $body .= $this->getPrimaryCustomer()->getEmail(); }

      $body .= "       </TD>\n";
      $body .= "      </TR>\n";
      $body .= "      <TR>\n";
      $body .= "       <TD>Additional Customers</TD>\n";
      $body .= "       <TD>\n";
      foreach ( $this->getCustomers() as $customer_object )
      {
         $body .= $customer_object->getEmail();
         $body .= "<BR>\n";
      }
      $body .= "       </TD>\n";
      $body .= "      </TR>\n";
      $body .= "    </TABLE>\n";
      $body .= "   </TD>\n";
      $body .= "  </TR>\n";
      $body .= "  <TR>\n";
      $body .= "   <TD>\n";
      $body .= "    <TABLE border='1' cellpadding='3' cellpadding='3'>\n";
      $body .= "     <TR>\n";
      $body .= "      <TH colspan='2'>Order Status</TH>\n";
      $body .= "     </TR>\n";

      if ( in_array($this->getStatus('num'), array_keys($status_aarr)) )
      {
         $match = 0;
         foreach ( $status_aarr as $status_num=>$status_abbr )
         {
            $body .= "<TR>\n";
            if ( $match == 0 )
            { $body .= "  <TD><FONT style='color:green'>Complete</FONT></TD>"; }
            else
            { $body .= "  <TD></TD>"; }

            $body .= "  <TD>$status_abbr</TD>\n";
            $body .= " </TR>\n";

            if ( $status_num == $this->getStatus('num') )
            { $match = 1; }
         }
      }
      else
      {
         $body .= " <TR>\n";
         $body .= "  <TD>";
         $body .= "   <DIV style='color:blue'>\n";
         $body .= $this->getStatus('abbr');
         $body .= "   </DIV>\n";
         $body .= "  </TD>\n";
         $body .= " </TR>\n";
      }

      $body .= "     </TABLE>\n";
      $body .= "    </TD>\n";
      $body .= "   </TR>\n";

      $product_objects = DB_ProductManager::searchByOrder($database_object, $this);

      if ( count($product_objects) > 0 )
      {
         $body .= "   <TR>\n";
         $body .= "    <TD>\n";
         $body .= "     <TABLE border='1' cellpadding='3' cellpadding='3'>\n";
         $body .= "      <TR>\n";
         $body .= "       <TD>\n";
         $body .= "        <TABLE border='1' cellpadding='3' cellpadding='3'>\n";
         $body .= "         <TR>\n";
         $body .= "          <TH>Cylinder ID</TH>\n";
         $body .= "          <TH>Analysis Details</TH>\n";
         $body .= "         </TR>\n";

         foreach ( $product_objects as $product_object )
         {
            $body .= "<TR>";
            $body .= " <TD>";
            $cylinder_object = $product_object->getCylinder();

            if ( is_object($cylinder_object) )
            {
               $body .= htmlentities($cylinder_object->getID(), ENT_QUOTES, 'UTF-8');
            }
            else
            {
               $body .= "Unassigned";
            }
            $body .= " </TD>";
            $body .= " <TD>";

            $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

            if ( count($calrequest_objects) > 0 )
            {
               $body .= "  <TABLE border='1' cellspacing='3' cellpadding='3'>";
               $body .= "   <TR>";
               $body .= "    <TH>Specie</TH>";
               $body .= "    <TH>Target Value</TH>";
               $body .= "    <TH>Analysis Type</TH>";
               $body .= "   </TR>";

               foreach ( $calrequest_objects as $calrequest_object )
               {
                  $body .= "   <TR>";
                  $body .= "    <TD>";
                  $body .= $calrequest_object->getCalService()->getAbbreviationHTML();
                  $body .= "    </TD>";
                  $body .= "    <TD>";
                  $body .= htmlentities($calrequest_object->getTargetValue(), ENT_QUOTES, 'UTF-8');
                  $body .= "    </TD>";
                  $body .= "    <TD>";
                  $body .= htmlentities($calrequest_object->getAnalysisType(), ENT_QUOTES, 'UTF-8');
                  $body .= "    </TD>";
                  $body .= "   </TR>";
               }
               $body .= "  </TABLE>";
            }
            else
            {
               # Handle the case of no calrequests
               $body .= "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
               $body .= "   <TR>\n";
               $body .= "    <TH></TH>\n";
               $body .= "    <TH>Status</TH>\n";
               $body .= "   </TR>\n";
               $body .= "   <TR>\n";
               $body .= "    <TD>\n";
               $body .= "No analyzes\n";
               $body .= "    </TD>\n";
               $body .= "    <TD>\n";
               $body .= $product_object->getStatus('abbr');
               $body .= "    </TD>\n";
               $body .= "   </TR>\n";
               $body .= "  </TABLE>\n";

            }
            $body .= " </TD>";
            $body .= "</TR>";
         }
         $body .= "        </TABLE>\n";
         $body .= "       </TD>\n";
         $body .= "      </TR>\n";
         $body .= "     </TABLE>\n";
         $body .= "    </TD>\n";
         $body .= "   </TR>\n";
      }
      $body .= "  </TABLE>\n";
      $body .= " </BODY>\n";
      $body .= "</HTML>\n";

      $log_comment = "";
/*
      $message = Swift_Message::newInstance();
      $message->setFrom(array('refgas@noaa.gov' => 'NOAA Refgas Manager'));
      $log_comment .= "From: NOAA Refgas Manager &lt;<A href='mailto:refgas@noaa.gov'>refgas@noaa.gov</A>&gt;<BR>";

      $primary_customer = $this->getPrimaryCustomer();
      $message->setTo(array($primary_customer->getEmail() => $primary_customer->getFirstName().' '.$primary_customer->getLastName()));

      $log_comment .= "To: ".$primary_customer->getFirstName()." ".$primary_customer->getLastName()." &lt;<A href='mailto:".$primary_customer->getEmail()."'>".$primary_customer->getEmail()."</A>&gt;<BR>";

      $customer_objects = $this->getCustomers();

      $cc_strarr = array();
      $cc_emails = array();
      foreach ( $customer_objects as $customer_object )
      {
         $cc_emails[$customer_object->getEmail()] = $customer_object->getFirstName().' '.$customer_object->getLastName();

         array_push($cc_strarr, $customer_object->getFirstName()." ".$customer_object->getLastName()." &lt;<A href='mailto:".$customer_object->getEmail()."'>".$customer_object->getEmail()."</A>&gt;");
      }

      if ( count($cc_emails) > 0 )
      {
         $message->setCc($cc_emails);
         $log_comment .= 'CC: '.join($cc_strarr)."<BR>";
      }

      // subject
      $subject = $input_subject.' Order # '.DB_OrderManager::encodeString($this->getNum());

      $message->setSubject($subject);
      $log_comment .= "Subject: ".$subject."<BR>";

      $message->setBody($body, "text/html");

      $log_comment .= "Content-Type: text/html<BR>";
      $log_comment .= "<BR>";
      $log_comment .= $body."<BR>";

      $transport = Swift_SendmailTransport::newInstance('/usr/sbin/sendmail -bs');
      $mailer = Swift_Mailer::newInstance($transport);

      if ( $this->getStatus('num') == '5' )
      {
         $pdffiles = $this->getAnalysisDocuments();

         foreach ( $pdffiles as $pdffile )
         {
            $attachment = Swift_Attachment::fromPath(getcwd().'/'.$pdffile, 'application/pdf');
            $message->attach($attachment);

            $log_comment .= "Attachment: <A href='".getcwd().'/'.$pdffile."'>$pdffile</A><BR>";
         }
      }

      #$result = $mailer->send($message);

      if ( ! $result )
      {
         throw new Exception("Sending email to customer was not successful.");
      }

      EmailLog::update($log_comment);
*/
   }

   /**
   * Method to retrieve related analysis documents
   *
   * @return (array) Array of file paths.
   */
   public function getAnalysisDocuments()
   {
      $files = array();

      $database_object = $this->getDB();

      $product_objects = DB_ProductManager::searchByOrder($database_object, $this);

      foreach ( $product_objects as $product_object )
      {
         $tmpfiles = $product_object->getAnalysisDocuments();
         $files = array_merge($files, $tmpfiles);
      }

      return ($files);
   }

   /**
   * Method to retrieve related shipping documents
   *
   * @return (array) Array of file paths.
   */
   public function getShippingDocuments()
   {
      $files = array();

      if ( ValidInt($this->getNum()) )
      {
         $target = "documents/*_N".$this->getNum().".pdf";

         $files = glob($target);

         sort($files);
      }

      return ($files);
   }

   /**
   * Method to retrieve the count of products related to an order
   *
   * @return (int) Count of products related to order
   */
   public function countProducts()
   {
      $database_object = $this->getDB();

      $cylinder_status_nums = DB_CylinderManager::getStatusNumsByOrder($database_object, $this);

      return count($cylinder_status_nums);
   }

   /**
   * Method to retrieve count of products that need to be filled
   *
   * @return (string) Count of products that need to be filled.
   */
   public function countProductsNeedFill()
   {
      $database_object = $this->getDB();

      $cylinder_status_nums = DB_CylinderManager::getStatusNumsByOrder($database_object, $this);

      $count = 0;

      foreach ( $cylinder_status_nums as $cylinder_status_num )
      {
         if ( $cylinder_status_num == '' ||
              $cylinder_status_num == 1 )
         { $count++; }
      }

      return $count.'/'.count($cylinder_status_nums);
   }

   /**
   * Method to retrieve count of products that need to be analyzed.
   *
   * @return (string) Count of products that need to be analyzed.
   */
   public function countProductsNeedAnalysis()
   {
      $database_object = $this->getDB();

      $product_status_nums = DB_ProductManager::getStatusNumsByOrder($database_object, $this);

      $count = 0;

      foreach ( $product_status_nums as $product_status_num )
      {
         if ( $product_status_num !== '3' &&
              $product_status_num !== '6' )
         { $count++; }
      }

      return $count.'/'.count($product_status_nums);
   }

   /**
   * Method to determine if an order is processing
   *
   * Orders are in processing when there are calibrations being made
   *  or the calibrations are complete but the order could still be
   *  modified before shipment
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal.
   */
   public function isProcessing()
   {
      if ( $this->getStatus('num') == '1' ||
           $this->getStatus('num') == '2' ||
           $this->getStatus('num') == '3' ||
           $this->getStatus('num') == '4' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if an order is active
   *
   * Orders that are not complete and not cancelled
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal.
   */
   public function isActive()
   {
      if ( $this->getStatus('num') == '1' ||
           $this->getStatus('num') == '2' ||
           $this->getStatus('num') == '3' ||
           $this->getStatus('num') == '4' ||
           $this->getStatus('num') == '6' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to determine if an order is pending
   *
   * @return (bool) TRUE -> equal. FALSE -> not equal.
   */
   public function isPending()
   {
      if ( $this->getStatus('num') == '8' )
      { return true; }
      else
      { return false; }
   }

   /**
   * Method to initiate processing of a pending order
   *
   * @return void
   */
   public function process()
   {
      if ( $this->getStatus('num') == '8' )
      {
         $this->setStatus('1','num');
      }
      else
      {
         # Do nothing, the order is already processing
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

      # Put checks here that need to occur before the data should be saved
   }

   /**
   * Method to save to the database
   *
   * This method is the only way to save a DB_Order to
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
      $send_email = 0;
      $email_subject = '';

      $this->updateStatus();

      $this->preSaveToDB();

      $database_object = $this->getDB();

      $sqlaarr = array();

      # Save the information where we have it
      $sqlaarr['creation_datetime'] = $this->getCreationDatetime();
      $sqlaarr['due_date'] = $this->getDueDate();
      $sqlaarr['MOU_number'] = $this->getMOUNumber();
      $sqlaarr['organization'] = $this->getOrganization();
      $sqlaarr['order_status_num'] = $this->getStatus('num');
      $sqlaarr['comments'] = $this->getComments();

      if ( is_object($this->getShippingLocation()) )
      { $sqlaarr['shipping_location_num'] = $this->getShippingLocation()->getNum(); }

      if ( is_object($this->getPrimaryCustomer()) )
      { $sqlaarr['primary_customer_user_id'] = $this->getPrimaryCustomer()->getNum(); }

      if ( ValidInt($this->getNum()) )
      {
         # UPDATE

         # Instantiate a DB_Order from the database
         # so we can determine the difference between
         # $this and the database.
         $db_order_object = new DB_Order($database_object, $this->getNum());

         if ( ! $this->equals($db_order_object) )
         {
            $setarr = array();
            $sqlargs = array();
            foreach ( $sqlaarr as $key=>$value )
            {
               array_push($setarr, "$key = ?");
               array_push($sqlargs, $value);
            }

            $sql = " UPDATE order_tbl SET ".join(', ', $setarr)." WHERE num = ? LIMIT 1";
            array_push($sqlargs, $this->getNum());

            #toLogFile($sql."<BR>");
            #(join(',', $sqlargs)."<BR>");

            $database_object->executeSQL($sql, $sqlargs);

            #Log::update($input_user_object->getUsername(), '(UPDATE NEW) '.$this->diffToString($db_order_object).' '.$this->__toString());
            #jwm - 1/17 - updating log output
            Log::update($input_user_object->getUsername(), '(DB_Order: update) order.num:'.$this->getNum().' '.$this->diffToString($db_order_object).' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs));

            # If the status changed from pending to not pending then
            # update the related products to not pending as well
            if ( $db_order_object->isPending() &&
                 $this->isActive() )
            {
               $product_objects = DB_ProductManager::searchByOrder($database_object, $this);

               foreach ( $product_objects as $product_object )
               {
                  $product_object->process();
                  $product_object->saveToDB($input_user_object);
               }
            }

            # Email customers
            if ( $this->getStatus('num') != $db_order_object->getStatus('num') )
            {
               if ( $this->getStatus('num') == '5' ||
                    $this->getStatus('num') == '7' )
               {
                  $email_subject = 'Your order status has been updated to '.$this->getStatus('abbr').'.';
                  $send_email = 1;
               }
            }
         }

         # Handle the customers
         list($add_customer_objects, $delete_customer_objects) = compare_object_array($this->getCustomers(), $db_order_object->getCustomers(), 'match');
      }
      else
      {
         # INSERT

         $sql = " INSERT INTO order_tbl (".join(', ', array_keys($sqlaarr)).") VALUES (".join(', ', array_fill('0', count(array_values($sqlaarr)), '?')).")";

         $sqlargs = array_values($sqlaarr);

         #print $sql."<BR>";
         #print join(',', $sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);

         $sql2 = " SELECT LAST_INSERT_ID()";
         $res = $database_object->queryData($sql2);
         $this->setNum($res[0][0]);

         $logtext='(DB_Order: insert) order.num:'.$res[0][0].' SQL:'.$sql."   SQLARGS:".implode(",",$sqlargs);

         #Log::update($input_user_object->getUsername(), '(INSERT) '.$this->__toString());
         #jwm - 1/17 -changing log output.
         Log::update($input_user_object->getUsername(), $logtext);

         # Email customers
         $email_subject = 'Your order has been created.';
         $send_email = 1;

         $add_customer_objects = $this->getCustomers();
         $delete_customer_objects = array();
      }

      # Save the ones that need to be added/updated
      foreach ( $add_customer_objects as $customer_object )
      {
         $sql = " INSERT INTO order_customer (order_num, customer_user_id) VALUES (?,?)";
         $sqlargs = array($this->getNum(), $customer_object->getNum());

         #print $sql."<BR>";
         #print join(',', $sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);
      }

      # Delete the ones that need to be deleted
      foreach ( $delete_customer_objects as $customer_object )
      {
         $sql = " DELETE FROM order_customer WHERE order_num = ? AND customer_user_id = ?";
         $sqlargs = array($this->getNum(), $customer_object->getNum());

         #print $sql."<BR>";
         #print join(',', $sqlargs)."<BR>";

         $database_object->executeSQL($sql, $sqlargs);
      }

      # If the order is cancelled, then handle the products properly
      if ( $this->getStatus('num') == '7' )
      {
         $product_objects = DB_ProductManager::searchByOrder($database_object, $this);

         foreach ( $product_objects as $product_object )
         {
            if ( $product_object->isActive() )
            {
               # Please note, pending products cannot exist independent of an order

               $product_object->setOrder('');
               $product_object->saveToDB($input_user_object);
            }
            else
            {
               $product_object->deleteFromDB($input_user_object);
            }
            #print_r($product_object);
         }
      }
      elseif ( $this->getStatus('num') == '5' )
      {
         # This should only be done once
         if ( ! isset($db_order_object) ||
              ! is_object($db_order_object) ||
              $db_order_object->getStatus('num') != $this->getStatus('num') )
         {
            # This is functional, however, it would be better if
            #   the cylinder status was not set outside of
            #   a cylinder object
            $product_objects = DB_ProductManager::searchByOrder($database_object, $this);

            foreach ( $product_objects as $product_object )
            {
               if ( is_object($product_object->getCylinder()) )
               {
                  $product_object->getCylinder()->setStatus('2','num');
                  $product_object->getCylinder()->setCheckInStatus('2','num');
                  $product_object->getCylinder()->saveToDB($input_user_object);

                  # Save information to 'owner'

                  $sqlaarr = array();
                  $sqlaarr['serial_number'] = $product_object->getCylinder()->getID();
                  $sqlaarr['date'] = date("Y-m-d");
                  $sqlaarr['organization'] = $this->getOrganization();
                  $sqlaarr['name'] = $this->getPrimaryCustomer()->getFullName();

                  if ( is_object($this->getShippingLocation()) )
                  {
                     $tmparr = array();
                     array_push($tmparr, $this->getShippingLocation()->getAbbreviation());
                     array_push($tmparr, $this->getShippingLocation()->getAddress());
                     $sqlaarr['address'] = join("\n", $tmparr);
                  }

                  $sqlaarr['email'] = $this->getPrimaryCustomer()->getEmail();

                  $sql = " INSERT INTO reftank.owner (".join(', ', array_keys($sqlaarr)).") VALUES (".join(', ', array_fill('0', count(array_values($sqlaarr)), '?')).")";
                  $sqlargs = array_values($sqlaarr);

                  #print $sql."<BR>";
                  #print join(',', $sqlargs)."<BR>";

                  $database_object->executeSQL($sql, $sqlargs);
               }
            }
         }
      }

      # At the end, send an e-mail if necessary. By leaving this until
      #  the end then I make sure that all the other tasks were
      #  completed successfully
      if ( $send_email == 1 )
      {
         # This has been turned off and waiting redesign
         # $this->emailCustomers($email_subject);
      }
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

      $sql = " SELECT creation_datetime, due_date, MOU_number, organization, primary_customer_user_id, shipping_location_num, order_status_num, comments FROM order_tbl WHERE num = ?";

      $sqlargs = array($this->getNum());
      $res = $database_object->queryData($sql, $sqlargs);

      # Throw errors if we get more or less than one result
      if ( count($res) == 0 )
      { throw new Exception("No matching records found in database."); }
      elseif ( count($res) > 1 )
      { throw new Exception("Too many matching records found in database."); }

      $this->setCreationDatetime($res[0]['creation_datetime']);
      $this->setDueDate($res[0]['due_date']);
      $this->setMOUNumber($res[0]['MOU_number']);
      $this->setOrganization($res[0]['organization']);
      if ( $res[0]['primary_customer_user_id'] != '' )
      {
         $customer_object = new DB_Customer($database_object, $res[0]['primary_customer_user_id']);
         $this->setPrimaryCustomer($customer_object);
      }

      if ( $res[0]['shipping_location_num'] != '0' )
      {
         $location_object = new DB_Location($database_object, $res[0]['shipping_location_num']);
         $this->setShippingLocation($location_object);
      }

      $this->setStatus($res[0]['order_status_num'], 'num');
      $this->setComments($res[0]['comments']);

      # Get the customers associated with this order
      $sql = " SELECT customer_user_id FROM order_customer WHERE order_num = ?";
      $sqlargs = array($this->getNum());

      $res = $database_object->queryData($sql, $sqlargs);

      foreach ( $res as $aarr )
      {
         $customer_object = new DB_Customer($database_object, $aarr['customer_user_id']);
         $this->addCustomer($customer_object);
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
   public function equals($input_object)
   {
      if ( parent::equals($input_object) &&
           $this->getNum() === $input_object->getNum() )
      {
         $db_order_object = new DB_Order($this->getDB(), $this->getNum());

         # Handle the customers
         list($add_objects, $delete_objects) = compare_object_array($this->getCustomers(), $db_order_object->getCustomers(), 'match');

         if ( count($add_objects) > 0 ||
              count($delete_objects) > 0 )
         {
            return false;
         }

         return true;
      }
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
   * Method to determine the differences between a given object and this one.
   *
   * This is primarily used when creating a log entry so that an user
   *  can quickly determine where to look for differences.
   *
   * @return (string) A string of variable names where the information
   *  has been updated.
   */
   public function diffToString(DB_Order $input_order_object)
   {
      $diff_arr = array();

      if ( $this->getNum() !== $input_order_object->getNum() )
      { array_push($diff_arr, "num"); }

      if ( ! $this->getPrimaryCustomer()->equals($input_order_object->getPrimaryCustomer()) )
      { array_push($diff_arr, "primary_customer"); }

      list($add_objects, $delete_objects) = compare_object_array($this->getCustomers(), $input_order_object->getCustomers());
      if ( count($add_objects) != 0 ||
           count($delete_objects) != 0 )
      { array_push($diff_arr, "additional_customers"); }

      if ( $this->getCreationDatetime() !== $input_order_object->getCreationDatetime() )
      { array_push($diff_arr, "creation_datetime"); }

      if ( $this->getDueDate() !== $input_order_object->getDueDate() )
      { array_push($diff_arr, "due_date"); }

      if ( $this->getMOUNumber() !== $input_order_object->getMOUNumber() )
      { array_push($diff_arr, "MOU_number"); }

      if ( $this->getOrganization() !== $input_order_object->getOrganization() )
      { array_push($diff_arr, "organization"); }

      if ( $this->getStatus('num') !== $input_order_object->getStatus('num') )
      { array_push($diff_arr, "status"); }

      $str = 'No differences found.';
      if ( count($diff_arr) > 0 )
      {
         $str = " The following information has been updated: ".join(', ', $diff_arr).".";
      }

      return($str);
   }
}

?>
