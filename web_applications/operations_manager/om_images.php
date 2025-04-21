<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

$image = isset( $_GET['image'] ) ? $_GET['image'] : '';
$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$comments = isset( $_POST['comments'] ) ? $_POST['comments'] : '';

if ( empty($image) ) { echo "Image not set"; return false; }

#echo "$image";

#
# Do what the user requests
#
if ( $task == 'save' )
{
   $prefix = substr("$image", 0, -4);
   $textfile = $prefix.".txt";

   #
   # If there are no comments, then delete the file
   #
   if ( empty($comments) )
   {
      if ( file_exists($textfile) )
      {
         unlink($textfile);
      }
   }
   else
   {
      #
      # Save the text into a text file
      #    The name is the same as the image except for with a .txt extension
      #
      $fp = fopen("${textfile}","w") or die ("Could not open textfile");
      $comments = stripslashes($comments);
      fputs($fp,"${comments}");
      #echo "$comments\n";
      fclose($fp);
   }
   #JavaScriptAlert("Text saved");
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $image;

   echo "<HTML>";
   echo "<HEAD>";
   echo "<SCRIPT language='JavaScript' src='om_images.js'></SCRIPT>";
   echo "<LINK REL=STYLESHEET TYPE=\"text/css\" HREF=\"/om/om_style.css\">";
   echo "</HEAD>";

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='image' VALUE='${image}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='changed' VALUE='0'>";

   echo "<BODY>";
   echo "<TABLE align='center' width=80% border='0' cellpadding='2' cellspacing='2'>";
   echo "<TR><TD align='center' class='LargeBlueB'>$image</TD></TR>";

   #
   # If a specific image file is specified, then post it with text. Allow
   #    the user to edit the text
   #
   PostPicture($image);

   #
   # Put focus on the comments textarea
   #
   JavaScriptCommand("document.mainform.comments.focus()");

   echo "</TABLE>";
   echo "</BODY>";
   echo "</HTML>";
}
#
# Function PostPicture ###############################################################
#
function PostPicture($image)
{
   #
   # Make the textfile name 
   #
   $prefix = substr("$image", 0, -4);
   $textfile = $prefix.".txt";
   #echo "$prefix<BR>";

   echo "<TR><TD><HR></TD></TR>";
   #echo "<TR><TD align='center' bgcolor='#FFCC99'><H3>$prefix</H3></TD></TR>";
   echo "<TR><TD valign='top' align='center'>";
   #echo "$filelist[$i]<BR>";

   $resize = ImageResize("$image",'','','');
   echo "<img src='$image' width='$resize[0]' height='$resize[1]'>";

   echo "</TD></TR>";
   echo "<TR><TD valign='top' align='center'>";

   echo "<TEXTAREA class='MediumBlackN' name='comments' cols=80 rows=3 onFocus='SetBackground(this,true)' onBlur='SetBackground(this,false)' onChange='document.mainform.changed.value = \"1\"' style='background-color:white; color: black' WRAP=SOFT>";

   #JavaScriptAlert("$prefix.txt exists");

   #
   # If the text file exists for the image, then read it and put the
   #    contents in the textarea
   #
   if ( file_exists($textfile) && filesize($textfile) > 0 )
   {
      $fp = fopen($textfile, "r") or die ("Could not open textfile!");
      $textcontents = fread($fp, filesize($textfile));
      fclose($fp);

      echo htmlspecialchars($textcontents);
   }

   echo "</TEXTAREA>";
   echo "</TD></TR>";

   #
   # Show the interface buttons
   #
   echo "<TR><TD align='center'>";
   echo "<TABLE align='center' width=30% border='0' cellpadding='2' cellspacing='2'>";
   echo "<TR>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='addupdate' class='Btn' value='Save' onClick='SaveCB()'>";
   echo "</TD>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' name='clear' class='Btn' value='Clear' onClick='ClearCB()'>";
   echo "</TD>";
   echo "<TD align='center'>";
   echo "<INPUT TYPE='button' class='Btn' value='Close' onClick='CloseCB();'>";
   echo "</TD>";
   echo "</TR>";
   echo "</TABLE>";
   echo "</TD></TR>";
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
