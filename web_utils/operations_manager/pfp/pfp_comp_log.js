function ListSelectCB(list)
{
   f = document.mainform;

   //
   // If the user selects from the unit list, store the unit id and 
   //    reset the selected component
   //
   if ( list.name == 'unitlist' )
   {
      f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.datetime.value = ''
   }

   if ( list.name == 'datelist' )
   {
      f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.datetime.value = f.datelist[f.datelist.selectedIndex].value;
   }

   if ( list.name == 'sitelist' )
   {
      f.sitenum.value = f.sitelist[f.sitelist.selectedIndex].value;
   }
   else
   {
      f.submit();
   }
}

function AddCB()
{
   //
   // Adding comments
   //
   f = document.mainform;
   if ( f.sitenum.value == '' )
   {
      alert('Please select a Site');
      return;
   }

   if (!confirm("Are you sure?")) return;

   SaveData();

   f.task.value = 'add';
   f.submit();
}

function BackCB()
{
   //
   // If the user clicks back, clear all information
   //
   f = document.mainform;

   if (!confirm("Are you sure?")) return;

   f.task.value = '';
   //f.unitid.value = '';
   f.datetime.value = '';
   //f.unitlist.selectedIndex = -1;
   f.datelist.selectedIndex = -1;

   f.submit();
   
}

function ClearCB()
{
   //
   // If the user clicks clear, clear all information
   //
   f = document.mainform;

   if (f.unitid.value == '' && f.datetime.value == '' && f.flaskdate.value == '') return;

   if (!confirm("Are you sure?")) return;
   
   key = new RegExp("comments:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      f.elements[ii].value = '';
   }
                                                                                          
}

function DeleteCB()
{
   //
   // If the user clicks clear, clear all information
   //
   f = document.mainform;
                                                                                          
   if (f.unitid.value == '' && f.datetime.value == '' && f.flaskdate.value == '') return;
                                                                                          
   if (!confirm("Are you sure?")) return;
                                                                                          
   key = new RegExp("comments:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      f.elements[ii].value = '';
   }

   SaveData();
                                                                                          
   f.task.value = 'update';
   f.submit();
}

function UpdateCB()
{
   f = document.mainform;

   //
   // Only comments that are associated with a component and an unit can be updated
   //
   if (f.unitid.value == '' && f.datetime.value == '' && f.flaskdate.value == '') return;
   if ( f.sitenum.value == '' )
   {
      alert('Please select a Site');
      return;
   }

   if (!(ChkTime())) return;

   if (!confirm("Are you sure?")) return;

   SaveData();

   f.task.value = 'update';
   f.submit();
}

function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}

function SaveData()
{
   //
   // Saves the data server side so that we can access it after the page submits
   //
   f = document.mainform;
                                                                                          
   if (f.unitid.value == '' && f.datetime.value == '') return;

   a = '';
   key = new RegExp("comments:",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      //
      // Disallow use of '~' and '|'
      //
      if (f.elements[ii].value.match(/\~/) != null)
      { f.elements[ii].focus(); alert('Use of \'~\' not allowed'); return; }                                                                                           
      if (f.elements[ii].value.match(/\|/) != null)
      { f.elements[ii].focus(); alert('Use of \'|\' not allowed'); return; }
                                                                                          
      tmp = f.elements[ii].name.split(":");
                                                                                          
      z = tmp[1] + "~" + f.elements[ii].value;
      a += (a == '') ? z : "|" + z;
   }
   
   //
   // Depending on if the user selected an unit or component, save
   //    the data in the appropriate place
   //
   f.commentinfo.value = a;

   // alert(b);
   return 1;
}

function ChkTime()
{
   f = document.mainform;

   var d = new Date();
   var curr_day = d.getDate();
   var curr_month = d.getMonth();
   var curr_year = d.getFullYear();

   fdate = f.flightdate.value;

   if ( fdate == '0000-00-00' ) { return true; }

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
   datefield = fdate.split("\-");
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
      alert(datefield[1]);
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
