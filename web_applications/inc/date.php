<?PHP
#
# Filename: date.php
# Info: Contains date functions
#

#
# Function Date2Dec ########################################################
#
function Date2Dec($yr,$mo,$dy,$hr,$mn)
{
   #
   #######################################
   # Convert yr mo dy hr mn to decimal year
   #######################################
   #
   $arr = array(array(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
                array(0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

   $mo = ($mo) ? $mo : 1;
   $dy = ($dy) ? $dy : 15;
   $hr = ($hr) ? $hr : 12;
   $mn = ($mn) ? $mn : 0;

   $leap = (($yr%4==0 && $yr%100 != 0) || ($yr%400 == 0)) ? 1.0 : 0.0;

   for ($i=1,$d=$dy; $i<$mo; $i++) { $d += $arr[$leap][$i]; }
   $dd = $yr+(($d-1.0)*24.0+$hr+($mn/60.0))/((365.0+$leap)*24.0);

    return $dd;
}
#
# Function Julian2Date ########################################################
#
function Julian2Date($j)
{
   #
   # Convert julian date (1992051) 21FEB1992 format.
   #
   $arr = array(array(-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334),
                array( -9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 ));

   $yr = $j/1000;
   $leap = ($yr%4==0 && $yr%100!=0) || $yr%400==0;
   $doy = $julian%1000; 
   
   for ($mo=1; $mo<13; $mo++)
      if ($diy[$leap][$mo] >= $doy) break;
   $mo-=1;
   $dy=$doy-$diy[$leap][$mo];
   
   $mon = GetMonthName($mo);

   return sprintf("%02d%s%4d",$dy,$mon,$yr);
}

?>
