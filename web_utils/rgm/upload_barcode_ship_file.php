<?PHP

require_once "CCGDB.php";
require_once "DB_Cylinder.php";
require_once "DB_Location.php";
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

$location_num = isset( $_POST['location_num'] ) ? $_POST['location_num'] : '';
$location_comments = isset( $_POST['location_comments'] ) ? $_POST['location_comments'] : '';

$allowedExts = array("txt", "TXT");
$errors = array();

$extension = end(explode(".", $_FILES["file"]["name"]));
if ( $_FILES["file"]["type"] == "text/plain" &&
     $_FILES["file"]["size"] > 0 &&
     $_FILES["file"]["size"] < 1000 &&
     in_array($extension, $allowedExts) )
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

            $input_arr = split("\n", $contents);
         }
         catch(Exception $e)
         {
            array_push($errors, $e);
         }

         $cylinder_objs = array();

         # Process the lines in the file
         foreach ($input_arr as $input_line)
         {
            # Similar to chomp() in perl
            $input_line = chop($input_line);

            if ( preg_match('/^[0-9]{2}\/[0-9]{2}\/[0-9]{2},[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{2},.*$/',$input_line) )
            {
               # Don't use this date and time because the time in the barcode
               #   scanner can drift. Better to use the time when the user
               #   uploads the list.
               $input_fields = split(',', $input_line, 4);
               #list($input_date, $input_time, $device_id, $input_id) = split(',', $input_line, 4);

               $input_id = ( isset($input_fields[3]) ) ? $input_fields[3] : '';

               # Skip over any group separators because this is for shipping
               if ( $input_id === '-GS-' ) { continue; }

               try
               {
                  # Instantiate the cylinder to see if the ID exists
                  $cylinder_obj = new DB_Cylinder($database_object, $input_id, 'id');

                  #print_r($cylinder_obj);
                  array_push($cylinder_objs, $cylinder_obj);
               }
               catch(Exception $e)
               { array_push($errors, $e); }
            }
         }

         if ( count($errors) == 0 )
         {
            # Make the list of cylinder objects unique

            $cylinder_objs = array_values(array_unique_obj($cylinder_objs));

            # Process the objects

            try
            {
               $location_obj = new DB_Location($database_object, $location_num);

               foreach ( $cylinder_objs as $cylinder_obj )
               {
                  $cylinder_obj->ship($location_obj, $location_comments);
                  $cylinder_obj->saveToDB($_SESSION['user']);
                  #echo "<PRE>";
                  #print_r($cylinder_obj);
                  #echo "</PRE>";
               }

               echo "<DIV style='color:green'>File processed successfully.</DIV>";
               echo "<BR>";
            }
            catch(Exception $e)
            { array_push($errors, $e); }
         }
      }
   }
}
else
{
   $e = new Exception("Invalid input file. Must be non-empty text file and less than 1 KB.");
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
   echo " Please address them, if possible, and try to upload the file again. Otherwise, please contact  John Mund <A href=\"mailto:john.mund@noaa.gov\">john.mund@noaa.gov</A>.";
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
