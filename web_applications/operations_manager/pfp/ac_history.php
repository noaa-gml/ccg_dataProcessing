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
$sitenum = isset( $_POST['sitenum'] ) ? $_POST['sitenum'] : '';
$casenum = isset( $_POST['casenum'] ) ? $_POST['casenum'] : '';
$datetime = isset( $_POST['datetime'] ) ? $_POST['datetime'] : '';
$newcomment = isset( $_POST['newcomment'] ) ? $_POST['newcomment'] : '';
$newcase = isset( $_POST['newcase'] ) ? $_POST['newcase'] : '';
$saveinfo = isset( $_POST['saveinfo'] ) ? $_POST['saveinfo'] : '';

$strat_name = 'PFP';
$strat_abbr = 'pfp';
$proj_abbr = 'ccg_aircraft';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='ac_history.js'></SCRIPT>";

#
# After the user submits the page, check $task to determine what the user
#    wanted to do.
#

if ( $task == 'add' )
{
   #
   # Add a new case or comment
   #
   DB_AddInfo($sitenum, $newcase, $newcomment, $saveinfo);

   $newcase = '';
   $newcomment = '';
   $task = '';
}
elseif ( $task == 'update' )
{

   #
   # Update a comment
   #
   if ( !(DB_UpdateInfo($sitenum,$casenum,$datetime,$saveinfo)))
   {
      JavaScriptAlert("Unable to update DB");
   }

   #
   # Clear task variable so that update only occurs once
   #
   $task = '';
   $datetime = '';
   $saveinfo = '';
}
elseif ( $task == 'delete' )
{
   #
   # Delete a comment
   #
   if ( !(DB_DeleteInfo($sitenum,$casenum,$datetime)))
   {
      JavaScriptAlert("Unable to delete from DB");
   }
   #
   # Clear task variable so that delete only occurs once
   #
   $task = '';
   $datetime = '';
   $saveinfo = '';
}
else
{
   if ( $task != '' ) { JavaScriptAlert("Invalid Task"); }
   $task = '';
}

$siteinfo = DB_GetSiteList($proj_abbr, $strat_abbr);
$keyinfo = DB_GetKeyList();

#
# Get lots of information from the database that we need to make select lists
#
$caseinfo = '';
$loginfo = '';
                                                                                          
if ( $sitenum != '' )
{
   $caseinfo = DB_GetCases($sitenum);

   if ( $casenum != '' )
   {
      $loginfo = DB_GetEntries($casenum);
   }
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $siteinfo;
   global $keyinfo;
   global $caseinfo;
   global $loginfo;
   global $saveinfo;
   global $sitenum;
   global $casenum;
   global $datetime;
   global $newcomment;
   global $newcase;

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='sitenum' VALUE='${sitenum}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='casenum' VALUE='${casenum}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='datetime' VALUE='${datetime}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='newcomment' VALUE='${newcomment}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='newcase' VALUE='${newcase}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='saveinfo' VALUE='${saveinfo}'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Aircraft Site Log";
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

   #
   ############################
   # Site List
   ############################
   #
   echo "<TD align='left' valign='top' width='30%'>";
   echo "<FONT class='MediumBlackN'>Select Site:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='1' onChange='ListSelectCB(this)'>";

   echo "<OPTION class='MediumBlackN' VALUE=''>---</OPTION>";
   for ($i=0; $i<count($siteinfo); $i++)
   {
      # $siteinfo
      # num|code
      $tmp=split("\|",$siteinfo[$i]);
      $selected = (!(strcasecmp($tmp[0],$sitenum))) ? 'SELECTED' : '';
      $z = sprintf("%s",$tmp[1]);
      echo "<OPTION class='MediumBlackN' $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }

   echo "</SELECT>";
   echo "</TD>";

   #
   ############################
   # Case List
   ############################
   #
   echo "<TD align='left' valign='top' width='30%'>";
   $class = ( $sitenum != '' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select Case:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='caselist' SIZE='4' onClick='ListSelectCB(this)'>";

   echo "<OPTION VALUE='Add'>Add Case</OPTION>";
   for ($i=0; $i<count($caseinfo); $i++)
   {
      # $caseinfo
      # case_num|date
      $tmp=split("\|",$caseinfo[$i]);
      $selected = ( $tmp[0] == $casenum ) ? 'SELECTED' : '';
      $z = sprintf("%s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</DIV>";

   $class = ( $sitenum != '' && $casenum != '' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<INPUT TYPE='button' name='allimage' class='Btn' value='All Images' onClick='ShowImageCB(\"\",\"all\")'>";
   echo "</DIV>";
   
   echo "</TD>";

   #
   ############################
   # Log Entry List
   ############################
   #
   echo "<TD align='left' valign='top' width='40%'>";

   $class = ( $sitenum != '' && $casenum != '' ) ? '' : 'Hidden';
   echo "<DIV class='$class'>";
   echo "<FONT class='MediumBlackN'>Select Log Entry:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='loglist' SIZE='4' MULTIPLE>";

   $datearr = split(",",$datetime);
   for ($i=0; $i<count($loginfo); $i++)
   {
      # $loginfo
      # date|time|user|ac_log_key_num|ac_log_key.name|entry
      $tmp=split("\|",$loginfo[$i]);

      $selected = ( in_array("$tmp[0]~$tmp[1]",$datearr) ) ? 'SELECTED' : '';

      $z = sprintf("%s - %s (%s)",$tmp[4], $tmp[0], $tmp[1]);
      echo "<OPTION class='MediumBlackN' $selected VALUE='$tmp[0]~$tmp[1]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "<BR>";

   #
   # Button used to show tests
   #
   echo "<DIV align=left>";
   echo "<INPUT TYPE='button' class='Btn' value='Show' onClick='ShowEntryCB()'>";
   echo "<INPUT TYPE='button' name='addlog' class='Hidden' value='Add' onClick='NewLogCB()'>";
   echo "</DIV>";
   echo "</DIV>";
   echo "</TD>";
   echo "</TR>";

   if ( $sitenum != '' & $casenum != '' )
   {
      if ( $datetime != '' && $newcomment == '' )
      {
         #
         # Show old tests
         #
         echo "<TR>";
         echo "<TD colspan=4 align=center class='LargeBlueB'><HR>Log Entry</TD>"; 
         echo "</TR>";
         PostPastLog($datetime,$casenum);
      }
      elseif ( $datetime == '' && $newcomment != '' )
      {
         #
         # Show new test
         #
         $writable = 1;
         echo "<TR>";
         echo "<TD colspan=4 align=center class='LargeBlueB'><HR>New Log Entry</TD>"; 
         echo "</TR>";
         PostLogTable('',$casenum,$writable);
      }
      else
      {
         echo "<TR>";
         echo "<TD colspan=4 align=center class='LargeBlueB'><HR></TD>"; 
         echo "</TR>";
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
   if ( $casenum != '' )
   {
      #
      # If a new comment is going to be added
      #
      if ( $newcomment != '' )
      {
         echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Add' onClick='AddCB()'>";
         echo "</TD>";
         echo "<TD align='center'>";
         echo "<INPUT TYPE='button' name='clear' class='Btn' value='Clear' onClick='ClearCB()'>";
      }
      else
      {
         if ( count($dates) < 2 && $dates[0] != '' )
         {
            echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Update' onClick='UpdateCB()'>";
            echo "</TD>";
            echo "<TD align='center'>";
            echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Delete' onClick='DeleteCB()'>";
         }
      }
      echo "</TD>";

   }

   if ( $sitenum != '' )
   {
      if ( $casenum != '' && $newcomment == '' )
      {
         JavaScriptCommand('document.mainform.addlog.className = \'Btn\'');
      }
   }

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
   echo "</TD>";

   echo "</TABLE>";
   echo "</BODY>";
   echo "</HTML>";
}

#
# Function PostPastLog ##########################################################
#
function PostPastLog($datetime,$casenum)
{
   #
   # Loop through all of the selected tests and post their information
   #
   global $loginfo;

   $dates = split(",",$datetime);

   #
   # If there is more than one test selected, then do not allow the information
   # to be writable
   #
   $writable = ( count($dates) == 1 ) ? '1' : '0';

   for ( $i=0; $i<count($dates); $i++ )
   {
      # $dates
      # date~time
      $datefield = split("\~",$dates[$i]);

      for ( $j=0; $j<count($loginfo); $j++ )
      {
         # $loginfo
         # date|time|user|ac_log_key_num|ac_log_key.name|entry
         $tmp=split("\|",$loginfo[$j]);

         if ( $datefield[0] == $tmp[0] && $datefield[1] == $tmp[1] )
         {
            PostLogTable($loginfo[$j],$casenum,$writable);
         }
      }
   }
}
#
# Function DB_GetLogEntries ##########################################################
#
function DB_GetLogEntries($test_num, $testtype_num)
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
# Function PostLogTable ##########################################################
#
function PostLogTable($info,$casenum,$writable)
{

   #
   # Post the test table, tried to make this as general as possible
   # but with code specific for a test grouped together 
   #

   $disabled = ( $writable == '1' ) ? '' : 'DISABLED';

   # date|time|user|ac_log_key_num|ac_log_key.name|entry
   $infofield = split("\|",$info);
   $date = ( isset($infofield[0]) ) ? $infofield[0] : '';
   $time = ( isset($infofield[1]) ) ? $infofield[1] : '';
   $user = ( isset($infofield[2]) ) ? $infofield[2] : '';
   $keyword_num = ( isset($infofield[3]) ) ? $infofield[3] : '';
   $comments = ( isset($infofield[5]) ) ? $infofield[5] : '';

   if ( !empty($date) && !empty($time) )
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

   PostLogEntries($keyword_num, $comments, $writable);
   echo "</TR>";
}

#
# Function PostLogEntries ##########################################################
#
function PostLogEntries($keyword_num, $comments, $writable)
{
   #
   # A general function that posts a colored bar, keyword select list, and a textarea
   #
   
   global $keyinfo;

   $disabled = ( $writable == '1' ) ? '' : 'DISABLED';

   echo "<TR><TD colspan=3>";
   echo "<TABLE width='100%' align='center' cellpadding='0' cellspacing='0'>";

      echo "<TR>";
      echo "<TD ALIGN='left' width='50%' bgcolor='#FFCC99'>";
      echo "<FONT class='MediumBlackB'>Log Entry</FONT>";
      echo "</TD>";
      echo "<TD ALIGN='left' width='25%' bgcolor='#FFCC99'>";
      if ( $writable == '1' )
      {
         #
         # If we allow the table to be writable, display the keyword select list
         #
         echo "<SELECT NAME='info:ac_log_key_num' class='MediumBlackN' SIZE=1>";

         echo "<OPTION VALUE=''>Select Keyword</OPTION>";
         for ( $k=0; $k<count($keyinfo); $k++ )
         {
            # $keyinfo
            # num|name
            $keyfield = split("\|",$keyinfo[$k]);
            $z = sprintf("%s",$keyfield[1]);
            $selected = ( $keyfield[0] == $keyword_num ) ? 'SELECTED' : '';
            echo "<OPTION $selected VALUE='$keyfield[0]'>${z}</OPTION>";
         }

         echo "</SELECT>";
         echo "</TD>";
         echo "<TD ALIGN='right' width='25%' bgcolor='#FFCC99'>";
         echo "<INPUT TYPE='button' name='showpic' class='Btn' value='Images' onClick='ShowImageCB(\"\",\"one\")'>";
      }
      else
      {
         #
         # If the table is not suppose to writable, then just display the keyword
         #
         for ( $k=0; $k<count($keyinfo); $k++ )
         {
            # $keyinfo
            # num|name
            $keyfield = split("\|",$keyinfo[$k]);
            if ( $keyfield[0] == $keyword_num )
            {
               $keyword_name = $keyfield[1];
               continue;
            }
         }
         echo "<FONT class='MediumBlackN'>$keyword_name</FONT>";
         echo "</TD>";
         echo "<TD ALIGN='right' width='25%' bgcolor='#FFCC99'>";
         $tmp = str_replace(" ","_", $keyword_name);
         echo "<INPUT TYPE='button' name='showpic' class='Btn' value='Images' onClick='ShowImageCB(\"$tmp\",\"one\")'>";
      
      }
      echo "</TD>";
      echo "</TR>";
   echo "</TABLE>";
   echo "</TD>";
   echo "</TR>";
   echo "<TR><TD colspan=3>";

   #
   # If the table is writable, then show a textarea. Otherwise just write it out as text
   #
   if ( $writable == '1' )
   {
      echo "<TEXTAREA class='MediumBlackN' name='info:entry' cols=120 rows=5 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
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
# Function DB_GetCases() #####################################################
#
function DB_GetCases($sitenum)
{
   $select = "SELECT num, date ";
   $from = "FROM ac_log_case ";
   $where = "WHERE site_num = '${sitenum}' ";
   $order = "ORDER BY date DESC";
                                                                                          
   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetEntries() #####################################################
#
function DB_GetEntries($casenum)
{

   $select = "SELECT date, time, user, ac_log_key_num, ac_log_key.name, entry ";
   $from = "FROM ac_log, ac_log_key ";
   $where = "WHERE case_num = '$casenum' ";
   $where = "${where} AND ac_log.ac_log_key_num = ac_log_key.num ";
   $order = "ORDER BY ac_log_key.name, date DESC, time DESC";
                                                                                          
   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetKeyList() ########################################################
#
function DB_GetKeyList()
{
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT num, name ";
   $from = "FROM ac_log_key ";
                                                                                          
   return ccgg_query($select.$from);
}
#
# Function DB_AddInfo ##############################################################
#
function DB_AddInfo($sitenum, $newcase, $newcomment, $saveinfo)
{
   global $casenum;

   $user = GetUser();

   $today = date("Y-m-d");
   $now = date("H:i:s");

   if ( $newcase != '' && $newcomment == '' )
   {
      $sql = "SELECT COUNT(*) FROM ac_log_case WHERE date = '$today' AND site_num = '$sitenum'";

      $res = ccgg_query($sql);
       
      if ( $res[0] == '0' )
      {
         $sql = "INSERT INTO ac_log_case VALUES ('','$sitenum','$today')";
         $res = ccgg_insert($sql);
         if (strcmp($res,"")) { return(FALSE); }
      
         $last = mysql_insert_id();
         $casenum = $last;
      }
      else
      {
         JavaScriptAlert("Current date already exists in database");
         return(FALSE);
      }

      #
      # Create the directory for the images
      #
      $sitecode = strtolower(DB_GetSiteCode($sitenum));

      $filename = '/projects/aircraft/'.$sitecode.'/images/log/'.$today;

      if (!(file_exists($filename)))
      {
         #echo "The file $filename does not exist";
         $old_umask = umask(0);
         makeDirs($filename);
         umask($old_umask);
      }
      else
      {
         #echo "The file $filename exists";
      }
      
   }
   elseif ( $newcase == '' && $newcomment != '' )
   {
      #JavaScriptAlert($newcase." ".$newcomment." ".$saveinfo);
      $savetmp = split("\|",$saveinfo);

      for ( $i=0; $i<count($savetmp); $i++ )
      {
         $field = split("~",$savetmp[$i]);
         switch ($field[0])
         {
            case "ac_log_key_num":
               $keynum = $field[1];
               break;
            case "entry":
               $entry = addslashes($field[1]);
               break;
         }
      }

      $insert = "INSERT INTO ac_log ";
      $values = "VALUES ('$casenum','$keynum','$user','$today','$now','$entry')";

      $sql = $insert.$values;
      #echo "$sql\n";
      #JavaScriptAlert($sql);

      $res = ccgg_insert($sql);
      if (strcmp($res,"")) { return(FALSE); }
      
   }

   return(TRUE);
}
#
# Function DB_UpdateInfo ##############################################################
#
function DB_UpdateInfo($sitenum,$casenum,$datetime,$saveinfo)
{
   $today = date("Y-m-d");
   $now = date("H:i:s");
   $sql = '';

   #
   # Get the user id
   #
   $user = GetUser();

   $datefield = split("~",$datetime); 

   $savetmp = split("\|",$saveinfo);

   $set = '';
   for ( $i=0; $i<count($savetmp); $i++ )
   {
      $field = split("~",$savetmp[$i]);

      $field[1] = addslashes($field[1]);
      if ( $set == '' )
      {
         $set = "SET $field[0] = '$field[1]'";
      }
      else
      {
         $set = $set.", $field[0] = '$field[1]'";
      }
   }
  
   $where = "WHERE date = '$datefield[0]' AND time ='$datefield[1]'";
   $where = "{$where} AND case_num = '$casenum'";

   $update = "UPDATE ac_log ";
   $set = "{$set}, user = '$user', date = '$today', time = '$now' ";

   $sql = $update.$set.$where;

   #echo "$sql\n";
   #JavaScriptAlert($sql);

   $res = ccgg_insert($sql);
   if (strcmp($res,"")) { return(FALSE); }

   return(TRUE);
}

#
# Function DB_DeleteInfo ##############################################################
#
function DB_DeleteInfo($sitenum,$casenum,$datetime)
{
   $datefield = split("~",$datetime); 

   $delete = "DELETE FROM ac_log ";
   $where = "WHERE date = '$datefield[0]' AND time ='$datefield[1]'";
   $where = "{$where} AND case_num = '$casenum'";

   $sql = $delete.$where;

   #echo "$sql\n";
   #JavaScriptAlert($sql);

   $res = ccgg_delete($sql);
   if (strcmp($res,"")) { return(FALSE); }

   return(TRUE);
}

#
# Function makeDirs
#
function makeDirs($strPath, $mode = 0777) //creates directory tree recursively
{
   return is_dir($strPath) or ( makeDirs(dirname($strPath), $mode) and mkdir($strPath, $mode) ) and chmod($strPath, $mode);
}
?>
