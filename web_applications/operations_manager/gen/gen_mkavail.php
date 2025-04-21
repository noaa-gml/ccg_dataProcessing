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

$id = isset( $_POST['id'] ) ? $_POST['id'] : '';

$invtype = isset( $_GET['invtype'] ) ? $_GET['invtype'] : '';

$sql = "SELECT num, abbr, strategy_nums FROM ${ccgg_equip}.gen_type WHERE abbr = '$invtype'";
$tmp = ccgg_query($sql);

list($gen_type_num, $gen_type_abbr, $gen_type_strategy_nums) = split("\|", $tmp[0]);

$yr = date("Y");
$log = "${omdir}log/".strtolower($invtype).".${yr}";

BuildInvBanner($gen_type_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='gen_mkavail.js'></SCRIPT>";

if ($id)
{
   #
   # Is flask in Boulder?
   #
   if(!(DB_UnitExist($id,$gen_type_num,$res))) { JavaScriptAlert("${id} is not in DB"); }
   else
   {
      $field = explode("|",$res[0]);
      switch ($field[8])
      {
         case '2':
            JavaScriptAlert("${id} is already Available");
            break;
         case '3':
            $z = DB_GetSiteCode($field[2]);
            list($x,$y) = split("\|", DB_GetProjectInfo($field[3]));
            JavaScriptAlert("${id} was shipped to $z, $y on $field[4]");
            break;
         case '1':
            if ( DB_OpenTestCase($id) )
            {
               JavaScriptAlert("${id} cannot bo made available for checkout\\n because it has an open Test Case");
               break;
            }
         default:
            if (DB_ToUnitPrep($id))
            { UpdateLog($log,"${id} made Available"); }
            else
            { JavaScriptAlert("Unable to make ${id} Available"); }
            break;
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
global $id;
global $gen_type_num;
global $gen_type_abbr;

echo "<FORM name='mainform' method=POST>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>Make ${gen_type_abbr} Available</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE cellspacing=5 cellpadding=5 width='50%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center'>";
echo "<B><INPUT TYPE='text' class='SuperSizeBlackTurquoiseB' SIZE=10 NAME='id'><BR>";
echo "<FONT class='MediumBlackB'>Scan Only</FONT></TD>";
echo "</TR>";

JavaScriptCommand("document.mainform.id.focus()");

echo "<TR><TD valign='top'>";
echo "<TABLE cellspacing=0 cellpadding=0 width='50%' align='center'>";
echo "<TR>";
echo "<TD align='center' width='50%'>";
echo "<B><INPUT TYPE='button' class='Btn' NAME='Task' value='Ok' onClick='OkayCB()'>";
echo "</TD>";

echo "<TD align='center' width='50%'>";
echo "<B><INPUT TYPE='button' class='Btn' NAME='Task' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";
echo "</TD>";
echo "</TR>";

if ( !empty($id) )
{
   echo "<TR>";
   echo "<TD>";
   $comments = DB_UnitComments($id,$gen_type_num);

   if ( !empty($comments) )
   { echo "<FONT class='MediumRedB'>[$id]: $comments </FONT>"; }
   echo "</TD>";
   echo "</TR>";
}
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
   # Does flask id exist in DB?
   #
   $sql = "SELECT * FROM ${ccgg_equip}.gen_inv WHERE id='${id}' AND gen_type_num = '${gen_type_num}'";
   $res = ccgg_query($sql);
   return count($res);
}
#
# Function DB_UnitComments ########################################################
#
function DB_UnitComments($id)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Find the unit comments
   #
   $sql = "SELECT comments FROM ${ccgg_equip}.gen_inv WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";
   $res = ccgg_query($sql);
   if ( isset($res[0]) ) { return $res[0]; }
   else { return ''; }
}
#
# Function DB_ToUnitPrep ########################################################
#
function DB_ToUnitPrep($id)
{
   global $ccgg_equip;
   global $gen_type_num;
   #
   # Indicate in DB that passed ID is now available for checkout
   #
   $sql = "UPDATE ${ccgg_equip}.gen_inv SET gen_status_num='2' WHERE id='${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";
   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); } 
   return(TRUE);
}
#
# Function DB_OpenTestCase ########################################################
#
function DB_OpenTestCase($id)
{
   global $ccgg_equip;
   global $gen_type_num;

   $sql = "SELECT date_out FROM ${ccgg_equip}.gen_tlog_case WHERE gen_inv_id = '${id}'";
   $sql = "${sql} AND gen_type_num = '${gen_type_num}'";
   $res = ccgg_query($sql);

   for ( $i=0; $i<count($res); $i++ )
   {
      if ( $res[$i] == '0000-00-00' ) { return(TRUE); }
   }
   return(FALSE);
}
?>
