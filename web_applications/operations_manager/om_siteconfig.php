<?PHP

include ("/var/www/html/om/om_inc.php");
include ("/var/www/html/om/ccgglib_inc.php");
include ("/var/www/html/om/omlib_inc.php");

#
# Make sure that the database is up and running
#
if (!($fpdb = ccgg_connect()))
{
   JavaScriptAlert("Cannot connect to server at this time. Please try again later.");
   exit;
}

$strat_name = isset( $_GET['strat_name'] ) ? $_GET['strat_name'] : 'om';
$strat_abbr = isset( $_GET['strat_abbr'] ) ? $_GET['strat_abbr'] : 'om';

$task = isset( $_POST['task'] ) ? $_POST['task'] : '';
$sitecode = isset( $_POST['sitecode'] ) ? $_POST['sitecode'] : '';
$date = isset( $_POST['date'] ) ? $_POST['date'] : '';
$images = isset( $_POST['images'] ) ? $_POST['images'] : '';
$editmode = isset( $_POST['editmode'] ) ? $_POST['editmode'] : '';

BuildBanner($strat_name,$strat_abbr,GetUser());
BuildNavigator();
echo "<SCRIPT language='JavaScript' src='om_siteconfig.js'></SCRIPT>";

$configinfo = '';

#
# If the user update the current configuration
#
if ( $task == "update" )
{
   if ( $strat_abbr == 'flask' )
   {
      $dir = '/projects/network/site_info/'.strtoupper($sitecode).'/images/log';
   }
   else
   {
      $dir = '/projects/aircraft/'.strtolower($sitecode).'/images/log';
   }
   

   $configfile = $dir.'/curconfig.txt';

   #
   # If the current configuration file exists, then read it
   #
   if ( file_exists($configfile) && filesize($configfile) > 0)
   {
      $fp = fopen($configfile, "r") or die ("Could not open configfile!");
      $configinfo = split("\n",fread($fp, filesize($configfile)));
      fclose($fp);

      #
      # Remove all the elements that are just a space
      #
      $configinfo = array_values(preg_grep("/^[^\s]/", $configinfo));
   }

   #
   # Passing between JavaScript and PHP
   #
   $editarr = split("\|",$images);

   if ( !is_array($configinfo) )
   {
      $configinfo = $editarr;
   }
   else
   {
      #
      # Match all of the images that are not from the currently selected date.
      #
      $datechk = preg_quote($date, "/");
      $configinfo = array_values(preg_grep("/^($datechk)/", $configinfo, PREG_GREP_INVERT));
      #
      # Then add in all the selected images for the currently selected date.
      #
      $configinfo = array_merge($configinfo, $editarr);
   }

   #
   # Sort by <image name> not by <date>/<image name>
   #
   usort($configinfo, "cmp");

   foreach($configinfo as $key => $value)
   {
      if( empty( $value ) )
      {
         unset($configinfo[$key]);
      }
   }
   $configinfo = array_values($configinfo); 

   #
   # Write the list of images to the current configuration file
   #
   $fp = fopen("$configfile","w") or die ("Could not open configfile");
   $imagetext = implode("\n",$configinfo);
   fputs($fp,"${imagetext}");
   fclose($fp);

   $date = '';
   $images = '';
}

#
# Only get the site list if no site is selected
#
if ( $sitecode == '' )
{
   $siteinfo = DB_GetSiteList('', $strat_abbr);
}

MainWorkArea();
exit;
#
# Function MainWorkArea ########################################################
#
function MainWorkArea()
{
   global $strat_name;
   global $strat_abbr;
   global $path;
   global $date;
   global $images;
   global $sitecode;
   global $siteinfo;
   global $configinfo;
   global $editmode;

   echo "<FORM name='mainform' method=POST>";

   echo "<INPUT TYPE='HIDDEN' NAME='task'>";
   echo "<INPUT TYPE='HIDDEN' NAME='sitecode' VALUE='${sitecode}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='date' VALUE='${date}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='images' VALUE='${images}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='editmode' VALUE='${editmode}'>";
   echo "<INPUT TYPE='HIDDEN' NAME='changed' VALUE='0'>";

   #
   #############################
   # Outermost Table
   #############################
   #
   echo "<TABLE width='100%' border='0' cellspacing='0' cellpadding='5' class='MediumBlackN'>";
   echo "<TR>";

   if ( $sitecode == '' )
   {
      echo "<TD align='center' class='XLargeBlackB'>Site Images";
      echo "</TD></TR>";
      echo "<TR><TD align='center'>";
      #
      # If the user is not editing the current configuration of a site,
      #    the allow the user to select a site
      #
      echo "<FONT class='MediumBlackN'>Select Site:</FONT><BR>";
      echo "<SELECT class='MediumBlackN' NAME='sitelist' SIZE='1' onChange='ListSelectCB(this)'>";

      echo "<OPTION class='MediumBlackN' VALUE=''>---</OPTION>";
      for ($i=0; $i<count($siteinfo); $i++)
      {
         # $siteinfo
         # num|code|name|country
         $tmp=split("\|",$siteinfo[$i]);
         $selected = (!(strcasecmp($tmp[1],$sitecode))) ? 'SELECTED' : '';
         $z = sprintf("%s - %s, %s",$tmp[1],$tmp[2],$tmp[3]);
         $tmp[1] = strtolower($tmp[1]);
         echo "<OPTION class='MediumBlackN' $selected VALUE='$tmp[1]'>${z}</OPTION>";
      }
                                                                                          
      echo "</SELECT>";
   }
   else
   {
      #
      # If a user is editing the current configuration, then a site must
      #    already be selected
      #
      echo "<TD align='center' class='XLargeBlackB'>";
      echo "<FONT class='XLargeBlueB'>".strtoupper($sitecode)."</FONT>";
      echo " Images";
   }

   echo "</TD></TR>";

   if ( $sitecode != '' )
   {
      #
      # If a site has been chosen, then read the current configuration
      #    file for the site
      #
      if ( $strat_abbr == 'flask' )
      {
         $dir = '/projects/network/site_info/'.strtoupper($sitecode).'/images/log';
      }
      else
      {
         $dir = '/projects/aircraft/'.strtolower($sitecode).'/images/log';
      }

      if ( $configinfo == '' )
      {
         #
         # If the current configuration information is empty, then read it
         #    from the file
         #
         $configfile = $dir.'/curconfig.txt';

         if ( file_exists($configfile) && filesize($configfile) > 0)
         {
            $fp = fopen($configfile, "r") or die ("Could not open configfile!");
            $configinfo = split("\n",fread($fp, filesize($configfile)));
            fclose($fp);
         }
      }

      if ( $editmode )
      {
         #
         # If the user wants to edit the current configuration,
         #    then go into edit mode
         #

         #
         # Open and read the $site/images/log directory
         #
         $dir_open = @ opendir($dir);
         if (! $dir_open)
         {
            JavaScriptAlert("Could not open directory: $dir");
            return false;
         }
         while (($dir_content = readdir($dir_open)) !== false)
            $dirlist[] = $dir_content;

         #
         # Get all the directories starting with numbers, since they should be
         #    date directories
         #
         $datelist = array_values(preg_grep("/^[0-9]+/", $dirlist));

         #
         # If a date was not previously chosen, set it to the first element in
         #    the date directory array
         #
         if ( empty($date) || !in_array($date, $datelist))
         {
            $date = ( !empty($datelist[0]) ) ? $datelist[0] : '';
            JavaScriptCommand("document.mainform.date.value = '$date'");
         }

         #
         # Open and read the $site/images/log/$date directory
         #
         $dir_open = @ opendir($dir."/".$date);
         if (! $dir_open)
         {
            JavaScriptAlert("Could not open directory: $dir"."/"."$date");
            return false;
         }
         while (($dir_content = readdir($dir_open)) !== false)
            $dirlist[] = $dir_content;

         #
         # Find all of the jpegs and gifs
         #
         $imageinfo = array_values(preg_grep("/.+(jpg|gif)/i", $dirlist));

         #
         # Add the date directory before the image name so that the image
         #    can be found from $site/images/log directory
         #
         for ( $i=0; $i<count($imageinfo); $i++ ) { $imageinfo[$i] = $date."/".$imageinfo[$i]; }

         #
         # Sort the array by the names of the files, not
         #    $date/$filename
         #
         usort($imageinfo, "cmp");

         echo "<TR><TD><HR></TD></TR>";
         echo "<TR><TD align='center' class='LargeBlackB'>Edit Current Configuration</TD></TR>";
         echo "<TR><TD align='center'>";
         echo "<FONT class='MediumBlackN'>Select Date:</FONT> ";
         echo "<SELECT class='MediumBlackN' NAME='datelist' SIZE='1' onChange='ListSelectCB(this)'>";
         for ( $j=0; $j<count($datelist); $j++ )
         {
            $selected = (!(strcasecmp($datelist[$j],$date))) ? 'SELECTED' : '';
            $z = sprintf("%s",$datelist[$j]);
            echo "<OPTION class='MediumBlackN' $selected VALUE='${z}'>${z}</OPTION>";
         }
         echo "</SELECT>";
         echo "</TD></TR>";
      }
      else
      {
         #
         # Show the current configuration
         #
         $imageinfo = $configinfo;
         echo "<TR><TD><HR></TD></TR>";
         echo "<TR><TD align='center' class='LargeBlackB'>Current Configuration</TD></TR>";
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
         # If the user is editing the current configuration, let them tell us when
         #    they are ready to update or are done
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
         # If the user is viewing the current configuration, allow them
         #    to go into edit mode or go back to select a site
         #
         echo "<INPUT TYPE='button' name='edit' class='Btn' value='Edit' onClick='EditCB()'>";
         echo "</TD>";
         echo "<TD align='center'>";
         echo "<INPUT TYPE='button' name='back' class='Btn' value='Back' onClick='BackCB()'>";
         echo "</TD>";
      }
      echo "</TR>";
      echo "</TABLE>";
      echo "</TD></TR>";

      echo "<TR><TD align='center' class='SmallBlackN'>";
      echo "[Click on image to view/edit captions]</TD></TR>";

      #
      # Table for the images
      #
      echo "<TR><TD align='center'>";
      echo "<TABLE width='80%' border='1' cellspacing='0' cellpadding='5' class='MediumBlackN'>";

      for ( $i=0, $j=0; $i<count($imageinfo); $i++ )
      {
         if ( empty ( $imageinfo[$i] ) ) { continue; }
         if ( ! file_exists($dir."/".$imageinfo[$i])) { continue; }

         # $tmp
         # $date/<image name>
         $tmp = split("\/",$imageinfo[$i]);
         $date = $tmp[0];
         $image = $tmp[1];

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
         $resize = ImageResize("$dir/$imageinfo[$i]",'240','180','');
         echo "<a href='javascript:void(0);'><img src='$dir/".$imageinfo[$i]."' width='$resize[0]' height='$resize[1]'  onClick='ShowImageCB(\"$dir/$imageinfo[$i]\")'></a>";

         echo "<BR>";

         #
         # If we are in edit mode, show the checkboxes beneath the images
         #
         if ( $editmode )
         {
            #
            # If the image was already in the current configuration,
            #    make the checkbox CHECKED
            #
            $checked = '';
            if (!empty($configinfo))
            {
               if ( in_array($imageinfo[$i], $configinfo) )
               { $checked = 'CHECKED'; }
            }
            echo "<INPUT TYPE='checkbox' name='imagelist' value='$imageinfo[$i]' onClick='ListSelectCB(this)' $checked>";
            echo "$tmp[1]";
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

      echo "</TABLE>";
      echo "</TD><TR>";
   }
   echo "</TABLE>";
}

function cmp($a, $b)
{
   #
   # Function that compares <file name> instead of the <date>/<file name>
   #
   $atmp = split("\/",strtolower($a));
   $btmp = split("\/",strtolower($b));
   if ($atmp[1] == $btmp[1]) {
       return 0;
   }
   return ($atmp[1] < $btmp[1]) ? -1 : 1;
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
