<?PHP

function LoadConstantVariables($varfile="variables.txt")
{
   #
   # This function reads a file called variables.txt, which should be created
   #  by initialize.pl. The variables.txt file will contain name~value pairs
   #  that need to be constant variables. The scope of a constant is global.
   #

   $filecontents = file($varfile) or die ("Could not read $varfile.");

   # Strip out the comment lines
   $arr = array_values(preg_grep("/^[^#]/", $filecontents));

   # Loop through the actual name~value pairs
   foreach ($arr as $line_num => $line)
   {
      if ( preg_match("/^\s*$/", $line) ) continue;
      list($name,$value) = explode('~', $line, 2);

      # Remove leading and trailing spaces in the name
      $name = preg_replace("/^\s+/", "", $name);
      $name = preg_replace("/\s+$/", "", $name);

      # Remove trailing spaces in the value
      $value = preg_replace("/\s+$/", "", $value);

      #print "$name $value\n";

      define(strtoupper($name), $value);
   }
}
?>
