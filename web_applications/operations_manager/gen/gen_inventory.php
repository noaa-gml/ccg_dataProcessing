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

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$id = isset( $_POST['id'] ) ? $_POST['id'] : '';
$print = isset( $_POST['print'] ) ? $_POST['print'] : '';
$fm_comments = isset( $_POST['fm_comments'] ) ? $_POST['fm_comments'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$comment = '--';

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

$sql = "SELECT num, abbr, info, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_info, $gen_type_strategy_nums) = split("\|", $tmp[0]);

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_inventory.js'></SCRIPT>";

$statusinfo = DB_GetAllStatusList();

#
# Does unit exist in DB?
#
$nret = DB_UnitExist($id,$gen_type_num,$res);

if (empty($res)) { $res[0] = '|||||||'; }

$fields = explode("|",$res[0]);

$id = ( $fields[0] == '' ) ? $id : $fields[0];
$site_num = $fields[1];
$date_out = $fields[2];
$date_in = $fields[3];
$status_num = $fields[4];
$comments = $fields[5];

$fm_comments = ( empty($fm_comments) ) ? $comments : $fm_comments;

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
      if ($nret == 0) { $comment = "${id} does not exist in DB"; break; }
      $statusfield = split("\|",$statusinfo[$status_num-1]);
      if ( $status_num != '3' )
      {
         $comment = "${id} is $statusfield[1]";
      }
      else
      {
         $z = DB_GetSiteCode($site_num);
         $comment = "${id} was shipped to $z on $date_out";
      }
      #echo "$comment";
      $showdetails = 1;
      break;
   case "Add":
      if ($nret != 0) { $comment = "${id} already exists in DB."; break; }
      if ((DB_InsertUnit($id,$gen_type_num)))
      {
         $comment = "${id} added";
         #echo "$comment";
         UpdateLog($log,"${id} added");
      }
      else {JavaScriptAlert("Unable to add ${id}"); }
      break;
   case "Repair":
      if ($nret == 0) { $comment = "${id} does not exist in DB"; break; }
      if ( $status_num != '2' )
      {
         $comment = "${id} cannot be sent to Repair because not Available";
      }
      else
      {
         if ((DB_RepairUnit($id,$gen_type_num)))
         {
            $comment = "${id} sent to repair";
            #echo "$comment";
            UpdateLog($log,"${id} sent to repair");
         }
         else {JavaScriptAlert("Unable to send ${id} to repair"); }
      }
      break;
   case "Retire":
      if ($nret == 0) { $comment = "${id} does not exist in DB"; break; }
      if ( $status_num != '2' && $status_num != '4' )
      {
         $comment = "${id} cannot be Retired because not Available";
      }
      else
      {
         if ((DB_RetireUnit($id,$gen_type_num)))
         {
            $comment = "${id} retired";
            #echo "$comment";
            UpdateLog($log,"${id} retired");
         }
         else {JavaScriptAlert("Unable to retire ${id}"); }
      }
      break;
   case "Testing":
      if ($nret == 0) { $comment = "${id} does not exist in DB"; break; }
      if ( $status_num != '2' )
      {
         $comment = "${id} cannot be sent to Testing because not Available";
      }
      else
      {
         if ((DB_ToTestingUnit($id,$gen_type_num)))
         {
            $comment = "${id} sent to testing";
            #echo "$comment";
            UpdateLog($log,"${id} sent to testing");
         }
         else {JavaScriptAlert("Unable to send ${id} to Testing"); }
      }
      break;
   case "Notes":
      if ($nret == 0) { $comment = "${id} does not exist in DB"; break; }
      if ($fm_comments == "")
      {
         if ((DB_DeleteUnitNote($id,$gen_type_num)))
         {
            $comment = "${id} comments deleted";
            #echo "$comment";
            UpdateLog($log,"${id} comments deleted");
         }
         else {JavaScriptAlert("Unable to delete ${id} comments"); }
      }
      else
      {
         if ((DB_UpdateUnitNote($id,$gen_type_num,$fm_comments)))
         {
            $comment = "${id} comments updated";
            #echo "$comment";
            UpdateLog($log,"${id} comments update");
         }
         else {JavaScriptAlert("Unable to update ${id} comments"); }
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
global $gen_type_num;
global $gen_type_abbr;
global $comment;
global $fm_comments;
global $id;
global $print;
global $searched;
global $status_num;
global $task;
global $showdetails;

echo "<FORM name='mainform' method=POST onSubmit=\"if ( document.mainform.id.value == '' ) return false;\">";

echo "<INPUT type='HIDDEN' NAME='task' VALUE='Search'>";
echo "<INPUT type='HIDDEN' NAME='print' VALUE=$print>";
echo "<INPUT type='HIDDEN' NAME='searched' VALUE='$searched'>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>${gen_type_abbr} Inventory Manager</TD>";
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
echo "<TD align='right' width='50%'>";

echo "<TABLE>";
echo "<TR>";
echo "<TD valign=top>";
echo "<FONT class='LargeBlackB'>${gen_type_abbr} Id</FONT></TD>";
echo "<TD valign=top><INPUT type='text' onChange='IdChangeCB()' class='LargeBlackB'
onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)'
onKeyUp='ClearChk(this)' size=10 name='id' value='$id'>";
echo "<BR>Press ` to clear";
echo "</TD>";
echo "</TR>";
#echo "<TR>";
#echo "<TD></TD>";
#echo "<TD align='center'>";
#echo "<BR><FONT class='LargeBlueB'>$id</FONT>";
#echo "</TD>";
#echo "</TR>";
echo "</TABLE>";

JavaScriptCommand("document.mainform.id.focus()");

echo "</TD>";
echo "<TD align='left' width='50%'>";

echo "<TABLE>";
$labelarr = array('Search','Add','Retire','Repair','Testing');
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
   echo "<FONT class='LargeBlackB'>$label</FONT>";
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
echo "<TEXTAREA ROWS=5 COLS=60 NAME='fm_comments' DISABLED
onFocus='SetBackground2(this,true)' onBlur='SetBackground2(this,false)'>";
echo $fm_comments;
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
echo "<FONT class='LargeRedB' id='unitcomment'>${comment}</FONT>";
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

echo "</TABLE>";

echo "</BODY>";
echo "</HTML>";
}
#
# Function DB_UnitExist ########################################################
#
function DB_UnitExist($id,$gen_type_num,&$res)
{
   global $ccgg_equip;
   #
   # Does unit id exist in DB?
   #
   $sql = "SELECT id, site_num, date_out, date_in, gen_status_num, comments FROM ${ccgg_equip}.gen_inv WHERE id='${id}' AND gen_type_num='${gen_type_num}'";
   $res = ccgg_query($sql);
   return count($res);
}
#
# Function DB_InsertUnit ########################################################
#
function DB_InsertUnit($id,$gen_type_num)
{
   global $ccgg_equip;
   global $gen_type_info;
   #
   # Insert unit id into DB
   #
   $sql = "INSERT INTO ${ccgg_equip}.gen_inv (id,gen_type_num,gen_status_num)";
   $sql = "${sql} VALUES('${id}','${gen_type_num}','2')";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }

   $sql = "INSERT INTO ${ccgg_equip}.${gen_type_info} (gen_inv_id)";
   $sql = "${sql} VALUES('${id}')";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }

   return(TRUE);
}
#
# Function DB_DeleteUnitNote ########################################################
#
function DB_DeleteUnitNote($id,$gen_type_num)
{
   global $ccgg_equip;
   #
   # Delete unit comments in DB
   #
   $sql = "UPDATE ${ccgg_equip}.gen_inv SET comments='' WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_UpdateUnitNote ########################################################
#
function DB_UpdateUnitNote($id,$gen_type_num,$comments)
{
   global $ccgg_equip;
   #
   # Update unit comments in DB
   #
   $sql = "UPDATE ${ccgg_equip}.gen_inv SET comments='".mysql_real_escape_string($comments)."' WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_RepairUnit ########################################################
#
function DB_RepairUnit($id,$gen_type_num)
{
   global $ccgg_equip;
   #
   # Give unit 'in repair' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE ${ccgg_equip}.gen_inv SET date_out=\"${now}\",gen_status_num='4' WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_RetireUnit ########################################################
#
function DB_RetireUnit($id,$gen_type_num)
{
   global $ccgg_equip;
   #
   # Give unit 'retired' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE ${ccgg_equip}.gen_inv SET date_out=\"${now}\",gen_status_num='5' WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";

   #echo "$sql<BR>";
   $res = ccgg_insert($sql);
   #$res = "";
   if (!empty($res)) { return(FALSE); }
   return(TRUE);
}
#
# Function DB_ToTestingUnit ########################################################
#
function DB_ToTestingUnit($id,$gen_type_num)
{  
   global $ccgg_equip;
   #
   # Give unit 'in testing' status
   #
   $now=date("Y-m-d");

   $sql = "UPDATE ${ccgg_equip}.gen_inv SET date_out=\"${now}\",gen_status_num='1' WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";

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
   global $ccgg_equip;
   #
   # Get a list of all the units in the unit table
   #
   $select = " SELECT num, name";
   $from = " FROM ${ccgg_equip}.gen_status";
   $order = " ORDER BY num";

   return ccgg_query($select.$from.$order);
}
?>
