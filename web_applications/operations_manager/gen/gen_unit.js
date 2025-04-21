function ListSelectCB(list)
{
   var f = document.mainform;

   //
   // If the user selects from the unit list, then clear the selected
   //    component value and store the information server side
   //
   if ( list.name == 'unitlist' )
   {
      f.id.value = f.unitlist[f.unitlist.selectedIndex].value;
   }

   f.submit();
}

function SearchCB()
{
   f = document.mainform;
   var c = f.search4id.value.toUpperCase();

   if (c == '') { return; }

   f.id.value = '';

   for ( i=0; i<f.unitlist.length; i++)
   {
      if ( f.unitlist[i].value == c )
      {
         f.id.value = c;
         break;
      }
   }

   if ( f.id.value == '' ) { alert(c+" not found in DB."); }

   f.submit();
}

function BackCB()
{
   //
   // If the user clicks on the Back button
   //
   var f = document.mainform;

   if ( f.id.value != '' )
   {
      f.id.value = '';
      f.task.value = '';
      f.unitinfo.value = '';
      f.unitlist.selectedIndex = -1;

      f.submit();
   }
   else
   {
      document.location = omurl+'index2.php?invtype='+invtype;
   }
}

function ClearCB()
{
   //
   // Clears the form
   //
   var f = document.mainform;

   key = new RegExp("data~",'i');
   //alert(key);
   for (ii=0,jj=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;

      f.elements[ii].value = '';
      jj++;
   }
}

function UpdateCB()
{
   var f = document.mainform;

   if (SaveData())
   {
      f.task.value = 'update';
      f.submit();
   }
}

function SaveData()
{
   //
   // Saves the data server side so that we can access it after the page submits
   //
   var f = document.mainform;

   f.id.value = f.unitlist[f.unitlist.selectedIndex].value;

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
                                                                                          
      tmp = f.elements[ii].name.split(/~/);

      z = tmp[1] + "~" + f.elements[ii].value;
      a += (jj == 0) ? z : "|" + z;
      jj++;
   }

   f.unitinfo.value = a;
   return 1;
}

function SetBackground(element,state)
{
	color = (state) ? 'paleturquoise' : 'white';
	element.style.backgroundColor=color;
}

function ChkTime(date)
{
   var d = new Date();
   var f = document.mainform;
   var curr_day = d.getDate();
   var curr_month = d.getMonth();
   var curr_year = d.getFullYear();

   a = '';
   fdate = '0000-00-00';
   key = new RegExp("psu_inv:date_use",'i');
   for (ii=0,jj=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;

      fdate = f.elements[ii].value;
   }

   if ( fdate == '0000-00-00' )
   {
      return true;
   }
   //
   // Check to make sure that the date is 10 characters and also only contains
   // numbers and dashes
   //
   rexp = /[^0-9\-]/gi;
   // alert(info[0].search(rexp));
   if ( fdate.search(rexp) > 0 || fdate.length < 10 )
   {
      alert("Invalid characters in and/or length of Date");
      return false;
   }
                                                                                          
   var mon_days = new Array("31","29","31","30","31","30","31","31","30","31","30","31");
   datefield = fdate.split("-");
   year = parseInt(datefield[0],10);
   month = parseInt(datefield[1],10);
   day = parseInt(datefield[2],10);
   if ( year < 1950 || year > curr_year )
   {
      alert("Invalid Year in Date");
      return false;
   }
   if ( month < 1 || month > 12 )
   {
      alert("Invalid Month in Date");
      return false;
   }
   if ( day < 1 || day > mon_days[month-1] )
   {
      alert("Invalid Day in Date");
      return false;
   }
                                                                                          
   return true;
}

