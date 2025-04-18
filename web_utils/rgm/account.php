<?PHP

require_once "CCGDB.php";
require_once "utils.php";
require_once "Log.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$input_data = isset( $_POST['input_data'] ) ? $_POST['input_data'] : '';

$errors = array();
if ( $input_data != '' )
{
   # Must use @mb_unserialize so that it will not crash the program if
   #  unable to mb_unserialize string
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

?>
<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/php_serialize.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='account.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
<?PHP
   CreateMenu($database_object, $user_obj);
?>
   <INPUT type='hidden' id='input_data' name='input_data'>
   <TABLE>

<?PHP

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'change_password' )
{
   #echo "<PRE>\n";
   #print_r($input_data_aarr);
   #echo "</PRE>\n";

   try
   {
      # Call the update password function
      $user_obj->updatePassword($input_data_aarr['curpwd'], $input_data_aarr['newpwd1'], $input_data_aarr['newpwd2']);

      print "<DIV style='color:green'>Password updated successfully.</DIV><BR>";

      Log::update($user_obj->getUsername(), "Password updated.");
   }
   catch (Exception $e)
   {
      array_push($errors, $e);
   }
}

#
# Handle errors
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
      # Only use __toString() when debugging!
      #Log::update($user_obj->getUsername(),$e->__toString());

      Log::update($user_obj->getUsername(),"exception '".get_class($e)."' with message '".$e->getMessage()."' in ".$e->getFile().":".$e->getLine());

      echo "    <LI><DIV style='color:red'>".$e->getMessage()."</DIV></LI>";
   }
   echo "   </UL>";
   echo "  </TD>";
   echo " </TR>";
   echo "</TABLE>";
   echo "</TD></TR>";
}

?>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD align='left'>
         <H1>Change password</H1>
        </TD>
       </TR>
       <TR>
        <TD>
         <FONT style='font-weight:bold;'>Please note that this will only update your password for Refgas Manager. This will NOT update your Windows/Linux/LDAP password.</FONT>
        </TD>
       </TR>
       <TR>
        <TD>
         <TABLE>
          <TR>
           <TD align='center'>
            Current password
           </TD>
          </TR>
          <TR>
           <TD>
            <INPUT type='password' id='curpwd' name='curpwd' size='15'>
           </TD>
          </TR>
          <TR>
           <TD align='center'>
            New Password
           </TD>
          </TR>
          <TR>
           <TD>
            <INPUT type='password' id='newpwd1' name='newpwd1' size='15'>
           </TD>
          </TR>
          <TR>
           <TD align='center'>
            Verify Password
           </TD>
          </TR>
          <TR>
           <TD>
            <INPUT type='password' id='newpwd2' name='newpwd2' size='15'>
           </TD>
          </TR>
         </TABLE>
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
         <INPUT type='button' value='Update' onClick='ChangePasswordCB();'>
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
