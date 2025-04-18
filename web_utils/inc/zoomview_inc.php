<?PHP
#
# Function ZoomViewImageArea() ##################################################################
#
# This function creates a zooming interface bosed on a list of images passed in.
# The function first finds which file is the base zoom file (most general) file.
# It takes that filename and splits it based on $filenamedelim and figures out
# which index is the zoomfield. For each zoomed image, it looks at the zoomfield
# index in the filename and splits bazed on the $zoomfielddelim. Depending on
# the number of $zoomfielddelim's determines which level of zoom.
# For example
#
#    zoom 0: xxx_basezoom_xxx.png
#    zoom 1: xxx_2002_xxx.png
#    zoom 2: xxx_2002-01_xxx.png
#    zoom 3: xxx_2002-01-01_xxx.png
#
# Javascript is used to zoom in, zoom out, previous and next image. These
# functions should be overridden for each specific application if needed.
#
# Created by Dan Chao
# 2011-04-21
#
function ZoomViewImageArea($argsaarr, $imgarr)
{

   #
   # Parse the argument associative array
   #
   if ( isset($argsaarr['zoomfieldkeyword']) )
   { $zoomfieldkeyword = $argsaarr['zoomfieldkeyword']; }
   else
   { $zoomfieldkeyword = 'basezoom'; }

   if ( isset($argsaarr['filenamedelim']) )
   { $filenamedelim = $argsaarr['filenamedelim']; }
   else
   { $filenamedelim = '_'; }

   if ( isset($argsaarr['zoomfielddelim']) )
   { $zoomfielddelim = $argsaarr['zoomfielddelim']; }
   else
   { $zoomfielddelim = '-'; }
   $basenameimgarr = $imgarr;
   for ( $i=0; $i<count($basenameimgarr); $i++ )
   {
      $basenameimgarr[$i] = basename($basenameimgarr[$i]);
   }

   #
   # Find the base zoom file
   #
   $basezoomimgarr = array_values(preg_grep("/[^A-Za-z0-9]".$zoomfieldkeyword."[^A-Za-z0-9]/", $basenameimgarr));

   if ( count($basezoomimgarr) == 1 )
   {
      # If we find one base zoom file, then proceed
      list($name, $extension) = split('\.', $basezoomimgarr[0], 2);

      $fields = split($filenamedelim, $name);
      $tmparr = preg_grep("/$zoomfieldkeyword/", $fields);
      $zoomfieldnum = key($tmparr);

      if ( $zoomfieldnum === false )
      {
         print "Keyword '$zoomfieldkeyword' found but could not determine field number.";
      }
   }
   elseif ( count($basezoomimgarr) == 0 )
   {
      # If we find no base zoom file, then exit
      print "Keyword '$zoomfieldkeyword' not found.";
      exit;
   }
   elseif ( count($basezoomimgarr) > 1 )
   {
      # If we find more than one base zoom file, then exit
      print "Keyword '$zoomfieldkeyword' found more than once.";
      exit;
   }

   # Create the zoomed associative array

   # Example
   #Array
   #(
   #    [0] => Array
   #        (
   #            [0] => dist/alt/2011-04-15/P01_alt_colocated_basezoom_co2_page.png
   #        )
   #
   #    [1] => Array
   #        (
   #            [0] => dist/alt/2011-04-15/P01_alt_colocated_2002_co2_page.png
   #            [1] => dist/alt/2011-04-15/P01_alt_colocated_2003_co2_page.png
   #            [2] => dist/alt/2011-04-15/P01_alt_colocated_2004_co2_page.png
   #            [3] => dist/alt/2011-04-15/P01_alt_colocated_2005_co2_page.png
   #            [4] => dist/alt/2011-04-15/P01_alt_colocated_2006_co2_page.png
   #            [5] => dist/alt/2011-04-15/P01_alt_colocated_2007_co2_page.png
   #            [6] => dist/alt/2011-04-15/P01_alt_colocated_2008_co2_page.png
   #            [7] => dist/alt/2011-04-15/P01_alt_colocated_2009_co2_page.png
   #            [8] => dist/alt/2011-04-15/P01_alt_colocated_2010_co2_page.png
   #            [9] => dist/alt/2011-04-15/P01_alt_colocated_2011_co2_page.png
   #        )
   #
   #    [2] => Array
   #        (
   #            [0] => dist/alt/2011-04-15/P01_alt_colocated_2002-01_co2_page.png
   #            [1] => dist/alt/2011-04-15/P01_alt_colocated_2002-02_co2_page.png
   #            [2] => dist/alt/2011-04-15/P01_alt_colocated_2002-03_co2_page.png
   #            [3] => dist/alt/2011-04-15/P01_alt_colocated_2002-04_co2_page.png
   #            [4] => dist/alt/2011-04-15/P01_alt_colocated_2002-05_co2_page.png
   #            [5] => dist/alt/2011-04-15/P01_alt_colocated_2002-06_co2_page.png
   #            [6] => dist/alt/2011-04-15/P01_alt_colocated_2002-07_co2_page.png
   #            [7] => dist/alt/2011-04-15/P01_alt_colocated_2002-08_co2_page.png
   #            [8] => dist/alt/2011-04-15/P01_alt_colocated_2002-09_co2_page.png
   #            [9] => dist/alt/2011-04-15/P01_alt_colocated_2002-10_co2_page.png
   #            [10] => dist/alt/2011-04-15/P01_alt_colocated_2002-11_co2_page.png
   #            [11] => dist/alt/2011-04-15/P01_alt_colocated_2002-12_co2_page.png
   #            [12] => dist/alt/2011-04-15/P01_alt_colocated_2003-01_co2_page.png
   #            [13] => dist/alt/2011-04-15/P01_alt_colocated_2003-02_co2_page.png
   #            [14] => dist/alt/2011-04-15/P01_alt_colocated_2003-03_co2_page.png
   #            [15] => dist/alt/2011-04-15/P01_alt_colocated_2003-04_co2_page.png
   #            [16] => dist/alt/2011-04-15/P01_alt_colocated_2003-05_co2_page.png
   #            [17] => dist/alt/2011-04-15/P01_alt_colocated_2003-06_co2_page.png
   #            [18] => dist/alt/2011-04-15/P01_alt_colocated_2003-07_co2_page.png
   #            [19] => dist/alt/2011-04-15/P01_alt_colocated_2003-08_co2_page.png
   #            [20] => dist/alt/2011-04-15/P01_alt_colocated_2003-09_co2_page.png
   #            [21] => dist/alt/2011-04-15/P01_alt_colocated_2003-10_co2_page.png
   #            [22] => dist/alt/2011-04-15/P01_alt_colocated_2003-11_co2_page.png
   #            [23] => dist/alt/2011-04-15/P01_alt_colocated_2003-12_co2_page.png
   #        )
   #
   #)
   
   $zoomaarr = array ();
   foreach ( $imgarr as $img )
   {
      $basenameimg = basename($img);
      list($name, $extension) = split('\.', $basenameimg, 2);

      $fields = split($filenamedelim, $name);

      if ( preg_match("/$zoomfieldkeyword/", $fields[$zoomfieldnum] ) )
      {
         if ( !isset($zoomaarr[0]) || ! is_array($zoomaarr[0]) )
         {
            $zoomaarr[0] = array();
         }
         array_push($zoomaarr[0], $img);
      } 
      else
      {
         $dashcount = preg_match_all('/'.$zoomfielddelim.'/', $fields[$zoomfieldnum], $matches);
         # print "$fields[$zoomfieldnum] $dashcount<br>";

         if ( ! isset($zoomaarr[$dashcount+1]) ||
              ! is_array($zoomaarr[$dashcount+1]) )
         {
            $zoomaarr[$dashcount+1] = array();
         }
         array_push($zoomaarr[$dashcount+1], $img);
      }
   }
   #12345
   # I need to use a custom sort to sort by the zoomfieldnum

   # Sort the main array on the keys
   ksort($zoomaarr);

   # Sort the associative array
   for ( $i=0; $i<count($zoomaarr); $i++ )
   { sort($zoomaarr[$i]); }

   #echo "<PRE>\n";
   #print_r($zoomaarr);
   #echo "</PRE>\n";
   $namearr = array();

   # Pass the information to JavaScript
   SendtoJS('imagelevels', $zoomaarr, $namearr);

   #print "Basezoom " . $zoomfieldnum;

   ?>
     <TABLE border='1'>
      <TR>
       <TD>
        <!-- Table for interface buttons -->
        <TABLE cellspacing='5' cellpadding='5'>
         <TR>
          <TD>
           <INPUT type='button' id='zoomview_zoomout_btn' value='-' title='Zoom out' onClick='zoomview_ZoomOut();' DISABLED>
          </TD>
          <TD>
           <INPUT type='button' id='zoomview_zoomin_btn' value='+' title='Zoom in' onClick='zoomview_ZoomIn();' color='#00FF00'>
          </TD>
          <TD>
           <INPUT type='button' id='zoomview_prev_btn' value='<<' title='Previous image at zoom level' onClick='zoomview_PrevImg();' DISABLED>
          </TD>
          <TD>
           <INPUT type='button' id='zoomview_next_btn' value='>>' title='Next image at zoom level' onClick='zoomview_NextImg();' DISABLED>
          </TD>
         </TR>
        </TABLE>
        <!-- End table for interface buttons -->
       </TD>
      </TR>
      <TR>
       <TD>
   <?PHP
   # Image name
   echo "<DIV style='text-align:center' id='zoomview_imgsrc' size='75'>" . basename($zoomaarr[0][0]) . "</DIV>";
   ?>
        <P>
   <?PHP
   # Image
   echo "<IMG id='zoomview_outimage' src='" . $zoomaarr[0][0] . "'>";
   ?>
       </TD>
      </TR>
     </TABLE>

   <?PHP

   # Pass which zoom field number in the file name
   JavaScriptCommand("zoomfieldnum = ".$zoomfieldnum);
   # Pass the file name delimiter
   JavaScriptCommand("filenamedelim = '".$filenamedelim."'");
   # Pass the zoom field delimiter
   JavaScriptCommand("zoomfielddelim = '".$zoomfielddelim."'");
}
?>
