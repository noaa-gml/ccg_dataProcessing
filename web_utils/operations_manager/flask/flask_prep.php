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

$strat_abbr = 'flask';
$strat_name = 'Flask';

$yr = date("Y");
$log = "${omdir}log/${strat_abbr}.${yr}";

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='flask_prep.js'></SCRIPT>";

if ($id)
{
   #
   # Is flask in Boulder?
   #
   if(!(DB_FlaskExist($id,$res))) { JavaScriptAlert("${id} is not in DB"); }
   else
   {
      $field = split("\|",$res[0]);   
      switch ($field[4])
      {
         case '2':
            $z = DB_GetSiteCode($field[1]);
            list($x,$y) = split("\|", DB_GetProjectInfo($field[7]));
            JavaScriptAlert("${id} was shipped to $z, $y on $field[2]");
            break;
         case '1':
            JavaScriptAlert("${id} is already in Flask Prep Room");
            break;
         case '6':
            #
            # Do not let the user put a flask in prep if there
            # is an open testing case
            #
            if ( DB_OpenTestCase($id) )
            {
               JavaScriptAlert("${id} has an open Test Case");
               break;
            }
         default:
            if (DB_ToFlaskPrep($id))
            { UpdateLog($log,"${id} returned to Flask Prep Room"); }
            else
            { JavaScriptAlert("Unable to return ${id} to Flask Prep"); }
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

echo "<FORM name='mainform' method=POST>";

echo "<TABLE cellspacing=10 cellpadding=10 width='100%' align='center'>";
echo "<TR align='center'>";
echo "<TD align='center' class='XLargeBlueB'>To Flask Prep Room</TD>";
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
   $comments = DB_FlaskNotes($id);

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
# Function DB_FlaskExist ########################################################
#
function DB_FlaskExist($id,&$res)
{
   #
   # Does flask id exist in DB?
   #
   $sql = "SELECT * FROM flask_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   return count($res);
}
#
# Function DB_FlaskNotes ########################################################
#
function DB_FlaskNotes($id)
{
   #
   # Indicate in DB that passed ID is in Flask Prep Room
   #
   $sql = "SELECT comments FROM flask_inv WHERE id='${id}'";
   $res = ccgg_query($sql);
   if ( isset($res[0]) ) { return $res[0]; }
   else { return ''; }
}
#
# Function DB_ToFlaskPrep ########################################################
#
function DB_ToFlaskPrep($id)
{
   #
   # Indicate in DB that passed ID is in Flask Prep Room
   #
   $sql = "UPDATE flask_inv SET sample_status_num='1' WHERE id='${id}'";
   $res = ccgg_insert($sql);
   if (!empty($res)) { return(FALSE); } 
   return(TRUE);
}
#
# Function DB_OpenTestCase ########################################################
#
function DB_OpenTestCase($id)
{
   $sql = "SELECT date_out FROM flask_log_case WHERE id = '${id}'";
   $res = ccgg_query($sql);

   for ( $i=0; $i<count($res); $i++ )
   {
      if ( $res[$i] == '0000-00-00' ) { return(TRUE); }
   }
   return(FALSE);
}
?>
