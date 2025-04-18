<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
        exit;
}

$id = isset( $_POST['id'] ) ? $_POST['id'] : '';

if ( $id ) { $id = strtoupper($id); }

$strat_abbr = 'pfp';
$strat_name = 'PFP';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<FORM name='mainform' method=POST>";
echo "<SCRIPT language='JavaScript' src='pfp_toprep.js'></SCRIPT>";

if ($id)
{
   #
   # Is PFP in Boulder?
   #
   if(!(DB_PFPExist($id,$res))) { JavaScriptAlert("${id} is not in DB"); }
   else
   {
      $field = split("\|",$res[0]);   
      switch ($field[4])
      {
      case '2':
         $z = DB_GetSiteCode($field[1]);
                        list ($x,$y) = split("\|", DB_GetProjectInfo($field[8]));
         JavaScriptAlert("${id} was shipped to $z, $y on $field[2]");
         break;
      case '1':
         JavaScriptAlert("${id} is already in PFP Prep Room");
         break;
      default:
         if (DB_ToPfpPrep($id))
         { UpdateLog($log,"${id} returned to PFP Prep Room"); }
                   else
                   { JavaScriptAlert("Unable to return ${id} to PFP Prep"); }
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

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>To PFP Prep Room</TD>";
echo "</TR>";
echo "</TABLE>";

echo "<TABLE cellspacing=10 cellpadding=10 width='50%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center'>";
echo "<B><INPUT TYPE='text' class='SuperSizeBlackTurquoiseB' SIZE=10 NAME='id'><BR>";
echo "<FONT class='MediumBlackB'>Scan Only</FONT></TD>";
echo "</TR>";

JavaScriptCommand("document.mainform.id.focus()");

echo "<TR><TD valign='top'>";
echo "<TABLE cellspacing=10 cellpadding=10 width='20%' align='center'>";
echo "<TR>";
echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Ok' onClick='OkayCB()'>";
echo "</TD>";

echo "<TD align='center'>";
echo "<B><INPUT TYPE='button' class='Btn' value='Cancel' onClick='CancelCB()'>";
echo "</TD>";
echo "</TR>";
echo "</TABLE>";

echo "</TD>";
echo "</TR>";

if ( !empty($id) )
{
   echo "<TR>";
   echo "<TD>";
   $comments = DB_PFPNotes($id);

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
# Function DB_PFPExist ########################################################
#
function DB_PFPExist($id,&$res)
{
   #
   # Does PFP id exist in DB?
   #
   $sql = "SELECT * FROM pfp_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   return count($res);
}
#
# Function DB_PFPNotes ########################################################
#
function DB_PFPNotes($id)
{
   #
   # Indicate in DB that passed ID is in Flask Prep Room
   #
   $sql = "SELECT comments FROM pfp_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   if ( isset($res[0]) ) { return $res[0]; }
   else { return ''; }
}
#
# Function DB_ToPfpPrep ########################################################
#
function DB_ToPfpPrep($id)
{
   #
   # Indicate in DB that passed ID is in PFP Prep Room
   #
   list($pre,$suf) = split("-FP",$id);

   $sql = "UPDATE pfp_inv SET sample_status_num='1' WHERE id LIKE '${pre}-%'";

   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); } 
   return(TRUE);
}
?>
