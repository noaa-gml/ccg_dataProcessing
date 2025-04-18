<?PHP

require_once ("CCGDB.php");
require_once("DB_Order.php");
require_once("DB_ProductManager.php");
require_once("DB_CalRequestManager.php");
require_once("DB_CalServiceManager.php");
require_once("DB_CylinderManager.php");
require_once("Log.php");
require_once("/var/www/html/inc/ccgglib_inc.php");
require_once "utils.php";
require_once "menu_utils.php";
require_once "/var/www/html/inc/validator.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

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
  <SCRIPT language='JavaScript' src='php_urlencode.js'></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/validator.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="order_creation.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>
<?PHP

$task = isset($_POST['task']) ? $_POST['task'] : '';
$orderinfostr = ( isset($_POST['orderinfostr'])) ? $_POST['orderinfostr'] : '';

$orderinfo = mb_unserialize(urldecode($orderinfostr));

CreateMenu($database_object, $user_obj);

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

if ( ! is_array($orderinfo) )
{
   $orderinfo = array();

   $task = 'product_add';
}

#echo "<PRE>";
#print_r($orderinfo);
#echo "</PRE>";

$errors = array();
if ( $task === 'submit' || $task == 'pending' )
{
   #echo "<PRE>";
   #print_r($orderinfo);
   #echo "</PRE>";

   # First check to see if we get any errors
   list($errors, $order_num) = CreateObject($database_object, $orderinfo, $task);

   # If there are no errors, do the same thing but save the data
   if ( count($errors) == 0 )
   {
      list($errors, $order_num) = CreateObject($database_object, $orderinfo, $task, TRUE);

      if ( count($errors) == 0 )
      {
         echo "Order created successfully.";
         echo "<BR>";
         echo "<A href='order_status.php?num=$order_num'><INPUT type='button' value='Orders Status'></A>";
         exit;
      }
   }
}
elseif ( $task === 'product_add' )
{
   $product_add_number = ( isset($_POST['product_add_number'])) ? $_POST['product_add_number'] : 1;

   if ( ! ValidInt($product_add_number) )
   { $product_add_number = 1; }

   #
   # Add a new product through PHP because I am aware of how many
   #   calservices there should be. Also, when the page is first loaded with
   #   a new order this function is needed as well.
   #
   if ( ! isset($orderinfo['products']) )
   { $orderinfo['products'] = array(); }

   for ( $product_counter=0; $product_counter<$product_add_number; $product_counter++ )
   {
      array_push($orderinfo['products'], array()); 

      $productnum = count($orderinfo['products'])-1;

      $tmparr = array();

      foreach ( $calservice_objects as $calservice_object )
      {
         array_push($tmparr, array());
      }

      $orderinfo['products'][$productnum]['calrequests'] = $tmparr;
   }

   $task = '';
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
   echo "<TR><TD>";
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
   echo "</TD></TR>";
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
           calservice_checkbox = $(this).attr('id').replace('_analysis-type', '_requested');
           var myCalServiceCheckBox = $('#'+calservice_checkbox);
           if ( myCalServiceCheckBox.prop("checked") != true )
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
           
            var productstr = $(this).attr('id').split('_')[0];
            var productnum = productstr.replace(/^product/, '');

            if ( orderinfo['products'][productnum]['cylinder-id'] != $(this).val() )
            {
               // if the cylinder ID is changed, clear all
               //  the analysis type selects
               $("select[id^='"+productstr+"_'][id$='_analysis-type']").each(
                  function ()
                  {
                     $(this).val('1').blur();
                  }
               );
            }

            // Then update the Details section
            UpdateDetails(productstr);

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


      $("input[type=checkbox], input[type=text], select, textarea").each(
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

       // This input needs to have onBlur() set because it is created after document.ready()
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
      <H1>Order Creation</H1>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD>Due Date</TD>
        <TD>
         <TABLE>
          <TR>
           <TD>
         <?PHP

         $today = date("Y-m-d", strtotime("+3 months"));
         $value = isset($orderinfo['due-date']) ? $orderinfo['due-date'] : $today;
         echo "<INPUT type='text' id='due-date' name='due-date' size='10' maxlength='10' value='$value'>";
         ?>
           </TD>
           <TD>
            <?PHP
            if ( isset($orderinfo['calculate-due-date']) )
            {
               if ( $orderinfo['calculate-due-date'] )
               { $checked = 'CHECKED'; }
               else
               { $checked = ''; }
            }
            else
            { $checked = 'CHECKED'; }

            echo "  <INPUT type='checkbox' id='calculate-due-date' name='calculate-due-date' $checked onChange='SetValue(this.id, this.checked, orderinfo);'> Calculate based on order";
            ?>
           </TD>
          </TR>
         </TABLE>
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

         <SCRIPT>
         <?PHP
          $customer_email_keys = preg_grep('/^customer-email[0-9]+$/', array_keys($orderinfo));

          #print_r($customer_email_keys);

          foreach ( $customer_email_keys as $customer_email_key )
          {
             echo "AddCustomer('".$orderinfo[$customer_email_key]."');\n";
          }
         ?>

         </SCRIPT>
        </TD>
       </TR>
       <TR>
        <TD>Order Comments</TD>
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
         <TH>Cylinder ID</TH>
         <TH>Analyzes</TH>
         <TH>Details</TH>
         <TD></TD>
        </TR>
<?PHP

   for ( $productnum=0; $productnum<count($orderinfo['products']); $productnum++ )
   {
      $product_aarr = $orderinfo['products'][$productnum];

      echo "<TR>";
      echo " <TD>";
      $value = isset($product_aarr['cylinder-id']) ? $product_aarr['cylinder-id'] : '';
      echo "  <INPUT type='text' id='product".$productnum."_cylinder-id' name='product".$productnum."_cylinder-id' size='15' maxlength='15' value='$value' onKeyup='this.value = this.value.toUpperCase();'>";
      echo "  <br><div id='product".$productnum."_cylinder-comments' name='product".$productnum."_cylinder-comments'></div>";
      echo " </TD>";
      echo " <TD>";
      echo "  <TABLE border='1' cellspacing='2' cellpadding='2'>";
      echo "   <TR>";
      echo "    <TH></TH>";
      echo "    <TH>Species</TH>";
      echo "    <TH>Target</TH>";
      echo "    <TH>Analysis Type</TH>";
      echo "    <TH>Comments</TH>";
      echo "   </TR>";

      $calrequestnum = 0;
      foreach ( $calservice_objects as $calservice_object )
      {
         $calrequest_aarr = $product_aarr['calrequests'][$calrequestnum];

         echo "<TR>";
         echo " <TD>";
         $checked = ( isset($calrequest_aarr['requested']) && $calrequest_aarr['requested'] ) ? 'CHECKED' : '';
         echo "  <INPUT type='checkbox' id='product".$productnum."_calrequest".$calrequestnum."_requested' name='product".$productnum."_calrequest".$calrequestnum."_requested' onChange='CalServiceSelect(this)' $checked>";
         echo " </TD>";
         echo " <TD>";
         echo $calservice_object->getAbbreviationHTML();
         echo "<INPUT type='hidden' id='product".$productnum."_calrequest".$calrequestnum."_calservice-abbr' name='product".$productnum."_calrequest".$calrequestnum."_calservice-abbr' value='".$calservice_object->getAbbreviation()."'>";
         echo "<INPUT type='hidden' id='product".$productnum."_calrequest".$calrequestnum."_estimated-processing-days' name='product".$productnum."_calrequest".$calrequestnum."_estimated-processing-days' value='".$calservice_object->getEstimatedProcessingDays()."'>";
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
         $input_value = ( isset($calrequest_aarr['analysis-type']) ) ? $calrequest_aarr['analysis-type'] : '';
         echo "  <SELECT id='product".$productnum."_calrequest".$calrequestnum."_analysis-type' name='product".$productnum."_calrequest".$calrequestnum."_analysis-type'>";
         echo "  </SELECT>";
         echo " </TD>";
         echo " <TD>";
         $input_value = ( isset($calrequest_aarr['comments']) ) ? $calrequest_aarr['comments'] : '';
         echo "  <INPUT type='text' id='product".$productnum."_calrequest".$calrequestnum."_comments' name='product".$productnum."_calrequest".$calrequestnum."_comments' size='15' value='".htmlentities($input_value, ENT_QUOTES, 'UTF-8')."'>";
         echo " </TD>";
         echo "</TR>";

         $calrequestnum++;
      }
?>
         </TABLE>
        </TD>
        <TD>
         <TABLE>
          <TR>
           <TH>Cylinder Size</TH>
           <TD>
            <?PHP echo "<SELECT id='product".$productnum."_cylinder-size' name='product".$productnum."_cylinder-size'>";
             ?>
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
        <TD>
         <?PHP echo "<INPUT id='product".$productnum."_delete' type='button' value='Remove' onClick='ProductDelete(this)'>"; ?>
        </TD>
       </TR>
<?PHP
   }
?>
        <TR>
         <TD>
          Add <INPUT id='product_add_number' name='product_add_number' type='text' value='1' size='2'> new products. <INPUT id='product_add' type='button' value='Add Product(s)' onClick='SubmitCB("product_add")'>
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
        <TD>
         <INPUT type='button' value='Submit Order' onClick='SubmitCB("submit")'>
        </TD>
        <TD>
         <INPUT type='button' value='Pending Order' onClick='SubmitCB("pending")'>
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
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'>
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

function CreateObject($input_database_object, $info, $task='submit', $save=FALSE)
{
   $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

   #echo "<PRE>";
   $errors = array();
   try
   {
      $product_objects = array();
      $calrequest_objects = array();
      foreach ( $info['products'] as $product_aarr )
      {
         try
         {
            if ( isset($product_aarr['cylinder-id']) && $product_aarr['cylinder-id'] != '' )
            {
               $cylinder_object = new DB_Cylinder($input_database_object, $product_aarr['cylinder-id'], 'id');

               $product_object = new DB_Product($input_database_object, '', $cylinder_object->getSize());
               $product_object->setCylinder($cylinder_object);
               $product_object->getCylinder()->setCheckInStatus($product_aarr['checkin-status']);
            }
            else
            {
               $product_object = new DB_Product($input_database_object, '', $product_aarr['cylinder-size']);
            }

            $product_object->setComments($product_aarr['comments']);

            if ( $task === 'submit' )
            { $product_object->process(); }

            $product_object->preSaveToDB();

            if ( $save )
            {
               #echo "<PRE>";
               #print_r($product_object);
               #echo "</PRE>";

               $product_object->saveToDB($user_obj);
            }
            array_push($product_objects, $product_object);

            #print_r($product_object);

            foreach ( $product_aarr['calrequests'] as $calrequest_aarr )
            {
               try
               {
                  if ( ! isset($calrequest_aarr['requested']) ||
                       $calrequest_aarr['requested'] != true )
                  { continue; }

                  $calservice_object = new DB_CalService($input_database_object, $calrequest_aarr['calservice-abbr']);
                  $calrequest_object = new DB_CalRequest($input_database_object, $product_object, $calservice_object, $calrequest_aarr['target-value'], $calrequest_aarr['analysis-type']);
                  if ( isset($calrequest_aarr['comments']) )
                  { $calrequest_object->setComments($calrequest_aarr['comments']); }

                  # If the user asked this to be pending
                  if ( $task === 'submit' )
                  { $calrequest_object->process(); }

                  $calrequest_object->preSaveToDB();

                  if ( $save )
                  {
                     #echo "<PRE>";
                     #print_r($calrequest_object);
                     #echo "</PRE>";

                     $calrequest_object->saveToDB($user_obj);
                  }
                  array_push($calrequest_objects, $calrequest_object);

                  #echo "<PRE>";
                  #print_r($calservice_object);
                  #echo "</PRE>";

                  #echo "<PRE>";
                  #print_r($calrequest_object);
                  #echo "</PRE>";
               }
               catch ( Exception $e )
               { array_push($errors, $e); }
            }

            #echo "<PRE>";
            #print_r($product_object);
            #echo "</PRE>";
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      # Check to make sure a cylinder ID is only used once
      $tmpaarr = array();
      foreach ( $product_objects as $product_object )
      {
         $cylinder_object = $product_object->getCylinder();
         if ( is_object($cylinder_object) )
         {
            if ( ! isset($tmpaarr[$cylinder_object->getID()]) )
            { $tmpaarr[$cylinder_object->getID()] = 1; }
            else
            { $tmpaarr[$cylinder_object->getID()]++; }
         }
      }

      foreach ( $tmpaarr as $id=>$count )
      {
         try
         {
            if ( $count > 1 )
            { throw new Exception("Cylinder ID '$id' assigned more than once."); }
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( count($errors) == 0 )
      {
         # If there are no errors, then try to create an order. This is because
         # when we create an order an e-mail is sent to the customer so only do
         # that if we know we will be successful
         try
         {
            $order_object = new DB_Order($input_database_object, $info['due-date']);

            if ( isset($info['MOU-number']) && $info['MOU-number'] != '' )
            { $order_object->setMOUNumber($info['MOU-number']); }
            else
            { $order_object->setMOUNumber(''); }

            if ( isset($info['organization']) && $info['organization'] != '' )
            { $order_object->setOrganization($info['organization']); }
            else
            { $order_object->setOrganization(''); }

            if ( isset($info['primary-customer-email']) )
            {
               $customer_object = new DB_Customer($input_database_object, $info['primary-customer-email']);
               $order_object->setPrimaryCustomer($customer_object);
            }

            $order_object->setComments($info['comments']);

            $customer_email_keys = preg_grep('/^customer-email[0-9]+$/', array_keys($info));

            #print_r($customer_email_keys);

            foreach ( $customer_email_keys as $customer_email_key )
            {
               if ( $info[$customer_email_key] != '' )
               {
                  $customer_object = new DB_Customer($input_database_object, $info[$customer_email_key]);
                  $order_object->addCustomer($customer_object);
               }
            }

            if ( $task === 'submit' )
            { $order_object->process(); }

            $order_object->preSaveToDB();

            if ( $save )
            {
               #echo "<PRE>";
               #print_r($calrequest_object);
               #echo "</PRE>";

               $order_object->saveToDB($user_obj);

               # Now assign to each product and save again
               foreach ( $product_objects as $product_object )
               {
                  $product_object->setOrder($order_object);
                  $product_object->saveToDB($user_obj);
               }


               # This must be done at the end once the database has been updated
               if ( isset($info['calculate-due-date']) &&
                    $info['calculate-due-date'] == '1' )
               {
                  $order_object->calculateDueDate();
                  $order_object->saveToDB($user_obj);
               }
            }
         }
         catch ( Exception $e )
         { array_push($errors, $e); }

         #echo "<PRE>";
         #print_r($order_object);
         #echo "</PRE>";
      }

      if ( $save && count($errors) > 0 )
      {
         # If there are errors on a save then make sure we cleanup
         if ( isset($order_object) &&
              is_object($order_object) )
         { $order_object->cancel(); }

         foreach ( $product_objects as $product_object )
         { $product_object->deleteFromDB($user_obj); }

         foreach ( $calrequest_objects as $calrequest_object )
         { $calrequest_object->deleteFromDB($user_obj); }
      }
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   #echo "</PRE>";
   if ( isset($order_object) &&
        is_object($order_object) )
   {
      return (array($errors, $order_object->getNum()));
   }

   return (array($errors, ''));
}

?>
