<?PHP
/*Updated to add DOT Date, size & cylinder type.
 *jwm - 10/15
 */
require_once "CCGDB.php";
require_once "DB_Location.php";
require_once "DB_LocationManager.php";
require_once "DB_CylinderManager.php";
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
  <FORM action="upload_barcode_add_file.php" method="POST" enctype="multipart/form-data">
   <?PHP CreateMenu($database_object, $user_obj); ?>
   <TABLE border='1' cellspacing='5' cellpadding='5'>
    <TR>
     <TD colspan='2'>
      <H1>Add Cylinder from File</H1>
     </TD>
    </TR>
    <TR>
     <TD align='right'>
      Text File
     </TD>
     <TD>
      <input type="file" name="file" id="file">
      <A href='example_add_file.txt'>Example file</A>
     </TD>
    </TR>
    <TR>
     <TD align='right'>
      DOT Date
     </TD>
     <TD>
      <?PHP
      $default_value = '99-99';
      echo "<INPUT type='text' name='recertification_date' id='recertification_date' size='5' maxlength='5' value='$default_value' onClick='if (this.value == \"99-99\") { this.value = \"\"};' onBlur='if (this.value == \"\" ) { this.value = \"99-99\"};'>";
      ?>
     </TD>
    </TR>
    <TR>
     <TD align='right'>
      Size
     </TD>
     <TD>
      <SELECT name='size_num' id='size_num'>
<?PHP

$aarr = DB_CylinderManager::getCylinderSizes($database_object);

$default_value = '8';
foreach ( $aarr as $value=>$name )
{
   $selected = ( $value == $default_value ) ? 'SELECTED' : '';
   echo "<OPTION value='$value' $selected>$name</OPTION>";
}

?>
      </SELECT>
     </TD>
    </TR>
    <TR>
     <TD align='right'>
      Type
     </TD>
     <TD>
      <SELECT name='type_num' id='type_num'>
        <option value='none' selected></option>
<?PHP
$aarr = DB_CylinderManager::getCylinderTypes($database_object);


foreach ( $aarr as $value=>$name )
{
   echo "<OPTION value='$value'>$name</OPTION>";
}

?>
      </SELECT>
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


