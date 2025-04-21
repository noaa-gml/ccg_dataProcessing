<?PHP

require_once("CCGDB.php");
require_once("DB_Order.php");
require_once("DB_ProductManager.php");
require_once("DB_CalRequestManager.php");
require_once("DB_CalServiceManager.php");
require_once("DB_CylinderManager.php");
require_once("/var/www/html/inc/validator.php");
require_once("/var/www/html/inc/ccgglib_inc.php");
require_once "utils.php";
require_once "menu_utils.php";

session_start();

?>

<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/validator.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="order_edit.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>

<?PHP

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$order_num = isset($_GET['num']) ? $_GET['num'] : '';
$task = isset($_POST['task']) ? $_POST['task'] : '';
$orderinfostr = ( isset($_POST['orderinfostr'])) ? $_POST['orderinfostr'] : '';

CreateMenu($database_object, $user_obj);

$orderinfo = mb_unserialize($orderinfostr);

$cylinder_size_aarr = DB_CylinderManager::getCylinderSizes($database_object);
natcasesort($cylinder_size_aarr);
#echo "<PRE>";
#print_r($cylinder_size_aarr);
#echo "</PRE>";

$calservice_objects = DB_CalServiceManager::getAnalysisCalServices($database_object);
#echo "<PRE>";
#print_r($calservice_objects);
#echo "</PRE>";

$analysis_type_aarr = DB_CalRequestManager::getAnalysisTypes($database_object);

#echo "<PRE>";
#print_r($orderinfo);
#echo "</PRE>";

$errors = array();
if ( $task === 'save' ||
     $task === 'process' )
{
   #echo "<PRE>";
   #print_r($orderinfo);
   #echo "</PRE>";

   # First check to see if we get any errors
   $errors = SaveObject($database_object, $orderinfo, $task);

   # If there are no errors, do the same thing but save the data
   if ( count($errors) == 0 )
   {
      $errors = SaveObject($database_object, $orderinfo, $task, TRUE);
      # Load the data from the database
      $orderinfo = LoadObject($database_object, $order_num);
   }

   if ( count($errors) == 0 )
   {
      print "Order updated successfully.";
   }
}
elseif ( $task === 'cancel' )
{
   try
   {
      # Cancel the order and then load the data from the database
      $order_object = new DB_Order($database_object, $orderinfo['order-num']);
      $order_object->cancel();
      $order_object->preSaveToDB();
      $order_object->saveToDB($user_obj);

      $orderinfo = LoadObject($database_object, $order_num);
   }
   catch(Exception $e)
   { array_push($errors, $e); }

   if ( count($errors) == 0 )
   {
      echo "Order cancelled.";
      echo "<BR>";
      echo "<A href='orders_overview.php'><INPUT type='button' value='Orders Overview'></A>";
      exit;
   }
}
elseif ( $task === 'product_add' )
{
   #
   # Add a new product through PHP because I am aware of how many
   #   calservices there should be. Also, when the page is first loaded with
   #   a new order this function is needed as well.
   #
   if ( ! isset($orderinfo['products']) )
   { $orderinfo['products'] = array(); }

   array_push($orderinfo['products'], array()); 

   $productnum = count($orderinfo['products'])-1;

   $tmparr = array();

   foreach ( $calservice_objects as $calservice_object )
   {
      array_push($tmparr, array());
   }

   $orderinfo['products'][$productnum]['requested'] = true;
   $orderinfo['products'][$productnum]['calrequests'] = $tmparr;

   $task = '';
}
else
{
   if ( ValidInt($order_num) )
   {
      $orderinfo = LoadObject($database_object, $order_num);
   }
   else
   {
      print "Please provide a valid order number.";
      exit;
   }
}

if ( ! $orderinfo['is-active'] && ! $orderinfo['is-pending'] )
{
   echo "Order has already been completed or cancelled and may no longer be edited.";
   exit;
}

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

  <FORM name='mainform' id='mainform' method='post'>
   <SCRIPT>
    $(document).ready(function()
    {
      $("select[id$='_analysis-type']").change(
         function ()
         {
           var product = $(this).attr('id').split('_')[0];
           var productnum = product.replace(/^product/, '');

           var myCylinderID = $('#'+product+'_cylinder-id');

           // Check that calservice is enabled
           // This checkbox may not exist in the case of a calrequest
           //  that is being processed or is complete
           calservice_checkbox = $(this).attr('id').replace('_analysis-type', '_requested');
           var myCalServiceCheckBox = $('#'+calservice_checkbox);

           if ( myCalServiceCheckBox.val() != undefined &&
                myCalServiceCheckBox.prop("checked") != true )
           {
              $(this).val('1');
              return false;
           }

           // This should only be used for co2, ch4, co, n2o, sf6, h2
           //  as the other calservices do not have data in the database
           calservice_abbr = $(this).attr('id').replace('_analysis-type', '_calservice-abbr');
           var myCalServiceAbbr = $('#'+calservice_abbr);
           if ( myCalServiceAbbr.val() != 'co2' &&
                myCalServiceAbbr.val() != 'ch4' &&
                myCalServiceAbbr.val() != 'co' &&
                myCalServiceAbbr.val() != 'n2o' &&
                myCalServiceAbbr.val() != 'sf6' &&
                myCalServiceAbbr.val() != 'h2' )
           { return false; }

           if ( $(this).val() != '1' )
           {
              var mySelectMenu = $(this);
              target_value = $(this).attr('id').replace('_analysis-type', '_target-value');
              var myTargetValue = $('#'+target_value);

              // Call cylinder_get-last-analysis to retrieve
              // last calibration

              //alert(myCylinderID.val()+' '+myCalServiceAbbr.val());

              $.ajax({
                 url: 'cylinder_get-last-analysis.php',
                 type: 'get',
                 data: { id: myCylinderID.val(),
                         calservice: myCalServiceAbbr.val()  },
                 success:function(data)
                 {
                    if ( data.match(/Error:/) )
                    {
                       mySelectMenu.val("1").change();
                       alert(data);
                    }
                    else
                    {
                       if ( ValidFloat(data.trim()) )
                       {
                          if ( myTargetValue.val() != '' )
                          {
                             if ( myTargetValue.val() != data.trim() &&
                                  confirm("Overwrite current target value?") )
                             { myTargetValue.click().val(data.trim()).blur(); }
                             else
                             { myTargetValue.click().blur(); }
                          }
                          else
                          { myTargetValue.click().val(data.trim()).blur(); }
                       }
                    }
                 } 
              });
           }
         }
      );

       //Validate the entered cylinder ID and retrieve any comments for display.  
      $("input[id$='_cylinder-id']").change(function(){
       
          //Extract out and build various ids from the called input field.
          var cid=$(this).val();
          var commentID= $(this).attr('id').replace(/-id$/,'-comments');
          var productnum=commentID.split("_")[0].replace(/^product/,'');
          
          if (cid=="") {//Clear the comment div when id is erased.
            $("#"+commentID).html("");
          }else{
             //Validate the id and retrieve any cylinder comments.   
             $.ajax({
                    url: 'cylinder_get_info.php',
                    type: 'get',
                    data: { id: cid,
                            data_element: 'comments'  },
                    success:function(data){
                      //Out put whatever was sent back (error or success).
                          $("#"+commentID).html(data);
                    } 
              });
          }
         
      });
      
      // This could probably be changed to .change()
      $("input[id$='_cylinder-id']").blur(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            var productstr = $(this).attr('id').split('_')[0];
            var productnum = productstr.replace(/^product/, '');

            // if the cylinder ID is changed, clear all
            //  the analysis type selects
            if ( orderinfo['products'][productnum]['cylinder-id'] != $(this).val() )
            { 
               $("select[id^='"+productstr+"_'][id$='_analysis-type']").each(
                  function ()
                  {
                     $(this).val('1').blur();
                  }
               );
            }

            // And update the Analysis Type pulldowns
            UpdateAnalysisType(productstr);
         }
      );

      $("input[type=checkbox][id$=_requested], select[id$='_analysis-type']").change(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            var productstr = $(this).attr('id').split('_')[0];

            UpdateDetails(productstr);
         }
      );

      $("input[type=text], input[type=hidden], select, textarea").blur(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            SetValue($(this).attr('id'), $(this).val(), orderinfo);
         }
      );
    });

    $(window).load(function()
    {
      $("input[id$='_cylinder-id']").each(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            var productstr = $(this).attr('id').split('_')[0];

            UpdateAnalysisType(productstr);
         }
      );

      $("input[type=checkbox], input[type=text]").each(
         function ()
         {
            $(this).trigger('change');
            $(this).trigger('blur');
         }
      );

      // Process the radio buttons after the input type=text boxes because
      //  the radio buttons may affect the value of the text boxes
      $('input[type=radio]').each(
         function ()
         {
            // Only fire if the option is selected
            if ( $(this).prop("checked") == true )
            {
               $(this).trigger('click') ;
            }
         }
      );

      $( "#primary-customer-email" ).autocomplete({
         source: availablecustomers
      });

    });

    // This exists in the PHP because I need values from PHP variables
    function UpdateDetails(productstr)
    {
       var productnum = productstr.replace(/^product/, '');

       var myCylinderID = $('#'+productstr+'_cylinder-id');

       var allowrefillflag = 1;
       $("select[id^='"+productstr+"_'][id$='_analysis-type']").each(
          function ()
          {
             // alert($(this).val());
             if ( $(this).val() != '1' &&
                  $(this).prop('disabled') != true )
             {
                allowrefillflag = 0;
                return false;
             }
          }
       );

       var mySizeSelect = $('#'+productstr+'_cylinder-size');
       var myStatusSelect = $('#'+productstr+'_checkin-status');

       if ( myCylinderID.val() != '' )
       { 
          var mySizeOptions = {
              0 : 'From Cylinder ID',
          };
          mySizeSelect.empty();
          $.each(mySizeOptions, function(val, text) {
              mySizeSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });

          if ( allowrefillflag == 1 )
          {
             var myStatusOptions = {
                 '3' : 'Ready for Analysis',
                 '1' : 'Ready for Filling',
             };
          }
          else
          {
             var myStatusOptions = {
                 '3' : 'Ready for Analysis',
             };
          }
          myStatusSelect.empty();
          $.each(myStatusOptions, function(val, text) {
              myStatusSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });
       } 
       else
       {
          var mySizeOptions = {
<?PHP
          $tmparr = array();
          foreach ( $cylinder_size_aarr as $value=>$name )
          {
             array_unshift($tmparr, "$value : '$name'");
          }
          echo join(',', $tmparr);
?>
          };
          mySizeSelect.empty();
          $.each(mySizeOptions, function(val, text) {
              mySizeSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });

          var myStatusOptions = {
              '3' : 'Default',
          };
          myStatusSelect.empty();
          $.each(myStatusOptions, function(val, text) {
              myStatusSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });
       } 

       mySizeSelect.val(orderinfo['products'][productnum]['cylinder-size']).blur(); 
       myStatusSelect.val(orderinfo['products'][productnum]['checkin-status']).blur();

       return false;
    }

    // This exists in the PHP because I need values from PHP variables
    function UpdateAnalysisType(productstr)
    {
       var productnum = productstr.replace(/^product/, '');

       var myCylinderID = $('#'+productstr+'_cylinder-id');

       var myAnalysisTypeOptions;

       if ( myCylinderID.val() != '' )
       { 
          myAnalysisTypeOptions = {
<?PHP
          $tmparr = array();
          foreach ( $analysis_type_aarr as $value=>$name )
          {
             array_push($tmparr, "$value : '$name'");
          }
          echo join(',', $tmparr);
?>
          };
       } 
       else
       {
          myAnalysisTypeOptions = {
<?PHP
             $keys = array_keys($analysis_type_aarr);

             echo $keys[0]." : '".$analysis_type_aarr[$keys[0]]."'";
?>
          };
       } 
       
       var calrequeststr;
       var calrequestnum;
       var disabled;
       $("select[id^='"+productstr+"_'][id$='_analysis-type']").each(
          function ()
          {
             //alert($(this).attr("id"));
             myAnalysisTypeSelect = $(this);

             disabled = 0;

             if ( myAnalysisTypeSelect.prop('disabled') == 'true' )
             { disabled = 1; }

             myAnalysisTypeSelect.empty();
             $.each(myAnalysisTypeOptions, function(val, text) {
                 myAnalysisTypeSelect.append(
                     $('<option></option>').val(val).html(text)
                 );
             });

             calrequeststr = $(this).attr('id').split('_')[1];
             calrequestnum = calrequeststr.replace(/^calrequest/, '');
             myAnalysisTypeSelect.val(orderinfo['products'][productnum]['calrequests'][calrequestnum]['analysis-type']).blur(); 

             if ( disabled == 1 )
             { myAnalysisTypeSelect.prop('disabled', true); }
          }
       );

       return false;
    }

<?PHP
   $sql = "SELECT first_name, last_name, email FROM customers WHERE valid_id = 1 ORDER BY email";

   $results = $database_object->queryData($sql);

   $customerarr = array();
   foreach ( $results as $aarr )
   {
      if ( $aarr['first_name'] == $aarr['last_name'] ||
           $aarr['last_name'] == '' )
      {
         array_push($customerarr, "{ label : \"".str_replace('"', '\"', $aarr['first_name'])." <".$aarr['email'].">\", value: \"".$aarr['email']."\"}");
      }
      else
      {
         array_push($customerarr, "{ label : \"".str_replace('"', '\"', $aarr['first_name']." ".$aarr['last_name'])." <".$aarr['email'].">\", value: \"".$aarr['email']."\"}");
      }
   }
?>

   // Available customers source data
   //  This is used on the customer autocomplete
   var availablecustomers = [
<?PHP echo join(",\n", $customerarr); ?>
   ];

    var customercount = 0;

    function AddCustomer(email)
    {
       email = typeof emal !== 'undefined' ? email : '';

       customercount++;
       htmlstr = '';
       htmlstr = htmlstr+"<TR>";
       htmlstr = htmlstr+" <TD>";
       htmlstr = htmlstr+"  <INPUT type='text' id='customer-email"+customercount+"' name='customer-email"+customercount+"' size='30' value='"+email+"' onBlur='SetValue($(this).attr(\"id\"), $(this).val(), orderinfo);'>";
       htmlstr = htmlstr+" </TD>";
       htmlstr = htmlstr+" <TD>";

       $('#customers tr:last').before(htmlstr);

       // Set the autocomplete feature after the element is created
       $("#customer-email"+customercount).autocomplete({
           source: availablecustomers
       });
    }
   </SCRIPT>
   <INPUT type='hidden' name='task' value=''>

<?PHP
   echo "<INPUT type='hidden' name='orderinfostr' value='$orderinfostr'>";

   $namearr = array();
   SendtoJS("orderinfo",$orderinfo, $namearr);
?>



   <TABLE border='1' cellspacing='3' cellpadding='3'>
    <TR>
     <TD>
      <H1>Order Details<H1>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD>Order num</TD>
        <TD>
         <FONT style='color:blue'>
          <?PHP echo $orderinfo['order-num']; ?>
         </FONT>
        </TD>
       </TR>
       <TR>
        <TD>Current status</TD>
        <TD>
         <FONT style='color:blue'>
          <?PHP echo $orderinfo['status-abbr']; ?>
         </FONT>
        </TD>
       </TR>
       <TR>
        <TD>Due Date</TD>
        <TD>
         <?PHP
         $value = isset($orderinfo['due-date']) ? $orderinfo['due-date'] : '';
         echo "<INPUT type='text' id='due-date' name='due-date' size='10' maxlength='10' value='$value'>";
         ?>
        </TD>
       </TR>
       <TR>
        <TD>MOU number</TD>
        <TD>
         <?PHP
         $value = isset($orderinfo['MOU-number']) ? $orderinfo['MOU-number'] : '';
         echo "<INPUT type='text' id='MOU-number' name='MOU-number' size='10' value='$value'>";
         ?>
        </TD>
       </TR>
       <TR>
        <TD>Organization</TD>
        <TD>
         <?PHP
         $value = isset($orderinfo['organization']) ? $orderinfo['organization'] : '';
         echo "<INPUT type='text' id='organization' name='organization' size='20' value='$value'>";
         ?>
        </TD>
       </TR>
       <TR>
        <TD>Primary Customer Email</TD>
        <TD>
         <?PHP
         $value = isset($orderinfo['primary-customer-email']) ? $orderinfo['primary-customer-email'] : '';
         echo "<INPUT type='text' id='primary-customer-email' name='primary-customer-email' size='30' value='$value'>";
         ?>
        </TD>
       </TR>
       <TR>
        <TD valign='top'>Additional Customers Email</TD>
        <TD>
         <TABLE id='customers'>
          <TBODY>
           <TR>
            <TD>
             <INPUT type='button' value='Add New Customer' onClick='AddCustomer()'>
            </TD>
           </TR>
          </TBODY>
         </TABLE>

         <?PHP
          $customer_email_keys = preg_grep('/^customer-email[0-9]+$/', array_keys($orderinfo));

          #print_r($customer_email_keys);

          echo "<SCRIPT>";
          foreach ( $customer_email_keys as $customer_email_key )
          {
             echo "AddCustomer('".$orderinfo[$customer_email_key]."');\n";
          }
          echo "</SCRIPT>";
         ?>
        </TD>
       </TR>
       <TR>
        <TD>Comments</TD>
        <TD>
         <?PHP
         $value = isset($orderinfo['comments']) ? $orderinfo['comments'] : '';
         echo "<TEXTAREA id='comments' name='comments' cols='60' rows='5'>$value</TEXTAREA>";
         ?>
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE id='products' border='1' cellspacing='5' cellpadding='5'>
       <TBODY>
        <TR>
         <TH>Include</TH>
         <TH>Cylinder ID</TH>
         <TH>Analyzes</TH>
         <TH>Details</TH>
        </TR>
<?PHP

   for ( $productnum=0; $productnum<count($orderinfo['products']); $productnum++ )
   {
      $product_aarr = $orderinfo['products'][$productnum];

      echo "<TR>";
      echo " <TD align='center'>";
      $checked = ( isset($product_aarr['requested']) && $product_aarr['requested'] ) ? 'CHECKED' : '';

      echo "  <INPUT type='checkbox' id='product".$productnum."_requested' name='product".$productnum."_requested' onChange='ProductSelect(this)' $checked>";
      echo " </TD>";
      echo " <TD>";
      $value = isset($product_aarr['cylinder-id']) ? $product_aarr['cylinder-id'] : '';
      if ( isset($product_aarr['in-processing']) &&
           $product_aarr['in-processing'] )
      {
         echo "$value";
         echo "<INPUT type='hidden' id='product".$productnum."_cylinder-id' name='product".$productnum."_cylinder-id' value='$value'>";
      }
      else
      {
         echo "  <INPUT type='text' id='product".$productnum."_cylinder-id' name='product".$productnum."_cylinder-id' size='15' maxlength='15' value='$value' onKeyup='this.value = this.value.toUpperCase();'>";
         echo "  <br><div id='product".$productnum."_cylinder-comments' name='product".$productnum."_cylinder-comments'></div>";
      }
      
      echo " </TD>";
      echo " <TD>";
      echo "  <TABLE border='1' cellspacing='2' cellpadding='2'>";
      echo "   <TR>";
      echo "    <TH>Active</TH>";
      echo "    <TH>Species</TH>";
      echo "    <TH>Target</TH>";
      echo "    <TH>Analysis Type</TH>";
      echo "    <TH>Comments</TH>";
      echo "    <TH>Status</TH>";
      echo "   </TR>";

      $calrequestnum = 0;
      foreach ( $calservice_objects as $calservice_object )
      {
         $calrequest_aarr = $product_aarr['calrequests'][$calrequestnum];

         echo "<TR>";
         echo " <TD align='center'>";

         $requested = ( isset($calrequest_aarr['requested']) && $calrequest_aarr['requested'] ) ? TRUE : FALSE;
         $checked = ( isset($calrequest_aarr['requested']) && $calrequest_aarr['requested'] ) ? 'CHECKED' : '';

         if ( isset($product_aarr['in-processing']) &&
              $product_aarr['in-processing'] &&
              $requested)
         { echo "X"; }
         else
         {
            echo "  <INPUT type='checkbox' id='product".$productnum."_calrequest".$calrequestnum."_requested' name='product".$productnum."_calrequest".$calrequestnum."_requested' onChange='CalServiceSelect(this)' $checked>";
         }
         echo " </TD>";
         echo " <TD>";
         echo $calservice_object->getAbbreviationHTML();
         echo "<INPUT type='hidden' id='product".$productnum."_calrequest".$calrequestnum."_calservice-abbr' name='product".$productnum."_calrequest".$calrequestnum."_calservice-abbr' value='".$calservice_object->getAbbreviation()."'>";
         echo " </TD>";
         echo " <TD>";
         echo "  <TABLE>";
         echo "   <TR>";
         echo "    <TD>";
         $value = ( isset($calrequest_aarr['target-value']) && isset($calrequest_aarr['requested']) && $calrequest_aarr['requested']) ? $calrequest_aarr['target-value'] : 'ambient';
         $option1_checked = ( $value == 'ambient' ) ? 'CHECKED' : '';
         echo "     <INPUT type='radio' id='product".$productnum."_calrequest".$calrequestnum."_target-value-option1' name='product".$productnum."_calrequest".$calrequestnum."_target-value-options' onClick='SetValue(\"product".$productnum."_calrequest".$calrequestnum."_target-value\", \"ambient\", orderinfo);' $option1_checked>";
         echo "    </TD>";
         echo "    <TD>";
         echo " Ambient";
         echo "    </TD>";
         echo "   </TR>";
         echo "   <TR>";
         echo "    <TD>";
         $option2_checked = ( $value != 'ambient' ) ? 'CHECKED' : '';
         echo "     <INPUT type='radio' id='product".$productnum."_calrequest".$calrequestnum."_target-value-option2' name='product".$productnum."_calrequest".$calrequestnum."_target-value-options' onClick='\$(\"#product".$productnum."_calrequest".$calrequestnum."_target-value\").blur();' $option2_checked>";
         echo "    </TD>";
         echo "    <TD>";
         $inputbox_value = ( $value != 'ambient' ) ? $value : '';
         echo "     <INPUT type='text' id='product".$productnum."_calrequest".$calrequestnum."_target-value' name='product".$productnum."_calrequest".$calrequestnum."_target-value' size='10' value='$inputbox_value' onClick='\$(\"#product".$productnum."_calrequest".$calrequestnum."_target-value-option2\").prop(\"checked\", true);'>";
         echo "    </TD>";
         echo "   </TR>";
         echo "  </TABLE>";
         echo " </TD>";
         echo " <TD>";

         $input_value = isset($calrequest_aarr['analysis-type']) ? $calrequest_aarr['analysis-type'] : '';

         echo "  <SELECT id='product".$productnum."_calrequest".$calrequestnum."_analysis-type' name='product".$productnum."_calrequest".$calrequestnum."_analysis-type'>";

         echo "  </SELECT>";

         echo " </TD>";
         echo " <TD>";
         $input_value = ( isset($calrequest_aarr['comments']) ) ? $calrequest_aarr['comments'] : '';
         echo "  <INPUT type='text' id='product".$productnum."_calrequest".$calrequestnum."_comments' name='product".$productnum."_calrequest".$calrequestnum."_comments' size='15' value='".htmlentities($input_value, ENT_QUOTES, 'UTF-8')."'>";
         echo " </TD>";
         echo " <TD>";
         echo "  <TABLE>";
         echo "   <TR>";
         $value = isset($calrequest_aarr['status']) ? $calrequest_aarr['status'] : '';
         echo "    <TD>$value</TD>";
         $value = isset($calrequest_aarr['status-color']) ? $calrequest_aarr['status-color'] : 'transparent';
         echo "    <TD style='background-color: $value'>&nbsp;&nbsp;&nbsp;</TD>";
         echo "   </TR>";
         echo "  </TABLE>";
         echo " </TD>";
         echo "</TR>";

         $calrequestnum++;
      }
?>
         </TABLE>
        </TD>
        <TD>
         <TABLE>
<?PHP
         if ( isset($product_aarr['in-processing']) &&
              $product_aarr['in-processing'] )
         {
         }
         else
         {
?>
          <TR>
           <TH>Cylinder Size</TH>
           <TD>
            <?PHP echo "<SELECT id='product".$productnum."_cylinder-size' name='product".$productnum."_cylinder-size'>"; ?>
             <OPTION value='0'>From Cylinder ID</OPTION>
            </SELECT>
           </TD>
          </TR>
          <TR>
           <TH>Check-In Status</TH>
           <TD>
            <?PHP echo "<SELECT id='product".$productnum."_checkin-status' name='product".$productnum."_checkin-status'>"; ?>
            </SELECT>
           </TD>
          </TR>
<?PHP
         }

?>
          <TR>
           <TH>Comments</TH>
          </TR>
          <TR>
           <TD colspan='2'>
<?PHP
            echo "<TEXTAREA id='product".$productnum."_comments' name='product".$productnum."_comments' cols='30'>";
            $value = isset($product_aarr['comments']) ? $product_aarr['comments'] : '';
            echo $value;
            echo "</TEXTAREA>";
?>
           </TD>
          </TR>
         </TABLE>
        </TD>
       </TR>
<?PHP
   }
?>
        <TR>
         <TD colspan='4'>
          <INPUT id='product_add' type='button' value='Add New Product' onClick='SubmitCB("product_add")'>
         </TD>
        </TR>
       </TBODY>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <TABLE cellspacing='10' cellpadding='10'>
       <TR>
<?PHP
   if ( $orderinfo['is-active'] )
   {
      echo " <TD>";
      echo "  <INPUT type='button' value='Save Order' onClick='SubmitCB(\"save\")'>";
      echo " </TD>";
      echo " <TD>";
      echo "  <INPUT type='button' style='background-color:red' value='Order Cancel' onClick='SubmitCB(\"cancel\")'>";
      echo " </TD>";
   }
   elseif ( $orderinfo['is-pending'] )
   {
      echo " <TD>";
      echo "  <INPUT type='button' value='Save Order' onClick='SubmitCB(\"save\")'>";
      echo " </TD>";
      echo " <TD>";
      echo "  <INPUT type='button' value='Save & Process Order' onClick='SubmitCB(\"process\")'>";
      echo " </TD>";
      echo " <TD>";
      echo "  <INPUT type='button' style='background-color:red' value='Order Cancel' onClick='SubmitCB(\"cancel\")'>";
      echo " </TD>";
   }
   echo " <TD>";
   echo "  <A href='order_status.php?num=".$orderinfo['order-num']."'>";
   echo "   <INPUT type='button' value='Discard Changes'>";
   echo "  </A>";
   echo " </TD>";
   echo " <TD>";
   echo "  <A href='order_status.php?num=".$orderinfo['order-num']."'>";
   echo "   <INPUT type='button' value='Order Status'>";
   echo "  </A>";
   echo " </TD>";
?>
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
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'>
        </TD>
       </TR>
       <TR>
        <TD align='left' width='50%'>
         <A href='index.php'><INPUT type='button' value='Home'></A>
        </TD>
        <TD align='right' width='50%'>
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

function LoadObject(DB $input_database_object, $order_num)
{
   $calservice_objects = DB_CalServiceManager::getAnalysisCalServices($input_database_object);

   $info = array();

   $order_object = new DB_Order($input_database_object, $order_num);

   $product_objects = DB_ProductManager::searchByOrder($input_database_object, $order_object);

   $info['products'] = array();

   foreach ( $product_objects as $product_object )
   {
      $product_aarr = array();

      $calrequest_objects = DB_CalRequestManager::searchByProduct($input_database_object, $product_object);

      # Loop through each calservice to create the structure for the
      # associative array. If we match with a calrequest then fill
      # in the appropriate information
      $product_aarr['calrequests'] = array();
      foreach ( $calservice_objects as $calservice_object )
      {
         $calrequest_aarr = array();
         foreach ( $calrequest_objects as $calrequest_object )
         {
            if ( $calrequest_object->getCalService()->matches($calservice_object) )
            {
               $calrequest_aarr['calrequest_num'] = $calrequest_object->getNum();
               $calrequest_aarr['requested'] = true;
               $calrequest_aarr['calservice-abbr'] = $calservice_object->getAbbreviation();
               $calrequest_aarr['target-value'] = $calrequest_object->getTargetValue();
               $calrequest_aarr['analysis-type'] = $calrequest_object->getAnalysisType('num');
               $calrequest_aarr['comments'] = $calrequest_object->getComments();
               $calrequest_aarr['status'] = $calrequest_object->getStatus();
               $calrequest_aarr['status-color'] = $calrequest_object->getStatusColorHTML();
               break;
            }
         }
         array_push($product_aarr['calrequests'], $calrequest_aarr); 
      }

      # This call is needed because when we instantiated the CalRequests
      #    it may have updated the status of the Product
      $product_object->loadFromDB();

      $product_aarr['product_num'] = $product_object->getNum();
      $product_aarr['requested'] = true;

      if ( is_object($product_object->getCylinder()) )
      {
         $product_aarr['cylinder-id'] = $product_object->getCylinder()->getID();
         $product_aarr['cylinder-size'] = '';
         $product_aarr['checkin-status'] = $product_object->getCylinder()->getCheckInStatus('num');
      }
      else
      {
         $product_aarr['cylinder-size'] = $product_object->getCylinderSize('num');
         $product_aarr['checkin-status'] = '3';
      }
      
      $product_aarr['status_abbr'] = $product_object->getStatus();
      $product_aarr['is-active'] = ( $product_object->isActive() ) ? '1' : '0';
      $product_aarr['in-processing'] = ( $product_object->inProcessing() ) ? '1' : '0';
      $product_aarr['comments'] = $product_object->getComments();


      array_push($info['products'], $product_aarr);
   }

   # This call is needed because when we instantiated the Products
   #    it may have updated the status of the Order
   $order_object->loadFromDB();

   $info['order-num'] = $order_object->getNum();
   $info['status-abbr'] = $order_object->getStatus('abbr');
   $info['is-active'] = ( $order_object->isActive() ) ? '1' : '0';
   $info['is-pending'] = ( $order_object->isPending() ) ? '1' : '0';
   $info['due-date'] = $order_object->getDueDate();
   $info['MOU-number'] = $order_object->getMOUNumber();
   $info['organization'] = $order_object->getOrganization();
   $info['comments'] = $order_object->getComments();

   if ( is_object($order_object->getPrimaryCustomer()) )
   {
      $info['primary-customer-email'] = $order_object->getPrimaryCustomer()->getEmail();
   }

   $customercount = 0;

   foreach ( $order_object->getCustomers() as $customer_object )
   {
      $info['customer-email'.$customercount] = $customer_object->getEmail();
      $customercount++;
   }

   #echo "<PRE>";
   #print_r($order_object);
   #echo "</PRE>";

   return ($info);
}

function SaveObject(DB $input_database_object, $info, $task='save', $save=FALSE)
{
   $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

   #echo "<PRE>";
   $errors = array();
   try
   {
      $order_object = new DB_Order($input_database_object, $info['order-num']);
      $order_object->setDueDate($info['due-date']);
      $order_object->setMOUNumber($info['MOU-number']);
      $order_object->setOrganization($info['organization']);

      if ( isset($info['primary-customer-email']) )
      {
         $customer_object = new DB_Customer($input_database_object, $info['primary-customer-email']);
         $order_object->setPrimaryCustomer($customer_object);
      }

      $order_object->setComments($info['comments']);

      $customer_email_keys = preg_grep('/^customer-email[0-9]+$/', array_keys($info));
    
      #print_r($customer_email_keys);
 
      $customer_objects = array(); 
      foreach ( $customer_email_keys as $customer_email_key )
      {
         if ( ! isBlank($info[$customer_email_key]) )
         {
            $customer_object = new DB_Customer($input_database_object, $info[$customer_email_key]);
            array_push($customer_objects, $customer_object);
         }
      }
      $order_object->setCustomers($customer_objects);

      if ( $task === 'process' )
      { $order_object->process(); }


      if ( $save )
      { $order_object->saveToDB($user_obj); }
      else
      { $order_object->preSaveToDB(); }

      $delete_product_objects = DB_ProductManager::searchByOrder($input_database_object, $order_object);

      #echo "<PRE>";
      #print_r($delete_product_objects);
      #echo "</PRE>";
      #print_r($order_object);

      foreach ( $info['products'] as $product_aarr )
      {
         try
         {
            if ( $product_aarr['requested'] )
            {
               if ( isset($product_aarr['product_num']) &&
                    ValidInt($product_aarr['product_num']) )
               {
                  # Update existing product

                  $product_object = new DB_Product($input_database_object, $product_aarr['product_num']);

                  if ( isset($product_aarr['cylinder-id']) &&
                       $product_aarr['cylinder-id'] != '' )
                  {
                     $cylinder_object = new DB_Cylinder($input_database_object, $product_aarr['cylinder-id'], 'id');
                     $product_object->setCylinder($cylinder_object);
                     $product_object->setCylinderSize($cylinder_object->getSize());
                     $product_object->getCylinder()->setCheckInStatus($product_aarr['checkin-status']);
                  }
                  else
                  {
                     $product_object->setCylinder('');
                     $product_object->setCylinderSize($product_aarr['cylinder-size']);
                  }

                  for ( $i=0; $i<count($delete_product_objects); $i++ )
                  {
                     if ( $product_object->getNum() == $delete_product_objects[$i]->getNum() )
                     {
                        unset($delete_product_objects[$i]);
                        break;
                     }
                  }
                  $delete_product_objects = array_values($delete_product_objects);

                  #echo "UPDATE<BR>";
                  #echo "<PRE>";
                  #print_r($product_object);
                  #echo "</PRE>";
               }
               else
               {
                  # Create new product

                  if ( isset($product_aarr['cylinder-id']) &&
                       $product_aarr['cylinder-id'] != '' )
                  {
                     $cylinder_object = new DB_Cylinder($input_database_object, $product_aarr['cylinder-id'], 'id');
                     $product_object = new DB_Product($input_database_object, $order_object, $cylinder_object->getSize());

                     $product_object->setCylinder($cylinder_object);
                     $product_object->getCylinder()->setCheckInStatus($product_aarr['checkin-status']);
                  }
                  else
                  {
                     $product_object = new DB_Product($input_database_object, $order_object, $product_aarr['cylinder-size']);
                  }

                  #echo "INSERT<BR>";
                  #print_r($product_object);
               }

               $product_object->setComments($product_aarr['comments']);

               if ( $task === 'process' ||
                    ! $order_object->isPending() )
               { $product_object->process(); }

               #echo "<PRE>";
               #print_r($product_object);
               #echo "</PRE>";


               if ( $save )
               { $product_object->saveToDB($user_obj); }
               else
               { $product_object->preSaveToDB(); }

               foreach ( $product_aarr['calrequests'] as $calrequest_aarr )
               {
                  try
                  {
                     if ( isset($calrequest_aarr['requested']) &&
                          $calrequest_aarr['requested'] == true )
                     {
                        if ( isset($calrequest_aarr['calrequest_num']) &&
                             ValidInt($calrequest_aarr['calrequest_num']) )
                        {
                           # UPDATE

                           $calrequest_object = new DB_CalRequest($input_database_object, $calrequest_aarr['calrequest_num']);
                           $calrequest_object->setTargetValue($calrequest_aarr['target-value']);
                           $calrequest_object->setAnalysisType($calrequest_aarr['analysis-type'], 'num');
                           #echo "UPDATE<BR>";
                           #print_r($calrequest_object);
                        }
                        else
                        {
                           # INSERT

                           $calservice_object = new DB_CalService($input_database_object, $calrequest_aarr['calservice-abbr']);
                           $calrequest_object = new DB_CalRequest($input_database_object, $product_object, $calservice_object, $calrequest_aarr['target-value'], $calrequest_aarr['analysis-type']);

                           #echo "INSERT<BR>";
                           #print_r($calrequest_object);
                        }

                        if ( isset($calrequest_aarr['comments']) ) 
                        { $calrequest_object->setComments($calrequest_aarr['comments']); }

                        if ( $task === 'process' ||
                             ! $product_object->isPending() )
                        { $calrequest_object->process(); }


                        #echo "<PRE>";
                        #print_r($calrequest_object);
                        #echo "</PRE>";

                        if ( $save )
                        { $calrequest_object->saveToDB($user_obj); }
                        else
                        { $calrequest_object->preSaveToDB(); }
                     }
                     else
                     {
                        if ( isset($calrequest_aarr['calrequest_num']) &&
                             ValidInt($calrequest_aarr['calrequest_num']) )
                        {
                           # DELETE
                           $calrequest_object = new DB_CalRequest($input_database_object, $calrequest_aarr['calrequest_num']);
                           #echo "DELETE<BR>";
                           #print_r($calrequest_object);

                           if ( $save )
                           { $calrequest_object->deleteFromDB($user_obj); }
                        }
                     }
                  }
                  catch ( Exception $e )
                  { array_push($errors, $e); }
               }
            }
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      # Remove the products that are left in $delete_product_objects
      # from the current order
      # This also catches the case where a new product was created in the interface but
      #  will not be saved

      foreach ( $delete_product_objects as $product_object )
      {
         if ( $product_object->isActive() )
         {
            $product_object->setOrder('');

            #echo "UPDATE<BR>";
            #print_r($product_object);

            if ( $save )
            { $product_object->saveToDB($user_obj); }
            else
            { $product_object->preSaveToDB(); }
         }
         else
         {
            #echo "DELETE<BR>";
            #print_r($product_object);

            if ( $save )
            { $product_object->deleteFromDB($user_obj); }
         }
      }

      if ( $save )
      {
         # This must be done at the end once the database has been updated
         if ( isset($info['calculate-due-date']) &&
              $info['calculate-due-date'] == '1' )
         {
            # Calculate due date using today as the base day
            $order_object->calculateDueDate(date("Y-m-d"));
            $order_object->saveToDB($user_obj);
         }
      }
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   #echo "</PRE>";
   return ($errors);
}

?>
