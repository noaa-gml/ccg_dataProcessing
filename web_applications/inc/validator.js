//
//
// Some functions found at http://www.mattkruse.com/javascript/validations/source.html
//


//
////////////////////////////////////////////////////////////////////////////////////
// Field validationg functions
////////////////////////////////////////////////////////////////////////////////////
//

function isBlank(val)
{
   var i;

   if ( isNull(val) ) { return true; }

   val = val.toString();

   for ( i=0; i<val.length; i++ )
   {
      if ( (val.charAt(i) != ' ') && (val.charAt(i) != "\t") && (val.charAt(i) != "\n") && (val.charAt(i) != "\r") )
      { return false; }
   }
   return true;
}

function ValidDate(d_val)
{
   var i;

   if ( isBlank(d_val) ) { return false; }

   //
   // Check that the date is in the right format
   // - Used this method instead of regular expressions because they are not supported
   //      until IE4 and NS4
   // YYYY-MM-DD
   //
   var dcount = 0;
   for ( i=0; i<d_val.length; i++ )
   {
      chkchar = d_val.charAt(i);
      if ( ! isDigit(chkchar) && ! inString(chkchar,"-") ) { return false; }

      if ( inString(chkchar,"-") ) { dcount ++; }
   }
   if ( dcount != 2 ) { return false; }
 
   tmp = d_val.split("-");
   yr = tmp[0]; mo = tmp[1]; dy = tmp[2];


   if ( ! ValidInt(yr) ) { return false; }
   if ( ! ValidInt(mo) ) { return false; }
   if ( ! ValidInt(dy) ) { return false; }
   if ( ! ValidRange(yr,"1900","9999","int")) { return false; }
   if ( ! ValidRange(mo,"1","12","int")) { return false; }
   if ( ! ValidRange(dy,"1","31","int")) { return false; }

   // Check days in month
   dim_noleap = new Array(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   dim_leap = new Array(0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

   if ((yr%4==0 && yr%100 != 0) || (yr%400 == 0))
   { maxdim = dim_leap[mo]; }
   else
   { maxdim = dim_noleap[mo]; }

   if (dy < 1 || dy > maxdim) { return false; }

   return true;
}

function ValidFloat(flt_val)
{
   var i;
   var chkchar;
   var pcount = 0;

   flt_val = flt_val.toString();

   if ( isBlank(flt_val) ) { return false; }

   for ( i=0; i<flt_val.length; i++ )
   {
      chkchar = flt_val.charAt(i);
      if ( i == 0 && flt_val.length > 1 )
      {
         if ( !isDigit(chkchar) && !inString(chkchar,"-") && !inString(chkchar,".") && !inString(chkchar,"+") )
         { return false; }

         if ( inString(chkchar,".") ) { pcount++; }
      }
      else
      {
         if ( !isDigit(chkchar) && !inString(chkchar,".") )
         { return false; }

         if ( inString(chkchar,".") ) { pcount++; }
      }

      if ( pcount > 1 ) { return false; }
   }
   return true;
}

function ValidInt(int_val)
{
   var i, chkchar;

   int_val = int_val.toString();

   if ( isBlank(int_val) ) { return false; }

   for ( i=0; i<int_val.length; i++ )
   {
      chkchar = int_val.charAt(i);
      if ( i == 0 && int_val.length > 1 )
      {
         if ( !isDigit(chkchar) && !inString(chkchar,"-") && !inString(chkchar,"+") )
         { return false; }
      }
      else
      {
         if ( !isDigit(chkchar) )
         { return false; }
      }
   }
   return true;
}

function ValidLength(value,min,max)
{
   if ( ! ValidInt(min) ) { return false; }
   if ( ! ValidInt(max) ) { return false; }

   if ( value.length < parseInt(min,10) ) { return false; }
   if ( value.length > parseInt(max,10) ) { return false; } 
   return true;
}

function ValidRange(value,min,max,type)
{
   switch (type)
   {
      case "date":
         if ( ! ValidDate(value) ) { return false; }

         var tmp;
         var yr, mo, dy;
         var dec, mindec, maxdec;

         tmp = value.split("-");
         yr = tmp[0]; mo = tmp[1]; dy = tmp[2];

         dec = Date2Dec(yr,mo,dy,12,0);
         
         if ( ! isNull(min) )
         {
            if ( ! ValidDate(min) ) { return false; }

            tmp = min.split("-");
            mindec = Date2Dec(tmp[0],tmp[1],tmp[2],12,0);
            if (dec < mindec) { return false; }
         }

         if ( ! isNull(max) )
         {
            if ( ! ValidDate(max) ) { return false; }

            tmp = max.split("-");
            maxdec = Date2Dec(tmp[0],tmp[1],tmp[2],12,0);
            if (dec > maxdec) { return false; }
         }
         break;
      case "int":
         if ( ! ValidInt(value) ) { return false; }

         if ( ! isNull(min) )
         {
            if ( ! ValidInt(min) ) { return false; }
            if ( parseInt(value,10) < parseInt(min,10) ) { return false; }
         }

         if ( ! isNull(max) )
         {
            if ( ! ValidInt(max) ) { return false; }
            if ( parseInt(value,10) > parseInt(max,10) ) { return false; }
         }
         break;
      case "float":
         if ( ! ValidFloat(value) ) { return false; }

         if ( ! isNull(min) )
         {
            if ( ! ValidFloat(min) ) { return false; }
            if ( parseFloat(value) < parseFloat(min) ) { return false; }
         }

         if ( ! isNull(max) )
         {
            if ( ! ValidFloat(max) ) { return false; }
            if ( parseFloat(value) > parseFloat(max) ) { return false; }
         }
         break;
      default:
         if ( ! isNull(min) )
         { if ( value < min ) { return false; } }
         if ( ! isNull(max) )
         { if ( value > max ) { return false; } }
         break;
   }
   return true;
}

function ValidTime(t_val)
{
   var i;

   if ( isBlank(t_val) ) { return false; }

   //
   // Check that the date is in the right format
   // - Used this method instead of regular expressions because they are not supported
   //      until IE4 and NS4
   // HH:MM:SS
   //
   var ccount = 0;
   for ( i=0; i<t_val.length; i++ )
   {
      chkchar = t_val.charAt(i);
      if ( ! isDigit(chkchar) && ! inString(chkchar,":") ) { return false; }

      if ( inString(chkchar,":") ) { ccount ++; }
   }
   if ( ccount != 2 ) { return false; }
 
   tmp = t_val.split(":");
   hr = tmp[0]; mn = tmp[1]; sc = tmp[2];

   if ( !ValidRange(hr,"0","23","int")) { return false; }
   if ( !ValidRange(mn,"0","59","int")) { return false; }
   if ( !ValidRange(sc,"0","59","int")) { return false; }

   return true;
}

function inString(val,cstr)
{
   val = val.toString();
   cstr = cstr.toString();

   if ( val.length > 1 ) { return false; }
   if ( cstr.length > 1 ) { return false; }
   var string = cstr;
   if ( string.indexOf(val) != -1 ) { return true; }
   return false;
}

//
////////////////////////////////////////////////////////////////////////////////////
// Single character validationg functions
////////////////////////////////////////////////////////////////////////////////////
//

function isAlphaNum(val)
{
   val = val.toString();
   if ( ! isLetter(val) && ! isDigit(val) ) { return false; }
   return true;
}

function isDigit(val)
{
   val = val.toString();
   if ( val.length > 1 ) { return false; }
   var string = "1234567890";
   if ( string.indexOf(val) != -1 ) { return true; }
   return false;
}

function isLetter(val)
{
   val = val.toString();
   if ( ! isUpperLetter(val) && ! isLowerLetter(val) ) { return false; }
   return true;
}

function isNull(val)
{
   if ( val != null ) { return false; }
   return true;
}

function isLowerLetter(val)
{
   val = val.toString();
   if ( val.length > 1 ) { return false; }
   var string = "abcdefghijklmnopqrstuvwxyz";
   if ( string.indexOf(val) != -1 ) { return true; }
   return false;
}

function isUpperLetter(val)
{
   val = val.toString();
   if ( val.length > 1 ) { return false; }
   var string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
   if ( string.indexOf(val) != -1 ) { return true; }
   return false;
}

//
////////////////////////////////////////////////////////////////////////////////////
// Minimum & maximum functions
////////////////////////////////////////////////////////////////////////////////////
//
function MaxDate(value)
{
   if ( value != undefined && value.match(/^[0-9]{4}\-?$/) )
   {
      // Add month and day
      if ( value.match(/[0-9]$/) )
      {
         value = value+'-';
      }
      value = value+'12-31';
   }
   else if ( value != undefined && value.match(/^[0-9]{4}\-[0-9]{1,2}\-?$/) )
   {
      // Days in month
      dim_noleap = new Array(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
      dim_leap = new Array(0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

      fields = value.split('-');
      yr = parseInt(fields[0],10);
      mo = parseInt(fields[1],10);

      if ((yr%4==0 && yr%100 != 0) || (yr%400 == 0))
      { dy = dim_leap[mo]; }
      else
      { dy = dim_noleap[mo]; }

      // Add day
      if ( value.match(/[0-9]$/) )
      {
         value = value+'-';
      }
      value = value+dy;
   }
   else
   {
      value = '9999-12-31';
   }

   return value;
}

function MinDate(value)
{
   if ( value != undefined && value.match(/^[0-9]{4}\-?$/) )
   {
      // Add month and day

      if ( value.match(/[0-9]$/) )
      {
         value = value+'-';
      }
      value = value+'1-1';
   }
   else if ( value != undefined && value.match(/^[0-9]{4}\-[0-9]{1,2}\-?$/) )
   {
      // Add day
      if ( value.match(/[0-9]$/) )
      {
         value = value+'-';
      }
      value = value+'1';
   }
   else
   {
      value = '1900-01-01';
   }

   return value;
}

function MaxTime(value)
{
   if ( value != undefined && value.match(/^[0-9]{1,2}:?$/) )
   {
      // Add minutes and seconds
      if ( value.match(/[0-9]$/) )
      {
         value = value+':';
      }
      value = value+'59:59';
   }
   else if ( value != undefined && value.match(/^[0-9]{1,2}:[0-9]{2}:?$/) )
   {
      // Add seconds
      if ( value.match(/[0-9]$/) )
      {
         value = value+':';
      }
      value = value+'59';
   }
   else
   {
      value = '23:59:59';
   }

   return value;
}

function MinTime(value)
{
   if ( value != undefined && value.match(/^[0-9]{1,2}:?$/) )
   {
      // Add minutes and seconds
      if ( value.match(/[0-9]$/) )
      {
         value = value+':';
      }
      value = value+'00:00';
   }
   else if ( value != undefined && value.match(/^[0-9]{1,2}:[0-9]{2}:?$/) )
   {
      // Add seconds
      if ( value.match(/[0-9]$/) )
      {
         value = value+':';
      }
      value = value+'00';
   }
   else
   {
      value = '00:00:00';
   }

   return value;
}

function MaxLatitude()
{
   value = parseFloat('90.0');
   return value;
}

function MinLatitude()
{
   value = parseFloat('-90.0');
   return value;
}

function MaxLongitude()
{
   value = parseFloat('180.0');
   return value;
}

function MinLongitude()
{
   value = parseFloat('-180.0');
   return value;
}

function MaxHeight()
{
   value = parseFloat('99999.99999');
   return value;
}

function MinHeight()
{
   value = parseFloat('-99999.99999');
   return value;
}

//
////////////////////////////////////////////////////////////////////////////////////
// Miscellaneous validationg functions
////////////////////////////////////////////////////////////////////////////////////
//

function in_array (needle, haystack, argStrict) {
    // http://kevin.vanzonneveld.net
    // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: vlado houba
    // +   input by: Billy
    // +   bugfixed by: Brett Zamir (http://brett-zamir.me)
    // *     example 1: in_array('van', ['Kevin', 'van', 'Zonneveld']);
    // *     returns 1: true
    // *     example 2: in_array('vlado', {0: 'Kevin', vlado: 'van', 1: 'Zonneveld'});
    // *     returns 2: false
    // *     example 3: in_array(1, ['1', '2', '3']);
    // *     returns 3: true
    // *     example 3: in_array(1, ['1', '2', '3'], false);
    // *     returns 3: true
    // *     example 4: in_array(1, ['1', '2', '3'], true);
    // *     returns 4: false

    var key = '', strict = !!argStrict;

    if (strict) {
        for (key in haystack) {
            if (haystack[key] === needle) {
                return true;
            }
        }
    } else {
        for (key in haystack) {
            if (haystack[key] == needle) {
                return true;
            }
        }
    }

    return false;
}
