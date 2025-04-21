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

#echo "<PRE>";
#print_r($input_data_aarr);
#echo "</PRE>";

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'submit' )
{

   $product_arr = array_values(preg_grep('/^product[0-9]+$/', array_keys($input_data_aarr)));

   #echo "<PRE>";
   #print_r($product_arr);
   #echo "</PRE>";

   foreach ( $product_arr as $product_string )
   {
      try
      {
         # Get the product number
         $product_num = preg_replace('/^product/', '', $product_string);

         #echo $input_data_aarr[$product_string];

         if ( $input_data_aarr[$product_string] === 'approve' )
         {
            # If the product is approved

            # Instantiate the product
            $product_object = new DB_Product($database_object, $product_num);

            # Mark it as ready to ship
            $product_object->readyToShip();
            $product_object->saveToDB($user_obj);

            #echo "<PRE>";
            #print_r($product_object);
            #echo "</PRE>";
         }
         elseif ( $input_data_aarr[$product_string] === 'to_processing' )
         {
            # If the product is to be sent back to processing
            #   This may only happen if there are calrequests

            $calrequest_arr = array_values(preg_grep('/^'.$product_string.'_/', array_keys($input_data_aarr)));

            #echo "<PRE>";
            #print_r($calrequest_arr);
            #echo "</PRE>";

            foreach ( $calrequest_arr as $calrequest_string )
            {
               if ( $input_data_aarr[$calrequest_string] === 'to_processing' )
               {
                  # Determine the ones than need to be sent back to processing

                  if ( preg_match('/^product[0-9]+_calrequest([0-9]+)_selection$/', $calrequest_string, $matches) )
                  {
                     #echo "<PRE>";
                     #print_r($matches);
                     #echo "</PRE>";

                     $calrequest_num = $matches[1];

                     # Instantiate the CalRequest
                     $calrequest_object = new DB_CalRequest($database_object, $calrequest_num);

                     # Only reset the status if the calrequest is not pending
                     if ( ! $calrequest_object->isPending() )
                     {
                        $calrequest_object->resetStatus();
                        $calrequest_object->saveToDB($user_obj);
                     }

                     #echo "<PRE>";
                     #print_r($calrequest_object);
                     #echo "</PRE>";
                  }
               }
            }
         }
      }
      catch(Exception $e)
      { array_push($errors, $e); }
   }
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
  <SCRIPT language='JavaScript' src="order_finalapproval.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
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

  <H1>Order Product Final Approval</H1>
  <FORM name='mainform' id='mainform' method='post'>

   <SCRIPT>
    $(document).ready(function()
    {
      $("select").change(
         function()
         {
            
            var idfields = $(this).attr('id').split('_');

            related_count = $("select[id^='"+idfields[0]+"_']").length;

            if ( related_count == 1 )
            {
               // Skip the rest of the code if there is only one calrequest
               //  as the code is used to ensure consistency between
               //  related calrequests 

               SetValue($(this).attr('id'), $(this).val(), dataaarr);
               return TRUE;
            } 

            if ( $(this).val() == 'approve' )
            {
               //At request of Duane, removing confirmation boxes, making messages instead
               setMessageDiv("If one analysis is approved, all related analyzes must be approved",3);
               if (1==1)
               //if ( confirm("If one analysis is approved, all related analyzes must be approved") )
               {
                  // If one calrequest is approved, all related calrequests must be approved

                  selected_value = $(this).val();

                  $("select[id^='"+idfields[0]+"_']").each(
                     function ()
                     {
                        $(this).val(selected_value);
                        SetValue($(this).attr('id'), $(this).val(), dataaarr);
                     }
                  );
               }
               else
               {
                  // If the user does not accept then set the select
                  //  to the previous value

                  $(this).val(GetValue($(this).attr('id')));
                  SetValue($(this).attr('id'), $(this).val(), dataaarr);
               }
            }
            else if ( $(this).val() == 'to_processing' ||
                      $(this).val() == '' )
            {
               // Count how many of the select inputs are
               //  set to 'approve'

               approvecount = 0;

               $("select[id^='"+idfields[0]+"_']").each(
                  function ()
                  {
                     if ( $(this).val() == 'approve' )
                     { approvecount++; }
                  }
               );

               if ( approvecount > 0 )
               {

                  if ( $(this).val() == 'to_processing' )
                  { 
                     message_string = "If one analysis is sent back to processing, no related analysis may be approved";
                  }
                  else
                  {
                     message_string = "If one analysis is cleared, no related analysis may be approved";
                  }
                  //Removing confirmation at request of Duane.  We'll just display as a status message instead.
                  setMessageDiv(message_string,3);
                  if (1==1)
                  //if ( confirm(message_string) )
                  {
                     // If there are at least one select marked as 'approve'
                     //  then let the user know it will be cleared.

                     $("select[id^='"+idfields[0]+"_']").each(
                        function ()
                        {
                           if ( $(this).val() == 'approve' )
                           {
                              // If the value is set to 'approve' then clear it

                              $(this).val('');
                              SetValue($(this).attr('id'), $(this).val(), dataaarr);
                           }
                        }
                     );
                  }
                  else
                  {
                     // If the user does not accept then set the pulldown
                     //  to its previous value

                     $(this).val(GetValue($(this).attr('id')));
                     SetValue($(this).attr('id'), $(this).val(), dataaarr);
                  }
               }
            }

            SetValue($(this).attr('id'), $(this).val(), dataaarr);
         }
      );
    });
    var clearMessageTimer;//Global used (in php code) to wipe the status after a set time.  Global allows us to unset it.
    function setMessageDiv(message,wipeAfter) {
    //auto clears message in wipeafter seconds (0 to leave).
    clearTimeout(clearMessageTimer);//Prevent an earlier message from wiping us early.
    $("#messageDiv").html(message);
    if (wipeAfter>0 && message!="") {
        clearMessageTimer=setTimeout(function(){$("#messageDiv").empty();},wipeAfter*1000);
    }
}
   </SCRIPT>

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
         <TH>Cylinder ID</TH>
         <TH>Fill Code</TH>
         <TH>Status</TH>
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

      echo " <TD>\n";
      if ( is_object($product_object->getCylinder()) )
      { echo $product_object->getCylinder()->getID(); }
      echo "</TD>\n";

      echo " <TD align='center'>\n";
      echo $product_object->getFillCode();
      echo " </TD>\n";

      echo " <TD>\n";

      if ( $product_object->getStatus('num') == '3' )
      {
         $showsubmit = TRUE;
      }
      elseif ( $product_object->getStatus('num') == '6' )
      {
         echo "<FONT style='color:green'>Approved</FONT>";
      }

      echo " </TD>\n";

      echo " <TD>\n";

      $files = $product_object->getAnalysisDocuments();

      if ( count($files) > 0 )
      {
         foreach ( $files as $file )
         {
            list($dir, $filename) = preg_split('/\//', $file, 2);
            echo "<FONT style='font-weight:bold'>Certificate</FONT>: <A href='$file'>$filename</A><BR>";
         }
      }

      $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

      if ( count($calrequest_objects) > 0 )
      {
         # If there are calrequests

         echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
         echo "   <THEAD>\n";
         echo "   <TR>\n";
         echo "    <TH>Option</TH>\n";
         echo "    <TH>Specie</TH>\n";
         echo "    <TH colspan='2'>Status</TH>\n";
         echo "    <TH>Target Value</TH>\n";
         echo "    <TH>Analysis Type</TH>\n";
         echo "    <TH>Analysis Value</TH>\n";
         echo "    <TH>Analysis Repeatability</TH>\n";
         echo "    <TH>Reference Scale</TH>\n";
         echo "   </TR>\n";
         echo "   </THEAD>\n";
         echo "   <TBODY>\n";

         foreach ( $calrequest_objects as $calrequest_object )
         {
            echo "   <TR>\n";
            echo "    <TD>\n";

            if ( $product_object->getStatus('num') == '3' ||
                 ( $product_object->getStatus('num') == '2' &&
                   $calrequest_object->getStatus('num') == '3' ))
            {
               $showsubmit = TRUE;

               echo "     <SELECT id='product".$product_object->getNum()."_calrequest".$calrequest_object->getNum()."_selection' name='product".$product_object->getNum()."_calrequest".$calrequest_object->getNum()."_selection'>\n";
               echo "      <OPTION value=''></OPTION>";
               echo "      <OPTION value='approve'>Approve</OPTION>";
               echo "      <OPTION value='to_processing'>Back to processing</OPTION>";
               echo "     </SELECT>\n";

               if ( $calrequest_object->getAnalysisReferenceScale() != '' &&
                    $calrequest_object->getAnalysisReferenceScale() != $calrequest_object->getCalService()->getCurrentReferenceScale() )
               {
                  echo "<DIV style='color:#E92828;'>Current reference scale updated to '".$calrequest_object->getCalService()->getCurrentReferenceScale()."'</DIV>";
               }
            }
            echo "    </TD>\n";
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

            echo "    <TD>\n";
            echo $calrequest_object->getAnalysisReferenceScale();
            echo "    </TD>\n";
            echo "   </TR>\n";
         }

         echo "   </TBODY>\n";
         echo "  </TABLE>\n";
      }
      else
      {
         # There are no calrequests

         echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
         echo "   <TR>\n";
         echo "    <TD>\n";
         if ( $product_object->getStatus('num') == '3' )
         {
            $showsubmit = TRUE;

            echo "     <SELECT id='product".$product_object->getNum()."_selection' name='product".$product_object->getNum()."_selection'>\n";
            echo "      <OPTION value=''></OPTION>";
            echo "      <OPTION value='approve'>Approve</OPTION>";
            echo "     </SELECT>\n";
         }
         echo "    </TD>\n";
         echo "    <TD>\n";
         # Handle the case of no calrequests
         echo "     <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
         echo "      <TR>\n";
         echo "       <TH></TH>\n";
         echo "       <TH>Status</TH>\n";
         echo "      </TR>\n";
         echo "      <TR>\n";
         echo "       <TD>\n";
         echo "No analyzes\n";
         echo "       </TD>\n";
         echo "       <TD>\n";
         echo $product_object->getStatus('abbr');
         echo "       </TD>\n";
         echo "      </TR>\n";
         echo "     </TABLE>\n";
         echo "    </TD>\n";
         echo "   </TR>\n";
         echo "  </TABLE>\n";
      }
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
      <TABLE width='100%'>
         
       <TR>
        <TD align='right'>
<?PHP
         if ( $showsubmit )
         { echo "<INPUT type='button' value='Submit' onClick='SubmitCB();'>&nbsp;&nbsp;"; }
?>
        </TD>
        <TD>
         <?PHP echo "<A href='order_status.php?num=".$order_object->getNum()."'><INPUT type='button' value='Order Status'></A>"; ?>
        </TD>
       </TR>
       <tr><td colspan='2' align='center'>&nbsp;<div id='messageDiv'></div></td></tr>
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
