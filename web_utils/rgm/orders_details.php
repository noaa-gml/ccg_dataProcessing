<?PHP

require_once ("CCGDB.php");
require_once ("DB_OrderManager.php");
require_once ("DB_ProductManager.php");
require_once ("DB_CalRequestManager.php");
require_once "utils.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : ''; 
ValidateAuthentication($database_object, $user_obj);

?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/tablesorter-blue/style.css">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/php_serialize.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-tablesorter-pager.js"></SCRIPT>
  <SCRIPT>
    $(document).ready(function() 
    { 
        $("#mainTable").tablesorter(); 

        $("input[type=checkbox][id^=col_toggle_]").click(function() {
           var idfields = $(this).attr('id').split('_');

           if ( $(this).prop("checked") == true )
           {
              $("table#mainTable th[id$='_"+idfields[2]+"']").show();
              $("table#mainTable td[id$='_"+idfields[2]+"']").show();
           }
           else
           {
              $("table#mainTable th[id$='_"+idfields[2]+"']").hide();
              $("table#mainTable td[id$='_"+idfields[2]+"']").hide();
           }

           // Find the columns that have been unselected
           var unselectedcols = [];
           $("input[type=checkbox][id^=col_toggle_]").each ( function ()
           {
               if ( $(this).prop("checked") == false )
               {
                  var idfields = $(this).attr('id').split('_');

                  unselectedcols.push(idfields[2]);
               }
           });
           //alert(unselectedcols.join(','));
             
           // Save the preferences to user preferences 
           $.ajax({
              url: 'user_set-preferences.php',
              type: 'get',
              data: { id:location.pathname.split("/").slice(-1).toString(),value:encodeURIComponent(unselectedcols.join(',')) },
              success:function(data)
              {
                 // Display the error to screen
                 if ( data.toString() != '' )
                 { alert('Error saving user preferences: '+data.toString()); }
              }
           }); 
        });
    
        $("#col_table_btn").click(function() {
           if ( $(this).val() == 'Show' )
           {
              $('#col_table').show();
              $(this).val('Hide');
           }
           else
           {
              $('#col_table').hide();
              $(this).val('Show');
           }
        });
    }); 

    $(window).load(function() 
    {
        //alert(location.pathname.split("/").slice(-1).toString());

        // Load the user preferences from the database
        $.ajax({
           url: 'user_get-preferences.php',
           type: 'get',
           data: { id:location.pathname.split("/").slice(-1).toString() },
           success:function(encoded_data)
           {
               //alert('hi '+data.toString());

               // The user has set no user preferences
               if ( encoded_data == '' ) { return; }

               data = decodeURIComponent(encoded_data); 

               var i;
               cols = data.split(',');

               // Loop through each toggle
               $("input[type=checkbox][id^=col_toggle_]").each ( function ()
               {
                  var idfields = $(this).attr('id').split('_');

                  for ( i=0; i < cols.length; i++ )
                  {
                     if ( idfields[2] == cols[i] )
                     {
                        if ( $(this).prop("checked") == true )
                        {
                           // alert(idfields[2]);
                           // Uncheck the checkbox if there is a match in
                           //  user preferences

                           $(this).trigger('click');
                        }
                        break;
                     } 
                  }
               });
           } 
        });
    }); 
  </SCRIPT>
 </HEAD>
 <BODY>

<?PHP

CreateMenu($database_object, $user_obj);

?>
  <H1>Active Orders Details</H1>

<TABLE border='1'>
 <TR>
  <TD>
   <INPUT type='button' value='Show' id='col_table_btn'>
   &nbsp;
   <FONT style='font-weight:bold'>Display columns</FONT>
  </TD>
 </TR>
 <TR>
  <TD>
   <TABLE cellspacing='1' cellpadding='1' id='col_table' style='display:none'>
    <TR>
     <TD valign='top'>
      <INPUT type='checkbox' id='col_toggle_order-num' checked>Order Num<BR>
      <INPUT type='checkbox' id='col_toggle_primary-customer' checked>Primary Customer<BR>
      <INPUT type='checkbox' id='col_toggle_due-date' checked>Due Date<BR>
     </TD>
     <TD valign='top'>
      <INPUT type='checkbox' id='col_toggle_order-needs-analysis' checked>Order Needs Analysis<BR>
      <INPUT type='checkbox' id='col_toggle_cylinder-id' checked>Cylinder ID<BR>
      <INPUT type='checkbox' id='col_toggle_fill-code' checked>Fill Code<BR>
     </TD>
     <TD valign='top'>
      <INPUT type='checkbox' id='col_toggle_calservice' checked>CalService<BR>
      <INPUT type='checkbox' id='col_toggle_target' checked>Target<BR>
      <INPUT type='checkbox' id='col_toggle_analysis-type' checked>Analysis Type<BR>
     </TD>
     <TD valign='top'>
      <INPUT type='checkbox' id='col_toggle_analysis-value' checked>Analysis value<BR>
      <INPUT type='checkbox' id='col_toggle_analysis-repeatability' checked>Analysis Repeatability<BR>
      <INPUT type='checkbox' id='col_toggle_status' checked>Status<BR>
     </TD>
     <TD valign='top'>
      <INPUT type='checkbox' id='col_toggle_actions' checked>Actions<BR>
      <INPUT type='checkbox' id='col_toggle_analyzes' checked>Analyzes<BR>
     </TD>
    </TR>
   </TABLE>
  </TD>
 </TR>
</TABLE>
<TABLE class='tablesorter' id='mainTable'>
 <THEAD>
 <TR>
  <TH id='header_order-num'>Order Num</TH>
  <TH id='header_primary-customer'>Primary Customer</TH>
  <TH id='header_due-date'>Due Date</TH>
  <TH id='header_order-needs-analysis'>Order Needs Analysis</TH>
  <TH id='header_cylinder-id'>Cylinder ID</TH>
  <TH id='header_fill-code'>Fill Code</TH>
  <TH id='header_calservice'>CalService</TH>
  <TH id='header_target'>Target</TH>
  <TH id='header_analysis-type'>Analysis Type</TH>
  <TH id='header_analysis-value'>Analysis Value</TH>
  <TH id='header_analysis-repeatability'>Analysis Repeatability</TH>
  <TH id='header_status'>Status</TH>
  <TH id='header_actions'>Actions</TH>
  <TH id='header_analyzes'>Analyzes</TH>
 </TR>
 </THEAD>
 <TBODY>

<?PHP

$order_objects = DB_OrderManager::getActiveOrders($database_object);

foreach ( $order_objects as $order_object )
{
   $product_objects = DB_ProductManager::searchByOrder($database_object, $order_object);

   foreach ( $product_objects as $product_object )
   {
      $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);

      foreach ( $calrequest_objects as $calrequest_object )
      {
         echo "<TR>";
         echo " <TD id='".$calrequest_object->getNum()."_order-num'>";
         echo $order_object->getNum();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_primary-customer'>";
         echo $order_object->getPrimaryCustomer()->getEmail();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_due-date'>";
         echo $order_object->getDueDate();
         echo " </TD>";
         echo " <TD  id='".$calrequest_object->getNum()."_order-needs-analysis'>";
         echo $order_object->countProductsNeedAnalysis();
         echo " </TD>";
         echo " <TD  id='".$calrequest_object->getNum()."_cylinder-id'>";
         if ( is_object($product_object->getCylinder() ) )
         { echo $product_object->getCylinder()->getID(); }
         echo "</TD>";
         echo " <TD id='".$calrequest_object->getNum()."_fill-code'>";
         if ( is_object($product_object->getCylinder() ) )
         { echo $product_object->getFillCode(); }
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_calservice'>";
         echo $calrequest_object->getCalService()->getAbbreviationHTML();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_target'>";
         echo $calrequest_object->getTargetValue();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_analysis-type'>";
         echo $calrequest_object->getAnalysisType();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_analysis-value'>";
         echo $calrequest_object->getAnalysisValue();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_analysis-repeatability'>";
         echo $calrequest_object->getAnalysisRepeatability();
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_status'>";
         echo "  <TABLE>";
         echo "   <TR>";
         echo "    <TD>";
         echo $calrequest_object->getStatus();
         echo "    </TD>";
         $color = $calrequest_object->getStatusColorHTML();
         echo "    <TD style='background-color:$color'>";
         echo "&nbsp;&nbsp;&nbsp;";
         echo "    </TD>";
         echo "   </TR>";
         echo "  </TABLE>";
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_actions'>";
         echo "  <A href='order_status.php?num=".$order_object->getNum()."'><INPUT type='button' value='View Order'></A>";
         echo " </TD>";
         echo " <TD id='".$calrequest_object->getNum()."_analyzes'>";
         echo "  <PRE>";
         try
         {
            echo join("\n",$calrequest_object->getAnalyzesFromDB());
         }
         catch ( Exception $e )
         {
            ## Do nothing
         }
         echo "  </PRE>";
         echo " </TD>";
         echo "</TR>";
      }
   }
}
echo " </TBODY>";
echo "</TABLE>";

?>

<?PHP NoCacheLinks(); ?>
 </BODY>
</HTML>

<?PHP

exit;

?>

