<?PHP

require_once "CCGDB.php";
require_once "DB_CalRequestManager.php";
require_once "DB_CalServiceManager.php";
require_once "DB_UserManager.php";
require_once "utils.php";
require_once "menu_utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);

$calservice_num = isset($_GET['cs_num']) ? $_GET['cs_num'] : '';
$showresults = isset($_GET['showresults']) ? $_GET['showresults'] : '1';
$input_data = isset( $_POST['input_data'] ) ? $_POST['input_data'] : '';

$calservice_objects = DB_CalServiceManager::searchByUser($database_object, $user_obj);

$allowed = 0;

foreach ( $calservice_objects as $calservice_object )
{
   if ( $calservice_object->getNum() == $calservice_num )
   { $allowed = 1; }
}

if ( ! $allowed )
{
   print "You do not have permission to view this information.";
   exit;
}

$errors = array();
if ( $input_data != '' )
{
   $input_data_aarr = @unserialize(urldecode($input_data));

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

#echo "<PRE>";
#print_r($input_data_aarr);
#echo "</PRE>";

if ( isset($input_data_aarr['task']) &&
     $input_data_aarr['task'] === 'complete' )
{
   $keys = array_keys($input_data_aarr);

   foreach ( $keys as $key )
   {
      # Find the entries that are calrequests
      if ( preg_match("/^[0-9]+$/", $key) )
      {
         $calrequest_num = $key;
         $calrequest_aarr = $input_data_aarr[$calrequest_num];

         # Skip this calrequest if either of the values are NULL
         #  which happens if a user selects Analysis Complete and
         #  then unselects it
         if ( $calrequest_aarr['analysis-value'] == 'NULL' ||
              $calrequest_aarr['analysis-repeatability'] == 'NULL' )
         { continue; }

         try
         {
            $calrequest_obj = new DB_CalRequest($database_object, $calrequest_num);

            $calrequest_obj->analysisComplete($user_obj, $calrequest_aarr['analysis-value'], $calrequest_aarr['analysis-repeatability'], join("\n", $calrequest_aarr['analyzes']));

            #echo "<PRE>";
            #print_r($calrequest_obj);
            #echo "</PRE>";
            $calrequest_obj->saveToDB($user_obj);

            $tmpaarr = array();
            $tmpaarr['calrequest_num'] = $calrequest_num;
            $tmpaarr['calrequest_analysis-value'] = $calrequest_aarr['analysis-value'];
            $tmpaarr['calrequest_analysis-repeatability'] = $calrequest_aarr['analysis-repeatability'];
            $tmpaarr['calrequest_analysis-reference-scale'] = $calrequest_obj->getAnalysisReferenceScale();
            $tmpaarr['calrequest_analysis-submit-datetime'] = $calrequest_obj->getAnalysisSubmitDatetime();
            if ( $calrequest_obj->getAnalysisCalibrationsSelected() != '' )
            { $tmpaarr['calrequest_analysis-calibrations-selected'] = urlencode($calrequest_obj->getAnalysisCalibrationsSelected()); }
            #print serialize($tmpaarr);
            Log::update($user_obj->getUsername(), '(ANALYSIS COMPLETE) '.serialize($tmpaarr));
         }
         catch(Exception $e)
         { array_push($errors, $e); }
      }
   }
   
   unset($input_data_aarr);
}

try
{
   $calservice_object = new DB_CalService($database_object, $calservice_num, 'num');

   $calrequest_objects = DB_CalRequestManager::searchForAnalysis($database_object);

   $final_calrequest_objects = array();
   foreach ( $calrequest_objects as $calrequest_object )
   {
      if ( $calservice_object->matches($calrequest_object->getCalService()) )
      { array_push($final_calrequest_objects, $calrequest_object); }
   }

   $calrequest_objects = $final_calrequest_objects;
}
catch ( Exception $e )
{
   echo $e->getMessage();
   exit;
}


?>

<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/jquery-ui/jquery-ui.css">
  <meta http-equiv="Content-type" content="text/html;charset=UTF-8">
  <meta charset="UTF-8">
  <SCRIPT language='JavaScript' src="/inc/jquery-1.9.1.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/jquery-ui-1.10.2.js"></SCRIPT>
  <LINK rel="stylesheet" type="text/css" href="/inc/jquery-themes/tablesorter-blue/style.css">
  <LINK rel="stylesheet" type="text/css" href="desktop.css">
  <SCRIPT language='JavaScript' src="/inc/jquery-tablesorter-pager.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="/inc/php_serialize.js"></SCRIPT>
  <SCRIPT language='JavaScript' src="todo_list.js?randnum=<?PHP echo time(); ?>"></SCRIPT>
 </HEAD>
 <BODY>
  <SCRIPT>
    $(document).ready(function() 
    { 
        // Please see http://tablesorter.com/docs/example-options-headers.html
        $("#mainTable").tablesorter({ 
            // pass the headers argument and assing a object 
            headers: { 
                // assign the ninth column (we start counting zero) 
                11: { 
                    // disable it by setting the property sorter to false 
                    sorter: false 
                } 
            },  
        });

        $("font[id$='analysis-complete-box']").click ( function()
        {
           var idfields = $(this).attr('id').split('_');
           analysis_complete_chkbx = idfields[0]+"_analysis-complete";

           $("#"+analysis_complete_chkbx).trigger("click"); 
        });

        $("input[type=checkbox][id$='analysis-complete']").click ( function()
        {
           var idfields = $(this).attr('id').split('_');

           font_box = $(this).attr('id')+'-box';
           analysis_value_txtbx = idfields[0]+"_analysis-value";
           analysis_repeatability_txtbx = idfields[0]+"_analysis-repeatability";
           analyzes_name = idfields[0]+"_analyzes";

           // If the analysis value is default than ask for a confirmation
           if ( $(this).prop("checked") == true &&
                ( $("#"+analysis_value_txtbx).val() == '' ||
                  $("#"+analysis_value_txtbx).val() == 'NaN' ||
                  $("#"+analysis_value_txtbx).val() == 'nan' ) )
           {
              if ( ! confirm("No calibration results provided.\nAre you sure you want to continue?") )
              { return false; }
           }


           var linearr = [];

           // Process the checkbox
           if ( $(this).prop("checked") == true )
           {
              // Analysis complete checked?

              // Set the box to green
              $("#"+font_box).css('background-color', '#00FF00');

              $("input[type=checkbox][id^='"+idfields[0]+"_'][id*='results']").each ( function()
              {
                 if ( $(this).prop("checked") == true )
                 {
                    linearr.push($(this).attr('data'));
                 }
              });

              // Save the values
              SetValue(analysis_value_txtbx, $("#"+analysis_value_txtbx).val(), dataaarr);
              SetValue(analysis_repeatability_txtbx, $("#"+analysis_repeatability_txtbx).val(), dataaarr);
              SetValue(analyzes_name, linearr, dataaarr);
           }
           else
           {
              // Analysis complete unchecked?

              // Set the box to white
              $("#"+font_box).css('background-color', '#FFFFFF');

              // Set the values to default
              SetValue(analysis_value_txtbx, 'NULL', dataaarr);
              SetValue(analysis_repeatability_txtbx, 'NULL', dataaarr);
              SetValue(analyzes_name, 'NULL', dataaarr);
           }
        });
 
        $("input[type=checkbox][id$='analysis-complete']").click ( function()
        {
           //
           // Display a 'Stay on Page?' dialog if an analysis-complete box
           //  has been checked but the user tries to navigate away
           //
           var count = 0;
           $("input[type=checkbox][id$='analysis-complete']").each ( function()
           {
              if ( $(this).prop("checked") == true )
              {
                 count++;
                 return false;
              }
           });

           if ( count > 0 )
           {
              //alert("beforeunload set!");
              $(window).bind('beforeunload', function(){
                 return 'Are you sure you want to leave?';
              });
           }
           else
           {
              //alert("beforeunload unset!");
              $(window).unbind('beforeunload');
           }
        });

        $("input[type=checkbox][id*='results']").click ( function()
        {
           var valuearr = [];
           var idfields = $(this).attr('id').split('_');

           $("input[type=checkbox][id^='"+idfields[0]+"_'][id*='results']").each ( function()
           {
              if ( $(this).prop("checked") == true )
              {
                 valuearr.push($(this).attr('val'));
              }
           });

           var sum_value = 0.0;

           for ( var i = 0; i < valuearr.length; i++ )
           {
              sum_value = sum_value + parseFloat(valuearr[i]);
           }

           var mean_value = sum_value / valuearr.length;

           var tmp_value = 0.0;
           for ( var j = 0; j < valuearr.length; j++ )
           {
              tmp_value = tmp_value + Math.pow( parseFloat(valuearr[j]) - mean_value, 2)
           }

           // Needs to be divided by n-1 because the value was determined from this
           //  sample data not independently
           var variance_value = tmp_value / (valuearr.length - 1);

           var standard_deviation = Math.sqrt(variance_value);

           mean_value = mean_value.toFixed(3);
           standard_deviation = standard_deviation.toFixed(3);

           // alert(mean_value+' '+standard_deviation);
           // alert($(this).attr('id'));

           // Put the values in the correct text places
           $("#"+idfields[0]+"_analysis-value").val(mean_value);
           $("#"+idfields[0]+"_analysis-repeatability").val(standard_deviation);

           if ( $("#"+idfields[0]+"_analysis-complete").prop("checked") == true )
           {
              // If it is checked it needs to be unclicked then clicked again
              $("#"+idfields[0]+"_analysis-complete").trigger('click');
              $("#"+idfields[0]+"_analysis-complete").trigger('click');
           }
        });

        $("input[type=button][id$='_select-all']").click ( function()
        {
           var idfields = $(this).attr('id').split('_');

           $("input[type=checkbox][id^='"+idfields[0]+"_'][id*='results']").each ( function()
           {
              // If a checkbox is not checked then click it to check it
              if ( $(this).prop("checked") != true )
              { $(this).trigger('click'); }
           });
        });

        $("input[type=button][id$='_unselect-all']").click ( function()
        {
           var idfields = $(this).attr('id').split('_');

           $("input[type=checkbox][id^='"+idfields[0]+"_'][id*='results']").each ( function()
           {
              // If a checkbox is checked then click it to uncheck it
              if ( $(this).prop("checked") == true )
              { $(this).trigger('click'); }
           });
        });
        
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
        //alert(location.pathname.split("/").slice(-1).toString());

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

    

  </SCRIPT>

<?PHP
CreateMenu($database_object, $user_obj);

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

  <FORM name='mainform' id='mainform' method='POST'>
   <INPUT type='hidden' id='input_data' name='input_data'>
    <H1>
<?PHP
   echo $calservice_object->getAbbreviationHTML()." To Do";

   if ( $showresults != 0 )
   {
      echo " - Task";
   }
   else
   {
      echo " - View";
   }
?>
    </H1>
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
         <INPUT type='checkbox' id='col_toggle_fill-code' checked>Fill Code<BR>
         <INPUT type='checkbox' id='col_toggle_primary-customer' checked>Primary Customer<BR>
        </TD>
        <TD valign='top'>
         <INPUT type='checkbox' id='col_toggle_order-num' checked>Order Num<BR>
         <INPUT type='checkbox' id='col_toggle_due-date' checked>Due Date<BR>
         <INPUT type='checkbox' id='col_toggle_organization' checked>Organization<BR>
        </TD>
        <TD valign='top'>
         <INPUT type='checkbox' id='col_toggle_cylinder-location' checked>Cylinder Location<BR>
         <INPUT type='checkbox' id='col_toggle_location-comments' checked>Location Comments<BR>
         <INPUT type='checkbox' id='col_toggle_analysis-type' checked>Analysis Type<BR>
        </TD>
        <TD valign='top'>
         <INPUT type='checkbox' id='col_toggle_target-value' checked>Target Value<BR>
         <INPUT type='checkbox' id='col_toggle_analysis-comments' checked>Analysis Comments<BR>
         <?php
         if(!$showresults){
            echo "<INPUT type='checkbox' id='col_toggle_last-caldate' checked>Last Cal Date<BR>";
         }?>
<?PHP
   if ( $showresults != 0 )
   { echo "<INPUT type='checkbox' id='col_toggle_results' checked>Results<BR>"; }
?>
        </TD>
       </TR>
      </TABLE>
     </TD>
    </TR>
   </TABLE>

   <TABLE border='1' id='mainTable' class='tablesorter'>
    <THEAD>
     <TH id='header_cylinder-id'>Cylinder ID</TH>
     <TH id='header_fill-code'>Fill Code</TH>
     <TH id='header_primary-customer'>Primary Customer</TH>
     <TH id='header_order-num'>Order Num</TH>
     <TH id='header_due-date'>Due Date</TH>
     <TH id='header_organization'>Organization</TH>
     <TH id='header_cylinder-location'>Cylinder Location</TH>
     <TH id='header_location-comments'>Location Comments</TH>
     <TH id='header_analysis-type'>Analysis Type</TH>
     <TH id='header_target-value'>Target Value</TH>
     <?php
     if(!$showresults){
         echo "<th id='header__last-caldate'>Last Cal Date</th>";
     }?>
     <TH id='header_analysis-comments'>Analysis Comments</TH>
<?PHP
   if ( $showresults != 0 )
   { echo "<TH id='header_results'>Results</TH>"; }
?>
    </THEAD>
    <TBODY>
<?PHP

foreach ( $calrequest_objects as $calrequest_object )
{
   echo "<TR>\n";
   echo " <TD id='".$calrequest_object->getNum()."_cylinder-id'>\n";
   echo $calrequest_object->getProduct()->getCylinder()->getID();
   echo "</TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_fill-code'>\n";
   echo $calrequest_object->getProduct()->getFillCode();
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_primary-customer'>\n";
   if ( is_object($calrequest_object->getProduct()) &&
        is_object($calrequest_object->getProduct()->getOrder()) &&
        is_object($calrequest_object->getProduct()->getOrder()->getPrimaryCustomer()) )
   { echo htmlentities($calrequest_object->getProduct()->getOrder()->getPrimaryCustomer()->getEmail(), ENT_QUOTES, 'UTF-8'); }
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_order-num'>\n";
   if ( is_object($calrequest_object->getProduct()) &&
        is_object($calrequest_object->getProduct()->getOrder()) )
   { echo $calrequest_object->getProduct()->getOrder()->getNum(); }
   echo " </TD>\n";
   if ( is_object($calrequest_object->getProduct()) &&
        is_object($calrequest_object->getProduct()->getOrder()) ) 
   { $color = $calrequest_object->getProduct()->getOrder()->getPriorityColorHTML(); }
   else
   { $color = '#FFFFFF'; }
   echo " <TD id='".$calrequest_object->getNum()."_due-date' style='background-color:$color'>\n";
   if ( is_object($calrequest_object->getProduct()) &&
        is_object($calrequest_object->getProduct()->getOrder()) )
   { echo $calrequest_object->getProduct()->getOrder()->getDueDate(); }
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_organization'>\n";
   if ( is_object($calrequest_object->getProduct()) &&
        is_object($calrequest_object->getProduct()->getOrder()) )
   { echo htmlentities($calrequest_object->getProduct()->getOrder()->getOrganization(), ENT_QUOTES, 'UTF-8'); }
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_cylinder-location'>\n";
   echo $calrequest_object->getProduct()->getCylinder()->getLocation()->getAbbreviation();
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_location-comments'>\n";
   echo htmlentities($calrequest_object->getProduct()->getCylinder()->getLocationComments(), ENT_QUOTES, 'UTF-8');
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_analysis-type'>\n";
   echo $calrequest_object->getAnalysisType();
   echo " </TD>\n";
   echo " <TD id='".$calrequest_object->getNum()."_target-value'>\n";
   echo htmlentities($calrequest_object->getTargetValue(), ENT_QUOTES, 'UTF-8');
   echo " </TD>\n";
   if(!$showresults){
      echo " <TD id='".$calrequest_object->getNum()."_last-caldate'>\n";
      echo htmlentities($calrequest_object->getLastCalDate(), ENT_QUOTES, 'UTF-8');
      echo " </TD>\n";
   }
   echo " <TD id='".$calrequest_object->getNum()."_analysis-comments'>\n";
   echo htmlentities($calrequest_object->getComments(), ENT_QUOTES, 'UTF-8');
   echo " </TD>\n";
   
   if ( $showresults != 0 )
   {
      echo " <TD id='".$calrequest_object->getNum()."_results'>\n";
      try
      {
         if ( is_object($calrequest_object->getProduct()) &&
              is_object($calrequest_object->getProduct()->getCylinder()) )
         {
            $res = $calrequest_object->getAnalyzesFromDB();
            echo "<H4>Database results</H4>";

            echo "<TABLE cellspacing='0' cellpadding='0'>";
            for ( $linenum = 0; $linenum < count($res); $linenum++ )
            {
               $line = $res[$linenum];

               echo "<TR>";
               $fields = preg_split('/\s+/', trim($line));
               if ( preg_match('/^[A-Z]|(None)$/', $fields[0]) &&
                    ValidDate($fields[1]) )
               {

                  echo " <TD>";
                  if ( ValidFloat($fields[6]) )
                  {
                     echo "  <INPUT id='calrequest".$calrequest_object->getNum()."_results-".$linenum."' name='calrequest".$calrequest_object->getNum()."_results-".$linenum."' type='checkbox' val='$fields[6]' data='$line'>";
                  }
                  else
                  { echo "<FONT style='color:red; '>Error parsing string!</FONT>"; } 
   
                  echo " </TD>";
                  echo " <TD style='font-family:monospace; unicode-bidi: embed; white-space: pre; font-size: 1.3em;'>";
                  echo $line;
                  echo " </TD>";
               }
               else
               {
                  echo " <TD>";
                  echo " </TD>";
                  echo " <TD style='font-family:monospace; unicode-bidi: embed; white-space: pre; font-size: 1.3em;'>";
                  echo $line;
                  echo " </TD>";
               }
               echo "</TR>";
            }
            echo "</TABLE>";
            echo "<TABLE>";
            echo " <TR>";
            echo "  <TD colspan='2'>";
            echo "   <DIV style='font-weight:bold; color:red;'>These selections are for reporting only.<BR>They do not change flags in the database.</DIV>";
            echo "  </TD>";
            echo " </TR>";
            echo " <TR>";
            echo "  <TD>";
            echo "   <INPUT type='button' value='Select All' id='calrequest".$calrequest_object->getNum()."_btn2_select-all' name='calrequest".$calrequest_object->getNum()."_btn2_select-all'>";
            echo "  </TD>";
            echo "  <TD>";
            echo "   <INPUT type='button' value='Unselect All' id='calrequest".$calrequest_object->getNum()."_btn2_unselect-all' name='calrequest".$calrequest_object->getNum()."_btn2_unselect-all'>";
            echo "  </TD>";
            echo " </TR>";
            echo "</TABLE>";
         }
         echo "  <HR>\n";
         echo "  <H4>Analysis Results</H4>\n";
         echo "  <TABLE border='1'>\n";
         echo "   <TR>\n";
         echo "    <TH>Value</TH>\n";
         echo "    <TH>Repeatability</TH>\n";
         echo "   </TR>\n";
         echo "   <TR>\n";
         echo "    <TD>\n";
         echo "     <INPUT type='text' size='10' id='calrequest".$calrequest_object->getNum()."_analysis-value' name='calrequest".$calrequest_object->getNum()."_analysis-value' value='NaN'>\n";
         echo "    </TD>\n";
         echo "    <TD>\n";
         echo "     <INPUT type='text' size='10' id='calrequest".$calrequest_object->getNum()."_analysis-repeatability' name='calrequest".$calrequest_object->getNum()."_analysis-repeatability' value='-999.9999'>\n";
         echo "    </TD>\n";
         echo "   </TR>\n";
         echo "   <TR>\n";
         echo "    <TD colspan='2'>\n";
         echo "     <INPUT type='checkbox' name='calrequest".$calrequest_object->getNum()."_analysis-complete' id='calrequest".$calrequest_object->getNum()."_analysis-complete'>";
         echo "     <FONT style='font-weight:bold;' name='calrequest".$calrequest_object->getNum()."_analysis-complete-box' id='calrequest".$calrequest_object->getNum()."_analysis-complete-box'>&nbsp;Analysis Complete</FONT>\n";
         echo "    </TD>\n";
         echo "   </TR>\n";
         echo "  </TABLE>\n";
         echo "  <BR>\n";
         echo "  <FONT style='cursor: pointer; color:blue; text-decoration:underline;' onClick='$(document.body).scrollLeft($(\"#bottom\").offset().left).scrollTop($(\"#bottom\").offset().top);'>Go to bottom</FONT> to submit.\n";
      }
      catch ( Exception $e )
      {
         Log::update($user_obj->getUsername(), $e->__toString());

         echo "    <DIV style='color:red'>Error encountered: ".$e->getMessage()."</DIV>";
      }
      echo " </TD>\n";
   }
   echo "</TR>\n";
}

?>
    </TBODY>
   </TABLE>
   <TABLE>
    <TR>
     <TD>
      <A name='bottom' id='bottom'>
      <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
       <TR>
        <TD align='left' width='50%'>
<?PHP
   if ( $showresults != 0 )
   { echo "<INPUT type='button' value='Submit Page' onClick='SubmitCB();'>"; }
?>
   
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

