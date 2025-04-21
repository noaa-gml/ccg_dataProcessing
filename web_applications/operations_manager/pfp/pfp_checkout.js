var flask_notes = new Array();
var send_notes = new Array();

function FlaskSelection(id)
{
   var f = document.mainform;
   var tstr = '';
   var oflask_notes = top.document.getElementById('flask_notes');
   var oselectedflaskcnt = top.document.getElementById('selectedflaskcnt');
   var i;
   var availablelistindex;
   var selectedlistindex;

   //
   // Strip whitespace from Id
   //
   id = id.replace(/\s+/g,'');
   
   if (id == '') return;
   //
   // Cannot assume selectedIndex of availablelist has been set
   //
   for (i=0,availablelistindex=(-1); i<f.availablelist.length; i++)
   {
      if (f.availablelist[i].value == id) {availablelistindex = i;}
   }
   if (availablelistindex < 0) { alert(id+' not found in available PFP list.');return; }

   for (i=0,selectedlistindex=(-1); i<f.selectedlist.length; i++)
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
      if (f.selectedlist.length == 1) { alert('Check out one PFP at a time.');return; }

      f.selectedlist[f.selectedlist.length] = new Option(id,id,false,false);
      f.availablelist[availablelistindex].text = id+'*';
   }
   //
   // Are there PFP comments?
   //
   if (flask_notes[availablelistindex] != "NULL" && flask_notes[availablelistindex] != "")
   { oflask_notes.innerHTML = '** PFP **<BR>['+id+'] '+flask_notes[availablelistindex]; }
   else { oflask_notes.innerHTML = ' '; }

   f.availablelist[availablelistindex].selected = 1;

   oselectedflaskcnt.innerHTML = f.selectedlist.length;

   for (i=0; i<f.selectedlist.length; i++)
   {
      tstr += (i == 0) ? f.selectedlist[i].value : "~" + f.selectedlist[i].value
   }
   f.selectedflasks.value = tstr;
   //
   // Set focus to flask scan text field
   //
   f.flaskscan.focus();
}

function SiteListCB()
{
   var f = document.mainform;
   var i =f.sitelist.selectedIndex;
   f.code.value = f.sitelist[i].value;
   f.selectedflasks.value = '';

   if (send_notes[i] != "NULL" && send_notes[i] != "")
   { f.send_notes.value = "** SEND **<BR>"+send_notes[i]; }
   else { f.send_notes.value = ''; }

   f.submit();
}

function ProjListCB()
{
   var f = document.mainform;
   var j = f.projlist.selectedIndex;
   f.proj_abbr.value = f.projlist[j].value;
   f.selectedflasks.value = '';
   f.code.value = '';
                                                                                          
   f.submit();
}

function AvailableListCB()
{
   var f = document.mainform;
   FlaskSelection(f.availablelist[f.availablelist.selectedIndex].value);
}

function FilterListCB()
{
   var f = document.mainform;
   if (f.code.value) { FilterSelection(); }
}

function OkayCB()
{
   var f = document.mainform;
   if (f.selectedflasks.value == '')  { return; }
   if (confirm('Are you sure?'))
   {
      f.action = 'pfp_sampleplan.php';
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
      f.selectedflasks.value = '';
      f.send_notes.value = '';
      f.submit();
   }
   else { document.location = 'pfp_blank.php'; }
}

function SiteScanCB()
{
   var i,j;
   var f = document.mainform;

   if (f.sitescan.value == '') return;

   var key = new RegExp(f.sitescan.value,'i');

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

function FlaskScanCB()
{
   var f = document.mainform;
   if (f.flaskscan.value == '') return;
   f.flaskscan.value = f.flaskscan.value.toUpperCase();
   FlaskSelection(f.flaskscan.value);
   f.flaskscan.blur();
   f.flaskscan.value = '';
   f.flaskscan.focus();
}
