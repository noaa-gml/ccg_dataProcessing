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
$unitinfo = isset( $_POST['unitinfo'] ) ? $_POST['unitinfo'] : '';
$id = isset( $_POST['id'] ) ? $_POST['id'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_unit.js'></SCRIPT>";

#
# Determine the task to be done
#
switch ($task)
{
   case "update";
      $fields = split("\|", $unitinfo);

      for ( $i=0; $i<count($fields); $i++ )
      {
         $tmp = split("~",$fields[$i]);
         list($table, $name) = split(":", $tmp[0]);

         $tmp[1] = mysql_real_escape_string($tmp[1]);
         if ( $table === "${ccgg_equip}.gen_inv" )
         {
            $sql = "UPDATE ${table} SET ${name} = '${tmp[1]}' WHERE id = '${id}'";
         }
         else
         {
            $sql = "UPDATE ${table} SET ${name} = '${tmp[1]}' WHERE gen_inv_id = '${id}'";
         }
         #echo "$sql<BR>";
         $sql = ccgg_insert($sql);
      }
      $task = '';
      break;
}

$unitinfo = DB_GetAllUnitList($gen_type_num);

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
   global $unitinfo;
   global $gen_type_num;
   global $gen_type_abbr;
   global $id;
?>

   <FORM name='mainform' method=POST>
   <?php
   #
   #  Keep all the data hidden for the server side operations
   #
   ?>
   <INPUT TYPE='HIDDEN' NAME='task'>
   <INPUT TYPE='HIDDEN' NAME='unitinfo'>
   <?php
   echo "<INPUT TYPE='HIDDEN' NAME='id' VALUE='${id}'>";
   ?>

   <?php
   #
   # Page title
   #
   ?>
   <TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>
   <TR align='center'>
   <?php
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} Information Manager</TD>";
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
   <TD colspan='2'>
   <?php
   $hline = str_pad('_',50,'_');
   ?>
   <?php # Begin of Button table ?>
   <TABLE border='0' align='center' width='50%'>
   <TR>
   <TD align='right'>
   <SELECT class='MediumBlackN' NAME='unitlist' onChange='ListSelectCB(this)'>
   <?php
   echo "<OPTION VALUE=''>Select ${gen_type_abbr}</OPTION>";

   #if ( empty($id) ) { $id = $unitinfo[0]; }

   for ($i=0; $i<count($unitinfo); $i++)
   {
      $z = $unitinfo[$i];
      $selected = ( $z == $id ) ? "SELECTED" : "";
      echo "<OPTION class='MediumBlackN' $selected VALUE='${z}'>${z}</OPTION>";
   }
   ?>
   </SELECT>
   </TD>
   <TD align='left'>
   <?php
   echo "<B><INPUT TYPE='text' class='MediumSizeBlackTurquoiseB' onChange='SearchCB()' SIZE=10 NAME='search4id' autocomplete='off'>";

   JavaScriptCommand("document.mainform.search4id.focus()");

   echo "<B><INPUT TYPE='button' class='Btn' value='Search' onClick='SearchCB()'>";
   ?>
   </TD>
   <TD align='left'>
   <INPUT TYPE='button' class='Btn' value='Update' onClick='UpdateCB()'>
   </TD>
   <TD align='left'>
   <INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>
   </TD>
   </TR>
   <?php # End of Button table ?>
   </TABLE>
   </TD>
   </TR>
   <?php
   if ( !empty($id) )
   {
      echo "<TR>";
      echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>${hline}</TD>";
      echo "</TR>";
      $table = "${ccgg_equip}.gen_inv";
      PostTable2Edit($table, $id, $gen_type_num, "General Info");

      $sql = " SELECT info FROM ${ccgg_equip}.gen_type WHERE num = '${gen_type_num}'";
      $table = ccgg_query($sql);

      if ( isset($table[0]) ) { $table = $ccgg_equip.".".$table[0]; }
      else { $table = ''; }

      if ( !empty($table) )
      {
         echo "<TR>";
         echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>${hline}</TD>";
         echo "</TR>";
         PostTable2Edit($table, $id, '', "${gen_type_abbr} Info");
      }
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
function DB_GetTableContents($table,$id,$gen_type_num)
{
   global $ccgg_equip;

   #
   # Get contents of passed table
   #
   ccgg_fields($table,$name,$type,$length);

   $select = "SELECT * ";
   $from = " FROM ${table}";
   if ( $table === "${ccgg_equip}.gen_inv" )
   { $where = " WHERE id='${id}'"; }
   else
   { $where = " WHERE gen_inv_id='${id}'"; }
   if ( empty($gen_type_num ) ) { $and = ''; }
   else { $and = " AND gen_type_num='${gen_type_num}'"; }
   $sql = $select.$from.$where.$and;

   return ccgg_query($sql);
}
#
# Function PostTable2Edit ########################################################
#
function PostTable2Edit($table,$id,$gen_type_num,$title)
{
   global $ccgg_equip;

   echo "<TR>";
   echo "<TD class='LargeBlueB' COLSPAN=2 ALIGN='center'>${title}</TD>";
   echo "</TR>";
   #echo "<TR><TD></TD></TR>";
   echo "<TR>";

   #
   # returns data about the datatype
   #
   $res = ccgg_fields($table,$name,$type,$length);
   $info = DB_GetTableContents($table,$id,$gen_type_num);

   if ( isset($info[0]) ) { $field = split("\|", $info[0]); }

   #
   # Find the status_num of the unit. We need this for date_inuse
   # and date_outuse.
   #
   for ($i=0; $i<count($name); $i++)
   {
      $value = ( isset($field[$i]) ) ? $field[$i] : '';

      switch($name[$i])
      {
         case 'gen_status_num':
            $gen_status = $value;
            break;
      }
   }
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
         case 'gen_inv_id':
         case 'id':
            if ( $table != "${ccgg_equip}.gen_inv" ) { continue 2; }
            $writable = 0;
            break;
         case 'gen_type_num':
            continue 2;
            #$sql = " SELECT abbr FROM gen_type WHERE num = '$value'";
            #$abbr = ccgg_query($sql);
            #$value = isset($abbr[0]) ? $abbr[0] : '';
            #$writable = 0;
            #break;
         case 'site_num':
            $oname = 'site_code';
            $sql = "SELECT code from gmd.site where num = '$value'";
            $site_code = ccgg_query($sql);
            $value = isset($site_code[0]) ? $site_code[0] : '';
            $writable = 0;
            break;
         case 'project_num':
            $oname = 'project';
            $writable = 0;
            $tmp = DB_GetProjectInfo($value);
            if ( !empty($tmp) ) { list( $junk, $value ) = split("\|", $tmp); }
            else { $value = ''; }
            break;
         case 'date_out':
         case 'date_in':
            $writable = 0;
            break;
         case 'date_inuse':
         case 'date_outuse':
            if ( $gen_status != '3' ) { $writable = 0; }
            break;
         case 'gen_status_num':
            $oname = 'status';
            $sql = "SELECT name from ${ccgg_equip}.gen_status where num = '$value'";
            $status_name = ccgg_query($sql);
            $value = isset($status_name[0]) ? $status_name[0] : '';
            $writable = 0;
            break;
         case 'event_num';
            continue 2;
         case 'psu_mfr_num':
            CreateMfrSelectButton($table,$value);
            continue 2;
         case 'notes':
            if ( $gen_status != '3' ) { $writable = 0; }
            switch ( $gen_type_num )
            {
               case 1:
                  $oname = 'project_notes';
                  break;
               case 2:
                  $oname = 'checkin_notes';
                  break;
               default:
                  break;
            }
            break;
        case 'doc_property_num':
            $oname='Property Num';
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
               echo "<INPUT type=text class='MediumBlackN' name='data~${table}:$name[$i]' value='${value}' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' $disabled $color>";
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
#var_dump($mfrinfo);
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
# Function DB_GetAllUnitList() ########################################################
#
function DB_GetAllUnitList($gen_type_num)
{
   global $ccgg_equip;

   #
   # Get a list of all the units in the unit table
   #
   $select = " SELECT id";
   $from = " FROM ${ccgg_equip}.gen_inv ";
   $where = " WHERE gen_type_num = '${gen_type_num}'";

   if ( $gen_type_num == 1 )
   { $order = " ORDER BY CONVERT(id,SIGNED) DESC"; }
   else
   { $order = " ORDER BY CONVERT(id,SIGNED)"; }

   return ccgg_query($select.$from.$where.$order);
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
   $from = "FROM ccgg_equip.psu_mfr ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
?>
