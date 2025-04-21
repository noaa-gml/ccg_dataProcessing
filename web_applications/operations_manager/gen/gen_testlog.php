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

#
# Get variables
#
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$unitid = isset( $_POST['unitid'] ) ? $_POST['unitid'] : '';
$casenum = isset( $_POST['casenum'] ) ? $_POST['casenum'] : '';
$casetestnums = isset( $_POST['casetestnums'] ) ? $_POST['casetestnums'] : '';
$newtest = isset( $_POST['newtest'] ) ? $_POST['newtest'] : '';
$saveinfo = isset( $_POST['saveinfo'] ) ? $_POST['saveinfo'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = explode("|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_testlog.js'></SCRIPT>";

switch ( $task )
{
   case 'add':
   case 'update':
      #
      # Add / Update information to DB
      #
      if ( !(DB_UpdateInfo($task,$unitid,$casenum,$casetestnums,$newtest,$saveinfo)))
      {
         JavaScriptAlert("Unable to update DB");
      }
      #
      # Clear task variable so that add\update only occurs once
      #
      $newtest = '';
      $task = '';
      break;
   case 'close':
      #
      # Close a case
      #
      if ( !( DB_CloseCase($unitid,$casenum)))
      {
         JavaScriptAlert("Unable to close to DB");
      }
      $newtest = '';
      $casetestnums = '';
      $task = '';
      break;
}

#
# Get lots of information from the database that we need to make select lists
#
$unitinfo = DB_GetTestUnitList();
$pastunitinfo = DB_GetCaseUnitList();
$alltestinfo = DB_GetAllTestList();
$commentinfo = DB_GetAllCommentType();

#
# If the user tried to use the unit scan but typed in an invalid id, reset $unitid
#
if ( ! empty($unitid ) && ! in_array($unitid, $unitinfo) && ! in_array($unitid, $pastunitinfo) )
{
   JavaScriptAlert("${gen_type_abbr} ID not found.");
   $unitid = '';
}

#
# If a unit id is selected, get all the cases for that unit id
#
if ( $unitid != '' )
{  
   $caseinfo = DB_GetCases($unitid);

   if ( $casenum != '' )
   {
      #
      # If a case is selected, get all the tests for that case
      #
      $casetestinfo = DB_GetTests4Case($casenum);
   }
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $gen_type_abbr;
   global $unitinfo;
   global $pastunitinfo;
   global $caseinfo;
   global $casetestinfo;
   global $alltestinfo;
   global $unitid;
   global $casenum;
   global $casetestnums;
   global $newtest;
   ?>

   <FORM name='mainform' method=POST>

   <INPUT TYPE='HIDDEN' NAME='task'>
   <?php echo "<INPUT TYPE='HIDDEN' NAME='unitid' VALUE='${unitid}'>"; ?>
   <?php echo "<INPUT TYPE='HIDDEN' NAME='casenum' VALUE='${casenum}'>"; ?>
   <?php echo "<INPUT TYPE='HIDDEN' NAME='casetestnums' VALUE='${casetestnums}'>"; ?>
   <?php echo "<INPUT TYPE='HIDDEN' NAME='newtest' VALUE='${newtest}'>"; ?>
   <?php echo "<INPUT TYPE='HIDDEN' NAME='table' VALUE=''>"; ?>
   <?php echo "<INPUT TYPE='HIDDEN' NAME='saveinfo' VALUE=''>"; ?>

   <TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>
   <TR align='center'>

   <?php
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} Test Log";
   if ( ! empty($unitid) )
   {
      if ( in_array($unitid, $unitinfo) )
      { echo ": $unitid"; }
      else
      { echo ": <FONT class='XLargeBlackB'>$unitid</FONT>"; }
   }

   ?>

   </TD></TR>
   </TABLE>

   <?php
   #
   ##############################
   # Define OuterMost Table
   ##############################
   #
   ?>
   <TABLE align='center' width=80% border='0' cellpadding='2' cellspacing='2'>

   <?php
   #
   ##############################
   # Row 2: Selection Windows
   ##############################
   #
   ?>
   <TR>
   <TD align='left' valign='top' width='20%'>
   <?php echo "<FONT class='MediumBlackN'>Select ${gen_type_abbr}:</FONT><BR>"; ?>
   <SELECT class='MediumBlackN' NAME='unitlist' SIZE='4' onChange='ListSelectCB(this)'>

   <?php
   #
   # Display the list of units in testing in blue
   #
   for ($i=0; $i<count($unitinfo); $i++)
   {
      $selected = (!(strcasecmp($unitinfo[$i],$unitid))) ? 'SELECTED' : '';
      $z = sprintf("%s",$unitinfo[$i]);
      echo "<OPTION class='MediumBlueN' $selected VALUE='${z}'>${z}</OPTION>";
   }

   #
   # Display the list of units that have previous cases in black
   #
   for ($i=0; $i<count($pastunitinfo); $i++)
   {
      if ( in_array( $pastunitinfo[$i], $unitinfo ) ) continue;
      $selected = (!(strcasecmp($pastunitinfo[$i],$unitid))) ? 'SELECTED' : '';
      $z = sprintf("%s",$pastunitinfo[$i]);
      echo "<OPTION class='MediumBlackN' $selected VALUE='${z}'>${z}</OPTION>";
   }
   ?>

   </SELECT>

   <BR><B><INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='unitscan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='UnitScanCB()'></B>

   <?php
   JavaScriptCommand("document.mainform.unitscan.focus()");
   ?>

   </TD>

   <?php
   #
   # Case List
   #
   ?>
   <TD align='left' valign='top' width='20%'>

   <?php
   $class = ( $unitid != '' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   ?>

   <FONT class='MediumBlackN'>Select Case:</FONT><BR>
   <SELECT class='MediumBlackN' NAME='caselist' SIZE='4' onClick='ListSelectCB(this)'>

   <?php   
   #
   # If there are no open cases, then display the "Add Case" option in the
   # case selected list. An open case has date_out of '0000-00-00'
   #   
   $addcheck = 0; 
   for ($i=0; $i<count($caseinfo); $i++)
   {
      $tmp=explode("|",$caseinfo[$i]);
      if ( $tmp[2] == '0000-00-00' )
      {
         $addcheck = 1;
         break;
      }
   }

   if ( $addcheck != 1 && in_array( $unitid, $unitinfo ) )
   {
      $selected = ( $casenum == "Add~0000-00-00" ) ? 'SELECTED' : '';
      echo "<OPTION VALUE='Add~0000-00-00' $selected>Add Case</OPTION>";
   }

   for ($i=0; $i<count($caseinfo); $i++)
   {
      #
      #num|date_in|date_out|keyword_num|comments
      #
      $tmp=explode("|",$caseinfo[$i]);

      $selected = ( $casenum == "$tmp[0]~$tmp[1]~$tmp[2]" ) ? 'SELECTED' : '';

      #
      # Display all the cases, putting the open cases in blue text
      # An open case is one that does not a date_out set
      #
      $class = ( $tmp[2] != '0000-00-00' ) ? 'MediumBlackN' : 'MediumBlueN';
      $z = sprintf("%s",$tmp[1]);
      # 
      # In the value we put '$case_num~$date_in~$date_out
      # 
      echo "<OPTION class='$class' $selected VALUE='$tmp[0]~$tmp[1]~$tmp[2]'>${z}</OPTION>";
   }
   ?>
   </SELECT>
   </DIV>
   </TD>

   <TD align='left' valign='top' width='30%'>

   <?php
   #Variable: casetmp
   #Contents: num~date_in~date_out
   #
   $casetmp = explode("~",$casenum);
   $casetmp[0] = isset( $casetmp[0] ) ? $casetmp[0] : '';
   $casetmp[1] = isset( $casetmp[1] ) ? $casetmp[1] : '';
   $casetmp[2] = isset( $casetmp[2] ) ? $casetmp[2] : '';

   #
   # If a unitid, a case are not selected and we are not adding a 
   # new case, then hide the test list
   #
   $class = ( $unitid != '' && $casetmp[0] != '' && $casetmp[0] != 'Add' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select Test:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='testlist' SIZE='4' MULTIPLE>";
   $casetestnums_arr = explode(",",$casetestnums);

   for ($i=0; $i<count($casetestinfo); $i++)
   {
      # date|time|user|test_num|testtype
      $tmp=explode("|",$casetestinfo[$i]);

      $selected = ( in_array($tmp[0], $casetestnums_arr) ) ? "SELECTED" : "";

      $z = sprintf("%s (%s) - %s",$tmp[1], $tmp[2], $tmp[3]);
      echo "<OPTION class='MediumBlackN' $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "<BR>";

   #
   # Button used to show tests
   #
   echo "<DIV align=center>";
   echo "<INPUT TYPE='button' class='Btn' value='Show' onClick='TestSelectCB()'>";
   echo "</DIV>";
   echo "</DIV>";
   echo "</TD>";

   echo "<TD align='left' valign='top' width='30%'>";

   #
   # If a unitid was not selected, we are not adding a new case, and the selected
   # case is still open, then show the list of tests that can be added to the open case
   #
   $class = ( $unitid != '' && $casetmp[0] != 'Add' && $casetmp[2] == '0000-00-00' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select New Test:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='newtestlist' SIZE='4' onChange='ListSelectCB(this)'>";
   sort($alltestinfo);
   for ($i=0; $i<count($alltestinfo); $i++)
   {
      $tmp=explode("|",$alltestinfo[$i]);
      $selected = ( $newtest == $tmp[0] ) ? 'SELECTED' : '';
      $z = sprintf("Add %s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   ?>
   </SELECT>
   </DIV>
   </TD>
   </TR>
   <TR>
   <TD colspan='4'>
   <TABLE width='100%'>

   <?php
   if ( $unitid != '' & $casenum != '' )
   {
      if ( $casetestnums != '' && $newtest == '' )
      {
         #
         # Show old tests
         #
         PostPastTest($casetestnums,$casenum);
      }
      elseif ( $casetestnums == '' && $newtest != '' )
      {
         #
         # Show new test
         #
         $writable = 1;
         PostTestTable('',$newtest,$writable);
      }
      else 
      {
         #
         # Show case information
         #
         PostCaseTable($unitid,$casenum);
      }
   }
   ?>

   <TABLE align='center' width=20% border='0' cellpadding='2' cellspacing='2'>
   <TD align='center'>

   <?php

   $casetestnums_arr = explode(",",$casetestnums);

   #
   ################################
   # Create the clickable buttons
   ################################
   #

   #
   # If a case is selected and the number of past test selected is less than 2
   #
   if ( $casetmp[0] != '' && count($casetestnums_arr) < 2 )
   {
      #
      # If a new case or a new test is going to be added
      #
      if ( $casetmp[0] == 'Add' || $newtest != '' )
      {
         echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Add' onClick='AddCB()'>";
         echo "</TD>";
         echo "<TD align='center'>";
         echo "<INPUT TYPE='button' name='clear' class='Btn' value='Clear' onClick='ClearCB()'>";
      }
      else
      {
         echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Update' onClick='UpdateCB()'>";
      }
      echo "</TD>";

   }
   ?>

   <TD align='center'>
   <INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>
   </TD>

   <?php
   #
   # If the case is open, then allow the user to close the case
   #
   if ( $casetmp[2] == '0000-00-00' && $casetestnums == '' && $newtest == '' )
   {
      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' name='close' class='Btn' value='Close Case' onClick='CloseCB()'>";
      echo "</TD>";
   }
   ?>

   </TABLE>
   </BODY>
   </HTML>

<?php
}

#
# Function DB_GetTestUnitList() ########################################################
#
function DB_GetTestUnitList()
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of units in testing
   #

   $select = "SELECT id ";
   $from = "FROM ${ccgg_equip}.gen_inv ";
   $where = "WHERE gen_status_num = '1' ";
   $and = " AND gen_type_num = '${gen_type_num}'";
   $order = "ORDER BY id";
   $sql = $select.$from.$where.$and.$order;

   return ccgg_query($sql);
}
#
# Function DB_GetCaseUnitList() ########################################################
#
function DB_GetCaseUnitList()
{  
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of units that have previous cases
   #

   $select = "SELECT DISTINCT gen_inv_id ";
   $from = "FROM ${ccgg_equip}.gen_tlog_case ";
   $where = " WHERE gen_type_num = '${gen_type_num}'";
   $order = "ORDER BY gen_inv_id";
   $sql = $select.$from.$where.$order;

   return ccgg_query($sql);
}
#
# Function DB_GetCases() #####################################################
#
function DB_GetCases($id)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of all the cases associated with a given case
   #

   $select = "SELECT num, date_in, date_out, gen_tlog_keyword_num, comments ";
   $from = "FROM ${ccgg_equip}.gen_tlog_case ";
   $where = "WHERE gen_inv_id = '${id}' ";
   $and = " AND gen_type_num = '${gen_type_num}'";
   $order = "ORDER BY date_in DESC";
   $sql = $select.$from.$where.$and.$order;

   return ccgg_query($sql);
}
#
# Function DB_GetTests4Case() #####################################################
#
function DB_GetTests4Case($casenum)
{
   global $ccgg_equip;

   #
   # Get a list of all the tests associated with a case
   #
   $select = " SELECT t1.num, t1.date, t1.time, t2.name";
   $from = " FROM ${ccgg_equip}.gen_tlog_casetest AS t1, ${ccgg_equip}.gen_tlog_test AS t2";
   $where = " WHERE gen_tlog_case_num = '${casenum}'";
   $and = " AND t1.gen_tlog_test_num = t2.num";
   $order = " ORDER BY date DESC, time DESC";
   $sql = $select.$from.$where.$and.$order;

   return ccgg_query($sql);
}
#
# Function DB_GetAllTestList() ########################################################
#
function DB_GetAllTestList()
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get a list of all the types of tests
   #

   $select = " SELECT num, name";
   $from = " FROM ${ccgg_equip}.gen_tlog_test";
   $where = " WHERE gen_type_num = '${gen_type_num}'";
   $order = " ORDER BY num";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetAllCommentType() ########################################################
#
function DB_GetAllCommentType()
{
   global $ccgg_equip;

   #
   # Get the list of comment types: Symptoms, Diagnosis, Treament, etc...
   #
   $select = "SELECT num, name ";
   $from = "FROM ${ccgg_equip}.gen_tlog_commenttype ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetKeyList() ########################################################
#
function DB_GetKeyList($num)
{
   global $ccgg_equip;
   global $gen_type_num;

   #
   # Get a list of keywords based on the comment type
   #
   $select = " SELECT num, name, comments";
   $from = " FROM ${ccgg_equip}.gen_tlog_keyword";
   $where = " WHERE gen_tlog_commenttype_num = '$num'";
   $and = " AND gen_type_num = '${gen_type_num}'";
   $order = " ORDER BY name";
   $sql = $select.$from.$where.$and.$order;

   return ccgg_query($sql);
}
#
# Function PostCaseTable() ############################################################
#
function PostCaseTable($unitid,$casenum)
{
   global $ccgg_equip;
   global $caseinfo;
   global $commentinfo;

   #
   # Post a case table with the appropraite information
   #
   $table = "${ccgg_equip}.gen_tlog_comment";

   $today = date("Y-m-d");
   JavaScriptCommand("document.mainform.table.value = '${ccgg_equip}.gen_tlog_case'");

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = explode("~",$casenum);

   $keyword_num = '';
   $comments = '';

   for ($i=0; $i<count($caseinfo); $i++)
   {
      #
      #num|date_in|date_out|keyword_num|comments
      #
      $tmp=explode("|",$caseinfo[$i]);
      if ( $casetmp[0] == $tmp[0] )
      {
          $datein = $tmp[1];
          $dateout = $tmp[2];
          $keyword_num = $tmp[3];
          $comments = $tmp[4];
          continue;
      }
   }

   for ( $i=0; $i<count($commentinfo); $i++ )
   {
      #
      # num|name
      #
      $tmp=explode("|",$commentinfo[$i]);
      if ( $tmp[0] == '1' )
      {
         $comment_type = $tmp[1];
         continue;
      }
   }

   echo "<TR>";
   echo "<TD colspan=4 align=center class='MediumBlackB'><HR>Case Information</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD ALIGN='left' colspan=1>";
   echo "<FONT class='MediumBlackB'>Case Number</FONT>";
   echo "</TD>";
   echo "<TD>";
   $value = ( $casetmp[0] == 'Add' ) ? 'Pending' : $casetmp[0];
   echo "<FONT class='MediumBlackB'>$value</FONT>";
   echo "</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD ALIGN='left' colspan=1>";
   echo "<FONT class='MediumBlackB'>Open Date:</FONT>";
   echo "</TD>";
   echo "<TD>";
   $value = ( isset($datein) && !empty($datein) ) ? $datein : '--';
   if ( $casetmp[0] == 'Add' )
   {
      $value = $today;
   }
   echo "<FONT class='MediumBlackB'>$value</FONT>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD ALIGN='left' colspan=1>";
   echo "<FONT class='MediumBlackB'>Closed Date:</FONT>";
   echo "</TD>";
   echo "<TD>";
   $value = ( isset($dateout) && !empty($dateout) ) ? $dateout : '--';
   echo "<FONT class='MediumBlackB'>$value</FONT>";
   echo "</TR>";

   #
   # Use the function PostTestComments() to display the comments
   #
   $type_num = '1';
   $writable = 1;
   $table = "${ccgg_equip}.gen_tlog_case";
   PostTestComments($table,$keyword_num, $comments, $type_num, $comment_type, $writable);

}
#
# Function DB_GetTestComments ##########################################################
#
function DB_GetTestComments($casetestnum)
{
   global $ccgg_equip;

   #  
   # Gets the test comments for a certain test
   #
   $select = " SELECT gen_tlog_commenttype_num, gen_tlog_keyword_num, comments";
   $from = " FROM ${ccgg_equip}.gen_tlog_comment";
   $where = " WHERE gen_tlog_casetest_num = '${casetestnum}'";
   $sql = $select.$from.$where;

   # comment_type_num|keyword_num|comments
   return ccgg_query($sql);
}
#  
# Function DB_GetCaseTestInfo()#########################################################
#  
function DB_GetCaseTestInfo($casetestnum)
{
   global $ccgg_equip;

   #
   # Gets information about a specific case test
   #
   $select = " SELECT t1.date, t1.time, t1.user, t1.gen_tlog_test_num, t2.name";
   $from = " FROM ${ccgg_equip}.gen_tlog_casetest AS t1, ${ccgg_equip}.gen_tlog_test AS t2";
   $where = " WHERE t1.num = '${casetestnum}' and t1.gen_tlog_test_num = t2.num";
   $sql = $select.$from.$where;

   $res = ccgg_query($sql);

   $res[0] = ( isset($res[0]) ) ? $res[0] : "";
   return $res[0];
}
#  
# Function DB_GetTestFields()#########################################################
#  
function DB_GetTestFields($testnum)
{
   global $ccgg_equip;

   #
   # Get the fields for a test number, ordered by sequence
   #
   $select = " SELECT t1.gen_tlog_field_num, t2.name";
   $select = "${select}, t3.name, t2.units";
   $from = " FROM ${ccgg_equip}.gen_tlog_testfield AS t1, ${ccgg_equip}.gen_tlog_field AS t2";
   $from = "${from}, ${ccgg_equip}.gen_tlog_fieldtype as t3";
   $where = " WHERE gen_tlog_test_num = '${testnum}'";
   $and = " AND t1.gen_tlog_field_num = t2.num";
   $and = "${and} AND t2.gen_tlog_fieldtype_num = t3.num";
   $order = " ORDER BY sequence;";
   $sql = $select.$from.$where.$and.$order;

   return ccgg_query($sql);
}
#
# Function DB_GetCaseTestFieldValue ################################################
#
function DB_GetCaseTestFieldValue($casetestnum,$fieldnum)
{
   global $ccgg_equip;

   #
   # Get a value for a specific casetestnum + field combination
   #
   $select = " SELECT value";
   $from = " FROM ${ccgg_equip}.gen_tlog_value";
   $where = " WHERE gen_tlog_casetest_num = '${casetestnum}'";
   $and = " AND gen_tlog_field_num = '${fieldnum}'";
   $sql = $select.$from.$where.$and;

   $res = ccgg_query($sql);

   $res[0] = ( isset($res[0]) ) ? $res[0] : '';
   return $res[0];
}
#  
# Function PostTestTable ##########################################################
#  
function PostTestTable($casetestnum,$testnum,$writable)
{  
   global $ccgg_equip;
   global $alltestinfo;
   global $commentinfo;

   #
   # Post the test table, tried to make this as general as possible
   # but with code specific for a test grouped together 
   #
   $table = "${ccgg_equip}.gen_tlog_value";

   $disabled = ( $writable == '1' ) ? '' : 'DISABLED';

   $casetestinfo = DB_GetCaseTestInfo($casetestnum);

   # date|time|user|test_num|testtype
   $infofield = explode("|",$casetestinfo);
   $date = ( isset($infofield[0]) ) ? $infofield[0] : '';
   $time = ( isset($infofield[1]) ) ? $infofield[1] : '';
   $user = ( isset($infofield[2]) ) ? $infofield[2] : '';
   $testnum = ( isset($infofield[3]) ) ? $infofield[3] : $testnum;
   $title = ( isset($infofield[4]) ) ? $infofield[4] : '';

   if ( empty($title) )
   {
      for ( $i=0; $i<count($alltestinfo); $i++ )
      {
         # gen_tlog_testtype:num|name
         $tmp = explode("|",$alltestinfo[$i]);
         if ( $testnum == $tmp[0] )
         {
            $title = $tmp[1];
            break;
         }
      }

   }

   #
   # Get the test comments for this test
   #
   $testcomment = DB_GetTestComments($casetestnum);

   echo "<TR>";
   echo "<TD colspan=4 align=center class='LargeBlueB'><HR>$title</TD>";
   echo "</TR>";
   if ( $date != '' && $time != '' )
   {
      echo "<TR>";
      echo "<TD ALIGN='left' colspan=4>";
      echo "<FONT class='MediumBlackB'>Date:</FONT>&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackN'>$date</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackB'>Time:</FONT>&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackN'>$time</FONT>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackB'>User:</FONT>&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackN'>$user</FONT>";
      echo "</TD>";
      echo "</TR>";
   }

   $testfieldinfo = DB_GetTestFields($testnum);

   for ( $i=0; $i<count($testfieldinfo); $i++ )
   {
      $field = explode("|", $testfieldinfo[$i]);
      echo "<TR>";
      echo "<TD>";
      echo "<FONT class='MediumBlackB'>${field[1]}";
      if ( !empty($field[3]) ) { echo " [${field[3]}]"; }
      echo "</FONT>";
      echo "</TD>";
      echo "<TD>";

      $value = DB_GetCaseTestFieldValue($casetestnum, $field[0]);

      if ( $writable != '1' ) { echo "<FONT class='MediumBlackB'>$value</FONT>"; }
      else
      {
         $name = "data~${table}:${field[0]}";
         switch ( $field[2] )
         {
            case 'int':
               if ( $value != '' ) { $value = intval($value); }
               echo "<INPUT type=text align=right class='MediumBlackN' name='${name}' value='${value}' size='10' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' MAXLENGTH=12>";
               break;
            case 'float':
               if ( $value != '' ) { $value = floatval($value); }
               echo "<INPUT type=text align=right class='MediumBlackN' name='${name}' value='${value}' size='10' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' MAXLENGTH=12>";
               break;
            case 'str':
               $value = htmlentities(strval($value));
               echo "<INPUT type=text align=right class='MediumBlackN' name='${name}' value='${value}' size='40' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' MAXLENGTH=12>";
               break;
            case 'text':
               $value = strval($value);
               echo "<TEXTAREA class='MediumBlackN' name='${name}' cols=40 rows=3 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
               echo htmlentities($value);
               echo "</TEXTAREA>";
               break;
            case 'date':
               $value = htmlentities(strval($value));
               echo "<INPUT type=text align=right class='MediumBlackN' name='${name}' value='${value}' size='10' maxlength='10' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' MAXLENGTH=12>";
               break;
         }
      }
      ?>

      </TD>
      </TR>

      <?php
   }

   #
   # $i = 0 is where gen_tlog_commenttype.num = 1 => Symptoms
   # which are displayed when the user has only selected a unit ID and a case
   #
   for ( $i=1; $i<count($commentinfo); $i++ )
   {
      $comments = '';
      $keyword_num = '';

      # comment_type:num|name
      $field = explode("|",$commentinfo[$i]);

      for ( $j=0; $j<count($testcomment); $j++ )
      {
         # gen_tlog_comment:comment_type_num|keyword_num|comments
         $tmp = explode("|",$testcomment[$j]);

         if ( $field[0] == $tmp[0] )
         {
            $keyword_num = $tmp[1];
            $comments = $tmp[2];
            continue;
         }
      }
   
      if ( $keyword_num != '' || $writable == '1' )
      {
         PostTestComments('',$keyword_num, $comments, $field[0], $field[1], $writable);
      }
   }
   echo "</TR>";
}
#
# Function PostTestComments ##########################################################
#
function PostTestComments($table,$keyword_num, $comments, $type_num, $type, $writable)
{
   global $ccgg_equip;

   #
   # A general function that posts a colored bar, keyword select list, and a textarea
   #
   if ( empty($table) ) { $table = "${ccgg_equip}.gen_tlog_comment"; }

   $disabled = ( $writable == '1' ) ? '' : 'DISABLED';
   $keyinfo = DB_GetKeyList($type_num);

   echo "<TR>";
   echo "<TD ALIGN='left' colspan=2 bgcolor='#FFCC99'>";
   echo "<FONT class='MediumBlackB'>$type</FONT>";
   echo "</TD>";
   echo "<TD  ALIGN='left' colspan=2 bgcolor='#FFCC99'>";
   if ( $writable == '1' )
   {
      #
      # If we allow the table to be writable, display the keyword select list
      #
      echo "<SELECT NAME='data~${table}:gen_tlog_keyword_num:${type_num}' class='MediumBlackN' SIZE=1>";

      echo "<OPTION VALUE=''>Select Keyword</OPTION>";
      for ( $k=0; $k<count($keyinfo); $k++ )
      {
         #
         # gen_tlog_keyword:num|name|comments
         #
         $keyfield = explode("|",$keyinfo[$k]);
         $z = sprintf("%s",$keyfield[1]);
         $selected = ( $keyfield[0] == $keyword_num ) ? 'SELECTED' : '';
         echo "<OPTION $selected VALUE='$keyfield[0]'>${z}</OPTION>";
      }

      echo "</SELECT>";
   }
   else
   {
      #
      # If the table is not suppose to writable, then just display the keyword
      #
      for ( $k=0; $k<count($keyinfo); $k++ )
      {
         #
         # gen_tlog_keyword:num|name|comments
         #
         $keyfield = explode("|",$keyinfo[$k]);
         if ( $keyfield[0] == $keyword_num )
         {
            $keyword_name = $keyfield[1];
            continue;
         }
      }
      echo "<FONT class='MediumBlackN'>$keyword_name</FONT>";

   }
   echo "</TD>";
   echo "</TR>";
   echo "<TR><TD colspan='4'>";

   #
   # If the table is writable, then show a textarea. Otherwise just write it out as text
   #
   if ( $writable == '1' )
   {
      echo "<TEXTAREA class='MediumBlackN' name='data~${table}:comments:${type_num}' cols=120 rows=3 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
      echo $comments;
      echo "</TEXTAREA>";
   }
   else
   {
      $comments = htmlentities($comments);
      echo "<FONT class='MediumBlackN'>$comments</FONT>";
   }
   echo "</TD>";
   echo "</TR>";
}
#
# Function PostPastTest ##########################################################
#
function PostPastTest($casetestnums,$casenum)
{
   #
   # Loop through all of the selected tests and post their information
   #

   $casetestnums_arr = explode(",",$casetestnums);

   #
   # If there is more than one test selected, then do not allow the information
   # to be writable
   #
   $writable = ( count($casetestnums_arr) == 1 ) ? '1' : '0';

   for ( $i=0; $i<count($casetestnums_arr); $i++ )
   {
      PostTestTable($casetestnums_arr[$i],'',$writable);
   }
}
#
# Function DB_UpdateInfo #############################################################
#
function DB_UpdateInfo($task,$unitid,$casenum,$casetestnums,$newtest,$saveinfo)
{
   global $ccgg_equip;
   global $gen_type_num;

   #
   # These are so we can set the values without returning them
   #
   global $casenum;
   global $casetestnums;

   $today = date("Y-m-d");
   $now = date("H:i:s");
   $sql = '';

   #
   # Get the user id
   #
   $user = GetUser();

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);

   $saveinfo_arr = explode("|", $saveinfo);

   if ( $casetestnums != '' && $newtest == '' )
   {
      #
      # Updating past test
      #
      for ( $i=0; $i<count($saveinfo_arr); $i++ )
      {
         $info = $saveinfo_arr[$i];
         if ( ! DB_UpdateTest($info,$casetestnums) ) { return(FALSE); }
      }
   }
   elseif ( $casetestnums == '' && $newtest != '' )
   {
      #
      # Adding new test
      #
      $insert = " INSERT INTO ${ccgg_equip}.gen_tlog_casetest";
      $list = " (gen_tlog_case_num, gen_tlog_test_num, date, time, user)";
      $values = " VALUES ('".mysql_real_escape_string($casetmp[0])."'";
      $values = "${values}, '".mysql_real_escape_string($newtest)."'";
      $values = "${values}, '${today}','${now}','${user}')";
      $sql = $insert.$list.$values;

      #echo "<BR>$sql<BR>";
      $res = ccgg_insert($sql);
      if (!empty($res)) { return(FALSE); }

      $sql = "SELECT LAST_INSERT_ID()";
      $res = ccgg_query($sql);

      if ( ! isset($res[0]) || $res[0] == '0' )
      {
         JavaScriptAlert("Error adding new test to DB.");
         return(FALSE);
      }
      else { $casetestnums = $res[0]; }

      # Go to regular function of updating past test
      for ( $i=0; $i<count($saveinfo_arr); $i++ )
      {
         $info = $saveinfo_arr[$i];
         if ( ! DB_UpdateTest($info,$casetestnums) ) { return(FALSE); }
      }
   }
   elseif ( $casetmp[0] === "Add" )
   {
      #
      # Insert new case
      #
      $insert = " INSERT INTO ${ccgg_equip}.gen_tlog_case";
      $list = " (gen_inv_id, gen_type_num, date_in, date_out)";
      $values = " VALUES ('".mysql_real_escape_string($unitid)."'";
      $values = "${values}, '".mysql_real_escape_string($gen_type_num)."'";
      $values = "${values}, '".mysql_real_escape_string($today)."'";
      $values = "${values}, '0000-00-00')";
      $sql = $insert.$list.$values;

      #echo "<BR>$sql<BR>";
      $res = ccgg_insert($sql);
      if (!empty($res)) { return(FALSE); }

      $sql = "SELECT LAST_INSERT_ID()";
      $res = ccgg_query($sql);

      if ( ! isset($res[0]) || $res[0] == '0' )
      {
         JavaScriptAlert("Error adding new case to DB.");
         return(FALSE);
      }
      else { $casetmp[0] = $res[0]; }
      $casenum = "$casetmp[0]~$today~0000-00-00";

      for ( $i=0; $i<count($saveinfo_arr); $i++ )
      {
         $fields = explode("~",$saveinfo_arr[$i]);
         $names = explode(":",$fields[0]);

         #
         # If we are updating gen_tlog_case and the commenttype is 1 (Symptoms)
         #
         if ( $names[0] == "${ccgg_equip}.gen_tlog_case" && $names[2] == '1' )
         {
            $update = " UPDATE ".mysql_real_escape_string($names[0]);
            $set = " SET ".mysql_real_escape_string($names[1]);
            $set = "${set} = '".mysql_real_escape_string($fields[1])."'";
            $where = " WHERE num = '".mysql_real_escape_string($casetmp[0])."'";
            $sql = $update.$set.$where;

            #echo "<BR>$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) { return(FALSE); }
         }
      }
   }
   else
   {
      #
      # Updating case
      #
      for ( $i=0; $i<count($saveinfo_arr); $i++ )
      {
         $fields = explode("~",$saveinfo_arr[$i]);
         $names = explode(":",$fields[0]);

         #
         # If we are updating gen_tlog_case and the commenttype is 1 (Symptoms)
         #
         if ( $names[0] == "${ccgg_equip}.gen_tlog_case" && $names[2] == '1' )
         {
            $update = " UPDATE ".mysql_real_escape_string($names[0]);
            $set = " SET ".mysql_real_escape_string($names[1]);
            $set = "${set} = '".mysql_real_escape_string($fields[1])."'";
            $where = " WHERE num = '".mysql_real_escape_string($casetmp[0])."'";
            $sql = $update.$set.$where;

            #echo "<BR>$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) { return(FALSE); }
         }
      }
   }
   return(TRUE);
}
#
# Function DB_UpdateTest() ###########################################################
#
function DB_UpdateTest($info,$casetestnums)
{
   global $ccgg_equip;

   #
   # Add/Update the information to DB
   #
   $fields = explode("~",$info);
   $names = explode(":",$fields[0]);
   $table = mysql_real_escape_string($names[0]);

   switch ( $names[0] )
   {
      case "${ccgg_equip}.gen_tlog_value":
         #
         # Variable: $names
         # table name|keyword number
         #
         $where = " WHERE gen_tlog_casetest_num = ";
         $where = "${where} '".mysql_real_escape_string($casetestnums)."'";
         $and = " AND gen_tlog_field_num = ";
         $and = "${and} '".mysql_real_escape_string($names[1])."'";
         if ( empty($fields[1]) )
         {
            #
            # Delete value
            #
            $delete = " DELETE FROM ${table}";
            $sql = $delete.$where.$and;

            #echo "<BR>$sql<BR>";
            $res = ccgg_delete($sql);
            if (!empty($res)) { return(FALSE); }
         }
         else
         {
            #
            # Add/Update value
            #
            $select = "SELECT COUNT(*)";
            $from = " FROM ${table}";
            $sql = $select.$from.$where.$and;

            #echo "<BR>$sql<BR>";
            $count = ccgg_query($sql);

            $tselect = " SELECT t2.name";
            $tfrom = " FROM ${ccgg_equip}.gen_tlog_field AS t1, ${ccgg_equip}.gen_tlog_fieldtype AS t2";
            $twhere = " WHERE t1.num = '".mysql_real_escape_string($names[1])."'";
            $tand = " AND t1.gen_tlog_fieldtype_num = t2.num";
            $sql = $tselect.$tfrom.$twhere.$tand;

            #echo "<BR>$sql<BR>";
            $type = ccgg_query($sql);

            #
            # Filter the values
            #
            switch($type[0])
            {
               case 'int':
                  $fields[1] = intval($fields[1]);
                  break;
               case 'float':
                  $fields[1] = floatval($fields[1]);
                  break;
               case 'date':
               case 'str':   
               case 'text':
                  $fields[1] = strval($fields[1]);
                  break;
               default:
               {
                  JavaScriptAlert("Type not found.");
                  return(FALSE);
               }
            }

            if ( $count[0] == '0' )
            {
               $insert = " INSERT INTO ${table}";
               $list = " (gen_tlog_casetest_num,gen_tlog_field_num,value)";
               $values = " VALUES ('".mysql_real_escape_string($casetestnums)."'";
               $values = "${values}, '".mysql_real_escape_string($names[1])."'";
               $values = "${values}, '".mysql_real_escape_string($fields[1])."')";
               $sql = $insert.$list.$values;
            }
            else
            {
               $update = " UPDATE ${table}";
               $set = " SET value = '".mysql_real_escape_string($fields[1])."'";
               $sql = $update.$set.$where.$and;
            }
            #echo "<BR>$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) { return(FALSE); }
         }
         break;
      case "${ccgg_equip}.gen_tlog_comment":
         #
         # Variable: $names
         # table name|field name|comment type
         #
         $where = " WHERE gen_tlog_casetest_num = ";
         $where = "${where} '".mysql_real_escape_string($casetestnums)."'";
         $and = " AND gen_tlog_commenttype_num = ";
         $and = "${and} '".mysql_real_escape_string($names[2])."'";
         if ( empty($fields[1]) )
         {
            #
            # Delete comment
            #
            if ( $names[1] == 'gen_tlog_keyword_num' )
            {
               $delete = " DELETE FROM ${table}";
               $sql = $delete.$where.$and;

               #echo "<BR>$sql<BR>";
               $res = ccgg_delete($sql);
               if (!empty($res)) { return(FALSE); }
            }
         }
         else
         {
            #
            # Add/Update comment
            #
            $select = "SELECT COUNT(*)";
            $from = " FROM ${table}";
            $sql = $select.$from.$where.$and;

            #echo "<BR>$sql<BR>";
            $count = ccgg_query($sql);
                  
            if ( $count[0] == '0' )
            {
               #
               # Only insert an entry if a keyword is set
               #
               if ( $names[1] === 'gen_tlog_keyword_num' )
               {
                  $insert = " INSERT INTO ${table}";
                  $list = " (gen_tlog_casetest_num,gen_tlog_commenttype_num";
                  $list = "${list},".mysql_real_escape_string($names[1]).")";
                  $values = " VALUES ('".mysql_real_escape_string($casetestnums)."'";
                  $values = "${values}, '".mysql_real_escape_string($names[2])."'";
                  $values = "${values}, '".mysql_real_escape_string($fields[1])."')";
                  $sql = $insert.$list.$values;
                  #echo "<BR>$sql<BR>";
                  $res = ccgg_insert($sql);
                  if (!empty($res)) { return(FALSE); }
               }
            }
            else
            {
               $update = " UPDATE ${table}";
               $set = " SET ".mysql_real_escape_string($names[1]);
               $set = "${set} = '".mysql_real_escape_string($fields[1])."'";
               $sql = $update.$set.$where.$and;
               #echo "<BR>$sql<BR>";
               $res = ccgg_insert($sql);
               if (!empty($res)) { return(FALSE); }
            }
         }
         break;
   }
   return(TRUE);
}
#
# Function DB_CloseCase ##############################################################
#
function DB_CloseCase($unitid,$casenum)
{
   global $ccgg_equip;
   global $casenum;

   #
   # Close a case, which means setting a date_out
   #
   $table = "${ccgg_equip}.gen_tlog_case";
   $today = date("Y-m-d");

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);

   $update = " UPDATE ${table}";
   $set = " SET date_out = '$today'";
   $where = " WHERE num = '$casetmp[0]'";
   $and = " AND date_in = '$casetmp[1]' AND gen_inv_id = '$unitid'";
   $sql = $update.$set.$where.$and;

   #echo "<BR>$sql<BR>";
   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); }
   $casenum = "$casetmp[0]~$casetmp[1]~$today";
   return(TRUE);
}
?>
