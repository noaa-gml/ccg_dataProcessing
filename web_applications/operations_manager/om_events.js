function SubmitCB()
{
   var f = document.mainform;
   var str = '';
   var datachk = '';

   SetDate(f.ev_date1, f.ev_date2);

   str = str + f.ev_num.value + '|';
   str = str + f.ev_code.value + '|';
   str = str + f.selectproject[f.selectproject.selectedIndex].value + '|';
   f.ev_date1.value = (f.ev_date1.value == '') ? f.ev_date2.value : f.ev_date1.value;
   f.ev_date2.value = (f.ev_date2.value == '') ? f.ev_date1.value : f.ev_date2.value;
   str = str + f.ev_date1.value + '|';
   str = str + f.ev_date2.value + '|';
   f.ev_time1.value = (f.ev_time1.value == '') ? f.ev_time2.value : f.ev_time1.value;
   f.ev_time2.value = (f.ev_time2.value == '') ? f.ev_time1.value : f.ev_time2.value;
   str = str + f.ev_time1.value + '|';
   str = str + f.ev_time2.value + '|';
   str = str + f.ev_id.value + '|';

   if ( f.ev_loopdb.checked == true && f.ev_id.value == '' )
   {
      alert("Must input an id for 'In Analysis' results");
      return;
   }

   datachk = f.ev_num.value + f.ev_code.value + f.ev_date1.value + f.ev_id.value + f.an_date1.value + f.ev_comment.value;

   if ( datachk == '' )
   {
      alert("Collection event num, code, date, id, comment or measurement date must be specified");
      return;
   }

   z = (f.ev_loopdb.checked == true) ? 1 : 0;
   str = str + z + '|';

   str = str + f.ev_meth.value + '|';
   str = str + f.ev_comment.value + '|';
   //
   // Prepare Gas list
   //
   for (i=0,list=''; i<f.selectparam.length; i++)
   {
      if (f.selectparam[i].selected)
      {
         list = (list) ? list + ',' + f.selectparam[i].value : f.selectparam[i].value;
         if (i <= 1) break;
      }
   }

   SetDate(f.an_date1, f.an_date2);

   str = str + list + '|';
   str = str + f.selectflag.value + '|';
   str = str + f.an_id.value + '|';
   f.an_date1.value = (f.an_date1.value == '') ? f.an_date2.value : f.an_date1.value;
   f.an_date2.value = (f.an_date2.value == '') ? f.an_date1.value : f.an_date2.value;
   str = str + f.an_date1.value + '|';
   str = str + f.an_date2.value + '|';
   f.an_time1.value = (f.an_time1.value == '') ? f.an_time2.value : f.an_time1.value;
   f.an_time2.value = (f.an_time2.value == '') ? f.an_time1.value : f.an_time2.value;
   str = str + f.an_time1.value + '|';
   str = str + f.an_time2.value + '|';

   f.input.value = str;
   f.task.value = 'query';
   f.submit();
}

function SetDate(date1, date2 )
{
  if ( date1.value == '' && date2.value == '' ) return;

  now = new Date();
  yr = now.getFullYear();
  mo = now.getMonth();
  dy = now.getDate();

  mo = mo+1;

  tmp1 = date1.value.split(/\-/);
  tmp2 = date2.value.split(/\-/);

  if ( date1.value != '' && date2.value == '' )
  {
     if ( tmp1[1] == null )
     {
        if ( tmp1[2] == null )
        {
           date1.value = date1.value + '-1-1';
        }
     }
     else
     {
        if ( tmp1[2] == null )
        {
           date1.value = date1.value + '-1';
        }
     }
     date2.value = yr + '-' + mo + '-' + dy; 
     if ( date1.value > date2.value )
     {
        date2.value = '';
     }
  }
}

function ResetCB()
{
   f = document.mainform;
   var ooutput = top.document.getElementById('output');

   f.ev_num.value = '';
   f.ev_code.value = '';
   f.selectproject.selectedIndex = 0;
   f.ev_date1.value = '';
   f.ev_date2.value = '';
   f.ev_time1.value = '';
   f.ev_time2.value = '';
   f.ev_id.value = '';
   f.ev_loopdb.checked = false;
   f.ev_meth.value = '';
   f.ev_comment.value = '';


   for (i=0; i<f.selectparam.length; i++) { f.selectparam[i].selected = false; }
   f.selectparam[0].selected = true;

   f.selectflag[0].selected = true;
   f.an_id.value = '';
   f.an_date1.value = '';
   f.an_date2.value = '';
   f.an_time1.value = '';
   f.an_time2.value = '';

   ooutput.innerHTML = '';
}

function ChkDate(element)
{
   f = document.mainform;
   month = new Array('jan','feb','mar','apr','may','jun',
                     'jul','aug','sep','oct','nov','dec');
   dim =   new Array(  31,   29,   31,   30,   31,   30,
                       31,   31,   30,   31,   30,   31);

   t_s = element.value;

   if (t_s.length != 8 && t_s.length != 9) { return false; }
   if (t_s.length == 8) { t_s = '0'+t_s; }

   dy = parseFloat(t_s.substr(0,2));
   if (dy < 1 || dy > 31) { return false; }

   mo = t_s.substr(2,3);
   key = new RegExp(mo,'i');


   for (imo=0; imo<month.length; imo++) { if ((r=month[imo].match(key)) != null ) { break; } }
   if (imo == month.length) { return false; }
   if (dy > dim[imo]) { return false; }

   yr = parseInt(t_s.substr(5,4),10);
   if (yr < 0) { return false; }
   //
   // Future date?
   //
   dec = Date2Dec(yr,imo+1,dy,12,0);
   now = new Date();
   yr = now.getFullYear();
   mo = now.getMonth();
   dy = now.getDate();
   today = Date2Dec(yr,mo+1,dy,12,0);
   if (dec > today) { return false; }

   element.value = t_s;
   return true;
}

function ChkTime(element)
{
   t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   if (t_s == defaults1.time) { return true; }

   t_i = parseInt(t_s,10);
   if (t_i<0) { return false; }
   //
   // pad with zeros
   //
   for (i=t_s.length,z=''; i<4; i++) { z = z.concat('0'); }
   t_s = z + t_s;
   //
   //valid time?
   //
   hr = t_s.substr(0,2);
   mn = t_s.substr(2,2);
   if (hr > 23 || mn > 59) { return false; }
   element.value = t_s;
   return true;
}

function ChkId(element)
{
   t_s = element.value;

   if (t_s == '') { return false; }
   return true;
}

function ChkMethod(element)
{
   t_s = element.value;

   if (t_s == '?' || t_s == '') { return false; }

   element.value = t_s.toUpperCase();

   return true;
}

function ChkTemp(element)
{
   t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   return true;
}

function ChkPress(element)
{
   t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   return true;
}

function ChkRH(element)
{
   t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   return true;
}

function ChkLat(element)
{
   t_s = element.value.toUpperCase();

   if (t_s.length < 4) { return false; }

   if (t_s == defaults1.lat) { return true; }

   tmp = t_s.split(/\s+/);
   if (tmp.length != 2 ) { return false; }
   if (tmp[0] < 0 || tmp[0] > 90) { return false; }

   h = tmp[1].charAt(tmp[1].length-1);
   if (h != 'S' && h != 'N') { return false; }

   m = tmp[1].substring(0,tmp[1].length-1);
   if (m < 0 || m > 59) { return false; }
   element.value = t_s;
   return true;
}

function ChkLon(element)
{
   t_s = element.value.toUpperCase();

   if (t_s.length < 4) { return false; }

   if (t_s == defaults1.lon) { return true; }

   tmp = t_s.split(/\s+/);
   if (tmp.length != 2 ) { return false; }
   if (tmp[0] < 0 || tmp[0] > 180) { return false; }

   h = tmp[1].charAt(tmp[1].length-1);
   if (h != 'W' && h != 'E') { return false; }

   m = tmp[1].substring(0,tmp[1].length-1);
   if (m < 0 || m > 59) { return false; }
   element.value = t_s;
   return true;
}

function ChkReal(item)
{
   //
   //Allowable characters are 0-9,.,-
   //
   if (item == '' || (isNaN(item))) { return false; } else { return true; }
}

function ChkEvent()
{
   f = document.mainform;
   if (!(ChkCode(f.ev_code))) { f.ev_code.focus(); alert('Improper Code'); return false; }
   if (!(ChkDate(f.ev_date))) { f.ev_date.focus(); alert('Improper Date'); return false; }
   if (!(ChkTime(f.ev_time))) { f.ev_time.focus(); alert('Improper Time'); return false; }
   if (!(ChkId(f.ev_id))) { f.ev_id.focus(); alert('Improper Id'); return false; }
   if (!(ChkMethod(f.ev_meth))) { f.ev_meth.focus(); alert('Improper Method'); return false; }
   if (!(ChkTemp(f.ev_temp))) { f.ev_temp.focus(); alert('Improper Temperature'); return false; }
   if (!(ChkPress(f.ev_press))) { f.ev_press.focus(); alert('Improper Pressure'); return false; }
   if (!(ChkRH(f.ev_rh))) { f.ev_rh.focus(); alert('Improper Relative Humidity'); return false; }
   if (!(ChkLat(f.ev_lat))) { f.ev_lat.focus(); alert('Improper Latitude'); return false; }
   if (!(ChkLon(f.ev_lon))) { f.ev_lon.focus(); alert('Improper Longitude'); return false; }
   if (!(ChkReal(f.ev_alt.value))) { f.ev_alt.focus(); alert('Improper Altitude'); return false; }
   return true;
}
