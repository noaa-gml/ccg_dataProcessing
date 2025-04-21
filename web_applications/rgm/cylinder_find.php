<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "Log.php";
require_once "utils.php";
require_once "menu_utils.php";
require_once "DB_OrderManager.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$input_id = isset ( $_GET['id'] ) ? $_GET['id'] : '';

$errors = array();

?>
<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='utils.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='cylinder_find.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
<title>RGM Find</title>
 </HEAD>
 <BODY>
  <A name='top' id='top'></A>
  <FORM name='mainform' method='GET'>
   <?PHP CreateMenu($database_object, $user_obj); ?>

<?PHP
#
##############################
#
# Handle the operations related
#  to the task
#
##############################
#
$cylinder_history = array();

if ( $input_id != '' )
{
   try
   {
      $cylinder_obj = new DB_Cylinder($database_object, $input_id, 'id');

      $sql = "SELECT t2.name, t2.abbr, t1.location_comments, t1.location_datetime, t1.location_action_user FROM cylinder_location as t1, location as t2 WHERE t1.cylinder_num = ? AND t1.location_num = t2.num ORDER BY t1.location_datetime DESC";
      $sqlargs = array($cylinder_obj->getNum());

      $cylinder_history = $database_object->queryData($sql,$sqlargs);
   }
   catch(Exception $e)
   { array_push($errors, $e); }
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

#
##############################
#
# Create the body of
#  the page
#
##############################
#
?>
   <TABLE>
    <TR>
     <TD>
      <H1>Find Cylinder</H1>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Cylinder ID
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <INPUT type='text' name='id' id='id' size='15' onKeyup='this.value = this.value.toUpperCase();'>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
         <INPUT type='button' value='Submit' onClick='SubmitCB();'>
        </TD>
        <TD align='right' width='50%'>
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> 
        </TD>
       </TR>
      </TABLE>

     </TD>
    </TR>
   </TABLE>

   <A name='details' id='details'></A>
<?PHP
if ( isset($cylinder_obj) )
{
?>
   <TABLE border='1' cellspacing='5' cellpadding='5'>
    <TR>
     <TD>
      <TABLE cellspacing='3' cellpadding='3'>
       <TR>
        <TH colspan='2'>Cylinder Details</TH>
       </TR>
       <TR>
        <TD>Cylinder Num</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getNum()."</TD>";?>
       </TR>
       <TR>
        <TD>Cylinder ID</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getID()."</TD>";?>
       </TR>
       <TR>
        <TD>DOT Date</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getRecertificationDate()."</TD>";?>
       </TR>
       <TR>
        <TD>Size</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getSize()."</TD>";?>
       </TR>
       <TR>
        <TD>Type</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getType()."</TD>";?>
       </TR>
       <TR>
        <TD>Status</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getStatus()."</TD>";?>
       </TR>
       <TR>
        <TD>Check in Status</TD>
        <?PHP echo "<TD style='color:blue'>".$cylinder_obj->getCheckInStatus()."</TD>";?>
       </TR>
       <TR>
        <TD>Comments</TD>
        <?PHP echo "<TD style='color:blue'>".htmlentities($cylinder_obj->getComments(), ENT_QUOTES, 'UTF-8')."</TD>";?>
       </TR>
       <TR>
        <TD>Label</TD>
        <?PHP echo "<TD><A href='labels/".$cylinder_obj->getID().".png'>".$cylinder_obj->getID()." label image</A></TD>";?>
       </TR>
       <TR>
        <TD>
         <?PHP echo "<A href='cylinder_edit.php?num=".$cylinder_obj->getNum()."&action=update'>"; ?>
          <INPUT type='button' value='Update Cylinder'>
         </A>
        </TD>
       </TR>
      </TABLE>
     </TD>
     <TD valign='top'>
      <TABLE border='1' cellspacing='2' cellpadding='2'>
       <TR>
        <TH colspan='5'>Related Orders</TH>
       </TR>
       <TR>
        <TH>Num</TH>
        <TH>Primary Customer</TH>
        <TH>Creation Date</TH>
        <TH>Status</TH>
        <TH>Actions</TH>

<?PHP

   $product_objects = DB_ProductManager::searchByCylinder($database_object, $cylinder_obj);

   $order_nums = array();
   $product_extra_objects = array();
   foreach ( $product_objects as $product_object )
   {
      if ( is_object($product_object->getOrder()) )
      {
         array_push($order_nums, $product_object->getOrder()->getNum());
      }
      else
      {
         array_push($product_extra_objects, $product_object);
      }
   }

   if ( count($product_extra_objects) > 0 )
   {
      echo "<DIV style='color:blue;'>This cylinder is a product extra. Goto <A href='product_extras.php'><INPUT type='button' value='Product Extras'></A></DIV>";
   }

   if ( count($order_nums) > 0 )
   {
      rsort($order_nums);

      foreach ( $order_nums as $order_num )
      {
         $order_object = new DB_Order($database_object, $order_num);

         echo "<TR>";
         echo " <TD>";
         echo $order_object->getNum();
         echo " </TD>";
         echo " <TD>";
         echo $order_object->getPrimaryCustomer()->getEmail();
         echo " </TD>";
         echo " <TD>";
         $fields = split(' ', $order_object->getCreationDatetime());
         echo $fields[0];
         echo " </TD>";
         echo " <TD>";
         echo $order_object->getStatus();
         echo " </TD>";
         echo " <TD>";
         echo "  <A href='order_status.php?num=".$order_object->getNum()."'>";
         echo "   <INPUT type='button' value='View Details'>";
         echo "  </A>";
         echo " </TD>";
         echo "</TR>";
      }
   }
     
?>
      </TABLE>
     </TD>
    </TR>
   </TABLE>
   <TABLE border='1' cellspacing='5' cellpadding='5'>
    <TR>
     <TH>Fill History</TH>
    </TR>
    <TR>
     <TD>
<?PHP

      $cmd = escapeshellcmd('/ccg/bin/reftank');

      # Build the shell command
      $args = array();
      array_push($args, escapeshellarg('-f'));
      array_push($args, escapeshellarg($cylinder_obj->getID()));

      $res = array();
      exec($cmd.' '.join(' ', $args), $res);

      #echo $cmd.' '.join(' ', $args)."<BR>";

      if ( count($res) > 0 ) 
      {
         echo "<PRE>";
         foreach ( $res as $line )
         { print $line."\n"; }
         echo "</PRE>";
      }
      else
      { echo "No fill history found."; }
?>
     </TD>
    </TR>
   </TABLE>
   <TABLE border='1' cellspacing='5' cellpadding='5'>
    <TR>
     <TH colspan='4'>Location History</TH>
    </TR>
    <TR>
     <TH>
     Current Location
     </TH>
     <TH>
     Comments
     </TH>
     <TH>
     Date & Time
     </TH>
     <TH>
     User
     </TH>
    </TR>
<?PHP
   #print_r($cylinder_history);
   echo "<TR>";
   echo " <TD style='color:blue;'>";
   print "<DIV title='".$cylinder_obj->getLocation()->getName()."'>".$cylinder_obj->getLocation()->getAbbreviation()."</DIV>";
   echo " </TD>";
   echo " <TD style='color:blue;'>";
   print $cylinder_obj->getLocationComments();
   echo " </TD>";
   echo " <TD style='color:blue;'>";
   print $cylinder_obj->getLocationDatetime();
   echo " </TD>";
   echo " <TD style='color:blue;'>";
   print $cylinder_obj->getLocationActionUser()->getUsername();
   echo " </TD>";
   echo "</TR>";

   if ( count($cylinder_history) > 0 )
   {
?>
   <TR>
    <TH>
    Past Locations
    </TH>
    <TH>
    Comments
    </TH>
    <TH>
    Date & Time
    </TH>
    <TH>
    User
    </TH>
   </TR>
<?PHP
      foreach ( $cylinder_history as $aarr )
      {
         echo "<TR>";
         echo " <TD>";
         print "<DIV title='".$aarr['0']."'>".$aarr['1']."</DIV>";
         echo " </TD>";
         echo " <TD>";
         print $aarr['2'];
         echo " </TD>";
         echo " <TD>";
         print $aarr['3'];
         echo " </TD>";
         echo " <TD>";
         print $aarr['4'];
         echo " </TD>";
         echo "</TR>";
      }
   }
}
?>
   </TABLE>
  </FORM>

<?PHP

if ( $input_id != '' )
{
?>
   <SCRIPT>
   $(function() {
       $(document).scrollTop( $("#details").offset().top );  
   });
   </SCRIPT>
<?PHP
}
else
{
?>
   <SCRIPT>
   $(function() {
       $(document).scrollTop( $("#top").offset().top );  
   });
   </SCRIPT>
<?PHP
}

NoCacheLinks();
?>
 </BODY>
</HTML>
