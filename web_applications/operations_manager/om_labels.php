<?PHP
                                                                                          
include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

$printids = isset( $_POST['printids'] ) ? $_POST['printids'] : '';
$oldids = isset( $_POST['oldids'] ) ? $_POST['oldids'] : '';

echo "<SCRIPT language='JavaScript' src='om_labels.js'></SCRIPT>";

$tmpfile = 'dan.txt';
if (!($fp = fopen($tmpfile, "r")))
{ JavaScriptAlert("Unable to open ${tmpfile}.  Get help."); }

$contents = fread($fp, filesize($tmpfile));
$contents = chop($contents);
$id_arr = split("\n",$contents);
fclose($fp);

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $printids;
   global $oldids;
   global $id_arr;

   $printid_arr = split(",", $printids);
   $oldid_arr = split(",", $oldids);

   foreach ( $printid_arr as $print_id )
   { if ( !in_array($print_id,$oldid_arr)) { array_push($oldid_arr, $print_id); } }

   $oldids = implode(",", $oldid_arr);

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='printids'>";
   echo "<INPUT TYPE='HIDDEN' NAME='oldids' VALUE='$oldids'>";

   echo "<TABLE cellspacing=10 cellpadding=5 width='50%' border='1'>";
   echo "<TR>";
   echo "<TD width='10%'>Print?</TD>";
   echo "<TD width='25%'>ID</TD>";
   echo "<TD width='65%'>Status</TD>";
   echo "</TR>";

   $printerror = 0;
   foreach ( $id_arr as $id )
   {
      $status = "";
      if ( in_array($id, $printid_arr))
      {
         if ( $printerror == 0 )
         {
            $status = "Printing... ";
            # Send print command

            $cmd = "/projects/src/label/psu/makepsulabel.pl -l$id";
            exec($cmd, $output, $return);
            #print_r($output);
            #echo "$return";

            if ( $return == 0 )
            {
               $status = $status." ".implode("<BR>", $output);
               $printerror = 1;
            }
            else { $status = $status." Done"; }
         }
         else
         { $status = "Printer Error"; }
      }
      else
      {
         if ( in_array($id, $oldid_arr ) )
         { $status = "Printed"; }
      }

      echo "<TR>";
      echo "<TD align='center'>";
      $checked = '';
      if ( (!in_array($id,$printid_arr) && !in_array($id,$oldid_arr)) || $printerror)
      { $checked = 'CHECKED'; }
      echo "<INPUT TYPE='checkbox' name='printlist' value='$id' $checked>";
      echo "</TD>";
      echo "<TD>";
      echo "$id";
      echo "</TD>";
      echo "<TD>";
      echo "$status";
      echo "</TD>";
      echo "</TR>";
   }

   echo "</TABLE>";
   echo "<TABLE cellspacing=10 cellpadding=5 width='20%' border='1'>";
   echo "<TR><TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Print!' onClick='PrintCB()'>";
   echo "</TD></TR>";
}
