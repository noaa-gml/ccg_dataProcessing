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
$selectkey = isset( $_POST['selectkey'] ) ? $_POST['selectkey'] : '';
$selecttype = isset( $_POST['selecttype'] ) ? $_POST['selecttype'] : '';
$prev_selectkey = isset( $_POST['prev_selectkey'] ) ? $_POST['prev_selectkey'] : '';
$key_info = isset( $_POST['key_info'] ) ? $_POST['key_info'] : '';

$strat_name = 'Flask';
$strat_abbr = 'flask';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_keyword.js'></SCRIPT>";

#
#    Set initial variables as well as global variables that were returned
# from the last submission
#
$table = 'flask_log_keyword';
$info = $key_info;
$number = $selectkey;

#
# Determine the task to be done
#
switch ($task)
{
   case 'add':
   case 'update':
      #
      # Add a new keyword to the database
      #
      DB_UpdateInfo($table,$info,$number,$task);
      $selectkey = '';
      $selecttype = '';
      $task = '';
      break;
}

#
# Server side to client side
# Sending all the keyword information to client side
#
$keyinfo = DB_GetAllKeyList();
for ($i=0,$z=''; $i<count($keyinfo); $i++)
{
   $keyinfo[$i] = addslashes($keyinfo[$i]);
   $z = ($i == 0) ? $keyinfo[$i] : "${z}~${keyinfo[$i]}";
}
JavaScriptCommand("keys = \"${z}\"");

$keycount = DB_GetAllKeyCount();
for ($i=0,$z=''; $i<count($keycount); $i++)
{
   $z = ($i == 0) ? $keycount[$i] : "${z}~${keycount[$i]}";
}
JavaScriptCommand("keyscount = \"${z}\"");

#
# Getting the contents of the $table first so that we can send it over
# to the client side. This is done so that the table can be updated through
# JavaScript without coming back to the server
#
$res = ccgg_fields($table,$name,$type,$length);
for ( $i=0; $i<count($name); $i++ )
{
   $y = ( $i == 0 ) ? "${name[$i]}|${type[$i]}|${length[$i]}" : "${y}~${name[$i]}|${type[$i]}|${length[$i]}";
}
JavaScriptCommand("tablefields = \"${y}\"");

#
# Get a list of the types of keywords there are
#
$typeinfo = DB_GetAllTypeList();

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
   global $selectkey;
   global $selecttype;
   global $prev_selectkey;
   global $keyinfo;
   global $typeinfo;
   global $nsubmits;
 
   echo "<FORM name='mainform' method=POST>";

   #
   # Keep all the data hidden for the server side operations. Task
   # is used to determine what to do on the next submission. Selectkey
   # is the currently selected keyword. Selecttype is the currently
   # selected type of keyword. Prev_selectkey is so that a user may
   # click on an existing key and then click on "Add Keyword" to add a
   # new key similar to the key previously selected.
   # 
   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='selectkey' VALUE=${selectkey}>";
   echo "<INPUT TYPE='HIDDEN' NAME='selecttype' VALUE=${selecttype}>";
   echo "<INPUT TYPE='HIDDEN' NAME='prev_selectkey' VALUE=${prev_selectkey}>";

   #
   # key_info stores the information that we want to inject into the databse
   #
   echo "<INPUT type='hidden' name='key_info'>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Keyword Manager</TD>";
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

   echo "<TD width=50%>";

   #
   # Create the list of keyword types
   #
   echo "<FONT CLASS='MediumBlackB'>Select Keyword Type:</FONT><BR><BR>";
   for ( $j=0; $j<count($typeinfo); $j++ )
   {
      $field = split("\|",$typeinfo[$j]);
      $checked = '';
      if ( $field[0] == $selecttype ) { $checked = 'checked'; }
      echo "<INPUT TYPE='radio' NAME='type' VALUE='$field[0]' onClick='ListSelectCB(this)' $checked>$field[1]<BR>";

      #
      # Spaces between each keyword type, except we don't need these after the
      # last one
      #
      # if ( $j != (count($typeinfo) - 1) ) { echo "<BR><BR>"; }

   }
   echo "</TD>";
   echo "<TD WIDTH=50% VALIGN='top'>";

   #
   # This is completely to be sneaky. Basically we build the entire page, all
   # the selection windows, tables, and forms. Then we decide which ones to
   # show and which ones to hide. Initially, they are hidden.
   # See /www/ccgg/om/om_styles.css
   #
   echo "<DIV id='keylistid' class='Hidden' ALIGN='center'>";

   #
   # Create the selection list for keywords. It is filled in by JavaScript
   #
   echo "<FONT CLASS='MediumBlackB'>Select Keyword:</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='keylist' SIZE='5' onChange='ListSelectCB(this)'>";
   echo "</SELECT>";
   echo "</DIV>";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";

   #
   # Again, we hide the entire table until we have all the information
   # we need to fill the table. Then we show it. All done in JavaScript
   # with css styles.
   #
   echo "<DIV id='keywordid' class='Hidden' ALIGN='center'>";


   echo "<TABLE align='center' col=2 width=75% border='0' cellpadding='2' cellspacing='2'>";

   #
   # Post the keyword information table
   #
   $type = 'flask_log_keyword';
   PostTable2Edit($type,$selectkey,$prev_selectkey,'DESCRIPTION');

   echo "</TABLE>";

   echo "<TABLE align='center' width=25% border='0' cellpadding='4' cellspacing='4'>";
   echo "<TR>";

   #
   # By default this button will be update. But if user clicks on "Add Keyword",
   # then we change this button to "Add".
   #
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Update' onClick='Execute(\"${type}\")'>";
   echo "</TD>";

   echo "<TD align='center'>";

   #
   # If the user chooses to add a keyword, then this button will be made visible.
   # Otherwise this button is hidden by default.
   #
   echo "<DIV id='clearbtn' class='Hidden' ALIGN='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Clear' onClick='ClearCB(\"${type}\")'>";
   echo "</DIV>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
   echo "</TD>";

   echo "</TR>";
   echo "</TABLE>";
   echo "</DIV>";

   echo "</BODY>";
   echo "</HTML>";
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

   #
   # Loop through all of the fields and output the name and data
   #
   for ($i=0; $i<count($name); $i++)
   {

      echo "<TR>";

      $oname = $name[$i];
      $writable = 1;

      switch($name[$i])
      {
         case 'num':
            $writable = 0;
            break;
         case 'comment_type_num':
            CreateTypeSelectButton($table);
            continue 2;
      }

      echo "<TD ALIGN='right' class='LargeBlueN'>$oname</TD>";
      #
      # Based on the type of field, switch for different outputs
      #
      switch ($type[$i])
      {
         case "blob":
            echo "<TD ALIGN='left'>";
            echo "<TEXTAREA class='MediumBlackN' name='${table}:$name[$i]' cols=60 rows=5 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
            echo "</TEXTAREA></TD>";
            break;
         default:
            echo "<TD ALIGN='left'>";
            if ( $writable )
            {
               echo "<INPUT type=text class='MediumBlackN' name='${table}:$name[$i]' size='60' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'>";
            }
            else
            {
               echo "<INPUT type=text class='MediumBlackN' name='${table}:$name[$i]' size='60' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' style='background-color: #E6E6E6;' DISABLED>";
               # echo "<FONT id='${table}:$name[$i]' class='MediumBlackN'>$value</FONT></TD>";
            }
	    break;
      }
      echo "</TR>";
   }	
}

#
# Function CreateTypeSelectButton ####################################################
#
function CreateTypeSelectButton($table)
{
   #
   # Create a select menu for the type of keyword
   #
   global $typeinfo;

   echo "<TD ALIGN='right' class='LargeBlueN'>comment type</TD>";
   echo "<TD ALIGN='left'>";
   echo "<SELECT NAME='$table:comment_type_num' class='MediumBlackN' SIZE=1>";

   for ($i=0; $i<count($typeinfo); $i++)
   {
      $tmp=split("\|",$typeinfo[$i]);
      $z = sprintf("%s",$tmp[1]);
      echo "<OPTION $selected VALUE='$tmp[0]'>${z}</OPTION>";
   }

   echo "</TD>";
}
#
# Function DB_GetAllKeyList() ########################################################
#
function DB_GetAllKeyList()
{
   #
   # Get a list of all the keywords
   #
   $select = "SELECT num, comment_type_num, name, comments ";
   $from = "FROM flask_log_keyword ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
#
# Function DB_GetAllKeyCount() ########################################################
#
function DB_GetAllKeyCount()
{
   #
   # Get a list of all the keywords
   #
   $select = "SELECT num, COUNT(*) ";
   $from = "FROM flask_log_keyword, flask_log_testcomment ";
   $where = "WHERE flask_log_keyword.num = flask_log_testcomment.comment_type_num ";
   $group = "GROUP BY num ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$where.$group.$order);
}
#
# Function DB_GetAllTypeList() ########################################################
#
function DB_GetAllTypeList()
{
   #
   # Get a list of all the types of keywords
   #
   $select = "SELECT num, name ";
   $from = "FROM flask_log_commenttype ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
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
   $updateset = '';
   $chkset = '';
   $set = '';

   for ($i=0,$acc='',$list='',$values=''; $i<count($datapairs); $i++)
   {
      list($n,$v) = split("~",$datapairs[$i]);
      $acc = "${acc}${v}";

      $v = addslashes($v);

      $list = ($i == 0) ? "${n}" : "${list},${n}";
      $values = ($i == 0) ? "'${v}'" : "${values},'${v}'";

      $updateset = ($updateset == '') ? "${n}='${v}'" : "${updateset}, ${n}='${v}'";
      if ( $n == 'name' )
      {
         $chkset = ($chkset == '') ? "${n}='${v}'" : "${chkset} AND ${n}='${v}'";
      }
      $set = ($set == '') ? "${n}='${v}'" : "${set}, ${n}='${v}'";

   }

   #
   # Count the number of entries based on the values we were passed.
   #
   if ( $table == '' )
   {
      JavaScriptAlert("UpdateInfo: No table defined");
      return(FALSE);
   }

   if ( $number != 'Add' )
   {
      $sql = "SELECT COUNT(*) FROM ${table} WHERE num = $number";
   }
   else
   {
      $sql = "SELECT COUNT(*) FROM ${table} WHERE ${chkset}";
   }

   #print "$sql<BR>";
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
         $sql = "UPDATE ${table} SET ${updateset}";
         $sql = "${sql} WHERE num=$number";
      }

      if ( $settask == 'add' )
      {
         $sql = "INSERT INTO ${table} ";
         $sql = "${sql} VALUES ('',${values})";
      }

      #
      # Do not create a table entry if all fields are empty
      #

      if (!empty($acc))
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
         JavaScriptAlert("Unable to add because already exists in DB.");
      }
      return(FALSE);
   }
}
?>
