<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

#
# Make sure that the database is up and running
#
if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$unitid = isset( $_POST['unitid'] ) ? $_POST['unitid'] : '';
$prev_unitid = isset( $_POST['prev_unitid'] ) ? $_POST['prev_unitid'] : '';
$compnum = isset( $_POST['compnum'] ) ? $_POST['compnum'] : '';
$prev_compnum = isset( $_POST['prev_compnum'] ) ? $_POST['prev_compnum'] : '';
$unit_info = isset( $_POST['unit_info'] ) ? $_POST['unit_info'] : '';
$comp_info = isset( $_POST['comp_info'] ) ? $_POST['comp_info'] : '';
$nsubmits = isset( $_POST['nsubmits'] ) ? $_POST['nsubmits'] : '';
$type = isset( $_POST['type'] ) ? $_POST['type'] : '';

$strat_name = 'PFP';
$strat_abbr = 'pfp';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_comp_add.js'></SCRIPT>";

#
# If an unit was not selected, then a component was selected. If a component
#    was not selected, then an unit was selected. Store the information
#    in the appropriate variables.
#
if ( $unitid == '' )
{
   $table = 'pfp_comp';
   $info = $comp_info;
   $number = $compnum;
}
elseif ( $compnum == '' )
{
   $table = 'pfp_unit';
   $info = $unit_info;
   $number = $unitid;
}

#echo $info;
#
# Determine the task to be done
#
switch ($task)
{
   case 'add':
      #
      # Add a new unit or component to the database
      #
      if (!(DB_UpdateInfo($table,$info,$number,$task))) 
      {
         JavaScriptAlert("Unable to add ${number} to DB");
      }
      $unitid = '';
      $compnum = '';
      $task = '';
      break;

   case 'update':
      #
      # Update an existing unit or component
      #
      $activeunitlist = '';
      $typelist = '';
      $datapairs = split("\|",$info);
                                                                                          
      for ($i=0; $i<count($datapairs); $i++)
      {
         list($n,$v) = split("~",$datapairs[$i]);

         #
         # If the component unit_type is going to be changed, check to make
         #    sure that the unit_type_num of the component is not going
         #    to differ from the unit_type_num of the units that the
         #    component is linked to
         #

         if ( $n == 'pfp_unit_type_num' && $compnum )
         {
            $typecompinfo = DB_GetUnitTypeList($compnum);

            for ($i=0,$j=''; $i<count($typecompinfo); $i++)
            {
               $field = split("\|",$typecompinfo[$i]);
               if ( $field[0] != $v )
               {
                  $typelist = ($j == 0 ) ? "${field[1]}" : $typelist.",${field[1]}";
                  $j++;
               }
            }
         }
 
         #
         # If a component is going to be made inactive, check to see
         #    if it is linked to any active units
         #
         if ( $n == 'active_status_num' && $v == '0' )
         {
            $activecompinfo = DB_GetActiveCompList();
            for ($i=0,$j=0; $i<count($activecompinfo); $i++)
            {
               $field = split("\|",$activecompinfo[$i]);
               if ( $field[0] == $number )
               {
                  $activeunitlist = ($j == 0 ) ? "${field[1]}" : $activeunitlist.",${field[1]}";
                  $j++;
               }
            }
         }
      }

      #
      # If the list of active units that a component is linked to is not NULL
      #    then the component cannot be made inactive
      #
      if ( $activeunitlist != '' )
      {
         $output = "Component cannot be made inactive because it is \\npart of unit(s): ".$activeunitlist;
         JavaScriptAlert($output);
      }
      else
      {
         if ( $typelist != '' )
         {
            $output = "Component_unit_type cannot be changed because it is part of unit(s): ".$typelist;
            JavaScriptAlert($output);
         }
         else
         {
            #
            # Otherwise, update the database
            #
            if (!(DB_UpdateInfo($table,$info,$number,$task)))
            {
               JavaScriptAlert("Unable to add ${number} to DB");
            }
         }
      }

      #
      # After finishing the task, reset the variables which resets the page
      #
      $unitid = '';
      $compnum = '';
      $task = '';
      break;
}

# Server side to client side

$unitinfo = DB_GetAllEquipList();
for ($i=0,$z=''; $i<count($unitinfo); $i++)
{
   $field = split("\|",$unitinfo[$i]);
   $z = ($i == 0) ? $field[0] : "${z},${field[0]}";
}
JavaScriptCommand("units = \"${z}\"");

# Server side to client side
                                                                                          
$compinfo = DB_GetAllCompList();
for ($i=0,$z=''; $i<count($compinfo); $i++)
{
   $field = split("\|",$compinfo[$i]);
   $z = ($i == 0) ? $field[1] : "${z},${field[1]}";
}
JavaScriptCommand("comps = \"${z}\"");

# Server side to client side

$prevcomp = -99;
$activecompinfo = DB_GetActiveCompList();
for ($i=0,$z=''; $i<count($activecompinfo); $i++)
{
   $field = split("\|",$activecompinfo[$i]);
   if ( $field[0] == $prevcomp )
   {
      $z = "${z},${field[1]}";
   }
   else
   {
      $z = ($z == '') ? "$field[0]~$field[1]" : "${z}|${field[0]}~${field[1]}";
      $prevcomp = $field[0];
   }
}
JavaScriptCommand("activecomps = \"${z}\"");

if ( $compnum != '' )
{
   # JavaScriptAlert($compnum);
   $typecompinfo = DB_GetUnitTypeList($compnum);

   $prevtype = -99;

   for ($i=0,$z=''; $i<count($typecompinfo); $i++)
   {
      $field = split("\|",$typecompinfo[$i]);
      if ( $field[0] == $prevtype )
      {
         $z = "${z},${field[1]}";
      }
      else
      {
         $z = ($z == '') ? "$field[0]~$field[1]" : "${z}|${field[0]}~${field[1]}";
         $prevtype = $field[0];
      }
   }

   JavaScriptCommand("typecomps = \"${z}\"");
}
# function DB_GetUnitTypeList($comp_num)

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{

   #
   # Define global variables
   #
   global $unitid;
   global $prev_unitid;
   global $compnum;
   global $prev_compnum;
   global $unitinfo;
   global $compinfo;
   global $nsubmits;
   global $type;
 
   echo "<FORM name='mainform' method=POST>";

  #
  #  Keep all the data hidden for the server side operations
  # 
   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='unitid' VALUE=${unitid}>";
   echo "<INPUT TYPE='HIDDEN' NAME='prev_unitid' VALUE=${prev_unitid}>";
   echo "<INPUT TYPE='HIDDEN' NAME='compnum' VALUE=${compnum}>";
   echo "<INPUT TYPE='HIDDEN' NAME='prev_compnum' VALUE=${prev_compnum}>";
   echo "<INPUT type='hidden' name='nsubmits' value=$nsubmits>";
   echo "<INPUT type='hidden' name='type' value=$type>";
  
   echo "<INPUT type='hidden' name='unit_info'>";
   echo "<INPUT type='hidden' name='comp_info'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Meta Manager</TD>";
   echo "</TR>";
   echo "</TABLE>";
   #
   ##############################
   # Define OuterMost Table
   ##############################
   #
   echo "<TABLE align='center' width=90% border='0' cellpadding='2' cellspacing='2'>";

   #
   ##############################
   # Row 1: Selection Windows
   ##############################
   #
   echo "<TR>";
   echo "<TD>";

   #
   # List all the active units
   #
   echo "<SELECT class='MediumBlackN' NAME='unitlist' SIZE='1' onChange='ListSelectCB(this)'>";
   echo "<OPTION VALUE=''>Select Unit</OPTION>";
   $selected = (!(strcasecmp('Add',$unitid))) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE='Add'>Add Unit</OPTION>";
   for ($i=0; $i<count($unitinfo); $i++)
   {
      $tmp=split("\|",$unitinfo[$i]);
      $class = ($tmp[6] == 1) ? 'MediumBlackN' : 'MediumGrayN';
      $selected = (!(strcasecmp($tmp[0],$unitid))) ? 'SELECTED' : '';
      $z = sprintf("%s (%s) - %s",$tmp[0],$tmp[1],$tmp[2]);
      echo "<OPTION class=$class $selected VALUE=$tmp[0]>${z}</OPTION>";
   }
   echo "</SELECT>";

   echo "</TD>";
   echo "<TD align=right>";

   #
   # List all of the active components
   #
   echo "<SELECT class='MediumBlackN' NAME='complist' SIZE='1' onChange='ListSelectCB(this)'>";
                                                                                          
   echo "<OPTION VALUE=''>Select Component</OPTION>";
   $selected = (!(strcasecmp('Add',$compnum))) ? 'SELECTED' : '';
   echo "<OPTION $selected VALUE='Add'>Add Component</OPTION>";
   for ($i=0; $i<count($compinfo); $i++)
   {
      $tmp=split("\|",$compinfo[$i]);
      $class = ($tmp[5] == 1) ? 'MediumBlackN' : 'MediumGrayN';
      $selected = (!(strcasecmp($tmp[0],$compnum))) ? 'SELECTED' : '';

      #
      # If the version of the component is NULL, then we don't need to
      #    output the []'s
      #
      if ( $tmp[3] != '' )
      {
         $z = sprintf("%s - %s [%s]",$tmp[1],$tmp[2],$tmp[3]);
      }
      else
      {
         $z = sprintf("%s - %s",$tmp[1],$tmp[2]);
      }

      echo "<OPTION class=$class $selected VALUE=$tmp[0]>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD>";

   echo "</TR>";
   echo "</TABLE>";

   #
   # Do this only if something has been selected
   #
   if ($unitid != '' || $compnum != '')
   {
      echo "<TABLE align='center' col=2 width=75% border='0' cellpadding='2' cellspacing='2'>";

      #
      # Post editable tables based on whether an unit or component was selected
      #
      if ( $unitid != '')
      {
         $type = 'pfp_unit';
         PostTable2Edit($type,$unitid,$prev_unitid,'DESCRIPTION');
      }
      if ( $compnum != '' )
      {
         $type = 'pfp_comp';
         PostTable2Edit($type,$compnum,$prev_compnum,'DESCRIPTION');
      }

   echo "</TABLE>";

   echo "<TABLE align='center' width=20% border='0' cellpadding='2' cellspacing='2'>";

   #
   # If 'Add Unit' or 'Add Component' was selected, then make the clickable
   #    button name Add. Otherwise, name it Update.
   #
   if ( $unitid == 'Add' || $compnum == 'Add' )
   {
      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' class='Btn' value='Add' onClick='AddCB(\"${type}\")'>";
      echo "</TD>";

      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' class='Btn' value='Clear' onClick='ClearCB(\"${type}\")'>";
      echo "</TD>";
   }
   else
   {
      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' class='Btn' value='Update' onClick='UpdateCB(\"${type}\")'>";
      echo "</TD>";
   }

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
   echo "</TD>";

   echo "</TABLE>";

}

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_GetTableContents ########################################################
#
function DB_GetTableContents($table,$number)
{
   #
   # Get contents of passed table
   #
   ccgg_fields($table,$name,$type,$length);

   #
   # If $number is an unit, use 'id'. Otherwise if $number is a component
   #    use 'num'
   #
   $z = ($table == 'pfp_unit') ? 'id' : 'num';

   $select = "SELECT * ";
   $from = " FROM ${table}";
   $where = " WHERE ${z}='${number}'";

   #JavaScriptAlert($number);
   return ccgg_query($select.$from.$where);
}
#
# Function PostTable2Edit ########################################################
#
function PostTable2Edit($table,$number,$prev,$title)
{
   $hline = str_pad('_',50,'_');

   echo "<TR>";
   echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>${hline}</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD class='LargeBlueB' COLSPAN=2 ALIGN='center'>${title}</TD>";
   echo "</TR>";
   echo "<TR><TD></TD></TR>";
   echo "<TR>";

   #
   # returns data about the datatype
   #
   $res = ccgg_fields($table,$name,$type,$length);
   $info = DB_GetTableContents($table,$number);

   #
   # If an unit is selected first and then 'Add Unit' is selected then we want to
   #    fill the editable table with all the information from the unit selected
   #    first. If no unit was selected previously, then no need to do this step.
   #    This also applies to components
   #
   if ( $prev != '' && $number == 'Add' ) { $info = DB_GetTableContents($table,$prev); }

   $field = (isset($info[0])) ? split("\|",$info[0]) : '';

   #
   # Loop through all of the fields and output the name and data
   #
   for ($i=0; $i<count($name); $i++)
   {

      $value = (isset($field[$i])) ? $field[$i] : '';

      #
      # If we are adding a new unit or component, do not put a value
      #    for the id (for units) or num (for components)
      #
      if ( $number == 'Add' && ($name[$i] == 'num' || $name[$i] == 'id'))
      {
         $value = '';
      }

      echo "<TR>";

      #
      # Create a select menu for the status of the unit or component
      #
      if ( $name[$i] == 'active_status_num' )
      {
         CreateStatusSelectButton($table,$value,$number);
         continue;
      }

      if ( $name[$i] == 'pfp_unit_type_num' )
      {
         CreateTypeSelectButton($table,$value,$number);
         continue;
      }

      echo "<TD ALIGN='right' class='LargeBlueN'>$name[$i]</TD>";

      #
      # If 'Add Component' was selected, do not let the component number
      #    be editable. This number is auto-incremented by the database
      #
      if ( $number == 'Add' && $name[$i] == 'num' )
      {
         echo "<TD ALIGN='left' class='LargeBlackN'>$value</TD>";
         continue;
      }

      #
      # If we are not adding a new unit or component, then write the
      #    num or id
      #
      if ($number != 'Add' && ($name[$i] == 'num' || $name[$i] == 'id'))
      {
         echo "<TD ALIGN='left' class='LargeBlackN'>$value</TD>";
         continue;
      }

      #
      # Based on the type of field, switch for different outputs
      #
      switch ($type[$i])
      {
         case "blob":
            echo "<TD ALIGN='left'>";
            echo "<TEXTAREA class='MediumBlackN' name='${table}:$name[$i]' cols=60 rows=5 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
            echo $value;
            echo "</TEXTAREA></TD>";
            break;
         default:
            echo "<TD ALIGN='left'>";
            echo "<INPUT type=text class='MediumBlackN'
               name='${table}:$name[$i]' value='${value}' size='60'
               onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
            break;
      }
      echo "</TR>";
   }
}

#
# Function CreateStatusSelectButton ####################################################
#
function CreateStatusSelectButton($table,$status_num,$number)
{
   #
   # Creates the select list for choosing inactive versus active units
   #
   echo "<TD ALIGN='right' class='LargeBlueN'>status</TD>";
   echo "<TD ALIGN='left'>";
   echo "<SELECT NAME='$table:active_status_num' class='MediumBlackN' SIZE=1>";

   if ( $table == 'pfp_comp' )
   {
      $onclick = "onClick='ActiveStatus(${number})'";
   }
   else
   {
      $onclick = "";
   }

   $option1 = '';
   $option2 = '';
   if ( $status_num == '0' )
   {
      $option1 = '';
      $option2 = 'SELECTED';
   }
   elseif ( $status_num == '1' )
   {
      $option1 = 'SELECTED';
      $option2 = '';
   }

   echo "<OPTION VALUE='1' ${option1}>Active</OPTION>";
   echo "<OPTION VALUE='0' ${onclick} ${option2}>Inactive</OPTION>";

   echo "</TD>";
}
#
# Function CreateTypeSelectButton ####################################################
#
function CreateTypeSelectButton($table,$type_num,$number)
{
   #
   # Creates the select list for choosing inactive versus active units
   #


   $select = "SELECT num, abbr, name ";
   $from = "FROM pfp_unit_type ";
   $order = "ORDER BY name";

   $type = ccgg_query($select.$from.$order);
   
   echo "<TD ALIGN='right' class='LargeBlueN'>unit_type</TD>";
   
   echo "<TD ALIGN='left' class='MediumBlackN'>";
   
   if ( $table == 'pfp_unit' && $number != 'Add' )
   {
      for ( $i=0; $i<count($type); $i++ )
      {
         $tmp=split("\|",$type[$i]);
         if ( $type_num == $tmp[0] )
         {
            echo "$tmp[2] ($tmp[1])";
         }
      }
   }
   else
   {
      echo "<SELECT NAME='$table:pfp_unit_type_num' class='MediumBlackN' SIZE=1>";
      for ( $i=0; $i<count($type); $i++ )
      {
         $tmp=split("\|",$type[$i]);
         $selected = ( $type_num == $tmp[0] ) ? 'SELECTED' : '';
         if ( $number != 'Add' )
         {
            $onclick = "onClick='TypeNum($tmp[0],${type_num})'";
         }
         echo "<OPTION VALUE='$tmp[0]' $onclick $selected>$tmp[2] ($tmp[1])</OPTION>";
      }
   }


   echo "</TD>";
}
#
# Function DB_GetAllEquipList() ########################################################
#
function DB_GetAllEquipList()
{
#
# Get a list of all the units in the unit table
#
   $select = "SELECT id, abbr, name, version, batch, comments, active_status_num ";
   $from = "FROM pfp_unit LEFT JOIN pfp_unit_type ";
   $from = "${from} ON ( pfp_unit.pfp_unit_type_num = pfp_unit_type.num ) ";
   $order = "ORDER BY id";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetAllCompList() ########################################################
#
function DB_GetAllCompList()
{
#
# Get a list of all the components in the comp table
#
   $select = "SELECT num, type, name, version, comments, active_status_num ";
   $from = "FROM pfp_comp ";
   $order = "ORDER BY type";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetActiveCompList() #####################################################
#
function DB_GetActiveCompList()
{
#
# Get a list of all the active components associated with active units
#
   $select = "SELECT pfp_comp.num, pfp_unit.id ";
   $from = "from pfp_comp LEFT JOIN pfp_history ON ( pfp_comp.num = pfp_history.comp_num) ";
   $from = "${from} LEFT JOIN pfp_unit ON ( pfp_history.unit_id = pfp_unit.id) ";
   $where = "WHERE pfp_history.current_status_num = 1 AND pfp_unit.active_status_num = 1 ";
   $where = "${where} AND pfp_comp.active_status_num = 1 ";
   $order = "ORDER BY pfp_comp.num";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetUnitTypeList() #####################################################
#
function DB_GetUnitTypeList($comp_num)
{
   $select = "SELECT pfp_unit.pfp_unit_type_num, pfp_unit.id ";
   $from = "FROM pfp_unit LEFT JOIN pfp_history ON ";
   $from = "${from} ( pfp_history.unit_id = pfp_unit.id ) LEFT JOIN pfp_comp ON ";
   $from = "${from} (pfp_history.comp_num = pfp_comp.num) ";
   $where = "WHERE pfp_history.unit_id is not null AND pfp_comp.num = '${comp_num}' ";
   $where = "${where} AND pfp_history.current_status_num = 1 ";
   $order = "ORDER BY pfp_unit.id";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_UpdateInfo ##############################################################
#
function DB_UpdateInfo($table,$info,$number,$settask)
{
   #
   # DB_UpdateInfo first determines whether we should be inserting or
   #    updating the information. If an entry already exists, then we
   #    should be updating. If an entry does not exist, then we should
   #    be inserting. Then check if what the user wants to do coincides
   #    with what DB_UpdateInfo determined should happen. If they are the
   #    same task, then do it.
   #
   $datapairs = split("\|",$info);

   #
   # Split up the $info and create a long string to be attached later
   #
   for ($i=0,$acc='',$list='',$values=''; $i<count($datapairs); $i++)
   {
      list($n,$v) = split("~",$datapairs[$i]);
      $v = addslashes($v);
      $acc = "${acc}${v}";

      $list = ($i == 0) ? "${n}" : "${list},${n}";
      $values = ($i == 0) ? "'${v}'" : "${values},'${v}'";

      $set = ($i == 0) ? "${n}='${v}'" : "${set}, ${n}='${v}'";
   }

   #
   # Count the number of entries based on the values we were passed.
   #
   if ( $table == 'pfp_unit' )
   {
      $sql = "SELECT COUNT(*) FROM ${table} WHERE id = '$number'";
   }
   elseif ( $table == 'pfp_comp' )
   {
      $sql = "SELECT COUNT(*) FROM ${table} WHERE num = '$number'";
   }
   else
   {
      JavaScriptAlert("UpdateInfo: No table defined");
      return(FALSE);
   }

   $res = ccgg_query($sql);

   #
   # If there is a count of 0, then we should insert. Otherwise, we should
   #    update.
   #
   $task = ($res[0] == '0') ? 'add' : 'update';

   #
   # Do stuff only if the task set by the user is equal to the task determined
   #    by DB_UpdateInfo
   #
   if ( $settask == $task )
   {
      if ( $settask == 'update' )
      {
         $sql = "UPDATE ${table} SET ${set}";

         if ( $table == 'pfp_unit' )
         {
            $sql = "${sql} WHERE id='$number'";
         }
         elseif ( $table == 'pfp_comp' )
         {
            $sql = "${sql} WHERE num=$number";
         }
      }

      if ( $settask == 'add' )
      {
         if ( $table == 'pfp_unit' )
         {
            $sql = "INSERT INTO ${table} (${list})";
            $sql = "${sql} VALUES(${values})";
         }
         elseif ( $table == 'pfp_comp' )
         {
            $sql = "INSERT INTO ${table} (num,${list})";
            if ( $number == 'Add' )
            {
               $sql = "${sql} VALUES('',${values})";
            }
            else
            {
               $sql = "${sql} VALUES('${number}',${values})";
            }
         }
      }

      #
      # Do not create a table entry if all fields are empty
      #

      if (empty($acc)) { DB_DeleteInfo($table, $number); }
      else 
      {
         #echo "$sql<BR>";
         $res = ccgg_insert($sql);
         if (!empty($res)) { return(FALSE); }
      }
      return(TRUE);
   }
   else
   {
      #
      # If the task set by the user is not equal to the task determined
      #    by DB_UserInfo, then error
      #
      if ( $settask == 'update' AND $task == 'add' )
      {
         JavaScriptAlert("Unable to update because does not exist in DB.");
      }
      elseif ( $settask == 'add' AND $task == 'update' )
      {
         JavaScriptAlert("Unable to add bacause already exists in DB.");
      }
      return(FALSE);
   }
}

#
# Function DB_DeleteInfo ########################################################
#
function DB_DeleteInfo($table, $number)
{
   #
   # By deleting an unit or component, all we do is set it inactive
   #

   $sql = "UPDATE ${table} SET active_status_num = 0";
   if ( $table == 'pfp_unit' )
   {
      $sql = "${sql} WHERE id='${number}'";
   }
   else
   {
      $sql = "${sql} WHERE num='${number}'";
   }

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
?>
