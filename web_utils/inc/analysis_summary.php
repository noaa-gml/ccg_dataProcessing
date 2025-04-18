<?PHP

#################################################################
function TseriesFluxSummary($file)
{
   if ( ! ChkSumFile($file) ) { return; }

   $sum = file($file);
   #
   # Remove comment lines
   #
   $sum = array_values(preg_grep("/^#/", $sum, PREG_GREP_INVERT));


   echo "<TABLE border=1 cellspacing=2>";
   echo "<CAPTION>Results Summary (all units PgC/yr)</CAPTION>";
   echo "<TH bgcolor='LightGrey'>Year";
   echo "<TH bgcolor='LightGrey'>First Guess";
   echo "<TH bgcolor='LightGrey'>Estimate";
   echo "<TH bgcolor='LightGrey'>Fire Emission";
   echo "<TH bgcolor='LightGrey'>Fossil Emission";
   echo "<TH bgcolor='LightGrey'>Total Flux";
   #
   # Loop through summary
   #
   for ($i = 0; $i < count($sum); $i ++)
   {
  
      $field = explode(";", $sum[$i]);
      for ( $j=0; $j<count($field); $j++ )
      { $field[$j] = htmlentities($field[$j], ENT_QUOTES, 'UTF-8'); }

      echo "<TR>";

      echo "<TD align=CENTER>";
      echo $field[0];
      echo "</TD>";

      echo "<TD align=CENTER>";
      echo "${field[1]} &plusmn; ${field[2]}";
      echo "</TD>";

      echo "<TD align=CENTER>";
      echo "${field[3]} &plusmn; ${field[4]}";
      echo "</TD>";

      echo "<TD align=CENTER>";
      echo $field[5];
      echo "</TD>";

      echo "<TD align=CENTER>";
      echo $field[6];
      echo "</TD>";

      echo "<TD align=CENTER>";
      echo "${field[7]} &plusmn; ${field[4]}";
      echo "</TD>";

      echo "</TR>";
   }
   echo "</TABLE>";
}

#################################################################
function TseriesEddyFluxSummary($file)
{
   if ( ! ChkSumFile($file) ) { return; }

   $sum = file($file);
   #
   # Remove comment lines
   #
   $sum = array_values(preg_grep("/^#/", $sum, PREG_GREP_INVERT));

   echo "<TABLE border=1 cellspacing=2>";
   echo "<CAPTION>Site Summary</CAPTION>";

   $field = explode(";", $sum[0]);
   for ( $j=0; $j<count($field); $j++ )
   { $field[$j] = htmlentities($field[$j], ENT_QUOTES, 'UTF-8'); }

   echo "</TR>";
   echo "<TR align=LEFT>";
   echo "<TH bgcolor='LightGrey'>Code";
   echo "<TD>$field[0]";
   echo "</TR>";

   echo "</TR>";
   echo "<TR align=LEFT>";
   echo "<TH bgcolor='LightGrey'>Latitude";
   echo "<TD>$field[2]";
   echo "</TR>";

   echo "</TR>";
   echo "<TR align=LEFT>";
   echo "<TH bgcolor='LightGrey'>Longitude";
   echo "<TD>$field[1]";
   echo "</TR>";

   echo "</TR>";
   echo "<TR align=LEFT>";
   echo "<TH bgcolor='LightGrey'>Veg Type (model)";
   echo "<TD>$field[3]";
   echo "</TR>";

   echo "</TABLE>";
   echo "<FONT class='SmallBlackN'>CO<SUB>2</SUB> flux measurements courtesy of AmeriFlux investigators</FONT>";
}

#################################################################
function MapFluxSummary($file)
{
   if ( ! ChkSumFile($file) ) { return; }

   $sum = file($file);
   #
   # Remove comment lines
   #
   $sum = array_values(preg_grep("/^#/", $sum, PREG_GREP_INVERT));


   echo "<TABLE border=1 cellspacing=2>";
   echo "<CAPTION>Results Summary (all units PgC/yr)</CAPTION>";
   echo "<TH bgcolor='LightGrey'>Region Name";
   echo "<TH bgcolor='LightGrey'>Estimated Mean";
   echo "<TH bgcolor='LightGrey'>Fossil Emissions";
   echo "<TH bgcolor='LightGrey'>Fire Emissions";
   echo "<TH bgcolor='LightGrey'>Total Flux";

   for ($i = 0; $i < count($sum); $i ++)
   {

         $field = explode(";", $sum[$i]);
         for ( $j=0; $j<count($field); $j++ )
         { $field[$j] = htmlentities($field[$j], ENT_QUOTES, 'UTF-8'); }

         echo "<TR>";

         echo "<TD align=CENTER>";
         echo $field[0];
         echo "</TD>";

         echo "<TD align=CENTER>";
         echo "${field[1]} &plusmn; ${field[2]}";
         echo "</TD>";

         echo "<TD align=CENTER>";
         echo $field[3];
         echo "</TD>";

         echo "<TD align=CENTER>";
         echo $field[4];
         echo "</TD>";

         echo "<TD align=CENTER>";
         echo "${field[5]} &plusmn; ${field[2]}";
         echo "</TD>";

         echo "</TR>";
   }
   echo "</TABLE>";
}

function ChkSumFile($file)
{
   if ( ! preg_match("/^\.\.\/\.\.\/webdata\/[A-Za-z0-9_\/]+\.txt$/", $file ) )
   { return FALSE; }

   return TRUE;
}
?>
