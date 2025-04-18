<?PHP

require_once "CCGDB.php";
require_once("DB_Order.php");
require_once "utils.php";
require_once "menu_utils.php";

session_start();

?>
<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/php_serialize.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="order_ship-docs.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>
<?PHP
$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$order_num = isset($_GET['num']) ? $_GET['num'] : '';
$input_data = isset( $_POST['input_data'] ) ? $_POST['input_data'] : '';

CreateMenu($database_object, $user_obj);

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

$errors = array();
try
{
   if ( ValidInt($order_num) )
   {
      $order_object = new DB_Order($database_object, $order_num);
   }
   else
   {
      print "Please provide a valid order number.";
      exit; 
   }
}
catch ( Exception $e )
{
   echo "<DIV style='color:red'>".$e->getMessage()."</DIV>";
   exit;
}

if ( $order_object->getStatus('num') == '7' )
{
   print "Order has been cancelled.";
   exit;
}
elseif ( $order_object->getStatus('num') != '3' &&
         $order_object->getStatus('num') != '4' &&
         $order_object->getStatus('num') != '6' &&
         $order_object->getStatus('num') != '5' )
{
   print "Order must be processing, processing complete, ready to ship, or complete to upload shipping documents.";
   exit;
}

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'upload' )
{

   $allowedExts = array("pdf", "PDF");
   $errors = array();

   $fileaarrs = array();

   $fileids = array ( "file1", "file2", "file3" );

   foreach ( $fileids as $fileid )
   {
      if ( $_FILES[$fileid]["name"] != '' )
      { array_push($fileaarrs, $_FILES[$fileid]); }
   }

   foreach ( $fileaarrs as $fileaarr )
   {
      $extension = end(explode(".", $fileaarr["name"]));
      if ( $fileaarr["type"] == "application/pdf" &&
           $fileaarr["size"] > 0 &&
           $fileaarr["size"] < 10000000 &&
           in_array($extension, $allowedExts) )
      {
         if ($fileaarr["error"] > 0)
         {
            $e = new Exception("File error: " . $fileaarr["error"]);
            array_push($errors, $e);
         }
         else
         {
            #echo "Upload: " . $fileaarr["name"] . "<br>";
            #echo "Type: " . $fileaarr["type"] . "<br>";
            #echo "Size: " . ($fileaarr["size"] / 1024) . " kB<br>";
            #echo "Temp file: " . $fileaarr["tmp_name"] . "<br>";

            $fields = explode('_', reset(explode(".", $fileaarr["name"])));
            $filenamefields = $fields;

            if ( isset($fields[count($fields)-2]) &&
                 isset($fields[count($fields)-1]) &&
                 preg_match('/^[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{5,6}$/', $fields[count($fields)-2]) &&
                 preg_match('/^N[0-9]+$/', $fields[count($fields)-1]) )
            {
               $filenamefields[count($fields)-2] = date("Y-m-d-His");
               $filenamefields[count($fields)-1] = sprintf("N%d", $order_object->getNum());
            }
            else
            {
               array_push($filenamefields, date("Y-m-d-His"));
               array_push($filenamefields, sprintf("N%d", $order_object->getNum()));
            }

            $localfile = 'documents/'.join('_', $filenamefields).'.'.$extension;

            if (file_exists($localfile))
            {
               $e = new Exception ("File already exists. Please try again.");
               array_push($errors, $e);
            }
            else
            {
               $input_arr = array();
               try
               {
                  # Move the temporary file to the $localfile location
                  move_uploaded_file($fileaarr["tmp_name"], $localfile);
                  #echo "Stored in: " . $localfile;
               }
               catch(Exception $e)
               {
                  array_push($errors, $e);
               }
            }
         }
      }
      else
      {
         $e = new Exception("Invalid input file. Must be non-empty PDF file and less than 10 MB.");
      array_push($errors, $e);
      }
   }
}
if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'remove' )
{
   #echo "<PRE>";
   #print_r($input_data_aarr);
   #echo "</PRE>";

   #print basename($input_data_aarr['file']);

   #echo "<BR>";

   $cleanfile = 'documents/'.basename($input_data_aarr['file']);

   if ( file_exists($cleanfile) &&
        filetype($cleanfile) == 'file' )
   {
      unlink($cleanfile);
   }
   else
   {
      $e = new Exception("File not found.");
      array_push($errors, $e);
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
      #Log::update($user_obj->getUsername(), $e->__toString());
      #echo "    <LI><DIV style='color:red'>".$e->getMessage()."</DIV></LI>";
      echo "    <LI><DIV style='color:red'>".$e->__toString()."</DIV></LI>";
   }
   echo "   </UL>";
   echo "  </TD>";
   echo " </TR>";
   echo "</TABLE>";
}

?>

  <FORM name='mainform' id='mainform' method='post' enctype='multipart/form-data'>
   <INPUT type='hidden' id='input_data' name='input_data'>
   <TABLE border='0' cellspacing='3' cellpadding='3'>
    <TR>
     <TD align='center'>
      <H1>Order Shipping Documents</H1>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE border='1' cellspacing='5' cellpadding='5' width='100%'>
       <TR>
        <TD>
         <TABLE cellspacing='2' cellpadding='2'>
<?PHP
   $shipping_documents = $order_object->getShippingDocuments();
   
   if ( count($shipping_documents) > 0 )
   {
      echo "<TR>";
      echo " <TH colspan='2'>Available documents</TH>";
      echo "<TR>";

      rsort($shipping_documents);

      foreach ( $shipping_documents as $shipping_document )
      {
         $shipping_documentfields = preg_split('/\//', $shipping_document);

         $shipping_document_filename = array_pop($shipping_documentfields);

         echo "<TR>";
         echo " <TD>";
         echo "  <A href='$shipping_document'>$shipping_document_filename</A>";
         echo " </TD>";
         echo " <TD>";
         echo "  <INPUT type='button' value='X' onClick='RemoveFileCB(\"".$shipping_document_filename."\")'>";
         echo " </TD>";
         echo "</TR>";
      }
   }
   else
   {
      echo "No shipping documents currently associated with this order.";
   }
?>
         </TABLE>
        </TD>
       </TR>
       <TR>
        <TD>
         <TABLE border='0'>
          <TR>
           <TH colspan='2'>Upload new files</TH>
          </TR>
          <TR>
           <TD>
            <INPUT type="file" name="file1" id="file1">
            <BR>
            <INPUT type="file" name="file2" id="file2">
            <BR>
            <INPUT type="file" name="file3" id="file3">
           </TD>
           <TD>
            <INPUT type='button' value='Upload' onClick='UploadCB()'>
           </TD>
          </TR>
         </TABLE>
        </TD>
       </TR>
       <TR>
        <TD align='center'>
         <?PHP echo "<A href='order_status.php?num=".$order_object->getNum()."'><INPUT type='button' value='Order Status'></A>"; ?>
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
   </TABLE>
   <TABLE>
    <TR>
     <TD>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
        </TD>
        <TD align='right' width='50%'>
         <INPUT type='button' value='Reload' onClick='window.location.href=window.location.href;'>
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
