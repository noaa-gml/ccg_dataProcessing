<?PHP

require_once "CCGDB.php";
require_once "DB_OrderManager.php";
require_once "DB_Order.php";
require_once "DB_ProductManager.php";
require_once "/var/www/html/inc/validator.php";

$encoded_order_num = ( isset($_GET['order']) ) ? $_GET['order'] : '';

$decoded_order_num = DB_OrderManager::decodeString($encoded_order_num);

$database_object = new CCGDB();

try
{
   if ( ValidInt($decoded_order_num) )
   {
      $order_object = new DB_Order($database_object, $decoded_order_num);
   }
   else
   {
      print "Please provide a valid order number.";
      exit;
   }
}
catch ( Exception $e )
{
   Log::update($e->__toString());
   echo "<DIV style='color:red'>".$e->getMessage()."</DIV>";
   exit;
}

$status_aarr = DB_OrderManager::getOrderStatusSequence($database_object);

#echo "<PRE>";
#print_r($order_object);
#print_r($status_aarr);
#echo "</PRE>";

?>
<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
 </HEAD>
 <BODY>
  <TABLE cellspacing='3' cellpadding='3' style='background-color:white'>
   <TR>
    <TD valign='top'>
     <TABLE border='1' cellpadding='3' cellpadding='3' style='background-color:white'>
      <TR>
       <TH colspan='2'><H2>Order Status</H2></TH>
      </TR>
<?PHP
if ( in_array($order_object->getStatus('num'), array_keys($status_aarr)) )
{

   $match = 0;
   foreach ( $status_aarr as $status_num=>$status_abbr )
   {
      echo " <TR>";
      if ( $match == 0 )
      { echo "  <TD><IMG src='images/checkmark_green.png'></TD>"; }
      else
      { echo "  <TD></TD>"; }

      echo "  <TD>".htmlentities($status_abbr, ENT_QUOTES, 'UTF-8')."</TD>";
      echo " </TR>";

      if ( $status_num == $order_object->getStatus('num') )
      { $match = 1; }
   }
}
else
{
   echo " <TR>";
   echo "  <TD>";
   echo "   <DIV style='color:blue'>";
   echo htmlentities($order_object->getStatus('abbr'), ENT_QUOTES, 'UTF-8');
   echo "   </DIV>";
   echo "  </TD>";
   echo " </TR>";
}
?>
     </TABLE>
    </TD>
    <TD valign='top'>
     <TABLE cellspacing='3' cellpadding='3' style='background-color:white;'>
      <TR>
       <TH colspan='2'><H2>Order Details</H2></TH>
      </TR>
      <TR>
       <TD>Due Date</TD>
       <TD>
        <?PHP echo htmlentities($order_object->getDueDate(), ENT_QUOTES, 'UTF-8'); ?>
       </TD>
      </TR>
      <TR>
       <TD>MOU number</TD>
       <TD>
        <?PHP echo htmlentities($order_object->getMOUNumber(), ENT_QUOTES, 'UTF-8'); ?>
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
        <TD>Additional Customers</TD>
        <TD>
         <?PHP
          foreach ( $customer_objects as $customer_object )
          {
             echo htmlentities($customer_object->getEmail(), ENT_QUOTES, 'UTF-8');
             echo "<BR>";
          }
         ?>
        </TD>
       </TR>
<?PHP

}

?>
       <TR>
        <TD colspan='2'><HR></TD>
       </TR>

<?PHP

   $shipping_documents = $order_object->getShippingDocuments();

   if ( count($shipping_documents) > 0 )
   {
      $shipping_strings = array();
      foreach ( $shipping_documents as $file )
      {
         $filefields = preg_split('/\//', $file);

         $filename = array_pop($filefields);

         array_push($shipping_strings, "<A href='$file'>$filename</A>");
      }

      echo " <TR>";
      echo "  <TH colspan='2'>Shipping documents</TH>";
      echo " </TR>";
      echo " <TR>";
      echo "  <TD colspan='2' align='center'>"; 
      echo join('<BR>', $shipping_strings);
      echo "  </TD>"; 
      echo " </TR>";
   }

   $product_objects = DB_ProductManager::searchByOrder($database_object, $order_object);

   $certificate_strings = array();
   foreach ( $product_objects as $product_object )
   {
      $files = $product_object->getAnalysisDocuments();

      if ( count($files) > 0 )
      {
         foreach ( $files as $file )
         {
            $string = '';
            if ( is_object($product_object->getCylinder()) )
            { $string .= 'Cylinder '.htmlentities($product_object->getCylinder()->getID(), ENT_QUOTES, 'UTF-8').': '; }

            list($dir, $filename) = preg_split('/\//', $file, 2);
            $string .= "<A href='$file'>".htmlentities($filename, ENT_QUOTES, 'UTF-8')."</A>";

            array_push($certificate_strings, $string);
         }
      }
   }

   if ( count($certificate_strings) > 0 )
   {
      echo " <TR>";
      echo "  <TH colspan='2'>Calibration certificates</TH>";
      echo " </TR>";
      echo " <TR>";
      echo "  <TD colspan='2' align='center'>"; 
      echo join('<BR>', $certificate_strings);
      echo "  </TD>"; 
      echo " </TR>";
   }
?>
     </TABLE>
     <TABLE border='1' cellpadding='3' cellpadding='3' style='background-color:white'>
      <TR>
       <TH>Cylinder ID</TH>
       <TH>Analysis Details</TH>
      </TR>
<?PHP

foreach ( $product_objects as $product_object )
{
   echo "<TR>";
   echo " <TD>";
   $cylinder_object = $product_object->getCylinder();

   if ( is_object($cylinder_object) )
   {
      echo htmlentities($cylinder_object->getID(), ENT_QUOTES, 'UTF-8');
   }
   else
   {
      echo "Unassigned";
   }
   echo " </TD>";
   echo " <TD>";

   $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

   if ( count($calrequest_objects) > 0 )
   {
      echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>";
      echo "   <TR>";
      echo "    <TH>Specie</TH>";
      echo "    <TH>Target Value</TH>";
      echo "    <TH>Analysis Type</TH>";
      echo "   </TR>";

      foreach ( $calrequest_objects as $calrequest_object )
      { 
         echo "   <TR>";
         echo "    <TD>";
         echo $calrequest_object->getCalService()->getAbbreviationHTML();
         echo "    </TD>";
         echo "    <TD>";
         echo htmlentities($calrequest_object->getTargetValue(), ENT_QUOTES, 'UTF-8');
         echo "    </TD>";
         echo "    <TD>";
         echo htmlentities($calrequest_object->getAnalysisType(), ENT_QUOTES, 'UTF-8');
         echo "    </TD>";
         echo "   </TR>";
      }
      echo "  </TABLE>";
   }
   else
   {
      # Handle the case of no calrequests
      echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
      echo "   <TR>\n";
      echo "    <TH></TH>\n";
      echo "    <TH>Status</TH>\n";
      echo "   </TR>\n";
      echo "   <TR>\n";
      echo "    <TD>\n";
      echo "No analyzes\n";
      echo "    </TD>\n";
      echo "    <TD>\n";
      echo $product_object->getStatus('abbr');
      echo "    </TD>\n";
      echo "   </TR>\n";
      echo "  </TABLE>\n";
   }
   echo " </TD>";
   echo "</TR>";
}

?>
       </TD>
      </TR>
     </TABLE>
    </TD>
   </TR>
  </TABLE>
 </BODY>
</HTML>

