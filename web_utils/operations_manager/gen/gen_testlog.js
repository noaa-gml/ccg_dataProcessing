function ListSelectCB(list)
{
   var f = document.mainform;

   if ( list.name == 'unitlist' )
   {
      f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.casenum.value = '';
      f.casetestnums.value = '';
      f.newtest.value = '';
   }

   if ( list.name == 'caselist' )
   {
      f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.casenum.value = f.caselist[f.caselist.selectedIndex].value;
      f.casetestnums.value = '';
      f.newtest.value = '';
   }

   if ( list.name == 'newtestlist' )
   {
      f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.casenum.value = f.caselist[f.caselist.selectedIndex].value;
      f.casetestnums.value = '';
      f.newtest.value = f.newtestlist[f.newtestlist.selectedIndex].value;
   }


   f.submit();
}

function UnitScanCB()
{
   var f = document.mainform;
   if (f.unitscan.value == '') return;

   f.unitid.value = f.unitscan.value;
   //f.casenum.value = '';
   //f.datetime.value = '';
   //f.newtest.value = '';

   f.unitscan.value = '';
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

   f.unitid.value = f.unitlist[f.unitlist.selectedIndex].value;
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
   f.casetestnums.value = selectedArray;
   f.newtest.value = '';

   f.submit();
}

function SaveData()
{
   //
   // Saves the data server side so that we can access it after the page submits
   // Note: 0 - FALSE, 1 - TRUE
   //
   var f = document.mainform;
                                
   if (f.unitid.value == '' && f.casetestnums.value == '') return 0;
   
   a = '';
   chk = '';
   key = new RegExp("data~",'i');
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

      field = f.elements[ii].name.split("~");
      tmp = field[1].split(":");

      z = field[1] + "~" + f.elements[ii].value;

      if ( z != '' ) 
      {
         a += (a == '') ? z : "|" + z;
      }
   }

   f.saveinfo.value = a;

   //
   // If data was actually entered
   //
   if ( a == '' ) return 0;
   
   return 1;

}

function AddCB()
{  
   //
   // Adding comments
   //
   var f = document.mainform;

   if ( f.unitid.value == '' && f.casenum.value == '' ) return;

   if (!(SaveData())) return;

   if (!confirm("Add data?")) return;

   f.task.value = 'add';
   f.submit();
}

function UpdateCB()
{
   // 
   // If the user clicks update
   //    
   var f = document.mainform;

   if ( f.unitid.value == '' && f.casenum.value == '' ) return;
  
   if (!(SaveData())) return;
         
   if (!confirm("Save data?")) return;
         
   f.task.value = 'update';
   f.submit();
}

function CloseCB()
{
   var f = document.mainform;

   if (!confirm("All unsaved data on the page will be lost.\nClose case?")) return;

   f.task.value = 'close';
   f.submit();
}

function ClearCB()
{
   //
   // If the user clicks clear, clear all information
   //
   var f = document.mainform;

   if ( f.unitid.value == '' && f.casenum.value == '' ) return;

   if (!confirm("Clear page?")) return;

   key = new RegExp("data~",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      f.elements[ii].value = '';
   }
}

function BackCB()
{
   //
   // If the user clicks back, step backwards through the page
   //
   var f = document.mainform;

   foundfield = 0;
   key = new RegExp("data~",'i');
   for (ii=0; ii<f.elements.length; ii++)
   {
      if (f.elements[ii].name.match(key) == null) continue;
      foundfield = 1;
      break;
   }

   if ( foundfield ) { if (!confirm("Unsaved data will be lost. Okay?")) return; }

   if ( f.newtest.value != '' || f.casetestnums.value != '' )
   {
      f.casetestnums.value = '';
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
         f.unitid.value = '';
      }
   }

   f.submit();
}

function SetBackground(element,state)
{
   color = (state) ? 'paleturquoise' : 'white';
   element.style.backgroundColor=color;
}

