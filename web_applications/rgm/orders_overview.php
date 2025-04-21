<?PHP

require_once "CCGDB.php";
require_once "DB_OrderManager.php";
require_once "utils.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$type = ( isset($_GET['type']) ) ? $_GET['type'] : '';

$order_objects = array();
if ( $type === 'pending' )
{
   $order_objects = DB_OrderManager::getPendingOrders($database_object);
}
else
{
   $order_objects = DB_OrderManager::getActiveOrders($database_object);
}

?>

<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/tablesorter-blue/style.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-tablesorter-pager.js"></SCRIPT>
 </HEAD>
 <BODY>
  <SCRIPT>
$(document).ready(function() 
    { 
        $("#myTable").tablesorter(); 
    } 
); 
  </SCRIPT>
  <FORM name='mainform' id='mainform' method='post'>
<?PHP
CreateMenu($database_object, $user_obj);

if ( $type === 'pending' )
{
   echo "<H1>Pending Orders overview</H1>";
   echo "<A href='orders_overview.php'>";
   echo " <INPUT type='button' value='Orders overview'>";
   echo "</A>";
}
else
{
   echo "<H1>Orders overview</H1>";
   echo "<A href='orders_overview.php?type=pending'>";
   echo " <INPUT type='button' value='Pending Orders overview'>";
   echo "</A>";
}
?>
   <A href='order_creation.php'><INPUT type='button' value='Create New Order'></A>
   <TABLE border='1' cellspacing='5' cellpadding='5' id="myTable" class="tablesorter">
    <THEAD>
    <TR>
     <TH>Order Num</TH>
     <TH>Customers</TH>
     <TH>Organization</TH>
     <TH>Product<BR>Count</TH>
     <TH>Due Date</TH>
     <TH>Priority</TH>
     <TH>Status</TH>
     <TH>Actions</TH>
    </TR>
    </THEAD>
    <TBODY>

<?PHP

   foreach ( $order_objects as $order_object )
   {

      echo "<TR>";
      echo " <TD>";
      echo $order_object->getNum();
      echo " </TD>";

      echo " <TD>";
      echo $order_object->getPrimaryCustomer()->getEmail();
      echo " </TD>";

      echo " <TD>";
      echo $order_object->getOrganization();
      echo " </TD>";

      echo " <TD>";
      echo $order_object->countProducts();
      echo " </TD>";

      echo " <TD>";
      echo $order_object->getDueDate();
      echo " </TD>";

      $color = $order_object->getPriorityColorHTML();
      echo " <TD style='background-color:$color'>";
      echo " </TD>";

      echo " <TD>";
      echo $order_object->getStatus('abbr');
      echo " </TD>";

      echo " <TD>";

      $order_num = $order_object->getNum();
      echo "<A href='order_status.php?num=$order_num'><INPUT type='button' value='View Details'></A>";

      $product_status_arr = array_values(array_unique(DB_ProductManager::getStatusNumsByOrder($database_object, $order_object)));

      if ( in_array('3', $product_status_arr) )
      {
         # If a product is 'processing complete' then provide the ability for final
         #  approval so it may be shipped
         echo "<A href='order_finalapproval.php?num=".$order_object->getNum()."'><INPUT type='button' value='Final Approval'></A>";
      }

      echo " </TD>";

      echo "</TR>";
   }
?>
    </TBODY>
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



