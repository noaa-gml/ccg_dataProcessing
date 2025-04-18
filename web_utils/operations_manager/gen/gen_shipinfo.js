function UpdateCB()
{
   var f = document.mainform;

   if ( SaveData() )
   { 
      f.submit();
   }

}

function SaveData()
{
   var f = document.mainform;

   a = '';
   key = new RegExp("data~",'i');
   for (ii=0,jj=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      //
      // Disallow use of '~' and '|'
      //
      if (f.elements[ii].value.match(/\~/) != null)
      { f.elements[ii].focus(); alert('Use of \'~\' not allowed'); return; }

      if (f.elements[ii].value.match(/\|/) != null)
      { f.elements[ii].focus(); alert('Use of \'|\' not allowed'); return; }

      nametmp = f.elements[ii].name.split(/~/);

      fields = nametmp[1].split(/:/);

      if ( fields[1] == 'date_inuse' || fields[1] == 'date_outuse' )
      {
         if ( ! ( ChkDate(f.elements[ii]) ) )
         {
            alert("Invalid date");
            f.elements[ii].focus();
            return false;
         }
      }

      z = nametmp[1] + "~" + f.elements[ii].value;
      a += (jj == 0) ? z : "|" + z;
      jj++;
   }

   f.unitinfo.value = a;
   f.task.value = 'update';
   return true;

}

function BackCB()
{
   history.back(-1);
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
   if (yr < 0) { return false; }

   if ( f.date_out.value > t_s ) { return false; }

   if ( f.date_in.value == '0000-00-00' )
   {
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
   }
   else
   {
      if ( f.date_in.value < t_s ) { return false; }
   }


   return true;
}

