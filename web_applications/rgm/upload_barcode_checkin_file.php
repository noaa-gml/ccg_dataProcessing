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

$allowedExts = array("txt", "TXT");
$errors = array();
$cylids=array();

$extension = end(explode(".", $_FILES["file"]["name"]));
if ( $_FILES["file"]["type"] == "text/plain" &&
     $_FILES["file"]["size"] > 0 &&
     $_FILES["file"]["size"] < 10000 &&
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

            $cln_process_aarr = array();

            $process_arr = array ();
            foreach ($input_arr as $input_line )
            {
               if ( ! preg_match('/^[0-9]{2}\/[0-9]{2}\/[0-9]{2},[0-9]{2}:[0-9]{2}:[0-9]{2},[0-9]{2},(.*$)/',$input_line, $input_value) ) { continue; }

               array_push($process_arr, chop($input_value[1]));
            }

            array_unshift($process_arr, '-GS-');
            array_push($process_arr, '-GS-');

            #echo "<PRE>";
            #print_r($process_arr);
            #echo "</PRE>";

            $separator_arr = preg_grep('-GS-', $process_arr);

            $separator_idxs = array_keys($separator_arr);

            sort($separator_idxs);

            #print_r($separator_idxs);

            for ($idx1=0, $idx2=1; $idx2 < count($separator_idxs); $idx1++, $idx2++ )
            {
               #print $idx1.' '.$idx2."<BR>";
               $begin_idx = $separator_idxs[$idx1]+1;
               $end_idx = $separator_idxs[$idx2];
               $diff = $end_idx - $begin_idx;

               #print '<BR>Group number '.$idx2."<BR>";

               if ( $diff > 1 )
               {
                  $cylinder_objs = array();

                  $subsetarr = array_slice($process_arr, $begin_idx, $diff);

                  #echo "<PRE>";
                  #print_r($subsetarr);
                  #echo "</PRE>";

                  $location_comments = array_pop($subsetarr);

                  foreach ( $subsetarr as $input_id )
                  {
                     try
                     {
                        # Instantiate the cylinder to see if the ID exists
                        $cylinder_obj = new DB_Cylinder($database_object, $input_id, 'id');

                        #print_r($cylinder_obj);
                        array_push($cylinder_objs, $cylinder_obj);
                     } 
                     catch(Exception $e)
                     {
                        $error = new Exception($e->getMessage()." in group $idx2.");
                        array_push($errors, $error);
                     }
                  }

                  #
                  # If there are cylinder objects and we have location comments
                  #  then add them to $cln_process_aarr
                  #
                  $tmpaarr = array();
                  $tmpaarr['location_comments'] = $location_comments;

                  # Get unique cylinder objects
                  $cylinder_objs = array_values(array_unique_obj($cylinder_objs));

                  $tmpaarr['cylinder_objs'] = $cylinder_objs;

                  # Push to cln_process_aarr
                  array_push($cln_process_aarr, $tmpaarr);

                  # Clear the information
                  $location_comments = '';
                  $cylinder_objs = array();
               }
            }
         }
         catch(Exception $e)
         {
            array_push($errors, $e);
         }


         #echo "<PRE>";
         #print_r($cln_process_aarr);
         #echo "</PRE>";

         if ( count($errors) == 0 )
         {
            # Process $cln_process_arr

            try
            {
               $location_obj = new DB_Location($database_object, $location_num);

               foreach ( $cln_process_aarr as $aarr )
               {
                  foreach ( $aarr['cylinder_objs'] as $cylinder_obj)
                  {
                     $cylinder_obj->checkin($location_obj, $aarr['location_comments']);
                     $cylinder_obj->saveToDB($_SESSION['user']);
                     $cylids[]=$cylinder_obj->getID();
                  }
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
   $e = new Exception("Invalid input file. Must be non-empty text file less than 10 KB.");
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
<?PHP
#Do a popup with any check in notes.
#ini_set("error_log","/var/www/html/mund/rgm/j/log/php_err.log");
#ob_start("ob_gzhandler");
$dbutils_dir="/var/www/html/inc/dbutils";
require_once("$dbutils_dir/dbutils.php");
db_connect("j/lib/config.php");$html='';
foreach($cylids as $cyl){
    $a=doquery("select c.id as Cylinder,case when cal_on_next_checkin=1 then 'X' else '' end as 'Needs int/final cal' ,next_checkin_notes as notes
            from cylinder_checkin_notes n join cylinder c on c.num=n.cylinder_num 
            where c.id=? and n.fill_code=reftank.f_getFillCode(?,now()) 
            and ((next_checkin_notes is not null and next_checkin_notes!='') 
                or (cal_on_next_checkin is not null and cal_on_next_checkin>0))",-1,array($cyl,$cyl));
    if($a){
        $html.=printTable($a)."<br>Open <a href='index.php?mod=addOrder' target='_blank'>New Order</a>";#"<tr><td>$cyl</td><td>$cal_on_next_checkin</td><td>next_checkin_notes</td></tr>";
    }
}
if($html){
    #$html="<table><tr><th>Cylinder</th><th>Needs int/final Cal</th><th>Notes</th></tr>".$html."</table>";
    echo getPopupAlert($html);
}
?>
 </BODY>
</HTML>
