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
$unit_id = isset( $_POST['unit_id'] ) ? $_POST['unit_id'] : '';
$datetime = isset( $_POST['datetime'] ) ? $_POST['datetime'] : '';
$sitenum = isset( $_POST['sitenum'] ) ? $_POST['sitenum'] : '';
$projnum = isset( $_POST['projnum'] ) ? $_POST['projnum'] : '';
$commentsave = isset( $_POST['commentsave'] ) ? $_POST['commentsave'] : '';
$keysave = isset( $_POST['keysave'] ) ? $_POST['keysave'] : '';

$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : '';
$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : '';
$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

if ( empty($strat_abbr ) ) { $strat_abbr = 'flask'; }
if ( empty($strat_name ) ) { $strat_name = 'Flask'; }

if ( empty($proj_abbr) ) { $proj_abbr = "ccg_surface"; }

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_elog.js'></SCRIPT>";

#JavaScriptAlert($unitid);

#
# After the user submits the page, check $task to determine what the user
#    wanted to do.
#

if ( $task == 'add' || $task == 'update' )
{
   #
   # Add a new log comment
   #
   if (!(DB_UpdateInfo($task,$unit_id,$datetime,$sitenum,$projnum,$commentsave,$keysave)))
   {
      JavaScriptAlert("Unable to add log to DB");
   }
   #
   # Clear variables so that the unit history comes up
   #    and the task is reset
   #
   $datetime = '';
   $task = '';
}

#
# Get a list of all the active units from the database
#
$unitinfo = DB_GetAllUnitList();
$siteinfo = DB_GetAllSiteInfo("",$strat_abbr);

$prevcode = '123';
for ($i=0; $i<count($siteinfo); $i++)
{
   $tmp = split("\|", $siteinfo[$i]);

   if ( $tmp[1] == $prevcode ) { unset($siteinfo[$i]); }
   else { $prevcode = $tmp[1]; }
}
$siteinfo = array_values($siteinfo);


#
# If an unit is selected, then find the list of components linked
#   to that unit
#
if ( $unit_id != '' )
{
   $dateinfo = DB_GetDates($unit_id);
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $proj_abbr;
   global $unit_id;
   global $datetime;
   global $unitinfo;
   global $siteinfo;
   global $dateinfo;
   global $commentsave;
   global $sitenum;
   global $projnum;
   global $keysave;
   global $gen_type_abbr;

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='unit_id' VALUE='${unit_id}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='datetime' VALUE=${datetime}>";
   echo "<INPUT TYPE='HIDDEN' NAME='sitenum' VALUE=${sitenum}>";
   echo "<INPUT TYPE='HIDDEN' NAME='projnum' VALUE=${projnum}>";
   echo "<INPUT TYPE='HIDDEN' NAME='commentsave' VALUE='${commentsave}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='keysave' VALUE='${keysave}'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} History Manager</TD>";
   echo "</TR>";
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
   echo "<TD align='center' valign='top' width='50%'>";
   echo "<FONT class='MediumBlackN'>Select Unit:<FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='unitlist' SIZE='1' onChange='ListSelectCB(this)'>";

   #
   # Display the list of active units
   #
   echo "<OPTION VALUE=''>---</OPTION>";
   for ($i=0; $i<count($unitinfo); $i++)
   {
      $tmp=split("\|",$unitinfo[$i]);
      $selected = (!(strcasecmp($tmp[0],$unit_id))) ? 'SELECTED' : '';
      $z = $tmp[0];
      echo "<OPTION class='MediumBlackN' $selected VALUE='${z}'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD>";

   #
   # Make sure an unit has been selected before we display this table
   #
   echo "<TD align='center' width='50%'>";
   $class = ( $unit_id != '' ) ? '' : 'Hidden';
   echo "<DIV class=$class>";

   echo "<TABLE border='0' cellpadding='0' cellspacing='0'>";
   echo "<TR><TD>";
   echo "<FONT class='MediumBlackN'>Select Problem:</FONT><BR>";
   echo "</TD></TR>";
   echo "<TR><TD>";
   echo "<SELECT class='MediumBlackN' NAME='datelist' SIZE='4' onChange='ListSelectCB(this)'>";

   #
   # Display the list of active units
   #
   if ( $datetime == "Add" )
   {
      $selected = 'SELECTED';
   }
   else
   {
      $selected = '';
   }
   echo "<OPTION VALUE='Add' $selected>New Problem</OPTION>";

   $field = split("~",$datetime);
   for ($i=0; $i<count($dateinfo); $i++)
   {
      $tmp=split("\|",$dateinfo[$i]);
      if ( $field[0] == $tmp[0] && $field[1] == $tmp[1] )
      {
         $selected = 'SELECTED';
      }
      else
      {
         $selected = '';
       }
      $z = sprintf("%s (%s) - %s",$tmp[0],$tmp[1],$tmp[2]);
      echo "<OPTION $selected VALUE='$tmp[0]~$tmp[1]~$tmp[2]~$tmp[3]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD></TR>";
   echo "</TABLE>";
   echo "</DIV>";
   echo "</TD>";
   echo "</TR>";

   #
   # Display editable comment field
   #
   # PostDates($unit_id);
   if ( $unit_id != '' && $datetime != '' )
   {
      echo "<TR><TD>";
      echo "</TABLE>";
                                                                                         
      echo "<TABLE align='center' col=2 width=75% border='0' cellpadding='2' cellspacing='2'>";

      PostForm2Edit($unit_id,$datetime,'Comments');
      
      echo "</TABLE>";

      echo "<TABLE align='center' width=20% border='0' cellpadding='2' cellspacing='2'>";

      echo "<TR>";
      echo "<TD align='center'>";

      #
      # Create the clickable buttons
      #
      if ( $datetime == 'Add' )
      {
         echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Add' onClick='AddCB()'>";
      }
      else
      {
         echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Update' onClick='UpdateCB()'>";
      }
      echo "</TD>";

      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' name='delete' class='Btn' value='Delete' onClick='DeleteCB()'>";
      echo "</TD>";

      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' name='clear' class='Btn' value='Clear' onClick='ClearCB()'>";
      echo "</TD>";

      echo "<TD align='center'>"; echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
      echo "</TD>";
      echo "</TR>";
   }

   echo "</TABLE>";
   echo "</BODY>";
   echo "</HTML>";
}

#
# Function PostTable2Edit ########################################################
#
function PostForm2Edit($unit_id,$datetime,$title)
{
   global $ccgg_equip;
   #
   # Post an editable comment field
   #
   $hline = str_pad('_',50,'_');

   echo "<TR>";
   echo "<TD class='LargeBlackB' COLSPAN=2 ALIGN='center'>${hline}</TD>";
   echo "</TR>";
   echo "<TR>";
   echo "<TD class='LargeBlueB' COLSPAN=2 ALIGN='center'>${title}</TD>";
   echo "</TR>";
   echo "<TR><TD></TD></TR>";
   echo "<TR>";
   echo "</TR>";
   echo "<TR><TD colspan=2>";
   echo "<FONT class='MediumBlackB'>Unit:</FONT>";
   echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$unit_id</FONT>";
   echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

   $tmp = split("\~",$datetime);
   $field[0] = ( isset($tmp[0]) ) ? $tmp[0] : '';
   $field[1] = ( isset($tmp[1]) ) ? $tmp[1] : '';
   $field[2] = ( isset($tmp[2]) ) ? $tmp[2] : '';
   $field[3] = ( isset($tmp[3]) ) ? $tmp[3] : '';
   if ( $datetime != "Add" )
   {
      echo "<FONT class='MediumBlackB'>Date:</FONT>";
      echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$field[0]</FONT>";
      echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackB'>Time:</FONT>";
      echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$field[1]</FONT>";
      echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

      $select = "SELECT user ";
      $from = "FROM ${ccgg_equip}.gen_elog ";
      $where = "WHERE gen_inv_id = '${unit_id}' AND date = '$field[0]' ";
      $where = "${where} AND time = '$field[1]'";
      $usernames = ccgg_query($select.$from.$where);
                                                                                          
      $first = $usernames[0];
      $user = $first;
      for ($i=1; $i<count($usernames); $i++)
      {
         if ( $first != $usernames[$i] )
         {
            $user = "$user, $usernames[$i]";
         }
      }
   }
   else
   {
      $user = GetUser();
   }
   echo "<FONT class='MediumBlackB'>User:</FONT>";
   echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$user</FONT>";
   echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
   echo "<FONT class='MediumBlackB'>Site:</FONT>";
   echo "&nbsp;&nbsp;";
   CreateSiteSelectButton($field[2]);
   echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
   echo "<FONT class='MediumBlackB'>Project:</FONT>";
   echo "&nbsp;&nbsp;";
   CreateProjSelectButton($field[3]);

   echo "</TD></TR>";
   echo "<TR>";

   $commentinfo = DB_GetAllCommentType();
   $keyinfo = DB_GetAllKeyType();

   for ($i=0; $i<count($commentinfo); $i++)
   {
      $tmp=split("\|",$commentinfo[$i]);
      echo "<TR><TD ALIGN='left' width=50% bgcolor='#FFCC99'>";
      echo "<FONT class='MediumBlackB'>$tmp[1]</FONT>";
      echo "</TD><TD  ALIGN='left' width=50% bgcolor='#FFCC99'>";
      echo "<SELECT NAME='keys:$tmp[0]' class='MediumBlackN' SIZE=1>";

      $select = "SELECT gen_elog_key_num ";
      $from = "FROM ${ccgg_equip}.gen_elog ";
      $where = "WHERE gen_inv_id = '${unit_id}' AND date = '$field[0]' ";
      $where = "${where} AND time = '$field[1]' AND gen_elog_type_num = $tmp[0]";
      $keyvalue = ccgg_query($select.$from.$where);

      echo "<OPTION VALUE='-999'>None Selected</OPTION>";

      for ($j=0; $j<count($keyinfo);$j++)
      {
         $keyfield = split("\|",$keyinfo[$j]);
         if ( $keyfield[2] == $tmp[0] )
         {
            $selected = ( $keyfield[0] == $keyvalue[0] ) ? 'SELECTED' : '';
            echo "<OPTION VALUE='$keyfield[0]' $selected>$keyfield[1]</OPTION>";
         }
      }

      echo "</SELECT>";
      echo "</TD></TR>";
      echo "<TR><TD colspan=2>";
      echo "<TEXTAREA class='MediumBlackN' name='comments:$tmp[0]' cols=120 rows=5 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";

      $select = "SELECT entry ";
      $from = "FROM ${ccgg_equip}.gen_elog ";
      $where = "WHERE gen_inv_id = '${unit_id}' AND date = '$field[0]' ";
      $where = "${where} AND time = '$field[1]' AND gen_elog_type_num = $tmp[0]";
      $value = ccgg_query($select.$from.$where);

      if ( isset($value[0]) ) { echo $value[0]; }
      echo "</TEXTAREA></TD></TR>";
      # JavaScriptAlert($select.$from.$where);
      # JavaScriptAlert($value[0]);

   }
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
   $from = " FROM ${ccgg_equip}.gen_inv";
   $where = " WHERE gen_type_num = '${gen_type_num}'";

   if ( $gen_type_num == 1 )
   { $order = " ORDER BY CONVERT(id,SIGNED) DESC"; }
   else
   { $order = " ORDER BY CONVERT(id,SIGNED)"; }

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetDates() #####################################################
#
function DB_GetDates($id)
{
   global $ccgg_equip;
   #
   # Get the history.
   #
   $select = "SELECT DISTINCT date, time, code, gmd.project.abbr ";
   $from = "FROM ${ccgg_equip}.gen_elog LEFT JOIN gmd.site ON ( gen_elog.site_num = gmd.site.num ) ";
   $from = "${from} LEFT JOIN gmd.project ON ( gen_elog.project_num = gmd.project.num ) ";
   $where = "WHERE gen_inv_id = '${id}' ";
   $order = "ORDER BY date, time DESC";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_UpdateInfo ##############################################################
#
function DB_UpdateInfo($settask,$unit_id,$datetime,$sitenum,$projnum,$comments,$keys)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Get the user id
   #
   $user = GetUser();

   #
   # Get date and time
   #
   $today = date("Y-m-d");
   $now = date("H:i:s");

   #
   # If the user is updating a comment, then we want to update the log table
   #    using the time and date of the comment that is being updated. Otherwise
   #    a new comment is being added, so we'll use the time now and the date today
   #
   if ( $datetime == 'Add' ) 
   {
      $datetime = "$today~$now~$sitenum~$projnum";
   }

   $datefield = split("\~",$datetime);
   $date = $datefield[0];
   $time = $datefield[1];

   $sql = "SELECT COUNT(*) FROM ${ccgg_equip}.gen_elog";
   $sql = "${sql} WHERE gen_inv_id = '${unit_id}' AND date = '${date}'";
   $sql = "${sql} AND time = '${time}' AND gen_type_num = '${gen_type_num}'";

   $res = ccgg_query($sql);
                                                                                          
   #
   # If there is a count of 0, then we should insert. Otherwise, we should
   #    update.
   #
   $task = ($res[0] == '0') ? 'add' : 'update';

   #
   # Updating a comment
   #

   if ( $settask == 'update' )
   {
      $commentfield = split("\|",$comments);
      for ($i=0; $i<count($commentfield); $i++)
      {
         $tmp=split("\~",$commentfield[$i]);
         $commenttype = $tmp[0];
         $entry = addslashes($tmp[1]);
                                                                                          
         if ( $entry != '' )
         {
            $sql = "SELECT COUNT(*) FROM ${ccgg_equip}.gen_elog";
            $sql = "${sql} WHERE gen_inv_id = '${unit_id}' AND date = '${date}'";
            $sql = "${sql} AND time = '${time}' AND gen_elog_type_num = $commenttype";
            $sql = "${sql} AND gen_type_num = '${gen_type_num}'";
            $res = ccgg_query($sql);

            $keytype = 0;
            $keyinfo = split("\|",$keys);
            for ( $j=0; $j<count($keyinfo); $j++ )
            {
               $keyfield = split("\~",$keyinfo[$j]);
               if ( $keyfield[0] == $commenttype )
               {
                  $keytype = $keyfield[1];
                  continue;
               }
            }

            #
            # If there is a count of 0, then we should insert. Otherwise, we should
            #    update.
            #

            if ( $res[0] == '0' )
            {
               $sql = "INSERT INTO ${ccgg_equip}.gen_elog";
               $sql = "${sql} VALUES ('${unit_id}','${gen_type_num}','${commenttype}','${keytype}','${sitenum}','${projnum}','${user}','${date}','${time}','${entry}')";

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               #$res = "";
               if (!empty($res)) { return(FALSE); }
            } 
            else
            {
               $sql = "UPDATE ${ccgg_equip}.gen_elog SET entry='${entry}', user='${user}'";
               $sql = "${sql}, site_num='$sitenum', project_num='$projnum'";
               $sql = "${sql}, gen_elog_key_num='$keytype'";
               $sql = "${sql} WHERE gen_inv_id='$unit_id' AND date='$date'";
               $sql = "${sql} AND time='$time' AND gen_elog_type_num='$commenttype'";
               $sql = "${sql} AND gen_type_num = '${gen_type_num}'";

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               #$res = "";
               if (!empty($res)) { return(FALSE); }
            }
         }
         else
         {
            DB_DeleteInfo($unit_id,$datetime,$sitenum,$commenttype);
         }
      }
   }

   #
   # Adding a comment
   #
   if ( $settask == 'add' )
   {
      $commentfield = split("\|",$comments);
      for ($i=0; $i<count($commentfield); $i++)
      {
         $tmp=split("\~",$commentfield[$i]);
         $commenttype = $tmp[0];
         $entry = addslashes($tmp[1]);

         $keytype = 0;
         $keyinfo = split("\|",$keys);
         for ( $j=0; $j<count($keyinfo); $j++ )
         {
            $keyfield = split("\~",$keyinfo[$j]);
            if ( $keyfield[0] == $commenttype )
            {
               $keytype = $keyfield[1];
               continue;
            }
         }

         if (!empty($entry))
         {
            $sql = "INSERT INTO ${ccgg_equip}.gen_elog";
            $sql = "${sql} VALUES ('${unit_id}','${gen_type_num}','${commenttype}','${keytype}','${sitenum}','${projnum}','${user}','${date}','${time}','${entry}')";

            #echo "$sql<BR>";
            $res = ccgg_insert($sql);
            #$res = "";
            if (!empty($res)) { return(FALSE); }
         }
      }
   }
   return(TRUE);
}

#
# Function DB_GetAllCommentType() ########################################################
#
function DB_GetAllCommentType()
{
   global $ccgg_equip;
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT num, name ";
   $from = "FROM ${ccgg_equip}.gen_elog_type ";
   $order = "ORDER BY num";
                                                                                          
   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetAllKeyType() ########################################################
#
function DB_GetAllKeyType()
{
   global $ccgg_equip;
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT num, name, gen_elog_type_num ";
   $from = "FROM ${ccgg_equip}.gen_elog_key ";
   $order = "ORDER BY name";
                                                                                          
   return ccgg_query($select.$from.$order);
}
#
# Function CreateSiteSelectButton ####################################################
#
function CreateSiteSelectButton($code)
{
   global $siteinfo;

   #
   # Create a select menu for PFP Sites
   #
   echo "<SELECT NAME='sitelist' class='MediumBlackN' SIZE=1 onChange='ListSelectCB(this)'>";

   for ($i=0; $i<count($siteinfo); $i++)
   {
      $tmp=split("\|",$siteinfo[$i]);
      $selected = (!(strcasecmp($tmp[1],$code))) ? 'SELECTED' : '';
      $z = sprintf("%s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   echo "</SELECT>";
}
#
# Function CreateProjSelectButton ####################################################
#
function CreateProjSelectButton($proj_abbr)
{
   global $siteinfo;
   global $strat_abbr;

   #
   # Create a select menu for PFP Sites
   #
   echo "<SELECT NAME='projlist' class='MediumBlackN' SIZE=1 onChange='ListSelectCB(this)'></SELECT>";

   for ($i=0; $i<count($siteinfo); $i++)
   {
      $tmp = split("\|", $siteinfo[$i]);
      $code = $tmp[1];
      JavaScriptCommand("sitedesc['$code'] = new Array()");

      $sitedescinfo = DB_GetSiteDesc($code, $strat_abbr);
      #print_r($sitedescinfo);

      for ($j=0; $j<count($sitedescinfo); $j++)
      { JavaScriptCommand("sitedesc['$code'][$j] = \"$sitedescinfo[$j]\""); }
   }

   JavaScriptCommand("PostProjList()");

}
#
# Function DB_DeleteInfo ########################################################
#
function DB_DeleteInfo($unit_id,$datetime,$sitenum,$commenttype)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # By deleting an unit or component, all we do is set it inactive
   #

   $datefield = split("\~",$datetime);
   $date = $datefield[0];
   $time = $datefield[1];


   $sql = "DELETE FROM ${ccgg_equip}.gen_elog";
   $sql = "${sql} WHERE gen_inv_id ='$unit_id' AND date='$date'";
   $sql = "${sql} AND time='$time' AND site_num='$sitenum'";
   $sql = "${sql} AND gen_elog_type_num='$commenttype'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";
   $sql = "${sql} LIMIT 1";

   #echo "$sql<BR>";
   $res = ccgg_delete($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}

?>
