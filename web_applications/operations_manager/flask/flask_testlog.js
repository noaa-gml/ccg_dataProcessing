function ListSelectCB(list)
{
   var f = document.mainform;

   if ( list.name == 'flasklist' )
   {
      f.flaskid.value = f.flasklist[f.flasklist.selectedIndex].value;
      f.casenum.value = '';
      f.datetime.value = '';
      f.newtest.value = '';
   }

   if ( list.name == 'caselist' )
   {
      f.flaskid.value = f.flasklist[f.flasklist.selectedIndex].value;
      f.casenum.value = f.caselist[f.caselist.selectedIndex].value;
      f.datetime.value = '';
      f.newtest.value = '';
   }

   if ( list.name == 'newtestlist' )
   {
      f.flaskid.value = f.flasklist[f.flasklist.selectedIndex].value;
      f.casenum.value = f.caselist[f.caselist.selectedIndex].value;
      f.newtest.value = f.newtestlist[f.newtestlist.selectedIndex].value;
      f.datetime.value = '';
   }

   f.submit();
}

function TestSelectCB()
{
   //
   // If the user selects from the test list, grab all of the selected values
   // and put them into an array
   //

   var f = document.mainform;

   if ( f.testlist.selectedIndex == -1 ) return;

   f.flaskid.value = f.flasklist[f.flasklist.selectedIndex].value;
   f.casenum.value = f.caselist[f.caselist.selectedIndex].value;

   selectedArray = new Array();
   var i;
   var count = 0;
   for (i=0; i < f.testlist.length; i++) {
      if ( f.testlist.options[i].selected )
      {
         selectedArray[count] = f.testlist.options[i].value;
         count++;
      }
   }

   //
   // When you set an array to a non-array element, all the entries
   // are put into the non-array element deliminated by commas
   //
   f.datetime.value = selectedArray;
   f.newtest.value = '';

   f.submit();
}

function FlaskScanCB()
{
   var f = document.mainform;
   if (f.flaskscan.value == '') return;

   f.flaskid.value = f.flaskscan.value;
   f.casenum.value = '';
   f.datetime.value = '';
   f.newtest.value = '';

   f.flaskscan.value = '';
   f.submit();
}

function AddCB()
{
   //
   // Adding comments
   //
   var f = document.mainform;

   if ( f.flaskid.value == '' && f.casenum.value == '' ) return;

   if (!(SaveData())) return;

   if (!confirm("Add data?")) return;

   f.task.value = 'add';
   f.submit();
}

function BackCB()
{
   //
   // If the user clicks back, step backwards through the page
   //
   var f = document.mainform;

   if (!confirm("Unsaved data will be lost. Okay?")) return;

   if ( f.newtest.value != '' || f.datetime.value != '' )
   {
      f.datetime.value = '';
      f.newtest.value = '';
   }
   else
   {
      if ( f.casenum.value != '' )
      {
         f.casenum.value = '';
      }
      else
      {
         f.flaskid.value = '';
      }
   }

   f.submit();
}

function ClearCB()
{
   //
   // If the user clicks clear, clear all information
   //
   var f = document.mainform;

   if ( f.flaskid.value == '' && f.casenum.value == '' ) return;

   if (!confirm("Clear page?")) return;
   
   key = new RegExp(f.table.value+":",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      f.elements[ii].value = '';
   }
}

function UpdateCB()
{
   //
   // If the user clicks update
   //
   var f = document.mainform;

   if ( f.flaskid.value == '' && f.casenum.value == '' ) return;

   if (!(SaveData())) return;

   if (!confirm("Save data?")) return;

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
   // Note: 0 - FALSE, 1 - TRUE
   //
   var f = document.mainform;
                                                                                          
   if (f.flaskid.value == '' && f.datetime.value == '') return 0;

   a = '';
   chk = '';
   key = new RegExp(f.table.value+":",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      z = '';

      if (f.elements[ii].name.match(key) == null) continue;
      //
      // Disallow use of '~' and '|'
      //
      if (f.elements[ii].value.match(/\~/) != null)
      { f.elements[ii].focus(); alert('Use of \'~\' not allowed'); return 0; }

      if (f.elements[ii].value.match(/\|/) != null)
      { f.elements[ii].focus(); alert('Use of \'|\' not allowed'); return 0; }

      tmp = f.elements[ii].name.split(":");

      if ( f.table.value != 'flask_log_case' && tmp[1] == 'keyword_num' )
      {
         commkey = new RegExp(f.table.value+":comments:"+tmp[2],'i');
         for (jj=0; jj<f.elements.length; jj++)
         {
            if (f.elements[jj].name.match(commkey) == null) continue;
             
            if ( f.elements[ii].value == '' && f.elements[jj].value != '' )
            {
               alert("Please select a keyword");
               return 0;
            }
         }
         z = tmp[1] + ":" + tmp[2] + "~" + f.elements[ii].value;
         chk = chk + f.elements[ii].value;
      }
      else
      {
         if ( tmp[1] == 'keyword_num' )
         {
            commkey = new RegExp(f.table.value+":comments",'i');
            for (jj=0; jj<f.elements.length; jj++)
            {
               if (f.elements[jj].name.match(commkey) == null) continue;
               
               if ( f.elements[ii].value == '' && f.elements[jj].value != '' )
               {
                  alert("Please select a keyword");
                  return 0;
               }
            }
         }

         if ( tmp[1] == 'comments' && f.table.value != 'flask_log_case' )
         {
            z = tmp[1] + ":" + tmp[2] + "~" + f.elements[ii].value;
            chk = chk + f.elements[ii].value;
         }
         else
         {
            z = tmp[1] + "~" + f.elements[ii].value;
            chk = chk + f.elements[ii].value;
         }
      }

      if ( z != '' )
      {
         a += (a == '') ? z : "|" + z;
      }
   }
   
   //
   // Write the data to the webpage
   //
   f.saveinfo.value = a;

   //
   // If data was actually entered
   //
   if ( chk == '' ) return 0;

   return 1;
}

function CloseCB()
{
   var f = document.mainform;

   if (!confirm("All data on the page will be lost.\nClose case?")) return;

   f.task.value = 'close';
   f.submit();
}
