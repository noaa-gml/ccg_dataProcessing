<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "DB_LocationManager.php";
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

?>

<?php header('Content-type: text/html; charset=utf-8'); ?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/validator.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_urlencode.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='location_update.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <INPUT type='hidden' name='location_num' id='location_num' value='<?PHP if ( isset($input_data_aarr['location_num']) ) { echo $input_data_aarr['location_num']; } ?>'>
   <INPUT type='hidden' name='input_data' id='input_data'>
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
   if ( $input_data_aarr['task'] === 'search' )
   {
      #
      # CCGDB_Utils::searchDBLocations($string)
      #
      try
      {
         if ( preg_match('/%/', $input_data_aarr['search_string']) )
         { $match_location_objs = DB_LocationManager::search($database_object, $input_data_aarr['search_string']); }
         else
         { $match_location_objs = DB_LocationManager::search($database_object, '%'.$input_data_aarr['search_string'].'%'); }
         
      }
      catch(Exception $e)
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
?>
    <TR>
     <TD>
      <H1>Update Location</H1>
     </TD>
    </TR>
<?PHP
   # Initial page load & after search
echo "    <TR>";
echo "     <TD align='center'>Search string</TD>";
echo "    </TR>";
echo "    <TR>";
echo "     <TD align='center'>";

if ( isset($input_data_aarr['search_string']) )
{ $value = $input_data_aarr['search_string']; }
else
{ $value = ''; }

echo "<INPUT type='text' name='search_string' id='search_string' size='15' value='$value'>";
echo "<SCRIPT>$('#search_string').focus();</SCRIPT>";

echo "     </TD>";
echo "    </TR>";

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'search' )
{
   # After searching for search string
   #   Display the matching locations
   echo "    <TR>";
   echo "     <TD align='center'>";

   if ( count($match_location_objs) > 0 ) 
   {
      echo "      <TABLE border='1' cellspacing='10' cellspacing='5'>";
      echo "       <TR>";
      echo "        <TH>Abbreviation</TH>";
      echo "        <TH>Name</TH>";
      echo "       </TR>";

      foreach ($match_location_objs as $location_obj)
      {
         echo '<TR>';
         echo ' <TD>';

         # Pass the number to location_edit.php
         echo "  <A href='location_edit.php?num=".$location_obj->getNum()."'>".$location_obj->getAbbreviation()."</A></TD>";
         echo ' <TD>'.$location_obj->getName().'</TD>';
         echo '</TR>';
      } 
      echo "      </TABLE>";
   }
   else
   {
      echo "<FONT style='font-weight:bold'>No matching locations found.</FONT>";
      echo "<A href='location_edit.php'><INPUT type='button' value='Add Location'></A>?";
   }
   echo "     </TD>";
   echo "    </TR>";
}

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

<?PHP

exit;

?>
