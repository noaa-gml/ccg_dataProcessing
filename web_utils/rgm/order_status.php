<?PHP
/*jwm - 10/15
 *Several minor modifications to layout and added a show/hide arrow for calibration details
 *
 */
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

#echo "<PRE>";
#print_r($input_data_aarr);
#echo "</PRE>";

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

#
# Process input_data_aarr if necessary
#
if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'complete' )
{
   # Mark the order as 'order complete'
   $order_object->complete();
   $order_object->saveToDB($user_obj);
}

?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <LINK rel="stylesheet" type="text/css" href="styles.css">
  <SCRIPT language='JavaScript' src="/inc/php_serialize.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="order_status.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
  <script type="text/javascript">
<!--
    function toggle_visibility(id,link) {
       var e = document.getElementById(id);
       var l = document.getElementById(link);
       
       if(e.style.display == ''){
          e.style.display = 'none';
          l.innerHTML= '&darr;';
       }else{
          e.style.display = '';
          l.innerHTML= '&uarr;';
       }
    }
//-->
</script>
 </HEAD>
 <BODY>
<div class='page'>
<div class='header'>
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
   echo "<TABLE>
            <TR>
               <TD>The following errors were encountered:</TD>
            </TR>
            <TR>
               <TD>
                  <UL>";
                     foreach ( $errors as $e )
                     {
                        #Log::update($user_obj->getUsername(), $e->__toString());
                        #echo "    <LI><DIV style='color:red'>".$e->getMessage()."</DIV></LI>";
                        echo "    <LI><DIV style='color:red'>".$e->__toString()."</DIV></LI>";
                     }
   echo "         </ul>
               </td>
            </tr>
         </table>";
}

?>

<FORM name='mainform' id='mainform' method='post'>
<INPUT type='hidden' id='input_data' name='input_data'>
<table width='100%' cellpadding='0' border='0' cellspacing='0'>
   <tr>
      <td style='vertical-align: top;min-width:35%;'>
            <table>
               <tr>
                  <td><span class='title1'>Order Status</span></td>
               </tr>
               <tr>
                  <td><span class='title2' style='color:blue'></font><?php echo $order_object->getStatus();?></span></td>
               </tr>
               <tr>
                  <td><span class='label'>Due:</span> <span class='data'><?PHP echo $order_object->getDueDate(); ?></span></td>
               </tr>
            </table>
      </td>
      <td>
         <table width='100%'>
            <tr>
               <td class='label'>MOU:</td><td class='data'><?PHP echo $order_object->getMOUNumber(); ?></td>
            </tr>
            <tr>
               <td class='label'>Organization:</td><td class='data'><?PHP echo $order_object->getOrganization(); ?></td>
            </tr>
            <tr>
               <td class='label'>Primary Contact:</td>
               <td class='data'><?PHP
                     $customer_object = $order_object->getPrimaryCustomer();

                     if ( is_object($customer_object) ){
                        echo htmlentities($customer_object->getFirstName().' '.$customer_object->getLastName().' <'.$customer_object->getEmail().'>', ENT_QUOTES, 'UTF-8');
                     }
       
               ?>
               </td>
            </tr>
            <?PHP               
            if ( is_object($order_object->getShippingLocation()) ){
               echo "<TR><TD class='label'>Shipping location:</TD><TD class='data'>".$order_object->getShippingLocation()->getName()."</td></TR>";
            }?>
            
            <?php
               $comments=$order_object->getComments();
               if($comments){
                  echo "<tr><td class='label'>Comments:</td><td class='data'>".htmlentities($comments, ENT_QUOTES, 'UTF-8')."</td></tr>";
               }
            ?>
            <tr>
               <td colspan='2' style='text-align: right' class='sm_data'>Created: <?php echo $order_object->getCreationDatetime();?></td>
            </tr>
         </table>
      </td>      
   </tr>
   <tr><td colspan='2'><hr align='center' width='90%'></hr></td></tr>
</table> 
</div>
<div class='content'>
<table style='border: 1px solid grey;' width='95%'>
   <?PHP
      $out="";
      #Build list of emails if present
      $customer_objects = $order_object->getCustomers();
      if ( count($customer_objects) > 0){
         $out="<tr><td class='label'>Customers Email:</td><td class='data'>";
         foreach ( $customer_objects as $customer_object ){
            if(get_class($customer_object)=="customer"){
               $out.="$customer_object->getEmail() ";
            }
         }
         $out.="<br></td></tr>";
      }
      
      #Build list of shipping Docs if present
      $files = $order_object->getShippingDocuments();
      if ( count($files) > 0 ){
         rsort($files);
         $out.="<tr><td colspan='2'><div align='left' class='data'>Shipping Documents:</div>";
         foreach($files as $file){
             $filefields = preg_split('/\//', $file);
             $filename = array_pop($filefields);
             $out.="<a href='$file'>$filename</a><br> ";
         }
         $out.="<br><br></td></tr>";
      }
      
      #build a list of pending orders if present
      $pending_order_objects = DB_OrderManager::getRelatedPendingOrders($database_object, $order_object);

      if ( count($pending_order_objects) > 0 ){
         $out.="<tr><td colspan='2'><span class='data' style='color:red;'>There are pending orders related to this order based on cylinders and/or customers.</span></br>";
         foreach ( $pending_order_objects as $pending_order_object ){
            $out.="<A href='order_status.php?num=".$pending_order_object->getNum()."'><INPUT type='button' value='Order #".$pending_order_object->getNum()."'></A>";
         }
         $out.="<br><br></td></tr>";
      }
      
      #build the list of cylinder products
      $product_objects = DB_ProductManager::searchByOrder($database_object, $order_object);
      if($product_objects){
         $out.="<tr><td colspan='2'><table class='datatable'>";
         foreach ( $product_objects as $prod_index=>$product_object ){
            #I played with setting a color for the cylinder status, but that was too busy
            /*$prodStatus= $product_object->getStatus('num');
            $statusColor=($prodStatus=='6' ||$prodStatus=='3')?"green":"yellow";
            $out.="<tr>
                     <td><div class='statusbox $statusColor' style='width:20px;'>&nbsp;</div></td>
                     <td><span class='label'>Cylinder: </span><span class='data'>";
            */
            $out.="<tr>
                     <td>-</td>
                     <td><span class='label'>Cylinder: </span><span class='data'>";
            
            
            if ( is_object($product_object->getCylinder()) )$out.=$product_object->getCylinder()->getID();
            $out.="</span></td>
                     <td><span class='label' style='width:200px;'>Fill Code:</span>
                        <span class='data'>".$product_object->getFillCode()."</span>
                     </td>
                     <td><span class='label'>Status: </span><span class='data'>".$product_object->getStatus()."</span></td>
                     <td width='30%'></td>
                  </tr>";
            $calrequest_objects = DB_CalRequestManager::searchByProduct($database_object, $product_object);
            
            /*We'll lay out the primary data in a row followed by a hidden row with some of the extra analysis data if available.
             *We'll build the table up a little backwards (tds befor th) so we can determine if there even is any actual 'extra'
             *data so we know whether to include the show/hide arrow widgets.*/
            
            $tableHasHiddenRows=false;
            $tableData="";
            $out.="<tr><td colspan='5'><table class='species'>";
            
            if ( count($calrequest_objects) > 0 ){
                        
               foreach ( $calrequest_objects as $req_index=>$calrequest_object ){
                  $uid=$prod_index."_".$req_index;//unique id to mark the hidden row data
                  $statusColor=$calrequest_object->getStatusColorHTML();
                  $rowHasHiddenData=(( get_class($calrequest_object->getAnalysisSubmitUser()) == 'DB_User' ) || $calrequest_object->getAnalysisSubmitDatetime() || $calrequest_object->getAnalysisCalibrationsSelected() || $calrequest_object->getComments());
                  $tableHasHiddenRows=($tableHasHiddenRows || $rowHasHiddenData);            
            
                  $tableData.="<tr>
                           <td style='border:none;' width='20px'>&nbsp;</td>
                           <td style='border:none;'><div class='statusbox' style='background-color:$statusColor;'>&nbsp;</div></td>
                           <td>".$calrequest_object->getCalService()->getAbbreviationHTML()."</td>
                           <td>".$calrequest_object->getStatus('abbr')."</td>
                           <td>".$calrequest_object->getAnalysisType()."</td>
                           <td>".$calrequest_object->getTargetValue()."</td>
                           <td>".htmlentities($calrequest_object->getAnalysisValue(), ENT_QUOTES, 'UTF-8')."</td>
                           <td>".htmlentities($calrequest_object->getAnalysisReferenceScale(), ENT_QUOTES, 'UTF-8')."</td>
                           <td>".htmlentities($calrequest_object->getAnalysisRepeatability(), ENT_QUOTES, 'UTF-8')."</td>";
                  if($rowHasHiddenData)$tableData.="<td style='border:none;' align='center'><div id='exp_link_$uid' style='cursor:pointer;' onclick='toggle_visibility(\"details_$uid\",\"exp_link_$uid\")'>&nbsp;&darr;&nbsp;</div></td>";
                  else $tableData.="<td style='border:none;'>&nbsp;</td>";
                  $tableData.="</tr>";
                                    
                  
                  #Add a hidden row with details if needed
                  if($rowHasHiddenData){
                     $user="";
                     if ( get_class($calrequest_object->getAnalysisSubmitUser()) == 'DB_User' ){
                        $user=htmlentities($calrequest_object->getAnalysisSubmitUser()->getUsername(), ENT_QUOTES, 'UTF-8');
                     }
                     $tableData.="<tr style='display:none;' id='details_$uid'>
                              <td style='border:none;'>&nbsp;</td>
                              <td style='border:none;'>&nbsp;</td>
                              <td colspan='8' style='border:none;'>
                                 <table style='border-collapse:collapse;'>
                                    <tr><td class='label'>Date analysis submitted: </td><td ><span class='data'>".htmlentities($calrequest_object->getAnalysisSubmitDatetime(), ENT_QUOTES, 'UTF-8')."</span></td></tr>
                                    <tr><td class='label' >Submitted by: </td><td ><span class='data'>$user</span></td></tr>
                                    <tr><td class='label' >Calibrations selected: </td><td ><span class='data'>".htmlentities($calrequest_object->getAnalysisCalibrationsSelected(), ENT_QUOTES, 'UTF-8')."</span></td></tr>
                                    <tr><td class='label' >Comments: </td><td ><span class='data'>".htmlentities($calrequest_object->getComments(), ENT_QUOTES, 'UTF-8')."</span></td></tr>                              
                                 </table>
                              </td>
                           </tr>";
                  }
               }
               
               #Now we can put it all together
               $out.="<tr>
                           <th style='border:none;'></th>
                           <th style='border:none;'></th>
                           <th>Species</th>
                           <th>Status</th>
                           <th>Analysis type</th>
                           <th>Target</th>
                           <th>Value</th>
                           <th>Scale</th>
                           <th>Repeatability</th>";
               if($tableHasHiddenRows)$out.="<th style='border:none;'><span style='font-size:x-small;color:blue;font-style: italic;'>Click arrow to <br>see details</span></th>";
               else $out.="<th  style='border:none;'>&nbsp;</th>";
               $out.="</tr>$tableData";
               
               
               if ( $product_object->getComments() != '' ){
                  $out.="  <tr>
                              <td style='border:none;'>&nbsp;</td>
                              <td style='border:none;'>&nbsp;</td>
                              <td colspan='8' style='border:none;'><span class='label'>Comments:</span><span class='data'>".htmlentities($product_object->getComments(), ENT_QUOTES, 'UTF-8')."</span>
                              </td>
                           </tr>";
               }        
               $out.="<tr><td colspan='10' style='border:none;'>&nbsp;</td></tr>";
            }else{
               $out.="<tr><td class='data'>No analyzes</td></tr>";
            }
            $out.="</table></td></tr>";
         }
         $out.="</table></td></tr>";
      }
      echo $out;
      
   ?>   
   <tr>   
      
   </tr>
   
</table>
</div> 
<div class='footer'>
<table>
   <tr>
      <td colspan='2'>
         <?php
            $out="";
            #If editable, add appropriate links
            if ( $order_object->getStatus('num') == '1' || $order_object->getStatus('num') == '2' || $order_object->getStatus('num') == '3' ){
               $out="<A href='order_edit.php?num=".$order_object->getNum()."'><INPUT type='button' value='Edit Order'></A>";
               
               # If a product is 'processing complete' then provide the ability for final
               #  approval so it may be shipped
               $product_status_arr = array_values(array_unique(DB_ProductManager::getStatusNumsByOrder($database_object, $order_object)));
               $calrequest_status_arr = array_values(array_unique(DB_CalRequestManager::getStatusNumsByOrder($database_object, $order_object)));
               if ( in_array('3', $calrequest_status_arr) || 
                    in_array('3', $product_status_arr) ){
                  $out.="<A href='order_finalapproval.php?num=".$order_object->getNum()."'><INPUT type='button' value='Final Approval'></A>";
               }
        
               # If a product is 'ready to ship' then provide the ability to upload shipping
               #  documents               
               if ( in_array('6', $product_status_arr) ){
                  $out.="<A href='order_ship-docs.php?num=".$order_object->getNum()."'><INPUT type='button' value='Shipping Documents'></A>";
               
               }
            }elseif ( $order_object->getStatus('num') == '4' ){
                 # If order is 'processing complete' we still need the final approval step
                 $out.="<A href='order_edit.php?num=".$order_object->getNum()."'><INPUT type='button' value='Edit Order'></A>";
                 $out.="<A href='order_finalapproval.php?num=".$order_object->getNum()."'><INPUT type='button' value='Final Approval'></A>";
                 $out.="<A href='order_ship-docs.php?num=".$order_object->getNum()."'><INPUT type='button' value='Shipping Documents'></A>";
                 
            }elseif ( $order_object->getStatus('num') == '6' ){
                  # If order is 'Ready to ship' then display the edit order,  shipping docs page and
                  #   order complete button
                  $out.="<A href='order_edit.php?num=".$order_object->getNum()."'><INPUT type='button' value='Edit Order'></A>";
                  $out.="<INPUT type='button' value='Complete Order' onClick='CompleteCB()'>";
                  $out.="<A href='order_ship-docs.php?num=".$order_object->getNum()."'><INPUT type='button' value='Shipping Documents'></A>";
                  $out.="<A href='order_certificates.php?num=".$order_object->getNum()."'><INPUT type='button' value='Make certificates'></A>";
     
            }elseif ( $order_object->getStatus('num') == '5' ){
                  # If order is 'order complete' then we need to provide functions for
                  #  adding shipping documents and creating certificates
                  $out.="<A href='order_ship-docs.php?num=".$order_object->getNum()."'><INPUT type='button' value='Shipping Documents'></A>";
                  $out.="<A href='order_certificates.php?num=".$order_object->getNum()."'><INPUT type='button' value='Make certificates'></A>";
                  
            }elseif ( $order_object->getStatus('num') == '8' ){
               $out.="<A href='order_edit.php?num=".$order_object->getNum()."'><INPUT type='button' value='Edit Order'></A>";
            }
            $out.="<A href='orders_overview.php'><INPUT type='button' value='Orders Overview'></A>
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
                       <!-- This is for the menu that pops up at the bottom of the android screen. -->
                       <BR>
                       <BR>
                       <BR>
                      </TD>
                     </TR>
                    </TABLE>
                   </FORM>";
            echo $out;
            
            
         ?>
      </td>
   </tr>
</table>
   
</div>
</div>
<?PHP NoCacheLinks(); ?>
</BODY>
</HTML>

<?php exit();?>
