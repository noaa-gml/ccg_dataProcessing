<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "DB_CylinderManager.php";
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

$input_action = isset ( $_GET['action'] ) ? $_GET['action'] : '';

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

$chkarr = array ( 'update', 'add' );

if ( ! in_array($input_action, $chkarr ) )
{ $input_action = 'add'; }

$input_data_aarr['action'] = $input_action;

if ( $input_data_aarr['action'] === 'add' )
{
   if ( isset($_GET['id']) && preg_match('/^[A-Za-z0-9\-]{3,}$/', urldecode($_GET['id'])) )
   {
      $input_data_aarr['cylinder_id'] = urldecode($_GET['id']);
   }
}
elseif ( $input_data_aarr['action'] === 'update' )
{
   if ( ! isset($input_data_aarr['task']) )
   {
      if ( isset($_GET['num']) && Validator_Utils::ValidInt($_GET['num']) )
      {
         $input_data_aarr['cylinder_num'] = $_GET['num'];
         $input_data_aarr['task'] = 'load';
      }
      elseif ( isset($_GET['id']) && preg_match('/^[A-Za-z0-9\-]{3,}$/', urldecode($_GET['id'])) )
      {
         $input_data_aarr['cylinder_id'] = urldecode($_GET['id']);
         $input_data_aarr['task'] = 'load';
      }
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
  <SCRIPT language='JavaScript' src='cylinder_edit.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>
  <FORM name='mainform' method='POST' onsubmit="return false;">
   <INPUT type='hidden' name='input_data' id='input_data'>
   <?PHP echo "<INPUT type='hidden' name='nsubmits' id='nsubmits' value='$nsubmits'>"; ?>
   <?PHP CreateMenu($database_object, $user_obj); ?>


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
      if ( isset($input_data_aarr['cylinder_num']) )
      {
         try
         {
            $cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_num'],'num');

            $input_data_aarr['cylinder_id'] = $cylinder_obj->getID();
            $input_data_aarr['cylinder_recertification_date'] = $cylinder_obj->getRecertificationDate();
            $input_data_aarr['cylinder_size_num'] = $cylinder_obj->getSize('num');
            $input_data_aarr['cylinder_type_num'] = $cylinder_obj->getType('num');
            $input_data_aarr['cylinder_status_num'] = $cylinder_obj->getStatus('num');
            $input_data_aarr['cylinder_status_abbr'] = $cylinder_obj->getStatus('abbr');
            $input_data_aarr['cylinder_comments'] = $cylinder_obj->getComments();
         }
         catch (Exception $e)
         {
            unset($input_data_aarr);
            array_push($errors, $e);
         }
      }
      elseif ( isset($input_data_aarr['cylinder_id']) )
      {
         try
         {
            $cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_id'],'id');

            $input_data_aarr['cylinder_num'] = $cylinder_obj->getNum();
            $input_data_aarr['cylinder_id'] = $cylinder_obj->getID();
            $input_data_aarr['cylinder_recertification_date'] = $cylinder_obj->getRecertificationDate();
            $input_data_aarr['cylinder_size_num'] = $cylinder_obj->getSize('num');
            $input_data_aarr['cylinder_type_num'] = $cylinder_obj->getType('num');
            $input_data_aarr['cylinder_status_num'] = $cylinder_obj->getStatus('num');
            $input_data_aarr['cylinder_status_abbr'] = $cylinder_obj->getStatus('abbr');
            $input_data_aarr['cylinder_comments'] = $cylinder_obj->getComments();
         }
         catch (Exception $e)
         {
            $tmp = $input_data_aarr['cylinder_id'];
            unset($input_data_aarr);
            $input_data_aarr['cylinder_id'] = $tmp;
            array_push($errors, $e);
         }
      }
      else
      {
         unset($input_data_aarr);
      }

      if ( is_object($cylinder_obj) )
      {
         $labelid = str_replace(' ', '_', $cylinder_obj->getID() );

         if ( ! file_exists('labels/'.$labelid.'.png') )
         {
            # Create tank barcode label
            system("/projects/refgas/label/tanklabelmaker.pl '".escapeshellarg($cylinder_obj->getID())."'", $errcode);

            if ( $errcode != 0 )
            { throw new LogicException("Failed to create tank barcode label."); }
            else
            {
               echo "<TR><TD>";
               echo "<DIV align='center' style='color:green'>".$cylinder_obj->getID()." barcode image file created.</DIV>";
               echo "</TD></TR>";
            }
         }
      }
   }
   elseif ( $input_data_aarr['task'] == 'save' &&
            $input_data_aarr['action'] == 'update' )
   {
      try
      {
         if ( ! isset($input_data_aarr['cylinder_num']) )
         { throw new Exception("Cylinder num required to update cylinder."); }

         $cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_num'], 'num');
         $db_cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_num'], 'num');
         $cylinder_obj->updateID($input_data_aarr['cylinder_id']);
         $cylinder_obj->setRecertificationDate($input_data_aarr['cylinder_recertification_date']);
         $cylinder_obj->setSize($input_data_aarr['cylinder_size_num']);
         $cylinder_obj->setType($input_data_aarr['cylinder_type_num']);
         $cylinder_obj->setStatus($input_data_aarr['cylinder_status_num'], 'num');

         if ( isset($input_data_aarr['cylinder_comments']))
         { $cylinder_obj->setComments($input_data_aarr['cylinder_comments']); }

         if ( ! $cylinder_obj->equals($db_cylinder_obj) )
         { $cylinder_obj->saveToDB($_SESSION['user']); }

         #echo "<PRE>";
         #print_r($cylinder_obj);
         #echo "</PRE>";

         # Use the object to print the ID so that it is the same case as
         #  the database entry 
         echo "<TR><TD>";
         echo "<DIV align='center' style='color:green'>".$cylinder_obj->getID()." updated successfully.</DIV>";
         echo "</TD></TR>";

         # Create a new label if the ID is updated
         #   or the label file does not exist

         $labelid = str_replace(' ', '_', $cylinder_obj->getID() );

         if ( $db_cylinder_obj->getID() !== $cylinder_obj->getID() ||
              ! file_exists('labels/'.$labelid.'.png') )
         {
            # Create tank barcode label
            system("/projects/refgas/label/tanklabelmaker.pl '".escapeshellarg($cylinder_obj->getID())."'", $errcode);

            if ( $errcode != 0 )
            { throw new LogicException("Failed to create tank barcode label."); }
            else
            {
               echo "<TR><TD>";
               echo "<DIV align='center' style='color:green'>".$cylinder_obj->getID()." barcode image file created.</DIV>";
               echo "</TD></TR>";
            }
         }

         #unset($input_data_aarr);

         $input_data_aarr['cylinder_num'] = $cylinder_obj->getNum();
         $input_data_aarr['task'] = 'load';
      }
      catch (Exception $e)
      {
         array_push($errors, $e);
         $input_data_aarr['task'] = 'load';
      }
   }
   elseif ( $input_data_aarr['task'] == 'save' &&
            $input_data_aarr['action'] == 'add' )
   {
      try
      {
         $cylinder_obj = new DB_Cylinder($database_object, $input_data_aarr['cylinder_id'], $input_data_aarr['cylinder_recertification_date']);

         $location_obj = new DB_Location($database_object, '1');
         $cylinder_obj->checkin($location_obj);

         if ( isset($input_data_aarr['cylinder_comments']))
         { $cylinder_obj->setComments($input_data_aarr['cylinder_comments']); }

         $cylinder_obj->setSize($input_data_aarr['cylinder_size_num']);
         $cylinder_obj->setType($input_data_aarr['cylinder_type_num']);

         $cylinder_obj->saveToDB($_SESSION['user']);

         #echo "<PRE>";
         #print_r($cylinder_obj);
         #echo "</PRE>";

         # Use the object to print the ID so that it is the same case as
         #  the database entry 
         echo "<TR><TD>";
         echo "<DIV align='center' style='color:green'>".$cylinder_obj->getID()." added successfully.</DIV>";
         echo "</TD></TR>";

         # Create tank barcode label
         system("/projects/refgas/label/tanklabelmaker.pl '".escapeshellarg($cylinder_obj->getID())."'", $errcode);

         if ( $errcode != 0 )
         { throw new LogicException("Failed to create tank barcode label."); } 

         #unset($input_data_aarr);

         $input_data_aarr['cylinder_num'] = $cylinder_obj->getNum();
         $input_data_aarr['task'] = 'load';

         echo "<SCRIPT>";
         echo "window.location.replace('cylinder_edit.php?num=".urlencode($cylinder_obj->getNum())."&action=update');";
         echo "</SCRIPT>";
      }
      catch (Exception $e)
      { array_push($errors, $e); }
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
# This AJAX check is to make sure that a new cylinder ID does not match an
#  existing one.
#  A similar check is done when updating a cylinder to make sure that it exists.
#  It is implemented through the cylinder_update.php interface.
#

if ( $input_data_aarr['action'] == 'add' &&
     ! isset($input_data_aarr['task']) )
{
?>
   <SCRIPT>
    $(document).ready(function()
    {
      $("input[type=text][id='cylinder_id']").blur(
         function ()
         {
           if ( $(this).val() != '' )
           {
              cylinder_id = $(this).val();

              $.ajax({
                 url: 'cylinder_check-exists.php',
                 type: 'get',
                 data: { id: $(this).val() },
                 success:function(data)
                 {
                     //alert(data);
                     //alert(cylinder_id);

                     if ( data == 1 )
                     { $('#cylinder-comments').html('Cylinder already exists.<BR><A href="cylinder_edit.php?id='+cylinder_id+'&action=update"><INPUT type="button" value="Update Cylinder"></A>'); }
                     else
                     { $('#cylinder-comments').html('');}
                 } 
              });
           }
           else
           {
              // Clear the cylinder comments
              $('#cylinder-comments').html('');
           }
         }
      );
    });
   </SCRIPT>

<?PHP
}

#
##############################
#
# Create the body of
#  the page
#
##############################
#

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] == 'load' &&
     isset($input_data_aarr['cylinder_num']) )
{
?>
    <TR>
     <TD>
      <H1>Update Cylinder</H1>
     </TD>
    </TR>
    <TR>
     <TD align='center' style='border-style:solid;border-width:1px;'>
      <TABLE width='100%' cellspacing='5' cellpadding='5'>
       <TR>
        <TD>
         Cylinder num
        </TD>
        <TD>
         <?PHP echo "<FONT style='font-weight:bold; color:blue; font-size:125%;'>".$cylinder_obj->getNum()."</FONT>"; ?>
         <INPUT type='hidden' name='cylinder_num' id='cylinder_num' value='<?PHP echo $cylinder_obj->getNum(); ?>'>
        </TD>
       </TR>
<?PHP
}
else
{
?>
    <TR>
     <TD>
      <H1>Add Cylinder</H1>
     </TD>
    </TR>
    <TR>
     <TD align='center' style='border-style:solid;border-width:1px;'>
      <TABLE width='100%' cellspacing='5' cellpadding='5'>
<?PHP
}
?>
    <TR>
     <TD>
      Cylinder ID
     </TD>
     <TD>
<?PHP
$value = ( isset($input_data_aarr['cylinder_id']) ) ? $input_data_aarr['cylinder_id'] : '';
echo "<INPUT type='text' name='cylinder_id' id='cylinder_id' size='15' onKeyup='this.value = this.value.toUpperCase();' value='$value'>";
?>
      <BR>
      <DIV style='color:red' id='cylinder-comments' name='cylinder-comments'></DIV>
     </TD>
    </TR>
    <TR>
     <TD>
      DOT Date
     </TD>
     <TD>
<?PHP
$value = ( isset($input_data_aarr['cylinder_recertification_date']) ) ? $input_data_aarr['cylinder_recertification_date'] : '99-99';
echo "<INPUT type='text' name='cylinder_recertification_date' id='cylinder_recertification_date' size='5' maxlength='5' value='$value' onClick='if (this.value == \"99-99\") { this.value = \"\"};' onBlur='if (this.value == \"\" ) { this.value = \"99-99\"};'>";
?>
     </TD>
    </TR>
    <TR>
     <TD>
      Size
     </TD>
     <TD>
      <SELECT name='cylinder_size_num' id='cylinder_size_num'>
<?PHP
$aarr = DB_CylinderManager::getCylinderSizes($database_object);

if ( !isset($input_data_aarr['cylinder_size_num'] ) )
{ $input_data_aarr['cylinder_size_num'] = '8'; }

foreach ( $aarr as $value=>$name )
{
   $selected = ( isset($input_data_aarr['cylinder_size_num']) && $value == $input_data_aarr['cylinder_size_num'] ) ? 'SELECTED' : ''; 
   echo "<OPTION value='$value' $selected>$name</OPTION>";
}

?>
      </SELECT>
     </TD>
    </TR>
    <TR>
     <TD>
      Type 
     </TD>
     <TD>
      <SELECT name='cylinder_type_num' id='cylinder_type_num'>
<?PHP
$aarr = DB_CylinderManager::getCylinderTypes($database_object);

foreach ( $aarr as $value=>$name )
{
   $selected = ( isset($input_data_aarr['cylinder_type_num']) && $value == $input_data_aarr['cylinder_type_num'] ) ? 'SELECTED' : ''; 
   echo "<OPTION value='$value' $selected>$name</OPTION>";
}

?>
      </SELECT>
     </TD>
    </TR>

<?PHP
if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] == 'load' &&
     isset($input_data_aarr['cylinder_num']) )
{
?>
    <TR>
     <TD>
      Status
     </TD>
     <TD>
<?PHP

if ( isset($input_data_aarr['cylinder_status_num']) &&
     ( $input_data_aarr['cylinder_status_num'] == '2' ||
       $input_data_aarr['cylinder_status_num'] == '6' ) )
{
   $aarr = DB_CylinderManager::getCylinderStatuses($database_object);

   echo "<SELECT name='cylinder_status_num' id='cylinder_status_num'>";

   $status_nums = array ('2', '6' );

   foreach ( $status_nums as $value )
   {
      $selected = ( isset($input_data_aarr['cylinder_status_num']) && $value == $input_data_aarr['cylinder_status_num'] ) ? 'SELECTED' : ''; 
      echo " <OPTION value='$value' $selected>".$aarr[$value]."</OPTION>";
   }
   echo "</SELECT>";
}
else
{
   echo "<FONT style='font-weight:bold; color:blue; font-size:125%;'>".$cylinder_obj->getStatus('abbr')."</FONT>";
   echo "<INPUT type='hidden' name='cylinder_status_num' id='cylinder_status_num' value='".$cylinder_obj->getStatus('num')."'>";
}

?>
     </TD>
    </TR>
<?PHP
}
?>
    <TR>
     <TD>
      Comments
     </TD>
     <TD>
<?PHP
$value = ( isset($input_data_aarr['cylinder_comments']) ) ? $input_data_aarr['cylinder_comments'] : '';
echo "<TEXTAREA name='cylinder_comments' id='cylinder_comments' cols='40'>$value</TEXTAREA>";
?>
     </TD>
    </TR>
   </TD>
  </TR>
 </TABLE>
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
         <?PHP echo "<INPUT type='button' value='Back' onClick='history.go($nsubmits);'>"; ?>
<?PHP #         <INPUT type='button' value='Back' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> ?>
        </TD>
       </TR>
<?PHP

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'load' )
{
   echo "       <TR>";
   echo "        <TD colspan='2'>";
   echo "         <A href='cylinder_edit.php?action=add'>";
   echo "          <INPUT type='button' value='Add New Cylinder'>";
   echo "         </A>";
   echo "        </TD>";
   echo "       </TR>";
   echo "       <TR>";
   echo "        <TD>";
   echo "         <A href='cylinder_update.php'>";
   echo "          <INPUT type='button' value='Update Another Cylinder'>";
   echo "         </A>";
   echo "        </TD>";
   echo "       </TR>";
}
else
{
   echo "       <TR>";
   echo "        <TD colspan='2'>";
   echo "         <A href='cylinder_update.php'>";
   echo "          <INPUT type='button' value='Update Cylinder'>";
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

