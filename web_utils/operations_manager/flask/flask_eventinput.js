var flask_notes = new Array();
var meas_notes = new Array();
var sitedesc = new Array();
var npaths;

function FlaskSelection(idobj)
{
   var f = document.mainform;
   var tstr = '';
   var oflask_notes = top.document.getElementById('flask_notes');
   var oselectedflaskcnt = top.document.getElementById('selectedflaskcnt');
   var i;
   var availablelistindex;
   var selectedlistindex;

   //
   // Cannot assume selectedIndex of availablelist has been set
   //
   for (var i=0,availablelistindex=(-1); i<f.availablelist.length; i++)
   {
      if (f.availablelist[i].text == idobj.text) {availablelistindex = i;}
   }
   if (availablelistindex < 0)
   { alert(idobj.text+' not found in available flask list.');return; }

   var id = idobj.text.replace(/\*/,"");
   var field1 = id.split(/\s+/);
   var value1 = idobj.value.split(/\|/);
   var key = new RegExp(id,'i');
   for (var i=0,selectedlistindex=(-1); i<f.selectedlist.length; i++)
   {
      var field2 = f.selectedlist[i].text.split(/\s+/);
      if (field1[0] != field2[0])
      {
         alert("You cannot select samples from different locations");
         return;
      }

      if (f.selectedlist[i].text.search(key) != (-1)) {selectedlistindex = i;}
   }

   //
   // Check the project
   //
   var value2;
   if ( f.selectedlist.length > 0 )
   { value2 = f.selectedlist[0].value.split(/\|/); }
   else { value2 = value1; }

   //
   // If we are adding to the selectedlist and the project numbers do not match
   //    then alert the user
   //
   if ( selectedlistindex < 0 && value1[13] != value2[13] )
   {
      tmp = confirm(id+" has a conflicting project. Continue?");
      if ( ! ( tmp ) ) { return; }
   }

   if (selectedlistindex >= 0)
   {
      f.selectedlist[selectedlistindex] = null;
      f.availablelist[availablelistindex].text = id;
   }
   else
   {
      f.selectedlist[f.selectedlist.length] = new Option(id,idobj.value,false,false);
      f.availablelist[availablelistindex].text = id+'*';
   }

   //
   // If the selectedlist length is 1 and the user added to the selected list,
   //    set the project list
   //
   if ( f.selectedlist.length == 1 && selectedlistindex < 0 )
   { PostProjList(field1[0],value1[13]); }
   //
   // If the selectedlist length is 0 and the user removed from the selected list,
   //    clear the project list
   //
   if ( f.selectedlist.length == 0 && selectedlistindex >= 0 )
   { f.projlist.length = 0; }

   //
   // Are there flask comments?
   //
   if (flask_notes[availablelistindex] != "NULL" && flask_notes[availablelistindex] != "")
   { 
      var field = id.split(/\s+/)
      oflask_notes.innerHTML = '** FLASK **<BR>['+field[1]+'] '+flask_notes[availablelistindex];
   }
   else { oflask_notes.innerHTML = ' '; }

   f.availablelist[availablelistindex].selected = 1;

   oselectedflaskcnt.innerHTML = f.selectedlist.length;

   for (var i=0; i<f.selectedlist.length; i++)
   {
      tstr += (i == 0) ? f.selectedlist[i].value : "~" + f.selectedlist[i].value
   }
   f.selectedflasks.value = tstr;
   //
   // Post Default Analysis Path
   // Post Default Method and Position Information
   //   
   var path = '';
   if (f.selectedlist.length)
   {
      field = f.selectedlist[0].value.split("\|");
      path = field[4];
      f.fm_method.value = field[10];

      if ( field[6] < -90 || field[7] < -900 )
      {
         //
         // Moving site -> Units in degrees
         //
         f.fm_lat.value = (field[6] < -90) ? defaults1.lat : Dec2Deg(field[6],'lat');
         f.fm_lon.value = (field[7] < -900) ? defaults1.lon : Dec2Deg(field[7],'lon');
         setRadioValue(f.fm_lat_units, 'deg');
         setRadioValue(f.fm_lon_units, 'deg');
      }
      else
      {
         //
         // Stationary site -> Units in decimal
         //
         f.fm_lat.value = (field[6] < -90) ? defaults2.lat : field[6];
         f.fm_lon.value = (field[7] < -900) ? defaults2.lon : field[7];
         setRadioValue(f.fm_lat_units, 'dec');
         setRadioValue(f.fm_lon_units, 'dec');
      }

      // elevation
      var tmp1 = parseFloat(field[8]);
      // intake_ht
      var tmp2 = parseFloat(field[12]);
      if ( tmp1 < -9999 || tmp2 < -9999 )
      { f.fm_alt.value = parseFloat(field[8]); }
      else { f.fm_alt.value = parseFloat(field[8]) + parseFloat(field[12]); }
   }
   else
   {
      f.fm_method.value = '';
      f.fm_lat.value = '';
      f.fm_lon.value = '';
      f.fm_alt.value = '';
   }
   PostDefPath(path);
}

function PostDefPath(path)
{
   var f = document.mainform;
   var field = path.split(",");
   var i,j,ii;
   //
   // For all paths, identify 'path##' select
   // elements and reset to default (----) path
   //
   for (i=0,j=1; i<npaths; i++,j++)
   {
      var key = new RegExp('path'+j,'i');
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

function PostProjList(code, proj_num)
{
   var tmp;
   var selected;
   var f = document.mainform;
   //alert(code);
   for ( i=0; i<sitedesc[code].length; i++ )
   {
      tmp = sitedesc[code][i].split(/\|/);
      if ( proj_num == tmp[0] ) { selected = true; }
      else { selected = false; }
      f.projlist[f.projlist.length] = new Option(tmp[1],sitedesc[code][i],false,selected);
   }

   // Fire the onChange() for projlist so we can set the elevation source also
   f.projlist.onchange();
}

function AvailableListCB()
{
   var f = document.mainform;
   var i = f.availablelist.selectedIndex;
   var omeas_notes = top.document.getElementById('meas_notes');

   FlaskSelection(f.availablelist[i]);
   //
   // Are there flask comments?
   //
   if (meas_notes[i] != "NULL" && meas_notes[i] != "")
   {
      omeas_notes.innerHTML = "** MEASUREMENT **<BR>"+meas_notes[i];
   } else { omeas_notes.innerHTML = ' '; }
}

function AcceptCB()
{
   var f = document.mainform;

   if (!(f.selectedflasks.value)) { return false };

   if ( !ChkProj() ) { return false; }

   if (confirm('Are you sure?')) { if (ChkEvent() && ChkPath()) { return true; } }
   return false;
}

function DiscardCB()
{
   var f = document.mainform;

   if (!(f.selectedflasks.value)) { return false };

   if (confirm('Are you sure?\nThis action will return selected samples to Flask Prep Room.'))
   { return true; } else { return false; }
}

function CancelCB()
{
   var f = document.mainform;
   if (f.selectedflasks.value)
   { 
      f.selectedflasks.value='';
      f.submit();
   }
   else { document.location = 'flask_blank.php';}
}

function ClearCB()
{
   var f = document.mainform;
   f.fm_date.value = '';
   f.fm_time.value = '';
   f.fm_method.value = '';
   f.fm_ws.value = '';
   f.fm_wd.value = '';
   f.fm_lat.value = '';
   f.fm_lon.value = '';
   f.fm_alt.value = '';
   setSelectValue(f.fm_elev_source, 'DB');
   f.fm_comment.value = '';
}

function RecallCB()
{
   var f = document.mainform;
   if (f.fm_date.value == '') { f.fm_date.value = f.last_date.value; }
   if (f.fm_time.value == '') { f.fm_time.value = f.last_time.value; }
   if (f.fm_method.value == '') { f.fm_method.value = f.last_method.value; }
   if (f.fm_ws.value == '') { f.fm_ws.value = f.last_ws.value; }
   if (f.fm_wd.value == '') { f.fm_wd.value = f.last_wd.value; }
   if (f.fm_lat.value == '') { f.fm_lat.value = f.last_lat.value; }
   if (f.fm_lon.value == '') { f.fm_lon.value = f.last_lon.value; }
   if (f.fm_alt.value == '') { f.fm_alt.value = f.last_alt.value; }
   if (f.fm_elev_source.value == '') { setSelectValue(f.fm_elev_source, f.last_elev_source.value); }
   if (f.fm_comment.value == '') { f.fm_comment.value = f.last_comment.value; }
}

function SetDefaultsCB()
{
   var f = document.mainform;
   if (f.fm_date.value == '') { f.fm_date.value = defaults1.date; }
   if (f.fm_time.value == '') { f.fm_time.value = defaults1.time; }
   if (f.fm_method.value == '') { f.fm_method.value = defaults1.meth; }
   if (f.fm_ws.value == '') { f.fm_ws.value = defaults1.ws; }
   if (f.fm_wd.value == '') { f.fm_wd.value = defaults1.wd; }
   if (f.fm_lat.value == '') { f.fm_lat.value = defaults1.lat; }
   if (f.fm_lon.value == '') { f.fm_lon.value = defaults1.lon; }
   if (f.fm_alt.value == '') { f.fm_alt.value = defaults1.alt; }
   if (f.fm_comment.value == '') { f.fm_comment.value = defaults1.comment; }
}

function ChkDate(element)
{
   var f = document.mainform;
   var month = new Array('jan','feb','mar','apr','may','jun',
                     'jul','aug','sep','oct','nov','dec');
   var dim =   new Array(  31,   29,   31,   30,   31,   30,
                       31,   31,   30,   31,   30,   31);
   var t_s = element.value;

   if (t_s.length != 8 && t_s.length != 9) { return false; }
   if (t_s.length == 8) { t_s = '0'+t_s; }

   var date_patt = /^[0-9]{2}[A-Za-z]{3}[0-9]{4}$/;
   if (! date_patt.test(t_s)) { return false; }

   var dy = parseFloat(t_s.substr(0,2));
   if (dy < 1 || dy > 31) { return false; }

   var mo = t_s.substr(2,3);
   var key = new RegExp(mo,'i');

   var imo, r;
   for (imo=0; imo<month.length; imo++) { if ((r=month[imo].match(key)) != null ) { break; } }
   if (imo == month.length) { return false; }
   if (dy > dim[imo]) { return false; }

   yr = parseInt(t_s.substr(5,4),10);
   if ( yr < 1900 || yr > 9999 ) { return false; }

   //
   // Future date?
   //
   var dec = Date2Dec(yr,imo+1,dy,12,0);
   now = new Date();
   yr = now.getFullYear();
   mo = now.getMonth();
   dy = now.getDate();
   var today = Date2Dec(yr,mo+1,dy,12,0);
   if (dec > today) { return false; }

   element.value = t_s;
   return true;
}

function ChkTime(element)
{
   var t_s = element.value;

   if (!(ChkReal(t_s))) { return false; }

        if (t_s == defaults1.time.substr(0,4)) { return true; }

   var t_i = parseInt(t_s,10);
   if (t_i<0) { return false; }
   //
   // pad with zeros
   //
   var z;
   for (i=t_s.length,z=''; i<4; i++) { z = z.concat('0'); }
   t_s = z + t_s;

   var time_patt = /^[0-9]{4}$/;
   if (! time_patt.test(t_s)) { return false; }

   //
   //valid time?
   //
   var hr = t_s.substr(0,2);
   var mn = t_s.substr(2,2);
   if (hr > 23 || mn > 59) { return false; }
   element.value = t_s;
   return true;
}

function ChkMethod(element)
{
   var t_s = element.value;

   if (t_s == '?') { return false; }

   element.value = t_s.toUpperCase();

   return true;
}

function ChkWS(element)
{
   var t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   if (t_s == defaults1.ws) { return true; }

   t_i = parseFloat(t_s);
   if (t_i < 0) { return false; }
   return true;
}

function ChkWD(element)
{
   var t_s = element.value;
   if (!(ChkReal(t_s))) { return false; }

   if (t_s == defaults1.wd) { return true; }

   t_i = parseFloat(t_s);
   if (t_i < 0 || t_i > 360) { return false; }
   return true;
}

function ChkLatDeg(element)
{
   var t_s = element.value.toUpperCase();

   if (t_s.length < 4) { return false; }

   if (t_s == defaults1.lat) { return true; }

   var tmp = t_s.split(/\s+/);
   if (tmp.length != 2 ) { return false; }
   if (tmp[0] < 0 || tmp[0] > 90) { return false; }

   var h = tmp[1].charAt(tmp[1].length-1);
   if (h != 'S' && h != 'N') { return false; }

   var m = tmp[1].substring(0,tmp[1].length-1);
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
   var t_s = element.value.toUpperCase();

   if (t_s.length < 4) { return false; }

   if (t_s == defaults1.lon) { return true; }

   var tmp = t_s.split(/\s+/);
   if (tmp.length != 2 ) { return false; }
   if (tmp[0] < 0 || tmp[0] > 180) { return false; }

   var h = tmp[1].charAt(tmp[1].length-1);
   if (h != 'W' && h != 'E') { return false; }

   var m = tmp[1].substring(0,tmp[1].length-1);
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

function ChkComment(item)
{
   //
   //Is a comment required?
   //
   var omeas_notes = top.document.getElementById('meas_notes');
   var s = omeas_notes.innerHTML;
   var key = new RegExp("comment field is required",'i');
   if (s.search(key) != (-1) && item == '') { return false; } else { return true; }
}

function ChkEvent()
{
   var f = document.mainform;
   if (!(ChkDate(f.fm_date))) { f.fm_date.focus(); alert('Improper Date'); return false; }
   if (!(ChkTime(f.fm_time))) { f.fm_time.focus(); alert('Improper Time'); return false; }
   if (!(ChkMethod(f.fm_method))) { f.fm_method.focus(); alert('Improper Method'); return false; }
   if (!(ChkWS(f.fm_ws))) { f.fm_ws.focus(); alert('Improper Wind Speed'); return false; }
   if (!(ChkWD(f.fm_wd))) { f.fm_wd.focus(); alert('Improper Wind Direction'); return false; }
   var lat_units = getRadioValue(f.fm_lat_units);
   if ( lat_units == 'deg' )
   {
      if (!(ChkLatDeg(f.fm_lat)))
      { f.fm_lat.focus(); alert('Improper Latitude'); return false; }
   }
   else
   {
      if (!(ChkLatDec(f.fm_lat)))
      { f.fm_lat.focus(); alert('Improper Latitude'); return false; }
   }
   var lon_units = getRadioValue(f.fm_lon_units);
   if ( lon_units == 'deg' )
   {
      if (!(ChkLonDeg(f.fm_lon)))
      { f.fm_lon.focus(); alert('Improper Longitude'); return false; }
   }
   else
   {
      if (!(ChkLonDec(f.fm_lon)))
      { f.fm_lon.focus(); alert('Improper Longitude'); return false; }
   } 
   if (!(ChkReal(f.fm_alt.value))) { f.fm_alt.focus(); alert('Improper Altitude'); return false; }
   if (!(ChkComment(f.fm_comment.value))) { f.fm_comment.focus(); alert('Comment Required'); return false; }
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
   if (f.path.value == '') { alert('Improper Analysis Path'); return false; }
   //
   // Are there identical path entries?
   //
   arr = f.path.value.split(",");
   arr.sort();
   for (i=1,j=0,dup=0; i<arr.length; i++,j++) { if (arr[i] == arr[j]) dup++; }
   if (dup) { alert('Repeated Analytical Systems Not Allowed'); return false; }

   return true;
}

function ChkProj()
{
   var f = document.mainform;
   f.proj_num.value = '';

   if ( f.projlist.length == 0 ) { return false; }

   if ( f.projlist.selectedIndex == -1 ) { return false; }

   i = f.projlist.selectedIndex;
   var tmp = f.projlist[i].value.split(/\|/);

   f.proj_num.value = tmp[0];

   return true; 
}

function ConvertALT()
{
   var f = document.mainform;
   var conv = f.alt_conv[f.alt_conv.selectedIndex].value;
   f.alt_conv[0].selected = true;

   if (f.fm_alt.value == '') { alert('No Altitude Entered'); f.fm_alt.focus(); return; }

   switch(conv)
   {
      case 'ft':
         f.fm_alt.value *= 0.3048;
         break;
      case 'km':
         f.fm_alt.value *= 1000.0;
         break;
      case 'miles':
         f.fm_alt.value *= 1609.344;
         break;
      default:
   }
}

function ConvertLAT()
{
   var f = document.mainform;
   var conv = f.lat_conv[f.lat_conv.selectedIndex].value;
   f.lat_conv[0].selected = true;

   if (f.fm_lat.value == '') { alert('No Latitude Entered'); f.fm_lat.focus(); return; }

   switch(conv)
        {
   case 'decimal':
      f.fm_lat.value = Dec2Deg(f.fm_lat.value,'lat');
      break;
   default:
   }
}

function ConvertLON()
{
   var f = document.mainform;
   var conv = f.lon_conv[f.lon_conv.selectedIndex].value;
   f.lon_conv[0].selected = true;

   if (f.fm_lon.value == '') { alert('No Longitude Entered'); f.fm_lon.focus(); return; }

   switch(conv)
   {
      case 'decimal':
         f.fm_lon.value = Dec2Deg(f.fm_lon.value,'lon');
         break;
      default:
   }
}

function ConvertWD()
{
   var f = document.mainform;
   var t_s = f.fm_wd.value.toUpperCase();
   var arr1 = new Array('NNE','NE','ENE','E','ESE','SE','SSE','S',
                    'SSW','SW','WSW','W','WNW','NW','NNW','N');
   var arr2 = new Array(  23,  45,   68, 90,  113, 135,  158, 180, 
                     203, 225,  248, 270, 293, 315,  338, 360);
   f.wd_conv[0].selected = true;

   if (f.fm_wd.value == '') { alert('No Wind Direction Entered'); f.fm_wd.focus(); return; }

   for (i=0; i<arr1.length; i++) { if (t_s == arr1[i]) break; }
   if (i<arr1.length) { f.fm_wd.value = arr2[i] };
}

function ConvertDT()
{
   var i,z;
   var f = document.mainform;
   var conv = f.time_conv[f.time_conv.selectedIndex].value;
   f.time_conv[0].selected = true;

   if (f.selectedlist.length == 0) { alert('No Flasks Selected'); return; }
   if (f.fm_date.value == '') { alert('No Date Entered'); f.fm_date.focus(); return; }
   if (!(ChkTime(f.fm_time))) { alert('Improper Time'); f.fm_time.focus(); return; }

   var t_s = f.fm_time.value;
   var d_s = f.fm_date.value;

   var field = f.selectedlist[0].value.split("\|");
   var lst2utc = parseFloat(field[9]);

   var utc;
   switch(conv)
   {
      case 'lst':
         utc = parseFloat(t_s)+(100*lst2utc);
         break;
      case 'ldt':
         utc = parseFloat(t_s)+((100*lst2utc)-100);
         break;
      case 'julian':
         var err = "Expecting 2004104 Julian Format";
         if (!(ChkReal(d_s))) { alert(err); break; }
         if (d_s.length != 7) { alert(err); break; }
         f.fm_date.value = Julian2Date(d_s);
         return;
   }
   if (!(ChkDate(f.fm_date))) { alert('Improper Date'); f.fm_date.focus(); return; }
   d_s = f.fm_date.value;

   if (utc < 0)
   {
      utc += 2400;
      julian = Date2Julian(f.fm_date.value,-1);
      f.fm_date.value = Julian2Date(julian);
   }
   if (utc > 2359)
   {
      utc -= 2400;
      julian = Date2Julian(f.fm_date.value,+1);
      f.fm_date.value = Julian2Date(julian);
   }
   for (i=utc.length,z=''; i<4; i++) { z = z.concat('0'); }
   f.fm_time.value = z + utc;
}

function ConvertWS()
{
   var f = document.mainform;
   var conv = f.ws_conv[f.ws_conv.selectedIndex].value;
   f.ws_conv[0].selected = true;

   if (f.fm_ws.value == '') { alert('No Wind Speed Entered'); f.fm_ws.focus(); return; }

   switch(conv)
   {
      case 'knots':
         f.fm_ws.value *= 0.51444;
         break;
      case 'mph':
         f.fm_ws.value *= 0.44704;
         break;
      case 'kph':
         f.fm_ws.value *= 0.27778;
      break;
      default:
   }
}

function ProjListCB(projinfo)
{
   var f = document.mainform;
   //
   // Post the project list
   //
   var tmp = projinfo.value.split(/\|/);

   f.fm_method.value = tmp[2];
   // intake_ht
   tmp1 = parseFloat(tmp[3]);
   // elevation
   tmp2 = parseFloat(tmp[4]);
   if ( tmp1 < -9999 || tmp2 < -9999 )
   { f.fm_alt.value = parseFloat(tmp[4]); }
   else { f.fm_alt.value = parseFloat(tmp[4]) + parseFloat(tmp[3]); }

   if ( tmp[0] == 1 )
   { setSelectValue(f.fm_elev_source, 'DB'); }
   else
   { setSelectValue(f.fm_elev_source, 'DEM'); }


   PostDefPath(tmp[5]);
}

