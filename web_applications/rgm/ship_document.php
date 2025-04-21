<?PHP

require_once "CCGDB.php";
require_once "DB_Order.php";
require_once "DB_LocationManager.php";
require_once "DB_ProductManager.php";
require_once "utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$order_num = isset($_GET['order_num']) ? $_GET['order_num'] : '';

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

   $location_objects = DB_LocationManager::getShipDBLocations($database_object);

   $product_objects = DB_ProductManager::searchByOrder($database_object, $order_object);
}
catch ( Exception $e )
{
   echo $e->getMessage()."<BR>";
   exit;
}

$inputdatastr = isset($_POST['inputdatastr']) ? $_POST['inputdatastr'] : '';
#echo $inputdatastr."<BR>";
$inputdataaarr = mb_unserialize(urldecode($inputdatastr));

if ( is_array($inputdataaarr) &&
     isset($inputdataaarr['task']) &&
     $inputdataaarr['task'] === 'submit' &&
     count($errors) == 0 )
{
   #echo "<PRE>";
   #print_r($inputdataaarr);
   #echo "</PRE>";

   $shipping_data = new SimpleXMLElement('<?xml version="1.0" standalone="yes"?><shipping_data></shipping_data>');

   foreach ( array_keys($inputdataaarr) as $key )
   {
      $shipping_data->addChild($key, $inputdataaarr[$key]);
   }

   #echo htmlentities($shipping_data->asXML());

   $token = str_replace(".", "", uniqid(''));

   $xmlfile = "tmp/".$token.".xml";
   $htmlfile = "tmp/".$token.".html";
   $pdffile = "tmp/".$token.".pdf";

   try
   {
      # Create the XML
      file_put_contents($xmlfile, $shipping_data->asXML());

      system("/usr/bin/php make_shipping_document.php $xmlfile > $htmlfile", $exit_status);

      if ( $exit_status == 0 &&
           file_exists($htmlfile) )
      {
         system("/usr/local/bin/wkhtmltopdf -O landscape $htmlfile $pdffile");

         $finalxmlfile = 'documents/NOAA-ESRL_SS-'.$order_num.'_'.date('Y-m-d-His').'.xml';
         $finalhtmlfile = 'documents/NOAA-ESRL_SS-'.$order_num.'_'.date('Y-m-d-His').'.html';
         $finalpdffile = 'documents/NOAA-ESRL_SS-'.$order_num.'_'.date('Y-m-d-His').'.pdf';

         if ( file_exists($xmlfile) &&
              file_exists($htmlfile) &&
              file_exists($pdffile) )
         {
            rename ( $xmlfile, $finalxmlfile ); 
            rename ( $htmlfile, $finalhtmlfile ); 
            rename ( $pdffile, $finalpdffile ); 
         }
         else
         { throw new Exception("Problem creating shipping document."); }

         if ( ! file_exists($finalpdffile) )
         { throw new Exception("Problem creating shipping document."); }

         # Document created successfully

         $location_object = new DB_Location($database_object, $inputdataaarr['location_num']); 
         $order_object->setShippingLocation($location_object);
         $order_object->saveToDB($user_obj);

         header ( "Location: order_ship.php?num=$order_num" );
      }
      else
      { throw new Exception("Problem creating shipping document."); }

   }
   catch ( Exception $e )
   {
      array_push($errors, $e);
   }

}


?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src='ship_document.js?randnum=<?PHP echo time(); ?>'></SCRIPT>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
 </HEAD>
 <BODY>

<?PHP
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
      echo "<LI><DIV style='color:red'>".$e->getMessage()."</DIV></LI>";
   }
   echo "   </UL>";
   echo "  </TD>";
   echo " </TR>";
   echo "</TABLE>";
}

?>
  <FORM name='mainform' method='post'>
   <INPUT type='hidden' id='inputdatastr' name='inputdatastr'>
   <H1>Create Shipping Document</H1>
   <TABLE border='1' cellpadding='5' cellspacing='5'>
    <TR>
     <TH colspan='2'>Order details</TH>
    </TR>
    <TR>
     <TH>Num</TH>
     <TD>
      <?PHP echo $order_object->getNum(); ?>
     </TD>
    </TR>
    <TR>
     <TH>Due Date</TH>
     <TD>
      <?PHP echo $order_object->getDueDate(); ?>
     </TD>
    </TR>
    <TR>
     <TH>MOU Number</TH>
     <TD>
      <?PHP echo $order_object->getMOUNumber(); ?>
     </TD>
    </TR>
    <TR>
     <TH>Primary Customer</TH>
     <TD>
      <?PHP echo $order_object->getPrimaryCustomer()->getEmail(); ?>
     </TD>
    </TR>
   </TABLE>
   <HR>
   <TABLE>
    <TR>
     <TD valign='top'>
      Ship To:
     </TD>
     <TD>
      <SELECT id='location_num' name='location_num' title='Location'>
       <OPTION value=''>Please select a location</OPTION>
<?PHP

$input_value = ( isset($inputdataaarr['location_num']) ) ? $inputdataaarr['location_num'] : '';

foreach ( $location_objects as $location_object )
{
   $selected = ( $input_value == $location_object->getNum() ) ? 'SELECTED' : '';
   echo "<OPTION value='".$location_object->getNum()."' $selected>".$location_object->getAbbreviation().' - '.$location_object->getName()."</OPTION>";
}

?>
      </SELECT>
      <BR>
      <TEXTAREA style='outline: 1px solid black; background-color: #EFEFEF; color: black;' id='ship_to' name='ship_to' cols='100' rows='6' DISABLED></TEXTAREA>
     </TD>
    </TR> 
    <TR>
     <TD valign='top'>
      Ship From
     </TD>
     <TD>
      <TEXTAREA style='outline: 1px solid black; background-color: #EFEFEF; color: black;' id='ship_from' name='ship_from' cols='100' rows='6' DISABLED>
U.S. Department of Commerce
NOAA/ESRL/CCGG ESRL1
325 Broadway
Boulder, CO, 80305

ATTN: Duane Kitzis
PHONE: (303) 497-6675
FAX: (303) 497-6290</TEXTAREA>
     </TD>
    </TR> 
    <TR>
     <TD>
      Total Pieces
     </TD>
     <TD>
<?PHP

$input_value = (isset($inputdataaarr['total_pieces'])) ? $inputdataaarr['total_pieces'] : count($product_objects);
echo "<INPUT type='text' size='5' id='total_pieces' name='total_pieces' title='Total Pieces' value='$input_value'>";

?>
     </TD>
    </TR> 
    <TR>
     <TD>
      Value
     </TD>
     <TD>
<?PHP

   $input_value = ( isset($inputdataaarr['value']) ) ? $inputdataaarr['value'] : '200';
   echo "<INPUT type='text' id='value' name='value' title='Value' size='4' value='$input_value'>";

?>
     </TD>
    </TR> 
    <TR>
     <TD>
      Ship By
     </TD>
     <TD>
<?PHP

   $input_value = ( isset($inputdataaarr['ship_by']) ) ? $inputdataaarr['ship_by'] : '';
   echo "<INPUT type='text' id='ship_by' name='ship_by' title='Ship By' size='10' value='$input_value'>";

?>
     </TD>
    </TR> 
    <TR>
     <TD>
      Division / Org. Code
     </TD>
     <TD>
<?PHP

   $input_value = ( isset($inputdataaarr['org_code']) ) ? $inputdataaarr['org_code'] : '53-34-0000';
   echo "<INPUT type='text' id='org_code' name='org_code' title='Division / Org. Code' size='12' value='$input_value'>";

?>
     </TD>
    </TR> 
    <TR>
     <TD>
      Project / Task Number
     </TD>
     <TD>
<?PHP

   $input_value = ( isset($inputdataaarr['project_number']) ) ? $inputdataaarr['project_number'] : '36R1MYYPPT';
   echo "<INPUT type='text' id='project_number' name='project_number' title='Project / Task Number' size='12' value='$input_value'>";

?>
     </TD>
    </TR> 
    <TR>
     <TD valign='top'>
      Description
     </TD>
     <TD>
<TEXTAREA id='description' name='description' cols='80' rows='10'>
<?PHP

   $input_value = ( isset($inputdataaarr['cost']) ) ? $inputdataaarr['cost'] : '';
   if ( isset($inputdataaarr['description']) )
   {
      $input_value = $inputdataaarr['description'];
   }
   else
   {
      $input_value = '';
      $input_value .= "Aluminum cylinder(s) are pressurized to less than 135 atmospheres.\n";
      $input_value .= "UN 1956 [Carbon Dioxide in Air] 2.2 nt wt 4.7 KG.\n";
      $input_value .= "\n";
      $input_value .= "Serial Number(s):\n";

      $tmparr = array();
      foreach ( $product_objects as $product_object )
      {
         if ( is_object($product_object->getCylinder()) )
         { array_push($tmparr, $product_object->getCylinder()->getID()); }
      }

      $input_value .= join(', ', $tmparr)."\n";
   }

   echo $input_value;
?>
</TEXTAREA>
     </TD>
    </TR>
    <TR>
     <TD colspan='2' align='center'>
      <TABLE width='40%'>
       <TR>
        <TD>
         <INPUT type='button' value='Submit' onClick='SubmitCB();'>
        </TD>
        <TD>
         <?PHP echo "<A href='order_ship.php?num=$order_num'>"; ?>
          <INPUT type='button' value='Cancel'>
         </A>
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
