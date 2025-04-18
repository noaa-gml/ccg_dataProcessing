<?PHP
#jwm - 8.23 - added 'in testing', 'Reserved' and changed 'not in use' to 'in repair' status.
#To add others, search and copy 'in testing'  logic below. and then modify pfp_viewer.php similarly
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
$fiu = isset( $_POST['fiu'] ) ? $_POST['fiu'] : '';
$fm_note = isset( $_POST['fm_note'] ) ? $_POST['fm_note'] : '';

$strat_abbr = 'pfp';
$strat_name = 'PFP';
$comment = '--';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='pfp_inventory.js'></SCRIPT>";

$statusinfo = DB_GetAllStatusList();

#
# Does Flask exist in DB?
#
$nret = DB_FlaskExist($flask_id, $res);

if ( empty($res[0]) ) { $res[0] = '|||||||'; }

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
      $showdetails = 1;
      #echo "$comment";
      break;
   case "Add":
      if ($nret != 0) { $comment = "${flask_id} already exists in DB."; break; }
      if (DB_InsertFlask($flask_id,$fiu))
      {
         $comment = "${flask_id} added";
         #echo "$comment";
         UpdateLog($log,"${flask_id} added");
      }
      else {JavaScriptAlert("Unable to add ${flask_id}"); }
      break;
   case "In Repair":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' )
      {
         $comment = "${flask_id} cannot be sent to In Repair because not In Prep";
      }
      else
      {
         if ((DB_InRepairFlask($flask_id)))
         {
            $comment = "${flask_id} sent to In Repair";
            #echo "$comment";
            UpdateLog($log,"${flask_id} sent to In Repair");
         }
         else {JavaScriptAlert("Unable to send ${flask_id} to In Repair"); }
      }
      break;
   case "In Testing":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' )
      {
         $comment = "${flask_id} cannot be sent to In Testing because not In Prep";
      }
      else
      {
         if ((DB_inTesting($flask_id)))
         {
            $comment = "${flask_id} sent to In Testing";
            #echo "$comment";
            UpdateLog($log,"${flask_id} sent to In Testing");
         }
         else {JavaScriptAlert("Unable to send ${flask_id} to In Testing"); }
      }
      break;
   case "Reserved":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' )
      {
         $comment = "${flask_id} cannot be sent to Reserved because not In Prep";
      }
      else
      {
         if ((DB_reserved($flask_id)))
         {
            $comment = "${flask_id} sent to Reserved";
            #echo "$comment";
            UpdateLog($log,"${flask_id} sent to Reserved");
         }
         else {JavaScriptAlert("Unable to send ${flask_id} to Reserved"); }
      }
      break;
   case "Retire":
      if ($nret == 0) { $comment = "${flask_id} does not exist in DB"; break; }
      if ( $status_num != '1' || $status_num == '4' )
      {
         $comment= "${flask_id} cannot be deleted from DB"; break;
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
global $fiu;
global $searched;
global $ev;
global $status_num;
global $task;
global $showdetails;
global $omdir;

echo "<FORM name='mainform' method=POST onSubmit=\"if ( document.mainform.flask_id.value == '' ) return false;\">";

echo "<INPUT type='HIDDEN' NAME='task' VALUE='Search'>";
echo "<INPUT type='HIDDEN' NAME='fiu' VALUE='$fiu'>";
echo "<INPUT type='HIDDEN' NAME='fm_notes' VALUE='${fm_notes}'>";
echo "<INPUT type='HIDDEN' NAME='searched' VALUE='$searched'>";
#echo "<INPUT type='HIDDEN' NAME='flaskid' VALUE='$flask_id'>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>PFP Inventory Manager</TD>";
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
echo "<FONT class='LargeBlackB'>PFP Id</FONT></TD>";
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
$labelarr = array('Search','Add','Retire','In Repair','In Testing','Reserved');
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
      echo "<SELECT class='MediumBlackN' NAME='fm_fiu' DISABLED SIZE='1'>";
      echo "<OPTION VALUE='12'>12</OPTION>";
      echo "<OPTION VALUE='17'>17</OPTION>";
      echo "<OPTION VALUE='20'>20</OPTION>";
      echo "</SELECT>";
      echo "<FONT class='MediumBlackN'>Flasks in Unit</FONT>";
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
$t='>In repair - not operational, needs maintenance, new flasks, etc. \n>Retired - obsolete equipment ver 2, damaged beyond repair or returned to original owner - NCAR, LLBL etc\n>In prep - available to send out to network sites \n>Checked out - checked out to site \n>In analysis - PFPs circulating through measurement labs \n>Reserved - clean PFPs set aside for campaigns or in-house testing\n>In testing - identified as dirty/contaminated and needs to be cleaned and/or tested ';

$help="<a href='' id='alertButton' name='help'>Help?</a>
		<script>
		    var button = document.getElementById('alertButton');
		    button.addEventListener('click', function (event) {
                // Prevent the form from submitting
                event.preventDefault();

                // Display an alert when the button is clicked
                alert('${t}');
                return false;
            });
		</script>";
echo $help;
#echo "<button name='help' onClick=\"alert('$t');return false;\">?</button>";
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

$col_details = '';

if ( $flask_id != '' && $showdetails == 1 && $status_num == 3 && $task != "Notes" && $task != "Add")
{
   $eventscode = "/projects/src/db/ccg_inanalysis.pl -i${flask_id}";
   exec($eventscode,$arr,$ret);

   #
   # If there is nothing returned, set the eventmax and eventmin
   # numbers to impossible event ids. Otherwise loop through the
   # event numbers and get the max and min
   #
   $eventmax = -99;
   $eventmin = -99;
   if ( count($arr) != 0 )
   {
      for ( $i=0; $i<count($arr); $i++ )
      {
         $tmp = split(" ",$arr[$i]);
         $eventsnum[$i] = $tmp[0];
      }
      $eventmax = max($eventsnum);
      $eventmin = min($eventsnum);
   }

   $perlcode = "/projects/src/db/ccg_flask.pl";
   $z = $perlcode." -t -enum:${eventmin},${eventmax}";

   exec($z,$col_details,$ret);
}

echo "<P align='center'>";
echo "<FONT class='LargeGreenB' id='coldetails'>";
for ( $j = 0; $j<count($col_details); $j++ )
{
   if ( isset($col_details[$j]) ) { echo "$col_details[$j]<BR>"; }
}
echo "</FONT>";
echo "</P>";

echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_FlaskExist ########################################################
#
function DB_FlaskExist($id, &$res)
{
   #
   # Does flask id exist in DB?
   #
   $sql = "SELECT id, site_num, date_out, date_in, sample_status_num, path, event_num, comments FROM pfp_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   return count($res);
}
#
# Function DB_InsertFlask ########################################################
#
function DB_InsertFlask($id,$nflasks)
{
   #
   # Insert flask id into DB
   #
   $z = strtoupper($id);
   $insert = "INSERT INTO pfp_inv";
   $attributes = " (id,site_num,sample_status_num,nflasks,comments)";
   $values = " VALUES('${z}','0','1','${nflasks}','')";

   #echo "$insert$attributes$values<BR>";
   $res = ccgg_insert($insert.$attributes.$values);
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
   $sql = "UPDATE pfp_inv SET comments=\"NULL\" WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #res = "";
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
   $sql = "UPDATE pfp_inv SET comments=\"$note\" WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_InRepairFlask ########################################################
#
function DB_InRepairFlask($id)
{
   #
   # Give flask 'not in use' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE pfp_inv SET date_out=\"${now}\",sample_status_num='4' WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
###in testing. jwm - 8.23
function DB_inTesting($id)
{
   #
   # Give flask 'testing' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE pfp_inv SET date_out=\"${now}\",sample_status_num='6' WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}

function DB_reserved($id)
{
   #
   # Give flask 'testing' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE pfp_inv SET date_out=\"${now}\",sample_status_num='7' WHERE id='${id}'";

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

   $sql = "UPDATE pfp_inv SET date_out=\"${now}\",sample_status_num='5' WHERE id='${id}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
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
