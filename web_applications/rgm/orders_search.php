<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "DB_LocationManager.php";
require_once "DB_CalServiceManager.php";
require_once "DB_OrderManager.php";
require_once "Log.php";
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
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/validator.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_urlencode.js'></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-tablesorter-pager.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='orders_search.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
  <SCRIPT>
$(document).ready(function() 
    { 
        $("#resultstable").tablesorter(); 
    } 
); 
  </SCRIPT>
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <INPUT type='hidden' name='input_data' id='input_data'>
   <TABLE>

<?PHP

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

#print "<PRE>\n";
#print_r($input_data_aarr)."\n";
#print "</PRE>\n";

#
##############################
#
# Handle the operations related
#  to the task
#
##############################
#
$matching_order_objs = array();
$matching_product_extra_objs = array();
if ( isset($input_data_aarr['task']) )
{
   if ( $input_data_aarr['task'] === 'search' )
   {
      $matching_aarr = array();

      if ( isset($input_data_aarr['num_string']) &&
           $input_data_aarr['num_string'] != '' )
      {
         try
         {
            $matching_aarr['num'] = DB_OrderManager::searchByNum($database_object, $input_data_aarr['num_string']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( isset($input_data_aarr['customer_string']) &&
           $input_data_aarr['customer_string'] != '' )
      {
         try
         {
            $matching_aarr['customer'] = DB_OrderManager::searchByCustomer($database_object, $input_data_aarr['customer_string']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( isset($input_data_aarr['organization_string']) &&
           $input_data_aarr['organization_string'] != '' )
      {
         try
         {
            $matching_aarr['organization'] = DB_OrderManager::searchByOrganization($database_object, $input_data_aarr['organization_string']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( isset($input_data_aarr['cylinder_string']) &&
           $input_data_aarr['cylinder_string'] != '' )
      {
         try
         {
            $matching_aarr['cylinder'] = DB_OrderManager::searchByCylinder($database_object, $input_data_aarr['cylinder_string']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }

         # Look to see if the cylinder is in product extras
         try
         {
            $cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_string'], 'id');

            $product_objects = DB_ProductManager::searchByCylinder($database_object, $cylinder_obj);

            foreach ( $product_objects as $product_object )
            {
               if ( ! is_object($product_object->getOrder()) )
               {
                  # This is a product extra
                  array_push($matching_product_extra_objs, $product_object);
               }
            }
         }
         catch ( Exception $e )
         { 
            # Do nothing as the search has failed.
         }
      }

      if ( isset($input_data_aarr['calservice_num']) &&
           $input_data_aarr['calservice_num'] != '' )
      {
         try
         {
            $matching_aarr['calservice'] = DB_OrderManager::searchByCalService($database_object, $input_data_aarr['calservice_num']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( ( isset($input_data_aarr['due-date_string1']) &&
           $input_data_aarr['due-date_string1'] != '1900-01-01' )
           || 
           ( isset($input_data_aarr['due-date_string2'] ) &&
           $input_data_aarr['due-date_string2'] != '9999-12-31' ) ) 
      {
         try
         {
            $matching_aarr['due-date'] = DB_OrderManager::searchByDueDate($database_object, $input_data_aarr['due-date_string1'], $input_data_aarr['due-date_string2']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( isset($input_data_aarr['creation-date_string1']) &&
           $input_data_aarr['creation-date_string1'] != '1900-01-01' && 
           isset($input_data_aarr['creation-date_string2'] ) &&
           $input_data_aarr['creation-date_string2'] != '9999-12-31' ) 
      {
         try
         {
            $matching_aarr['creation-date'] = DB_OrderManager::searchByCreationDate($database_object, $input_data_aarr['creation-date_string1'], $input_data_aarr['creation-date_string2']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      if ( isset($input_data_aarr['comments_string']) &&
           $input_data_aarr['comments_string'] != '' )
      {
         try
         {
            $matching_aarr['customer'] = DB_OrderManager::searchByComments($database_object, $input_data_aarr['comments_string']);
         }
         catch ( Exception $e )
         { array_push($errors, $e); }
      }

      #echo "<PRE>";
      #print_r($matching_aarr);
      #echo "</PRE>";

      if ( count($errors) == 0 )
      {
         if ( count($matching_aarr) == 0 )
         {
         }
         elseif ( count($matching_aarr) == 1 )
         {
            $keys = array_keys($matching_aarr);
            $matching_order_objs = $matching_aarr[$keys[0]];
         }
         else
         {

            $emptyarr = 0;
            $all_arr = array();
            foreach ( $matching_aarr as $key=>$object_arr )
            {
               if ( count($object_arr) == 0 )
               {
                  $emptyarr = 1;
                  break;
               }

               $tmparr = array();
               foreach ( $object_arr as $order_object )
               {
                  array_push($tmparr, $order_object->getNum());
               }
               array_push($all_arr, $tmparr);
            }

            if ( ! $emptyarr )
            {
               $matching_order_nums = call_user_func_array('array_intersect', $all_arr);
               sort($matching_order_nums, SORT_NUMERIC);

               $matching_order_objs = array();
               foreach ( $matching_order_nums as $order_num )
               {
                  array_push($matching_order_objs, new DB_Order($database_object, $order_num));
               }
            }
         }
      }

   }
   else
   {
      unset($input_data_aarr['task']);
   }
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

#
##############################
#
# Create the body of
#  the page
#
##############################
#
?>
    <TR>
     <TD>
      <H1>Order Search</H1>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD>Num</TD>
        <TD>

<?PHP

if ( isset($input_data_aarr['num_string']) )
{ $value = $input_data_aarr['num_string']; }
else
{ $value = ''; }

echo "<INPUT type='text' name='num_string' id='num_string' size='10' value='$value'>";

?>

        </TD>
       </TR>
       <TR>
        <TD>Customer</TD>
        <TD>

<?PHP

if ( isset($input_data_aarr['customer_string']) )
{ $value = $input_data_aarr['customer_string']; }
else
{ $value = ''; }

echo "<INPUT type='text' name='customer_string' id='customer_string' size='30' value='$value'>";

?>

        </TD>
       </TR>
       <TR>
        <TD>Organization</TD>
        <TD>

<?PHP

if ( isset($input_data_aarr['organization_string']) )
{ $value = $input_data_aarr['organization_string']; }
else
{ $value = ''; }

echo "<INPUT type='text' name='organization_string' id='organization_string' size='20' value='$value'>";

?>

        </TD>
       </TR>
       <TR>
        <TD>Cylinder ID</TD>
        <TD>

<?PHP

if ( isset($input_data_aarr['cylinder_string']) )
{ $value = $input_data_aarr['cylinder_string']; }
else
{ $value = ''; }

echo "<INPUT type='text' name='cylinder_string' id='cylinder_string' size='10' value='$value'>";

?>

        </TD>
       </TR>
       <TR>
        <TD>Calservice</TD>
        <TD>

<?PHP

$calservice_objs = DB_CalServiceManager::getAnalysisCalServices($database_object);

if ( isset($input_data_aarr['calservice_num']) )
{ $value = $input_data_aarr['calservice_num']; }
else
{ $value = ''; }

echo "         <SELECT id='calservice_num' name='calservice_num'>";
echo "          <OPTION value=''>---</OPTION>";
foreach ( $calservice_objs as $calservice_object )
{
   $selected = ( $value == $calservice_object->getNum() ) ? 'SELECTED' : '';
   echo "<OPTION value='".$calservice_object->getNum()."' $selected>".$calservice_object->getAbbreviation()."</OPTION>";
}
echo "         </SELECT>";

?>

        </TD>
       </TR>
       <TR>
        <TD>Due Date</TD>
        <TD>
         <TABLE cellspacing='0' cellpadding='0'>
          <TR>
           <TD>

<?PHP

if ( isset($input_data_aarr['due-date_string1']) )
{ $value = $input_data_aarr['due-date_string1']; }
else
{ $value = ''; }

echo "            <INPUT type='text' name='due_date_string1' id='due-date_string1' size='10' value='$value'>";
echo "           </TD>";
echo "           <TD>";

if ( isset($input_data_aarr['due-date_string2']) )
{ $value = $input_data_aarr['due-date_string2']; }
else
{ $value = ''; }

echo "            <INPUT type='text' name='due-date_string2' id='due-date_string2' size='10' value='$value'>";

?>

           </TD>
          </TR>
         </TABLE>
        </TD>
       </TR>
       <TR>
        <TD>Creation Date</TD>
        <TD>
         <TABLE cellspacing='0' cellpadding='0'>
          <TR>
           <TD>

<?PHP

if ( isset($input_data_aarr['creation-date_string1']) )
{ $value = $input_data_aarr['creation-date_string1']; }
else
{ $value = ''; }

echo "            <INPUT type='text' name='creation-date_string1' id='creation-date_string1' size='10' value='$value'>";
echo "           </TD>";
echo "           <TD>";

if ( isset($input_data_aarr['creation-date_string2']) )
{ $value = $input_data_aarr['creation-date_string2']; }
else
{ $value = ''; }

echo "            <INPUT type='text' name='creation-date_string2' id='creation-date_string2' size='10' value='$value'>";

?>
           </TD>
          </TR>
         </TABLE>
        </TD>
       </TR>
       <TR>
        <TD>Comments</TD>
        <TD>

<?PHP

if ( isset($input_data_aarr['comments_string']) )
{ $value = $input_data_aarr['comments_string']; }
else
{ $value = ''; }

echo "<INPUT type='text' name='comments_string' id='comments_string' size='30' value='$value'>";

?>

        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>

    <TR>
     <TD>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
         <INPUT type='button' value='Search' onClick='SearchCB();'>
        </TD>
        <TD align='right' width='50%'>
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> 
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>

<?PHP
if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'search' )
{
   # After searching for search string
   #   Display the matching locations
   echo "    <TR>";
   echo "     <TD>";

   if ( count($matching_product_extra_objs) > 0 )
   {
      echo "<DIV style='color:blue;'>This cylinder is a product extra. <BR>Goto <A href='product_extras.php'><INPUT type='button' value='Product Extras'></A></DIV>";
   }
   
   if ( count($matching_order_objs) > 0 ) 
   {

?>
      <TABLE border='1' cellspacing='0' cellspacing='0'>
       <TR>
        <TD>
         <H3>Results</H3>
        </TD>
       </TR>
       <TR>
        <TD>
         <TABLE border='1' cellspacing='5' cellspacing='5' id='resultstable' class='tablesorter'>
          <THEAD>
          <TR>
           <TH>Num</TH>
           <TH>Primary Customer</TH>
           <TH>Due Date</TH>
           <TH>Status</TH>
           <TH>Actions</TH>
          </TR>
          </THEAD>
          <TBODY>

<?PHP
      foreach ($matching_order_objs as $order_obj)
      {
         echo " <TR>";
         echo "  <TD>".$order_obj->getNum()."</TD>"; 
         echo "  <TD>".$order_obj->getPrimaryCustomer()->getEmail()."</TD>";
         echo "  <TD>".$order_obj->getDueDate()."</TD>";
         echo "  <TD>".$order_obj->getStatus('abbr')."</TD>";
         echo "  <TD>";
         # Pass the number to order_edit.php
         echo "   <A href='order_status.php?num=".$order_obj->getNum()."'>";
         echo "    <INPUT type='button' value='View Details'>";
         echo "   </A>";
         echo "  </TD>";
         echo " </TR>";
      } 
      echo "    </TBODY>";
      echo "   </TABLE>";
      echo "  </TD>";
      echo " </TR>";
      echo "</TABLE>";
   }
   else
   {
      echo '<H4>No matching orders found.</H4>';
   }
   echo "     </TD>";
   echo "    </TR>";
}

?>
   </TABLE>
  </FORM>
<?PHP NoCacheLinks(); ?>
 </BODY>
</HTML>

