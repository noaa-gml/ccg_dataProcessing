<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

#
# Make sure that the database is up and running
#
if (!($fpdb = ccgg_connect()))
{
        JavaScriptAlert("Cannot connect to server at this time. Please try again later.");        exit;
}

$path = isset( $_GET['path'] ) ? $_GET['path'] : '';
$keyword = isset( $_GET['keyword'] ) ? $_GET['keyword'] : '';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$images = isset( $_POST['images'] ) ? $_POST['images'] : '';
$editmode = isset( $_POST['editmode'] ) ? $_POST['editmode'] : '';

$strat_name = 'PFP';
$strat_abbr = 'pfp';
                                                                                          
BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='ac_keyconfig.js'></SCRIPT>";

$listinfo = '';
$listfile = "$path/listing.txt";

#
# If the user wants to update the current configuration
#
if ( $task == "update" )
{
   #
   # If the current configuration file exists, then read it
   #
   if ( file_exists($listfile) && filesize($listfile) > 0 )
   {
      $fp = fopen($listfile, "r") or die ("Could not open listfile!");
      $listinfo = split("\n",fread($fp, filesize($listfile)));
      fclose($fp);

      #
      # Remove all the elements that are just a space
      #
      $listinfo = array_values(preg_grep("/[^\s]/", $listinfo));
   }

   #
   # Passing between JavaScript and PHP
   #
   $editarr = split("\|",$images);

   #
   # Add the selected keyword in front of each image name
   #
   for ( $i=0; $i<count($editarr); $i++ )
   {
      $editarr[$i] = $keyword.":".$editarr[$i];
   }

   if ( !is_array($listinfo) )
   {
      $listinfo = $editarr;
   }
   else
   {
      #
      # Match all of the images in the current configuration that do NOT start
      #    with the currently selected keyword
      #
      $keytest = preg_quote($keyword, "/");
      $listinfo = array_values(preg_grep("/^($keytest)/", $listinfo, PREG_GREP_INVERT));

      #
      # Add the images that begin with the currently selected keyword
      #
      $listinfo = array_merge($listinfo, $editarr);
   }

   #
   # Write the list of images to the current configuration file
   #
   $fp = fopen("$listfile","w") or die ("Could not open listfile");
   $imagetext = implode("\n",$listinfo);
   fputs($fp,"${imagetext}");
   fclose($fp);

   $task = '';
   $images = '';
   $editmode = '';
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $task;
   global $path;
   global $keyword;
   global $editmode;
   global $listfile;
   global $listinfo;

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='images'>";
   echo "<INPUT TYPE='HIDDEN' NAME='editmode' VALUE='${editmode}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='changed' VALUE='0'>";

   #
   #############################
   # Outermost Table
   #############################
   #
   echo "<TABLE width='100%' border='0' cellspacing='0' cellpadding='5' class='MediumBlackN'>";
   echo "<TR>";

   #
   # Display different titles based on if the user is in edit mode or not
   #
   if ( $editmode )
   {
      $title = "<FONT class='XLargeBlueB'>$path</FONT><BR>";
      $title = "$title <FONT class='XLargeBlueB'>$keyword</FONT> Images";
   }
   else
   { $title = "<FONT class='XLargeBlueB'>$path</FONT> Images"; }

   echo "<TD align='center' class='XLargeBlackB'>$title";
   echo "</TD></TR>";

   if ( !isset($listinfo[0]) || empty($listinfo[0]) )
   {
      #
      # Read the list file if $listinfo is not set
      #
      if ( file_exists($listfile) && filesize($listfile) > 0 )
      {
         $fp = fopen($listfile, "r") or die ("Could not open listfile!");
         $listinfo = split("\n",fread($fp, filesize($listfile)));
         fclose($fp);
      }
   }

   if ( $editmode || $keyword == '' )
   {
      #
      # If the user is in edit mode or no keyword is specified, then get
      #    a list of all the jpgs and gifs from the $path
      #
      $dir_open = @ opendir($path);

      if (! $dir_open)
      {
         JavaScriptAlert("Could not open directory: $path");
         return false;
      }

      while (($dir_content = readdir($dir_open)) !== false)
         $dirlist[] = $dir_content;

      #
      # Find all of the jpegs and gifs
      #
      $imageinfo = array_values(preg_grep("/.+(jpg|gif)/i", $dirlist));

      #
      # Sort by <file name> not <keyword>:<file name>
      #
      usort($imageinfo, "cmp");

      #
      # Different titiles based on whether or not keyword is specified
      #
      if ( $keyword == '' )
      { $edittitle = "All Images"; }
      else
      { $edittitle = "Edit Image List"; }

      echo "<TR><TD><HR></TD></TR>";
      echo "<TR><TD align='center' class='LargeBlackB'>$edittitle</TD></TR>";

   }
   else
   {
      #
      # If the user is not editing the images associated with a keyword,
      #    then show the images associated with the keyword
      #
      for ( $i=0, $j=0; $i<count($listinfo); $i++ )
      {
         if ( isset($listinfo[$i]) )
         {
            $tmp = split(":",$listinfo[$i]);
            if ( $tmp[0] == $keyword )
            {
               $imageinfo[$j] = $tmp[1];
               $j++;
            }
         }
      }

      $title = "<FONT class='LargeBlueB'>$keyword</FONT> Images";

      echo "<TR><TD><HR></TD></TR>";
      echo "<TR><TD align='center' class='LargeBlackB'>$title</TD></TR>";
   }


   echo "<TR><TD colspan=3>";

   #
   ##################
   # Buttons Table
   ##################
   #
   echo "<TABLE align='center' width=20% border='0' cellpadding='2' cellspacing='2'>";
   echo "<TR>";
   echo "<TD align='center'>";
   if ( $editmode )
   {
      #
      # If we are in edit mode, allow the user to tell us when they are ready
      #    to update or are done
      #
      echo "<INPUT TYPE='button' name='update' class='Btn' value='Update' onClick='UpdateCB()'>";
      echo "</TD>";
      echo "<TD align='center'>";
      echo "<INPUT TYPE='button' name='done' class='Btn' value='Done' onClick='DoneCB()'>";
      echo "</TD>";
   }
   else
   {
      #
      # Allow the user to edit the images associated with a keyword only if
      #    a keyword is specified
      #
      if ( $keyword != '' )
      {
         echo "<INPUT TYPE='button' name='edit' class='Btn' value='Edit' onClick='EditCB()'>";
      }
   }
   echo "</TR>";
   echo "</TABLE>";
   echo "</TD></TR>";

   echo "<TR><TD align='center' class='SmallBlackN'>";
   echo "[Click on image to view/edit caption]";
   echo "</TD></TR>";

   #
   # Image Table
   #
   echo "<TR><TD align='center'>";
   echo "<TABLE width='80%' border='1' cellspacing='0' cellpadding='5' class='MediumBlackN'>";

   if ( isset($imageinfo[0]) )
   {
      for ( $i=0, $j=0; $i<count($imageinfo); $i++ )
      {
         if ( $imageinfo[$i] == '' ) continue;

         #
         # Put 3 images / row
         #
         if ( ( $j % 3 ) == 0 ) { echo "<TR><TD>"; }
         else { echo "<TD>"; }

         #
         # Put the image up
         #
         echo "<DIV align='center'>";

         #
         # Get the width and height of the image so that it fits within a
         # 240X180 thumbnail box
         #

         $resize = ImageResize("$path/$imageinfo[$i]",'240','180','');
         echo "<a href='javascript:void(0);' onMouseOver=\"window.status='Show $imageinfo[$i]'; return true;\"><img src='$path/$imageinfo[$i]' width='$resize[0]' height='$resize[1]' onClick='ShowImageCB(\"$path/$imageinfo[$i]\")'></a>";

         echo "<BR>";

         if ( $editmode )
         {
            #
            # If the user is in edit mode, then show checkboxes beneath the
            #    images. If the image was already associated with the
            #    keyword, then make the checkbox CHECKED
            #
            $checked = '';
            if ( is_array($listinfo) )
            {
               if ( in_array($keyword.":".$imageinfo[$i], $listinfo) )
               { $checked = 'CHECKED'; }
            }
            echo "<INPUT TYPE='checkbox' name='imagelist' value='$imageinfo[$i]' onClick='ListSelectCB(this)' $checked>";
            echo "$imageinfo[$i]";
         }
         else
         {
            echo "$imageinfo[$i]";
         }

         echo "</DIV>";

         #
         # 3 images / row
         #
         if ( ( $j % 3 ) == 2 ) { echo "</TD></TR>"; }
         else { echo "</TD>"; }

         $j++;
      }

      if ( ( $j % 3 ) != 2 ) { echo "</TR>"; }

   }
   else
   {
      echo "<TR><TD align='center' colspan='3'>";
      echo "<FONT class='LargeRedB'>No Images</FONT>";
      echo "</TD></TR>";
   }

   echo "</TABLE>";
   echo "</TD><TR>";

   echo "</TABLE>";
}

function cmp($a, $b)
{
   #
   # Function that compares the lower case file names
   #
   $atmp = strtolower($a);
   $btmp = strtolower($b);
   if ($atmp == $btmp) {
       return 0;
   }
   return ($atmp < $btmp) ? -1 : 1;
}

#
# Function ImageResize ###############################################################
#
function ImageResize($infile,$owidth,$oheight,$ratio)
{
   list($width, $height, $type) = GetImagesize($infile);
                                                                                          
   if ( empty($ratio) )
   {
      if ( empty($owidth) ) { $owidth = 640; }
      $ratiow = $owidth / $width;
                                                                                          
      if ( empty($oheight) ) { $oheight = 480; }
      $ratioh = $oheight / $height;
                                                                                          
      if ( $ratiow > $ratioh ) { $ratio = $ratioh; }
      else { $ratio = $ratiow; }
                                                                                          
      if ( $ratio > 1 ) { $ratio = 1; }
   }
                                                                                          
   $newwidth = $width * $ratio;
   $newheight = $height * $ratio;
                                                                                          
   $dimensions = array( $newwidth, $newheight );
                                                                                          
   return $dimensions;
}


?>
