function Date2Dec(yr,mo,dy,hr,mn)
{
   var i,d,leap;

   var dim_noleap = new Array(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   var dim_leap = new Array(0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

   if ((yr%4==0 && yr%100 != 0) || (yr%400 == 0))
   {
      var dim=dim_leap;
      leap=1;
   }
   else
   {
      dim=dim_noleap;
      leap=0;
   }

   for (i=1,d=dy; i<mo; i++) { d += dim[i]; }
   return yr+((d-1)*24.0+hr+(mn/60.0))/((365+leap)*24.0);
}

function Julian2Date(julian)
{
   //
   // Convert julian date (1992051) 21FEB1992 format.
   //
   doy_noleap = new Array(-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
   doy_leap = new Array( -9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 );
   mon = new Array( '', 'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');
   var i;

   yr = parseInt(julian/1000,10);
   day = julian%1000;

   if ((yr%4==0 && yr%100 != 0) || (yr%400 == 0)) { doy=doy_leap; } else { doy=doy_noleap; }

   for (mo=1; mo<13; mo++) if (doy[mo] >= day) break;

   mo -= 1;
   dy = (day-doy[mo]).toString();
   //
   // pad day with zeros
   //
   for (i=dy.length,z=''; i<2; i++) { z = z.concat('0'); }
   dy = z + dy;

   return dy+mon[mo]+yr;
}

function Date2Julian(date,adj)
{
   //
   // Convert from date (21FEB1992) to julian (1992051) format.
   // May add or subtract days
   //
   doy_noleap = new Array(-9, 0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334);
   doy_leap = new Array( -9, 0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335 );
   mon = new Array( '', 'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');

   yr = parseInt(date.substr(5,4),10);
   mo = date.substr(2,3);
   dy = parseFloat(date.substr(0,2));

   leap = (yr%4==0 && yr%100!=0) || yr%400==0;

   key = new RegExp(mo,'i');
   for (mo=1; mo<13; mo++) if (mon[mo].search(key) != (-1)) break;

   doy = (leap) ? doy_leap[mo]+dy : doy_noleap[mo]+dy;

   doy += adj;

   if (doy > (365+leap)) { yr += 1; doy = 1; }
   if (doy == 0)
   {
      yr -= 1;
      leap = (yr%4==0 && yr%100!=0) || yr%400==0;
      doy = 365 + leap;
   }

   return parseInt(yr*1000,10)+doy;
}
