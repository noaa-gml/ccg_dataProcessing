var summaryinfoaarr = new Array();
var sites;
var npaths;
var flags = new Array();
var nsamples;

function ChkOptionCB()
{
   var f = document.mainform;
   for (i = 0; i < f.radio.length; i++) { if (f.radio[i].checked) break;};

   if (i == f.radio.length) { alert('Select an option.'); return; }

   if (f.radio[i].value == 'discard') { DiscardCB() }
   if (f.radio[i].value == 'bypass') { ByPassCB() }
   if (f.radio[i].value == 'read') { ReadCB() }
}

function ReadCB()
{
   var f = document.mainform;
   z = 'Are you sure?\n';
   z = z + 'This action will import a user-supplied history file.\n';
   if (confirm(z)) { f.task.value = 'read'; f.submit(); }
}

function ByPassCB()
{
   var f = document.mainform;
   z = 'Are you sure?\n';
   z = z + 'This action will CHECK IN unit without downloading the history.\n';
   if (confirm(z)) { f.task.value = 'bypass'; f.submit(); }
}

function ByPassHelpCB()
{
   var tstr;

   tstr = "Option 1: Read user-supplied HISTORY file\n";
   tstr = tstr + "Use when unable to download history file. User must\n";
   tstr = tstr + "prepare a 3.06+ formatted history file and save in \n";
   tstr = tstr + "/ccg/tmp/temp.his.\n\n";
   tstr = tstr + "Also, a datalog file may be included by saving it as\n";
   tstr = tstr + "/ccg/tmp/temp.dat.\n\n\n";

   tstr = tstr + "Option 2: CHECK IN (no download)\n";
   tstr = tstr + "Use when PFP has already been successfully downloaded\n";
   tstr = tstr + "but was checked out prior to being analyzed.  This option\n";
   tstr = tstr + "uses event numbers created during the 1st check in. No\n";
   tstr = tstr + "new event numbers will be created.\n\n\n";

   tstr = tstr + "Option 3: CHECK IN (no download) AND return to PREP\n";
   tstr = tstr + "Use when PFP will not be analyzed.\n";

   alert(tstr);
}

function StatusNumHelp()
{
   var tstr;

   tstr = "Sample status number\n\n";
   tstr = tstr + "0 - Filling failed\n";
   tstr = tstr + "1 - Filling passed, prefill mode off\n";
   tstr = tstr + "2 - Filling passed, prefill passed\n";
   tstr = tstr + "3 - Filling passed, prefill failed\n";

   alert(tstr);
}


function DownloadCB()
{
   var f = document.mainform;
   if (confirm('Are you sure?'))
   {
      f.serialport.value = f.sp[f.sp.selectedIndex].value;
      f.task.value = 'download';
      MessageAlert('show');
      f.submit();
   }
}

function Download2CB()
{
   var f = document.mainform;
   if (confirm('Are you sure?'))
   {
      f.serialport.value = f.sp2[f.sp2.selectedIndex].value;
      f.task.value = 'download_noflaghis';
      MessageAlert('show');
      f.submit();
   }
}

function DiscardCB()
{
   var f = document.mainform;
   if (confirm('Are you sure?\nThis action will return unit to PREP.'))
   { f.task.value='discard'; f.submit(); }
}

function AcceptCB(button)
{
   button.disabled = true;
   var f = document.mainform;

   if ( ChkEntries() )
   {
      if (confirm('Are you sure?'))
      { f.task.value='accept'; f.submit(); }
   }
   button.disabled = false;
}

function AcceptHistoryCB()
{
   var f = document.mainform;

   m = "Are you sure?  This action will save changes\n";
   m = m + "made to history file and reconstruct PFP summary.";
   if (confirm(m))
   {
      f.task.value='accept_history';
      f.submit();
   }
}

function HistoryCB()
{
   alert("Please contact Dan Chao for assistance.");
//   var f = document.mainform;
//   f.task.value='history';
//   f.submit();
}

function EditHistoryCB()
{
   var f = document.mainform;

   f.edithistory.readOnly = false;
   f.edithistory.disabled = false;
}


function EditCB()
{
   var f = document.mainform;
   var key = new RegExp('his_','i');

   //
   // When the user clicks Edit, only allow them to edit the
   //    code and comment field
   //
   var codekey = new RegExp('_code','i');
   var methodkey = new RegExp('_me','i');
   var commentkey = new RegExp('_comment','i');

   for (var i=0; i<f.elements.length; i++)
   {
      if (f.elements[i].name.match(key) == null) continue;

      if ( f.elements[i].name.match(codekey) == null && 
           f.elements[i].name.match(methodkey) == null &&
           f.elements[i].name.match(commentkey) == null)
         continue;

      f.elements[i].disabled = false;
   }
}

function CancelCB()
{
   document.location = 'pfp_checkin.php';
}

function SetPlanCB(plan)
{
   var f = document.mainform;

   f.task.value = 'read';
   f.plan.value = plan;

   f.submit();
}

function ClearPathsCB()
{
   var f = document.mainform;

   var key = new RegExp('path','i');

   var i, j;

   for (i=0; i<f.elements.length; i++)
   {
      if (f.elements[i].name.match(key) == null) continue;

      f.elements[i].selectedIndex = 0;
   }
}

function SetDefaultsCB()
{
   var f = document.mainform;
   var i,ele,row;

   for (i=0,row=1; i<nsamples; i++,row++)
   {
      row = (row < 10) ? '0'+row : row;

      ele = 'his_date'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.date;

      ele = 'his_time'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.time;

      ele = 'his_me'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.meth;

      ele = 'his_lat'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.lat;

      ele = 'his_lon'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.lon;

      ele = 'his_alt'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.alt;

      ele = 'his_temp'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.temp;

      ele = 'his_press'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.press;

      ele = 'his_rh'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.rh;

      ele = 'his_comment'+row;
      if (f.elements[ele].value == '')  f.elements[ele].value = defaults3.comment;
   }
}

function ChkCode(element)
{
   var f = document.mainform;
   t_s = element.value;
   var key = new RegExp(t_s,'i');
   if (sites.match(key) == null) { return false; }
   return true;
}

function ChkDate(element)
{
   var f = document.mainform;
   t_s = element.value;

   if (t_s == defaults3.date) { return true; }

   tmp = t_s.split("-");
   yr = tmp[0]; mo = tmp[1]; dy = tmp[2];

   if (yr.length != 4) { return false; }

   if (mo.length < 2) {mo = '0'+mo; }
   if (dy.length < 2) {dy = '0'+dy; }

   t_s = yr+'-' + mo+'-'+dy;

   element.value = t_s;

   if (!(ChkReal(yr))) { return false; }
   if (!(ChkReal(mo))) { return false; }
   if (!(ChkReal(dy))) { return false; }

   dy = parseFloat(dy);
   if (dy < 1 || dy > 31) { return false; }
   mo = parseFloat(mo);
   if (mo < 1 || mo > 12) { return false; }
   yr = parseFloat(yr);
   if (yr < 0) { return false; }
   //
   // Future date?
   //
   dec = Date2Dec(yr,mo,dy,12,0);
   now = new Date();
   yr = now.getFullYear();
   mo = now.getMonth();
   dy = now.getDate();
   today = Date2Dec(yr,mo+1,dy,12,0);
   if (dec > today) { return false; }
   return true;
}

function ChkTime(element)
{
   t_s = element.value;

   if (parseFloat(t_s) == parseFloat(defaults3.time)) { return true; }

   tmp= t_s.split(":");
   hr = tmp[0]; mn = tmp[1]; sc = tmp[2];

   if (hr.length < 2) {hr = '0'+hr; }
   if (mn.length < 2) {mn = '0'+mn; }
   if (sc.length < 2) {sc = '0'+sc; }

   t_s = hr+':'+mn+':'+sc;

   element.value = t_s;

   if (!(ChkReal(hr))) { return false; }
   if (!(ChkReal(mn))) { return false; }
   if (!(ChkReal(sc))) { return false; }
   //
   //valid time?
   //
   hr = parseFloat(hr);
   mn = parseFloat(mn);
   sc = parseFloat(sc);

   if (hr > 23 || mn > 59 || sc > 59) { return false; }
   return true;
}

function ChkMethod(element)
{
   t_s = element.value;

   if (t_s == '?') { return false; }
   return true;
}

function ChkPress(element)
{
   var t_s = element.value;

   if (parseFloat(t_s) == parseFloat(defaults3.press)) { return true; }

   if (!(ChkReal(t_s))) { return false; }

   if (parseFloat(t_s) < 0) { return false; }
   return true;
}

function ChkTemp(element)
{
   var t_s = element.value;

   if (parseFloat(t_s) == parseFloat(defaults3.temp)) { return true; }

   if (!(ChkReal(t_s))) { return false; }

   return true;
}

function ChkRH(element)
{
   var t_s = element.value;
   //
   // -1 because default RH for version 2 is -99.0
   // and -99.9 version 3
   //
   if (parseFloat(t_s) <= parseFloat(defaults3.rh)) { return true; }

   if (!(ChkReal(t_s))) { return false; }

   //jwm 5/17. Not sure of the details, but some pfps have legitimate (just)  below zero readings.  Changed from <0 to <-1  
   if (parseFloat(t_s) < -1) { return false; }
   return true;
}

function ChkLat(element)
{
   var t_s = element.value;

   if (parseFloat(t_s) <= parseFloat(defaults3.lat)) { return true; }

   if (!(ChkReal(t_s))) { return false; }

   //Removed this check per Pat request as it prevents pfp from being downloaded. 11/17
   //They will manuall check and correct as needed.
   //if (parseFloat(t_s) < -90 || parseFloat(t_s) > 90) { return false; }
   return true;
}

function ChkLon(element)
{
   var t_s = element.value;

   if (parseFloat(t_s) <= parseFloat(defaults3.lon)) { return true; }

   if (!(ChkReal(t_s))) { return false; }

   //Removed this check per Pat request as it prevents pfp from being downloaded. 11/17
   //They will manuall check and correct as needed.
   //if (parseFloat(t_s) < -180 || parseFloat(t_s) > 180) { return false; }
   return true;
}

function ChkAlt(element)
{
   var t_s = element.value;

   if (parseFloat(t_s) <= parseFloat(defaults3.alt)) { return true; }

   if (!(ChkReal(t_s))) { return false; }

   return true;
}

function ChkAltSource(element)
{
   var t_s = element.value;

   if ( t_s == 'na' ||
        t_s == 'plan' ||
        t_s == 'plan_edit' ||
        t_s == 'gps' ||
        t_s == 'gps_edit' ||
        t_s == 'db' ||
        t_s == 'db_edit' )
   { return true; }

   return false;
}

function ChkStatusNum(element)
{
   t_s = element.value;

   if (!(ChkReal(t_s))) { return false; }
   return true;
}

function ChkReal(item)
{
   //
   //Allowable characters are 0-9,.,-
   //
   if (item == '' || (isNaN(item))) { return false; } else { return true; }
}

function ChkEntries()
{
   var f = document.mainform;
   var i,ii,j,jj,key,p;
   var col,row;
   var str;
   var sum = '';

   summaryinfoaarr = [];
   summaryinfoaarr.length = 0;

   for (i=0,row=1; i<nsamples; i++,row++)
   {
      smpno = 'Sample '+row+':  ';

      row = (row < 10) ? '0'+row : row;
      //
      // Check analysis path
      // If path is not specified, sample will be ignored
      //
      for (ii=0,col=1,p=''; ii<npaths; ii++,col++)
      {
         col = (col < 10) ? '0'+col : col;
         ele = 'path'+row+col;
         if (f.elements[ele][0].selected == true) continue;
         field = f.elements[ele][f.elements[ele].selectedIndex].value.split("\|");
         p += (p == '') ? field[0] : "," + field[0]
      }

      if (p == '') continue;

      len = summaryinfoaarr.length;
      summaryinfoaarr[len] = [];

      ele = 'his_code'+row;
      if (!(ChkCode(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Code'); return false; }
      summaryinfoaarr[len]['code'] = f.elements[ele].value;

      ele = 'his_date'+row;
      if (!(ChkDate(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Date'); return false; }
      summaryinfoaarr[len]['date'] = f.elements[ele].value;

      ele = 'his_time'+row;
      if (!(ChkTime(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Time'); return false; }
      summaryinfoaarr[len]['time'] = f.elements[ele].value;

      ele = 'his_id'+row;
      summaryinfoaarr[len]['id'] = f.elements[ele].value;

      ele = 'his_me'+row;
      if (!(ChkMethod(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Method'); return false; }
      summaryinfoaarr[len]['me'] = f.elements[ele].value;

      ele = 'his_lat'+row;
      if (!(ChkLat(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Latitude'); return false; }
      summaryinfoaarr[len]['lat'] = f.elements[ele].value;

      ele = 'his_lon'+row;
      if (!(ChkLon(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Longitude'); return false; }
      summaryinfoaarr[len]['lon'] = f.elements[ele].value;

      ele = 'his_alt'+row;
      if (!(ChkAlt(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Altitude'); return false; }
      summaryinfoaarr[len]['alt'] = f.elements[ele].value;

      ele = 'his_alt_source'+row;
      if (!(ChkAltSource(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Altitude Source'); return false; }
      summaryinfoaarr[len]['alt_source'] = f.elements[ele].value;

      ele = 'his_temp'+row;
      if (!(ChkTemp(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Temperature'); return false; }
      summaryinfoaarr[len]['temp'] = f.elements[ele].value;

      ele = 'his_press'+row;
      if (!(ChkPress(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Pressure'); return false; }
      summaryinfoaarr[len]['press'] = f.elements[ele].value;

      ele = 'his_rh'+row;
      if (!(ChkRH(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Relative Humidity'); return false; }
      summaryinfoaarr[len]['rh'] = f.elements[ele].value;

      ele = 'his_comment'+row;
      summaryinfoaarr[len]['comment'] = URLEncode(f.elements[ele].value);

      ele = 'his_status_num'+row;
      if (!(ChkStatusNum(f.elements[ele])))
      { f.elements[ele].focus(); alert(smpno+'Improper Status Num'); return false; }
      summaryinfoaarr[len]['status_num'] = f.elements[ele].value;

      //
      // Are there identical path entries?
      //
      arr = p.split(",");
      arr.sort();
      for (ii=1,jj=0,dup=0; ii<arr.length; ii++,jj++) { if (arr[ii] == arr[jj]) dup++; }
      if (dup) { alert(smpno+'Repeated Analytical Systems Not Allowed'); return false; }
      summaryinfoaarr[len]['path'] = p;
   }

   //
   // Prepare summary information
   //
   sum = php_serialize(summaryinfoaarr);
   if (summaryinfoaarr.length > 0)
   {
      f.summaryinfostr.value = sum;
      return true;
   }
   return false;
}

function Date2Dec(yr,mo,dy,hr,mn)
{
   var i,d,leap;

   dim_noleap = new Array(0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
   dim_leap = new Array(0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

   if ((yr%4==0 && yr%100 != 0) || (yr%400 == 0)) 
   {
      dim=dim_leap;
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

function UpdateMethod(element)
{
   // If one method is updated then update all the other methods too

   var f = document.mainform;
   var key = new RegExp('his_','i');

   var methodkey = new RegExp('_me','i');

   for (var i=0; i<f.elements.length; i++)
   {
      if (f.elements[i].name.match(key) == null) continue;

      if ( f.elements[i].name.match(methodkey) == null ) continue;

      f.elements[i].value = element.value;
   }
}
