<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$unit_id = isset( $_POST['unit_id'] ) ? $_POST['unit_id'] : '';
$selectedcomps = isset( $_POST['selectedcomps'] ) ? $_POST['selectedcomps'] : '';
$originalcomps = isset( $_POST['originalcomps'] ) ? $_POST['originalcomps'] : '';
$addcomps = isset( $_POST['addcomps'] ) ? $_POST['addcomps'] : '';
$remcomps = isset( $_POST['remcomps'] ) ? $_POST['remcomps'] : '';
$unit_notes = isset( $_POST['unit_notes'] ) ? $_POST['unit_notes'] : '';
$comp_notes = isset( $_POST['comp_notes'] ) ? $_POST['comp_notes'] : '';

$strat_abbr = 'pfp';
$strat_name = 'PFP';

$yr = date("Y");

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_comp_status.js'></SCRIPT>";

switch ($task)
{
   case "Ok":
      #
      # Are selected comps still available to check out?
      #
      $precheckcompinfo = (empty($selectedcomps)) ? '' : explode('~',$selectedcomps);

      #
      # Initialize variables
      # 
      $postcheckcompinfo = array();

      #
      # If there are selected components
      #
      if ( !(empty($selectedcomps)))
      {
         #
         # Loop through the selected components and check to make sure that
         #    the selected components actually exist in the database
         #
         for ($i=0,$err=''; $i<count($precheckcompinfo); $i++)
         {
            //JavaScriptAlert($precheckcompinfo[$i]);
            DB_PreChange($precheckcompinfo[$i],$z);
            if ($z != "") { $err = "${err}\\n${z}"; }
            else { $postcheckcompinfo[] = $precheckcompinfo[$i]; }
         }
         if ($err != '')
         {
            JavaScriptAlert("${err}\\n\\nChanging of components aborted.");
            $selectedcomps = implode('~',$postcheckcompinfo);
            break;
         }
      }

      #
      # "Remove" the components specified in the string $remcomps
      #    (which is deliminated by ~'s)
      #
      $remcompinfo = (empty($remcomps)) ? array() : explode('~',$remcomps);
      for ($i=0; $i<count($remcompinfo); $i++)
      {
         if ( $remcompinfo[$i] != '' )
         {
            DB_RemCompFromEquip($remcompinfo[$i],$unit_id);
         }
      }

      #
      # Add the components specified in the string $addcomps
      #    (which is deliminated by ~'s)
      #
      $addcompinfo = (empty($addcomps)) ? array() : explode('~',$addcomps);
      for ($i=0; $i<count($addcompinfo); $i++)
      {
         if ( $addcompinfo[$i] != '' )
         {
            DB_AddCompToEquip($addcompinfo[$i],$unit_id);
         }
      }

      #
      # Reset the variables after we have done what the user requested
      #

      $unit_id = '';
      $selectedcomps = '';
      $originalcomps = '';
      $unit_notes = '';
      $comp_notes = '';
      break;
   }

#
# When the page first loads, show all the units in the database
#
$unitinfo = DB_GetAllEquipList();

#
# The second time the page loads, after a user clicks on an unit,
#    show all the components, highlighting the ones that are already part
#    of the unit
#
if ($unit_id != '')
{ 
   DB_GetComps($selectedcompinfo, $originalcompinfo, $unit_id);
   DB_GetAllCompList($availcompinfo, $unit_id);
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   #
   # Initialize the variables
   #
   global  $unit_id;
   global  $unitinfo;
   global  $availcompinfo;
   global  $selectedcompinfo;
   global  $selectedcomps;
   global  $originalcompinfo;
   global  $originalcomps;
   global  $addcomps;
   global  $remcomps;
   global  $unit_notes;

   $user = GetUser();
   $originalcomps = (empty($originalcompinfo)) ? '' : implode('~',$originalcompinfo);
   $selectedcomps = (empty($selectedcompinfo)) ? '' : implode('~',$selectedcompinfo);

   #
   # Start of the form
   #
   echo "<FORM name='mainform' method=POST>";

   #
   # Initialize hidden variables, so that we can change them dynamically
   #
   echo "<INPUT TYPE='HIDDEN' NAME='unit_id' VALUE=${unit_id}>";
   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='selectedcomps' VALUE='${selectedcomps}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='originalcomps' VALUE='${originalcomps}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='addcomps' VALUE='${addcomps}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='remcomps' VALUE='${remcomps}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='unit_notes' VALUE=''>";
   echo "<INPUT TYPE='HIDDEN' NAME='comp_notes' VALUE=''>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   if ( empty($unit_id) )
   {
      echo "<TD align='center' class='XLargeBlueB'>Unit Change</TD>";
   }
   else
   {
      echo "<TD align='center' class='XLargeBlueB'>Unit: ${unit_id}</TD>";
   }
   echo "</TR>";
   echo "</TABLE>";

   #
   ##############################
   # Define OuterMost Table
   ##############################
   #
   echo "<TABLE col=4 width=100% border='0' cellpadding='8' cellspacing='8'>";

   #
   ##############################
   # Row 1: Column Headers
   ##############################
   #
   echo "<TR align='center'>";

   $unit_id = (empty($unit_id)) ? 'None' : $unit_id;
   echo "<TD width='14%' align='left' class='MediumBlackB'>Unit - <FONT class='MediumBlueB'>${unit_id}</FONT></TD>";

   $n = (empty($availcompinfo)) ? '0' : count($availcompinfo);
   echo "<TD width='48%' align='left' class='MediumBlackB'>Components - <FONT class='MediumBlueB'>${n}</FONT></TD>";

   echo "<TD width='38%' align='left' class='MediumBlackB'>Notes</TD>";

   echo "</TR>";

   #
   ##############################
   # Row 2: Selection Windows
   ##############################
   #
   echo "<TR>";
   echo "<TD>";
   echo "<SELECT class='MediumBlackN' NAME='unitlist' SIZE='15' onClick='EquipListCB()'>";

   #
   # Loop through the unit array and select the ones that the user selected
   #
   for ($i=0; $i<count($unitinfo); $i++)
   {
      $tmp=split("\|",$unitinfo[$i]);
      $selected = ($tmp[0] == $unit_id) ? 'SELECTED' : '';
      echo "<OPTION $selected VALUE=$tmp[0]>${tmp[0]}</OPTION>";

      $zz = str_replace("\r\n","<BR>",$tmp[1]);
      JavaScriptCommand("unit_notes[$i] = \"${zz}\"");
   }
   echo "</SELECT>";
   echo "</TD>";

   echo "<TD>";
   echo "<SELECT class='MediumBlackN' NAME='availablelist' SIZE='15' onClick='doSingle()' ondblClick='doDouble()'>";

   #
   # $availcompinfo is sorted, so by printing the selected ones first
   #    and then looping through and printing all the unselected ones
   #    the list of selected and unselected will be sorted separately.
   #

   #
   # Loop through the available component array, changing the color to
   #    MediumRedB of the components that are in the selected component list
   #

   for ($i=0, $first=0; $i<count($availcompinfo); $i++)
   {
      $tmp=split("\|",$availcompinfo[$i]);
      if (in_array($tmp[0],$selectedcompinfo) && $tmp[0] != '')
      {
         echo "<OPTION class='MediumRedB' VALUE=${tmp[0]}>${tmp[1]} - ${tmp[2]}";
         if (!empty($tmp[3]) ) { echo " [${tmp[3]}]</OPTION>"; }
         else { echo " </OPTION>"; }

         $zz = str_replace("\r\n","<BR>","$tmp[4]");
         JavaScriptCommand("comp_notes[$first] = \"${zz}\"");
	 $first++;
      }
   }

   #
   # List the rest of the components in MediumBlackN
   #
   for ($i=0, $second=0; $i<count($availcompinfo); $i++)
   {
      $tmp=split("\|",$availcompinfo[$i]);
      if (!(in_array($tmp[0],$selectedcompinfo)) && $tmp[0] != '')
      {
         echo "<OPTION class='MediumBlackN' VALUE='${tmp[0]}'>${tmp[1]} - ${tmp[2]}";
         if ( !empty($tmp[3]) ) { echo " [${tmp[3]}]</OPTION>"; }
         else { echo " </OPTION>"; }

         #
	 # Append notes to the already created comp_notes array
	 #    so we need to get the last value that was inserted
	 #    by the first loop and then add to that
	 #

         $zz = str_replace("\r\n","<BR>","$tmp[4]");
         $num = $first + $second;
         JavaScriptCommand("comp_notes[$num] = \"${zz}\"");
         $second++;

      }
   }


   echo "</SELECT>";
   echo "</TD>";

   #
   ##############################
   # Unit and Components Notes
   ##############################
   #
   echo "<TD valign='top'>";
   echo "<FONT class='MediumRedN' id='unit_notes'>${unit_notes}<BR><BR></FONT>";
                                                                                          
   echo "<FONT class='MediumRedN' id='comp_notes'></FONT>";
   echo "</TD>";

   echo "</TABLE>";

   #
   ####################################
   # Form submission and cancel buttons
   ####################################
   #
   echo "<TABLE width='20%' cellspacing='2' cellpadding='2' align='center'>";
   echo "<TR>";
   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Ok' onClick='OkayCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
   echo "</TD>";

   echo "</TR>";
   echo "</TABLE>";

   echo "</BODY>";
   echo "</HTML>";
}
#
# Function DB_GetAllCompList ########################################################
#
function DB_GetAllCompList(&$availcompinfo,$unit_id)
{
   #
   #
   #
   $select = "SELECT pfp_unit_type_num ";
   $from = "FROM pfp_unit ";
   $where = "WHERE id = '${unit_id}'";

   $type_num = ccgg_query($select.$from.$where);
    
   #
   # Get list of all components
   #
   $select = "SELECT num, type, name, version, comments ";
   $from = "FROM pfp_comp ";
   $where = "WHERE active_status_num = '1' ";
   if ( isset($type_num[0]) )
   { $where = "${where} AND pfp_unit_type_num = '$type_num[0]' "; }
   $order = "ORDER BY TYPE ";
        
   $availcompinfo = ccgg_query($select.$from.$where.$order);
}

#
# Function DB_GetComps ########################################################
#
function DB_GetComps(&$selectedcompinfo,&$originalcompinfo,$unit_id)
{
   #
   # Get list of components that are in a given unit
   #
   $select = "SELECT comp_num ";
   $from = " FROM pfp_history ";
   $where = "WHERE current_status_num='1' ";
   $where = "${where} AND unit_id = '${unit_id}' ";
   $order = "ORDER BY comp_num";

   $selectedcompinfo = ccgg_query($select.$from.$where.$order);
   $originalcompinfo = $selectedcompinfo;
}
#
# Function DB_PreChange ########################################################
#
function DB_PreChange($num,&$err)
{
   #
   # Check to make sure that the component is still in the database
   #
   $err = "";

   $sql="SELECT num, type, name FROM pfp_comp WHERE num='${num}'";
   $res = ccgg_query($sql);

   $n = count($res);
   if ($n == 0) { $err = "${num} no longer exists in DB."; }
   elseif ($n > 1) { $err = "${num} exists multiple times in DB."; }
}
#
# Function DB_AddCompToEquip ########################################################
#
function DB_AddCompToEquip($id,$unit_id)
{
   #
   # "Add" the component to an unit
   #

   #
   # Get the date and time
   #
   $today = date("Y-m-d");
   $time = date("h:i:s A");

   #
   # Get the database information so that we can output the type, name, and version
   #
   DB_GetAllCompList($availcompinfo,$unit_id);

   for ($i=0; $i<count($availcompinfo); $i++)
   {
      $tmp=split("\|",$availcompinfo[$i]);
      if ( $tmp[0] == $id )
      {
         $outinfo = "$tmp[1] - $tmp[2] ($tmp[3])";
      }
   }

   #
   # Add a row to the history table, with current_status_num = 0 (which means that
   #    it is a non-current component)
   #
   $insert = "INSERT INTO pfp_history ";
   $values = "VALUES('$unit_id','$id','1','$today','$time','Added Component $outinfo to Unit $unit_id')";

   #echo "$insert $values<BR>";
   $res = ccgg_insert($insert.$values);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}

# Function DB_RemCompFromEquip ########################################################
#
function DB_RemCompFromEquip($comp_num,$unit_id)
{
   #
   # "Remove" component from an unit
   #

   #
   # Get date and time
   #
   $today = date("Y-m-d");
   $time = date("h:i:s A");

   #
   # Get the database information so that we can output the type, name, and version
   #
   DB_GetAllCompList($availcompinfo,$unit_id);
                                                                                          
   for ($i=0; $i<count($availcompinfo); $i++)
   {
      $tmp=split("\|",$availcompinfo[$i]);
      if ( $tmp[0] == $comp_num )
      {
         $outinfo = "$tmp[1] - $tmp[2] ($tmp[3])";
      }
   }

   #
   # Add a row to the history table, with current_status_num = 0 (which means that
   #    it is a non-current component)
   #

   $insert = "INSERT INTO pfp_history ";
   $values = "VALUES('$unit_id','$comp_num','1','$today','$time','Removed Component $outinfo from Unit $unit_id')";

   #echo "$insert $values<BR>";
   $res = ccgg_insert($insert.$values);
   if (!empty($res)) { return(FALSE); }

   #
   # Update the history table so that the current_status_num of the 
   #    "removed" component is all 0's (non-current)
   #
   $update = "UPDATE pfp_history ";
   $set = "SET current_status_num='0' ";
   $where = "WHERE comp_num='${comp_num}' AND unit_id = '${unit_id}'";

   #echo "$update $set $where<BR>";
   $res = ccgg_insert($update.$set.$where);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}

# Function DB_GetAllEquipList #########################################################
#
function DB_GetAllEquipList()
{
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT id, comments ";
   $from = "FROM pfp_unit ";
   $where = "WHERE active_status_num = 1 ";
   $order = "ORDER BY id";
                                                                                
   return ccgg_query($select.$from.$where.$order);
}

?>
