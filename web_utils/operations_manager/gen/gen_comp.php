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
global $ccgg_equip;

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$compinfo = isset( $_POST['compinfo'] ) ? $_POST['compinfo'] : '';
$compnum = isset( $_POST['compnum'] ) ? $_POST['compnum'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_comp.js'></SCRIPT>";

#
# Determine the task to be done
#
switch ($task)
{
   case "add";
      $sql = "INSERT INTO ${ccgg_equip}.gen_comp (gen_type_num) VALUES ('${gen_type_num}')";

      $res = ccgg_insert($sql); 
      if (!empty($res))
      {
         JavaScriptAlert("Error adding component to DB.");
         break;
      }

      $sql = "SELECT LAST_INSERT_ID()";
      $res = ccgg_query($sql);

      if ( ! isset($res[0]) || $res[0] == '0' )
      {
         JavaScriptAlert("Error adding component to DB.");
         break;
      }
      else
      {
         $compnum = $res[0];
      }
   case "update";
      $fields = split("\|", $compinfo);

      for ( $i=0; $i<count($fields); $i++ )
      {
         $tmp = split("~",$fields[$i]);
         list($table, $name) = split(":", $tmp[0]);

         $tmp[1] = mysql_real_escape_string($tmp[1]);
         $sql = "UPDATE ${table} SET ${name} = '${tmp[1]}' WHERE num = '${compnum}'";
         #echo "$sql<BR>";
         $sql = ccgg_insert($sql);
      }

      if ( $task === "add" ) { JavaScriptAlert("Component updated."); }
      else { JavaScriptAlert("Component updated."); }
      $task = '';
      break;
}

$compinfo = DB_GetAllCompList($gen_type_num);

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
   global $ccgg_equip;
   global $compinfo;
   global $gen_type_num;
   global $gen_type_abbr;
   global $compnum;
?>

   <FORM name='mainform' method=POST>
   <?php
   #
   #  Keep all the data hidden for the server side operations
   # 
   ?>
   <INPUT TYPE='HIDDEN' NAME='task'>
   <INPUT TYPE='HIDDEN' NAME='compinfo'>
   <INPUT TYPE='HIDDEN' NAME='activestr'>
   <?php
   echo "<INPUT TYPE='HIDDEN' NAME='compnum' VALUE='${compnum}'>";
   ?>

   <?php
   #
   # Page title
   #
   ?>
   <TABLE cellspacing=10 cellpadding=10 width='90%' align='center'>
   <TR align='center'>
   <?php
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} Component Manager</TD>";
   ?>
   </TR>
   <?php # End page title table ?>
   </TABLE>

   <?php
   #
   # Main table
   #
   ?>
   <TABLE align='center' width='90%' border='0' cellpadding='5' cellspacing='0'>
   <TR>

   <?php
   $hline = str_pad('_',50,'_');
   ?>
   
   <TD colspan='2'>
   <?php # Begin of Button table ?>
   <TABLE border='0' align='center' width='60%'>
   <TR>
   <TD align='left'>
   <SELECT class='MediumBlackN' NAME='complist' SIZE='1' onChange='ListSelectCB(this)'>
   <OPTION VALUE=''></OPTION>
   <?php

   for ($i=0; $i<count($compinfo); $i++)
   {
      $fields = split("\|", $compinfo[$i]);

      if ( empty($compnum) ) { $compnum = $fields[0]; }

      $selected = ( $fields[0] == $compnum ) ? "SELECTED" : "";
      $text = "$fields[2] - $fields[1]";
      $val = $fields[0];
      echo "<OPTION class='MediumBlackN' $selected VALUE='${val}'>${text}</OPTION>";
   }
   ?>
   </SELECT>
   </TD>
   <TD align='left'>
   <INPUT TYPE='button' class='Btn' value='Add' onClick='AddCB()'>
   </TD>
   <?php
   if ( $compnum != "Add" )
   {
      echo "<TD align='left'>";
      echo "<INPUT TYPE='button' class='Btn' value='Update' onClick='UpdateCB()'>";
      echo "</TD>";
   }
   ?>
   <TD align='left'>
   <INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>
   </TD>
   </TR>
   <?php # End of Button table ?>
   </TABLE>
   </TD>
   </TR>
   <?php
   if ( $compnum > 0 || $compnum == 'Add' )
   {
      echo "<TR>";
      echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>${hline}</TD>";
      echo "</TR>";
      $table = "${ccgg_equip}.gen_comp";
      PostTable2Edit($table, $compnum, $gen_type_num, "General Info");
   }
   ?>
   <?php # End main table ?>
   </TABLE>

   </BODY>
   </HTML>
<?php
}
#
# Function DB_GetTableContents ########################################################
#
function DB_GetTableContents($table,$compnum,$gen_type_num)
{
   #
   # Get contents of passed table
   #
   ccgg_fields($table,$name,$type,$length);

   $select = "SELECT * ";
   $from = " FROM ${table}";
   $where = " WHERE num='${compnum}'";
   if ( empty($gen_type_num ) ) { $and = ''; }
   else { $and = " AND gen_type_num='${gen_type_num}'"; }
   $sql = $select.$from.$where.$and;

   return ccgg_query($sql);
}
#
# Function PostTable2Edit ########################################################
#
function PostTable2Edit($table,$compnum,$gen_type_num,$title)
{
   echo "<TR>";
   echo "<TD class='LargeBlueB' COLSPAN=2 ALIGN='center'>${title}</TD>";
   echo "</TR>";
   echo "<TR><TD></TD></TR>";
   echo "<TR>";

   #
   # returns data about the datatype
   #
   $res = ccgg_fields($table,$name,$type,$length);
   $info = DB_GetTableContents($table,$compnum,$gen_type_num);
   $linkcount = DB_CountLinkedUnits($compnum);

   if ( isset($info[0]) ) { $field = split("\|", $info[0]); }

   #
   # Loop through all of the fields and output the name and data
   #
   for ($i=0; $i<count($name); $i++)
   {
      $disabled = '';
      $color = '';

      $value = ( isset($field[$i]) ) ? $field[$i] : '';

      echo "<TR>";

      $oname = $name[$i];
      $writable = 1;

      switch($name[$i])
      {
         case 'num':
            $writable = 0;
            break;
         case 'type':
         case 'name':
            if ( $linkcount > 0 ) { $writable = 0; }
            break;
         case 'gen_type_num':
            continue 2;
            #$sql = " SELECT abbr FROM gen_type WHERE num = '$value'";
            #$abbr = ccgg_query($sql);
            #$value = isset($abbr[0]) ? $abbr[0] : '';
            #$writable = 0;
            #break;
         case 'active':
            if ( $compnum == "Add" ) { continue 2; }
            CreateActiveSelectButton($table,$value,$compnum);
            continue 2;
            break;
      }

      echo "<TD ALIGN='right' class='LargeBlueN'>$oname</TD>";
      #
      # Based on the type of field, switch for different outputs
      #
      switch ($type[$i])
      {
         case "blob":
         case "text":
            echo "<TD ALIGN='left'>";
            if ( $writable )
            {
               echo "<TEXTAREA class='MediumBlackN' name='data~${table}:$name[$i]' rows=5 cols=40 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
            }
            else
            {
               echo "<TEXTAREA class='MediumBlackN' name='${table}:$name[$i]' rows=5 cols=40 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' DISABLED>";
            }
            echo $value;
            echo "</TEXTAREA></TD>";
            break;
         default:
            echo "<TD ALIGN='left'>";
            if ( $writable )
            {
               echo "<INPUT type=text class='MediumBlackN' name='data~${table}:$name[$i]' value='${value}' SIZE='40' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' $disabled $color>";
            }
            else
            {
               echo "<FONT class='MediumBlackN'>$value</FONT></TD>";
            }
            break;
      }
      echo "</TR>";
   }
}

#
# Function CreateMfrSelectButton ####################################################
#
function CreateMfrSelectButton($table,$mfr_num)
{
   $mfrinfo = DB_GetAllPSUMfrList();

   echo "<TD ALIGN='right' class='LargeBlueN'>mfr</TD>";
   echo "<TD ALIGN='left'>";
   echo "<SELECT NAME='data~${table}:psu_mfr_num' class='MediumBlackN' SIZE=1>";

   for ($i=0; $i<count($mfrinfo); $i++)
   {
      $tmp=split("\|",$mfrinfo[$i]);
      $selected = ( $mfr_num == $tmp[0] ) ? 'SELECTED' : '';
      $z = sprintf("%s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD>";
}
#
# Function CreateActiveSelectButtion #################################################
#
function CreateActiveSelectButton($table,$status_num,$compnum)
{
   echo "<TD ALIGN='right' class='LargeBlueN'>status</TD>";
   echo "<TD ALIGN='left'>";
   echo "<SELECT NAME='data~$table:active' class='MediumBlackN' SIZE=1 onChange='ActiveStatus(this)'>";

   if ( $status_num == '0' )
   {
      echo "<OPTION VALUE='1'>Active</OPTION>";
      echo "<OPTION VALUE='0' SELECTED>Inactive</OPTION>";
   }
   elseif ( $status_num == '1' )
   {
      echo "<OPTION VALUE='1' SELECTED>Active</OPTION>";
      echo "<OPTION VALUE='0'>Inactive</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD>";

   $tmparr = DB_GetActiveUnitList($compnum);

   $chkstr = join(",", $tmparr);

   if ( !empty($chkstr) )
   {
      $tmpstr = "Component cannot be set to Inactive because\\n it is linked to active units: ".join(",", $tmparr);

      JavaScriptCommand("document.mainform.activestr.value = '${tmpstr}'");
   }
}
#
# Function DB_GetAllCompList() ########################################################
#
function DB_GetAllCompList($gen_type_num)
{
   global $ccgg_equip;
   #
   # Get a list of all the units in the unit table
   #
   $select = " SELECT num, name, type";
   $from = " FROM ${ccgg_equip}.gen_comp ";
   $where = " WHERE gen_type_num = '${gen_type_num}'";
   $order = " ORDER BY type, name";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetActiveUnitList() #####################################################
#
function DB_GetActiveUnitList($compnum)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of all the active components associated with active units
   #
   $select = "SELECT t3.id";
   $from = " FROM ${ccgg_equip}.gen_comp AS t1 LEFT JOIN ${ccgg_equip}.gen_config AS t2";
   $from = "${from} ON ( t1.num = t2.gen_comp_num AND t1.gen_type_num = t2.gen_type_num)";
   $from = "${from} LEFT JOIN ${ccgg_equip}.gen_inv AS t3";
   $from = "${from} ON ( t2.gen_inv_id = t3.id AND t2.gen_type_num = t3.gen_type_num)";
   $where = " WHERE t1.gen_type_num = '${gen_type_num}'";
   $and = " AND t1.active = '1' AND t2.status = '1' AND t1.num = '${compnum}'";
   $order = " ORDER BY t1.num";

   $sql = $select.$from.$where.$and.$order;
   return ccgg_query($sql);
}
#
# Function DB_CountLinkedUnits() #####################################################
#
function DB_CountLinkedUnits($compnum)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of all the active components associated with active units
   #
   $select = "SELECT COUNT(*)";
   $from = " FROM ${ccgg_equip}.gen_comp AS t1, ${ccgg_equip}.gen_config AS t2, ${ccgg_equip}.gen_inv AS t3";
   $where = " WHERE t1.num = t2.gen_comp_num AND t1.gen_type_num = t2.gen_type_num";
   $and = " AND t2.id = t3.id AND t2.gen_type_num = t3.gen_type_num";
   $and = "${and} AND t1.gen_type_num = '${gen_type_num}'";
   $and = "${and} AND t1.num = '${compnum}'";

   $sql = $select.$from.$where.$and;
   $res = ccgg_query($sql);

   return $res[0];
}
#
# Function DB_GetAllPSUMfrList() ########################################################
#
function DB_GetAllPSUMfrList()
{
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT num, abbr ";
   $from = "FROM psu_mfr ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
?>
