var unit_notes = new Array();

function UnitSelection(id,multiselect)
{
   var f = document.mainform;
   tstr = '';
   var ounit_notes = top.document.getElementById('unit_notes');
   var oselectedunitcnt = top.document.getElementById('selectedunitcnt');
   var i;
   //
   // Strip whitespace from Id
   //
   id = id.replace(/\s+/g,'');
   
   if (id == '') return;

   //
   // Cannot assume selectedIndex of availablelist has been set
   //
   for (var i=0,availablelistindex=(-1); i<f.availablelist.length; i++)
   {
      if (f.availablelist[i].value == id) {availablelistindex = i;}
   }
   if (availablelistindex < 0) { alert(id+' not found in available unit list.');return; }

   for (var i=0,selectedlistindex=(-1); i<f.selectedlist.length; i++)
   {
      if (f.selectedlist[i].value == id) {selectedlistindex = i;}
   }
   if (selectedlistindex >= 0)
   {
      f.selectedlist[selectedlistindex] = null;
      f.availablelist[availablelistindex].text = id;
   }
   else
   {
      if ( multiselect != 1 )
      {
         if (f.selectedlist.length == 1)
         { alert('Check out one unit at a time.');return; }
      }

      f.selectedlist[f.selectedlist.length] = new Option(id,id,false,false);
      f.availablelist[availablelistindex].text = id+'*';
   }
   //
   // Are there unit comments?
   //
   if (unit_notes[availablelistindex] != "NULL" && unit_notes[availablelistindex] != "")
   { ounit_notes.innerHTML = '** COMMENTS **<BR>['+id+'] '+unit_notes[availablelistindex]; }
   else { ounit_notes.innerHTML = ' '; }

   f.availablelist[availablelistindex].selected = 1;

   oselectedunitcnt.innerHTML = f.selectedlist.length;

   for (var i=0; i<f.selectedlist.length; i++)
   {
      tstr += (i == 0) ? f.selectedlist[i].value : "~" + f.selectedlist[i].value
   }
   f.selectedunits.value = tstr;
   //
   // Set focus to unit scan text field
   //
   f.unitscan.focus();

}

function AvailableListCB(multiselect, shownotes)
{
   var f = document.mainform;
   if ( f.availablelist.selectedIndex == -1 ) return;
   UnitSelection(f.availablelist[f.availablelist.selectedIndex].value,multiselect);

   if ( shownotes == 1 )
   { 
      if ( f.selectedlist.length > 0 )
      {
         f.shipping_notes.disabled = false;
      }
      else
      {
         f.shipping_notes.disabled = true;
      }
   }
}

function SiteListCB()
{
   var f = document.mainform;
   var i = f.sitelist.selectedIndex;

   f.code.value = f.sitelist[i].value;

   f.selectedunits.value = '';
   f.submit();
}

function OkayCB(action)
{
   var f = document.mainform;
   if (f.selectedunits.value == '')  { return; }
   if (confirm('Are you sure?'))
   {
      f.task.value = 'chkout';
      f.submit();
   }
   else { return; }
}

function CancelCB()
{
   var f = document.mainform;
   if (f.code.value)
   {
      f.code.value = '';
      f.task.value = '';
      f.selectedunits.value = '';
      f.submit();
   }
   else { document.location = omurl+'index2.php?invtype='+invtype; }
}

function SiteScanCB()
{
   var i,j;
   var f = document.mainform;

   if (f.sitescan.value == '') return;

   key = new RegExp(f.sitescan.value,'i');

   for (i=0,j=(-1); i<f.sitelist.length; i++)
   { if (f.sitelist.options[i].value.match(key) != null) { j = i; } }
   if (j < 0)
   {
      alert(f.sitescan.value+' not found in available site list.');
      f.sitescan.value = '';
      return;
   }
   f.sitelist[j].selected = true;

   SiteListCB();
   f.sitescan.blur();
   f.sitescan.value = '';
   f.sitescan.focus();
}

function UnitScanCB(multiselect)
{
   var f = document.mainform;
   if (f.unitscan.value == '') return;
   UnitSelection(f.unitscan.value,multiselect);
   f.unitscan.blur();
   f.unitscan.value = '';
   f.unitscan.focus();
}

function ProjListCB()
{
   var f = document.mainform;
   var j = f.projlist.selectedIndex;
   f.proj_abbr.value = f.projlist[j].value;
   f.selectedunits.value = '';
   f.code.value = '';

   f.submit();
}
