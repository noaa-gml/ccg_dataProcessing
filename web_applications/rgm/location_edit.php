<?PHP

require_once "CCGDB.php";
require_once "DB_Location.php";
require_once "Log.php";
require_once "utils.php";
require_once "/var/www/html/inc/Validator_Utils.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$nsubmits = ( isset($_POST['nsubmits']) ) ? $_POST['nsubmits'] : '0';
$nsubmits--;

$input_data = isset( $_POST['input_data'] ) ? $_POST['input_data'] : '';

$errors = array();
if ( $input_data != '' )
{
   $input_data_aarr = mb_unserialize(urldecode($input_data));

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

if ( isset($_GET['num']) && Validator_Utils::ValidInt($_GET['num']) )
{
   $input_data_aarr['location_num'] = $_GET['num'];

   # Load the information only if the user has not
   # requested something else
   if ( !isset($input_data_aarr['task']) )
   { $input_data_aarr['task'] = 'load'; }
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
  <SCRIPT language='JavaScript' src='location_edit.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <INPUT type='hidden' name='input_data' id='input_data'>
   <?PHP echo "<INPUT type='hidden' name='nsubmits' id='nsubmits' value='$nsubmits'>"; ?>
   <TABLE>

<?PHP
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
if ( isset($input_data_aarr['task']) )
{
   if ( $input_data_aarr['task'] == 'load' )
   {
      try
      {
         $location_obj = new DB_Location($database_object, $input_data_aarr['location_num']);

         $input_data_aarr['location_name'] = $location_obj->getName();
         $input_data_aarr['location_abbr'] = $location_obj->getAbbreviation();
         $input_data_aarr['location_active_status'] = $location_obj->getActiveStatus();
         $input_data_aarr['location_address'] = $location_obj->getAddress();
         $input_data_aarr['location_comments'] = $location_obj->getComments();
      }
      catch (Exception $e)
      { array_push($errors, $e); }
   }
   elseif ( $input_data_aarr['task'] == 'save' )
   {
      try
      {
         if ( isset($input_data_aarr['location_num']) )
         {
            # UPDATE

            $location_obj = new DB_Location($database_object, $input_data_aarr['location_num']);

            $location_obj->setName($input_data_aarr['location_name']);
            $location_obj->setAbbreviation($input_data_aarr['location_abbr']);
            $location_obj->setActiveStatus($input_data_aarr['location_active_status']);
            $location_obj->setAddress($input_data_aarr['location_address']);

            if ( isset($input_data_aarr['location_comments']) )
            { $location_obj->setComments($input_data_aarr['location_comments']); }

            $location_obj->saveToDB($_SESSION['user']);

            # Use the object to print the ID so that it is the same case as
            #  the database entry 
            echo "<TR><TD>";
            echo "<DIV align='center' style='color:green'>".$location_obj->getAbbreviation()." updated successfully.</DIV>";
            echo "</TD></TR>";
         }
         else
         {
            # INSERT

            $location_obj = new DB_Location($database_object, $input_data_aarr['location_name'], $input_data_aarr['location_abbr'], $input_data_aarr['location_address']);
            $location_obj->setActiveStatus($input_data_aarr['location_active_status']);

            if ( isset($input_data_aarr['location_comments']) )
            { $location_obj->setComments($input_data_aarr['location_comments']); }

            $location_obj->saveToDB($_SESSION['user']);

            $input_data_aarr['location_num'] = $location_obj->getNum();

            # Use the object to print the ID so that it is the same case as
            #  the database entry 
            echo "<TR><TD>";
            echo "<DIV align='center' style='color:green'>".$location_obj->getAbbreviation()." added successfully.</DIV>";
            echo "</TD></TR>";
         }
         #echo "<PRE>\n";
         #print_r($location_obj);
         #echo "</PRE>\n";
      }
      catch (Exception $e)
      { array_push($errors, $e); }
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
if ( isset($input_data_aarr['location_num']) )
{
   echo "    <TR>";
   echo "     <TD>";
   echo "      <H1>Update Location</H1>";
   echo "     </TD>";
   echo "    </TR>";
}
else
{
   echo "    <TR>";
   echo "     <TD>";
   echo "      <H1>Add Location</H1>";
   echo "     </TD>";
   echo "    </TR>";
}
?>

    <TR>
     <TD align='center'>
      Name
     </TD>
    </TR>
    <TR>
     <TD align='center'>
<?PHP
$value = (isset($input_data_aarr['location_name'])) ? $input_data_aarr['location_name'] : '';
echo "      <INPUT type='text' name='location_name' id='location_name' size='50' value='$value'>";
?>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Abbreviation
     </TD>
    </TR>
    <TR>
     <TD align='center'>
<?PHP
$value = (isset($input_data_aarr['location_abbr'])) ? $input_data_aarr['location_abbr'] : '';
echo "      <INPUT type='text' name='location_abbr' id='location_abbr' size='40' value='$value'>";
?>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Status
     </TD>
    </TR>
    <TR>
     <TD align='center'>
<?PHP
   $active_status = (isset($input_data_aarr['location_active_status'])) ? $input_data_aarr['location_active_status'] : '1';
?>
      <SELECT id='location_active_status' name='location_active_status'>
       <OPTION value='1'>Active</OPTION>
       <OPTION value='0'>Inactive</OPTION>
      </SELECT>
<?PHP
   # Set the correct walue
   echo "<SCRIPT>$('#location_active_status').val('$active_status');</SCRIPT>";
?>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Address 
     </TD>
    </TR>
    <TR>
     <TD align='center'>
<?PHP
$value = (isset($input_data_aarr['location_address'])) ? $input_data_aarr['location_address'] : '';
echo "      <TEXTAREA name='location_address' id='location_address' cols='40'>$value</TEXTAREA>";
?>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      Comments 
     </TD>
    </TR>
    <TR>
     <TD align='center'>
<?PHP
$value = (isset($input_data_aarr['location_comments'])) ? $input_data_aarr['location_comments'] : '';
echo "      <TEXTAREA name='location_comments' id='location_comments' cols='40'>$value</TEXTAREA>";
?>
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
         <INPUT type='button' value='Submit' onClick='SubmitCB();'>
        </TD>
        <TD align='right' width='50%'>
         <?PHP echo "<INPUT type='button' value='Back' onClick='history.go($nsubmits);'>
"; ?>
<?PHP #         <INPUT type='button' value='Back' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> ?>
        </TD>
       </TR>
<?PHP

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'load' )
{
   echo "       <TR>";
   echo "        <TD colspan='2'>";
   echo "         <A href='location_edit.php'>";
   echo "          <INPUT type='button' value='Add New Location'>";
   echo "         </A>";
   echo "        </TD>";
   echo "       </TR>";
}
?>
      </TABLE>
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
