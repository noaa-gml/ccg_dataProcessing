var omdir = '/var/www/html/om/';
var omurl = '/om/';

var allow = {
user: '',
level: 0,
pfp: '',
flask: '',
tower: '',
obs: '',
om: '',
pcp: '',
psu: '',
ccg:''''}

var defaults1 = {
code: '',
date: '',
time: '999999',
id:   '',
meth: 'D',
lat:  '99 99S',
lon:  '999 99W',
alt:  '-9999.99',
ws:    '-99.9',
wd:    '999',
press:'-9999.9',
temp: '-999.9',
rh:   '-999.9',
comment: ''}

var defaults2 = {
code: '',
date: '9999-12-31',
time: '00:00:00',
id:   '',
meth: 'A',
lat:  '-99.9999',
lon:  '-999.9999',
alt:  '-9999.99',
press:'-9999.9',
temp: '-999.9',
rh:   '-999.9',
comment: ''}

var defaults3 = {
code: '',
date: '',
time: '00:00:00',
id:   '',
meth: 'A',
lat:  '-99.9999',
lon:  '-999.9999',
alt:  '-9999.99',
press:'-9999.9',
temp: '-999.9',
rh:   '-999.9',
comment: ''}

function GetAccessLevel(user, group)
{
	var i, j, arr;

	arr = group.split(',');
	
	for (i=0; i<arr.length; i++) { 
		//jwm 10/26/2023.  Oddly had to add case insensitive (uc) as some users started coming through with capitalized names.
		if (arr[i].toUpperCase() == user.toUpperCase()){break;}

		//else{alert(arr[i]);alert(user);} 
	
	}
	j = (i < arr.length) ? 1 : 0;

	return j;
}

function SetBackground(element,state)
{
	var color = (state) ? 'paleturquoise' : 'white';
	element.style.backgroundColor=color;
}

function Dec2Deg(deg,type)
{
        var abv, min;
	var v_f = parseFloat(deg);
	var v_i = parseInt(deg);

	abv = Math.abs(v_f);
	deg = Math.abs(v_i);
	min = parseInt((abv-deg)*60);

        var h;
	switch(type)
        {
	case 'lat':

		h = (v_f >= 0) ? 'N' : 'S';
		break;
	case 'lon':
		h = (v_f >= 0) ? 'E' : 'W';
		break;
	}
	return deg+' '+min+h;
}

function Deg2Dec(v)
{
	a = v.split(/\s+/);
	z = a[1].toLowerCase();
	h = z.substr(z.length-1,1);
	min = parseInt(z.substr(0,z.length-1));
	deg = parseInt(a[0]);

	if ((h == 's' || h == 'n') && deg > 90) return -99.9999;
	if ((h == 'e' || h == 'w') && deg > 180) return -999.9999;

	sign = (h == 's' || h == 'w') ? -1 : 1;
	return (sign*(deg + min/60)).toFixed(4);
}

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

	yr = parseInt(julian/1000);
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

	yr = parseInt(date.substr(5,4));
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

	return parseInt(yr*1000)+doy;
}

function getRadioValue(radioObj)
{
   //
   // This function was found at:
   // http://www.somacon.com/p143.php
   //
   if(!radioObj)
      return "";
   var radioLength = radioObj.length;
   if(radioLength == undefined)
      if(radioObj.checked)
         return radioObj.value;
      else
         return "";
   for(var i = 0; i < radioLength; i++) {
      if(radioObj[i].checked) {
         return radioObj[i].value;
      }
   }
   return "";
}

function setRadioValue(radioObj, newValue)
{
   //
   // This function was found at:
   // http://www.somacon.com/p143.php
   //
   if(!radioObj)
      return;
   var radioLength = radioObj.length;
   if(radioLength == undefined) {
      radioObj.checked = (radioObj.value == newValue.toString());
      return;
   }
   for(var i = 0; i < radioLength; i++) {
      radioObj[i].checked = false;
      if(radioObj[i].value == newValue.toString()) {
         radioObj[i].checked = true;
      }
   }
}

function getSelectValue(selectObj)
{
   if ( !selectObj )
      return;
   var selectLength = selectObj.length;
   if(selectLength == undefined)
      if(selectObj.selected)
         return selectObj.value;
      else
         return "";
   for(var i = 0; i < selectLength; i++) {
      if(selectObj[i].selected) {
         return selectObj[i].value;
      }
   }
   return "";
   
}

function setSelectValue(selectObj, newValue)
{
   if(!selectObj)
      return;
   var selectLength = selectObj.length;
   if(selectLength == undefined) {
      selectObj.selected = (selectObj.value == newValue.toString());
      return;
   }
   for(var i = 0; i < selectLength; i++) {
      selectObj[i].selected = false;
      if(selectObj[i].value == newValue.toString()) {
         selectObj[i].selected = true;
      }
   }
}

function in_array (needle, haystack, argStrict)
{
    // Checks if the given value exists in the array  
    // 
    // version: 1006.1915
    // discuss at: http://phpjs.org/functions/in_array    // +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +   improved by: vlado houba
    // +   input by: Billy
    // +   bugfixed by: Brett Zamir (http://brett-zamir.me)
    // *     example 1: in_array('van', ['Kevin', 'van', 'Zonneveld']);    // *     returns 1: true
    // *     example 2: in_array('vlado', {0: 'Kevin', vlado: 'van', 1: 'Zonneveld'});
    // *     returns 2: false
    // *     example 3: in_array(1, ['1', '2', '3']);
    // *     returns 3: true    // *     example 3: in_array(1, ['1', '2', '3'], false);
    // *     returns 3: true
    // *     example 4: in_array(1, ['1', '2', '3'], true);
    // *     returns 4: false
    var key = '', strict = !!argStrict; 
    if (strict) {
        for (key in haystack) {
            if (haystack[key] === needle) {
                return true;            }
        }
    } else {
        for (key in haystack) {
            if (haystack[key] == needle) {                return true;
            }
        }
    }
     return false;
}
