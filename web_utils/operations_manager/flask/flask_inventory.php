<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$flask_id = isset( $_POST['flask_id'] ) ? $_POST['flask_id'] : '';
$print = isset( $_POST['print'] ) ? $_POST['print'] : '';
$fm_note = isset( $_POST['fm_note'] ) ? $_POST['fm_note'] : '';

$strat_abbr = 'flask';
$strat_name = 'Flask';
$comment = '--';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_inventory.js'></SCRIPT>";

$statusinfo = DB_GetAllStatusList();

#
# Does Flask exist in DB?
#
$nret = DB_FlaskExist($flask_id,$res);

if (empty($res)) { $res[0] = '|||||||'; }

list($id,$site_num,$out,$in,$status_num,$path,$ev,$note)= split("\|",$res[0]);
$fm_notes = ($note != 'NULL') ? $note : '';

$searched = 0;
if ( $nret == 1 )
{
   $searched = 1;
}

#
# Show collection details? 0 - false, 1 - true
#
$showdetails = 0;

switch ($task)
{
   case "Search":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      $statusfield = split("\|",$statusinfo[$status_num-1]);
      if ( $status_num != '2' )
      {
         $comment = "${flask_id} is $statusfield[1]";
      }
      else
      {
         $z = DB_GetSiteCode($site_num);   
         $comment = "${flask_id} was shipped to $z on $out";
      }
      #echo "$comment";
      $showdetails = 1;
      break;
   case "Add":
      if ($nret != 0) { $comment = "${flask_id} already exists in DB."; break; }
      if ((DB_InsertFlask($flask_id)))
      {
         $comment = "${flask_id} added";
         #echo "$comment";
         UpdateLog($log,"${flask_id} added");
      }
      else {JavaScriptAlert("Unable to add ${flask_id}"); }
      break;
   case "Not in Use":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' )
      {
         $comment = "${flask_id} cannot be sent to 'Not in Use' because not In Prep";
      }
      else
      {
         if ((DB_NotInUseFlask($flask_id)))
         {
            $comment = "${flask_id} sent to not in use";
            #echo "$comment";
            UpdateLog($log,"${flask_id} sent to not in use");
         }
         else {JavaScriptAlert("Unable to send ${flask_id} to not in use"); }
      }
      break;
   case "Retire":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' && $status_num != '4' )
      {
         $comment = "${flask_id} cannot be Retired because not In Prep";
      }
      else
      {
         if ((DB_RetireFlask($flask_id)))
         {
            $comment = "${flask_id} retired";
            #echo "$comment";
            UpdateLog($log,"${flask_id} retired");
         }
         else {JavaScriptAlert("Unable to retire ${flask_id}"); }
      }
      break;
   case "Leak Test":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' )
      {
         $comment = "${flask_id} cannot be sent to Leak Test because not In Prep";
      }
      else
      {
         if ((DB_LeakTestFlask($flask_id)))
         {
            $comment = "${flask_id} sent to leak test";
            #echo "$comment";
            UpdateLog($log,"${flask_id} sent to leak test");
         }
         else {JavaScriptAlert("Unable to send ${flask_id} to Leak Test"); }
      }
      break;
   case "Notes":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ($fm_note == "")
      {
         if ((DB_DeleteFlaskNote($flask_id)))
         {
            $fm_notes = $fm_note;
            $comment = "${flask_id} note deleted";
            #echo "$comment";
            UpdateLog($log,"${flask_id} note deleted");
         }
         else {JavaScriptAlert("Unable to delete ${flask_id} notes"); }
      }
      else
      {
         if ((DB_UpdateFlaskNote($flask_id,$fm_note)))
         {
            $fm_notes = $fm_note;
            $comment = "${flask_id} note updated";
            #echo "$comment";
            UpdateLog($log,"${flask_id} note update");
         }
         else {JavaScriptAlert("Unable to update ${flask_id} notes"); }
      }
      break;
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
global $comment;
global $flask_id;
global $fm_notes;
global $print;
global $searched;
global $ev;
global $status_num;
global $task;
global $showdetails;

echo "<FORM name='mainform' method=POST onSubmit=\"if ( document.mainform.flask_id.value == '' ) return false;\">";

echo "<INPUT type='HIDDEN' NAME='task' VALUE='Search'>";
echo "<INPUT type='HIDDEN' NAME='print' VALUE=$print>";
echo "<INPUT type='HIDDEN' NAME='fm_notes' VALUE='${fm_notes}'>";
echo "<INPUT type='HIDDEN' NAME='searched' VALUE='$searched'>";
#echo "<INPUT type='HIDDEN' NAME='flaskid' VALUE='$flask_id'>";

echo "<TABLE cells; }cing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Flask Inventory Manager</TD>";
echo "</TR>";
echo "</TABLE>";
#
##############################
# Define OuterMost Table
##############################
#
echo "<TABLE col=2 align='center' width=100% border='0' cellpadding='10' cellspacing='10'>";
#
##############################
# Row 1: Column Headers
##############################
#
echo "<TR>";
echo "<TD align='right'>";

echo "<TABLE>";
echo "<TR>";
echo "<TD valign=top>";
echo "<FONT class='LargeBlackB'>Flask Id</FONT></TD>";
echo "<TD valign=top><INPUT type='text' onChange='IdChangeCB()' class='LargeBlackB'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
onKeyUp='ClearChk(this)' size=10 name='flask_id' value='$flask_id'>";
echo "<BR>Press ` to clear";
echo "</TD>";
echo "</TR>";
#echo "<TR>";
#echo "<TD></TD>";
#echo "<TD align='center'>";
#echo "<BR><FONT class='LargeBlueB'>$flask_id</FONT>";
#echo "</TD>";
#echo "</TR>";
echo "</TABLE>";

JavaScriptCommand("document.mainform.flask_id.focus()");

echo "</TD>";
echo "<TD align='left'>";

echo "<TABLE>";
$labelarr = array('Search','Add','Retire','Not in Use','Leak Test');
foreach ( $labelarr as $label )
{
   echo "<TR>";
   echo "<TD>";
   $checked = "";
   if ( $label == "Search" )
   {
      $checked = "CHECKED";
   }
   echo "<INPUT TYPE='radio' onclick=\"InventoryCB('$label')\" $checked NAME='radio' VALUE=$label>";
   if ( $label == "Add" )
   {
      echo "<FONT class='LargeBlackB'>$label&nbsp&nbsp&nbsp&nbsp</FONT>";
      $checked = ($print=='true' || empty($print)) ? 'CHECKED' : '';
      echo "<INPUT TYPE='checkbox' NAME='fm_print' CHECKED DISABLED>";
      echo "<FONT class='SmallBlackB'>Create/Print UPC label</FONT>";
   }
   else
   {
      echo "<FONT class='LargeBlackB'>$label</FONT>";
   }
   echo "</TD>";
   echo "</TR>";
}
echo "<TR>";
echo "<TD>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";

echo "<TR>";
echo "<TD colspan=2>";

echo "<TABLE width='100%' cellspacing='2' cellpadding='2' align='center'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<TABLE border='0'>";
echo "<TR>";
echo "<TD>";
echo "<TEXTAREA ROWS=5 COLS=60 id='flasknote' NAME='fm_note' DISABLED
onFocus='SetBackground2(this,true)' onBlur='SetBackground2(this,false)'>";
echo $fm_notes;
echo "</TEXTAREA>";
echo "</TD>";
echo "<TD align='left'>";
echo "<IMG SRC='../images/date.png' ALT='Date' onClick='DateText()'>";
echo "<BR>";
echo "<IMG SRC='../images/pencil.png' ALT='Edit' onClick='EnableText()'>";
echo "<BR>";
echo "<IMG SRC='../images/eraser.png' ALT='Clear' onClick='ClearText()'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<P align='center'>";
echo "<FONT class='LargeRedB' id='flaskcomment'>${comment}</FONT>";
echo "</P>";
echo "<TABLE width='10%' cellspacing='2' cellpadding='2' align='center'>";

echo "<TR>";
echo "<TD align='center'>";
#echo "<B><INPUT TYPE='submit' class='Btn' value='Ok'
#onClick='if (OkayCB()) return true; else return false;'>";
echo "<INPUT TYPE='button' name='okupdate' class='Btn' value='Ok' onClick='OkayCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";

echo "</TR>";
echo "</TABLE>";
/*
#commented out.  This was supposed to print event details on flasks that are in analysis loop (just for info).  It wasn't coded right though and outputs garbage.  Since never worked, just removed instead of fixing.  jwm 5/24
$perlcode = "/projects/src/db/ccg_flask.pl";
$z = $perlcode." -event=num:$ev"; 

$col_details = '';

if ( $showdetails == 1 && $ev != '0' && $ev != '' && $status_num == 3 && $task != "Notes" && $task != "Add")
{
   $col_details = exec($z,$arr,$ret);
}


echo "<P align='center'>";
echo "<FONT class='LargeGreenB' id='coldetails'>${col_details}</FONT>";
echo "</P>";
*/
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_FlaskExist ########################################################
#
function DB_FlaskExist($id,&$res)
{
   #
   # Does flask id exist in DB?
   #
   $sql = "SELECT id, site_num, date_out, date_in, sample_status_num, path, event_num, comments FROM flask_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   return count($res);
}
#
# Function DB_InsertFlask ########################################################
#
function DB_InsertFlask($id)
{
   #
   # Insert flask id into DB
   #
   $sql = "INSERT INTO flask_inv (id,site_num,sample_status_num) VALUES('${id}','0','1')";
   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_DeleteFlaskNote ########################################################
#
function DB_DeleteFlaskNote($id)
{
   #
   # Delete flask note in DB
   #
   $sql = "UPDATE flask_inv SET comments=\"NULL\" WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_UpdateFlaskNote ########################################################
#
function DB_UpdateFlaskNote($id,$note)
{
   #
   # Update flask note in DB
   #
   $sql = "UPDATE flask_inv SET comments=\"$note\" WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_NotInUseFlask ########################################################
#
function DB_NotInUseFlask($id)
{
   #
   # Give flask 'not in use' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE flask_inv SET date_out=\"${now}\",sample_status_num='4' WHERE id='${id}'";
   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_RetireFlask ########################################################
#
function DB_RetireFlask($id)
{
   #
   # Give flask 'retired' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE flask_inv SET date_out=\"${now}\",sample_status_num='5' WHERE id='${id}'";
   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_LeakTestFlask ########################################################
#
function DB_LeakTestFlask($id)
{
   #
   # Give flask 'in testing' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE flask_inv SET date_out=\"${now}\",sample_status_num='6' WHERE id='${id}'";
   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
#
# Function DB_GetAllStatusList ##################################################
#
function DB_GetAllStatusList()
{
   #
   # Get a list of all the units in the unit table
   #
   $select = "SELECT num, name ";
   $from = "FROM sample_status ";
   $order = "ORDER BY num";

   return ccgg_query($select.$from.$order);
}
?>
