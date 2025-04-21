<?PHP

require_once("CCGDB.php");
require_once("DB_Order.php");
require_once("DB_ProductManager.php");
require_once("DB_CalRequestManager.php");
require_once("/var/www/html/inc/validator.php");
require_once("/var/www/html/inc/ccgglib_inc.php");
require_once "utils.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$order_num = isset($_GET['num']) ? $_GET['num'] : '';
$input_data = isset( $_POST['input_data'] ) ? $_POST['input_data'] : '';

$errors = array();
if ( $input_data != '' )
{
   $input_data_aarr = @mb_unserialize(urldecode($input_data));

   if ( $input_data_aarr === false )
   {
      $e = new Exception("Error with input data.");
      array_push($errors, $e);
   }
}
else
{
   $input_data_aarr = array();
}

$errors = array();
try
{
   if ( ValidInt($order_num) )
   {
      $order_object = new DB_Order($database_object, $order_num);
   }
   else
   {
      print "Please provide a valid order number.";
      exit;
   }
}
catch ( Exception $e )
{
   echo "<DIV style='color:red'>".$e->getMessage()."</DIV>";
   exit;
}

/*Changing logic filter to allow certs for some cylinders in an order.
 *jwm 2/17
 *if ( $order_object->getStatus('num') != '5' && 
     $order_object->getStatus('num') != '6' )
{
   print "Order must be complete or ready to ship before calibration certificates may be made.";
   exit;
}
*/
if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'submit' )
{
   try
   {
      #print_r($input_data_aarr);
      if ( isset($input_data_aarr['productnumarr']) )
      {
         # First, make sure that all the entries in productnumarr
         #  are valid product numbers
         $product_objects = array();
         foreach ( $input_data_aarr['productnumarr'] as $product_num )
         {
            $product_object = new DB_Product($database_object, $product_num);
            array_push($product_objects, $product_object);
         }

         # Now, make all of the calibration certificates requested but
         # only if there are no certificates for that product
         foreach ( $product_objects as $product_object )
         {
            $certificates = $product_object->getAnalysisDocuments();

            if ( count($certificates) == 0 )
            { $product_object->makeAnalysisDocuments($user_obj); }
         }
      }

      # Only email the documents if the order is complete.
      if ( $order_object->getStatus('num') == '5' )
      { $order_object->emailDocuments(); } 
   }
   catch(Exception $e)
   { array_push($errors, $e); }
}

?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/php_serialize.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="order_certificates.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>

<?PHP

CreateMenu($database_object, $user_obj);

#
##############################
#
# Display errors
#
##############################
#
if ( count($errors) > 0 )
{
   echo "<TABLE>";
   echo " <TR>";
   echo "  <TD>";
   echo "The following errors were encountered:";
   echo "  </TD>";
   echo " </TR>";
   echo " <TR>";
   echo "  <TD>";
   echo "   <UL>";
   foreach ( $errors as $e )
   {
      Log::update($user_obj->getUsername(), $e->__toString());
      echo "    <LI><DIV style='color:red'>".$e->getMessage()."</DIV></LI>";
   }
   echo "   </UL>";
   echo "  </TD>";
   echo " </TR>";
   echo "</TABLE>";
}

?>

  <H1>Order Calibration Certificates</H1>
  <!-- <P>Please note that an email is sent to the customer upon a successful submission.</P> -->
  <FORM name='mainform' id='mainform' method='post'>
   <INPUT type='hidden' id='input_data' name='input_data'>
   <TABLE border='1' cellspacing='3' cellpadding='3'>
    <TR>
     <TD>
      <TABLE border='1' cellspacing='3' cellpadding='3'>
       <TR>
        <TD>Order num</TD>
        <TD>
         <FONT style='color:blue'>
          <?PHP echo $order_object->getNum(); ?>
         </FONT>
        </TD>
       </TR>
       <TR>
        <TD>Due Date</TD>
        <TD>
         <?PHP echo $order_object->getDueDate(); ?>
        </TD>
       </TR>
       <TR>
        <TD>MOU number</TD>
        <TD>
         <?PHP echo $order_object->getMOUNumber(); ?>
        </TD>
       </TR>
       <TR>
        <TD>Primary Customer</TD>
        <TD>
         <?PHP
          $customer_object = $order_object->getPrimaryCustomer();

          if ( is_object($customer_object) )
          { echo htmlentities($customer_object->getFirstName().' '.$customer_object->getLastName().' <'.$customer_object->getEmail().'>', ENT_QUOTES, 'UTF-8'); }
         ?>
        </TD>
       </TR>

<?PHP

$customer_objects = $order_object->getCustomers();

if ( count($customer_objects) > 0 )
{

?>
       <TR>
        <TD>Customers</TD>
        <TD>
         <?PHP
          foreach ( $customer_objects as $customer_object )
          {
             echo $customer_object->getEmail();
             echo "<BR>";
          }
         ?>
        </TD>
       </TR>
<?PHP

}

?>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE border='1' cellspacing='5' cellpadding='5'>
       <THEAD>
        <TR>
         <TH>Selection</TH>
         <TH>Cylinder ID</TH>
         <TH>Fill Code</TH>
         <TH>Analysis Status</TH>
        </TR>
       </THEAD>
       <TBODY>
<?PHP

   $product_objects = DB_ProductManager::searchByOrder($database_object, $order_object);

   $showsubmit = FALSE;

   foreach ( $product_objects as $product_object )
   {

      
      echo "<TR>\n";

      echo " <TD align='center'>\n";
      $certificates = $product_object->getAnalysisDocuments();
      if ( count($certificates) == 0)
      {//Note after removing above check on order status, these may still be 'processing'.  Users requested ability to print a cert unhindered by status though.  They'll decide when its ready.
         $showsubmit = TRUE;
         echo "<INPUT type='checkbox' id='product".$product_object->getNum()."_selection' name='product".$product_object->getNum()."_selection'>";
      }
      else
      { echo "X"; }
      echo " </TD>\n";

      echo " <TD>\n";
      if ( is_object($product_object->getCylinder()) )
      { echo $product_object->getCylinder()->getID(); }
      echo " </TD>\n";

      echo " <TD align='center'>\n";
      echo $product_object->getFillCode();
      echo " </TD>\n";

      echo " <TD>\n";

      $files = $product_object->getAnalysisDocuments();

      if ( count($files) > 0 )
      {
         foreach ( $files as $file )
         {
            list($dir, $filename) = preg_split('/\//', $file, 2);
            echo "<FONT style='font-weight:bold'>Certificate</FONT>: <A target='_new'href='$file'>$filename</A><BR>";
         }
      }

      echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
      echo "   <THEAD>\n";
      echo "   <TR>\n";
      echo "    <TH>Specie</TH>\n";
      echo "    <TH colspan='2'>Status</TH>\n";
      echo "    <TH>Target Value</TH>\n";
      echo "    <TH>Analysis Type</TH>\n";
      echo "    <TH>Analysis Value</TH>\n";
      echo "    <TH>Analysis Repeatability</TH>\n";
      echo "   </TR>\n";
      echo "   </THEAD>\n";
      echo "   <TBODY>\n";
     
      $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

      foreach ( $calrequest_objects as $calrequest_object )
      {
         echo "   <TR>\n";
         echo "    <TD>\n";
         echo $calrequest_object->getCalService()->getAbbreviationHTML();
         echo "    </TD>\n";

         echo "    <TD>\n";
         echo $calrequest_object->getStatus('abbr');
         echo "    </TD>\n";

         $color = $calrequest_object->getStatusColorHTML();
         echo "    <TD style='background-color:$color'>\n";
         echo "&nbsp;&nbsp;&nbsp;";
         echo "    </TD>\n";

         echo "    <TD>\n";
         echo $calrequest_object->getTargetValue();
         echo "    </TD>\n";

         echo "    <TD>\n";
         echo $calrequest_object->getAnalysisType();
         echo "    </TD>\n";

         echo "    <TD>\n";
         echo $calrequest_object->getAnalysisValue();
         echo "    </TD>\n";

         echo "    <TD>\n";
         echo $calrequest_object->getAnalysisRepeatability();
         echo "    </TD>\n";
         echo "   </TR>\n";
      }

      echo "   </TBODY>\n";
      echo "  </TABLE>\n";
      echo " </TD>\n";

      echo "</TR>\n";
   }

?>
       </TBODY>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <TABLE cellspacing='10' cellpadding='10'>
       <TR>
        <TD>
<?PHP
         if ( $showsubmit )
         { echo "<INPUT type='button' value='Submit' onClick='SubmitCB();'>"; }
?>
        </TD>
        <TD>
         <?PHP echo "<A href='order_status.php?num=".$order_object->getNum()."'><INPUT type='button' value='Order Status'></A>&nbsp;&nbsp;";
            echo "<A href='index.php?mod=orders'><INPUT type='button' value='Back to order'></A>";
         ?>
        
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
   </TABLE>
   <TABLE>
    <TR>
     <TD>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
        </TD>
        <TD align='right' width='50%'>
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href;'>
        </TD>
       </TR>
      </TABLE>
      <?PHP # This is for the menu that pops up at the bottom of the android screen. ?>
      <BR>
      <BR>
      <BR>
     </TD>
    </TR>
   </TABLE>
  </FORM>
<?PHP NoCacheLinks(); ?>
 </BODY>
</HTML>

<?PHP

exit;

?>
