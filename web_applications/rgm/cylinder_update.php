<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "Log.php";
require_once "utils.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

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

#
##############################
#
# Handle the operations related
#  to the task
#
##############################
#

if ( isset($input_data_aarr['task']) )
{
   if ( $input_data_aarr['task'] === 'search' )
   {
      try
      {
         $cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_id'], 'id');
         header( 'Location: cylinder_edit.php?num='.$cylinder_obj->getNum().'&action=update' ) ;
      }
      catch(Exception $e)
      { array_push($errors, $e); }
   }
   else
   {
      unset($input_data_aarr['task']);
   }
}
?>
<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/validator.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_urlencode.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='utils.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='cylinder_update.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
   <INPUT type='hidden' name='input_data' id='input_data'>
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <TABLE cellpadding='2' cellspacing='2'>

<?PHP
#print "<PRE>\n";
#print_r($input_data_aarr)."\n";
#print "</PRE>\n";

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
      <H1>Update Cylinder</H1>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Cylinder ID
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <INPUT type='text' name='cylinder_id' id='cylinder_id' size='15' onKeyup='this.value = this.value.toUpperCase();' value=''>
      <SCRIPT>$('#cylinder_id').focus();</SCRIPT>
     </TD>
    </TR>
<?PHP

#   
##############################
#
# Create the bottom menu
#
##############################
#
?>
    <TR>
     <TD>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
         <INPUT type='button' value='Search' onClick='SearchCB();'>
        </TD>
        <TD align='right' width='50%'>
<?PHP #         <INPUT type='button' value='Back' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> ?>
         <A href='index.php'><INPUT type='button' value='Back'></A>
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
   </TABLE>
  </FORM>
<?PHP NoCacheLinks(); ?>
 </BODY>
</HTML>

