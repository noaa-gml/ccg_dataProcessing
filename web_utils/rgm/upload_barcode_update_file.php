<?PHP
/*Updated to add cylinder type.
 *jwm 10-15
 */
require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "DB_CylinderManager.php";
require_once "Log.php";
require_once "utils.php";

session_start();

$database_object = new CCGDB();

$user_obj = ( isset($_SESSION['user']) ) ? $_SESSION['user'] : '';
ValidateAuthentication($database_object, $user_obj);
?>

<HTML>
 <HEAD>
  <LINK rel="stylesheet" type="text/css" href="mobile.css" media="screen and (max-device-width:800px)" />
  <LINK rel="stylesheet" type="text/css" href="desktop.css" media="screen and (min-device-width:801px)">
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" />
 </HEAD>
 <BODY>

<?PHP
# Please see
# http://www.w3schools.com/php/php_file_upload.asp

$allowedExts = array("txt", "TXT");
$errors = array();

$cylinder_size_aarr = DB_CylinderManager::getCylinderSizes($database_object);
$cylinder_type_aarr = DB_CylinderManager::getCylinderTypes($database_object);

$extension = end(explode(".", $_FILES["file"]["name"]));
if (($_FILES["file"]["type"] == "text/plain") &&
    ($_FILES["file"]["size"] < 100000) &&
    in_array($extension, $allowedExts))
{
   if ($_FILES["file"]["error"] > 0)
   {
      #echo "Return Code: " . $_FILES["file"]["error"] . "<br>";
      $e = new Exception("Return Code: " . $_FILES["file"]["error"]);
      array_push($errors, $e);
   }
   else
   {
      #echo "Upload: " . $_FILES["file"]["name"] . "<br>";
      #echo "Type: " . $_FILES["file"]["type"] . "<br>";
      #echo "Size: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
      #echo "Temp file: " . $_FILES["file"]["tmp_name"] . "<br>";

      $nowstr = date("Y-m-dTHis");

      $localfile = "upload/".$nowstr."_" . $_FILES["file"]["name"];
      $historyfile = "upload/history/".$nowstr."_" . $_FILES["file"]["name"];

      if (file_exists($localfile))
      {
         echo $localfile. " already exists. ";
      }
      else
      {

         $input_arr = array();
         try
         {
            # Move the temporary file to the $localfile location
            move_uploaded_file($_FILES["file"]["tmp_name"], $localfile);
            #echo "Stored in: " . $localfile;

            # Read the file and then delete it
            $contents = file_get_contents($localfile);
            copy($localfile, $historyfile);
            unlink($localfile);

            $input_arr = explode("\n", $contents);

            #echo "<PRE>";
            #print_r($input_arr);
            #echo "</PRE>";

            $cln_process_aarr = array ();
            foreach ($input_arr as $input_line )
            {
               $input_line = chop($input_line);

               if ( ! preg_match('/[A-Za-z0-9]/', $input_line) ) { continue; }

               $fields = explode(',' ,$input_line);

               $tmpaarr = array();
               $tmpaarr['id'] = $fields[0];

               if ( isset($_POST['recertification_date']) &&
                    preg_match('/^[0-9]{2}\-[0-9]{2}$/', $_POST['recertification_date']) )
               {
                  $tmpaarr['recertification_date'] = ($_POST['recertification_date']);
               }
               else
               {
                  $tmpaarr['recertification_date'] = '99-99';
               }

               if ( isset($_POST['size_num']) &&
                    in_array($_POST['size_num'], array_keys($cylinder_size_aarr)) )
               {
                  $tmpaarr['size_num'] = $_POST['size_num'];
               }
               else
               {
                  $tmpaarr['size_num'] = '8';
               }
               
               if ( isset($_POST['type_num']) &&
                    in_array($_POST['type_num'], array_keys($cylinder_type_aarr)) )
               {
                  $tmpaarr['type_num'] = $_POST['type_num'];
               }
               else
               {
                  //If no valid value passed (this select can be left blank), set to false so that we don't override the current value
                  $tmpaarr['type_num'] = false;
               }
               
               array_push($cln_process_aarr, $tmpaarr);
            }

            #echo "<PRE>";
            #print_r($cln_process_aarr);
            #echo "</PRE>";

            try
            {
               foreach ( $cln_process_aarr as $aarr )
               {
                  # Instantiate the cylinder
                  $cylinder_obj = new DB_Cylinder($database_object, $aarr['id'], 'id');
                  $cylinder_obj->setRecertificationDate($aarr['recertification_date']);
                  $cylinder_obj->setSize($aarr['size_num'], 'num');
                  //Type is optional, if not passed, leave at current value
                  if($aarr['type_num']!==false)$cylinder_obj->setType($aarr['type_num'], 'num');
                  
                  
                  #echo "<PRE>";
                  #print_r($cylinder_obj);
                  #echo "</PRE>";
                  $cylinder_obj->saveToDB($_SESSION['user']);
               } 
               echo "<DIV style='color:green'>File processed successfully.</DIV>";
               echo "<BR>";
            }
            catch(Exception $e)
            {
               array_push($errors, $e);
            }
         }
         catch(Exception $e)
         {
            array_push($errors, $e);
         }
      }
   }
}
else
{
   $e = new Exception("Invalid input file. Must be text file and less than 100 KB.");
   array_push($errors, $e);
}

if ( count($errors) > 0 )
{
   echo "<TABLE>";
   echo " <TR>";
   echo "  <TD>";
   echo "The following errors were encountered:";
   echo "  </TD>";
   echo " </TR>";
   echo " <TR>";
   echo "  <TD>";
   echo "   <UL>";
   foreach ( $errors as $e )
   {
      Log::update($user_obj->getUsername(), $e->__toString());
      echo "<LI><DIV style='color:red'>".$e->getMessage()."</DIV></LI>";
   }
   echo "   </UL>";
   echo "  </TD>";
   echo " </TR>";
   echo " <TR>";
   echo "  <TD>";
   echo " Please address them, if possible, and try to upload the file again. Otherwise, please contact John Mund <A href=\"mailto:john.mund@noaa.gov\">john.mund@noaa.gov</A>.";
   echo "  </TD>";
   echo " </TR>";
   echo "</TABLE>";
}

?> 
  <FORM>
   <TABLE class='MenuTable' cellspacing='5' cellpadding='5'>
    <TR>
     <TD align='left' width='50%'>
     </TD>
     <TD align='right' width='50%'>
<?PHP #         <INPUT type='button' value='Back' onClick='window.location.href=window.location.href.substring(0, window.location.href .indexOf("?"));'> ?>
      <A href='index.php'><INPUT type='button' value='Back'></A>
     </TD>
    </TR>
    <TR>
     <TD align='left' width='50%'>
      <A href='index.php'><INPUT type='button' value='Home'></A>
     </TD>
     <TD align='right' width='50%'>
     </TD>
    </TR>
   </TABLE>
   <?PHP # This is for the menu that pops up at the bottom of the android screen. ?>
   <BR>
   <BR>
   <BR>
  </FORM> 
<?PHP NoCacheLinks(); ?>
 </BODY>
</HTML>
