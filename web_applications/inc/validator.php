<?PHP
#
# Form validation functions
#

#
########################################################################################
# Field validating functions
########################################################################################
#
function isBlank($val)
{
   # empty checks for "", 0, "0", NULL, FALSE, array(),
   #    and var $var [declared variable without a value]
   if ( strlen($val) == 0 ) { return TRUE; }

   $val_arr = str_split($val);

   for ( $i=0; $i<count($val_arr); $i++ )
   {
      if ( preg_match("/[^ \t\n\r]/", $val_arr[$i] ) ) { return FALSE; }
   }

   return TRUE;
}
function ValidDate($d_val)
{
   if ( isBlank($d_val) ) { return FALSE; }

   if ( ! is_string($d_val) ) { return FALSE; }

   if ( ! preg_match("/^[0-9]{4}\-[0-9]{1,2}\-[0-9]{1,2}$/", $d_val) )
   { return FALSE; }

   list($yr, $mo, $dy) = explode("-", $d_val);

   $mindate = MinDate();
   $maxdate = MaxDate();

   list($mindateyr, $mindatemo, $mindatedy) = explode("-", $mindate);
   list($maxdateyr, $maxdatemo, $maxdatedy) = explode("-", $maxdate);

   if ( ! ValidinRange($yr,$mindateyr,$maxdateyr,"int") ) { return FALSE; }
   if ( ! ValidinRange($mo,$mindatemo,$maxdatemo,"int") ) { return FALSE; }
   if ( ! ValidinRange($dy,$mindatedy,$maxdatedy,"int") ) { return FALSE; }

   if ( ! checkdate($mo, $dy, $yr) ) { return FALSE; }

   return TRUE;
}

function ValidDatetime($dt_val)
{
   if ( isBlank($dt_val) ) { return FALSE; }

   if ( ! is_string($dt_val) ) { return FALSE; }

   if ( ! preg_match("/^[0-9]{4}\-[0-9]{1,2}\-[0-9]{1,2} [0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}$/", $dt_val) )
   { return FALSE; }

   list($date, $time) = preg_split('/\s/', $dt_val, 2);

   if ( ValidDate($date) && ValidTime($time) )
   { return TRUE; }
   else
   { return FALSE; }
}

function ValidFloat($flt_val)
{
   if ( ! is_numeric($flt_val) ) { return FALSE; }

   if ( preg_match("/^[+-]?[0-9]*\.?[0-9]+$/", $flt_val) ) { return TRUE; }
   return FALSE;
}

function ValidinRange($value, $min, $max, $type="other")
{
   switch ( $type )
   {
      case "date":
         if ( ! ValidDate($value) ) { return FALSE; }

         list($yr, $mo, $dy) = explode("-", $value);

         $dec = Date2Dec($yr, $mo, $dy, 12, 0);

         if ( ! isNULL($min) )
         {
            if ( ! ValidDate($min) ) { return FALSE; }

            list($minyr, $minmo, $mindy) = explode("-", $min);
            $mindec = Date2Dec($minyr, $minmo, $mindy, 12, 0);
            if ( $dec < $mindec ) { return false; }
         }

         if ( ! isNULL($max) )
         {
            if ( ! ValidDate($max) ) { return FALSE; }

            list($maxyr, $maxmo, $maxdy) = explode("-", $max);
            $maxdec = Date2Dec($maxyr, $maxmo, $maxdy, 12, 0);
            if ( $dec > $maxdec ) { return false; }
         }
         break;
      case "int":
         if ( ! ValidInt($value) ) { return FALSE; }

         if ( ! isNULL($min) )
         {
            if ( ! ValidInt($min) ) { return FALSE; }
            if ( intval($value) < intval($min) ) { return FALSE; }
         }

         if ( ! isNULL($max) )
         {
            if ( ! ValidInt($max) ) { return FALSE; }
            if ( intval($value) > intval($max) ) { return FALSE; }
         }
         break;
      case "float":
         if ( ! ValidFloat($value) ) { return FALSE; }

         if ( ! isNULL($min) )
         {
            if ( ! ValidFloat($min) ) { return FALSE; }
            if ( floatval($value) < floatval($min) ) { return FALSE; }
         }

         if ( ! isNULL($max) )
         {
            if ( ! ValidFloat($max) ) { return FALSE; }
            if ( floatval($value) > floatval($max) ) { return FALSE; }
         }
         break;
      default:
         if ( ! isNULL($min) )
         { if ( $value < $min ) { return FALSE; } }
         if ( ! isNULL($max) )
         { if ( $value > $max ) { return FALSE; } }
         break;
   }
   return TRUE;
}

function ValidInt($int_val)
{
   if ( ! is_numeric($int_val) ) { return FALSE; }

   if ( preg_match("/^[+-]?[0-9]+$/", $int_val ) ) { return TRUE; }
   return FALSE;
}

function ValidLength($value, $min, $max)
{
   if ( ! ValidInt($min) ) { return FALSE; }
   if ( ! ValidInt($max) ) { return FALSE; }

   if ( strlen($value) < $min ) { return FALSE; }
   if ( strlen($value) > $max ) { return FALSE; }
   return TRUE;
}

function ValidTime($t_val)
{
   if ( isBlank($t_val) ) { return FALSE; }

   if ( ! is_string($t_val) ) { return FALSE; }

   # If only the hour and minute were specified, add the seconds
   if ( preg_match("/^[0-9]{1,2}:[0-9]{2}$/", $t_val) )
   { $t_val = $t_val.":00"; }

   if ( ! preg_match("/^[0-9]{1,2}:[0-9]{2}:[0-9]{2}$/", $t_val) )
   { return FALSE; }

   list($yr, $mo, $dy) = explode("-", date("Y-m-d"));

   list($hr, $mn, $sc) = explode(":", $t_val);

   $mintime = MinTime();
   $maxtime = MaxTime();

   list($mintimehr, $mintimemn, $mintimesc) = explode(":", $mintime);
   list($maxtimehr, $maxtimemn, $maxtimesc) = explode(":", $maxtime);

   if ( ! ValidinRange($hr,$mintimehr,$maxtimehr,"int") ) { return FALSE; }
   if ( ! ValidinRange($mn,$mintimemn,$maxtimemn,"int") ) { return FALSE; }
   if ( ! ValidinRange($sc,$mintimesc,$maxtimesc,"int") ) { return FALSE; }

   # With 0 padding
   $t_chk1 = date("H:i:s", mktime($hr, $mn, $sc, $mo, $dy, $yr));
   # Without 0 padding
   $t_chk2 = date("G:i:s", mktime($hr, $mn, $sc, $mo, $dy, $yr));

   if ( $t_val === $t_chk1 || $t_val === $t_chk2 ) { return TRUE; }
   return FALSE;
}

#
########################################################################################
# Single character validating functions
########################################################################################
#
function isAlphaNum($val)
{
   if ( ! isLetter($val) && ! isDigit($val) ) { return FALSE; }
   return TRUE;
}


function isDigit($val)
{
   if ( strlen($val) > 1 ) { return FALSE; }
   if ( ! preg_match("/^[0-9]$/", $val) ) { return FALSE; }
   return TRUE;
}

function isLetter($val)
{
   if ( ! isLowerLetter($val) && ! isUpperLetter($val) )
   { return FALSE; }
   return TRUE;
}

function isNULL($val)
{
   if ( is_null($val) ) { return TRUE; }
   return FALSE;
}

function isLowerLetter($val)
{
   if ( strlen($val) > 1 ) { return FALSE; }
   if ( ! preg_match("/^[a-z]$/", $val) ) { return FALSE; }
   return TRUE;
}

function isUpperLetter($val)
{
   if ( strlen($val) > 1 ) { return FALSE; }
   if ( ! preg_match("/^[A-Z]$/", $val) ) { return FALSE; }
   return TRUE;
}

#
########################################################################################
# Minimum & maximum functions
########################################################################################
#
function MaxDate($value='')
{
   if ( preg_match('/^[0-9]{4}$/', $value ) )
   {
      $value = $value.'-12-31';
   }
   elseif ( preg_match('/^[0-9]{4}\-[0-9]{1,2}$/', $value ) )
   {
      // Days in month
      $dim_noleap = array ('0','31','28','31','30','31','30','31','31','30','31','30','31');
      $dim_leap = array ('0','31','29','31','30','31','30','31','31','30','31','30','31');

      $fields = explode('-', $value);
      $yr = $fields[0];
      $mo = $fields[1];

      if (($yr%4==0 && $yr%100 != 0) || ($yr%400 == 0))
      { $dy = $dim_leap[$mo]; }
      else
      { $dy = $dim_noleap[$mo]; }

      // Add day
      $value = $value.'-'.$dy;
   }
   else
   {
      $value = '9999-12-31';
   }

   return $value;
}

function MinDate($value='')
{
   if ( preg_match('/^[0-9]{4}$/', $value ) )
   {
      $value = $value.'-1-1';
   }
   elseif ( preg_match('/^[0-9]{4}\-[0-9]{1,2}$/', $value ) )
   {
      $value = $value.'-1';
   }
   else
   {
      $value = '1900-1-1';
   }

   return $value;
}

function MaxTime($value='')
{
   if ( preg_match('/^[0-9]{1,2}$/', $value ) )
   {
      $value = $value.':59:59';
   }
   elseif ( preg_match('/^[0-9]{1,2}:[0-9]{2}$/', $value ) )
   {
      $value = $value.':59';
   }
   else
   {
      $value = '23:59:59';
   }

   return $value;
}

function MinTime($value='')
{
   if ( preg_match('/^[0-9]{1,2}$/', $value ) )
   {
      $value = $value.':00:00';
   }
   elseif ( preg_match('/^[0-9]{1,2}:[0-9]{2}$/', $value ) )
   {
      $value = $value.':00';
   }
   else
   {
      $value = '00:00:00';
   }

   return $value;
}

function MaxLatitude()
{
   $value = floatval('90.0');
   return $value;
}

function MinLatitude()
{
   $value = floatval('-90.0');
   return $value;
}

function MaxLongitude()
{
   $value = floatval('180.0');
   return $value;
}

function MinLongitude()
{
   $value = floatval('-180.0');
   return $value;
}

function MaxHeight()
{
   $value = floatval('99999.99999');
   return $value;
}

function MinHeight()
{
   $value = floatval('-99999.99999');
   return $value;
}

#
########################################################################################
# Miscellaneous functions
########################################################################################
#
function inString($str, $cstr)
{
   $pos = strpos($str, $cstr);
   if ( $pos === false ) { return FALSE; }
   return TRUE;
}

function in_clnarray($element, $array )
{

   if ( ! is_array($array) ) { return(FALSE); }

   for ( $i=0; $i<count($array); $i++ )
   {
      if ( $array[$i] === $element ) { return(TRUE); }
   }

   return(FALSE);
}

?>
