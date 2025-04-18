var sitedesc = new Array();

function ListSelectCB(list)
{
   var f = document.mainform;

   //
   // If the user selects from the unit list, store the unit id and 
   //    reset the selected component
   //
   if ( list.name == 'unitlist' )
   {
      f.unit_id.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.datetime.value = ''
   }

   if ( list.name == 'datelist' )
   {
      f.unit_id.value = f.unitlist[f.unitlist.selectedIndex].value;
      f.datetime.value = f.datelist[f.datelist.selectedIndex].value;
   }

   if ( list.name == 'sitelist' )
   {
      f.sitenum.value = f.sitelist[f.sitelist.selectedIndex].value;
      f.projnum.value = f.projlist[f.projlist.selectedIndex].value;
      PostProjList();
   }
   else if ( list.name == 'projlist' )
   {
      f.sitenum.value = f.sitelist[f.sitelist.selectedIndex].value;
      f.projnum.value = f.projlist[f.projlist.selectedIndex].value;
   }
   else
   {
      f.submit();
   }
}

function PostProjList()
{
   var f = document.mainform;

   var code = f.sitelist[f.sitelist.selectedIndex].text;

   f.projlist.length = 0;
   //alert(code);
   //alert(sitedesc[code].length);
   for ( i=0; i<sitedesc[code].length; i++ )
   {
      tmp = sitedesc[code][i].split(/\|/);
      f.projlist[f.projlist.length] = new Option(tmp[1],sitedesc[code][i],false,false);
   }
}

function AddCB()
{
   //
   // Adding comments
   //
   var f = document.mainform;

   //if (!(ChkKeys())) return;

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
   var f = document.mainform;

   if (!confirm("Unsaved data will be lost. Okay?")) return;

   f.task.value = '';
   //f.unit_id.value = '';
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
   var f = document.mainform;

   if (f.unit_id.value == '' && f.datetime.value == '') return;

   if (!confirm("Unsaved data will be lost. Okay?")) return;
   
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
   var f = document.mainform;

   if (f.unit_id.value == '' && f.datetime.value == '') return;

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
   var f = document.mainform;

   //
   // Only comments that are associated with a component and an unit can be updated
   //
   if (f.unit_id.value == '' && f.datetime.value == '') return;

   //if (!(ChkKeys())) return;

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
   var f = document.mainform;

   if (f.unit_id.value == '' && f.datetime.value == '') return;

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

      tmp = f.elements[ii].name.split(/:/);

      z = tmp[1] + "~" + f.elements[ii].value;
      a += (a == '') ? z : "|" + z;
   }

   //
   // Depending on if the user selected an unit or component, save
   //    the data in the appropriate place
   //
   f.commentsave.value = a;

   b = '';
   key = new RegExp("keys:",'i');
   for (jj=0; jj<f.elements.length; jj++)
   {
      if (f.elements[jj].name.match(key) == null) continue;

      tmp = f.elements[jj].name.split(/:/);

      if ( f.elements[jj].value != -999 )
      {
         y = tmp[1] + "~" + f.elements[jj].value;
         b += (b == '') ? y : "|" + y;
      }
   } 

   f.keysave.value = b;
   f.sitenum.value = f.sitelist[f.sitelist.selectedIndex].value;
   f.projnum.value = f.projlist[f.projlist.selectedIndex].value;

   return 1;
}

function ChkKeys()
{
   var f = document.mainform;
   var b = '';
   var key = new RegExp("keys:",'i');
   var jj, ii;
   for (jj=0; jj<f.elements.length; jj++)
   {
      if (f.elements[jj].name.match(key) == null) continue;

      tmp = f.elements[jj].name.split(/:/);

      if ( f.elements[jj].value == -999 )
      {
         key = new RegExp("comments:"+tmp[1],'i');
         for (ii=0; ii<f.elements.length; ii++)
         {
            if (f.elements[ii].name.match(key) == null) continue;

            if ( f.elements[ii].value != '' )
            {
               alert("Must select a keyword for every log entry");
               return false;
            }
         }
      }
   } 
   return true;
}
