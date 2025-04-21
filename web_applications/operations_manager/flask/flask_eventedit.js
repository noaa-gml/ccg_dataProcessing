var npaths;
var siteinfo = new Array();

function SearchCB()
{
   var f = document.mainform;

   if (f.search4event.value == '') return;

   f.task.value='search';
   f.submit();
}

function AcceptCB()
{
   var f = document.mainform;

   if (f.ev_num.value == '') return;

   if (confirm('Are you sure?'))
   { if (ChkEvent() && ChkPath()) { BuildEventString(); f.task.value='accept'; f.submit(); } }
}

function DiscardCB()
{
   var f = document.mainform;

   if (f.ev_num.value == '') return;

   if (confirm('Are you sure?\nThis action will return remove event from DB.'))
   { f.task.value='discard'; f.submit(); }
}

function CancelCB()
{
   document.location = 'flask_blank.php';
}

function ClearCB()
{
   var f = document.mainform;

   if (f.ev_num.value == '') return;

   f.ev_code.value = '';
   f.ev_date.value = '';
   f.ev_time.value = '';
   f.ev_id.value = '';
   f.ev_meth.value = '';
   f.ev_ws.value = '';
   f.ev_wd.value = '';
   f.ev_lat.value = '';
   f.ev_lon.value = '';
   f.ev_alt.value = '';
   setSelectValue(f.ev_elev_source,'DB');
   f.ev_comment.value = '';
}

function RecallCB()
{
   var f = document.mainform;

   if (f.ev_num.value == '') return;

   if (f.ev_code.value == '') { f.ev_code.value = f.last_code.value; }
   if (f.ev_date.value == '') { f.ev_date.value = f.last_date.value; }
   if (f.ev_time.value == '') { f.ev_time.value = f.last_time.value; }
   if (f.ev_id.value == '') { f.ev_id.value = f.last_id.value; }
   if (f.ev_meth.value == '') { f.ev_meth.value = f.last_meth.value; }
   if (f.ev_ws.value == '') { f.ev_ws.value = f.last_ws.value; }
   if (f.ev_wd.value == '') { f.ev_wd.value = f.last_wd.value; }
   if (f.ev_lat.value == '') { f.ev_lat.value = f.last_lat.value; }
   if (f.ev_lon.value == '') { f.ev_lon.value = f.last_lon.value; }
   if (f.ev_alt.value == '') { f.ev_alt.value = f.last_alt.value; }
   if (f.ev_elev_source.value == '') { setSelectValue(f.ev_elev_source,f.last_elev_source.value); }
   if (f.ev_comment.value == '') { f.ev_comment.value = f.last_comment.value; }
}

function BuildEventString()
{
   var f = document.mainform;
   var lat, lon;

   if ( f.ev_ws.value == defaults1.ws ) { f.ev_ws.value = ''; }
   if ( f.ev_wd.value == defaults1.wd ) { f.ev_wd.value = ''; }

   var lat_units = getRadioValue(f.ev_lat_units);
   if ( lat_units == 'deg' ) { lat = Deg2Dec(f.ev_lat.value); }
   else { lat = f.ev_lat.value; } 

   var lon_units = getRadioValue(f.ev_lon_units);
   if ( lon_units == 'deg' ) { lon = Deg2Dec(f.ev_lon.value); }
   else { lon = f.ev_lon.value; } 

   var commentstr = '';
   var elev_source = getSelectValue(f.ev_elev_source);
   if ( f.ev_comment.value != '' )
   {
      commentstr = 'elev:'+elev_source+'~+~'+f.ev_comment.value;
   }
   else
   {
      commentstr = 'elev:'+elev_source;
   }

   a = new Array(f.ev_code.value,
                 f.projlist[f.projlist.selectedIndex].text,
                 f.ev_id.value,
                 Date2DBFormat(f.ev_date.value),
                 Time2DBFormat(f.ev_time.value),
                 f.ev_meth.value,
                 f.ev_ws.value,
                 f.ev_wd.value,
                 lat,
                 lon,
                 f.ev_alt.value,
                 commentstr,
            f.ev_num.value,
            f.lst2utc.value,
            f.status_num.value,
            f.path.value);
   f.event_detail.value = a.join('|');
}

function SetPosition()
{
   var f = document.mainform;

   if (f.ev_code.value == '') return;
   
   var key = new RegExp(f.ev_code.value,'i');

   for (i=0,j=(-1); i<siteinfo.length; i++) { if (siteinfo[i].match(key) != null) { j = i; } }
   if (j < 0)
   {
      f.ev_lat.value = defaults1.lat;
      f.ev_lon.value = defaults1.lon;
      f.ev_alt.value = defaults1.alt;
   }
   else
   {
      tmp = siteinfo[j].split(",");
      f.ev_lat.value = Dec2Deg(tmp[1],'lat');
      f.ev_lon.value = Dec2Deg(tmp[2],'lon');
      f.ev_alt.value = (tmp[4] < 0) ? defaults1.alt : parseFloat(tmp[3])+parseFloat(tmp[4]);
   }
   f.ev_code.value = f.ev_code.value.toUpperCase();
}

function SetDefaultsCB()
{
   var f = document.mainform;

   if (f.ev_num.value == '') return;

   if (f.ev_code.value == '') { f.ev_code.value = defaults1.code; }
   if (f.ev_date.value == '') { f.ev_date.value = defaults1.date; }
   if (f.ev_time.value == '') { f.ev_time.value = defaults1.time; }
   if (f.ev_id.value == '') { f.ev_id.value = defaults1.id; }
   if (f.ev_meth.value == '') { f.ev_meth.value = defaults1.meth; }
   if (f.ev_ws.value == '') { f.ev_ws.value = defaults1.ws; }
   if (f.ev_wd.value == '') { f.ev_wd.value = defaults1.wd; }
   if (f.ev_lat.value == '') { f.ev_lat.value = defaults1.lat; }
   if (f.ev_lon.value == '') { f.ev_lon.value = defaults1.lon; }
   if (f.ev_alt.value == '') { f.ev_alt.value = defaults1.alt; }
   if (f.ev_elev_source.value == '') { setSelectValue(f.ev_elev_source.value,'DB'); }
   if (f.ev_comment.value == '') { f.ev_comment.value = defaults1.comment; }
}

function ChkCode(element)
{
   var f = document.mainform;
   t_s = element.value;

   if (t_s == defaults1.code) return false;

   var key = new RegExp(t_s,'i');

   for (i=0,j=(-1); i<siteinfo.length; i++) { if (siteinfo[i].match(key) != null) { j = i; } }
   if (j < 0) { return false; }

   element.value = t_s.toUpperCase();
   return true;
}

function ChkDate(element)
{
   var f = document.mainform;
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

   if (t_s == defaults1.time.substr(0,4)) { return true; }

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

function ChkWS(element)
{
   t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   if (t_s == defaults1.ws) { return true; }

   t_i = parseFloat(t_s);
   if (t_i < 0) { return false; }
   return true;
}

function ChkWD(element)
{
   t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   if (t_s == defaults1.wd) { return true; }

   t_i = parseFloat(t_s);
   if (t_i < 0 || t_i > 360) { return false; }
   return true;
}

function ChkLatDeg(element)
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

function ChkLatDec(element)
{
   t_s = element.value;

   if (t_s.length < 4) { return false; }

   if (t_s == defaults2.lat) { return true; }

   if ( t_s < -90 || t_s > 90 ) { return false; }

   if ( ! ( t_s.match(/^(-|)[0-9]{1,2}\.[0-9]{1,4}$/) ) ) { return false; }

   return true;
}

function ChkLonDeg(element)
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

function ChkLonDec(element)
{
   t_s = element.value;

   if (t_s.length < 4) { return false; }

   if (t_s == defaults2.lon) { return true; }

   if ( t_s < -180 || t_s > 180 ) { return false; }

   if ( ! ( t_s.match(/^(-|)[0-9]{1,3}\.[0-9]{1,4}$/) ) ) { return false; }

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
   var f = document.mainform;
   if (!(ChkCode(f.ev_code))) { f.ev_code.focus(); alert('Improper Code'); return false; }
   if (!(ChkDate(f.ev_date))) { f.ev_date.focus(); alert('Improper Date'); return false; }
   if (!(ChkTime(f.ev_time))) { f.ev_time.focus(); alert('Improper Time'); return false; }
   if (!(ChkId(f.ev_id))) { f.ev_id.focus(); alert('Improper Id'); return false; }
   if (!(ChkMethod(f.ev_meth))) { f.ev_meth.focus(); alert('Improper Method'); return false; }
   if (!(ChkWS(f.ev_ws))) { f.ev_ws.focus(); alert('Improper Wind Speed'); return false; }
   if (!(ChkWD(f.ev_wd))) { f.ev_wd.focus(); alert('Improper Wind Direction'); return false; }
   var lat_units = getRadioValue(f.ev_lat_units);
   if ( lat_units == 'deg' )
   {
      if (!(ChkLatDeg(f.ev_lat)))
      { f.ev_lat.focus(); alert('Improper Latitude'); return false; }
   }
   else
   {
      if (!(ChkLatDec(f.ev_lat)))
      { f.ev_lat.focus(); alert('Improper Latitude'); return false; }
   }
   var lon_units = getRadioValue(f.ev_lon_units);
   if ( lon_units == 'deg' )
   {
      if (!(ChkLonDeg(f.ev_lon)))
      { f.ev_lon.focus(); alert('Improper Longitude'); return false; }
   }
   else
   {
      if (!(ChkLonDec(f.ev_lon)))
      { f.ev_lon.focus(); alert('Improper Longitude'); return false; }
   }
   if (!(ChkReal(f.ev_alt.value))) { f.ev_alt.focus(); alert('Improper Altitude'); return false; }
   return true;
}

function ChkPath()
{
   var f = document.mainform;
   f.path.value = '';

   for (i=0,j=1; i<npaths; i++,j++)
   {
      key = new RegExp('path'+j,'i');
      for (ii=0; ii<f.elements.length; ii++)
      {
         if (f.elements[ii].name.match(key) == null) continue;
         if (f.elements[ii][0].selected == true) continue;
         field = f.elements[ii][f.elements[ii].selectedIndex].value.split("\|");
         f.path.value += (f.path.value == '') ? field[0] : "," + field[0]
      }
   }
   //
   // Are there identical path entries?
   //
   arr = f.path.value.split(",");
   arr.sort();
   for (i=1,j=0,dup=0; i<arr.length; i++,j++) { if (arr[i] == arr[j]) dup++; }
   if (dup) { alert('Repeated Analytical Systems Not Allowed'); return false; }

   return true;
}

function ConvertALT()
{
   var f = document.mainform;
   conv = f.alt_conv[f.alt_conv.selectedIndex].value;
   f.alt_conv[0].selected = true;

   if (f.ev_alt.value == '') { alert('No Altitude Entered'); f.ev_alt.focus(); return; }

   switch(conv)
        {
   case 'ft':
      f.ev_alt.value *= 0.3048;
      break;
   case 'km':
      f.ev_alt.value *= 1000.0;
      break;
   case 'miles':
      f.ev_alt.value *= 1609.344;
      break;
   default:
   }
}

function ConvertLAT()
{
   var f = document.mainform;
   conv = f.lat_conv[f.lat_conv.selectedIndex].value;
   f.lat_conv[0].selected = true;

   if (f.ev_lat.value == '') { alert('No Latitude Entered'); f.ev_lat.focus(); return; }

   switch(conv)
        {
   case 'decimal':
      f.ev_lat.value = Dec2Deg(f.ev_lat.value,'lat');
      break;
   default:
   }
}

function ConvertLON()
{
   var f = document.mainform;
   conv = f.lon_conv[f.lon_conv.selectedIndex].value;
   f.lon_conv[0].selected = true;

   if (f.ev_lon.value == '') { alert('No Longitude Entered'); f.ev_lon.focus(); return; }

   switch(conv)
        {
   case 'decimal':
      f.ev_lon.value = Dec2Deg(f.ev_lon.value,'lon');
      break;
   default:
   }
}

function ConvertWD()
{
   var f = document.mainform;
   t_s = f.ev_wd.value.toUpperCase();
   arr1 = new Array('NNE','NE','ENE','E','ESE','SE','SSE','S',
                    'SSW','SW','WSW','W','WNW','NW','NNW','N');
   arr2 = new Array(  23,  45,   68, 90,  113, 135,  158, 180, 
                     203, 225,  248, 270, 293, 315,  338, 360);
   f.wd_conv[0].selected = true;

   if (f.ev_wd.value == '') { alert('No Wind Direction Entered'); f.ev_wd.focus(); return; }

   for (i=0; i<arr1.length; i++) { if (t_s == arr1[i]) break; }
   if (i<arr1.length) { f.ev_wd.value = arr2[i] };
}

function ConvertDT()
{
   var f = document.mainform;
   conv = f.time_conv[f.time_conv.selectedIndex].value;
   f.time_conv[0].selected = true;

   if (f.ev_date.value == '') { alert('No Date Entered'); f.ev_date.focus(); return; }
   if (!(ChkTime(f.ev_time))) { alert('Improper Time'); f.ev_time.focus(); return; }

   t_s = f.ev_time.value;
   d_s = f.ev_date.value;


   lst2utc = parseFloat(f.lst2utc.value);

   switch(conv)
        {
   case 'lst':
      utc = parseFloat(t_s)+(100*lst2utc);
      break;
   case 'ldt':
      utc = parseFloat(t_s)+((100*lst2utc)-100);
      break;
   case 'julian':
      err = "Expecting 2004104 Julian Format";
      if (!(ChkReal(d_s))) { alert(err); break; }
      if (d_s.length != 7) { alert(err); break; }
      f.ev_date.value = Julian2Date(d_s);
      return;
   }
   if (!(ChkDate(f.ev_date))) { alert('Improper Date'); f.ev_date.focus(); return; }
   d_s = f.ev_date.value;

   if (utc < 0)
   {
      utc += 2400;
      julian = Date2Julian(f.ev_date.value,-1);
      f.ev_date.value = Julian2Date(julian);
   }
   if (utc > 2359)
   {
      utc -= 2400;
      julian = Date2Julian(f.ev_date.value,+1);
      f.ev_date.value = Julian2Date(julian);
   }
   for (i=utc.length,z=''; i<4; i++) { z = z.concat('0'); }
   f.ev_time.value = z + utc;
}

function ConvertWS()
{
   var f = document.mainform;
   conv = f.ws_conv[f.ws_conv.selectedIndex].value;
   f.ws_conv[0].selected = true;

   if (f.ev_ws.value == '') { alert('No Wind Speed Entered'); f.ev_ws.focus(); return; }

   switch(conv)
        {
   case 'knots':
      f.ev_ws.value *= 0.51444;
      break;
   case 'mph':
      f.ev_ws.value *= 0.44704;
      break;
   case 'kph':
      f.ev_ws.value *= 0.27778;
   break;
   default:
   }
}

function Date2DBFormat(d)
{
   month = new Array( '', 'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC');

   dy = d.substr(0,2);
   yr = d.substr(5,4);
   key = new RegExp(d.substr(2,3),'i');

   for (i=0; i<month.length; i++)
   { if ((r=month[i].match(key)) != null ) break; }
   mo = (i<10) ? '0'+i : i;
   return yr + '-' + mo + '-' + dy;
}

function Time2DBFormat(t)
{
   hr = t.substr(0,2);
   mn = t.substr(2,2);
   return hr + ':' + mn + ':00';
}

function ProjListCB(projinfo)
{
   //
   // Post the project list
   //
   tmp = projinfo.value.split(/\|/);
                                                                                          
   //f.fm_method.value = tmp[2];
   //intake_ht = parseFloat(tmp[3]);
   //if ( intake_ht < -9999 )
   //{ f.fm_alt.value = parseFloat(tmp[3]); }
   //else { f.fm_alt.value = parseFloat(tmp[3]) + parseFloat(tmp[4]); }
   
   if ( tmp[0] == 1 )
   { setSelectValue(f.fm_elev_source, 'DB'); }
   else
   { setSelectValue(f.fm_elev_source, 'DEM'); }

   PostDefPath(tmp[5]);
}

function PostDefPath(path)
{
   var f = document.mainform;
   field = path.split(",");
   var i,j;
   //
   // For all paths, identify 'path##' select
   // elements and reset to default (----) path
   //
   for (i=0,j=1; i<npaths; i++,j++)
   {
      key = new RegExp('path'+j,'i');
      for (ii=0; ii<f.elements.length; ii++)
      { if (f.elements[ii].name == ("path" + j)) f.elements[ii][0].selected = true; }
   }
   //
   // Set paths for selected site
   //
   for (i=0,j=1; i<field.length; i++,j++)
   {
      if (field[i] == '') continue;
                                                                                          
      key = new RegExp('path'+j,'i');
      for (ii=0; ii<f.elements.length; ii++)
      {
         if (f.elements[ii].name != ("path" + j)) continue;
         f.elements[ii][field[i]].selected = true;
      }
   }
}
