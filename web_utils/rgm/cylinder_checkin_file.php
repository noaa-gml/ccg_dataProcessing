<?PHP

require_once "CCGDB.php";
require_once "DB_Location.php";
require_once "DB_LocationManager.php";
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
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
 </HEAD>
 <BODY>
  <FORM action="upload_barcode_checkin_file.php" method="POST" enctype="multipart/form-data">
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <TABLE border='1' cellspacing='5' cellpadding='5'>
    <TR>
     <TD colspan='2'>
      <H1>Check-In Cylinder from File</H1>
     </TD>
    </TR>
    <TR>
     <TD>
      Location
     </TD>
     <TD>
      <SELECT name="location_num" id="location_num">
<?PHP

   $location_objs = DB_LocationManager::getCheckInDBLocations($database_object);

   foreach ( $location_objs as $location_obj )
   {
      $value = $location_obj->getNum();
      $name = $location_obj->getAbbreviation();

      # Select Niwot Ridge by default
      if ( $value === '1' ) { $selected = 'SELECTED'; }
      else { $selected = ''; }

      echo "<OPTION value='$value' $selected>$name</OPTION>";
   }

?>
      </SELECT>
     </TD>
    </TR>
    <TR>
     <TD align='right'>
      Text File
     </TD>
     <TD>
      <input type="file" name="file" id="file">
      <A href='example_checkin_file.txt'>Example file</A>
     </TD>
    </TR>
    <TR>
     <TD colspan='2'>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
         <INPUT type='submit' value='Submit'>
        </TD>
        <TD align='right' width='50%'>
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> 
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


