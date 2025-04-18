<?PHP

require_once("CCGDB.php");
require_once("DB_CalRequestManager.php");
require_once("DB_CalServiceManager.php");
require_once("DB_CylinderManager.php");
require_once("Log.php");
require_once("/var/www/html/inc/ccgglib_inc.php");
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
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <SCRIPT language='JavaScript' src='/inc/php_serialize.js'></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/validator.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="product_extra_edit.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>
<?PHP

CreateMenu($database_object, $user_obj);

$task = isset($_POST['task']) ? $_POST['task'] : '';
$productinfostr = ( isset($_POST['productinfostr'])) ? $_POST['productinfostr'] : '';
$product_num = isset($_GET['num']) ? $_GET['num'] : '';

$productinfo = mb_unserialize(urldecode($productinfostr));

$cylinder_size_aarr = DB_CylinderManager::getCylinderSizes($database_object);
natcasesort($cylinder_size_aarr);
#echo "<PRE>";
#print_r($cylinder_size_aarr);
#echo "</PRE>";

$calservice_objects = DB_CalServiceManager::getAnalysisCalServices($database_object);
#echo "<PRE>";
#print_r($calservice_objects);
#echo "</PRE>";

$analysis_type_aarr = DB_CalRequestManager::getAnalysisTypes($database_object);

if ( ! is_array($productinfo) || $task === '' )
{
   if ( ValidInt($product_num) )
   {
      $productinfo = LoadObject($database_object, $product_num);
   }
   else
   {
      $productinfo = array();

      $task = 'product_add';
   }
}

#echo "<PRE>";
#print_r($productinfo);
#echo "</PRE>";

$errors = array();
if ( $task === 'submit' )
{
   #echo "<PRE>";
   #print_r($productinfo);
   #echo "</PRE>";

   # First check to see if we get any errors
   list($errors, $product_num) = CreateObject($database_object, $productinfo, $task);

   # If there are no errors, do the same thing but save the data
   if ( count($errors) == 0 )
   {
      list($errors, $product_num) = CreateObject($database_object, $productinfo, $task, TRUE);

      if ( count($errors) == 0 )
      {
         echo "Product extra created successfully.";
         echo "<SCRIPT>";
         echo "window.location.replace('product_extra_edit.php?num=$product_num')";
         echo "</SCRIPT>";
         exit;
      }
   }
}
elseif ( $task === 'update' )
{
   #echo "<PRE>";
   #print_r($productinfo);
   #echo "</PRE>";

   # First check to see if we get any errors
   $errors = SaveObject($database_object, $productinfo, $task);

   # If there are no errors, do the same thing but save the data
   if ( count($errors) == 0 )
   {
      $errors = SaveObject($database_object, $productinfo, $task, TRUE);

      if ( count($errors) == 0 )
      {
         echo "Product extra updated successfully.";
         echo "<BR>";
         $productinfo = LoadObject($database_object, $product_num);
      }
   }
}
elseif ( $task === 'delete' )
{
   #echo "<PRE>";
   #print_r($productinfo);
   #echo "</PRE>";

   # First check to see if we get any errors
   $errors = DeleteObject($database_object, $productinfo, $task);

   # If there are no errors, do the same thing but save the data
   if ( count($errors) == 0 )
   {
      $errors = DeleteObject($database_object, $productinfo, $task, TRUE);

      if ( count($errors) == 0 )
      {
         echo "Product extra deleted successfully.";
         echo "<BR>";
         echo "<A href='product_extras.php'><INPUT type='button' value='Product Extras'></A>";
         exit;
      }
   }
}
elseif ( $task === 'product_add' )
{
   #
   # Add a new product through PHP because I am aware of how many
   #   calservices there should be. Also, when the page is first loaded with
   #   a new order this function is needed as well.
   #
   $tmparr = array();

   foreach ( $calservice_objects as $calservice_object )
   {
      $tmpaarr2 = array();
      $tmpaarr2['calservice-abbr'] = $calservice_object->getAbbreviation();
      $tmpaarr2['calservice-abbr-html'] = $calservice_object->getAbbreviationHTML();
      array_push($tmparr, $tmpaarr2);
   }

   $productinfo['calrequests'] = $tmparr;

   $task = '';
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
   <SCRIPT>
    $(document).ready(function()
    {
      $("input[type=text], input[type=hidden], select, textarea").blur(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());
            SetValue($(this).attr('id'), $(this).val(), productinfo);
         }
      );

      $("select[id$='_analysis-type']").change(
         function ()
         {
           var myCylinderID = $("#cylinder-id");

           // Check that calservice is enabled
           calservice_checkbox = $(this).attr('id').replace('_analysis-type', '_requested');
           var myCalServiceCheckBox = $('#'+calservice_checkbox);

           if ( myCalServiceCheckBox.val() != undefined &&
                myCalServiceCheckBox.prop("checked") != true )
           {
              $(this).val('1');
              return false;
           }

           // This should only be used for co2, ch4, co, n2o, sf6, h2
           //  as the other calservices do not have data in the database
           calservice_abbr = $(this).attr('id').replace('_analysis-type', '_calservice-abbr');
           var myCalServiceAbbr = $('#'+calservice_abbr);
           if ( myCalServiceAbbr.val() != 'co2' &&
                myCalServiceAbbr.val() != 'ch4' &&
                myCalServiceAbbr.val() != 'co' &&
                myCalServiceAbbr.val() != 'n2o' &&
                myCalServiceAbbr.val() != 'sf6' &&
                myCalServiceAbbr.val() != 'h2' )
           { return false; }

           if ( $(this).val() != '1' )
           {
              var mySelectMenu = $(this);
              target_value = $(this).attr('id').replace('_analysis-type', '_target-value');
              var myTargetValue = $('#'+target_value);

              // Call cylinder_get-last-analysis to retrieve
              // last calibration

              //alert(myCylinderID.val()+' '+myCalServiceAbbr.val());

              $.ajax({
                 url: 'cylinder_get-last-analysis.php',
                 type: 'get',
                 data: { id: myCylinderID.val(),
                         calservice: myCalServiceAbbr.val()  },
                 success:function(data)
                 {
                    if ( data.match(/Error:/) )
                    {
                       mySelectMenu.val("1").change();
                       alert(data);
                    }
                    else
                    {
                       if ( ValidFloat(data.trim()) )
                       {
                          if ( myTargetValue.val() != '' )
                          {
                             if ( myTargetValue.val() != data.trim() &&
                                  confirm("Overwrite current target value?") )
                             { myTargetValue.click().val(data.trim()).blur(); }
                             else
                             { myTargetValue.click().blur(); }
                          }
                          else
                          { myTargetValue.click().val(data.trim()).blur(); }
                       }
                    }
                 } 
              });
           }
         }
      );

      $("#cylinder-id").change(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());

            // if the cylinder ID is changed, first clear all
            //  the analysis type selects
            $("select[id$='_analysis-type']").each(
               function ()
               {
                  $(this).val('1').blur();
               }
            );

            // Then update the Details section
            UpdateDetails();

            // And update the Analysis Type pulldowns
            UpdateAnalysisType();
            
            var cid=$(this).val();
            
            if (cid=="") {//Clear the comment div when id is erased.
              $("#cylinder-comments").html("");
            }else{
               //Validate the id and retrieve any cylinder comments.   
               $.ajax({
                      url: 'cylinder_get_info.php',
                      type: 'get',
                      data: { id: cid,
                              data_element: 'comments'  },
                      success:function(data){
                        //Out put whatever was sent back (error or success).
                            $("#cylinder-comments").html(data);
                      } 
                });
            }
         }
      );

      $("input[type=checkbox][id$=_requested], select[id$='_analysis-type']").change(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());

            UpdateDetails();
         }
      );
    });

    $(window).load(function()
    {
      $("#cylinder-id").each(
         function()
         {
            //alert($(this).attr('id')+' '+$(this).val());

            UpdateAnalysisType();
         }
      );

      $("input[type=checkbox], input[type=text], select, textarea").each(
         function ()
         {
            $(this).trigger('change');
            $(this).trigger('blur');
         }
      );

      // Process the radio buttons after the input type=text boxes because
      //  the radio buttons may affect the value of the text boxes
      $('input[type=radio]').each(
         function ()
         {
            // Only fire if the option is selected
            if ( $(this).prop("checked") == true )
            {
               $(this).trigger('click') ;
            }
         }
      );
    });

    // This exists in the PHP because I need values from PHP variables
    function UpdateDetails()
    {
       var myCylinderID = $("#cylinder-id");

       var allowrefillflag = 1;
       $("select[id$='_analysis-type']").each(
          function ()
          {
             // alert($(this).val());
             if ( $(this).val() != '1' &&
                  $(this).prop('disabled') != true )
             {
                allowrefillflag = 0;
                return false;
             }
          }
       );

       var mySizeSelect = $("#cylinder-size");
       var myStatusSelect = $("#checkin-status");

       if ( myCylinderID.val() != '' )
       { 
          var mySizeOptions = {
              0 : 'From Cylinder ID',
          };
          mySizeSelect.empty();
          $.each(mySizeOptions, function(val, text) {
              mySizeSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });

          if ( allowrefillflag == 1 )
          {
             var myStatusOptions = {
                 '3' : 'Ready for Analysis',
                 '1' : 'Ready for Filling',
             };
          }
          else
          {
             var myStatusOptions = {
                 '3' : 'Ready for Analysis',
             };
          }
          myStatusSelect.empty();
          $.each(myStatusOptions, function(val, text) {
              myStatusSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });
       } 
       else
       {
          var mySizeOptions = {
<?PHP
          $tmparr = array();
          foreach ( $cylinder_size_aarr as $value=>$name )
          {
             array_unshift($tmparr, "$value : '$name'");
          }
          echo join(',', $tmparr);
?>
          };
          mySizeSelect.empty();
          $.each(mySizeOptions, function(val, text) {
              mySizeSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });

          var myStatusOptions = {
              '3' : 'Default',
          };
          myStatusSelect.empty();
          $.each(myStatusOptions, function(val, text) {
              myStatusSelect.append(
                  $('<option></option>').val(val).html(text)
              );
          });
       } 

       mySizeSelect.val(productinfo['cylinder-size']).blur(); 
       myStatusSelect.val(productinfo['checkin-status']).blur();

       return false;
    }

    // This exists in the PHP because I need values from PHP variables
    function UpdateAnalysisType()
    {
       var myCylinderID = $("#cylinder-id");

       var myAnalysisTypeOptions;

       if ( myCylinderID.val() != '' )
       { 
          myAnalysisTypeOptions = {
<?PHP
          $tmparr = array();
          foreach ( $analysis_type_aarr as $value=>$name )
          {
             array_push($tmparr, "$value : '$name'");
          }
          echo join(',', $tmparr);
?>
          };
       } 
       else
       {
          myAnalysisTypeOptions = {
<?PHP
             $keys = array_keys($analysis_type_aarr);

             echo $keys[0]." : '".$analysis_type_aarr[$keys[0]]."'";
?>
          };
       } 
       
       var disabled;
       $("select[id$='_analysis-type']").each(
          function ()
          {
             //alert($(this).attr("id"));
             myAnalysisTypeSelect = $(this);

             disabled = 0;

             if ( myAnalysisTypeSelect.prop('disabled') == 'true' )
             { disabled = 1; }

             myAnalysisTypeSelect.empty();
             $.each(myAnalysisTypeOptions, function(val, text) {
                 myAnalysisTypeSelect.append(
                     $('<option></option>').val(val).html(text)
                 );
             });

             if ( disabled == 1 )
             { myAnalysisTypeSelect.prop('disabled', true); }
          }
       );

       return false;
    }

   </SCRIPT>
   <INPUT type='hidden' name='task' value=''>

<?PHP
   echo "<INPUT type='hidden' name='productinfostr' value='$productinfostr'>";

   $namearr = array();
   SendtoJS("productinfo",$productinfo, $namearr);
?>



   <TABLE border='1' cellspacing='3' cellpadding='3'>
    <TR>
     <TD>
<?PHP

if ( ValidInt($product_num) )
{
   echo "<H1>Edit Product Extra</H1>";
}
else
{
   echo "<H1>Add Product Extra</H1>";
}

?>
     </TD>
    </TR>
    <TR>
     <TD>
      <TABLE id='products' border='1' cellspacing='5' cellpadding='5'>
       <TBODY>
        <TR>
         <TH>Cylinder ID</TH>
         <TH>Analyzes</TH>
         <TH>Details</TH>
         <TD></TD>
        </TR>
<?PHP

      echo "<TR>";
      echo " <TD>";
      $value = isset($productinfo['cylinder-id']) ? $productinfo['cylinder-id'] : '';
      if ( isset($productinfo['in-processing']) &&
           $productinfo['in-processing'] )
      {
         echo "$value";
         echo "<INPUT type='hidden' id='cylinder-id' name='cylinder-id' value='$value'>";
      }
      else
      {
         echo "  <INPUT type='text' id='cylinder-id' name='cylinder-id' size='15' maxlength='15' onKeyup='this.value = this.value.toUpperCase();' value='$value'>";
         echo "  <br><div id='cylinder-comments' name='cylinder-comments'></div>";
      
      }
      echo " </TD>";
      echo " <TD>";
      echo "  <TABLE border='1' cellspacing='2' cellpadding='2'>";
      echo "   <TR>";
      echo "    <TH></TH>";
      echo "    <TH>Species</TH>";
      echo "    <TH>Target</TH>";
      echo "    <TH>Analysis Type</TH>";
      echo "    <TH>Comments</TH>";
      echo "    <TH>Status</TH>";
      echo "   </TR>";

      $calrequestnum = 0;
      foreach ( $productinfo['calrequests'] as $calrequest_aarr )
      {
         echo "<TR>";
         echo " <TD>";
         $requested = ( isset($calrequest_aarr['requested']) && $calrequest_aarr['requested'] ) ? TRUE : FALSE;
         $checked = ( isset($calrequest_aarr['requested']) && $calrequest_aarr['requested'] ) ? 'CHECKED' : '';

         if ( isset($productinfo['in-processing']) &&
              $productinfo['in-processing'] &&
              $requested)
         { echo "X"; }
         else
         {
            echo "  <INPUT type='checkbox' id='calrequest".$calrequestnum."_requested' name='calrequest".$calrequestnum."_requested' onChange='CalServiceSelect(this)' $checked>";
         }

         echo " </TD>";
         echo " <TD>";
         echo $calrequest_aarr['calservice-abbr-html'];
         echo "<INPUT type='hidden' id='calrequest".$calrequestnum."_calservice-abbr' name='calrequest".$calrequestnum."_calservice-abbr' value='".$calrequest_aarr['calservice-abbr']."'>";
         echo " </TD>";
         echo " <TD>";
         echo "  <TABLE>";
         echo "   <TR>";
         echo "    <TD>";
         $value = ( isset($calrequest_aarr['target-value']) && isset($calrequest_aarr['requested']) && $calrequest_aarr['requested']) ? $calrequest_aarr['target-value'] : 'ambient';
         $option1_checked = ( $value == 'ambient' ) ? 'CHECKED' : '';
         echo "     <INPUT type='radio' id='calrequest".$calrequestnum."_target-value-option1' name='calrequest".$calrequestnum."_target-value-options' onClick='SetValue(\"calrequest".$calrequestnum."_target-value\", \"ambient\", productinfo);' $option1_checked>";
         echo "    </TD>";
         echo "    <TD>";
         echo " Ambient";
         echo "    </TD>";
         echo "   </TR>";
         echo "   <TR>";
         echo "    <TD>";
         $option2_checked = ( $value != 'ambient' ) ? 'CHECKED' : '';
         echo "     <INPUT type='radio' id='calrequest".$calrequestnum."_target-value-option2' name='calrequest".$calrequestnum."_target-value-options' onClick='\$(\"#calrequest".$calrequestnum."_target-value\").blur();' $option2_checked>";
         echo "    </TD>";
         echo "    <TD>";
         $inputbox_value = ( $value != 'ambient' ) ? $value : '';
         echo "     <INPUT type='text' id='calrequest".$calrequestnum."_target-value' name='calrequest".$calrequestnum."_target-value' size='10' value='$inputbox_value' onClick='\$(\"#calrequest".$calrequestnum."_target-value-option2\").prop(\"checked\", true);'>";
         echo "    </TD>";
         echo "   </TR>";
         echo "  </TABLE>";
         echo " </TD>";
         echo " <TD>";
         $input_value = ( isset($calrequest_aarr['analysis-type']) ) ? $calrequest_aarr['analysis-type'] : '';
         echo "  <SELECT id='calrequest".$calrequestnum."_analysis-type' name='calrequest".$calrequestnum."_analysis-type'>";
         echo "  </SELECT>";
         echo " </TD>";
         echo " <TD>";
         $input_value = ( isset($calrequest_aarr['comments']) ) ? $calrequest_aarr['comments'] : '';
         echo "  <INPUT type='text' id='calrequest".$calrequestnum."_comments' name='calrequest".$calrequestnum."_comments' size='15' value='".htmlentities($input_value, ENT_QUOTES, 'UTF-8')."'>";
         echo " </TD>";
         echo " <TD>";
         echo "  <TABLE>";
         echo "   <TR>";
         $value = isset($calrequest_aarr['status']) ? $calrequest_aarr['status'] : '';
         echo "    <TD>$value</TD>";
         $value = isset($calrequest_aarr['status-color']) ? $calrequest_aarr['status-color'] : 'transparent';
         echo "    <TD style='background-color: $value'>&nbsp;&nbsp;&nbsp;</TD>";
         echo "   </TR>";
         echo "  </TABLE>";
         echo " </TD>";
         echo "</TR>";

         $calrequestnum++;
      }
?>
         </TABLE>
        </TD>
        <TD>
         <TABLE>
<?PHP
if ( isset($productinfo['in-processing']) &&
     $productinfo['in-processing'] )
{
}
else
{
?>
          <TR>
           <TH>Cylinder Size</TH>
           <TD>
            <SELECT id='cylinder-size' name='cylinder-size'>
            </SELECT>
           </TD>
          </TR>
          <TR>
           <TH>Check-In Status</TH>
           <TD>
            <SELECT id='checkin-status' name='checkin-status'>
            </SELECT>
           </TD>
          </TR>
<?PHP
}
?>
          <TR>
           <TH>Comments</TH>
          </TR>
          <TR>
           <TD colspan='2'>
<?PHP
            echo "<TEXTAREA id='comments' name='comments'>";
            $value = isset($productinfo['comments']) ? $productinfo['comments'] : '';
            echo $value;
            echo "</TEXTAREA>";
?>
           </TD>
          </TR>
         </TABLE>
        </TD>
       </TR>
       </TBODY>
      </TABLE>
     </TD>
    </TR>
    <TR>
     <TD align='center'>
      <TABLE cellspacing='10' cellpadding='10'>
       <TR>
        <TD>
<?PHP
   if ( ValidInt($product_num) )
   {
      echo " <INPUT type='button' value='Update' onClick='SubmitCB(\"update\")'>";
      echo "</TD>";
      echo "<TD>";
      echo " <INPUT type='button' value='Delete' onClick='SubmitCB(\"delete\")'>";
   }
   else
   {
      echo " <INPUT type='button' value='Submit' onClick='SubmitCB(\"submit\")'>";
   }
?>
        </TD>
        <TD>
         <A href='product_extras.php'><INPUT type='button' value='Product Extras'></A>
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

function LoadObject(DB $input_database_object, $product_num)
{
   $calservice_objects = DB_CalServiceManager::getAnalysisCalServices($input_database_object);

   $product_object = new DB_Product($input_database_object, $product_num);

   $info = array();
   $info['product-num'] = $product_num;

   if ( is_object($product_object->getCylinder()) )
   {
      $info['cylinder-id'] = $product_object->getCylinder()->getID();
      $info['cylinder-size'] = '0';
      $info['checkin-status'] = $product_object->getCylinder()->getCheckInStatus('num'); 
   }
   else
   {
      $info['cylinder-id'] = '';
      $info['cylinder-size'] = $product_object->getCylinderSize('num');
      $info['checkin-status'] = '3'; 
   }
   $info['is-active'] = ( $product_object->isActive() ) ? '1' : '0';
   $info['in-processing'] = ( $product_object->inProcessing() ) ? '1' : '0';
   $info['comments'] = $product_object->getComments();

   $info['calrequests'] = array();

   $product_calrequest_objects = DB_CalRequestManager::searchByProduct($input_database_object, $product_object);

   foreach ( $calservice_objects as $calservice_object )
   {
      $calrequest_aarr = array();

      $calrequest_aarr['requested'] = false;
      $calrequest_aarr['calservice-abbr'] = $calservice_object->getAbbreviation();
      $calrequest_aarr['calservice-abbr-html'] = $calservice_object->getAbbreviationHTML();
      foreach ( $product_calrequest_objects as $product_calrequest_object )
      {
         if ( $product_calrequest_object->getCalService()->equals($calservice_object) )
         {
            $calrequest_aarr['requested'] = true;
            $calrequest_aarr['calrequest-num'] = $product_calrequest_object->getNum();
            $calrequest_aarr['target-value'] = $product_calrequest_object->getTargetValue();
            $calrequest_aarr['analysis-type'] = $product_calrequest_object->getAnalysisType('num');
            $calrequest_aarr['comments'] = $product_calrequest_object->getComments();
            $calrequest_aarr['status'] = $product_calrequest_object->getStatus();
            $calrequest_aarr['status-color'] = $product_calrequest_object->getStatusColorHTML();
            break;
         }
      }

      array_push($info['calrequests'], $calrequest_aarr);
   }   

   return $info;
}

function CreateObject(DB $input_database_object, $info, $task='submit', $save=FALSE)
{
   $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

   #echo "<PRE>";
   $errors = array();
   try
   {
      $calrequest_objects = array();
      try
      {
         if ( isset($info['cylinder-id']) && $info['cylinder-id'] != '' )
         {
            $cylinder_object = new DB_Cylinder($input_database_object, $info['cylinder-id'], 'id');

            $product_object = new DB_Product($input_database_object, '', $cylinder_object->getSize());
            $product_object->setCylinder($cylinder_object);
            $product_object->getCylinder()->setCheckInStatus($info['checkin-status']);
         }
         else
         {
            $product_object = new DB_Product($input_database_object, '', $info['cylinder-size']);
         }
         $product_object->setComments($info['comments']);

         $product_object->process();

         $product_object->preSaveToDB();

         if ( $save )
         {
            $product_object->saveToDB($user_obj);
         }

         #print_r($product_object);

         foreach ( $info['calrequests'] as $calrequest_aarr )
         {
            try
            {
               if ( ! isset($calrequest_aarr['requested']) ||
                    $calrequest_aarr['requested'] != true )
               { continue; }

               $calservice_object = new DB_CalService($input_database_object, $calrequest_aarr['calservice-abbr']);
               $calrequest_object = new DB_CalRequest($input_database_object, $product_object, $calservice_object, $calrequest_aarr['target-value'], $calrequest_aarr['analysis-type']);

               if ( isset($calrequest_aarr['comments']) )
               { $calrequest_object->setComments($calrequest_aarr['comments']); }

               $calrequest_object->process();

               $calrequest_object->preSaveToDB();

               if ( $save )
               {
                  $calrequest_object->saveToDB($user_obj);
               }
               array_push($calrequest_objects, $calrequest_object);

               #echo "<PRE>";
               #print_r($calservice_object);
               #echo "</PRE>";

               #echo "<PRE>";
               #print_r($calrequest_object);
               #echo "</PRE>";
            }
            catch ( Exception $e )
            { array_push($errors, $e); }
         }
      }
      catch ( Exception $e )
      { array_push($errors, $e); }

      #echo "<PRE>";
      #print_r($product_object);
      #echo "</PRE>";
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   #echo "</PRE>";
   return (array ($errors, $product_object->getNum()) );
}

function SaveObject(DB $input_database_object, $info, $task='submit', $save=FALSE)
{
   $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

   #echo "<PRE>";
   $errors = array();
   try
   {
      $calrequest_objects = array();

      if ( isset($info['product-num']) )
      {
         $product_object = new DB_Product($input_database_object, $info['product-num']);
      }
      else
      { throw new Exception ("Must provide valid product number"); }

      try
      {
         if ( isset($info['cylinder-id']) && $info['cylinder-id'] != '' )
         {
            $cylinder_object = new DB_Cylinder($input_database_object, $info['cylinder-id'], 'id');

            $product_object->setCylinder($cylinder_object);
            $product_object->getCylinder()->setCheckInStatus($info['checkin-status']);
         }
         else
         {
            $product_object->setCylinderSize($info['cylinder-size'], 'num');
         }
         $product_object->setComments($info['comments']);

         $product_object->process();

         $product_object->preSaveToDB();

         if ( $save )
         {
            $product_object->saveToDB($user_obj);
         }

         #print_r($product_object);

         foreach ( $info['calrequests'] as $calrequest_aarr )
         {
            try
            {
               if ( isset($calrequest_aarr['requested']) &&
                    $calrequest_aarr['requested'] == true )
               {
                  if ( isset($calrequest_aarr['calrequest-num']) &&
                       ValidInt($calrequest_aarr['calrequest-num']) )
                  {
                     # UPDATE

                     $calrequest_object = new DB_CalRequest($input_database_object, $calrequest_aarr['calrequest-num']);
                     $calrequest_object->setTargetValue($calrequest_aarr['target-value']);
                     $calrequest_object->setAnalysisType($calrequest_aarr['analysis-type'], 'num');
                     #echo "UPDATE<BR>";
                     #print_r($calrequest_object);
                  }
                  else
                  {
                     # INSERT
                     $calservice_object = new DB_CalService($input_database_object, $calrequest_aarr['calservice-abbr']);
                     $calrequest_object = new DB_CalRequest($input_database_object, $product_object, $calservice_object, $calrequest_aarr['target-value'], $calrequest_aarr['analysis-type']);

                     #echo "INSERT<BR>";
                     #print_r($calrequest_object);
                  }

                  if ( isset($calrequest_aarr['comments']) )
                  { $calrequest_object->setComments($calrequest_aarr['comments']); }

                  $calrequest_object->process();

                  $calrequest_object->preSaveToDB();

                  #echo "<PRE>";
                  #print_r($calrequest_object);
                  #echo "</PRE>";

                  if ( $save )
                  { $calrequest_object->saveToDB($user_obj); }

               }
               else
               {
                  if ( isset($calrequest_aarr['calrequest-num']) &&
                       ValidInt($calrequest_aarr['calrequest-num']) )
                  {
                     # DELETE
                     $calrequest_object = new DB_CalRequest($input_database_object, $calrequest_aarr['calrequest-num']);
                     #echo "DELETE<BR>";
                     #print_r($calrequest_object);

                     if ( $save )
                     { $calrequest_object->deleteFromDB($user_obj); }
                  }
               }
            }
            catch ( Exception $e )
            { array_push($errors, $e); }
         }
      }
      catch ( Exception $e )
      { array_push($errors, $e); }

      #echo "<PRE>";
      #print_r($product_object);
      #echo "</PRE>";
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   #echo "</PRE>";
   return ($errors);
}

function DeleteObject($input_database_object, $info, $task='submit', $save=FALSE)
{
   $user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';

   #echo "<PRE>";
   $errors = array();
   try
   {
      $calrequest_objects = array();

      if ( isset($info['product-num']) )
      {
         $product_object = new DB_Product($input_database_object, $info['product-num']);
      }
      else
      { throw new Exception ("Must provide valid product number"); }

      try
      {
         if ( $save )
         {
            $product_object->deleteFromDB($user_obj);
         }
      }
      catch ( Exception $e )
      { array_push($errors, $e); }

      #echo "<PRE>";
      #print_r($product_object);
      #echo "</PRE>";
   }
   catch ( Exception $e )
   { array_push($errors, $e); }

   #echo "</PRE>";
   return ($errors);
}

?>
