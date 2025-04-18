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
$flaskid = isset( $_POST['flaskid'] ) ? $_POST['flaskid'] : '';
$casenum = isset( $_POST['casenum'] ) ? $_POST['casenum'] : '';
$datetime = isset( $_POST['datetime'] ) ? $_POST['datetime'] : '';
$newtest = isset( $_POST['newtest'] ) ? $_POST['newtest'] : '';
$table = isset( $_POST['table'] ) ? $_POST['table'] : '';
$saveinfo = isset( $_POST['saveinfo'] ) ? $_POST['saveinfo'] : '';

$strat_name = 'Flask';
$strat_abbr = 'flask';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_testlog.js'></SCRIPT>";

#
# After the user submits the page, check $task to determine what the user
#    wanted to do.
#

if ( $task == 'add' || $task == 'update' )
{

   #
   # Add\Update
   #
   #if (!(DB_UpdateInfo($task,$flaskid,$casenum,$flightdate,$sitenum,${commentinfo})))
   if ( !(DB_UpdateInfo($task,$table,$flaskid,$casenum,$datetime,$newtest,$saveinfo)))
   {
      JavaScriptAlert("Unable to update DB");
   }
   #
   # Clear task variable so that add\update only occurs once
   #
   $newtest = '';
   $datetime = '';
   $task = '';
}
elseif ( $task == 'close' )
{
   #
   # Close a case
   #
   if ( !( DB_CloseCase($table,$flaskid,$casenum)))
   {
      JavaScriptAlert("Unable to close to DB");
   }
   $datetime = '';
   $newtest = '';
   $task = '';
}

#
# Get lots of information from the database that we need to make select lists
#
$flaskinfo = DB_GetTestFlaskList();
$pastflaskinfo = DB_GetCaseFlaskList();
$alltestinfo = DB_GetAllTestList();
$commentinfo = DB_GetAllCommentType();

#
# If a flask id is selected, get all the cases for that flask id
#
if ( $flaskid != '' )
{
   $caseinfo = DB_GetCases($flaskid);
   if ( $casenum != '' )
   {
      #
      # If a case is selected, get all the tests for that case
      #
      $testinfo = DB_GetTests($casenum);
   }
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $flaskid;
   global $casenum;
   global $datetime;
   global $newtest;
   global $flightdate;
   global $flaskinfo;
   global $pastflaskinfo;
   global $caseinfo;
   global $testinfo;
   global $alltestinfo;
   global $commentinfo;
   global $saveinfo;

   global $table;

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='flaskid' VALUE='${flaskid}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='casenum' VALUE='${casenum}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='datetime' VALUE='${datetime}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='newtest' VALUE='${newtest}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='table' VALUE=''>";
   echo "<INPUT TYPE='HIDDEN' NAME='commentinfo' VALUE='${commentinfo}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='saveinfo' VALUE='${saveinfo}'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Flask Log";
   if ( in_array($flaskid, $flaskinfo) )
   { echo ": $flaskid"; }
   else
   { echo ": <FONT class='XLargeBlackB'>$flaskid</FONT>"; }
   echo "</TD></TR>";
   echo "</TABLE>";

   #
   ##############################
   # Define OuterMost Table
   ##############################
   #
   echo "<TABLE align='center' width=80% border='0' cellpadding='2' cellspacing='2'>";

   #
   ##############################
   # Row 2: Selection Windows
   ##############################
   #
   echo "<TR>";
   echo "<TD align='left' valign='top' width='20%'>";
   echo "<FONT class='MediumBlackN'>Select Flask:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='flasklist' SIZE='4' onChange='ListSelectCB(this)'>";

   #
   # Display the list of flasks in testing in blue
   #
   for ($i=0; $i<count($flaskinfo); $i++)
   {
      $selected = (!(strcasecmp($flaskinfo[$i],$flaskid))) ? 'SELECTED' : '';
      $z = sprintf("%s",$flaskinfo[$i]);
      echo "<OPTION class='MediumBlueN' $selected VALUE='${z}'>${z}</OPTION>";
   }

   #
   # Display the list of flasks that have previous cases in black
   #
   for ($i=0; $i<count($pastflaskinfo); $i++)
   {
      if ( in_array( $pastflaskinfo[$i], $flaskinfo ) ) continue;
      $selected = (!(strcasecmp($pastflaskinfo[$i],$flaskid))) ? 'SELECTED' : '';
      $z = sprintf("%s",$pastflaskinfo[$i]);
      echo "<OPTION class='MediumBlackN' $selected VALUE='${z}'>${z}</OPTION>";
   }
   
   echo "</SELECT>";

   echo "<BR><B><INPUT TYPE='text' class='MediumBlackB' SIZE=8 NAME='flaskscan'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='FlaskScanCB()'>";

   JavaScriptCommand("document.mainform.flaskscan.focus()");

   echo "</TD>";

   echo "<TD align='left' valign='top' width='20%'>";
   $class = ( $flaskid != '' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select Case:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='caselist' SIZE='4' onClick='ListSelectCB(this)'>";


   #
   # If there are no open cases, then display the "Add Case" option in the
   # case selected list. An open case has date_out of '0000-00-00'
   #   
   $addcheck = 0;
   for ($i=0; $i<count($caseinfo); $i++)
   {
      $tmp=split("\|",$caseinfo[$i]);
      if ( $tmp[2] == '0000-00-00' )
      {
         $addcheck = 1;
      }
   }

   if ( $addcheck != 1 && in_array( $flaskid, $flaskinfo ) )
   {
      $selected = ( $casenum == "Add~0000-00-00" ) ? 'SELECTED' : '';
      echo "<OPTION VALUE='Add~0000-00-00' $selected>Add Case</OPTION>";
   }
                                                                                          
   for ($i=0; $i<count($caseinfo); $i++)
   {
      #
      #num|date_in|date_out|keyword_num|comments
      #
      $tmp=split("\|",$caseinfo[$i]);

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
   echo "</SELECT>";
   echo "</DIV>";
   echo "</TD>";

   echo "<TD align='left' valign='top' width='30%'>";
   #
   #Variable: casetmp
   #Contents: num~date_in~date_out
   #
   $casetmp = split("~",$casenum);
   $casetmp[0] = isset( $casetmp[0] ) ? $casetmp[0] : '';
   $casetmp[1] = isset( $casetmp[1] ) ? $casetmp[1] : '';
   $casetmp[2] = isset( $casetmp[2] ) ? $casetmp[2] : '';

   #
   # If a flaskid, a case were not selected and we are not adding a 
   # new case, then hide the test list
   #
   $class = ( $flaskid != '' && $casetmp[0] != '' && $casetmp[0] != 'Add' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select Test:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='testlist' SIZE='4' MULTIPLE>";
   for ($i=0; $i<count($testinfo); $i++)
   {
      # date|time|user|test_num|testtype
      $tmp=split("\|",$testinfo[$i]);

      $dates = split(",",$datetime);
      $selected = '';
      for ( $j=0; $j<count($dates); $j++ )
      {
         if ( $dates[$j] == $testinfo[$i] )
         {
            $selected = 'SELECTED';
            continue;
         }
      }

      #
      # Get the name of the test associated with each test_num
      #
      for ( $j=0; $j<count($alltestinfo); $j++ )
      {
         $field = split("\|",$alltestinfo[$j]);
         if ( $tmp[4] == $field[0] )
         {
            $testtype = $field[1];
            continue;
         }
      }
      $z = sprintf("%s (%s) - %s",$tmp[0], $tmp[1], $testtype);
      echo "<OPTION class='MediumBlackN' $selected VALUE='$testinfo[$i]'>${z}</OPTION>";
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
   # If a flaskid was not selected, we are not adding a new case, and the selected
   # case is still open, then show the list of tests that can be added to the open case
   #
   $class = ( $flaskid != '' && $casetmp[0] != 'Add' && $casetmp[2] == '0000-00-00' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select New Test:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='newtestlist' SIZE='4' onChange='ListSelectCB(this)'>";
   sort($alltestinfo);
   for ($i=0; $i<count($alltestinfo); $i++)
   {
      $tmp=split("\|",$alltestinfo[$i]);
      $selected = ( $newtest == $tmp[0] ) ? 'SELECTED' : '';
      $z = sprintf("Add %s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</DIV>";
   echo "</TD>";

   if ( $flaskid != '' & $casenum != '' )
   {
      if ( $datetime != '' && $newtest == '' )
      {
         #
         # Show old tests
         #
         PostPastTest($datetime,$casenum);
      }
      elseif ( $datetime == '' && $newtest != '' )
      {
         #
         # Show new test
         #
         $writable = 1;
         PostTestTable('',$newtest,$casenum,$writable);
      }
      else
      {
         #
         # Show case information
         #
         PostCaseTable($flaskid,$casenum);
      }
   }

   echo "<TABLE align='center' width=20% border='0' cellpadding='2' cellspacing='2'>";
                                                                                        
   echo "<TD align='center'>";

   $dates = split(",",$datetime);

   #
   ################################
   # Create the clickable buttons
   ################################
   #

   #
   # If a case is selected and the number of past test selected is less than 2
   #
   if ( $casetmp[0] != '' && count($dates) < 2 )
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

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
   echo "</TD>";

   #
   # If the case is open, then allow the user to close the case
   #
   if ( $casetmp[2] == '0000-00-00' && $datetime == '' && $newtest == '' )
   {
      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' name='close' class='Btn' value='Close Case' onClick='CloseCB()'>";
      echo "</TD>";
   }
                   
   echo "</TABLE>";
   echo "</BODY>";
   echo "</HTML>";
}

#
# Function PostPastTest ##########################################################
#
function PostPastTest($datetime,$casenum)
{
   #
   # Loop through all of the selected tests and post their information
   #

   $dates = split(",",$datetime);

   #
   # If there is more than one test selected, then do not allow the information
   # to be writable
   #
   $writable = ( count($dates) == 1 ) ? '1' : '0';

   for ( $i=0; $i<count($dates); $i++ )
   {
      # date|time|user|test_num|testtype_num
      $datefield = split("\|",$dates[$i]);

      PostTestTable($dates[$i],$datefield[4],$casenum,$writable);

   }
}
#
# Function DB_GetTestComments ##########################################################
#
function DB_GetTestComments($test_num, $testtype_num)
{
   #
   # Gets the test comments for a certain test
   #

   $select = "SELECT comment_type_num, keyword_num, comments ";
   $from = "FROM flask_log_testcomment ";
   $where = "WHERE test_num = '$test_num' and testtype_num = '$testtype_num'";

   # comment_type_num|keyword_num|comments
   return ccgg_query($select.$from.$where);
}

#
# Function PostTestTable ##########################################################
#
function PostTestTable($info,$testtype_num,$casenum,$writable)
{
   #
   # Post the test table, tried to make this as general as possible
   # but with code specific for a test grouped together 
   #

   global $alltestinfo;
   global $commentinfo;
   global $table;

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);

   $disabled = ( $writable == '1' ) ? '' : 'DISABLED';

   for ( $i=0; $i<count($alltestinfo); $i++ )
   {
      # flask_log_testtype:num|name
      $tmp = split("\|",$alltestinfo[$i]);
      if ( $testtype_num == $tmp[0] )
      {
         JavaScriptCommand("document.mainform.table.value = 'flask_log_t$tmp[0]'");
         $table = "flask_log_t$tmp[0]";
         $title = $tmp[1];
         continue;
      }
   }

   # date|time|user|test_num|testtype
   $infofield = split("\|",$info);
   $date = ( isset($infofield[0]) ) ? $infofield[0] : '';
   $time = ( isset($infofield[1]) ) ? $infofield[1] : '';
   $user = ( isset($infofield[2]) ) ? $infofield[2] : '';
   $infofield[3] = ( isset($infofield[3]) ) ? $infofield[3] : '';
   $infofield[4] = ( isset($infofield[4]) ) ? $infofield[4] : '';

   #
   # Get the test comments for this test
   #
   $testcomment = DB_GetTestComments($infofield[3], $infofield[4]);

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

   switch ( $testtype_num )
   {
      case '1':
         #
         # This is for the 24 hour test
         #
         $select = "SELECT spike ";
         $from = "FROM flask_log_t1 ";
         $where = "WHERE date = '$date' AND time = '$time' AND case_num = '$casetmp[0]'";
         $spike = ccgg_query($select.$from.$where);
         $spike[0] = ( isset($spike[0]) ) ? $spike[0] : '0';
         echo "<TR>";
         echo "<TD>";
         echo "<FONT class='MediumBlackB'>Spike</FONT>";
         echo "</TD>";
         echo "<TD>";
         $value = sprintf("%.2e",$spike[0]);
         if ( $writable == '1' )
         {
            echo "<INPUT type=text align=right class='MediumBlackN' name='flask_log_t1:spike' value='$value' size='10' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' MAXLENGTH=12>";
         }
         else
         {
            echo "<FONT class='MediumBlackB'>$value</FONT>";
         }
         echo "</TD>";
         echo "</TR>";
         break;
   }


   #
   # $i = 0 is where flask_log_commenttype.num = 1 => Symptoms
   # which are displayed when the user has only selected a flask ID and a case
   #
   for ( $i=1; $i<count($commentinfo); $i++ )
   {
      $comments = '';
      $keyword_num = '';

      # comment_type:num|name
      $field = split("\|",$commentinfo[$i]);

      for ( $j=0; $j<count($testcomment); $j++ )
      {
         # flask_log_testcomment:comment_type_num|keyword_num|comments
         $tmp = split("\|",$testcomment[$j]);

         if ( $field[0] == $tmp[0] )
         {
            $keyword_num = $tmp[1];
            $comments = $tmp[2];
            continue;
         }
      }

      if ( $keyword_num != '' || $writable == '1' )
      {   
         PostTestComments($keyword_num, $comments, $field[0], $field[1], $writable);
      }
   }
   echo "</TR>";
}

#
# Function PostTestComments ##########################################################
#
function PostTestComments($keyword_num, $comments, $type_num, $type, $writable)
{
   #
   # A general function that posts a colored bar, keyword select list, and a textarea
   #
   
   global $table;

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
      echo "<SELECT NAME='$table:keyword_num:$type_num' class='MediumBlackN' SIZE=1>";

      echo "<OPTION VALUE=''>Select Keyword</OPTION>";
      for ( $k=0; $k<count($keyinfo); $k++ )
      {
         #
         # flask_log_keyword:num|name|comments
         #
         $keyfield = split("\|",$keyinfo[$k]);
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
         # flask_log_keyword:num|name|comments
         #
         $keyfield = split("\|",$keyinfo[$k]);
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
   echo "<TR><TD colspan=4>";

   #
   # If the table is writable, then show a textarea. Otherwise just write it out as text
   #
   if ( $writable == '1' )
   {
      echo "<TEXTAREA class='MediumBlackN' name='$table:comments:$type_num' cols=120 rows=3 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
      echo $comments;
      echo "</TEXTAREA>";
   }
   else
   {
      $comments = htmlentities($comments);
      echo "<FONT class='MediumBlackN'>$comments</FONT>";
   }
   echo "</TD>";
}

#
# Function PostCaseTable ########################################################
#
function PostCaseTable($flaskid,$casenum)
{
   #
   # Post a case table with the appropriate information
   #

   global $caseinfo;
   global $commentinfo;

   $today = date("Y-m-d");
   JavaScriptCommand("document.mainform.table.value = 'flask_log_case'");

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);

   for ($i=0; $i<count($caseinfo); $i++)
   {
      #
      #num|date_in|date_out|keyword_num|comments
      #
      $tmp=split("\|",$caseinfo[$i]);
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
      $tmp=split("\|",$commentinfo[$i]);
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
   echo "<TR>";
   echo "<TD  ALIGN='left' colspan=2 bgcolor='#FFCC99'>";
   echo "<FONT class='MediumBlackB'>$comment_type</FONT>";
   echo "</TD><TD  ALIGN='left' colspan=2 bgcolor='#FFCC99'>";
   echo "<SELECT NAME='flask_log_case:keyword_num' class='MediumBlackN' SIZE=1>";

   #
   # Display the keyword select list
   # comment_type_num = 1 is Symptoms
   #

   $keyinfo = DB_GetKeyList('1');
   echo "<OPTION VALUE=''>Select Keyword</OPTION>";
   for ( $i=0; $i<count($keyinfo); $i++ )
   {
      #
      # num|name|comments
      #
      $field = split("\|",$keyinfo[$i]);
      $z = sprintf("%s",$field[1]);
      $selected = ( $field[0] == $keyword_num ) ? 'SELECTED' : '';
      echo "<OPTION $selected VALUE='$field[0]'>${z}</OPTION>";
   }

   echo "</SELECT>";
   echo "<TR><TD colspan=4>";
   echo "<TEXTAREA class='MediumBlackN' name='flask_log_case:comments' cols=120 rows=5 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
   if ( isset($comments) && !empty($comments) ) { echo $comments; }
   echo "</TEXTAREA>";
   echo "</TD>";
   echo "</TR>";

}
#
# Function DB_GetTestFlaskList() ########################################################
#
function DB_GetTestFlaskList()
{
   #
   # Get a list of flasks in testing
   #

   $select = "SELECT id ";
   $from = "FROM flask_inv ";
   $where = "WHERE sample_status_num = '6' ";
   $order = "ORDER BY id";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetCaseFlaskList() ########################################################
#
function DB_GetCaseFlaskList()
{
   #
   # Get a list of flasks that have previous cases
   #

   $select = "SELECT DISTINCT id ";
   $from = "FROM flask_log_case ";
   $order = "ORDER BY id";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetAllCommentType() ########################################################
#
function DB_GetAllCommentType()
{
   #
   # Get the list of comment types: Symptoms, Diagnosis, Treament, etc...
   #

   $select = "SELECT num, name ";
   $from = "FROM flask_log_commenttype ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetKeyList() ########################################################
#
function DB_GetKeyList($num)
{
   #
   # Get a list of keywords based on the comment type
   #

   $select = "SELECT num, name, comments ";
   $from = "FROM flask_log_keyword ";
   $where = "WHERE comment_type_num = '$num' ";
   $order = "ORDER BY name";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetAllTestList() ########################################################
#
function DB_GetAllTestList()
{
   #
   # Get a list of all the types of tests
   #

   $select = "SELECT num, name ";
   $from = "FROM flask_log_testtype ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetCases() #####################################################
#
function DB_GetCases($id)
{
   #
   # Get a list of all the cases associated with a given case
   #

   $select = "SELECT num, date_in, date_out, keyword_num, comments ";
   $from = "FROM flask_log_case ";
   $where = "WHERE id = '${id}' ";
   $order = "ORDER BY date_in DESC";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetTests ##############################################################
#
function DB_GetTests($casenum)
{
   #
   # Get a list of all the tests associated with a case
   # The trick is that the tests are listed in separate tables called
   # flask_log_t#. So, we need to get the list of all possible testtype_nums
   # and then make the table name 'flask_log_t#'. Lastly, we look in that
   # table to find out if there are any tests associated with the current case
   # number
   #

   $testinfo = array();

   $sql = "SELECT num FROM flask_log_testtype";
   $test_nums = ccgg_query($sql);

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);

   for ($i=0; $i<count($test_nums); $i++)
   {
      $select = "SELECT date, time, user, num ";
      $from = "FROM flask_log_t".$test_nums[$i]." ";
      $where = "WHERE case_num = '$casetmp[0]'";

      $tmpinfo = ccgg_query($select.$from.$where);

      for ( $j=0; $j<count($tmpinfo); $j++ )
      {
         $tmpinfo[$j] = $tmpinfo[$j]."|".$test_nums[$i];
      }

      $testinfo = array_merge($testinfo,$tmpinfo);
   }

   #
   # Reverse sort so that the most recent is on top
   #
   rsort($testinfo);

   return $testinfo;
}
#
# Function DB_UpdateInfo ##############################################################
#
function DB_UpdateInfo($task,$table,$flaskid,$casenum,$datetime,$newtest,$saveinfo)
{
   global $casenum;

   $today = date("Y-m-d");
   $now = date("H:i:s");
   $sql = '';
   $darray = Array();

   #
   # Get the user id
   #
   $user = GetUser();

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);
   
   if ( $datetime != '' && $newtest == '' )
   {
      # Updating past test
      #
      # Variable: datefield
      # date|time|user|test_num|testtype
      #
      $datefield = split("\|",$datetime);

      #
      # Variable: infofield
      # Example: keyword_num:2~1|comments:2~123|keyword_num:3~2|comments:3~425
      #
      $infofield = split("\|",$saveinfo);

      for ( $i=0; $i<count($infofield); $i++ )
      {
         #
         # Variable: tmp
         # Example: keyword_num:2~1
         #
         $tmp = split("\~",$infofield[$i]);

         #
         # Variable: field
         # Example: keyword_num:2
         #
         $field = split(":",$tmp[0]);

         if ( $tmp[0] == 'spike' )
         {
            $sql = "UPDATE $table SET spike = '$tmp[1]' WHERE num = '$datefield[3]'";

            #echo "$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) { return(FALSE); }
         }
         else
         {
            #
            # search: darray12345
            # There was a problem between the way that we save the page
            # data and the way we input the data into the database. When data
            # is saved from the page using javascript, all the information
            # is pipe delimited. But when we input the data into the database
            # two things had to be entered at the same time (keyword_num and comments).
            # To solve this problem, a step was inserted between raw data and data
            # input. We loop through the raw data one line at a time,
            # if we see the word 'keyword_num' then a new entry is added
            # to darray(). When we see the word 'comments', there must be
            # a keyword. So, we loop through darray() matching the
            # comment_type_num. In the end, we have an array with multiple
            # entries but each line has all the information we need
            # to insert at one time (meaning, all the information we need
            # to make one insert call)
            #
            if ( $field[0] == 'keyword_num' )
            {
               $darray[count($darray)] = $datefield[3]."|".$datefield[4]."|".$field[1]."|".$field[0]."~".$tmp[1];
            }
            elseif ( $field[0] == 'comments' )
            {
               for ( $j=0; $j<count($darray); $j++ )
               {
                  #
                  # Variable: arrayfield
                  # Example: test_num|testtype_num|comment_type_num|keyword_num~1
                  #
                  $arrayfield = split("\|",$darray[$j]);

                  #
                  # Match the comments with the appropriate keyword based on
                  # comment_type_num. There cannot be a comment without a keyword
                  # but there can be a keyword without a comment
                  #
                  if ( $arrayfield[2] == $field[1] )
                  {
                     $darray[$j] = $darray[$j]."|".$field[0]."~".$tmp[1];
                  }
               }
            }
         }
      }

      for ( $i=0; $i<count($darray); $i++ )
      {
         #
         # test_num|testtype_num|comment_type_num|keyword_num~<data>|comments~<data>
         #
         $dfield = split("\|",$darray[$i]);
         $keyfield = split("~",$dfield[3]);
         $commentfield = split("~",$dfield[4]);
         $commentfield[1] = addslashes($commentfield[1]);

         #
         # Find out if there exists an entry for the information that we are trying
         # to insert
         #
         $sql = "SELECT * FROM flask_log_testcomment WHERE test_num = '$dfield[0]' AND testtype_num = '$dfield[1]' AND comment_type_num = '$dfield[2]'";
         $res = ccgg_query($sql);

         if ( $res[0] != '' )
         {
            #
            # Entry exists in the database
            #

            if ( $keyfield[1] != '' )
            {
               #
               ##################
               # Update comment
               ##################
               #
               $update = "UPDATE flask_log_testcomment ";
               $set = "SET keyword_num = '$keyfield[1]' ";
               $set = "${set}, comments = '$commentfield[1]' ";
               $where = "WHERE test_num = '$dfield[0]' AND ";
               $where = "${where} testtype_num = '$dfield[1]' AND ";
               $where = "${where} comment_type_num = '$dfield[2]'";
               $sql = $update.$set.$where;

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               if (!empty($res)) { return(FALSE); }
            }
            else
            {
               #
               ##################
               # Delete comment
               ##################
               #
               $delete = "DELETE FROM flask_log_testcomment ";
               $where = "WHERE test_num = '$dfield[0]' AND ";
               $where = "${where} testtype_num = '$dfield[1]' AND ";
               $where = "${where} comment_type_num = '$dfield[2]'";
               $sql = $delete.$where;

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               if (!empty($res)) { return(FALSE); }
            }
         }
         else
         {
            #
            ##################
            # Insert comment
            ##################
            #

            # 
            # Only insert if there is a keyword set
            #
            if ( $keyfield[1] != '' )
            {
               $sql = "INSERT INTO flask_log_testcomment VALUES ('$dfield[0]','$dfield[1]','$dfield[2]','$keyfield[1]','$commentfield[1]')";

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               if (!empty($res)) { return(FALSE); }
            }
         }
      }
   }
   elseif ( $newtest != '' && $datetime == '' )
   {
      #
      ##################
      # Adding new test
      ##################
      #
      $test_num = '';

      #
      # Variable: infofield
      # Example: keyword_num:2~1|comments:2~123|keyword_num:3~2|comments:3~425
      #
      $infofield = split("\|",$saveinfo);

      for ( $i=0; $i<count($infofield); $i++ )
      {
         #
         # Variable: tmp
         # Example: keyword_num:2~1
         #
         $tmp = split("\~",$infofield[$i]);

         #
         # Variable: field
         # Example: keyword_num:2
         #
         $field = split(":",$tmp[0]);

         if ( $tmp[0] == 'spike' )
         {
            $sql = "INSERT INTO $table VALUES ('','$casetmp[0]','$user','$today','$now','$tmp[1]')";
            #echo "$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) { return(FALSE); }
            $test_num = mysql_insert_id();
         }
         else
         {
            #
            # Search for 'darray12345' for a long comment about what this
            # section does
            #
            if ( $field[0] == 'keyword_num' )
            {
               $darray[count($darray)] = $field[1]."|".$field[0]."~".$tmp[1];
            }
            elseif ( $field[0] == 'comments' )
            {
               for ( $j=0; $j<count($darray); $j++ )
               {
                  #
                  # Variable: arrayfield
                  # Example: comment_type_num|keyword_num~1
                  #
                  $arrayfield = split("\|",$darray[$j]);
                  if ( $arrayfield[0] == $field[1] )
                  {
                     $darray[$j] = $darray[$j]."|".$field[0]."~".$tmp[1];
                  }
               }
            }
         }
      }

      #
      # If a new entry for flask_log_t# was not entered, then do it now and
      # grab the auto-incremented number
      #
      if ( $test_num == '' )
      {
         $sql = "INSERT INTO $table VALUES ('','$casetmp[0]','$user','$today','$now')";

         #echo "$sql<BR>";
         $res = ccgg_insert($sql);
         if (!empty($res)) { return(FALSE); }
         $test_num = mysql_insert_id();
      }

      for ( $i=0; $i<count($darray); $i++ )
      {
         #
         # comment_type_num|keyword_num~<data>|comments~<data>
         #
         $dfield = split("\|",$darray[$i]);
         $keyfield = split("~",$dfield[1]);
         $commentfield = split("~",$dfield[2]);
         $commentfield[1] = addslashes($commentfield[1]);

         #
         # If the keyword is not set, then do not insert an entry into the database
         #
         if ( $keyfield[1] != '' )
         {
            $insert = "INSERT INTO flask_log_testcomment ";
            $values = "VALUES ('$test_num','$newtest','$dfield[0]','$keyfield[1]','$commentfield[1]')";
            $sql = $insert.$values;
            #echo "$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) { return(FALSE); }
         }
      }

   }
   else
   {
      $dfield = split("\|",$saveinfo);
      for ( $i=0; $i<count($dfield); $i++ )
      {
         $tmp = split("\~",$dfield[$i]);
         if ( $tmp[0] == 'keyword_num' ) { $keyword_num = $tmp[1]; }
         if ( $tmp[0] == 'comments' ) { $comments = addslashes($tmp[1]); }
      }

      #
      #################
      # Updating case
      #################
      #
      if ( $casetmp[0] == "Add" )
      {
         $sql = "INSERT INTO $table VALUES ('','$flaskid','$today','','$keyword_num','$comments')";

         #echo "$sql<BR>";
         $res = ccgg_insert($sql);
         if (!empty($res)) { return(FALSE); }
      }
      else
      {
         $update = "UPDATE $table ";
         $set = "SET date_in = '$casetmp[1]', date_out = '$casetmp[2]', ";
         $set = "${set} keyword_num = '$keyword_num', comments = '$comments' ";
         $where = "WHERE num = '$casetmp[0]'";
         $sql = $update.$set.$where;

         #echo "$sql<BR>";
         $res = ccgg_insert($sql);
         if (!empty($res)) { return(FALSE); }
      }


      #
      # After we insert a new case, we have to set $casenum so that
      # the right case is selected when the page loads up again
      #
      if ( $casetmp[0] == "Add" )
      {
         $case_num = mysql_insert_id();
         $casenum = "$case_num~$today~0000-00-00";
      }
   }
   return(TRUE);
}

#
# Function DB_CloseCase ##############################################################
#
function DB_CloseCase($table,$flaskid,$casenum)
{
   #
   # Close a case, which means setting a date_out
   #

   global $casenum;
   $today = date("Y-m-d");

   #
   #Variable: casetmp
   #Contents: num~date_in`date_out
   #
   $casetmp = split("~",$casenum);

   $update = "UPDATE flask_log_case ";
   $set = "SET date_out = '$today' ";
   $where = "WHERE num = '$casetmp[0]' AND date_in = '$casetmp[1]' AND id = '$flaskid'";
   $sql = $update.$set.$where;

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); }
   $casenum = "$casetmp[0]~$casetmp[1]~$today";
   return(TRUE);
}
?>
