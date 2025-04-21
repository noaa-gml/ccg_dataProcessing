<?PHP

#
# Function ImageArea ####################################################################
#
function ImageArea($imagelist)
{

$hreflist = array();

#
# Find the list of images and sort it
#
$imglist = array_values(preg_grep("/\.(png|gif|jpg)$/i", $imagelist));

#
# Find the list of pdf, ps files, and txt files (notimg). 
#
$notimgarr = array_values(preg_grep("/\.(pdf|ps|txt)$/i", $imagelist));

#
# Loop through the images
#
for ( $i=0; $i<count($imglist); $i++ )
{
   $tmp = pathinfo($imglist[$i]);

   #
   # Create a regular expression based on the image name
   #
   $imgname = preg_replace("/".$tmp['extension']."$/i", "", $imglist[$i]);
   $imgname = preg_quote($imgname);
   $imgname = preg_replace("/\//", "\/", $imgname);

   #print "$imgname<BR>";

   #
   # Find files in $notimgarr that match the image name with an extension
   #    that is 2-4 characters in length that are alphanumeric
   #
   $tmparr = array_values(preg_grep("/^{$imgname}[A-Za-z0-9]{2,4}$/i", $notimgarr));
   #print_r($tmparr);

   #
   # For the files in $notimgarr that match the current image file, change those
   #    files names to A HREF links so they can be set directly in JavaScript with
   #    needing to parse in JavaScript
   #
   for ( $j=0; $j<count($tmparr); $j++ )
   {
      $tmp2 = pathinfo($tmparr[$j]);

      $tmparr[$j] = "<A HREF='$tmparr[$j]'>".strtoupper($tmp2['extension'])."</A>";
   }

   $hreflist[$i] = join(" ", $tmparr);
}

#
# Send the hreflist to client side
#
for ($i=0; $i<count($hreflist); $i++)
{
   JavaScriptCommand("hreflist[$i] = \"".$hreflist[$i]."\"");
}

?>
<TABLE border='1' cellspacing='0' cellpadding='5' class='MediumBlackN' bgcolor='white'>
<TR>
<?PHP #<TD style='position: absolute; text-align: center; LEFT: 45%'> ?>
<TD>
<?PHP # Interface table ?>
<TABLE border='0' cellspacing='0' cellpadding='5' class='MediumBlackN'>
<TR>
<TD align='left'>
<?PHP # Image Navigation Buttons table ?>
<TABLE border='0' cellspacing='0' cellpadding='5' class='MediumBlackN'>
<TR>
<TD width='20'>
<INPUT type='button' id='PrevImg' value='<<' class='Btn' onClick='ImagePrev()'>
</TD>
<TD width='20'>
<INPUT type='button' id='NextImg' value='>>' class='Btn' onClick='ImageNext()'>
</TD>
<TD>
<SELECT NAME='imagelist' id='imagelist' onClick='ImageList()' class='MediumBlackN' SIZE='1'>
<?PHP
for ($i=0; $i<count($imglist); $i++ )
{
   $val = $imglist[$i];
   $z = basename($imglist[$i]);
   echo "<OPTION VALUE='${val}'>${z}</OPTION>";
}
?>
</SELECT>
</TD>
</TR>
<?PHP # End of Image Navigation Buttons table ?>
</TABLE>
</TD>
<TD align='right'>
<FONT class='MediumBlackN' id='hreflist'></FONT>
</TD>
</TR>
<?PHP # End of Interface table ?>
</TABLE>
</TD>
</TR>
<TR>
<TD align='center'>
<IMG alt='Image' name='plotimg' border='0'>
</TD>
</TR>
<?PHP # End of image table ?>
</TABLE>
<?PHP
}
?>
