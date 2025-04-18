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

$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : 'om';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : 'om';

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$query = isset( $_POST['query'] ) ? $_POST['query'] : '';
$newqueryinfo = isset( $_POST['newqueryinfo'] ) ? $_POST['newqueryinfo'] : '';

BuildBanner($strat_name,$strat_abbr, GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='om_dbquery.js'></SCRIPT>";

#
# After the user submits the page, check $task to determine what the user
#    wanted to do.
#

if ( $task == 'add' )
{
   #
   # Update or insert the query
   #
   if (!DB_UpdateInfo($newqueryinfo))
   {
      JavaScriptAlert("Unable to add query to DB");
   }
   #
   # Reset the task
   #
   $task = '';
}
if ( $task == 'delete' )
{
   #
   # Delete a query from the database
   #
   if (!DB_DeleteInfo($newqueryinfo))
   {
      JavaScriptAlert("Unable to delete query from DB");
   }
   #
   # Clear variables so that the page is blank 
   #    and the task is reset
   #
   $newqueryinfo = '';
   $task = '';
}

if ( $task == 'run' )
{
   $query_table = '';
   $query_output = '';

   #
   # Parse the $newqueryinfo variable, extracting the SQL query
   #
   $commentfield = split("\|",$newqueryinfo);
   for ($i=0; $i<count($commentfield); $i++)
   {
      list($n,$v)=split("\~",$commentfield[$i]);
      $set = ($i == 0) ? "'${v}'" : "${set},'${v}'";
      if ( $n == 'command' )
      {
         $command = str_replace("\\","",$v);
         continue;
      }
   }

   #
   # Run the SQL query
   #
   #$result = mysql_query ($command);
   $result=doquery($command);
   if (!$result)
   {
      #
      # If there is an error, alert it and clear the variables
      #
      $error = mysql_error();
      $check = array ("'", "\"", "\n", "\r");
      $replace = array ("\'", "\\\"", "/n", "/r");
      $error = str_replace ( $check, $replace, $error); 
      JavaScriptAlert($error);
      $query_table = '';
      $query_output = '';
   }
   else
   {
      $query_output=printTable($result);
      /*
      #
      # Get the field names for the query so we can build the
      #    table on the webpage
      #
      for ( $i=0; $i < mysql_num_fields($result); $i++ )
      {
         #
         # mysql_fetch_field returns a structure to $meta
         #    accessible data in the struture are:
         #       $meta->blob
         #       $meta->max_length
         #       $meta->multiple_key
         #       $meta->name
         #       $meta->not_null
         #       $meta->numeric
         #       $meta->primery_key
         #       $meta->table
         #       $meta->type
         #       $meta->unique_key
         #       $meta->unsigned
         #       $meta->zerofill
         #
         $meta = mysql_fetch_field($result);
         if ( !$meta )
         {
            continue;
         }

         #
         # Build up the array of headers for the fields
         # 
         $query_table[$i] = $meta->name;
      }

      #
      # Actually run the command, retrieving the data
      #
      $query_output = ccgg_query($command);
      */
   }
   $task = '';
}

#
# Get a list of all the queries from the database
#
$queryinfo = DB_GetAllQueryList();

#
# Server side to client side
#
for ($i=0,$z=''; $i<count($queryinfo); $i++)
{
$field = split("\|",$queryinfo[$i]);
$z = ($i == 0) ? "${field[0]},${field[3]}" : "${z}|${field[0]},${field[3]}";
}
JavaScriptCommand("queries = \"".addslashes($z)."\"");

#
# Clear some variables
#
$queryname='';
$sqlquery='';
$comment='';

#
# If a query was already submitted, then $newqueryinfo will be non-empty
#    so we should parse the data from the variable and put it up on the webpage
#
if ( $newqueryinfo != '' )
{
   $commentfield = split("\|",$newqueryinfo);
   for ($i=0; $i<count($commentfield); $i++)
   {
      list($n,$v)=split("\~",$commentfield[$i]);
      switch ($n) {
         case 'name':
            $queryname=$v;
            break;
         case 'command':
            $sqlquery=$v;
            break;
         case 'comments':
            $comment=$v;
            break;
         case 'user':
            $username=$v;
            break;
      }
   }
}
else
{
   #
   # If a user clicked on a query from the query list, let's loop through
   #    all the queries that we have stored and set the variables
   #    to display the information later
   #
   if ( $query != '' )
   {
      for ($i=0; $i<count($queryinfo); $i++)
      {
         $tmp=split("\|",$queryinfo[$i]);
         if ( $query == "$tmp[3]-$tmp[0]" )
         {
            $queryname=$tmp[0];
            $sqlquery=$tmp[1];
            $comment=$tmp[2];
            $username=$tmp[3];
         }
      }
   }
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $strat_abbr;
   global $query;
   global $queryname;
   global $username;
   global $sqlquery;
   global $comment;
   global $queryinfo;
   global $newqueryinfo;
   global $query_output;
   global $query_table;

   echo "<FORM name='mainform' method=POST>";

   $user = GetUser();
   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='query' VALUE='${query}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='user' VALUE='${user}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='username' VALUE='${username}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='newqueryinfo' VALUE=''>";

   echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
   echo "<TR align='center'>";
   echo "<TD align='center' class='XLargeBlueB'>Database Query</TD>";
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
   # Row 2: Input Textareas
   ##############################
   #
   # Display information about the query if we have anything, otherwise
   #    bring up some blank input textareas
   #

   echo "<TR>";
   echo "<TD ALIGN='center'>";
   echo "<FONT class='MediumBlackB'>Query Name</FONT><BR>";

   echo "<INPUT type=text class='MediumBlackN' name='query:name' size='30' maxlength='30' onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' value='${queryname}'><BR><BR><BR>";
   echo "<FONT class='MediumBlackB'>MySQL Query</FONT><BR>";
   echo "<TEXTAREA class='MediumBlackN' name='query:command' cols=80 rows=3 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' WRAP=SOFT>";

   #
   # Since we use urlencode when we save the data, all the ' and " are escaped
   #    meaning they show up as \' and \", so we need to remove the \
   #
   $sqlquery = str_replace("\\","",$sqlquery);
   echo "$sqlquery";
   echo "</TEXTAREA><BR><BR><BR>";
   echo "<FONT class='MediumBlackB'>Comments</FONT><BR>";
   echo "<TEXTAREA class='MediumBlackN' name='query:comments' cols=80 rows=3 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' WRAP=SOFT>";

   #
   # Since we use urlencode when we save the data, all the ' and " are escaped
   #    meaning they show up as \' and \", so we need to remove the \
   #
   $comment = str_replace("\\","",$comment);
   echo "$comment";
   echo "</TEXTAREA><BR><BR>";

   #
   ##############################
   # Row 2: Clickable Buttons
   ##############################
   #
   echo "<TABLE align='center' col=2 width=75% border='0' cellpadding='4' cellspacing='4'>";

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='run' class='Btn' value='Run' onClick='RunCB()'>";
   echo "</TD>";

   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Save' onClick='AddCB()'>";
   echo "</TD>";
                                                                                          
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='delete' class='Btn' value='Remove' onClick='DeleteCB()'>";
   echo "</TD>";
                                                                                          
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='clear' class='Btn' value='Clear' onClick='ClearCB()'>";
   echo "</TD>";
                                                                                          
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Back' onClick='BackCB()'>";
   echo "</TD></TABLE></TD>";

   echo "<TD align=center valign=top>";
   echo "<FONT class='MediumBlackB'>Query List</FONT><BR>";
   echo "<SELECT class='MediumBlackN' NAME='querylist' SIZE='10' onChange='ListSelectCB(this)'>";

   #
   # Display the list of queries we have
   #

   for ($i=0; $i<count($queryinfo); $i++)
   {
      $tmp=split("\|",$queryinfo[$i]);
      if ( $tmp[3] == $user )
      {
         $z = sprintf("%s - %s",$tmp[3], $tmp[0]);
         $selected = ( $tmp[3] == $username && $tmp[0] == $queryname ) ? "SELECTED" : "";
         echo "<OPTION class='MediumBlackN' $selected VALUE='$tmp[3]-$tmp[0]'>${z}</OPTION>";
      }
   }

   for ($i=0; $i<count($queryinfo); $i++)
   {
      $tmp=split("\|",$queryinfo[$i]);
      if ( $tmp[3] != $user )
      {
         $z = sprintf("%s - %s",$tmp[3], $tmp[0]);
         $selected = ( $tmp[3] == $username && $tmp[0] == $queryname ) ? "SELECTED" : "";
         echo "<OPTION class='MediumBlackN' $selected VALUE='$tmp[3]-$tmp[0]'>${z}</OPTION>";
      }
   }
   echo "</SELECT>";
   echo "</TD></TR>";
   echo "</TABLE>";
   echo "<br><br><table width='95%'><tr><td align='center'>".$query_output."</td></tr></table>";#output the result table
   #
   # If we have a SQL query and the headers of the output table
   #    then we should output the data from the query using
   #    the headers of the output table
   #
     /*
   if ( $newqueryinfo != '' && $query_table != '' )
   {
      echo "<HR>";
      
    
      echo "<TABLE align='left' col=2 border='0' cellpadding='4' cellspacing='4'>";

      echo "<TR>";

      #
      # Output the headers of each column
      #
      for ($i=0; $i<count($query_table); $i++)
      {
         $tmp=split("\|",$query_table[$i]);
         echo "<TD class='MediumBlueB'>${tmp[0]}</TD>";
      }
      echo "</TR>";

      #
      # Output the data, if there is a blank spot then we fill it with --
      #
      for ($i=0; $i<count($query_output); $i++)
      {
         $tmp=split("\|",$query_output[$i]);
         echo "<TR>";
         for($j=0; $j<count($tmp); $j++)
         {
            $tmp[$j] = str_replace("\n","<BR>",$tmp[$j]);
            if ( $tmp[$j] == '' )
            {
               echo "<TD>--</TD>";
            }
            else
            {
               echo "<TD>${tmp[$j]}</TD>";
            }
         }
         echo "</TR>";
      }
      
   }
   echo "</TABLE>";*/
   echo "</BODY>";
   echo "</HTML>";
}

#
# Function DB_GetAllQueryList() ########################################################
#
function DB_GetAllQueryList()
{
   global $strat_abbr;
   
   $strat_num = DB_GetStrategyNum($strat_abbr);

   #
   # Get a list of all the queries from the database
   #
   $select = "SELECT name, command, comments, user ";
   $from = "FROM dbquery ";
   $where = "WHERE strategy_num = $strat_num ";
   $order = "ORDER BY user, name";

   return ccgg_query($select.$from.$where.$order);
}

#
# Function DB_UpdateInfo ##############################################################
#
function DB_UpdateInfo($newqueryinfo)
{
   global $strat_abbr;

   #
   # Update/Insert the inputted query
   #

   $user = GetUser();
   $strat_num = DB_GetStrategyNum($strat_abbr);

   #
   # Get date and time
   #
   $date = date("Y-m-d");
   $time = date("H:i:s");

   #
   # Parse the $newqueryinfo input to the variables that we want
   #
   $commentfield = split("\|",$newqueryinfo);
   for ($i=0; $i<count($commentfield); $i++)
   {
      list($n,$v)=split("\~",$commentfield[$i]);
      $v = addslashes($v);
      $set = ($i == 0) ? "${n}='${v}'" : "${set}, ${n}='${v}'";
      switch ($n) {
         case 'name':
            $name=$v;
            break;
         case 'command':
            $command=$v;
            break;
         case 'comments':
            $comments=$v;
            break;
      }
   }


   $sql = "SELECT COUNT(*) FROM dbquery";
   $sql = "${sql} WHERE name = '${name}' AND user = '${user}'";
   $sql = "${sql} AND strategy_num = '${strat_num}'";

   $res = ccgg_query($sql);

   #
   # If there is a count of 0, then we should insert. Otherwise, we should
   #    update.
   #
   $task = ($res[0] == '0') ? 'add' : 'update';

   #
   # Since the query already exists in the database, we should update it
   #
   if ( $task == 'update' )
   {
      if ( $name != '' && $command != '')
      {
         $sql = "UPDATE dbquery SET ${set} ";
         $sql = "${sql} WHERE name='${name}' AND user='$user'";
         $sql = "${sql} AND strategy_num = '${strat_num}'";

         #echo "$sql";
         $res = ccgg_insert($sql);
         if (!empty($res)) { return(FALSE); }
         return(TRUE);
      }
   }

   #
   # Since the query does not exist in the database, we should insert it
   #
   if ( $task == 'add' )
   {
      if ( $name != '' && $command != '')
      {
         $sql = "INSERT INTO dbquery";
         $sql = "${sql} VALUES ('$strat_num','$user','${name}','$date','$time','${command}','${comments}')";

         #echo "$sql";
         $res = ccgg_insert($sql);
         if (!empty($res)) { return(FALSE); }
         return(TRUE);
      }
   }
   return(FALSE);
}
#
# Function DB_DeleteInfo ########################################################
#
function DB_DeleteInfo($newqueryinfo)
{
   global $strat_abbr;
   #
   # Delete the query from the database
   #

   $user = GetUser();
   $strat_num = DB_GetStrategyNum($strat_abbr);

   #
   # Parse the input variable, getting the name
   #
   $commentfield = split("\|",$newqueryinfo);
   for ($i=0; $i<count($commentfield); $i++)
   {
      list($n,$v)=split("\~",$commentfield[$i]);
      $set = ($i == 0) ? "'${v}'" : "${set},'${v}'";
      if ( $n == 'name' )
      {
         $name = $v;
         continue;
      }
   }
   $name = addslashes($name);

   $sql = "DELETE FROM dbquery";
   $sql = "${sql} WHERE name ='${name}' AND user='$user'";
   $sql = "${sql} AND strategy_num = '${strat_num}'";
   $sql = "${sql} LIMIT 1";

   #echo "$sql";
   $res = ccgg_delete($sql);
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
?>
