<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}
global $ccgg_equip;

$unit_id = isset( $_POST['unit_id'] ) ? $_POST['unit_id'] : '';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$selectedcomps = isset( $_POST['selectedcomps'] ) ? $_POST['selectedcomps'] : '';
$originalcomps = isset( $_POST['originalcomps'] ) ? $_POST['originalcomps'] : '';
$addcomps = isset( $_POST['addcomps'] ) ? $_POST['addcomps'] : '';
$remcomps = isset( $_POST['remcomps'] ) ? $_POST['remcomps'] : '';
$unit_notes = isset( $_POST['unit_notes'] ) ? $_POST['unit_notes'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_config.js'></SCRIPT>";

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
      break;
   }

#
# When the page first loads, show all the units in the database
#
$unitinfo = DB_GetAllUnitList();
#
# The second time the page loads, after a user clicks on an unit,
#    show all the components, highlighting the ones that are already part
#    of the unit
#
if ($unit_id != '')
{ 
   DB_GetComps($selectedcompinfo, $originalcompinfo, $unit_id);
   DB_GetAllCompList($availcompinfo);
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
   global $user;
   global $unit_id;
   global $unitinfo;
   global $availcompinfo;
   global $selectedcompinfo;
   global $selectedcomps;
   global $originalcompinfo;
   global $originalcomps;
   global $addcomps;
   global $remcomps;
   global $unit_notes;
   global $gen_type_abbr;

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
   echo "<INPUT TYPE='HIDDEN' NAME='unit_notes' VALUE='${unit_notes}'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} Configuration</TD>";
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
   echo "<TD width='14%' align='left' class='MediumBlackB'>${gen_type_abbr} - <FONT class='MediumBlueB'>${unit_id}</FONT></TD>";

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

   for ($i=0; $i<count($availcompinfo); $i++)
   {
      $tmp=split("\|",$availcompinfo[$i]);
      if (in_array($tmp[0],$selectedcompinfo))
      {
         echo "<OPTION class='MediumRedB' VALUE=${tmp[0]}>${tmp[1]} - ${tmp[2]}";
         if (!empty($tmp[3]) ) { echo " [v. ${tmp[3]}]</OPTION>"; }
         else { echo " </OPTION>"; }
      }

      $zz = str_replace("\r\n","<BR>",$tmp[4]);
      JavaScriptCommand("comp_notes[$i] = \"${zz}\"");
   }

   #
   # List the rest of the components in MediumBlackN
   #
   for ($i=0; $i<count($availcompinfo); $i++)
   {
      $tmp=split("\|",$availcompinfo[$i]);
      if (!(in_array($tmp[0],$selectedcompinfo)))
      {
         echo "<OPTION class='MediumBlackN' VALUE='${tmp[0]}'>${tmp[1]} - ${tmp[2]}";
         if (!empty($tmp[3]) ) { echo " [v. ${tmp[3]}]</OPTION>"; }
         else { echo " </OPTION>"; }
      }
                                                                                          
      $zz = str_replace("\r\n","<BR>",$tmp[4]);
      JavaScriptCommand("comp_notes[$i] = \"${zz}\"");
   }


   echo "</SELECT>";
   echo "</TD>";

   #
   ##############################
   # Unit and Components Notes
   ##############################
   #
   echo "<TD valign='top'>";
   echo "<FONT class='MediumRedB' id='unit_notes'>${unit_notes}<BR><BR></FONT>";
                                                                                          
   echo "<FONT class='MediumRedB' id='comp_notes'></FONT>";
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
# Function DB_GetAllUnitList() ########################################################
#
function DB_GetAllUnitList()
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of all the units in the unit table
   #
   $select = " SELECT id, comments";
   $from = " FROM ${ccgg_equip}.gen_inv ";
   $where = " WHERE gen_type_num = '${gen_type_num}'";

   if ( $gen_type_num == 1 )
   { $order = " ORDER BY CONVERT(id,SIGNED) DESC"; }
   else
   { $order = " ORDER BY CONVERT(id,SIGNED)"; }

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetAllCompList ########################################################
#
function DB_GetAllCompList(&$availcompinfo)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get list of all components
   #
   $select = " SELECT num, type, name, version, comments ";
   $from = " FROM ${ccgg_equip}.gen_comp ";
   $where = " WHERE active = 1 ";
   $and = " AND gen_type_num = '${gen_type_num}'";
   $order = " ORDER BY type, name";
        
   $availcompinfo = ccgg_query($select.$from.$where.$and.$order);
}

#
# Function DB_GetComps ########################################################
#
function DB_GetComps(&$selectedcompinfo,&$originalcompinfo,$unit_id)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get list of components that are in a given unit
   #
   $select = "SELECT gen_comp_num";
   $from = " FROM ${ccgg_equip}.gen_config";
   $where = " WHERE status='1'";
   $where = " ${where} AND gen_inv_id = '${unit_id}'";
   $where = " ${where} AND gen_type_num = '${gen_type_num}'";
   $order = " ORDER BY gen_comp_num";

   $selectedcompinfo = ccgg_query($select.$from.$where.$order);
   $originalcompinfo = $selectedcompinfo;
}
#
# Function DB_PreChange ########################################################
#
function DB_PreChange($num,&$err)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Check to make sure that the component is still in the database
   #
   $err = "";

   $sql="SELECT num, type, name FROM ${ccgg_equip}.gen_comp WHERE num='${num}' AND gen_type_num = '${gen_type_num}'";
   $res = ccgg_query($sql);

   $n = count($res);
   if ($n == 0) { $err = "${num} no longer exists in DB."; }
   elseif ($n > 1) { $err = "${num} exists multiple times in DB."; }
}
#
# Function DB_AddCompToEquip ########################################################
#
function DB_AddCompToEquip($comp_num,$unit_id)
{
   global $ccgg_equip;
   global $gen_type_num;
   global $gen_type_abbr;
   #
   # "Add" the component to an unit
   #

   #
   # Get the date and time
   #
   $today = date("Y-m-d");
   $time = date("h:i:s A");
   $user = GetUser();

   #
   # Get the database information so that we can output the type, name, and version
   #
   DB_GetAllCompList($availcompinfo);

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
   $insert = "INSERT INTO ${ccgg_equip}.gen_config ";
   $values = "VALUES('${unit_id}','${comp_num}','${gen_type_num}','1','${user}','${today}','${time}','Added Component ${outinfo} to ${gen_type_abbr} ${unit_id}')";

   #echo "$insert $values<BR>";
   $res = ccgg_insert($insert.$values);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}

# Function DB_RemCompFromEquip ########################################################
#
function DB_RemCompFromEquip($comp_num,$unit_id)
{
   global $ccgg_equip;
   global $gen_type_num;
   global $gen_type_abbr;
   #
   # "Remove" component from an unit
   #

   #
   # Get date and time
   #
   $today = date("Y-m-d");
   $time = date("h:i:s A");
   $user = GetUser();

   #
   # Get the database information so that we can output the type, name, and version
   #
   DB_GetAllCompList($availcompinfo);
                                                                                          
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

   $insert = "INSERT INTO ${ccgg_equip}.gen_config ";
   $values = "VALUES('${unit_id}','${comp_num}','${gen_type_num}','1','${user}','${today}','${time}','Removed Component ${outinfo} from ${gen_type_abbr} ${unit_id}')";

   #echo "$insert $values<BR>";
   $res = ccgg_insert($insert.$values);
   if (!empty($res)) { return(FALSE); }

   #
   # Update the history table so that the current_status_num of the 
   #    "removed" component is all 0's (non-current)
   #
   $update = " UPDATE ${ccgg_equip}.gen_config";
   $set = " SET status='0'";
   $where = " WHERE gen_comp_num='${comp_num}' AND gen_inv_id = '${unit_id}'";
   $and = " AND gen_type_num = '${gen_type_num}'";

   $sql = $update.$set.$where.$and;
   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
?>
