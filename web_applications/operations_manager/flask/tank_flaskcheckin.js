var flask_notes = new Array();

function TankListCB()
{
   var f = document.mainform;
   var i = f.tanklist.selectedIndex;

   for ( i=0; i<f.tanklist.length; i++ )
   {
      if ( f.tanklist[i].selected )
      { f.tankid.value = f.tanklist[i].value; }
   }
}

function FlaskSelection(id)
{
   var f = document.mainform;
   var oflask_notes = top.document.getElementById('flask_notes');
   var tstr = '';
   var i;
   var checkedoutlistindex;
   var selectedlistindex;

   // Strip whitespace from Id
   id = id.replace(/\s+/g, '');

   if ( id == '' ) return;

   for (i=0,checkedoutlistindex=(-1); i<f.flasklist_checkedout.length; i++)
   {
      if ( f.flasklist_checkedout[i].value == id )
      { checkedoutlistindex = i; }
   }
   if ( checkedoutlistindex < 0 ) { alert(id+' not found in checked out flask list.'); return; }

   for (i=0,selectedlistindex=(-1); i<f.flasklist_selected.length; i++)
   {
      if ( f.flasklist_selected[i].value == id )
      { selectedlistindex = i; }
   }

   if ( selectedlistindex >= 0 )
   {
      f.flasklist_selected[selectedlistindex] = null;
      f.flasklist_checkedout[checkedoutlistindex].text = id;
   }
   else
   {
      f.flasklist_selected[f.flasklist_selected.length] = new Option(id,id,false,false);
      f.flasklist_checkedout[checkedoutlistindex].text = id+'*';
   }

   if ( flask_notes[id] != "NULL" && flask_notes[id] != "")
   { oflask_notes.innerHTML = "** FLASK **<BR>["+id+"]"+flask_notes[id]; }
   else
   { oflask_notes.innerHTML = ' '; }

   f.flasklist_checkedout[checkedoutlistindex].selected = 1;

   for (i=0; i<f.flasklist_selected.length; i++)
   {
      tstr += (i == 0) ? f.flasklist_selected[i].value : "~" + f.flasklist_selected[i].value;
   }

   f.selectedflasks.value = tstr;

   //
   // Set focus to flask scan text field
   //
   f.flaskscan.focus();

}

function AvailableListCB()
{
   var f = document.mainform;
   var i;

   for ( i=0; i<f.flasklist_checkedout.length; i++ )
   {
      if ( f.flasklist_checkedout[i].selected )
      {
         FlaskSelection(f.flasklist_checkedout[i].value);
         break;
      }
   }
}

function TankScanCB()
{
   var f = document.mainform;
   var i;

   if ( f.tankscan.value == '' ) return;

   for ( i=0; i<f.tanklist.length; i++ )
   {
      if ( f.tanklist[i].value == f.tankscan.value )
      { f.tanklist[i].selected = true; }
   }

   TankListCB();

   f.tankscan.value = '';
   f.tankscan.focus();
}

function FlaskScanCB()
{
   var f = document.mainform;

   if ( f.flaskscan.value == '') return;

   FlaskSelection(f.flaskscan.value);

   f.flaskscan.value = '';
   f.flaskscan.focus();
}

function OkayCB()
{
   var f = document.mainform;
   if (f.selectedflasks.value == '')  { return; }
   f.action = 'tank_flaskeventinput.php';
   f.submit();
}

function CancelCB()
{
   var f = document.mainform;
   if (f.tankid.value)
   {
      f.tankid.value = '';
      f.selectedflasks.value = '';
      f.submit();
   }
   else { document.location = 'flask_blank.php'; }
}

