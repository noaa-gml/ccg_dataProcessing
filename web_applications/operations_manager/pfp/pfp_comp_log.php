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
$datetime = isset( $_POST['datetime'] ) ? $_POST['datetime'] : '';
$sitenum = isset( $_POST['sitenum'] ) ? $_POST['sitenum'] : '';
$flightdate = isset( $_POST['flightdate'] ) ? $_POST['flightdate'] : '';
$commentinfo = isset( $_POST['commentinfo'] ) ? $_POST['commentinfo'] : '';

$strat_name = 'PFP';
$strat_abbr = 'pfp';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_comp_log.js'></SCRIPT>";

#
# After the user submits the page, check $task to determine what the user
#    wanted to do.
#

if ( $task == 'add' || $task == 'update' )
{

   #
   # Add a new log comment
   #
   if (!(DB_UpdateInfo($task,$unitid,$datetime,$flightdate,$sitenum,$commentinfo)))
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
$siteinfo = DB_GetAllSiteList();

#
# If an unit is selected, then find the list of components linked
#   to that unit
#
if ( $unitid != '' )
{
   $dateinfo = DB_GetDates($unitid);
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $unitid;
   global $datetime;
   global $sitenum;
   global $flightdate;
   global $unitinfo;
   global $siteinfo;
   global $dateinfo;
   global $commentinfo;

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='unitid' VALUE='${unitid}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='datetime' VALUE='${datetime}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='sitenum' VALUE=''>";
   echo "<INPUT TYPE='HIDDEN' NAME='commentinfo' VALUE='${commentinfo}'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Unit</TD>";
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
   echo "<TD>";
   echo "<SELECT class='MediumBlackN' NAME='unitlist' SIZE='1' onChange='ListSelectCB(this)'>";

   #
   # Display the list of active units
   #
   echo "<OPTION VALUE=''>Select Unit</OPTION>";
   for ($i=0; $i<count($unitinfo); $i++)
   {
      $tmp=split("\|",$unitinfo[$i]);
      $class = ($tmp[6] == 1) ? 'MediumBlackN' : 'MediumGrayN';
      $selected = (!(strcasecmp($tmp[0],$unitid))) ? 'SELECTED' : '';
      $z = sprintf("%s (%s) - %s",$tmp[0],$tmp[1],$tmp[2]);
      echo "<OPTION class=$class $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
   echo "</SELECT>";
   echo "</TD>";

   #
   # Make sure an unit has been selected before we display this table
   #
   if ( $unitid != '' )
   {
      echo "<TD align=right>";
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
      echo "<OPTION VALUE='Add' $selected>Add Date</OPTION>";
      
      $field = split("~",$datetime);
      for ($i=0; $i<count($dateinfo); $i++)
      {
         $tmp=split("\|",$dateinfo[$i]);
	 if ( $field[0] == $tmp[0] && $field[1] == $tmp[1] )
         {
            $selected = 'SELECTED';
	    $flightdate = $tmp[3];
         }
         else
         {
            $selected = '';
         }
	
	 if ( $tmp[2] == NULL )
	 {
	    $sitecode = '';
	 }
	 else
	 {
            for ($j=0; $j<count($siteinfo); $j++)
            {
               $sitetmp=split("\|",$siteinfo[$j]);
   	       if ( $sitetmp[0] == $tmp[2] )
   	       {
  	          $sitecode = $sitetmp[1];
	          break;
	       }
            }
	 }
         $z = sprintf("%s - %s",$tmp[3],$sitecode);
         echo "<OPTION $selected VALUE='$tmp[0]~$tmp[1]~$tmp[2]'>${z}</OPTION>";
      }
      echo "</SELECT>";

      #
      # Display editable comment field
      #
      # PostDates($unitid);
      if ( $unitid != '' && $datetime != '' )
      {
         echo "</TABLE>";
                                                                                          
         echo "<TABLE align='center' col=2 width=75% border='0' cellpadding='2' cellspacing='2'>";

         PostForm2Edit($unitid,$datetime,$flightdate,'Comments');
      
         echo "</TABLE>";

         echo "<TABLE align='center' width=20% border='0' cellpadding='2' cellspacing='2'>";

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

         echo "<TD align='center'>";
	 echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
         echo "</TD>";
      }
                
   }

   echo "</TABLE>";
   echo "</BODY>";
   echo "</HTML>";
}

#
# Function PostTable2Edit ########################################################
#

function PostForm2Edit($unitid,$datetime,$flightdate,$title)
{
   global $siteinfo;
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
   echo "<TR><TD>";
   echo "<FONT class='MediumBlackB'>Unit:</FONT>";
   echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$unitid</FONT>";
   echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";

   $today = date("Y-m-d");
   $now = date("H:i:s");
   $sitecode = split("\|",$siteinfo[0]);

   $tmp = split("\~",$datetime);
   $field[0] = ( isset($tmp[0]) ) ? $tmp[0] : '';
   $field[1] = ( isset($tmp[1]) ) ? $tmp[1] : '';
   $field[2] = ( isset($tmp[2]) ) ? $tmp[2] : '';

   #
   # If the user is not trying to add a new log, then look in the database
   # and determine who all edited the logs for the particular date, time, and
   # unit_id. Otherwise, grab the current user and make a default $datetime.
   #
   if ( $datetime != "Add" )
   {
      $select = "SELECT user ";
      $from = "FROM pfp_log ";
      $where = "WHERE unit_id = '${unitid}' AND date = '$field[0]' ";
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

      $field = split("\~",$datetime);
      echo "<FONT class='MediumBlackB'>Date:</FONT>";
      echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$field[0]</FONT>";
      echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
      echo "<FONT class='MediumBlackB'>Time:</FONT>";
      echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$field[1]</FONT>";
      echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
   }
   else
   {
      $user=GetUser();
      $flightdate=$today;
   }


   echo "<FONT class='MediumBlackB'>User:</FONT>";
   echo "&nbsp;&nbsp;<FONT class='MediumBlackN'>$user</FONT>";
   echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
   echo "<p>"; 
   echo "<FONT class='MediumBlackB'>Flight Date:</FONT>";
   echo "&nbsp;&nbsp;<INPUT type='text' name='flightdate' class='MediumBlackN' size=8 maxlength=10 value='$flightdate'><FONT class='MediumBlackN'>[YYYY-MM-DD]</FONT>";

   echo "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
   echo "<FONT class='MediumBlackB'>Site:</FONT>";
   echo "&nbsp;&nbsp;";
   CreateSiteSelectButton($field[2]);

   JavaScriptCommand("document.mainform.sitenum.value = \"$field[2]\"");


   echo "</TD></TR>";
   echo "<TR>";

   $commentinfo = DB_GetAllCommentType();

   for ($i=0; $i<count($commentinfo); $i++)
   {
      $tmp=split("\|",$commentinfo[$i]);
      echo "<TR><TD ALIGN='left' bgcolor='#FFCC99'>";
      echo "<FONT class='MediumBlackB'>$tmp[1]</FONT><BR>";
      echo "<TEXTAREA class='MediumBlackN' name='comments:$tmp[0]' cols=120 rows=5 onClick='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";

      $select = "SELECT entry ";
      $from = "FROM pfp_log ";
      $where = "WHERE unit_id = '${unitid}' AND date = '$field[0]' ";
      $where = "${where} AND time = '$field[1]' AND pfp_comment_type_num = $tmp[0]";
      $value = ccgg_query($select.$from.$where);

      if ( isset($value[0]) ) { echo "$value[0]"; }
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
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT id, abbr, name, version, batch, comments, active_status_num ";
   $from = "FROM pfp_unit LEFT JOIN pfp_unit_type";
   $from = "${from} ON ( pfp_unit.pfp_unit_type_num = pfp_unit_type.num ) ";
   $order = "ORDER BY id";

   return ccgg_query($select.$from.$order);
}

#
# Function DB_GetAllSiteList() ########################################################
#
function DB_GetAllSiteList()
{
   #
   # Get a list of all the units in the unit table
   #
   $select = " SELECT DISTINCT num, code";
   $from = " FROM gmd.site LEFT JOIN site_desc";
   $on = " ON ( gmd.site.num = site_desc.site_num )";
   $where = " WHERE strategy_num = '2'";
   $order = " ORDER BY code";
                                                                                          
   return ccgg_query($select.$from.$on.$where.$order);
}

#
# Function DB_GetCompInfo() ###########################################################
#

function DB_GetCompInfo($num)
{
   #
   # Get the information about a single component
   #
   $select = "SELECT num, type, name, version, comments ";
   $from = "FROM pfp_comp ";
   $where = "WHERE num = ${num}";

   return ccgg_query($select.$from.$where);
}

#
# Function DB_GetCompList($id) ########################################################
#

function DB_GetCompList($id)
{
   #
   # Get a list of all the components associated with a specific unit
   #
   $select = "SELECT DISTINCT pfp_comp.num, pfp_comp.type, pfp_comp.name, pfp_comp.version, pfp_comp.comments ";
   $from = "FROM pfp_comp LEFT JOIN pfp_history ON ( pfp_comp.num = pfp_history.comp_num) ";
   $where = "WHERE pfp_history.unit_id = '${id}' ";
   $order = "ORDER by pfp_comp.type";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_GetHist() #####################################################
#
function DB_GetDates($id)
{
   #
   # Get the history. If no component is selected, then Get_Hist() will
   #   return the history for that unit. If a component is selected,
   #   then Get_Hist() will return the history of the unit in regards
   #   to the selected component
   #
   $select = "SELECT DISTINCT date, time, num, flight_date ";
   $from = "FROM pfp_log LEFT JOIN gmd.site ON (pfp_log.site_num = gmd.site.num) ";
   $where = "WHERE unit_id = '${id}' ";
   $order = "ORDER BY flight_date DESC";

   return ccgg_query($select.$from.$where.$order);
}
#
# Function DB_UpdateInfo ##############################################################
#
function DB_UpdateInfo($settask,$unitid,$datetime,$flightdate,$sitenum,$comments)
{

   $today = date("Y-m-d");
   $now = date("H:i:s");
   
   #
   # Get the user id
   #
   $user = GetUser();

   if ( $datetime == "Add" )
   {
      $datetime = "$today~$now";
   }
   $datefield = split("\~",$datetime);
   $date = $datefield[0];
   $time = $datefield[1];

   $sql = "SELECT COUNT(*) FROM pfp_log";
   $sql = "${sql} WHERE unit_id = '${unitid}' AND date = '${date}'";
   $sql = "${sql} AND time = '${time}'";

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
            $sql = "SELECT COUNT(*) FROM pfp_log";
            $sql = "${sql} WHERE unit_id = '${unitid}' AND date = '${date}'";
            $sql = "${sql} AND time = '${time}' AND pfp_comment_type_num = $commenttype";
                                                                                          
            $res = ccgg_query($sql);
                                                                                          
            #
            # If there is a count of 0, then we should insert. Otherwise, we should
            #    update.
            #

            if ( $res[0] == '0' )
            {
               $sql = "INSERT INTO pfp_log";
               $sql = "${sql} VALUES ('${unitid}','$flightdate','$date','$time','$user','${sitenum}','$commenttype','${entry}')";

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               if (!empty($res)) {var_dump($sql);var_dump($res); return(FALSE); }
            } 
            else
            {
	       #
	       # If the user selected a date and then changes it, there is a
	       # possibility that there is an existing log that has that exact
	       # date and time. It was decided that logs cannot be overwritten,
	       # only modified and updated. So, we alert the user that they
	       # are trying to do something not allowed.
	       #
               $sql = "UPDATE pfp_log SET entry='${entry}', user='${user}',";
               $sql = "${sql} site_num='$sitenum', flight_date='$flightdate'";
               $sql = "${sql} WHERE unit_id='$unitid' AND date='$date'";
               $sql = "${sql} AND time='$time' AND pfp_comment_type_num='$commenttype'";

               #echo "$sql<BR>";
               $res = ccgg_insert($sql);
               if (!empty($res)) {var_dump($sql);var_dump($res); return(FALSE); }
            }
         }
         else
         {
            #JavaScriptAlert("Delete");
            DB_DeleteInfo($unitid,$datetime,$flightdate,$commenttype);
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

         if ( $entry != '' )
         {
            $sql = "INSERT INTO pfp_log";
            $sql = "${sql} VALUES ('${unitid}','$flightdate','$date','$time','$user','${sitenum}','$commenttype','${entry}')";

            #echo "$sql<BR>";
            $res = ccgg_insert($sql);
            if (!empty($res)) {var_dump($sql);var_dump($res); return(FALSE); }
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
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT * ";
   $from = "FROM pfp_comment_type ";
   $order = "ORDER BY num";
                                                                                          
   return ccgg_query($select.$from.$order);
}
#
# Function CreateStatusSelectButton ####################################################
#
function CreateSiteSelectButton($num)
{
   global $siteinfo;

   #
   # Create a select menu for PFP sites
   #
   echo "<SELECT NAME='sitelist' class='MediumBlackN' SIZE=1 onChange='ListSelectCB(this)'>";

   echo "<OPTION VALUE=''>---</OPTION>";
   for ($i=0; $i<count($siteinfo); $i++)
   {
      $tmp=split("\|",$siteinfo[$i]);
      $selected = (!(strcasecmp($tmp[0],$num))) ? 'SELECTED' : '';
      $z = sprintf("%s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }
}
#
# Function DB_DeleteInfo ########################################################
#
function DB_DeleteInfo($unitid,$datetime,$flightdate,$commenttype)
{
   #
   # Delete the specified log
   #

   $datefield = split("\~",$datetime);
   $date = $datefield[0];
   $time = $datefield[1];
   $sitenum = $datefield[2];


   $sql = "DELETE FROM pfp_log";
   $sql = "${sql} WHERE unit_id ='$unitid' AND date='$date'";
   $sql = "${sql} AND time='$time' AND site_num='$sitenum'";
   $sql = "${sql} AND pfp_comment_type_num=$commenttype AND flight_date='$flightdate'";
   $sql = "${sql} LIMIT 1";

   #echo "$sql<BR>";
   $res = ccgg_delete($sql);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}

?>
