<?PHP

require_once("CCGDB.php");
require_once("DB_Cylinder.php");
require_once("DB_LocationManager.php");
require_once("DB_ProductManager.php");
require_once("DB_CalRequestManager.php");
require_once("DB_CylinderManager.php");
require_once("/var/www/html/inc/ccgglib_inc.php");
require_once "utils.php";
require_once "menu_utils.php";

session_start();

?>

<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src="product_extras.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
<title>RGM Extras</title>
 </HEAD>
 <BODY>
<?PHP

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$task = isset($_POST['task']) ? $_POST['task'] : '';
$productinfosstr = ( isset($_POST['productinfosstr'])) ? $_POST['productinfosstr'] : '';

$productinfos = mb_unserialize($productinfosstr);

CreateMenu($database_object, $user_obj);

$errors = array();
if ( $task === 'submit' )
{
   #echo "<PRE>"; 
   #print_r($productinfos);
   #echo "</PRE>";

   # First check to see if we get any errors
   $errors = SaveData($database_object, $productinfos);

   # If there are no errors, do the same thing but save the data
   if ( count($errors) == 0 )
   {
      $errors = SaveData($database_object, $productinfos, TRUE);
      # Load the data from the database
      $productinfos = LoadData($database_object);
   }

   if ( count($errors) == 0 )
   {
      print "Product information update successfully.";
      $productinfos = LoadData($database_object);
   }

}
else
{
   $productinfos = LoadData($database_object);
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

?>

  <FORM name='mainform' id='mainform' method='post'>
   <INPUT type='hidden' name='task' value=''>
<?PHP
   echo "<INPUT type='hidden' name='productinfosstr' value='$productinfosstr'>";

   $namearr = array();
   SendtoJS("productinfos",$productinfos, $namearr);
?>

   <SCRIPT>
    $(document).ready(function()
    {
      $("input[type=text], input[type=hidden], select, textarea").blur(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            SetValue($(this).attr('id'), $(this).val(), productinfos);
         }
      );
    });

   $(function() {
      var filllocations = [
       'NWR',
       'Scott Marrin',
      ];
      $( "input[type=text][id$=fill-location]" ).autocomplete({
         source: filllocations
      });
   })

   $(function() {
      $("input[type=text][id$=fill-date]").datepicker({
          onSelect: function(dateText)
          { SetValue($(this).attr('id'), $(this).val(), productinfos); }
      });

      //$("input[type=text][id$=fill-date]").datepicker( "option", "dateFormat", "yy-mm-dd" );
   })
   </SCRIPT>
   <TABLE>
    <TR>
     <TD><H1>Product Extras</H1></TD>
    </TR>
    <TR>
     <TD>
      <A href='product_extra_edit.php'>
       <INPUT type='button' value='Add New Product Extra'>
      </A>
      <TABLE border='1' cellpadding='5' cellspacing='5'>
       <TR>
        <TH>Row #</TH>
        <TH>Order Num</TH>
        <TH>Cylinder Details</TH>
        <TH>Location Details</TH>
        <TH>Analysis Status</TH>
       </TR>
<?PHP

   if ( count($productinfos) == 0 )
   {
      echo "<TR>";
      echo " <TD colspan='4'>";
      echo "  No product extras at this time.";
      echo " </TD>";
      echo "</TR>";
   }

   $productnum = 0;
   foreach ( $productinfos as $product_aarr )
   {
      echo "<TR>\n";
      echo " <TD valign='top' align='center'>\n";
      echo $productnum;
      echo "<BR>\n";
      echo " <A href='product_extra_edit.php?num=".$product_aarr['num']."'>\n";
      echo "  <INPUT type='button' value='Edit'>\n";
      echo " </A>\n";
      echo " </TD>\n";
      echo " <TD valign='top' align='center'>\n";
      $value = isset($product_aarr['order-num']) ? $product_aarr['order-num'] : '';
      echo "  <INPUT type='text' id='product".$productnum."_order-num' name='product".$productnum."_order-num' size='5' value='$value'>\n";
      echo " </TD>\n";
      echo " <TD valign='top'>\n";
      echo "  <TABLE cellspacing='3' cellpadding='3'>\n";
      echo "   <TR>\n";
      echo "    <TH>ID</TH>\n";
      echo "    <TD>\n";
      echo $product_aarr['db-cylinder-id'];
      echo "<INPUT type='hidden' id='product".$productnum."_db-cylinder-id' name='product".$productnum."_db-cylinder-id' value='".$product_aarr['db-cylinder-id']."'>\n";
      echo "    </TD>\n";
      echo "   </TR>\n";
      echo "  </TABLE>\n";
      echo " </TD>\n";
      echo " <TD valign='top' align='left'>\n";
      echo "  <DIV style='white-space: nowrap;'>\n";
      if ( isset($product_aarr['cylinder-location-abbr']) )
      { echo htmlentities($product_aarr['cylinder-location-abbr'], ENT_QUOTES, 'UTF-8'); }
      echo "  </DIV>\n";
      echo "  <DIV>\n";
      if ( isset($product_aarr['cylinder-location-comments']) )
      { echo htmlentities($product_aarr['cylinder-location-comments'], ENT_QUOTES, 'UTF-8'); }
      echo "  </DIV>\n";
      echo " </TD>\n";
      echo " <TD valign='top'>\n";

      if ( count($product_aarr['calrequests']) > 0 )
      {
         echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
         echo "   <THEAD>\n";
         echo "   <TR>\n";
         echo "    <TH>Specie</TH>\n";
         echo "    <TH colspan='2'>Status</TH>\n";
         echo "    <TH>Target</TH>\n";
         echo "    <TH>Analysis Type</TH>\n";
         echo "    <TH>Analysis Value</TH>\n";
         echo "    <TH>Analysis Repeatability</TH>\n";
         echo "    <TH>Comments</TH>\n";
         echo "   </TR>\n";
         echo "   </THEAD>\n";
         echo "   <TBODY>\n";

         foreach ( $product_aarr['calrequests'] as $calrequest_aarr )
         {
            echo "   <TR>\n";
            echo "    <TD>\n";
            echo $calrequest_aarr['abbr-HTML'];
            echo "    </TD>\n";

            echo "    <TD>\n";
            echo $calrequest_aarr['status-abbr'];
            echo "    </TD>\n";

            $color = $calrequest_aarr['status-color'];
            echo "    <TD style='background-color:$color'>\n";
            echo "&nbsp;&nbsp;&nbsp;";
            echo "    </TD>\n";

            echo "    <TD>\n";
            echo htmlentities($calrequest_aarr['target-value'], ENT_QUOTES, 'UTF-8');
            echo "    </TD>\n";

            echo "    <TD>\n";
            echo $calrequest_aarr['analysis-type'];
            echo "    </TD>\n";

            echo "    <TD>\n";
            echo htmlentities($calrequest_aarr['analysis-value'], ENT_QUOTES, 'UTF-8');
            echo "    </TD>\n";

            echo "    <TD>\n";
            echo htmlentities($calrequest_aarr['analysis-repeatability'], ENT_QUOTES, 'UTF-8');
            echo "    </TD>\n";

            echo "    <TD style='white-space: nowrap;'>\n";
            echo htmlentities($calrequest_aarr['comments'], ENT_QUOTES, 'UTF-8');
            echo "    </TD>\n";
            echo "   </TR>\n";
         }
         echo "   </TBODY>\n";
         echo "  </TABLE>\n";
      }
      else
      {
         # Handle the case of no analyzes
         echo "  <TABLE border='1' cellspacing='3' cellpadding='3'>\n";
         echo "   <TR>\n";
         echo "    <TH></TH>\n";
         echo "    <TH>Status</TH>\n";
         echo "   </TR>\n";
         echo "   <TR>\n";
         echo "    <TD>\n";
         echo "No analyzes\n";
         echo "    </TD>\n";
         echo "    <TD>\n";
         echo $product_aarr['status-abbr'];
         echo "    </TD>\n";
         echo "   </TR>\n";
         echo "  </TABLE>\n";
      }

      if ( $product_aarr['comments'] != '' )
      {
         echo "<DIV style='font-weight:bold'>Comments:</DIV>";
         echo htmlentities($product_aarr['comments'], ENT_QUOTES, 'UTF-8');
      }

      echo " </TD>\n";

      $productnum++;
   }
?>
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
         <INPUT type='button' value='Submit' onClick='SubmitCB("submit")'>
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

<?PHP

exit;

function LoadData(DB $input_database_object)
{

   $product_objects = DB_ProductManager::searchForExtras($input_database_object);

   #echo "<PRE>";
   #print_r($product_objects);
   #echo "</PRE>";

   $info = array();

   foreach ( $product_objects as $product_object )
   {
      $product_aarr = array();
      $product_aarr['num'] = $product_object->getNum();
      $product_aarr['status-abbr'] = $product_object->getStatus();

      $product_aarr['db-cylinder-id'] = '';
      if ( is_object($product_object->getCylinder()) )
      {
         $product_aarr['db-cylinder-id'] = $product_object->getCylinder()->getID();

         if ( is_object($product_object->getCylinder()->getLocation()) )
         {
            $product_aarr['cylinder-location-abbr'] = $product_object->getCylinder()->getLocation()->getAbbreviation();
            $product_aarr['cylinder-location-comments'] = $product_object->getCylinder()->getLocationComments();
         }
      }
      $product_aarr['cylinder-size'] = $product_object->getCylinderSize();
      $product_aarr['comments'] = $product_object->getComments();

      $product_aarr['calrequests'] = array();

      $calrequest_objects = DB_CalRequestManager::searchByProduct($input_database_object, $product_object);

      foreach ( $calrequest_objects as $calrequest_object )
      {
         $calrequest_aarr['abbr'] = $calrequest_object->getCalService()->getAbbreviation();
         $calrequest_aarr['abbr-HTML'] = $calrequest_object->getCalService()->getAbbreviationHTML();
         $calrequest_aarr['status-abbr'] = $calrequest_object->getStatus();
         $calrequest_aarr['status-color'] = $calrequest_object->getStatusColorHTML();
         $calrequest_aarr['target-value'] = $calrequest_object->getTargetValue();
         $calrequest_aarr['analysis-type'] = $calrequest_object->getAnalysisType();
         $calrequest_aarr['analysis-value'] = $calrequest_object->getAnalysisValue();
         $calrequest_aarr['analysis-repeatability'] = $calrequest_object->getAnalysisRepeatability();
         $calrequest_aarr['comments'] = $calrequest_object->getComments();


         array_push($product_aarr['calrequests'], $calrequest_aarr);
      }

      array_push($info, $product_aarr);
   }

   #echo "<PRE>";
   #print_r($info);
   #echo "</PRE>";

   return ($info);
}

function SaveData(DB $input_database_object, $info, $save=FALSE)
{
   $errors = array();

   $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

   try
   {
      $productnum = 0;
      foreach ( $info as $productinfo )
      {
         try
         {
            $product_object = new DB_Product($input_database_object, $productinfo['num']);

            # If any of the inputs for a row are not empty then
            # try to process the row
            if ( isset($productinfo['order-num']) &&
                 ! isBlank($productinfo['order-num']) )
            {
               $cln_aarr = array();

               if ( ValidInt($productinfo['order-num']) )
               {
                  $cln_aarr['order-num'] = $productinfo['order-num'];
               }
               else
               { throw new Exception ("Invalid order num provided on row #".$productnum); }

               #echo "<PRE>";
               #print_r($cln_aarr);
               #echo "</PRE>";

               # Try to create the order and add to product
               $order_object = new DB_Order($input_database_object, $cln_aarr['order-num']);

               $product_object->setOrder($order_object);
               $product_object->saveToDB($user_obj);
            }
         }
         catch (Exception $e)
         { array_push($errors, $e); }

         $productnum++;
      }
   }
   catch (Exception $e)
   { array_push($errors, $e); }

   return($errors);
 

}
