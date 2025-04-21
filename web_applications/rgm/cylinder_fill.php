<?PHP

require_once("CCGDB.php");
require_once("DB_Cylinder.php");
require_once("DB_Location.php");
require_once("DB_ProductManager.php");
require_once("DB_CalRequestManager.php");
require_once("DB_LocationManager.php");
require_once("/var/www/html/inc/ccgglib_inc.php");
require_once "menu_utils.php";
require_once "utils.php";

session_start();

?>


<HTML>
 <HEAD>
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/tablesorter-blue/style.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-tablesorter-pager.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src="cylinder_fill.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>

<?PHP

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);
#var_dump($user_obj);
$task = isset($_POST['task']) ? $_POST['task'] : '';
$productinfosstr = ( isset($_POST['productinfosstr'])) ? $_POST['productinfosstr'] : '';

$productinfos = mb_unserialize(urldecode($productinfosstr));

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
      echo "Fill information update successfully.<BR>";
      echo "<FONT style='color:#E68A2E'>Please note that cylinders are now marked as shipped to their respective fill location.</FONT>";
      $productinfosstr = '';
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

$location_objs = DB_LocationManager::getFillDBLocations($database_object);
?>

  <FORM name='mainform' id='mainform' method='post'>
   <INPUT type='hidden' name='task' value=''>
<?PHP
   echo "<INPUT type='hidden' name='productinfosstr' id='productinfosstr' value='$productinfosstr'>";

   $namearr = array();
   SendtoJS("productinfos",$productinfos, $namearr);
?>

   <SCRIPT>
    $(document).ready(function()
    {
      // Please see http://tablesorter.com/docs/example-options-headers.html
      $("#mainTable").tablesorter({ 
          // pass the headers argument and assing a object 
          headers: { 
              // assign the eigth column (we start counting zero) 
              8: { 
                  // disable it by setting the property sorter to false 
                  sorter: false 
              } 
          },  
      });

      $("input[type=text], input[type=hidden], select, textarea").blur(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            SetValue($(this).attr('id'), $(this).val(), productinfos);
         }
      );

      $("input[type=text][id$='_cylinder-id'], input[type=hidden][id$='_db-cylinder-id']").blur(
         function ()
         {
           if ( $(this).val() != '' )
           {
              var idfields = $(this).attr('id').split('_');
      
              $.ajax({
                 url: 'cylinder_check-dot-date.php',
                 type: 'get',
                 data: { id: $(this).val(),include_comments:1 },
                 success:function(data)
                 {
                     //alert(data);
                     $('#'+idfields[0]+'_cylinder-comments').html(data);
                 } 
              });
           }
           else
           {
              // Clear the cylinder comments
              $('#'+idfields[0]+'_cylinder-comments').html('');
           }
         }
      );

      // If the location textbox is set to a certain location then set
      //   the fill method
      $( "select[id$='_fill-location-num']" ).change(
         function()
         {
            // alert($(this).attr('id')+' '+$(this).val());
            var idfields = $(this).attr('id').split('_');

            if ( $(this).val() == '3' )
            {
               // If 'NWR' is selected
               $( '#'+idfields[0]+'_fill-method' ).val('RIX SA6').trigger('blur');
            }
            else if ( $(this).val() == '4' )
            {
               // If 'Scott Marrin' is selected
               $( '#'+idfields[0]+'_fill-method' ).val('GRAV BLEND').trigger('blur');
            }
            else
            {
               $( '#'+idfields[0]+'_fill-method' ).val('').trigger('blur');
            }
         }
      );

      // Display the autocomplete menu when the textbox is focused
      $( "input[type=text][id$=fill-method]" ).focus(
         function()
         {
            $(this).autocomplete("search", "");
         }
      );

      $("input[type=checkbox][id^=col_toggle_]").click(function() {
         var idfields = $(this).attr('id').split('_');

         if ( $(this).prop("checked") == true )
         {
            $("table#mainTable th[id$='_"+idfields[2]+"']").show();
            $("table#mainTable td[id$='_"+idfields[2]+"']").show();
         }
         else
         {
            $("table#mainTable th[id$='_"+idfields[2]+"']").hide();
            $("table#mainTable td[id$='_"+idfields[2]+"']").hide();
         }

         // Find the columns that have been unselected
         var unselectedcols = [];
         $("input[type=checkbox][id^=col_toggle_]").each ( function ()
         {
             if ( $(this).prop("checked") == false )
             {
                var idfields = $(this).attr('id').split('_');

                unselectedcols.push(idfields[2]);
             }
         });
         //alert(unselectedcols.join(','));
             
         // Save the preferences to user preferences 
         $.ajax({
            url: 'user_set-preferences.php',
            type: 'get',
            data: { id:location.pathname.split("/").slice(-1).toString(),value:encodeURIComponent(unselectedcols.join(',')) },
            success:function(data)
            {
               // Display the error to screen
               if ( data.toString() != '' )
               { alert('Error saving user preferences: '+data.toString()); }
            }
         }); 
      });

      $("#col_table_btn").click(function() {
         if ( $(this).val() == 'Show' )
         {
            $('#col_table').show();
            $(this).val('Hide');
         }
         else
         {
            $('#col_table').hide();
            $(this).val('Show');
         }
      });

    });

    $(window).load(function()
    {
      // On the first load, productinfostr should be empty
      //    on subsequent loads there will be information.
      //    This is to prevent automatically over writing
      //    information that the user may have typed in the
      //    fill method since location NWR and Scott Marrin
      //    will set the fill method when selected
      //
      // Please note, this MUST be the first thing in $(window).load()
      //    in order to work properly
      //
      if ( $("#productinfosstr").val() == '' )
      {
         $("select[id$='_fill-location-num']").each(
            function ()
            {
               $(this).trigger('change').trigger('blur');
            }
         );
      }

      $("input[type=hidden][id$='_db-cylinder-id']").each(
         function ()
         {
            $(this).trigger('blur');
         }
      );

      // Load the user preferences from the database
      $.ajax({
         url: 'user_get-preferences.php',
         type: 'get',
         data: { id:location.pathname.split("/").slice(-1).toString() },
         success:function(encoded_data)
         {
             //alert('hi '+data.toString());

             // The user has set no user preferences
             if ( encoded_data == '' ) { return; }

             data = decodeURIComponent(encoded_data); 

             var i;
             cols = data.split(',');

             // Loop through each toggle
             $("input[type=checkbox][id^=col_toggle_]").each ( function ()
             {
                var idfields = $(this).attr('id').split('_');

                for ( i=0; i < cols.length; i++ )
                {
                   if ( idfields[2] == cols[i] )
                   {
                      if ( $(this).prop("checked") == true )
                      {
                         // alert(idfields[2]);
                         // Uncheck the checkbox if there is a match in
                         //  user preferences

                         $(this).trigger('click');
                      }
                      break;
                   } 
                }
             });
         } 
      });
    });

<?PHP
$tmparr = array();

foreach ( $location_objs as $location_obj )
{
   $value = $location_obj->getNum();
   $name = $location_obj->getAbbreviation();

   array_push($tmparr, sprintf('{label:"%s", value:"%d"}', $name, $value));
}

?>

    $(function() {
       var availablelocations = [
       <?PHP echo join(',', $tmparr); ?>
       ];
       $( "input[type=text][id$='_location-search']" ).autocomplete({
          source: availablelocations
       });
       $( "input[type=text][id$='_location-search']" ).autocomplete({
          select: function( event, ui ) {
               var idfields = $(this).attr('id').split('_');
               $("#"+idfields[0]+"_fill-location-num").val(ui.item.value).change().blur();
               $(this).val('');
               return false;
          }
       });
       $( "input[type=text][id$='_location-search']" ).autocomplete({
          change: function( event, ui ) {
               $(this).val('');
               return false;
          }
       });
    })

    $(function() {
       var fillmethods = [
        'RIX SA6',
        'GRAV BLEND',
       ];
       $( "input[type=text][id$=fill-method]" ).autocomplete({
          source: fillmethods,
          minLength: 0
       });
    })

    $(function() {
       $("input[type=text][id$=fill-date]").datepicker({
           onSelect: function(dateText)
           { SetValue($(this).attr('id'), $(this).val(), productinfos); }, 
           dateFormat: "yy-mm-dd",
           maxDate: 2
       });
    })
   </SCRIPT>
   <TABLE>
    <TR>
     <TD><H1>Cylinder Fill</H1></TD>
    </TR>
    <TR>
     <TD>
      <TABLE border='1'>
       <TR>
        <TD>
         <INPUT type='button' value='Show' id='col_table_btn'>
         &nbsp;
         <FONT style='font-weight:bold'>Display columns</FONT>
        </TD>
       </TR>
       <TR>
        <TD>
         <TABLE cellspacing='1' cellpadding='1' id='col_table' style='display:none'>
          <TR>
           <TD valign='top'> 
            <INPUT type='checkbox' id='col_toggle_cylinder-id' checked>Cylinder ID<BR>
            <INPUT type='checkbox' id='col_toggle_cylinder-size' checked>Cylinder Size<BR>
            <INPUT type='checkbox' id='col_toggle_species-target-comments' checked>Species, Target, Comments<BR>
           </TD>
           <TD valign='top'>
            <INPUT type='checkbox' id='col_toggle_order-num' checked>Order Num<BR>
            <INPUT type='checkbox' id='col_toggle_primary-customer' checked>Primary Customer<BR>
            <INPUT type='checkbox' id='col_toggle_organization' checked>Organization<BR>
           </TD>
           <TD valign='top'>
            <INPUT type='checkbox' id='col_toggle_order-needs-fill' checked>Order Needs Fill<BR>
            <INPUT type='checkbox' id='col_toggle_fill-details' checked>Fill Details<BR>
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
      <TABLE border='1' cellpadding='5' cellspacing='5' id='mainTable' class='tablesorter'>
       <THEAD>
        <TH>Row #</TH>
        <TH id='header_cylinder-id'>Cylinder ID</TH>
        <TH id='header_cylinder-size'>Cylinder Size</TH>
        <TH id='header_species-target-comments'>Species, Target<BR>Comments</TH>
        <TH id='header_order-num'>Order Num</TH>
        <TH id='header_primary-customer'>Primary Customer</TH>
        <TH id='header_organization'>Organization</TH>
        <TH id='header_order-needs-fill'>Order Needs Fill</TH>
        <TH id='header_fill-details'>Fill Details</TH>
       </THEAD>
       <TBODY>
<?PHP

   if ( count($productinfos) == 0 )
   {
      echo "<TR>";
      echo " <TD colspan='5'>";
      echo "  No cylinders to be filled at this time.";
      echo " </TD>";
      echo "</TR>";
   }

   $productnum = 0;
   foreach ( $productinfos as $product_aarr )
   {
      echo "<TR>\n";
      echo " <TD valign='top' align='center'>\n";
      echo $productnum;
      echo " </TD>\n";
      echo " <TD id='".$productnum."_cylinder-id'>\n";
      if ( isset($product_aarr['db-cylinder-id']) &&
           $product_aarr['db-cylinder-id'] != '' )
      {
         echo $product_aarr['db-cylinder-id'];
         echo "<INPUT type='hidden' id='product".$productnum."_db-cylinder-id' name='product".$productnum."_db-cylinder-id' value='".$product_aarr['db-cylinder-id']."'>\n";
      }
      else
      {
         $value = isset($product_aarr['cylinder-id']) ? $product_aarr['cylinder-id'] : '';
         echo "<INPUT type='text' id='product".$productnum."_cylinder-id' name='product".$productnum."_cylinder-id' size='10' onKeyup='this.value = this.value.toUpperCase();' value='$value'>\n";
      }
      echo "     <div id='product".$productnum."_cylinder-comments' name='product".$productnum."_cylinder-comments'></div>\n";
      echo " </TD>\n";
      echo " <TD id='".$productnum."_cylinder-size'>\n";
      if ( isset($product_aarr['cylinder-size']) &&
           $product_aarr['cylinder-size'] != '' )
      { echo $product_aarr['cylinder-size']; }
      echo " </TD>\n";
      echo " <TD valign='top' align='left' id='".$productnum."_species-target-comments'>\n";

      if ( $product_aarr['comments'] != '' )
      {
         echo "<DIV>Product comments:</DIV>";
         echo "<DIV>";
         echo $product_aarr['comments'];
         echo "</DIV>";
         echo "<HR>";
      }
      if ( count($product_aarr['calrequests']) > 0 )
      {
         foreach ( $product_aarr['calrequests'] as $calrequest_aarr )
         {
            echo "<DIV>";
            echo $calrequest_aarr['abbr-HTML'].':'.htmlentities($calrequest_aarr['target-value'], ENT_QUOTES, 'UTF-8');
            echo "</DIV>";
            echo "<DIV style='white-space: nowrap;'>";
            echo htmlentities($calrequest_aarr['comments'], ENT_QUOTES, 'UTF-8');
            echo "</DIV>";
            echo "<HR>";
         }
      }
      else
      {
         # Handle the case of no calrequests
         echo "No analyzes";
      }
      echo " </TD>\n";
      echo " <TD id='".$productnum."_order-num'>\n";
      if ( isset($product_aarr['order-num']) &&
           $product_aarr['order-num'] != '' )
      { echo $product_aarr['order-num']; }
      echo " </TD>\n";
      echo " <TD  id='".$productnum."_primary-customer'>\n";
      if ( isset($product_aarr['order-primary-customer-email']) &&
           $product_aarr['order-primary-customer-email'] != '' )
      { echo $product_aarr['order-primary-customer-email']; }
      echo " </TD>\n";
      echo " <TD  id='".$productnum."_organization'>\n";
      if ( isset($product_aarr['order-organization']) &&
           $product_aarr['order-organization'] != '' )
      { echo $product_aarr['order-organization']; }
      echo " </TD>\n";
      echo " <TD  id='".$productnum."_order-needs-fill'>\n";
      echo $product_aarr['order-needs-filled'];
      echo " </TD>\n";
      echo " <TD  id='".$productnum."_fill-details'>\n";
      echo "  <TABLE cellspacing='1' cellpadding='1'>\n";
      echo "   <TR>\n";
      echo "    <TD>Fill Date</TD>\n";
      echo "    <TD>\n";
      $value = ( isset($product_aarr['fill-date']) ) ? $product_aarr['fill-date'] : '';
      echo "     <INPUT type='text' size='10' id='product".$productnum."_fill-date' name='product".$productnum."_fill-date' value='$value'>\n";
      echo "    </TD>\n";
      echo "   </TR>\n";
      echo "    <TD>Location</TD>\n";
      echo "    <TD>\n";

      echo "<SELECT id='product".$productnum."_fill-location-num' name='product".$productnum."_fill-location-num'>";

      $selected_location_num = ( isset($product_aarr['fill-location-num']) ) ? $product_aarr['fill-location-num'] : '3';

      foreach ( $location_objs as $location_obj )
      {
         $value = $location_obj->getNum();
         $name = $location_obj->getAbbreviation();

         $selected = ( $value == $selected_location_num ) ? 'SELECTED' : '';

         echo "<OPTION value='$value' $selected>$name</OPTION>";
      }

      echo "     </SELECT>";

      echo "<div class='ui-widget'>";
      echo "<img src='images/search-icon-active.png'>";
      echo "<input type='text' size='10' id='product".$productnum."_location-search' />";
      echo "</div>";

      echo "    </TD>\n";
      echo "   </TR>\n";
      echo "    <TD>Method</TD>\n";
      echo "    <TD>\n";
      $value = ( isset($product_aarr['fill-method']) ) ? $product_aarr['fill-method'] : '';
      echo "     <INPUT type='text' size='10' id='product".$productnum."_fill-method' name='product".$productnum."_fill-method' value='$value'>\n";
      echo "    </TD>\n";
      echo "   </TR>\n";
      echo "   </TR>\n";
      echo "    <TD>Comments</TD>\n";
      echo "    <TD>\n";
      $value = ( isset($product_aarr['fill-comments']) ) ? $product_aarr['fill-comments'] : '';
      echo "     <TEXTAREA id='product".$productnum."_fill-comments' name='product".$productnum."_fill-comments'>$value</TEXTAREA>\n";
      echo " </TD>\n";
      echo "    </TD>\n";
      echo "   </TR>\n";
      echo "   </TR>\n";
      echo "    <TD colspan='2'>\n";
      echo "     <FONT style='cursor: pointer; color:blue; text-decoration:underline;' onClick='$(document.body).scrollLeft($(\"#bottom\").offset().left).scrollTop($(\"#bottom\").offset().top);'>Go to bottom</FONT> to submit.\n";
      echo "    </TD>\n";
      echo "   </TR>\n";

      echo "  </TABLE>\n";
      echo " </TD>\n";

      $productnum++;
   }
?>
       </TBODY>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD>
      <A name='bottom' id='bottom'>
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
   $product_objects = DB_ProductManager::searchForFilling($input_database_object);

   $info = array();

   foreach ( $product_objects as $product_object )
   {
      $product_aarr = array();
      $product_aarr['num'] = $product_object->getNum();

      if ( is_object($product_object->getCylinder()) )
      {
         $product_aarr['db-cylinder-id'] = $product_object->getCylinder()->getID();
      }
      $product_aarr['cylinder-size'] = $product_object->getCylinderSize();
      $product_aarr['comments'] = $product_object->getComments();

      if ( is_object($product_object->getOrder()) )
      {
         $product_aarr['order-num'] = $product_object->getOrder()->getNum();
         $product_aarr['order-organization'] = $product_object->getOrder()->getOrganization();
         $product_aarr['order-needs-filled'] = $product_object->getOrder()->countProductsNeedFill();

         if ( is_object($product_object->getOrder()->getPrimaryCustomer()) )
         {
            $product_aarr['order-primary-customer-email'] = $product_object->getOrder()->getPrimaryCustomer()->getEmail();
         }
      }

      $product_aarr['calrequests'] = array();

      $calrequest_objects = DB_CalRequestManager::searchByProduct($input_database_object, $product_object);

      foreach ( $calrequest_objects as $calrequest_object )
      {
         $calrequest_aarr['abbr'] = $calrequest_object->getCalService()->getAbbreviation();
         $calrequest_aarr['abbr-HTML'] = $calrequest_object->getCalService()->getAbbreviationHTML();
         $calrequest_aarr['target-value'] = $calrequest_object->getTargetValue();

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

            #
            # If any of the inputs for a row are not empty then
            # try to process the row.
            #  - Ignore fill location as we are defaulting the location to
            #     NWR now.
            #
            if ( ( isset($productinfo['cylinder-id']) &&
                 ! isBlank($productinfo['cylinder-id']) )
                 ||
                 ( isset($productinfo['fill-date']) &&
                 ! isBlank($productinfo['fill-date']) ) )
            {
               #
               # Check required fields
               #
               if ( ! isset($productinfo['fill-date']) ||
                    isBlank($productinfo['fill-date']) )
               { throw new Exception ("Fill date must be provided on row #".$productnum); }
          
               if ( ! isset($productinfo['fill-location-num']) ||
                    isBlank($productinfo['fill-location-num']) )
               { throw new Exception ("Fill location must be provided on row #".$productnum); }
          
               if ( ! isset($productinfo['fill-method']) ||
                    isBlank($productinfo['fill-method']) )
               { throw new Exception ("Fill method must be provided on row #".$productnum); }
          
               # Make sure we have a cylinder ID
               if ( isset($productinfo['db-cylinder-id']) &&
                    $productinfo['db-cylinder-id'] != '' )
               { $cylinder_id = $productinfo['db-cylinder-id']; }
               elseif ( isset($productinfo['cylinder-id']) &&
                        $productinfo['cylinder-id'] != '' )
               { $cylinder_id = $productinfo['cylinder-id']; }
               else
               { throw new Exception ("Cylinder ID must be provided on row #".$productnum); }
               

               $cylinder_object = new DB_Cylinder($input_database_object, $cylinder_id, 'id');

               if ( ! is_object($cylinder_object) )
               { throw new Exception ("Invalid cylinder-id provided on row #".$productnum.". <A href='cylinder_edit.php?id=".urlencode($cylinder_id)."&action=add'><INPUT type='button' value='Add Cylinder'></A>"); }

               $location_object = new DB_Location($input_database_object, $productinfo['fill-location-num']); 

               # Set the cylinder to this location
               $cylinder_object->ship($location_object);

               if ( isset($productinfo['fill-comments']) &&
                    ! isBlank($productinfo['fill-comments']) )
               {
                  $cylinder_object->fill($productinfo['fill-date'], $location_object->getAbbreviation(), $productinfo['fill-method'], $productinfo['fill-comments']);
               }
               else
               {
                  $cylinder_object->fill($productinfo['fill-date'], $location_object->getAbbreviation(), $productinfo['fill-method']);
               }

               if ( $save )
               {
                  #echo "<PRE>";
                  #print_r($cylinder_object);
                  #echo "</PRE>";

                  $cylinder_object->saveToDB($user_obj);
               }

               # Update product information
               $product_object->setCylinder($cylinder_object);

               if ( $cylinder_object->getLastFillCodeFromDB() != '' )
               {
                  # Get the Last Fill Code as we just added a new one with fill()
                  $product_object->setFillCode($cylinder_object->getLastFillCodeFromDB());
               }

               $product_object->preSaveToDB();

               if ( $save )
               {
                  #echo "<PRE>";
                  #print_r($product_object);
                  #echo "</PRE>";
   
                  $product_object->saveToDB($user_obj);
               }
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
