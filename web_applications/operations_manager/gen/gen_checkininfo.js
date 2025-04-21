function AcceptCB()
{
   var f = document.mainform;

   if (ChkEvent())
   {
      if ( confirm('Are you sure?'))
      {
         return true;
      }
   }
   return false;
}

function CancelCB()
{
   var f = document.mainform;
   document.location = omurl+'gen/gen_checkin.php?invtype='+f.invtype.value+'&strat_name='+f.strat_name.value+'&strat_abbr='+f.strat_abbr.value;
}

function ChkReal(item)
{
   //
   //Allowable characters are 0-9,.,-
   //
   if (item == '' || (isNaN(item))) { return false; } else { return true; }
}

function ChkDate(element)
{
   var f = document.mainform;
   t_s = element.value;

   if ( t_s == '0000-00-00' ) { return true; }

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

function ChkEvent()
{
   var f = document.mainform;
   if (!(ChkDate(f.fm_dateinuse))) { f.fm_dateinuse.focus(); alert('Improper Date'); return false; }
   if (!(ChkDate(f.fm_dateoutuse))) { f.fm_dateoutuse.focus(); alert('Improper Date'); return false; }
   if ( f.fm_dateinuse.value < f.date_out.value && f.fm_dateinuse.value != '0000-00-00' ) 
   { f.fm_dateinuse.focus(); alert('Invalid Date In Use'); return false; }
   if ( f.fm_dateinuse.value > f.date_in.value && f.fm_dateoutuse.value != '0000-00-00')
   { f.fm_dateoutuse.focus(); alert('Invalid Date Out Use'); return false; }
   if ( f.fm_dateoutuse.value < f.date_out.value && f.fm_dateinuse.value != '0000-00-00' ) 
   { f.fm_dateinuse.focus(); alert('Invalid Date In Use'); return false; }
   if ( f.fm_dateoutuse.value > f.date_in.value && f.fm_dateoutuse.value != '0000-00-00')
   { f.fm_dateoutuse.focus(); alert('Invalid Date Out Use'); return false; }
   return true;
}
