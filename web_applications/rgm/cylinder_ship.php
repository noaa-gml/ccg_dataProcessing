<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "DB_Location.php";
require_once "DB_LocationManager.php";
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
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='utils.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='cylinder_ship.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <INPUT type='hidden' name='input_data'>
   <TABLE cellpadding='10' cellspacing='10'>

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

   if ( isset($input_data_aarr['task']) &&
        $input_data_aarr['task'] === 'submit' )
   {

      #echo "<PRE>";
      #print_r($input_data_aarr);
      #echo "</PRE>";

      #
      # Check the user input
      # 

      try
      {
         if ( isset($input_data_aarr['location_num']) )
         {
            $location_obj = new DB_Location($database_object, $input_data_aarr['location_num']);
         }
         else
         { throw new Exception("Location must be provided."); }

         $location_comments = '';
         if ( isset($input_data_aarr['location_comments']) && $input_data_aarr['location_comments'] != '' )
         {
            $location_comments = $input_data_aarr['location_comments'];
         }

         #print "CYLINDER: ".$cylinder."<BR>";
         #print "LOCATION: ".$location."<BR>";
         #print "COMMENTS: ".$location_comments."<BR>";

         $cylinder_arr = array();
         # Cylinder IDs should be case insensitive so make them all uppercase
         foreach ( $input_data_aarr as $name=>$value)
         {
            if ( preg_match('/^cylinder[0-9]+$/', $name) && $value != '' )
            { array_push($cylinder_arr, strtoupper($value)); }
         }
         $cylinder_arr = array_values(array_unique($cylinder_arr));

         foreach ( $cylinder_arr as $cylinder)
         {
            try
            {
               $cylinder_obj = new DB_Cylinder($database_object, $cylinder, 'id');

               $cylinder_obj->ship($location_obj, $location_comments);

               $cylinder_obj->saveToDB($_SESSION['user']);
               #print_r($cylinder_obj);

               # Use the object to print the ID so that it is the same case as
               #  the database entry 
               echo "<TR><TD>";
               echo "<DIV align='center' style='color:green'>".$cylinder_obj->getID()." location updated successfully</DIV>";
               echo "</TD></TR>";
            }
            catch(Exception $e)
            { array_push($errors, $e); }
         }
      }
      catch(Exception $e)
      { array_push($errors, $e); }

      # Clear the data if everything was successful
      if ( count($errors) == 0 )
      { unset($input_data_aarr); }
   }

# Handle errors
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

    <TR>
     <TD>
      <H1>Ship Cylinder</H1>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD colspan='2' align='center'>
         <DIV style='font-weight:bold'>Cylinder IDs</DIV>
        </TD>
       </TR>
       <TR>
        <TD>1</TD>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['cylinder1']) ) ? $input_data_aarr['cylinder1'] : '';
   echo "<INPUT type='text' id='cylinder1' name='cylinder1' size='15' value='$value'>";
?>
        </TD>
       </TR>
       <TR>
        <TD>2</TD>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['cylinder2']) ) ? $input_data_aarr['cylinder2'] : '';
   echo "<INPUT type='text' id='cylinder2' name='cylinder2' size='15' value='$value'>";
?>
        </TD>
       </TR>
       <TR>
        <TD>3</TD>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['cylinder3']) ) ? $input_data_aarr['cylinder3'] : '';
   echo "<INPUT type='text' id='cylinder3' name='cylinder3' size='15' value='$value'>";
?>
        </TD>
       </TR>
       <TR>
        <TD>4</TD>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['cylinder4']) ) ? $input_data_aarr['cylinder4'] : '';
   echo "<INPUT type='text' id='cylinder4' name='cylinder4' size='15' value='$value'>";
?>
        </TD>
       </TR>
       <TR>
        <TD>5</TD>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['cylinder5']) ) ? $input_data_aarr['cylinder5'] : '';
   echo "<INPUT type='text' id='cylinder5' name='cylinder5' size='15' value='$value'>";
?>
        </TD>
       </TR>
       <TR>
        <TD>6</TD>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['cylinder6']) ) ? $input_data_aarr['cylinder6'] : '';
   echo "<INPUT type='text' id='cylinder6' name='cylinder6' size='15' value='$value'>";
?>
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD align='center'>
         <DIV style='font-weight:bold'>Location</DIV>
        </TD>
       </TR>
       <TR>
        <TD>
         <SELECT size='5' id='location_num' name='location_num'>
<?PHP
   $location_objs = DB_LocationManager::getShipDBLocations($database_object);

   $selected_location_num = ( isset($input_data_aarr['location_num']) ) ? $input_data_aarr['location_num'] : '';

   foreach ( $location_objs as $location_obj )
   {
      $value = $location_obj->getNum();
      $name = $location_obj->getAbbreviation();

      $selected = ( $value == $selected_location_num ) ? 'SELECTED' : '';

      echo "<OPTION value='$value' $selected>$name</OPTION>";
   }

?>
         </SELECT>

<?PHP

   $tmparr = array();
   foreach ( $location_objs as $location_obj )
   {
      $value = $location_obj->getNum();
      $name = $location_obj->getAbbreviation();

      array_push($tmparr, sprintf('{label:"%s", value:"%d"}', $name, $value)); 
   }

?>

<SCRIPT>
$(function() {
   var availablelocations = [
<?PHP
echo join(',', $tmparr);
?>
   ];
   $( "#location_search" ).autocomplete({
      source: availablelocations
   });
   $( "#location_search" ).autocomplete({
      select: function( event, ui ) {
           $("#location_num").val(ui.item.value).change();
           $("#location_search").val('');
           return false;
      }
   });
   $( "#location_search" ).autocomplete({
      change: function( event, ui ) {
           $("#location_search").val('');
           return false;
      }
   });
})
</SCRIPT>
<div class="ui-widget">
<img src='images/search-icon-active.png'>
<input type='text' size='10' id="location_search" />
</div>
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE>
       <TR>
        <TD align='center'>
         <DIV style='font-weight:bold'>Comments</DIV>
        </TD>
       </TR>
       <TR>
        <TD>
<?PHP
   $value = ( isset($input_data_aarr['location_comments']) ) ? $input_data_aarr['location_comments'] : '';
   echo "<INPUT type='text' id='location_comments' name='location_comments' size='15' value='$value'>";
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
         <INPUT type='button' value='Submit' onClick='SubmitCB();'>
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
